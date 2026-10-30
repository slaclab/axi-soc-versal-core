Register Map
============

This page documents the address map of the ``axi-soc-versal-core``
platform as seen from the Versal PS and from the PyRogue device tree.

PS address windows
------------------

The block design (``AxiSocVersalCpuCore.bd``) exposes two PL register
windows to the PS:

.. list-table::
   :header-rows: 1
   :widths: 20 22 12 46

   * - PS master
     - Base address
     - Size
     - Target
   * - ``M_AXI_FPD``
     - ``0x04_0000_0000``
     - 4 GiB
     - Platform and application AXI-Lite registers
       (:repo:`shared/rtl/AxiSocVersalReg.vhd`)
   * - ``M_AXI_LPD``
     - ``0x00_8000_0000``
     - 64 KiB
     - DMA engine control registers (``AxiStreamDmaV2``), used by the
       ``axi_stream_dma`` kernel driver (``axi_stream_dma_0@80000000``
       in ``system-user.dtsi``)

The Rogue TCP bridge on the board forwards memory transactions from
port 9000 to ``/dev/axi_memory_map``, which uses these PS physical
addresses directly.  Host-side PyRogue offsets are therefore absolute
PS addresses.

AXI-Lite crossbar
-----------------

Inside the ``M_AXI_FPD`` window, ``AxiSocVersalReg`` decodes four slots
with a ``surf.AxiLiteCrossbar``:

.. code-block:: text

   M_AXI_FPD (0x04_0000_0000)
        │
        ▼
   AxiSocVersalReg AxiLiteCrossbar
        ├─ [0] VERSION_INDEX_C  0x0000_0000  (16-bit)  surf.AxiVersion
        ├─ [1] AXIS_MON_IB_C    0x0002_0000  (16-bit)  DMA inbound AxiStreamMonAxiL
        ├─ [2] AXIS_MON_OB_C    0x0003_0000  (16-bit)  DMA outbound AxiStreamMonAxiL
        └─ [3] APP_INDEX_C      0x8000_0000  (31-bit)  application (appClk domain)

.. list-table::
   :header-rows: 1
   :widths: 30 28 42

   * - Block
     - PS address
     - Typical PyRogue path
   * - ``AxiVersion``
     - ``0x04_0000_0000``
     - ``Root.AxiSocCore.AxiVersion``
   * - DMA inbound monitor
     - ``0x04_0002_0000``
     - ``Root.AxiSocCore.DmaIbAxisMon``
   * - DMA outbound monitor
     - ``0x04_0003_0000``
     - ``Root.AxiSocCore.DmaObAxisMon``
   * - Application
     - ``0x04_8000_0000`` to ``0x04_FFFF_FFFF``
     - ``Root.Application``

The application slot is exported from ``AxiSocVersalCore`` as the
``appReadMaster``/``appWriteMaster`` ports and crosses into the
application's ``appClk`` domain through ``surf.AxiLiteAsync``.  The
application should decode its own sub-crossbar starting at
``APP_ADDR_OFFSET_C`` (``x"8000_0000"``, from
:repo:`shared/rtl/AxiSocVersalPkg.vhd`), passed in as its
``AXIL_BASE_ADDR_G`` generic.  Unmapped addresses return DECERR.

With ``EXT_AXIL_MASTER_G = true``, a second AXI-Lite master
(``extReadMaster``/``extWriteMaster``, ``dmaClk`` domain) shares the
same crossbar.

AxiVersion user registers
-------------------------

``AxiSocVersalReg`` drives the ``surf.AxiVersion`` ``userValues`` array,
which appears at ``0x400 + 4*n`` inside ``AxiVersion`` and is decoded by
:repo:`python/axi_soc_versal_core/_AxiVersion.py`:

.. list-table::
   :header-rows: 1
   :widths: 10 12 22 56

   * - n
     - Offset
     - Variable
     - Contents
   * - 0
     - ``0x400``
     - ``DMA_SIZE_G``
     - Number of DMA lanes (``DMA_SIZE_G`` generic)
   * - 1
     - ``0x404``
     - ``DMA_CLK_FREQ_C``
     - DMA clock frequency in Hz (250 MHz)
   * - 2
     - ``0x408``
     - ``AppReset``
     - Bit 0: ``appRst``, the DMA system reset, or the AxiVersion
       ``UserRst``, synchronized to ``dmaClk``
   * - 3
     - ``0x40C``
     - ``AppClkFreq``
     - Measured ``appClk`` frequency in Hz
   * - 4
     - ``0x410``
     - ``DspClkFreq``
     - Measured ``dspClk`` frequency in Hz
   * - 5
     - ``0x414``
     - ``DspReset``
     - Bit 0: ``dspRst``, synchronized
   * - 6
     - ``0x418``
     - ``HW_TYPE_C``
     - Hardware type code (see :doc:`supported_boards`)

Clocks
------

.. list-table::
   :header-rows: 1
   :widths: 20 18 62

   * - Clock
     - Frequency
     - Use
   * - ``dmaClk``
     - 250 MHz
     - DMA engine, AXI-Lite crossbar, ``dmaObMasters``/``dmaIbMasters``
       streams (``DMA_CLK_FREQ_C``)
   * - ``auxClk``
     - 100 MHz
     - General-purpose clock output for the application
       (``AUX_CLK_FREQ_C``)
   * - ``appClk``
     - application
     - Input; clocks the application AXI-Lite slot
   * - ``dspClk``
     - application
     - Input; frequency and reset monitored only
   * - ``aieClk``
     - application
     - Input; clocks the ``aieIbMasters``/``aieObMasters`` streams
       (AIE-capable boards only)

Stream configurations
---------------------

``AxiSocVersalPkg`` defines the AXI-Stream configurations the
application must match:

- ``DMA_AXIS_CONFIG_C``: 16-byte (128-bit) ``tData``, 8-bit ``tDest``,
  3-bit ``tId``, 4-bit ``tUser`` (first/last mode), compact ``tKeep``.
- ``AIE_AXIS_CONFIG_C`` (AIE-capable boards): 16-byte (128-bit)
  ``tData``, no ``tDest``, ``tId`` or ``tUser``, normal ``tKeep``.

External references
-------------------

- `Versal Adaptive SoC Register Reference (AM012)
  <https://docs.amd.com/r/en-US/am012-versal-register-reference>`_:
  authoritative PS and PMC register map.
