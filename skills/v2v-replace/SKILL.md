---
name: v2v-replace
description: 视频换人（V2V）：已有一条原片，只把里面的人物换成指定角色（可连背景一起换），舞蹈编排、节拍、站位、机位、运镜全部继承原片。用于复刻舞蹈 / 唱跳二创 / 「把视频里的人换成 XX」。没有原片、或要改写动作时不用。
---

# 视频换人（V2V）

原片管动作，角色图管身份，场景图管背景；prompt 只负责说清这三份素材各管什么。一条原片 → 一条换人成片。

不归本 skill：没有原片只有概念 → 所在 Space 的复刻 / 分镜流程；要按角色特质改写动作 → `video-remake-pipeline`；锁首尾 pose 的逐拍重绘 → 所在 Space 的动作底稿协议。

## 步骤

1. **登记原片**。原片落在所在 Space 的 restricted 目录，同目录写来源（URL、作者、发布日期、抓取日期、授权分级）。原片、原曲和任何含原片画面的对照文件都是 `restricted`，不进发布目录。
   完成：原片文件可被 `ffprobe` 读出，来源四项齐全。

2. **切片**。选单人或固定人数、全身、固定机位或少切镜的窗口，≤15s，起止点选清楚的站姿。
   ```bash
   ffmpeg -ss <t0> -i src.mp4 -t <len> -an -vf "fps=24,scale=-2:720" -c:v libx264 -crf 20 clip.mp4
   ```
   水印、UP 主名、逐句歌词在切片里先 `delogo` / 裁掉；切片像素数 ≥ 407,696（H3 下限，720p 竖屏满足）。
   完成：切片无音轨、无可读文字，时长 ≤15s。

3. **参考包**。≤3 张图，一张图只管一件事：角色（脸 + 全身，一张三视图也可以）、场景（只在换背景时给）、可选脸部特写。图压成 720p JPEG 再传。
   完成：每张图在 prompt 里都有唯一职责，没有职责的图删掉。

4. **写 prompt**。照 [references/prompt-template.md](references/prompt-template.md) 填空，总长 ≤300 字。
   完成：模板九行齐全；角色外观描述不超过一句。

5. **过审探针**。同一 prompt、同一参考，先跑 4s / 480p 一次。被拒不扣费；拒审或超时按 [references/models.md](references/models.md) 处理，不在同一被拒 prompt 上堆形容词。
   完成：探针出片，且第 6 步的 `sync_check.py` 判 PASS。

6. **正式生成 + 验收**。`duration` 填切片长度，一次出 1 条，有 ✗ 再出第 2 条（换 seed 或删减 prompt）。逐项验收：
   - 动作同步：`python3 scripts/sync_check.py clip.mp4 out.mp4` 判 PASS（best r ≥ 0.7、|lag| ≤ 1 帧），2s 窗口无 ✗。
   - 身份：1s 步进抽帧，角色五要素（发型、发色、脸、服装、鞋）全程一致。
   - 原片残留：原舞者的脸、发型、服装一处不在；无文字、字幕、水印、第二个人、镜中倒影。
   - 解码：`ffmpeg -v error -i out.mp4 -f null -` 无错。
   完成：四项都有证据文件（脚本输出、抽帧对照图）。

7. **记录**。在项目目录写一段：
   ```yaml
   v2v:
     source: {path, url, author, date, license: restricted}
     clip: {t0, len, path}
     refs: {角色: path, 场景: path}
     model: seedance-2-0-fast
     params: {duration, resolution, ratio}
     prompt: prompts/<name>.txt
     task: <taskRunId>
     cost: <USD>
     sync: {r, lag_frames, windows: "✓✓✓△"}
     check: {身份:, 残留:, 文字:, 解码:}
     verdict: pass | 返修 | 否决
   ```
   完成：任何人能用这段记录重跑同一请求。

## 参考

- [references/prompt-template.md](references/prompt-template.md)：模板、每行的作用、出了问题改哪一行。
- [references/models.md](references/models.md)：模型选择、参数、审核与故障。
- `scripts/sync_check.py`：动作同步验收（需要 numpy；`--audio` 落拍报告另需 librosa）。
