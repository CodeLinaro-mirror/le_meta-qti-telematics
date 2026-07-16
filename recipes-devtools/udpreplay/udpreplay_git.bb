inherit cmake pkgconfig

DESCRIPTION = "UDPReplay Software"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH ?= "${MACHINE_ARCH}"

FILESPATH =+ "${WORKSPACE}:"

DEPENDS = "libpcap glib-2.0"

TARGET_CFLAGS += "-Wno-format-security"

SRC_URI = "file://udpreplay"
SRC_DIR = "${WORKSPACE}/udpreplay"
S = "${UNPACKDIR}/udpreplay"

SOLIBS = ".so*"
FILES_SOLIBSDEV = ""
