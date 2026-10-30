First SoC Bring-up
==================

This tutorial walks through building and booting a SLAC Versal SoC
platform design from source.  It covers the board-agnostic steps shared
by every ``axi-soc-versal-core`` application repo; each application
repo's own docs list its target directory, boot switch settings, and
application-specific steps.  See :doc:`../reference/supported_boards`
for the list of application repos.

Paths are parameterised with placeholders:

- ``<app-repo>``: the application repository, e.g. ``Simple-<board>-Example``
- ``<your-target-dir>``: the target directory under ``firmware/targets/``
- ``<board-ip>``: the board's IP address

Output filenames embed the build timestamp, user name, and git hash,
following the schema
``<TargetName>-<PRJ_VERSION>-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>``.
The ``<full-name>`` placeholder is used below wherever the exact filename
is build-specific.

.. admonition:: Reference toolchain

   - **Vivado:** ``2025.1`` or later (checked by
     :repo:`hardware/XilinxVek280/ruckus.tcl`)
   - **Yocto:** AMD ``rel-v2026.1`` manifests (fetched by
     ``BuildYoctoProject.sh``)
   - **Rogue:** the release pinned in
     :repo:`shared/Yocto/recipes-apps/rogue/rogue.bb` (``6.16.0``)

Clone
-----

Install `git-lfs <https://git-lfs.com>`_ in your shell profile (one-time
step per environment) before cloning, so that the large binary files
tracked with LFS (for example the NoC solution ``.ncr``) are fetched
correctly:

.. code-block:: bash

   git lfs install

Clone the application repository with all submodules:

.. code-block:: bash

   git clone --recursive https://github.com/slaclab/<app-repo>.git

The ``--recursive`` flag initialises all git submodules (``surf``,
``axi-soc-versal-core``, ``ruckus``, ``aes-stream-drivers``) in a single
step.  Omitting it leaves the firmware build unable to find required RTL
and TCL sources.

Setup environment
-----------------

**Vivado toolchain (firmware build)**

Source the Vivado ``settings64.sh`` for your installation.  On SLAC AFS
hosts, application repos provide ``firmware/setup_env_slac.sh``, which
sources it from ``/sdf/group/faders/tools/xilinx/``:

.. code-block:: bash

   source <app-repo>/firmware/setup_env_slac.sh

**Rogue / PyRogue environment (software)**

On SLAC AFS hosts, application repos provide
``software/setup_env_slac.sh``, which activates a matching Rogue conda
environment.  On a non-SLAC host, see :doc:`../how-to/rogue_install`.

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

   rm -rf <app-repo>/firmware/build 2>/dev/null
   ln -s <your-local-disk-path>/build <app-repo>/firmware/build

``firmware/build`` is gitignored, so the symlink is created once per
host and survives across builds.

Firmware build
--------------

Change into the target directory and run ``make``:

.. code-block:: bash

   cd <app-repo>/firmware/targets/<your-target-dir>/
   make

Applications opt into Versal Segmented Configuration with
``USE_SEGMENTED_CONFIG = 1`` (typically in
``firmware/targets/shared_version.mk``), so the build writes **two**
PDIs plus the XSA to the ``images/`` directory:

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
from the firmware build to the application's ``BuildYoctoProject.sh``
wrapper:

.. code-block:: bash

   cd <app-repo>/firmware/targets/<your-target-dir>/
   ./BuildYoctoProject.sh -f images/<full-name>.xsa

The wrapper fixes the board-specific settings (hardware type, DMA lane
and buffer counts) and forwards ``-m``, ``-i``, ``-e`` and ``-c`` to the
shared :repo:`BuildYoctoProject.sh`.  The default boot mode is
``sd-only``; see :doc:`../reference/yocto_build` for every option and
:doc:`../how-to/tftp_network_boot` for the network boot modes.

The script reads ``<full-name>_dynamic.pdi`` from next to the XSA and
stops with ``Dynamic PDI not found`` if the firmware build did not run
with ``USE_SEGMENTED_CONFIG=1``.

After a successful build, the boot images are in:

.. code-block:: text

   firmware/build/YoctoProjects/<your-target-dir>/linux/BOOT.BIN
   firmware/build/YoctoProjects/<your-target-dir>/linux/boot.scr
   firmware/build/YoctoProjects/<your-target-dir>/linux/image.ub
   firmware/build/YoctoProjects/<your-target-dir>/linux/pl.pdi
   firmware/build/YoctoProjects/<your-target-dir>/linux/pl.dtbo
   firmware/build/YoctoProjects/<your-target-dir>/linux/system-top.dtb

and the same set is packaged next to the XSA as:

.. code-block:: text

   firmware/targets/<your-target-dir>/images/<full-name>.linux.tar.gz

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
       firmware/targets/<your-target-dir>/images/<full-name>.linux.tar.gz

Run the script as a normal user, from the application checkout; it
invokes ``sudo`` itself for the steps that need root.

Boot
----

1. Power down the board.
2. Insert the SD card.
3. Set the board's boot mode switches to SD boot (the setting is listed
   in each application repo's docs).
4. Power up the board.
5. Confirm the board is reachable on the network:

   .. code-block:: bash

      ping <board-ip>

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

   ssh root@<board-ip> 'cat /sys/class/fpga_manager/fpga0/state'
   ssh root@<board-ip> axiversiondump

The state should be ``operating``, ``FwVersion`` should match the
``PRJ_VERSION`` you built, and ``HW_TYPE_C`` should name your board.

Then connect from the host with the application's Rogue GUI
(:doc:`../how-to/rogue_gui_launch`).

Next steps
----------

- Iterate on the PL without re-imaging the card:
  :doc:`../how-to/remote_pl_update`.
- Load an AI Engine image on top of the PL (AIE-capable boards only):
  :doc:`../how-to/aie_image_deploy`.
- Understand the platform blocks and address map:
  :doc:`../explanation/architecture` and
  :doc:`../reference/register_map`.
