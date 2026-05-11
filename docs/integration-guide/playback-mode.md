# 播放模式

约定如下：

| 模式 | repeatMode | shuffleModeEnabled |
| --- | --- | --- |
| 顺序播放 | `Player.REPEAT_MODE_ALL` | `false` |
| 单曲循环 | `Player.REPEAT_MODE_ONE` | `false` |
| 随机播放 | `Player.REPEAT_MODE_OFF` | `true` |

## 示例

=== "顺序播放"

    ```kotlin
    import androidx.media3.common.Player

    browser.repeatMode = Player.REPEAT_MODE_ALL
    browser.shuffleModeEnabled = false
    ```

=== "单曲循环"

    ```kotlin
    browser.repeatMode = Player.REPEAT_MODE_ONE
    browser.shuffleModeEnabled = false
    ```

=== "随机播放"

    ```kotlin
    browser.repeatMode = Player.REPEAT_MODE_OFF
    browser.shuffleModeEnabled = true
    ```

!!! note "状态同步"
    切换播放模式后，所有连接到同一会话的 `Player.Listener` 都会收到 `onRepeatModeChanged` / `onShuffleModeEnabledChanged` 回调。
