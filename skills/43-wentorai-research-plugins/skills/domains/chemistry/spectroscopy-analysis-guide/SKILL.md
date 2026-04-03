---
name: spectroscopy-analysis-guide
description: "Spectral data analysis for NMR, IR, mass spectrometry, and UV-Vis"
metadata:
  openclaw:
    emoji: "🔬"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["spectroscopy", "nmr", "mass-spectrometry", "infrared", "uv-vis", "analytical-chemistry"]
    source: "wentor"
---

# Spectroscopy Analysis Guide

A skill for processing and interpreting spectroscopic data in chemistry research. Covers NMR, IR, mass spectrometry, and UV-Vis spectroscopy including data formats, baseline correction, peak detection, spectral matching, and structure elucidation workflows.

## Spectral Data Formats

### Common File Formats

| Format | Spectroscopy | Description |
|--------|-------------|-------------|
| JCAMP-DX (.jdx, .dx) | All types | IUPAC standard exchange format |
| Bruker (1r, fid, acqu) | NMR | Raw and processed Bruker data |
| mzML / mzXML | MS | Open mass spectrometry format |
| SPC (.spc) | IR, UV-Vis | Galactic/Thermo spectral format |
| CSV / TXT | All | Simple x,y pairs (wavelength/wavenumber, intensity) |

### Reading Spectral Data

```python
import numpy as np
from scipy.signal import find_peaks, savgol_filter

def read_jcamp(filepath: str) -> dict:
    """
    Read a JCAMP-DX spectral file.
    Returns x (wavenumber/chemical shift/m/z) and y (intensity) arrays.
    """
    x_data, y_data = [], []
    metadata = {}

    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()
            if line.startswith("##"):
                key_val = line[2:].split("=", 1)
                if len(key_val) == 2:
                    metadata[key_val[0].strip()] = key_val[1].strip()
            elif line and not line.startswith("$$"):
                parts = line.split()
                try:
                    values = [float(v) for v in parts]
                    if len(values) >= 2:
                        x_data.append(values[0])
                        y_data.extend(values[1:])
                except ValueError:
                    continue

    return {
        "x": np.array(x_data),
        "y": np.array(y_data[:len(x_data)]),
        "metadata": metadata,
    }
```

## NMR Spectroscopy

### 1H NMR Processing

```python
import nmrglue as ng

def process_1h_nmr(bruker_dir: str) -> dict:
    """
    Process 1H NMR data from Bruker format using nmrglue.
    bruker_dir: path to Bruker experiment directory
    """
    # Read raw data
    dic, data = ng.bruker.read(bruker_dir)

    # Apply processing
    data = ng.bruker.remove_digital_filter(dic, data)
    data = ng.proc_base.zf_size(data, 65536)     # zero-fill
    data = ng.proc_base.fft(data)                  # Fourier transform
    data = ng.proc_autophase.autops(data, "acme")  # automatic phasing
    data = ng.proc_base.rev(data)                  # reverse spectrum
    data = ng.proc_base.di(data)                   # discard imaginary

    # Generate chemical shift axis (ppm)
    udic = ng.bruker.guess_udic(dic, data)
    uc = ng.fileiobase.uc_from_udic(udic)
    ppm = uc.ppm_scale()

    return {
        "ppm": ppm,
        "spectrum": data.real,
        "sf": dic["acqus"]["SFO1"],       # spectrometer frequency (MHz)
        "sw_ppm": dic["acqus"]["SW"],       # sweep width (ppm)
    }

def pick_nmr_peaks(ppm: np.ndarray, spectrum: np.ndarray,
                    threshold: float = 0.05) -> list[dict]:
    """
    Automatic peak picking for 1H NMR.
    threshold: minimum peak height as fraction of max intensity.
    """
    min_height = threshold * np.max(spectrum)
    indices, properties = find_peaks(
        spectrum, height=min_height, distance=10, prominence=min_height * 0.5
    )

    peaks = []
    for idx in indices:
        peaks.append({
            "ppm": round(float(ppm[idx]), 3),
            "intensity": float(spectrum[idx]),
        })

    # Sort by chemical shift (high to low, NMR convention)
    peaks.sort(key=lambda p: p["ppm"], reverse=True)
    return peaks
```

### Common 1H NMR Chemical Shift Ranges

| Chemical Shift (ppm) | Functional Group |
|----------------------|-----------------|
| 0.8-1.0 | CH3 (methyl, alkyl) |
| 1.2-1.4 | CH2 (methylene, alkyl chain) |
| 2.0-2.5 | CH next to C=O |
| 3.3-3.9 | CH next to O or N (ethers, amines) |
| 4.5-5.5 | Vinyl C=CH2, OCH |
| 6.5-8.5 | Aromatic H |
| 9.0-10.0 | Aldehyde CHO |
| 10.0-12.0 | Carboxylic acid OH |

## Mass Spectrometry

### Processing MS Data

```python
from pyteomics import mzml
import numpy as np

def read_mzml_spectra(filepath: str, ms_level: int = 1) -> list[dict]:
    """
    Read mass spectra from an mzML file.
    ms_level: 1 for MS1 (survey scans), 2 for MS/MS
    """
    spectra = []
    with mzml.read(filepath) as reader:
        for spectrum in reader:
            if spectrum.get("ms level") == ms_level:
                spectra.append({
                    "scan": spectrum["index"],
                    "rt": spectrum["scanList"]["scan"][0].get(
                        "scan start time", 0
                    ),
                    "mz": spectrum["m/z array"],
                    "intensity": spectrum["intensity array"],
                    "tic": np.sum(spectrum["intensity array"]),
                })
    return spectra

def find_molecular_ion(mz: np.ndarray, intensity: np.ndarray,
                        expected_mw: float = None,
                        tolerance_da: float = 0.5) -> list[dict]:
    """
    Identify molecular ion peaks ([M+H]+, [M+Na]+, [M-H]-).
    """
    # Find top peaks
    top_indices = np.argsort(intensity)[::-1][:20]
    candidates = []

    adducts = {
        "[M+H]+": 1.00728,
        "[M+Na]+": 22.98922,
        "[M+K]+": 38.96316,
        "[M-H]-": -1.00728,
        "[M+NH4]+": 18.03437,
    }

    for idx in top_indices:
        peak_mz = mz[idx]
        peak_int = intensity[idx]

        if expected_mw:
            for adduct_name, adduct_mass in adducts.items():
                calc_mw = peak_mz - adduct_mass
                if abs(calc_mw - expected_mw) < tolerance_da:
                    candidates.append({
                        "mz": round(float(peak_mz), 4),
                        "intensity": float(peak_int),
                        "adduct": adduct_name,
                        "calc_mw": round(calc_mw, 4),
                        "error_da": round(abs(calc_mw - expected_mw), 4),
                    })
        else:
            candidates.append({
                "mz": round(float(peak_mz), 4),
                "intensity": float(peak_int),
            })

    return candidates
```

## Infrared Spectroscopy

### IR Peak Assignment

```python
# Standard IR functional group frequency table
IR_ASSIGNMENTS = {
    (3200, 3600): "O-H stretch (broad: alcohol, acid; sharp: free OH)",
    (3300, 3500): "N-H stretch (primary amine: 2 bands; secondary: 1 band)",
    (2850, 3000): "C-H stretch (sp3: 2850-2960; sp2: 3000-3100)",
    (2100, 2260): "Triple bond stretch (C-triple-N: 2210-2260; C-triple-C: 2100-2150)",
    (1680, 1750): "C=O stretch (ketone ~1715; ester ~1735; acid ~1710; amide ~1650)",
    (1600, 1680): "C=C stretch (alkene ~1640; aromatic ~1600, 1500)",
    (1000, 1300): "C-O stretch (ether, ester, alcohol)",
}

def assign_ir_peaks(wavenumber: np.ndarray, absorbance: np.ndarray,
                     threshold: float = 0.1) -> list[dict]:
    """Detect and assign IR absorption peaks to functional groups."""
    # Invert for peak detection (absorbance peaks are positive)
    peaks, properties = find_peaks(absorbance, height=threshold, prominence=0.05)

    assignments = []
    for idx in peaks:
        wn = float(wavenumber[idx])
        assignment = "unassigned"
        for (low, high), group in IR_ASSIGNMENTS.items():
            if low <= wn <= high:
                assignment = group
                break
        assignments.append({
            "wavenumber_cm-1": round(wn, 1),
            "absorbance": round(float(absorbance[idx]), 4),
            "assignment": assignment,
        })

    return sorted(assignments, key=lambda x: x["wavenumber_cm-1"], reverse=True)
```

## Spectral Processing Utilities

### Baseline Correction and Smoothing

```python
def baseline_correction(y: np.ndarray, lam: float = 1e6,
                         p: float = 0.001, n_iter: int = 10) -> np.ndarray:
    """
    Asymmetric least squares baseline correction (Eilers and Boelens, 2005).
    lam: smoothness parameter (larger = smoother baseline)
    p: asymmetry parameter (smaller = more emphasis on fitting below peaks)
    """
    from scipy.sparse import diags, csc_matrix
    from scipy.sparse.linalg import spsolve

    L = len(y)
    D = diags([1, -2, 1], [0, -1, -2], shape=(L, L - 2)).toarray()
    H = lam * D.dot(D.T)
    w = np.ones(L)

    for _ in range(n_iter):
        W = diags(w, 0, shape=(L, L))
        Z = csc_matrix(W + H)
        baseline = spsolve(Z, w * y)
        w = p * (y > baseline) + (1 - p) * (y < baseline)

    return y - baseline

def smooth_spectrum(y: np.ndarray, window: int = 11,
                     polyorder: int = 3) -> np.ndarray:
    """Apply Savitzky-Golay smoothing to a spectrum."""
    return savgol_filter(y, window, polyorder)
```

## Tools and Software

- **nmrglue**: Python NMR data processing (Bruker, Varian, Agilent)
- **pyOpenMS / pyteomics**: Mass spectrometry data processing
- **RDKit**: Molecular structure to predicted spectra
- **MestReNova**: Commercial NMR processing (widely used in chemistry labs)
- **TopSpin (Bruker)**: NMR acquisition and processing
- **SDBS (AIST)**: Free spectral database (IR, NMR, MS)
- **MassBank**: Open mass spectral database
- **NIST Chemistry WebBook**: Reference spectra for IR and MS
