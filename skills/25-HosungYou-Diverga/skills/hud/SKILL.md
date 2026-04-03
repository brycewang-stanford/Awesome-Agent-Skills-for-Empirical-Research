---
name: hud
description: |
  Diverga HUD (Heads-Up Display) management skill.
  Configure and manage the research project statusline display.
  Supports multiple presets: research, checkpoint, memory, minimal.
  Triggers: "hud", "statusline", "display settings"
version: "12.0.1"
---

# Diverga HUD Skill

Configure and manage the Diverga HUD (Heads-Up Display) statusline.

## Overview

The Diverga HUD provides a real-time statusline in your terminal showing:
- Current research project name
- Research stage progress
- Checkpoint completion status
- Memory/context health

The HUD is **independent** of oh-my-claudecode and works as a standalone component.

## Commands

### Status

```
/diverga-hud status
```

Show current HUD configuration and status:
- Whether HUD is enabled
- Current preset
- Project name and stage
- Checkpoint progress
- Memory health

### Presets

```
/diverga-hud preset <preset_name>
```

Change HUD display preset:

| Preset | Description | Example Output |
|--------|-------------|----------------|
| `research` | Standard view (default) | `🔬 AI-Ethics │ Stage: foundation │ ●●○○○ (2/11) │ 🧠 95%` |
| `checkpoint` | Detailed checkpoints | Multi-line with checkpoint details |
| `memory` | Memory focus | Shows context and memory health |
| `minimal` | Stage only | `🔬 foundation` |

### Enable/Disable

```
/diverga-hud enable
/diverga-hud disable
```

Turn HUD display on or off.

### Setup

```
/diverga-hud setup
```

Install or repair HUD statusline integration:
1. Creates `~/.claude/hud/diverga-hud.mjs`
2. Updates `~/.claude/settings.json` with statusLine command
3. Initializes `.research/hud-state.json` in current project

## Installation

### Automatic (Recommended)

Run `/diverga-hud setup` to automatically configure HUD.

### Manual

1. Ensure the HUD script exists at `~/.claude/hud/diverga-hud.mjs`

2. Add to `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "node ~/.claude/hud/diverga-hud.mjs"
  }
}
```

3. Restart Claude Code for changes to take effect.

## State Files

### HUD State

**Location**: `.research/hud-state.json`

```json
{
  "version": "1.0.0",
  "enabled": true,
  "preset": "research",
  "last_updated": "2026-02-04T18:45:00Z",
  "cache": {
    "project_name": "AI-Ethics-HR",
    "current_stage": "foundation",
    "checkpoints_completed": 2,
    "checkpoints_total": 11,
    "memory_health": 95
  }
}
```

### Project State

HUD reads from:
- `.research/project-state.yaml` - Project metadata
- `.research/checkpoints.yaml` - Checkpoint completion status

## Protocol

When `/diverga-hud` is invoked:

1. **status** command:
   - Read `.research/hud-state.json`
   - Display current configuration
   - Show live project status

2. **preset** command:
   - Validate preset name (research, checkpoint, memory, minimal)
   - Update `.research/hud-state.json`
   - Confirm change

3. **enable/disable** command:
   - Update `.research/hud-state.json` enabled flag
   - Confirm change

4. **setup** command:
   - Check if `~/.claude/hud/` exists, create if not
   - Copy/update `diverga-hud.mjs` script
   - Update `~/.claude/settings.json` statusLine
   - Initialize `.research/hud-state.json`
   - Display success message

## Error Handling

| Error | Response |
|-------|----------|
| No project found | "No Diverga project detected. Initialize with `/diverga-setup`" |
| Invalid preset | "Invalid preset. Available: research, checkpoint, memory, minimal" |
| Settings write fail | "Could not update settings.json. Check file permissions." |

## HUD Components

### Progress Bar

```
●●○○○○○○○○○ (2/11)
```

- `●` = Completed checkpoint (green)
- `○` = Pending checkpoint (dim)
- `(X/Y)` = Completed/Total count

### Memory Health

```
🧠 95%
```

Color coding:
- Green: 70%+ (healthy)
- Yellow: 40-70% (moderate)
- Red: <40% (needs attention)

### Stage Indicator

Available stages:
- `foundation` - Research question, paradigm
- `theory` - Theoretical framework
- `methodology` - Research design
- `design` - Database, sampling
- `execution` - Data collection, screening
- `analysis` - Data analysis
- `validation` - Quality, peer review

## Examples

### Check Status

```
User: /diverga-hud status

Claude: 📊 **Diverga HUD Status**

| Setting | Value |
|---------|-------|
| Enabled | ✅ Yes |
| Preset | research |
| Project | AI-Ethics-HR |
| Stage | foundation |
| Checkpoints | 2/11 (18%) |
| Memory Health | 95% |

HUD is active and displaying in statusline.
```

### Change Preset

```
User: /diverga-hud preset minimal

Claude: ✅ HUD preset changed to **minimal**.

New display: `🔬 foundation`

To switch back: `/diverga-hud preset research`
```

### Setup HUD

```
User: /diverga-hud setup

Claude: 🔧 **Setting up Diverga HUD...**

1. ✅ Created ~/.claude/hud/diverga-hud.mjs
2. ✅ Updated ~/.claude/settings.json
3. ✅ Initialized .research/hud-state.json

🎉 HUD setup complete!

**Please restart Claude Code** to activate the statusline.

Your HUD will display:
`🔬 AI-Ethics-HR │ Stage: foundation │ ●●○○○○○○○○○ (2/11) │ 🧠 95%`
```

## Troubleshooting

### HUD Not Showing

1. Check if script exists:
   ```bash
   ls -la ~/.claude/hud/diverga-hud.mjs
   ```

2. Check settings.json:
   ```bash
   cat ~/.claude/settings.json | grep statusLine
   ```

3. Test script manually:
   ```bash
   node ~/.claude/hud/diverga-hud.mjs
   ```

4. Ensure you're in a Diverga project directory (has `.research/` folder)

### Stale Data

Run refresh to update cache:
```bash
/diverga-hud status
```

Or manually trigger cache rebuild by editing `.research/hud-state.json`.

## Integration with Diverga

The HUD automatically updates when:
- Checkpoints are completed
- Stage advances
- Project state changes

For manual sync, use `/diverga-memory sync`.
