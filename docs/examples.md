# 开发示例

> 本页提供基于 Media3 `MediaBrowser` 的真实接入示例。每个媒体源对外接口都有对应的内部测试入口，外部接入方可参考下面的代码片段进行验证。

## 1. 最小可运行示例

```kotlin
import android.content.ComponentName
import android.content.Context
import androidx.media3.session.MediaBrowser
import androidx.media3.session.SessionToken
import kotlinx.coroutines.guava.await

class MediaCenterDemo(private val context: Context) {

    private val neteaseSource = ComponentName(
        "com.jidouauto.netease.jdo",
        "com.jidouauto.netease.jdo.service.JdoMusicMediaService"
    )

    suspend fun playFirstSong(): Boolean {
        val token = SessionToken(context, neteaseSource)
        val browser = MediaBrowser.Builder(context, token).buildAsync().await()
        try {
            val root = browser.getLibraryRoot(null).await().value ?: return false
            val children = browser.getChildren(root.mediaId, 1, 50, null).await().value.orEmpty()
            val playable = children.firstOrNull { it.mediaMetadata.isPlayable == true } ?: return false
            browser.setMediaItem(playable)
            browser.prepare()
            browser.play()
            return true
        } finally {
            browser.release()
        }
    }
}
```

## 2. 搜索 + 整组播放（模拟语音助手"播放林俊杰的歌"）

```kotlin
import android.os.Bundle
import androidx.media3.common.MediaItem
import androidx.media3.session.MediaBrowser
import kotlinx.coroutines.guava.await

private fun extractChildren(group: MediaItem): List<MediaItem> {
    val bundles = group.mediaMetadata.extras
        ?.getParcelableArrayList<Bundle>("MEDIA_ITEM_PARAMETER_CHILDREN")
        ?: return emptyList()
    return bundles.map { MediaItem.fromBundle(it) }
}

suspend fun playArtistSongs(browser: MediaBrowser, artist: String) {
    val result = browser.getSearchResult(artist, 1, 8, null).await()
    val songGroup = result.value
        .orEmpty()
        .firstOrNull { it.mediaId == "searchsong" }
        ?: return

    val songs = extractChildren(songGroup)
    if (songs.isEmpty()) return

    browser.setMediaItems(songs, 0, 0L)
    browser.prepare()
    browser.play()
}
```

## 3. 视频播放（模拟语音助手"播放西游记"）

```kotlin
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.media3.common.MediaItem
import androidx.media3.session.MediaBrowser
import kotlinx.coroutines.guava.await

private fun extractChildren(group: MediaItem): List<MediaItem> {
    val bundles = group.mediaMetadata.extras
        ?.getParcelableArrayList<Bundle>("MEDIA_ITEM_PARAMETER_CHILDREN")
        ?: return emptyList()
    return bundles.map { MediaItem.fromBundle(it) }
}

suspend fun launchIqyVideo(context: Context, browser: MediaBrowser, keyword: String) {
    val result = browser.getSearchResult(keyword, 1, 6, null).await()
    val videoGroup = result.value
        .orEmpty()
        .firstOrNull { it.mediaId == "videos" }
        ?: return

    val target = extractChildren(videoGroup).firstOrNull() ?: return

    val intent = Intent("com.jidouauto.iqiyi.LAUNCH_INTENT").apply {
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        putExtra("target_media_item", target.toBundle())
    }
    context.startActivity(intent)
}
```

## 4. 监听播放状态

```kotlin
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.session.MediaBrowser

class PlaybackObserver(private val browser: MediaBrowser) : Player.Listener {

    fun attach() = browser.addListener(this)
    fun detach() = browser.removeListener(this)

    override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
        // 切歌：刷新 UI、重新拉歌词
    }

    override fun onMediaMetadataChanged(mediaMetadata: MediaMetadata) {
        // metadata 更新：标题、封面、艺人
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        // STATE_IDLE / STATE_BUFFERING / STATE_READY / STATE_ENDED
    }

    override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {
        // 播放/暂停状态变化
    }
}
```

## 5. 进度轮询

```kotlin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

fun CoroutineScope.startProgressTicker(browser: MediaBrowser, onTick: (Long, Long) -> Unit) =
    launch {
        while (isActive) {
            val pos = browser.currentPosition
            val dur = browser.contentDuration
            onTick(pos, dur)
            delay(250)
        }
    }
```

## 6. 收藏与登录态处理

```kotlin
import androidx.media3.common.HeartRating
import androidx.media3.session.MediaBrowser
import androidx.media3.session.SessionResult
import kotlinx.coroutines.guava.await

sealed class FavoriteResult {
    data object Ok : FavoriteResult()
    data object NeedLogin : FavoriteResult()
    data object Failed : FavoriteResult()
}

suspend fun toggleFavorite(
    browser: MediaBrowser,
    mediaId: String,
    favorite: Boolean,
): FavoriteResult {
    val result: SessionResult = browser
        .setRating(mediaId, HeartRating(favorite))
        .await()

    if (result.resultCode == SessionResult.RESULT_SUCCESS) {
        return FavoriteResult.Ok
    }
    if (result.extras.getBoolean("requireLogin", false)) {
        return FavoriteResult.NeedLogin
    }
    return FavoriteResult.Failed
}
```

## 7. 获取歌词（普通 LRC + 逐字 JSON）

```kotlin
import android.os.Bundle
import androidx.media3.common.MediaMetadata
import androidx.media3.session.MediaBrowser
import androidx.media3.session.SessionCommand
import androidx.media3.session.SessionResult
import kotlinx.coroutines.guava.await

object MediaLyricConstants {
    const val CUSTOM_ACTION_FETCH_LYRIC = "CUSTOM_ACTION_FETCH_LYRIC"
    const val CUSTOM_ACTION_FETCH_LYRIC_BY_WORD = "CUSTOM_ACTION_FETCH_LYRIC_BY_WORD"
    const val EXTRA_MUSIC_LYRIC = "music_lyric"
}

suspend fun fetchLyric(
    browser: MediaBrowser,
    metadata: MediaMetadata,
    byWord: Boolean,
): String? {
    if (metadata.mediaType != MediaMetadata.MEDIA_TYPE_MUSIC) return null

    val action = if (byWord) {
        MediaLyricConstants.CUSTOM_ACTION_FETCH_LYRIC_BY_WORD
    } else {
        MediaLyricConstants.CUSTOM_ACTION_FETCH_LYRIC
    }

    val command = SessionCommand(action, Bundle.EMPTY)
    if (!browser.isSessionCommandAvailable(command)) return null

    val result: SessionResult = browser.sendCustomCommand(command, metadata.toBundle()).await()
    if (result.resultCode != SessionResult.RESULT_SUCCESS) return null

    return result.extras.getString(MediaLyricConstants.EXTRA_MUSIC_LYRIC)?.takeIf { it.isNotBlank() }
}
```

完整歌词解析说明请见 [歌词对接](lyric-guide.md)。

## 8. 多源切换

```kotlin
import android.content.ComponentName

object MediaSourceCatalog {
    val NETEASE = ComponentName(
        "com.jidouauto.netease.jdo",
        "com.jidouauto.netease.jdo.service.JdoMusicMediaService",
    )
    val IQY = ComponentName(
        "com.jidouauto.iqiyi.jdo",
        "com.jidouauto.iqiyi.jdo.service.JdoIqiyiMediaService",
    )
    val RADIO = ComponentName(
        "com.jidouauto.radiobrowser.jdo",
        "com.jidouauto.radiobrowser.jdo.service.JdoRadioBrowserMediaService",
    )
    val SPOTIFY = ComponentName(
        "com.jidouauto.spotify",
        "com.jidouauto.spotify.service.SpotifyMediaService",
    )
    val SHORT_PLAY = ComponentName(
        "com.jidouauto.shortplay.jdo",
        "com.jidouauto.shortplay.jdo.service.JdoShortPlayMediaService",
    )
}

class MultiSourceClient(private val context: Context) {
    private var currentBrowser: MediaBrowser? = null

    suspend fun switchTo(source: ComponentName): MediaBrowser {
        currentBrowser?.release()
        val token = SessionToken(context, source)
        return MediaBrowser.Builder(context, token)
            .buildAsync()
            .await()
            .also { currentBrowser = it }
    }

    fun release() {
        currentBrowser?.release()
        currentBrowser = null
    }
}
```

!!! tip "示例代码来源"
    上面的示例都来自媒体中心 `MediaBrowserManager` / `PlaybackHelper` / `ServiceCommandHandler` 的真实接入逻辑。每个媒体源对外都暴露了对应的协议常量和 `MediaSessionService`，外部接入方均可按这些示例直接验证。
