inherit systemd pkgconfig

SUMMARY = "GPTP"
DESCRIPTION = "Time Sensitive Networking stack Time Sync"
HOMEPAGE = "https://git.codelinaro.org/"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

PR = "r1"

DEPENDS += "glib-2.0 libpcap pciutils cmake-native qmi-framework"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://external/open-avb/ \
		file://gptp-daemon.service \
		file://gptp-daemon-tmpfilesd.conf \
		file://qgptp.rules"

S = "${WORKDIR}/external/open-avb/"

GPTP_AUTO_START_ENABLE= "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'NO', 'YES', d)}"
RGPTP_SRV_INCLUDED= "YES"
RGPTP_CLNT_INCLUDED= "YES"

EXTRA_OEMAKE += "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " SYSTEMD_SUPPORT_INCLUDED=1", " SYSTEMD_SUPPORT_INCLUDED=0", d)}"
EXTRA_OEMAKE += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-host', 'LE_SHARED_MEM=1', 'LE_SHARED_MEM=0', d)}"
EXTRA_OEMAKE += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-tele', 'LE_GVM=1', 'LE_GVM=0', d)}"
EXTRA_OEMAKE += "${@oe.utils.conditional('GPTP_AUTO_START_ENABLE', 'YES', 'GPTP_AUTO_START=1', 'GPTP_AUTO_START=0', d)}"
EXTRA_OEMAKE += "${@oe.utils.conditional('RGPTP_SRV_INCLUDED', 'YES', 'RGPTP_ENABLED=1', 'RGPTP_ENABLED=0', d)}"
EXTRA_OEMAKE += "${@oe.utils.conditional('RGPTP_CLNT_INCLUDED', 'YES', 'RGPTP_CLNT_ENABLED=1', 'RGPTP_CLNT_ENABLED=0', d)}"
SYSTEMD_SERVICE:${PN} = "${@oe.utils.conditional('GPTP_AUTO_START_ENABLE', 'YES', 'gptp-daemon.service', '', d)}"

TARGET_CC_ARCH += "${LDFLAGS}"

do_compile() {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'false', 'true', d)}; then
        oe_runmake gptp
    fi

    oe_runmake libgptp
}

do_install() {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'false', 'true', d)}; then
        install -d ${D}${bindir}
        install -m 0755 ${S}/daemons/gptp/linux/build/obj/qgptp ${D}${bindir}
    fi

    install -d ${D}${libdir}
    install -m 0755 ${S}/lib/libgptp/*.so ${D}${libdir}
    install -d ${D}/${includedir}
    install -m 0644 ${S}/lib/libgptp/gptp_helper.h ${D}${includedir}

    if [ "x${GPTP_AUTO_START_ENABLE}" = "xYES" ]; then
       if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
          install -d ${D}${systemd_unitdir}/system/
          install -m 0644 ${WORKDIR}/gptp-daemon.service -D ${D}${systemd_unitdir}/system/gptp-daemon.service
          install -d ${D}${sysconfdir}/udev/rules.d/
          install -m 0644 ${WORKDIR}/qgptp.rules -D ${D}${sysconfdir}/udev/rules.d/qgptp.rules
          install -d ${D}${sysconfdir}/tmpfiles.d/
          install -m 0644 ${WORKDIR}/gptp-daemon-tmpfilesd.conf ${D}${sysconfdir}/tmpfiles.d/gptp-daemon-tmpfilesd.conf
          install -m 0644 ${S}/daemons/gptp/gptp_cfg_le.ini ${D}${sysconfdir}/gptp_cfg.ini
       fi
    fi
}

RPROVIDES:${PN} += "open-avb"
FILES:SOLIBSDEV = ""
FILES:${PN} += "${bindir}/*"
FILES:${PN} += "${libdir}/*"
FILES:${PN}-dev = "${includedir}"
FILES:${PN} += "${libdir}/libgptp.so"
FILES:${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', '', '${sysconfdir}/gptp_cfg_le.ini', d)}"
FILES:${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', '', '${sysconfdir}/udev/rules.d/qgptp.rules', d)}"
