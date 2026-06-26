SUMMARY = "libbrillo library from android"
DESCRIPTION = "\
libbrillo support file_stream fetch and read from payload bin operations"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "openssl libmodpb64 liblog libchrome binderstreaming nad-mtd-al nad-ubi-al"
DEPENDS:class-native = "curl-native libchrome-native binderstreaming-native openssl-native"


PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/libbrillo/"

S = "${UNPACKDIR}/OTA/streaming/external/libbrillo/"

BBCLASSEXTEND = "native"

EXTRA_OECONF:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'TARGET_NAND_BOOT=true', '', d)}"

inherit autotools pkgconfig
