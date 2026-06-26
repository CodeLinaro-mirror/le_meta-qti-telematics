DESCRIPTION = "Start up script for setting up the can link"
HOMEPAGE = "http://codeaurora.org"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause-Clear;md5=7a434440b651f4a472ca93716d01033a"
LICENSE = "BSD-3-Clause-Clear"
inherit update-rc.d systemd

SRC_URI += "file://init-can.sh"
SRC_URI += "file://61-can.rules"
SRC_URI  += "file://init-can.service"

S = "${UNPACKDIR}"
SRC_DIR = "${THISDIR}"

PR = "r2"

INITSCRIPT_NAME = "init-can.sh"
INITSCRIPT_PARAMS = "start 45 5 . stop 3 0 1 6 ."

do_compile[noexec] = "1"

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/etc/initscripts/
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
        install -m 0555 ${UNPACKDIR}/init-can.sh -D ${D}${sysconfdir}/initscripts/init-can.sh
        install -m 0644 ${UNPACKDIR}/init-can.service -D ${D}${systemd_unitdir}/system/init-can.service

        # enable the service for multi-user.target
        ln -sf ${systemd_unitdir}/system/init-can.service ${D}${systemd_unitdir}/system/multi-user.target.wants/init-can.service
    else
        install -d ${D}${sysconfdir}/init.d/
        install -m 0555 ${UNPACKDIR}/${INITSCRIPT_NAME} -D ${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}
    fi
}

FILES:${PN} += "${systemd_unitdir}/system/*"
