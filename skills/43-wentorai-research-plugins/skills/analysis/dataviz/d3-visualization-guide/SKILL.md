---
name: d3-visualization-guide
description: "Guide to D3.js for building custom interactive data visualizations"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["data visualization", "D3.js", "interactive charts", "SVG", "web visualization", "scientific plots"]
    source: "https://github.com/d3/d3"
---

# D3.js Visualization Guide

## Overview

D3.js (Data-Driven Documents) is the most powerful and flexible JavaScript library for producing dynamic, interactive data visualizations in web browsers. With over 112K stars on GitHub, D3 has become the de facto standard for custom data visualization on the web. It uses HTML, SVG, and CSS to bring data to life, giving researchers full control over the final visual output.

Unlike higher-level charting libraries, D3 operates at the level of individual SVG elements and data bindings, which means researchers can create entirely bespoke visualizations tailored to their specific datasets and publication requirements. This makes it particularly valuable for academic work where standard chart types may not adequately represent complex research findings.

D3 provides a comprehensive ecosystem of modules covering everything from scales and axes to geographic projections, force-directed layouts, and hierarchical data structures. The library follows a functional, composable design that allows researchers to combine modules as needed for their specific visualization tasks.

## Core Concepts for Research Visualizations

D3 revolves around the concept of binding data to DOM elements and applying data-driven transformations. The key patterns every researcher should understand are selections, data joins, scales, and axes.

### Data Binding and Selections

```javascript
// Load research data from CSV
const data = await d3.csv("experiment_results.csv", d => ({
  condition: d.condition,
  measurement: +d.measurement,
  error: +d.standard_error
}));

// Create an SVG container
const svg = d3.select("#chart")
  .append("svg")
  .attr("width", 800)
  .attr("height", 500);

// Binddata to elements using the enter-update-exit pattern
svg.selectAll("circle")
  .data(data)
  .join("circle")
  .attr("cx", d => xScale(d.condition))
  .attr("cy", d => yScale(d.measurement))
  .attr("r", 5)
  .attr("fill", "#3B82F6");
```

### Scales and Axes

```javascript
// Linear scale for continuous measurements
const yScale = d3.scaleLinear()
  .domain([0, d3.max(data, d => d.measurement)])
  .range([height - margin.bottom, margin.top]);

// Band scale for categorical conditions
const xScale = d3.scaleBand()
  .domain(data.map(d => d.condition))
  .range([margin.left, width - margin.right])
  .padding(0.3);

// Add axes with proper formatting
svg.append("g")
  .attr("transform", `translate(0,${height - margin.bottom})`)
  .call(d3.axisBottom(xScale));

svg.append("g")
  .attr("transform", `translate(${margin.left},0)`)
  .call(d3.axisLeft(yScale).tickFormat(d3.format(".2f")));
```

## Publication-Quality Scientific Charts

### Error Bar Plot for Experimental Results

```javascript
function createErrorBarPlot(data, container) {
  const margin = { top: 40, right: 30, bottom: 60, left: 70 };
  const width = 700 - margin.left - margin.right;
  const height = 450 - margin.top - margin.bottom;

  const svg = d3.select(container)
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`);

  const x = d3.scaleBand()
    .domain(data.map(d => d.group))
    .range([0, width])
    .padding(0.4);

  const y = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.mean + d.sem) * 1.15])
    .range([height, 0]);

  // Draw bars
  svg.selectAll(".bar")
    .data(data)
    .join("rect")
    .attr("class", "bar")
    .attr("x", d => x(d.group))
    .attr("y", d => y(d.mean))
    .attr("width", x.bandwidth())
    .attr("height", d => height - y(d.mean))
    .attr("fill", (d, i) => d3.schemeTableau10[i]);

  // Draw error bars
  svg.selectAll(".error-line")
    .data(data)
    .join("line")
    .attr("x1", d => x(d.group) + x.bandwidth() / 2)
    .attr("x2", d => x(d.group) + x.bandwidth() / 2)
    .attr("y1", d => y(d.mean - d.sem))
    .attr("y2", d => y(d.mean + d.sem))
    .attr("stroke", "#333")
    .attr("stroke-width", 1.5);

  // Error bar caps
  const capWidth = 10;
  ["top", "bottom"].forEach(pos => {
    svg.selectAll(`.cap-${pos}`)
      .data(data)
      .join("line")
      .attr("x1", d => x(d.group) + x.bandwidth() / 2 - capWidth)
      .attr("x2", d => x(d.group) + x.bandwidth() / 2 + capWidth)
      .attr("y1", d => y(d.mean + (pos === "top" ? d.sem : -d.sem)))
      .attr("y2", d => y(d.mean + (pos === "top" ? d.sem : -d.sem)))
      .attr("stroke", "#333")
      .attr("stroke-width", 1.5);
  });

  // Axes
  svg.append("g")
    .attr("transform", `translate(0,${height})`)
    .call(d3.axisBottom(x))
    .selectAll("text")
    .style("font-size", "12px");

  svg.append("g")
    .call(d3.axisLeft(y))
    .selectAll("text")
    .style("font-size", "12px");
}
```

### Heatmap for Correlation Matrices

```javascript
function createCorrelationHeatmap(matrix, labels, container) {
  const size = 500;
  const cellSize = size / labels.length;

  const colorScale = d3.scaleSequential(d3.interpolateRdBu)
    .domain([1, -1]);

  const svg = d3.select(container)
    .append("svg")
    .attr("width", size + 120)
    .attr("height", size + 120);

  const g = svg.append("g")
    .attr("transform", "translate(100, 20)");

  // Draw cells
  labels.forEach((rowLabel, i) => {
    labels.forEach((colLabel, j) => {
      g.append("rect")
        .attr("x", j * cellSize)
        .attr("y", i * cellSize)
        .attr("width", cellSize - 1)
        .attr("height", cellSize - 1)
        .attr("fill", colorScale(matrix[i][j]))
        .append("title")
        .text(`${rowLabel} vs ${colLabel}: ${matrix[i][j].toFixed(3)}`);

      g.append("text")
        .attr("x", j * cellSize + cellSize / 2)
        .attr("y", i * cellSize + cellSize / 2)
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "central")
        .style("font-size", "10px")
        .text(matrix[i][j].toFixed(2));
    });
  });

  // Row and column labels
  g.selectAll(".row-label")
    .data(labels)
    .join("text")
    .attr("x", -8)
    .attr("y", (d, i) => i * cellSize + cellSize / 2)
    .attr("text-anchor", "end")
    .attr("dominant-baseline", "central")
    .style("font-size", "11px")
    .text(d => d);
}
```

## Interactive Techniques for Research Presentations

D3 excels at adding interactivity to visualizations, which is valuable for research presentations, supplementary materials, and data exploration during analysis.

### Tooltips and Hover Effects

```javascript
// Create a tooltip div
const tooltip = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("position", "absolute")
  .style("background", "rgba(0,0,0,0.8)")
  .style("color", "#fff")
  .style("padding", "8px 12px")
  .style("border-radius", "4px")
  .style("font-size", "12px")
  .style("pointer-events", "none")
  .style("opacity", 0);

// Attach to data points
svg.selectAll("circle")
  .on("mouseover", (event, d) => {
    tooltip.transition().duration(200).style("opacity", 1);
    tooltip.html(
      `<strong>${d.sample_id}</strong><br/>` +
      `Value: ${d.measurement.toFixed(3)}<br/>` +
      `p-value: ${d.pvalue.toExponential(2)}`
    )
    .style("left", (event.pageX + 12) + "px")
    .style("top", (event.pageY - 28) + "px");
  })
  .on("mouseout", () => {
    tooltip.transition().duration(300).style("opacity", 0);
  });
```

### Zoom and Pan for Large Datasets

```javascript
const zoom = d3.zoom()
  .scaleExtent([1, 20])
  .on("zoom", (event) => {
    chartGroup.attr("transform", event.transform);
  });

svg.call(zoom);
```

## Exporting for Publications

When preparing figures for journal submissions, D3 SVG output can be exported directly to vector formats.

```javascript
// Extract SVG markup for saving
function exportSVG(svgElement) {
  const serializer = new XMLSerializer();
  const svgString = serializer.serializeToString(svgElement);
  const blob = new Blob([svgString], { type: "image/svg+xml" });
  const url = URL.createObjectURL(blob);

  const link = document.createElement("a");
  link.href = url;
  link.download = "figure.svg";
  link.click();
  URL.revokeObjectURL(url);
}
```

Researchers can then convert SVG to PDF or EPS using tools like Inkscape or cairosvg for submission to journals that require specific formats.

## References

- D3.js official documentation: https://d3js.org
- D3 GitHub repository: https://github.com/d3/d3
- Observable D3 tutorials: https://observablehq.com/@d3
- D3 Graph Gallery (examples): https://d3-graph-gallery.com
