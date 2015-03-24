ifeq ($(TARGET_KERNEL_BUILT_FROM_SOURCE),true)

PERL = perl

# Force using bash as a shell, otherwise, on Ubuntu, dash will break some
# dependency due to its bad handling of echo \1
MAKE += SHELL=/bin/bash

KERNEL_BUILD_DIR := $(ANDROID_BUILD_TOP)/$(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_OUT_DIR ?= $(PRODUCT_OUT)/linux
KERNEL_CONFIG := $(KERNEL_OUT_DIR)/.config
TARGET_PREBUILT_INT_KERNEL := $(KERNEL_OUT_DIR)/zImage
KERNEL_HEADERS_INSTALL := $(KERNEL_OUT_DIR)/usr
KERNEL_MODULES_INSTALL := $(ANDROID_BUILD_TOP)/$(PRODUCT_OUT)/system/
TARGET_KERNEL_ARCH ?= arm

ifeq ($(TARGET_KERNEL_ARCH),x86_64)
KERNEL_TOOLCHAIN_ARCH := $(TARGET_KERNEL_ARCH)
else
KERNEL_TOOLCHAIN_ARCH := i686
endif
KERNEL_EXTRA_FLAGS := ANDROID_TOOLCHAIN_FLAGS="-mno-android -Werror"
KERNEL_CROSS_COMP := $(notdir $(TARGET_TOOLS_PREFIX))
KERNEL_CCACHE :=$(firstword $(TARGET_CC))

ifeq ($(notdir $(KERNEL_CCACHE)),ccache)
KERNEL_CROSS_COMP := "ccache $(KERNEL_CROSS_COMP)"
KERNEL_PATH += :$(ANDROID_BUILD_TOP)/$(dir $(KERNEL_CCACHE))
endif

#remove time_macros from ccache options, it breaks signing process
KERNEL_CCSLOP := $(filter-out time_macros,$(subst $(comma), ,$(CCACHE_SLOPPINESS)))
KERNEL_CCSLOP := $(subst $(space),$(comma),$(KERNEL_CCSLOP))

KERNEL_BLD_FLAGS := \
    ARCH=$(TARGET_KERNEL_ARCH) \
    $(KERNEL_EXTRA_FLAGS)

KERNEL_BLD_FLAGS :=$(KERNEL_BLD_FLAGS) \
     O=$(KERNEL_BUILD_DIR) \

KERNEL_BLD_ENV := CROSS_COMPILE=$(KERNEL_CROSS_COMP) \
    PATH=$(KERNEL_PATH):$(PATH) \
    CCACHE_SLOPPINESS=$(KERNEL_CCSLOP)

define kernel-make
	$(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS)
endef


ifeq ($(TARGET_KERNEL_DTS_NAME),)
  $(error cannot build kernel, TARGET_KERNEL_DTS_NAME not specified)
endif

DTS_FILES = $(wildcard $(KERNEL_SRC_DIR)/arch/arm/boot/dts/$(TARGET_DTS_NAME)*.dts)
DTS_FILE = $(lastword $(subst /, ,$(1)))
DTB_FILE = $(addprefix $(KERNEL_OUT_DIR)/arch/arm/boot/,$(patsubst %.dts,%.dtb,$(call DTS_FILE,$(1))))
ZIMG_FILE = $(addprefix $(KERNEL_OUT_DIR)/arch/arm/boot/,$(patsubst %.dts,%-zImage,$(call DTS_FILE,$(1))))
KERNEL_ZIMG = $(KERNEL_OUT_DIR)/arch/arm/boot/zImage
DTC = $(KERNEL_OUT_DIR)/scripts/dtc/dtc
MERGE_CONFIG = scripts/kconfig/merge_config.sh

ifeq ($(TARGET_KERNEL_DEFCONFIG_NAME),)
  $(error cannot build kernel, TARGET_KERNEL_DEFCONFIG_NAME not specified)
endif

ifeq ($(TARGET_KERNEL_CONFIG_FRAGMENTS),)

define build-config
	$(kernel-make) $(TARGET_KERNEL_DEFCONFIG_NAME)
endef

else

define build-config
	cd $(KERNEL_SRC_DIR) &&\
	 ARCH=$(TARGET_KERNEL_ARCH) $(MERGE_CONFIG)  arch/$(TARGET_KERNEL_ARCH)/configs/$(TARGET_KERNEL_DEFCONFIG_NAME) $(TARGET_KERNEL_CONFIG_FRAGMENTS) &&\
	 cd $(ANDROID_BUILD_TOP) &&\
	 mv $(KERNEL_SRC_DIR)/.config $(KERNEL_BUILD_DIR) &&\
	 $(MAKE) ARCH=$(TARGET_KERNEL_ARCH) -C $(KERNEL_SRC_DIR) mrproper
endef

endif

ifeq ($(TARGET_KERNEL_COMMAND_LINE),)
define modify-config
endef

else
define modify-config
	cat $(KERNEL_BUILD_DIR)/.config|grep -vw CONFIG_CMDLINE>$(KERNEL_BUILD_DIR)/.config.mod &&\
	echo "CONFIG_CMDLINE=\"$(TARGET_KERNEL_COMMAND_LINE)\"">>$(KERNEL_BUILD_DIR)/.config.mod &&\
	mv -f $(KERNEL_BUILD_DIR)/.config.mod $(KERNEL_BUILD_DIR)/.config
endef

endif

define move-images
	cp $(KERNEL_BUILD_DIR)/arch/$(TARGET_KERNEL_ARCH)/boot/zImage $(TARGET_PREBUILT_INT_KERNEL) &&\
	cp $(KERNEL_BUILD_DIR)/arch/$(TARGET_KERNEL_ARCH)/boot/dts/$(TARGET_KERNEL_DTS_NAME)*.dtb $(KERNEL_OUT_DIR)
endef

ifeq ($(TARGET_SGX_DDK_DRV_SRC_DIR),)
define build-sgx-images
endef
define move-sgx-images
endef
else

define build-sgx-images
OUT=$(KERNEL_BUILD_DIR) KERNEL_CROSS_COMPILE=$(KERNEL_CROSS_COMP) $(KERNEL_BLD_ENV) KERNELDIR="$(KERNEL_BUILD_DIR)" $(MAKE) -C $(TARGET_SGX_DDK_DRV_SRC_DIR) $(TARGET_SGX_DDK_DRV_FLAGS)
endef

define move-sgx-images
mv $(KERNEL_BUILD_DIR)/$(TARGET_SGX_DDK_DRV_BINARY_PATH) $(KERNEL_MODULES_INSTALL)/lib/modules/
endef

endif

sgx: build_kernel
	$(build-sgx-images)
	$(move-sgx-images)

$(KERNEL_BUILD_DIR):
	mkdir -p $(KERNEL_BUILD_DIR)

$(KERNEL_OUT_DIR):
	mkdir -p $(KERNEL_OUT_DIR)

$(KERNEL_MODULES_INSTALL):
	mkdir -p $(KERNEL_MODULES_INSTALL)

$(KERNEL_CONFIG): $(KERNEL_BUILD_DIR)
	$(build-config)
	$(modify-config)


$(TARGET_PREBUILT_INT_KERNEL): $(KERNEL_MODULES_INSTALL) $(KERNEL_OUT_DIR) $(KERNEL_CONFIG) $(KERNEL_HEADERS_INSTALL)
	$(kernel-make) zImage modules dtbs
	$(kernel-make) INSTALL_MOD_PATH=$(KERNEL_MODULES_INSTALL) INSTALL_MOD_STRIP=1 modules_install
	rm -vf $(KERNEL_MODULES_INSTALL)/lib/modules/*/build $(KERNEL_MODULES_INSTALL)/lib/modules/*/source
	$(move-images)

$(KERNEL_HEADERS_INSTALL): $(KERNEL_OUT_DIR) $(KERNEL_CONFIG)
	$(kernel-make) headers_install


build_kernel: $(TARGET_PREBUILT_INT_KERNEL)

.PHONY: build_kernel sgx

endif #TARGET_KERNEL_BUILT_FROM_SOURCE
