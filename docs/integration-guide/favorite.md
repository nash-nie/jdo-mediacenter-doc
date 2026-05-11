# 收藏管理

收藏能力统一使用 `setRating + HeartRating`：

```kotlin
import androidx.media3.common.HeartRating

browser.setRating(mediaId, HeartRating(true)).await()
browser.setRating(mediaId, HeartRating(false)).await()
```

说明：

- `true`：收藏
- `false`：取消收藏
- 如果目标媒体源需要登录，可能会在结果 `extras` 中返回 `requireLogin`

## 完整示例

```kotlin
import androidx.media3.common.HeartRating
import androidx.media3.session.SessionResult

suspend fun toggleFavorite(
    browser: MediaBrowser,
    mediaId: String,
    favorite: Boolean
): Boolean {
    val result: SessionResult = browser
        .setRating(mediaId, HeartRating(favorite))
        .await()

    if (result.resultCode != SessionResult.RESULT_SUCCESS) {
        val requireLogin = result.extras.getBoolean("requireLogin", false)
        if (requireLogin) {
            // 引导用户跳转到对应媒体源的登录页
        }
        return false
    }
    return true
}
```

!!! warning "登录态依赖"
    网易云、Spotify、爱奇艺等需要账号体系的源，在未登录时收藏会失败。建议在调用前先检查 `AccountManager` 状态或处理 `requireLogin` 字段。
