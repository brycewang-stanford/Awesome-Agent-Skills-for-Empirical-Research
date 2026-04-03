**# Standard initial code.
* Run the whole code instead of chunks, otherwise the output may be different because of locals.
* If the files are in OneDrive, pause syncing temporarily before running the code.
version 17
cls
capture quietly log close
clear all
macro drop _all
set more off, permanently
set varabbrev off, permanently
// set excelxlsxlargefile on // This is an undocumented setting that allows Excel files above 40 MB to be imported. The drawback is that one cannot break the code while importing an Excel file.
// set trace on // Traces the execution of loops for debugging.
timer on 1

* Your paths.
cd "YOUR_PATH" // Current PC folder.
global folder_original_databases "YOUR_PATH/data/raw" // Original databases folder.
global folder_save_databases "YOUR_PATH/data/interim" // Save databases folder.
global folder_output "YOUR_PATH/Outputs" // Output folder.
sysdir set PLUS "YOUR_PATH/Stata/Plus" // This is the PC plus folder.
sysdir set PERSONAL "YOUR_PATH/Stata/Personal" // This is the PC personal folder.
sysdir set OLDPLACE "YOUR_PATH/Stata/Old" // This is the PC old folder.

* Globals for quick update of ISSDD databases.
global iss_database_date 20211001
global last_year 2021

log using "Output", replace
* BOARD DIVERSITY
quietly log off

* Files to be added by running code is in Python or SAS.
/*
use "${folder_save_databases}/DB_Announcements_of_Directors_Joining_or_Leaving_Audit_Analytics_with_returns", clear
use "${folder_save_databases}/conference_calls/diversity_exposure_calculated_cc_level_after_GF.csv", clear
use "${folder_save_databases}/conference_calls/diversity_exposure_over_time_all_CCs.csv", clear
use "${folder_save_databases}/press_releases/all_press_releases_to_match_to_CCs", clear
use "${folder_save_databases}/press_releases/PRs_textual_attributes", clear
use "${folder_save_databases}/press releases event study CRSP data/es4 - Updated Sample - 2022-10-08", clear
*/

**# Import ISS Director Diversity - Symbology database (firm level data).
import_delimited using "${folder_original_databases}/ISS_director_diversity_data/current_datasets/full_history/symbology_${iss_database_date}.txt", delimiter("|", asstring) asdouble charset("utf8") clear

ds, has(type string) // Identifies all string variables in the database.
foreach variab in `r(varlist)' {
	quietly replace `variab' = strtrim(`variab') // Removes leading and trailing blanks in the string variables.
}

foreach variab in ipo_date delisted_date {
	rename `variab' `variab'_temp
	generate double `variab' = date(`variab'_temp,"YMD")
	format %td `variab'
	assert !missing(`variab')
	replace `variab' = . if `variab'==date("01Jan1900","DMY") // The date "01Jan1900" means, for "ipo_date", that the value was not collected. However, for "delisted_reason", it means "not collected, but the company does not have equity listed on a major listing exchange".
	replace `variab' = . if `variab'==date("01Jan2199","DMY") // The date "01Jan2199" means, for "delisted_reason", "'not applicable' because the company is still listed on a major exchange".
	drop `variab'_temp
}

ds, has(type numeric)
foreach variab in `r(varlist)' {
	assert `variab'!=-1 // Minus one is a missing value in the database. Verifies that there is no numerical variable with a missing value.
}

format %-45s company_name
format %-30s gics_sub_industry primary_exchange msa_name hq_address
format %12.0g iss_company_id
format %12.0f gics_8_code

assert !missing(iss_company_id)
duplicates report iss_company_id
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" is a unique identifier.
sort iss_company_id
order iss_company_id company_name iss_country entity_type_code entity_status_code cusip isin ticker sedol gvkey iid cik gics_8_code gics_sub_industry ipo_date delisted_reason delisted_date primary_exchange country_of_incorporation state_of_incorporation country_of_address state_of_address msa_name hq_address jpn_source_data_yn

quietly log on
	* Distribution of observations by country.
	tab iss_country, sort missing
	tab country_of_incorporation, sort missing
quietly log off

save "${folder_save_databases}/iss/DB ISSDD Origin Firm Level", replace
clear

**# Import ISS Director Diversity - Diversity Company database (firm-event level data).
import_delimited using "${folder_original_databases}/ISS_director_diversity_data/current_datasets/full_history/diversity_company_e1_${iss_database_date}.txt", delimiter("|", asstring) asdouble charset("utf8") clear

ds, has(type string) // Identifies all string variables in the database.
foreach variab in `r(varlist)' {
	quietly replace `variab' = strtrim(`variab') // Removes leading and trailing blanks in the string variables.
}

foreach variab in from_date to_date last_meeting_date most_recent_fy_end_date {
	rename `variab' `variab'_temp
	generate double `variab' = date(`variab'_temp,"YMD")
	format %td `variab'
	assert !missing(`variab')
	quietly replace `variab' = . if `variab'==date("01Jan1900","DMY") // The date "01Jan1900" means the value is missing.
	quietly replace `variab' = . if `variab'==date("01Jan2199","DMY") // The date "01Jan2199" means that the event is the most recent one, and the company is still actively collected by ISS.
	drop `variab'_temp
}

order company_event_id from_date to_date most_recent_event_yn company_event_order_rank iss_meeting_id last_meeting_date most_recent_fy_end_date

ds, has(type numeric)
foreach variab in `r(varlist)' {
	capture assert `variab'!=-1 // Minus one is a missing value in the database. The "capture" command stores any error code in "_rc".
	if _rc!=0 {
		display "The variable `variab' contained missing values reported as -1."
		replace `variab' = . if `variab'==-1
	}
	else {
	}
}

foreach variab in event_added_date event_modified_date event_correction_date event_completed_date {
	assert missing(`variab') // All values of the variable are missing.
	drop `variab'
}

format %-30s diversity_statement_source
format %-45s diversity_statement
format %12.0g iss_company_id

duplicates tag iss_meeting_id last_meeting_date most_recent_fy_end_date data_capture_type board_size gender_diversity_statement_detai board_gender_diversity_policy_yn board_gender_diversity_goal_num board_gender_diversity_goal_pct board_gender_diversity_statement exec_gender_diversity_policy_yn exec_gender_diversity_goal_num exec_gender_diversity_goal_pct exec_gender_diversity_statement_ mgmt_gender_diversity_statement_ emp_gender_diversity_statement_y diversity_statement diversity_statement_source number_women_directors pct_women_directors number_men_directors pct_men_directors num_women_neos num_men_neos num_directors_disclosed num_directors_survey num_directors_identified pct_board_identified num_directors_diverse pct_board_diverse num_neos_disclosed num_neos_survey num_neos_identified num_neos_diverse num_directors_leadership_exp num_directors_ceo_exp num_directors_cfo_exp num_directors_international_exp num_directors_industry_exp num_directors_financial_exp num_directors_technology_exp num_directors_risk_exp num_directors_government_exp num_directors_audit_exp num_directors_sales_exp num_directors_academic_exp num_directors_legal_exp num_directors_human_resources_ex num_directors_strategic_planning num_directors_operations_exp num_directors_mergers_acquisitio num_directors_csr_sri_exp median_director_age stdev_director_age median_director_tenure stdev_director_tenure pct_board_tenure_gt_9_yrs pct_board_tenure_lt_6_yrs, generate(dup) // Removed the following variables: "company_event_id" "from_date" "to_date" "most_recent_event_yn" "company_event_order_rank" "iss_company_id".

quietly log on
	* Distribution of duplicate observations. I checked the database for iss_company_id==549662 on SEC's EDGAR. Every observation is an event (e.g., shareholder meeting, 8-K filed for a new director of the board, 8-K filed for a resignation, etc.). However, I could not find the two most recent observations on EDGAR, which contain no difference in the total number of directors. I suspect these are due to, for example, a director acquiring a new skill from sitting on the board of a different company.
	tab dup, mis
quietly log off
drop dup

assert !missing(company_event_id)
duplicates report company_event_id
assert `r(unique_value)'==`r(N)' // Verifies that "company_event_id" is a unique identifier.

assert !missing(iss_company_id, company_event_order_rank)
duplicates report iss_company_id company_event_order_rank
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "company_event_order_rank" are a unique identifier pair. In the update of 2021-06-10, there were duplicates I had to deal with. Now, there are not.
sort iss_company_id company_event_order_rank
order company_event_id iss_company_id company_event_order_rank from_date to_date most_recent_event_yn iss_meeting_id last_meeting_date most_recent_fy_end_date data_capture_type board_size gender_diversity_statement_detai board_gender_diversity_policy_yn board_gender_diversity_goal_num board_gender_diversity_goal_pct board_gender_diversity_statement exec_gender_diversity_policy_yn exec_gender_diversity_goal_num exec_gender_diversity_goal_pct exec_gender_diversity_statement_ mgmt_gender_diversity_statement_ emp_gender_diversity_statement_y diversity_statement diversity_statement_source number_women_directors pct_women_directors number_men_directors pct_men_directors num_women_neos num_men_neos num_directors_disclosed num_directors_survey num_directors_identified pct_board_identified num_directors_diverse pct_board_diverse num_neos_disclosed num_neos_survey num_neos_identified num_neos_diverse num_directors_leadership_exp num_directors_ceo_exp num_directors_cfo_exp num_directors_international_exp num_directors_industry_exp num_directors_financial_exp num_directors_technology_exp num_directors_risk_exp num_directors_government_exp num_directors_audit_exp num_directors_sales_exp num_directors_academic_exp num_directors_legal_exp num_directors_human_resources_ex num_directors_strategic_planning num_directors_operations_exp num_directors_mergers_acquisitio num_directors_csr_sri_exp median_director_age stdev_director_age median_director_tenure stdev_director_tenure pct_board_tenure_gt_9_yrs pct_board_tenure_lt_6_yrs

save "${folder_save_databases}/iss/DB ISSDD Origin Firm-Event Level", replace
clear

**# Import ISS Director Diversity - Diversity Director database (firm-event-person-role level data).
local first_year_month // The macro starts empty, and each loop adds a list of names to the macro.
local year_month_list // The macro starts empty, and each loop adds a list of names to the macro.

	local first_year_month `first_year_month' 201301

	foreach year of numlist 2013(1)$last_year {
		foreach month of numlist 1(1)12 {
			if `month'<10 {
				local month "0`month'"
			}
			local year_month_list `year_month_list' `year'`month'
		}
	}

foreach year_month of local year_month_list {
	display "Importing Diversity Director database for " =substr("`year_month'", 1, 4) "-" =substr("`year_month'", 5, 2)
	quietly import_delimited using "${folder_original_databases}/ISS_director_diversity_data/current_datasets/full_history/diversity_director_${iss_database_date}_`year_month'.txt", delimiter("|", asstring) asdouble charset("utf8") clear
	confirm variable person_company_role_event_id person_company_event_id co_person_id company_event_id iss_company_id data_capture_type iss_person_id association_type executive_title_disclosed executive_title_iss ceo_yn founder_type eca_person_year_id include_in_board_stats_yn director_start_date director_start_date_precision age psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills, exact // Verifies that no variable is missing. The option "exact" makes the command to match the name of the variables exactly, without abbreviations.
	quietly describe // Extracts the number of variables.
	assert `r(k)'==36 // Verifies that no variable in addition to the list above is present.
	generate merged_file = substr("`year_month'", 1, 4) + "-" + substr("`year_month'", 5, 2)
	quietly save "Database Diversity Director `year_month'", replace
	clear
}

local year_month_list: list year_month_list - first_year_month // Removes the first year-month pair of the macro list.
use "Database Diversity Director `first_year_month'"
erase "Database Diversity Director `first_year_month'.dta"

foreach year_month of local year_month_list {
	display "Appending Diversity Director database for " =substr("`year_month'", 1, 4) "-" =substr("`year_month'", 5, 2)
	quietly append using "Database Diversity Director `year_month'"
	quietly erase "Database Diversity Director `year_month'.dta"
}

ds, has(type string) // Identifies all string variables in the database.
foreach variab in `r(varlist)' {
	quietly replace `variab' = strtrim(`variab') // Removes leading and trailing blanks in the string variables.
}

foreach variab in director_start_date {
	rename `variab' `variab'_temp
	assert length(`variab'_temp)==10 if !missing(`variab'_temp) // Some observations are missing, but all non-missing observations are 10 characters long (yyyy-mm-dd).
	generate double `variab' = date(`variab'_temp,"YMD")
	format %td `variab'
	replace `variab' = . if `variab'==date("01Jan1900","DMY") // The date "01Jan1900" means, for "director_start_date", that the date is either "n/d" or "n/c".
	assert `variab'!=date("01Jan2199","DMY")
	quietly log on
		* Observations whose dates do not conform to the "YMD" format are classified as missing.
		list director_start_date director_start_date_temp if missing(`variab') & !missing(`variab'_temp) & `variab'_temp!="1900-01-01"
		count if missing(`variab') & !missing(`variab'_temp) & `variab'_temp!="1900-01-01"
	quietly log off
	drop `variab'_temp
}

foreach variab in merged_file {
	rename `variab' `variab'_temp
	assert length(`variab'_temp)==7 // All observations are 7 characters long (yyyy-mm).
	generate double `variab' = monthly(`variab'_temp,"YM")
	format %tm `variab'
	assert !missing(`variab') if !missing(`variab'_temp)
	drop `variab'_temp
}

ds, has(type numeric)
foreach variab in `r(varlist)' {
	capture assert `variab'!=-1 // Minus one is a missing value in the database. The "capture" command stores any error code in "_rc".
	if _rc!=0 {
		display "The variable `variab' contained missing values reported as -1."
		replace `variab' = . if `variab'==-1
	}
	else {
	}
}

format %-30s executive_title_disclosed executive_title_iss

assert !missing(person_company_role_event_id)
duplicates report person_company_role_event_id
assert `r(unique_value)'==`r(N)' // Verifies that "person_company_role_event_id" is a unique identifier.
sort person_company_role_event_id
order person_company_role_event_id person_company_event_id co_person_id company_event_id iss_company_id data_capture_type iss_person_id association_type merged_file executive_title_disclosed executive_title_iss ceo_yn founder_type eca_person_year_id include_in_board_stats_yn director_start_date director_start_date_precision age psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills

save "${folder_save_databases}/iss/DB ISSDD Origin Firm-Event-Person-Role Level", replace
clear

**# Import ISS Director Diversity - Company Ethnicity database (firm-event-ethnicity level data).
import_delimited using "${folder_original_databases}/ISS_director_diversity_data/current_datasets/full_history/company_ethnicity_${iss_database_date}.txt", delimiter("|", asstring) asdouble charset("utf8") clear

ds, has(type string) // Identifies all string variables in the database.
foreach variab in `r(varlist)' {
	quietly replace `variab' = strtrim(`variab') // Removes leading and trailing blanks in the string variables.
}

ds, has(type numeric)
foreach variab in `r(varlist)' {
	assert `variab'!=-1 // Minus one is a missing value in the database. Verifies that there is no numerical variable with a missing value.
}

format %-30s person_ethnicity

assert !missing(company_ethnicity_event_id)
duplicates report company_ethnicity_event_id
assert `r(unique_value)'==`r(N)' // Verifies that "company_ethnicity_event_id" is a unique identifier.
sort company_ethnicity_event_id
order company_ethnicity_event_id company_event_id iss_company_id person_ethnicity person_ethnicity_code num_directors pct_board num_women_directors pct_women_board num_board_leaders num_women_board_leaders num_neos num_women_neos num_founders num_individuals num_women_individuals num_individuals_primary num_women_individuals_primary num_directors_primary num_women_directors_primary num_neos_primary num_women_neos_primary pct_board_primary pct_women_board_primary

save "${folder_save_databases}/iss/DB ISSDD Origin Firm-Event-Ethnicity Level", replace
clear

**# Import ISS Director Diversity - Person database (person level data).
import_delimited using "${folder_original_databases}/ISS_director_diversity_data/current_datasets/full_history/person_${iss_database_date}.txt", delimiter("|", asstring) asdouble charset("utf8") clear

ds, has(type string) // Identifies all string variables in the database.
foreach variab in `r(varlist)' {
	quietly replace `variab' = strtrim(`variab') // Removes leading and trailing blanks in the string variables.
}

foreach variab in birth_date {
	rename `variab' `variab'_temp
	generate double `variab' = date(`variab'_temp,"YMD")
	format %td `variab'
	assert !missing(`variab')
	assert `variab'==date("01Jan1900", "DMY") if (birth_date_precision=="n/c" | birth_date_precision=="n/d" | missing(birth_date_precision)) // When the "birth_date_precision" is not collected, disclosed, or missing, "birth_date" should always be missing.
	quietly replace `variab' = . if `variab'==date("01Jan1900","DMY") // The date "01Jan1900" means the value is missing.
	assert `variab'!=date("01Jan2199","DMY")
	assert (birth_date_precision=="yyyy" | birth_date_precision=="yyyy-mm" | birth_date_precision=="yyyy-mm-dd") if !missing(birth_date)
	drop `variab'_temp
}

foreach variab in person_updated_date {
	rename `variab' `variab'_temp
	generate double `variab' = clock(`variab'_temp,"YMDhms") // The Stata manual says that it automatically looks for "AM" and "PM".
	format %tc `variab'
	assert !missing(`variab') if !missing(`variab'_temp)
	drop `variab'_temp
}

foreach variab in iss_person_id person_updated_date {
	assert `variab'!=-1 // Minus one is a missing value in the database. Verifies that there is no observation with a missing value. Does not apply to variable "birth_date".
}

foreach variab in deceased_yn deceased_date {
	assert missing(`variab') // All values of the variable are missing.
	drop `variab'
}

format %-30s first_name last_name person_ethnicity
format %-10s middle_name

assert !missing(iss_person_id)
duplicates report iss_person_id
assert `r(unique_value)'==`r(N)' // Verifies that "iss_person_id" is a unique identifier.
sort iss_person_id
order iss_person_id person_cik first_name last_name middle_name person_ethnicity person_ethnicity_2 person_ethnicity_3 person_ethnicity_code person_ethnicity_code_2 person_ethnicity_code_3 ethnicity_id_type ethnicity_source photo_source gender birth_date birth_date_precision person_updated_date

save "${folder_save_databases}/iss/DB ISSDD Origin Person Level", replace
clear

**# Merge the ISS Director Diversity databases at the firm-event level.
use "${folder_save_databases}/iss/DB ISSDD Origin Firm-Event Level", clear
	assert !missing(iss_company_id)
	merge m:1 iss_company_id using "${folder_save_databases}/iss/DB ISSDD Origin Firm Level", keep(match master) // Non-matched observations from the using database are not useful because those are just firm identifiers.
	assert _merge==3 // All observations from the master database matched.
	drop _merge

	drop pct_women_directors pct_men_directors pct_board_identified pct_board_diverse // These variables can be recovered at any point by dividing the variable that contains the respective number of directors by "board_size" and multiplying by 100.

	order company_event_id iss_company_id company_event_order_rank from_date to_date most_recent_event_yn iss_meeting_id last_meeting_date most_recent_fy_end_date data_capture_type company_name iss_country entity_type_code entity_status_code cusip isin ticker sedol gvkey iid cik gics_8_code gics_sub_industry ipo_date delisted_reason delisted_date primary_exchange country_of_incorporation state_of_incorporation country_of_address state_of_address msa_name hq_address jpn_source_data_yn board_size gender_diversity_statement_detai board_gender_diversity_policy_yn board_gender_diversity_goal_num board_gender_diversity_goal_pct board_gender_diversity_statement exec_gender_diversity_policy_yn exec_gender_diversity_goal_num exec_gender_diversity_goal_pct exec_gender_diversity_statement_ mgmt_gender_diversity_statement_ emp_gender_diversity_statement_y diversity_statement diversity_statement_source number_women_directors number_men_directors num_women_neos num_men_neos num_directors_disclosed num_directors_survey num_directors_identified num_directors_diverse num_neos_disclosed num_neos_survey num_neos_identified num_neos_diverse num_directors_leadership_exp num_directors_ceo_exp num_directors_cfo_exp num_directors_international_exp num_directors_industry_exp num_directors_financial_exp num_directors_technology_exp num_directors_risk_exp num_directors_government_exp num_directors_audit_exp num_directors_sales_exp num_directors_academic_exp num_directors_legal_exp num_directors_human_resources_ex num_directors_strategic_planning num_directors_operations_exp num_directors_mergers_acquisitio num_directors_csr_sri_exp median_director_age stdev_director_age median_director_tenure stdev_director_tenure pct_board_tenure_gt_9_yrs pct_board_tenure_lt_6_yrs

	assert !missing(company_event_id)
	duplicates report company_event_id
	assert `r(unique_value)'==`r(N)' // Verifies that "company_event_id" is a unique identifier.

	assert !missing(iss_company_id, company_event_order_rank)
	duplicates report iss_company_id company_event_order_rank
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "company_event_order_rank" are a unique identifier pair.
	sort iss_company_id company_event_order_rank

	save "DB ISSDD Firm-Event Level - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Origin Firm-Event-Ethnicity Level", clear
	assert missing(num_women_individuals_primary) // All values of this variable are missing.
	drop num_women_individuals_primary

	foreach v in num_directors num_neos {
		gen dif_`v'_primary = cond(`v'!=`v'_primary, 1, 0) if !missing(`v', `v'_primary)
		bysort company_event_id (company_ethnicity_event_id): egen max_dif_`v'_primary = max(dif_`v'_primary)
		drop if max_dif_`v'_primary>0 // Removes the few observations in which the number of directors/NEOs of a certain ethnicity is not the same as the number of a certain "primary" ethnicity. The whole firm-event is dropped.
		drop dif_`v'_primary max_dif_`v'_primary
	}

	foreach variab in num_directors num_individuals num_women_directors pct_board pct_women_board num_neos num_women_neos {
		assert `variab'==`variab'_primary
		drop `variab'_primary // The "partial or primary" ethnicity is the same as the primary.
	}

	drop pct_women_board num_women_board_leaders // We are not interested in the intersection between ethnicity and gender at this point. However, I keep "num_women_directors", "num_women_neos", and "num_women_individuals" to aggregate across ethnicities, having a measure at the firm-event level.
	drop num_founders // We are not interested in the intersection between ethnicity and founder at this point.

	assert !missing(num_directors, num_board_leaders)
	assert num_directors>=num_board_leaders // A board leader is a: (1) board chair, (2) lead director, (3) nominating committee chair, (4) compensation committee chair, and/or (5) audit committee chair.
	assert !missing(num_individuals, num_directors, num_neos)
	assert num_individuals<=(num_directors + num_neos) // An executive that is on the board is both a director and a named executive officer (NEO).
	assert num_individuals>=num_directors // An executive that is on the board is both a director and a named executive officer (NEO).
	assert num_individuals>=num_neos // An executive that is on the board is both a director and a named executive officer (NEO).

	assert !missing(num_directors, num_women_directors)
	assert num_directors>=num_women_directors // A board member can be male or female.
	assert !missing(num_neos, num_women_neos)
	assert num_neos>=num_women_neos // A named executive officer can be male or female.
	assert !missing(num_individuals, num_women_individuals)
	assert num_individuals>=num_women_individuals // An individual can be male or female.

	assert !missing(num_women_individuals, num_women_directors, num_women_neos)
	assert num_women_individuals<=(num_women_directors + num_women_neos) // An executive that is on the board is both a director and a named executive officer (NEO).
	assert num_women_individuals>=num_women_directors // An executive that is on the board is both a director and a named executive officer (NEO).
	assert num_women_individuals>=num_women_neos // An executive that is on the board is both a director and a named executive officer (NEO).

	assert !missing(num_directors)
	bysort company_event_id: egen double total_num_directors_comp_event = total(num_directors), missing // The option "missing" does not really make a difference, as there are no missing values in the database, as checked by the "assert" command above.
	assert !missing(total_num_directors_comp_event)
	assert !missing(pct_board)
	bysort company_event_id: egen double total_pct_board_comp_event = total(pct_board), missing // The option "missing" does not really make a difference, as there are no missing values in the database, as checked by the "assert" command above.
	assert float(total_pct_board_comp_event)==1 if total_num_directors_comp_event!=0 // The percentages should sum to one, unless the total number of directors is zero.
	drop total_num_directors_comp_event total_pct_board_comp_event
	drop pct_board // The percentages can be created later.

	assert person_ethnicity_code!="n/d" & person_ethnicity_code!="nd" // There is ethnicity that is not disclosed in the database.
	replace person_ethnicity_code = "nc" if person_ethnicity_code=="n/c"
	assert company_ethnicity_event_id == company_event_id + "_" + person_ethnicity_code // There is no need for the variable "company_ethnicity_event_id". It is just a concatenation of "company_event_id" and "person_ethnicity_code".
	drop company_ethnicity_event_id
	assert !missing(person_ethnicity_code)
	replace person_ethnicity_code = "_" + person_ethnicity_code
	replace person_ethnicity = "not collected" if person_ethnicity == "n/c"

	foreach variab of varlist _all { // Applies to all the variables in the database.
		assert !missing(`variab') // There are no missing values in the database. That means that all missing values that show up later are due to the "reshape wide" command.
	}

	order company_event_id iss_company_id person_ethnicity_code person_ethnicity num_directors num_board_leaders num_neos num_individuals num_women_directors num_women_neos num_women_individuals
	reshape wide person_ethnicity num_directors num_board_leaders num_neos num_individuals num_women_directors num_women_neos num_women_individuals, i(company_event_id) j(person_ethnicity_code) string
	confirm variable iss_company_id, exact // The command "reshape wide" checks whether the values of a variable that is not in the command's varlist are constant across the values of the i() variable. If the values are not constant, the command breaks.
	order iss_company_id company_event_id

	foreach variab of varlist person_ethnicity_* {
		quietly egen `variab'_mode = mode(`variab') // As there is only one unique non-missing string for each variable and the "mode" function ignores missing values, there are other functions that could have been used.
		assert `variab'==`variab'_mode if !missing(`variab') // Confirms that all non-missing values are identical.
		quietly replace `variab' = `variab'_mode if missing(`variab') // Substitutes missing values.
		assert !missing(`variab') // Checks that there are no missing names anymore.
		quietly bysort `variab': gen different = 1 if (`variab'[1]!=`variab'[_N])
		assert missing(different) // Checks that all observations are identical for that variable.
		quietly drop `variab'_mode different
	}

	foreach eth_code in "a" "b" "hl" "i" "m" "n" "nc" "o" "p" "pnd" "u" "w" {
		foreach variab in num_directors_`eth_code' num_board_leaders_`eth_code' num_neos_`eth_code' num_individuals_`eth_code' num_women_directors_`eth_code' num_women_neos_`eth_code' num_women_individuals_`eth_code' {
			label variable `variab' "`=person_ethnicity_`eth_code'[1]'" // The first value of the "person_ethnicity" variable becomes the label of the variable. Here, the first value is irrelevant because all values are the same.
			quietly replace `variab' = 0 if missing(`variab') // There were no missing values in the database before the "reshape wide" command. Therefore, the missing values are actually zeros.
		}
		drop person_ethnicity_`eth_code'
	}

	foreach variab in num_directors num_board_leaders num_neos num_individuals num_women_directors num_women_neos num_women_individuals {
		gen `variab'_ai = `variab'_a + `variab'_i
	}

	assert !missing(company_event_id)
	duplicates report company_event_id
	assert `r(unique_value)'==`r(N)' // Verifies that "company_event_id" is a unique identifier.
	sort company_event_id

	save "DB ISSDD Firm-Event Level - Temp 2", replace
	clear

use "DB ISSDD Firm-Event Level - Temp 1", clear
erase "DB ISSDD Firm-Event Level - Temp 1.dta"
merge 1:1 company_event_id using "DB ISSDD Firm-Event Level - Temp 2", keep(match master)
erase "DB ISSDD Firm-Event Level - Temp 2.dta"
tab board_size if _merge==1, missing // Some of the observations in the master database that could not be matched to the using database contain missing values for "board_size". However, I still keep them to maintain the structure of the master database.
drop _merge

foreach variab in num_directors_nd num_women_directors_nd num_women_neos_nd num_women_individuals_nd {
	capture confirm variable `variab', exact // "confirm" verifies the existence of a variable. The "capture" command stores any error code in "_rc".
		if _rc!=0 {
			display "The variable '`variab'' does not exist, as expected."
		}
		else {
			display as error "The variable '`variab'' exists."
			error 1 // Forces a break.
		}
}

drop if board_size != ( 		/// The sum of the number of directors in each ethnicity should be equal to board size.
	num_directors_a 	+ 		///
	num_directors_b 	+ 		///
	num_directors_hl 	+ 		///
	num_directors_i 	+ 		///
	num_directors_m 	+ 		///
	num_directors_n 	+ 		///
	num_directors_nc 	+ 		///
	num_directors_o 	+ 		///
	num_directors_p 	+ 		///
	num_directors_pnd 	+ 		///
	num_directors_u 	+ 		///
	num_directors_w 			///
) & !missing(board_size , 		///
	num_directors_a 	, 		///
	num_directors_b 	, 		///
	num_directors_hl 	, 		///
	num_directors_i 	, 		///
	num_directors_m 	, 		///
	num_directors_n 	, 		///
	num_directors_nc 	, 		///
	num_directors_o 	, 		///
	num_directors_p 	, 		///
	num_directors_pnd 	, 		///
	num_directors_u 	, 		///
	num_directors_w 			///
)

assert board_size == ( 			///
	num_directors_a 	+ 		///
	num_directors_b 	+ 		///
	num_directors_hl 	+ 		///
	num_directors_i 	+ 		///
	num_directors_m 	+ 		///
	num_directors_n 	+ 		///
	num_directors_nc 	+ 		///
	num_directors_o 	+ 		///
	num_directors_p 	+ 		///
	num_directors_pnd 	+ 		///
	num_directors_u 	+ 		///
	num_directors_w 			///
) if !missing(board_size, 		///
	num_directors_a 	, 		///
	num_directors_b 	, 		///
	num_directors_hl 	, 		///
	num_directors_i 	, 		///
	num_directors_m 	, 		///
	num_directors_n 	, 		///
	num_directors_nc 	, 		///
	num_directors_o 	, 		///
	num_directors_p 	, 		///
	num_directors_pnd 	, 		///
	num_directors_u 	, 		///
	num_directors_w 			///
)

assert num_directors_identified == ( 	///
	num_directors_a 	+ 				///
	num_directors_b 	+ 				///
	num_directors_hl 	+ 				///
	num_directors_i 	+ 				///
	num_directors_m 	+ 				///
	num_directors_n 	+ 				///
	num_directors_o 	+ 				///
	num_directors_p 	+ 				///
	num_directors_w 					///
) if !missing( 							///
	num_directors_a 	, 				///
	num_directors_b 	, 				///
	num_directors_hl 	, 				///
	num_directors_i 	, 				///
	num_directors_m 	, 				///
	num_directors_n 	, 				///
	num_directors_o 	, 				///
	num_directors_p 	, 				///
	num_directors_w 					///
) // Excludes the following variables: "num_directors_nc", "num_directors_pnd", and "num_directors_u".

assert num_directors_diverse == ( 	///
	num_directors_a 		+ 		///
	num_directors_b 		+ 		///
	num_directors_hl 		+ 		///
	num_directors_i 		+ 		///
	num_directors_m 		+ 		///
	num_directors_n 		+ 		///
	num_directors_o 		+ 		///
	num_directors_p 				///
) if !missing( 						///
	num_directors_diverse 	, 		///
	num_directors_a 		, 		///
	num_directors_b 		, 		///
	num_directors_hl 		, 		///
	num_directors_i 		, 		///
	num_directors_m 		, 		///
	num_directors_n 		, 		///
	num_directors_o 		, 		///
	num_directors_p 				///
) // Excludes the following variables: "num_directors_nc", "num_directors_pnd", "num_directors_u", and "num_directors_w".

assert number_women_directors == ( 		///
	num_women_directors_a 	+ 			///
	num_women_directors_b 	+ 			///
	num_women_directors_hl 	+ 			///
	num_women_directors_i 	+ 			///
	num_women_directors_m 	+ 			///
	num_women_directors_n 	+ 			///
	num_women_directors_nc 	+ 			///
	num_women_directors_o 	+ 			///
	num_women_directors_p 	+ 			///
	num_women_directors_pnd + 			///
	num_women_directors_u 	+ 			///
	num_women_directors_w 				///
) if !missing(number_women_directors, 	///
	num_women_directors_a 	, 			///
	num_women_directors_b 	, 			///
	num_women_directors_hl 	, 			///
	num_women_directors_i 	, 			///
	num_women_directors_m 	, 			///
	num_women_directors_n 	, 			///
	num_women_directors_nc 	, 			///
	num_women_directors_o 	, 			///
	num_women_directors_p 	, 			///
	num_women_directors_pnd , 			///
	num_women_directors_u 	, 			///
	num_women_directors_w 				///
)

assert !missing(num_directors_diverse) if iss_country=="USA" // The "num_directors_diverse" is not missing for all U.S. firms.
assert missing(num_directors_diverse) if iss_country!="USA" // The "num_directors_diverse" is missing for all non-U.S. firms.

assert !missing(iss_company_id, company_event_order_rank)
duplicates report iss_company_id company_event_order_rank
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "company_event_order_rank" are a unique identifier pair.
sort iss_company_id company_event_order_rank

foreach variab in num_directors_nd num_board_leaders_nd num_neos_nd num_individuals_nd num_women_directors_nd num_women_neos_nd num_women_individuals_nd {
	capture confirm variable `variab', exact // "confirm" verifies the existence of a variable. The "capture" command stores any error code in "_rc".
		if _rc!=0 {
			display "The variable '`variab'' does not exist, as expected."
		}
		else {
			display as error "The variable '`variab'' exists."
			error 1 // Forces a break.
		}
}

foreach eth_code in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "nc" "pnd" "u" "ai" {
	order num_directors_`eth_code' num_board_leaders_`eth_code' num_neos_`eth_code' num_individuals_`eth_code' num_women_directors_`eth_code' num_women_neos_`eth_code' num_women_individuals_`eth_code', last
}

save "${folder_save_databases}/iss/DB ISSDD Firm-Event Level", replace
clear

**# Create filters and other variables for the ISS Director Diversity database at the firm-event level.
use "${folder_save_databases}/iss/DB ISSDD Firm-Event Level", clear

foreach variab in num_directors_nd num_women_directors_nd num_women_neos_nd num_women_individuals_nd {
	capture confirm variable `variab', exact // "confirm" verifies the existence of a variable. The "capture" command stores any error code in "_rc".
		if _rc!=0 {
			display "The variable '`variab'' does not exist, as expected."
		}
		else {
			display as error "The variable '`variab'' exists."
			error 1 // Forces a break.
		}
}

gen num_women_individuals = 		///
	num_women_individuals_a 	+ 	///
	num_women_individuals_b 	+ 	///
	num_women_individuals_hl 	+ 	///
	num_women_individuals_i 	+ 	///
	num_women_individuals_m 	+ 	///
	num_women_individuals_n 	+ 	///
	num_women_individuals_nc 	+ 	///
	num_women_individuals_o 	+ 	///
	num_women_individuals_p 	+ 	///
	num_women_individuals_pnd 	+ 	///
	num_women_individuals_u 	+ 	///
	num_women_individuals_w 		// The number of female individuals was not present in the firm-event database, and was obtained from the firm-event-ethnicity database.

assert num_women_individuals<=(number_women_directors + num_women_neos) if !missing(num_women_individuals, number_women_directors, num_women_neos)
assert num_women_individuals>=number_women_directors if !missing(num_women_individuals, number_women_directors)
assert num_women_individuals>=num_women_neos if !missing(num_women_individuals, num_women_neos)

gen num_dir_not_identified = board_size - ( ///
	num_directors_a 	+ 					///
	num_directors_b 	+ 					///
	num_directors_hl 	+ 					///
	num_directors_i 	+ 					///
	num_directors_m 	+ 					///
	num_directors_n 	+ 					///
	num_directors_p 	+ 					///
	num_directors_w 	+ 					///
	num_directors_o 						///
) // Excludes the following variables: "num_directors_nc", "num_directors_pnd", and "num_directors_u".

assert num_dir_not_identified==(num_directors_nc + num_directors_pnd + num_directors_u) if !missing(board_size)

gen prop_dir_identified = ( ///
	num_directors_a 	+ 	///
	num_directors_b 	+ 	///
	num_directors_hl 	+ 	///
	num_directors_i 	+ 	///
	num_directors_m 	+ 	///
	num_directors_n 	+ 	///
	num_directors_p 	+ 	///
	num_directors_w 	+ 	///
	num_directors_o 		///
) / board_size // Excludes the following variables: "num_directors_nc", "num_directors_pnd", and "num_directors_u".

gen prop_dir_survey = num_directors_survey / board_size

gen prop_dir_disc_to_ident = num_directors_disclosed / ( 	///
	num_directors_a 	+ 									///
	num_directors_b 	+ 									///
	num_directors_hl 	+ 									///
	num_directors_i 	+ 									///
	num_directors_m 	+ 									///
	num_directors_n 	+ 									///
	num_directors_p 	+ 									///
	num_directors_w 	+ 									///
	num_directors_o 										///
) // Excludes the following variables: "num_directors_nc", "num_directors_pnd", and "num_directors_u".

gen prop_dir_diverse = ( 	///
	num_directors_a 	+ 	///
	num_directors_b 	+ 	///
	num_directors_hl 	+ 	///
	num_directors_i 	+ 	///
	num_directors_m 	+ 	///
	num_directors_n 	+ 	///
	num_directors_p 	+ 	///
	num_directors_o 		///
) / board_size // Excludes the following variables: "num_directors_nc", "num_directors_pnd", "num_directors_u", and "num_directors_w".

gen prop_dir_diverse_o_ident = ( 	///
	num_directors_a 	+ 			///
	num_directors_b 	+ 			///
	num_directors_hl 	+ 			///
	num_directors_i 	+ 			///
	num_directors_m 	+ 			///
	num_directors_n 	+ 			///
	num_directors_p 	+ 			///
	num_directors_o 				///
) / ( 								///
	num_directors_a 	+ 			///
	num_directors_b 	+ 			///
	num_directors_hl 	+ 			///
	num_directors_i 	+ 			///
	num_directors_m 	+ 			///
	num_directors_n 	+ 			///
	num_directors_p 	+ 			///
	num_directors_w 	+ 			///
	num_directors_o 				///
) // Excludes the following variables: "num_directors_nc", "num_directors_pnd", "num_directors_u", and "num_directors_w".

foreach eth_code in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" {
	gen dummy_dir_`eth_code' = cond(num_directors_`eth_code'>0, 1, 0) if !missing(num_directors_`eth_code') // It is equal to one if there is at least one director with such ethnicity.
	gen prop_dir_`eth_code'_o_identified = num_directors_`eth_code' / num_directors_identified
	gen prop_dir_`eth_code'_o_board = num_directors_`eth_code' / board_size
}

capture confirm variable num_board_leaders_nd, exact // "confirm" verifies the existence of a variable. The "capture" command stores any error code in "_rc".
	if _rc!=0 {
		display "The variable 'num_board_leaders_nd' does not exist, as expected."
	}
	else {
		display as error "The variable 'num_board_leaders_nd' exists."
		error 1 // Forces a break.
	}

gen prop_dir_leaders = ( 		///
	num_board_leaders_a 	+ 	///
	num_board_leaders_b 	+ 	///
	num_board_leaders_hl 	+ 	///
	num_board_leaders_i 	+ 	///
	num_board_leaders_m 	+ 	///
	num_board_leaders_n 	+ 	///
	num_board_leaders_p 	+ 	///
	num_board_leaders_w 	+ 	///
	num_board_leaders_o 	+ 	///
	num_board_leaders_nc 	+ 	///
	num_board_leaders_pnd 	+ 	///
	num_board_leaders_u 		///
) / board_size

gen prop_dir_leaders_diverse = ( 	///
	num_board_leaders_a 	+ 		///
	num_board_leaders_b 	+ 		///
	num_board_leaders_hl 	+ 		///
	num_board_leaders_i 	+ 		///
	num_board_leaders_m 	+ 		///
	num_board_leaders_n 	+ 		///
	num_board_leaders_p 	+ 		///
	 num_board_leaders_o 			///
) / board_size // Excludes the following variables: "num_board_leaders_nc", "num_board_leaders_pnd", "num_board_leaders_u", and "num_board_leaders_w".

gen prop_dir_leaders_diverse_leaders = ( 	///
	num_board_leaders_a 	+ 				///
	num_board_leaders_b 	+ 				///
	num_board_leaders_hl 	+ 				///
	num_board_leaders_i 	+ 				///
	num_board_leaders_m 	+ 				///
	num_board_leaders_n 	+ 				///
	num_board_leaders_p 	+ 				///
	num_board_leaders_o 					///
) / ( 										///
	num_board_leaders_a 	+ 				///
	num_board_leaders_b 	+ 				///
	num_board_leaders_hl 	+ 				///
	num_board_leaders_i 	+ 				///
	num_board_leaders_m 	+ 				///
	num_board_leaders_n 	+ 				///
	num_board_leaders_p 	+ 				///
	num_board_leaders_w 	+ 				///
	num_board_leaders_o 	+ 				///
	num_board_leaders_nc 	+ 				///
	num_board_leaders_pnd 	+ 				///
	num_board_leaders_u 					///
) // Excludes the following variables: "num_board_leaders_w", "num_board_leaders_nc", "num_board_leaders_pnd", and "num_board_leaders_u".

capture confirm variable num_neos_nd, exact // "confirm" verifies the existence of a variable. The "capture" command stores any error code in "_rc".
	if _rc!=0 {
		display "The variable 'num_neos_nd' does not exist, as expected."
	}
	else {
		display as error "The variable 'num_neos_nd' exists."
		error 1 // Forces a break.
	}

gen prop_neos_identified = ( 	///
	num_neos_a 		+ 			///
	num_neos_b 		+ 			///
	num_neos_hl 	+ 			///
	num_neos_i 		+ 			///
	num_neos_m 		+ 			///
	num_neos_n 		+ 			///
	num_neos_p 		+ 			///
	num_neos_w 		+ 			///
	num_neos_o 					///
) / ( 							///
	num_neos_a 		+ 			///
	num_neos_b 		+ 			///
	num_neos_hl 	+ 			///
	num_neos_i 		+ 			///
	num_neos_m 		+ 			///
	num_neos_n 		+ 			///
	num_neos_p 		+ 			///
	num_neos_w 		+ 			///
	num_neos_o 		+ 			///
	num_neos_nc 	+ 			///
	num_neos_pnd 	+ 			///
	num_neos_u 					///
) // Excludes the following variables: "num_neos_nc", "num_neos_pnd", and "num_neos_u".

gen prop_neos_diverse = ( 	///
	num_neos_a 		+ 		///
	num_neos_b 		+ 		///
	num_neos_hl 	+ 		///
	num_neos_i 		+ 		///
	num_neos_m 		+ 		///
	num_neos_n 		+ 		///
	num_neos_p 		+ 		///
	num_neos_o 				///
) / ( 						///
	num_neos_a 		+ 		///
	num_neos_b 		+ 		///
	num_neos_hl 	+ 		///
	num_neos_i 		+ 		///
	num_neos_m 		+ 		///
	num_neos_n 		+ 		///
	num_neos_p 		+ 		///
	num_neos_w 		+ 		///
	num_neos_o 		+ 		///
	num_neos_nc 	+ 		///
	num_neos_pnd 	+ 		///
	num_neos_u 				///
) // Excludes the following variables: "num_neos_nc", "num_neos_pnd", "num_neos_u", and " num_neos_w".

gen num_neos_total = ( 	///
	num_neos_a 		+ 	///
	num_neos_b 		+ 	///
	num_neos_hl 	+ 	///
	num_neos_i 		+ 	///
	num_neos_m 		+ 	///
	num_neos_n 		+ 	///
	num_neos_nc 	+ 	///
	num_neos_o 		+ 	///
	num_neos_p 		+ 	///
	num_neos_pnd 	+ 	///
	num_neos_u 		+ 	///
	num_neos_w 			///
)

gen num_neos_identified_correct = ( 	///
	num_neos_a 	+ 						///
	num_neos_b 	+ 						///
	num_neos_hl + 						///
	num_neos_i 	+ 						///
	num_neos_m 	+ 						///
	num_neos_n 	+ 						///
	num_neos_o 	+ 						///
	num_neos_p 	+ 						///
	num_neos_w 							///
) // Excludes the following variables: "num_neos_nc", "num_neos_pnd", and "num_neos_u".

foreach eth_code in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" {
	gen dummy_neos_`eth_code' = cond(num_neos_`eth_code'>0, 1, 0) if !missing(num_neos_`eth_code') // It is equal to one if there is at least one NEO with such ethnicity.
	gen prop_neos_`eth_code'_o_identified = num_neos_`eth_code' / num_neos_identified_correct
	gen prop_neos_`eth_code'_o_total = num_neos_`eth_code' / num_neos_total
}

gen diff_dir_gender = board_size - number_women_directors - number_men_directors
gen prop_dir_women = number_women_directors / board_size if diff_dir_gender==0
gen prop_dir_men = number_men_directors / board_size if diff_dir_gender==0
drop diff_dir_gender

gen diff_neos_gender = ( 	///
	num_neos_a 		+ 		///
	num_neos_b 		+ 		///
	num_neos_hl 	+ 		///
	num_neos_i 		+ 		///
	num_neos_m 		+ 		///
	num_neos_n 		+ 		///
	num_neos_p 		+ 		///
	num_neos_w 		+ 		///
	num_neos_o 		+ 		///
	num_neos_nc 	+ 		///
	num_neos_pnd 	+ 		///
	num_neos_u 				///
) - num_women_neos - num_men_neos

gen prop_neos_women = num_women_neos / ( 	///
	num_neos_a 		+ 						///
	num_neos_b 		+ 						///
	num_neos_hl 	+ 						///
	num_neos_i 		+ 						///
	num_neos_m 		+ 						///
	num_neos_n 		+ 						///
	num_neos_p 		+ 						///
	num_neos_w 		+ 						///
	num_neos_o 		+ 						///
	num_neos_nc 	+ 						///
	num_neos_pnd 	+ 						///
	num_neos_u 								///
) if diff_neos_gender==0

gen prop_neos_men = num_men_neos / ( 	///
	num_neos_a 		+ 					///
	num_neos_b 		+ 					///
	num_neos_hl 	+ 					///
	num_neos_i 		+ 					///
	num_neos_m 		+ 					///
	num_neos_n 		+ 					///
	num_neos_p 		+ 					///
	num_neos_w 		+ 					///
	num_neos_o 		+ 					///
	num_neos_nc 	+ 					///
	num_neos_pnd 	+ 					///
	num_neos_u 							///
) if diff_neos_gender==0

drop diff_neos_gender

gen length_gics_8 = length(string(gics_8_code,"%12.0f")) if !missing(gics_8_code)
assert length_gics_8==8 if !missing(gics_8_code)
drop length_gics_8
gen gics_6_code = floor(gics_8_code / 100)
gen gics_4_code = floor(gics_8_code / 10000)
gen gics_2_code = floor(gics_8_code / 1000000)

assert !missing(primary_exchange)
gen exchange = "Cross-Listed"
replace exchange = "OTC" if 					///
	primary_exchange == "OTC Markets" 	| 		///
	primary_exchange == "US OTC" 		| 		///
	primary_exchange == "Norwegian OTC Market"
replace exchange = "Primary US" if 				///
	primary_exchange == "NASDAQ" 		| 		///
	primary_exchange == "NYSE American" | 		///
	primary_exchange == "New York Stock Exchange"
replace exchange = "Not Traded" if 				///
	primary_exchange == "Not Traded"
replace exchange = "" if 						///
	primary_exchange == "UNKNOWN" 		| 		///
	primary_exchange == "n/a"
gen us_listed = cond(exchange=="Primary US", 1, 0) if !missing(exchange)

assert !missing(iss_country, country_of_incorporation)
gen filter_us = cond(iss_country=="USA" & country_of_incorporation=="USA", 1, 0)
gen filter_has_gvkey = cond(!missing(gvkey), 1, 0)
gen filter_has_cik = cond(!missing(cik), 1, 0)
gen filter_gics_non_financial = cond(gics_2_code!=40, 1, 0) if !missing(gics_2_code) // 4010 represents "Banks", 4020 represents "Diversified Financials", and 4030 represents "Insurance".
	assert !missing(filter_gics_non_financial) if !missing(gics_8_code) // The dummy is not missing when "gics_8_code" is not missing.
gen filter_board_size = inrange(board_size, 4, 16) if !missing(board_size)
gen filter_prop_dir_ident = cond(prop_dir_identified>=0.7, 1, 0) if !missing(prop_dir_identified)

assert !missing(iss_company_id, company_event_order_rank)
duplicates report iss_company_id company_event_order_rank
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "company_event_order_rank" are a unique identifier pair.
sort iss_company_id company_event_order_rank

order company_event_id iss_company_id company_event_order_rank from_date to_date most_recent_event_yn iss_meeting_id last_meeting_date most_recent_fy_end_date data_capture_type company_name iss_country entity_type_code entity_status_code cusip isin ticker sedol gvkey iid cik gics_sub_industry gics_8_code gics_6_code gics_4_code gics_2_code ipo_date delisted_reason delisted_date primary_exchange exchange us_listed country_of_incorporation state_of_incorporation country_of_address state_of_address msa_name hq_address jpn_source_data_yn board_size gender_diversity_statement_detai board_gender_diversity_policy_yn board_gender_diversity_goal_num board_gender_diversity_goal_pct board_gender_diversity_statement exec_gender_diversity_policy_yn exec_gender_diversity_goal_num exec_gender_diversity_goal_pct exec_gender_diversity_statement_ mgmt_gender_diversity_statement_ emp_gender_diversity_statement_y diversity_statement diversity_statement_source number_women_directors prop_dir_women number_men_directors prop_dir_men num_women_neos prop_neos_women num_men_neos prop_neos_men num_women_individuals num_directors_disclosed prop_dir_disc_to_ident num_directors_survey prop_dir_survey num_directors_identified num_dir_not_identified prop_dir_identified num_directors_diverse prop_dir_diverse prop_dir_diverse_o_ident prop_dir_leaders prop_dir_leaders_diverse prop_dir_leaders_diverse_leaders num_neos_disclosed num_neos_survey num_neos_identified num_neos_identified_correct prop_neos_identified num_neos_diverse prop_neos_diverse num_neos_total num_directors_leadership_exp num_directors_ceo_exp num_directors_cfo_exp num_directors_international_exp num_directors_industry_exp num_directors_financial_exp num_directors_technology_exp num_directors_risk_exp num_directors_government_exp num_directors_audit_exp num_directors_sales_exp num_directors_academic_exp num_directors_legal_exp num_directors_human_resources_ex num_directors_strategic_planning num_directors_operations_exp num_directors_mergers_acquisitio num_directors_csr_sri_exp median_director_age stdev_director_age median_director_tenure stdev_director_tenure pct_board_tenure_gt_9_yrs pct_board_tenure_lt_6_yrs

foreach eth_code in "a" "b" "hl" "i" "m" "n" "p" "w" "o" {
	order num_directors_`eth_code' num_board_leaders_`eth_code' num_neos_`eth_code' num_individuals_`eth_code' num_women_directors_`eth_code' num_women_neos_`eth_code' num_women_individuals_`eth_code' dummy_dir_`eth_code' prop_dir_`eth_code'_o_identified prop_dir_`eth_code'_o_board dummy_neos_`eth_code' prop_neos_`eth_code'_o_identified prop_neos_`eth_code'_o_total, last
}

foreach eth_code in "nc" "pnd" "u" {
	order num_directors_`eth_code' num_board_leaders_`eth_code' num_neos_`eth_code' num_individuals_`eth_code' num_women_directors_`eth_code' num_women_neos_`eth_code' num_women_individuals_`eth_code', last
}

foreach eth_code in "ai" {
	order num_directors_`eth_code' num_board_leaders_`eth_code' num_neos_`eth_code' num_individuals_`eth_code' num_women_directors_`eth_code' num_women_neos_`eth_code' num_women_individuals_`eth_code' dummy_dir_`eth_code' prop_dir_`eth_code'_o_identified prop_dir_`eth_code'_o_board dummy_neos_`eth_code' prop_neos_`eth_code'_o_identified prop_neos_`eth_code'_o_total, last
}

order filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident, last

save "${folder_save_databases}/iss/DB ISSDD Firm-Event Level Filters", replace
clear

**# Structure the ISS Director Diversity databases at the firm-year level.
use "${folder_save_databases}/iss/DB ISSDD Firm-Event Level Filters", clear
	keep cusip // I merge ISS to CRSP based on cusip instead of the Compustat CRSP Linking Table because the timing of the identifiers is irrelevant in ISS. In ISS, the identifiers (e.g., "gvkey", "cusip") do not change over time and are based on the most recent data.
	drop if missing(cusip)
	duplicates drop // Extracts unique values of "cusip".
	assert length(cusip)==9

	gen cusip_8 = substr(cusip, 1, 8) // Cusip is a 8-digit variable in CRSP.
	assert length(cusip_8)==8

	assert !missing(cusip_8)
	duplicates report cusip_8
	assert `r(unique_value)'==`r(N)'
	sort cusip_8
	order cusip_8 cusip

	save "DB ISSDD Firm-Year Level - Temp 1", replace
	clear

use "${folder_original_databases}/CRSP/CRSPQ Daily - 2021-11-02", clear
	rename *, lower

	drop distcd divamt facpr facshr cfacpr cfacshr dclrdt rcrddt paydt acperm accomp // These variables are related to distribution events. When there are multiple distribution events in the same day, Permno and Date are no longer unique.
	duplicates drop // Changes the structure of the database from security-day-event to security-day.

	assert !missing(permno, date)
	duplicates report permno date
	assert `r(unique_value)'==`r(N)' // Verifies that permno-date is unique in the database. At this point, "cusip"-"date" is not unique.
	sort permno date

	rename cusip cusip_8

	merge m:1 cusip_8 using "DB ISSDD Firm-Year Level - Temp 1", keep(match) nogenerate // Observations for "_merge==1" are not going to be used to match to ISSDD. Observations for "_merge==3" do not have trading information in CRSP.
	erase "DB ISSDD Firm-Year Level - Temp 1.dta"

	keep comnam cusip date vol ret
	assert vol!=-99 // Verifies if there are no values that should be classified as missing.
	assert ret!=-66.0 & ret!=-77.0 & ret!=-88.0 & ret!=-99.0 // Verifies if there are no values that should be classified as missing.
	format %-30s comnam

	assert !missing(cusip, date)
	duplicates report cusip date
	assert `r(unique_value)'==`r(N)' // Verifies that cusip-date is unique in the database.
	sort cusip date
	order comnam cusip date vol ret

	drop if missing(vol) & (missing(ret) | ret==0) // Keeps non-missing volume observations and missing volume observations whose returns are non-missing and non-zero.
	drop if vol==0 & (missing(ret) | ret==0) // Keeps non-zero volume observations and zero volume observations whose returns are non-missing and non-zero.
	drop vol ret

	bysort cusip (date): egen max_date_crsp = max(date)
	format %td max_date_crsp
	keep if date==max_date_crsp // Only the most recent date for each "cusip" is kept.
	drop date

	rename comnam company_name_crsp

	assert !missing(cusip)
	duplicates report cusip
	assert `r(unique_value)'==`r(N)' // Verifies that cusip is unique in the database.
	sort cusip
	order company_name_crsp cusip max_date_crsp

	save "DB ISSDD Firm-Year Level - Temp 2", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Event Level Filters", clear

assert !missing(from_date)
assert !missing(to_date) if most_recent_event_yn==0
assert most_recent_event_yn==1 if missing(to_date) // "to_date" is only missing in the last (most recent) observation for each firm.
assert most_recent_event_yn==0 | most_recent_event_yn==1

duplicates report iss_company_id company_event_order_rank
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "company_event_order_rank" are a unique identifier pair.
bysort iss_company_id (company_event_order_rank): gen to_date_check = from_date[_n+1]
format %td to_date_check
assert missing(to_date_check) if to_date_check!=to_date // The difference between the two variables only occur in the last (most recent) observation for each firm.
assert most_recent_event_yn==1 if to_date_check!=to_date // The difference between the two variables only occur in the last (most recent) observation for each firm.
drop to_date_check // When "most_recent_event_yn" equals to one and "to_date" is not missing, there are firms whose securities registration was terminated (e.g., cik==54441, cik==1496268) or the firm concluded the merger (e.g., cik==320575). Now, for firms whose "most_recent_event_yn" equals to one and "to_date" is missing, some are still active (e.g., cik==1161728, cik==1724965, cik==752714), some filed the securities registration termination (e.g., cik==356028), some have not submitted documents to EDGAR in many years (e.g., cik==102049, cik==882873).

merge m:1 cusip using "DB ISSDD Firm-Year Level - Temp 2", keep(match master) nogenerate
erase "DB ISSDD Firm-Year Level - Temp 2.dta"
drop company_name_crsp

gen to_date_adj = to_date
replace to_date_adj = max_date_crsp if missing(to_date_adj) & from_date<=max_date_crsp // ISS may have tracked the company's board even after delisting its shares from the stock exchange.
replace to_date_adj = from_date if missing(to_date_adj) & most_recent_event_yn==1 // Now "to_date_adj" has no missing value.
replace to_date_adj = mdy(1, 1, year(to_date_adj) + 1) if most_recent_event_yn==1 // Changes the date to January 1 of the following year. This way I keep the whole last year for each firm, even if partially covered by ISS.
assert !missing(to_date_adj)
format %td to_date_adj
drop max_date_crsp

sort iss_company_id company_event_order_rank
order company_event_id iss_company_id company_event_order_rank from_date to_date to_date_adj

assert from_date<=to_date_adj // This means the minimum year is in "from_date", and the maximum year is in "to_date_adj".
gen year_from_date = year(from_date)
quietly summarize year_from_date, detail
local year_min = r(min)
drop year_from_date
gen year_to_date_adj = year(to_date_adj)
quietly summarize year_to_date_adj, detail
local year_max = r(max)
drop year_to_date_adj

local total_years = `year_max' - `year_min' + 1
expand `total_years'
bysort iss_company_id company_event_order_rank: gen calendar_year_end = mdy(12, 31, (_n - 1 + `year_min')) // Calculates the last calendar day for each year, from the minimum to the maximum.
format %td calendar_year_end

assert !missing(iss_company_id, company_event_order_rank, calendar_year_end)
duplicates report iss_company_id company_event_order_rank calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id", "company_event_order_rank", and "calendar_year_end" are a unique identifier triple.

assert !missing(from_date, to_date_adj, calendar_year_end)
gen match_window = cond(from_date<=calendar_year_end & to_date_adj>calendar_year_end, 1, 0) // Notice that the event happens in the "from_date", and the "to_date_adj" is simply the date of the next event. Therefore, a window match can start on the "calendar_year_end" or before, and must end after the "calendar_year_end". This solves issues with the "from_date" and "to_date_adj" being the same date. These are discarded because there will be a following event starting in that very same day and spanning a certain period of time that will be chosen for starting later that day. Notice also that by setting the window match this way, duplicates for the same event are created if the window is beyond one year. This is intended.
order company_event_id iss_company_id company_event_order_rank match_window calendar_year_end
keep if match_window==1 // After the "keep" command, some events disappear because their time interval does not overlap with the year-end date, and some are duplicated because they cover more than one year-end date. I manually checked "iss_company_id" equal to 143009, 141050, 17600, 39016, 505605, 546.
assert from_date!=to_date_adj // None of the same-day "from_date" and "to_date_adj" events are kept, which is correct, as there is always a more recent event starting on that very day.
drop match_window

bysort iss_company_id (calendar_year_end): egen min_cal_year_firm = min(year(calendar_year_end))
bysort iss_company_id (calendar_year_end): gen calendar_year_end_check = mdy(12, 31, (_n - 1 + min_cal_year_firm)) // Checks that the years are sequential for each company.
format %td calendar_year_end_check
assert calendar_year_end_check==calendar_year_end
drop min_cal_year_firm calendar_year_end_check

assert !missing(calendar_year_end)
gen calendar_year = year(calendar_year_end)
gen filter_period_year = cond(calendar_year>=2014 & calendar_year<=${last_year}, 1, 0)
gen sample = cond( 							///
	filter_us 					==1 	& 	///
	filter_has_gvkey 			==1 	& 	///
	filter_has_cik 				==1 	& 	///
	filter_gics_non_financial 	==1 	& 	///
	filter_board_size 			==1 	& 	///
	filter_prop_dir_ident 		==1 	& 	///
	filter_period_year 			==1 		///
, 1, 0) if 									///
	!missing(filter_us) 				& 	///
	!missing(filter_has_gvkey) 			& 	///
	!missing(filter_has_cik) 			& 	///
	!missing(filter_gics_non_financial) & 	///
	!missing(filter_board_size) 		& 	///
	!missing(filter_prop_dir_ident) 	& 	///
	!missing(filter_period_year)
gen sample_with_financial = cond( 			///
	filter_us 					==1 	& 	///
	filter_has_gvkey 			==1 	& 	///
	filter_has_cik 				==1 	& 	///
	filter_board_size 			==1 	& 	///
	filter_prop_dir_ident 		==1 	& 	///
	filter_period_year 			==1 		///
, 1, 0) if 									///
	!missing(filter_us) 				& 	///
	!missing(filter_has_gvkey) 			& 	///
	!missing(filter_has_cik) 			& 	///
	!missing(filter_gics_non_financial) & 	///
	!missing(filter_board_size) 		& 	///
	!missing(filter_prop_dir_ident) 	& 	///
	!missing(filter_period_year)

assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database changed to firm-calendar_year_end.
sort iss_company_id calendar_year_end

order company_event_id iss_company_id company_event_order_rank calendar_year calendar_year_end from_date to_date to_date_adj

save "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", replace
clear

**# Merge the ISS Director Diversity databases at the firm-event-director level.
use "${folder_save_databases}/iss/DB ISSDD Origin Person Level", clear
	assert !missing(iss_person_id)
	duplicates report iss_person_id
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_person_id" is a unique identifier.
	sort iss_person_id

	save "DB ISSDD Firm-Event-Director Level - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Origin Firm-Event-Person-Role Level", clear
assert !missing(person_company_role_event_id)
duplicates report person_company_role_event_id
assert `r(unique_value)'==`r(N)' // Verifies that "person_company_role_event_id" is a unique identifier.
sort person_company_role_event_id

merge m:1 iss_person_id using "DB ISSDD Firm-Event-Director Level - Temp 1", keep(match master) // Individual directors that are not matched to the master database cannot be matched to firms, and therefore are not useful observations.
erase "DB ISSDD Firm-Event-Director Level - Temp 1.dta"

gen non_matched = cond(_merge==1, 1, 0) if !missing(_merge)
bysort company_event_id (iss_person_id association_type): egen max_non_matched = max(non_matched)
drop if max_non_matched==1 // If a director is not matched, I drop the whole firm-event. This way, the sum of the individual observations within a firm-event is equal to "board_size" after setting "include_in_board_stats_yn" equal to one.
assert _merge==3
drop non_matched max_non_matched _merge

assert !missing(person_ethnicity_2)
gen not_nc_person_ethnicity_2 = cond(person_ethnicity_2!="n/c", 1, 0)
bysort company_event_id (person_company_role_event_id): egen max_not_nc_person_ethnicity_2 = max(not_nc_person_ethnicity_2)
drop if max_not_nc_person_ethnicity_2>0 // I remove all firm-events in which there is a director with multiple ethnicities.
drop not_nc_person_ethnicity_2 max_not_nc_person_ethnicity_2

foreach variab in person_ethnicity_2 person_ethnicity_3 person_ethnicity_code_2 person_ethnicity_code_3 {
	assert `variab'=="n/c"
	drop `variab'
}

assert substr(person_company_role_event_id, -2, 2)=="01" | substr(person_company_role_event_id, -2, 2)=="02"
assert association_type=="director" if substr(person_company_role_event_id, -2, 2)=="01"
assert association_type=="executive" if substr(person_company_role_event_id, -2, 2)=="02"
assert association_type=="director" if include_in_board_stats_yn==1 // Not all directors contain a "include_in_board_stats_yn==1".
assert !missing(include_in_board_stats_yn)
keep if include_in_board_stats_yn==1 // This variable serves to identify whether a director should be considered as part of the board, according to ISS.

assert !missing(person_company_event_id)
duplicates report person_company_event_id
assert `r(unique_value)'==`r(N)' // After keeping only role==01, "person_company_event_id" is a unique identifier.
sort person_company_event_id

save "${folder_save_databases}/iss/DB ISSDD Firm-Event-Director Level", replace
clear

**# Structure the ISS Director Diversity databases at the firm-year-director level.
use "${folder_save_databases}/iss/DB ISSDD Firm-Event-Director Level", clear
	drop iss_company_id data_capture_type // These variables are dropped to avoid duplicates after the "joinby" command.
	save "DB ISSDD Firm-Year-Director Level - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear
assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-calendar_year_end.
sort iss_company_id calendar_year_end

joinby company_event_id using "DB ISSDD Firm-Year-Director Level - Temp 1", unmatched(none) // I do not keep the few unmatched observations from the master database (_merge==1) because data on the individual directors is needed (the vast majority of these observations are from the last year). I do not keep the unmatched observations from the using database (_merge==2) because it contains event windows that do not cover the calendar-year-end.
erase "DB ISSDD Firm-Year-Director Level - Temp 1.dta"

bysort iss_company_id calendar_year_end (iss_person_id): gen board_size_check = _N // The new structure is firm-year-director.
assert board_size==board_size_check // Verifies that "board_size" is equal to the sum of the individual board members shown in the database.
drop board_size_check

capture confirm variable num_directors_nd, exact // "confirm" verifies the existence of a variable. The "capture" command stores any error code in "_rc".
	if _rc!=0 {
		display "The variable 'num_directors_nd' does not exist, as expected."
	}
	else {
		display as error "The variable 'num_directors_nd' exists."
		error 1 // Forces a break.
	}

foreach eth_code in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "n/c" "pnd" "u" { // Excludes "n/d", which is not present in the database at the firm-year level. Excludes "ai" because if it works for "a" and "i", it must work for the sum as well.
	gen director_ethnicity_`=subinstr("`eth_code'","/","",.)' = cond(person_ethnicity_code=="`eth_code'", 1, 0) if !missing(person_ethnicity_code)
	bysort iss_company_id calendar_year_end (iss_person_id): egen num_directors_`=subinstr("`eth_code'","/","",.)'_check = total(director_ethnicity_`=subinstr("`eth_code'","/","",.)')
	assert num_directors_`=subinstr("`eth_code'","/","",.)' == num_directors_`=subinstr("`eth_code'","/","",.)'_check if iss_country=="USA" // It does not work for all countries.
	drop director_ethnicity_`=subinstr("`eth_code'","/","",.)' num_directors_`=subinstr("`eth_code'","/","",.)'_check
}

assert !missing(iss_company_id, calendar_year_end, iss_person_id)
duplicates report iss_company_id calendar_year_end iss_person_id
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database changed to firm-calendar_year_end-director. I manually checked that the individual gender and race/ethnicity of directors match the aggregate measures at the firm-year for iss_company_id==441 & calendar_year==2018.
sort iss_company_id calendar_year_end iss_person_id

save "DB ISSDD Firm-Year-Director Level - Temp 2", replace // The following steps are not saved.

	keep if sample==1 // Keeps only observations from the main sample.
	bysort iss_person_id (person_updated_date): gen different = 1 if person_updated_date[1]!=person_updated_date[_N]
	assert missing(different) // Verifies that "person_updated_date" is identical for every "iss_person_id".
	drop different
	assert !missing(iss_person_id)
	collapse (mean) person_updated_date, by(iss_person_id) // The "mean" could be replaced by other statistics, as all the values of "person_updated_date" are identical for each "iss_person_id".
	gen year_update = yofd(dofc(person_updated_date))

	quietly log on
		* Distribution of the year in which the individual's ethnicity information was updated. The structure of the database is individual. Only individuals in the main sample are kept.
		tabulate year_update, miss
	quietly log off

	clear

use "DB ISSDD Firm-Year-Director Level - Temp 2", clear // The previous steps are discarded.
erase "DB ISSDD Firm-Year-Director Level - Temp 2.dta"

gen month_day_dir_start_date = string(month(director_start_date),"%02.0f") + "-" + string(day(director_start_date),"%02.0f") if !missing(director_start_date)
gen year_dir_start_date = year(director_start_date)
	quietly log on
		* Distribution of director start dates conditional on the variable's precision.
		tab director_start_date_precision if sample==1, miss
		tab month_day_dir_start_date if director_start_date_precision=="yyyy" & sample==1, miss
		tab month_day_dir_start_date if director_start_date_precision=="yyyy-mm" & sample==1, miss
		tab month_day_dir_start_date if (director_start_date_precision=="" | director_start_date_precision=="n/d") & sample==1, miss
		tab month_day_dir_start_date year_dir_start_date if director_start_date_precision=="yyyy-mm" & sample==1 & year_dir_start_date>=2014 & year_dir_start_date<=${last_year}, miss
		tab month_day_dir_start_date year_dir_start_date if director_start_date_precision=="yyyy-mm" & sample==1 & year_dir_start_date>=2014 & year_dir_start_date<=${last_year}, miss col nofreq
	quietly log off
drop month_day_dir_start_date year_dir_start_date

save "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", replace
clear

**# Create the ISS "directors_list" (ISS files of 2021-10-01).
use "${folder_save_databases}/iss/DB ISSDD Firm-Event-Director Level", clear

assert !missing(person_company_role_event_id)
duplicates report person_company_role_event_id
assert `r(unique_value)'==`r(N)' // Verifies that "person_company_role_event_id" is a unique identifier.
sort person_company_role_event_id
order person_company_role_event_id person_company_event_id co_person_id company_event_id iss_company_id data_capture_type iss_person_id association_type merged_file executive_title_disclosed executive_title_iss ceo_yn founder_type eca_person_year_id include_in_board_stats_yn director_start_date director_start_date_precision age psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills

merge m:1 iss_company_id using "${folder_save_databases}/iss/DB ISSDD Origin Firm Level", keep(match master) // Obtains firm identifiers. There is no point in keeping unmatched firm identifiers from the using database.
assert _merge==3 // All observations are matched.
drop _merge
keep if iss_country=="USA" & country_of_incorporation=="USA"
drop if missing(cik)
assert length(cusip)==9 if !missing(cusip)
rename cusip cusip_9
keep iss_company_id iss_person_id company_name cusip_9 isin ticker gvkey cik first_name last_name middle_name birth_date birth_date_precision director_start_date
duplicates drop // Removes duplicate observations, creating the firm-director pairs, independently of the event.

duplicates tag iss_company_id iss_person_id, gen(dup)
bysort iss_company_id iss_person_id (director_start_date): egen min_director_start_date = min(director_start_date)
format %td min_director_start_date
drop if dup>0 & director_start_date!=min_director_start_date // Keeps only the first "director_start_date" for each firm-director pair.
drop dup min_director_start_date

duplicates report iss_company_id iss_person_id
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "iss_person_id" form a unique identifier.
sort iss_company_id iss_person_id
order iss_company_id company_name gvkey cusip_9 isin cik ticker iss_person_id first_name middle_name last_name birth_date birth_date_precision director_start_date

save "${folder_save_databases}/iss/iss_directors_list_2021-10-01", replace
clear

**# Create a database of director appointments merged with ISS.

capture cd "YOUR_PATH\data\raw\Audit_Analytics\audit_plus_compliance"
	// use "Director and Officer Changes - 2021-10-30", clear
	// rename *, lower
	// compress
	// leftalign
	// save "Director and Officer Changes - 2021-10-30 compressed", replace

use "${folder_save_databases}\iss\iss_directors_list_2021-10-01.dta", clear
*iss_company_id iss_person_id director_start_date company_name cusip_9 isin ticker gvkey cik first_name last_name middle_name birth_date birth_date_precision

gen iss_birth_year = year(birth_date)
replace iss_birth_year = . if inrange(birth_date_precision, "n/c", "n/d")
tab iss_birth_year
browse
replace last_name = subinstr(last_name,".","",.)
replace first_name = subinstr(first_name,".","",.)
replace middle_name = subinstr(middle_name,".","",.)
replace last_name = subinstr(last_name,",","",.)
replace first_name = subinstr(first_name,",","",.)
replace middle_name = subinstr(middle_name,",","",.)

replace last_name = ustrtrim(last_name)
replace first_name = ustrtrim(first_name)
replace middle_name = ustrtrim(middle_name)

gen middle_initial = substr(middle_name,1,1)
tab middle_initial, miss
replace middle_initial = "" if !(regexm(lower(middle_initial), "[a-z]") | mi(middle_initial))
replace middle_initial = upper(middle_initial)
tab middle_initial, miss

gen ISS_FL_name = first_name + " " + last_name
gen ISS_FML_name = ISS_FL_name
replace ISS_FML_name = first_name + " " + middle_name + " " + last_name if !missing(middle_name)
gen ISS_FMiL_name = ISS_FL_name
replace ISS_FMiL_name = first_name + " " + middle_initial + " " + last_name if !missing(middle_initial)
leftalign

capture drop iss_cik_director_id
gen double iss_cik_director_id = (10000000 + iss_person_id) + (10000000*(10000000 + cik) - 10000000)
format iss_cik_director_id %18.0f
sum iss_cik_director_id, d
order iss_cik_director_id cik iss_person_id
browse

duplicates report iss_cik_director_id
duplicates tag iss_cik_director_id, gen(dups)
tab dups
sort iss_cik_director_id
browse if dups==1
*The duplicates show up only in October 2021 update. ISS has new company ID for 34 companies (name change, SPAC, etc.) but same CIK. I am retaining the earlier company ID
sort iss_cik_director_id iss_company_id
duplicates drop iss_cik_director_id, force
drop dups
duplicates report iss_cik_director_id
* no duplicates

gen start_year = year(director_start_date)
tab start_year, miss
browse if mi(start_year)
rename first_name iss_first_name
rename middle_name iss_middle_name
rename middle_initial iss_middle_initial
rename last_name iss_last_name
keep ISS_FL_name ISS_FML_name ISS_FMiL_name iss_first_name iss_middle_name iss_middle_initial iss_last_name iss_cik_director_id iss_company_id iss_person_id director_start_date company_name cusip_9 isin ticker gvkey cik iss_birth_year birth_date birth_date_precision start_year
order ISS_FL_name ISS_FML_name ISS_FMiL_name iss_first_name iss_middle_name iss_middle_initial iss_last_name
browse
save "iss_directors_for_merge.dta", replace

use "Director and Officer Changes - 2021-10-30 compressed", clear
// COMPANY_FKEY Edgar's Central Index Key. Unique numeric identifier for each registrant. Programmatically extracted and matched from the sec.gov's registrant header page
// subsid_name parent_co_name ult_parent_co_name --> these are largely missing
// name short_name former_name1 former_name2 former_name3 name_change_date1 name_change_date2 name_change_date3 --> These names refer to company names

keep do_off_pers_key company_fkey title_report is_c_level is_bdmem_pers is_legal is_scitech_pers is_admin_pers is_fin_pers is_op_pers is_cont is_chair is_chair_other is_secretary is_coo is_president is_ceo is_cfo is_exec_vp comm_report interim do_off_remains eff_date_unspec eff_date_next_meet action reasons eff_date_x eff_date_s first_name middle_name last_name suffix name_suffix do_change_key form_fkey file_date inc_state_country loc_state_country bus_state_country mail_state_country is_in_sp500 is_in_nasdaq_composite is_in_djia30 is_in_russell_2000 irs_number name

rename company_fkey cik_str
destring cik_str, gen(cik_n)
gen file_year = year(file_date)

*ISS last name includes suffix
replace last_name = subinstr(last_name,".","",.)
replace first_name = subinstr(first_name,".","",.)
replace middle_name = subinstr(middle_name,".","",.)
replace last_name = subinstr(last_name,",","",.)
replace first_name = subinstr(first_name,",","",.)
replace middle_name = subinstr(middle_name,",","",.)

replace last_name = ustrtrim(last_name)
replace first_name = ustrtrim(first_name)
replace middle_name = ustrtrim(middle_name)
replace name_suffix = ustrtrim(name_suffix)

gen last_name2 = last_name
replace last_name2 = last_name + " " + name_suffix if !missing(name_suffix)
gen AA_FL_name = first_name + " " + last_name2
gen AA_FML_name = AA_FL_name
replace AA_FML_name = first_name + " " + middle_name + " " + last_name2 if !missing(middle_name)
leftalign
drop last_name2

gen middle_initial = substr(middle_name,1,1)
tab middle_initial if !(regexm(lower(middle_initial), "[a-z]") | mi(middle_initial)), miss
replace middle_initial = "" if !(regexm(lower(middle_initial), "[a-z]") | mi(middle_initial))
replace middle_initial = upper(middle_initial)
tab middle_initial, missing

gen last_name2 = last_name
replace last_name2 = last_name + " " + name_suffix if !missing(name_suffix)
gen AA_FMiL_name = AA_FL_name
replace AA_FMiL_name = first_name + " " + middle_initial + " " + last_name2 if !missing(middle_initial)
leftalign
drop last_name2
replace AA_FMiL_name = subinstr(AA_FMiL_name,".","",.)
replace AA_FMiL_name = subinstr(AA_FMiL_name,",","",.)
replace AA_FMiL_name = subinstr(AA_FMiL_name,"  "," ",.)

order AA_FL_name AA_FML_name AA_FMiL_name first_name middle_name middle_initial last_name name_suffix

save "Director and Officer Changes - 2021-10-30 compressed 2", replace

use "Director and Officer Changes - 2021-10-30 compressed 2", clear
matchit do_off_pers_key AA_FML_name using "iss_directors_for_merge.dta", idu(iss_cik_director_id) txtu(ISS_FML_name) sim(token) threshold(.51) override
leftalign
format iss_cik_director_id %18.0f
rename similscore similscore_fml
save "matchit_fmlname_all.dta", replace

use "matchit_fmlname_all.dta", clear
tab similscore_fml
browse if similscore_fml == 1
browse if inrange(similscore_fml,0.9,0.999) //looks good
browse if inrange(similscore_fml,0.8,0.899) //looks good
browse if inrange(similscore_fml,0.7,0.799) //NOT good
drop if similscore_fml < 0.8

merge m:1 do_off_pers_key using "Director and Officer Changes - 2021-10-30 compressed 2"

keep if _merge == 3
drop _merge
capture drop iss_cik_director_id_str iss_cik iss_director_id
gen iss_cik_director_id_str = string(iss_cik_director_id, "%18.0f")
gen iss_person_id = real(substr(iss_cik_director_id_str, 9, 15))
gen iss_cik = real(substr(iss_cik_director_id_str, 1, 8)) - 10000000
format iss_person_id %10.0f
browse iss_cik_director_id_str iss_cik iss_person_id

count if iss_cik == cik_n

leftalign
order iss_cik cik_n iss_person_id action reasons file_year
tab file_year action if iss_cik == cik_n

browse if iss_cik == cik_n
drop if iss_cik != cik_n
gen cik = iss_cik

merge m:1 cik iss_person_id using "iss_directors_for_merge.dta"
gen director_start_year = year(director_start_date)
tab director_start_year _merge
*We need to retain all director_start_year to capture all departures. I can delete < 2013 when focused on appointments

preserve
keep if _merge == 2
keep cik iss_cik ISS_FL_name iss_first_name iss_middle_name iss_middle_initial iss_last_name iss_company_id director_start_date company_name cusip_9 isin ticker gvkey birth_date birth_date_precision iss_birth_year start_year iss_person_id ISS_FML_name ISS_FMiL_name iss_cik_director_id director_start_year
save "iss_directors_list_startyearGE2013_not_matched_using_FML", replace
restore

keep if _merge == 3
drop _merge
*saving each batch frst, the append all the batches, and then do the clean all at once
save "match_iss_aa_directors_batch1", replace

use "Director and Officer Changes - 2021-10-30 compressed 2", clear
matchit do_off_pers_key AA_FMiL_name using "iss_directors_list_startyearGE2013_not_matched_using_FML.dta", idu(iss_cik_director_id) txtu(ISS_FMiL_name) sim(token) threshold(.51) override
leftalign
format iss_cik_director_id %18.0f
rename similscore similscore_fmil
save "matchit_fmilname_all.dta", replace

use "matchit_fmilname_all.dta", clear
tab similscore_fmil
browse if similscore_fmil == 1
browse if inrange(similscore_fmil,0.9,0.999) //looks good
browse if inrange(similscore_fmil,0.85,0.899) //looks good
browse if inrange(similscore_fmil,0.80,0.85) //likely good if we can match on cik also

browse if inrange(similscore_fmil,0.7,0.799) //NOT good
drop if similscore_fmil < 0.8

merge m:1 do_off_pers_key using "Director and Officer Changes - 2021-10-30 compressed 2"

keep if _merge == 3
drop _merge
capture drop iss_cik_director_id_str iss_cik iss_director_id
gen iss_cik_director_id_str = string(iss_cik_director_id, "%18.0f")
gen iss_person_id = real(substr(iss_cik_director_id_str, 9, 15))
gen iss_cik = real(substr(iss_cik_director_id_str, 1, 8)) - 10000000
format iss_person_id %10.0f
browse iss_cik_director_id_str iss_cik iss_person_id

count if iss_cik == cik_n

leftalign
order iss_cik cik_n iss_person_id action reasons file_year
tab file_year action if iss_cik == cik_n

browse if iss_cik == cik_n
drop if iss_cik != cik_n
gen cik = iss_cik

merge m:1 cik iss_person_id using "iss_directors_list_startyearGE2013_not_matched_using_FML"
tab director_start_year _merge

preserve
keep if _merge == 2
keep cik iss_cik ISS_FL_name iss_first_name iss_middle_name iss_middle_initial iss_last_name iss_company_id director_start_date company_name cusip_9 isin ticker gvkey birth_date birth_date_precision iss_birth_year start_year iss_person_id ISS_FML_name ISS_FMiL_name iss_cik_director_id director_start_year
save "iss_directors_list_startyearGE2013_not_matched_using_FML_or_FMIL.dta", replace
restore

keep if _merge == 3
drop _merge
*We need to retain all director_start_year to capture all departures. I can delete < 2013 when focused on appointments
save "match_iss_aa_directors_batch2", replace

use "Director and Officer Changes - 2021-10-30 compressed 2", clear
matchit do_off_pers_key AA_FL_name using "iss_directors_list_startyearGE2013_not_matched_using_FML_or_FMIL.dta", idu(iss_cik_director_id) txtu(ISS_FL_name) sim(token) threshold(.51) override
leftalign
format iss_cik_director_id %18.0f
rename similscore similscore_fl
save "matchit_flname_all.dta", replace

use "matchit_flname_all.dta", clear
tab similscore_fl
browse if similscore_fl == 1
browse if inrange(similscore_fl,0.9,0.999) //looks good
browse if inrange(similscore_fl,0.85,0.899) // good
browse if inrange(similscore_fl,0.80,0.85) //likely good if we can match on cik also

browse if inrange(similscore_fl,0.7,0.799) //NOT good
drop if similscore_fl < 0.8

merge m:1 do_off_pers_key using "Director and Officer Changes - 2021-10-30 compressed 2"

keep if _merge == 3
drop _merge
capture drop iss_cik_director_id_str iss_cik iss_director_id
gen iss_cik_director_id_str = string(iss_cik_director_id, "%18.0f")
gen iss_person_id = real(substr(iss_cik_director_id_str, 9, 15))
gen iss_cik = real(substr(iss_cik_director_id_str, 1, 8)) - 10000000
format iss_person_id %10.0f
browse iss_cik_director_id_str iss_cik iss_person_id

count if iss_cik == cik_n

leftalign
order iss_cik cik_n iss_person_id action reasons file_year
tab file_year action if iss_cik == cik_n

browse if iss_cik == cik_n
drop if iss_cik != cik_n
gen cik = iss_cik

merge m:1 cik iss_person_id using "iss_directors_list_startyearGE2013_not_matched_using_FML_or_FMIL.dta"
tab director_start_year _merge

preserve
keep if _merge == 2
keep cik iss_cik ISS_FL_name iss_first_name iss_middle_name iss_last_name iss_company_id director_start_date company_name cusip_9 isin ticker gvkey birth_date birth_date_precision iss_birth_year start_year iss_person_id ISS_FML_name iss_cik_director_id director_start_year
save "iss_directors_list_startyearGE2013_not_matched_using_FML_or_FMIL_or_FL.dta", replace
restore

keep if _merge == 3
drop _merge
save "match_iss_aa_directors_batch3", replace

use "match_iss_aa_directors_batch3.dta", clear
append using "match_iss_aa_directors_batch2.dta"
append using "match_iss_aa_directors_batch1.dta"
tab file_year action
gen year_month = (year(file_date)*100) + month(file_date)
tab year_month
drop year_month
drop if file_year < 2014

gen eff_year_x = real(substr(eff_date_x, 1, 4))
gen year_diff_eff = eff_year_x - director_start_year
gen year_diff_filing = file_year - director_start_year
gen eff_minus_file = eff_year_x - file_year

capture drop action_short
gen action_short = "missing"
replace action_short = "to delete" if inlist(action, "Administrative Leave","Appointment Revoked/Not Accepted","Change Misreported","Engaged" "Retracted Resignation","Returned to Position") | inlist(action, "Nominated", "Re-elected", "Retracted Resignation", "Returned to Position")
replace action_short = "appointed" if inlist(action, "Appointed")
replace action_short = "departure" if inlist(action, "Deceased", "Declined Re-election", "Dismissed", "Not Re-elected", "Personal Leave", "Resigned", "Retired", "Employment Ceased")
tab action action_short, miss
drop if action_short == "to delete"

tab year_diff_eff action_short

drop if year_diff_eff < 0 & action_short == "departure"

tab eff_minus_file, miss

drop if abs(eff_minus_file) > 1

corr year_diff_eff year_diff_filing // 0.9996
*focus on year_diff_eff

tab year_diff_eff action_short,
tab year_diff_eff action_short, nofreq col
*For departure, effec_year_x can be many years after director_start_year, so no need to drop positive differences. I saw an example that was 50 years after first appointment

egen officer = rcount(is_c_level is_legal is_scitech_pers is_admin_pers is_fin_pers is_op_pers is_cont is_secretary is_coo is_president is_ceo is_cfo is_exec_vp), cond(@==1)
* officer equal zero if title_report == "Director"
tab officer if title_report == "Director"

tab officer if title_report != "Director"

capture drop seq_n
sort cik_n iss_person_id file_date eff_date_x
bysort cik_n iss_person_id: gen seq_n = _n
tab seq_n

order seq_n cik_n company_name action_short action reasons file_date eff_date_x iss_person_id iss_first_name iss_middle_name iss_last_name AA_FML_name
browse

gen is_officer = cond(officer > 0, 1, 0)
tab officer is_officer
bysort cik_n iss_person_id: egen officer_n = total(is_officer)
bysort cik_n iss_person_id: egen total_n = count(seq_n)
tab total_n officer_n, miss
// filling in officer status in all years if missing in some years.
replace is_officer = 1 if officer_n > 0 & !mi(officer_n) & is_officer != 1
drop officer_n
bysort cik_n iss_person_id: egen officer_n = total(is_officer)
corr total_n officer_n if officer_n > 0 //perfect correlation, just a check

drop if is_officer == 1

sort cik_n iss_person_id seq_n
order seq_n cik_n iss_person_id last_name middle_name first_name file_date eff_date_x director_start_date year_diff_eff action reasons company_name
browse

capture drop seq_n2
sort cik_n iss_person_id action_short file_date eff_date_x
bysort cik_n iss_person_id action_short: gen seq_n2 = _n
tab seq_n2 action_short, miss

order seq_n seq_n2 total_n action_short year_diff_eff is_officer cik_n last_name middle_name first_name file_date eff_date_x action reasons
browse if total_n > 3

preserve
keep if action_short == "appointed"
capture drop last_filing_appoint
sort cik_n iss_person_id action_short file_date eff_date_x
bysort cik_n iss_person_id action_short: egen last_filing_appoint = max(file_date)
duplicates drop cik_n iss_person_id , force
keep cik_n iss_person_id last_filing_appoint
save "last_filing_appoint", replace
restore

merge m:1 cik_n iss_person_id using "last_filing_appoint"

format last_filing_appoint %td
order seq_n seq_n2 total_n action_short file_date last_filing_appoint year_diff_eff is_officer cik_n last_name middle_name first_name file_date last_filing_appoint eff_date_x action reasons
browse if action_short == "departure" & file_date < last_filing_appoint & !mi(last_filing_appoint)
drop if action_short == "departure" & file_date < last_filing_appoint & !mi(last_filing_appoint)
*(233 observations deleted)

*do_off_remains, which is supposed to indicate Director officer remains on board is zero for all remaining obs, so not helpful
*Example of AA treating a board as "resigning" when they leave a board committee: https://www.sec.gov/ix?doc=/Archives/edgar/data/19617/000001961720000339/ots8k05202020agm.htm Todd A. Combs
tab comm_report if action_short == "departure" & !mi(comm_report)
drop if action_short == "departure" & !mi(comm_report)

capture drop seq_n
sort cik_n iss_person_id file_date eff_date_x
bysort cik_n iss_person_id: gen seq_n = _n
tab seq_n, miss
capture drop total_n
bysort cik_n iss_person_id: egen total_n = count(seq_n)
tab total_n, miss
capture drop seq_n2
sort cik_n iss_person_id action_short file_date eff_date_x
bysort cik_n iss_person_id action_short: gen seq_n2 = _n
tab seq_n2 action_short, miss

order seq_n seq_n2 total_n action_short file_date last_filing_appoint year_diff_eff is_officer cik_n last_name middle_name first_name file_date last_filing_appoint eff_date_x action reasons
*checking to see if this was the last act
browse if action == "Employment Ceased" & seq_n != total_n
replace action_short = "to delete" if action == "Employment Ceased" & seq_n != total_n

drop if action_short == "to delete"

capture drop seq_n
sort cik_n iss_person_id file_date eff_date_x
bysort cik_n iss_person_id: gen seq_n = _n
tab seq_n, miss
capture drop total_n
bysort cik_n iss_person_id: egen total_n = count(seq_n)
tab total_n, miss
capture drop seq_n2
sort cik_n iss_person_id action_short file_date eff_date_x
bysort cik_n iss_person_id action_short: gen seq_n2 = _n
tab seq_n2 action_short, miss

order seq_n seq_n2 total_n action_short file_date last_filing_appoint year_diff_eff is_officer cik_n do_change_key iss_person_id last_name middle_name first_name file_date last_filing_appoint eff_date_x action reasons
browse if total_n > 4

replace reasons = "No Reason" if mi(reasons)
tab reasons action_short, miss
tab file_year action_short

order seq_n seq_n2 total_n action_short file_date eff_date_x year_diff_eff action reasons last_filing_appoint is_officer cik_n do_change_key last_name middle_name first_name
browse if total_n > 4

browse if seq_n2 == 1 & seq_n == total_n

tab title_report if seq_n2 == 1 & seq_n == total_n

split title_report, parse ("|" ";" "/" )
leftalign
tab title_report1, sort
*any titles in title_report1 with () usually refers to a subsidiary or target/bidder board appointment/depture except "Director(Registrant" "Director (Registrant" "Director(Combined Company)" "Director(New Parent)" Director(Surviving Corporation) Director (Combined Company)
tab action action_short

tab action action_short if inlist(lower(title_report1), "director", "director ", "diector", "dirctor", "directior", "board of directors", "")
browse title_report1 if !inlist(lower(title_report1), "director", "director ", "diector", "dirctor", "directior", "board of directors", "")

tab action action_short if (regexm(lower(title_report1), "registrant") |regexm(lower(title_report1), "combined company") | regexm(lower(title_report1), "new parent") | regexm(lower(title_report1), "surviving corporation") | regexm(lower(title_report1), "combined company") ) & regexm(lower(title_report1), "^director")

gen tokeep = 0
replace tokeep = 1 if inlist(lower(title_report1), "director", "director ", "diector", "dirctor", "directior", "board of directors", "")
replace tokeep = 1 if (regexm(lower(title_report1), "registrant") |regexm(lower(title_report1), "combined company") | regexm(lower(title_report1), "new parent") | regexm(lower(title_report1), "surviving corporation") | regexm(lower(title_report1), "combined company") ) & regexm(lower(title_report1), "^director")

drop if tokeep == 0

capture drop seq_n
sort cik_n iss_person_id file_date eff_date_x
bysort cik_n iss_person_id: gen seq_n = _n
tab seq_n, miss
capture drop total_n
bysort cik_n iss_person_id: egen total_n = count(seq_n)
tab total_n, miss
capture drop seq_n2
sort cik_n iss_person_id action_short file_date eff_date_x
bysort cik_n iss_person_id action_short: gen seq_n2 = _n
tab seq_n2 action_short, miss

order seq_n seq_n2 year_diff_eff total_n action_short file_date last_filing_appoint is_officer cik_n do_change_key iss_person_id last_name middle_name first_name file_date last_filing_appoint eff_date_x action reasons

*ISS does not carefully identify directors who come back and rejoin the board, so it is best to rely on AA effective year
keep if seq_n2 == 1 //keeping the first appointment and first record of departure
tab file_year action_short

count if mi(year_diff_eff)
*if director_start_date is missing (38 obs), I assume the AA effect_date_x is the start date, still decided to drop out of caution
drop if mi(year_diff_eff)
tab year_diff_eff if action_short == "appointed" & abs(year_diff_eff) <=1 , miss
drop if action_short == "appointed" & abs(year_diff_eff) >1
tab year_diff_eff action_short, miss
tab file_year action_short, miss

capture drop total_n_dup_id
sort cik_n iss_person_id action_short file_date
bysort cik_n iss_person_id action_short: gen total_n_dup_id = _n
tab total_n_dup_id
drop total_n_dup_id
*no duplicates, one appointment and/or one departure.

tab year_diff_eff action_short

global appointed_drop inlist(reasons, "Assuming additional Position(s)", "Committee Assignment", "Other", "Personal / Health Reasons", "Personal Reasons", "Position Change within Company", "Returning to Prior Position" )
*categories to drop -- testing
tab reasons action_short if action_short == "appointed" & $appointed_drop
drop if action_short == "appointed" & $appointed_drop
*sample review suggests that AA reasons code for these are not clear

tab file_year action_short

drop seq_n seq_n2 total_n last_filing_appoint officer officer_n _merge title_report1 title_report2 title_report3 title_report4 title_report5 title_report6 year_diff_filing eff_minus_file tokeep

drop AA_FMiL_name middle_initial iss_middle_initial ISS_FMiL_name
save "matched_iss_aa_director_changes_2014onwards", replace

clear
local year 2014
import delimited "YOUR_PATH\data\raw\Form8K\Form 8-K 2014.csv", encoding(UTF-8) clear
	save "temp_`year'", replace
	forvalues year = 2015(1)2021 {
	import delimited "YOUR_PATH\data\raw\Form8K\Form 8-K `year'.csv", encoding(UTF-8) clear
	save "temp_`year'", replace
}
clear
forvalues year = 2014(1)2021 {
	append using "temp_`year'", force
}
keep accession formtype items cik conformedname filingdate period
keep if regexm(items, "5.02")
leftalign
rename filingdate file_date
rename cik cik_n
save "form8k_502_2014_2021.dta", replace
forvalues year = 2014(1)2021 {
	erase "temp_`year'.dta"
}

use "form8k_502_2014_2021.dta", clear
gen year_month = year(file_date)*100 + month(file_date)
tab year_month
drop year_month
capture drop dups
duplicates tag cik_n file_date period, gen(dups)
tab dups
browse if dups == 3
drop dups
duplicates drop cik_n file_date period, force

capture drop file_date2
tostring file_date, replace format(%20.0f)
gen file_date2 = date(file_date, "YMD")
format file_date2 %td
drop file_date
rename file_date2 file_date

capture drop period2
tostring period, replace format(%20.0f)
gen period2 = date(period, "YMD")
format period2 %td
drop period
rename period2 period

gen event_delay = file_date - period
tab event_delay

sort cik_n file_date event_delay
bysort cik_n file_date: gen repeats = _n
capture drop dups
duplicates tag cik_n file_date, gen(dups)
tab dups
browse if dups == 2
drop dups
keep if repeats == 1
drop repeats
save "form8k_502_2014_2021.dta", replace

use "matched_iss_aa_director_changes_2014onwards", clear
drop _merge
merge m:1 cik_n file_date using "form8k_502_2014_2021.dta"
drop if _merge == 2
count if mi(event_delay)
gen match8k = 1
replace match8k = 0 if _merge==1
drop _merge
tab event_delay action_short, miss
rename period event_date_8k
rename conformedname company_name_8k
tab file_year action_short
save "matched_iss_aa_director_changes_2014onwards", replace

*********************************************************************************************************************************
*************************END OF This PROGRAM *****************************************************************************************
*********************************************************************************************************************************

cfvars "matched_iss_aa_director_changes_2014onwards" "YOUR_PATH\data\raw\Audit_Analytics\audit_plus_compliance\original codes and data 20210917\matched_iss_aa_director_changes_2014onwards.dta"
// in both
// action_short file_date cik_n iss_person_id eff_date_x action reasons director_start_date iss_first_name iss_middle_name
// iss_last_name AA_FML_name iss_cik file_year do_off_pers_key AA_FL_name name_suffix name iss_cik_director_id_str cik birth_date
// birth_date_precision iss_birth_year start_year director_start_year eff_year_x accession formtype items event_date_8k event_delay
// match8k

use "matched_iss_aa_director_changes_2014onwards", clear
merge 1:1 cik_n file_date iss_person_id action_short using "YOUR_PATH\data\raw\Audit_Analytics\audit_plus_compliance\original codes and data 20210917\matched_iss_aa_director_changes_2014onwards.dta"
keep action_short file_date cik_n iss_person_id eff_date_x action reasons director_start_date iss_first_name iss_middle_name iss_last_name AA_FML_name iss_cik file_year do_off_pers_key AA_FL_name name_suffix name iss_cik_director_id_str cik birth_date birth_date_precision iss_birth_year start_year director_start_year eff_year_x accession formtype items event_date_8k event_delay match8k _merge

gen sample_source = "new only" if _merge == 1
replace sample_source = "old only" if _merge == 2
replace sample_source = "old & new" if _merge == 3

capture drop year_diff_eff
gen year_diff_eff = eff_year_x - director_start_year
tab year_diff_eff action_short

sort cik_n iss_person_id action_short file_date eff_date_x

duplicates tag cik_n iss_person_id action_short, gen(dups)
tab dups
browse if dups > 0
bysort cik_n iss_person_id action_short: gen dup_n = _n
tab dup_n
order dups dup_n
browse if dups > 0
// https://www.sec.gov/Archives/edgar/data/824142/000082414219000090/aaon8-kjackshort.htm --> Announcement that Jack E. Short he has decided to complete his current term and retire
// https://www.sec.gov/ix?doc=/Archives/edgar/data/824142/000082414220000110/aaon-20200515.htm --> actual retirement

drop if dup_n == 2

tab file_year action_short

drop dups dup_n
order sample_source cik_n name AA_FML_name iss_person_id action_short file_date event_date_8k eff_date_x year_diff_eff director_start_year
sort iss_person_id cik
drop _merge
save "matched_iss_aa_director_changes_2014onwards_combined", replace

use "${folder_save_databases}\iss\iss_directors_list_2021-10-01.dta", clear
*iss_company_id iss_person_id director_start_date company_name cusip_9 isin ticker gvkey cik first_name last_name middle_name birth_date birth_date_precision
*trying to add iss_company_id
duplicates tag iss_person_id cik, gen(dups)
tab dups
sort iss_person_id cik
browse if dups==1
drop if dups==1 & mi(gvkey)
drop dups
duplicates tag iss_person_id cik, gen(dups)
tab dups
sort iss_person_id cik
browse if dups==1
gsort iss_person_id cik -gvkey
duplicates drop iss_person_id cik, force

keep iss_company_id iss_person_id cik
sort iss_person_id cik
merge 1:m iss_person_id cik using "matched_iss_aa_director_changes_2014onwards_combined"
keep if _merge == 3
drop _merge
sort cik_n name AA_FML_name iss_person_id action_short file_date
order sample_source cik_n iss_company_id name AA_FML_name iss_person_id action_short file_date event_date_8k eff_date_x year_diff_eff director_start_year
save "matched_iss_aa_director_changes_2014onwards_combined", replace

use "matched_iss_aa_director_changes_2014onwards_combined", clear
assert cik_n == cik
assert cik_n == iss_cik
assert cik == iss_cik
*all three cik variables are identical
tab sample_source

tab event_delay

tab action if reasons == "Position Change within Company"

capture drop multiple_acts
duplicates tag cik_n file_date, gen(multiple_acts)
tab multiple_acts

// On file_date June 24, 2020 PG&E had 19 board appointments and departures (This must be after the CA wildefire disaster)
// On file_date 12/15/2016 KEY ENERGY SERVICES INC had 18 board appointments and departures
// On fil_date 04/23/2020 Madison Square Garden Entertainment Corp. announced the election of 16 directors (looks like the first election, but I am sure their nomination must have been known). It is a "new" company that filed its registration Form 10-12B 3/6/2020

global nacts 10
capture drop multiple_acts_gt$nacts
gen multiple_acts_gt$nacts = cond(multiple_acts > $nacts & !mi(multiple_acts), 1, 0, .)

tab reasons multiple_acts_gt$nacts

tab multiple_acts if reasons == "No Reason"

gen start_date_diff = director_start_date - event_date_8k
sum start_date_diff if action_short=="appointed", d
bysort file_year: sum start_date_diff if action_short=="appointed"

clear

**# Calculate the board's network size for each firm-year based on the ISS Directors Diversity database.
use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear // I start with all firm-year-directors (non-directors were dropped previously).

preserve
	keep iss_company_id calendar_year_end
	duplicates drop // Keeps only unique firm-years.
	quietly count // Stores the number of observations in `r(N)'.
	local unique_firm_years = r(N)
restore

	keep calendar_year_end iss_person_id iss_company_id // Only the variables necessary to calculate the board's network size are retained.
	assert !missing(calendar_year_end, iss_person_id, iss_company_id)
	duplicates report calendar_year_end iss_person_id iss_company_id
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-calendar_year_end-director.
	sort calendar_year_end iss_person_id iss_company_id
	order calendar_year_end iss_person_id iss_company_id
	save "DB Board Network Size ISSDD - Temp 1", replace

		* These commands do not affect the "DB Board Network Size ISSDD - Temp 1" database.
		bysort calendar_year_end iss_person_id (iss_company_id): gen paired_order = _n
		rename iss_company_id iss_company_id_paired // Each firm is paired to the focal firm in the given year-director.
		save "DB Board Network Size ISSDD - Temp 2", replace
		clear

	use "DB Board Network Size ISSDD - Temp 1", clear
	erase "DB Board Network Size ISSDD - Temp 1.dta"
	bysort calendar_year_end iss_person_id (iss_company_id): gen year_director_freq = _N
	expand year_director_freq // The "expand" command allows us to create a matrix that is (N)x(N) within each year-director pair, as opposed to (N)x(N) for the full sample, which is intractable.
	drop year_director_freq
	bysort calendar_year_end iss_person_id iss_company_id: gen paired_order = _n

	merge m:1 calendar_year_end iss_person_id paired_order using "DB Board Network Size ISSDD - Temp 2"
	erase "DB Board Network Size ISSDD - Temp 2.dta"
	assert _merge==3 // All observations in the master and using databases are matched.
	drop _merge
	drop paired_order

	assert !missing(calendar_year_end, iss_person_id, iss_company_id, iss_company_id_paired)
	duplicates report calendar_year_end iss_person_id iss_company_id iss_company_id_paired
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is calendar_year_end-director-firm_i-firm_j. Only directors create links between firms. Noticed that at least one firm-year-director remains on the database because the observation is paired to itself. This is important, as firm-years that have no links should be coded as zero, and not missing.
	sort calendar_year_end iss_person_id iss_company_id iss_company_id_paired

	drop iss_person_id
	sort calendar_year_end iss_company_id iss_company_id_paired
	duplicates drop // Removes multiple links to the same firm in the same year (caused by different directors creating multiple links).
	assert !missing(iss_company_id, iss_company_id_paired, calendar_year_end)
	gen network_size = cond(iss_company_id!=iss_company_id_paired, 1, 0) // Firms-years matched to themselves are not counted as a link.
	collapse (sum) network_size, by(calendar_year_end iss_company_id)
	gen ln_network_size = ln(1 + network_size)

	quietly log on
		* Descriptive statistics of the network size variables in the ISS Directors Diversity database.
		summarize network_size, det
		summarize ln_network_size, det
	quietly log off

	* Lag all the variables:
		rename calendar_year_end calendar_year_end_lag
		gen calendar_year_end = mdy(month(calendar_year_end_lag), day(calendar_year_end_lag), year(calendar_year_end_lag) + 1)
		format %td calendar_year_end
		drop calendar_year_end_lag

		foreach variab in network_size ln_network_size {
			rename `variab' `variab'_lag
		}

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year is a unique identifier.
	sort iss_company_id calendar_year_end
	order iss_company_id calendar_year_end network_size_lag ln_network_size_lag

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

save "${folder_save_databases}/iss/DB Board Network Size ISSDD", replace
clear

**# Import the Zip Codes database.
import_delimited using "${folder_original_databases}/Zip_Codes/zip-codes-database-DELUXE - 2021-11-01.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear
// import_delimited using "${folder_original_databases}/Zip_Codes/zip-codes-database-DELUXE - 2021-04-15.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear
format %05.0f zipcode
keep if primaryrecord=="P" // According to the manual: "This column indicates the 'primary' city name within a given ZIP Code. This is designated by the U.S. Postal Service and is based on mail delivery totals. If you want to get only the 'unique' U.S. zip codes, sort the data by this field. Your results will be all (approx.) 41,000 unique zip codes and all will be designated with a 'p'."
keep zipcode latitude longitude city county state statefullname
assert !missing(latitude, longitude) // Latitude and longitude values are non missing.
assert abs(latitude)<=90 // Latitude must be between -90 and 90 degrees.
assert abs(longitude)<=180 // Longitude must be between -180 and 180 degrees.

foreach variab in latitude longitude city county state statefullname {
	rename `variab' zip_`variab'
}

assert !missing(zipcode)
duplicates report zipcode
assert `r(unique_value)'==`r(N)' // Verifies that "zipcode" is a unique identifier.
sort zipcode
order zipcode zip_latitude zip_longitude zip_city zip_county zip_state zip_statefullname

save "${folder_save_databases}/Zip_Codes/DB ZC Origin Zip Code Level", replace
clear

**# Calculate the supply of directors within a 60-mile radius using the ISS Directors Diversity database.
use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear // I start with all firm-years.

gen num_individuals_total = ///
	num_individuals_a 	+ 	///
	num_individuals_b 	+ 	///
	num_individuals_hl 	+ 	///
	num_individuals_i 	+ 	///
	num_individuals_m 	+ 	///
	num_individuals_n 	+ 	///
	num_individuals_nc 	+ 	///
	num_individuals_o 	+ 	///
	num_individuals_p 	+ 	///
	num_individuals_pnd + 	///
	num_individuals_u 	+ 	///
	num_individuals_w

rename number_women_directors num_directors_women
rename num_women_neos num_neos_women
rename num_women_individuals num_individuals_women

rename board_size num_directors_total
rename num_neos_total num_neos_total
rename num_individuals_total num_individuals_total

foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
	assert num_individuals_`group'<=(num_directors_`group' + num_neos_`group') if !missing(num_individuals_`group', num_directors_`group', num_neos_`group') // An executive that is on the board is both a director and a named executive officer (NEO).
	assert num_individuals_`group'>=num_directors_`group' if !missing(num_individuals_`group', num_directors_`group')
	assert num_individuals_`group'>=num_neos_`group' if !missing(num_individuals_`group', num_neos_`group')
}

keep calendar_year_end iss_company_id country_of_address country_of_incorporation state_of_address hq_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total // According to the ISS Directors Diversity dictionary, "hq_address" contains the address of the company's headquarters/primary operations. The same dictionary describes "num_individuals" as the distinct number of directors and named executive officers who partially or primarily identify as the ethnicity type.
order calendar_year_end iss_company_id country_of_address country_of_incorporation state_of_address hq_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
replace country_of_address = "" if country_of_address=="n/a"
replace state_of_address = "" if state_of_address=="n/a"
replace hq_address = "" if hq_address=="n/c"
assert missing(hq_address) if missing(country_of_address) // If the "country_of_address" is missing, then "hq_address" is missing.
drop if missing(country_of_address)
assert country_of_address=="USA" // Data on the headquarter's address is only collected for U.S. firms. In addition, non-U.S. headquarter addresses would result in the wrong matching with the Zip Codes database.
keep if country_of_incorporation=="USA" // I only keep U.S. firms for this analysis.
drop country_of_address country_of_incorporation

gen hq_address_edited = hq_address
replace hq_address_edited = regexs(1) + "-" + regexs(2) if regexm(hq_address,"(^.*[0-9][0-9][0-9][0-9][0-9]).([0-9][0-9][0-9][0-9])$") // Changes any character for a dash in a 9 digit zip code at the end of the string.
format %-60s hq_address hq_address_edited
gen zipcode = substr(hq_address_edited, strrpos(hq_address_edited, " ") + 1, .) // Extracts all the characters after the last space. The "+1" prevents the last space from being part of the new string.
replace zipcode = regexs(1) if regexm(zipcode, "(^[0-9][0-9][0-9][0-9][0-9])-[0-9][0-9][0-9][0-9]$") // Extracts only the first five of a nine digit zip code.
drop if regexm(zipcode,"^[0-9][0-9][0-9][0-9][0-9]$")!=1 // There is no point in keeping observations with zip codes that will not match to the Zip Codes database.
destring zipcode, replace
format %05.0f zipcode
drop hq_address hq_address_edited
order calendar_year_end iss_company_id zipcode state_of_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total

merge m:1 zipcode using "${folder_save_databases}/Zip_Codes/DB ZC Origin Zip Code Level", keep(match) // It is not helpful to keep zip codes where no company is located, or zip codes in which it is not possible to identify latitude and longitude.
drop _merge
assert state_of_address==zip_statefullname // The name of the state where the firm is headquartered matches both databases.
drop state_of_address zip_city zip_county zip_state zip_statefullname

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	assert !missing(calendar_year_end, iss_company_id)
	duplicates report calendar_year_end iss_company_id
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year forms a unique identifier.
	sort calendar_year_end iss_company_id
	order calendar_year_end iss_company_id zipcode zip_latitude zip_longitude filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
	save "DB Supply Directors ISSDD - Temp 1", replace

		* These commands do not affect the "DB Supply Directors ISSDD - Temp 1" database.
		bysort calendar_year_end (iss_company_id): gen firm_j_order = _n

		foreach variab in iss_company_id zipcode zip_latitude zip_longitude filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total {
			rename `variab' `variab'_j // "firm_j" is the paired firm.
		}

		save "DB Supply Directors ISSDD - Temp 2", replace
		clear

	use "DB Supply Directors ISSDD - Temp 1", clear
	drop filter_gics_non_financial num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
	bysort calendar_year_end (iss_company_id): gen year_freq = _N
	expand year_freq // The "expand" command allows us to create a matrix that is (N)x(N) within each year, as opposed to (N)x(N) for the full sample. Notice that I could create a (N)x(N-1) matrix, but matching firm_i to itself prevents the firm from being dropped from the database if there is not a single firm within the specified radius. This is important, as the variable "SUPPLY_DIR" should be missing if the zip code is missing/incorrect, but should be zero if there is not a single firm around the specified distance.
	drop year_freq
	bysort calendar_year_end iss_company_id: gen firm_j_order = _n
	erase "DB Supply Directors ISSDD - Temp 1.dta"

	merge m:1 calendar_year_end firm_j_order using "DB Supply Directors ISSDD - Temp 2"
	erase "DB Supply Directors ISSDD - Temp 2.dta"
	assert _merge==3
	drop _merge
	drop firm_j_order

	assert !missing(calendar_year_end, iss_company_id, iss_company_id_j)
	duplicates report calendar_year_end iss_company_id iss_company_id_j
	assert `r(unique_value)'==`r(N)' // Verifies that firm_i-year-firm_j form a unique identifier.
	sort calendar_year_end iss_company_id iss_company_id_j

	geodist zip_latitude zip_longitude zip_latitude_j zip_longitude_j, miles sphere gen(distance_miles) // The "sphere" option makes the distance match the one on Zip-Codes.com.
	geodist zip_latitude_j zip_longitude_j zip_latitude zip_longitude, miles sphere gen(distance_miles_check) // The "sphere" option makes the distance match the one on Zip-Codes.com.
	assert distance_miles==distance_miles_check // Verifies that the distance between points A and B are the same as B and A.
	format %12.2fc distance_miles
	drop distance_miles_check zipcode zip_latitude zip_longitude zipcode_j zip_latitude_j zip_longitude_j

	quietly log on
		* Distribution of distances before dropping any (includes firm_i matched to itself).
		summarize distance_miles, det
	quietly log off

	foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
		gen supply_dir_`group' = cond( 				///
			distance_miles<=60 					& 	///
			filter_gics_non_financial_j==1 		& 	/// Exclude paired firms in the financial industry.
			gics_8_code!=gics_8_code_j 			& 	/// The paired firm cannot be in the same 8-digit GICS of the focal firm.
			iss_company_id!=iss_company_id_j 	& 	/// Observations paired to themselves are ignored, but not excluded.
			!missing( 								///
				distance_miles 					, 	///
				filter_gics_non_financial_j 	, 	///
				gics_8_code 					, 	///
				gics_8_code_j 					, 	///
				iss_company_id 					, 	///
				iss_company_id_j 				, 	///
				num_individuals_`group'_j 			/// Missing values are considered zero, which is analogous to how "n/c", "pnd", and "u" are implicitly treated.
			) 										///
		, num_individuals_`group'_j, 0)
		assert !missing(supply_dir_`group')
		gen supply_dir_fin_`group' = cond( 			/// Does not exclude paired firms in the financial industry.
			distance_miles<=60 					& 	///
			gics_8_code!=gics_8_code_j 			& 	/// The paired firm cannot be in the same 8-digit GICS of the focal firm.
			iss_company_id!=iss_company_id_j 	& 	/// Observations paired to themselves are ignored, but not excluded.
			!missing( 								///
				distance_miles 					, 	///
				filter_gics_non_financial_j 	, 	///
				gics_8_code 					, 	///
				gics_8_code_j 					, 	///
				iss_company_id 					, 	///
				iss_company_id_j 				, 	///
				num_individuals_`group'_j 			/// Missing values are considered zero, which is analogous to how "n/c", "pnd", and "u" are implicitly treated.
			) 										///
		, num_individuals_`group'_j, 0)
		assert !missing(supply_dir_fin_`group')
	}

	drop gics_8_code filter_gics_non_financial_j gics_8_code_j distance_miles num_individuals_a_j num_individuals_b_j num_individuals_hl_j num_individuals_i_j num_individuals_m_j num_individuals_n_j num_individuals_p_j num_individuals_w_j num_individuals_o_j num_individuals_ai_j num_individuals_women_j num_individuals_total_j

	collapse (sum) supply_dir_a supply_dir_b supply_dir_hl supply_dir_i supply_dir_m supply_dir_n supply_dir_p supply_dir_w supply_dir_o supply_dir_ai supply_dir_women supply_dir_total supply_dir_fin_a supply_dir_fin_b supply_dir_fin_hl supply_dir_fin_i supply_dir_fin_m supply_dir_fin_n supply_dir_fin_p supply_dir_fin_w supply_dir_fin_o supply_dir_fin_ai supply_dir_fin_women supply_dir_fin_total, by(calendar_year_end iss_company_id)

	foreach variab in dir dir_fin {
		foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
			gen ln_supply_`variab'_`group' = ln(1 + supply_`variab'_`group')
			assert !missing(ln_supply_`variab'_`group')
		}
	}

	quietly log on
		* Descriptive statistics of the number of potential directors of a given ethnicity.
		foreach transf in supply ln_supply {
			foreach variab in dir dir_fin {
				tabstat 					///
					`transf'_`variab'_a 	///
					`transf'_`variab'_b 	///
					`transf'_`variab'_hl 	///
					`transf'_`variab'_i 	///
					`transf'_`variab'_m 	///
					`transf'_`variab'_n 	///
					`transf'_`variab'_p 	///
					`transf'_`variab'_w 	///
					`transf'_`variab'_o 	///
					`transf'_`variab'_ai 	///
					`transf'_`variab'_women ///
					`transf'_`variab'_total ///
				, statistics(mean sd min p25 p50 p75 max count) columns(statistics)
			}
		}
	quietly log off

	* Lag all the variables:
		rename calendar_year_end calendar_year_end_lag
		gen calendar_year_end = mdy(month(calendar_year_end_lag), day(calendar_year_end_lag), year(calendar_year_end_lag) + 1)
		format %td calendar_year_end
		drop calendar_year_end_lag

		foreach transf in supply ln_supply {
			foreach variab in dir dir_fin {
				foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
					rename `transf'_`variab'_`group' `transf'_`variab'_`group'_lag
				}
			}
		}

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year form a unique identifier.
	sort iss_company_id calendar_year_end
	order iss_company_id calendar_year_end supply_dir_a_lag supply_dir_b_lag supply_dir_hl_lag supply_dir_i_lag supply_dir_m_lag supply_dir_n_lag supply_dir_p_lag supply_dir_w_lag supply_dir_o_lag supply_dir_ai_lag supply_dir_women_lag supply_dir_total_lag supply_dir_fin_a_lag supply_dir_fin_b_lag supply_dir_fin_hl_lag supply_dir_fin_i_lag supply_dir_fin_m_lag supply_dir_fin_n_lag supply_dir_fin_p_lag supply_dir_fin_w_lag supply_dir_fin_o_lag supply_dir_fin_ai_lag supply_dir_fin_women_lag supply_dir_fin_total_lag ln_supply_dir_a_lag ln_supply_dir_b_lag ln_supply_dir_hl_lag ln_supply_dir_i_lag ln_supply_dir_m_lag ln_supply_dir_n_lag ln_supply_dir_p_lag ln_supply_dir_w_lag ln_supply_dir_o_lag ln_supply_dir_ai_lag ln_supply_dir_women_lag ln_supply_dir_total_lag ln_supply_dir_fin_a_lag ln_supply_dir_fin_b_lag ln_supply_dir_fin_hl_lag ln_supply_dir_fin_i_lag ln_supply_dir_fin_m_lag ln_supply_dir_fin_n_lag ln_supply_dir_fin_p_lag ln_supply_dir_fin_w_lag ln_supply_dir_fin_o_lag ln_supply_dir_fin_ai_lag ln_supply_dir_fin_women_lag ln_supply_dir_fin_total_lag

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the number of firm-year observations with non-missing and matched zip codes is correct.

save "${folder_save_databases}/iss/DB Supply Directors ISSDD", replace
clear

**# Import the institutional ownership data from Thomson Reuters.
use "${folder_original_databases}/Thomson_Reuters/wrds_stock_ownership/WRDS Thomson Reuters Stock Ownership - 2021-04-14", clear
gen InstOwn_Perc_check = InstOwn / (shrout * 1000)
assert float(InstOwn_Perc)==float(InstOwn_Perc_check)
drop InstOwn_Perc_check

assert missing(InstOwn_Perc) if (missing(shrout) | shrout==0) // "InstOwn_Perc" is missing only when either "shrout" is missing or zero.
gen shrout_zero_miss = cond((missing(shrout) | shrout==0), 1, 0)

keep rdate cusip InstOwn_HHI InstOwn_Perc shrout_zero_miss
assert 0<=InstOwn_HHI & InstOwn_HHI<=1 if !missing(InstOwn_HHI)
assert 0<=InstOwn_Perc if !missing(InstOwn_Perc) // According to the manual there are three reasons for institutional ownership being greater than 100%: 1) short positions are not reported, 2) shared investment discretion by multiple asset managers, and 3) issues with stock splits.

assert !missing(rdate)
gen day_month_string = substr(string(rdate, "%td"), 1, 5)
label define order_day_month 	///
	1 "31mar" 					///
	2 "30jun" 					///
	3 "30sep" 					///
	4 "31dec"
encode day_month_string, gen(day_month) label(order_day_month)

quietly log on
	* Report the distribution of the day-months of the file date.
	tab day_month, miss
quietly log off

drop day_month day_month_string

assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
rename cusip cusip_8

assert !missing(cusip_8, rdate)
duplicates report cusip_8 rdate
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
sort cusip_8 rdate
order cusip_8 rdate InstOwn_Perc InstOwn_HHI

save "${folder_save_databases}/Institutional_Ownership/DB TR Institutional Ownership", replace
clear

**# Calculate the institutional ownership of the Big Three from Thomson Reuters.
use "${folder_original_databases}/Thomson_Reuters/s34 Master File/Institutional Holdings - s34 Master File - 2021-11-01", clear
drop if missing(cusip) // "cusip" is the variable I use as the security identifier.

assert !missing(cusip, mgrno, rdate, fdate)
duplicates report cusip mgrno rdate fdate
assert `r(unique_value)'==`r(N)' // Verifies that "cusip", "mgrno", "rdate", and "fdate" form a unique identifier. According to the manuals available from WRDS, "rdate" represents the effective ownership date, whereas the "fdate" represents the vintage date at which the shares outstanding are valid. Because Thomson Reuters' 13F data carries forward institutional reports for up to 8 quarters, a given tuple "cusip"-"mgrno"-"rdate" can have multiple "fdate".
sort cusip mgrno rdate fdate

bysort cusip mgrno rdate (fdate): egen min_fdate = min(fdate)
format %td min_fdate
keep if fdate==min_fdate // I follow Ben-David et al. (2021) and keep the first "fdate" (the first vintage) for a given tuple "cusip"-"mgrno"-"rdate". Keeping the first instead of the last "fdate" also results in institutional ownership much closer to the aggregate institutional ownership data available on WRDS.
drop min_fdate

assert !missing(cusip, mgrno, rdate)
duplicates report cusip mgrno rdate
assert `r(unique_value)'==`r(N)'
sort cusip mgrno rdate

gen year_rdate = year(rdate)
gen mgrname_stand = mgrname
replace mgrname_stand = upper(mgrname_stand) // Capitalizes the string variable.
replace mgrname_stand = strtrim(mgrname_stand) // Removes internal consecutive spaces.
replace mgrname_stand = stritrim(mgrname_stand) // Removes leading and trailing spaces.
assert !missing(mgrname_stand)

assert !missing(mgrno)
gen d_blackrock = ( 	/// I follow Ben-David et al. (2020).
	mgrno== 9385 | 		///
	mgrno==11386 | 		///
	mgrno==12588 | 		///
	mgrno==39539 | 		///
	mgrno==56790 | 		///
	mgrno==91430 		///
)
gen d_vanguard = (mgrno==90457)
gen d_ssga = (mgrno==81540)
gen d_big_3 = d_blackrock + d_vanguard + d_ssga
assert d_big_3==0 | d_big_3==1 // There is no overlap among the Big Three classification.

quietly log on
	* Shows the distribution of the combination of Manager Number - Year of the Report Date - Manager Name.
	foreach investor in blackrock vanguard ssga {
		groups mgrno year_rdate mgrname_stand if d_`investor'==1, sepby(mgrno)
	}
	tab d_big_3, miss
quietly log off

drop mgrname_stand year_rdate

gen double prop_shares = cond(!missing(shrout2), shares / (shrout2 * 1000), shares / (shrout1 * 1000000)) // "shrout2" and "shrout1" are not constant within each "cusip"-"rdate" pair. Therefore, the proportion of shares owned has to be calculated before aggregating the data at "cusip"-"rdate". Because "shrout2" is more precise than "shrout1", I use the former whenever its value is not missing.
assert !missing(shares) // The "prop_shares" is only missing because of the denominator (zero or missing) and never because of the numerator.

foreach investor in blackrock vanguard ssga big_3 {
	quietly gen double prop_shares_`investor' = cond(d_`investor'==1, prop_shares, .)
}

collapse (sum) inst_own=prop_shares inst_own_blackrock=prop_shares_blackrock inst_own_vanguard=prop_shares_vanguard inst_own_ssga=prop_shares_ssga inst_own_big_3=prop_shares_big_3 (max) d_blackrock d_vanguard d_ssga d_big_3 (count) non_miss_prop_shares=prop_shares non_miss_prop_shares_blackrock=prop_shares_blackrock non_miss_prop_shares_vanguard=prop_shares_vanguard non_miss_prop_shares_ssga=prop_shares_ssga non_miss_prop_shares_big_3=prop_shares_big_3, by(cusip rdate)

assert !missing(non_miss_prop_shares) & non_miss_prop_shares>=0
gen all_shrout_zero_miss = cond(non_miss_prop_shares==0, 1, 0) // Keep in mind that "prop_shares" was missing only because of the denominator (zero or missing).
assert !missing(inst_own)
assert inst_own==0 if all_shrout_zero_miss==1
replace inst_own = . if all_shrout_zero_miss==1 // I only set "inst_own" to missing if all values of "prop_shares" were missing for that particular "cusip"-"rdate". This is an analogous treatment to institutional investors that manage less than $100 million.
drop non_miss_prop_shares

foreach investor in blackrock vanguard ssga big_3 {
	assert d_`investor'==0 | d_`investor'==1
	assert !missing(non_miss_prop_shares_`investor') & non_miss_prop_shares_`investor'>=0
	quietly gen all_shrout_zero_miss_`investor' = cond(non_miss_prop_shares_`investor'==0, 1, 0)
	assert !missing(inst_own_`investor')
	assert inst_own_`investor'==0 if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // It is zero, but should be missing.
	quietly replace inst_own_`investor' = . if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // There was at least one 13F form from the investor, but the proportion of shares owned by it were all missing.
	assert inst_own_`investor'==0 if d_`investor'==0 & all_shrout_zero_miss==1 // It is zero, but should be missing.
	quietly replace inst_own_`investor' = . if d_`investor'==0 & all_shrout_zero_miss==1 // There was no 13F form from the investor and the proportion of shares owned by all shareholders were missing.
	drop non_miss_prop_shares_`investor' d_`investor'
}

drop all_shrout_zero_miss all_shrout_zero_miss_blackrock all_shrout_zero_miss_vanguard all_shrout_zero_miss_ssga all_shrout_zero_miss_big_3

foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
	gen miss_inst_`variab' = cond(missing(inst_`variab'), 1, 0) // If the underlying variable is missing in this database, its value should not be replaced with zero after merging.
}

assert !missing(rdate)
gen day_month_string = substr(string(rdate, "%td"), 1, 5)
label define order_day_month 	///
	1 "31mar" 					///
	2 "30jun" 					///
	3 "30sep" 					///
	4 "31dec"
encode day_month_string, gen(day_month) label(order_day_month)

quietly log on
	* Report the distribution of the day-months of the file date.
	tab day_month, miss
quietly log off

drop day_month day_month_string

assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
rename cusip cusip_8

assert !missing(cusip_8, rdate)
duplicates report cusip_8 rdate
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
sort cusip_8 rdate
order cusip_8 rdate inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3

save "${folder_save_databases}/Institutional_Ownership/DB TR Big Three Ownership", replace
clear

**# Import variables from Compustat.
use "${folder_original_databases}/Compustat/Compustat - 2021-11-01" if 	///
	consol 	== 	"C" 	& 												/// Imposes consolidated financial statements.
	datafmt == 	"STD" 	& 												/// Imposes standardized data format.
	indfmt 	== 	"INDL" 	& 												/// Imposes industrial firms.
	curcd 	== 	"USD" 													/// Imposes currency to be US Dollars.
, clear

assert popsrc=="D" // Imposes domestic firms (USA, Canada & ADRs).

destring sic, replace // "sic" is numeric in the Fama-French 48 Industry Classification database.
destring naics, replace // "naics" is numeric in the Bureau of Labor Statistics database.
destring gvkey, replace // "gvkey" is numeric in ISSDD.

duplicates tag gvkey fyear, gen(dup)
drop if dup>0 // There is only one firm for which the "gvkey"-"fyear" pair is not unique.
drop dup

assert !missing(datadate, fyear)
gen fyear_test = cond(month(datadate)>=6, year(datadate), year(datadate) - 1)
assert fyear_test==fyear // This commands checks the variable "fyear" based on datadate.
drop fyear_test

assert !missing(gvkey, fyear)
duplicates report gvkey fyear
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
sort gvkey fyear

xtset gvkey fyear
	gen firm_visibility = ln(at)
	gen book_to_market = ceq / (csho * prcc_f)
	gen roa = ib / ((at + L.at) / 2)
	gen loss = cond(ib<0, 1, 0) if !missing(ib)
	gen rd_over_assets = xrd / ((at + L.at) / 2)
	gen rd_over_assets_0 = cond(!missing(xrd), xrd, 0) / ((at + L.at) / 2)
	gen rd_miss = cond(missing(xrd), 1, 0)
		assert rd_over_assets==rd_over_assets_0 if rd_miss==0
	bysort gvkey (fyear): egen min_fyear = min(fyear)
	gen firm_age_min_fyear = fyear - min_fyear
	gen ln_firm_age_min_fyear = ln(1 + firm_age_min_fyear)
	drop min_fyear
		assert !missing(firm_age_min_fyear)
		assert firm_age_min_fyear>=0
	gen firm_age_ipo_years = fyear - year(ipodate)
	gen ln_firm_age_ipo_years = ln(1 + firm_age_ipo_years) // Zero or negative years will translate into a missing value for the variable.
	gen firm_age_ipo_days = datadate - ipodate
	gen ln_firm_age_ipo_days = ln(1 + firm_age_ipo_days) // Zero or negative days will translate into a missing value for the variable.
xtset, clear

gen dif_age_years = firm_age_min_fyear - firm_age_ipo_years
	quietly log on
		* Reports the distribution of the difference between age calculated based on the minimum "fyear" and the year of the IPO.
		summarize dif_age_years, detail
		correlate firm_age_min_fyear firm_age_ipo_years
	quietly log off
drop dif_age_years

label variable at "Total Assets, measured in Millions of USD"

keep gvkey datadate at firm_visibility csho prcc_f book_to_market roa loss rd_over_assets rd_over_assets_0 rd_miss firm_age_min_fyear ln_firm_age_min_fyear firm_age_ipo_years ln_firm_age_ipo_years firm_age_ipo_days ln_firm_age_ipo_days sic naics naicsh

assert !missing(gvkey, datadate)
duplicates report gvkey datadate
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
sort gvkey datadate
order gvkey datadate at firm_visibility csho prcc_f book_to_market roa loss rd_over_assets rd_over_assets_0 rd_miss firm_age_min_fyear ln_firm_age_min_fyear firm_age_ipo_years ln_firm_age_ipo_years firm_age_ipo_days ln_firm_age_ipo_days sic naics naicsh

save "${folder_save_databases}/Compustat/DB Compustat", replace
clear

**# Calculate variables related to directors' age and founder status aggregated at the firm-year level from the ISS Directors database.
use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear // I start with all firm-year-directors (non-directors were dropped previously).
assert !missing(iss_company_id, calendar_year_end, iss_person_id)
duplicates report iss_company_id calendar_year_end iss_person_id
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-calendar_year_end-director.
sort iss_company_id calendar_year_end iss_person_id

assert !missing(founder_type)
gen founder = cond( 										///
	founder_type=="founder" 							| 	///
	founder_type=="founder family" 						| 	///
	founder_type=="founder investor" 					| 	///
	founder_type=="founder not employed by the company" | 	///
	founder_type=="founder relative" 					| 	///
	founder_type=="founder scientific" 					| 	///
, 1, 0)

bysort iss_company_id calendar_year_end (iss_person_id): egen median_director_age_check = median(age)
assert median_director_age==median_director_age_check // Because "age" is not correctly measured, then "median_director_age" is also incorrect.
drop median_director_age_check median_director_age stdev_director_age
drop age // The variable "age" is not correctly measured. For example, see first_name=="Timothy" & last_name=="Cook" & company_name=="Apple Inc.". The director's age is identical, independently of the "calendar_year_end". The same is true for first_name=="Elon" & last_name=="Musk". Another example is iss_company_id==513234 & calendar_year_end==td(31, Dec, 2015). While Robert Finocchio, Maria Klawe, and Nancy Handel all were born in 1952 according to "birth_date", their age is reported as 69, 63, and 63, respectively. The proxy statement filed on 2015-03-27 shows that all three were 63 years old on March 16, 2015.

assert !missing(calendar_year_end)
gen age_calendar_year_end = cond(calendar_year_end>=birthday(birth_date, year(calendar_year_end)), year(calendar_year_end) - year(birth_date), year(calendar_year_end) - year(birth_date) - 1) if !missing(birth_date) // The formula calculates "age_calendar_year_end" for any date, in case we use a different time stamp than December 31 later.
assert !missing(age_calendar_year_end) if !missing(birth_date)

gen dir_age_67_72 = cond(67<=age_calendar_year_end & age_calendar_year_end<=72, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_67_75 = cond(67<=age_calendar_year_end & age_calendar_year_end<=75, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_70_75 = cond(70<=age_calendar_year_end & age_calendar_year_end<=75, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_67_plus = cond(67<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_70_plus = cond(70<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_72_plus = cond(72<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_75_plus = cond(75<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)
gen dir_age_76_plus = cond(76<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)

collapse (mean) dir_age_mean=age_calendar_year_end (median) dir_age_median=age_calendar_year_end (min) dir_age_min=age_calendar_year_end (max) dir_age_max=age_calendar_year_end (sum) num_dir_age_67_72=dir_age_67_72 num_dir_age_67_75=dir_age_67_75 num_dir_age_70_75=dir_age_70_75 num_dir_age_67_plus=dir_age_67_plus num_dir_age_70_plus=dir_age_70_plus num_dir_age_72_plus=dir_age_72_plus num_dir_age_75_plus=dir_age_75_plus num_dir_age_76_plus=dir_age_76_plus num_dir_founder=founder (count) dir_age_non_miss=age_calendar_year_end board_size=iss_person_id, by(iss_company_id calendar_year_end) // Changes the structure of the database from firm-year-director to firm-year. In the "collapse" command, "(count)" reports the number of non-missing observations within each "firm-year". "iss_person_id" is never missing and, therefore, "board_size" is the total number of observations within each "firm-year".

assert !missing(dir_age_non_miss, board_size) & dir_age_non_miss<=board_size
gen prop_dir_age_non_miss = dir_age_non_miss / board_size
assert !missing(prop_dir_age_non_miss)

foreach variab in dir_age_mean dir_age_median dir_age_min dir_age_max num_dir_age_67_72 num_dir_age_67_75 num_dir_age_70_75 num_dir_age_67_plus num_dir_age_70_plus num_dir_age_72_plus num_dir_age_75_plus num_dir_age_76_plus {
	quietly replace `variab' = . if prop_dir_age_non_miss < 0.7 // I impose that the age of at least 70% of the directors must be identified, otherwise the variable is missing.
}

foreach variab in age_67_72 age_67_75 age_70_75 age_67_plus age_70_plus age_72_plus age_75_plus age_76_plus {
	quietly gen prop_dir_`variab'_o_ident = num_dir_`variab' / dir_age_non_miss
	assert !missing(prop_dir_`variab'_o_ident) if !missing(num_dir_`variab')
	drop num_dir_`variab'
}

gen prop_dir_founder = num_dir_founder / board_size // There was no missing value for "founder_type".
assert !missing(prop_dir_founder)
drop num_dir_founder

drop dir_age_non_miss prop_dir_age_non_miss board_size

gen d_dir_age_max_67_72 = cond(67<=dir_age_max & dir_age_max<=72, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_67_75 = cond(67<=dir_age_max & dir_age_max<=75, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_70_75 = cond(70<=dir_age_max & dir_age_max<=75, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_67_plus = cond(67<=dir_age_max, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_70_plus = cond(70<=dir_age_max, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_72_plus = cond(72<=dir_age_max, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_75_plus = cond(75<=dir_age_max, 1, 0) if !missing(dir_age_max)
gen d_dir_age_max_76_plus = cond(76<=dir_age_max, 1, 0) if !missing(dir_age_max)

* Lag all the variables:
	rename calendar_year_end calendar_year_end_lag
	gen calendar_year_end = mdy(month(calendar_year_end_lag), day(calendar_year_end_lag), year(calendar_year_end_lag) + 1)
	format %td calendar_year_end
	drop calendar_year_end_lag

	foreach variab in dir_age_mean dir_age_median dir_age_min dir_age_max prop_dir_age_67_72_o_ident prop_dir_age_67_75_o_ident prop_dir_age_70_75_o_ident prop_dir_age_67_plus_o_ident prop_dir_age_70_plus_o_ident prop_dir_age_72_plus_o_ident prop_dir_age_75_plus_o_ident prop_dir_age_76_plus_o_ident d_dir_age_max_67_72 d_dir_age_max_67_75 d_dir_age_max_70_75 d_dir_age_max_67_plus d_dir_age_max_70_plus d_dir_age_max_72_plus d_dir_age_max_75_plus d_dir_age_max_76_plus prop_dir_founder {
		rename `variab' `variab'_lag
	}

assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that firm-year is a unique identifier.
sort iss_company_id calendar_year_end
order iss_company_id calendar_year_end dir_age_mean_lag dir_age_median_lag dir_age_min_lag dir_age_max_lag prop_dir_age_67_72_o_ident_lag prop_dir_age_67_75_o_ident_lag prop_dir_age_70_75_o_ident_lag prop_dir_age_67_plus_o_ident_lag prop_dir_age_70_plus_o_ident_lag prop_dir_age_72_plus_o_ident_lag prop_dir_age_75_plus_o_ident_lag prop_dir_age_76_plus_o_ident_lag d_dir_age_max_67_72_lag d_dir_age_max_67_75_lag d_dir_age_max_70_75_lag d_dir_age_max_67_plus_lag d_dir_age_max_70_plus_lag d_dir_age_max_72_plus_lag d_dir_age_max_75_plus_lag d_dir_age_max_76_plus_lag prop_dir_founder_lag

save "${folder_save_databases}/iss/DB ISSDD Directors' Age", replace
clear

**# Add variables for the analysis of the determinants of racial diversity - CRSP merger.
use "${folder_original_databases}/CRSP/CRSPQ Daily - 2021-11-02", clear
	keep date
	duplicates drop
	sort date
	bcal create "crsptrdays", from(date) maxgap(11) purpose("CRSP Trading Days") replace // Creates a trading days calendar with unique dates from CRSP.
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear
assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique pair.
sort iss_company_id calendar_year_end

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	gen calendar_year_end_lag = mdy(month(calendar_year_end), day(calendar_year_end), year(calendar_year_end) - 1)
	format %td calendar_year_end_lag
	assert !missing(calendar_year_end_lag)

	gen trad_bus_cal_year_end_lag = bofd("crsptrdays", calendar_year_end_lag)
	format %tbcrsptrdays trad_bus_cal_year_end_lag

	egen miss_total = total(cond(missing(trad_bus_cal_year_end_lag), 1, 0))
	local i = 1
	while miss_total!=0 & `i'<=11 { // Only stops the loop if either there are no missing values or it goes back more than 11 trading days.
		quietly replace trad_bus_cal_year_end_lag = bofd("crsptrdays", calendar_year_end_lag - `i') if missing(trad_bus_cal_year_end_lag)
		quietly drop miss_total
		quietly egen miss_total = total(cond(missing(trad_bus_cal_year_end_lag), 1, 0))
		local i = `i' + 1
	}
	drop miss_total
	assert !missing(trad_bus_cal_year_end_lag) // Checks the presence of observations whose "trad_bus_cal_year_end_lag" is missing.

	gen trad_calendar_year_end_lag = dofb(trad_bus_cal_year_end_lag,"crsptrdays")
	format %td trad_calendar_year_end_lag
	gen diff_days = calendar_year_end_lag - trad_calendar_year_end_lag

	quietly log on
		* Distribution of the difference between the calendar year end day and the respective trading day.
		tab diff_days, missing
		tab calendar_year_end_lag diff_days
	quietly log off

	drop trad_bus_cal_year_end_lag diff_days
	erase "crsptrdays.stbcal"
	save "DB ISSDD Firm-Year Level CRSP - Temp 1", replace
	clear

	use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2021-11-05", clear
		rename *, lower
		keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
		keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.
		destring gvkey, replace

		keep gvkey linktype linkprim lpermno lpermco linkdt linkenddt

		assert !missing(gvkey, linkdt)
		duplicates report gvkey linkdt linkenddt
		assert `r(unique_value)'==`r(N)'
		sort gvkey linkdt linkenddt
		order gvkey linktype linkprim lpermno lpermco linkdt linkenddt

		save "DB ISSDD Firm-Year Level CRSP - Temp 2", replace
		clear

	use "DB ISSDD Firm-Year Level CRSP - Temp 1", clear
	erase "DB ISSDD Firm-Year Level CRSP - Temp 1.dta"
	joinby gvkey using "DB ISSDD Firm-Year Level CRSP - Temp 2", unmatched(master) // Although some observations in the master database contain missing values for "gvkey", as long as there is no missing values for "gvkey" in the using database, there is no problem. This was checked earlier.
	erase "DB ISSDD Firm-Year Level CRSP - Temp 2.dta"
	assert !missing(trad_calendar_year_end_lag)

	foreach variab in linktype linkprim {
		quietly replace `variab' = "" if (trad_calendar_year_end_lag < linkdt | trad_calendar_year_end_lag > linkenddt)
	}

	foreach variab in lpermno lpermco linkdt linkenddt {
		quietly replace `variab' = . if (trad_calendar_year_end_lag < linkdt | trad_calendar_year_end_lag > linkenddt)
	}

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0
	assert missing(linktype, linkprim, lpermno, lpermco, linkdt, linkenddt) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) whose trading day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort iss_company_id calendar_year_end: egen sum_valid_link = total(valid_link)
	assert sum_valid_link==1 | sum_valid_link==0 // There is at most one valid link per firm-year.
	drop if valid_link==0 & sum_valid_link==1
	drop _merge valid_link sum_valid_link

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique pair.
	sort iss_company_id calendar_year_end

quietly count // Stores the number of observations in `r(N)'.
assert `r(N)'==`num_obs' // Checks that the original number of observations is correct.

save "${folder_save_databases}/iss/DB ISSDD Firm-Year Level CRSP", replace
clear

**# Merge multiple variables for the analysis of the determinants of racial diversity.
use "${folder_save_databases}/iss/DB Board Network Size ISSDD", clear
	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort iss_company_id calendar_year_end
	save "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Directors' Age", clear
	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort iss_company_id calendar_year_end
	save "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 2", replace
	clear

use "${folder_save_databases}/iss/DB Supply Directors ISSDD", clear
	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort iss_company_id calendar_year_end
	save "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 3", replace
	clear

use "${folder_save_databases}/Institutional_Ownership/DB TR Institutional Ownership", clear
	assert !missing(cusip_8, rdate)
	duplicates report cusip_8 rdate
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort cusip_8 rdate
	save "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 5", replace
	clear

use "${folder_save_databases}/Institutional_Ownership/DB TR Big Three Ownership", clear
	rename rdate rdate_big_3
	assert !missing(cusip_8, rdate_big_3)
	duplicates report cusip_8 rdate_big_3
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort cusip_8 rdate_big_3
	save "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 6", replace
	clear

use "${folder_save_databases}/Compustat/DB Compustat", clear
	assert !missing(gvkey, datadate)
	duplicates report gvkey datadate
	assert `r(unique_value)'==`r(N)'
	sort gvkey datadate
	save "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 8", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level CRSP", clear

xtset iss_company_id calendar_year
	gen prop_dir_women_lag = L.prop_dir_women
	gen prop_dir_men_lag = L.prop_dir_men
xtset, clear

drop median_director_age stdev_director_age // Because "age" is not correctly measured, then "median_director_age" and "stdev_director_age" are also incorrect.

merge 1:1 iss_company_id calendar_year_end using "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 1", keep(match master)
drop _merge
erase "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 1.dta"

merge 1:1 iss_company_id calendar_year_end using "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 2", keep(match master)
drop _merge
erase "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 2.dta"

merge 1:1 iss_company_id calendar_year_end using "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 3", keep(match master)
drop _merge
erase "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 3.dta"

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 5", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 5.dta"
	duplicates report iss_company_id calendar_year_end rdate // Some of the "rdate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-rdate form a unique identifier.
	sort iss_company_id calendar_year_end rdate

	assert day(rdate + 1)==1 if !missing(rdate) // The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.
	assert ( 				///
		month(rdate)==03 | 	///
		month(rdate)==06 | 	///
		month(rdate)==09 | 	///
		month(rdate)==12 	///
	) if !missing(rdate) 	// The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.

	gen calendar_year_month_end = mofd(calendar_year_end)
	gen rdate_month = mofd(rdate)
	format %tm calendar_year_month_end rdate_month
	gen month_year_dif = rdate_month - calendar_year_month_end

	gen match_window = cond(month_year_dif<=-6 & month_year_dif>-18, 1, 0) if _merge==3
	bysort iss_company_id calendar_year_end (rdate): egen sum_match_window = total(match_window) if _merge==3
	bysort iss_company_id calendar_year_end (rdate): egen max_month_year_dif = max(month_year_dif) if match_window==1 & sum_match_window>1

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss calendar_year_month_end rdate_month month_year_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval of -18 to -6 months.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if month_year_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 calendar_year_month_end rdate_month month_year_dif match_window sum_match_window max_month_year_dif retain

	xtset iss_company_id calendar_year
		foreach v in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss {
			quietly replace `v' = L.`v' if calendar_year==2021 // For now, we forward track 2020 into 2021.
		}
	xtset, clear

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss {
		rename `variab' `variab'_lag
	}

	gen InstOwn_Perc_0_lag = cond((missing(InstOwn_Perc_lag) & !missing(cusip) & shrout_zero_miss_lag!=1), 0, InstOwn_Perc_lag) // I assume that form 13F is comprehensive and, therefore, substitute "InstOwn_Perc_lag" by zero, as long as "cusip" is not missing and "shrout" is neither zero or missing in the Thomson Reuters database.
	gen InstOwn_Perc_miss_lag = cond(missing(InstOwn_Perc_lag) & InstOwn_Perc_0_lag==0, 1, 0) if !missing(InstOwn_Perc_0_lag)
	drop shrout_zero_miss_lag

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique identifier.
	sort iss_company_id calendar_year_end

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 6", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 6.dta"
	duplicates report iss_company_id calendar_year_end rdate_big_3 // Some of the "rdate_big_3" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-rdate_big_3 form a unique identifier.
	sort iss_company_id calendar_year_end rdate_big_3

	assert day(rdate_big_3 + 1)==1 if !missing(rdate_big_3) // The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.
	assert ( 						///
		month(rdate_big_3)==03 | 	///
		month(rdate_big_3)==06 | 	///
		month(rdate_big_3)==09 | 	///
		month(rdate_big_3)==12 		///
	) if !missing(rdate_big_3) 		// The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.

	gen calendar_year_month_end = mofd(calendar_year_end)
	gen rdate_big_3_month = mofd(rdate_big_3)
	format %tm calendar_year_month_end rdate_big_3_month
	gen month_year_dif = rdate_big_3_month - calendar_year_month_end

	gen match_window = cond(month_year_dif<=-6 & month_year_dif>-18, 1, 0) if _merge==3
	bysort iss_company_id calendar_year_end (rdate_big_3): egen sum_match_window = total(match_window) if _merge==3
	bysort iss_company_id calendar_year_end (rdate_big_3): egen max_month_year_dif = max(month_year_dif) if match_window==1 & sum_match_window>1

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 calendar_year_month_end rdate_big_3_month month_year_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval of -18 to -6 months.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if month_year_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 calendar_year_month_end rdate_big_3_month month_year_dif match_window sum_match_window max_month_year_dif retain

	xtset iss_company_id calendar_year
		foreach v in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 {
			quietly replace `v' = L.`v' if calendar_year==2021 // For now, we forward track 2020 into 2021.
		}
	xtset, clear

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 {
		rename `variab' `variab'_lag
	}

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		quietly gen inst_`variab'_0_lag = cond((missing(inst_`variab'_lag) & !missing(cusip) & miss_inst_`variab'_lag!=1), 0, inst_`variab'_lag) // I assume that form 13F is comprehensive and, therefore, substitute the variables by zero, as long as "cusip" is not missing and the variables are not missing in the Thomson Reuters database.
		quietly gen inst_`variab'_miss_lag = cond(missing(inst_`variab'_lag) & inst_`variab'_0_lag==0, 1, 0) if !missing(inst_`variab'_0_lag)
		drop miss_inst_`variab'_lag
	}

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique identifier.
	sort iss_company_id calendar_year_end
	order rdate_big_3_lag inst_own_lag inst_own_0_lag inst_own_miss_lag inst_own_blackrock_lag inst_own_blackrock_0_lag inst_own_blackrock_miss_lag inst_own_vanguard_lag inst_own_vanguard_0_lag inst_own_vanguard_miss_lag inst_own_ssga_lag inst_own_ssga_0_lag inst_own_ssga_miss_lag inst_own_big_3_lag inst_own_big_3_0_lag inst_own_big_3_miss_lag, last

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	joinby gvkey using "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 8", unmatched(master) // There are missing "gvkey" values in the master database. It is ok to use "joinby" because there are no missing "gvkey" values in the using database.
	erase "DB ISSDD Firm-Year Level Merge Multiple Variables - Temp 8.dta"
	duplicates report iss_company_id calendar_year_end datadate // Some of the "datadate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-datadate form a unique identifier.
	sort iss_company_id calendar_year_end datadate

	assert day(datadate + 1)==1 if !missing(datadate) // The precision of the variable "datadate" is month-year, since it always contains the last day of the month.
	gen calendar_year_month_end = mofd(calendar_year_end)
	gen datadate_month = mofd(datadate)
	format %tm calendar_year_month_end datadate_month
	gen month_year_dif = datadate_month - calendar_year_month_end

	gen match_window = cond(month_year_dif<=-6 & month_year_dif>-18, 1, 0) if _merge==3
	bysort iss_company_id calendar_year_end (datadate): egen sum_match_window = total(match_window) if _merge==3
	bysort iss_company_id calendar_year_end (datadate): egen max_month_year_dif = max(month_year_dif) if match_window==1 & sum_match_window>1

	foreach variab in datadate at firm_visibility csho prcc_f book_to_market roa loss rd_over_assets rd_over_assets_0 rd_miss firm_age_min_fyear ln_firm_age_min_fyear firm_age_ipo_years ln_firm_age_ipo_years firm_age_ipo_days ln_firm_age_ipo_days sic naics naicsh calendar_year_month_end datadate_month month_year_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval of -18 to -6 months.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if month_year_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge calendar_year_month_end datadate_month month_year_dif match_window sum_match_window max_month_year_dif retain

	foreach variab in datadate at firm_visibility csho prcc_f book_to_market roa loss rd_over_assets rd_over_assets_0 rd_miss firm_age_min_fyear ln_firm_age_min_fyear firm_age_ipo_years ln_firm_age_ipo_years firm_age_ipo_days ln_firm_age_ipo_days {
		rename `variab' `variab'_lag
	}

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique identifier.
	sort iss_company_id calendar_year_end

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique identifier.
sort iss_company_id calendar_year_end

save "${folder_save_databases}/iss/DB ISSDD Firm-Year Level Merge Multiple Variables", replace
clear

**# Create a list of unique NAICS and NAICSH values for "sample" equals one.
use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level Merge Multiple Variables", clear

keep if sample==1
keep naics naicsh

gen length_naics = ustrlen(string(naics, "%9.0f")) if !missing(naics)
gen length_naicsh = ustrlen(string(naicsh, "%9.0f")) if !missing(naicsh)

quietly log on
	* Shows the distribution of the number of digits of "naics" and "naicsh" for "sample" equals one.
	tab length_naics, miss
	tab length_naicsh, miss
	count if naicsh!=naics & !missing(naics, naicsh)
quietly log off

drop length_naics length_naicsh

preserve
	keep naics
	duplicates drop
	drop if missing(naics)
	sort naics

	save "${folder_save_databases}/Industries/DB Unique NAICS for sample", replace
	clear
restore

preserve
	keep naicsh
	duplicates drop
	drop if missing(naicsh)
	sort naicsh

	save "${folder_save_databases}/Industries/DB Unique NAICSH for sample", replace
	clear
restore

clear

**# Bureau of Labor Statistics.

**## BLS_diversity_2012_2016

clear
cd "YOUR_PATH\data\raw\BLS\"
import excel "YOUR_PATH\data\raw\BLS\2-digit_2012_Codes-1_cleaning.xls", sheet("tbl_2012_title_description_coun") firstrow
leftalign
drop if missing( NAICS_Code_2012)
destring NAICS_Code_2012, replace force
gen NAICS_Code_2012n = NAICS_Code_2012
replace NAICS_Code_2012n = NAICS_Code_2012*10 if NAICS_Code_2012 < 100000
replace NAICS_Code_2012n = NAICS_Code_2012*100 if NAICS_Code_2012 < 10000
replace NAICS_Code_2012n = NAICS_Code_2012*1000 if NAICS_Code_2012 < 1000
replace NAICS_Code_2012n = NAICS_Code_2012*10000 if NAICS_Code_2012 < 100
sort NAICS_Code_2012n

*duplicates drop NAICS_Code_2012n, force
save "2012_NAICS_temp", replace
*NAICS_Code_2012 NAICS_Title_2012 NAICS_Code_2012n
// use "2012_NAICS_temp", clear
// duplicates tag NAICS_Code_2012n, gen(dups)
// tab dups
// drop dups

import excel "YOUR_PATH\data\raw\BLS\2012-census-industry-classification-titles-and-code-list_cleaning.xlsx", sheet("2012") firstrow clear
replace BLS_industry_title = strtrim(BLS_industry_title)
leftalign
drop if missing( NAICS_Code_2012)
gen NAICS_Code_2012_orig = NAICS_Code_2012
replace NAICS_Code_2012 = substr(NAICS_Code_2012,1,strpos(NAICS_Code_2012, " exc. ") - 1) if regexm(NAICS_Code_2012, "exc.")
replace NAICS_Code_2012 = substr(lower(NAICS_Code_2012),1,strpos(NAICS_Code_2012, ", pt. ") - 1) if regexm(lower(NAICS_Code_2012), "pt.")
replace NAICS_Code_2012 = substr(lower(NAICS_Code_2012),1,strpos(NAICS_Code_2012, ", part of ") - 1) if regexm(lower(NAICS_Code_2012), "part of")
replace NAICS_Code_2012 = substr(lower(NAICS_Code_2012),1,strpos(NAICS_Code_2012, ", pts. ") - 1) if regexm(NAICS_Code_2012, "pts.") //redundant
drop if missing( NAICS_Code_2012)
gen serno = _n
egen BLS_industry_title_n = concat(BLS_industry_title serno), punct(-)

split NAICS_Code_2012, parse(",") gen(multiple_codes)

reshape long multiple_codes, i(BLS_industry_title_n) j(codes)
drop if missing(multiple_codes)
leftalign
drop serno BLS_industry_title_n

destring multiple_codes, gen(multiple_codesn) force
drop multiple_codes
rename multiple_codesn multiple_codes

drop codes
drop NAICS_Code_2012
rename multiple_codes NAICS_Code_2012
gen NAICS_Code_2012n = NAICS_Code_2012
replace NAICS_Code_2012n = NAICS_Code_2012*10 if NAICS_Code_2012 < 100000
replace NAICS_Code_2012n = NAICS_Code_2012*100 if NAICS_Code_2012 < 10000
replace NAICS_Code_2012n = NAICS_Code_2012*1000 if NAICS_Code_2012 < 1000
replace NAICS_Code_2012n = NAICS_Code_2012*10000 if NAICS_Code_2012 < 100
rename NAICS_Code_2012 BLS_NAICS_Code_2012
drop NAICS_Code_2012_orig

duplicates tag NAICS_Code_2012n, gen(dups)
tab dups
browse if dups > 0
drop dups
joinby NAICS_Code_2012n using 2012_NAICS_temp, unmatched(master)
* all matched
tab _merge
drop _merge
gen Walk_ID = _n
*drop NAICS_Code_2012

save "2012_BLS_NAICS_Walk", replace
* BLS_Industry_title BLS_NAICS_Code_2012 NAICS_Code_2012n NAICS_Code_2012 NAICS_Title_2012 Walk_ID
erase 2012_NAICS_temp.dta

// use "2012_BLS_NAICS_Walk", clear
// duplicates tag BLS_Industry_title, gen(dups)
// tab dups
// brows if dups > 0

forvalues i=2012(1)2016 {
import excel "YOUR_PATH\data\raw\BLS\O&I02_2012_2020_from_Dejan_cleaning.xlsx", sheet("`i'") firstrow clear
	if `i' !=2020 {
		replace A = B if missing(A) & !missing(B)
		replace A = C if missing(A) & !missing(C)
		replace A = D if missing(A) & !missing(D)
		gen test = strpos(A, "..")
		replace A = substr(A,1,strpos(A, "..") - 1) if regexm(A, "..") & test !=0
		leftalign
		drop B-J
		drop test
		}

drop if missing(A)
rename A BLS_Industry_title_annual
replace BLS_Industry_title_annual = strtrim(BLS_Industry_title_annual)
leftalign
gen year = `i'
order year

foreach ethnic of varlist WomenP BlackP AsianP HispanicP {
	if substr("`:type `ethnic' '",1,3) != "str" {
	gen `ethnic'n = `ethnic'
	drop `ethnic'
	}
	if substr("`:type `ethnic' '",1,3) == "str" {
	replace `ethnic' = "." if regexm(`ethnic',"­")
	destring `ethnic' , gen(`ethnic'n) force
	drop `ethnic'
	}
}

egen allmiss = rsum2(WomenPn BlackPn AsianPn HispanicPn), allmiss
drop if allmiss == .
sum
save "`i'_BLS_data_temp", replace

}


forvalues i=2012(1)2016 {
	use "`i'_BLS_data_temp", clear
		gen BLS_ID = _n
	matchit BLS_ID BLS_Industry_title_annual using "2012_BLS_NAICS_Walk.dta", idu(NAICS_Code_2012n) txtu(BLS_industry_title) sim(token) threshold(.5) override
	bysort NAICS_Code_2012n: egen max_simil = max(similscore)
	gsort NAICS_Code_2012n -similscore
	browse
	drop if max_simil != similscore
	leftalign
	drop BLS_ID
	gen year = `i'
	drop similscore
	save "`i'_BLS_data_matchit", replace
	sum
}


use "2012_BLS_data_temp", clear
forvalues i=2013(1)2016 {
	append using `i'_BLS_data_temp
}

drop allmiss
save "2012_2016_BLS_data_temp", replace
* BLS_Industry_title_annual Total WomenPn BlackPn AsianPn HispanicPn

use "2012_BLS_data_matchit", clear
forvalues i=2013(1)2016 {
	append using `i'_BLS_data_matchit
}

drop if max_simil < .75
save "2012_2016_BLS_data_matchit", replace
* year BLS_Industry_title_annual NAICS_Code_2012n BLS_Industry_title max_simil year

merge m:1 year BLS_Industry_title_annual using 2012_2016_BLS_data_temp
browse if _merge == 2
keep if _merge == 3
drop _merge
save "2012_2016_BLS_NAICS_matched_data", replace
*BLS_Industry_title_annual NAICS_Code_2012n BLS_industry_title max_simil year Total WomenPn BlackPn AsianPn HispanicPn

use "2012_2016_BLS_NAICS_matched_data", clear
gen naics = NAICS_Code_2012n
replace naics = NAICS_Code_2012n/10 if mod(NAICS_Code_2012n, 10) == 0
replace naics = NAICS_Code_2012n/100 if mod(NAICS_Code_2012n, 100) == 0
replace naics = NAICS_Code_2012n/1000 if mod(NAICS_Code_2012n, 1000) == 0
replace naics = NAICS_Code_2012n/10000 if mod(NAICS_Code_2012n, 10000) == 0
gen naics2 = naics if inrange(naics,10,99)
gen naics3 = naics if inrange(naics,100,999)
gen naics4 = naics if inrange(naics,1000,9999)
gen naics5 = naics if inrange(naics,10000,99999)
gen naics6 = naics if inrange(naics,100000,999999)
save "2012_2016_BLS_NAICS_matched_data", replace

forvalues i=2012(1)2016 {
	erase `i'_BLS_data_temp.dta
	erase `i'_BLS_data_matchit.dta
}
erase 2012_2016_BLS_data_matchit.dta
erase 2012_2016_BLS_data_temp.dta

use "DB Unique NAICS for sample", clear
*naics
gen compustat = 1
gen naics2 = naics if inrange(naics,1,99)
replace naics2 = int(naics/10) if inrange(naics,100,999)
replace naics2 = int(naics/100) if inrange(naics,1000,9999)
replace naics2 = int(naics/1000) if inrange(naics,10000,99999)
replace naics2 = int(naics/10000) if inrange(naics,100000,999999)

gen naics3 = . if inrange(naics,1,99)
replace naics3 = naics if inrange(naics,100,999)
replace naics3 = int(naics/10) if inrange(naics,1000,9999)
replace naics3 = int(naics/100) if inrange(naics,10000,99999)
replace naics3 = int(naics/1000) if inrange(naics,100000,999999)

gen naics4 = . if inrange(naics,1,999)
replace naics4 = naics if inrange(naics,1000,9999)
replace naics4 = int(naics/10) if inrange(naics,10000,99999)
replace naics4 = int(naics/100) if inrange(naics,100000,999999)

gen naics5 = . if inrange(naics,1,9999)
replace naics5 = naics if inrange(naics,10000,99999)
replace naics5 = int(naics/10) if inrange(naics,100000,999999)

gen naics6 = .
replace naics6 = naics if inrange(naics,100000,999999) & mod(naics, 10) !=0
browse
sort naics
gen comp_naics_id = _n
save "DB Unique NAICS for sample_temp", replace

forvalues i=2(1)6 {
use "DB Unique NAICS for sample_temp", clear
gen comp_naics = naics
keep naics`i' compustat comp_naics_id comp_naics
drop if missing(naics`i')
*duplicates drop naics`i', force
joinby naics`i' using "2012_2016_BLS_NAICS_matched_data", unmatched(master)
table _merge
keep if _merge==3
save "naics`i'_temp", replace
}

use "naics2_temp", clear
forvalues i=2(1)6 {
	append using "naics`i'_temp"
}

sort NAICS_Code_2012n year comp_naics
gen naics_gap = comp_naics - naics
order compustat naics comp_naics naics_gap naics2 naics3 naics4 naics5 naics6 year
bysort year comp_naics: egen min_naics_gap = min(naics_gap)
drop if naics_gap != min_naics_gap
drop compustat naics_gap naics2 naics3 naics4 naics5 naics6 comp_naics_id _merge min_naics_gap
duplicates drop naics comp_naics year BLS_Industry_title_annual Total WomenPn BlackPn AsianPn HispanicPn, force
save "2012_2016_Compustat_NACIS_BLS_Merged_data", replace
*naics comp_naics year BLS_Industry_title_annual NAICS_Code_2012n BLS_industry_title max_simil Total WomenPn BlackPn AsianPn HispanicPn

forvalues i=2(1)6 {
	erase "naics`i'_temp.dta"
}

erase "DB Unique NAICS for sample_temp.dta"

**## BLS_diversity_2017_2019

// Effective with January 2020 data, industries reflect the introduction of the 2017 Census industry classification system, derived from the 2017 North American Industry Classification System (NAICS)
// So I should use the 2012 NAICS through 2019
clear
cd "YOUR_PATH\data\raw\BLS\"
import excel "YOUR_PATH\data\raw\BLS\2017_NAICS_Structure-1_cleaning.xlsx", sheet("Sheet1") cellrange(A1:B2216) firstrow
leftalign
drop if missing( NAICS_Code_2017)
gen NAICS_Code_2017n = NAICS_Code_2017
replace NAICS_Code_2017n = NAICS_Code_2017*10 if NAICS_Code_2017 < 100000
replace NAICS_Code_2017n = NAICS_Code_2017*100 if NAICS_Code_2017 < 10000
replace NAICS_Code_2017n = NAICS_Code_2017*1000 if NAICS_Code_2017 < 1000
replace NAICS_Code_2017n = NAICS_Code_2017*10000 if NAICS_Code_2017 < 100
sort NAICS_Code_2017n

replace NAICS_Title_2017 = strtrim(NAICS_Title_2017)
browse if usubstr( NAICS_Title_2017 , -1, 1) == "T"
replace NAICS_Title_2017 = usubstr( NAICS_Title_2017 , 1, length( NAICS_Title_2017 ) - 1) if usubstr( NAICS_Title_2017 , -1, 1) == "T"

*duplicates drop NAICS_Code_2017n, force
save "2017_NAICS_temp", replace
*NAICS_Code_2017 NAICS_Title_2017 NAICS_Code_2017n
// use "2017_NAICS_temp", clear
// duplicates tag NAICS_Code_2017n, gen(dups)
// tab dups
// drop dups

***********************************************************************************************************************
cd "YOUR_PATH\data\raw\BLS\"
import excel "YOUR_PATH\data\raw\BLS\2-digit_2012_Codes-1_cleaning.xls", sheet("tbl_2012_title_description_coun") firstrow clear
leftalign
drop if missing( NAICS_Code_2012)
destring NAICS_Code_2012, replace force
gen NAICS_Code_2012n = NAICS_Code_2012
replace NAICS_Code_2012n = NAICS_Code_2012*10 if NAICS_Code_2012 < 100000
replace NAICS_Code_2012n = NAICS_Code_2012*100 if NAICS_Code_2012 < 10000
replace NAICS_Code_2012n = NAICS_Code_2012*1000 if NAICS_Code_2012 < 1000
replace NAICS_Code_2012n = NAICS_Code_2012*10000 if NAICS_Code_2012 < 100
sort NAICS_Code_2012n

// For coding convenience I using 2017 to name the 2012 variables, so I don't have to change the rest of my code
// BTW, the code saved under Old folder should still work, subject to assuming that BLS started using the 2017 NAICS classification from 2017 onwards instead of starting 2020

rename NAICS_Code_2012 NAICS_Code_2017
rename NAICS_Title_2012 NAICS_Title_2017
rename NAICS_Code_2012n NAICS_Code_2017n

*duplicates drop NAICS_Code_2017n, force
save "2017_NAICS_temp", replace
*NAICS_Code_2017 NAICS_Title_2017 NAICS_Code_2017n
// use "2017_NAICS_temp", clear
// duplicates tag NAICS_Code_2017n, gen(dups)
// tab dups
// drop dups

import excel "YOUR_PATH\data\raw\BLS\2017-census-industry-classification-titles-and-code-list-1_cleaning.xlsx", sheet("2017") firstrow clear
replace BLS_industry_title = strtrim(BLS_industry_title)
leftalign
drop if missing( NAICS_Code_2017)
gen NAICS_Code_2017_orig = NAICS_Code_2017
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, " exc. ") - 1) if regexm(NAICS_Code_2017, "exc.")
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, ", pt. ") - 1) if regexm(NAICS_Code_2017, "pt.")
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, ", part of ") - 1) if regexm(NAICS_Code_2017, "part of")
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, ", pts. ") - 1) if regexm(NAICS_Code_2017, "pts.")
gen serno = _n
egen BLS_industry_title_n = concat(BLS_industry_title serno), punct(-)

split NAICS_Code_2017, parse(",") gen(multiple_codes)

reshape long multiple_codes, i(BLS_industry_title_n) j(codes)
drop if missing(multiple_codes)
leftalign
drop serno BLS_industry_title_n

destring multiple_codes, gen(multiple_codesn)
drop multiple_codes
rename multiple_codesn multiple_codes

drop codes
drop NAICS_Code_2017
rename multiple_codes NAICS_Code_2017
gen NAICS_Code_2017n = NAICS_Code_2017
replace NAICS_Code_2017n = NAICS_Code_2017*10 if NAICS_Code_2017 < 100000
replace NAICS_Code_2017n = NAICS_Code_2017*100 if NAICS_Code_2017 < 10000
replace NAICS_Code_2017n = NAICS_Code_2017*1000 if NAICS_Code_2017 < 1000
replace NAICS_Code_2017n = NAICS_Code_2017*10000 if NAICS_Code_2017 < 100
rename NAICS_Code_2017 BLS_NAICS_Code_2017
drop NAICS_Code_2017_orig

duplicates tag NAICS_Code_2017n, gen(dups)
tab dups
browse if dups > 0
drop dups
joinby NAICS_Code_2017n using 2017_NAICS_temp, unmatched(master)
* all matched
tab _merge
drop _merge
gen Walk_ID = _n
*drop NAICS_Code_2017

save "2017_BLS_NAICS_Walk", replace
* BLS_Industry_title BLS_NAICS_Code_2017 NAICS_Code_2017n NAICS_Code_2017 NAICS_Title_2017 Walk_ID
erase 2017_NAICS_temp.dta

// use "2017_BLS_NAICS_Walk", clear
// duplicates tag BLS_Industry_title, gen(dups)
// tab dups
// brows if dups > 0

forvalues i=2017(1)2019 {
import excel "YOUR_PATH\data\raw\BLS\O&I02_2012_2020_from_Dejan_cleaning.xlsx", sheet("`i'") firstrow clear
	if `i' !=2020 {
		replace A = B if missing(A) & !missing(B)
		replace A = C if missing(A) & !missing(C)
		replace A = D if missing(A) & !missing(D)
		gen test = strpos(A, "..")
		replace A = substr(A,1,strpos(A, "..") - 1) if regexm(A, "..") & test !=0
		leftalign
		drop B-J
		drop test
		}

drop if missing(A)
rename A BLS_Industry_title_annual
replace BLS_Industry_title_annual = strtrim(BLS_Industry_title_annual)
leftalign
gen year = `i'
order year

foreach ethnic of varlist WomenP BlackP AsianP HispanicP {
	if substr("`:type `ethnic' '",1,3) != "str" {
	gen `ethnic'n = `ethnic'
	drop `ethnic'
	}
	if substr("`:type `ethnic' '",1,3) == "str" {
	replace `ethnic' = "." if regexm(`ethnic',"­")
	destring `ethnic' , gen(`ethnic'n) force
	drop `ethnic'
	}
}

egen allmiss = rsum2(WomenPn BlackPn AsianPn HispanicPn), allmiss
drop if allmiss == .
sum
save "`i'_BLS_data_temp", replace

}

forvalues i=2017(1)2019 {
	use "`i'_BLS_data_temp", clear
		gen BLS_ID = _n
	matchit BLS_ID BLS_Industry_title_annual using "2017_BLS_NAICS_Walk.dta", idu(NAICS_Code_2017n) txtu(BLS_industry_title) sim(token) threshold(.5) override
	bysort NAICS_Code_2017n: egen max_simil = max(similscore)
	gsort NAICS_Code_2017n -similscore
	browse
	drop if max_simil != similscore
	leftalign
	drop BLS_ID
	gen year = `i'
	drop similscore
	save "`i'_BLS_data_matchit", replace
	sum
}

use "2017_BLS_data_temp", clear
forvalues i=2018(1)2019 {
	append using `i'_BLS_data_temp

}
drop allmiss
save "2017_2019_BLS_data_temp", replace
* BLS_Industry_title_annual Total WomenPn BlackPn AsianPn HispanicPn

use "2017_BLS_data_matchit", clear
forvalues i=2018(1)2019 {
	append using `i'_BLS_data_matchit

}
drop if max_simil < .75
save "2017_2019_BLS_data_matchit", replace
* year BLS_Industry_title_annual NAICS_Code_2017n BLS_Industry_title max_simil year

merge m:1 year BLS_Industry_title_annual using 2017_2019_BLS_data_temp
browse if _merge == 2
keep if _merge == 3
drop _merge
save "2017_2019_BLS_NAICS_matched_data", replace
*BLS_Industry_title_annual NAICS_Code_2017n BLS_industry_title max_simil year Total WomenPn BlackPn AsianPn HispanicPn

use "2017_2019_BLS_NAICS_matched_data", clear
gen naics = NAICS_Code_2017n
replace naics = NAICS_Code_2017n/10 if mod(NAICS_Code_2017n, 10) == 0
replace naics = NAICS_Code_2017n/100 if mod(NAICS_Code_2017n, 100) == 0
replace naics = NAICS_Code_2017n/1000 if mod(NAICS_Code_2017n, 1000) == 0
replace naics = NAICS_Code_2017n/10000 if mod(NAICS_Code_2017n, 10000) == 0
gen naics2 = naics if inrange(naics,10,99)
gen naics3 = naics if inrange(naics,100,999)
gen naics4 = naics if inrange(naics,1000,9999)
gen naics5 = naics if inrange(naics,10000,99999)
gen naics6 = naics if inrange(naics,100000,999999)
save "2017_2019_BLS_NAICS_matched_data", replace

forvalues i=2017(1)2019 {
	erase `i'_BLS_data_temp.dta
	erase `i'_BLS_data_matchit.dta
}
erase 2017_2019_BLS_data_matchit.dta
erase 2017_2019_BLS_data_temp.dta

use "DB Unique NAICS for sample", clear
*naics
gen compustat = 1
gen naics2 = naics if inrange(naics,1,99)
replace naics2 = int(naics/10) if inrange(naics,100,999)
replace naics2 = int(naics/100) if inrange(naics,1000,9999)
replace naics2 = int(naics/1000) if inrange(naics,10000,99999)
replace naics2 = int(naics/10000) if inrange(naics,100000,999999)

gen naics3 = . if inrange(naics,1,99)
replace naics3 = naics if inrange(naics,100,999)
replace naics3 = int(naics/10) if inrange(naics,1000,9999)
replace naics3 = int(naics/100) if inrange(naics,10000,99999)
replace naics3 = int(naics/1000) if inrange(naics,100000,999999)

gen naics4 = . if inrange(naics,1,999)
replace naics4 = naics if inrange(naics,1000,9999)
replace naics4 = int(naics/10) if inrange(naics,10000,99999)
replace naics4 = int(naics/100) if inrange(naics,100000,999999)

gen naics5 = . if inrange(naics,1,9999)
replace naics5 = naics if inrange(naics,10000,99999)
replace naics5 = int(naics/10) if inrange(naics,100000,999999)

gen naics6 = .
replace naics6 = naics if inrange(naics,100000,999999) & mod(naics, 10) !=0
browse
sort naics
gen comp_naics_id = _n
save "DB Unique NAICS for sample_temp", replace

forvalues i=2(1)6 {
use "DB Unique NAICS for sample_temp", clear
gen comp_naics = naics
keep naics`i' compustat comp_naics_id comp_naics
drop if missing(naics`i')
*duplicates drop naics`i', force
joinby naics`i' using "2017_2019_BLS_NAICS_matched_data", unmatched(master)
*merge 1:m naics`i' using "2017_2019_BLS_NAICS_matched_data"
table _merge
keep if _merge==3
save "naics`i'_temp", replace
}

use "naics2_temp", clear
forvalues i=2(1)6 {
	append using "naics`i'_temp"
}

sort NAICS_Code_2017n year comp_naics
gen naics_gap = comp_naics - naics
order compustat naics comp_naics naics_gap naics2 naics3 naics4 naics5 naics6 year
bysort year comp_naics: egen min_naics_gap = min(naics_gap)
drop if naics_gap != min_naics_gap
drop compustat naics_gap naics2 naics3 naics4 naics5 naics6 comp_naics_id _merge min_naics_gap
duplicates drop naics comp_naics year BLS_Industry_title_annual Total WomenPn BlackPn AsianPn HispanicPn, force
save "2017_2019_Compustat_NACIS_BLS_Merged_data", replace

forvalues i=2(1)6 {
	erase "naics`i'_temp.dta"

}
erase "DB Unique NAICS for sample_temp.dta"

**## BLS_diversity_2020_2020

clear
cd "YOUR_PATH\data\raw\BLS\"
import excel "YOUR_PATH\data\raw\BLS\2017_NAICS_Structure-1_cleaning.xlsx", sheet("Sheet1") cellrange(A1:B2216) firstrow
leftalign
drop if missing( NAICS_Code_2017)
gen NAICS_Code_2017n = NAICS_Code_2017
replace NAICS_Code_2017n = NAICS_Code_2017*10 if NAICS_Code_2017 < 100000
replace NAICS_Code_2017n = NAICS_Code_2017*100 if NAICS_Code_2017 < 10000
replace NAICS_Code_2017n = NAICS_Code_2017*1000 if NAICS_Code_2017 < 1000
replace NAICS_Code_2017n = NAICS_Code_2017*10000 if NAICS_Code_2017 < 100
sort NAICS_Code_2017n

replace NAICS_Title_2017 = strtrim(NAICS_Title_2017)
browse if usubstr( NAICS_Title_2017 , -1, 1) == "T"
replace NAICS_Title_2017 = usubstr( NAICS_Title_2017 , 1, length( NAICS_Title_2017 ) - 1) if usubstr( NAICS_Title_2017 , -1, 1) == "T"

*duplicates drop NAICS_Code_2017n, force
save "2017_NAICS_temp", replace
*NAICS_Code_2017 NAICS_Title_2017 NAICS_Code_2017n
// use "2017_NAICS_temp", clear
// duplicates tag NAICS_Code_2017n, gen(dups)
// tab dups
// drop dups

import excel "YOUR_PATH\data\raw\BLS\2017-census-industry-classification-titles-and-code-list-1_cleaning.xlsx", sheet("2017") firstrow clear
replace BLS_industry_title = strtrim(BLS_industry_title)
leftalign
drop if missing( NAICS_Code_2017)
gen NAICS_Code_2017_orig = NAICS_Code_2017
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, " exc. ") - 1) if regexm(NAICS_Code_2017, "exc.")
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, ", pt. ") - 1) if regexm(NAICS_Code_2017, "pt.")
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, ", part of ") - 1) if regexm(NAICS_Code_2017, "part of")
replace NAICS_Code_2017 = substr(NAICS_Code_2017,1,strpos(NAICS_Code_2017, ", pts. ") - 1) if regexm(NAICS_Code_2017, "pts.")
gen serno = _n
egen BLS_industry_title_n = concat(BLS_industry_title serno), punct(-)

split NAICS_Code_2017, parse(",") gen(multiple_codes)

reshape long multiple_codes, i(BLS_industry_title_n) j(codes)
drop if missing(multiple_codes)
leftalign
drop serno BLS_industry_title_n

destring multiple_codes, gen(multiple_codesn)
drop multiple_codes
rename multiple_codesn multiple_codes

drop codes
drop NAICS_Code_2017
rename multiple_codes NAICS_Code_2017
gen NAICS_Code_2017n = NAICS_Code_2017
replace NAICS_Code_2017n = NAICS_Code_2017*10 if NAICS_Code_2017 < 100000
replace NAICS_Code_2017n = NAICS_Code_2017*100 if NAICS_Code_2017 < 10000
replace NAICS_Code_2017n = NAICS_Code_2017*1000 if NAICS_Code_2017 < 1000
replace NAICS_Code_2017n = NAICS_Code_2017*10000 if NAICS_Code_2017 < 100
rename NAICS_Code_2017 BLS_NAICS_Code_2017
drop NAICS_Code_2017_orig

duplicates tag NAICS_Code_2017n, gen(dups)
tab dups
browse if dups > 0
drop dups
joinby NAICS_Code_2017n using 2017_NAICS_temp, unmatched(master)
* all matched
tab _merge
drop _merge
gen Walk_ID = _n
*drop NAICS_Code_2017

save "2017_BLS_NAICS_Walk", replace
* BLS_Industry_title BLS_NAICS_Code_2017 NAICS_Code_2017n NAICS_Code_2017 NAICS_Title_2017 Walk_ID
erase 2017_NAICS_temp.dta

// use "2017_BLS_NAICS_Walk", clear
// duplicates tag BLS_Industry_title, gen(dups)
// tab dups
// brows if dups > 0

// retained the old code with redundancy to avoid errors
forvalues i=2020(1)2020 {
import excel "YOUR_PATH\data\raw\BLS\O&I02_2012_2020_from_Dejan_cleaning.xlsx", sheet("`i'") firstrow clear
	if `i' !=2020 {
		replace A = B if missing(A) & !missing(B)
		replace A = C if missing(A) & !missing(C)
		replace A = D if missing(A) & !missing(D)
		gen test = strpos(A, "..")
		replace A = substr(A,1,strpos(A, "..") - 1) if regexm(A, "..") & test !=0
		leftalign
		drop B-J
		drop test
		}

drop if missing(A)
rename A BLS_Industry_title_annual
replace BLS_Industry_title_annual = strtrim(BLS_Industry_title_annual)
leftalign
gen year = `i'
order year

foreach ethnic of varlist WomenP BlackP AsianP HispanicP {
	if substr("`:type `ethnic' '",1,3) != "str" {
	gen `ethnic'n = `ethnic'
	drop `ethnic'
	}
	if substr("`:type `ethnic' '",1,3) == "str" {
	replace `ethnic' = "." if regexm(`ethnic',"­")
	destring `ethnic' , gen(`ethnic'n) force
	drop `ethnic'
	}
}

egen allmiss = rsum2(WomenPn BlackPn AsianPn HispanicPn), allmiss
drop if allmiss == .
sum
save "`i'_BLS_data_temp", replace

}

forvalues i=2020(1)2020 {
	use "`i'_BLS_data_temp", clear
		gen BLS_ID = _n
	matchit BLS_ID BLS_Industry_title_annual using "2017_BLS_NAICS_Walk.dta", idu(NAICS_Code_2017n) txtu(BLS_industry_title) sim(token) threshold(.5) override
	bysort NAICS_Code_2017n: egen max_simil = max(similscore)
	gsort NAICS_Code_2017n -similscore
	browse
	drop if max_simil != similscore
	leftalign
	drop BLS_ID
	gen year = `i'
	drop similscore
	save "`i'_BLS_data_matchit", replace
	sum
}

use "2020_BLS_data_temp", clear
// forvalues i=2018(1)2020 {
// 	append using `i'_BLS_data_temp
// }

drop allmiss
save "2020_2020_BLS_data_temp", replace
* BLS_Industry_title_annual Total WomenPn BlackPn AsianPn HispanicPn

use "2020_BLS_data_matchit", clear
// forvalues i=2018(1)2020 {
// 	append using `i'_BLS_data_matchit
// }

drop if max_simil < .75
save "2020_2020_BLS_data_matchit", replace
* year BLS_Industry_title_annual NAICS_Code_2017n BLS_Industry_title max_simil year

merge m:1 year BLS_Industry_title_annual using 2020_2020_BLS_data_temp
browse if _merge == 2
keep if _merge == 3
drop _merge
save "2020_2020_BLS_NAICS_matched_data", replace
*BLS_Industry_title_annual NAICS_Code_2017n BLS_industry_title max_simil year Total WomenPn BlackPn AsianPn HispanicPn

use "2020_2020_BLS_NAICS_matched_data", clear
gen naics = NAICS_Code_2017n
replace naics = NAICS_Code_2017n/10 if mod(NAICS_Code_2017n, 10) == 0
replace naics = NAICS_Code_2017n/100 if mod(NAICS_Code_2017n, 100) == 0
replace naics = NAICS_Code_2017n/1000 if mod(NAICS_Code_2017n, 1000) == 0
replace naics = NAICS_Code_2017n/10000 if mod(NAICS_Code_2017n, 10000) == 0
gen naics2 = naics if inrange(naics,10,99)
gen naics3 = naics if inrange(naics,100,999)
gen naics4 = naics if inrange(naics,1000,9999)
gen naics5 = naics if inrange(naics,10000,99999)
gen naics6 = naics if inrange(naics,100000,999999)
save "2020_2020_BLS_NAICS_matched_data", replace

forvalues i=2020(1)2020 {
	erase `i'_BLS_data_temp.dta
	erase `i'_BLS_data_matchit.dta
}
erase 2020_2020_BLS_data_matchit.dta
erase 2020_2020_BLS_data_temp.dta

use "DB Unique NAICS for sample", clear
*naics
gen compustat = 1
gen naics2 = naics if inrange(naics,1,99)
replace naics2 = int(naics/10) if inrange(naics,100,999)
replace naics2 = int(naics/100) if inrange(naics,1000,9999)
replace naics2 = int(naics/1000) if inrange(naics,10000,99999)
replace naics2 = int(naics/10000) if inrange(naics,100000,999999)

gen naics3 = . if inrange(naics,1,99)
replace naics3 = naics if inrange(naics,100,999)
replace naics3 = int(naics/10) if inrange(naics,1000,9999)
replace naics3 = int(naics/100) if inrange(naics,10000,99999)
replace naics3 = int(naics/1000) if inrange(naics,100000,999999)

gen naics4 = . if inrange(naics,1,999)
replace naics4 = naics if inrange(naics,1000,9999)
replace naics4 = int(naics/10) if inrange(naics,10000,99999)
replace naics4 = int(naics/100) if inrange(naics,100000,999999)

gen naics5 = . if inrange(naics,1,9999)
replace naics5 = naics if inrange(naics,10000,99999)
replace naics5 = int(naics/10) if inrange(naics,100000,999999)

gen naics6 = .
replace naics6 = naics if inrange(naics,100000,999999) & mod(naics, 10) !=0
browse
sort naics
gen comp_naics_id = _n
save "DB Unique NAICS for sample_temp", replace

forvalues i=2(1)6 {
use "DB Unique NAICS for sample_temp", clear
gen comp_naics = naics
keep naics`i' compustat comp_naics_id comp_naics
drop if missing(naics`i')
*duplicates drop naics`i', force
joinby naics`i' using "2020_2020_BLS_NAICS_matched_data", unmatched(master)
*merge 1:m naics`i' using "2020_2020_BLS_NAICS_matched_data"
table _merge
keep if _merge==3
save "naics`i'_temp", replace
}

use "naics2_temp", clear
forvalues i=2(1)6 {
	append using "naics`i'_temp"
}

sort NAICS_Code_2017n year comp_naics
gen naics_gap = comp_naics - naics
order compustat naics comp_naics naics_gap naics2 naics3 naics4 naics5 naics6 year
bysort year comp_naics: egen min_naics_gap = min(naics_gap)
drop if naics_gap != min_naics_gap
drop compustat naics_gap naics2 naics3 naics4 naics5 naics6 comp_naics_id _merge min_naics_gap
duplicates drop naics comp_naics year BLS_Industry_title_annual Total WomenPn BlackPn AsianPn HispanicPn, force
save "2020_2020_Compustat_NACIS_BLS_Merged_data", replace

forvalues i=2(1)6 {
	erase "naics`i'_temp.dta"

}
erase "DB Unique NAICS for sample_temp.dta"

**## BLS_diversity_2012_2020

clear
cd "YOUR_PATH\data\raw\BLS\"
// First execute the Stata do files BLS_diversity_2012_2016, BLS_diversity_2019_2020, and BLS_diversity_2020_2020 prior to executing this do file.

use "2017_2019_Compustat_NACIS_BLS_Merged_data", clear
rename NAICS_Code_2017n naics6digit
save "2017_2019_temp.dta", replace

use "2020_2020_Compustat_NACIS_BLS_Merged_data", clear
rename NAICS_Code_2017n naics6digit
save "2020_2020_temp.dta", replace

use "2012_2016_Compustat_NACIS_BLS_Merged_data", clear
*naics comp_naics year BLS_Industry_title_annual NAICS_Code_2012n BLS_industry_title max_simil Total WomenPn BlackPn AsianPn HispanicPn
rename NAICS_Code_2012n naics6digit
append using "2017_2019_temp.dta"
append using "2020_2020_temp.dta"
order year naics6digit naics comp_naics
sort year comp_naics naics6digit
save "2012_2020_Compustat_NACIS_BLS_Merged_data", replace
erase "2017_2019_temp.dta"
erase "2020_2020_temp.dta"

clear

**# Merge employment data on ethnicity and gender per industry from the Bureau of Labor Statistics.
use "${folder_original_databases}/BLS/2012_2020_Compustat_NACIS_BLS_Merged_data", clear
	duplicates tag comp_naics year, gen(dup)
	drop if dup>0
	drop dup

	keep year comp_naics Total WomenPn BlackPn AsianPn HispanicPn
	rename comp_naics naics // Renamed to match the variable names in the main database.
	rename year calendar_year // Renamed to match the variable names in the main database.
	rename Total total_emp_by_naics_bls
	rename WomenPn pct_emp_women_by_naics_bls
	rename BlackPn pct_emp_b_by_naics_bls
	rename AsianPn pct_emp_a_by_naics_bls
	rename HispanicPn pct_emp_h_by_naics_bls

	foreach group in "women" "b" "a" "h" {
		quietly gen prop_emp_`group'_by_naics_bls = pct_emp_`group'_by_naics_bls / 100
		assert 0<=prop_emp_`group'_by_naics_bls & prop_emp_`group'_by_naics_bls<=1 if !missing(prop_emp_`group'_by_naics_bls) // Percentages should take values between 0% and 100%.
		drop pct_emp_`group'_by_naics_bls
	}

	* Lag all the variables:
		rename calendar_year calendar_year_lag
		gen calendar_year = calendar_year_lag + 1
		drop calendar_year_lag

		foreach variab in total_emp_by_naics_bls prop_emp_women_by_naics_bls prop_emp_b_by_naics_bls prop_emp_a_by_naics_bls prop_emp_h_by_naics_bls {
			rename `variab' `variab'_lag
		}

	assert !missing(naics, calendar_year)
	duplicates report naics calendar_year
	assert `r(unique_value)'==`r(N)' // Verifies that "naics" and "calendar_year" form a unique identifier.
	sort naics calendar_year
	order calendar_year naics total_emp_by_naics_bls_lag prop_emp_women_by_naics_bls_lag prop_emp_b_by_naics_bls_lag prop_emp_a_by_naics_bls_lag prop_emp_h_by_naics_bls_lag

	save "DB Determinants of Racial Diversity - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level Merge Multiple Variables", clear
merge m:1 naics calendar_year using "DB Determinants of Racial Diversity - Temp 1", keep(match master)
erase "DB Determinants of Racial Diversity - Temp 1.dta"
drop _merge

quietly log on
	* To report in the paper the number of years.
		tab calendar_year if sample==1
	* To report in the paper the number of firm-years.
		duplicates report iss_company_id calendar_year_end
		assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique identifier.
		count if sample==1
	* To report in the paper the number of unique firms.
		preserve
			keep if sample==1
			keep gvkey
			duplicates drop
			assert !missing(gvkey)
			count
		restore
quietly log on

assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that "iss_company_id" and "calendar_year_end" form a unique identifier.
sort iss_company_id calendar_year_end

save "${folder_save_databases}/DB Determinants of Racial Diversity", replace
clear

**# Import Census data on Black population by state.
import delimited "${folder_original_databases}/census_bureau/sc-est2019-alldata6.csv", clear

preserve
	import delimited "${folder_original_databases}/census_bureau/sc-est2021-alldata6.csv", clear
	tempfile census2021
	save "`census2021'", replace
restore

merge 1:1 sumlev region division state name sex origin race age using "`census2021'", keep(match) nogenerate

* Avoid double counting (see manual)
drop if sex == 0
drop if origin == 0

foreach i in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {

	* Single characteristics
		bysort name: egen p_state_`i' = sum(popestimate`i')
			replace p_state_`i' = p_state_`i' / 1000
		bysort age: egen p_age_`i' = sum(popestimate`i')
			replace p_age_`i' = p_age_`i' / 1000
		bysort sex: egen p_sex_`i' = sum(popestimate`i')
			replace p_sex_`i' = p_sex_`i' / 1000
		bysort origin: egen p_origin_`i' = sum(popestimate`i')
			replace p_origin_`i' = p_origin_`i' / 1000
		bysort race: egen p_race_`i' = sum(popestimate`i')
			replace p_race_`i' = p_race_`i' / 1000

		bysort origin race: egen p_origin_race_`i' = sum(popestimate`i')
			replace p_origin_race_`i' = p_origin_race_`i' / 1000

	* By state
		bysort name sex: egen p_state_sex_`i' = sum(popestimate`i')
			replace p_state_sex_`i' = p_state_sex_`i' / 1000
		bysort name origin: egen p_state_origin_`i' = sum(popestimate`i')
			replace p_state_origin_`i' = p_state_origin_`i' / 1000
		gen prop_p_state_origin_`i' = p_state_origin_`i' / p_state_`i'
		bysort name race: egen p_state_race_`i' = sum(popestimate`i')
			replace p_state_race_`i' = p_state_race_`i' / 1000
		gen prop_p_state_race_`i' = p_state_race_`i' / p_state_`i'


	* By state and origin
		bysort name origin race: egen p_state_origin_race_`i' = sum(popestimate`i')
			replace p_state_origin_race_`i' = p_state_origin_race_`i' / 1000
		gen prop_p_state_origin_race_`i' = p_state_origin_race_`i' / p_state_`i'
}

save "${folder_save_databases}/census_bureau/census_diversity_state_2021.dta", replace

use "${folder_save_databases}/census_bureau/census_diversity_state_2021.dta", clear

preserve
	drop census2010pop estimatesbase2010 pop*
	duplicates drop name, force
	gsort -p_state_2019
restore

preserve
	duplicates drop age, force
	sort age
	list age p_age_2*
restore

preserve	/* 1 = Male, 2 = Female */
	duplicates drop sex, force
	sort sex
	list sex p_sex_2*
restore

preserve	/* 1 = Not Hispanic, 2 = Hispanic */
	duplicates drop origin, force
	sort origin
	list origin p_origin_2*
restore

/*
origin: 1 = Not Hispanic, 2 = Hispanic
	The key for RACE is as follows:
	1 = White Alone
	2 = Black or African American Alone
	3 = American Indian or Alaska Native Alone
	4 = Asian Alone
	5 = Native Hawaiian and Other Pacific Islander Alone
	6 = Two or more races
*/

preserve
	duplicates drop name origin race, force
	sort name origin race
restore

preserve
	duplicates drop origin race, force
	sort origin race
	list origin race p_origin_race_2*
restore

preserve
	duplicates drop origin race, force
	keep origin race p_origin_race_2*
	xpose, clear

	global var_names nh_w nh_b nh_i nh_a nh_h nh_2 h_w h_b h_i h_a h_h h_2

	forval i	= 1/12 {
		local o : word `i' of $var_names
		rename v`i' `o'
	}

	drop if nh_w ==1

	gen year = _n + 2009

	graph twoway (connect nh_b year, color(dkorange) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_i year, color(gold) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_a year, color(maroon) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_h year, color(green) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_2 year, color(blue) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_w year, color(cranberry) lwidth(medthick) msize(vsmall) msymbol(O) yaxis(2)) ///
			, title("Population in Thousands (Not Hispanics)") ///
			ylabel(0(10000)50000, labsize(*.8)	format(%6.0fc)) xlabel(2010(2)2020) ///
			ylabel(190000(5000)200000, axis(2) labsize(*.8) format(%8.0fc))

	graph twoway (connect h_b year, color(dkorange) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect h_i year, color(gold) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect h_a year, color(maroon) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect h_h year, color(green) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect h_2 year, color(blue) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect h_w year, color(cranberry) lwidth(medthick) msize(vsmall) msymbol(O) yaxis(2)) ///
			, title("Population in Thousands (Hispanics)") ///
			ylabel(0(500)3000, labsize(*.8)	format(%6.0fc)) xlabel(2010(2)2020) ///
			ylabel(40000(5000)55000, axis(2) labsize(*.8) format(%8.0fc))

	gen total_nh = nh_w+ nh_b+ nh_i+ nh_a+ nh_h+ nh_2
	gen total_h = h_w+ h_b+ h_i+ h_a+ h_h+ h_2

	foreach v in h_w h_b h_i h_a h_h h_2 {
		gen	`v'_p =	`v' / total_h * 100
		gen n`v'_p = n`v' / total_nh * 100
	}

	graph twoway (connect nh_b_p year, color(dkorange) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_i_p year, color(gold) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_a_p year, color(maroon) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_h_p year, color(green) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_2_p year, color(blue) lwidth(medthick) msize(vsmall) msymbol(O)) ///
		(connect nh_w_p year, color(cranberry) lwidth(medthick) msize(vsmall) msymbol(O) yaxis(2)) ///
			, title("Population in Thousands (Not Hispanics)") ///
			ylabel(0(5)15, labsize(*.8)	format(%6.0fc)) xlabel(2010(2)2020) ///
			ylabel(70(2)80, labsize(*.8)	format(%6.0fc) axis(2))

	window manage close graph _all

restore

**## Population by state.
use "${folder_save_databases}/census_bureau/census_diversity_state_2021.dta", clear

/*
origin: 1 = Not Hispanic, 2 = Hispanic
	The key for RACE is as follows:
	1 = White Alone
	2 = Black or African American Alone
	3 = American Indian or Alaska Native Alone
	4 = Asian Alone
	5 = Native Hawaiian and Other Pacific Islander Alone
	6 = Two or more races
*/

duplicates drop name race origin, force
* keep if race == 2
keep name race origin prop_p_state_race_2* prop_p_state_origin_* prop_p_state_origin_race_*
rename name state
gen eth = "__"
replace eth = "w" if race == 1
replace eth = "b" if race == 2
replace eth = "n" if race == 3
replace eth = "ai" if race == 4
replace eth = "p" if race == 5
save tmp.dta, replace

keep state
duplicates drop
sort state
save states.dta, replace
save tmp_races.dta, replace

* year 2010 as starting point
use tmp.dta, clear
duplicates drop state race, force
keep state eth prop_p_state_race_2010
gen year = 2010
order state year prop_p_state_race_2010
save tmp_2010.dta, replace

/*
	(w)	1 = White Alone
	(b)	2 = Black or African American Alone
	(n)	3 = American Indian or Alaska Native Alone
	(ai) 4 = Asian Alone
	(p)	5 = Native Hawaiian and Other Pacific Islander Alone
	6 = Two or more races
*/

foreach eth_code in "w" "b" "n" "ai" "p" {
	use tmp_2010.dta, clear
	keep if eth == "`eth_code'"
	rename prop_p_state_race_2010 local_pop_`eth_code'
	drop eth
	quietly merge 1:1 state using tmp_races.dta, keep(match master) nogenerate force
	save tmp_races.dta, replace
}

foreach i in 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	use states.dta, clear
	save states_`i'.dta, replace
	foreach eth_code in "w" "b" "n" "ai" "p" {
		use tmp.dta, clear
		duplicates drop state race, force
		keep state eth prop_p_state_race_`i'
		gen year = `i'
		order state year prop_p_state_race_`i'
		keep if eth == "`eth_code'"
		rename prop_p_state_race_`i' local_pop_`eth_code'
		drop eth
		quietly merge 1:1 state using states_`i'.dta, keep(match master) nogenerate force
		save states_`i'.dta, replace
	}
	use states_`i'.dta, clear
	append using tmp_races.dta
	save tmp_races.dta, replace
	erase states_`i'.dta
}

use tmp_races.dta, clear
save "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", replace

**## Population by Hispanics.
use "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", clear

foreach i in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	use tmp.dta, clear
	duplicates drop state origin, force
	keep if origin == 2
	keep state prop_p_state_origin_`i'
	gen year = `i'
	order state year prop_p_state_origin_`i'
	rename prop_p_state_origin_`i' local_pop_hl
	merge 1:1 state year using "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", keep(match using) nogenerate force
	save "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", replace
}

foreach i in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	use tmp.dta, clear
	duplicates drop state origin race, force
	keep if origin == 2 & eth == "w"
	keep state prop_p_state_origin_race_`i'
	gen year = `i'
	order state year prop_p_state_origin_race_`i'
	rename prop_p_state_origin_race_`i' local_pop_hlw
	merge 1:1 state year using "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", keep(match using) nogenerate force
	save "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", replace
}

local i 2010
foreach i in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {
	use tmp.dta, clear
	duplicates drop state origin race, force
	keep if origin == 2 & eth != "w"
	bysort state origin: egen p_state_origin_2notw_`i' = sum(prop_p_state_origin_race_`i')
	keep state p_state_origin_2notw_`i'
	duplicates drop
	gen year = `i'
	order state year p_state_origin_2notw_`i'
	rename p_state_origin_2notw_`i' local_pop_hlnw
	merge 1:1 state year using "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", keep(match using) nogenerate force
	save "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", replace
}

sort state year
save "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", replace

erase tmp.dta
erase states.dta
erase tmp_races.dta
erase tmp_2010.dta
clear

**# Add S&P 500 identifiers and Census data on Black population.

**## Add S&P 500 identifiers.

use "${folder_save_databases}/DB Determinants of Racial Diversity.dta", clear

/*
preserve
	import excel "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted.xlsx", clear firstrow sheet("S&P_500")
	gen sp_index = "500"
	save sp_tmp.dta, replace
	import excel "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted.xlsx", clear firstrow sheet("S&P_400")
	gen sp_index = "400"
	append using sp_tmp.dta
	save sp_tmp.dta, replace
	import excel "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted.xlsx", clear firstrow sheet("S&P_600")
	gen sp_index = "600"
	append using sp_tmp.dta

	rename Date date
	rename Ticker ticker
	rename CUSIP cusip
	gen sp_year = year(date)
	tab sp_year sp_index

	* rename cusip cusip_9
	* gen cusip = substr(cusip_9, 1,8)

	save "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted.dta", replace
	erase sp_tmp.dta
restore
*/

* Decision implemented: go back 1 year from 12/31 & pick valid S&P index var at that time

joinby cusip using "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted.dta", unmatched(master)
gen cusip_to_match_sp = cusip

gen one_yr_before_1231 = mdy(12,31, yofd(calendar_year_end)-1)
format %td one_yr_before_1231

foreach v in BloombergIdentifier cusip_to_match_sp date sp_index sp_year {
	capture replace `v' = . if ((one_yr_before_1231 != date) & ~mi(one_yr_before_1231)) | (mi(date))
	capture replace `v' = "" if ((one_yr_before_1231 != date) & ~mi(one_yr_before_1231)) | (mi(date))
}

duplicates drop
gsort iss_company_id calendar_year_end -sp_index
duplicates drop iss_company_id calendar_year_end, force

preserve
	gen year = year(calendar_year_end)
	duplicates drop iss_company_id year, force
	tab year sp_index
restore

rename sp_index sp_index_lag
replace sp_index_lag = "Missing" if mi(sp_index_lag)
label define order	1 500	2 400	3 600	4 Missing
encode sp_index_lag, gen(sp_index_lag_enc) label(order)
gen sp500 = sp_index_lag == "500"
gen sp400 = sp_index_lag == "400"
gen sp600 = sp_index_lag == "600"

**## Add Census data on Black population.
* Decision implemented: take july of that same year in 12/31, use 2019 for 2020
gen year = calendar_year
gen state = state_of_address

merge m:1 state year using "${folder_save_databases}/census_bureau/census_diversity_state_race_2021.dta", keep(match master) nogenerate force

foreach eth_code in "w" "b" "n" "ai" "p" "hl" "hlw" "hlnw"{
	rename local_pop_`eth_code' local_pop_`eth_code'_lag
}

assert !missing(iss_company_id, calendar_year_end)
duplicates report iss_company_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database changed to firm-calendar_year_end.
sort iss_company_id calendar_year_end

gen post_george_floyd = calendar_year_end > td(25may2020)
gen post_george_floyd_from_date = from_date > td(25may2020)

compress

save "${folder_save_databases}/DB Determinants of Racial Diversity - DP.dta", replace
clear

**# Create a database for director skills at the firm-director-action level.
use "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted", clear
	assert sp_year==year(date)
	drop sp_year
	drop BloombergIdentifier
	drop ticker 
	replace cusip = "" if cusip=="#N/A N/A"
	drop if missing(cusip)
	gen sp_ = 1

	reshape wide sp_, i(cusip date) j(sp_index) string

	foreach sp in 500 400 600 {
		quietly replace sp_`sp' = 0 if missing(sp_`sp')
	}

	assert !missing(cusip, date)
	duplicates report cusip date
	assert `r(unique_value)'==`r(N)'
	sort cusip date
	order cusip date sp_500 sp_400 sp_600

	save "DB ISSDD Director Skills - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear

assert !missing(iss_company_id, calendar_year_end, iss_person_id)
duplicates report iss_company_id calendar_year_end iss_person_id
assert `r(unique_value)'==`r(N)'
sort iss_company_id calendar_year_end iss_person_id

gen non_miss_total_psm = 0
	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		quietly replace non_miss_total_psm = non_miss_total_psm + 1 if !missing(`v')
	}

assert non_miss_total_psm==0 | non_miss_total_psm==18 // Either all variables of the Personal Skill Matrix (PSM) are missing, or none is missing.

preserve // Cross tabulates year and number of identified skills of directors by S&P index.
	keep if sample==1

	quietly count // Stores the number of observations in `r(N)'.
	local unique_firm_years = r(N)

		joinby cusip using "DB ISSDD Director Skills - Temp 1", unmatched(master) // Some observations in the master database have missing "cusip". This creates no problem, since I dropped missing "cusip" in the using database.
		erase "DB ISSDD Director Skills - Temp 1.dta"
		duplicates report iss_company_id calendar_year_end iss_person_id date
		assert `r(unique_value)'==`r(N)'
		sort iss_company_id calendar_year_end iss_person_id date

		gen days_dif = date - calendar_year_end

		gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
		bysort iss_company_id calendar_year_end iss_person_id (date): egen sum_match_window = total(match_window) if _merge==3
		bysort iss_company_id calendar_year_end iss_person_id (date): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

		foreach variab in date sp_500 sp_400 sp_600 days_dif {
			quietly replace `variab' = . if sum_match_window==0
		}

		duplicates drop // Removes duplicate observations that matched on "cusip" but did not match on the time window interval of -540 to -180 days.

		gen retain = 0
		replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the ISSDD database.
		replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
		replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
		replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

		drop if retain==0
		drop _merge days_dif match_window sum_match_window max_days_dif retain

		foreach variab in date sp_500 sp_400 sp_600 {
			rename `variab' `variab'_lag
		}

		assert !missing(iss_company_id, calendar_year_end, iss_person_id)
		duplicates report iss_company_id calendar_year_end iss_person_id
		assert `r(unique_value)'==`r(N)'
		sort iss_company_id calendar_year_end iss_person_id

	quietly count
	assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

	quietly log on
		* Distribution of firm-year-directors with identified skills by S&P index.
		tab calendar_year non_miss_total_psm, miss
		tab calendar_year non_miss_total_psm if sp_500_lag==1, miss
		tab calendar_year non_miss_total_psm if sp_400_lag==1, miss
		tab calendar_year non_miss_total_psm if sp_600_lag==1, miss
		tab calendar_year non_miss_total_psm if sp_500_lag!=1 & sp_400_lag!=1 & sp_600_lag!=1, miss
	quietly log off

	drop date_lag sp_500_lag sp_400_lag sp_600_lag
restore

drop non_miss_total_psm

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
	quietly bysort iss_company_id iss_person_id: egen sd_`v' = sd(`v') // Missing values are ignored, and the variable is non-missing when there are two or more non-missing years for a given firm-director.
}

preserve
	gen action_short = "appointed"

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		quietly bysort iss_company_id iss_person_id (calendar_year_end): gen cnm_`v' = sum(!missing(`v')) if !missing(`v') // Counts non-missing observations within each firm-director pair.
		quietly bysort iss_company_id iss_person_id (cnm_`v' calendar_year_end): gen nm_`v' = `v'[1] // Reports the first non-missing value of the Personal Score Matrix.
		drop cnm_`v'
	}

	bysort iss_company_id iss_person_id (calendar_year): gen order_firm_director = _n
	assert !missing(order_firm_director)
	bysort iss_company_id iss_person_id (calendar_year): egen min_order_firm_director = min(order_firm_director)
	keep if order_firm_director==min_order_firm_director // Changes the structure of the database from firm-year-director to firm-director, keeping the earliest observation.
	drop order_firm_director min_order_firm_director

	save "DB ISSDD Director Skills - Temp 2", replace
	clear
restore

preserve
	gen action_short = "departure"

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		quietly gen inm_`v' = !missing(`v') // Indicates whether an observation is not missing.
		quietly bysort iss_company_id iss_person_id (inm_`v' calendar_year_end): gen nm_`v' = `v'[_N] // Reports the last non-missing value of the Personal Score Matrix.
		drop inm_`v'
	}

	bysort iss_company_id iss_person_id (calendar_year): gen order_firm_director = _n
	assert !missing(order_firm_director)
	bysort iss_company_id iss_person_id (calendar_year): egen max_order_firm_director = max(order_firm_director)
	keep if order_firm_director==max_order_firm_director // Changes the structure of the database from firm-year-director to firm-director, keeping the earliest observation.
	drop order_firm_director max_order_firm_director

	save "DB ISSDD Director Skills - Temp 3", replace
	clear
restore

clear

use "DB ISSDD Director Skills - Temp 2", clear
append using "DB ISSDD Director Skills - Temp 3"
erase "DB ISSDD Director Skills - Temp 2.dta"
erase "DB ISSDD Director Skills - Temp 3.dta"

quietly log on
	* Reports the sample standard deviation of the skills for a given firm-director across all the years.
	tabstat sd_psm_leadership_yne sd_psm_ceo_yne sd_psm_cfo_yne sd_psm_international_yne sd_psm_industry_yne sd_psm_financial_yne sd_psm_technology_yne sd_psm_risk_yne sd_psm_government_yne sd_psm_audit_yne sd_psm_sales_yne sd_psm_academic_yne sd_psm_legal_yne sd_psm_human_resources_yne sd_psm_strategic_planning_yne sd_psm_operations_yne sd_psm_mergers_acquisitions_yne sd_psm_csr_sri_yne if action_short=="appointed" & sample==1, statistics(mean sd min p25 p50 p75 max count) columns(statistics) varwidth(32)
	tabstat sd_psm_leadership_yne sd_psm_ceo_yne sd_psm_cfo_yne sd_psm_international_yne sd_psm_industry_yne sd_psm_financial_yne sd_psm_technology_yne sd_psm_risk_yne sd_psm_government_yne sd_psm_audit_yne sd_psm_sales_yne sd_psm_academic_yne sd_psm_legal_yne sd_psm_human_resources_yne sd_psm_strategic_planning_yne sd_psm_operations_yne sd_psm_mergers_acquisitions_yne sd_psm_csr_sri_yne if action_short=="departure" & sample==1, statistics(mean sd min p25 p50 p75 max count) columns(statistics) varwidth(32)
	drop sd_psm_leadership_yne sd_psm_ceo_yne sd_psm_cfo_yne sd_psm_international_yne sd_psm_industry_yne sd_psm_financial_yne sd_psm_technology_yne sd_psm_risk_yne sd_psm_government_yne sd_psm_audit_yne sd_psm_sales_yne sd_psm_academic_yne sd_psm_legal_yne sd_psm_human_resources_yne sd_psm_strategic_planning_yne sd_psm_operations_yne sd_psm_mergers_acquisitions_yne sd_psm_csr_sri_yne
quietly log off

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
	assert missing(`v') if `v'!=nm_`v' // If the two variables are different, then it must be the case that the first/last observation for the Personal Skill Matrix variable is missing.
}

quietly log on
	* Reports the number of observations (firm-directors) for the Personal Skill Matrix variables for the first/last observation in the database and the first/last non-missing observation.
	tabstat psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne if action_short=="appointed" & sample==1, statistics(mean count) columns(statistics) varwidth(32)
	tabstat psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne if action_short=="departure" & sample==1, statistics(mean count) columns(statistics) varwidth(32)
	tabstat nm_psm_leadership_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_international_yne nm_psm_industry_yne nm_psm_financial_yne nm_psm_technology_yne nm_psm_risk_yne nm_psm_government_yne nm_psm_audit_yne nm_psm_sales_yne nm_psm_academic_yne nm_psm_legal_yne nm_psm_human_resources_yne nm_psm_strategic_planning_yne nm_psm_operations_yne nm_psm_mergers_acquisitions_yne nm_psm_csr_sri_yne if action_short=="appointed" & sample==1, statistics(mean count) columns(statistics) varwidth(32)
	tabstat nm_psm_leadership_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_international_yne nm_psm_industry_yne nm_psm_financial_yne nm_psm_technology_yne nm_psm_risk_yne nm_psm_government_yne nm_psm_audit_yne nm_psm_sales_yne nm_psm_academic_yne nm_psm_legal_yne nm_psm_human_resources_yne nm_psm_strategic_planning_yne nm_psm_operations_yne nm_psm_mergers_acquisitions_yne nm_psm_csr_sri_yne if action_short=="departure" & sample==1, statistics(mean count) columns(statistics) varwidth(32)
quietly log off

quietly log on
	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		gen dnm_`v' = cond(!missing(nm_`v'), 1, 0)
	}

	* Reports the proportion of non-missing observations (firm-directors) for the Personal Skill Matrix variables for the first/last non-missing observation.
	tabstat dnm_psm_leadership_yne dnm_psm_ceo_yne dnm_psm_cfo_yne dnm_psm_international_yne dnm_psm_industry_yne dnm_psm_financial_yne dnm_psm_technology_yne dnm_psm_risk_yne dnm_psm_government_yne dnm_psm_audit_yne dnm_psm_sales_yne dnm_psm_academic_yne dnm_psm_legal_yne dnm_psm_human_resources_yne dnm_psm_strategic_planning_yne dnm_psm_operations_yne dnm_psm_mergers_acquisitions_yne dnm_psm_csr_sri_yne if action_short=="appointed" & sample==1, statistics(mean count) columns(statistics) varwidth(32)
	tabstat dnm_psm_leadership_yne dnm_psm_ceo_yne dnm_psm_cfo_yne dnm_psm_international_yne dnm_psm_industry_yne dnm_psm_financial_yne dnm_psm_technology_yne dnm_psm_risk_yne dnm_psm_government_yne dnm_psm_audit_yne dnm_psm_sales_yne dnm_psm_academic_yne dnm_psm_legal_yne dnm_psm_human_resources_yne dnm_psm_strategic_planning_yne dnm_psm_operations_yne dnm_psm_mergers_acquisitions_yne dnm_psm_csr_sri_yne if action_short=="departure" & sample==1, statistics(mean count) columns(statistics) varwidth(32)

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		drop dnm_`v'
	}
quietly log off

keep company_event_id iss_company_id calendar_year_end company_name iss_country cusip isin ticker sedol gvkey iid cik gics_sub_industry gics_8_code gics_6_code gics_4_code gics_2_code primary_exchange country_of_incorporation state_of_incorporation country_of_address state_of_address filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident filter_period_year sample sample_with_financial person_company_role_event_id person_company_event_id co_person_id iss_person_id association_type merged_file director_start_date director_start_date_precision age person_cik first_name last_name middle_name person_ethnicity person_ethnicity_code ethnicity_id_type ethnicity_source photo_source gender birth_date birth_date_precision person_updated_date psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills nm_psm_leadership_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_international_yne nm_psm_industry_yne nm_psm_financial_yne nm_psm_technology_yne nm_psm_risk_yne nm_psm_government_yne nm_psm_audit_yne nm_psm_sales_yne nm_psm_academic_yne nm_psm_legal_yne nm_psm_human_resources_yne nm_psm_strategic_planning_yne nm_psm_operations_yne nm_psm_mergers_acquisitions_yne nm_psm_csr_sri_yne action_short

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills {
	order `v', last
}

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
	order nm_`v', last
}

assert !missing(iss_company_id, iss_person_id, action_short)
duplicates report iss_company_id iss_person_id action_short // The structure of the database is firm-director-action, where action can be "appointed" or "departure".
assert `r(unique_value)'==`r(N)'
sort iss_company_id iss_person_id action_short

save "${folder_save_databases}/DB ISSDD Director Skills", replace
clear

**# Identify the ethnicity of directors joining or leaving the board from the Audit Analytics database.
use "${folder_original_databases}/CRSP/CRSPQ Daily - 2021-11-02", clear
	keep date
	duplicates drop
	sort date
	bcal create "crsptrdays", from(date) maxgap(11) purpose("CRSP Trading Days") replace // Creates a trading days calendar with unique dates from CRSP.
	clear

use "${folder_save_databases}/iss/DB ISSDD Origin Firm Level", clear
	keep company_name iss_company_id gvkey iss_country country_of_incorporation gics_8_code

	assert !missing(iss_company_id)
	duplicates report iss_company_id
	assert `r(unique_value)'==`r(N)'
	sort iss_company_id
	order company_name iss_company_id gvkey iss_country country_of_incorporation gics_8_code

	save "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 1", replace
	clear

use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2021-11-05", clear
	rename *, lower
	keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
	keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.
	destring gvkey, replace

	keep gvkey linktype linkprim lpermno lpermco linkdt linkenddt

	assert !missing(gvkey, linkdt)
	duplicates report gvkey linkdt linkenddt
	assert `r(unique_value)'==`r(N)'
	sort gvkey linkdt linkenddt
	order gvkey linktype linkprim lpermno lpermco linkdt linkenddt

	save "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 2", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Origin Person Level", clear
	keep iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity person_ethnicity_code_2 person_ethnicity_2 person_ethnicity_code_3 person_ethnicity_3
	assert !missing(person_ethnicity_code, person_ethnicity)

	assert !missing(iss_person_id)
	duplicates report iss_person_id
	assert `r(unique_value)'==`r(N)' // Verifies that "iss_person_id" is a unique identifier.
	sort iss_person_id
	order iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity person_ethnicity_code_2 person_ethnicity_2 person_ethnicity_code_3 person_ethnicity_3

	save "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 3", replace
	clear

use "${folder_save_databases}/DB ISSDD Director Skills", clear
	keep iss_company_id iss_person_id action_short psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills nm_psm_leadership_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_international_yne nm_psm_industry_yne nm_psm_financial_yne nm_psm_technology_yne nm_psm_risk_yne nm_psm_government_yne nm_psm_audit_yne nm_psm_sales_yne nm_psm_academic_yne nm_psm_legal_yne nm_psm_human_resources_yne nm_psm_strategic_planning_yne nm_psm_operations_yne nm_psm_mergers_acquisitions_yne nm_psm_csr_sri_yne

	assert !missing(iss_company_id, iss_person_id, action_short)
	duplicates report iss_company_id iss_person_id action_short // The structure of the database is firm-director-action, where action can be "appointed" or "departure".
	assert `r(unique_value)'==`r(N)'
	sort iss_company_id iss_person_id action_short

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills {
		order `v', last
	}

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		order nm_`v', last
	}

	save "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 4", replace
	clear

use "${folder_save_databases}/DB Determinants of Racial Diversity", clear
	keep iss_company_id calendar_year_end board_size prop_dir_women prop_dir_b_o_identified prop_dir_b_o_board prop_dir_identified

	assert !missing(iss_company_id, calendar_year_end)
	duplicates report iss_company_id calendar_year_end
	assert `r(unique_value)'==`r(N)'
	sort iss_company_id calendar_year_end

	save "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 5", replace
	clear

use "${folder_original_databases}/Audit_Analytics/audit_plus_compliance/matched_iss_aa_director_changes_2014onwards_combined", clear

gen year_diff_event8k_to_start = year(event_date_8k) - year(director_start_date)

assert cik==cik_n
assert cik==iss_cik
drop cik_n iss_cik

assert iss_cik_director_id_str == "1" + string(cik, "%07.0f") + string(iss_person_id, "%07.0f")
drop iss_cik_director_id_str

assert !missing(eff_date_x)
gen eff_date = date(eff_date_x, "YMD")
assert !missing(eff_date)
format eff_date %td
drop eff_date_x

assert eff_year_x==year(eff_date)
drop eff_year_x

assert director_start_year==start_year
drop start_year

assert director_start_year==year(director_start_date)
drop director_start_year

assert iss_birth_year==year(birth_date)
drop iss_birth_year

assert name_suffix==substr(AA_FML_name, -length(name_suffix), .)
drop name_suffix // "NAME_SUFFIX" is a variable in Audit Analytics, but there is no suffix in ISS.

assert match8k==1 if !missing(formtype)
assert match8k==0 if missing(formtype)
drop match8k

assert file_year==year(file_date)

assert year_diff_eff == year(eff_date) - year(director_start_date)
rename year_diff_eff year_diff_eff_to_start

assert event_delay == file_date - event_date_8k
rename event_delay event_delay_file_8k

rename name aa_company_name
rename sample_source sample_source_aa_iss_match
rename AA_FML_name aa_fml_name
rename AA_FL_name aa_fl_name

drop iss_first_name iss_middle_name iss_last_name director_start_date birth_date birth_date_precision // These variables are not necessary here, as they are in the ISSDD database.

format %-10s sample_source_aa_iss_match
format %-35s aa_fml_name aa_fl_name
format %-45s aa_company_name

order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date event_date_8k eff_date file_year event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items cik iss_company_id iss_person_id

quietly log on
	* Provides summary statistics regarding the variables to be filtered in the announcements of Audit Analytics.
	tab event_delay_file_8k, miss
	tab year_diff_eff_to_start if action_short=="appointed", miss
	tab year_diff_event8k_to_start if action_short=="appointed", miss
	tab reasons if action_short=="appointed", miss
	tab reasons if action_short=="departure", miss
quietly log off

drop if event_delay_file_8k>=9 | missing(event_delay_file_8k)
drop if action_short=="appointed" 		& (	///
	reasons=="Bankruptcy/Dissolution"	| 	///
	reasons=="Change in Control"		| 	///
	reasons=="Corporate Restructuring"	| 	///
	reasons=="Merger / Acquisition"		| 	///
	reasons=="Sale of Assets/Spin-Off"	| 	///
)
drop if action_short=="departure" 					& ( ///
	reasons=="Bankruptcy/Dissolution"				|	///
	reasons=="Change in Control"					|	///
	reasons=="Corporate Restructuring"				|	///
	reasons=="Investigation (Internal or Other)"	|	///
	reasons=="Merger / Acquisition"					|	///
	reasons=="Sale of Assets/Spin-Off"				|	///
)

duplicates tag do_off_pers_key, gen(dup)
drop if dup>0 // There are a few announcements whose directors are matched to different individuals in ISS (iss_person_id).
drop dup

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action. For example, see cik==1701051 & iss_person_id==225792. According to the 8-K form filed on 2020-05-11, the director Angela Courtin was elected at the annual meeting but resigned from the board due to an inability to resolve an unforeseen professional conflict. In the database, the director shows as two different observations. One for action_short==appointed, and another one for action_short==departure.
sort iss_company_id iss_person_id file_date action_short
order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items cik iss_company_id iss_person_id

gen trad_bus_file_date = bofd("crsptrdays", file_date)
format %tbcrsptrdays trad_bus_file_date

egen miss_total = total(cond(missing(trad_bus_file_date), 1, 0))
local i = 1
while miss_total!=0 & `i'<=5 { // Only stops the loop if either there are no missing values or it goes forward more than 5 trading days.
	quietly replace trad_bus_file_date = bofd("crsptrdays", file_date + `i') if missing(trad_bus_file_date)
	quietly drop miss_total
	quietly egen miss_total = total(cond(missing(trad_bus_file_date), 1, 0))
	quietly local i = `i' + 1
}
assert !missing(trad_bus_file_date)
drop miss_total

gen trad_file_date = dofb(trad_bus_file_date, "crsptrdays")
assert !missing(trad_file_date)
format %td trad_file_date
gen diff_days = trad_file_date - file_date

quietly log on
	* Distribution of the difference between the file date and the respective trading day.
	tab diff_days, missing
quietly log off

drop trad_bus_file_date diff_days
erase "crsptrdays.stbcal"
order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items cik iss_company_id iss_person_id

merge m:1 iss_company_id using "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 1", keep(match master)
erase "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 1.dta"
assert _merge==3
drop _merge

assert !missing(iss_country, country_of_incorporation)
gen filter_us = cond(iss_country=="USA" & country_of_incorporation=="USA", 1, 0)
gen filter_has_gvkey = cond(!missing(gvkey), 1, 0)
gen filter_has_cik = cond(!missing(cik), 1, 0)
gen filter_gics_non_financial = cond(floor(gics_8_code / 1000000)!=40, 1, 0) if !missing(floor(gics_8_code / 1000000)) // 4010 represents "Banks", 4020 represents "Diversified Financials", and 4030 represents "Insurance".
	assert !missing(filter_gics_non_financial) if !missing(gics_8_code) // The dummy is not missing when "gics_8_code" is not missing.
assert !missing(file_year)
gen filter_period_year = cond(file_year>=2014 & file_year<=${last_year}, 1, 0)

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
sort iss_company_id iss_person_id file_date action_short
order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_period_year iss_person_id

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby gvkey using "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 2", unmatched(master) // Although some observations in the master database contain missing values for "gvkey", as long as there is no missing values for "gvkey" in the using database, there is no problem. This was checked earlier.
	erase "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 2.dta"

	foreach variab in linktype linkprim {
		quietly replace `variab' = "" if (missing(trad_file_date) | trad_file_date < linkdt | trad_file_date > linkenddt)
	}

	foreach variab in lpermno lpermco linkdt linkenddt {
		quietly replace `variab' = . if (missing(trad_file_date) | trad_file_date < linkdt | trad_file_date > linkenddt)
	}

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0
	assert missing(linktype, linkprim, lpermno, lpermco, linkdt, linkenddt) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) whose trading day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort iss_company_id iss_person_id file_date action_short: egen sum_valid_link = total(valid_link)
	assert sum_valid_link==1 | sum_valid_link==0 // There is at most one valid link per firm-year.
	drop if valid_link==0 & sum_valid_link==1
	drop _merge valid_link sum_valid_link

	assert !missing(iss_company_id, iss_person_id, file_date, action_short)
	duplicates report iss_company_id iss_person_id file_date action_short
	assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
	sort iss_company_id iss_person_id file_date action_short
	order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_period_year linktype linkprim lpermno lpermco linkdt linkenddt iss_person_id

quietly count // Stores the number of observations in `r(N)'.
assert `r(N)'==`num_obs' // Checks that the original number of observations is correct.

merge m:1 iss_person_id using "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 3", keep(match master)
erase "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 3.dta"
assert _merge==3
drop _merge

assert !missing(person_ethnicity_2)

foreach variab in person_ethnicity_2 person_ethnicity_3 person_ethnicity_code_2 person_ethnicity_code_3 {
	assert `variab'=="n/c"
	drop `variab'
}

gen dir_non_white = 1 if ( 				///
	person_ethnicity_code=="a" 	| 		///
	person_ethnicity_code=="b" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="i" 	| 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 			///
)
replace dir_non_white = 0 if person_ethnicity_code=="w"
assert missing(dir_non_white) if ( 		///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)

gen dir_minority = 1 if ( 				///
	person_ethnicity_code=="b" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="n" 			///
)
replace dir_minority = 0 if ( 			///
	person_ethnicity_code=="a" | 		///
	person_ethnicity_code=="i" | 		///
	person_ethnicity_code=="m" | 		///
	person_ethnicity_code=="p" | 		///
	person_ethnicity_code=="o" | 		///
	person_ethnicity_code=="w" 			///
)
assert missing(dir_minority) if ( 		///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)

gen dir_black = 1 if person_ethnicity_code=="b"
replace dir_black = 0 if ( 				///
	person_ethnicity_code=="a" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="i" 	| 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 	|		///
	person_ethnicity_code=="w" 	 		///
)
assert missing(dir_black) if ( 			///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
sort iss_company_id iss_person_id file_date action_short
order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_period_year linktype linkprim lpermno lpermco linkdt linkenddt iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity dir_non_white dir_minority dir_black

merge m:1 iss_company_id iss_person_id action_short using "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 4", keep(match master) nogenerate
erase "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 4.dta"

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
sort iss_company_id iss_person_id file_date action_short

order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_period_year linktype linkprim lpermno lpermco linkdt linkenddt iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity dir_non_white dir_minority dir_black

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills {
	order `v', last
}

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
	order nm_`v', last
}

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	joinby iss_company_id using "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 5", unmatched(master)
	erase "DB Announcements of Directors Joining or Leaving Audit Analytics - Temp 5.dta"
	duplicates report iss_company_id iss_person_id file_date action_short calendar_year_end
	assert `r(unique_value)'==`r(N)'
	sort iss_company_id iss_person_id file_date action_short calendar_year_end

	gen days_dif = calendar_year_end - file_date

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort iss_company_id iss_person_id file_date action_short (calendar_year_end): egen sum_match_window = total(match_window) if _merge==3
	bysort iss_company_id iss_person_id file_date action_short (calendar_year_end): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in calendar_year_end board_size prop_dir_women prop_dir_b_o_identified prop_dir_b_o_board prop_dir_identified days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "iss_company_id" but did not match on the time window interval of -540 to -180 days.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the Audit Analytics database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in calendar_year_end board_size prop_dir_women prop_dir_b_o_identified prop_dir_b_o_board prop_dir_identified {
		rename `variab' `variab'_lag
	}

	assert !missing(iss_company_id, iss_person_id, file_date, action_short)
	duplicates report iss_company_id iss_person_id file_date action_short
	assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
	sort iss_company_id iss_person_id file_date action_short

	order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_period_year linktype linkprim lpermno lpermco linkdt linkenddt iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity dir_non_white dir_minority dir_black

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills {
		order `v', last
	}

	foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
		order nm_`v', last
	}

	order calendar_year_end_lag board_size_lag prop_dir_women_lag prop_dir_b_o_identified_lag prop_dir_b_o_board_lag prop_dir_identified_lag, last

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

gen filter_board_size = inrange(board_size_lag, 4, 16) if !missing(board_size_lag)
gen filter_prop_dir_ident = cond(prop_dir_identified_lag>=0.7, 1, 0) if !missing(prop_dir_identified_lag)

gen sample = cond( 							///
	filter_us 					==1 	& 	///
	filter_has_gvkey 			==1 	& 	///
	filter_has_cik 				==1 	& 	///
	filter_gics_non_financial 	==1 	& 	///
	filter_board_size 			==1 	& 	///
	filter_prop_dir_ident 		==1 	& 	///
	filter_period_year 			==1 		///
, 1, 0) if 									///
	!missing(filter_us) 				& 	///
	!missing(filter_has_gvkey) 			& 	///
	!missing(filter_has_cik) 			& 	///
	!missing(filter_gics_non_financial) & 	///
	!missing(filter_board_size) 		& 	///
	!missing(filter_prop_dir_ident) 	& 	///
	!missing(filter_period_year)

quietly log on
	* Shows the number of non-missing observations for Audit Analytics per year of filing and whether the director joined or left the board.
	tab file_year action_short, miss
	tab file_year action_short if sample==1, miss
	tab file_year action_short if sample==1 & !missing(linkprim), miss
	tab file_year action_short if sample==1 & !missing(linkprim) & !missing(dir_black), miss
	tab file_year action_short if sample==1 & !missing(linkprim) & !missing(dir_black) & !missing(nm_psm_leadership_yne), miss
	tab file_year action_short if sample==1 & !missing(linkprim) & !missing(dir_black) & !missing(nm_psm_leadership_yne) & !missing(psm_leadership_yne), miss
	tab file_year action_short if sample==1 & !missing(linkprim) & !missing(dir_black) & !missing(nm_psm_leadership_yne) & !missing(psm_leadership_yne) & !missing(calendar_year_end_lag), miss

	* Provides summary statistics regarding the announcements from Audit Analytics.
	tab file_year action_short if sample==1 & !missing(linkprim) & !missing(dir_black), miss
	tab action file_year if sample==1 & !missing(linkprim) & !missing(dir_black), miss
	tab file_year dir_black if action_short=="appointed" & sample==1 & !missing(linkprim) & !missing(dir_black), row miss
	tab file_year dir_black if action_short=="departure" & sample==1 & !missing(linkprim) & !missing(dir_black), row miss
	tab file_year dir_minority if action_short=="appointed" & sample==1 & !missing(linkprim) & !missing(dir_black), row miss
	tab file_year dir_minority if action_short=="departure" & sample==1 & !missing(linkprim) & !missing(dir_black), row miss
	tab file_year dir_non_white if action_short=="appointed" & sample==1 & !missing(linkprim) & !missing(dir_black), row miss
	tab file_year dir_non_white if action_short=="departure" & sample==1 & !missing(linkprim) & !missing(dir_black), row miss

	* Reports the distribution of the days of delay and reasons that are kept in the database.
	tab event_delay_file_8k, miss
	tab year_diff_eff_to_start if action_short=="appointed", miss
	tab year_diff_event8k_to_start if action_short=="appointed", miss
	tab reasons if action_short=="appointed", miss
	tab reasons if action_short=="departure", miss
quietly log off

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
sort iss_company_id iss_person_id file_date action_short

order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident filter_period_year sample linktype linkprim lpermno lpermco linkdt linkenddt iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity dir_non_white dir_minority dir_black

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills {
	order `v', last
}

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
	order nm_`v', last
}

order calendar_year_end_lag board_size_lag prop_dir_women_lag prop_dir_b_o_identified_lag prop_dir_b_o_board_lag prop_dir_identified_lag, last

save "${folder_save_databases}/DB Announcements of Directors Joining or Leaving Audit Analytics", replace
clear

**# Generate graph of new director appointments by ethnicity on a monthly level.
use "${folder_save_databases}/DB Determinants of Racial Diversity - DP", clear // The database contains the same number of observations as "DB Determinants of Racial Diversity" for all the filters equal to one, except the year 2013, which must be kept to match director appointments in 2014.

	keep if filter_us*filter_prop_dir_ident*filter_has_gvkey*filter_has_cik*filter_gics_non_financial*filter_board_size == 1

	assert 									///
		filter_us					==1 & 	///
		filter_has_gvkey			==1 & 	///
		filter_has_cik				==1 & 	///
		filter_gics_non_financial	==1 & 	///
		filter_board_size			==1 & 	///
		filter_prop_dir_ident		==1

	keep iss_company_id calendar_year filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident filter_period_year sample

	assert !missing(iss_company_id, calendar_year)
	duplicates report iss_company_id calendar_year
	assert `r(unique_value)'==`r(N)'
	sort iss_company_id calendar_year

	save "DB Graph Director Appointments by Ethnicity and Month - Temp 1", replace
	clear

use "${folder_save_databases}/DB Announcements of Directors Joining or Leaving Audit Analytics", clear
drop filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident filter_period_year sample

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
sort iss_company_id iss_person_id file_date action_short

gen calendar_year = year(file_date) - 1 

merge m:1 iss_company_id calendar_year using "DB Graph Director Appointments by Ethnicity and Month - Temp 1", keep(match) 
	erase "DB Graph Director Appointments by Ethnicity and Month - Temp 1.dta"
	drop _merge

keep if action_short=="appointed"
keep if file_date<=td(31, Dec, 2020) // To be consistent with the other analyses of director appointments.

assert 									///
	filter_us					==1 & 	///
	filter_has_gvkey			==1 & 	///
	filter_has_cik				==1 & 	///
	filter_gics_non_financial	==1 & 	///
	filter_board_size			==1 & 	///
	filter_prop_dir_ident		==1

keep if !missing(person_ethnicity_code) & 	///
	person_ethnicity_code!="n/c" 		& 	///
	person_ethnicity_code!="n/d" 		& 	///
	person_ethnicity_code!="pnd" 		& 	///
	person_ethnicity_code!="u"

assert !missing(iss_company_id, iss_person_id)
duplicates report iss_company_id iss_person_id
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director announcement.
sort iss_company_id iss_person_id

foreach eth_code in "a" "b" "hl" "i" "m" "n" "p" "w" "o" {
	gen appoint_`eth_code' = cond(person_ethnicity_code=="`eth_code'", 1, 0)
}

gen appoint_total = cond(!missing(person_ethnicity_code), 1, 0)
gen appoint_identified = appoint_a + appoint_b + appoint_hl + appoint_i + appoint_m + appoint_n + appoint_p + appoint_w + appoint_o // I can sum because these ethnical classifications are non-overlapping.
gen appoint_ai = appoint_a + appoint_i // I can sum because these ethnical classifications are non-overlapping.
gen appoint_onw = appoint_m + appoint_n + appoint_p + appoint_o // I can sum because these ethnical classifications are non-overlapping.

gen file_year_month = mofd(file_date)
format %tm file_year_month

collapse (sum) appoint_total appoint_a appoint_b appoint_hl appoint_i appoint_m appoint_n appoint_p appoint_w appoint_o appoint_ai appoint_onw appoint_identified, by(file_year_month)

foreach eth_code in "ai" "b" "hl" "onw" "w" {
	gen p_appoint_`eth_code'_o_identified = (appoint_`eth_code' / appoint_identified) * 100
}

assert 100==round(p_appoint_ai_o_identified + p_appoint_b_o_identified + p_appoint_hl_o_identified + p_appoint_onw_o_identified + p_appoint_w_o_identified, 0.01) // The percentages should sum up to 100 after rounding with two decimal places.

graph twoway 	(connected p_appoint_hl_o_identified 	file_year_month, color(gold) 		lwidth(thin) msize(tiny) msymbol(d) lpattern(solid)) 	///
				(connected p_appoint_ai_o_identified 	file_year_month, color(cranberry) 	lwidth(thin) msize(tiny) msymbol(T) lpattern(solid)) 	///
				(connected p_appoint_onw_o_identified 	file_year_month, color(green) 		lwidth(thin) msize(tiny) msymbol(|) lpattern(solid)) 	///
				(connected p_appoint_b_o_identified 	file_year_month, color(dkorange) 	lwidth(thin) msize(tiny) msymbol(O) lpattern(solid)) 	///
				, 																																	///
				ytitle("% Director Appointments") 																									///
				ylabel(0(10)40, labsize(*.8) format(%6.0fc) grid glcolor(gs8) glpattern(dot) glwidth(thin) gmin gmax) 								///
				xlabel(648(12)732, labsize(*.8) grid glcolor(gs8) glpattern(dot) glwidth(thin) gmin gmax) 											///
				xtitle("") 																															///
				legend(label(1 "% Hisp/Latino") label(2 "% Asian/Indian") label(3 "% Other Non-White") label(4 "% Black") order(4 1 2 3)) 			///
				graphregion(color(white)) 																											///
				name(graph_perc_dir_apppoint_no_w, replace)
graph export "${folder_output}/Graphs/Director Appointments - No Whites - Percent.pdf", replace
graph export "${folder_output}/Graphs/Director Appointments - No Whites - Percent.eps", replace

window manage close graph _all

save "${folder_save_databases}/Others/DB Graph Director Appointments by Ethnicity and Month", replace
clear

**# Analyze director busyness by race.
use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear
assert !missing(iss_company_id, calendar_year_end, iss_person_id)
duplicates report iss_company_id calendar_year_end iss_person_id
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-calendar_year_end-director.
sort iss_company_id calendar_year_end iss_person_id

keep if 									/// I do not keep if "filter_period_year==1" at this point.
	filter_us 					==1 	& 	///
	filter_has_gvkey 			==1 	& 	///
	filter_has_cik 				==1 	& 	///
	filter_gics_non_financial 	==1 	& 	///
	filter_board_size 			==1 	& 	///
	filter_prop_dir_ident 		==1

gen california_av = cond(state_of_address == "California", 1 , 0) if !missing(state_of_address)

foreach v in first_name last_name middle_name person_ethnicity person_ethnicity_code birth_date birth_date_precision {
	quietly bysort iss_person_id (`v'): gen different = 1 if `v'[1]!=`v'[_N]
	assert missing(different) // These variables are constant for each director.
	drop different
}

gen num_seats = 1
collapse (sum) num_seats (mean) birth_date california_av (first) first_name last_name middle_name person_ethnicity person_ethnicity_code birth_date_precision, by(iss_person_id calendar_year_end) // This command restructures the data from firm-year-director to director-year. It does not really matter if "mean" and "first" are used, as all the observations are identical within each "iss_person_id".
order iss_person_id calendar_year_end first_name middle_name last_name birth_date birth_date_precision person_ethnicity person_ethnicity_code num_seats california_av

assert !missing(person_ethnicity_code)
gen dir_black = 1 if person_ethnicity_code=="b"
replace dir_black = 0 if ( 				///
	person_ethnicity_code=="a" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="i" 	| 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 	|		///
	person_ethnicity_code=="w" 	 		///
)
assert missing(dir_black) if ( 			///
	person_ethnicity_code=="n/c" | 		///
	person_ethnicity_code=="n/d" | 		///
	person_ethnicity_code=="pnd" | 		///
	person_ethnicity_code=="u" 			///
)

gen year = year(calendar_year_end)
	xtset iss_person_id year
		gen previous_seat = cond(!missing(L.num_seats), 1, 0)
	xtset, clear
drop year

keep if year(calendar_year_end)>=2014 // At this point we are back to "sample==1".

gen california = cond(california_av>0, 1, 0) if !missing(california_av) // All board positions must be outside California for "california" to be equal to zero.
gen post_george_floyd = cond(calendar_year_end>td(25, May, 2020), 1, 0) if !missing(calendar_year_end)
gen calendar_year = year(calendar_year_end)
gen director_busy = cond(num_seats>1, 1, 0) if !missing(num_seats)

levelsof calendar_year, local(calendar_year_levels)
foreach i of local calendar_year_levels {
	gen calendar_year_`i' = cond(calendar_year==`i', 1, 0) if !missing(calendar_year)
}

quietly log on
	* To report in the paper the number director-years.
		count if !missing(dir_black)
	* To report in the paper the number director-years conditional on a seat in the previous year.
		count if !missing(dir_black) & previous_seat==1
quietly log off

assert !missing(iss_person_id, calendar_year_end)
duplicates report iss_person_id calendar_year_end
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database changed to director-year.
sort iss_person_id calendar_year_end

save "${folder_save_databases}/Others/DB Director Busyness", replace
clear

**# Analysis of news concurrent to director appointment announcements by looking at 8-K items.
use "${folder_save_databases}/DB Announcements of Directors Joining or Leaving Audit Analytics", clear // This database contains the same number of observations as calculated by Ramesh in the matching between Audit Analytics and ISS, less observations that were excluded based on "reason", in addition to a few duplicates. Check above in the code how this database was constructed.
	keep iss_company_id file_date iss_person_id action_short
	order iss_company_id file_date iss_person_id action_short

	foreach variab in file_date iss_person_id action_short { // Only "iss_company_id" is excluded, as it is used for matching.
		rename `variab' `variab'_match
	}

	assert !missing(iss_company_id, file_date_match, iss_person_id_match, action_short_match)
	duplicates report iss_company_id file_date_match iss_person_id_match action_short_match
	assert `r(unique_value)'==`r(N)' // The structure of the database is firm-file_date_match-director-action.
	sort iss_company_id file_date_match iss_person_id_match action_short_match

	save "DB Director Appointments 8-K Items - Matching - Temp 1", replace
	clear

use "${folder_save_databases}/DB Announcements of Directors Joining or Leaving Audit Analytics", clear
	assert !missing(iss_company_id, iss_person_id, file_date, action_short)
	duplicates report iss_company_id iss_person_id file_date action_short
	assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
	sort iss_company_id iss_person_id file_date action_short

	keep iss_company_id iss_person_id file_date action_short
	order iss_company_id iss_person_id file_date action_short

	quietly count // Stores the number of observations in `r(N)'.
	local obs = r(N)

		joinby iss_company_id using "DB Director Appointments 8-K Items - Matching - Temp 1", unmatched(master)
		erase "DB Director Appointments 8-K Items - Matching - Temp 1.dta"
		assert _merge==3
		drop _merge

		assert !missing(iss_company_id, iss_person_id, file_date, action_short, file_date_match, iss_person_id_match, action_short_match)
		duplicates report iss_company_id iss_person_id file_date action_short file_date_match iss_person_id_match action_short_match
		assert `r(unique_value)'==`r(N)' // The structure of the database is now firm-director-file_date-action-file_date_match-director_match-action_match.
		sort iss_company_id iss_person_id file_date action_short file_date_match iss_person_id_match action_short_match

		local win_appoint = 180

		assert !missing(file_date_match, file_date)
		gen days_dif = file_date_match - file_date
		assert !missing(days_dif)
		keep if -(`win_appoint'-1)<=days_dif & days_dif<=0 // A director that is matched to himself/herself gets a zero, which is not dropped.

		assert action_short_match=="appointed" | action_short_match=="departure"
		gen dir_appoint = cond(action_short_match=="appointed", 1, 0)
		gen dir_depart = cond(action_short_match=="departure", 1, 0)

		bysort iss_company_id iss_person_id file_date action_short (file_date_match iss_person_id_match action_short_match): egen total_dir_appoint = total(dir_appoint)
		bysort iss_company_id iss_person_id file_date action_short (file_date_match iss_person_id_match action_short_match): egen total_dir_depart = total(dir_depart)

		gen net_dir_appoint_window = total_dir_appoint - total_dir_depart
		gen enlargement_board_window = cond(net_dir_appoint_window>0, 1, 0) if !missing(net_dir_appoint_window)

		keep iss_company_id iss_person_id file_date action_short net_dir_appoint_window enlargement_board_window
		duplicates drop // The structure of the databae is back to firm-director-file_date-action.

		egen min_file_date = min(file_date)
		gen min_file_date_window = min_file_date + (`win_appoint'-1) // The minus one results in a full window, including the first day itself.
		format %td min_file_date min_file_date_window

		foreach variab in net_dir_appoint_window enlargement_board_window {
			replace `variab' = . if file_date < min_file_date_window
		}

		drop min_file_date min_file_date_window

	quietly count
	assert `r(N)'==`obs' // Checks that the original number of observations is correct.

	save "DB Director Appointments 8-K Items - Matching - Temp 2", replace
	clear

use "${folder_save_databases}/DB Determinants of Racial Diversity - DP", clear

	keep if filter_us*filter_prop_dir_ident*filter_has_gvkey*filter_has_cik*filter_gics_non_financial*filter_board_size == 1

	replace InstOwn_Perc_lag = 1 if InstOwn_Perc_lag > 1 & ~mi(InstOwn_Perc_lag)
	replace InstOwn_Perc_0_lag = 1 if InstOwn_Perc_0_lag > 1 & ~mi(InstOwn_Perc_0_lag)
	winsor2 book_to_market_lag roa_lag rd_over_assets_lag rd_over_assets_0_lag

	gen time = calendar_year - 2013
	gen ge2017 = calendar_year >= 2017 // can do it for 2018, 2019
	egen InstOwn_Perc_0_lag_m = mean(InstOwn_Perc_0_lag)
	gen InstOwn_Perc_0_lag_dm = InstOwn_Perc_0_lag - InstOwn_Perc_0_lag_m
	egen firm_visibility_lag_m = mean(firm_visibility_lag)
	gen firm_visibility_lag_dm = firm_visibility_lag - firm_visibility_lag_m
	egen time_m = mean(time)
	gen time_dm = time - time_m

	gen has_permno = ~mi(lpermno)
	gen permno = lpermno

	assert 									///
		filter_us					==1 & 	///
		filter_has_gvkey			==1 & 	///
		filter_has_cik				==1 & 	///
		filter_gics_non_financial	==1 & 	///
		filter_board_size			==1 & 	///
		filter_prop_dir_ident		==1

	gen ln_mve_lag = ln(csho_lag * prcc_f_lag)

	keep iss_company_id ticker calendar_year datadate_lag book_to_market_lag ln_mve_lag roa_lag filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident filter_period_year sample board_size prop_dir_women prop_dir_b_o_identified prop_dir_b_o_board prop_dir_identified

	assert !missing(iss_company_id, calendar_year)
	duplicates report iss_company_id calendar_year
	assert `r(unique_value)'==`r(N)'
	sort iss_company_id calendar_year

	save "DB Director Appointments 8-K Items - Matching - Temp 3", replace
	clear

use "${folder_save_databases}/DB_Announcements_of_Directors_Joining_or_Leaving_Audit_Analytics_with_returns", clear // This database contains the same number of observations as "DB Announcements of Directors Joining or Leaving Audit Analytics" found above in the code, in addition to four variables containing returns calculated in Python.
drop filter_us filter_has_gvkey filter_has_cik filter_gics_non_financial filter_board_size filter_prop_dir_ident filter_period_year sample
drop board_size_lag prop_dir_women_lag prop_dir_b_o_identified_lag prop_dir_b_o_board_lag prop_dir_identified_lag

order do_off_pers_key sample_source_aa_iss_match aa_company_name aa_fml_name aa_fl_name file_date trad_file_date file_year event_date_8k eff_date event_delay_file_8k year_diff_eff_to_start year_diff_event8k_to_start action_short action reasons accession formtype items company_name cik gvkey iss_company_id iss_country country_of_incorporation gics_8_code linktype linkprim lpermno lpermco linkdt linkenddt iss_person_id first_name last_name middle_name gender birth_date birth_date_precision person_ethnicity_code person_ethnicity dir_non_white dir_minority dir_black

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne psm_other_skills {
	order `v', last
}

foreach v in psm_leadership_yne psm_ceo_yne psm_cfo_yne psm_international_yne psm_industry_yne psm_financial_yne psm_technology_yne psm_risk_yne psm_government_yne psm_audit_yne psm_sales_yne psm_academic_yne psm_legal_yne psm_human_resources_yne psm_strategic_planning_yne psm_operations_yne psm_mergers_acquisitions_yne psm_csr_sri_yne {
	order nm_`v', last
}

order calendar_year_end_lag, last

assert !missing(iss_company_id, iss_person_id, file_date, action_short)
duplicates report iss_company_id iss_person_id file_date action_short
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director-file_date-action.
sort iss_company_id iss_person_id file_date action_short

merge 1:1 iss_company_id iss_person_id file_date action_short using "DB Director Appointments 8-K Items - Matching - Temp 2", keep(master match)
	erase "DB Director Appointments 8-K Items - Matching - Temp 2.dta"
	assert _merge==3
	drop _merge

gen calendar_year = year(file_date) - 1

merge m:1 iss_company_id calendar_year using "DB Director Appointments 8-K Items - Matching - Temp 3", keep(match master)
	erase "DB Director Appointments 8-K Items - Matching - Temp 3.dta"
	drop _merge

	foreach variab in board_size prop_dir_women prop_dir_b_o_identified prop_dir_b_o_board prop_dir_identified {
		rename `variab' `variab'_lag
	}

assert ticker==upper(ticker)
replace ticker = regexs(1) if regexm(ticker, "^(.*)\..*$") // Discards the dot and everything after it. For example, Instructure Inc. has "ticker" value as "INST.XX2" in ISS, while in Seeking Alpha it has value "INST". One letter tickers are fine. For example, Lowes Corp.'s ticker is "L".

keep if action_short=="appointed"
keep if !missing(fd_bhar_m1p1, dir_black, book_to_market_lag, ln_mve_lag, roa_lag)
keep if file_date<=td(31, Dec, 2020)
// keep if file_date<=td(25, Nov, 2020) // We keep appointments up to six months after George Floyd's death.
// keep if file_date<=td(25, May, 2021) // We keep appointments up to one year after George Floyd's death.
// keep if file_date<=td(28, Jan, 2021) 

assert 									///
	filter_us					==1 & 	///
	filter_has_gvkey			==1 & 	///
	filter_has_cik				==1 & 	///
	filter_gics_non_financial	==1 & 	///
	filter_board_size			==1 & 	///
	filter_prop_dir_ident		==1

assert !missing(fd_car_m1p1, linkprim, lpermno, person_ethnicity_code, reasons, file_date, ticker, gics_8_code)
assert !missing(person_ethnicity_code) 	& 	///
	person_ethnicity_code!="n/c" 		& 	///
	person_ethnicity_code!="n/d" 		& 	///
	person_ethnicity_code!="pnd" 		& 	///
	person_ethnicity_code!="u"

assert !missing(iss_company_id, iss_person_id)
duplicates report iss_company_id iss_person_id
assert `r(unique_value)'==`r(N)' // The structure of the database is firm-director announcement.
sort iss_company_id iss_person_id

gen file_date_month = mofd(file_date) if !missing(file_date)
format %tm file_date_month
gen post_george_floyd 				= cond(file_date>td(25, May, 2020)									, 1, 0) if !missing(file_date)
gen post_george_floyd_s1 			= cond(file_date>td(25, May, 2020) & file_date<=td(25, Nov, 2020)	, 1, 0) if !missing(file_date)
gen post_george_floyd_s2 			= cond(file_date>td(25, Nov, 2020)									, 1, 0) if !missing(file_date)
gen post_george_floyd_q1 			= cond(file_date>td(25, May, 2020) & file_date<=td(25, Aug, 2020)	, 1, 0) if !missing(file_date)
gen post_george_floyd_q2 			= cond(file_date>td(25, Aug, 2020) & file_date<=td(25, Nov, 2020)	, 1, 0) if !missing(file_date)
gen post_george_floyd_q3 			= cond(file_date>td(25, Nov, 2020) & file_date<=td(25, Feb, 2021)	, 1, 0) if !missing(file_date)
gen post_george_floyd_q4 			= cond(file_date>td(25, Feb, 2021)									, 1, 0) if !missing(file_date)
gen post_george_floyd_3m 			= cond(file_date>td(25, May, 2020) & file_date<=td(25, Aug, 2020)	, 1, 0) if !missing(file_date)
gen post_george_floyd_rest_2020 	= cond(file_date>td(25, Aug, 2020) & file_date<=td(31, Dec, 2020)	, 1, 0) if !missing(file_date)
gen days_after_gf = max(file_date - td(25, May, 2020), 0)

assert items==subinstr(items, char(32), "", .) // There are no leading, trailing, or inside spaces.
assert !missing(items)
assert regexm(items, "5\.02")==1 // All observations contain item 5.02 ("Departure of Directors or Certain Officers; Election of Directors; Appointment of Certain Officers; Compensatory Arrangements of Certain Officers")

gen multiple_items_8k = cond(items!="5.02", 1, 0)
gen total_num_items = 1 + (length(items) - length(subinstr(items, ";", "", .))) // One semicolon means two items.
gen ln_total_num_items = ln(total_num_items)

gen no_other_mat_event = cond( 	///
	regexm(items, "8\.01")!=1 & ///
	regexm(items, "1\.01")!=1 & ///
	regexm(items, "2\.02")!=1 & ///
	regexm(items, "3\.02")!=1 & ///
	regexm(items, "2\.03")!=1 & ///
	regexm(items, "2\.01")!=1 & ///
	regexm(items, "3\.03")!=1 & ///
	regexm(items, "1\.02")!=1 & ///
	regexm(items, "3\.01")!=1 & ///
	regexm(items, "5\.01")!=1 & ///
	regexm(items, "5\.08")!=1 & ///
	regexm(items, "5\.05")!=1 & ///
	regexm(items, "2\.05")!=1 & ///
	regexm(items, "4\.01")!=1 & ///
	regexm(items, "2\.04")!=1 & ///
	regexm(items, "1\.03")!=1 & ///
	regexm(items, "2\.06")!=1 & ///
	regexm(items, "4\.02")!=1 & ///
	regexm(items, "5\.04")!=1 & ///
	regexm(items, "5\.06")!=1 	///
	, 1, 0) if !missing(items)

quietly log on
	* Firm-director announcements and items other than 5.02 in Form 8-K.
	tab multiple_items_8k, miss
		probit multiple_items_8k i.dir_black##i.post_george_floyd, vce(cluster iss_company_id)
	tab total_num_items, miss
		reg ln_total_num_items i.dir_black##i.post_george_floyd, vce(cluster iss_company_id)
	tab no_other_mat_event
		probit no_other_mat_event i.dir_black##i.post_george_floyd, vce(cluster iss_company_id)
quietly log off

gen gics_2_code = floor(gics_8_code / 1000000)
gen enlargement_board = cond(reasons=="Enlargement of Board", 1, 0) if !missing(reasons)
gen enlargement_board_both = cond(enlargement_board==1 & enlargement_board_window==1, 1, 0) if !missing(enlargement_board, enlargement_board_window)

gen dir_b = 1 if person_ethnicity_code=="b"
replace dir_b = 0 if ( 					///
	person_ethnicity_code=="a" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="i" 	| 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 	|		///
	person_ethnicity_code=="w" 	 		///
)
assert missing(dir_b) if ( 				///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)
assert dir_black==dir_b
drop dir_b

gen dir_hl = 1 if person_ethnicity_code=="hl"
replace dir_hl = 0 if ( 				///
	person_ethnicity_code=="a" 	| 		///
	person_ethnicity_code=="b" 	| 		///
	person_ethnicity_code=="i" 	| 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 	|		///
	person_ethnicity_code=="w" 	 		///
)
assert missing(dir_hl) if ( 			///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)

gen dir_ai = 1 if person_ethnicity_code=="a" | person_ethnicity_code=="i"
replace dir_ai = 0 if ( 				///
	person_ethnicity_code=="b" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 	|		///
	person_ethnicity_code=="w" 	 		///
)
assert missing(dir_ai) if ( 			///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)

gen dir_w = 1 if person_ethnicity_code=="w"
replace dir_w = 0 if ( 					///
	person_ethnicity_code=="a" 	| 		///
	person_ethnicity_code=="b" 	| 		///
	person_ethnicity_code=="hl" | 		///
	person_ethnicity_code=="i" 	| 		///
	person_ethnicity_code=="m" 	| 		///
	person_ethnicity_code=="n" 	| 		///
	person_ethnicity_code=="p" 	| 		///
	person_ethnicity_code=="o" 			///
)
assert missing(dir_w) if ( 				///
	person_ethnicity_code=="n/c" 	| 	///
	person_ethnicity_code=="n/d" 	| 	///
	person_ethnicity_code=="pnd" 	| 	///
	person_ethnicity_code=="u" 			///
)

gen dif_file_date_calendar_year_end = file_date - calendar_year_end_lag
gen dif_file_datadate_lag = file_date - datadate_lag
	quietly log on
		* Distribution of the difference between "file_date" and "calendar_year_end_lag" (ISSDD).
		sum dif_file_date_calendar_year_end, det
		* Distribution of the difference between "file_date" and "datadate_lag" (Compusat).
		sum dif_file_datadate_lag, det
	quietly log off
drop dif_file_date_calendar_year_end dif_file_datadate_lag

assert !missing(board_size_lag) if !missing(calendar_year_end_lag)
assert board_size_lag!=0
gen no_black_board_lag = cond((prop_dir_b_o_board_lag * board_size_lag)==0, 1, 0) if !missing(prop_dir_b_o_board_lag * board_size_lag)
gen at_least_one_black_board_lag = 1 - no_black_board_lag
gen dir_black_board_black = dir_black * at_least_one_black_board_lag
gen dir_black_board_no_black = dir_black * no_black_board_lag

assert !missing(no_black_board_lag, at_least_one_black_board_lag)
assert no_black_board_lag==1 if at_least_one_black_board_lag==0
assert no_black_board_lag==0 if at_least_one_black_board_lag==1

quietly log on
	* Comparison of board enlargement between Form 8-K and 180 days before the file date.
	tab net_dir_appoint_window enlargement_board_window, miss
	tab enlargement_board_window, miss
	tab enlargement_board, miss
	tab enlargement_board enlargement_board_window, miss
	tab enlargement_board_both, miss
	correl enlargement_board enlargement_board_window
quietly log off

gen miss_no_black_board_lag = cond(missing(no_black_board_lag), 1, 0)
	quietly log on
		* Distribution of Blacks on the board and the appointed director.
		tab at_least_one_black_board_lag dir_black_board_black, miss
		tab no_black_board_lag dir_black_board_no_black, miss
		* Most of the missing values for "no_black_board_lag" are because of the first year in the database.
		tab file_year miss_no_black_board_lag, miss
	quietly log off
drop miss_no_black_board_lag

bysort post_george_floyd: sum dir_black // Untabulated numbers reported in the paper.

save "${folder_save_databases}/Others/DB Director Appointments", replace
clear

**# Analysis of director appointments excluding concurrent press releases.
use "${folder_save_databases}/press_releases/all_press_releases_to_match_to_CCs", clear
	gen id_pr = _n

	gen date_pr = date(publication_date, "YMD")
	format %td date_pr
	assert !missing(date_pr)
	drop publication_date

	gen ticker = main_ticker
	replace ticker = upper(ticker)
	replace ticker = strtrim(ticker) // Removes internal consecutive spaces.
	replace ticker = stritrim(ticker) // Removes leading and trailing spaces.
	replace ticker = "" if ticker=="TRUE"
	replace ticker = "" if ticker=="NAN"
	replace ticker = subinstr(ticker, `"""', "", .)
	replace ticker = subinstr(ticker, "$", "", .)
	replace ticker = subinstr(ticker, "(", "", .)
	replace ticker = subinstr(ticker, ")", "", .)
	replace ticker = subinstr(ticker, "/", "", .)

	drop main_ticker
	drop if missing(ticker)
	format %-20s ticker
	assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
	assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".

	assert (has_diversity_regex		==0 | has_diversity_regex		==1)
	assert (diversity_subject_code	==0 | diversity_subject_code	==1)

	isid id_pr
	sort id_pr
	order id_pr ticker date_pr has_diversity_regex diversity_subject_code

	quietly sum date_pr
	local date_pr_min = r(min)

	save "DB Director Appointments - Exclude Press Releases - Temp 1", replace
	clear

use "${folder_save_databases}/Others/DB Director Appointments", clear
assert action_short=="appointed"
isid ticker file_date iss_person_id

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby ticker using "DB Director Appointments - Exclude Press Releases - Temp 1", unmatched(master)
	erase "DB Director Appointments - Exclude Press Releases - Temp 1.dta"

	assert !missing(date_pr, file_date) if _merge==3
	gen days_dif = date_pr - file_date
	gen match_window = cond(abs(days_dif)<=1, 1, 0) if _merge==3

	foreach variab in id_pr date_pr has_diversity_regex diversity_subject_code {
		replace `variab' = . if match_window==0
	}

	bysort ticker file_date iss_person_id (date_pr id_pr): egen pr_count = count(id_pr) if _merge==3 // I set "pr_count" to missing in case "ticker" does not match between the two datasets.
	bysort ticker file_date iss_person_id (date_pr id_pr): egen has_diversity_regex_max = max(has_diversity_regex)
	bysort ticker file_date iss_person_id (date_pr id_pr): egen diversity_subject_code_max = max(diversity_subject_code)

	drop _merge id_pr date_pr has_diversity_regex diversity_subject_code days_dif match_window
	duplicates drop

	assert missing(has_diversity_regex_max) if (pr_count==0 | missing(pr_count))
	assert !missing(has_diversity_regex_max) if pr_count>0 & !missing(pr_count)
	assert missing(diversity_subject_code_max) if (pr_count==0 | missing(pr_count))
	assert !missing(diversity_subject_code_max) if pr_count>0 & !missing(pr_count)

	isid ticker file_date iss_person_id

quietly count // Stores the number of observations in `r(N)'.
assert `r(N)'==`num_obs' // Checks that the original number of observations is correct.

global factiva_sample = "file_date>=`date_pr_min' & !missing(pr_count)" // Constrains the sample to after the first press release and matching tickers with Factiva.
global no_other_press_release = "(pr_count==0 | pr_count==1)"

gen no_other_press_release_var = (cond(pr_count==0 | pr_count==1), 1, 0) if ${factiva_sample}
gen no_mat_event_or_press_release = (cond(no_other_mat_event==1 | no_other_press_release_var==1), 1, 0) if !missing(no_other_mat_event, no_other_press_release_var)
gen no_mat_event_and_press_release = (cond(no_other_mat_event==1 & no_other_press_release_var==1), 1, 0) if !missing(no_other_mat_event, no_other_press_release_var)

quietly log on
	* Shows the number of observations removed based on material events according to 8-Ks and press releases.
	tab no_other_mat_event no_other_press_release_var, miss
	tab no_mat_event_or_press_release, miss
	tab no_mat_event_and_press_release, miss

	tab dir_black no_other_mat_event, column
	tab dir_black no_other_press_release_var, column
	tab dir_black no_mat_event_or_press_release, column
	tab dir_black no_mat_event_and_press_release, column
quietly log off

label variable fd_bhar_m1p1 				"BHAR"
label variable dir_black 					"Black Appoint"
label variable dir_hl 						"Hisp Appoint"
label variable dir_ai 						"Asian Appoint"
label variable dir_w 						"White Appoint"
label variable enlargement_board 			"Board Enlargement"
label variable at_least_one_black_board_lag "$\text{Black Dir}_{t-1}$"

label variable post_george_floyd 			"Post George Floyd"
label variable book_to_market_lag 			"$\text{Book-to-Market}_{t-1}$"
label variable ln_mve_lag 					"$\text{Ln(MVE)}_{t-1}$"
label variable roa_lag 						"$\text{ROA}_{t-1}$"
label variable post_george_floyd_3m 		"Post GF 3 Months"
label variable post_george_floyd_rest_2020 	"Post GF Rest of 2020"

label variable dir_black_board_black 		"$\text{Black Appoint and Black Dir}_{t-1}$"
label variable dir_black_board_no_black		"$\text{Black Appoint and No Black Dir}_{t-1}$"

save "${folder_save_databases}/Others/DB Director Appointments - Exclude Press Releases", replace
clear

**# Map NAICS to B2C classification, as of Delgado and Mills (2020).
use "${folder_original_databases}/Industry_Classification/SupplyChain_B2C_categorization_naics17_97_April2020 - 2022-04-21", clear // The US Bureau of Economic Analysis uses NAICS at a given year to prepare the input-output tables. "Comprehensive updates, which are typically conducted at 5-year intervals, tend to have a more expansive scope than annual updates and provide an opportunity to update the accounts to better reflect the evolving U.S. economy. These updates incorporate changes in definitions and classifications and statistical changes, which update the accounts through the use of new and improved estimation methods and newly available and revised source data, including the Economic Census which is used to benchmark the accounts."
	keep year
	duplicates drop // Keeps unique years.
	gen year_last = cond(!missing(year[_n + 1]), year[_n + 1], 2022) - 1 // If year is missing, the last one is the current year (2022).
	gen year_window = year_last - year + 1
	drop year_last
	save "DB B2C Classification - Delgado and Mills (2020) - Temp 1", replace
	clear

use "${folder_original_databases}/Industry_Classification/SupplyChain_B2C_categorization_naics17_97_April2020 - 2022-04-21", clear
assert ustrlen(string(naicso_id, "%9.0f"))==6 // These are all six-digit NAICS. As Delgado and Mills (2020) explain, their classification does not map perfectly into firm-level data because some firms have establishments in multiple industries in SC (supply chain) and B2C (business-to-consumer).
assert !missing(sc65, perc_supplies_to_pce)
assert sc65==0 | sc65==1
assert perc_supplies_to_pce<0.35 if sc65==1 // 0.35 is the cut-off used by the authors.
assert perc_supplies_to_pce>=0.35 if sc65==0 // 0.35 is the cut-off used by the authors.

keep naicso_id year sc65 perc_supplies_to_pce

assert !missing(naicso_id, year)
duplicates report naicso_id year
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
sort naicso_id year
order naicso_id year sc65

merge m:1 year using "DB B2C Classification - Delgado and Mills (2020) - Temp 1"
erase "DB B2C Classification - Delgado and Mills (2020) - Temp 1.dta"
assert _merge==3
drop _merge

expand year_window
bysort naicso_id year: gen order = _n
gen valid_year = year + order - 1
drop year year_window order

gen b2c_dm = 1 - sc65 if !missing(sc65)
drop sc65
rename perc_supplies_to_pce b2c_cont_dm

rename valid_year datadate_year
rename naicso_id naicsh

assert !missing(naicsh, datadate_year)
duplicates report naicsh datadate_year
assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is industry-year.
sort naicsh datadate_year
order naicsh datadate_year b2c_dm b2c_cont_dm

save "${folder_save_databases}/Others/DB B2C Classification - Delgado and Mills (2020)", replace
clear

**# Analysis of returns to conference calls.
use "${folder_original_databases}/CRSP/CRSP Daily - 2022-04-15", clear
	keep date
	duplicates drop
	sort date
	bcal create "crsptrdays", from(date) maxgap(12) purpose("CRSP Trading Days") replace // Creates a trading days calendar with unique dates from CRSP.
	clear

use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2022-04-15", clear
	rename *, lower
	keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
	keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.

	rename tic ticker
	rename gsector gics_2_code
	destring gvkey, replace
	assert !missing(gvkey) // "gvkey" is necessary to merge the conference calls to the Compustat variables.

	keep ticker gvkey linktype linkprim lpermno lpermco linkdt linkenddt gics_2_code

	assert !missing(ticker, linkdt)
	duplicates report ticker linkdt linkenddt
	assert `r(unique_value)'==`r(N)'
	sort ticker linkdt linkenddt
	order ticker gvkey linktype linkprim lpermno lpermco linkdt linkenddt gics_2_code

	save "DB Analysis of Returns to Conference Calls - Temp 1", replace
	clear

use "${folder_save_databases}/Compustat/DB Compustat", clear
	gen ln_mve = ln(csho * prcc_f)
	keep gvkey datadate book_to_market ln_mve roa naicsh

	assert !missing(gvkey, datadate)
	duplicates report gvkey datadate
	assert `r(unique_value)'==`r(N)'
	sort gvkey datadate

	save "DB Analysis of Returns to Conference Calls - Temp 2", replace
	clear

use "${folder_original_databases}/IBES/Surprise History - 2022-04-15", clear
	rename *, lower
	format %9.0fc usfirm

	keep if measure=="EPS"
	keep if fiscalp=="QTR"

	drop ticker // We use the official ticker instead ("oftic").
	drop if missing(oftic)
	drop if missing(actual)
	assert !missing(surpmean)

	assert !missing(oftic, anndats, pyear, pmon)
	gen pdate = mdy(pmon, 1, pyear) // First day of the year-month pair.
	format %td pdate
	gen dif_anndats_pdate = anndats - pdate
	bysort oftic anndats (pdate): egen min_dif_anndats_pdate = min(dif_anndats_pdate)
	drop if min_dif_anndats_pdate < 0 // Removes the whole "oftic"-"anndats" pair.
	drop if dif_anndats_pdate!=min_dif_anndats_pdate
	drop dif_anndats_pdate min_dif_anndats_pdate

	bysort oftic anndats: egen max_usfirm = max(usfirm)
	drop if usfirm!=max_usfirm // In case there are multiple "oftic"-"anndats" pairs with different values for "usfirm", keep "usfirm==1".
	drop max_usfirm

	duplicates tag oftic anndats, gen(dup)
	drop if dup>0
	drop dup

	gen sue_new = (actual - surpmean) / ((abs(actual) + abs(surpmean)) / 2)
	replace sue_new = 0 if actual==0 & surpmean==0

	gen year_quarter = qofd(mdy(pmon, 1, pyear))
	format %tq year_quarter

	egen sue_new_dec = xtile(sue_new), nquantiles(10) by(year_quarter)
	egen suescore_dec = xtile(suescore), nquantiles(10) by(year_quarter)
	gen sue_new_dec_scaled = (sue_new_dec - 1) / 9
	assert !missing(sue_new_dec, sue_new_dec_scaled)

	quietly log on
		correl sue_new_dec suescore_dec
	quietly log off

	drop sue_new_dec suescore_dec

	rename oftic ticker // Although "oftic" is used, "ticker" is the name of the variable in the conference calls database.

	assert !missing(ticker, anndats)
	duplicates report ticker anndats
	assert `r(unique_value)'==`r(N)'
	sort ticker anndats
	order ticker usfirm measure fiscalp pyear pmon year_quarter pdate anndats actual surpmean surpstdev suescore sue_new sue_new_dec_scaled

	save "DB Analysis of Returns to Conference Calls - Temp 3", replace
	clear

import_delimited "${folder_save_databases}/conference_calls/diversity_exposure_calculated_cc_level_after_GF.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear

gen date_cc = date(date, "YMD")
format %td date_cc
assert !missing(date_cc)
drop date

assert date_year == year(date_cc)
assert date_month == month(date_cc)
assert year_month == year(date_cc) * 100 + month(date_cc)
drop date_year date_month year_month

drop ticker1 // To be consistent with the director appointments database, I only match on "ticker_text".
rename ticker_text ticker // Renaming allows me to merge to the ISSDD database.

assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".
assert ticker==upper(ticker)

assert !missing(cc_id)
duplicates report cc_id
assert `r(unique_value)'==`r(N)' // The structure of the database is conference call ID.
sort cc_id
order cc_id cc ticker date_cc fyear period

gen trad_bus_date_cc = bofd("crsptrdays", date_cc)
format %tbcrsptrdays trad_bus_date_cc

egen miss_total = total(cond(missing(trad_bus_date_cc), 1, 0))
local i = 1
while miss_total!=0 & `i'<=5 { // Only stops the loop if either there are no missing values or it goes forward more than 5 trading days.
	quietly replace trad_bus_date_cc = bofd("crsptrdays", date_cc + `i') if missing(trad_bus_date_cc)
	quietly drop miss_total
	quietly egen miss_total = total(cond(missing(trad_bus_date_cc), 1, 0))
	local i = `i' + 1
}
drop miss_total

assert !missing(date_cc)
assert year(date_cc)>=2022 if missing(trad_bus_date_cc) // CRSP daily ends on December 31, 2021.
drop if missing(trad_bus_date_cc)

gen trad_cc = dofb(trad_bus_date_cc, "crsptrdays")
format %td trad_cc
gen diff_days = date_cc - trad_cc

quietly log on
	* Distribution of the difference between the date of the conference call and the respective trading day.
	tab diff_days, missing
quietly log off

drop trad_bus_date_cc diff_days
erase "crsptrdays.stbcal"

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby ticker using "DB Analysis of Returns to Conference Calls - Temp 1", unmatched(master) // Although some observations in the master database contain missing values for "ticker", as long as there is no missing values for "ticker" in the using database, there is no problem. This was checked earlier.
	erase "DB Analysis of Returns to Conference Calls - Temp 1.dta"
	assert !missing(trad_cc)

	foreach variab in linktype linkprim { // Matched only on "ticker", but not on the time interval.
		quietly replace `variab' = "" if (trad_cc < linkdt | trad_cc > linkenddt)
	}

	foreach variab in gvkey lpermno lpermco linkdt linkenddt gics_2_code { // Matched only on "ticker", but not on the time interval.
		quietly replace `variab' = . if (trad_cc < linkdt | trad_cc > linkenddt)
	}

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0
	assert missing(gvkey, linktype, linkprim, lpermno, lpermco, linkdt, linkenddt, gics_2_code) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) whose trading day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort cc_id: egen sum_valid_link = total(valid_link)
	assert sum_valid_link==1 | sum_valid_link==0 // There is at most one valid link per firm-year.
	drop if valid_link==0 & sum_valid_link==1
	drop _merge valid_link sum_valid_link

	assert !missing(cc_id)
	duplicates report cc_id
	assert `r(unique_value)'==`r(N)' // Verifies that "ticker" and "date_cc" form a unique pair.
	sort cc_id

quietly count // Stores the number of observations in `r(N)'.
assert `r(N)'==`num_obs' // Checks that the original number of observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	joinby gvkey using "DB Analysis of Returns to Conference Calls - Temp 2", unmatched(master) // It is ok to have missing "gvkey" in the master database, as long as there is no missing "gvkey" in the using database, which is the case.
	erase "DB Analysis of Returns to Conference Calls - Temp 2.dta"
	duplicates report cc_id datadate
	assert `r(unique_value)'==`r(N)'
	sort cc_id datadate

	gen days_dif = datadate - date_cc

	gen match_window = cond(days_dif<=0 & days_dif>-365, 1, 0) if _merge==3
	bysort cc_id (datadate): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (datadate): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in datadate book_to_market ln_mve roa naicsh days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in datadate book_to_market ln_mve roa {
		rename `variab' `variab'_lag
	}

	assert !missing(cc_id)
	duplicates report cc_id
	assert `r(unique_value)'==`r(N)'
	sort cc_id

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of observations is correct.

gen datadate_year = year(datadate_lag) // I use the same variable name as in the using database to be able to match the datasets.

merge m:1 naicsh datadate_year using "${folder_save_databases}/Others/DB B2C Classification - Delgado and Mills (2020)", keep(match master)
drop _merge
drop naicsh datadate_year b2c_cont_dm

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	joinby ticker using "DB Analysis of Returns to Conference Calls - Temp 3", unmatched(master) // It is ok to have missing "ticker" in the master database, as long as there is no missing "ticker" in the using database, which is the case.
	erase "DB Analysis of Returns to Conference Calls - Temp 3.dta"
	duplicates report cc_id anndats
	assert `r(unique_value)'==`r(N)'
	sort cc_id anndats

	gen days_dif = anndats - date_cc

	gen match_window = cond(days_dif<=0 & days_dif>-10, 1, 0) if _merge==3
	bysort cc_id (anndats): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (anndats): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in measure fiscalp {
		quietly replace `variab' = "" if sum_match_window==0
	}

	foreach variab in usfirm pyear pmon year_quarter pdate anndats actual surpmean surpstdev suescore sue_new sue_new_dec_scaled days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "ticker" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0

	quietly log on
	* Distribution of days between the most recent announcement and the conference call.
		tab days_dif
	quietly log off

	drop _merge days_dif match_window sum_match_window max_days_dif retain

	assert !missing(cc_id)
	duplicates report cc_id
	assert `r(unique_value)'==`r(N)'
	sort cc_id

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of observations is correct.

save "${folder_save_databases}/Others/DB Analysis of Returns to Conference Calls", replace
clear

**# Import Racial Justice and DEI data from As You Sow.
import_delimited "${folder_original_databases}/As You Sow/dei_data_dictionary.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear
	rename v1 kpi

	gen column_var_name = substr(column_name, 1, 29) // I constrain the variable name to 29 characters.
	gen column_var_label = "DEI - " + pillar_desc + " - " + metric_desc + " - W " + string(metric_weight, "%9.4f")

		format %-80s column_var_name column_var_label
		assert length(column_var_label)<=80 // Limit of 80 characters for labels.

		local var_name_set_dei
		local var_label_set_dei

		forvalues i = 1 (1) `=_N' {
			local var_name_set_dei `"`var_name_set_dei' `"`=column_var_name[`i']'"'"' // Appends the value of the variable and delimiters. Command "levelsof" does not work because it sorts the values.
			local var_label_set_dei `"`var_label_set_dei' `"`=column_var_label[`i']'"'"' // Appends the value of the variable and delimiters. Command "levelsof" does not work because it sorts the values.
		}

	drop column_var_name column_var_label

	clear // There is no need to save the database, as the values are saved in the macros.

import_delimited "${folder_original_databases}/As You Sow/rji_data_dictionary - Weights extracted from As You Sow's website.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) varnames(1) clear
	destring metric_weight, replace ignore("%") force
	replace metric_weight = metric_weight / 100

	save "DB As You Sow - Import - Temp 1", replace
	clear

import_delimited "${folder_original_databases}/As You Sow/rji_data_dictionary.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) varnames(1) clear
	rename v1 kpi
	drop if subset_desc=="Methodology"

	merge 1:1 metric_desc using "DB As You Sow - Import - Temp 1"
		erase "DB As You Sow - Import - Temp 1.dta"
		assert _merge==3 // All observations are matched in both datasets.
		drop _merge
		sort kpi

	gen column_var_name = substr(column_name, 1, 29) // I constrain the variable name to 29 characters.
	gen column_var_label = "RJ - " + pillar_desc + " - " + metric_desc // Only 80 characters are allowed for a variable label.
	replace column_var_label = "RJ - " + pillar_desc + " - " + metric_desc + " - W " + string(metric_weight, "%9.4f") if !missing(metric_weight) // Only 80 characters are allowed for a variable label.

		format %-80s column_var_name column_var_label
		assert length(column_var_label)<=80 // Limit of 80 characters for labels.

		local var_name_set_rj
		local var_label_set_rj

		forvalues i = 1 (1) `=_N' {
			local var_name_set_rj `"`var_name_set_rj' `"`=column_var_name[`i']'"'"' // Appends the value of the variable and delimiters. Command "levelsof" does not work because it sorts the values.
			local var_label_set_rj `"`var_label_set_rj' `"`=column_var_label[`i']'"'"' // Appends the value of the variable and delimiters. Command "levelsof" does not work because it sorts the values.
		}

	drop column_var_name column_var_label

	clear // There is no need to save the database, as the values are saved in the macros.

import_delimited "${folder_original_databases}/As You Sow/dei_rj_quarterly_data.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear
drop v1
format %12.0fc market_cap

foreach variab of varlist _all {
	local variab_short_name = substr("`variab'", 1, 29) // I constrain the variable name to 29 characters.
	quietly rename `variab' `variab_short_name'
}

foreach var_name_dei of local var_name_set_dei { // Parallel loop of "var_name_set_dei" and "var_label_set_dei".
	gettoken var_label var_label_set_dei: var_label_set_dei // Parses the first input from the macro list and puts the remaining list of inputs back to the macro.
	label variable `var_name_dei' "`var_label'"
}

foreach var_name_rj of local var_name_set_rj { // Parallel loop of "var_name_set_rj" and "var_label_set_rj".
	gettoken var_label var_label_set_rj: var_label_set_rj // Parses the first input from the macro list and puts the remaining list of inputs back to the macro.
	label variable `var_name_rj' "`var_label'"
}

gen double dei_pct_score_check = 0

	foreach variab of varlist dei_a_* {
		local l_`variab': variable label `variab'
		quietly replace dei_pct_score_check = dei_pct_score_check + (cond(!missing(`variab'), `variab', 0) * real(substr("`l_`variab''", -6, .)))
	}

	quietly log on
		* Checks the formula for "dei_pct_score", according to instructions from As You Sow's website.
		count if abs(dei_pct_score - (dei_pct_score_check)) > 0.005 & !missing(dei_pct_score_check) // The observation that does not match is probably an error.
	quietly log off

drop dei_pct_score_check

assert raw_rji_score == 								///
	rji_a_1_1_statement_rj			* 1 + 				///
	rji_a_1_2_statement_pl			* 1 + 				///
	rji_a_2_1_ceo_resp				* 1 + 				///
	rji_a_2_2_blck_empl_input		* 1 + 				///
	rji_a_3_1_names_vtms_pol_vlnc	* 1 + 				///
	rji_a_3_2_states_blm			* 1 + 				///
	rji_a_3_3_call_for_cj_rfrm		* 1 + 				///
	rji_a_3_4_ack_sys_racism		* 1 + 				///
	rji_a_3_5_ident_antiracist		* 1 + 				///
	rji_b_4_1_dei_intrnl_dept		* 5 + 				///
	rji_b_4_2_dei_ldr_ttle			* 5 + 				///
	rji_b_5_1_workforce_comp		* 5 + 				///
	rji_b_5_2_pay_eqty_data_rpt		* 5 + 				///
	rji_b_5_3_promotion				* 5 + 				///
	rji_b_5_4_recruitment			* 5 + 				///
	rji_b_5_5_retention				* 5 + 				///
	rji_b_5_6_explct_dvrsty_goal	* 5 + 				///
	rji_b_5_7_eeo_data_pub			* 5 + 				///
	rji_b_5_8_supply_chain_divrse	* 5 + 				///
	rji_b_6_1_cmty_eng_rj			* 5 + 				///
	rji_b_6_2_rj_donations			* 5 + 				///
	rji_b_6_3_hate_spch_accnt		* 5 + 				///
	rji_b_7_1_acknwdg_ej			* 5 + 				///
	rji_b_7_2_abides_ej_regs_sinc	* 5 + 				///
	rji_b_7_3_env_fines_penalties	* 5 + 				///
	rji_b_7_4_neg_effects_bipoc_c	* 5 if !missing( 	///
		rji_a_1_1_statement_rj, 						///
		rji_a_1_2_statement_pl, 						///
		rji_a_2_1_ceo_resp, 							///
		rji_a_2_2_blck_empl_input, 						///
		rji_a_3_1_names_vtms_pol_vlnc, 					///
		rji_a_3_2_states_blm, 							///
		rji_a_3_3_call_for_cj_rfrm, 					///
		rji_a_3_4_ack_sys_racism, 						///
		rji_a_3_5_ident_antiracist, 					///
		rji_b_4_1_dei_intrnl_dept, 						///
		rji_b_4_2_dei_ldr_ttle, 						///
		rji_b_5_1_workforce_comp, 						///
		rji_b_5_2_pay_eqty_data_rpt, 					///
		rji_b_5_3_promotion, 							///
		rji_b_5_4_recruitment, 							///
		rji_b_5_5_retention, 							///
		rji_b_5_6_explct_dvrsty_goal, 					///
		rji_b_5_7_eeo_data_pub, 						///
		rji_b_5_8_supply_chain_divrse, 					///
		rji_b_6_1_cmty_eng_rj, 							///
		rji_b_6_2_rj_donations, 						///
		rji_b_6_3_hate_spch_accnt, 						///
		rji_b_7_1_acknwdg_ej, 							///
		rji_b_7_2_abides_ej_regs_sinc, 					///
		rji_b_7_3_env_fines_penalties, 					///
		rji_b_7_4_neg_effects_bipoc_c)

gen year_quarter_str = string(yyyy) + qtr
gen year_quarter = quarterly(year_quarter_str, "YQ")
format %tq year_quarter
drop yyyy qtr year_quarter_str

sort year_quarter
egen period = group(year_quarter)

isid company_id year_quarter
sort company_id year_quarter
bysort company_id (year_quarter): gen quarters_per_company = _N
order year_quarter period company_id quarters_per_company

save "${folder_save_databases}/As You Sow/DB As You Sow - Import", replace
clear

**# Merge As You Sow to independent variables.
use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2022-08-29", clear
	rename *, lower
	format conm %-45s
	keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
	keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.
	destring gvkey, replace
	rename gsector gics_2_code

	keep conm tic gvkey cusip lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code
	order conm tic gvkey cusip lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code

	assert !missing(linkdt)
	assert !missing(tic)

	isid tic linkdt // Ticker is not missing and is unique for each linking time window.
	isid gvkey linkdt // Gvkey is not missing and is unique for each linking time window.
	isid lpermno linkdt // Permno is not missing and is unique for each linking time window.

	sort tic linkdt
	rename tic ticker
	rename lpermno permno
	rename lpermco permco

	save "DB As You Sow - Merge Independent Variables - Temp 1", replace
	clear

use "${folder_original_databases}/Compustat/Compustat - 2022-10-12" if 	///
	consol 	== 	"C" 	& 												/// Imposes consolidated financial statements.
	datafmt == 	"STD" 	& 												/// Imposes standardized data format.
	indfmt 	== 	"INDL" 	& 												/// Imposes industrial firms.
	curcd 	== 	"USD" 													/// Imposes currency to be US Dollars.
, clear

	assert popsrc=="D" // Imposes domestic firms (USA, Canada & ADRs).

	destring naics, replace // "naics" is numeric in the Bureau of Labor Statistics database.
	destring gvkey, replace // "gvkey" is numeric in ISSDD.

	duplicates tag gvkey fyear, gen(dup)
	drop if dup>0 // There is only one firm for which the "gvkey"-"fyear" pair is not unique.
	drop dup

	assert !missing(datadate, fyear)
	gen fyear_test = cond(month(datadate)>=6, year(datadate), year(datadate) - 1)
	assert fyear_test==fyear // This commands checks the variable "fyear" based on datadate.
	drop fyear_test

	isid gvkey fyear
	sort gvkey fyear

	xtset gvkey fyear
		gen firm_visibility = ln(at)
		gen roa = ib / ((at + L.at) / 2)
		gen book_to_market = ceq / (csho * prcc_f)
	xtset, clear

	keep gvkey datadate firm_visibility roa book_to_market naicsh
	order gvkey datadate firm_visibility roa book_to_market naicsh

	isid gvkey datadate
	sort gvkey datadate

	save "DB As You Sow - Merge Independent Variables - Temp 2", replace
	clear

use "${folder_original_databases}/Thomson_Reuters/wrds_stock_ownership/WRDS Thomson Reuters Stock Ownership - 2022-10-19", clear
	gen InstOwn_Perc_check = InstOwn / (shrout * 1000)
	assert float(InstOwn_Perc)==float(InstOwn_Perc_check)
	drop InstOwn_Perc_check

	assert missing(InstOwn_Perc) if (missing(shrout) | shrout==0) // "InstOwn_Perc" is missing only when either "shrout" is missing or zero.
	gen shrout_zero_miss = cond((missing(shrout) | shrout==0), 1, 0)

	keep rdate cusip InstOwn_HHI InstOwn_Perc shrout_zero_miss
	assert 0<=InstOwn_HHI & InstOwn_HHI<=1 if !missing(InstOwn_HHI)
	assert 0<=InstOwn_Perc if !missing(InstOwn_Perc) // According to the manual there are three reasons for institutional ownership being greater than 100%: 1) short positions are not reported, 2) shared investment discretion by multiple asset managers, and 3) issues with stock splits.

	assert !missing(rdate)
	gen day_month_string = substr(string(rdate, "%td"), 1, 5)
	label define order_day_month 	///
		1 "31mar" 					///
		2 "30jun" 					///
		3 "30sep" 					///
		4 "31dec"
	encode day_month_string, gen(day_month) label(order_day_month)

	quietly log on
		* Report the distribution of the day-months of the file date.
		tab day_month, miss
	quietly log off

	drop day_month day_month_string

	assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
	rename cusip cusip_8

	isid cusip_8 rdate
	sort cusip_8 rdate
	order cusip_8 rdate InstOwn_Perc InstOwn_HHI

	save "DB As You Sow - Merge Independent Variables - Temp 3", replace
	clear

use "${folder_original_databases}/Thomson_Reuters/s34 Master File/Institutional Holdings - s34 Master File - 2022-10-19", clear
	drop if missing(cusip) // "cusip" is the variable I use as the security identifier.

	assert !missing(cusip, mgrno, rdate, fdate)
	duplicates report cusip mgrno rdate fdate
	assert `r(unique_value)'==`r(N)' // Verifies that "cusip", "mgrno", "rdate", and "fdate" form a unique identifier. According to the manuals available from WRDS, "rdate" represents the effective ownership date, whereas the "fdate" represents the vintage date at which the shares outstanding are valid. Because Thomson Reuters' 13F data carries forward institutional reports for up to 8 quarters, a given tuple "cusip"-"mgrno"-"rdate" can have multiple "fdate".
	sort cusip mgrno rdate fdate

	bysort cusip mgrno rdate (fdate): egen min_fdate = min(fdate)
	format %td min_fdate
	keep if fdate==min_fdate // I follow Ben-David et al. (2021) and keep the first "fdate" (the first vintage) for a given tuple "cusip"-"mgrno"-"rdate". Keeping the first instead of the last "fdate" also results in institutional ownership much closer to the aggregate institutional ownership data available on WRDS.
	drop min_fdate

	assert !missing(cusip, mgrno, rdate)
	duplicates report cusip mgrno rdate
	assert `r(unique_value)'==`r(N)'
	sort cusip mgrno rdate

	gen year_rdate = year(rdate)
	gen mgrname_stand = mgrname
	replace mgrname_stand = upper(mgrname_stand) // Capitalizes the string variable.
	replace mgrname_stand = strtrim(mgrname_stand) // Removes internal consecutive spaces.
	replace mgrname_stand = stritrim(mgrname_stand) // Removes leading and trailing spaces.
	assert !missing(mgrname_stand)

	assert !missing(mgrno)
	gen d_blackrock = ( 	/// I follow Ben-David et al. (2020).
		mgrno== 9385 | 		///
		mgrno==11386 | 		///
		mgrno==12588 | 		///
		mgrno==39539 | 		///
		mgrno==56790 | 		///
		mgrno==91430 		///
	)
	gen d_vanguard = (mgrno==90457)
	gen d_ssga = (mgrno==81540)
	gen d_big_3 = d_blackrock + d_vanguard + d_ssga
	assert d_big_3==0 | d_big_3==1 // There is no overlap among the Big Three classification.

	quietly log on
		* Shows the distribution of the combination of Manager Number - Year of the Report Date - Manager Name.
		foreach investor in blackrock vanguard ssga {
			groups mgrno year_rdate mgrname_stand if d_`investor'==1, sepby(mgrno)
		}
		tab d_big_3, miss
	quietly log off

	drop mgrname_stand year_rdate

	gen double prop_shares = cond(!missing(shrout2), shares / (shrout2 * 1000), shares / (shrout1 * 1000000)) // "shrout2" and "shrout1" are not constant within each "cusip"-"rdate" pair. Therefore, the proportion of shares owned has to be calculated before aggregating the data at "cusip"-"rdate". Because "shrout2" is more precise than "shrout1", I use the former whenever its value is not missing.
	assert !missing(shares) // The "prop_shares" is only missing because of the denominator (zero or missing) and never because of the numerator.

	foreach investor in blackrock vanguard ssga big_3 {
		quietly gen double prop_shares_`investor' = cond(d_`investor'==1, prop_shares, .)
	}

	collapse (sum) inst_own=prop_shares inst_own_blackrock=prop_shares_blackrock inst_own_vanguard=prop_shares_vanguard inst_own_ssga=prop_shares_ssga inst_own_big_3=prop_shares_big_3 (max) d_blackrock d_vanguard d_ssga d_big_3 (count) non_miss_prop_shares=prop_shares non_miss_prop_shares_blackrock=prop_shares_blackrock non_miss_prop_shares_vanguard=prop_shares_vanguard non_miss_prop_shares_ssga=prop_shares_ssga non_miss_prop_shares_big_3=prop_shares_big_3, by(cusip rdate)

	assert !missing(non_miss_prop_shares) & non_miss_prop_shares>=0
	gen all_shrout_zero_miss = cond(non_miss_prop_shares==0, 1, 0) // Keep in mind that "prop_shares" was missing only because of the denominator (zero or missing).
	assert !missing(inst_own)
	assert inst_own==0 if all_shrout_zero_miss==1
	replace inst_own = . if all_shrout_zero_miss==1 // I only set "inst_own" to missing if all values of "prop_shares" were missing for that particular "cusip"-"rdate". This is an analogous treatment to institutional investors that manage less than $100 million.
	drop non_miss_prop_shares

	foreach investor in blackrock vanguard ssga big_3 {
		assert d_`investor'==0 | d_`investor'==1
		assert !missing(non_miss_prop_shares_`investor') & non_miss_prop_shares_`investor'>=0
		quietly gen all_shrout_zero_miss_`investor' = cond(non_miss_prop_shares_`investor'==0, 1, 0)
		assert !missing(inst_own_`investor')
		assert inst_own_`investor'==0 if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // It is zero, but should be missing.
		quietly replace inst_own_`investor' = . if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // There was at least one 13F form from the investor, but the proportion of shares owned by it were all missing.
		assert inst_own_`investor'==0 if d_`investor'==0 & all_shrout_zero_miss==1 // It is zero, but should be missing.
		quietly replace inst_own_`investor' = . if d_`investor'==0 & all_shrout_zero_miss==1 // There was no 13F form from the investor and the proportion of shares owned by all shareholders were missing.
		drop non_miss_prop_shares_`investor' d_`investor'
	}

	drop all_shrout_zero_miss all_shrout_zero_miss_blackrock all_shrout_zero_miss_vanguard all_shrout_zero_miss_ssga all_shrout_zero_miss_big_3

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		gen miss_inst_`variab' = cond(missing(inst_`variab'), 1, 0) // If the underlying variable is missing in this database, its value should not be replaced with zero after merging.
	}

	assert !missing(rdate)
	gen day_month_string = substr(string(rdate, "%td"), 1, 5)
	label define order_day_month 	///
		1 "31mar" 					///
		2 "30jun" 					///
		3 "30sep" 					///
		4 "31dec"
	encode day_month_string, gen(day_month) label(order_day_month)

	quietly log on
		* Report the distribution of the day-months of the file date.
		tab day_month, miss
	quietly log off

	drop day_month day_month_string

	assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
	rename cusip cusip_8

	rename rdate rdate_big_3
	isid cusip_8 rdate_big_3
	sort cusip_8 rdate_big_3

	isid cusip_8 rdate_big_3
	sort cusip_8 rdate_big_3
	order cusip_8 rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3

	save "DB As You Sow - Merge Independent Variables - Temp 4", replace
	clear

import_delimited "${folder_save_databases}/conference_calls/diversity_exposure_calculated_cc_level_after_GF.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear
// import_delimited "${folder_save_databases}/conference_calls/diversity_exposure_over_time_all_CCs.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear // Includes data before George Floyd's death.

	gen date_cc = date(date, "YMD")
	format %td date_cc
	assert !missing(date_cc)
	drop date

	assert date_year == year(date_cc)
	assert date_month == month(date_cc)
	assert year_month == year(date_cc) * 100 + month(date_cc)
	drop date_year date_month year_month

	isid cc_id
	sort cc_id

	drop ticker1 // To be consistent with the director appointments database, I only match on "ticker_text".
	rename ticker_text ticker // Renaming allows me to merge to the master database.

	assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
	assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".
	assert ticker==upper(ticker)
	drop if missing(ticker)

	duplicates tag ticker date_cc, gen(dup)
	drop if regexm(cc, "quick-version") & dup>0 // Some of the conference calls transcripts are issued earlier than other versions with "Quick Version" in the title.
	drop dup

	duplicates tag ticker date_cc, gen(dup)
	drop if dup>0 // In case the "cc"-"date_cc" pair is still not unique, drop all duplicates.
	drop dup

	rename period quarter_cc

	isid ticker date_cc
	sort ticker date_cc
	order cc_id cc ticker date_cc fyear quarter_cc

	save "DB As You Sow - Merge Independent Variables - Temp 5", replace
	clear

* Obtains unique period identifiers.
	use "${folder_save_databases}/As You Sow/DB As You Sow - Import", clear
	isid company_id year_quarter
	keep year_quarter
	duplicates drop
	isid year_quarter
	sort year_quarter
	gen year_quarter_order = _n

	quietly count
	local total_year_quater = r(N)

	save "DB As You Sow - Merge Independent Variables - Temp 6", replace
	clear

* Obtains "primary_symbol".
	use "${folder_save_databases}/As You Sow/DB As You Sow - Import", clear
	keep company_id year_quarter primary_symbol
	isid company_id year_quarter
	save "DB As You Sow - Merge Independent Variables - Temp 7", replace
	clear

* Obtains unique company identifiers.
	use "${folder_save_databases}/As You Sow/DB As You Sow - Import", clear
	isid company_id year_quarter
	keep company_id
	duplicates drop
	isid company_id
	sort company_id

* Creates a balanced panel with only identifiers.
	expand `total_year_quater'
	bysort company_id: gen year_quarter_order = _n
	merge m:1 year_quarter_order using "DB As You Sow - Merge Independent Variables - Temp 6"
	erase "DB As You Sow - Merge Independent Variables - Temp 6.dta"
	assert _merge==3
	drop _merge year_quarter_order
	isid company_id year_quarter
	sort company_id year_quarter

* Adds ticker identifiers for missing periods.
	merge 1:1 company_id year_quarter using "DB As You Sow - Merge Independent Variables - Temp 7"
	erase "DB As You Sow - Merge Independent Variables - Temp 7.dta"
	assert _merge!=2 // No observation is added.
	drop _merge
	gen primary_symbol_origin = primary_symbol

	egen total_miss = total(missing(primary_symbol))
		while total_miss>0 { // While there are still missing values, continue the loop.
			bysort company_id (year_quarter): replace primary_symbol = primary_symbol[_n+1] if missing(primary_symbol) // Backtracks ticker when it is missing using the first non-missing.
			bysort company_id (year_quarter): replace primary_symbol = primary_symbol[_n-1] if missing(primary_symbol) // Forwardtracks ticker when it is missing using the last non-missing.
			drop total_miss
			egen total_miss = total(missing(primary_symbol))
		}
	drop total_miss

	duplicates tag primary_symbol year_quarter, gen(dup)
	gen dup_dummy = cond(dup>0, 1, 0) if !missing(dup)
	bysort company_id (year_quarter): egen max_dup_dummy = max(dup_dummy)
	replace primary_symbol = primary_symbol_origin if max_dup_dummy==1 // In cases of non-unique observations, do not back/forward track ticker.
	drop dup dup_dummy max_dup_dummy

	assert primary_symbol==primary_symbol_origin if !missing(primary_symbol_origin)
	drop primary_symbol_origin

	drop if missing(primary_symbol) // These observations are dropped to be able to get unique ticker-year_quarters.

	isid primary_symbol year_quarter
	isid company_id year_quarter
	sort company_id year_quarter

	save "DB As You Sow - Merge Independent Variables - Temp 8", replace
	clear

use "DB As You Sow - Merge Independent Variables - Temp 8", clear
erase "DB As You Sow - Merge Independent Variables - Temp 8.dta"
merge 1:1 company_id year_quarter using "${folder_save_databases}/As You Sow/DB As You Sow - Import"
assert _merge!=2
drop _merge

gen first_day_year_quarter = dofq(year_quarter) // Setting it as a first day of the quarter is safer to avoid possible reverse causality.
format %td first_day_year_quarter

isid primary_symbol year_quarter
rename primary_symbol ticker
isid ticker first_day_year_quarter
sort ticker first_day_year_quarter
order year_quarter first_day_year_quarter

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	joinby ticker using "DB As You Sow - Merge Independent Variables - Temp 1", unmatched(master) // There are no missing tickers.
	erase "DB As You Sow - Merge Independent Variables - Temp 1.dta"

	gen outside_window = cond((first_day_year_quarter < linkdt | first_day_year_quarter > linkenddt), 1, 0)

		foreach variab in conm linktype linkprim cusip {
			quietly replace `variab' = "" if outside_window==1
		}

		foreach variab in gvkey permno permco linkdt linkenddt gics_2_code {
			quietly replace `variab' = . if outside_window==1
		}

	drop outside_window

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0 // Duplicates only happen when observations from both datasets matched.
	assert missing(conm, gvkey, cusip, permno, permco, linktype, linkprim, linkdt, linkenddt, gics_2_code) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) based on "ticker" whose day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort ticker first_day_year_quarter (linkdt): egen sum_valid_link = total(valid_link)
	drop if valid_link==0 & sum_valid_link>0 // In case of at least one match, drop instances of no valid link because the day does not fit the link window interval.
	drop valid_link sum_valid_link

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort ticker first_day_year_quarter (linkdt): egen sum_valid_link = total(valid_link)
	assert sum_valid_link==0 | sum_valid_link==1 // There is at most one match per "ticker"-"first_day_year_quarter".
	drop valid_link sum_valid_link _merge

	isid ticker first_day_year_quarter
	sort ticker first_day_year_quarter

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	joinby gvkey using "DB As You Sow - Merge Independent Variables - Temp 2", unmatched(master) // It is ok to have missing "gvkey" in the master database, as long as there is no missing "gvkey" in the using database, which is the case.
	erase "DB As You Sow - Merge Independent Variables - Temp 2.dta"
	duplicates report ticker first_day_year_quarter datadate
	assert `r(unique_value)'==`r(N)'
	sort ticker first_day_year_quarter datadate

	gen days_dif = datadate - first_day_year_quarter

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort ticker first_day_year_quarter (datadate): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker first_day_year_quarter (datadate): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in datadate firm_visibility roa book_to_market naicsh days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in datadate firm_visibility roa book_to_market {
		rename `variab' `variab'_lag
	}

	isid ticker first_day_year_quarter
	sort ticker first_day_year_quarter

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of observations is correct.

isid ticker year_quarter
sort ticker year_quarter

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "DB As You Sow - Merge Independent Variables - Temp 3", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "DB As You Sow - Merge Independent Variables - Temp 3.dta"
	duplicates report ticker year_quarter rdate // Some of the "rdate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-rdate form a unique identifier.
	sort ticker year_quarter rdate

	assert day(rdate + 1)==1 if !missing(rdate) // The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.
	assert ( 				///
		month(rdate)==03 | 	///
		month(rdate)==06 | 	///
		month(rdate)==09 | 	///
		month(rdate)==12 	///
	) if !missing(rdate) 	// The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.

	gen year_quarter_inst_inv = qofd(rdate)
	format %tq year_quarter_inst_inv
	gen quart_dif = year_quarter_inst_inv - year_quarter

	gen match_window = cond(quart_dif<=-2 & quart_dif>-6, 1, 0) if _merge==3
	bysort ticker year_quarter (year_quarter_inst_inv): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker year_quarter (year_quarter_inst_inv): egen max_quart_dif = max(quart_dif) if match_window==1 & sum_match_window>1

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss year_quarter_inst_inv quart_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if quart_dif==max_quart_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 year_quarter_inst_inv quart_dif match_window sum_match_window max_quart_dif retain

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss {
		rename `variab' `variab'_lag
	}

	gen InstOwn_Perc_0_lag = cond((missing(InstOwn_Perc_lag) & !missing(cusip) & shrout_zero_miss_lag!=1), 0, InstOwn_Perc_lag) // I assume that form 13F is comprehensive and, therefore, substitute "InstOwn_Perc_lag" by zero, as long as "cusip" is not missing and "shrout" is neither zero or missing in the Thomson Reuters database.
	gen InstOwn_Perc_miss_lag = cond(missing(InstOwn_Perc_lag) & InstOwn_Perc_0_lag==0, 1, 0) if !missing(InstOwn_Perc_0_lag)
	drop shrout_zero_miss_lag

	isid ticker year_quarter
	sort ticker year_quarter

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "DB As You Sow - Merge Independent Variables - Temp 4", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "DB As You Sow - Merge Independent Variables - Temp 4.dta"
	duplicates report ticker year_quarter rdate_big_3 // Some of the "rdate_big_3" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-rdate_big_3 form a unique identifier.
	sort ticker year_quarter rdate_big_3

	assert day(rdate_big_3 + 1)==1 if !missing(rdate_big_3) // The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.
	assert ( 						///
		month(rdate_big_3)==03 | 	///
		month(rdate_big_3)==06 | 	///
		month(rdate_big_3)==09 | 	///
		month(rdate_big_3)==12 		///
	) if !missing(rdate_big_3) 		// The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.

	gen year_quarter_big_3 = qofd(rdate_big_3)
	format %tq year_quarter_big_3
	gen quart_dif_big_3 = year_quarter_big_3 - year_quarter

	gen match_window = cond(quart_dif_big_3<=-2 & quart_dif_big_3>-6, 1, 0) if _merge==3
	bysort ticker year_quarter (year_quarter_big_3): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker year_quarter (year_quarter_big_3): egen max_quart_dif_big_3 = max(quart_dif_big_3) if match_window==1 & sum_match_window>1

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 year_quarter_big_3 quart_dif_big_3 {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if quart_dif_big_3==max_quart_dif_big_3 & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 year_quarter_big_3 quart_dif_big_3 match_window sum_match_window max_quart_dif_big_3 retain

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 {
		rename `variab' `variab'_lag
	}

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		quietly gen inst_`variab'_0_lag = cond((missing(inst_`variab'_lag) & !missing(cusip) & miss_inst_`variab'_lag!=1), 0, inst_`variab'_lag) // I assume that form 13F is comprehensive and, therefore, substitute the variables by zero, as long as "cusip" is not missing and the variables are not missing in the Thomson Reuters database.
		quietly gen inst_`variab'_miss_lag = cond(missing(inst_`variab'_lag) & inst_`variab'_0_lag==0, 1, 0) if !missing(inst_`variab'_0_lag)
		drop miss_inst_`variab'_lag
	}

	isid ticker year_quarter
	sort ticker year_quarter

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

preserve // Creates macros with all numeric and string variables in the database, except "ticker".

	use "DB As You Sow - Merge Independent Variables - Temp 5", clear
		ds, has(type numeric) // Identifies all numeric variables in the database.
		local cc_num_var_list `r(varlist)'

		ds, has(type string) // Identifies all string variables in the database.
		local cc_str_var_list `r(varlist)'
		local ticker "ticker"
		local cc_str_var_list_no_ticker: list cc_str_var_list - ticker // Removes the variable "ticker" from the list.

restore

isid ticker first_day_year_quarter
sort ticker first_day_year_quarter

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	joinby ticker using "DB As You Sow - Merge Independent Variables - Temp 5", unmatched(master) // "ticker" is not missing in either database.
	erase "DB As You Sow - Merge Independent Variables - Temp 5.dta"
	duplicates report ticker first_day_year_quarter date_cc
	assert `r(unique_value)'==`r(N)'
	sort ticker first_day_year_quarter date_cc

	gen days_dif = date_cc - first_day_year_quarter

	gen match_window = cond(days_dif<=0 & days_dif>=-365, 1, 0) if _merge==3
	bysort ticker first_day_year_quarter (date_cc): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker first_day_year_quarter (date_cc): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in `cc_str_var_list_no_ticker' {
		quietly replace `variab' = "" if sum_match_window==0
	}

	foreach variab in `cc_num_var_list' days_dif { // I added "days_dif" to the list of variables.
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "ticker" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in `cc_str_var_list_no_ticker' `cc_num_var_list' {
		local variab_trunc = substr("`variab'", 1, 28) // Some of the variable names are too long to add "_lag".
		rename `variab' `variab_trunc'_lag
	}

	isid ticker first_day_year_quarter
	sort ticker first_day_year_quarter

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of observations is correct.

isid ticker year_quarter
sort ticker year_quarter

save "${folder_save_databases}/As You Sow/DB As You Sow - Merge Independent Variables", replace
clear

**# Analyze the As You Sow data.
use "${folder_save_databases}/As You Sow/DB As You Sow - Merge Independent Variables", clear

sort year_quarter company_id
drop period // I recreated the period variable based on the balanced panel now.
egen period = group(year_quarter)
sort company_id year_quarter
order year_quarter first_day_year_quarter company_id ticker period quarters_per_company

drop if period==1 // There are three reasons why we dropped these observations. First, because the conference calls database starts after GF's death (2020-05-26), there are only a few matches to the first day of the first quarter of the As You Sow database (2020-07-01). Second, when using lags, the first period is more than one quarter before the second period. Third, there is a difference in methodology when calculating the "raw_rji_score".

isid company_id year_quarter
sort company_id year_quarter

egen company_id_numeric = group(company_id)
xtset company_id_numeric period

foreach var in rji_b_4_1_dei_intrnl_dept rji_b_4_2_dei_ldr_ttle rji_b_5_6_explct_dvrsty_goal rji_b_5_8_supply_chain_divrse rji_b_6_1_cmty_eng_rj rji_b_6_2_rj_donations {
	gen `var'_b = cond(`var'>0, 1, 0) if !missing(`var') // Creates binary variables for the action-oriented measures.
}

assert float(InstOwn_Perc_lag)==float(inst_own_lag) if !missing(InstOwn_Perc_lag, inst_own_lag)
assert float(InstOwn_Perc_0_lag)==float(inst_own_0_lag) if !missing(InstOwn_Perc_0_lag, inst_own_0_lag)
drop inst_own_lag inst_own_0_lag

foreach variab in InstOwn_Perc_lag InstOwn_Perc_0_lag inst_own_blackrock_lag inst_own_blackrock_0_lag inst_own_vanguard_lag inst_own_vanguard_0_lag inst_own_ssga_lag inst_own_ssga_0_lag inst_own_big_3_lag inst_own_big_3_0_lag {
	replace `variab' = 1 if `variab'>1 & !missing(`variab')
}

* These commands winsorize the variables at 1% each tail.
foreach variab in book_to_market_lag roa_lag {
	quietly gen `variab'_w = `variab'
	quietly sum `variab', detail
	quietly replace `variab'_w = `r(p99)' if `variab'>`r(p99)' & !missing(`variab')
	quietly replace `variab'_w = `r(p1)' if `variab'<`r(p1)' & !missing(`variab')
	quietly local var_label: variable label `variab'
	quietly label variable `variab'_w "`var_label'"
	quietly drop `variab'
	display as text "Winsorizing at 1% each tail the variable `variab'"
}

gen dummy_disclosure_lag = cond(diver_exposure_sent_lag>0, 1, 0) if !missing(diver_exposure_sent_lag)
gen dummy_bow_lag = cond(r_n_init_tok_to_n_diss_tok_lag>0, 1, 0) if !missing(r_n_init_tok_to_n_diss_tok_lag)
gen init_bow_lag = cond(cc_with_init_lag==1 | dummy_bow_lag==1, 1, 0) if !missing(cc_with_init_lag, dummy_bow_lag)

gen diver_exposure_sent_perc_lag = diver_exposure_sent_lag * 100
gen dummy_sp_500 = cond(sp_500_values=="1", 1, cond(sp_500_values=="0", 0, .))

gen sum_dummy_disclosure_lag 			= L0.dummy_disclosure_lag 			+ L1.dummy_disclosure_lag 			+ L2.dummy_disclosure_lag 			+ L3.dummy_disclosure_lag
gen sum_diver_exposure_sent_perc_lag 	= L0.diver_exposure_sent_perc_lag 	+ L1.diver_exposure_sent_perc_lag 	+ L2.diver_exposure_sent_perc_lag 	+ L3.diver_exposure_sent_perc_lag
gen sum_init_bow_lag 					= L0.init_bow_lag 					+ L1.init_bow_lag 					+ L2.init_bow_lag 					+ L3.init_bow_lag

gen raw_rji_score_no_envir = raw_rji_score - ( 	///
	rji_b_7_1_acknwdg_ej			* 5 + 		///
	rji_b_7_2_abides_ej_regs_sinc	* 5 + 		///
	rji_b_7_3_env_fines_penalties	* 5 + 		///
	rji_b_7_4_neg_effects_bipoc_c	* 5 )

save "${folder_save_databases}/As You Sow/DB As You Sow - Analysis", replace
clear

**# Merge press releases and Link Table.
use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2022-08-29", clear
	rename *, lower
	format conm %-45s
	keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
	keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.
	destring gvkey, replace
	rename gsector gics_2_code

	keep conm tic gvkey lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code
	order conm tic gvkey lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code

	assert !missing(linkdt)
	assert !missing(tic)

	isid tic linkdt // Ticker is not missing and is unique for each linking time window.
	isid gvkey linkdt // Gvkey is not missing and is unique for each linking time window.
	isid lpermno linkdt // Permno is not missing and is unique for each linking time window.

	sort tic linkdt
	rename tic ticker
	rename lpermno permno
	rename lpermco permco

	save "DB Merge Factiva and Link Table - Temp 1", replace
	clear

import_delimited "${folder_original_databases}/../../Outputs/press_releases/to_match_w_CRSP.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) varnames(1) clear

gen main_ticker_check = ""
	replace main_ticker_check = ticker_text if missing(main_ticker_check)
	replace main_ticker_check = djticker if missing(main_ticker_check)
	replace main_ticker_check = ric if missing(main_ticker_check)
	assert main_ticker==main_ticker_check
drop main_ticker_check

rename publication_date publication_date_string
gen publication_date=date(publication_date_string, "YMD")
format %td publication_date
drop publication_date_string

rename main_ticker ticker

isid an
sort an
order an publication_date cofcode ticker ticker_text djticker ric

quietly count // Stores the number of observations in `r(N)'.
local unique_an = r(N)

	joinby ticker using "DB Merge Factiva and Link Table - Temp 1", unmatched(master) // There are missing tickers in the master database. However, this creates no problem because there are no missing tickers in the using database.
	erase "DB Merge Factiva and Link Table - Temp 1.dta"

	gen outside_window = cond((publication_date < linkdt | publication_date > linkenddt), 1, 0)

		foreach variab in conm linktype linkprim {
			quietly replace `variab' = "" if outside_window==1
		}

		foreach variab in gvkey permno permco linkdt linkenddt gics_2_code {
			quietly replace `variab' = . if outside_window==1
		}

	drop outside_window

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0 // Duplicates only happen when observations from both datasets matched.
	assert missing(conm, gvkey, permno, permco, linktype, linkprim, linkdt, linkenddt, gics_2_code) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) based on "ticker" whose day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort an: egen sum_valid_link = total(valid_link)
	drop if valid_link==0 & sum_valid_link>0 // In case of at least one match, drop instances of no valid link because the day does not fit the link window interval.
	drop valid_link sum_valid_link

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort an: egen sum_valid_link = total(valid_link)
	assert sum_valid_link==0 | sum_valid_link==1 // There is at most one match per accession number ("an").
	drop valid_link sum_valid_link _merge

quietly count
assert `r(N)'==`unique_an' // Checks that the original number of observations is correct.

isid an
sort an

drop if missing(ticker)
drop if missing(linktype, linkprim)

save "${folder_save_databases}/Press_Releases/DB Merge Factiva and Link Table", replace
clear

**# Obtain abnormal returns from press releases.
use "${folder_save_databases}/press releases event study CRSP data/es4 - Updated Sample - 2022-10-08", clear
	rename d trading_day
	keep if trading_day>=-1 & trading_day<=1 // Looks only at the [-1,+1] window.
	bysort an (trading_day): gen total_trading_days = _N
	drop if total_trading_days!=3 // Looks only at the [-1,+1] window.
	drop total_trading_days

	gen double ab_ret = ret - decret
	gen double ln_ret_over_decret = ln((1 + ret) / (1 + decret)) // The log of the product is equal to the sum of the logs.

	foreach variab in ret decret {
		gen double one_plus_`variab' = 1 + `variab'
		gen double compound_one_plus_`variab' = one_plus_`variab'[_n-1] * one_plus_`variab'[_n] * one_plus_`variab'[_n+1] if trading_day==0
	}

	gen double bhar_check = ln(compound_one_plus_ret) - ln(compound_one_plus_decret)
	drop one_plus_ret compound_one_plus_ret one_plus_decret compound_one_plus_decret

	assert !missing(trading_day)
	collapse (sum) ab_ret ln_ret_over_decret (mean) bhar_check (count) count_total=trading_day count_ab_ret=ab_ret count_ln_ret_over_decret=ln_ret_over_decret, by(an)

	foreach variab in ab_ret ln_ret_over_decret {
		replace `variab' = . if count_`variab'<count_total // Requires all daily returns to be non-missing within the window. The "bhar_check" variable does not need replacement because there is just one value per "an", and when it is missing, the mean is missing.
	}

	rename ab_ret car
	rename ln_ret_over_decret bhar

	assert float(bhar)==float(bhar_check)
	drop bhar_check

	keep an car bhar
	isid an

	save "DB Press Releases with Abnormal Returns - Temp 1", replace
	clear

use "${folder_save_databases}/Press_Releases/DB Merge Factiva and Link Table", clear
isid an

merge 1:1 an using "DB Press Releases with Abnormal Returns - Temp 1"
erase "DB Press Releases with Abnormal Returns - Temp 1.dta"
assert _merge==1 | _merge==3 // There is no additional "an" coming from the using database.
drop _merge

drop publication_date ticker ticker_text djticker ric // These variables are dropped to avoid duplicates in the merger later.

save "${folder_save_databases}/Press_Releases/DB Press Releases with Abnormal Returns", replace
clear

**# Obtain independent variables for the press releases analysis.
use "${folder_original_databases}/Compustat/Compustat - 2021-11-01" if 	///
	consol 	== 	"C" 	& 												/// Imposes consolidated financial statements.
	datafmt == 	"STD" 	& 												/// Imposes standardized data format.
	indfmt 	== 	"INDL" 	& 												/// Imposes industrial firms.
	curcd 	== 	"USD" 													/// Imposes currency to be US Dollars.
, clear

	assert popsrc=="D" // Imposes domestic firms (USA, Canada & ADRs).

	destring sic, replace // "sic" is numeric in the Fama-French 48 Industry Classification database.
	destring naics, replace // "naics" is numeric in the Bureau of Labor Statistics database.
	destring gvkey, replace // "gvkey" is numeric in ISSDD.

	duplicates tag gvkey fyear, gen(dup)
	drop if dup>0 // There is only one firm for which the "gvkey"-"fyear" pair is not unique.
	drop dup

	assert !missing(datadate, fyear)
	gen fyear_test = cond(month(datadate)>=6, year(datadate), year(datadate) - 1)
	assert fyear_test==fyear // This commands checks the variable "fyear" based on datadate.
	drop fyear_test

	isid gvkey fyear
	sort gvkey fyear

	xtset gvkey fyear
		gen book_to_market = ceq / (csho * prcc_f)
		gen ln_mve = ln(csho * prcc_f)
		gen roa = ib / ((at + L.at) / 2)
	xtset, clear

	keep gvkey datadate book_to_market ln_mve roa naicsh

	isid gvkey datadate
	sort gvkey datadate

	save "DB Obtain Independent Variables for Press Releases - Temp 1", replace
	clear

use "${folder_save_databases}/Press_Releases/PRs_textual_attributes", clear
format %-60s subject_codes

foreach variab in publication_date modification_date {
	rename `variab' `variab'_string
	gen `variab' = date(`variab'_string, "YMD")
	format %td `variab'
	drop `variab'_string
}

rename publication_datetime publication_datetime_string
gen double publication_datetime = clock(publication_datetime_string,"YMD hms") // Double increases precision.
format %tc publication_datetime
drop publication_datetime_string

gen double publication_time = hms(hh(publication_datetime),mm(publication_datetime),ss(publication_datetime)) // Double increases precision.
format %tcHH:MM:SS.sss publication_time

gen publication_date_check = dofc(publication_datetime)
	format %td publication_date_check
	assert publication_date==publication_date_check
drop publication_date_check

order an subject_codes publication_datetime publication_date publication_time modification_date publisher_name main_ticker ticker_text DJTicker RIC

isid an
sort an

merge 1:1 an using "${folder_save_databases}/Press_Releases/DB Press Releases with Abnormal Returns"
assert _merge==1 | _merge==3 // There is no additional "an" coming from the using database.
drop _merge

order an subject_codes publication_datetime publication_date publication_time modification_date publisher_name main_ticker ticker_text DJTicker RIC cofcode

local graph_name_pr_hour // The macro starts empty, and each time the macro loops over, a graph name is added.
local bar_num 10 25 30 40 50 100
foreach i of local bar_num {
	#delimit;
		quietly histogram publication_time, freq xtitle("Press Release Hour")
		title(`i' Bars)
		ylabel(#3, format(%12.0fc))
		xlabel(0(7200000)86400000, alternate format(%tcHH))
		tline(14400000 72000000, lpattern(dash) lcolor(edkblue)) //NYSE and NASDAQ Pre-market trading starts at 4:00am, After-hours end at 8:00pm.
		tline(34200000 57600000, lpattern(shortdash)) // NYSE and NASDAQ Regular trading is between 9:30am and 4:00pm.
		bin(`i')
		nodraw
		name(pr_hour_`i', replace);
	#delimit cr
	local graph_name_pr_hour `graph_name_pr_hour' pr_hour_`i'
}
graph combine `graph_name_pr_hour', title("Frequency of Press Releases Over Time")

window manage close graph _all

quietly count // Stores the number of observations in `r(N)'.
local unique_firm_years = r(N)

	joinby gvkey using "DB Obtain Independent Variables for Press Releases - Temp 1", unmatched(master) // It is ok to have missing "gvkey" in the master database, as long as there is no missing "gvkey" in the using database, which is the case.
	erase "DB Obtain Independent Variables for Press Releases - Temp 1.dta"
	duplicates report an datadate
	assert `r(unique_value)'==`r(N)'
	sort an datadate

	gen days_dif = datadate - publication_date

	gen match_window = cond(days_dif<=0 & days_dif>-365, 1, 0) if _merge==3
	bysort an (datadate): egen sum_match_window = total(match_window) if _merge==3
	bysort an (datadate): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in datadate book_to_market ln_mve roa naicsh days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in datadate book_to_market ln_mve roa {
		rename `variab' `variab'_lag
	}

	isid an
	sort an

quietly count
assert `r(N)'==`unique_firm_years' // Checks that the original number of observations is correct.

save "${folder_save_databases}/Press_Releases/DB Obtain Independent Variables for Press Releases with Regex", replace
clear

**# Merge determinants of exposure to racial diversity (conference calls).
use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2022-08-29", clear
	rename *, lower
	format conm %-45s
	keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
	keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.
	destring gvkey, replace
	rename gsector gics_2_code

	gen gics_2_code_n = ""
		quietly replace gics_2_code_n = "Energy" 					 if gics_2_code == 10
		quietly replace gics_2_code_n = "Materials" 				 if gics_2_code == 15
		quietly replace gics_2_code_n = "Industrials" 				 if gics_2_code == 20
		quietly replace gics_2_code_n = "Consumer Discretionary" 	 if gics_2_code == 25
		quietly replace gics_2_code_n = "Consumer Staples" 			 if gics_2_code == 30
		quietly replace gics_2_code_n = "Health Care" 				 if gics_2_code == 35
		quietly replace gics_2_code_n = "Financials" 				 if gics_2_code == 40
		quietly replace gics_2_code_n = "Information Technology" 	 if gics_2_code == 45
		quietly replace gics_2_code_n = "Telecommunication Services" if gics_2_code == 50
		quietly replace gics_2_code_n = "Utilities" 				 if gics_2_code == 55
		quietly replace gics_2_code_n = "Real Estate" 				 if gics_2_code == 60
	quietly replace gics_2_code_n = gics_2_code_n + " (" + string(gics_2_code, "%02.0f") + ")" if !missing(gics_2_code_n)
	encode gics_2_code_n, gen(gics_2_code_i)
	drop gics_2_code gics_2_code_n

	keep conm tic gvkey cusip lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code_i
	order conm tic gvkey cusip lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code_i

	assert !missing(linkdt)
	assert !missing(tic)

	isid tic linkdt // Ticker is not missing and is unique for each linking time window.
	isid gvkey linkdt // Gvkey is not missing and is unique for each linking time window.
	isid lpermno linkdt // Permno is not missing and is unique for each linking time window.

	sort tic linkdt
	rename tic ticker
	rename lpermno permno
	rename lpermco permco

	save "Merge Determinants of Exposure to Racial Diversity - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear // I start with all firm-year-directors (non-directors were dropped previously).
	isid iss_company_id calendar_year_end iss_person_id
	sort iss_company_id calendar_year_end iss_person_id

	bysort iss_company_id calendar_year_end (iss_person_id): egen median_director_age_check = median(age)
	assert median_director_age==median_director_age_check // Because "age" is not correctly measured, then "median_director_age" is also incorrect.
	drop median_director_age_check median_director_age stdev_director_age
	drop age // The variable "age" is not correctly measured. For example, see first_name=="Timothy" & last_name=="Cook" & company_name=="Apple Inc.". The director's age is identical, independently of the "calendar_year_end". The same is true for first_name=="Elon" & last_name=="Musk". Another example is iss_company_id==513234 & calendar_year_end==td(31, Dec, 2015). While Robert Finocchio, Maria Klawe, and Nancy Handel all were born in 1952 according to "birth_date", their age is reported as 69, 63, and 63, respectively. The proxy statement filed on 2015-03-27 shows that all three were 63 years old on March 16, 2015.

	assert !missing(calendar_year_end)
	gen age_calendar_year_end = cond(calendar_year_end>=birthday(birth_date, year(calendar_year_end)), year(calendar_year_end) - year(birth_date), year(calendar_year_end) - year(birth_date) - 1) if !missing(birth_date) // The formula calculates "age_calendar_year_end" for any date, in case we use a different time stamp than December 31 later.
	assert !missing(age_calendar_year_end) if !missing(birth_date)

	gen dir_age_72_plus = cond(72<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)

	collapse (sum) num_dir_age_72_plus=dir_age_72_plus (count) dir_age_non_miss=age_calendar_year_end board_size=iss_person_id, by(iss_company_id calendar_year_end) // Changes the structure of the database from firm-year-director to firm-year. In the "collapse" command, "(count)" reports the number of non-missing observations within each "firm-year". "iss_person_id" is never missing and, therefore, "board_size" is the total number of observations within each "firm-year".

	assert !missing(dir_age_non_miss, board_size) & dir_age_non_miss<=board_size
	gen prop_dir_age_non_miss = dir_age_non_miss / board_size
	assert !missing(prop_dir_age_non_miss)
	replace num_dir_age_72_plus = . if prop_dir_age_non_miss < 0.7 // I impose that the age of at least 70% of the directors must be identified, otherwise the variable is missing.

	gen prop_dir_age_72_plus_o_ident = num_dir_age_72_plus / dir_age_non_miss
	assert !missing(prop_dir_age_72_plus_o_ident) if !missing(num_dir_age_72_plus)
	drop num_dir_age_72_plus

	drop dir_age_non_miss prop_dir_age_non_miss board_size

	isid iss_company_id calendar_year_end
	sort iss_company_id calendar_year_end
	order iss_company_id calendar_year_end prop_dir_age_72_plus_o_ident

	save "Merge Determinants of Exposure to Racial Diversity - Temp 2", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear // I start with all firm-years.

	gen num_individuals_total = ///
		num_individuals_a 	+ 	///
		num_individuals_b 	+ 	///
		num_individuals_hl 	+ 	///
		num_individuals_i 	+ 	///
		num_individuals_m 	+ 	///
		num_individuals_n 	+ 	///
		num_individuals_nc 	+ 	///
		num_individuals_o 	+ 	///
		num_individuals_p 	+ 	///
		num_individuals_pnd + 	///
		num_individuals_u 	+ 	///
		num_individuals_w

	rename number_women_directors num_directors_women
	rename num_women_neos num_neos_women
	rename num_women_individuals num_individuals_women

	rename board_size num_directors_total
	rename num_neos_total num_neos_total
	rename num_individuals_total num_individuals_total

	foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
		assert num_individuals_`group'<=(num_directors_`group' + num_neos_`group') if !missing(num_individuals_`group', num_directors_`group', num_neos_`group') // An executive that is on the board is both a director and a named executive officer (NEO).
		assert num_individuals_`group'>=num_directors_`group' if !missing(num_individuals_`group', num_directors_`group')
		assert num_individuals_`group'>=num_neos_`group' if !missing(num_individuals_`group', num_neos_`group')
	}

	keep calendar_year_end iss_company_id country_of_address country_of_incorporation state_of_address hq_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total // According to the ISS Directors Diversity dictionary, "hq_address" contains the address of the company's headquarters/primary operations. The same dictionary describes "num_individuals" as the distinct number of directors and named executive officers who partially or primarily identify as the ethnicity type.
	order calendar_year_end iss_company_id country_of_address country_of_incorporation state_of_address hq_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
	replace country_of_address = "" if country_of_address=="n/a"
	replace state_of_address = "" if state_of_address=="n/a"
	replace hq_address = "" if hq_address=="n/c"
	assert missing(hq_address) if missing(country_of_address) // If the "country_of_address" is missing, then "hq_address" is missing.
	drop if missing(country_of_address)
	assert country_of_address=="USA" // Data on the headquarter's address is only collected for U.S. firms. In addition, non-U.S. headquarter addresses would result in the wrong matching with the Zip Codes database.
	keep if country_of_incorporation=="USA" // I only keep U.S. firms for this analysis.
	drop country_of_address country_of_incorporation

	gen hq_address_edited = hq_address
	replace hq_address_edited = regexs(1) + "-" + regexs(2) if regexm(hq_address,"(^.*[0-9][0-9][0-9][0-9][0-9]).([0-9][0-9][0-9][0-9])$") // Changes any character for a dash in a 9 digit zip code at the end of the string.
	format %-60s hq_address hq_address_edited
	gen zipcode = substr(hq_address_edited, strrpos(hq_address_edited, " ") + 1, .) // Extracts all the characters after the last space. The "+1" prevents the last space from being part of the new string.
	replace zipcode = regexs(1) if regexm(zipcode, "(^[0-9][0-9][0-9][0-9][0-9])-[0-9][0-9][0-9][0-9]$") // Extracts only the first five of a nine digit zip code.
	drop if regexm(zipcode,"^[0-9][0-9][0-9][0-9][0-9]$")!=1 // There is no point in keeping observations with zip codes that will not match to the Zip Codes database.
	destring zipcode, replace
	format %05.0f zipcode
	drop hq_address hq_address_edited
	order calendar_year_end iss_company_id zipcode state_of_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total

	merge m:1 zipcode using "${folder_save_databases}/Zip_Codes/DB ZC Origin Zip Code Level", keep(match) // It is not helpful to keep zip codes where no company is located, or zip codes in which it is not possible to identify latitude and longitude.
	drop _merge
	assert state_of_address==zip_statefullname // The name of the state where the firm is headquartered matches both databases.
	drop state_of_address zip_city zip_county zip_state zip_statefullname

	quietly count // Stores the number of observations in `r(N)'.
	local unique_firm_years = r(N)

		assert !missing(calendar_year_end, iss_company_id)
		duplicates report calendar_year_end iss_company_id
		assert `r(unique_value)'==`r(N)' // Verifies that firm-year forms a unique identifier.
		sort calendar_year_end iss_company_id
		order calendar_year_end iss_company_id zipcode zip_latitude zip_longitude filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
		save "Merge Determinants of Exposure to Racial Diversity - Temp 3", replace

			* These commands do not affect the "Merge Determinants of Exposure to Racial Diversity - Temp 1" database.
			bysort calendar_year_end (iss_company_id): gen firm_j_order = _n

			foreach variab in iss_company_id zipcode zip_latitude zip_longitude filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total {
				rename `variab' `variab'_j // "firm_j" is the paired firm.
			}

			save "Merge Determinants of Exposure to Racial Diversity - Temp 4", replace
			clear

		use "Merge Determinants of Exposure to Racial Diversity - Temp 3", clear
		drop filter_gics_non_financial num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
		bysort calendar_year_end (iss_company_id): gen year_freq = _N
		expand year_freq // The "expand" command allows us to create a matrix that is (N)x(N) within each year, as opposed to (N)x(N) for the full sample. Notice that I could create a (N)x(N-1) matrix, but matching firm_i to itself prevents the firm from being dropped from the database if there is not a single firm within the specified radius. This is important, as the variable "SUPPLY_DIR" should be missing if the zip code is missing/incorrect, but should be zero if there is not a single firm around the specified distance.
		drop year_freq
		bysort calendar_year_end iss_company_id: gen firm_j_order = _n
		erase "Merge Determinants of Exposure to Racial Diversity - Temp 3.dta"

		merge m:1 calendar_year_end firm_j_order using "Merge Determinants of Exposure to Racial Diversity - Temp 4"
		erase "Merge Determinants of Exposure to Racial Diversity - Temp 4.dta"
		assert _merge==3
		drop _merge
		drop firm_j_order

		assert !missing(calendar_year_end, iss_company_id, iss_company_id_j)
		duplicates report calendar_year_end iss_company_id iss_company_id_j
		assert `r(unique_value)'==`r(N)' // Verifies that firm_i-year-firm_j form a unique identifier.
		sort calendar_year_end iss_company_id iss_company_id_j

		geodist zip_latitude zip_longitude zip_latitude_j zip_longitude_j, miles sphere gen(distance_miles) // The "sphere" option makes the distance match the one on Zip-Codes.com.
		geodist zip_latitude_j zip_longitude_j zip_latitude zip_longitude, miles sphere gen(distance_miles_check) // The "sphere" option makes the distance match the one on Zip-Codes.com.
		assert distance_miles==distance_miles_check // Verifies that the distance between points A and B are the same as B and A.
		format %12.2fc distance_miles
		drop distance_miles_check zipcode zip_latitude zip_longitude zipcode_j zip_latitude_j zip_longitude_j

		quietly log on
			* Distribution of distances before dropping any (includes firm_i matched to itself).
			summarize distance_miles, det
		quietly log off

		foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
			gen supply_dir_`group' = cond( 				///
				distance_miles<=60 					& 	///
				filter_gics_non_financial_j==1 		& 	/// Exclude paired firms in the financial industry.
				gics_8_code!=gics_8_code_j 			& 	/// The paired firm cannot be in the same 8-digit GICS of the focal firm.
				iss_company_id!=iss_company_id_j 	& 	/// Observations paired to themselves are ignored, but not excluded.
				!missing( 								///
					distance_miles 					, 	///
					filter_gics_non_financial_j 	, 	///
					gics_8_code 					, 	///
					gics_8_code_j 					, 	///
					iss_company_id 					, 	///
					iss_company_id_j 				, 	///
					num_individuals_`group'_j 			/// Missing values are considered zero, which is analogous to how "n/c", "pnd", and "u" are implicitly treated.
				) 										///
			, num_individuals_`group'_j, 0)
			assert !missing(supply_dir_`group')
		}

		drop gics_8_code filter_gics_non_financial_j gics_8_code_j distance_miles num_individuals_a_j num_individuals_b_j num_individuals_hl_j num_individuals_i_j num_individuals_m_j num_individuals_n_j num_individuals_p_j num_individuals_w_j num_individuals_o_j num_individuals_ai_j num_individuals_women_j num_individuals_total_j

		collapse (sum) supply_dir_a supply_dir_b supply_dir_hl supply_dir_i supply_dir_m supply_dir_n supply_dir_p supply_dir_w supply_dir_o supply_dir_ai supply_dir_women supply_dir_total, by(calendar_year_end iss_company_id)

		foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
			gen ln_supply_dir_`group' = ln(1 + supply_dir_`group')
			assert !missing(ln_supply_dir_`group')
		}

		quietly log on
			* Descriptive statistics of the number of potential directors of a given ethnicity.
			foreach transf in supply ln_supply {
				tabstat 							///
					`transf'_dir_a 					///
					`transf'_dir_b 					///
					`transf'_dir_hl 				///
					`transf'_dir_i 					///
					`transf'_dir_m 					///
					`transf'_dir_n 					///
					`transf'_dir_p 					///
					`transf'_dir_w 					///
					`transf'_dir_o 					///
					`transf'_dir_ai 				///
					`transf'_dir_women 				///
					`transf'_dir_total 				///
				, statistics(mean sd min p25 p50 p75 max count) columns(statistics)
			}
		quietly log off

		order iss_company_id calendar_year_end supply_dir_a supply_dir_b supply_dir_hl supply_dir_i supply_dir_m supply_dir_n supply_dir_p supply_dir_w supply_dir_o supply_dir_ai supply_dir_women supply_dir_total ln_supply_dir_a ln_supply_dir_b ln_supply_dir_hl ln_supply_dir_i ln_supply_dir_m ln_supply_dir_n ln_supply_dir_p ln_supply_dir_w ln_supply_dir_o ln_supply_dir_ai ln_supply_dir_women ln_supply_dir_total

		isid iss_company_id calendar_year_end
		sort iss_company_id calendar_year_end
		keep iss_company_id calendar_year_end ln_supply_dir_b

	quietly count
	assert `r(N)'==`unique_firm_years' // Checks that the number of firm-year observations with non-missing and matched zip codes is correct.

	save "Merge Determinants of Exposure to Racial Diversity - Temp 5", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear // I start with all firm-year-directors (non-directors were dropped previously).

	preserve
		keep iss_company_id calendar_year_end
		duplicates drop // Keeps only unique firm-years.
		quietly count // Stores the number of observations in `r(N)'.
		local unique_firm_years = r(N)
	restore

		keep calendar_year_end iss_person_id iss_company_id // Only the variables necessary to calculate the board's network size are retained.
		assert !missing(calendar_year_end, iss_person_id, iss_company_id)
		duplicates report calendar_year_end iss_person_id iss_company_id
		assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-calendar_year_end-director.
		sort calendar_year_end iss_person_id iss_company_id
		order calendar_year_end iss_person_id iss_company_id
		save "Merge Determinants of Exposure to Racial Diversity - Temp 6", replace

			* These commands do not affect the file above.
			bysort calendar_year_end iss_person_id (iss_company_id): gen paired_order = _n
			rename iss_company_id iss_company_id_paired // Each firm is paired to the focal firm in the given year-director.
			save "Merge Determinants of Exposure to Racial Diversity - Temp 7", replace
			clear

		use "Merge Determinants of Exposure to Racial Diversity - Temp 6", clear
		erase "Merge Determinants of Exposure to Racial Diversity - Temp 6.dta"
		bysort calendar_year_end iss_person_id (iss_company_id): gen year_director_freq = _N
		expand year_director_freq // The "expand" command allows us to create a matrix that is (N)x(N) within each year-director pair, as opposed to (N)x(N) for the full sample, which is intractable.
		drop year_director_freq
		bysort calendar_year_end iss_person_id iss_company_id: gen paired_order = _n

		merge m:1 calendar_year_end iss_person_id paired_order using "Merge Determinants of Exposure to Racial Diversity - Temp 7"
		erase "Merge Determinants of Exposure to Racial Diversity - Temp 7.dta"
		assert _merge==3 // All observations in the master and using databases are matched.
		drop _merge
		drop paired_order

		assert !missing(calendar_year_end, iss_person_id, iss_company_id, iss_company_id_paired)
		duplicates report calendar_year_end iss_person_id iss_company_id iss_company_id_paired
		assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is calendar_year_end-director-firm_i-firm_j. Only directors create links between firms. Noticed that at least one firm-year-director remains on the database because the observation is paired to itself. This is important, as firm-years that have no links should be coded as zero, and not missing.
		sort calendar_year_end iss_person_id iss_company_id iss_company_id_paired

		drop iss_person_id
		sort calendar_year_end iss_company_id iss_company_id_paired
		duplicates drop // Removes multiple links to the same firm in the same year (caused by different directors creating multiple links).
		assert !missing(iss_company_id, iss_company_id_paired, calendar_year_end)
		gen network_size = cond(iss_company_id!=iss_company_id_paired, 1, 0) // Firms-years matched to themselves are not counted as a link.
		collapse (sum) network_size, by(calendar_year_end iss_company_id)
		gen ln_network_size = ln(1 + network_size)

		quietly log on
			* Descriptive statistics of the network size variables in the ISS Directors Diversity database.
			summarize network_size, det
			summarize ln_network_size, det
		quietly log off

		isid iss_company_id calendar_year_end
		sort iss_company_id calendar_year_end
		order iss_company_id calendar_year_end network_size ln_network_size

	quietly count
	assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

	save "Merge Determinants of Exposure to Racial Diversity - Temp 8", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear
	isid iss_company_id calendar_year_end

	merge 1:1 iss_company_id calendar_year_end using "Merge Determinants of Exposure to Racial Diversity - Temp 2"
	assert _merge!=2
	drop _merge
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 2.dta"

	merge 1:1 iss_company_id calendar_year_end using "Merge Determinants of Exposure to Racial Diversity - Temp 5"
	assert _merge!=2
	drop _merge
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 5.dta"

	merge 1:1 iss_company_id calendar_year_end using "Merge Determinants of Exposure to Racial Diversity - Temp 8"
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 8.dta"
	assert _merge!=2
	drop _merge

	drop if missing(gvkey)

	duplicates tag gvkey calendar_year_end, gen(dup)
	drop if dup>0
	drop dup

	isid gvkey calendar_year_end
	sort gvkey calendar_year_end
	keep company_event_id gvkey calendar_year_end dummy_dir_b prop_dir_b_o_board prop_dir_b_o_identified prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size state_of_address
	order company_event_id gvkey calendar_year_end dummy_dir_b prop_dir_b_o_board prop_dir_b_o_identified prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size state_of_address

	save "Merge Determinants of Exposure to Racial Diversity - Temp 9", replace
	clear

use "${folder_original_databases}/Compustat/Compustat - 2022-10-12" if 	///
	consol 	== 	"C" 	& 												/// Imposes consolidated financial statements.
	datafmt == 	"STD" 	& 												/// Imposes standardized data format.
	indfmt 	== 	"INDL" 	& 												/// Imposes industrial firms.
	curcd 	== 	"USD" 													/// Imposes currency to be US Dollars.
, clear

	assert popsrc=="D" // Imposes domestic firms (USA, Canada & ADRs).

	destring naics, replace // "naics" is numeric in the Bureau of Labor Statistics database.
	destring gvkey, replace // "gvkey" is numeric in ISSDD.

	duplicates tag gvkey fyear, gen(dup)
	drop if dup>0 // There is only one firm for which the "gvkey"-"fyear" pair is not unique.
	drop dup

	assert !missing(datadate, fyear)
	gen fyear_test = cond(month(datadate)>=6, year(datadate), year(datadate) - 1)
	assert fyear_test==fyear // This commands checks the variable "fyear" based on datadate.
	drop fyear_test

	isid gvkey fyear
	sort gvkey fyear

	xtset gvkey fyear

		gen firm_visibility = ln(at)

		bysort gvkey (fyear): egen min_fyear = min(fyear)
		gen firm_age_min_fyear = fyear - min_fyear
		drop min_fyear
		assert !missing(firm_age_min_fyear)
		assert firm_age_min_fyear>=0
		gen ln_firm_age_min_fyear = ln(1 + firm_age_min_fyear)

		gen book_to_market = ceq / (csho * prcc_f)
		gen rd_over_assets_0 = cond(!missing(xrd), xrd, 0) / ((at + L.at) / 2)
		gen roa = ib / ((at + L.at) / 2)

	xtset, clear

	label variable at "Total Assets, measured in Millions of USD"

	keep gvkey datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh
	order gvkey datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh

	isid gvkey datadate
	sort gvkey datadate

	save "Merge Determinants of Exposure to Racial Diversity - Temp 10", replace
	clear

use "${folder_original_databases}/Thomson_Reuters/wrds_stock_ownership/WRDS Thomson Reuters Stock Ownership - 2022-10-19", clear
	gen InstOwn_Perc_check = InstOwn / (shrout * 1000)
	assert float(InstOwn_Perc)==float(InstOwn_Perc_check)
	drop InstOwn_Perc_check

	assert missing(InstOwn_Perc) if (missing(shrout) | shrout==0) // "InstOwn_Perc" is missing only when either "shrout" is missing or zero.
	gen shrout_zero_miss = cond((missing(shrout) | shrout==0), 1, 0)

	keep rdate cusip InstOwn_HHI InstOwn_Perc shrout_zero_miss
	assert 0<=InstOwn_HHI & InstOwn_HHI<=1 if !missing(InstOwn_HHI)
	assert 0<=InstOwn_Perc if !missing(InstOwn_Perc) // According to the manual there are three reasons for institutional ownership being greater than 100%: 1) short positions are not reported, 2) shared investment discretion by multiple asset managers, and 3) issues with stock splits.

	assert !missing(rdate)
	gen day_month_string = substr(string(rdate, "%td"), 1, 5)
	label define order_day_month 	///
		1 "31mar" 					///
		2 "30jun" 					///
		3 "30sep" 					///
		4 "31dec"
	encode day_month_string, gen(day_month) label(order_day_month)

	quietly log on
		* Report the distribution of the day-months of the file date.
		tab day_month, miss
	quietly log off

	drop day_month day_month_string

	assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
	rename cusip cusip_8

	isid cusip_8 rdate
	sort cusip_8 rdate
	order cusip_8 rdate InstOwn_Perc InstOwn_HHI

	save "Merge Determinants of Exposure to Racial Diversity - Temp 11", replace
	clear

use "${folder_original_databases}/Thomson_Reuters/s34 Master File/Institutional Holdings - s34 Master File - 2022-10-19", clear
	drop if missing(cusip) // "cusip" is the variable I use as the security identifier.

	assert !missing(cusip, mgrno, rdate, fdate)
	duplicates report cusip mgrno rdate fdate
	assert `r(unique_value)'==`r(N)' // Verifies that "cusip", "mgrno", "rdate", and "fdate" form a unique identifier. According to the manuals available from WRDS, "rdate" represents the effective ownership date, whereas the "fdate" represents the vintage date at which the shares outstanding are valid. Because Thomson Reuters' 13F data carries forward institutional reports for up to 8 quarters, a given tuple "cusip"-"mgrno"-"rdate" can have multiple "fdate".
	sort cusip mgrno rdate fdate

	bysort cusip mgrno rdate (fdate): egen min_fdate = min(fdate)
	format %td min_fdate
	keep if fdate==min_fdate // I follow Ben-David et al. (2021) and keep the first "fdate" (the first vintage) for a given tuple "cusip"-"mgrno"-"rdate". Keeping the first instead of the last "fdate" also results in institutional ownership much closer to the aggregate institutional ownership data available on WRDS.
	drop min_fdate

	assert !missing(cusip, mgrno, rdate)
	duplicates report cusip mgrno rdate
	assert `r(unique_value)'==`r(N)'
	sort cusip mgrno rdate

	gen year_rdate = year(rdate)
	gen mgrname_stand = mgrname
	replace mgrname_stand = upper(mgrname_stand) // Capitalizes the string variable.
	replace mgrname_stand = strtrim(mgrname_stand) // Removes internal consecutive spaces.
	replace mgrname_stand = stritrim(mgrname_stand) // Removes leading and trailing spaces.
	assert !missing(mgrname_stand)

	assert !missing(mgrno)
	gen d_blackrock = ( 	/// I follow Ben-David et al. (2020).
		mgrno== 9385 | 		///
		mgrno==11386 | 		///
		mgrno==12588 | 		///
		mgrno==39539 | 		///
		mgrno==56790 | 		///
		mgrno==91430 		///
	)
	gen d_vanguard = (mgrno==90457)
	gen d_ssga = (mgrno==81540)
	gen d_big_3 = d_blackrock + d_vanguard + d_ssga
	assert d_big_3==0 | d_big_3==1 // There is no overlap among the Big Three classification.

	quietly log on
		* Shows the distribution of the combination of Manager Number - Year of the Report Date - Manager Name.
		foreach investor in blackrock vanguard ssga {
			groups mgrno year_rdate mgrname_stand if d_`investor'==1, sepby(mgrno)
		}
		tab d_big_3, miss
	quietly log off

	drop mgrname_stand year_rdate

	gen double prop_shares = cond(!missing(shrout2), shares / (shrout2 * 1000), shares / (shrout1 * 1000000)) // "shrout2" and "shrout1" are not constant within each "cusip"-"rdate" pair. Therefore, the proportion of shares owned has to be calculated before aggregating the data at "cusip"-"rdate". Because "shrout2" is more precise than "shrout1", I use the former whenever its value is not missing.
	assert !missing(shares) // The "prop_shares" is only missing because of the denominator (zero or missing) and never because of the numerator.

	foreach investor in blackrock vanguard ssga big_3 {
		quietly gen double prop_shares_`investor' = cond(d_`investor'==1, prop_shares, .)
	}

	collapse (sum) inst_own=prop_shares inst_own_blackrock=prop_shares_blackrock inst_own_vanguard=prop_shares_vanguard inst_own_ssga=prop_shares_ssga inst_own_big_3=prop_shares_big_3 (max) d_blackrock d_vanguard d_ssga d_big_3 (count) non_miss_prop_shares=prop_shares non_miss_prop_shares_blackrock=prop_shares_blackrock non_miss_prop_shares_vanguard=prop_shares_vanguard non_miss_prop_shares_ssga=prop_shares_ssga non_miss_prop_shares_big_3=prop_shares_big_3, by(cusip rdate)

	assert !missing(non_miss_prop_shares) & non_miss_prop_shares>=0
	gen all_shrout_zero_miss = cond(non_miss_prop_shares==0, 1, 0) // Keep in mind that "prop_shares" was missing only because of the denominator (zero or missing).
	assert !missing(inst_own)
	assert inst_own==0 if all_shrout_zero_miss==1
	replace inst_own = . if all_shrout_zero_miss==1 // I only set "inst_own" to missing if all values of "prop_shares" were missing for that particular "cusip"-"rdate". This is an analogous treatment to institutional investors that manage less than $100 million.
	drop non_miss_prop_shares

	foreach investor in blackrock vanguard ssga big_3 {
		assert d_`investor'==0 | d_`investor'==1
		assert !missing(non_miss_prop_shares_`investor') & non_miss_prop_shares_`investor'>=0
		quietly gen all_shrout_zero_miss_`investor' = cond(non_miss_prop_shares_`investor'==0, 1, 0)
		assert !missing(inst_own_`investor')
		assert inst_own_`investor'==0 if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // It is zero, but should be missing.
		quietly replace inst_own_`investor' = . if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // There was at least one 13F form from the investor, but the proportion of shares owned by it were all missing.
		assert inst_own_`investor'==0 if d_`investor'==0 & all_shrout_zero_miss==1 // It is zero, but should be missing.
		quietly replace inst_own_`investor' = . if d_`investor'==0 & all_shrout_zero_miss==1 // There was no 13F form from the investor and the proportion of shares owned by all shareholders were missing.
		drop non_miss_prop_shares_`investor' d_`investor'
	}

	drop all_shrout_zero_miss all_shrout_zero_miss_blackrock all_shrout_zero_miss_vanguard all_shrout_zero_miss_ssga all_shrout_zero_miss_big_3

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		gen miss_inst_`variab' = cond(missing(inst_`variab'), 1, 0) // If the underlying variable is missing in this database, its value should not be replaced with zero after merging.
	}

	assert !missing(rdate)
	gen day_month_string = substr(string(rdate, "%td"), 1, 5)
	label define order_day_month 	///
		1 "31mar" 					///
		2 "30jun" 					///
		3 "30sep" 					///
		4 "31dec"
	encode day_month_string, gen(day_month) label(order_day_month)

	quietly log on
		* Report the distribution of the day-months of the file date.
		tab day_month, miss
	quietly log off

	drop day_month day_month_string

	assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
	rename cusip cusip_8

	rename rdate rdate_big_3
	isid cusip_8 rdate_big_3
	sort cusip_8 rdate_big_3

	isid cusip_8 rdate_big_3
	sort cusip_8 rdate_big_3
	order cusip_8 rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3

	save "Merge Determinants of Exposure to Racial Diversity - Temp 12", replace
	clear

use "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted", clear
	assert sp_year==year(date)
	drop sp_year
	drop BloombergIdentifier
	drop ticker
	replace cusip = "" if cusip=="#N/A N/A"
	drop if missing(cusip)
	gen sp_ = 1

	reshape wide sp_, i(cusip date) j(sp_index) string

	foreach sp in 500 400 600 {
		quietly replace sp_`sp' = 0 if missing(sp_`sp')
	}

	rename date date_sp
	keep cusip date_sp sp_500

	isid cusip date_sp
	sort cusip date_sp
	order cusip date_sp sp_500

	save "Merge Determinants of Exposure to Racial Diversity - Temp 13", replace
	clear

use "${folder_original_databases}/BLS/2012_2020_Compustat_NACIS_BLS_Merged_data", clear
	duplicates tag comp_naics year, gen(dup)
	drop if dup>0
	drop dup

	keep year comp_naics Total WomenPn BlackPn AsianPn HispanicPn
	rename comp_naics naics // Renamed to match the variable names in the main database.
	rename year year_naics_bls
	rename Total total_emp_by_naics_bls
	rename WomenPn pct_emp_women_by_naics_bls
	rename BlackPn pct_emp_b_by_naics_bls
	rename AsianPn pct_emp_a_by_naics_bls
	rename HispanicPn pct_emp_h_by_naics_bls

	foreach group in "women" "b" "a" "h" {
		quietly gen prop_emp_`group'_by_naics_bls = pct_emp_`group'_by_naics_bls / 100
		assert 0<=prop_emp_`group'_by_naics_bls & prop_emp_`group'_by_naics_bls<=1 if !missing(prop_emp_`group'_by_naics_bls) // Percentages should take values between 0% and 100%.
		drop pct_emp_`group'_by_naics_bls
	}

	* These commands forward track the last year another year.
		quietly sum year_naics_bls
		gen expand_last_year = 1
		replace expand_last_year = 2 if year_naics_bls==r(max)
		expand expand_last_year, gen(obs_last_year)
		replace year_naics_bls = year_naics_bls + 1 if obs_last_year==1
		drop expand_last_year obs_last_year

	keep year_naics_bls naics prop_emp_b_by_naics_bls

	* Lag all the variables:
		gen year_date_cc = year_naics_bls + 1
		rename prop_emp_b_by_naics_bls prop_emp_b_by_naics_bls_lag
		drop year_naics_bls
		rename naics naics_lag

	isid naics_lag year_date_cc
	sort naics_lag year_date_cc
	order naics_lag year_date_cc prop_emp_b_by_naics_bls_lag

	save "Merge Determinants of Exposure to Racial Diversity - Temp 14", replace
	clear

use "${folder_save_databases}/census_bureau/census_diversity_state_race_2021", clear

	keep state year local_pop_b

	* Lag all the variables:
		gen year_date_cc = year + 1
		rename local_pop_b local_pop_b_lag
		drop year
		rename state state_of_address_lag

	isid state_of_address_lag year_date_cc
	sort state_of_address_lag year_date_cc
	order state_of_address_lag year_date_cc

	save "Merge Determinants of Exposure to Racial Diversity - Temp 15", replace
	clear

use "${folder_original_databases}/Industry_Classification/SupplyChain_B2C_categorization_naics17_97_April2020 - 2022-04-21", clear // The US Bureau of Economic Analysis uses NAICS at a given year to prepare the input-output tables. "Comprehensive updates, which are typically conducted at 5-year intervals, tend to have a more expansive scope than annual updates and provide an opportunity to update the accounts to better reflect the evolving U.S. economy. These updates incorporate changes in definitions and classifications and statistical changes, which update the accounts through the use of new and improved estimation methods and newly available and revised source data, including the Economic Census which is used to benchmark the accounts."
	keep year
	duplicates drop // Keeps unique years.
	gen year_last = cond(!missing(year[_n + 1]), year[_n + 1], 2022) - 1 // If year is missing, the last one is the current year (2022).
	gen year_window = year_last - year + 1
	drop year_last
	save "Merge Determinants of Exposure to Racial Diversity - Temp 16", replace
	clear

use "${folder_original_databases}/Industry_Classification/SupplyChain_B2C_categorization_naics17_97_April2020 - 2022-04-21", clear
	assert ustrlen(string(naicso_id, "%9.0f"))==6 // These are all six-digit NAICS. As Delgado and Mills (2020) explain, their classification does not map perfectly into firm-level data because some firms have establishments in multiple industries in SC (supply chain) and B2C (business-to-consumer).
	assert !missing(sc65, perc_supplies_to_pce)
	assert sc65==0 | sc65==1
	assert perc_supplies_to_pce<0.35 if sc65==1 // 0.35 is the cut-off used by the authors.
	assert perc_supplies_to_pce>=0.35 if sc65==0 // 0.35 is the cut-off used by the authors.

	keep naicso_id year sc65 perc_supplies_to_pce

	assert !missing(naicso_id, year)
	duplicates report naicso_id year
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort naicso_id year
	order naicso_id year sc65

	merge m:1 year using "Merge Determinants of Exposure to Racial Diversity - Temp 16"
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 16.dta"
	assert _merge==3
	drop _merge

	expand year_window
	bysort naicso_id year: gen order = _n
	gen valid_year = year + order - 1
	drop year year_window order

	gen b2c_dm = 1 - sc65 if !missing(sc65)
	drop sc65
	rename perc_supplies_to_pce b2c_cont_dm

	rename valid_year datadate_year
	rename naicso_id naicsh
	keep naicsh datadate_year b2c_dm b2c_cont_dm

	* Lag all the variables:
		gen year_date_cc = datadate_year + 1
		rename b2c_dm b2c_dm_lag
		rename b2c_cont_dm b2c_cont_dm_lag
		drop datadate_year
		rename naicsh naicsh_lag

	isid naicsh_lag year_date_cc
	sort naicsh_lag year_date_cc
	order naicsh_lag year_date_cc b2c_dm_lag b2c_cont_dm_lag

	save "Merge Determinants of Exposure to Racial Diversity - Temp 17", replace
	clear

import_delimited "${folder_save_databases}/conference_calls/diversity_exposure_over_time_all_CCs.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear // Includes data before George Floyd's death.
// import_delimited "${folder_save_databases}/conference_calls/diversity_exposure_calculated_cc_level_after_GF.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear

gen date_cc = date(date, "YMD")
format %td date_cc
assert !missing(date_cc)
drop date

assert date_year == year(date_cc)
assert date_month == month(date_cc)
assert year_month == year(date_cc) * 100 + month(date_cc)
drop date_year date_month year_month

gen year_date_cc = year(date_cc)

drop ticker1 // To be consistent with the director appointments database, I only match on "ticker_text".
rename ticker_text ticker // Renaming allows me to merge to the master database.

replace ticker = regexs(1) if regexm(ticker, "^(.*)[-']$")==1 // No ticker ends with "-" or "'"
replace ticker = regexs(1) if regexm(ticker, "^-(.*)$")==1 // No ticker begins with "-".

assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".
assert ticker==upper(ticker)
drop if missing(ticker)

duplicates tag ticker date_cc, gen(dup)
drop if regexm(cc, "quick-version") & dup>0 // Some of the conference calls transcripts are issued earlier than other versions with "Quick Version" in the title.
drop dup

rename period quarter_cc
format %-60s cc

isid cc_id
sort cc_id
order cc_id cc ticker date_cc year_date_cc fyear quarter_cc

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby ticker using "Merge Determinants of Exposure to Racial Diversity - Temp 1", unmatched(master)
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 1.dta"

	gen outside_window = cond((date_cc < linkdt | date_cc > linkenddt), 1, 0)

		foreach variab in conm linktype linkprim cusip {
			quietly replace `variab' = "" if outside_window==1
		}

		foreach variab in gvkey permno permco linkdt linkenddt gics_2_code_i {
			quietly replace `variab' = . if outside_window==1
		}

	drop outside_window

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0 // Duplicates only happen when observations from both datasets matched.
	assert missing(conm, gvkey, cusip, permno, permco, linktype, linkprim, linkdt, linkenddt, gics_2_code_i) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) based on "ticker" whose day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort cc_id: egen sum_valid_link = total(valid_link)
	drop if valid_link==0 & sum_valid_link>0 // In case of at least one match, drop instances of no valid link because the day does not fit the link window interval.
	drop valid_link sum_valid_link

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort cc_id: egen sum_valid_link = total(valid_link)
	assert sum_valid_link==0 | sum_valid_link==1 // There is at most one match per "ticker"-"date_cc" pair.
	drop valid_link sum_valid_link _merge

	isid cc_id
	sort cc_id

quietly count
assert `r(N)'==`num_obs' // Checks that the original number of observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby gvkey using "Merge Determinants of Exposure to Racial Diversity - Temp 9", unmatched(master) // There are missing "gvkey" values in the master database. It is ok to use "joinby" because there are no missing "gvkey" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 9.dta"
	duplicates report cc_id calendar_year_end // Some of the "calendar_year_end" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-calendar_year_end form a unique identifier.
	sort cc_id calendar_year_end

	gen days_dif = calendar_year_end - date_cc

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort cc_id (calendar_year_end): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (calendar_year_end): egen max_month_year_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in company_event_id state_of_address {
		quietly replace `variab' = "" if sum_match_window==0
	}

	foreach variab in calendar_year_end dummy_dir_b prop_dir_b_o_identified prop_dir_b_o_board prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_month_year_dif retain

	foreach variab in company_event_id calendar_year_end dummy_dir_b prop_dir_b_o_identified prop_dir_b_o_board prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size state_of_address {
		rename `variab' `variab'_lag
	}

	isid cc_id
	sort cc_id

quietly count
assert `r(N)'==`num_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby gvkey using "Merge Determinants of Exposure to Racial Diversity - Temp 10", unmatched(master) // There are missing "gvkey" values in the master database. It is ok to use "joinby" because there are no missing "gvkey" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 10.dta"
	duplicates report cc_id datadate // Some of the "datadate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-datadate form a unique identifier.
	sort cc_id datadate

	gen days_dif = datadate - date_cc

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort cc_id (datadate): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (datadate): egen max_month_year_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_month_year_dif retain

	foreach variab in datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh {
		rename `variab' `variab'_lag
	}

	isid cc_id
	sort cc_id

quietly count
assert `r(N)'==`num_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "Merge Determinants of Exposure to Racial Diversity - Temp 11", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 11.dta"
	duplicates report cc_id rdate // Some of the "rdate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that "cc_id"-"rdate" form a unique identifier.
	sort cc_id rdate

	assert day(rdate + 1)==1 if !missing(rdate) // The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.
	assert ( 				///
		month(rdate)==03 | 	///
		month(rdate)==06 | 	///
		month(rdate)==09 | 	///
		month(rdate)==12 	///
	) if !missing(rdate) 	// The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.

	gen days_dif = rdate - date_cc

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort cc_id (rdate): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (rdate): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 days_dif match_window sum_match_window max_days_dif retain

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss {
		rename `variab' `variab'_lag
	}

	gen InstOwn_Perc_0_lag = cond((missing(InstOwn_Perc_lag) & !missing(cusip) & shrout_zero_miss_lag!=1), 0, InstOwn_Perc_lag) // I assume that form 13F is comprehensive and, therefore, substitute "InstOwn_Perc_lag" by zero, as long as "cusip" is not missing and "shrout" is neither zero or missing in the Thomson Reuters database.
	gen InstOwn_Perc_miss_lag = cond(missing(InstOwn_Perc_lag) & InstOwn_Perc_0_lag==0, 1, 0) if !missing(InstOwn_Perc_0_lag)
	drop shrout_zero_miss_lag

	isid cc_id
	sort cc_id

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "Merge Determinants of Exposure to Racial Diversity - Temp 12", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 12.dta"
	duplicates report cc_id rdate_big_3 // Some of the "rdate_big_3" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that "cc_id"-"rdate_big_3" form a unique identifier.
	sort cc_id rdate_big_3

	assert day(rdate_big_3 + 1)==1 if !missing(rdate_big_3) // The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.
	assert ( 						///
		month(rdate_big_3)==03 | 	///
		month(rdate_big_3)==06 | 	///
		month(rdate_big_3)==09 | 	///
		month(rdate_big_3)==12 		///
	) if !missing(rdate_big_3) 		// The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.

	gen days_dif_big_3 = rdate_big_3 - date_cc

	gen match_window = cond(days_dif_big_3<=-180 & days_dif_big_3>-540, 1, 0) if _merge==3
	bysort cc_id (rdate_big_3): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (rdate_big_3): egen max_days_dif_big_3 = max(days_dif_big_3) if match_window==1 & sum_match_window>1

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 days_dif_big_3 {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif_big_3==max_days_dif_big_3 & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 days_dif_big_3 match_window sum_match_window max_days_dif_big_3 retain

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 {
		rename `variab' `variab'_lag
	}

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		quietly gen inst_`variab'_0_lag = cond((missing(inst_`variab'_lag) & !missing(cusip) & miss_inst_`variab'_lag!=1), 0, inst_`variab'_lag) // I assume that form 13F is comprehensive and, therefore, substitute the variables by zero, as long as "cusip" is not missing and the variables are not missing in the Thomson Reuters database.
		quietly gen inst_`variab'_miss_lag = cond(missing(inst_`variab'_lag) & inst_`variab'_0_lag==0, 1, 0) if !missing(inst_`variab'_0_lag)
		drop miss_inst_`variab'_lag
	}

	isid cc_id
	sort cc_id

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	joinby cusip using "Merge Determinants of Exposure to Racial Diversity - Temp 13", unmatched(master) // There are missing "cusip" values in the master database. It is ok to use "joinby" because there are no missing "cusip" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity - Temp 13.dta"
	duplicates report cc_id date_sp // Some of the "date_sp" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that "cc_id"-"date_sp" form a unique identifier.
	sort cc_id date_sp

	gen days_dif = date_sp - date_cc

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort cc_id (date_sp): egen sum_match_window = total(match_window) if _merge==3
	bysort cc_id (date_sp): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in date_sp sp_500 days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in date_sp sp_500 {
		rename `variab' `variab'_lag
	}

	replace sp_500_lag = 0 if missing(sp_500_lag) & !missing(cusip) // The Bloomberg database contains cusips only for S&P 1500. Any non-missing cusip observation in the master database should be considered non-S&P 500.

	isid cc_id
	sort cc_id

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of firm-year observations is correct.

merge m:1 naics_lag year_date_cc using "Merge Determinants of Exposure to Racial Diversity - Temp 14", keep(match master) nogenerate
erase "Merge Determinants of Exposure to Racial Diversity - Temp 14.dta"

merge m:1 state_of_address_lag year_date_cc using "Merge Determinants of Exposure to Racial Diversity - Temp 15", keep(match master) nogenerate
erase "Merge Determinants of Exposure to Racial Diversity - Temp 15.dta"

merge m:1 naicsh_lag year_date_cc using "Merge Determinants of Exposure to Racial Diversity - Temp 17", keep(match master) nogenerate
erase "Merge Determinants of Exposure to Racial Diversity - Temp 17.dta"

isid cc_id
sort cc_id

save "${folder_save_databases}/Exposure to Racial Diversity/Merge Determinants of Exposure to Racial Diversity", replace
clear

**# Analyze determinants of exposure to racial diversity (conference calls).
use "${folder_save_databases}/Exposure to Racial Diversity/Merge Determinants of Exposure to Racial Diversity", clear

gen post_george_floyd = cond(date_cc>td(25, May, 2020), 1, 0)
keep if date_cc >= td(01, Jan, 2019)
keep if date_cc <= td(31, Dec, 2021)

assert float(InstOwn_Perc_lag)==float(inst_own_lag) if !missing(InstOwn_Perc_lag, inst_own_lag)
assert float(InstOwn_Perc_0_lag)==float(inst_own_0_lag) if !missing(InstOwn_Perc_0_lag, inst_own_0_lag)
drop inst_own_lag inst_own_0_lag

foreach variab in InstOwn_Perc_lag InstOwn_Perc_0_lag inst_own_blackrock_lag inst_own_blackrock_0_lag inst_own_vanguard_lag inst_own_vanguard_0_lag inst_own_ssga_lag inst_own_ssga_0_lag inst_own_big_3_lag inst_own_big_3_0_lag {
	replace `variab' = 1 if `variab'>1 & !missing(`variab')
}

* These commands winsorize the variables at 1% each tail.
foreach variab in book_to_market_lag roa_lag rd_over_assets_0_lag {
	quietly gen `variab'_w = `variab'
	quietly sum `variab', detail
	quietly replace `variab'_w = `r(p99)' if `variab'>`r(p99)' & !missing(`variab')
	quietly replace `variab'_w = `r(p1)' if `variab'<`r(p1)' & !missing(`variab')
	quietly local var_label: variable label `variab'
	quietly label variable `variab'_w "`var_label'"
	quietly drop `variab'
	display as text "Winsorizing at 1% each tail the variable `variab'"
}

gen dummy_disclosure = cond(diver_exposure_sent>0, 1, 0) if !missing(diver_exposure_sent)
gen diver_exposure_sent_perc = diver_exposure_sent * 100

save "${folder_save_databases}/Exposure to Racial Diversity/Analyze Determinants of Exposure to Racial Diversity", replace
clear

**# Merge determinants of exposure to racial diversity (press releases).
use "${folder_original_databases}/CRSP Compustat Merged/Compustat CRSP Link - 2022-08-29", clear
	rename *, lower
	format conm %-45s
	keep if linktype=="LC" | linktype=="LU" // These are the recommended links by WRDS.
	keep if linkprim=="P" | linkprim=="C" // "P" means primary in Compustat, and "C" means primary in CRSP. According to WRDS, they are mutually exclusive.
	destring gvkey, replace
	rename gsector gics_2_code

	gen gics_2_code_n = ""
		quietly replace gics_2_code_n = "Energy" 					 if gics_2_code == 10
		quietly replace gics_2_code_n = "Materials" 				 if gics_2_code == 15
		quietly replace gics_2_code_n = "Industrials" 				 if gics_2_code == 20
		quietly replace gics_2_code_n = "Consumer Discretionary" 	 if gics_2_code == 25
		quietly replace gics_2_code_n = "Consumer Staples" 			 if gics_2_code == 30
		quietly replace gics_2_code_n = "Health Care" 				 if gics_2_code == 35
		quietly replace gics_2_code_n = "Financials" 				 if gics_2_code == 40
		quietly replace gics_2_code_n = "Information Technology" 	 if gics_2_code == 45
		quietly replace gics_2_code_n = "Telecommunication Services" if gics_2_code == 50
		quietly replace gics_2_code_n = "Utilities" 				 if gics_2_code == 55
		quietly replace gics_2_code_n = "Real Estate" 				 if gics_2_code == 60
	quietly replace gics_2_code_n = gics_2_code_n + " (" + string(gics_2_code, "%02.0f") + ")" if !missing(gics_2_code_n)
	encode gics_2_code_n, gen(gics_2_code_i)
	drop gics_2_code gics_2_code_n

	keep conm tic gvkey cusip lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code_i
	order conm tic gvkey cusip lpermno lpermco linktype linkprim linkdt linkenddt gics_2_code_i

	assert !missing(linkdt)
	assert !missing(tic)

	isid tic linkdt // Ticker is not missing and is unique for each linking time window.
	isid gvkey linkdt // Gvkey is not missing and is unique for each linking time window.
	isid lpermno linkdt // Permno is not missing and is unique for each linking time window.

	sort tic linkdt
	rename tic ticker
	rename lpermno permno
	rename lpermco permco

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 1", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear // I start with all firm-year-directors (non-directors were dropped previously).
	isid iss_company_id calendar_year_end iss_person_id
	sort iss_company_id calendar_year_end iss_person_id

	bysort iss_company_id calendar_year_end (iss_person_id): egen median_director_age_check = median(age)
	assert median_director_age==median_director_age_check // Because "age" is not correctly measured, then "median_director_age" is also incorrect.
	drop median_director_age_check median_director_age stdev_director_age
	drop age // The variable "age" is not correctly measured. For example, see first_name=="Timothy" & last_name=="Cook" & company_name=="Apple Inc.". The director's age is identical, independently of the "calendar_year_end". The same is true for first_name=="Elon" & last_name=="Musk". Another example is iss_company_id==513234 & calendar_year_end==td(31, Dec, 2015). While Robert Finocchio, Maria Klawe, and Nancy Handel all were born in 1952 according to "birth_date", their age is reported as 69, 63, and 63, respectively. The proxy statement filed on 2015-03-27 shows that all three were 63 years old on March 16, 2015.

	assert !missing(calendar_year_end)
	gen age_calendar_year_end = cond(calendar_year_end>=birthday(birth_date, year(calendar_year_end)), year(calendar_year_end) - year(birth_date), year(calendar_year_end) - year(birth_date) - 1) if !missing(birth_date) // The formula calculates "age_calendar_year_end" for any date, in case we use a different time stamp than December 31 later.
	assert !missing(age_calendar_year_end) if !missing(birth_date)

	gen dir_age_72_plus = cond(72<=age_calendar_year_end, 1, 0) if !missing(age_calendar_year_end)

	collapse (sum) num_dir_age_72_plus=dir_age_72_plus (count) dir_age_non_miss=age_calendar_year_end board_size=iss_person_id, by(iss_company_id calendar_year_end) // Changes the structure of the database from firm-year-director to firm-year. In the "collapse" command, "(count)" reports the number of non-missing observations within each "firm-year". "iss_person_id" is never missing and, therefore, "board_size" is the total number of observations within each "firm-year".

	assert !missing(dir_age_non_miss, board_size) & dir_age_non_miss<=board_size
	gen prop_dir_age_non_miss = dir_age_non_miss / board_size
	assert !missing(prop_dir_age_non_miss)
	replace num_dir_age_72_plus = . if prop_dir_age_non_miss < 0.7 // I impose that the age of at least 70% of the directors must be identified, otherwise the variable is missing.

	gen prop_dir_age_72_plus_o_ident = num_dir_age_72_plus / dir_age_non_miss
	assert !missing(prop_dir_age_72_plus_o_ident) if !missing(num_dir_age_72_plus)
	drop num_dir_age_72_plus

	drop dir_age_non_miss prop_dir_age_non_miss board_size

	isid iss_company_id calendar_year_end
	sort iss_company_id calendar_year_end
	order iss_company_id calendar_year_end prop_dir_age_72_plus_o_ident

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 2", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear // I start with all firm-years.

	gen num_individuals_total = ///
		num_individuals_a 	+ 	///
		num_individuals_b 	+ 	///
		num_individuals_hl 	+ 	///
		num_individuals_i 	+ 	///
		num_individuals_m 	+ 	///
		num_individuals_n 	+ 	///
		num_individuals_nc 	+ 	///
		num_individuals_o 	+ 	///
		num_individuals_p 	+ 	///
		num_individuals_pnd + 	///
		num_individuals_u 	+ 	///
		num_individuals_w

	rename number_women_directors num_directors_women
	rename num_women_neos num_neos_women
	rename num_women_individuals num_individuals_women

	rename board_size num_directors_total
	rename num_neos_total num_neos_total
	rename num_individuals_total num_individuals_total

	foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
		assert num_individuals_`group'<=(num_directors_`group' + num_neos_`group') if !missing(num_individuals_`group', num_directors_`group', num_neos_`group') // An executive that is on the board is both a director and a named executive officer (NEO).
		assert num_individuals_`group'>=num_directors_`group' if !missing(num_individuals_`group', num_directors_`group')
		assert num_individuals_`group'>=num_neos_`group' if !missing(num_individuals_`group', num_neos_`group')
	}

	keep calendar_year_end iss_company_id country_of_address country_of_incorporation state_of_address hq_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total // According to the ISS Directors Diversity dictionary, "hq_address" contains the address of the company's headquarters/primary operations. The same dictionary describes "num_individuals" as the distinct number of directors and named executive officers who partially or primarily identify as the ethnicity type.
	order calendar_year_end iss_company_id country_of_address country_of_incorporation state_of_address hq_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
	replace country_of_address = "" if country_of_address=="n/a"
	replace state_of_address = "" if state_of_address=="n/a"
	replace hq_address = "" if hq_address=="n/c"
	assert missing(hq_address) if missing(country_of_address) // If the "country_of_address" is missing, then "hq_address" is missing.
	drop if missing(country_of_address)
	assert country_of_address=="USA" // Data on the headquarter's address is only collected for U.S. firms. In addition, non-U.S. headquarter addresses would result in the wrong matching with the Zip Codes database.
	keep if country_of_incorporation=="USA" // I only keep U.S. firms for this analysis.
	drop country_of_address country_of_incorporation

	gen hq_address_edited = hq_address
	replace hq_address_edited = regexs(1) + "-" + regexs(2) if regexm(hq_address,"(^.*[0-9][0-9][0-9][0-9][0-9]).([0-9][0-9][0-9][0-9])$") // Changes any character for a dash in a 9 digit zip code at the end of the string.
	format %-60s hq_address hq_address_edited
	gen zipcode = substr(hq_address_edited, strrpos(hq_address_edited, " ") + 1, .) // Extracts all the characters after the last space. The "+1" prevents the last space from being part of the new string.
	replace zipcode = regexs(1) if regexm(zipcode, "(^[0-9][0-9][0-9][0-9][0-9])-[0-9][0-9][0-9][0-9]$") // Extracts only the first five of a nine digit zip code.
	drop if regexm(zipcode,"^[0-9][0-9][0-9][0-9][0-9]$")!=1 // There is no point in keeping observations with zip codes that will not match to the Zip Codes database.
	destring zipcode, replace
	format %05.0f zipcode
	drop hq_address hq_address_edited
	order calendar_year_end iss_company_id zipcode state_of_address filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total

	merge m:1 zipcode using "${folder_save_databases}/Zip_Codes/DB ZC Origin Zip Code Level", keep(match) // It is not helpful to keep zip codes where no company is located, or zip codes in which it is not possible to identify latitude and longitude.
	drop _merge
	assert state_of_address==zip_statefullname // The name of the state where the firm is headquartered matches both databases.
	drop state_of_address zip_city zip_county zip_state zip_statefullname

	quietly count // Stores the number of observations in `r(N)'.
	local unique_firm_years = r(N)

		assert !missing(calendar_year_end, iss_company_id)
		duplicates report calendar_year_end iss_company_id
		assert `r(unique_value)'==`r(N)' // Verifies that firm-year forms a unique identifier.
		sort calendar_year_end iss_company_id
		order calendar_year_end iss_company_id zipcode zip_latitude zip_longitude filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
		save "Merge Determinants of Exposure to Racial Diversity PR - Temp 3", replace

			* These commands do not affect the "Merge Determinants of Exposure to Racial Diversity PR - Temp 1" database.
			bysort calendar_year_end (iss_company_id): gen firm_j_order = _n

			foreach variab in iss_company_id zipcode zip_latitude zip_longitude filter_gics_non_financial gics_8_code num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total {
				rename `variab' `variab'_j // "firm_j" is the paired firm.
			}

			save "Merge Determinants of Exposure to Racial Diversity PR - Temp 4", replace
			clear

		use "Merge Determinants of Exposure to Racial Diversity PR - Temp 3", clear
		drop filter_gics_non_financial num_individuals_a num_individuals_b num_individuals_hl num_individuals_i num_individuals_m num_individuals_n num_individuals_p num_individuals_w num_individuals_o num_individuals_ai num_individuals_women num_individuals_total
		bysort calendar_year_end (iss_company_id): gen year_freq = _N
		expand year_freq // The "expand" command allows us to create a matrix that is (N)x(N) within each year, as opposed to (N)x(N) for the full sample. Notice that I could create a (N)x(N-1) matrix, but matching firm_i to itself prevents the firm from being dropped from the database if there is not a single firm within the specified radius. This is important, as the variable "SUPPLY_DIR" should be missing if the zip code is missing/incorrect, but should be zero if there is not a single firm around the specified distance.
		drop year_freq
		bysort calendar_year_end iss_company_id: gen firm_j_order = _n
		erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 3.dta"

		merge m:1 calendar_year_end firm_j_order using "Merge Determinants of Exposure to Racial Diversity PR - Temp 4"
		erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 4.dta"
		assert _merge==3
		drop _merge
		drop firm_j_order

		assert !missing(calendar_year_end, iss_company_id, iss_company_id_j)
		duplicates report calendar_year_end iss_company_id iss_company_id_j
		assert `r(unique_value)'==`r(N)' // Verifies that firm_i-year-firm_j form a unique identifier.
		sort calendar_year_end iss_company_id iss_company_id_j

		geodist zip_latitude zip_longitude zip_latitude_j zip_longitude_j, miles sphere gen(distance_miles) // The "sphere" option makes the distance match the one on Zip-Codes.com.
		geodist zip_latitude_j zip_longitude_j zip_latitude zip_longitude, miles sphere gen(distance_miles_check) // The "sphere" option makes the distance match the one on Zip-Codes.com.
		assert distance_miles==distance_miles_check // Verifies that the distance between points A and B are the same as B and A.
		format %12.2fc distance_miles
		drop distance_miles_check zipcode zip_latitude zip_longitude zipcode_j zip_latitude_j zip_longitude_j

		quietly log on
			* Distribution of distances before dropping any (includes firm_i matched to itself).
			summarize distance_miles, det
		quietly log off

		foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
			gen supply_dir_`group' = cond( 				///
				distance_miles<=60 					& 	///
				filter_gics_non_financial_j==1 		& 	/// Exclude paired firms in the financial industry.
				gics_8_code!=gics_8_code_j 			& 	/// The paired firm cannot be in the same 8-digit GICS of the focal firm.
				iss_company_id!=iss_company_id_j 	& 	/// Observations paired to themselves are ignored, but not excluded.
				!missing( 								///
					distance_miles 					, 	///
					filter_gics_non_financial_j 	, 	///
					gics_8_code 					, 	///
					gics_8_code_j 					, 	///
					iss_company_id 					, 	///
					iss_company_id_j 				, 	///
					num_individuals_`group'_j 			/// Missing values are considered zero, which is analogous to how "n/c", "pnd", and "u" are implicitly treated.
				) 										///
			, num_individuals_`group'_j, 0)
			assert !missing(supply_dir_`group')
		}

		drop gics_8_code filter_gics_non_financial_j gics_8_code_j distance_miles num_individuals_a_j num_individuals_b_j num_individuals_hl_j num_individuals_i_j num_individuals_m_j num_individuals_n_j num_individuals_p_j num_individuals_w_j num_individuals_o_j num_individuals_ai_j num_individuals_women_j num_individuals_total_j

		collapse (sum) supply_dir_a supply_dir_b supply_dir_hl supply_dir_i supply_dir_m supply_dir_n supply_dir_p supply_dir_w supply_dir_o supply_dir_ai supply_dir_women supply_dir_total, by(calendar_year_end iss_company_id)

		foreach group in "a" "b" "hl" "i" "m" "n" "p" "w" "o" "ai" "women" "total" {
			gen ln_supply_dir_`group' = ln(1 + supply_dir_`group')
			assert !missing(ln_supply_dir_`group')
		}

		quietly log on
			* Descriptive statistics of the number of potential directors of a given ethnicity.
			foreach transf in supply ln_supply {
				tabstat 							///
					`transf'_dir_a 					///
					`transf'_dir_b 					///
					`transf'_dir_hl 				///
					`transf'_dir_i 					///
					`transf'_dir_m 					///
					`transf'_dir_n 					///
					`transf'_dir_p 					///
					`transf'_dir_w 					///
					`transf'_dir_o 					///
					`transf'_dir_ai 				///
					`transf'_dir_women 				///
					`transf'_dir_total 				///
				, statistics(mean sd min p25 p50 p75 max count) columns(statistics)
			}
		quietly log off

		order iss_company_id calendar_year_end supply_dir_a supply_dir_b supply_dir_hl supply_dir_i supply_dir_m supply_dir_n supply_dir_p supply_dir_w supply_dir_o supply_dir_ai supply_dir_women supply_dir_total ln_supply_dir_a ln_supply_dir_b ln_supply_dir_hl ln_supply_dir_i ln_supply_dir_m ln_supply_dir_n ln_supply_dir_p ln_supply_dir_w ln_supply_dir_o ln_supply_dir_ai ln_supply_dir_women ln_supply_dir_total

		isid iss_company_id calendar_year_end
		sort iss_company_id calendar_year_end
		keep iss_company_id calendar_year_end ln_supply_dir_b

	quietly count
	assert `r(N)'==`unique_firm_years' // Checks that the number of firm-year observations with non-missing and matched zip codes is correct.

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 5", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year-Director Level", clear // I start with all firm-year-directors (non-directors were dropped previously).

	preserve
		keep iss_company_id calendar_year_end
		duplicates drop // Keeps only unique firm-years.
		quietly count // Stores the number of observations in `r(N)'.
		local unique_firm_years = r(N)
	restore

		keep calendar_year_end iss_person_id iss_company_id // Only the variables necessary to calculate the board's network size are retained.
		assert !missing(calendar_year_end, iss_person_id, iss_company_id)
		duplicates report calendar_year_end iss_person_id iss_company_id
		assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-calendar_year_end-director.
		sort calendar_year_end iss_person_id iss_company_id
		order calendar_year_end iss_person_id iss_company_id
		save "Merge Determinants of Exposure to Racial Diversity PR - Temp 6", replace

			* These commands do not affect the file above.
			bysort calendar_year_end iss_person_id (iss_company_id): gen paired_order = _n
			rename iss_company_id iss_company_id_paired // Each firm is paired to the focal firm in the given year-director.
			save "Merge Determinants of Exposure to Racial Diversity PR - Temp 7", replace
			clear

		use "Merge Determinants of Exposure to Racial Diversity PR - Temp 6", clear
		erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 6.dta"
		bysort calendar_year_end iss_person_id (iss_company_id): gen year_director_freq = _N
		expand year_director_freq // The "expand" command allows us to create a matrix that is (N)x(N) within each year-director pair, as opposed to (N)x(N) for the full sample, which is intractable.
		drop year_director_freq
		bysort calendar_year_end iss_person_id iss_company_id: gen paired_order = _n

		merge m:1 calendar_year_end iss_person_id paired_order using "Merge Determinants of Exposure to Racial Diversity PR - Temp 7"
		erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 7.dta"
		assert _merge==3 // All observations in the master and using databases are matched.
		drop _merge
		drop paired_order

		assert !missing(calendar_year_end, iss_person_id, iss_company_id, iss_company_id_paired)
		duplicates report calendar_year_end iss_person_id iss_company_id iss_company_id_paired
		assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is calendar_year_end-director-firm_i-firm_j. Only directors create links between firms. Noticed that at least one firm-year-director remains on the database because the observation is paired to itself. This is important, as firm-years that have no links should be coded as zero, and not missing.
		sort calendar_year_end iss_person_id iss_company_id iss_company_id_paired

		drop iss_person_id
		sort calendar_year_end iss_company_id iss_company_id_paired
		duplicates drop // Removes multiple links to the same firm in the same year (caused by different directors creating multiple links).
		assert !missing(iss_company_id, iss_company_id_paired, calendar_year_end)
		gen network_size = cond(iss_company_id!=iss_company_id_paired, 1, 0) // Firms-years matched to themselves are not counted as a link.
		collapse (sum) network_size, by(calendar_year_end iss_company_id)
		gen ln_network_size = ln(1 + network_size)

		quietly log on
			* Descriptive statistics of the network size variables in the ISS Directors Diversity database.
			summarize network_size, det
			summarize ln_network_size, det
		quietly log off

		isid iss_company_id calendar_year_end
		sort iss_company_id calendar_year_end
		order iss_company_id calendar_year_end network_size ln_network_size

	quietly count
	assert `r(N)'==`unique_firm_years' // Checks that the original number of firm-year observations is correct.

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 8", replace
	clear

use "${folder_save_databases}/iss/DB ISSDD Firm-Year Level", clear
	isid iss_company_id calendar_year_end

	merge 1:1 iss_company_id calendar_year_end using "Merge Determinants of Exposure to Racial Diversity PR - Temp 2"
	assert _merge!=2
	drop _merge
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 2.dta"

	merge 1:1 iss_company_id calendar_year_end using "Merge Determinants of Exposure to Racial Diversity PR - Temp 5"
	assert _merge!=2
	drop _merge
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 5.dta"

	merge 1:1 iss_company_id calendar_year_end using "Merge Determinants of Exposure to Racial Diversity PR - Temp 8"
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 8.dta"
	assert _merge!=2
	drop _merge

	drop if missing(gvkey)

	duplicates tag gvkey calendar_year_end, gen(dup)
	drop if dup>0
	drop dup

	isid gvkey calendar_year_end
	sort gvkey calendar_year_end
	keep company_event_id gvkey calendar_year_end dummy_dir_b prop_dir_b_o_board prop_dir_b_o_identified prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size state_of_address
	order company_event_id gvkey calendar_year_end dummy_dir_b prop_dir_b_o_board prop_dir_b_o_identified prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size state_of_address

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 9", replace
	clear

use "${folder_original_databases}/Compustat/Compustat - 2022-10-12" if 	///
	consol 	== 	"C" 	& 												/// Imposes consolidated financial statements.
	datafmt == 	"STD" 	& 												/// Imposes standardized data format.
	indfmt 	== 	"INDL" 	& 												/// Imposes industrial firms.
	curcd 	== 	"USD" 													/// Imposes currency to be US Dollars.
, clear

	assert popsrc=="D" // Imposes domestic firms (USA, Canada & ADRs).

	destring naics, replace // "naics" is numeric in the Bureau of Labor Statistics database.
	destring gvkey, replace // "gvkey" is numeric in ISSDD.

	duplicates tag gvkey fyear, gen(dup)
	drop if dup>0 // There is only one firm for which the "gvkey"-"fyear" pair is not unique.
	drop dup

	assert !missing(datadate, fyear)
	gen fyear_test = cond(month(datadate)>=6, year(datadate), year(datadate) - 1)
	assert fyear_test==fyear // This commands checks the variable "fyear" based on datadate.
	drop fyear_test

	isid gvkey fyear
	sort gvkey fyear

	xtset gvkey fyear

		gen firm_visibility = ln(at)

		bysort gvkey (fyear): egen min_fyear = min(fyear)
		gen firm_age_min_fyear = fyear - min_fyear
		drop min_fyear
		assert !missing(firm_age_min_fyear)
		assert firm_age_min_fyear>=0
		gen ln_firm_age_min_fyear = ln(1 + firm_age_min_fyear)

		gen book_to_market = ceq / (csho * prcc_f)
		gen rd_over_assets_0 = cond(!missing(xrd), xrd, 0) / ((at + L.at) / 2)
		gen roa = ib / ((at + L.at) / 2)

	xtset, clear

	label variable at "Total Assets, measured in Millions of USD"

	keep gvkey datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh
	order gvkey datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh

	isid gvkey datadate
	sort gvkey datadate

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 10", replace
	clear

use "${folder_original_databases}/Thomson_Reuters/wrds_stock_ownership/WRDS Thomson Reuters Stock Ownership - 2022-10-19", clear
	gen InstOwn_Perc_check = InstOwn / (shrout * 1000)
	assert float(InstOwn_Perc)==float(InstOwn_Perc_check)
	drop InstOwn_Perc_check

	assert missing(InstOwn_Perc) if (missing(shrout) | shrout==0) // "InstOwn_Perc" is missing only when either "shrout" is missing or zero.
	gen shrout_zero_miss = cond((missing(shrout) | shrout==0), 1, 0)

	keep rdate cusip InstOwn_HHI InstOwn_Perc shrout_zero_miss
	assert 0<=InstOwn_HHI & InstOwn_HHI<=1 if !missing(InstOwn_HHI)
	assert 0<=InstOwn_Perc if !missing(InstOwn_Perc) // According to the manual there are three reasons for institutional ownership being greater than 100%: 1) short positions are not reported, 2) shared investment discretion by multiple asset managers, and 3) issues with stock splits.

	assert !missing(rdate)
	gen day_month_string = substr(string(rdate, "%td"), 1, 5)
	label define order_day_month 	///
		1 "31mar" 					///
		2 "30jun" 					///
		3 "30sep" 					///
		4 "31dec"
	encode day_month_string, gen(day_month) label(order_day_month)

	quietly log on
		* Report the distribution of the day-months of the file date.
		tab day_month, miss
	quietly log off

	drop day_month day_month_string

	assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
	rename cusip cusip_8

	isid cusip_8 rdate
	sort cusip_8 rdate
	order cusip_8 rdate InstOwn_Perc InstOwn_HHI

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 11", replace
	clear

use "${folder_original_databases}/Thomson_Reuters/s34 Master File/Institutional Holdings - s34 Master File - 2022-10-19", clear
	drop if missing(cusip) // "cusip" is the variable I use as the security identifier.

	assert !missing(cusip, mgrno, rdate, fdate)
	duplicates report cusip mgrno rdate fdate
	assert `r(unique_value)'==`r(N)' // Verifies that "cusip", "mgrno", "rdate", and "fdate" form a unique identifier. According to the manuals available from WRDS, "rdate" represents the effective ownership date, whereas the "fdate" represents the vintage date at which the shares outstanding are valid. Because Thomson Reuters' 13F data carries forward institutional reports for up to 8 quarters, a given tuple "cusip"-"mgrno"-"rdate" can have multiple "fdate".
	sort cusip mgrno rdate fdate

	bysort cusip mgrno rdate (fdate): egen min_fdate = min(fdate)
	format %td min_fdate
	keep if fdate==min_fdate // I follow Ben-David et al. (2021) and keep the first "fdate" (the first vintage) for a given tuple "cusip"-"mgrno"-"rdate". Keeping the first instead of the last "fdate" also results in institutional ownership much closer to the aggregate institutional ownership data available on WRDS.
	drop min_fdate

	assert !missing(cusip, mgrno, rdate)
	duplicates report cusip mgrno rdate
	assert `r(unique_value)'==`r(N)'
	sort cusip mgrno rdate

	gen year_rdate = year(rdate)
	gen mgrname_stand = mgrname
	replace mgrname_stand = upper(mgrname_stand) // Capitalizes the string variable.
	replace mgrname_stand = strtrim(mgrname_stand) // Removes internal consecutive spaces.
	replace mgrname_stand = stritrim(mgrname_stand) // Removes leading and trailing spaces.
	assert !missing(mgrname_stand)

	assert !missing(mgrno)
	gen d_blackrock = ( 	/// I follow Ben-David et al. (2020).
		mgrno== 9385 | 		///
		mgrno==11386 | 		///
		mgrno==12588 | 		///
		mgrno==39539 | 		///
		mgrno==56790 | 		///
		mgrno==91430 		///
	)
	gen d_vanguard = (mgrno==90457)
	gen d_ssga = (mgrno==81540)
	gen d_big_3 = d_blackrock + d_vanguard + d_ssga
	assert d_big_3==0 | d_big_3==1 // There is no overlap among the Big Three classification.

	quietly log on
		* Shows the distribution of the combination of Manager Number - Year of the Report Date - Manager Name.
		foreach investor in blackrock vanguard ssga {
			groups mgrno year_rdate mgrname_stand if d_`investor'==1, sepby(mgrno)
		}
		tab d_big_3, miss
	quietly log off

	drop mgrname_stand year_rdate

	gen double prop_shares = cond(!missing(shrout2), shares / (shrout2 * 1000), shares / (shrout1 * 1000000)) // "shrout2" and "shrout1" are not constant within each "cusip"-"rdate" pair. Therefore, the proportion of shares owned has to be calculated before aggregating the data at "cusip"-"rdate". Because "shrout2" is more precise than "shrout1", I use the former whenever its value is not missing.
	assert !missing(shares) // The "prop_shares" is only missing because of the denominator (zero or missing) and never because of the numerator.

	foreach investor in blackrock vanguard ssga big_3 {
		quietly gen double prop_shares_`investor' = cond(d_`investor'==1, prop_shares, .)
	}

	collapse (sum) inst_own=prop_shares inst_own_blackrock=prop_shares_blackrock inst_own_vanguard=prop_shares_vanguard inst_own_ssga=prop_shares_ssga inst_own_big_3=prop_shares_big_3 (max) d_blackrock d_vanguard d_ssga d_big_3 (count) non_miss_prop_shares=prop_shares non_miss_prop_shares_blackrock=prop_shares_blackrock non_miss_prop_shares_vanguard=prop_shares_vanguard non_miss_prop_shares_ssga=prop_shares_ssga non_miss_prop_shares_big_3=prop_shares_big_3, by(cusip rdate)

	assert !missing(non_miss_prop_shares) & non_miss_prop_shares>=0
	gen all_shrout_zero_miss = cond(non_miss_prop_shares==0, 1, 0) // Keep in mind that "prop_shares" was missing only because of the denominator (zero or missing).
	assert !missing(inst_own)
	assert inst_own==0 if all_shrout_zero_miss==1
	replace inst_own = . if all_shrout_zero_miss==1 // I only set "inst_own" to missing if all values of "prop_shares" were missing for that particular "cusip"-"rdate". This is an analogous treatment to institutional investors that manage less than $100 million.
	drop non_miss_prop_shares

	foreach investor in blackrock vanguard ssga big_3 {
		assert d_`investor'==0 | d_`investor'==1
		assert !missing(non_miss_prop_shares_`investor') & non_miss_prop_shares_`investor'>=0
		quietly gen all_shrout_zero_miss_`investor' = cond(non_miss_prop_shares_`investor'==0, 1, 0)
		assert !missing(inst_own_`investor')
		assert inst_own_`investor'==0 if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // It is zero, but should be missing.
		quietly replace inst_own_`investor' = . if d_`investor'==1 & all_shrout_zero_miss_`investor'==1 // There was at least one 13F form from the investor, but the proportion of shares owned by it were all missing.
		assert inst_own_`investor'==0 if d_`investor'==0 & all_shrout_zero_miss==1 // It is zero, but should be missing.
		quietly replace inst_own_`investor' = . if d_`investor'==0 & all_shrout_zero_miss==1 // There was no 13F form from the investor and the proportion of shares owned by all shareholders were missing.
		drop non_miss_prop_shares_`investor' d_`investor'
	}

	drop all_shrout_zero_miss all_shrout_zero_miss_blackrock all_shrout_zero_miss_vanguard all_shrout_zero_miss_ssga all_shrout_zero_miss_big_3

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		gen miss_inst_`variab' = cond(missing(inst_`variab'), 1, 0) // If the underlying variable is missing in this database, its value should not be replaced with zero after merging.
	}

	assert !missing(rdate)
	gen day_month_string = substr(string(rdate, "%td"), 1, 5)
	label define order_day_month 	///
		1 "31mar" 					///
		2 "30jun" 					///
		3 "30sep" 					///
		4 "31dec"
	encode day_month_string, gen(day_month) label(order_day_month)

	quietly log on
		* Report the distribution of the day-months of the file date.
		tab day_month, miss
	quietly log off

	drop day_month day_month_string

	assert length(cusip)==8 // ISSDD's cusip is 9 characters long.
	rename cusip cusip_8

	rename rdate rdate_big_3
	isid cusip_8 rdate_big_3
	sort cusip_8 rdate_big_3

	isid cusip_8 rdate_big_3
	sort cusip_8 rdate_big_3
	order cusip_8 rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 12", replace
	clear

use "../../../data/external/sp500/Bloomberg/S&P Constituent Data_Static_formatted", clear
	assert sp_year==year(date)
	drop sp_year
	drop BloombergIdentifier
	drop ticker 
	replace cusip = "" if cusip=="#N/A N/A"
	drop if missing(cusip)
	gen sp_ = 1

	reshape wide sp_, i(cusip date) j(sp_index) string

	foreach sp in 500 400 600 {
		quietly replace sp_`sp' = 0 if missing(sp_`sp')
	}

	rename date date_sp
	keep cusip date_sp sp_500

	isid cusip date_sp
	sort cusip date_sp
	order cusip date_sp sp_500

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 13", replace
	clear

use "${folder_original_databases}/BLS/2012_2020_Compustat_NACIS_BLS_Merged_data", clear
	duplicates tag comp_naics year, gen(dup)
	drop if dup>0
	drop dup

	keep year comp_naics Total WomenPn BlackPn AsianPn HispanicPn
	rename comp_naics naics // Renamed to match the variable names in the main database.
	rename year year_naics_bls
	rename Total total_emp_by_naics_bls
	rename WomenPn pct_emp_women_by_naics_bls
	rename BlackPn pct_emp_b_by_naics_bls
	rename AsianPn pct_emp_a_by_naics_bls
	rename HispanicPn pct_emp_h_by_naics_bls

	foreach group in "women" "b" "a" "h" {
		quietly gen prop_emp_`group'_by_naics_bls = pct_emp_`group'_by_naics_bls / 100
		assert 0<=prop_emp_`group'_by_naics_bls & prop_emp_`group'_by_naics_bls<=1 if !missing(prop_emp_`group'_by_naics_bls) // Percentages should take values between 0% and 100%.
		drop pct_emp_`group'_by_naics_bls
	}

	* These commands forward track the last year another year.
		quietly sum year_naics_bls
		gen expand_last_year = 1
		replace expand_last_year = 2 if year_naics_bls==r(max)
		expand expand_last_year, gen(obs_last_year)
		replace year_naics_bls = year_naics_bls + 1 if obs_last_year==1
		drop expand_last_year obs_last_year

	keep year_naics_bls naics prop_emp_b_by_naics_bls

	* Lag all the variables:
		gen year_quarter_first_day = year_naics_bls + 1
		rename prop_emp_b_by_naics_bls prop_emp_b_by_naics_bls_lag
		drop year_naics_bls
		rename naics naics_lag

	isid naics_lag year_quarter_first_day
	sort naics_lag year_quarter_first_day
	order naics_lag year_quarter_first_day prop_emp_b_by_naics_bls_lag

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 14", replace
	clear

use "${folder_save_databases}/census_bureau/census_diversity_state_race_2021", clear

	keep state year local_pop_b

	* Lag all the variables:
		gen year_quarter_first_day = year + 1
		rename local_pop_b local_pop_b_lag
		drop year
		rename state state_of_address_lag

	isid state_of_address_lag year_quarter_first_day
	sort state_of_address_lag year_quarter_first_day
	order state_of_address_lag year_quarter_first_day

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 15", replace
	clear

use "${folder_original_databases}/Industry_Classification/SupplyChain_B2C_categorization_naics17_97_April2020 - 2022-04-21", clear // The US Bureau of Economic Analysis uses NAICS at a given year to prepare the input-output tables. "Comprehensive updates, which are typically conducted at 5-year intervals, tend to have a more expansive scope than annual updates and provide an opportunity to update the accounts to better reflect the evolving U.S. economy. These updates incorporate changes in definitions and classifications and statistical changes, which update the accounts through the use of new and improved estimation methods and newly available and revised source data, including the Economic Census which is used to benchmark the accounts."
	keep year
	duplicates drop // Keeps unique years.
	gen year_last = cond(!missing(year[_n + 1]), year[_n + 1], 2022) - 1 // If year is missing, the last one is the current year (2022).
	gen year_window = year_last - year + 1
	drop year_last
	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 16", replace
	clear

use "${folder_original_databases}/Industry_Classification/SupplyChain_B2C_categorization_naics17_97_April2020 - 2022-04-21", clear
	assert ustrlen(string(naicso_id, "%9.0f"))==6 // These are all six-digit NAICS. As Delgado and Mills (2020) explain, their classification does not map perfectly into firm-level data because some firms have establishments in multiple industries in SC (supply chain) and B2C (business-to-consumer).
	assert !missing(sc65, perc_supplies_to_pce)
	assert sc65==0 | sc65==1
	assert perc_supplies_to_pce<0.35 if sc65==1 // 0.35 is the cut-off used by the authors.
	assert perc_supplies_to_pce>=0.35 if sc65==0 // 0.35 is the cut-off used by the authors.

	keep naicso_id year sc65 perc_supplies_to_pce

	assert !missing(naicso_id, year)
	duplicates report naicso_id year
	assert `r(unique_value)'==`r(N)' // Verifies that the structure of the database is firm-year.
	sort naicso_id year
	order naicso_id year sc65

	merge m:1 year using "Merge Determinants of Exposure to Racial Diversity PR - Temp 16"
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 16.dta"
	assert _merge==3
	drop _merge

	expand year_window
	bysort naicso_id year: gen order = _n
	gen valid_year = year + order - 1
	drop year year_window order

	gen b2c_dm = 1 - sc65 if !missing(sc65)
	drop sc65
	rename perc_supplies_to_pce b2c_cont_dm

	rename valid_year datadate_year
	rename naicso_id naicsh
	keep naicsh datadate_year b2c_dm b2c_cont_dm

	* Lag all the variables:
		gen year_quarter_first_day = datadate_year + 1
		rename b2c_dm b2c_dm_lag
		rename b2c_cont_dm b2c_cont_dm_lag
		drop datadate_year
		rename naicsh naicsh_lag

	isid naicsh_lag year_quarter_first_day
	sort naicsh_lag year_quarter_first_day
	order naicsh_lag year_quarter_first_day b2c_dm_lag b2c_cont_dm_lag

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 17", replace
	clear

use "${folder_save_databases}/press_releases/all_press_releases_to_match_to_CCs", clear
gen id_pr = _n

gen date_pr = date(publication_date, "YMD")
format %td date_pr
assert !missing(date_pr)
drop publication_date

gen ticker = main_ticker
replace ticker = upper(ticker)
replace ticker = strtrim(ticker) // Removes internal consecutive spaces.
replace ticker = stritrim(ticker) // Removes leading and trailing spaces.
replace ticker = "" if ticker=="TRUE"
replace ticker = "" if ticker=="NAN"
replace ticker = subinstr(ticker, `"""', "", .)
replace ticker = subinstr(ticker, "$", "", .)
replace ticker = subinstr(ticker, "(", "", .)
replace ticker = subinstr(ticker, ")", "", .)
replace ticker = subinstr(ticker, "/", "", .)

drop main_ticker
drop if missing(ticker)
format %-20s ticker
assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".

assert (has_diversity_regex		==0 | has_diversity_regex		==1) if !missing(has_diversity_regex)
assert (diversity_subject_code	==0 | diversity_subject_code	==1) if !missing(diversity_subject_code)

isid id_pr
sort id_pr
order id_pr ticker date_pr has_diversity_regex diversity_subject_code

save "Merge Determinants of Exposure to Racial Diversity PR - Temp 18", replace
clear

* Creates a database of sequential quarters around GF's murder.
	use "Merge Determinants of Exposure to Racial Diversity PR - Temp 18", clear
	quietly sum date_pr
	local date_pr_min = r(min)
	local date_pr_max = r(max)
	clear

	local num_obs = 1
	set obs 1
	gen quarter_pr = 1
	gen quarter_first_day = td(25, May, 2020) + 1
	gen quarter_last_day = mdy(month(quarter_first_day) + 3, day(quarter_first_day) - 1, year(quarter_first_day))
	format %td quarter_first_day quarter_last_day

	while `date_pr_min'<quarter_first_day[1] {
		set obs `=_N + 1'
		quietly replace quarter_pr = quarter_pr[1] - 1 if _n==_N
		quietly replace quarter_first_day = cond( 																										///
											(month(quarter_first_day[1])==5 | 																			///
											month(quarter_first_day[1])==8 | 																			///
											month(quarter_first_day[1])==11), 																			///
												mdy(month(quarter_first_day[1]) - 3, day(quarter_first_day[1]), year(quarter_first_day[1])), 			///
											cond(month(quarter_first_day[1]==2), 																		///
												mdy(month(quarter_first_day[1]) + 9, day(quarter_first_day[1]), year(quarter_first_day[1]) - 1), 		///
											.)) if _n==_N // If none of these four months, then missing.
		quietly replace quarter_last_day = quarter_first_day[1] - 1 if _n==_N
		sort quarter_pr
	}

	while `date_pr_max'>quarter_last_day[_N] {
		set obs `=_N + 1'
		quietly replace quarter_pr = quarter_pr[_N-1] + 1 if _n==_N
		quietly replace quarter_first_day = quarter_last_day[_N-1] + 1 if _n==_N // If none of these four months, then missing.
		quietly replace quarter_last_day = cond( 																										///
											(month(quarter_last_day[_N-1])==2 | 																		///
											month(quarter_last_day[_N-1])==5 | 																			///
											month(quarter_last_day[_N-1])==8), 																			///
												mdy(month(quarter_last_day[_N-1]) + 3, day(quarter_last_day[_N-1]), year(quarter_last_day[_N-1])), 		///
											cond(month(quarter_last_day[_N-1]==11), 																	///
												mdy(month(quarter_last_day[_N-1]) - 9, day(quarter_last_day[_N-1]), year(quarter_last_day[_N-1]) + 1), 	///
											.)) if _n==_N // If none of these four months, then missing.
	}

	assert quarter_pr - quarter_pr[_n-1]==1 if _n!=1
	assert quarter_last_day>quarter_first_day

	isid quarter_pr
	sort quarter_pr

	save "Merge Determinants of Exposure to Racial Diversity PR - Temp 19", replace
	clear

* Creates a balanced quarterly panel with all firms that issued a press release at least once.
	use "Merge Determinants of Exposure to Racial Diversity PR - Temp 18", clear
	keep ticker
	duplicates drop
	assert !missing(ticker)

	cross using "Merge Determinants of Exposure to Racial Diversity PR - Temp 19"
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 19.dta"
	isid ticker quarter_pr
	sort ticker quarter_pr

	joinby ticker using "Merge Determinants of Exposure to Racial Diversity PR - Temp 18", unmatched(both)
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 18.dta"
	assert _merge==3
	drop _merge

	assert !missing(date_pr, quarter_first_day, quarter_last_day)

	foreach variab in id_pr has_diversity_regex diversity_subject_code {
		replace `variab' = . if (date_pr<quarter_first_day | date_pr>quarter_last_day)
	}

	duplicates drop

	collapse (max) has_diversity_regex diversity_subject_code (mean) quarter_first_day quarter_last_day, by(ticker quarter_pr)

	replace has_diversity_regex = 0 if missing(has_diversity_regex) // The "collapse" command results in missing only when all observations are missing. We considered the absence of a press release in the quarter as zero in this dataset. Later, we remove quarters for which there is no match to CRSP-Compustat Link Table.
	replace diversity_subject_code = 0 if missing(diversity_subject_code) // The "collapse" command results in missing only when all observations are missing. We considered the absence of a press release in the quarter as zero in this dataset. Later, we remove quarters for which there is no match to CRSP-Compustat Link Table.

	gen year_quarter_first_day = year(quarter_first_day)
	gen year_quarter_last_day = year(quarter_last_day)

	isid ticker quarter_pr
	sort ticker quarter_pr
	order ticker quarter_pr quarter_first_day quarter_last_day year_quarter_first_day year_quarter_last_day has_diversity_regex diversity_subject_code

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby ticker using "Merge Determinants of Exposure to Racial Diversity PR - Temp 1", unmatched(master)
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 1.dta"

	gen outside_window = cond((quarter_first_day < linkdt | quarter_first_day > linkenddt), 1, 0)

		foreach variab in conm linktype linkprim cusip {
			quietly replace `variab' = "" if outside_window==1
		}

		foreach variab in gvkey permno permco linkdt linkenddt gics_2_code_i {
			quietly replace `variab' = . if outside_window==1
		}

	drop outside_window

	duplicates tag, gen(dup)
	assert _merge==3 if dup>0 // Duplicates only happen when observations from both datasets matched.
	assert missing(conm, gvkey, cusip, permno, permco, linktype, linkprim, linkdt, linkenddt, gics_2_code_i) if dup>0
	drop dup
	duplicates drop // These are matched observations (_merge==3) based on "ticker" whose day does not fit the link window interval. One observation of each is kept.

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort ticker quarter_first_day: egen sum_valid_link = total(valid_link)
	drop if valid_link==0 & sum_valid_link>0 // In case of at least one match, drop instances of no valid link because the day does not fit the link window interval.
	drop valid_link sum_valid_link

	gen valid_link = cond(!missing(linktype, linkprim), 1, 0)
	bysort ticker quarter_first_day: egen sum_valid_link = total(valid_link)
	assert sum_valid_link==0 | sum_valid_link==1 // There is at most one match per "ticker"-"quarter_first_day" pair.
	drop valid_link sum_valid_link _merge

	isid ticker quarter_first_day
	sort ticker quarter_first_day

quietly count
assert `r(N)'==`num_obs' // Checks that the original number of observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby gvkey using "Merge Determinants of Exposure to Racial Diversity PR - Temp 9", unmatched(master) // There are missing "gvkey" values in the master database. It is ok to use "joinby" because there are no missing "gvkey" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 9.dta"
	duplicates report ticker quarter_first_day calendar_year_end // Some of the "calendar_year_end" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-calendar_year_end form a unique identifier.
	sort ticker quarter_first_day calendar_year_end

	gen days_dif = calendar_year_end - quarter_first_day

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort ticker quarter_first_day (calendar_year_end): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker quarter_first_day (calendar_year_end): egen max_month_year_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in company_event_id state_of_address {
		quietly replace `variab' = "" if sum_match_window==0
	}

	foreach variab in calendar_year_end dummy_dir_b prop_dir_b_o_identified prop_dir_b_o_board prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_month_year_dif retain

	foreach variab in company_event_id calendar_year_end dummy_dir_b prop_dir_b_o_identified prop_dir_b_o_board prop_dir_age_72_plus_o_ident ln_supply_dir_b network_size ln_network_size state_of_address {
		rename `variab' `variab'_lag
	}

	isid ticker quarter_first_day
	sort ticker quarter_first_day

quietly count
assert `r(N)'==`num_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local num_obs = r(N)

	joinby gvkey using "Merge Determinants of Exposure to Racial Diversity PR - Temp 10", unmatched(master) // There are missing "gvkey" values in the master database. It is ok to use "joinby" because there are no missing "gvkey" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 10.dta"
	duplicates report ticker quarter_first_day datadate // Some of the "datadate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that firm-year-datadate form a unique identifier.
	sort ticker quarter_first_day datadate

	gen days_dif = datadate - quarter_first_day

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort ticker quarter_first_day (datadate): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker quarter_first_day (datadate): egen max_month_year_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "gvkey" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the ISSDD database. They are needed to obtain the original number of observations in the ISSDD database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_month_year_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_month_year_dif retain

	foreach variab in datadate firm_visibility ln_firm_age_min_fyear book_to_market rd_over_assets_0 roa naics naicsh {
		rename `variab' `variab'_lag
	}

	isid ticker quarter_first_day
	sort ticker quarter_first_day

quietly count
assert `r(N)'==`num_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "Merge Determinants of Exposure to Racial Diversity PR - Temp 11", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 11.dta"
	duplicates report ticker quarter_first_day rdate // Some of the "rdate" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that "ticker"-"quarter_first_day"-"rdate" form a unique identifier.
	sort ticker quarter_first_day rdate

	assert day(rdate + 1)==1 if !missing(rdate) // The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.
	assert ( 				///
		month(rdate)==03 | 	///
		month(rdate)==06 | 	///
		month(rdate)==09 | 	///
		month(rdate)==12 	///
	) if !missing(rdate) 	// The precision of the variable "rdate" is quarterly, since it always contains the last day of the quarter.

	gen days_dif = rdate - quarter_first_day

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort ticker quarter_first_day (rdate): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker quarter_first_day (rdate): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 days_dif match_window sum_match_window max_days_dif retain

	foreach variab in rdate InstOwn_Perc InstOwn_HHI shrout_zero_miss {
		rename `variab' `variab'_lag
	}

	gen InstOwn_Perc_0_lag = cond((missing(InstOwn_Perc_lag) & !missing(cusip) & shrout_zero_miss_lag!=1), 0, InstOwn_Perc_lag) // I assume that form 13F is comprehensive and, therefore, substitute "InstOwn_Perc_lag" by zero, as long as "cusip" is not missing and "shrout" is neither zero or missing in the Thomson Reuters database.
	gen InstOwn_Perc_miss_lag = cond(missing(InstOwn_Perc_lag) & InstOwn_Perc_0_lag==0, 1, 0) if !missing(InstOwn_Perc_0_lag)
	drop shrout_zero_miss_lag

	isid ticker quarter_first_day
	sort ticker quarter_first_day

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of firm-year observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	assert length(cusip)==9 if !missing(cusip)
	gen cusip_8 = substr(cusip, 1, 8)

	joinby cusip_8 using "Merge Determinants of Exposure to Racial Diversity PR - Temp 12", unmatched(master) // There are missing "cusip_8" values in the master database. It is ok to use "joinby" because there are no missing "cusip_8" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 12.dta"
	duplicates report ticker quarter_first_day rdate_big_3 // Some of the "rdate_big_3" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that "ticker"-"quarter_first_day"-"rdate_big_3" form a unique identifier.
	sort ticker quarter_first_day rdate_big_3

	assert day(rdate_big_3 + 1)==1 if !missing(rdate_big_3) // The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.
	assert ( 						///
		month(rdate_big_3)==03 | 	///
		month(rdate_big_3)==06 | 	///
		month(rdate_big_3)==09 | 	///
		month(rdate_big_3)==12 		///
	) if !missing(rdate_big_3) 		// The precision of the variable "rdate_big_3" is quarterly, since it always contains the last day of the quarter.

	gen days_dif_big_3 = rdate_big_3 - quarter_first_day

	gen match_window = cond(days_dif_big_3<=-180 & days_dif_big_3>-540, 1, 0) if _merge==3
	bysort ticker quarter_first_day (rdate_big_3): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker quarter_first_day (rdate_big_3): egen max_days_dif_big_3 = max(days_dif_big_3) if match_window==1 & sum_match_window>1

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 days_dif_big_3 {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip_8" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif_big_3==max_days_dif_big_3 & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge cusip_8 days_dif_big_3 match_window sum_match_window max_days_dif_big_3 retain

	foreach variab in rdate_big_3 inst_own inst_own_blackrock inst_own_vanguard inst_own_ssga inst_own_big_3 miss_inst_own miss_inst_own_blackrock miss_inst_own_vanguard miss_inst_own_ssga miss_inst_own_big_3 {
		rename `variab' `variab'_lag
	}

	foreach variab in own own_blackrock own_vanguard own_ssga own_big_3 {
		quietly gen inst_`variab'_0_lag = cond((missing(inst_`variab'_lag) & !missing(cusip) & miss_inst_`variab'_lag!=1), 0, inst_`variab'_lag) // I assume that form 13F is comprehensive and, therefore, substitute the variables by zero, as long as "cusip" is not missing and the variables are not missing in the Thomson Reuters database.
		quietly gen inst_`variab'_miss_lag = cond(missing(inst_`variab'_lag) & inst_`variab'_0_lag==0, 1, 0) if !missing(inst_`variab'_0_lag)
		drop miss_inst_`variab'_lag
	}

	isid ticker quarter_first_day
	sort ticker quarter_first_day

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of observations is correct.

quietly count // Stores the number of observations in `r(N)'.
local unique_obs = r(N)

	joinby cusip using "Merge Determinants of Exposure to Racial Diversity PR - Temp 13", unmatched(master) // There are missing "cusip" values in the master database. It is ok to use "joinby" because there are no missing "cusip" values in the using database.
	erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 13.dta"
	duplicates report ticker quarter_first_day date_sp // Some of the "date_sp" values are missing.
	assert `r(unique_value)'==`r(N)' // Verifies that "ticker"-"quarter_first_day"-"date_sp" form a unique identifier.
	sort ticker quarter_first_day date_sp

	gen days_dif = date_sp - quarter_first_day

	gen match_window = cond(days_dif<=-180 & days_dif>-540, 1, 0) if _merge==3
	bysort ticker quarter_first_day (date_sp): egen sum_match_window = total(match_window) if _merge==3
	bysort ticker quarter_first_day (date_sp): egen max_days_dif = max(days_dif) if match_window==1 & sum_match_window>1

	foreach variab in date_sp sp_500 days_dif {
		quietly replace `variab' = . if sum_match_window==0
	}

	duplicates drop // Removes duplicate observations that matched on "cusip" but did not match on the time window interval.

	gen retain = 0
	replace retain = 1 if missing(match_window) // These are observations only present in the master database. They are needed to obtain the original number of observations in the master database.
	replace retain = 1 if sum_match_window==0 // I only kept one of these observations by setting the matched variables to missing and dropping duplicates.
	replace retain = 1 if match_window==1 & sum_match_window==1 // These observations have only one match.
	replace retain = 1 if days_dif==max_days_dif & sum_match_window>1 // For multiple matches, I selected the most recent observation.

	drop if retain==0
	drop _merge days_dif match_window sum_match_window max_days_dif retain

	foreach variab in date_sp sp_500 {
		rename `variab' `variab'_lag
	}

	replace sp_500_lag = 0 if missing(sp_500_lag) & !missing(cusip) // The Bloomberg database contains cusips only for S&P 1500. Any non-missing cusip observation in the master database should be considered non-S&P 500.

	isid ticker quarter_first_day
	sort ticker quarter_first_day

quietly count
assert `r(N)'==`unique_obs' // Checks that the original number of firm-year observations is correct.

merge m:1 naics_lag year_quarter_first_day using "Merge Determinants of Exposure to Racial Diversity PR - Temp 14", keep(match master) nogenerate
erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 14.dta"

merge m:1 state_of_address_lag year_quarter_first_day using "Merge Determinants of Exposure to Racial Diversity PR - Temp 15", keep(match master) nogenerate
erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 15.dta"

merge m:1 naicsh_lag year_quarter_first_day using "Merge Determinants of Exposure to Racial Diversity PR - Temp 17", keep(match master) nogenerate
erase "Merge Determinants of Exposure to Racial Diversity PR - Temp 17.dta"

isid ticker quarter_first_day
sort ticker quarter_first_day

save "${folder_save_databases}/Exposure to Racial Diversity/Merge Determinants of Exposure to Racial Diversity PR", replace
clear

**# Analyze determinants of exposure to racial diversity (press releases).
use "${folder_save_databases}/Exposure to Racial Diversity/Merge Determinants of Exposure to Racial Diversity PR", clear

drop if missing(gvkey) // Given that the balanced panel was artificially created based on the existence of the firm in Factiva, we remove quarters that do not match the CRSP-Compustat Link table.

gen post_george_floyd = cond(quarter_pr>=1, 1, 0)
keep if quarter_last_day >= td(01, Jan, 2019)
keep if quarter_first_day <= td(31, Dec, 2021)

assert abs(float(InstOwn_Perc_lag)-float(inst_own_lag))<0.01 if !missing(InstOwn_Perc_lag, inst_own_lag)
assert abs(float(InstOwn_Perc_0_lag)-float(inst_own_0_lag))<0.01 if !missing(InstOwn_Perc_0_lag, inst_own_0_lag)
drop inst_own_lag inst_own_0_lag

foreach variab in InstOwn_Perc_lag InstOwn_Perc_0_lag inst_own_blackrock_lag inst_own_blackrock_0_lag inst_own_vanguard_lag inst_own_vanguard_0_lag inst_own_ssga_lag inst_own_ssga_0_lag inst_own_big_3_lag inst_own_big_3_0_lag {
	replace `variab' = 1 if `variab'>1 & !missing(`variab')
}

* These commands winsorize the variables at 1% each tail.
foreach variab in book_to_market_lag roa_lag rd_over_assets_0_lag {
	quietly gen `variab'_w = `variab'
	quietly sum `variab', detail
	quietly replace `variab'_w = `r(p99)' if `variab'>`r(p99)' & !missing(`variab')
	quietly replace `variab'_w = `r(p1)' if `variab'<`r(p1)' & !missing(`variab')
	quietly local var_label: variable label `variab'
	quietly label variable `variab'_w "`var_label'"
	quietly drop `variab'
	display as text "Winsorizing at 1% each tail the variable `variab'"
}

save "${folder_save_databases}/Exposure to Racial Diversity/Analyze Determinants of Exposure to Racial Diversity PR", replace
clear

**# Standard ending code.
quietly timer off 1
quietly log on
quietly timer list 1
display "Total Time to Run the Code was " =string(`r(t1)' / 3600, "%12.2fc") " Hours"
log close
clear
exit, STATA

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}



* ----------------------------------------------------------------------------- *
*                								 T A B L E   2    			  			           	    *
* ----------------------------------------------------------------------------- *

use "${data_dir}/interim/Exposure to Racial Diversity/Analyze Determinants of Exposure to Racial Diversity", clear

label variable dummy_disclosure "Diversity Discussion$ _t$"
label variable diver_exposure_sent_perc		"Prop Diversity Sents$ _{t}$"
label variable prop_emp_b_by_naics_bls_lag	"Prop Emp Black NAICS$ _{t-1}$"
label variable local_pop_b_lag				"Local Black Population$ _{t-1}$"
label variable b2c_dm_lag					"B2C$ _{t-1}$"
label variable sp_500_lag					"S\&P 500$ _{t-1}$"
label variable firm_visibility_lag 			"Ln(Total Assets)$ _{t-1}$"
label variable InstOwn_Perc_0_lag 			"InstOwn$ _{t-1}$"
label variable ln_firm_age_min_fyear_lag	"Firm Age$ _{t-1}$"
label variable book_to_market_lag_w 		"Book-to-Market$ _{t-1}$"
label variable roa_lag_w 					"ROA$ _{t-1}$"


* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

global control_vars "ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w"

* Descriptive statistics.
tabstat dummy_disclosure diver_exposure_sent_perc prop_emp_b_by_naics_bls_lag           if !missing(dummy_disclosure, diver_exposure_sent_perc, prop_emp_b_by_naics_bls_lag,    b2c_dm_lag, sp_500_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w), by(post_george_floyd) statistics(count mean p50 sd) columns(statistics) longstub nototal
tabstat local_pop_b_lag                                                                 if !missing(dummy_disclosure, diver_exposure_sent_perc,                                 b2c_dm_lag, sp_500_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w), by(post_george_floyd) statistics(count mean p50 sd) columns(statistics) longstub nototal
tabstat b2c_dm_lag sp_500_lag firm_visibility_lag InstOwn_Perc_0_lag ${control_vars}    if !missing(dummy_disclosure, diver_exposure_sent_perc, prop_emp_b_by_naics_bls_lag,    b2c_dm_lag, sp_500_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w), by(post_george_floyd) statistics(count mean p50 sd) columns(statistics) longstub nototal


* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

global control_vars "ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w"
eststo clear
	* Dependent variable: "dummy_disclosure"
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag prop_emp_b_by_naics_bls_lag 	sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag local_pop_b_lag 				sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag prop_emp_b_by_naics_bls_lag 	firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag local_pop_b_lag 				firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	* Dependent variable: "diver_exposure_sent_perc"
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag prop_emp_b_by_naics_bls_lag 	sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag local_pop_b_lag 				sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag prop_emp_b_by_naics_bls_lag 	firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag local_pop_b_lag 				firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust


esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )   ///
    star(* 0.10 ** 0.05 *** 0.01)   ///
    stats(r2 N ,  ///
            fmt(%5.3fc %10.0gc )   ///
            labels("R2" "Observations" ))   ///
    indicate("Controls = ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w" , labels(Y N))   ///
    varwidth(40) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(prop_emp_b_by_naics_bls_lag local_pop_b_lag b2c_dm_lag sp_500_lag firm_visibility_lag InstOwn_Perc_0_lag) nobase nomtitles


* --------------------------------------------- *
*                 P A N E L   C            	    *
* --------------------------------------------- *

eststo clear
	* Dependent variable: "dummy_disclosure"
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag prop_emp_b_by_naics_bls_lag 	sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag local_pop_b_lag 				sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag prop_emp_b_by_naics_bls_lag 	firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg dummy_disclosure 			b2c_dm_lag local_pop_b_lag 				firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	* Dependent variable: "diver_exposure_sent_perc"
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag prop_emp_b_by_naics_bls_lag 	sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag local_pop_b_lag 				sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag prop_emp_b_by_naics_bls_lag 	firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg diver_exposure_sent_perc 	b2c_dm_lag local_pop_b_lag 				firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust


esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )   ///
    star(* 0.10 ** 0.05 *** 0.01)   ///
    stats(r2 N ,  ///
            fmt(%5.3fc %10.0gc )   ///
            labels("R2" "Observations" ))   ///
    indicate("Controls = ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w" , labels(Y N))   ///
    varwidth(40)  ///
  	label compress nogaps noconst eqlabels(none) collabels(none) order(prop_emp_b_by_naics_bls_lag local_pop_b_lag b2c_dm_lag sp_500_lag firm_visibility_lag InstOwn_Perc_0_lag) nobase nomtitles







*

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}


use "${data_dir}/interim/Others/DB Analysis of Returns to Conference Calls.dta", clear

preserve
  use "${data_dir}/interim/conference_calls/DB_Analysis_of_Returns_to_Conference_Calls_with_returns.dta", clear
  keep cc_id risk_exposure_all ccdate_car_m1p1 ccdate_bhar_m1p1
  tempfile crsp
  save "`crsp'", replace
restore
merge 1:1 cc_id using "`crsp'", keep(match) nogenerate

rename ln_mve_lag mve_lag_log

gen dummy_disclosure = diver_exposure_sent > 0 if ~mi(diver_exposure_sent)
gen p_diver_sents = diver_exposure_sent * 100

gen initiative_bow = cond(n_initiative_words_cc>0,1,0) if !missing(n_initiative_words_cc)

gen dummy_initiative = cond((cc_with_init==1)|(initiative_bow==1),1,0) if ~missing(cc_with_init, initiative_bow)

gen dummy_race = cond(p_race_sents >0, 1, 0) if !missing(p_race_sents)
gen dummy_gender = cond(p_gender_sents >0, 1, 0) if !missing(p_gender_sents)
tab dummy_disclosure dummy_race


winsor2 book_to_market_lag roa_lag, replace cuts(1 99)

gen passive_dummy = cond(passive_exposure > 0, 1, 0) if !missing(passive_exposure)
gen passive_no_init = (1-dummy_initiative)*passive_dummy
gen init_with_passive = dummy_initiative * passive_dummy
gen init_with_no_passive = (1-passive_dummy) * dummy_initiative
gen no_passive_no_init = (1-dummy_initiative)*(1-passive_dummy)

label var ccdate_bhar_m1p1 "BHAR$ _t$"
label var dummy_disclosure "Diversity Discussion$ _t$"
label var diver_exposure_sent "Prop Diversity Sents$ _t$"
label var dummy_race "Race Discussion$ _{t}$"
label var dummy_gender "Gender Discussion$ _{t}$"
label var sentiment_all "Sentiment$ _t$"
label var sue_new_dec_scaled "SUE$ _t$"
label var book_to_market_lag "Book-to-Market$ _{t-1}$"
label var roa_lag   "ROA$ _{t-1}$"
label var dummy_initiative "Initiative$ _t$"
label var mve_lag_log "Ln(MVE)$ _{t-1}$"
label var roa_lag "ROA$ _{t-1}$"
label var passive_dummy "Passive Words$ _t$"



* ----------------------------------------------------------------------------- *
*                								 T A B L E   3    			  			           	    *
* ----------------------------------------------------------------------------- *

* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *


global if_notmiss if !mi(ccdate_bhar_m1p1, dummy_disclosure, sentiment_all, sue_new_dec_scaled, book_to_market_lag, mve_lag_log, roa_lag)

sum ccdate_bhar_m1p1 dummy_disclosure diver_exposure_sent dummy_race dummy_gender ///
      sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag ///
      $if_notmiss




* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

quietly {
  eststo clear
  eststo: reg ccdate_bhar_m1p1 dummy_disclosure sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg ccdate_bhar_m1p1 diver_exposure_sent sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg ccdate_bhar_m1p1 dummy_race sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg ccdate_bhar_m1p1 dummy_gender sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg ccdate_bhar_m1p1 dummy_race dummy_gender sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag, robust
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )   ///
    star(* 0.10 ** 0.05 *** 0.01)   ///
    stats(r2 N ,  ///
            fmt(%5.3fc %10.0gc )   ///
            labels("R2" "Observations" ))   ///
    indicate( , labels(Y N))   ///
    varwidth(40)  ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(dummy_disclosure diver_exposure_sent dummy_race dummy_gender sentiment_all sue_new_dec_scaled) nobase nomtitles





* ----------------------------------------------------------------------------- *
*                								 T A B L E   4    			  			           	    *
* ----------------------------------------------------------------------------- *


* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

global if_notmiss if !mi(ccdate_bhar_m1p1, dummy_disclosure, dummy_race, dummy_gender, sentiment_all, sue_new_dec_scaled, book_to_market_lag, mve_lag_log, roa_lag)

noisily sum ccdate_bhar_m1p1 dummy_disclosure dummy_initiative passive_dummy ///
      sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag ///
      $if_notmiss


* --------------------------------------------- *
*                 P A N E L   B           	    *
* --------------------------------------------- *

quietly {
  eststo clear
  eststo: reg ccdate_bhar_m1p1 dummy_disclosure dummy_initiative passive_dummy sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg ccdate_bhar_m1p1 dummy_initiative passive_dummy sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag  if diver_exposure_sent > 0, robust
  eststo: reg ccdate_bhar_m1p1 dummy_initiative sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag  if diver_exposure_sent > 0 & passive_dummy == 0, robust
  eststo: reg ccdate_bhar_m1p1 dummy_initiative sentiment_all sue_new_dec_scaled book_to_market_lag mve_lag_log roa_lag  if diver_exposure_sent > 0 & passive_dummy == 1, robust
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate( , labels(Y N))  ///
    varwidth(40) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(dummy_disclosure dummy_initiative passive_dummy sentiment_all sue_new_dec_scaled) nobase nomtitles

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}


* ----------------------------------------------------------------------------- *
*                								 T A B L E   6    			  			           	    *
* ----------------------------------------------------------------------------- *

use "${data_dir}/interim/Exposure to Racial Diversity/Analyze Determinants of Exposure to Racial Diversity PR", clear

label var has_diversity_regex "PR Diversity Discussion$ _{t}$"
label var prop_emp_b_by_naics_bls_lag "Prop Emp Black NAICS$ _{t-1}$"
label var local_pop_b_lag "Local Black Population$ _{t-1}$"
label var b2c_dm_lag	"B2C$ _{t-1}$"
label var sp_500_lag	"S\&P 500$ _{t-1}$"
label var firm_visibility_lag 			"Ln(Total Assets)$ _{t-1}$"
label var InstOwn_Perc_0_lag 			"InstOwn$ _{t-1}$"
label var ln_firm_age_min_fyear_lag	"Firm Age$ _{t-1}$"
label var book_to_market_lag_w 		"Book-to-Market$ _{t-1}$"
label var roa_lag_w 					"ROA$ _{t-1}$"

global control_vars "ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w"

* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

sum has_diversity_regex if !missing(has_diversity_regex, local_pop_b_lag, 				b2c_dm_lag, sp_500_lag, firm_visibility_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w) & post_george_floyd==1
sum prop_emp_b_by_naics_bls_lag  if !missing(has_diversity_regex, prop_emp_b_by_naics_bls_lag, 	b2c_dm_lag, sp_500_lag, firm_visibility_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w) & post_george_floyd==1
sum local_pop_b_lag b2c_dm_lag sp_500_lag firm_visibility_lag InstOwn_Perc_0_lag ${control_vars} 	if !missing(has_diversity_regex, local_pop_b_lag, 				b2c_dm_lag, sp_500_lag, firm_visibility_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w) & post_george_floyd==1

sum has_diversity_regex if !missing(has_diversity_regex, local_pop_b_lag, 				b2c_dm_lag, sp_500_lag, firm_visibility_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w) & post_george_floyd==0
sum prop_emp_b_by_naics_bls_lag  if !missing(has_diversity_regex, prop_emp_b_by_naics_bls_lag, 	b2c_dm_lag, sp_500_lag, firm_visibility_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w) & post_george_floyd==0
sum local_pop_b_lag b2c_dm_lag sp_500_lag firm_visibility_lag InstOwn_Perc_0_lag ${control_vars} 	if !missing(has_diversity_regex, local_pop_b_lag, 				b2c_dm_lag, sp_500_lag, firm_visibility_lag, InstOwn_Perc_0_lag, ln_firm_age_min_fyear_lag, book_to_market_lag_w, roa_lag_w) & post_george_floyd==0


* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

global control_vars "ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w"
eststo clear
	* Post-George Floyd period.
	eststo: quietly reg has_diversity_regex b2c_dm_lag prop_emp_b_by_naics_bls_lag 	sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg has_diversity_regex b2c_dm_lag local_pop_b_lag 				sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg has_diversity_regex b2c_dm_lag prop_emp_b_by_naics_bls_lag 	firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	eststo: quietly reg has_diversity_regex b2c_dm_lag local_pop_b_lag 				firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==1, 	robust
	* Pre-George Floyd period.
	eststo: quietly reg has_diversity_regex b2c_dm_lag prop_emp_b_by_naics_bls_lag 	sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg has_diversity_regex b2c_dm_lag local_pop_b_lag 				sp_500_lag 			InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg has_diversity_regex b2c_dm_lag prop_emp_b_by_naics_bls_lag 	firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust
	eststo: quietly reg has_diversity_regex b2c_dm_lag local_pop_b_lag 				firm_visibility_lag InstOwn_Perc_0_lag 						${control_vars} if post_george_floyd==0, 	robust


esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate("Controls = ln_firm_age_min_fyear_lag book_to_market_lag_w roa_lag_w" , labels(Y N))  ///
    varwidth(40) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(prop_emp_b_by_naics_bls_lag local_pop_b_lag b2c_dm_lag sp_500_lag firm_visibility_lag InstOwn_Perc_0_lag) nobase nomtitles

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}

use "${data_dir}/interim/Press_Releases/DB Obtain Independent Variables for Press Releases with Regex.dta", clear
drop diversity_sent

global after_GF if publication_date >=td(25may2020)
keep $after_GF

rename ln_mve_lag mve_lag_log

gen dummy_disclosure = diver_exposure_sent > 0 if ~mi(diver_exposure_sent)
gen dummy_no_disclosure = 1 - dummy_disclosure
gen p_diver_sents = diver_exposure_sent * 100


winsor2 book_to_market_lag roa_lag, replace cuts(1 99)

gen pub_year = year(publication_date)
keep if pub_year < 2022

label var bhar "BHAR$ _t$"
label var dummy_disclosure	"PR Diversity Discussion$ _{t}$"
label var sentiment_all "PR Sentiment$ _t$"
label var book_to_market_lag "Book-to-Market$ _{t-1}$"
label var mve_lag_log "Ln(MVE)$ _{t-1}$"
label var roa_lag "ROA$ _{t-1}$"
label var diver_exposure_sent "PR Prop Diversity Sents$ _{t}$"
label var diversity_subject_code "PR Diversity Subject Code$ _t$"


* ----------------------------------------------------------------------------- *
*                								 T A B L E   7    			  			           	    *
* ----------------------------------------------------------------------------- *


* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

global if_notmiss if !mi(bhar, diversity_subject_code, dummy_disclosure, diver_exposure_sent, sentiment_all, book_to_market_lag, mve_lag_log, roa_lag)

sum bhar dummy_disclosure diver_exposure_sent diversity_subject_code sentiment_all book_to_market_lag mve_lag_log roa_lag ///
      $if_notmiss


* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

quietly {
  eststo clear
  eststo: reg bhar dummy_disclosure sentiment_all book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg bhar diver_exposure_sent sentiment_all book_to_market_lag mve_lag_log roa_lag, robust
  eststo: reg bhar dummy_disclosure diversity_subject_code sentiment_all book_to_market_lag mve_lag_log roa_lag , robust
  eststo: reg bhar diver_exposure_sent diversity_subject_code sentiment_all book_to_market_lag mve_lag_log roa_lag , robust
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate( , labels(Y N))  ///
    varwidth(40) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(dummy_disclosure diver_exposure_sent diversity_subject_code sentiment_all) nobase nomtitles

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}


use "${data_dir}/interim/DB Determinants of Racial Diversity - DP.dta", clear

gen no_black = prop_dir_b_o_board == 0
xtset iss_company_id calendar_year
gen no_black_lag = l.no_black

gen sample_to_2021 = cond( 							///
	filter_us 					==1 	& 	///
	filter_has_gvkey 			==1 	& 	///
	filter_has_cik 				==1 	& 	///
	filter_gics_non_financial 	==1 	& 	///
	filter_board_size 			==1 	& 	///
	filter_prop_dir_ident 		==1 &		///
  calendar_year >= 2014 ///
, 1, 0) if ///
	!missing(filter_us) 				& 	///
	!missing(filter_has_gvkey) 			& 	///
	!missing(filter_has_cik) 			& 	///
	!missing(filter_gics_non_financial) & 	///
	!missing(filter_board_size) 		& 	///
	!missing(filter_prop_dir_ident) 	& 	///
	!missing(filter_period_year)

keep if sample_to_2021 == 1


replace InstOwn_Perc_0_lag = 1 if InstOwn_Perc_0_lag > 1 & ~mi(InstOwn_Perc_0_lag)

winsor2 book_to_market_lag roa_lag rd_over_assets_lag rd_over_assets_0_lag // 1% 99%

global supply_vars ln_supply_dir_b_lag local_pop_b_lag


* Make proportions percentages
foreach eth in b w hl hlnw h ai a {
  capture gen p_emp_`eth'_by_naics_bls_lag = prop_emp_`eth'_by_naics_bls_lag * 100
  capture gen p_local_pop_`eth'_lag = local_pop_`eth'_lag * 100
}
gen p_dir_age_72_plus_o_ident_lag = prop_dir_age_72_plus_o_ident_lag * 100
gen p_dir_b_o_board = prop_dir_b_o_board * 100
gen p_dir_hl_o_board = prop_dir_hl_o_board * 100
gen p_dir_ai_o_board = prop_dir_ai_o_board * 100
gen p_dir_w_o_board = prop_dir_w_o_board * 100


foreach var in InstOwn_Perc_0_lag inst_own_big_3_0_lag firm_visibility_lag ln_supply_dir_b_lag ///
						 	ln_network_size_lag p_local_pop_b_lag p_emp_b_by_naics_bls_lag ln_supply_dir_hl_lag ///
							p_local_pop_hl_lag p_emp_h_by_naics_bls_lag ln_supply_dir_hl_lag p_local_pop_hlnw_lag ///
							p_emp_h_by_naics_bls_lag ln_supply_dir_ai_lag p_local_pop_ai_lag p_emp_a_by_naics_bls_lag ///
							prop_emp_b_by_naics_bls_lag local_pop_b_lag {
	capture drop `var'_m `var'_dm
	egen `var'_m = mean(`var')
	gen `var'_dm = `var' - `var'_m
}


preserve
      import_delimited using "${data_dir}/interim/conference_calls/exposure_all_tickers.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear

      assert source=="ticker_text" | source=="ticker1"
      assert ticker_used==ticker_text if source=="ticker_text"
      assert ticker_used==ticker1 if source=="ticker1"
      drop ticker_text ticker1 // There is no need for these variables.
      rename ticker_used ticker

      assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
      assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".
      assert ticker==upper(ticker)
      drop if missing(ticker)

      keep if source=="ticker_text"
      rename source source_match_ticker

      assert !missing(ticker) // I kept tickers with "-OLD" as two different tickers because they seem to be from two different firms. For example, "Accel Entertainment" and "Alfacell" both were traded as "ACEL" at different points in time.
      duplicates report ticker
      assert `r(unique_value)'==`r(N)'
      sort ticker

      save "DB Determinants of Racial Diversity Regressions - Temp 1", replace
      clear
restore

assert ticker==upper(ticker)
replace ticker = regexs(1) if regexm(ticker, "^(.*)\..*$") // Discards the dot and everything after it. For example, Instructure Inc. has "ticker" value as "INST.XX2" in ISS, while in Seeking Alpha it has value "INST". One letter tickers are fine. For example, Lowes Corp.'s ticker is "L".

merge m:1 ticker using "DB Determinants of Racial Diversity Regressions - Temp 1", keep(match master) nogenerate
erase "DB Determinants of Racial Diversity Regressions - Temp 1.dta"
capture drop _merge
capture rename gics_2_code gics_2_code_i


* ----------------------------------------------------------------------------- *
*                								 T A B L E   8    			  			           	    *
* ----------------------------------------------------------------------------- *
label var dummy_dir_b "Black Dir"
label var no_black_lag "No Black Dir$ _{t-1}$"
label var ln_supply_dir_b_lag_dm "Ln(Supply Black Dir)$ _{t-1}$"
label var prop_emp_b_by_naics_bls_lag_dm "Prop Emp Black NAICS$ _{t-1}$"
label var local_pop_b_lag_dm "Local Black Population$ _{t-1}$"
label var ln_network_size_lag_dm "Ln(Network Size)$ _{t-1}$"
label var prop_dir_age_72_plus_o_ident_lag "Prop Dir Age 72+$ _{t-1}$"
label var inst_own_big_3_0_lag_dm "Big3 InstOwn$ _{t-1}$"
label var sp500 "S\&P 500$ _{t-1}$"
label var firm_visibility_lag "Ln(Total Assets)$ _{t-1}$"
label var book_to_market_lag "Book-to-Market$ _{t-1}$"
label var rd_over_assets_0_lag "R\&D/Assets$ _{t-1}$"
label var ln_firm_age_min_fyear_lag	"Firm Age$ _{t-1}$"
label var roa_lag "ROA$ _{t-1}$"

* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

global reg_vars ln_supply_dir_b_lag_dm prop_emp_b_by_naics_bls_lag_dm local_pop_b_lag_dm ln_network_size_lag_dm prop_dir_age_72_plus_o_ident_lag ///
								inst_own_big_3_0_lag_dm sp500 firm_visibility_lag book_to_market_lag rd_over_assets_0_lag ln_firm_age_min_fyear_lag roa_lag
global order_output ln_supply_dir_b_lag_dm ln_network_size_lag_dm local_pop_b_lag_dm prop_emp_b_by_naics_bls_lag_dm inst_own_big_3_0_lag_dm

eststo clear
forvalues year = 2014(1)2021 {
	quietly probit dummy_dir_b $reg_vars i.gics_2_code_i if calendar_year == `year', vce(robust)
  quietly eststo m`year': margins, dydx(*) post
}

esttab m2014 m2015 m2016 m2017 m2018 m2019 m2020 m2021 , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )   ///
    star(* 0.10 ** 0.05 *** 0.01)   ///
    stats(r2 N ,  ///
            fmt(%5.3fc %10.0gc )   ///
            labels("R2" "Observations" ))   ///
    indicate( , labels(Y N))   ///
    varwidth(40) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(ln_supply_dir_b_lag_dm ln_network_size_lag_dm local_pop_b_lag_dm prop_emp_b_by_naics_bls_lag_dm inst_own_big_3_0_lag_dm) keep(ln_supply_dir_b_lag_dm ln_network_size_lag_dm local_pop_b_lag_dm prop_emp_b_by_naics_bls_lag_dm inst_own_big_3_0_lag_dm) mtitles("2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021") nonumbers



* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

tabstat dummy_dir_b if ~missing(no_black_lag, ln_supply_dir_b_lag_dm, prop_emp_b_by_naics_bls_lag_dm, local_pop_b_lag_dm, ln_network_size_lag_dm, prop_dir_age_72_plus_o_ident_lag, inst_own_big_3_0_lag_dm, sp500, firm_visibility_lag, book_to_market_lag, rd_over_assets_0_lag, ln_firm_age_min_fyear_lag, roa_lag, gics_2_code_i), by(calendar_year)

global reg_vars i.no_black_lag ln_supply_dir_b_lag_dm prop_emp_b_by_naics_bls_lag_dm local_pop_b_lag_dm ln_network_size_lag_dm prop_dir_age_72_plus_o_ident_lag ///
								inst_own_big_3_0_lag_dm sp500 firm_visibility_lag book_to_market_lag rd_over_assets_0_lag ln_firm_age_min_fyear_lag roa_lag

eststo clear
forvalues year = 2014(1)2021 {
	quietly probit dummy_dir_b $reg_vars i.gics_2_code_i if calendar_year == `year', vce(robust)
  quietly eststo m`year': margins no_black_lag, post
}

esttab m2014 m2015 m2016 m2017, ci ///
		mtitles("2014" "2015" "2016" "2017") nonumbers indicate( ) varwidth(20)

esttab m2018 m2019 m2020 m2021, ci ///
		mtitles("2018" "2019" "2020" "2021") nonumbers indicate( ) varwidth(20)



* --------------------------------------------- *
*                 P A N E L   C            	    *
* --------------------------------------------- *

replace diver_exposure_sent_avg = diver_exposure_sent_avg * 100 if ~mi(diver_exposure_sent_avg)
gen no_discl_avg = 100 - diver_exposure_sent_avg
gen dummy_no_discl_avg_test = no_discl_avg == 100 if ~mi(no_discl_avg)

gen dummy_diver_discl_avg = diver_exposure_sent_avg > 0 if ~mi(diver_exposure_sent_avg)
gen dummy_no_discl_avg = 1 - dummy_diver_discl_avg
assert dummy_no_discl_avg == dummy_no_discl_avg_test
drop dummy_no_discl_avg_test

label var dummy_no_discl_avg "No Diversity Discussion"

tabstat dummy_dir_b if ~missing(dummy_no_discl_avg, ln_supply_dir_b_lag_dm, prop_emp_b_by_naics_bls_lag_dm, local_pop_b_lag_dm, ln_network_size_lag_dm, prop_dir_age_72_plus_o_ident_lag, inst_own_big_3_0_lag_dm, sp500, firm_visibility_lag, book_to_market_lag, rd_over_assets_0_lag, ln_firm_age_min_fyear_lag, roa_lag, gics_2_code_i), by(calendar_year)


global reg_vars i.dummy_no_discl_avg ln_supply_dir_b_lag_dm prop_emp_b_by_naics_bls_lag_dm local_pop_b_lag_dm ln_network_size_lag_dm prop_dir_age_72_plus_o_ident_lag ///
								inst_own_big_3_0_lag_dm sp500 firm_visibility_lag book_to_market_lag rd_over_assets_0_lag ln_firm_age_min_fyear_lag roa_lag

eststo clear
forvalues year = 2014(1)2021 {
	quietly eststo: probit dummy_dir_b $reg_vars i.gics_2_code_i if calendar_year == `year', vce(robust)
  quietly eststo m`year': margins dummy_no_discl_avg, post
}

esttab m2014 m2015 m2016 m2017, ci ///
		mtitles("2014" "2015" "2016" "2017") nonumbers indicate( ) varwidth(20)

esttab m2018 m2019 m2020 m2021, ci ///
		mtitles("2018" "2019" "2020" "2021") nonumbers indicate( ) varwidth(20)

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}


use "${data_dir}/interim/As You Sow/DB As You Sow - Analysis", clear

global control_vars firm_visibility_lag book_to_market_lag_w roa_lag_w InstOwn_Perc_0_lag dummy_sp_500
global period_constraint period > 2


label var firm_visibility_lag "Ln(Total Assets)$ _{t-1}$"
label var firm_visibility_lag 				"Ln(Total Assets)$ _{t-1}$"
label var book_to_market_lag_w 			"Book-to-Market$ _{t-1}$"
label var roa_lag_w 						"ROA$ _{t-1}$"
label var InstOwn_Perc_0_lag 				"InstOwn$ _{t-1}$"
label var dummy_sp_500 					"S\&P 500$ _{t-1}$"
label var raw_rji_score 					"AYS Racial Justice Scorecard"
label var raw_rji_score_no_envir 			"AYS Racial Justice Scorecard Adj"
label var rji_b_4_1_dei_intrnl_dept 		"AYS Internal DEI Dept"
label var rji_b_4_2_dei_ldr_ttle 			"AYS DEI Leader Title"
label var rji_b_5_6_explct_dvrsty_goal 	"AYS Diversity Goal"
label var rji_b_5_8_supply_chain_divrse 	"AYS Supply Chain Diversif"
label var rji_b_6_1_cmty_eng_rj 			"AYS Community Engagement"
label var rji_b_6_2_rj_donations 			"AYS Racial Justice Donations"
label var dummy_disclosure_lag 			"Diversity Discussion$ _{t-1}$"
label var sum_dummy_disclosure_lag "$\sum_{j=1}^{4} \text{Diversity Discussion} _{t-j}$"
label var period "Period"

* ----------------------------------------------------------------------------- *
*                								 T A B L E   9    			  			           	    *
* ----------------------------------------------------------------------------- *


* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

sum raw_rji_score raw_rji_score_no_envir rji_b_4_1_dei_intrnl_dept rji_b_4_2_dei_ldr_ttle rji_b_5_6_explct_dvrsty_goal ///
      rji_b_5_8_supply_chain_divrse rji_b_6_1_cmty_eng_rj rji_b_6_2_rj_donations ///
      dummy_disclosure_lag sum_dummy_disclosure_lag $control_vars ///
      if !missing(raw_rji_score, sum_dummy_disclosure_lag, firm_visibility_lag, book_to_market_lag_w, roa_lag_w, InstOwn_Perc_0_lag, dummy_sp_500)



* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

quietly {
  eststo clear
	eststo: reg raw_rji_score 					c.sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
	eststo: reg raw_rji_score 					i.sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
	eststo: reg raw_rji_score_no_envir 			c.sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
  eststo: reg raw_rji_score_no_envir 			i.sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "t(par fmt(%5.2fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate(  "Year-Quarter F.E. = *period* ", labels(Y N))  ///
    varwidth(70) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(sum_dummy_disclosure_lag 1.sum_dummy_disclosure_lag 2.sum_dummy_disclosure_lag 3.sum_dummy_disclosure_lag 4.sum_dummy_disclosure_lag firm_visibility_lag book_to_market_lag_w roa_lag_w InstOwn_Perc_0_lag dummy_sp_500) nobase mtitles("AYS Original" "AYS Original" "AYS Adj." "AYS Adj.")




* --------------------------------------------- *
*                 P A N E L   C            	    *
* --------------------------------------------- *
quietly {
  eststo clear
  eststo: reg rji_b_4_1_dei_intrnl_dept sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
  eststo: reg rji_b_4_2_dei_ldr_ttle sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
  eststo: reg rji_b_5_6_explct_dvrsty_goal sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
	eststo: reg rji_b_5_8_supply_chain_divrse sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
	eststo: reg rji_b_6_1_cmty_eng_rj sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
	eststo: reg rji_b_6_2_rj_donations sum_dummy_disclosure_lag $control_vars i.period if $period_constraint, 	vce(robust)
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "t(par fmt(%5.2fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate(  "Year-Quarter F.E. = *period* ", labels(Y N))  ///
    varwidth(40) ///
    label compress nogaps noconst eqlabels(none) collabels(none) order(sum_dummy_disclosure_lag firm_visibility_lag book_to_market_lag_w roa_lag_w InstOwn_Perc_0_lag dummy_sp_500) nobase mtitles("DEI Dept" "DEI Leader" "Diversity Goal" "Supply Chain" "Community" "Donations")

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}

* ----------------------------------------------------------------------------- *
*                								 T A B L E   10    			  			           	    *
* ----------------------------------------------------------------------------- *

use "${data_dir}/interim/press_releases/all_press_releases_to_match_to_CCs", clear
	gen id_pr = _n

	gen date_pr = date(publication_date, "YMD")
	format %td date_pr
	assert !missing(date_pr)
	drop publication_date

	gen ticker = main_ticker
	replace ticker = upper(ticker)
	replace ticker = strtrim(ticker) // Removes internal consecutive spaces.
	replace ticker = stritrim(ticker) // Removes leading and trailing spaces.
	replace ticker = "" if ticker=="TRUE"
	replace ticker = "" if ticker=="NAN"
	replace ticker = subinstr(ticker, `"""', "", .)
	replace ticker = subinstr(ticker, "$", "", .)
	replace ticker = subinstr(ticker, "(", "", .)
	replace ticker = subinstr(ticker, ")", "", .)
	replace ticker = subinstr(ticker, "/", "", .)

	drop main_ticker
	drop if missing(ticker)
	format %-20s ticker
	assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
	assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".

	assert (has_diversity_regex		==0 | has_diversity_regex		==1)
	assert (diversity_subject_code	==0 | diversity_subject_code	==1)

	isid id_pr
	sort id_pr
	order id_pr ticker date_pr has_diversity_regex diversity_subject_code

	quietly sum date_pr
	local date_pr_min = r(min)

	clear

use "${data_dir}/interim/Others/DB Director Appointments - Exclude Press Releases", clear

global factiva_sample = "file_date>=`date_pr_min' & !missing(pr_count)" // Constrains the sample to after the first press release and matching tickers with Factiva.
global no_other_press_release = "(pr_count==0 | pr_count==1)"

label variable fd_bhar_m1p1 				"BHAR"
label variable dir_black 					"Black Appoint"
label variable dir_hl 						"Hisp Appoint"
label variable dir_ai 						"Asian Appoint"
label variable dir_w 						"White Appoint"
label variable enlargement_board 			"Board Enlargement"
label variable at_least_one_black_board_lag "$\text{Black Dir}_{t-1}$"
label variable post_george_floyd 			"Post George Floyd"
label variable book_to_market_lag 			"$\text{Book-to-Market}_{t-1}$"
label variable ln_mve_lag 					"$\text{Ln(MVE)}_{t-1}$"
label variable roa_lag 						"$\text{ROA}_{t-1}$"
label variable post_george_floyd_3m 		"Post GF 3 Months"
label variable post_george_floyd_rest_2020 	"Post GF Rest of 2020"
label variable dir_black_board_black 		"$\text{Black Appoint and Black Dir}_{t-1}$"
label variable dir_black_board_no_black		"$\text{Black Appoint and No Black Dir}_{t-1}$"



* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

estpost tabstat fd_bhar_m1p1 dir_black dir_hl dir_ai dir_w enlargement_board at_least_one_black_board_lag book_to_market_lag ln_mve_lag roa_lag														, statistics(count mean sd min p25 p50 p75 max) columns(statistics)


* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

eststo clear
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black book_to_market_lag ln_mve_lag roa_lag, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black book_to_market_lag ln_mve_lag roa_lag if no_other_mat_event==1, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd_3m##i.dir_black i.post_george_floyd_rest_2020##i.dir_black book_to_market_lag ln_mve_lag roa_lag if no_other_mat_event==1, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black i.post_george_floyd##i.dir_hl i.post_george_floyd##i.dir_ai book_to_market_lag ln_mve_lag roa_lag if no_other_mat_event==1, robust

	estout, 																																																					///
		cells(b(star fmt(3)) p(par fmt(3))) collabels(none) 																																																																								///
		stats(r2 N, fmt(%12.3fc %12.0fc) labels("R$^2$" "Observations")) 																																																				///
		indicate("Controls = book_to_market_lag ln_mve_lag roa_lag _cons", labels(Y N)) 																																														///
		mlabels(none) eqlabels(none) label nolegend nobaselevels varwidth(40)																																																																									///
		order(1.post_george_floyd#1.dir_black 1.post_george_floyd_3m#1.dir_black 1.post_george_floyd_rest_2020#1.dir_black 1.post_george_floyd#1.dir_hl 1.post_george_floyd#1.dir_ai 1.post_george_floyd 1.dir_black 1.post_george_floyd_3m 1.post_george_floyd_rest_2020 1.dir_hl 1.dir_ai)



* --------------------------------------------- *
*                 P A N E L   C            	    *
* --------------------------------------------- *

eststo clear
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black book_to_market_lag ln_mve_lag roa_lag if ${factiva_sample}, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black book_to_market_lag ln_mve_lag roa_lag if ${factiva_sample} & ${no_other_press_release}, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd_3m##i.dir_black i.post_george_floyd_rest_2020##i.dir_black book_to_market_lag ln_mve_lag roa_lag if ${factiva_sample} & ${no_other_press_release}, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black i.post_george_floyd##i.dir_hl i.post_george_floyd##i.dir_ai book_to_market_lag ln_mve_lag roa_lag if ${factiva_sample} & ${no_other_press_release}, robust

	estout, 																																																						///
		cells(b(star fmt(3)) p(par fmt(3))) collabels(none) 																																																																									///
		stats(r2 N, fmt(%12.3fc %12.0fc) labels("R$^2$" "Observations")) 																																																																///
		indicate("Controls = book_to_market_lag ln_mve_lag roa_lag _cons", labels(Y N)) 																																															///
		mlabels(none)	eqlabels(none) label nolegend nobaselevels varwidth(40)																																																																											///
		order(1.post_george_floyd#1.dir_black 1.post_george_floyd_3m#1.dir_black 1.post_george_floyd_rest_2020#1.dir_black 1.post_george_floyd#1.dir_hl 1.post_george_floyd#1.dir_ai 1.post_george_floyd 1.dir_black 1.post_george_floyd_3m 1.post_george_floyd_rest_2020 1.dir_hl 1.dir_ai)



* --------------------------------------------- *
*                 P A N E L   D            	    *
* --------------------------------------------- *
eststo clear
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black##i.enlargement_board book_to_market_lag ln_mve_lag roa_lag if no_other_mat_event==1, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black_board_black i.post_george_floyd##i.dir_black_board_no_black book_to_market_lag ln_mve_lag roa_lag if no_other_mat_event==1, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black##i.enlargement_board book_to_market_lag ln_mve_lag roa_lag if ${factiva_sample} & ${no_other_press_release}, robust
	eststo: quietly reg fd_bhar_m1p1 i.post_george_floyd##i.dir_black_board_black i.post_george_floyd##i.dir_black_board_no_black book_to_market_lag ln_mve_lag roa_lag if ${factiva_sample} & ${no_other_press_release}, robust

	estout , 																																																																									///
		cells(b(star fmt(3)) p(par fmt(3))) collabels(none) stats(r2 N, fmt(%12.3fc %12.0fc) labels("R$^2$" "Observations")) 																																																																		///
		indicate("Controls = book_to_market_lag ln_mve_lag roa_lag _cons", labels(Y N)) 																																																												///
		mlabels(none) eqlabels(none) label nolegend nobaselevels varwidth(40) 																																																																																							///
		order(1.post_george_floyd#1.dir_black#1.enlargement_board 1.post_george_floyd#1.dir_black_board_no_black 1.post_george_floyd#1.dir_black_board_black 1.post_george_floyd#1.dir_black 1.post_george_floyd#1.enlargement_board 1.dir_black#1.enlargement_board 1.post_george_floyd 1.dir_black 1.enlargement_board 1.dir_black_board_no_black 1.dir_black_board_black)

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"
  set seed 123

}



use "${data_dir}/interim/DB Announcements of Directors Joining or Leaving Audit Analytics.dta", clear
keep if action_short == "appointed"

gen ethnicity = ""
replace ethnicity = "White" if cond(person_ethnicity_code == "w", 1, 0, .)
replace ethnicity = "Black" if cond(person_ethnicity_code == "b", 1, 0, .)
replace ethnicity = "Hispanic" if cond(person_ethnicity_code == "hl", 1, 0, .)
replace ethnicity = "Asian" if cond(((person_ethnicity_code == "a") | (person_ethnicity_code == "i")), 1, 0, .)
replace ethnicity = "Other NW" if cond(inlist(person_ethnicity_code,"m","n","p","o"), 1, 0, .)

gen event_year = year(event_date_8k)
gen post_george_floyd = cond(event_date_8k > td(25may2020),1,0,.)

keep if inrange(event_year,2014,2020)

keep if filter_us==1
keep if filter_has_gvkey==1
keep if filter_has_cik==1
keep if filter_gics_non_financial==1
keep if filter_board_size==1
keep if filter_prop_dir_ident==1



* ----------------------------------------------------------------------------- *
*                								 T A B L E   11    			  			           	    *
* ----------------------------------------------------------------------------- *

label var nm_psm_leadership_yne "Leadership"
label var nm_psm_ceo_yne "CEO Experience"
label var nm_psm_cfo_yne "CFO Experience"
label var nm_psm_international_yne "International"
label var nm_psm_industry_yne "Industry"
label var nm_psm_financial_yne "Financial"
label var nm_psm_technology_yne "Technology"
label var nm_psm_risk_yne "Risk"
label var nm_psm_government_yne "Government"
label var nm_psm_audit_yne "Audit"
label var nm_psm_sales_yne "Sales"
label var nm_psm_academic_yne "Academic"
label var nm_psm_legal_yne "Legal"
label var nm_psm_human_resources_yne "Human Resources"
label var nm_psm_strategic_planning_yne "Strategic Planning"
label var nm_psm_operations_yne "Operations"
label var nm_psm_mergers_acquisitions_yne "M&As"
label var nm_psm_csr_sri_yne "CSR-SRI"
label var post_george_floyd "Post George Floyd"

* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

sum nm_psm_academic_yne nm_psm_audit_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_csr_sri_yne nm_psm_financial_yne nm_psm_government_yne ///
             nm_psm_human_resources_yne nm_psm_industry_yne nm_psm_international_yne nm_psm_leadership_yne nm_psm_legal_yne ///
             nm_psm_mergers_acquisitions_yne nm_psm_operations_yne nm_psm_risk_yne nm_psm_sales_yne nm_psm_strategic_planning_yne nm_psm_technology_yne ///
             if !mi(nm_psm_leadership_yne) & action_short == "appointed"


* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

global output_order nm_psm_academic_yne nm_psm_audit_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_csr_sri_yne nm_psm_financial_yne nm_psm_government_yne ///
             nm_psm_human_resources_yne nm_psm_industry_yne nm_psm_international_yne nm_psm_leadership_yne nm_psm_legal_yne ///
             nm_psm_mergers_acquisitions_yne nm_psm_operations_yne nm_psm_risk_yne nm_psm_sales_yne nm_psm_strategic_planning_yne nm_psm_technology_yne

* MultiLogit
gen ethnicity_e = .
replace ethnicity_e = 1 if ethnicity == "Black"
replace ethnicity_e = 2 if ethnicity == "Hispanic"
replace ethnicity_e = 3 if ethnicity == "Asian"
replace ethnicity_e = 4 if ethnicity == "Other NW"
replace ethnicity_e = 5 if ethnicity == "White"
label define labels_e ///
    1 "Black" ///
    2 "Hispanic" ///
    3 "Asian" ///
    4 "Other Non-White" ///
    5 "White"
    label values ethnicity_e labels_e

quietly {
    eststo clear
    eststo: mlogit ethnicity_e nm_psm* i.event_year,  baseoutcome(5) rrr vce(bootstrap, reps(200))
}

esttab  ,  ///
    cells( "b(fmt(%5.3fc) star)" "t(par fmt(%5.2fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2_p N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("Pseudo R$ ^2$" "Observations" ))  ///
    indicate("\addlinespace Year F.E.=*event_year*" , labels(Y N))  ///
    varwidth(30) ///
    label compress nogaps noconst eqlabels(none) collabels(none) unstack eform noomitted nobase order(nm_psm_academic_yne nm_psm_audit_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_csr_sri_yne nm_psm_financial_yne nm_psm_government_yne nm_psm_human_resources_yne nm_psm_industry_yne nm_psm_international_yne nm_psm_leadership_yne nm_psm_legal_yne nm_psm_mergers_acquisitions_yne nm_psm_operations_yne nm_psm_risk_yne nm_psm_sales_yne nm_psm_strategic_planning_yne nm_psm_technology_yne) nomtitles



* --------------------------------------------- *
*                 P A N E L   C            	    *
* --------------------------------------------- *

use "${data_dir}/interim/DB Announcements of Directors Joining or Leaving Audit Analytics.dta", clear
keep if action_short == "appointed"


gen ethnicity = ""
replace ethnicity = "White" if cond(person_ethnicity_code == "w", 1, 0, .)
replace ethnicity = "Black" if cond(person_ethnicity_code == "b", 1, 0, .)
replace ethnicity = "Hispanic" if cond(person_ethnicity_code == "hl", 1, 0, .)
replace ethnicity = "Asian" if cond(((person_ethnicity_code == "a") | (person_ethnicity_code == "i")), 1, 0, .)
replace ethnicity = "Other NW" if cond(inlist(person_ethnicity_code,"m","n","p","o"), 1, 0, .)

keep if inrange(event_year,2014,2020)


keep if filter_us==1
keep if filter_has_gvkey==1
keep if filter_has_cik==1
keep if filter_gics_non_financial==1
keep if filter_board_size==1
keep if filter_prop_dir_ident==1


global factor_skills nm_psm_academic_yne nm_psm_audit_yne nm_psm_ceo_yne nm_psm_cfo_yne nm_psm_csr_sri_yne nm_psm_financial_yne nm_psm_government_yne ///
             nm_psm_human_resources_yne nm_psm_industry_yne nm_psm_international_yne nm_psm_leadership_yne nm_psm_legal_yne ///
             nm_psm_mergers_acquisitions_yne nm_psm_operations_yne nm_psm_risk_yne nm_psm_sales_yne nm_psm_strategic_planning_yne nm_psm_technology_yne

capture drop nfactors

mean $factor_skills
matrix skillsmeans = e(b)
matrix list skillsmeans
tabstat $factor_skills, stat(sd) save
matrix skillssd=r(StatTotal)
matrix list skillssd

tetrachoric $factor_skills, posdef
display r(N)
global N = r(N)
matrix r = r(Rho)
factormat r, n($N) mineigen(1) names($factor_skills) sds(skillssd) means(skillsmeans)
rotate, varimax
gen nfactors = e(f)
display nfactors
predict factor1-factor5

rename factor1 f_fina_acct
rename factor2 f_stakeholder
rename factor3 f_business_acumen
rename factor4 f_leadership
rename factor5 f_tech_acad

label variable f_fina_acct "Financial/Accounting"
label variable f_business_acumen "Business Acumen"
label variable f_leadership "Leadership"
label variable f_stakeholder "Stakeholder"
label variable f_tech_acad "Technology/Academic"


* MultiLogit
gen ethnicity_e = .
replace ethnicity_e = 1 if ethnicity == "Black"
replace ethnicity_e = 2 if ethnicity == "Hispanic"
replace ethnicity_e = 3 if ethnicity == "Asian"
replace ethnicity_e = 4 if ethnicity == "Other NW"
replace ethnicity_e = 5 if ethnicity == "White"
label define labels_e ///
    1 "Black" ///
    2 "Hispanic" ///
    3 "Asian" ///
    4 "Other Non-White" ///
    5 "White"
    label values ethnicity_e labels_e
tab ethnicity_e

quietly {
  eststo clear
  eststo: mlogit ethnicity_e i.post_george_floyd##c.f_* i.event_year,  baseoutcome(5) rrr vce(bootstrap, reps(300))
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "t(par fmt(%5.2fc))" ) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(r2_p N , ///
            fmt(%5.3fc %10.0gc ) ///
            labels("Pseudo R$ ^2$" "Observations" )) ///
    indicate("\addlinespace Year F.E.=*event_year*" , labels(Y N)) ///
    varwidth(30) ///
    label compress nogaps noconst eqlabels(none) collabels(none) unstack eform noomitted nobase nomtitles

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}

* ----------------------------------------------------------------------------- *
*                								 T A B L E   12    			  			           	    *
* ----------------------------------------------------------------------------- *

use "${data_dir}/interim/Others/DB Director Busyness", clear

label var director_busy "Busy Director"
label var dir_black "Black Dir"
label var calendar_year_2015 "Year=2015"
label var calendar_year_2016 "Year=2016"
label var calendar_year_2017 "Year=2017"
label var calendar_year_2018 "Year=2018"
label var calendar_year_2019 "Year=2019"
label var calendar_year_end "Calendar Year"
label var previous_seat "Previous Seat"
label var post_george_floyd "Post George Floyd"


* --------------------------------------------- *
*                 P A N E L   A            	    *
* --------------------------------------------- *

table (calendar_year_end) (dir_black previous_seat), statistic(count num_seats) nformat(%9.0fc count) nototals


* --------------------------------------------- *
*                 P A N E L   B            	    *
* --------------------------------------------- *

quietly {
  eststo clear
  eststo: reg director_busy i.dir_black##i.post_george_floyd i.calendar_year_2015 i.calendar_year_2016 i.calendar_year_2017 i.calendar_year_2018 i.calendar_year_2019 if previous_seat==1, vce(cluster iss_person_id)
  eststo: reg num_seats i.dir_black##i.post_george_floyd i.calendar_year_2015 i.calendar_year_2016 i.calendar_year_2017 i.calendar_year_2018 i.calendar_year_2019 if previous_seat==1, vce(cluster iss_person_id)
}

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" ) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(r2_p N , ///
            fmt(%5.3fc %10.0gc ) ///
            labels("Pseudo R$ ^2$" "Observations" )) ///
    indicate("\addlinespace Year F.E.=*calendar_year_*" , labels(Y N)) ///
    varwidth(60) ///
    label compress nogaps noconst eqlabels(none) collabels(none) nobase order(1.dir_black#1.post_george_floyd 1.dir_black 1.post_george_floyd) mtitles("Busy Director" "# Seats") substitute("$ \_{t-1}$" "$ _{t-1}$" "%" "\%" "R2" "R$ ^2$" "=1&" "&" "=1 " " ")

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}


* ----------------------------------------------------------------------------- *
*                								 T A B L E   13    			  			           	    *
* ----------------------------------------------------------------------------- *

************************************************************
/*                      S&P 250                           */
************************************************************

**# Analyze the effect of action-oriented measures from As You Sow on diversity exposure from conference calls.
local period_ays = 1 // First period data were collected for S&P 250 firms, second for S&P 500 firms.

use "${data_dir}/interim/As You Sow/DB As You Sow - Import", clear
	gen first_day_year_quarter = dofq(year_quarter)
	gen last_day_year_quarter = dofq(year_quarter + 1) - 1 // Setting it as the last day of the quarter is safer to avoid possible reverse causality.
	format %td first_day_year_quarter last_day_year_quarter
	isid primary_symbol year_quarter
	rename primary_symbol ticker

	drop sector state region market_cap market_cap_min market_cap_max num_eplyd num_eplyd_min num_eplyd_max country symbol_values index_change_values name_change_values general_change_values

	gen raw_rji_score_no_envir = raw_rji_score - ( 	///
		rji_b_7_1_acknwdg_ej			* 5 + 		///
		rji_b_7_2_abides_ej_regs_sinc	* 5 + 		///
		rji_b_7_3_env_fines_penalties	* 5 + 		///
		rji_b_7_4_neg_effects_bipoc_c	* 5 )
	gen action_oriented_score = rji_b_4_1_dei_intrnl_dept 		+ ///
	 							rji_b_4_2_dei_ldr_ttle 			+ ///
	 							rji_b_5_6_explct_dvrsty_goal 	+ ///
	 							rji_b_5_8_supply_chain_divrse 	+ ///
	 							rji_b_6_1_cmty_eng_rj 			+ ///
	 							rji_b_6_2_rj_donations

	keep if period==`period_ays'

	sort year_quarter
	assert year_quarter[1]==year_quarter[_N] // Checks that all quarters contain the same value.
	local year_quarter_ays = year_quarter[1] // The value of the first observation is the same as any other observation.

	quietly sum action_oriented_score
	gen action_oriented_score_dm = action_oriented_score - r(mean)
	xtile action_oriented_score_terc = action_oriented_score, nquantiles(3)
	xtile action_oriented_score_quin = action_oriented_score, nquantiles(5)


	isid ticker last_day_year_quarter
	sort ticker last_day_year_quarter
	order company_id ticker standard_name year_quarter first_day_year_quarter last_day_year_quarter period quarters_per_company

	save "Analyze AYS Actions on Diversity Exposure - Temp 1", replace
	clear

import_delimited "${data_dir}/interim/conference_calls/diversity_exposure_over_time_all_CCs.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear // Includes data before George Floyd's death.

gen date_cc = date(date, "YMD")
format %td date_cc
assert !missing(date_cc)
drop date

assert date_year == year(date_cc)
assert date_month == month(date_cc)
assert year_month == year(date_cc) * 100 + month(date_cc)
drop date_year date_month year_month

gen year_date_cc = year(date_cc)

drop ticker1 // To be consistent with the director appointments database, I only match on "ticker_text".
rename ticker_text ticker // Renaming allows me to merge to the master database.

replace ticker = regexs(1) if regexm(ticker, "^(.*)[-']$")==1 // No ticker ends with "-" or "'"
replace ticker = regexs(1) if regexm(ticker, "^-(.*)$")==1 // No ticker begins with "-".

assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".
assert ticker==upper(ticker)
drop if missing(ticker)

duplicates tag ticker date_cc, gen(dup)
drop if regexm(cc, "quick-version") & dup>0 // Some of the conference calls transcripts are issued earlier than other versions with "Quick Version" in the title.
drop dup

rename period quarter_cc
format %-60s cc

isid cc_id
sort cc_id
order cc_id cc ticker date_cc year_date_cc fyear quarter_cc

merge m:1 ticker using "Analyze AYS Actions on Diversity Exposure - Temp 1", keep(match) nogenerate
erase "Analyze AYS Actions on Diversity Exposure - Temp 1.dta"

keep if qofd(date_cc) >= (`year_quarter_ays' + 1) // Only matches conference calls after the quarter of the AYS data.
keep if date_cc <= td(31, Dec, 2021)

gen cc_month_after_ays = mofd(date_cc) - mofd(last_day_year_quarter)
gen cc_days_after_ays = date_cc - last_day_year_quarter
gen dummy_disclosure = cond(diver_exposure_sent>0, 1, 0) if !missing(diver_exposure_sent)
gen diver_exposure_sent_perc = diver_exposure_sent * 100



	if `period_ays'==1 {
		display "Sample of S&P 250 firms"
	}
	else if `period_ays'==2 {
		display "Sample of S&P 500 firms"
	}
	else {
		display as error `""period_ays" should take the values of "1" or "2""'
		error 1 // Forces a break.
	}

	tab cc_month_after_ays, miss

	eststo clear
		* Dependent variable: "dummy_disclosure"
			eststo: quietly reg dummy_disclosure 			cc_month_after_ays if action_oriented_score_terc==1, robust
			eststo: quietly reg dummy_disclosure 			cc_month_after_ays if action_oriented_score_terc==2, robust
			eststo: quietly reg dummy_disclosure 			cc_month_after_ays if action_oriented_score_terc==3, robust
		* Dependent variable: "diver_exposure_sent_perc"
			eststo: quietly reg diver_exposure_sent_perc 	cc_month_after_ays if action_oriented_score_terc==1, robust
			eststo: quietly reg diver_exposure_sent_perc 	cc_month_after_ays if action_oriented_score_terc==2, robust
			eststo: quietly reg diver_exposure_sent_perc 	cc_month_after_ays if action_oriented_score_terc==3, robust


capture label variable cc_month_after_ays "Months After AYS Score"

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate( , labels(Y N))  ///
    varwidth(30) ///
    label compress nogaps noconst eqlabels(none) collabels(none) nobase nomtitles mlabels("Tercile 1" "Tercile 2" "Tercile 3" "Tercile 1" "Tercile 2" "Tercile 3")


************************************************************
/*                      S&P 500                           */
************************************************************

quietly {

	clear all
	set more off
	global data_dir "YOUR_DIRECTORY"
	noisily display "DATA_DIR: ${data_dir}"

}

**# Analyze the effect of action-oriented measures from As You Sow on diversity exposure from conference calls.
local period_ays = 2 // First period data were collected for S&P 250 firms, second for S&P 500 firms.

use "${data_dir}/interim/As You Sow/DB As You Sow - Import", clear
	gen first_day_year_quarter = dofq(year_quarter)
	gen last_day_year_quarter = dofq(year_quarter + 1) - 1 // Setting it as the last day of the quarter is safer to avoid possible reverse causality.
	format %td first_day_year_quarter last_day_year_quarter
	isid primary_symbol year_quarter
	rename primary_symbol ticker

	drop sector state region market_cap market_cap_min market_cap_max num_eplyd num_eplyd_min num_eplyd_max country symbol_values index_change_values name_change_values general_change_values

	gen raw_rji_score_no_envir = raw_rji_score - ( 	///
		rji_b_7_1_acknwdg_ej			* 5 + 		///
		rji_b_7_2_abides_ej_regs_sinc	* 5 + 		///
		rji_b_7_3_env_fines_penalties	* 5 + 		///
		rji_b_7_4_neg_effects_bipoc_c	* 5 )
	gen action_oriented_score = rji_b_4_1_dei_intrnl_dept 		+ ///
	 							rji_b_4_2_dei_ldr_ttle 			+ ///
	 							rji_b_5_6_explct_dvrsty_goal 	+ ///
	 							rji_b_5_8_supply_chain_divrse 	+ ///
	 							rji_b_6_1_cmty_eng_rj 			+ ///
	 							rji_b_6_2_rj_donations

	keep if period==`period_ays'

	sort year_quarter
	assert year_quarter[1]==year_quarter[_N] // Checks that all quarters contain the same value.
	local year_quarter_ays = year_quarter[1] // The value of the first observation is the same as any other observation.

	quietly sum action_oriented_score
	gen action_oriented_score_dm = action_oriented_score - r(mean)
	xtile action_oriented_score_terc = action_oriented_score, nquantiles(3)
	xtile action_oriented_score_quin = action_oriented_score, nquantiles(5)


	* Distribution of terciles.
		tab action_oriented_score action_oriented_score_terc, miss


	isid ticker last_day_year_quarter
	sort ticker last_day_year_quarter
	order company_id ticker standard_name year_quarter first_day_year_quarter last_day_year_quarter period quarters_per_company

	save "Analyze AYS Actions on Diversity Exposure - Temp 1", replace
	clear

import_delimited "${data_dir}/interim/conference_calls/diversity_exposure_over_time_all_CCs.csv", delimiter(",", asstring) asdouble bindquotes(loose) stripquotes(default) clear // Includes data before George Floyd's death.

gen date_cc = date(date, "YMD")
format %td date_cc
assert !missing(date_cc)
drop date

assert date_year == year(date_cc)
assert date_month == month(date_cc)
assert year_month == year(date_cc) * 100 + month(date_cc)
drop date_year date_month year_month

gen year_date_cc = year(date_cc)

drop ticker1 // To be consistent with the director appointments database, I only match on "ticker_text".
rename ticker_text ticker // Renaming allows me to merge to the master database.

replace ticker = regexs(1) if regexm(ticker, "^(.*)[-']$")==1 // No ticker ends with "-" or "'"
replace ticker = regexs(1) if regexm(ticker, "^-(.*)$")==1 // No ticker begins with "-".

assert regexm(ticker, "^(.*)[-']$")==0 // No ticker ends with "-" or "'"
assert regexm(ticker, "^-(.*)$")==0 // No ticker begins with "-".
assert ticker==upper(ticker)
drop if missing(ticker)

duplicates tag ticker date_cc, gen(dup)
drop if regexm(cc, "quick-version") & dup>0 // Some of the conference calls transcripts are issued earlier than other versions with "Quick Version" in the title.
drop dup

rename period quarter_cc
format %-60s cc

isid cc_id
sort cc_id
order cc_id cc ticker date_cc year_date_cc fyear quarter_cc

merge m:1 ticker using "Analyze AYS Actions on Diversity Exposure - Temp 1", keep(match) nogenerate
erase "Analyze AYS Actions on Diversity Exposure - Temp 1.dta"

keep if qofd(date_cc) >= (`year_quarter_ays' + 1) // Only matches conference calls after the quarter of the AYS data.
keep if date_cc <= td(31, Dec, 2021)

gen cc_month_after_ays = mofd(date_cc) - mofd(last_day_year_quarter)
gen cc_days_after_ays = date_cc - last_day_year_quarter
gen dummy_disclosure = cond(diver_exposure_sent>0, 1, 0) if !missing(diver_exposure_sent)
gen diver_exposure_sent_perc = diver_exposure_sent * 100


	if `period_ays'==1 {
		display "Sample of S&P 250 firms"
	}
	else if `period_ays'==2 {
		display "Sample of S&P 500 firms"
	}
	else {
		display as error `""period_ays" should take the values of "1" or "2""'
		error 1 // Forces a break.
	}

	tab cc_month_after_ays, miss

	eststo clear
		* Dependent variable: "dummy_disclosure"
			eststo: quietly reg dummy_disclosure 			cc_month_after_ays if action_oriented_score_terc==1, robust
			eststo: quietly reg dummy_disclosure 			cc_month_after_ays if action_oriented_score_terc==2, robust
			eststo: quietly reg dummy_disclosure 			cc_month_after_ays if action_oriented_score_terc==3, robust
		* Dependent variable: "diver_exposure_sent_perc"
			eststo: quietly reg diver_exposure_sent_perc 	cc_month_after_ays if action_oriented_score_terc==1, robust
			eststo: quietly reg diver_exposure_sent_perc 	cc_month_after_ays if action_oriented_score_terc==2, robust
			eststo: quietly reg diver_exposure_sent_perc 	cc_month_after_ays if action_oriented_score_terc==3, robust



capture label variable cc_month_after_ays "Months After AYS Score"

esttab  , ///
    cells( "b(fmt(%5.3fc) star)" "p(par fmt(%5.3fc))" )  ///
    star(* 0.10 ** 0.05 *** 0.01)  ///
    stats(r2 N , ///
            fmt(%5.3fc %10.0gc )  ///
            labels("R2" "Observations" ))  ///
    indicate( , labels(Y N))  ///
    varwidth(30) ///
    label compress nogaps noconst eqlabels(none) collabels(none) nobase nomtitles mlabels("Tercile 1" "Tercile 2" "Tercile 3" "Tercile 1" "Tercile 2" "Tercile 3")

