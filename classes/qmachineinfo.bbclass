# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Function to get machine type based on machine features enabled
def get_machine_type(d):
    machine_features = set(d.getVar("MACHINE_FEATURES").split())
    if "qti-vm-guest" in machine_features:
        return "VM"
    if "qti-eap" in machine_features:
        return "EAP"
    if "external-ap" in machine_features:
        return "EAP"
    return "MDM"

# Function to get machine name based on machine features enabled
def get_machine_name(d):
    machine_features = set(d.getVar("MACHINE_FEATURES").split())
    if "qti-vm-fota" in machine_features:
        return "qcom,fotavm"
    if "qti-vm-tele" in machine_features:
        return "qcom,televm"
    if "qti-vm-guest" in machine_features:
        return "qcom,guestvm"
    if "qti-eap" in machine_features:
        return "qcom,eap"
    if "external-ap" in machine_features:
        return "nonqcom,eap"
    return "qcom,mdm"
