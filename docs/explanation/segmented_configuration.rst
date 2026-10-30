Segmented Configuration and the NoC Lock
========================================

This page explains why Versal PL images ship as two PDIs, why the
runtime image must be the dynamic one, and why the NoC solution is
locked between builds.

Why Versal differs from ZynqMP for runtime PL loading
-----------------------------------------------------

On ZynqMP, the PCAP loader accepts the same ``.bit`` for both first-stage
and runtime PL programming, because it does a full-PL reload from
scratch every time.  The ``axi-soc-ultra-plus-core`` platform relies on
this: ``/boot/system.bit`` is simply reloaded by ``fpgautil`` at boot.

Versal's Platform Management Controller (PMC) works the other way.  It
treats the *base* PDI (loaded by the PLM at boot) and the *runtime* PDI
(loaded later through ``fpgautil``) as distinct artifacts with distinct
rules, and rejects any attempt to load the base PDI as a runtime PDI:
``xilfpga`` returns ``EPERM`` through the EEMI interface, and the kernel
surfaces it as error code ``0x1``.  The path is in
`drivers/fpga/versal-fpga.c
<https://github.com/Xilinx/linux-xlnx/blob/master/drivers/fpga/versal-fpga.c>`_
(``versal_fpga_ops_write`` to the ``zynqmp_pm_load_pdi`` return-code
branch).  See the `Solution Versal PL Programming wiki
<https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/1188397412/Solution+Versal+PL+Programming>`_
for the authoritative description.

A board that hits this rejection logs the triplet:

.. code-block:: text

   kernel: fpga_manager fpga0: Error while writing image data to FPGA
   startup-app-init[425]: BIN FILE loading through FPGA manager failed
   state: write error: 0x1

The fix is to make sure ``/boot/pl.pdi`` is a *runtime* (dynamic) PDI
built with Segmented Configuration, not a copy of the PDI that
``BOOT.BIN`` already contains.

Static and dynamic PDIs
-----------------------

Vivado's `Segmented Configuration
<https://github.com/Xilinx/Vivado-Design-Tutorials/tree/2025.2/Versal/Boot_and_Config/Segmented_Configuration>`_
flow is the minimum mechanism that provides a separate runtime PDI.
Setting ``USE_SEGMENTED_CONFIG = 1`` (in ``Simple-VEK280-Example`` this
lives in ``firmware/targets/shared_version.mk``) makes the ruckus build
emit:

``<full-name>_static.pdi``
   PS, PMC and NoC configuration.  The Yocto build packs it into
   ``BOOT.BIN``, and the PLM loads it at power-up.

``<full-name>_dynamic.pdi``
   The PL fabric.  The Yocto build copies it to ``pl.pdi``, and
   ``startup-app-init`` loads it from Linux with ``pl.dtbo``, whose
   ``partial-fpga-config`` property tells the FPGA manager this is a
   partial load on top of the running base.

Because the PL is no longer inside ``BOOT.BIN``, a new PL image can be
deployed by replacing one file on the SD card
(:doc:`../how-to/remote_pl_update`) or on a TFTP server.

Why the NoC must be locked
--------------------------

The two PDIs are not independent.  The static PDI configures the NoC,
including the NoC paths that connect the PS to the PL boundary, and the
dynamic PDI has to plug into exactly those paths and the same memory
map.  If Vivado re-solves the NoC in a later build, that build's
dynamic PDI expects a different NoC than the one the deployed
``BOOT.BIN`` set up, and it cannot be loaded on that board.

To keep builds interchangeable, Vivado can write a placed description
of the NoC solution (``.ncr``) and accept it back through the
``impl_1`` run property ``NOC_SOLUTION_FILE``.  Behind the scenes this
calls ``read_noc_solution`` before ``place_design``.  The platform ships
a golden solution for each block design version
(:repo:`hardware/XilinxVek280/bd/2025.1/XilinxVek280NoC.ncr`), and
:repo:`hardware/XilinxVek280/ruckus.tcl` applies it with ruckus's
``loadNoCSolution`` whenever ``USE_SEGMENTED_CONFIG`` is set.  Every
build from the same platform version therefore produces a dynamic PDI
that matches every ``BOOT.BIN`` from that version.

``pr_verify`` confirms the match by comparing the golden routed
checkpoint with a new one (:doc:`../how-to/verify_noc_compatibility`).
The golden design must carry the superset of PS, PL and NoC boundary
connections that later builds will use.

The ``U_Core`` requirement
--------------------------

The ``.ncr`` is keyed by full hierarchical instance names starting at
the application top, for example
``U_Core/REAL_CPU.U_CPU/U_CPU/Master_NoC/inst/S00_AXI_nmu/...``.  Every
consumer must therefore instantiate ``AxiSocVersalCore`` with the label
``U_Core``.  With a different label the solution does not apply, the
NoC is re-solved from scratch, and the resulting dynamic PDI is
incompatible with the deployed ``BOOT.BIN``.  Nothing in the build flags
this, which is why the label is documented as a hard requirement.

What a change to the platform means
-----------------------------------

- **Application RTL change:** only the dynamic PDI changes.  Deploy the
  new ``_dynamic.pdi``; ``BOOT.BIN`` and ``pl.dtbo`` stay.
- **Block design or** ``.ncr`` **change** (typically an
  ``axi-soc-versal-core`` update): the NoC solution changes, so the new
  dynamic PDI only works with a new ``BOOT.BIN``.  Rebuild Yocto with
  the new XSA and re-image the card.
- **pl-user.dtsi change:** rebuild Yocto and deploy the new ``pl.dtbo``
  together with the dynamic PDI.

Out of scope
------------

Full Dynamic Function eXchange with explicit Reconfigurable Partitions,
``libdfx`` userspace integration, and the AI Engine ``xclbin`` flow are
intentionally not used.  Segmented Configuration is the minimum
sufficient mechanism for fabric-only runtime PL reload on Versal; the
others would be revisited only if it proved insufficient.
