# 支持的媒体源

| 媒体源 | packageName | service class |
| --- | --- | --- |
| 网易云音乐 | `com.jidouauto.netease.jdo` | `com.jidouauto.netease.jdo.service.JdoMusicMediaService` |
| iQIYI | `com.jidouauto.iqiyi.jdo` | `com.jidouauto.iqiyi.jdo.service.JdoIqiyiMediaService` |
| RadioBrowser | `com.jidouauto.radiobrowser.jdo` | `com.jidouauto.radiobrowser.jdo.service.JdoRadioBrowserMediaService` |
| Spotify | `com.jidouauto.spotify` | `com.jidouauto.spotify.service.SpotifyMediaService` |
| 短剧 | `com.jidouauto.shortplay.jdo` | `com.jidouauto.shortplay.jdo.service.JdoShortPlayMediaService` |

## 示例

```kotlin
import android.content.ComponentName

val NETEASE_SOURCE = ComponentName(
    "com.jidouauto.netease.jdo",
    "com.jidouauto.netease.jdo.service.JdoMusicMediaService"
)

val IQY_SOURCE = ComponentName(
    "com.jidouauto.iqiyi.jdo",
    "com.jidouauto.iqiyi.jdo.service.JdoIqiyiMediaService"
)

val RADIO_BROWSER_SOURCE = ComponentName(
    "com.jidouauto.radiobrowser.jdo",
    "com.jidouauto.radiobrowser.jdo.service.JdoRadioBrowserMediaService"
)

val SPOTIFY_SOURCE = ComponentName(
    "com.jidouauto.spotify",
    "com.jidouauto.spotify.service.SpotifyMediaService"
)

val SHORT_PLAY_SOURCE = ComponentName(
    "com.jidouauto.shortplay.jdo",
    "com.jidouauto.shortplay.jdo.service.JdoShortPlayMediaService"
)
```

!!! note "顺序约定"
    媒体中心内部固定按 网易云 → Spotify → RadioBrowser → 爱奇艺 → 短剧 的顺序展示，外部接入可按业务自行定义顺序。
