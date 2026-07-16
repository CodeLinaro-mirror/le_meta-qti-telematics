DESCRIPTION = "Installs public certificate on root file system for IMA"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

KERNEL_USE_PREBUILTS = "${@d.getVar('MACHINE_USES_KERNEL_PREBUILTS') or "False"}"

SRC_URI = "file://x509_ima.der \
           file://privkey_ima.pem \
           ${@bb.utils.contains('COMBINED_FEATURES', 'vbleevm', 'file://x509_evm.der', '', d)}"

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_patch() {
    if ${@oe.utils.conditional('KERNEL_USE_PREBUILTS', 'True', 'true', 'false', d)}; then
        cp -a ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/x509_ima.der ${S}/x509_ima.der
        cp -a ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/privkey_ima.pem ${S}/privkey_ima.pem
        if ${@bb.utils.contains('COMBINED_FEATURES', 'vbleevm', 'true', 'false', d)}; then
            cp -a ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/x509_evm.der ${S}/x509_evm.der
        fi
    fi
}

do_install() {
    install -d "${D}${sysconfdir}/keys"
    install -m 0444 "${UNPACKDIR}/x509_ima.der" "${D}${sysconfdir}/keys"
    if ${@bb.utils.contains('COMBINED_FEATURES', 'vbleevm', 'true', 'false', d)}; then
        install -m 0444 "${UNPACKDIR}/x509_evm.der" "${D}${sysconfdir}/keys"
    fi
}

do_install:append:class-native() {
    install -d ${D}${sysconfdir}/keys
    install -m 0444 "${UNPACKDIR}/privkey_ima.pem" "${D}${sysconfdir}/keys"
}

BBCLASSEXTEND = "native"
