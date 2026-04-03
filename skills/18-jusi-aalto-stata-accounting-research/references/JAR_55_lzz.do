/* This program generates the main dependent variables used in Ljungqvist, Zhang and Zuo (2017) */

set more off

use fundq, clear /*  This dataset is directly downloaded from Compustat Fundamentals Quarterly */
drop if atq ==.
drop if atq<=0
drop if ceqq==.
drop if (oiadpq==. & oibdpq==. & oancfy==.)

count
gsort gvkey fyearq fqtr -atq
by gvkey fyearq fqtr: keep if _n==1

replace pstkq=0 if pstkq==.
replace dlcq = 0 if dlcq ==.
replace dlttq = 0 if dlttq ==.
replace mibtq =0 if mibtq ==.

gen noaq = ceqq + pstkq + dlttq + dlcq + mibtq
gen rnoaq = oiadpq/noaq
replace rnoaq =. if noaq <0

gen roaq = oiadpq/atq

capture program drop clean
program define clean
sort fyear
by fyear: egen p99 = pctile (`1'), p(99) 
by fyear: egen p1 = pctile (`1'), p(1) 
replace `1'=p99 if `1'>p99&`1'~=.
replace `1'=p1 if `1'<p1&`1'~=.
drop p99 p1
end

clean rnoaq
clean roaq

sort gvkey fyearq fqtr

by gvkey: gen lag4_fyearq = fyearq[_n-4]
gen diff4_fyearq = fyearq - lag4_fyearq

local vol "rnoaq roaq" 
foreach x of local vol {
	sort gvkey fyearq fqtr
	by gvkey: gen lag4_`x' = `x'[_n-4]
	replace lag4_`x'=. if diff4_fyearq > 1
	gen adj_`x' = `x' - lag4_`x'
	by gvkey: gen `x'_1 = adj_`x'[_n+1]
	by gvkey: gen `x'_2 = adj_`x'[_n+2]
	by gvkey: gen `x'_3 = adj_`x'[_n+3]
	by gvkey: gen `x'_4 = adj_`x'[_n+4]
	by gvkey: gen `x'_5 = adj_`x'[_n+5]
	by gvkey: gen `x'_6 = adj_`x'[_n+6]
	by gvkey: gen `x'_7 = adj_`x'[_n+7]
	by gvkey: gen `x'_8 = adj_`x'[_n+8]
	by gvkey: gen `x'_9 = adj_`x'[_n+9]
	by gvkey: gen `x'_10 = adj_`x'[_n+10]
	by gvkey: gen `x'_11 = adj_`x'[_n+11]
	egen std_`x' = rowsd(`x' `x'_1 `x'_2 `x'_3 `x'_4 `x'_5 `x'_6 `x'_7 `x'_8 `x'_9 `x'_10 `x'_11)
	egen std_`x'_n = rownonmiss(`x' `x'_1 `x'_2 `x'_3 `x'_4 `x'_5 `x'_6 `x'_7 `x'_8 `x'_9 `x'_10 `x'_11) 
	}

sort gvkey fyearq fqtr
by gvkey fyearq: keep if _n==1
count
sum std_*

/* We restrict to n>=4 quarters in the regression */
replace std_roaq =. if std_roaq_n < 4
replace std_rnoaq =. if std_rnoaq_n < 4

keep gvkey fyearq std_*
rename fyearq fyear
destring gvkey, force replace
save fundq_vol, replace
/* This program generates the dataset used in Ljungqvist, Zhang and Zuo (2017) */

set more off
use funda, clear /* This dataset is directly downloaded from Compustat Fundamentals Annual*/

/* Because of leads/lags needed, we do not restrict to 1989-2011 here */
drop if fyear < 1986
drop if fyear > 2013
format datadate %d

/* Initial screening */
des indfmt consol popsrc datafmt
keep if indfmt=="INDL"
keep if consol=="C"
keep if popsrc=="D"
keep if datafmt=="STD        "

/* Retain only US firms */
keep if curcd=="USD"
keep if curncd=="USD"
keep if fic=="USA"

/* Industry screening */
gen sic1= int(sich/1000)
gen sic2=int(sich/100)
drop if sic1==6
drop if sic2==49
drop if sic1==9

/* Additional screening */
drop if at==.
drop if at <=0
sort gvkey fyear
by gvkey fyear: keep if _n==1

/* Generate basic variables */
gen mkv=abs(prcc_f)*csho
gen ltbook_lev=dltt/at
gen mb=mkv/ceq
replace mb =. if ceq <0
replace mb=log(mb)

replace xrd=0 if xrd==.
replace sppe =0 if sppe==.
replace dpc=0 if dpc==.

gen capex=(capx-sppe)/at
gen rnd=xrd/at
gen cash=che/at
gen sur_cash=(oancf-dpc+xrd)/at
gen nol=1 if (tlcf > 0 & tlcf~=.)
replace nol=0 if nol==.

keep gvkey fyear fyr datadate cik at ltbook_lev mb sich sale capex rnd cash sur_cash nol tlcf pi  

gen year=year(datadate)
merge m:1 year using gdplev_annual /*gdplev_annual is the dataset containing the GDP deflator, available at http://www.bea.gov/national/xls/gdplev.xls */
drop if _merge==2
drop _merge

gen at09=at*ratio
gen lnat09=log(at09)
gen sale09=sale*ratio

destring gvkey, force replace
tsset gvkey fyear
gen lagsale09=l1.sale09
gen sgrowth=log(sale09/lagsale09)

merge m:1 gvkey using company /* company is the dataset containing the variable (headquarter) "state", directly downloaded from Compustat */
drop if _merge==2
drop _merge

merge 1:1 gvkey fyear using crsp_data_05012015 /* This dataset contains stock return data, computed using the SAS code "LZZ code stock return" */
drop if _merge==2
drop _merge

merge 1:1 gvkey fyear using fundq_vol /* fundq_vol contains vol. measures based on quarterly data, computed using the Stata code "LZZ code volatility" */
drop if _merge==2
drop _merge

merge m:1 gvkey using compustat_start /* Starting year in compustat for each firm */
drop if _merge==2
drop _merge

gen age=fyear - fyear_start + 1
replace age=log(age)

do "HQ corrections 1989-2011 (c) Alexander Ljungqvist, 2013" /*This do-file corrects Compustat's backfilled HQ states to actual historic HQ states for the period 1989-2011. Please contact Alexander Ljungqvist for access to this do-file */

do "Code tax changes - clean" /*This do-file codes which firms are affected by tax changes when. This do-file is based on manually collected data described in the paper and listed in Table A.1 of the Online Appendix */

merge m:1 state year using GDP_growth_rate /*GSP growth rate is the real annual growth rate in gross state product (GSP) using data obtained from the U.S. Bureau of Economic Analysis */
drop if _merge==2
drop _merge

merge m:1 state year using State_unemployment_rate_annual /*State unemployment rate is the state unemployment rate, obtained from the U.S. Bureau of Labor Statistics */
drop if _merge==2
drop _merge
rename value suer

drop if (state=="AB" | state=="BC" | state=="MB"| state=="NB"| state=="NF"| state=="NS"| state=="ON"| state=="PR"| state=="QC"| state=="SK"| state=="VI") /*removing non-US statas*/

tsset gvkey fyear
egen i_t=group(sich fyear)

tab state, gen(st)

*** Dependent variables

replace std_roaq=log(std_roaq)
replace std_rnoaq=log(std_rnoaq)

*** NETS weighted tax changes
di _N
sort gvkey datadate
merge gvkey datadate using "NETS weighted tax changes.dta",nokeep
/* We match Compustat firms by name to the National Establishment Time Series (NETS) database, which contains a comprehensive record of all business establishments in the U.S. since 1989 */
tab _m
replace wtaxchangeup_all=taxchangeup if _m==1 
replace wtaxchangedown_all=taxchangedown if _m==1 
drop _m

/* absoluate magnitude */
replace taxchangedown=abs(taxchangedown)
replace wtaxchangedown_all=abs(wtaxchangedown_all)
replace wtaxchangeup_all=. if taxchangeup==.
replace wtaxchangedown_all=. if taxchangedown==.

tsset gvkey fyear

global Xvars="age lnat09 mb ltbook_lev sur_cash nol sgrowth RET_12"
global Xvars_state=" gdpgr suer"

/* Winsorize */

capture program drop clean
program define clean
sort fyear
by fyear: egen p99 = pctile (`1'), p(99) 
by fyear: egen p1 = pctile (`1'), p(1) 
replace `1'=p99 if `1'>p99&`1'~=.
replace `1'=p1 if `1'<p1&`1'~=.
drop p99 p1
end

local clean_var "std_roaq std_rnoaq $Xvars $Xvars_state"

foreach x of local clean_var {
	clean `x'
}


tsset gvkey fyear

local diff_var "std_roaq std_rnoaq"

/*std_var was generated using three-year data t to t+2; For year t, we compare ROA vol. computed using (t to t+2) data to ROA vol. computed using (t-3 to t-1) data.*/

foreach x of local diff_var {
	gen diff_`x' = `x'- l3.`x'
	
}

sort gvkey fyear
tsset gvkey fyear

replace diff_std_roaq=. if (fyear < 1990 | fyear>2011)
replace diff_std_rnoaq=. if (fyear < 1990 | fyear>2011)

*** Main results

* lagged changes
quiet areg diff_std_roaq L.(taxchangeup taxchangedown) D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  replace
	test L.taxchangeup+L.taxchangedown=0
	
quiet areg diff_std_rnoaq L.(taxchangeup taxchangedown) D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test L.taxchangeup+L.taxchangedown=0

replace taxchangeup=. if (fyear < 1990 | fyear>2011)
replace wtaxchangeup_all=. if (fyear < 1990 | fyear>2011)

* contemporaneous changes
quiet areg diff_std_roaq taxchangeup taxchangedown D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test taxchangeup+taxchangedown=0

quiet areg diff_std_rnoaq taxchangeup taxchangedown D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test taxchangeup+taxchangedown=0

* Alternative tax change measures: NETS weighted tax changes

quiet areg diff_std_roaq wtaxchangeup_all wtaxchangedown_all D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
		test wtaxchangeup_all+wtaxchangedown_all=0

quiet areg diff_std_rnoaq wtaxchangeup_all wtaxchangedown_all D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
		test wtaxchangeup_all+wtaxchangedown_all=0
/* This program generates the main dependent variables used in Ljungqvist, Zhang and Zuo (2017) */

set more off

use fundq, clear /*  This dataset is directly downloaded from Compustat Fundamentals Quarterly */
drop if atq ==.
drop if atq<=0
drop if ceqq==.
drop if (oiadpq==. & oibdpq==. & oancfy==.)

count
gsort gvkey fyearq fqtr -atq
by gvkey fyearq fqtr: keep if _n==1

replace pstkq=0 if pstkq==.
replace dlcq = 0 if dlcq ==.
replace dlttq = 0 if dlttq ==.
replace mibtq =0 if mibtq ==.

gen noaq = ceqq + pstkq + dlttq + dlcq + mibtq
gen rnoaq = oiadpq/noaq
replace rnoaq =. if noaq <0

gen roaq = oiadpq/atq

capture program drop clean
program define clean
sort fyear
by fyear: egen p99 = pctile (`1'), p(99) 
by fyear: egen p1 = pctile (`1'), p(1) 
replace `1'=p99 if `1'>p99&`1'~=.
replace `1'=p1 if `1'<p1&`1'~=.
drop p99 p1
end

clean rnoaq
clean roaq

sort gvkey fyearq fqtr

by gvkey: gen lag4_fyearq = fyearq[_n-4]
gen diff4_fyearq = fyearq - lag4_fyearq

local vol "rnoaq roaq" 
foreach x of local vol {
	sort gvkey fyearq fqtr
	by gvkey: gen lag4_`x' = `x'[_n-4]
	replace lag4_`x'=. if diff4_fyearq > 1
	gen adj_`x' = `x' - lag4_`x'
	by gvkey: gen `x'_1 = adj_`x'[_n+1]
	by gvkey: gen `x'_2 = adj_`x'[_n+2]
	by gvkey: gen `x'_3 = adj_`x'[_n+3]
	by gvkey: gen `x'_4 = adj_`x'[_n+4]
	by gvkey: gen `x'_5 = adj_`x'[_n+5]
	by gvkey: gen `x'_6 = adj_`x'[_n+6]
	by gvkey: gen `x'_7 = adj_`x'[_n+7]
	by gvkey: gen `x'_8 = adj_`x'[_n+8]
	by gvkey: gen `x'_9 = adj_`x'[_n+9]
	by gvkey: gen `x'_10 = adj_`x'[_n+10]
	by gvkey: gen `x'_11 = adj_`x'[_n+11]
	egen std_`x' = rowsd(`x' `x'_1 `x'_2 `x'_3 `x'_4 `x'_5 `x'_6 `x'_7 `x'_8 `x'_9 `x'_10 `x'_11)
	egen std_`x'_n = rownonmiss(`x' `x'_1 `x'_2 `x'_3 `x'_4 `x'_5 `x'_6 `x'_7 `x'_8 `x'_9 `x'_10 `x'_11) 
	}

sort gvkey fyearq fqtr
by gvkey fyearq: keep if _n==1
count
sum std_*

/* We restrict to n>=4 quarters in the regression */
replace std_roaq =. if std_roaq_n < 4
replace std_rnoaq =. if std_rnoaq_n < 4

keep gvkey fyearq std_*
rename fyearq fyear
destring gvkey, force replace
save fundq_vol, replace
/* This program generates the dataset used in Ljungqvist, Zhang and Zuo (2017) */

set more off
use funda, clear /* This dataset is directly downloaded from Compustat Fundamentals Annual*/

/* Because of leads/lags needed, we do not restrict to 1989-2011 here */
drop if fyear < 1986
drop if fyear > 2013
format datadate %d

/* Initial screening */
des indfmt consol popsrc datafmt
keep if indfmt=="INDL"
keep if consol=="C"
keep if popsrc=="D"
keep if datafmt=="STD        "

/* Retain only US firms */
keep if curcd=="USD"
keep if curncd=="USD"
keep if fic=="USA"

/* Industry screening */
gen sic1= int(sich/1000)
gen sic2=int(sich/100)
drop if sic1==6
drop if sic2==49
drop if sic1==9

/* Additional screening */
drop if at==.
drop if at <=0
sort gvkey fyear
by gvkey fyear: keep if _n==1

/* Generate basic variables */
gen mkv=abs(prcc_f)*csho
gen ltbook_lev=dltt/at
gen mb=mkv/ceq
replace mb =. if ceq <0
replace mb=log(mb)

replace xrd=0 if xrd==.
replace sppe =0 if sppe==.
replace dpc=0 if dpc==.

gen capex=(capx-sppe)/at
gen rnd=xrd/at
gen cash=che/at
gen sur_cash=(oancf-dpc+xrd)/at
gen nol=1 if (tlcf > 0 & tlcf~=.)
replace nol=0 if nol==.

keep gvkey fyear fyr datadate cik at ltbook_lev mb sich sale capex rnd cash sur_cash nol tlcf pi  

gen year=year(datadate)
merge m:1 year using gdplev_annual /*gdplev_annual is the dataset containing the GDP deflator, available at http://www.bea.gov/national/xls/gdplev.xls */
drop if _merge==2
drop _merge

gen at09=at*ratio
gen lnat09=log(at09)
gen sale09=sale*ratio

destring gvkey, force replace
tsset gvkey fyear
gen lagsale09=l1.sale09
gen sgrowth=log(sale09/lagsale09)

merge m:1 gvkey using company /* company is the dataset containing the variable (headquarter) "state", directly downloaded from Compustat */
drop if _merge==2
drop _merge

merge 1:1 gvkey fyear using crsp_data_05012015 /* This dataset contains stock return data, computed using the SAS code "LZZ code stock return" */
drop if _merge==2
drop _merge

merge 1:1 gvkey fyear using fundq_vol /* fundq_vol contains vol. measures based on quarterly data, computed using the Stata code "LZZ code volatility" */
drop if _merge==2
drop _merge

merge m:1 gvkey using compustat_start /* Starting year in compustat for each firm */
drop if _merge==2
drop _merge

gen age=fyear - fyear_start + 1
replace age=log(age)

do "HQ corrections 1989-2011 (c) Alexander Ljungqvist, 2013" /*This do-file corrects Compustat's backfilled HQ states to actual historic HQ states for the period 1989-2011. Please contact Alexander Ljungqvist for access to this do-file */

do "Code tax changes - clean" /*This do-file codes which firms are affected by tax changes when. This do-file is based on manually collected data described in the paper and listed in Table A.1 of the Online Appendix */

merge m:1 state year using GDP_growth_rate /*GSP growth rate is the real annual growth rate in gross state product (GSP) using data obtained from the U.S. Bureau of Economic Analysis */
drop if _merge==2
drop _merge

merge m:1 state year using State_unemployment_rate_annual /*State unemployment rate is the state unemployment rate, obtained from the U.S. Bureau of Labor Statistics */
drop if _merge==2
drop _merge
rename value suer

drop if (state=="AB" | state=="BC" | state=="MB"| state=="NB"| state=="NF"| state=="NS"| state=="ON"| state=="PR"| state=="QC"| state=="SK"| state=="VI") /*removing non-US statas*/

tsset gvkey fyear
egen i_t=group(sich fyear)

tab state, gen(st)

*** Dependent variables

replace std_roaq=log(std_roaq)
replace std_rnoaq=log(std_rnoaq)

*** NETS weighted tax changes
di _N
sort gvkey datadate
merge gvkey datadate using "NETS weighted tax changes.dta",nokeep
/* We match Compustat firms by name to the National Establishment Time Series (NETS) database, which contains a comprehensive record of all business establishments in the U.S. since 1989 */
tab _m
replace wtaxchangeup_all=taxchangeup if _m==1 
replace wtaxchangedown_all=taxchangedown if _m==1 
drop _m

/* absoluate magnitude */
replace taxchangedown=abs(taxchangedown)
replace wtaxchangedown_all=abs(wtaxchangedown_all)
replace wtaxchangeup_all=. if taxchangeup==.
replace wtaxchangedown_all=. if taxchangedown==.

tsset gvkey fyear

global Xvars="age lnat09 mb ltbook_lev sur_cash nol sgrowth RET_12"
global Xvars_state=" gdpgr suer"

/* Winsorize */

capture program drop clean
program define clean
sort fyear
by fyear: egen p99 = pctile (`1'), p(99) 
by fyear: egen p1 = pctile (`1'), p(1) 
replace `1'=p99 if `1'>p99&`1'~=.
replace `1'=p1 if `1'<p1&`1'~=.
drop p99 p1
end

local clean_var "std_roaq std_rnoaq $Xvars $Xvars_state"

foreach x of local clean_var {
	clean `x'
}


tsset gvkey fyear

local diff_var "std_roaq std_rnoaq"

/*std_var was generated using three-year data t to t+2; For year t, we compare ROA vol. computed using (t to t+2) data to ROA vol. computed using (t-3 to t-1) data.*/

foreach x of local diff_var {
	gen diff_`x' = `x'- l3.`x'
	
}

sort gvkey fyear
tsset gvkey fyear

replace diff_std_roaq=. if (fyear < 1990 | fyear>2011)
replace diff_std_rnoaq=. if (fyear < 1990 | fyear>2011)

*** Main results

* lagged changes
quiet areg diff_std_roaq L.(taxchangeup taxchangedown) D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  replace
	test L.taxchangeup+L.taxchangedown=0
	
quiet areg diff_std_rnoaq L.(taxchangeup taxchangedown) D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test L.taxchangeup+L.taxchangedown=0

replace taxchangeup=. if (fyear < 1990 | fyear>2011)
replace wtaxchangeup_all=. if (fyear < 1990 | fyear>2011)

* contemporaneous changes
quiet areg diff_std_roaq taxchangeup taxchangedown D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test taxchangeup+taxchangedown=0

quiet areg diff_std_rnoaq taxchangeup taxchangedown D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test taxchangeup+taxchangedown=0

* Alternative tax change measures: NETS weighted tax changes

quiet areg diff_std_roaq wtaxchangeup_all wtaxchangedown_all D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
		test wtaxchangeup_all+wtaxchangedown_all=0

quiet areg diff_std_rnoaq wtaxchangeup_all wtaxchangedown_all D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
		test wtaxchangeup_all+wtaxchangedown_all=0
/* This program generates the main dependent variables used in Ljungqvist, Zhang and Zuo (2017) */

set more off

use fundq, clear /*  This dataset is directly downloaded from Compustat Fundamentals Quarterly */
drop if atq ==.
drop if atq<=0
drop if ceqq==.
drop if (oiadpq==. & oibdpq==. & oancfy==.)

count
gsort gvkey fyearq fqtr -atq
by gvkey fyearq fqtr: keep if _n==1

replace pstkq=0 if pstkq==.
replace dlcq = 0 if dlcq ==.
replace dlttq = 0 if dlttq ==.
replace mibtq =0 if mibtq ==.

gen noaq = ceqq + pstkq + dlttq + dlcq + mibtq
gen rnoaq = oiadpq/noaq
replace rnoaq =. if noaq <0

gen roaq = oiadpq/atq

capture program drop clean
program define clean
sort fyear
by fyear: egen p99 = pctile (`1'), p(99) 
by fyear: egen p1 = pctile (`1'), p(1) 
replace `1'=p99 if `1'>p99&`1'~=.
replace `1'=p1 if `1'<p1&`1'~=.
drop p99 p1
end

clean rnoaq
clean roaq

sort gvkey fyearq fqtr

by gvkey: gen lag4_fyearq = fyearq[_n-4]
gen diff4_fyearq = fyearq - lag4_fyearq

local vol "rnoaq roaq" 
foreach x of local vol {
	sort gvkey fyearq fqtr
	by gvkey: gen lag4_`x' = `x'[_n-4]
	replace lag4_`x'=. if diff4_fyearq > 1
	gen adj_`x' = `x' - lag4_`x'
	by gvkey: gen `x'_1 = adj_`x'[_n+1]
	by gvkey: gen `x'_2 = adj_`x'[_n+2]
	by gvkey: gen `x'_3 = adj_`x'[_n+3]
	by gvkey: gen `x'_4 = adj_`x'[_n+4]
	by gvkey: gen `x'_5 = adj_`x'[_n+5]
	by gvkey: gen `x'_6 = adj_`x'[_n+6]
	by gvkey: gen `x'_7 = adj_`x'[_n+7]
	by gvkey: gen `x'_8 = adj_`x'[_n+8]
	by gvkey: gen `x'_9 = adj_`x'[_n+9]
	by gvkey: gen `x'_10 = adj_`x'[_n+10]
	by gvkey: gen `x'_11 = adj_`x'[_n+11]
	egen std_`x' = rowsd(`x' `x'_1 `x'_2 `x'_3 `x'_4 `x'_5 `x'_6 `x'_7 `x'_8 `x'_9 `x'_10 `x'_11)
	egen std_`x'_n = rownonmiss(`x' `x'_1 `x'_2 `x'_3 `x'_4 `x'_5 `x'_6 `x'_7 `x'_8 `x'_9 `x'_10 `x'_11) 
	}

sort gvkey fyearq fqtr
by gvkey fyearq: keep if _n==1
count
sum std_*

/* We restrict to n>=4 quarters in the regression */
replace std_roaq =. if std_roaq_n < 4
replace std_rnoaq =. if std_rnoaq_n < 4

keep gvkey fyearq std_*
rename fyearq fyear
destring gvkey, force replace
save fundq_vol, replace

/* This program generates the dataset used in Ljungqvist, Zhang and Zuo (2017) */

set more off
use funda, clear /* This dataset is directly downloaded from Compustat Fundamentals Annual*/

/* Because of leads/lags needed, we do not restrict to 1989-2011 here */
drop if fyear < 1986
drop if fyear > 2013
format datadate %d

/* Initial screening */
des indfmt consol popsrc datafmt
keep if indfmt=="INDL"
keep if consol=="C"
keep if popsrc=="D"
keep if datafmt=="STD        "

/* Retain only US firms */
keep if curcd=="USD"
keep if curncd=="USD"
keep if fic=="USA"

/* Industry screening */
gen sic1= int(sich/1000)
gen sic2=int(sich/100)
drop if sic1==6
drop if sic2==49
drop if sic1==9

/* Additional screening */
drop if at==.
drop if at <=0
sort gvkey fyear
by gvkey fyear: keep if _n==1

/* Generate basic variables */
gen mkv=abs(prcc_f)*csho
gen ltbook_lev=dltt/at
gen mb=mkv/ceq
replace mb =. if ceq <0
replace mb=log(mb)

replace xrd=0 if xrd==.
replace sppe =0 if sppe==.
replace dpc=0 if dpc==.

gen capex=(capx-sppe)/at
gen rnd=xrd/at
gen cash=che/at
gen sur_cash=(oancf-dpc+xrd)/at
gen nol=1 if (tlcf > 0 & tlcf~=.)
replace nol=0 if nol==.

keep gvkey fyear fyr datadate cik at ltbook_lev mb sich sale capex rnd cash sur_cash nol tlcf pi  

gen year=year(datadate)
merge m:1 year using gdplev_annual /*gdplev_annual is the dataset containing the GDP deflator, available at http://www.bea.gov/national/xls/gdplev.xls */
drop if _merge==2
drop _merge

gen at09=at*ratio
gen lnat09=log(at09)
gen sale09=sale*ratio

destring gvkey, force replace
tsset gvkey fyear
gen lagsale09=l1.sale09
gen sgrowth=log(sale09/lagsale09)

merge m:1 gvkey using company /* company is the dataset containing the variable (headquarter) "state", directly downloaded from Compustat */
drop if _merge==2
drop _merge

merge 1:1 gvkey fyear using crsp_data_05012015 /* This dataset contains stock return data, computed using the SAS code "LZZ code stock return" */
drop if _merge==2
drop _merge

merge 1:1 gvkey fyear using fundq_vol /* fundq_vol contains vol. measures based on quarterly data, computed using the Stata code "LZZ code volatility" */
drop if _merge==2
drop _merge

merge m:1 gvkey using compustat_start /* Starting year in compustat for each firm */
drop if _merge==2
drop _merge

gen age=fyear - fyear_start + 1
replace age=log(age)

do "HQ corrections 1989-2011 (c) Alexander Ljungqvist, 2013" /*This do-file corrects Compustat's backfilled HQ states to actual historic HQ states for the period 1989-2011. Please contact Alexander Ljungqvist for access to this do-file */

do "Code tax changes - clean" /*This do-file codes which firms are affected by tax changes when. This do-file is based on manually collected data described in the paper and listed in Table A.1 of the Online Appendix */

merge m:1 state year using GDP_growth_rate /*GSP growth rate is the real annual growth rate in gross state product (GSP) using data obtained from the U.S. Bureau of Economic Analysis */
drop if _merge==2
drop _merge

merge m:1 state year using State_unemployment_rate_annual /*State unemployment rate is the state unemployment rate, obtained from the U.S. Bureau of Labor Statistics */
drop if _merge==2
drop _merge
rename value suer

drop if (state=="AB" | state=="BC" | state=="MB"| state=="NB"| state=="NF"| state=="NS"| state=="ON"| state=="PR"| state=="QC"| state=="SK"| state=="VI") /*removing non-US statas*/

tsset gvkey fyear
egen i_t=group(sich fyear)

tab state, gen(st)

*** Dependent variables

replace std_roaq=log(std_roaq)
replace std_rnoaq=log(std_rnoaq)

*** NETS weighted tax changes
di _N
sort gvkey datadate
merge gvkey datadate using "NETS weighted tax changes.dta",nokeep
/* We match Compustat firms by name to the National Establishment Time Series (NETS) database, which contains a comprehensive record of all business establishments in the U.S. since 1989 */
tab _m
replace wtaxchangeup_all=taxchangeup if _m==1 
replace wtaxchangedown_all=taxchangedown if _m==1 
drop _m

/* absoluate magnitude */
replace taxchangedown=abs(taxchangedown)
replace wtaxchangedown_all=abs(wtaxchangedown_all)
replace wtaxchangeup_all=. if taxchangeup==.
replace wtaxchangedown_all=. if taxchangedown==.

tsset gvkey fyear

global Xvars="age lnat09 mb ltbook_lev sur_cash nol sgrowth RET_12"
global Xvars_state=" gdpgr suer"

/* Winsorize */

capture program drop clean
program define clean
sort fyear
by fyear: egen p99 = pctile (`1'), p(99) 
by fyear: egen p1 = pctile (`1'), p(1) 
replace `1'=p99 if `1'>p99&`1'~=.
replace `1'=p1 if `1'<p1&`1'~=.
drop p99 p1
end

local clean_var "std_roaq std_rnoaq $Xvars $Xvars_state"

foreach x of local clean_var {
	clean `x'
}


tsset gvkey fyear

local diff_var "std_roaq std_rnoaq"

/*std_var was generated using three-year data t to t+2; For year t, we compare ROA vol. computed using (t to t+2) data to ROA vol. computed using (t-3 to t-1) data.*/

foreach x of local diff_var {
	gen diff_`x' = `x'- l3.`x'
	
}

sort gvkey fyear
tsset gvkey fyear

replace diff_std_roaq=. if (fyear < 1990 | fyear>2011)
replace diff_std_rnoaq=. if (fyear < 1990 | fyear>2011)

*** Main results

* lagged changes
quiet areg diff_std_roaq L.(taxchangeup taxchangedown) D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  replace
	test L.taxchangeup+L.taxchangedown=0
	
quiet areg diff_std_rnoaq L.(taxchangeup taxchangedown) D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test L.taxchangeup+L.taxchangedown=0

replace taxchangeup=. if (fyear < 1990 | fyear>2011)
replace wtaxchangeup_all=. if (fyear < 1990 | fyear>2011)

* contemporaneous changes
quiet areg diff_std_roaq taxchangeup taxchangedown D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test taxchangeup+taxchangedown=0

quiet areg diff_std_rnoaq taxchangeup taxchangedown D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
	test taxchangeup+taxchangedown=0

* Alternative tax change measures: NETS weighted tax changes

quiet areg diff_std_roaq wtaxchangeup_all wtaxchangedown_all D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
		test wtaxchangeup_all+wtaxchangedown_all=0

quiet areg diff_std_rnoaq wtaxchangeup_all wtaxchangedown_all D.($Xvars_state) DL.($Xvars), cluster(state) absorb(i_t)
	outreg2 using table2.xls,   bdec(3) sdec(3) rdec(3)  append
		test wtaxchangeup_all+wtaxchangedown_all=0

