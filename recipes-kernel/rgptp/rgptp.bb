DESCRIPTION = "rgptp client driver"
LICENSE = "GPL-2.0-only & BSD-3-Clause"
LIC_FILES_CHKSUM = "file://rgptp_init.c;\
startline=4;endline=11;md5=f8a4d965e4d68a4dd1340fe615be7db4 \
file://rgptp-start-stop_le;startline=5;endline=28;md5=9af25fa7a8af3640b15d12e6d460f33b"

inherit module systemd

FILESPATH =+ "${THISDIR}/:"
SRC_URI = "file://files"
SRC_URI += "file://rgptp-start-stop_le"
SRC_URI += "file://rgptp.service"

S = "${UNPACKDIR}/files"

do_install() {
    module_do_install
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/initscripts
        install -m 0755 ${UNPACKDIR}/rgptp-start-stop_le ${D}${sysconfdir}/initscripts

        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/

        #RGPTP Service
        install -m 0644 ${UNPACKDIR}/rgptp.service -D ${D}${systemd_unitdir}/system/rgptp.service

        # enable the service for multi-user.target
        #ln -sf ${systemd_unitdir}/system/rgptp.service \
        #        ${D}${systemd_unitdir}/system/multi-user.target.wants/rgptp.service
    fi
}

FILES:${PN} += "${systemd_unitdir}/system/*"
FILES:${PN} += "${sysconfdir}/initscripts/*"
