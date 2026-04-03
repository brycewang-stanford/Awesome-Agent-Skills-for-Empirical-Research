# Economist Data Skill

**Tagline:** *Real data, not articles about data.*

## Goal

This skill ensures economists and researchers make conscious, explicit decisions about data specifications before any data is retrieved. It only directs users to authoritative, high-quality sources.

## Problem It Solves

When AI agents search the web for economic data, they often return:
- News articles *about* the data, not the data itself
- Unreliable or outdated sources
- Data without clear methodology or provenance
- Inconsistent formats that require manual cleaning

This leads to:
- Invalid analysis from mixing incompatible data specifications
- Wasted time cleaning and reformatting
- Reproducibility failures ("where did this number come from?")
- Silent errors from misunderstood data definitions

## Solution

The Economist Data Skill enforces data rigor by:

### 1. Mandatory Decision Points
Before fetching ANY data, users must explicitly confirm:
- **Price basis**: Nominal vs Real (and if real: base year, deflator method)
- **Seasonal adjustment**: SA vs NSA
- **Frequency**: Annual, Quarterly, Monthly
- **Currency**: USD, EUR, local currency, PPP-adjusted

### 2. Authoritative Sources Only
The skill directs to official statistics and peer-reviewed sources:
- Official: FRED, BLS, BEA, World Bank, IMF, OECD, Eurostat
- Academic: Penn World Table, Maddison Project, World Inequality Database
- Journal replication data: AEA, QJE, REStud, Econometrica

### 3. Tidy Data Output
All output follows tidy data principles with mandatory metadata:
- Consistent schema across all requests
- Required `source` and `accessed_date` columns for provenance
- Software-specific code snippets (R, Python, Stata)

## Compatibility

**This skill is designed to be used in conjunction with Playwright MCP or similar browser automation tools.**

The skill provides the *intelligence* (what to fetch, where to go, what questions to ask), while browser automation provides the *capability* (navigating websites, downloading data).

| AI Agent | Browser Automation |
|----------|-------------------|
| Claude | [Playwright MCP](https://github.com/anthropics/mcp-playwright) |
| Other agents | Playwright, Selenium, Puppeteer, or equivalent |

Without browser automation, this skill cannot fetch data from web sources.

## Usage

1. Ensure browser automation is configured
2. Load the skill prompt
3. Request data (e.g., "Get US inflation data for the last 10 years")
4. Answer the mandatory specification questions
5. Confirm the data request summary
6. Receive tidy data with full provenance

## Files

- `economist-data-skill.md` - The full skill prompt/instructions

## Why "The Friction is the Feature"

Taking 30 seconds to confirm data specifications prevents hours of rework from bad data. The explicit decision points aren't obstacles - they're guardrails that ensure research integrity.
