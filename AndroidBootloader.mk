ifeq ($(TARGET_BOOTLOADER_BUILT_FROM_SOURCE),true)

PERL = perl

# Force using bash as a shell, otherwise, on Ubuntu, dash will break some
# dependency due to its bad handling of echo \1
MAKE += SHELL=/bin/bash

BOOTLOADER_BUILD_DIR := $(ANDROID_BUILD_TOP)/$(TARGET_OUT_INTERMEDIATES)/BOOTLOADER_OBJ
BOOTLOADER_OUT_DIR ?= $(PRODUCT_OUT)/bootloader
TARGET_PREBUILT_INT_BOOTLOADER := $(BOOTLOADER_OUT_DIR)/$(TARGET_BOOTLOADER_SECONDARY_IMAGE)
TARGET_BOOTLOADER_ARCH ?= arm

ifeq ($(TARGET_BOOTLOADER_ARCH),x86_64)
BOOTLOADER_TOOLCHAIN_ARCH := $(TARGET_BOOTLOADER_ARCH)
else
BOOTLOADER_TOOLCHAIN_ARCH := i686
endif
BOOTLOADER_EXTRA_FLAGS := ANDROID_TOOLCHAIN_FLAGS="-mno-android -Werror"
#XXX ti-u-boot-2014.07 is broken for build with eabi compiler! try force gnueabi-
#BOOTLOADER_CROSS_COMP := $(notdir $(TARGET_TOOLS_PREFIX))
BOOTLOADER_CROSS_COMP := arm-linux-gnueabi-

BOOTLOADER_CCACHE :=$(firstword $(TARGET_CC))

ifeq ($(notdir $(BOOTLOADER_CCACHE)),ccache)
BOOTLOADER_CROSS_COMP := "ccache $(BOOTLOADER_CROSS_COMP)"
BOOTLOADER_PATH += :$(ANDROID_BUILD_TOP)/$(dir $(BOOTLOADER_CCACHE))
endif

#remove time_macros from ccache options, it breaks signing process
BOOTLOADER_CCSLOP := $(filter-out time_macros,$(subst $(comma), ,$(CCACHE_SLOPPINESS)))
BOOTLOADER_CCSLOP := $(subst $(space),$(comma),$(BOOTLOADER_CCSLOP))

BOOTLOADER_BLD_FLAGS := \
    ARCH=$(TARGET_BOOTLOADER_ARCH) \
    $(BOOTLOADER_EXTRA_FLAGS)

BOOTLOADER_BLD_FLAGS :=$(BOOTLOADER_BLD_FLAGS) \
     O=$(BOOTLOADER_BUILD_DIR) \

BOOTLOADER_BLD_ENV := CROSS_COMPILE=$(BOOTLOADER_CROSS_COMP) \
    PATH=$(BOOTLOADER_PATH):$(PATH) \
    CCACHE_SLOPPINESS=$(BOOTLOADER_CCSLOP)

define bootloader-make
	$(BOOTLOADER_BLD_ENV) $(MAKE) -C $(BOOTLOADER_SRC_DIR) $(BOOTLOADER_BLD_FLAGS)
endef

ifeq ($(TARGET_BOOTLOADER_DEFCONFIG_NAME),)
  $(error cannot build bootloader, TARGET_BOOTLOADER_DEFCONFIG_NAME not specified)
endif
define build-bootloader-config
	$(bootloader-make) $(TARGET_BOOTLOADER_DEFCONFIG_NAME)
endef


ifeq ($(TARGET_BOOTLOADER_PRIMARY_IMAGE),)
define move-bootloader-image-primary
endef
else
define move-bootloader-image-primary
	cp $(BOOTLOADER_BUILD_DIR)/$(TARGET_BOOTLOADER_PRIMARY_IMAGE) $(BOOTLOADER_OUT_DIR)
endef
endif

ifeq ($(TARGET_BOOTLOADER_SECONDARY_IMAGE),)
  $(error cannot build bootloader, TARGET_BOOTLOADER_SECONDARY_IMAGE not specified)
else
define move-bootloader-image-secondary
	cp $(BOOTLOADER_BUILD_DIR)/$(TARGET_BOOTLOADER_SECONDARY_IMAGE) $(BOOTLOADER_OUT_DIR)
endef
endif

$(BOOTLOADER_BUILD_DIR):
	mkdir -p $(BOOTLOADER_BUILD_DIR)

$(BOOTLOADER_OUT_DIR):
	mkdir -p $(BOOTLOADER_OUT_DIR)

$(TARGET_PREBUILT_INT_BOOTLOADER): $(BOOTLOADER_OUT_DIR) $(BOOTLOADER_BUILD_DIR)
	$(build-bootloader-config)
	$(bootloader-make)
	$(move-bootloader-image-primary)
	$(move-bootloader-image-secondary)

build_bootloader: $(TARGET_PREBUILT_INT_BOOTLOADER)

.PHONY: build_bootloader

endif #TARGET_BOOTLOADER_BUILT_FROM_SOURCE
