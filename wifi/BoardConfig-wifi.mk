#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Broadcom bcmdhd. Stock ships both bcmdhd4383.ko and bcmdhd4390.ko in vendor_dlkm;
# stock init.insmod.cubs.cfg loads bcmdhd4383.ko. Without these the tree builds
# neither wpa_supplicant nor hostapd, so there is no wifi at all.
BOARD_WLAN_DEVICE := bcmdhd
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_bcmdhd
WPA_SUPPLICANT_VERSION := VER_0_8_X
