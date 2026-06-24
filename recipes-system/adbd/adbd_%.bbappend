FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-ADB-Add-leprop-as-the-supplementary-group.patch \
	   "

do_install:append() {
    if ${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-vm-guest', 'true', 'false', d)}; then
        sed -i 's/Requires=/Wants=/g' ${D}${systemd_unitdir}/system/adbd.service
    fi
}
