Deploy an AIE Image
===================

Build an AI Engine (AIE) image pair and load it onto a running board,
where ``startup-app-init`` stacks it on top of the PL at every boot.

Prerequisites
-------------

- The board was built for a machine with the ``aie`` feature (the VEK280
  is; see :doc:`../reference/yocto_build`) and has booted at least once.
- The PL image the AIE design connects to is already on the board
  (``/boot/pl.pdi`` and ``/boot/pl.dtbo``).
- Vitis 2025.1 or later (``firmware/setup_env_slac.sh`` sources 2025.2).
- SSH access to the board as ``root``.

The examples use the ``AieLoopback`` component of
``Simple-VEK280-Example``, which loops DMA lane 1 through the AIE array
and back.

Steps
-----

1. Build the firmware first (see :doc:`../tutorial/first_soc_bringup`).
   The AIE package step picks the newest ``.xsa`` in the Vivado target's
   ``images/`` directory.

2. Build the AIE image:

   .. code-block:: bash

      cd Simple-VEK280-Example/firmware/shared/AieLoopback/
      make

   This chains project creation, the ``aiecompiler`` build, packaging,
   and sidecar generation, and writes the deliverable pair to ``ip/``:

   .. code-block:: text

      ip/AieLoopback.pdi             # CDO-only partial PDI (stacks on the PL)
      ip/AieLoopback.partition.conf  # sidecar consumed by aie-partition-init

3. Deploy the pair to the board's ``/boot/aie/`` directory:

   .. code-block:: bash

      make program AIE_BOARD_IP=root@10.0.0.10

   The deploy helper uploads the pair, reboots the board, and verifies
   that the boot loop loaded the AIE image.  Without ``make program``,
   the manual equivalent is:

   .. code-block:: bash

      ssh root@10.0.0.10 'mkdir -p /boot/aie'
      scp ip/AieLoopback.pdi ip/AieLoopback.partition.conf root@10.0.0.10:/boot/aie/
      ssh root@10.0.0.10 '/bin/sync; /sbin/reboot'

Verification
------------

.. code-block:: bash

   ssh root@10.0.0.10 'journalctl -b -u startup-app-init | grep -E "AIE|fpga0/state"'
   ssh root@10.0.0.10 'systemctl status aie-partition-init@AieLoopback.service'

The journal should show ``AIE load: /boot/aie/AieLoopback.pdi`` followed
by ``fpga0/state: operating``, and the service should be active.  Then
run ``AiePrbsTx``/``AiePrbsRx`` from the Rogue GUI
(:doc:`rogue_gui_launch`).

Notes
-----

- Multiple images load in lexicographic filename order; prefix names to
  control ordering (``00_a.pdi``, ``10_b.pdi``).  See
  :doc:`../explanation/aie_runtime_loading` for the caveats on loading
  more than one image.
- To remove an AIE image, delete both files from ``/boot/aie/``,
  ``sync`` and reboot.
- A ``tftp-only`` board loads AIE images from the TFTP server instead;
  stage them with ``provision_tftp_host.sh -A`` (see
  :doc:`tftp_network_boot`).
- The sidecar schema is in :doc:`../reference/boot_partition`.
