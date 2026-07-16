FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://extra-users-auto.conf"

do_install:append() {
   install -d ${D}/${datadir}/dbus-1/system.d/
   install -m 0644 ${UNPACKDIR}/extra-users-auto.conf -D ${D}${datadir}/dbus-1/system.d/extra-users-auto.conf
}
