---
name: data-collection-automation
description: "Automate survey deployment, data collection, and pipeline management"
metadata:
  openclaw:
    emoji: "🤖"
    category: "research"
    subcategory: "automation"
    keywords: ["data collection", "survey automation", "pipeline", "Qualtrics API", "research automation", "ETL"]
    source: "wentor-research-plugins"
---

# Data Collection Automation Guide

A skill for automating research data collection, survey deployment, and data pipeline management. Covers survey platform APIs, automated data retrieval, quality checks, ETL pipelines, and scheduling for longitudinal studies.

## Survey Platform APIs

### Qualtrics API

```python
import os
import json
import urllib.request
import time


def export_qualtrics_responses(survey_id: str,
                                file_format: str = "csv") -> str:
    """
    Export survey responses from Qualtrics via API.

    Args:
        survey_id: The Qualtrics survey ID (SV_...)
        file_format: Export format (csv, json, spss)
    """
    api_token = os.environ["QUALTRICS_API_TOKEN"]
    data_center = os.environ["QUALTRICS_DATACENTER"]
    base_url = f"https://{data_center}.qualtrics.com/API/v3"

    headers = {
        "X-API-TOKEN": api_token,
        "Content-Type": "application/json"
    }

    # Step 1: Start export
    export_data = json.dumps({
        "format": file_format,
        "compress": False
    }).encode("utf-8")

    req = urllib.request.Request(
        f"{base_url}/surveys/{survey_id}/export-responses",
        data=export_data,
        headers=headers
    )
    response = json.loads(urllib.request.urlopen(req).read())
    progress_id = response["result"]["progressId"]

    # Step 2: Poll for completion
    status = "inProgress"
    while status == "inProgress":
        time.sleep(2)
        req = urllib.request.Request(
            f"{base_url}/surveys/{survey_id}/export-responses/{progress_id}",
            headers=headers
        )
        check = json.loads(urllib.request.urlopen(req).read())
        status = check["result"]["status"]

    file_id = check["result"]["fileId"]

    # Step 3: Download file
    req = urllib.request.Request(
        f"{base_url}/surveys/{survey_id}/export-responses/{file_id}/file",
        headers=headers
    )
    file_data = urllib.request.urlopen(req).read()

    output_path = f"responses_{survey_id}.{file_format}"
    with open(output_path, "wb") as f:
        f.write(file_data)

    return output_path
```

### REDCap API

```python
def export_redcap_records(api_url: str, fields: list[str] = None) -> list:
    """
    Export records from a REDCap project.

    Args:
        api_url: REDCap API endpoint URL
        fields: List of field names to export (None = all fields)
    """
    api_token = os.environ["REDCAP_API_TOKEN"]

    data = {
        "token": api_token,
        "content": "record",
        "format": "json",
        "type": "flat"
    }

    if fields:
        data["fields"] = ",".join(fields)

    encoded = urllib.parse.urlencode(data).encode("utf-8")
    req = urllib.request.Request(api_url, data=encoded)
    response = urllib.request.urlopen(req)

    return json.loads(response.read())
```

## Automated Data Quality Checks

### Validation Pipeline

```python
import pandas as pd
from datetime import datetime


def validate_survey_data(df: pd.DataFrame,
                          rules: dict) -> dict:
    """
    Run automated data quality checks on collected data.

    Args:
        df: DataFrame of survey responses
        rules: Dict of column -> validation rule pairs
    """
    issues = []

    # Check for duplicates
    dupes = df.duplicated(subset=["respondent_id"]).sum()
    if dupes > 0:
        issues.append(f"Found {dupes} duplicate respondent IDs")

    # Check completion rates
    completion = df.notna().mean()
    low_completion = completion[completion < 0.5]
    for col in low_completion.index:
        issues.append(f"Column '{col}' has {low_completion[col]:.0%} completion")

    # Check value ranges
    for col, rule in rules.items():
        if col not in df.columns:
            continue
        if "min" in rule:
            violations = (df[col] < rule["min"]).sum()
            if violations > 0:
                issues.append(f"{violations} values below minimum in '{col}'")
        if "max" in rule:
            violations = (df[col] > rule["max"]).sum()
            if violations > 0:
                issues.append(f"{violations} values above maximum in '{col}'")

    # Check for speeding (unusually fast completion)
    if "duration_seconds" in df.columns:
        median_time = df["duration_seconds"].median()
        speeders = (df["duration_seconds"] < median_time * 0.3).sum()
        if speeders > 0:
            issues.append(f"{speeders} respondents completed in <30% of median time")

    return {
        "n_records": len(df),
        "n_issues": len(issues),
        "issues": issues,
        "timestamp": datetime.now().isoformat()
    }
```

## ETL Pipeline for Research Data

### Scheduled Data Retrieval

```python
def research_etl_pipeline(sources: list[dict],
                           output_dir: str) -> dict:
    """
    Extract, transform, and load research data from multiple sources.

    Args:
        sources: List of data source configurations
        output_dir: Directory to save processed data
    """
    results = {}

    for source in sources:
        name = source["name"]

        # Extract
        if source["type"] == "qualtrics":
            raw_path = export_qualtrics_responses(source["survey_id"])
            df = pd.read_csv(raw_path)
        elif source["type"] == "redcap":
            records = export_redcap_records(source["api_url"])
            df = pd.DataFrame(records)
        elif source["type"] == "csv_url":
            df = pd.read_csv(source["url"])
        else:
            continue

        # Transform
        df = df.dropna(how="all")
        df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

        # Load
        timestamp = datetime.now().strftime("%Y%m%d")
        output_path = f"{output_dir}/{name}_{timestamp}.csv"
        df.to_csv(output_path, index=False)

        results[name] = {
            "records": len(df),
            "columns": len(df.columns),
            "output": output_path
        }

    return results
```

## Scheduling and Monitoring

### Cron-Based Scheduling

```bash
# Run data collection pipeline daily at 6 AM
# crontab -e
0 6 * * * cd /path/to/project && python collect_data.py >> logs/collection.log 2>&1
```

### Monitoring Checklist

```
For longitudinal studies, automate monitoring of:
  - Response rates per wave (alert if below threshold)
  - Data quality metrics (completion, speeding, straight-lining)
  - API quota usage (stay within rate limits)
  - Storage usage and backup status
  - Participant dropout patterns
```

## Ethical Considerations

Always ensure automated data collection complies with your IRB/ethics board approval. Store API tokens securely using environment variables, never in code. Implement data encryption at rest. Log all data access for audit trails. Respect rate limits on external APIs. Include automated checks for consent status before processing participant data.
