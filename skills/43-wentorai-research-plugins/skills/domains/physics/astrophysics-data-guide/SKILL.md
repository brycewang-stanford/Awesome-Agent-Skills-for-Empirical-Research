---
name: astrophysics-data-guide
description: "Astronomical data processing with Astropy, FITS files, and sky surveys"
metadata:
  openclaw:
    emoji: "🔭"
    category: "domains"
    subcategory: "physics"
    keywords: ["astrophysics", "astronomy", "astropy", "fits", "photometry", "spectroscopy", "sky-survey"]
    source: "wentor"
---

# Astrophysics Data Guide

A skill for processing and analyzing astronomical data using standard astrophysics tools. Covers FITS file handling, coordinate transformations, photometric analysis, spectral analysis, catalog cross-matching, and accessing major sky survey archives.

## Astronomical Data Formats

### FITS Files

FITS (Flexible Image Transport System) is the standard data format in astronomy:

```python
from astropy.io import fits
import numpy as np

def inspect_fits(filepath: str) -> dict:
    """
    Inspect the structure of a FITS file.
    Returns information about each HDU (Header/Data Unit).
    """
    with fits.open(filepath) as hdul:
        info = []
        for i, hdu in enumerate(hdul):
            entry = {
                "index": i,
                "name": hdu.name,
                "type": type(hdu).__name__,
            }
            if hdu.data is not None:
                entry["shape"] = hdu.data.shape
                entry["dtype"] = str(hdu.data.dtype)
            if hasattr(hdu, "columns") and hdu.columns is not None:
                entry["columns"] = [c.name for c in hdu.columns]
            info.append(entry)
        return {"filename": filepath, "n_hdus": len(hdul), "hdus": info}

def read_fits_image(filepath: str, hdu_index: int = 0) -> tuple:
    """Read a FITS image and its WCS (World Coordinate System)."""
    from astropy.wcs import WCS

    with fits.open(filepath) as hdul:
        data = hdul[hdu_index].data
        header = hdul[hdu_index].header
        wcs = WCS(header)

    return data, wcs, header
```

### Working with FITS Tables

```python
from astropy.table import Table

def read_fits_catalog(filepath: str, hdu: int = 1) -> Table:
    """Read a FITS binary table extension as an Astropy Table."""
    catalog = Table.read(filepath, hdu=hdu)
    print(f"Catalog: {len(catalog)} objects, {len(catalog.columns)} columns")
    print(f"Columns: {catalog.colnames}")
    return catalog
```

## Coordinate Systems

### Astronomical Coordinate Transformations

```python
from astropy.coordinates import SkyCoord, EarthLocation, AltAz
from astropy.time import Time
import astropy.units as u

def coordinate_transforms(ra_deg: float, dec_deg: float) -> dict:
    """
    Transform between astronomical coordinate systems.
    ra_deg, dec_deg: right ascension and declination in degrees (ICRS/J2000)
    """
    coord = SkyCoord(ra=ra_deg * u.degree, dec=dec_deg * u.degree, frame="icrs")

    return {
        "icrs": {
            "ra": coord.ra.to_string(unit=u.hourangle, precision=2),
            "dec": coord.dec.to_string(unit=u.degree, precision=2),
        },
        "galactic": {
            "l": round(coord.galactic.l.degree, 4),
            "b": round(coord.galactic.b.degree, 4),
        },
        "ecliptic": {
            "lon": round(coord.geocentricmeanecliptic.lon.degree, 4),
            "lat": round(coord.geocentricmeanecliptic.lat.degree, 4),
        },
    }

def compute_altaz(ra_deg: float, dec_deg: float,
                   obs_time: str, location: tuple) -> dict:
    """
    Compute altitude and azimuth for a target from a given location and time.
    location: (latitude_deg, longitude_deg, elevation_m)
    """
    target = SkyCoord(ra=ra_deg * u.degree, dec=dec_deg * u.degree)
    time = Time(obs_time)
    loc = EarthLocation(
        lat=location[0] * u.degree,
        lon=location[1] * u.degree,
        height=location[2] * u.m,
    )
    altaz_frame = AltAz(obstime=time, location=loc)
    altaz = target.transform_to(altaz_frame)

    return {
        "altitude_deg": round(altaz.alt.degree, 2),
        "azimuth_deg": round(altaz.az.degree, 2),
        "airmass": round(altaz.secz.value, 3) if altaz.alt.degree > 0 else None,
        "is_observable": altaz.alt.degree > 10,
    }
```

## Photometric Analysis

### Aperture Photometry

```python
from photutils.aperture import CircularAperture, CircularAnnulus
from photutils.aperture import aperture_photometry

def perform_aperture_photometry(image: np.ndarray,
                                  positions: list[tuple],
                                  aperture_radius: float = 5.0,
                                  annulus_inner: float = 10.0,
                                  annulus_outer: float = 15.0) -> list[dict]:
    """
    Perform aperture photometry with local background subtraction.
    image: 2D numpy array (flux/counts)
    positions: list of (x, y) pixel coordinates of sources
    """
    apertures = CircularAperture(positions, r=aperture_radius)
    annuli = CircularAnnulus(positions, r_in=annulus_inner, r_out=annulus_outer)

    # Measure flux in aperture and annulus
    phot_table = aperture_photometry(image, [apertures, annuli])

    results = []
    for row in phot_table:
        # Background per pixel from annulus
        annulus_area = np.pi * (annulus_outer**2 - annulus_inner**2)
        bkg_per_pixel = row["aperture_sum_1"] / annulus_area

        # Background-subtracted flux
        aperture_area = np.pi * aperture_radius**2
        net_flux = row["aperture_sum_0"] - bkg_per_pixel * aperture_area

        # Instrumental magnitude
        if net_flux > 0:
            inst_mag = -2.5 * np.log10(net_flux)
        else:
            inst_mag = float("nan")

        results.append({
            "x": float(row["xcenter"]),
            "y": float(row["ycenter"]),
            "raw_flux": float(row["aperture_sum_0"]),
            "net_flux": round(float(net_flux), 2),
            "bkg_per_pixel": round(float(bkg_per_pixel), 2),
            "inst_mag": round(inst_mag, 4),
        })

    return results
```

### Source Detection

```python
from photutils.detection import DAOStarFinder
from astropy.stats import sigma_clipped_stats

def detect_sources(image: np.ndarray, fwhm: float = 3.0,
                    threshold_sigma: float = 5.0) -> Table:
    """
    Detect point sources in an astronomical image using DAOFind algorithm.
    """
    mean, median, std = sigma_clipped_stats(image, sigma=3.0)
    daofind = DAOStarFinder(fwhm=fwhm, threshold=threshold_sigma * std)
    sources = daofind(image - median)

    if sources is not None:
        sources.sort("flux", reverse=True)
        print(f"Detected {len(sources)} sources")
    return sources
```

## Spectral Analysis

### Processing 1D Spectra

```python
from specutils import Spectrum1D, SpectralRegion
from specutils.analysis import line_flux, equivalent_width, centroid
import astropy.units as u

def analyze_spectrum(wavelength: np.ndarray,
                      flux: np.ndarray,
                      line_center: float,
                      line_width: float = 10.0) -> dict:
    """
    Analyze an emission or absorption line in a 1D spectrum.
    wavelength: array in Angstroms
    flux: array in erg/s/cm2/Angstrom
    line_center: expected line center in Angstroms
    line_width: width of spectral region to analyze
    """
    spectrum = Spectrum1D(
        spectral_axis=wavelength * u.Angstrom,
        flux=flux * u.Unit("erg / (s cm2 Angstrom)"),
    )

    region = SpectralRegion(
        (line_center - line_width) * u.Angstrom,
        (line_center + line_width) * u.Angstrom,
    )

    measured_flux = line_flux(spectrum, regions=region)
    ew = equivalent_width(spectrum, regions=region)
    center = centroid(spectrum, region)

    # Redshift from line center offset
    rest_wavelength = line_center  # assumed rest frame
    z = (center.value - rest_wavelength) / rest_wavelength

    return {
        "line_flux": f"{measured_flux:.4e}",
        "equivalent_width": f"{ew:.2f}",
        "measured_center_A": round(center.value, 2),
        "redshift": round(z, 6),
        "velocity_km_s": round(z * 299792.458, 1),
    }
```

## Survey Data Access

### Querying Major Archives

```python
from astroquery.vizier import Vizier
from astroquery.simbad import Simbad
from astroquery.sdss import SDSS

def query_simbad(object_name: str) -> dict:
    """Query SIMBAD for basic object information."""
    result = Simbad.query_object(object_name)
    if result is None:
        return {"found": False}

    return {
        "found": True,
        "name": object_name,
        "ra": str(result["RA"][0]),
        "dec": str(result["DEC"][0]),
        "object_type": str(result["OTYPE"][0]),
    }

def cone_search_vizier(ra_deg: float, dec_deg: float,
                        radius_arcmin: float = 1.0,
                        catalog: str = "II/246") -> Table:
    """
    Cone search in a VizieR catalog.
    Default catalog II/246 = 2MASS Point Source Catalog.
    """
    coord = SkyCoord(ra=ra_deg * u.degree, dec=dec_deg * u.degree)
    result = Vizier.query_region(
        coord, radius=radius_arcmin * u.arcmin, catalog=catalog
    )
    return result[0] if result else None
```

### Key Sky Surveys

| Survey | Band | Coverage | Resolution | Key Science |
|--------|------|----------|-----------|-------------|
| SDSS | ugriz | 14,555 sq deg | 1.3" | Galaxy evolution, QSOs |
| 2MASS | JHK | All-sky | 2" | Stellar populations, MW structure |
| WISE | 3.4-22 um | All-sky | 6-12" | Brown dwarfs, AGN, dusty galaxies |
| Gaia DR3 | G, BP, RP | All-sky | 0.1 mas | Astrometry, stellar parameters |
| DESI | Spectroscopic | 14,000 sq deg | Fiber | Dark energy, BAO |
| JWST | 0.6-28 um | Pointed | 0.03-0.1" | Early universe, exoplanets |

## Tools and Software

- **Astropy**: Core Python library for astronomy (coordinates, FITS, tables, units)
- **photutils**: Photometry tools (detection, aperture/PSF photometry)
- **specutils**: Spectral analysis (line fitting, equivalent widths)
- **astroquery**: Unified interface to astronomical databases
- **reproject**: Image reprojection between WCS frames
- **ccdproc**: CCD image reduction pipeline
- **SAOImageDS9**: Interactive FITS image viewer
- **TOPCAT**: Interactive catalog cross-matching and visualization
