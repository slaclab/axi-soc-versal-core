/*
 * SPDX-License-Identifier: MIT
 *
 * AIE userspace partition-init agent.
 *
 * Opens /dev/aie0, calls AIE_REQUEST_PART_IOCTL to create the partition
 * described by a sidecar config file, then AIE_PARTITION_INIT_IOCTL to
 * boot the columns. Holds the returned partition fd open via pause() so
 * the kernel doesn't destroy the partition on last close.
 *
 * Config is sourced from a two-key shell-style sidecar:
 *   PARTITION_ID=0x2600
 *   UID=0xc8f9a8af
 *
 * Usage: aie-partition-init --conf /boot/aie/<name>.partition.conf
 *        aie-partition-init -c     /boot/aie/<name>.partition.conf
 *
 * No retry loop (systemd Restart=on-failure handles it).
 */

#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

/*
 * The vendored xlnx-ai-engine.h UAPI header uses BIT(n) for the
 * AIE_PART_INIT_OPT_* flag values but only includes <linux/ioctl.h>
 * and <linux/types.h>.  Provide the BIT() shim before the include
 * so userspace toolchains without <linux/bits.h> still build cleanly.
 */
#ifndef BIT
#define BIT(n) (1U << (n))
#endif

#include "xlnx-ai-engine.h"

#define AIE_DEV           "/dev/aie0"
/* COLUMN_RST, SHIM_RST, and ZEROIZEMEM are intentionally omitted.
 * Those flags halt and zero AIE compute tiles, destroying the loopback
 * graph that aie_cdo_elfs.bin + aie_cdo_enable.bin loaded at PDI time.
 * Keep only the non-destructive options so the running graph is preserved. */
#define AIE_INIT_OPTS    (AIE_PART_INIT_ERROR_HANDLING  | \
                          AIE_PART_INIT_OPT_ENB_COLCLK_BUFF)

static volatile sig_atomic_t g_stop = 0;
static void on_term(int signo) { (void)signo; g_stop = 1; }

int main(int argc, char *argv[])
{
    /* Catch SIGTERM so systemd 'stop' is graceful (kernel will tear down
     * the partition on last close anyway, but logging the exit is useful). */
    struct sigaction sa = { .sa_handler = on_term };
    sigemptyset(&sa.sa_mask);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGINT,  &sa, NULL);

    /* --- CLI parsing (D-01, D-02, D-03) --------------------------------- */
    const char *conf_path = NULL;

    /* Hand-roll --conf before getopt so both forms are accepted (D-01) */
    if (argc >= 3 && strcmp(argv[1], "--conf") == 0) {
        conf_path = argv[2];
    } else {
        int opt;
        while ((opt = getopt(argc, argv, "c:h")) != -1) {
            switch (opt) {
            case 'c': conf_path = optarg; break;
            case 'h':
                fprintf(stdout, "Usage: %s --conf <path>\n", argv[0]);
                return 0;
            default:
                fprintf(stderr, "Usage: %s --conf <path>\n", argv[0]);
                return 1;
            }
        }
    }
    if (!conf_path) {
        fprintf(stderr, "%s: --conf <path> is required\n", argv[0]);
        return 1;
    }

    /* --- Sidecar parser (D-04 through D-09) ------------------------------ */
    struct { uint32_t partition_id; uint32_t uid; } conf = {0, 0};
    int have_partition_id = 0, have_uid = 0;

    FILE *fp = fopen(conf_path, "r");
    if (!fp) {
        fprintf(stderr, "%s: cannot open %s: %s\n", argv[0], conf_path, strerror(errno));
        return 1;
    }

    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        /* Strip trailing newline/whitespace */
        char *p = line + strlen(line);
        while (p > line && (p[-1] == '\n' || p[-1] == '\r' || p[-1] == ' ' || p[-1] == '\t'))
            *--p = '\0';
        p = line;
        /* Skip leading whitespace (D-04) */
        while (*p == ' ' || *p == '\t') p++;
        /* Skip blank lines and # comments (D-04, D-07) */
        if (*p == '\0' || *p == '#') continue;

        char *eq = strchr(p, '=');
        if (!eq) {
            fprintf(stderr, "%s: malformed line in %s: %s\n", argv[0], conf_path, p);
            fclose(fp);
            return 1;
        }
        *eq = '\0';
        const char *key = p;
        const char *val = eq + 1;

        unsigned long parsed_ul;
        char *end;
        if (strcmp(key, "PARTITION_ID") == 0) {
            parsed_ul = strtoul(val, &end, 0);
            if (*end != '\0' || parsed_ul > UINT32_MAX) {
                fprintf(stderr, "%s: unparsable PARTITION_ID value: %s\n", argv[0], val);
                fclose(fp);
                return 1;
            }
            conf.partition_id = (uint32_t)parsed_ul;
            have_partition_id = 1;
        } else if (strcmp(key, "UID") == 0) {
            parsed_ul = strtoul(val, &end, 0);
            if (*end != '\0' || parsed_ul > UINT32_MAX) {
                fprintf(stderr, "%s: unparsable UID value: %s\n", argv[0], val);
                fclose(fp);
                return 1;
            }
            conf.uid = (uint32_t)parsed_ul;
            have_uid = 1;
        } else {
            fprintf(stderr, "%s: unknown key in %s: %s\n", argv[0], conf_path, key);
            fclose(fp);
            return 1;
        }
    }
    fclose(fp);

    if (!have_partition_id) {
        fprintf(stderr, "%s: PARTITION_ID missing in %s\n", argv[0], conf_path);
        return 1;
    }
    if (!have_uid) {
        fprintf(stderr, "%s: UID missing in %s\n", argv[0], conf_path);
        return 1;
    }

    int aie_fd = open(AIE_DEV, O_RDWR);
    if (aie_fd < 0) {
        fprintf(stderr, "open(%s) failed: %s\n", AIE_DEV, strerror(errno));
        return 1;
    }

    struct aie_partition_req req = {
        .partition_id = conf.partition_id,
        .uid          = conf.uid,
        .meta_data    = 0,
        .flag         = 0,
    };
    int part_fd = ioctl(aie_fd, AIE_REQUEST_PART_IOCTL, &req);
    if (part_fd < 0) {
        fprintf(stderr, "ioctl(AIE_REQUEST_PART_IOCTL, id=0x%x, uid=0x%x) failed: %s\n",
                req.partition_id, req.uid, strerror(errno));
        close(aie_fd);
        return 2;
    }

    /*
     * Note: aie_partition_init_args has no partition_id field — the
     * partition fd returned by AIE_REQUEST_PART_IOCTL identifies it.
     * Layout (per July 2025 upstream — board kernel 6.12.10-xilinx):
     *   { locs*, num_tiles, init_opts, ecc_scrub, handshake*, handshake_size }
     * Designated init zero-fills the unused fields.
     */
    struct aie_partition_init_args init_args = {
        .locs         = NULL,
        .num_tiles    = 0,
        .init_opts    = AIE_INIT_OPTS,
    };
    if (ioctl(part_fd, AIE_PARTITION_INIT_IOCTL, &init_args) < 0) {
        fprintf(stderr, "ioctl(AIE_PARTITION_INIT_IOCTL, opts=0x%x) failed: %s\n",
                init_args.init_opts, strerror(errno));
        close(part_fd);
        close(aie_fd);
        return 3;
    }

    fprintf(stdout, "aie-partition-init: partition 0x%x ready (uid=0x%x, opts=0x%x); blocking\n",
            conf.partition_id, conf.uid, init_args.init_opts);
    fflush(stdout);

    /* Partition is destroyed on last close — block forever to keep the fd. */
    while (!g_stop) pause();

    close(part_fd);
    close(aie_fd);
    return 0;
}
