# 模型与参数（视频换人）

参数和输入角色以 `cohub models show <model>` 为准；本文件只记 `models show` 里看不到的实测结论。

## 选型

| 情况 | 用 | 说明 |
|---|---|---|
| 默认 | `seedance-2-0-fast` | `reference_video` = 整段切片，`reference_image` ≤3 张；唯一实测能逐拍对齐的路线 |
| 需要 1080p 交付 | `seedance-2-0` / `seedance-2-5` | 先用 fast 跑通同一 prompt 再升级 |
| Seedance 拒审，且角色不能换 | `minimax-h3` | 每段 ≤10s，768P 上限；身份和场景稳，但动作不逐拍跟随，最高判「返修」 |
| 必须锁首帧 / 尾帧 pose | 不走本 skill | H3 不允许 `first_frame` 和 `reference_video` 同用；走首尾帧逐拍路线 |

`kling-image-to-video`、`minimax-h3-max-turbo` 不接受 `reference_video`，不能做换人。

## 参数

- `duration` = 切片长度（整数秒）；`resolution` 探针 480p，正式 720p 起。
- `ratio`：fast / 2.0 用与原片一致的比例（9:16 实测可用）；2.5 带 `reference_video` 时用 `adaptive`，`duration=-1` 跟随视频。
- 音轨后期处理：成片去掉模型音轨，按发布口径配平台曲库或自有音乐。
- `reference_video` 只接受 URL，CLI 会把本地文件传到不公开列出的 URL；这是 restricted 原片唯一允许的出口，URL 不写进任何交付物。

## 审核与故障

| 现象 | 判断 | 处理 |
|---|---|---|
| `OutputVideoSensitiveContentDetected`（copyright） | 角色是可识别的官方 IP 形象（三角洲干员及其皮肤 4 例全拦；原创无 IP 角色同条件通过） | 换原创角色；或按所在 Space 口径降级 H3；不靠改形容词绕 |
| HTTP 400 `input video may contain real person` | 原片是真人且被判定（AI 综艺 2 例） | 换原片；或用已经过审的自有 AI 成片当 `reference_video` 再换人（AI 综艺 dnc6–dnc9） |
| 同一请求上午过、下午拒 | 审核阈值波动 | 先 4s 探针复测，再决定 |
| 10 分钟「等待生成超时」 | 服务端拥堵，不是审核 | 不并发提交，逐条重提 |
| H3 15s 显存溢出 / 503 capacity | 服务端 | 切成 ≤10s；503 等 10 分钟重试 |
| H3 审核超时 `shumei_greenweb_img_requests_error` | 参考图过大 | 压成 720p JPEG（约 100KB） |
| 角色三视图被读成多个人 | 整图多视图 | 裁成单视图再传 |

被拒、超时均不扣费。

## 证据

- 粥粥工坊：`内容生成结果/20261019_56a5610c_唱跳二创试点/`（Seedance r 0.77–0.89 vs H3 ≈0）、`内容生成结果/20261019_c608989f_唱跳二创02-粉白宅舞/`（皮肤拒审对照）、`production/nawa-growl-dance-delta-v1/`。
- AI 综艺工作室：`HANDOFF.md` 唱跳二创各节、`内容生成结果/20261019_dnc1_NETA101唱跳二创试点/`。
