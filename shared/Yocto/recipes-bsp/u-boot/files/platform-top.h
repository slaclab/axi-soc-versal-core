#include <configs/xilinx_versal.h>

#undef CFG_EXTRA_ENV_SETTINGS
#define CFG_EXTRA_ENV_SETTINGS \
	ENV_MEM_LAYOUT_SETTINGS \
	BOOTENV \
	/* Static-IP override placeholders, deliberately empty; site-configurable, */ \
	/* never a hardcoded subnet. */ \
	"serverip=\0" \
	"ipaddr=\0" \
	"gatewayip=\0" \
	"netmask=\0" \
	/* Prefer a preset static IP over DHCP when one is configured. */ \
	/* && short-circuits so a dhcp or tftp failure each bail out at their own */ \
	/* independent, hardcoded lwIP timeout (~6.2s measured for TFTP-fail, */ \
	/* DHCP-fail unmeasured) rather than summing both stages' timeouts. */ \
	/* loadpl_net runs from netboot only in the tftp-only (diskless) build. */ \
	/* 'setexpr gsub' rewrites ${ethaddr}'s colons to dashes into ${macfn} */ \
	/* (U-Boot's tftpboot parses the first ':' in a filename as a hostIP */ \
	/* separator, so a colon-form name is unusable). Probe order is most- */ \
	/* to least-specific, <name>.<mac-dashes> -> <name>; a miss costs one */ \
	/* immediate TFTP NAK, not a timeout. 0x10000000 is reused sequentially. */ \
	/* The chain is && so any fetch, load or apply failure aborts netboot */ \
	/* before the kernel boots. ${filesize} is set by whichever tftpboot */ \
	/* succeeded. */ \
	/* On Versal loadpl_net also boots. It fpga-loads pl.pdi (PM_LOAD_PDI to */ \
	/* the PLM), fetches the standalone base DTB system-top.dtb (the DTB */ \
	/* image.ub embeds, with __symbols__) to fdt_addr_r and pl.dtbo to */ \
	/* fdtoverlay_addr_r, fdt-applies the overlay so the PL nodes are live */ \
	/* without Linux applying one, sets the /chosen property slac,boot-mode */ \
	/* to tftp-only for startup-app-init, stacks the AIE PDI(s) when the */ \
	/* machine has the aie feature, then fetches image.ub to kernel_addr_r */ \
	/* and bootm's the FIT kernel and ramdisk with the patched DTB as the */ \
	/* explicit FDT argument. The FIT address is passed twice because a '-' */ \
	/* ramdisk argument skips the FIT ramdisk, and 'pxe boot' is not used */ \
	/* because it would boot the FIT's embedded DTB and drop the overlay. It */ \
	/* never returns on success, so netboot's PXE tail is never reached in */ \
	/* tftp-only. */ \
	/* Versal's ENV_MEM_LAYOUT_SETTINGS has no overlay address; this sits */ \
	/* just past fdt_addr_r plus fdt_size_r. */ \
	"fdtoverlay_addr_r=0x40400000\0" \
	"loadpl_net=setexpr macfn gsub : - ${ethaddr} && if tftpboot 0x10000000 pl.pdi.${macfn}; then true; else tftpboot 0x10000000 pl.pdi; fi && fpga load 0 0x10000000 ${filesize} && if tftpboot ${fdt_addr_r} system-top.dtb.${macfn}; then true; else tftpboot ${fdt_addr_r} system-top.dtb; fi && if tftpboot ${fdtoverlay_addr_r} pl.dtbo.${macfn}; then true; else tftpboot ${fdtoverlay_addr_r} pl.dtbo; fi && fdt addr ${fdt_addr_r} && fdt resize 0x10000 && fdt apply ${fdtoverlay_addr_r} && fdt set /chosen slac,boot-mode tftp-only && run @LOADAIE_SEL@ && if tftpboot ${kernel_addr_r} image.ub.${macfn}; then true; else tftpboot ${kernel_addr_r} image.ub; fi && bootm ${kernel_addr_r} ${kernel_addr_r} ${fdt_addr_r}\0" \
	"loadaie_net=if tftpboot 0x10000000 aie/manifest.${macfn}; then run loadaie_list; elif tftpboot 0x10000000 aie/manifest; then run loadaie_list; else echo No AIE manifest served, booting PL only; fi\0" /* U-Boot learns the AIE image names from aie/manifest (one aie_names= line, per-MAC name first), so an AIE rebuild never needs a BOOT.BIN redeploy, no manifest served means a PL-only boot, and each loadaie_ line carries its own comment so the u-boot bbappend deletes both together on a machine without the aie feature */ \
	"loadaie_list=setenv aie_names && env import -t 0x10000000 ${filesize} aie_names && test -n \"${aie_names}\" && fdt mknode /chosen slac,aie && setenv aie_ok 1 && for n in ${aie_names}; do if itest.b ${aie_ok} -eq 1; then setenv aie_n ${n}; run loadaie_one || setenv aie_ok 0; fi; done && itest.b ${aie_ok} -eq 1\0" /* env import -t names aie_names so a served manifest can set nothing else, and the old hush parser has no break, so a setenv-backed aie_ok flag skips the remaining images after the first failure and the list then fails */ \
	"loadaie_one=if tftpboot 0x10000000 aie/${aie_n}.pdi.${macfn}; then true; else tftpboot 0x10000000 aie/${aie_n}.pdi; fi && fpga load 0 0x10000000 ${filesize} && if tftpboot 0x10000000 aie/${aie_n}.partition.conf.${macfn}; then true; else tftpboot 0x10000000 aie/${aie_n}.partition.conf; fi && setenv PARTITION_ID && setenv UID && env import -t 0x10000000 ${filesize} PARTITION_ID UID && test -n \"${PARTITION_ID}\" && test -n \"${UID}\" && fdt mknode /chosen/slac,aie ${aie_n} && fdt set /chosen/slac,aie/${aie_n} partition-id ${PARTITION_ID} && fdt set /chosen/slac,aie/${aie_n} uid ${UID} && setenv PARTITION_ID && setenv UID\0" /* once the manifest names an image a failed fetch or fpga load of its PDI, or a failed fetch or import of its partition.conf, halts, and PARTITION_ID and UID (imported by name) become /chosen/slac,aie/<name> partition-id and uid for startup-app-init */ \
	/* fallback and sd-only builds: no U-Boot PL load -- the SD's */ \
	/* startup-app-init fpgautil owns the PL exactly as before (avoids a */ \
	/* double-program). */ \
	"loadpl_skip=true\0" \
	/* PXE-first: 'pxe get' downloads pxelinux.cfg/01-<MAC> (else .../default) from */ \
	/* ${serverip} and 'pxe boot' loads the KERNEL FIT it names (FIT -> bootm). This */ \
	/* lets boot behavior change server-side without reflashing U-Boot or editing the */ \
	/* board env. If no PXE config is served, fall back to fetching image.ub directly. */ \
	/* Addresses (pxefile_addr_r/kernel_addr_r) come from ENV_MEM_LAYOUT_SETTINGS -- do */ \
	/* not hand-set them here. 'run @LOADPL_SEL@' is substituted at build time by the */ \
	/* u-boot bbappend to loadpl_net (tftp-only) or loadpl_skip (fallback, sd-only); the */ \
	/* bareword swap keeps '&&' out of the bbappend sed replacement. */ \
	/* DHCP + serverip (lwIP): 'dhcp' unconditionally overwrites ${serverip} with the */ \
	/* DHCP server's own address, and sets ${tftpserverip} from the next-server (siaddr) */ \
	/* field when present; 'tftpboot'/'pxe' prefer ${tftpserverip} over ${serverip}. The */ \
	/* legacy CONFIG_BOOTP_SERVERIP knob does NOT exist in the lwIP DHCP path, so we work */ \
	/* around it here: when ${serverip} is already set (authoritative site config), stash */ \
	/* it, run dhcp, then restore serverip and clear tftpserverip. A failed dhcp short- */ \
	/* circuits the && chain with no restore (correct -- nothing was bound/clobbered), */ \
	/* still bailing at the hardcoded lwIP timeout. To hand TFTP addressing back to DHCP, */ \
	/* clear serverip ('setenv serverip'). */ \
	/* Versal: before dhcp, wait up to about 12 seconds for the EEPROM MAC to become */ \
	/* readable at i2c bus 1, chip 0x54, offset 0xa8 (the bound is written 0xc since */ \
	/* U-Boot setexpr stores its result in hex and itest parses its operands in hex too, */ \
	/* so a plain decimal "12" would actually bound at 18 iterations). Exhausting the */ \
	/* bound deliberately skips this dhcp attempt so the sequential bootcmd still falls */ \
	/* through to sdboot instead of re-probing the GEM with no MAC. */ \
	"netboot=if test -n \"${ipaddr}\"; then true; else setenv ok 0; setenv i 0; while itest.b ${ok} -eq 0 && itest.b ${i} -lt 0xc; do i2c dev 1 && i2c md 0x54 0xa8 6 && setenv ok 1; if itest.b ${ok} -eq 0; then setexpr i ${i} + 1; sleep 1; fi; done; if itest.b ${ok} -eq 1; then if test -n \"${serverip}\"; then setenv _sip ${serverip}; dhcp && setenv serverip ${_sip} && setenv tftpserverip && setenv _sip; else dhcp; fi; fi; fi && run @LOADPL_SEL@ && if pxe get; then pxe boot; else tftpboot 0x10000000 image.ub && bootm 0x10000000; fi\0" \
	/* Reuse the existing, unmodified SD-boot mechanism verbatim. */ \
	"sdboot=run distro_bootcmd\0" \
	/* The WHOLE bootcmd value is substituted at build time by the u-boot bbappend, not */ \
	/* just a trailing mode action, so a mode can opt out of netboot entirely: */ \
	/*   sd-only (default) -> echo <skipping netboot>; run sdboot            */ \
	/*   fallback          -> run netboot; run sdboot                        */ \
	/*   tftp-only         -> run netboot; echo <not falling back to SD>     */ \
	/* sd-only's leading echo gives it a unique 'strings BOOT.BIN' signature and a */ \
	/* serial-console one; a bare 'run sdboot' would be indistinguishable from the */ \
	/* stock upstream 'run distro_bootcmd' that U-Boot also emits into the env. */ \
	/* sd-only exists because netboot is PXE-first: with no TFTP server answering, */ \
	/* 'pxe get' walks 13 pxelinux.cfg names and the direct image.ub fetch follows, and */ \
	/* each of those 14 attempts waits its full ~6s request timeout (~85s server-down, */ \
	/* ~110s under a silent DROP). A board that never had a TFTP server paid that on */ \
	/* every boot. 'run sdboot' is 'run distro_bootcmd', i.e. the stock upstream Versal */ \
	/* bootcmd, so sd-only introduces no new boot path. The netboot and loadpl_* env */ \
	/* vars above stay DEFINED in every mode -- they cost nothing at boot and keep */ \
	/* 'run netboot' available by hand for recovery on an sd-only board. */ \
	/* Where 'run netboot' IS in bootcmd, the sequence is deliberately sequential and */ \
	/* NOT exit-code-gated: a successful boot never returns to the U-Boot shell, so */ \
	/* merely reaching the mode action proves netboot failed -- no exit code needed. */ \
	/* This stays correct even for boot methods that lie about their status: upstream */ \
	/* 'pxe boot' returns 0 after a failed label_boot() (handle_pxe_menu is void, */ \
	/* pxe_process() discards the nonzero), so an exit-code-gated fallback would */ \
	/* silently never fire now that netboot is PXE-first. */ \
	"bootcmd=@BOOTCMD_SEL@\0"
