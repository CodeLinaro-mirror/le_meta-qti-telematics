# To add OTA upgrade support on an emmc/ufs target,
# add the MACHINE name to this list.
# This is the "only" list that will control whether
# OTA upgrade will be supported on a target.
DEPENDS += "releasetools-native zip-native fsconfig-native applypatch-native bc-native bsdiff-native"
DEPENDS += " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', bb.utils.contains('MACHINE_FEATURES', 'qti-stream-update', 'payload-gen-native', '', d), '', d)}"

RM_WORK_EXCLUDE_ITEMS += "rootfs rootfs-dbg"

IMAGE_SYSTEM_MOUNT_POINT = "/"
IMAGE_VDLKM_MOUNT_POINT = "/lib/modules/"

OTA_TARGET_IMAGE_ROOTFS_EXT4 = "${UNPACKDIR}/ota-target-image-ext4"

OTA_TARGET_FILES_EXT4 = "target-files-ext4.zip"
OTA_TARGET_FILES_EXT4_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_EXT4}"
OTA_FULL_UPDATE_EXT4 = "full_update_ext4.zip"
OTA_FULL_UPDATE_EXT4_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_FULL_UPDATE_EXT4}"
OTA_INCREMENTAL_UPDATE_EXT4 = "incremental_update_ext4.zip"
OTA_INCREMENTAL_UPDATE_EXT4_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_INCREMENTAL_UPDATE_EXT4}"

OTA_TARGET_FILES_EXT4_FDE = "target-files-ext4-fde.zip"
OTA_TARGET_FILES_EXT4_FDE_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/fde/${OTA_TARGET_FILES_EXT4_FDE}"
OTA_FULL_UPDATE_EXT4_FDE = "full_update_ext4_fde.zip"

MACHINE_FILESMAP_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/filesmap' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FILESMAP_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FILESMAP_CONF'), d.getVar('MACHINE_FILESMAP_SEARCH_PATH')) or ''}"

SIGN_OTA_PACKAGE ?= "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', '--sign', '', d)}"

MACHINE_PARTITION_CONF_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/partition' % p for p in d.getVar('BBPATH').split(':'))}"
MACHINE_PARTITION_CONF_FULL_PATH ?= "${@bb.utils.which(d.getVar('MACHINE_PARTITION_CONF_SEARCH_PATH'), d.getVar('MACHINE_PARTITION_CONF')) or ''}"

SLOT_A_SUFFIX ?= "_a"

#Set appropriate partion:Image map
NONAB_BOOT_PARTITION_IMAGE_MAP = "boot='${BOOTIMAGE_TARGET}',system='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}',dtbo='${DTBOIMAGE_TARGET}'"
AB_BOOT_PARTITION_IMAGE_MAP = "boot_a='${BOOTIMAGE_TARGET}',boot_b='${BOOTIMAGE_TARGET}',system_a='${SYSTEMIMAGE_TARGET}',system_b='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}'"

def set_partition_image_map(d):
    if "qti-ab-boot" in d.getVar('COMBINED_FEATURES', True):
        return d.getVar('AB_BOOT_PARTITION_IMAGE_MAP', True)
    else:
        return d.getVar('NONAB_BOOT_PARTITION_IMAGE_MAP', True)

PARTITION_IMAGE_MAP = "${@set_partition_image_map(d)}"

python do_generate_partition_xml() {
    import os
    import re
    import bb

    conf = d.getVar('MACHINE_PARTITION_CONF_FULL_PATH')
    if not conf or not os.path.isfile(conf):
        bb.fatal("Partition conf not found: '%s'" % conf)

    workdir = d.getVar('WORKDIR')
    xml     = os.path.join(workdir, 'sources/partition.xml')

    bb.note("Parsing EMMC partition conf: %s" % conf)

    partitions = {}  # name -> size_in_kb (int)

    with open(conf, 'r') as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '--partition' not in line:
                continue

            # extract --name=VALUE
            m_name = re.search(r'--name=(\S+)', line)
            # extract --size=VALUE  (e.g. 71680Kb or 71680KB or 71680)
            m_size = re.search(r'--size=([0-9]+(?:\.[0-9]+)?)\s*[Kk][Bb]?', line)

            if m_name and m_size:
                name    = m_name.group(1)
                size_kb = int(float(m_size.group(1)))
                partitions[name] = size_kb
                bb.note("  partition: %-30s  %d KB" % (name, size_kb))

    if not partitions:
        bb.fatal("No partitions parsed from %s" % conf)

    # Write partition.xml — format that existing sed patterns can match
    lines = ['<?xml version="1.0" encoding="UTF-8"?>', '<partitions>']
    for name, size_kb in partitions.items():
        lines.append('  <partition label="%s" size_in_kb="%d"/>' % (name, size_kb))
    lines.append('</partitions>')

    with open(xml, 'w') as fh:
        fh.write('\n'.join(lines) + '\n')

    bb.note("partition.xml written: %s" % xml)
}

addtask do_generate_partition_xml after do_rootfs before do_image

#Create directory structure for targetfiles.zip
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOTABLE_IMAGES"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/DATA"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/SYSTEM"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RADIO"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES"
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/DTBO"

# Create this folder just for saving file_contexts(SElinux security context file),
# It will be used to generate OTA packages when selinux_fc is set.
do_recovery_ext4[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOT/RAMDISK"

# recovery rootfs is required for generating OTA files.
# Wait till all tasks of machine-recovery-image complete.

do_recovery_ext4() {
    echo "base image rootfs: ${IMAGE_ROOTFS}"

    # if exists copy filesmap into RADIO directory
    radiofilesmap=${MACHINE_FILESMAP_FULL_PATH}
    [[ ! -z "$radiofilesmap" ]] && install -m 755 $radiofilesmap ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RADIO/filesmap

    # copy the boot\recovery images
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOTABLE_IMAGES/boot.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOTABLE_IMAGES/recovery.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/boot.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/recovery.img

    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/system.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${SYSTEMIMAGE_MAP_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/system.map

    if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${VDLKMIMAGE_TARGET} ]; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${VDLKMIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/vendor_dlkm.img
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${VDLKMIMAGE_MAP_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/vendor_dlkm.map
        echo vendor_dlkm_exist=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
    fi

    # if dtbo.img file exist then copy
    if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ]; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/dtbo.img
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RADIO/dtbo.img
    fi

    # if vendor_boot.img file exist then copy
    if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${VBOOTIMAGE_TARGET} ]; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${VBOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RADIO/vendor_boot.img
    fi

    # copy the contents of system rootfs
    cp -r ${IMAGE_ROOTFS}/. ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/SYSTEM/.
    cd  ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/SYSTEM
    rm -rf var/run
    ln -snf ../run var/run

    # copy the contents of system overlayfs
    if [ -f ${IMAGE_ROOTFS}/overlay/. ]; then
        cp -r ${IMAGE_ROOTFS}/overlay/. ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/DATA/.
    fi
    cp -r ${IMAGE_ROOTFS}/. ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/.

    #generate recovery.fstab which is used by the updater-script
    echo #mount point fstype device [device2] >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/recovery.fstab
    echo /boot     emmc  /dev/block/bootdevice/by-name/boot >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/recovery.fstab
    echo /overlay     ext4  /dev/block/bootdevice/by-name/userdata >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/recovery.fstab
    echo ${IMAGE_SYSTEM_MOUNT_POINT}   ext4  /dev/block/bootdevice/by-name/system >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/recovery.fstab
    echo ${IMAGE_VDLKM_MOUNT_POINT}   ext4  /dev/block/bootdevice/by-name/vendor_dlkm >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/recovery.fstab
    #Getting content for OTA folder
    mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA/bin
    cp ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA/bin/.

    cp ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/OTA/bin/.

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
    cp ${STAGING_DIR_NATIVE}/usr/bin/releasetools/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/.

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
      echo le_target_supports_nad_emmc=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
    fi

    # copy contents of META folder
    #recovery_api_version is from recovery module
    echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
    echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    export BOOT_SIZE=$(sed -r 's/.*label="boot${SLOT_A_SUFFIX}".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${UNPACKDIR}/partition.xml)
    export SYSTEM_SIZE=$(sed -r 's/.*label="system${SLOT_A_SUFFIX}".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${UNPACKDIR}/partition.xml)
    export USERDATA_SIZE=$(sed -r 's/.*label="userdata".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${UNPACKDIR}/partition.xml)
    export VDLKM_SIZE=$(sed -r 's/.*label="vendor_dlkm_a".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${UNPACKDIR}/partition.xml)
    export DTBO_SIZE=$(sed -r 's/.*label="dtbo_a".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${UNPACKDIR}/partition.xml)
    export VBOOT_SIZE=$(sed -r 's/.*label="vendor_boot_a".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${UNPACKDIR}/partition.xml)

    # convert kb to bytes
    export BOOT_SIZE="$(expr $BOOT_SIZE \* 1024)"
    export SYSTEM_SIZE="$(expr $SYSTEM_SIZE \* 1024)"
    export USERDATA_SIZE="$(expr $USERDATA_SIZE \* 1024)"
    export VDLKM_SIZE="$(expr $VDLKM_SIZE \* 1024)"
    export DTBO_SIZE="$(expr $DTBO_SIZE \* 1024)"
    export VBOOT_SIZE="$(expr $VBOOT_SIZE \* 1024)"

    #boot_size: Size of boot partition from partition.xml
    echo "boot_size=0x$(echo "obase=16; $BOOT_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #dtbo_size: Size of dtbo partition from partition.xml
    echo "dtbo_size=0x$(echo "obase=16; $DTBO_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #vendor_boot_size: Size of vendor_boot partition from partition.xml
    echo "vboot_size=0x$(echo "obase=16; $VBOOT_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #system_size : Size of system partition from partition.xml
    echo "system_size=0x$(echo "obase=16; $SYSTEM_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #vendor_dlkm_size : Size of vendor_dlkm partition from partition.xml
    echo "vdlkm_size=0x$(echo "obase=16; $VDLKM_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #userdate_size : Size of data partition from partition.xml
    echo "userdate_size=0x$(echo "obase=16; $USERDATA_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #cache_size : Size of data partition from partition.xml
    echo "cache_size=0x$(echo "obase=16; $USERDATA_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
    echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
    echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
    echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    # set block img diff version to v3
    echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    # Targets that support A/B boot do not need recovery(fs)-updater
    echo le_target_supports_ab=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt

    cd ${OTA_TARGET_IMAGE_ROOTFS_EXT4} && zip -qry ${OTA_TARGET_FILES_EXT4_PATH} *

    # Create target zip with boot-fde.img when qti-nad-fde is enabled
    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-nad-fde', 'true', 'false', d)}; then
        mkdir -p ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/fde
        cp -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/boot-fde.img ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/BOOTABLE_IMAGES/boot.img
        cp -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/boot-fde.img ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/IMAGES/boot.img
        echo le_target_supports_nad_fde=1 >> ${OTA_TARGET_IMAGE_ROOTFS_EXT4}/META/misc_info.txt
        cd ${OTA_TARGET_IMAGE_ROOTFS_EXT4} && zip -qry ${OTA_TARGET_FILES_EXT4_FDE_PATH} *
    fi
}
addtask do_recovery_ext4 after do_image_complete before do_build

# Generate OTA zip files
do_gen_ota_incremental_zip_ext4[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_ota_incremental_zip_ext4() {
    if [ -f "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_EXT4}" ]; then

        ./incremental_ota.sh ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_EXT4} ${OTA_TARGET_FILES_EXT4_PATH} ${IMAGE_ROOTFS} ext4 --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT} ${SIGN_OTA_PACKAGE}

        cp update_incr_ext4.zip ${DEPLOY_DIR_IMAGE}/${OTA_INCREMENTAL_UPDATE_EXT4}
    else
        return 0
    fi
}

do_gen_ota_full_zip_ext4[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_ota_full_zip_ext4() {
    ./full_ota.sh ${OTA_TARGET_FILES_EXT4_PATH} ${IMAGE_ROOTFS} ext4 --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT} ${SIGN_OTA_PACKAGE}
    if [[ -e update_ext4.zip ]]; then
        cp update_ext4.zip ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_FULL_UPDATE_EXT4}
    else
        bbwarn "Failed to create full_update_ext4.zip"
    fi

    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-nad-fde', 'true', 'false', d)}; then
        ./full_ota.sh ${OTA_TARGET_FILES_EXT4_FDE_PATH} ${IMAGE_ROOTFS} ext4 --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT} ${SIGN_OTA_PACKAGE}
        if [[ -e update_ext4.zip ]]; then
            cp update_ext4.zip ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/fde/${OTA_FULL_UPDATE_EXT4_FDE}
        else
            bbwarn "Failed to create full_update_ext4_fde.zip"
        fi
    fi

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
        if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-stream-update', 'true', 'false', d)}; then
            TMP=$(mktemp -d)
            cd $TMP
            gen_full_stream.sh ${OTA_TARGET_FILES_EXT4_PATH}
            scripts_brillo_update_payload generate --payload payload.bin --target_image target.zip
            scripts_brillo_update_payload properties --payload payload.bin > properties.txt
            cp payload.bin properties.txt ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}
            cd -
            rm -rf $TMP
            if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-nad-fde', 'true', 'false', d)}; then
                TMP=$(mktemp -d)
                cd $TMP
                gen_full_stream.sh ${OTA_TARGET_FILES_EXT4_FDE_PATH}
                scripts_brillo_update_payload generate --payload payload.bin --target_image target.zip
                scripts_brillo_update_payload properties --payload payload.bin > properties.txt
                cp payload.bin properties.txt ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/fde
                cd -
                rm -rf $TMP
            fi
        fi
    fi
}
addtask do_gen_ota_full_zip_ext4 after do_recovery_ext4 before do_build
