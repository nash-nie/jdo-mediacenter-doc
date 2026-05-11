# 搜索

## 关键字搜索

```kotlin
val result = browser.getSearchResult(
    "周杰伦",
    1,
    50,
    null
).await()

val items = result.value.orEmpty()
```

## 搜索热词

如目标媒体源支持热词，可通过固定 `mediaId` 获取：

```text
MEDIA_ID_MEDIA_CENTER_SEARCH_HOT_WORDS
```

```kotlin
val hotWords = browser.getChildren(
    "MEDIA_ID_MEDIA_CENTER_SEARCH_HOT_WORDS",
    1,
    Int.MAX_VALUE,
    null
).await()
```

## 搜索结果分组

部分媒体源（例如网易云、爱奇艺）返回的搜索结果是分组节点，需要先判断分组的 `mediaId` 再展开 children。

| `mediaId` | 含义 |
| --- | --- |
| `searchsong` | 歌曲分组 |
| `videos` | 视频分组 |

详见 [业务协议约定](protocol.md#搜索结果分组)。

## 提取分组 children

分组节点的 children 通常作为 `Bundle[]` 放在 `mediaMetadata.extras` 中：

```kotlin
import android.os.Bundle
import androidx.media3.common.MediaItem

fun extractChildren(groupItem: MediaItem): List<MediaItem> {
    val bundles = groupItem.mediaMetadata.extras
        ?.getParcelableArrayList<Bundle>("MEDIA_ITEM_PARAMETER_CHILDREN")
        ?: return emptyList()
    return bundles.map { MediaItem.fromBundle(it) }
}
```
