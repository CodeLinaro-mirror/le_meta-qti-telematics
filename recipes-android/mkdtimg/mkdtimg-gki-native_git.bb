inherit native python3native

DESCRIPTION = "Prebuilt DTBO image creation tool from Android"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "virtual/mkdtimg-native"

KERNEL_PLATFORM_PATH = "${WORKSPACE}/kernel/kernel_platform"

FILESEXTRAPATHS:prepend := "${KERNEL_PLATFORM_PATH}/prebuilts/kernel-build-tools/linux-x86/:"
SRC_URI  = "file://bin"
SRC_URI += "file://include"
SRC_URI += "file://lib64"

do_compile[noexec] = "1"
do_configure[noexec] = "1"

SYSROOT_PREPROCESS_FUNCS:remove = "relocatable_binaries_preprocess"
SYSROOT_PREPROCESS_FUNCS:remove = "relocatable_native_pcfiles"
INHIBIT_SYSROOT_STRIP = "1"

# uninative.bbclass by default gets inherited into all native recipes.
# This class provides uninative_changeinterp function which eliminates
# any host-dependencies from native bins. This alteration is breaking
# mkdtboimg.py and to disable it, defined custom function to do nothing.
python uninative_changeinterp () {
    return
}

do_install() {
    install -d ${D}${bindir}/mkdtboimg/bin
    for b in ${UNPACKDIR}/bin/*; do
        install -m 0755 $b -D ${D}${bindir}/mkdtboimg/bin/
    done

    install -d ${D}${bindir}/mkdtboimg/lib64
    for l in ${UNPACKDIR}/lib64/*; do
        install -m 0644 $l -D ${D}${bindir}/mkdtboimg/lib64
    done

    install -d ${D}${bindir}/mkdtboimg/include/elfutils
    for i in ${UNPACKDIR}/include/elfutils/*; do
        install -m 0644 $i -D ${D}${bindir}/mkdtboimg/include/elfutils
    done
    install -m 0644 ${UNPACKDIR}/include/gelf.h   -D ${D}${bindir}/mkdtboimg/include/
    install -m 0644 ${UNPACKDIR}/include/libelf.h -D ${D}${bindir}/mkdtboimg/include/
    install -m 0644 ${UNPACKDIR}/include/nlist.h  -D ${D}${bindir}/mkdtboimg/include/
}
