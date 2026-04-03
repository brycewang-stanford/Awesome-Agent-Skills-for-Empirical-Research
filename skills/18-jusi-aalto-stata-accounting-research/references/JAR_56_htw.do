
* =============================================================

** TABLE 10: base specification

* =============================================================


set more off
xi i.country i.year /* create fixed effects */

logit $model _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, replace tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)

logit $model ln_gdp_l1 ln_infl_l1 _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)

logit $model rr_crisis_fyr_lma ln_gdp_l1 ln_infl_l1 _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)

logit $model rr_crisis_fyr_lma ln_gdp_l1 ln_infl_l1 _Icountry* _Iyear*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry* _Iyear*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, Yes, Cluster, Country)


logit $model ln_gdp_l1 ln_infl_l1 _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)

logit $model ln_gdp_l1 ln_infl_l1 _Icountry* if year<1946, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-1945") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)

logit $model ln_gdp_l1 ln_infl_l1 _Icountry* if year>1945, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1946-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)

logit $model ln_gdp_l1 ln_infl_l1 _Icountry* if year>1969, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1970-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Pseudo R-squared, `e(r2_p)') addtext(Country FE, Yes, Year FE, No, Cluster, Country)


erase $output.txt
drop _Icountry* _Iyear*


* =============================================================


* =============================================================

** TABLE 10: base specification

* =============================================================


set more off
xi i.country i.year /* create fixed effects */

reg $model _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, replace tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)

reg $model ln_gdp_l1 ln_infl_l1 _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)

reg $model rr_crisis_fyr_lma ln_gdp_l1 ln_infl_l1 _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)

reg $model rr_crisis_fyr_lma ln_gdp_l1 ln_infl_l1 _Icountry* _Iyear*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry* _Iyear*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, Yes, Cluster, Country)


reg $model ln_gdp_l1 ln_infl_l1 _Icountry*, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)

reg $model ln_gdp_l1 ln_infl_l1 _Icountry* if year<1946, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1800-1945") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)

reg $model ln_gdp_l1 ln_infl_l1 _Icountry* if year>1945, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1946-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)

reg $model ln_gdp_l1 ln_infl_l1 _Icountry* if year>1969, vce(cluster country) noemptycells
outreg2 using $output.xls, append tstat ctitle("1970-2015") bdec(3) tdec(2) rdec(4) drop(_Icountry*) addstat(Adjusted R-squared, e(r2_a)) addtext(Country FE, Yes, Year FE, No, Cluster, Country)


erase $output.txt
drop _Icountry* _Iyear*


* =============================================================


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
