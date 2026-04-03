**************************************************************
*Observing Enforcement: Evidence from Banking
*Authors: Anya Kleymenova and Rimmy E. Tomy
*Creating macro variables to be used in analyses
*Date created: 27 November 2019
*Date last modified: 18 December 2020
*
*Raw data is from the BEA
***************************************************************
preserve
clear
import delimited "Z:\00 Original data\HMDA\county macro\bea - county economic profile\county_econ.csv"


gen per_capita_personal_inc_num= real(per_capita_personal_inc)
gen personal_income_num= real(personal_income)
gen population_num= real(population)
gen emp_num= real(emp)

drop per_capita_personal_inc personal_income population emp

gen emp_rate = emp / population

sort geofips year
bysort geofips: gen emp_num_lag1 = emp_num[_n-1] if year==year[_n-1]+1
bysort geofips: gen emp_rate_lag1 = emp_rate[_n-1] if year==year[_n-1]+1
bysort geofips: gen per_capita_personal_inc_num_lag1 = per_capita_personal_inc_num[_n-1] if year==year[_n-1]+1

gen emp_growth = (emp_num - emp_num_lag1) / emp_num_lag1
gen emp_rate_growth = emp_rate - emp_rate_lag1
gen pc_income_growth = (per_capita_personal_inc_num - per_capita_personal_inc_num_lag1) / per_capita_personal_inc_num_lag1

rename geofips sc_fips
save county_econ, replace
restore

*merging with county-level macroeconomic data
merge m:1 sc_fips year using county_econ
drop if _merge==2

br if _merge == 1
drop _merge

*filling missing values with state-level data
preserve
clear
import delimited "Z:\00 Original data\HMDA\county macro\bea - county economic profile\state_econ.csv"

rename per_capita_personal_inc per_capita_inc_state
rename personal_income personal_income_state
rename population population_state
rename emp emp_state

gen emp_rate_state = emp / population
gen state_fips = floor(geofips/1000)

sort geofips year
bysort geofips: gen emp_state_lag1 = emp_state[_n-1] if year==year[_n-1]+1
bysort geofips: gen emp_rate_state_lag1 = emp_rate_state[_n-1] if year==year[_n-1]+1
bysort geofips: gen personal_income_state_lag1 = personal_income_state[_n-1] if year==year[_n-1]+1


gen emp_growth_state = (emp_state - emp_state_lag1) / emp_state_lag1
gen emp_rate_growth_state = emp_rate_state - emp_rate_state_lag1
gen pc_income_growth_state = (personal_income_state - personal_income_state_lag1) / personal_income_state_lag1

drop geofips geoname 

save state_econ, replace
restore

*merging with state-level macroeconomic data to fill in missing values
merge m:1 state_fips year using state_econ
br year state_fips *_state _merge if _merge == 2
tab year if _merge == 2
drop if _merge == 2
drop _merge

replace per_capita_personal_inc_num = per_capita_inc_state if per_capita_personal_inc_num == .
replace emp_rate = emp_rate_state if emp_rate == .
replace emp_growth = emp_growth_state if emp_growth ==.
replace emp_rate_growth = emp_rate_growth_state if emp_rate_growth ==.
replace pc_income_growth = pc_income_growth_state if pc_income_growth ==.


replace per_capita_personal_inc_num = per_capita_personal_inc_num/1000
gen log_per_capita_income = log(per_capita_personal_inc_num)

gen neg_emp_ind = 1 if emp_growth <0
replace neg_emp_ind = 0 if missing(neg_emp_ind)
tab neg_emp_ind

gen neg_pc_inc_ind = 1 if pc_income_growth <0
replace neg_pc_inc_ind = 0 if missing(neg_pc_inc_ind)
tab neg_pc_inc_ind

*End of DO file**************************************************************
*Observing Enforcement: Evidence from Banking
*Authors: Anya Kleymenova and Rimmy E. Tomy
*Creating data for textual analyses (raw data constructed in Python)
*	1) Read in raw data
*	2) Construct a completed sample (RSSDID and textual variables)
*	3) Merge observables from the quarter prior
*Date created: 2 December 2019
*Date last modified: 14 January 2021
*Steps:
*	1) Start from two raw files
*	2) Combine the files
*	3) Add observables
*	4) Prepare file for merging with the master dataset for regression analyses
***************************************************************
*Preliminaries

*Set global directory
clear
clear matrix
*Server (external)
global rootDir "Z:\EDO_KT"
global output "Z:\EDO_KT\04 Modified data\01_Output"

cd "$rootDir\04 Modified data"

*Set the library
*Modified data
cd "$rootDir\04 Modified data"

*Set the maximum number of variables for Stata
clear mata
set maxvar 32767

*Read in the raw files from textual analysis
use "$rootDir\00 Original data\SNL\old_results_modified", clear
br

*Retain the subset that will be used in the analyses
keep Regulatory_ID_ Event_Date File Docket words sents Gunning_FOG Automated_readability Coleman_Liau Flesch_Grade_Level_Readability Flesch_Reading_Ease_Readability smog SNL_Type Coded_Type SNL_InstnID Event_Date Company Regulatory_ID_ Parent_Name_ Parent_Regulatory_ID_ Cert_Number_ Regulatory_Action_Type_ numeric_percent numeric_characters alphabetical_characters boilerplate_ratio

rename Regulatory_ID_ RSSDID
rename Cert_Number_ CERT

*Check types
table SNL_Type
table Coded_Type

mdesc SNL_Type Coded_Type Regulatory_Action_Type_


table Regulatory_Action_Type_

// Keep only severe eforcement actions in EDO_modified
keep if Regulatory_Action_Type_ == "Cease and Desist" |  Regulatory_Action_Type_ == "CEASE AND DESIST" |  Regulatory_Action_Type_ == "Formal Agreement/Consent Order" | ///
Regulatory_Action_Type_ == "Formal Agreement/Consent Order" | Regulatory_Action_Type_ == "(Modified) CEASE AND DESIST" | Regulatory_Action_Type_ == "(Modified) CONSENT ORDER" | ///
Regulatory_Action_Type_ == "CONSENT ORDER" | Regulatory_Action_Type_ == "CORRECTIVE ACTION DIRECTIVE" | Regulatory_Action_Type_ == "Prompt Corrective Action"  | ///
Regulatory_Action_Type_ == "SUPERVISORY PROMPT CORRECTIVE ACTION DIRECTIVE"

table Regulatory_Action_Type_
table Coded_Type

drop if Coded_Type=="(Terminated) CEASE AND DESIST" | Coded_Type=="(Terminated) CONSENT ORDER" | Coded_Type=="(Terminated) CORRECTIVE ACTION DIRECTIVE"

table Regulatory_Action_Type_

*Generate a stata date

gen yq=qofd(Event_Date)

gen ISSUE_DATE=Event_Date

//New File (befor text_data)
save text_data_ck, replace

use "$rootDir\00 Original data\SNL\merged_modified", clear
br
rename DOCKET_DUMBER Docket
drop Docket_tika Docket_textract

keep rssdid characters_length_textract words_textract sents_textract Gunning_FOG_textract Automated_readability_textract Coleman_Liau_textract Flesch_Grade_Level_Readability_0 Flesch_Reading_Ease_Readability0 SMOG_textract top_words_textract digit_characters_textract numeric_percent_textract ISSUE_DATE rssdid boilerplate_ratio Docket

rename characters_length_textract character_length
rename words_textract words 
rename sents_textract sents 
rename Gunning_FOG_textract Gunning_FOG
rename Automated_readability_textract Automated_readability
rename Coleman_Liau_textract Coleman_Liau
rename Flesch_Grade_Level_Readability_0 Flesch_Grade_Level_Readability
rename Flesch_Reading_Ease_Readability0 Flesch_Reading_Ease_Readability
rename SMOG_textract smog
rename digit_characters_textract numeric_characters
rename numeric_percent_textract numeric_percent
rename rssdid RSSDID 
rename character_length alphabetical_characters

gen Regulatory_Action_Type_ = "Cease and Desist"
gen Event_Date=ISSUE_DATE

//Combine the two files
append using text_data_ck
replace yq=qofd(Event_Date) if yq==.

drop if RSSDID ==.
rename roa roa_text
rename CERT FDIC_CERT
save text_data_ck, replace

use bnk_vars, clear
*Generate a stata date
tostring date, gen(date_str)                                                                                                                      
gen date_stata=date(date_str, "YMD")
format date_stata %td

gen yq=qofd(date_stata)
gen RSSDID=rssdid
gen Parent_Regulatory_ID_=rssdid

save temp_text_ck, replace

*Combine the datasets
use text_data_ck, clear	
merge m:1 RSSDID yq using temp_text_ck
drop if _merge==2
drop _merge

merge m:1 Parent_Regulatory_ID_ yq using temp_text_ck, update
drop if _merge==2
drop _merge

merge m:m FDIC_CERT yq using temp_text_ck, update
drop if _merge==2
drop _merge

replace year=year(Event_Date) if year==.
generate quarter=quarter(Event_Date)

//Replace missing YEAR_QTR
egen YEAR_QTR_ck = concat(year quarter), punct(.) 

destring(YEAR_QTR_ck), generate(YEAR_QTR_ck3) force
drop if YEAR_QTR_ck3==.

replace YEAR_QTR=YEAR_QTR_ck3 if YEAR_QTR==.


drop YEAR_QTR_ck*


gen byte disclosure_regime=1 if YEAR_QTR>1989.3 &YEAR_QTR!=.
replace disclosure_regime=0 if disclosure_regime==. &YEAR_QTR<1989.3

table YEAR_QTR disclosure_regime

gen byte crisis=1 if YEAR_QTR>2007.3 & YEAR_QTR<=2009.2
replace crisis=0 if crisis==. & YEAR_QTR!=.

gen byte post_crisis=1 if YEAR_QTR>2009.2 
replace post_crisis=0 if post_crisis==. & YEAR_QTR!=.

table year disclosure_regime

//check for duplicates
duplicates report
duplicates drop
mdesc YEAR_QTR
mdesc yq
table year if missing(YEAR_QTR)

************************************************************************************************************
//Adding macro variables
************************************************************************************************************
*** Adding macroeconomic variables
gen sc_fips = STATE_FIPS*1000 + COUNTY_FIPS
rename STATE_FIPS state_fips

do "$rootDir\01 Analysis\adding_emp_growth.do"

*merging with state-level macroeconomic data to fill in missing values
merge m:1 state_fips year using state_econ
br year state_fips *_state _merge if _merge == 2
tab year if _merge == 2
drop if _merge == 2
drop _merge

replace per_capita_personal_inc_num = per_capita_inc_state if per_capita_personal_inc_num == .
replace emp_rate = emp_rate_state if emp_rate == .
replace emp_growth = emp_growth_state if emp_growth ==.
replace emp_rate_growth = emp_rate_growth_state if emp_rate_growth ==.
replace pc_income_growth = pc_income_growth_state if pc_income_growth ==.
replace per_capita_personal_inc_num = per_capita_personal_inc_num/1000

duplicates report
duplicates report rssdid ISSUE_DATE
duplicates list (rssdid ISSUE_DATE Reg*)
duplicates drop rssdid ISSUE_DATE Regu, force

//Drop observations with missing rssdid
drop if rssdid==.

//Add information on EDO termination from the master SNL file
merge m:1 rssdid ISSUE_DATE using "$rootDir\00 Original Data\SNL\edo_complete"
drop if _merge==2
drop _merge

*replace alphabetical_characters=character_length if alphabetical_characters==.
//Add logs of the number of words and sentences
gen ln_words=ln(1+words)
gen ln_sents=ln(1+sents)

gen ln_edo_length=ln(1+EDO_LENGTH)

//Note that 533 boilerplate observations are missing (non-C&D)
gen byte cd_sample=1 if boilerplate_ratio!=.
replace cd_sample=0 if cd_sample==.

*End of DO file