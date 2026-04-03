******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
***                                                                                                                                              						   ***
***                                                                                                                                              						   ***
***                                                                                                       																   ***
*** Article: 		The Effect of Firms’ Information Exposure on Safeguarding Employee Health: Evidence from COVID-19       											   ***
*** Authors: 		Lisa Yao Liu and Shirley Lu	                                                        																   ***
*** Journal:		Journal of Accounting Research                                                        																   ***
***                                                                                                    	  																   ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.          																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************

******************************************************************************************************************************************************************************
* 1. Import Data

do "./Dofiles/11_Import_Safegraph.do"
do "./Dofiles/12_Import_Information_Exposure.do"
do "./Dofiles/13_Import_Infogroup.do"
do "./Dofiles/14_Import_Other_Data.do"

******************************************************************************************************************************************************************************
* 2. Merge Data

do "./Dofiles/20_Merge_Datafiles.do" 

******************************************************************************************************************************************************************************
* 3. Validation of Information Exposure (Sample: SP500)

do "./Dofiles/31_Clean_SP500_Analysis.do"
do "./Dofiles/32_SP500_Analysis.do"

******************************************************************************************************************************************************************************
* 4. Main regressions (Including cross sectional and robustness)

do "./Dofiles/41_Clean_Main_Result.do"
do "./Dofiles/42_Main_Result.do"

******************************************************************************************************************************************************************************
* 5. COVID regressions

do "./Dofiles/51_Clean_COVID_Analysis.do"
do "./Dofiles/52_COVID_Analysis.do"

******************************************************************************************************************************************************************************
*===============================================================================
* Import Safegraph
*===============================================================================


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"


****** Unzip social distancing dataset
rsource, terminator(END_OF_R) rpath("..") roptions(`"--vanilla"')
library(readr)
library(haven)
library(data.table)
require(foreign)
setwd("...")

for (j in 1:6){
  for (i in 1:9) {
    infile <- paste("2020/0", j, "/0", i, "/2020-0", j, "-0", i, "-social-distancing.csv.gz", sep="")
    outfile <- paste("Summary/social_distancing_0", j, "0", i, ".dta", sep="")
    dt=read_csv(infile)
    dt$month=j
    dt$day=i
    dt$ori_date=substr(dt$date_range_start, 1, 10)
    dt2=dt[c("origin_census_block_group", "device_count",
             "distance_traveled_from_home",
             "completely_home_device_count",
             "part_time_work_behavior_devices",
             "full_time_work_behavior_devices",
             "median_non_home_dwell_time",
             "candidate_device_count",
             "median_percentage_time_home",
             "month", "day", "ori_date")]
    write_dta(dt2, outfile)
  }
}
for (j in 1:6){
  for (i in 10:28) {
    infile <- paste("2020/0", j, "/", i, "/2020-0", j, "-", i, "-social-distancing.csv.gz", sep="")
    outfile <- paste("Summary/social_distancing_0",j, i, ".dta", sep="")
    dt=read_csv(infile)
    dt$month=j
    dt$day=i
    dt$ori_date=substr(dt$date_range_start, 1, 10)
    dt2=dt[c("origin_census_block_group", "device_count",
             "distance_traveled_from_home",
             "completely_home_device_count",
             "part_time_work_behavior_devices",
             "full_time_work_behavior_devices",
             "median_non_home_dwell_time",
             "candidate_device_count",
             "median_percentage_time_home",
             "month", "day", "ori_date")]
    write_dta(dt2, outfile)
  }
}
vec <- c(1, 3, 5)
for (j in vec){
  for (i in 29:31) {
    infile <- paste("2020/0", j, "/", i, "/2020-0", j, "-", i, "-social-distancing.csv.gz", sep="")
    outfile <- paste("Summary/social_distancing_0",j, i, ".dta", sep="")
    dt=read_csv(infile)
    dt$month=j
    dt$day=i
    dt$ori_date=substr(dt$date_range_start, 1, 10)
    dt2=dt[c("origin_census_block_group", "device_count",
             "distance_traveled_from_home",
             "completely_home_device_count",
             "part_time_work_behavior_devices",
             "full_time_work_behavior_devices",
             "median_non_home_dwell_time",
             "candidate_device_count",
             "median_percentage_time_home",
             "month", "day", "ori_date")]
    write_dta(dt2, outfile)
  }
}
vec <- c(4, 6)
for (j in vec){
  for (i in 29:30) {
    infile <- paste("2020/0", j, "/", i, "/2020-0", j, "-", i, "-social-distancing.csv.gz", sep="")
    outfile <- paste("Summary/social_distancing_0",j, i, ".dta", sep="")
    dt=read_csv(infile)
    dt$month=j
    dt$day=i
    dt$ori_date=substr(dt$date_range_start, 1, 10)
    dt2=dt[c("origin_census_block_group", "device_count",
             "distance_traveled_from_home",
             "completely_home_device_count",
             "part_time_work_behavior_devices",
             "full_time_work_behavior_devices",
             "median_non_home_dwell_time",
             "candidate_device_count",
             "median_percentage_time_home",
             "month", "day", "ori_date")]
    write_dta(dt2, outfile)
  }
}
vec <- c(7)
for (j in vec){
  for (i in 1:4) {
    infile <- paste("2020/0", j, "/0", i, "/2020-0", j, "-0", i, "-social-distancing.csv.gz", sep="")
    outfile <- paste("Summary/social_distancing_0", j, "0", i, ".dta", sep="")
    dt=read_csv(infile)
    dt$month=j
    dt$day=i
    dt$ori_date=substr(dt$date_range_start, 1, 10)
    dt2=dt[c("origin_census_block_group", "device_count",
             "distance_traveled_from_home",
             "completely_home_device_count",
             "part_time_work_behavior_devices",
             "full_time_work_behavior_devices",
             "median_non_home_dwell_time",
             "candidate_device_count",
             "median_percentage_time_home",
             "month", "day", "ori_date")]
    write_dta(dt2, outfile)
  }
}

END_OF_R

***** Append and create datasets 
cd "$directory/..."

local dtafiles : dir . files "*.dta"
foreach file of local dtafiles {
        append using `file'
        erase `file'
}
gen tract_11=substr(origin_census_block_group, 1, 11)
gen tract_10=substr(origin_census_block_group, 1, 10)
destring origin_census_block_group, gen (tract)
destring tract_11 tract_10, replace 
save social_distancing_total.dta, replace


********* Bring in Location data
**** Bring in zipcode dataset 
import excel "TRACT_ZIP_032020.xlsx", sheet("TRACT_ZIP_032020") firstrow clear
destring TRACT, gen (tract)
gsort tract -TOT_RATIO
duplicates drop tract, force
destring ZIP, gen (zipcode)
keep ZIP zipcode tract TRACT
isid tract
rename tract tract_11
merge 1:m tract_11 using social_distancing_total.dta
save social_distancing_zip.dta, replace /* Social distancing data with zipcode*/ 




*===============================================================================
* Import Information Exposure
*===============================================================================
/*
Part 1: Factset Revere Trade Relations
Part 2: BoardEx
Part 3: Branches
*/


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"


/*
** three sets of outcome files
Factset:
exposure_factset

BoardEx:
exposure_boardex

Segment:
exposure_segment
*/

*===============================================================================
* Part 1: Factset Revere Trade Relations
/*
Data downloaded via Factset add-on in Excel, separately for public and private firms.
For both, "Factset_*_relation.xlsx" contains all firm's trade relation firms; '"Factset_*_country.xlsx" contains the HQ country of each trade relation firm 
*/

**************** Import Factset Public Firms
clear
import excel "Factset_public_country.xlsx", sheet("Sheet1") firstrow 
keep partnerid hqcountry
tempfile file1
save `file1', replace
import excel "Factset_public_relation.xlsx", sheet("Sheet1") firstrow clear
merge m:1 partnerid using `file1'
drop _merge
replace hqcountry = "UK" if hqcountry=="United Kingdom"
local country China Italy Canada Japan India UK Belgium Netherlands
foreach i of local country {
	gen factset_`i' = 1 if hqcountry == "`i'"
}
** convert to firm level
collapse (max) factset_* ,by(tic Name Postal)
save factset_public, replace


**************** Import Factset Private Firms ******************
clear
import excel "Factset_private_country.xlsx", sheet("Sheet1") firstrow 
keep partnerid hqcountry
tempfile file1
save `file1', replace
import excel "Factset_private_relation.xlsx", sheet("Sheet1") firstrow clear
merge m:1 partnerid using `file1'
drop _merge
replace hqcountry = "UK" if hqcountry=="United Kingdom"
local country China Italy Canada Japan India UK Belgium Netherlands
foreach i of local country {
	gen factset_`i' = 1 if hqcountry == "`i'"
}
** convert to firm level
collapse (max) factset_* ,by(Identifier Name Postal)
save factset_private, replace


**************** Combine private and public 
use factset_private, clear 
rename Identifier id_factset_private
rename Name conm
rename Postal addzip
keep id_factset_private conm addzip factset*
gen source="factset private"
append using factset_public
replace source="factset public" if missing(source)
gen id_factset_public=tic
keep source id_* tic conm addzip factset*
** clean addzip 
gen zipcode=substr(addzip,1,5)
drop addzip
** remove firms with no exposure at all
egen exposure = rowtotal(factset*)
drop if exposure==0
drop exposure
** aggregate EU and asia placebo countries
gen factset_asia = max(factset_Japan, factset_India)
gen factset_EU = max(factset_Belgium, factset_Netherlands)
drop factset_Japan  factset_India factset_Belgium factset_Netherlands
foreach k of varlist factset* {
	replace `k'=0 if `k'==.
}
save exposure_factset, replace



*===============================================================================
* Part 2: BoardEx Dataset 
*********** Construct China - Italy BoardEx Exposure Dataset

***** Clean Education data 
use Education_all_BoardEx_NA.dta, clear 
* BoardEx - Individual Profile Education (downloaded from BoardEx)
duplicates drop 
preserve
	use Company_EU.dta, clear 
	rename BoardID CompanyID
	duplicates drop 
	tempfile inst_EU 
	save `inst_EU'
restore 
merge m:1 CompanyID using `inst_EU' 
drop if _m==2
gen italy_edu_total=(_m==3 & HOCountryName=="Italy")
drop _m 
rename HOCountryName HOCountryName_EU 
preserve
	use Company_Rest.dta, clear 
	rename BoardID CompanyID
	duplicates drop 
	tempfile inst_Rest 
	save `inst_Rest'
restore 
merge m:1 CompanyID using `inst_Rest' 
drop if _m==2
gen china_edu_total=(_m==3 & HOCountryName=="China")
replace china_edu_total=1 if _m==3 & HOCountryName=="Hong Kong SAR"
drop _m 
rename HOCountryName HOCountryName_Rest 
keep if china_edu_total>0 | italy_edu_total>0 
drop if Qualification=="Studied"
drop if Qualification=="Attended" 
keep DirectorID italy_edu_total china_edu_total  
bys DirectorID: egen max_china=max(china_edu_total)
bys DirectorID: egen max_italy=max(italy_edu_total)
local var china italy
foreach k of local var{
	rename max_`k' `k'_edu
}
keep DirectorID italy_edu china_edu 
duplicates drop 
isid DirectorID
save china_italy_director.dta, replace


*** Bring in Company Officer Dataset
use Boardex_composition_officers_NA.dta, clear
* Downloaded dataset from BoardEx 
duplicates drop 
merge m:1 DirectorID using  china_italy_director.dta
drop if _m==2
local var china italy 
foreach k of local var{
	replace `k'_edu=0 if `k'_edu==.
}
local var china italy 
foreach k of local var{
	bys CompanyID: egen max_`k'=max(`k'_edu)
}
keep CompanyID max_china max_italy  
duplicates drop 
local var china italy
foreach k of local var{
	rename max_`k' `k'_edu
}
isid CompanyID
save china_italy_company.dta, replace


********** Find all company ticker or name identifier data 
use CompanyProfile_NA.dta, clear 
* BoardEx - Company Profile Details
duplicates drop 
tab HOCountryName
keep if HOCountryName=="United States"
keep if OrgType=="Quoted" | OrgType=="Private"
rename BoardID CompanyID
drop AdvisorName AdvTypeDesc
duplicates drop 
merge m:1 CompanyID using china_italy_company.dta
drop if _m==2
local var china italy 
foreach k of local var{
	replace `k'_edu=0 if `k'_edu==.
}
keep if china_edu==1 | italy_edu==1 
local var HOAddress5 CCAddress5
foreach k of local var{
	replace `k' = strtrim(`k')
}
gen zipcode=substr(HOAddress5, 1, 5) 
replace zipcode=CCAddress5 if HOAddress5=="" & CCAddress5!=""
replace zipcode=substr(HOAddress5, 4, 5) if missing(real(zipcode)) & zipcode!=""
keep BoardName CIKCode Ticker ISIN OrgType Index china_edu italy_edu CompanyID zipcode
duplicates drop 
rename BoardName firm_name 
save china_italy_boardex_identifier.dta, replace 



******************* We use the same code but changed the country identifiers for creating Pseudo Information Connection 
** Country: Canada, Japan, India, UK, Netherlands, Belgium
* EU:  Belgium, Netherlands
* Asia: Japan, India
****** Additionally downloaded datasets from BoardEx: "Company_UK.dta", "Company_NA.dta" 
****** Generated dataset: "pseudo_boardex_identifier.dta"



** combine to one boardex data
use china_italy_boardex_identifier, clear
merge 1:1 CompanyID using pseudo_boardex_identifier 
local var china_edu italy_edu UK_edu CA_edu EU_edu Asia_edu
foreach k of local var {
	replace `k'=0 if `k'==.
}
rename CompanyID id_boardex
tostring id_boardex, replace
rename firm_name conm
rename Ticker tic
keep id_boardex tic conm zipcode *edu
gen source="boardex"
save exposure_boardex.dta



*===============================================================================
* Part 3: Branch Dataset 
******************** Find US companies that have China branches  
use seg_ctry_data_clean_northamerica.dta, clear 
* Downloaded from the WorldScope  
tab firm_country 
keep if firm_country=="UNITED STATES"
gen China=strpos(lower(seg_ctry), "china")>0
keep if China==1
tab seg_ctry 
replace China=0 if strpos(lower(seg_ctry), "excluding china") | strpos(lower(seg_ctry), "ex. china") | strpos(lower(seg_ctry), "except china") | strpos(lower(seg_ctry), "other than china") | strpos(lower(seg_ctry), "exclding china") | strpos(lower(seg_ctry), "excluding greater china") | strpos(lower(seg_ctry), "exclding china")
drop if China==0
keep if year>=2016
* they have important physical presence / branches there for four to five years 
keep isin 
duplicates drop 
merge 1:m isin using CompanyID_isin.dta 
keep if _m==3
keep companyid
duplicates drop 
merge 1:m companyid using CompanyID_gvkey.dta
keep if _m==3
keep gvkey 
duplicates drop 
gen china_segment=1
save usfirm_china_branch_gvkey.dta, replace 


******************** Find US companies that have Italy branches  
use seg_ctry_data_clean_northamerica.dta, clear 
* Downloaded from the WorldScope 
tab firm_country 
keep if firm_country=="UNITED STATES"
gen Italy=strpos(lower(seg_ctry), "italy")>0
keep if Italy==1
tab seg_ctry 
replace Italy=0 if strpos(lower(seg_ctry), "excluding italy") | strpos(lower(seg_ctry), "ex. italy") | strpos(lower(seg_ctry), "except italy") | strpos(lower(seg_ctry), "other than italy") | strpos(lower(seg_ctry), "exclding italy") | strpos(lower(seg_ctry), "excluding greater italy") | strpos(lower(seg_ctry), "exclding italy") | strpos(lower(seg_ctry), "excl. italy") | strpos(lower(seg_ctry), "ex italy")
drop if Italy==0
keep if year>=2016
* they have important physical presence / branches there for four to five years 
keep isin 
duplicates drop 
merge 1:m isin using CompanyID_isin.dta 
* Identifier-link from Capital IQ 
keep if _m==3
keep companyid
duplicates drop 
merge 1:m companyid using CompanyID_gvkey.dta
* Identifier-link from Capital IQ 
keep if _m==3
keep gvkey 
duplicates drop 
gen Italy_segment=1
save usfirm_italy_branch_gvkey.dta, replace 


*********** We used the same code but changed country identifiers to Generate Pseudo Country Branch Data **********************
******* Canada, Japan, India, UK, Netherlands, Belgium
*** created dataset: "usfirm_EU_branch_gvkey.dta", "usfirm_UK_branch_gvkey.dta"
* "usfirm_CA_branch_gvkey.dta", "usfirm_Asia_branch_gvkey.dta"

************ combine all into one branch file, use compustat to get ticker 
use usfirm_china_branch_gvkey.dta, clear
merge 1:1 gvkey using usfirm_italy_branch_gvkey.dta
drop _merge
merge 1:1 gvkey using usfirm_EU_branch_gvkey.dta
drop _merge
merge 1:1 gvkey using usfirm_UK_branch_gvkey.dta
drop _merge
merge 1:1 gvkey using usfirm_CA_branch_gvkey.dta
drop _merge
merge 1:1 gvkey using usfirm_Asia_branch_gvkey.dta
drop _merge
rename gvkey gvkey_old
gen gvkey  = string(gvkey_old,"%06.0f")
drop gvkey_old
merge 1:1 gvkey using compustat_unique_gvkey
keep if _merge==3
drop _merge
** clean variable name
rename gvkey id_segment
gen zipcode=substr(addzip,1,5)
keep id_segment tic conm zipcode *segment
gen source="segment"
save exposure_segment.dta




*===============================================================================
* Import Infogroup
*===============================================================================
/*
Part 1: Clean Zipcode-level and Zip-industry-level variables
Part 2: Bring in info exposure 
Part 3: Bring in PRI/SRI
*/


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"


*===============================================================================
* Part 1: Clean Zipcode-level and Zip-industry-level variables

******** Find the number of companies in each zip code-industry
use infogroup2019.dta, clear 
* Downloaded from InfoGroup 
bys zipcode: egen zip_firm_count=nvals(abi)
bys zipcode: egen zip_employee_count=sum(employee_size_location)
bys zipcode: egen ind_firm=nvals(primary_naics_code) if primary_naics_code!=""
bys zipcode: egen ind_firm_max=max(ind_firm)
drop ind_firm 
rename ind_firm_max ind_firm 
bys zipcode primary_naics_code: egen zipind_firm_count=nvals(abi) if primary_naics_code!=""
bys zipcode primary_naics_code: egen zipind_employee_count=sum(employee_size_location) if primary_naics_code!=""
keep zipcode primary_naics_code zip_firm_count zip_employee_count ind_firm  zipind_firm_count
duplicates drop
bys zipcode: egen zip_ind_avg=mean(zipind_firm_count) if primary_naics_code!=""
bys zipcode: egen zip_ind_median=median(zipind_firm_count) if primary_naics_code!=""
bys zipcode: egen zip_ind_avg_max=max(zip_ind_avg) 
drop zip_ind_avg 
rename zip_ind_avg_max zip_ind_avg
bys zipcode: egen zip_ind_median_max=max(zip_ind_median) 
drop zip_ind_median
rename zip_ind_median_max zip_ind_median
gen zip_ind_ratio=zip_firm_count/ind_firm

keep zipcode primary_naics_code zip_firm_count ind_firm zip_ind_avg zip_ind_median zip_ind_ratio zipind_firm_count   zip_employee_count 
duplicates drop 
isid zipcode primary_naics_code, missok 
save info_zipcode_firm.dta, replace 

******** Create ZIP CODE-level employee numbers
use infogroup2019.dta, clear
replace employee_size_location=0 if employee_size_location==.
destring zipcode, gen (zipcode_numerical) 
bys zipcode_numerical: egen zipcode_employee=sum(employee_size_location)
gen count=1
bys zipcode_numerical: egen zip_firm_count=sum(count)
gen public=1 if !missing(ticker)
bys zipcode_numerical: egen public_firm=sum(public)
keep zipcode zipcode_numerical zipcode_employee zip_firm_count public_firm
duplicates drop 
rename zipcode ZIP
save infogroup2019_zipcode_agg.dta, replace

*===============================================================================
* Part 2: Bring in information exposure

/*
Goal: Find zips with information exposures
Step 1: Create unique firm data in infogroup
Step 2: Create firm-level data for all information exposure
Step 3: match info exp to infogroup using ticker 
Step 4: those not matched: map exposure data to infogroup firm for other firms using name match
Step 5: map infogroup firm to full data in order to aggregate to zipcode level

*/


********** Step 1
******** Get all the company name 
***** Clean the company name for name matching 
use infogroup2019.dta, clear
keep abi parent_number company ticker 
gen with_branch=(parent_number!="")
gen id=abi
replace id=parent_number if parent_number!=""
keep company id with_branch ticker 
duplicates drop 
destring id, gen (id_num)
gen id_numerical=_n 
keep if company!=""
save infogroup2019_name.dta, replace


********** Step 2
************** Create firm-level exposure information
** factset
use exposure_factset, clear

** bring in boardex 
append using exposure_boardex 

** bring in segment
append using exposure_segment 

order source id* tic conm zipcode
save exposure_all, replace

************ clean to make sure unique firms represented 
** manually clean some errors in tickers 
replace tic="VZ" if id_boardex=="32507"
replace tic="ALXN" if id_boardex=="1815"
replace tic="CL" if id_boardex=="7293"
replace tic="" if id_boardex=="2957858"
egen tic_id=group(tic)
xfill *segment *edu factset* id* if !missing(tic), i(tic_id)
gsort -source
duplicates drop tic if !missing(tic), force //checked no info lost, force because there are multiple missing ticker private firms
drop tic_id  
** create unique id now for each obs
gen id_firm = _n
save exposure_all_uniqueticker, replace


********** Step 3
** match firm to infogroup using ticker 
** create unique ticker from infogroup
use infogroup2019_name, clear
keep if !missing(ticker)
** noted one duplicated ticker, AZZ
drop if company=="AZARGA URANIUM CORP"
tempfile file1
save `file1', replace

use exposure_all_uniqueticker, clear
rename tic ticker
merge m:1 ticker using `file1', keepusing(with_branch id)
drop if _merge==2
drop _merge
save exposure_all_uniqueticker_matched, replace

********** Step 4
** match name
/* exported the rest to python for name matching with firm names in infogroup. Returned file is called infogroup_dataset_match.xlsx
See python code for the name matching at the end of this do file
*/
clear
import excel "infogroup_dataset_match.xlsx", sheet("Sheet1") firstrow
drop if match_id==0
tempfile file1
save `file1', replace

use exposure_all_uniqueticker_matched, clear
merge 1:1 id_firm using `file1', keepusing(match_id match_name id_numerical) 
gen match_source = "name" if _merge==3
replace match_source = "ticker" if !missing( id)
replace match_source = "name_old" if !missing( parent_number) 
drop _merge
* for matched id, bring in whether has parent_id or not
merge 1:1 id_numerical using infogroup2019_name, keepusing( with_branch id) 
drop if _merge==2
drop _merge

save exposure_all_uniqueticker_matched_final, replace


********** Step 5
******* to match back to all branches in infogroup, need both with_branch (1/0) and parent_id. Those without branch have no parent_id, so has unique id_numerical
************* keep id and branch (to find infogroup) *************
drop if missing(match_source)

** use unique with_branch and id_numerical to find infogroup branches + 
** add Business Status Code, zipcode, employees
keep with_branch id
duplicates drop 
save exposure_all_matched_id, replace

**** match to full infogroup data  
gen parent_number=id if with_branch==1
gen abi=id if with_branch==0 

******** Merge with Parent_number dataset 
preserve 
	keep if parent_number!=""
	keep parent_number with_branch 
	merge 1:m parent_number using "infogroup2019.dta"
	keep if _m==3 
	keep parent_number with_branch business_status_code zipcode employee_size_location company primary_sic_code sic_code sic_code_1 sic_code_2 sic_code_3 sic_code_4 primary_naics_code
	replace employee_size_location=0 if employee_size_location==.
	rename parent_number id 
	save "parent_number_exposure_merge.dta", replace 
restore 

******** Merge with abi dataset 
preserve 
	keep if abi!=""
	keep abi with_branch 
	merge 1:m abi using "infogroup2019.dta"
	keep if _m==3 
	keep abi with_branch business_status_code zipcode employee_size_location company primary_sic_code sic_code sic_code_1 sic_code_2 sic_code_3 sic_code_4 primary_naics_code
	replace employee_size_location=0 if employee_size_location==.
	rename abi id 
	save "abi_exposure_merge.dta", replace 
restore 

use "parent_number_exposure_merge.dta", clear 
append using "abi_exposure_merge.dta"
save "all_exposure_merge_infogroup.dta", replace 


**** combine exposure variables with infogroup data
use exposure_all_uniqueticker_matched_final, clear
drop if missing(match_source)
keep match_source with_branch id conm ticker factset_* *_edu *_segment 
order match_source with_branch id conm ticker factset_* *_edu *_segment 
duplicates tag with_branch id, gen(dup)
** some firms have branches with different names, hence can have duplicate exposure. Take the max at the parent-firm level.
collapse (max) factset_* *_edu *_segment ,by(with_branch id)

** save unique firm-level exposure 
save exposure_unique_firm, replace

**** merge in infogroup
merge 1:m with_branch id using all_exposure_merge_infogroup
* all merged
drop _merge
**** clean and create var 
egen exposure_firm_count = rowmax( factset_China factset_Italy china_edu italy_edu china_segment Italy_segment )
gen exposure_firm_employee = employee_size_location if exposure_firm_count==1
** gen the final measure infogroup_n100 for all headquarters and branch with over 100 employees
foreach k of varlist factset_* *_edu *_segment {
	gen `k'_infogroup_n100=`k' if employee_size_location>100 | business_status_code=="1"
	rename `k' `k'_infogroup 
}


*collapse to zip code level
rename zipcode ZIP
collapse (sum) exposure_firm_count exposure_firm_employee *_infogroup *_n100,by(ZIP)

save infogroup_exposure_zip_merged, replace



*************** create a residual firm data ******************************
use exposure_all_uniqueticker_matched_final, clear
drop if !missing(match_source)
drop if missing(zipcode)
keep zipcode factset_* *_edu *_segment 
drop id_segment
rename zipcode ZIP
collapse (sum) exposure_firm_count factset_* *_edu *_segment ,by(ZIP)
save infogroup_exposure_zip_residual, replace



*===============================================================================
* Part 3: Bring in PRI/SRI ******************************
** bring in PRI SRI
use sri_mf_gvkey, clear
rename gvkey gvkey_old
gen gvkey  = string(gvkey_old,"%06.0f")
drop gvkey_old
merge 1:1 gvkey using pri_ii_gvkey
drop _merge
** bring in compustat for ticker
merge 1:1 gvkey using compustat_unique_gvkey
keep if _merge==3
drop _merge
rename tic ticker
tempfile file1
save `file1', replace

** create unique ticker from infogroup
use infogroup2019_name, clear
keep if !missing(ticker)
** one duplicated ticker, AZZ
drop if company=="AZARGA URANIUM CORP"
keep ticker with_branch id
merge 1:1 ticker using `file1', keepusing(gvkey conm addzip SRI PRI)
drop if _merge==1
drop _merge

** bring in those name matched
preserve
	clear
	import excel "infogroup_prisri_match.xlsx", sheet("Sheet1") firstrow
	* The matched dataset is obtained through running the name matching Python code below 
	drop if match_id==0
	tempfile file1
	save `file1', replace
restore 
merge 1:1 gvkey using `file1', keepusing(match_id match_name id_numerical) 
gen match_source = "name" if _merge==3
replace match_source = "ticker" if !missing( id)
drop _merge
merge 1:1 id_numerical using infogroup2019_name, keepusing( with_branch id) update
drop if _merge==2
drop _merge

save prisri_ticker_matched_final, replace

************* keep id and branch (to find infogroup) *************
drop if missing(match_source)
** use unique with_branch and id  to find infogroup branches + 
** add Business Status Code, zipcode, employees
keep with_branch id
duplicates drop 
save prisri_ticker_matched_id, replace

** match to infogroup
gen parent_number=id if with_branch==1
gen abi=id if with_branch==0 

******** Merge with Parent_number dataset 
preserve 
	keep if parent_number!=""
	keep parent_number with_branch 
	merge 1:m parent_number using "infogroup2019.dta"
	keep if _m==3 
	keep parent_number with_branch business_status_code zipcode employee_size_location company 
	replace employee_size_location=0 if employee_size_location==.
	rename parent_number id 
	save "parent_number_prisri_merge.dta", replace 
restore 

******** Merge with abi dataset 
preserve 
	keep if abi!=""
	keep abi with_branch 
	merge 1:m abi using "infogroup2019.dta"
	keep if _m==3 
	keep abi with_branch business_status_code zipcode employee_size_location company 
	replace employee_size_location=0 if employee_size_location==.
	rename abi id 
	save "abi_prisri_merge.dta", replace 
restore 

use "parent_number_prisri_merge.dta", clear 
append using "abi_prisri_merge.dta"
save "all_prisri_merge_infogroup.dta", replace 


************* bring in matched by name *******************************
*** combine prisri with infogroup data
use prisri_ticker_matched_final, clear
drop if missing(match_source)

keep match_source with_branch id conm ticker SRI PRI
order match_source with_branch id conm ticker SRI PRI

duplicates tag with_branch id, gen(dup)
** 2315/2387 unique firms, for now collapse into firm-level, take the max exposure
collapse (max) SRI PRI,by(with_branch id)

** merge in infogroup
merge 1:m with_branch id using all_prisri_merge_infogroup
drop _merge

**************** by zipcode, aggreate
** create an firm-level any PRI or SRI
gen SRIPRI = PRI 
replace SRIPRI =1 if SRI==1
** gen the final measure infogroup_n100 for all headquarters and branch with over 100 employees
foreach k of varlist SRIPRI   {
	gen `k'_infogroup_n100=`k' if employee_size_location>100 | business_status_code=="1"
	rename `k' `k'_infogroup 
}

*collapse to zip code level
rename zipcode ZIP
collapse (sum)   *_infogroup *_n100 ,by(ZIP)

save infogroup_prisri_zip_merged, replace

*************** create a residual firm data ******************************
use prisri_ticker_matched_final, clear
drop if !missing(match_source)
gen SRIPRI = PRI 
replace SRIPRI =1 if SRI==1
keep zipcode SRIPRI 
rename zipcode ZIP
collapse (sum) SRIPRI  ,by(ZIP)
save infogroup_prisri_zip_residual, replace


*===============================================================================
************* Name Matching Code Between InfoGroup and Firm Datasets (can run on Python or invoke Python on STATA, we also randomly selected observations to make sure the accuracy rate is >= 85% ~ 90%)
python:
import pandas as pd
import numpy as np
from cleanco import cleanco

info=pd.read_stata('infogroup2019_name.dta')
info['com']=info['conm_1']
info.head()

all_name=pd.read_stata('dataset_tomatch.dta')
* # change the dta file for different name matching dataset (# is used for comment in Python)
all_name.head()
all_name['com']=all_name['company_name']
all_name.head()

for i in list(info.index):
    info['com'].loc[i]=cleanco(info['com'].loc[i]).clean_name()
for i in list(info.index):
    info['com'].loc[i]=cleanco(info['com'].loc[i]).clean_name()    
info.head()

for i in list(all_name.index):
    all_name['com'].loc[i]=cleanco(all_name['com'].loc[i]).clean_name()
for i in list(all_name.index):
    all_name['com'].loc[i]=cleanco(all_name['com'].loc[i]).clean_name()    
all_name.head()

all_name['possible_match']=0
all_name['match_flag']=np.nan
all_name['match_id']=-1
all_name['match_name']=np.nan
all_name['id_numerical']=np.nan
all_name.head()

pub=list(info['com'])
pub=[c.lower() for c in pub]
for i in range(len(pub)):
    for mark in ['.',',','&','(',')',' ']:
        pub[i]=pub[i].replace(mark,'')
all_pub=' '.join(pub)

for i in list(all_name.index):
    com=''.join(all_name['com'].loc[i].lower().split(' '))
    for mark in ['.',',','&','(',')']:
        com=com.replace(mark,'')
    all_name['com'].loc[i]=com
    
match=[]
for i in list(all_name.index):
    if all_name['com'].loc[i] in all_pub:
        all_name['match_flag'].loc[i]=1
        first_pos=all_pub.index(all_name['com'].loc[i])
        try:
            all_name['match_id'].loc[i]=all_pub.split(' ').index(all_pub[first_pos:first_pos+len(all_name['com'].loc[i])+30].split(' ')[0])
            all_name['match_name'].loc[i]=info['company'].iloc[all_name['match_id'].loc[i]]
            all_name['id_numerical'].loc[i]=info['id_numerical'].iloc[all_name['match_id'].loc[i]]
        except:
            continue
        match.append(i)
        
all_name[all_name['match_flag']==1]
a=all_name[all_name['match_flag']==1]
a=a[a['match_id']!=-1]
a
a.to_excel('infogroup_dataset_match.xlsx')
end 
* # save as different datasets based on the name matching dataset (# is used for comment in Python)

**********************************
* Import Other Data
**********************************
/*
Summary:
Data 1: Industry Teleworkability
Data 2: Covid Local Government Policy
Data 3: Political Affiliation 
Data 4: Covid
Data 5: Essential industry data
Data 6: Clean union data
Data 7: Zip mapping
Data 8: Social Capital data 
*/

set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"


************************Data 1: Teleworkability******************************
** industry teleworkability data based on paper Dingel et al
clear
import delimited "https://raw.githubusercontent.com/jdingel/DingelNeiman-workathome/master/national_measures/output/NAICS3_workfromhome.csv"
rename naics naics_3
save dingel_teleworkability, replace

** import establishments to link industry NAICS_3 to calculate teleworkability
clear
import delimited "zbp18detail.txt", varnames(1) encoding(Big5) stringcols(1 3) 
* create NAICS_3 level data
gen naics_3 = substr(naics,1,3) if substr(naics,-3,.)=="///"
keep if !missing(naics_3)
* clean 
rename est establishment
destring establishment, replace
rename zip ZIP
order ZIP naics_3 establishment
keep ZIP naics_3 establishment
** bring in teleworkability
merge m:1 naics_3 using dingel_teleworkability, keepusing(teleworkable_emp)
keep if _merge==3
drop _merge
** create weighted teleworkability by establishment
bys ZIP: egen establishment_total = sum(establishment)
gen establishment_weight = establishment/establishment_total
gen tele_w = teleworkable_emp*establishment_weight
bys ZIP: egen teleworkable_emp_establish = sum(tele_w)
drop  establishment_weight  tele_w
* some ZIPs only have industries with no teleworkable data, turn to missing (none)
replace teleworkable_emp_establish = . if establishment_total==0
* keep one
keep ZIP teleworkable_emp_establish 
duplicates drop 
save teleworkability_zip_clean, replace

** create county level teleworkability
** import establishments
clear
import delimited "zbp18detail.txt", varnames(1) encoding(Big5) stringcols(1 3) 
* create NAICS_3 level data
gen naics_3 = substr(naics,1,3) if substr(naics,-3,.)=="///"
keep if !missing(naics_3)
* clean 
rename est establishment
destring establishment, replace
rename zip ZIP
order ZIP naics_3 establishment
keep ZIP naics_3 establishment
** bring in teleworkability
merge m:1 naics_3 using dingel_teleworkability, keepusing(teleworkable_emp)
keep if _merge==3
drop _merge
** bring in county_fips
destring ZIP, gen(zipcode)
merge m:1 zipcode using countyzip
keep if _merge==3
drop _merge
** create weighted teleworkability by county instead of zip
bys county_fips: egen establishment_total = sum(establishment)
gen establishment_weight = establishment/establishment_total
gen tele_w = teleworkable_emp*establishment_weight
bys county_fips: egen teleworkable_emp_establish = sum(tele_w)
drop establishment_total establishment_weight  tele_w
* some ZIPs only have industries with no teleworkable data, turn to missing 
replace teleworkable_emp_establish = . if teleworkable_emp_establish==0
* keep one
keep county_fips teleworkable_emp_establish 
duplicates drop 
save establishment_tele_county_clean, replace


************************Data 2: Covid Local Government Policy******************************
** county level
clear
import delimited "https://raw.githubusercontent.com/Keystone-Strategy/covid19-intervention-data/master/complete_npis_inherited_policies.csv", stringcols(1) 
** clean location variables
statastates, name(state)
* missing GUAM and PUERTO RICO, drop them
keep if _merge==3
drop _merge
** turn into county level date start for each policy (policy start date is already first of county or state)
gen date_ = date(start_date, "MDY")
format date %td
sort date
duplicates drop fips npi, force
* clean DC and OH, treat them as states
replace county="" if county=="District of Columbia"
replace county="" if fips=="39"
* remove states to create county level outcome
preserve
	drop if missing(county)
	* checked that all county level data is same or earlier than state level
	keep fips npi date state*
	replace npi = "nonessential_closure" if npi == "non-essential_services_closure" 
	replace npi = "school_closure" if npi == "school closure" 
	reshape wide date, i( fips ) j(npi) string
	** keep 2 dates for each place: first stay at home order (only 31 counties), and first ANY order (all 620)
	egen date_policy = rowmin(date_*)
	rename fips county_fips
	destring county_fips, replace
	** lock down date also include shelter-in-place
	rename date_lockdown date_lockdown_old
	egen date_lockdown = rowmin(date_lockdown_old date_shelter_in_place)
	keep county_fips state*  date_policy date_lockdown
	order county_fips state*  date_policy date_lockdown
	format date_policy date_lockdown %td
	save county_policy, replace
restore

** state level
* continue data cleaning and now keep only states
keep if missing(county)
keep fips npi date state*
replace npi = "nonessential_closure" if npi == "non-essential_services_closure" 
replace npi = "school_closure" if npi == "school closure" 
reshape wide date, i( fips ) j(npi) string
** keep 2 dates for each place: first stay at home order (only 31 counties), and first ANY order (all 620)
egen date_policy = rowmin(date_*)
** lock down date also include shelter-in-place
rename date_lockdown date_lockdown_old
egen date_lockdown = rowmin(date_lockdown_old date_shelter_in_place)
format date_policy date_lockdown %td
keep state*  date_policy date_lockdown
order state*  date_policy date_lockdown
save state_policy, replace

** city level
clear
import excel "200821 city_government_response.xlsx", sheet("city_government_response") firstrow 
* one empty first line
drop if missing(city)
replace city=lower(city)
* note that NYC is sometimes new york sometimes new york city
replace city="new york" if city=="new york city"
* clean dates
replace dateOfAction = substr(dateOfAction,1,10)
gen date = date( dateOfAction, "YMD")
format date %td
** create date for: stay at home, emergency declaration, social distancing, gathering
* remove any recommendations only
drop if actionTypes=="Recommendation/Soft Power"
replace description=lower(description)
* stay at home orders
gen date_lockdown = date if strpos(description,"stay at home")>0
replace date_lockdown = date if strpos(description,"stay home")>0
replace date_lockdown = date if strpos(description,"shelter in place")>0
replace date_lockdown = date if strpos(description,"shelter-in-place")>0
** keep 2 dates for each place: first stay at home order (only 55 cities), and first ANY order (181 / 516)
egen date_policy = rowmin(date_*)
format date_* %td
** keep earliest dates
collapse (min) date_lockdown date_policy, by(city state population)
* clean city and state names
rename city city_name
* clean location name
statastates, name(state)
* all merged
drop _merge
save city_policy, replace
***** add place_fips
clear
import excel "all-geocodes-v2017.xlsx", sheet("stata") firstrow clear
keep if SummaryLevel=="162" 
keep StateCodeFIPS PlaceCodeFIPS AreaNameincludinglegalstati
rename StateCodeFIPS state_fips
destring state_fips, replace
rename AreaNameincludinglegalstati fullname
gen city_name = subinstr(fullname," city","",.) if substr(fullname,-5,.)==" city"
replace city_name = subinstr(fullname," town","",.) if substr(fullname,-5,.)==" town"
replace city_name = subinstr(fullname," village","",.) if substr(fullname,-8,.)==" village"
replace city_name = subinstr(fullname," borough","",.) if substr(fullname,-8,.)==" borough"
replace city_name = fullname if missing(city_name)
replace city_name = lower(city_name)
drop if missing(city_name)
save city_fips, replace
** bring in place_fips
use city_policy, clear
rename city_name city_name_original
gen city_name = lower(city_name_original)
* manually update those not matched
replace city_name = "anchorage municipality" if city_name_original == "anchorage" & state_fips==2
replace city_name = "athens-clarke county unified government (balance)" if city_name_original == "athens" & state_fips==13
replace city_name = "augusta-richmond county consolidated government (balance)" if city_name_original == "augusta" & state_fips==13
replace city_name = "boise city" if city_name_original == "boise" & state_fips==16
replace city_name = "delaware" if city_name_original == "delaware city" & state_fips==39
replace city_name = "urban honolulu cdp" if city_name_original == "honolulu" & state_fips==15
replace city_name = "indianapolis city (balance)" if city_name_original == "indianapolis" & state_fips==18
replace city_name = "lexington-fayette urban county" if city_name_original == "lexington" & state_fips==21
replace city_name = "louisville/jefferson county metro government (balance)" if city_name_original == "louisville" & state_fips==21
replace city_name = "mountain view" if city_name_original == "moutain view" & state_fips==6
replace city_name = "nashville-davidson metropolitan government (balance)" if city_name_original == "nashville" & state_fips==47
replace city_name = "river forest" if city_name_original == "river forest village" & state_fips==17
replace city_name = "st. paul" if city_name_original == "saint paul" & state_fips==27
replace city_name = "san marcos" if city_name_original == "san marco" & state_fips==6
replace city_name = "sandy" if city_name_original == "sandy city" & state_fips==49
replace city_name = "san buenaventura (ventura)" if city_name_original == "ventura" & state_fips==6
replace city_name = "weymouth town" if city_name_original == "weymouth" & state_fips==25

merge 1:m city_name state_fips using city_fips
keep if _merge==3
drop _merge
rename PlaceCodeFIPS place_fips
keep city_name place_fips state*  date_policy date_lockdown
order city_name place_fips state*  date_policy date_lockdown
save city_policy, replace




************************Data 3: Political Affiliation******************************
** county level: vote for Trump in 2020
**** Political affiliation (county level)
clear
import delimited "https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20/master/2020_US_County_Level_Presidential_Results.csv",stringcols(11) 
*create indicator for democratic or republican 
gen party_dem_2020 = votes_dem> votes_gop
gen party_rep_2020 = votes_dem< votes_gop
gen party_diff_2020 = (votes_gop - votes_dem) / total_votes
keep county_fips party*
save county_election_2020, replace

** OurCampaign data
clear
import excel "ourcampaign_mayoral_election_result_2000_2020.xlsx", sheet("ourcampaign_mayoral_election_re") firstrow
gen date_election = date
format date_election %td
** keep only those won, and mayor
keep if race_result=="Won"
keep if office == "Mayor"
keep if inlist(type, "General Election","Nonpartisan General Election")
** keep election between 2010-2019
drop if date>td(1jan2020) | date<td(1jan2010)
** clean city name to match to place_id
rename county_or_city city 
** error in NYC, Bill de Blasio is labelled Brooklyn
replace city= "New York" if city=="Brooklyn"
drop if missing(city)
gen city_name=lower(city)
rename candidate_state state
** keep latest win
gsort  city_name state -date_election
by city_name state: gen keep = 1 if _n==1
keep if keep==1
** bring into place_id
statastates, a(state)
drop if _merge==2
drop _merge
merge 1:m city_name state_fips using city_fips
keep if _merge==3
distinct city_name state_fips, joint
** one duplicated: St. Anthony city MINNESOTA, keep correct place_fips; now 1168 distinct
drop if state_fips==27 & PlaceCodeFIPS=="56698"
** create indicator for political affiliation
gen ourcamp_mayor_politics = "D" if strpos(party,"Democratic")>0
replace ourcamp_mayor_politics = "R" if strpos(party,"Republican")>0
replace ourcamp_mayor_politics = "O" if missing(ourcamp_mayor_politics) 

rename PlaceCodeFIPS place_fips
keep city_name place_fips state*  ourcamp_mayor_politics
order city_name place_fips state*  ourcamp_mayor_politics
save our_campaigns_mayors_2020_clean


************************Data 4: Covid******************************
** County lv from new york times 
clear
import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv", stringcols(4) 
* Convert string to date
ren date temp_date
g date = date(temp_date,"YMD")
format date %td
drop if missing(fips)
destring fips, gen(county_fips)
keep county_fips date cases deaths
save countyfips_covid, replace



************************Data 5: Essential Industry Data **************************
** to create ratio of essential industry at zipcode level

** bring in essential industries, NAICS 6 digit, from CDC 
import excel "Essential_Industries_CISAv4_1_24.xlsx", sheet("EID by 6-digit NAICS") firstrow clear
** use CISAv40NAICSEssentialIndust as the indicator for essential business or not
drop if missing(CISAv40NAICSEssentialIndust)
gen business_essential = CISAv40NAICSEssentialIndust==1
rename NAICSCode NAICS_6_i
keep NAICS_6_i business_essential
save cdc_essential_industry

* create aggregate industry counts
use info_zipcode_firm, clear
keep primary_naics_code zipind_firm_count  
collapse (sum) zipind_firm_count  , by(primary_naics_code)
rename zipind_firm_count ind_firm_count
tempfile file1
save `file1', replace

use info_zipcode_firm, clear
merge m:1 primary_naics_code using `file1' 
drop _merge

** bring in essential business
gen NAICS_6 = substr(primary_naics_code,1,6)
destring NAICS_6, gen(NAICS_6_i)
merge m:1 NAICS_6_i using cdc_essential_industry
drop if _merge==2
drop _merge 

** create measures for industry-level essential 
** measure : weighted industry essential
gen establishment_weight = zipind_firm_count/zip_firm_count
gen ind_essential_ratio_w = business_essential*establishment_weight
bys zipcode: egen zip_ind_essential_ratio = sum(ind_essential_ratio_w)


** keep unique ZIP level value
keep zipcode zip_ind_essential_ratio 
duplicates drop 
rename zipcode ZIP
save info_zipcode_firm_unique, replace



************************Data 6: Clean union data******************************
** union source: http://www.unionstats.com/ 
** file used = by metropolitan area, 2020 data
import excel "zip_fips_metropolitan_maxpopulation_weighted.xlsx", sheet("Sheet1") firstrow clear
distinct zipcode
keep if Sector=="Total"
distinct zipcode
** 374 duplicates 185 zipcodes where a msa cross multiple zipcodes, drop
duplicates tag zipcode, gen(dup)
keep if dup==0
** rename var
rename Mem union_mem_ratio
keep zipcode union_*
save zip_union, replace

************************Data 7: Zip mapping*************************************
** zip to place mapping
import excel "placezip.xlsx", sheet("placezip") firstrow clear
* note that a zip can be in multiple cities. For now, assign ZIP to the city with most population
gsort ZIP -Population
duplicates drop ZIP, force
rename Name city_name
rename State state_abr
gen place_fips  = string(Place,"%05.0f")
drop Place
rename ZIP zipcode
order zipcode state_abr place_fips city_name
save placezip, replace

** zip to county mapping
import excel "uszips.xlsx", sheet("Sheet1") firstrow clear
statastates, a(state_id)
* only Puerto Rico not matched, drop
keep if _merge==3
drop _merge
rename zip zipcode
keep zipcode state* county_fips
save countyzip, replace


************************Data 8: Social Capital data*****************************
* Step 1: Manually clean "social-capital-project-social-capital-index-data.xlsx" to "social_capital_county.xlsx" to keep the tap that has "CountyLevelIndex"
* Step 2: Cleaning the xlsx to get "Social_Capital/social_capital_county_clean.dta"

import excel social_capital_county.xlsx, sheet("County Index") firstrow clear
keep county_fips CountyLevelIndex
destring county_fips, replace
save social_capital_county_clean.dta, replace 


**********************************
* Merge all data files
**********************************

/*
Goal: Data cleaning to create zip-level tests
Step 1: Start with Safegraph zip level
Step 2: Bring in zip to city data including demographics 
Step 3: Bring in teleworkability data
Step 4: Bring in covid policy data
Step 5: Bring in political affiliation data
Step 6: Bring in Covid data
Step 7: Bring in Social Capital County Index
Step 8: Bring in Infogroup information exposure data 
Step 9: Bring in Infogroup other data (employee, firm, industry counts)
Step 10: Bring in Socially responsible investor data
Step 11: Bring in Union

Outcome: zip_analysis
*/


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"

************************Step 1: Create Safegraph Zip level******************************
** use Safegraph social distancing zip level data
use social_distancing_zip.dta, clear 
** clean: ZIP is string;  zipcode is number
drop if missing(origin_census_block_group)
gen date = date(ori_date,"YMD")
format date %td
rename full_time_work_behavior_devices full_time_work_devices
** clean into daily zip level data
local var device_count  completely_home_device_count  full_time_work_devices  candidate_device_count 
collapse (sum) `var' , by(ZIP zipcode date month day)
drop if missing(zipcode)
save zip_analysis, replace



************************Step 2: Bring in zip to city and county******************************
** bring in zip to city 
merge m:1 zipcode using placezip
drop if _merge==2
drop _merge

** bring in zip to county and state
merge m:1 zipcode using countyzip
drop if _merge==2
drop _merge


************************Step 3: Bring in teleworkability******************************
** bring in teleworkability 
merge m:1 ZIP using teleworkability_zip_clean
drop if _merge==2
drop _merge


************************Step 4: Bring in state/county/city Covid policy******************************
** start with state level policy
merge m:1 state_fips using state_policy
drop _merge
rename date_policy  date_policy_state
rename date_lockdown date_lockdown_state

** county level policy
merge m:1 county_fips state_fips using county_policy
drop _merge
rename date_policy  date_policy_county
rename date_lockdown date_lockdown_county

** city level policy
merge m:1 place_fips state_fips using city_policy
drop if _merge==2
drop _merge
rename date_policy  date_policy_city
rename date_lockdown date_lockdown_city

** create a date for earliest of all three
egen date_policy = rowmin(date_policy_state date_policy_county date_policy_city)
egen date_lockdown = rowmin(date_lockdown_state date_lockdown_county date_lockdown_city)
format date* %td

************************Step 5: Bring in party affiliation******************************
** bring in county level 2020 vote for trump
merge m:1 county_fips using county_election_2020
drop if _merge==2
drop _merge

** bring in mayor data from OurCampaign
merge m:1 place_fips state_fips using our_campaigns_mayors_2020_clean, keepusing(ourcamp_mayor_politics)
drop if _merge==2
drop _merge


************************Step 6: Bring in Covid data******************************
** NYT county level
merge m:1 county_fips date using countyfips_covid, gen (merge_covid)
drop if merge_covid==2

local var deaths cases
foreach k of local var {
	replace `k'=0 if `k'==.
}

************************Step 7: Bring in Social Capital Index ******************
merge m:1 county_fips using social_capital_county_clean, gen(merge_social_capital)
rename CountyLevelIndex social_capital_county 
drop if merge_social_capital==2


************************Step 8: Bring in Infogroup exposure ******************
merge m:1 ZIP using infogroup_exposure_zip_merged, gen(merge_infogroup)
drop if merge_infogroup==2

foreach k of varlist *_infogroup* exposure_firm_count exposure_firm_employee exposure_firm_count_n100 {
	replace `k'=0 if `k'==.
}


**************Bring in residual exposure info
merge m:1 ZIP using infogroup_exposure_zip_residual, gen (merge_infogroupresidual)
drop if merge_infogroupresidual==2

foreach k of varlist exposure_firm_count factset_* *_edu *_segment {
	replace `k'=0 if `k'==.
}

** clean all exposure variables = add together to create final
foreach k of varlist factset_China-Asia_segment {
	egen `k'_final=rowtotal(`k'  `k'_infogroup_n100)
}

************************Step 9: Bring in other Infogroup data******************************
***** bring in infogroup zipcode level emp
merge m:1 ZIP using infogroup2019_zipcode_agg, gen (merge_infogroupzip)
drop if merge_infogroupzip==2

** bring in firm count and industry info from infogroup
merge m:1 ZIP using info_zipcode_firm_unique, gen(merge_infogroupind3)
drop if merge_infogroupind3==2


************************Step 10: Bring in PRI/SRI ******************************
merge m:1 ZIP using infogroup_prisri_zip_merged, gen(merge_sripri)
* var: all exposure variables with _infogroup or _infogroup_n100
drop if merge_sripri==2

foreach k of varlist SRIPRI {
	replace `k'=0 if `k'==.
}

** bring in residual
merge m:1 ZIP using infogroup_prisri_zip_residual, gen (merge_sripriresidual)
drop if merge_sripriresidual==2

foreach k of varlist SRIPRI  {
	replace `k'=0 if `k'==.
}


** clean all exposure variables = add together to create final
foreach k of varlist SRIPRI  {
	egen `k'_final=rowtotal(`k'  `k'_infogroup_n100)
}


************************Step 11: Bring in union *******
merge m:1 zipcode using zip_union, gen(merge_union)
drop if merge_union==2

save zip_analysis, replace

**********************************
* SP500 Data Cleaning
**********************************

/*
Part 1: Import SP 500 from Compustat
Part 2: Add exposure (factset, boardex, segment)
Part 3: Add Ravenpack press release
Part 4: Add earnings call Covid
Part 5: Add compustat controls
Part 6: Clean for regression

*/


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"

***********************************Part 1: Import SP500***********************************
import excel SP500.xlsx, sheet("WRDS") firstrow clear
rename GlobalCompanyKeyIndexConst gvkey 
rename CompanyTicker ticker
rename CompanyCIK cik
rename CompanyCusip cusip
order gvkey cik cusip ticker CompanyName CompanySICCode CompanyNAICScode EffectiveFromDate EffectiveThruDate
keep gvkey cik cusip ticker CompanyName CompanySICCode CompanyNAICScode EffectiveFromDate EffectiveThruDate
*remove duplicated
duplicates drop cik, force
**keep the 500 on 1/1/2020
keep if EffectiveFromDate<20200101
save sp500_analysis, replace



***********************************Part 2: Add china/italy exposure***************************
** Factset
use sp500_analysis, clear
merge 1:m gvkey using factset_public, keepusing(factset_China factset_Italy)
drop if _merge==2
drop _merge
save sp500_analysis, replace

** boardex
use china_italy_boardex_identifier, clear
destring CIKCode, gen(cik)
tempfile file1
save `file1', replace
use sp500_analysis, clear
merge 1:m cik using `file1', keepusing(*_edu)
drop if _merge==2
drop _merge
replace china_edu=0 if missing(china_edu)
replace italy_edu=0 if missing(italy_edu)
save sp500_analysis, replace
 
** segment
merge 1:1 gvkey using usfirm_china_branch_gvkey.dta
drop if _merge==2
drop _merge
merge 1:1 gvkey using usfirm_italy_branch_gvkey.dta
drop if _merge==2
drop _merge

save sp500_analysis, replace


***********************************Part 3: Import Ravenpack***********************************
** need to map and bring ravenpack ID into sample first
*start with ravenpack ID
clear
import delimited "RP_company-mapping-4.0_2020-02-27.csv", varnames(1) 
*format dates
gen date_start=date(range_start,"YMD")
gen date_end=date(range_end,"YMD")
format date* %td
drop  range_start  range_end
*note data is long based on data_type, with multiple per id
gen country = data_value if data_type=="COUNTRY"
gen companyname = data_value if data_type=="ENTITY_NAME"
gen ticker = data_value if data_type=="TICKER"
*for each id, use latest company country and name
egen id=group(rp_entity_id)
foreach var of varlist country companyname{
	gen byte ismiss = missing(`var') 
	gsort id ismiss -date_end, mfirst
	by id ismiss: replace `var'=`var'[1] 
	xfill `var', i(id)
	drop ismiss
}
duplicates drop id ticker, force
save ravenpack_id, replace

use ravenpack_id, clear
** match to SP500 ticker
merge m:1 ticker using sp500_analysis
*manually checked all matches, 2 below not match due to recent firm changes
*RTX newly merged in april 2020, drop for now
drop if ticker=="RTX"
*truist financial corp newly merged Dec 2019, not in ravenpack, drop for now
drop if ticker=="TFC"
drop _merge
tempfile file1
save `file1'
** add the ravenpack ID to SP500 sample
use sp500_analysis, clear
merge 1:1 ticker using `file1', keepusing(rp_entity_id)
drop _merge
save sp500_analysis, replace

** bring in ravenpack
clear
import delimited "ravenpack_covid19.csv", varnames(1) 
**clean dates/time
split timestamp_utc, p(" ")
gen date=date(timestamp_utc1,"YMD")
rename timestamp_utc2 time
format date %td
drop timestamp_utc1
order date time
** import ravenpack first PR
keep if news_type=="PRESS-RELEASE"
** bring into sample (earliest date)
sort date
duplicates drop rp_entity_id, force
keep rp_entity_id date
rename date rp_pr_date_new
tempfile file1
save `file1', replace
use sp500_analysis, clear
merge m:1 rp_entity_id using `file1'
drop if _merge==2
drop _merge 
save sp500_analysis, replace


***********************************Part 4: Add earnings call Covid***************************
use firmquarter_2020q3aug, clear
** keep the latest earnings before Apr 1st 2020
gen date_quarterend = date( date_earningscall,"DMY")
drop if date_quarterend>=td(01apr2020)
gsort gvkey -date_quarterend
duplicates drop gvkey, force
** clean gvkey
destring gvkey, replace
** manually update one gvkey for correct matching
replace gvkey = 6268 if ticker=="JCI"
tempfile file1
save `file1', replace

use sp500_analysis, clear
merge 1:1 gvkey using `file1'
drop if _merge==2
drop _merge
save sp500_analysis, replace



***********************************Part 5: Add compustat control***************************
** clean compustat: keep only values for fiscal 2019
use compustatuniverse200919, clear
gsort gvkey - indfmt 
keep if fyear==2019
duplicates drop gvkey, force
destring gvkey cik, replace
tempfile file1
save `file1', replace

use sp500_analysis, clear
merge 1:1 gvkey using `file1'
** one missing: ticker WCG 	CompanyName 	WELLCARE HEALTH PLANS INC
* bought by another firm in jan 2020
drop if _merge==2
drop _merge
save sp500_analysis, replace



***********************************Part 6: Clean for regression***************************
use sp500_analysis, clear

** change all to 0 if missing
local var china_edu factset_China  china_segment italy_edu factset_Italy  Italy_segment
foreach k of local var {
	replace `k'=0 if `k'==.
}

** create main outcome variable
egen exposure_total = rowtotal(china_edu  factset_China  china_segment italy_edu  factset_Italy  Italy_segment)
label variable exposure_total "Information Exposure"

** create ravenpack binary
gen rp_pr_binary=!missing( rp_pr_date) 

label variable rp_pr_binary "PR"
label variable rp_pr_date "PR Date"

** clean earnings call variables 
local risks Risk PRiskT_trade PRiskT_health PRiskT_economic
foreach k of local risks {
	gen `k'_d1000=`k'/1000
}
label variable Risk_d1000 "Overall Risk"
label variable PRiskT_trade_d1000 "Trade Risk"
label variable PRiskT_health_d1000 "Health Risk"
label variable PRiskT_economic_d1000 "Economic Risk"
label variable Covid_Exposure "COVID Exposure"
 
** clean control
gen at_log = log(at)
gen leverage = lt/at
gen roa = ni/at
** create liquidity ratio
** final used cfo_to_current liability; if missing current liability use total liability (results hold if all use total liability). The final version is called cfo_ratio_mix
gen cfo_to_tl = oancf/lt
gen cfo_ratio_mix = oancf/lct
replace cfo_ratio_mix = cfo_to_tl if missing(lct)

label variable cfo_ratio_mix "Liquidity"
label variable at_log "Total Assets (log)"
label variable roa "Return on Asset"
label variable leverage "Leverage"


** any exposure
gen exposure_any = exposure_total>0
** robustness: if only keep exposure from boardex
egen exposure_edu = rowtotal(china_edu  italy_edu)
label variable exposure_edu "BoardEx Exposure"
** robustness: variable where most exposure comes from boardex
gen boardex_ratio = exposure_edu/exposure_total

** clean earnings call date for FE
gen date_earningscall_month = mofd(date_quarterend)

** clear if their earnings call is before jan 2020 (720)
replace Covid_Exposure= . if date_earningscall_month<720
local risks Risk_d1000 PRiskT_trade_d1000 PRiskT_health_d1000 PRiskT_economic_d1000
foreach k of local risks {
	replace `k' = . if date_earningscall_month<720
}

** keep sample with all obs
drop if missing(roa)

save sp500_analysis_clean, replace

**********************************
* SP500 Analysis
**********************************


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"


use sp500_analysis_clean
*===============================================================================
* 1. Tables
** Table 1 Descriptive Stats
local var rp_pr_binary  Covid_Exposure Risk_d1000 PRiskT_trade_d1000 PRiskT_health_d1000 PRiskT_economic_d1000
local exp exposure_total exposure_edu 
local control at_log roa leverage  cfo_ratio_mix 
eststo clear
eststo: quietly estpost sum `exp' `var' `control' , detail
esttab using 2_output/table_sp500_summarystats.tex, replace label noobs title(Descriptive statistics)   ///
cells("count(fmt(%9.0fc)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))")  varwidth(30)

** Table 2
local control  at_log roa leverage cfo_ratio_mix
eststo clear
eststo: quietly reg rp_pr_binary exposure_total `control'
eststo: quietly reghdfe Covid_Exposure  exposure_total  `control' *d1000, absorb(date_earningscall_month)
eststo: quietly reg rp_pr_binary exposure_edu `control'
eststo: quietly reghdfe Covid_Exposure  exposure_edu  `control' *d1000, absorb(date_earningscall_month)
eststo: quietly reg rp_pr_binary exposure_edu `control' if boardex_ratio>=0.33 | exposure_any==0
eststo: quietly reghdfe Covid_Exposure  exposure_edu  `control' *d1000 if boardex_ratio>=0.33 | exposure_any==0, absorb(date_earningscall_month)
esttab using 2_output/table_sp500.tex, replace label title(First Covid-19 Responses)  nocon star(* .10 ** .05 *** .01)  ///
 b(3) s(N r2_a, label("N" "Adj. R-squared") fmt(0 %9.3f)) order(exposure_total exposure_edu) 
 

**********************************
* Main Analysis Data Cleaning
**********************************



set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"

use zip_analysis, clear


************** Outcome variables 
gen device_home_ratio = completely_home_device_count/ device_count*100
gen device_ftwork_ratio = full_time_work_devices/ device_count*100

************** Treatment variables
** continuous
egen exposure_total = rowtotal(factset_China_final  china_edu_final  china_segment_final factset_Italy_final  italy_edu_final  Italy_segment_final)
** Scale by firm count in infogroup
gen exposure_total_scaled = exposure_total/zip_firm_count*100
** truncate 
winsor2 exposure_total_scaled, trim 

** factset 
gen factset_exposure = factset_China_final + factset_Italy_final
** boardex 
gen boardex_exposure = china_edu_final + italy_edu_final
** segment 
gen segment_exposure = china_segment_final + Italy_segment_final
** binary
gen china_exposure_binary = 1 if factset_China_final>0 | china_edu_final>0 | china_segment_final>0
replace china_exposure_binary=0 if missing(china_exposure_binary)
gen italy_exposure_binary = 1 if factset_Italy_final>0 | italy_edu_final>0 | Italy_segment_final>0
replace italy_exposure_binary=0 if missing(italy_exposure_binary)
gen info_exposure_binary = china_exposure_binary
replace info_exposure_binary=1 if italy_exposure_binary==1

** placebo
egen placebo_exposure_total = rowtotal(factset_Canada_final- factset_EU_final UK_edu_final- Asia_edu_final EU_segment_final- Asia_segment_final)
gen placebo_exposure_scaled = placebo_exposure_total/zip_firm_count*100
gen placebo_exposure_binary = placebo_exposure_total>0
winsor2 placebo_exposure_scaled, trim 
** create placebo ratio
egen total_exposure_total = rowtotal(placebo_exposure_total exposure_total)
gen placebo_ratio = placebo_exposure_total/total_exposure_total
gen no_any_exposure = placebo_exposure_binary==0 & info_exposure_binary==0

** Scale by other 
** employees
gen exposure_firm_employee_zipratio = exposure_firm_employee/zipcode_employee
** distinct firms
gen exposure_firm_count_scaled = exposure_firm_count_n100/zip_firm_count*100
winsor2 exposure_firm_count_scaled, trim 


************** Clean weekends out
gen dow=dow(date)
drop if inlist(dow,0,6)
* clean public holidays out: martin, presidents day
drop if inlist(date,td(1jan2020),td(20jan2020), td(17feb2020))

************** Create date relative to policy
gen date_lockdown_t = date - date_lockdown if !missing( date_lockdown)
gen prelockdown_20day = 1 if date_lockdown_t>=-20 & !missing( date_lockdown)
replace prelockdown_20day=0 if missing(prelockdown_20day)
drop if missing(date_lockdown)

************** Clean control variables
** population use log
gen population_log=log(Population)
gen zip_firm_count_log=log(zip_firm_count)
** clean covid 
rename cases cases_cumulative
rename deaths deaths_cumulative
xtset zipcode date
bys zipcode: gen cases = cases_cumulative - cases_cumulative[_n-1]
bys zipcode: gen deaths = deaths_cumulative - deaths_cumulative[_n-1]
** note covid data missing jan 2, set all as 0 cases
replace cases=0 if missing(cases)
replace deaths=0 if missing(deaths)


************** Clean for cross sectional
** PRISRI
gen SRIPRI_public_ratio = SRIPRI_final/public_firm*100

** mayors
gen mayor_demo = ourcamp_mayor_politics=="D" if !missing(ourcamp_mayor_politics)
gen mayor_rep = ourcamp_mayor_politics=="R" if !missing(ourcamp_mayor_politics)

** essential out of 100 to be consistent
replace zip_ind_essential_ratio=zip_ind_essential_ratio*100


*********************************** Label

label variable device_home_ratio "Stay-at-Home Ratio"
label variable device_ftwork_ratio "Full-Time-Work Ratio"

label define prelockdown_20day 0 "Control" 1 "Pre Lockdown 20 Days"
label values prelockdown_20day prelockdown_20day 

label variable exposure_total_scaled_tr "Information Exposure Scaled"
label variable exposure_firm_employee_zipratio "Information Exposure (Employee)"
label variable exposure_firm_count_scaled_tr "Information Exposure (Firm)"
label variable info_exposure_binary "Information Exposure Binary"
label variable placebo_exposure_scaled_tr "Placebo Information Exposure Scaled"
label define info_exposure_binary 0 "Control" 1 "Information Exposure Binary"
label values info_exposure_binary info_exposure_binary 
label variable placebo_ratio "Placebo Exposure Ratio"

label variable demo_asian "Asian Percentage"
label variable population_log "Population (log)"
label variable Population "Population"
label variable teleworkable_emp_establish "Industry Teleworkability"
label variable zip_firm_count_log "Firms (log)"
label variable deaths "COVID Deaths"
label variable cases "COVID Cases"
label variable social_capital_county "Social Capital"
label var zip_ind_essential_ratio "Essential Industry Ratio"
label variable party_dem_2020 "Democratic Counties"
label variable party_rep_2020 "Republican Counties"
label variable mayor_demo "Democratic Mayor"
label variable mayor_rep "Republican Mayor"
label variable union_mem_ratio "% Union member"
label variable SRIPRI_public_ratio "Socially Responsible Investors"


** city indicator since need to combine place fips and state fips 
egen city_i = group(state_fips place_fips)
** main sample: period before lockdown date 
keep if date_lockdown_t<0


save zip_analysis_clean, replace

**********************************
* Main Results
**********************************

set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"

use zip_analysis_clean.dta, clear

*===============================================================================
** Table 1 Descriptive Stats

preserve
gen sample=!missing(Population)
replace sample=0 if missing(zip_firm_count)
replace sample=0 if missing(demo_asian)
replace sample=0 if missing(teleworkable_emp_establish)

local var device_home_ratio device_ftwork_ratio exposure_total_scaled_tr exposure_firm_employee_zipratio   exposure_firm_count_scaled_tr info_exposure_binary    placebo_exposure_scaled_tr       
local control demo_asian Population zip_firm_count teleworkable_emp_establish  deaths cases  social_capital_county   placebo_ratio   party_dem_2020  party_rep_2020  mayor_dem mayor_rep zip_ind_essential_ratio SRIPRI_public_ratio union_mem_ratio
sum `var' `control'
eststo clear
eststo: quietly estpost sum `var' `control' if sample==1, detail
esttab using 2_output/table_safegraph_summarystats.tex, replace label noobs title(Descriptive statistics)   ///
cells("count(fmt(%9.0fc)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))")  varwidth(30)
restore

*===============================================================================
** Table 3 Panel A
local control demo_asian population_log  teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control' i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish , absorb(city_i#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "Yes"
estadd local countydayFE "No"
estadd local statedayFE "No"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "Yes"
estadd local statedayFE "No"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control' i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish, absorb( state_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "No"
estadd local statedayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr i.prelockdown_20day#c.social_capital_county i.prelockdown_20day#c.deaths  i.prelockdown_20day#c.cases `control' c.deaths c.cases c.social_capital_county i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish, absorb( state_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local citydayFE "No"
estadd local countydayFE "No"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 2_output/table_main.tex, replace label title(Change in Stay-at-Home Ratio 20 Days before Policy Intervention) noobs s(N r2_a zipFE citydayFE countydayFE statedayFE cluster, label("N" "Adj. R-squared" "Zip-code FE" "City-Day FE"  "County-Day FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prelockdown_20day* demo_asian population_log   teleworkable_emp_establish 1.prelockdown_20day social_capital_county exposure_total_scaled_tr) order(1.prelockdown_20day#c.exposure_total_scaled_tr )

** Table 3 Panel B
local control demo_asian population_log teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_ftwork_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_firm_employee_zipratio i.prelockdown_20day#c.exposure_firm_employee_zipratio  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_firm_count_n100_scaletr i.prelockdown_20day#c.exposure_firm_count_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
local control demo_asian population_log zip_firm_count_log  teleworkable_emp_establish
eststo: qui reghdfe device_home_ratio i.prelockdown_20day i.info_exposure_binary i.prelockdown_20day#i.info_exposure_binary  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.zip_firm_count_log i.prelockdown_20day#c.teleworkable_emp_establish, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
esttab using 2_output/table_main_panelB.tex, replace label title(Main Analysis Panel B) noobs s(N r2_a zipFE  countydayFE  cluster, label("N" "Adj. R-squared" "Zip-code FE"  "County-Day FE"   "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prelockdown_20day* demo_asian population_log   teleworkable_emp_establish  zip_firm_count_log 1.prelockdown_20day exposure_total_scaled_tr 1.info_exposure_binary *0.info_exposure_binary exposure_firm_count_scaled_tr exposure_firm_employee_zipratio) order(1.prelockdown_20day#c.exposure_total_scaled_tr  1.prelockdown_20day#c.exposure_firm_employee_zipratio 1.prelockdown_20day#c.exposure_firm_count_scaled_tr 1.prelockdown_20day#1.info_exposure_binary )


*===============================================================================
* 4. Cross Sectional

* 4A. Political affiliation
* above mean population = 12014
local control demo_asian population_log  teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio  i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control' i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish  if ourcamp_mayor_politics=="R" , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Republican Mayor high pop"
eststo: qui reghdfe device_home_ratio  i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control' i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish  if ourcamp_mayor_politics=="D" , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Democratic Mayor high pop"
eststo: qui reghdfe device_home_ratio  i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control' i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish  if party_rep_2020==1   & Population>12014, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Republican County high pop"
eststo: qui reghdfe device_home_ratio  i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control' i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log  i.prelockdown_20day#c.teleworkable_emp_establish  if party_dem_2020==1   & Population>12014, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Democratic County high pop"
esttab using 2_output/table_cross_party_highpop.tex, replace label title(Cross Sectional: Political Affiliation) noobs s(N r2_a sample zipFE countydayFE  cluster, label("N" "Adj. R-squared" "Sample" "Zip-code FE" "County-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prelockdown_* demo_asian population_log   teleworkable_emp_establish 1.prelockdown_20day exposure_total_scaled_tr)


* 4B. Teleworkability and essential work
local control demo_asian population_log   teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if teleworkable_emp_establish<0.33, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local sample "Low tele"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if teleworkable_emp_establish>=0.33, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local sample "High tele"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if zip_ind_essential_ratio<0.785, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local sample "Low ess"
estadd local cluster "State"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if zip_ind_essential_ratio>=0.785, absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local sample "High ess"
estadd local cluster "State"
esttab using 2_output/table_cross_capability.tex, replace label title(Cross Sectional: By Teleworkability and Essential Work) noobs s(N r2_a sample  zipFE  countydayFE  cluster, label("N" "Adj. R-squared"   "Essential Industry Ratio" "Zip-code FE"  "County-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prelockdown_20day* demo_asian population_log   teleworkable_emp_establish 1.prelockdown_20day exposure_total_scaled_tr) order(1.prelockdown_20day#c.exposure_total_scaled_tr)


* 4C. Firm means and incentives test
local control demo_asian population_log   teleworkable_emp_establish
eststo clear
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if SRIPRI_public_ratio<1.923 & !missing(SRIPRI_public_ratio) & zip_firm_count>=119 , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Low SRIPRI_public_ratio"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish  if   SRIPRI_public_ratio>=1.923 & !missing(SRIPRI_public_ratio) & zip_firm_count>=119 , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "High SRIPRI_public_ratio"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if union_mem_ratio<10 & !missing(union_mem_ratio) , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "Low union_mem_ratio"
eststo: qui reghdfe device_home_ratio i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr  `control'  i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish  if union_mem_ratio>=10 & !missing(union_mem_ratio) , absorb(county_fips#date zipcode) vce(cluster state_fips)
estadd local zipFE "Yes"
estadd local countydayFE "Yes"
estadd local cluster "State"
estadd local sample "High union_mem_ratio"
esttab using 2_output/table_incentives.tex, replace label title(Incentives) noobs s(N r2_a zipFE countydayFE sample cluster, label("N" "Adj. R-squared" "Zip-code FE" "County-Day FE" "Sample" "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3)  drop(_cons 0.prelockdown_20day* demo_asian population_log   teleworkable_emp_establish 1.prelockdown_20day  0.prelockdown_20day*  exposure_total_scaled_tr  )




**********************************
* COVID Analysis Data Cleaning
**********************************


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"


*===============================================================================
**** aggregate zip-level data to county level

use zip_analysis, clear

drop if missing(demo_asian) | missing(Population) | missing(zip_firm_count) 
** note some need to aggregate at county-level again: asian ratio and industry teleworkability (as this analysis is at the county level)
** create asian for county level
gen asian = demo_asian/100* Population

local control asian Population  zip_firm_count
collapse (sum)  `control'  (min) date_lockdown_county ,by(date month day county_fips state_fips  cases deaths social_capital_county)

** bring in county level teleworkability
merge m:1 county_fips using establishment_tele_county_clean
drop if _merge==2
drop _merge
** create asian pop ratio 
gen demo_asian=asian/Population*100

xtset county_fips date

***********************************Clean Var for Regression***********************************
************** Treatment variables
** info exposure
egen exposure_total = rowtotal(factset_China_final  china_edu_final  china_segment_final factset_Italy_final  italy_edu_final  Italy_segment_final)
** Scale by firm count in infogroup
gen exposure_total_scaled = exposure_total/zip_firm_count*100
** truncate 
winsor2 exposure_total_scaled, trim 

************** Clean weekends out
gen dow=dow(date)
drop if inlist(dow,0,6)
* clean public holidays out: martin, presidents day
drop if inlist(date,td(1jan2020),td(20jan2020), td(17feb2020))

************** Create date relative to policy
egen date_lockdown=rowmin(date_lockdown_county date_lockdown_state)
drop if missing(date_lockdown)

gen date_lockdown_t = date - date_lockdown if !missing( date_lockdown)
gen prelockdown_20day = 1 if date_lockdown_t>=-20 & !missing( date_lockdown)
replace prelockdown_20day=0 if missing(prelockdown_20day)

************** Clean control variables
** population use log
gen population_log=log(Population)

************** Clean COVID variables (outcome)
rename cases cases_cumulative
rename deaths deaths_cumulative
bys county_fips: gen cases = cases_cumulative - cases_cumulative[_n-1]
bys county_fips: gen deaths = deaths_cumulative - deaths_cumulative[_n-1]
** noted a few cases of error in cumulative covid cases such that the difference is negative, change to 0 
replace cases=0 if cases<0
replace deaths=0 if deaths<0
** Growth in daily cases
bys county_fips (date): gen cases_7day_growth = (ln(1+cases[_n+7]) - ln(1+cases[_n]))
bys county_fips (date): gen cases_14day_growth = (ln(1+cases[_n+14]) - ln(1+cases[_n]))
** add indicator for cumulative covid cases 7 and 14 days into the future
gen cases_cumulative_f7=f7.cases_cumulative
gen cases_cumulative_f14=f14.cases_cumulative


*********** Label
label variable exposure_total_scaled_tr "Information Exposure Scaled"
label variable cases_7day_growth "Growth in COVID-19 Cases t+7"
label variable cases_14day_growth "Growth in COVID-19 Cases t+14"
label variable demo_asian "Asian Percentage"
label variable Population "Population"
label variable population_log "Population (log)"
label variable teleworkable_emp_establish "Industry Teleworkability"
label variable social_capital_county "Social Capital"
label define prelockdown_20day 0 "Control" 1 "Pre Lockdown 20 Days"
label values prelockdown_20day prelockdown_20day 


save county_analysis_clean, replace

**********************************
* COVID Analysis 
**********************************


set more off, permanently
clear all
global directory ".../2 Data"
cd "$directory"

use county_analysis_clean, clear
*===============================================================================

** Table 1 
** COVID descriptive stats
** sum cases_log_change_f7 keeping cases_cumulative_f7!=0
eststo clear
eststo: quietly estpost sum cases_7day_growth if cases_cumulative_f7!=0  & date_lockdown_t<0, detail
esttab using 2_output/table_covid_summarystats_l7day.tex, replace label noobs title(Descriptive statistics)   ///
cells("count(fmt(%9.0fc)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))")  varwidth(30)

** sum cases_log_change_f14 keeping cases_cumulative_f14!=0
eststo clear
eststo: quietly estpost sum cases_14day_growth if cases_cumulative_f14!=0   & date_lockdown_t<0, detail
esttab using 2_output/table_covid_summarystats_l14day.tex, replace label noobs title(Descriptive statistics)   ///
cells("count(fmt(%9.0fc)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))")  varwidth(30)

** sum the rest 
local var exposure_total_scaled_tr Population demo_asian  teleworkable_emp_establish social_capital_county 
eststo clear
eststo: quietly estpost sum `var'   if date_lockdown_t<0, detail
esttab using 2_output/table_covid_summarystats.tex, replace label noobs title(Descriptive statistics)   ///
cells("count(fmt(%9.0fc)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))")  varwidth(30)



** Table 4
local control demo_asian population_log  teleworkable_emp_establish
eststo clear
eststo: qui reghdfe cases_7day_growth i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr i.prelockdown_20day#c.social_capital_county  `control'  c.social_capital_county i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if date_lockdown_t<0, absorb( state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
eststo: qui reghdfe cases_14day_growth i.prelockdown_20day c.exposure_total_scaled_tr i.prelockdown_20day#c.exposure_total_scaled_tr i.prelockdown_20day#c.social_capital_county  `control'  c.social_capital_county i.prelockdown_20day#c.demo_asian i.prelockdown_20day#c.population_log i.prelockdown_20day#c.teleworkable_emp_establish if date_lockdown_t<0, absorb( state_fips#date county_fips) vce(cluster state_fips)
estadd local countyFE "Yes"
estadd local statedayFE "Yes"
estadd local cluster "State"
esttab using 2_output/table_covid_mainregression.tex, replace label title(Change in COVID cases 20 Days before Lockdown Intervention) noobs s(N r2_a countyFE  statedayFE cluster, label("N" "Adj. R-squared" "County FE"  "State-Day FE"  "Clusters" ) fmt(0 %9.3f)) star(* .10 ** .05 *** .01) nocon b(3) drop(_cons 0.prelockdown_20day* demo_asian population_log   teleworkable_emp_establish 1.prelockdown_20day social_capital_county exposure_total_scaled_tr) order(1.prelockdown_20day#c.exposure_total_scaled_tr )

