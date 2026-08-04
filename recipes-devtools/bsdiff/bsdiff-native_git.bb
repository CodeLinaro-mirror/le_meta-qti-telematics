inherit autotools pkgconfig native deploy

PR = "r4"

DESCRIPTION = "bsdiff tool from Android"
LICENSE = "BSD-2-Clause & BSD-3-Clause"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=cb641bc04cda31daea161b1bc15da69f \
    file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9 \
"

DEPENDS += "bzip2-replacement-native libdivsufsort-native"

FILESEXTRAPATHS:prepend := "${WORKSPACE}:"
SRC_URI = "file://OTA/external/bsdiff/"

S = "${UNPACKDIR}/OTA/external/bsdiff"

EXTRA_OECONF = "--with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR_NATIVE}"
EXTRA_OEMAKE += "WORKSPACE=${S}/../../.."

BBCLASSEXTEND = "native"

do_deploy[cleandirs] = "${DEPLOYDIR}/ota-scripts"
do_deploy() {
    install -m 755 ${D}${bindir}/bsdiff ${DEPLOYDIR}/ota-scripts
}
addtask deploy after do_install
