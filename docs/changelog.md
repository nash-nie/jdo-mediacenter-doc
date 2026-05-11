# 更新日志

> 仅记录与外部接入文档及对外协议相关的变更，业务侧改动请查看 git log。

## 2026-05-06

- :material-waveform: 新增 [音频频谱接入](audio-spectrum.md)：`CUSTOM_ACTION_GET_AUDIO_SESSION_ID` / `EXTRA_AUDIO_SESSION_ID` + Android `Visualizer` 采集 waveform / FFT
- :material-api: API 清单增补 [音频频谱章节](api-reference.md#custom-action音频频谱)

## 2026-04-22

- :material-file-document-plus: 新增 [外部接入文档](integration-guide/index.md)，覆盖：
    - 支持的媒体源 ComponentName 列表
    - `SessionToken + MediaBrowser` 接入流程
    - 浏览 / 搜索 / 播放 / 收藏 / 状态监听
    - 业务协议约定（详情列表、查询类型、搜索分组）
    - Spotify 兼容方案
- 关联 ticket: `JDO20260422`

## 2026-04-20

- :material-swap-horizontal: WebSocket 切换到审批通道
- :material-swap-horizontal: 媒体数据从 WebSocket 推送，由原拉取模式调整为流式订阅
- 关联 ticket: `JDO20260420`

## 2026-04-17

- :material-cellphone: OMINI Activity 背景样式调整
- :material-bug-fix: 修复 Agent Activity 背景显示异常
- 关联 ticket: `JDO20260417`

## 2026-04-15 ~ 2026-04-16

- :material-television-play: 媒体中心 App 前台启动爱奇艺
- :material-cellphone: OMINI Activity 列表布局与动画
- :material-cellphone: OMINI Activity 横屏锁定
- :material-television-play: 媒体推荐视频按 `videoId` 精确匹配
- 关联 ticket: `JDO20260415` ~ `JDO20260416`

## 2026-04-14

- :material-list-status: MediaAgent 推荐列表跳转
- :material-list-status: OMINI Launcher Activity 接口数据对接
- :material-music: 媒体中心播放模块歌词右侧增加播放源标识
- 关联 ticket: `JDO20260414`

## 2026-04-13

- :material-arrow-up-bold: HMI SDK 升级至 `main.2026.161`，注册 `OverlayChangeManager`
- :material-window-close: 媒体播放弹窗关闭逻辑修复
- 关联 ticket: `JDO20260413`

## 2026-04-12

- :material-arrow-up-bold: HMI SDK 升级至 515
- :material-image: 统一图片加载到 ImageLoader，并支持动态版本
- 关联 ticket: `JDO20260412`

## 2026-04-10 ~ 2026-04-11

- :material-cellphone: OMINI Activity `taskAffinity` 调整
- :material-magnify: 爱奇艺媒体搜索关键词优化
- :material-list-status: 语音媒体 Agent 推荐列表跳转修复
- :material-cellphone: 媒体 Agent Activity 适配 OMINI Launcher
- 关联 ticket: `JDO20260410` ~ `JDO20260411`

## 2026-04-09

- :material-bug-fix: 比亚迪车机首次进入密度适配修复（首屏 inflate 前完成密度适配）
- 关联 ticket: `JDO20260409`

---

!!! info "完整 git log"
    更细粒度的实现变更请使用 `git log --oneline` 或在 Gerrit 上查看 commit 历史。本页仅汇总对外接入或运行行为产生影响的内容。
