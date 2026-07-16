FILESEXTRAPATHS:prepend := "${THISDIR}/chrony:"

SRC_URI += "file://chrony-gvm.conf"

do_install:append() {
    if [ ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-guest', 'True', 'False', d)} = True ]; then
        rm -f ${D}${sysconfdir}/chrony.conf
        install -m 0640 ${UNPACKDIR}/chrony-gvm.conf ${D}${sysconfdir}/chrony.conf
    fi
    chmod 640 ${D}${sysconfdir}/chrony.conf
}
