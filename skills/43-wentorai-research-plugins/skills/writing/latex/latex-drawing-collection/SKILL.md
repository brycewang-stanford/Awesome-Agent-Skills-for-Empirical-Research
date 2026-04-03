---
name: latex-drawing-collection
description: "LaTeX drawing examples for Bayesian networks, tensors, and diagrams"
version: 1.0.0
author: wentor-community
source: https://github.com/xinychen/awesome-latex-drawing
metadata:
  openclaw:
    category: "writing"
    subcategory: "latex"
    emoji: "🎨"
    keywords:
      - latex-drawing
      - tikz
      - bayesian-networks
      - tensor-diagrams
      - scientific-figures
      - pgfplots
---

# LaTeX Drawing Collection

A skill providing ready-to-use LaTeX drawing examples and guidance for creating publication-quality scientific figures using TikZ, PGFPlots, and related packages. Based on awesome-latex-drawing (2K stars), this skill covers Bayesian networks, tensor decompositions, neural architectures, time series visualizations, and more.

## Overview

High-quality figures are essential for effective scientific communication. While external tools like Matplotlib or Inkscape can produce figures, native LaTeX drawings offer superior integration with the document, consistent typography, vector-quality output at any resolution, and automatic style matching with the surrounding text.

This skill equips the agent with knowledge of 30+ LaTeX drawing patterns commonly used in academic publications. Each pattern includes the required packages, a description of the drawing approach, and guidance on customization for specific research contexts.

## Essential Packages

The following LaTeX packages form the foundation for scientific drawing:

**TikZ (tikz)**
- The core drawing package for LaTeX, providing a programming interface for vector graphics
- Supports coordinate systems, transformations, path operations, and decorations
- Required for virtually all complex scientific diagrams
- Load with: `\usepackage{tikz}` and relevant libraries via `\usetikzlibrary{...}`

**PGFPlots (pgfplots)**
- Built on TikZ for creating publication-quality data plots
- Supports 2D and 3D plots, error bars, fill areas, and custom markers
- Handles axis formatting, legends, and annotations
- Load with: `\usepackage{pgfplots}` and `\pgfplotsset{compat=1.18}`

**TikZ Libraries**
- `arrows.meta` - customizable arrowhead styles
- `positioning` - relative node placement (above=of, right=of)
- `fit` - bounding boxes around groups of nodes
- `matrix` - grid-based node layouts
- `decorations.pathreplacing` - braces, zigzag, snake decorations
- `calc` - coordinate arithmetic
- `backgrounds` - layered drawing with background regions

## Bayesian Network Diagrams

Bayesian networks are among the most common diagrams in probabilistic modeling papers:

**Node Styles**
- Observed variables: filled circles or shaded nodes
- Latent variables: open (unfilled) circles
- Hyperparameters: small solid dots or fixed-value nodes
- Plates: rounded rectangles indicating repetition with index labels

**Construction Approach**
- Define node styles at the beginning of the tikzpicture environment
- Place nodes using relative positioning for maintainable layouts
- Draw directed edges with arrow styles indicating conditional dependencies
- Add plate notation around repeated variable groups
- Label edges with conditional probability annotations when needed

**Common Patterns**
- Latent Dirichlet Allocation (LDA) plate diagram
- Hidden Markov Model (HMM) chain structure
- Variational autoencoder (VAE) graphical model
- Gaussian mixture model (GMM) with plate notation
- Deep generative model hierarchies

## Tensor and Matrix Diagrams

For linear algebra and tensor decomposition papers:

**Tensor Representations**
- Matrices as 2D grids with element shading
- Third-order tensors as 3D cubes with visible faces
- Tensor networks as connected node diagrams
- Factor matrices as thin rectangular blocks

**Decomposition Visualizations**
- CP decomposition: tensor equals sum of rank-one components
- Tucker decomposition: core tensor multiplied by factor matrices
- Tensor train: chain of connected 3D cores
- Matrix factorization: large matrix as product of thin matrices

## Neural Network Architectures

For deep learning and machine learning papers:

**Layer Representations**
- Fully connected layers as columns of nodes with all-to-all connections
- Convolutional layers as stacked feature map grids
- Attention layers as matrix operation diagrams
- Recurrent connections as self-loops or unrolled sequences

**Architecture Patterns**
- Encoder-decoder structures with bottleneck
- Skip connections and residual blocks
- Multi-head attention mechanisms
- Transformer block diagrams

## Time Series and Spatiotemporal Plots

For data analysis and forecasting papers:

**Time Series Elements**
- Line plots with confidence bands using PGFPlots fill between
- Missing data indicators with dashed segments
- Multi-variate time series as stacked or aligned panels
- Seasonal decomposition as vertically arranged subplots

**Spatiotemporal Grids**
- Heatmaps using TikZ matrix with color-coded cells
- Geographic grids with observation points
- Temporal slices showing spatial evolution

## Customization Guidelines

When adapting templates for specific publications:

- Match the font size to the document class (typically 8-10pt for figure labels)
- Use consistent color schemes that work in both color and grayscale
- Align arrow styles across all figures in the paper
- Keep node sizes proportional to their importance in the diagram
- Add descriptive labels rather than relying solely on mathematical notation
- Test figures at the target column width before finalizing

## Integration with Research-Claw

This skill supports the Research-Claw writing workflow:

- Generate LaTeX drawing code from verbal descriptions of desired figures
- Adapt existing templates to match specific research contexts
- Debug TikZ compilation errors and suggest fixes
- Recommend appropriate diagram types for different data structures
- Produce standalone compilable .tex files for figure testing

## Best Practices

- Always use relative positioning instead of absolute coordinates for maintainability
- Define reusable styles at the document or figure level to ensure consistency
- Compile figures as standalone documents first, then include in the main paper
- Use `\footnotesize` or `\scriptsize` for labels inside dense diagrams
- Export to PDF for vector quality and include via `\includegraphics`
- Keep TikZ code well-commented for future modifications by collaborators
