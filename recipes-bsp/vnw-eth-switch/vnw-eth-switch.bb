SUMMARY = "Ethernet Switch Driver"
DESCRIPTION = "An utility to insert ethernet switch driver module into the kernel"
LICENSE = "GPL-2.0-with-Linux-syscall-note & BSD-3-Clause & BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

inherit module systemd

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://vnw-eth-sw-kernel/"

S = "${UNPACKDIR}/vnw-eth-sw-kernel/"

SYSTEMD_SERVICE:${PN} += "vnw_eth_switch.service"

do_install() {
    module_do_install
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then

        #Install systemd service unit file [Ethernet switch Service]
        install -d ${D}${systemd_unitdir}/system/
        install -m 0644 ${UNPACKDIR}/vnw-eth-sw-kernel/vnw_eth_switch.service \
                     -D ${D}${systemd_unitdir}/system/vnw_eth_switch.service
    fi
}
