FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://platform-top.h file://bsp.cfg"

UBOOT_NETBOOT_MODE ??= "sd-only"

# Versal: no Versal machine strips platform-top.h from SRC_URI today; the guard
# below keeps this body a no-op for any future board that does.
do_configure:append () {
	if [ -f ${WORKDIR}/platform-top.h ]; then
		install ${WORKDIR}/platform-top.h ${S}/include/configs/
		# @BOOTCMD_SEL@ is the WHOLE bootcmd value, so sd-only can drop 'run netboot'
		# entirely and never pay the PXE/TFTP timeouts on a board with no TFTP server.
		# @LOADPL_SEL@ selects whether netboot programs the PL from TFTP-fetched
		# images (loadpl_net, tftp-only/diskless; on Versal it also applies pl.dtbo
		# and boots) or does nothing (loadpl_skip, fallback and sd-only -- SD
		# fpgautil owns the PL). Barewords keep '&&' out of the sed replacements,
		# and the literals stay inline rather than in shell variables because
		# BitBake would capture a ${...} expansion at parse time. Every replacement
		# is plain text on purpose: no '&' (sed's whole-match), no '|' (the
		# delimiter), and no '\' or '"' (the text lands inside a C string literal).
		# ';' is safe inside a sed replacement, but the sed script MUST stay
		# double-quoted or the shell would fork at it.
		case "${UBOOT_NETBOOT_MODE}" in
			tftp-only)
				sed -i "s|@BOOTCMD_SEL@|run netboot; echo TFTP-only build: not falling back to SD|" \
					${S}/include/configs/platform-top.h
				sed -i "s|@LOADPL_SEL@|loadpl_net|" ${S}/include/configs/platform-top.h
				;;
			fallback)
				sed -i "s|@BOOTCMD_SEL@|run netboot; run sdboot|" ${S}/include/configs/platform-top.h
				sed -i "s|@LOADPL_SEL@|loadpl_skip|" ${S}/include/configs/platform-top.h
				;;
			*)
				# sd-only (the default). The leading echo is not decoration: it is
				# the only mode whose bootcmd would otherwise be indistinguishable
				# from the stock upstream 'run distro_bootcmd', so it gives the mode
				# both a unique 'strings BOOT.BIN' signature and a serial-console one.
				if [ -n "${UBOOT_NETBOOT_MODE}" ] && [ "${UBOOT_NETBOOT_MODE}" != "sd-only" ]; then
					bbwarn "Unrecognized UBOOT_NETBOOT_MODE '${UBOOT_NETBOOT_MODE}'; building 'sd-only'"
				fi
				sed -i "s|@BOOTCMD_SEL@|echo SD-only build: skipping netboot; run sdboot|" \
					${S}/include/configs/platform-top.h
				sed -i "s|@LOADPL_SEL@|loadpl_skip|" ${S}/include/configs/platform-top.h
				;;
		esac
		# Versal: the loadaie_ env stacks AIE PDIs in loadpl_net and exists only on
		# a machine with the aie feature; without it the definitions are deleted
		# and the AIE step becomes loadpl_skip, so the env carries no AIE text at
		# all. The aie test is parse-time inline python, the same form
		# startup-app-init.bb uses.
		if ${@bb.utils.contains('MACHINE_FEATURES', 'aie', 'true', 'false', d)}; then
			sed -i "s|@LOADAIE_SEL@|loadaie_net|" ${S}/include/configs/platform-top.h
		else
			sed -i "/^[[:space:]]*\"loadaie_/d" ${S}/include/configs/platform-top.h
			sed -i "s|@LOADAIE_SEL@|loadpl_skip|" ${S}/include/configs/platform-top.h
		fi
	fi
}
