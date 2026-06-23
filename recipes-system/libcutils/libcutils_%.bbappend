FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0002-ADB-Add-leprop-to-group-list.patch;patchdir=.. \
	   "

EXTRA_OECONF:append:qti-distro-debug = "\
            ${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-sdx qti-vm-host', '--enable-leproperties', '', d)} \
"
