inherit autotools pkgconfig

SUMMARY = "sensor util lib test application "
DESCRIPTION = "Sensor util test app used to configure hal_config file"
PR = "r1"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

DEPENDS = "sensor-util-lib"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-service/sensor_utils/test_app"
S = "${WORKDIR}/hardware/qcom/sensors/sensor-service/sensor_utils/test_app"

EXTRA_OECONF += "--with-glib"
