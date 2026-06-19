#!/bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: LGPL-2.1-only

LXC_CONF_PATH="/etc/lxc/lxc_networking.conf"
DEF_VETH_HOST_IP="192.168.2.200"
LXC_CONTAINER_LOG_PATH="/tmp/container_logs"
CONTAINER_NAME="con1"

function moduleExist(){

   #disabled for now
   return 2

   MODULE="$1"
   if lsmod | grep "$MODULE" &> /dev/null ; then
      return 0
   else
      return 1
   fi
}

function exec_lxc_ops() {
   OPS="$1"

   if [ ! -d "$LXC_CONTAINER_LOG_PATH" ]; then
      mkdir -p $LXC_CONTAINER_LOG_PATH
   fi

   case $OPS in
      start)
         if [ -n "$(ls -A /lxcrootfs 2>/dev/null)" ]; then

            #loading modules for lxc
            moduleExist macvlan
            if [ "$?" == "1"  ]; then
               modprobe macvlan
            fi

            moduleExist ip6table_nat
            if [ "$?" == "1"  ]; then
               modprobe ip6table_nat
            fi

            moduleExist xt_CHECKSUM
            if [ "$?" == "1"  ]; then
               modprobe xt_CHECKSUM
            fi

            lxc-create -n $CONTAINER_NAME -f $LXC_CONF_PATH -t none -o $LXC_CONTAINER_LOG_PATH/lxc-create.log -l trace
            lxc-start -n $CONTAINER_NAME -o $LXC_CONTAINER_LOG_PATH/lxc-start.log -l trace
            lxc-info -n $CONTAINER_NAME | grep Link: | awk '{print $2}' | xargs -t -I {} ifconfig {} "$DEF_VETH_HOST_IP"
         else
            echo "No files in /lxcrootfs, skipping lxc create/start" > /dev/kmsg
         fi
         ;;

      stop)
         if [ -n "$(ls -A /lxcrootfs 2>/dev/null)" ]; then
               lxc-stop -n $CONTAINER_NAME
               lxc-destroy -n $CONTAINER_NAME -o $LXC_CONTAINER_LOG_PATH/lxc-destroy.log -l trace
            #manually deleting the container path, because
            #container marked as non mananged in conf
            rm "/tmp/container" -rf

            #removing modules for lxc
            moduleExist xt_CHECKSUM
            if [ "$?" == "0"  ]; then
               rmmod xt_CHECKSUM
            fi

            moduleExist ip6table_nat
            if [ "$?" == "0"  ]; then
               rmmod ip6table_nat
            fi

            moduleExist macvlan
            if [ "$?" == "0"  ]; then
               rmmod macvlan
            fi
         else
            echo "No files in /lxcrootfs, skipping lxc stop/destroy" > /dev/kmsg
         fi
         ;;

      *)
      echo "No proper input"
      ;;
   esac
}

eval exec_lxc_ops $1
exit 0
