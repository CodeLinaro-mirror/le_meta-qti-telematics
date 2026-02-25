INIT_RAMDISK = "${@d.getVar('MACHINE_SUPPORTS_INIT_RAMDISK') or "False"}"
FLASHLESS_MCU = "${@d.getVar('MACHINE_SUPPORTS_FLASHLESS_MEMORY') or "False"}"
RAMDISKDIR = "${WORKDIR}/ramdisk"
RAMDISKDIRFDE = "${WORKDIR}/ramdiskfde"
RAMDISKDIRDEBUG = "${WORKDIR}/ramdiskdebug"
OVERLAY_ENABLED ?= "False"

MLIBPREFIX ?= ""
TOYBOX_RAMDISK ?= "False"
ENABLE_ADB = "True"
ENABLE_ADB:qti-distro-base-user ?= "False"
ENABLE_ADB:sa525m ?= "False"
ENABLE_ADB:sa510m ?= "False"
USB_AUTOSUSPEND_SUPPORT = "${@d.getVar('MACHINE_SUPPORTS_USB_AUTOSUSPEND') or "True"}"
PACKAGE_INSTALL += "${@oe.utils.conditional('ENABLE_ADB', 'True', '${MLIBPREFIX}adbd ${MLIBPREFIX}usb-composition', '', d)}"
PACKAGE_INSTALL += "${@oe.utils.conditional('USB_AUTOSUSPEND_SUPPORT', 'True', '${MLIBPREFIX}usb-composition-usbd', '', d)}"
PACKAGE_INSTALL += "${@oe.utils.conditional('TOYBOX_RAMDISK', 'True', 'toybox mksh gawk coreutils ethtool iputils devmem2 tcpdump', '', d)}"
PACKAGE_INSTALL += "${@oe.utils.conditional('FLASHLESS_MCU', 'True', 'nbd-client techpack-ecpri', '', d)}"
DEPENDS += "${@oe.utils.conditional('FLASHLESS_MCU', 'True', 'binutils-cross-${TARGET_ARCH}', '', d)}"

KERNEL_VERSION = "${@oe.utils.read_file('${STAGING_KERNEL_BUILDDIR}/kernel-abiversion')}"

# Adding mtd-utils to support dm-verity v4 for NAND
PACKAGE_INSTALL += "${@bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v4', '${MLIBPREFIX}mtd-utils ${MLIBPREFIX}avbtool ${MLIBPREFIX}cryptsetup ${MLIBPREFIX}nad-abctl ${MLIBPREFIX}util-linux-libuuid ${MLIBPREFIX}json-c', '', d)}"

inherit qdlkm

do_ramdisk_create[depends] += "virtual/kernel:do_deploy"
do_ramdisk_create[cleandirs] += "${RAMDISKDIR}"
do_ramdisk_create[cleandirs] += "${RAMDISKDIRFDE}"
do_ramdisk_create[cleandirs] += "${RAMDISKDIRDEBUG}"
fakeroot do_ramdisk_create() {
        mkdir -p ${RAMDISKDIR}/bin
        mkdir -p ${RAMDISKDIR}/etc
        mkdir -p ${RAMDISKDIR}/etc/init.d
        mkdir -p ${RAMDISKDIR}/lib
        mkdir -p ${RAMDISKDIR}/lib/modules
        mkdir -p ${RAMDISKDIR}/usr
        mkdir -p ${RAMDISKDIR}/usr/bin
        mkdir -p ${RAMDISKDIR}/usr/sbin
        mkdir -p ${RAMDISKDIR}/usr/lib
        if [[ "${FLASHLESS_MCU}" == "True" ]]; then
            mkdir -p ${RAMDISKDIR}/lib/firmware/qcom_aw_phy/
            mkdir -p ${RAMDISKDIR}/usr/share/dhcpcd/hooks/
            mkdir -p ${RAMDISKDIR}/usr/libexec/dhcpcd-hooks
            mkdir -p ${RAMDISKDIR}/usr/lib/dhcpcd/dev/
            mkdir -p ${RAMDISKDIR}/var/db/dhcpcd/
        fi
        mkdir -p ${RAMDISKDIR}/dev
        mknod -m 0600 ${RAMDISKDIR}/dev/console c 5 1
        mknod -m 0600 ${RAMDISKDIR}/dev/tty c 5 0
        mknod -m 0600 ${RAMDISKDIR}/dev/tty0 c 4 0
        mknod -m 0600 ${RAMDISKDIR}/dev/tty1 c 4 1
        mknod -m 0600 ${RAMDISKDIR}/dev/tty2 c 4 2
        mknod -m 0600 ${RAMDISKDIR}/dev/tty3 c 4 3
        mknod -m 0600 ${RAMDISKDIR}/dev/tty4 c 4 4
        mknod -m 0600 ${RAMDISKDIR}/dev/zero c 1 5
        mkdir -p ${RAMDISKDIR}/dev/pts
        mkdir -p ${RAMDISKDIR}/root
        mkdir -p ${RAMDISKDIR}/proc
        mkdir -p ${RAMDISKDIR}/sys
        cd ${RAMDISKDIR}
        ln -s bin sbin
        if [[ "${TOYBOX_RAMDISK}" == "True" ]]; then
            cp ${IMAGE_ROOTFS}/usr/lib/libcrypt.so.2 lib/libcrypt.so.2
            cp ${IMAGE_ROOTFS}/bin/toybox bin/
            cp ${IMAGE_ROOTFS}/bin/mksh bin/
            cp ${IMAGE_ROOTFS}/lib/libcap.so.2 lib/libcap.so.2
            cp ${IMAGE_ROOTFS}/usr/lib/libgcrypt.so.20 lib/libgcrypt.so.20
            cp ${IMAGE_ROOTFS}/usr/sbin/ethtool bin/
            cp ${IMAGE_ROOTFS}/bin/ping.iputils bin/
            cp ${IMAGE_ROOTFS}/bin/arping bin/
            cp ${IMAGE_ROOTFS}/usr/lib/libgpg-error.so.0 lib/libgpg-error.so.0
            cp ${IMAGE_ROOTFS}/usr/bin/devmem2 bin/
            cp ${IMAGE_ROOTFS}/usr/sbin/tcpdump bin/
            cp ${IMAGE_ROOTFS}/usr/lib/libpcap.so.1 lib/libpcap.so.1
            cp ${IMAGE_ROOTFS}/usr/lib/libcrypto.so.1.1 lib/
            ln -s mksh bin/sh
            ln -s ping.iputils bin/ping
            ln -s devmem2 bin/devmem

            # Don't install redundant packages for VM image
            if ${@bb.utils.contains('IMAGE_FEATURES', 'vm', 'false', 'true', d)}; then
                cp ${IMAGE_ROOTFS}/usr/lib/libreadline.so.8 lib/libreadline.so.8 #awk support
                cp ${IMAGE_ROOTFS}/lib/libtinfo.so.5 lib/libtinfo.so.5
                cp ${IMAGE_ROOTFS}/lib/libext2fs.so.2 lib/libext2fs.so.2
                cp ${IMAGE_ROOTFS}/lib/libcom_err.so.2 lib/libcom_err.so.2
                cp ${IMAGE_ROOTFS}/lib/libblkid.so.1 lib/libblkid.so.1
                cp ${IMAGE_ROOTFS}/usr/lib/libuuid.so.1 lib/libuuid.so.1
                cp ${IMAGE_ROOTFS}/lib/libe2p.so.2 lib/libe2p.so.2
                cp ${IMAGE_ROOTFS}/usr/lib/libgmp.so.10 lib/libgmp.so.10
                cp ${IMAGE_ROOTFS}/usr/lib/libmnl.so.0 lib/libmnl.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libelf.so.1 lib/libelf.so.1
                cp ${IMAGE_ROOTFS}/lib/libcap.so.2 lib/libcap.so.2
                cp ${IMAGE_ROOTFS}/bin/toybox bin/
                cp ${IMAGE_ROOTFS}/bin/mksh bin/
                cp ${IMAGE_ROOTFS}/usr/bin/gawk bin/
                cp ${IMAGE_ROOTFS}/usr/bin/expr.coreutils bin/
                cp ${IMAGE_ROOTFS}/usr/bin/tr.coreutils bin/
                cp ${IMAGE_ROOTFS}/sbin/ip.iproute2 bin/
                ln -s gawk bin/awk
                ln -s expr.coreutils bin/expr
                ln -s tr.coreutils bin/tr
                ln -s ip.iproute2 bin/ip
            fi
            # install all the toybox commands
            if [ -r ${IMAGE_ROOTFS}/etc/toybox.links ]; then
                while read -r LREAD; do
                    ln -s /bin/toybox ${LREAD:1}
                done < ${IMAGE_ROOTFS}/etc/toybox.links
            fi
        else
            cp ${IMAGE_ROOTFS}/bin/busybox bin/
            cp ${IMAGE_ROOTFS}/bin/busybox.suid bin/
            cp ${COREBASE}/meta/recipes-core/base-files/base-files/fstab etc/
            cp ${COREBASE}/meta/recipes-core/busybox/files/inittab etc/
            cp ${COREBASE}/meta/recipes-core/base-files/base-files/profile etc/
            cp ${COREBASE}/meta/recipes-core/busybox/files/rcS etc/init.d
            # Run rcS script only if busybox is init manager in ramdisk.
            # In other cases, ramdisk will be used in early boot but no init in busybox.
            if ${@oe.utils.conditional('INIT_RAMDISK', 'True', 'true', 'false', d)}; then
                chmod 744 etc/init.d/rcS
            fi
            ln -s busybox bin/sh
            ln -s busybox bin/echo
            ln -s busybox.suid bin/mount
            ln -s busybox.suid bin/umount
            if ${@bb.utils.contains('IMAGE_DEV_MANAGER', 'mdev', 'true', 'false', d)}; then
                ln -s busybox bin/mdev
            fi
        fi

        if [[ "${FLASHLESS_MCU}" == "True" ]]; then
            cp ${IMAGE_ROOTFS}/usr/sbin/nbd-client.nbd bin/nbdclient
            cp ${IMAGE_ROOTFS}/etc/nbdtab etc/

            # DMA kos
            cp ${IMAGE_ROOTFS}/usr/lib/modules/gsim.ko lib/modules/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/ecpri_dmam.ko lib/modules/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/fpc_qsfp.ko lib/modules/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/lassen_qcom_aw_phy.ko lib/modules/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/lassen_mtip.ko lib/modules/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/lassen_secure_eip.ko lib/modules/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/ecpri_core.ko lib/modules/
            cp ${IMAGE_ROOTFS}/lib/firmware/qcom_aw_phy/eth_custom_rates_1.hex lib/firmware/qcom_aw_phy/

            # strip and sign the KOs
            do_strip_and_sign_dlkm lib/modules/gsim.ko
            do_strip_and_sign_dlkm lib/modules/ecpri_dmam.ko
            do_strip_and_sign_dlkm lib/modules/fpc_qsfp.ko
            do_strip_and_sign_dlkm lib/modules/lassen_qcom_aw_phy.ko
            do_strip_and_sign_dlkm lib/modules/lassen_mtip.ko
            do_strip_and_sign_dlkm lib/modules/lassen_secure_eip.ko
            do_strip_and_sign_dlkm lib/modules/ecpri_core.ko

            # install dhcpcd
            cp ${IMAGE_ROOTFS}/etc/dhcpcd.conf etc/
            cp ${IMAGE_ROOTFS}/usr/lib/dhcpcd/dev/udev.so usr/lib/dhcpcd/dev/
            cp ${IMAGE_ROOTFS}/usr/libexec/dhcpcd-hooks/01-test usr/libexec/dhcpcd-hooks/
            cp ${IMAGE_ROOTFS}/usr/libexec/dhcpcd-hooks/02-dump usr/libexec/dhcpcd-hooks/
            cp ${IMAGE_ROOTFS}/usr/libexec/dhcpcd-hooks/20-resolv.conf usr/libexec/dhcpcd-hooks/
            cp ${IMAGE_ROOTFS}/usr/libexec/dhcpcd-hooks/30-hostname usr/libexec/dhcpcd-hooks/3
            cp ${IMAGE_ROOTFS}/usr/libexec/dhcpcd-hooks/50-ntp.conf usr/libexec/dhcpcd-hooks/
            cp ${IMAGE_ROOTFS}/usr/libexec/dhcpcd-run-hooks usr/libexec/
            cp ${IMAGE_ROOTFS}/usr/sbin/dhcpcd usr/sbin/
            cp ${IMAGE_ROOTFS}/usr/share/dhcpcd/hooks/10-wpa_supplicant usr/share/dhcpcd/hooks/
            cp ${IMAGE_ROOTFS}/usr/share/dhcpcd/hooks/15-timezone usr/share/dhcpcd/hooks/
            cp ${IMAGE_ROOTFS}/usr/share/dhcpcd/hooks/29-lookup-hostname usr/share/dhcpcd/hooks/
            #install csm_ru_nwboot_client
            cp ${IMAGE_ROOTFS}/usr/sbin/csm_ru_nwboot_client usr/sbin
        fi

        if ${@bb.utils.contains('IMAGE_FEATURES', 'vm', 'true', 'false', d)}; then
            if [[ "${TOYBOX_RAMDISK}" == "True" ]]; then
                cp ${COREBASE}/meta-qti-bsp/recipes-products/images/include/vmrd-init-toybox vmrd-init
            else
                cp ${COREBASE}/../meta-qti-telematics/recipes-products/images/include/vmrd-init .
            fi
            chmod 744 vmrd-init
            ln -s vmrd-init init
        else
            if [[ "${ENABLE_ADB}" == "True" ]]; then
                cp ${IMAGE_ROOTFS}/sbin/adbd sbin/
                cp ${IMAGE_ROOTFS}/usr/lib/libadbd.so.0 lib/libadbd.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libext4_utils.so.0 lib/libext4_utils.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libbase.so.0 lib/libbase.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libfs_mgr.so.0 lib/libfs_mgr.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/liblog.so.0 lib/liblog.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libcutils.so.0 lib/libcutils.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libsparse.so.0 lib/libsparse.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libmincrypt.so.0 lib/libmincrypt.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libgthread-2.0.so.0 lib/libgthread-2.0.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libglib-2.0.so.0 lib/libglib-2.0.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/liblogwrap.so.0 lib/liblogwrap.so.0
                cp ${IMAGE_ROOTFS}/lib/libgcc_s.so.1 lib/libgcc_s.so.1
                cp ${IMAGE_ROOTFS}/sbin/usb_composition sbin/
                cp -r ${IMAGE_ROOTFS}/sbin/usb/ sbin/
                cp ${IMAGE_ROOTFS}/usr/lib/libstdc++.so.6 lib/libstdc++.so.6
            fi

            if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-csm', 'true', 'false', d)}; then
                cp ${COREBASE}/meta-qti-bsp/recipes-products/images/include/csmrd-init .
                chmod 744 csmrd-init
                ln -s csmrd-init init
            elif ${@bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v4', 'true', 'false', d)}; then
                if ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'true', 'false', d)}; then
                    install -m 744 ${COREBASE}/../meta-qti-telematics/recipes-products/images/include/ramdisk-init-emmc.sh init
                else
                    install -m 744 ${COREBASE}/../meta-qti-telematics/recipes-products/images/include/ramdisk-init.sh init
                fi

                # Creating actual rootfs dir mountpoint for initramfs
                mkdir -p ${RAMDISKDIR}/rootfs
                cp ${IMAGE_ROOTFS}/usr/sbin/ubiblock usr/sbin/
                cp ${IMAGE_ROOTFS}/usr/sbin/ubiattach usr/sbin/
                cp ${IMAGE_ROOTFS}/usr/bin/nad-abctl usr/bin/nad-abctl
                cp ${IMAGE_ROOTFS}/usr/lib/libnad_ab_al.so.1 lib/libnad_ab_al.so.1
                cp ${IMAGE_ROOTFS}/usr/lib/libgthread-2.0.so.0 lib/libgthread-2.0.so.0
                cp ${IMAGE_ROOTFS}/usr/lib/libglib-2.0.so.0 lib/libglib-2.0.so.0
                ln -s busybox bin/dd
            else
                ln -s bin/busybox init
            fi
        fi

        if [ "${TARGET_ARCH}" = "arm" ] || [ "${MLIBPREFIX}" = "lib32-" ]; then
            cp ${IMAGE_ROOTFS}/lib/ld-linux-armhf.so.3 lib/ld-linux-armhf.so.3
        else
            cp ${IMAGE_ROOTFS}/lib/ld-linux-aarch64.so.1 lib/ld-linux-aarch64.so.1
        fi

        cp ${IMAGE_ROOTFS}/lib/libz.so.1 lib/libz.so.1
        cp ${IMAGE_ROOTFS}/lib/libc.so.6 lib/libc.so.6
        cp ${IMAGE_ROOTFS}/lib/libm.so.6 lib/libm.so.6
        cp ${IMAGE_ROOTFS}/lib/librt.so.1 lib/librt.so.1
        cp ${IMAGE_ROOTFS}/lib/libpthread.so.0 lib/libpthread.so.0
        cp ${IMAGE_ROOTFS}/lib/libdl.so.2 lib/libdl.so.2
        cp ${IMAGE_ROOTFS}/lib/libresolv.so.2 lib/libresolv.so.2
        if ${@bb.utils.contains('IMAGE_DEV_MANAGER', 'mdev', 'true', 'false', d)}; then
            cp ${IMAGE_ROOTFS}/etc/init.d/mdev etc/init.d/
            cp ${IMAGE_ROOTFS}/etc/mdev.conf etc/
            cp -r ${IMAGE_ROOTFS}/etc/mdev etc/
            cat etc/init.d/mdev >> etc/init.d/rcS
        fi

        if ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'true', 'false', d)}; then
            cp ${IMAGE_ROOTFS}/lib/libselinux.so.1 lib/libselinux.so.1
        fi

        # meta-selinux layer does not currently check for distro_features
        if [ -f ${IMAGE_ROOTFS}/usr/lib/libpcre2-8.so.0 ]; then
            cp ${IMAGE_ROOTFS}/usr/lib/libpcre2-8.so.0 lib/libpcre2-8.so.0
        else
            cp ${IMAGE_ROOTFS}/usr/lib/libpcre.so.1 lib/libpcre.so.1
        fi

        if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains_any('MACHINE_FEATURES', 'dm-verity-initramfs dm-verity-initramfs-v3 dm-verity-initramfs-v4', 'true', 'false', d), 'false', d)}; then

            # Copy certificates
            mkdir -p etc/keys
            cp ${IMAGE_ROOTFS}/etc/keys/x509_root.der etc/keys/x509_root.der

            cp ${IMAGE_ROOTFS}/etc/verity.env  etc/

            # Tools required to enable dmverity
            cp ${IMAGE_ROOTFS}/usr/sbin/verified-boot usr/sbin/
            cp ${IMAGE_ROOTFS}/usr/sbin/veritysetup bin/

            # Shared library dependencies for verified-boot
            cp ${IMAGE_ROOTFS}/usr/lib/libcryptsetup.so.12 lib/
            cp ${IMAGE_ROOTFS}/lib/libblkid.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libpopt.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libuuid.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libdevmapper.so.1.02 lib/
            if [ -f ${IMAGE_ROOTFS}/usr/lib/libssl.so.3 ]; then
                 cp ${IMAGE_ROOTFS}/usr/lib/libssl.so.3 lib/
            fi
            cp ${IMAGE_ROOTFS}/usr/lib/libcrypto.so.3 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libjson-c.so.5 lib/
            cp ${IMAGE_ROOTFS}/lib/libudev.so.1 lib/
            cp ${IMAGE_ROOTFS}/lib/libmount.so.1 lib/
            cp ${IMAGE_ROOTFS}/lib/libcap.so.2 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libavb.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libnad-vb.so.1 lib/

        fi

        # Generate ramdisk image with fde dependencies
        if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-nad-fde', 'true', 'false', d)}; then
            # Copies FDE dependencies in fde ramdisk dir
            cp -rf ${RAMDISKDIR}/* ${RAMDISKDIRFDE}
            # Remove the below line if FDE has to be enabled in boot.img
            cd ${RAMDISKDIRFDE}
            echo "nad_fde=1" >> etc/fde.env
            cp ${IMAGE_ROOTFS}/usr/bin/nad-fde-app usr/bin/
            cp ${IMAGE_ROOTFS}/usr/bin/qseecomd usr/bin/
            cp ${IMAGE_ROOTFS}/usr/sbin/cryptsetup usr/sbin/
            cp ${IMAGE_ROOTFS}/lib/libgcc_s.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libnad-vb.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libavb.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libnad-vb.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libnad-km.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libnad-keystore-rw.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libnad_mtd_al.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libcrypto.so.3 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libKeyMaster.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libqcbor.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libcbor.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libcutils.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libutils.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/liblog.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libminkdescriptor.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libstdc++.so.6 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libcryptsetup.so.12 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libdmabufheap.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libbase.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libion.so.0 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/librpmb.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libQseeComApi.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libdrmfs.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libxml2.so.2 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libGPreqcancel.so lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libGPreqcancel_svc.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libdrmtime.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libQseeComApi.so.1 lib/
            cp ${IMAGE_ROOTFS}/etc/gpfspath_le_oem_config.xml etc/
            cp ${IMAGE_ROOTFS}/usr/lib/modules/smcinvoke.ko lib/modules/
            cp ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}/dm-crypt.ko lib/modules/
            if ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'false', 'true', d)}; then
              cp ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}/loop.ko lib/modules/
            fi

            # gen_initramfs_list.sh expects to be run from kernel directory
            cd ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts
            # remove the initrd-fde.gz file if exist
            rm -rf ${IMGDEPLOYDIR}/${PN}-initrd-fde.gz
            # gen_initramfs.sh uses gen_init_cpio to generate the cpio archive.
            bash ./scripts/gen_initramfs.sh -o ${IMGDEPLOYDIR}/${PN}-initrd-fde -u 0 -g 0 ${RAMDISKDIRFDE}
            gzip -n -9 -f ${IMGDEPLOYDIR}/${PN}-initrd-fde
        fi

        if ${@bb.utils.contains('DISTRO_FEATURES','usrmerge','true','false',d)}; then
            mv lib/* usr/lib/
            mv bin/* usr/bin/
            rm -rf lib bin
            ln -s usr/lib lib
            ln -s usr/bin bin
        fi

        #gen_initramfs_list.sh expects to be run from kernel directory
        cd ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts
        # remove the initrd.gz file if exist
        rm -rf ${IMGDEPLOYDIR}/${PN}-initrd.gz
        # gen_initramfs.sh uses gen_init_cpio to generate the cpio archive.
        bash ./scripts/gen_initramfs.sh -o ${IMGDEPLOYDIR}/${PN}-initrd -u 0 -g 0 ${RAMDISKDIR}
        gzip -n -9 -f ${IMGDEPLOYDIR}/${PN}-initrd

        if [[ "${OVERLAY_ENABLED}" == "True" ]]; then


            cd ${RAMDISKDIRDEBUG}
            cp -rf ${RAMDISKDIR}/* ./

            if  ${@bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v4', 'true', 'false', d)}; then
               install -m 744 ${COREBASE}/../meta-qti-telematics/recipes-products/images/include/ramdisk-init-debug.sh init
            fi

            # gen_initramfs_list.sh expects to be run from kernel directory
            cd ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts
            # remove the initrd-overlay.gz file if exist
            rm -rf ${IMGDEPLOYDIR}/${PN}-initrd-debug.gz

            # gen_initramfs.sh uses gen_init_cpio to generate the cpio archive.
            bash ./scripts/gen_initramfs.sh -o ${IMGDEPLOYDIR}/${PN}-initrd-debug -u 0 -g 0 ${RAMDISKDIRDEBUG}
            gzip -n -9 -f ${IMGDEPLOYDIR}/${PN}-initrd-debug
        fi
        cd ${CURRENT_DIR}
}

addtask do_ramdisk_create after do_image before do_makeboot
