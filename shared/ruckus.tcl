# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {aes-stream-drivers}  {7.2.1} ] < 0 } {exit -1}
   if { [SubmoduleCheck {ruckus}             {4.26.0} ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}               {2.70.0} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in axi-soc-versal-core/ruckus.tcl"
   puts "*********************************************************\n\n"
}

# Check for .pdi file copy to target's image dir
if { $::env(GEN_PDI_IMAGE) == 0 } {
   puts "\n\n*********************************************************"
   puts "GEN_PDI_IMAGE env var must be defined as 1 in Makefile"
   puts "*********************************************************\n\n"
   exit -1
}

# Check for .xsa file copy to target's image dir
if { $::env(GEN_XSA_IMAGE) == 0 } {
   puts "\n\n*********************************************************"
   puts "GEN_XSA_IMAGE env var must be defined as 1 in Makefile"
   puts "*********************************************************\n\n"
   exit -1
}

# Versal runtime PL reload requires Segmented Configuration (issue #6).
# The PMC rejects loading the base PDI as a runtime PDI; the dynamic PDI
# from a Segmented Configuration build is the only artifact the PMC accepts.
if { ![info exists ::env(USE_SEGMENTED_CONFIG)] || $::env(USE_SEGMENTED_CONFIG) == 0 } {
   puts "\n\n*********************************************************"
   puts "USE_SEGMENTED_CONFIG env var must be defined as 1 in Makefile"
   puts "Required for runtime PL reload; see README section"
   puts "'Why Versal differs from ZynqMP'."
   puts "*********************************************************\n\n"
   exit -1
}

# Check for version 2025.1 of Vivado (or later)
if { [VersionCheck 2025.1] < 0 } {exit -1}

# Load Source Code
loadSource -lib axi_soc_versal_core -dir "$::DIR_PATH/rtl"
loadSource -lib axi_soc_versal_core -dir "$::DIR_PATH/ip"

# loadIpCore -dir "$::DIR_PATH/ip/AxiPcie16BCrossbarIpCore"
loadSource -lib axi_soc_versal_core -dir "$::DIR_PATH/ip/AxiPcie16BCrossbarIpCore"

## Enable DFX in a project
#set_property PR_FLOW 1 [current_project]
