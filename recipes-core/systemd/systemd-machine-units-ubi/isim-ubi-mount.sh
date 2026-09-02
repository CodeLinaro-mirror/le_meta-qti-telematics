#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

MTD_NAME="isim"
MOUNT_POINT="/isim"
UBI_CTRL="/dev/ubi_ctrl"
UBI_DEV=""          # will be detected
VOL_NAME="isim"

find_mtd_num() {
    grep -l "^${MTD_NAME}$" /sys/class/mtd/mtd*/name \
        | sed -n 's#.*mtd\([0-9]\+\)/name#\1#p' \
        | head -n1
}

find_ubi_dev() {
    for u in /sys/class/ubi/ubi*; do
        [ -f "$u/mtd_num" ] || continue
        if [ "$(cat "$u/mtd_num")" = "$1" ]; then
            basename "$u"
            return 0
        fi
    done
    return 1
}

case "$1" in
start)
    MTD_NUM="$(find_mtd_num)"
    if [ -z "$MTD_NUM" ]; then
        echo "isim : Failed to find MTD number, skipping" > /dev/kmsg
        exit 0
    fi


    # Attach if not already attached
    if ! grep -q "^$MTD_NUM$" /sys/class/ubi/ubi*/mtd_num 2>/dev/null; then
        if ! ubiattach "${UBI_CTRL}" -m "${MTD_NUM}" 2>/dev/null; then
            echo "isim : ubiattach failed for MTD ${MTD_NUM}, skipping" > /dev/kmsg
            exit 0
        fi
    fi

    # Find the UBI device number (ubiX)
    for i in 1 2 3 4 5; do
        UBI_DEV="$(find_ubi_dev "$MTD_NUM")"
        [ -n "$UBI_DEV" ] && break
        sleep 1
    done

    if [ -z "$UBI_DEV" ]; then
        echo "isim : Failed to resolve UBI device for MTD ${MTD_NUM} after retries, skipping" > /dev/kmsg
        exit 0
    fi

    if ! mkdir -p "${MOUNT_POINT}" 2>/dev/null; then
        echo "isim : Failed to create mount point ${MOUNT_POINT}; skipping" > /dev/kmsg
        exit 0
    fi

    # Mount using correct UBIFS syntax
    if ! mountpoint -q "${MOUNT_POINT}"; then
        if ! mount -t ubifs "${UBI_DEV}:${VOL_NAME}" "${MOUNT_POINT}" -o "rw,noatime,nodiratime,nodev,noexec,rootcontext=system_u:object_r:isim_fw_t:s0" 2>/dev/null; then
            echo "isim : mount failed for ${UBI_DEV}:${VOL_NAME} on ${MOUNT_POINT}, skipping" > /dev/kmsg
            exit 0
        fi
        if command -v restorecon >/dev/null 2>&1; then
            # Ensure files under /isim get policy-based labels after mount.
            restorecon -RF "${MOUNT_POINT}" >/dev/null 2>&1 || true
        fi
    else
        echo "isim : Already mounted, skipping" > /dev/kmsg
        exit 0
    fi
    ;;
stop)
    umount "${MOUNT_POINT}" 2>/dev/null || true

    MTD_NUM="$(find_mtd_num)"
    [ -n "$MTD_NUM" ] && ubidetach "${UBI_CTRL}" -m "${MTD_NUM}" || true
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
