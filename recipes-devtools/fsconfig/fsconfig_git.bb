inherit native autotools-brokensep pkgconfig

PR = "r5"

DESCRIPTION = "fs_config tool from Android"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
HOMEPAGE = "http://android.git.kernel.org/?p=platform/system/core.git"

DEPENDS += "libselinux libcutils"

FILESEXTRAPATHS:prepend := "${WORKSPACE}:"
SRC_URI = "file://OTA/build/tools/fs_config/"

S = "${UNPACKDIR}/OTA/build/tools/fs_config"

BBCLASSEXTEND = "native"

EXTRA_OECONF:append:class-target = " --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include"
EXTRA_OECONF:append:class-native = " --with-core-headers=${STAGING_INCDIR_NATIVE}"
EXTRA_OECONF:append:class-native = " ${@oe.utils.conditional('DISTRO_FEATURES', 'selinux', ' --enable-selinux', '', d)}"
