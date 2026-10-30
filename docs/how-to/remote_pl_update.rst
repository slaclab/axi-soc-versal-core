Remote PL Update
================

Copy a new PL image (dynamic ``.pdi``) to the VEK280 over the network
and reboot to load it, without touching ``BOOT.BIN``, rebuilding Yocto,
or physically accessing the SD card.

How It Works
------------

Versal targets are built with Vivado's Segmented Configuration flow
(``USE_SEGMENTED_CONFIG=1``), which splits the image in two:

- ``<full-name>_static.pdi``: PS and NoC configuration.  It is packed
  into ``BOOT.BIN`` by the Yocto build and loaded by the PLM at power-up.
- ``<full-name>_dynamic.pdi``: all of the PL fabric.  The Yocto build
  copies it to ``/boot/pl.pdi``, and :repo:`startup-app-init
  <shared/Yocto/recipes-apps/startup-app-init/files/startup-app-init>`
  loads it at boot with
  ``fpgautil -o /boot/pl.dtbo -b /boot/pl.pdi``.

The NoC is locked to a pre-computed solution
(:repo:`hardware/XilinxVek280/bd/2025.1/XilinxVek280NoC.ncr`, applied by
``loadNoCSolution`` in :repo:`hardware/XilinxVek280/ruckus.tcl`), so the
``_dynamic.pdi`` from any later build is compatible with the
``BOOT.BIN`` already on the card.  Updating the PL therefore only needs
the new ``_dynamic.pdi``.  The new ``_static.pdi`` and ``.xsa`` are not
deployed.

``/boot/pl.dtbo`` normally does not need to change either.  The Yocto
build generates it from the XSA's PS-visible block design
(``AxiSocVersalCpuCore.bd``) plus the
:repo:`hardware/XilinxVek280/Yocto/recipes-bsp/device-tree/files/pl-user.dtsi`
fragment, and it references the PDI by name
(``firmware-name = "pl.pdi"``).  Application RTL changes do not affect
it.  If ``pl-user.dtsi`` changes (for example a new AIE interface or
PS-PL clock domain), rebuild Yocto and also copy the new
``firmware/build/YoctoProjects/<your-target-dir>/linux/pl.dtbo`` to
``/boot/pl.dtbo`` before the reboot.

Prerequisites
-------------

- The SD card was imaged (see :doc:`sd_card_imaging`) from a
  ``.linux.tar.gz`` built with ``USE_SEGMENTED_CONFIG=1`` and the NoC
  lock above, and the board has booted from it at least once.  A card imaged from a build that predates the NoC lock must be
  re-imaged once.
- The board is built for the ``sd-only`` (default) or ``fallback`` boot
  mode.  For ``tftp-only`` see `Notes`_.
- SSH access to the board as ``root``.
- The running and new builds use the same ``axi-soc-versal-core``
  version (same block design and ``.ncr``), and the application
  instantiates ``AxiSocVersalCore`` with the label ``U_Core`` (the
  ``.ncr`` is keyed by hierarchical instance name).
- The new build's dynamic PDI in the Vivado images directory:
  ``firmware/targets/<your-target-dir>/images/<full-name>_dynamic.pdi``
  (schema:
  ``<TargetName>-<PRJ_VERSION>-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>``).
  No new ``.linux.tar.gz`` is needed.

The example below updates a board running
``SimpleVek280Example-0x02030000-20261028094242-ruckman-6b669f7`` to
``SimpleVek280Example-0x02030001-20261028113245-ruckman-3385699``.
Replace ``<board-ip>`` with the board's address.

Steps
-----

1. Confirm what the board is running now:

   .. code-block:: bash

      ssh root@<board-ip> axiversiondump

   ``FwVersion`` should read ``0x2030000`` and ``GitHash`` should start
   with ``6b669f7``.

2. Keep a copy of the current PL image on the card for rollback:

   .. code-block:: bash

      ssh root@<board-ip> 'cp /boot/pl.pdi /boot/pl.pdi.bak'

3. Copy the new dynamic PDI over ``/boot/pl.pdi``:

   .. code-block:: bash

      cd firmware/targets/SimpleVek280Example/images
      scp SimpleVek280Example-0x02030001-20261028113245-ruckman-3385699_dynamic.pdi \
          root@<board-ip>:/boot/pl.pdi

   Use the ``_dynamic.pdi``, never the ``_static.pdi``: the PLM rejects
   a base PDI loaded at runtime (see
   :doc:`../explanation/segmented_configuration`).

4. Flush writes and reboot the board:

   .. code-block:: bash

      ssh root@<board-ip> '/bin/sync; /sbin/reboot'

   The ``sync`` command is critical: writing to an SD card is slow and
   rebooting before the write completes may corrupt the file.  ``sync``
   blocks until all writes are flushed to the card.

Verification
------------

After the board comes back up (typically 30 to 60 s), confirm it is
reachable:

.. code-block:: bash

   ping -c 4 <board-ip>

Check the PL load result and the firmware version that
``startup-app-init`` logged at boot:

.. code-block:: bash

   ssh root@<board-ip> 'cat /sys/class/fpga_manager/fpga0/state'
   ssh root@<board-ip> 'journalctl -b -u startup-app-init | grep -E "PL load|fpga0/state|ERROR|FwVersion|GitHash|BuildDate"'

The state should be ``operating``, there should be no ``ERROR`` lines,
``FwVersion`` should read ``0x2030001`` and ``GitHash`` should start
with ``3385699``.  Running ``ssh root@<board-ip> axiversiondump`` prints
the same information on demand.

If the load fails, the journal shows the rejection triplet described in
:doc:`../explanation/segmented_configuration`
(``Error while writing image data to FPGA``).  Roll back with:

.. code-block:: bash

   ssh root@<board-ip> 'cp /boot/pl.pdi.bak /boot/pl.pdi; /bin/sync; /sbin/reboot'

If the board does not come back on the network at all, remove the SD
card and restore ``pl.pdi`` on the boot partition from the
``.pdi.bak`` copy (or from the ``.linux.tar.gz`` it was imaged with).

Notes
-----

- For a ``tftp-only`` (diskless) board, U-Boot fetches ``pl.pdi`` from
  the TFTP server instead of the SD card.  Overwrite the staged
  ``pl.pdi`` on the server (and any per-MAC copy staged with
  ``provision_tftp_host.sh -M``) with the new ``_dynamic.pdi`` and
  reboot the board; see :doc:`tftp_network_boot`.
- AIE images in ``/boot/aie/`` are left untouched and are reloaded on
  top of the new PL at boot.
- To confirm before deploying that a new build reused the locked NoC
  solution, see :doc:`verify_noc_compatibility`.
- A change to the block design or an ``axi-soc-versal-core`` update
  that changes the ``.ncr`` produces a PL image that is not compatible
  with the deployed ``BOOT.BIN``.  In that case rebuild Yocto with the
  new XSA and re-image the card.
