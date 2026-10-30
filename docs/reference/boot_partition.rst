Boot Partition and Startup
==========================

Reference for the files on the SD card and the boot-time sequence run
by ``startup-app-init``.

SD card layout
--------------

``CreateDiskImage.sh`` and ``FormatSdCard.sh`` (see
:doc:`../how-to/sd_card_imaging`) create two partitions:

.. list-table::
   :header-rows: 1
   :widths: 14 22 64

   * - Partition
     - Mount point
     - Contents
   * - p1, FAT32
     - ``/boot``
     - Boot files below; mounted read-write on the running system
   * - p2, ext4
     - ``/app``
     - Application partition (optional ``/app/runtimeApp``)

The root filesystem runs from RAM (``root=/dev/ram0``), so ``/boot`` can
be rewritten while the system is running.

Files in ``/boot``
------------------

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - File
     - Purpose
   * - ``BOOT.BIN``
     - PLM, static PDI (PS and NoC configuration), TF-A and U-Boot.
       Loaded by the boot ROM in every boot mode.
   * - ``boot.scr``
     - U-Boot boot script
   * - ``image.ub``
     - Kernel FIT image (kernel, base DTB, initramfs)
   * - ``pl.pdi``
     - Dynamic PDI (PL fabric), loaded from Linux by
       ``startup-app-init``.  See :doc:`../how-to/remote_pl_update`.
   * - ``pl.dtbo``
     - Device-tree overlay for the PL, with
       ``firmware-name = "pl.pdi"`` and ``partial-fpga-config``
   * - ``system-top.dtb``
     - Standalone base DTB (with ``__symbols__``), used by a
       ``tftp-only`` U-Boot; harmless on the card
   * - ``ip`` (optional)
     - Static IPv4 address, assigned to ``eth0`` as ``/24``
   * - ``mac`` (optional)
     - MAC address to set on ``eth0`` (default comes from the board
       EEPROM)
   * - ``ssh/``
     - Persistent SSH host keys, generated on first boot
   * - ``aie/<name>.pdi``
     - CDO-only AIE partial PDI (see :doc:`../how-to/aie_image_deploy`)
   * - ``aie/<name>.partition.conf``
     - Sidecar for ``aie-partition-init``

startup-app-init sequence
-------------------------

:repo:`startup-app-init
<shared/Yocto/recipes-apps/startup-app-init/files/startup-app-init>` runs
as ``startup-app-init.service`` (``Restart=always``) and logs to the
journal and console.  In order, it:

1. Mounts the SD partitions on ``/boot`` and ``/app``.
2. Restores or generates the SSH host keys in ``/boot/ssh`` and starts
   ``sshd``.
3. Applies ``/boot/mac`` and ``/boot/ip`` if present.
4. If the DMA driver is already loaded (``/proc/axi_stream_dma_0``
   exists), kills ``jupyter``/``python3`` and unloads ``axi_memory_map``
   and ``axi_stream_dma``.
5. Loads the PL:

   - ``tftp-only`` boot (``/chosen/slac,boot-mode`` is ``tftp-only``):
     U-Boot already loaded the PL, nothing to do.
   - Both ``/boot/pl.pdi`` and ``/boot/pl.dtbo`` present: removes the
     ``full`` overlay, then runs
     ``fpgautil -o /boot/pl.dtbo -b /boot/pl.pdi`` (each step retried up
     to 30 times).
   - Only one of the two present: logs
     ``WARNING: 2nd-stage PL load skipped - need BOTH /boot/pl.pdi and
     /boot/pl.dtbo`` and skips the load.

6. If the PL was programmed, loads ``axi_memory_map`` and
   ``axi_stream_dma`` (with the build's buffer counts and size);
   otherwise logs ``ERROR: PL not programmed`` and skips the drivers.
7. Loads the AIE images, if ``/sys/class/aie`` exists (see below).
8. Runs ``axiversiondump``.
9. Runs ``/app/runtimeApp`` if it exists, otherwise
   ``roguetcpbridge --lane <DMA_NUM_LANES> --tdest <DMA_NUM_DEST>``.
   :repo:`shared/Yocto/runtimeApp` is an example that starts JupyterLab.

AIE image load
--------------

For each ``/boot/aie/*.pdi`` in lexicographic order:

1. Copy the PDI to ``/lib/firmware/<name>.pdi`` and write ``<name>.pdi``
   to ``/sys/class/fpga_manager/fpga0/firmware``.
2. Read ``fpga0/state``.  Anything other than ``operating`` logs
   ``ERROR: AIE PDI load failed`` and moves on to the next image.
3. On success, copy ``<name>.partition.conf`` to
   ``/run/aie/<name>.partition.conf`` and start
   ``aie-partition-init@<name>.service``.  A missing sidecar logs a
   ``WARNING`` and skips partition-init; the PDI stays programmed.

On a ``tftp-only`` boot, U-Boot already stacked the AIE PDIs, and the
sidecar values come from ``/proc/device-tree/chosen/slac,aie/<name>/``
(``partition-id`` and ``uid``) instead.

``aie-partition-init@.service`` runs
``/usr/bin/aie-partition-init --conf /run/aie/%i.partition.conf``, is
gated on ``ConditionPathExists=/run/aie/%i.partition.conf``, and
restarts on failure.

Sidecar schema
--------------

``<name>.partition.conf`` is a two-key shell-style file:

.. code-block:: text

   PARTITION_ID=0x2600
   UID=0xc8f9a8af

- Both keys are mandatory; a missing key makes ``aie-partition-init``
  exit non-zero.  Unknown keys are rejected.
- Values are parsed with ``strtoul(..., 0)``, so both ``0x`` hex and
  decimal are accepted.  Blank lines and ``#`` comments are allowed.
- ``UID`` is ``.AIE.ai_engine_0.partitions[0].aie_pl_intf_id`` from the
  Vitis ``aie_partition.json``.
- ``PARTITION_ID`` is ``(numColumns << 8) | startColumn`` from the same
  partition entry; a full-array 38-column design starting at column 0
  gives ``0x2600``.

In ``Simple-VEK280-Example`` the sidecar is generated by
``emit_partition_conf.sh`` during ``make`` in the AIE component
directory.

Diagnostics
-----------

.. code-block:: bash

   journalctl -b -u startup-app-init            # whole boot sequence
   cat /sys/class/fpga_manager/fpga0/state      # last PL/AIE load result
   axiversiondump                               # firmware identity
   systemctl status 'aie-partition-init@*'      # AIE agents
