Platform Architecture
=====================

This page is the platform-level architecture narrative for
``axi-soc-versal-core``.  The platform provides the core infrastructure
(PS block design wrapper, AXI-Lite register bridge, DMA engine, AIE
stream ports, and the shared Yocto build) that every Versal application
repo builds upon.  Per-board details are in
:doc:`../reference/supported_boards`.

System overview
---------------

A remote host connects to the Versal board over TCP.  The PS runs Linux
from RAM; the PL implements the FPGA design.  All register access and
DMA traffic crosses the PS-to-PL boundary through the
``AxiSocVersalCore`` block.

.. code-block:: text

   ┌──────────────────────────────────────────────────────────────────────┐
   │                  Host Machine (Remote Client)                        │
   │        PyRogue Root (e.g. software/scripts/devGui.py)                │
   └──────────────────────────────┬───────────────────────────────────────┘
                                  │ TCP: 9000/9001 memory,
                                  │      10000 + 512*lane + 2*tdest streams
   ┌──────────────────────────────▼───────────────────────────────────────┐
   │                      Versal Board (PS + PL + AIE)                    │
   │                                                                      │
   │  PS (Linux): roguetcpbridge ── /dev/axi_memory_map                   │
   │                             └─ /dev/axi_stream_dma_0                 │
   │        │ M_AXI_FPD (regs)   │ M_AXI_LPD (DMA ctrl)   ▲ NoC (DMA data)│
   │  ┌─────▼────────────────────▼──────────────────────────┴───────────┐ │
   │  │                  AxiSocVersalCore  (U_Core)                     │ │
   │  │  AxiSocVersalCpu ── AxiSocVersalReg ── AxiSocVersalDma          │ │
   │  │  (CIPS/NoC/AIE BD)  (AxiVersion,       (AxiStreamDmaV2,         │ │
   │  │                      AXIS monitors)     DMA_SIZE_G lanes)       │ │
   │  └──────┬─────────────────┬──────────────────────┬─────────────────┘ │
   │         │ aie* streams    │ app AXI-Lite         │ dma* streams      │
   │  ┌──────▼─────────────────▼──────────────────────▼─────────────────┐ │
   │  │                Application (app-specific RTL)                   │ │
   │  └─────────────────────────────────────────────────────────────────┘ │
   └──────────────────────────────────────────────────────────────────────┘

``AxiSocVersalCore``
--------------------

:repo:`shared/rtl/AxiSocVersalCore.vhd` is the only entity an
application instantiates.  It contains three blocks:

``AxiSocVersalCpu`` (board-specific, ``hardware/<HwType>/rtl/``)
   Wraps the Vivado block design ``AxiSocVersalCpuCore.bd``: the CIPS
   (PS and PMC), the NoC with LPDDR controllers, and the AI Engine
   array.  It converts the PS ``M_AXI_FPD`` and ``M_AXI_LPD`` masters to
   AXI-Lite (``AxiSocVersalAxiConvt``), exposes a 128-bit AXI4 slave
   through the NoC for DMA data, and generates ``dmaClk`` (250 MHz) and
   ``auxClk`` (100 MHz) from the PL reference clock with a
   ``ClockManagerVersal`` PLL.

``AxiSocVersalReg``
   The platform register block on ``M_AXI_FPD``: ``surf.AxiVersion``
   with the platform user registers, the DMA AXI-Stream monitors, and
   the pass-through to the application AXI-Lite slot at
   ``APP_ADDR_OFFSET_C``.  It also measures the application and DSP
   clocks and reports their reset state.

``AxiSocVersalDma``
   A ``surf.AxiStreamDmaV2`` engine (4096-entry descriptor memory) with
   ``DMA_SIZE_G`` lanes, controlled through ``M_AXI_LPD`` by the
   ``axi_stream_dma`` kernel driver.  Its per-lane AXI4 masters, plus an
   optional user AXI4 master, are merged by ``AxiSocVersalCoreCrossbar``
   onto the single AXI4 port into the NoC, and from there into PS DDR.

The address map and register contents are in
:doc:`../reference/register_map`.

Application interface
---------------------

The application connects to ``AxiSocVersalCore`` through:

- **AXI-Lite slot** (``appReadMaster``/``appWriteMaster``), covering
  ``0x8000_0000`` to ``0xFFFF_FFFF`` of the platform window, delivered
  in the application's own ``appClk`` domain.
- **DMA streams** (``dmaObMasters``/``dmaIbMasters``), one per lane, in
  the ``dmaClk`` domain with ``DMA_AXIS_CONFIG_C`` (128-bit).
- **AIE streams** (``aieIbMasters``/``aieObMasters``), ``AIE_SIZE_G``
  ports in the application-supplied ``aieClk`` domain with
  ``AIE_AXIS_CONFIG_C`` (128-bit).
- **Clocks**: ``dmaClk`` and ``auxClk`` outputs; ``dspClk``/``dspRst``
  inputs that are only monitored.

``Simple-VEK280-Example`` wires DMA lane 0 to a firmware PRBS loopback
and routes a second stream through the AIE loopback graph; see
:doc:`../how-to/rogue_gui_launch`.

Software stack on the board
---------------------------

The Yocto image built by :doc:`BuildYoctoProject.sh
<../reference/yocto_build>` adds the SLAC userspace to a PetaLinux
minimal image:

- ``aes-stream-drivers`` kernel modules: ``axi_memory_map`` (register
  access) and ``axi_stream_dma`` (DMA, buffers in the 1.5 GiB CMA pool).
- ``startup-app-init``: loads the PL and AIE images, the drivers, and
  the runtime application at boot (:doc:`../reference/boot_partition`).
- ``roguetcpbridge``: exposes the two device nodes to the network.
- ``axiversiondump``: prints the firmware identity on the board.
- ``aie-partition-init`` (AIE boards): holds the AIE partition open
  (:doc:`aie_runtime_loading`).

Host-side PyRogue classes are in :doc:`../reference/pyrogue_api`.

Boot flow
---------

1. The boot ROM loads ``BOOT.BIN`` from the SD card: the PLM programs
   the static PDI (PS, NoC, DDR), then TF-A and U-Boot run.
2. U-Boot boots ``image.ub`` (from SD, or from TFTP in the network
   modes, see :doc:`../how-to/tftp_network_boot`).
3. Linux runs ``startup-app-init``, which loads the dynamic PDI
   ``/boot/pl.pdi`` with its overlay ``/boot/pl.dtbo``, then the drivers,
   then any AIE images.

Splitting the PL from ``BOOT.BIN`` is what makes remote PL updates
possible, and it is also why the NoC must be locked between builds.
See :doc:`segmented_configuration`.

Further reading
---------------

- :doc:`../reference/register_map`: address windows, crossbar, user
  registers, clocks and stream configurations
- :doc:`../reference/pyrogue_api`: ``AxiSocCore``, ``AxiVersion`` and
  the TCP port scheme
- :doc:`segmented_configuration`: static and dynamic PDIs and the NoC
  lock
- :doc:`aie_runtime_loading`: how AIE images are stacked on the PL
