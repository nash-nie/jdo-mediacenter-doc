# API 清单

本页是协议常量、Custom Command、Custom Action 等的速查表，用作接入侧字面量对齐。

## 媒体源 ComponentName

| 媒体源 | packageName | service class |
| --- | --- | --- |
| 网易云音乐 | `com.jidouauto.netease.jdo` | `com.jidouauto.netease.jdo.service.JdoMusicMediaService` |
| iQIYI | `com.jidouauto.iqiyi.jdo` | `com.jidouauto.iqiyi.jdo.service.JdoIqiyiMediaService` |
| RadioBrowser | `com.jidouauto.radiobrowser.jdo` | `com.jidouauto.radiobrowser.jdo.service.JdoRadioBrowserMediaService` |
| Spotify | `com.jidouauto.spotify` | `com.jidouauto.spotify.service.SpotifyMediaService` |
| 短剧 | `com.jidouauto.shortplay.jdo` | `com.jidouauto.shortplay.jdo.service.JdoShortPlayMediaService` |

## Custom Session Command

| 常量 | 字面量 | 用途 |
| --- | --- | --- |
| `CUSTOM_SESSION_COMMAND_PLAY` | `"CUSTOM_SESSION_COMMAND_PLAY"` | Spotify 兼容播放 |
| `CUSTOM_SESSION_COMMAND_PAUSE` | `"CUSTOM_SESSION_COMMAND_PAUSE"` | Spotify 兼容暂停 |
| `CUSTOM_SESSION_COMMAND_ACCOUNT` | `"CUSTOM_SESSION_COMMAND_ACCOUNT"` | 账号能力（内部使用） |

## Custom Action（歌词）

| 常量 | 字面量 | 用途 |
| --- | --- | --- |
| `CUSTOM_ACTION_FETCH_LYRIC` | `"CUSTOM_ACTION_FETCH_LYRIC"` | 普通逐句 LRC 歌词 |
| `CUSTOM_ACTION_FETCH_LYRIC_BY_WORD` | `"CUSTOM_ACTION_FETCH_LYRIC_BY_WORD"` | 逐字歌词 JSON |
| `EXTRA_MUSIC_LYRIC` | `"music_lyric"` | `SessionResult.extras` 中歌词字符串 key |

详见 [歌词对接](lyric-guide.md)。

## Custom Action（音频频谱）

| 常量 | 字面量 | 用途 |
| --- | --- | --- |
| `CUSTOM_ACTION_GET_AUDIO_SESSION_ID` | `"CUSTOM_ACTION_GET_AUDIO_SESSION_ID"` | 获取当前播放器 `audioSessionId` |
| `EXTRA_AUDIO_SESSION_ID` | `"EXTRA_AUDIO_SESSION_ID"` | `SessionResult.extras` 中的 `Int` key |

仅网易云音乐源支持，配合 `android.media.audiofx.Visualizer` 采集 waveform / FFT。详见 [音频频谱接入](audio-spectrum.md)。

## 业务协议常量

### 详情列表查询

| 类型 | 常量 |
| --- | --- |
| parentId | `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST` |
| extras key | `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_MEDIA_ID` |
| extras key | `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_TYPE` |
| extras key | `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_OFFSET` |
| extras key | `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_LIMIT` |
| 固定 mediaId | `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST_CURRENT` |
| 固定 mediaId | `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST_RECENT` |
| 固定 mediaId | `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST_FAVORITE` |

### 查询类型

| 常量 | 含义 |
| --- | --- |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_ARTIST_ALBUMS` | 艺人专辑 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_PLAYLIST_SONGS` | 歌单歌曲 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_ALBUM_SONGS` | 专辑歌曲 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_TYPE_QUERY_ARTIST_SONGS` | 艺人歌曲 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_PLAYLIST_LISTS` | 歌单列表 |

### 搜索分组

| 常量 | 含义 |
| --- | --- |
| `searchsong` | 歌曲分组 |
| `videos` | 视频分组 |

### 搜索热词

| 常量 | 含义 |
| --- | --- |
| `MEDIA_ID_MEDIA_CENTER_SEARCH_HOT_WORDS` | 搜索热词列表父节点 |

## Intent Action

| Intent Action | 用途 |
| --- | --- |
| `com.jidouauto.iqiyi.LAUNCH_INTENT` | 启动爱奇艺播放页 |
| `com.jidouauto.shortplay.LAUNCH_INTENT` | 启动短剧播放页 |

## 播放模式

| 模式 | repeatMode | shuffleModeEnabled |
| --- | --- | --- |
| 顺序播放 | `Player.REPEAT_MODE_ALL` | `false` |
| 单曲循环 | `Player.REPEAT_MODE_ONE` | `false` |
| 随机播放 | `Player.REPEAT_MODE_OFF` | `true` |

## MediaBrowser 主要 API

| API | 说明 |
| --- | --- |
| `getLibraryRoot(params)` | 获取根节点 |
| `getChildren(parentId, page, pageSize, params)` | 分页获取子节点 |
| `getItem(mediaId)` | 按 mediaId 获取标准 MediaItem |
| `getSearchResult(query, page, pageSize, params)` | 搜索 |
| `setMediaItem(item)` / `setMediaItems(items, startIndex, position)` | 装载播放项 |
| `prepare()` / `play()` / `pause()` | 播放控制 |
| `seekTo(positionMs)` / `seekToPrevious()` / `seekToNext()` | 进度控制 |
| `setRating(mediaId, HeartRating)` | 收藏 |
| `sendCustomCommand(command, args)` | 发送自定义会话指令 |
| `isSessionCommandAvailable(command)` | 判断目标源是否支持指定 command |
| `addListener(listener)` / `removeListener(listener)` | 状态监听 |
| `release()` | 释放连接 |
