---
name: architecture-design-guide
description: "Design principles of form, function, sustainability in architecture"
metadata:
  openclaw:
    emoji: "🏗️"
    category: "domains"
    subcategory: "business"
    keywords: ["architecture", "design", "sustainability", "urban planning", "BIM", "parametric design"]
    source: "wentor-research-plugins"
---

# Architecture Design Guide

## Overview

Architectural research spans the technical, aesthetic, social, and environmental dimensions of the built environment. From structural engineering and building physics to urban theory and computational design, the discipline demands integration across multiple domains. Academic architecture research increasingly focuses on sustainability, computational methods, and evidence-based design -- areas where rigorous methodology is essential.

This guide covers the core principles that inform architectural research: the interplay of form and function, structural logic, environmental performance, and human experience. It also addresses the computational tools (BIM, parametric design, simulation) that have transformed how architects investigate and validate design decisions.

Whether you are conducting research on building performance, urban morphology, computational design methods, or the social impact of built environments, this guide provides the frameworks and tools to ground your work in established architectural theory and current best practices.

## Fundamental Design Principles

### The Vitruvian Triad (Updated)

```
Classical framework (Vitruvius, 1st century BCE):

FIRMITAS (Structural Integrity)
- Structural systems: load paths, material behavior, safety factors
- Building physics: thermal, acoustic, moisture performance
- Durability: service life, maintenance, resilience to hazards
- Modern addition: seismic, wind, and climate resilience

UTILITAS (Function)
- Program: spatial organization, adjacency requirements
- Circulation: movement patterns, wayfinding, accessibility
- Flexibility: adaptability to changing uses over time
- Modern addition: Universal design, inclusive environments

VENUSTAS (Delight)
- Proportion, rhythm, scale, materiality
- Light: natural and artificial, atmosphere, perception
- Cultural meaning: symbolism, context, identity
- Modern addition: Biophilic design, multisensory experience

Contemporary additions:
SUSTAINABILITY (since 1990s)
- Energy performance, carbon footprint, resource efficiency
- Lifecycle assessment, circular economy principles
- Passive strategies, renewable energy integration

SOCIAL RESPONSIBILITY (since 2000s)
- Equity, community engagement, participatory design
- Affordable housing, public space, social infrastructure
- Post-occupancy evaluation, evidence-based design
```

### Design Thinking Process

| Phase | Activities | Outputs |
|-------|-----------|---------|
| Research | Site analysis, precedent study, user research | Brief, program, constraints |
| Concept | Parti development, diagramming, massing | Concept diagrams, parti models |
| Schematic Design | Spatial organization, form development | Floor plans, sections, elevations |
| Design Development | Material selection, systems integration | Detailed drawings, specifications |
| Documentation | Construction documents, specifications | Building permit package |
| Post-Occupancy | Performance monitoring, user satisfaction | POE report, design feedback |

## Structural Systems

### Structural Logic for Researchers

```
Primary structural systems and their research applications:

FRAME STRUCTURES
- Material: Steel, reinforced concrete, timber
- Behavior: Moment-resisting frames, braced frames
- Research topics: Connection design, progressive collapse,
  fire resistance, seismic performance

SHELL STRUCTURES
- Types: Vaults, domes, hyperbolic paraboloids
- Behavior: Membrane forces (compression/tension), minimal bending
- Research topics: Form-finding, buckling, computational geometry
- Key method: Thrust network analysis (Block, 2009)

TENSILE STRUCTURES
- Types: Cable-stayed, membrane, tensegrity
- Behavior: Pure tension, anticlastic curvature
- Research topics: Form-finding, wind loading, material durability
- Key method: Dynamic relaxation, force density method

MASS TIMBER
- Types: CLT (cross-laminated timber), glulam, mass plywood
- Behavior: Orthotropic, fire charring provides structural reserve
- Research topics: Tall timber buildings, connections, moisture
- Growing field: embodied carbon advantages over concrete/steel
```

### Structural Analysis Methods

```python
# Simple structural analysis for research
# Finite element analysis using Python (for educational purposes)

import numpy as np

def analyze_simply_supported_beam(
    length: float,       # meters
    load: float,         # kN/m (uniform distributed load)
    E: float,            # Young's modulus (GPa)
    I: float,            # Moment of inertia (mm^4)
    n_elements: int = 20,
) -> dict:
    """
    Analyze a simply supported beam under uniform load.
    Returns deflection, moment, and shear diagrams.
    """
    x = np.linspace(0, length, n_elements + 1)
    dx = length / n_elements

    # Analytical solutions
    # Maximum moment: wL^2/8
    max_moment = load * length**2 / 8  # kN-m

    # Moment diagram: M(x) = (w*x/2)*(L-x)
    moment = (load * x / 2) * (length - x)

    # Shear diagram: V(x) = w*(L/2 - x)
    shear = load * (length / 2 - x)

    # Deflection: delta(x) = (w*x)/(24*E*I) * (L^3 - 2*L*x^2 + x^3)
    E_pa = E * 1e9  # Convert GPa to Pa
    I_m4 = I * 1e-12  # Convert mm^4 to m^4
    w_nm = load * 1e3  # Convert kN/m to N/m
    deflection = (w_nm * x) / (24 * E_pa * I_m4) * (
        length**3 - 2 * length * x**2 + x**3
    )
    max_deflection = 5 * w_nm * length**4 / (384 * E_pa * I_m4)

    return {
        "x": x,
        "moment_kNm": moment,
        "shear_kN": shear,
        "deflection_mm": deflection * 1000,
        "max_moment_kNm": max_moment,
        "max_deflection_mm": max_deflection * 1000,
        "span_to_deflection_ratio": length / max_deflection if max_deflection > 0 else float("inf"),
    }
```

## Sustainability and Performance

### Building Performance Metrics

| Metric | Unit | Benchmark (Office) | Tool |
|--------|------|-------------------|------|
| Energy Use Intensity (EUI) | kWh/m2/yr | < 100 (LEED Gold) | EnergyPlus, IES-VE |
| Embodied carbon | kgCO2e/m2 | < 500 (RIBA 2030) | One Click LCA, Tally |
| Operational carbon | kgCO2e/m2/yr | < 20 (net zero target) | EnergyPlus |
| Daylight factor | % | > 2% in 80% of area | Radiance, DIVA |
| Thermal comfort | PMV/PPD | PMV -0.5 to +0.5 | CBE Thermal Comfort Tool |
| Indoor air quality | CO2 ppm | < 800 ppm | CONTAM, CFD |

### Passive Design Strategies

```
Climate-responsive design strategies:

HOT-ARID CLIMATE
- Thermal mass: Thick walls absorb daytime heat, release at night
- Courtyard typology: Microclimate creation, stack ventilation
- Shading: Deep overhangs, mashrabiya screens
- Evaporative cooling: Water features, vegetation

HOT-HUMID CLIMATE
- Cross ventilation: Openings on opposite facades
- Elevated structures: Raise above ground for air circulation
- Lightweight construction: Low thermal mass (rapid cooling)
- Solar shading: Extended roofs, louvers

COLD CLIMATE
- Compact form: Minimize surface-to-volume ratio
- Superinsulation: R-40+ walls, R-60+ roof, triple glazing
- Solar gain: South-facing glazing (N hemisphere), thermal storage
- Air tightness: < 0.6 ACH50 (Passive House standard)

TEMPERATE CLIMATE
- Mixed-mode: Natural ventilation + mechanical when needed
- Balanced glazing: Optimize daylight vs. heat gain/loss
- Thermal mass: Moderate mass with night purge ventilation
- Responsive facades: Operable shading, automated louvers
```

## Computational Design Methods

### Parametric Design with Grasshopper/Python

```python
# Example: Parametric facade panel generation
# (Illustrative -- actual implementation uses Grasshopper + RhinoCommon)

import numpy as np

def generate_parametric_facade(
    width: float,
    height: float,
    panel_count_x: int,
    panel_count_y: int,
    solar_data: np.ndarray,  # Solar radiation per panel position
    min_opening: float = 0.1,
    max_opening: float = 0.8,
) -> list:
    """
    Generate facade panel openings responsive to solar radiation.
    Higher radiation = smaller opening (reduce heat gain).
    """
    panels = []
    for i in range(panel_count_x):
        for j in range(panel_count_y):
            radiation = solar_data[i, j]
            normalized = (radiation - solar_data.min()) / (solar_data.max() - solar_data.min())
            # Inverse: more sun = smaller opening
            opening_ratio = max_opening - normalized * (max_opening - min_opening)

            panels.append({
                "position": (i * width / panel_count_x, j * height / panel_count_y),
                "size": (width / panel_count_x, height / panel_count_y),
                "opening_ratio": round(opening_ratio, 3),
                "solar_radiation": round(radiation, 1),
            })
    return panels
```

### BIM for Research

```
Building Information Modeling (BIM) in academic research:

APPLICATIONS:
1. Performance simulation integration (energy, daylight, acoustics)
2. Construction logistics and scheduling research
3. Facility management and digital twin studies
4. Heritage documentation and conservation
5. Parametric and generative design exploration

INTEROPERABILITY STANDARDS:
- IFC (Industry Foundation Classes): Open BIM exchange format
- gbXML: Energy simulation data exchange
- COBie: Facility management data
- CityGML: Urban-scale modeling

RESEARCH TOOLS:
- Revit + Dynamo: Parametric BIM authoring
- ArchiCAD + Grasshopper Live Connection
- BlenderBIM: Open-source BIM (IFC native)
- OpenStudio + EnergyPlus: Energy simulation
- Ladybug/Honeybee: Environmental analysis (Grasshopper)
```

## Best Practices

- **Ground design claims in evidence.** Post-occupancy evaluation and simulation results strengthen design arguments.
- **Use multiple performance metrics.** Energy, daylight, thermal comfort, and embodied carbon often trade off against each other.
- **Document design rationale.** The reasoning behind decisions is as important as the decisions themselves.
- **Engage with architectural theory.** Computational methods are tools, not substitutes for critical thinking about space, meaning, and experience.
- **Validate simulations against measured data.** Calibrated models are far more credible than uncalibrated predictions.
- **Consider the full lifecycle.** Embodied carbon in materials can exceed operational carbon over 60 years.

## References

- Ching, F. D. K. (2014). Architecture: Form, Space, and Order, 4th ed. Wiley.
- [ArchDaily](https://www.archdaily.com/) -- Architectural project database and analysis
- [Ladybug Tools](https://www.ladybug.tools/) -- Environmental analysis for Grasshopper
- Block, P. et al. (2017). Beyond Bending: Reimagining Compression Shells. DETAIL.
- [RIBA 2030 Climate Challenge](https://www.architecture.com/about/policy/climate-action/2030-climate-challenge) -- Carbon benchmarks
