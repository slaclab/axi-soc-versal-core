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
           file://aie-partition-init.service \
           file://xlnx-ai-engine.h \
"

S = "${WORKDIR}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "aie-partition-init.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -Wall -Wextra -I${WORKDIR} \
        -o ${WORKDIR}/aie-partition-init ${WORKDIR}/aie-partition-init.c
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/aie-partition-init ${D}${bindir}/
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aie-partition-init.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "${bindir}/aie-partition-init \
               ${systemd_system_unitdir}/aie-partition-init.service \
"
