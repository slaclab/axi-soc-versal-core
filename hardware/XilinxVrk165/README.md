# XilinxVrk165

Hardware support for the AMD VRK165 evaluation board (Versal RF, part `xcvr1652-vsva2488-2MP-e-S`, board part
`xilinx.com:vrk165:part0:1.0`). `ruckus.tcl` accepts production silicon only, aborts on ES1 parts and needs Vivado 2026.1.1 or
later.

## Board files

The board files come from the Vivado install; nothing is stored in this directory. `ruckus.tcl` sets board part
`xilinx.com:vrk165:part0:1.0` directly. Vivado 2026.1.1 installs the production `vrk165` 1.0 files
(`data/xhub/boards/XilinxBoardStore/boards/Xilinx/vrk165/prod/1.0` of the install). Vivado 2026.1 installs
only the ES1 board files (`vrk165/es/1.0`, board `vrk165_es`), whose ES1 parts are missing from the 2026.1 device
library, which is why `ruckus.tcl` asks for Vivado 2026.1.1 or later.

## Block design seed

The seed of `bd/2026.1/AxiSocVersalCpuCore.tcl` is produced by `scripts/gen_vrk_bd_seed.tcl` from the AMD Versal
Embedded Common Platform 2.0 example design (`versal_comn_platform`, `vrk_base_board.tcl`) in Vivado 2026.1.1. To
regenerate it, use Vivado 2026.1.1 or later and run from a scratch directory outside the repository:

```
vivado -mode batch -notrace -nojournal -source <core root>/scripts/gen_vrk_bd_seed.tcl \
   -tclargs xilinx.com:vrk165:part0:1.0 <outDir>
```

`<outDir>/AxiSocVersalCpuCore.tcl` is then byte-identical to the seed as first committed. It is the input of
`scripts/gen_vrk_bd.tcl`, which grows it into the SLAC block design (see below); the committed
`bd/2026.1/AxiSocVersalCpuCore.tcl` is that result and no longer the seed itself.

- Kept: `ps_wizard_0`, `Master_NoC`, `NoC_C0` to `NoC_C3`, `aggr_noc`, `ConfigNoc`, `ai_engine_0`, `util_ds_buf_0`,
  `clk_wizard_0` and `rst_clk`.
- Removed: the GPIO, UART, SmartConnect and BRAM content of the example and its platform (PFM) declarations.
- `clk_wizard_0` and `rst_clk` are kept so that `ps_wizard_0/fpd_axi_pl_aclk` stays driven and the design validates.
  The SLAC block design replaces them with `plClk` and `plRstL`.

## LPDDR5

The example design hardcodes `LPDDR5X-8533` with `DDRMC5_F0_TCK` 938 (C0, C1) and 952 (C2, C3), which are ES1-era
values. With the production board loaded, the board preset yields `LPDDR5X-7500` with tCK 1087 (C0, C1) and 1081
(C2, C3). The generator asserts this on every controller and aborts otherwise, instead of re-applying the preset.

- The wrapper-level `DDRMC5_F0_RL` 25 and `DDRMC5_F0_WL` 12 are left over from the 8533 values. The inner memory
  controller IP ignores them (inner values 22 and 11, `IP_Flow 19-3374` warning expected). They are left as generated.
- The reference clock of C0 and C1 is plain at 3125 ps. C2 and C3 use `Lpddr5_Controller_C2_Bank_706_707_int` and
  `Lpddr5_Controller_C3_Bank_709_710_int` at 5000 ps, following the example design.

## Address map

Round trip of the committed seed in Vivado 2026.1.1 (`validate_bd_design` returns 0), segments of the Cortex-A72 address
space:

| Segment | Offset | Range |
|---------|--------|-------|
| `SEG_NoC_C0_DDR_CH0_LEGACY` | `0x0` | 2 GiB |
| `SEG_NoC_C0_DDR_CH0_MED` | `0x8_0000_0000` | 2 GiB |
| `SEG_NoC_C1_DDR_CH1` | `0x500_0000_0000` | 4 GiB |
| `SEG_NoC_C2_DDR_CH2` | `0x600_0000_0000` | 4 GiB |
| `SEG_NoC_C3_DDR_CH3` | `0x700_0000_0000` | 4 GiB |
| `SEG_ai_engine_0_AIE_ARRAY_0` | `0x200_0000_0000` | 4 GiB |

The four controllers expose five DDR segments (C0 is split in two) for 16 GiB in total.

## Comparison with XilinxVrk160

No Vitis base platform is available for this board, so the seed is cross-checked against the installed production
`vrk165` board files and against the XilinxVrk160 seed and block design, all generated on Vivado 2026.1.1.

- Board files: `preset.xml` of `vrk165` 1.0 is byte-identical to the one of `vrk160` 1.0 (0 differing lines), which
  covers the memory part, the speed grade, tCK and the reference clock periods of all four controllers.
  `part0_pins.xml` differs in 2 lines, the `part_info` line that names the part (`xcvr1652-vsva2488-2MP-e-S` instead of
  `xcvr1602-vsva2488-2MP-e-S`).
- Seed: the XilinxVrk160 seed as first committed differs in 4 lines, the `create_project -part` and `BOARD_PART` lines.
  With the part and board part strings substituted the difference is 0 lines.
- Block design: the SLAC block design `.tcl` and the `.bd` of both boards differ in 0 lines after the same
  substitution, and the builder evidence (cells, LPDDR5 renames, PS overrides, NoC reach, address segments, PL0
  frequency, interrupt pins) differs in 0 lines.
- Topology: the topology fingerprint (IP cells with their VLNV, six LPDDR5 master interface ports, differential clock
  ports) is identical.

The seed, the SLAC block design and the builder evidence are identical to the XilinxVrk160 ones
apart from the part and board part lines, so the memory banks, the reference clock interfaces, the DDR regions and the PS
peripheral and MIO settings are the same.

## SLAC block design

`bd/2026.1/AxiSocVersalCpuCore.tcl` and `bd/2026.1/AxiSocVersalCpuCore.bd` are generated by `scripts/gen_vrk_bd.tcl`
from the seed. Do not edit them by hand; change the script and regenerate. Two independent runs (seed generator
followed by the builder) on Vivado 2026.1.1 reproduce both files byte for byte. `ruckus.tcl` loads the `.bd`; the `.tcl`
line stays commented. To regenerate, use Vivado 2026.1.1 or later and run from a scratch directory outside the
repository:

```
vivado -mode batch -notrace -nojournal -source <core root>/scripts/gen_vrk_bd_seed.tcl \
   -tclargs xilinx.com:vrk165:part0:1.0 <seedDir>
vivado -mode batch -notrace -nojournal -source <core root>/scripts/gen_vrk_bd.tcl \
   -tclargs xilinx.com:vrk165:part0:1.0 <seedDir>/AxiSocVersalCpuCore.tcl <outDir>
```

Then copy `<outDir>/AxiSocVersalCpuCore.tcl` and `<outDir>/AxiSocVersalCpuCore.bd` into `bd/2026.1/`. The builder also
writes `<outDir>/AxiSocVersalCpuCore_wrapper.vhd`, the block design wrapper that the CPU wrapper port map is generated
from. It validates the design, reads every `PS_PMC_CONFIG` override back (Vivado drops unknown keys without an error),
asserts that the DMA reaches all four DDR controllers and aborts on a missing key, an unmatched LPDDR5 port, a failed
assertion or a failed validation. A passing run prints `DDRCHECK OK board=xilinx.com:vrk165:part0:1.0 segs=5 nocpins=4`
and `LEAKSCAN OK files=2`.

The external port list is the common platform contract of the other Versal designs: `dma`, `dmaCtrl`, `axiLite`,
`dmaIrq`, `dmaClk`, `plClk`, `plRstL`, `aieClk` and 16 + 16 AXI4-Stream ports `S00_AXIS_0` to `S15_AXIS_0` and
`M00_AXIS_0` to `M15_AXIS_0` with 128-bit data. The 282 non-memory ports of the generated component match that
contract by name, direction and type.

### Seed overrides

| Key or object | Seed | SLAC block design | Reason |
|---------------|------|-------------------|--------|
| `PMC_CRP_PL0_REF_CTRL_FREQMHZ` | `100` | `250` | `pl0_ref_clk` runs at 249997498 Hz, so the `U_Pll` generics keep a 4.0 ns input clock |
| `PS_IRQ_USAGE` | `CH0` to `CH7` set to 1 | `CH0` only | one `pl_ps_irq0` pin, driven by `dmaIrq` |
| `PS_USE_PL_AXI_FPD0` | absent | `1` | adds the `PL_AXI_FPD0` slave for `dma` |
| `PS_USE_LPD_AXI_PL` | absent | `1` | adds the `LPD_AXI_PL` master for `dmaCtrl` |
| `PS_FPD_AXI_PL_DATA_WIDTH` | absent (128) | `32` | 32-bit `axiLite` |
| `PS_LPD_AXI_PL_DATA_WIDTH` | absent (128) | `32` | 32-bit `dmaCtrl` |
| `clk_wizard_0`, `rst_clk` | present | removed | `plClk` and `plRstL` are driven from `pl0_ref_clk` and `pl0_resetn` |

No other `PS_PMC_CONFIG` key differs from the seed. In particular the board preset settings of the Ethernet, USB, SD,
OSPI, I2C, UART, TTC, GPIO and MIO blocks are untouched. The AIE array is set to one clock (`aclk0`), 16 slave and 16
master PL streams, 16 byte `TDATA` on the master side, with `ASSOCIATED_BUSIF` listing all 32 interfaces.

### LPDDR5 port names

The interface ports are renamed by controller and channel with `set_property NAME`, which keeps the NoC board interface
association.

| Seed | SLAC block design |
|------|-------------------|
| `Lpddr5_Controller_C0_CH0_Bank_700_701_702` | `ch0_lpddr5_c0` |
| `Lpddr5_Controller_C0_CH1_Bank_700_701_702` | `ch1_lpddr5_c0` |
| `Lpddr5_Controller_C1_CH0_Bank_703_704_705` | `ch0_lpddr5_c1` |
| `Lpddr5_Controller_C1_CH1_Bank_703_704_705` | `ch1_lpddr5_c1` |
| `Lpddr5_Controller_C2_Bank_706_707_int` | `lpddr5_c2` |
| `Lpddr5_Controller_C3_Bank_709_710_int` | `lpddr5_c3` |
| `lpddr5_clk0_1` | `lpddr5_clk0` |

The generated board constraints of `NoC_C0` to `NoC_C3` and `util_ds_buf_0` are byte-identical before and after the
rename, so the pin placement is unchanged.

### PS slave choice

`dma` connects to `ps_wizard_0/PL_AXI_FPD0` (AXI4, 128-bit data, 49-bit address, 6-bit ID, attached to the FPD). It is
the equivalent of the CIPS `S_AXI_FPD` slave of earlier Versal designs. `axiLite` connects to `FPD_AXI_PL` and
`dmaCtrl` to `LPD_AXI_PL`. `dmaIrq` drives `pl_ps_irq0`, the only interrupt channel in use (`CH0`). The other
`PL_AXI_*` slave candidates (`PL_ACE_FPD`, `PL_ACP_FPD`, `PL_AXI_LPD`) are not used: the DMA must be neither a coherent
ACE master nor an ACP master, and `PL_AXI_LPD` is attached to the LPD instead of the FPD. That `PL_AXI_FPD0` behaves
like `S_AXI_FPD` with respect to coherency is an assumption until bring-up.

### PS address map and DDR reach

In the Cortex-A72 address space `axiLite` sits at `0x4_0000_0000` (4 GiB) and `dmaCtrl` at `0x8000_0000` (64 KiB). Both
are excluded from the Cortex-R5 space, which is 32 bit and rejects the 4 GiB range.

The `dma` address space lists PS peripheral segments only and no DDR segment. The PL DMA reaches DDR through the PS:
`PL_AXI_FPD0` enters the FPD, and the four `ps_wizard_0` `FPD_CCI_NOC0` to `FPD_CCI_NOC3` ports drive
`Master_NoC/S00_AXI` to `S03_AXI`. Each of them connects to `M04_INI`, `M05_INI`, `M06_INI` and `M07_INI` and to one
of `M00_INI` to `M03_INI`, so all four controllers are reachable, including `SEG_NoC_C3_DDR_CH3` at
`0x700_0000_0000`. `scripts/gen_vrk_bd.tcl` asserts the five Cortex-A72 DDR segments and these four connections, and
prints `DDRCHECK OK` only when they hold. The Cortex-A72 space keeps all five DDR segments listed in the address map
above.

## CPU wrapper port map

`rtl/AxiSocVersalCpu.vhd` and `rtl/HardwareTypePkg.vhd` keep their hand-written code outside the generated regions. The
regions sit between `-- BEGIN GENERATED BY scripts/gen_vrk_psmem.py: <region>` and the matching `-- END` marker line and
are rewritten from the block design wrapper by:

```
python3 scripts/gen_vrk_psmem.py --wrapper <outDir>/AxiSocVersalCpuCore_wrapper.vhd --hw-dir hardware/XilinxVrk165
```

Do not edit a generated region by hand. `--check` writes nothing and exits 1 when a region is out of date, so it proves
that the committed regions match the block design. The generator refuses a wrapper without the `AxiSocVersalCpuCore`
component, with a duplicated port, with no memory port, with an empty direction set (its vector cannot be empty) or with
an ascending memory port range, and then writes no file.

| Region | File | Content |
|--------|------|---------|
| `component` | `rtl/AxiSocVersalCpu.vhd` | the `AxiSocVersalCpuCore` component, ports in wrapper order |
| `psMem port map` | `rtl/AxiSocVersalCpu.vhd` | one line per memory port, sorted by port name, each mapped to its slice of a memory vector |
| `psMem types` | `rtl/HardwareTypePkg.vhd` | `psMemOutType`, `psMemInOutType` and `psMemInType`, flat `slv` subtypes sized to hold the memory ports |

A port is a memory port when its name matches `^(ch[0-9]+_)?lpddr5_` (`--mem-regex`). The wrapper has 348 ports, 66 of
them memory ports: 40 out (98 bits in `psMemOutType`), 14 in (34 bits in `psMemInType`) and 12 inout (144 bits in
`psMemInOutType`). The other 282 ports are the common platform contract and reach the VHDL unchanged. `HW_TYPE_C` is
`HW_TYPE_XILINX_VRK165_C` (`0x3`).

The memory types are flat vectors and not VHDL records on purpose. Vivado names the top-level ports of a record
`psMemOut[<field>][<bit>]`, and with ports named that way the LPDDR5 controller check in `opt_design` (Mig 66-441)
rejects the WCK pins of the first channel of the first controller, which sit on the legal octad. The same design with
vector ports `psMemOut[<bit>]` passes the check with identical pins, directions and I/O standards. Bits are assigned in
the port order of the component, so a change of the block design port list moves the bits; regenerate the regions with
the command above.

`xdc/XilinxVrk165.xdc` holds the board timing constraints, today the asynchronous clock groups between the two `U_Pll`
outputs. Later timing fixes go there.

## NoC lock and AIE-PL placement

`bd/2026.1/XilinxVrk165NoC.ncr` is the full-design NoC solution: the file the implementation run writes after placement
of a build without the lock. Its instances are keyed by the `U_Core` instance label of the application top level
(`U_Core/REAL_CPU.U_CPU/U_CPU/...`), plus the NoC that the tool adds for the debug hub. It is stored through Git LFS.
It is harvested with:

```
vivado -mode batch -notrace -nojournal -source <core root>/scripts/gen_vrk_noc_ncr.tcl \
   -tclargs <impl run dir> <top> hardware/XilinxVrk165/bd/2026.1/XilinxVrk165NoC.ncr
```

The script prints `NCR SOURCE impl` when it copies `<top>.ncr` of the run directory (the expected case) and `NCR SOURCE dcp`
when it falls back to `write_noc_solution` on the routed checkpoint. It writes a temporary file next to the target and
replaces the target only after validation, so a failed run never touches an existing solution. It refuses a solution whose
instances are not under `U_Core`, which is how the block design level solution in the project `nsln` directory looks, and
that file must never be used as the lock.

`ruckus.tcl` loads the solution with `loadNoCSolution` whenever Segmented Configuration is on. There is no bypass: a
missing file stops the build in `loadNoCSolution` before synthesis starts.

`xdc/XilinxVrk165AiePl.xdc` pins the 16 + 16 AIE-PL boundary channels of `ai_engine_0` to the sites that the free
placement chose (nothing steered it). It is harvested from a routed checkpoint of the same build with:

```
vivado -mode batch -notrace -nojournal -source <core root>/scripts/gen_vrk_aiepl_xdc.tcl \
   -tclargs <routed dcp> hardware/XilinxVrk165/xdc/XilinxVrk165AiePl.xdc XilinxVrk165
```

Facts of the committed placement:

- Sites are `AIE_PL_X<n>Y0` for `n` from 10 to 15, BELs are `AIE_PL_M_AXIS_<k>` (master, `ai_pl_ch_*`, `M*_AXIS_0`) and
  `AIE_PL_S_AXIS_<k>` (slave, `pl_ai_ch_*`, `S*_AXIS_0`).
- Each 128-bit channel is a macro of two 64-bit member cells on consecutive BELs. Only the first member (even BEL index)
  is constrained (the anchor member), because Vivado rejects a BEL on the second member and the macro carries it along.
- `S00_AXIS_0` (`pl_ai_ch_0`) sits on LOC `AIE_PL_X10Y0`, BEL `AIE_PL_S_AXIS_0`.
- `M00_AXIS_0` (`ai_pl_ch_0`) sits on LOC `AIE_PL_X10Y0`, BEL `AIE_PL_M_AXIS_0`.
- Each used site shares its interface tile with one shim switch: `AIE_PL_X10Y0` is in tile `AIE_INTF_B2_CORE_X11Y0` with
  `AIE_SHIMSWITCH_X11Y0`, `AIE_PL_X11Y0` in `AIE_INTF_B3_CORE_X12Y0` with `AIE_SHIMSWITCH_X12Y0`, `AIE_PL_X12Y0` in
  `AIE_INTF_B0_CORE_X13Y0` with `AIE_SHIMSWITCH_X13Y0`, `AIE_PL_X13Y0` in `AIE_INTF_B1_CORE_X14Y0` with
  `AIE_SHIMSWITCH_X14Y0`, `AIE_PL_X14Y0` in `AIE_INTF_B2_CORE_X15Y0` with `AIE_SHIMSWITCH_X15Y0` and `AIE_PL_X15Y0` in
  `AIE_INTF_B3_CORE_X16Y0` with `AIE_SHIMSWITCH_X16Y0`.
- Column rule, derived from the routed checkpoint of this board: for all six used sites the shim switch X index equals
  the AIE_PL site X index plus 1. `S00_AXIS_0` is therefore on shim column 11, and aiecompiler confirms it: with the
  `adf::shim(11, 0)` constraints of the AieLoopback graph built for `xcvr1652-vsva2488-2MP-e-S`, its shim solution places
  `AIE_PL_X10Y0_AIE_PL_S_AXIS_0` and `AIE_PL_X10Y0_AIE_PL_M_AXIS_0` on column 11, channel 0.
- The `adf::shim` column and channel of the PLIOs of an AIE graph compiled against the platform must match this
  placement.

Harvested independently from this board's own bootstrap build, the placement has the same sites and BELs as the XilinxVrk160 placement. The NoC solution of the two boards also compares equal as JSON.

A locked build is checked against the routed checkpoint of the bootstrap build with:

```
vivado -mode batch -notrace -nojournal -source <core root>/scripts/vrk_pr_verify.tcl \
   -tclargs <golden routed dcp> <new routed dcp> <report>
```

The wrapper always runs `pr_verify -segcfg_only -full_check`. The default `pr_verify` mode skips the Segmented
Configuration partition, which is the one that holds the NoC and PS configuration, so a pass without `-segcfg_only` would
prove nothing about the lock. The wrapper prints `PRV PASS` only when the report content shows a compatible result, and
`PRV FAIL` with the reason otherwise. It judges these strings:

| String | Meaning |
|--------|---------|
| `INFO: [Vivado 12-3253] PR_VERIFY: check points <initial> and <additional> are compatible` | Pass line, exactly one is required |
| `[Dfx 88-264]` initial boot paths compared | Boot path count, must be above zero so that a pass is never vacuous |
| `INFO: [Vivado 12-3515] PR_VERIFY: check points <initial> and <additional> are not compatible` | Fail line, any occurrence fails |
| `ERROR: [Common 17-39] 'pr_verify' failed due to earlier errors.` | Tcl error of a failed comparison |
| `[Dfx 88-133]`, `[Dfx 88-134]`, `[Dfx 88-136]`, `[Dfx 88-145]`, `[Dfx 88-146]`, `[Dfx 88-162]` | Error ID families reported for an incompatible pair |

Any line that starts with `ERROR:` or `CRITICAL WARNING:` also fails the check.

### Freeze rule

Both files are valid only for the exact block design they were harvested from. Any change to `bd/2026.1` (or to the
`U_Core` instance label) invalidates both locks and requires the re-bootstrap below. After a re-bootstrap the locked
build is checked with `pr_verify` against the routed checkpoint of the bootstrap build.

### Manual re-bootstrap

This procedure is done by hand in a working copy and the temporary edit is never committed.

1. Comment out the `loadNoCSolution` line in `ruckus.tcl`.
2. Remove `bd/2026.1/XilinxVrk165NoC.ncr` and `xdc/XilinxVrk165AiePl.xdc`.
3. Run the full build in a clean build directory. It places and routes without either lock.
4. Harvest both files from that build with the two scripts above (`<impl run dir>` is the `impl_1` run directory).
5. Restore the `loadNoCSolution` line.
6. Rebuild with the locks and check the result with `pr_verify` against the bootstrap routed checkpoint.

## Yocto BSP

`Yocto/` is the board support used by the shared `BuildYoctoProject.sh`. The script appends `Yocto/versal-user.conf` to
the machine configuration and links `Yocto/recipes-bsp` into the project layer.

- Machine: `versal-user.conf` requires the versal-generic machine and appends `aie` to `MACHINE_FEATURES`. The design uses
  no video codec unit and no RF data converters, so no other machine feature is set. The script detects the feature by a
  plain substring match, so the `" aie"` spelling must stay as written.
- Device tree flag: there is none. device-tree-xlnx rel-v2026.1 has no VRK165 board file, so the generated device tree
  comes from the XSA (`ps_wizard`) alone, plus `system-user.dtsi` and the PL overlay `pl-user.dtsi`.
- U-Boot: there is no `UBOOT_DT_FILES` entry, because u-boot-xlnx rel-v2026.1 ships no VRK165 system controller overlay.
  The variable acts only together with `UBOOT_DTFILES_BUNDLE`, which this flow does not set. No U-Boot patch is carried.
- Ethernet: `gem0` uses a TI DP83867 PHY (`ethernet-phy-id2000.a231`) at MDIO address 1, RX delay 3.00 ns (`0xb`), TX
  delay 2.75 ns (`0xa`), reset on `gpio0` 12 (active low). The values come from `versal-vrk165-revA.dts` of u-boot-xlnx,
  which includes `versal-vrk160-revA.dts` and changes only the model and compatible strings. The board files name no PHY,
  so the PHY is to be confirmed at bring-up. The delays are written as numbers because the dt-bindings header may not be
  on the include path of the device-tree generator.
- Memory: `system-user.dtsi` carries the same `reserved-memory` node as XilinxVek280 (`cma_reserved`, 1.5 GiB at
  `0x8000_0000`), although the DDR map has no RAM at `0x8000_0000`, the PL AXI window of `axi_stream_dma_0`. The kernel
  command line sets `cma=1536M`, the same as XilinxVek280. The DMA driver allocates
  128 RX plus 128 TX buffers of 512 KiB (128 MiB) with the wrapper defaults. The size is to be confirmed at bring-up.
- MAC address: the board EEPROM (u21, M24128 at `0x54`) sits on `i2c1` behind the PCA9541 arbitrator at `0x72` that it
  shares with the system controller, as in `versal-vrk160-revA.dts` of u-boot-xlnx. It holds an IPMI FRU image whose
  multirecord area carries two Xilinx `0xD2` MAC records: version `0x11` for the system controller and version `0x31` for
  the Versal device. device-tree-xlnx has no VRK160 board file (XilinxVek280 gets the EEPROM node and the `nvmem0` alias
  from `YAML_DT_BOARD_FLAGS`), so `system-user.dtsi` adds the EEPROM node, the `nvmem0` alias and `xlnx,eeprom` in
  `chosen`. U-Boot decodes the FRU through `nvmem0`, sets `ethaddr` from the Versal record and passes it to Linux in the
  device tree. `gem0` also reads the MAC through an nvmem cell at offset `0xA8`, the same as XilinxVek280. The record
  offset depends on the FRU field lengths, so it is to be confirmed at bring-up; a wrong offset only makes U-Boot warn
  that the device-tree and environment MAC addresses differ, and the FRU MAC is kept. The shared `netboot` script polls `i2c md 0x54 0xa8 6`
  on I2C bus 1 directly, outside the arbitrator, which is not confirmed for this board. Until bring-up confirms it,
  `sd-only` (the default `-m` mode) is the supported boot mode; `fallback` and `tftp-only` are untested.
- SD card: `sdhci1` is enabled with `no-1-8-v`, as in the AMD board device tree, and with `disable-wp`, as in
  XilinxVek280, so the write-protect line is ignored.
- DMA interrupt: `axi_stream_dma_0@80000000` uses `pl_ps_irq0`, GIC SPI 84 (`interrupts = <0 84 4>`), the PS interrupt
  contract of the block design.
- Outputs: `pl.pdi` (the `<image>_dynamic.pdi` beside the XSA), `BOOT.BIN` and so the `linux.tar.gz` tarball come only from
  a build that wrote the Vivado device images. The kernel, root file system, `system-top.dtb`, `pl.dtbo` and `boot.scr`
  do not depend on them.
- Difference from XilinxVrk160: the `Yocto/` directory equals `hardware/XilinxVrk160/Yocto` apart from the missing
  `UBOOT_DT_FILES` block in `versal-user.conf` and the dts name in the `system-user.dtsi` comment.
