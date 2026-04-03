---
name: metabase-analytics-guide
description: "Guide to Metabase for open-source research data analytics and dashboards"
metadata:
  openclaw:
    emoji: "📋"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["Metabase", "business intelligence", "SQL analytics", "data dashboard", "research analytics", "self-hosted BI"]
    source: "https://github.com/metabase/metabase"
---

# Metabase Analytics Guide

## Overview

Metabase is a powerful open-source business intelligence and analytics tool with over 46K stars on GitHub. It allows researchers and data analysts to explore data, create visualizations, and build dashboards without writing SQL, though it fully supports custom SQL queries for advanced users. Metabase connects to a wide variety of databases and provides a browser-based interface that makes data exploration accessible to team members regardless of their technical background.

For academic research groups and labs, Metabase serves as an excellent self-hosted platform for tracking experimental data, monitoring research progress, and creating shared dashboards for collaborative projects. Its ability to connect directly to PostgreSQL, MySQL, SQLite, and many other databases means it can be pointed at existing research data stores without data migration. Researchers can set up automated reports, scheduled email digests, and shared dashboards that keep the entire team informed.

Metabase's no-code query builder is particularly valuable in interdisciplinary research teams where not all members are comfortable with SQL. Principal investigators, graduate students, and collaborators can all explore the same datasets through an intuitive visual interface while power users retain full SQL access for complex analyses.

## Installation and Setup

### Docker Deployment (Recommended)

```bash
# Quick start with Docker
docker run -d -p 3000:3000 \
  --name metabase \
  -v metabase-data:/metabase-data \
  -e MB_DB_TYPE=postgres \
  -e MB_DB_DBNAME=metabase_app \
  -e MB_DB_PORT=5432 \
  -e MB_DB_USER=$METABASE_DB_USER \
  -e MB_DB_PASS=$METABASE_DB_PASS \
  -e MB_DB_HOST=db-host \
  metabase/metabase

# Access at http://localhost:3000
```

### Docker Compose for Research Lab Setup

```yaml
version: "3.9"
services:
  metabase:
    image: metabase/metabase:latest
    container_name: research-metabase
    ports:
      - "3000:3000"
    environment:
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: metabase_app
      MB_DB_PORT: 5432
      MB_DB_USER: ${METABASE_DB_USER}
      MB_DB_PASS: ${METABASE_DB_PASS}
      MB_DB_HOST: postgres
      MB_SITE_NAME: "Research Lab Analytics"
    depends_on:
      - postgres
    volumes:
      - metabase-data:/metabase-data

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: metabase_app
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pg-data:/var/lib/postgresql/data

volumes:
  metabase-data:
  pg-data:
```

## Connecting Research Databases

Metabase supports connecting to many database types commonly used in research environments.

### Supported Data Sources for Research

- **PostgreSQL** - Primary research databases, experimental records
- **MySQL/MariaDB** - Legacy lab information management systems
- **SQLite** - Local experiment databases, embedded analytics
- **BigQuery** - Large-scale genomic or observational datasets
- **MongoDB** - Semi-structured research data, document stores
- **CSV uploads** - Quick ad-hoc analysis of exported data

### Database Connection Configuration

Navigate to Admin > Databases > Add Database in the Metabase UI. For a typical research PostgreSQL database:

```
Display name: Lab Experiment Database
Host: research-db.lab.university.edu
Port: 5432
Database name: experiments
Username: (use environment variable $DB_USER)
Password: (use environment variable $DB_PASS)
```

Enable "Auto-run queries" and set "Scan frequency" to daily for research databases that update regularly.

## Building Research Dashboards

### Experiment Tracking Dashboard

A common research use case is tracking experiment progress and results. Here is an example SQL query for monitoring experiment completion rates:

```sql
-- Experiment completion overview
SELECT
    e.project_name,
    COUNT(*) AS total_experiments,
    COUNT(CASE WHEN e.status = 'completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN e.status = 'in_progress' THEN 1 END) AS in_progress,
    COUNT(CASE WHEN e.status = 'failed' THEN 1 END) AS failed,
    ROUND(
        COUNT(CASE WHEN e.status = 'completed' THEN 1 END)::NUMERIC /
        NULLIF(COUNT(*), 0) * 100, 1
    ) AS completion_rate
FROM experiments e
WHERE e.created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY e.project_name
ORDER BY completion_rate DESC;
```

### Sample Analysis Summary

```sql
-- Sample processing metrics
SELECT
    DATE_TRUNC('week', s.processed_at) AS week,
    s.sample_type,
    COUNT(*) AS samples_processed,
    AVG(s.quality_score) AS avg_quality,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.processing_time)
        AS median_processing_hours
FROM samples s
WHERE s.processed_at >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('week', s.processed_at), s.sample_type
ORDER BY week DESC, sample_type;
```

### Publication Pipeline Tracker

```sql
-- Track manuscript progress across the lab
SELECT
    p.title,
    p.lead_author,
    p.status,
    p.target_journal,
    p.submission_date,
    CASE
        WHEN p.status = 'draft' THEN 1
        WHEN p.status = 'internal_review' THEN 2
        WHEN p.status = 'submitted' THEN 3
        WHEN p.status = 'revision' THEN 4
        WHEN p.status = 'accepted' THEN 5
        WHEN p.status = 'published' THEN 6
    END AS stage_number,
    CURRENT_DATE - p.last_updated AS days_since_update
FROM publications p
WHERE p.year >= EXTRACT(YEAR FROM CURRENT_DATE) - 1
ORDER BY stage_number, p.last_updated;
```

## Automated Reporting and Alerts

Metabase supports scheduled reports and conditional alerts, which are useful for research operations.

### Setting Up Scheduled Reports

1. Create a dashboard with key metrics (experiment counts, quality scores, etc.)
2. Click the sharing icon and select "Subscriptions"
3. Configure email delivery schedule (e.g., weekly Monday 9 AM)
4. Add recipients from the research team

### Alert Configuration

```
Question: "Failed experiments in last 7 days"
Alert when: Results are above threshold (e.g., > 5 failures)
Check frequency: Daily
Notify: Lab manager email, Slack channel
```

This allows labs to automatically detect quality issues in experimental workflows.

## Embedding Metabase in Research Applications

Metabase supports embedding dashboards into other web applications via iframes or its embedding SDK.

```html
<!-- Embed a dashboard in a lab portal -->
<iframe
  src="http://metabase.lab.internal/public/dashboard/abc123-def456"
  frameborder="0"
  width="100%"
  height="800"
  allowtransparency
></iframe>
```

For authenticated embedding, use signed JWTs to control access:

```python
import jwt
import time

embedding_secret = os.environ["METABASE_EMBEDDING_SECRET"]

payload = {
    "resource": {"dashboard": 42},
    "params": {"project_id": 7},
    "exp": int(time.time()) + 600  # 10-minute expiry
}

signed = jwt.encode(payload, embedding_secret, algorithm="HS256")
embed_url = f"http://metabase.lab.internal/embed/dashboard/{signed}"
```

## Best Practices for Research Teams

- **Organize by project**: Create separate Metabase collections for each research project or grant
- **Use saved questions**: Standardize common analyses as saved questions that team members can reuse
- **Document queries**: Add descriptions to all saved questions explaining the methodology and assumptions
- **Access control**: Use Metabase groups to control which team members can view sensitive data
- **Regular backups**: Schedule database backups, especially for the Metabase application database
- **Version tracking**: Export dashboard definitions as JSON for version control alongside research code

## References

- Metabase official documentation: https://www.metabase.com/docs
- Metabase GitHub repository: https://github.com/metabase/metabase
- Metabase embedding documentation: https://www.metabase.com/docs/latest/embedding
- Metabase API reference: https://www.metabase.com/docs/latest/api
