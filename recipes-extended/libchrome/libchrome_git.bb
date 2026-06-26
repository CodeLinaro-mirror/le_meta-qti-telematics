SUMMARY = "library chrome from android required for stream update"
DESCRIPTION = "${SUMMARY}"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "bzip2-replacement-native libdivsufsort-native curl libevent liblog libcutils"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/libchrome/"

S = "${UNPACKDIR}/OTA/streaming/external/libchrome/"

BBCLASSEXTEND = "native"
inherit autotools pkgconfig
