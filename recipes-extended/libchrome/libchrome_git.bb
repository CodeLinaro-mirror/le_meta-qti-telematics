SUMMARY = "library chrome from android required for stream update"
DESCRIPTION = "${SUMMARY}"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "bzip2-replacement-native libdivsufsort-native curl libevent liblog libcutils libmodpb64"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/libchrome/"

S = "${UNPACKDIR}/OTA/streaming/external/libchrome/"

BBCLASSEXTEND = "native"

do_install:append() {
    install -d ${D}${includedir}/libchrome

    if [ -d ${S}/base ]; then
        cp -R ${S}/base ${D}${includedir}/libchrome/
    fi

    if [ -d ${S}/build ]; then
        cp -R ${S}/build ${D}${includedir}/libchrome/
    fi

    if [ -d ${S}/testing ]; then
        cp -R ${S}/testing ${D}${includedir}/libchrome/
    fi

    if [ -d ${S}/crypto ]; then
        cp -R ${S}/crypto ${D}${includedir}/libchrome/
    fi
}

inherit autotools pkgconfig
