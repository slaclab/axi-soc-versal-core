# XilinxVrk165

Hardware support for the AMD VRK165 evaluation board (Versal RF, part `xcvr1652-vsva2488-2MP-e-S`, board part
`xilinx.com:vrk165:part0:1.0`). `ruckus.tcl` accepts production silicon only and aborts on ES1 parts and ES1 board
files. See `AGENTS.md` for the plan to move to the board files installed with Vivado 2026.2.

## Board files

The production board files in `board_repo/boards/Xilinx/vrk165/prod/1.0` are vendored verbatim from
`github.com/Xilinx/XilinxBoardStore`, path `boards/Xilinx/vrk165/prod/1.0`.

- Branch `2026.2`, HEAD `d64f2e74cadc01209659d796aa843e9bacc824b9` when vendored.
- Last upstream commit touching the directory: `319d55153cfd12a41ddc60049825db38fddc99a5`.
- The content is identical on branch `2026.1.1` (HEAD `7bd4e1dc6c6a183986df5a33ca09b4ffe0da2cb0`).
- The Apache-2.0 `LICENSE` from AMD is kept next to the files.
- Only 1.0 is vendored. Version 1.1 is excluded because the example design board filter picks the latest file version.
- Vivado 2026.1 installs only the ES1 board files (`vrk165/es/1.0`, board `vrk165_es`), whose ES1 part is missing from
  the 2026.1 device library, so they cannot be used.

SHA-256 of the vendored files:

| File | SHA-256 |
|------|---------|
| `LICENSE` | `e1aa6325b5df2cd95c0b70194dafe2080c961d52901010b584c6617a0bdd3956` |
| `README.md` | `c2126c19a9ade97f7bc0681091ce89e29550928da80cf9969d2279dbdabe79f0` |
| `board.xml` | `1af857cede710e77415fdf428128d24fdb74496c4df5f9b496797a295d981ace` |
| `changelog.txt` | `f9350976954e5fdd9e64aedc247ecb4f55efb69b2184de6d2a6e9330bbaf68cc` |
| `part0_pins.xml` | `68e46b265405af4c9dfa76d1ffa6124b59f85a57deb03a15dccd2b4e3c7fdf3d` |
| `preset.xml` | `351f3dbe1bf445fc069cd040d9ae0e205bbe9c9afa55665df321ca632665b6aa` |
| `xitem.json` | `4f717f5b99ad673784ad038eba87d3243e86176890c65ff5b9cfa3de7a2e0f0c` |

`ruckus.tcl` appends `board_repo` to the `board_part_repo_paths` project property and mirrors it in the
`board.repoPaths` param before it sets the board part.
