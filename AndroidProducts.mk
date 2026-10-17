# SPDX-License-Identifier: Apache-2.0

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/aosp_cubs.mk \
    $(LOCAL_DIR)/lineage_cubs.mk

COMMON_LUNCH_CHOICES := \
    aosp_cubs-user \
    aosp_cubs-userdebug \
    aosp_cubs-eng \
    lineage_cubs-user \
    lineage_cubs-userdebug \
    lineage_cubs-eng
