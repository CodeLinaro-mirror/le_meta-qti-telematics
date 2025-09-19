DESCRIPTION = "Systemd machine units for ubi image"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=7a434440b651f4a472ca93716d01033a"

inherit systemd
FILESPATH =+ "${WORKSPACE}:systemd-machine-uints-ubi"


SRC_URI += "file://firmware_ubi_mount.service"
SRC_URI += "file://firmware-ubi-mount.sh"


do_install() {
    install -d ${D}${systemd_unitdir}
    install -d ${D}${sysconfdir}/initscripts
for entry in ${MACHINE_MNT_POINTS}; do
     mountname="${entry:1}"
    if [[ "$mountname" == "firmware" ]] ; then
        install -m 0644 ${WORKDIR}/firmware_ubi_mount.service -D ${D}${systemd_unitdir}/system/firmware_ubi_mount.service
        install -m 0644 ${WORKDIR}/firmware-ubi-mount.sh ${D}${sysconfdir}/initscripts/firmware-ubi-mount.sh
        install -d ${D}${systemd_unitdir}/system/local-fs.target.wants
        ln -sf ${systemd_unitdir}/system/firmware_ubi_mount.service ${D}${systemd_unitdir}/system/local-fs.target.wants/firmware_ubi_mount.service
    fi
done
}
FILES:${PN} += "${systemd_unitdir}/*"
FILES:${PN} += "${sysconfdir}/*"
