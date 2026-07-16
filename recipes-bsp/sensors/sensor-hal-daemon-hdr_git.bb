inherit autotools-brokensep pkgconfig

SUMMARY = "sensor hal daemon service headers"
DESCRIPTION = "Provides sensor hal daemon headers"
PR = "r1"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-service/sensor_hal_daemon"
S = "${UNPACKDIR}/hardware/qcom/sensors/sensor-service/sensor_hal_daemon"

# don't run these functions
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${includedir}
    install -m 644 ${S}/src/*.h ${D}${includedir}
}

PACKAGES = "${PN}"
FILES:${PN} += "/usr/include/*"
