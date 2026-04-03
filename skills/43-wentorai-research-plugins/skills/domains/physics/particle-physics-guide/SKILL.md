---
name: particle-physics-guide
description: "Particle physics data analysis with ROOT, HEPData, and event processing"
metadata:
  openclaw:
    emoji: "🌀"
    category: "domains"
    subcategory: "physics"
    keywords: ["particle-physics", "root", "hepdata", "collider", "event-analysis", "high-energy-physics"]
    source: "wentor"
---

# Particle Physics Guide

A skill for analyzing particle physics data, covering event reconstruction, histogram analysis, statistical methods for discovery, and the standard tools used in high-energy physics (HEP) research. Includes ROOT, uproot, pyhf, and HEPData workflows.

## Data Formats and Access

### HEP Data Ecosystem

| Format | Description | Typical Size | Access Tool |
|--------|-------------|-------------|-------------|
| ROOT (.root) | Columnar binary format, HEP standard | GB-TB | ROOT, uproot |
| NanoAOD | Compact analysis format (CMS) | ~1 KB/event | uproot, coffea |
| DAOD_PHYS | Derived analysis format (ATLAS) | ~10 KB/event | ROOT, uproot |
| HepMC | Monte Carlo event record | Variable | pyhepmc |
| HEPData | Published results (YAML/JSON) | KB | hepdata_lib |

### Reading ROOT Files with uproot

```python
import uproot
import awkward as ak
import numpy as np

def load_nanoaod(filepath: str, tree_name: str = "Events",
                  branches: list[str] = None) -> ak.Array:
    """
    Load a NanoAOD ROOT file into an awkward array.
    branches: list of branch names to load (None = all)
    """
    with uproot.open(filepath) as f:
        tree = f[tree_name]
        if branches is None:
            branches = tree.keys()
        events = tree.arrays(branches, library="ak")

    print(f"Loaded {len(events)} events")
    print(f"Branches: {events.fields}")
    return events

# Example: Load muon data
events = load_nanoaod("nano_data.root", branches=[
    "nMuon", "Muon_pt", "Muon_eta", "Muon_phi", "Muon_mass",
    "Muon_charge", "Muon_pfRelIso04_all", "Muon_tightId",
])
```

## Event Selection and Reconstruction

### Dimuon Invariant Mass

```python
def compute_invariant_mass(pt1, eta1, phi1, mass1,
                            pt2, eta2, phi2, mass2):
    """
    Compute invariant mass of a particle pair from 4-momentum components.
    Uses the relativistic energy-momentum relation.
    """
    # Convert to Cartesian 4-vectors
    px1 = pt1 * np.cos(phi1)
    py1 = pt1 * np.sin(phi1)
    pz1 = pt1 * np.sinh(eta1)
    e1 = np.sqrt(px1**2 + py1**2 + pz1**2 + mass1**2)

    px2 = pt2 * np.cos(phi2)
    py2 = pt2 * np.sin(phi2)
    pz2 = pt2 * np.sinh(eta2)
    e2 = np.sqrt(px2**2 + py2**2 + pz2**2 + mass2**2)

    # Invariant mass of the pair
    m_inv = np.sqrt(
        (e1 + e2)**2 - (px1 + px2)**2 - (py1 + py2)**2 - (pz1 + pz2)**2
    )
    return m_inv

def select_z_candidates(events):
    """
    Select Z -> mu+mu- candidates from NanoAOD events.
    Requires exactly 2 opposite-sign muons passing quality cuts.
    """
    # Quality cuts
    muon_mask = (
        (events.Muon_pt > 20) &            # pT > 20 GeV
        (abs(events.Muon_eta) < 2.4) &     # |eta| < 2.4
        (events.Muon_tightId == True) &     # tight muon ID
        (events.Muon_pfRelIso04_all < 0.15) # relative isolation
    )

    # Apply mask and require exactly 2 muons
    good_muons = events[muon_mask]
    dimuon_events = good_muons[ak.num(good_muons.Muon_pt) == 2]

    # Opposite sign requirement
    opposite_sign = (
        dimuon_events.Muon_charge[:, 0] * dimuon_events.Muon_charge[:, 1] < 0
    )
    z_candidates = dimuon_events[opposite_sign]

    # Compute invariant mass
    m_inv = compute_invariant_mass(
        z_candidates.Muon_pt[:, 0], z_candidates.Muon_eta[:, 0],
        z_candidates.Muon_phi[:, 0], z_candidates.Muon_mass[:, 0],
        z_candidates.Muon_pt[:, 1], z_candidates.Muon_eta[:, 1],
        z_candidates.Muon_phi[:, 1], z_candidates.Muon_mass[:, 1],
    )

    return m_inv
```

## Statistical Methods for Discovery

### Hypothesis Testing with pyhf

```python
import pyhf

def build_counting_model(signal: float, background: float,
                          bkg_uncertainty: float) -> dict:
    """
    Build a simple counting experiment model in pyhf.
    signal: expected signal yield
    background: expected background yield
    bkg_uncertainty: relative uncertainty on background
    """
    model = pyhf.simplemodels.uncorrelated_background(
        signal=[signal],
        bkg=[background],
        bkg_uncertainty=[bkg_uncertainty * background],
    )

    # Observed data (background-only for expected limit)
    data = [background] + model.config.auxdata

    return {"model": model, "data": data}

def compute_cls(model, data, poi_values=None):
    """
    Compute CLs exclusion limits (frequentist hypothesis test).
    Uses the CLs method standard in HEP.
    """
    if poi_values is None:
        poi_values = np.linspace(0, 5, 50)

    obs_cls = []
    exp_cls = []

    for mu in poi_values:
        result = pyhf.infer.hypotest(
            mu, data, model["model"],
            test_stat="qtilde",
            return_expected_set=True,
        )
        obs_cls.append(float(result[0]))
        exp_cls.append([float(v) for v in result[1]])

    return {
        "poi_values": poi_values.tolist(),
        "observed_cls": obs_cls,
        "expected_cls": exp_cls,
    }
```

### Discovery Significance

```python
def discovery_significance(n_observed: float, n_background: float,
                            sigma_b: float = 0) -> dict:
    """
    Compute discovery significance for a counting experiment.
    n_observed: number of observed events
    n_background: expected background
    sigma_b: uncertainty on background
    """
    from scipy.stats import norm

    if sigma_b == 0:
        # Simple Poisson significance
        # Z = sqrt(2 * (n * ln(n/b) - (n - b)))
        if n_observed <= n_background:
            z = 0
        else:
            z = np.sqrt(2 * (
                n_observed * np.log(n_observed / n_background)
                - (n_observed - n_background)
            ))
    else:
        # With systematic uncertainty (profile likelihood approximation)
        tau = n_background / sigma_b**2
        n = n_observed
        b = n_background
        z = np.sqrt(2 * (
            n * np.log((n * (b + tau)) / (b**2 + n * tau))
            - (b**2 / tau) * np.log(1 + tau * (n - b) / (b * (b + tau)))
        ))

    p_value = 1 - norm.cdf(z)

    return {
        "z_significance": round(z, 4),
        "p_value": p_value,
        "is_evidence": z >= 3.0,       # 3 sigma = evidence
        "is_discovery": z >= 5.0,      # 5 sigma = discovery
    }
```

## Histogram Analysis

### Binned Fitting

```python
from scipy.optimize import curve_fit

def fit_breit_wigner_plus_bg(bin_centers: np.ndarray,
                               bin_contents: np.ndarray,
                               mass_range: tuple = (80, 100)) -> dict:
    """
    Fit a Breit-Wigner (resonance) + polynomial background to a mass histogram.
    Standard approach for Z boson mass measurement.
    """
    def model(m, N_sig, M_Z, Gamma_Z, a0, a1):
        # Breit-Wigner
        bw = N_sig * Gamma_Z / (2 * np.pi) / (
            (m - M_Z)**2 + (Gamma_Z / 2)**2
        )
        # Linear background
        bg = a0 + a1 * (m - 91.0)
        return bw + bg

    mask = (bin_centers >= mass_range[0]) & (bin_centers <= mass_range[1])
    x = bin_centers[mask]
    y = bin_contents[mask]

    p0 = [1000, 91.2, 2.5, 10, 0]  # initial guess
    popt, pcov = curve_fit(model, x, y, p0=p0, sigma=np.sqrt(y + 1))
    perr = np.sqrt(np.diag(pcov))

    return {
        "M_Z": f"{popt[1]:.3f} +/- {perr[1]:.3f} GeV",
        "Gamma_Z": f"{popt[2]:.3f} +/- {perr[2]:.3f} GeV",
        "N_signal": f"{popt[0]:.0f} +/- {perr[0]:.0f}",
        "chi2_ndf": round(np.sum(((y - model(x, *popt))**2 / (y + 1))) / (len(x) - 5), 2),
    }
```

## Monte Carlo Simulation

### Event Generation Pipeline

```
1. Matrix element calculation (MadGraph, Sherpa, POWHEG)
   --> Hard scattering process (e.g., pp -> Z -> mu+mu-)

2. Parton shower (Pythia, Herwig)
   --> QCD radiation, initial/final state radiation

3. Hadronization (Pythia string model, Herwig cluster model)
   --> Quarks/gluons -> hadrons

4. Detector simulation (Geant4 via CMSSW/Athena, or Delphes for fast sim)
   --> Particle interactions with detector material

5. Reconstruction
   --> Raw hits -> tracks, clusters, physics objects
```

## Tools and Software

- **ROOT**: C++ data analysis framework (CERN), ubiquitous in HEP
- **uproot**: Pure Python ROOT file reader (no ROOT dependency)
- **awkward-array**: Columnar data with variable-length nested structure
- **coffea**: Analysis framework built on uproot + awkward + dask
- **pyhf**: Pure Python HistFactory for statistical models
- **MadGraph5_aMC@NLO**: Automated matrix element generation
- **Pythia 8**: Monte Carlo event generator (parton shower + hadronization)
- **Delphes**: Fast detector simulation framework
- **HEPData**: Repository for published HEP measurements
