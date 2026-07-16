SUMMARY = "CAN Drivers Kernel Modules"
DESCRIPTION = "CAN driver to interact with Calypso FW"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

DEPENDS = "virtual/kernel linux-kernel-qcom-headers"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://vendor/qcom/opensource/qti-can-kernel/"

S = "${UNPACKDIR}/vendor/qcom/opensource/qti-can-kernel"
EXT_MODULES = "${@os.path.relpath("${S}", "${KERNEL_PLATFORM_PATH}")}"

inherit linux-kernel-base deploy module pkgconfig

KERNEL_VERSION = "${@get_kernelversion_file("${STAGING_KERNEL_BUILDDIR}")}"

do_configure[depends] += "virtual/kernel:do_shared_workdir"

TARGET_CC_ARCH += "-fdebug-prefix-map=${UNPACKDIR}=/usr/src/debug/${PN}/${PV}"

do_compile() {
    cd ${S}
    oe_runmake -C ${STAGING_KERNEL_DIR} M=${S} modules
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    install -m 0755 ${UNPACKDIR}/vendor/qcom/opensource/qti-can-kernel/qti-can.ko ${D}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
}

do_module_signing() {

  strip_tool="${STRIP}"
  ${strip_tool} --strip-debug ${PKGDEST}/${PN}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/qti-can.ko

  export LD_LIBRARY_PATH="${KERNEL_PREBUILT_DISTDIR}"
  if [ -f ${STAGING_KERNEL_BUILDDIR}/signing_key.priv ]; then
        ${STAGING_KERNEL_DIR}/scripts/sign-file sha1 ${STAGING_KERNEL_BUILDDIR}/signing_key.priv ${STAGING_KERNEL_BUILDDIR}/signing_key.x509 ${PKGDEST}/${PN}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
  elif [ -f ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.pem ]; then
   ${STAGING_KERNEL_BUILDDIR}/scripts/sign-file sha1 ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.pem ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.x509 ${PKGDEST}/${PN}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/qti-can.ko
   bbnote "Signing ${PKGDEST}/${PN}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/ module" 
  fi
}

do_deploy() {
#Deploy unstripped kernel modules into ${DEPLOYDIR}/kernel_modules for debugging purposes
    install -d ${DEPLOYDIR}/kernel_modules
    install -m 0644 $(find ${D} -name "*.ko") ${DEPLOYDIR}/kernel_modules
}

addtask do_module_signing after do_package before do_package_write_ipk

# The inherit of module.bbclass will automatically name module packages with
# kernel-module-" prefix as required by the oe-core build environment. Also it
# replaces '_' with '-' in the module name.


FILES:${PN}+="${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/*"
FILES:${PN}+="${nonarch_base_libdir}/"

RPROVIDES:${PN} += "kernel-module-qti-can-${KERNEL_VERSION}"

INSANE_SKIP:${PN} += "buildpaths"
INSANE_SKIP:${PN}-dbg += "buildpaths"
