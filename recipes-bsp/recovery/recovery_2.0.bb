inherit autotools-brokensep pkgconfig

DESCRIPTION = "Recovery bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
HOMEPAGE = "https://git.codelinaro.org/clo/le/OTA/recovery.git"

DEPENDS += "glib-2.0 safe-iop mtd-utils oem-recovery adbd libbase libsparse libmincrypt bzip2 bison-native openssl"
RDEPENDS:${PN} = "zlib"

FILESEXTRAPATHS:prepend := "${WORKSPACE}:"
SRC_URI = "file://OTA/recovery/"
SRC_URI += "file://recovery.service"

S = "${UNPACKDIR}/OTA/recovery/"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"
EXTRA_OECONF += "${@bb.utils.contains('DISTRO_FEATURES', 'ota-package-verification', 'TARGET_SUPPORTS_OTA_VERIFICATION=true', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'TARGET_SUPPORTS_NAND_DM_VERITY=true', '', d)}"

CFLAGS += "-lsparse -llog"

PARALLEL_MAKE = ""

FILES:${PN}  = "${bindir} ${libdir} ${includedir} ${systemd_unitdir} /res /cache /data"

RM_WORK_EXCLUDE += "${PN}"

do_configure:prepend() {
    install -d ${UNPACKDIR}/OTA/system/core
    cp -r ${TOPDIR}/../sources/OTA/system/core ${UNPACKDIR}/OTA/system
}

CPPFLAGS:append = " -I${RECIPE_SYSROOT}/usr/include/cutils \
                    -I${RECIPE_SYSROOT}/usr/include/fs_mgr \
                    -I${RECIPE_SYSROOT}/usr/include/ext4_utils \
                    -I${UNPACKDIR}/OTA/system/core/adb \
                    -I${UNPACKDIR}/OTA/system/core/include \
"
CXXFLAGS:append = " -I${RECIPE_SYSROOT}/usr/include/cutils \
                    -I${RECIPE_SYSROOT}/usr/include/fs_mgr \
                    -I${RECIPE_SYSROOT}/usr/include/ext4_utils \
                    -I${UNPACKDIR}/OTA/system/core/adb \
                    -I${UNPACKDIR}/OTA/system/core/include \
"
do_install:append() {
    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -m 0644 ${UNPACKDIR}/recovery.service -D ${D}${systemd_unitdir}/system/recovery.service
    ln -sf ${systemd_unitdir}/system/recovery.service ${D}${systemd_unitdir}/system/multi-user.target.wants/recovery.service
}

# Fix buildpaths QA error — remove TMPDIR references from static lib debug info
CFLAGS:append = " -ffile-prefix-map=${UNPACKDIR}=. -ffile-prefix-map=${TMPDIR}=."
CXXFLAGS:append = " -ffile-prefix-map=${UNPACKDIR}=. -ffile-prefix-map=${TMPDIR}=."
