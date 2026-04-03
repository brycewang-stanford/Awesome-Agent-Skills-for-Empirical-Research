---
name: conservation-biology-guide
description: "Apply conservation biology methods, databases, and assessment tools"
metadata:
  openclaw:
    emoji: "🌳"
    category: "domains"
    subcategory: "ecology"
    keywords: ["conservation biology", "biodiversity", "IUCN Red List", "species assessment", "habitat modeling", "wildlife"]
    source: "wentor-research-plugins"
---

# Conservation Biology Guide

A skill for conducting conservation biology research, covering species assessment methods, habitat modeling, population viability analysis, key biodiversity databases, and frameworks for conservation prioritization.

## Species Assessment and Red List

### IUCN Red List Categories

```
Extinction Risk Categories (from highest to lowest):

  EX  - Extinct
  EW  - Extinct in the Wild
  CR  - Critically Endangered
  EN  - Endangered
  VU  - Vulnerable
  NT  - Near Threatened
  LC  - Least Concern
  DD  - Data Deficient
  NE  - Not Evaluated

Classification criteria (any one triggers the category):
  A: Population size reduction
  B: Geographic range (extent of occurrence, area of occupancy)
  C: Small population size and decline
  D: Very small or restricted population
  E: Quantitative extinction probability analysis
```

### Querying the IUCN API

```python
import os
import json
import urllib.request


def get_species_assessment(species_name: str) -> dict:
    """
    Retrieve IUCN Red List assessment for a species.

    Args:
        species_name: Scientific name (e.g., 'Panthera tigris')
    """
    api_token = os.environ["IUCN_API_TOKEN"]
    encoded_name = urllib.parse.quote(species_name)
    url = f"https://apiv3.iucnredlist.org/api/v3/species/{encoded_name}?token={api_token}"

    req = urllib.request.Request(url)
    response = urllib.request.urlopen(req)
    data = json.loads(response.read())

    if data.get("result"):
        species = data["result"][0]
        return {
            "scientific_name": species.get("scientific_name"),
            "common_name": species.get("main_common_name"),
            "category": species.get("category"),
            "population_trend": species.get("population_trend"),
            "assessment_date": species.get("assessment_date"),
            "criteria": species.get("criteria")
        }

    return {"error": "Species not found in IUCN Red List"}
```

## Habitat Modeling

### Species Distribution Models (SDMs)

```python
def sdm_workflow(occurrence_data: list[tuple],
                 environmental_layers: list[str],
                 method: str = "maxent") -> dict:
    """
    Outline a species distribution modeling workflow.

    Args:
        occurrence_data: List of (latitude, longitude) tuples
        environmental_layers: List of environmental raster file paths
        method: Modeling method (maxent, glm, rf, boosted_regression)
    """
    return {
        "data_preparation": {
            "occurrences": len(occurrence_data),
            "environmental_variables": len(environmental_layers),
            "steps": [
                "Clean occurrence records (remove duplicates, spatial outliers)",
                "Thin records to reduce spatial autocorrelation (1 per grid cell)",
                "Generate pseudo-absences or background points",
                "Extract environmental values at occurrence/absence points",
                "Check for multicollinearity (VIF < 10)"
            ]
        },
        "modeling": {
            "method": method,
            "methods_available": {
                "maxent": "Maximum entropy (presence-only, widely used)",
                "glm": "Generalized linear model (presence-absence)",
                "rf": "Random forest (handles non-linearities)",
                "boosted_regression": "BRT (good predictive performance)",
                "ensemble": "Combine multiple methods for robustness"
            }
        },
        "validation": {
            "metrics": ["AUC-ROC", "TSS (True Skill Statistic)", "Boyce Index"],
            "methods": [
                "k-fold cross-validation",
                "Spatial block cross-validation (reduces spatial autocorrelation bias)",
                "Independent validation dataset (ideal)"
            ]
        },
        "projection": {
            "current": "Map current suitable habitat",
            "future": "Project under climate change scenarios (SSP1-2.6, SSP5-8.5)",
            "note": "Report uncertainty across climate models and scenarios"
        }
    }
```

## Population Viability Analysis (PVA)

### Estimating Extinction Risk

```
PVA simulates population dynamics to estimate extinction probability
over a given time horizon.

Key inputs:
  - Current population size and structure (age/stage)
  - Vital rates: survival, fecundity (with variance)
  - Carrying capacity and density dependence
  - Environmental and demographic stochasticity
  - Catastrophe frequency and severity
  - Genetic factors (inbreeding depression)

Common software:
  - Vortex: Individual-based PVA simulation
  - RAMAS GIS: Spatially explicit PVA
  - R packages: popbio, lefko3, Compadre for matrix models

Outputs:
  - Probability of extinction over T years
  - Expected minimum population size
  - Population growth rate (lambda) and its variance
  - Sensitivity of persistence to management actions
```

## Key Databases

### Biodiversity Data Sources

| Database | Content | Access |
|----------|---------|--------|
| GBIF | 2+ billion species occurrence records | Free (gbif.org) |
| IUCN Red List | Species assessments and distributions | API + download |
| BIEN | Plant occurrence and trait data (Americas) | Free (biendata.org) |
| eBird | Bird observations worldwide | Free (ebird.org) |
| Protected Planet (WDPA) | Global protected area boundaries | Free (protectedplanet.net) |
| WorldClim | Current and future climate layers | Free (worldclim.org) |
| CHELSA | High-resolution climate data | Free (chelsa-climate.org) |
| Global Forest Watch | Forest cover change | Free (globalforestwatch.org) |

## Conservation Prioritization

### Frameworks for Decision-Making

```
Systematic Conservation Planning (Margules & Pressey):
  1. Compile data on biodiversity features and their distributions
  2. Set conservation targets for each feature
  3. Review existing protected area coverage
  4. Select additional areas using optimization (e.g., Marxan, Zonation)
  5. Implement and manage conservation actions
  6. Monitor outcomes and adapt

Key principles:
  - Representativeness: All species/habitats should be represented
  - Complementarity: Each new area should add maximum new coverage
  - Efficiency: Minimize cost while meeting targets
  - Connectivity: Corridors link protected areas
```

## Reporting Conservation Research

Report species names with taxonomic authority and reference to the taxonomic standard used (e.g., ITIS, Catalogue of Life). Deposit occurrence data in GBIF. Follow the Darwin Core standard for biodiversity data. Use IUCN criteria language when discussing threat status. Clearly state conservation implications and management recommendations, as conservation biology is an applied and mission-driven discipline.
