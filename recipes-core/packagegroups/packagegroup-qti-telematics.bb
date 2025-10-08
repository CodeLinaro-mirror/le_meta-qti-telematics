SUMMARY = "QTI package groups for Telematics modules"
DESCRIPTION = "Package group to bring in all basic packages for LE Telematics system"
LICENSE = "BSD-3-Clause"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

OPENAVB ?= "False"
OPENAVB:sa415m = "True"
OPENAVB:sa410m = "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'False', 'True',d)}"
OPENAVB:sa515m = "True"
OPENAVB:sa510m = "True"
OPENAVB:sa535m = "True"
OPENAVB:sa525m = "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-fota', 'False', 'True',d)}"
PTPVIRT ?=  "False"
PTPVIRT:sa525m = "${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-vm-host qti-vm-tele', 'True', 'False',d)}"

SENSORIDL ?= "False"
SENSORIDL:sa525m = "${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-vm-tele', 'False', 'True',d)}"

CRONIE ?= "True"
CRONIE:sa510m = "False"
CRONIE:sa525m-fotavm = "False"

QTI_CAN ?= "False"
QTI_CAN:sa510m= "True"
QTI_CAN:sa535m= "True"

PROVIDES = "${PACKAGES}"
PACKAGES = ' \
    ${MLPREFIX}packagegroup-qti-telematics \
    ${MLPREFIX}packagegroup-qti-telematics-utils \
    ${MLPREFIX}packagegroup-qti-telematics-vnw \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sensors', '${MLPREFIX}packagegroup-qti-telematics-sensors', '', d)} \
    '

RDEPENDS:packagegroup-qti-telematics = "\
    ${MLPREFIX}packagegroup-qti-telematics-utils \
    ${MLPREFIX}packagegroup-qti-telematics-vnw \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sensors', '${MLPREFIX}packagegroup-qti-telematics-sensors', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'qti-mvm', '${MLPREFIX}packagegroup-qti-telematics-mvm', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'vbleima', 'keyutils ima-evm-utils attr ima-cert-setup', '',d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'packagegroup-qti-telematics-nad-core', '', d)} \
    "

RDEPENDS:packagegroup-qti-telematics-sensors = "\
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', '', 'sensor-util-lib sensor-util-testapp', d)}\
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-tele', '', 'sensor-hal-daemon', d)}\
    libsensors sensor-socket sensor-client-api sensor-client-api-testapp sensor-testapp-legacy \
    ${@oe.utils.conditional('SENSORIDL', 'True', 'sensor-idl-client', '', d)} \
    "

RDEPENDS:packagegroup-qti-telematics-utils = "\
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', '', 'qdloader', d)} \
    ${@oe.utils.conditional('CRONIE', 'True', 'cronie', '', d)} \
    ${@oe.utils.conditional('DEBUG_BUILD', '1', 'devmem2 ', '', d)} \
    ${@oe.utils.conditional('DEBUG_BUILD', '1', 'net-tools', '', d)} \
    ${@oe.utils.conditional('DEBUG_BUILD', '1', 'leproperties', '', d)} \
    ${@oe.utils.conditional('DEBUG_BUILD', '1', 'procrank', '', d)} \
    ethtool \
    mtd-utils \
    chrony \
    chronyc \
    ethtool \
    iproute2 \
    procps \
    logcat \
    logd \
    "

RDEPENDS:packagegroup-qti-telematics-vnw = "\
    ${@oe.utils.conditional('OPENAVB', 'True', 'open-avb', '', d)} \
    ${@oe.utils.conditional('PTPVIRT', 'True', 'ptp-virtual', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', '', 'start-scripts-init-can can-utils', d)} \
    ${@bb.utils.contains('MACHINE', 'sa515m', 'vnw-eth-switch', '', d)} \
    ${@oe.utils.conditional('QTI_CAN', 'True', 'qti-can-kernel can-kernel-devicetree', '', d)} \
    can-utils \
    "

RDEPENDS:packagegroup-qti-telematics-mvm = "\
    mvm-dlkm \
    "

RDEPENDS:packagegroup-qti-telematics-nad-core = "\
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-stream-update', 'stream-update', '', d)} \
    "

