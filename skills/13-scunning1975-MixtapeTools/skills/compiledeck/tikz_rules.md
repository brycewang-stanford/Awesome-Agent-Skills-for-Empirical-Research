# TikZ & Figure Anti-Collision Rules

These rules prevent rendering errors — text on top of arrows, arrows crossing arrows, labels spilling over boxes. The compiler catches none of these. You must catch them yourself. **These rules apply to BOTH TikZ diagrams AND matplotlib/Python figures.**

---

## THE WORKFLOW: Bézier First, Everything Else Second

Every time you create or edit TikZ in a deck, follow this order. Do not skip steps. Do not audit only the slide you just touched — audit the entire deck.

### Pass 0: Cross-slide consistency

Before checking geometry, check continuity. When the same diagram, cycle, or visual element appears on more than one slide:

1. **Colors must match.** If "Inspect" is Slate on slide 31, it must be Slate on slide 32. Grep for repeated node names or labels across frames.
2. **Layout must match.** Same nodes at same positions, same spacing, same font sizes.
3. **Deliberate changes must be the ONLY changes.** If slide 32 adds a red rectangle to highlight the bottleneck, that should be the only difference from slide 31. Nothing else moves, recolors, or resizes.

This catches continuity errors that are invisible when looking at one slide in isolation but obvious when flipping between consecutive slides.

```bash
# Find all frames that share the same node names
grep -n "node.*draft\|node.*compile\|node.*inspect" [file].tex
```

For each group of slides sharing elements, verify color and position consistency.

---

### Pass 1: Find and fix all Bézier curves

```bash
grep -n "bend" [file].tex
```

For EACH curved arrow found:

**Step 1.** Identify the two endpoints and the bend angle.

**Step 2.** Calculate max curve depth:
```
max_depth = (chord_length / 2) × tan(bend_angle / 2)
```

**Step 3.** Calculate safe distance:
```
safe_distance = max_depth + 0.5cm
```

**Step 4.** Check every label near the curve. Any label closer than `safe_distance` to the baseline (in the direction the curve bends) MUST be moved.

**Step 5.** Check every other arrow in the same figure. Does the curve cross any of them? If the curve bends downward and there's a vertical arrow in the middle of the diagram, they WILL cross. Fix: re-route the curve to bend the other direction (`bend right` instead of `bend left`, or vice versa).

### Common bend values for quick reference

| Bend angle | tan(angle/2) | Multiplier for half-chord |
|-----------|-------------|--------------------------|
| 20° | 0.176 | × 0.18 |
| 25° | 0.222 | × 0.22 |
| 30° | 0.268 | × 0.27 |
| 35° | 0.315 | × 0.32 |
| 40° | 0.364 | × 0.36 |
| 45° | 0.414 | × 0.41 |

Example: Arrow across 8.4cm with `bend left=35`:
- Half-chord = 4.2
- Depth = 4.2 × 0.315 = **1.32cm**
- Safe distance = 1.32 + 0.5 = **1.82cm**
- Any label must be at y ≤ -1.82 (not -1.2, not -1.5)

### Pass 2: Gap calculations for labels between nodes

For every label positioned between two nodes:

```
Available gap = (center-to-center distance) - (half-width of node A) - (half-width of node B)
Usable space  = Available gap - 0.6cm (0.3cm padding each side)
```

Estimate label width:

| Font size | Width per character |
|-----------|-------------------|
| `\scriptsize` | 0.10cm |
| `\footnotesize` | 0.12cm |
| `\small` | 0.15cm |
| `\normalsize` | 0.18cm |

Bold: +10%. Monospace: +15%.

If estimated label width > usable space: collision guaranteed. Move the label above/below or shorten it.

### Pass 3: Arrow label positioning

Every arrow label must have a positional keyword:

```latex
% GOOD
\draw[->] (A) -- (B) node[midway, above] {label};

% BAD — label sits ON the arrow
\draw[->] (A) -- (B) node[midway] {label};
```

Horizontal arrows: `above` or `below`.
Vertical arrows: `left` or `right`.
Diagonal: whichever side has more space.

### Pass 4: Labels vs. drawn shapes (the Boundary Rule)

**Problem this solves**: Text placed at hardcoded coordinates that collide with the edge of a circle, rectangle, or filled region. The compiler gives zero warnings for these — they only show up visually.

**The rule**: Every label placed near a drawn geometric shape must have its coordinate verified against the shape's computed boundary. Never place text at a coordinate chosen for aesthetic alignment (e.g., "same y-height as another label") without checking whether that coordinate clears the shape it's near.

**For circles**: `\draw (cx, cy) circle (r);` → boundary extends from `cy - r` to `cy + r`. Any label must be at least **0.4cm** outside the boundary (if external) or at least **0.4cm** inside (if internal).

```
% WRONG — label at y=2.0 sits exactly on boundary of circle with center (4, 0.5) radius 1.5
\draw (4, 0.5) circle (1.5cm);  % top edge at y = 0.5 + 1.5 = 2.0
\node at (4, 2.0) {Sample};     % COLLISION: y = top edge

% RIGHT — label 0.4cm above the top edge
\node at (4, 2.4) {Sample};     % 2.0 + 0.4 = 2.4 ✓
```

**For rectangles / FancyBboxPatch**: bottom-left `(x, y)` with width `w` and height `h` → top edge at `y + h`. Same 0.4cm clearance rule.

**Critical corollary — don't match y-coordinates across different shapes**: If two shapes have different sizes, a single y-coordinate that's safe for one may collide with the other. Always compute boundaries independently for each shape.

**For matplotlib/Python figures**: The same principle applies. When positioning `ax.text()` calls near `FancyBboxPatch` or `Circle` objects, compute the patch boundary and verify clearance. Text with `va='center'` extends roughly half its font height above and below the anchor — account for this.

**Sub-rule: Bézier-first for matplotlib arrows (the arc3 formula).** The TikZ Bézier workflow (Pass 1) has an exact equivalent for matplotlib's `arc3` connectionstyle. You MUST compute curve positions before placing labels — the same "Claude cannot eyeball where a curve passes" rule applies to Python figures.

**Matplotlib arc3 control point formula:**
```python
# For ax.annotate with connectionstyle='arc3,rad=R':
# Start: (x1, y1), End: (x2, y2)
dx, dy = x2 - x1, y2 - y1
cx = (x1 + x2) / 2 + R * dy     # control point x
cy = (y1 + y2) / 2 - R * dx     # control point y
```

**To find where the curve passes at any x-coordinate**, use the quadratic Bézier formula:
```python
B(t) = (1-t)²·P0 + 2(1-t)t·P1 + t²·P2,  t ∈ [0,1]
```
Solve for t at the desired x, then compute y(t). Use numerical sampling if needed.

**Labeling arrows in matplotlib:** Once you know the curve's y-position at the label's x-coordinate, offset the label perpendicular to the curve with a white-background bbox:
```python
# Compute where curve passes at gap midpoint
cx, cy = arc3_control_point(x1, y1, x2, y2, rad)
t_mid = find_t_for_x(gap_mid_x, x1, cx, x2)
curve_y = bezier_y_at_t(t_mid, y1, cy, y2)

# Place label ABOVE the computed curve position
ax.text(gap_mid_x, curve_y + 0.35, label, ha='center', va='bottom',
        bbox=dict(facecolor='white', edgecolor='none', alpha=0.8, pad=1))
```

**Label offset direction:**
- Arrow curves upward → label above (`va='bottom'`)
- Arrow curves downward → label below (`va='top'`)
- Arrow is straight → label above (`va='bottom'`)

**Never guess arrow positions.** Every attempt to place labels by visual intuition or simple offsets from endpoints will fail. The formula is the only reliable method — just as in TikZ.

**Sub-rule: Anchor-based centering of text pairs.** When multiple text elements (title + math, header + body) are placed inside a single container, do NOT use `va='center'` for both at symmetric y-offsets — this fails because multi-line text extends further from its anchor than single-line text, creating visual asymmetry even when coordinates are symmetric.

Instead, **anchor both elements outward from the container's center**:
- Upper element: `va='bottom'` at `center_y + small_gap` (text grows upward)
- Lower element: `va='top'` at `center_y - small_gap` (text grows downward)

This ensures true visual centering regardless of how many lines each element has.

```python
# WRONG — symmetric coordinates but visually asymmetric
title_y = box_mid_y + 0.7   # 2-line title with va='center' → top-heavy
math_y  = box_mid_y - 0.7   # 1-line math with va='center' → too low

# RIGHT — anchor-based, text grows outward from center
ax.text(x, box_mid_y + 0.15, 'Title\nLine 2', va='bottom', ...)  # grows UP
ax.text(x, box_mid_y - 0.15, r'$math$',       va='top', ...)     # grows DOWN
```

### Pass 5: Margin spacing and everything else

**THE MARGIN RULE (mandatory):** Every pair of distinct visual objects — labels, arrows, boxes, axis lines, tick marks, curve endpoints — must have **visible margin space** between them. No object should touch or visually collide with another. Minimum clearances:

| Object pair | Minimum clearance |
|---|---|
| Label ↔ label | 0.3cm |
| Label ↔ axis line | 0.3cm |
| Label ↔ arrow | 0.3cm |
| Arrow origin ↔ box edge | 0.15cm |
| Label ↔ drawn shape boundary | 0.4cm (see Pass 4) |
| Any object ↔ slide edge | 0.5cm |

When two labels would overlap or touch at their intended positions, move one of them — offset it, anchor it differently, or shorten the text. **Never allow two objects to share the same visual space.** This rule catches the most common TikZ errors: labels sitting on axis lines, $\mu$ markers overlapping x-axis descriptions, arrow origins crowding box edges.

Additional checks:
- Multi-line nodes have `align=center`?
- No nodes clipped by slide edges (0.5cm margin)?
- If scaled: nodes scaled too, not just coordinates?
- Arrow colors and stealth sizes consistent?
- No two labels overlap?

### Pass 5b: Plotted curves (normal distributions, arbitrary functions)

**Problem this solves**: Labels, boxes, arrows, and other objects placed near plotted curves (e.g., `\draw plot` with mathematical functions) that overlap because the curve's position was never calculated. TikZ `plot` commands generate curves that the compiler renders but never checks for collisions. You must calculate curve positions yourself.

**The rule**: For every plotted curve, compute its y-value at every x-coordinate where another object exists. Verify clearance.

**For normal/Gaussian curves** of the form `plot ({A*\x}, {B + C*exp(-\x*\x/2)})`:
- Peak is at x=0: `y_peak = B + C`
- At any TikZ x-coordinate X: `x_norm = X / A`, then `y = B + C * exp(-x_norm^2 / 2)`
- Every label, box edge, or arrow within the x-domain of the curve must clear the computed y-value by at least **0.3cm**

**Example**: Curve `plot ({1.5*\x}, {0.3 + 2.0*exp(-\x*\x/2)})`:
- Peak: y = 0.3 + 2.0 = 2.3
- At x=1.5 (one SD): y = 0.3 + 2.0*0.607 = 1.51
- At x=3.0 (two SD): y = 0.3 + 2.0*0.135 = 0.57
- A label at y=3.0 near x=0 clears the peak by 0.7 ✓
- A box with bottom edge at y=3.6 clears the peak by 1.3 ✓

**Common failure**: Setting amplitude too high so the curve peak penetrates nearby boxes, or placing labels at y-positions that look clear in your head but sit inside the curve. Always compute, never eyeball.

### Pass 6: Open the PDF and visually confirm

---

## REFERENCE: The Individual Rules

### Rule 1: Gap Calculation (see Pass 2 above)

Worked example — the "via the terminal" problem:
- Two boxes: left at x=0 (5cm wide), right at x=6.5 (5cm wide)
- Edge-to-edge gap: 4.0 - 2.5 = 1.5cm
- Usable: 1.5 - 0.6 = 0.9cm
- Label "via the terminal" = 16 chars × 0.10 = 1.6cm
- 1.6 > 0.9: collision. Fix: move label above both boxes.

### Rule 2: Positional Keywords (see Pass 3 above)

### Rule 3: Minimum Spacing

| Between | Minimum |
|---------|---------|
| Node edge to node edge | 0.8cm |
| Label to any line/arrow | 0.15cm |
| Node edge to slide margin | 0.5cm |
| Stacked labels (vertically) | 0.3cm |

### Rule 4: Multi-line Nodes

`\\` in a node requires `align=center` (or `align=left`). Without it: "Not allowed in LR mode" error. Set `text width` 15% wider than your estimate.

### Rule 5: Scale Shrinks Coordinates But Not Text

`scale=0.8` makes a 2cm gap into 1.6cm, but text stays full size. Always use:
```latex
\begin{tikzpicture}[scale=0.8, every node/.style={scale=0.8}]
```
Or better: don't scale. Design at intended size.

### Rule 6: Staggering Crowded Labels

- Alternate `above`/`below` for consecutive arrow labels
- Use `pos=0.3` and `pos=0.7` instead of `midway` for parallel arrows
- `near start` and `near end` for very crowded diagrams

### Rule 7: Bézier Curves (see Pass 1 above)

The fundamental problem: Claude cannot eyeball where a curve passes. The formula is the only reliable method. DO NOT trust intuition on curved arrows.

### Rule 8: Arrows Crossing Arrows

A curved return arrow bending downward WILL cross any vertical arrow in the middle of the diagram. Fix: route the return arrow above (`bend right` instead of `bend left` when going right-to-left).

### Rule 9: Full-Deck Re-Audit

After ANY TikZ fix, re-audit EVERY TikZ figure in the deck. The same error pattern repeats across slides because the same code structure was reused. `grep -n "bend"` finds all curves. Check each one. This takes 2 minutes. Skipping it costs the user's trust.

---

## Common Collision Patterns

1. **Label between wide boxes**: Text exceeds gap. Fix: move above/below.
2. **Timeline with era labels**: Adjacent labels overlap. Fix: stagger above/below.
3. **Flow diagram with many arrows**: Labels pile up. Fix: label only non-obvious transitions.
4. **Node near slide edge**: Text extends past boundary. Fix: explicit `text width`, 0.5cm margin.
5. **Return arrow crossing vertical branch**: Curve passes through another arrow. Fix: bend the other direction.
6. **Label in curved arrow's path**: Label placed "below" the baseline but inside the curve's sweep. Fix: use the depth formula, add 0.5cm safety margin.

---

## Matplotlib Bézier Helper Functions (Copy-Paste Template)

When generating ANY Python/matplotlib figure with curved arrows (`arc3`), include these helper functions at the top of the script. They compute exact curve positions so labels can be placed with precision.

```python
import numpy as np

def arc3_control_point(x1, y1, x2, y2, rad):
    """Compute the quadratic Bézier control point for matplotlib's arc3 connectionstyle.
    Formula from matplotlib source: cx = mid_x + rad*dy, cy = mid_y - rad*dx
    """
    dx, dy = x2 - x1, y2 - y1
    cx = (x1 + x2) / 2 + rad * dy
    cy = (y1 + y2) / 2 - rad * dx
    return cx, cy

def find_t_for_x(target_x, x1, cx, x2, num_samples=1000):
    """Find the Bézier parameter t where x(t) ≈ target_x."""
    ts = np.linspace(0, 1, num_samples)
    xs = (1 - ts)**2 * x1 + 2 * (1 - ts) * ts * cx + ts**2 * x2
    return ts[np.argmin(np.abs(xs - target_x))]

def bezier_y_at_t(t, y1, cy, y2):
    """Y-coordinate of quadratic Bézier at parameter t."""
    return (1 - t)**2 * y1 + 2 * (1 - t) * t * cy + t**2 * y2

# Usage: Label an arc3 arrow at the midpoint of the gap
# cx, cy = arc3_control_point(start_x, start_y, end_x, end_y, rad)
# t_mid = find_t_for_x(gap_mid_x, start_x, cx, end_x)
# curve_y = bezier_y_at_t(t_mid, start_y, cy, end_y)
# ax.text(gap_mid_x, curve_y + 0.35, label, ha='center', va='bottom',
#         bbox=dict(facecolor='white', edgecolor='none', alpha=0.8, pad=1))
```

**When to use:** Every time a matplotlib figure has `connectionstyle='arc3'` AND labels near those arrows. For straight arrows (`rad=0`), the curve position is just linear interpolation — but still compute it, don't guess.
