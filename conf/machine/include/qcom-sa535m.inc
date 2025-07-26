BASEMACHINE ?= "sa535m"

DEFAULTTUNE = "armv8-2a-crypto"
require conf/machine/include/arm/arch-armv8-2a.inc

SOC_FAMILY = "sa535m"
require conf/machine/include/qcom-base.inc

# Additional Kernel cmdline parameters for debug builds
DBG_CMDLINE = "${@oe.utils.conditional('DEBUG_BUILD','1','earlycon nokaslr reboot=panic_warm page_owner=on qcom_scm.download_mode=1 slub_debug=FZP,zs_handle,zspage;FZPU','',d)}"

PREFERRED_PROVIDER_virtual/refpolicy = "refpolicy-mls-auto"
PREFERRED_VERSION_linux-qcom-custom = "6.6"

# Fixes for boot image dtb appending
BOOT_HEADER_VERSION = "2"
KERNEL_DTB_NAMES = "dtb.img"
KERNEL_IMAGETYPE = "Image"
KERNEL_BASE = "0x80000000"

KERNEL_CMDLINE_EXTRA ?= "ro rootwait ${DBG_CMDLINE} no_console_suspend=1 androidboot.console=ttyMSM0 firmware_class.path=/data/firmware/image,/lib/firmware/image net.ifnames=0"

#TODO
#MACHINE_EXTRA_RRECOMMENDS:append:qcom-custom-bsp = " \
#    qcom-subsystem-ramdump \
#"

PREFERRED_PROVIDER_virtual/partconf = ""
PREFERRED_PROVIDER_virtual/bootbins = ""

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

MACHINE_FEATURES += "qti-sensors qti-location"
