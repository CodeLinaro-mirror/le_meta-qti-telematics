SUMMARY = "idl tool to generate source file from aidl interface file"
inherit native autotools pkgconfig
PR = "r0"

DESCRIPTION = "\
.aidl files are introduced by android for IPC between two process.\
This tool enables aidl bin which generates interface files from .aidl,\
 compiler doesnt understand .aidl file. This is tool is enabled as part of \
enabling stream update feature on LE. Stream update is android solution for update \
and it uses .aidl files for IPC"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS += "bzip2-replacement-native libdivsufsort-native libmincrypt-native bison-native flex-native glib-2.0-native \
             zlib-native libcutils-native liblog-native libbase-native libsparse-native"

DEPENDS:class-native += "aidl-lib-native"

EXTRA_OECONF:append = "BISON=true"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://system/tools/aidl/src/"

S = "${UNPACKDIR}/system/tools/aidl/src/"

BBCLASSEXTEND = "native"

RM_WORK_EXCLUDE += "${PN}"


PACKAGES += "${PN}-bin"
FILES:${PN}-bin += "${bindir}"
