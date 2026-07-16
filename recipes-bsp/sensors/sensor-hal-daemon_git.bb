inherit autotools systemd pkgconfig useradd

SUMMARY = "sensor hal daemon service"
DESCRIPTION = "This recipe compiles sensor service and configuration files"
PR = "r1"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS = "glib-2.0 libsensors sensor-util-lib sensor-socket powermanager-lib open-avb"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://hardware/qcom/sensors/sensor-service/sensor_hal_daemon"
SRC_URI +="file://sensor_hal_daemon.service"
SRC_URI +="file://sensor_hal_daemon-tmpfilesd.conf"
SRC_URI +="file://sensors.conf"
SRC_URI +="file://hal_config"
S = "${UNPACKDIR}/hardware/qcom/sensors/sensor-service/sensor_hal_daemon"

PACKAGECONFIG:append:sa515m = " shd"
PACKAGECONFIG:append:sa415m = " shd"
PACKAGECONFIG:append:mdm9607 = " shd"

EXTRA_OECONF = "--with-core-includes=${WORKSPACE}/system/core/include \
                --with-pwrmgrlib \
                --with-gptp \
                --with-glib"

SYSTEMD_SERVICE:${PN} = "sensor_hal_daemon.service"
SYSTEMD_SERVICE:${PN}:remove:mdm9607 = "sensor_hal_daemon.service"

FILES:${PN} += "${userfsdatadir}/sensorhal"
RDEPENDS:${PN} = "open-avb"

do_install:append () {

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        ## Install systemd-tmpfiles config file
        install -d ${D}${sysconfdir}/tmpfiles.d/
        install -m 0644 ${UNPACKDIR}/sensor_hal_daemon-tmpfilesd.conf ${D}${sysconfdir}/tmpfiles.d/${BPN}.conf

        ## Install systemd service unit file
        install -d ${D}${sysconfdir}/systemd/system/
        install -m 0644 ${UNPACKDIR}/sensor_hal_daemon.service -D ${D}${sysconfdir}/systemd/system/sensor_hal_daemon.service

	install -m 0644 -D -o 3011 -g 3011 ${UNPACKDIR}/sensors.conf  ${D}${sysconfdir}/sensors.conf
        install -d -m 0755 -o 3011 -g 3011 ${D}${sysconfdir}/sensorhal/
        install -m 0664 -D -o 3011 -g 3011 ${UNPACKDIR}/hal_config  ${D}${sysconfdir}/sensorhal/hal_config
    fi

    if ${@bb.utils.contains('PACKAGECONFIG', ' shd', 'true', 'false', d)}; then
        sed -i 's/SENSOR_HAL_LIB_PATH=\/usr\/lib\/libasm330sensors.so.1.0.0/#SENSOR_HAL_LIB_PATH=\/usr\/lib\/libasm330sensors.so.1.0.0/1' ${D}${sysconfdir}/sensors.conf
    fi
}

do_install:append:sa525m() {
        # remove telaf from sensor service for emmc target
        if ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'true', 'false', d)}; then
            sed -i 's/telaf//' ${D}${sysconfdir}/systemd/system/sensor_hal_daemon.service
        fi
}
