---
name: species-distribution-guide
description: "Species distribution modeling with MaxEnt, SDM methods, and GBIF data"
metadata:
  openclaw:
    emoji: "🐾"
    category: "domains"
    subcategory: "ecology"
    keywords: ["species-distribution", "maxent", "sdm", "gbif", "ecological-niche", "biodiversity", "habitat"]
    source: "wentor"
---

# Species Distribution Modeling Guide

A skill for building and evaluating species distribution models (SDMs), covering occurrence data acquisition from biodiversity databases, environmental predictor preparation, model fitting with MaxEnt and ensemble methods, model evaluation, and projection under climate change scenarios.

## Occurrence Data

### Accessing GBIF Data

The Global Biodiversity Information Facility (GBIF) is the primary source of species occurrence records:

```python
from pygbif import occurrences, species

def download_occurrences(species_name: str, country: str = None,
                          limit: int = 5000,
                          has_coordinate: bool = True) -> dict:
    """
    Download species occurrence records from GBIF.
    species_name: scientific name (e.g., 'Panthera tigris')
    Returns cleaned occurrence records with coordinates.
    """
    # Get GBIF species key
    name_result = species.name_backbone(name=species_name)
    if "usageKey" not in name_result:
        return {"error": f"Species not found: {species_name}"}

    species_key = name_result["usageKey"]

    # Search occurrences
    params = {
        "taxonKey": species_key,
        "hasCoordinate": has_coordinate,
        "hasGeospatialIssue": False,
        "limit": limit,
    }
    if country:
        params["country"] = country

    results = occurrences.search(**params)

    # Clean records
    records = []
    seen_coords = set()
    for rec in results.get("results", []):
        lat = rec.get("decimalLatitude")
        lon = rec.get("decimalLongitude")
        if lat is None or lon is None:
            continue

        # Remove exact duplicates
        coord_key = (round(lat, 4), round(lon, 4))
        if coord_key in seen_coords:
            continue
        seen_coords.add(coord_key)

        records.append({
            "species": rec.get("species", species_name),
            "latitude": lat,
            "longitude": lon,
            "year": rec.get("year"),
            "basis_of_record": rec.get("basisOfRecord"),
            "institution": rec.get("institutionCode"),
            "country": rec.get("country"),
        })

    return {
        "species": species_name,
        "gbif_key": species_key,
        "n_records": len(records),
        "records": records,
    }
```

### Data Cleaning for SDM

```python
import pandas as pd
import numpy as np

def clean_occurrences(records: pd.DataFrame,
                       study_extent: dict = None,
                       thin_distance_km: float = 10.0) -> pd.DataFrame:
    """
    Clean occurrence records for species distribution modeling.
    Removes outliers, duplicates, and applies spatial thinning.

    study_extent: {min_lon, max_lon, min_lat, max_lat}
    thin_distance_km: minimum distance between retained points
    """
    df = records.copy()

    # Remove records with missing coordinates
    df = df.dropna(subset=["latitude", "longitude"])

    # Remove records at (0,0) -- common data error
    df = df[~((df.latitude == 0) & (df.longitude == 0))]

    # Clip to study extent
    if study_extent:
        df = df[
            (df.longitude >= study_extent["min_lon"]) &
            (df.longitude <= study_extent["max_lon"]) &
            (df.latitude >= study_extent["min_lat"]) &
            (df.latitude <= study_extent["max_lat"])
        ]

    # Spatial thinning (grid-based)
    # Convert thinning distance to approximate degrees
    thin_deg = thin_distance_km / 111.0
    df["grid_x"] = (df.longitude / thin_deg).astype(int)
    df["grid_y"] = (df.latitude / thin_deg).astype(int)
    df = df.drop_duplicates(subset=["grid_x", "grid_y"])
    df = df.drop(columns=["grid_x", "grid_y"])

    return df.reset_index(drop=True)
```

## Environmental Predictors

### WorldClim Bioclimatic Variables

The standard predictor set for SDMs:

| Variable | Description | Unit |
|----------|-------------|------|
| BIO1 | Annual Mean Temperature | C x 10 |
| BIO2 | Mean Diurnal Range | C x 10 |
| BIO4 | Temperature Seasonality | SD x 100 |
| BIO5 | Max Temperature of Warmest Month | C x 10 |
| BIO6 | Min Temperature of Coldest Month | C x 10 |
| BIO12 | Annual Precipitation | mm |
| BIO13 | Precipitation of Wettest Month | mm |
| BIO14 | Precipitation of Driest Month | mm |
| BIO15 | Precipitation Seasonality | CV |

### Extracting Environmental Values

```python
import rasterio
from rasterio.sample import sample_gen

def extract_environmental_values(occurrence_coords: np.ndarray,
                                   raster_paths: dict) -> pd.DataFrame:
    """
    Extract environmental variable values at occurrence locations.
    occurrence_coords: array of (longitude, latitude) pairs
    raster_paths: {variable_name: filepath} for each predictor raster
    """
    env_data = {}

    for var_name, raster_path in raster_paths.items():
        with rasterio.open(raster_path) as src:
            values = []
            for lon, lat in occurrence_coords:
                row, col = src.index(lon, lat)
                if 0 <= row < src.height and 0 <= col < src.width:
                    values.append(float(src.read(1)[row, col]))
                else:
                    values.append(np.nan)
            env_data[var_name] = values

    df = pd.DataFrame(env_data)
    df["longitude"] = occurrence_coords[:, 0]
    df["latitude"] = occurrence_coords[:, 1]

    # Remove points with nodata values
    df = df.replace(src.nodata, np.nan).dropna()
    return df
```

## Model Fitting

### MaxEnt (Maximum Entropy)

MaxEnt is the most widely used SDM algorithm for presence-only data:

```python
import subprocess

def run_maxent(samples_csv: str, env_layers_dir: str,
                output_dir: str, features: str = "auto",
                regularization: float = 1.0,
                n_background: int = 10000) -> dict:
    """
    Run MaxEnt species distribution model.
    samples_csv: CSV with columns species, longitude, latitude
    env_layers_dir: directory containing .asc raster files
    output_dir: directory for model outputs
    """
    cmd = [
        "java", "-jar", "maxent.jar",
        "-s", samples_csv,
        "-e", env_layers_dir,
        "-o", output_dir,
        f"betamultiplier={regularization}",
        f"maximumbackground={n_background}",
        "responsecurves=true",
        "jackknife=true",
        "writeplotdata=true",
        "autorun=true",
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    # Parse results from maxentResults.csv
    import csv
    results_file = f"{output_dir}/maxentResults.csv"
    with open(results_file) as f:
        reader = csv.DictReader(f)
        row = next(reader)

    return {
        "training_auc": float(row.get("Training AUC", 0)),
        "test_auc": float(row.get("Test AUC", 0)),
        "n_training": int(row.get("X Training samples", 0)),
        "regularized_gain": float(row.get("Regularized training gain", 0)),
        "important_variables": row.get("Percent contribution", ""),
    }
```

### Ensemble SDM with Python

```python
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_predict
from sklearn.metrics import roc_auc_score

def ensemble_sdm(presence_env: pd.DataFrame,
                  background_env: pd.DataFrame,
                  predictor_cols: list[str]) -> dict:
    """
    Build an ensemble SDM from multiple algorithms.
    presence_env: environmental values at presence points
    background_env: environmental values at background/pseudo-absence points
    """
    # Prepare data
    X_pres = presence_env[predictor_cols].values
    X_bg = background_env[predictor_cols].values
    X = np.vstack([X_pres, X_bg])
    y = np.concatenate([np.ones(len(X_pres)), np.zeros(len(X_bg))])

    models = {
        "random_forest": RandomForestClassifier(n_estimators=500, max_depth=10),
        "gbm": GradientBoostingClassifier(n_estimators=300, max_depth=5,
                                            learning_rate=0.05),
        "logistic": LogisticRegression(max_iter=1000),
    }

    results = {}
    predictions = {}

    for name, model in models.items():
        # Cross-validated predictions
        cv_pred = cross_val_predict(model, X, y, cv=5, method="predict_proba")[:, 1]
        auc = roc_auc_score(y, cv_pred)

        model.fit(X, y)
        results[name] = {"auc": round(auc, 4), "model": model}
        predictions[name] = cv_pred

    # Weighted ensemble (weight by AUC)
    total_auc = sum(r["auc"] for r in results.values())
    ensemble_pred = sum(
        predictions[name] * results[name]["auc"] / total_auc
        for name in models
    )
    ensemble_auc = roc_auc_score(y, ensemble_pred)

    results["ensemble"] = {"auc": round(ensemble_auc, 4)}
    return results
```

## Model Evaluation

### Evaluation Metrics for SDMs

| Metric | Range | Interpretation |
|--------|-------|---------------|
| AUC | 0-1 | Discrimination ability (>0.7 useful, >0.8 good) |
| TSS (True Skill Statistic) | -1 to 1 | Sensitivity + Specificity - 1 |
| Boyce Index | -1 to 1 | Predicted-to-expected ratio consistency |
| Kappa | -1 to 1 | Agreement beyond chance |

```python
def compute_tss(y_true: np.ndarray, y_pred_proba: np.ndarray) -> dict:
    """
    Compute TSS (True Skill Statistic) at the optimal threshold.
    TSS = Sensitivity + Specificity - 1
    """
    from sklearn.metrics import roc_curve

    fpr, tpr, thresholds = roc_curve(y_true, y_pred_proba)
    specificity = 1 - fpr
    tss_values = tpr + specificity - 1

    optimal_idx = np.argmax(tss_values)
    return {
        "tss": round(tss_values[optimal_idx], 4),
        "optimal_threshold": round(thresholds[optimal_idx], 4),
        "sensitivity": round(tpr[optimal_idx], 4),
        "specificity": round(specificity[optimal_idx], 4),
    }
```

## Climate Change Projections

### Projecting Habitat Shifts

SDMs can project future suitable habitat under climate scenarios:

1. Fit model on current climate + occurrences
2. Obtain future climate rasters (CMIP6 SSP scenarios)
3. Predict suitability on future climate surfaces
4. Compare current vs future range to quantify shifts

Key considerations:
- Use multiple GCMs to capture model uncertainty
- Apply clamping for novel climate combinations
- Report range change metrics: area gained, area lost, centroid shift

## Tools and Resources

- **MaxEnt**: Maximum entropy SDM (Java, most cited SDM software)
- **biomod2 (R)**: Ensemble SDM framework with 10+ algorithms
- **Wallace (R Shiny)**: Interactive SDM workflow application
- **pygbif / rgbif**: GBIF data access from Python/R
- **rasterio / terra**: Raster data handling
- **WorldClim (worldclim.org)**: Global climate data at 1km resolution
- **CHELSA**: High-resolution climate data (better for mountainous regions)
- **eBird**: Citizen science bird occurrence data (Cornell Lab)
