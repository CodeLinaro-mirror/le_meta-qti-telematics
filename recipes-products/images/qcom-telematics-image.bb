SUMMARY = "Auto Telematics Base Image"

LICENSE = "BSD-3-Clause-Clear"

IMAGE_FEATURES += " \
         allow-root-login \
         post-install-logging \
         read-only-rootfs \
         ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'persist-volume', '', d)} \
         ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'modem-volume', '', d)} \
         ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'cache-volume', '', d)} \
        "
inherit core-image features_check extrausers image-adbd
inherit python3native qramdisk dm-verity-initramfs-v4

inherit  ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'selinux-image', '', d)}

QIMGCLASSES += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'qimage-ext4', '', d)}"
QIMGCLASSES += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', 'qimage-isim', '', d)}"
QIMGCLASSES += "${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'qimage-tele-squashfs-ubi', '', d)}"

RM_WORK_EXCLUDE += "${PN}"

inherit ${QIMGCLASSES}
# let's make sure we have a good image..
REQUIRED_DISTRO_FEATURES = "systemd"

CORE_IMAGE_BASE_INSTALL += " \
    kernel-modules \
    packagegroup-qti-telematics \
    packagegroup-qti-core \
    packagegroup-qti-ss-mgr \
    packagegroup-qcom-securemsm \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', 'packagegroup-qti-data', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location packagegroup-qti-location-auto', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-audio', 'packagegroup-qcom-audio', '', d)} \
    packagegroup-qcom-ppat \
    binder \
    packagegroup-qti-telsdk \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wlan', 'packagegroup-qti-wlan', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', 'packagegroup-qti-bt', '', d)} \
    diag-reboot-app \
    post-boot \
"

DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'ext4-utils-native', '', d)}"
DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'mtd-utils-native', '', d)}"
IMAGE_FSTYPES:remove = "ostree"

ROOTFS_POSTPROCESS_COMMAND += "do_create_rootdir"

do_create_rootdir() {
    mkdir -p ${IMAGE_ROOTFS}/home/root
}

IMAGE_INSTALL += "${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', ' initscripts-automount-sdcard', '', d)}"
IMAGE_FEATURES:append:sa535m = " \
        ${@oe.utils.conditional('DEBUG_BUILD', '1', 'empty-root-password serial-autologin-root', '', d )} \
"

EMMC_BOOT = "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'True', 'False', d)}"
NAND_BOOT = "${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'True', 'False', d)}"

python () {
    bb.build.addtask('do_merge_dtbs', 'do_makeboot', bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'do_makesystem_ubi', 'do_makesystem', d), d)
}

do_merge_dtbs() {
    install -d ${DEPLOY_DIR_IMAGE}/dtbs/
    if [ ! -f ${DEPLOY_DIR_IMAGE}/combined-dtb.dtb ]; then
        bbfatal "do_merge_dtbs: ${DEPLOY_DIR_IMAGE}/combined-dtb.dtb not found. Ensure linux-qcom-mergedtb:do_deploy completed successfully."
    fi
    cat ${DEPLOY_DIR_IMAGE}/combined-dtb.dtb > ${DEPLOY_DIR_IMAGE}/dtbs/dtb.img
}

do_merge_dtbs[depends] += "virtual/kernel:do_deploy"
do_merge_dtbs[depends] += "linux-qcom-mergedtb:do_deploy"

# Place all files needed to flash the device in DEPLOY_DIR_NAME/IMAGE_BASENAME.
# As they can't be directly installed into this path from actual recipes,
# use do_deploy_fixup task and copy them here.
do_deploy_fixup[dirs] = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}"
do_deploy_fixup[cleandirs] = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}"
do_deploy_fixup[depends] += "virtual/kernel:do_deploy"
do_deploy_fixup[deptask] += "do_image_complete"

do_deploy_fixup[nostamp] = "1"

do_deploy_fixup () {
    if [ "${EMMC_BOOT}" = "True" ]; then
        install -m 0644 ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/sysfs.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/sysfs.img
	install -m 0644 ${BOOTIMGDEPLOYDIR}/qcom-telematics-image/boot.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/boot.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/vmlinux ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/vmlinux
        install -m 0644 ${DEPLOY_DIR_IMAGE}/abl.elf ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/abl.elf
        install -m 0644 ${DEPLOY_DIR_IMAGE}/userdata.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/userdata.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/userdata.map ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/userdata.map
        install -m 0644 ${DEPLOY_DIR_IMAGE}/persist.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/persist.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/cache.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/cache.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/systemrw.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/systemrw.img
        if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', 'true', 'false', d)} ; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/isim.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/isim.img
        fi
     elif [ "${NAND_BOOT}" = "True" ]; then
        mkdir -p ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/squashfs
        mkdir -p ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs

	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/sysfs.ubi ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs/sysfs.ubi
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/sysfs.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs/sysfs.ubifs
	install -m 0644  ${BOOTIMGDEPLOYDIR}/qcom-telematics-image/boot.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/boot.img
	install -m 0644  ${DEPLOY_DIR_IMAGE}/vmlinux ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/vmlinux
	install -m 0644  ${DEPLOY_DIR_IMAGE}/abl.elf ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/abl.elf
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/systemrw.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs/systemrw.ubifs
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/squashfs/sysfs.squash ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/squashfs/sysfs.squash
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/userfs.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs/userfs.ubifs
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/cache.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs/cache.ubifs
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/persist.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/ubifs/persist.ubifs
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/squashfs/sysfs-squashfs_ab.ubi ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/squashfs/sysfs-squashfs_ab.ubi
	install -m 0644  ${WORKDIR}/deploy-qcom-telematics-image-image-complete/${IMAGE_BASENAME}/squashfs/squashfs_ubinize_ab.cfg ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/squashfs/squashfs_ubinize_ab.cfg
        if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', 'true', 'false', d)} ; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/isim.ubi ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/isim.ubi
        fi
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "add_target_and_symlink;update_usb_composition;gen_buildprop; "

add_target_and_symlink() {
    echo "${MACHINE}" > ${IMAGE_ROOTFS}/target
    install -d ${IMAGE_ROOTFS}/lib/firmware
    ln -sf /firmware/image ${IMAGE_ROOTFS}/lib/firmware/image
}

# Update usb composition
USBCOMPOSITION ??= "90DB"
update_usb_composition() {
    if [ -e ${IMAGE_ROOTFS}/etc/usb/boot_hsusb_comp ]; then
        echo ${USBCOMPOSITION} > ${IMAGE_ROOTFS}/etc/usb/boot_hsusb_comp
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "create_required_dir;"

create_required_dir() {
    mkdir -p ${IMAGE_ROOTFS}/firmware
    mkdir -p ${IMAGE_ROOTFS}/data
    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', 'true', 'false', d)} ; then
        mkdir -p ${IMAGE_ROOTFS}/isim
    fi
}
gen_buildprop() {
   echo ro.build.version.release=${BUILDNAME} >> ${IMAGE_ROOTFS}/build.prop
   echo ro.product.name=${BASEMACHINE}-${DISTRO} >> ${IMAGE_ROOTFS}/build.prop
}

do_rootfs[depends] += "binutils-cross-${TARGET_ARCH}:do_populate_sysroot"

strip_kernel_modules() {
    strip_bin="${RECIPE_SYSROOT_NATIVE}/usr/bin/${TARGET_SYS}/${KERNEL_STRIP}"

    if [ ! -x "${strip_bin}" ]; then
        bbfatal "Strip executable not found: ${strip_bin}"
    fi

    find "${IMAGE_ROOTFS}" -name "*.ko" | while read -r ko; do
        "${strip_bin}" --strip-debug "${ko}"
    done
}

ROOTFS_POSTPROCESS_COMMAND += "strip_kernel_modules; "

addtask do_deploy_fixup after do_makeboot after do_image_complete before do_build
