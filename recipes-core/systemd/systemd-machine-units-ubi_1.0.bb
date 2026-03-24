DESCRIPTION = "Systemd machine units for ubi image"

include qti-systemd-machine-units.inc

LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

inherit systemd
FILESPATH =+ "${WORKSPACE}:systemd-machine-units-ubi"


SRC_URI += "file://firmware-mount.service"
SRC_URI += "file://firmware-ubi-mount.sh"
SRC_URI += "file://non-hlos-squash.sh"
SRC_URI += "file://var-persist.mount"
SRC_URI += "file://data.mount"
SRC_URI += "file://systemrw.mount"
SRC_URI += "file://systemrw.conf"
SRC_URI += "file://var-cache.mount"
SRC_URI += "file://var-volatile.mount"


SRC_URI:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', 'file://isim_ubi_mount.service file://isim-ubi-mount.sh file://isim.mount', '', d)}"

IMAGETYPE = "ubi"


do_install() {
    install -d ${D}${sysconfdir}/initscripts
    install -d 0644 ${D}${systemd_unitdir}/system
    install -d 0755 ${D}${systemd_unitdir}/system/local-fs.target.wants
#Uncomment if ubi filesystem needs to be enabled
#    install -m 0644 ${WORKDIR}/firmware-ubi-mount.sh ${D}${sysconfdir}/initscripts/firmware-mount.sh
    install -m 0644 ${WORKDIR}/non-hlos-squash.sh ${D}${sysconfdir}/initscripts/firmware-mount.sh
    install -m 0744 ${S}/systemrw.conf ${D}${systemd_system_unitdir}/systemrw-ubi.conf
    install -m 0644 ${WORKDIR}/var-volatile.mount \
            ${D}${systemd_unitdir}/system/var-volatile.mount

    ln -sf ${systemd_unitdir}/system/var-volatile.mount \
           ${D}${systemd_unitdir}/system/local-fs.target.wants/var-volatile.mount

    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', 'true', 'false', d)}; then
        install -m 0755 ${WORKDIR}/isim-ubi-mount.sh ${D}${sysconfdir}/initscripts/isim-ubi-mount.sh
    fi
}
