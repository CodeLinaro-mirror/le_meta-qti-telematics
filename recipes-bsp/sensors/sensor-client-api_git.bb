inherit autotools-brokensep pkgconfig

SUMMARY = "sensor client api library"
DESCRIPTION = "The client api provides library interface to the clients"
PR = "r1"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "glib-2.0 sensor-util-lib sensor-socket libcutils sensor-hal-daemon-hdr libsensors"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-service/sensor_client_api"
S = "${UNPACKDIR}/hardware/qcom/sensors/sensor-service/sensor_client_api"

##Entries for VMs
PACKAGECONFIG:append = "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'sensors-vm', '', d)}"
## Both VMs and EAPs will be treated in similar way
PACKAGECONFIG[sensors-vm] = "--with-vm"

EXTRA_OECONF = "--with-core-includes=${WORKSPACE}/system/core/include \
                --with-glib"

