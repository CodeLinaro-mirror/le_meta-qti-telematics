inherit pkgconfig native autotools

LICENSE = "Apache-2.0 & BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
                    file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=cb641bc04cda31daea161b1bc15da69f \
"
HOMEPAGE = "https://git.codelinaro.org/clo/le/OTA/recovery.git"

PR = "r1"

DEPENDS += "bzip2-replacement-native"
RDEPENDS:${PN} = "zlib"

FILESEXTRAPATHS:prepend := "${WORKSPACE}/OTA/recovery/:"
SRC_URI   = "file://applypatch"

S = "${UNPACKDIR}/applypatch"
