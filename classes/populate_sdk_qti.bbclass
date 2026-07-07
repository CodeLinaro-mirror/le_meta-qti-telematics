# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Copyright (c) 2021, The Linux Foundation. All rights reserved.
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

# The majority of populate_sdk is located in populate_sdk_base
# which is inherited by populate_sdk_ext. So inheriting
# populate_sdk_ext also helps to run populate_sdk task.

inherit populate_sdk_ext

COPY_DIRECTORY_TREE = "${COREBASE}/meta-qti-bsp/files/copy_directory_tree.sh"

python copy_buildsystem:append() {
    import subprocess
    # Create src directory in extensible SDK to copy the project sources
    bb.utils.mkdirhier(baseoutpath + '/src')
    # Enable the use of WORKSPACE variable on an extensible SDK
    with open(baseoutpath + '/conf/bblayers.conf', 'a') as f:
        f.write('WORKSPACE = "$' + '{TOPDIR}/src"\n')

    # Copy prebuilt tar to eSDK and set PREBUILT_SRC_DIR
    prebuilt_src_dir_sdk = ""
    default_prebuilt_src_dir = d.getVar('DEFAULT_PREBUILT_SRC_DIR')
    default_prebuilt_src_dir_list = default_prebuilt_src_dir.split()
    for dir in default_prebuilt_src_dir_list:
        if os.path.exists(str(dir)):
            destdir = baseoutpath + str(dir).replace(d.getVar('WORKSPACEROOT'),"")
            bb.utils.mkdirhier(destdir)
            cmd = "%s %s %s" % (d.getVar('COPY_DIRECTORY_TREE'), str(dir), destdir)
            subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
            prebuilt_src_dir_sdk = prebuilt_src_dir_sdk + '${TOPDIR}/'  + str(dir).replace(d.getVar('WORKSPACEROOT'),"") + " "
        else:
            pass

    with open(baseoutpath + '/conf/local.conf', 'a') as f:
        f.write('\nPREBUILT_SRC_DIR = "%s"\n' % prebuilt_src_dir_sdk)
}

# To include llvm-arm-toolchain as part of sysroots in eSDK tmp directory
DEPENDS:append = " llvm-arm-toolchain-native "

# To include protoc compiler in SDK
TOOLCHAIN_HOST_TASK:append = " nativesdk-protobuf-compiler "

# Add nativesdk-llvm-arm-toolchain in SDK to run on SDKMACHINE
TOOLCHAIN_HOST_TASK:append = " nativesdk-llvm-arm-toolchain"
