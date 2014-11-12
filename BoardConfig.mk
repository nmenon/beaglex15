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

TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := cortex-a15

TARGET_NO_BOOTLOADER := true

BOARD_KERNEL_BASE := 0x80000000
#BOARD_KERNEL_CMDLINE := console=ttyO2,115200n8 mem=1024M androidboot.console=ttyO2 androidboot.hardware=beaglex15board vram=20M omapfb.vram=0:16M
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01f00000

TARGET_NO_RADIOIMAGE := true
TARGET_BOARD_PLATFORM := jacinto6
TARGET_BOOTLOADER_BOARD_NAME := beaglex15

BOARD_EGL_CFG := device/ti/beaglex15/egl.cfg

USE_OPENGL_RENDERER := true

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 805306368
BOARD_USERDATAIMAGE_PARTITION_SIZE := 2147483648
BOARD_FLASH_BLOCK_SIZE := 4096

TARGET_RECOVERY_FSTAB = device/ti/beaglex15/fstab.beaglex15board
TARGET_RECOVERY_PIXEL_FORMAT := "RGB565"
TARGET_RELEASETOOLS_EXTENSIONS := device/ti/beaglex15


