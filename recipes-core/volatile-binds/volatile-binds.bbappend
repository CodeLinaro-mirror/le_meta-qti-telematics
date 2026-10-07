FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

VOLATILE_BINDS:append = "${@bb.utils.contains('DEBUG_BUILD','1',' '.join(d.getVar('VOLATILE_BINDS_SA535M_DEBUG').split()),' '.join(d.getVar('VOLATILE_BINDS_SA535M_PERF').split()),d)}"

# mount-copybind's overlay mount(2) attempt hits errno 13 (EACCES) in enforcing mode with zero correlating AVC denials even after granting mount_t the capabilities theoretically needed for overlay setup.
# Skip overlayfs and use the script's existing bind+copy fallback instead. Keeping the behaviour same with other configurations.
AVOID_OVERLAYFS:sa535m = "1"

VOLATILE_BINDS_SA535M_DEBUG = "\
/systemrw/adb_devid  /etc/adb_devid\n\
/systemrw/data /etc/data/\n\
/systemrw/data/adpl /etc/data/adpl/\n\
/systemrw/data/usb /etc/data/usb/\n\
/systemrw/data/ipa /etc/data/ipa/\n\
/systemrw/boot_hsusb_comp /etc/usb/boot_hsusb_comp\n\
/systemrw/wifi /etc/misc/wifi/\n\
/systemrw/tel.conf /etc/tel.conf\n\
/systemrw/OSNMA_MerkleTree.xml /etc/OSNMA_MerkleTree.xml\n\
/systemrw/tm.conf /etc/tm.conf\n\
/systemrw/resourcemanager.xml /etc/resourcemanager.xml\n\
/systemrw/ObeConfig.conf /etc/ObeConfig.conf\n\
/systemrw/qmi_fw.conf /vendor/etc/qmi_fw.conf\n\
/systemrw/commonapi4someip.ini /etc/commonapi4someip.ini\n\
/systemrw/vsomeip-location.json /etc/vsomeip-location.json\n\
/systemrw/sap.conf /etc/sap.conf\n\
/systemrw/apdr.conf /etc/apdr.conf\n\
/systemrw/eCall.conf /etc/eCall.conf\n\
/systemrw/vsomeip-sensor_service.json /usr/etc/vsomeip/SensorInterface/vsomeip-sensor_service.json\n\
/systemrw/qits_env_file /etc/qits_env_file\n\
/systemrw/chrony.conf /etc/chrony.conf\n\
/systemrw/power_state.conf /etc/power_state.conf\n\
/systemrw/gptp_cfg.ini /etc/gptp_cfg.ini\n\
/systemrw/sensors.conf /etc/sensors.conf\n\
/systemrw/izat.conf /etc/izat.conf\n\
/systemrw/izat_process.conf /etc/izat_process.conf\n\
/systemrw/gps.conf /etc/gps.conf\n\
/systemrw/telux_chrony-sock.conf /etc/telux_chrony-sock.conf\n\
/systemrw/telux_power_refd.conf /etc/telux_power_refd.conf\n\
/systemrw/httpd.conf /etc/httpd.conf\n\
/systemrw/telsdk_app.conf /etc/telsdk_app.conf\n\
/systemrw/Datafilter.conf /etc/Datafilter.conf\n\
/systemrw/rtcmConfig.conf /etc/rtcmConfig.conf\n\
"

VOLATILE_BINDS_SA535M_PERF = "\
/systemrw/adb_devid  /etc/adb_devid\n\
/systemrw/data /etc/data/\n\
/systemrw/data/adpl /etc/data/adpl/\n\
/systemrw/data/usb /etc/data/usb/\n\
/systemrw/data/ipa /etc/data/ipa/\n\
/systemrw/boot_hsusb_comp /etc/usb/boot_hsusb_comp\n\
/systemrw/wifi /etc/misc/wifi/\n\
/systemrw/tel.conf /etc/tel.conf\n\
/systemrw/OSNMA_MerkleTree.xml /etc/OSNMA_MerkleTree.xml\n\
/systemrw/tm.conf /etc/tm.conf\n\
/systemrw/resourcemanager.xml /etc/resourcemanager.xml\n\
/systemrw/ObeConfig.conf /etc/ObeConfig.conf\n\
/systemrw/qmi_fw.conf /vendor/etc/qmi_fw.conf\n\
/systemrw/commonapi4someip.ini /etc/commonapi4someip.ini\n\
/systemrw/vsomeip-location.json /etc/vsomeip-location.json\n\
/systemrw/sap.conf /etc/sap.conf\n\
/systemrw/apdr.conf /etc/apdr.conf\n\
/systemrw/eCall.conf /etc/eCall.conf\n\
/systemrw/vsomeip-sensor_service.json /usr/etc/vsomeip/SensorInterface/vsomeip-sensor_service.json\n\
/systemrw/qits_env_file /etc/qits_env_file\n\
/systemrw/chrony.conf /etc/chrony.conf\n\
/systemrw/power_state.conf /etc/power_state.conf\n\
/systemrw/gptp_cfg.ini /etc/gptp_cfg.ini\n\
/systemrw/sensors.conf /etc/sensors.conf\n\
/systemrw/izat.conf /etc/izat.conf\n\
/systemrw/izat_process.conf /etc/izat_process.conf\n\
/systemrw/gps.conf /etc/gps.conf\n\
/systemrw/telux_chrony-sock.conf /etc/telux_chrony-sock.conf\n\
/systemrw/telux_power_refd.conf /etc/telux_power_refd.conf\n\
/systemrw/httpd.conf /etc/httpd.conf\n\
/systemrw/telsdk_app.conf /etc/telsdk_app.conf\n\
/systemrw/Datafilter.conf /etc/Datafilter.conf\n\
/systemrw/rtcmConfig.conf /etc/rtcmConfig.conf\n\
"


do_install:append (){
    #Remove deprecated StandardOutput=syslog
    for service in ${SYSTEMD_SERVICE:${PN}}; do
         sed -i '/StandardOutput=syslog/d' ${D}${systemd_system_unitdir}/$service
     done
}
