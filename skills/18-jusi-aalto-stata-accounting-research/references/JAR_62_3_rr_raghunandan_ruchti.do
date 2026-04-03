*** THIS FILE SHOULD BE CALLED FROM WITHIN osha_descriptives_20_04_16.do. IT IS NOT A STANDALONE FILE!!! ****
* The code below processes raw osha_violation... csv files so that there is one obs per activity_nr

** Types of violations 
gen repeat_viol = (viol_type == "R")
gen willful_viol = (viol_type == "W")

sort activity_nr
foreach v of varlist repeat_viol willful_viol {
	gen `v'_current_pen = `v' * current_penalty
	by activity_nr: egen `v'_current_pen_tot = sum(`v'_current_pen)
}

sort activity_nr
by activity_nr: egen num_repeat_viol = sum(repeat_viol)
by activity_nr: egen num_willful_viol = sum(willful_viol)
by activity_nr: egen current_pen_tot = sum(current_penalty)



keep activity_nr num_repeat_viol num_willful_viol current_pen_tot *_current_pen_tot 
duplicates drop // should now have 1 obs per activity_nr
gen has_violation = 1 

sort activity_nr 
cd Data // change this to file path where data is housed

******* PREPROCESS VIOLATION DATA ************
* Begin with the raw OSHA violation data (all downloaded 04/2020)
** Raw OSHA violation data is downloaded in multiple files from OSHA website due to size

import delimited using osha_violation12.csv, clear 
sort activity_nr

// for formatting compatability w/older files, need to make these vars strings -- though we never actually use these vars
	tostring abate_complete, replace 
	tostring emphasis, replace
	tostring hazcat, replace
	tostring fta_issuance_date, replace
	tostring fta_contest_date, replace
	tostring fta_final_order_date, replace

* One activity_nr can have multiple violations, each with its own row. The routine provided in the do-file below aggregates the violation data to the activity_nr level
do aggregate_osha_violation_v2.do 

save osha_violations_by_activity_nr, replace

import delimited using osha_violation11.csv, clear 
	do aggregate_osha_violation_v2.do
	sort activity_nr
	append using osha_violations_by_activity_nr
	save osha_violations_by_activity_nr, replace

import delimited using osha_violation10.csv, clear 
	do aggregate_osha_violation_v2.do
	sort activity_nr
	append using osha_violations_by_activity_nr
	save osha_violations_by_activity_nr, replace

import delimited using osha_violation9.csv, clear 
	do aggregate_osha_violation_v2.do
	sort activity_nr
	append using osha_violations_by_activity_nr
	save osha_violations_by_activity_nr, replace

import delimited using osha_violation8.csv, clear 
	do aggregate_osha_violation_v2.do
	sort activity_nr
	append using osha_violations_by_activity_nr
	save osha_violations_by_activity_nr, replace

import delimited using osha_violation7.csv, clear 
	do aggregate_osha_violation_v2.do
	sort activity_nr
	append using osha_violations_by_activity_nr
	save osha_violations_by_activity_nr, replace

	
import delimited using osha_violation6.csv, clear 
	do aggregate_osha_violation_v2.do
	sort activity_nr
	append using osha_violations_by_activity_nr
	duplicates drop activity_nr, force
	sort activity_nr
	save osha_violations_by_activity_nr, replace



	


******* PREPROCESS INSPECTION DATA ************
** Begin with the raw OSHA inspection data (downloaded 04/2020).
*** Raw OSHA inspection data is downloaded in multiple files from OSHA website due to size (each file has 1 million obs). Append it all together

import delimited using osha_inspection4.csv, clear
sort activity_nr
save osha_inspection_ID_info_all, replace

import delimited using osha_inspection3.csv, clear
sort activity_nr
append using osha_inspection_ID_info_all
save osha_inspection_ID_info_all , replace

import delimited using osha_inspection2.csv, clear
sort activity_nr
append using osha_inspection_ID_info_all
save osha_inspection_ID_info_all , replace

import delimited using osha_inspection1.csv, clear
sort activity_nr
append using osha_inspection_ID_info_all
save osha_inspection_ID_info_all , replace

import delimited using osha_inspection0.csv, clear
sort activity_nr
append using osha_inspection_ID_info_all

gen open_year = substr(open_date,1,4)
	destring open_year, replace
	drop if open_year < 1997
rename estab_name company_OSHA
rename site_zip zipcode_OSHA 

save osha_inspection_ID_info_all, replace // full OSHA inspection data -- reload this shortly

** Now export OSHA inspection info for fuzzy matching + hand-checking of matches
keep if owner_type == "A" // private firms only
keep activity_nr reporting_id host_est_key estab_name site_state site_address site_zip sic_code naics_code mail_street mail_zip open_date


** The below file, after fuzzy matching and hand checking, ultimately yields the linktable in OSHA_compustat_linktable.dta
export delim using osha_inspection_ID_info_all.csv, replace
** It's sufficient to fuzzy match the inspection data; this can be merged to violation data using activity_nr
** To fuzzy match, we rely on an initial match - for which we hand-verified matches - done by Rich Puchalsky. We supplemented this with further matching to ReferenceUSA done using Stata's reclink command, again hand-checking all matches. 


*** Read back in inspection data, merge with linktable that resulted from hand checks of fuzzy matches
u osha_inspection_ID_info_all.dta, clear

merge company_OSHA year zipcode_OSHA open_year using OSHA_compustat_linktable.dta // linktable is hand-checked output, derived from csv file exported above 
	keep if _merge == 3
	drop _merge

so gvkey year

save osha_inspections_merged_to_compustat, replace

* Merge to preprocessed violation data
so activity_nr
merge 1:1 activity_nr using osha_violations_by_activity_nr, keep(1 3) // all violations have a corresponding inspection; clean inspections do not have a violation
	drop _merge
	replace has_violation = 0 if has_violation == .

save osha_inspections_violations_merged, replace






*********** Construction of main dataset used for analyses starts here ****************
u OSHA/osha_inspections_violations_merged.dta, clear // all individual OSHA inspections and violations for which we were able to identify a gvkey through our fuzzy matching procedures
	gen open_month = substr(open_date,6,2)
		destring open_month, replace
	gen open_day = substr(open_date,9,2)
		destring open_day, replace
	gen open_date_statafmt = mdy(open_month, open_day, open_year)
	
	
	
* First, merge to Compustat to correctly match fiscal year to violations. (Then drop - we will merge with Compustat again later post-aggregation to get control vars)
	so gvkey year
	merge m:1 gvkey year using Compustat_all_1995_2019, keep(3)
		drop _merge		
		keep activity_nr - open_date_statafmt datadate_statafmt 
		gen distance_to_end = datadate_statafmt - open_date_statafmt
		replace year = year + 1 if distance_to_end < 0 // if fiscal year t ends before calendar year t
		replace year = year - 1 if distance_to_end > 365
	
* A=Accident. B=Complaint. C=Referral. D=Monitoring. E=Variance. F=FollowUp. G=Unprog Rel. H=Planned. I=Prog Related. J=Unprog Other. K=Prog Other. L=Other-L. M=Fat/Cat

gen num_inspections = 1
gen discret_inspection = (insp_type=="D"|insp_type=="E"|insp_type=="F"|insp_type=="G"|insp_type=="I"|insp_type=="J"|insp_type=="K"|insp_type=="L") 
gen whistle_blown = (insp_type=="B"|insp_type=="C")
gen planned_insp = (insp_type == "H")

replace current_pen_tot = 0 if current_pen_tot == .
replace num_repeat = 0 if num_repeat == .
replace num_willful = 0 if num_willful == .
	gen inspection_has_repeat = num_repeat > 0
	gen inspection_has_willful = num_willful > 0
	gen inspection_has_RW = inspection_has_repeat + inspection_has_willful  - inspection_has_repeat*inspection_has_willful // repeat OR willful 
	



collapse (sum) num_inspections discret_inspection whistle_blown planned_insp has_violation inspection_has* current_pen_tot, by(gvkey site_state year)

	rename has_violation num_sites_with_violations
	rename inspection_has_repeat num_inspection_has_repeat
	rename inspection_has_willful num_inspection_has_willful
	rename inspection_has_RW num_inspection_has_RW

	

rename site_state state
so gvkey state year
merge gvkey state year using "refUSA_firm_state_estabs_w_gvkey.dta" //aggregated ReferenceUSA data with # of firm-state-year estabs
	gen log_estabs = log(firm_state_estabs)

gen stateplan = (state=="AK"|state=="WA"|state=="OR"|state=="CA"|state=="HI"|state=="NV"|state=="AZ"|state=="UT"|state=="NM"|state=="WY"|state=="MN"|state=="IA"|state=="MN"|state=="MI"|state=="IN"|state=="KY"|state=="TN"|state=="VA"|state=="NC"|state=="SC"|state=="MD"|state=="VT")
	
	
drop if (year < 2002 | year > 2017)
	drop if _merge == 1
	drop _merge

foreach v of varlist num_*   *_state_* *pen_tot {
	qui replace `v' = 0 if `v' == .
}


so gvkey year
merge gvkey year using ../../Generally_Useful_Data/Compustat_all_1995_2019
	drop if _merge == 1
	gen non_violation_year = (_merge == 2)
	drop _merge
	drop if year < 2001
	drop if year > 2017 


so gvkey
by gvkey: egen total_inspections_allyears = sum(num_inspections) // drop firms that were never even inspected
	drop if total_inspections_allyears == 0
by gvkey: egen max_year_in_data = max(year)
	drop if max_year_in_data <= 2002

tostring gvkey, gen(gvkey_string)
	drop if state == "PR"
	drop if state == "VI"
	drop if state == ""
	gen firmstate = gvkey_string + state 
	drop gvkey_string 
encode firmstate, gen(firmstate_enc)

* some basic financial information
xtset firmstate_enc year
capture gen roa = ni/l1.at
	winsor roa, p(0.01) gen(roa_wins) // just to eyeball - winsorize again before running regs
gen lev = dltt/at
	winsor lev, p(0.01) gen(lev_wins) // just to eyeball - winsorize again before running regs
gen roe = ni/(l1.prcc_f * l1.csho)
	winsor roe, p(0.01) gen(roe_wins) // just to eyeball - winsorize again before running regs
gen mkt_to_book = prcc_f/bkvlps 
	winsor mkt_to_book, p(0.01) gen(mtb_wins) // just to eyeball - winsorize again before running regs
rename sich sic4
	gen sic2 = floor(sic4/100)
gen lassets = log(at)
	
so gvkey year	
foreach v of varlist num_inspections - num_inspection_has_RW {
	replace `v' = 0 if `v' == . 
	gen log_`v' = log(1+`v')
}

rename num_sites_with_violations num_violation 
rename num_inspection_has_RW num_RW
rename discret_inspection num_discret
rename whistle_blown num_whistle
rename planned_insp num_planned 


foreach v of varlist num_violation num_inspections num_RW num_discret num_whistle num_planned {
	rename `v' `v'_instate
}


***** Calculate out-of-state violations and inspections

* All violations
bys gvkey year: egen num_violations_FY = sum(num_violation_instate)
	gen num_violation_outofstate = num_violations_FY - num_violation_instate

* RW violations
bys gvkey year: egen num_RW_FY = sum(num_RW_instate)
	gen num_RW_outofstate = num_RW_FY - num_RW_instate

* All inspections
by gvkey year: egen num_inspections_FY = sum(num_inspections_instate)
	gen num_inspections_outofstate = num_inspections_FY - num_inspections_instate

* Discretionary inspections
by gvkey year: egen num_discret_FY = sum(num_discret_instate)
	gen num_discret_outofstate = num_discret_FY - num_discret_instate
	
*Planned inspections
by gvkey year: egen num_planned_FY = sum(num_planned_instate)
	gen num_planned_outofstate = num_planned_FY - num_planned_instate

*Whistleblower-driven inspections
by gvkey year: egen num_whistle_FY = sum(num_whistle_instate)
	gen num_whistle_outofstate = num_whistle_FY - num_whistle_instate



foreach v of varlist num_violation_* num_inspections_* num_discret_* num_whistle_* num_planned_* num_RW_* {
	gen xx`v' = `v' > 0 if `v' != .
}
rename (xxnum*) (has*) // this creates the indicator vars for in/out of state violations/inspections


save OSHA_compustat_firmstate, replace



*

************ Analyst forecast data *******************
* See bottom of file for creation of ibes_aggregated.dta 
merge m:1 gvkey year using ibes_aggregated.dta, keep(1 3) // IBES analyst forecast data from WRDS, merged to gvkey, aggregated from details file
	drop _merge
	drop if year < 2002
	drop if year > 2017 

* meet-or-beat w/r/t analyst forecasts
gen ana_est_diff_mean_street = actual_street - mean_forecast_street 
	gen meetorbeat1_mean_street = (ana_est_diff_mean_street  <= 0.01) & (ana_est_diff_mean_street  >= 0 ) if actual_street != .



************ BOARD INDEPENDENCE ***********************
* See bottom of file for creation of director_independence_year.dta
sort cik year
merge m:1 cik year using director_independence_year.dta, keep(1 3)
	drop _merge



*********** NON-OSHA VIOLATION HISTORY **************
* See bottom of file for creation of non_OSHA_violations.dta 
sort cik year
merge m:1 cik year using non_OSHA_violations // from Violation Tracker
	drop if _merge == 2
	drop _merge

* Now merge in the list of all unique CIKs found at least once in GJF's databases -- 
* For any CIK outside this list we cannot be sure if a firm's absence is a true zero or GJF not having parent-subsidiary matches available to identify violations
sort cik
merge m:1 cik using "CultureVariables/cik_in_SubsidyTracker"
	gen in_ST = (_merge == 3)
	drop if _merge == 2
	drop _merge
	
sort cik
merge m:1 cik using "CultureVariables/cik_in_ViolationTracker"
	gen in_VT = (_merge == 3)
	drop if _merge == 2
	drop _merge

replace penalties_not_OSHA = 0 if penalties_not_OSHA == . & (in_VT == 1 | in_ST == 1) 
replace penalties_not_OSHA_3year = 0 if penalties_not_OSHA_3year== . & (in_VT == 1 | in_ST == 1)

gen has_non_OSHA = (penalties_not_OSHA != .)
xtile non_OSHA_decile = penalties_not_OSHA_3year, nq(10)


sort firmstate year
save OSHA_compustat_firmstate, replace // final dataset for main analyses












**********************************************************************************
************ IBES ******************
use "ibes_EPS_DETAIL_2000_2019.dta", clear
	rename *, lower
	drop if cusip == ""
	keep if measure == "EPS"

rename actual actual_street 
rename value mean_forecast_street // prior to collapse command 
drop if cusip == ""
gsort cusip fpedats analys -anndats -anntims // keep last forecast by each analyst
	duplicates drop cusip fpedats analys , force 

* Drop forecasts made > 180 days and < 4 days before announcement date, following Caskey and Ozel 2017
gen forecast_timing = anndats_act - anndats
keep if ((forecast_timing >= 4) & (forecast_timing <= 180))

collapse (mean) mean_forecast_street actual_street, by(cusip fpedats )
	* Fiscal year end year/month, for merging with gvkeys
	gen fyear_end_year = year(fpedats)
	gen fyear_end_month = month(fpedats)

rename cusip ncusip
merge 1:1 ncusip fyear_end_month fyear_end_year using cusip_gvkey_linktable, keep(3)
	drop _merge
	drop if gvkey == . 

rename fyear year
keep gvkey year mean_forecast_street actual_street 

save ibes_aggregated, replace

************* NON-OSHA VIOLATIONS *************
import delim "VT_with_historical_parents.csv", clear // Violation Tracker data, with hand-collected historical parent info -- now provided standard as part of VT
	drop if cik == .
	rename pen_year year

keep cik year penalty_adjusted agency_code 
	drop if cik == . 

gen penalties_not_OSHA = penalty_adjusted * (agency_code != "OSHA")

collapse (sum) penalties_not_OSHA , by(cik year)

save Data/CultureVariables/non_OSHA_violations, replace


************* BOARDEX ********************
u na_dir_characteristics.dta, clear // raw BoardEx director-level data from WRDS

sort BoardID year

merge m:1 BoardID using boardex_ID_CIK, keep(3) // boardex BoardID - CIK link, pulled from WRDS company-level data
	drop _merge

sort cik year

drop if year < 2000
drop if year > 2017

by cik year: egen numDirectorNonExecutive = sum(NonExecutiveDirector)
by cik year: egen numBoardMember = sum(RowType=="Board Member")
by cik year: egen numDisclosedEarner = sum(RowType=="Disclosed Earner")


duplicates drop cik year, force // pare down to 1 obs per board-year
keep cik year num* 

gen board_indep_percentage = numDir/(numBoard + numDiscl)

sort cik year



save director_independence_year, replace
