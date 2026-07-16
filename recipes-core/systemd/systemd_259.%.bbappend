FILESEXTRAPATHS:prepend := "${THISDIR}/systemd_255:"

SRC_URI:append = "file://0001-systemd-mask-journald-messages-and-remove-rules-with.patch "

do_install:append () {
   #  'systemctl unmask' can be used on device to enable them if needed.
   if [ "${SYSTEMD_ENABLE_JOURNAL}" != "1" ]; then
       ln -sf /dev/null ${D}${sysconfdir}/systemd/system/systemd-journald-audit.socket
   fi
}
