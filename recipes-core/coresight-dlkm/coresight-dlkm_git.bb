inherit systemd

DESCRIPTION = "Coresight DLKM Loader"
PR = "r0"

LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM += "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

FILESPATH =+ "${WORKSPACE}:"

SRC_URI += "file://load_coresight-dlkm.service"
SRC_URI += "file://load_coresight_dlkm"

SYSTEMD_SERVICE:${PN} += "load_coresight-dlkm.service"
FILES:${PN}+="${sysconfdir}/initscripts/load_coresight_dlkm"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
      # Place coresight_load.service in systemd unitdir
      install -d ${D}${systemd_unitdir}/system/
      install -m 0644 ${UNPACKDIR}/load_coresight-dlkm.service  \
          -D ${D}${systemd_unitdir}/system/load_coresight-dlkm.service

      # Place load_coresight_dlkm script in initscripts dir
      install -m 0555 ${UNPACKDIR}/load_coresight_dlkm  \
          -D ${D}${sysconfdir}/initscripts/load_coresight_dlkm
}
