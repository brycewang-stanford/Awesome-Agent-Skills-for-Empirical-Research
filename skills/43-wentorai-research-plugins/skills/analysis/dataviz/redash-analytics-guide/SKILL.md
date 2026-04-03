---
name: redash-analytics-guide
description: "Guide to Redash for SQL-driven research data dashboards and sharing"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["Redash", "SQL dashboards", "data visualization", "query tool", "research analytics", "collaborative BI"]
    source: "https://github.com/getredash/redash"
---

# Redash Analytics Guide

## Overview

Redash is an open-source data visualization and dashboarding tool with over 28K stars on GitHub. It is designed for analysts and researchers who prefer writing SQL to explore and visualize data. Redash connects to virtually any data source that supports SQL or has an API, and provides a browser-based query editor with autocomplete, visualization builder, and dashboard composer.

For academic research groups, Redash offers a lightweight, self-hosted alternative to commercial BI tools. Its SQL-first approach is natural for researchers who already work with databases, and its sharing features make it straightforward to create dashboards that the entire lab can access. Unlike Metabase which emphasizes no-code exploration, Redash is specifically designed for users who are comfortable writing queries and want direct control over their data retrieval logic.

Redash supports over 35 data source types, including PostgreSQL, MySQL, SQLite, BigQuery, Elasticsearch, MongoDB, Google Sheets, CSV files, and even custom Python scripts. This versatility means researchers can build unified dashboards that pull data from multiple sources: experiment databases, survey platforms, instrument logs, and cloud storage.

## Installation and Configuration

### Docker Compose Deployment

```bash
# Clone the Redash setup repository
git clone https://github.com/getredash/setup.git redash-setup
cd redash-setup

# Generate configuration
./setup.sh

# Or manually configure with Docker Compose
```

### Docker Compose Configuration for Research Labs

```yaml
version: "3"
services:
  redash:
    image: redash/redash:latest
    command: server
    ports:
      - "5000:5000"
    environment:
      REDASH_DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres/redash
      REDASH_REDIS_URL: redis://redis:6379/0
      REDASH_SECRET_KEY: ${REDASH_SECRET_KEY}
      REDASH_MAIL_SERVER: smtp.university.edu
      REDASH_MAIL_PORT: 587
      REDASH_MAIL_USERNAME: ${MAIL_USERNAME}
      REDASH_MAIL_PASSWORD: ${MAIL_PASSWORD}
    depends_on:
      - postgres
      - redis

  worker:
    image: redash/redash:latest
    command: worker
    environment:
      REDASH_DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres/redash
      REDASH_REDIS_URL: redis://redis:6379/0
    depends_on:
      - redash

  scheduler:
    image: redash/redash:latest
    command: scheduler
    environment:
      REDASH_DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres/redash
      REDASH_REDIS_URL: redis://redis:6379/0
    depends_on:
      - redash

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: redash
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pg-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data

volumes:
  pg-data:
  redis-data:
```

## Writing Research Queries

### Experiment Results Summary

```sql
-- Aggregate experiment results by condition and time period
SELECT
    e.condition_name,
    DATE_TRUNC('month', e.run_date) AS month,
    COUNT(*) AS num_runs,
    ROUND(AVG(e.primary_outcome)::NUMERIC, 4) AS mean_outcome,
    ROUND(STDDEV(e.primary_outcome)::NUMERIC, 4) AS std_outcome,
    ROUND(AVG(e.primary_outcome)::NUMERIC - 1.96 * STDDEV(e.primary_outcome)::NUMERIC / SQRT(COUNT(*)), 4) AS ci_lower,
    ROUND(AVG(e.primary_outcome)::NUMERIC + 1.96 * STDDEV(e.primary_outcome)::NUMERIC / SQRT(COUNT(*)), 4) AS ci_upper
FROM experiments e
WHERE e.project_id = {{project_id}}
  AND e.run_date >= {{start_date}}
GROUP BY e.condition_name, DATE_TRUNC('month', e.run_date)
ORDER BY month, condition_name;
```

The `{{project_id}}` and `{{start_date}}` syntax creates interactive parameter widgets that users can modify without editing the query.

### Literature Review Metrics

```sql
-- Track literature search and screening progress
SELECT
    r.review_name,
    r.search_database,
    COUNT(DISTINCT a.article_id) AS total_found,
    COUNT(DISTINCT CASE WHEN s.decision = 'include' THEN a.article_id END) AS included,
    COUNT(DISTINCT CASE WHEN s.decision = 'exclude' THEN a.article_id END) AS excluded,
    COUNT(DISTINCT CASE WHEN s.decision IS NULL THEN a.article_id END) AS pending,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.decision IS NOT NULL THEN a.article_id END)::NUMERIC /
        NULLIF(COUNT(DISTINCT a.article_id), 0) * 100, 1
    ) AS screening_progress_pct
FROM systematic_reviews r
JOIN articles a ON a.review_id = r.id
LEFT JOIN screening_decisions s ON s.article_id = a.article_id
WHERE r.review_name = {{review_name}}
GROUP BY r.review_name, r.search_database
ORDER BY total_found DESC;
```

### Grant Funding and Budget Tracking

```sql
-- Monitor research grant expenditures
SELECT
    g.grant_name,
    g.funding_agency,
    g.total_budget,
    SUM(t.amount) AS total_spent,
    g.total_budget - SUM(t.amount) AS remaining,
    ROUND(SUM(t.amount)::NUMERIC / g.total_budget * 100, 1) AS pct_spent,
    g.end_date,
    (g.end_date - CURRENT_DATE) AS days_remaining,
    ROUND(
        (g.total_budget - SUM(t.amount))::NUMERIC /
        NULLIF((g.end_date - CURRENT_DATE), 0), 2
    ) AS daily_burn_budget
FROM grants g
JOIN transactions t ON t.grant_id = g.id
WHERE g.status = 'active'
GROUP BY g.grant_name, g.funding_agency, g.total_budget, g.end_date
ORDER BY pct_spent DESC;
```

## Visualization Types for Research

Redash supports multiple visualization types that can be attached to any query result.

### Available Chart Types

- **Line Chart** - Time-series data, experiment progression, longitudinal studies
- **Bar Chart** - Categorical comparisons, group means, frequency counts
- **Scatter Plot** - Correlation analysis, cluster visualization
- **Pie / Donut Chart** - Distribution breakdowns, category proportions
- **Area Chart** - Cumulative metrics, stacked comparisons
- **Heatmap** - Correlation matrices, temporal patterns
- **Box Plot** - Distribution comparison across groups
- **Map** - Geographic distribution of samples or collaborators
- **Pivot Table** - Cross-tabulation of experimental factors
- **Counter** - Single key metrics (total papers, h-index, sample count)
- **Word Cloud** - Keyword frequency from abstracts or text analysis

### Configuring a Visualization

After running a query, click "New Visualization" and configure:

1. Select the chart type appropriate for your data
2. Map columns to X axis, Y axis, group, and size dimensions
3. Configure axis labels, ranges, and formatting
4. Add annotations for significance levels or thresholds
5. Save and add to a dashboard

## Dashboard Design for Research Labs

### Creating an Effective Research Dashboard

A well-designed research lab dashboard typically includes the following widgets arranged in a logical layout:

1. **Header row**: Key counters (active projects, publications this year, pending reviews)
2. **Progress section**: Line charts showing experiment completion over time
3. **Results section**: Bar charts or box plots comparing treatment conditions
4. **Quality section**: Scatter plots of quality metrics and control charts
5. **Pipeline section**: Tables showing upcoming deadlines and task assignments

### Parameterized Dashboards

Redash dashboards support global parameters that filter all widgets simultaneously:

```
Dashboard Parameters:
- Project: dropdown linked to projects table
- Date Range: date range picker
- Researcher: dropdown linked to team members table
```

This allows a single dashboard template to serve multiple research projects.

## Scheduled Queries and Alerts

### Automatic Data Refresh

Configure queries to run on a schedule to keep dashboards current:

- **Every 5 minutes**: Instrument monitoring, live experiment tracking
- **Hourly**: Computing cluster job status, data pipeline health
- **Daily**: Experiment summaries, publication metrics
- **Weekly**: Lab progress reports, budget summaries

### Alert Configuration

```
Alert: "Low Sample Quality Detected"
Query: samples with quality_score < threshold in last 24h
Condition: When query returns results
Destination: Email to lab manager, Slack channel notification
Rearm after: 1 hour
```

## API Access for Automation

Redash provides a REST API that researchers can use to integrate dashboards into automated workflows.

```python
import requests

REDASH_URL = "http://redash.lab.internal"
redash_key = os.environ["REDASH_API_KEY"]

# Execute a query and get results
def run_query(query_id, parameters=None):
    url = f"{REDASH_URL}/api/queries/{query_id}/results"
    headers = {"Authorization": f"Key {redash_key}"}
    payload = {"parameters": parameters or {}}

    response = requests.post(url, json=payload, headers=headers)
    job = response.json().get("job", {})

    # Poll for results
    while job.get("status") not in (3, 4):
        result = requests.get(
            f"{REDASH_URL}/api/jobs/{job['id']}",
            headers=headers
        )
        job = result.json().get("job", {})

    # Fetch final results
    result = requests.get(
        f"{REDASH_URL}/api/queries/{query_id}/results.json",
        headers=headers
    )
    return result.json()

# Export dashboard data for reporting
results = run_query(42, {"project_id": 7})
```

## References

- Redash official documentation: https://redash.io/help
- Redash GitHub repository: https://github.com/getredash/redash
- Redash setup guide: https://redash.io/help/open-source/setup
- Redash API reference: https://redash.io/help/user-guide/integrations-and-api/api
