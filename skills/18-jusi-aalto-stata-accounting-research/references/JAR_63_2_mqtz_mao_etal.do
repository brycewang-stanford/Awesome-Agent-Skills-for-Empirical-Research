log using "C:\Patent Library and M&A\Log File\0.3. Analytical_Sample_Construction.smcl", replace

********************************************************************************
*The historical SIC is based on SICH from Compustat. If SICH is not available, we will use CRSP industry instead;
use "C:\Patent Library and M&A\Data\Historical_SIC.dta", clear
destring gvkey, replace
drop if gvkey==.

bysort gvkey year:  keep if _n==1

gen tgt_sic_his=sic_his
gen tgt_gvkey=gvkey

sort tgt_gvkey year

tempfile hist_sic
save `hist_sic'

********************************************************************************
*In this dataset, we start from KPSS dataset.
*We first adjust for historical SIC code.
*We then use the maximum number of patents garanted in the past 5 years within an SIC3 industry to identify innovative industry.
use "C:\Patent Library and M&A\Data\KPSS_SIC.dta", replace

gen tgt_sic3=sic3_adj
gen tgt_innov_sic3=innov_ind

tempfile KPSS_Ind
save `KPSS_Ind'


********************************************************************************
*This dataset counts the total number of patents granted to a firm in the past 5 years using the KPSS dataset.
use "C:\Patent Library and M&A\Data\KPSS_5Year.dta", replace

gen tgt_gvkey=gvkey
gen acq_npat_5year=npat_5year 
gen tgt_npat_5year=npat_5year 

sort gvkey year

tempfile KPSS_5Year
save `KPSS_5Year'
 
*******Zip to county FIPS
import excel "C:\Patent Library and M&A\Data\ZIP_COUNTY_032020.xlsx", sheet("ZIP_COUNTY_032020") firstrow clear

gen tot_ratio=float(TOT_RATIO)
gen bus_ratio=float(BUS_RATIO)
gen res_ratio=float(RES_RATIO)

egen max_zip=max(tot_ratio), by(ZIP)
egen max_bus=max(bus_ratio), by(ZIP)
egen max_res=max(res_ratio), by(ZIP)


***Select the county with the largest tot_ratio for each ZIP

keep if tot_ratio ==max_zip


rename ZIP hist_zip

**First round of clean
sort hist_zip

quietly by hist_zip:  gen dup = cond(_N==1,0,_n)
drop if bus_ratio<max_bus & dup>=1
drop dup

**Second round of clean
sort hist_zip

quietly by hist_zip:  gen dup = cond(_N==1,0,_n)
drop if res_ratio<max_res & dup>=1
drop dup

keep hist_zip COUNTY

tempfile zip_county
save `zip_county'

********************************************************************************
use "C:\Patent Library and M&A\Data\County_population_1969-2018.dta", clear


destring fips, gen(fips_num)

xtset fips_num year

gen population_l1=l1.population
gen income_per_capita_l1=l1.income_per_capita

drop fips_num

rename fips COUNTY

sort COUNTY year

tempfile county_pop 
save `county_pop' 
********************************************************************************
use "C:\Patent Library and M&A\Data\Firm_Controls.dta", replace
rename _all, lower
destring gvkey, replace

gen acq_gvkey=gvkey

sort acq_gvkey permno fyear

quietly by acq_gvkey permno fyear:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

sort acq_gvkey fyear

joinby acq_gvkey fyear using "C:\Patent Library and M&A\Data\M&A_withID.dta", unmatched(both)
drop _merge 

replace permno=acq_permno if permno != acq_permno & acq_permno !=.

gen event=1 if deal_number !=.
replace event=0 if deal_number ==.

sort deal_number
quietly by deal_number:  gen dup = cond(_N==1,0,_n) if deal_number !=.
replace dup=0 if deal_number==.
drop if dup>1
drop dup

sort hist_zip

merge hist_zip using `zip_county'
drop _merge

sort COUNTY

merge COUNTY using "C:\Patent Library and M&A\Data\Patent_library_locations.dta"
drop _merge

sort COUNTY year

merge COUNTY year using `county_pop'
drop _merge


sort tgt_gvkey year

merge m:1 tgt_gvkey year using `hist_sic', keepusing(tgt_sic_his)
drop if _merge==2
drop _merge

gen tgt_sic3=int(tgt_sic_his/10)
replace tgt_sic3=int(target_sic/10) if tgt_sic_his==. & deal_number !=.

sort tgt_sic3 year

merge m:1 tgt_sic3 year using `KPSS_Ind', keepusing(tgt_innov_sic3)
drop if _merge==2
drop _merge

sort gvkey year

merge m:1 gvkey year using `KPSS_5Year', keepusing(acq_npat_5year)
drop if _merge==2
drop _merge

sort tgt_gvkey year

merge m:1 tgt_gvkey year using `KPSS_5Year', keepusing(tgt_npat_5year)
drop if _merge==2
drop _merge

****Manually check if private targets have patents or not
sort deal_number
merge m:1 deal_number using "C:\Patent Library and M&A\Data\Private_tgt_innovation.dta"
drop if _merge==2
drop _merge

sort deal_number
quietly by deal_number:  gen dup = cond(_N==1,0,_n) if deal_number !=.
replace dup=0 if deal_number==.
drop if dup>1
drop dup

format library_start_date %td

sort deal_number

replace acq_permco=permco if acq_permco==. & permco !=. & deal_number !=.

saveold "C:\Patent Library and M&A\Data\Sample 1_Raw.dta", replace
log close
global code "C:\Patent Library and M&A\Code\"

* First, merge M&A deals with firm-level and county-level controls
do "${code}0.3. Analytical_Sample_Construction.do" 

* Apply filters to generate the testing sample for our main analysis (Table 3)
do "${code}1. Sample for Table 1-4.do" 

* Generate the testing sample for the analysis on Patent Library Openings and Acquirer-Target Pairings 
* (Tables 5 and 6)
do "${code}2.4. Sample for Table 5-6.do" 

* Generate the testing sample for the analysis on Patent Library Openings and the Likelihood of Deal Completion 
* (Table 7)
do "${code}3. Sample for Table 7.do" 

* Generate the testing sample for the analysis on Patent Library Openings, Stock Returns, and Long-term Performance 
* (Table 8)
do "${code}4.2. Sample for Table 8.do" 

* Generate the testing sample for the analysis on Patent Library Openings and Post-Merger Innovation Activities 
* (Table 9)
do "${code}5. Sample for Table 9.do" 

* Generate the testing sample for the analysis on Patent Library Openings and Post-Merger Co-invention Between Target and Acquirer Inventors 
* (Table 10)
do "${code}6. Sample for Table 10.do" 

* Generate the testing sample for the analysis on Coincidence Between Acquirers’ Technological Keywords from SEC Filings and Keywords in Targets’ Patent Abstracts 
* (Table 11)
do "${code}7. Sample for Table 11.do" 

* Generate the testing sample for the analysis on Post-acquisition Citation of Target Patents by Terminated Acquirers 
* (Table 12)
do "${code}8.2. Sample for Table 12.do" 

* Generate the testing sample for the Falsification Tests 
* (Figure 3)
do "${code}1.1. Sample for Figure 3.do" 

********************************************************************************
* Below is the do-file to generate all regression results
do "${code}9. Regression Table 1-12.do" 
log using "C:\Patent Library and M&A\Log File\1. Sample for Table 1-4.smcl", replace

use "C:\Patent Library and M&A\Data\Sample 1_Raw.dta", clear
destring COUNTY, gen(FIPS)

//1. the form of deal was coded as a merger, an acquisition of majority interest, 
// or an acquisition of assets

keep if status=="C" | deal_number==.

keep if form=="Merger" | form=="Acq. Maj. Int." | form=="Acq. of Assets"  | deal_number==.

//2. if the acquirer owns less than 50% of the target firm prior to the bid, is seeking to ownmore than 50% of the target firm, and ownsmore than 90% of the target firm after the deal completion.

replace pct_before=0 if pct_before==. & deal_number !=.
replace pct_after=0 if pct_after==. & deal_number !=.
replace pct_seek=0 if pct_seek==. & deal_number !=.
gen pct_acquire=pct_after-pct_before

keep if (pct_before<=50 & pct_before!=.) & ((pct_seek >=50 & pct_seek !=.) | (pct_acquire >=50 & pct_acquire !=.))  & (pct_after>=90 & pct_after !=.) | deal_number==.

//3. the acquirer’s total assets be valued at more than $1 million, 
// or that the transaction value be no less than $1 million (all in 1984 constant dollars) to eliminate the many small and economically insignificant deals in the sample
keep if at>1 
drop if at ==.

keep if deal_value_mil>1 & (deal_value_mil !=. & deal_number !=.)  | deal_number==.

//4. the acquirer is not from the financial sector (SIC 6000–6999)
drop if  inrange(sic_his,6000,6999)

*Drop obs with missing controls
keep if age_l1+ ln_assets_l1+ rd_assets_l1+ roa_l1+ lev_l1+ che_assets_l1+ mtob_l1+ sale_g_l1+ ncwc_l1+bhr_l1  !=.

**Delete firms without available location information
keep if COUNTY != ""
 

***Define the library dummy=1 if the library opens 1 year before the datadate
gen day=datadate-365
format day %d

gen library=1 if day>=library_start_date & library_start_date !=.
replace library=0 if library==.

sort library_start_date gvkey datadate

keep if cik !=""

drop if sale<=0 | sale_l1<=0 | sale==0 

gen acquirer=event
gen deal=event
gen deal_innov_tgt=event if (tgt_npat_5year>0 & tgt_npat_5year !=.) |  (innovative_target==1)
replace deal_innov_tgt=0 if deal_innov_tgt==.

gen deal_innov_tgt_sic3=event if tgt_innov_sic3==1
replace deal_innov_tgt_sic3=0 if deal_innov_tgt_sic3==.
replace deal_innov_tgt_sic3=1 if deal_innov_tgt_sic3==0 & deal_innov_tgt==1


preserve
keep if inrange(year, 1985, 1999) 
keep if acq_npat_5year>0 & acq_npat_5year !=. 
keep if deal_innov_tgt_sic3==1
gen target_sic3=int(target_sic/10)

saveold "C:\Patent Library and M&A\Data\Deals_Innovative_SIC3.dta", replace
sort deal_number
restore

sort deal_number

global firm_control_l1 "age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1"
global county_control "population income_per_capita"
global county_control_l1 "population_l1 income_per_capita_l1 "

collapse (mean) $firm_control_l1 $county_control_l1 $county_control sic_his datadate acq_npat_5year at ///
(max) acquirer library (sum) deal deal_innov_tgt deal_innov_tgt_sic3 (last) library_start_date , by(gvkey year FIPS state)

gen income_percap_K_l1=income_per_capita_l1/1000	
	 
gen sic2_adj=int(sic_his/100)

xtset gvkey year

gen ln_age_l1 = ln(1+age_l1)
gen ln_population_l1 = ln(1+population_l1/10000000)

gen sic3_adj=int(sic_his)

global ln_county_control_l1 "ln_population_l1 income_percap_K_l1"
global ln_firm_control_l1 "ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1"

keep if inrange(year, 1985, 1999) 

foreach x in acquirer library $ln_county_control_l1 $ln_firm_control_l1{
	drop if `x'==.
}

replace deal_innov_tgt_sic3=deal_innov_tgt if deal_innov_tgt_sic3==0 & deal_innov_tgt>0 & deal_innov_tgt !=.

gen ln_deal_innov_tgt_sic3=ln(1+deal_innov_tgt_sic3)

saveold "C:\Patent Library and M&A\Data\Sample For Table 1.dta", replace

keep if acq_npat_5year>0 & acq_npat_5year !=. 
winsor2 ln_deal_innov_tgt_sic3 $ln_firm_control_l1 $ln_county_control_l1 , cuts(1 99) by(year) replace

saveold "C:\Patent Library and M&A\Data\Sample For Table 3.dta", replace

log close

clear *
clear all
drop _all
set more off
set matsize 10000
set maxvar 30000
set segmentsize 256m
set max_memory 16g
set niceness 6

********************************************************************************
log using "C:\Patent Library and M&A\Log File\1.1. Sample for Figure 3.smcl", replace

use "C:\Patent Library and M&A\Data\Sample For Table 3.dta", clear

cd "C:\Patent Library and M&A\Data\"

keep if library_start_date!=.
bysort FIPS library_start_date: keep if _n ==1
bysort 		  library_start_date: generate nx = _N
bysort 		  library_start_date: keep if _n ==1
keep  		  library_start_date nx
expand 		  nx 
sort 		  nx library_start_date
gen   		  merge_id = _n
rename library_start_date pseudo_treat_date
keep pseudo_treat_date merge_id
save 		  year_dist.dta, replace

use "C:\Patent Library and M&A\Data\Sample For Table 3.dta", clear
bysort FIPS:  keep if _n ==1
keep FIPS

gen merge_id=0

qui forv i=1/1000{

				local  randomseedx= 1000+2*`i'
				set seed `randomseedx'
				generate rannum`i'  = rnormal() 
				sort rannum`i'
				gen merge_id`i'= _n 
			drop rannum`i'

			replace merge_id = merge_id`i'
			merge 	1:1 merge_id using year_dist.dta
			rename 	pseudo_treat_date pseudo_treat_date`i'
			drop _merge
			drop merge_id`i'
			
}
sort FIPS

tempfile rand_sample
save  `rand_sample'


use "C:\Patent Library and M&A\Data\Sample For Table 3.dta", clear
sort FIPS
merge m:1 FIPS using `rand_sample'

saveold "C:\Patent Library and M&A\Data\Sample Placebo.dta", replace




*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
*-------------                                                 ----------------*
*-------------                                                 ----------------*
*-------------                    Regressions                  ----------------*
*-------------                                                 ----------------*
*-------------                                                 ----------------*
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
use "C:\Patent Library and M&A\Data\Sample Placebo.dta", replace
cd "C:\Patent Library and M&A\Results"

gen day=datadate-365
format day %d

global ln_county_pop_l1 "ln_population_l1 income_percap_K_l1"
global ln_lag_ctrl_salegl1_rl1 "ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1"


winsor2 $ln_lag_ctrl_salegl1_rl1 $COUNTY_pop_l1 $ln_county_pop_l1, cuts(1 99) by(year) replace
winsor2 ln_deal_innov_tgt_sic3, cuts(1 99) by(year) replace
*********************************
qui forv i=1/1000{
gen pseudo_library`i'=1 if day>=pseudo_treat_date`i' & pseudo_treat_date`i' !=.
replace pseudo_library`i'=0 if pseudo_library`i'==.
}
*********************
*********************
*********************
est clear

		capture erase info_noCountyCtrl_1.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_noCountyCtrl_1
		 		 
qui forv i=1/300{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'
*********************
est clear
		capture erase info_noCountyCtrl_2.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_noCountyCtrl_2
		 		 
qui forv i=301/600{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'

*********************
est clear
		capture erase info_noCountyCtrl_3.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_noCountyCtrl_3
		 		 
qui forv i=601/900{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'
		
*********************
est clear
		capture erase info_noCountyCtrl_4.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_noCountyCtrl_4
		 		 
qui forv i=901/1000{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'

*********************
*********************
*********************
est clear
		capture erase info_withCountyCtrl_1.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_withCountyCtrl_1
		 		 
qui forv i=1/300{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 $ln_county_pop_l1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'
*********************
est clear
		capture erase info_withCountyCtrl_2.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_withCountyCtrl_2
		 		 
qui forv i=301/600{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 $ln_county_pop_l1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'

*********************
est clear
		capture erase info_withCountyCtrl_3.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_withCountyCtrl_3
		 		 
qui forv i=601/900{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 $ln_county_pop_l1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}
		 
		postclose `hdle'
		
*********************
est clear
		capture erase info_withCountyCtrl_4.dta
		tempname hdle
		postfile `hdle' b_placebo se_placebo using info_withCountyCtrl_4
		 		 
qui forv i=901/1000{

eststo: reghdfe ln_deal_innov_tgt_sic3 pseudo_library`i'  $ln_lag_ctrl_salegl1_rl1 $ln_county_pop_l1 , absorb(year gvkey) vce(cluster FIPS)
				post `hdle' (_b[pseudo_library`i']) (_se[pseudo_library`i'])
}

		 
		postclose `hdle'
********************************************************************************

	use info_noCountyCtrl_1, clear
	append using info_noCountyCtrl_2 info_noCountyCtrl_3 info_noCountyCtrl_4
	gen tstat = b_placebo/se_placebo

save placebocoef_nocountyctrl.dta, replace

	use info_withCountyCtrl_1, clear
	append using info_withCountyCtrl_2 info_withCountyCtrl_3 info_withCountyCtrl_4
	gen tstat = b_placebo/se_placebo

save placebocoef_withcountyctrl.dta, replace

log close
log using "C:\Patent Library and M&A\Log File\2.1. For Matching.smcl", replace

use "C:\Patent Library and M&A\Data\Sample 1_Raw.dta", replace

drop if gvkey ==.

tempfile all
save `all'

qui forval i=1/3{
use `all', clear
keep if event==1
gen year_`i'before=year+`i'
drop year
rename year_`i'before year

gen event_`i'before=1

bysort gvkey year:  keep if _n==1

keep gvkey year event_`i'before

sort gvkey year

tempfile acq_`i'before
save `acq_`i'before'
}

******************************************************

use "C:\Patent Library and M&A\Data\Sample 1_Raw.dta", clear
 
drop if tgt_gvkey ==.

tempfile target
save `target'

qui forval i=1/3{
use `target', clear
gen year_`i'before=year+`i'
drop year
drop gvkey
rename year_`i'before year
rename tgt_gvkey gvkey

gen tgt_`i'before=1

bysort gvkey year:  keep if _n==1

keep gvkey year tgt_`i'before

sort gvkey year

tempfile tgt_`i'before
save `tgt_`i'before'
}
***********

use `target', clear

drop gvkey
rename tgt_gvkey gvkey

gen tgt_eventyear=1

bysort gvkey year:  keep if _n==1

keep gvkey year tgt_eventyear

sort gvkey year

tempfile tgt_eventyear
save `tgt_eventyear'

*************************************************************
*************************************************************
*************************************************************

use `all', clear

qui forval i=1/3{
sort gvkey year

merge m:1 gvkey year using `acq_`i'before'
drop _merge

sort gvkey year

merge m:1 gvkey year using `tgt_`i'before'
drop _merge
}
merge m:1 gvkey year using `tgt_eventyear'
drop _merge

forval i=1/3{
replace event_`i'before=0 if event_`i'before==.
replace tgt_`i'before=0 if tgt_`i'before==.
}
replace tgt_eventyear=0 if tgt_eventyear==.

egen ttl_event_before=rowtotal(event_1before event_2before event_3before event tgt_1before tgt_2before tgt_3before tgt_eventyear)

gen ctrl_eligible=1 if ttl_event_before==0
replace ctrl_eligible=0 if ttl_event_before>0

drop event_1before event_2before event_3before tgt_1before tgt_2before tgt_3before tgt_eventyear ttl_event_before

joinby gvkey year using "C:\Patent Library and M&A\Data\Tech_proximity.dta", unmatched(master)
bysort gvkey year deal_number: keep if _n==1

**********************************************************************
//1. the form of deal was coded as a merger, an acquisition of majority interest, 
// or an acquisition of assets

keep if status=="C" | deal_number==.


****Do not require the target firm to be public

keep if form=="Merger" | form=="Acq. Maj. Int." | form=="Acq. of Assets"  | deal_number==.

//2. if the acquirer owns less than 50% of the target firm prior to the bid, is seeking to ownmore than 50% of the target firm, and ownsmore than 90% of the target firm after the deal completion.

replace pct_before=0 if pct_before==. & deal_number !=.
replace pct_after=0 if pct_after==. & deal_number !=.
replace pct_seek=0 if pct_seek==. & deal_number !=.
gen pct_acquire=pct_after-pct_before

keep if (pct_before<=50 & pct_before!=.) & ((pct_seek >=50 & pct_seek !=.) | (pct_acquire >=50 & pct_acquire !=.))  & (pct_after>=90 & pct_after !=.) | deal_number==.

//3. the acquirer’s total assets be valued at more than $1 million, 
// or that the transaction value be no less than $1 million (all in 1984 constant dollars) to eliminate the many small and economically insignificant deals in the sample
keep if at>1 
drop if at ==.

keep if deal_value_mil>1 & (deal_value_mil !=. & deal_number !=.)  | deal_number==.

//4. neither the acquirer nor the target firm be from the financial sector (SIC 6000–6999)
drop if  inrange(sic_his,6000,6999)

keep if age_l1+ ln_assets_l1+ rd_assets_l1+ roa_l1+ lev_l1+ che_assets_l1+ mtob_l1+ sale_g_l1+ ncwc_l1+bhr_l1  !=.

**Delete firms without available location information
keep if COUNTY != ""

*clear *

***Define the library dummy=1 if the library opens 1 year before the datadate
gen day=datadate-365
format day %d

gen library=1 if day>=library_start_date & library_start_date !=.
replace library=0 if library==.

sort library_start_date gvkey datadate
order deal_number gvkey event datadate day library library_start_date date_announced

keep if cik !=""

drop if sale<=0 | sale_l1<=0

drop if sale==0 

gen acquirer=event
gen deal=event
gen deal_innov_tgt=event if (tgt_npat_5year>0 & tgt_npat_5year !=.) | (innovative_target==1)
replace deal_innov_tgt=0 if deal_innov_tgt==.

gen deal_innov_tgt_sic3=event if tgt_innov_sic3==1
replace deal_innov_tgt_sic3=0 if deal_innov_tgt_sic3==.
replace deal_innov_tgt_sic3=1 if deal_innov_tgt_sic3==0 & deal_innov_tgt==1

sort deal_number

gen income_percap_K_l1=income_per_capita_l1/1000	
	 
gen sic2_adj=int(sic_his/100)

gen ln_age_l1 = ln(1+age_l1)
gen ln_population_l1 = ln(1+population_l1/10000000)
  
global ln_county_control_l1 "ln_population_l1 income_percap_K_l1"
global ln_firm_control_l1 "ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1"

keep if inrange(year, 1985, 1999) 

foreach x in acquirer library $ln_county_control_l1 $ln_firm_control_l1{
	drop if `x'==.
}

keep if acq_npat_5year>0 & acq_npat_5year !=. 

destring COUNTY, gen(FIPS)

gen at_l1=exp(ln_assets_l1)-1
drop county countyfips countyname

saveold "C:\Patent Library and M&A\Data\Sample_for_Match.dta", replace


log close


clear *
clear all
drop _all
set more off
set matsize 10000
set maxvar 30000
set segmentsize 256m
set max_memory 16g
set niceness 6

log using "C:\Patent Library and M&A\Log File\2.3. Size&MB Matched Sample.smcl", replace

********************************************************************************
use "C:\Patent Library and M&A\Data\Sample For Table 1.dta", clear

gen acquirer_innov_sic3=(deal_innov_tgt_sic3>0 &deal_innov_tgt_sic3 !=.)
quietly: logit acquirer_innov_sic3 ln_assets_l1 mtob_l1  i.year, r

predict yhat

gen acq_gvkey=gvkey 

gen acq_yhat=yhat

keep gvkey year yhat acq_gvkey acq_yhat

tempfile prob_acq
save `prob_acq'

	
use "C:\Patent Library and M&A\Data\Same_ind_match.dta" , clear //This sample contains pseudo acquirers that have the same industry as the 

append using "C:\Patent Library and M&A\Data\Actual_pair.dta"

rename _all, lower

sort deal_number

replace match_level=0 if actual_pair==1

replace actual_pair=0 if actual_pair==.

sort gvkey year

merge m:1 gvkey year using `prob_acq', keepusing(yhat)
drop if _merge==2
drop _merge

sort acq_gvkey year

merge m:1 acq_gvkey year using `prob_acq', keepusing(acq_yhat)
drop if _merge==2
drop _merge

gen diff_prob=abs(acq_yhat-yhat)

sort deal_number match_level diff_prob
quietly by deal_number:  gen  order_control= cond(_N==1,0,_n)

keep if order_control<=6 | actual_pair==1

egen count_control=count(gvkey), by(deal_number)

drop if count_control==7 & order_control==6 //keep at most 5 pseudo acquirers

saveold "C:\Patent Library and M&A\Data\Size_MB_matched.dta", replace

log close
log using "C:\Patent Library and M&A\Log File\2.4. Sample for Table 5-6.smcl", replace

**********************************************************************************************************************************
use "C:\Patent Library and M&A\Data\Size_matched.dta" , clear
drop tech_proximity
joinby deal_number using "C:\Patent Library and M&A\Data\Deals_Innovative_SIC3.dta"

sort gvkey year tgt_sic3

merge m:1 gvkey year tgt_sic3 using "C:\Patent Library and M&A\Data\Tech_proximity.dta"
drop if _merge==2

rename income_percap_k_l1 income_percap_K_l1

drop day library
gen day=datadate-365
format day %d

gen library=1 if day>=library_start_date & library_start_date !=.
replace library=0 if library==.

keep if inrange(year, 1985, 1999)

quietly bysort deal_number gvkey:  keep if _n==1

gen ln_dist_state=ln(1+dist_state)

gen geo_proximity=1/ln_dist_state 
replace geo_proximity=1 if ln_dist_state==0

global ln_county_control_l1 "ln_population_l1 income_percap_K_l1"
global ln_firm_control_l1 "ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1"

foreach x in actual_pair library $ln_county_control_l1 $ln_firm_control_l1 geo_proximity tech_proximity{
	drop if `x'==.
} 

egen max_acquirer=max(actual_pair), by(deal_number)
egen min_acquirer=min(actual_pair), by(deal_number)
keep if max_acquirer==1 & min_acquirer==0 
drop max_acquirer min_acquirer

saveold "C:\Patent Library and M&A\Data\Sample2_Size.dta", replace

************************************************************************************************************

use "C:\Patent Library and M&A\Data\Size_MB_matched.dta", replace
drop tech_proximity
joinby deal_number using "C:\Patent Library and M&A\Data\Deals_Innovative_SIC3.dta"

sort gvkey year tgt_sic3

joinby gvkey year tgt_sic3 using "C:\Patent Library and M&A\Data\Tech_proximity.dta", unmatched(master)
drop _merge

rename income_percap_k_l1 income_percap_K_l1

drop day library
gen day=datadate-365
format day %d

gen library=1 if day>=library_start_date & library_start_date !=.
replace library=0 if library==.

keep if inrange(year, 1985, 1999)

quietly bysort deal_number gvkey:  keep if _n==1

gen ln_dist_state=ln(1+dist_state)

gen geo_proximity=1/ln_dist_state 
replace geo_proximity=1 if ln_dist_state==0

global ln_county_control_l1 "ln_population_l1 income_percap_K_l1"
global ln_firm_control_l1 "ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1"

foreach x in actual_pair library $ln_county_control_l1 $ln_firm_control_l1 geo_proximity tech_proximity{
	drop if `x'==.
} 

egen max_acquirer=max(actual_pair), by(deal_number)
egen min_acquirer=min(actual_pair), by(deal_number)
keep if max_acquirer==1 & min_acquirer==0 
drop max_acquirer min_acquirer

saveold "C:\Patent Library and M&A\Data\Sample2_Size_MB.dta", replace
log close
log using "C:\Patent Library and M&A\Log File\3. Sample for Table 7.smcl", replace

use "C:\Patent Library and M&A\Data\Sample 1_Raw.dta", clear
destring COUNTY, gen(FIPS)

keep if deal_number !=. 

keep if inrange(year, 1985, 1999)

keep if form=="Merger" | form=="Acq. Maj. Int." | form=="Acq. of Assets"

//2. if the acquirer owns less than 50% of the target firm prior to the bid, is seeking to ownmore than 50% of the target firm, 
//****Not require to own more than 90% of the target firm after the deal completion.

replace pct_before=0 if pct_before==. & deal_number !=.
replace pct_after=0 if pct_after==. & deal_number !=.
replace pct_seek=0 if pct_seek==. & deal_number !=.
gen pct_acquire=pct_after-pct_before

keep if (pct_before<=50 & pct_before!=.) & ((pct_seek >=50 & pct_seek !=.) | (pct_acquire >=50 & pct_acquire !=.))  

drop if status=="C" & (pct_after<90 | pct_after==.)

//3. the acquirer’s total assets be valued at more than $1 million, 
// or that the transaction value be no less than $1 million (all in 1984 constant dollars) to eliminate the many small and economically insignificant deals in the sample
keep if at>1 
drop if at ==.

keep if deal_value_mil>1 & (deal_value_mil !=. & deal_number !=.) 

//4. the acquirer is not from the financial sector (SIC 6000–6999)
drop if  inrange(sic_his,6000,6999)

**Delete firms with no available location information
keep if COUNTY != ""

*clear *

***Define the library dummy=1 if the library opens 1 year before the datadate
gen day=datadate-365
format day %d

gen library=1 if day>=library_start_date & library_start_date !=.
replace library=0 if library==.

keep if cik !=""

drop if sale<=0 | sale_l1<=0

drop if sale==0 

gen acquirer=event
gen deal=event
gen deal_innov_tgt=event if (tgt_npat_5year>0 & tgt_npat_5year !=.) |  (innovative_target==1)
replace deal_innov_tgt=0 if deal_innov_tgt==.

gen deal_innov_tgt_sic3=event if tgt_innov_sic3==1
replace deal_innov_tgt_sic3=0 if deal_innov_tgt_sic3==.
replace deal_innov_tgt_sic3=1 if deal_innov_tgt_sic3==0 & deal_innov_tgt==1

replace dlc=0 if dlc==.
replace dltt=0 if dltt==.


//DEAL RATIO: The ratio of M&A deal value to an acquirer’s market value of equity 
*measured 4 weeks before a deal announcement. Source: SDC Platinum.
gen deal_ratio=deal_value/mv_l1 //mv here need adjustment

//EXCESS CASH: The difference between expected cash holding and realized cash holding. Source: Compustat.
gen ecess_cash=che_assets_l1  //need to figure out a way to measure expected cash holding

// /STOCK DUMMY: An indicator that equals 1 if the payment is fully in stock, and 0 otherwise.Source: SDC Platinum.
gen stock_dummy=1 if pct_stock==100
replace stock_dummy=0 if stock_dummy==.

//CASH DUMMY: An indicator that equals 1 if an M&A deal is fully funded by cash, and 0 otherwise. Source: SDC Platinum.
gen cash_dummy=1 if pct_cash==100
replace cash_dummy=0 if cash_dummy==.

//HIGH TECH DUMMY: An indicator that equals 1 if an acquirer’s 4-digit SIC code is
*equal to 3571, 3572, 3575, 3577, 3578, 3661, 3663, 3669, 3671, 3672, 3674, 3675,
*3677, 3678, 3679, 3812, 3823, 3825, 3826, 3827, 3829, 3841, 3845, 4812, 4813,
*4899, 7371–7375, 7378, or 7379, and 0 otherwise. Source: Compustat.
gen high_tech_dummy=1 if inlist(acquirer_sic,3571, 3572, 3575, 3577, 3578, 3661, 3663, 3669, 3671, 3672, 3674, 3675, ///
3677, 3678, 3679, 3812, 3823, 3825, 3826, 3827, 3829, 3841, 3845, 4812, 4813,4899, 7371,7372, 7373,7374,7375, 7378, 7379)
replace high_tech_dummy=0 if high_tech_dummy==.
//DIVERSIFYING DUMMY: An indicator that equals 1 if the acquirer and target belong to
*different 2-digit SIC code industries, and 0 otherwise. Source: Compustat.
gen acquirer_sic2=int(acquirer_sic/100)
gen target_sic2=int(target_sic/100)

gen diversify_dummy=1 if acquirer_sic2 != target_sic2
replace diversify_dummy=0 if acquirer_sic2 == target_sic2
replace diversify_dummy=. if acquirer_sic2==. | target_sic2==.
//HOSTILE DUMMY: An indicator that equals 1 if the M&A deal is a hostile takeover, and 0 otherwise. Source: SDC Platinum.
gen hostile_dummy=1 if attitude=="Hostile"
replace hostile_dummy=0 if hostile_dummy==.

//An indicator that equals 1 for a publicly listed target, and 0 otherwise. Source: SDC Platinum.
gen public_tgt = 1 if target_public_status=="Public" 
replace public_tgt = 0 if public_tgt ==.

//CHALLENGE DUMMY: An indicator that equals 1 if the acquirer’s offer is challenged by a competing offer, and 0 otherwise. Source: SDC Platinum.
gen challenge_dummy=1 if strpos(competing___bidder, "Yes")>0
replace challenge_dummy=0 if challenge_dummy==.

gen ln_age_l1 = ln(1+age_l1)
gen ln_population_l1 = ln(1+population_l1/10000000)
gen income_percap_K_l1=income_per_capita_l1/1000	

gen complete=1 if status=="C"
replace complete=0 if complete==.

gen sic3_adj=int(sic_his/10)

keep if acq_npat_5year>0 & acq_npat_5year !=.

keep if deal_innov_tgt_sic3==1

global completion_control "ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 ecess_cash rd_assets_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy  challenge_dummy public_tgt"

***********************************		
foreach x in library $completion_control  ln_population_l1 income_percap_K_l1{
	drop if `x'==.
}


bysort acquirer_name target_name: gen dup=cond(_N==1,0,_n) //some deals are withdrawn first and then completed. And one deal show up twice both are pending

*Stata somtimes misclassify completed deals as withdrawal. So we manually verified if the withdrawal deals are completed or withdrawal.
merge 1:1 deal_number using "C:\Patent Library and M&A\Data\Manually_verified_completed_or_withdrawal.dta"
drop if _merge==2
drop _merge

gen new_complete=complete 
replace new_complete=completed_new if complete==0

drop if dup>0 & status !="C" 

drop if deal_number== 96920020 | deal_number==22722020 | deal_number==554394020 //re-submitted deals

drop if completed_new==1 //they have missing deal-level information such as deal_value
winsor2 $completion_control ln_population_l1 income_percap_K_l1, cuts(1 99) by(year) replace

saveold "C:\Patent Library and M&A\Data\Sample For Table7.dta", replace

log close
log using "C:\Patent Library and M&A\Log File\4.1. For Deal-level Analysis.smcl", replace

use "C:\Patent Library and M&A\Data\Sample 1_Raw.dta", clear
destring COUNTY, gen(FIPS)

keep if deal_number !=. 

keep if inrange(year, 1985, 1999)

keep if status=="C" | deal_number==.

****Do not require the target firm to be public
keep if form=="Merger" | form=="Acq. Maj. Int." | form=="Acq. of Assets" 

//2. if the acquirer owns less than 50% of the target firm prior to the bid, is seeking to ownmore than 50% of the target firm, and ownsmore than 90% of the target firm after the deal completion.

replace pct_before=0 if pct_before==. & deal_number !=.
replace pct_after=0 if pct_after==. & deal_number !=.
replace pct_seek=0 if pct_seek==. & deal_number !=.
gen pct_acquire=pct_after-pct_before

keep if (pct_before<=50 & pct_before!=.) & ((pct_seek >=50 & pct_seek !=.) | (pct_acquire >=50 & pct_acquire !=.))  & (pct_after>=90 & pct_after !=.)
//3. the acquirer’s total assets be valued at more than $1 million, 
// or that the transaction value be no less than $1 million (all in 1984 constant dollars) to eliminate the many small and economically insignificant deals in the sample
keep if at>1 
drop if at ==.

keep if deal_value_mil>1 & (deal_value_mil !=. & deal_number !=.) 

//4. the acquirer is not from the financial sector (SIC 6000–6999)
drop if  inrange(sic_his,6000,6999)

**Delete firms with no available location information
keep if COUNTY != ""

*clear *

***Define the library dummy=1 if the library opens 1 year before the datadate
gen day=datadate-365
format day %d

gen library=1 if day>=library_start_date & library_start_date !=.
replace library=0 if library==.

keep if cik !=""

drop if sale<=0 | sale_l1<=0

drop if sale==0 

gen acquirer=event
gen deal=event
gen deal_innov_tgt=event if (tgt_npat_5year>0 & tgt_npat_5year !=.) |  (innovative_target==1)
replace deal_innov_tgt=0 if deal_innov_tgt==.

gen deal_innov_tgt_sic3=event if tgt_innov_sic3==1
replace deal_innov_tgt_sic3=0 if deal_innov_tgt_sic3==.
replace deal_innov_tgt_sic3=1 if deal_innov_tgt_sic3==0 & deal_innov_tgt==1

//DEAL RATIO: The ratio of M&A deal value to an acquirer’s market value of equity 
*measured 4 weeks before a deal announcement. Source: SDC Platinum.
gen deal_ratio=deal_value/mv_l1 //mv here need adjustment

//EXCESS CASH: The difference between expected cash holding and realized cash holding. Source: Compustat.
gen ecess_cash=che_assets_l1  //need to figure out a way to measure expected cash holding

// /STOCK DUMMY: An indicator that equals 1 if the payment is fully in stock, and 0 otherwise.Source: SDC Platinum.
gen stock_dummy=1 if pct_stock==100
replace stock_dummy=0 if stock_dummy==.

//CASH DUMMY: An indicator that equals 1 if an M&A deal is fully funded by cash, and 0 otherwise. Source: SDC Platinum.
gen cash_dummy=1 if pct_cash==100
replace cash_dummy=0 if cash_dummy==.

//HIGH TECH DUMMY: An indicator that equals 1 if an acquirer’s 4-digit SIC code is
*equal to 3571, 3572, 3575, 3577, 3578, 3661, 3663, 3669, 3671, 3672, 3674, 3675,
*3677, 3678, 3679, 3812, 3823, 3825, 3826, 3827, 3829, 3841, 3845, 4812, 4813,
*4899, 7371–7375, 7378, or 7379, and 0 otherwise. Source: Compustat.
gen high_tech_dummy=1 if inlist(acquirer_sic,3571, 3572, 3575, 3577, 3578, 3661, 3663, 3669, 3671, 3672, 3674, 3675, ///
3677, 3678, 3679, 3812, 3823, 3825, 3826, 3827, 3829, 3841, 3845, 4812, 4813,4899, 7371,7372, 7373,7374,7375, 7378, 7379)
replace high_tech_dummy=0 if high_tech_dummy==.
//DIVERSIFYING DUMMY: An indicator that equals 1 if the acquirer and target belong to
*different 2-digit SIC code industries, and 0 otherwise. Source: Compustat.
gen acquirer_sic2=int(acquirer_sic/100)
gen target_sic2=int(target_sic/100)

gen diversify_dummy=1 if acquirer_sic2 != target_sic2
replace diversify_dummy=0 if acquirer_sic2 == target_sic2
replace diversify_dummy=. if acquirer_sic2==. | target_sic2==.
//HOSTILE DUMMY: An indicator that equals 1 if the M&A deal is a hostile takeover, and 0 otherwise. Source: SDC Platinum.
gen hostile_dummy=1 if attitude=="Hostile"
replace hostile_dummy=0 if hostile_dummy==.

//An indicator that equals 1 for a publicly listed target, and 0 otherwise. Source: SDC Platinum.
gen public_tgt = 1 if target_public_status=="Public" 
replace public_tgt = 0 if public_tgt ==.

//CHALLENGE DUMMY: An indicator that equals 1 if the acquirer’s offer is challenged by a competing offer, and 0 otherwise. Source: SDC Platinum.
gen challenge_dummy=1 if strpos(competing___bidder, "Yes")>0
replace challenge_dummy=0 if challenge_dummy==.

gen ln_age_l1 = ln(1+age_l1)
gen ln_population_l1 = ln(1+population_l1/10000000)
gen income_percap_K_l1=income_per_capita_l1/1000	

gen sic3_adj=int(sic_his/10)

keep if acq_npat_5year>0 & acq_npat_5year !=.

quietly bysort permno date_announced:  gen dup = cond(_N==1,0,_n) if deal_number !=.
gen one_deal=1 if dup==0 
replace one_deal=0 if dup>0
drop dup


saveold "C:\Patent Library and M&A\Data\Deals with Innovative Acquirer.dta", replace

log close
/*get the permno of the acquirers and the target and the deal announcement date 
use "C:\Patent Library and M&A\Data\Deals with Innovative Industry.dta", replace



preserve
bysort permno date_announced: keep if _n==1
keep permno date_announced
saveold "C:\Patent Library and M&A\Data\List of Acquirers.dta", replace
restore

preserve
drop if tgt_permno==.
bysort permno date_announced: keep if _n==1
keep tgt_permno date_announced
saveold "C:\Patent Library and M&A\Data\List of Targets.dta", replace
restore
*/

/*Use EVENTUS service in SAS to get CAR
proc import datafile="C:\Patent Library and M&A\Data\List of Acquirers.dta"
out=acquirer replace dbms=stata;
run;

data Acq_event_upload;
set acquirer;
format date_announced YYMMDDn8.;
/*The date format must be YYMMDDn8.;*/
rename date_announced=EVENTDAT;
/*Rename data var as EVENTDA;*/
run;
proc import datafile="C:\Patent Library and M&A\Data\List of Targets.dta"
out=target replace dbms=stata;
run;

data Tgt_event_upload;
set target;
rename tgt_permno=permno;
format date_announced YYMMDDn8.;
/*The date format must be YYMMDDn8.;*/
rename date_announced=EVENTDAT;
/*Rename data var as EVENTDA;*/
run;
proc sort data=Acq_event_upload nodupkey; by Permno EVENTDAT; run; 
proc sort data=Tgt_event_upload nodupkey; by Permno EVENTDAT; run; 

%let wrds=wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;                    /*To connect with WRDS Unix SERVER;*/
signon username=_prompt_;                           /*you need EVENTUS subscription;*/
rsubmit;

options fullstimer ps=60;

proc upload data=Acq_event_upload out =Acq_event_upload; run;
proc upload data=Tgt_event_upload out =Tgt_event_upload; run;
/*Upload the file to WRDS Work Lib;*/


/******************************EVENTUS CODE BEGIN********************************** */
/*eventus; Market Model method */

eventus;
request  insas=Acq_event_upload autodate Est=-46 estlen=255 Minestn=3;
windows (-3,3);
evtstudy pre=30 post=30 patell cda tail=2 both mar raw outwin=Acq_CAR_MM nonames;
**********;
eventus;
request  insas=Tgt_event_upload autodate Est=-46 estlen=255 Minestn=3;
windows (-3,3);
evtstudy pre=30 post=30 patell cda tail=2 both mar raw outwin=Tgt_CAR_MM nonames;
proc download   data=Acq_CAR_MM
                out=Acq_CAR_MM ;                 
run;
proc download   data=Tgt_CAR_MM
                out=Tgt_CAR_MM ;                  
run;
     
endrsubmit;                                         /*sign off from WRDS;*/
*signoff;

proc export data=Acq_CAR_MM outfile="C:\Patent Library and M&A\Data\Acquirer_CAR_MM.dta"
dbms=stata replace;
run;

proc export data=Tgt_CAR_MM outfile="C:\Patent Library and M&A\Data\Target_CAR_MM.dta"
dbms=stata replace;
run;
*/
log using "C:\Patent Library and M&A\Log File\4.2. Sample for Table 8.smcl", replace

use "C:\Patent Library and M&A\Data\CRSP_Market Value.dta", replace
*Use CRSP daily stock file. mkv=abs(prc)*shrout. mkv_1weekbefore is mkv lagged by 7 days.

sort permno date

tempfile MKV
save `MKV'

use "C:\Patent Library and M&A\Data\Acquirer_CAR_MM.dta", clear
keep if (restype=="MAR" & _weight_=="Value")

gen date=eventdat

sort permno date

merge m:1 permno date using `MKV', keepusing(mkv_1weekbefore)
drop if _merge==2
drop _merge
rename mkv_1weekbefore acq_mkv_1weekbefore

rename original_eventdat date_announced

bysort permno date_announced: keep if _n==1
rename car_window acq_car

tempfile acq_car
save `acq_car'

use "C:\Patent Library and M&A\Data\Target_CAR_MM.dta", clear
keep if (restype=="MAR" & _weight_=="Value")

gen date=eventdat

sort permno date

merge m:1 permno date using `MKV', keepusing(mkv_1weekbefore)
drop if _merge==2
drop _merge
rename mkv_1weekbefore tgt_mkv_1weekbefore

rename original_eventdat date_announced
rename permno tgt_permno

bysort tgt_permno date_announced: keep if _n==1
rename car_window tgt_car

tempfile tgt_car
save `tgt_car'


use "C:\Patent Library and M&A\Data\Long-term abnormal return.dta", clear
*Calculated using CRSP monthly stock file. 
*in PROC Expand command: convert lnabret = BHAR5 / transformout = (movsum 60 trimleft 3); 
*where 	lnabret=log(ret-vwretd+1);

gen year_effective=year(date)
gen month_effective=month(date)

bysort permco year_effective month_effective: keep if _n==1

tempfile BHAR
save `BHAR'

**************************************************************


use "C:\Patent Library and M&A\Data\Deals with Innovative Acquirer.dta", clear

merge m:1 gvkey year using "C:\Patent Library and M&A\Data\Long-term abnormal ROA.dta",keepusing(roa_ind_adj)
**roa_ind_adj: the firm's ROA minus the median ROA of its SIC3 industry after 5 years
drop if _merge==2
drop _merge

merge m:1 permno date_announced using `acq_car', keepusing(acq_car acq_mkv_1weekbefore)
drop _merge


merge m:1 tgt_permno date_announced using `tgt_car', keepusing(tgt_car tgt_mkv_1weekbefore)
drop _merge

gen year_effective=year(date_effective)
gen month_effective=month(date_effective)
merge m:1 permco year_effective month_effective using `BHAR', keepusing(bhar5)
*bhar5: the firm's 5-year abnormal return relative to the value-weighted market return, calculated from the deal's effective date.
drop if _merge==2
drop _merge

bysort deal_number:  keep if _n==1

saveold "C:\Patent Library and M&A\Data\Sample for Table8.dta", replace

global deal_control "deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt"
global acq_control "ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1"
global acq_control_nobhr "ln_assets_l1 mtob_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1"
global acq_control_noroa "ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 che_assets_l1 rd_assets_l1 ln_age_l1"
global tgt_control "tgt_ln_assets_l1 tgt_mtob_l1 tgt_bhr_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_roa_l1 tgt_che_assets_l1 tgt_rd_assets_l1 tgt_ln_age_l1"

saveold "C:\Patent Library and M&A\Data\Sample for Table8.dta", replace

keep if acq_car !=.

keep if one_deal==1


foreach x in library $acq_control ncwc_l1 ln_population_l1 income_percap_K_l1{
	drop if `x'==.
}

foreach x in $deal_control{
	drop if `x'==.
}

keep if acq_car !=. & bhar5 !=.

keep if deal_innov_tgt_sic3==1

winsor2 $acq_control ln_population_l1 income_percap_K_l1 deal_ratio, cuts(1 99) by(year) replace


saveold "C:\Patent Library and M&A\Data\Sample for Table8_Acq.dta", replace


***********************************************************************************************
use "C:\Patent Library and M&A\Data\Comp_Control.dta", replace

sort gvkey year

bysort gvkey year(fyear datadate):  keep if _n==1

gen tgt_gvkey=gvkey 

local control "rd_assets ln_assets roa che_assets mtob lev at sale_g ln_age"
foreach zz of local control{
rename `zz' `zz'_l1
}
replace year=year(datadate)+1


keep gvkey year fyear datadate ln_assets_l1 mtob_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 at_l1 ln_age_l1


gen tgt_gvkey=gvkey 

global comp_control "ln_assets_l1 mtob_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1"

foreach vv of var $comp_control{
gen tgt_`vv'=`vv'
}

gen tgt_at_l1=at_l1

global tgt_comp_control "tgt_ln_assets_l1 tgt_mtob_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_roa_l1 tgt_che_assets_l1 tgt_rd_assets_l1"

sort gvkey year

tempfile tgt_control
save `tgt_control'

****************

use "C:\Patent Library and M&A\Data\CRSP_Control.dta", clear

gen year=year(date)

bysort permco year(date):  keep if _n==1

replace year=year(date)+1

sort permco year

gen tgt_permco=permco
gen tgt_bhr_l1=bhr

sort permco year

tempfile crsp_control
save `crsp_control'
****************

use "C:\Patent Library and M&A\Data\Sample for Table8.dta", replace

keep if one_deal==1

sort tgt_gvkey year

joinby tgt_gvkey year using `tgt_control', unmatched(both)
drop if _merge==2
drop _merge
merge m:1 tgt_permco year using `crsp_control'
drop if _merge==2
drop _merge

gen combined_car=acq_mkv_1weekbefore/(acq_mkv_1weekbefore+tgt_mkv_1weekbefore)*acq_car+tgt_mkv_1weekbefore/(acq_mkv_1weekbefore+tgt_mkv_1weekbefore)*tgt_car

foreach x in library $acq_control $tgt_control ln_population_l1 income_percap_K_l1{
	drop if `x'==.
	di `"`x'"'
}

foreach x in $deal_control{
	drop if `x'==.
	di `"`x'"'
}
sort tgt_permno date_announced deal_value_mil deal_ratio date_effective

by tgt_permno date_announced: keep if _n==1 


keep if deal_number !=.

keep if combined_car !=. & acq_car !=. & tgt_car !=. 
keep if deal_innov_tgt_sic3==1

gen target_sic3=int(target_sic/10)

winsor2 $acq_control $tgt_control deal_ratio ln_population_l1 income_percap_K_l1, cuts(1 99) by(year) replace

saveold "C:\Patent Library and M&A\Data\Sample for Table8_Tgt.dta", replace

log close
log using "C:\Patent Library and M&A\Log File\5. Sample for Table 9.smcl", replace

use "C:\Patent Library and M&A\Data\Sample for Table8.dta", clear
keep if deal_innov_tgt_sic3==1
keep deal_number date_announced date_effective gvkey tgt_gvkey permno tgt_permno permco tgt_permco library_start_date library COUNTY FIPS acq_mkv_1weekbefore tgt_mkv_1weekbefore

expand 10

bysort deal_number: gen relative_year=-(_n)
gen year=year(date_announced)+relative_year
gen post=0

tempfile pre_announcement
save `pre_announcement'

use "C:\Patent Library and M&A\Data\Sample for Table8.dta", clear
keep if deal_innov_tgt_sic3==1
keep deal_number date_announced date_effective gvkey tgt_gvkey permno tgt_permno permco tgt_permco library_start_date library COUNTY FIPS acq_mkv_1weekbefore tgt_mkv_1weekbefore



expand 10

bysort deal_number: gen relative_year=_n
gen year=year(date_effective)+relative_year
gen post=1

tempfile post_effective
save `post_effective'

use `pre_announcement', clear
append using `post_effective'


tempfile deal_expand
save `deal_expand'

***********************************************************************************************

use "C:\Patent Library and M&A\Data\CRSP_Control.dta", clear
gen year=year(date)

gsort permco year permno -date


by permco year: keep if _n==1

replace year=year(date)+1

sort permco year

gen tgt_permco=permco
gen tgt_bhr_l1=bhr
gen bhr_l1=bhr

sort permco year

tempfile crsp_control
save `crsp_control'

***********************************************************************************************
use "C:\Patent Library and M&A\Data\Comp_Control.dta", replace

destring gvkey, replace

sort gvkey fyear

gen asset_tan=ppe_assets
local control "at ln_assets asset_tan sale_g lev rd_assets roa tobinq1 capex_assets"
keep gvkey datadate fyear `control'
foreach zz of local control{
rename `zz' `zz'_l1
}
gen year=year(datadate)+1

gsort gvkey year -fyear -datadate

quietly by gvkey year:  keep if _n==1


gen tgt_gvkey=gvkey 

global comp_control "at_l1 ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 capex_assets_l1"

foreach vv of var $comp_control{
gen tgt_`vv'=`vv'
}

global tgt_comp_control "tgt_at_l1 tgt_ln_assets_l1 tgt_asset_tan_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_rd_assets_l1 tgt_roa_l1 tgt_tobinq1_l1 tgt_capex_assets_l1"

sort gvkey year


tempfile innov_ctrl
save `innov_ctrl'


***********************************************************************************************
use "C:\Patent Library and M&A\Data\Comp_Control.dta", replace

destring gvkey, replace

gsort gvkey year -fyear -datadate

quietly by gvkey year:  keep if _n==1

sort gvkey year

keep gvkey year datadate

gen tgt_gvkey=gvkey
gen tgt_datadate=datadate
tempfile datadate
save `datadate'
********************************************************************************
**County-level control
use "C:\Patent Library and M&A\Data\County_population_1969-2018.dta", clear


destring fips, gen(fips_num)

xtset fips_num year

gen population_l1=l1.population
gen income_per_capita_l1=l1.income_per_capita

drop fips_num

rename fips COUNTY

destring COUNTY, gen(FIPS)

sort FIPS year

gen ln_population_l1 = ln(1+population_l1/10000000)
gen income_percap_K_l1=income_per_capita_l1/1000

keep FIPS year ln_population_l1 income_percap_K_l1

sort FIPS year
tempfile county_pop 
save `county_pop'
*****************************************************************
use "C:\Patent Library and M&A\Data\Citation_wt_Patents.dta", clear

*We follow the methodology outlined by Anton (2021) to construct the citation-weighted patents variable
*First, we calculate the average number of citations for all patents granted within a given year: egen mean_citation_year = mean(cites), by(grt_year).
*Next, we determine the weight by dividing the number of citations of the focal patent by the mean citations for that year: gen weight = cites/mean_citation_year.
*Finally, the citation-weighted patents are calculated as the summation of 1*(1 + weight) for all patents filed by a firm within a year.

collapse (sum) cites citation_wt_npat npat (mean) mean_citaion_year , by(permno year)

gen tgt_permno=permno
gen tgt_npat=npat 
gen tgt_cites=cites
gen tgt_citation_wt_npat=citation_wt_npat
sort permno year

tempfile patent
save `patent'

use `deal_expand', clear
sort permno year

merge m:1 permno year using `patent', keepusing(npat cites citation_wt_npat mean_citaion_year)
drop if _merge==2
drop _merge

sort tgt_permno year

merge m:1 tgt_permno year using `patent', keepusing(tgt_npat tgt_cites tgt_citation_wt_npat)
drop if _merge==2
drop _merge


sort gvkey year

merge m:1 gvkey year using `innov_ctrl', keepusing($comp_control)
drop if _merge==2
drop _merge

sort gvkey year

merge m:1 gvkey year using `datadate', keepusing(datadate)
drop if _merge==2
drop _merge


sort permco year

merge m:1 permco year using `crsp_control', keepusing(bhr_l1)
drop if _merge==2
drop _merge

sort tgt_gvkey year

merge m:1 tgt_gvkey year using `innov_ctrl', keepusing($tgt_comp_control)
drop if _merge==2
drop _merge

sort tgt_gvkey year

merge m:1 tgt_gvkey year using `datadate', keepusing(tgt_datadate)
drop if _merge==2
drop _merge


sort tgt_permco year

merge m:1 tgt_permco year using `crsp_control', keepusing(tgt_bhr_l1)
drop if _merge==2
drop _merge

sort FIPS year
merge m:1 FIPS year using `county_pop'
drop if _merge==2
drop _merge


sort permno datadate

merge m:1 permno datadate using "C:\Patent Library and M&A\Data\Acquirer_MKV.dta", keepusing(acq_mkv_datadate)
drop if _merge==2
drop _merge

sort tgt_permno tgt_datadate

merge m:1 tgt_permno tgt_datadate using "C:\Patent Library and M&A\Data\Target_MKV.dta", keepusing(tgt_mkv_datadate) 
drop if _merge==2
drop _merge

sort deal_number year

replace npat=0 if npat==.
replace tgt_npat=0 if tgt_npat==. & tgt_permno !=.

replace cites=0 if cites==.
replace tgt_cites=0 if tgt_cites==. & tgt_permno !=.

replace citation_wt_npat=0 if citation_wt_npat==.
replace tgt_citation_wt_npat=0 if tgt_citation_wt_npat==. & tgt_permno !=.

gen combined_npat=npat+tgt_npat if post==0
replace combined_npat=npat if post==1 & tgt_permno !=.

gen comb_cite_wt_npat=citation_wt_npat+tgt_citation_wt_npat if post==0
replace comb_cite_wt_npat=citation_wt_npat if post==1 & tgt_permno !=.

gen combined_cites=cites+tgt_cites if post==0
replace combined_cites=cites if post==1 & tgt_permno !=.

gen ln_npat=ln(1+npat)
gen ln_ncite=ln(1+cites)
gen ln_combined_npat=ln(1+combined_npat)
gen ln_combined_cites=ln(1+combined_cites)
gen ln_comb_cite_wt_npat=ln(1+comb_cite_wt_npat)
 
global innov_control "at_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 capex_assets_l1"
global time "datadate"

foreach zz in $time{
foreach vv of var $innov_control ln_assets_l1{

gen comb_`vv'=(acq_mkv_`zz'/(acq_mkv_`zz'+tgt_mkv_`zz'))*`vv'+(tgt_mkv_`zz'/(acq_mkv_`zz'+tgt_mkv_`zz'))*tgt_`vv' if post==0
replace comb_`vv'=`vv' if post==1
replace comb_`vv'=. if post==1 & tgt_gvkey ==.
}
gen ln_comb_at_l1=ln(1+comb_at_l1)
}

keep if tgt_gvkey !=. & tgt_permno !=.


keep if inrange(relative_year, -5,5)

egen max_combined_npat=max(combined_npat), by(deal_number)
drop if max_combined_npat==0 | max_combined_npat==.
replace ln_combined_cites=0 if ln_combined_cites==.

global acq_control "ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1"
global comb_control " ln_comb_at_l1  comb_asset_tan_l1 comb_sale_g_l1 comb_lev_l1 comb_rd_assets_l1 comb_roa_l1 comb_tobinq1_l1 comb_bhr_l1"

foreach x in `zz' library $comb_control{
	drop if `x'==.
}
winsor2 $comb_control $acq_control ln_population_l1 income_percap_K_l1, cuts(1 99) by(year) replace

saveold "C:\Patent Library and M&A\Data\Sample for Table9.dta", replace
log close
log using "C:\Patent Library and M&A\Log File\6. Sample for Table 10.smcl", replace

use "C:\Patent Library and M&A\Data\CRSP_Control.dta", clear
gen year=year(date)

bysort permco year:  keep if _n==1

replace year=year(date)+1

sort permco year

gen tgt_permco=permco
gen tgt_bhr_l1=bhr
gen bhr_l1=bhr

sort permco year

tempfile crsp_control
save `crsp_control'

***********************************************************************************************
use "C:\Patent Library and M&A\Data\Comp_Control.dta", replace

destring gvkey, replace

sort gvkey fyear

gen asset_tan=ppe_assets
local control "at ln_assets asset_tan sale_g lev rd_assets roa tobinq1 capex_assets"
keep gvkey datadate `control'
foreach zz of local control{
rename `zz' `zz'_l1
}
gen year=year(datadate)+1

sort gvkey year
quietly by gvkey year:  keep if _n==1


gen tgt_gvkey=gvkey 

global comp_control "at_l1 ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 capex_assets_l1"

foreach vv of var $comp_control{
gen tgt_`vv'=`vv'
}

global tgt_comp_control "tgt_at_l1 tgt_ln_assets_l1 tgt_asset_tan_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_rd_assets_l1 tgt_roa_l1 tgt_tobinq1_l1 tgt_capex_assets_l1"

sort gvkey year


tempfile innov_ctrl
save `innov_ctrl'
***********************************************************************************************
use "C:\Patent Library and M&A\Data\Sample for Table8.dta", clear
keep if deal_innov_tgt_sic3==1

keep if tgt_gvkey !=. & tgt_permno !=.

sort deal_number
quietly by deal_number: keep if _n==1

joinby deal_number using "C:\Patent Library and M&A\Data\Deal-level Number of Co-invented Patents.dta", unmatched(both)
drop _merge
*To get the number of co-invented patents
*1.Use inventor-patent-year level data, along with firm IDs, to identify inventors who worked for the target firm in the year prior to the deal announcement.
*2.Identify patents filed by the acquiring firm within the five years following the deal's effective date, along with the inventors listed on these patents.
*3.Define a patent as a co-invention if at least one of the listed inventors worked for the target firm in the year prior to the deal announcement.
*4.Count the total number of co-invented patents, the total number of citations of these co-invented patents, and the total number of patents and citations filed within the five years following the deal's effective date.

gen co_pat_pct=co_pat/npat

gen co_cites_pct=co_cites/ncites

replace co_cites_pct=0 if co_cites_pct==. & co_pat_pct !=.

sort gvkey year

merge m:1 gvkey year using `innov_ctrl', keepusing($comp_control)
drop if _merge==2
drop _merge


sort tgt_gvkey year

merge m:1 tgt_gvkey year using `innov_ctrl', keepusing($tgt_comp_control)
drop if _merge==2
drop _merge

sort tgt_permco year

merge m:1 tgt_permco year using `crsp_control', keepusing(tgt_bhr_l1)
drop if _merge==2
drop _merge

gen target_sic3=int(target_sic/10)

global acq_control_innov "ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1"
global tgt_control_innov "tgt_ln_assets_l1 tgt_asset_tan_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_rd_assets_l1 tgt_roa_l1 tgt_tobinq1_l1 tgt_bhr_l1"
global deal_control "deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt"
global acq_control_NP "ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1"

replace co_cites_pct=0 if co_cites_pct==. & co_pat_pct !=.

replace tgt_innov_sic3=1 if deal_innov_tgt==1

keep if tgt_innov_sic3==1

foreach x in library $acq_control_innov $deal_control ln_population_l1 income_percap_K_l1{
	drop if `x'==.
}
winsor2 $deal_control $acq_control_NP $acq_control_innov $acq_control_NP $acq_control_innov $tgt_control_innov ln_population_l1 income_percap_K_l1, cuts(1 99) by(year) replace

saveold "C:\Patent Library and M&A\Data\Sample for Table10.dta", replace
log close

log using "C:\Patent Library and M&A\Log File\7. Sample for Table 11.smcl", replace

use "C:\Patent Library and M&A\Data\Deal-level Keywrods Count.dta", clear

*To get the number of co-invented patents
*1. Using invnetor-patent-year level data with firm id to identify the inventors worked for the target firm in the year prior to the deal announcement
*2. Identify patents filed by the acquirer in 5 years post deal effective date, and the inventors listed on these patents
*3. Define a patent as co-invention if the at least one of the listed inventor worked for the target firm in the year prior to the deal annoucement
*4. Count the total number of co-invented patents, the total number of citations of these co-invented patnets, and the total number of patents and citations in 5 years post the deal effective date.  


collapse (sum) key_word_total (mean) total_number_of_words (count)N_keywords=total_number_of_words, by(deal_number date_announced filling_type filling_date)

gen relative_year=year(filling_date)-year(date_announced)
gen keyword_ratio=(key_word_total/N_keywords)/total_number_of_words //adjust for the differences in the number of keywords

collapse (mean) keyword_ratio, by(deal_number relative_year filling_type)

gen filetype_10KQ=1 if filling_type=="10_K" | filling_type=="10_Q" 
replace filetype_10KQ=0 if filetype_10KQ==.

gen filetype_8K=1 if filling_type=="8_K" 
replace filetype_8K=0 if filetype_8K==.

gen filetype_10or8K=(filetype_10KQ==1 | filetype_8K==1)

gen filetype_allfile=1

unab keywor_ratio: keyword_ratio*
qui foreach yy of local keywor_ratio{
	foreach vv in allfile 10KQ 10or8K 8K{
	replace filetype_`vv'=. if filetype_`vv'==0
	gen `yy'_`vv'=`yy'*filetype_`vv' 
	}
drop `yy'
}

collapse (mean) keyword_ratio_*, by(deal_number relative_year)



preserve
use "C:\Patent Library and M&A\Data\Comp_Control.dta", replace

destring gvkey, replace

sort gvkey fyear

gen asset_tan=ppe_assets
local control "at ln_assets asset_tan sale_g lev rd_assets roa tobinq1 capex_assets"
keep gvkey datadate `control'
foreach zz of local control{
rename `zz' `zz'_l1
}
gen year=year(datadate)+1

bysort gvkey year:  keep if _n==1

global comp_control "at_l1 ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 capex_assets_l1"

tempfile innov_ctrl
save `innov_ctrl'
restore

keep if relative_year==-1

merge 1:1 deal_number using "C:\Patent Library and M&A\Data\Deals with Innovative Acquirer and Innovative Tgt SIC3.dta"
drop if _merge==2
drop _merge

merge m:1 gvkey year using `innov_ctrl', keepusing($comp_control)
drop if _merge==2
drop _merge


global acq_control_innov "ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1"
global deal_control "deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt"


unab keywor_ratio: keyword_ratio*
foreach yy of local keywor_ratio{
replace `yy'=`yy'*10^4
}

saveold "C:\Patent Library and M&A\Data\Sample for Table11.dta", replace
log close

log using "C:\Patent Library and M&A\Log File\8.1. Failed Bids Patent Num&Backward Citations.smcl", replace

use "C:\Patent Library and M&A\Data\KPSS_Patent_level.dta", clear

gen cite_permno=permno 
gen cite_patent_num=patent_num 
gen year=year(filing_date)
sort cite_patent_num

tempfile cite_firm
save `cite_firm'

********************************************************************************

use "C:\Patent Library and M&A\Data\Patent_Backward_Citation.dta", clear
gen citation_id2=substr(citation_id, -7,.)
gen cite_patent_num=int(real(citation_id2))
replace cite_patent_num=int(real(citation_id)) if cite_patent_num==.

sort cite_patent_num 

merge m:1 cite_patent_num using `cite_firm', keepusing(cite_permno)
drop if _merge==2
drop _merge

rename patent_id patent_num

saveold "C:\Patent Library and M&A\Data\Backward_Citation_with_FirmID.dta", replace

****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
use "C:\Patent Library and M&A\Data\Failed Bids_Size Matched.dta", clear


expand 5

bysort deal_number gvkey: gen relative_year=-(_n)
gen year=year(date_announced)+relative_year
gen post=0

tempfile pre_announcement
save `pre_announcement'

use "C:\Patent Library and M&A\Data\Failed Bids_Size Matched.dta", clear
*Using the same method as Table 5 and 6 to match acquirers of failed bids with pseudo acquirers

expand 5

bysort deal_number gvkey: gen relative_year=_n
gen year=year(date_withdrawn)+relative_year
replace year=year(date_announced)+relative_year if date_withdrawn==.

gen post=1

tempfile post_effective
save `post_effective'

use `pre_announcement', clear
append using `post_effective'


merge m:m permno year using `cite_firm', keepusing(patent_num)
drop if _merge==2
drop _merge

merge m:m patent_num using "C:\Patent Library and M&A\Data\Backward_Citation_with_FirmID.dta", keepusing(cite_permno)
drop if _merge==2
drop _merge

gen refer_target_pat=1 if cite_permno==tgt_permno
replace refer_target_pat=0 if refer_target_pat==.

egen refer_target=max(refer_target_pat), by(patent_num deal_number)

	
collapse (last) library_start_date permno permco post relative_year  tgt_permno tgt_permco tgt_gvkey ///
date_announced date_withdrawn status FIPS (max) library actual_pair ///
(count) npat=patent_num (sum) n_refer_target=refer_target, by(deal_number gvkey year)
gen ratio_refer_target=n_refer_target/npat

saveold "C:\Patent Library and M&A\Data\Failed Bids_Size Matched_with Citation of Target Patents.dta", replace



****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************

use "C:\Patent Library and M&A\Data\Failed Bids_Size&MB Matched.dta", clear


expand 5

bysort deal_number gvkey: gen relative_year=-(_n)
gen year=year(date_announced)+relative_year
gen post=0

tempfile pre_announcement
save `pre_announcement'

use "C:\Patent Library and M&A\Data\Failed Bids_Size&MB Matched.dta", clear
*Using the same method as Table 5 and 6 to match acquirers of failed bids with pseudo acquirers

expand 5

bysort deal_number gvkey: gen relative_year=_n
gen year=year(date_withdrawn)+relative_year
replace year=year(date_announced)+relative_year if date_withdrawn==.

gen post=1

tempfile post_effective
save `post_effective'

use `pre_announcement', clear
append using `post_effective'

merge m:m permno year using `cite_firm', keepusing(patent_num)
drop if _merge==2
drop _merge

merge m:m patent_num using "C:\Patent Library and M&A\Data\Backward_Citation_with_FirmID.dta", keepusing(cite_permno)
drop if _merge==2
drop _merge

gen refer_target_pat=1 if cite_permno==tgt_permno
replace refer_target_pat=0 if refer_target_pat==.

egen refer_target=max(refer_target_pat), by(patent_num deal_number)

	
collapse (last) library_start_date permno permco post relative_year tgt_permno tgt_permco tgt_gvkey ///
date_announced date_withdrawn status FIPS (max) library actual_pair ///
(count) npat=patent_num (sum) n_refer_target=refer_target, by(deal_number gvkey year)
gen ratio_refer_target=n_refer_target/npat
saveold "C:\Patent Library and M&A\Data\Failed Bids_Size&MB Matched_with Citation of Target Patents.dta", replace

log close
log using "C:\Patent Library and M&A\Log File\8.2 Sample for Table 12.smcl", replace

use "C:\Patent Library and M&A\Data\Comp_Control.dta", replace

destring gvkey, replace

sort gvkey fyear

gen asset_tan=ppe_assets
local control "at ln_assets asset_tan sale_g lev rd_assets roa tobinq1 capex_assets"

keep gvkey datadate `control' 
foreach zz of local control{
rename `zz' `zz'_l1
}
gen year=year(datadate)+1


sort gvkey year

sort gvkey year
quietly by gvkey year: keep if _n==1

gen tgt_gvkey=gvkey 

global comp_control "at_l1 ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 capex_assets_l1"

foreach vv of var $comp_control{
gen tgt_`vv'=`vv'
}

global tgt_comp_control "tgt_at_l1 tgt_ln_assets_l1 tgt_asset_tan_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_rd_assets_l1 tgt_roa_l1 tgt_tobinq1_l1 tgt_capex_assets_l1"

sort gvkey year


tempfile innov_ctrl
save `innov_ctrl'

***********************************************************************************************
use "C:\Patent Library and M&A\Data\CRSP_Control.dta", clear
gen year=year(date)

gsort permco year permno -date

by permco year: keep if _n==1

replace year=year(date)+1

sort permco year

gen tgt_permco=permco
gen tgt_bhr_l1=bhr
gen bhr_l1=bhr

sort permco year

tempfile crsp_control
save `crsp_control'

********************************************************************************
**County-level control
use "C:\Patent Library and M&A\Data\County_population_1969-2018.dta", clear


destring fips, gen(fips_num)

xtset fips_num year

gen population_l1=l1.population
gen income_per_capita_l1=l1.income_per_capita

drop fips_num

rename fips COUNTY

destring COUNTY, gen(FIPS)

sort FIPS year

gen ln_population_l1 = ln(1+population_l1/10000000)
gen income_percap_K_l1=income_per_capita_l1/1000

keep FIPS year ln_population_l1 income_percap_K_l1

sort FIPS year
tempfile county_pop 
save `county_pop'
******************
use "C:\Patent Library and M&A\Data\kpss_patents.dta" , clear

gen year=year(filing_date)+1

collapse (count)tgt_npat_app_l1=patent_num, by(permno year)

rename permno tgt_permno

sort tgt_permno year

tempfile tgt_app_npat
save `tgt_app_npat'

******************
use "C:\Patent Library and M&A\Data\kpss_patents.dta" , clear

gen year=year(filing_date)+1

collapse (count)acq_npat_app_l1=patent_num, by(permno year)

sort permno year

tempfile acq_app_npat
save `acq_app_npat'

******************
use "C:\Patent Library and M&A\Data\Failed Bids_Size Matched_with Citation of Target Patents.dta", clear
*1. We begin by compiling a list of failed bids.
*2. Next, we identify pseudo bidders as a control group using the same matching techniques applied in Tables 5 and 6.
*3. For each failed bid, we gather all patents granted to the target firm prior to the deal announcement date.
*4. We then extend the analysis to include the period starting 5 years before the deal announcement date and ending 5 years after the deal's effective date.
*5. In each year, we calculate the percentage of patents filed by the (pseudo) acquirers that cite at least one of the targets' patents.

merge m:1 gvkey year using `innov_ctrl', keepusing($comp_control)
drop if _merge==2
drop _merge

merge m:1 permco year using `crsp_control', keepusing(bhr_l1)
drop if _merge==2
drop _merge

sort FIPS year
merge m:1 FIPS year using `county_pop'
drop if _merge==2
drop _merge


joinby tgt_permno year using `tgt_app_npat', unmatched(master)
drop _merge

joinby permno year using `acq_app_npat', unmatched(master)
drop _merge

replace tgt_npat_app_l1=0 if tgt_npat_app_l1==.
replace acq_npat_app_l1=0 if acq_npat_app_l1==.

gen ln_tgt_npat_app_l1=ln(1+tgt_npat_app_l1)
gen ln_acq_npat_app_l1=ln(1+acq_npat_app_l1)


merge m:1 deal_number using "C:\Patent Library and M&A\Data\Manually_verified_completed_or_withdrawal.dta"
keep if _merge==3
drop _merge

merge m:1 deal_number using  "C:\Patent Library and M&A\Data\Withdrawn_and_Resubmit_Later.dta"
drop if _merge==2 | _merge==3 //drop deals that are initially withdrawn but submit and complete later by the same bidder

preserve
bysort deal_number: keep if _n==1
restore

global c_acq_control "c.ln_assets_l1 c.asset_tan_l1 c.sale_g_l1 c.lev_l1 c.rd_assets_l1 c.roa_l1 c.tobinq1_l1 c.bhr_l1"
 
drop if completed_new==1

saveold "C:\Patent Library and M&A\Data\Sample For Table12_Size_Matched.dta", replace

***************************************************************************************************************
use "C:\Patent Library and M&A\Data\Failed Bids_Size&MB Matched_with Citation of Target Patents.dta", clear

merge m:1 gvkey year using `innov_ctrl', keepusing($comp_control)
drop if _merge==2
drop _merge

merge m:1 permco year using `crsp_control', keepusing(bhr_l1)
drop if _merge==2
drop _merge

sort FIPS year
merge m:1 FIPS year using `county_pop'
drop if _merge==2
drop _merge


sort tgt_permno year
merge m:1 tgt_permno year using `tgt_app_npat'
drop if _merge==2
drop _merge

sort permno year
merge m:1 permno year using `acq_app_npat'
drop if _merge==2
drop _merge

replace tgt_npat_app_l1=0 if tgt_npat_app_l1==.
replace acq_npat_app_l1=0 if acq_npat_app_l1==.

gen ln_tgt_npat_app_l1=ln(1+tgt_npat_app_l1)
gen ln_acq_npat_app_l1=ln(1+acq_npat_app_l1)

merge m:1 deal_number using "C:\Patent Library and M&A\Data\Manually_verified_completed_or_withdrawal.dta"
keep if _merge==3
drop _merge

merge m:1 deal_number using  "C:\Patent Library and M&A\Data\Withdrawn_and_Resubmit_Later.dta"
drop if _merge==2 | _merge==3 //drop deals that are initially withdrawn but submit and complete later by the same bidder

preserve
bysort deal_number: keep if _n==1
restore

global c_acq_control "c.ln_assets_l1 c.asset_tan_l1 c.sale_g_l1 c.lev_l1 c.rd_assets_l1 c.roa_l1 c.tobinq1_l1 c.bhr_l1"
 
drop if completed_new==1


saveold "C:\Patent Library and M&A\Data\Sample For Table12_Size&MB_Matched.dta", replace

log close
global repoption "b(3) t(3) ar2 pr2 nogaps star(* 0.10 ** 0.05 *** 0.01)"

clear *
clear all
drop _all
set more off
set matsize 10000
set maxvar 30000
set segmentsize 256m
set max_memory 16g
set niceness 6

********************************************************************************
log using "C:\Patent Library and M&A\Log File\9. Regression Table 1-12.smcl", replace

********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 1                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************
use "C:\Patent Library and M&A\Data\Sample For Table 1.dta", clear
cd "C:\Patent Library and M&A\Results"

preserve

estpost tabstat deal, stats(sum) by(year) columns(statistics) 
esttab using Table1_column1.csv, replace cells("sum") noobs

restore


preserve
keep if acq_npat_5year>0 & acq_npat_5year !=. 

estpost tabstat deal_innov_tgt_sic3, stats(sum) by(year) columns(statistics) 
esttab using Table1_column2.csv, replace cells("sum") noobs

restore


********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 2                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************
use "C:\Patent Library and M&A\Data\Sample For Table 3.dta", clear

cd "C:\Patent Library and M&A\Results"

gen acquirer_innov_tgt_sic3=(deal_innov_tgt_sic3>0)
eststo clear
estpost tabstat acquirer_innov_tgt_sic3 deal_innov_tgt_sic3 library ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1 ln_population_l1 income_percap_K_l1, ///
stats(n mean p50 sd) columns(statistics) 
esttab using Table2.csv,replace cells("count mean p50 sd") noobs

********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 3                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************

eststo clear

*reghdfe, compile
eststo: reghdfe ln_deal_innov_tgt_sic3 library  ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1 , absorb(year gvkey) vce(cluster FIPS)
eststo: reghdfe ln_deal_innov_tgt_sic3 library  ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1 ln_population_l1 income_percap_K_l1 , absorb(year gvkey) vce(cluster FIPS)

esttab using Table3.csv, $repoption replace 


********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 4                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************

use "C:\Patent Library and M&A\Data\Sample For Table 3.dta", clear

cd "C:\Patent Library and M&A\Results"

gen rel_year=year-year(library_start_date) 
replace rel_year=year-year(library_start_date)-1 if  library_start_date !=. & month(datadate)<=month(library_start_date)

gen lib_neg3=1 if rel_year<=-3 & rel_year!=.
replace lib_neg3=0 if lib_neg3==.

gen lib_neg2=1 if rel_year==-2 & rel_year!=.
replace lib_neg2=0 if lib_neg2==.

gen lib_neg1=1 if rel_year==-1 & rel_year!=.
replace lib_neg1=0 if lib_neg1==.

gen year0=1 if rel_year==0 & rel_year!=.
replace year0=0 if year0==.

gen lib_pos1=1 if rel_year==1 & rel_year!=.
replace lib_pos1=0 if lib_pos1==.

gen lib_pos2=1 if rel_year==2 & rel_year!=.
replace lib_pos2=0 if lib_pos2==.

gen lib_pos3=1 if rel_year>=3 & rel_year!=.
replace lib_pos3=0 if lib_pos3==.

************************************************************************************
eststo clear

*reghdfe, compile
eststo: reghdfe ln_deal_innov_tgt_sic3 lib_neg3 lib_neg2 lib_neg1 lib_pos1 lib_pos2 lib_pos3  ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1 , absorb(year gvkey) vce(cluster FIPS)
eststo: reghdfe ln_deal_innov_tgt_sic3 lib_neg3 lib_neg2 lib_neg1 lib_pos1 lib_pos2 lib_pos3  ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1 ln_population_l1 income_percap_K_l1 , absorb(year gvkey) vce(cluster FIPS)

esttab using Table4.csv, $repoption replace 

********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                Figure 2                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************

global dynamic3_with0 " "lib_neg3" "lib_neg2" "lib_neg1"  "lib_pos1" "lib_pos2" "lib_pos3" "year0" "

****************
matrix base0=J(8,3,.)

matrix rownames base0=$dynamic3_with0
matrix colnames base0= coef ll90 ul90 

eststo clear

eststo: reghdfe ln_deal_innov_tgt_sic3 lib_neg3 lib_neg2 lib_neg1 lib_pos1 lib_pos2 lib_pos3 ln_age_l1 ln_assets_l1 rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1 ln_population_l1 income_percap_K_l1 , absorb(year gvkey) vce(cluster FIPS)

***************************	
local iter = 0

foreach i in lib_neg3 lib_neg2 lib_neg1 lib_pos1 lib_pos2 lib_pos3{
      local iter=`iter'+1
	  matrix    base0[`iter',1]=_b[`i']
	  matrix    base0[`iter',2]=_b[`i'] - invttail(e(df_r),0.05)*_se[`i']
	  matrix    base0[`iter',3]=_b[`i'] + invttail(e(df_r),0.05)*_se[`i']
}
	  matrix    base0[7,1]=0
	  matrix    base0[7,2]=0
	  matrix    base0[7,3]=0


coefplot ( matrix(base0[,1]), ci((base0[,2] base0[,3]))), vertical ciopts(recast(rcap) color(black))  citop   order(lib_neg3 lib_neg2 lib_neg1 year0 lib_pos1 lib_pos2 lib_pos3) ///
        coeflab(lib_neg3 = "<=-3" lib_neg2 = "-2" lib_neg1 = "-1" year0="Library    Open Year" lib_pos1="1"  lib_pos2="2"  lib_pos3=">=3",wrap(10)) ///
	    yline(0) omitted xtitle("Year relative to Pat Library Open", size(large)) ytitle("Coefficient Estimate", size(large))		
graph export Figure2.png, as(png) replace

********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                Figure 3                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************
use "C:\Patent Library and M&A\Results\placebocoef_withcountyctrl.dta", clear
rename b_placebo b_withcounty
rename se_placebo se_withcounty
rename tstat tstat_withcounty

************************************************************************
*************************************************************************
global fcolor_coef "fcolor(yellow*1.1) lcolor(gs7)"

*********************
hist b_withcounty, freq bin(30) title("Panel A", size(normal)) graphregion(color(white)) ///
bgcolor(white) xtitle("Coefficient Estimate on Pat Library", size(small)) ytitle("Frequency", size(small)) ///
yla(,grid labsize(small) glcolor(black) glwidth(.05)) xla( -0.1 "-0.1" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.1 "0.1",labsize(small) ) xline(0.062 ,  lstyle(foreground) lcolor(black) lwidth(.3) lpattern(shortdash_dot)) ///
/*fcolor(yellow*1.1) lcolor(gs7)*/ saving(coef_county,replace) 

hist tstat_withcounty, freq bin(30) title("Panel B", size(normal)) graphregion(color(white)) ///
bgcolor(white) xtitle("T-stat of Coefficient Estimate on Pat Library", size(small)) ytitle("Frequency", size(small)) ///
yla(,grid labsize(small) glcolor(black) glwidth(.05)) xla(,labsize(small) ) xline(2.77,  lstyle(foreground) lcolor(black) lwidth(.3) lpattern(shortdash_dot)) ///
/*fcolor(yellow*1.1) lcolor(gs7)*/ saving(tstat_county,replace) 

cd "C:\Patent Library and M&A\Results"
graph combine coef_county.gph tstat_county.gph, col(1) iscale(1) 
graph export "C:\Patent Library and M&A\Results\Figure3.png", replace


********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                             Table 5 & 6                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************


use "C:\Patent Library and M&A\Data\Sample2_Size.dta", clear

cd "C:\Patent Library and M&A\Results"

eststo clear
eststo: clogit  actual_pair c.library#c.geo_proximity c.library geo_proximity ln_age_l1 /*ln_assets_l1*/  rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1  ln_population_l1 income_percap_K_l1, group(deal_number) vce(cluster deal_number)
    test geo_proximity + c.library#c.geo_proximity=0
	estadd scalar p_value = r(p)
	estadd scalar F = r(chi2)
	esttab using Table5.csv, $repoption replace title("Geo Proximity") scalar(F p_value)

eststo clear
eststo: clogit  actual_pair c.library#c.tech_proximity c.library tech_proximity ln_age_l1 /*ln_assets_l1*/ rd_assets_l1 roa_l1 lev_l1 che_assets_l1 mtob_l1 sale_g_l1 ncwc_l1 bhr_l1  ln_population_l1 income_percap_K_l1, group(deal_number) vce(cluster deal_number)
    test tech_proximity + c.library#c.tech_proximity=0
	estadd scalar p_value = r(p)
	estadd scalar F = r(chi2)
	esttab using Table6.csv, $repoption replace title("Tech Proximity") scalar(F p_value)

********************************************************************************
use "C:\Patent Library and M&A\Data\Sample2_Size_MB.dta", clear

cd "C:\Patent Library and M&A\Results"

eststo clear
eststo: clogit  actual_pair c.library#c.geo_proximity c.library geo_proximity ln_age_l1 /*ln_assets_l1*/  rd_assets_l1 roa_l1 lev_l1 che_assets_l1 /*mtob_l1*/ sale_g_l1 ncwc_l1 bhr_l1  ln_population_l1 income_percap_K_l1, group(deal_number) vce(cluster deal_number)
    test geo_proximity + c.library#c.geo_proximity=0
	estadd scalar p_value = r(p)
	estadd scalar F = r(chi2)
	esttab using Table5.csv, $repoption append title("Geo Proximity") scalar(F p_value)

eststo clear
eststo: clogit  actual_pair c.library#c.tech_proximity c.library tech_proximity ln_age_l1 /*ln_assets_l1*/ rd_assets_l1 roa_l1 lev_l1 che_assets_l1 /*mtob_l1*/ sale_g_l1 ncwc_l1 bhr_l1  ln_population_l1 income_percap_K_l1, group(deal_number) vce(cluster deal_number)
    test tech_proximity + c.library#c.tech_proximity=0
	estadd scalar p_value = r(p)
	estadd scalar F = r(chi2)
	esttab using Table6.csv, $repoption append title("Tech Proximity") scalar(F p_value)

********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 7                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************
use "C:\Patent Library and M&A\Data\Sample For Table7.dta", clear
cd "C:\Patent Library and M&A\Results"

eststo clear
eststo: logit new_complete library ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 ecess_cash rd_assets_l1 deal_ratio cash_dummy high_tech_dummy diversify_dum hostile_dummy  challenge_dummy public_tgt i.sic3_adj i.year, vce(cluster FIPS)
eststo: logit new_complete library ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 ecess_cash rd_assets_l1 deal_ratio cash_dummy high_tech_dummy diversify_dum hostile_dummy  challenge_dummy public_tgt ln_population_l1 income_percap_K_l1 i.sic3_adj i.year, vce(cluster FIPS)

esttab using Table7.csv, $repoption replace 



********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 8                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************

use "C:\Patent Library and M&A\Data\Sample for Table8_Acq.dta", clear

cd "C:\Patent Library and M&A\Results"

eststo clear
eststo: reghdfe acq_car library ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj year) vce(cluster FIPS)
eststo: reghdfe bhar5 library ln_assets_l1 mtob_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj year) vce(cluster FIPS)
eststo: reghdfe roa_ind_adj library ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1  che_assets_l1 rd_assets_l1 ln_age_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj year) vce(cluster FIPS)

esttab using Table8.csv, $repoption mtitles("Acquirer CAR" "BHAR5" "AcqIndAdj ROA") replace
****************************************************************************************************************************************************************
use "C:\Patent Library and M&A\Data\Sample for Table8_Tgt.dta", clear
cd "C:\Patent Library and M&A\Results"

eststo clear
eststo: reghdfe combined_car library ln_assets_l1 mtob_l1 bhr_l1 sale_g_l1 lev_l1 roa_l1 che_assets_l1 rd_assets_l1 ln_age_l1 tgt_ln_assets_l1 tgt_mtob_l1 tgt_bhr_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_roa_l1 tgt_che_assets_l1 tgt_rd_assets_l1 tgt_ln_age_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj target_sic3 year) vce(cluster FIPS)
eststo: reghdfe tgt_car library tgt_ln_assets_l1 tgt_mtob_l1 tgt_bhr_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_roa_l1 tgt_che_assets_l1 tgt_rd_assets_l1 tgt_ln_age_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt, absorb(target_sic3 year) vce(cluster FIPS)

esttab using Table8.csv, $repoption mtitles("Combined CAR" "Target CAR") append



********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 9                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************


use "C:\Patent Library and M&A\Data\Sample for Table9.dta", clear
cd "C:\Patent Library and M&A\Results"

est clear
foreach zz in ln_combined_npat ln_comb_cite_wt_npat{
eststo: reghdfe `zz' c.library##c.post ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 ln_population_l1 income_percap_K_l1, absorb(deal_number year) vce(robust)
eststo: reghdfe `zz' c.library##c.post ln_comb_at_l1  comb_asset_tan_l1 comb_sale_g_l1 comb_lev_l1 comb_rd_assets_l1 comb_roa_l1 comb_tobinq1_l1 comb_bhr_l1 ln_population_l1 income_percap_K_l1, absorb(deal_number year) vce(robust)
}
esttab using Table9.csv, $repoption mtitles("Combined NPat" "Combined NPat" "Combined Citation wt NPat" "Combined Citation wt NPat")replace       


********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 10                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************
use "C:\Patent Library and M&A\Data\Sample for Table10.dta", replace

eststo clear

foreach zz in co_pat_pct co_cites_pct{
preserve
foreach x in `zz'{
	drop if `x'==.
}
eststo: reghdfe `zz' library ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj year) vce(cluster FIPS)
eststo: reghdfe `zz' library ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 tgt_ln_assets_l1 tgt_asset_tan_l1 tgt_sale_g_l1 tgt_lev_l1 tgt_rd_assets_l1 tgt_roa_l1 tgt_tobinq1_l1 tgt_bhr_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj target_sic3 year) vce(cluster FIPS)

restore
}
esttab using Table10.csv, $repoption mtitles("co-pat pct" "co-pat pct" "co-cite pct" "co-cite pct" )replace

********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 11                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************

use "C:\Patent Library and M&A\Data\Sample for Table11.dta", clear

cd "C:\Patent Library and M&A\Results"

est clear
foreach vv in allfile 10or8K 10KQ {
eststo: reghdfe keyword_ratio_`vv' c.library ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 deal_ratio cash_dummy high_tech_dummy diversify_dummy hostile_dummy challenge_dummy public_tgt ln_population_l1 income_percap_K_l1, absorb(sic3_adj year) vce(cluster FIPS)
}
esttab using Table11.csv, $repoption title("SIC3+Year FE" "County Clustered SE") replace       


********************************************************************************
********************************************************************************
*****                                                                      *****
*****                                                                      *****
*****                                 Table 12                              *****
*****                                                                      *****
*****                                                                      *****
********************************************************************************
********************************************************************************
use "C:\Patent Library and M&A\Data\Sample For Table12_Size_Matched.dta", clear
 
est clear
eststo: reghdfe ratio_refer_target c.actual_pair#(c.library#c.post c.library c.post) c.library#c.post c.library c.post c.actual_pair ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 ln_tgt_npat_app_l1 ln_acq_npat_app_l1, absorb(deal_number year) vce(robust)

********************************************************************************
********************************************************************************

use "C:\Patent Library and M&A\Data\Sample For Table12_Size&MB_Matched.dta", clear

eststo: reghdfe ratio_refer_target c.actual_pair#(c.library#c.post c.library c.post) c.library#c.post c.library c.post c.actual_pair ln_assets_l1 asset_tan_l1 sale_g_l1 lev_l1 rd_assets_l1 roa_l1 tobinq1_l1 bhr_l1 ln_tgt_npat_app_l1 ln_acq_npat_app_l1, absorb(deal_number year) vce(robust)
esttab using Table12.csv, $repoption replace 	  

log close
