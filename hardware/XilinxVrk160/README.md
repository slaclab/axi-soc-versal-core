# XilinxVrk160

Hardware support for the AMD VRK160 evaluation board (Versal RF, part `xcvr1602-vsva2488-2MP-e-S`, board part
`xilinx.com:vrk160_p:part0:1.0`). `ruckus.tcl` accepts production silicon only and aborts on ES1 parts and ES1 board
files. See `AGENTS.md` for the plan to move to the board files installed with Vivado 2026.2.

## Board files

The production board files in `board_repo/boards/Xilinx/vrk160/prod/1.0` are vendored verbatim from
`github.com/Xilinx/XilinxBoardStore`, path `boards/Xilinx/vrk160/prod/1.0`.

- Branch `2026.2`, HEAD `d64f2e74cadc01209659d796aa843e9bacc824b9` when vendored.
- Last upstream commit touching the directory: `319d55153cfd12a41ddc60049825db38fddc99a5`.
- The content is identical on branch `2026.1.1` (HEAD `7bd4e1dc6c6a183986df5a33ca09b4ffe0da2cb0`).
- The Apache-2.0 `LICENSE` from AMD is kept next to the files.
- Only 1.0 is vendored. Version 1.1 is excluded because the example design board filter picks the latest file version.
- Vivado 2026.1 installs only the ES1 board files (`xilinx.com:vrk160:part0:1.2`), whose ES1 parts are missing from the
  2026.1 device library, so they cannot be used.

SHA-256 of the vendored files:

| File | SHA-256 |
|------|---------|
| `LICENSE` | `e1aa6325b5df2cd95c0b70194dafe2080c961d52901010b584c6617a0bdd3956` |
| `README.md` | `3766aa86e64cf2394dcb1b691f6aa3e8b4493d241a67ace7cbaeb196415ad233` |
| `board.xml` | `acf3b79f03429ca8998bc7e92dac0d88c32d83342410aa85cca8d0407b1714f8` |
| `changelog.txt` | `75c82c0923d6dfd0a4ba2748f8d6b4ef8cdb27987c81713d5c37a0402feb7975` |
| `part0_pins.xml` | `9918f0270636e6e12d0e9c2353719af877fa84a1707cb67a3d642f8979c6f4e9` |
| `preset.xml` | `351f3dbe1bf445fc069cd040d9ae0e205bbe9c9afa55665df321ca632665b6aa` |
| `xitem.json` | `91ac4716031fdde9f19c7d11d5c7f8221473d9e90d4bf5ed3d3c41d921af4426` |

`ruckus.tcl` appends `board_repo` to the `board_part_repo_paths` project property and mirrors it in the
`board.repoPaths` param before it sets the board part.

## Block design seed

`bd/2026.1/AxiSocVersalCpuCore.tcl` is produced by `scripts/gen_vrk_bd_seed.tcl` from the AMD Versal Embedded Common
Platform 2.0 example design (`versal_comn_platform`, `vrk_base_board.tcl`) in Vivado 2026.1. To regenerate it, run from
a scratch directory outside the repository:

```
vivado -mode batch -notrace -nojournal -source <core root>/scripts/gen_vrk_bd_seed.tcl \
   -tclargs <core root>/hardware/XilinxVrk160/board_repo xilinx.com:vrk160_p:part0:1.0 <outDir>
```

`<outDir>/AxiSocVersalCpuCore.tcl` is then byte-identical to the committed seed.

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

Round trip of the committed seed in Vivado 2026.1 (`validate_bd_design` returns 0), segments of the Cortex-A72 address
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

## Deviations from vrk160_base

The seed was compared against the ES1 `vrk160_base` platform `hw.xsa` (board `xilinx.com:vrk160:part0:1.2`). That
platform is a comparison target only and is not a source of the seed. All other `DDRMC5_CONFIG` keys (about 100 per
controller) and all other `PS_PMC_CONFIG` keys are identical. The address map and the board interfaces are identical.

DDRMC5 (per controller):

| Key | Controller | Seed | hw.xsa |
|-----|------------|------|--------|
| `DDRMC5_SPEED_GRADE` | C0 to C3 | `LPDDR5X-7500` | `LPDDR5X-8533` |
| `DDRMC5_F0_TCK` | C0, C1 | `1087` | `938` |
| `DDRMC5_F0_TCK` | C2, C3 | `1081` | `952` |
| `DDRMC5_INPUTCLK0_PERIOD` | C0, C1 | `3125` | `3127` |
| `DDRMC5_INPUTCLK0_PERIOD` | C2, C3 | `5000` | `4998` |
| `DDRMC5_BOARD_INTRF_EN` | C0 to C3 | `true` | absent |
| `DDRMC5_DDR5_TFAW_DLR` | C0 to C3 | `0` | absent |
| `DDRMC5_CRYPTO` | C0 to C3 | `false` | `None` |
| `DDRMC5_MC0_CONFIG_SEL` | C0, C1 | `config9` | absent |
| `DDRMC5_MC1_CONFIG_SEL` | C0, C1 | `config9` | absent |
| `DDRMC5_MC0_CONFIG_SEL` | C2, C3 | `config13` | absent |
| `DDRMC5_MC3_CONFIG_SEL` | C2, C3 | `config13` | absent |

`PS_PMC_CONFIG` of `ps_wizard_0`:

| Key | Seed | hw.xsa |
|-----|------|--------|
| `PMC_MIO36` | GPIO, direction in | absent |
| `PS_TTC0_CLK` | `ENABLE 1 IO PS_MIO_22 IO_TYPE MIO` | absent |
| `PS_MIO22` | pulldown, `Reserved`, direction in | pullup, `GPIO`, direction out |
| `PS_USE_LPD_AXI_PL` | absent | `1` |
| `PS_IRQ_USAGE` | `CH0` to `CH7` set to 1 | `CH0` to `CH3` and `CH8` to `CH11` set to 1 |
