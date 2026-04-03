---
name: climate-modeling-guide
description: "Climate simulation, modeling tools, and climate data analysis methods"
metadata:
  openclaw:
    emoji: "☁️"
    category: "domains"
    subcategory: "geoscience"
    keywords: ["climate", "modeling", "simulation", "netcdf", "cmip", "atmosphere", "global-warming"]
    source: "wentor"
---

# Climate Modeling Guide

A skill for working with climate models and climate data in research contexts. Covers accessing CMIP archives, processing NetCDF data, running idealized climate simulations, statistical downscaling, and analyzing climate projections with Python tools.

## Climate Data Standards

### NetCDF and CF Conventions

Climate data is stored in NetCDF (Network Common Data Form) files following CF (Climate and Forecast) conventions:

```python
import xarray as xr
import numpy as np

# Open a CMIP6 temperature dataset
ds = xr.open_dataset("tas_Amon_CESM2_ssp585_r1i1p1f1_gn_201501-210012.nc")

print(ds)
# Dimensions:  (time: 1032, lat: 192, lon: 288)
# Variables:   tas (surface air temperature, K)
# Attributes:  CF-1.6 compliant, CMIP6 metadata

# Basic inspection
print(f"Variable: {ds.tas.long_name}")
print(f"Units: {ds.tas.units}")
print(f"Time range: {ds.time.values[0]} to {ds.time.values[-1]}")
print(f"Spatial resolution: {np.diff(ds.lat.values[:2])[0]:.2f} deg")
```

### CMIP6 Data Access

The Coupled Model Intercomparison Project Phase 6 provides standardized multi-model climate projections:

```python
# Using intake-esm to search the CMIP6 catalog
import intake

# Open the Pangeo CMIP6 catalog (cloud-hosted on Google Cloud)
url = "https://storage.googleapis.com/cmip6/pangeo-cmip6.json"
col = intake.open_esm_datastore(url)

# Search for monthly surface temperature under SSP5-8.5
query = col.search(
    experiment_id="ssp585",
    variable_id="tas",
    table_id="Amon",
    source_id=["CESM2", "GFDL-ESM4", "UKESM1-0-LL", "MPI-ESM1-2-HR"],
    member_id="r1i1p1f1",
)
print(f"Found {len(query)} datasets from {query.nunique()['source_id']} models")

# Load as xarray datasets (lazy, Zarr-backed)
dsets = query.to_dataset_dict(zarr_kwargs={"consolidated": True})
```

## Climate Analysis Techniques

### Global Mean Temperature Anomaly

```python
def compute_global_mean_anomaly(ds, baseline_start="1850-01-01",
                                  baseline_end="1900-12-31"):
    """
    Compute area-weighted global mean temperature anomaly
    relative to a baseline period.
    """
    # Area weighting by cosine of latitude
    weights = np.cos(np.deg2rad(ds.lat))
    weights.name = "weights"

    # Weighted global mean time series
    global_mean = ds.tas.weighted(weights).mean(dim=["lat", "lon"])

    # Compute baseline climatology
    baseline = global_mean.sel(time=slice(baseline_start, baseline_end))
    climatology = baseline.groupby("time.month").mean("time")

    # Compute anomalies
    anomaly = global_mean.groupby("time.month") - climatology

    # Annual mean anomaly
    annual_anomaly = anomaly.resample(time="YE").mean()
    return annual_anomaly


def multi_model_ensemble(datasets: dict, baseline_period: tuple):
    """
    Compute multi-model ensemble mean and spread for temperature projections.
    datasets: dict of {model_name: xarray.Dataset}
    Returns ensemble mean and 5th/95th percentile bounds.
    """
    anomalies = []
    for name, ds in datasets.items():
        anom = compute_global_mean_anomaly(ds, *baseline_period)
        anom = anom.assign_coords(model=name)
        anomalies.append(anom)

    ensemble = xr.concat(anomalies, dim="model")
    return {
        "mean": ensemble.mean(dim="model"),
        "p05": ensemble.quantile(0.05, dim="model"),
        "p95": ensemble.quantile(0.95, dim="model"),
    }
```

### Climate Indices

Standard indices used in climate research:

| Index | Full Name | Definition |
|-------|-----------|-----------|
| ENSO (Nino3.4) | El Nino Southern Oscillation | SST anomaly in 5S-5N, 170W-120W |
| NAO | North Atlantic Oscillation | SLP difference Iceland - Azores |
| PDO | Pacific Decadal Oscillation | Leading PC of North Pacific SST |
| AMO | Atlantic Multidecadal Oscillation | Detrended North Atlantic SST |
| IOD | Indian Ocean Dipole | SST difference western - eastern Indian Ocean |

```python
def compute_nino34(sst_dataset, baseline="1991-01-01/2020-12-31"):
    """Compute Nino 3.4 index from SST data."""
    # Select Nino 3.4 region
    nino34_region = sst_dataset.tos.sel(
        lat=slice(-5, 5), lon=slice(190, 240)
    )
    # Area-weighted mean
    weights = np.cos(np.deg2rad(nino34_region.lat))
    nino34_ts = nino34_region.weighted(weights).mean(dim=["lat", "lon"])

    # Remove monthly climatology
    clim = nino34_ts.sel(time=slice(*baseline.split("/"))).groupby("time.month").mean()
    nino34_index = nino34_ts.groupby("time.month") - clim

    # 5-month running mean for standard definition
    nino34_smoothed = nino34_index.rolling(time=5, center=True).mean()
    return nino34_smoothed
```

## Statistical Downscaling

### Bias Correction and Spatial Disaggregation

Global climate models (GCMs) typically have 50-200 km resolution, too coarse for impact studies. Statistical downscaling bridges this gap:

```python
def quantile_mapping(obs: np.ndarray, model_hist: np.ndarray,
                     model_future: np.ndarray, n_quantiles: int = 100):
    """
    Quantile mapping bias correction.
    Maps model quantiles to observed quantiles for bias correction.
    """
    quantiles = np.linspace(0, 1, n_quantiles + 1)
    obs_q = np.quantile(obs, quantiles)
    hist_q = np.quantile(model_hist, quantiles)

    # For each future value, find its quantile in historical distribution
    # then map to corresponding observed quantile
    corrected = np.interp(model_future, hist_q, obs_q)
    return corrected
```

### Downscaling Methods Comparison

| Method | Type | Advantages | Limitations |
|--------|------|-----------|-------------|
| Quantile mapping | Statistical | Simple, preserves distribution | Assumes stationarity |
| BCSD | Statistical | Preserves spatial patterns | Limited for extremes |
| Delta method | Statistical | Very simple | Only shifts mean |
| WRF (dynamical) | Physical | Physically consistent | Computationally expensive |
| DeepSD (deep learning) | Hybrid | Learns complex patterns | Requires large training data |

## Running Climate Models

### Simple Energy Balance Model

```python
def energy_balance_model(S0=1361, albedo=0.30, emissivity=0.612):
    """
    Zero-dimensional energy balance model.
    S0: solar constant (W/m2)
    albedo: planetary albedo
    emissivity: effective atmospheric emissivity
    Returns equilibrium surface temperature (K).
    """
    sigma = 5.67e-8  # Stefan-Boltzmann constant
    # Absorbed solar radiation
    absorbed = S0 * (1 - albedo) / 4
    # Surface temperature with greenhouse effect
    T_surface = (absorbed / (emissivity * sigma)) ** 0.25
    return T_surface

T_eq = energy_balance_model()
print(f"Equilibrium surface temperature: {T_eq:.1f} K ({T_eq - 273.15:.1f} C)")
```

## Tools and Resources

- **xarray + dask**: Scalable multi-dimensional climate data analysis
- **CDO (Climate Data Operators)**: Command-line NetCDF processing
- **NCO (NetCDF Operators)**: File manipulation and arithmetic
- **CESM (Community Earth System Model)**: Full-complexity coupled GCM
- **Pangeo**: Cloud-native geoscience data analysis ecosystem
- **ESMValTool**: Community diagnostic and performance metrics for ESMs
- **ClimateData.ca / Copernicus CDS**: Processed climate projection portals
