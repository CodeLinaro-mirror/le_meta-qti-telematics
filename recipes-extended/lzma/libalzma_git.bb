SUMMARY = "library lzma from android required for stream update"
DESCRIPTION = "stream update uses decoder which are part of this library during stream update process"

LICENSE = "PD"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
PD;md5=b3597d12946881e13cb3b548d1173851"

DEPENDS += "bzip2-replacement-native libdivsufsort-native curl openssl libmodpb64 libcutils"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/lzma/C/"

S = "${UNPACKDIR}/OTA/streaming/external/lzma/C/"

BBCLASSEXTEND = "native"

do_install:append() {
    install -d ${D}${includedir}/

    if ls ${S}/*.h >/dev/null 2>&1; then
        install -m 0644 ${S}/*.h ${D}${includedir}/
    else
        bbwarn "LZMA headers not found under ${S}"
    fi
}

inherit autotools pkgconfig
