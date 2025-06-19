SUMMARY = "Auto Telematics Base Image"

LICENSE = "BSD-3-Clause-Clear"

IMAGE_FEATURES += "allow-root-login post-install-logging enable-adbd"

inherit core-image features_check extrausers image-adbd
inherit python3native qramdisk dm-verity-initramfs-v4

# let's make sure we have a good image..
REQUIRED_DISTRO_FEATURES = "systemd"

CORE_IMAGE_BASE_INSTALL += " \
    var-persist-mount \
    qcom-resize-partitions \
"

CORE_IMAGE_BASE_INSTALL += " \
    can-utils \
    chrony \
    chronyc \
    ethtool \
    iproute2 \
    leproperties \
    mtd-utils \
    packagegroup-qti-telematics \
    procrank \
"

IMAGE_FSTYPES:remove = "ostree"

python () {
	bb.build.addtask('do_merge_dtbs', 'do_makeboot', bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'do_makesystem_ubi', 'do_makesystem', d), d)
}

do_merge_dtbs() {
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
do_deploy_fixup[deptask] = "do_image_complete"

do_deploy_fixup[nostamp] = "1"

do_deploy_fixup:append() {
    install -m 0644 ${DEPLOY_DIR_IMAGE}/qcom-telematics-image-sa535m.rootfs.ubi ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/sysfs.ubi
    install -m 0644 ${DEPLOY_DIR_IMAGE}/qcom-telematics-image-sa535m.rootfs.ubifs ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/sysfs.ubifs
    install -m 0644 ${BOOTIMGDEPLOYDIR}/qcom-telematics-image/boot.img ${DEPLOY_DIR_IMAGE}/qcom-telematics-image/boot.img
}

addtask do_deploy_fixup after do_image_complete before do_build
