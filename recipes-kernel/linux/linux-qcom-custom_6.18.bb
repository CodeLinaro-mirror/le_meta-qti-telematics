SECTION = "kernel"

SUMMARY = "Linux kernel for QCOM devices"
DESCRIPTION = "Recipe to build Linux kernel"

LICENSE = "GPLv2.0-with-linux-syscall-note"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel

DISTRO_VERSION = "2.1"

# Extend the version string of the Linux kernel to indicate distro
LINUX_VERSION_EXTENSION = "-qli-${DISTRO_VERSION}"

COMPATIBLE_MACHINE = "(qcom)"

FILESEXTRAPATHS:prepend = "${WORKSPACE}/kernel/kernel_platform:"

SRC_URI = "file://kernel \
           ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ' file://selinux.cfg', '', d)} \
           ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ' file://selinux_debug.cfg', '', d)} \
           "

S = "${UNPACKDIR}/kernel"

KERNEL_CONFIG ??= "qcom_telematics_base_defconfig"

# Enable selinux support
SELINUX_CFG = "${@oe.utils.vartrue('DEBUG_BUILD', 'selinux_debug.cfg', 'selinux.cfg', d)}"
KERNEL_CONFIG_FRAGMENTS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${UNPACKDIR}/${SELINUX_CFG}', '', d)}"

#Add DTC_FLAGS to compile DTB with symbols.
KERNEL_DTC_FLAGS += "-@"

do_configure:prepend() {
    if [ ! -f "${S}/arch/${ARCH}/configs/${KERNEL_CONFIG}" ]; then
        bbfatal "KERNEL_CONFIG '${KERNEL_CONFIG}' was specified, but not present in the source tree"
    else
        cp '${S}/arch/${ARCH}/configs/${KERNEL_CONFIG}' '${B}/.config'
    fi

    if [ "${SCMVERSION}" = "y" ]; then
        # Add GIT revision to the local version
        head=`git --git-dir=${S}/.git  rev-parse --verify --short HEAD 2> /dev/null`
        printf "%s%s" +g $head > ${B}/.scmversion
    fi


    # Check for kernel config fragments.  The assumption is that the config
    # fragment will be specified with the absolute path.  For example:
    #   * ${UNPACKDIR}/config1.cfg
    #   * ${S}/config2.cfg
    # Iterate through the list of configs and make sure that you can find
    # each one.  If not then error out.
    # NOTE: If you want to override a configuration that is kept in the kernel
    #       with one from the OE meta data then you should make sure that the
    #       OE meta data version (i.e. ${UNPACKDIR}/config1.cfg) is listed
    #       after the in kernel configuration fragment.
    # Check if any config fragments are specified.
    if [ ! -z "${KERNEL_CONFIG_FRAGMENTS}" ]
    then
        for f in ${KERNEL_CONFIG_FRAGMENTS}
        do
            # Check if the config fragment was copied into the UNPACKDIR from
            # the OE meta data
            if [ ! -e "$f" ]
            then
                echo "Could not find kernel config fragment $f"
                exit 1
            fi
        done

        # Now that all the fragments are located merge them.
        ( cd ${UNPACKDIR} && ${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${B}/.config ${KERNEL_CONFIG_FRAGMENTS} 1>&2 )
    fi

     # After merging, combine CONFIG_LOCALVERSION (from fragments) with LINUX_VERSION_EXTENSION
    if [ ! -z "${LINUX_VERSION_EXTENSION}" ]; then
        # Extract whatever CONFIG_LOCALVERSION was set by the fragments (strip quotes)
         existing=$(grep "^CONFIG_LOCALVERSION=" ${B}/.config | sed 's/CONFIG_LOCALVERSION=//;s/"//g' | tail -1)

        # Remove the old CONFIG_LOCALVERSION line
        sed -i '/^CONFIG_LOCALVERSION=/d' ${B}/.config

        # Write the combined value
        echo "# Global settings from linux recipe" >> ${B}/.config
        echo "CONFIG_LOCALVERSION=\"${existing}${LINUX_VERSION_EXTENSION}\"" >> ${B}/.config
    fi
}

do_configure:append() {
    oe_runmake -C ${S} O=${B} savedefconfig && cp ${B}/defconfig ${UNPACKDIR}/defconfig.saved
}

# Kernel 6.6 with commit d8131c2965d5ee59bfa4d548641e52a13cbe17c9
# removed $(MODLIB)/source symlink. However, kernel.bbclass is yet to
# catchup and failing while removing a non-existing link. To mitigate,
# added a dummy link which would be deleted by kernel_do_install task.
do_install:prepend() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}
    ln -rs ${STAGING_KERNEL_DIR} ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/source
}
