# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

################################################
### Generate isim image ###
################################################
inherit qimage-utils
ISIM_DIR ??= "isim"
ISIM_ROOTFS ??= "${IMAGE_ROOTFS}/${ISIM_DIR}"
ISIM_FSCONFIG="${UNPACKDIR}/isim-fsconfig.conf"

# Define macros for ext4 filesystem image
ISIMIMAGE_EXT4_TARGET ?= "isim.img"
ISIMIMAGE_EXT4_MAP_TARGET ?= "isim.map"
# Convert human readable partition sizes into bytes
ISIM_IMAGE_EXT4_ROOTFS_SIZE = "${@get_size_in_bytes(d.getVar('ISIM_SIZE_EXT4') or '80000KiB')}"

ISIMIMAGE_UBIFS_TARGET ?= "isim.ubifs"
ISIMIMAGE_UBI_TARGET ?= "isim.ubi"
ISIM_UBINIZE_CFG ?= "${IMGDEPLOYDIR}/ubinize_isim.cfg"

#Ensure SELinux file context variable is defined
SELINUX_FILE_CONTEXTS ?= "${IMAGE_ROOTFS}/etc/selinux/mls/contexts/files/file_contexts"
#These are needed for ubi
SELINUX_IMG_UBI_S = "${@['--selinux=${SELINUX_FILE_CONTEXTS}', ''][d.getVar('SELINUX_FILE_CONTEXTS') == '']}"
IMAGE_UBIFS_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_UBI_S}', '', d)}"

#These are needed for ext4
SELINUX_IMG_S = "${@['-S ${SELINUX_FILE_CONTEXTS}', ''][d.getVar('SELINUX_FILE_CONTEXTS') == '']}"
IMAGE_EXT4_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_S}', '', d)}"

generate_dynamic_fsconfig() {
    ISIM_UID=$(grep "^isim:" ${IMAGE_ROOTFS}/etc/passwd | cut -d: -f3)
    ISIM_GID=$(grep "^isim:" ${IMAGE_ROOTFS}/etc/group  | cut -d: -f3)

    #Clear existing contents
    : > ${ISIM_FSCONFIG}

    if [ -n "${ISIM_UID}" ] && [ -n "${ISIM_GID}" ]; then
        bbnote "Creating ${ISIM_FSCONFIG} file with ${ISIM_UID} uid and ${ISIM_GID} gid"
        echo "isim/isim ${ISIM_UID} ${ISIM_GID} 0750" >> ${ISIM_FSCONFIG}
    else
        bbnote "Creating ${ISIM_FSCONFIG} file without isim uid and gid"
        echo "/isim 0 0 0750" >> ${ISIM_FSCONFIG}
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'generate_dynamic_fsconfig', '', d)}"

do_makeisim[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'ext4-utils-native', '', d)}"
DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'mtd-utils-native', '', d)}"

fakeroot do_makeisim() {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'true', 'false', d)} ; then
        bbnote "Generating ${ISIMIMAGE_EXT4_TARGET} with ext4 file system"
        make_ext4fs  -C ${ISIM_FSCONFIG} \
                     -B ${IMGDEPLOYDIR}/${ISIMIMAGE_EXT4_MAP_TARGET} \
                     -a /isim ${IMAGE_EXT4_SELINUX_OPTIONS} \
                     -b 4096 -l ${ISIM_IMAGE_EXT4_ROOTFS_SIZE} \
                     ${IMGDEPLOYDIR}/${ISIMIMAGE_EXT4_TARGET} \
                     ${IMAGE_ROOTFS}/${ISIM_DIR}
    elif ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'true', 'false', d)} ; then
        bbnote "Generating ${ISIMIMAGE_UBIFS_TARGET} and ${ISIMIMAGE_UBI_TARGET}"

        install -d ${IMGDEPLOYDIR}
        install -d ${IMGDEPLOYDIR}/${IMAGE_BASENAME}

        cat > ${ISIM_UBINIZE_CFG} << EOF
[isim]
vol_id=0
mode=ubi
image=${UNPACKDIR}/${ISIMIMAGE_UBIFS_TARGET}
vol_type=dynamic
vol_name=isim
vol_size=${ISIM_VOLUME_SIZE}
EOF

        mkfs.ubifs -r ${IMAGE_ROOTFS}/${ISIM_DIR} ${IMAGE_UBIFS_SELINUX_OPTIONS} \
           -o ${UNPACKDIR}/${ISIMIMAGE_UBIFS_TARGET} \
           ${MKUBIFS_ARGS}
        ubinize -o ${IMGDEPLOYDIR}/${ISIMIMAGE_UBI_TARGET} \
                ${UBINIZE_ARGS} ${ISIM_UBINIZE_CFG}
    fi
}

addtask do_makeisim after do_rootfs before do_image_complete
