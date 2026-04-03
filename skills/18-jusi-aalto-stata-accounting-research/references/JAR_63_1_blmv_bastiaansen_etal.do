/*************************************************************************
"Court Disclosures of Firms in Chapter 11 Bankruptcy"
Authors: Ilona Bastiaansen, Alina Lerman, Frank Murphy, and Dushyant Vyas
STATA Code File
*************************************************************************/

clear all
set more off
log using "C:\Users\ibastiaa\Dropbox\Research\Bankruptcy\Bankruptcy\Bankruptcy Data\Bankruptcy Code\Final Submission Code\JAR\2b Bankruptcy Disclosure Code - Log.txt"

*Load Dataset
global root C:\Users\ibastiaa\Dropbox\Research\Bankruptcy\Bankruptcy\Bankruptcy Data\Bankruptcy Code\Final Submission Code\Data Files
global dta $root\dta
global log $root\log
use "$root\BKRPT_Full_Data", replace

*Convert from string to numerical;
destring gvkey2, generate(gvkey3)
destring KEIP, generate(KEIP2)
destring Bond_Note, generate(Bond_Note2)
destring Num_Revisions, generate(Num_Revisions2)

*Create year variables;
gen date_filed_year = year(DateFiled)
replace Dateconfirmed_year = year(DateConfirmed)

*Convert industry categories into a categorical variable;
gen sich_cat2 = .
replace sich_cat2 = 1 if sich_cat == "Agriculture, Forestry & Fishing"
replace sich_cat2 = 2 if sich_cat == "Mining"
replace sich_cat2 = 3 if sich_cat == "Construction"
replace sich_cat2 = 4 if sich_cat == "Manufacturing"
replace sich_cat2 = 5 if sich_cat == "Transportation & Public Utiliti"
replace sich_cat2 = 6 if sich_cat == "Wholesale Trade"
replace sich_cat2 = 7 if sich_cat == "Retail Trade"
replace sich_cat2 = 8 if sich_cat == "Finance, Insurance & Real Estat"
replace sich_cat2 = 9 if sich_cat == "Services"
replace sich_cat2 = 10 if sich_cat == "Public Administration"
replace sich_cat2 = 11 if sich_cat == "Nonclassifiable Establishments"

*Drop private firm observations for public only variables
replace multinational = . if Public_file == 0
replace guidance = . if Public_file == 0
replace z_score_qh = . if Public_file == 0
replace Disp_Claims = . if Public_file == 0

*One observation with pre-petition assets of 0: set to 1
replace pre_petition_assets = 1 if pre_petition_assets == 0
replace pre_petition_assets_log = ln(1) if pre_petition_assets == 1

*Create emerging assets variable
replace Assets_Emerg = "" if Assets_Emerg == "N/A"
destring Assets_Emerg, generate(Assets_Emerg2)
gen Assets_Emerg3 = Assets_Emerg2/1000000
gen Assets_Emerg3_log = ln(Assets_Emerg3)

*Create emerging liabilities variable
replace Liab__Emerge = "" if Liab__Emerge == "N/A"
destring Liab__Emerge, generate(Liab_Emerg2)
gen Liab_Emerg3 = Liab_Emerg2/1000000

*Convert EBITDA values to millions
gen EBITDA_Year1_adj = EBITDA_1/1000000
gen EBITDA_Year2_adj = EBITDA_2/1000000
gen EBITDA_Year3_adj = EBITDA_3/1000000
gen EBITDA_Year4_adj = EBITDA_4/1000000
gen EBITDA_Year5_adj = EBITDA_5/1000000

*Convert debt analyst variables from string to numeric;
destring danalyst_post1, generate(danalyst_post1a)
gen danalyst_post1a = danalyst_post1

destring danalyst_post2, generate(danalyst_post2a)
gen danalyst_post2a = danalyst_post2

destring danalyst_post3, generate(danalyst_post3a)
gen danalyst_post3a = danalyst_post3

replace danalyst_post4 = "" if danalyst_post4 == "N/A"
destring danalyst_post4, generate(danalyst_post4a)

replace danalyst_post5 = "" if danalyst_post5 == "N/A"
destring danalyst_post5, generate(danalyst_post5a)


/*************************************************************************
FIGURE 1 & TABLE 2
*************************************************************************/

*Figure 1: The Proportion of Chapter 11 Cases in each Jurisdiction
tabstat date_filed_year, stat(n) by(District_complete)

*Table 2 Panel A: Annual Distribution of Public and Private Firms Filing for Chapter 11 Bankruptcy
tabstat date_filed_year if Public_file == 1, stat(n) by(date_filed_year)
tabstat date_filed_year if Public_file == 0, stat(n) by(date_filed_year)
tabstat date_filed_year, stat(n) by(date_filed_year)

*Table 2 Panel B: Industry Representation of Public and Private Firms Filing for Chapter 11 Bankruptcy
tabstat date_filed_year if Public_file == 1, stat(n) by(sich_cat)
tabstat date_filed_year if Public_file == 0, stat(n) by(sich_cat)
tabstat date_filed_year, stat(n) by(sich_cat)

/*************************************************************************
TABLE 3
*************************************************************************/

*Table 3 Panel A: Chapter 11 Disclosure Statement Items
tabstat DI_balance_sheet DI_cash_flow_acct DI_proj_rev DI_proj_exp DI_proj_liquidity DI_rev_ass DI_exp_ass DI_num_tables DI_Num_years_projected DI_sources_uses DI_valuation_stmt DI_valuation_methods DI_liquidation_stmt DI_governance DI_plan_sum DI_tax, stat(n mean p50) columns(statistics)

*Table 3 Panel B: Chapter 11 Disclosure Index and Subindices
tabstat DI DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER Num_years_projected num_tables valuation_methods, stat(n mean sd p25 p50 p75) columns(statistics)

*Table 3 Panel C: Annual Distribution of Chapter 11 Disclosure Index
tabstat DI, stat(n mean p50) by(date_filed_year)

*Table 3 Panel D: Correlations among Chapter 11 Disclosure Statement Items
pwcorr DI_balance_sheet DI_cash_flow_acct DI_proj_rev DI_proj_exp DI_proj_liquidity DI_rev_ass DI_exp_ass DI_num_tables DI_Num_years_projected DI_sources_uses DI_valuation_stmt DI_valuation_methods DI_liquidation_stmt DI_governance DI_plan_sum DI_tax, sig star(0.1)

*Table 3 Panel E: Chapter 11 Disclosure Index and Subindices for Public and Private Firms
* (1) Public Sample - Emerging Public
keep if Public_file == 1
tabstat DI DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER if Public_emerge == 1, stat(n mean p50) columns(statistics)

* (2) Public Sample - Emerging Private
keep if Public_file == 1
tabstat DI DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER if Public_emerge == 0, stat(n mean p50) columns(statistics)

* (3) Private Sample
tabstat DI DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER if Public_file == 0, stat(n mean p50) columns(statistics)

/*************************************************************************
TABLE 4
*************************************************************************/

*Table 4 Panel A: Descriptive Statistics for the Full Sample
* (1) Claimant characteristics
tabstat Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP, stat(n mean sd p25 p50 p75) columns(statistics)

* (2) Case characteristics
tabstat Judge District Outside_counsel Restr_adv prepack days_bankruptcy Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge, stat(n mean sd p25 p50 p75) columns(statistics)

* (3) Debtor characteristics
tabstat  pre_petition_assets pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability, stat(n mean sd p25 p50 p75) columns(statistics)

*Table 4 Panel B: Descriptive Statistics for Public and Private Firms Separately

*Public Sample - Emerging Public
keep if Public_file == 1

* (1) Claimant characteristics
tabstat Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP if Public_emerge == 1, stat(n mean p50) columns(statistics)

* (2) Case characteristics
tabstat Judge District Outside_counsel Restr_adv prepack days_bankruptcy Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge if Public_emerge == 1, stat(n mean p50) columns(statistics)

* (3) Debtor characteristics
tabstat  pre_petition_assets pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_emerge == 1, stat(n mean p50) columns(statistics)


*Public Sample - Emerging Private
keep if Public_file == 1

* (1) Claimant characteristics
tabstat Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP if Public_emerge == 0, stat(n mean p50) columns(statistics)

* (2) Case characteristics
tabstat Judge District Outside_counsel Restr_adv prepack days_bankruptcy Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge if Public_emerge == 0, stat(n mean p50) columns(statistics)

* (3) Debtor characteristics
tabstat  pre_petition_assets pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_emerge == 0, stat(n mean p50) columns(statistics)


*Private Sample
* (1) Claimant characteristics
tabstat Bond_Note2 UC_Comm Equity_Comm DIP if Public_file == 0, stat(n mean p50) columns(statistics)

* (2) Case characteristics
tabstat Judge District Outside_counsel Restr_adv prepack days_bankruptcy Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge if Public_file == 0, stat(n mean p50) columns(statistics)

* (3) Debtor characteristics
tabstat  pre_petition_assets pre_petition_assets_log   Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix if Public_file == 0, stat(n mean p50) columns(statistics)


/*************************************************************************
TABLE 5
*************************************************************************/

*Table 5 Panel A: Sell-Side Equity Analysts
tabstat DateFiled, stat(n) by(numest_pre5)
tabstat DateFiled, stat(n) by(numest_pre4)
tabstat DateFiled, stat(n) by(numest_pre3)
tabstat DateFiled, stat(n) by(numest_pre2)
tabstat DateFiled, stat(n) by(numest_pre1)
tabstat DateFiled, stat(n) by(numest_bankrupt)
tabstat DateFiled, stat(n) by(numest_post1)
tabstat DateFiled, stat(n) by(numest_post2)
tabstat DateFiled, stat(n) by(numest_post3)
tabstat DateFiled, stat(n) by(numest_post4)
tabstat DateFiled, stat(n) by(numest_post5)

*Determine N at t+2
tabstat Dateconfirmed_year, stat (n) by(Dateconfirmed_year)
tabstat DateFiled if Dateconfirmed_year < 2022, stat(n)

*Determine N at t+3
keep if Public_file == 1
tabstat DateFiled if Dateconfirmed_year < 2021, stat(n)

*Determine N at t+4
tabstat DateFiled if Dateconfirmed_year < 2020, stat(n)

*Determine N at t+5
tabstat DateFiled if Dateconfirmed_year < 2019, stat(n)


*Table 5 Panel B: Debt Analysts
replace danalyst_pre5 = . if Public_file == 0
replace danalyst_pre4 = . if Public_file == 0
replace danalyst_pre3 = . if Public_file == 0
replace danalyst_pre2 = . if Public_file == 0
replace danalyst_pre1 = . if Public_file == 0
replace danalyst_bankrupt = . if Public_file == 0
replace danalyst_post1a = . if Public_file == 0
replace danalyst_post2a = . if Public_file == 0
replace danalyst_post3a = . if Public_file == 0
replace danalyst_post4a = . if Public_file == 0
replace danalyst_post5a = . if Public_file == 0

tabstat DateFiled, stat(n) by(danalyst_pre5)
tabstat DateFiled, stat(n) by(danalyst_pre4)
tabstat DateFiled, stat(n) by(danalyst_pre3)
tabstat DateFiled, stat(n) by(danalyst_pre2)
tabstat DateFiled, stat(n) by(danalyst_pre1)
tabstat DateFiled, stat(n) by(danalyst_bankrupt)
tabstat DateFiled, stat(n) by(danalyst_post1a)
tabstat DateFiled, stat(n) by(danalyst_post2a)
tabstat DateFiled, stat(n) by(danalyst_post3a)
tabstat DateFiled, stat(n) by(danalyst_post4a)
tabstat DateFiled, stat(n) by(danalyst_post5a)


/*************************************************************************
TABLE 6
*************************************************************************/

*Table 6 Panel A: Multivariate Analyses
*(1) Claimant characteristics
reg DI Bond_Note2 UC_Comm Equity_Comm DIP, vce(robust) 
di e(r2_a)

*(2) Case characteristics
reg  DI Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log  Num_Revisions2 Public_file Public_emerge, vce(robust) 
di e(r2_a)

*(3) Debtor characteristics
reg DI  pre_petition_assets_log  Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix, vce(robust)    
di e(r2_a)

*(4) Full Regression (Full sample)
reg DI Bond_Note2 UC_Comm Equity_Comm DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log  Num_Revisions2 Public_file Public_emerge pre_petition_assets_log  Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix, vce(robust)   
di e(r2_a)

*(5) Full Regression (public sample)
reg DI Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_file == 1, vce(robust) 
di e(r2_a)

*(6) Full regression (private sample)
reg DI Bond_Note2 UC_Comm Equity_Comm DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge pre_petition_assets_log Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix if Public_file == 0, vce(robust) 
di e(r2_a)


*Table 6 Panel B: Public Sample - Chapter 11 Disclosure Subindices Multivariate Analyses
* (1) Projection
reg DI_PROJECTION Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_file == 1, vce(robust)
di e(r2_a)

* (2) Valuation
reg DI_VALUATION Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_file == 1, vce(robust)
di e(r2_a)

* (3) Liquidation 
reg DI_LIQUIDATION Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_file == 1, vce(robust)
di e(r2_a)

* (4) Other
reg DI_OTHER Disp_Claims Bond_Note2 UC_Comm Equity_Comm pension DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_file Public_emerge pre_petition_assets_log multinational z_score_qh Proj_Loss_EBITDA New_CEO KEIP_KERP Ind_Std_ROA avg_vix guidance Nonreliability if Public_file == 1, vce(robust)
di e(r2_a)


*Table 6 Panel C: Private Sample - Chapter 11 Disclosure Subindices Multivariate Analyses
* (1) Projection
reg DI_PROJECTION Bond_Note2 UC_Comm Equity_Comm DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_emerge pre_petition_assets_log   Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix if Public_file == 0, vce(robust)
di e(r2_a)

* (2) Valuation
reg DI_VALUATION Bond_Note2 UC_Comm Equity_Comm DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_emerge pre_petition_assets_log   Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix if Public_file == 0, vce(robust)
di e(r2_a)

* (3) Liquidation 
reg DI_LIQUIDATION Bond_Note2 UC_Comm Equity_Comm DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_emerge pre_petition_assets_log   Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix if Public_file == 0, vce(robust)
di e(r2_a)

* (4) Other
reg DI_OTHER Bond_Note2 UC_Comm Equity_Comm DIP Judge District Outside_counsel Restr_adv prepack Days_bankruptcy_log Num_Revisions2 Public_emerge pre_petition_assets_log   Proj_Loss_EBITDA KEIP_KERP Ind_Std_ROA avg_vix if Public_file == 0, vce(robust)
di e(r2_a)


/*************************************************************************
TABLE 7
*************************************************************************/

*TABLE 7 Panel A: Public and Private Firm Descriptive Statistics
* (1) Full Sample
tabstat pre_petition_assets pre_petition_liab Assets_Emerg3 Liab_Emerg3 chapter22 EBITDA_Year1_adj EBITDA_Year2_adj EBITDA_Year3_adj EBITDA_Year4_adj EBITDA_Year5_adj, stat(n mean p50) columns(statistics)

* (2) Public Sample
tabstat pre_petition_assets pre_petition_liab Assets_Emerg3 Liab_Emerg3 chapter22 EBITDA_Year1_adj EBITDA_Year2_adj EBITDA_Year3_adj EBITDA_Year4_adj EBITDA_Year5_adj if Public_file == 1, stat(n mean p50) columns(statistics)

* (3) Private Sample
tabstat pre_petition_assets pre_petition_liab Assets_Emerg3 Liab_Emerg3 chapter22 EBITDA_Year1_adj EBITDA_Year2_adj EBITDA_Year3_adj EBITDA_Year4_adj EBITDA_Year5_adj  if Public_file == 0, stat(n mean p50) columns(statistics)


*TABLE 7 Panel B: Disclosure Quality Index and Subsequent Bankruptcy Filings (Disclosure Index)
* (1) Full Sample
probit chapter22 DI, vce(robust) asis
probit chapter22 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2, vce(robust) asis

* (2) Public Sample
probit chapter22 DI if Public_file == 1, vce(robust) asis
probit chapter22 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2 if Public_file == 1, vce(robust) asis

* (3) Private Sample
probit chapter22 DI if Public_file == 0, vce(robust) asis
probit chapter22 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2 if Public_file == 0, vce(robust) asis


*TABLE 7 Panel B: Disclosure Quality Index and Subsequent Bankruptcy Filings (Disclosure Subindices)
* (1) Full Sample
probit chapter22 DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER, vce(robust) asis
probit chapter22 DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER Assets_Emerg3_log i.date_filed_year i. sich_cat2, vce(robust) asis

* (2) Public Sample
probit chapter22 DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER if Public_file == 1, vce(robust) asis
probit chapter22 DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER Assets_Emerg3_log i.date_filed_year i. sich_cat2 if Public_file == 1, vce(robust) asis

* (3) Private Sample
probit chapter22 DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER if Public_file == 0, vce(robust) asis
probit chapter22 DI_PROJECTION DI_VALUATION DI_LIQUIDATION DI_OTHER Assets_Emerg3_log i.date_filed_year i. sich_cat2 if Public_file == 0, vce(robust) asis


*TABLE 7 Panel C: Disclosure Quality Index and Ex Post Projection Accuracy (1-year Accuracy)
* (1) EBITDA 1-year Accuracy (signed)
reg EBITDA_Acc_1 DI , vce(robust)
di e(r2_a)

* (2) EBITDA 1-year Accuracy (signed) - with controls
reg EBITDA_Acc_1 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2 , vce(robust)
di e(r2_a)

* (3) EBITDA 1-year Accuracy (unsigned)
reg EBITDA_Acc_us_1 DI, vce(robust)
di e(r2_a)

* (4) EBITDA 1-year Accuracy (unsigned) - with controls
reg EBITDA_Acc_us_1 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2 , vce(robust)
di e(r2_a)


*TABLE 7 Panel C: Disclosure Quality Index and Ex Post Projection Accuracy (3-year Accuracy)
* (1) EBITDA 3-year Accuracy (signed)
reg EBITDA_Acc_3 DI, vce(robust)
di e(r2_a)

* (2) EBITDA 3-year Accuracy (signed) - with controls
reg EBITDA_Acc_3 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2 , vce(robust)
di e(r2_a)

* (3) EBITDA 3-year Accuracy (unsigned)
reg EBITDA_Acc_us_3 DI, vce(robust)
di e(r2_a)

* (4) EBITDA 1-year Accuracy (unsigned) - with controls
reg EBITDA_Acc_us_3 DI Assets_Emerg3_log i.date_filed_year i. sich_cat2 , vce(robust)
di e(r2_a)


log close