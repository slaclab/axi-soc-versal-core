PyRogue API Reference
=====================

This page documents the **platform-level** PyRogue classes provided by
the ``axi_soc_versal_core`` Python package (installed from the
``firmware/submodules/axi-soc-versal-core/python/`` submodule path).
These classes form the foundation that every Versal application repo
extends.

Application-level PyRogue (the per-board ``Root`` and ``Application``
device tree) is documented in each application repo.

Device tree pattern
-------------------

The PyRogue device tree mirrors the RTL AXI-Lite address hierarchy.
Each ``pr.Device`` holds its **offset relative to its parent**; the
absolute address of any register is the sum of offsets along the path
from root to leaf.  Because the board-side TCP bridge forwards to
``/dev/axi_memory_map``, the top-level offsets are absolute PS
addresses (see :doc:`register_map`).

.. code-block:: python

   import axi_soc_versal_core as socCore

   self.add(socCore.AxiSocCore(
       memBase     = self.tcpMemBase,
       offset      = 0x04_0000_0000,
       numDmaLanes = 1,
   ))

Key rules:

- Always pass ``**kwargs``: never enumerate base-class arguments
  explicitly.
- Use ``self.add(...)`` for every child device or variable.
- Offset addresses use hex with underscore groupings: ``0x04_0000_0000``,
  ``0x04_8000_0000``.

AxiSocCore
----------

:repo:`python/axi_soc_versal_core/_AxiSocCore.py`

``AxiSocCore`` maps to :repo:`shared/rtl/AxiSocVersalReg.vhd`.

Arguments:

``numDmaLanes`` (default ``1``)
   Number of DMA lanes the application expects.  Sizes the two stream
   monitors.  At ``_start()``, ``AxiSocCore`` compares it against
   ``AxiVersion.DMA_SIZE_G`` and prints a warning when they differ.

``sim`` (default ``False``)
   Skip the ``DMA_SIZE_G`` check when running against a Rogue
   simulation.

Children:

.. list-table::
   :header-rows: 1
   :widths: 22 14 64

   * - Name
     - Offset
     - Class
   * - ``AxiVersion``
     - ``0x0_0000``
     - ``axi_soc_versal_core.AxiVersion``
   * - ``DmaIbAxisMon``
     - ``0x2_0000``
     - ``surf.axi.AxiStreamMonAxiL`` (DMA inbound, ``numDmaLanes``
       lanes)
   * - ``DmaObAxisMon``
     - ``0x3_0000``
     - ``surf.axi.AxiStreamMonAxiL`` (DMA outbound, ``numDmaLanes``
       lanes)

Methods:

``UserRst(timeout=0)``
   Issue ``AxiVersion.UserRst()``, then wait until ``AppReset`` has read
   back low for 1 s continuously.  Returns ``True`` on timeout
   (``timeout`` in seconds; ``0`` waits forever), ``False`` otherwise.

``DspRstWait(timeout=0)``
   Wait until ``DspReset`` has read back low for 1 s continuously.  Same
   return convention as ``UserRst``.

AxiVersion
----------

:repo:`python/axi_soc_versal_core/_AxiVersion.py`

Extends ``surf.axi.AxiVersion`` with the platform user registers
``DMA_SIZE_G``, ``DMA_CLK_FREQ_C``, ``AppReset``, ``AppClkFreq``,
``DspClkFreq``, ``DspReset`` and ``HW_TYPE_C`` (offsets and contents in
:doc:`register_map`).  ``printStatus()`` prints them after the standard
``AxiVersion`` fields.

The on-board ``axiversiondump`` utility
(:repo:`shared/Yocto/recipes-apps/axiversiondump/files/axiversiondump`)
prints the same fields directly from ``/dev/axi_memory_map``; it runs
once at boot from ``startup-app-init`` and can be run by hand over SSH.

connectionTest
--------------

``axi_soc_versal_core.connectionTest(ip)`` (in
:repo:`python/axi_soc_versal_core/__init__.py`) pings the board and
checks whether a TCP connection to port 9000 on that IP is already
established.  It raises ``ValueError`` with troubleshooting hints if
the ping fails or another session holds the port.

TCP bridge ports
----------------

The board runs ``roguetcpbridge``
(:repo:`shared/Yocto/recipes-apps/roguetcpbridge/files/roguetcpbridge`),
started by ``startup-app-init`` unless ``/app/runtimeApp`` exists:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Port(s)
     - Connection
   * - 9000, 9001
     - Memory server, forwarded to ``/dev/axi_memory_map``
   * - ``10000 + 512*lane + 2*tdest`` and ``+1``
     - Stream server for ``DMA[lane][tdest]``, forwarded to
       ``/dev/axi_stream_dma_0`` channel ``256*lane + tdest``

The lane and ``tdest`` counts come from the ``DMA_NUM_LANES`` and
``DMA_NUM_DEST`` values passed to the Yocto build (``-l``/``-d``, see
:doc:`yocto_build`).  Host-side, connect with
``rogue.interfaces.memory.TcpClient(ip, 9000)`` and
``rogue.interfaces.stream.TcpClient(ip, port)``; for example DMA lane 0
is port 10000 and lane 1 is port 10512.
