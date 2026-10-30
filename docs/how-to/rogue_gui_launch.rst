Launch the Rogue GUI
====================

Start the PyDM-based Rogue control GUI to interact with a running
axi-soc-versal-core board over TCP.

Prerequisites
-------------

- Rogue installed in a conda environment (see :doc:`rogue_install`).
- The board is powered on and reachable at its IP address (the examples
  below assume the DHCP-assigned address ``10.0.0.10``).
- The application repository cloned locally (e.g.
  ``Simple-VEK280-Example``).

Steps
-----

1. Activate the Rogue environment.  On the SLAC AFS network use the
   provided setup script:

   .. code-block:: bash

      source Simple-VEK280-Example/software/setup_env_slac.sh

   On a standalone machine, activate your conda Rogue environment
   directly.

2. Launch the GUI, passing the board IP address:

   .. code-block:: bash

      cd Simple-VEK280-Example/software
      python scripts/devGui.py --ip 10.0.0.10

   To run headless (no GUI), add ``--guiType None``; the ``Root`` stays
   up until ``Ctrl-C``:

   .. code-block:: bash

      python scripts/devGui.py --ip 10.0.0.10 --guiType None

What the GUI provides
---------------------

``devGui.py`` constructs the application ``Root`` defined in
`firmware/python/simple_vek280_example/_Root.py
<https://github.com/slaclab/Simple-VEK280-Example/blob/main/firmware/python/simple_vek280_example/_Root.py>`__
of the Simple-VEK280-Example repository, which:

- Opens a TCP memory-map connection to the board's Rogue TCP bridge
  (port 9000) and adds ``AxiSocCore`` at ``0x04_0000_0000`` and the
  ``Application`` device at ``0x04_8000_0000``.
- Opens TCP stream connections for DMA lane 0 (port 10000) and lane 1
  (port 10512).
- Starts a ZMQ server on ``127.0.0.1`` with an auto-assigned port, which
  the PyDM GUI attaches to.
- Launches the PyDM GUI via ``pyrogue.pydm.runPyDM()``.

The device tree includes two PRBS loopback paths for exercising the DMA
lanes:

- ``SwPrbsTx``/``SwPrbsRx``: DMA lane 0 firmware loopback in the PL.
- ``AiePrbsTx``/``AiePrbsRx``: DMA lane 1 loopback through the AIE
  array.  This requires the AIE loopback image to be deployed (see
  :doc:`aie_image_deploy`).

``AiePrbsTx.txPeriod`` defaults to 100 us to pace the round trip below
the DMA RX buffer pool depth.  Setting ``txPeriod=0`` saturates the TCP
bridge and drops frames (the AIE datapath itself is lossless).

See :doc:`../reference/pyrogue_api` for the platform classes and the
TCP port scheme.

Troubleshooting
---------------

- **Connection refused:** verify the board is booted and the IP is
  correct.  Run ``ping 10.0.0.10`` before launching, and check that
  ``startup-app-init`` started the bridge with
  ``ssh root@10.0.0.10 'journalctl -b -u startup-app-init'``.
- **Port 9000 already established:** another ``Root`` (on this or
  another host) already holds the memory connection.
  ``axi_soc_versal_core.connectionTest(ip)`` reports this case.  Close
  the other session first.
- **DMA lane count warning at start:** ``AxiSocCore`` prints
  ``numDmaLanes = N != AxiVersion.DMA_SIZE_G = M`` when the Python
  ``numDmaLanes`` argument does not match the firmware ``DMA_SIZE_G``
  generic.  Fix the ``Root`` argument to match the firmware build.
