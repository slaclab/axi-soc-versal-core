FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SYSTEM_USER_DTSI ?= "system-user.dtsi"
PL_USER_DTSI     ?= "pl-user.dtsi"
 
SRC_URI:append = " file://${SYSTEM_USER_DTSI}"
SRC_URI:append = " file://${PL_USER_DTSI}"
 
do_configure:append() {
   cp ${WORKDIR}/${SYSTEM_USER_DTSI} ${B}/device-tree
   cp ${WORKDIR}/${PL_USER_DTSI}     ${B}/device-tree
   echo "#include \"${SYSTEM_USER_DTSI}\"" >> ${B}/device-tree/system-top.dts
   echo "#include \"${PL_USER_DTSI}\""     >> ${B}/device-tree/pl.dtsi
}
