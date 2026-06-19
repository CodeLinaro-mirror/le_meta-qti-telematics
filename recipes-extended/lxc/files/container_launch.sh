#!/bin/sh

#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: LGPL-2.1-only

OPS="${1}"
LXC_CONF_PATH="${2}"
DEF_VETH_HOST_IP="${3}"
LXC_CONTAINER_LOG_PATH="/tmp/container_logs"
CONTAINER_NAME="${4}"
PVM_SHARED_LXC_RW="/data/lxc_rw"
KPI_FILE_PATH="/sys/kernel/boot_kpi/kpi_values"
LXC_PID_FILE_PATH="/var/run/lxc_start_${CONTAINER_NAME}.pid"

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

function prepare_lxc_dirs()
{
   # For all logs from lxc-cmds
   mkdir -p ${LXC_CONTAINER_LOG_PATH}
}

function exec_lxc_ops() {
   local OPS="${1}"

   if [ ! -d "$LXC_CONTAINER_LOG_PATH" ]; then
      prepare_lxc_dirs
   fi

   if [ ! -f "$LXC_CONF_PATH" ]; then
      echo "LXC: Configuration file not present, exiting" > /dev/kmsg
      return 1
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
            lxc-start -n $CONTAINER_NAME -f $LXC_CONF_PATH -o $LXC_CONTAINER_LOG_PATH/lxc-start.log -l trace -p ${LXC_PID_FILE_PATH}
            lxc-info -n $CONTAINER_NAME | grep Link: | awk '{print $2}' | xargs -t -I {} ifconfig {} "$DEF_VETH_HOST_IP"
         else
            echo "No files in /lxcrootfs, skipping lxc create/start" > /dev/kmsg
            return 1
         fi

         echo -n "M - Container $CONTAINER_NAME init finish" >> $KPI_FILE_PATH
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
            return 1
         fi
         ;;

      *)
      echo "No proper input"
      return 1
      ;;
   esac
}

if [ "$#" -eq "0" ]; then
   echo "incorrect number of arguments supplied"
   echo "usage: ~/# con_launch.sh <start/stop> <conf> <ip> <name>"
   exit 1
fi

echo -n "M - Container $CONTAINER_NAME init start" >> $KPI_FILE_PATH

exec_lxc_ops $1

if [ "$?" == "1" ]; then
   exit 1
fi

exit 0
