SUMMARY = "library xz from android required for stream update"
DESCRIPTION = "stream update uses xz compression in payload.bin"

LICENSE = "PD"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
PD;md5=b3597d12946881e13cb3b548d1173851"

DEPENDS += "libmodpb64 liblog libcutils"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/xz-embedded/"

S = "${UNPACKDIR}/OTA/streaming/external/xz-embedded/"

BBCLASSEXTEND = "native"

do_install:append() {
    install -d ${D}${includedir}/linux

    if [ -f ${S}/linux/include/linux/xz.h ]; then
        install -m 0644 ${S}/linux/include/linux/xz.h \
            ${D}${includedir}/linux/xz.h
    else
        bbwarn "linux/xz.h not found at ${S}/linux/include/linux/xz.h"
    fi
}

inherit autotools pkgconfig
