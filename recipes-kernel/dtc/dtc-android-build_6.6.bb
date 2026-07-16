DESCRIPTION = "Android DTC required to compile QTI kernel"
LICENSE = "GPL-2.0-only"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

PROVIDES = "virtual/dtc-native"

FILESEXTRAPATHS:prepend := "${WORKSPACE}/kernel-6.6/kernel_platform/prebuilts/kernel-build-tools/linux-x86/:"
SRC_URI = "file://bin"
S = "${UNPACKDIR}/bin"

INHIBIT_SYSROOT_STRIP = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

BBCLASSEXTEND = " native"

do_install() {
    install -d ${D}/${bindir}/dtc/
    install -d ${D}/${bindir}/dtc/bin/
    cp -rf ${S}/dtc ${D}/${bindir}/dtc/bin/
}
