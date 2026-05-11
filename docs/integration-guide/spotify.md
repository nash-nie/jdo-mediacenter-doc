# Spotify 兼容

Spotify 的播放 / 暂停建议优先按以下方式兼容：

1. 先尝试标准 `play()` / `pause()`
2. 如源侧要求自定义 command，再补充：

```kotlin
import android.os.Bundle
import androidx.media3.session.SessionCommand

val playCommand = SessionCommand("CUSTOM_SESSION_COMMAND_PLAY", Bundle())
val pauseCommand = SessionCommand("CUSTOM_SESSION_COMMAND_PAUSE", Bundle())

if (browser.isSessionCommandAvailable(playCommand)) {
    browser.sendCustomCommand(playCommand, Bundle())
}
```

## 推荐封装

```kotlin
suspend fun safePlay(browser: MediaBrowser) {
    val customPlay = SessionCommand("CUSTOM_SESSION_COMMAND_PLAY", Bundle())
    if (browser.isSessionCommandAvailable(customPlay)) {
        browser.sendCustomCommand(customPlay, Bundle()).await()
    } else {
        browser.play()
    }
}

suspend fun safePause(browser: MediaBrowser) {
    val customPause = SessionCommand("CUSTOM_SESSION_COMMAND_PAUSE", Bundle())
    if (browser.isSessionCommandAvailable(customPause)) {
        browser.sendCustomCommand(customPause, Bundle()).await()
    } else {
        browser.pause()
    }
}
```

!!! info "为什么需要兼容"
    Spotify 在部分版本上对外只暴露 custom command，标准 `play() / pause()` 不会触达其内部播放器。建议接入时统一使用 `safePlay/safePause` 封装。
