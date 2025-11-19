DESCRIPTION = "Systemd machine units for ext4 image"
include qti-systemd-machine-units.inc
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

inherit systemd
FILESPATH =+ "${WORKSPACE}:systemd-machine-uints-ext4"
PE="1"
SRC_URI += "file://var-persist.mount"
SRC_URI += "file://data.mount"
SRC_URI += "file://systemrw.mount"
SRC_URI += "file://var-cache.mount"
SRC_URI += "file://firmware-mount.service"
SRC_URI += "file://firmware-ext4-mount.sh"

IMAGETYPE = "ext4"

do_install() {

    install -d ${D}${sysconfdir}/initscripts
    install -d 0644 ${D}${systemd_unitdir}/system
    install -m 0744 ${WORKDIR}/firmware-ext4-mount.sh ${D}${sysconfdir}/initscripts/firmware-ext4-mount.sh
}
