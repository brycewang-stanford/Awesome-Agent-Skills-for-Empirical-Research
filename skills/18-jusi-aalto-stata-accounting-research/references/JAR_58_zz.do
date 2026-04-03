* We compute quarterly factor loading using ff 3 factor plus momentum. 

*ssc install use13
clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

********************************************************************************

use "${rawdata}/crspdateprice_bundled_20191216.dta", clear

sort date
merge m:1 date using "${rawdata}/FactorsRF19260701to20181031_20181204.dta"
* stock returns after 20181031 do not have factors. 
keep if _merge == 3
drop _merge

sort permno rdq
by permno: gen nvals = _n == 1
count if nvals == 1

gen FirmGroup = sum(nvals)
drop nvals

save "${data}/temp_FactorBetasStartFile.dta", replace


* The second part of Factor Betas include environmental variables from the 
* first part.  

args FirmGroupNum

clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"




* Select firm RDQ group
use "${data}/temp_FactorBetasStartFile.dta", clear

*Keep 90 days prior to rdq
keep if FirmGroup == `FirmGroupNum'
keep if date >= rdq-90 & date < rdq

*Keep more than 30 trading days
sort permno rdq
by permno rdq: gen NumObs = _N
keep if NumObs >=30


* Compute factor loadings
gen RetEx = ret - rf
statsby BetaMkt=_b[mktrf] BetaSMB = _b[smb] BetaHML = _b[hml] BetaMom = _b[umd], by(permno rdq) saving("${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", replace): reg RetEx mktrf smb hml umd


use "${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", clear
keep permno rdq Beta*
rename rdq rdqlag
duplicates drop permno rdqlag, force
saveold "${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", replace version(12)
* The third part of the file combines all factor loadings

args FirmGroupNum

clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

use "${data}/temp_FactorBetas_Group1.dta", clear

forvalues i=2(1)`FirmGroupNum'{

	capture append using "${data}/temp_FactorBetas_Group`i'.dta"

}

sort permno rdqlag
saveold "${data}/FactorBetas20191216.dta", replace

clear
set more off

args FirmGroupNum

* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

forvalues i=1(1)`FirmGroupNum'{

	shell rm "${data}/temp_FactorBetas_Group`i'.dta"

}

cd "${dofile}"
shell rm "FactorBeta_"*
shell rm "${data}/temp_FactorBetasStartFile.dta"
********************************************************************************
* This file creates two files regarding the return for a size portfolio. 

* The input files are: ME_Breakpoints.csv (size portfolio cut-off points by month
* and 5 percent increment), Portfolios_Formed_on_ME_daily.csv (daily size portfolio
* return. 

* Method:
* We use value weighted return of three portfolios formed based on market value of equity. 

* The output files are:
* DailySize.dta: **daily** value weighted return of three size-portfolios. 
* SizeCut.dta: **monthly** cut-off points for the three size-portfilios. 

* How the output files are used:
* First, each vector of the three daily size portfolio returns is matched to the corresponding 
* daily return file. 
* Second, each vector of the two monthly cut-off points will be matched to the month prior
* to the most recent earnings announcement, that is, prior to the month of the beginning of the
* cumulative return measurement window. For example, if earnings are announced on April 15th, 2015,
* the cut-off points will be chosen to be March, 2015. 

********************************************************************************


// global rawdata "C:/Users/yuzhou/Dropbox/Disclosure/rawdatanew"
// global data "C:/Users/yuzhou/Dropbox/Disclosure/datanew"
// global dofile "C:/Users/yuzhou/Dropbox/Disclosure/analysis"
// global output "C:/Users/yuzhou/Dropbox/Disclosure/output"



global rawdata "/Users/szho/Dropbox/My Projects/Disclosure/rawdatanew"
global data "/Users/szho/Dropbox/My Projects/Disclosure/datafinal"
global dofile "/Users/szho/Dropbox/My Projects/Disclosure/analysis/20191216/03 Factor and Size"
global output "/Users/szho/Dropbox/My Projects/Disclosure/output"


********************************************************************************

capture log close
capture log using "${dofile}/SizeAdjustment20191206.log", replace
********************************************************************************
* Value weighted daily 3-size portfolio returns. 
********************************************************************************


import delimited "${rawdata}/Portfolios_Formed_on_ME_daily_vw20181204.csv", clear

tostring date, replace format(%20.0f)
gen date1 = date(date, "YMD")
format date1 %td
drop date
rename date1 date

keep date lo30 med40 hi30
label variable lo30 "Daily (value weighted) return for firms whose size belongs to the lower 30%"
label variable med40 "Daily (value weighted) return for firms whose size belongs to 30%-70%"
label variable hi30 "Daily (value weighted) return for firms whose size belongs to the upper 30%"

sort date
keep if date!=.

capture saveold "${data}/DailySize20191216.dta", replace version(12)

********************************************************************************
* Montly cut-offs for the 3-size portfolios. 
* The cut-off points are price times the number of shares outstanding from 5% to 100%. 
* The unit is 1,000,000. 
********************************************************************************

import delimited "${rawdata}/ME_Breakpoints.csv", clear

tostring v1, replace format(%20.0f)
gen date = date(v1, "YM")

gen year = year(date)
gen month = month(date)

rename v8 cut30
label variable cut30 "30% size"
rename v16 cut70
label variable cut70 "70% size"

keep year month cut30 cut70
sort year month

capture saveold "${data}/SizeCut20191216.dta", replace version(12)

capture log close

/*

This file computes cumulative stock returns and EA returns and combines the control variables

Input data:
	- GUIDECCM20191216.dta, created by quarterly_ols_sample_construction20191216
	- crspdateprice_bundled_20191216.dta, created by quarterly_ols_sample_construction20191216
	- Controls20191216, created by Controls20191216.sas
	- FactorsRF19260701to20181031_20181204.dta (download)
	- rdq_ibes20191216.dta
	- SizeCut20191216.dta
	- DailySize20191216.dta
	- FactorBetas20191216.dta
	
Output data:
	- final_EPS_2.dta
	- final_EPS_20191216_2.dta

*/




*ssc install use13
clear
clear matrix
clear mata
set mem 3000m
set maxvar 20000
set matsize 10000

set more off
* cd "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
 global path "/Users/szho/Dropbox/My Projects/Disclosure"
* global path "C:/Users/yuzhou/Dropbox/Disclosure" 
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure"
* global path "/home/acct/szho/Disclosure"

global rawdata "${path}/rawdatanew"
global data "${path}/datafinal"
global dofile "${path}/analysis"
global output "${path}/output"

capture log close
log using "${dofile}/20191216/06 Merge/limited_strategic_thinking20191216.log", replace 

***************************
* DO NOT USE FORWARD SLASH IN FILE NAMES!
****************************




******************************
* Step 1: Guidance data  

* The master file is guidance data -- GUIDECCM20191216, 
* produced by quarterly_ols_sample_construction20191216.sas.


******************************
* Step I: Seperate earnings guidance data 
******************************


***** 1.1 Data cleaning:
use "${data}/GUIDECCM20191216.dta", clear

* We drop observations of 2015, because we don't have stock return data.
drop if rdq +90 >= mdy(12,31,2017) 
count
*13,115

**1.1.1 Pre-announcements.

capture drop preannounce

gen day = 31 if guide == 1
replace day = 30 if prd_mon == 4 | prd_mon == 6 | prd_mon == 9 | prd_mon == 11
replace day = 28 if prd_mon == 2 & mod(prd_yr,4) != 0
replace day = 29 if prd_mon == 2 & mod(prd_yr,4) == 0

gen ForecastDate = mdy(prd_mon, day, prd_yr)
label variable ForecastDate "Target date of a management forecast"
format ForecastDate %td
drop day

rename anndats anndats_manager
gen preannounce = (anndats_manager >= datadateq & ForecastDate <= datadateq) | (anndats_manager < datadateq & ForecastDate <= datadateqlag)
replace preannounce = . if guide != 1 | anndats_manager ==.



** 1.1.2 The existence of bundled forecasts in the current quarter or the previous quarter.

preserve

sort permno datadateq 
gen bundle = anndats >=rdqlag-1 & anndats <= rdqlag+1

by permno datadateq: egen BundleCurrentQ = total(bundle)
replace BundleCurrentQ = BundleCurrentQ > 0
replace BundleCurrentQ =. if guide == 0

// define the existence of nonbundle disclosure
gen nonbundle = anndats > rdqlag+1 & anndats !=.
by permno datadateq: egen NonBundleCurrentQ = total(nonbundle)
replace NonBundleCurrentQ = NonBundleCurrentQ > 0
replace NonBundleCurrentQ =. if guide == 0

// generate bundle varaible by only using EPS measure
gen bundle_EPS = bundle
replace bundle_EPS = 0 if measure != "EPS"

by permno datadateq: egen BundleCurrentQ_EPS = total(bundle_EPS)
replace BundleCurrentQ_EPS = BundleCurrentQ_EPS > 0
replace BundleCurrentQ_EPS =. if guide == 0

gen nonbundle_EPS = nonbundle
replace nonbundle_EPS = 0 if measure != "EPS"

by permno datadateq: egen NonBundleCurrentQ_EPS = total(nonbundle_EPS)
replace NonBundleCurrentQ_EPS = NonBundleCurrentQ_EPS > 0
replace NonBundleCurrentQ_EPS =. if guide == 0


keep permno datadateq Bundle* NonBundle*
duplicates drop permno datadateq, force

sort permno datadateq
gen BundleLastQ = BundleCurrentQ[_n-1] if permno == permno[_n-1]
gen BundleNextQ = BundleCurrentQ[_n+1] if permno == permno[_n+1]
label variable BundleCurrentQ "Existence of a bundled forecast the current quarter"
label variable BundleLastQ "Existence of a bundled forecast the previous quarter"
label variable BundleNextQ "Existence of a bundled forecast the following quarter"

gen NonBundleLastQ = NonBundleCurrentQ[_n-1] if permno == permno[_n-1]
gen NonBundleNextQ = NonBundleCurrentQ[_n+1] if permno == permno[_n+1]
label variable NonBundleCurrentQ "Existence of a nonbundled forecast the current quarter"
label variable NonBundleLastQ "Existence of a nonbundled forecast the previous quarter"
label variable NonBundleNextQ "Existence of a nonbundled forecast the following quarter"

gen BundleLastQ_EPS = BundleCurrentQ_EPS[_n-1] if permno == permno[_n-1]
gen BundleNextQ_EPS = BundleCurrentQ_EPS[_n+1] if permno == permno[_n+1]
label variable BundleCurrentQ_EPS "Existence of a bundled forecast the current quarter: EPS"
label variable BundleLastQ_EPS "Existence of a bundled forecast the previous quarter: EPS"
label variable BundleNextQ_EPS "Existence of a bundled forecast the following quarter: EPS"

gen NonBundleLastQ_EPS = NonBundleCurrentQ_EPS[_n-1] if permno == permno[_n-1]
gen NonBundleNextQ_EPS = NonBundleCurrentQ_EPS[_n+1] if permno == permno[_n+1]
label variable NonBundleCurrentQ_EPS "Existence of a nonbundled forecast the current quarter: EPS"
label variable NonBundleLastQ_EPS "Existence of a nonbundled forecast the previous quarter: EPS"
label variable NonBundleNextQ_EPS "Existence of a nonbundled forecast the following quarter: EPS"


keep permno datadateq Bundle* NonBundle*
duplicates drop permno datadateq, force

save "${data}/temp_bundle.dta", replace

restore

sort permno datadateq
merge m:1 permno datadateq using "${data}/temp_bundle.dta"
drop _merge



*** 1.1.3 Keep earnings per share related measures
/*
EPS: Earnings per share
EBS: EBITDA per share
EBT: EBITDA
GPS: Fully reported earnings per share   
NET: Net income
PRE: Pre-tax income
ROA: Return on Assets
ROE: Return on Equity
*/

** Forecast measure, important to keep guide == 0. 

keep if measure == "EPS" | measure == "EBS" | measure == "EBT" | measure == "GPS" | ///
measure == "NET" | measure == "PRE" | measure == "ROA" | measure == "ROE" | guide == 0

count
* 243,028

** Keep the earliest management forecast for each firm quarter

* Pre-announcements "typically" happen after datadateq, so they are likely to be dropped. 
* However, if rdqlag >= datadateq, last period earnings announcement date occurs after current datadateq,
* pre-announcements will be the first observation. 
* Because the nature of preannouncements is likely to be different from other forecasts, we keep one preannouncement
* and one regular forecast. 

sort permno datadateq preannounce anndats_manager
drop if preannounce == 1   
count

sort permno datadateq anndats_manager
by permno datadateq: gen index = _n==1
keep if index == 1
drop index

** Redefine nonguidance sample based on the point that 60 days after rdqlag
gen disclose_dif = anndats_manager - rdqlag
gen nonguide_60 = (disclose_dif == . | disclose_dif >60)

* Adjust earnings announcement date
sort permno datadateq
merge 1:1 permno datadateq using "${data}/rdq_ibes20191216.dta"
drop if _merge ==2
drop _merge

destring hour, replace
gen rdq1 = rdq
replace rdq1=rdq+1 if hour >= 16 & hour!=. & rdq == rdq_new

saveold "${data}/GUIDECCM20191216_EPS.dta", replace

count
* 127,541 observations















******************************
* Step 3: Merge with CRSP data (crspdateprice_bundled_20191216)
* and then generate cmulative return variables and earnings surprise. 
******************************

use "${data}/GUIDECCM20191216_EPS", clear


** 3.1. Merge stock return data 
 
sort permno datadateq
merge 1:m permno datadateq using "${data}/crspdateprice_bundled_20191216.dta"  
 keep if _merge==3
drop _merge



******************************************
* 3.2. Obtain factor returns and factor loadings
******************************************

* 3.3.1 Obtain factor returns

sort date
merge m:1 date using "${rawdata}/FactorsRF19260701to20181031_20181204.dta", keep(3) nogen

* 3.3.2 Obtain factor loadings generated by previous quarter stock returns. 

sort permno rdqlag
merge m:1 permno rdqlag using "${data}/FactorBetas20191216.dta"
drop if _merge == 2
drop _merge

* 3.3.3 Obtain factor loadings generated by next quarter stock returns.

preserve

use "${data}/FactorBetas20191216.dta", clear
gen rdq = rdq[_n-2] if permno == permno[_n-2] //  so rdq is two quarters before the factor loading. 

drop rdqlag
drop if rdq ==.

sort permno rdq
foreach var of varlist BetaMkt BetaSMB BetaHML BetaMom{
	rename `var' `var'Qplus2
}
save "${data}/tempFactorsQplus2.dta", replace

restore

sort permno rdq
merge m:1 permno rdq using "${data}/tempFactorsQplus2.dta"
drop if _merge == 2
drop _merge

* 3.3.3 Generate market adjusted return and four factor adjusted return

gen retFctAdj = ret - rf - BetaMkt*mktrf - BetaSMB*smb - BetaHML*hml - BetaMom*umd
label variable retFctAdj "4 Factor adjusted stock return"

gen retFctAdjQplus2 = ret - rf - BetaMktQplus2*mktrf - BetaSMBQplus2*smb - BetaHMLQplus2*hml - BetaMomQplus2*umd
label variable retFctAdj "4 Factor adjusted stock return using quarter t+2 stock return"

gen retFctAdjChange = retFctAdj
replace retFctAdjChange = retFctAdjQplus2 if date >= rdq



******************************************
* 3.4 Obtain size adjusted stock return. 
******************************************
* 3.4.1 Obtain daily size portfolio return.

* DailySize.dta, generated from SizeAdjustment, contains value weighted 3-size portfolio returns.

sort date
merge m:1 date using "${data}/DailySize20191216.dta"
drop if _merge == 2
drop _merge
* All merged, results the same as prior do file version, disclosure_new_20160412_copy.do.  
count if lo30==.

* 3.4.2 Find size cut-off for each firm at the end of each June.
* We use June, because size portfolio returns are computed using size cut-offs
* formed in June each year. The sorting will be valid until the next June. 
* Therefore, later when we merge this data back to the guidance data,
* for return prior to June 30th, we merge back to previous year,
* for return after June 30th, we merge to the current year. 
* For example, the size category of daily return on 2014.04.15 (variable name, ret)
* should be based on its size of 2013.06.30. 

* We first find the market value of equity at the end of June of each year
* see http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/det_port_form_sz.html. 

* Note that not all firms have June stock returns. 
* One reason is:
* These firms only start to exist in the data after June. Then these firms won't be matched
* with a size portfolio until June of the next year.  
* Another reason is:
* These firms do not trade in June. For example, permno == 32687, year == 2005. 

preserve

use "${data}/crspdateprice_bundled_20191216.dta", clear

* keep June.
gen month = month(date)
keep if month == 6
gen mkv = abs(prc*shrout)/1000
drop if mkv == .

* keep the last observation of each June.
gen year = year(date)
sort permno year date
by permno year: gen nvals = _n == _N
keep if nvals == 1
drop nvals

* merge ${data}/SizeCut.dta

sort year month
merge m:1 year month using "${data}/SizeCut20191216.dta", nogen keep(1 3)
* ${data}/SizeCut.dta, generated from SizeAdjustment, contains monthly cut-offs 
* for the 3-size portfolios. 

* Here SizeTercile indicates where a firm's equity at the end of June falls into 
* the cut-offs computed by French. 

gen SizeTercile = 1
replace SizeTercile = 2 if mkv > cut30 & mkv <= cut70
replace SizeTercile = 3 if mkv > cut70

keep permno year SizeTercile
duplicates drop permno year, force

rename year year_size
sort permno year_size

capture saveold "${data}/temp_SizeTercile", replace version(12)

restore


gen year_size = year(date)
gen month_size = month(date)

replace year_size = year_size - 1 if month_size <7

sort permno year_size
merge m:1 permno year_size using "${data}/temp_SizeTercile"
drop if _merge == 2
drop _merge year_size month_size

* 3.4.3 Find size portfolio return

gen SizeRet = .
replace SizeRet = lo30 if SizeTercile == 1
replace SizeRet = med40 if SizeTercile == 2
replace SizeRet = hi30 if SizeTercile == 3

drop lo30 med40 hi30 SizeTercile

* 3.4.4 Compute size adjusted return (different from previous version)

gen retSizeAdj = ret - SizeRet/100
label variable retSizeAdj "size adjusted log stock return"



******************************************
* 3.5 Create trading date calendar
******************************************

preserve 

use "${rawdata}/FactorsRF19260701to20181031_20181204.dta",clear

keep if date>=mdy(01,01,2000)
bcal create crsp, from(date) generate(tradedate) replace
bcal dir

restore


* Change rdqlag to business calendar format, and adjust weekend announcement to
* the most recent trading date

generate rdqlag2 = bofd("crsp", rdqlag)
format rdqlag2 %tbcrsp:CCYY.NN.DD

forvalues d=1(1)4{

	gen nvals = rdqlag + `d'
	replace nvals = bofd("crsp", nvals)
	
	replace rdqlag2 = nvals if rdqlag2 ==. & nvals !=.
	drop nvals
}


generate rdq2 = bofd("crsp", rdq1)
format rdq2 %tbcrsp:CCYY.NN.DD

generate WeekDayRDQ = rdq2 !=. 

forvalues d=1(1)4{

	gen nvals = rdq1 + `d'
	replace nvals = bofd("crsp", nvals)
	
	replace rdq2 = nvals if rdq2 ==. & nvals !=.
	drop nvals
}

* Change date to business calendar format

generate date2 = bofd("crsp", date)
format date2 %tbcrsp:CCYY.NN.DD

bcal describe crsp
bcal check








******************************************
* Generate long term returns
******************************************

sort permno rdq2 date2

foreach i in 20 40 60{
by permno rdq2: egen CumRetSizeAdj`i'After = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetSizeAdj`i'After = exp(CumRetSizeAdj`i'After) - 1
by permno rdq2: egen CumRetSizeAdj`i'After2 = mean(CumRetSizeAdj`i'After)
replace CumRetSizeAdj`i'After = CumRetSizeAdj`i'After2
drop CumRetSizeAdj`i'After2
} 


capture saveold "${data}/final_EPS_2.dta", replace version(12)



******************************************
* 3.6. Generate cumulative return by using "ret"
******************************************


*****
* Restrict window to improve speed
keep if date2>=rdq2-25 & date2<=rdq2+11 
*****

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRet`i' = total( log( 1 + ret ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRet`i' = exp( CumRet`i' ) - 1
by permno rdq2: egen CumRet`i'2 = mean(CumRet`i')
replace CumRet`i' = CumRet`i'2
drop CumRet`i'2
}

foreach i in 5{
by permno rdq2: egen CumRet`i'After = total( log( 1 + ret ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRet`i'After = exp(CumRet`i'After) - 1
by permno rdq2: egen CumRet`i'After2 = mean(CumRet`i'After)
replace CumRet`i'After = CumRet`i'After2
drop CumRet`i'After2
} 

* Missing CumRet: Missing return means that we do not have return info for the
* first observation in the return measurement window, [-25,+5]. 

gen RetWindow = date2 >= rdq2 -25 & date2 <= rdq2 + 10
sort permno rdq2 RetWindow date2
by permno rdq2 RetWindow: gen ObsFirst = _n == 1 if RetWindow == 1
count if ObsFirst ==. & RetWindow == 1 // should be zero

saveold "${data}/temp_temp.dta", replace





************************************
* Cumulative size adjusted stock return
************************************

sort permno rdq2 date2

forvalues i=1(1)11{
by permno rdq2: egen CumRetSizeAdj`i' = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetSizeAdj`i' = exp(CumRetSizeAdj`i') - 1
by permno rdq2: egen CumRetSizeAdj`i'2 = mean(CumRetSizeAdj`i')
replace CumRetSizeAdj`i' = CumRetSizeAdj`i'2
drop CumRetSizeAdj`i'2
}
forvalues i=0(1)10{
by permno rdq2: egen CumRetSizeAdj`i'After = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetSizeAdj`i'After = exp(CumRetSizeAdj`i'After) - 1
by permno rdq2: egen CumRetSizeAdj`i'After2 = mean(CumRetSizeAdj`i'After)
replace CumRetSizeAdj`i'After = CumRetSizeAdj`i'After2
drop CumRetSizeAdj`i'After2
} 

saveold "${data}/temp_temp.dta", replace


************************************
* Cumulative 4 factor adjusted stock return
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdj`i' = total( log( 1 + retFctAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdj`i' = exp(CumRetFctAdj`i') - 1
by permno rdq2: egen CumRetFctAdj`i'2 = mean(CumRetFctAdj`i')
replace CumRetFctAdj`i' = CumRetFctAdj`i'2
drop CumRetFctAdj`i'2
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdj`i'After = total( log( 1 + retFctAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdj`i'After = exp(CumRetFctAdj`i'After) - 1
by permno rdq2: egen CumRetFctAdj`i'After2 = mean(CumRetFctAdj`i'After)
replace CumRetFctAdj`i'After = CumRetFctAdj`i'After2
drop CumRetFctAdj`i'After2
} 

saveold "${data}/temp_temp.dta", replace

************************************
* Cumulative 4 factor adjusted stock returns that use t+2 information for factor loading.
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdj`i'Qplus2 = total( log( 1 + retFctAdjQplus2 ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdj`i'Qplus2 = exp(CumRetFctAdj`i'Qplus2) - 1
by permno rdq2: egen CumRetFctAdj`i'Qplus22 = mean(CumRetFctAdj`i'Qplus2)
replace CumRetFctAdj`i'Qplus2 = CumRetFctAdj`i'Qplus22
drop CumRetFctAdj`i'Qplus22
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdj`i'Qplus2After = total( log( 1 + retFctAdjQplus2 ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdj`i'Qplus2After = exp(CumRetFctAdj`i'Qplus2After) - 1
by permno rdq2: egen CumRetFctAdj`i'Qplus2After2 = mean(CumRetFctAdj`i'Qplus2After)
replace CumRetFctAdj`i'Qplus2After = CumRetFctAdj`i'Qplus2After2
drop CumRetFctAdj`i'Qplus2After2
} 

saveold "${data}/temp_temp.dta", replace


************************************
* Cumulative 4 factor adjusted stock returns that use t+2 information for factor loading for date >= rdq.
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdjChange`i' = total( log( 1 + retFctAdjChange ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdjChange`i' = exp(CumRetFctAdjChange`i') - 1
by permno rdq2: egen CumRetFctAdjChange`i'2 = mean(CumRetFctAdjChange`i')
replace CumRetFctAdjChange`i' = CumRetFctAdjChange`i'2
drop CumRetFctAdjChange`i'2
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdjChange`i'After = total( log( 1 + retFctAdjChange ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdjChange`i'After = exp(CumRetFctAdjChange`i'After) - 1
by permno rdq2: egen CumRetFctAdjChange`i'After2 = mean(CumRetFctAdjChange`i'After)
replace CumRetFctAdjChange`i'After = CumRetFctAdjChange`i'After2
drop CumRetFctAdjChange`i'After2
} 

saveold "${data}/temp_temp.dta", replace

* 3.7. Generate bid ask spread 

sort permno rdq2 date2

gen BDSpread = ( ask - bid ) / abs(prc)
forvalues i=2(1)2{
by permno rdq2: gen nvals = _n  if date2 >= rdqlag2 + 5 & date2 >= rdq2 -`i' - 5 & date2 <= rdq2 - `i' & BDSpread !=.
replace nvals = 0 if nvals ==.
by permno rdq2: egen nvals1 = max( nvals )
gen nvals2 = .
replace nvals2 = BDSpread if nvals1 == nvals & nvals1 !=0
by permno rdq2: egen BDSpread`i' = mean(nvals2)
replace BDSpread`i' = . if nvals1 == 0
drop nvals*
}

forvalues i=5(1)5{
by permno rdq2: gen nvals = _n  if date2 >= rdqlag2 + 5 & date2 >= rdq2 + `i' - 5 & date2 <= rdq2 + `i'
replace nvals = 0 if nvals ==.
by permno rdq2: egen nvals1 = max( nvals )
gen nvals2 = .
replace nvals2 = BDSpread if nvals1 == nvals & nvals1 !=0
by permno rdq2: egen BDSpread`i'After = mean(nvals2)
replace BDSpread`i'After = . if nvals1 == 0
drop nvals*
} 

drop BDSpread


**** Adjust missing return. 

sort permno rdq2 date2

capture drop Miss*
capture drop afterwindow
capture drop totalafterwindow
capture drop beforewindow
capture drop totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & ret !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & ret !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRet = (totalafterwindow <5 | totalbeforewindow <20) 

* Size Adjusted

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retSizeAdj !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retSizeAdj !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetSizeAdj1 = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdj !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdj !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdj = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted qplus2

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdjQplus2 !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdjQplus2 !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdjQplus2 = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted change

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdjChange !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdjChange !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdjChange = (totalafterwindow <5 | totalbeforewindow <20)







******************************
* Step 4: Generate other control variables 
******************************

duplicates drop permno rdq, force
sort permno datadateq


// 4.1 control to include in the main regressions

* Variables ending in quarter q
preserve
use "${data}/Controls20191216.dta", clear
rename cqretvol ret_vola
rename ncurrentanalyst NumAnalys
rename mtb market_book
rename qeih InstPct
rename earnsurp_epspxq EarnSurp_epspxq
cap rename datadate datadateq
keep permno datadateq ret_vola NumAnalys market_book InstPct EarnSurp_epspxq
save "${data}/tempq0.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq0.dta", nogen keep(1 3)





* Variables ending in quarter q-1
preserve
use "${data}/tempq0.dta", clear
rename datadateq datadateq0
sort permno datadateq0
by permno: gen datadateq=datadateq0[_n+1]
foreach var of varlist ret_vola NumAnalys market_book InstPct EarnSurp_epspxq{
	rename `var' `var'_lag
}
keep if datadateq!=.
sort permno datadateq
save "${data}/tempq1.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq1.dta", nogen keep(1 3)






* Variables ending in quarter q+1
preserve
use "${data}/tempq0.dta", clear
rename datadateq datadateq0
sort permno datadateq0
by permno: gen datadateq=datadateq0[_n-1]
foreach var of varlist ret_vola NumAnalys market_book InstPct EarnSurp_epspxq{
	rename `var' `var'NextQ
}
keep if datadateq!=.
sort permno datadateq
save "${data}/tempq1.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq1.dta", nogen keep(1 3)



* Create controls
foreach var of varlist ret_vola NumAnalys {
	gen `var'_change = `var'NextQ - `var'
}
foreach var of varlist market_book InstPct {
	gen `var'_change = `var' - `var'_lag
}


* Generate additional variables
gen nonguide=(guide==0)
gen year = year(datadateq)
gen quarter = quarter(datadateq)

local num = "5"
foreach i in `num'{
	gen BDSpread_change`i' = BDSpread`i'After - BDSpread2
}




* 4.2 News prediction variables for Table 
preserve

use "${data}/Controls20191216.dta", clear
gen datadateq = datadate
sort permno datadateq
keep permno datadateq atqlag cqroaavg cqroaavg_oiadpq sic
save "${data}/tempatqlag.dta", replace


use "${data}/Controls20191216.dta", clear

sort permno datadate
gen datadatef = datadate[_n+1] if permno == permno[_n+1]
drop datadate
rename datadatef datadateq
sort permno datadateq
duplicates drop permno datadateq, force 
keep permno datadateq cqroaavg cqroaavg_oiadpq leverage cqmaret

save "${data}/temproalag.dta", replace

restore

sort permno datadateq
merge 1:1 permno datadateq using "${data}/temproalag.dta", nogen keep(1 3)
rename cqroaavg pqroaavg
rename cqroaavg_oiadpq pqroaavg_oiadpq 
rename cqmaret pqmaret
merge 1:1 permno datadateq using "${data}/tempatqlag.dta", nogen keep(1 3)


gen logatqlag = log(1+atqlag)
destring sic, replace
gen sic2d = floor(sic/100)

capture saveold "${data}/final_EPS_20191216_2.dta", replace version(12)


log close




/********************************************************************************
This file creates the regression sample for our main results. 

Input data:
	- final_EPS_20191206_2.dta
	- final_EPS_2.dta
	- CRSP_Compustat_Merged_LinkingTable.dta
	- RavenPack20181110/rp20020101to20171231_20181210.dta
	- markit_bc20181110.dta

Output data:
	- /CalendarTrading_DisclosureData_20191216.dta
	- final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta
	
********************************************************************************/

// global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
* global path "C:/Users/zhouy/Dropbox/Disclosure"
 global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure"
// global path "/home/acct/szho/Disclosure"

global rawdata "${path}/rawdatanew"
global data "${path}/datafinal"
global dofile "${path}/analysis/07 Merge"
global output "${path}/output"

********************************************************************************

capture log close 
*log using "${dofile}/regsample20191216.log", replace
set more off

********************************************************************************

* Create data needed for the main results


********************************************************************
* Calendar trading disclosure data
********************************************************************

use "${data}/GUIDECCM20191216.dta", clear

drop if rdq +90 >= mdy(12,31,2017) 
count
*13,115 dropped 

** Pre-announcements
gen day = 31 if guide == 1
replace day = 30 if prd_mon == 4 | prd_mon == 6 | prd_mon == 9 | prd_mon == 11
replace day = 28 if prd_mon == 2 & mod(prd_yr,4) != 0
replace day = 29 if prd_mon == 2 & mod(prd_yr,4) == 0
gen ForecastDate = mdy(prd_mon, day, prd_yr)
label variable ForecastDate "Target date of a management forecast"
format ForecastDate %td
drop day

rename anndats anndats_manager
gen preannounce = (anndats_manager >= datadateq & ForecastDate <= datadateq) | (anndats_manager < datadateq & ForecastDate <= datadateqlag)
replace preannounce = . if guide != 1 | anndats_manager ==.

*** Keep earnings per share related measures
/*
EPS: Earnings per share
EBS: EBITDA per share
EBT: EBITDA
GPS: Fully reported earnings per share   
NET: Net income
PRE: Pre-tax income
ROA: Return on Assets
ROE: Return on Equity
*/

** Forecast measure, important to keep guide == 0. 
keep if measure == "EPS" | measure == "EBS" | measure == "EBT" | measure == "GPS" | ///
measure == "NET" | measure == "PRE" | measure == "ROA" | measure == "ROE" | guide == 0

count

sort permno datadateq preannounce anndats_manager
keep if anndats_manager !=. & preannounce != 1
keep permno datadateq anndats_manager rdq
 
saveold "${data}/CalendarTrading_DisclosureData_20191216.dta", replace version(12)















********************************************************************************
* Step 1: Generate regression sample
********************************************************************************




use "${data}/final_EPS_20191216_2.dta", clear
set more off

********************************************************************************
* Define main sample
********************************************************************************

** Winsorizations of the main controls
macro define ChangeControl "EarnSurp_epspxq EarnSurp_epspxq_lag ret_vola_change market_book_change NumAnalys_change InstPct_change"
foreach var of varlist $ChangeControl BDSpread_change5{ 
	winsor2 `var', cut(1 99) replace
}




** Generate change in return
sort permno rdq
forvalue i=3(1)3{
	rename CumRetFctAdj`i'Qplus2 CumRetFctAdjQplus2`i'
}

forvalue i=5(1)5{
	rename CumRetFctAdj`i'Qplus2After CumRetFctAdjQplus2`i'After
}

macro define depvar "CumRetSizeAdj"
foreach var in $depvar {
    gen Delta`var'10 = ( (1+`var'10After)/(1+`var'3)-1 )*100
	gen Delta`var'5 = ( (1+`var'5After)/(1+`var'3)-1 )*100
	gen Delta`var'2 = ( (1+`var'2After)/(1+`var'3)-1 )*100
	gen Delta`var'5bf5af = ( (1+`var'5After)/(1+`var'6)-1 )*100
	gen Delta`var'10bf5af = ( (1+`var'5After)/(1+`var'11)-1 )*100
	*gen Delta`var'5bf1bf = ( (1+`var'1)/(1+`var'6)-1 )*100
	gen Delta`var'0bf0af = ( (1+`var'0After)/(1+`var'1)-1 )*100
}
macro define depvar "CumRet CumRetSizeAdj CumRetFctAdj CumRetFctAdjChange CumRetFctAdjQplus2"
foreach var in $depvar {
	cap gen Delta`var'5 = ( (1+`var'5After)/(1+`var'3)-1 )*100
}

macro define depvar "CumRetSizeAdj"
foreach var in $depvar{

    quietly sum Delta`var'10,d
	gen OutLierDelta`var'10 = Delta`var'10 >= r(p99) | Delta`var'10 < r(p1)
	
	quietly sum Delta`var'5,d
	gen OutLierDelta`var'5 = Delta`var'5 >= r(p99) | Delta`var'5 < r(p1)
	
	quietly sum Delta`var'2,d
	gen OutLierDelta`var'2 = Delta`var'2 >= r(p99) | Delta`var'2 < r(p1)
			
}




* Keep regression sample
macro define variable "BDSpread_change"
keep if OutLierDeltaCumRetSizeAdj5 == 0 & MissCumRetSizeAdj == 0
reg DeltaCumRetSizeAdj5 ${variable}5 $ChangeControl if OutLierDeltaCumRetSizeAdj5 == 0 & MissCumRetSizeAdj == 0, r 
// This step results in a slight change in the number of observations between version 1204, which does not require lagged earnings surprise,
// and this version of the data, namely 0711. 
keep if e(sample)

















********************************************************************************
* Merge in other variables: factor returns, xs variables, additional variables
********************************************************************************

** Factor returns
preserve

use "${data}/final_EPS_2.dta", clear
sort permno rdq date2
keep permno rdq rdq2 date2 smb mktrf rf hml umd
gen deltardq = date2 - rdq2
keep if deltardq >=-2 & deltardq <=5
foreach var of varlist smb mktrf rf hml umd{
	bys permno rdq: egen Cum`var' = total(log(1+`var'))
	replace Cum`var' = (exp(Cum`var')-1)*100
}
duplicates drop permno rdq, force
keep permno rdq Cum*
sort permno rdq
save "${data}/temp_cumfactor.dta", replace
restore

merge 1:1 permno rdq using "${data}/temp_cumfactor.dta", nogen keep(1 3)
















** Earnings announcement premium
preserve

use "${data}/final_EPS_2.dta", clear
sort permno rdq date2
keep if date2 >= rdq2 - 5 & date2 <= rdq2
macro define depvar "CumRetSizeAdj CumRetFctAdj CumRetFctAdjChange CumRetFctAdjQplus2"
foreach var in $depvar{
	by permno rdq: egen  Delta`var'5bf0af = total( log( 1 + ret ) ) 
	replace Delta`var'5bf0af = (exp(Delta`var'5bf0af)-1)*100
} 
keep permno rdq Delta*
duplicates drop permno rdq, force
sort permno rdq
save "${data}/temp_5bf0af.dta", replace

restore
merge 1:1 permno rdq using "${data}/temp_5bf0af.dta", nogen keep(1 3)
















** News data

preserve

// Prepare for linking table
use "${rawdata}/CRSP_Compustat_Merged_LinkingTable.dta", clear
duplicates drop conm, force
keep gvkey cusip lpermno
sort gvkey
save "${data}/temp_CRSP_Compustat_Merged_LinkingTable.dta", replace

restore

// Prepare for the news data
preserve

use "${rawdata}/RavenPack20181110/rp20020101to20171231_20181210.dta", clear

* drop observations with duplicated cusip 
keep entity_name country_code isin
duplicates drop isin, force
gen cusip = substr(isin,3,9)
sort cusip
by cusip: gen id = _N
drop if id > 1
drop id
save "${data}/RP_isin.dta", replace

restore


preserve

use "${rawdata}/RavenPack20181110/rp20020101to20171231_20181210.dta", clear

keep rpna_date_utc entity_name country_code relevance news_type isin
gen cusip = substr(isin,3,9)
sort cusip
merge m:1 cusip using "${data}/RP_isin.dta"
keep if _merge == 3
drop _merge

drop if cusip == ""

* keep observations with valid cusip 
merge m:1 cusip using "${data}/temp_CRSP_Compustat_Merged_LinkingTable.dta"
keep if _merge == 3  // most of US firms are matched
drop _merge
rename lpermno permno
saveold "${data}/RP_news.dta", version(12) replace


// Preprare for the matching data 
use "${data}/final_EPS_20191216_2.dta", clear
keep permno rdq rdqlag rdqf
saveold "${data}/temp_permno_final_EPS_20191216_2.dta", version(12) replace


*** run sasfile: RP_merge  (save RP_news_merge.dta)
*ssc install saswrapper, replace
saswrapper using "${dofile}/RP_merge.sas", nodata clear 
* Merge news data with firm rdq
restore


preserve
// Generate useful news coverage variables for each firm quarter
use "${data}/RP_news_merge.dta", clear
bysort permno rdq: gen num_news = _N

gen rele = (relevance >= 90)
bysort permno rdq: egen num_news_90 = sum(rele)

duplicates drop permno rdq, force

keep permno rdq num_news num_news_90 

save "${data}/temp_RP_news_merge.dta", replace
restore


// Merge news data with the final regression data
merge 1:1 permno rdq using "${data}/temp_RP_news_merge.dta"
gen news = (_merge == 3)
gen news_90 = (_merge == 3 & num_news_90 > 0)

replace num_news = 0 if num_news ==.
replace num_news_90 = 0 if num_news_90 ==.

sort permno rdq
by permno: gen num_news_lag = num_news[_n-1]
by permno: gen num_news_90_lag = num_news_90[_n-1]

drop if _merge ==2
drop _merge











**Short selling constraints

preserve

use "${data}/markit_bc20191216.dta", clear
gen yq=yq(year,quarter)
replace yq=yq+1
sort permno yq
keep permno yq indicativefee indicativerebate utilisation dcbs
save "${data}/temp_markit_bc.dta", replace

restore

gen yq=yq(year,quarter)
sort permno yq

merge m:1 permno yq using "${data}/temp_markit_bc.dta", keep(1 3) nogen // do not replace missing trading cost vars.
*replace putvol = 0 if putvol ==. // replace option trading to zero if not matched. 


save "${data}/final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta", replace









// guidance history

sort permno rdq
by permno: gen PastNG = sum( nonguide )
replace PastNG = PastNG - 1 if nonguide == 1
by permno: replace PastNG = . if _n == 1
label variable PastNG "The number of past nonguidance"
by permno: gen PastPeriods = _n -1
label variable PastPeriods "The number of past period"

sort permno rdq
saveold "${data}/temp_pastNG.dta", replace version(12)

// Use SAS to generate the past guidance frequence variables
* run PastNG3y.sas
saswrapper using "${dofile}/PastNG3y.sas", nodata clear 

merge 1:1 permno datadateq using "${data}/temp_sas_pastNG_merge.dta", force
drop if _merge == 2
drop _merge




** Determinants of disclosure
// All variables are already defined.





********************************************************************************
* Generate variables
********************************************************************************

gen deltaroa = cqroaavg - pqroaavg
gen lowcost = dcbs <=2 // if not covered by Markit, short-selling should be difficult
gen loss = pqroaavg <0
replace ret_vola_lag=. if pqmaret ==.

winsor2 indicativefee, cuts(1 99) replace
replace utilisation = -utilisation
replace indicativefee = -indicativefee


save "${data}/final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta", replace



* We compute quarterly factor loading using ff 3 factor plus momentum. 

*ssc install use13
clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

********************************************************************************

use "${rawdata}/crspdateprice_bundled_20191216.dta", clear

sort date
merge m:1 date using "${rawdata}/FactorsRF19260701to20181031_20181204.dta"
* stock returns after 20181031 do not have factors. 
keep if _merge == 3
drop _merge

sort permno rdq
by permno: gen nvals = _n == 1
count if nvals == 1

gen FirmGroup = sum(nvals)
drop nvals

save "${data}/temp_FactorBetasStartFile.dta", replace


* The second part of Factor Betas include environmental variables from the 
* first part.  

args FirmGroupNum

clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"




* Select firm RDQ group
use "${data}/temp_FactorBetasStartFile.dta", clear

*Keep 90 days prior to rdq
keep if FirmGroup == `FirmGroupNum'
keep if date >= rdq-90 & date < rdq

*Keep more than 30 trading days
sort permno rdq
by permno rdq: gen NumObs = _N
keep if NumObs >=30


* Compute factor loadings
gen RetEx = ret - rf
statsby BetaMkt=_b[mktrf] BetaSMB = _b[smb] BetaHML = _b[hml] BetaMom = _b[umd], by(permno rdq) saving("${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", replace): reg RetEx mktrf smb hml umd


use "${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", clear
keep permno rdq Beta*
rename rdq rdqlag
duplicates drop permno rdqlag, force
saveold "${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", replace version(12)
* The third part of the file combines all factor loadings

args FirmGroupNum

clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

use "${data}/temp_FactorBetas_Group1.dta", clear

forvalues i=2(1)`FirmGroupNum'{

	capture append using "${data}/temp_FactorBetas_Group`i'.dta"

}

sort permno rdqlag
saveold "${data}/FactorBetas20191216.dta", replace

clear
set more off

args FirmGroupNum

* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

forvalues i=1(1)`FirmGroupNum'{

	shell rm "${data}/temp_FactorBetas_Group`i'.dta"

}

cd "${dofile}"
shell rm "FactorBeta_"*
shell rm "${data}/temp_FactorBetasStartFile.dta"
********************************************************************************
* This file creates two files regarding the return for a size portfolio. 

* The input files are: ME_Breakpoints.csv (size portfolio cut-off points by month
* and 5 percent increment), Portfolios_Formed_on_ME_daily.csv (daily size portfolio
* return. 

* Method:
* We use value weighted return of three portfolios formed based on market value of equity. 

* The output files are:
* DailySize.dta: **daily** value weighted return of three size-portfolios. 
* SizeCut.dta: **monthly** cut-off points for the three size-portfilios. 

* How the output files are used:
* First, each vector of the three daily size portfolio returns is matched to the corresponding 
* daily return file. 
* Second, each vector of the two monthly cut-off points will be matched to the month prior
* to the most recent earnings announcement, that is, prior to the month of the beginning of the
* cumulative return measurement window. For example, if earnings are announced on April 15th, 2015,
* the cut-off points will be chosen to be March, 2015. 

********************************************************************************


// global rawdata "C:/Users/yuzhou/Dropbox/Disclosure/rawdatanew"
// global data "C:/Users/yuzhou/Dropbox/Disclosure/datanew"
// global dofile "C:/Users/yuzhou/Dropbox/Disclosure/analysis"
// global output "C:/Users/yuzhou/Dropbox/Disclosure/output"



global rawdata "/Users/szho/Dropbox/My Projects/Disclosure/rawdatanew"
global data "/Users/szho/Dropbox/My Projects/Disclosure/datafinal"
global dofile "/Users/szho/Dropbox/My Projects/Disclosure/analysis/20191216/03 Factor and Size"
global output "/Users/szho/Dropbox/My Projects/Disclosure/output"


********************************************************************************

capture log close
capture log using "${dofile}/SizeAdjustment20191206.log", replace
********************************************************************************
* Value weighted daily 3-size portfolio returns. 
********************************************************************************


import delimited "${rawdata}/Portfolios_Formed_on_ME_daily_vw20181204.csv", clear

tostring date, replace format(%20.0f)
gen date1 = date(date, "YMD")
format date1 %td
drop date
rename date1 date

keep date lo30 med40 hi30
label variable lo30 "Daily (value weighted) return for firms whose size belongs to the lower 30%"
label variable med40 "Daily (value weighted) return for firms whose size belongs to 30%-70%"
label variable hi30 "Daily (value weighted) return for firms whose size belongs to the upper 30%"

sort date
keep if date!=.

capture saveold "${data}/DailySize20191216.dta", replace version(12)

********************************************************************************
* Montly cut-offs for the 3-size portfolios. 
* The cut-off points are price times the number of shares outstanding from 5% to 100%. 
* The unit is 1,000,000. 
********************************************************************************

import delimited "${rawdata}/ME_Breakpoints.csv", clear

tostring v1, replace format(%20.0f)
gen date = date(v1, "YM")

gen year = year(date)
gen month = month(date)

rename v8 cut30
label variable cut30 "30% size"
rename v16 cut70
label variable cut70 "70% size"

keep year month cut30 cut70
sort year month

capture saveold "${data}/SizeCut20191216.dta", replace version(12)

capture log close

/*

This file computes cumulative stock returns and EA returns and combines the control variables

Input data:
	- GUIDECCM20191216.dta, created by quarterly_ols_sample_construction20191216
	- crspdateprice_bundled_20191216.dta, created by quarterly_ols_sample_construction20191216
	- Controls20191216, created by Controls20191216.sas
	- FactorsRF19260701to20181031_20181204.dta (download)
	- rdq_ibes20191216.dta
	- SizeCut20191216.dta
	- DailySize20191216.dta
	- FactorBetas20191216.dta
	
Output data:
	- final_EPS_2.dta
	- final_EPS_20191216_2.dta

*/




*ssc install use13
clear
clear matrix
clear mata
set mem 3000m
set maxvar 20000
set matsize 10000

set more off
* cd "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
 global path "/Users/szho/Dropbox/My Projects/Disclosure"
* global path "C:/Users/yuzhou/Dropbox/Disclosure" 
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure"
* global path "/home/acct/szho/Disclosure"

global rawdata "${path}/rawdatanew"
global data "${path}/datafinal"
global dofile "${path}/analysis"
global output "${path}/output"

capture log close
log using "${dofile}/20191216/06 Merge/limited_strategic_thinking20191216.log", replace 

***************************
* DO NOT USE FORWARD SLASH IN FILE NAMES!
****************************




******************************
* Step 1: Guidance data  

* The master file is guidance data -- GUIDECCM20191216, 
* produced by quarterly_ols_sample_construction20191216.sas.


******************************
* Step I: Seperate earnings guidance data 
******************************


***** 1.1 Data cleaning:
use "${data}/GUIDECCM20191216.dta", clear

* We drop observations of 2015, because we don't have stock return data.
drop if rdq +90 >= mdy(12,31,2017) 
count
*13,115

**1.1.1 Pre-announcements.

capture drop preannounce

gen day = 31 if guide == 1
replace day = 30 if prd_mon == 4 | prd_mon == 6 | prd_mon == 9 | prd_mon == 11
replace day = 28 if prd_mon == 2 & mod(prd_yr,4) != 0
replace day = 29 if prd_mon == 2 & mod(prd_yr,4) == 0

gen ForecastDate = mdy(prd_mon, day, prd_yr)
label variable ForecastDate "Target date of a management forecast"
format ForecastDate %td
drop day

rename anndats anndats_manager
gen preannounce = (anndats_manager >= datadateq & ForecastDate <= datadateq) | (anndats_manager < datadateq & ForecastDate <= datadateqlag)
replace preannounce = . if guide != 1 | anndats_manager ==.



** 1.1.2 The existence of bundled forecasts in the current quarter or the previous quarter.

preserve

sort permno datadateq 
gen bundle = anndats >=rdqlag-1 & anndats <= rdqlag+1

by permno datadateq: egen BundleCurrentQ = total(bundle)
replace BundleCurrentQ = BundleCurrentQ > 0
replace BundleCurrentQ =. if guide == 0

// define the existence of nonbundle disclosure
gen nonbundle = anndats > rdqlag+1 & anndats !=.
by permno datadateq: egen NonBundleCurrentQ = total(nonbundle)
replace NonBundleCurrentQ = NonBundleCurrentQ > 0
replace NonBundleCurrentQ =. if guide == 0

// generate bundle varaible by only using EPS measure
gen bundle_EPS = bundle
replace bundle_EPS = 0 if measure != "EPS"

by permno datadateq: egen BundleCurrentQ_EPS = total(bundle_EPS)
replace BundleCurrentQ_EPS = BundleCurrentQ_EPS > 0
replace BundleCurrentQ_EPS =. if guide == 0

gen nonbundle_EPS = nonbundle
replace nonbundle_EPS = 0 if measure != "EPS"

by permno datadateq: egen NonBundleCurrentQ_EPS = total(nonbundle_EPS)
replace NonBundleCurrentQ_EPS = NonBundleCurrentQ_EPS > 0
replace NonBundleCurrentQ_EPS =. if guide == 0


keep permno datadateq Bundle* NonBundle*
duplicates drop permno datadateq, force

sort permno datadateq
gen BundleLastQ = BundleCurrentQ[_n-1] if permno == permno[_n-1]
gen BundleNextQ = BundleCurrentQ[_n+1] if permno == permno[_n+1]
label variable BundleCurrentQ "Existence of a bundled forecast the current quarter"
label variable BundleLastQ "Existence of a bundled forecast the previous quarter"
label variable BundleNextQ "Existence of a bundled forecast the following quarter"

gen NonBundleLastQ = NonBundleCurrentQ[_n-1] if permno == permno[_n-1]
gen NonBundleNextQ = NonBundleCurrentQ[_n+1] if permno == permno[_n+1]
label variable NonBundleCurrentQ "Existence of a nonbundled forecast the current quarter"
label variable NonBundleLastQ "Existence of a nonbundled forecast the previous quarter"
label variable NonBundleNextQ "Existence of a nonbundled forecast the following quarter"

gen BundleLastQ_EPS = BundleCurrentQ_EPS[_n-1] if permno == permno[_n-1]
gen BundleNextQ_EPS = BundleCurrentQ_EPS[_n+1] if permno == permno[_n+1]
label variable BundleCurrentQ_EPS "Existence of a bundled forecast the current quarter: EPS"
label variable BundleLastQ_EPS "Existence of a bundled forecast the previous quarter: EPS"
label variable BundleNextQ_EPS "Existence of a bundled forecast the following quarter: EPS"

gen NonBundleLastQ_EPS = NonBundleCurrentQ_EPS[_n-1] if permno == permno[_n-1]
gen NonBundleNextQ_EPS = NonBundleCurrentQ_EPS[_n+1] if permno == permno[_n+1]
label variable NonBundleCurrentQ_EPS "Existence of a nonbundled forecast the current quarter: EPS"
label variable NonBundleLastQ_EPS "Existence of a nonbundled forecast the previous quarter: EPS"
label variable NonBundleNextQ_EPS "Existence of a nonbundled forecast the following quarter: EPS"


keep permno datadateq Bundle* NonBundle*
duplicates drop permno datadateq, force

save "${data}/temp_bundle.dta", replace

restore

sort permno datadateq
merge m:1 permno datadateq using "${data}/temp_bundle.dta"
drop _merge



*** 1.1.3 Keep earnings per share related measures
/*
EPS: Earnings per share
EBS: EBITDA per share
EBT: EBITDA
GPS: Fully reported earnings per share   
NET: Net income
PRE: Pre-tax income
ROA: Return on Assets
ROE: Return on Equity
*/

** Forecast measure, important to keep guide == 0. 

keep if measure == "EPS" | measure == "EBS" | measure == "EBT" | measure == "GPS" | ///
measure == "NET" | measure == "PRE" | measure == "ROA" | measure == "ROE" | guide == 0

count
* 243,028

** Keep the earliest management forecast for each firm quarter

* Pre-announcements "typically" happen after datadateq, so they are likely to be dropped. 
* However, if rdqlag >= datadateq, last period earnings announcement date occurs after current datadateq,
* pre-announcements will be the first observation. 
* Because the nature of preannouncements is likely to be different from other forecasts, we keep one preannouncement
* and one regular forecast. 

sort permno datadateq preannounce anndats_manager
drop if preannounce == 1   
count

sort permno datadateq anndats_manager
by permno datadateq: gen index = _n==1
keep if index == 1
drop index

** Redefine nonguidance sample based on the point that 60 days after rdqlag
gen disclose_dif = anndats_manager - rdqlag
gen nonguide_60 = (disclose_dif == . | disclose_dif >60)

* Adjust earnings announcement date
sort permno datadateq
merge 1:1 permno datadateq using "${data}/rdq_ibes20191216.dta"
drop if _merge ==2
drop _merge

destring hour, replace
gen rdq1 = rdq
replace rdq1=rdq+1 if hour >= 16 & hour!=. & rdq == rdq_new

saveold "${data}/GUIDECCM20191216_EPS.dta", replace

count
* 127,541 observations















******************************
* Step 3: Merge with CRSP data (crspdateprice_bundled_20191216)
* and then generate cmulative return variables and earnings surprise. 
******************************

use "${data}/GUIDECCM20191216_EPS", clear


** 3.1. Merge stock return data 
 
sort permno datadateq
merge 1:m permno datadateq using "${data}/crspdateprice_bundled_20191216.dta"  
 keep if _merge==3
drop _merge



******************************************
* 3.2. Obtain factor returns and factor loadings
******************************************

* 3.3.1 Obtain factor returns

sort date
merge m:1 date using "${rawdata}/FactorsRF19260701to20181031_20181204.dta", keep(3) nogen

* 3.3.2 Obtain factor loadings generated by previous quarter stock returns. 

sort permno rdqlag
merge m:1 permno rdqlag using "${data}/FactorBetas20191216.dta"
drop if _merge == 2
drop _merge

* 3.3.3 Obtain factor loadings generated by next quarter stock returns.

preserve

use "${data}/FactorBetas20191216.dta", clear
gen rdq = rdq[_n-2] if permno == permno[_n-2] //  so rdq is two quarters before the factor loading. 

drop rdqlag
drop if rdq ==.

sort permno rdq
foreach var of varlist BetaMkt BetaSMB BetaHML BetaMom{
	rename `var' `var'Qplus2
}
save "${data}/tempFactorsQplus2.dta", replace

restore

sort permno rdq
merge m:1 permno rdq using "${data}/tempFactorsQplus2.dta"
drop if _merge == 2
drop _merge

* 3.3.3 Generate market adjusted return and four factor adjusted return

gen retFctAdj = ret - rf - BetaMkt*mktrf - BetaSMB*smb - BetaHML*hml - BetaMom*umd
label variable retFctAdj "4 Factor adjusted stock return"

gen retFctAdjQplus2 = ret - rf - BetaMktQplus2*mktrf - BetaSMBQplus2*smb - BetaHMLQplus2*hml - BetaMomQplus2*umd
label variable retFctAdj "4 Factor adjusted stock return using quarter t+2 stock return"

gen retFctAdjChange = retFctAdj
replace retFctAdjChange = retFctAdjQplus2 if date >= rdq



******************************************
* 3.4 Obtain size adjusted stock return. 
******************************************
* 3.4.1 Obtain daily size portfolio return.

* DailySize.dta, generated from SizeAdjustment, contains value weighted 3-size portfolio returns.

sort date
merge m:1 date using "${data}/DailySize20191216.dta"
drop if _merge == 2
drop _merge
* All merged, results the same as prior do file version, disclosure_new_20160412_copy.do.  
count if lo30==.

* 3.4.2 Find size cut-off for each firm at the end of each June.
* We use June, because size portfolio returns are computed using size cut-offs
* formed in June each year. The sorting will be valid until the next June. 
* Therefore, later when we merge this data back to the guidance data,
* for return prior to June 30th, we merge back to previous year,
* for return after June 30th, we merge to the current year. 
* For example, the size category of daily return on 2014.04.15 (variable name, ret)
* should be based on its size of 2013.06.30. 

* We first find the market value of equity at the end of June of each year
* see http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/det_port_form_sz.html. 

* Note that not all firms have June stock returns. 
* One reason is:
* These firms only start to exist in the data after June. Then these firms won't be matched
* with a size portfolio until June of the next year.  
* Another reason is:
* These firms do not trade in June. For example, permno == 32687, year == 2005. 

preserve

use "${data}/crspdateprice_bundled_20191216.dta", clear

* keep June.
gen month = month(date)
keep if month == 6
gen mkv = abs(prc*shrout)/1000
drop if mkv == .

* keep the last observation of each June.
gen year = year(date)
sort permno year date
by permno year: gen nvals = _n == _N
keep if nvals == 1
drop nvals

* merge ${data}/SizeCut.dta

sort year month
merge m:1 year month using "${data}/SizeCut20191216.dta", nogen keep(1 3)
* ${data}/SizeCut.dta, generated from SizeAdjustment, contains monthly cut-offs 
* for the 3-size portfolios. 

* Here SizeTercile indicates where a firm's equity at the end of June falls into 
* the cut-offs computed by French. 

gen SizeTercile = 1
replace SizeTercile = 2 if mkv > cut30 & mkv <= cut70
replace SizeTercile = 3 if mkv > cut70

keep permno year SizeTercile
duplicates drop permno year, force

rename year year_size
sort permno year_size

capture saveold "${data}/temp_SizeTercile", replace version(12)

restore


gen year_size = year(date)
gen month_size = month(date)

replace year_size = year_size - 1 if month_size <7

sort permno year_size
merge m:1 permno year_size using "${data}/temp_SizeTercile"
drop if _merge == 2
drop _merge year_size month_size

* 3.4.3 Find size portfolio return

gen SizeRet = .
replace SizeRet = lo30 if SizeTercile == 1
replace SizeRet = med40 if SizeTercile == 2
replace SizeRet = hi30 if SizeTercile == 3

drop lo30 med40 hi30 SizeTercile

* 3.4.4 Compute size adjusted return (different from previous version)

gen retSizeAdj = ret - SizeRet/100
label variable retSizeAdj "size adjusted log stock return"



******************************************
* 3.5 Create trading date calendar
******************************************

preserve 

use "${rawdata}/FactorsRF19260701to20181031_20181204.dta",clear

keep if date>=mdy(01,01,2000)
bcal create crsp, from(date) generate(tradedate) replace
bcal dir

restore


* Change rdqlag to business calendar format, and adjust weekend announcement to
* the most recent trading date

generate rdqlag2 = bofd("crsp", rdqlag)
format rdqlag2 %tbcrsp:CCYY.NN.DD

forvalues d=1(1)4{

	gen nvals = rdqlag + `d'
	replace nvals = bofd("crsp", nvals)
	
	replace rdqlag2 = nvals if rdqlag2 ==. & nvals !=.
	drop nvals
}


generate rdq2 = bofd("crsp", rdq1)
format rdq2 %tbcrsp:CCYY.NN.DD

generate WeekDayRDQ = rdq2 !=. 

forvalues d=1(1)4{

	gen nvals = rdq1 + `d'
	replace nvals = bofd("crsp", nvals)
	
	replace rdq2 = nvals if rdq2 ==. & nvals !=.
	drop nvals
}

* Change date to business calendar format

generate date2 = bofd("crsp", date)
format date2 %tbcrsp:CCYY.NN.DD

bcal describe crsp
bcal check








******************************************
* Generate long term returns
******************************************

sort permno rdq2 date2

foreach i in 20 40 60{
by permno rdq2: egen CumRetSizeAdj`i'After = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetSizeAdj`i'After = exp(CumRetSizeAdj`i'After) - 1
by permno rdq2: egen CumRetSizeAdj`i'After2 = mean(CumRetSizeAdj`i'After)
replace CumRetSizeAdj`i'After = CumRetSizeAdj`i'After2
drop CumRetSizeAdj`i'After2
} 


capture saveold "${data}/final_EPS_2.dta", replace version(12)



******************************************
* 3.6. Generate cumulative return by using "ret"
******************************************


*****
* Restrict window to improve speed
keep if date2>=rdq2-25 & date2<=rdq2+11 
*****

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRet`i' = total( log( 1 + ret ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRet`i' = exp( CumRet`i' ) - 1
by permno rdq2: egen CumRet`i'2 = mean(CumRet`i')
replace CumRet`i' = CumRet`i'2
drop CumRet`i'2
}

foreach i in 5{
by permno rdq2: egen CumRet`i'After = total( log( 1 + ret ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRet`i'After = exp(CumRet`i'After) - 1
by permno rdq2: egen CumRet`i'After2 = mean(CumRet`i'After)
replace CumRet`i'After = CumRet`i'After2
drop CumRet`i'After2
} 

* Missing CumRet: Missing return means that we do not have return info for the
* first observation in the return measurement window, [-25,+5]. 

gen RetWindow = date2 >= rdq2 -25 & date2 <= rdq2 + 10
sort permno rdq2 RetWindow date2
by permno rdq2 RetWindow: gen ObsFirst = _n == 1 if RetWindow == 1
count if ObsFirst ==. & RetWindow == 1 // should be zero

saveold "${data}/temp_temp.dta", replace





************************************
* Cumulative size adjusted stock return
************************************

sort permno rdq2 date2

forvalues i=1(1)11{
by permno rdq2: egen CumRetSizeAdj`i' = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetSizeAdj`i' = exp(CumRetSizeAdj`i') - 1
by permno rdq2: egen CumRetSizeAdj`i'2 = mean(CumRetSizeAdj`i')
replace CumRetSizeAdj`i' = CumRetSizeAdj`i'2
drop CumRetSizeAdj`i'2
}
forvalues i=0(1)10{
by permno rdq2: egen CumRetSizeAdj`i'After = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetSizeAdj`i'After = exp(CumRetSizeAdj`i'After) - 1
by permno rdq2: egen CumRetSizeAdj`i'After2 = mean(CumRetSizeAdj`i'After)
replace CumRetSizeAdj`i'After = CumRetSizeAdj`i'After2
drop CumRetSizeAdj`i'After2
} 

saveold "${data}/temp_temp.dta", replace


************************************
* Cumulative 4 factor adjusted stock return
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdj`i' = total( log( 1 + retFctAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdj`i' = exp(CumRetFctAdj`i') - 1
by permno rdq2: egen CumRetFctAdj`i'2 = mean(CumRetFctAdj`i')
replace CumRetFctAdj`i' = CumRetFctAdj`i'2
drop CumRetFctAdj`i'2
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdj`i'After = total( log( 1 + retFctAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdj`i'After = exp(CumRetFctAdj`i'After) - 1
by permno rdq2: egen CumRetFctAdj`i'After2 = mean(CumRetFctAdj`i'After)
replace CumRetFctAdj`i'After = CumRetFctAdj`i'After2
drop CumRetFctAdj`i'After2
} 

saveold "${data}/temp_temp.dta", replace

************************************
* Cumulative 4 factor adjusted stock returns that use t+2 information for factor loading.
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdj`i'Qplus2 = total( log( 1 + retFctAdjQplus2 ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdj`i'Qplus2 = exp(CumRetFctAdj`i'Qplus2) - 1
by permno rdq2: egen CumRetFctAdj`i'Qplus22 = mean(CumRetFctAdj`i'Qplus2)
replace CumRetFctAdj`i'Qplus2 = CumRetFctAdj`i'Qplus22
drop CumRetFctAdj`i'Qplus22
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdj`i'Qplus2After = total( log( 1 + retFctAdjQplus2 ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdj`i'Qplus2After = exp(CumRetFctAdj`i'Qplus2After) - 1
by permno rdq2: egen CumRetFctAdj`i'Qplus2After2 = mean(CumRetFctAdj`i'Qplus2After)
replace CumRetFctAdj`i'Qplus2After = CumRetFctAdj`i'Qplus2After2
drop CumRetFctAdj`i'Qplus2After2
} 

saveold "${data}/temp_temp.dta", replace


************************************
* Cumulative 4 factor adjusted stock returns that use t+2 information for factor loading for date >= rdq.
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdjChange`i' = total( log( 1 + retFctAdjChange ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdjChange`i' = exp(CumRetFctAdjChange`i') - 1
by permno rdq2: egen CumRetFctAdjChange`i'2 = mean(CumRetFctAdjChange`i')
replace CumRetFctAdjChange`i' = CumRetFctAdjChange`i'2
drop CumRetFctAdjChange`i'2
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdjChange`i'After = total( log( 1 + retFctAdjChange ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdjChange`i'After = exp(CumRetFctAdjChange`i'After) - 1
by permno rdq2: egen CumRetFctAdjChange`i'After2 = mean(CumRetFctAdjChange`i'After)
replace CumRetFctAdjChange`i'After = CumRetFctAdjChange`i'After2
drop CumRetFctAdjChange`i'After2
} 

saveold "${data}/temp_temp.dta", replace

* 3.7. Generate bid ask spread 

sort permno rdq2 date2

gen BDSpread = ( ask - bid ) / abs(prc)
forvalues i=2(1)2{
by permno rdq2: gen nvals = _n  if date2 >= rdqlag2 + 5 & date2 >= rdq2 -`i' - 5 & date2 <= rdq2 - `i' & BDSpread !=.
replace nvals = 0 if nvals ==.
by permno rdq2: egen nvals1 = max( nvals )
gen nvals2 = .
replace nvals2 = BDSpread if nvals1 == nvals & nvals1 !=0
by permno rdq2: egen BDSpread`i' = mean(nvals2)
replace BDSpread`i' = . if nvals1 == 0
drop nvals*
}

forvalues i=5(1)5{
by permno rdq2: gen nvals = _n  if date2 >= rdqlag2 + 5 & date2 >= rdq2 + `i' - 5 & date2 <= rdq2 + `i'
replace nvals = 0 if nvals ==.
by permno rdq2: egen nvals1 = max( nvals )
gen nvals2 = .
replace nvals2 = BDSpread if nvals1 == nvals & nvals1 !=0
by permno rdq2: egen BDSpread`i'After = mean(nvals2)
replace BDSpread`i'After = . if nvals1 == 0
drop nvals*
} 

drop BDSpread


**** Adjust missing return. 

sort permno rdq2 date2

capture drop Miss*
capture drop afterwindow
capture drop totalafterwindow
capture drop beforewindow
capture drop totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & ret !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & ret !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRet = (totalafterwindow <5 | totalbeforewindow <20) 

* Size Adjusted

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retSizeAdj !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retSizeAdj !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetSizeAdj1 = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdj !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdj !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdj = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted qplus2

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdjQplus2 !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdjQplus2 !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdjQplus2 = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted change

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdjChange !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdjChange !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdjChange = (totalafterwindow <5 | totalbeforewindow <20)







******************************
* Step 4: Generate other control variables 
******************************

duplicates drop permno rdq, force
sort permno datadateq


// 4.1 control to include in the main regressions

* Variables ending in quarter q
preserve
use "${data}/Controls20191216.dta", clear
rename cqretvol ret_vola
rename ncurrentanalyst NumAnalys
rename mtb market_book
rename qeih InstPct
rename earnsurp_epspxq EarnSurp_epspxq
cap rename datadate datadateq
keep permno datadateq ret_vola NumAnalys market_book InstPct EarnSurp_epspxq
save "${data}/tempq0.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq0.dta", nogen keep(1 3)





* Variables ending in quarter q-1
preserve
use "${data}/tempq0.dta", clear
rename datadateq datadateq0
sort permno datadateq0
by permno: gen datadateq=datadateq0[_n+1]
foreach var of varlist ret_vola NumAnalys market_book InstPct EarnSurp_epspxq{
	rename `var' `var'_lag
}
keep if datadateq!=.
sort permno datadateq
save "${data}/tempq1.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq1.dta", nogen keep(1 3)






* Variables ending in quarter q+1
preserve
use "${data}/tempq0.dta", clear
rename datadateq datadateq0
sort permno datadateq0
by permno: gen datadateq=datadateq0[_n-1]
foreach var of varlist ret_vola NumAnalys market_book InstPct EarnSurp_epspxq{
	rename `var' `var'NextQ
}
keep if datadateq!=.
sort permno datadateq
save "${data}/tempq1.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq1.dta", nogen keep(1 3)



* Create controls
foreach var of varlist ret_vola NumAnalys {
	gen `var'_change = `var'NextQ - `var'
}
foreach var of varlist market_book InstPct {
	gen `var'_change = `var' - `var'_lag
}


* Generate additional variables
gen nonguide=(guide==0)
gen year = year(datadateq)
gen quarter = quarter(datadateq)

local num = "5"
foreach i in `num'{
	gen BDSpread_change`i' = BDSpread`i'After - BDSpread2
}




* 4.2 News prediction variables for Table 
preserve

use "${data}/Controls20191216.dta", clear
gen datadateq = datadate
sort permno datadateq
keep permno datadateq atqlag cqroaavg cqroaavg_oiadpq sic
save "${data}/tempatqlag.dta", replace


use "${data}/Controls20191216.dta", clear

sort permno datadate
gen datadatef = datadate[_n+1] if permno == permno[_n+1]
drop datadate
rename datadatef datadateq
sort permno datadateq
duplicates drop permno datadateq, force 
keep permno datadateq cqroaavg cqroaavg_oiadpq leverage cqmaret

save "${data}/temproalag.dta", replace

restore

sort permno datadateq
merge 1:1 permno datadateq using "${data}/temproalag.dta", nogen keep(1 3)
rename cqroaavg pqroaavg
rename cqroaavg_oiadpq pqroaavg_oiadpq 
rename cqmaret pqmaret
merge 1:1 permno datadateq using "${data}/tempatqlag.dta", nogen keep(1 3)


gen logatqlag = log(1+atqlag)
destring sic, replace
gen sic2d = floor(sic/100)

capture saveold "${data}/final_EPS_20191216_2.dta", replace version(12)


log close




/********************************************************************************
This file creates the regression sample for our main results. 

Input data:
	- final_EPS_20191206_2.dta
	- final_EPS_2.dta
	- CRSP_Compustat_Merged_LinkingTable.dta
	- RavenPack20181110/rp20020101to20171231_20181210.dta
	- markit_bc20181110.dta

Output data:
	- /CalendarTrading_DisclosureData_20191216.dta
	- final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta
	
********************************************************************************/

// global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
* global path "C:/Users/zhouy/Dropbox/Disclosure"
 global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure"
// global path "/home/acct/szho/Disclosure"

global rawdata "${path}/rawdatanew"
global data "${path}/datafinal"
global dofile "${path}/analysis/07 Merge"
global output "${path}/output"

********************************************************************************

capture log close 
*log using "${dofile}/regsample20191216.log", replace
set more off

********************************************************************************

* Create data needed for the main results


********************************************************************
* Calendar trading disclosure data
********************************************************************

use "${data}/GUIDECCM20191216.dta", clear

drop if rdq +90 >= mdy(12,31,2017) 
count
*13,115 dropped 

** Pre-announcements
gen day = 31 if guide == 1
replace day = 30 if prd_mon == 4 | prd_mon == 6 | prd_mon == 9 | prd_mon == 11
replace day = 28 if prd_mon == 2 & mod(prd_yr,4) != 0
replace day = 29 if prd_mon == 2 & mod(prd_yr,4) == 0
gen ForecastDate = mdy(prd_mon, day, prd_yr)
label variable ForecastDate "Target date of a management forecast"
format ForecastDate %td
drop day

rename anndats anndats_manager
gen preannounce = (anndats_manager >= datadateq & ForecastDate <= datadateq) | (anndats_manager < datadateq & ForecastDate <= datadateqlag)
replace preannounce = . if guide != 1 | anndats_manager ==.

*** Keep earnings per share related measures
/*
EPS: Earnings per share
EBS: EBITDA per share
EBT: EBITDA
GPS: Fully reported earnings per share   
NET: Net income
PRE: Pre-tax income
ROA: Return on Assets
ROE: Return on Equity
*/

** Forecast measure, important to keep guide == 0. 
keep if measure == "EPS" | measure == "EBS" | measure == "EBT" | measure == "GPS" | ///
measure == "NET" | measure == "PRE" | measure == "ROA" | measure == "ROE" | guide == 0

count

sort permno datadateq preannounce anndats_manager
keep if anndats_manager !=. & preannounce != 1
keep permno datadateq anndats_manager rdq
 
saveold "${data}/CalendarTrading_DisclosureData_20191216.dta", replace version(12)















********************************************************************************
* Step 1: Generate regression sample
********************************************************************************




use "${data}/final_EPS_20191216_2.dta", clear
set more off

********************************************************************************
* Define main sample
********************************************************************************

** Winsorizations of the main controls
macro define ChangeControl "EarnSurp_epspxq EarnSurp_epspxq_lag ret_vola_change market_book_change NumAnalys_change InstPct_change"
foreach var of varlist $ChangeControl BDSpread_change5{ 
	winsor2 `var', cut(1 99) replace
}




** Generate change in return
sort permno rdq
forvalue i=3(1)3{
	rename CumRetFctAdj`i'Qplus2 CumRetFctAdjQplus2`i'
}

forvalue i=5(1)5{
	rename CumRetFctAdj`i'Qplus2After CumRetFctAdjQplus2`i'After
}

macro define depvar "CumRetSizeAdj"
foreach var in $depvar {
    gen Delta`var'10 = ( (1+`var'10After)/(1+`var'3)-1 )*100
	gen Delta`var'5 = ( (1+`var'5After)/(1+`var'3)-1 )*100
	gen Delta`var'2 = ( (1+`var'2After)/(1+`var'3)-1 )*100
	gen Delta`var'5bf5af = ( (1+`var'5After)/(1+`var'6)-1 )*100
	gen Delta`var'10bf5af = ( (1+`var'5After)/(1+`var'11)-1 )*100
	*gen Delta`var'5bf1bf = ( (1+`var'1)/(1+`var'6)-1 )*100
	gen Delta`var'0bf0af = ( (1+`var'0After)/(1+`var'1)-1 )*100
}
macro define depvar "CumRet CumRetSizeAdj CumRetFctAdj CumRetFctAdjChange CumRetFctAdjQplus2"
foreach var in $depvar {
	cap gen Delta`var'5 = ( (1+`var'5After)/(1+`var'3)-1 )*100
}

macro define depvar "CumRetSizeAdj"
foreach var in $depvar{

    quietly sum Delta`var'10,d
	gen OutLierDelta`var'10 = Delta`var'10 >= r(p99) | Delta`var'10 < r(p1)
	
	quietly sum Delta`var'5,d
	gen OutLierDelta`var'5 = Delta`var'5 >= r(p99) | Delta`var'5 < r(p1)
	
	quietly sum Delta`var'2,d
	gen OutLierDelta`var'2 = Delta`var'2 >= r(p99) | Delta`var'2 < r(p1)
			
}




* Keep regression sample
macro define variable "BDSpread_change"
keep if OutLierDeltaCumRetSizeAdj5 == 0 & MissCumRetSizeAdj == 0
reg DeltaCumRetSizeAdj5 ${variable}5 $ChangeControl if OutLierDeltaCumRetSizeAdj5 == 0 & MissCumRetSizeAdj == 0, r 
// This step results in a slight change in the number of observations between version 1204, which does not require lagged earnings surprise,
// and this version of the data, namely 0711. 
keep if e(sample)

















********************************************************************************
* Merge in other variables: factor returns, xs variables, additional variables
********************************************************************************

** Factor returns
preserve

use "${data}/final_EPS_2.dta", clear
sort permno rdq date2
keep permno rdq rdq2 date2 smb mktrf rf hml umd
gen deltardq = date2 - rdq2
keep if deltardq >=-2 & deltardq <=5
foreach var of varlist smb mktrf rf hml umd{
	bys permno rdq: egen Cum`var' = total(log(1+`var'))
	replace Cum`var' = (exp(Cum`var')-1)*100
}
duplicates drop permno rdq, force
keep permno rdq Cum*
sort permno rdq
save "${data}/temp_cumfactor.dta", replace
restore

merge 1:1 permno rdq using "${data}/temp_cumfactor.dta", nogen keep(1 3)
















** Earnings announcement premium
preserve

use "${data}/final_EPS_2.dta", clear
sort permno rdq date2
keep if date2 >= rdq2 - 5 & date2 <= rdq2
macro define depvar "CumRetSizeAdj CumRetFctAdj CumRetFctAdjChange CumRetFctAdjQplus2"
foreach var in $depvar{
	by permno rdq: egen  Delta`var'5bf0af = total( log( 1 + ret ) ) 
	replace Delta`var'5bf0af = (exp(Delta`var'5bf0af)-1)*100
} 
keep permno rdq Delta*
duplicates drop permno rdq, force
sort permno rdq
save "${data}/temp_5bf0af.dta", replace

restore
merge 1:1 permno rdq using "${data}/temp_5bf0af.dta", nogen keep(1 3)
















** News data

preserve

// Prepare for linking table
use "${rawdata}/CRSP_Compustat_Merged_LinkingTable.dta", clear
duplicates drop conm, force
keep gvkey cusip lpermno
sort gvkey
save "${data}/temp_CRSP_Compustat_Merged_LinkingTable.dta", replace

restore

// Prepare for the news data
preserve

use "${rawdata}/RavenPack20181110/rp20020101to20171231_20181210.dta", clear

* drop observations with duplicated cusip 
keep entity_name country_code isin
duplicates drop isin, force
gen cusip = substr(isin,3,9)
sort cusip
by cusip: gen id = _N
drop if id > 1
drop id
save "${data}/RP_isin.dta", replace

restore


preserve

use "${rawdata}/RavenPack20181110/rp20020101to20171231_20181210.dta", clear

keep rpna_date_utc entity_name country_code relevance news_type isin
gen cusip = substr(isin,3,9)
sort cusip
merge m:1 cusip using "${data}/RP_isin.dta"
keep if _merge == 3
drop _merge

drop if cusip == ""

* keep observations with valid cusip 
merge m:1 cusip using "${data}/temp_CRSP_Compustat_Merged_LinkingTable.dta"
keep if _merge == 3  // most of US firms are matched
drop _merge
rename lpermno permno
saveold "${data}/RP_news.dta", version(12) replace


// Preprare for the matching data 
use "${data}/final_EPS_20191216_2.dta", clear
keep permno rdq rdqlag rdqf
saveold "${data}/temp_permno_final_EPS_20191216_2.dta", version(12) replace


*** run sasfile: RP_merge  (save RP_news_merge.dta)
*ssc install saswrapper, replace
saswrapper using "${dofile}/RP_merge.sas", nodata clear 
* Merge news data with firm rdq
restore


preserve
// Generate useful news coverage variables for each firm quarter
use "${data}/RP_news_merge.dta", clear
bysort permno rdq: gen num_news = _N

gen rele = (relevance >= 90)
bysort permno rdq: egen num_news_90 = sum(rele)

duplicates drop permno rdq, force

keep permno rdq num_news num_news_90 

save "${data}/temp_RP_news_merge.dta", replace
restore


// Merge news data with the final regression data
merge 1:1 permno rdq using "${data}/temp_RP_news_merge.dta"
gen news = (_merge == 3)
gen news_90 = (_merge == 3 & num_news_90 > 0)

replace num_news = 0 if num_news ==.
replace num_news_90 = 0 if num_news_90 ==.

sort permno rdq
by permno: gen num_news_lag = num_news[_n-1]
by permno: gen num_news_90_lag = num_news_90[_n-1]

drop if _merge ==2
drop _merge











**Short selling constraints

preserve

use "${data}/markit_bc20191216.dta", clear
gen yq=yq(year,quarter)
replace yq=yq+1
sort permno yq
keep permno yq indicativefee indicativerebate utilisation dcbs
save "${data}/temp_markit_bc.dta", replace

restore

gen yq=yq(year,quarter)
sort permno yq

merge m:1 permno yq using "${data}/temp_markit_bc.dta", keep(1 3) nogen // do not replace missing trading cost vars.
*replace putvol = 0 if putvol ==. // replace option trading to zero if not matched. 


save "${data}/final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta", replace









// guidance history

sort permno rdq
by permno: gen PastNG = sum( nonguide )
replace PastNG = PastNG - 1 if nonguide == 1
by permno: replace PastNG = . if _n == 1
label variable PastNG "The number of past nonguidance"
by permno: gen PastPeriods = _n -1
label variable PastPeriods "The number of past period"

sort permno rdq
saveold "${data}/temp_pastNG.dta", replace version(12)

// Use SAS to generate the past guidance frequence variables
* run PastNG3y.sas
saswrapper using "${dofile}/PastNG3y.sas", nodata clear 

merge 1:1 permno datadateq using "${data}/temp_sas_pastNG_merge.dta", force
drop if _merge == 2
drop _merge




** Determinants of disclosure
// All variables are already defined.





********************************************************************************
* Generate variables
********************************************************************************

gen deltaroa = cqroaavg - pqroaavg
gen lowcost = dcbs <=2 // if not covered by Markit, short-selling should be difficult
gen loss = pqroaavg <0
replace ret_vola_lag=. if pqmaret ==.

winsor2 indicativefee, cuts(1 99) replace
replace utilisation = -utilisation
replace indicativefee = -indicativefee


save "${data}/final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta", replace



* We compute quarterly factor loading using ff 3 factor plus momentum. 

*ssc install use13
clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

********************************************************************************

use "${rawdata}/crspdateprice_bundled_20191216.dta", clear

sort date
merge m:1 date using "${rawdata}/FactorsRF19260701to20181031_20181204.dta"
* stock returns after 20181031 do not have factors. 
keep if _merge == 3
drop _merge

sort permno rdq
by permno: gen nvals = _n == 1
count if nvals == 1

gen FirmGroup = sum(nvals)
drop nvals

save "${data}/temp_FactorBetasStartFile.dta", replace



* The second part of Factor Betas include environmental variables from the 
* first part.  

args FirmGroupNum

clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"




* Select firm RDQ group
use "${data}/temp_FactorBetasStartFile.dta", clear

*Keep 90 days prior to rdq
keep if FirmGroup == `FirmGroupNum'
keep if date >= rdq-90 & date < rdq

*Keep more than 30 trading days
sort permno rdq
by permno rdq: gen NumObs = _N
keep if NumObs >=30


* Compute factor loadings
gen RetEx = ret - rf
statsby BetaMkt=_b[mktrf] BetaSMB = _b[smb] BetaHML = _b[hml] BetaMom = _b[umd], by(permno rdq) saving("${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", replace): reg RetEx mktrf smb hml umd


use "${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", clear
keep permno rdq Beta*
rename rdq rdqlag
duplicates drop permno rdqlag, force
saveold "${data}/temp_FactorBetas_Group`FirmGroupNum'.dta", replace version(12)

* The third part of the file combines all factor loadings

args FirmGroupNum

clear
set more off


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

use "${data}/temp_FactorBetas_Group1.dta", clear

forvalues i=2(1)`FirmGroupNum'{

	capture append using "${data}/temp_FactorBetas_Group`i'.dta"

}

sort permno rdqlag
saveold "${data}/FactorBetas20191216.dta", replace


clear
set more off

args FirmGroupNum

* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
global path "/home/acct/szho/Disclosure"
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 

global rawdata "${path}/rawdatanew"
global data "${path}/datanew"
global dofile "${path}/analysis"
global output "${path}/output"

forvalues i=1(1)`FirmGroupNum'{

	shell rm "${data}/temp_FactorBetas_Group`i'.dta"

}

cd "${dofile}"
shell rm "FactorBeta_"*
shell rm "${data}/temp_FactorBetasStartFile.dta"

********************************************************************************
* This file creates two files regarding the return for a size portfolio. 

* The input files are: ME_Breakpoints.csv (size portfolio cut-off points by month
* and 5 percent increment), Portfolios_Formed_on_ME_daily.csv (daily size portfolio
* return. 

* Method:
* We use value weighted return of three portfolios formed based on market value of equity. 

* The output files are:
* DailySize.dta: **daily** value weighted return of three size-portfolios. 
* SizeCut.dta: **monthly** cut-off points for the three size-portfilios. 

* How the output files are used:
* First, each vector of the three daily size portfolio returns is matched to the corresponding 
* daily return file. 
* Second, each vector of the two monthly cut-off points will be matched to the month prior
* to the most recent earnings announcement, that is, prior to the month of the beginning of the
* cumulative return measurement window. For example, if earnings are announced on April 15th, 2015,
* the cut-off points will be chosen to be March, 2015. 

********************************************************************************


// global rawdata "C:/Users/yuzhou/Dropbox/Disclosure/rawdatanew"
// global data "C:/Users/yuzhou/Dropbox/Disclosure/datanew"
// global dofile "C:/Users/yuzhou/Dropbox/Disclosure/analysis"
// global output "C:/Users/yuzhou/Dropbox/Disclosure/output"



global rawdata "/Users/szho/Dropbox/My Projects/Disclosure/rawdatanew"
global data "/Users/szho/Dropbox/My Projects/Disclosure/datafinal"
global dofile "/Users/szho/Dropbox/My Projects/Disclosure/analysis/20191216/03 Factor and Size"
global output "/Users/szho/Dropbox/My Projects/Disclosure/output"


********************************************************************************

capture log close
capture log using "${dofile}/SizeAdjustment20191206.log", replace
********************************************************************************
* Value weighted daily 3-size portfolio returns. 
********************************************************************************


import delimited "${rawdata}/Portfolios_Formed_on_ME_daily_vw20181204.csv", clear

tostring date, replace format(%20.0f)
gen date1 = date(date, "YMD")
format date1 %td
drop date
rename date1 date

keep date lo30 med40 hi30
label variable lo30 "Daily (value weighted) return for firms whose size belongs to the lower 30%"
label variable med40 "Daily (value weighted) return for firms whose size belongs to 30%-70%"
label variable hi30 "Daily (value weighted) return for firms whose size belongs to the upper 30%"

sort date
keep if date!=.

capture saveold "${data}/DailySize20191216.dta", replace version(12)

********************************************************************************
* Montly cut-offs for the 3-size portfolios. 
* The cut-off points are price times the number of shares outstanding from 5% to 100%. 
* The unit is 1,000,000. 
********************************************************************************

import delimited "${rawdata}/ME_Breakpoints.csv", clear

tostring v1, replace format(%20.0f)
gen date = date(v1, "YM")

gen year = year(date)
gen month = month(date)

rename v8 cut30
label variable cut30 "30% size"
rename v16 cut70
label variable cut70 "70% size"

keep year month cut30 cut70
sort year month

capture saveold "${data}/SizeCut20191216.dta", replace version(12)

capture log close


/*

This file computes cumulative stock returns and EA returns and combines the control variables

Input data:
	- GUIDECCM20191216.dta, created by quarterly_ols_sample_construction20191216
	- crspdateprice_bundled_20191216.dta, created by quarterly_ols_sample_construction20191216
	- Controls20191216, created by Controls20191216.sas
	- FactorsRF19260701to20181031_20181204.dta (download)
	- rdq_ibes20191216.dta
	- SizeCut20191216.dta
	- DailySize20191216.dta
	- FactorBetas20191216.dta
	
Output data:
	- final_EPS_2.dta
	- final_EPS_20191216_2.dta

*/




*ssc install use13
clear
clear matrix
clear mata
set mem 3000m
set maxvar 20000
set matsize 10000

set more off
* cd "C:/Users/Yuqing Zhou/Dropbox/Disclosure" 


* global path "/Users/Frank/Dropbox/My Projects/Disclosure"
 global path "/Users/szho/Dropbox/My Projects/Disclosure"
* global path "C:/Users/yuzhou/Dropbox/Disclosure" 
* global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure"
* global path "/home/acct/szho/Disclosure"

global rawdata "${path}/rawdatanew"
global data "${path}/datafinal"
global dofile "${path}/analysis"
global output "${path}/output"

capture log close
log using "${dofile}/20191216/06 Merge/limited_strategic_thinking20191216.log", replace 

***************************
* DO NOT USE FORWARD SLASH IN FILE NAMES!
****************************




******************************
* Step 1: Guidance data  

* The master file is guidance data -- GUIDECCM20191216, 
* produced by quarterly_ols_sample_construction20191216.sas.


******************************
* Step I: Seperate earnings guidance data 
******************************


***** 1.1 Data cleaning:
use "${data}/GUIDECCM20191216.dta", clear

* We drop observations of 2015, because we don't have stock return data.
drop if rdq +90 >= mdy(12,31,2017) 
count
*13,115

**1.1.1 Pre-announcements.

capture drop preannounce

gen day = 31 if guide == 1
replace day = 30 if prd_mon == 4 | prd_mon == 6 | prd_mon == 9 | prd_mon == 11
replace day = 28 if prd_mon == 2 & mod(prd_yr,4) != 0
replace day = 29 if prd_mon == 2 & mod(prd_yr,4) == 0

gen ForecastDate = mdy(prd_mon, day, prd_yr)
label variable ForecastDate "Target date of a management forecast"
format ForecastDate %td
drop day

rename anndats anndats_manager
gen preannounce = (anndats_manager >= datadateq & ForecastDate <= datadateq) | (anndats_manager < datadateq & ForecastDate <= datadateqlag)
replace preannounce = . if guide != 1 | anndats_manager ==.



** 1.1.2 The existence of bundled forecasts in the current quarter or the previous quarter.

preserve

sort permno datadateq 
gen bundle = anndats >=rdqlag-1 & anndats <= rdqlag+1

by permno datadateq: egen BundleCurrentQ = total(bundle)
replace BundleCurrentQ = BundleCurrentQ > 0
replace BundleCurrentQ =. if guide == 0

// define the existence of nonbundle disclosure
gen nonbundle = anndats > rdqlag+1 & anndats !=.
by permno datadateq: egen NonBundleCurrentQ = total(nonbundle)
replace NonBundleCurrentQ = NonBundleCurrentQ > 0
replace NonBundleCurrentQ =. if guide == 0

// generate bundle varaible by only using EPS measure
gen bundle_EPS = bundle
replace bundle_EPS = 0 if measure != "EPS"

by permno datadateq: egen BundleCurrentQ_EPS = total(bundle_EPS)
replace BundleCurrentQ_EPS = BundleCurrentQ_EPS > 0
replace BundleCurrentQ_EPS =. if guide == 0

gen nonbundle_EPS = nonbundle
replace nonbundle_EPS = 0 if measure != "EPS"

by permno datadateq: egen NonBundleCurrentQ_EPS = total(nonbundle_EPS)
replace NonBundleCurrentQ_EPS = NonBundleCurrentQ_EPS > 0
replace NonBundleCurrentQ_EPS =. if guide == 0


keep permno datadateq Bundle* NonBundle*
duplicates drop permno datadateq, force

sort permno datadateq
gen BundleLastQ = BundleCurrentQ[_n-1] if permno == permno[_n-1]
gen BundleNextQ = BundleCurrentQ[_n+1] if permno == permno[_n+1]
label variable BundleCurrentQ "Existence of a bundled forecast the current quarter"
label variable BundleLastQ "Existence of a bundled forecast the previous quarter"
label variable BundleNextQ "Existence of a bundled forecast the following quarter"

gen NonBundleLastQ = NonBundleCurrentQ[_n-1] if permno == permno[_n-1]
gen NonBundleNextQ = NonBundleCurrentQ[_n+1] if permno == permno[_n+1]
label variable NonBundleCurrentQ "Existence of a nonbundled forecast the current quarter"
label variable NonBundleLastQ "Existence of a nonbundled forecast the previous quarter"
label variable NonBundleNextQ "Existence of a nonbundled forecast the following quarter"

gen BundleLastQ_EPS = BundleCurrentQ_EPS[_n-1] if permno == permno[_n-1]
gen BundleNextQ_EPS = BundleCurrentQ_EPS[_n+1] if permno == permno[_n+1]
label variable BundleCurrentQ_EPS "Existence of a bundled forecast the current quarter: EPS"
label variable BundleLastQ_EPS "Existence of a bundled forecast the previous quarter: EPS"
label variable BundleNextQ_EPS "Existence of a bundled forecast the following quarter: EPS"

gen NonBundleLastQ_EPS = NonBundleCurrentQ_EPS[_n-1] if permno == permno[_n-1]
gen NonBundleNextQ_EPS = NonBundleCurrentQ_EPS[_n+1] if permno == permno[_n+1]
label variable NonBundleCurrentQ_EPS "Existence of a nonbundled forecast the current quarter: EPS"
label variable NonBundleLastQ_EPS "Existence of a nonbundled forecast the previous quarter: EPS"
label variable NonBundleNextQ_EPS "Existence of a nonbundled forecast the following quarter: EPS"


keep permno datadateq Bundle* NonBundle*
duplicates drop permno datadateq, force

save "${data}/temp_bundle.dta", replace

restore

sort permno datadateq
merge m:1 permno datadateq using "${data}/temp_bundle.dta"
drop _merge



*** 1.1.3 Keep earnings per share related measures
/*
EPS: Earnings per share
EBS: EBITDA per share
EBT: EBITDA
GPS: Fully reported earnings per share   
NET: Net income
PRE: Pre-tax income
ROA: Return on Assets
ROE: Return on Equity
*/

** Forecast measure, important to keep guide == 0. 

keep if measure == "EPS" | measure == "EBS" | measure == "EBT" | measure == "GPS" | ///
measure == "NET" | measure == "PRE" | measure == "ROA" | measure == "ROE" | guide == 0

count
* 243,028

** Keep the earliest management forecast for each firm quarter

* Pre-announcements "typically" happen after datadateq, so they are likely to be dropped. 
* However, if rdqlag >= datadateq, last period earnings announcement date occurs after current datadateq,
* pre-announcements will be the first observation. 
* Because the nature of preannouncements is likely to be different from other forecasts, we keep one preannouncement
* and one regular forecast. 

sort permno datadateq preannounce anndats_manager
drop if preannounce == 1   
count

sort permno datadateq anndats_manager
by permno datadateq: gen index = _n==1
keep if index == 1
drop index

** Redefine nonguidance sample based on the point that 60 days after rdqlag
gen disclose_dif = anndats_manager - rdqlag
gen nonguide_60 = (disclose_dif == . | disclose_dif >60)

* Adjust earnings announcement date
sort permno datadateq
merge 1:1 permno datadateq using "${data}/rdq_ibes20191216.dta"
drop if _merge ==2
drop _merge

destring hour, replace
gen rdq1 = rdq
replace rdq1=rdq+1 if hour >= 16 & hour!=. & rdq == rdq_new

saveold "${data}/GUIDECCM20191216_EPS.dta", replace

count
* 127,541 observations















******************************
* Step 3: Merge with CRSP data (crspdateprice_bundled_20191216)
* and then generate cmulative return variables and earnings surprise. 
******************************

use "${data}/GUIDECCM20191216_EPS", clear


** 3.1. Merge stock return data 
 
sort permno datadateq
merge 1:m permno datadateq using "${data}/crspdateprice_bundled_20191216.dta"  
 keep if _merge==3
drop _merge



******************************************
* 3.2. Obtain factor returns and factor loadings
******************************************

* 3.3.1 Obtain factor returns

sort date
merge m:1 date using "${rawdata}/FactorsRF19260701to20181031_20181204.dta", keep(3) nogen

* 3.3.2 Obtain factor loadings generated by previous quarter stock returns. 

sort permno rdqlag
merge m:1 permno rdqlag using "${data}/FactorBetas20191216.dta"
drop if _merge == 2
drop _merge

* 3.3.3 Obtain factor loadings generated by next quarter stock returns.

preserve

use "${data}/FactorBetas20191216.dta", clear
gen rdq = rdq[_n-2] if permno == permno[_n-2] //  so rdq is two quarters before the factor loading. 

drop rdqlag
drop if rdq ==.

sort permno rdq
foreach var of varlist BetaMkt BetaSMB BetaHML BetaMom{
	rename `var' `var'Qplus2
}
save "${data}/tempFactorsQplus2.dta", replace

restore

sort permno rdq
merge m:1 permno rdq using "${data}/tempFactorsQplus2.dta"
drop if _merge == 2
drop _merge

* 3.3.3 Generate market adjusted return and four factor adjusted return

gen retFctAdj = ret - rf - BetaMkt*mktrf - BetaSMB*smb - BetaHML*hml - BetaMom*umd
label variable retFctAdj "4 Factor adjusted stock return"

gen retFctAdjQplus2 = ret - rf - BetaMktQplus2*mktrf - BetaSMBQplus2*smb - BetaHMLQplus2*hml - BetaMomQplus2*umd
label variable retFctAdj "4 Factor adjusted stock return using quarter t+2 stock return"

gen retFctAdjChange = retFctAdj
replace retFctAdjChange = retFctAdjQplus2 if date >= rdq



******************************************
* 3.4 Obtain size adjusted stock return. 
******************************************
* 3.4.1 Obtain daily size portfolio return.

* DailySize.dta, generated from SizeAdjustment, contains value weighted 3-size portfolio returns.

sort date
merge m:1 date using "${data}/DailySize20191216.dta"
drop if _merge == 2
drop _merge
* All merged, results the same as prior do file version, disclosure_new_20160412_copy.do.  
count if lo30==.

* 3.4.2 Find size cut-off for each firm at the end of each June.
* We use June, because size portfolio returns are computed using size cut-offs
* formed in June each year. The sorting will be valid until the next June. 
* Therefore, later when we merge this data back to the guidance data,
* for return prior to June 30th, we merge back to previous year,
* for return after June 30th, we merge to the current year. 
* For example, the size category of daily return on 2014.04.15 (variable name, ret)
* should be based on its size of 2013.06.30. 

* We first find the market value of equity at the end of June of each year
* see http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/det_port_form_sz.html. 

* Note that not all firms have June stock returns. 
* One reason is:
* These firms only start to exist in the data after June. Then these firms won't be matched
* with a size portfolio until June of the next year.  
* Another reason is:
* These firms do not trade in June. For example, permno == 32687, year == 2005. 

preserve

use "${data}/crspdateprice_bundled_20191216.dta", clear

* keep June.
gen month = month(date)
keep if month == 6
gen mkv = abs(prc*shrout)/1000
drop if mkv == .

* keep the last observation of each June.
gen year = year(date)
sort permno year date
by permno year: gen nvals = _n == _N
keep if nvals == 1
drop nvals

* merge ${data}/SizeCut.dta

sort year month
merge m:1 year month using "${data}/SizeCut20191216.dta", nogen keep(1 3)
* ${data}/SizeCut.dta, generated from SizeAdjustment, contains monthly cut-offs 
* for the 3-size portfolios. 

* Here SizeTercile indicates where a firm's equity at the end of June falls into 
* the cut-offs computed by French. 

gen SizeTercile = 1
replace SizeTercile = 2 if mkv > cut30 & mkv <= cut70
replace SizeTercile = 3 if mkv > cut70

keep permno year SizeTercile
duplicates drop permno year, force

rename year year_size
sort permno year_size

capture saveold "${data}/temp_SizeTercile", replace version(12)

restore


gen year_size = year(date)
gen month_size = month(date)

replace year_size = year_size - 1 if month_size <7

sort permno year_size
merge m:1 permno year_size using "${data}/temp_SizeTercile"
drop if _merge == 2
drop _merge year_size month_size

* 3.4.3 Find size portfolio return

gen SizeRet = .
replace SizeRet = lo30 if SizeTercile == 1
replace SizeRet = med40 if SizeTercile == 2
replace SizeRet = hi30 if SizeTercile == 3

drop lo30 med40 hi30 SizeTercile

* 3.4.4 Compute size adjusted return (different from previous version)

gen retSizeAdj = ret - SizeRet/100
label variable retSizeAdj "size adjusted log stock return"



******************************************
* 3.5 Create trading date calendar
******************************************

preserve 

use "${rawdata}/FactorsRF19260701to20181031_20181204.dta",clear

keep if date>=mdy(01,01,2000)
bcal create crsp, from(date) generate(tradedate) replace
bcal dir

restore


* Change rdqlag to business calendar format, and adjust weekend announcement to
* the most recent trading date

generate rdqlag2 = bofd("crsp", rdqlag)
format rdqlag2 %tbcrsp:CCYY.NN.DD

forvalues d=1(1)4{

	gen nvals = rdqlag + `d'
	replace nvals = bofd("crsp", nvals)
	
	replace rdqlag2 = nvals if rdqlag2 ==. & nvals !=.
	drop nvals
}


generate rdq2 = bofd("crsp", rdq1)
format rdq2 %tbcrsp:CCYY.NN.DD

generate WeekDayRDQ = rdq2 !=. 

forvalues d=1(1)4{

	gen nvals = rdq1 + `d'
	replace nvals = bofd("crsp", nvals)
	
	replace rdq2 = nvals if rdq2 ==. & nvals !=.
	drop nvals
}

* Change date to business calendar format

generate date2 = bofd("crsp", date)
format date2 %tbcrsp:CCYY.NN.DD

bcal describe crsp
bcal check








******************************************
* Generate long term returns
******************************************

sort permno rdq2 date2

foreach i in 20 40 60{
by permno rdq2: egen CumRetSizeAdj`i'After = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetSizeAdj`i'After = exp(CumRetSizeAdj`i'After) - 1
by permno rdq2: egen CumRetSizeAdj`i'After2 = mean(CumRetSizeAdj`i'After)
replace CumRetSizeAdj`i'After = CumRetSizeAdj`i'After2
drop CumRetSizeAdj`i'After2
} 


capture saveold "${data}/final_EPS_2.dta", replace version(12)



******************************************
* 3.6. Generate cumulative return by using "ret"
******************************************


*****
* Restrict window to improve speed
keep if date2>=rdq2-25 & date2<=rdq2+11 
*****

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRet`i' = total( log( 1 + ret ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRet`i' = exp( CumRet`i' ) - 1
by permno rdq2: egen CumRet`i'2 = mean(CumRet`i')
replace CumRet`i' = CumRet`i'2
drop CumRet`i'2
}

foreach i in 5{
by permno rdq2: egen CumRet`i'After = total( log( 1 + ret ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRet`i'After = exp(CumRet`i'After) - 1
by permno rdq2: egen CumRet`i'After2 = mean(CumRet`i'After)
replace CumRet`i'After = CumRet`i'After2
drop CumRet`i'After2
} 

* Missing CumRet: Missing return means that we do not have return info for the
* first observation in the return measurement window, [-25,+5]. 

gen RetWindow = date2 >= rdq2 -25 & date2 <= rdq2 + 10
sort permno rdq2 RetWindow date2
by permno rdq2 RetWindow: gen ObsFirst = _n == 1 if RetWindow == 1
count if ObsFirst ==. & RetWindow == 1 // should be zero

saveold "${data}/temp_temp.dta", replace





************************************
* Cumulative size adjusted stock return
************************************

sort permno rdq2 date2

forvalues i=1(1)11{
by permno rdq2: egen CumRetSizeAdj`i' = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetSizeAdj`i' = exp(CumRetSizeAdj`i') - 1
by permno rdq2: egen CumRetSizeAdj`i'2 = mean(CumRetSizeAdj`i')
replace CumRetSizeAdj`i' = CumRetSizeAdj`i'2
drop CumRetSizeAdj`i'2
}
forvalues i=0(1)10{
by permno rdq2: egen CumRetSizeAdj`i'After = total( log( 1 + retSizeAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetSizeAdj`i'After = exp(CumRetSizeAdj`i'After) - 1
by permno rdq2: egen CumRetSizeAdj`i'After2 = mean(CumRetSizeAdj`i'After)
replace CumRetSizeAdj`i'After = CumRetSizeAdj`i'After2
drop CumRetSizeAdj`i'After2
} 

saveold "${data}/temp_temp.dta", replace


************************************
* Cumulative 4 factor adjusted stock return
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdj`i' = total( log( 1 + retFctAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdj`i' = exp(CumRetFctAdj`i') - 1
by permno rdq2: egen CumRetFctAdj`i'2 = mean(CumRetFctAdj`i')
replace CumRetFctAdj`i' = CumRetFctAdj`i'2
drop CumRetFctAdj`i'2
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdj`i'After = total( log( 1 + retFctAdj ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdj`i'After = exp(CumRetFctAdj`i'After) - 1
by permno rdq2: egen CumRetFctAdj`i'After2 = mean(CumRetFctAdj`i'After)
replace CumRetFctAdj`i'After = CumRetFctAdj`i'After2
drop CumRetFctAdj`i'After2
} 

saveold "${data}/temp_temp.dta", replace

************************************
* Cumulative 4 factor adjusted stock returns that use t+2 information for factor loading.
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdj`i'Qplus2 = total( log( 1 + retFctAdjQplus2 ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdj`i'Qplus2 = exp(CumRetFctAdj`i'Qplus2) - 1
by permno rdq2: egen CumRetFctAdj`i'Qplus22 = mean(CumRetFctAdj`i'Qplus2)
replace CumRetFctAdj`i'Qplus2 = CumRetFctAdj`i'Qplus22
drop CumRetFctAdj`i'Qplus22
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdj`i'Qplus2After = total( log( 1 + retFctAdjQplus2 ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdj`i'Qplus2After = exp(CumRetFctAdj`i'Qplus2After) - 1
by permno rdq2: egen CumRetFctAdj`i'Qplus2After2 = mean(CumRetFctAdj`i'Qplus2After)
replace CumRetFctAdj`i'Qplus2After = CumRetFctAdj`i'Qplus2After2
drop CumRetFctAdj`i'Qplus2After2
} 

saveold "${data}/temp_temp.dta", replace


************************************
* Cumulative 4 factor adjusted stock returns that use t+2 information for factor loading for date >= rdq.
************************************

sort permno rdq2 date2

foreach i in 3{
by permno rdq2: egen CumRetFctAdjChange`i' = total( log( 1 + retFctAdjChange ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 - `i'
replace CumRetFctAdjChange`i' = exp(CumRetFctAdjChange`i') - 1
by permno rdq2: egen CumRetFctAdjChange`i'2 = mean(CumRetFctAdjChange`i')
replace CumRetFctAdjChange`i' = CumRetFctAdjChange`i'2
drop CumRetFctAdjChange`i'2
}
foreach i in 5{
by permno rdq2: egen CumRetFctAdjChange`i'After = total( log( 1 + retFctAdjChange ) ) if date2 >= rdqlag2 + 5 & date2 <= rdq2 + `i'
replace CumRetFctAdjChange`i'After = exp(CumRetFctAdjChange`i'After) - 1
by permno rdq2: egen CumRetFctAdjChange`i'After2 = mean(CumRetFctAdjChange`i'After)
replace CumRetFctAdjChange`i'After = CumRetFctAdjChange`i'After2
drop CumRetFctAdjChange`i'After2
} 

saveold "${data}/temp_temp.dta", replace

* 3.7. Generate bid ask spread 

sort permno rdq2 date2

gen BDSpread = ( ask - bid ) / abs(prc)
forvalues i=2(1)2{
by permno rdq2: gen nvals = _n  if date2 >= rdqlag2 + 5 & date2 >= rdq2 -`i' - 5 & date2 <= rdq2 - `i' & BDSpread !=.
replace nvals = 0 if nvals ==.
by permno rdq2: egen nvals1 = max( nvals )
gen nvals2 = .
replace nvals2 = BDSpread if nvals1 == nvals & nvals1 !=0
by permno rdq2: egen BDSpread`i' = mean(nvals2)
replace BDSpread`i' = . if nvals1 == 0
drop nvals*
}

forvalues i=5(1)5{
by permno rdq2: gen nvals = _n  if date2 >= rdqlag2 + 5 & date2 >= rdq2 + `i' - 5 & date2 <= rdq2 + `i'
replace nvals = 0 if nvals ==.
by permno rdq2: egen nvals1 = max( nvals )
gen nvals2 = .
replace nvals2 = BDSpread if nvals1 == nvals & nvals1 !=0
by permno rdq2: egen BDSpread`i'After = mean(nvals2)
replace BDSpread`i'After = . if nvals1 == 0
drop nvals*
} 

drop BDSpread


**** Adjust missing return. 

sort permno rdq2 date2

capture drop Miss*
capture drop afterwindow
capture drop totalafterwindow
capture drop beforewindow
capture drop totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & ret !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & ret !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRet = (totalafterwindow <5 | totalbeforewindow <20) 

* Size Adjusted

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retSizeAdj !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retSizeAdj !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetSizeAdj1 = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdj !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdj !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdj = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted qplus2

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdjQplus2 !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdjQplus2 !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdjQplus2 = (totalafterwindow <5 | totalbeforewindow <20)

* Factor adjusted change

capture drop afterwindow totalafterwindow beforewindow totalbeforewindow

gen afterwindow = (date2 >= rdq2 & date2 <= rdq2+10 & date2 >= rdqlag2 +5 & retFctAdjChange !=.)
by permno rdq2: egen totalafterwindow = total(afterwindow)

gen beforewindow = (date2 >= rdq2-25 & date2 < rdq2 & date2 >= rdqlag2 +5 & retFctAdjChange !=.)
by permno rdq2: egen totalbeforewindow = total(beforewindow)

gen MissCumRetFctAdjChange = (totalafterwindow <5 | totalbeforewindow <20)







******************************
* Step 4: Generate other control variables 
******************************

duplicates drop permno rdq, force
sort permno datadateq


// 4.1 control to include in the main regressions

* Variables ending in quarter q
preserve
use "${data}/Controls20191216.dta", clear
rename cqretvol ret_vola
rename ncurrentanalyst NumAnalys
rename mtb market_book
rename qeih InstPct
rename earnsurp_epspxq EarnSurp_epspxq
cap rename datadate datadateq
keep permno datadateq ret_vola NumAnalys market_book InstPct EarnSurp_epspxq
save "${data}/tempq0.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq0.dta", nogen keep(1 3)





* Variables ending in quarter q-1
preserve
use "${data}/tempq0.dta", clear
rename datadateq datadateq0
sort permno datadateq0
by permno: gen datadateq=datadateq0[_n+1]
foreach var of varlist ret_vola NumAnalys market_book InstPct EarnSurp_epspxq{
	rename `var' `var'_lag
}
keep if datadateq!=.
sort permno datadateq
save "${data}/tempq1.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq1.dta", nogen keep(1 3)






* Variables ending in quarter q+1
preserve
use "${data}/tempq0.dta", clear
rename datadateq datadateq0
sort permno datadateq0
by permno: gen datadateq=datadateq0[_n-1]
foreach var of varlist ret_vola NumAnalys market_book InstPct EarnSurp_epspxq{
	rename `var' `var'NextQ
}
keep if datadateq!=.
sort permno datadateq
save "${data}/tempq1.dta", replace
restore
merge 1:1 permno datadateq using "${data}/tempq1.dta", nogen keep(1 3)



* Create controls
foreach var of varlist ret_vola NumAnalys {
	gen `var'_change = `var'NextQ - `var'
}
foreach var of varlist market_book InstPct {
	gen `var'_change = `var' - `var'_lag
}


* Generate additional variables
gen nonguide=(guide==0)
gen year = year(datadateq)
gen quarter = quarter(datadateq)

local num = "5"
foreach i in `num'{
	gen BDSpread_change`i' = BDSpread`i'After - BDSpread2
}




* 4.2 News prediction variables for Table 
preserve

use "${data}/Controls20191216.dta", clear
gen datadateq = datadate
sort permno datadateq
keep permno datadateq atqlag cqroaavg cqroaavg_oiadpq sic
save "${data}/tempatqlag.dta", replace


use "${data}/Controls20191216.dta", clear

sort permno datadate
gen datadatef = datadate[_n+1] if permno == permno[_n+1]
drop datadate
rename datadatef datadateq
sort permno datadateq
duplicates drop permno datadateq, force 
keep permno datadateq cqroaavg cqroaavg_oiadpq leverage cqmaret

save "${data}/temproalag.dta", replace

restore

sort permno datadateq
merge 1:1 permno datadateq using "${data}/temproalag.dta", nogen keep(1 3)
rename cqroaavg pqroaavg
rename cqroaavg_oiadpq pqroaavg_oiadpq 
rename cqmaret pqmaret
merge 1:1 permno datadateq using "${data}/tempatqlag.dta", nogen keep(1 3)


gen logatqlag = log(1+atqlag)
destring sic, replace
gen sic2d = floor(sic/100)

capture saveold "${data}/final_EPS_20191216_2.dta", replace version(12)


log close





/********************************************************************************
This file creates the regression sample for our main results. 

Input data:
	- final_EPS_20191206_2.dta
	- final_EPS_2.dta
	- CRSP_Compustat_Merged_LinkingTable.dta
	- RavenPack20181110/rp20020101to20171231_20181210.dta
	- markit_bc20181110.dta

Output data:
	- /CalendarTrading_DisclosureData_20191216.dta
	- final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta
	
********************************************************************************/

// global path "/Users/Frank/Dropbox/My Projects/Disclosure"
* global path "/Users/szho/Dropbox/My Projects/Disclosure"
* global path "C:/Users/zhouy/Dropbox/Disclosure"
 global path "C:/Users/Yuqing Zhou/Dropbox/Disclosure"
// global path "/home/acct/szho/Disclosure"

global rawdata "${path}/rawdatanew"
global data "${path}/datafinal"
global dofile "${path}/analysis/07 Merge"
global output "${path}/output"

********************************************************************************

capture log close 
*log using "${dofile}/regsample20191216.log", replace
set more off

********************************************************************************

* Create data needed for the main results


********************************************************************
* Calendar trading disclosure data
********************************************************************

use "${data}/GUIDECCM20191216.dta", clear

drop if rdq +90 >= mdy(12,31,2017) 
count
*13,115 dropped 

** Pre-announcements
gen day = 31 if guide == 1
replace day = 30 if prd_mon == 4 | prd_mon == 6 | prd_mon == 9 | prd_mon == 11
replace day = 28 if prd_mon == 2 & mod(prd_yr,4) != 0
replace day = 29 if prd_mon == 2 & mod(prd_yr,4) == 0
gen ForecastDate = mdy(prd_mon, day, prd_yr)
label variable ForecastDate "Target date of a management forecast"
format ForecastDate %td
drop day

rename anndats anndats_manager
gen preannounce = (anndats_manager >= datadateq & ForecastDate <= datadateq) | (anndats_manager < datadateq & ForecastDate <= datadateqlag)
replace preannounce = . if guide != 1 | anndats_manager ==.

*** Keep earnings per share related measures
/*
EPS: Earnings per share
EBS: EBITDA per share
EBT: EBITDA
GPS: Fully reported earnings per share   
NET: Net income
PRE: Pre-tax income
ROA: Return on Assets
ROE: Return on Equity
*/

** Forecast measure, important to keep guide == 0. 
keep if measure == "EPS" | measure == "EBS" | measure == "EBT" | measure == "GPS" | ///
measure == "NET" | measure == "PRE" | measure == "ROA" | measure == "ROE" | guide == 0

count

sort permno datadateq preannounce anndats_manager
keep if anndats_manager !=. & preannounce != 1
keep permno datadateq anndats_manager rdq
 
saveold "${data}/CalendarTrading_DisclosureData_20191216.dta", replace version(12)















********************************************************************************
* Step 1: Generate regression sample
********************************************************************************




use "${data}/final_EPS_20191216_2.dta", clear
set more off

********************************************************************************
* Define main sample
********************************************************************************

** Winsorizations of the main controls
macro define ChangeControl "EarnSurp_epspxq EarnSurp_epspxq_lag ret_vola_change market_book_change NumAnalys_change InstPct_change"
foreach var of varlist $ChangeControl BDSpread_change5{ 
	winsor2 `var', cut(1 99) replace
}




** Generate change in return
sort permno rdq
forvalue i=3(1)3{
	rename CumRetFctAdj`i'Qplus2 CumRetFctAdjQplus2`i'
}

forvalue i=5(1)5{
	rename CumRetFctAdj`i'Qplus2After CumRetFctAdjQplus2`i'After
}

macro define depvar "CumRetSizeAdj"
foreach var in $depvar {
    gen Delta`var'10 = ( (1+`var'10After)/(1+`var'3)-1 )*100
	gen Delta`var'5 = ( (1+`var'5After)/(1+`var'3)-1 )*100
	gen Delta`var'2 = ( (1+`var'2After)/(1+`var'3)-1 )*100
	gen Delta`var'5bf5af = ( (1+`var'5After)/(1+`var'6)-1 )*100
	gen Delta`var'10bf5af = ( (1+`var'5After)/(1+`var'11)-1 )*100
	*gen Delta`var'5bf1bf = ( (1+`var'1)/(1+`var'6)-1 )*100
	gen Delta`var'0bf0af = ( (1+`var'0After)/(1+`var'1)-1 )*100
}
macro define depvar "CumRet CumRetSizeAdj CumRetFctAdj CumRetFctAdjChange CumRetFctAdjQplus2"
foreach var in $depvar {
	cap gen Delta`var'5 = ( (1+`var'5After)/(1+`var'3)-1 )*100
}

macro define depvar "CumRetSizeAdj"
foreach var in $depvar{

    quietly sum Delta`var'10,d
	gen OutLierDelta`var'10 = Delta`var'10 >= r(p99) | Delta`var'10 < r(p1)
	
	quietly sum Delta`var'5,d
	gen OutLierDelta`var'5 = Delta`var'5 >= r(p99) | Delta`var'5 < r(p1)
	
	quietly sum Delta`var'2,d
	gen OutLierDelta`var'2 = Delta`var'2 >= r(p99) | Delta`var'2 < r(p1)
			
}




* Keep regression sample
macro define variable "BDSpread_change"
keep if OutLierDeltaCumRetSizeAdj5 == 0 & MissCumRetSizeAdj == 0
reg DeltaCumRetSizeAdj5 ${variable}5 $ChangeControl if OutLierDeltaCumRetSizeAdj5 == 0 & MissCumRetSizeAdj == 0, r 
// This step results in a slight change in the number of observations between version 1204, which does not require lagged earnings surprise,
// and this version of the data, namely 0711. 
keep if e(sample)

















********************************************************************************
* Merge in other variables: factor returns, xs variables, additional variables
********************************************************************************

** Factor returns
preserve

use "${data}/final_EPS_2.dta", clear
sort permno rdq date2
keep permno rdq rdq2 date2 smb mktrf rf hml umd
gen deltardq = date2 - rdq2
keep if deltardq >=-2 & deltardq <=5
foreach var of varlist smb mktrf rf hml umd{
	bys permno rdq: egen Cum`var' = total(log(1+`var'))
	replace Cum`var' = (exp(Cum`var')-1)*100
}
duplicates drop permno rdq, force
keep permno rdq Cum*
sort permno rdq
save "${data}/temp_cumfactor.dta", replace
restore

merge 1:1 permno rdq using "${data}/temp_cumfactor.dta", nogen keep(1 3)
















** Earnings announcement premium
preserve

use "${data}/final_EPS_2.dta", clear
sort permno rdq date2
keep if date2 >= rdq2 - 5 & date2 <= rdq2
macro define depvar "CumRetSizeAdj CumRetFctAdj CumRetFctAdjChange CumRetFctAdjQplus2"
foreach var in $depvar{
	by permno rdq: egen  Delta`var'5bf0af = total( log( 1 + ret ) ) 
	replace Delta`var'5bf0af = (exp(Delta`var'5bf0af)-1)*100
} 
keep permno rdq Delta*
duplicates drop permno rdq, force
sort permno rdq
save "${data}/temp_5bf0af.dta", replace

restore
merge 1:1 permno rdq using "${data}/temp_5bf0af.dta", nogen keep(1 3)
















** News data

preserve

// Prepare for linking table
use "${rawdata}/CRSP_Compustat_Merged_LinkingTable.dta", clear
duplicates drop conm, force
keep gvkey cusip lpermno
sort gvkey
save "${data}/temp_CRSP_Compustat_Merged_LinkingTable.dta", replace

restore

// Prepare for the news data
preserve

use "${rawdata}/RavenPack20181110/rp20020101to20171231_20181210.dta", clear

* drop observations with duplicated cusip 
keep entity_name country_code isin
duplicates drop isin, force
gen cusip = substr(isin,3,9)
sort cusip
by cusip: gen id = _N
drop if id > 1
drop id
save "${data}/RP_isin.dta", replace

restore


preserve

use "${rawdata}/RavenPack20181110/rp20020101to20171231_20181210.dta", clear

keep rpna_date_utc entity_name country_code relevance news_type isin
gen cusip = substr(isin,3,9)
sort cusip
merge m:1 cusip using "${data}/RP_isin.dta"
keep if _merge == 3
drop _merge

drop if cusip == ""

* keep observations with valid cusip 
merge m:1 cusip using "${data}/temp_CRSP_Compustat_Merged_LinkingTable.dta"
keep if _merge == 3  // most of US firms are matched
drop _merge
rename lpermno permno
saveold "${data}/RP_news.dta", version(12) replace


// Preprare for the matching data 
use "${data}/final_EPS_20191216_2.dta", clear
keep permno rdq rdqlag rdqf
saveold "${data}/temp_permno_final_EPS_20191216_2.dta", version(12) replace


*** run sasfile: RP_merge  (save RP_news_merge.dta)
*ssc install saswrapper, replace
saswrapper using "${dofile}/RP_merge.sas", nodata clear 
* Merge news data with firm rdq
restore


preserve
// Generate useful news coverage variables for each firm quarter
use "${data}/RP_news_merge.dta", clear
bysort permno rdq: gen num_news = _N

gen rele = (relevance >= 90)
bysort permno rdq: egen num_news_90 = sum(rele)

duplicates drop permno rdq, force

keep permno rdq num_news num_news_90 

save "${data}/temp_RP_news_merge.dta", replace
restore


// Merge news data with the final regression data
merge 1:1 permno rdq using "${data}/temp_RP_news_merge.dta"
gen news = (_merge == 3)
gen news_90 = (_merge == 3 & num_news_90 > 0)

replace num_news = 0 if num_news ==.
replace num_news_90 = 0 if num_news_90 ==.

sort permno rdq
by permno: gen num_news_lag = num_news[_n-1]
by permno: gen num_news_90_lag = num_news_90[_n-1]

drop if _merge ==2
drop _merge











**Short selling constraints

preserve

use "${data}/markit_bc20191216.dta", clear
gen yq=yq(year,quarter)
replace yq=yq+1
sort permno yq
keep permno yq indicativefee indicativerebate utilisation dcbs
save "${data}/temp_markit_bc.dta", replace

restore

gen yq=yq(year,quarter)
sort permno yq

merge m:1 permno yq using "${data}/temp_markit_bc.dta", keep(1 3) nogen // do not replace missing trading cost vars.
*replace putvol = 0 if putvol ==. // replace option trading to zero if not matched. 


save "${data}/final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta", replace









// guidance history

sort permno rdq
by permno: gen PastNG = sum( nonguide )
replace PastNG = PastNG - 1 if nonguide == 1
by permno: replace PastNG = . if _n == 1
label variable PastNG "The number of past nonguidance"
by permno: gen PastPeriods = _n -1
label variable PastPeriods "The number of past period"

sort permno rdq
saveold "${data}/temp_pastNG.dta", replace version(12)

// Use SAS to generate the past guidance frequence variables
* run PastNG3y.sas
saswrapper using "${dofile}/PastNG3y.sas", nodata clear 

merge 1:1 permno datadateq using "${data}/temp_sas_pastNG_merge.dta", force
drop if _merge == 2
drop _merge




** Determinants of disclosure
// All variables are already defined.





********************************************************************************
* Generate variables
********************************************************************************

gen deltaroa = cqroaavg - pqroaavg
gen lowcost = dcbs <=2 // if not covered by Markit, short-selling should be difficult
gen loss = pqroaavg <0
replace ret_vola_lag=. if pqmaret ==.

winsor2 indicativefee, cuts(1 99) replace
replace utilisation = -utilisation
replace indicativefee = -indicativefee


save "${data}/final_EPS_regression_bundled_long_ChangeInControl20191216_wide.dta", replace




