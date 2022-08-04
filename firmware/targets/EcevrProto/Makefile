
# Define target output
target: yaml-link prom bin

# Define Firmware Version Number
export PRJ_VERSION = 0x00000002

export GEN_BIN_IMAGE = 1

# Define target part
export PRJ_PART = XC7A35TCSG325-2
#export PRJ_PART = XC7Z015CLG485-2
#export PRJ_PART = XC7Z030SBG485-1
#export PRJ_PART = XC7Z012SCLG485-1

PRJ_FAMILY = $(shell echo "$(PRJ_PART)" | sed -e 's/\(XC7Z\)\([0-9]\+\).*/7z\2/' -e 's/\(XC7A\)\([0-9]\+\).*/7a\2/')

# Define the Microblaze source path
#export SDK_SRC_PATH = $(PROJ_DIR)/../../../common/core/src
export TOP_DIR=$(abspath $(PWD)/../..)

export REMOVE_UNUSED_CODE = 1

# Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
