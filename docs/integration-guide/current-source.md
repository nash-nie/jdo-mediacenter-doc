# 当前媒体源信息

当前媒体源信息建议由调用方自己维护连接对象，并结合 `ComponentName` / `packageName` 获取应用信息：

```kotlin
val packageName = source.packageName
val appInfo = context.packageManager.getApplicationInfo(packageName, 0)
val appLabel = context.packageManager.getApplicationLabel(appInfo)
val appIcon = context.packageManager.getApplicationIcon(appInfo)
```

## 推荐封装

```kotlin
data class MediaSourceInfo(
    val component: ComponentName,
    val label: CharSequence,
    val icon: Drawable,
)

fun resolveMediaSourceInfo(
    context: Context,
    component: ComponentName,
): MediaSourceInfo? = runCatching {
    val pm = context.packageManager
    val appInfo = pm.getApplicationInfo(component.packageName, 0)
    MediaSourceInfo(
        component = component,
        label = pm.getApplicationLabel(appInfo),
        icon = pm.getApplicationIcon(appInfo),
    )
}.getOrNull()
```

!!! tip "未安装媒体源处理"
    如果目标媒体源未安装，`getApplicationInfo` 会抛 `PackageManager.NameNotFoundException`，建议用 `runCatching` 包裹并在 UI 上做"未安装"占位。
