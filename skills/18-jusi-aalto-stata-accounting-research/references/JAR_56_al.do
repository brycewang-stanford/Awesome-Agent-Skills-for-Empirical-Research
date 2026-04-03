
/*

DESCRIPTION

This file compiles the various scandal datasets from each country, adds country characteristics 
and inflation, computes basic descriptive statistics, and runs the lead-lag regression analyses 
for the media mentions and the panel data.

(identifier keys: country year)

*/

* =============================================================

** SET GLOBAL PARAMETERS

* =============================================================

* assign memory space

clear all
set memory 1000m
set more off
set linesize 150

* =============================================================


* assign workstation

global m1 "actual"

global m2 "  "
global m3 "* "
global m4 "/Users/lhail/Dropbox/Scandal_Regulation/01 Countries - quality assurance/"
cd "/Users/lhail/Desktop/"


* =============================================================


* create log file and output tables

local x = upper(word(c(current_date),1)+word(c(current_date),2)+word(c(current_date),3))

log using "HTW_analyses (`x').log", replace


* =============================================================

** PREPARE INPUT DATA FOR ANALYSES

* =============================================================


* prepare INFLATION and GDP data (temporary dataset)

use "$m4/01 Input_datasets/inflation_gdp.dta", clear

rename gdppc gdp
rename gdppc_est gdp_est

sum gdp infl,d

list country year if (infl>5000&infl!=.) 
replace infl=4738.426 if (infl>5000&infl!=.) /* winsorization: replace one extreme observation */
list country year if (infl<-99)
replace infl=-68 if (infl<-99) /* winsorization: replace one extreme observation */

gen ln_gdp=ln(gdp)
gen ln_infl=ln(69+infl) /* 69 = (abs(minimum value) + 1) */

corrtab gdp ln_gdp infl ln_infl,sig

sort country year
foreach x of varlist gdp gdp_est ln_gdp infl infl_est ln_infl {
	bysort country: gen `x'_l1 = `x'[_n-1] /* lagging */
	}

label var gdp_l1 "GDP per capita, l1"
label var ln_gdp "ln(GDP per capita)"
label var ln_gdp_l1 "ln(GDP per capita), l1"
rename gdp_est_l1 gdp_flag
label var gdp_flag "filled-in indicator, l1"

label var infl_l1 "inflation, l1"
label var ln_infl_l1 "ln(69 + inflation), l1"
rename infl_est_l1 infl_flag
label var infl_flag "filled-in indicator, l1"

drop gdp_est infl ln_infl infl_est

order country year gdp gdp_l1 ln_gdp ln_gdp_l1 gdp_flag infl_l1 ln_infl_l1 infl_flag
sort country year
describe
save "$m4/01 Input_datasets/temp_inflation_gdp.dta", replace


* =============================================================


* prepare REINHART & ROGOFF 2011 data (temporary dataset)

use "$m4/01 Input_datasets/RR_replication.dta", clear

keep country year /* add 5 more years with empty data */
replace year=year+5
drop if year<2011
save "temp.dta", replace

* start with raw data

use "$m4/01 Input_datasets/RR_replication.dta", clear
append using "temp.dta"
erase "temp.dta"
sort country year

drop *_l* *_tlag* *_lag* bc_fc dc_fc fc_fc
drop independence fc ae em dc dc_firstyr

rename currcrisis rr_curr
rename inflcrisis rr_infl
rename mktcrash rr_crash
rename dc_dom rr_domdebt
rename dc_ext rr_extdebt
rename bc rr_bank
rename rrcrisistally rr_crisis_sum
rename bc_firstyr rr_bank_fyr
rename bc_firstyr_close rr_bankclose_fyr
rename dc_dom_firstyr rr_domdebt_fyr
rename dc_dom_firstyr_close rr_domdebtclose_fyr
rename dc_ext_firstyr rr_extdebt_fyr
rename dc_ext_firstyr_close rr_extdebtclose_fyr

* prepare single debt crisis indicator/combined financial crisis indicator

gen rr_debt=max(rr_domdebt, rr_extdebt)
label var rr_debt "sovereign debt crisis (dom & ext)"

gen rr_debt_fyr=max(rr_domdebt_fyr, rr_extdebt_fyr)
label var rr_debt_fyr "first year of crisis"

gen rr_crisis=max(rr_curr, rr_infl, rr_crash, rr_bank, rr_debt)
replace rr_crisis=1 if rr_crisis>1&rr_crisis!=.
label var rr_crisis "financial crisis (bank, crash, curr, debt, infl)"
label var rr_crisis_sum "financial crisis (bank+crash+curr+debt+infl)"

replace rr_curr=1 if rr_curr>1&rr_curr!=. /* make sure crisis variables are binary */

drop rr_crisis_sum rr_domdebt rr_extdebt rr_domdebt_fyr rr_domdebtclose_fyr rr_extdebt_fyr rr_extdebtclose_fyr rr_bankclose_fyr

* fill in years 2011 to 2015 with 0s

foreach x of varlist rr_* {
	replace `x'=0 if (year>2010&year<2016)
	}

* create first year indicators

sort country year

foreach x of varlist rr_crisis rr_crash rr_curr rr_infl {
	bysort country: gen `x'_fyr = 1 if (`x'==1&`x'[_n-1]==0)
	replace `x'_fyr = 0 if (`x'_fyr==.&`x'!=.)
	label var `x'_fyr "first year of crisis"
	tab `x' `x'_fyr,m
	}

* create lagged moving averages

sort country year

foreach x of varlist rr_crisis rr_crisis_fyr rr_bank rr_bank_fyr rr_crash rr_crash_fyr rr_curr rr_curr_fyr rr_debt rr_debt_fyr rr_infl rr_infl_fyr {
	bysort country: gen `x'_l1 = `x'[_n-1] /* lagging */
	bysort country: gen `x'_l2 = `x'[_n-2] 
	bysort country: gen `x'_l3 = `x'[_n-3] 
	replace `x'_l1 = `x' if `x'_l1 == .
	replace `x'_l2 = `x' if `x'_l2 == .
	replace `x'_l3 = `x' if `x'_l3 == .

	gen `x'_lma = (`x'_l1 + `x'_l2 + `x'_l3)/3 /* moving average */
	label var `x'_lma "lagged moving average (3yrs)"
	label var `x'_l1 "lagged 1yr"
	codebook `x'_lma
	drop *_l2 *l3
	}

* prepare for merging

keep country year rr_crisis*

aorder
order country year
sort country year
describe
save "$m4/01 Input_datasets/temp_RR_replication.dta", replace


* =============================================================

** PREPARE SCANDAL DATA FOR ANALYSES

* =============================================================


* compile SCANDAL dataset

use "$m4\02 Countries - done/Austria/scandal_data_Austria.dta", clear

local countries "Australia Belgium Brazil Canada China Denmark Egypt Finland France Germany Greece India Israel Italy Japan Korea Netherlands Poland Portugal South_Africa Spain Sweden Switzerland UK USA" /* completed countries */
foreach x of local countries {	append using "$m4/02 Countries - done/`x'/scandal_data_`x'.dta"
	}

sort country year
duplicates drop country year, force
tab country,m

* label variables

label var scand_tot "total # corporate scandals"
label var scand_acct "# accounting scandals"
label var scand_near "# near accounting scandals"
label var scand_non "# other scandals"

label var regl_tot "total # regulations"
label var regl_acct "# accounting regulations"
label var regl_oth "# other regulations"
label var regl_supra "# supranational regulations"

label var scand_news "# media mentions scandal"
label var regl_news "# media mentions regulator"

replace decade=decade*10
label var decade "decade"
label var country "country"
label var year "year"

* combine different accounting and regulation variables

gen scand_acct_near=scand_acct+scand_near
label var scand_acct_near "# acct & near acct scandals"

gen regl_acct_oth=regl_acct+regl_oth
label var regl_acct_oth "# acct & other regulations"

* check for cases of deregulation

foreach x of varlist regl_acct regl_oth regl_supra regl_tot {	display "`x'"
	list country year `x' if `x'<0
	}

* create binary dummy variables and lagged moving averages

tab country if scand_tot!=.
tab country if scand_news!=.
sort country year

foreach x of varlist regl_acct regl_acct_oth regl_tot scand_acct scand_acct_near scand_tot {
	gen `x'_ind=(`x'>0) if scand_tot!=. /* dummy variable */
	label var `x'_ind "binary indicator"
	}

foreach x of varlist regl_acct regl_acct_oth regl_tot scand_acct scand_acct_near scand_tot regl_acct_ind regl_acct_oth_ind regl_tot_ind scand_acct_ind scand_acct_near_ind scand_tot_ind regl_news scand_news {
	bysort country: gen `x'_l1 = `x'[_n-1] /* lagging */
	bysort country: gen `x'_l2 = `x'[_n-2] 
	bysort country: gen `x'_l3 = `x'[_n-3] 
	bysort country: gen `x'_l4 = `x'[_n-4] 
	bysort country: gen `x'_l5 = `x'[_n-5] 
	replace `x'_l1 = `x' if `x'_l1 == .
	replace `x'_l2 = `x' if `x'_l2 == .
	replace `x'_l3 = `x' if `x'_l3 == .
	replace `x'_l4 = `x' if `x'_l4 == .
	replace `x'_l5 = `x' if `x'_l5 == .

	gen `x'_lma = (`x'_l1 + `x'_l2 + `x'_l3)/3 /* moving average */
	label var `x'_lma "lagged moving average (3yrs)"
	codebook `x'_lma

	gen `x'_lmal1 = (`x'_l2 + `x'_l3 + `x'_l4)/3 /* moving average */
	label var `x'_lmal1 "lagged moving average (3yrs) l2,l3,l4"
	codebook `x'_lmal1

	gen `x'_lmal2 = (`x'_l3 + `x'_l4 + `x'_l5)/3 /* moving average */
	label var `x'_lmal2 "lagged moving average (3yrs) l3,l4,l5"
	codebook `x'_lmal2

	drop *_l1 *_l2 *_l3 *_l4 *_l5
	}

aorder
order country year decade

* drop years with missing data

tab country if scand_news!=.&scand_tot==.

drop if scand_tot==.


* =============================================================


* attach inflation and gdp data

sort country year
merge 1:1 country year using "$m4/01 Input_datasets/temp_inflation_gdp.dta"
erase "$m4/01 Input_datasets/temp_inflation_gdp.dta"
drop if _merge==2
drop _merge

sum gdp_l1,d /* create binary gdp dummy by year */
egen temp_cutoff=median(gdp_l1), by(year)
gen gdp_l1_ind = (gdp_l1>=temp_cutoff)
replace gdp_l1_ind=. if gdp_l1==.
drop temp_cutoff
label var gdp_l1_ind "GDP indicator (by year)"

* attach Reinhart & Rogoff data

sort country year
merge 1:1 country year using "$m4/01 Input_datasets/temp_RR_replication.dta"
erase "$m4/01 Input_datasets/temp_RR_replication.dta"
drop if _merge==2
drop _merge

replace country="KOREA" if country=="KOREA (SOUTH)" /* for alphabetical ordering */
sort country year


* =============================================================

** DESCRIPTIVE STATISTICS

* =============================================================


* Table 3, Panel A: Sample composition by country

egen earliest=min(year), by(country)

table country, c(mean earliest count year)
tabstat scand_acct scand_near scand_non scand_tot regl_acct regl_oth regl_supra regl_tot rr_crisis rr_crisis_fyr, s(sum) by(country)

tabout country using table3.xls, replace ///
c(mean earliest count year sum scand_acct sum scand_near sum scand_non sum scand_tot sum regl_acct sum regl_oth sum regl_supra sum regl_tot sum rr_crisis sum rr_crisis_fyr) ///
f(0 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c) h2(Panel A| | |Corporate Scandals| | | |Accounting Regulation| | | |Financial Crises| |) ///
clab(Earliest_Year Country-Years Accounting Near_Accounting Other Total Accounting Other Supranational Total rr_crisis rr_crisis_fye) ///
sum 

drop earliest

* Table 3, Panel B: Sample composition by year

egen ctry_no=tag(country decade)

table decade, c(sum ctry_no count year)
tabstat scand_acct scand_near scand_non scand_tot regl_acct regl_oth regl_supra regl_tot rr_crisis rr_crisis_fyr, s(sum) by(decade)

tabout decade using table3.xls, append ///
c(sum ctry_no count year sum scand_acct sum scand_near sum scand_non sum scand_tot sum regl_acct sum regl_oth sum regl_supra sum regl_tot sum rr_crisis sum rr_crisis_fyr) ///
f(0 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c) h2(Panel C| | |Corporate Scandals| | | |Accounting Regulation| | | |Financial Crises| |) ///
clab(Number_of_Countries Country-Years Accounting Near_Accounting Other Total Accounting Other Supranational Total rr_crisis rr_crisis_fye) ///
sum 

drop ctry_no


* =============================================================


* Table 4: Descriptive stats for regression variables

set matsize 5000

local x "scand_news regl_news scand_acct_ind scand_acct_near_ind scand_tot_ind regl_acct_ind regl_acct_oth_ind regl_tot_ind ln_gdp_l1 gdp_l1 ln_infl_l1 infl_l1 rr_crisis rr_crisis_fyr"

order `x'

tabstat `x', s(n mean sd p1 p25 median p75 p99) format(%9.3f) col(stat)
quietly: outreg2 `x' using table4_A.xls, replace sum(detail) eqkeep(N mean sd p1 p25 p50 p75 p99)
erase table4_A.txt

* mkcorr `x', log(table4_B.xls) replace num cdec(3) sig

aorder
order country year decade


* =============================================================

** REGRESSION ANALYSES: MEDIA MENTIONS

* =============================================================


* Table 5: Regression analysis - base specification

gen ln_scand_news=ln(scand_news+1)
gen ln_scand_news_lma=ln(scand_news_lma+1)
gen ln_regl_news_lma=ln(regl_news_lma+1)
gen ln_regl_news=ln(regl_news+1)

/* Panel A: media mentions of scandals as dependent variable (log transformed) */

global model "ln_scand_news ln_scand_news_lma ln_regl_news_lma"
global output "table5_A_ln_scand_news"

do "$m4/03 STATA code/01 tab11_regressions.do"

/* Panel B: media mentions of regulator as dependent variable (log transformed) */

global model "ln_regl_news ln_scand_news_lma ln_regl_news_lma"
global output "table5_B_ln_regl_news"

do "$m4/03 STATA code/01 tab11_regressions.do"

drop ln_scand_* ln_regl_*


* =============================================================

** REGRESSION ANALYSES: PANEL DATA

* =============================================================


* Table 6: Regression analysis - base specification

/* Panel A: accounting scandals as dependent variable */

global model "scand_acct_ind scand_acct_ind_lma regl_acct_ind_lma"
global output "table6_A_acct"

do "$m4/03 STATA code/01 tab10_regressions.do"

/* Panel B: accounting regulations as dependent variable */

global model "regl_acct_ind scand_acct_ind_lma regl_acct_ind_lma"
global output "table6_B_acct"

do "$m4/03 STATA code/01 tab10_regressions.do"


* =============================================================


/* Panel A: total corporate scandals as dependent variable */

global model "scand_tot_ind scand_tot_ind_lma regl_tot_ind_lma"
global output "table6_A_tot&supra"

do "$m4/03 STATA code/01 tab10_regressions.do"

/* Panel B: total regulations (including supranational) as dependent variable */

global model "regl_tot_ind scand_tot_ind_lma regl_tot_ind_lma"
global output "table6_B_tot&supra"

do "$m4/03 STATA code/01 tab10_regressions.do"


* =============================================================


log close
set memory 4096M
set matsize 5000

set more off
cd "C:\My_Works\Research_1\CDS_Information_Environment\Data\Results"

set seed 123456
gen u=uniform()
sort u

*Main tests
*Table 2: Main Test
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

* Panel A
xi:reg d_mf1 cds cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)

xi:reg log_num_mf1_w cds cds_traded log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear, cluster(gvkey)

* Panel B
xi: reg d_mf1 cds cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if fyear > 2001, cluster(gvkey)

xi: reg log_num_mf1_w cds cds_traded log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if  fyear > 2001, cluster(gvkey)


*Table 3: Cross-sectional test: ease of hedging by lenderst & Extent of Lender Monitoring
*Panel A: CDS Liquidity & Credit Derivative Protection
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1) CDS Liquidity
xi:reg d_mf1 low_cds_1 high_cds_1  cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_1 = high_cds_1

xi:reg log_num_mf1_w low_cds_1 high_cds_1  cds_traded  log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_1 = high_cds_1

xi:reg d_mf1 low_cds_2 high_cds_2  cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_2 = high_cds_2

*(2) Credit Derivative Protection
xi:reg log_num_mf1_w low_cds_2 high_cds_2  cds_traded  log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_2 = high_cds_2

xi:reg d_mf1 low_rel_cds_protect high_rel_cds_protect cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_rel_cds_protect = high_rel_cds_protect

xi:reg log_num_mf1_w low_rel_cds_protect high_rel_cds_protect cds_traded log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_rel_cds_protect = high_rel_cds_protect

*Panel B: Extent of Lender Monitoring (above/below median)
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1): Bank Allocation
xi:reg d_mf1 cds cds_h2_bksh h2_bksh cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

xi:reg log_num_mf1_w cds cds_h2_bksh h2_bksh cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

*(2): financial covenant
xi:reg d_mf1 cds cds_h2_fincov h2_fincov cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

xi:reg log_num_mf1_w cds cds_h2_fincov h2_fincov cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w i.fyear, cluster(gvkey)

*(3): distress risk
xi:reg d_mf1 cds cds_h2_lag_leverage h2_lag_leverage cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore i.fyear , cluster(gvkey)

xi:reg log_num_mf1_w cds cds_h2_lag_leverage h2_lag_leverage cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore i.fyear  , cluster(gvkey)


*Table 4: Equityholders' Demand above/below median)
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1): strong board: borad independence
xi:reg d_mf1 cds cds_high_bd high_bd cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear , cluster(gvkey)

xi:reg log_num_mf1 cds cds_high_bd high_bd cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear , cluster(gvkey)

*(2)  High Institutions & No blocking holders
xi:reg d_mf1 cds cds_comb_ins_blk_2 comb_ins_blk_2 cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

xi:reg log_num_mf1_w cds cds_comb_ins_blk_2 comb_ins_blk_2 cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w i.fyear, cluster(gvkey)


*Table 5: Interaction of Lender monitoring intensity and shareholder' information demand
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1) high cds liquidity & high institutional ownership (no block) & low lead lenders' share;
xi: reg d_mf1 cds_other_1 cds_low_all_1 cds_high_all_1   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_1_miss == 0, cluster(gvkey)
test cds_high_all_1 = cds_low_all_1

xi:reg log_num_mf1_w  cds_other_1 cds_low_all_1 cds_high_all_1   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_1_miss == 0, cluster(gvkey)
test cds_high_all_1 = cds_low_all_1

*(2) high cds liquidity & high institutional ownership (no block) & low financial covenants;
xi: reg d_mf1 cds_other_2 cds_low_all_2 cds_high_all_2   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_2_miss == 0, cluster(gvkey)
test cds_high_all_2 = cds_low_all_2

xi:reg log_num_mf1_w  cds_other_2 cds_low_all_2 cds_high_all_2   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_2_miss == 0, cluster(gvkey)
test cds_high_all_2 = cds_low_all_2


*Table 6: Endogeneity - 1: PSM for CDS Initiation using 5year period around CDS initation
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_2_ver_2017_11.dta", clear

set seed 123456
gen u=uniform()
sort u

*first stage (
xi: probit cds_initiation pre_rated pre_inv_grade pre_leverage_w pre_profit_margin_w pre_log_ta_w pre_ret_volatility_w pre_mtb_w , cluster(gvkey)
predict pscore if e(sample), pr

egen year_dind = group(year_cds_match)
gen pscore2=year_dind*100+pscore

drop if cds_traded == 1 & cds_year != first_cds_year

table cds_initiation if cds_traded  == 1
table cds_initiation if cds_traded  == 0

sort u

psmatch2 cds_initiation , pscore(pscore2) neighbor(3) 

#d;
keep u pscore pscore2 _pscore _weight _id _n1 _n2 _n3 _nn _pdif 
       cds_initiation gvkey datadate fyear cds cds_year first_cds_year cds_traded cds_first_date year_cds_match
	   pre_rated pre_inv_grade pre_leverage_w pre_profit_margin_w pre_log_ta_w pre_ret_volatility_w pre_mtb_w;
#d cr;

export sasxport "C:\My_Works\Research_1\CDS_Information_Environment\Data\psm_1st.xpt", rename replace vallabfile(none)

*second stage model;
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_3_ver_2017_11.dta", clear
xi:reg log_num_mf1_w psm_cds post psm_cds_post log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w post_fd , cluster(gvkey)


*Table 7: Endogeneity - 2: Change analysis for CDS Initiation;
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_4_ver_2017_11.dta", clear

*Panel A: change test
xi: reg chg_log_num_mf1_w chg_cds chg_log_at_w chg_lag_mtb_w chg_roa_w chg_inst_own_w chg_log_following_w chg_rvol_w chg_eq_iss lit chg_mid_zscore lagchg_leverage_w log_lag_num_mf1_w  i.fyear, cluster(gvkey)

*Panel B: Reverse Casaulity: OLS for cds initaiton 
xi: reg chg_cds pre_chg_log_num_mf1_w log_lag_num_mf1_w chg_log_at_w chg_lag_mtb_w chg_roa_w chg_inst_own_w chg_log_following_w chg_rvol_w chg_eq_iss lit chg_mid_zscore lagchg_leverage_w i.fyear, cluster(gvkey)
* ********************************************************************************
* ********************************************************************************
* Sales Data
* ********************************************************************************
* ********************************************************************************
* author: Kyle Thomas
* reviewed by: Tatiana Sandino and Shelley Li
* date: January 26, 2017
* purpose: take individual store sales data and generate store-brand-week
* ********************************************************************************
* ********************************************************************************
* Inputs: B. Data Preparation\04. Sales Data\input
* Outputs: B. Data Preparation\04. Sales Data\output
* Steps
	* 1. Import and combine data
	* 2. Generate Weekly Measures
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\output"

* ********************************************************************************
* 1. Import and combine data
* ********************************************************************************

* set up local to contain all store abbreviations
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted (local store contains store names)
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* use for loop to import each file
		qui foreach x in `stores'{
			* import
				cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\input"
				import delimited `x'_sales.csv, clear
				cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\output"
			* drop unnecessary data
				cap drop invoiceno
				cap drop itemcolour
				cap drop cc
				cap drop imei
				cap drop imei2mobile
				cap drop isbajaj
				cap drop customername
				cap drop customerphone
				cap drop shopcomments
				cap drop datecreated
			* rename data
				rename salesamtincltax sales_tax_amt
				rename amountexclvat sales_notax_amt
			* convert strings to numbers
				foreach z in sales_tax_amt sales_notax_amt totalprofit{
					replace `z'=subinstr(`z',",","",.)
					destring `z', replace
				}
			* save and clear
				save `x'_sales.dta, replace
				clear
		}
		
	* combine data
		qui foreach x in `stores'{
			append using `x'_sales, force
		}

* ********************************************************************************
* 2. Generate Weekly Measures
* ********************************************************************************

	* total sales for store week; total sales for each brand for each week for each store
	* primary brands and "other brand" category

	* -----------------------------------
	* Create Date
	* -----------------------------------

	* generate unique id for sorting
		gen id = _n

	* format date
		gen x = substr(invoicedatetime,1,10)
		gen x2 = date(x,"MDY")
		format x2 %td
		drop x invoicedatetime
		rename x2 sales_date

	* generate week
		gen week = wofd(sales_date)
		format week %tw

	* rename location to shop
		rename location shop

	* -----------------------------------
	* Flag Brands
	* -----------------------------------

	* fix brand variable
		rename group2 brands
		replace brands = lower(brands)

	* fix brand name related errors
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* flag main brands
		gen main_brands = 0

		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		foreach i in XXX{
			replace main_brands = 1 if brands == "`i'"
		}

	* flag other brands
		gen other_brands = 0
		replace other_brands = 1 if main_brands == 0
		replace brands = "other" if other_brands==1

	* -----------------------------------
	* Related to the brand "Home Credit"
	* -----------------------------------

	* fix variable
		replace homecreditcharges = subinstr(homecreditcharges,",","",.)
		replace homecreditcharges = "0" if homecreditcharges==""
		destring homecreditcharges, replace

	* get shop-week totals
		gen hcsale = sales_tax_amt if ishomecredit=="yes"
		bysort shop week : egen sales_hc = total(hcsale)
		gen profit_hc = 0

	* -----------------------------------
	* Generate Sales for Each Brand
	* -----------------------------------

	* generate sales for each main brand
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted: brand names removed
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		foreach i in XXX{

			* initiate blank sales vars
			gen totalprofit_`i' = 0
			gen sales_tax_amt_`i' = 0

			* replace blanks with values
			replace totalprofit_`i' = totalprofit if brands == "`i'"
			replace sales_tax_amt_`i' = sales_tax_amt if brands == "`i'"

			*create weekly sales
			bysort shop week : egen profit_`i' = total(totalprofit_`i')
			bysort shop week : egen sales_`i' = total(sales_tax_amt_`i')

			*drop individual sales
			drop totalprofit_`i'
			drop sales_tax_amt_`i'

		}	

	* -----------------------------------
	* Create Total Sales for Store-Week (no home credit numbers are included)
	* -----------------------------------

	bysort shop week : egen profit_all = total(totalprofit)
	bysort shop week : egen sales_all = total(sales_tax_amt)

	* -----------------------------------
	* Number of Sales-Days for Store-Week
	* -----------------------------------

	bysort shop week : egen days = nvals(sales_date)

	* -----------------------------------
	* clean data
	* -----------------------------------
		duplicates drop shop week, force
		drop group1 brands itemname incentive totalprofit homecreditcharges sales_tax_amt budgetused sales_notax_amt taxrate vatamt discount profit salesamtdifference normaldpinclvat finalnetdpinclvat id sales_date main_brands other_brands

	* -----------------------------------
	* create sales and profit
	* -----------------------------------
	
		gen id = _n
		reshape long sales profit, i(id) j(brand) string
		replace brand = subinstr(brand,"_","",.)
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		rename sales sales_tax
		drop id
		
	* save sales data
		save "T:\Data Prep and Analyses\C. Master Dataset\input\store_week_brand_sales", replace

***************************************************************************************
	* end log
		log close

 



	***************************************************************************************
	*****Purpose: Generate Analyses Tables Listed in the Original Proposal *******
	*****Created by: Shelley Li
	*****Date: Feb 14, 2017
	*****Modifications by: Tatiana Sandino
	*****Date: Mar 19, 2017
	*****      Sept 13, 2017- Verified if we had more than one poster per shop-brand-month
	*****                     in the creativity regressions
	***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\D. Analyses\02. Main Analysis\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text
		
	* change into working directory
		cd "T:\Data Prep and Analyses\D. Analyses\02. Main Analysis\output"

	set more off
	
	*Choose tenure from the choices: tenure_survey tenure_bg_period tenure_bg_brand 
	local tenure="tenure_survey"

	*Choose gender from the choices: gender gender_fmissing gender_fmissing_brand
	local gender="gender"
	
	*Choose whether to exclude november or not: 
		*to exclude it choose exclnov="if nov==0" and exclnovinlist= "if nov==0 &"
		*to NOT exclude it choose exclnov="" and exclnovinlist= "if"
	local exclnov="if nov==0"
	local exclnovinlist= "if nov==0 &"
	
	****************************************************************************************
	******ANALYSES THAT USE THE MASTER SALES-ATTENDANCE DATASET store_data.dta**************
	******i.e. TABLES 1, 3, 6, 7, 10, TABLE 5 COLUMNS 1&2************************************
	****************************************************************************************
	
	* load the master file for sales-attendance-store characteristics
	use "T:\Data Prep and Analyses\C. Master Dataset\output\store_data.dta", clear
	
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_activeaccessfreq.dta"
	drop if _m==2
	drop _m
	
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_accessfreq.dta"
	drop if _m==2
	drop _m
	
	gen engagement= engagement1+engagement4+engagement2+engagement3
	gen quality= quality1+quality2+quality3
	
	
	*Keep the sales-analysis sample the same as the attendance-analysis sample
	keep if mattendance!=.
	
	qui: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	keep if e(sample)
	
	estpost sum lsales attendance tr post n_promoters sqft store_age days close_stores hodist tenure_survey gender lmsales mattendance accessfreq_active
	esttab,replace label cells("count mean sd min max")
	
	pwcorr lsales attendance tr post n_promoters sqft store_age days close_stores hodist tenure_survey gender lmsales mattendance accessfreq_active, sig
	
	
	*get descriptive stats for accessfreq
	summarize accessfreq accessfreq_active, detail
	tabulate accessfreq 
	
	pwcorr accessfreq accessfreq_active sales_tax attendance engagement quality, sig
	
	*--------------------------------------------------------------------------
	*Descriptive Statistics of Main Financial/Attendance Variables- Spot Errors
	*(NEW TATIANA CHANGES)
	*--------------------------------------------------------------------------
	*Summarize DV
	summarize sales_tax lsales attendance attendanceUC motivation ability, detail
	histogram lsales
	set more off
	graph save Graph "Histogram LnSales (Excludes sales less than or equal to 0).gph", replace
	histogram attendance
	set more off
	graph save Graph "Histogram Attendance (Setting attendance greater than 7 to 7).gph", replace
	histogram attendanceUC
	graph save Graph "Histogram Attendance Unconstrained.gph", replace


	* sales have been already restricted to be > 0 in "merge.do"
	
	*Summarize EV
	summarize n_promoters sqft store_age days close_stores hodist tenure_survey tenure_bestguess tenure_bg_period tenure_bg_brand gender gender_fmissing_brand gender_fmissing TL_changed lmsales mattendance age edu renovation monthbeforeclosing close_stores, detail
	tabulate market, missing
	
	***RED FLAGS AND RESOLUTIONS: 
	*n_promoters: large numbers, going up to 19- these had to be trainings, not promoters working at the stores
		*this was fixed to exclude promoters that showed up at a store that was not their home store
		*see explanations on attendance.do
	*days: we have some sales days equal to 9- weeks cannot have more than 7 days
		*clarified by Shelley and Kyle, this is just based on Stata convention (accomodating the last week of the year)
		*we cap days at 7 in the program merge.do
	*attendance: we had some attending more than 7 days a week. This is partly 		
		* but not entirely explained by the week 52 defined by Stata
		* We cap attendance at 7 in program merge.do
	*sqft: one of the stores appeared to be 15525 sqft big
		*there was a typo with DGJF which should have read 155.25 
		*this was fixed on the excel spreadsheet used as input
				
	label var `tenure' "Tenure" 
	label var `gender' "Gender"

	*----------------------------------------------
	*Table 1 - Financial Performance and Engagement
	*----------------------------------------------
	
	eststo clear
	
	*Financial performance
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	*Attendance
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)
		
	*show formatted table results directly in the command window
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	*export formatted table results into a csv file that can be opened and editted in Excel
	esttab using table1_sales-attendance.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")
    eststo clear

	*--------------------------------------------------------------------------------------
	*Table 2 - Financial Performance and Attendance: Split by Post_Early & Post_Late
	*--------------------------------------------------------------------------------------

	gen Post_Early=1 if week>=tw(2016w36) & week<=tw(2016w44)
	replace Post_Early=0 if Post_Early==.
	gen Post_Late=1 if week>=tw(2016w45) 
	replace Post_Late=0 if Post_Late==.
	gen trxPost_Early=tr*Post_Early
	gen trxPost_Late=tr*Post_Late

	eststo clear

	*Excluding Nov
	qui: eststo: xi: reg lsales tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)

	esttab, replace b(4) r2 label ///
    keep(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table2_EarlyLate.csv, replace b(4) r2 label ///
    keep(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

    eststo clear	
set more off
	*-------------------------------------------------------------------------------------------------
	*Table 3 (Prev Table 9) - Financial Performance and Attendance: Contingent on Frequency of Access
	*--------------------------------------------------------------------------------------------------
	**Proposed Analysis
	replace accessfreq=0 if tr==0
	replace accessfreq_active=0 if tr==0 
	replace accessfreq=0 if tr==1 & post==0
	replace accessfreq_active=0 if tr==1 & post==0
	
	gen trxpostxaccessfreq=tr*post*accessfreq
	gen trxpostxactiveaccess=tr*post*accessfreq_active
	
	label var trxpostxaccessfreq "Info Sharing x Access to System x Post"
	label var trxpostxactiveaccess "Info Sharing x Active Access to System x Post"

	summarize accessfreq_active if(tr==1 & post==1 & lsales!=. & n_promoters!=.	& sqft!=. & store_age!=. & days!=. & close_stores!=. & hodist!=. & `tenure'!=. & `gender'!=.), detail 
		*Shows what stats I can save
		return list	
		gen mean_activeaccess=r(mean)
		gen med_activeaccess=r(p50)
		gen topQ_activeaccess=r(p75)
	
	bysort shop: egen shop_activeaccess=max(accessfreq_active)
	
	gen trHIaccess=(tr==1 & shop_activeaccess>med_activeaccess)
	gen trLOaccess=(tr==1 & shop_activeaccess<=med_activeaccess)
	gen trHIaccessxpost=trHIaccess*post
	gen trLOaccessxpost=trLOaccess*post
	
	label var trHIaccess "High Access"
	label var trLOaccess "Low Access"
	label var trHIaccessxpost "High Access x Post"
	label var trLOaccessxpost "Low Access x Post"
	
	eststo clear
	*qui: eststo: xi: reg lsales tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	*qui: eststo: xi: tobit attendance tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table3_prev9_access_fin-att.csv, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")
	
	**Fixed effects

	eststo clear
	qui: eststo: xi: reg lsales post trxpost trxpostxactiveaccess i.shop i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance post trxpost trxpostxactiveaccess i.shop i.brand `exclnov', vce (cluster shop) ul(7)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost trxpostxactiveaccess) ///
    order(post trxpost trxpostxactiveaccess) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table3__FEaccess_fin-att.csv, replace b(4) r2 label ///
    keep(post trxpost trxpostxactiveaccess) ///
    order(post trxpost trxpostxactiveaccess) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	eststo clear
	
	**Include in a single analysis above and below or equal to median 
	qui: eststo: xi: reg lsales trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)

	esttab, replace b(4) r2 label ///
    keep(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table3_prev9_hiaccess_fin-att.csv, replace b(4) r2 label ///
    keep(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

    eststo clear	
	
	*---------------------------------------------------------------------------------
	*Table 4 (Prev Table 10)- Financial Performance: Robustness Check with Store Fixed Effects
	*---------------------------------------------------------------------------------
	
	**NOTE THAT N_PROMOTER ENDS UP NOT BEING ESTIMATED IN THESE REGRESISONS
	**SUGGESTING THAT THE FEW VARIATIONS IN THIS VARIBLE ARE PERHAPS ENTIRELY CONTROLLED VIA BRAND AND SHOP FIXED EFFECS
	
		
	eststo clear

	qui: eststo: xi: reg lsales post trxpost i.brand i.shop `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance post trxpost i.brand i.shop `exclnov', vce (cluster shop) ul(7)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost ) ///
    order(post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table4_prev10_storeFE_exclcontrols.csv, replace b(4) r2 label ///
    keep(post trxpost ) ///
    order(post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")
	
	eststo clear
	*------------------------------------------------------------------
	*Table 5 (Prev Table 6-8) - Financial Performance: Subsample Analysis
	*------------------------------------------------------------------
	
	**the median number of closeby stores is 2 - SEE the store characteristics data and do files
	**Use the main specification - i.e. excluding the November data
	
	
	sort shop brand
	merge m:1 shop brand using "T:\Data Prep and Analyses\C. Master Dataset\output\poster_preindicator.dta"
	drop if _m==2
	drop _m
	
		
	eststo clear
	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' close_stores<=2, vce (cluster shop)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' market=="divergent", vce (cluster shop)

	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	esttab using table5_fin_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	eststo clear

	
	*FIXED EFFECTS VERSION
	eststo clear
	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' close_stores<=2, vce (cluster shop)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' market=="divergent", vce (cluster shop)

	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	esttab using table5_FEfin_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	eststo clear
	
	*------------------------------------------------------------------
	* Table 8 (Similar to Previous Table 6-8) - Attendance: Subsample Analysis
	*------------------------------------------------------------------
	
	*Exploratory analyses>> do this partition using attendance
	eststo clear

	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' close_stores>2, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' close_stores<=2, vce (cluster shop) ul(7)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop) ul(7)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' market=="mainstream", vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' market=="divergent", vce (cluster shop) ul(7)

	*show formatted table results directly in the command window
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")
	
	esttab using table8_attend_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "LowCreativeTalent" "Mainstream" "Divergent")

	eststo clear
	
	
	*FIXED EFFECTS VERSION
	eststo clear

	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' close_stores>2, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' close_stores<=2, vce (cluster shop) ul(7)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop) ul(7)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' market=="mainstream", vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' market=="divergent", vce (cluster shop) ul(7)

	*show formatted table results directly in the command window
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")
	
	esttab using table8_FEattend_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "LowCreativeTalent" "Mainstream" "Divergent")

	eststo clear
	
	****************************************************************************************
	******ANALYSES THAT USE THE POSTER VARIABLES AS DVs "PosterData_DV.dta"****************
	******i.e. TABLES 2 & 5 COLUMNS 3&4 ****************************************************
	****************************************************************************************
	
	*--------------------------------------------
	*Table 1 - Quality of Creative Work
	*--------------------------------------------
	
	*load the poster data as DV dataset
	use "T:\Data Prep and Analyses\C. Master Dataset\output\PosterData_DV.dta", clear	
		*TATIANA: THIS DATASET COMES FROM 03. Prepare Poster Datasets.do 
		*		  AND ADDS STORE MEASURES TO THE POSTER RATINGS, USING 
		*		  AVERAGES BASED ON THE 4 WEEKS SURROUNDING THE POSTER
		*		  COLLECTION.	
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_activeaccessfreq.dta"
	drop if _m==2
	drop _m
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_accessfreq.dta"
	drop if _m==2
	drop _m
				
	*local tenure="tenure_survey"
	*local gender="gender"

	gen engagement= engagement1+engagement4+engagement2+engagement3
	gen quality= quality1+quality2+quality3
	
	pwcorr accessfreq accessfreq_active engagement quality Useful_rating_bucket Attractive_rating_bucket, sig
	**as you can see, access frequency is positively and significantly correlated with survey_based engagement measures, with survey-based quality measures, 
	**and with poster quality measures from customer panels.
	**survey-based engagement measure is also positively and significantly correlated with poster quality measures
	
	bysort Poster_month tr: sum Useful_rating_bucket
	bysort Poster_month tr:sum Attractive_rating_bucket
	**not so much for the novelty measure
	
	bysort Poster_month: egen ave_value=mean(Useful_rating_bucket)
	bysort Poster_month: egen ave_novelty=mean(Attractive_rating_bucket)
	bysort Poster_month: egen sd_value=sd(Useful_rating_bucket)
	bysort Poster_month: egen sd_novelty=sd(Attractive_rating_bucket)
	gen value_fromMean=abs(Useful_rating_bucket-ave_value)
	gen value_SDfromMean=abs(Useful_rating_bucket-ave_value)/sd_value
	gen novelty_fromMean=abs(Attractive_rating_bucket-ave_novelty)
	gen novelty_SDfromMean=abs(Attractive_rating_bucket-ave_novelty)/sd_novelty
			
	*--------------------------------------
	*Analyses using the AVERAGE measures
	*--------------------------------------
	
	**generate pre-period average novelty and value data
	sort shop brand post
	by shop brand post: egen mAttractive=mean(Attractive_rating_bucket)
	by shop brand post: egen mAttractiveNorm=mean(Attractive_rating_normalized)
	by shop brand post: egen mUseful=mean(Useful_rating_bucket)
	by shop brand post: egen mUsefulNorm=mean(Useful_rating_normalized)
	
	by shop brand: gen pre_Attractive=mAttractive[1]
	by shop brand: gen pre_AttractiveNorm=mAttractiveNorm[1]
	by shop brand: gen pre_Useful=mUseful[1]
	by shop brand: gen pre_UsefulNorm=mUsefulNorm[1]
	
	**label vars
	label var pre_Attractive "Pre-Intervention Novelty of Creative Work"
	label var pre_Useful "Pre-Intervention Value of Creative Work"
	label var Poster_clear "Poster Image is Clear"
	label var Poster_multiple "Containing Multiple Poster Images"
	label var Useful_pctraters_langmiss "Value_Language Mismatch"
	label var Attractive_pctraters_langmiss "Novelty_Language Mismatch"
	
	
	qui: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist tenure_survey gender pre_Useful i.brand, vce (cluster shop)
	keep if e(sample)
	
	sum Useful_rating_bucket Attractive_rating_bucket pre_Useful pre_Attractive
	
	pwcorr Useful_rating_bucket Attractive_rating_bucket tr post n_promoters sqft store_age days close_stores hodist tenure_survey gender pre_Useful pre_Attractive accessfreq_active, sig

		
	*-------------------------------	
	* Table 1- Creativity Measures
	*-------------------------------
		
	eststo clear
	
	**Specified as proposed 
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	
	esttab using table1_poster.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	
	eststo clear
		
		*Check whether there is more than one poster per shop-brand-month in these regressions
		xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce(cluster shop)
		predict attres, residual
		gen attresdummy=(attres!=.)
		bysort Poster_month shop brand attresdummy: gen poscount=_n
		count if poscount==1 & attresdummy==1
		count if poscount==2 & attresdummy==1
		count if poscount==3 & attresdummy==1
		count if poscount==4 & attresdummy==1
		count if poscount==5 & attresdummy==1 
		br Poster_month shop brand poscount attres Attractive_rating_bucket Useful_rating_bucket
		*ANSWER: YES, 64 observations correspond to cases where there was more than one poster per shop-brand-month;*/
	
	*-----------------------------------------------------------------
	* Table 3- Exploratory similar to Table 9: Contingent on Frequency of Access
	*-----------------------------------------------------------------
	**Proposed Analysis
	replace accessfreq=0 if tr==0
	replace accessfreq_active=0 if tr==0 
	replace accessfreq=0 if tr==1 & post==0
	replace accessfreq_active=0 if tr==1 & post==0
	
	gen trxpostxaccessfreq=tr*post*accessfreq
	gen trxpostxactiveaccess=tr*post*accessfreq_active
	
	label var trxpostxaccessfreq "Info Sharing x Access x Post"
	label var trxpostxactiveaccess "Info Sharing x Active Access x Post"

	summarize accessfreq_active if(tr==1 & post==1 & Useful_rating_bucket!=. & n_promoters!=. & sqft!=. & store_age!=. & days!=. & close_stores!=. & hodist!=. & `tenure'!=. & `gender'!=.), detail 
		*Shows what stats I can save
		return list	
		gen mean_activeaccess=r(mean)
		gen med_activeaccess=r(p50)
		gen topQ_activeaccess=r(p75)
	
	bysort shop: egen shop_activeaccess=max(accessfreq_active)

	gen trHIaccess=(tr==1 & shop_activeaccess>med_activeaccess)
	gen trLOaccess=(tr==1 & shop_activeaccess<=med_activeaccess)
	gen trHIaccessxpost=trHIaccess*post
	gen trLOaccessxpost=trLOaccess*post
	
	label var trHIaccess "High Access"
	label var trLOaccess "Low Access"
	label var trHIaccessxpost "High Access x Post"
	label var trLOaccessxpost "Low Access x Post"

	*Quality of creative work-

	eststo clear
	*qui: eststo: xi: reg Useful_rating_bucket tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	*qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop) 
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop) 

	esttab, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table3_prev9_creative.csv, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	eststo clear

	*Fixed Effects- Quality of creative work-

	eststo clear
	qui: eststo: xi: reg Useful_rating_bucket post trxpost trxpostxactiveaccess  i.shop i.brand, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket post trxpost trxpostxactiveaccess  i.shop i.brand, vce (cluster shop) 

	esttab, replace b(4) r2 label ///
    keep(post trxpost trxpostxaccessfreq trxpostxactiveaccess ) ///
    order(post trxpost trxpostxaccessfreq trxpostxactiveaccess ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table3_FEaccess_creative.csv, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess ) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	eststo clear
		
 	**Include a single analysis above and below or equal to the top quartile

	eststo clear
	
	qui: eststo: xi: reg Useful_rating_bucket trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Useful" "Attractive")

	esttab using table3_freqaccess_creative.csv, replace b(4) r2 label ///
    keep(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Useful" "Attractive")

	eststo clear

	*------------------------------------------------------------
	* Table 4-Exploratory analyses similar to Table 10
	*------------------------------------------------------------
	eststo clear

	*Shop and brand fixed effects
	*Including controls
	qui: eststo: xi: reg Useful_rating_bucket post trxpost n_promoters days `tenure' `gender' i.brand i.shop, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket post trxpost n_promoters days `tenure' `gender' i.brand i.shop, vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost n_promoters days `tenure' `gender') ///
    order(post trxpost n_promoters days `tenure' `gender') nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table4_storeFE_creative.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters days `tenure' `gender') ///
    order(tr post trxpost n_promoters days `tenure' `gender') nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	eststo clear

	*Shop and brand fixed effects
	*Excluding controls
	qui: eststo: xi: reg Useful_rating_bucket post trxpost i.brand i.shop if n_promoters!=. & days!=. & `tenure'!=. & `gender'!=., vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket post trxpost i.brand i.shop if n_promoters!=. & days!=. & `tenure'!=. & `gender'!=., vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost ) ///
    order(post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table4_storeFE_creative_exclcontrols.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	eststo clear
		
	*------------------------------------------------------------------
	* Exploratory similar to Table 6-8 - Subsamples
	*------------------------------------------------------------------
	**the median number of closeby stores is 2 - SEE the store characteristics data and do files
	**Use the main specification - i.e. excluding the November data
	
	sort shop brand
	merge m:1 shop brand using "T:\Data Prep and Analyses\C. Master Dataset\output\poster_preindicator.dta"
	drop if _m==2
	drop _m

	eststo clear
	
	**Useful- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if close_stores<=2, vce (cluster shop)
	**Useful- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if amquality_rating==0, vce (cluster shop) 
	*Useful- Mainstream vs Divergent
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if market=="divergent", vce (cluster shop)
		
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' gender pre_Useful) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table6_useful_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear
	
	**Attractive- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if close_stores<=2, vce (cluster shop)
	**Attractive- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if amquality_rating==0, vce (cluster shop) 
	*Attractive- Mainstream vs Divergent
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if market=="divergent", vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table7_attractive_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear
		
	*FIXED EFFECTS VERSIONS
	
	eststo clear
	
	**Useful- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if close_stores<=2, vce (cluster shop)
	**Useful- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==0, vce (cluster shop) 
	*Useful- Mainstream vs Divergent
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost  i.shop i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost  i.shop i.brand if market=="divergent", vce (cluster shop)
		
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' gender ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table6_FEuseful_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear
	
	**Attractive- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if close_stores<=2, vce (cluster shop)
	**Attractive- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==0, vce (cluster shop) 
	*Attractive- Mainstream vs Divergent
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost  i.shop i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost  i.shop i.brand if market=="divergent", vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table7_FEattractive_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear


	
	***************************************************************************************
	* end log
		log close

	
	
