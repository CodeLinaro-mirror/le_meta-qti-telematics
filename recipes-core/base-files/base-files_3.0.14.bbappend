FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}-${PV}:"

do_install:append() {

  # Create sdcard mount point in rootfs.
  install -d ${D}/media/sdcard

 if [ ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'True', 'False', d)} = True ]; then
        echo "192.168.225.1 qti-modem" >> ${D}${sysconfdir}/hosts
    fi
}
