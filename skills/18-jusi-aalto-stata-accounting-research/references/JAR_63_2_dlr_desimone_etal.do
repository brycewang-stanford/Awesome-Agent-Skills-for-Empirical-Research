/*******************************************************************************************************************************************
/*THIS FILE CLEANS STATE DATA OBTAINED FROM MICHIGAN STATE INSTITUTE FOR PUBLIC POLICY AND SOCIAL RESEARCH.
THE FILE WAS DOWNLOADED FROM THIS PAGE: http://ippsr.msu.edu/public-policy/correlates-state-policy*/
*******************************************************************************************************************************************/

clear 
cd ~ 

log using "msu_data_cleaning.log", replace nomsg


****************************************RETAIN ONLY THE STATES AND YEARS OF OUR SAMPLE********************************************************

import excel "IPPSR_dataset.xlsx", firstrow
save raw_msu_data, replace 

use raw_msu_data, clear 
*Retain only data for 27 states in sample
/*sort stateno
by stateno: keep if _n==1
tab state stateno*/

keep if stateno == 1 | stateno == 3 | stateno == 5 | stateno == 7 | stateno == 9 | stateno == 10 | stateno == 13 | stateno == 14 | stateno == 16 | stateno == 17 | stateno == 18 | stateno == 19 | stateno == 20 | stateno == 21 | stateno == 23 | stateno == 25 | stateno == 27 | stateno == 28 | stateno == 31 | stateno == 32 | stateno == 35 | stateno == 36 | stateno == 38 | stateno == 40 | stateno == 43 | stateno == 46 | stateno == 49

tab year 

keep if year > 2007
keep if year < 2016
tab year 

****************************************RETAIN RELEVANT GOVERNMENT VARIABLES********************************************************

*Political Variables

keep st stateno state state_fips state_icpsr year  /*political variables*/ gub_election govparty_a per_leg_of_govs_pty /*Corruption/"Hiding Pork" Variables*/ drecord reports /*Sophistication Variables*/ wallstreet_best_run

save cleaned_msu_data, replace 

clear
import excel "State Partisan Composition\state partisan details.xlsx", firstrow
save leg_gov_party, replace 

use cleaned_msu_data, clear
sort state year
merge m:1 state year using leg_gov_party
drop _merge
gen per_leg_of_govs_pty_n = real(per_leg_of_govs_pty)
drop per_leg_of_govs_pty

gen same_party_control_n = real(same_party_control)
drop same_party_control 

gen drecord_n = real(drecord)
drop drecord

gen reports_n = real(reports)
drop reports


gen same_party_var = same_party_control_n
replace same_party_var = 0 if year == 2008 & per_leg_of_govs_pty_n < 50
replace same_party_var = 1 if year == 2008 & per_leg_of_govs_pty_n >= 50

drop per_leg_of_govs_pty_n
drop same_party_control_n

save cleaned_msu_data_final, replace 

log close**************** STEP 1: CREATE SUBSIDY DATA ****************************


preserve
	import delim Subsidies/state_subsidy_state_sample, clear
	sort state
	save Subsidies/state_subsidy_state_sample, replace


	import delim Subsidies/local_subsidy_county_sample, clear
	sort area_fips
	save Subsidies/local_subsidy_county_sample, replace
restore


preserve
	import delim Subsidies/subsidy_program_job_disclosure, clear
	so state program
	save Subsidies/subsidy_program_job_disclosure.dta, replace
	
restore

import delim Subsidies/subsidy_data_december2021_version.csv, clear
	capture rename ïstate state
	destring sub_year, replace
	drop if countyfips == .
	drop if sub_year < 2008
	drop if sub_year > 2019
		so state
		merge state using Subsidies/state_subsidy_state_sample
		qui gen in_statesample = (_merge == 3)
		drop _merge
	drop if countyfips == 36061 & subsidy_type == "multiple" // These are NYC local subsidies 
	qui replace subsidy_type = "grant" if subsidy_type == "multiple" // Minnesota local subsidies, non-JOBZ related grants. Note -- this line of code may not generalize to future versions of Subsidy Tracker.

rename countyfips area_fips
	so area_fips 
	merge area_fips using Subsidies/local_subsidy_county_sample
		qui gen in_localsample = (_merge == 3) & (subsidy_level == "local" | subsidy_level == "Local")
		drop _merge
	
drop if (in_localsample == 0) & (in_statesample == 0)

qui replace subsidy_level = "state" if subsidy_level == "State"
qui replace subsidy_level = "local" if subsidy_level == "Local"
qui replace subsidy_level = "state" if subsidy_level == "multiple" // these are megadeals -- we attribute to the state b/c they have huge state component and state is primary funder. Local-only megadeals are already labeled as such

* Now drop specific programs given data quality issues
	drop if state == "TX" & program == "Moving Image Industry Incentive Program" 
	drop if state == "MO" & program == "Chapter 100 Industrial Revenue Bonds"
	drop if state == "OH" & program == "Business Assistance Program"
	drop if state == "AZ" & program == "Government Property Lease Excise Tax (GPLET)"
	drop if state == "MD" & program == "Research and Development Tax Credit"
	drop if state == "KS" & program == "Promoting Employment Across Kansas (PEAK)"
	qui replace program = "Virginia Investment Partnership and Major Eligible Employer Grant" if state == "VA" & program == "Major Eligibile Employer Grant"
	
qui replace subsidy_type = "tax increment financing" if subsidy_type == "Tax Increment Financing"

qui gen subsidy_overall_type = ""
qui replace subsidy_o = "TIF" if (subsidy_t == "tax increment financing")
qui replace subsidy_o = "taxcredit" if (subsidy_t == "tax credit"|subsidy_t == "tax credit/rebate and grant"|subsidy_t=="tax credit/rebate"|subsidy_t=="tax credit/rebate "|subsidy_t=="tax credit/rebate; property tax abatement"|subsidy_t=="Tax Credit/Rebate"|subsidy_t=="Tax credit/rebate")
qui replace subsidy_o = "taxabatement" if (subsidy_t=="property tax abatement"|subsidy_t=="property tax abatement "|subsidy_t=="Property tax abatement"|subsidy_t=="tax abatement"|subsidy_t=="tax exemption"|subsidy_t=="sales tax exemption")
qui replace subsidy_o = "reimbursement" if (subsidy_t=="training reimbursement"|subsidy_t=="training reimbursement "|subsidy_t=="cost reimbursement"|subsidy_t=="fee waiver")
qui replace subsidy_o = "enterprise_zone" if (subsidy_t=="Enterprise Zone"|subsidy_t=="Enterprize Zone"|subsidy_t=="Enterprise zone"|subsidy_t=="enterprise zone")
qui replace subsidy_o = "grant" if (subsidy_t=="grant"|subsidy_t=="Grant"|subsidy_t=="grant/low-cost loan"|subsidy_t=="grant/loan hybrid program"|subsidy_t=="infrastructure assistance"|subsidy_t=="industrial revenue bond"|subsidy_t=="grant/loan hybrid program ")
qui replace subsidy_o = "megadeal" if (subsidy_t == "MEGADEAL"|subsidy_t == "megadeal")
qui replace subsidy_o = "financing" if (subsidy_t == "loan"|subsidy_t=="bond"|subsidy_t=="loan or bond financing"|subsidy_t=="venture capital")

sort area_fips sub_year

recast str818 company, force // so that this is not strL for merging

sort state company sub_year subsidy_type
save Subsidies/subs_data_trimmed, replace

*********** Now merge in our hand classification of subsidy types by program
import excel ../JAR/Subsidy_Disclosure_Examples/megadeal_subsidy_type_classification_v2.xlsx, first clear
	keep state company sub_year subsidy_type WorkerTraining - Other
	drop Attraction
	foreach v of varlist WorkerTraining - Other {
		qui replace `v' = 0 if `v' == .
		rename `v' `v'_mega
	}
sort state company sub_year subsidy_type

merge state company sub_year subsidy_type using Subsidies/subs_data_trimmed
drop if _merge == 1
drop _merge
recast str818 program 
sort state program
save Subsidies/subs_data_trimmed, replace

* List of programs 
import excel Subsidies/state_subsidy_program_list_samplestates_updated.xlsx, first clear
	drop Establishments - EmploymentWages // deprecated classification scheme
	drop if type_GJF == "MEGADEAL" & (program != "Missouri Automotive Manufacturing Jobs" & program != "Missouri Works" & program != "Enterprise Zone") // Coding of megadeals derived from elsewhere, not here

keep state program WorkerTraining - Other
foreach v of varlist WorkerTraining - Other {
	qui replace `v' = 0 if `v' == .
}

sort state program	
merge state program using 	Subsidies/subs_data_trimmed
	drop _merge
rename sub_year year


so state program subsidy_type agency
merge state program subsidy_type agency using Subsidies/local_sub_program_classifications
	drop _merge

foreach v of varlist WorkerTraining - Infrastructure Innovation - Other {
	qui replace `v' = `v'_mega if subsidy_type == "MEGADEAL" & (program != "Missouri Automotive Manufacturing Jobs" & program != "Missouri Works" & program != "Enterprise Zone") 
}






qui replace Employment = 1 if WorkerTraining == 1	


qui gen Emp_NoGrantR = Employment * ((subsidy_overall_type != "reimbursement") & (subsidy_overall_type != "grant"))
qui gen Emp_GrantR = Employment * ((subsidy_overall_type == "reimbursement") | (subsidy_overall_type == "grant"))

qui gen NoEmploy = (Employment != 1)
qui gen NoEmployNoGR = (Emp_NoGrantR != 1)
qui gen NoEmployGR = (Emp_GrantR != 1)

	

save Subsidies/subs_data_trimmed, replace



use Subsidies/subs_data_trimmed, clear 

merge m:1 state program using program_level_disclosure_years
	drop _merge
	qui gen early_program_ext = (year_external < 2012) if year_external != . // cut the sample in half
	qui gen internal_disclosure = (year >= year_internal) if subsidy_level == "state" // since missing > all values in Stata, this line is fine
	qui gen internal_disclosure_NOGENLAW = (year >= year_internal) & (general_law_flag != 1) if subsidy_level == "state" // since missing > all values in Stata, this line is fine

	qui gen external_disclosure = (year >= year_external) if subsidy_level == "state" // since missing > all values in Stata, this line is fine
	qui gen external_disclosure_NOGENLAW = (year >= year_external) & (general_law_flag != 1) if subsidy_level == "state" // since missing > all values in Stata, this line is fine
	
	qui replace internal_disclosure = 1 if external_disclosure == 1
	qui replace internal_disclosure_NOGENLAW = 1 if external_disclosure_NOGENLAW == 1
	
	qui gen external_newinfo = (year_internal >= year_external) * (year_external != .) if subsidy_level == "state"
	qui gen external_newinfo_NOGENLAW = ((year_internal >= year_external) * (year_external != .) ) & (general_law_flag != 1) if subsidy_level == "state"
	
	qui gen external_pre12 = external_disclosure * early_program_ext if subsidy_level == "state"
	qui gen external_pre12_NOGENLAW = external_disclosure_NOGENLAW * early_program_ext if subsidy_level == "state"
merge m:1 state program using "Subsidies/online_programs_after_external_strict"	
	qui gen external_disclosure_online = 1 if _merge == 3
		qui replace external_disclosure_online = 0 if external_disclosure_NOGENLAW == 0
		qui replace external_disclosure_online = 0 if external_disclosure_online == . & subsidy_level == "state"
	drop _merge
	
	
collapse (sum) subsidy_adjusted (mean) disclosed_online internal_disclosure* external_disclosure* external_newinfo* external_pre12* WorkerTraining Employment NoEmploy NoEmployGR NoEmployNoGR Other Relocation RetainExpand Emp_NoGrantR Emp_GrantR, by(area_fips state year company program subsidy_overall_type subsidy_level) // account for the fact that some subsidy programs disaggregate and some don't

*** Export unique subsidy programs w/external disclosure
/*
preserve
	keep if external_disclosure == 1
	qui gen stfips = floor(area_fips/1000)
	duplicates drop stfips program year, force
	keep stfips program year external_disclosure external_disclosure_NOGENLAW 
	drop if external_disclosure == 0
	
	export delim Subsidies/programs_with_external_disclosure
restore
*/

qui gen subs_TIF = subsidy_adjusted if subsidy_o == "TIF"
qui gen subs_taxcredit = subsidy_adjusted if subsidy_o == "taxcredit"
qui gen subs_taxabatement = subsidy_adjusted if subsidy_o == "taxabatement"
qui gen subs_reimbursement = subsidy_adjusted if subsidy_o == "reimbursement"
qui gen subs_EZone = subsidy_adjusted if subsidy_o == "enterprise_zone"
qui gen subs_grant = subsidy_adjusted if subsidy_o == "grant"
qui gen subs_financing = subsidy_adjusted if subsidy_o == "financing"
qui gen subs_megadeal = subsidy_adjusted if subsidy_o == "megadeal"

foreach v of varlist subs_TIF - subs_megadeal {
	qui gen st_`v' = `v' * (subsidy_level == "state")

}
* Now classify subsidies according to type/purpose 
foreach v of varlist WorkerTraining Employment  Other NoEmploy NoEmployGR NoEmployNoGR Emp_GrantR Emp_NoGrantR  {
	qui gen subs_`v'_st = subsidy_adjusted if `v' == 1 & subsidy_level == "state" 
}

****Clean up program names ****
preserve
	import excel "Subsidies/clean_program_names.xlsx", first clear // manually cleaned-up program names 
	rename program_raw_GJF program
	save "Subsidies/clean_program_names", replace
restore
	

**** SAVE A VERSION FOR DESCRIPTIVES PARTITIONED BY DISCLOSURE **********

merge m:1 state program using "Subsidies/clean_program_names", keep(1 3)
	drop _merge
	rename program program_raw_GJF
	rename program_clean program

preserve
	keep if subsidy_level == "state"
	merge m:1 area_fips year using "county_years_in_sample_final", keep(3)
	save "subsidies_in_final_sample", replace

restore 

preserve
	keep if subsidy_level == "state"
	merge m:1 area_fips year using "county_years_in_sample_with_megadeals_2023_03_31", keep(3)
	save "subsidies_in_final_sample_with_megadeals", replace

restore
	
	


foreach v of varlist subs_* {
	qui gen count_`v' = `v'
	qui gen nonzero_`v' = `v' if (`v' > 0)
}
 
foreach v of varlist st_* {
	qui gen count_`v' = `v' if subsidy_level == "state"
	qui gen nonzero_`v' = `v' if (`v' > 0) & (subsidy_level=="state")
	qui gen count_`v'Emp = `v' if subsidy_level == "state" & Employment == 1
	qui gen nonzero_`v'Emp = `v' if (`v' > 0) & subsidy_level == "state" & Employment == 1
	qui gen `v'_Emp = `v' if Employment == 1
	qui gen `v'_EGR = `v' if Employment == 1 & ((subsidy_overall_type == "grant") | (subsidy_overall_type == "reimbursement"))
	
	qui gen intDisc_`v' = `v' if subsidy_level == "state" & (internal_disclosure == 1 | external_disclosure == 1)
		qui gen intDisc_NG_`v' = `v' if subsidy_level == "state" & (internal_disclosure_NOGENLAW == 1 | external_disclosure_NOGENLAW == 1) // NG = not counting disclosure via general law
	qui gen extDisc_`v' = `v' if subsidy_level == "state" & external_disclosure == 1
		qui gen extDisc_NG_`v' = `v' if subsidy_level == "state" & external_disclosure_NOGENLAW == 1 // NG = not counting disclosure via general law
}




foreach v of varlist  Employment Other  NoEmploy NoEmployGR NoEmployNoGR Emp_GrantR Emp_NoGrantR {
	gen intDisc_`v' = count_subs_`v'_st if internal_disclosure == 1 & subsidy_level == "state"  
		gen intDisc_NG_`v' = count_subs_`v'_st if internal_disclosure_NOGENLAW == 1  & subsidy_level == "state" // NG = not counting disclosure via general law
	gen extDisc_`v' = count_subs_`v'_st if external_disclosure == 1 & subsidy_level == "state"  
		gen extDisc_NG_`v' = count_subs_`v'_st if external_disclosure_NOGENLAW == 1  & subsidy_level == "state" // NG = not counting disclosure via general law
}




collapse (count) count_* nonzero_* intDisc* extDisc* (sum) subs_* st_* , by(area_fips year)


save Subsidies/subsdata_bytype.dta, replace

********* DISCLOSURE AND SUBSIDY CLASSIFICATION
import excel ../JAR/state_subsidy_program_list_samplestates.xlsx, first clear
	drop Establishments - EmploymentWages // deprecated classification scheme
	drop if type_GJF == "MEGADEAL" & (program != "Missouri Automotive Manufacturing Jobs" & program != "Missouri Works" & program != "Enterprise Zone") // 

keep state program WorkerTraining - Other
foreach v of varlist WorkerTraining - Other {
	qui replace `v' = 0 if `v' == .
}

sort state program	

merge 1:1 state program using Subsidies/subsidy_program_job_disclosure.dta, keep(3)
	drop _merge

gen Investment = (Realty == 1 | Personalty == 1 | Infrastructure == 1) if (Realty != . & Personalty != . & Infrastructure != .)

foreach v of varlist WorkerTraining Employment Investment Realty Personalty Infrastructure Relocation RetainExpand Innovation Film Historical {
	tabstat ex_ante_job_disclosure if `v' == 1
}



******** CODE THAT PROCESSES PROGRAM-LEVEL DISCLOSURE YEARS INTO STATA FILE *************
/*
import excel "../JAR/Reviews 2/program_level_disclosure_years.xlsx", first clear

keep state program year_internal year_external general_law_flag

save "program_level_disclosure_years", replace
*/
*import delim Census/county_employable_populations.csv // Downloaded directly from Census public website
*sort area_fips year
*save county_pop_25_64, replace

/**** Census county-level education -- note that 2008 is derived from a different ACS file because the most recent version of the data becomes comprehensive only in 2009. Both files downloaded directly from Census public website
import excel "Census/ACS_2008_education_estimates_S1501_table56.xlsx", first clear
	qui replace year = year/1000 // clean up formatting in raw data
	keep fips year educ_college_pct_25up
	destring fips, replace
	keep if fips >= 1000 & fips < 100000 // only keep counties, not state-level obs
	rename educ_college_pct_25up percent_bachelors_degree
	qui replace percent_bachelors_degree = 100 * percent_bachelors_degree // standardize for later data
	save educ_county_year, replace
	
import delim "Census/educ_county_year", clear
	keep fips year percent_bachelors_degree
	append using educ_county_year
	rename fips area_fips
	rename percent_bachelors_degree county_educ_college_pct
	sort area_fips year
	save educ_county_year, replace
*/	

	
	
clear
import delim "countydata_agg_updated2022.csv", clear // output of R script that preprocesses data
rename fips_statecode state_fips
sort area_fips year

foreach v of varlist minwage_effective stategdp corp_tax_rate {
	qui replace `v' = "" if `v' == "NA"
	destring `v', replace
}


xtset area_fips year
qui gen annual_avg_emplvl_lead = f1.annual_avg_emplvl
qui gen total_annual_wages_lead = f1.total_annual_wages
qui gen annual_avg_estabs_lead = f1.annual_avg_estabs


preserve
import delim JPE_Data_Appendix/JPE_Data_Appendix/giroud_rauh_controls.csv, clear // data on control vars obtained from Giroud and Rauh (2019, JPE)
rename fips state_fips
sort state_fips year
save control_variables_all.dta, replace

* Supplement the Giroud and Rauh controls 
import delim StateGovt/GDP_by_state_allindustries.csv, clear
drop if geofips == 0
keep if description=="All industry total"
destring gdp, replace
qui gen state_fips = geofips/1000
keep state_fips year gdp 
rename gdp stateGDP
sort state_fips year
merge state_fips year using control_variables_all.dta
drop _merge
keep if year > 2002
sort state year
save control_variables_all.dta, replace

use control_variables_all, clear
	keep state_fips state 
	duplicates drop
	sort state_fips
save states_with_fips_codes, replace

import delim UnionMembership/UnionMembership_All.csv, clear
keep if sector=="Private"
drop if state=="#N/A"
keep state year mem cov mempctchange collbarg 
rename mem union_pct
drop if year < 2003
drop if year > 2015
sort state year
merge state year using control_variables_all.dta
drop _merge
sort state year
save control_variables_all.dta, replace

* college education -- state-year level (separate from county-year data above)
import delim Census/educ_state_year.csv, clear
drop if year < 2003
drop if year > 2015
sort state year
merge state year using control_variables_all.dta
drop _merge
sort state_fips year
save control_variables_all.dta, replace


restore


drop state
merge m:1 state_fips using states_with_fips_codes, keep(3)
	drop _merge

sort area_fips year
	merge area_fips year using educ_county_year
	drop if _merge == 2
	drop _merge

	* Replace 2008 education with 2009 if 2008 is missing, also create flag for such observations
	qui gen educ_county_imputed = (county_educ_college_pct == .) & (year == 2008)
	xtset area_fips year
	qui replace county_educ_college_pct = f1.county_educ_college_pct if educ_county_imputed == 1
	

sort area_fips year
	merge area_fips year using county_pop_25_64
	drop _merge

	
xtset area_fips year
sort area_fips year

qui gen population_25_64_lag1 = l1.population_25_64



*** DROP COUNTIES WHERE WE SOMETIMES SEE ZERO OBSERVATIONS FOR ESTABS/EMPS/WAGES ****
qui gen zero_estabs = (annual_avg_estabs_lead == 0)
qui gen zero_emps = (annual_avg_emplvl_lead == 0)
qui gen zero_wages = (total_annual_wages_lead == 0)
qui gen has_zero = zero_estabs + zero_emps + zero_wages
	qui replace has_zero = 1 if (has_zero == 2 | has_zero == 3)
bys area_fips: egen ever_has_zero_obs = sum(has_zero)
	drop if ever_has_zero_obs > 0 & ever_has_zero_obs != .

// NOTE: for estabs, emps, wages we use year t+1 (so if year=2008, then control variables all correspond to 2008 and but y-variable is 2009)
qui gen l_estabs = log(1+annual_avg_estabs_lead)
qui gen l_emps = log(1+annual_avg_emplvl_lead)
qui gen l_wage = log(1+total_annual_wages_lead)



* Scaling
qui replace corp_tax_rate = corp_tax_rate*100
qui replace corp_tax_rate_lag = corp_tax_rate_lag*100

rename xmem union_pct

encode state, gen(state_copy)

sort state year
merge state year using "NASB_data"
drop if _merge == 2
drop _merge

xtset area_fips year
qui gen expenditures_lag = l1.expenditures
qui gen totalresources_lag = l1.totalresources


sort state
merge state using "Subsidies/state_disclosure_ratings_all"
drop if _merge==2
drop _merge
sort area_fips year

merge 1:1 area_fips year using "Subsidies/subsdata_bytype"
drop if _merge == 2
drop _merge

rename *WorkerTraining* *WrkTrain*

sort state_fips year
sort area_fips year

* Logs where necessary
qui gen l_GDP = log(stategdp)
qui replace ui = "" if ui == "NA"
	destring ui, replace
	qui gen l_ui = log(ui)
qui gen logpop = log(population_25_64) // adult population
	drop if logpop == .


************ NOW CREATE RELEVANT VARIABLES FOR SUBSIDY-BY-TYPE ********************
format subs_* %15.2g

// this loop primarily exists because of the way stata handles missing (i.e., ".") data
foreach v of varlist count_subs* nonzero_subs* subs_* {
qui replace `v' = 0 if `v'==. 
}

foreach v of varlist count_subs* nonzero_subs*  {
	qui gen dum_`v' = (`v' > 0)
	qui replace dum_`v' = (`v' > 0)
}


**************** NOW CREATE OVERALL SUBSIDY VARIABLES ***************
qui gen subsidy_dollar_sum = subs_TIF + subs_taxcredit + subs_taxabatement + subs_reimbursement + subs_EZone + subs_grant + subs_megadeal + subs_financing
qui gen l_subs_amt = log(1+subsidy_dollar_sum)
capture drop subs_count
qui gen subs_count = (count_subs_TIF + count_subs_taxcredit + count_subs_taxabatement + count_subs_reimbursement + count_subs_EZone + count_subs_grant + count_subs_megadeal + count_subs_financing)
qui gen subs_dummy = (subs_count > 0)



foreach v of varlist l_GDP educ_college union_pct l_ui pr pinc tax_inc sal {
	qui gen lag_`v' = l1.`v'

}

* Sample period
drop if year < 2008 
drop if year > 2015 


sort area_fips year
by area_fips: egen nsubyears = total(subs_dummy)
qui gen never_received_subsidy = nsubyears == 0
qui gen ever_received_subsidy = nsubyears > 0
qui gen sub_recipient_otheryears = ever_received_subsidy - subs_dummy // This takes the value of 1 if the county gave subsidies in any other year, BUT not the present year. We can then drop these observations prior to matching.
drop nsubyears 



drop state
rename state_copy state // this is because we temporarily had to make state a STRING type for dropping purposes, but to be used as a factor variable in regressions it can't be a string


sort area_fips year



drop if state == .

decode state, gen(state_str)
	rename state state_copy
	rename state_str state
	sort state

***********************************GENERATE STATE SUBSIDY SAMPLE******************************************************
merge state using Subsidies/state_subsidy_state_sample 
	qui gen state_subs_keep = (_merge == 3)
	drop if (state_subs_keep == 0) 
	drop _merge
	
** State-level characteristics ("MSU data")
merge m:1 state year using "StateGovt/cleaned_msu_data_final_for_merging", keep(1 3)
	drop _merge

merge m:1 state year using "StateGovt/governor_party_and_elections", keep(1 3)
	drop _merge
	drop ag_party 


so area_fips year
** Subsidy count/dollar variables
qui gen sum_state_subsidies = st_subs_TIF + st_subs_taxcredit + st_subs_taxabatement + st_subs_financing + st_subs_EZone + st_subs_grant + st_subs_megadeal + st_subs_reimbursement
	qui gen count_state_subsidies = count_st_subs_TIF + count_st_subs_taxcredit + count_st_subs_taxabatement + count_st_subs_financing + count_st_subs_EZone + count_st_subs_grant + count_st_subs_megadeal + count_st_subs_reimbursement 
	qui gen nonzero_state_subsidies = nonzero_st_subs_TIF + nonzero_st_subs_taxcredit + nonzero_st_subs_taxabatement + nonzero_st_subs_financing + nonzero_st_subs_EZone + nonzero_st_subs_grant + nonzero_st_subs_megadeal + nonzero_st_subs_reimbursement 
	qui gen has_state_subsidy = count_state_subsidies > 0 if count_state_subsidies != .
		qui replace has_state_subsidy = 0 if has_state_subsidy == .
		by area_fips: egen ever_had_state_subsidy = sum(has_state_subsidy) 
		qui replace ever_had_state_subsidy = 1 if ever_had_state_subsidy > 0 & ever_had_state_subsidy != .

drop state
rename state_copy state // this is because we temporarily had to make state a STRING type for dropping purposes, but to be used as a factor variable in regressions it can't be a string

foreach v of varlist minwage_effective l_GDP union_pct corp_tax_rate l_ui pr pinc tax_inc sal  {
	destring `v', replace	
}
*************************************  GENERATE ALL POST-SUB AND COUNT VARIABLES *************************************
so area_fips year
by area_fips: egen nsubyears_state = total(has_state_subsidy)


egen first_sub_state = min(year / (has_state_subsidy==1)), by(area_fips)
	qui gen is_first_sub_state_year = (year == first_sub_state)

foreach x in "Employment" "NoEmploy" "NoEmployNoGR" "NoEmployGR" "Emp_GrantR" "Emp_NoGrantR"  {
	egen first_sub_`x'_yr_st = min(year / (dum_count_subs_`x'_st == 1) ), by(area_fips)
		qui gen is_1st_type_`x'_yr_st = (year == first_sub_`x'_yr_st)
		qui gen years_after_1st_`x'_st = year - first_sub_`x'_yr_st


	*********** running COUNTS *************
	qui gen temp_cnt_1_`x'_st = count_subs_`x'_st * is_1st_type_`x'_yr_st
		by area_fips: egen cnt_firstyr_`x'_st = sum(temp_cnt_1_`x'_st )
			qui replace cnt_firstyr_`x'_st = 0 if (year < first_sub_`x'_yr_st)
		qui gen log_firstyr_`x'_st = log(1+cnt_firstyr_`x'_st)
		drop temp_cnt_1_`x'_st

	by area_fips: gen running_cnt_`x'_st = sum(count_subs_`x'_st) // note gen, not egen!
		qui gen log_running_`x'_st = log(1+running_cnt_`x'_st)
		qui gen log_cnt_`x'_st = log(1+count_subs_`x'_st)
		qui gen cnt_subseq_`x'_st = running_cnt_`x'_st - cnt_firstyr_`x'_st *(year >= first_sub_`x'_yr_st)
		qui gen log_subseq_`x'_st = log(1 + cnt_subseq_`x'_st)

		
	*********** running DOLLARS *************
	qui gen temp_USD_1_`x'_st = subs_`x'_st * is_1st_type_`x'_yr_st
		by area_fips: egen USD_firstyr_`x'_st = sum(temp_USD_1_`x'_st )
			qui replace USD_firstyr_`x'_st = 0 if (year < first_sub_`x'_yr_st)
		qui gen log_USD_firstyr_`x'_st = log(1+USD_firstyr_`x'_st)
		drop temp_USD_1_`x'_st

	by area_fips: gen running_USD_`x'_st = sum(subs_`x'_st) // note gen, not egen!
		qui gen log_running_USD_`x'_st = log(1+running_USD_`x'_st)
		qui gen log_USD_`x'_st = log(1+subs_`x'_st)
		qui gen USD_subseq_`x'_st = running_USD_`x'_st - USD_firstyr_`x'_st *(year >= first_sub_`x'_yr_st)
		qui gen log_USD_subseq_`x'_st = log(1 + USD_subseq_`x'_st)
		

}

egen first_sub_megadeal_yr_st = min(year / (count_st_subs_megadeal > 0 & count_st_subs_megadeal < .)), by(area_fips)
	qui gen post_sub_mega = (year >= first_sub_megadeal_yr_st) if first_sub_megadeal_yr_st != .
	by area_fips: egen ever_had_state_megadeal = sum(post_sub_mega)
		qui replace ever_had_state_megadeal = 1 if ever_had_state_megadeal > 0 & ever_had_state_megadeal  != .

*********** running COUNTS *************
qui gen temp_cnt_1_state = count_state_subsidies * is_first_sub_state_year
	by area_fips: egen cnt_firstyr_state_subs = sum(temp_cnt_1_state)
		qui replace cnt_firstyr_state_subs = 0 if year < first_sub_state
	drop temp_cnt_1_state
	qui gen log_firstyr_state_subs = log(1+cnt_firstyr_state_subs)


	
so area_fips year
by area_fips: gen running_count_state_subs = sum(count_state_subsidies)
	qui gen log_running_state_subs = log(1+running_count_state_subs)
	by area_fips: egen total_state_subs = sum(count_state_subsidies)  // note the use of egen here vs gen in the prior line
	qui gen cnt_subseq_state_subs = running_count_state_subs - cnt_firstyr_state_subs
	qui gen log_subseq_state_subs = log(1+cnt_subseq_state_subs)
*********** running DOLLARS *************
qui gen temp_USD_1_state = sum_state_subsidies * is_first_sub_state_year
	by area_fips: egen USD_firstyr_state_subs = sum(temp_USD_1_state)
		qui replace USD_firstyr_state_subs = 0 if year < first_sub_state
	drop temp_USD_1_state
	qui gen log_USD_firstyr_state_subs = log(1+USD_firstyr_state_subs)

sort area_fips year
by area_fips: gen running_USD_state_subs = sum(sum_state_subsidies)
	qui gen log_running_USD_state_subs = log(1+running_USD_state_subs )
	by area_fips: egen total_USD_state_subs = sum(sum_state_subsidies)  // note the use of egen here vs gen in the prior line
	qui gen USD_subseq_state_subs = running_USD_state_subs - USD_firstyr_state_subs
	qui gen log_USD_subseq_state_subs = log(1+USD_subseq_state_subs)


qui gen st_sub_no_dollar_inner = (sum_state_subsidies == 0) & (count_state_subsidies > 0) if (count_state_subsidies != .) 	
so area_fips year
by area_fips: egen state_subs_no_dollar_county = sum(st_sub_no_dollar_inner)
	qui replace state_subs_no_dollar_county = 1 if state_subs_no_dollar_county > 1

	
*********** indicators *************
qui gen years_after_1st_sub_state = year - first_sub_state
	qui gen years_before_first_sub_state1 = (years_after_1st_sub_state == -1)
	qui gen years_before_first_sub_state2 = (years_after_1st_sub_state == -2)
	qui gen years_before_first_sub_state3 = (years_after_1st_sub_state == -3)

foreach i of num 0/7 { 
	qui gen post_state_sub`i' = (years_after_1st_sub_state == `i')
	qui gen pre_state_sub`i' = (years_after_1st_sub_state == -`i')
	
foreach x in "Employment" "NoEmploy" "NoEmployNoGR" "NoEmployGR" "Emp_GrantR" "Emp_NoGrantR"  {
		qui gen post_first_`x'_`i'_st = ((year - first_sub_`x'_yr_st) == `i')
		qui gen pre_first_`x'_`i'_st = ((year - first_sub_`x'_yr_st) == -`i')
	}
}



	qui gen post_any_state_sub = post_state_sub0 + post_state_sub1 + post_state_sub2 + post_state_sub3 + post_state_sub4 + post_state_sub5 + post_state_sub6 + post_state_sub7 
	qui gen pre_any_state_sub = pre_state_sub1 + pre_state_sub2 + pre_state_sub3 + pre_state_sub4 + pre_state_sub5 + pre_state_sub6 + pre_state_sub7



************ NOW POST VARIABLES *****************
foreach x in "Employment" "NoEmploy" "NoEmployNoGR" "NoEmployGR" "Emp_GrantR" "Emp_NoGrantR"  {
	qui gen post_first_`x'_st = (log_running_`x'_st > 0) if log_running_`x'_st != . // define post variable by type based on FIRST YEAR THAT TYPE OF SUBSIDY WAS AWARDED
	qui gen has_`x'_st = count_subs_`x'_st > 0 if count_subs_`x'_st != .
}	


foreach i of num 1/7{
	qui gen follow_state_sub`i' = post_state_sub`i' * has_state_subsidy
	by area_fips: egen follow_state_subs_`i'_after = sum(follow_state_sub`i')
	qui gen post_follow_state`i' = follow_state_subs_`i'_after * (years_after_1st_sub_state >= `i') // this is a POST (diff in diff style) variable for each followup subsidy
}



by area_fips: egen total_county_megadeals = sum(count_subs_mega)
	qui gen megadeal_county = total_county_megadeals > 0 if total_county_megadeals != .






*********************** DISCLOSURE LAW **************************
	************* PROGRAM LEVEL DISCLOSURE LAWS *********

so area_fips year
qui gen num_st_subs_intDisc = intDisc_st_subs_TIF + intDisc_st_subs_taxcredit + intDisc_st_subs_taxabatement + intDisc_st_subs_reimbursement + intDisc_st_subs_grant + intDisc_st_subs_financing + intDisc_st_subs_megadeal + intDisc_st_subs_EZone
	qui gen pct_st_subs_intDisc = num_st_subs_intDisc/count_state_subsidies
	qui gen temp_intDisc_st = pct_st_subs_intDisc * (year == first_sub_state)
	by area_fips: egen first_intDisc_st = sum(temp_intDisc_st)
	qui gen first_st_intDisc_nodiscl = pct_st_subs_intDisc < 1 if pct_st_subs_intDisc != . & year == first_sub_state
	drop temp_intDisc_st
	by area_fips: egen first_intDisc_nodiscl = sum(first_st_intDisc_nodiscl )
		drop first_st_intDisc_nodiscl // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_intDisc_st = 1 - first_intDisc_nodiscl 

qui gen num_st_subs_extDisc = extDisc_st_subs_TIF + extDisc_st_subs_taxcredit + extDisc_st_subs_taxabatement + extDisc_st_subs_reimbursement + extDisc_st_subs_grant + extDisc_st_subs_financing + extDisc_st_subs_megadeal + extDisc_st_subs_EZone
	qui gen pct_st_subs_extDisc = num_st_subs_extDisc/count_state_subsidies
	qui gen temp_extDisc_st = pct_st_subs_extDisc * (year == first_sub_state)
	by area_fips: egen first_extDisc_st = sum(temp_extDisc_st)
	qui gen first_st_extDisc_nodiscl = pct_st_subs_extDisc < 1 if pct_st_subs_extDisc != . & year == first_sub_state
	drop temp_extDisc_st
	by area_fips: egen first_extDisc_nodiscl = sum(first_st_extDisc_nodiscl )
		drop first_st_extDisc_nodiscl // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_extDisc_st = 1 - first_extDisc_nodiscl 

	
	
foreach x in "Employment" "NoEmploy" "NoEmployNoGR" "NoEmployGR" "Emp_GrantR" "Emp_NoGrantR"  {
	qui gen intDisc_pct_`x' = intDisc_`x'/count_subs_`x'_st
	qui gen temp_intDisc_`x' = intDisc_pct_`x' * (year == first_sub_`x'_yr_st)
	by area_fips: egen first_intDisc_`x' = sum(temp_intDisc_`x')
	qui gen first_`x'_noPre = intDisc_pct_`x' < 1 if intDisc_pct_`x' != . & year == first_sub_`x'_yr_st
	drop temp_intDisc_`x'
	by area_fips: egen first_intDisc_no_`x' = sum(first_`x'_noPre)
		drop first_`x'_noPre // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_intDisc_`x'_st = 1 - first_intDisc_no_`x'

	qui gen extDisc_pct_`x' = extDisc_`x'/count_subs_`x'_st
	qui gen temp_extDisc_`x' = extDisc_pct_`x' * (year == first_sub_`x'_yr_st)
	by area_fips: egen first_extDisc_`x' = sum(temp_extDisc_`x')
	qui gen first_`x'_noPre = extDisc_pct_`x' < 1 if extDisc_pct_`x' != . & year == first_sub_`x'_yr_st
	drop temp_extDisc_`x'
	by area_fips: egen first_extDisc_no_`x' = sum(first_`x'_noPre)
		drop first_`x'_noPre // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_extDisc_`x'_st = 1 - first_extDisc_no_`x'

}


********** Now exclude general laws
so area_fips year
qui gen num_st_subs_intDisc_NG = intDisc_NG_st_subs_TIF + intDisc_NG_st_subs_taxcredit + intDisc_NG_st_subs_taxabatement + intDisc_NG_st_subs_reimbursement + intDisc_NG_st_subs_grant + intDisc_NG_st_subs_financing + intDisc_NG_st_subs_megadeal + intDisc_NG_st_subs_EZone
	qui gen pct_st_subs_intDisc_NG = num_st_subs_intDisc_NG/count_state_subsidies
	qui gen temp_intDisc_NG_st = pct_st_subs_intDisc_NG * (year == first_sub_state)
	by area_fips: egen first_intDisc_NG_st = sum(temp_intDisc_NG_st)
	qui gen first_st_intDisc_NG_nodiscl = pct_st_subs_intDisc_NG < 1 if pct_st_subs_intDisc_NG != . & year == first_sub_state
	drop temp_intDisc_NG_st
	by area_fips: egen first_intDisc_NG_nodiscl = sum(first_st_intDisc_NG_nodiscl )
		drop first_st_intDisc_NG_nodiscl // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_intDisc_NG_st = 1 - first_intDisc_NG_nodiscl 

qui gen num_st_subs_extDisc_NG = extDisc_NG_st_subs_TIF + extDisc_NG_st_subs_taxcredit + extDisc_NG_st_subs_taxabatement + extDisc_NG_st_subs_reimbursement + extDisc_NG_st_subs_grant + extDisc_NG_st_subs_financing + extDisc_NG_st_subs_megadeal + extDisc_NG_st_subs_EZone
	qui gen pct_st_subs_extDisc_NG = num_st_subs_extDisc_NG/count_state_subsidies
	qui gen temp_extDisc_NG_st = pct_st_subs_extDisc_NG * (year == first_sub_state)
	by area_fips: egen first_extDisc_NG_st = sum(temp_extDisc_NG_st)
	qui gen first_st_extDisc_NG_nodiscl = pct_st_subs_extDisc_NG < 1 if pct_st_subs_extDisc_NG != . & year == first_sub_state
	drop temp_extDisc_NG_st
	by area_fips: egen first_extDisc_NG_nodiscl = sum(first_st_extDisc_NG_nodiscl )
		drop first_st_extDisc_NG_nodiscl // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_extDisc_NG_st = 1 - first_extDisc_NG_nodiscl 

	
	
	
foreach x in "Employment" "NoEmploy" "NoEmployNoGR" "NoEmployGR" "Emp_GrantR" "Emp_NoGrantR"  {
	qui gen intDisc_NG_pct_`x' = intDisc_NG_`x'/count_subs_`x'_st
	qui gen temp_intDisc_NG_`x' = intDisc_NG_pct_`x' * (year == first_sub_`x'_yr_st)
	by area_fips: egen first_intDisc_NG_`x' = sum(temp_intDisc_NG_`x')
	qui gen first_`x'_noPre = intDisc_NG_pct_`x' < 1 if intDisc_NG_pct_`x' != . & year == first_sub_`x'_yr_st
	drop temp_intDisc_NG_`x'
	by area_fips: egen first_intDisc_NG_no_`x' = sum(first_`x'_noPre)
		drop first_`x'_noPre // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_intDisc_NG_`x'_st = 1 - first_intDisc_NG_no_`x'


	qui gen extDisc_NG_pct_`x' = extDisc_NG_`x'/count_subs_`x'_st
	qui gen temp_extDisc_NG_`x' = extDisc_NG_pct_`x' * (year == first_sub_`x'_yr_st)
	by area_fips: egen first_extDisc_NG_`x' = sum(temp_extDisc_NG_`x')
	qui gen first_`x'_noPre = extDisc_NG_pct_`x' < 1 if extDisc_NG_pct_`x' != . & year == first_sub_`x'_yr_st
	drop temp_extDisc_NG_`x'
	by area_fips: egen first_extDisc_NG_no_`x' = sum(first_`x'_noPre)
		drop first_`x'_noPre // drop this to prevent confusion down the line between two otherwise similarly-named vars
	qui gen fully_extDisc_NG_`x'_st = 1 - first_extDisc_NG_no_`x'
		
}

** ROBUSTNESS: FMP STATES **
** FMP STATES: CT, FL, IA, KY, MD, MI, MN, NH, NJ, NC, SD, WA; CO (2013+), LA (2014+), NV (2015+), NM (2012+), NY (2013+), OR (2015+), PA (2014+), TN (2014+)
decode state, gen(state_str)
	rename state state_copy
	rename state_str state
	sort state
	
gen fmp_ineffect = (state == "CT" | state == "FL" | state == "IA" | state == "KY" | state == "MD" | state == "MI" | state == "MN" | state == "NH" | state == "NJ" | state == "NC" | state == "SD" | state == "WA" | ///
	((state == "CO") & (year >= 2013)) | ((state == "LA") & (year >= 2014)) | ((state == "NV") & (year >= 2015))  | ((state == "NM") & (year >= 2012))  | ((state == "NY") & (year >= 2013))  | ((state == "OR") & (year >= 2015))  | ((state == "PA") & (year >= 2014))  | ((state == "TN") & (year >= 2014)) )
	


save full_dataset_for_regression, replace*STATE SAMPLE, BY TYPE, WITH STATE-YEAR FE **********	
local outFile = "../Results/all_regs_stateyear_FE_JAR_final.xls" 

preserve

** Uncomment for robustness as needed **
*drop if state == "KY" 
*local outFile = "../Results/all_regs_stateyear_FE_no_KY.xls" 


*********** TABLE 4 PANEL A **************
reghdfe l_emps post_any_state_sub logpop county_educ_college_pct  if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
	outreg2 using `outFile', ctitle("Employees, Base") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_emps c.log_firstyr_state_subs logpop county_educ_college_pct  if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
	outreg2 using `outFile', ctitle("Employees, Base") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_emps c.log_firstyr_state_subs c.log_subseq_state_subs logpop county_educ_college_pct  if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
	outreg2 using `outFile', ctitle("Employees, Base") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

	
reghdfe l_emps 1.post_first_Employment_st 1.post_first_NoEmploy_st ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_emps c.log_firstyr_Employment_st 1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_emps c.log_firstyr_Employment_st c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

		
reghdfe l_emps c.log_firstyr_Employment_st##1.fully_intDisc_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, Internal Disclosure Law") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_intDisc_Employment_st = 0
	
reghdfe l_emps c.log_firstyr_Employment_st##1.fully_intDisc_NG_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, Internal Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_intDisc_NG_Employment_st = 0

			
			
			
*********** TABLE 4 PANEL B **************
reghdfe l_wage post_any_state_sub logpop county_educ_college_pct  if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
	outreg2 using `outFile', ctitle("Wages, Base") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_wage c.log_firstyr_state_subs logpop county_educ_college_pct  if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
	outreg2 using `outFile', ctitle("Wages, Base") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_wage c.log_firstyr_state_subs c.log_subseq_state_subs logpop county_educ_college_pct  if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
	outreg2 using `outFile', ctitle("Wages, Base") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append


reghdfe l_wage   1.post_first_Employment_st 1.post_first_NoEmploy_st ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_wage c.log_firstyr_Employment_st 1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_wage c.log_firstyr_Employment_st c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append


reghdfe l_wage c.log_firstyr_Employment_st##1.fully_intDisc_Employment_st  c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages, Internal Disclosure Law") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_intDisc_Employment_st = 0
reghdfe l_wage c.log_firstyr_Employment_st##1.fully_intDisc_NG_Employment_st  c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages, Internal Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_intDisc_NG_Employment_st = 0



********** TABLE 5 *******************
reghdfe l_emps c.log_firstyr_Employment_st c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_emps c.log_firstyr_Employment_st##1.fully_extDisc_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, External Disclosure Law") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_extDisc_Employment_st = 0
reghdfe l_emps c.log_firstyr_Employment_st##1.fully_extDisc_NG_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, External Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_extDisc_NG_Employment_st = 0

		
reghdfe l_wage c.log_firstyr_Employment_st c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe l_wage c.log_firstyr_Employment_st##1.fully_extDisc_Employment_st  c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages, External Disclosure Law") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_extDisc_Employment_st = 0
reghdfe l_wage c.log_firstyr_Employment_st##1.fully_extDisc_NG_Employment_st  c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Wages, External Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
		*** F-test:
			test c.log_firstyr_Employment_st + c.log_firstyr_Employment_st#1.fully_extDisc_NG_Employment_st = 0
			
		
		
		
			
		
**** ROBUSTNESS TESTS **************

**** ONLY GRANTS AND REIMBURSEMENTS// EXCLUDING GRANTS AND REIMBURSEMENTS
* Internal disclosure, only grants/reimb
reghdfe l_emps c.log_firstyr_Emp_GrantR_st##1.fully_intDisc_NG_Emp_GrantR_st c.log_subseq_Emp_GrantR_st  1.post_first_NoEmployGR_st    ///
	logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
	eststo internal_onlygrant

* External disclosure, only grants/reimb
reghdfe l_emps c.log_firstyr_Emp_GrantR_st##1.fully_extDisc_NG_Emp_GrantR_st c.log_subseq_Emp_GrantR_st  1.post_first_NoEmployGR_st    ///
	logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
	eststo external_onlygrant 

* Internal disclosure, excluding grants/reimb
reghdfe l_emps c.log_firstyr_Emp_NoGrantR_st##1.fully_intDisc_NG_Emp_NoGrantR_st c.log_subseq_Emp_NoGrantR_st  1.post_first_NoEmployNoGR_st    ///
	logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
	eststo internal_nogrant
	
* External disclosure, excluding grants/reimb
reghdfe l_emps c.log_firstyr_Emp_NoGrantR_st##1.fully_extDisc_NG_Emp_NoGrantR_st c.log_subseq_Emp_NoGrantR_st  1.post_first_NoEmployNoGR_st    ///
	logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips state_fips##year) cluster(area_fips)
	eststo external_nogrant 


	
*** Differences in coefficients - need to use reg rather than reghdfe here for compatibility with suest.	
qui reg l_emps c.log_firstyr_Emp_GrantR_st##1.fully_intDisc_NG_Emp_GrantR_st c.log_subseq_Emp_GrantR_st  1.post_first_NoEmployGR_st    ///
	logpop county_educ_college_pct i.area_fips i.state_fips##i.year if ever_had_state_subsidy == 1  & state_subs_keep == 1 
	eststo internal_onlygrant
qui reg l_emps c.log_firstyr_Emp_NoGrantR_st##1.fully_intDisc_NG_Emp_NoGrantR_st c.log_subseq_Emp_NoGrantR_st  1.post_first_NoEmployNoGR_st    ///
	logpop county_educ_college_pct i.area_fips i.state_fips##i.year if ever_had_state_subsidy == 1  & state_subs_keep == 1 
	eststo internal_nogrant
qui suest internal_nogrant internal_onlygrant, cluster(area_fips)

test [internal_onlygrant_mean]c.log_firstyr_Emp_GrantR_st#1.fully_intDisc_NG_Emp_GrantR_st = [internal_nogrant_mean]c.log_firstyr_Emp_NoGrantR_st#1.fully_intDisc_NG_Emp_NoGrantR_st

qui reg l_emps c.log_firstyr_Emp_GrantR_st##1.fully_extDisc_NG_Emp_GrantR_st c.log_subseq_Emp_GrantR_st  1.post_first_NoEmployGR_st    ///
	logpop county_educ_college_pct i.area_fips i.state_fips##i.year if ever_had_state_subsidy == 1  & state_subs_keep == 1 
	eststo external_onlygrant
qui reg l_emps c.log_firstyr_Emp_NoGrantR_st##1.fully_extDisc_NG_Emp_NoGrantR_st c.log_subseq_Emp_NoGrantR_st  1.post_first_NoEmployNoGR_st    ///
	logpop county_educ_college_pct i.area_fips i.state_fips##i.year if ever_had_state_subsidy == 1  & state_subs_keep == 1 
	eststo external_nogrant
qui suest external_nogrant external_onlygrant, cluster(area_fips)

test [external_onlygrant_mean]c.log_firstyr_Emp_GrantR_st#1.fully_extDisc_NG_Emp_GrantR_st = [external_nogrant_mean]c.log_firstyr_Emp_NoGrantR_st#1.fully_extDisc_NG_Emp_NoGrantR_st
	



************* DOLLAR VALUES ***************
reghdfe l_emps c.log_USD_firstyr_Employment_st##1.fully_intDisc_NG_Employment_st   c.log_USD_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 & state_subs_no_dollar_county == 0 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, Internal Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

reghdfe l_emps c.log_USD_firstyr_Employment_st##1.fully_extDisc_NG_Employment_st   c.log_USD_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 & state_subs_no_dollar_county == 0 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, External Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append


********** RELAXED FE STRUCTURE PLUS ADDITIONAL CONTROLS ******************
reghdfe l_emps c.log_firstyr_Employment_st##1.fully_intDisc_NG_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct minwage_effective l_GDP  union_pct corp_tax_rate l_ui pr pinc sal drecord_n reports_n same_party_var wallstreet_top_quartile electionyear if ever_had_state_subsidy == 1  & state_subs_keep == 1 ,  absorb(area_fips year) cluster(area_fips)
		outreg2 using `outFile', ctitle("Employees, Internal Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

		
		
*** FMP ***
reghdfe l_emps c.log_firstyr_Employment_st##1.fully_intDisc_NG_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st  ///
	logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 & fmp_ineffect == 0 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("No FMP, Employees, Internal Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

reghdfe l_emps c.log_firstyr_Employment_st##1.fully_extDisc_NG_Employment_st   c.log_subseq_Employment_st  1.post_first_NoEmploy_st   ///
	 logpop county_educ_college_pct if ever_had_state_subsidy == 1  & state_subs_keep == 1 & fmp_ineffect == 0 ,  absorb(area_fips state_fips##year) cluster(area_fips)
		outreg2 using `outFile', ctitle("No FMP, Employees, External Disclosure Law (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append



restore
*** THIS IS THE MAIN FILE FOR NEW REGRESSIONS ******
cd ~ // replace with project dir

log using "DLR_full_log.log", replace

* First, generate main regression dataset
do ../Code/Estimations/create_subsidy_data_final.do
do ../Code/Estimations/data_preprocessing_final.do
use full_dataset_for_regression, clear // dataset generated by do-file above

sort area_fips year

gen state_megadeal_sample = (ever_had_state_subs == 1) & (megadeal_county == 1) & (state_subs_keep == 1)



********** COMMENT OUT THE BELOW LINE (AND RERUN FROM HERE) IF WANT MEGADEALS IN THE ANALYSES  ***************
replace ever_had_state_subs = 0 if megadeal_county == 1

** GENERATE TABLEAU OUTPUT *****
/*
preserve

	keep if (ever_had_state_subs == 1 & state_subs_keep == 1) 
	gen count_state_sub_relevant = count_state_subsidies if (ever_had_state_subs == 1 & state_subs_keep == 1)
	gen first_year_state_subsidies = count_state_sub_relevant * (year == first_sub_state)  
	gen first_year_emp_subsidies = count_subs_Employment_st * (year == first_sub_Employment_yr_st)
	
	
	
	collapse (mean) population_25_64 (sum) extDisc_Employment extDisc_NG_Employment intDisc_Employment intDisc_NG_Employment num_st_subs_extDisc num_st_subs_extDisc_NG num_st_subs_intDisc num_st_subs_intDisc_NG count_state_sub_relevant first_year_state_subsidies count_subs_Employment_st first_year_emp_subsidies, by(area_fips)
	rename population_25_64 avg_adult_population_0815
	export delim "../Tableau/county_subsidies_for_tableau_v4.csv", replace
	keep area_fips 
	duplicates drop 
	*save unique_counties_in_final_sample, replace
restore
*/

/*
preserve
	keep if ( (ever_had_state_subs == 1) & (state_subs_keep == 1) ) 
	keep area_fips
	duplicates drop
	save unique_counties_in_final_sample, replace
restore
*/



	
	
**** Descriptives ****

gen total_annual_wages_mlns = total_annual_wages_lead/1000000

qui estpost tabstat annual_avg_emplvl_lead l_emps total_annual_wages_mlns l_wage ///
	post_any_state_sub log_firstyr_state_subs log_subseq_state_subs ///
	post_first_Employment_st log_firstyr_Employment_st log_subseq_Employment_st ///
	post_first_NoEmploy_st ///
	fully_intDisc_Employment_st fully_intDisc_NG_Employment_st fully_extDisc_Employment_st fully_extDisc_NG_Employment_st ///
	logpop county_educ_college_pct  ///
	if ever_had_state_subsidy == 1  & state_subs_keep == 1, statistics(N mean p50 sd p25 p75 ) columns (statistics) 

esttab . using ../Results/sumstats_controls.csv, cells("mean sd p25 p50 p75") not nostar unstack title("Summary Statistics") nonumber nonote noobs label replace


est clear




foreach v of varlist subsidy_dollar_sum subs_Employment*  st_subs* {
	gen `v'_mln = `v'/1000000
}
* ALL SUBSIDY-YEAR DESCRIPTIVES BY TYPE
estpost tabstat subs_Employment_st_mln count_subs_Employment_st  count_subs_NoEmploy_st	nonzero_subs_Employment_st nonzero_subs_NoEmploy_st if ever_had_state_subsidy == 1  & state_subs_keep == 1, statistics(sum) columns (statistics) 
esttab . using ../Results/subsidy_dollar_values_bytype.csv, cells("sum") not nostar unstack nonumber nonote noobs label replace

tab has_Employment_st year if ever_had_state_subsidy == 1  & state_subs_keep == 1 


* FIRST SUBSIDY-YEAR DESCRIPTIVES BY TYPE

est clear

qui estpost tabstat subs_Employment_st_mln count_subs_Employment_st nonzero_subs_Employment_st if ever_had_state_subsidy == 1  & state_subs_keep == 1 & year == first_sub_Employment_yr_st, statistics(sum) columns (statistics) 
esttab . using ../Results/sumstats_employment_firstyr.csv, cells("sum") not nostar unstack nonumber nonote noobs label replace

tab has_Employment_st year if ever_had_state_subsidy == 1  & state_subs_keep == 1 & year == first_sub_Employment_yr_st
tab has_NoEmploy_st year if ever_had_state_subsidy == 1  & state_subs_keep == 1 & year == first_sub_NoEmploy_yr_st

*** SUBSIDIES BY YEAR AND STATE
*By Year
estpost tabstat count_state_subsidies count_subs_Employment_st  count_subs_NoEmploy_st if state_subs_keep == 1 & ever_had_state_subsidy == 1 , by(year) statistics(sum) columns(statistics)
esttab . using ../Results/subsidy_counts_yearly.rtf, main(sum) not nostar unstack nomtitle nonumber nonote noobs label replace

qui estpost tabstat count_state_subsidies if state_subs_keep == 1 & ever_had_state_subsidy == 1 & year == first_sub_state , by(year) statistics(sum) columns(statistics)
esttab . using ../Results/subsidy_counts_yearly.rtf, main(sum) not nostar unstack nomtitle nonumber nonote noobs label append

qui estpost tabstat count_subs_Employment_st  if state_subs_keep == 1 & ever_had_state_subsidy == 1 & year == first_sub_Employment_yr_st , by(year) statistics(sum) columns(statistics)
esttab . using ../Results/subsidy_counts_yearly.rtf, main(sum) not nostar unstack nomtitle nonumber nonote noobs label append

qui estpost tabstat count_subs_NoEmploy_st if state_subs_keep == 1 & ever_had_state_subsidy == 1 & year == first_sub_NoEmploy_yr_st , by(year) statistics(sum) columns(statistics)
esttab . using ../Results/subsidy_counts_yearly.rtf, main(sum) not nostar unstack nomtitle nonumber nonote noobs label append


tab state if ever_had_state_sub == 1

***** SUBSIDIES BY GJF CLASSIFICATION, STATE ONLY
qui estpost tabstat st_subs*mln count_st_subs* nonzero_st_subs* if ever_had_state_subsidy == 1 & state_subs_keep == 1, statistics(sum) columns(statistics)  
esttab . using ../Results/subs_by_GJF_type_fullsample.csv, cells("sum") not nostar unstack nonumber nonote noobs label replace

	* Now first subsidy year only
qui estpost tabstat st_subs*mln count_st_subs* nonzero_st_subs* if ever_had_state_subsidy == 1 & state_subs_keep == 1 & year == first_sub_state, statistics(sum) columns(statistics) 
esttab . using ../Results/subs_by_GJF_type_firstyr.csv, cells("sum") not nostar unstack nonumber nonote noobs label replace
*/



preserve
	qui keep if ever_had_state_sub == 1 & state_subs_keep == 1
	keep area_fips year
	duplicates drop
	gen insample = 1
	save county_years_in_sample_final, replace
restore

do ../Code/Estimations/subseq_sub_descriptives


do ../Code/Estimations/full_set_regs_stateyear_FE_final



*** SUBSIDY COUNTIES IN SAMPLE -- note, after running this run create_subsidy_data.do again ***
/*
preserve
	use Subsidies/subs_data_trimmed, clear
	merge m:1 area_fips using unique_counties_in_final_sample
	keep if _merge == 3
	drop _merge
	keep if (subsidy_level == "multiple" | subsidy_level == "state")
	keep state program
	duplicates drop
	export delim "../JAR/programs_in_final_sample.csv", replace
restore

*/


*** COMPARE TO SLATTERY TOTAL INCENTIVE FIGURES ***
preserve
keep if ever_had_state_subs==1
collapse (sum) subsidy_dollar_sum subs_Employment_st (mean) total_credits total_budget total_incentives, by(state year)

*All subsidies
qui gen sample_to_total_credits = subsidy_dollar_sum/total_credits
qui gen sample_to_total_budget = subsidy_dollar_sum/total_budget
qui gen sample_to_total_incentives = subsidy_dollar_sum/total_incentives


* Employment subsidies
qui gen empsample_to_total_credits = subs_Employment_st/total_credits
qui gen empsample_to_total_budget = subs_Employment_st/total_budget
qui gen empsample_to_total_incentives = subs_Employment_st/total_incentives

estpost tabstat sample_to_total* empsample_to_total* , statistics(N mean sd p10 p25 p50 p75 p90 p95 max) columns(statistics)
esttab . using ../Results/slattery_comparison.xls, cells("N mean sd p10 p25 p50 p75 p90 p95 max") not nostar unstack title("Comparison") nonumber nonote 

restore 

clear 

log closecd ~ 

log using "state_program_analyses.log", replace
**** Rename some MSU variables to match master data
import delim "StateGovt/WallStreet Best Run/wallstreet_best_run_for_merging.csv", clear

merge 1:1 state year using "StateGovt/cleaned_msu_data_final"
	drop _merge
	rename state statename
	rename st state
	drop stateno state_icpsr gub_election govparty_a wallstreet_best_run 
	qui gen wallstreet_top_quartile = (wallstreet_bestrun_rank < 13)
	
	xtset state_fips year
	qui replace drecord_n = l1.drecord_n if drecord_n == .
	qui replace reports_n = l1.reports_n if reports_n == .
	qui replace same_party_var = 1 if same_party_var == . // Nebraska's unicameral system -- 1 by default
	
	save "StateGovt/cleaned_msu_data_final_for_merging", replace

	
* Reshape disclosure dataset to get unique state-years when a new law was passed for at least one program
use "program_level_disclosure_years", clear 
merge m:1 state program using "Subsidies/clean_program_names"
	drop if _merge == 1 
	drop _merge
	rename program program_raw_GJF
	rename program_clean program


	drop if year_internal == . & year_external == .
	qui gen tobs = 1 // total obs per program -- 1 if only one type of law, 2 if hit by both int. & ext. in different years
	qui replace tobs = 2 if (year_internal != year_external) & (year_internal != .) & (year_external != .)

expand tobs // create duplicate obs for programs with separate int. and ext. years
	bys state program: gen nobs = _n

qui gen year = year_internal if nobs == 1
	qui replace year = year_external if year == . & tobs == 1
	qui replace year = year_internal if tobs == 2 & nobs == 1
	qui replace year = year_external if tobs == 2 & nobs == 2

qui gen internal_flag = 1
qui gen external_flag = (year_external == year) & (year_external != .)

drop tobs nobs

qui gen internal_NG_flag = internal_flag * (general_law == .)
qui gen external_NG_flag = external_flag * (general_law == .)


preserve
* Program-year level
	qui gen stateprogram = state + program
	collapse (max) internal_flag external_flag internal_NG_flag external_NG_flag , by(stateprogram year)
	fillin stateprogram year // have to do it this way to avoid 
		qui gen state = substr(stateprogram,1,2) 

    sort stateprogram year
	foreach v of varlist internal_flag external_flag internal_NG_flag external_NG_flag {
		by stateprogram: gen total_`v' = sum(`v') // note gen, NOT egen!
		qui gen had_`v' = (total_`v' > 0) if total_`v' != .
	}

	save years_with_new_program_laws, replace
restore 

collapse (max) internal_flag external_flag internal_NG_flag external_NG_flag , by(state year)

fillin state year

sort state year
foreach v of varlist internal_flag external_flag internal_NG_flag external_NG_flag {
	by state : gen total_`v' = sum(`v') // note gen, NOT egen!
	qui gen had_`v' = (total_`v' > 0) if total_`v' != .
}

save years_with_new_state_laws, replace



** Descriptives -- how many programs with laws in each state/county in any given year?
  
* Now, analyses
use years_with_new_program_laws, clear

preserve
keep if ((year == 2008) | (year == 2015))
collapse (sum) had*flag , by(state year)
	export delim "../Tableau/state_year_programs_with_laws_for_tableau.csv", replace

restore

keep if year == 2015 // last year of sample

collapse (sum) had*flag , by(state)
	export delim "../Tableau/state_programs_with_laws_for_tableau.csv", replace


use "subsidies_in_final_sample", clear 
	drop _merge
qui gen nsubs = 1
qui gen stateprogram = state + program
rename internal_disclosure_NOGENLAW internal_disclosure_NG 
rename external_disclosure_NOGENLAW external_disclosure_NG

merge m:1 stateprogram year using years_with_new_program_laws, keep(1 3)
		drop _merge

keep if year == 2015 // last year, where all disclosure should have eventually turned on
duplicates drop stateprogram area_fips, force

******* PROGRAM-YEAR FIRST ******************
use "subsidies_in_final_sample", clear 
qui gen nsubs = 1
qui gen stateprogram = state + program
rename internal_disclosure_NOGENLAW internal_disclosure_NG 
rename external_disclosure_NOGENLAW external_disclosure_NG

foreach v of varlist internal_disclosure* external_disclosure* {
    qui gen `v'_E = `v' * Employment
}

qui gen nsubs_Employment = Employment 

collapse (sum) nsubs nsubs_Employment internal_disclosure* external_disclosure* (mean) Employment Investment, by(stateprogram year)
	fillin stateprogram year
		qui gen state = substr(stateprogram,1,2) 

bys stateprogram: egen empsum = sum(Employment)
	qui replace Employment = 1 if Employment == . & empsum > 0 & empsum != .
		
qui replace nsubs = 0 if nsubs == .
qui gen log_program_year_subs = log(nsubs + 1)
	qui gen program_had_subs = (log_program_year_subs > 0) if log_program_year_subs != .
qui gen log_program_year_subs_E = log(nsubs_Employment + 1)
	qui gen program_had_subs_E = (log_program_year_subs_E > 0) if log_program_year_subs_E != .

bys state year: egen state_total_subs = sum(nsubs)
	qui gen program_subsidy_share = nsubs/state_total_subs
bys state year: egen state_total_subs_Employment = sum(nsubs_Employment)
	qui gen program_subsidy_share_E = nsubs_Employment/state_total_subs_Employment
		qui replace program_subsidy_share_E = 0 if program_subsidy_share_E == .
	qui gen program_subsidy_share_E_all = nsubs_Employment/state_total_subs
		qui replace program_subsidy_share_E_all = 0 if program_subsidy_share_E_all == .

	merge 1:1 stateprogram year using years_with_new_program_laws, keep(1 3)
		drop _merge
		
merge m:1 state year using "StateGovt/governor_party_and_elections", keep(1 3)
	drop _merge
	qui gen republican_gov = (gov_party == "Republican")

merge m:1 state year using "StateGovt/cleaned_msu_data_final_for_merging", keep(1 3)
	drop _merge

foreach v of varlist nsubs internal_disclosure* external_disclosure* had*flag {
    qui replace `v' = 0 if `v' == .
}

foreach v of varlist internal_disclosure* external_disclosure* {
    qui gen pct_`v' = 0
	qui replace pct_`v' = `v'/nsubs if nsubs > 0
}	

	merge m:1 state year using control_variables_all, keep(1 3)
		drop _merge
	
* Some basic regressions to understand where there is disclosure
qui gen l_GDP = log(stateGDP)
qui gen l_ui = log(ui)




**** REGRESSIONS ******
* Determinants - program level (OA Table 5) 
local outFile = "../Results/program_level_disclosure_determinants.xls" 
reghdfe had_internal_NG_flag log_program_year_subs republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal, absorb(year) cluster(stateprogram)
	outreg2 using `outFile', ctitle("Internal, Strict, Year FE") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe had_external_NG_flag log_program_year_subs republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal, absorb(year) cluster(stateprogram)
	outreg2 using `outFile', ctitle("External, Strict, Year FE") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append


* Program responses to disclosure (Table 6)
local outFile = "../Results/program_disclosure_responses.xls" 

* Internal (Panel A)
reghdfe program_had_subs had_internal_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Pr(program subsidy), Year FE, Internal (Weak)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel replace
reghdfe program_had_subs had_internal_NG_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Pr(program subsidy), Year FE, Internal (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe log_program_year_subs had_internal_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Log Program-Year Subs, Year FE, Internal (Weak)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe log_program_year_subs had_internal_NG_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Log Program-Year Subs, Year FE, Internal (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe program_subsidy_share_E_all had_internal_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Program Subsidy Share, Year FE, Internal (Weak)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe program_subsidy_share_E_all had_internal_NG_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Program Subsidy Share, Year FE, Internal (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append


* External (Panel B)
reghdfe program_had_subs had_external_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Pr(program subsidy), Year FE, External (Weak)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe program_had_subs had_external_NG_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Pr(program subsidy), Year FE, External (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe log_program_year_subs had_external_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Log Program-Year Subs, Year FE, External (Weak)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe log_program_year_subs had_external_NG_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Log Program-Year Subs, Year FE, External (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe program_subsidy_share_E_all had_external_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Program Subsidy Share, Year FE, External (Weak)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe program_subsidy_share_E_all had_external_NG_flag republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear Employment educ_college l_GDP union_pct l_ui pr pinc sal if _fillin == 0 & Employment == 1, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Program Subsidy Share, Year FE, External (Strict)") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

	
	
	
	
	
	
*************************************************************	
************** NOW STATE-YEAR DETERMINANTS ******************
*************************************************************

use "subsidies_in_final_sample", clear 
	
rename internal_disclosure_NOGENLAW internal_disclosure_NG 
rename external_disclosure_NOGENLAW external_disclosure_NG

foreach v of varlist internal_disclosure* external_disclosure* {
    qui gen `v'_E = `v' * Employment
}

qui gen nsubs_Employment = Employment 
	
qui gen nsubs = 1
collapse (sum) nsubs* internal_disclosure* external_disclosure* , by(state year)
	fillin state year 

	
qui replace nsubs = 0 if nsubs == .
qui gen log_state_year_subs = log(nsubs + 1)
bys state year: egen state_total_subs = sum(nsubs)
	qui gen state_subsidy_share = nsubs/state_total_subs
	
	
merge 1:1 state year using years_with_new_state_laws, keep(1 3)
	drop _merge
	
merge 1:1 state year using "StateGovt/governor_party_and_elections", keep(1 3)
	drop _merge
	qui gen republican_gov = (gov_party == "Republican")

merge m:1 state year using "StateGovt/cleaned_msu_data_final_for_merging", keep(1 3)
	drop _merge
	
foreach v of varlist nsubs internal_disclosure* external_disclosure* had*flag internal*flag external*flag {
    qui replace `v' = 0 if `v' == .
}

foreach v of varlist internal_disclosure*E external_disclosure*E {
    qui gen pct_`v' = 0
	qui replace pct_`v' = `v'/nsubs_Employment if nsubs > 0
}


	merge m:1 state year using control_variables_all, keep(1 3)
		drop _merge
	
* Some basic regressions to understand where there is disclosure
qui gen l_GDP = log(stateGDP)
qui gen l_ui = log(ui)


local outFile = "../Results/state_level_disclosure_determinants.xls" 
reghdfe had_internal_flag log_state_year_subs republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear educ_college l_GDP union_pct l_ui pr pinc sal, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Internal, Weak, Year FE") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe had_internal_NG_flag log_state_year_subs republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear educ_college l_GDP union_pct l_ui pr pinc sal, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("Internal, Strict, Year FE") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append

reghdfe had_external_flag log_state_year_subs republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear educ_college l_GDP union_pct l_ui pr pinc sal, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("External, Weak, Year FE") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append
reghdfe had_external_NG_flag log_state_year_subs republican_gov wallstreet_top_quartile drecord_n reports_n same_party_var electionyear educ_college l_GDP union_pct l_ui pr pinc sal, absorb(year) cluster(state)
	outreg2 using `outFile', ctitle("External, Strict, Year FE") st(coef tstat)  br(tstat) bdec(4) tdec(2) rdec(4)  addnote("t-stats in brackets, p-values in parentheses") addstat(Within R-squared, e(r2_a_within), Adj. Overall R-squared, e(r2_a),MSE, e(rmse)) excel append


log close* How many subsidies go to repeat recipients within a county?
** CALL THIS FROM INSIDE OUR MAIN ANALYSIS FILE


* All subsidies
preserve
keep if ever_had_state_subs == 1 & state_subs_keep == 1

keep area_fips year
merge 1:m area_fips year using "Subsidies/subs_data_trimmed", keep(3)


gen nsub = 1
collapse (mean) nsub Employment NoEmploy , by(area_fips year company program subsidy_overall_type subsidy_level )
	replace Employment = 0 if Employment == .
drop if subsidy_level == "local"

*** COMMENT OUT THE NEXT LINE IF WANT ALL SUBSIDIES. LEAVE IT IF ONLY WANT EMPLOYMENT
drop if Employment == 0

sort area_fips company year
egen county_company_index = group (company area_fips)

bys county_company_index: egen first_year_of_firm_cty_sub = min(year)
	gen repeat_subsidy = (year > first_year_of_firm_cty_sub) if year != . & first_year_of_firm_cty_sub != .

qui estpost tabstat repeat_subsidy, statistics(mean)
 esttab . using ../Results/subseq_descriptives.csv, cells("mean") not nostar unstack nonumber nonote noobs label replace



************ Program  **************
egen county_program_index = group(area_fips program)
bys county_program_index: egen first_year_cty_prg_sub = min(year)
bys county_program_index: egen first_year_of_prg_cty_sub = min(year)
	gen repeat_subsidy_prg = (year > first_year_of_prg_cty_sub ) if year != . & first_year_of_prg_cty_sub != .

qui estpost tabstat repeat_subsidy_prg, statistics(mean) 

 esttab . using ../Results/subseq_descriptives.csv, cells("mean") not nostar unstack nonumber nonote noobs label append
restore







* Employment subsidies
preserve
keep if ever_had_state_subs == 1 & state_subs_keep == 1

keep area_fips year
merge 1:m area_fips year using "Subsidies/subs_data_trimmed", keep(3)


gen nsub = 1
collapse (mean) nsub Employment NoEmploy , by(area_fips year company program subsidy_overall_type subsidy_level )
	replace Employment = 0 if Employment == .
drop if subsidy_level == "local"

drop if Employment == 0

sort area_fips company year
egen county_company_index = group (company area_fips)

bys county_company_index: egen first_year_of_firm_cty_sub = min(year)
	gen repeat_subsidy = (year > first_year_of_firm_cty_sub) if year != . & first_year_of_firm_cty_sub != .

qui estpost tabstat repeat_subsidy, statistics(mean)
 esttab . using ../Results/subseq_descriptives.csv, cells("mean") not nostar unstack nonumber nonote noobs label append



************ Program  **************
egen county_program_index = group(area_fips program)
bys county_program_index: egen first_year_cty_prg_sub = min(year)
bys county_program_index: egen first_year_of_prg_cty_sub = min(year)
	gen repeat_subsidy_prg = (year > first_year_of_prg_cty_sub ) if year != . & first_year_of_prg_cty_sub != .

qui estpost tabstat repeat_subsidy_prg, statistics(mean) 

 esttab . using ../Results/subseq_descriptives.csv, cells("mean") not nostar unstack nonumber nonote noobs label append
restore