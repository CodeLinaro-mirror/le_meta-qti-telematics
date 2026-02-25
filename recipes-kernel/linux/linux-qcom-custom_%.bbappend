# Prepend to do_install: copy initramfs scripts and prepare directories
RRECOMMENDS:${KERNEL_PACKAGE_NAME}-base = ""

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

    # Copy initramfs scripts again for deploy stage
    cp -a ${S}/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
    cp -a ${B}/usr/gen_init_cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
}
