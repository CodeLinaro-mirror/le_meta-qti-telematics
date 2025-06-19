######################################################################
# This configuration defines an OE Linux based distribution containing
# libraries and utilities required for running the complete system on
# qti Telematics chipsets.
######################################################################

# Get basic distro configuration
require conf/distro/include/qcom-base.inc

DISTRO_NAME = "QTI Linux Telematics distro."

##################################################################
# list of distro features
##################################################################
#
# dm-verity:       Support block integrity check on system image
# selinux:         Use selinux for mandatory access control.

DISTRO_FEATURES:append = " selinux dm-verity"

## QTI defined distro features ##
# qti-audio:     Support QTI audio solution
# qti-bluetooth: Support QTI bluetooth solution
# qti-cdsp:      Support QTI cdsp solution
# qti-adsp:      Support QTI adsp solution
# qti-security:  Support QTI security solution
# qti-vble:      Support QTI Verified boot for LE
# qti-earlyusb   Support QTI early USB init
# vbleima        Support system-integrity through IMA
# vbleevm        Support system-integrity through EVM
# qti-nad-telaf: Support telematics application framework
#

#DISTRO_FEATURES:append = " qti-adsp qti-security qti-vble qti-audio qti-earlyusb qti-early-eth qti-telux vbleima vbleevm qti-nad-core qti-nad-telaf"

# Allow checking of required and conflicting features across the distro
IMAGE_CLASSES += "features_check"

# Include in native DISTRO_FEATURES if present in the target DISTRO_FEATURES.
DISTRO_FEATURES_FILTER_NATIVE += " selinux"

# Set selinux in enforcing state by default
DEFAULT_ENFORCING ?= "permissive"
