---
name: seismology-data-guide
description: "Earthquake data analysis, seismogram processing, and seismic research"
metadata:
  openclaw:
    emoji: "🌏"
    category: "domains"
    subcategory: "geoscience"
    keywords: ["seismology", "earthquake", "seismogram", "obspy", "waveform", "geophysics"]
    source: "wentor"
---

# Seismology Data Guide

A skill for processing seismic data, analyzing earthquake catalogs, and working with seismograms using standard tools in observational seismology. Covers data retrieval from global networks, waveform processing with ObsPy, magnitude estimation, focal mechanism analysis, and seismic hazard assessment.

## Seismic Data Sources

### Global Data Centers

| Data Center | Abbreviation | Coverage | Access |
|-------------|-------------|----------|--------|
| IRIS Data Management Center | IRIS DMC | Global broadband | FDSN Web Services |
| European Integrated Data Archive | EIDA | European networks | FDSN Web Services |
| USGS Earthquake Hazards Program | USGS EHP | Global catalog | API + ComCat |
| International Seismological Centre | ISC | Global bulletin | ISC web services |
| NIED F-net | F-net | Japan broadband | NIED website |

### Retrieving Earthquake Catalogs

```python
from obspy.clients.fdsn import Client
from obspy import UTCDateTime

client = Client("IRIS")

# Fetch earthquake catalog for a region and time window
catalog = client.get_events(
    starttime=UTCDateTime("2024-01-01"),
    endtime=UTCDateTime("2024-12-31"),
    minmagnitude=5.0,
    maxmagnitude=9.0,
    minlatitude=30.0, maxlatitude=45.0,
    minlongitude=125.0, maxlongitude=150.0,
    orderby="magnitude",
)

print(f"Found {len(catalog)} events")
for event in catalog[:5]:
    origin = event.preferred_origin()
    mag = event.preferred_magnitude()
    print(f"  M{mag.mag:.1f} {origin.time} "
          f"({origin.latitude:.2f}, {origin.longitude:.2f}) "
          f"depth={origin.depth/1000:.1f} km")
```

## Waveform Processing

### Retrieving and Preprocessing Seismograms

```python
from obspy import UTCDateTime
from obspy.clients.fdsn import Client

client = Client("IRIS")

# Download waveform data for a specific event
t = UTCDateTime("2024-01-01T07:10:00")
st = client.get_waveforms(
    network="IU", station="ANMO", location="00", channel="BHZ",
    starttime=t, endtime=t + 600,  # 10 minutes of data
)

# Standard preprocessing pipeline
st.detrend("demean")        # Remove mean
st.detrend("linear")        # Remove linear trend
st.taper(max_percentage=0.05, type="cosine")  # Taper edges
st.filter("bandpass", freqmin=0.01, freqmax=5.0, corners=4)

# Remove instrument response to get ground velocity (m/s)
inv = client.get_stations(
    network="IU", station="ANMO", location="00", channel="BHZ",
    starttime=t, endtime=t + 600, level="response",
)
st.remove_response(inventory=inv, output="VEL", pre_filt=[0.005, 0.01, 8, 10])
```

### Spectral Analysis

```python
import numpy as np
from scipy.signal import welch

def compute_psd(trace, nperseg=256):
    """
    Compute power spectral density of a seismic trace.
    Returns frequencies (Hz) and PSD (dB relative to 1 (m/s)^2/Hz).
    """
    freqs, psd = welch(
        trace.data,
        fs=trace.stats.sampling_rate,
        nperseg=nperseg,
        noverlap=nperseg // 2,
    )
    psd_db = 10 * np.log10(psd + 1e-30)
    return freqs, psd_db
```

## Phase Picking and Location

### Automatic Phase Arrival Detection

```python
from obspy.signal.trigger import recursive_sta_lta, trigger_onset

def pick_arrivals(trace, sta_seconds=1.0, lta_seconds=30.0,
                  threshold_on=3.5, threshold_off=1.0):
    """
    STA/LTA trigger for P-wave arrival detection.
    sta_seconds: short-term average window
    lta_seconds: long-term average window
    Returns list of (on_sample, off_sample) trigger windows.
    """
    df = trace.stats.sampling_rate
    cft = recursive_sta_lta(
        trace.data,
        int(sta_seconds * df),
        int(lta_seconds * df),
    )
    triggers = trigger_onset(cft, threshold_on, threshold_off)
    return triggers, cft
```

### Earthquake Location

Determining earthquake hypocenter from arrival times:

1. **Grid search**: Evaluate travel-time residuals on a 3D grid
2. **Geiger's method**: Iterative linearized least-squares inversion
3. **NonLinLoc**: Probabilistic non-linear location using Oct-tree sampling
4. **HypoDD**: Double-difference relocation for high-precision relative locations

```python
# Simplified grid search earthquake location
def grid_search_locate(stations, arrival_times, velocity_model,
                       lat_range, lon_range, depth_range, grid_spacing):
    """
    Brute-force grid search for earthquake location.
    Minimizes sum of squared travel-time residuals.
    """
    best_misfit = float("inf")
    best_location = None

    for lat in np.arange(*lat_range, grid_spacing):
        for lon in np.arange(*lon_range, grid_spacing):
            for depth in np.arange(*depth_range, grid_spacing):
                residuals = []
                for sta, obs_time in zip(stations, arrival_times):
                    dist = geodetic_distance(lat, lon, sta.lat, sta.lon)
                    pred_time = velocity_model.get_travel_time(dist, depth)
                    residuals.append((obs_time - pred_time) ** 2)
                misfit = sum(residuals)
                if misfit < best_misfit:
                    best_misfit = misfit
                    best_location = (lat, lon, depth)

    return best_location, best_misfit
```

## Magnitude Estimation

### Common Magnitude Scales

| Scale | Symbol | Measurement | Range |
|-------|--------|------------|-------|
| Local (Richter) | ML | Max amplitude on Wood-Anderson | < 6.5 |
| Body wave | mb | P-wave amplitude at 1 Hz | 4-7 |
| Surface wave | Ms | Rayleigh wave at 20s period | 5-8.5 |
| Moment | Mw | Seismic moment from waveform | All sizes |

Moment magnitude is the standard for modern seismology:

```python
def moment_magnitude(seismic_moment_nm: float) -> float:
    """
    Compute moment magnitude from seismic moment (in Newton-meters).
    Mw = (2/3) * log10(M0) - 6.07  (Hanks and Kanamori, 1979)
    """
    return (2.0 / 3.0) * np.log10(seismic_moment_nm) - 6.07
```

## Focal Mechanisms

Beach ball diagrams represent earthquake source geometry. The fault plane solution requires at least 8-10 well-distributed first-motion polarities (up/down) or full waveform moment tensor inversion.

Tools for focal mechanism determination:
- **HASH**: First-motion focal mechanism (USGS)
- **TDMT_INV**: Time-domain moment tensor inversion
- **ObsPy beachball module**: Plotting focal mechanisms

## Tools and Software

- **ObsPy**: Python framework for seismological data processing
- **SAC (Seismic Analysis Code)**: Classic command-line waveform tool
- **GMT (Generic Mapping Tools)**: Map generation and focal mechanism plotting
- **SeisComP**: Real-time seismic network processing system
- **SPECFEM3D**: Spectral-element wave propagation simulation
- **Pyrocko**: Python toolbox for seismology (Green's functions, source inversion)
