SUMMARY = "implement the Precision Time Protocol(ptp) virtual driver"
DESCRIPTION = "Precision Time Protocol(ptp) virtual driver leverage the share memory machanism to sync the gptp timestamp between Host and GVM"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=801f80980d171dd6425610833a22dbe6"
DEPENDS = "virtual/kernel"

PR = "r1"

SRC_URI = "file://external/open-avb/kernel/ptp-virtual/"

S = "${UNPACKDIR}/external/open-avb/kernel/ptp-virtual"

inherit pkgconfig module systemd

FILESPATH =+ "${WORKSPACE}:"

SYSTEMD_SERVICE:${PN} += "ptp_dlkm.service"
do_compile() {

    cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform  && \
    BUILD_CONFIG=${KERNEL_BUILD_CONFIG} \
    EXT_MODULES=../../external/open-avb/kernel/ptp-virtual \
    ROOTDIR=${WORKSPACE}/ \
    MODULE_OUT=${UNPACKDIR}/external/open-avb/kernel/ptp-virtual-out \
    OUT_DIR=${KERNEL_OUT_PATH}/ \
    ./build/build_module.sh
}


do_install() {
    install -d ${D}/usr/lib/modules/

    #Signing and installing the ptp-virtual module
    LD_LIBRARY_PATH=${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/prebuilts/kernel-build-tools/linux-x86/lib64/ \
    ${STAGING_KERNEL_BUILDDIR}/scripts/sign-file sha1 ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.pem \
    ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.x509 ${UNPACKDIR}/external/open-avb/kernel/ptp-virtual-out/ptp_dlkm.ko
    install -m 0755 ${UNPACKDIR}/external/open-avb/kernel/ptp-virtual-out/ptp_dlkm.ko -D ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/ptp.ko

    #Install the ptp_dlkm service file
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${S}/ptp_dlkm.service -D ${D}${systemd_unitdir}/system/ptp_dlkm.service
}

FILES:${PN} += "/usr/lib/"
FILES:${PN} += "${systemd_unitdir}/"
RPROVIDES:${PN} += "ptp-dlkm"
