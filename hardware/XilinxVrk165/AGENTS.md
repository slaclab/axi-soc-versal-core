# AGENTS.md: XilinxVrk165 board files

Instructions for a maintainer or a coding agent working in `hardware/XilinxVrk165`.

## Why `board_repo/` exists

Vivado 2026.1 installs only the ES1 `vrk165_es` board files (installed as `vrk165/es/1.0`). Their ES1 part is missing
from the 2026.1 device library, so `get_board_parts` returns nothing for them and `set_property board_part` fails with
`[Board 49-71]`.

The production `vrk165` 1.0 files from the AMD XilinxBoardStore repository are therefore vendored, unmodified and with
their `LICENSE`, in `board_repo/boards/Xilinx/vrk165/prod/1.0`. `ruckus.tcl` registers `board_repo/` through the
`board_part_repo_paths` project property and the `board.repoPaths` param before it sets the board part.

## When to migrate

Migrate once Vivado 2026.2 is installed at SLAC with its official board files under:

`/sdf/group/faders/tools/xilinx/2026.2/Vivado/data/xhub/boards/XilinxBoardStore/boards/Xilinx/`

Do not migrate before that install exists. Do not run recursive searches of network mounts to find it.

## Migration steps

1. Confirm the official production board is installed. Run `ls` on the path above and on its `vrk165` entries, and check
   the real layout (for example `vrk165/prod/1.0` versus another directory scheme). Then start a Vivado 2026.2 batch
   session with no extra board repo path and confirm that `get_board_parts` lists `xilinx.com:vrk165:part0:1.0`.
2. Run `diff -r` of the installed production files against `board_repo/boards/Xilinx/vrk165/prod/1.0` and record every
   difference. Treat a newer file version such as 1.1 as an explicit decision, not an automatic switch.
3. Delete `board_repo/` and the `board_part_repo_paths` / `board.repoPaths` registration block from `ruckus.tcl`. Keep
   the exact `PRJ_PART` check, the ES1 part abort, the ES board-name abort and the read-back of `board_part` after
   `set_property board_part`. Point the board repo argument of `scripts/gen_vrk_bd_seed.tcl` at the installed board
   store.
4. Move `VersionCheck` and `bdVer` in `ruckus.tcl` to 2026.2. Create `bd/2026.2/` by opening the block design in Vivado
   2026.2, upgrading the IP and regenerating `AxiSocVersalCpuCore.tcl`, the `.bd` and `XilinxVrk165NoC.ncr`
   (re-checked with `pr_verify` against the golden routed DCP).
5. Rebuild the `SimpleVrk165Example` target. Re-run the ES1 part, wrong part and ES board negative tests with a
   stubbed-loader harness that evaluates `ruckus.tcl` in a scratch project outside the repository.
6. Bump the `axi-soc-versal-core` submodule pin in Simple-VRK165-Example.

## Vivado 2026.2 migration risks

None of these is confirmed for 2026.2. Check each one during the migration.

1. Board file version drift. The 2026.2 install may ship a newer file version (for example `prod/1.1`), a different
   directory layout or a changed board part string. The example design selects board files with
   `-latest_file_version`, so a newer version would be picked up silently. Diff it against `board_repo/` and adopt it
   only as an explicit decision.
2. Example design version. `scripts/gen_vrk_bd_seed.tcl` pins `xilinx.com:design:versal_comn_platform:2.0`. If 2026.2
   drops or changes that example design, the generator may fail or produce different DDRMC5 settings. After a rerun,
   confirm that every controller still reports LPDDR5X-7500 and that each `CHECK` line (tCK and refclk) matches the
   2026.1 generator output.
3. IP upgrade of the block design. Upgrading `ps_wizard`, the NoC, the DDRMC5 controllers and `ai_engine` can rename
   parameters or pins (the PL-to-PS coherent slave interface names on `ps_wizard` are the least certain) and can
   re-solve the NoC, which invalidates `XilinxVrk165NoC.ncr`. Diff the regenerated `AxiSocVersalCpuCore.tcl` against
   `bd/2026.1/` before accepting it, and harvest a new `.ncr` from a 2026.2 routed build.
4. Segmented configuration across tool versions. Do not load a dynamic PDI built with 2026.2 on a board that booted a
   2026.1 boot PDI. After migrating, rebuild and redeploy the full boot image, not only `pl.pdi`.
5. Submodule and platform support. The `ruckus` submodule pin in Simple-VRK165-Example may need an update for 2026.2.
   Vivado 2026.1 has no VRK165 Vitis base platform, so the AIE build targets the AIE part only. Check whether 2026.2
   adds a VRK165 base platform, and switch to it only as an explicit decision.
6. Yocto route. Confirm that XSCT still reads the 2026.2 XSA, and check whether the meta-xilinx layer versions used by
   the shared Yocto flow changed. Vivado 2026.1 ships no VRK165 board device tree; check whether 2026.2 adds one.
7. Part strings. Confirm that `get_parts xcvr1652-vsva2488-2MP-e-S` still returns the production part in the 2026.2
   device library, so the exact `PRJ_PART` compare and the ES1 aborts in `ruckus.tcl` stay correct.
8. Hardware baseline. The 2026.1 build was accepted as build-only. If boards are available before the migration, record
   a known-good 2026.1 hardware result first (boot, LPDDR5 calibration, DMA and AIE PRBS loopback) so a 2026.2
   regression can be told apart from a bring-up issue.

## VRK165 risks to know about now

- Its preset contents, AIE geometry and PL column rules are unverified.
- There is no VRK165 base platform XSA to cross-check against, so its seed relies more heavily on the example project being correct.

The production part `xcvr1652-vsva2488-2MP-e-S` and board part `xilinx.com:vrk165:part0:1.0` remain the only accepted
values.
