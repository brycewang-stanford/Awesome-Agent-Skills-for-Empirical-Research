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

# Slide Modification Guide

Workflows for modifying individual slides after initial generation.

## Edit Single Slide

Regenerate a specific slide with modified content:

1. Identify slide to edit (e.g., `03-slide-key-findings.png`)
2. Update prompt in `prompts/03-slide-key-findings.md`
3. If content changes significantly, update slug in filename
4. Regenerate image using same session ID
5. Regenerate PPTX and PDF

## Add New Slide

Insert a new slide at specified position:

1. Specify insertion position (e.g., after slide 3)
2. Create new prompt with appropriate slug (e.g., `04-slide-new-section.md`)
3. Generate new slide image
4. **Renumber files**: All subsequent slides increment NN by 1
   - `04-slide-conclusion.png` → `05-slide-conclusion.png`
   - Slugs remain unchanged
5. Update `outline.md` with new slide entry
6. Regenerate PPTX and PDF

## Delete Slide

Remove a slide and renumber:

1. Identify slide to delete (e.g., `03-slide-key-findings.png`)
2. Remove image file and prompt file
3. **Renumber files**: All subsequent slides decrement NN by 1
   - `04-slide-conclusion.png` → `03-slide-conclusion.png`
   - Slugs remain unchanged
4. Update `outline.md` to remove slide entry
5. Regenerate PPTX and PDF

## File Naming Convention

Files use meaningful slugs for better readability:

```
NN-slide-[slug].png
NN-slide-[slug].md (in prompts/)
```

Examples:
- `01-slide-cover.png`
- `02-slide-problem-statement.png`
- `03-slide-key-findings.png`
- `04-slide-back-cover.png`

## Slug Rules

| Rule | Description |
|------|-------------|
| Format | Kebab-case (lowercase, hyphens) |
| Source | Derived from slide title/content |
| Uniqueness | Must be unique within the deck |
| Updates | Change slug when content changes significantly |

## Renumbering Rules

| Scenario | Action |
|----------|--------|
| Add slide | Increment NN for all subsequent slides |
| Delete slide | Decrement NN for all subsequent slides |
| Reorder slides | Update NN to match new positions |
| Edit slide | NN unchanged, update slug if needed |

**Important**: Slugs remain unchanged during renumbering. Only the NN prefix changes.

## Post-Modification Checklist

After any modification:

- [ ] Image file renamed/created correctly
- [ ] Prompt file renamed/created correctly
- [ ] Subsequent files renumbered (if add/delete)
- [ ] `outline.md` updated to reflect changes
- [ ] PPTX regenerated
- [ ] PDF regenerated
- [ ] Slide count in outline header updated
