# 建立连接

## 创建 MediaBrowser

```kotlin
import android.content.ComponentName
import android.content.Context
import androidx.media3.session.MediaBrowser
import androidx.media3.session.SessionToken
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.guava.await
import kotlinx.coroutines.withContext

suspend fun connectBrowser(
    context: Context,
    source: ComponentName,
    listener: MediaBrowser.Listener = object : MediaBrowser.Listener {}
): MediaBrowser = withContext(Dispatchers.Main) {
    val token = SessionToken(context, source)
    MediaBrowser.Builder(context, token)
        .setListener(listener)
        .buildAsync()
        .await()
}
```

## 释放 MediaBrowser

使用完成后请主动释放：

```kotlin
browser.release()
```

## 接入建议

- 连接放在主线程
- 连接失败时做有限次重试
- 页面销毁或模块退出时及时 `release`
- 避免每次操作都 reconnect，建议把连接对象维护在生命周期长于 UI 的层（例如 `Repository`）

## 失败重试模式

```kotlin
suspend fun connectBrowserWithRetry(
    context: Context,
    source: ComponentName,
    maxAttempts: Int = 3
): MediaBrowser {
    var lastError: Throwable? = null
    repeat(maxAttempts) { attempt ->
        runCatching { connectBrowser(context, source) }
            .onSuccess { return it }
            .onFailure { lastError = it }
        delay(200L * (attempt + 1))
    }
    throw lastError ?: IllegalStateException("connectBrowser failed")
}
```
