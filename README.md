# axi-soc-versal-core

[DOE Code](https://www.osti.gov/doecode/biblio/165458)

<!--- ######################################################## -->

### Versal Adaptive SoC Register Reference (AM012)

https://docs.amd.com/r/en-US/am012-versal-register-reference

<!--- ######################################################## -->

### How to format SD card for SD boot

https://xilinx-wiki.atlassian.net/wiki/x/EYMfAQ

1) Copy For the boot images, simply copy the files to the FAT partition.
This typically will include BOOT.BIN, image.ub, and boot.scr

```bash
sudo mkdir -p boot
sudo mount /dev/sdd1 boot
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/system.bit boot/.
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/BOOT.BIN   boot/.
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/image.ub   boot/.
sudo cp <PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/boot.scr   boot/.
sudo umount boot
sudo rm -rf boot
```

2) For the root file system, the process will depend on the format of your root file system image.

`roofts.ext4 -  This is an uncompressed ext4 file system image. To copy the contents to the root partition, you can use the following command: `

```bash
sudo dd if=<PATH_TO_BUILD_DIR>/tmp/deploy/images/versal-user/rootfs.ext4 of=/dev/<DEV_NAME>
```

<!--- ######################################################## -->

### How to remote update the PL bitstream (Versal)

On Versal targets the runtime PL artifact is a *dynamic* PDI plus a device-tree
overlay that carries the `partial-fpga-config` property. Both files live on the
boot partition under `/boot/`. To swap the PL on a running board:

```bash
scp pl.pdi  root@<board-ip>:/boot/pl.pdi
scp pl.dtbo root@<board-ip>:/boot/pl.dtbo
ssh root@<board-ip> '/bin/sync; /sbin/reboot'
```

The existing `BOOT.BIN` is *not* touched — only the runtime PDI and its overlay
need to land on the SD card. After the reboot, `startup-app-init` re-runs
`fpgautil` against the new pair, and `cat /sys/class/fpga_manager/fpga0/state`
should report `operating`.

If only one of the two files (`/boot/pl.pdi` xor `/boot/pl.dtbo`) is present,
`startup-app-init` skips the load and writes `WARNING: 2nd-stage PL load
skipped - need BOTH /boot/pl.pdi and /boot/pl.dtbo` to journalctl. Both files
must be in place for the load to proceed.

This flow closes [slaclab/axi-soc-versal-core#6](https://github.com/slaclab/axi-soc-versal-core/issues/6).

<!--- ######################################################## -->

### Why Versal differs from ZynqMP for runtime PL loading

Versal's Platform Management Controller (PMC) treats the *base* PDI (loaded by
the PLM at boot) and the *runtime* PDI (loaded later via `fpgautil`) as
distinct artifacts with distinct rules. The runtime PDI must be a different
build product than the base PDI — typically generated via Vivado's Segmented
Configuration flow, which emits a static (base) PDI for `BOOT.BIN` and a
dynamic (runtime) PDI for `/boot/pl.pdi`. See the [Solution Versal PL
Programming wiki](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/1188397412/Solution+Versal+PL+Programming)
for the authoritative description.

This is the inverse of ZynqMP's behaviour. ZynqMP's PCAP loader accepts the
same `.bit` for both first-stage and runtime PL programming because it does a
full-PL reload from scratch every time. The Versal PMC, by contrast, rejects
any attempt to load the base PDI as a runtime PDI: `xilfpga` returns `EPERM`
through the EEMI interface, and the kernel surfaces it as error code `0x1`.
The path is in [drivers/fpga/versal-fpga.c](https://github.com/Xilinx/linux-xlnx/blob/master/drivers/fpga/versal-fpga.c)
(`versal_fpga_ops_write` -> `zynqmp_pm_load_pdi` return-code branch).

In journalctl on a board that hits this rejection you will see the triplet:

```text
kernel: fpga_manager fpga0: Error while writing image data to FPGA
startup-app-init[425]: BIN FILE loading through FPGA manager failed
state: write error: 0x1
```

If you grep your own journal for any of those strings and landed here, the
fix is to ensure `/boot/pl.pdi` is a *runtime* PDI (built via Segmented
Configuration), not a copy of the same `.pdi` that `BOOT.BIN` already
contains. The `slaclab/ruckus` build-system hook for Segmented Configuration
and the resulting `make pdi-dynamic` target are tracked under
[slaclab/axi-soc-versal-core#6](https://github.com/slaclab/axi-soc-versal-core/issues/6).

Out of scope for this note (and intentionally so): full Dynamic Function
eXchange with explicit Reconfigurable Partitions, `libdfx` userspace
integration, and the AI Engine `xclbin` flow. Segmented Configuration is the
minimum sufficient mechanism for fabric-only runtime PL reload on Versal; the
others would be revisited only if Segmented Configuration proved
insufficient.

<!--- ######################################################## -->
