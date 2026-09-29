################################################
### Generate userdata.img ###
################################################
inherit qimage-utils
USERDATAIMAGE_TARGET ?= "userdata.img"
USERDATAIMAGE_MAP_TARGET ?= "userdata.map"
USERDATA_DIR ??= "data"
USERDATA_IMAGE_ROOTFS_SIZE = "${@get_size_in_bytes(d.getVar('USERDATA_SIZE') or '1GB')}"
MACHINE_FSCONFIG_CONF_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/fsconfig' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FSCONFIG_CONF_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FSCONFIG_CONF'), d.getVar('MACHINE_FSCONFIG_CONF_SEARCH_PATH')) or ''}"

DEPENDS += "${@bb.utils.contains('USERDATA_FSTYPE', 'f2fs', 'f2fs-tools-android-native', '', d)} "

do_makeuserdata[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makeuserdata() {
    echo $MACHINE_FSCONFIG_CONF_FULL_PATH
    cp ${MACHINE_FSCONFIG_CONF_FULL_PATH} ${UNPACKDIR}/rootfs-fsconfig.conf
    if ${@bb.utils.contains('USERDATA_FSTYPE', 'f2fs', 'true', 'false', d)}; then
        bbnote "Generating ${USERDATAIMAGE_TARGET} with f2fs file system"
        dd if=${IMAGE_ROOTFS}/${USERDATA_DIR} of=${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET} \
	      seek=${USERDATA_IMAGE_ROOTFS_SIZE} count=0 bs=1
        mkfs.f2fs -O encrypt -S ${USERDATA_IMAGE_ROOTFS_SIZE} -f -R root:root \
	      ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET}
    else
        bbnote "Generating ${USERDATAIMAGE_TARGET} with ext4 file system"
        make_ext4fs -C ${UNPACKDIR}/rootfs-fsconfig.conf \
                    -B ${IMGDEPLOYDIR}/${USERDATAIMAGE_MAP_TARGET} \
                    -a /data ${IMAGE_EXT4_SELINUX_OPTIONS} \
                    ${SPARSE_SYSTEMIMAGE_FLAG} -b 4096 -l ${USERDATA_IMAGE_ROOTFS_SIZE} \
                    ${IMGDEPLOYDIR}/${USERDATAIMAGE_TARGET} \
                    ${IMAGE_ROOTFS}/${USERDATA_DIR}
    fi
}

addtask do_makeuserdata after do_makesystem before do_build
