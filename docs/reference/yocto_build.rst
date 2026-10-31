Yocto Build
===========

Reference for :repo:`BuildYoctoProject.sh`, the shared Yocto build
driver.  Application repos call it through a per-target
``BuildYoctoProject.sh`` wrapper
(``firmware/targets/<TargetName>/BuildYoctoProject.sh``) that fixes the
board-specific arguments and forwards the rest.

Wrapper options
---------------

The SLAC example wrappers accept:

.. list-table::
   :header-rows: 1
   :widths: 18 82

   * - Option
     - Meaning
   * - ``-f XSA``
     - Path to the Vivado ``.xsa`` (required).  ``<xsa>_dynamic.pdi``
       must sit next to it.
   * - ``-m MODE``
     - U-Boot boot mode, forwarded as ``-m``
   * - ``-i IMAGE``
     - Image to bitbake, forwarded as ``-i``
   * - ``-e``
     - Drop into a Yocto shell instead of building, forwarded as ``-e``
   * - ``-c``
     - Force reconfigure, forwarded as ``-c``

and pass the application's fixed values for ``-h`` (hardware type),
``-l``/``-d`` (DMA lanes and ``tdest`` per lane), ``-t``/``-r`` (TX/RX
buffer counts) and ``-s`` (buffer size); each application repo lists
its values.  The build directory is
``firmware/build/YoctoProjects/<TargetName>``, and ``-n`` is the target
directory name.

BuildYoctoProject.sh options
----------------------------

.. list-table::
   :header-rows: 1
   :widths: 18 82

   * - Option
     - Meaning
   * - ``-p PATH``
     - Build directory (required).  The project is created in
       ``PATH/<NAME>``; the shared ``sstate-cache`` lives in ``PATH``.
   * - ``-n NAME``
     - Target name (required); also the board hostname
   * - ``-h HWTYPE``
     - Hardware type, must match a ``hardware/`` directory (required)
   * - ``-x XSA``
     - Path to the ``.xsa`` (required)
   * - ``-T PATH``
     - The application's ``firmware/`` directory (required)
   * - ``-l LANES``
     - Number of DMA lanes (``DMA_NUM_LANES``)
   * - ``-d DESTS``
     - Number of ``tdest`` per lane (``DMA_NUM_DEST``)
   * - ``-t TXCNT``
     - Number of DMA TX buffers (``DMA_TX_BUFF_COUNT``)
   * - ``-r RXCNT``
     - Number of DMA RX buffers (``DMA_RX_BUFF_COUNT``)
   * - ``-s BUFFSZ``
     - DMA buffer size in bytes (``DMA_BUFF_SIZE``)
   * - ``-i IMAGE``
     - Image to bitbake (default ``petalinux-image-minimal``)
   * - ``-m MODE``
     - U-Boot boot mode baked into ``BOOT.BIN``: ``sd-only`` (default),
       ``fallback`` or ``tftp-only``
   * - ``-e``
     - Activate the Yocto environment and drop into an interactive
       shell in the build directory instead of running bitbake
   * - ``-c``
     - Force reconfigure of an existing project
   * - ``-H``
     - Show the help text

Boot modes
----------

.. list-table::
   :header-rows: 1
   :widths: 16 84

   * - Mode
     - Behavior
   * - ``sd-only``
     - Never attempts DHCP or TFTP; boots ``image.ub`` from the SD card
       and loads ``/boot/pl.pdi`` from Linux.  No TFTP server needed.
   * - ``fallback``
     - U-Boot tries to fetch the kernel FIT over TFTP first, then boots
       the on-SD ``image.ub`` if that fails.
   * - ``tftp-only``
     - Diskless: U-Boot loads ``pl.pdi``, applies ``pl.dtbo``, stacks
       the AIE PDIs and boots ``image.ub`` all over TFTP, and halts
       instead of falling back to SD.

``UBOOT_NETBOOT_MODE`` is written to ``local.conf`` on a fresh or
``-c`` configure.  Re-running with an explicit ``-m`` re-syncs it on an
existing project; a run without ``-m`` keeps a hand edit.  See
:doc:`../how-to/tftp_network_boot` for the server side.

Checks before the build
-----------------------

The script exits early when:

- Any of ``bash curl chrpath diffstat git gzip lz4c mkimage`` is missing
  from ``PATH`` (it prints the ``apt install`` line to fix it).
- ``(TXCNT + RXCNT) * BUFFSZ`` exceeds 1.5 GiB (``0x60000000``), the size
  of the CMA pool reserved in ``system-user.dtsi``.
- ``hardware/<HWTYPE>/Yocto/versal-user.conf`` or
  ``hardware/<HWTYPE>/Yocto/recipes-bsp`` does not exist.
- ``<xsa>_dynamic.pdi`` is not found next to the XSA (the firmware was
  not built with ``USE_SEGMENTED_CONFIG=1``).

Reconfiguration
---------------

The project records the XSA path in ``.build_stamp``.  Passing a
different XSA path, or ``-c``, deletes the project directory and
configures from scratch (the ``sstate-cache`` is kept outside it, so
rebuilds reuse already-built components).

Layers and configuration
------------------------

On configure, the script assembles a ``meta-user`` layer from:

- :repo:`shared/Yocto/versal-user.conf` followed by
  ``hardware/<HWTYPE>/Yocto/versal-user.conf``, concatenated into the
  ``versal-user`` machine, with ``HDF_PATH`` set to the XSA.
- ``hardware/<HWTYPE>/Yocto/recipes-bsp`` (device tree, U-Boot).
- ``aes-stream-drivers/Yocto/recipes-kernel`` (``axistreamdma``,
  ``aximemorymap`` kernel modules).
- :repo:`shared/Yocto` ``recipes-apps``: ``rogue``, ``roguetcpbridge``,
  ``axiversiondump``, ``startup-app-init`` and ``aie-partition-init``.

Then it appends any application-provided layers and configuration:

- Every ``<firmware>/shared/Yocto/meta-*`` directory.
- Every ``<firmware>/targets/<NAME>/meta-*`` directory.
- ``<firmware>/shared/Yocto/local.conf``, appended to ``local.conf``.

Machine features
----------------

The board's ``versal-user.conf`` gates optional userspace:

``aie``
   When the ``aie`` token (with a leading space) appears in the board's
   ``versal-user.conf`` (for the VEK280:
   ``MACHINE_FEATURES:append = " vdu aie"``), the build prints
   ``MACHINE_FEATURES=aie detected: Including AIE partition-init`` and
   adds ``aie-partition-init`` to ``IMAGE_INSTALL``.  Boards without an
   AI Engine array (for example the VPK180 and VMK180) omit the token
   and get no AIE recipe, binary or unit.

``rfsoc``
   When ``MACHINE_FEATURES:append = " rfsoc"`` is present, ``pyrfdc`` is
   added to the image.

The shared :repo:`shared/Yocto/versal-user.conf` always enables
``fpga-overlay`` and ``fpga-manager-script``, which provide the
``pl.dtbo`` overlay path used to load the PL from Linux.

Outputs
-------

.. list-table::
   :header-rows: 1
   :widths: 45 55

   * - Path
     - Contents
   * - ``<PATH>/<NAME>/linux/``
     - ``BOOT.BIN``, ``boot.scr``, ``image.ub``, ``pl.pdi``,
       ``pl.dtbo``, ``system-top.dtb`` (and ``ip``, see below)
   * - ``<xsa-basename>.linux.tar.gz``
     - The same file set, packaged next to the XSA

``pl.pdi`` is a copy of ``<xsa>_dynamic.pdi``.  When the environment
variable ``SOC_IP_STATIC`` is set at build time, its value is written to
``linux/ip`` and included in the tarball; ``startup-app-init`` then
assigns that address (``/24``) to ``eth0`` at boot.  See
:doc:`boot_partition` for what each file does on the board.
