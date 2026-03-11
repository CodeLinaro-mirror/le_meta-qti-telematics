#Add qti specific changes only when QTI Distro is enabled.

FILESEXTRAPATHS:prepend := "${THISDIR}/systemd-machine-units:"

S = "${WORKDIR}"

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
        if [[ "${IMAGETYPE}" == "ubi"  || "${IMAGETYPE}" == "ext4"  || "{IMAGETYPE}" == "squashfs" ]] ; then
		if [[ "$mountname" == "firmware" ]]; then
			install -m 0644 ${S}/${mountname}-mount.service ${D}${systemd_unitdir}/system/${mountname}-mount.service
			ln -sf ${systemd_unitdir}/system/${mountname}-mount.service ${D}${systemd_unitdir}/system/local-fs.target.wants/${mountname}-mount.service
		elif [[ "$mountname" == "cache"  ||  "$mountname" == "persist" ]] ; then
			install -m 0644 ${S}/var-${mountname}.mount -D ${D}${systemd_unitdir}/system/var-${mountname}.mount
			ln -sf ${systemd_unitdir}/system/var-${mountname}.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/var-${mountname}.mount
		elif [[ "$mountname" == "systemrw"  || "$mountname" == "data" ]]; then
			install -m 0644 ${S}/${mountname}.mount -D ${D}${systemd_unitdir}/system/${mountname}.mount
			ln -sf ${systemd_unitdir}/system/${mountname}.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/${mountname}.mount
		elif [[ "$mountname" == "isim" ]]; then
			install -m 0644 ${S}/${mountname}.mount -D ${D}${systemd_unitdir}/system/${mountname}.mount
			ln -sf ${systemd_unitdir}/system/${mountname}.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/${mountname}.mount
		fi
	fi
    done
}

def get_mnt_services(d):
    services = []
    img = d.getVar("IMAGETYPE")
    slist = d.getVar("MACHINE_MNT_POINTS").split()
    if "/firmware" in slist:
    	services.append("firmware-mount.service")
    for s in slist:
        svc = s.replace("/", "")
        if os.path.exists(oe.path.join(d.getVar("D"), d.getVar("systemd_unitdir"), "system", svc + "-" + img + ".mount")):
            services.append("%s.mount" % svc)
        elif os.path.exists(oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "systemd", "system", svc + "-" + img + ".mount")):
            services.append("%s.mount" % svc)
    return " ".join(services)

SYSTEMD_SERVICE:${PN} += "${@get_mnt_services(d)}"
FILES:${PN} += " ${systemd_unitdir}/*"
PACKAGE_ARCH = "${MACHINE_ARCH}"
