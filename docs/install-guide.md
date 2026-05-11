# JDO Media Center 环境部署

## 前提条件

- 设备已连接并开启 ADB 调试
- 设备支持 `adb root` 和 `adb remount`
- 已准备好以下文件：
  - `jdo_mediacenter_*.apk`
  - `com.jidouauto.mediacenter.xml`

- `com.jidouauto.mediacenter.xml` 配置参考（查权限是否为 `signature|privileged`）：

```text
https://cs.android.com/android/platform/superproject/+/android-latest-release:frameworks/base/core/res/AndroidManifest.xml
```

## 权限文件

媒体中心对应的权限文件为项目根目录下的 `com.jidouauto.mediacenter.xml`。
推送到设备时需要放到 `/system/etc/permissions/`。

文件内容参考：

```xml
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.jidouauto.mediacenter">
        <permission name="com.jidouauto.theme.center.permission.READ"/>
        <permission name="com.jidouauto.mediacenter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"/>
        <permission name="android.permission.MEDIA_CONTENT_CONTROL"/>
        <permission name="android.permission.RECORD_AUDIO"/>
        <permission name="android.permission.INTERACT_ACROSS_USERS"/>
        <permission name="android.permission.INTERACT_ACROSS_USERS_FULL"/>
    </privapp-permissions>
</permissions>
```

关键点：
- `privapp-permissions package` 必须与 APK 包名一致：`com.jidouauto.mediacenter`
- XML 文件必须随 APK 一起推送，否则系统重启后不会给特权权限授权
- 如果后续 Manifest 新增 `signature|privileged` 权限，需要同步补充到这个 XML

## APK 构建

在项目根目录执行：

```bash
./gradlew :app:assembleJdoDebug
```

构建产物路径参考：

```text
app/build/outputs/apk/jdo/debug/jdo_mediacenter_<version>_debug_<yyyyMMdd-HHmm>.apk
```

如需 release 包：

```bash
./gradlew :app:assembleJdoRelease
```

## 安装步骤

以下命令假设当前目录下只有一个待安装的媒体中心 APK。若有多个 APK，请手动指定：

```bash
APK=app/build/outputs/apk/jdo/debug/jdo_mediacenter_26.171_debug_20260423-1830.apk
```

或在 APK 所在目录自动取第一个：

```bash
APK="$(ls jdo_mediacenter_*.apk | head -n 1)"
```

### 1. 进入可写模式

```bash
adb root
adb remount
```

### 2. 清理旧文件

```bash
adb shell rm -rf /system/priv-app/jdoMediaCenter
adb shell rm -rf /system/priv-app/jdo_mediacenter
adb shell rm -rf /system/priv-app/jdoMediaCenterApp
```

### 3. 创建目标目录

```bash
adb shell mkdir -p /system/priv-app/jdoMediaCenter
```

### 4. 安装应用

```bash
adb install -r -t -d -g "${APK}"
```

### 5. 推送文件

```bash
# 推送权限配置文件
adb push com.jidouauto.mediacenter.xml /system/etc/permissions/

# 推送 APK 到系统分区
adb push "${APK}" /system/priv-app/jdoMediaCenter/jdoMediaCenter.apk
```

### 6. 重启设备

```bash
adb reboot
```

### 7. 重启后再次安装

```bash
# 等待设备启动完成
adb wait-for-device root
adb remount

# 再次安装确保生效
adb install -r -t -d -g "${APK}"
```

## 一键安装脚本

将以下内容保存为 `install.sh`，放在 APK 与 `com.jidouauto.mediacenter.xml` 同目录下执行。
默认会安装当前目录下第一个 `jdo_mediacenter_*.apk`，也可以显式传入 APK 路径：

```bash
./install.sh app/build/outputs/apk/jdo/debug/jdo_mediacenter_26.171_debug_20260423-1830.apk
```

脚本内容：

```bash
#!/bin/bash
set -e

APK="${1:-$(ls jdo_mediacenter_*.apk | head -n 1)}"
PERMISSION_XML="com.jidouauto.mediacenter.xml"
PRIV_APP_DIR="/system/priv-app/jdoMediaCenter"
PRIV_APP_APK="${PRIV_APP_DIR}/jdoMediaCenter.apk"

if [ -z "${APK}" ] || [ ! -f "${APK}" ]; then
  echo "未找到 APK，请将 jdo_mediacenter_*.apk 放到当前目录，或通过参数传入 APK 路径"
  exit 1
fi

if [ ! -f "${PERMISSION_XML}" ]; then
  echo "未找到 ${PERMISSION_XML}"
  exit 1
fi

echo "===> 使用 APK: ${APK}"

echo "===> adb root"
adb root
echo "===> adb remount"
adb remount

echo "===> 删除旧文件..."
adb shell rm -rf /system/priv-app/jdoMediaCenter
adb shell rm -rf /system/priv-app/jdo_mediacenter
adb shell rm -rf /system/priv-app/jdoMediaCenterApp

echo "===> 创建目标目录..."
adb shell mkdir -p "${PRIV_APP_DIR}"

echo "===> 安装应用..."
sleep 2
adb install -r -t -d -g "${APK}"

echo "===> 推送文件..."
adb push "${PERMISSION_XML}" /system/etc/permissions/
adb push "${APK}" "${PRIV_APP_APK}"

echo "===> 重启设备..."
adb reboot

echo "===> 等待设备重启..."
adb wait-for-device root
adb remount
sleep 3
adb install -r -t -d -g "${APK}"

echo "===> 安装完成!"
```

## 注意事项

> [!IMPORTANT]
> - `jdo` flavor 使用 AOSP 平台签名配置
> - Manifest 使用 `android:sharedUserId="com.jidouauto"`，需要与系统侧签名/共享 UID 策略匹配
> - 设备需要支持 `adb root` 和 `adb remount`
> - `com.jidouauto.mediacenter.xml` 需要推送到 `/system/etc/permissions/`
> - APK 需要推送到 `/system/priv-app/jdoMediaCenter/`
> - 确保本地 APK 文件名与脚本匹配，或执行脚本时显式传入 APK 路径

## 说明：privapp-permissions 配置思路（给新人看的）

`com.jidouauto.mediacenter.xml` 的作用是给 **系统/特权应用** 授权
`signature|privileged` 级别的受保护权限。只有满足以下条件，权限才会生效：

1. APK 安装在系统分区的 `priv-app` 目录下
2. 对应权限在 `privapp-permissions` 白名单里
3. APK 包名与 XML 中的 package 一致：`com.jidouauto.mediacenter`

### 1. 为什么要参考 AOSP 的 AndroidManifest.xml

AOSP 在 `frameworks/base/core/res/AndroidManifest.xml` 里定义了
每个系统权限的 `protectionLevel`（例如 `signature|privileged`）。
新人常见问题是“某个权限为什么必须写进 privapp XML”，判断依据就是这个文件。

简单判断方法：
- 如果权限的 `protectionLevel` 里包含 `privileged`，就需要进入 `privapp-permissions` 白名单
- 如果只是 `dangerous` 或 `normal`，一般不需要写进 `privapp` 白名单

### 2. 本项目 privapp 白名单配置了哪些权限

以下权限已经在 `com.jidouauto.mediacenter.xml` 中配置：

- `android.permission.MEDIA_CONTENT_CONTROL`
- `android.permission.INTERACT_ACROSS_USERS`
- `android.permission.INTERACT_ACROSS_USERS_FULL`
- `android.permission.RECORD_AUDIO`
- `com.jidouauto.theme.center.permission.READ`
- `com.jidouauto.mediacenter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

其中：
- `MEDIA_CONTENT_CONTROL` 是 AOSP 受保护权限，用于媒体控制、媒体源发现和车机媒体模板相关能力
- `INTERACT_ACROSS_USERS` / `INTERACT_ACROSS_USERS_FULL` 是 AOSP 受保护权限，用于跨用户场景
- `RECORD_AUDIO` 是运行时危险权限，用于媒体中心内语音/Agent 相关能力；严格来说不是 `privileged` 权限，但当前 XML 中保留了该项
- `com.jidouauto.theme.center.permission.READ` 是主题中心读取权限
- `com.jidouauto.mediacenter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` 是应用自身动态广播保护权限

### 3. 哪些权限不需要按 privapp 白名单处理

下面这些权限虽然在 Manifest 中声明或由依赖合并进 Manifest，但不是典型的
`privileged` 权限，不需要按 `privapp` 白名单方式处理：

- `android.permission.INTERNET`
- `android.permission.RECORD_AUDIO`

### 4. 不推到系统路径会有什么后果

如果 APK 不是 `priv-app`，或者 `privapp-permissions` 没放在系统分区：

- `signature|privileged` 权限不会被授予
- 媒体控制、跨用户访问、部分媒体源调度能力可能失败
- 某些系统版本会直接抛 `SecurityException`

### 5. 不同系统版本的差异

- Android 8/9 之后开始严格校验 `privapp-permissions`
- Android 10+ 对分区（`system` / `product` / `vendor`）有匹配要求
- 新版本会新增权限或加严后台限制，建议按目标系统版本校验白名单

## 安装后验证

### 1. 确认包已安装

```bash
adb shell pm list packages | grep com.jidouauto.mediacenter
```

### 2. 确认系统分区文件存在

```bash
adb shell ls -l /system/priv-app/jdoMediaCenter/
adb shell ls -l /system/etc/permissions/com.jidouauto.mediacenter.xml
```

### 3. 查看授权状态

```bash
adb shell dumpsys package com.jidouauto.mediacenter | grep -E "MEDIA_CONTENT_CONTROL|INTERACT_ACROSS_USERS|RECORD_AUDIO"
```

### 4. 启动媒体中心

```bash
adb shell monkey -p com.jidouauto.mediacenter 1
```
