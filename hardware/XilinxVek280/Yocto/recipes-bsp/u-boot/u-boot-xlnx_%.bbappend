# VEK280: Linux leaves the ADIN1300 in software power-down across a warm
# reboot, so this patch clears it before U-Boot autonegotiates; it lets
# netboot's dhcp bring the link up on the same PHY Linux just suspended.
# The shared netboot hooks stay in shared/Yocto.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://0001-net-phy-clear-BMCR-power-down-before-autoneg.patch"
