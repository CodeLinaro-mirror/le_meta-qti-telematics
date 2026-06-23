FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-nad-telaf', 'file://0001-logd-Grant-process-with-dlt-primary-group-access-to-.patch', '', d)}"

do_install:append(){
           sed -i '/\[Service\]/a SupplementaryGroups=logd leprop' ${D}${systemd_unitdir}/system/earlyinit-logd.service
}
