FILESEXTRAPATHS:prepend := "${THISDIR}/busybox:"

SRC_URI += "\
            file://no-shell-history.cfg \
            file://busybox_utilities.cfg \
            file://0001-Support-both-buffer-mode-and-file-mode.patch \
            file://taskset.cfg \
"

do_install:append() {
    if [ -f ${D}${sysconfdir}/default/busybox-syslog ]; then
        echo 'OPTIONS="-C300 -O /var/log/messages -R 127.0.0.1:47111 -L"' \
            >> ${D}${sysconfdir}/default/busybox-syslog
    fi
}

ERROR_QA:remove = "patch-status"
