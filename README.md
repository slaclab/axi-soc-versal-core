# axi-soc-versal-core

**Documentation:** https://slaclab.github.io/axi-soc-versal-core/

[DOE Code](https://www.osti.gov/doecode/biblio/165458)

<!--- ######################################################## -->

### Versal Adaptive SoC Register Reference (AM012)

https://docs.amd.com/r/en-US/am012-versal-register-reference

<!--- ######################################################## -->

### BuildYoctoProject.sh options

`BuildYoctoProject.sh` (invoked from the target `Makefile`, or via the
`Simple-VEK280-Example` wrapper's `-i`/`-e`/`-m` passthrough) takes three
options beyond the required build paths:

- `-i IMAGE` bitbakes the named image (default `petalinux-image-minimal`).
- `-e` activates the Yocto environment and drops into a shell in the build
  dir instead of building.
- `-m MODE` bakes the U-Boot boot mode into `BOOT.BIN`: `sd-only` (default,
  no DHCP or TFTP), `fallback` (TFTP first, then SD) or `tftp-only`
  (diskless: U-Boot loads `pl.pdi`, applies `pl.dtbo` and stacks the AIE
  PDIs over TFTP, and halts instead of falling back to SD). Re-running with
  an explicit `-m` re-syncs `local.conf`; a run without `-m` keeps a hand
  edit.

See the how-tos for the TFTP boot modes and for imaging an SD card:
https://slaclab.github.io/axi-soc-versal-core/how-to/tftp_network_boot.html
https://slaclab.github.io/axi-soc-versal-core/how-to/sd_card_imaging.html

<!--- ######################################################## -->

### How to format SD card for SD boot

Use `scripts/CreateDiskImage.sh` or `scripts/FormatSdCard.sh` on the `.linux.tar.gz`, as described in the SD card imaging how-to: https://slaclab.github.io/axi-soc-versal-core/how-to/sd_card_imaging.html

<!--- ######################################################## -->

### Maintaining a consistent NoC solution

In order for the runtime switching of the PL firmware to work, one needs to use the Segmented Configuration flow. More info about it can
be found here: https://github.com/Xilinx/Vivado-Design-Tutorials/tree/2025.2/Versal/Boot_and_Config/Segmented_Configuration

This makes Vivado generate two bitstreams: a static PDI used for booting (generating BOOT.BIN), and a dynamic one with all the PL firmware. These are not
independent, as they need to have compatible memory space and NoC solutions. To help with this, Vivado outputs a `.ncr` file
containing a placed description of the NoC solution. In order to build a compatible firmware, i.e. one built with the same NoC solution,
one needs to set it during implementation with the `NOC_SOLUTION_FILE` option. This is achieved with the `loadNoCSolution` command in
ruckus.

Compatibility can be verified by comparing the placed and routed netlists with the following TCL command:
```
pr_verify -initial <golden>_routed.dcp -additional <new>_routed.dcp
```

The .ncr is keyed by full hierarchical instance names starting at the application top, e.g. `U_Core/REAL_CPU.U_CPU/U_CPU/Master_NoC/inst/S00_AXI_nmu/...`.
That means this library now silently requires every consumer to instantiate AxiSocVersalCore with the label U_Core. A different label means the solution
does not apply, the NoC is re-solved from scratch, and the resulting dynamic PDI is incompatible with the deployed BOOT.BIN.

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

### How to runtime update the PL bitstream (Versal)

The instructions above have the advantage of being persistent, i.e. the firmware
will survive a reboot. It's possible to reload the PL firmware at run-time as
follows:
```bash
scp pl.pdi  root@<board-ip>:/lib/firmware/pl.pdi
ssh root@<board-ip> "echo pl.pdi > /sys/class/fpga_manager/fpga0/firmware"
```

While this operation is being performed, no data should be sent through the DMA and
no registers should be written. Furthermore, if `pl.pdi` is not updated in `/boot/`
this operation is not persistent and will not survive a reboot.

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

### Conditional AIE rootfs inclusion

`BuildYoctoProject.sh` gates AIE userspace on a token in the board's
`hardware/<board>/Yocto/versal-user.conf`. When ` aie` appears in the
`MACHINE_FEATURES:append` value, the build prints:

```text
MACHINE_FEATURES=aie detected: Including AIE partition-init
```

and appends `aie-partition-init` to `IMAGE_INSTALL`, landing the
`aie-partition-init@.service` systemd template and the
`/usr/bin/aie-partition-init` binary in the rootfs. Boards that do not
declare the ` aie` token produce a clean image with no AIE recipe, binary,
or unit in the manifest.

The current VEK280 setting (in `hardware/XilinxVek280/Yocto/versal-user.conf`):

```
MACHINE_FEATURES:append = " vdu aie"
```

A non-AIE Versal board simply omits the ` aie` token from its own
`versal-user.conf`; no other recipe or layer change is required.

<!--- ######################################################## -->

### Runtime AIE PDI load

After the PL fabric is programmed at boot, `startup-app-init` loads one or
more AIE PDIs from `/boot/aie/`. Each image is expected as a pair:

```
/boot/aie/<name>.pdi             # CDO-only partial PDI (stacks on the PL)
/boot/aie/<name>.partition.conf  # sidecar: PARTITION_ID + UID
```

No device-tree overlay is needed: the `ai_engine` node is already live from
`pl.dtbo`, so the PDI is delivered straight to the PLM through the kernel
`request_firmware` path.

The entire loop is conditioned on `[ -d /sys/class/aie ]`: if the kernel
driver has not exposed that directory (non-AIE board or driver not loaded),
the section is skipped with a log message and execution continues normally.

Images are loaded in lexicographic order via the `for pdi in /boot/aie/*.pdi`
shell glob. User controls load order via filename prefix, e.g.
`00_loopback.pdi` before `10_extra.pdi`. This is a convention, not enforced
by the loader.

**Load-bearing invariant — no `fpgautil` in the AIE loop.** The code comment
states this explicitly. A second `fpgautil -o` collides with the `full`
overlay name created by the `pl.pdi` load above, and `fpgautil` reports that
as `Error: Overlay already exists in the live tree` — which a `grep -i
failed` retry loop never catches, silently skipping the load. And `fpgautil
-R -n full` would tear down the PL fabric; the single `-R -n full` that
clears prior overlays runs only before the `pl.pdi` load.

For each PDI in the glob:

- Copy the PDI to `/lib/firmware/<name>.pdi` and write the filename
  `<name>.pdi` — *with* the `.pdi` extension — to
  `/sys/class/fpga_manager/fpga0/firmware`. That write triggers the kernel
  `request_firmware()` path, which searches `/lib/firmware/` (and
  `/lib/firmware/updates/`) for a file whose name is the *exact string
  written*. Two things therefore matter when driving this by hand: the file
  must be staged under `/lib/firmware/` first (`/boot/aie/` is not a firmware
  search path), and the written name must include `.pdi` — writing the bare
  `<name>` gives `Direct firmware load for <name> failed with error -2`
  (`-ENOENT`) before the PDI is ever parsed. The write is synchronous:
  `fpga0/state` reflects the result when it returns — `operating` on
  success, `write error: 0x<plm-status>` on PLM rejection (e.g.
  `0x03260014` = IDCODE check failed).
- If the state is not `operating`: log `ERROR: AIE PDI load failed for
  <pdi>` and continue to the next image (not a fatal error).
- After a successful load: if `<name>.partition.conf` exists, run
  `systemctl start aie-partition-init@<name>.service`. The unit's own
  `ConditionPathExists=/boot/aie/%i.partition.conf` provides a second gate.
  If `.partition.conf` is absent: log `WARNING: <conf> missing - skipping
  aie-partition-init for <name>` — the PDI remains programmed; only
  partition-init is skipped.

The `aie-partition-init` agent holds the partition fd open (via `pause()`) for
the lifetime of the service, because the `xilinx-ai-engine` driver tears the
partition down on *last close*. So running the agent a second time by hand
while the service holds the partition fails the request ioctl with `Invalid
argument`. `systemctl stop` the service before running it manually — and note
that a stopped service is not proof the fd is released: if
`/sys/class/aie/aiepart_<col>_<numcols>/` still exists afterward, some process
(e.g. a stray manual run, which systemd does not track) still holds
`/dev/aie0`. Find and clear the holder before retrying:

```bash
fuser /dev/aie0                 # who has the device open
kill <process number>
```

<!--- ######################################################## -->

### Heterogeneous-multi-image caveats

Loading more than one AIE PDI is supported by the loop above, but carries
constraints the kernel driver does not enforce automatically.

**Overlapping column geometry is undefined.** If two PDIs claim the same AIE
column range, the second firmware-sysfs load will appear to succeed but the
resulting partition state is undefined — the `xilinx-ai-engine` driver does
not detect or refuse the conflict. First-loaded PDI wins any column conflict.

**Filename order is the only ordering control.** Because the loader uses a
shell lexicographic glob, prepend a zero-padded numeric prefix to control
sequencing: `00_design_a.pdi`, `10_design_b.pdi`, etc.

**Sidecar schema.** The `.partition.conf` file is a two-key shell-style
config:

```
PARTITION_ID=0x2600
UID=0xc8f9a8af
```

Both keys are mandatory; a missing key causes `aie-partition-init` to exit
non-zero. Values are parsed with `strtoul(..., 0)` — both `0x` hex and plain
decimal are accepted. Blank lines and `#` comments are allowed. Unknown keys
are rejected with an error.

**Sidecar provenance.** The `.partition.conf` is generated by
`emit_partition_conf.sh` during `make` in the AIE component directory (e.g.
`firmware/shared/AieLoopback/`). Values are sourced from the
`aie_partition.json` file emitted by Vitis at
`${OUT_DIR}/${PROJECT}/build/hw/Work/arch/aie_partition.json`:

- `UID` is read directly from `.AIE.ai_engine_0.partitions[0].aie_pl_intf_id`.
- `PARTITION_ID` is computed from the geometry fields:
  `(numColumns << 8) | startColumn`, where `numColumns` and `startColumn`
  are read from `.AIE.ai_engine_0.partitions[0]`. For a full-array 38-column
  design starting at column 0: `(38 << 8) | 0 = 0x2600`.

<!--- ######################################################## -->
