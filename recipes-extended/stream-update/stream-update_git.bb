SUMMARY = "stream update engine daemon"
DESCRIPTION = "\
update engine daemon support fota update for full AB systems \
update can be applied in small chunks removing dependency for space \
required for update operation"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "glib-2.0 libmincrypt-native fsmgr oem-recovery libsparse bison-native curl bzip2 e2fsprogs zlib xz lzo lz4 liblog libbspatch libxz libbrillo protobuf libalzma libbinderwrapper openssl binderstreaming libevent libchrome protobuf-native aidl-native nad-mtd-al nad-ubi-al nad-ab-al"
DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'ab-boot-support', 'abctl', '', d)}"
DEPENDS:class-native = "glib-2.0-native libmincrypt-native fsmgr-native libsparse bison-native curl bzip2 e2fsprogs zlib xz lzo lz4 liblog libbspatch libxz libbrillo protobuf libalzma libbinderwrapper openssl binderstreaming-native libevent libchrome protobuf-native aidl-native"
PR = "r0"
SRC_URI = "file://OTA/streaming/system/update_engine/ \
           file://stream-update.service \
          "
S = "${UNPACKDIR}/OTA/streaming/system/update_engine/"
SYSTEMD_SERVICE:${PN} = "stream-update.service"

inherit autotools-brokensep pkgconfig systemd useradd

EXTRA_OECONF:append = " --with-glib"
EXTRA_OECONF:append = " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'TARGET_SUPPORTS_AB=true', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'TARGET_NAND_BOOT=true', '', d)}"

FILES:${PN} += "/${userfsdatadir}"
do_compile:prepend () {
   echo "Running interface generation"
   ${S}/update_metadata_proto.sh
   ${S}/update_aidl_interface.sh
}

BBCLASSEXTEND = "native"

STREAM_UPDATE_EXTRA_INCLUDES = " \
    -I${STAGING_INCDIR}/libchrome \
    -I${STAGING_INCDIR}/libbrillo \
    -I${STAGING_INCDIR}/recovery \
    -I${STAGING_INCDIR}/libxz \
    -I${STAGING_INCDIR}/binderstreaming \
"

CPPFLAGS:append = " ${STREAM_UPDATE_EXTRA_INCLUDES}"
CXXFLAGS:append = " ${STREAM_UPDATE_EXTRA_INCLUDES}"

do_install:append:class-target() {
   install -d ${D}${userfsdatadir}
   install -m 0755 ${S}/update_engine_sideload -D ${D}/usr/bin/update_engine_sideload
   install -d ${D}${sysconfdir}/initscripts/
   install -m 0555 ${S}/start_update_engine -D ${D}${sysconfdir}/initscripts/start_update_engine
   install -d ${D}${systemd_unitdir}/system/
   install -m 0644 ${UNPACKDIR}/stream-update.service -D ${D}${systemd_unitdir}/system/stream-update.service
}
FILESPATH =+ "${WORKSPACE}:"
FILES:${PN} += "${systemd_unitdir}/system/* ${userfsdatadir}/stream_update/*"
