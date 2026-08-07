FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append += " \
    file://0001-Remove-queuing-mechanism-update-to-fq-codel.patch \
    file://0001-Allow-powermgr-group-to-communicate.patch \
    file://61-pps.rules \
    file://0001-Allow-system-user-to-use-dbus-for-communication.patch \
    file://loc_bootup_iio.sh \
    file://postmss.service \
    file://postmss \
    file://sensor_bootup_iio.sh \
    file://${BASEMACHINE}/ \
    ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'file://mtd.rules', '',d)} \
    file://platform.rules \
    file://platform.conf \
"

PACKAGECONFIG:remove = " \
    acl \
    binfmt \
    hibernate \
    kmod \
    timesyncd \
"

FILES:${PN} += "${sysconfdir}/initscripts ${sysconfdir}/initscripts/*"

do_configure:append() {
    # Disable autostart of systemd-network-generator.service
    sed -i -e "s/enable systemd-network-generator.service/disable systemd-network-generator.service/g" ${S}/presets/90-systemd.preset
}

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -m 0644 ${UNPACKDIR}/61-pps.rules ${D}${sysconfdir}/udev/rules.d/61-pps.rules

        install -m 0644 ${UNPACKDIR}/platform.rules ${D}${sysconfdir}/udev/rules.d/platform.rules

        if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
                install -m 0644 ${UNPACKDIR}/mtd.rules -D ${D}${sysconfdir}/udev/rules.d/mtd.rules
        fi

        install -d ${D}${systemd_unitdir}/system/
        cp -fR ${UNPACKDIR}/${BASEMACHINE}/* ${D}${systemd_unitdir}/system/

        #Install service files and scripts
        install -d ${D}${sysconfdir}/initscripts/
        install -d ${D}${systemd_unitdir}/system/basic.target.wants/

        if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'false', 'true', d)}; then
            install -m 0555 ${UNPACKDIR}/postmss ${D}${sysconfdir}/initscripts/postmss
            install -m 0644 ${UNPACKDIR}/postmss.service ${D}${systemd_unitdir}/system/postmss.service
            ln -sf ${systemd_unitdir}/system/postmss.service \
                    ${D}${systemd_unitdir}/system/basic.target.wants/postmss.service

            rm -rf ${D}${systemd_unitdir}/system/adbd.service.d/adbd-gvm.conf
        fi

        if ${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-vm-guest emmc-boot', 'true', 'false', d)}; then
            rm -rf ${D}${systemd_unitdir}/system/QCMAP_ConnectionManagerd.service.d/QCMAP_ConnectionManagerd-pvm.conf
        fi

        #Install iio bootup script for sensors
        if ${@bb.utils.contains('MACHINE', 'sa515m', 'true', 'false', d)}; then
            install -m 0755 ${UNPACKDIR}/loc_bootup_iio.sh ${D}${sysconfdir}/initscripts/loc_bootup_iio.sh
        else
            install -m 0555 ${UNPACKDIR}/sensor_bootup_iio.sh ${D}${sysconfdir}/initscripts/loc_bootup_iio.sh
        fi

        if [ -f ${D}/lib/udev/rules.d/60-persistent-storage.rules ]; then
            sed -i 's/SUBSYSTEM!="block|ubi", GOTO="persistent_storage_end"/SUBSYSTEM!="block", GOTO="persistent_storage_end"/g' \
                ${D}/lib/udev/rules.d/60-persistent-storage.rules
        elif [ -f ${D}/usr/lib/udev/rules.d/60-persistent-storage.rules ]; then
            sed -i 's/SUBSYSTEM!="block|ubi", GOTO="persistent_storage_end"/SUBSYSTEM!="block", GOTO="persistent_storage_end"/g' \
                ${D}/usr/lib/udev/rules.d/60-persistent-storage.rules
        fi

        install -m 0644 ${UNPACKDIR}/platform.conf -D ${D}${sysconfdir}/tmpfiles.d/platform.conf

    fi
}

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        rm -f ${D}${base_libdir}/udev/ata_id
        rm -f ${D}${base_libdir}/udev/cdrom_id
        rm -f ${D}${base_libdir}/udev/scsi_id
        rm -f ${D}${base_libdir}/udev/v4l_id
        rm -f ${D}${base_libdir}/udev/rules.d/60-cdrom_id.rules
        rm -f ${D}${base_libdir}/udev/rules.d/60-drm.rules
        rm -f ${D}${base_libdir}/udev/rules.d/60-evdev.rules
        rm -f ${D}${base_libdir}/udev/rules.d/60-input_id.rules
        rm -f ${D}${base_libdir}/udev/rules.d/60-persistent-input.rules
        rm -f ${D}${base_libdir}/udev/rules.d/60-persistent-storage-tape.rules
        rm -f ${D}${base_libdir}/udev/rules.d/70-joystick.rules
        rm -f ${D}${base_libdir}/udev/rules.d/70-mouse.rules
        rm -f ${D}${base_libdir}/udev/rules.d/70-touchpad.rules
        rm -f ${D}${base_libdir}/udev/rules.d/71-seat.rules
        rm -f ${D}${base_libdir}/udev/rules.d/73-seat-late.rules
        rm -f ${D}${base_libdir}/udev/rules.d/80-drivers.rules
        rm -f ${D}${sysconfdir}/udev/rules.d/touchscreen.rules
        rm -f ${D}${sysconfdir}/udev/rules.d/mtpserver.rules
        rm -f ${D}${systemd_unitdir}/system/systemd-udev-settle.service
        rm -f ${D}${sysconfdir}/udev/rules.d/ion.rules
        rm -f ${D}${sysconfdir}/udev/rules.d/tui.rules
        rm -f ${D}${sysconfdir}/udev/rules.d/kgsl.rules
        rm -f ${D}${sysconfdir}/udev/rules.d/set-mhi-nodes.rules
        if ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'true', 'false', d)}; then
             rm -f ${D}${sysconfdir}/udev/rules.d/mmc-rpmb.rules
        fi
    fi
}
FILES:${PN} += "${sysconfdir}/udev/rules.d/61-pps.rules"
FILES:${PN} += "${sysconfdir}/udev/rules.d/platform.rules"

ERROR_QA:remove = "patch-status"
