
# JDO Media Center 歌词对接指南

本文档面向外部应用开发人员，说明如何通过 AndroidX Media3 从 JDO Media Center 获取当前播放歌曲的歌词，并正确识别普通 LRC 歌词与逐字歌词格式。

## 1. 对接结论

外部应用通过 `MediaBrowser` / `MediaController` 连接网易云音乐服务后，使用 `sendCustomCommand` 请求歌词。返回歌词统一放在 `SessionResult.extras["music_lyric"]` 中。

建议接入方按以下顺序处理：

1. 先请求逐字歌词 `CUSTOM_ACTION_FETCH_LYRIC_BY_WORD`。
2. 如果返回非空，按“逐字歌词 JSON”解析。
3. 如果逐字歌词为空、解析失败，或业务只需要逐句展示，再请求普通歌词 `CUSTOM_ACTION_FETCH_LYRIC`。
4. 普通歌词按标准 LRC 行格式解析：`[mm:ss.xx]歌词文本`。

> 注意：逐字歌词不是标准 `.lrc` 文本，不能直接交给只支持 LRC 的控件展示。如果偶发遇到 `{"lrcContent":"[...]"}` 这种外层包装的形式（属于边缘场景，详见 §8），真正歌词内容是 `lrcContent` 里的 JSON 数组字符串。

## 2. 常量定义

下面三个字符串常量是协议字面量，需要外部 App 在自己的工程中按相同的字符串值定义并使用。建议在自己的代码中集中放在一个 `object` 中：

```kotlin
object MediaLyricConstants {
    /** 普通逐句 LRC 歌词 custom action */
    const val CUSTOM_ACTION_FETCH_LYRIC = "CUSTOM_ACTION_FETCH_LYRIC"

    /** 逐字歌词 custom action */
    const val CUSTOM_ACTION_FETCH_LYRIC_BY_WORD = "CUSTOM_ACTION_FETCH_LYRIC_BY_WORD"

    /** 返回的 SessionResult.extras 中歌词字符串的 key */
    const val EXTRA_MUSIC_LYRIC = "music_lyric"
}
```

> 在 JDO Media Center 工程内部，这些常量分别位于
> `MediaBrowserManager.CUSTOM_ACTION_FETCH_LYRIC` /
> `MediaBrowserManager.CUSTOM_ACTION_FETCH_LYRIC_BY_WORD` 与
> `MediaConstContract.Source.NM.EXTRA_NETEASE_MUSIC_LYRIC`，外部 App 不依赖这些类，只需保证字符串值一致即可。

## 3. 目标服务

请求歌词前，外部 App 需要通过 `MediaBrowser` 连接到网易云音乐的 Media3 服务。

| 项目 | 值 |
| --- | --- |
| Package Name | `com.jidouauto.netease.jdo` |
| Service Name | `com.jidouauto.netease.jdo.service.JdoMusicMediaService` |

### 3.1 AndroidManifest 配置（Android 11+ 必须）

Android 11（API 30）及以上系统对包可见性做了限制。外部 App 必须在自己的 `AndroidManifest.xml` 中声明对网易云包的查询权限，否则 `SessionToken.getAllServiceTokens(context)` 与 `MediaBrowser.Builder(...).buildAsync()` 都拿不到目标服务。

```xml
<manifest ...>
    <queries>
        <intent>
            <action android:name="androidx.media3.session.MediaLibraryService" />
        </intent>
        <intent>
            <action android:name="androidx.media3.session.MediaSessionService" />
        </intent>
        <intent>
            <action android:name="android.media.browse.MediaBrowserService" />
        </intent>

        <package android:name="com.jidouauto.netease.jdo" />
    </queries>
    ...
</manifest>
```

JDO Media Center 自身的 `app/src/main/AndroidManifest.xml` 即是这种声明方式。

### 3.2 建立 MediaBrowser 连接

```kotlin
import android.content.ComponentName
import android.content.Context
import androidx.media3.session.MediaBrowser
import androidx.media3.session.SessionToken
import com.google.common.util.concurrent.ListenableFuture
import kotlinx.coroutines.guava.await

suspend fun buildNeteaseMediaBrowser(context: Context): MediaBrowser {
    val componentName = ComponentName(
        "com.jidouauto.netease.jdo",
        "com.jidouauto.netease.jdo.service.JdoMusicMediaService"
    )
    val sessionToken = SessionToken(context, componentName)
    val browserFuture: ListenableFuture<MediaBrowser> =
        MediaBrowser.Builder(context, sessionToken).buildAsync()
    return browserFuture.await()
}
```

如果项目未引入 `await()` 扩展，需要添加：

```gradle
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-guava:1.7.1")
```

## 4. 请求参数

`sendCustomCommand` 的第二个参数需要传当前播放歌曲的 `MediaMetadata.toBundle()`。服务端会依赖当前歌曲元信息（特别是 `mediaId` 和 extras 中的网易侧扩展字段）查询歌词。

推荐取值：

```kotlin
val metadata = mediaController.currentMediaItem?.mediaMetadata ?: return null
val args = metadata.toBundle()
```

不要手动拼一个只包含歌名或歌手的 `Bundle`，否则可能因为缺少 `mediaId`、数据源扩展字段等信息导致查不到歌词。

### 4.1 仅对音乐类型请求

JDO Media Center 内部只在 `MediaMetadata.mediaType == MEDIA_TYPE_MUSIC` 时才会请求歌词，电台、有声书等其他类型不请求。建议外部 App 同样做一次过滤，避免无意义调用：

```kotlin
if (metadata.mediaType != MediaMetadata.MEDIA_TYPE_MUSIC) return null
```

### 4.2 可选：使用带 MediaItem 的重载

Media3 1.8.0 提供了一个标记 `@UnstableApi` 的三参重载：

```kotlin
controller.sendCustomCommand(
    SessionCommand(action, Bundle.EMPTY),
    mediaItem,                              // 当前播放项
    mediaItem.mediaMetadata.toBundle()      // 元信息
)
```

它等价于在调用前往 args 里塞了 `MediaConstants.EXTRA_KEY_MEDIA_ID`，本质和两参版相同。JDO Media Center 内部 `LiveShowDataProviderImpl` 走这条调用路径；外部 App 用两参版即可，不强制升级。

## 5. 调用示例

```kotlin
import android.os.Bundle
import androidx.media3.common.MediaMetadata
import androidx.media3.session.MediaController
import androidx.media3.session.SessionCommand
import androidx.media3.session.SessionResult
import kotlinx.coroutines.guava.await

suspend fun fetchLyric(
    mediaController: MediaController,
    metadata: MediaMetadata,
    byWord: Boolean
): String? {
    val action = if (byWord) {
        MediaLyricConstants.CUSTOM_ACTION_FETCH_LYRIC_BY_WORD
    } else {
        MediaLyricConstants.CUSTOM_ACTION_FETCH_LYRIC
    }

    val result: SessionResult = mediaController.sendCustomCommand(
        SessionCommand(action, Bundle.EMPTY),
        metadata.toBundle()
    ).await()

    if (result.resultCode != SessionResult.RESULT_SUCCESS) {
        return null
    }

    return result.extras
        .getString(MediaLyricConstants.EXTRA_MUSIC_LYRIC)
        ?.takeIf { it.isNotBlank() }
}

suspend fun fetchBestAvailableLyric(
    mediaController: MediaController,
    metadata: MediaMetadata
): LyricPayload? {
    val byWord = fetchLyric(mediaController, metadata, byWord = true)
    if (!byWord.isNullOrBlank()) {
        return LyricPayload.ByWord(byWord)
    }

    val lrc = fetchLyric(mediaController, metadata, byWord = false)
    if (!lrc.isNullOrBlank()) {
        return LyricPayload.Lrc(lrc)
    }

    return null
}

sealed class LyricPayload {
    data class ByWord(val rawJson: String) : LyricPayload()
    data class Lrc(val rawLrc: String) : LyricPayload()
}
```

## 6. 普通歌词格式

普通歌词返回标准 LRC 文本，每行包含一个时间戳和歌词内容。

```lrc
[00:00.00]作词：C君
[00:00.31]作曲：方大同
[00:01.25]曾经受过一些伤
[00:03.80]也许还没有遗忘
```

时间戳支持：

| 格式 | 示例 | 说明 |
| --- | --- | --- |
| `[mm:ss]` | `[01:23]` | 精确到秒 |
| `[mm:ss.xx]` | `[01:23.45]` | 精确到百分之一秒 |
| `[mm:ss.xxx]` | `[01:23.456]` | 精确到毫秒 |
| `[mm:ss:xx]` | `[01:23:45]` | 兼容冒号分隔的小数部分 |

解析建议：

1. 按换行拆分。
2. 忽略空行和只有标签、没有正文的行，例如 `[ar:xxx]`。
3. 将时间戳转换成毫秒。
4. 按时间升序排序。
5. 如果相邻两行时间相同，通常后一行可视为翻译行，接入方可按业务决定是否展示。

## 7. 逐字歌词格式

逐字歌词返回 JSON 数组字符串，不是标准 LRC。数组中的每个对象表示一句歌词，每句歌词内的 `words` 表示逐字或逐词时间轴。

> 重要：句级 `duration` 表示**当前句实际唱词时长**（最后一个字结束 - 第一个字开始），并不一定等于"到下一句开始的间隔"。展示整句的高亮窗口时通常需要用 `下一句的 start - 当前句的 start` 自行计算。JDO Media Center 在 `DualLrcHelper.handleDuration` 中就是这样处理的：取下一句（跳过翻译行）的 `start` 减当前句 `start` 作为整句展示时长。

```json
[
  {
    "duration": 1890,
    "start": 1250,
    "words": [
      {
        "duration": 250,
        "suspend": 1250,
        "words": "曾"
      },
      {
        "duration": 140,
        "suspend": 1500,
        "words": "经"
      }
    ]
  }
]
```

字段说明：

| 字段 | 类型 | 单位 | 说明 |
| --- | --- | --- | --- |
| `start` | Long | ms | 当前句开始时间，相对歌曲起点 |
| `duration` | Long | ms | 当前句唱词时长 |
| `words` | Array | - | 当前句的逐字/逐词列表 |
| `words[].suspend` | Long | ms | 当前字或词开始时间，相对歌曲起点 |
| `words[].duration` | Long | ms | 当前字或词持续时长 |
| `words[].words` | String | - | 当前字或词文本 |

逐字歌词 Kotlin 数据结构示例：

```kotlin
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class WordByWordLine(
    val duration: Long,
    val start: Long,
    val words: List<WordByWordToken> = emptyList()
)

@Serializable
data class WordByWordToken(
    val duration: Long,
    val suspend: Long,
    @SerialName("words")
    val text: String
)
```

如果接入方只需要逐句展示，可以把逐字 JSON 转成 LRC：

```kotlin
import kotlinx.serialization.json.Json

private val lyricJson = Json {
    ignoreUnknownKeys = true
}

fun wordByWordJsonToLrc(raw: String): String {
    val normalized = unwrapLrcContentIfNeeded(raw)
    val lines = lyricJson.decodeFromString<List<WordByWordLine>>(normalized)

    return lines
        .sortedBy { it.start }
        .mapNotNull { line ->
            val text = line.words.joinToString(separator = "") { it.text }.trim()
            if (text.isBlank()) null else "${formatLrcTime(line.start)}$text"
        }
        .joinToString(separator = "\n")
}

fun formatLrcTime(ms: Long): String {
    val totalSeconds = ms / 1000
    val minute = totalSeconds / 60
    val second = totalSeconds % 60
    val centisecond = (ms % 1000) / 10
    return "[%02d:%02d.%02d]".format(minute, second, centisecond)
}
```

## 8. 兼容外层 `lrcContent` 包装（边缘场景）

> JDO Media Center 当前在线版本的网易云数据源直接返回纯 JSON 数组字符串，不存在 `lrcContent` 外层包装。本节属于历史/边缘场景的容错建议，如果你确认数据源版本稳定，可跳过。

部分链路抓到的数据可能长这样：

```json
{
  "lrcContent": "[{\"duration\":312,\"start\":0,\"words\":[{\"duration\":312,\"suspend\":0,\"words\":\"作词：C君\"}]}]"
}
```

这不是最终逐字歌词数组，而是外层对象包装了一个字符串字段。接入方可以加一层防御性拆包，先取出 `lrcContent`，再按逐字 JSON 数组解析。

```kotlin
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class LyricContentWrapper(
    val lrcContent: String? = null
)

fun unwrapLrcContentIfNeeded(raw: String): String {
    val trimmed = raw.trim()
    if (!trimmed.startsWith("{")) {
        return trimmed
    }

    return runCatching {
        lyricJson.decodeFromString<LyricContentWrapper>(trimmed).lrcContent
    }.getOrNull()?.takeIf { it.isNotBlank() } ?: trimmed
}
```

格式识别建议：

```kotlin
fun detectLyricFormat(raw: String): LyricFormat {
    val normalized = unwrapLrcContentIfNeeded(raw).trim()
    return when {
        normalized.startsWith("[") && normalized.contains("\"words\"") -> LyricFormat.WORD_BY_WORD_JSON
        normalized.lines().any { it.trimStart().startsWith("[") && it.contains("]") } -> LyricFormat.LRC
        else -> LyricFormat.UNKNOWN
    }
}

enum class LyricFormat {
    WORD_BY_WORD_JSON,
    LRC,
    UNKNOWN
}
```

## 9. 展示与降级建议

逐字展示：

1. 按 `start` 排序歌词句。
2. 每句内按 `words[].suspend` 排序。
3. 当前播放进度落在 `words[].suspend` 到 `words[].suspend + words[].duration` 之间时，高亮对应字或词。
4. 如果只做整句高亮，用 `line.start` 和下一句 `start` 计算整句展示区间。

普通 LRC 展示：

1. 当前播放进度大于等于某行时间，并小于下一行时间时，展示当前行。
2. 最后一行可以展示到歌曲结束；如果拿不到歌曲时长，可给一个默认展示时长。

降级规则：

1. 逐字歌词为空：请求普通歌词。
2. 逐字歌词不是合法 JSON：请求普通歌词。
3. 逐字歌词可解析但 `words` 为空：可拼接整句文本展示，或请求普通歌词。
4. 普通歌词为空或解析后无有效行：展示“暂无歌词”。

## 10. 注意事项

1. 歌词请求建议在 `onMediaItemTransition`、播放源切换、或当前 `mediaId` 变化后触发一次，并按歌曲缓存结果，避免高频轮询。JDO Media Center 内部用 `currentMetaDataId` 比较 `METADATA_KEY_MEDIA_ID`，只有变化时才发起请求，可作参考。
2. 请求参数必须来自当前播放中的 `MediaMetadata`，建议使用 `mediaController.currentMediaItem?.mediaMetadata`。
3. `music_lyric` 为空不一定是错误，可能是歌曲无歌词、数据源未提供、或当前元信息不足。需要在 UI 上做"暂无歌词"占位。
4. 普通歌词和逐字歌词是两种不同格式，接入方需要先识别再解析。
5. 时间单位统一为毫秒。
6. 调用 `sendCustomCommand` 之前最好先用
   `mediaController.isSessionCommandAvailable(SessionCommand(action, Bundle()))` 判一下能力可见性，避免在不支持的源（如 Spotify、Radio Browser）上发出无效请求。
7. `MediaBrowser` 连接断开后再调用会立即返回失败的 `SessionResult`，注意区分"未连接"和"歌词为空"两种情形。
