ifeq ($(BOARD_HAVE_WIFI_QCA6564),true)

LOCAL_PATH := $(call my-dir)
ANDROID_ROOT := $(PWD)
DRIVER_SRC_BASE := $(LOCAL_PATH)
LOCAL_PATH_BACKUP := $(ANDROID_ROOT)/$(LOCAL_PATH)

KERNEL_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/arm-linux-androideabi-

KERNEL_CROSS_COMPILE_WRAPPER := $(realpath $(CC_WRAPPER)) $(KERNEL_CROSS_COMPILE)

# Generic flags
MAKE_OPTIONS := ARCH=arm
MAKE_OPTIONS += CROSS_COMPILE="$(KERNEL_CROSS_COMPILE_WRAPPER)"
MAKE_OPTIONS += WLAN_ROOT=$(LOCAL_PATH_BACKUP)
MAKE_OPTIONS += MODNAME=wlan
MAKE_OPTIONS += WLAN_OPEN_SOURCE=1
MAKE_OPTIONS += CONFIG_QCA_WIFI_ISOC=0
MAKE_OPTIONS += CONFIG_QCA_WIFI_2_0=1
MAKE_OPTIONS += CONFIG_QCA_CLD_WLAN=m
MAKE_OPTIONS += CONFIG_ARCH_MSM=n
MAKE_OPTIONS += CONFIG_ARCH_QCOM=n
MAKE_OPTIONS += CONFIG_NON_QC_PLATFORM=y
MAKE_OPTIONS += CONFIG_LINUX_QCMBR=y
MAKE_OPTIONS += BUILD_DEBUG_VERSION=0

# Custom flags to compile SDIO version
MAKE_OPTIONS += CONFIG_ROME_IF=sdio
MAKE_OPTIONS += CONFIG_CLD_HL_SDIO_CORE=y

KERNEL_SRC := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ

QCACLD_INTERMEDIATES := $(TARGET_OUT_INTERMEDIATES)/$(LOCAL_MODULE_CLASS)/$(LOCAL_MODULE)_intermediates

# Override the default build target in order to issue our own custom command.
# Note that the module name is wlan.ko by default, we then change it to
# qca6564_wlan.ko in order to be more explicit.
$(DRIVER_SRC_BASE)/wlan.ko: $(mod_cleanup) bootimage | $(ACP)
	$(MAKE) -C $(KERNEL_SRC) M=$(LOCAL_PATH_BACKUP) $(MAKE_OPTIONS) modules
	$(hide) $(KERNEL_CROSS_COMPILE_WRAPPER)strip --strip-debug $(LOCAL_PATH_BACKUP)/wlan.ko
	$(hide) mkdir -p $(QCACLD_INTERMEDIATES)
	$(hide) $(ACP) $(LOCAL_PATH_BACKUP)/wlan.ko $(QCACLD_INTERMEDIATES)/qca6564_wlan.ko

mod_cleanup := $(ANDROID_ROOT)/$(DRIVER_SRC_BASE)/dummy

$(mod_cleanup):
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean

qca6564_clean: $(mod_cleanup)

# wlan.ko
include $(CLEAR_VARS)
LOCAL_MODULE       := qca6564_wlan.ko
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR)/lib/modules/
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_TAGS  := optional
LOCAL_SRC_FILES := wlan.ko
include $(BUILD_PREBUILT)

# firmware_bin/WCNSS_cfg.dat
include $(CLEAR_VARS)
LOCAL_MODULE := WCNSS_cfg
LOCAL_MODULE_STEM := cfg.dat
LOCAL_MODULE_TAGS := debug eng optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/firmware/wlan
LOCAL_SRC_FILES := firmware_bin/WCNSS_cfg.dat
ALL_DEFAULT_INSTALLED_MODULES += $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

# firmware_bin/WCNSS_qcom_cfg.ini
include $(CLEAR_VARS)
LOCAL_MODULE := WCNSS_qcom_cfg
LOCAL_MODULE_STEM := qcom_cfg.ini
LOCAL_MODULE_TAGS := debug eng optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/firmware/wlan
LOCAL_SRC_FILES := firmware_bin/WCNSS_qcom_cfg.ini
ALL_DEFAULT_INSTALLED_MODULES += $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

endif
