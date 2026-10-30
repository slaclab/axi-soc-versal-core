Launch the Rogue GUI
====================

Start the PyDM-based Rogue control GUI to interact with a running
axi-soc-versal-core board over TCP.

Prerequisites
-------------

- Rogue installed in a conda environment (see :doc:`rogue_install`).
- The board is powered on and reachable at ``<board-ip>``.
- The application repository (``<app-repo>``) cloned locally.

Steps
-----

1. Activate the Rogue environment.  On the SLAC AFS network use the
   application's setup script:

   .. code-block:: bash

      source <app-repo>/software/setup_env_slac.sh

   On a standalone machine, activate your conda Rogue environment
   directly.

2. Launch the application's GUI script, passing the board IP address.
   SLAC example repos use ``software/scripts/devGui.py``:

   .. code-block:: bash

      cd <app-repo>/software
      python scripts/devGui.py --ip <board-ip>

   The application repo's docs list any other options (for example a
   headless mode) and describe its device tree.

What the platform provides
--------------------------

On the board, ``startup-app-init`` starts ``roguetcpbridge``, which
serves:

- **Port 9000**: memory transactions, forwarded to
  ``/dev/axi_memory_map``.  The application ``Root`` adds
  ``axi_soc_versal_core.AxiSocCore`` at ``0x04_0000_0000`` and its own
  ``Application`` device at ``0x04_8000_0000``.
- **Ports 10000 + 512*lane + 2*tdest**: DMA streams, one per lane and
  ``tdest``.

See :doc:`../reference/pyrogue_api` for the platform classes and the
port scheme, and :doc:`../reference/register_map` for the address map.

Troubleshooting
---------------

- **Connection refused:** verify the board is booted and the IP is
  correct.  Run ``ping <board-ip>`` before launching, and check that
  ``startup-app-init`` started the bridge with
  ``ssh root@<board-ip> 'journalctl -b -u startup-app-init'``.
- **Port 9000 already established:** another ``Root`` (on this or
  another host) already holds the memory connection.
  ``axi_soc_versal_core.connectionTest(ip)`` reports this case.  Close
  the other session first.
- **DMA lane count warning at start:** ``AxiSocCore`` prints
  ``numDmaLanes = N != AxiVersion.DMA_SIZE_G = M`` when the Python
  ``numDmaLanes`` argument does not match the firmware ``DMA_SIZE_G``
  generic.  Fix the ``Root`` argument to match the firmware build.
