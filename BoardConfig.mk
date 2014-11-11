#
# Copyright (C) 2011 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# These two variables are set first, so they can be overridden
# by BoardConfigVendor.mk
BOARD_USES_GENERIC_AUDIO := true
#USE_CAMERA_STUB := true
#OMAP_ENHANCEMENT := true

ifeq ($(OMAP_ENHANCEMENT),true)
COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT
# Multi-zone audio (requires ro.com.ti.omap_multizone_audio, see device.mk)
#OMAP_MULTIZONE_AUDIO := true
endif

TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := cortex-a15

BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_TI := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/ti/jacinto6evm/bluetooth
TARGET_NO_BOOTLOADER := true

BOARD_KERNEL_BASE := 0x80000000
#BOARD_KERNEL_CMDLINE := console=ttyO2,115200n8 mem=1024M androidboot.console=ttyO2 androidboot.hardware=jacinto6evmboard vram=20M omapfb.vram=0:16M
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01f00000

TARGET_NO_RADIOIMAGE := true
TARGET_BOARD_PLATFORM := jacinto6
TARGET_BOOTLOADER_BOARD_NAME := jacinto6evm

BOARD_EGL_CFG := device/ti/jacinto6evm/egl.cfg

USE_OPENGL_RENDERER := true

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 805306368
BOARD_USERDATAIMAGE_PARTITION_SIZE := 2147483648
BOARD_FLASH_BLOCK_SIZE := 4096

TARGET_RECOVERY_FSTAB = device/ti/jacinto6evm/fstab.jacinto6evmboard
TARGET_RECOVERY_PIXEL_FORMAT := "RGB565"
TARGET_RELEASETOOLS_EXTENSIONS := device/ti/jacinto6evm

# Connectivity - Wi-Fi
#USES_TI_MAC80211 := true
ifeq ($(USES_TI_MAC80211),true)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WPA_SUPPLICANT_VERSION      := VER_0_8_X_TI
BOARD_HOSTAPD_DRIVER        := NL80211
BOARD_WLAN_DEVICE           := wl12xx_mac80211
BOARD_SOFTAP_DEVICE         := wl12xx_mac80211
COMMON_GLOBAL_CFLAGS += -DUSES_TI_MAC80211
endif

ifeq ($(OMAP_MULTIZONE_AUDIO),true)
COMMON_GLOBAL_CFLAGS += -DOMAP_MULTIZONE_AUDIO
endif

#BOARD_SEPOLICY_DIRS := device/ti/jacinto6evm/sepolicy
#BOARD_SEPOLICY_UNION := \
#        healthd.te

