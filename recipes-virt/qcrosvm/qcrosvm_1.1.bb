inherit ${@bb.utils.contains("BBFILE_COLLECTIONS", "rust-layer", "cargo", "", d)} systemd
inherit cargo pkgconfig systemd

SUMMARY  = "QCrosVM Support"
HOMEPAGE = "https://www.codelinaro.org/"
LICENSE  = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

PR = "R1"

DEPENDS += "cargo-native libcap rust-native rust-llvm-native"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "\
        file://vendor/qcom/opensource/crosvm-gunyah \
        file://external/crosvm/ \
        file://external/rust/crates/ \
        file://external/minijail/ \
"

S = "${UNPACKDIR}/vendor/qcom/opensource/crosvm-gunyah"

CARGO_DISABLE_BITBAKE_VENDORING = "1"

do_compile[network] = "1"

inherit useradd

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} += "-u 3025 --home /usr/sbin --no-create-home --shell /bin/nologin --user-group qvirt;"
