DESCRIPTION = "Systemd machine units for ubi image"

include qti-systemd-machine-units.inc

LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

inherit systemd
FILESPATH =+ "${WORKSPACE}:systemd-machine-uints-ubi"


SRC_URI += "file://firmware-mount.service"
SRC_URI += "file://firmware-ubi-mount.sh"
SRC_URI += "file://var-persist.mount"
SRC_URI += "file://data.mount"
SRC_URI += "file://systemrw.mount"
SRC_URI += "file://systemrw.conf"
SRC_URI += "file://var-cache.mount"

IMAGETYPE = "ubi"


do_install() {
    install -d ${D}${sysconfdir}/initscripts
    install -d 0644 ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/firmware-ubi-mount.sh ${D}${sysconfdir}/initscripts/firmware-ubi-mount.sh
    install -m 0744 ${S}/systemrw.conf ${D}${systemd_system_unitdir}/systemrw-ubi.conf

 

}
