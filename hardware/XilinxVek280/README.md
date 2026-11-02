# XilinxVek280

Hardware support for the AMD VEK280 evaluation board (Versal AI Edge, part `xcve2802-vsvh1760-2MP-e-S`, board part
`xilinx.com:vek280:part0:1.2`). `ruckus.tcl` accepts only that part and loads the block design, constraints, RTL and
optional NoC lock in this directory.

## Board files

The board files come from the Vivado install; nothing is vendored in this directory. `ruckus.tcl` sets board part
`xilinx.com:vek280:part0:1.2` directly (the Vivado 2026.1 install provides `vek280` 1.0, 1.1 and 1.2).

## Block design

`bd/2025.1/AxiSocVersalCpuCore.bd` is the block design loaded by `ruckus.tcl`. `bd/2025.1/AxiSocVersalCpuCore.tcl`
is its `write_bd_tcl` export (`scripts_vivado_version 2025.1`) and is kept as the readable reference. `ruckus.tcl`
loads `bd/2025.1` for any Vivado version at or above 2025.1.

- Cells: `CIPS_0` (`versal_cips` 3.4), `ai_engine_0`, `Master_NoC`, `ConfigNoc`, `aggr_noc` and `noc_lpddr0` to
  `noc_lpddr2`.
- `rtl/AxiSocVersalCpu.vhd` wraps the block design. `rtl/HardwareTypePkg.vhd` sets `HW_TYPE_C` to
  `HW_TYPE_XILINX_VEK280_C` (`x"00_00_00_01"`).

## LPDDR4

The three memory NoCs take their memory and clock settings from the board interfaces of the board file preset:

| Cell | Memory interfaces | System clock | Region |
|------|-------------------|--------------|--------|
| `noc_lpddr0` | `ch0_lpddr4_trip1`, `ch1_lpddr4_trip1` | `lpddr4_clk1` | `DDR_LOW0`, `DDR_LOW1`, channel interleaved at 4 KB |
| `noc_lpddr1` | `ch0_lpddr4_trip2`, `ch1_lpddr4_trip2` | `lpddr4_clk2` | `DDR_CH1` |
| `noc_lpddr2` | `ch0_lpddr4_trip3`, `ch1_lpddr4_trip3` | `lpddr4_clk3` | `DDR_CH2` |

## Address map

Segments of the `CIPS_0/FPD_AXI_NOC_0` address space in `bd/2025.1/AxiSocVersalCpuCore.tcl` (the other FPD NoC
address spaces map the same ranges):

| Segment | Offset | Range |
|---------|--------|-------|
| `noc_lpddr0/S00_INI/C0_DDR_LOW0` | `0x0` | 2 GiB |
| `noc_lpddr0/S00_INI/C0_DDR_LOW1` | `0x8_0000_0000` | 2 GiB |
| `noc_lpddr1/S00_INI/C1_DDR_CH1` | `0x500_0000_0000` | 4 GiB |
| `noc_lpddr2/S00_INI/C1_DDR_CH2` | `0x600_0000_0000` | 4 GiB |
| `ai_engine_0/S00_AXI/AIE_ARRAY_0` | `0x200_0000_0000` | 4 GiB |

The three memory NoCs expose 12 GiB of DDR in total.

## NoC solution lock

With `USE_SEGMENTED_CONFIG` set, `ruckus.tcl` loads `bd/2025.1/XilinxVek280NoC.ncr` through `loadNoCSolution` so the
static NoC stays identical between the boot PDI and the dynamic PDI. The `.ncr` is keyed by hierarchical instance
name and assumes the application instantiates `AxiSocVersalCore` as `U_Core`. A changed block design requires
regenerating the `.ncr` from the implementation run directory and re-checking with `pr_verify` against the golden
routed DCP. See the top-level `README.md` for the full flow.

## Constraints

- `xdc/XilinxVek280.xdc`: clock groups for the PLL outputs inside `U_Core`.
- `xdc/XilinxVek280AiePl.xdc`: pins the 16 master and 16 slave 128-bit AIE-PL stream channels of `ai_engine_0` to
  fixed shim sites, so separately compiled AIE graphs can place their PLIOs with `adf::shim(column, channel)`. The
  header of the file documents the column and channel mapping and how to regenerate it.

## Yocto

`Yocto/` holds the board layer used by the shared Yocto flow: `versal-user.conf`, device-tree `bbappend` with
`system-user.dtsi` and `pl-user.dtsi`, and a U-Boot patch that clears the Ethernet PHY power-down bit before network
boot autonegotiation.
