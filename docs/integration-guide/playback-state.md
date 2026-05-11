# 播放状态与 metadata

## 直接读取

```kotlin
val currentItem = browser.currentMediaItem
val metadata = browser.mediaMetadata
val duration = browser.duration
val currentPosition = browser.currentPosition
val bufferedPosition = browser.bufferedPosition
val playbackState = browser.playbackState
val isPlaying = browser.isPlaying
```

## 监听播放状态

```kotlin
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player

val listener = object : Player.Listener {
    override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {}

    override fun onMediaMetadataChanged(mediaMetadata: MediaMetadata) {}

    override fun onPlaybackStateChanged(playbackState: Int) {}

    override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {}

    override fun onRepeatModeChanged(repeatMode: Int) {}

    override fun onShuffleModeEnabledChanged(shuffleModeEnabled: Boolean) {}
}

browser.addListener(listener)
```

不再使用时移除：

```kotlin
browser.removeListener(listener)
```

## 进度刷新建议

如需稳定展示进度，建议每 250ms 轮询一次：

- `browser.currentPosition`
- 或 `browser.contentPosition`

## duration 取值顺序

按以下顺序取值：

1. `contentDuration`
2. `mediaMetadata.durationMs`
3. `mediaMetadata.extras[android.media.MediaMetadata.METADATA_KEY_DURATION]`

```kotlin
import android.media.MediaMetadata as PlatformMediaMetadata

fun resolveDuration(browser: MediaBrowser): Long {
    val content = browser.contentDuration
    if (content > 0) return content

    val meta = browser.mediaMetadata.durationMs
    if (meta != null && meta > 0) return meta

    val extra = browser.mediaMetadata.extras
        ?.getLong(PlatformMediaMetadata.METADATA_KEY_DURATION) ?: 0L
    return extra
}
```
