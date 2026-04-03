<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/Orchestra-Research/AI-Research-SKILLs
  项目名称: AI-Research-SKILLs
  开源协议: Apache License 2.0
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Progress Reporting: Research Presentations

When the research produces something worth sharing, create a compelling presentation — not a status dump, but a research story with visuals.

## When to Report

You decide when progress is meaningful enough to report. Consider reporting:

- After an outer loop reflection that identified a significant pattern
- When the optimization trajectory shows clear, sustained improvement
- After a pivot — explain why the direction changed
- Before requesting human input on a major decision
- When concluding the research, before paper writing

Maximum frequency: once per /loop tick or heartbeat cycle. Minimum: whenever you have something a human would find interesting.

## What Makes a Good Research Presentation

A good progress report reads like a research talk, not a database query. It should:

1. **Tell a story**: why we started, what we tried, what we found, what it means
2. **Show, don't just tell**: include plots, tables, comparisons — not just text
3. **Be selective**: highlight the interesting findings, don't exhaustively list every experiment
4. **End with direction**: what happens next and why

## Recommended Sections

Adapt these to what's compelling from your current research. Skip sections that aren't relevant. Add sections the research demands.

### 1. Research Question and Motivation
- What are we investigating and why does it matter?
- One paragraph, accessible to someone unfamiliar with the project

### 2. Approach
- What's our method? What are we optimizing?
- The two-loop architecture in one sentence

### 3. Optimization Trajectory (The Karpathy Plot)
- X-axis: experiment number or wall-clock time
- Y-axis: proxy metric value
- Show baseline as a horizontal line
- Annotate significant jumps with what change caused them
- This is often the most compelling visual — include it whenever possible

### 4. Key Findings
- The 2-3 most significant results with supporting evidence
- Include plots, metric tables, comparison charts
- Explain WHY results are significant, not just WHAT they are

### 5. What We Tried (Decision Map)
- A selective view of the hypothesis tree
- Focus on the reasoning: why each direction was chosen, what it taught us
- Include both successes and informative failures

### 6. Current Understanding
- The findings.md narrative, but presented compellingly
- What's our best explanation for the patterns we see?

### 7. Next Steps
- What experiments are planned and why
- What questions remain open
- Any decisions that need human input

## The Optimization Trajectory Plot

This is the signature visual of autoresearch — a chart showing metric improvement over experiments.

Minimal implementation (SVG-based, no dependencies):

```python
def generate_trajectory_svg(trajectory_data, width=800, height=400):
    """Generate an SVG optimization trajectory chart.

    trajectory_data: list of {"run": int, "metric": float, "label": str}
    """
    if not trajectory_data:
        return "<p>No experiments yet.</p>"

    metrics = [d["metric"] for d in trajectory_data]
    min_m, max_m = min(metrics), max(metrics)
    margin = (max_m - min_m) * 0.1 or 0.1
    y_min, y_max = min_m - margin, max_m + margin

    padding = 60
    plot_w = width - 2 * padding
    plot_h = height - 2 * padding
    n = len(trajectory_data)

    def x_pos(i):
        return padding + (i / max(n - 1, 1)) * plot_w

    def y_pos(v):
        return padding + plot_h - ((v - y_min) / (y_max - y_min)) * plot_h

    # Build SVG
    svg = f'<svg width="{width}" height="{height}" xmlns="http://www.w3.org/2000/svg">'
    svg += f'<rect width="{width}" height="{height}" fill="#1a1a2e" rx="8"/>'

    # Grid lines
    for i in range(5):
        y = padding + i * plot_h / 4
        val = y_max - i * (y_max - y_min) / 4
        svg += f'<line x1="{padding}" y1="{y}" x2="{width-padding}" y2="{y}" stroke="#333" stroke-dasharray="4"/>'
        svg += f'<text x="{padding-8}" y="{y+4}" fill="#888" text-anchor="end" font-size="11">{val:.3f}</text>'

    # Baseline line
    baseline = trajectory_data[0]["metric"]
    by = y_pos(baseline)
    svg += f'<line x1="{padding}" y1="{by}" x2="{width-padding}" y2="{by}" stroke="#ff6b6b" stroke-dasharray="6" opacity="0.7"/>'
    svg += f'<text x="{width-padding+5}" y="{by+4}" fill="#ff6b6b" font-size="10">baseline</text>'

    # Data line
    points = " ".join(f"{x_pos(i)},{y_pos(d['metric'])}" for i, d in enumerate(trajectory_data))
    svg += f'<polyline points="{points}" fill="none" stroke="#4ecdc4" stroke-width="2"/>'

    # Data points
    for i, d in enumerate(trajectory_data):
        cx, cy = x_pos(i), y_pos(d["metric"])
        svg += f'<circle cx="{cx}" cy="{cy}" r="4" fill="#4ecdc4"/>'

    # Title
    svg += f'<text x="{width/2}" y="24" fill="#eee" text-anchor="middle" font-size="14" font-weight="bold">Optimization Trajectory</text>'
    svg += f'<text x="{width/2}" y="{height-10}" fill="#888" text-anchor="middle" font-size="11">Experiment Run</text>'
    svg += '</svg>'
    return svg
```

Embed the SVG output directly in the HTML report. Annotate significant jumps with brief labels.

## HTML Presentation Template

Use [templates/progress-presentation.html](../templates/progress-presentation.html) as a starting point. It provides:

- Clean, dark-themed styling suitable for research presentations
- Responsive layout
- Section scaffolding matching the recommended structure
- Placeholder for the trajectory chart

Replace placeholder content with your actual research data. Add, remove, or rearrange sections as the research demands. The template is a scaffold, not a constraint.

### Claude Code

Generate the HTML, then show it to the human:

```bash
open to_human/progress-001.html
```

### OpenClaw

Generate a PDF version. Options:
- Use Python `weasyprint` to convert HTML to PDF
- Use `matplotlib` to generate plots directly as PDF
- Create a simple markdown → PDF pipeline

Note the PDF path in HEARTBEAT.md so the human knows to look at it.

## Presentation Quality Tips

- **One insight per section** — don't overload
- **Label axes and units** on all plots
- **Use color consistently** — one color for improvements, another for baselines
- **Include confidence intervals** or error bars where meaningful
- **Show the trajectory early** — it's the hook that tells the reader "this is working"
- **End with a clear next step** — the human should know what happens next without asking
