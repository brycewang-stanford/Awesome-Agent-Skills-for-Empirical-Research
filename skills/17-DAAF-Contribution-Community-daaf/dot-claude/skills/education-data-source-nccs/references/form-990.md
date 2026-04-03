# IRS Form 990 Structure and Data Elements

Form 990 is the annual information return that tax-exempt organizations file with the IRS. This reference covers the form's structure and the data elements available for research.

> **Variable naming context:** This file uses original IRS/NCCS variable names (e.g., `CONT`, `TOTREV`, `COMPENS`) which are UPPERCASE and abbreviated. In the Portal dataset, these are mapped to lowercase descriptive names (e.g., `contributions_total`, `revenue_total`, `compensation_officers`). See SKILL.md Portal Variable Name Mapping for the crosswalk. Governance and schedule detail variables (Part VI, VII, Schedule D/J) are available only in the full NCCS Efile database, not in the Portal mirror dataset.

## Contents

- [Form 990 Overview](#form-990-overview)
- [Form Types](#form-types)
- [Form 990 Parts](#form-990-parts)
- [Schedules](#schedules)
- [Key Financial Sections](#key-financial-sections)
- [Governance and Compensation](#governance-and-compensation)
- [Data Quality Considerations](#data-quality-considerations)

---

## Form 990 Overview

Form 990, "Return of Organization Exempt From Income Tax," is required annually from most tax-exempt organizations. It provides comprehensive information about:

- **Mission and activities**: What the organization does
- **Finances**: Revenue, expenses, assets, liabilities
- **Governance**: Board composition, policies, conflicts of interest
- **Compensation**: Executive pay, board compensation
- **Related parties**: Transactions with insiders

### Filing Requirements

| Organization Type | Gross Receipts | Assets | Required Form |
|-------------------|----------------|--------|---------------|
| Most 501(c) | < $50,000 | N/A | 990-N (e-Postcard) |
| Most 501(c) | < $200,000 | < $500,000 | 990-EZ |
| Most 501(c) | ≥ $200,000 | ≥ $500,000 | 990 (full form) |
| Private foundations | Any | Any | 990-PF |

### 2008 Form Redesign

The Form 990 was substantially redesigned in 2008, affecting data comparability:

| Pre-2008 | Post-2008 |
|----------|-----------|
| 8 pages | 11 pages + schedules |
| Basic governance questions | Detailed governance section |
| Limited compensation detail | Extensive compensation reporting |
| Functional expense info optional | Required for most |

**Important**: When analyzing pre-2008 vs. post-2008 data, be aware of definitional and structural changes.

---

## Form Types

### Form 990 (Full Form)

- **Filers**: Larger organizations (gross receipts ≥ $200K or assets ≥ $500K)
- **Length**: 11 pages + applicable schedules
- **Detail level**: Comprehensive financial and governance information
- **In NCCS**: Core PC files, Efile database

### Form 990-EZ

- **Filers**: Smaller organizations (gross receipts < $200K AND assets < $500K)
- **Length**: 4 pages
- **Detail level**: Abbreviated financials, basic governance
- **In NCCS**: Core PZ files (combined with 990), Efile database

### Form 990-PF

- **Filers**: Private foundations (including non-operating foundations)
- **Length**: 13 pages
- **Detail level**: Grant recipients, investment details, minimum distribution
- **In NCCS**: Core PF files, Efile database

### Form 990-N (e-Postcard)

- **Filers**: Very small organizations (gross receipts normally ≤ $50K)
- **Content**: Name, EIN, address, principal officer, tax year only
- **In NCCS**: Separate ePostcard database (no financial data)

---

## Form 990 Parts

### Part I: Summary

High-level organizational overview and key financial totals.

| Line | Description | Variable (approx.) |
|------|-------------|-------------------|
| 1 | Mission/activities description | Text field |
| 8 | Contributions and grants | CONT |
| 9 | Program service revenue | PROGREV |
| 10 | Investment income | INVINC |
| 12 | Total revenue | TOTREV |
| 18 | Total expenses | EXPS |
| 19 | Revenue less expenses | NETINC |
| 20 | Total assets (EOY) | TOTASS |
| 21 | Total liabilities (EOY) | TOTLIAB |
| 22 | Net assets (EOY) | NETASS |

### Part II: Signature Block

Officer signature and preparer information.

### Part III: Statement of Program Service Accomplishments

Narrative descriptions of the three largest program services with associated expenses.

| Line | Description |
|------|-------------|
| 1 | Mission statement |
| 4a-4d | Program descriptions and expenses |

### Part IV: Checklist of Required Schedules

Yes/No questions determining which schedules must be attached (26 questions).

### Part V: Statements Regarding Other IRS Filings

Questions about other tax filings (W-2s, 1099s, etc.) and tax compliance.

### Part VI: Governance, Management, and Disclosure

Detailed questions about organizational governance.

| Section | Topics |
|---------|--------|
| A | Governing body and management |
| B | Policies (conflict of interest, whistleblower, document retention) |
| C | Disclosure (990 availability, financial statements) |

Key questions:
- Number of voting members of governing body
- Number of independent voting members
- Family/business relationships among officers
- Delegation of management to outside firms
- Policy documentation

### Part VII: Compensation of Officers, Directors, Trustees, Key Employees

Most important section for governance research.

| Section | Content |
|---------|---------|
| A | List of officers, directors, trustees, key employees, highest compensated employees |
| B | Independent contractors receiving > $100,000 |

**Reported for each person**:
- Name and title
- Hours per week (and related organizations)
- Reportable compensation from organization
- Reportable compensation from related organizations
- Estimated other compensation (benefits, deferred)

### Part VIII: Statement of Revenue

Detailed breakdown of all revenue sources.

| Line | Category |
|------|----------|
| 1a-1f | Federated campaigns, membership dues, fundraising events, related organizations, government grants, other contributions |
| 2a-2g | Program service revenue by activity |
| 3-7 | Investment income (interest, dividends, royalties, rental) |
| 8a-8c | Net gain/loss from sales (securities, other assets) |
| 9-10 | Fundraising events, gaming |
| 11a-11e | Other revenue |
| 12 | Total revenue |

### Part IX: Statement of Functional Expenses

Expenses broken down by function (program, management, fundraising).

| Line | Expense Category |
|------|------------------|
| 1 | Grants to domestic organizations |
| 2 | Grants to domestic individuals |
| 3 | Grants to foreign organizations/individuals |
| 4 | Benefits to members |
| 5 | Compensation (current officers, directors, etc.) |
| 6 | Compensation (disqualified persons) |
| 7 | Other salaries and wages |
| 8 | Pension plan accruals |
| 9 | Other employee benefits |
| 10 | Payroll taxes |
| 11a-g | Professional fees |
| 12 | Advertising and promotion |
| 13 | Office expenses |
| 14 | Information technology |
| 15 | Royalties |
| 16 | Occupancy |
| 17 | Travel |
| 18 | Payments to affiliates |
| 19 | Conferences and meetings |
| 20 | Interest |
| 21 | Payments to affiliates |
| 22 | Depreciation |
| 23 | Insurance |
| 24a-e | Other expenses |
| 25 | Total functional expenses |

**Columns**: 
- (A) Total
- (B) Program services
- (C) Management and general
- (D) Fundraising

### Part X: Balance Sheet

Assets, liabilities, and net assets at beginning and end of year.

**Assets**:
| Line | Category |
|------|----------|
| 1 | Cash (non-interest bearing) |
| 2 | Savings and temporary cash investments |
| 3 | Pledges and grants receivable |
| 4 | Accounts receivable |
| 5 | Loans to current/former officers, etc. |
| 6 | Loans to other employees |
| 7 | Notes and loans receivable |
| 8 | Inventories |
| 9 | Prepaid expenses |
| 10a-c | Land, buildings, equipment (gross, depreciation, net) |
| 11 | Investments (publicly traded securities) |
| 12 | Investments (other securities) |
| 13 | Investments (program-related) |
| 14 | Intangible assets |
| 15 | Other assets |
| 16 | Total assets |

**Liabilities**:
| Line | Category |
|------|----------|
| 17 | Accounts payable and accrued expenses |
| 18 | Grants payable |
| 19 | Deferred revenue |
| 20 | Tax-exempt bond liabilities |
| 21 | Escrow/custodial account liability |
| 22 | Loans from officers, directors, etc. |
| 23 | Secured mortgages and notes payable |
| 24 | Unsecured notes and loans payable |
| 25 | Other liabilities |
| 26 | Total liabilities |

**Net Assets**:
| Line | Category |
|------|----------|
| 27 | Without donor restrictions |
| 28 | With donor restrictions |
| 29 | Capital stock or trust principal |
| 30 | Paid-in or capital surplus |
| 31 | Retained earnings |
| 32 | Total net assets |
| 33 | Total liabilities and net assets |

### Part XI: Reconciliation of Net Assets

Links Part VIII revenue and Part IX expenses to the change in net assets.

### Part XII: Financial Statements and Reporting

Information about accounting method and audit status.

---

## Schedules

Organizations attach schedules based on their activities. Key schedules for education research:

### Schedule A: Public Charity Status and Public Support

Required for 501(c)(3) public charities.

| Part | Content |
|------|---------|
| I | Reason for public charity status |
| II | Support schedule (170(b)(1)(A)(vi)) |
| III | Support schedule (509(a)(2)) |
| IV-VI | Supporting organization details |

### Schedule D: Supplemental Financial Statements

**Part V: Endowment Funds** - Critical for higher education research

| Line | Description |
|------|-------------|
| 1a | Beginning of year balance |
| 1b | Contributions |
| 1c | Net investment earnings |
| 1d | Grants or scholarships |
| 1e | Other expenditures |
| 1f | Administrative expenses |
| 1g | End of year balance |
| 2 | Land, buildings, equipment held for investment |
| 3 | Qualifying distributions from endowment |

Other Parts:
- Part I: Donor advised funds
- Part II: Conservation easements
- Part III: Art and collections
- Part IV: Escrow and custodial accounts
- Part VI: Land, buildings, equipment details
- Part VII: Investments (other securities)
- Part VIII: Investments (program related)
- Part IX: Other assets
- Part X: Other liabilities
- Part XI: Reconciliation of revenue
- Part XII: Reconciliation of expenses

### Schedule J: Compensation Information

Detailed compensation for officers, directors, key employees.

| Part | Content |
|------|---------|
| I | Questions about compensation practices |
| II | Officers/directors/employees receiving >$150K from organization and related |

**For each person**:
- Base compensation
- Bonus and incentive compensation
- Other reportable compensation
- Retirement and deferred compensation
- Nontaxable benefits
- Total compensation

### Schedule R: Related Organizations and Unrelated Partnerships

Information about related entities (common for university systems).

| Part | Content |
|------|---------|
| I | Related exempt organizations |
| II | Related taxable corporations/trusts |
| III | Related partnerships |
| IV | Unrelated organizations taxable as partnership |
| V | Transactions with related organizations |

---

## Key Financial Sections

### Revenue Categories (Part VIII)

```
Total Revenue
├── Contributions, Gifts, Grants
│   ├── Federated campaigns
│   ├── Membership dues
│   ├── Related organizations
│   ├── Government grants
│   └── Other contributions
├── Program Service Revenue
│   ├── Tuition and fees
│   ├── Auxiliary enterprises
│   └── Other program revenue
├── Investment Income
│   ├── Interest
│   ├── Dividends
│   ├── Royalties
│   └── Rental income
├── Net Gain/Loss from Sales
│   ├── Securities
│   └── Other assets
└── Other Revenue
    ├── Special events
    └── Miscellaneous
```

### Expense Categories (Part IX)

```
Total Expenses
├── Grants and Allocations
├── Compensation
│   ├── Officers/directors/trustees
│   ├── Other employees
│   ├── Pension/retirement
│   ├── Other benefits
│   └── Payroll taxes
├── Professional Fees
│   ├── Accounting
│   ├── Legal
│   ├── Investment management
│   └── Other professional
├── Operations
│   ├── Occupancy
│   ├── Supplies
│   ├── Travel
│   ├── Conferences
│   └── Interest
├── Depreciation
└── Other Expenses
```

### Functional Expense Allocation

For 501(c)(3) and (c)(4) organizations, expenses must be allocated to:

| Function | Description |
|----------|-------------|
| **Program services** | Direct mission-related activities |
| **Management and general** | Administration, oversight, finance |
| **Fundraising** | Donor cultivation, solicitation |

This allocation is important for calculating efficiency ratios.

---

## Governance and Compensation

### Key Governance Variables

| Item | Description |
|------|-------------|
| Voting members | Size of governing body |
| Independent members | Members without financial relationship |
| Family relationships | Officers/directors related to each other |
| Business relationships | Officers/directors with business ties |
| Conflict of interest policy | Written policy exists |
| Whistleblower policy | Written policy exists |
| Document retention policy | Written policy exists |
| CEO/director review | Governing body reviews CEO compensation |
| Form 990 review | Governing body reviews Form 990 |

### Compensation Data

**Who is reported**:
- Current officers, directors, trustees
- Key employees (>$150K compensation with organizational responsibility)
- Highest compensated employees (>$100K)
- Former officers/employees receiving >$100K
- Independent contractors receiving >$100K

**What is reported**:
- Base compensation
- Bonus/incentive
- Other reportable (expense accounts, etc.)
- Retirement/deferred compensation
- Nontaxable benefits (health insurance, housing, etc.)
- Total

---

## Data Quality Considerations

### Common Issues

| Issue | Description | Mitigation |
|-------|-------------|------------|
| **Missing data** | Not all fields required | Check for valid values vs. blanks |
| **Reporting variations** | Organizations interpret questions differently | Use consistent definitions |
| **Fiscal year differences** | Organizations have different year-ends | Account for timing in comparisons |
| **Amended returns** | Some organizations file corrections | Use most recent filing |
| **Consolidation** | University systems may file consolidated | Check related organizations |
| **Rounding** | Small amounts may be rounded | Be cautious with small values |

### Missing Data Codes

In NCCS data:
| Code | Meaning |
|------|---------|
| -1 | Data unavailable |
| -2 | Not applicable |
| -3 | Suppressed (confidentiality) |
| `null` | Not reported (blank in CSV, null in parquet) |

> **Portal note:** In the Portal dataset, most missing data appears as `null` rather than negative codes. The `-1`/`-2`/`-3` codes exist but are rare (only a few financial columns). Always check for both `null` and negative codes when cleaning.

### Recommended Error Checks

1. **Revenue check**: Total revenue ≈ sum of components
2. **Expense check**: Total expenses ≈ sum of components
3. **Balance sheet**: Assets = Liabilities + Net Assets
4. **Reconciliation**: Beginning net assets + (Revenue - Expenses) ≈ Ending net assets
5. **Compensation**: Individual totals ≈ sum of components
6. **Functional expense**: Total ≈ Program + Management + Fundraising

### Form 990 vs. Audited Financial Statements

| Aspect | Form 990 | Audited Financials |
|--------|----------|-------------------|
| **Basis** | Modified cash or accrual | GAAP accrual |
| **Fiscal year** | Tax year (may differ) | Organization's fiscal year |
| **Consolidation** | Varies | Full consolidation |
| **Revenue detail** | Specific categories | May differ |
| **Expense detail** | Functional allocation | Natural classification |
| **Notes** | Limited | Extensive |

**For colleges**: Audited financial statements (GAAP) may show different totals than Form 990 due to these differences. IPEDS data also follows education-specific accounting.
