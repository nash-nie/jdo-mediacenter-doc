# 播放控制

## 播放单条

```kotlin
browser.setMediaItem(targetItem)
browser.prepare()
browser.play()
```

## 播放列表

```kotlin
browser.setMediaItems(items, startIndex, 0L)
browser.prepare()
browser.play()
```

## 暂停 / 上一首 / 下一首 / seek

```kotlin
browser.pause()
browser.seekToPrevious()
browser.seekToNext()
browser.seekTo(positionMs)
```

## 按 mediaId 播放

如果调用方已经拿到了目标 `mediaId`，推荐优先使用 `getItem(mediaId)` 获取标准 `MediaItem`，再发起播放：

```kotlin
val itemResult = browser.getItem(mediaId).await()
val targetItem = itemResult.value ?: return

browser.setMediaItem(targetItem)
browser.prepare()
browser.play()
```

适用场景：

- 已经缓存了媒体源返回的 `mediaId`
- 从业务侧拿到了明确的歌曲 / 专辑 / 视频 `mediaId`

## 语音助手示例：播放"林俊杰的歌"

当前语音小助手的实际处理逻辑是：

1. 连接网易云音乐媒体源
2. 组织搜索关键词：`artist + song + genre`
3. 对"播放林俊杰的歌"这类请求，关键词通常就是 `林俊杰`
4. 调用 `getSearchResult(keyword, ...)`
5. 在结果中找到歌曲分组 `searchsong`
6. 取出分组 children
7. 直接调用 `setMediaItems(items, startIndex, 0)`，把整组歌曲交给播放器

```kotlin
import android.os.Bundle
import androidx.media3.common.MediaItem

fun extractChildren(groupItem: MediaItem): List<MediaItem> {
    val bundles = groupItem.mediaMetadata.extras
        ?.getParcelableArrayList<Bundle>("MEDIA_ITEM_PARAMETER_CHILDREN")
        ?: return emptyList()
    return bundles.map { MediaItem.fromBundle(it) }
}

val keyword = "林俊杰"
val startIndex = 0

val result = browser.getSearchResult(keyword, 1, 8, null).await()

val songGroup = result.value
    .orEmpty()
    .firstOrNull { it.mediaId == "searchsong" }
    ?: return

val songs = extractChildren(songGroup)
if (songs.isEmpty()) return

browser.setMediaItems(songs, startIndex, 0L)
```

说明：

- 这里使用的是整组播放，而不是先取第一首再 `setMediaItem`
- 这和当前 `ServiceCommandHandler.handleMusicPlay()` 的实现一致
- 如果语义里带"播放第 N 首"，则把 `startIndex` 改为对应索引

## 语音助手示例：播放"西游记"

当前语音小助手播放视频的实际处理逻辑是：

1. 连接 iQIYI 媒体源
2. 组织搜索关键词，对通用视频播放命令，关键词通常是 `actor + name`
3. 调用 `getSearchResult(keyword, ...)`
4. 在结果中找到视频分组 `videos`
5. 从分组 children 中取目标视频 `MediaItem`
6. 使用 iQIYI 播放 Intent 打开播放页

```kotlin
import android.content.Intent
import android.os.Bundle
import androidx.media3.common.MediaItem

fun extractChildren(groupItem: MediaItem): List<MediaItem> {
    val bundles = groupItem.mediaMetadata.extras
        ?.getParcelableArrayList<Bundle>("MEDIA_ITEM_PARAMETER_CHILDREN")
        ?: return emptyList()
    return bundles.map { MediaItem.fromBundle(it) }
}

val keyword = "西游记"

val result = browser.getSearchResult(keyword, 1, 6, null).await()

val videoGroup = result.value
    .orEmpty()
    .firstOrNull { it.mediaId == "videos" }
    ?: return

val videos = extractChildren(videoGroup)
val targetVideo = videos.firstOrNull() ?: return

// MediaItem.toBundle() 在部分 Media3 版本下可能需要 @OptIn(UnstableApi::class)
val intent = Intent("com.jidouauto.iqiyi.LAUNCH_INTENT").apply {
    putExtra("target_media_item", targetVideo.toBundle())
}
context.startActivity(intent)
```

说明：

- 这里的实际起播方式不是 `setMediaItem`，而是启动 iQIYI 播放页
- 这和当前 `handleVideoPlay() + openIQYPlayerActivity()` 的实现一致

如果你已经拿到了目标视频的业务 ID，例如 iQIYI 的 `qipuId`，可以先在 `videos` 里按 extras 过滤：

```kotlin
val targetVideo = videos.firstOrNull {
    it.mediaMetadata.extras?.getLong("qipuId")?.toString() == targetVideoId
} ?: return
```

如果是从推荐卡片或跳转参数直接起播，当前项目里还会拼接更强约束的关键词：

```text
director第一个值 + actors第一个值 + title
```

这和 `MediaAgentManager.parseMediaJump()` 及 `ServiceCommandHandler` 中的视频跳转逻辑一致。

短剧源同理，可使用：

```text
com.jidouauto.shortplay.LAUNCH_INTENT
```
