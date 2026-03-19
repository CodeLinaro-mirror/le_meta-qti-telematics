#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#

case "$1" in
     start)
          echo "isim : Starting isim dlkm service" > /dev/kmsg
          modprobe /lib/modules/$(uname -r)/updates/isim_dlkm.ko
          echo "isim : Changing permissions of isim dev nodes" > /dev/kmsg
          chmod 0600 /dev/isim_img2
          chmod 0600 /dev/isim_img3
          chmod 0600 /dev/isim_ipc
          chmod 0600 /dev/isim_load
          chmod 0600 /dev/isim_mbox
          chmod 0600 /dev/ddr_mmap
          echo "isim : Changed permissions of isim dev nodes" > /dev/kmsg
          echo "isim : Changing ownership  of isim dev nodes" > /dev/kmsg
          chown isim:isim /dev/isim_img2
          chown isim:isim /dev/isim_img3
          chown isim:isim /dev/isim_ipc
          chown isim:isim /dev/isim_load
          chown isim:isim /dev/isim_mbox
          chown isim:isim /dev/ddr_mmap
          echo "isim : Changed ownership  of isim dev nodes" > /dev/kmsg
          ;;

     stop)
          echo "isim : Stopping isim dlkm service" > /dev/kmsg
          modprobe -r isim_dlkm
          echo "isim : removed dlkm"
          ;;

        *)
          echo "Usage: $0 {start|stop}"
          exit 1
          ;;
esac
