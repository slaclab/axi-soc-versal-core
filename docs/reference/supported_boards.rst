Supported Boards
================

The following application repos target Versal boards using the
``axi-soc-versal-core`` platform.  Each repo contains a board-specific
FPGA target under ``firmware/targets/<TargetName>/`` with its own
top-level VHDL entity, ``Makefile`` and ``ruckus.tcl``, and a
``BuildYoctoProject`` wrapper that selects the matching
``hardware/<HwType>/`` directory of this repo.

.. list-table:: Versal Application Repos
   :header-rows: 1
   :widths: 30 14 26 22 16 10

   * - Repo
     - Board model
     - Xilinx part number
     - Target dir name
     - ``hardware/`` dir
     - AIE
   * - `Simple-VEK280-Example <https://github.com/slaclab/Simple-VEK280-Example>`_
     - AMD VEK280
     - xcve2802-vsvh1760-2MP-e-S
     - SimpleVek280Example
     - XilinxVek280
     - Yes

Planned boards
--------------

The following boards have a hardware type code reserved (see
`Hardware type codes`_) but no ``hardware/`` directory or application
repo yet.  Part numbers and board parts are from the
`XilinxBoardStore 2026.2 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx>`_
branch (latest board revision).  Only the VEK385 and VEK386 have an AI
Engine array; the rest follow `Boards without an AI Engine`_.

.. list-table::
   :header-rows: 1
   :widths: 16 22 30 16 10

   * - Board model
     - Series
     - Xilinx part number
     - Board part
     - AIE
   * - `AMD VRK160 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vrk160/prod/1.0>`_
     - Versal RF
     - xcvr1602-vsva2488-2MP-e-S
     - ``vrk160_p``
     - No
   * - `AMD VRK165 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vrk165/prod/1.0>`_
     - Versal RF
     - xcvr1652-vsva2488-2MP-e-S
     - ``vrk165``
     - No
   * - `AMD VPK360 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vpk360>`_
     - Versal Premium Gen 2
     - xc2vp3602-vsvc3340-2MP-e-S
     - ``vpk360``
     - No
   * - `AMD VPK180 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vpk180>`_
     - Versal Premium
     - xcvp1802-lsvc4072-2MP-e-S
     - ``vpk180``
     - No
   * - `AMD VPK120 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vpk120>`_
     - Versal Premium
     - xcvp1202-vsva2785-2MP-e-S
     - ``vpk120``
     - No
   * - `AMD VMK365 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vmk365>`_
     - Versal Prime Gen 2
     - xc2vm3654-sfvb1440-2MP-e-s
     - ``vmk365``
     - No
   * - `AMD VMK180 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vmk180>`_
     - Versal Prime
     - xcvm1802-vsva2197-2MP-e-S
     - ``vmk180``
     - No
   * - `AMD VHK158 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vhk158>`_
     - Versal HBM
     - xcvh1582-vsva3697-2MP-e-S
     - ``vhk158``
     - No
   * - `AMD VEK386 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vek386>`_
     - Versal AI Edge Gen 2
     - xc2ve3858-ssva2397-2MP-e-S
     - ``vek386``
     - Yes
   * - `AMD VEK385 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vek385>`_
     - Versal AI Edge Gen 2
     - xc2ve3858-ssva2112-2MP-e-S
     - ``vek385``
     - Yes

Boards without an AI Engine
---------------------------

AI Engine support is a per-board option, not a platform requirement.
A board without an AI Engine array differs from the VEK280 in its
``hardware/<HwType>/`` directory only:

- The block design has no ``ai_engine`` IP, and the board's
  ``AxiSocVersalCpu`` ties off the ``aie*`` stream ports.  The ports
  stay on ``AxiSocVersalCore`` (``AIE_SIZE_G`` has a minimum of 1), so
  applications leave them unconnected.
- No AIE PL constraints (the VEK280 keeps them in
  ``xdc/XilinxVek280AiePl.xdc``).
- ``Yocto/versal-user.conf`` omits the ``aie`` machine feature, so the
  image carries no ``aie-partition-init`` (see
  :doc:`yocto_build`), and ``startup-app-init`` skips the AIE load at
  boot.

Everything else (Segmented Configuration, the NoC lock, remote PL
update, the register map and the PyRogue classes) is the same.  The NoC
solution ``.ncr`` is per block design, so each board ships its own.

Per-board files
---------------

Each ``hardware/<HwType>/`` directory provides everything that differs
between boards.  For the VEK280:

.. list-table::
   :header-rows: 1
   :widths: 45 55

   * - Path
     - Purpose
   * - :repo:`hardware/XilinxVek280/ruckus.tcl`
     - Vivado version and part checks, block design and NoC solution
       loading
   * - ``hardware/XilinxVek280/bd/<ver>/AxiSocVersalCpuCore.bd``
     - CIPS, NoC and LPDDR block design (plus the AI Engine on
       AIE-capable boards)
   * - ``hardware/XilinxVek280/bd/<ver>/XilinxVek280NoC.ncr``
     - Locked NoC solution for Segmented Configuration
   * - :repo:`hardware/XilinxVek280/rtl/AxiSocVersalCpu.vhd`
     - VHDL wrapper around the block design
   * - :repo:`hardware/XilinxVek280/rtl/HardwareTypePkg.vhd`
     - ``HW_TYPE_C`` and the PS memory port record types
   * - ``hardware/XilinxVek280/xdc/``
     - Board constraints
   * - :repo:`hardware/XilinxVek280/Yocto/versal-user.conf`
     - Yocto machine settings (``MACHINE_FEATURES``, U-Boot machine,
       device-tree board flags)
   * - ``hardware/XilinxVek280/Yocto/recipes-bsp/``
     - Device-tree fragments (``system-user.dtsi``, ``pl-user.dtsi``)
       and the U-Boot PHY patch

The ``hardware/`` directory name must match the ``hwType`` set in the
application's ``BuildYoctoProject`` wrapper, and its ``HW_TYPE_C`` value
must be listed in ``AxiSocVersalPkg.vhd`` and in the ``HW_TYPE_C`` enums
of :repo:`python/axi_soc_versal_core/_AxiVersion.py` and
:repo:`shared/Yocto/recipes-apps/axiversiondump/files/axiversiondump`.

Hardware type codes
-------------------

``AxiVersion.HW_TYPE_C`` (user register 6) reports the board the
firmware was built for:

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Value
     - VHDL constant
     - Python enum
   * - ``0x0000_0000``
     - ``HW_TYPE_UNDEFINED_C``
     - ``Undefined``
   * - ``0x0000_0001``
     - ``HW_TYPE_XILINX_VEK280_C``
     - ``XilinxVek280``
   * - ``0x0000_0002``
     - ``HW_TYPE_XILINX_VRK160_C``
     - ``XilinxVrk160``
   * - ``0x0000_0003``
     - ``HW_TYPE_XILINX_VRK165_C``
     - ``XilinxVrk165``
   * - ``0x0000_0004``
     - ``HW_TYPE_XILINX_VPK360_C``
     - ``XilinxVpk360``
   * - ``0x0000_0005``
     - ``HW_TYPE_XILINX_VPK180_C``
     - ``XilinxVpk180``
   * - ``0x0000_0006``
     - ``HW_TYPE_XILINX_VPK120_C``
     - ``XilinxVpk120``
   * - ``0x0000_0007``
     - ``HW_TYPE_XILINX_VMK365_C``
     - ``XilinxVmk365``
   * - ``0x0000_0008``
     - ``HW_TYPE_XILINX_VMK180_C``
     - ``XilinxVmk180``
   * - ``0x0000_0009``
     - ``HW_TYPE_XILINX_VHK158_C``
     - ``XilinxVhk158``
   * - ``0x0000_000A``
     - ``HW_TYPE_XILINX_VEK386_C``
     - ``XilinxVek386``
   * - ``0x0000_000B``
     - ``HW_TYPE_XILINX_VEK385_C``
     - ``XilinxVek385``
   * - ``0xFFFF_FFFF``
     - ``HW_TYPE_RESERVED_C``
     - ``Reserved``

Finding the target directory name
---------------------------------

The target directory name maps directly to the Vivado project name and
to the top-level VHDL entity.  The ``Makefile`` in that directory
carries the authoritative Xilinx device part string:

.. code-block:: bash

   grep PRJ_PART firmware/targets/<TargetName>/Makefile
