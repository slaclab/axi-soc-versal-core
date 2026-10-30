First SoC Bring-up
==================

This tutorial walks through building and booting a SLAC Versal SoC
platform design from source.  ``Simple-VEK280-Example`` (board: AMD
VEK280, FPGA part ``xcve2802-vsvh1760-2MP-e-S``) is used as the concrete
example throughout.  Paths under ``firmware/targets/`` are parameterised
with the ``<your-target-dir>`` placeholder; see
:doc:`../reference/supported_boards` for the target directory name of
your board.

Output filenames embed the build timestamp, user name, and git hash,
following the schema
``<TargetName>-<PRJ_VERSION>-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>``.
The ``<full-name>`` placeholder is used below wherever the exact filename
is build-specific.

.. admonition:: Reference toolchain

   This walkthrough was authored against:

   - **Vivado:** ``2025.2`` (sourced by ``firmware/setup_env_slac.sh``;
     ``2025.1`` is the minimum accepted by
     :repo:`hardware/XilinxVek280/ruckus.tcl`)
   - **Yocto:** AMD ``rel-v2026.1`` manifests (fetched by
     ``BuildYoctoProject.sh``)
   - **Rogue:** ``v6.16.0``
   - **Firmware version:** ``v2.3.0.1`` (``PRJ_VERSION = 0x02030001``)
   - **Target FPGA part:** ``xcve2802-vsvh1760-2MP-e-S``

Clone
-----

Install `git-lfs <https://git-lfs.com>`_ in your shell profile (one-time
step per environment) before cloning, so that the large binary files
tracked with LFS (for example the NoC solution ``.ncr``) are fetched
correctly:

.. code-block:: bash

   git lfs install

Clone the repository with all submodules:

.. code-block:: bash

   git clone --recursive https://github.com/slaclab/Simple-VEK280-Example.git

The ``--recursive`` flag initialises all git submodules (``surf``,
``axi-soc-versal-core``, ``ruckus``, ``aes-stream-drivers``) in a single
step.  Omitting it leaves the firmware build unable to find required RTL
and TCL sources.

Setup environment
-----------------

**Vivado toolchain (firmware build)**

On SLAC AFS hosts, source the provided setup script:

.. code-block:: bash

   source Simple-VEK280-Example/firmware/setup_env_slac.sh

This sources ``settings64.sh`` from the Vivado 2025.2 install under
``/sdf/group/faders/tools/xilinx/``.  On a non-SLAC host, source the
equivalent ``settings64.sh`` from your local Vivado installation
instead.

**Rogue / PyRogue environment (software)**

On SLAC AFS hosts:

.. code-block:: bash

   source Simple-VEK280-Example/software/setup_env_slac.sh

This activates the ``rogue_v6.16.0`` conda environment.  On a non-SLAC
host, see :doc:`../how-to/rogue_install`.

**Yocto host packages**

``BuildYoctoProject.sh`` verifies that the following host tools are on
``PATH`` before it starts, and exits with an install hint if any are
missing:

.. code-block:: text

   bash  curl  chrpath  diffstat  git  gzip  lz4c  mkimage

On Ubuntu these can be installed with:

.. code-block:: bash

   sudo apt install -y bash curl chrpath diffstat git gzip liblz4-tool u-boot-tools

**Build-output redirection (recommended before the Yocto build)**

Both the Vivado and Yocto builds write their intermediates under
``firmware/build/``, and the Yocto tree is very large.  If
``firmware/build/`` resolves to an NFS home directory or a partition
with little free space, the build will exhaust the quota or run very
slowly.  Point it at a local-disk partition before building:

.. code-block:: bash

   rm -rf Simple-VEK280-Example/firmware/build 2>/dev/null
   ln -s <your-local-disk-path>/build Simple-VEK280-Example/firmware/build

``firmware/build`` is gitignored, so the symlink is created once per
host and survives across builds.

Firmware build
--------------

Change into the target directory and run ``make``:

.. code-block:: bash

   cd Simple-VEK280-Example/firmware/targets/SimpleVek280Example/
   make

The project opts into Versal Segmented Configuration with
``USE_SEGMENTED_CONFIG = 1`` in ``firmware/targets/shared_version.mk``,
so the build writes **two** PDIs plus the XSA to the ``images/``
directory:

.. code-block:: text

   images/<full-name>_static.pdi    # PS + NoC; packed into BOOT.BIN by Yocto
   images/<full-name>_dynamic.pdi   # PL fabric; deployed as /boot/pl.pdi
   images/<full-name>.xsa           # hardware handoff for the Yocto build

See :doc:`../explanation/segmented_configuration` for why Versal needs
the split.

To review Vivado results in GUI mode after a successful build:

.. code-block:: bash

   make gui

Yocto build
-----------

The Yocto build produces the embedded Linux boot images that run on the
Versal Processing System.  From the target directory, pass the ``.xsa``
from the firmware build to the ``BuildYoctoProject`` wrapper:

.. code-block:: bash

   cd Simple-VEK280-Example/firmware/targets/SimpleVek280Example/
   ./BuildYoctoProject -f images/<full-name>.xsa

The wrapper fixes the board-specific settings (``hwType=XilinxVek280``,
DMA lane and buffer counts) and forwards ``-m``, ``-i``, ``-e`` and
``-c`` to the shared :repo:`BuildYoctoProject.sh`.  The default boot
mode is ``sd-only``; see :doc:`../reference/yocto_build` for every
option and :doc:`../how-to/tftp_network_boot` for the network boot
modes.

The script reads ``<full-name>_dynamic.pdi`` from next to the XSA and
stops with ``Dynamic PDI not found`` if the firmware build did not run
with ``USE_SEGMENTED_CONFIG=1``.

After a successful build, the boot images are in:

.. code-block:: text

   firmware/build/YoctoProjects/SimpleVek280Example/linux/BOOT.BIN
   firmware/build/YoctoProjects/SimpleVek280Example/linux/boot.scr
   firmware/build/YoctoProjects/SimpleVek280Example/linux/image.ub
   firmware/build/YoctoProjects/SimpleVek280Example/linux/pl.pdi
   firmware/build/YoctoProjects/SimpleVek280Example/linux/pl.dtbo
   firmware/build/YoctoProjects/SimpleVek280Example/linux/system-top.dtb

and the same set is packaged next to the XSA as:

.. code-block:: text

   firmware/targets/SimpleVek280Example/images/<full-name>.linux.tar.gz

See :doc:`../reference/boot_partition` for what each file does.

SD card
-------

Write the tarball to an SD card.  Full instructions, covering both
scripted approaches and by-hand partitioning, are on the
:doc:`../how-to/sd_card_imaging` page.  The quickest path formats,
partitions and loads the card in one pass (replace ``/dev/sdX`` with
your card, confirmed with ``lsblk -o NAME,SIZE,MODEL,TRAN``):

.. code-block:: bash

   ./firmware/submodules/axi-soc-versal-core/scripts/FormatSdCard.sh \
       /dev/sdX \
       firmware/targets/SimpleVek280Example/images/<full-name>.linux.tar.gz

Run the script as a normal user, from the ``Simple-VEK280-Example``
checkout; it invokes ``sudo`` itself for the steps that need root.

Boot
----

1. Power down the VEK280.
2. Insert the SD card.
3. Confirm the boot mode switch ``SW1[4:1] = 1110`` (mode pins
   ``[3:0]``; switch OFF = 1 = high, ON = 0 = low).
4. Power up the board.
5. Confirm the board is reachable on the network.  The examples below
   assume the DHCP-assigned address ``10.0.0.10``:

   .. code-block:: bash

      ping 10.0.0.10

**Serial console** (for troubleshooting boot failures or network
issues): connect a USB cable to the board's serial-to-USB bridge and
open the PS UART at 115200 8N1, for example:

.. code-block:: bash

   cu --line /dev/ttyUSB1 --speed 115200 --parity=none

Verify the firmware
-------------------

At boot, ``startup-app-init`` loads ``/boot/pl.pdi`` with its overlay,
loads the DMA kernel drivers, dumps the ``AxiVersion`` registers to the
journal, and starts the Rogue TCP bridge.  Check the result:

.. code-block:: bash

   ssh root@10.0.0.10 'cat /sys/class/fpga_manager/fpga0/state'
   ssh root@10.0.0.10 axiversiondump

The state should be ``operating``, ``FwVersion`` should match the
``PRJ_VERSION`` you built, and ``HW_TYPE_C`` should read
``XilinxVek280``.

Then connect from the host with the Rogue GUI
(:doc:`../how-to/rogue_gui_launch`):

.. code-block:: bash

   source Simple-VEK280-Example/software/setup_env_slac.sh
   cd Simple-VEK280-Example/software
   python scripts/devGui.py --ip 10.0.0.10

Optional: AIE loopback image
----------------------------

The SD tarball carries no AI Engine image.  To exercise the
``AiePrbsTx``/``AiePrbsRx`` loopback through the AIE array, build and
deploy the AIE image pair as described in
:doc:`../how-to/aie_image_deploy`.

Next steps
----------

- Iterate on the PL without re-imaging the card:
  :doc:`../how-to/remote_pl_update`.
- Understand the platform blocks and address map:
  :doc:`../explanation/architecture` and
  :doc:`../reference/register_map`.
