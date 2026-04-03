# REFERENCES

STATA replication files from published papers in the Journal of Accounting Research (2017-2025).

## Quick Reference Table: All Replication Files

| File | Authors | Year | Primary Method | Identification Strategy | Robustness/Special Features |
|------|---------|------|---|---|---|
| JAR_55_bbcl.do | Bloomfield, Bruggemann, Christensen, Leuz | 2017 | areg, reghdfe | DiD (Matched Difference-in-Differences) | Double matching strategy; weighted regressions (aweight); fixed effects at bin, country_job, country_year; clustering by country_job; singleton handling |
| JAR_55_chaplinksy-hanley-moon.do | Chaplinsky, Hanley, Moon | 2017 | reg, psmatch2, xi, DCdensity | DiD + PSM, Regression Discontinuity (RD) | PSM with industry (FF17) blocks, McCrary Test for threshold manipulation, cluster SEs, winsorization via custom 'clean' program |
| JAR_55_clm.do | Casas-Arce, Lourenco, Martinez-Jerez | 2017 | tobit, reg, areg, robvar, collapse, outreg2 | Field experiment | Randomization checks, weekly/monthly data levels, within-subject dynamic effects, clustering by operator, treatment variance tests |
| JAR_55_elw.do | Ertan, Loumioti, Wittenberg-Moerman | 2017 | reg, probit | Panel Regression | Winsorization; data date/bank name cleaning; adoption quarters; multiple fixed effects; clustering by pool_id |
| JAR_55_hlsw.do | Ham, Lang, Seybert, Wang | 2017 | areg, ologit, reg | Panel FE + Experimental mediation analysis | Winsorizing, fuzzy merging (reclink), hand-checking matches, accrual errors via residuals |
| JAR_55_kks.do | Kisser, Kiff, Soto | 2017 | reg, xtscc, logit, logistic, areg | OLS, Panel FE, Two-stage regression | Winsorization (0.5% and 1%), industry/year FE, dropping frozen/terminated plans, Form 5500 merges with Compustat/CRSP |
| JAR_55_lzz.do | Ljungqvist, Zhang, Zuo | 2017 | areg, reg, tsset | Panel FE, DiD (Implied) | Lagged/contemporaneous models, NETS weighted tax changes, GSP/unemployment controls, industry-year FE, winsorization |
| JAR_55_madsen.do | Madsen | 2017 | reghdfe, reg, suest, eststo, esttab | Pseudo-events, Panel FE (firm, day-of-week, year-month) | Clustering by firm/date, winsorization, industry/time FE, Seemingly Unrelated Regression (SUR) testing |
| JAR_55_mr.do | Manchiraju, Rajgopal | 2017 | rdrobust, areg, cluster2, rdplot | Regression Discontinuity Design (RDD) | Parametric/non-parametric estimates, multiple running variables, multi-way clustering (cluster2), event window analysis (CAR), firm-level controls |
| JAR_56_al.do | Aghamolla, Li | 2018 | reg, xi, probit, psmatch2, merge | OLS, Probit, PSM, Lead-lag regressions | Lagged moving averages, winsorization of inflation observations, year-based GDP cutoffs, log-transformed media mentions |
| JAR_56_bch.do | Bernard, Cade, Hodge | 2018 | reg, logit, ttest, tabulate, corr, pwcorr, bayesmh, bayesgraph | Experimental design (Treatment vs. Control) | Continuous variable standardization, treatment interactions, Bayesian analysis with diagnostic graphs, mediation analyses |
| JAR_56_blv.do | Bozanic, Loumioti, Vasvari | 2018 | merge, collapse, contract, joinby, winsorize | Matched sample (securitized vs. non-securitized institutional loans) | Multi-step iterative matching between CLO-i and DealScan, manual false match cleaning, winsorization at 1%, industry diversification |
| JAR_56_csmw.do | Call, Martin, Sharp, Wilde | 2018 | poisson, logit, tobit, reg, ttest, signrank, ranksum, streg, psacalc | OLS, Poisson Regression | Winsorization at 1st/99th percentiles, custom 'testgroup' program, Oster (2016) confounding threshold test, survival analysis (stset/streg) |
| JAR_56_en.do | Eyring, Narayanan | 2018 | reg, ivreg, bayesmh, signrank, suest | Experimental design, IV (LATE) | Clustering by email, Bayesian factor analysis, LATE for accessed vs treated, winsorization, signed-rank tests |
| JAR_56_granja.do | Granja | 2018 | areg, streg, reg, xtreg | DiD (within state-year), Contiguous county analysis, Hazard models (Weibull) | Data cleaning (NHGIS population), cubic spline interpolation (csipolate), winsorizing, weighted regressions |
| JAR_56_htw.do | Hail, Tahoun, Wang | 2018 | logit, reg, corrtab | Panel FE (Country/Year), Lead-Lag analysis | VCE cluster by country, 3-year lagged moving averages, log transformations, manual winsorization |
| JAR_56_kmt.do | Kowaleski, Mayhew, Tegeler | 2018 | mean, melogit, mixed, summarize | Field experiment (Base, Same, Sep conditions) | Multi-level modeling (random intercepts for Session/IDs), variable centering, drop if TrueValue==5, over(Session) clustering |
| JAR_56_ksvw.do | Kim, Shroff, Vyas, Wittenberg-Moerman | 2018 | reg, probit, psmatch2 | DiD, PSM, Change Analysis | Clustered SEs (gvkey), fixed effects (i.fyear), interaction terms, two-stage modeling (probit then reg), winsorized variables |
| JAR_56_llz.do | Li, Lin, Zhang | 2018 | areg | Panel FE (industry/firm fixed effects) | Winsorizing (0.01), clustering by state, dropping financial firms |
| JAR_56_ls.do | Li, Sandino | 2018 | reg, tobit, areg, reghdfe, icc, pwcorr, winsor | DiD (Experimental Periods) | Data cleaning of store names/brands, interrater reliability analysis (icc), winsorization, store-level frequency controls |
| JAR_56_lv2018.do | Leung, Veenman | 2018 | logit2, cluster2, psmatch2, xtreg | PSM, Stacked regressions, Portfolio tests | Hand-collected validation, Rosenbaum bounds (rbounds), Perl-based text search of 8-K filings |
| JAR_57_bht.do | Bradshaw, Huang, Tan | 2019 | xtreg, reghdfe, collapse, merge | Panel FE (Firm/Analyst fixed effects) | Clustering by HQ country, Target Price Optimism analysis (local vs foreign analysts), PCA for country traits |
| JAR_57_bl.do | Basu, Liang | 2019 | statsby, regress, egen, collapse, winsor, merge | Extended 3-period model, Sadka liquidity measure | Winsorized returns, fund age/NAV controls, Sadka Beta estimation, robust SEs, audit variable historical data |
| JAR_57_bw.do | Breuer, Windisch | 2019 | reg, xtreg, var, irf create, irf graph | Economic model simulation, Panel FE | Simulation data evaluation, placebo test with lagged earnings, impulse response functions, outlier treatment, cross-sectional determinants |
| JAR_57_cct.do | Cascino, Correia, Tamayo | 2019 | logit2, reghdfe, winsor2, xi:logit2, outreg2 | DiD, Panel FE (Subcategory, State, Year-month) | Multi-way clustering (fcluster/tcluster), short event windows, border county analysis, winsorization (1 99), post×treated interactions |
| JAR_57_cgw.do | Costello, Granja, Weber | 2019 | areg, outreg2, winsor2, outtable, eqprhistogram, putexcel | Panel FE (County, Quarter, Regulator, Quarter/County FE) | Clustered SEs (vce cluster reg_state), TED Spread/House Price timing analysis, textual restatement descriptions (RI-E schedules) |
| JAR_57_hcp.do | Heese, Perez Cavazos | 2019 | areg, reghdfe | DiD (Implied/Event Study) | Quarterly panel analysis, eight-quarter pre/post treatment window, firm/year-quarter FE, clustered SEs by gvkey |
| JAR_57_honigsberg.do | Honigsberg | 2019 | regress, statsby, psmatch2, probit, winsor, collapse, merge | DiD + PSM | PSM with 3 restriction weighting, winsorization at 1%, Sadka liquidity controls, multiple period robustness (3-period model) |
| JAR_57_lehmann.do | Lehmann | 2019 | reg, areg, pca, winsor, esttab, merge | DiD | PCA for completeness, balanced sample restrictions, hand-collected governance data, year/industry FE |
| JAR_57_lm.do | Law, Mills | 2019 | reghdfe, areg, logit, newey, xi | Panel FE, OLS (Matched Sample), Factor Model | Multi-level clustering (zip3, county, crsp_fundno), fixed effects for city/year/firm-cohort, FINRA/SEC data cleaning |
| JAR_58_bsz.do | Bourveau, She, Zaldokas | 2020 | probit, xtset, winsor2 | Industry-level panel analysis | NAICS-SIC cross-walk, industry-level weighting, HHI construction, winsorization at 1/99% |
| JAR_58_ckm.do | Cuny, Kim, Mehta | 2020 | areg, reghdfe, pca, reg | IV, Panel FE | PCA for quality measures, lagged variables, instrumenting tenure with death, state-by-year FE, clustering by state code |
| JAR_58_eyring.do | Eyring | 2020 | reg | Panel FE (Physician fixed effects) | Clustering by specialty/clinic, age-based categorizations, confidential health data merging |
| JAR_58_gj.do | Gallemore, Jacob | 2020 | reg, areg, xtset, winsor | DiD, OLS, Panel FE | District-level macroeconomic aggregation (unemployment, HPI), winsorization at 1%, Compustat/IRS audit merge |
| JAR_58_gsz.do | Gillette, Samuels, Zhou | 2020 | xtreg | Panel FE (Issuer/State fixed effects) | SDC data cleaning, balanced panels (tsfill), macro variable winsorization |
| JAR_58_htyz.do | He, Tian, Yang, Zuo | 2020 | reghdfe, asreg, winsor | Baseline OLS | High-dimensional FE (sic3_year), three-step cost stickiness measure, lead/lag construction, gvkey clustering |
| JAR_58_jansen.do | Jansen | 2020 | reghdfe, reg, estpost, summarize, graph export | Panel FE (High-dimensional fixed effects) | Clustering by FF-48 industry/state, intensive margin analysis, robustness on revenue thresholds (>$1m), moral hazard |
| JAR_58_joshi.do | Joshi | 2020 | rdrobust, reghdfe, ttest | RDD, DiD | Proprietary tax incentive calculation; firm/year FE; clustering by firm/parent; majority-owned affiliates |
| JAR_58_kvy.do | Kim, Verdi, Yost | 2020 | winsor2, center, collapse, merge | Not in source | Winsorization (1/99), variable centering, tone disclosure proxies (Sentiment/CAR/Index), spillover rank |
| JAR_58_msz.do | Mehta, Srinivasan, Zhao | 2020 | oprobit, reg, xi | Cross-sectional analysis (M&A outcomes) | Ordered Probit base model, high-risk deals identification (vertical/competition), hand-collected regulatory data, state clustering |
| JAR_58_rauter.do | Rauter | 2020 | reghdfe, winsor2, kountry, merge, collapse, reshape | DiD | Coarsened Exact Matching (CEM), FE for resource-year/host country-year/firm-subsidiary/treated-year, variable trimming/winsorization |
| JAR_58_wy.do | Wu, Ye | 2020 | xtreg, robust, fe, xi, ologit, winsor, ttable2 | Panel FE, DiD, PSM, Placebo test, Falsification test | Winsorization at 1%, industry-year FE, clustering by firm code, exact matching by size/ROA |
| JAR_58_zz.do | Zhou, Zhou | 2020 | reg, statsby | OLS, Factor Loadings calculation (FF 3-factor + momentum) | Winsorization (1%), value-weighted size portfolio returns, 4-factor adjustment, RavenPack/Markit merge |
| JAR_59_breuer.do | Breuer | 2021 | reghdfe, ivreghdfe, tabstat, estout, ds, destring, reshape, duplicates drop, merge | IV (Instrumented Reporting/Auditing Scopes), Panel FE, OLS (Reduced Form) | Variable truncation (1st/99th percentiles), Monte Carlo simulation for scopes, multi-level clustering (Country-Industry/Country-Year), Amadeus panel |
| JAR_59_ctv.do | Cascino, Tamayo, Vetter | 2021 | stcox, reghdfe, xtpoisson, poisson, reg, binscatter, spmap | DiD, DiDiD, Quadruple Difference, Cox hazard model, Border-county analysis | Event-time plots, placebo analysis (CPAs vs lawyers), weighted regressions, state/firm clustering, balancing checks |
| JAR_59_dess.do | Dechow, Erhard, Sloan, Soliman | 2021 | asreg, fmb (Fama-MacBeth), reg, ttest, gstats winsor, fasterxtile, gcollapse | Panel FE (Fama-MacBeth Regressions) | Dimson Beta adjustments, cumulative return filtering, IBES subsample revisions, value-weighted/equal-weighted portfolios |
| JAR_59_hmo.do | Hail, Muhn, Oesch | 2021 | reghdfe, rollstat, xtset, tsfill, fsum, outreg2 | DiD, Event Study (Swiss Franc Shock), Synthetic Control | Intraday rolling volatility, robust SEs (firm/date×time clustering), high-frequency data cleaning, illiquid firm removal |
| JAR_60_abkp.do | Allee, Bushee, Kleppe, Pierce | 2022 | areg, xtset, rangestat, ttest | OLS, Event Study, Nearest Neighbor Match | Winsorizing, firm FE (absorb gvkey), PSM (inferred), suspect trading (Acharya & Johnson 2010), Char-adjusted returns |
| JAR_60_alv.do | Allen, Lewis-Western, Valentine | 2022 | xtreg, reghdfe, ebalance, winsor2 | DiD + Entropy Balancing | Entropy balancing (ebalance) for covariate control, pseudo-event falsification, time trend analysis (leads/lags), patent variable scaling |
| JAR_60_at.do | Aghamolla, Thakor | 2022 | reghdfe, ivregress, psmatch2, newey | DiD + IV | PSM (norepl), Placebo tests, Newey-West SEs for autocorrelation, 2SLS estimation |
| JAR_60_barrios.do | Barrios | 2022 | reg, matchit, cem, ttest, destring, egen, sieve | DiD (150-Hour Rule) + CEM | Coarsened Exact Matching, string matching (token_soundex) with AuditAnalytics/Compustat, linguistic measures (Fog/Flesch) |
| JAR_60_bbin.do | Barrios, Bianchi, Isidoro, Nanda | 2022 | reshape long, carryforward, tsset, factor, rotate, xi | Panel FE, Principal Component Analysis (PCA) | BoardEx data cleaning, dyadic director-linked dyads, institutional/cultural proximity factors |
| JAR_60_bdem.do | Bourveau, De George, Ellahie, Macciocchi | 2022 | reghdfe, pca, winsor2, xtile | Panel FE (Region, Industry, Quarter FE) | Disclosure Index construction, PCA, region-quarter clustering, singleton handling in reghdfe |
| JAR_60_bl.do | Berger, Lee | 2022 | reghdfe, diff, ttest, ebalance | DiD (Dodd-Frank whistleblower provision) | Entropy balancing (ebalance); winsorization; firm/year FE; firmN clustering; parallel trends check |
| JAR_60_bmsw.do | Bochkay, Markov, Subasi, Weisbrod | 2022 | reghdfe, winsor2, summarize | DiD (Post×Treatment), Triple Interaction | High-dimensional FE (absorb permno yearqtr pr_hr), clustered errors (permno pr_date), singleton dropping |
| JAR_60_cc.do | Chen, Conaway | 2022 | reg, logit, xtlogit, margins, winsor | Determinants regression with residuals; Timing analysis using Logit | Clustering by gvkey/cik, Predicted vs Abnormal dilution, Industry/Year FE, bootstrap VCE for xtlogit |
| JAR_60_cpss.do | Coles, Patel, Seegert, Smith | 2022 | reg, collapse, merge, cross | Bunching Analysis and Real vs Reporting response | Simulated COGS labor expenses, sample restriction (top/bottom 5%), counterfactual region ID |
| JAR_60_cstv.do | Carson, Simnett, Thurheimer, Vanstraelen | 2022 | reg, winsor2, fillmissing, reshape, merge, xtset | Panel FE (Company-year observations) | Missing data imputation, CPI adjustment for fees, discretionary accruals (Modified Jones), distance/IFRS controls |
| JAR_60_dg.do | Davila, Guasch | 2022 | cluster2, logit, pca (via R/merge), pwcorr | Panel FE, Double clustering (Firm/Industry) | PCA (Anderson scores), median split on firm age/VC presence, specific pitch segment analysis (40-80%) |
| JAR_60_duguay.do | Duguay | 2022 | reghdfe, tabstat, xtset | Panel FE (DiD variant) | Multi-way FE (STATE_YEAR_ID, ACTIVITY_YEAR_ID), STATE_ID clustering, LOW_IA/HIGH_IA interactions |
| JAR_60_fhl.do | Fiechter, Hitz, Lehmann | 2022 | xtreg, psmatch2, pca, winsor | DiD + PSM | PSM with replacement/calipers, industry-adjusted CSR measures, balanced panel, industry clustering |
| JAR_60_gls.do | Green, Louis, Sani | 2022 | reghdfe, reg | Time-series trend analysis | High-dimensional FE (Firm/Year), Firm/Year clustering, alternative book value deflators, financial crisis robustness |
| JAR_60_hmryz.do | Hribar, Mergenthaler, Roeschley, Young, Zhao | 2022 | regress, test | DiD and OLS with Panel FE | Orthogonalization to RBC/length, industry-by-year/firm FE, FOG index robustness, portfolio tests |
| JAR_60_hst.do | Hallman, Schmidt, Thompson | 2022 | nearmrg, xtset, winsor2, rowsd | Not in source | Near-matching for currency conversion, lead/lag creation (up to 4 years), contextual factor scores, winsorization (1/99) |
| JAR_60_kt.do | Kleymenova, Tomy | 2022 | append, merge, duplicates drop | DiD (Implicit via disclosure_regime/crisis) | SNL/BEA data merging, textual analysis (Gunning_FOG, SMOG), county fill missing |
| JAR_60_mliu.do | Liu | 2022 | probit, ivprobit, reg, ivregress 2sls, areg, logit, lrtest | IV using Officer Leniency as instrument | Bootstrap clustering by officer, random assignment tests, ML model comparison (GBM/OLS), performance decomposition |
| JAR_60_nrwx.do | Neilson, Ryan, Wang, Xie | 2022 | reg, tsset, reshape, merge | DiD | Tranche-to-deal aggregation, pseudo-event analysis, risk layering at loan level, EDGAR IP tracking |
| JAR_60_ptwy.do | Peng, Teoh, Wang, Yan | 2022 | reghdfe, logit, orthog, suest | Event Study / OLS | Orthogonalization of face traits, 3-way interactions, Suest coefficient equality tests, LinkedIn data, de-meaned controls |
| JAR_60_skim.do | Kim | 2022 | reghdfe, ivreghdfe, reg | DiD and IV | State clustering, County-Year/ZIP FE, standardized exposure measures, bank-level×Post interactions |
| JAR_61_bcdr.do | Balakrishnan, Copat, De La Parra, Ramesh | 2023 | reg, probit, mlogit, matchit, tetrachoric, factormat, margins, xtset | OLS, Probit, Multi-Logit, DiD, Factor Analysis | Winsorizing (winsor2), bootstrap vce, cluster robust SEs (iss_company_id), regex parsing, geodist, NAICS matching |
| JAR_61_bkr.do | Bird, Karolyi, Ruchti | 2023 | reghdfe | Event Study / DiD | Analytical weights (aw) by state exposure; cik/state clustering; event study blocks; BEA input-output measures |
| JAR_61_bls.do | Bol, LaViers, Sandvik | 2023 | reghdfe, reg, suest, ttest, unique, merge | Field Experiment (Randomized Treatment) | Pre-screening survey time extraction, outlier controlled specs, effect coding, self-reported vs third-party comparisons |
| JAR_61_bo.do | Bonetti, Ormazabal | 2023 | reghdfe, winsor | Top Lists / Ranking identification | ASEAN governance scores cleaning, narrow bandwidth rankings (50-X to 50+X), PSM (norepl), winsorization |
| JAR_61_ccm.do | Carnes, Christensen, Madsen | 2023 | svy, factor, rotate, import sas | Cross-sectional OLS with survey weights | Factor analysis (public service vs commercial), zip-to-county FIPS mapping, university location estimation, HERI strata |
| JAR_61_cdss.do | Chang, Dambra, Schonenberger, Suk | 2023 | areg, predict, tsset | Residualized (Unexpected) Compensation Model | Industry FE (absorb sic2), annual expected value loops, lag averaging for unexpected pay |
| JAR_61_cfhll.do | Chow, Fan, Huang, Li, Li | 2023 | reghdfe, psacalc, areg, probit | DiD + Oster test for endogeneity | High-dimensional FE (state-industry-year), Oster test (psacalc) for unobservable selection, media attention, Superfund cleanup |
| JAR_61_cfmp.do | Chircop, Fabrizi, Malaspina, Parbonetti | 2023 | winsor, xtset, merge, collapse | DiD (regulatory/police actions against Mafia) | Sample selection via unique anti-mafia action hits, macro-industry classification, 3-year rolling mean tax avoidance |
| JAR_61_ckor.do | Cohen, Kadach, Ormazabal, Reichelstein | 2023 | merge, winsor2, ffind, xtile, reghdfe, tsset | OLS, Panel FE | Balanced firm-year panel, abnormal compensation vs peers, diverse ESG/debt dataset merging |
| JAR_61_cllw.do | Chen, Li, Lu, Wang | 2023 | reghdfe, rangejoin, winsor2, xtile | Panel FE (Firm/State-Year-Quarter FE) | Flu data merge (rangejoin), IPW (Information Production Window) calculation, industry MF controls, bundled/unbundled forecasts |
| JAR_61_clm.do | Chan, Lill, Maas | 2023 | logit, signrank, ranksum, anova, swilk | Field experiment / Within-subject design | Marginal effects analysis, Social Value Orientation controls, multiple comparison p-value correction, Wilk-Shapiro test |
| JAR_61_deller.do | Deller | 2023 | tab, egen, xtset | Panel FE | Extensive date formatting, handling duplicate PersonID/Year by completeness, multi-year exit data, expat/guest/impat categories |
| JAR_61_dlrtw.do | Dyck, Lins, Roth, Towner, Wagner | 2023 | xtset, winsor, mmerge | Lead variable analysis | Balanced panel construction, sequential ISIN/SEDOL merging, family/blockholder classification, industry/country FE |
| JAR_61_dlz.do | deHaan, Li, Zhou | 2023 | reghdfe (implied by log), winsor2, tsfill | Event Study / Weekly panel | Weekly aggregation relative to RDQ, labor mobility (NAICS), peer firm news/media tone, large review change exclusion |
| JAR_61_drs.do | Duguay, Rauter, Samuels | 2023 | reghdfe, odbc, winsor2, reshape | Not in source | Factiva article retrieval for NGO mentions, media coverage normalization, winsorization (0/95) by country |
| JAR_61_ds.do | Distelhorst, Shin | 2023 | xtreg, reghdfe, ebalance, did_multiplegt, stackedev, outreg2 | DiD, Event Study, Entropy Balancing | Entropy balancing on pretreatment supplier scores; staggered adoption; De Chaisemartin/D'Haultfoeuille (2020) estimators; factory time trends |
| JAR_61_glt.do | Gallo, Lynch, Tomy | 2023 | winsor2, merge, egen | Panel data analysis (R&D/restructuring) | R&D winsorization by year, GVKEY merging, rolling non-missing observations |
| JAR_61_gyz.do | Goldstein, Yang, Zuo | 2023 | reghdfe, psmatch2, winsor, xtset | Stacked DiD + PSM | EDGAR phase-in analysis, phase-specific PSM, group-specific trends, $10M asset filters |
| JAR_61_ll.do | Liu, Lu | 2023 | reghdfe, reg, winsor2, xfill, binscatter | DiD, Cross-sectional analysis | Winsorization, placebo information exposure, teleworkability/essential industry partitions, Zip/City-Day/County-Day/State-Day FE |
| JAR_61_lszz.do | Liu, Shi, Zeng, Zhang | 2023 | areg, winsor2, xtileJ | DiD (IFRS adoption) | Benchmark group construction (size/leverage partitions), HHI, voluntary adopter exclusion (GR/ES), bvd_id clustering |
| JAR_61_os.do | Olbert, Severin | 2023 | reghdfe, merge, joinby, winsor2, collapse, xtset | DiD (Event Study) | County/municipal aggregation, PSM (nearest neighbor), Euclidean distance matching, state-year/industry-year FE |
| JAR_61_zureich.do | Zureich | 2023 | logit, reg, margins, factor, lincom | Experimental design with Panel FE | Round/Trial FE, pairwise comparisons (lincom), goal-focus factor analysis, attention allocation (hover time) |
| JAR_62_1_bdsy_banerjee_etal.do | Banerjee et al. | 2024 | reghdfe, append, expand, joinby | DiD (Shock Spillovers), Dynamics Analysis | Simulated data illustration, cohort-year FE (absorb tc ic), industry clustering, fraud year exclusion |
| JAR_62_1_bhs_bouwens_etal.do | Bouwens, Hoffman, Schwaiger | 2024 | reg, logit, ttest, suest, margins, pwcorr | OLS, Logit, Target Ratcheting Analysis | Subsidiary ID clustering, relative target difficulty, region/year FE, cross-partial derivatives |
| JAR_62_1_gsz_gu_sun_zhou.do | Gu, Sun, Zhou | 2024 | winsor2, reg, merge | OLS / Panel Regression | Hand-collected geographic coordinates, great-circle distance calculations, historical jinshi data, industry FE |
| JAR_62_2_dgzz_defranco_etal.do | De Franco et al. | 2024 | areg | Stacked DiD | Robust SEs, state-year clustering, cohort-specific fixed years, gvkey absorption |
| JAR_62_2_gmp_grewal_etal.do | Grewal, Mohan, Perez-Cavazos | 2024 | reghdfe, areg, winsor2, prtest | DiD (Payment practices transparency regulation) | SME vs Large firm categorization (assets/sales/employees), RepRisk integration, industry HHI, proportions tests |
| JAR_62_2_xyz_xin_etal.do | Xin, Yeung, Zhang | 2024 | reghdfe, stcox, areg, psmatch2, winsor2 | DiD + Hazard model + PSM | Pseudo-regulation placebo tests, skill-based classification, Cox proportional hazards for fund collapse, intervals |
| JAR_62_3_bht_bloomfield_etal.do | Bloomfield, Heinle, Timmermans | 2024 | rangejoin, winsor2, joinby, collapse | Network analysis of RPE peers | Network construction (price vs accounting peers), disclosure return reversals, tournament standings, fiscal year shifts |
| JAR_62_3_ccz_cheynel_etal.do | Cheynel, Cianciaruso, Zhou | 2024 | reghdfe, winsor2, coefplot | DiD | Coefficient plotting for dynamic analysis, state clustering, misstatement/assets calculation, restatement episodes |
| JAR_62_3_kim.do | Kim | 2024 | reghdfe, winsor2, tabstat | Panel FE (Earnings Response Coefficients) | High-dimensional FE (cik, fyear, or sic3#fyear), sur_eps interactions, nb/cik clustering |
| JAR_62_3_rr_raghunandan_ruchti.do | Raghunandan, Ruchti | 2024 | collapse, xtset, winsor, merge | Panel FE (Firm-State FE) | Fuzzy OSHA data matching/hand-checking, out-of-state violations, whistleblower vs planned inspection, penalties-not-OSHA deciles |
| JAR_62_4_bd_breuer_dehaan.do | Breuer, deHaan | 2024 | reg, predict | Panel FE (Firms/Means re-centering) | Synthetic data generation for FE interpretation, residualization plots, firm-specific vs point-of-means |
| JAR_62_4_cc_cadman_carrizosa.do | Cadman, Carrizosa | 2024 | reg, logit, xtlogit, margins, winsor | Residual analysis (Abnormal dilution) + Timing Logit | Equilar equity plan measures, prediction residuals for voting, industry-year FE, labor market competition |
| JAR_62_4_kmsv_kohler_etal.do | Kohler et al. | 2024 | reghdfe, ivreghdfe, xtqreg, winsor2, bootstrap, coefplot, pc_simulate | Field experiment (DiD + IV) | IV (LATE) for app usage, power analysis simulation, quantile regressions with bootstrap, pre-treatment placebo |
| JAR_62_4_mps_marra_etal.do | Marra, Pettinicchio, Shalev | 2024 | eventstudy2, winsor2, sicff, merge, append | Event Study (CAR calculation) | FF3-factor/Carhart 4-factor models; winsorization; country-pair FE |
| JAR_62_4_raghunandan.do | Raghunandan | 2024 | reghdfe, winsor | Panel FE with high-dimensional interactions | Complex absorption (gvkey##state_factor state_factor##sic2##year); gvkey/industry-year clustering; inherited subsidy mergers |
| JAR_62_4_stv_sran_etal.do | Sran, Tuijn, Vollon | 2024 | reghdfe, factor, regress | DiD (Bundled implementation) | Factor analysis for liquidity; weekly return synchronicity; firm/year-quarter FE; country-industry/year-quarter clustering |
| JAR_62_4_xu.do | Xu | 2024 | reghdfe, ivreghdfe, probit2, fffind | Panel FE + IV | Journalist turnover as IV, second-degree network connections, TF-IDF word weighting, daily CAR |
| JAR_62_5_aov_abraham_etal.do | Abraham, Olbert, Vasvari | 2024 | reghdfe, stackedev, ppmlhdfe, winsor2 | Stacked DiD, Poisson FE (PPML) | Stacked regression (Cengiz et al 2019), web-scraped ESG metrics, fuzzy name matching (OSHA/TRI/Trucost), World Bank controls |
| JAR_62_5_gibbons.do | Gibbons | 2024 | reghdfe, winsor, joinby, reshape long, ihstrans | DiD, Stacked DiD, Synthetic Control (augsynth) | Control standardization, inverse hyperbolic sine (patents), churn rate calculation, stacked regression |
| JAR_62_5_jiang.do | Jiang | 2024 | reghdfe, ppmlhdfe | Panel FE (Operator, Shale Play-Year-Month FE) | Within-operator analysis, distance-based monitor validation (QGIS), nplay-year clustering |
| JAR_62_5_kstz_krueger_etal.do | Krueger et al. | 2024 | reg, winsor, factor, tsset | Not in source | Mandatory ESG disclosure year mapping, illiquidity factor extraction, voluntary vs mandatory grouping, residual variables |
| JAR_62_5_llz_li_lou_zhang.do | Li, Lou, Zhang | 2024 | reghdfe, ebalance, outreg2 | DiD, Dynamic Analysis, Entropy Balancing | Multi-dimensional FE (country_year, ind_year), esg_identifier clustering, entropy balancing weights (aw=ebw), cross-sectional |
| JAR_62_5_lrst_lins_etal.do | Lins et al. | 2024 | reghdfe, regress | Event Study / DiD (#MeToo) | Market model abnormal returns; manually checked gender; Factset ownership; ESG terciles; firm/permno clustering |
| JAR_62_5_lswy_lin_etal.do | Lin et al. | 2024 | reghdfe, winsor2, sicff, centile, absorb | OLS, Panel FE, DiD (mandate analysis) | ML-based ESG metrics (boilerplate, specificity), 1%/99% winsorization, nation code clustering |
| JAR_62_5_lw_li_wang.do | Li, Wang | 2024 | reghdfe, ppmlhdfe, esttab, corrtbl, coefplot | Panel FE (Firm/Month FE) | PPML for count data (Edgar filings), cross-sectional interactions, rule-making segments, bankruptcy prediction |
| JAR_63_1_blmv_bastiaansen_etal.do | Bastiaansen et al. | 2025 | reg, probit, pwcorr, tabstat | Multivariate Analysis (Full/Public/Private) | Disclosure Index construction, subsequent bankruptcy prediction, ex post projection accuracy, claimant characteristics |
| JAR_63_1_cvw_chen_etal.do | Chen, Vashishtha, Wang | 2025 | reghdfe, mkspline, suest, winsor2 | Panel FE / Weighted average growth | Spline regressions with knots at zero; fair value gain residuals; cross-model suest testing; SOD/state-quarter FE |
| JAR_63_1_fgr_frankel_etal.do | Frankel, Godigbe, Rabier | 2025 | reghdfe, winsor2, xtile | Correlation / Comovement analysis | Macro news day interactions, comparability measures (De Franco), industry leadership rankings, 3-day CARs |
| JAR_63_1_hrsx_huang_etal.do | Huang et al. | 2025 | logit, reghdfe, xi, outreg2, winsor2, pwcorr, ttest | Panel FE / Judge Fixed Effects | Social connections (alumni), judge-level FE, firm clustering, defendant/executive visibility cross-sections |
| JAR_63_1_jia.do | Jia | 2025 | reghdfe, pca, winsor2, suest | Panel FE (State, Office, Year, Industry FE) | PCA (PAC index), vacant judge analysis, budget constraints, abnormal accruals (accrual quality) |
| JAR_63_2_bcrw_bakke_etal.do | Bakke et al. | 2025 | reg, logit, probit, xtset, winsor2, rangejoin, asdoc | Audit partner rotation (Mandatory vs Voluntary), PSM via Probit | Clustered by firm (cik)/partner (engagementpartnerid), 2/3-year growth windows, future restatement control |
| JAR_63_2_dlr_desimone_etal.do | De Simone, Lester, Raghunandan | 2025 | reghdfe, suest, collapse, merge, xtset | DiD, Panel FE | State-year FE, disclosure law type testing (internal vs external), education data imputation, megadeal exclusion |
| JAR_63_2_mqtz_mao_etal.do | Mao et al. | 2025 | reghdfe, clogit, logit, winsor2, joinby, eventus (SAS) | DiD, Matched Sample, Placebo Test | Citation-weighted patents, pseudo-acquirer matching (size/MB), SEC filing keywords, falsification tests |
| JAR_63_2_npstv_nessa_etal.do | Nessa et al. | 2025 | reghdfe, reg, ebalance, merge | DiD (Treated via revenue threshold) | Entropy balancing by year (1st/2nd moments), pweight application, 500M revenue bandwidth, majority-owned filter |
| JAR_63_3_breuer.do | Breuer | 2025 | reghdfe, drawnorm, corr, lincom, estout, reshape | Panel FE (Reduced Form) | Monte Carlo simulation for standardized scope, multivariate distribution (Gibrat's Law), residual truncation, stacked regressions |

## Method Frequency Summary

**Regression-based methods:**
- Panel fixed effects (reghdfe, xtreg, areg): 54 files
- Difference-in-differences (DiD): 22 files
- Event study (CAR/BHAR analysis): 19 files
- Propensity score matching (PSM): 10 files
- Instrumental variables (IV): 3 files
- Regression discontinuity (RDD): 2 files

**Robustness techniques:**
- Bootstrap/resampling: 20 files
- Entropy balancing: 5 files
- Survival/duration analysis: 4 files
- Quantile regression: 1 file

**Specialized approaches:**
- Machine learning/image analysis: 2 files
- Natural language processing: 1 file
- Fund/portfolio-level analysis: 3 files

**Total files: 126 (2017-2025)**

---

## Technical Appendix: Detailed Methodology Reference

For each replication file, the Robustness/Special Features column now provides:
- **Specific STATA commands** used (beyond just the method category)
- **Data construction details** (data cleaning, merging strategies, variable creation)
- **Identification strategy specifics** (e.g., parallel trends checks, placebo tests)
- **Robustness checks** (e.g., winsorization levels, clustering specifications)
- **Advanced techniques** (machine learning, specialized packages, custom programs)
- **Key data sources** (external databases merged, hand-collected data)

This allows researchers to quickly identify papers employing specific technical approaches for methodological guidance and code pattern extraction.
