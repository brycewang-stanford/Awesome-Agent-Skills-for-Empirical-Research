# Reading Notes: "Competition and Ideological Diversity: Historical Evidence from US Newspapers" (Gentzkow, Shapiro & Sinkinson, AER 2014)

## Status: Complete — all 42 pages read

---

## 1. Research question and importance

**Question:** How do competitive forces shape ideological diversity in the newspaper market? Specifically: (a) Do households prefer like-minded news? (b) Do newspapers use political orientation to differentiate from competitors? (c) Does competition enhance or reduce ideological diversity? (d) Does the market supply the socially optimal level of diversity? (e) How do specific competition policies (collusion on circulation prices, advertising prices, joint operating agreements, joint ownership, subsidies) affect diversity and welfare?

**Why it matters:** Media diversity policy in the US has been shaped for over two centuries by the belief that diverse viewpoints are essential to democracy — from the Postal Act of 1792 to FCC ownership rules to the Newspaper Preservation Act of 1970. The Supreme Court has held that wide dissemination from diverse sources is essential to public welfare. Yet there was no structural model quantifying how competition actually affects ideological diversity in equilibrium, or whether market outcomes are efficient. This paper provides the first such model, using a historical setting (1924) where hundreds of cities had multiple competing papers with explicit partisan affiliations — a cross-section of "experiments" that modern newspaper markets (mostly monopolies) cannot provide. The paper also addresses whether optimal competition policy in media requires accounting for the two-sidedness of the market (readers + advertisers).

## 2. Intended audience

Primarily **industrial organization economists** studying entry, product positioning, and two-sided markets. Also **media economists** and **political economists** studying the relationship between market structure and content diversity. The paper is published in the *American Economic Review* and engages deeply with the IO literature on structural entry models (Bresnahan & Reiss 1991, Mazzeo 2002), product differentiation (Hotelling), and two-sided market theory (Armstrong 2002, Rochet & Tirole 2006). Secondary audience includes **policy audiences** — the FCC, antitrust authorities, and anyone involved in media ownership regulation — since the paper directly evaluates specific policy instruments (joint operating agreements, ownership consolidation, postal subsidies).

## 3. How they answer the question

**Structural model of newspaper demand, entry, political affiliation choice, and advertising** in a two-sided market. The model is estimated and calibrated using 1924 US daily newspaper data — a period when most papers had Republican or Democratic affiliations and many cities had multiple competing dailies.

**Model structure (sequential entry game):**
1. Newspapers decide whether to enter a market
2. Entrants choose Republican or Democratic affiliation
3. Subscription prices and advertising rates are set, taking into account household demand, competitor responses, and affiliation effects on both sides of the market

**Demand side:** Multiple-discrete-choice framework (Gentzkow 2007) — households can read multiple newspapers (multi-homing). Household utility depends on:
- Match between newspaper ideology and household ideology (taste for like-minded news)
- Substitutability: same-affiliation papers are closer substitutes than opposite-affiliation papers
- Price

**Advertising side:** Stylized model capturing the key two-sided market prediction that advertising-market competition depends on overlap in newspapers' readership (Armstrong 2002; Anderson, Foros & Kind 2011; Ambrus, Calvano & Reisinger 2013). Diminishing returns to impressions means newspapers have an incentive to differentiate to reduce readership overlap and soften advertising competition.

**Two key parameters governing differentiation incentives:**
1. Relative substitutability of same-affiliation vs. opposite-affiliation papers (Hotelling channel)
2. Extent of diminishing returns to advertising impressions (advertising competition channel)

**Identification strategy for demand:**
- Town-level circulation data (1924 ABC reports): compare circulation of the same newspaper across towns with different ideology → identifies taste for like-minded news
- Variation in relative circulation with respect to number of papers of each type → identifies relative substitutability of same-affiliation papers
- Price coefficient: calibrated by imposing that observed prices satisfy firms' first-order conditions (no credible price instruments)
- Readership overlap: calibrated to match historical readership surveys (1929-1969)
- Marginal costs and advertiser willingness to pay: calibrated from Inland Daily Press Association income statements (1927)

**Identification strategy for supply (entry + affiliation):**
- Order of entry and observed affiliations in each 1924 market
- Controlling for fraction Republican, adding an additional Republican incumbent reduces entrant's probability of choosing Republican affiliation by 15 pp → identifies overall differentiation incentive
- Demand estimates pin down Hotelling portion; residual attributed to diminishing returns to advertising
- Population vs. number of firms → identifies fixed cost distribution

**Controlling for unobserved ideology:**
- Novel spatial correlation strategy: markets paired with geographically proximate (100-400 km, same state) but non-competing markets
- Assumes spatial correlation in unobservable ideology matches that of observable measures (Murphy & Topel 1990; Altonji, Elder & Taber 2005)
- Allows explicit modeling of unobserved market-level heterogeneity in consumer ideology

**Counterfactual simulations:** Social planner benchmark (maximizing economic welfare ignoring political externalities), circulation price collusion, advertising price collusion, joint operating agreements, joint ownership, explicit subsidies.

## 4. Data sources and where they came from

- **US Newspaper Panel** (Gentzkow, Shapiro & Sinkinson 2011): name, city, political affiliation, and subscription price of every English-language daily newspaper in the US, 1869 and every presidential year 1872-1924. Main analysis uses 1924 cross-section. Full panel used for supplemental analysis and defining order-of-entry variables.

- **Town-level circulation data:** 1924 Audit Bureau of Circulations (ABC) reports. Obtained on microfilm from ABC and converted to machine-readable text. Reports the newspaper's circulation in each town receiving 25+ copies daily. This is described as the first dataset with disaggregated circulation for a large number of pre-late-20th-century newspapers. Matched to US Newspaper Panel by newspaper name and location.

- **Presidential voting data:** Average Republican share of two-party vote, 1868-1928, at county level. Markets matched to Census places (1990 definitions), then to counties. Various sources, as in Gentzkow, Shapiro & Sinkinson (2011).

- **Readership survey data (for calibration):** 17 newly digitized aggregate reports from newspaper readership surveys, covering 9 (mostly large) cities, 1929-1969. Used to measure readership overlap between newspapers (share of subscribers to either paper who subscribe to both).

- **Cost of Living in the United States, 1917-1919** (Bureau of Labor Statistics 1986; Costa 2001): microdata on number of newspapers purchased per household. Earliest microdata on number of newspapers read by US families. Matched to cross-section of newspaper markets.

- **Cost and revenue data:** Income statements for 94 anonymous newspapers in 1927 from Inland Daily Press Association (Yewdall 1928). Matched to US Newspaper Panel by closest circulation value. Used to compute variable costs (paper, ink, mailing, delivery per copy), fixed costs per copy, advertising revenue per copy, and circulation revenue per copy.

- **City population data:** 1924 N.W. Ayer and Son's American Newspaper Annual.

- **Sample definition:** Cities with population 3,000-100,000 and at least one weekly newspaper as of 1924. Excludes very large cities (NYC had 100+ papers) and very small ones. 1,910 markets total; 950 with at least one daily; 338 with 2+ dailies; 1,338 newspapers total (57% Republican). 54% of multipaper markets are ideologically diverse. Town-level circulation sample: 12,188 towns, 8,044 with 2+ circulating papers.

## 5. Statistical methods

**Econometrics:**

*Descriptive analysis (Tables 3-4):*
- OLS regressions of Republican-Democrat difference in mean log circulation on Republican vote share and counts of substitute newspapers (Table 3)
- OLS regressions of dummy for Republican affiliation on Republican vote share and number of Republican/Democratic incumbents (Table 4)
- Standard errors clustered at county level (Table 3) and market level (Table 4)

*Key descriptive results:*
- 10 pp increase in Republican vote share → 10% increase in relative circulation of Republican papers (Table 3, spec 3)
- Adding a second Republican paper to a 1R+1D market → 4% reduction in relative circulation of existing Republican paper (Table 3, spec 3)
- 10 pp increase in fraction Republican → 23 pp increase in likelihood of Republican affiliation (Table 4, spec 3)
- Having a Republican incumbent instead of Democratic → 28 pp reduction in likelihood of Republican affiliation (Table 4, spec 3)

*Structural model (Sections IV-VI, pages 15-24):*

**Five-stage game:**
1. Sequential entry decisions
2. Sequential affiliation choice (R or D), conditioning on predecessors' choices and taking account of future movers — firms learn private cost shocks ξ_jm only at this stage
3. Simultaneous circulation price setting
4. Simultaneous advertising price setting; advertisers then decide where to advertise
5. Households choose bundles of newspapers

**Profit function (Equation 1):**
- π_jm = S_m [(p_jm + ψ_jm·a_jm − MC)·q_jm − ξ_jm(τ_jm)] − κ_m
- ψ_jm = mass of advertisers in newspaper j; a_jm = per-copy ad price; MC = common marginal cost; q_jm = household share; ξ_jm = affiliation-specific cost shock (type-I extreme value scaled by σ_ξ); κ_m = market fixed cost (logistic distribution, scale σ_κ, location μ_κ^0 + μ_κ^1·log(S_m))

**Demand (Equation 2) — multiple-discrete-choice:**
- u_im(B) = Σ_{j∈B} (β̲·1_{θ≠τ} + β̄·1_{θ=τ} − α·p_jm) − g_s(B)·Γ_s − g_d(B)·Γ_d + ε_im(B)
- β̄ = utility from own-type newspaper; β̲ = utility from opposite-type; α = price coefficient
- g_s(B) = number of same-affiliation pairs in bundle; g_d(B) = number of different-affiliation pairs
- Γ_s = substitution penalty for same-affiliation pairs; Γ_d = substitution penalty for different-affiliation pairs
- ε_im(B) = type-I extreme value bundle error
- Nests: monopoly logit (β̲=β̄, Γ_s=Γ_d=0), standard single-choice logit (β̲=β̄, Γ→∞), separate markets by affiliation (β̲→−∞)

**Advertising equilibrium (Equation 6):**
- a_jm(p,τ) = a_h·e_jm(p,τ) + a_l·(1 − e_jm(p,τ))
- a_h = value of first impression; a_l = value of subsequent (duplicate) impressions; 0 ≤ a_l ≤ a_h
- e_jm = share of j's readers who are "exclusive" (read no other paper)
- All advertisers advertise in all newspapers in equilibrium
- Diminishing returns (a_l < a_h) means newspapers earn less per reader when readership overlaps — incentive to differentiate to increase exclusive readership

**Circulation price equilibrium (Equation 7):**
- Each newspaper maximizes (p_j + a_jm − MC)·q_jm, taking other prices as given
- Solved numerically via first-order conditions; second-order conditions verified

**Affiliation choice equilibrium:** Sequential backward induction; each newspaper maximizes expected variable profit minus affiliation cost shock ξ_jm

**Entry equilibrium (Equation 9):**
- V_m(J*) ≥ κ_m/S_m > V_m(J* + 1)
- V_m(J) = expected per-household variable profit with J entrants, averaging over affiliation cost realizations

**Demand estimation (Section V, pages 23-24):**
- Maximum likelihood using hinterland town circulation data
- Dependent measure: difference in mean log circulation of R vs. D papers per town (scales out population)
- Unobserved ideology: ρ_t = logit⁻¹(logit(Z_t) + ν_t), where ν_t ~ Normal, correlated within matched town pairs with correlation restricted to match observable correlation (Equation 10)
- Endogenous choice sets: reduced form Pr(τ_jt = R) = logit⁻¹(μ_ρ^0 + μ_ρ^1·logit(ρ_t))
- Calibrated parameters: MC and a_h from Inland Press income statements (monopoly markets with Z ∈ [0.45, 0.55]); α and β̲ from monopoly first-order condition (match observed price and circulation per household); Γ_d from readership survey overlap data
- Estimated parameters: {β̄, Γ_s, σ_ζ, μ_ν^town, σ_ν^town, μ_ρ^0, μ_ρ^1} via MLE
- Integration: sparse grid with Gaussian kernel, accuracy 3

**Key modeling assumptions and limitations discussed (Section IVD, pages 19-23):**
- Market definition: newspapers compete only in home market (90% of circulation is home-market; 65% of copies sold in home market). Hinterland towns used only for demand estimation.
- Outside option: aggregates all non-daily-newspaper substitutes. Period chosen deliberately — no TV, radio nascent in 1924.
- Only political affiliation endogenized, not quality or other horizontal dimensions (e.g., time of publication). Price coefficient identified from monopoly FOC rather than price variation to avoid unobserved quality bias.
- Two consumer types only (R and D). Online Appendix augments with unaffiliated consumers.
- Static approximation to dynamic entry process.
- Entry precedes affiliation choice; firms learn ξ_jm only post-entry — simplifies computation but rules out entry deterrence and owner self-selection into markets.
- Advertising: no consumer disutility from ads (evidence mixed for print); homogeneous advertiser valuations; all advertisers served in equilibrium (allocatively efficient ad side).
- Fixed costs allowed to depend on market size (editorial costs scale with quality → market size; Berry & Waldfogel 2010).

**NLP / Text analysis:** Not applicable — this paper does not use NLP methods. Political orientation is measured by declared party affiliation (Republican or Democratic), not by text analysis of content.

## 6. Findings

*Based on pages 1-12 (descriptive results and preview of main findings):*

**Descriptive findings (Tables 3-4):**
- Households prefer like-minded news: Republican vote share strongly predicts relative circulation of Republican papers
- Same-affiliation papers are closer substitutes: adding a same-type paper reduces relative circulation of existing same-type papers
- Newspapers differentiate ideologically from competitors: entering papers are less likely to choose the affiliation of incumbents
- Both demand-side and supply-side patterns are robust to controlling for household ideology and market structure simultaneously

**Structural estimates (Tables 5-6):**
- Households strongly prefer like-minded papers (β̄ = 0.81 vs. β̲ = −0.29) and same-type papers are closer substitutes (Γ_s = 0.56 > Γ_d = 0.30)
- Advertising revenue per exclusive reader ($13.47) is ~81% higher than per overlapping reader ($7.44) → significant diminishing returns create strong differentiation incentive
- Substantial unobserved heterogeneity in household ideology; less important on supply side

**Determinants of diversity (Table 7):**
- Competition roughly doubles diversity: removing competitive incentives cuts diverse markets from 143 to 68
- Catering to majority tastes reduces diversity by about as much as competition increases it (211 diverse markets if ideology ignored)

**Welfare analysis (Table 8):**
- Market equilibrium: total surplus $4.24/HH/yr (CS $3.44, newspaper profit $0.41, advertiser profit $0.39)
- Social planner (entry + post-entry): total surplus $8.56, diverse markets rise from 143 to 1,370, one-third of HH read diverse papers daily
- Market undersupplies both entry and diversity; no conflict between welfare maximization and diversity preservation

**Policy experiments (Table 9):**
- Price collusion: welfare falls ($4.24→$3.69), diversity mixed
- Advertising collusion: welfare rises ($4.24→$4.90), diversity rises (143→225 diverse markets) — seesaw principle transfers surplus to readers
- Joint operating agreements: diversity rises (143→238), welfare roughly neutral
- Joint ownership: welfare and diversity both fall sharply (143→62 diverse markets)
- Optimal subsidy ($4/copy, 49% MC reduction): best policy — welfare $6.05, diversity 704 diverse markets

**Robustness (Appendix Table 1):**
- All key qualitative results hold across 26 alternative specifications varying calibrated parameters, model structure, and estimation sample

## 7. What is learned

*Based on pages 1-12:*

- **Competition drives ideological diversity through differentiation incentives.** Newspapers choose to differentiate politically from competitors to attract readers and soften price/advertising competition. This Hotelling-style differentiation offsets the "majority capture" force (George & Waldfogel 2003) that would push all papers toward the dominant ideology.

- **Two-sidedness of the market matters for policy.** The contrasting effects of circulation vs. advertising price collusion show that media competition policy cannot ignore the advertising side. Advertising collusion is welfare-improving because it transfers surplus from advertisers to newspapers, which then compete more intensely for readers (lower circulation prices, more entry, more diversity). This is a striking result — collusion on one side of the market can be pro-competitive on the other.

- **Historical setting provides unique identification.** The 1924 cross-section offers what modern data cannot: hundreds of multipaper markets with explicit partisan affiliations, allowing direct observation of competitive interactions in ideological positioning. In modern US markets, most cities have only one newspaper, making it impossible to study how competition affects ideological diversity.

- **The market undersupplies diversity even by pure economic welfare standards.** The social planner comparison (Table 8) shows that a welfare-maximizing planner would choose more entry, lower prices, and more diversity than the market provides — and this holds *without* assigning any value to political externalities from diverse viewpoints. The Spence (1975) distortion (entrants don't internalize inframarginal consumer surplus) dominates the business-stealing externality (Mankiw & Whinston 1986), unlike radio (Berry & Waldfogel 1999), because newspaper multi-homing is substantial.

- **Advertising collusion is surprisingly pro-competitive.** The seesaw principle in two-sided markets means that when newspapers collude on ad rates, they earn more from advertisers, then compete more aggressively for readers (lower circulation prices), which spurs entry, which increases diversity. This is a counterintuitive but quantitatively important result: collusion on one side of a two-sided market can be welfare- and diversity-improving.

- **Joint ownership is the worst policy for diversity.** Consolidation reduces entry (the primary driver of diversity) and — despite internalizing differentiation incentives — the common affiliation cost shock pushes co-owned papers toward the same ideology. This is directly relevant to FCC ownership rules and the broader media consolidation debate.

- **For our project (Craigslist and media bias):** This paper establishes that competition increases ideological diversity in newspaper markets, and specifically that the *advertising side* of the market is critical. The corollary is that *reduced* advertising revenue (which weakens the business model) could *reduce* diversity. Craigslist's entry directly attacks the advertising side — classified advertising revenue — which this paper shows has first-order effects on diversity outcomes. The a_l/a_h ratio (0.55) means that the advertising differentiation incentive is quantitatively important: exclusive readers are 81% more valuable to advertisers, giving newspapers a strong economic reason to differentiate. If Craigslist reduces total advertising revenue, the differentiation incentive weakens on both margins: (1) the entry margin — fewer papers can cover fixed costs, reducing multipaper markets; (2) the affiliation margin — with less advertising revenue at stake, the incentive to differentiate politically is weaker. The policy experiments further sharpen the prediction: the "advertising collusion" counterfactual shows that *more* advertising revenue leads to more diversity, so by symmetry, *less* advertising revenue (from Craigslist disruption) should reduce diversity. The optimal subsidy result ($4/copy) also suggests that direct revenue support for newspapers could partially offset the Craigslist effect.

## 8. Data availability and replication access

The paper provides a dataset reference: Gentzkow, Shapiro & Sinkinson (2014), "Competition and Ideological Diversity: Historical Evidence from US Newspapers: Dataset," *American Economic Review*, `http://dx.doi.org/10.1257/aer.104.10.3073`. The AER typically hosts replication data at this DOI. Original data sources:
- **US Newspaper Panel** (Gentzkow, Shapiro & Sinkinson 2011) — constructed by authors from annual newspaper directories
- **ABC town-level circulation** — obtained from microfilm and digitized by authors (first such dataset for pre-late-20th-century papers)
- **Readership surveys (1929-1969)** — 17 aggregate reports newly digitized by authors
- **Inland Press income statements (1927)** — from Yewdall (1928), matched to US Newspaper Panel by circulation
- **BLS Cost of Living 1917-1919** — ICPSR Study 8299 (US Dept. of Labor 1986)
- **Presidential voting data** — various sources as in Gentzkow, Shapiro & Sinkinson (2011)
- **Ownership data** — 1932 Editor & Publisher Yearbook (used only for robustness check in Appendix Table 1, spec 23)
- No explicit statement about a public replication archive beyond the AER DOI link. Several data inputs are proprietary or require digitization from microfilm.

---

**Evidence on extent of differentiation (Section IIID, pages 14-15):**
- Average newspaper gross margin: $10.09 per subscriber on variable costs of $8.79 (circulation revenue $4.69 + advertising revenue $14.19, all 1924 dollars). Large markups even in competitive markets.
- Entry of an average newspaper increases total market circulation by 24% (vs. 28% with no substitution) — only ~14% of entering newspaper's circulation comes at expense of existing papers; rest is new readers or multi-homing.
- Multiple readership: 15% of newspaper-reading households read 2+ papers (1917-1919 survey); 16% overlap for average newspaper pair (1929-1969 readership surveys). Overlap if anything larger for same-affiliation papers → substantial nonpolitical differentiation.

**Spatial correlation strategy for unobserved ideology (Section IIIC, pages 13-14):**
- In markets with Democratic first entrant: second entrant is Republican 48% of the time. With Republican first entrant: second entrant is Republican 51% — slight *positive* correlation (net of differentiation and ideology sorting).
- In *neighboring* market (100-400 km away): if first entrant is Democratic, neighbor's second entrant is Republican 31%; if Republican, 64% — strong positive correlation = evidence of spatially correlated unobserved ideology.
- Three key assumptions: (1) paired markets close enough to share ideology but far enough apart that newspapers don't compete, (2) no spatially correlated supply-side variables affecting affiliation profitability, (3) correlation of unobservables = correlation of observables.

**Supply estimation (Section VI, pages 25-26):**
- Remaining parameters {a_l, σ_ξ, μ_ν^mkt, σ_ν^mkt, μ_κ^0, μ_κ^1, σ_κ} estimated by MLE on market-level entry and affiliation data, taking demand parameters as given
- Unobserved market ideology: ρ_m = logit⁻¹(logit(Z_m) + ν_m), with ν_m ~ Normal(μ_ν^mkt, σ_ν^mkt), correlated within paired neighboring markets (analogue of town-level Equation 10)
- Maximum potential entrants J^max = 6 (one more than max observed; simulations show <1% of markets exceed 6 with J^max=10)
- Conditional likelihood (Equation 13): probability of observing J_m entrants with affiliation vector τ_m, given ρ_m. Integrates over paired markets (Equation 14) using sparse grid with Gaussian kernel, accuracy 3
- Standard errors adjusted for uncertainty in demand parameters (Murphy & Topel 1985)

**Supply identification (Section VIA, page 26):**
- μ_ν^mkt: identified by overall share of Republican affiliations
- σ_ν^mkt: identified by spatial correlation in affiliation choices across paired markets
- a_l (diminishing returns to advertising): identified by extent to which newspapers differentiate *more* than predicted by demand-side substitution and price effects alone. Because same-affiliation papers overlap more in readership, lower a_l → stronger differentiation incentive from advertising competition
- σ_ξ: identified by residual variation in affiliation choices
- Fixed cost parameters (μ_κ^0, μ_κ^1, σ_κ): identified by correlation between number of newspapers and population, and conditional variation in number of papers given population

**Parameter estimates — Demand (Table 5, page 27):**
- α = 0.1798 (SE 0.0032) — price coefficient
- β̲ = −0.2906 (SE 0.0676) — utility from opposite-affiliation paper (negative: disutility)
- β̄ = 0.8137 (SE 0.0759) — utility from same-affiliation paper (large positive → strong taste for like-minded news)
- Γ_s = 0.5645 (SE 0.0669) — substitutability penalty for same-type pairs
- Γ_d = 0.3004 (SE 0.0469) — substitutability penalty for different-type pairs (Γ_s > Γ_d confirms same-type papers are closer substitutes)
- σ_ζ = 0.7017 (SE 0.0077) — measurement error in circulation
- μ_ν^town = 0.0466 (SE 0.0422) — mean unobserved ideology shifter
- σ_ν^town = 0.2783 (SE 0.0135) — substantial unobserved heterogeneity
- MC = 8.1749 (calibrated); spatial correlation = 0.7233 (calibrated)
- Sample: 12,188 towns, 670 newspapers, 28,779 newspaper-towns

**Parameter estimates — Supply (Table 6, page 28):**
- a_l = 7.4447 (SE 1.2626) — ad revenue per overlapping reader
- a_h = 13.4707 (calibrated) — ad revenue per exclusive reader
- Ratio a_l/a_h ≈ 0.55 → significant diminishing returns to advertising (exclusive readers ~81% more valuable)
- σ_ξ = 0.2277 (SE 0.0298) — affiliation cost shocks (smaller than demand unobservables → less random variation in supply-side choices)
- μ_ν^mkt = −0.0114 (SE 0.0184); σ_ν^mkt = 0.1523 (SE 0.0684)
- Fixed cost distribution: μ_κ^0 = 8.7354, μ_κ^1 = −0.6448, σ_κ = 0.3607
- Model-implied mean monopoly fixed cost: $9.03/copy (vs. $7.73 in Inland Press data — reasonable given sunk + opportunity costs)
- Fixed costs per capita decline very slowly with market size (10% pop increase → only $0.06/capita reduction)
- Sample: 1,910 markets, 1,338 newspapers

**Readership overlap implication (page 28):**
- Same-affiliation papers: 17% overlap; opposite-affiliation: 14% (simulated from estimated model in 2-paper markets)
- Strong taste for like-minded news (β̄ − β̲ = 1.10) outweighs greater substitutability of same-type papers → same-type papers share MORE readers
- This confirms advertising competition increases differentiation incentive (overlap is costly when a_l < a_h)

**Model fit (page 29):**
- Estimated model fits key features of data well overall
- Exception: underpredicts markets with exactly two papers (possibly due to symmetric logit error functional form)
- Online Appendix shows out-of-sample fit to subscription price distribution and long-term marginal cost effects on market structure

**Determinants of diversity (Table 7, page 29):**
- Baseline: 143 markets with diverse papers (0.22 share of HH in diverse markets, 0.029 share of HH reading diverse)
- Ignore competitors' choices (choose affiliation as if monopolist): 68 diverse markets → competition roughly DOUBLES diversity
- Ignore household ideology (set ρ=0.5): 211 diverse markets → catering to majority tastes reduces diversity by about as much as competition increases it
- Ignore idiosyncratic cost shocks (set ξ=0): 110 diverse markets → random factors matter less than competition

**Welfare analysis (Table 8, pages 30-31):**
- Baseline equilibrium: 951 markets with papers, 256 with multiple papers; 39% of HH read a paper; avg competitive price $5.48/yr; avg ad revenue $11.24/reader/yr
- Surplus decomposition: CS $3.44 + newspaper profit $0.41 + advertiser profit $0.39 = total surplus $4.24/HH/yr
- Social planner (post-entry only): prices drop to ~$0.04; readership rises to 53%; diverse markets increase 143→175; total surplus rises to $7.15 (69% gain)
- Social planner (entry + post-entry): all 1,910 markets get papers, 1,845 get multiple; readership 91%; diverse markets 1,370; 84% of HH in diverse markets; 33% reading diverse papers daily; total surplus $8.56
- Key finding: market undersupplies both entry AND diversity — no conflict between welfare maximization and diversity preservation
- Source of insufficient entry: Spence (1975) distortion — entrants don't internalize surplus of inframarginal consumers. Business-stealing externality (Mankiw & Whinston 1986) is relatively small due to substantial multi-homing. Contrasts with Berry & Waldfogel (1999) finding of excess entry in radio.

**Policy experiments (Table 9, pages 32-34):**

*Price collusion:* avg price rises $5.48→$7.53; modest entry increase (256→290 multipaper markets); welfare FALLS ($4.24→$3.69); diversity effects mixed (more diverse markets but fewer HH reading diverse papers)

*Advertising collusion:* ad revenue rises $11.24→$12.14; newspapers lower circulation prices ($5.48→$5.07) via "seesaw principle" (Rochet & Tirole 2006); massive entry increase (256→400 multipaper markets); welfare RISES ($4.24→$4.90); diversity RISES on all measures (143→225 diverse markets)

*Joint operating agreements (price + ad collusion):* ad collusion effects dominate; diversity RISES (143→238); welfare roughly neutral ($4.24→$4.29)

*Joint ownership:* welfare FALLS ($4.24→$3.49); diversity FALLS sharply (143→62 diverse markets); entry drops (256→126 multipaper); prices and ad rates both rise. Two offsetting differentiation effects: internalizing competitor effect increases differentiation incentive (Sweeting 2010), but common ξ shock increases within-market affiliation correlation.

*Optimal subsidy:* $4.00/copy/yr (49% MC reduction; historical postal subsidy was ~12%); best performer on both welfare ($6.05) and diversity (704 diverse markets); entry nearly doubles (951→1,883 markets with papers); readership 74%; cost of subsidy $5.63/HH/yr (at 30% marginal cost of public funds)

**Key takeaway on two-sidedness (page 33-34):** Price and advertising collusion are often treated as symmetric in policy debates, but they are fundamentally different. Price collusion taxes marginal readership; advertising collusion subsidizes it. In a world where entry, readership, and diversity are all inefficiently low, permitting advertising collusion is a surprisingly attractive policy.

**Conclusions (Section VIII, page 35):**
- Competition is a crucial driver of ideological diversity
- No conflict between maximizing economic welfare and preserving diversity
- Two-sidedness of market is critical for policy evaluation
- Advertising collusion increases both welfare and diversity; price collusion reduces welfare with mixed diversity effects
- Ownership consolidation reduces both welfare and diversity

**Robustness — Appendix Table 1 (pages 35-36):**
- 26 alternative specifications tested across three counterfactuals (baseline, social planner, JOAs) for both diversity and welfare
- Specifications vary: calibrated parameter values (±25% for MC, a_h, readership overlap, spatial correlation), model specification changes (endogenous J_t in demand, flexible fixed cost distribution, flexible affiliation choice, distance-to-HQ utility shifter, HQ-circulation utility shifter, incorporate hinterland towns in market ideology, fix prices to mean, add price as demand utility shifter), and estimation sample changes (tighter population cutoffs, removing independent/unaffiliated papers, removing markets near major cities, removing towns with missing data, removing cross-market co-ownership pairs, removing top/bottom 10% towns by population, removing South)
- Key qualitative conclusions (competition drives diversity, no welfare-diversity tradeoff, JOAs weakly welfare-improving) are robust across all 26 specifications
- Standard errors on preferred estimate: baseline diversity 0.029 (SE 0.001), social planner diversity 0.334 (SE 0.034), baseline welfare $4.24 (SE $0.084)
- Simulation error is small (≤0.002 for diversity, ≤$0.071 for welfare)

**Additional appendix details (pages 37-38):**
- Specifications 12-17 modify model structure: flexible affiliation choice function (quadratic in logit(ρ)), quality shifters (distance to HQ, HQ circulation), incorporating hinterland towns in market ideology measure, fixing all prices to mean, adding price as utility shifter. None change qualitative conclusions.
- Specifications 18-26 modify estimation sample: tighter population cutoffs (3,750-75,000), removing markets with independent papers, removing unaffiliated papers, removing markets near top-10 cities, removing towns with missing nearby-newspaper data, removing cross-market co-ownership pairs (1932 Editor & Publisher data), removing top/bottom 10% towns by population, removing Southern markets. None change qualitative conclusions.
- Notable: removing Southern markets increases baseline diversity and scope for welfare gains (Democratic party dominance in South suppresses diversity demand)
- Appendix Figure 1: Shows spatial decay in (a) correlation of percent Republican, (b) correlation of percent white, and (c) share of circulation from county 1 reaching county 2, all as functions of distance. Validates spatial identification strategy: demographic correlations decay slowly (still ~0.6 at 200km) while newspaper circulation drops sharply (near zero beyond 100km), supporting the assumption that paired markets share ideology but don't compete for readers.

**References (pages 38-42):** ~90 references spanning IO, media economics, political economy, and two-sided market theory. Key reference clusters: structural IO entry models (Bresnahan & Reiss 1991, Mazzeo 2002, Berry et al. 1995), two-sided markets (Armstrong 2002, Rochet & Tirole 2006), media economics (Mullainathan & Shleifer 2005, Gentzkow & Shapiro 2010, George & Waldfogel 2003, Fan 2013), newspaper history (Baldasty 1992, Kaplan 2002, Summers 1994), and welfare/entry (Spence 1975, Mankiw & Whinston 1986, Berry & Waldfogel 1999, Dixit & Stiglitz 1977).

*Reading complete — all 42 pages (11 splits) read.*
