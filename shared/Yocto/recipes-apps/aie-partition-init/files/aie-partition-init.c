/*
 * SPDX-License-Identifier: MIT
 *
 * AIE userspace partition-init agent.
 *
 * Opens /dev/aie0, calls AIE_REQUEST_PART_IOCTL to create the partition
 * for our PL geometry (start_col=0, num_cols=38), then AIE_PARTITION_INIT_IOCTL
 * to boot the columns. Holds the returned partition fd open via pause() so
 * the kernel doesn't destroy the partition on last close.
 *
 * Compile-time constants are derived from the Phase-2 AIE build:
 *   partition_id = aie_calc_part_id(0, 38) = 0x2600
 *   uid          = aie_partition.json::aie_pl_intf_id = 0xc8f9a8af
 *
 * No CLI flags. No retry loop (systemd Restart=on-failure handles it).
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
#define AIE_PARTITION_ID  0x2600u
#define AIE_PARTITION_UID 0xc8f9a8afu
#define AIE_INIT_OPTS    (AIE_PART_INIT_OPT_COLUMN_RST  | \
                          AIE_PART_INIT_OPT_SHIM_RST    | \
                          AIE_PART_INIT_OPT_ZEROIZEMEM  | \
                          AIE_PART_INIT_ERROR_HANDLING  | \
                          AIE_PART_INIT_OPT_ENB_COLCLK_BUFF)

static volatile sig_atomic_t g_stop = 0;
static void on_term(int signo) { (void)signo; g_stop = 1; }

int main(void)
{
    /* Catch SIGTERM so systemd 'stop' is graceful (kernel will tear down
     * the partition on last close anyway, but logging the exit is useful). */
    struct sigaction sa = { .sa_handler = on_term };
    sigemptyset(&sa.sa_mask);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGINT,  &sa, NULL);

    int aie_fd = open(AIE_DEV, O_RDWR);
    if (aie_fd < 0) {
        fprintf(stderr, "open(%s) failed: %s\n", AIE_DEV, strerror(errno));
        return 1;
    }

    struct aie_partition_req req = {
        .partition_id = AIE_PARTITION_ID,
        .uid          = AIE_PARTITION_UID,
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
            AIE_PARTITION_ID, AIE_PARTITION_UID, init_args.init_opts);
    fflush(stdout);

    /* Partition is destroyed on last close — block forever to keep the fd. */
    while (!g_stop) pause();

    close(part_fd);
    close(aie_fd);
    return 0;
}
