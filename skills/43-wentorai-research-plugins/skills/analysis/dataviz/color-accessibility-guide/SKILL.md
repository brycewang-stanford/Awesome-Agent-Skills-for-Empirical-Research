---
name: color-accessibility-guide
description: "Colorblind-friendly palettes and accessible visualization design"
metadata:
  openclaw:
    emoji: "🎨"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["colorblind-friendly palette", "accessible color scheme", "visualization principles", "data-ink ratio"]
    source: "wentor-research-plugins"
---

# Color Accessibility Guide

Design data visualizations that are accessible to colorblind readers and follow best practices for clarity, using tested palettes and encoding principles.

## Color Vision Deficiency Overview

Approximately 8% of males and 0.5% of females have some form of color vision deficiency (CVD). The most common types:

| Type | Prevalence (Male) | Affected Colors | Commonly Confused |
|------|-------------------|-----------------|-------------------|
| Deuteranomaly (green-weak) | 5% | Green | Red and green |
| Protanomaly (red-weak) | 1% | Red | Red and green |
| Deuteranopia (no green) | 1% | Green | Red and green |
| Protanopia (no red) | 1% | Red | Red and green |
| Tritanopia (no blue) | 0.003% | Blue | Blue and yellow |
| Monochromacy | Very rare | All | All colors |

**Key takeaway**: Never rely solely on a red-green distinction to convey information. About 1 in 12 male readers cannot distinguish them.

## Recommended Colorblind-Safe Palettes

### Qualitative Palettes (Categorical Data)

#### Wong (2011) Nature Palette (8 colors)

Widely recommended for scientific publications:

```python
# Wong's colorblind-friendly palette
wong_palette = {
    "black":       "#000000",
    "orange":      "#E69F00",
    "sky_blue":    "#56B4E9",
    "bluish_green":"#009E73",
    "yellow":      "#F0E442",
    "blue":        "#0072B2",
    "vermillion":  "#D55E00",
    "reddish_purple":"#CC79A7"
}
```

#### Okabe-Ito Palette

```python
okabe_ito = ["#E69F00", "#56B4E9", "#009E73", "#F0E442",
             "#0072B2", "#D55E00", "#CC79A7", "#000000"]
```

#### Tol's Qualitative Palette

```python
# Paul Tol's qualitative palette (up to 12 distinct colors)
tol_qualitative = ["#332288", "#88CCEE", "#44AA99", "#117733",
                   "#999933", "#DDCC77", "#CC6677", "#882255",
                   "#AA4499", "#661100", "#6699CC", "#888888"]
```

### Sequential Palettes (Ordered Data)

For continuous data, use perceptually uniform colormaps:

```python
import matplotlib.pyplot as plt

# Recommended sequential colormaps
# These are perceptually uniform and colorblind-safe:
good_cmaps = ["viridis", "plasma", "inferno", "magma", "cividis"]

# Avoid these (not perceptually uniform, not colorblind-safe):
bad_cmaps = ["jet", "rainbow", "hsv"]  # NEVER use these

# Example usage
import numpy as np
data = np.random.randn(10, 10)
fig, ax = plt.subplots(figsize=(8, 6))
im = ax.imshow(data, cmap="viridis")
plt.colorbar(im)
plt.title("Use viridis, not jet")
plt.savefig("heatmap.pdf", dpi=300, bbox_inches="tight")
```

### Diverging Palettes (Data with Meaningful Center)

```python
# Colorblind-safe diverging palettes
# Blue-to-Red via white (good for temperature, correlation)
import matplotlib.colors as mcolors

# Built-in matplotlib options:
diverging_safe = ["RdBu_r", "PuOr_r", "BrBG"]

# Custom two-color diverging (Tol):
tol_diverging = ["#364B9A", "#4A7BB7", "#6EA6CD", "#98CAE1", "#C2E4EF",
                 "#EAECCC", "#FEDA8B", "#FDB366", "#F67E4B", "#DD3D2D", "#A50026"]
```

## Design Principles for Accessible Visualization

### 1. Data-Ink Ratio

Edward Tufte's principle: maximize the proportion of ink used to display actual data.

```python
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# BAD: Low data-ink ratio (chartjunk)
ax1.bar(range(5), [3, 7, 2, 5, 8], color="blue", edgecolor="black",
        linewidth=2)
ax1.set_facecolor("#EEEEEE")
ax1.grid(True, color="white", linewidth=2)
ax1.set_title("Before: Low Data-Ink Ratio")

# GOOD: High data-ink ratio
ax2.bar(range(5), [3, 7, 2, 5, 8], color="#0072B2", edgecolor="none")
ax2.spines["top"].set_visible(False)
ax2.spines["right"].set_visible(False)
ax2.set_title("After: High Data-Ink Ratio")

plt.tight_layout()
plt.savefig("data_ink_ratio.pdf", dpi=300)
```

### 2. Redundant Encoding

Never use color as the sole channel for conveying information. Combine color with at least one other visual channel:

| Channel | Examples |
|---------|----------|
| Shape | Circles, squares, triangles for different groups |
| Pattern | Solid, dashed, dotted lines |
| Fill pattern | Hatching, cross-hatching for bar charts |
| Label | Direct text labels on or near data points |
| Position | Separate panels (facets) for each group |
| Size | Varying point sizes |

```python
import matplotlib.pyplot as plt

markers = ['o', 's', '^', 'D']  # Different shapes
colors = ['#0072B2', '#D55E00', '#009E73', '#CC79A7']
labels = ['Group A', 'Group B', 'Group C', 'Group D']

fig, ax = plt.subplots(figsize=(8, 6))
for i in range(4):
    ax.scatter(x[i], y[i], c=colors[i], marker=markers[i],
               s=80, label=labels[i], edgecolors='black', linewidth=0.5)

ax.legend()
ax.set_xlabel("X Variable")
ax.set_ylabel("Y Variable")
plt.savefig("redundant_encoding.pdf", dpi=300)
```

### 3. Line Style Differentiation

```python
line_styles = ['-', '--', '-.', ':', (0, (3, 1, 1, 1))]
colors = ['#0072B2', '#D55E00', '#009E73', '#CC79A7', '#E69F00']

fig, ax = plt.subplots(figsize=(8, 5))
for i in range(5):
    ax.plot(x, data[i], color=colors[i], linestyle=line_styles[i],
            linewidth=2, label=f"Method {i+1}")

ax.legend()
```

## Checking Your Visualizations

### Simulation Tools

| Tool | Platform | URL |
|------|----------|-----|
| Coblis | Web | color-blindness.com/coblis |
| Color Oracle | Desktop (Win/Mac/Linux) | colororacle.org |
| Sim Daltonism | macOS | michelf.ca/projects/sim-daltonism |
| Colorblindly | Chrome extension | Chrome Web Store |
| Matplotlib CVD simulation | Python | See code below |

### Programmatic CVD Simulation

```python
from colorspacious import cspace_convert
import numpy as np

def simulate_cvd(rgb_hex, deficiency="deuteranomaly", severity=100):
    """Simulate how a color appears to someone with CVD."""
    # Convert hex to RGB [0,1]
    rgb = np.array([int(rgb_hex[i:i+2], 16)/255 for i in (1, 3, 5)])

    # Convert using colorspacious
    cvd_space = {"name": "sRGB1+CVD",
                 "cvd_type": deficiency,
                 "severity": severity}
    rgb_cvd = cspace_convert(rgb, cvd_space, "sRGB1")
    rgb_cvd = np.clip(rgb_cvd, 0, 1)

    return "#{:02x}{:02x}{:02x}".format(*[int(c*255) for c in rgb_cvd])

# Test your palette
for color in ["#FF0000", "#00FF00", "#0072B2", "#D55E00"]:
    sim = simulate_cvd(color)
    print(f"{color} -> {sim} (deuteranomaly)")
```

## Quick Reference: Do's and Don'ts

| Do | Don't |
|----|-------|
| Use Wong or Okabe-Ito palettes | Use red vs. green to distinguish categories |
| Use viridis/cividis colormaps | Use jet/rainbow colormaps |
| Add shape/pattern as redundant encoding | Rely on color alone |
| Use direct labels when possible | Force readers to match colors to legend repeatedly |
| Test with CVD simulators | Assume your color choices work for everyone |
| Use high contrast (WCAG AA: 4.5:1 ratio) | Use light colors on white backgrounds |
| Keep maximum 7-8 colors in categorical charts | Use 15+ colors that are impossible to distinguish |
