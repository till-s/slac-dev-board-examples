
# Define target output
target: prom bin

# Define Firmware Version Number
export PRJ_VERSION = 0x00000002

# Define target part
export PRJ_PART = XC7Z015CLG485-2
#export PRJ_PART = XC7Z030SBG485-1
#export PRJ_PART = XC7Z012SCLG485-1

PRJ_FAMILY = $(shell echo "$(PRJ_PART)" | sed -e 's/\(XC7Z\)\([0-9]\+\).*/7z\2/')

# Define the Microblaze source path
#export SDK_SRC_PATH = $(PROJ_DIR)/../../../common/core/src

export REMOVE_UNUSED_CODE = 1

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../..)

# Image variant:
#
# deflt, ibert, devbd, toggle

export IMAGE_VARIANT = ecevr

PROJECT_ibert = TE0715-tb7-ibert
PROJECT_deflt = TE0715-tb7
PROJECT_devbd = TE0715-tb7-devbd
PROJECT_toggle= TE0715-tb7-toggle
PROJECT_ecevr = TE0715-ec

export PROJECT = $(PROJECT_$(IMAGE_VARIANT))-$(PRJ_FAMILY)

# Which MGT to use for the timing stream ethernet
# 0: SGMII interface of TE0715 module's ethernet PHY
#    (instead of PS ethernet)
# 1: SFP closer to TE0715 module
# 2: SFP closer to board edge (not present on development carrier)
#
# The MGT used for the timing fiber is 1 by default and 2 if
# TIMING_ETH_MGT=1
export TIMING_ETH_MGT=2

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk

fam:
	echo $(PRJ_FAMILY)
