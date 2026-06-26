inherit autotools-brokensep pkgconfig systemd

HOMEPAGE         = "http://codeaurora.org"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause-Clear;md5=7a434440b651f4a472ca93716d01033a"
LICENSE = "BSD-3-Clause-Clear"

DESCRIPTION = "Start up script for zram"

SRC_URI =  "file://zram.service"
SRC_URI += "file://zram-setup"

PR = "r0"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

SYSTEMD_SERVICE:${PN} += "zram.service"

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/initscripts/
        install -d ${D}/etc/systemd/system/
        install -d ${D}/etc/systemd/system/local-fs.target.wants/
        install -d ${D}${base_sbindir}/
        install -m 0744 ${UNPACKDIR}/zram-setup ${D}${base_sbindir}/zram-setup
        install -m 0644 ${UNPACKDIR}/zram.service -D ${D}/etc/systemd/system/zram.service

        # Set SWAP_MEMTOTAL_PCT in conf/machine/<target>.conf to use nondefault value
        val=${@d.getVar('SWAP_MEMTOTAL_PCT', 'true') or ""}
        sed -i -e "s,@SWAP_MEMTOTAL_PCT@,${val},g" ${D}/etc/systemd/system/zram.service

    fi
}

FILES:${PN}  += "${systemd_unitdir}/system/"
PACKAGE_ARCH  = "${MACHINE_ARCH}"
