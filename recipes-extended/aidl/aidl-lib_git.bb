inherit native autotools pkgconfig
PR = "r0"

DESCRIPTION = "\
this library is used in aidl tool, source files which generates \
header file are identified and moved in this library to make sure \
header files are generated before it is actually used in compilation\
"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS += "bzip2-replacement-native libdivsufsort-native libmincrypt-native bison-native flex-native glib-2.0-native libbase"
DEPENDS += "zlib-native libcutils-native liblog-native libbase-native libsparse-native"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://system/tools/aidl/"

EXTRA_OECONF:append = "BISON=true"
S = "${UNPACKDIR}/system/tools/aidl/"
RM_WORK_EXCLUDE += "${PN}"

do_install:append(){
   install -d ${D}${includedir}
   install -m 0644 ${B}/location.hh -D ${D}${includedir}/
   install -m 0644 ${B}/position.hh -D ${D}${includedir}/
}
BBCLASSEXTEND = "native"
FILES:${PN} += "${includedir}/*"
