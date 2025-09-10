DESCRIPTION = "Systemd machine units for ext4 image"
#include qti-systemd-machine-units.inc
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

inherit systemd
FILESPATH =+ "${WORKSPACE}:systemd-machine-uints-ext4"
PE="1"
SRC_URI += "file://firmware.mount"
SRC_URI += "file://persist.mount"
SRC_URI += "file://data.mount"
SRC_URI += "file://systemrw.mount"
SRC_URI += "file://cache.mount"

IMAGETYPE = "ext4"

do_install() {
    install -d ${D}${systemd_unitdir}
    install -m 0644 ${WORKDIR}/firmware.mount -D ${D}${systemd_unitdir}/system/firmware.mount
    install -m 0644 ${WORKDIR}/persist.mount -D ${D}${systemd_unitdir}/system/persist.mount
    install -m 0644 ${WORKDIR}/data.mount -D ${D}${systemd_unitdir}/system/data.mount
    install -m 0644 ${WORKDIR}/systemrw.mount -D ${D}${systemd_unitdir}/system/systemrw.mount
    install -m 0644 ${WORKDIR}/cache.mount -D ${D}${systemd_unitdir}/system/cache.mount
    install -d ${D}${systemd_unitdir}/system/local-fs.target.wants
    ln -sf ${systemd_unitdir}/system/firmware.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/firmware.mount
    ln -sf ${systemd_unitdir}/system/cache.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/cache.mount
    ln -sf ${systemd_unitdir}/system/persist.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/persist.mount
    ln -sf ${systemd_unitdir}/system/data.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/data.mount
    ln -sf ${systemd_unitdir}/system/systemrw.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/systemrw.mount
}
FILES:${PN} += "${systemd_unitdir}/*"
