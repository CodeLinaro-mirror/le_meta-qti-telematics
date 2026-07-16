SUMMARY = "QTI MVM driver"
DESCRIPTION = "MVM driver takes care of sending the CV2X messages \
for verification to MVM and sending the results back to userspace. \
This driver will be loaded as a module from the userspace"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=801f80980d171dd6425610833a22dbe6"
DEPENDS = "virtual/kernel"

PR = "r1"

SRC_URI = "file://vendor/qcom/opensource/mvm-kernel/"
SRC_URI += "file://mvm.rules"

S = "${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel"

inherit pkgconfig module systemd deploy qdlkm

FILESPATH =+ "${WORKSPACE}:"

SYSTEMD_SERVICE:${PN} += "mvm_dlkm.service"

addtask deploy after do_install

do_compile() {

    cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform  && \
    BUILD_CONFIG=${KERNEL_BUILD_CONFIG} \
    EXT_MODULES=../../vendor/qcom/opensource/mvm-kernel \
    ROOTDIR=${WORKSPACE}/ \
    MODULE_OUT=${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel-out \
    OUT_DIR=${KERNEL_OUT_PATH}/ \
    ./build/build_module.sh
}


do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/

    # Copy unsigned kernel modules
    install -m 0644 ${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel-out/mvm_dlkm.ko ${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel-out/mvm_unsigned.ko

    # Strip debug symbols and sign the module
    sign_strip_module ${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel-out/mvm_dlkm.ko

    install -m 0755 ${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel-out/mvm_dlkm.ko -D ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/mvm.ko

    #Install the mvm_dlkm service file
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${S}/mvm_dlkm.service -D ${D}${systemd_unitdir}/system/mvm_dlkm.service

    #Install udev rules
    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/mvm.rules -D ${D}${sysconfdir}/udev/rules.d/mvm.rules

}

# Copy unsigned kernel modules into image specific deploy directory.
do_deploy() {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-host', 'false', 'true', d)}; then
        install -d ${DEPLOYDIR}/kernel_modules/${PN}
        install -m 0644 ${UNPACKDIR}/vendor/qcom/opensource/mvm-kernel-out/mvm_unsigned.ko ${DEPLOYDIR}/kernel_modules/${PN}/mvm.ko
    fi
}

FILES:${PN} += "${nonarch_base_libdir}/modules/*"
FILES:${PN} += "${sysconfdir}/udev/rules.d/mvm.rules"
RPROVIDES:${PN} += "mvm-dlkm"
RPROVIDES:${PN} += "kernel-module-mvm-${KERNEL_VERSION}"
