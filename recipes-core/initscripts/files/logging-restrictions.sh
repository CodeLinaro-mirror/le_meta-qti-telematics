#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

if [ -f /proc/sys/kernel/kptr_restrict ]; then
    echo 2 > /proc/sys/kernel/kptr_restrict
fi

if [ -f /proc/sys/kernel/dmesg_restrict ]; then
    echo 1 > /proc/sys/kernel/dmesg_restrict
fi
