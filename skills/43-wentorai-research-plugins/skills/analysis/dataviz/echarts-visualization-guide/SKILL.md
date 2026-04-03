---
name: echarts-visualization-guide
description: "Guide to Apache ECharts for interactive research data dashboards"
metadata:
  openclaw:
    emoji: "📈"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["ECharts", "interactive charts", "data dashboard", "Apache ECharts", "scientific charts", "research visualization"]
    source: "https://github.com/apache/echarts"
---

# Apache ECharts Visualization Guide

## Overview

Apache ECharts is a powerful, free, and open-source interactive charting and data visualization library with over 66K stars on GitHub. Originally developed by Baidu and now an Apache Software Foundation top-level project, ECharts provides a declarative configuration-based approach to building rich, interactive visualizations that run smoothly in any modern browser.

For academic researchers, ECharts offers an excellent balance between ease of use and customization depth. Its declarative option-based API means researchers can produce complex multi-series charts, geographic visualizations, and animated transitions without writing low-level rendering code. This is particularly useful when building research dashboards or interactive supplementary materials for publications.

ECharts supports over 20 chart types out of the box, including line, bar, scatter, pie, radar, candlestick, heatmap, treemap, sunburst, parallel coordinates, sankey diagrams, and geographic maps. Its built-in support for large datasets (via progressive rendering and data sampling) makes it suitable for visualizing experimental results with hundreds of thousands of data points.

## Basic Configuration and Chart Types

ECharts uses a declarative JSON configuration object to define charts. This approach makes it straightforward to build visualizations programmatically from research data.

### Setting Up ECharts

```html
<div id="chart" style="width: 800px; height: 500px;"></div>
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
<script>
  const chart = echarts.init(document.getElementById('chart'));
</script>
```

### Multi-Series Line Chart for Time-Series Data

```javascript
const option = {
  title: {
    text: 'Gene Expression Over Time',
    left: 'center',
    textStyle: { fontSize: 16, fontWeight: 'bold' }
  },
  tooltip: {
    trigger: 'axis',
    formatter: params => {
      let html = `<strong>Hour ${params[0].axisValue}</strong><br/>`;
      params.forEach(p => {
        html += `${p.marker} ${p.seriesName}: ${p.value.toFixed(3)}<br/>`;
      });
      return html;
    }
  },
  legend: { data: ['Gene A', 'Gene B', 'Gene C'], bottom: 10 },
  xAxis: {
    type: 'category',
    name: 'Time (hours)',
    data: [0, 2, 4, 8, 12, 24, 48, 72]
  },
  yAxis: {
    type: 'value',
    name: 'Relative Expression',
    nameLocation: 'middle',
    nameGap: 50
  },
  series: [
    {
      name: 'Gene A',
      type: 'line',
      data: [1.0, 1.2, 2.4, 5.1, 8.3, 12.1, 10.5, 9.2],
      smooth: true,
      lineStyle: { width: 2 }
    },
    {
      name: 'Gene B',
      type: 'line',
      data: [1.0, 0.9, 0.7, 0.5, 0.3, 0.2, 0.15, 0.1],
      smooth: true,
      lineStyle: { width: 2 }
    },
    {
      name: 'Gene C',
      type: 'line',
      data: [1.0, 1.1, 1.3, 1.8, 3.2, 6.7, 8.9, 11.4],
      smooth: true,
      lineStyle: { width: 2 }
    }
  ]
};

chart.setOption(option);
```

### Scatter Plot with Error Regions

```javascript
const scatterOption = {
  title: { text: 'Treatment Response vs Dosage', left: 'center' },
  xAxis: { type: 'value', name: 'Dosage (mg/kg)' },
  yAxis: { type: 'value', name: 'Response Score' },
  tooltip: {
    formatter: p => `Dosage: ${p.value[0]}<br/>Response: ${p.value[1]}`
  },
  visualMap: {
    min: 0, max: 100,
    dimension: 2,
    inRange: { color: ['#3B82F6', '#EF4444'] },
    text: ['High', 'Low'],
    calculable: true
  },
  series: [{
    type: 'scatter',
    symbolSize: d => Math.sqrt(d[2]) * 2,
    data: experimentalData.map(d => [d.dosage, d.response, d.confidence])
  }]
};
```

## Advanced Research Visualizations

### Heatmap for Gene Expression Matrices

```javascript
const heatmapOption = {
  title: { text: 'Sample Correlation Matrix', left: 'center' },
  tooltip: {
    position: 'top',
    formatter: p => {
      return `${sampleNames[p.value[0]]} vs ${sampleNames[p.value[1]]}<br/>` +
             `Correlation: ${p.value[2].toFixed(4)}`;
    }
  },
  grid: { left: 120, top: 60, right: 80, bottom: 100 },
  xAxis: {
    type: 'category',
    data: sampleNames,
    axisLabel: { rotate: 45 }
  },
  yAxis: {
    type: 'category',
    data: sampleNames
  },
  visualMap: {
    min: -1, max: 1,
    calculable: true,
    orient: 'vertical',
    right: 10,
    top: 'center',
    inRange: {
      color: ['#2166AC', '#F7F7F7', '#B2182B']
    }
  },
  series: [{
    type: 'heatmap',
    data: correlationData,
    label: { show: true, formatter: p => p.value[2].toFixed(2), fontSize: 9 },
    emphasis: {
      itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.5)' }
    }
  }]
};
```

### Radar Chart for Multi-Dimensional Comparison

```javascript
const radarOption = {
  title: { text: 'Model Performance Comparison', left: 'center' },
  legend: { data: ['Model A', 'Model B', 'Baseline'], bottom: 10 },
  radar: {
    indicator: [
      { name: 'Accuracy', max: 1.0 },
      { name: 'Precision', max: 1.0 },
      { name: 'Recall', max: 1.0 },
      { name: 'F1 Score', max: 1.0 },
      { name: 'AUC-ROC', max: 1.0 },
      { name: 'Speed (norm)', max: 1.0 }
    ]
  },
  series: [{
    type: 'radar',
    data: [
      { value: [0.94, 0.91, 0.89, 0.90, 0.96, 0.72], name: 'Model A' },
      { value: [0.92, 0.95, 0.85, 0.90, 0.94, 0.88], name: 'Model B' },
      { value: [0.85, 0.82, 0.80, 0.81, 0.87, 0.95], name: 'Baseline' }
    ]
  }]
};
```

## Responsive Design and Theming

ECharts supports custom themes and responsive resizing, which is important when embedding visualizations in research web applications.

```javascript
// Register a custom academic theme
echarts.registerTheme('academic', {
  color: ['#3B82F6', '#EF4444', '#10B981', '#F59E0B', '#8B5CF6', '#EC4899'],
  backgroundColor: '#FFFFFF',
  textStyle: { fontFamily: 'Inter, sans-serif' },
  title: { textStyle: { color: '#1F2937', fontSize: 16 } },
  line: { smooth: false, symbolSize: 6 }
});

// Initialize chart with the academic theme
const chart = echarts.init(document.getElementById('chart'), 'academic');

// Handle responsive resizing
window.addEventListener('resize', () => chart.resize());
```

## Data Loading and Integration

```javascript
// Load CSV data and convert to ECharts format
async function loadExperimentData(csvUrl) {
  const response = await fetch(csvUrl);
  const text = await response.text();
  const rows = text.split('\n').slice(1);

  const data = rows.map(row => {
    const [sample, condition, value, error] = row.split(',');
    return { sample, condition, value: parseFloat(value), error: parseFloat(error) };
  });

  return data;
}

// Export chart as PNG for publications
function downloadChart(chartInstance, filename) {
  const url = chartInstance.getDataURL({
    type: 'png',
    pixelRatio: 3,
    backgroundColor: '#fff'
  });
  const link = document.createElement('a');
  link.href = url;
  link.download = filename || 'chart.png';
  link.click();
}
```

## References

- Apache ECharts official site: https://echarts.apache.org
- ECharts GitHub repository: https://github.com/apache/echarts
- ECharts examples gallery: https://echarts.apache.org/examples
- ECharts configuration handbook: https://echarts.apache.org/en/option.html
