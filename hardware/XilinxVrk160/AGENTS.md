# AGENTS.md: XilinxVrk160 board files

Instructions for a maintainer or a coding agent working in `hardware/XilinxVrk160`.

## Why `board_repo/` exists

Vivado 2026.1 installs only the ES1 `vrk160` 1.x board files (for example `vrk160/1.2`). Their ES1 parts are missing
from the 2026.1 device library, so `get_board_parts` returns nothing for them and `set_property board_part` fails with
`[Board 49-71]`.

The production `vrk160_p` 1.0 files from the AMD XilinxBoardStore repository are therefore vendored, unmodified and with
their `LICENSE`, in `board_repo/boards/Xilinx/vrk160/prod/1.0`. `ruckus.tcl` registers `board_repo/` through the
`board_part_repo_paths` project property and the `board.repoPaths` param before it sets the board part.

## When to migrate

Migrate once Vivado 2026.2 is installed at SLAC with its official board files under:

`/sdf/group/faders/tools/xilinx/2026.2/Vivado/data/xhub/boards/XilinxBoardStore/boards/Xilinx/`

Do not migrate before that install exists. Do not run recursive searches of network mounts to find it.

## Migration steps

1. Confirm the official production board is installed. Run `ls` on the path above and on its `vrk160` entries, and check
   the real layout (for example `vrk160/prod/1.0` versus `vrk160_p/1.0`). Then start a Vivado 2026.2 batch session with
   no extra board repo path and confirm that `get_board_parts` lists `xilinx.com:vrk160_p:part0:1.0`.
2. Run `diff -r` of the installed production files against `board_repo/boards/Xilinx/vrk160/prod/1.0` and record every
   difference. Treat a newer file version such as 1.1 as an explicit decision, not an automatic switch.
3. Delete `board_repo/` and the `board_part_repo_paths` / `board.repoPaths` registration block from `ruckus.tcl`. Keep
   the exact `PRJ_PART` check, the ES1 part abort, the ES board-name abort and the read-back of `board_part` after
   `set_property board_part`. Point the board repo argument of `scripts/gen_vrk_bd_seed.tcl` at the installed board
   store.
4. Move `VersionCheck` and `bdVer` in `ruckus.tcl` to 2026.2. Create `bd/2026.2/` by opening the block design in Vivado
   2026.2, upgrading the IP and regenerating `AxiSocVersalCpuCore.tcl`, the `.bd` and `XilinxVrk160NoC.ncr`
   (re-checked with `pr_verify` against the golden routed DCP).
5. Rebuild the `SimpleVrk160Example` target. Re-run the ES1 part, wrong part and ES board negative tests with a
   stubbed-loader harness that evaluates `ruckus.tcl` in a scratch project outside the repository.
6. Bump the `axi-soc-versal-core` submodule pin in Simple-VRK160-Example.

The production part `xcvr1602-vsva2488-2MP-e-S` and board part `xilinx.com:vrk160_p:part0:1.0` remain the only accepted
values.
