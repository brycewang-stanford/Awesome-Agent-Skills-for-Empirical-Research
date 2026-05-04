---
name: humanize-chinese
description: >
  Detect and humanize AI-generated Chinese text. 20+ rule detection categories plus statistical
  features (sentence-length CV, short-sentence fraction, comma density, perplexity, GLTR, DivEye)
  plus scene-aware LR fusion (rule × 0.2 + LR × 0.8) trained on three scenes: general / academic /
  longform 长文本 (≥1500 字)。Unified CLI: ./humanize {detect,rewrite,academic,style,compare}.
  8 style transforms (casual/zhihu/xiaohongshu/wechat/academic/literary/weibo/novel)。
  Multi-paragraph rewriting (paragraph length CV、跨段 trigram 重复) plus best-of-N humanize
  (默认 N=10 取最低 LR)。165 replacement patterns + CiLin 同义词词林 38873 with collision blacklist。
  Academic paper AIGC reduction for CNKI/VIP/Wanfang (知网/维普/万方 AIGC 检测降重)。
  Pure Python, no dependencies, offline。v5.0.0 — HC3 fused 准确率 95%、学术 hero 100→35 (-65)、
  工作汇报 96→13 (-83)、长篇博客 96→41 (-55)。
  Use when user says: "去AI味", "降AIGC", "人性化文本", "humanize chinese", "AI检测", "AIGC降重",
  "去除AI痕迹", "文本改写", "论文降重", "知网检测", "维普检测", "AI写作检测", "让文字更自然",
  "detect AI text", "humanize text", "reduce AIGC score", "make text human-like",
  "去ai化", "改成人话", "去机器味", "降低AI率", "过AIGC检测", "长文本改写", "小说改写"
allowed-tools:
  - Read
  - Write
  - Edit
  - exec
---

# Humanize Chinese AI Text v5.0

检测和改写中文 AI 生成文本的完整工具链。可独立运行（统一 CLI 或独立脚本），也可作为 LLM prompt 指南使用。

**v5.0 亮点：** scene-aware 三路 LR 融合 (general / academic / longform)；HC3 fused 准确率 95%；新增 `--scene novel/auto` 长文本场景；新增 `--style novel` 长篇叙事；`--best-of-n N` (默认 10) 多次 humanize 取最低 LR；段落级信号 (paragraph length CV / 跨段 trigram 重复) + 反制改写。

## CLI Tools

### 统一 CLI（推荐）

```bash
./humanize detect 文本.txt -v                              # 检测 + 详细
./humanize detect 章节.txt --scene novel                   # 长文本/小说显式 scene
./humanize detect 稿件.txt --scene auto                    # 按长度自动切 (≥1500 走 longform LR)
./humanize rewrite 文本.txt -o 改后.txt                    # 改写（默认 best-of-10）
./humanize rewrite 文本.txt -o 改后.txt --best-of-n 5      # 自调 best-of-N
./humanize rewrite 文本.txt -o 改后.txt --quick            # 快速模式（跳统计/best-of）
./humanize academic 论文.txt -o 改后.txt --compare          # 学术降重 + 双评分对比
./humanize style 章节.txt --style novel                    # 长篇叙事专属 (剔除 AI prompt artifact + markdown headers)
./humanize style 文本.txt --style xiaohongshu              # 风格转换
./humanize compare 文本.txt -a                              # 前后对比
```

### 独立脚本形式（等价）

所有脚本在 `scripts/` 目录下，纯 Python，无依赖。

```bash
# 检测 AI 模式（20+ 规则维度 + 8 统计特征，0-100 分）
python scripts/detect_cn.py text.txt
python scripts/detect_cn.py text.txt -v          # 详细 + 最可疑句子
python scripts/detect_cn.py text.txt -s           # 仅评分
python scripts/detect_cn.py text.txt -j           # JSON 输出

# 改写（默认 best-of-10，scene-aware）
python scripts/humanize_cn.py text.txt -o clean.txt
python scripts/humanize_cn.py text.txt --scene social -a   # 社交 + 激进
python scripts/humanize_cn.py text.txt --quick             # 18× 速度，纯替换
python scripts/humanize_cn.py text.txt --cilin             # 启用 CiLin 同义词扩展

# 风格转换（先自动 humanize 再套风格）
python scripts/style_cn.py text.txt --style zhihu -o out.txt

# 前后对比
python scripts/compare_cn.py text.txt --scene tech -a

# 学术论文 AIGC 降重（10 学术维度 + scene-aware academic LR + 双评分）
python scripts/academic_cn.py paper.txt -o clean.txt --compare
python scripts/academic_cn.py paper.txt -o clean.txt -a --compare  # 激进
python scripts/academic_cn.py paper.txt -o clean.txt --quick       # 快速模式
```

### 评分标准

| 分数 | 等级 | 含义 |
|------|------|------|
| 0-24 | LOW | 基本像人写的 |
| 25-49 | MEDIUM | 有些 AI 痕迹 |
| 50-74 | HIGH | 大概率 AI 生成 |
| 75-100 | VERY HIGH | 几乎确定是 AI |

### 参数速查

| 参数 | 说明 |
|------|------|
| `-v` | 详细模式，显示可疑句子 |
| `-s` | 仅评分 |
| `-j` | JSON 输出 |
| `-o` | 输出文件 |
| `-a` | 激进模式 |
| `--seed N` | 固定随机种子 |
| `--scene` | general / academic / novel / auto（detect_cn）—— auto 按 ≥1500 字切 longform LR |
| `--style` | casual / zhihu / xiaohongshu / wechat / academic / literary / weibo / **novel** |
| `--best-of-n N` | humanize N 次取 LR 最低（默认 10） |
| `--compare` | 前后对比（学术双评分） |
| `--quick` | 快速模式（跳过统计优化 + best-of，18× 速度） |
| `--cilin` | 启用 CiLin 同义词扩展（humanize，38873 词，含碰撞 blacklist） |
| `--no-humanize` | style 转换前不先去 AI 词 |
| `--rule-only` | detect 只用规则层（跳 LR 融合） |

### 工作流

```bash
# 1. 检测
./humanize detect document.txt -v
# 2. 改写 + 对比
./humanize compare document.txt -a -o clean.txt
# 3. 验证
./humanize detect clean.txt -s
# 4. 可选：转风格
./humanize style clean.txt --style zhihu -o final.txt
```

### HC3-Chinese 基准测试

阈值基于 [HC3-Chinese](https://github.com/Hello-SimpleAI/chatgpt-comparison-detection) 300+300 人类/AI 样本的 Cohen's d 校准，scene-aware LR 在 500+500 训练：

- 句长变异系数 CV: d = 1.22（最强单信号）
- 短句占比 (< 10 字): d = 1.21
- 段落长度 CV: d = -1.49（v5 长文本新信号）
- 段内句长 CV: d = -2.08（v5 长文本最强信号）
- 跨段 trigram 重复: d = +1.13（v5 长文本新信号）
- 困惑度: d = 0.47
- GLTR top-10 bucket: d = 0.44
- DivEye skew / kurt: d = 0.41 / 0.29
- 逗号密度: d = -0.47

**v5.0 100 样本回归测试 (HC3 fused)**：95% 正确分离率 / 55.0 分差距 / +40.5 平均降幅 / 100% 段落保留 / 0 grammar defect。

**长文本 170 样本回归 (longform benchmark)**：gap 51.4 / avg delta +25.1 / 段留 98.8%。By genre：academic +13.8 / news +18.8 / blog +36.3 / novel +19.5 / review +31.8。

**Hero 样本**（best-of-10, seed=42）：academic 100→35 (-65) / 通用 100→35 (-65) / 小红书 100→41 (-59) / 长篇博客 96→41 (-55) / 工作汇报 96→13 (-83)。

---

## LLM 直接使用指南

当用户要求"去 AI 味"、"降 AIGC"、"人性化文本"、"改成人话"时，如果无法运行 CLI 工具，按以下流程手动处理。

### 第一步：检测 AI 写作模式

扫描文本中的以下模式，按严重程度分类：

#### 🔴 高危模式（一眼就能看出是 AI）

**三段式套路：**
- 首先…其次…最后
- 一方面…另一方面
- 第一…第二…第三

**机械连接词：**
值得注意的是、综上所述、不难发现、总而言之、与此同时、由此可见、不仅如此、换句话说、更重要的是、不可否认、显而易见、不言而喻、归根结底

**空洞宏大词：**
赋能、闭环、数字化转型、协同增效、降本增效、深度融合、全方位、多维度、系统性、高质量发展、新质生产力

#### 🟠 中危模式

**AI 高频词：** 助力、彰显、凸显、底层逻辑、抓手、触达、沉淀、复盘、迭代、破圈、颠覆

**填充废话：** 值得一提的是、众所周知、毫无疑问、具体来说、简而言之

**模板句式：**
- 随着…的不断发展
- 在当今…时代
- 在…的背景下
- 作为…的重要组成部分
- 这不仅…更是…

**平衡论述套话：** 虽然…但是…同时、既有…也有…更有

#### 🟡 低危模式

- 犹豫语过多（在一定程度上、某种程度上 出现 >5 次）
- 列举成瘾（动辄①②③④⑤）
- 标点滥用（大量分号、破折号）
- 修辞堆砌（排比对偶过多）

#### ⚪ 风格信号

- 段落长度高度一致
- 句子长度单调
- 情感表达平淡
- 开头方式重复
- 信息熵低（用词可预测）

### 第二步：改写策略

按以下顺序处理：

**1. 砍掉三段式**
把"首先…其次…最后"打散，用自然过渡代替。不是每个论点都要编号。

**2. 替换 AI 套话**
- 综上所述 → 总之 / 说到底 / （直接删掉）
- 值得注意的是 → （直接删掉，后面的话自己能说清楚）
- 赋能 → 帮助 / 支持 / 提升
- 数字化转型 → 信息化改造 / 技术升级
- 不难发现 → 可以看到 / （删掉）
- 助力 → 帮 / 推动

**3. 句式重组**
- 过短的句子合并（"他很累。他决定休息。" → "他累了，干脆歇会儿。"）
- 过长的句子拆开（在"但是""不过""同时"等转折处断开）
- 打破均匀节奏（长短句交替，不要每句差不多长）

**4. 减少重复用词**
同一个词出现 3 次以上就换同义词。比如"进行"可以换成"做""搞""开展""着手"。

**5. 注入人味**
- 加一两句口语化表达（场景允许的话）
- 用具体的例子代替抽象概括
- 偶尔加个反问或感叹
- 不要每段都总分总结构

**6. 段落节奏**
打破每段差不多长的格局。有的段落 2 句话，有的 5 句话，像人写东西时自然的长短变化。

### 第三步：学术论文特殊处理

当文本是学术论文时，改写规则不同——不能口语化，要保持学术严谨性：

**学术专用检测维度：**
1. AI 学术措辞（"本文旨在""具有重要意义""进行了深入分析"）
2. 被动句式过度（"被广泛应用""被认为是"）
3. 段落结构过于整齐（每段总-分-总）
4. 连接词密度异常
5. 同义表达匮乏（"研究"出现 8 次）
6. 引用整合度低（每个引用都是"XX（2020）指出…"）
7. 数据论述模板化（"从表中可以看出"）
8. 过度列举（①②③④ 频繁出现）
9. 结论过于圆满（只说好不说局限）
10. 语气过于确定（"必然""毫无疑问"）

**学术改写策略：**

- **替换 AI 学术套话（保持学术性）：**
  - 本文旨在 → 本文尝试 / 本研究关注
  - 具有重要意义 → 值得关注 / 有一定参考价值
  - 研究表明 → 前人研究发现 / 已有文献显示 / 笔者观察到
  - 进行了深入分析 → 做了初步探讨 / 展开了讨论
  - 取得了显著成效 → 产生了一定效果 / 初见成效

- **减少被动句：**
  - 被广泛应用 → 得到较多运用 / 在多个领域有所应用
  - 被认为是 → 通常被看作 / 一般认为

- **注入学术犹豫语（hedging）：**
  在过于绝对的判断前加"可能""在一定程度上""就目前而言""初步来看"

- **增强作者主体性：**
  - 研究表明 → 笔者认为 / 本研究发现
  - 可以认为 → 笔者倾向于认为

- **补充局限性：**
  如果结论段没有提到局限，补一句"当然，本研究也存在一定局限…"

- **打破结构均匀度：**
  调整段落长度，避免每段都一样。合并过短的段落，拆分过长的。

### 第四步：验证

改写完成后，用 CLI 工具验证效果：

```bash
./humanize detect output.txt -s
```

目标（基于 v5.0 fused 检测器，best-of-10 humanize）：
- 通用文本降到 35 分以下（LOW 区间）
- 学术论文降到 35 分以下（学术专用 + 通用评分均低）
- 长篇博客/小说（≥1500 字）降到 41 分左右（MEDIUM）
- 真实 ChatGPT 短输出 baseline 通常已在 5-25 分，改写后再降 3-10 分
- 刻板化 AI 样板文 (论文模板/八股) 可以看到 60-83 分降幅

注：v5.0 fused 评分融合了 LR ensemble (rule × 0.2 + LR × 0.8)，相同文本的分数会比 v3.x rule-only 更准。`--rule-only` 可降级到纯规则视图。

---

## 配置说明

所有检测模式和替换规则在 `scripts/patterns_cn.json`，可自定义：
- 添加新 AI 词汇
- 调整权重
- 增加替换规则
- 修改正则匹配

## 外部配置字段

```
critical_patterns    — 高权重检测（三段式、连接词、空洞词）
high_signal_patterns — 中权重检测（AI 高频词、模板句）
replacements         — 替换词库（正则 + 纯文本）
academic_patterns    — 学术专用检测与替换
scoring              — 权重和阈值配置
```
