# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

################################################
### Generate isim image ###
################################################
inherit qimage-utils
ISIM_DIR ??= "isim"
ISIM_ROOTFS ??= "${IMAGE_ROOTFS}/${ISIM_DIR}"

# Define macros for ext4 filesystem image
ISIMIMAGE_EXT4_TARGET ?= "isim.img"
ISIMIMAGE_EXT4_MAP_TARGET ?= "isim.map"
# Convert human readable partition sizes into bytes
ISIM_IMAGE_EXT4_ROOTFS_SIZE = "${@get_size_in_bytes(d.getVar('ISIM_SIZE_EXT4') or '80000KiB')}"

do_makeisim[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'ext4-utils-native', '', d)}"

do_makeisim() {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'true', 'false', d)} ; then
        bbnote "Generating ${ISIMIMAGE_EXT4_TARGET} with ext4 file system"
        make_ext4fs  -B ${IMGDEPLOYDIR}/${ISIMIMAGE_EXT4_MAP_TARGET} \
                     -a /isim ${IMAGE_EXT4_SELINUX_OPTIONS} \
                     -b 4096 -l ${ISIM_IMAGE_EXT4_ROOTFS_SIZE} \
                     ${IMGDEPLOYDIR}/${ISIMIMAGE_EXT4_TARGET} \
                     ${IMAGE_ROOTFS}/${ISIM_DIR}
    fi
}

addtask do_makeisim after do_image before do_build
