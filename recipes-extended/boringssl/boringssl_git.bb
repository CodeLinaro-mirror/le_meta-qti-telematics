SUMMARY = "library from android for stream update secure update"
DESCRIPTION = "${SUMMARY}"
LICENSE = "OpenSSL"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
OpenSSL;md5=4eb1764f3e65fafa1a25057f9082f2ae"

DEPENDS += "bzip2-replacement-native libdivsufsort-native curl"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/boringssl/"

S = "${UNPACKDIR}/OTA/streaming/external/boringssl/"

BBCLASSEXTEND = "native"

inherit autotools pkgconfig
