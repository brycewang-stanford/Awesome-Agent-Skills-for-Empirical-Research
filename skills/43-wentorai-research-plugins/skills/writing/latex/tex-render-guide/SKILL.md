---
name: tex-render-guide
description: "Render LaTeX math expressions to images in PNG, JPEG, and SVG"
metadata:
  openclaw:
    emoji: "🔢"
    category: "writing"
    subcategory: "latex"
    keywords: ["LaTeX rendering", "math images", "equation rendering", "SVG math", "KaTeX", "MathJax"]
    source: "wentor-research-plugins"
---

# TeX Render Guide

## Overview

Researchers frequently need to render LaTeX mathematical expressions as standalone images—for inclusion in presentations, posters, web pages, documentation, social media posts, or any context where native LaTeX rendering is unavailable. Converting a LaTeX equation into a crisp PNG, JPEG, or SVG image requires selecting the right toolchain and configuring it for the appropriate output quality and format.

This skill covers multiple approaches to LaTeX-to-image rendering, from command-line tools to web APIs and JavaScript libraries. It provides guidance on choosing the right approach for your use case, achieving publication-quality output, and handling common challenges like transparent backgrounds, high DPI scaling, and color customization.

Whether you need a one-off equation image for a slide deck or a batch pipeline that renders hundreds of equations for a web application, this guide provides the tools and techniques to get it done.

## Method 1: Command-Line Rendering with LaTeX + dvipng/dvisvgm

This is the highest-quality approach, producing output identical to what you would see in a compiled LaTeX document.

### Single Equation to PNG

Create a minimal LaTeX document containing only your equation:

```bash
# Create a temporary LaTeX file
cat > equation.tex << 'EOF'
\documentclass[border=2pt]{standalone}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{xcolor}
\begin{document}
$\displaystyle \int_{-\infty}^{\infty} e^{-x^2} \, dx = \sqrt{\pi}$
\end{document}
EOF

# Render to PDF, then convert to PNG
pdflatex equation.tex
# Convert PDF to high-resolution PNG (300 DPI)
convert -density 300 equation.pdf -quality 100 equation.png

# Alternative: use dvipng for direct DVI-to-PNG
latex equation.tex
dvipng -D 300 -T tight -bg Transparent equation.dvi -o equation.png
```

### Key Options for dvipng

- `-D 300` — Resolution in DPI (300 for print, 150 for screen, 600 for high-quality)
- `-T tight` — Crop tightly to the equation with minimal margins
- `-bg Transparent` — Transparent background (essential for slides and web)
- `-fg "rgb 1.0 1.0 1.0"` — White foreground (for dark backgrounds)
- `-o output.png` — Output filename

### Equation to SVG

SVG is the best format for web use and scalable documents:

```bash
# Using dvisvgm (included with TeX Live)
latex equation.tex
dvisvgm --no-fonts equation.dvi -o equation.svg

# Or from PDF:
pdf2svg equation.pdf equation.svg
```

The `--no-fonts` flag in dvisvgm converts text to paths, ensuring the SVG displays correctly without requiring the original fonts to be installed.

### Batch Rendering Script

For rendering multiple equations, use a script:

```bash
#!/bin/bash
# render_equations.sh - Render a list of LaTeX equations to PNG
INPUT_FILE="equations.txt"  # One equation per line
OUTPUT_DIR="rendered"
DPI=300

mkdir -p "$OUTPUT_DIR"
counter=1

while IFS= read -r equation; do
    cat > /tmp/eq_temp.tex << EOF
\documentclass[border=2pt]{standalone}
\usepackage{amsmath,amssymb}
\begin{document}
\$\displaystyle ${equation}\$
\end{document}
EOF
    (cd /tmp && pdflatex -interaction=nonstopmode eq_temp.tex > /dev/null 2>&1)
    convert -density $DPI /tmp/eq_temp.pdf -quality 100 -trim "$OUTPUT_DIR/eq_$(printf '%03d' $counter).png"
    echo "Rendered equation $counter: $equation"
    ((counter++))
done < "$INPUT_FILE"
```

## Method 2: KaTeX (Fast, Lightweight)

KaTeX is a JavaScript library that renders LaTeX math to HTML/CSS or SVG. It is significantly faster than MathJax and is ideal for web applications and real-time rendering.

### Command-Line Usage with Node.js

```bash
# Install KaTeX CLI
npm install -g katex

# Render to HTML
echo "E = mc^2" | katex --display-mode

# For SVG output, use the katex API programmatically:
```

```javascript
const katex = require('katex');

const html = katex.renderToString(
  '\\int_{-\\infty}^{\\infty} e^{-x^2} \\, dx = \\sqrt{\\pi}',
  {
    displayMode: true,
    output: 'html',  // or 'mathml'
    throwOnError: false
  }
);
console.log(html);
```

### Advantages of KaTeX
- Renders in milliseconds (10-100x faster than MathJax)
- Produces identical output on server and client
- Supports most common LaTeX math commands
- Small bundle size (~200 KB)

### Limitations
- Does not support all LaTeX packages (no TikZ, limited matrix environments)
- Some advanced math commands require MathJax

## Method 3: MathJax (Comprehensive)

MathJax supports the widest range of LaTeX commands and produces high-quality output. Use it when KaTeX does not support the notation you need.

### Server-Side Rendering with MathJax

```javascript
// Using mathjax-node
const mjAPI = require('mathjax-node');
mjAPI.config({ MathJax: {} });
mjAPI.start();

mjAPI.typeset({
  math: '\\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}',
  format: 'TeX',
  svg: true,      // Output as SVG
  // png: true,   // Or output as PNG
}, function(data) {
  if (!data.errors) {
    // data.svg contains the SVG string
    require('fs').writeFileSync('equation.svg', data.svg);
  }
});
```

### Converting MathJax SVG to PNG

If you need PNG output from MathJax SVG:

```bash
# Using Inkscape for high-quality SVG-to-PNG conversion
inkscape equation.svg --export-type=png --export-dpi=300 --export-filename=equation.png

# Or using ImageMagick
convert -density 300 equation.svg equation.png
```

## Method 4: Web API Services

For quick, no-install rendering, use web APIs:

```bash
# Using the codecogs API (free for reasonable usage)
# URL-encode your LaTeX and fetch the image
curl "https://latex.codecogs.com/png.image?\dpi{300}\bg{white}\int_{0}^{1}x^2\,dx" \
  -o equation.png

# SVG variant:
curl "https://latex.codecogs.com/svg.image?\int_{0}^{1}x^2\,dx" \
  -o equation.svg
```

Note: web APIs require internet access and may have usage limits. For privacy-sensitive equations (unpublished research), prefer local rendering.

## Choosing the Right Method

| Use Case | Recommended Method | Format |
|----------|-------------------|--------|
| Print publication figures | LaTeX + dvipng | PNG (600 DPI) |
| Web pages / documentation | KaTeX or MathJax | SVG or HTML |
| Presentations (PowerPoint, Keynote) | LaTeX + dvipng | PNG (300 DPI, transparent) |
| Dark-background slides | LaTeX + dvipng with white fg | PNG (transparent) |
| Batch processing (100+ equations) | LaTeX script or KaTeX | PNG or SVG |
| Quick one-off equation | Web API | PNG or SVG |
| Real-time preview | KaTeX | HTML |

## Color and Style Customization

For equations on dark backgrounds or with custom styling:

```latex
% White equation on transparent background
\documentclass[border=2pt]{standalone}
\usepackage{amsmath,xcolor}
\begin{document}
\color{white}
$\displaystyle E = mc^2$
\end{document}
```

```bash
# Render with transparent background
dvipng -D 300 -T tight -bg Transparent equation.dvi -o equation.png
```

For colored equations or partial coloring:

```latex
$\displaystyle \textcolor{blue}{\nabla} \times \textcolor{red}{\mathbf{E}} = -\frac{\partial \mathbf{B}}{\partial t}$
```

## References

- KaTeX: https://katex.org
- MathJax: https://www.mathjax.org
- dvipng documentation: https://ctan.org/pkg/dvipng
- dvisvgm: https://dvisvgm.de
- latex2image: wentor-research-plugins
- CodeCogs equation editor: https://latex.codecogs.com
