# JDO Media Center 接入文档

> 适用对象：外部业务模块 / 外部应用 / Android Automotive 车机模块
> 技术方案：AndroidX Media3 `MediaBrowser` / `MediaController`

JDO Media Center 是 AOSP 车机平台的统一媒体中心，聚合网易云音乐、iQIYI、Spotify、RadioBrowser、短剧等媒体源，并以 Media3 标准协议向外部业务和系统侧提供能力。

## 文档导航

<div class="grid cards" markdown>

-   :material-rocket-launch: __快速入门__

    ---

    通过 `SessionToken + MediaBrowser` 5 步完成外部接入。

    [:octicons-arrow-right-24: 接入说明](integration-guide/overview.md)

-   :material-puzzle: __集成指南__

    ---

    完整覆盖连接、浏览、搜索、播放、收藏、监听、协议约定等细节。

    [:octicons-arrow-right-24: 集成指南](integration-guide/index.md)

-   :material-music-note-eighth: __歌词对接__

    ---

    通过 `sendCustomCommand` 获取普通 LRC 与逐字歌词。

    [:octicons-arrow-right-24: 歌词对接](lyric-guide.md)

-   :material-waveform: __音频频谱接入__

    ---

    通过 `audioSessionId` + `Visualizer` 采集 waveform / FFT 频谱数据，适用于 Unity / 原生 Android。

    [:octicons-arrow-right-24: 音频频谱接入](audio-spectrum.md)

-   :material-code-tags: __开发示例__

    ---

    基于测试应用提取的真实接入示例，涵盖音乐、视频、电台、短剧。

    [:octicons-arrow-right-24: 开发示例](examples.md)

-   :material-api: __API 清单__

    ---

    支持的媒体源、Custom Command、Custom Action、协议常量速查。

    [:octicons-arrow-right-24: API 清单](api-reference.md)

-   :material-frequently-asked-questions: __常见问题__

    ---

    Android 11 包可见性、连接失败、`music_lyric` 为空等高频问题。

    [:octicons-arrow-right-24: FAQ](faq.md)

</div>

## 媒体中心能力

外部接入统一采用 AndroidX Media3 官方方式，通过 `SessionToken + MediaBrowser` 连接目标媒体源服务，完成：

- 搜索 / 搜索热词
- 收藏 / 取消收藏
- 播放 / 暂停 / 上一首 / 下一首 / seek
- 切换播放模式（顺序 / 单曲 / 随机）
- 查看播放进度
- 获取 metadata
- 获取播放状态
- 获取当前连接的媒体源信息
- 获取歌词（普通 LRC / 逐字 JSON）

## 技术栈

| 项 | 值 |
| --- | --- |
| Min SDK | 30 |
| Target SDK | 35 |
| Media3 | 1.8.0 |
| Kotlin | 2.1.21 |
| Java Target | 11 |

## 参考资料

- Google 官方：[MediaBrowser API](https://developer.android.com/reference/androidx/media3/session/MediaBrowser)
- Google 官方：[MediaController API](https://developer.android.com/reference/androidx/media3/session/MediaController)
