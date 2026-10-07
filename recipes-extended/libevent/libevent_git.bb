SUMMARY = "library event from android required for stream update"
DESCRIPTION = "${SUMMARY}"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "libcutils"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/libevent/"

S = "${UNPACKDIR}/OTA/streaming/external/libevent/"

BBCLASSEXTEND = "native"

CPPFLAGS:append = " -I${S}/include"
CFLAGS:append = " -I${S}/include"

do_install:append() {
    install -d ${D}${includedir}/event2
    install -m 0644 ${S}/include/event2/*.h ${D}${includedir}/event2/
}

inherit autotools pkgconfig
