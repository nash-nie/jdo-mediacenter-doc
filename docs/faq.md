# 常见问题（FAQ）

## 连接相关

### Q1：`MediaBrowser.Builder(...).buildAsync()` 一直拿不到结果

可能原因：

1. **未声明 `<queries>`**：Android 11+ 对包可见性做了限制，未声明会拿不到目标 `Service`
2. **目标媒体源未安装**：先用 `packageManager.getPackageInfo` 校验
3. **Service Class 名错误**：必须与 [API 清单](api-reference.md#媒体源-componentname) 一致
4. **签名/权限问题**：部分能力依赖 `MEDIA_CONTENT_CONTROL` 等特权权限

排查步骤：

```kotlin
val pm = context.packageManager
val resolveInfo = pm.queryIntentServices(
    Intent("androidx.media3.session.MediaSessionService").apply {
        setPackage("com.jidouauto.netease.jdo")
    },
    0,
)
// resolveInfo 为空说明可见性或安装有问题
```

### Q2：`SessionToken(context, source)` 抛 IllegalArgumentException

通常是 `ComponentName` 的 service class 写错。请直接复用 [API 清单](api-reference.md#媒体源-componentname) 中的字符串。

### Q3：连接成功后过段时间断开

`MediaBrowser` 连接由 binder 管理，宿主 `Service` 被系统回收时连接会断开。建议：

- 在前台 / 业务页面活跃期间维持连接
- 监听 `MediaBrowser.Listener.onDisconnected` 后做有限次重连
- 退出业务时显式 `release`

## 浏览与搜索

### Q4：`getChildren` 返回为空

可能原因：

1. `parentId` 不正确（建议先取 `getLibraryRoot`，再以 `rootItem.mediaId` 作为 parentId）
2. 该节点 `isBrowsable == false`
3. 当前媒体源还未登录或本地缓存未就绪

### Q5：搜索结果一级节点不可播放

部分媒体源（网易云、爱奇艺）的搜索结果是分组节点（`searchsong` / `videos`）。需要按 [搜索 § 提取分组 children](integration-guide/search.md#提取分组-children) 取出真正可播放的 `MediaItem`。

### Q6：搜索热词为空

不是所有媒体源都支持热词。RadioBrowser 与 Spotify 暂未支持，调用 `getChildren("MEDIA_ID_MEDIA_CENTER_SEARCH_HOT_WORDS", ...)` 会返回空列表。

## 播放相关

### Q7：调用 `play()` 没有反应

排查清单：

1. 是否调用过 `prepare()`
2. `setMediaItem` / `setMediaItems` 的 `MediaItem.mediaId` 是否合法
3. Spotify 必须用自定义 command，详见 [Spotify 兼容](integration-guide/spotify.md)
4. 当前账号未登录或会话过期

### Q8：怎样按 mediaId 直接起播

```kotlin
val item = browser.getItem(mediaId).await().value ?: return
browser.setMediaItem(item)
browser.prepare()
browser.play()
```

不要用裸 `mediaId` 自己拼一个 `MediaItem`，会丢失 `mediaMetadata.extras` 中的业务字段。

### Q9：上一首 / 下一首没有效果

`setMediaItem` 单条装载时没有上一首 / 下一首。需要使用 `setMediaItems` 装载列表。

### Q10：`browser.duration` 始终为 0

按 [duration 取值顺序](integration-guide/playback-state.md#duration-取值顺序) 兜底：

1. `contentDuration`
2. `mediaMetadata.durationMs`
3. `mediaMetadata.extras[METADATA_KEY_DURATION]`

## 收藏

### Q11：`setRating` 返回失败但调用没异常

媒体源会通过 `SessionResult.extras` 中的 `requireLogin` 字段提示需要登录。建议按 [收藏管理 § 完整示例](integration-guide/favorite.md#完整示例) 处理。

## 歌词

### Q12：`music_lyric` 为空

可能原因：

1. 当前歌曲没有歌词数据
2. 当前媒体源不支持该 `CUSTOM_ACTION`（例如 RadioBrowser、Spotify）
3. 传入的 `metadata.toBundle()` 缺少 `mediaId`

排查时先调用 `isSessionCommandAvailable` 判断能力可见性。详见 [歌词对接](lyric-guide.md)。

### Q13：逐字歌词解析失败

参考 [歌词对接 § 兼容外层 lrcContent 包装](lyric-guide.md#8-兼容外层-lrccontent-包装边缘场景)，先解包再按数组解析。

### Q14：怎么判断"逐字" vs "逐句"歌词

```kotlin
fun detectLyricFormat(raw: String): String = when {
    raw.trim().startsWith("[") && raw.contains("\"words\"") -> "WORD_BY_WORD_JSON"
    raw.lines().any { it.trimStart().startsWith("[") && it.contains("]") } -> "LRC"
    else -> "UNKNOWN"
}
```

## 频谱 / audioSessionId

### Q15a：`fetchAudioSessionId` 返回 0

可能原因：

1. 播放器尚未进入 `Player.STATE_READY`（请在 `onIsPlayingChanged(true)` 后再请求）
2. 当前媒体源不支持 `CUSTOM_ACTION_GET_AUDIO_SESSION_ID`（仅网易云音乐源支持）
3. 切源 / 异常恢复后旧 `audioSessionId` 失效，需要重新请求

详见 [音频频谱接入 § 生命周期建议](audio-spectrum.md#7-生命周期建议)。

### Q15b：`Visualizer` 初始化抛异常

通常是：

- 未授予 `RECORD_AUDIO` 运行时权限
- `audioSessionId` 无效（小于等于 0）
- 系统策略限制（部分车机厂商屏蔽了应用层 `Visualizer`）
- 设备 effect 资源不足

## Spotify 专属

### Q15：Spotify `play()` / `pause()` 不生效

Spotify 部分版本只接受自定义 command。请按 [Spotify 兼容](integration-guide/spotify.md) 用 `safePlay/safePause` 封装。

## 监听

### Q16：listener 没有回调

检查：

1. 是否在 `browser` 连接成功后再 `addListener`
2. 是否在主线程操作（建议在主线程统一处理 `Player.Listener` 回调）
3. `browser.release()` 后 listener 会失效

## 安装与权限

### Q17：媒体中心装好但没有特权权限

请确认：

1. APK 安装到了 `/system/priv-app/jdoMediaCenter/`
2. `com.jidouauto.mediacenter.xml` 推送到了 `/system/etc/permissions/`
3. APK 包名与 XML 中的 `privapp-permissions package` 一致

详见 [环境部署](install-guide.md)。

### Q18：皮肤包不生效

```bash
adb shell cmd overlay list --user current | grep com.jidouauto.mediacenter
adb shell cmd overlay enable --user current aomrd_com.jidouauto.mediacenter
```

详见项目根目录 `README.md`。
