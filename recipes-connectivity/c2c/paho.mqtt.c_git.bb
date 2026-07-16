inherit pkgconfig cmake

SUMMARY = "paho_mqtt library"
DESCRIPTION = "paho_mqtt library"

HOMEPAGE = "https://github.com/eclipse/paho.mqtt.c.git"
LICENSE = "EPL-2.0 | EDL-1.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=fd3b896dadaeec3410d753ffaeadcfac"

PACKAGE_ARCH ?= "${MACHINE_ARCH}"

FILESPATH =+ "${WORKSPACE}:"

DEPENDS = "openssl"

SRC_URI = "file://c2c/external/eclipse/paho.mqtt.c"
S = "${UNPACKDIR}/c2c/external/eclipse/paho.mqtt.c"

EXTRA_OECMAKE = "-DPAHO_WITH_SSL=ON"
