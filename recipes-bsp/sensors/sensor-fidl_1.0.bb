inherit autotools-brokensep pkgconfig

SUMMARY = "sensor someip library"
DESCRIPTION = "This establishes someip communication between clients and sensor hal daemon"
PR = "r1"

LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

DEPENDS = "glib-2.0 libcutils common-api-c++ vsomeip common-api-c++-someip"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-service/sensor_fidl"
S = "${WORKDIR}/hardware/qcom/sensors/sensor-service/sensor_fidl"

FILES_${PN} += "${userfsdatadir}/sensorhal"
FILES:${PN} += "/usr/etc/*"
SOLIBS = ".so*"
FILES_SOLIBSDEV = ""
INSANE_SKIP:${PN} = "dev-so"

EXTRA_OECONF = "--with-core-includes=${WORKSPACE}/system/core/include \
		--with-glib"
