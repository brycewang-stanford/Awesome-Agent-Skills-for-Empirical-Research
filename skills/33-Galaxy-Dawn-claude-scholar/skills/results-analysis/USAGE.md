# Results Analysis Usage

本技能用于生成 **strict analysis bundle**，不是写论文 Results 草稿。

## 默认产物

```text
analysis-output/
├── analysis-report.md
├── stats-appendix.md
├── figure-catalog.md
└── figures/
```

## 典型调用路径

```text
/analyze-results (Command)
    ↓
results-analysis (Skill)
    ↓
results-report (Skill, optional follow-up)
```

## 适用场景

- 多模型对比，需要严谨统计
- 多 seed / 多 subject / 多 fold 结果汇总
- 需要真实科研图，而不是只给 figure specs
- 需要为后续 `results-report` 提供可信分析底座

## 推荐工作流

### 1. 准备输入

至少整理出以下之一：
- seed-level `csv/json`
- 每个实验的日志或目录
- baseline 与 ablation 的对应结果
- 训练曲线 / evaluation 曲线 / confusion 或 breakdown 数据

### 2. 运行 `/analyze-results`

```bash
/analyze-results path/to/results full
```

### 3. 期望输出

#### `analysis-report.md`
- 本轮分析回答的问题
- 关键发现
- 哪些比较成立 / 不成立
- 主要 caveats
- 哪些发现值得进一步写成完整实验报告

#### `stats-appendix.md`
- `mean ± std`
- `95% CI`
- significance tests
- effect sizes
- multiple-comparison correction
- assumptions / fallback tests
- blockers

#### `figure-catalog.md`
- 每张图的文件名
- 图用途
- 数据来源
- caption 必须包含的信息
- 图后 interpretation checklist

#### `figures/`
- 真实科研图，优先 PDF/PNG 等可复用格式

## 最低质量要求

### 统计
- 不能只报 best score
- 不能只报 p-value
- 不能混淆 std 和 sem
- 有多组比较时要说明 correction
- 假设不满足时必须切换或说明 non-parametric test

### 图表
- 有数据就要画真实图
- 每个主图都要有误差条或不确定性信息（如适用）
- 图必须有明确用途，不能只是“好看”
- 图后必须说明看到了什么、意味着什么

### 解释
- 先写 observation，再写 interpretation，最后写 implication
- 若无法支持 causal/mechanistic claim，必须保守表述

## 与 `results-report` 的关系

- `results-analysis`：负责严格统计、图表、证据核查
- `results-report`：负责完整实验总结报告、叙事、复盘与决策

推荐顺序：

```text
experiment artifacts
    ↓
results-analysis
    ↓
strict analysis bundle
    ↓
results-report
```

## 边界情况

### 输入不完整
若缺少 seed-level 数据、日志或可比 baseline：
- 明确列出缺失项
- 降级分析强度
- 不生成超出证据边界的结论

### 无法出图
如果数据结构不支持直接画图：
- 先说明原因
- 指出还需要哪些字段
- 不要拿“visualization specs”替代真实图作为完成态

## 参考阅读

- `references/statistical-reporting.md`
- `references/figure-interpretation.md`
- `references/analysis-depth.md`
- `references/common-pitfalls.md`
