<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/luwill/research-skills
  项目名称: research-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Content & Style Rules

Guidelines for slide deck content quality and style consistency.

## Content Rules

### 1. Respect Reader Attention
- Each slide should communicate ONE main idea
- Remove redundant information
- Prioritize clarity over comprehensiveness

### 2. Data Traceability
- All statistics must include source attribution
- Cite sources directly on slides with data
- Use specific numbers over vague claims

### 3. Self-Contained Prompts
- Every detail must be in the image prompt
- No external references (e.g., "like slide 2")
- Include all colors, layouts, and content explicitly

### 4. No Placeholders
- Every element must be fully specified
- No "[insert data here]" or "TBD"
- All text content finalized before generation

## Style Rules

### 1. Narrative Headlines
Headlines tell the story, not label the content.

| Bad | Good |
|-----|------|
| "Key Statistics" | "Usage doubled in 6 months" |
| "Our Solution" | "One platform replaces five tools" |
| "Benefits" | "Teams save 10 hours weekly" |

### 2. Avoid AI Clichés
Remove these patterns:
- "Dive into", "explore", "journey"
- "Let's look at", "let me show you"
- "Exciting", "amazing", "revolutionary"
- "In conclusion", "to summarize"

### 3. Meaningful Back Cover
Not just "Thank you" or "Questions?"

Include one of:
- Clear call-to-action
- Memorable key takeaway
- Thought-provoking closing statement
- Contact information with purpose

### 4. Consistent Visual Language
Throughout the deck:
- Same icon style
- Same color usage patterns
- Same layout grid system
- Same typography hierarchy

## Slide Structure

| Position | Type | Purpose |
|----------|------|---------|
| 1 | Cover | Title, visual hook, topic introduction |
| 2 to N-1 | Content | Key points, data, explanations |
| N | Back Cover | Summary, call-to-action, memorable close |

## Key Specifications

| Specification | Value |
|---------------|-------|
| Aspect Ratio | 16:9 (landscape) |
| Slide Count | Dynamic based on content |
| Required Slides | Cover + Back Cover minimum |
| Footers | None (no slide numbers, logos) |
| Language Priority | `--lang` → source language → ask user |
| Tone | Direct, confident (avoid AI phrases) |

## Style Quick Reference

| Style | Visual Summary |
|-------|----------------|
| `sketch-notes` | Hand-drawn, warm off-white, conceptual icons |
| `blueprint` | Technical schematics, grid texture, blue tones |
| `bold-editorial` | High contrast, dark backgrounds, magazine impact |
| `vector-illustration` | Flat vector, black outlines, retro colors |
| `minimal` | Maximum whitespace, single accent, zen-like |
| `storytelling` | Full-bleed imagery, cinematic, emotional |
| `warm` | Soft gradients, rounded shapes, wellness palette |
| `notion` | Dashboard aesthetic, clean data viz, SaaS-inspired |
| `corporate` | Navy/gold, structured layouts, business polish |
| `playful` | Vibrant coral/teal/yellow, dynamic, energetic |

Full style specifications: `references/styles/<style>.md`
