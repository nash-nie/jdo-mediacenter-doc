# 业务协议约定

以下字段是当前媒体源侧的协议约定，接入时如需用到，可按如下方式使用。

## 详情列表查询

固定 `parentId`：

```text
MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST
```

常用 extras：

| key | 含义 |
| --- | --- |
| `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_MEDIA_ID` | 目标媒体 ID |
| `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_TYPE` | 查询类型 |
| `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_OFFSET` | offset |
| `EXTRA_MEDIA_CENTER_DETAIL_PLAYLIST_LIMIT` | limit |

固定 `mediaId`：

| value | 含义 |
| --- | --- |
| `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST_CURRENT` | 当前播放列表 |
| `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST_RECENT` | 最近播放 |
| `MEDIA_ID_MEDIA_CENTER_DETAIL_PLAYLIST_FAVORITE` | 收藏列表 |

## 常见查询类型

| value | 含义 |
| --- | --- |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_ARTIST_ALBUMS` | 艺人专辑 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_PLAYLIST_SONGS` | 歌单歌曲 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_ALBUM_SONGS` | 专辑歌曲 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_TYPE_QUERY_ARTIST_SONGS` | 艺人歌曲 |
| `MEDIA_CENTER_DETAIL_PLAYLIST_QUERY_TYPE_PLAYLIST_LISTS` | 歌单列表 |

## 搜索结果分组

部分媒体源搜索结果会返回分组节点，常见 `mediaId`：

| value | 含义 |
| --- | --- |
| `searchsong` | 歌曲分组 |
| `videos` | 视频分组 |

如果搜索结果节点本身不可播放，请继续读取其 children。

详见 [搜索 § 提取分组 children](search.md#提取分组-children)。
