SUMMARY = "Auto Telematics Base Image"

LICENSE = "BSD-3-Clause-Clear"

IMAGE_FEATURES += "allow-root-login post-install-logging"

inherit core-image features_check extrausers image-adbd
inherit python3native qramdisk dm-verity-initramfs-v4

QIMGCLASSES += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'qimage-ext4', '', d)}"

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
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'systemd-machine-units-ubi', '', d)} \
    packagegroup-qcom-ppat \
    binder \
    packagegroup-qti-telsdk \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wlan', 'packagegroup-qti-wlan', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', 'packagegroup-qti-bt', '', d)} \
"

DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'ext4-utils-native', '', d)}"

IMAGE_FSTYPES:remove = "ostree"

ROOTFS_POSTPROCESS_COMMAND += "do_create_rootdir"

do_create_rootdir() {
    mkdir -p ${IMAGE_ROOTFS}/home/root
}

IMAGE_FEATURES:append:sa535m = " \
        ${@oe.utils.conditional('DEBUG_BUILD', '1', 'empty-root-password serial-autologin-root', '', d )} \
"

EMMC_BOOT = "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'True', 'False', d)}"

python () {
	bb.build.addtask('do_merge_dtbs', 'do_makeboot', bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'do_makesystem_ubi', 'do_makesystem', d), d)
}

do_merge_dtbs() {
        install -d ${DEPLOY_DIR_IMAGE}/dtbs/
	cat ${DEPLOY_DIR_IMAGE}/combined-dtb.dtb > ${DEPLOY_DIR_IMAGE}/dtbs/dtb.img
}

do_merge_dtbs[depends] += "virtual/kernel:do_deploy"
do_merge_dtbs[depends] += "linux-qcom-mergedtb:do_deploy"

# Place all files needed to flash the device in DEPLOY_DIR_NAME/IMAGE_BASENAME.
# As they can't be directly installed into this path from actual recipes,
# use do_deploy_fixup task and copy them here.
do_deploy_fixup[dirs] = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}"
do_deploy_fixup[cleandirs] = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}"
do_deploy_fixup[depends] += "dtb-qcom-image:do_image_complete"
do_deploy_fixup[depends] += "virtual/kernel:do_deploy"
do_deploy_fixup[deptask] += "do_image_complete"

do_deploy_fixup[nostamp] = "1"

do_deploy_fixup () {
    if [ "${EMMC_BOOT}" = "True" ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/sysfs.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/sysfs.img
        install -m 0644 ${BOOTIMGDEPLOYDIR}/qcom-telematics-image/boot.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/boot.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/vmlinux ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/vmlinux
	install -m 0644 ${DEPLOY_DIR_IMAGE}/abl.elf ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/abl.elf
        install -m 0644 ${DEPLOY_DIR_IMAGE}/userdata.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/userdata.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/userdata.map ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/userdata.map
        install -m 0644 ${DEPLOY_DIR_IMAGE}/persist.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/persist.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/cache.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/cache.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/systemrw.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/systemrw.img
    else
        install -m 0644 ${DEPLOY_DIR_IMAGE}/qcom-telematics-image-sa535m.rootfs.ubi ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/sysfs.ubi
        install -m 0644 ${DEPLOY_DIR_IMAGE}/qcom-telematics-image-sa535m.rootfs.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/sysfs.ubifs
        install -m 0644 ${BOOTIMGDEPLOYDIR}/qcom-telematics-image/boot.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/boot.img
        install -m 0644 ${DEPLOY_DIR_IMAGE}/vmlinux ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/vmlinux
	install -m 0644 ${DEPLOY_DIR_IMAGE}/abl.elf ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/abl.elf
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "add_target_and_symlink;update_usb_composition; "

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

addtask do_deploy_fixup after do_makeboot after do_image_complete before do_build
