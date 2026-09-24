BASEMACHINE ?= "sa535m"

DEFAULTTUNE = "armv8-2a-crypto"
require conf/machine/include/arm/arch-armv8-2a.inc

SOC_FAMILY = "sa535m"

SOC_FAMILY:prepend = "qcom:"
require conf/machine/include/soc-family.inc

PREFERRED_PROVIDER_virtual/mkdtimg-native = "mkdtimg-gki-native"

#Define and add SOC_ARCH to the list of architectures compatible with the given target.
SOC_ARCH = "${@ d.getVar('SOC_FAMILY').replace('-', '_').replace('qcom:', '')}"
PACKAGE_EXTRA_ARCHS:append = "${@['', ' ${SOC_ARCH}']['${SOC_ARCH}' != "${MACHINE_ARCH}"]}"

# Supported BSP selections are: base, custom
# We intend to use 'custom' BSP by default.
# Specific MACHINEs or DISTROs might change this as needed.
QCOM_SELECTED_BSP ??= "custom"
MACHINEOVERRIDES =. "qcom-${QCOM_SELECTED_BSP}-bsp:"

# Additional Kernel cmdline parameters for debug builds
SERIAL_CONSOLES = "115200;ttyMSM0"
DBG_CMDLINE = "${@oe.utils.conditional('DEBUG_BUILD','1','nokaslr page_owner=on slub_debug=FZP,zs_handle,zspage;FZPU','systemd.show_status=0 systemd.log_level=0 systemd.journald.forward_to_console=0',d)}"

PREFERRED_PROVIDER_virtual/refpolicy = "refpolicy-mls-auto"
# Kernel provider
PREFERRED_PROVIDER_virtual/kernel = "linux-qcom-custom"
# Kernel version preference
PREFERRED_VERSION_linux-qcom-custom = "6.18%"
PREFERRED_VERSION_thermal-engine = "14.0"

# Fixes for boot image dtb appending
BOOT_HEADER_VERSION = "2"
KERNEL_DTB_NAMES = "dtb.img"
KERNEL_IMAGETYPE = "Image"
KERNEL_ALT_IMAGETYPE ?= "vmlinux"
KERNEL_BASE = "0x80000000"

KERNEL_CMDLINE_EXTRA ?= "ro rootwait ${DBG_CMDLINE} no_console_suspend=1 androidboot.console=ttyMSM0 console=ttyMSM0,115200n8 root=/dev/ram0 rw rootwait printk.devkmsg=on console_msg_format=syslog androidboot.fstab_suffix=rdshell firmware_class.path=/lib/firmware/image net.ifnames=0 qcom_scm.download_mode=1 reboot=panic_warm panic=-1"

# Bootloader configuration
EXTRA_IMAGEDEPENDS += "edk2"

#TODO
#MACHINE_EXTRA_RRECOMMENDS:append:qcom-custom-bsp = " \
#    qcom-subsystem-ramdump \
#"

PREFERRED_PROVIDER_virtual/partconf = ""
PREFERRED_PROVIDER_virtual/bootbins = ""

MACHINE_SUPPORTS_INIT_RAMDISK = "False"

#Include tar.bz2 image artifact only for debug builds
IMAGE_FSTYPES += "${@bb.utils.contains('DEBUG_BUILD', '1', 'tar.bz2', '' , d)}"
IMAGE_GEN_DEBUGFS = "${@bb.utils.contains('DEBUG_BUILD', '1', '1', '0', d)}"
IMAGE_FSTYPES_DEBUGFS = "${@bb.utils.contains('DEBUG_BUILD', '1', 'tar.bz2', '', d)}"

# MACHINE_FEATURES ##
# qti-adsp:               Machine supports QTI adsp solution
# qti-cdsp:               Machine supports QTI cdsp solution
# qti-ab-boot:            Machine supports a/b boot
# qti-security:           Machine supports QTI security solution
# qti-wifi:               Machine supports QTI WiFi solution
# qti-audio:              Machine supports QTI audio solution
# qti-bluetooth:          Machine supports QTI bluetooth solution
# qti-sensors:            Machine supports sensors qti solution
# qti-location:           Machine supports Location solution
# qti-data-modem:         Machine supports QTI data modem solution
# qti-mvm:                Machine supports QTI MVM solution
# qseecompat:             Machine supports qseecom compat solution
# qti-tzlog:              Machine supports tz/qsee logs
# qti-smciqseecomd:       Machine supports smcinvoke based listeners
# android-binder:         Machine supports android binder
# dm-verity-initramfs-v4: Machine supports Initramfs and dm-verity working with AVB
# qti-nad-telaf:          Machine supports telematics application framework
# qti-nad-mrc             Machine supports mrcd feature
# qti-nad-core            Machine supports all nad core features
# qti-recovery            Machine supports a/b ota

MACHINE_FEATURES += "qti-ab-boot qti-sensors qti-location qti-audio qti-data-modem dm-verity-initramfs-v4 qti-wlan qti-bluetooth qti-isim qti-nad-mrc qti-nad-core qti-recoveryinfo qti-recovery qti-stream-update qti-nad-fde"

MACHINE_MNT_POINTS = " \
    /firmware \
    /data \
    /persist \
    /systemrw \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-isim', '/isim', '', d)} \
"

EXTRA_USERS_PARAMS += "usermod -p \
    '\$6\$fixed\$ehhrBJycOdAtiIuyucGkTk3lphxtYcRODdJVNS8T1kdONi5tWAFnzMcfOXlfH42wBNE5wmTyiNEopIKxG0U5r/' \
    -d /home/root root \
"
# Append Anti Rollback Index and Assign default value
ENABLE_ANTI_ROLLBACK = "0"
# Below index used by BOOT & DTBO img
ANTIROLL_BACK_INDEX_VALUE = "0"
# Below index used by Rootfs Image
ANTIROLL_BACK_INDEX_VALUE_ROOTFS = "0"

BBMASK += " \
meta-qti-data/recipes/dnsmasq/dnsmasq_2.90.bbappend \
meta-qti-data/recipes/dnsmasq/dnsmasq_2.83.bbappend \
meta-qti-sepolicy/recipes-security/selinux/checkpolicy_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/libselinux-python_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/libselinux_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/libsemanage_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/libsepol_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/mcstrans_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/policycoreutils_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/restorecond_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/secilc_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/selinux-dbus_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/selinux-gui_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/selinux-python_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/selinux-sandbox_3.3.bbappend \
meta-qti-sepolicy/recipes-security/selinux/semodule-utils_3.3.bbappend \
meta-qti-core-prop/recipes-products/images/machine-image.bbappend \
meta-qti-internal/recipes-products/packagegroups/packagegroup-qcom-wifi.bbappend \
meta-qti-internal/recipes-firmware/firmware/firmware-qcom-bootbins_.*\.bbappend \
meta-qti-internal/recipes-firmware/firmware/firmware-qcom-partconf_.*\.bbappend \
meta-qti-internal/recipes-firmware/firmware/firmware-qcom-verinfo_.*\.bbappend \
meta-qti-internal/recipes-firmware/firmware/firmware-qcom-modempr_.*\.bb \
meta-qti-internal/recipes-firmware/firmware/hexagon-dsp-binaries_.*\.bbappend \
meta-qti-internal/recipes-firmware/packagegroups/packagegroup-firmware-.*\.bbappend \
meta-qcom/dynamic-layers/qcom-distro/recipes-ml/tflite/tensorflow-lite_%.bbappend \
meta-qti-security/recipes-sota/ostree-initrd/ostree-initrd.bbappend \
meta-qti-telematics-prop/recipes-extended/thermal-engine/thermal-engine_%.bbappend \
meta-qti-telematics-prop/recipes-bsp/ss-restart/qcom-subsystem-ramdump_%.bbappend \
meta-qcom/recipes-support/qrtr/qrtr_1.2.bb \
"
