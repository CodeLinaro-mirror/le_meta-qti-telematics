inherit autotools-brokensep pkgconfig

DESCRIPTION = "OEM Recovery"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"
HOMEPAGE = "https://git.codelinaro.org/clo/le/OTA/recovery.git"

#FILESEXTRAPATHS:prepend := "${TOPDIR}/../sources:"
FILESEXTRAPATHS:prepend := "${WORKSPACE}:"
SRC_URI = "file://OTA/device/qcom/common/recovery/oem-recovery/ \
           file://OTA/recovery/ \
           file://0001-oem-recovery-disable-ufs-bsg-use-stub.patch \
"

S = "${UNPACKDIR}/OTA/device/qcom/common/recovery/oem-recovery"

DEPENDS += "virtual/kernel libcutils libsparse"

# To get kernel headers for compilation
do_configure[depends] += "virtual/kernel:do_shared_workdir"

EXTRA_OECONF = " \
    --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
    --with-sanitized-headers=${STAGING_INCDIR}/linux-kernel-qcom/usr/include \
    --with-core-headers=${STAGING_INCDIR} \
"

UFSBSG = "${@d.getVar('UFS_BSG_DEV_USAGE') or "False"}"

CPPFLAGS:append = "${@oe.utils.conditional('UFSBSG', 'True', ' -D_BSG_FRAMEWORK_KERNEL_HEADERS ', '', d)} -I${UNPACKDIR}/OTA/recovery"
CPPFLAGS += "-I${RECIPE_SYSROOT}/usr/include/sparse"
PACKAGECONFIG ?= " \
    glib \
    ion \
    ${@oe.utils.conditional('UFSBSG', 'True', 'ufsbsg', '', d)} \
"

PACKAGECONFIG[glib] = "--with-glib, --without-glib, glib-2.0"
PACKAGECONFIG[ion] = "--with-ion, --without-ion, libion"
#PACKAGECONFIG[ufsbsg] = "--with-ufsbsg, --without-ufsbsg"

do_install:append() {
    install -d ${D}${includedir}/recovery/mtdutils

    if [ -d ${UNPACKDIR}/OTA/recovery/mtdutils ]; then
        install -m 0644 ${UNPACKDIR}/OTA/recovery/mtdutils/*.h \
            ${D}${includedir}/recovery/mtdutils/
    else
        bbfatal "mtdutils headers not found at ${UNPACKDIR}/OTA/recovery/mtdutils"
    fi
}

FILES:${PN}-dev += " \
    ${includedir}/recovery \
    ${includedir}/recovery/mtdutils \
"

PARALLEL_MAKE = ""

# Fix buildpaths QA error — remove TMPDIR references from static lib debug info
CFLAGS:append = " -ffile-prefix-map=${UNPACKDIR}=. -ffile-prefix-map=${TMPDIR}=."
CXXFLAGS:append = " -ffile-prefix-map=${UNPACKDIR}=. -ffile-prefix-map=${TMPDIR}=."
