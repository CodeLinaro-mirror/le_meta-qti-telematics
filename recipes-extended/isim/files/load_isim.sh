#!/bin/sh
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#

case "$1" in
     start)
          echo "isim : Starting isim dlkm service" > /dev/kmsg
          insmod /lib/modules/$(uname -r)/updates/isim_dlkm.ko
          ;;

     stop)
          echo "isim : Stopping isim dlkm service" > /dev/kmsg
          rmmod isim_dlkm
          echo "tecic : removed dlkm"
          ;;

        *)
          echo "Usage: $0 {start|stop}"
          exit 1
          ;;
esac
