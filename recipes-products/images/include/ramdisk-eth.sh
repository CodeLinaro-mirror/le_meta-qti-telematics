#!/bin/sh

# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

SetupEth() {
    for iface in $(busybox ls /sys/class/net/ | busybox sort); do
        if [ ! -d /sys/class/net/${iface} ]; then
            continue
        fi

        emac_node="/sys/class/net/${iface}/device/of_node"
        if [ ! -d "${emac_node}" ]; then
            continue
        fi

        if [ ! -e "${emac_node}/qcom,early-eth-en" ]; then
            continue
        fi

        if [ -f "${emac_node}/ipv4-addr" ]; then
            ipv4_addr=$(busybox cat "${emac_node}/ipv4-addr" | busybox tr -d '\0')
            busybox ip addr add ${ipv4_addr}/24 dev ${iface}
            if [ $? -ne ${STATUS_OK} ]; then
                busybox echo "SetupEth: ip addr add ${ipv4_addr} to ${iface} failed" > /dev/kmsg
            fi
        fi

        if [ -f "${emac_node}/ipv6-addr" ]; then
            ipv6_addr=$(busybox cat "${emac_node}/ipv6-addr" | busybox tr -d '\0')
            busybox ip addr add ${ipv6_addr}/64 dev ${iface}
            if [ $? -ne ${STATUS_OK} ]; then
                busybox echo "SetupEth: ip addr add ${ipv6_addr} to ${iface} failed" > /dev/kmsg
            fi
        fi

        busybox ip link set ${iface} up
        if [ $? -ne ${STATUS_OK} ]; then
            busybox echo "SetupEth: ip link set ${iface} up failed" > /dev/kmsg
        fi
    done

    return ${STATUS_OK}
}
