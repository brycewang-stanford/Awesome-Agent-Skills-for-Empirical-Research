# Visualization Design Principles

How to *think* about data visualization — choosing the right chart, encoding data effectively, and directing attention. This guide is tool-agnostic; load `plotnine` or `plotly` skills for implementation syntax.

## Exploratory vs. Explanatory

Every visualization serves one of two purposes. Know which one you're making.

**Exploratory:** You're investigating — "turning over 100 rocks to find 1-2 gemstones" (Knaflic). Show comprehensive data across multiple dimensions. Keep it neutral. Enable the viewer to draw conclusions.

**Explanatory:** You've found the gemstone. Now communicate it. Use selective highlighting, strategic annotation, and a declarative title to guide the audience to a specific insight.

| Aspect | Exploratory | Explanatory |
|--------|-------------|-------------|
| Audience | You (the analyst) | Stakeholders |
| Title style | Descriptive ("Enrollment by State") | Declarative ("Rural States Lost Students Fastest") |
| Color use | Functional, all series visible | Gray + highlight the signal |
| Annotation | Minimal | Strategic — explain what happened |
| Interactivity | Filters, drill-downs useful | Usually static, guided |

**Rule of thumb:** Do exploratory work first, thoroughly. Only move to explanatory when you know what the story is. The same data structure can serve both — the difference is emphasis and annotation.

## The One-Chart-One-Message Principle

Each visualization should communicate a single clear takeaway. If you need two messages, make two charts.

**Test:** Can you state the chart's message in one sentence? If not, the chart is trying to do too much.

**Common violations:**
- Dual-axis charts implying a relationship between unrelated series
- Overloaded charts with 8+ colored series and a large legend
- Charts that require a paragraph of explanation to interpret

## Visual Encoding Hierarchy

Not all visual encodings are equally effective. Cleveland & McGill (1984), extended by Mackinlay (1986) and Munzner (2014), established that humans decode some visual channels far more accurately than others:

```
Most accurate
  │  1. Position on a common scale (scatter plot, dot plot)
  │  2. Position on non-aligned scales (separate panels, small multiples)
  │  3. Length (bar chart height)
  │  4. Slope (line chart trends)
  │  5. Angle (pie slice)
  │  6. Area (bubble size, treemap)
  │  7. Color saturation (heatmap intensity)
  │  8. Color hue (categorical distinction only)
Least accurate
```

**Practical implications:**
- Bars beat pies for the same data (length at rank 3 vs. angle at rank 5)
- Line chart slopes (rank 4) are read more accurately than pie angles (rank 5)
- Scatter plots are powerful — both axes use position (rank 1)
- Bubble charts sacrifice precision — size uses area (rank 6)
- Heatmaps show patterns, not precise values — use for "where are the hot spots?"

**Encoding depends on data type:**
- Quantitative → position, length, area, saturation
- Ordinal → position, saturation, size
- Categorical → position, hue, shape

## Chart Selection by Relationship

Start with the relationship you want to show, not the chart type you like. This framework draws from the Financial Times Visual Vocabulary (9 categories) distilled to the 6 most common in policy/research work.

### Comparison — How do values differ across categories?

| Chart | Best For | Key Rule |
|-------|----------|----------|
| Vertical bar | Few categories (<12), short labels | Must start at zero |
| Horizontal bar | Many categories or long labels | Sort by value (don't alphabetize) |
| Dot plot | Many categories, emphasis on position | Less ink than bars; avoids zero-baseline issue |
| Grouped bar | Sub-groups within categories | Limit to 2-3 sub-groups |
| Slope chart | Change between exactly 2 time points | Shows direction + magnitude of change |

### Distribution — How are values spread?

| Chart | Best For | Key Rule |
|-------|----------|----------|
| Histogram | Single distribution, shape + frequency | Bin width changes the story — try multiple |
| Box plot | Comparing distributions compactly | Hides shape: a bimodal and a unimodal distribution with the same quartiles produce identical boxes |
| Violin plot | Distribution shape matters | Reveals bimodality that box plots hide |
| Strip/jitter | Moderate datasets (n < ~500/group) | Shows individual data points; use transparency for larger n |
| ECDF plot | Percentile comparisons, no binning | Shows every point's rank; great for "what % fall below X?" questions |
| Ridgeline | Comparing many distributions (5-20+) | Compact vertical stacking of densities |

### Trend Over Time — How do values change?

| Chart | Best For | Key Rule |
|-------|----------|----------|
| Line chart | Continuous time series, 1-5 series | Lines imply continuity — don't use for discrete events |
| Area chart | Emphasizing volume over time | Stacked areas: only bottom layer and total are readable; middle layers lack a common baseline |
| Small multiples | 5+ series that would overlap | Each gets its own panel — avoids spaghetti |
| Bar chart | Discrete time periods (annual totals) | When each period is independent |
| Sparklines | Inline trend context in tables/text | Data-dense, word-sized graphics (Tufte) |

### Correlation — How do variables relate?

| Chart | Best For | Key Rule |
|-------|----------|----------|
| Scatter plot | Two continuous variables, n < ~5K | The gold standard — both axes use position |
| Hexbin / 2D density | Scatter with n > 5K (overplotting) | Shows density where scatter becomes a blob |
| Heatmap | Two categorical variables, showing intensity | Pattern detection, not precise reading |
| Connected scatter | Two variables changing over time | Path shows temporal trajectory |

### Composition — How do parts make a whole?

| Chart | Best For | Key Rule |
|-------|----------|----------|
| Stacked bar | Parts + total magnitude | Bottom segment is easiest to compare |
| 100% stacked bar | Comparing proportions across groups | Normalizes totals; focus on share |
| Treemap | Hierarchical, many categories | Space-efficient but hard to compare precisely |
| Waffle chart | Simple proportion ("7 out of 10") | Intuitive for general audiences |
| Stacked area | Composition change over time | Bottom layer + total are reliable; middle layers are hard to read precisely |

**Why pie charts are usually poor:** They encode values as angle (rank 4), not length (rank 3). Comparing slices across pies is nearly impossible. Beyond 3-4 slices they become unreadable. A bar chart almost always communicates the same data more accurately. The one defensible use: showing that one category overwhelmingly dominates.

### Ranking — What is the order?

| Chart | Best For | Key Rule |
|-------|----------|----------|
| Horizontal bar (sorted) | Ranked list of categories | **Sort the data** — the chart should do the cognitive work |
| Lollipop | Ranked list, cleaner aesthetic | Dot + stem; less ink than full bars |
| Bump chart | How rankings change over time | Shows rank trajectories and crossovers |

## Small Multiples

When you have more than 5 series, small multiples almost always beat an overloaded single chart.

**Why they work:** The eye learns the chart structure once, then compares across panels. Structure is O(1), comparison is O(n) — far less cognitive load than decoding a legend for each data point.

**When to use:**
- Too many series for one chart (>5 lines, >4 groups)
- Comparing pattern/shape across a categorical variable
- The legend would need more than ~5 entries

**Design rules:**
- **Shared axes** — all panels must use the same scales (this is the whole point)
- **Meaningful ordering** — sort by the variable of interest, not alphabetically
- **Label panels directly** — put the category name on each panel
- **Minimal per-panel decoration** — the structure does the work

**Limitations:** Weaker for precise cross-panel value comparison; consume more space.

## Common Pitfalls

| Pitfall | Why It's Bad | Better Alternative |
|---------|-------------|-------------------|
| Pie charts (>3 slices) | Angle encoding is weak; cross-pie comparison is impossible | Horizontal bar, stacked bar |
| Dual-axis charts | Scale choices create false implied correlations; deeply misleading | Two separate panels; index to common baseline |
| 3D effects | Add no information; distort perception via perspective | Standard 2D charts |
| Spaghetti plots (>5 lines) | Colors become indistinguishable; tracking is impossible | Small multiples; gray + highlight one series |
| Truncated bar chart axes | Bars encode *length* — not starting at zero breaks that mapping | Start at zero, or switch to dot plot |
| Rainbow color scales | Perceptually non-uniform; artificial bright bands at yellow/cyan; colorblind-hostile | viridis, cividis, or single-hue sequential |

## Integrity Checklist

Before finalizing any visualization:

- [ ] Bar charts start at zero
- [ ] Scales are consistent across all panels/small multiples
- [ ] No dual axes implying false relationships
- [ ] Area/volume encodings are proportional (no distorted bubbles)
- [ ] Uncertainty is shown where relevant (confidence intervals, error bars)
- [ ] Data is not cherry-picked — full context is visible
- [ ] Source is cited
- [ ] The chart's message is stated (title) or immediately obvious
- [ ] Sample sizes (N) are disclosed for all groups shown
- [ ] Suppressed or missing values are noted (not silently excluded)
- [ ] Axis labels include units of measurement
- [ ] **Visual inspection performed via the Read tool on the generated PNG** — programmatic checks alone cannot verify layout, readability, color rendering, or overall visual coherence; every figure must be viewed directly before declaring it complete

## Key References

- Cleveland & McGill (1984). "Graphical Perception." *Journal of the American Statistical Association*
- Tufte, E. *The Visual Display of Quantitative Information* (1983, 2nd ed. 2001)
- Knaflic, C.N. *Storytelling with Data* (2015)
- Schwabish, J. *Better Data Visualizations* (2021)
- Wilke, C. *Fundamentals of Data Visualization* (2019) — freely available at clauswilke.com/dataviz
- [FT Visual Vocabulary](https://ft-interactive.github.io/visual-vocabulary/) — 9-category chart selection framework
- [From Data to Viz](https://data-to-viz.com) — interactive decision tree by data type
