# IPEDS Finance Data: GASB vs FASB

Understanding the critical differences between accounting standards used by public and private institutions.

## Contents

- [The Core Problem](#the-core-problem)
- [Accounting Standards Overview](#accounting-standards-overview)
- [History of Finance Forms](#history-of-finance-forms)
- [GASB (Public Institutions)](#gasb-public-institutions)
- [FASB (Private Institutions)](#fasb-private-institutions)
- [Revenue Comparisons](#revenue-comparisons)
- [Expense Comparisons](#expense-comparisons)
- [Cross-Sector Analysis](#cross-sector-analysis)
- [Finance Data Quality Issues](#finance-data-quality-issues)
- [Common Finance Metrics](#common-finance-metrics)

## The Core Problem

**Public and private institutions use different accounting standards that are NOT directly comparable.**

| Standard | Institution Type | Governing Body |
|----------|-----------------|----------------|
| GASB | Public | Governmental Accounting Standards Board |
| FASB | Private nonprofit | Financial Accounting Standards Board |
| FASB | Private for-profit | Financial Accounting Standards Board |

**Critical Rule**: Do NOT compare finance data across sectors without understanding these differences.

## Accounting Standards Overview

### Why Different Standards?

- **Public institutions** are part of state/local government systems
- **Private institutions** are independent nonprofit or for-profit entities
- Different accounting rules for government vs business entities

### IPEDS Finance Forms

| Form | Institution Type | Standard |
|------|-----------------|----------|
| F1 | Public | GASB |
| F2 | Private nonprofit | FASB |
| F2 | Public using FASB (~20 institutions) | FASB |
| F3 | Private for-profit | FASB |

### Key Structural Differences

| Aspect | GASB (Public) | FASB (Private) |
|--------|--------------|----------------|
| Revenue classification | Operating vs non-operating | By restriction level |
| State appropriations | Major category | N/A (not received) |
| Net assets | Net position | Net assets by restriction |
| Pell Grant treatment | Federal non-operating revenue | May be passthrough |

## History of Finance Forms

### Timeline

| Period | Public Institutions | Private Institutions |
|--------|--------------------|--------------------|
| 1987-1996 | Common Form | Common Form |
| 1997-2001 | Common Form | FASB |
| 2002-2003 | GASB (phased in) | FASB |
| 2004-2009 | GASB | FASB |
| 2010-present | GASB Aligned | FASB Aligned |
| 2014-15+ | GASB Aligned | FASB Aligned (F3 revised) |

**Implication**: Pre-2004 data for public institutions uses different format; trend analysis must account for this.

## GASB (Public Institutions)

### Revenue Categories

#### Operating Revenues
Generated from institution's principal activities.

| Category | Examples |
|----------|----------|
| Tuition and fees (net) | After scholarship discounts |
| Federal grants and contracts | Sponsored research, etc. |
| State grants and contracts | State-funded research |
| Local grants and contracts | Local government funding |
| Private grants and contracts | Foundation research grants |
| Sales and services of educational activities | Testing services, clinics |
| Auxiliary enterprises | Housing, dining, bookstore |
| Hospital revenue | If institution has hospital |
| Independent operations | Related but separate entities |

#### Non-Operating Revenues
Not from principal activities.

| Category | Examples |
|----------|----------|
| Federal appropriations | Rarely used |
| State appropriations | PRIMARY public funding source |
| Local appropriations | Local tax support |
| Federal non-operating grants | Pell Grants, SEOG |
| State non-operating grants | State financial aid |
| Gifts | Private donations |
| Investment income | Endowment returns, interest |
| Other non-operating | Miscellaneous |

#### Other Revenues and Additions
Capital and endowment related.

| Category | Examples |
|----------|----------|
| Capital appropriations | State funding for buildings |
| Capital grants and gifts | Donations for construction |
| Additions to permanent endowments | Endowment contributions |
| Other | Miscellaneous |

### Expense Categories (Functional)

| Function | Description |
|----------|-------------|
| Instruction | Teaching and instructional support |
| Research | Sponsored and institutional research |
| Public service | Community service, extension |
| Academic support | Libraries, academic computing |
| Student services | Admissions, counseling, career services |
| Institutional support | Administration, legal, HR |
| Operation and maintenance of plant | Facilities, grounds |
| Scholarships and fellowships | Aid NOT applied to charges |
| Auxiliary enterprises | Housing, dining, bookstore expenses |
| Hospital services | Hospital operations |
| Independent operations | Related but separate entities |
| Other | Miscellaneous |

### Net Position

| Category | Definition |
|----------|------------|
| Net investment in capital assets | Property minus related debt |
| Restricted expendable | Can be spent but with restrictions |
| Restricted nonexpendable | Cannot be spent (endowment principal) |
| Unrestricted | No donor/grantor restrictions |

## FASB (Private Institutions)

### Revenue Categories (F2 - Nonprofit)

| Category | Description |
|----------|-------------|
| Tuition and fees (net) | After discounts and allowances |
| Federal appropriations/grants/contracts | All federal revenue |
| State appropriations/grants/contracts | All state revenue |
| Local appropriations/grants/contracts | All local revenue |
| Private gifts, grants, contracts | Donations and private grants |
| Contributions from affiliated entities | Related organizations |
| Investment return | Endowment and other investments |
| Sales and services of educational activities | Non-auxiliary revenue |
| Sales and services of auxiliary enterprises | Housing, dining, etc. |
| Hospital revenue | If applicable |
| Independent operations | Related but separate |
| Other | Miscellaneous |

### Revenue by Restriction Level (F2 Only)

| Level | Definition |
|-------|------------|
| Unrestricted | No donor restrictions |
| Temporarily restricted | Time or purpose restrictions |
| Permanently restricted | Cannot be spent (endowment) |

### Expense Categories (Functional)

Same functional categories as GASB but:
- "Net grant aid to students" instead of "Scholarships and fellowships"
- May have different allocation methods

### For-Profit Differences (F3)

| Aspect | F3 Treatment |
|--------|--------------|
| Restrictions | Not applicable |
| Revenue categories | Simplified |
| Owner's equity | Reported instead of net assets |
| Tax status | Different financial structure |

## Revenue Comparisons

### What's Comparable

| Category | GASB | FASB | Comparable? |
|----------|------|------|-------------|
| Tuition and fees | Yes | Yes | Yes (net) |
| Federal research | Operating + non-operating | Single category | Requires sum |
| State support | Appropriations | Grants/contracts | Partially |
| Private gifts | Gifts | Gifts, grants, contracts | Requires mapping |
| Investment income | Investment income | Investment return | Similar |
| Auxiliary | Yes | Yes | Yes |

### State Appropriations Issue

| Sector | Treatment |
|--------|-----------|
| Public (GASB) | Major revenue source, clearly reported |
| Private (FASB) | Not applicable - don't receive appropriations |

**Impact**: Cannot compare "government support" across sectors because public institutions receive direct appropriations that private institutions do not.

### Pell Grant Treatment

| Standard | Treatment |
|----------|-----------|
| GASB | Federal non-operating revenue, net of discounts |
| FASB (some) | Federal grant revenue |
| FASB (others) | Passthrough transaction (not revenue) |

**Problem**: If a FASB institution treats Pell as passthrough:
- Not counted as federal revenue
- Not counted as discount/allowance to tuition
- Revenue totals may be lower than comparable GASB institution

## Expense Comparisons

### More Comparable Than Revenues

Functional expense categories are more standardized:

| Function | GASB | FASB | Comparable? |
|----------|------|------|-------------|
| Instruction | Yes | Yes | Yes |
| Research | Yes | Yes | Yes |
| Public service | Yes | Yes | Yes |
| Academic support | Yes | Yes | Yes |
| Student services | Yes | Yes | Yes |
| Institutional support | Yes | Yes | Yes |
| Scholarships (net) | Yes | Yes | Terminology differs |
| Auxiliary | Yes | Yes | Yes |

### Natural Classification

Both report by natural classification:
- Salaries and wages
- Benefits
- Operations and maintenance
- Depreciation
- Interest

This is more comparable across sectors than functional classification.

### Depreciation Differences

| Issue | Impact |
|-------|--------|
| Historical vs current cost | Different base values |
| Useful life estimates | May differ |
| Asset categories | May be classified differently |

## Cross-Sector Analysis

### When It's Acceptable

| Scenario | Approach |
|----------|----------|
| Within-sector comparison | Safe |
| Public to public | Safe |
| Private NP to private NP | Safe |
| Cross-sector with caution | Note limitations |

### Harmonization Approaches

#### Delta Cost Project

The Delta Cost Project (Urban Institute) created harmonized finance data:
- Adjusts for GASB/FASB differences
- Creates comparable categories
- Available through IPEDS Data Center

#### Manual Harmonization

```python
# Example: Total education and general expenses
# Must sum functional categories consistently

# GASB
e_and_g_gasb = (
    instruction + research + public_service +
    academic_support + student_services + 
    institutional_support + 
    operation_maintenance + 
    scholarships_fellowships
)

# FASB (similar but verify category names)
e_and_g_fasb = (
    instruction + research + public_service +
    academic_support + student_services + 
    institutional_support + 
    operation_maintenance + 
    net_grant_aid
)
```

### Metrics That Cross Sectors

| Metric | Cross-Sector? | Notes |
|--------|--------------|-------|
| Tuition revenue per FTE | Caution | Net vs gross |
| Instruction expense per FTE | Yes | Functional is comparable |
| Admin expense per FTE | Yes | Institutional support |
| Total expense per FTE | Caution | Different inclusions |
| Endowment per FTE | Limited | Different reporting |

## Finance Data Quality Issues

### Data Lag

Finance data typically has a 1-2 year lag:
- FY 2024 data available in early 2026
- Institutions report after fiscal year close
- Audited figures may be delayed

### Affiliated Entities

| Issue | Impact |
|-------|--------|
| Hospital finances | May be separate or included |
| Foundations | May not be consolidated |
| Research parks | Variable inclusion |

### System vs Campus

For multi-campus systems:
- Each campus may report separately
- System office may report separately
- Some consolidated reporting

### Restatements

Institutions may restate prior years:
- Accounting changes
- Error corrections
- Audit findings

Check for unusual year-over-year changes.

## Common Finance Metrics

### Expense Per FTE

```python
# Most common metric
instruction_per_fte = instruction_expenses / total_fte
total_exp_per_fte = total_expenses / total_fte
```

### Revenue Composition

```python
# What share comes from each source
tuition_share = tuition_revenue / total_revenue * 100
state_share = state_appropriations / total_revenue * 100
```

### Net Tuition Revenue

```python
# Tuition after discounts
net_tuition = gross_tuition - tuition_discounts_allowances
```

### Education and General Spending

```python
# Core education spending (excludes auxiliary, hospital)
e_and_g = (instruction + research + public_service + 
           academic_support + student_services + 
           institutional_support + 
           operation_maintenance + 
           scholarships_fellowships)
```

### Instruction Share

```python
# Share of spending on instruction
instruction_share = instruction / total_core_expenses * 100
```

## Variable Reference

> Verify these variable names against the live codebook. Use `get_codebook_url()` from `fetch-patterns.md`:
> ```python
> url = get_codebook_url("ipeds/codebook_colleges_ipeds_finance")
> ```

> **CRITICAL: Portal vs NCES Variable Names.** The Portal `finance` dataset uses descriptive variable names (e.g., `rev_appropriations_state`, `exp_instruc_total`), NOT the NCES form-field codes (`f1a01`, `f2a01`). The NCES codes are shown below for cross-reference with source documentation only.

### Portal Revenue Variables (Selected)

| Portal Variable | Description | NCES Form Field |
|-----------------|-------------|-----------------|
| `rev_tuition` | Tuition and fees (net) | F1A01 / F2A01 |
| `rev_appropriations_fed` | Federal appropriations | F1A02 |
| `rev_appropriations_state` | State appropriations | F1A03 |
| `rev_appropriations_local` | Local appropriations | F1A04 |
| `rev_grants_contracts_federal` | Federal grants and contracts | F1A05 |
| `rev_grants_contracts_state` | State grants and contracts | F1A06 |
| `rev_grants_contracts_local` | Local grants and contracts | F1A07 |
| `rev_gifts_grants_contracts` | Private gifts, grants, contracts | F1A08 / F2A05 |
| `rev_investment_return` | Investment income/return | F1A09 / F2A07 |
| `rev_edu_services_sales` | Sales/services educational activities | F1A10 / F2A08 |
| `rev_auxiliary_enterprises_net` | Auxiliary enterprises (net) | F1A11 / F2A09 |
| `rev_hospital` | Hospital revenue | F1A12 |
| `rev_affiliated_entities` | Contributions from affiliated entities | F2A06 |
| `rev_operating` | Total operating revenue | — |
| `rev_nonoperating` | Total non-operating revenue | — |

### Portal Expense Variables (Selected)

| Portal Variable | Description | NCES Form Field |
|-----------------|-------------|-----------------|
| `exp_instruc_total` | Instruction (total) | F*B01 |
| `exp_research_total` | Research (total) | F*B02 |
| `exp_pub_serv_total` | Public service (total) | F*B03 |
| `exp_acad_supp_total` | Academic support (total) | F*B04 |
| `exp_student_serv_total` | Student services (total) | F*B05 |
| `exp_inst_supp_total` | Institutional support (total) | F*B06 |
| `exp_net_grant_aid_total` | Scholarships/fellowships (net) | F*B08 |
| `exp_aux_ent_total` | Auxiliary enterprises (total) | F*B09 |
| `exp_hospital_total` | Hospital services (total) | F*B10 |
| `exp_total_current` | Total current expenses | — |

### Other Key Finance Variables

| Portal Variable | Description |
|-----------------|-------------|
| `endowment_beg` | Endowment value at beginning of year |
| `endowment_end` | Endowment value at end of year |
| `form_type` | Finance form type (1-5, indicates GASB vs FASB) |
| `assets` | Total assets |
| `liabilities` | Total liabilities |
| `calc_fte` | Calculated FTE enrollment |
| `est_fte` | Estimated FTE enrollment |
| `rep_fte` | Reported FTE enrollment |

### NCES Form Field Codes (for reference only)

The variable names below are from NCES finance survey forms and are NOT used as column names in the Portal:

| NCES Code | Description | Used In |
|-----------|-------------|---------|
| `f1a01`-`f1a12` | GASB revenue items | Form F1 (public) |
| `f2a01`-`f2a09` | FASB revenue items | Form F2 (private NP) |
| `f*b01`-`f*b11` | Expense items (both forms) | Form F1, F2, F3 |
