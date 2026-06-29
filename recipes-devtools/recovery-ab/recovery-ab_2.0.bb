inherit autotools-brokensep pkgconfig systemd

DESCRIPTION = "Recovery bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
HOMEPAGE = "https://git.codelinaro.org/clo/le/OTA/recovery.git"

DEPENDS += "glib-2.0 ext4-utils adbd fsmgr oem-recovery libutils libbase libsparse libcutils libmincrypt bzip2 bison-native openssl openssl-native"
DEPENDS += " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'abctl', '', d)}"

RDEPENDS:${PN} += "zlib"
RDEPENDS:${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'openssl', '', d)}"
RDEPENDS:${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'openssl-bin', '', d)}"

FILESEXTRAPATHS:prepend := "${WORKSPACE}:"

SRC_URI = "file://OTA/recovery/"
SRC_URI += "file://fstab_AB"
SRC_URI += "file://fstab_AB_cache_ext4"
SRC_URI += "file://update_engine.service"

S = "${UNPACKDIR}/OTA/recovery"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"
EXTRA_OECONF:append = "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'TARGET_SUPPORTS_OTA_VERIFICATION=true', '', d)}"
CFLAGS += "-lsparse -llog"
PARALLEL_MAKE = ""

EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'qti-ab-boot', 'TARGET_SUPPORTS_AB=true', '', d)}"
EXTRA_OECONF:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'qti-abc-boot', 'TARGET_SUPPORTS_ABC=true', '', d)}"

FILES:${PN}  = "${bindir} ${libdir} ${systemd_unitdir} ${includedir} /res /cache"
SYSTEMD_SERVICE:${PN} = " ${@bb.utils.contains('DISTRO_FEATURES', 'qti-ab-boot', bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', '', 'update_engine.service', d), '', d)}"

RM_WORK_EXCLUDE += "${PN}"
INITSCRIPT_NAME = "update_engine"
INITSCRIPT_PARAMS = "defaults"
generate_public_key() {
    mkdir -p ${TMPDIR}/deploy/images/${MACHINE}/ota-scripts
    openssl pkcs8 -inform DER -nocrypt -in ${WORKSPACE}/OTA/build/target/product/security/testkey.pk8 -out ${TMPDIR}/deploy/images/${MACHINE}/ota-scripts/private.pem
    openssl rsa -in ${TMPDIR}/deploy/images/${MACHINE}/ota-scripts/private.pem -outform PEM -pubout > ${UNPACKDIR}/public.pem
}

do_install[prefuncs] += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'generate_public_key', '', d)}"

do_install:append() {
        install -d ${D}/res/
        if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'false', 'true', d)}; then
            install -d ${D}/cache/recovery
        fi
        if ${@bb.utils.contains('IMAGE_FSTYPES', 'ext4', 'true', 'false', d)}; then
            if ${@bb.utils.contains_any('MACHINE_MNT_POINTS', '/overlay', 'true', 'false', d)}; then
                install -m 0755 ${UNPACKDIR}/fstab_AB -D ${D}/res/recovery_volume_config
            elif ${@bb.utils.contains_any('MACHINE_MNT_POINTS', '/cache', 'true', 'false', d)}; then
                install -m 0755 ${UNPACKDIR}/fstab_AB_cache_ext4 -D ${D}/res/recovery_volume_config
            fi
        fi

        install -d ${D}${systemd_unitdir}/system/

        if ${@bb.utils.contains('DISTRO_FEATURES', 'qti-ab-boot', bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'false', 'true', d), 'false', d)}; then
            install -m 0644 ${UNPACKDIR}/update_engine.service -D \
                     ${D}${systemd_unitdir}/system/update_engine.service
        fi
        if ${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'true', 'false', d)}; then
            install -m 0755 ${UNPACKDIR}/public.pem -D ${D}/res/public.pem
        fi
}

do_configure:prepend() {
    install -d ${UNPACKDIR}/OTA/system/core
    cp -r ${TOPDIR}/../sources/OTA/system/core/ ${UNPACKDIR}/OTA/system/
}

CPPFLAGS:append = " \
                    -I${RECIPE_SYSROOT}/usr/include/cutils \
                    -I${RECIPE_SYSROOT}/usr/include/fs_mgr \
                    -I${RECIPE_SYSROOT}/usr/include/ext4_utils \
                    -I${UNPACKDIR}/OTA/system/core/base/include \
                    -I${UNPACKDIR}/OTA/system/core/adb \
                    -I${UNPACKDIR}/OTA/system/core/include \
"
CXXFLAGS:append = "  \
                    -I${RECIPE_SYSROOT}/usr/include/cutils \
                    -I${RECIPE_SYSROOT}/usr/include/fs_mgr \
                    -I${RECIPE_SYSROOT}/usr/include/ext4_utils \
                    -I${UNPACKDIR}/OTA/system/core/base/include \
                    -I${UNPACKDIR}/OTA/system/core/adb \
                    -I${UNPACKDIR}/OTA/system/core/include \
"
# Fix buildpaths QA error — remove TMPDIR references from static lib debug info
CFLAGS:append = " -ffile-prefix-map=${UNPACKDIR}=. -ffile-prefix-map=${TMPDIR}=."
CXXFLAGS:append = " -ffile-prefix-map=${UNPACKDIR}=. -ffile-prefix-map=${TMPDIR}=."
