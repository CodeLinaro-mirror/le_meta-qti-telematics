inherit autotools-brokensep pkgconfig

DESCRIPTION = "Sensor Legacy Test App"
PR = "r1"
LICENSE = "BSD-3-Clause & BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9 \
file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause-Clear;md5=7a434440b651f4a472ca93716d01033a"

DEPENDS = "glib-2.0 libsensors libcutils"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-test-app-legacy"
S = "${UNPACKDIR}/hardware/qcom/sensors/sensor-test-app-legacy"
EXTRA_OECONF = "--with-glib \
		--with-core-includes=${WORKSPACE}/system/core/include"
RM_WORK_EXCLUDE += "sensor-testapp-legacy"

