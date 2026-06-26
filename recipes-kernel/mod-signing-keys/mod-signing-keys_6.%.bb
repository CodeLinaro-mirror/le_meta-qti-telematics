inherit allarch nopackages

SUMMARY = "Installs Linux kernel signing keys"
LICENSE = "GPLv2.0-with-linux-syscall-note"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=8afb6abdac9a14cb18a0d6c9c151e9b4"

# Ensure PACKAGE_ARCH is set to all even when multilib is enabled.
PACKAGE_ARCH = "all"

SRC_URI   =  "file://${KERNEL_PREBUILT_DISTDIR}/"
S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Copy kernel certs
    install -d ${D}/kernel-certs
    install -m 0644 ${S}/${KERNEL_PREBUILT_DISTDIR}/signing_key.pem ${D}/kernel-certs/
}

SYSROOT_DIRS += "/kernel-certs"
