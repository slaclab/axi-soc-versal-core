Deploy an AIE Image
===================

Build an AI Engine (AIE) image pair and load it onto a running board,
where ``startup-app-init`` stacks it on top of the PL at every boot.

Prerequisites
-------------

- The board was built for a machine with the ``aie`` feature (see
  :doc:`../reference/yocto_build`) and has booted at least once.
- The PL image the AIE design connects to is already on the board
  (``/boot/pl.pdi`` and ``/boot/pl.dtbo``).
- Vitis 2025.1 or later.
- SSH access to the board as ``root``.
- An AIE component directory in the application repo whose ``Makefile``
  includes ruckus's ``system_vitis_unified_aie.mk``.  ``<AieComponent>``
  below stands for its project name.

Steps
-----

1. Build the firmware first (see :doc:`../tutorial/first_soc_bringup`).
   The AIE package step picks the newest ``.xsa`` in the Vivado target's
   ``images/`` directory.

2. Build the AIE image from the AIE component directory:

   .. code-block:: bash

      make

   This chains project creation, the ``aiecompiler`` build, packaging,
   and sidecar generation (ruckus ``vitis/aie/emit_partition_conf.sh``),
   and writes the deliverable pair to ``ip/``:

   .. code-block:: text

      ip/<AieComponent>.pdi             # CDO-only partial PDI (stacks on the PL)
      ip/<AieComponent>.partition.conf  # sidecar consumed by aie-partition-init

3. Deploy the pair to the board's ``/boot/aie/`` directory:

   .. code-block:: bash

      make program AIE_BOARD_IP=root@<board-ip>

   ``make program`` runs ruckus ``vitis/aie/program.sh``, which uploads
   the pair, reboots the board, and verifies that the boot loop loaded
   the AIE image.  The manual equivalent is:

   .. code-block:: bash

      ssh root@<board-ip> 'mkdir -p /boot/aie'
      scp ip/<AieComponent>.pdi ip/<AieComponent>.partition.conf root@<board-ip>:/boot/aie/
      ssh root@<board-ip> '/bin/sync; /sbin/reboot'

Verification
------------

.. code-block:: bash

   ssh root@<board-ip> 'journalctl -b -u startup-app-init | grep -E "AIE|fpga0/state"'
   ssh root@<board-ip> 'systemctl status aie-partition-init@<AieComponent>.service'

The journal should show ``AIE load: /boot/aie/<AieComponent>.pdi``
followed by ``fpga0/state: operating``, and the service should be
active.

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
