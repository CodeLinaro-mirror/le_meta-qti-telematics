inherit systemd externalsrc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:qcom = " \
    file://automountsdcard.rules \
    file://automountsdcard.sh \
    file://sdcard-mount@.service \
    file://coresight_reset_source_sink.sh \
    file://log-restrict.service \
    file://logging-restrictions.sh \
"

do_install:append:qcom() {
    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    install -d ${D}${sysconfdir}/initscripts/

    # log-restrict
    install -m 0755 ${UNPACKDIR}/logging-restrictions.sh -D ${D}${sysconfdir}/initscripts/log_restrict.sh
    install -m 0644 ${UNPACKDIR}/log-restrict.service -D ${D}${systemd_unitdir}/system/log-restrict.service
    ln -sf ${systemd_unitdir}/system/log-restrict.service ${D}${systemd_unitdir}/system/multi-user.target.wants/log-restrict.service
    ln -sf ${systemd_unitdir}/system/log-restrict.service ${D}${systemd_unitdir}/system/ffbm.target.wants/log-restrict.service

    # automount sdcard
    install -d ${D}${libdir}/udev/rules.d
    install -m 0644 ${UNPACKDIR}/automountsdcard.rules ${D}${libdir}/udev/rules.d/automountsdcard.rules
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/automountsdcard.sh ${D}${bindir}/automountsdcard.sh
    install -m 0755 ${UNPACKDIR}/sdcard-mount@.service ${D}${systemd_unitdir}/system/sdcard-mount@.service
}

S = "${UNPACKDIR}"

INITSCRIPT_PACKAGES =+ "${PN}-log-restrict"
INITSCRIPT_NAME:${PN}-log-restrict = "log_restrict.sh"
INITSCRIPT_PARAMS:${PN}-log-restrict = "start 99 2 3 4 5 ."
INITSCRIPT_PARAMS:${PN}-log-restrict += "stop 1 0 1 6 ."

PACKAGES =+ "${PN}-log-restrict"
FILES:${PN}-log-restrict += "${systemd_unitdir}/system/log-restrict.service ${systemd_unitdir}/system/multi-user.target.wants/log-restrict.service ${systemd_unitdir}/system/ffbm.target.wants/log-restrict.service ${sysconfdir}/initscripts/log_restrict.sh"

PACKAGES =+ "${PN}-automount-sdcard"
FILES:${PN}-automount-sdcard =+ "${libdir}/udev/rules.d/automountsdcard.rules ${bindir}/automountsdcard.sh ${systemd_unitdir}/system/sdcard-mount@.service"
