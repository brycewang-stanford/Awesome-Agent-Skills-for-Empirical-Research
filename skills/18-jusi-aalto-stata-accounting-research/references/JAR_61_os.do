*Directory macros 
/*to be set by user
glo dir = c(pwd)
glo buyouts = "..."
*/

*Defining macros
set more off

*Define other macros
glo countries1_iso = "AT BE BG HR CY CZ DK EE FI FR DE GR HU IS IE IT LI LV LT LU MT NL NO PL PT RO SK SI ES SE CH  GB" // TR






*** 1. Prepare Buyout Dataset ***
*** 1.1. Assemble the Dataset
// 1.1.1. Load and save chunks of dataset
forval i = 1/4 {
	import excel "$orig/Zephyr_Export_`i'penew", sheet("Results") firstrow clear
	qui destring A, ignore(".") replace
	qui save "$form/Zephyr_PE_new_`i'.dta", replace
}


// 1.1.2. Append all chunks to dataset
use "$form/Zephyr_PE_new_1.dta", clear

append using "$form/Zephyr_PE_new_2.dta", gen(append2)
replace A = A + 31000 if append2 == 1

append using "$form/Zephyr_PE_new_3.dta", gen(append3)
replace A = A + 62000 if append3 == 1

append using "$form/Zephyr_PE_new_4.dta", gen(append4)
replace A = A + 93000 if append4 == 1

drop append*
sum A // = number of downloaded deals 


// 1.1.3. Compress and save dataset
qui compress
save "$form/zephyr_privateequity_new.dta", replace  




*** 1.2. Clean Dataset
// 1.2.1. Generate ID Variables
use "$form/zephyr_privateequity_new.dta", clear

rename DealNumber deal_bvdid
rename A deal_id
destring deal_id deal_bvdid, replace ignore(".")
replace deal_id = deal_id[_n-1] if deal_id == .
label var deal_id "Artificial Deal Identifier"


// 1.2.2. Clean Variables
*Rename variables
rename TargetBvDIDnumber bvd_target
rename Targetcountrycode countryiso_target
rename Targetname name_target
rename AcquirorBvDIDnumber bvd_acquiror
rename Acquirorname name_acquiror
rename Acquirorcountrycode countryiso_acquiror
rename VendorBvDIDnumber bvd_vendor
rename Vendorname name_vendor
rename Vendorcountrycode countryiso_vendor
rename Dealtype deal_type
rename Dealsubtype deal_subtype
rename Dealfinancing deal_financing
rename Dealmethodofpayment deal_mop
rename Dealmethodofpaymentvalueth deal_mopvalue
rename Dealstatus deal_status
rename Rumourdate date_rumour
rename Announceddate date_announcement
rename Assumedcompletiondate date_assumedcompletion
rename Completeddate date_completion
rename DealvaluethEUR deal_value
rename DealequityvaluethEUR deal_valueequity
rename Initialstake stake_initial
rename Acquiredstake stake_acquired
rename Finalstake stake_final
rename Acquirorbusinessdescriptions acquiror_desr
rename DealenterprisevaluethEUR deal_valueenterprise
rename Dealmodelledenterprisevaluet deal_valueenterprise_mod
rename DealtotaltargetvaluethEUR deal_valuetotal

*Shorten names
foreach var of varlist name* acquiror_desr {
	replace `var' = substr(`var', 1, 25)
}
qui compress

*Clean numeric variables
foreach var of varlist deal_mopvalue deal_value* {
	qui replace `var' = "" if `var' == "n.a."
	qui destring `var', ignore("," "*") replace
	qui replace `var' = `var' * 1000
}

*Clean string variables
qui replace name_acquiror = subinstr(name_acquiror, " ", "", .)
foreach var of varlist name_* deal_type deal_subtype deal_financing deal_mop deal_status {
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = upper(`var')
}

*Clean deal type variable
replace deal_type = "ACQUISITION" if strpos(deal_type,"ACQUISITION")
replace deal_type = "MERGER" if strpos(deal_type,"MERGER")
replace deal_type = "IPO" if strpos(deal_type,"INITIAL PUBLIC OFFERING")
replace deal_type = "IPO" if strpos(deal_type,"IPO")
replace deal_type = "INSTITUTIONAL BUY-OUT" if strpos(deal_type,"INSTITUTIONAL BUY-OUT")
replace deal_type = "INSTITUTIONAL BUY-OUT" if strpos(deal_type,"IBO")
replace deal_type = "MANAGEMENT BUY-OUT" if strpos(deal_type,"MANAGEMENT BUY-OUT")
replace deal_type = "MANAGEMENT BUY-OUT" if strpos(deal_type,"MBO")
replace deal_type = "JOINT VENTURE" if strpos(deal_type,"JOINT VENTURE")
replace deal_type = "MANAGEMENT BUY-IN" if strpos(deal_type,"MANAGEMENT BUY-IN")
replace deal_type = "MANAGEMENT BUY-IN" if strpos(deal_type,"MBI")
replace deal_type = "CAPITAL INCREASE" if strpos(deal_type,"CAPITAL INCREASE")
replace deal_type = "IPO" if strpos(deal_type,"INITIAL PUBLIC")
replace deal_type = "IPO" if strpos(deal_type,"INTIAL PUBLIC OFFERING")
replace deal_type = "BID WITHDRAWN" if strpos(deal_type,"WITHDRAWN")
replace deal_type = "SHARE BUYBACK" if strpos(deal_type,"SHARE BUYBACK")
replace deal_type = "MINORITY STAKE" if strpos(deal_type,"MINORITY STAKE")
replace deal_type = "MINORITY STAKE" if strpos(deal_type,"MINORITY INCREASED")
tab deal_type

*Clean deal financing variable
replace deal_financing = "PRIVATE EQUITY/LBO" if strpos(deal_financing,"PRIVATE EQUITY")
replace deal_financing = "PRIVATE EQUITY/LBO" if strpos(deal_financing,"LEVERAGED BUY OUT")
replace deal_financing = "PRIVATE EQUITY/LBO" if strpos(deal_financing,"LEVERAGE")
replace deal_financing = "ANGEL" if strpos(deal_financing,"ANGEL")
replace deal_financing = "DEVELOPMENT" if strpos(deal_financing,"DEVELOPMENT")
replace deal_financing = "SEED" if strpos(deal_financing,"SEED")
replace deal_financing = "VC" if strpos(deal_financing,"VENTURE")
replace deal_financing = "REFINANCING" if inlist(deal_financing,"NEW BANK FACILITIES","RECAPITALISATION")
replace deal_financing = "CAPITAL INCREASE" if strpos(deal_financing,"CAPITAL INCREASE")
replace deal_financing = "CAPITAL INCREASE" if strpos(deal_financing,"CAPITAL INJ")
tab deal_financing




*** 1.3. Generate Variables
// 1.3.1. Generate year and month variables
replace date_completion = date_assumedcompletion if date_completion == .
drop date_assumedcompletion

g year = yofd(date_announcement)
label var year "Year of Announcement"
g year_completion = yofd(date_completion)
label var year_completion "Year of Completion"

g month = month(date_announcement)
label var month "Month of Announcement"
g month_completion = month(date_completion)
label var month_completion "Month of Completion"


// 1.3.2. Generate stake variables
g stake_finalclass = "minority" if stake_final == "Unknown minority"
replace stake_finalclass = "majority" if stake_final == "Unknown majority"
destring stake_final, replace ignore("Unknown %" "minority" "majority" "remaining")

qui g deal_majority = 1 if stake_final >= 50 | stake_finalclass == "majority"
qui replace deal_majority = 0 if stake_final < 50 | stake_finalclass == "minority"
label var deal_majority "Majority Transaction (>=50%)"

qui g deal_influence = 1 if stake_final >= 25
qui replace deal_influence = 0 if deal_majority == 1 
label var deal_influence "Influence Transaction (25-49.9%)"


// 1.3.3. Generate Deal Variables
*Private equity financing (PS: Only if mentioned first)
qui g deal_pe_first = (deal_financing == "PRIVATE EQUITY/LBO")
label var deal_pe_first "Private Equity (LBO) Deal Financing"
tab deal_pe_first

*PE-to-PE transaction
egen dup = group(bvd_target) if bvd_target != ""
egen year_min = min(year), by(dup)
g deal_pe2pe = (year > year_min & bvd_target != "")
label var deal_pe2pe "PE-to-PE Transaction"
tab deal_pe2pe if deal_bvdid != .

*Deal geographics (PS: Only first acquiror mentioned)
qui g deal_foreign = 1 if countryiso_acquiror != countryiso_target ///
	& countryiso_acquiror != "" & countryiso_target != ""
replace deal_foreign = 0 if countryiso_acquiror == countryiso_target ///
	& countryiso_acquiror != "" & countryiso_target != ""
label var deal_foreign "Foreign Acquiror"

qui gen deal_us = (countryiso_acquiror == "US")
label var deal_us "US Acquiror"

qui gen deal_eu = 0
foreach ctry in $countries1_iso {
	qui replace deal_eu = 1 if countryiso_acquiror == "`ctry'"
}
label var deal_eu "EU Acquiror"

tab deal_foreign if deal_bvdid != .
tab deal_us deal_eu if deal_bvdid != .

*Deal type
g deal_mbo_dup = (strpos(deal_type,"MANAGEMENT BUY-OUT"))
egen deal_mbo = max(deal_mbo_dup), by(deal_id)
label var deal_mbo "Management Buyout"

gen deal_buybuild_dup = (strpos(deal_subtype,"BUY & BUILD"))
egen deal_buybuild = max(deal_buybuild_dup), by(deal_id)
label var deal_buybuild "Buy and Build Buyout"

tab deal_mbo deal_buybuild if deal_bvdid != .


// 1.3.4. Generate Vendor Variables
*PE vendor
preserve 
keep bvd_acquiror
duplicates drop 
gen bvd_vendor = bvd_acquiror
drop if bvd_vendor == ""
save "$form/zephyr_privateequity_acquirorlist.dta", replace
restore

merge m:1 bvd_vendor using "$form/zephyr_privateequity_acquirorlist.dta", gen(pe_acquiror_vendor) keep(match master)

g deal_pevendor_dup = (pe_acquiror_vendor == 3)
egen deal_pevendor = max(deal_pevendor_dup), by(deal_id)
label var deal_pevendor "Deal with Private Equity Vendor"

tab deal_pevendor if deal_bvdid != .

*Private vendor
gen deal_pvendor_dup = (name_vendor == "" | strpos(name_vendor, "SHAREHOLDERS") & bvd_vendor == "")
egen deal_pvendor = min(deal_pvendor_dup), by(deal_id)
label var deal_pvendor "Private Vendor"

gen deal_pvendor2_dup = (missing(bvd_vendor))
egen deal_pvendor2 = min(deal_pvendor2_dup), by(deal_id)
label var deal_pvendor2 "Private Vendor"

tab deal_pvendor deal_pvendor2 if deal_bvdid != .


// 1.3.5. Generate Buyout Firm Variables
*Big PE houses 
// https://docs.preqin.com/reports/Preqin-Special-Report-The-Private-Equity-Top-100-February-2017.pdf
qui g deal_big10_dup = 0
foreach stub in CARLYLE BLACKST KKR KRAVIS GOLDMAN ARDIAN TPG CVC WARBURG ADVENT BAIN {

	di "`stub'"
	qui replace deal_big10_dup = 1 if strpos(name_acquiror, "`stub'")
}
egen deal_big10 = max(deal_big10_dup), by(deal_id)
label var deal_big10 "Largest 10 PE Investor"

qui g deal_big30_dup = 0
foreach stub in CARLYLE BLACKST KKR KRAVIS GOLDMAN ARDIAN TPG CVC WARBURG ADVENT BAIN ///
	APAX APOLLO HELLMANN HARBOURVEST SILVERLAKE LEONARDGR LEXINGTON VISTAEQU CHINAREFORM ///
	ADAMSS PARTNERSGROUP PROVIDENCE COLLER NEUBERGER ARES EQT THOMABRAVO PERMIRA CINVEN PANTHEON {
	
	di "`stub'"
	qui replace deal_big30_dup = 1 if strpos(name_acquiror,"`stub'")
}
egen deal_big30 = max(deal_big30_dup), by(deal_id)
label var deal_big30 "Largest 30 PE Investor"

qui g deal_big50_dup = 0
foreach stub in CARLYLE BLACKST KKR KRAVIS GOLDMAN ARDIAN TPG CVC WARBURG ADVENT BAIN ///
	APAX APOLLO HELLMANN HARBOURVEST SILVERLAKE LEONARDGR LEXINGTON VISTAEQU CHINAREFORM ///
	ADAMSS PARTNERSGROUP PROVIDENCE COLLER NEUBERGER ARES EQT THOMABRAVO PERMIRA CINVEN PANTHEON ///
	BARING BRIDGEP JCFLOWER BCPART LGT TAASS ONEX CLAYTON INSIGHTVENTURE TIGER ACCEL STONEPOINT ///
	AMERICANSEC MORGANSTAN THOMASH NORDICC HONYC BERKSHIRE SEQUOIA RRJ {
	
	di "`stub'"
	qui replace deal_big50_dup = 1 if strpos(name_acquiror,"`stub'")
}
egen deal_big50 = max(deal_big50_dup), by(deal_id)
label var deal_big50 "Largest 50 PE Investor"

tab deal_big10 if deal_bvdid != .
tab deal_big30 if deal_bvdid != .
tab deal_big50 if deal_bvdid != .

*Acquiror frequency
egen deal_acquiror_count_dup = count(bvd_acquiror), by(bvd_acquiror)
egen deal_acquiror_count = max(deal_acquiror_count_dup), by(deal_id) // Most active acquiror chosen
label var deal_acquiror_count "Acquiror Number of Buyouts (bvd)"

egen deal_acquiror_count2_dup = count(name_acquiror), by(name_acquiror)
egen deal_acquiror_count2 = max(deal_acquiror_count2_dup), by(deal_id) // Most active acquiror chosen
replace deal_acquiror_count2 = 1 if deal_acquiror_count2 > 580 	// Synonyms as names like "INVESTORS"
label var deal_acquiror_count2 "Acquiror Number of Buyouts (name)"

qui g name_acquiror_short = substr(name_acquiror, 1, 10)
egen deal_acquiror_count3_dup = count(name_acquiror_short), by(name_acquiror_short) // Most active acquiror chosen
replace deal_acquiror_count2 = 1 if deal_acquiror_count3 > 650 	// Synonyms as names like "INVESTORS"
egen deal_acquiror_count3 = max(deal_acquiror_count3_dup), by(deal_id)
label var deal_acquiror_count3 "Acquiror Number of Buyouts (short name)"

tab deal_acquiror_count if deal_id != .
tab deal_acquiror_count2 if deal_id != .
tab deal_acquiror_count3 if deal_id != .

drop year_min *dup pe_acquiror_vendor name_acquiror_short




*** 1.4. Generate Deal Level Variables and Dataset
*Count targets, acquirors, and vendors
egen deal_targets = count(name_target), by(deal_id)
label var deal_targets "Number of Targets in Deal"

egen deal_acquirors = count(name_acquiror), by(deal_id)
label var deal_acquirors "Number of Acquirors in Deal"

egen deal_vendors = count(name_vendor), by(deal_id)
label var deal_vendors "Number of Vendors in Deal"

*Generate deal level targets and acquirors
sort deal_id deal_bvdid
egen max_obs = count(deal_id), by(deal_id)
qui sum max_obs
foreach party in "target" "acquiror" "vendor" {
	rename bvd_`party' bvd_`party'1
	forvalue val = 2 (1) `r(max)' {
		qui g bvd_`party'`val' = ""
		loc ind = `val' - 1
		replace bvd_`party'`val' = bvd_`party'1[_n+`ind'] ///
			if deal_bvdid != . & deal_id == deal_id[_n+`ind']
	}
}
drop max_obs

*Generate and finalize deal level dataset
drop if deal_bvdid == .
rename bvd_target1 bvd
gsort bvd year -date_announcement
compress
save "$final/zephyr_privateequity_sampletable.dta", replace




*** 1.5. Finalize Buyout Dataset
// 1.5.1. Sample Selection
use "$final/zephyr_privateequity_sampletable.dta", clear

*1. Step: Deals from 32 EEA countries in period 2000 to 2018 with bvdid
qui g byte target_europe = 0
foreach ctry in $countries1_iso {
	qui replace target_europe=1 if countryiso_target=="`ctry'"
}
keep if target_europe == 1 //drops 70,081
drop if year < 2000 | year > 2018
drop if bvd == ""
drop target_europe

*2. Step: Only completed deals
drop if deal_status != "COMPLETED" & deal_status != "COMPLETED ASSUMED"

*3. Step: Only deals which involve one target
drop if deal_targets > 1
*drop if deal_majority == 0		// Dropping non-majority deals is possible, problem of falling below N = 10k

*4. Step: Drop duplicates
gsort bvd year -date_announcement deal_bvdid
duplicates drop bvd year, force


// 1.5.2. Generate In-Sample Country Weights
*Count observations in groups
egen obs_total = count(countryiso_target)
egen obs_country = count(countryiso_target), by(countryiso_target)
egen obs_year = count(year), by(year)
egen obs_country_year = count(countryiso_target), by(countryiso_target year)

*Generate weight variable
g obs_ctry_share_old = obs_country / obs_total
label var obs_ctry_share_old "Full Sample Country Shares"


// 1.5.3. Order, Compress and Save Dataset
order deal_id deal_bvdid year bvd
qui compress
save "$final/zephyr_privateequity_noown.dta", replace




*** 2. Add Ownership Data ***
*** 2.1. Prepare Ownership Data
/*
use "$orig_own/orbis_ownership_panel_full_variables_group.dta", replace
drop haven_nonsovereign vat tax_corporate_total eu_country tax_max_guo vat_min_guo vat_max_guo taxspread_firm_guo vatspread_firm_guo vatspread_group_guo countryiso subs_group_guo dummy_foreign_parent group_foreign
tab year
save "$form/orbis_ownership_panel_full_variables_group.dta", replace
*/




*** 2.2 Merge Deal and Ownership Variables before Buyout ***
// 2.1.1. Merge Target Ownership Data
use  "$final/zephyr_privateequity_noown.dta", clear

*Merge targets with ownership data
merge 1:1 bvd year using "$form/orbis_ownership_panel_full_variables_group.dta", gen(t_own_match) keep(master match)
foreach var of varlist bvd_guo bvd_parent treelevel companyname guobvdidnumber corpguo_name haven_eu haven_list1 haven_list2 haven_list3 haven_list4 haven_list_all haven_group_eu_guo haven_group_list1_guo haven_group_list2_guo haven_group_list3_guo haven_group_list4_guo haven_group_list_all_guo subs_foreign_guo tax_min_guo taxspread_group_guo haven_group_eu_guo_dummy haven_group_list1_guo_dummy haven_group_list2_guo_dummy haven_group_list3_guo_dummy haven_group_list4_guo_dummy haven_group_list_all_guo_dummy group_firms group_treelevel group_complex group_countries group_international {
	rename `var' t_`var'
}
gen t_standalone = (t_own_match == 1)
rename bvd bvd_target


// 2.1.2. Merge Acquiror Ownership Data
rename bvd_acquiror1 bvd 

*Merge acquirors with ownership data
merge m:1 bvd year using "$form/orbis_ownership_panel_full_variables_group.dta", gen(a_own_match) keep(master match)
foreach var of varlist bvd_guo bvd_parent treelevel companyname guobvdidnumber corpguo_name haven_eu haven_list1 haven_list2 haven_list3 haven_list4 haven_list_all haven_group_eu_guo haven_group_list1_guo haven_group_list2_guo haven_group_list3_guo haven_group_list4_guo haven_group_list_all_guo subs_foreign_guo tax_min_guo taxspread_group_guo haven_group_eu_guo_dummy haven_group_list1_guo_dummy haven_group_list2_guo_dummy haven_group_list3_guo_dummy haven_group_list4_guo_dummy haven_group_list_all_guo_dummy group_firms group_treelevel group_complex group_countries group_international {
	rename `var' a_`var'
}
rename bvd bvd_acquiror1 
rename bvd_target bvd  

*Set haven dummies to zero if missing
foreach var in haven_eu haven_list1 haven_list2 haven_list3 haven_list4 haven_list_all {
	replace a_`var' = 0 if a_`var' == . & a_own_match == 3
	replace t_`var' = 0 if t_`var' == . & t_own_match == 3
}


// 2.1.3. Finalize Dataset
compress
save "$final/zephyr_privateequity.dta", replace

*Save Identifiers for JAR Repository 
use "$final/zephyr_privateequity.dta", clear 

keep deal_bvdid bvd 
duplicates report //0

export delimited "$final/zephyr_privateequity_dealids.txt", replace



*Directory Macros
glo dir = c(pwd)
glo orig = "$dir/Data_Original"
glo form = "$dir/Data_Formatted"
glo final = "$dir/Data_Final"

*Other Macros
set more off, permanently






*** 1. Prepare Category Datasets ***
*** 1.1. Prepare GDP Dataset
*Rename Variables
import excel "$orig/Kreise GDP 2000-2018.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C gdp_total 
label var gdp_total "County GDP (th EUR)"
rename D gdp_worker
label var gdp_work "County GDP per worker"
rename E gdp_capita 
label var gdp_capita "County GDP per capita"
drop F - M

*Clean Dataset
g year = .
forval year = 2000/2018 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
drop if county_id == "05313" 	// Aachen Stadt, (alt)
drop if length(county_id) != 5

destring gdp*, replace force
gen workers = (gdp_total/gdp_worker ) * 1000
label var workers "County workforce"
gen population = (gdp_total/gdp_capita) * 1000
label var population "County population"

*generate lags
qui egen county_ident=group(county_id)
xtset county_ident year
foreach var of varlist gdp_* workers population {
    qui gen `var'_lag1=l.`var'
}


*Save Dataset
compress
save "$form/Kreise GDP 2000-2018.dta", replace




*** 1.2. Prepare Revenues Dataset
*Rename Variables
import excel "$orig/Kreise Einnahmen 2000-2014.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C revenues_total
label var revenues_total "Revenues (gross)"
rename D revenues_admin 
label var revenues_admin "Revenues (admin)"
rename E revenues_tax
label var revenues_tax "Revenues (taxes)"
rename F revenues_transfer
label var revenues_transfer "Revenues (transfer)"
rename G revenues_fee
label var revenues_fee "Revenues (fee)"
rename H revenues_financial
label var revenues_financial "Revenues (financial)"
rename I revenues_contributions
label var revenues_contributions "Revenues (contributions)"
rename J revenues_subsidies
label var revenues_subsidies "Revenues (subsidies)"
rename K revenues_credit
label var revenues_credit "Revenues (credit)"

*Clean Dataset
g year = .
forval year = 2000/2014 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

destring revenues*, replace force

*Save Dataset
compress
save "$form/Kreise Einnahmen 2000-2014.dta", replace




*** 1.3. Prepare Spendings Dataset
*Rename Variables
import excel "$orig/Kreise Ausgaben 2000-2014.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C spendings_total
label var spendings_total "Spendings (gross)"
rename D spendings_admin
label var spendings_admin "Spendings (admin)"
rename E spendings_personal
label var spendings_personal "Spendings (personal)"
rename F spendings_operational
label var spendings_operational "Spendings (operation)"
rename G spendings_financial
label var spendings_financial "Spendings (financial)"
rename H spendings_credit
label var spendings_credit "Spendings (credit)"
rename I spendings_investment
label var spendings_investment "Spendings (investment)"
rename J spendings_net
label var spendings_net "Spendings (net)"

*Clean Dataset
g year = .
forval year = 2000/2014 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

destring spendings*, replace force

*Save Dataset
compress
save "$form/Kreise Ausgaben 2000-2014.dta", replace




*** 1.4. Prepare Taxes Dataset
// 1.4.1. Prepare Data from 2000-2015
*Rename Variables
import excel "$orig/Kreise Steuern 2000-2015.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C taxes_revenue_A
label var taxes_revenue_A "Tax revenue (A)"
rename D taxes_revenue_B
label var taxes_revenue_B "Tax revenue (B)"
rename E taxes_revenue_business
label var taxes_revenue_business "Tax revenue (business)"
rename I taxes_rate_A
label var taxes_rate_A "Tax rate (A)"
rename J taxes_rate_B
label var taxes_rate_B "Tax rate (B)"
rename K taxes_rate_business
label var taxes_rate_business "Tax rate (business)"
rename L taxes_transfer_income
label var taxes_transfer_income "Tax transfer (income)"
rename M taxes_transfer_vat
label var taxes_transfer_vat "Tax transfer (VAT)"
rename N taxes_transfer_business
label var taxes_transfer_business "Tax transfer (business)"

*Clean Dataset
g year = .
forval year = 2000/2015 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

drop F G H O
destring taxes*, replace force

foreach var of varlist taxes_revenue* taxes_transfer* {
	replace `var' = `var' * 1000
}

*Save Dataset
compress
save "$form/Kreise Steuern 2000-2015.dta", replace


// 1.4.2. Prepare Data from 2016-2019
*Rename Variables
import excel "$orig/Kreise Steuern 2016-2019.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C taxes_revenue_A
label var taxes_revenue_A "Tax revenue (A)"
rename D taxes_revenue_B
label var taxes_revenue_B "Tax revenue (B)"
rename E taxes_revenue_business
label var taxes_revenue_business "Tax revenue (business)"
rename I taxes_rate_A
label var taxes_rate_A "Tax rate (A)"
rename J taxes_rate_B
label var taxes_rate_B "Tax rate (B)"
rename K taxes_rate_business
label var taxes_rate_business "Tax rate (business)"
rename M taxes_transfer_business
label var taxes_transfer_business "Tax transfer (business)"
rename O taxes_transfer_income
label var taxes_transfer_income "Tax transfer (income)"
rename P taxes_transfer_vat
label var taxes_transfer_vat "Tax transfer (VAT)"

*Clean Dataset
g year = .
forval year = 2016/2019 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

drop F G H L N Q
destring taxes*, replace force

*Save Dataset
compress
save "$form/Kreise Steuern 2016-2019.dta", replace


// 1.4.3. Merge Datasets
*Merge data
use "$form/Kreise Steuern 2000-2015.dta", clear
append using "$form/Kreise Steuern 2016-2019"

*Save data
sort county_id county year
order county_id county year
save "$form/Kreise Steuern 2000-2019.dta", replace




*** 1.5. Prepare Indebtedness Dataset
// 1.5.1. Prepare Data from 2000-2009
*Rename Variables
import excel "$orig/Kreise Schulden 2000-2009.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C debt_total
label var debt_total "Debt (total)"

rename D debt_credit
label var debt_credit "Debt (credit market)"


*Clean Dataset
g year = .
forval year = 2000/2009 {
	replace year = `year' if county_id == "31.12.`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

drop   E F
destring debt*, replace force

*Save Dataset
compress
save "$form/Kreise Schulden 2000-2009.dta", replace


// 1.5.2. Prepare Data from 2010-2019
*Rename Variables
import excel "$orig/Kreise Schulden 2010-2019.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename D debt_total
label var debt_total "Debt (total)"

rename F debt_credit
label var debt_credit "Debt (credit market)"

*Clean Dataset
g year = .
forval year = 2010/2019 {
	replace year = `year' if county_id == "31.12.`year'" & county == ""
}
replace year = year[_n-1] if year == .

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

drop C   E G H I
destring debt*, replace force

*Save Dataset
compress
save "$form/Kreise Schulden 2010-2019.dta", replace


// 1.5.3. Merge Datasets
*Merge data
use "$form/Kreise Schulden 2000-2009.dta", clear
append using "$form/Kreise Schulden 2010-2019"

foreach var of varlist debt_* {
	replace `var' = `var' * 1000
}


*Save data
sort county_id county year
order county_id county year
save "$form/Kreise Schulden 2000-2019.dta", replace




*** 1.6. Prepare Personal Datasets
// 1.6.1. Prepare Data from 2000-2005
*Rename Variables
import excel "$orig/Kreise Personal 2000-2005.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename D personal_ft
label var personal_ft "Personal (Full-time)"
rename H personal_pt
label var personal_pt "Personal (Part-time)"

*Clean Dataset
g year = .
forval year = 2000/2005 {
	replace year = `year' if county_id == "30.06.`year'" & county == ""
}
replace year = year[_n-1] if year == .
replace county_id = county_id[_n-1] if county_id == ""
replace county = county[_n-1] if county == ""

keep if C == "Insgesamt"
drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

drop C E F G I J K L
destring personal*, replace force

*Save Dataset
compress
save "$form/Kreise Personal 2000-2005.dta", replace


// 1.6.2. Prepare Data from 2006-2019
*Rename Variables
import excel "$orig/Kreise Personal 2006-2019.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename E personal_ft
label var personal_ft "Personal (Full-time)"
rename H personal_pt
label var personal_pt "Personal (Part-time)"

*Clean Dataset
g year = .
forval year = 2006/2019 {
	replace year = `year' if county_id == "30.06.`year'" & county == ""
}
replace year = year[_n-1] if year == .
replace county_id = county_id[_n-1] if county_id == ""
replace county = county[_n-1] if county == ""

keep if C == "Insgesamt"
drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

drop C D F G I J
destring personal*, replace force

*Save Dataset
compress
save "$form/Kreise Personal 2006-2019.dta", replace


// 1.6.3. Merge Datasets
*Merge data
use "$form/Kreise Personal 2000-2005.dta", clear
append using "$form/Kreise Personal 2006-2019"

*Save data
sort county_id county year
order county_id county year
save "$form/Kreise Personal 2000-2019.dta", replace




*** 1.7. Prepare Insolvency & Business Creation Dataset
// 1.6.1. Prepare Insolvency Data from 2007-2020
*Rename Variables
import excel "$orig/Kreise Unternehmensinsolvenzen 2007-2020.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C insolvencies_app 
label var insolvencies_app "Insolvencies (applied)"
rename D insolvencies_op 
label var insolvencies_op "Insolvencies (opened)"
drop E
rename F insolvencies_hr
label var insolvencies_hr "Insolvencies employed staff"
rename G insolvencies_loans
label var insolvencies_loans "Insolvencies loans (EUR th)"

*Clean Dataset
g year = .
forval year = 2007/2020 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .
replace county_id = county_id[_n-1] if county_id == ""
replace county = county[_n-1] if county == ""

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

destring insolvencies*, replace force

*Save Dataset
duplicates tag county year, gen(dup )
browse if dup>0
drop if insolvencies_app==. & dup>0
drop dup 
duplicates report county_id year //ok
 
qui egen county_id_id=group(county_id)
xtset county_id_id year 
compress
save "$form/Kreise_Insolvenzen_2007-2020.dta", replace


// 1.6.2. Prepare Business Creation Data from 1998-2020 
*Rename Variables
import excel "$orig/Kreise Gewerbean-abmeldungen 1998-2020.xlsx", clear

rename A county_id
label var county_id "County id"
rename B county
label var county "County"

rename C business_add
label var business_add "Business Creation (registered)"
rename D business_add_new 
label var business_add_new "Business Creation (registered new)"
rename E business_add_newfirm 
label var business_add_newfirm "Business Creation Firm (registered new)"
 
rename F business_add_influx
label var business_add_influx "Business Influx"
rename G business_add_takeo
label var business_add_takeo "Business Takeover"

rename H business_cease
label var business_cease"Business Cease"
rename I business_cease_est
label var business_cease_est "Business Cease (Establishment)"
rename J business_cease_firm
label var business_cease_firm "Business Cease (Firm)"

rename K business_cease_move
label var business_cease_move "Business Move"
rename L business_cease_hando
label var business_cease_hando "Business Handover"



*Clean Dataset
g year = .
forval year = 1998/2020 {
	replace year = `year' if county_id == "`year'" & county == ""
}
replace year = year[_n-1] if year == .
replace county_id = county_id[_n-1] if county_id == ""
replace county = county[_n-1] if county == ""

tab year 

drop if county == ""
replace county_id = county_id + "000" if county_id == "11" | county_id == "02" 	// Berlin und Hamburg
drop if length(county_id) != 5

destring business*, replace force

*Save Dataset
duplicates tag county year, gen(dup )
browse if dup>0
drop if business_add==. & dup>0
drop dup 
duplicates report county_id year //ok
 
qui egen county_id_id=group(county_id)
xtset county_id_id year 
compress
save "$form/Kreise_businesses_1998-2020.dta", replace


// 1.6.3. Merge Datasets
*Merge data
use "$form/Kreise_Insolvenzen_2007-2020.dta", clear
merge 1:1 county_id year using "$form/Kreise_businesses_1998-2020" , nogen //4230 not matched from using because of additiona year 

*Save data
sort county_id county year
order county_id county year
save "$form/Kreise Insolvenzen Neugewerbe 1998-2020.dta", replace


*** 2. Prepare Final County Dataset ***
// 2.1. Merge County Category Datasets
use "$form/Kreise GDP 2000-2018.dta", clear
merge 1:1 county_id year using "$form/Kreise Einnahmen 2000-2014.dta", nogen
merge 1:1 county_id year using "$form/Kreise Ausgaben 2000-2014.dta", nogen
merge 1:1 county_id year using "$form/Kreise Steuern 2000-2019.dta", nogen
merge 1:1 county_id year using "$form/Kreise Schulden 2000-2019.dta", nogen
merge 1:1 county_id year using "$form/Kreise Personal 2000-2019.dta", nogen
merge 1:1 county_id year using "$form/Kreise Insolvenzen Neugewerbe 1998-2020.dta", nogen

*Clean data
drop if year > 2018

duplicates tag county year, g(dup1)
drop if taxes_revenue_business == . & dup1 > 0
duplicates tag county year, g(dup2)
drop if gdp_total == . & dup2 > 0
drop dup*
duplicates report county year

drop if county_id == "14161" 		// Chemnitz (double entry)
drop if county_id == "14262"		// Dresden (double entry)
drop if county_id == "15358"		// Jerichower Land (ambiguous)
drop if county_id == "14365"		// Leipzig (double entry)
drop if county_id == "15171" 		// Wittenberg (ambiguous)
drop if county_id == "14167" 		// Wittenberg (integrated)
drop if county_id == "15363" 		// Stendal (double entry)
drop if county_id == "15370"		// Altmarkkreissalzwedel (double entry)


// 2.2. Adjust County Names
*Manual adjustments
replace county = "schwerin" if county == "Kreisfreie Stadt Schwerin, Landeshauptstadt"
replace county = "rostock" if county == "Kreisfreie Stadt Rostock, Hansestadt"
replace county = "dillingen" if county == "Dillingen a.d.Donau, Landkreis"
replace county = "frankenthal" if county == "Frankenthal (Pfalz), kreisfreie Stadt"
replace county = "lahndill" if county == "Lahn-Dill-Kreis"
replace county = "landkreisansbach" if county == "Ansbach, Landkreis"
replace county = "landkreisaschaffenburg" if county == "Aschaffenburg, Landkreis"
replace county = "landkreisaugsburg" if county == "Augsburg, Landkreis"
replace county = "landkreisbamberg" if county == "Bamberg, Landkreis"
replace county = "landkreisbayreuth" if county == "Bayreuth, Landkreis"
replace county = "landkreiscoburg" if county == "Coburg, Landkreis"
replace county = "landkreisfuerth" if county == "Fürth, Landkreis"
replace county = "landkreisguerlitz" if county == "Görlitz, Landkreis"
replace county = "landkreisheilbronn" if county == "Heilbronn, Landkreis"
replace county = "landkreishof" if county == "Hof, Landkreis"
replace county = "landkreiskaiserslautern" if county == "Kaiserslautern, Landkreis"
replace county = "landkreiskarlsruhe" if county == "Karlsruhe, Landkreis"
replace county = "landkreiskassel" if county == "Kassel, Landkreis"
replace county = "landkreislandshut" if county == "Landshut, Landkreis"
replace county = "landkreisleipzig" if county == "Leipzig, Landkreis"
replace county = "landkreismuenchen" if county == "München, Landkreis"
replace county = "landkreisoffenbach" if county == "Offenbach, Landkreis"
replace county = "landkreisoldenburg" if county == "Oldenburg, Landkreis"
replace county = "landkreisosnabrueck" if county == "Osnabrück, Landkreis"
replace county = "landkreispassau" if county == "Passau, Landkreis"
replace county = "landkreisregensburg" if county == "Regensburg, Landkreis"
replace county = "landkreisrosenheim" if county == "Rosenheim, Landkreis"
replace county = "landkreisschweinfurt" if county == "Schweinfurt, Landkreis"
replace county = "landkreiswuerzburg" if county == "Würzburg, Landkreis"
replace county = "landsberg" if county == "Landsberg am Lech, Landkreis"
replace county = "neckarodenwald" if county == "Neckar-Odenwald-Kreis, Landkreis"
replace county = "nordwestmecklenburg" if county == "Landkreis Nordwestmecklenburg"
replace county = "oldenburg" if county == "Oldenburg (Oldenburg), kreisfreie Stadt"
replace county = "postdam" if county == "Potsdam, kreisfreie Stadt" 				// Sic in Firm-Data
replace county = "postdammittelmark" if county == "Potsdam-Mittelmark, Landkreis" 	// Sic in Firm-Data
replace county = "saaleorla" if county == "Saale-Orla-Kreis"
replace county = "saarpfalz" if county == "Saarpfalz-Kreis"
replace county = "shwaebischhall" if county == "Schwäbisch Hall, Landkreis" 		// Sic in Firm-Data

*General adjustments
replace county = lower(county)
replace county = substr(county, 1, strpos(county, ",")) if strpos(county, ",") > 0
replace county = subinstr(county, " ", "", .)
replace county = subinstr(county, ",", "", .)
replace county = subinstr(county, ".", "", .)
replace county = subinstr(county, "(", "", .)
replace county = subinstr(county, ")", "", .)
replace county = subinstr(county, "/", "", .)
replace county = subinstr(county, "-", "", .)
replace county = subinstr(county, "ö", "oe", .)
replace county = subinstr(county, "ü", "ue", .)
replace county = subinstr(county, "ä", "ae", .)
replace county = subinstr(county, "Ö", "oe",.)
replace county = subinstr(county, "Ä", "ae",.)
replace county = subinstr(county, "Ü", "ue",.)
replace county = subinstr(county, "ß", "ss", .)

	
// 2.3. Finalize Dataset
compress
sort county year
order county year
duplicates report county year

duplicates tag county year, g(dup1)
drop if taxes_revenue_business == . & dup1 > 0
duplicates tag county year, g(dup2)
drop if gdp_total == . & dup2 > 0
drop dup*
duplicates report county year

save "$final/Kreise Final 2000-2019.dta", replace













*Directory macros 
/*to be set by user
glo dir = c(pwd)
glo buyouts = "..."
*/


*Color scheme
set scheme s2color


*** 1. Prepare Dataset ***
*** 1.1. Prepare Aggregate German County Data
// 1.1.1. Select Observations
use "$financials/orbis_DE.dta", clear

*Select observation
drop if industry_nace1 == ""
drop if county == ""
drop if year > 2018 | year < 2000


// 1.1.2. Adjust County Variable
*Adjust county names
replace county = substr(county, strpos(county, "|")+1, .) if strpos(county, "|") > 0
replace county = substr(county, strpos(county, "|")+1, .) if strpos(county, "|") > 0
replace county = substr(county, 1, strpos(county, ",")) if strpos(county, ",") > 0
replace county = lower(county)
replace county = subinstr(county, " ", "", .)
replace county = subinstr(county, ",", "", .)
replace county = subinstr(county, ".", "", .)
replace county = subinstr(county, "(", "", .)
replace county = subinstr(county, ")", "", .)
replace county = subinstr(county, "/", "", .)
replace county = subinstr(county, "-", "", .)


// 1.1.3. Merge Buyout Data and Collapse

*Merge m&a buyout data
merge 1:1 bvd year using "$buyouts/zephyr_manda.dta", ///
	keep(master matched) nogen keepusing(deal_value deal_manda)
rename deal_value deal_value_manda
rename deal_manda targets_manda
	
*Merge private equity buyout data
merge 1:1 bvd year using "$buyouts/zephyr_privateequity.dta", ///
	keep(master matched) nogen keepusing(deal_value obs_total)
g targets = (obs_total != .)


// 1.1.4 Collapse Data at Local Level
*Prepare some additional variable 
g ind_manu=inlist(industry_nace1,"C","F")
g ind_trade=inlist(industry_nace1,"G")
g ind_service=inlist(industry_nace1,"H","I","K","L","M","N","Q","S")
g ind_info=inlist(industry_nace1,"J")
g ind_util=inlist(industry_nace1,"A","B","D","E")
g ind_other=(ind_manu==0 & ind_trade==0 & ind_service==0 & ind_manu==0 & ind_info==0 )

g firms = 1
g deal_assets_total = assets_total if targets == 1
g deal_assets_total_manda = assets_total if targets_manda == 1

foreach ind of varlist ind_* {
g `ind'_firms = 1 if `ind' ==1
g `ind'_assets_total = assets_total if `ind' ==1 //Coarse industry composition controls: https://ec.europa.eu/eurostat/documents/3859598/5902521/KS-RA-07-015-EN.PDF
drop  `ind'
}


*Collapse data
qui egen municipal_id=group(municipal)
qui egen municipals_county=nvals(municipal_id), by(county year)

keep firms targets* assets_total deal_assets_total* deal_value*   ind_*    municipals_county county year

collapse (sum) firms targets* assets_total deal_assets_total* deal_value*  ind_*   (first)municipals_county , ///
	by(county year)

sum municipals_county

// 1.1.5. Merge County and Industry Data
*Merge county and industry data
merge 1:1 county year using "$counties/Kreise Final 2000-2019.dta", keep(matched) nogen


// 1.1.6. Compress and Save Dataset
compress
save "$merged/counties_form.dta", replace
asdf



*** 1.2. Prepare Variables
// 1.2.1. Set Panel Data
eststo clear
use "$merged/counties_form.dta", clear

g state_id = (substr(county_id, 1, 2))
destring state_id, replace

drop county_id
egen county_id = group(county)
xtset county_id year

 
// 1.2.2. Define Treatment Variables
*Define treatments
g treatment = (targets > 0)
label var treatment "Treated PE"
g treatment_intense1 = (targets > 0 & deal_assets_total > 100000000)
label var treatment_intense1 "Treated PE Intense"
g treatment_intense2 = (targets > 0 & deal_assets_total > 500000000)
label var treatment_intense2 "Treated PE Very Intense"

g treatment_manda = (targets_manda > 0)
label var treatment_manda "Treated M&A"
g treatment_manda_intense1 = (targets_manda > 0 & deal_assets_total_manda > 100000000)
label var treatment_manda_intense1 "Treated M&A Intense"
g treatment_manda_intense2 = (targets_manda > 0 & deal_assets_total_manda > 500000000)
label var treatment_manda_intense2 "Treated M&A Very Intense"

g treatment_int = treatment * treatment_manda
label var treatment_int "Treated PE * Treated M&A"
g treatment_int_intense1 = treatment_intense1 * treatment_manda_intense1
label var treatment_int "Treated PE * Treated M&A (Intense)"
g treatment_int_intense2 = treatment_intense2 * treatment_manda_intense2
label var treatment_int "Treated PE * Treated M&A (Very Intense)"
 

*Generate treatment dummies
g year_tr = year if treatment == 1
egen year_event = min(year_tr), by(county_id)

replace treatment = 1 if treatment[_n-1] == 1 & county_id == county_id[_n-1]
replace treatment_intense1 = 1 if treatment_intense1[_n-1] == 1 & county_id == county_id[_n-1]
replace treatment_intense2 = 1 if treatment_intense2[_n-1] == 1 & county_id == county_id[_n-1]

replace treatment_manda = 1 if treatment_manda[_n-1] == 1 & county_id == county_id[_n-1]
replace treatment_manda_intense1 = 1 if treatment_manda_intense1[_n-1] == 1 & county_id == county_id[_n-1]
replace treatment_manda_intense2 = 1 if treatment_manda_intense2[_n-1] == 1 & county_id == county_id[_n-1]

*Tab treatment variables
tab treatment
tab treatment_manda
tab treatment treatment_manda


// 1.2.4. Generate Other Variables
*Generate main dependent variable
g taxes_revenue_business_log = ln(1+taxes_revenue_business) * 100
label var taxes_revenue_business_log "Log. Business Tax Revenue"
g spendings_net_log = ln(1+spendings_net) * 100
label var spendings_net_log "Log. Spendings"
g debt_share = debt_total / gdp_total  
label var debt_share "Debt level over GDP (%)"


qui gen debt_total_log=ln(debt_total) * 100

gen debt_budget_share = (debt_total / (  revenues_total - revenues_transfer )) * 100

label var debt_budget_share "Debt (% of Revenue)"

*Generate memorandum dependent variables
g spendings_personal_log = ln(1+spendings_personal) * 100
label var spendings_personal_log "Log. Personal Spendings"
g spendings_operational_log = ln(1+spendings_operational) * 100
label var spendings_operational_log "Log. Operational Spendings"
g spendings_investment_log = ln(1+spendings_investment) * 100
label var spendings_investment_log "Log. Investment Spendings"

g spendings_social = spendings_admin - spendings_personal - spendings_operational
g spendings_social_log = ln(1+spendings_social) * 100
label var spendings_social_log "Log. Social Spendings"

qui gen revenues_credit_log = ln(1+revenues_credit) * 100
gen spendings_credit_log = ln(1+spendings_credit) * 100
label var spendings_credit_log "Log. Debt Repayment"
label var revenues_credit_log "Log. New Debt"

gen net_new_debt_share=((revenues_credit - spendings_credit ) / ( debt_credit) ) * 100
label var net_new_debt_share "New Debt (%)"


g taxes_transfer_income_log = ln(1+taxes_transfer_income) * 100
label var taxes_transfer_income_log "Log. Income Tax Transfer"
g taxes_transfer_vat_log = ln(1+taxes_transfer_vat) * 100
label var taxes_transfer_vat_log "Log. VAT Tax Transfer"
g taxes_transfer_business_log = ln(1+taxes_transfer_business) * 100
label var taxes_transfer_business_log "Log. Business Tax Transfer"

*Generate fixed effects
g fixed_effects = state_id * year

*Generate control variables
 
foreach var of varlist gdp_total_* population_* workers_* {
	replace `var' = ln(1+`var')
}

foreach var of varlist ind_*firms ind_*assets_total {
	gen `var'_log = ln(1+`var')
}


foreach var of varlist ind_manu_firms ind_trade_firms ind_service_firms {
	qui gen `var'_ratio = `var' / firms
}
qui gen ind_other_firms_ratio = 1 - ind_manu_firms_ratio - ind_trade_firms_ratio -  ind_service_firms_ratio
 replace ind_other_firms_ratio = 0 if ind_other_firms_ratio < 0

label var ind_manu_firms_ratio  "Manufacturing Firms Share"
label var ind_trade_firms_ratio "Trade Firms Share"
label var ind_service_firms_ratio "Service Firms Share"
label var ind_other_firms_ratio "Other Firms Share"

label var gdp_total_lag1 "Log. GDP (t-1)"
label var population_lag1 "Log. Population (t-1)"
label var workers_lag1 "Log. Workforce (t-1)"


*Total aggregates
gen firms_log=ln(firms)
gen assets_total_sum_log=ln(assets_total)

*Generate fixed effects
egen state_id_year = group(state_id year)


*Save dataset
drop if year <2001 

compress
save "$merged/analysis_counties.dta", replace
asdf




*** 2. Analysis ****
// 2.1. Public Finance Analysis
*Regressions
eststo clear
use"$merged/analysis_counties.dta", clear
 
glo fixedeffects = "county_id year"  
global controls_counties = "" //no controls in main spec  
 
*Tax Revenue
qui eststo taxrev1a: reghdfe taxes_revenue_business_log treatment treatment_manda treatment_int $controls_counties, absorb($fixedeffects) vce(cluster county_id)
qui g sample_counties = 1 if e(sample)
keep if sample_counties == 1
qui eststo taxrev1b: reghdfe taxes_revenue_business_log treatment_intense1 treatment_manda_intense1 treatment_int_intense1 $controls_counties , absorb($fixedeffects) vce(cluster county_id)
qui eststo taxrev1c: reghdfe taxes_revenue_business_log treatment_intense2 treatment_manda_intense2 treatment_int_intense2 $controls_counties , absorb($fixedeffects) vce(cluster county_id)

*Government Spendings
eststo spendings1a: reghdfe spendings_net_log treatment treatment_manda treatment_int $controls_counties, absorb($fixedeffects) vce(cluster county_id)
eststo spendings1b: reghdfe spendings_net_log treatment_intense1 treatment_manda_intense1 treatment_int_intense1 $controls_counties, absorb($fixedeffects) vce(cluster county_id) //main specification
qui eststo spendings1c: reghdfe spendings_net_log treatment_intense2 treatment_manda_intense2 treatment_int_intense2 $controls_counties, absorb($fixedeffects) vce(cluster county_id)

*Public Debt
sum net_new_debt_share, d
qui eststo debt1a: reghdfe net_new_debt_share treatment treatment_manda treatment_int $controls_counties, absorb($fixedeffects) vce(cluster county_id)
qui eststo debt1b: reghdfe net_new_debt_share treatment_intense1 treatment_manda_intense1 treatment_int_intense1 $controls_counties, absorb($fixedeffects) vce(cluster county_id)
qui eststo debt1c: reghdfe net_new_debt_share treatment_intense2 treatment_manda_intense2 treatment_int_intense2 $controls_counties, absorb($fixedeffects) vce(cluster county_id)

 
  

*Output Stata
estout taxrev1? spendings1? debt1?,  ///  
keep(treatment treatment_intense1 treatment_intense2) order(treatment treatment_intense1 treatment_intense2) stats(N r2_a, fmt(%9.0f %9.4f) labels("Observations" "adj. R2")) ///
c(b(fmt(%9.2f) star) t(par fmt(%9.2f))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) label

  
 
 
 
 

*Directory macros 
/*to be set by user
glo dir = c(pwd)
glo buyouts = "..."
*/

*Color scheme & font
set scheme s2color
graph set window fontface "Times New Roman"
set more off

*Event period and version
glo event_start = -3
glo event_finish = 3
glo event_time = $event_finish - $event_start + 1

glo version = "vFinal"  

*Variable macros 
glo countries = "AT BE BG CH CY CZ DE DK EE ES FI FR GB GR HR HU IE IS IT LI LT LU LV MT NL NO PL PT RO SE SI SK"

glo vars_dv_tax= "ratio_taxes_ebt costs_taxes_log profit_ebt_log taxhaven_all_dummy tax_diff_firm_log fees_tax_log_fame fees_nontax_log_fame"

glo vars_dv_inv= "capex_log capex_tan_log deal_manda_dummy deal_manda_local_dummy growth_employment salary_log"

glo vars_control = "assets_total_log ratio_ebit_assets ratio_leverage ratio_assets_intan ratio_cash treelevel group_treelevel_log gdp_capita gdp_total interest_long interest_short"
 
glo vars_crosss = "i_t_tax_potential i_grouptaxcross i_deal_pe_first i_deal_big30 i_ipdiff i_credit_investment"



*** 1. Prepare Dataset ***
*** 1.1. Select Observations
use "$financials/financials_treatedcontrols_${version}.dta", clear
xtset firmid year

*Outcome variables 
g growth_employment= (number_employees-l.number_employees) / (0.5*(number_employees+l.number_employees)) // Davis et al. (2014), Antoni et al. (2019)
g capex_intan_raw = assets_fixed_intan - l.assets_fixed_intan
g capex_intan_raw_log=ln(capex_intan_raw)
g capex_intan = (assets_fixed - l.assets_fixed) - (assets_fixed_tan - l.assets_fixed_tan)  
g capex_intan_log=ln(capex_intan)
g capex_intan_net = (assets_fixed - l.assets_fixed) - (assets_fixed_tan - l.assets_fixed_tan) + exp_depreciation
g capex_intan_net_log=ln(capex_intan_net)

*Keep matched observations
drop if matched == 0

*Select sample period years
drop if year_event == 2000
drop if year < 2000

*Keep observations within estimation event window 
drop if year_dummy > $event_finish
drop if year_dummy < $event_start


*** 1.2. Add Additional Data
*Add UK financial data
merge m:1 bvd year using "$uk_fame/fame_ukfirms.dta", ///
	nogen keep(master matched) keepusing(fees_tax_log_fame fees_nontax_log_fame)

*Add PE deal data
merge m:1 deal_id using "$buyouts/zephyr_privateequity.dta", ///
	keep(master matched) ///
	keepusing(obs_country obs_year date_announcement deal_big1 deal_pvendor2 ///
	a_tax_min_guo a_haven_group_list_all_guo_dummy deal_* a_*) nogen
	
*Add M&A deal data
rename bvd bvd_acquiror
merge m:1 bvd_acquiror year using "$buyouts/zephyr_manda_acquirors.dta", ///
	nogen keep(master matched) keepusing(deal_manda deal_manda_local)
	
	merge m:1 bvd_acquiror year using "$buyouts/zephyr_manda_acquirors_havens.dta", ///
	nogen keep(master matched) keepusing(deal_haven )
rename bvd_acquiror bvd
	
*Add macro data
rename country countryiso
merge m:1 countryiso year using "$macro/oecd_countries.dta", ///
	keep(master matched) keepusing(gdp_capita gdp_total	interest_long interest_short tax_corporate_total ///
	credit_* incentive_* ip_box*) nogen

*Add regulation data
merge m:1 countryiso year using "$regulation/regulation_countries.dta", ///
	keep(master matched) keepusing(group*) nogen
rename countryiso country

*Target ownership data
merge m:1 bvd year using "$ownership/orbis_ownership_europe.dta", ///
	keep(master matched) keepusing(taxspread* haven_group* subs_* bvd_parent bvd_guo treelevel *box*) nogen
foreach var of varlist taxspread* haven_group* subs_* {
	rename `var' t_`var'
}



*** 1.3. Generate Relevant Variables
// 1.3.1. Generate event Variables
*Generate individual event dummies
sort firmid year
replace treatment = 1 if treatment == .
forvalues year = $event_start (1) $event_finish {
	loc dummy = `year' - $event_start
	qui g byte event_`dummy' = 1 if year_dummy == `year'
	qui replace event_`dummy' = 0 if year_dummy!= `year'
	label var event_`dummy' "Event (t=`year')"
	
	qui g byte event_tr_`dummy' = event_`dummy' * treatment
	label var event_tr_`dummy' "Event (t=`year') * Treated PE"
}
loc drop = -$event_start - 1
drop event_`drop' event_tr_`drop'

*Generate cumulated event dummies
g after = 1 if year_dummy >= 0
replace after = 0 if after == .
g after_tr = after * treatment
label var after_tr "Post * Treated PE"


// 1.3.2. Generate Additional Variable
*Generate additional dependent variables
qui gen salary_log=ln(1 + exp_employees / number_employees)
label var salary_log  "Log. Avg. Salaries"

replace deal_manda = 0 if deal_manda == .
label var deal_manda "Number of M&A Deals"
g deal_manda_log = ln(1 + deal_manda)  
label var deal_manda_log "Log. Number of M&A Deals"
g deal_manda_dummy = (deal_manda > 0)  
label var deal_manda_dummy "M&A Deal"

replace deal_manda_local = 0 if deal_manda_local == .
label var deal_manda_local "Number of Local M&A Deals"
g deal_manda_local_log = ln(1 + deal_manda_local)  
label var deal_manda_local_log "Log. Number of Local M&A Deals"
g deal_manda_local_dummy = (deal_manda_local > 0)  
label var deal_manda_local_dummy "Local M&A Deal"
qui gen taxhaven_noeu_log= ln(1+t_haven_group_list1_guo) 
label var taxhaven_noeu_log "Log. Tax Haven Entities Non-EU"
gen taxhaven_noneu_dummy = (t_haven_group_list1_guo> 0 & t_haven_group_list1_guo!=.)
label var taxhaven_noneu_dummy "Tax Haven Non-EU"

g taxhaven_eu_log = ln(1+t_haven_group_eu_guo)  
label var taxhaven_eu_log "Log. Tax Haven Entities EU"

gen taxhaven_eu_dummy =  (t_haven_group_eu_guo> 0 & t_haven_group_eu_guo!=.)
replace taxhaven_eu_dummy = taxhaven_eu_dummy  
label var taxhaven_eu_dummy "Tax Haven EU"

gen taxhaven_all_log = ln(1+t_haven_group_list_all_guo)  
label var taxhaven_all_log "Log. Tax Haven Entities"

gen taxhaven_all_dummy =  (t_haven_group_list_all_guo> 0 & t_haven_group_list_all_guo!=.)
label var taxhaven_all_dummy "Tax Haven"
 
gen tax_diff_firm_log =  ln(1+t_taxspread_firm_guo)  
label var tax_diff_firm_log "Intl. Tax Differential (%)"
label var t_taxspread_firm_guo "Intl. Tax Differential (pp)"

*Generate additional control variable
g ratio_assets_intan = assets_fixed_intan / assets_total
label var ratio_assets_intan "Intangible Ratio"

*Country weights
egen obs_country_dummy = count(country) if year_dummy == -1 & treatment == 1, by(country)
egen obs_country_sample = mean(obs_country_dummy), by(deal_id)

g weights_country = obs_country / obs_country_sample
qui sum weights_country
replace weights_country = weights_country / r(mean)
label var weights_country "Country Sample Weights"

*Generate positive pre-deal ETR and EBT variables
//pos_etr_predeal == 1 & pos_ebt_predeal==1 condition

qui gen pos_etr_1 = (ratio_taxes_ebt > = 0 & year_dummy==-1)
qui gen pos_etr_2 = (ratio_taxes_ebt > = 0 & year_dummy==-2)
qui gen pos_etr_3 = (ratio_taxes_ebt > = 0 & year_dummy==-3)

qui egen pos_etr1_deal=max(pos_etr_1), by(deal_id) 
qui egen pos_etr2_deal=max(pos_etr_2), by(deal_id) 
qui egen pos_etr3_deal=max(pos_etr_3), by(deal_id) 
gen pos_etr_predeal =((pos_etr1_deal+ pos_etr2_deal+ pos_etr3_deal)==3)

qui gen pos_ebt_1 = (profit_ebt > = 0 & year_dummy==-1)
qui gen pos_ebt_2 = (profit_ebt > = 0 & year_dummy==-2)
qui gen pos_ebt_3 = (profit_ebt > = 0 & year_dummy==-3)

qui egen pos_ebt1_deal=max(pos_ebt_1), by(deal_id) 
qui egen pos_ebt2_deal=max(pos_ebt_2), by(deal_id) 
qui egen pos_ebt3_deal=max(pos_ebt_3), by(deal_id) 
gen pos_ebt_predeal =((pos_ebt1_deal+ pos_ebt2_deal+ pos_ebt3_deal)==3)


*Generate additional control variables
qui gen group_treelevel_log = ln(group_treelevel)
label var group_treelevel_log "Log. Subsidiary Level"

qui gen group_complex_log = ln(group_complex)
label var group_complex_log "Log. Group Levels"

*Adjust variables
replace gdp_capita = gdp_capita / 1000
label var gdp_capita "GDP / Capita (th)"
replace gdp_total = gdp_total / 1000000
label var gdp_total "GDP (tn)"

replace growth_roa_2 = growth_roa_2 * 100
replace fees_tax_log_fame = fees_tax_log_fame / 100
replace fees_nontax_log_fame = fees_nontax_log_fame / 100


// 1.3.3. Generate Cross-Sectional Variables
*Tax avoidance potential
g tax_potential = (ratio_taxes_ebt * 100 - tax_corporate_total) if year_dummy == -1 & treatment == 1 
qui egen i_tax_potential = mean(tax_potential), by(deal_id)

sum i_tax_potential, d
gen i_t_tax_potential = (i_tax_potential > 0)

*Clean group tax consolidation variable across countries 
replace grouptaxcross = 1 if grouptaxcross == 0.75
replace grouptaxcross = 0 if grouptaxcross == .


*Pre-deal dummies for cross-sectional tests
foreach var of varlist deal_pe_first deal_big30 grouptaxcross credit_investment ip_box ip_box_rate   group_ip_box group_ip_box_rateavg group_ip_box_ratemin  tax_corporate_total {
	loc var_label : var label `var'
	qui gen helpvar = `var' if year_dummy == -1 & treatment ==1
	qui egen i_`var' = mean(helpvar), by(deal_id)
	label var i_`var' "`var_label'"
	drop helpvar
}
replace i_grouptaxcross = 0 if t_subs_group_guo < 2

*IP Box dummy
gen i_ipdiff=(i_tax_corporate_total>i_group_ip_box_ratemin) & inlist(industry_nace1, "J", "M") // 
replace i_ipdiff = . if i_group_ip_box_ratemin==.  
replace i_ipdiff = 0 if i_group_ip_box_ratemin==. & inlist(industry_nace1, "J", "M")  


// 1.3.4 Format and Winsorize within-sample
*Winsorize 
foreach var of varlist ratio* {
	qui replace `var' = `var' * 100
}
winsor2 *log* ratio* *growth* capex*, cuts(1 99) replace 


 

*** 1.4. Finalize Dataset
// 1.4.1. Label Data
*Label dependent variables
label var capex_log "Log. Capex"
label var capex_tan_log "Log. Tangible Capex"
label var ratio_assets_intan "Intangible Ratio (%)"
label var capex_intan_raw_log "Log. Intangible Capex"
label var growth_employment "Employment Growth"

*Label control variables
label var assets_fixed_tan_log "Log. Tangible Assets"
label var treelevel "Subsidiary Level"
label var group_treelevel_log "Log. Group Levels"
label var group_complex_log "Log. Group Levels"
label var assets_fixed_log "Log. Fixed Assets"
label var assets_fixed_intan_log "Log. Intangible Assets"
label var interest_long "Long-t. Interest Rate (%)"
label var interest_short "Short-t. Interest Rate (%)"

*Label interaction variables:      
label var i_t_tax_potential "Tax Savings Potential"
label var i_grouptaxcross "Group Tax Consolidation"
label var i_deal_pe_first "First PE Investor"
label var i_deal_big30 "Big PE Player"
label var i_ipdiff "IP Box Access"
label var i_credit_investment "Investment Tax Credits"

*Label matching variables
label var growth_assets_2 "Log. Asset Growth (2-year)"
label var growth_assets_fixed_2 "Log. Fixed Asset Growth (2-year)"
label var growth_roa_2 "ROA Improvement (2-year in pp)"
label var growth_revenue_2 "Log. Revenue Growth (2-year)"

*Compress, sort, and save dataset
qui compress
sort firmid year
xtset firmid year
save "$merged/analysis_treatedcontrols_${version}.dta", replace

asdf


*** 2. Descriptive Statistics ***
*** 2.2. Generate Graphs for Distribution of Observations
*Generate country figure
use "$merged/analysis_treatedcontrols_${version}.dta", clear

replace year = year + 1
keep if year == year_event & treatment == 1 & matched == 1

g obs_country_tr = 1
g obs_year_tr = 1

qui sum obs_country if country == "NL" & bvd != "NL24311905" // PS: Data error, wrong allocation to GB
replace obs_country = `r(mean)' if bvd == "NL24311905"
 
collapse (mean) obs_country (sum) obs_country_tr, by(country)
gsort -obs_country_tr
g rank = _n
replace rank = 16 if rank > 15
replace country = "rest" if rank > 15

collapse (sum) obs_country obs_country_tr, by(rank country)
egen obs_country_total = sum(obs_country)
g obs_country_rel = obs_country / obs_country_total * 100
tab  rank  	country	//   Check country ranking to define xlabel below

twoway (bar obs_country_tr rank, yaxis(1)) ///
(connected obs_country_rel rank, yaxis(2)), ///
ytitle("{stSerif}Number of Observations", size(medium) axis(1)) ytitle("{stSerif}Percent", size(medium) axis(2)) ///
xtitle("{stSerif}Country (Alpha-2 Code)") /// 
graphregion(color(white)) bgcolor(white) ///
xlabel(1 "FR" 2 "GB" 3 "ES" 4 "IT" 5 "SE" 6 "DE" 7 "FI" 8 "BE" 9 "NO" 10 "NL" 11 "DK" 12 "PL" 13 "PT" 14 "CZ" 15 "RO" 16 "Rest") ///
legend(cols(1) label(1 "{stSerif}Number of deals in analysis") label(2 "{stSerif}Country share of deals in Zephyr data"))
graph export "$dir/Graphs/observations_country_rel.png", replace
graph close

*Generate year figure
use "$merged/analysis_treatedcontrols_${version}.dta", clear
 
replace year = year + 1
keep if year == year_event & treatment == 1 & matched == 1

g obs_country_tr = 1
g obs_year_tr = 1
 
collapse (mean) obs_year (sum) obs_year_tr, by(year)
egen obs_year_total = sum(obs_year)
g obs_year_rel = obs_year / obs_year_total * 100
replace year = year - 2000
tab year

twoway (bar obs_year_tr year, yaxis(1)) ///
(connected obs_year_rel year, yaxis(2)), ///
ytitle("{stSerif}Number of Observations", size(medium) axis(1)) ytitle("{stSerif}Percent", size(medium) axis(2)) ///
yscale(range(0 800) axis(1)) yscale(range(0 8) axis(2)) ///
ylabel(0(200)800, axis(1)) ylabel(0(2)8, axis(2)) ///
xtitle("{stSerif}Year (2000s)") xscale(range(1 18)) xlabel(1(1)18) /// 
graphregion(color(white)) bgcolor(white) ///
legend(cols(1) label(1 "{stSerif}Number of deals in analysis") label(2 "{stSerif}Annual share of deals in Zephyr data"))
graph export "$dir/Graphs/observations_year_rel.png", replace
graph close




*** 2.3. Generate Summary Statistics
*Load dataset
eststo clear
use "$merged/analysis_treatedcontrols_${version}.dta", clear

*Regression sample 
eststo etra: reghdfe ratio_taxes_ebt event_? event_tr_? $vars_control  , 	absorb(firmid year) vce(cluster firmid)  
keep if e(sample)

*adjust units for percentage terms 
foreach var of varlist taxhaven_all_dummy deal_manda_dummy deal_manda_local_dummy growth_employment  $vars_crosss {
 replace `var' = `var' * 100
 }

*Generate summary statistics
estpost tabstat ///
	$vars_dv_tax $vars_dv_inv /// Dep.
	$vars_crosss /// Int.
	$vars_control /// Controls 
	assets_total assets_fixed capex capex_tan profit_ebt , /// raw data 
	statistics(count mean median sd min max) columns(statistics)

*Output
estout ., ///
cells("count(l(Obs) f(%12.0fc)) mean(l(Mean) f(%12.2f)) p50(l(Median) f(%12.2f)) min(l(Min) f(%12.2f)) max(l(Max) f(%12.2f)) sd(l(SD) f(%12.2f))") label

  

*** 3. Graphical Analysis ***
*** 3.1. Descriptive Graphical Analysis
// 3.1.1. Effective Tax Rate
use "$merged/analysis_treatedcontrols_${version}.dta", clear

loc var = "ratio_taxes_ebt"
loc var_label : var label `var'
foreach stat in "mean" "median"  {
preserve
	collapse  (`stat') `var', by(treatment year_dummy)
	
	twoway (line `var' year_dummy if treatment == 1, sort lpattern(dash)) ///
	(line `var' year_dummy if treatment == 0, sort), /// 
	ytitle({stSerif}`var_label' (`stat')) xtitle({stSerif}Year Relative to Treatment) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "{stSerif}Treated") label(2 "{stSerif}Controls")) ///
	xline(-1) xla(-3 -2 -1 0 1 2 3)  yla(12(2)26)
	  
	graph  export "$dir/Graphs/${version}_`var'_`stat'.png", replace
	 
	graph close
restore
}



*** 3.3. Firm-level Outcomes Event-Study Design 
// 3.3.1. Tax and Economic Outcome Variables - Graphical 
eststo clear
use "$merged/analysis_treatedcontrols_${version}.dta", clear
 
*Scale variables
foreach var of varlist profit_ebt_log costs_taxes_log fees_tax_log_fame fees_nontax_log_fame tax_diff_firm_log taxhaven_*  ///
number_employees_log exp_employees_log salary_log employees_add_log laborexpenses_add_log growth_employees growth_employment capex_*log   deal_manda*  {
	qui replace `var' = `var' * 100
}  
 

*Main specification 
eststo etra: reghdfe ratio_taxes_ebt event_? event_tr_? $vars_control  , 	absorb(firmid year) vce(cluster firmid)  
qui g sample_controls = 1 if e(sample)  

*Save Identifiers for JAR Repository (Controls and Treated firms)
preserve 
keep bvd treatment year_event
duplicates drop 
tab treatment //11k+deals
keep bvd 
sort bvd 
export delimited "$merged/analysis_treatedcontrols_identifiers.txt", replace
restore 

*Average effect for text discussion 
eststo etr_full: reghdfe ratio_taxes_ebt after after_tr $vars_control  , 	absorb(firmid year) vce(cluster firmid)  
di _b[after_tr]
 

*Run analysis & produce event-study graphs  //for each type of variable, ylabel options are provided below
keep if sample_controls ==1 	
loc var = "deal_manda_dummy" //of 	varlist ratio_taxes_ebt profit_ebt_log costs_taxes_log taxhaven_eu_log taxhaven_eu_dummy taxhaven_all_log taxhaven_all_dummy 		growth_employees		t_taxspread_firm_guo tax_diff_firm_log 	 capex_log capex_tan_log growth_employees deal_manda_dummy deal_manda_local_dummy  number_employees_log  fees_tax_log_fame_m fees_nontax_log_fame_m ratio_assets_intan capex_intan_raw_log
loc ylabels =   "ylabel(-2 (2) 6)"  // "ylabel(-50 (25) 25)" "ylabel(-5 (2.5) 15 )" Log Havens: "ylabel(-5 (2.5) 10)" Haven Dummies:  "ylabel(-2 (2) 8)" Log Tax Differential: "ylabel(-10 (5) 25)"	 ETR:  "ylabel(-6 (1) 3)" Log EBT and Taxes: "ylabel(-30 (10) 30)"	, Capex and new labor:  "ylabel(-20 (10) 50)" M&A: "ylabel(-2 (2) 6)" , FAME:  "ylabel(-50 (25) 75)", growth_employees growth_employment salary_log:  "ylabel(-3 (2) 6)"  ratio_assets_intan :  "ylabel(-1 (1) 3)"  
 
*** 
	winsor2 `var' , cuts(1 99) replace 
	loc var_label : var label `var' 
	
	*Regression specification
	qui reghdfe `var' event_? event_tr_?, ///
		absorb(firmid year) vce(cluster firmid)
	
	loc coef = floor(_b[event_tr_0]*100)/100
	loc tstat = floor(_b[event_tr_0] / _se[event_tr_0]*100)/100
	di ""
	di "`var_label' coefficient (t = -3): `coef' (t-stat: `tstat')"

	*Insert coefficients into variables
	qui gen fig_b = .
	qui gen fig_se = .
	qui gen fig_t = _n-4 in 1/7

	forvalues x = 0/6 {
		loc y = `x' + 1
		cap replace fig_b=_b[event_tr_`x'] in `y'
		cap replace fig_se=_se[event_tr_`x'] in `y'
	}
	qui replace fig_b = 0 in 3
	qui replace fig_se = 0 in 3

	*Generate confidence intervals
	qui gen fig_upper = fig_b + 1.96 * fig_se  
	qui gen fig_lower = fig_b - 1.96 * fig_se  

	*Output graph
	di "Next graph: `var_label'"
	twoway (rarea fig_lower fig_upper fig_t, color(navy)) (scatter fig_b fig_t, mcolor(cranberry)), ///
		/*title(`var_label') */ ///
		xtitle({stSerif}Year Relative to Treatment) ytitle({stSerif}`var_label') ///
		graphregion(color(white)) bgcolor(white) ///
		legend(order(2 1) label(2 "{stSerif}Coefficient Estimate") label(1 "{stSerif}95 % Confidence Interval") cols(2)) ///
		yline(0, lc(red) lp(solid)) xline(-1) xlabel(-3 (1) 3) `ylabels'
	  graph export "$dir/Graphs/${version}_`var'_reg.png", replace
	*graph close

	drop fig*
*** 
 
  

 
		
*** 4. Regression Analysis - Effective Tax Rates Specifications  ***
*** 4.1. Regressions with Stand-Alone Controls
*Load dataset
eststo clear
use "$merged/analysis_treatedcontrols_${version}.dta", clear

*Regressions
qui eststo etra: reghdfe ratio_taxes_ebt event_? event_tr_? $vars_control, ///
	absorb(firmid year) vce(cluster firmid)
qui eststo etrb: reghdfe ratio_taxes_ebt event_? event_tr_? $vars_control ///
	if pos_etr_predeal == 1 & pos_ebt_predeal==1  , absorb(firmid year) vce(cluster firmid)
qui g sample_controls = 1 if e(sample)
qui eststo etrc: reghdfe ratio_taxes_ebt event_? event_tr_? ///
	if pos_etr_predeal == 1 & pos_ebt_predeal==1 & sample_controls == 1, absorb(firmid year) vce(cluster firmid)

*Untabulated: Result No M&As	
qui egen deal_manda_max=max(deal_manda), by(firmid)
eststo etr_x1: reghdfe ratio_taxes_ebt event_? event_tr_? $vars_control if deal_manda_max==0 | treatment==0, ///
	absorb(firmid year) vce(cluster firmid)

 
 
*** 4.2. Regressions with M&A Controls
*Prepare dataset
use "$merged/analysis_treatedcontrols_${version}.dta", clear
drop if treatment == 0
qui append using "$financials/financials_treatedcontrols_manda_${version}.dta"

qui replace ratio_taxes_ebt = ratio_taxes_ebt * 100 if treatment == 0
winsor2 ratio_taxes_ebt, cuts(1 99) replace
qui egen firmid2 = group(bvd)

egen fixed_effects_ctryr = group(country year)
egen fixed_effects_indyr = group(industry_nace1 year)

*Regressions
qui eststo etri: reghdfe ratio_taxes_ebt event_? event_tr_?, ///
	absorb(firmid2 year) vce(cluster firmid2)
  distinct bvd if treatment == 0 & e(sample)
  di "Number of control M&A firms used: `r(ndistinct)'" //for text and table notes

  
qui eststo etrj: reghdfe ratio_taxes_ebt event_? event_tr_?, ///
	absorb(firmid2 fixed_effects_ctryr fixed_effects_indyr) vce(cluster firmid2)


*Output Stata
estout etr? etr_x1, ///
keep (event_tr_?) stats(N  r2_a , fmt(%9.0fc %9.3f ) labels("Observations" "adj. R2" )) ///
c(b(fmt(2) star) t(par fmt(%9.2f))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,) label

 




*** 4.4. Mechanisms of Tax Efficiency
use "$merged/analysis_treatedcontrols_${version}.dta", clear

//Cross-Sectional Regressions based on Indicators
loc i = 0
foreach var in $vars_crosss {
 	
	loc i = `i' + 1
	
	*Restrict regressions to sample with control variables
	qui reghdfe ratio_taxes_ebt after# `var' after_tr# `var' `var'#c.($vars_control), absorb(firmid year#`var') vce(cluster firmid)
	qui g sample_controls = 1  if e(sample)
	
	*Generate interaction variables
	qui g after_int = after * `var'
	qui g after_tr_int = after * treatment * `var'
	
	*Run regressions
	qui eststo etr_int`i'a: reghdfe ratio_taxes_ebt after after_tr if `var' == 0 & sample_controls == 1, absorb(firmid year) vce(cluster firmid)
	qui eststo etr_int`i'b: reghdfe ratio_taxes_ebt after after_tr if `var' == 1 & sample_controls == 1, absorb(firmid year) vce(cluster firmid)
	qui eststo etr_int`i'c: reghdfe ratio_taxes_ebt after after_tr after_int after_tr_int if sample_controls == 1, absorb(firmid `var'#year) vce(cluster firmid)	
	
	drop after_int after_tr_int sample_controls
}


*Output Stata
forvalues i = 1/6 {
	estout etr_int`i'*, ///
	keep(after after_int after_tr after_tr_int) stats(r2_a N, fmt(%9.3f %9.0fc) labels("adj. R2" "Observations")) ///
	c(b(fmt(%9.2f) star) t(par fmt(%9.2f))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,) label
}

 
 
 

*Directory Macros
glo dir = c(pwd)
glo orig = "$dir/Data_Original"
glo form = "$dir/Data_Formatted"
glo final = "$dir/Data_Final"

*Other Macros
set more off, permanently






*** 1. Generate Total Revenues and Spending Datasets ***
*** 1.1. Generate Tax Revenue Dataset
// 1.1.1. Prepare Tax Revenue Datasets (2008 - 2015)
foreach year in 2008 2009 2010 2011 2012 2013 2014 2015 {
import excel using "$orig/Steuern `year'.xlsx", clear
qui compress
gen year = `year'

rename A municipal_id
rename B municipal
rename C tax_prop_a_revenue
rename D tax_prop_b_revenue
rename E tax_business_revenue
rename H tax_business_revenue_base
rename I rate_prop_a
rename J rate_prop_b
rename K rate_business
rename L tax_income_share
rename M tax_sales_share
rename N tax_business_revenue_transfers
rename O tax_business_revenue_net

drop F G 
drop if municipal == ""
replace municipal = subinstr(municipal, " ", "", .)
destring tax* rate*, replace force

*Adjust municipal IDs
replace municipal_id = municipal_id + "000000" if municipal_id == "02" | municipal_id == "11" | municipal_id == "04" // Berlin / Hamburg / Bremen
replace municipal_id = municipal_id + "000" if strpos(municipal, "Kreisfrei") > 0 

replace municipal_id = municipal_id + "000" if strpos(municipal, "krsfr.") > 0

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 9, 3) ///
if length(municipal_id) == 11 & substr(municipal_id, 1, 2) == "03"

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 8, 3) ///
if length(municipal_id) == 10 & substr(municipal_id, 1, 2) == "07"

drop if length(municipal_id) == 2
drop if length(municipal_id) == 3
drop if length(municipal_id) == 7
drop if strpos(municipal, "kreis") > 0 & length(municipal_id) != 8 & strpos(municipal, "Stadtkreis") == 0
drop if strpos(municipal, "Kreis") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Verbandsgem.") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Berlin") > 0 & length(municipal_id) != 8

replace municipal_id = municipal_id + "000" if length(municipal_id) == 5

*Save dataset
qui compress
save "$form/Steuern `year'", replace
}


// 1.1.2. Prepare Tax Revenue Datasets (2016 - 2019)
foreach year in 2016 2017 2018 2019 {
import excel using "$orig/Steuern `year'.xlsx", clear
qui compress
gen year = `year'

rename A municipal_id
rename B municipal
rename C tax_prop_a_revenue
rename D tax_prop_b_revenue
rename E tax_business_revenue
rename H tax_business_revenue_base
rename I rate_prop_a
rename J rate_prop_b
rename K rate_business

rename O tax_income_share
rename P tax_sales_share
rename M tax_business_revenue_transfers
rename N tax_business_revenue_net

drop F G L Q
drop if municipal == ""
replace municipal = subinstr(municipal, " ", "", .)
destring tax* rate*, replace force

*Adjust values to EUR th
foreach var of varlist tax* {
    replace `var' = `var' / 1000
} 

*Adjust municipal IDs
replace municipal_id = municipal_id + "000000" if municipal_id == "02" | municipal_id == "11" | municipal_id == "04" // Berlin / Hamburg / Bremen
replace municipal_id = municipal_id + "000" if strpos(municipal, "Kreisfrei") > 0 

replace municipal_id = municipal_id + "000" if strpos(municipal, "krsfr.") > 0

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 9, 3) ///
if length(municipal_id) == 11 & substr(municipal_id, 1, 2) == "03"

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 8, 3) ///
if length(municipal_id) == 10 & substr(municipal_id, 1, 2) == "07"

drop if length(municipal_id) == 2
drop if length(municipal_id) == 3
drop if length(municipal_id) == 7
drop if strpos(municipal, "kreis") > 0 & length(municipal_id) != 8 & strpos(municipal, "Stadtkreis") == 0
drop if strpos(municipal, "Kreis") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Verbandsgem.") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Berlin") > 0 & length(municipal_id) != 8

replace municipal_id = municipal_id + "000" if length(municipal_id) == 5

*drop if tax_business_revenue == .
compress
save "$form/Steuern `year'", replace
}


// 1.1.3. Merge Datasets
clear
foreach year in 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	append using "$form/Steuern `year'"
}

qui gen county_id = substr(municipal_id,1,5)
qui gen state_id = substr(municipal_id,1,2)

sort municipal_id year
qui compress
save "$form/Steuern_form.dta", replace




*** 1.2. Generate Revenues Dataset
// 1.2.1. Prepare Annual Data
foreach year in 2008 2009 2010 2011 2012 2013 2014 {
import excel using "$orig/Bruttoeinnahmen `year'.xlsx", clear
qui compress
gen year = `year'

rename A municipal_id
rename B municipal

rename C revenues_total
rename D revenues_admin
rename E revenues_taxes
rename F revenues_transfers
rename G revenues_fees

rename H revenues_financial
rename I revenues_contributions
rename J revenues_subsidies
rename K revenues_credit

drop if municipal == ""
replace municipal = subinstr(municipal, " ", "", .)
destring revenues*, replace force

*Adjust municipal IDs
replace municipal_id = municipal_id + "000000" if municipal_id == "02" | municipal_id == "11" | municipal_id == "04" // Berlin / Hamburg / Bremen
replace municipal_id = municipal_id + "000" if strpos(municipal, "Kreisfrei") > 0 

replace municipal_id = municipal_id + "000" if strpos(municipal, "krsfr.") > 0

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 9, 3) ///
if length(municipal_id) == 11 & substr(municipal_id, 1, 2) == "03"

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 8, 3) ///
if length(municipal_id) == 10 & substr(municipal_id, 1, 2) == "07"

drop if length(municipal_id) == 2
drop if length(municipal_id) == 3
drop if length(municipal_id) == 7
drop if strpos(municipal, "kreis") > 0 & length(municipal_id) != 8 & strpos(municipal, "Stadtkreis") == 0
drop if strpos(municipal, "Kreis") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Verbandsgem.") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Berlin") > 0 & length(municipal_id) != 8

replace municipal_id = municipal_id + "000" if length(municipal_id) == 5

*Save dataset
qui compress
save "$form/Bruttoeinnahmen `year'", replace
}


// 1.2.2. Merge Datasets
clear
foreach year in 2008 2009 2010 2011 2012 2013 2014 {
	append using "$form/Bruttoeinnahmen `year'"
}

qui gen county_id = substr(municipal_id,1,5)
qui gen state_id = substr(municipal_id,1,2)

sort municipal_id year
qui compress
save "$form/Bruttoeinnahmen_form.dta", replace




*** 1.3. Generate Spendings Dataset
// 1.3.1. Prepare Annual Data
foreach year in 2008 2009 2010 2011 2012 2013 2014 {
import excel using "$orig/Bruttoausgaben `year'.xlsx", clear
qui compress
gen year = `year'
asdf
rename A municipal_id

rename B municipal

rename C spendings_total
rename D spendings_admin
rename E spendings_personal
rename F spendings_operating

rename G spendings_financial
rename H spendings_credit
rename I spendings_investment
rename J spendings_net

drop if municipal == ""
replace municipal = subinstr(municipal, " ", "", .)
destring spendings*, replace force

*Adjust municipal IDs
replace municipal_id = municipal_id + "000000" if municipal_id == "02" | municipal_id == "11" | municipal_id == "04" // Berlin / Hamburg / Bremen
replace municipal_id = municipal_id + "000" if strpos(municipal, "Kreisfrei") > 0 

replace municipal_id = municipal_id + "000" if strpos(municipal, "krsfr.") > 0

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 9, 3) ///
if length(municipal_id) == 11 & substr(municipal_id, 1, 2) == "03"

replace municipal_id = substr(municipal_id, 1, 5) + substr(municipal_id, 8, 3) ///
if length(municipal_id) == 10 & substr(municipal_id, 1, 2) == "07"

drop if length(municipal_id) == 2
drop if length(municipal_id) == 3
drop if length(municipal_id) == 7
drop if strpos(municipal, "kreis") > 0 & length(municipal_id) != 8 & strpos(municipal, "Stadtkreis") == 0
drop if strpos(municipal, "Kreis") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Verbandsgem.") > 0 & length(municipal_id) != 8
drop if strpos(municipal, "Berlin") > 0 & length(municipal_id) != 8

replace municipal_id = municipal_id + "000" if length(municipal_id) == 5

*Save dataset
qui compress
save "$form/Bruttoausgaben `year'", replace
}


// 1.3.2. Merge Datasets
clear
foreach year in 2008 2009 2010 2011 2012 2013 2014 {
	append using "$form/Bruttoausgaben `year'"
}

qui gen county_id = substr(municipal_id,1,5)
qui gen state_id = substr(municipal_id,1,2)

sort municipal_id year
qui compress
save "$form/Bruttoausgaben_form.dta", replace





*** 2. Generate Postcode and County Dataset ***
// 2.1. Prepare Postcode Dataset
import excel "$orig/31122010_Auszug_GV.xlsx", sheet("Gemeindedaten") clear
keep C D E F G H I J N

gen year = 2010
gen municipal_id = C + D + E + G
drop C D E F G
rename H municipal
rename N postcode
rename I area
rename J population

drop if postcode == ""
drop if municipal == "Gemeindename"
replace municipal = subinstr(municipal, " ", "", .)
destring postcode area population, replace

compress
save "$form/Postcodes_2010.dta", replace


// 2.2. Prepare County Dataset
import excel "$orig/31122010_Auszug_GV.xlsx", sheet("Gemeindedaten") clear
keep C D E F G H J N

drop if length(F) > 0
gen county_id = C + D + E + G
drop C D E F G J N
rename H county

keep if length(county_id) == 5
compress

save "$form/Counties_2010.dta", replace




*** 3. Generate GDP Dataset ***
// 3.1. Prepare GDP Dataset 
import excel "$orig/GDP 2000-2018.xlsx", clear
rename A municipal_id
rename B municipal
rename C gdp_total 
label var gdp_total "Local GDP (th EUR)"
rename D gdp_worker
rename E gdp_capita 
drop F - M

drop if municipal_id=="" & municipal==""
gen year=.
forval yr = 2000/2017 {
replace year=`yr' if municipal_id=="`yr'" & municipal==""
}
tab year
replace year = year[_n-1] if year==.

drop if municipal_id== ""
drop if municipal == ""
replace municipal = subinstr(municipal, " ", "", .)
destring gdp*, replace force

gen population = (gdp_total/gdp_capita) * 1000
gen workers = (gdp_total/gdp_worker ) * 1000

*Adjust municipal IDs
replace municipal_id = municipal_id + "000" if municipal_id == "02" | municipal_id == "11" | municipal_id == "04" // Berlin / Hamburg / Bremen
	//to make them countires, only add "000"
drop if length(municipal_id) == 2
drop if length(municipal_id) == 3
drop if length(municipal_id) >5  //all was manually checked 


rename municipal_id county_id 
tab county_id
rename municipal county

duplicates tag county_id year, gen (dup)
drop if dup>0 & gdp_total==.
drop dup
codebook county
duplicates list county_id year
duplicates tag county year, gen (dup)
drop if dup>0 & gdp_total==.
drop dup 
codebook county_id

*Generate Lags 
qui egen id=group(county)
xtset id year

replace year = year+1 
foreach stub in gdp_total gdp_worker gdp_capita population workers {
rename `stub' `stub'_lag1
}
tab year

xtset id year
foreach stub in gdp_total gdp_worker gdp_capita population workers {
gen  `stub' = f.`stub'_lag1
}
tab year if gdp_total!=. // ok, 2000 missing 

foreach stub in gdp_total gdp_worker gdp_capita population workers {
gen  `stub'_lag2 = l2.`stub'
gen  `stub'_lag3 = l3.`stub'
gen  `stub'_lag4 = l4.`stub'
gen  `stub'_lag5 = l5.`stub'

}

drop id
tab year if workers_lag5!=.
tab year if workers!=.
sum workers population, d

*Save
order county* year gdp_total gdp_worker gdp_capita population workers
compress
save "$form/GDP_form.dta", replace




*** 4. Merge Datasets ***
// 4.1. Generate Overall Dataset
*Merge public finance datasets
use "$form/Steuern_form.dta", clear

merge 1:1 municipal_id year using "$form/Bruttoeinnahmen_form.dta", ///
	keep(master matched) nogen

merge 1:1 municipal_id year using "$form/Bruttoausgaben_form.dta", ///
	keep(master matched) nogen

*Merge general information datasets
merge m:1 municipal_id using "$form/Postcodes_2010.dta", ///
	keep(master matched) nogen

merge m:1 county_id using "$form/Counties_2010.dta", ///
	keep(master matched) nogen

*Merge gdp dataset
merge m:1 county_id year using "$form/GDP_form.dta", ///
	keep(master matched) nogen

*Adjust municipal names
replace municipal = lower(municipal)
replace municipal = substr(municipal, 1, strpos(municipal, ",")) if strpos(municipal, ",") > 0
replace municipal = subinstr(municipal, " ", "",.)
replace municipal = subinstr(municipal, " ", "", .)
replace municipal = subinstr(municipal, ",", "", .)
replace municipal = subinstr(municipal, ".", "", .)
replace municipal = subinstr(municipal, "(", "", .)
replace municipal = subinstr(municipal, ")", "", .)
replace municipal = subinstr(municipal, "/", "", .)
replace municipal = subinstr(municipal, "-", "", .)
replace municipal = subinstr(municipal, "ö", "oe",.)
replace municipal = subinstr(municipal, "ä", "ae",.)
replace municipal = subinstr(municipal, "ü", "ue",.)
replace municipal = subinstr(municipal, "Ö", "oe",.)
replace municipal = subinstr(municipal, "Ä", "ae",.)
replace municipal = subinstr(municipal, "Ü", "ue",.)
replace municipal = subinstr(municipal, "ß", "ss",.)

*Adjust county names
replace county = "schwerin" if county == "Kreisfreie Stadt Schwerin, Landeshauptstadt"
replace county = "rostock" if county == "Kreisfreie Stadt Rostock, Hansestadt"
replace county = "dillingen" if county == "Dillingen a.d.Donau, Landkreis"
replace county = "frankenthal" if county == "Frankenthal (Pfalz), kreisfreie Stadt"
replace county = "lahndill" if county == "Lahn-Dill-Kreis"
replace county = "landkreisansbach" if county == "Ansbach, Landkreis"
replace county = "landkreisaschaffenburg" if county == "Aschaffenburg, Landkreis"
replace county = "landkreisaugsburg" if county == "Augsburg, Landkreis"
replace county = "landkreisbamberg" if county == "Bamberg, Landkreis"
replace county = "landkreisbayreuth" if county == "Bayreuth, Landkreis"
replace county = "landkreiscoburg" if county == "Coburg, Landkreis"
replace county = "landkreisfuerth" if county == "Fürth, Landkreis"
replace county = "landkreisguerlitz" if county == "Görlitz, Landkreis"
replace county = "landkreisheilbronn" if county == "Heilbronn, Landkreis"
replace county = "landkreishof" if county == "Hof, Landkreis"
replace county = "landkreiskaiserslautern" if county == "Kaiserslautern, Landkreis"
replace county = "landkreiskarlsruhe" if county == "Karlsruhe, Landkreis"
replace county = "landkreiskassel" if county == "Kassel, Landkreis"
replace county = "landkreislandshut" if county == "Landshut, Landkreis"
replace county = "landkreisleipzig" if county == "Leipzig, Landkreis"
replace county = "landkreismuenchen" if county == "München, Landkreis"
replace county = "landkreisoffenbach" if county == "Offenbach, Landkreis"
replace county = "landkreisoldenburg" if county == "Oldenburg, Landkreis"
replace county = "landkreisosnabrueck" if county == "Osnabrück, Landkreis"
replace county = "landkreispassau" if county == "Passau, Landkreis"
replace county = "landkreisregensburg" if county == "Regensburg, Landkreis"
replace county = "landkreisrosenheim" if county == "Rosenheim, Landkreis"
replace county = "landkreisschweinfurt" if county == "Schweinfurt, Landkreis"
replace county = "landkreiswuerzburg" if county == "Würzburg, Landkreis"
replace county = "landsberg" if county == "Landsberg am Lech, Landkreis"
replace county = "neckarodenwald" if county == "Neckar-Odenwald-Kreis, Landkreis"
replace county = "nordwestmecklenburg" if county == "Landkreis Nordwestmecklenburg"
replace county = "oldenburg" if county == "Oldenburg (Oldenburg), kreisfreie Stadt"
replace county = "postdam" if county == "Potsdam, kreisfreie Stadt" 				// Sic in Firm-Data
replace county = "postdammittelmark" if county == "Potsdam-Mittelmark, Landkreis" 	// Sic in Firm-Data
replace county = "saaleorla" if county == "Saale-Orla-Kreis"
replace county = "saarpfalz" if county == "Saarpfalz-Kreis"
replace county = "shwaebischhall" if county == "Schwäbisch Hall, Landkreis" 		// Sic in Firm-Data

replace county = lower(county)
replace county = substr(county, 1, strpos(county, ",")) if strpos(county, ",") > 0
replace county = subinstr(county, " ", "", .)
replace county = subinstr(county, ",", "", .)
replace county = subinstr(county, ".", "", .)
replace county = subinstr(county, "(", "", .)
replace county = subinstr(county, ")", "", .)
replace county = subinstr(county, "/", "", .)
replace county = subinstr(county, "-", "", .)
replace county = subinstr(county, "ö", "oe", .)
replace county = subinstr(county, "ü", "ue", .)
replace county = subinstr(county, "ä", "ae", .)
replace county = subinstr(county, "Ö", "oe",.)
replace county = subinstr(county, "Ä", "ae",.)
replace county = subinstr(county, "Ü", "ue",.)
replace county = subinstr(county, "ß", "ss", .)
	
save "$final/Gemeindedaten.dta", replace


// 4.2. Generate Merge Datasets
*County
use "$final/Gemeindedaten.dta", clear
duplicates drop municipal county year, force
save "$final/Gemeindedaten_county.dta", replace

*Postcodes
use "$final/Gemeindedaten.dta", clear
duplicates drop municipal postcode year, force
save "$final/Gemeindedaten_postcode.dta", replace

*Municipal
use "$final/Gemeindedaten.dta", clear
duplicates tag municipal year, g(dup)
drop if dup > 0
drop dup
save "$final/Gemeindedaten_municipal.dta", replace


 




*Directory macros 
*Directory macros 
/*to be set by user
glo dir = c(pwd)
glo buyouts = "..."
*/


*Color scheme
set scheme s2color

*Set control and leverage variable
glo controls = "assets_total_log ratio_ebit_assets ratio_leverage ratio_assets_intan   ratio_cash"
glo controls_macro = "gdp_total_lag1 population_lag1 workers_lag1"



*** 1. Prepare Dataset ***
*** 1.1. Prepare Aggregate German Municipal Data
// 1.1.1. Select Observations
use "$financials/orbis_DE.dta", clear

g ratio_assets_intan = assets_fixed_intan / assets_total


drop if municipal == ""
drop if year > 2018 | year < 2008 //| year < 2008 //2000


// 1.1.2. Adjust Matching Variables
*Adjust municipal names
replace municipal = lower(municipal)
replace municipal = substr(municipal, 1, strpos(municipal, ",")) if strpos(municipal, ",") > 0
replace municipal = subinstr(municipal, " ", "", .)
replace municipal = subinstr(municipal, ",", "", .)
replace municipal = subinstr(municipal, ".", "", .)
replace municipal = subinstr(municipal, "(", "", .)
replace municipal = subinstr(municipal, ")", "", .)
replace municipal = subinstr(municipal, "/", "", .)
replace municipal = subinstr(municipal, "-", "", .)

*Adjust county names
rename county county_old		// To be reconsidered
egen county = mode(county_old), by(municipal) minmode
replace county = substr(county, strpos(county, "|")+1, .) if strpos(county, "|") > 0
replace county = substr(county, strpos(county, "|")+1, .) if strpos(county, "|") > 0
replace county = substr(county, 1, strpos(county, ",")) if strpos(county, ",") > 0
replace county = lower(county)
replace county = subinstr(county, " ", "", .)
replace county = subinstr(county, ",", "", .)
replace county = subinstr(county, ".", "", .)
replace county = subinstr(county, "(", "", .)
replace county = subinstr(county, ")", "", .)
replace county = subinstr(county, "/", "", .)
replace county = subinstr(county, "-", "", .)

*Adjust postcodes
destring postcode, replace force
rename postcode postcode_old
egen postcode = mode(postcode_old), by(municipal) minmode


// 1.1.3. Merge Buyout Data 
*Merge m&a buyout data
merge 1:1 bvd year using "$buyouts/zephyr_manda.dta", ///
	keep(master matched) nogen keepusing(deal_value deal_manda)
rename deal_value deal_value_manda
rename deal_manda targets_manda
	
*Merge private equity buyout data
merge 1:1 bvd year using "$buyouts/zephyr_privateequity.dta", ///
	keep(master matched) nogen keepusing(deal_value obs_total)
g targets = (obs_total != .)


// 1.1.4 Collapse Data at Local Level
*Prepare some additional variable
g ind_manu=inlist(industry_nace1, "C", "F")
g ind_trade=inlist(industry_nace1, "G")
g ind_service=inlist(industry_nace1, "H", "I", "K", "L", "M", "N", "Q", "S")
g ind_info=inlist(industry_nace1, "J")
g ind_util=inlist(industry_nace1, "A", "B", "D", "E")
g ind_other=(ind_manu == 0 & ind_trade == 0 & ind_service == 0 & ind_manu == 0 & ind_info == 0)

g firms = 1
g deal_assets_total = assets_total if targets == 1
g deal_assets_total_manda = assets_total if targets_manda == 1

foreach ind of varlist ind_* {
	g `ind'_firms = 1 if `ind' ==1
	g `ind'_assets_total = assets_total if `ind' == 1 //Coarse industry composition controls: https://ec.europa.eu/eurostat/documents/3859598/5902521/KS-RA-07-015-EN.PDF
	drop  `ind'
}

*Collapse data
collapse (sum) firms* targets* assets_total deal_assets_total* deal_value* ind_* (mean) $controls, by(county postcode municipal year)


// 1.1.5. Merge Municipal Data
*Merge county-municipal data
merge m:1 county municipal year using "$municipals/Gemeindedaten_county.dta", ///
	keep(master matched) nogen ///
	keepusing(state_id population area rate_business tax_* revenues* spendings* gdp_* population_* workers_*)

*Merge postcode-municipal data
merge m:1 postcode municipal year using "$municipals/Gemeindedaten_postcode.dta", ///
	update keep(master match match_update match_conflict) nogen ///
	keepusing(state_id population area rate_business tax_* revenues* spendings* gdp_* population_* workers_*)

*Merge municipal-only data
merge m:1 municipal year using "$municipals/Gemeindedaten_municipal.dta", ///
	update keep(master match match_update match_conflict) nogen ///
	keepusing(state_id population area rate_business tax_* revenues* spendings* gdp_* population_* workers_*)

	
// 1.1.6. Compress and Save Dataset
compress
save "$merged/municipals_form.dta", replace




*** 1.2. Prepare Variables
// 1.2.1. Set Panel Data
eststo clear
use "$merged/municipals_form.dta", clear

egen municipal_id = group(county municipal)
drop if municipal_id == .
xtset municipal_id year


// 1.2.3. Define Treatment Variables
*Define treatments
g treatment = (targets > 0)
label var treatment "Treated PE"
g treatment_intense1 = (targets > 0 & deal_assets_total > 100000000)
label var treatment_intense1 "Treated PE Intense"
g treatment_intense2 = (targets > 0 & deal_assets_total > 500000000)
label var treatment_intense2 "Treated PE Very Intense"

g treatment_manda = (targets_manda > 0)
label var treatment_manda "Treated M&A"
g treatment_manda_intense1 = (targets_manda > 0 & deal_assets_total_manda > 100000000)
label var treatment_manda_intense1 "Treated M&A Intense"
g treatment_manda_intense2 = (targets_manda > 0 & deal_assets_total_manda > 500000000)
label var treatment_manda_intense2 "Treated M&A Very Intense"

g treatment_int = treatment * treatment_manda
label var treatment_int "Treated PE * Treated M&A"
g treatment_int_intense1 = treatment_intense1 * treatment_manda_intense1
label var treatment_int "Treated PE * Treated M&A"
g treatment_int_intense2 = treatment_intense2 * treatment_manda_intense2
label var treatment_int "Treated PE * Treated M&A"

*Generate treatment dummies
g year_tr = year if treatment == 1
egen year_event = min(year_tr), by(municipal_id)

replace treatment = 1 if treatment[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_intense1 = 1 if treatment_intense1[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_intense2 = 1 if treatment_intense2[_n-1] == 1 & municipal_id == municipal_id[_n-1]

replace treatment_manda = 1 if treatment_manda[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_manda_intense1 = 1 if treatment_manda_intense1[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_manda_intense2 = 1 if treatment_manda_intense2[_n-1] == 1 & municipal_id == municipal_id[_n-1]


**** Keep relevant sample period for which dependent variable is available ****
gen first_treat = year_event 
replace first_treat = 0 if first_treat ==.
drop if year < 2008
tab year_event 


// 1.2.4. Generate Other Variables
*Generate dependent variable
g revenue_business_log = ln(1+tax_business_revenue) * 100
label var revenue_business_log "Log. Business Tax Revenue"
g revenue_property_log = ln(1+tax_prop_b_revenue) * 100
label var revenue_property_log "Log. Property Tax Revenue"

g revenue_income_log = ln(1+tax_income_share) * 100
label var revenue_income_log "Log. Income Tax Transfer"
g revenue_sales_log = ln(1+tax_sales_share) * 100
label var revenue_sales_log "Log. Sales Tax Transfer"

*Generate control variables
foreach var of varlist $controls {
	qui sum `var'
	replace `var' = `r(mean)' if `var' == .
}

foreach var of varlist gdp_total_* population_* workers_*  {
	replace `var' = ln(1+`var')
}

foreach var of varlist ind_*firms ind_*assets_total {
	gen `var'_log = ln(1+`var')
}

foreach var of varlist ind_manu_firms ind_trade_firms ind_service_firms {
	qui gen `var'_ratio = `var' / firms
}
qui gen ind_other_firms_ratio = 1 - ind_manu_firms_ratio - ind_trade_firms_ratio -  ind_service_firms_ratio
 replace ind_other_firms_ratio = 0 if ind_other_firms_ratio < 0
 
foreach var of varlist ind_*_ratio {
	qui replace 	`var' = `var' * 100
}

label var ind_manu_firms_ratio  "Manufacturing Firms Share"
label var ind_trade_firms_ratio "Trade Firms Share"
label var ind_service_firms_ratio "Service Firms Share"
label var ind_other_firms_ratio "Other Firms Share"

label var gdp_total_lag1 "Log. GDP (t-1)"
label var population_lag1 "Log. Population (t-1)"
label var workers_lag1 "Log. Workforce (t-1)"

*Total aggregates
gen firms_log=ln(firms)
gen assets_total_sum_log=ln(assets_total)

*Generate fixed effects
egen state_id_year = group(state_id year)
 

*Save dataset
compress
save "$merged/analysis_municipals.dta", replace





*** 3. Analysis ****
eststo clear
use "$merged/analysis_municipals.dta", clear

tab treatment treatment_manda // treatment_int 

glo controls = "assets_total_log ratio_ebit_assets ratio_leverage ratio_assets_intan ratio_cash"
glo controls_macro = "gdp_total_lag1 population_lag1 workers_lag1"
glo controls_all = "$controls_macro $controls ind_manu_firms_ratio ind_trade_firms_ratio ind_service_firms_ratio ind_other_firms_ratio" //ind_*firms_log


// 3.1. Log Tax Revenue Analysis
*Regressions
//Business Tax Revenue
eststo taxes1a: reghdfe revenue_business_log treatment, absorb(municipal_id state_id_year) vce(cluster municipal_id)
qui gen sample_municipal=1 if e(sample) //main sample 
tab year

qui eststo taxes1b: reghdfe revenue_business_log treatment treatment_manda treatment_int , absorb(municipal_id state_id_year) vce(cluster municipal_id)
qui eststo taxes1c: reghdfe  revenue_business_log treatment treatment_manda treatment_int $controls_all , absorb(municipal_id state_id_year) vce(cluster municipal_id)

//Income tax Transfer
qui eststo taxes1e: reghdfe revenue_income_log treatment, absorb(municipal_id state_id_year) vce(cluster municipal_id)
qui eststo taxes1f: reghdfe revenue_income_log treatment treatment_manda treatment_int, absorb(municipal_id state_id_year) vce(cluster municipal_id)
qui eststo taxes1g:  reghdfe revenue_income_log treatment treatment_manda treatment_int $controls_all , absorb(municipal_id state_id_year) vce(cluster municipal_id)



*Output Stata
estout taxes1?, ///
keep (treatment* gdp_total_* population_* workers_* $controls_all) order(treatment* gdp_total_* population_* workers_*) stats(N r2_a, fmt(%9.0f %9.4f) labels("Observations" "adj. R2")) ///
c(b(fmt(%9.2f) star) t(par fmt(%9.2f))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) label

 
 


*Define directory macros
*Directory macros 
/*to be set by user
glo dir = c(pwd)
glo buyouts = "..."
*/


*Define other macros
glo countries = "AT BE BG CH CY CZ DE DK EE ES FI FR GB GR HR HU IE IS IT LI LT LU LV MT NL NO PL PT RO SE SI SK"

glo variables = "bvd country county municipal postcode year account_ifrs account_consolidated industry_nace* date_incorp assets_fixed assets_fixed_intan assets_fixed_tan assets_fixed_oth assets_current assets_cash assets_total liab_noncurrent liab_current liab_equity_total number_employees revenue sales profit_ebt profit_ebit profit_netincome exp_tax exp_employees exp_depreciation exp_rd cash_flow"

*Color scheme
set scheme s2color

*Set Matching variables 
glo exactmatch = "year country industry_nace1 dummy_ebt_pos dummy_tax_pos dummy_bg dummy_bg_foreign"

glo bestmatch = "ratio_taxes_ebt ratio_leverage assets_total profit_ebt ratio_ebit_assets growth_assets_2 growth_assets_fixed_2 growth_roa_2 growth_revenue_2" //  vFinal

glo event_start = -3
glo event_finish = 3

glo version = "vFinal"

set seed 42

*Define scalars for sample table
sca obs_all = 0
sca obs_dup = 0
sca obs_lim = 0
sca obs_neg = 0
sca obs_tr = 0
sca obs_match = 0






*** 1. Prepare Country Financials Data ***
// 1.1. Clean Country Data
foreach country in $countries {
	
	di ""
	di "*** Country Data `country' ***"
	
	*Import data
	qui import delimited using "$orig/orbis_eur_`country'.txt", clear
	sort bvd year
	
	*Rename variables
	rename bvdid bvd
	rename country_alpha2 country
	
	*Select variables
	keep $variables
	order $variables
	
	*Merge ownership data
	qui merge m:1 bvd year using "$orig/orbis_ownership_`country'.dta", ///
		keep(master matched) keepusing(group_firms group_international) nogen
	qui g dummy_bg = (group_firms != .)
	qui g dummy_bg_foreign = (group_international == 1)
	drop group*
	
	di "Number of firms: "_N
	qui sum if dummy_bg == 1
	di " - Business group firms: "`r(N)'
	qui sum if dummy_bg_foreign == 1
	di " - Int. business group firms: "`r(N)'
	
	
// 1.2. Select Observations (First Round)
	*1. EEA from 2000 until 2020
	qui drop if year < 1997 | year > 2020	// 1997 to compute growth variables
	qui sum year if year >= 2000
	sca obs_all = obs_all + `r(N)'
	di "(1) All orbis financials data between 2000 and 2020 in the EEA: "`r(N)'

	*2. Remove duplicates while keeping consolidated data
	qui duplicates tag bvd year, g(dup1)
	qui drop if dup1 > 0 & account_consolidated == 0
	qui duplicates tag bvd year, g(dup2)
	qui drop if dup2 > 0 & account_ifrs == 1
	qui duplicates drop bvd year, force
	drop dup*
	qui sum year if year >= 2000
	sca obs_dup = obs_dup + `r(N)'
	di "(2) Remove duplicates keeping consolidated local gaap statements whenever possible: "`r(N)'

	*3. Remove limited data
	qui drop if revenue == . & assets_total == . & number_employees == .
	qui sum year if year >= 2000
	sca obs_lim = obs_lim + `r(N)'
	di "(3) Remove observations with missing data for turnover, number of employees, and total assets: "`r(N)'

	*4. Remove false data
	qui g dummy = min(number_employees, assets_total, assets_fixed_tan, sales)
	qui egen dummy_bvd = min(dummy), by(bvd)
	qui drop if dummy_bvd < 0
	drop dummy dummy_bvd
	qui sum year if year >= 2000
	sca obs_neg = obs_neg + `r(N)'
	di "(4) Remove observations with negative values for sales, employees, assets, or tan. assets in any firm-year: "`r(N)'
	

// 1.3. Generate variables
	egen bvd_id = group(bvd)
	qui xtset bvd_id year
	sort bvd_id year

	*Dummy variables
	g dummy_ebt_pos = (profit_ebt >= 0)
	label var dummy_ebt_pos "Positive Earnings Dummy"

	g dummy_tax_pos = (exp_tax >= 0)
	label var dummy_tax_pos "Positive Taxes Dummy"

	*Age variable
	qui tostring date_incorp, replace
	qui g year_incorp = date_incorp if length(date_incorp) == 4
	qui replace year_incorp = substr(date_incorp, 1, 4) if length(date_incorp) > 4
	qui destring year_incorp, replace
	qui g age = year - year_incorp
	drop date_incorp year_incorp
	label var age "Firm Age"

	*Log variables
	qui g assets_total_log = ln(1 + assets_total)
	label var assets_total_log "Log. Total Assets"
	
	qui g assets_fixed_log = ln(1 + assets_fixed)
	label var assets_fixed_log "Log. Fixed Assets"
	
	qui g assets_fixed_tan_log = ln(1 + assets_fixed_tan)
	label var assets_fixed_tan_log "Log. Tangible Fixed Assets"
	
	qui g assets_fixed_intan_log = ln(1 + assets_fixed_intan)
	label var assets_fixed_intan_log "Log. Intangible Fixed Assets"
	
	qui g assets_fixed_oth_log = ln(1 + assets_fixed_oth)
	label var assets_fixed_oth_log "Log. Other Fixed Assets"

	qui g profit_ebt_log = ln(1 + profit_ebt)
	label var profit_ebt_log "Log. EBT"
	
	qui g costs_taxes_log = ln(1 + exp_tax)
	label var costs_taxes_log "Log. Tax Expenses"

	qui g number_employees_log = ln(1 + number_employees)
	label var number_employees_log "Log. Number Employees"
	
	qui g exp_employees_log = ln(1 + exp_employees)
	label var exp_employees_log "Log. Labor Expenses"

	*Ratios
	qui g ratio_taxes_ebt = exp_tax / profit_ebt
	label var ratio_taxes_ebt "ETR"

	qui g ratio_ebit_assets = profit_ebit / assets_total
	label var ratio_ebit_assets "EBIT over Assets (ROA)"
	qui g ratio_ebit_revenue = profit_ebit / revenue
	label var ratio_ebit_revenue "EBIT over Revenue (Profit Margin)"

	qui g ratio_cash = assets_cash / assets_total
	label var ratio_cash "Cash Ratio"

	qui g ratio_leverage = (liab_noncurrent + liab_current) / assets_total
	label var ratio_leverage "Leverage Ratio"

	qui g ratio_salary = exp_employees / number_employees
	label var ratio_salary "Average Salary"
	
	qui g ratio_salary_log = ln(1 + ratio_salary)
	label var ratio_salary_log "Log. Average Salaries"
	
	winsor2 ratio*, replace

	*Growth variables
	qui g growth_assets = ln(assets_total / l.assets_total)
	label var growth_assets "Log. Asset Growth"
	qui g growth_assets_2 = ln(assets_total / l2.assets_total)
	label var growth_assets_2 "Two-Period log. Asset Growth"
	
	qui g growth_assets_fixed = ln(assets_fixed / l.assets_fixed)
	label var growth_assets_fixed "Log. Fixed Asset Growth"
	qui g growth_assets_fixed_2 = ln(assets_fixed / l2.assets_fixed)
	label var growth_assets_fixed_2 "Two-Period log. Fixed Asset Growth"
	
	qui g growth_assets_fixed_tan = ln(assets_fixed_tan / l.assets_fixed_tan)
	label var growth_assets_fixed_tan "Log. Fixed Tangible Asset Growth"
	qui g growth_assets_fixed_tan_2 = ln(assets_fixed_tan / l2.assets_fixed_tan)
	label var growth_assets_fixed_tan_2 "Two-Period log. Fixed Tangible Asset Growth"
	
	qui g growth_roa = ratio_ebit_assets - l.ratio_ebit_assets
	label var growth_roa "ROA Improvement"
	qui g growth_roa_2 = ratio_ebit_assets - l2.ratio_ebit_assets
	label var growth_roa_2 "Two-Period ROA Improvement"
	
	qui g growth_employees = ln(number_employees / l.number_employees)
	label var growth_employees "Log. Employment Growth"
	qui g growth_employees_2 = ln(number_employees / l2.number_employees)
	label var growth_employees_2 "Two-Period log. Employment Growth"
	
	qui g growth_revenue = ln(revenue / l.revenue)
	label var growth_revenue "Log. Revenue Growth"
	qui g growth_revenue_2 = ln(revenue / l2.revenue)
	label var growth_revenue_2 "Two-Period log. Revenue Growth"
	
	qui g growth_ebt = (profit_ebt - l.profit_ebt) / abs(l.profit_ebt)
	label var growth_ebt "EBT Growth (%)"
	qui g growth_ebt_2 = (profit_ebt - l2.profit_ebt) / abs(l2.profit_ebt)
	label var growth_ebt_2 "Two-Period EBT Growth (%)"
	
	qui g growth_taxes = ln(costs_taxes / l.costs_taxes)
	label var growth_taxes "Log. Taxes Growth"
	qui g growth_taxes_2 = ln(costs_taxes / l2.costs_taxes)
	label var growth_taxes_2 "Two-Period log. Taxes Growth"
	
	qui g growth_laborcost = ln(exp_employees / l.exp_employees)
	label var growth_laborcost "Log. Labor Cost Growth"
	qui g growth_laborcost_2 = ln(exp_employees / l2.exp_employees)
	label var growth_laborcost_2 "Two-Period log. Labor Cost Growth"
	
	winsor2 growth*, replace
	
	*Capex variables
	qui g capex = (assets_fixed - l.assets_fixed) + exp_depreciation
	label var capex "Capital Expenditures in Fixed Assets"
	qui g capex_log = ln(1 + capex)
	label var capex_log "Log. Capital Expenditures in Fixed Assets"

	qui g capex_tan = (assets_fixed_tan - l.assets_fixed_tan) + exp_depreciation
	label var capex_tan "Capital Expenditures in Tangible Assets"
	qui g capex_tan_log = ln(1 + capex_tan)
	label var capex_tan_log "Log. Capital Expenditures in Tangible Assets"
	
	*Labor investment variables 
	qui g employees_add_log = ln(1 + (number_employees - l.number_employees))
	label var employees_add_log  "Log. New Employment"

	qui g laborexpenses_add_log = ln(1 + (exp_employees - l.exp_employees))
	label var laborexpenses_add_log  "Log. New Salaries"
 
	winsor2 capex*, replace


	// 1.4. Compress and Save Aggregate Data
	qui replace municipal = substr(municipal, 1, 64)
	drop assets_current liab_equity_total profit_ebit profit_netincome exp_rd cash_flow ///
	ratio_salary ratio_salary_log sales // Reduce dataset size
	qui compress
	save "$form/orbis_`country'.dta", replace
	
	
	// 1.5. Save German Dataset for Municipal Analysis
	if "`country'" == "DE" {
		 save "$final/orbis_`country'.dta", replace
	}

}


 



*** 2. Match Datasets ***
*** 2.1. Prepare Treated Dataset
// 2.1.1. Prepare Private Equity Dataset
use "$buyout/zephyr_privateequity.dta", clear

*Keep and generate relevant variables
keep deal_id bvd year
g target_zephyr = 1
replace year = year - 1

*Save dataset
order deal_id bvd year target_zephyr
save "$form/zephyr_privateequity_form.dta", replace


// 2.1.2. Merge Financials and Private Equity Datasets
clear
foreach country in $countries {
	di "*** Append Country `country' ***"
	qui append using "$form/orbis_`country'.dta", force   keep(bvd $exactmatch $bestmatch)
}

*Reduce dataset
foreach var in $exactmatch $bestmatch {
	cap keep if `var' != .
	cap keep if `var' != ""
}


*Select treated firms
qui merge 1:1 bvd year using "$form/zephyr_privateequity_form.dta", keep(match) nogen

*Save dataset
qui compress
save "$form/zephyr_treated.dta", replace




*** 2.2. Prepare Control Dataset
*Remove previous files
!rmdir "$form/matching_controls" /s /q
mkdir "$form/matching_controls"

foreach country in $countries {
	
	di ""
	di "*** Country Data `country' ***"
	use "$form/orbis_`country'.dta", clear

	*Keep relevant variables
	keep bvd $exactmatch $bestmatch

	*Remove treated firms
	qui merge 1:1 bvd year using "$form/zephyr_privateequity_form.dta", ///
		keep(master match) keepusing(target_zephyr) nogen
	qui egen dummy_treated = max(target_zephyr), by(bvd)
	qui drop if dummy_treated == 1
	drop dummy_treated
	
	qui sum year if year >= 2000
	sca obs_tr = obs_tr + `r(N)'
	
	*Reduce dataset
	foreach var in $exactmatch $bestmatch {
		cap keep if `var' != .
		cap keep if `var' != ""
	}
	qui sum year if year >= 2000
	sca obs_match = obs_match + `r(N)'
*continue
	*Save separate files
	  save "$form/orbis_controls_`country'.dta", replace
	qui sum year
	forvalues year = `r(min)' / `r(max)' {
		use "$form/orbis_controls_`country'.dta", clear
		qui keep if year == `year'
		di "`year' (" _N ")"
		qui save "$form/orbis_controls_`country'_`year'.dta", replace
		qui levelsof industry_nace1
		foreach industry in `r(levels)' {
			use "$form/orbis_controls_`country'_`year'.dta", clear
			qui keep if industry_nace1 == "`industry'"
			qui compress
			di "Save control file for `country' `industry' `year'"
			qui  save "$form/matching_controls/orbis_controls_`country'_`industry'_`year'.dta", replace
		}
		erase "$form/orbis_controls_`country'_`year'.dta"
	}
	erase "$form/orbis_controls_`country'.dta"
}




*** 2.3. Match Samples
*Load treated data
use "$form/zephyr_treated.dta", clear
glo obs_ind_total = _N

*Remove previous files
!rmdir "$form/matched_controls" /s /q
mkdir "$form/matched_controls"

*Start algorithm
forvalue n = 1 /  $obs_ind_total {

	*Prepare treated sample
	use "$form/zephyr_treated.dta", clear
	qui keep if _n == `n'

	di "Observation `n' of $obs_ind_total"
	
	drop bvd
	g treatment = 0
	
	*Generate treated match variables
	foreach var in $bestmatch {
		rename `var' tr_`var'
	}
	
	*Exact matching
	loc country = country[1]
	loc industry = industry_nace1[1]
	loc year = year[1]
	qui cap merge 1:m $exactmatch using "$form/matching_controls/orbis_controls_`country'_`industry'_`year'.dta", ///
		keep(match) keepusing(bvd $bestmatch) nogenerate nolabel
	if _rc != 0 continue
	
	*Compute SDs for matching variables
	foreach match in $bestmatch {
		qui sum `match'
		sca sd_`match' = r(sd)
	}
	
	*Sample restriction on ETR difference
	drop if abs(tr_ratio_taxes_ebt - ratio_taxes_ebt) > 0.1 // 20%, as 10% on both sides
 
	*Best matching
	qui g diff_total = 0
	foreach var in $bestmatch {
		
		*Generate Euclidean Distances
		qui g diff_`var' = abs(tr_`var' - `var') / sd_`var'
		qui replace diff_`var' = 0 if diff_`var' == .
		label var diff_`var' "Standardized difference for `var'"
		qui replace diff_total = diff_total + diff_`var'
	}
	label var diff_total "Euclidean distance for continuous variables"
	
	loc obs = _N
	qui g matches = `obs'
	*di " --- `obs' Valid Matches (`r(min)') ---"

	*Sort by nearest neighbor and save
	sort diff_total
	keep bvd deal_id diff* tr* treatment $exactmatch $bestmatch matches
	qui keep if _n == 1
	
	qui  save "$form/matched_controls/control_`n'.dta", replace
}

*Append and save
clear
forvalue n = 1 (1) $obs_ind_total {
	*di "Observation `n'"
	 cap qui append using "$form/matched_controls/control_`n'.dta"
		//cap as some have no observations 
}

sort deal_id
order deal_id bvd tr* $exactmatch $bestmatch diff* treatment matches
qui save "$form/zephyr_controls.dta", replace






*** 3. Generate Analysis Dataset ***
*** 3.1. Generate PE Treated-Control Dataset
// 3.1.1. Generate Treatment-Control Dataset
*Merge treatment and control datasets
use "$form/zephyr_treated.dta", clear
g treatment = 1
append using "$form/zephyr_controls.dta"

*Generate variables
egen firmid = group(deal_id bvd)
label var firmid "Unique Firm-Consol Identifier"

egen matched = count(deal_id), by(deal_id)
replace matched = matched - 1
label var matched "Matching Indicator"

egen matches_dup = mean(matches), by(deal_id)
replace matches = matches_dup
label var matches "Number of Control Firms in Cell"

egen diff_total_dup = mean(diff_total), by(deal_id)
replace diff_total = diff_total_dup
label var diff_total "Sum of Standardized Matching Differences"

g year_event = year + 1
label var year_event "Event Year"

*Put year to matching year
replace year = year + 1

*Compress, drop variables, order, sort, and save
compress
keep deal_id firmid bvd year_event treatment diff_total matched matches
order deal_id firmid bvd year_event treatment diff_total matched matches
sort deal_id treatment
save "$form/zephyr_treatedcontrols.dta", replace


// 3.1.2. Merge with Financials & Ownership Data
foreach country in $countries {
	use "$form/orbis_`country'.dta", clear
	joinby bvd using "$form/zephyr_treatedcontrols.dta" 
	
	qui merge m:1 bvd year using "$orig/orbis_ownership_`country'.dta", ///
		keep(master matched) keepusing(treelevel group_firms group_treelevel group_complex) nogen
	
	foreach var of varlist treelevel group_* {
		qui replace `var' = 1 if `var' ==.
	}

	qui save "$form/orbis_`country'_treatedcontrols.dta", replace

}

clear
foreach country in $countries {
	append using "$form/orbis_`country'_treatedcontrols.dta", force
}
qui save "$form/orbis_treatedcontrols.dta", replace

*Generate variables
g year_dummy = year - year_event
label var year_dummy "Year relative to Event"

*Compress, sort, order, and save dataset
compress
gsort deal_id bvd year
order deal_id firmid bvd year* treatment diff_total matched matches
save "$final/financials_treatedcontrols_${version}.dta", replace

use "$final/financials_treatedcontrols_${version}.dta", clear



*** 3.2. Generate M&A Control Dataset
// 3.2.1. Prepare M&A Treated Dataset
use "$buyout/zephyr_manda.dta", clear

*Keep and generate relevant variables
keep deal_id bvd year
g target_zephyr = 1
g year_event = year

*Save dataset
order deal_id bvd year target_zephyr
save "$form/zephyr_manda_form.dta", replace


// 3.2.2. Merge with Financials & Ownership Data
foreach country in $countries {
    di "*** Country Data `country' ***"
	use "$form/orbis_`country'.dta", clear
	joinby bvd using "$form/zephyr_manda_form.dta" 
	
	qui merge m:1 bvd year using "$orig/orbis_ownership_`country'.dta", ///
	keep(master matched) keepusing(treelevel group_firms group_treelevel group_complex ) nogen
	
	foreach var of varlist treelevel group_* {
		qui replace `var' = 1 if `var' ==.
	}
	
	qui save "$form/orbis_`country'_mandacontrols.dta", replace
}

*Append country deal datasets
clear
foreach country in $countries {
	qui append using "$form/orbis_`country'_mandacontrols.dta", force
}

*Remove treated firms
rename target_zephyr target_manda
qui merge m:1 bvd year using "$form/zephyr_privateequity_form.dta", ///
	keep(master match) keepusing(target_zephyr) nogen
qui egen dummy_treated = max(target_zephyr), by(bvd)
qui drop if dummy_treated == 1
drop dummy_treated


// 3.2.3. Prepare Control Dataset
*Merge macro variables
rename country countryiso
merge m:1 countryiso year using "$orig/oecd_countries.dta", ///
	keep(master matched) keepusing(gdp_capita gdp_total	interest_long interest_short tax_corporate_total) nogen
rename countryiso country

*Generate variables
g year_dummy = year - year_event
label var year_dummy "Year relative to Event"

egen firmid = group(deal_id bvd)
replace firmid = firmid + 1000000
label var firmid "Unique Firm-Consol Identifier"

g treatment = 0
label var treatment "Treatment Indicator"

sort deal_id firmid year
forvalues year = $event_start (1) $event_finish {
	loc dummy = `year' - $event_start
	qui g byte event_`dummy' = 1 if year_dummy == `year'
	qui replace event_`dummy' = 0 if year_dummy!= `year'
	label var event_`dummy' "Event (t=`year')"
	
	qui g byte event_tr_`dummy' = event_`dummy' * treatment
	label var event_tr_`dummy' "Event (t=`year') * Treated"
}
loc drop = -$event_start - 1
drop event_`drop' event_tr_`drop'

g after = 1 if year_dummy >= 0
replace after = 0 if after == .
g after_tr = after * treatment

*Select observations
drop if year_dummy > $event_finish | year_dummy < $event_start

save "$final/financials_treatedcontrols_manda_${version}.dta", replace



asdf
 
 
*Directory macros 
*Directory macros 
/*to be set by user
glo dir = c(pwd)
glo buyouts = "..."
*/


*Color scheme
set scheme s2color

graph set window fontface "Times New Roman"

*Set variables
glo countries = "AT BE BG CH CY CZ DE DK EE ES FI FR GB GR HR HU IE IS IT LI LT LU LV MT NL NO PL PT RO SE SI SK"
glo dep_vars = "assets_total assets_fixed assets_fixed_tan assets_fixed_intan assets_cash number_employees exp_employees revenue profit_ebt exp_tax   exp_depreciation " 
glo dep_ratios = "ratio_taxes_ebt"  
glo controls = "assets_total_log ratio_ebit_assets ratio_leverage ratio_assets_intan ratio_assets_tan ratio_cash"

glo all_variables = "bvd country county municipal year $dep_vars $dep_ratios industry_nace1"

 
global outcomes_mun = "mun_ratio_taxes_ebt excl_o_mun_ratio_taxes_ebt mun_capex_fixed excl_o_mun_capex_fixed mun_growth_empl excl_o_mun_growth_empl mun_salaries excl_o_mun_salaries " 


*** 1. Prepare Datasets ***
//check for missing countries
*** 1.1. Aggregate Firms to Municipal Level
timer clear 1
timer on 1
foreach country in $countries {
	
	use $all_variables using "W:\Analysis - PE and Taxes\Data_Financials\Data_Formatted/orbis_`country'.dta", clear
	
	qui distinct municipal
	di "*** `country' distinct municipals: `r(ndistinct)' ***"
	
	qui distinct county
	di "*** `country' distinct counties: `r(ndistinct)' ***"

	cap tostring county, force replace
	
	*Select observations
	di "*** Dropping missing municipals ***"
	keep if municipal != ""
	di "*** Dropping outside year range ***"
	keep if inrange(year, 2000, 2018)
	di "*** Dropping missing ebt, taxes, assets_total, // and negative employment & assets_fixed ***"
	keep if assets_total > 0 & assets_total!=.
	gen obs = 1
	egen firms_orbis_mun=sum(obs), by(municipal year) 
	drop obs 
	keep if profit_ebt != . //makes sure reporting is not the issue 
	keep if exp_tax != .
	*keep if !missing(number_employees) & !missing(exp_employees) & !missing(assets_fixed) //muted 03.10.22 (this effects treated mun shares below, so maybe need to rerun)
	keep if !missing(number_employees) & !missing(exp_employees) & !missing(assets_fixed_tan)
	drop if assets_fixed < 0 | number_employees < 0 | exp_employees < 0 //data errors 
	
	
	*Clean names
	qui replace municipal = lower(municipal)
	qui replace municipal = substr(municipal, 1, strpos(municipal, ",")) if strpos(municipal, ",") > 0
	qui replace municipal = subinstr(municipal, " ", "", .)
	qui replace municipal = subinstr(municipal, ",", "", .)
	qui replace municipal = subinstr(municipal, ".", "", .)
	qui replace municipal = subinstr(municipal, "(", "", .)
	qui replace municipal = subinstr(municipal, ")", "", .)
	qui replace municipal = subinstr(municipal, "/", "", .)
	qui replace municipal = subinstr(municipal, "-", "", .)
	
	qui keep if municipal != "" & municipal != " "

	
	*Merge buyout data
	qui merge 1:1 bvd year using "$buyouts/zephyr_privateequity.dta", ///
		keep(master matched) gen(match_pe) keepusing(bvd)
	gen obs = (match_pe==3)	
	rename obs targets_pe
	
	qui merge 1:1 bvd year using "$buyouts/zephyr_manda.dta", ///
	keep(master matched) gen(match_ma) keepusing( bvd)	 
	*rename deal_value deal_value_ma
	gen obs = (match_ma==3)
	rename obs targets_ma
	
	drop match_??
	
	
	*Merge ownership data 
	qui merge 1:1 bvd year using "$orig/orbis_ownership_`country'.dta", ///
	keep(master matched) keepusing(treelevel bvd_guo) // nogen
 
	qui replace   bvd_guo = bvd if missing(bvd_guo) & year > 2004 //standalones and other missings 
	
	*extrapolate owner as of 2005 
	egen bvd_id =group(bvd) 
	xtset bvd_id year  
	forval y = 2004(-1)2000 {
	qui 	replace bvd_guo = bvd_guo[_n+1] if missing(bvd_guo) & year == `y'
	}
	
	
	*Industry shares 
	g ind_manu=inlist(industry_nace1,"C","F")
	g ind_trade=inlist(industry_nace1,"G")
	g ind_service=inlist(industry_nace1,"H","I","K","L","M","N","Q","S")
	g ind_info=inlist(industry_nace1,"J")
	g ind_util=inlist(industry_nace1,"A","B","D","E")
	g ind_other=(ind_manu==0 & ind_trade==0 & ind_service==0 & ind_manu==0 & ind_info==0 )
	
	g ind_hard=1 if ind_service==0 & ind_info==0 & ind_trade==0
	g ind_hard_assets= assets_total if ind_hard==1 
	g ind_hard_revenue = revenue if ind_hard==1 

	
	*Generate variables with profits and taxes only 
	qui gen exp_tax_p = exp_tax if exp_tax>=0
	qui gen exp_tax_p_p = exp_tax if exp_tax>=0	& profit_ebt>=0
	qui gen profit_ebt_p = profit_ebt if profit_ebt>=0
	
	
	*Identify treated firms 
	qui egen treated_pe = max(targets_pe), by(bvd)
	qui egen treated_ma = max(targets_ma), by(bvd)
	qui replace treated_pe = 0 if treated_pe==.
	qui replace treated_ma = 0 if treated_ma==.
	
	
	*Identify treated firms by corporate ownership  
	qui egen treated_pe_own = max(treated_pe), by(bvd_guo)
	qui egen treated_ma_own = max(targets_ma), by(bvd_guo)	
	gen treated_pe_own_ma = (treated_pe_own+treated_ma_own == 2)
	gen treated_pe_own_ma_firm = (treated_pe_own + treated_ma ==2)	


	*Adjust for financial reporting effects of target firms 
	qui gen year_pe = year if targets_pe==1
	qui gen year_ma = year if targets_ma==1
	qui egen year_pe_sample = min(year_pe), by(bvd)
	qui egen year_ma_sample = min(year_ma), by(bvd)
	qui egen year_sample = min(year), by(bvd)
	gen  appears_pe_all = year_pe_sample - year_sample 
	drop year_pe year_ma year_pe_sample year_ma_sample year_sample

	
	*Generate variables without PE target firms 
	//option: Exclude M&A as well
	foreach var of varlist $dep_vars $dep_ratios *_p dp_* {
		qui g excl_`var' = `var' if treated_pe != 1  
		qui g excl_o_`var' = `var' if treated_pe_own !=1   //Excludes all PE affiliates
		qui g excl_m_`var' = `var' if treated_pe_own_ma_firm!=1 & treated_pe!=1 // PE targets and acquired firms with same parent and PE link  
	}
	
	qui g firms = 1
	qui g deal_assets_pe = assets_total if targets_pe == 1
	qui g deal_assets_ma = assets_total if targets_ma == 1
	qui g deal_rev_pe = revenue if targets_pe == 1
	qui g deal_rev_ma = revenue if targets_ma == 1
	qui g deal_emp_pe = number_employees if targets_pe == 1
	qui g deal_emp_ma = number_employees if targets_ma == 1
	
	
	*Prepare for collapsing
	qui egen municipal_id = group(municipal)	
	rename (exp_tax_p exp_tax_p_p profit_ebt_p)  (exp_tax_pr exp_tax_p_pr profit_ebt_pr)	
	egen targets_pe_mun=sum(targets_pe), by(municipal year)
	gen h_mun=1
	drop targets_pe
	drop if appears_pe_all < 3  
	
	if _N >0 {
		*Collapse data	
		collapse (sum) firms targets_?? deal* excl_* $dep_vars *_pr ind_hard* dp_* (mean) $dep_ratios (first) country county municipal *_mun, by(municipal_id year)
		
		qui distinct municipal_id if targets_pe == 1
		di " - Treated municipals: `r(ndistinct)'"
		drop municipal_id
			
			
		*Save data
		qui compress
		sort country municipal year
		qui save "$merged/Data_Formatted/municipals_`country'.dta", replace
		}
		
	}
timer off 1
timer list 1
 
 
 

*** 1.3 Prepare Firm-level Data with Treatment Shares in municipalities (used in Online Appendix tests)
clear
foreach country in $countries {
	di "`country'"
	qui append using "W:\Analysis - PE and Taxes\Data_Financials\Data_Formatted/orbis_`country'_munshares.dta",
}
tab targets_pe
keep bvd year share_tr* targets_pe municipal  //keep only those, because firm-level financials come from main data (after matching code)
qui compress
save "$merged/Data_Formatted/orbis_munshares.dta", replace

clear 

 
 
*** 1.2. Generate Variables for Aggregated Municipality-level Data 
// 1.2.1. Set Panel Data
clear
foreach country in $countries {
	qui append using "$merged/Data_Formatted/municipals_`country'.dta"
}
egen municipal_id = group(country municipal)

duplicates drop municipal_id year, force
xtset municipal_id year

 
// 1.2.2. Define Treatment Variables
*Private equity treatment variables
rename targets_pe_mun targets_pe

g treatment = (targets_pe > 0)
label var treatment "Treated PE"
g treatment_intense1 = (targets_pe > 0 & deal_assets_pe > 100000000)
label var treatment_intense1 "Treated PE Intense"
g treatment_intense2 = (targets_pe > 0 & deal_assets_pe > 500000000)
label var treatment_intense2 "Treated PE Very Intense"

replace treatment = 1 if treatment[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_intense1 = 1 if treatment_intense1[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_intense2 = 1 if treatment_intense2[_n-1] == 1 & municipal_id == municipal_id[_n-1]

*M&A treatment variables
g treatment_ma = (targets_ma > 0)
label var treatment_ma "Treated M&A"
g treatment_ma_intense1 = (targets_ma > 0 & deal_assets_ma > 100000000)
label var treatment_ma_intense1 "Treated M&A Intense"
g treatment_ma_intense2 = (targets_ma > 0 & deal_assets_ma > 500000000)
label var treatment_ma_intense2 "Treated M&A Very Intense"

replace treatment_ma = 1 if treatment_ma[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_ma_intense1 = 1 if treatment_ma_intense1[_n-1] == 1 & municipal_id == municipal_id[_n-1]
replace treatment_ma_intense2 = 1 if treatment_ma_intense2[_n-1] == 1 & municipal_id == municipal_id[_n-1]

*Treatment interaction
g treatment_int = treatment * treatment_ma
label var treatment_int "Treated PE * Treated M&A"
g treatment_int_intense1 = treatment_intense1 * treatment_ma_intense1
label var treatment_int "Treated PE * Treated M&A"
g treatment_int_intense2 = treatment_intense2 * treatment_ma_intense2
label var treatment_int "Treated PE * Treated M&A"


// 1.2.3. Define Dependent and Control Variables
*Taxes 
g mun_taxes=ln(1+exp_tax) * 100
g excl_mun_taxes=ln(1+excl_exp_tax) * 100
g excl_o_mun_taxes=ln(1+excl_o_exp_tax) * 100
g excl_m_mun_taxes=ln(1+excl_m_exp_tax) * 100

g mun_taxes_p=ln(1+exp_tax_pr) * 100
g excl_mun_taxes_p=ln(1+excl_exp_tax_p) * 100
g excl_o_mun_taxes_p=ln(1+excl_o_exp_tax_p) * 100
g excl_m_mun_taxes_p=ln(1+excl_m_exp_tax_p) * 100

g mun_taxes_p_p=ln(1+exp_tax_p_p) * 100
g excl_mun_taxes_p_p=ln(1+excl_exp_tax_p_p) * 100
g excl_o_mun_taxes_p_p=ln(1+excl_o_exp_tax_p_p) * 100

*Profits
g mun_ebt=ln(1+profit_ebt) * 100
g excl_mun_ebt=ln(1+excl_profit_ebt) * 100
g excl_o_mun_ebt=ln(1+excl_o_profit_ebt) * 100
g excl_m_mun_ebt=ln(1+excl_m_profit_ebt) * 100

g mun_ebt_p=ln(1+profit_ebt_pr) * 100
g excl_mun_ebt_p=ln(1+excl_profit_ebt_p) * 100
g excl_o_mun_ebt_p=ln(1+excl_o_profit_ebt_p) * 100

 
*Effective tax rates
g mun_ratio_taxes_ebt = (exp_tax / profit_ebt) * 100
label var mun_ratio_taxes_ebt "ETR (Mun.)"
g excl_mun_ratio_taxes_ebt = (excl_exp_tax / excl_profit_ebt) * 100
label var excl_mun_ratio_taxes_ebt "ETR (excl. PE target)"
g excl_o_mun_ratio_taxes_ebt = (excl_o_exp_tax / excl_o_profit_ebt) * 100
label var excl_o_mun_ratio_taxes_ebt "ETR (excl. PE target group)"
g excl_m_mun_ratio_taxes_ebt = (excl_m_exp_tax / excl_m_profit_ebt) * 100
label var excl_m_mun_ratio_taxes_ebt "ETR (excl. PE target M&A)"


g mun_ratio_taxes_ebt_p = (exp_tax_pr  / profit_ebt_pr ) * 100
label var mun_ratio_taxes_ebt_p  "ETR"
g excl_mun_ratio_taxes_ebt_p  = (excl_exp_tax_p  / excl_profit_ebt_p ) * 100
label var excl_mun_ratio_taxes_ebt_p  "ETR (excl. PE target)"

*Investments
g mun_capex_fixed = ln(1+ (assets_fixed -l.assets_fixed) + exp_depreciation) * 100
label var mun_capex_fixed "Log. Capex (Mun.)"
g excl_mun_capex_fixed = ln(1+ (excl_assets_fixed - l.excl_assets_fixed) + excl_exp_depreciation) * 100
label var excl_mun_capex_fixed "Log. Capex (excl. PE target)"
g excl_o_mun_capex_fixed = ln(1+ (excl_o_assets_fixed - l.excl_o_assets_fixed) + excl_o_exp_depreciation) * 100
label var excl_o_mun_capex_fixed "Log. Capex (excl. PE target group)"

g excl_m_mun_capex_fixed = ln(1+ (excl_m_assets_fixed - l.excl_m_assets_fixed) + excl_m_exp_depreciation) * 100
label var excl_m_mun_capex_fixed "Log. Capex (excl. PE target M&A)"

g mun_capex_tan = ln(1+(assets_fixed_tan - l.assets_fixed_tan) + exp_depreciation) * 100
label var mun_capex_tan  "Log. Tangible Capex (Mun.)"
g excl_mun_capex_tan = ln(1+(excl_assets_fixed_tan - l.excl_assets_fixed_tan) + excl_exp_depreciation) * 100
label var excl_mun_capex_tan "Log. Capex (Tangible) (excl. PE target)" 

g excl_o_mun_capex_tan = ln(1+(excl_o_assets_fixed_tan - l.excl_o_assets_fixed_tan) + excl_o_exp_depreciation) * 100
label var excl_o_mun_capex_tan "Log. Tangible Capex (excl. PE target group)" 


*Human capital
g mun_growth_empl = ((number_employees-l.number_employees) / (0.5*(number_employees+l.number_employees)) ) * 100 // Davis et al. (2014), Antoni et al. (2019)
label var mun_growth_empl "Employment Growth (Mun.)"
g excl_mun_growth_empl = ((excl_number_employees-l.excl_number_employees) / (0.5*(excl_number_employees+l.excl_number_employees)) ) * 100 // Davis et al. (2014), Antoni et al. (2019)
label var excl_mun_growth_empl "Employment Growth (excl. PE target)"
g excl_o_mun_growth_empl = ((excl_o_number_employees-l.excl_o_number_employees) / (0.5*(excl_o_number_employees+l.excl_o_number_employees)) ) * 100 // Davis et al. (2014), Antoni et al. (2019)
label var excl_o_mun_growth_empl "Employment Growth (excl. PE target group)"

g mun_salaries = ln(1+ exp_employees/number_employees) * 100
label var mun_salaries "Log. Avg. Salaries (Mun.)"
g excl_mun_salaries = ln(1+ excl_exp_employees/excl_number_employees) * 100
label var excl_mun_salaries "Log. Avg. Salaries (excl. PE target)"
g excl_o_mun_salaries = ln(1+ excl_o_exp_employees/excl_o_number_employees) * 100
label var excl_o_mun_salaries "Log. Avg. Salaries (excl. PE target group)"
g excl_m_mun_salaries = ln(1+ excl_m_exp_employees/excl_m_number_employees) * 100
label var excl_m_mun_salaries "Log. Avg. Salaries (excl. PE target M&A))"  



// 1.2.4. Define Other Variables
*Potential Control Variables
g assets_total_log=ln(1+assets_total)
qui gen firms_log=ln(firms)

*Fixed effects
egen ctry_yr = group(country year)
egen county_yr = group(county year)

*Event years for Event Study 
g treatment_year_h = year if treatment==1 
qui egen treat_year=min(treatment_year_h), by(municipal_id)
gen event_year=year-treat_year

*Size deciles
egen assets_total_mean=mean(assets_total), by(municipal_id)
egen size_decile=xtile(assets_total_mean), nq(10) by(country)
tab size_decile
egen size_yr = group(size_decile year)
 

*Number of control firms
gen controls = firms - targets_pe - targets_ma
gen controls_pe = firms - targets_pe  
qui egen deals_sampletable=sum(targets_pe)

*Industry-by-year FE
qui egen ind_hard_mun=mean(ind_hard), by(municipal_id)
qui egen ind_hard_cmun_dec=xtile(ind_hard_mun), nq(10) by(country)
qui egen ind_hard_mun_dec=xtile(ind_hard_mun), nq(100) 

qui egen cmun_ind_yr= group(ind_hard_cmun_dec year) 
qui egen mun_ind_yr= group(ind_hard_mun_dec year) 


keep if year > 2000 //because CAPEX measure missing at beginning of sample period due to lag.

qui egen controls_pe_min=min(controls_pe), by(municipal_id)
egen excl_o_number_employees_min= min(excl_o_number_employees), by(municipal_id)
egen number_employees_min= min(number_employees), by(municipal_id)


*Data Cleaning and construction for regressions
qui gen outcomes_all = 1 

foreach var of varlist $outcomes_mun {
	  qui replace outcomes_all=0 if `var'==.
 	  qui replace outcomes_all=0 if `var'==0 
}
 

*Winsorize 
winsor2  *ratio* , cuts(1 99) replace 
winsor2  *mun*capex*  *mun_growth_empl    *mun_*taxes *mun_*ebt *salar* , cuts(1 99) replace 
 

// 1.2.5. Save Dataset
qui compress
xtset municipal_id year
save "$merged/analysis_spillovers.dta", replace

 
 
 
*** 2. Analysis Aggregate Level  ***
// 2.1. Treatment Regressions
eststo clear
use "$merged/analysis_spillovers.dta", clear 

//Settings for regression  
*Specification
glo specr = " , absorb(municipal_id ctry_yr  cmun_ind_yr) vce(cluster municipal_id) "
glo treat = " treatment  treatment_ma   treatment_int " //  
glo regcond = " if controls_pe_min>0 " // 


*Final sample selection 
keep if outcomes_all>0 &    excl_o_number_employees_min!=0 & l.excl_o_number_employees_min!=0 //ensures consistent samples throughout tests 
keep $regcond //drops municiapls without non PE firm observations

*Winsorize regression sample
winsor2 $outcomes_mun ,  cuts(1 99) replace

*Summary stats for text:
sum treatment treatment_ma   treatment_int 
tab treatment  treatment_int
 
eststo clear
*Regressions
qui eststo regar_1a: reghdfe mun_ratio_taxes_ebt  $treat  $regcond $specr
qui eststo regar_1b: reghdfe mun_capex_fixed  $treat     $regcond $specr
qui eststo regar_1c: reghdfe mun_capex_tan  $treat     $regcond $specr
qui eststo regar_1d: reghdfe mun_growth_empl  $treat     $regcond $specr
qui eststo regar_1e: reghdfe mun_salaries  $treat     $regcond $specr

qui eststo regar_3a: reghdfe excl_o_mun_ratio_taxes_ebt  $treat     $regcond  $specr 
qui eststo regar_3b: reghdfe excl_o_mun_capex_fixed  $treat     $regcond  $specr 
qui eststo regar_3c: reghdfe excl_o_mun_capex_tan  $treat     $regcond  $specr 
qui eststo regar_3d: reghdfe excl_o_mun_growth_empl  $treat     $regcond  $specr 
qui eststo regar_3e: reghdfe excl_o_mun_salaries  $treat     $regcond  $specr 


*Output Stata
estout regar_* , /// //
drop(_cons) stats(N r2_a, fmt(%9.0f %9.2f) labels("Observations" "adj. R2")) /// //keep (treatment*) order(treatment*) 
c(b(fmt(%9.2f) star) t(par fmt(%9.2f))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(, ) numbers label
 

  
asdf

 

