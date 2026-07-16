inherit cmake ${@bb.utils.contains("BBFILE_COLLECTIONS", "meta-python2", "pythonnative", "", d)}

SUMMARY = "Nanopb - Protocol Buffers for Embedded Systems"
DESCRIPTION = "Nanopb is a small code-size Protocol Buffers implementation \
in ansi C. It is especially suitable for use in microcontrollers, but fits \
any memory restricted system."
HOMEPAGE = "https://github.com/nanopb/nanopb"
SECTION = "console/tools"

LICENSE = "Zlib"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=9db4b73a55a3994384112efcdb37c01f"

DEPENDS = "protobuf protobuf-native nanopb-native python3-protobuf-native"
DEPENDS:append:class-native = " python3-protobuf-native"

SRCREV = "cc74b9f200176edc5524aa00ba45fa90a5e87d27"

SRC_URI = "git://git.codelinaro.org/clo/le/nanopb.git;protocol=https;branch=caf_migration/nanopb/master"
SRC_URI += "file://0001-bitbake-using-cmake.patch"

# need to export these variables for python-config to work
FILES:${PN} += "/usr/include/*"
FILES:${PN} += "/usr/lib/*"
FILES:${PN} += "/usr/lib64/*"
FILES:${PN}-dev += "${libdir}/cmake/*"
FILES:${PN}:append:class-native += "${libdir}/cmake/*"

SOLIBS = ".so"
FILES_SOLIBSDEV = ""

# Add support for tag numbers > 255 and fields larger than 255 bytes or 255 array entries
CFLAGS += "-DPB_FIELD_16BIT=1"

EXTRA_OECMAKE:append:class-native = "-Dnanopb_BUILD_GENERATOR=ON -Dnanopb_BUILD_RUNTIME=OFF -Dnanopb_MSVC_STATIC_RUNTIME=OFF"

EXTRA_OECMAKE += "-DCMAKE_INSTALL_CMAKEDIR=${libdir}/cmake/nanopb -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

BBCLASSEXTEND = "native nativesdk"
