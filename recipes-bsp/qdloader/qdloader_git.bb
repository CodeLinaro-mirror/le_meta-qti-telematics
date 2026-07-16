inherit pkgconfig qprebuilt

DESCRIPTION = "Bitbake recipe for QDL application. QDL is used to flash image \
using Sahara protocol / Firehose protocol."
HOMEPAGE = "https://git.codelinaro.org/explore/"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "glib-2.0 libxml2 libusb1"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://vendor/qcom/opensource/qdloader"
SRC_DIR = "${WORKSPACE}/vendor/qcom/opensource/qdloader"
S = "${UNPACKDIR}/vendor/qcom/opensource/qdloader"

do_install:append() {
    install -d ${D}/usr/sbin/
    install -m 0555 ${S}/qdl ${D}/usr/sbin/qdl
}
