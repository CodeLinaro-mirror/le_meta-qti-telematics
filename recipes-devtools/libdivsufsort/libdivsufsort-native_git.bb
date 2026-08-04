
inherit native autotools-brokensep pkgconfig

PR = "r1"

DESCRIPTION = "libdivsufsort from Android"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${WORKSPACE}:"
SRC_URI = "file://OTA/external/libdivsufsort/"

S = "${UNPACKDIR}/OTA/external/libdivsufsort"

EXTRA_OECONF = "--with-sanitized-headers=${STAGING_INCDIR_NATIVE}/linux-kernel-qcom/usr/include \
                --with-core-headers=${STAGING_INCDIR_NATIVE}"

do_install:append() {
    install -d ${D}${includedir}
    install -m 0644 ${S}/android_include/divsufsort64.h ${D}${includedir}
}
BBCLASSEXTEND = "native"
