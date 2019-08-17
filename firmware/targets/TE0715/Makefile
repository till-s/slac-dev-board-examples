
# Define target output
target: prom bin

# Define Firmware Version Number
export PRJ_VERSION = 0x00000001

# Define target part
export PRJ_PART = XC7Z015CLG485-2
#export PRJ_PART = XC7Z030SBG485-1
#export PRJ_PART = XC7Z012SCLG485-1

# Define the Microblaze source path
#export SDK_SRC_PATH = $(PROJ_DIR)/../../../common/core/src

export REMOVE_UNUSED_CODE = 1

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../..)

# Image variant:
#
# deflt, ibert, devbd, toggle

export IMAGE_VARIANT = deflt

PROJECT_ibert = TE0715-tb7-ibert
PROJECT_deflt = TE0715-tb7
PROJECT_devbd = TE0715-tb7-devbd
PROJECT_toggle= TE0715-tb7-toggle

export PROJECT = $(PROJECT_$(IMAGE_VARIANT))

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
