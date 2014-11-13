# Copyright (C) 2011 The Android Open Source Project
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
# This file is the build configuration for a full Android
# build for toro hardware. This cleanly combines a set of
# device-specific aspects (drivers) with a device-agnostic
# product configuration (apps). Except for a few implementation
# details, it only fundamentally contains two inherit-product
# lines, full and toro, hence its name.
#

PRODUCT_COPY_FILES := \
	 frameworks/av/media/libeffects/data/audio_effects.conf:system/etc/audio_effects.conf  \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	device/ti/beaglex15/720p_touchscreen.idc:system/usr/idc/720p_touchscreen.idc

# Inherit from those products. Most specific first.
$(call inherit-product, device/ti/beaglex15/device.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_NAME := full_beaglex15
PRODUCT_DEVICE := beaglex15
PRODUCT_BRAND := Android
PRODUCT_MODEL := beaglex15
PRODUCT_MANUFACTURER := BeagleBoard_Org
