Verify NoC Compatibility
========================

Confirm that a new firmware build reused the locked NoC solution, so its
``_dynamic.pdi`` can be loaded on a board whose ``BOOT.BIN`` came from
an earlier build.

Background on why this matters is in
:doc:`../explanation/segmented_configuration`.

Prerequisites
-------------

- Both builds ran with ``USE_SEGMENTED_CONFIG=1``, so
  :repo:`hardware/XilinxVek280/ruckus.tcl` called ``loadNoCSolution``
  with :repo:`hardware/XilinxVek280/bd/2025.1/XilinxVek280NoC.ncr`.
  ``loadNoCSolution`` comes from ruckus (4.32.0 or later, enforced by
  :repo:`shared/ruckus.tcl`) and sets the ``NOC_SOLUTION_FILE`` property
  of the ``impl_1`` run.
- The routed checkpoint (``*_routed.dcp``) of the new build, and of the
  "golden" build that established the NoC solution.  ruckus writes them
  to the ``impl_1`` run directory,
  ``firmware/build/<TargetName>/<TargetName>_project.runs/impl_1/``.

Steps
-----

1. Check the instance label.  The ``.ncr`` is keyed by full hierarchical
   instance names starting at the application top, for example
   ``U_Core/REAL_CPU.U_CPU/U_CPU/Master_NoC/inst/S00_AXI_nmu/...``.  The
   application must instantiate ``AxiSocVersalCore`` as ``U_Core``:

   .. code-block:: vhdl

      U_Core : entity axi_soc_versal_core.AxiSocVersalCore

   With any other label the solution silently does not apply, the NoC
   is re-solved from scratch, and the resulting dynamic PDI is
   incompatible with the deployed ``BOOT.BIN``.

2. Open Vivado in Tcl mode and compare the two routed checkpoints.  The
   golden design must be listed first:

   .. code-block:: tcl

      pr_verify -initial <golden>_routed.dcp -additional <new>_routed.dcp

   ``pr_verify`` reports whether the NoC solutions are identical, in
   which case the two PL images are interchangeable on the same
   ``BOOT.BIN``.

When the check fails
--------------------

- If the block design (``AxiSocVersalCpuCore.bd``) changed, the old
  ``.ncr`` no longer describes the design.  Regenerate it from the new
  build's impl run directory (Vivado writes it next to the routed DCP),
  re-run ``pr_verify`` against the new golden DCP, and re-image the SD
  card with a ``.linux.tar.gz`` from that build.
- If the label is wrong, rename the instance to ``U_Core`` and rebuild.
