#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

PATH=/sbin:/bin:/usr/sbin:/usr/bin

FIRMWARE_PART_NAME="firmware"
FIRMWARE_MOUNT="/firmware"
RECINFO_PART_NAME="recoveryinfo"

# Function return status
STATUS_OK=0
STATUS_ERR=1
STATUS_INVAL=-1
DEV_NUM=-1
UEVENT_PATH=""
SYS_MMC_PATH="/sys/class/block"
MAX_RETRY=150
SLOT_SUFFIX=""
abctl_cmd="/usr/bin/nad-abctl"
IsGPIOEnabled () {
    gpio_enable_status=`cat /proc/cmdline | awk -F'recoveryinfo_gpio=' '{print $2}' | awk '{print $1}' | tr -d '"'`
    return ${gpio_enable_status}
}

SetImageStatus() {
    arg=$1
    ${abctl_cmd} --set_image_set_status ${arg}
    if [ "$?" -eq "${STATUS_INVAL}" ]; then
        echo "Error: image set status failed" > /dev/kmsg
        return ${STATUS_ERR}
    fi
    return ${STATUS_OK}
}

SetImageOwner() {
    arg=$1
    ${abctl_cmd} --set_owner ${arg}
    if [ "$?" -eq "${STATUS_INVAL}" ]; then
        echo "Error: owner set failed" > /dev/kmsg
        return ${STATUS_ERR}
    fi
    return ${STATUS_OK}
}

SlotSwitchReboot () {
    DEV_NUM=-1
    # Set image_set_status fields in recoveryinfo struct
    #  'A&B' Usable     :  SET_AB_USABLE(0)
    #  'A' corrupted     :  DONT_USE_SET_A(1)
    #  'B' corrupted     :  DONT_USE_SET_B(2)
    #  'A &B' corrupted  :  DONT_USE_SET_AB(3)

    # Set owner fields in recoveryinfo struct
    #  OWNER_XBL         :  1
    #  OWNER_HLOS        :  2
    local owner_hlos=2
    local dont_use_set_a=1
    local dont_use_set_b=2
    local dont_use_set_ab=3
    local current_image_set_status=0
    if [ ! -e ${abctl_cmd} ]; then
        echo "${abctl_cmd} not found." > /dev/kmsg
        /bin/sh -c 'reboot edl'
        exit 1
    fi

    EmmcGetPartitionID ${RECINFO_PART_NAME}
    if [ "${DEV_NUM}" == "${STATUS_INVAL}" ]; then
        echo "Cannot get ${RECINFO_PART_NAME} partition." > /dev/kmsg
        /bin/sh -c 'reboot edl'
        exit 1
    fi

    # check current slot and image_set_status in recoveryinfo
    #  'A' corrupted     :  set image_set_status = DONT_USE_SET_A
    #  'B' corrupted     :  set image_set_status = DONT_USE_SET_B
    #  'A &B' corrupted  :  set image_set_status = DONT_USE_SET_AB

    curr_slot=`cat /proc/cmdline | awk -F'SLOT_SUFFIX=' '{print $2}' | awk '{print $1}' | tr -d '"'`
    if [ "x${curr_slot}" == "x" ]; then
        # Single system (non AB)
        echo "slot_suffix not present or invalid, reboot to edl" > /dev/kmsg
        /bin/sh -c 'reboot edl'
        exit 1
    else
        # A/B system case
        #Get current image set status
        (${abctl_cmd} --get_image_set_status)
        current_image_set_status=$?
        if [ "$current_image_set_status" -eq "-1" ]; then
            echo "Error: incorrect image set status" > /dev/kmsg
            /bin/sh -c 'reboot edl'
            exit 1
        fi

        if [ "$curr_slot" = "_a" ] && [ "$current_image_set_status" != "$dont_use_set_b" ]; then
            echo "Firmware A partition corrupted " > /dev/kmsg
            SetImageStatus ${dont_use_set_a}
            if [ "$?" -eq "${STATUS_ERR}" ]; then
                /bin/sh -c 'reboot edl'
                exit 1
            fi
        elif [ "$curr_slot" = "_b" ] && [ "$current_image_set_status" != "$dont_use_set_a" ]; then
            echo "Firmware B partition corrupted " > /dev/kmsg
            SetImageStatus ${dont_use_set_b}
            if [ "$?" -eq "${STATUS_ERR}" ]; then
                /bin/sh -c 'reboot edl'
                exit 1
            fi
        else
            echo "Firmware A and B partition is corrupted." > /dev/kmsg
            SetImageStatus ${dont_use_set_ab}
            if [ "$?" -eq "${STATUS_ERR}" ]; then
                /bin/sh -c 'reboot edl'
                exit 1
            fi
        fi
    fi

    #Set owner is set by SetImageStatus command internally, crashing device.
    #XBL or ABL will take care of slot switching after reboot with Trail Boot Enabled.
    echo "RBM: Reboot for switching slots or EDL mode" > /dev/kmsg
    /bin/sh -c 'reboot system-abnormal'
    exit 1
}

GetSlotSuffix() {
    local act_slot=""
    # We will only take "_a" and "_b" as correct active slot
    # Else all will be ignored and DEV_NUM will set as -1
    act_slot=`cat /proc/cmdline | awk -F'SLOT_SUFFIX=' '{print $2}' | awk '{print $1}' | tr -d '"'`
    if [ "${act_slot}" == "_b" ]; then
       SLOT_SUFFIX="_b"
    else
       SLOT_SUFFIX=""
    fi
}

EmmcGetPartitionID() {
    DEV_NUM=-1
    local PART_NAME=$1
    local retry_count=0
    UEVENT_PATH=""

    # Fetch active part uevent then parse dev num from PARTN
    while [ -z $UEVENT_PATH ]
    do
        UEVENT_PATH=$(grep -w $PART_NAME ${SYS_MMC_PATH}/mmcblk0p*/uevent | cut -d ":" -f 1)
        sleep 0.1
        retry_count=$(( retry_count + 1))
        if [ $retry_count -ge $MAX_RETRY ]; then
            echo "Error: EmmcGetPartitionID timed out $retry_count" > /dev/kmsg
            return ${STATUS_ERR}
        fi
    done
    DEV_NUM=$(grep -w PARTN $UEVENT_PATH | awk -F '=' '{print $2}')
}

#
# Mount the firmware partition
#
FindAndMountFW () {
    GetSlotSuffix
    EmmcGetPartitionID ${FIRMWARE_PART_NAME}${SLOT_SUFFIX}
    if [ "${DEV_NUM}" == "-1" ]; then
        echo "Cannot get ${FIRMWARE_PART_NAME}${SLOT_SUFFIX} partition." > /dev/kmsg
        exit 1
    fi

    block_device="/dev/mmcblk0p"$DEV_NUM
    mount -o noexec,nodev,nosuid,ro,context=system_u:object_r:firmware_t:s0 -t vfat $block_device ${FIRMWARE_MOUNT}
    if [ $? -ne ${STATUS_OK} ]; then
        echo "Unable to mount firmware partition" > /dev/kmsg
        IsGPIOEnabled
        if [ $? -eq 1 ]; then
            #GPIO Enabled moving device to EDL.
            echo "GPIO Enabled boot to EDL" > /dev/kmsg
            /bin/sh -c 'reboot edl'
        else
            echo "GPIO disabled switch the slots or boot to EDL." > /dev/kmsg
            SlotSwitchReboot
        fi
        exit 1
    fi
    return ${STATUS_OK}
}

eval FindAndMountFW
exit 0
