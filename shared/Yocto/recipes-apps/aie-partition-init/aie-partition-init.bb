#
# This file is the aie-partition-init recipe.
#

SUMMARY = "AIE userspace partition-init agent"
DESCRIPTION = "Holds an AIE partition fd open via AIE_REQUEST_PART_IOCTL + \
AIE_PARTITION_INIT_IOCTL on /dev/aie0 so the in-tree xilinx-ai-engine driver \
exposes /sys/class/aie/aiepart_<col>_<numcols>/ for downstream PL DMA / AIE \
loopback paths. Without this agent the driver only creates the aperture."
SECTION = "Yocto/apps"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://aie-partition-init.c \
           file://aie-partition-init@.service \
"

S = "${WORKDIR}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "aie-partition-init@.service"

DEPENDS += "virtual/kernel"
do_configure[depends] += "virtual/kernel:do_shared_workdir"

do_configure:prepend() {
    kern_uapi="${STAGING_KERNEL_DIR}/include/uapi/linux/xlnx-ai-engine.h"
    if [ ! -f "${kern_uapi}" ]; then
        bbfatal "aie-partition-init: AIE UAPI header not found at ${kern_uapi}. \
The agent must be compiled against the running kernel's ioctl ABI; refusing \
to build against a stale header. Check that virtual/kernel exports \
include/uapi/linux/xlnx-ai-engine.h (CONFIG_XILINX_AIE) for this release."
    fi
    bbnote "aie-partition-init: using AIE UAPI header from kernel source ${kern_uapi}"
    install -m 0644 "${kern_uapi}" "${WORKDIR}/xlnx-ai-engine.h"
}

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -Wall -Wextra -I${WORKDIR} \
        -o ${WORKDIR}/aie-partition-init ${WORKDIR}/aie-partition-init.c
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/aie-partition-init ${D}${bindir}/
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aie-partition-init@.service \
        ${D}${systemd_system_unitdir}/aie-partition-init@.service
}

FILES:${PN} = "${bindir}/aie-partition-init \
               ${systemd_system_unitdir}/aie-partition-init@.service \
"
