# Copyright (c) 2020-2021, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This patch file is from Qualcomm Technologies, Inc. and is provided under the following license:
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# For recipe inheriting 'qprebuilt', this class allows to:
#    - Generate prebuilt package(s) from 'installed' files
#      (content of ${D}) and place them in DEPLOY_DIR_PREBUILT.
#    - Use prebuilt package instead of fetching and compiling
#      the source, when PREBUILT_SRC_DIR is defined.
#
# ### Creating prebuilt package(s)
#
# By default, a prebuilt package is generated with all 'installed'
# files (content of ${D}).
#
# It's possible to strip binaries before packaging by setting
# PREBUILT_STRIP variable to "1", default is "0".
#
# It's possible to create several prebuilt packages with different
# content, using PREBUILT_PACKAGES and PREBUILT_FILES variables.
#
# E.g. libvendor-1.8.bb - PN="libvendor" ARCH="aarch64"
#
# PREBUILT_PACKAGES = "${PN}-full ${PN}-stripped ${PN}-minimal"
# PREBUILT_FILES:${PN}-full = "/"
# PREBUILT_FILES:${PN}-stripped = "/"
# PREBUILT_STRIP:${PN}-stripped = "1"
# PREBUILT_FILES:${PN}-minimal = "${bindir} ${libdir}"
# PREBUILT_STRIP:${PN}-minimal = "1"
#
# This will create three archives:
#   libvendor-full_1.8:aarch64.tar.gz
#   libvendor-stripped_1.8:aarch64.tar.gz (stripped content)
#   libvendor-minimal_1.8:aarch64.tar.gz  (stripped content)
#
# These prebuilt packages can then be distribuded to customers.
#
# Note - by default:
# PREBUILT_PACKAGES = "${PN}"
# PREBUILT_FILES:${PN} = "/"
#
# ### Build dependencies
#
# Build dependencies (DEPENDS) can be selectively removed when relying on
# prebuilt packages. This can be achieved via PREBUILT_INHIBIT_DEPS variable.
# If set to "0" (default) build deps are preserved, if set to "1" all buil
# deps are removed, else variable is considered as a list of dependencies to
# inhibit.
#
# DEPENDS = "systemd zlib"
# ...
# PREBUILT_INHIBIT_DEPS = "zlib"
# ...
# inherit prebuilt
#
# ### Using prebuilt package(s)
#
# User needs to define a PREBUILT_SRC_DIR, E.g:
#     PREBUILT_SRC_DIR = "/home/vendor/prebuilts"
# To search under multiple paths mention in a space separated list, E.g:
#     PREBUILT_SRC_DIR = "/home/vendor/prebuilt1 /home/vendor/prebuilt2"
#
# It's possible to search under a few default directories by setting
# USE_DEFAULT_PREBUILT_SRC_DIR variable to "1", default is "0". These
# additional paths are specified using DEFAULT_PREBUILT_SRC_DIR variable
# in one of the .conf files and are considered along with the ones defined in
# PREBUILT_SRC_DIR. No sanity checks are in place for dupliate tarballs.
# Users need to carefully provide paths to avoid surprizes.
#
# If prebuilt class finds a package compatible with the recipe, it will be used to
# populate ${D}, fetch, compile... functions will be discarded.

# Anonymous function needs to be executed each time so that runqueue
# can be updated
BB_DONT_CACHE = "1"

DEPLOY_DIR_PREBUILT ?= "${DEPLOY_DIR}/prebuilts"
PREBUILT_DIR = "${WORKDIR}/prebuilt"
PREBUILT_DATA_DIR = "${WORKDIR}/prebuiltdata"
PREBUILT_INHIBIT_DEPS ?= "0"

# Default prebuilt package
PREBUILT_PACKAGES ?= "${PN}"

#Default change log filename
CHANGES_FILE ?= "CHANGES"

# Compute prebuilt paths
def get_prebuilt_paths(d):
    pbpaths = []

    srcdir = d.getVar('PREBUILT_SRC_DIR')
    pkgpath = d.getVar("PREBUILT_PKG_PATH") or ""
    if srcdir:
        pbpaths.append(os.path.join(srcdir, pkgpath))

    defaultsrc = d.getVar('USE_DEFAULT_PREBUILT_SRC_DIR')
    if defaultsrc == "1":
        dpbpath = (d.getVar("DEFAULT_PREBUILT_SRC_DIR") or "").split()
        pbpaths += os.path.join(dpbpath, pkgpath)

    bb.debug(1,"Searching for prebuilts in: %s" % pbpaths)

    return " ".join(pbpaths)

# Install Prebuilt tarball
do_install_prebuilt[dirs] = "${D}"
do_install_prebuilt[doc] = "Populate Destination directory with prebuilt package content"

fakeroot python do_install_prebuilt() {
    import shutil

    licensedir = d.getVar('LICENSE_DIRECTORY')
    arch = d.getVar('PACKAGE_ARCH')
    alternate_archs = (d.getVar('MACHINEOVERRIDES') or "").split(":")
    dest = d.getVar('D')
    pn = d.getVar("PN")
    pv = d.getVar('PV')
    tarball = ""
    done = True

    # Check if prebuilt tarball exist
    for prebuiltsrc in (get_prebuilt_paths(d) or "").split():
        ppackages = (d.getVar("PREBUILT_PACKAGES") or "").split()
        for ppackage in ppackages:
            tbpath = prebuiltsrc + "/" + ppackage + "_" + pv + "_" + arch + ".tar.gz"
            if os.path.exists(tbpath):
                    tarball = tbpath
            else:
                for selected_arch in reversed(alternate_archs):
                    tbpath = prebuiltsrc + "/" + ppackage + "_" + pv + "_" + \
                              selected_arch.replace('-', '_') + ".tar.gz"
                    if os.path.exists(tbpath):
                        tarball = tbpath
                        break
            if tarball:
                bb.note("Install %s" % tarball)
                cmd = "tar -xvzf %s -C %s" % (tarball, dest)
                (retval, output) = oe.utils.getstatusoutput(cmd)
                if retval:
                    bb.fatal("Errors in extracting prebuilt: %s (%s)" % ( tarball, output))

    # Stop change log from getting packaged
    changesfile = os.path.join(dest, d.getVar('CHANGES_FILE'))
    if os.path.exists(changesfile):
        os.remove(changesfile)

    # Stop notice file from getting packaged
    noticefile = os.path.join(dest, "NOTICE")
    if os.path.exists(noticefile):
        os.remove(noticefile)

    # Install license into licensedir
    licensefile = os.path.join(dest, "LICENSE.qcom-2")
    licensedir = d.getVar('LICENSE_DIRECTORY')
    pn = d.getVar("PN")
    cmd = "cp %s %s/%s" % (licensefile, licensedir, pn)
    (retval, output) = oe.utils.getstatusoutput(cmd)
    if retval:
        bb.warn("Unable to retrieve license: %s" % output)

    # Stop license file from getting packaged
    if os.path.exists(licensefile):
        os.remove(licensefile)

    # Some older archives may still have these files. Drop them.
    if os.path.exists(os.path.join(dest, "NO.LOGIN.BINARY.LICENSE.QTI.pdf")):
        os.remove(os.path.join(dest, "NO.LOGIN.BINARY.LICENSE.QTI.pdf"))
    if os.path.exists(os.path.join(dest, "NOTICE.txt")):
        os.remove(os.path.join(dest, "NOTICE.txt"))
    if os.path.exists("%s/__LIC__" % dest):
        shutil.rmtree("%s/__LIC__" % dest, ignore_errors=True)
}

def gen_prebuiltvar(d):
    ret = []
    ppackages = (d.getVar("PREBUILT_PACKAGES") or "").split()
    pbvariants = (d.getVar("PREBUILT_VARIANTS") or "").split()
    # e.g. HY11_PREBUILT_PACKAGES, HY22_PREBUILT_PACKAGES
    for variant in pbvariants:
        ret.append(variant + "_PREBUILT_PACKAGES")

    ret.append("PREBUILT_FILES")
    ret.append("PREBUILT_STRIP")
    ret.append("PREBUILT_PKG_PATH")

    return " ".join(ret)

# Generate Prebuilt tarball
SSTATETASKS += "do_generate_prebuilt"
do_generate_prebuilt[dirs] = "${D}"
do_generate_prebuilt[cleandirs] = "${PREBUILT_DIR} ${PREBUILT_DATA_DIR}"
do_generate_prebuilt[sstate-inputdirs] = "${PREBUILT_DATA_DIR}"
do_generate_prebuilt[sstate-outputdirs] = "${DEPLOY_DIR_PREBUILT}"
do_generate_prebuilt[stamp-extra-info] = "${PACKAGE_ARCH}"
do_generate_prebuilt[doc] = "Create a prebuilt package"
do_generate_prebuilt[vardeps] = "${@gen_prebuiltvar(d)}"

def strip_dir(d, dir):
    strip = d.getVar('STRIP')
    cmd = "find " + dir + " -type f -exec " + strip + "--remove-section=.comment --remove-section=.note --strip-debug" + " {} +"
    (retval, output) = oe.utils.getstatusoutput(cmd)

python do_generate_prebuilt() {
    import re
    import shutil

    ppackages = (d.getVar("PREBUILT_PACKAGES") or "").split()
    pbvariants = (d.getVar("PREBUILT_VARIANTS") or "").split()
    pn = d.getVar('PN')
    pv = d.getVar('PV')
    arch = d.getVar('PACKAGE_ARCH')
    prebuiltdir = os.path.join(d.getVar('PREBUILT_DIR'), "non-stripped")
    prebuiltstrippeddir = os.path.join(d.getVar('PREBUILT_DIR'), "stripped")
    prebuiltdatadir = d.getVar('PREBUILT_DATA_DIR')
    inputdir = d.getVar('D')
    licensedir = os.path.join(d.getVar('LICENSE_DIRECTORY'), arch, pn)

    # Copy ${D}
    shutil.copytree(inputdir, prebuiltdir, True)

    # Add license
    licensefile = os.path.join(licensedir, "LICENSE.qcom-2")
    license_file = os.path.join(d.getVar('COREBASE'), "..", "meta-qti-bsp", "files", "common-licenses", "LICENSE.qcom-2")
    if os.path.exists(licensefile):
        shutil.copy2(licensefile, prebuiltdir)
    elif os.path.exists(license_file):
        shutil.copy2(license_file, prebuiltdir)
    else:
        bb.warn("LICENSE.qcom-2 is not available to archive")

    # Add changes log
    excluded_names = ["changelog", "changelog.txt"]
    if d.getVar('CHANGES_FILE') in excluded_names:
        bb.fatal(" Naming log file as 'changelog' is not allowed to avoid conflict with dpkg" +
        "changelog [https://www.debian.org/doc/debian-policy/ch-source.html#s-dpkgchangelog]")

    changesfile = os.path.join(d.getVar('S'), d.getVar('CHANGES_FILE'))
    if os.path.exists(changesfile) and os.path.getsize(changesfile) > 0:
        shutil.copy2(changesfile, prebuiltdir)
    else:
        bb.warn("\nChange log file (%s) is either not accessible or empty. "
                "Ensure that a valid log file exists under ${S}, and CHANGES_FILE "
                "variable is correctly set to point to it." % changesfile)

    # Add notice
    noticefile = os.path.join(d.getVar('S'), "generate_NOTICE.txt")
    if os.path.exists(noticefile):
        shutil.copy2(noticefile, os.path.join(prebuiltdir, "NOTICE"))
    else:
        bb.warn(" NOTICE is not available to archive")

    # fork and strip
    shutil.copytree(prebuiltdir, prebuiltstrippeddir, True)
    strip_dir(d, prebuiltstrippeddir)

    # Create prebuilt archive(s)
    for ppackage in ppackages:
        for variant in pbvariants:
            files = d.getVar("PREBUILT_FILES")
            stripped = d.getVar("PREBUILT_STRIP")
            pkgpath = d.getVar("PREBUILT_PKG_PATH") or ""
            tarballdir = os.path.join(prebuiltdatadir, variant, pkgpath)
            os.makedirs(tarballdir, exist_ok=True)
            tarball = "%s/%s_%s_%s.tar" % (tarballdir, ppackage, pv, arch)
            base = prebuiltdir

            # If no file specified quitely quit
            if files:
                files = files.split()
            else:
                bb.debug(1, "No files to create archive %s" %(tarball))
                continue

            if stripped and stripped != "0":
                bb.debug(1, "Packing stripped files into archive %s" %(tarball))
                base = prebuiltstrippeddir

            # Create empty archive
            cmd = "tar -cf %s -T /dev/null" % (tarball)
            (retval, output) = oe.utils.getstatusoutput(cmd)
            if retval:
                bb.fatal("Unable to create archive %s : %s" %(tarball, output))

            os.chdir(base)

            # Append files
            for file in files:
                directory, filename = os.path.split(file)
                file_regex = re.compile(filename)
                if os.path.exists(f"./{directory}"):
                    files_matched = [f for f in os.listdir(f"./{directory}") if file_regex.match(f)]
                    for file_matched in files_matched:
                        full_path = os.path.join(directory, file_matched)
                        cmd = "tar --owner 0 --group 0 -rvf %s ./%s" % (tarball, full_path)
                        (retval, output) = oe.utils.getstatusoutput(cmd)
                        if retval:
                            bb.debug(1,"Unable to add %s (%s) to archive %s: %s" % (file_matched, file, tarball, output))

            # Append license, notice and changelog to archive
            arch_metadata = ["LICENSE.qcom-2", "NOTICE", d.getVar('CHANGES_FILE')]
            for metadata in arch_metadata:
                if os.path.exists(metadata):
                    cmd = "tar --owner 0 --group 0 -rvf %s ./%s" % (tarball, metadata)
                    (retval, output) = oe.utils.getstatusoutput(cmd)
                    if retval:
                        bb.debug(1, "Unable to add %s to archive %s: %s" %(metadata, tarball, output))

            # gzip
            cmd = "gzip %s %s.gz" % (tarball, tarball)
            (retval, output) = oe.utils.getstatusoutput(cmd)
            if retval:
                bb.fatal("Unable to gzip archive: %s" % output)
}

python do_generate_prebuilt_setscene() {
    sstate_setscene(d)
}

# In case of prebuilt usage, these tasks are discarded
PREBUILT_DISCARDED_TASKS += "\
    do_fetch \
    do_unpack \
    do_patch \
    do_configure \
    do_compile \
    do_install \
    do_populate_lic \
"

python () {
    arch = d.getVar('PACKAGE_ARCH')
    alternate_archs = (d.getVar('MACHINEOVERRIDES') or "").split(":")
    pn = d.getVar('PN')
    pv = d.getVar('PV')
    found = False

    # Check if prebuilt tarball exist
    for prebuiltsrc in (get_prebuilt_paths(d) or "").split():
        ppackages = (d.getVar("PREBUILT_PACKAGES") or "").split()
        for ppackage in ppackages:
            tarball = ppackage + "_" + pv + "_" + arch + ".tar.gz"
            bb.debug(1, "Looking for: %s" % (prebuiltsrc + "/" + tarball))
            if os.path.exists(prebuiltsrc + "/" + tarball):
                found = True
                break
            else:
                for selected_arch in reversed(alternate_archs):
                    tarball = ppackage + "_" + pv + "_" + \
                              selected_arch.replace('-', '_') + ".tar.gz"
                    bb.debug(1, "Looking for: %s" % (prebuiltsrc + "/" + tarball))
                    if os.path.exists(prebuiltsrc + "/" + tarball):
                        found = True
                        break
            if found == False:
                bb.debug(1, "Unable to find archive: %s" % (prebuiltsrc + "/" + tarball))

    if found:
        # Use prebuilt, discard build operations
        for task in d.getVar('PREBUILT_DISCARDED_TASKS').split():
            d.setVarFlag(task, 'noexec', '1')
        bb.build.addtask('do_install_prebuilt', 'do_populate_sysroot', 'do_install', d)
        d.appendVarFlag('do_package', 'depends', ' %s:do_install_prebuilt' % pn)

        # Remove build-only deps ?
        inhibit_deps = d.getVar('PREBUILT_INHIBIT_DEPS')
        if inhibit_deps == "1":
            d.setVar('DEPENDS:remove:pn-%s' % pn, d.getVar('DEPENDS'))
        elif inhibit_deps != "0":
            d.setVar('DEPENDS:remove:pn-%s' % pn, inhibit_deps)

        # Ignore qa-already-stripped as files are pre-stripped
        d.appendVar("INSANE_SKIP:%s" % pn, " already-stripped")

    elif d.getVar('DEPLOY_DIR_PREBUILT'):
        # Create prebuilt tarball(s)
        bb.build.addtask('do_generate_prebuilt', 'do_packagedata', 'do_install', d)
        d.appendVarFlag('do_generate_prebuilt', 'depends', ' %s:do_populate_lic' % pn)
        bb.build.addtask('do_generate_prebuilt_setscene', None, None, d)
}
