# 依赖配置

## Gradle 依赖

```kotlin
implementation("androidx.media3:media3-common:<version>")
implementation("androidx.media3:media3-session:<version>")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-guava:<version>")
```

媒体中心当前内部使用版本：

| 依赖 | 版本 |
| --- | --- |
| Media3 | 1.8.0 |
| kotlinx-coroutines-guava | 与 kotlinx-coroutines 主版本一致 |

## AndroidManifest 包可见性

Android 11（API 30）及以上系统对包可见性做了限制。建议在 `AndroidManifest.xml` 中补充 `<queries>` 声明，否则 `SessionToken` 与 `MediaBrowser.Builder` 都拿不到目标服务。

```xml
<queries>
    <intent>
        <action android:name="androidx.media3.session.MediaSessionService" />
    </intent>
    <intent>
        <action android:name="androidx.media3.session.MediaLibraryService" />
    </intent>
    <intent>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent>

    <package android:name="com.jidouauto.netease.jdo" />
    <package android:name="com.jidouauto.iqiyi.jdo" />
    <package android:name="com.jidouauto.radiobrowser.jdo" />
    <package android:name="com.jidouauto.spotify" />
    <package android:name="com.jidouauto.shortplay.jdo" />
</queries>
```

!!! warning "易踩坑点"
    - 仅声明 `<intent>` 而不声明 `<package>`，部分 ROM 仍然查不到 `Service`
    - 仅声明 `<package>` 而不声明 `<intent>`，会拿不到 `MediaSessionService` / `MediaLibraryService` 列表
    - 推荐两者都加
