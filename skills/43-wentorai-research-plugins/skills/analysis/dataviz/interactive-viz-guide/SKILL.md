---
name: interactive-viz-guide
description: "Interactive data visualization with Plotly, ECharts, and D3"
metadata:
  openclaw:
    emoji: "✨"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["interactive visualization", "dynamic chart", "Plotly", "ECharts", "data visualization"]
    source: "wentor-research-plugins"
---

# Interactive Visualization Guide

Create interactive, publication-ready visualizations using Plotly, ECharts, Altair, and Bokeh for academic papers, presentations, and supplementary materials.

## When to Use Interactive Visualizations

| Scenario | Static | Interactive |
|----------|--------|-------------|
| Journal PDF figure | Preferred | Not supported |
| Supplementary materials | Optional | Excellent |
| Conference poster (digital) | Common | Increasingly popular |
| Presentation slides | Standard | Engaging |
| Online appendix / project website | Limited | Ideal |
| Exploratory data analysis | Quick | Detailed exploration |

## Plotly (Python)

Plotly produces interactive HTML charts with hover tooltips, zoom, pan, and export capabilities.

### Scatter Plot with Hover Details

```python
import plotly.express as px
import pandas as pd

# Example: visualize paper citations vs. year
df = pd.DataFrame({
    "title": ["Paper A", "Paper B", "Paper C", "Paper D", "Paper E"],
    "year": [2019, 2020, 2021, 2022, 2023],
    "citations": [150, 320, 89, 450, 210],
    "field": ["NLP", "CV", "NLP", "RL", "CV"],
    "venue": ["ACL", "CVPR", "EMNLP", "NeurIPS", "ICCV"]
})

fig = px.scatter(
    df, x="year", y="citations",
    color="field", size="citations",
    hover_data=["title", "venue"],
    title="Citation Counts by Year and Field",
    labels={"citations": "Citation Count", "year": "Publication Year"}
)
fig.update_layout(
    template="plotly_white",
    font=dict(size=14),
    width=800, height=500
)
fig.write_html("citations_interactive.html")
fig.show()
```

### Grouped Bar Chart

```python
import plotly.graph_objects as go

methods = ["Baseline", "Method A", "Method B", "Ours"]
accuracy = [82.1, 85.3, 87.0, 89.4]
f1_score = [79.8, 83.1, 85.2, 87.9]

fig = go.Figure(data=[
    go.Bar(name="Accuracy", x=methods, y=accuracy,
           text=[f"{v}%" for v in accuracy], textposition="auto"),
    go.Bar(name="F1 Score", x=methods, y=f1_score,
           text=[f"{v}%" for v in f1_score], textposition="auto")
])
fig.update_layout(
    barmode="group",
    title="Model Performance Comparison",
    yaxis_title="Score (%)",
    yaxis_range=[70, 95],
    template="plotly_white"
)
fig.write_html("comparison.html")
```

### Heatmap (Confusion Matrix)

```python
import plotly.figure_factory as ff
import numpy as np

z = [[85, 5, 3, 7],
     [4, 90, 2, 4],
     [6, 3, 88, 3],
     [5, 2, 7, 86]]
labels = ["Class A", "Class B", "Class C", "Class D"]

fig = ff.create_annotated_heatmap(
    z, x=labels, y=labels,
    colorscale="Blues",
    showscale=True
)
fig.update_layout(
    title="Confusion Matrix",
    xaxis_title="Predicted",
    yaxis_title="Actual"
)
fig.write_html("confusion_matrix.html")
```

## Altair (Python - Declarative)

Altair uses Vega-Lite grammar for concise, declarative visualization.

```python
import altair as alt
import pandas as pd

# Interactive scatter with selection
df = pd.DataFrame({
    "x": range(100),
    "y": [v**2 + 10 for v in range(100)],
    "category": ["A" if i % 3 == 0 else "B" if i % 3 == 1 else "C" for i in range(100)]
})

selection = alt.selection_point(fields=["category"], bind="legend")

chart = alt.Chart(df).mark_circle(size=60).encode(
    x="x:Q",
    y="y:Q",
    color="category:N",
    opacity=alt.condition(selection, alt.value(1), alt.value(0.2)),
    tooltip=["x", "y", "category"]
).add_params(
    selection
).properties(
    width=600, height=400,
    title="Interactive Scatter with Legend Selection"
).interactive()  # Enable zoom/pan

chart.save("altair_scatter.html")
```

## ECharts (JavaScript)

Apache ECharts is a powerful JavaScript charting library ideal for web dashboards and complex visualizations.

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
</head>
<body>
  <div id="chart" style="width: 800px; height: 500px;"></div>
  <script>
    const chart = echarts.init(document.getElementById('chart'));

    const option = {
      title: { text: 'Research Output by Year', left: 'center' },
      tooltip: {
        trigger: 'axis',
        axisPointer: { type: 'shadow' }
      },
      legend: { data: ['Papers', 'Citations'], top: 30 },
      xAxis: {
        type: 'category',
        data: ['2019', '2020', '2021', '2022', '2023']
      },
      yAxis: [
        { type: 'value', name: 'Papers' },
        { type: 'value', name: 'Citations' }
      ],
      series: [
        {
          name: 'Papers',
          type: 'bar',
          data: [12, 15, 18, 22, 28],
          itemStyle: { color: '#3B82F6' }
        },
        {
          name: 'Citations',
          type: 'line',
          yAxisIndex: 1,
          data: [45, 120, 280, 450, 680],
          itemStyle: { color: '#EF4444' },
          smooth: true
        }
      ],
      dataZoom: [{ type: 'slider', start: 0, end: 100 }]
    };

    chart.setOption(option);
    window.addEventListener('resize', () => chart.resize());
  </script>
</body>
</html>
```

## Network Visualization

### Plotly Network Graph

```python
import plotly.graph_objects as go
import networkx as nx

# Create a citation network
G = nx.karate_club_graph()
pos = nx.spring_layout(G, seed=42)

# Edge traces
edge_x, edge_y = [], []
for edge in G.edges():
    x0, y0 = pos[edge[0]]
    x1, y1 = pos[edge[1]]
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

edge_trace = go.Scatter(x=edge_x, y=edge_y, mode="lines",
                        line=dict(width=0.5, color="#888"), hoverinfo="none")

# Node traces
node_x = [pos[n][0] for n in G.nodes()]
node_y = [pos[n][1] for n in G.nodes()]
node_degree = [G.degree(n) for n in G.nodes()]

node_trace = go.Scatter(
    x=node_x, y=node_y, mode="markers",
    marker=dict(size=[d*3 for d in node_degree], color=node_degree,
                colorscale="Viridis", showscale=True,
                colorbar=dict(title="Connections")),
    text=[f"Node {n}: {G.degree(n)} connections" for n in G.nodes()],
    hoverinfo="text"
)

fig = go.Figure(data=[edge_trace, node_trace],
                layout=go.Layout(title="Citation Network",
                                 showlegend=False,
                                 xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                                 yaxis=dict(showgrid=False, zeroline=False, showticklabels=False)))
fig.write_html("network.html")
```

## Exporting for Publication

### Static Export from Plotly

```python
# Export as high-res static image for journals
fig.write_image("figure.pdf", width=1200, height=800, scale=2)  # Vector PDF
fig.write_image("figure.png", width=1200, height=800, scale=3)  # 300 DPI PNG
fig.write_image("figure.svg", width=1200, height=800)            # Vector SVG

# Requires: pip install kaleido
```

### Embedding in Jupyter Notebooks

```python
# Plotly renders natively in Jupyter
fig.show()

# For Altair in Jupyter
chart  # Just display the chart object

# For ECharts in Jupyter, use pyecharts
from pyecharts.charts import Bar
from pyecharts import options as opts

bar = (Bar()
    .add_xaxis(["2019", "2020", "2021", "2022", "2023"])
    .add_yaxis("Papers", [12, 15, 18, 22, 28])
    .set_global_opts(title_opts=opts.TitleOpts(title="Research Output")))
bar.render_notebook()
```

## Best Practices

1. **Start with a static version**: Ensure your visualization works as a static figure first; interactivity is an enhancement, not a replacement.
2. **Meaningful tooltips**: Show relevant context on hover (paper title, exact values, metadata), not just coordinates.
3. **Responsive design**: Use percentage-based sizing or `window.addEventListener('resize')` for ECharts.
4. **Accessibility**: Provide text alternatives, use colorblind-friendly palettes, and ensure keyboard navigation.
5. **Performance**: For datasets over 10,000 points, use WebGL renderers (Plotly's `scattergl`, Deck.gl) or server-side aggregation.
6. **Reproducibility**: Save the data alongside the visualization so others can recreate it.
