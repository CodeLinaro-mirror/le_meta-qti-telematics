# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# This file "dm-verity-initramfs-v4.bbclasss"
# 1, Generate boot.img with initramfs.
# 2, Enable dm-verity feature with avb for NAND.

CONFLICT_MACHINE_FEATURES += " dm-verity-bootloader dm-verity-initramfs dm-verity-none"

BOOTIMGDEPLOYDIR = "${WORKDIR}/deploy-${PN}-bootimage-complete"
KERNEL_CMDLINE_EXTRA += "root=/dev/ram rootfstype=ramfs init=/sbin/init"

INITRAMFS_IMAGE ?= ''
RAMDISK ?= "${IMGDEPLOYDIR}/${PN}-initrd.gz"
def get_ramdisk_path(d):
    if os.path.exists(d.getVar('RAMDISK')):
        return '%s' %(d.getVar('RAMDISK'))
    return '/dev/null'

RAMDISK_PATH = "${@get_ramdisk_path(d)}"

RAMDISK_FDE_PATH = "${IMGDEPLOYDIR}/${PN}-initrd-fde.gz"
BOOTIMAGE_FDE_TARGET = "boot-fde.img"
RAMDISK_DEBUG_PATH = "${IMGDEPLOYDIR}/${PN}-initrd-debug.gz"
BOOTIMAGE_DEBUG_TARGET = "boot-debug.img"
OVERLAY_ENABLED ?= "False"

MKBOOTUTIL = "kernel/kernel_platform/tools/mkbootimg/mkbootimg.py"

python do_makeboot () {
    import subprocess

    xtra_parms=""
    if (d.getVar("BOOT_HEADER_VERSION") or "0") != "0":
        xtra_parms += " --header_version " + d.getVar('BOOT_HEADER_VERSION')
        # header version setting expects dtb to be passed seprately but not appended to kernel
        xtra_parms += " --dtb " + d.getVar('DEPLOY_DIR_IMAGE', True) + "/dtbs/" + d.getVar('KERNEL_DTB_NAMES').strip()

    mkboot_bin_path = d.getVar('WORKSPACE', True) + "/" + d.getVar('MKBOOTUTIL')
    ramdisk_path    = d.getVar('RAMDISK_PATH')
    zimg_path       = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + d.getVar('KERNEL_IMAGETYPE', True)
    cmdline         = "\"" + d.getVar('KERNEL_CMDLINE_EXTRA', True) + "\""
    pagesize        = d.getVar('PAGE_SIZE', True)
    base            = d.getVar('KERNEL_BASE', True)
    output          = d.getVar('BOOTIMAGE_TARGET', True)

    # cmd to make boot.img
    cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s --ramdisk %s --ramdisk_offset 0x0 %s --output %s" \
           % (zimg_path, cmdline, pagesize, base, ramdisk_path, xtra_parms, output )
    bb.debug(1, "dm-verity-initramfs-v4 do_makeboot cmd: %s" % (cmd))
    try:
        ret = subprocess.check_output(cmd, shell=True)
    except RuntimeError as e:
        bb.error("dm-verity-initramfs-v4 cmd: %s failed with error %s" % (cmd, str(e)))

    # generate boot image with FDE enabled ramdisk
    if bb.utils.contains('MACHINE_FEATURES', 'qti-nad-fde', True, False, d):
        ramdiskfde_path = d.getVar('RAMDISK_FDE_PATH')
        outputfde = d.getVar('BOOTIMAGE_FDE_TARGET', True)
        # cmd to make boot-fde.img
        cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s --ramdisk %s --ramdisk_offset 0x0 %s --output %s" \
               % (zimg_path, cmdline, pagesize, base, ramdiskfde_path, xtra_parms, outputfde )
        bb.debug(1, "dm-verity-initramfs-v4 do_makeboot fde cmd: %s" % (cmd))
        try:
            ret = subprocess.check_output(cmd, shell=True)
        except RuntimeError as e:
            bb.error("dm-verity-initramfs-v4 fde cmd: %s failed with error %s" % (cmd, str(e)))

    overlay_enabled = d.getVar('OVERLAY_ENABLED', True)
    if ( overlay_enabled == "True"):

        # generate images with overlayfs
        ramdiskdebug_path = d.getVar('RAMDISK_DEBUG_PATH')
        outputdebug = d.getVar('BOOTIMAGE_DEBUG_TARGET', True)
        # cmd to make boot-debug.img
        cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s --ramdisk %s --ramdisk_offset 0x0 %s --output %s" \
               % (zimg_path, cmdline, pagesize, base, ramdiskdebug_path, xtra_parms, outputdebug )
        bb.debug(1, "dm-verity-initramfs-v4 do_makeboot debug(overlay) cmd: %s" % (cmd))
        try:
               ret = subprocess.check_output(cmd, shell=True)
        except RuntimeError as e:
               bb.error("dm-verity-initramfs-v4 debug(overlay) cmd: %s failed with error %s" % (cmd, str(e)))

}
do_makeboot[dirs]      = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}"

# Make sure native tools and vmlinux ready to create boot.img
do_makeboot[depends] += "virtual/kernel:do_deploy virtual/mkbootimg-native:do_populate_sysroot"
do_makeboot[depends] += "${PN}:do_ramdisk_create"
SSTATETASKS += "do_makeboot"
SSTATE_SKIP_CREATION_task-makeboot = '1'
do_makeboot[sstate-inputdirs] = "${BOOTIMGDEPLOYDIR}"
do_makeboot[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_makeboot[stamp-extra-info] = "${MACHINE_ARCH}"

addtask do_makeboot before do_image_complete

#squashfs files
SYSTEMIMAGE_SQUASHFS_TARGET = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/sysfs.squash"

do_sign_system_squashfs () {
    # Sign the system image
    ${TMPDIR}/work-shared/avbtool/avbtool add_hashtree_footer \
        --image ${SYSTEMIMAGE_SQUASHFS_TARGET} \
        --partition_name rootfs \
        --algorithm SHA256_RSA2048 \
        --key ${TMPDIR}/work-shared/avbtool/qpsa_attestca.key \
        --public_key_metadata ${TMPDIR}/work-shared/avbtool/qpsa_attestca.der \
        --do_not_generate_fec --rollback_index 0
}
do_sign_system_squashfs[depends] += "avbtool-native:do_install"

#EXT4 files
SYSTEMIMAGE_EXT4_TARGET = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/sysfs.img"

# Sign the system image
do_sign_system_ext4 () {
     ${TMPDIR}/work-shared/avbtool/avbtool add_hashtree_footer \
        --image ${SYSTEMIMAGE_EXT4_TARGET} \
        --partition_name system \
        --algorithm SHA256_RSA2048 \
        --key ${TMPDIR}/work-shared/avbtool/qpsa_attestca.key \
        --public_key_metadata ${TMPDIR}/work-shared/avbtool/qpsa_attestca.der \
        --do_not_generate_fec --rollback_index 0
}
do_sign_system_ext4[depends] += "avbtool-native:do_install"
