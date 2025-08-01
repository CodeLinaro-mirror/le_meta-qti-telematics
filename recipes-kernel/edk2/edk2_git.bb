inherit deploy python3native
DESCRIPTION = "UEFI bootloader"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

BUILD_OS = "linux"

DEPENDS += "util-linux-native"

PACKAGE_ARCH = "${MACHINE_ARCH}"
FILESPATH =+ "${WORKSPACE}/kernel/kernel_platform/bootable/bootloader:"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://edk2 \
           file://0001-BaseTools-suppress-compiler-warnings.patch"
S         =  "${WORKDIR}/edk2"

INSANE_SKIP:${PN} = "arch"

VBLE = "${@bb.utils.contains('DISTRO_FEATURES', 'qti-vble','1', '0', d)}"

VERITY_ENABLED = "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', '1', '0', d), '0', d)}"

EARLY_ETH = "${@bb.utils.contains('DISTRO_FEATURES', 'early-eth', '1', '0', d)}"

SYSTEMD_BOOTSLOT_ENABLED = "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot','1', '0', d)}"

DM_MOD_FOR_KERNEL5_4 = "${@d.getVar('DM_MOD_FOR_KERNEL') or "0"}"

EARLY_USB_INIT = "${@bb.utils.contains('DISTRO_FEATURES', 'qti-earlyusb', '1', '0', d)}"

TARGET_HIBERNATION_INSECURE_ENABLE = "${@bb.utils.contains('HIBERNATION_INSECURE_ENABLE', 'True', 'true', 'false', d)}"

EXTRA_OEMAKE = " \
    'TARGET_ARCHITECTURE=${TARGET_ARCH}' \
    'BUILDDIR=${B}' \
    'BOOTLOADER_OUT=${B}/out' \
    'ENABLE_LE_VARIANT=true' \
    'ENABLE_SYSTEMD_BOOTSLOT=${SYSTEMD_BOOTSLOT_ENABLED}'\
    'ENABLE_DM_MOD_FOR_KERNEL5_4=${DM_MOD_FOR_KERNEL5_4}'\
    'VERIFIED_BOOT_LE=${VBLE}' \
    'VERITY_LE=${VERITY_ENABLED}' \
    'INIT_BIN_LE=\"/sbin/init\"' \
    'EDK_TOOLS_PATH=${S}/BaseTools' \
    'EARLY_ETH_ENABLED=${EARLY_ETH}' \
    'OVERRIDE_ABL_LOAD_ADDRESS=${ABL_LOAD_ADDRESS}' \
    'HIBERNATION_SUPPORT_INSECURE=${TARGET_HIBERNATION_INSECURE_ENABLE}' \
    'TARGET_SUPPORTS_EARLY_USB_INIT=${EARLY_USB_INIT}' \
"
EXTRA_OEMAKE:append:qcs40x = " 'DISABLE_PARALLEL_DOWNLOAD_FLASH=1'"
NAND_SQUASHFS_SUPPORT = "${@bb.utils.contains('DISTRO_FEATURES', 'nand-squashfs', '1', '0', d)}"
EXTRA_OEMAKE:append = " 'NAND_SQUASHFS_SUPPORT=${NAND_SQUASHFS_SUPPORT}'"
EXTRA_OEMAKE:append:qti-distro-base-user = " 'VERITY_LE_USE_EXT4_GLUEBI=1'"

do_compile () {
    export CC=${BUILD_CC}
    export CXX=${BUILD_CXX}
    export LD=${BUILD_LD}
    export AR=${BUILD_AR}
    #oe_runmake -f makefile all
    make -C ${S} \
        BUILDDIR=${B} \
        BOOTLOADER_OUT=${B}/out \
        EDK_TOOLS_PATH=${S}/BaseTools \
        TARGET_ARCHITECTURE=${TARGET_ARCH} \
        VERIFIED_BOOT_LE=${VBLE} \
        VERIFIED_BOOT_ENABLED=0 \
        EARLY_ETH_ENABLED=${EARLY_ETH} \
        TARGET_SUPPORTS_EARLY_USB_INIT=${EARLY_USB_INIT} \
        AB_RETRYCOUNT_DISABLE=0 \
        TARGET_BOARD_TYPE_AUTO=0 \
        USER_BUILD_VARIANT=0 \
        DISABLE_PARALLEL_DOWNLOAD_FLASH=1 \
        ENABLE_LE_VARIANT=true \
        BUILD_USES_RECOVERY_AS_BOOT=0 \
        INIT_BIN_LE="/sbin/init" \
        NAND_UBI_VOLUME_FLASHING_ENABLED=1 \
        CMDLINE_SHOW_SECURE_BOOT_STATUS=1 \
        INTEGRITY_LE_IMA=0 \
        INTEGRITY_LE_EVM=0 \
        ENABLE_BOOT_DEVICE_BASED_DT_SELECTION=true \
        ENABLE_BOOT_REASON_BOOTPARAM=true \
        ENABLE_SYSTEMD_BOOTSLOT=${SYSTEMD_BOOTSLOT_ENABLED} \
        ENABLE_DM_MOD_FOR_KERNEL5_4=${DM_MOD_FOR_KERNEL5_4} \
        VERITY_LE=${VERITY_ENABLED} \
        OVERRIDE_ABL_LOAD_ADDRESS=${ABL_LOAD_ADDRESS} \
        HIBERNATION_SUPPORT_INSECURE=${TARGET_HIBERNATION_INSECURE_ENABLE} \
        TARGET_SUPPORTS_EARLY_USB_INIT=${EARLY_USB_INIT} \
        NAND_SQUASHFS_SUPPORT=${NAND_SQUASHFS_SUPPORT} \
        SIGNED_KERNEL=1 \
        CLANG_BIN="${STAGING_BINDIR_NATIVE}/llvm-arm-toolchain/bin/" \
        all
}

do_install[noexec]="1"
do_configure[noexec]="1"

do_deploy() {
    install -m 644 ${WORKDIR}/unsigned_abl.elf ${DEPLOYDIR}/
}

do_deploy[dirs] = "${S} ${DEPLOYDIR}"
addtask do_deploy before do_build after do_install

PACKAGE_STRIP = "no"
