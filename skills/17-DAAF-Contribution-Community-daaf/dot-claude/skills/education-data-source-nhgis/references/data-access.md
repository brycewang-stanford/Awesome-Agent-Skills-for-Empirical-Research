# Accessing NHGIS Data

Methods for obtaining NHGIS data: via Education Data Portal mirrors (school/college-to-census links) and via direct NHGIS access (custom census analysis).

## Quick Start: Education Data Portal (School/College-Census Links)

For linking schools or colleges to census geography, use the pre-processed data from the Education Data Portal mirrors. **No registration required.**

```python
import polars as pl

# Uses fetch_from_mirrors() — tries each mirror in priority order per mirrors.yaml.
# See fetch-patterns.md and datasets-reference.md for canonical paths.

# School-to-census geography (2020 Census boundaries)
df = fetch_from_mirrors("nhgis/schools_nhgis_geog_2020")

# College-to-census geography (2020 Census boundaries)
df_colleges = fetch_from_mirrors("nhgis/colleges_nhgis_geog_2020")

# Available census years: 1990, 2000, 2010, 2020
# All files contain ALL data years (schools: 1986-2023, colleges: 1980-2023)
# The census year determines which boundary vintage is used for geographic assignment
```

**Available data**: Institution coordinates linked to census tract, block group, block, region, division, CBSA, and place. See `variable-catalog.md` for Portal integer encodings.

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs. Codebook paths are listed in `datasets-reference.md`.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

**For custom census analysis** (tract-level demographics, time series, boundary files): Use NHGIS directly via methods below.

---

## Direct NHGIS Access (Custom Analysis)

For full census data access beyond school/college-census links, register for NHGIS directly. This is separate from the Education Data Portal mirror system.

### Registration

**Required**: Free registration at https://uma.pop.umn.edu/nhgis/user/new

All direct NHGIS access methods require authentication. Registration provides:
- Web interface access
- API key for programmatic access
- Extract history and downloads

## Method 1: NHGIS Data Finder (Web Interface)

### URL
https://data2.nhgis.org/main

### Workflow

1. **Filter data** using sidebar options:
   - Geographic Levels (State, County, Tract, etc.)
   - Years (1790-2023)
   - Topics (Population, Housing, etc.)
   - Datasets (Decennial, ACS periods)

2. **Select data type** (tabs):
   - SOURCE TABLES: Original census tables
   - TIME SERIES TABLES: Harmonized across years
   - GIS FILES: Boundary shapefiles

3. **Add to Data Cart**:
   - Click "+" to add tables/files
   - Review cart contents

4. **Configure extract** (Continue button):
   - Select geographic levels for tables
   - Choose output format (CSV, fixed-width)
   - Select layout for time series

5. **Submit extract**:
   - Extracts queued on server
   - Email notification when ready
   - Download from Extracts History page

### Output Formats

| Format | Extension | Best For |
|--------|-----------|----------|
| CSV | .csv | General use, Excel, Python, R |
| Fixed-width | .dat | Legacy systems, Stata |
| Shapefile | .shp | GIS software |

### Extract Contents

Each extract includes:
- Data file(s) (.csv or .dat)
- Codebook (.txt) - variable descriptions
- For GIS: multiple shapefile components

## Method 2: IPUMS API

### Overview

RESTful API for programmatic data requests.

**Documentation**: https://developer.ipums.org/docs/apiprogram/

### Authentication

```bash
# API key in header
curl -X GET "https://api.ipums.org/metadata/nhgis/datasets" \
  -H "Authorization: YOUR_API_KEY"
```

### Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/metadata/nhgis/datasets` | List available datasets |
| `/metadata/nhgis/data_tables` | List tables |
| `/metadata/nhgis/time_series_tables` | List time series |
| `/extracts/` | Create and manage extracts |

### Creating Extract via API

```python
import requests

api_key = "YOUR_API_KEY"
headers = {"Authorization": api_key}

# Define extract
extract_def = {
    "datasets": {
        "2016_2020_ACS5a": {
            "data_tables": ["B01001"],
            "geog_levels": ["tract"]
        }
    },
    "data_format": "csv_no_header",
    "description": "Population by age, tract level"
}

# Submit extract
response = requests.post(
    "https://api.ipums.org/extracts/?collection=nhgis&version=v1",
    headers=headers,
    json=extract_def
)

extract_id = response.json()["number"]
```

### Checking Extract Status

```python
status_url = f"https://api.ipums.org/extracts/{extract_id}?collection=nhgis&version=v1"
response = requests.get(status_url, headers=headers)
status = response.json()["status"]
# "queued", "started", "completed", "failed"
```

### Downloading Extract

```python
if status == "completed":
    download_links = response.json()["download_links"]
    for link in download_links:
        data = requests.get(link["url"], headers=headers)
        # Save to file
```

## Method 3: ipumspy (Python)

### Installation

```bash
pip install ipumspy
```

### Configuration

```python
from ipumspy import IpumsApiClient, readers

# Initialize client
client = IpumsApiClient(api_key="YOUR_API_KEY")
```

### Creating and Submitting Extract

```python
from ipumspy.nhgis import NhgisExtract

# Define extract
extract = NhgisExtract(
    datasets={
        "2016_2020_ACS5a": {
            "data_tables": ["B01001", "B19013"],
            "geog_levels": ["tract"]
        }
    }
)

# Submit
client.submit_extract(extract)
print(f"Extract number: {extract.extract_id}")
```

### Waiting and Downloading

```python
# Wait for completion
client.wait_for_extract(extract)

# Download
client.download_extract(extract, download_dir="./data")
```

### Reading NHGIS Data

```python
from ipumspy import readers

# Read tabular data with codebook
ddi = readers.read_nhgis_codebook("nhgis_extract_codebook.txt")
data = readers.read_nhgis("nhgis_data.csv", ddi)
```

### Example: Complete Workflow

```python
import polars as pl
from ipumspy import IpumsApiClient
from ipumspy.nhgis import NhgisExtract

# Setup
client = IpumsApiClient("YOUR_API_KEY")

# Define extract: Poverty data for tracts
extract = NhgisExtract(
    datasets={
        "2018_2022_ACS5a": {
            "data_tables": ["B17001"],  # Poverty status
            "geog_levels": ["tract"]
        }
    },
    geographic_extents=["California"],  # Single state
    data_format="csv_header"
)

# Submit and wait
client.submit_extract(extract)
client.wait_for_extract(extract)

# Download
files = client.download_extract(extract, download_dir="./nhgis_data")

# Read data with Polars
df = pl.read_csv(files["data"][0])
```

## Method 4: ipumsr (R)

### Installation

```r
install.packages("ipumsr")
```

### Configuration

```r
library(ipumsr)

# Set API key (or use environment variable IPUMS_API_KEY)
set_ipums_api_key("YOUR_API_KEY")
```

### Creating Extract

```r
# Define NHGIS extract
extract <- define_extract_nhgis(
  description = "Tract poverty data",
  datasets = ds_spec(
    "2018_2022_ACS5a",
    data_tables = "B17001",
    geog_levels = "tract"
  )
)
```

### Submitting and Downloading

```r
# Submit
submitted <- submit_extract(extract)

# Wait for completion
completed <- wait_for_extract(submitted)

# Download
downloaded <- download_extract(completed, download_dir = "./data")
```

### Reading Data

```r
# Read with variable labels
nhgis_data <- read_nhgis(downloaded)

# Access codebook info
nhgis_cb <- read_nhgis_codebook(downloaded)
```

### Time Series Example

```r
# Time series extract
ts_extract <- define_extract_nhgis(
  description = "Population time series",
  time_series_tables = tst_spec(
    "CL8",  # Total population table
    geog_levels = "county",
    years = c("1990", "2000", "2010", "2020")
  )
)

submitted <- submit_extract(ts_extract)
wait_for_extract(submitted)
downloaded <- download_extract(submitted)
```

## Accessing Geographic Crosswalks

Crosswalks are not available via API. Download directly:

### Web Download
https://www.nhgis.org/geographic-crosswalks#download

### Direct URLs (Examples)

```
# 2000 blocks to 2010 tracts
https://secure-assets.ipums.org/nhgis/crosswalks/nhgis_blk2000_tr2010.zip

# 2010 tracts to 2020 tracts
https://secure-assets.ipums.org/nhgis/crosswalks/nhgis_tr2010_tr2020.zip

# State-specific (faster download)
https://secure-assets.ipums.org/nhgis/crosswalks/nhgis_blk2000_blk2010_state/nhgis_blk2000_blk2010_06.zip  # California
```

## Accessing GIS Files

### Via Data Finder

1. Click "GIS FILES" tab
2. Filter by geographic level and year
3. Add to cart and submit extract

### Via API/ipumspy

```python
# Include shapefiles in extract
extract = NhgisExtract(
    datasets={"2016_2020_ACS5a": {...}},
    shapefiles=["2020_tract"]
)
```

### Direct TIGER/Line (Alternative)

For current boundaries only:
https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html

**Note**: NHGIS shapefiles are processed (clipped to coastlines, consistent projection).

## Data Format Details

### CSV Output

```csv
GISJOIN,YEAR,STATE,STATEA,COUNTY,COUNTYA,TRACTA,AJWME001,AJWME002
G0600010000100,2020,California,06,Alameda,001,000100,3245,1587
```

### Key Fields

| Field | Description |
|-------|-------------|
| GISJOIN | NHGIS geographic identifier |
| YEAR | Data year |
| STATE | State name |
| STATEA | State FIPS (with NHGIS suffix) |
| COUNTY | County name |
| COUNTYA | County FIPS (with NHGIS suffix) |
| [Variable codes] | Data values |

### Codebook Format

```
Context Fields 
    GISJOIN:     GIS Join Match Code
    YEAR:        Data File Year
    ...

Table 1:     B01001.    Sex by Age
Universe:    Total population
    AJWME001:    Total
    AJWME002:    Male
    AJWME003:    Male: Under 5 years
    ...
```

## Performance Tips

### Large Extracts

- Select specific states (geographic extent) when possible
- Request only needed geographic levels
- Use fixed-width format for very large files

### Efficient API Usage

```python
# Check if extract exists before resubmitting
existing = client.get_extract_by_id(extract_id, collection="nhgis")
if existing["status"] == "completed":
    # Download existing
    pass
else:
    # Submit new
    pass
```

### Batch Processing

```python
# Submit multiple extracts
extracts = []
for state in ["California", "Texas", "New York"]:
    ext = NhgisExtract(
        datasets={"2016_2020_ACS5a": {...}},
        geographic_extents=[state]
    )
    client.submit_extract(ext)
    extracts.append(ext)

# Wait for all
for ext in extracts:
    client.wait_for_extract(ext)
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Extract stuck "queued" | Server load | Wait; check status |
| "Unauthorized" error | Invalid API key | Regenerate key in account settings |
| Empty data file | Invalid table/level combo | Check Data Finder for valid combinations |
| Missing variables | Table not available for level | Choose different geographic level |
| Shapefile mismatch | Year mismatch | Ensure shapefile year matches data year |

## Citation

Include in publications:

```
Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. 
IPUMS National Historical Geographic Information System: Version 18.0 [dataset]. 
Minneapolis, MN: IPUMS. 2023. http://doi.org/10.18128/D050.V18.0
```

Check https://www.nhgis.org/citation-and-use-nhgis-data for current version.
