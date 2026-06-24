inherit autotools pkgconfig systemd

DESCRIPTION = "subsystem ramdump"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM += "file://subsystem_ramdump.c;beginline=1;endline=4;md5=e19ba7a648e00191388321a1e8a5c974"

FILESPATH =+ "${WORKSPACE}:"

SRC_URI = "file://ss-restart/subsystem_ramdump/"

S = "${WORKDIR}/ss-restart/subsystem_ramdump"

DEPENDS = "glib-2.0"

EXTRA_OECONF = " --with-glib"

do_install:append() {
    install -Dm 0644 ${S}/subsystem-ramdump.service ${D}${systemd_unitdir}/system/subsystem-ramdump.service
}

SYSTEMD_SERVICE:${PN} = "subsystem-ramdump.service"

FILES:${PN} += "${systemd_unitdir}/system/*"
