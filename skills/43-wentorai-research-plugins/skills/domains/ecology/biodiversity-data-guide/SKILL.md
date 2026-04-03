---
name: biodiversity-data-guide
description: "Biodiversity data access, species occurrence, and ecological tools"
metadata:
  openclaw:
    emoji: "🍃"
    category: "domains"
    subcategory: "ecology"
    keywords: ["biodiversity", "taxonomy", "ecology", "evolutionary biology"]
    source: "wentor-research-plugins"
---

# Biodiversity Data Guide

Access, analyze, and visualize biodiversity data from global databases including GBIF, iNaturalist, and GenBank for ecological and evolutionary research.

## Major Biodiversity Data Sources

| Database | Content | Records | API | Cost |
|----------|---------|---------|-----|------|
| GBIF | Species occurrence records | 2.4B+ | Yes | Free |
| iNaturalist | Citizen science observations | 180M+ | Yes | Free |
| GenBank (NCBI) | Genetic sequences | 250M+ | Yes | Free |
| BOLD Systems | DNA barcode records | 15M+ | Yes | Free |
| eBird | Bird observations | 1.3B+ | Yes | Free |
| IUCN Red List | Conservation status | 160,000+ | Yes | Free (with key) |
| OBIS | Marine biodiversity | 100M+ | Yes | Free |
| Catalogue of Life | Taxonomic backbone | 2M+ species | Yes | Free |
| TRY Plant Trait | Plant functional traits | 12M+ | Request | Free |
| WorldClim | Climate data (rasters) | Global | Download | Free |

## Querying GBIF (Species Occurrences)

### Python (pygbif)

```python
from pygbif import species as sp
from pygbif import occurrences as occ

# Search for a species by name
name_result = sp.name_backbone(name="Panthera tigris", rank="species")
taxon_key = name_result["usageKey"]
print(f"GBIF taxon key: {taxon_key}")
print(f"Status: {name_result['status']}")
print(f"Kingdom: {name_result['kingdom']}")

# Get occurrence records
results = occ.search(
    taxonKey=taxon_key,
    hasCoordinate=True,       # Only georeferenced records
    country="IN",             # India
    limit=100,
    year="2020,2024",         # Year range
    basisOfRecord="HUMAN_OBSERVATION"
)

print(f"Total records matching: {results['count']}")
for record in results["results"][:5]:
    print(f"  [{record.get('year')}] {record.get('decimalLatitude'):.4f}, "
          f"{record.get('decimalLongitude'):.4f} - {record.get('datasetName', 'N/A')}")
```

### R (rgbif)

```r
library(rgbif)
library(sf)
library(ggplot2)

# Get occurrence data
tiger_key <- name_backbone(name = "Panthera tigris")$usageKey

occurrences <- occ_search(
  taxonKey = tiger_key,
  hasCoordinate = TRUE,
  limit = 500,
  year = "2020,2024",
  basisOfRecord = "HUMAN_OBSERVATION"
)

# Convert to spatial data
occ_df <- occurrences$data
coords <- occ_df[, c("decimalLongitude", "decimalLatitude")]
occ_sf <- st_as_sf(coords, coords = c("decimalLongitude", "decimalLatitude"),
                    crs = 4326)

# Map occurrences
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
ggplot() +
  geom_sf(data = world, fill = "grey90") +
  geom_sf(data = occ_sf, color = "red", size = 1, alpha = 0.5) +
  coord_sf(xlim = c(60, 150), ylim = c(-10, 50)) +
  labs(title = "Panthera tigris occurrences (2020-2024)") +
  theme_minimal()
ggsave("tiger_map.pdf", width = 10, height = 6)
```

## Species Distribution Modeling

### MaxEnt Workflow

```r
library(dismo)
library(raster)

# 1. Get occurrence data
occ_data <- occ_search(taxonKey = tiger_key, hasCoordinate = TRUE,
                       limit = 1000)$data
occ_points <- occ_data[, c("decimalLongitude", "decimalLatitude")]
occ_points <- na.omit(occ_points)

# 2. Get environmental predictors (WorldClim bioclimatic variables)
bioclim <- getData("worldclim", var = "bio", res = 10)
# bio1 = Annual Mean Temperature
# bio12 = Annual Precipitation
# bio4 = Temperature Seasonality
# ... (19 bioclimatic variables total)

# 3. Extract environmental values at occurrence points
env_values <- extract(bioclim, occ_points)

# 4. Generate background (pseudo-absence) points
bg_points <- randomPoints(bioclim, n = 10000)

# 5. Fit MaxEnt model
me_model <- maxent(bioclim, occ_points, a = bg_points,
                    args = c("betamultiplier=1.5",
                             "responsecurves=true"))

# 6. Predict habitat suitability
prediction <- predict(me_model, bioclim)
plot(prediction, main = "Predicted Habitat Suitability")
points(occ_points, pch = 16, cex = 0.5)

# 7. Evaluate model
eval_result <- evaluate(me_model, p = occ_points, a = bg_points,
                        x = bioclim)
print(paste("AUC:", round(eval_result@auc, 3)))
```

## Phylogenetic Analysis

### Building a Phylogeny

```r
library(ape)
library(phytools)

# Read alignment (FASTA format)
alignment <- read.FASTA("aligned_sequences.fasta")

# Distance-based tree (Neighbor-Joining)
dist_matrix <- dist.dna(alignment, model = "TN93")
nj_tree <- nj(dist_matrix)

# Root the tree
rooted_tree <- root(nj_tree, outgroup = "outgroup_species")

# Plot phylogeny
plot(rooted_tree, type = "phylogram", cex = 0.8)
axisPhylo()

# Maximum likelihood tree (using phangorn)
library(phangorn)
data_phyDat <- phyDat(alignment, type = "DNA")
ml_tree <- pml_bb(data_phyDat, model = "GTR+G+I",
                   rearrangement = "NNI")
```

### Comparative Methods

```r
library(caper)

# Phylogenetic independent contrasts
# Test whether body mass predicts home range size
# while accounting for phylogenetic relatedness

trait_data <- data.frame(
  species = c("Sp_A", "Sp_B", "Sp_C", "Sp_D"),
  body_mass = c(5.2, 12.1, 3.8, 45.0),
  home_range = c(10, 25, 8, 120)
)

# Create comparative data object
comp_data <- comparative.data(
  phy = rooted_tree,
  data = trait_data,
  names.col = species,
  vcv = TRUE
)

# Phylogenetic Generalized Least Squares (PGLS)
pgls_model <- pgls(log(home_range) ~ log(body_mass),
                    data = comp_data,
                    lambda = "ML")  # Estimate Pagel's lambda
summary(pgls_model)
```

## Ecological Data Analysis

### Diversity Metrics

```python
import numpy as np
from scipy.stats import entropy

def calculate_diversity(abundance_vector):
    """Calculate common biodiversity metrics."""
    n = np.array(abundance_vector)
    N = n.sum()
    p = n / N  # Relative abundances
    p = p[p > 0]  # Remove zeros

    return {
        "species_richness": len(n[n > 0]),
        "shannon_H": entropy(p, base=np.e),
        "simpson_D": 1 - np.sum(p**2),
        "evenness_J": entropy(p, base=np.e) / np.log(len(p)),
        "fisher_alpha": estimate_fisher_alpha(n),
        "total_abundance": int(N)
    }

def estimate_fisher_alpha(n):
    """Estimate Fisher's alpha diversity parameter."""
    from scipy.optimize import brentq
    S = len(n[n > 0])
    N = n.sum()
    def equation(alpha):
        return alpha * np.log(1 + N/alpha) - S
    try:
        return brentq(equation, 0.1, 1000)
    except ValueError:
        return np.nan

# Example: Bird community survey
abundances = [45, 23, 12, 8, 5, 3, 2, 1, 1]
metrics = calculate_diversity(abundances)
for key, val in metrics.items():
    print(f"  {key}: {val:.4f}" if isinstance(val, float) else f"  {key}: {val}")
```

### Community Analysis

```r
library(vegan)

# Species abundance matrix (sites x species)
community <- matrix(c(
  10, 5, 3, 0, 1,
  8, 12, 0, 2, 3,
  0, 1, 15, 8, 0,
  2, 0, 12, 10, 1
), nrow = 4, byrow = TRUE,
dimnames = list(paste0("Site", 1:4), paste0("Sp", 1:5)))

# Alpha diversity
diversity(community, index = "shannon")  # Shannon H
diversity(community, index = "simpson")  # Simpson 1-D

# Beta diversity (Bray-Curtis dissimilarity)
bc_dist <- vegdist(community, method = "bray")

# NMDS ordination
nmds <- metaMDS(community, distance = "bray", k = 2)
plot(nmds, type = "t")

# PERMANOVA (testing group differences)
env_data <- data.frame(habitat = c("forest", "forest", "grassland", "grassland"))
adonis2(community ~ habitat, data = env_data, method = "bray")
```

## Data Standards and Best Practices

### Darwin Core Standard

Darwin Core (DwC) is the standard schema for biodiversity data exchange:

| Term | Description | Example |
|------|-------------|---------|
| `scientificName` | Full taxonomic name | "Panthera tigris (Linnaeus, 1758)" |
| `decimalLatitude` | Latitude in decimal degrees | 27.1751 |
| `decimalLongitude` | Longitude in decimal degrees | 78.0421 |
| `eventDate` | Date of observation | "2024-03-15" |
| `basisOfRecord` | Type of record | "HUMAN_OBSERVATION" |
| `coordinateUncertaintyInMeters` | Spatial precision | 100 |
| `institutionCode` | Data provider | "iNaturalist" |

### Data Quality Checks

1. **Coordinate validation**: Flag points in oceans for terrestrial species (and vice versa)
2. **Taxonomic verification**: Match names against Catalogue of Life or GBIF backbone
3. **Temporal consistency**: Remove records with impossible dates
4. **Duplicate detection**: Remove spatial and temporal duplicates
5. **Environmental outliers**: Flag occurrences in climatically unsuitable areas
6. **Sampling bias correction**: Use spatial thinning or bias files in SDMs
