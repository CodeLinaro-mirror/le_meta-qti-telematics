#Add qti specific changes only when QTI Distro is enabled.

FILESEXTRAPATHS:prepend := "${THISDIR}/systemd-machine-units:"

S = "${UNPACKDIR}"

IMAGETYPE ??= ""

do_install:append () {
    install -d 0644 ${D}${sysconfdir}/initscripts
    install -d 0644 ${D}${systemd_unitdir}
    install -d 0644 ${D}${systemd_unitdir}/system
    install -d 0644 ${D}${systemd_unitdir}/system/local-fs.target.requires
    install -d 0755 ${D}${systemd_unitdir}/system/local-fs.target.wants
    install -d 0644 ${D}${systemd_unitdir}/system/sysinit.target.wants
    install -d 0644 ${D}${systemd_unitdir}/system/multi-user.target.wants

    add_mount_files
}

add_mount_files () {

    for entry in ${MACHINE_MNT_POINTS}; do
        mountname="${entry:1}"
        # Replace "/" with "-" for systemd to understand mount unit.
        mountname=${mountname//'/'/"-"}
        if [[ "${IMAGETYPE}" == "ubi"  || "${IMAGETYPE}" == "ext4"  || "${IMAGETYPE}" == "squashfs" ]] ; then
                if [[ "$mountname" == "firmware" ]]; then
                      install -m 0644 ${S}/${mountname}-mount.service ${D}${systemd_unitdir}/system/${mountname}-mount.service
                elif [[ "$mountname" == "cache"  ||  "$mountname" == "persist" ]] ; then
                        install -m 0644 ${S}/var-${mountname}.mount -D ${D}${systemd_unitdir}/system/var-${mountname}.mount
                elif [[ "$mountname" == "systemrw"  || "$mountname" == "data" ]]; then
                        install -m 0644 ${S}/${mountname}.mount -D ${D}${systemd_unitdir}/system/${mountname}.mount
        elif [[ "$mountname" == "isim" ]]; then
            install -m 0644 ${S}/${mountname}.mount -D ${D}${systemd_unitdir}/system/${mountname}.mount
            if ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'true', 'false', d)}; then
                install -m 0644 ${UNPACKDIR}/isim_ubi_mount.service -D ${D}${systemd_unitdir}/system/isim_ubi_mount.service
            fi
        fi
        fi
    done
}

def get_mnt_services(d):
    services = []
    machine_features = (d.getVar("MACHINE_FEATURES") or "").split()
    slist = d.getVar("MACHINE_MNT_POINTS").split()
    if "/firmware" in slist:
    	services.append("firmware-mount.service")
    if "nand-boot" in machine_features and "qti-isim" in machine_features:
        services.append("isim_ubi_mount.service")
    for s in slist:
        svc = s.replace("/", "")
        # Match the actual unit filenames installed by add_mount_files()
        # - cache/persist are installed as var-cache.mount / var-persist.mount
        # - systemrw/data/isim are installed as systemrw.mount / data.mount / isim.mount
        if svc in ("cache", "persist"):
            unitfile = "var-%s.mount" % svc
            unitname = unitfile
        else:
            unitfile = "%s.mount" % svc
            unitname = unitfile

        # Check both packaged unit locations
        if os.path.exists(oe.path.join(d.getVar("D"), d.getVar("systemd_unitdir"), "system", unitfile)):
            services.append(unitname)
        elif os.path.exists(oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "systemd", "system", unitfile)):
            services.append(unitname)
    return " ".join(services)

SYSTEMD_SERVICE:${PN} += "${@get_mnt_services(d)}"
FILES:${PN} += " ${systemd_unitdir}/*"
PACKAGE_ARCH = "${MACHINE_ARCH}"
