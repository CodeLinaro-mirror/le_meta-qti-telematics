# Prepend to do_install: copy initramfs scripts and prepare directories

KERNEL_CONFIG_FRAGMENTS:remove = " ${S}/arch/arm64/configs/qcom_addons.config"
KERNEL_CONFIG_FRAGMENTS:remove = " ${@oe.utils.vartrue('DEBUG_BUILD', '${S}/arch/arm64/configs/qcom_debug.config', '', d)}"
KERNEL_CONFIG_FRAGMENTS:remove = " ${@oe.utils.vartrue('DEBUG_BUILD', '${S}/arch/arm64/configs/qcom_addons_debug.config', '', d)}"

do_install:prepend() {
    # Prepare build-artifacts directories
    install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
    install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/

    # Copy initramfs helper scripts
    cp -a ${S}/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
    cp -a ${B}/usr/gen_init_cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
}

# Append to do_deploy: copy DTBs and scripts to deploy directories
do_deploy:append() {
    install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
    install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
    install -d ${DEPLOY_DIR_IMAGE}/dtbs/

    # Copy initramfs scripts again for deploy stage
    cp -a ${S}/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
    cp -a ${B}/usr/gen_init_cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
}
