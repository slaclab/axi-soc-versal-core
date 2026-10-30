AIE Runtime Loading
===================

This page explains how AI Engine images are layered on top of the PL at
boot, and why the loader is built the way it is.  The file layout and
the exact sequence are in :doc:`../reference/boot_partition`; the
deploy procedure is in :doc:`../how-to/aie_image_deploy`.

This applies only to boards with an AI Engine array.  On a board without
one, the board's ``versal-user.conf`` omits the ``aie`` machine feature,
so the image carries no ``aie-partition-init``, the kernel exposes no
``/sys/class/aie``, and ``startup-app-init`` logs
``AIE not present (no /sys/class/aie) - skipping AIE PDI load`` and
continues.

Images stack on the PL
----------------------

An AIE image is a CDO-only partial PDI that configures the AIE array
on top of an already-programmed PL.  It needs no device-tree overlay of
its own: the ``ai_engine`` node is already live from ``pl.dtbo``, so the
PDI can go straight to the PLM through the kernel ``request_firmware``
path.  That is why ``startup-app-init`` loads AIE images only after the
PL load succeeded, and skips the whole AIE section on a board whose
kernel does not expose ``/sys/class/aie``.

No ``fpgautil`` in the AIE loop
-------------------------------

The loader deliberately does not use ``fpgautil`` for AIE images.  A
second ``fpgautil -o`` collides with the ``full`` overlay name created
by the ``pl.pdi`` load, and ``fpgautil`` reports that as
``Error: Overlay already exists in the live tree``.  A ``grep -i
failed`` retry loop never matches that message, so the load would be
skipped silently.  And ``fpgautil -R -n full`` would tear down the PL
fabric; the single ``-R -n full`` that clears prior overlays runs only
before the ``pl.pdi`` load.

Instead, each PDI is delivered through the ``fpga_manager`` firmware
attribute.  Two details matter when driving this by hand:

- The kernel searches ``/lib/firmware/`` (and
  ``/lib/firmware/updates/``) for a file whose name is the *exact
  string written*.  The PDI must be staged there first; ``/boot/aie/``
  is not a firmware search path.
- The written name must include the ``.pdi`` extension.  Writing the
  bare ``<name>`` gives
  ``Direct firmware load for <name> failed with error -2`` (``-ENOENT``)
  before the PDI is ever parsed.

The write is synchronous: ``fpga0/state`` reflects the result as soon
as it returns, ``operating`` on success or
``write error: 0x<plm-status>`` on PLM rejection (for example
``0x03260014``, IDCODE check failed).  A failed AIE image is logged and
the loop moves on; it does not stop the boot.

Holding the partition open
--------------------------

After the PDI is loaded, the AIE partition still has to be requested
and initialized.  The ``xilinx-ai-engine`` driver tears a partition
down on *last close* of its file descriptor, so this cannot be a
one-shot command.  ``aie-partition-init`` opens ``/dev/aie0``, requests
the partition described by the sidecar (``AIE_REQUEST_PART_IOCTL``),
initializes it (``AIE_PARTITION_INIT_IOCTL``), and then holds the fd
open with ``pause()`` for the lifetime of its systemd service.  The
init options leave out the column reset, shim reset and memory
zeroization flags, because those would destroy the graph that the PDI
just loaded.

Consequences:

- Running the agent by hand while the service holds the partition fails
  the request ioctl with ``Invalid argument``.  ``systemctl stop`` the
  service first.
- A stopped service is not proof the fd is released.  If
  ``/sys/class/aie/aiepart_<col>_<numcols>/`` still exists afterward,
  some process (for example a stray manual run, which systemd does not
  track) still holds ``/dev/aie0``.  Find and clear it before retrying:

  .. code-block:: bash

     fuser /dev/aie0
     kill <pid>

The sidecar is copied to ``/run/aie/`` only after its PDI loaded, and
the service is gated on that copy, so an agent never starts for an
image that failed to load.

Multiple images
---------------

Loading more than one AIE PDI is supported, but carries constraints the
kernel driver does not enforce:

- **Overlapping column geometry is undefined.**  If two PDIs claim the
  same AIE column range, the second load appears to succeed but the
  resulting partition state is undefined; the driver neither detects
  nor refuses the conflict.  The first-loaded PDI wins any column
  conflict.
- **Filename order is the only ordering control.**  The loader uses a
  shell lexicographic glob, so prefix names with a zero-padded number
  (``00_design_a.pdi``, ``10_design_b.pdi``) to control sequencing.

Diskless boards
---------------

On a ``tftp-only`` boot, U-Boot stacks the AIE PDIs listed in
``aie/manifest`` on the TFTP server, and passes each sidecar's
``PARTITION_ID``/``UID`` to Linux under ``/chosen/slac,aie/<name>``.
``startup-app-init`` then writes ``/run/aie/<name>.partition.conf``
from those properties and starts the same agent, so the partition
handling is identical in both modes.  See
:doc:`../how-to/tftp_network_boot`.
