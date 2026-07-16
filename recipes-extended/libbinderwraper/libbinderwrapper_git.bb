SUMMARY = "library for binderwrapper used for binder service registation"
DESCRIPTION = "${SUMMARY}"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "openssl libmodpb64 liblog libbrillo libchrome binderstreaming"

PR = "r0"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/system/core/libbinderwrapper/"

S = "${UNPACKDIR}/OTA/system/core/libbinderwrapper/"

BBCLASSEXTEND = "native"

inherit autotools pkgconfig
