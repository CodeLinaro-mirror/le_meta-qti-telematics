SUMMARY = "library bspatch from android required for stream update"
DESCRIPTION = "${SUMMARY}"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "bzip2-replacement-native curl openssl libmodpb64 liblog libdivsufsort-native libcutils bzip2"

PR = "r0"
FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/streaming/external/bsdiff/"

S = "${UNPACKDIR}/OTA/streaming/external/bsdiff/"

BBCLASSEXTEND = "native"

CPPFLAGS:append = " -I${S}/include"

do_install:append() {
    install -d ${D}${includedir}/bsdiff

    if [ -d ${S}/include/bsdiff ]; then
        install -m 0644 ${S}/include/bsdiff/*.h \
            ${D}${includedir}/bsdiff/
    else
        bbwarn "bsdiff headers not found"
    fi
}

inherit autotools pkgconfig
