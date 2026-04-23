SUMMARY = "iSIM Drivers Kernel Module"

DESCRIPTION = "iSIM driver to interact with iSIM block."

inherit module pkgconfig systemd useradd

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

FILESPATH   =+ "${WORKSPACE}:"
SRC_URI     =  "file://vendor/qcom-opensource/isim-opensource/isim-driver/ \
                file://isim-dlkm.service \
                file://load_isim.sh"

S = "${WORKDIR}/vendor/qcom-opensource/isim-opensource/isim-driver"

RPROVIDES:${PN} += "kernel-module-isim-dlkm-${KERNEL_VERSION}"
RPROVIDES:${PN} += "isim-dlkm"
MAKE_TARGETS = "modules"
MODULES_INSTALL_TARGET = "modules_install"

FILES:${PN} = "${nonarch_base_libdir}/modules/*"
FILES:${PN} += "${sysconfdir}/initscripts/load_isim.sh"
FILES:${PN} += "/isim/isim"

SYSTEMD_SERVICE:${PN} += "isim-dlkm.service"

USERADD_PACKAGES = "${PN}"

#-r = system account, -s /sbin/nologin = no shell/login, -M = no home directory created
USERADD_PARAM:${PN} = "-U -r -s /sbin/nologin -M isim"

do_install:append(){
    install -d ${D}${includedir}/isim_driver
    install -m 0644 ${S}/include/uapi/isim_uapi.h ${D}${includedir}/isim_driver/

    install -d ${D}${libdir}/pkgconfig
    install -m 0644 ${S}/isim_driver.pc ${D}${libdir}/pkgconfig/

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/isim-dlkm.service ${D}${systemd_unitdir}/system/isim-dlkm.service

    install -d ${D}${sysconfdir}/initscripts/
    install -m 0755 ${WORKDIR}/load_isim.sh ${D}${sysconfdir}/initscripts/load_isim.sh

    install -d ${D}/isim
    install -d ${D}/isim/isim/

    # chown: set owner and group
    chown isim:isim ${D}/isim/
    chown isim:isim ${D}/isim/isim/

    # chmod: restrict permissions on a directory
    chmod 750 ${D}/isim
    chmod 750 ${D}/isim/isim/

}
