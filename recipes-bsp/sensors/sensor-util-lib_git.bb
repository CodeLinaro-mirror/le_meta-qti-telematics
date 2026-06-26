inherit autotools pkgconfig

SUMMARY = "sensor util library"
DESCRIPTION = "The provides library interface to the util clients"
PR = "r1"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

DEPENDS = "glib-2.0 libcutils diag libsensors"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-service/sensor_utils/lib"
S = "${UNPACKDIR}/hardware/qcom/sensors/sensor-service/sensor_utils/lib"

EXTRA_OECONF = "--with-core-includes=${WORKSPACE}/system/core/include \
                --with-glib"

