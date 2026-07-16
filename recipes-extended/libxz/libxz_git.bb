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

inherit autotools pkgconfig
