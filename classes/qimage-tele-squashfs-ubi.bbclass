# if A/B support is supported, generate OTA pkg by default.
GENERATE_AB_OTA_PACKAGE ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', '1', '', d)}"

MLIBPREFIX ?= ""
QIMGUBICLASSES  = ""
# To be implemented

#QIMGUBICLASSES += "${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-recovery qti-ab-boot qti-nad-core', 'ota-ubi', '', d)}"

QIMGUBICLASSES += "${@bb.utils.contains_any('MACHINE_FEATURES', 'nand-boot', 'qimage-ubi', '', d)}"

inherit ${QIMGUBICLASSES}

IMAGE_FEATURES[validitems] += "nand2x gluebi modem-volume cache-volume persist-volume vm-bootsys-volume vm-systemrw-volume"
IMAGE_FEATURES[validitems] += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', 'telaf-volume', '', d)}"
IMAGE_FEATURES[validitems] += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-tele-lxc', 'lxcrootfs-volume', '', d)}"

CORE_IMAGE_EXTRA_INSTALL += "${MLIBPREFIX}systemd-machine-units-ubi"
DEPENDS += "\
             squashfs-tools-native \
"

SYSTEM_IMAGE_UBI_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/sysfs.ubi"
SYSTEM_IMAGE_UBI_TARGET_WITH_LXC ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/ubifs/sysfs.ubi"
SYSTEM_IMAGE_UBIFS_TARGET ?= "${@bb.utils.contains('IMAGE_FEATURES', 'gluebi', bb.utils.contains('DISTRO_FEATURES', 'dm-verity', '${IMGDEPLOYDIR}/${IMAGE_BASENAME}/verity/${SYSTEMIMAGE_GLUEBI_TARGET}/${SYSTEMIMAGE_GLUEBI_TARGET}', '${SYSTEMIMAGE_GLUEBI_TARGET}', d), '${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/sysfs.ubifs', d)}"
SYSTEMRW_UBIFS_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/systemrw.ubifs"
SYSTEMRW_ROOTFS ?= "${UNPACKDIR}/systemrw"
USER_IMAGE_UBIFS_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/userfs.ubifs"
USER_IMAGE_ROOTFS ?= "${UNPACKDIR}/usrfs-data"
MODEM_UBIFS_IMAGE = "${WORKSPACE}/NON-HLOS.ubifs"

LXCRFSIMAGE_UBIFS_TARGET ?= "${DEPLOY_DIR_IMAGE}/lxcrootfs.ubifs"
LXCRFSIMAGE_SQUASHFS_TARGET ?= "${DEPLOY_DIR_IMAGE}/lxcrootfs.squash"

CACHE_UBIFS_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/cache.ubifs"
CACHE_IMAGE_ROOTFS ?= "${UNPACKDIR}/cache"
PERSIST_UBIFS_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/persist.ubifs"
PERSIST_IMAGE_ROOTFS ?= "${UNPACKDIR}/persist"

VM_IMAGE_UBI_TARGET ?= "vm-bootsys.ubi"
VM_IMAGE_SQUASHFS_TARGET ?= "vm-bootsys.squash"
VM_IMAGE_ROOTFS ?= "${DEPLOY_DIR_IMAGE}/vm-images/"
VM_BOOTSYS_SQUASHFS_VOLUME_SIZE ??= "80MiB"

UBINIZE_SYSTEM_CFG ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs/ubifs_ubinize_ab.cfg"
UBINIZE_SYSTEM_CFG_WITH_LXC ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/ubifs/ubifs_ubinize_ab.cfg"
SQUASHFS_UBINIZE_VM_CFG ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/squashfs_ubinize_vm.cfg"

#squashfs files
SYSTEMIMAGE_SQUASHFS_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/sysfs.squash"
SYSTEMIMAGE_SQUASHFS_UBI_AB_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/sysfs-squashfs_ab.ubi"
SYSTEMIMAGE_SQUASHFS_UBI_AB_TARGET_WITH_LXC ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/squashfs/sysfs-squashfs_ab.ubi"
SQUASHFS_UBINIZE_CFG_AB ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/squashfs_ubinize_ab.cfg"
SQUASHFS_UBINIZE_CFG_AB_WITH_LXC ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/squashfs/squashfs_ubinize_ab.cfg"
MODEM_IMAGE_DIR = "${WORKSPACE}/modem_image"
SELINUX_CONTEXT_MODEM = "${WORKSPACE}/fctx1"
MODEM_SQUASHFS_IMAGE = "${WORKSPACE}/NON-HLOS.squash"

TELAF_RO_SQUASHFS_TARGET ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/telaf_ro.squashfs"
TELAF_RO_IMAGE_PATH ?= "${DEPLOY_DIR_IMAGE}/telaf-images/telaf_ro"
TELAF_RO_SELINUX_FILE_CONTEXTS ?= "${DEPLOY_DIR_IMAGE}/telaf-images/security/selinux/sepolicy/files/file_contexts"

# Ensure SELinux file context variable is defined

SELINUX_FILE_CONTEXTS ?= ""
SELINUX_FILE_CONTEXTS_DATA ?= ""
SELINUX_FILE_CONTEXTS_SYSTEMRW ?= ""
SELINUX_IMG_UBI_S = "${@['--selinux=${SELINUX_FILE_CONTEXTS}', ''][d.getVar('SELINUX_FILE_CONTEXTS') == '']}"
SELINUX_IMG_UBI_S_DATA = "${@['--selinux=${SELINUX_FILE_CONTEXTS_DATA}', ''][d.getVar('SELINUX_FILE_CONTEXTS_DATA') == '']}"
SELINUX_IMG_UBI_S_SYSTEMRW = "${@['--selinux=${SELINUX_FILE_CONTEXTS_SYSTEMRW}', ''][d.getVar('SELINUX_FILE_CONTEXTS_SYSTEMRW') == '']}"
IMAGE_UBIFS_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_UBI_S}', '', d)}"
IMAGE_UBIFS_SELINUX_OPTIONS_DATA = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_UBI_S_DATA}', '', d)}"
IMAGE_UBIFS_SELINUX_OPTIONS_SYSTEMRW = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_UBI_S_SYSTEMRW}', '', d)}"

MKUBIFS_SYSTEMRW_ARGS ?= "-m 4096 -e 253952 -c 25 -F"
MKUBIFS_USERFS_ARGS ?= "-m 4096 -e 253952 -c 2146 -F"
MKUBIFS_CACHE_ARGS ?= "-m 4096 -e 253952 -c 25 -F"
MKUBIFS_PERSIST_ARGS ?= "-m 4096 -e 253952 -c 24 -F"

OVERLAY_ENABLED ?= "False"

do_image_ubi[noexec] = "1"
do_image_ubifs[noexec] = "1"
do_image_multiubi[noexec] = "1"

################################################
### Generate sysfs.ubi #########################
################################################
SYSTEM_VOLUME_SIZE_G ??= "200MiB"
ROOTFS_VOLUME_SIZE = "${@bb.utils.contains('IMAGE_FEATURES', 'nand2x', '${SYSTEM_VOLUME_SIZE_G}', '${SYSTEM_VOLUME_SIZE}', d)}"
IMAGE_ROOTFS_SQUASHFS_UBI = "${WORKDIR}/rootfs-squashfs-ubi"
IMAGE_ROOTFS_UBIFS_UBI = "${WORKDIR}/rootfs-ubifs-ubi"

create_tele_systemrw[cleandirs] = "${SYSTEMRW_ROOTFS}"
create_tele_systemrw[noexec] = "1"

create_cache[cleandirs] = "${CACHE_IMAGE_ROOTFS}"
# Nothing to do, empty volume
create_cache[noexec] = "1"

create_persist[cleandirs] = "${PERSIST_IMAGE_ROOTFS}"
# Nothing to do, empty volume
create_persist[noexec] = "1"

create_symlink_tele_userfs[cleandirs] = "${USER_IMAGE_ROOTFS}"
create_symlink_tele_userfs() {

    if ${@bb.utils.contains('DISTRO_FEATURES', 'usrmerge', 'false', 'true', d)}; then
        #Symlink modules
        LIB_MODULES="${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/modules"
        if [ -d ${LIB_MODULES} ]; then
            cp -rp ${LIB_MODULES} ${IMAGE_ROOTFS_SQUASHFS_UBI}/usr/lib/
            rm -rf ${LIB_MODULES}
        fi
        ln -sf /usr/lib/modules ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib
    fi

    if [[ "${OVERLAY_ENABLED}" == "True" ]]; then
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/etc
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/usr-lib
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/usr-bin
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/usr-sbin
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/usr-lib-work
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/etc-work
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/usr-bin-work
        mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/usr-sbin-work
    fi

    # Move rootfs data to userfs directory
    # Content of userfs is added to data volume
    mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/configs
    mkdir -p ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/logs
    mv ${IMAGE_ROOTFS_SQUASHFS_UBI}/data/* ${USER_IMAGE_ROOTFS}
}

cleanup_squashfs_rootfs() {

    #remove additional ext4 symlinks if present
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/local-fs-pre.target.requires/systemd-fsck*
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/local-fs.target.requires/firmware.mount
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/local-fs.target.requires/dsp.mount
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/local-fs.target.requires/bt_firmware.mount
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/sysinit.target.wants/ab-updater.service
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/sysinit.target.wants/rmt_storage.service
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/etc/udev/rules.d/rmtstorage.rules
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/etc/systemd/system/local-fs-pre.target.wants/set-slotsuffix.service
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/local-fs.target.requires/vm-bootsys.mount
    # Recheck when overlay support added for ubi
    rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/local-fs.target.wants/overlay-restore.service

   # Remove rules to automount block devices.
   sed -i '/SUBSYSTEM=="block", TAG+="systemd"/d' ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/udev/rules.d/99-systemd.rules
   sed -i '/SUBSYSTEM=="block", ACTION=="add", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", ENV{SYSTEMD_READY}="0"/d' ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/udev/rules.d/99-systemd.rules

   # Remove generator binaries and ensure that we don't rely on generators for mount or service files.
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-debug-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-fstab-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-getty-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-gpt-auto-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-hibernate-resume-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-rc-local-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-system-update-generator
   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system-generators/systemd-sysv-generator

   # Start systemd-udev-trigger.service after sysinit.target
   sed -i '/Before=sysinit.target/a After=sysinit.target init_sys_mss.service' ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/systemd-udev-trigger.service
   sed -i '/Before=sysinit.target/d' ${IMAGE_ROOTFS_SQUASHFS_UBI}/lib/systemd/system/systemd-udev-trigger.service

}

# Need to copy ubinize.cfg file in the deploy directory
do_create_ubinize_tele_config[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs"
do_create_squash_ubinize_config_ab[depends] += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', 'do_maketelaf_squashfs', '', d)}"
do_create_ubinize_tele_config_with_lxc[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/ubifs"
do_create_squash_ubinize_config_ab_with_lxc[depends] += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', 'do_maketelaf_squashfs', '', d)}"

do_create_ubinize_tele_config() {
vol_id=0
cat << EOF > ${UBINIZE_SYSTEM_CFG}
[sysfs_a_volume]
mode=ubi
image="${SYSTEM_IMAGE_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=rootfs_a
vol_size="${ROOTFS_VOLUME_SIZE}"

[sysfs_b_volume]
mode=ubi
image="${SYSTEM_IMAGE_UBIFS_TARGET}"
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=rootfs_b
vol_size="${ROOTFS_VOLUME_SIZE}"

[usrfs_volume]
mode=ubi
image="${USERIMAGE_UBIFS_TARGET}"
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=usrfs
vol_flags=autoresize

EOF
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG}))
    if $(echo ${IMAGE_FEATURES} | grep -q "cache-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG}
[cache_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=cachefs
vol_size="${CACHE_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG}))
cat << EOF >> ${UBINIZE_SYSTEM_CFG}
[systemrw_volume]
mode=ubi
image="${SYSTEMRW_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=systemrw
vol_size="${SYSTEMRW_VOLUME_SIZE}"

EOF
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG}))
    if $(echo ${IMAGE_FEATURES} | grep -q "persist-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG}
[persist_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=persist
vol_size="${PERSIST_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG}))
    if $(echo ${IMAGE_FEATURES} | grep -q "modem-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG}
[modem_a_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=firmware_a
vol_size="${MODEM_VOLUME_SIZE}"

[modem_b_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=firmware_b
vol_size="${MODEM_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-bootsys-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG}
[vm-bootsys_a_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=vm-bootsys_a
vol_size="${VM_BOOTSYS_VOLUME_SIZE}"

[vm-bootsys_b_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=vm-bootsys_b
vol_size="${VM_BOOTSYS_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-systemrw-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG}
[vm_systemrw_volume]
mode=ubi
image="${SYSTEMRW_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=vm_systemrw
vol_size="${VM_SYSTEMRW_VOLUME_SIZE}"

EOF
    fi
}

do_create_ubinize_tele_config_with_lxc() {
vol_id=0
cat << EOF > ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[sysfs_a_volume]
mode=ubi
image="${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=rootfs_a
vol_size="${ROOTFS_VOLUME_SIZE}"

[sysfs_b_volume]
mode=ubi
image="${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_UBIFS_TARGET}"
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=rootfs_b
vol_size="${ROOTFS_VOLUME_SIZE}"

[usrfs_volume]
mode=ubi
image="${USERIMAGE_UBIFS_TARGET}"
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=usrfs
vol_flags=autoresize

EOF
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "cache-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[cache_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=cachefs
vol_size="${CACHE_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[systemrw_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=systemrw
vol_size="${SYSTEMRW_VOLUME_SIZE}"

EOF
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "lxcrootfs-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[lxcrootfs_volume_a]
mode=ubi
image="${LXCRFSIMAGE_UBIFS_TARGET}"
vol_id=$((vol_id++))
vol_type=dynamic
vol_name=lxcrootfs_a
vol_size=${LXCRFS_VOLUME_SIZE}

[lxcrootfs_volume_b]
mode=ubi
image="${LXCRFSIMAGE_UBIFS_TARGET}"
vol_id=$((vol_id++))
vol_type=dynamic
vol_name=lxcrootfs_b
vol_size=${LXCRFS_VOLUME_SIZE}
EOF
   fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "persist-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[persist_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=persist
vol_size="${PERSIST_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "modem-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[modem_a_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=firmware_a
vol_size="${MODEM_VOLUME_SIZE}"

[modem_b_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=firmware_b
vol_size="${MODEM_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-bootsys-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[vm-bootsys_a_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=vm-bootsys_a
vol_size="${VM_BOOTSYS_VOLUME_SIZE}"

[vm-bootsys_b_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=vm-bootsys_b
vol_size="${VM_BOOTSYS_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${UBINIZE_SYSTEM_CFG_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-systemrw-volume"); then
        cat << EOF >> ${UBINIZE_SYSTEM_CFG_WITH_LXC}
[vm_systemrw_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=vm_systemrw
vol_size="${VM_SYSTEMRW_VOLUME_SIZE}"

EOF
    fi
}

# Squahshfs cfg
do_create_squash_ubinize_config_ab[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs"
do_create_squash_ubinize_config_ab[depends] += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', 'do_maketelaf_squashfs', '', d)}"
do_create_squash_ubinize_config_ab_with_lxc[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/squashfs/"
do_create_squash_ubinize_config_ab_with_lxc[depends] += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', 'do_maketelaf_squashfs', '', d)}"

do_create_squash_ubinize_config_ab() {
vol_id=0
    cat << EOF > ${SQUASHFS_UBINIZE_CFG_AB}
[sysfs_a_volume]
mode=ubi
image="${SYSTEMIMAGE_SQUASHFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=rootfs_a
vol_size="${SYSTEM_SQUASHFS_VOLUME_SIZE}"

[sysfs_b_volume]
mode=ubi
image="${SYSTEMIMAGE_SQUASHFS_TARGET}"
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=rootfs_b
vol_size="${SYSTEM_SQUASHFS_VOLUME_SIZE}"

EOF
    if $(echo ${IMAGE_FEATURES} | grep -q "modem-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[modem_a_volume]
mode=ubi
EOF
        if [ -f ${MODEM_SQUASHFS_IMAGE} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
image="${MODEM_SQUASHFS_IMAGE}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
vol_id=$vol_id
vol_type=dynamic
vol_name=firmware_a
vol_size="${MODEM_SQUASHFS_VOLUME_SIZE}"

[modem_b_volume]
mode=ubi
EOF
        if [ -f ${MODEM_SQUASHFS_IMAGE} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
image="${MODEM_SQUASHFS_IMAGE}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
vol_id=$vol_id
vol_type=dynamic
vol_name=firmware_b
vol_size="${MODEM_SQUASHFS_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
    if $(echo ${IMAGE_FEATURES} | grep -q "telaf-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[telaf_a_volume]
mode=ubi
EOF
        if [ -f ${TELAF_RO_SQUASHFS_TARGET} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
image="${TELAF_RO_SQUASHFS_TARGET}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
vol_id=$vol_id
vol_type=dynamic
vol_name=telaf_a
vol_size="${TELAF_SQUASHFS_VOLUME_SIZE}"

[telaf_b_volume]
mode=ubi
EOF
        if [ -f ${TELAF_RO_SQUASHFS_TARGET} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
image="${TELAF_RO_SQUASHFS_TARGET}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
vol_id=$vol_id
vol_type=dynamic
vol_name=telaf_b
vol_size="${TELAF_SQUASHFS_VOLUME_SIZE}"

[telaf_app_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=telaf_app
vol_size="${TELAF_APP_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[usrfs_volume]
mode=ubi
image="${USER_IMAGE_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=usrfs
vol_flags=autoresize

EOF
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
    if $(echo ${IMAGE_FEATURES} | grep -q "cache-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[cache_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=cachefs
vol_size="${CACHE_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[systemrw_volume]
mode=ubi
image="${SYSTEMRW_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=systemrw
vol_size="${SYSTEMRW_VOLUME_SIZE}"

EOF
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
    if $(echo ${IMAGE_FEATURES} | grep -q "persist-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[persist_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=persist
vol_size="${PERSIST_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-bootsys-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[vm-bootsys_a_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=vm-bootsys_a
vol_size="${VM_BOOTSYS_SQUASHFS_VOLUME_SIZE}"

[vm-bootsys_b_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=vm-bootsys_b
vol_size="${VM_BOOTSYS_SQUASHFS_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-systemrw-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB}
[vm_systemrw_volume]
mode=ubi
image="${SYSTEMRW_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=vm_systemrw
vol_size="${VM_SYSTEMRW_VOLUME_SIZE}"

EOF
    fi
}

do_create_squash_ubinize_config_ab_with_lxc() {
vol_id=0
    cat << EOF > ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[sysfs_a_volume]
mode=ubi
image="${SYSTEMIMAGE_SQUASHFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=rootfs_a
vol_size="${SYSTEM_SQUASHFS_VOLUME_SIZE}"

[sysfs_b_volume]
mode=ubi
image="${SYSTEMIMAGE_SQUASHFS_TARGET}"
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=rootfs_b
vol_size="${SYSTEM_SQUASHFS_VOLUME_SIZE}"

EOF
    if $(echo ${IMAGE_FEATURES} | grep -q "modem-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[modem_a_volume]
mode=ubi
EOF
        if [ -f ${MODEM_SQUASHFS_IMAGE} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
image="${MODEM_SQUASHFS_IMAGE}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
vol_id=$vol_id
vol_type=dynamic
vol_name=firmware_a
vol_size="${MODEM_SQUASHFS_VOLUME_SIZE}"

[modem_b_volume]
mode=ubi
EOF
        if [ -f ${MODEM_SQUASHFS_IMAGE} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
image="${MODEM_SQUASHFS_IMAGE}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
vol_id=$vol_id
vol_type=dynamic
vol_name=firmware_b
vol_size="${MODEM_SQUASHFS_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "telaf-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[telaf_a_volume]
mode=ubi
EOF
        if [ -f ${TELAF_RO_SQUASHFS_TARGET} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
image="${TELAF_RO_SQUASHFS_TARGET}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
vol_id=$vol_id
vol_type=dynamic
vol_name=telaf_a
vol_size="${TELAF_SQUASHFS_VOLUME_SIZE}"

[telaf_b_volume]
mode=ubi
EOF
        if [ -f ${TELAF_RO_SQUASHFS_TARGET} ]; then
            cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
image="${TELAF_RO_SQUASHFS_TARGET}"
EOF
        fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
vol_id=$vol_id
vol_type=dynamic
vol_name=telaf_b
vol_size="${TELAF_SQUASHFS_VOLUME_SIZE}"

[telaf_app_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=telaf_app
vol_size="${TELAF_APP_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[usrfs_volume]
mode=ubi
image="${USER_IMAGE_UBIFS_TARGET}"
vol_id=$vol_id
vol_type=dynamic
vol_name=usrfs
vol_flags=autoresize

EOF
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "cache-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[cache_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=cachefs
vol_size="${CACHE_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[systemrw_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=systemrw
vol_size="${SYSTEMRW_VOLUME_SIZE}"

EOF
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "lxcrootfs-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[lxcrootfs_volume_a]
mode=ubi
image="${LXCRFSIMAGE_SQUASHFS_TARGET}"
vol_id=$((vol_id++))
vol_type=dynamic
vol_name=lxcrootfs_a
vol_size=${LXCRFS_SQUASHFS_VOLUME_SIZE}

[lxcrootfs_volume_b]
mode=ubi
image="${LXCRFSIMAGE_SQUASHFS_TARGET}"
vol_id=$((vol_id++))
vol_type=dynamic
vol_name=lxcrootfs_b
vol_size=${LXCRFS_SQUASHFS_VOLUME_SIZE}
EOF
   fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "persist-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[persist_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=persist
vol_size="${PERSIST_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-bootsys-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[vm-bootsys_a_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=vm-bootsys_a
vol_size="${VM_BOOTSYS_SQUASHFS_VOLUME_SIZE}"

[vm-bootsys_b_volume]
mode=ubi
vol_id=$((++vol_id))
vol_type=dynamic
vol_name=vm-bootsys_b
vol_size="${VM_BOOTSYS_SQUASHFS_VOLUME_SIZE}"

EOF
    fi
vol_id=$(echo $(grep -rc "vol_id" ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}))
    if $(echo ${IMAGE_FEATURES} | grep -q "vm-systemrw-volume"); then
        cat << EOF >> ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
[vm_systemrw_volume]
mode=ubi
vol_id=$vol_id
vol_type=dynamic
vol_name=vm_systemrw
vol_size="${VM_SYSTEMRW_VOLUME_SIZE}"

EOF
    fi
}


create_rootfs_tele_ubi[cleandirs] = "${IMAGE_ROOTFS_SQUASHFS_UBI}"
fakeroot python create_rootfs_tele_ubi () {
    src_dir = d.getVar("IMAGE_ROOTFS")
    dest_dir = d.getVar("IMAGE_ROOTFS_SQUASHFS_UBI")
    if os.path.isdir(src_dir):
        oe.path.copyhardlinktree(src_dir, dest_dir)
    else:
        bb.error("rootfs is not generated")
}

create_rootfs_tele_ubifs[cleandirs] = "${IMAGE_ROOTFS_UBIFS_UBI}"
fakeroot python create_rootfs_tele_ubifs () {
    src_dir = d.getVar("IMAGE_ROOTFS_SQUASHFS_UBI")
    dest_dir = d.getVar("IMAGE_ROOTFS_UBIFS_UBI")
    if os.path.isdir(src_dir):
        oe.path.copyhardlinktree(src_dir, dest_dir)
    else:
        bb.error("rootfs is not generated")
}

do_makesystem_tele_ubi[prefuncs] += "create_rootfs_tele_ubi"
do_makesystem_tele_ubi[prefuncs] += "create_symlink_tele_userfs"
do_makesystem_tele_ubi[prefuncs] += "cleanup_squashfs_rootfs"
do_makesystem_tele_ubi[prefuncs] += "do_create_ubinize_tele_config"
do_makesystem_tele_ubi[prefuncs] += "create_rootfs_tele_ubifs"
do_makesystem_tele_ubi[prefuncs] += "create_tele_systemrw"
do_makesystem_tele_ubi[prefuncs] += "create_cache"
do_makesystem_tele_ubi[prefuncs] += "create_persist"
do_makesystem_tele_ubi[postfuncs] += "${@bb.utils.contains('INHERIT', 'uninative', 'do_patch_ubi_tools', '', d)}"
do_makesystem_tele_ubi[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
do_makesystem_tele_ubi[dirs] += "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/ubifs ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs"

do_makesystem_tele_ubi_with_lxc[prefuncs] += "do_create_ubinize_tele_config_with_lxc"
do_makesystem_tele_ubi_with_lxc[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc"
do_makesystem_tele_ubi_with_lxc[depends] = "qti-lxcrootfs-image:do_build"

fakeroot do_makesystem_tele_ubi() {
   mkdir ${USER_IMAGE_ROOTFS}/cache
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/cache
   ln -sf /data/cache ${IMAGE_ROOTFS_UBIFS_UBI}/cache

   rm -rf ${IMAGE_ROOTFS_SQUASHFS_UBI}/cache
   ln -sf /data/cache ${IMAGE_ROOTFS_SQUASHFS_UBI}/cache

   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/telaf.mount.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/telaf.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/mrc-daemon.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/rbm-daemon.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system-preset/98-mrc-daemon.preset
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/gluebi-dlkm.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/multi-user.target.wants/telaf.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/lib/systemd/system/multi-user.target.wants/telaf.mount.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/etc/systemd/system/multi-user.target.wants/mrc-daemon.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/etc/systemd/system/multi-user.target.wants/rbm-daemon.service
   rm -rf ${IMAGE_ROOTFS_UBIFS_UBI}/etc/systemd/system/multi-user.target.wants/gluebi-dlkm.service

   mkfs.ubifs -r ${SYSTEMRW_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS_SYSTEMRW} -o ${SYSTEMRW_UBIFS_TARGET} ${MKUBIFS_SYSTEMRW_ARGS}
   mkfs.ubifs -r ${USER_IMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS_DATA} -o ${USER_IMAGE_UBIFS_TARGET} ${MKUBIFS_USERFS_ARGS}
   mkfs.ubifs -r ${CACHE_IMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS} -o ${CACHE_UBIFS_TARGET} ${MKUBIFS_CACHE_ARGS}
   mkfs.ubifs -r ${PERSIST_IMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS} -o ${PERSIST_UBIFS_TARGET} ${MKUBIFS_PERSIST_ARGS}
   if ${@bb.utils.contains('IMAGE_FEATURES', 'modem-volume', 'true', 'false', d)}; then
       if [ -d ${MODEM_IMAGE_DIR} ]; then
           mkfs.ubifs -r ${MODEM_IMAGE_DIR} --selinux=${SELINUX_CONTEXT_MODEM} -o ${MODEM_UBIFS_IMAGE} ${MKUBIFS_ARGS}
       fi
   fi
   mkfs.ubifs -r ${IMAGE_ROOTFS_UBIFS_UBI} ${IMAGE_UBIFS_SELINUX_OPTIONS} -o ${SYSTEM_IMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}

   ubinize -o ${SYSTEM_IMAGE_UBI_TARGET} ${UBINIZE_ARGS} ${UBINIZE_SYSTEM_CFG}
}

do_makesystem_squashfs[prefuncs] += "do_create_squash_ubinize_config_ab"
do_makesystem_squashfs[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs"
do_makesystem_squashfs_ubi_with_lxc[prefuncs] += "do_create_squash_ubinize_config_ab_with_lxc"
do_makesystem_squashfs_ubi_with_lxc[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/lxc/squashfs"
do_makesystem_squashfs_ubi_with_lxc[depends] = "qti-lxcrootfs-image:do_build"
do_makesystem_squashfs_ubi_with_lxc[prefuncs] += "do_sign_lxc_squashfs"

fakeroot do_makesystem_squashfs() {
    if ${@bb.utils.contains('IMAGE_FEATURES', 'modem-volume', 'true', 'false', d)}; then
        if [ -d ${MODEM_IMAGE_DIR} ]; then
            mksquashfs ${MODEM_IMAGE_DIR} ${MODEM_SQUASHFS_IMAGE} -context-file ${SELINUX_CONTEXT_MODEM} -noappend -comp gzip -Xcompression-level 9 -noI -b 65536 -processors 1
        fi
    fi
    if [[ "${DISTRO_FEATURES}" =~ "selinux" ]] ; then
        mksquashfs ${IMAGE_ROOTFS_SQUASHFS_UBI} ${SYSTEMIMAGE_SQUASHFS_TARGET} -context-file ${SELINUX_FILE_CONTEXTS} -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1
    else
        mksquashfs ${IMAGE_ROOTFS_SQUASHFS_UBI} ${SYSTEMIMAGE_SQUASHFS_TARGET} -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1
    fi
}
do_makesystem_squashfs_ubi () {
    ubinize -o ${SYSTEMIMAGE_SQUASHFS_UBI_AB_TARGET} ${UBINIZE_ARGS} ${SQUASHFS_UBINIZE_CFG_AB}
}

do_makesystem_squashfs_ubi_with_lxc () {
    ubinize -o ${SYSTEMIMAGE_SQUASHFS_UBI_AB_TARGET_WITH_LXC} ${UBINIZE_ARGS} ${SQUASHFS_UBINIZE_CFG_AB_WITH_LXC}
}

fakeroot do_makesystem_tele_ubi_with_lxc() {
   ubinize -o ${SYSTEM_IMAGE_UBI_TARGET_WITH_LXC} ${UBINIZE_ARGS} ${UBINIZE_SYSTEM_CFG_WITH_LXC}
}


do_maketelaf_squashfs[depends] += "${@bb.utils.contains('IMAGE_FEATURES', 'telaf-volume', '${MLIBPREFIX}telaf-image:do_deploy', '', d)}"
do_maketelaf_squashfs[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs"

fakeroot do_maketelaf_squashfs() {
    if [[ "${DISTRO_FEATURES}" =~ "selinux" ]] ; then
        mksquashfs ${TELAF_RO_IMAGE_PATH} ${TELAF_RO_SQUASHFS_TARGET} -context-file ${TELAF_RO_SELINUX_FILE_CONTEXTS} -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1 -all-root
    else
        mksquashfs ${TELAF_RO_IMAGE_PATH} ${TELAF_RO_SQUASHFS_TARGET} -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1 -all-root
    fi
}

# Need to copy squashfs_ubinize_vm.cfg file in the deploy directory
do_create_squashfs_ubinize_vm_config[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/"
do_create_squashfs_ubinize_vm_config() {
    cat << EOF > ${SQUASHFS_UBINIZE_VM_CFG}
[vm-bootsys_volume]
mode=ubi
image="${VM_IMAGE_SQUASHFS_TARGET}"
vol_id=0
vol_type=dynamic
vol_name=vm-bootsys
vol_size="${VM_BOOTSYS_SQUASHFS_VOLUME_SIZE}"

[vm_systemrw_volume]
mode=ubi
image="${VMSYSTEMRW_IMAGE_UBIFS_TARGET}"
vol_id=1
vol_type=dynamic
vol_name=vm_systemrw
vol_flags=autoresize
EOF

}

do_make_vmbootsys_squashfs[prefuncs] += "do_create_squashfs_ubinize_vm_config"
do_make_vmbootsys_squashfs[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/"

fakeroot do_make_vmbootsys_squashfs() {
    if [[ "${DISTRO_FEATURES}" =~ "selinux" ]] ; then
        mksquashfs ${VM_IMAGE_ROOTFS} ${VM_IMAGE_SQUASHFS_TARGET} -context-file ${SELINUX_FILE_CONTEXTS} -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1
    else
        mksquashfs ${VM_IMAGE_ROOTFS} ${VM_IMAGE_SQUASHFS_TARGET} -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1
    fi

    ubinize -o ${VM_IMAGE_UBI_TARGET} ${UBINIZE_ARGS} ${SQUASHFS_UBINIZE_VM_CFG}
}

python () {
    if bb.utils.contains('IMAGE_FEATURES', 'vm', True, False, d):
        bb.build.addtask('do_make_vmbootsys_squashfs', 'do_image_complete', 'do_compose_vmimage', d)
        if bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v4', True, False, d) and bb.utils.contains('DISTRO_FEATURES', 'qti-vm-guest', True, False, d):
            bb.build.addtask('do_sign_vmbootsys_squashfs', 'do_image_complete', 'do_make_vmbootsys_squashfs', d)
    elif bb.utils.contains('IMAGE_FEATURES', 'gluebi', True, False, d) and bb.utils.contains('DISTRO_FEATURES', 'dm-verity', True, False, d):
        bb.build.addtask('do_makesystem_gluebi', 'do_image_complete', 'do_image', d)
    else:
        bb.build.addtask('do_makesystem_tele_ubi', 'do_image_complete', 'do_makesystem_ubi', d)
        if bb.utils.contains('MACHINE_FEATURES', 'qti-tele-lxc', True, False, d):
           bb.build.addtask('do_makesystem_tele_ubi_with_lxc', 'do_image_complete', 'do_makesystem_tele_ubi', d)
        bb.build.addtask('do_makesystem_squashfs', 'do_image_complete', 'do_makesystem_tele_ubi', d)
        if bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', True, False, d):
            bb.build.addtask('do_maketelaf_squashfs', 'do_image_complete', 'do_makesystem_ubi', d)
        if bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v4', True, False, d):
            bb.build.addtask('do_sign_system_squashfs', 'do_image_complete', 'do_makesystem_squashfs', d)
            bb.build.addtask('do_makesystem_squashfs_ubi', 'do_image_complete', 'do_sign_system_squashfs', d)
            if bb.utils.contains('MACHINE_FEATURES', 'qti-tele-lxc', True, False, d):
               bb.build.addtask('do_makesystem_squashfs_ubi_with_lxc', 'do_image_complete', 'do_makesystem_squashfs_ubi', d)
            if bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', True, False, d):
                bb.build.addtask('do_sign_telaf_squashfs', 'do_image_complete', 'do_maketelaf_squashfs', d)
        else:
            bb.build.addtask('do_makesystem_squashfs_ubi', 'do_image_complete', 'do_makesystem_squashfs', d)
            if bb.utils.contains('MACHINE_FEATURES', 'qti-tele-lxc', True, False, d):
               bb.build.addtask('do_makesystem_squashfs_ubi_with_lxc', 'do_image_complete', 'do_makesystem_squashfs_ubi', d)
}

do_patch_ubi_tools() {

     if [ -f ${STAGING_DIR}-components/x86_64/squashfs-tools-native/${sbindir}/mksquashfs ]; then
         ${UNINATIVE_STAGING_DIR}-uninative/x86_64-linux/usr/bin/patchelf-uninative --set-interpreter /lib64/ld-linux-x86-64.so.2 ${STAGING_DIR}-components/x86_64/squashfs-tools-native${sbindir}/mksquashfs
     else 
         ${UNINATIVE_STAGING_DIR}-uninative/x86_64-linux/usr/bin/patchelf-uninative --set-interpreter /lib64/ld-linux-x86-64.so.2 ${STAGING_DIR}-components/x86_64/squashfs-tools-native${base_bindir}/mksquashfs 
     fi
}

# Default Image names
SYSTEMIMAGE_GLUEBI_TARGET ?= "system-gluebi.ext4"
SYSTEMIMAGE_GLUEBI_MAP_TARGET ?= "system-gluebi.map"

IMAGE_EXT4_SELINUX_OPTIONS ?= "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '-S ${SELINUX_FILE_CONTEXTS}', '', d)}"

################################################
### Generate system.img #####
################################################
do_makesystem_gluebi() {
    # Build ext4 system image
    cp ${MACHINE_FSCONFIG_CONF_FULL_PATH} ${UNPACKDIR}/rootfs-fsconfig-gluebi.conf
    make_ext4fs -C ${UNPACKDIR}/rootfs-fsconfig-gluebi.conf \
            -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_GLUEBI_MAP_TARGET} \
            -a / -b 4096 \
            -l ${SYSTEM_IMAGE_ROOTFS_SIZE} \
            ${IMAGE_EXT4_SELINUX_OPTIONS} \
            ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_GLUEBI_TARGET} ${IMAGE_ROOTFS_SQUASHFS_UBI}

    # Continue building ubifs images and generate ubi
    mkfs.ubifs -r ${USER_IMAGE_ROOTFS} -o ${USER_IMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}
}

do_verity_ubinize() {
    # Put the new sysfs.ubi in the verity specific folder after verity images have been generated
    ubinize -v -o "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/verity/${SYSTEMIMAGE_GLUEBI_TARGET}/${SYSTEM_IMAGE_UBI_TARGET}" ${UBINIZE_ARGS} ${UBINIZE_SYSTEM_CFG}
}
do_makesystem_gluebi[prefuncs] += "create_rootfs_tele_ubi"
do_makesystem_gluebi[prefuncs] += "create_symlink_tele_userfs"
do_makesystem_gluebi[prefuncs] += "cleanup_squashfs_rootfs"
do_makesystem_gluebi[prefuncs] += "do_create_ubinize_tele_config"
do_makesystem_gluebi[prefuncs] += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', 'adjust_system_size_for_verity', '', d), '', d)}"
do_makesystem_gluebi[postfuncs] += "${@bb.utils.contains('INHERIT', 'uninative', 'do_patch_ubi_tools', '', d)}"
do_makesystem_gluebi[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_verity_ubinize[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', '${PN}:do_make_verity_enabled_system_image', bb.utils.contains('IMAGE_FEATURES', 'gluebi', '${PN}:do_makesystem_gluebi', '', d), d)}"
do_verity_ubinize[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

python() {
    if bb.utils.contains('DISTRO_FEATURES', 'dm-verity', True, False, d) and bb.utils.contains('IMAGE_FEATURES', 'gluebi', True, False, d):
        bb.build.addtask('do_verity_ubinize', 'do_image_complete', 'do_make_verity_enabled_system_image', d)
    elif bb.utils.contains('IMAGE_FEATURES', 'gluebi', True, False, d):
        bb.build.addtask('do_verity_ubinize', 'do_image_complete', 'do_makesystem_gluebi', d)
}

#telaf squashfs files
TELAF_IMAGE_SQUASHFS_TARGET = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/telaf_ro.squashfs"

# Sign the telaf image
do_sign_telaf_squashfs () {
    ${TMPDIR}/work-shared/avbtool/avbtool add_hashtree_footer \
        --image ${TELAF_IMAGE_SQUASHFS_TARGET} \
        --partition_name telaf \
        --algorithm SHA256_RSA2048 \
        --key ${TMPDIR}/work-shared/avbtool/qpsa_attestca.key \
        --public_key_metadata ${TMPDIR}/work-shared/avbtool/qpsa_attestca.der \
        --do_not_generate_fec --rollback_index 0
}
do_sign_telaf_squashfs[depends] += "avbtool-native:do_install"

# Sign the vmbootsys image
do_sign_vmbootsys_squashfs[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/squashfs/"
do_sign_vmbootsys_squashfs () {
    ${TMPDIR}/work-shared/avbtool/avbtool add_hashtree_footer \
        --image ${VM_IMAGE_SQUASHFS_TARGET} \
        --partition_name vm-bootsys \
        --algorithm SHA256_RSA2048 \
        --key ${TMPDIR}/work-shared/avbtool/qpsa_attestca.key \
        --public_key_metadata ${TMPDIR}/work-shared/avbtool/qpsa_attestca.der \
        --do_not_generate_fec --rollback_index 0
}
do_sign_vmbootsys_squashfs[depends] += "avbtool-native:do_install"


# Sign the lxc squash image
do_sign_lxc_squashfs () {
    ${TMPDIR}/work-shared/avbtool/avbtool add_hashtree_footer \
        --image ${LXCRFSIMAGE_SQUASHFS_TARGET} \
        --partition_name lxcrootfs \
        --algorithm SHA256_RSA2048 \
        --key ${TMPDIR}/work-shared/avbtool/qpsa_attestca.key \
        --public_key_metadata ${TMPDIR}/work-shared/avbtool/qpsa_attestca.der \
        --do_not_generate_fec --rollback_index 0
}
do_sign_lxc_squashfs[depends] += "avbtool-native:do_install"
