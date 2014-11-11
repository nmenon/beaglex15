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

ifeq ($(TARGET_PREBUILT_KERNEL),)
LOCAL_KERNEL := device/ti/beaglex15/kernel
else
LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_COPY_FILES := \
	$(LOCAL_KERNEL):kernel \
	device/ti/beaglex15/tablet_core_hardware_beaglex15.xml:system/etc/permissions/tablet_core_hardware_beaglex15.xml \
	device/ti/beaglex15/init.beaglex15board.rc:root/init.beaglex15board.rc \
	device/ti/beaglex15/init.beaglex15board.usb.rc:root/init.beaglex15board.usb.rc \
	device/ti/beaglex15/ueventd.beaglex15board.rc:root/ueventd.beaglex15board.rc \
	device/ti/beaglex15/fstab.beaglex15board:root/fstab.beaglex15board \
	device/ti/beaglex15/media_profiles.xml:system/etc/media_profiles.xml \
	device/ti/beaglex15/media_codecs.xml:system/etc/media_codecs.xml \
	device/ti/beaglex15/bootanimation.zip:/system/media/bootanimation.zip \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	device/ti/beaglex15/Atmel_maXTouch_Touchscreen.idc:system/usr/idc/Atmel_maXTouch_Touchscreen.idc \
	device/ti/beaglex15/LDC_3001_TouchScreen_Controller.idc:system/usr/idc/LDC_3001_TouchScreen_Controller.idc \

# These are the hardware-specific features
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \

PRODUCT_PACKAGES := \
	e2fsck

PRODUCT_PROPERTY_OVERRIDES := \
	hwui.render_dirty_regions=false

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	persist.sys.usb.config=mtp

PRODUCT_PROPERTY_OVERRIDES += \
	ro.opengles.version=131072

PRODUCT_CHARACTERISTICS := tablet,nosdcard

DEVICE_PACKAGE_OVERLAYS := \
	device/ti/beaglex15/overlay

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PACKAGES += \
	com.android.future.usb.accessory

PRODUCT_PROPERTY_OVERRIDES += \
	ro.sf.lcd_density=160

# WI-Fi
PRODUCT_PACKAGES += \
	hostapd.conf \
	wifical.sh \
	TQS_D_1.7.ini \
	TQS_D_1.7_127x.ini \
	crda \
	regulatory.bin \
	wlconf

PRODUCT_PACKAGES += \
	LegacyCamera \
	camera_test \
	ion_tiler_test \
	iontest \
	ion_ti_test2 \
	vpetest

# Audio HAL modules
PRODUCT_PACKAGES += audio.primary.jacinto6
PRODUCT_PACKAGES += audio.hdmi.jacinto6
# BlueDroid a2dp Audio HAL module
PRODUCT_PACKAGES += audio.a2dp.default
# Remote submix
PRODUCT_PACKAGES += audio.r_submix.default

# Audio policy
PRODUCT_PACKAGES += audio_policy.jacinto6

PRODUCT_PACKAGES += \
	audio_policy.conf \
	mixer_paths.xml

PRODUCT_PACKAGES += \
	tinymix \
	tinyplay \
	tinycap

# Radio
PRODUCT_PACKAGES += \
	HelloRadio \
	lad_dra7xx \
	libtiipc \
	libtiipcutils

# Can utilities
PRODUCT_PACKAGES += \
	libcan \
	bcmserver \
	canbusload \
	can-calc-bit-timing \
	candump \
	canfdtest \
	cangen \
	cangw \
	canlogserver \
	canplayer \
	cansend \
	cansniffer \
	isotpdump \
	isotprecv \
	isotpsend \
	isotpserver \
	isotpsniffer.c \
	isotptun \
	log2asc \
	log2long \
	slcan_attach \
	slcand \
	slcanpty \

# Enable AAC 5.1 decode (decoder)
PRODUCT_PROPERTY_OVERRIDES += \
	media.aac_51_output_enabled=true

# Multi-zone audio (requires OMAP_MULTIZONE_AUDIO, see BoardConfig.mk)
PRODUCT_PROPERTY_OVERRIDES += \
	ro.com.ti.omap_multizone_audio=true

$(call inherit-product, frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk)
$(call inherit-product-if-exists, hardware/ti/omap4xxx/jacinto6.mk)
$(call inherit-product-if-exists, hardware/ti/wpan/ti-wpan-products.mk)
$(call inherit-product-if-exists, device/ti/proprietary-open/jacinto6/ti-jacinto6-vendor.mk)
$(call inherit-product-if-exists, device/ti/proprietary-open/jacinto6/ducati-full_beaglex15.mk)
$(call inherit-product-if-exists, device/ti/proprietary-open/wl12xx/wlan/wl12xx-wlan-fw-products.mk)
$(call inherit-product-if-exists, device/ti/proprietary-open/wl12xx/wpan/wl12xx-wpan-fw-products.mk)
