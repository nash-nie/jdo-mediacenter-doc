# 接入说明

外部接入建议优先参考 Google 官方 Media3 文档，本文档结合当前项目支持的媒体源和接入约定给出落地示例。

## Google 官方文档

- MediaBrowser API Reference: [https://developer.android.com/reference/androidx/media3/session/MediaBrowser](https://developer.android.com/reference/androidx/media3/session/MediaBrowser)
- MediaController API Reference: [https://developer.android.com/reference/androidx/media3/session/MediaController](https://developer.android.com/reference/androidx/media3/session/MediaController)

## 支持的能力

外部接入统一采用 AndroidX Media3 官方方式，通过 `SessionToken + MediaBrowser` 连接目标媒体源服务，完成：

- 搜索
- 收藏 / 取消收藏
- 播放
- 暂停
- 上一首
- 下一首
- 切换播放模式
- 查看播放进度
- 获取 metadata
- 获取播放状态
- 获取当前连接媒体源信息

!!! tip "推荐先读"
    新接入方建议按以下顺序阅读：
    [依赖配置](dependencies.md) → [建立连接](connect.md) → [浏览媒体内容](browse.md) → [播放控制](playback.md)
