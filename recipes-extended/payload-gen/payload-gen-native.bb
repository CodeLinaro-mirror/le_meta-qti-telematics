SUMMARY = "stream update payload bin file generation"
DESCRIPTION = "invoke script file to generate stream update payload bin file"

inherit native
PR = "r0"

DESCRIPTION = "generate stream update interface files"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

DEPENDS += "stream-update-native libsparse-native unzip-native aidl-native"

RDEPENDS:${PN} = "releasetools-native"
SRC_URI = "file://OTA/streaming/system/update_engine/scripts/brillo_update_payload \
            file://OTA/streaming/external/shflags/src/shflags \
            file://gen_full_stream.sh \
           "

S = "${UNPACKDIR}/payload"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    echo "Installing update engine interface files"
    install -m 755 -D ${UNPACKDIR}/gen_full_stream.sh ${D}${bindir}/gen_full_stream.sh
    install -m 755 -D ${UNPACKDIR}/OTA/streaming/system/update_engine/scripts/brillo_update_payload ${D}${bindir}/scripts_brillo_update_payload
    install -m 644 -D ${UNPACKDIR}/OTA/streaming/external/shflags/src/shflags ${D}${bindir}/lib/shflags/shflags
}
FILESPATH =+ "${WORKSPACE}:"
