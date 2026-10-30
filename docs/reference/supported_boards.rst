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
repo yet.  Both are Versal RF Series devices with LPDDR5 and **no AI
Engine array**.

.. list-table::
   :header-rows: 1
   :widths: 22 30 26 22

   * - Board model
     - Xilinx part number
     - Board part (BoardStore)
     - AIE
   * - `AMD VRK160 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vrk160/prod/1.0>`_
     - xcvr1602-vsva2488-2MP-e-S
     - ``vrk160_p``
     - No
   * - `AMD VRK165 <https://github.com/Xilinx/XilinxBoardStore/tree/2026.2/boards/Xilinx/vrk165/prod/1.0>`_
     - xcvr1652-vsva2488-2MP-e-S
     - ``vrk165``
     - No

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
