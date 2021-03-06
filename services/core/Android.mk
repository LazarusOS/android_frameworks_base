LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := services.core

LOCAL_AIDL_INCLUDES := system/netd/server/binder

LOCAL_SRC_FILES += \
    $(call all-java-files-under,java) \
    $(call all-proto-files-under, proto) \
    java/com/android/server/EventLogTags.logtags \
    java/com/android/server/am/EventLogTags.logtags \
    ../../../../system/netd/server/binder/android/net/INetd.aidl \
    ../../../../system/netd/server/binder/android/net/metrics/INetdEventListener.aidl \

ifeq ($(BOARD_HAVE_NUBIA_GOODIX_FP_V1),)
LOCAL_SRC_FILES += \
    $(call all-java-files-under,ext)
endif

LOCAL_AIDL_INCLUDES += \
    system/netd/server/binder

LOCAL_JAVA_LIBRARIES := services.net telephony-common
LOCAL_STATIC_JAVA_LIBRARIES := tzdata_update
LOCAL_PROTOC_OPTIMIZE_TYPE := nano

LOCAL_JAVA_LIBRARIES += org.mokee.platform.internal

ifneq ($(INCREMENTAL_BUILDS),)
    LOCAL_PROGUARD_ENABLED := disabled
    LOCAL_JACK_ENABLED := incremental
endif

LOCAL_JACK_FLAGS := \
 -D jack.transformations.boost-locked-region-priority=true \
 -D jack.transformations.boost-locked-region-priority.classname=com.android.server.am.ActivityManagerService \
 -D jack.transformations.boost-locked-region-priority.request=com.android.server.am.ActivityManagerService\#boostPriorityForLockedSection \
 -D jack.transformations.boost-locked-region-priority.reset=com.android.server.am.ActivityManagerService\#resetPriorityAfterLockedSection

LOCAL_JAR_PROCESSOR := lockedregioncodeinjection
# Use = instead of := to delay evaluation of ${in} and ${out}
LOCAL_JAR_PROCESSOR_ARGS = \
 --targets \
  "Lcom/android/server/am/ActivityManagerService;,Lcom/android/server/wm/WindowHashMap;" \
 --pre \
  "com/android/server/am/ActivityManagerService.boostPriorityForLockedSection,com/android/server/wm/WindowManagerService.boostPriorityForLockedSection" \
 --post \
  "com/android/server/am/ActivityManagerService.resetPriorityAfterLockedSection,com/android/server/wm/WindowManagerService.resetPriorityAfterLockedSection" \
 -o ${out} \
 -i ${in}

include $(BUILD_STATIC_JAVA_LIBRARY)
