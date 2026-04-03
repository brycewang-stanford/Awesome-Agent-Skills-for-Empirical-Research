********************************************************************************
**********                                                            **********
**********      ARTICLE: Extraction Payment Disclosures               **********
**********      AUTHOR: Thomas Rauter                                 **********
**********      JOURNAL OF ACCOUNTING RESEARCH                        **********
**********      CODE TYPE: Run all Do-Files  		                  **********
**********      LAST UPDATED: August 2020                             **********
**********                                                            **********
**********                                                            **********
**********      README / DESCRIPTION:                                 **********
**********      This STATA code runs all do-files that convert        **********
**********      the raw data into my final regression datasets.       **********
**********      The do-files use the raw data listed in Section 2     **********
**********      of the datasheet as input and produce the final       **********
**********	    regression datasets as output.                        **********
**********                                                            **********
********************************************************************************


// Set main directory => copy path into ""
global main_dir ""

global raw_data "$main_dir/00_Raw_Data"
global clean_data "$main_dir/01_Clean_Data"
global final_data "$main_dir/02_Final_data"


********************************************************************************
*****************************  1) PAYMENT ANALYSIS  ****************************
********************************************************************************

	do "$main_dir/1_data_payment.do"
	

********************************************************************************
**************************  2) SEGMENT CAPEX ANALYSIS  *************************
********************************************************************************
	
	do "$main_dir/2_data_segment_capex.do"
	
	
********************************************************************************
**************************  3) PARENT CAPEX ANALYSIS  **************************
********************************************************************************
	
	do "$main_dir/3_data_parent_capex.do"


********************************************************************************
********************** 4) AUCTION PARTICIPATION ANALYSIS ***********************
********************************************************************************

	do "$main_dir/4_data_hist_bidding.do"

	
********************************************************************************
***************************  5) LICENSING ANALYSIS  ****************************
********************************************************************************

	do "$main_dir/5_data_licensing.do"
	

********************************************************************************
*************************  6) PRODUCTIVITY ANALYSIS  ***************************
********************************************************************************

	do "$main_dir/6_data_productivity.do"
********************************************************************************
******                                                                   *******
******   			 ARTICLE: Extraction Payment Disclosures             *******
******  			 AUTHOR: Thomas Rauter                               *******
******               JOURNAL OF ACCOUNTING RESEARCH                      *******
******   			 CODE TYPE: Data Preparation for Payment Analysis    *******
******   			 LAST UPDATED: August 2020                           *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "payment"


********************************************************************************
********** 1. IMPORT PARENT INFORMATION FOR FIRMS IN EITI REPORT DATA **********
********************************************************************************

foreach s in all parent_gvkeys all_update {
	import excel "$raw_data/eiti_data_enrichment.xls", firstrow sheet(`s')
	save "$clean_data/eiti_data_enrich_`s'.dta", replace
clear
}

********************************************************************************
**************************  2. CLEAN COMPUSTAT DATA  ***************************
********************************************************************************

// Compustat North America data
use "$raw_data/compustat_north_america_fundamentals.dta", clear
keep gvkey datadate fyear curcd fyr at capx dlc dltt oibdp sale naics
save "$clean_data/compustat_north_america_fundamentals_clean.dta", replace 

// Compustat Global data
use "$raw_data/compustat_global_fundamentals.dta", clear
keep gvkey datadate fyear curcd fyr at capx dlc dltt oibdp sale naics
save "$clean_data/compustat_global_fundamentals_clean.dta", replace

// Append Compustat North America and Compustat Global data
use "$clean_data/compustat_north_america_fundamentals_clean.dta", clear
append using "$clean_data/compustat_global_fundamentals_clean.dta"

// Drop duplicates
duplicates drop gvkey fyear, force

// Merge exchange rates
rename curcd curcdq
merge m:1 curcdq datadate using "$raw_data/currencies.dta", keepusing(exratm) keep(1 3) nogen
rename at tot_assets

// Convert all currencies to GBP
foreach var of varlist tot_assets capx dlc dltt oibdp sale {
   replace `var' = `var' / exratm
}

// Generate firm fundamentals
gsort gvkey fyear
by gvkey: gen tot_assets_lag1 = tot_assets[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
gen ln_tot_assets = ln(tot_assets)
gen ln_tot_assets_lag1 = ln(tot_assets_lag1)
gen leverage = (dlc + dltt) / tot_assets
gen roa = oibdp / tot_assets_lag1
gen capex_frac = capx / tot_assets_lag1

gsort gvkey fyear
foreach var of varlist leverage roa {
   by gvkey: gen `var'_lag1 = `var'[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
}

// Trim firm fundamentals
foreach var of varlist roa_lag1  {
   winsor2 `var', cuts(1 99) trim
}
foreach var of varlist leverage_lag1 capex_frac {
   winsor2 `var', cuts(0 99) trim
}

// Generate lagged capex variables
gsort gvkey fyear
by gvkey: gen capex_frac_tr_lag1 = capex_frac_tr[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
by gvkey: gen capex_frac_tr_lag2 = capex_frac_tr[_n-2] if ((fyear[_n] == fyear[_n-2] + 2))
by gvkey: gen capex_frac_tr_lag3 = capex_frac_tr[_n-3] if ((fyear[_n] == fyear[_n-3] + 3))
by gvkey: gen capex_frac_tr_lag4 = capex_frac_tr[_n-4] if ((fyear[_n] == fyear[_n-4] + 4))
by gvkey: gen capex_frac_tr_lag5 = capex_frac_tr[_n-5] if ((fyear[_n] == fyear[_n-5] + 5))

// Generate year variable for merging with EITI data
gen year = fyear
drop if year ==.

// Drop variables without gvkey and drop duplicates
drop if gvkey == ""
duplicates drop gvkey year, force

// Convert year variable to string
gen yr = year
tostring yr, replace
drop year
gsort gvkey yr

// Save firm fundamentals data
save "$clean_data/compustat_fundamentals.dta", replace
clear

********************************************************************************
******** 3. CLEAN CORRUPTION PERCEPTIONS DATA FOR CROSS-SECTIONAL TESTS ********
********************************************************************************

// Import and clean Corruption Perceptions Index (CPI) for 2013
import excel "$raw_data/CPI_2005_2018.xlsx", firstrow sheet(CPI_2013) clear
save "$clean_data/2013_CPI.dta", replace
use "$clean_data/2013_CPI.dta", clear

drop if year >=.
replace country = "Democratic Republic of Congo" if (country == "Congo, Democratic Republic")
replace country = "Democratic Republic of Congo" if (country == "Congo. Democratic Republic")
gsort country year

gen cpi_13 = 0
replace cpi_13 = cpi if (year == 2013)

// Classify countries as highly- or less corrupt based on 2013 CPI
gen corrupt_host_cty = 0
replace corrupt_host_cty = 1 if (cpi_13 <= 28) // CPI value of 28 = 25th percentile

gen non_corrupt_host_cty = 0
replace non_corrupt_host_cty = 1 if (cpi_13 > 28)

lab var corrupt_host_cty "Corrupt Country"
lab var non_corrupt_host_cty "Non-Corrupt Country"

// Save CPI data
save "$clean_data/CPI_2013_new.dta", replace
clear

********************************************************************************
******************* 4. IMPORT PAYMENT DATA FROM EITI REPORTS ******************* 
********************************************************************************

import excel "$raw_data/eiti_country_company_payments_FINAL.xlsx", firstrow clear

// Rename variables
rename paymentgovernmentreconciled pmt_gov_reconciled
rename governmentinitial pmt_gov_initial
rename companygovernment pmt_gap_com_gov
rename commodity commodity_reported

lab var country "Country"
lab var year "Year"
lab var currency "Currency"
lab var unit "Unit"
lab var company "Company"
lab var identification_number "ID_Number"
lab var commodity_reported "Commodity Reported"
lab var pmt_gov_reconciled "Payment Government Reconciled"
lab var pmt_gov_initial "Payment Government Initial"
lab var pmt_gap_com_gov "Payment Reported by Company - Payment Received by Government"

// Drop missing payment observations
drop if pmt_gov_initial >=.
gsort country year company

// Merge parent company information
foreach file in all all_update {
if "`file'"=="all"{
merge m:1 company country ///
using "$clean_data/eiti_data_enrich_`file'.dta"
drop _merge
}
else{
merge m:1 company country ///
using "$clean_data/eiti_data_enrich_`file'.dta", update
drop _merge
}
}

// Merge Compustat data
merge m:1 parent parent_country ///
using "$clean_data/eiti_data_enrich_parent_gvkeys.dta", update keep(1 3 4 5) nogen

gen yr = year
forvalues v = 2009/2015{
local next = `v' + 1
display `next'
replace yr = "`v'" if yr == "`v'-`next'"
}

merge m:1 gvkey yr using "$clean_data/compustat_fundamentals.dta", keep(1 3) nogen

********************************************************************************
********** 5. CONVERT PAYMENT VARIABLES FROM LOCAL CURRENCY INTO GBP ***********
********************************************************************************
gsort country year

preserve
import excel "$raw_data/fx_rates_payments.xlsx", firstrow clear
gen fx_eop = (period_end_gbp_fx_bid + period_end_gbp_fx_ask) / 2
save "$clean_data/fx_payments.dta", replace
restore

merge m:1 country currency year unit ///
using "$clean_data/fx_payments.dta", keepusing(fx_eop) keep(1 3) nogen

lab var fx_eop "FX End of Period"

foreach var of varlist pmt_gov_initial pmt_gap_com_gov resolved unresolved {
   gen `var'_gbp = `var' * unit * fx_eop
}

forvalues v = 2009/2015{
local next = `v' + 1
replace year = "`v'.5" if year == "`v'-`next'"
}
destring year, replace

********************************************************************************
**************  6. MERGE EPD DATA AND CROSS-SECTIONAL VARIABLES ****************
********************************************************************************

// Merge EPD masterfile 
merge m:1 gvkey using "$raw_data/epd_masterfile.dta", keep(1 3) nogen

// Merge CPI data
kountry country, from(other) stuck
gen country_intermed = _ISO3N_
kountry country_intermed, from(iso3n) to(iso3c)
rename _ISO3C_ segment_country
drop _ISO3N_

kountry parent_country, from(other) stuck
gen parent_country_intermed = _ISO3N_
kountry parent_country_intermed, from(iso3n) to(iso3c)
rename _ISO3C_ loc

merge m:1 country using "$clean_data/CPI_2013_new.dta", keep(1 3) nogen

egen corrupt_new = max(corrupt_host_cty), by(country)
egen non_corrupt_new = max(non_corrupt_host_cty), by(country)

// Merge shaming channel data
do "$code/clean_shaming_data.do"


********************************************************************************
**********************  7. CLEAN SUBSIDIARY NAMES  *****************************
********************************************************************************
do "$code/clean_company_name.do"


********************************************************************************
************************  8. PREPARE REGRESSION SAMPLE *************************
********************************************************************************

// Rename variables
rename pmt_gov_initial_gbp pmt_gov
rename pmt_gap_com_gov_gbp pmt_gap
rename resolved_gbp res
gen pmt_company = pmt_gap + pmt_gov

// Drop missing year observations
drop if year >=.

// Define EPD treatment indicators
gen EPD_effective_year_masterfile = year(effective_since)
gen EPD_implementation_wave = 0
replace EPD_implementation_wave = 1 if (EPD_effective_year_masterfile == 2014)
replace EPD_implementation_wave = 2 if (EPD_effective_year_masterfile == 2015)
replace EPD_implementation_wave = 3 if (EPD_effective_year_masterfile == 2016)
 
// Generate dependent variables
gen pmt_tot_assets = pmt_company / (tot_assets_lag1 * 1000000)
replace pmt_tot_assets =. if (pmt_tot_assets < 0)

// Trim dependent variables
winsor2 pmt_tot_assets, cuts(1 99) trim

// Multiply dependent variables by 100
gen pmt_tot_assets_tr_100 = pmt_tot_assets_tr * 100
gen pmt_tot_assets_100 = pmt_tot_assets * 100

// Generate EPD indicators
gen EPD = 0
replace EPD = 1 if ((EPD_implementation_wave == 1 & year > 2013 & year <.) | (EPD_implementation_wave == 2 & year > 2014 & year <.) | (EPD_implementation_wave == 3 & year > 2015 & year <.))

// Generate event-time indicators
gen EPD_0plus = EPD

gen EPD_minus1 = 0
replace EPD_minus1 = 1 if ((EPD_implementation_wave == 1 & (year == 2013 | year == 2012.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2014 | year == 2013.5) & year <.)  | (EPD_implementation_wave == 3 & (year == 2015 | year == 2014.5) & year <.))

gen EPD_minus2 = 0
replace EPD_minus2 = 1 if ((EPD_implementation_wave == 1 & (year == 2012 | year == 2011.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2013 | year == 2012.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2014 | year == 2013.5) & year <.))

gen EPD_minus3 = 0
replace EPD_minus3 = 1 if ((EPD_implementation_wave == 1 & (year == 2011 | year == 2010.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2012 | year == 2011.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2013 | year == 2012.5) & year <.))

gen EPD_minus4 = 0
replace EPD_minus4 = 1 if ((EPD_implementation_wave == 1 & (year == 2010 | year == 2009.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2011 | year == 2010.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2012 | year == 2011.5) & year <.))

gen EPD_minus5 = 0
replace EPD_minus5 = 1 if ((EPD_implementation_wave == 1 & (year == 2009 | year == 2008.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2010 | year == 2009.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2011 | year == 2010.5) & year <.))

gen EPD_3minus = 0
replace EPD_3minus = 1 if (EPD_minus3 == 1  | EPD_minus4 == 1  | EPD_minus5 == 1)

// High vs. low corruption in host country
gen EPD_corrupt_host_cty = EPD * corrupt_host_cty
gen EPD_non_corrupt_host_cty = EPD * non_corrupt_host_cty

// Foreign vs. domestic host country
gen foreign_host_cty = 0
replace foreign_host_cty = 1 if (country != parent_country)

gen domestic_host_cty = 0
replace domestic_host_cty = 1 if (country == parent_country)

gen EPD_foreign_host_cty = EPD * foreign_host_cty
gen EPD_domestic_host_cty = EPD * domestic_host_cty

// Company subject to high vs. low media coverage
replace high_media_cov_d = 0 if high_media_cov_d ==.
replace low_media_cov_d = 0 if low_media_cov_d ==.
gen EPD_high_media_cov = EPD * high_media_cov_d
gen EPD_low_media_cov = EPD * low_media_cov_d

// Company target vs. no target of NGO shaming campaign
replace campaign_before_effective_d = 0 if campaign_before_effective_d ==.
replace no_campaign_before_effective_d = 0 if no_campaign_before_effective_d ==.

gen EPD_activist_campaign = EPD * campaign_before_effective_d
gen EPD_no_activist_campaign = EPD * no_campaign_before_effective_d

// Identify micro firms with less than USD 10 mn in total assets
gen small = 0
replace small = 1 if (tot_assets < 6.2) // USD 10 mn * average USD/GBP FX rate; results also hold when including micro firms

// Keep only relevant variables
rename effective_since EPD_effective_since

keep pmt_tot_assets_100 pmt_tot_assets_tr_100 EPD_implementation_wave EPD EPD_effective_since ln_tot_assets_lag1 tot_assets_lag1 tot_assets roa_lag1_tr leverage_lag1_tr ///
EPD_corrupt_host_cty EPD_non_corrupt_host_cty naics yr year country parent_country company_cleaned parent ///
corrupt_host_cty non_corrupt_host_cty EPD_activist_campaign EPD_no_activist_campaign EPD_high_media_cov EPD_low_media_cov gvkey ///
part_of_annual_report EPD_foreign_host_cty EPD_domestic_host_cty capex_frac_tr capex_frac_tr_lag1 capex_frac_tr_lag2 capex_frac_tr_lag3 capex_frac_tr_lag4 capex_frac_tr_lag5 ///
EPD_0plus EPD_minus1 EPD_minus2 EPD_minus3 EPD_minus4 EPD_minus5 EPD_3minus small company_standardized fyear pmt_company oibdp sale

// Label variables
lab var capex_frac_tr "Capex_t/Total Assets_t-1 - Trimmed"
lab var capex_frac_tr_lag1 "Capex_t-1/Total Assets_t-2 - Trimmed"
lab var capex_frac_tr_lag2 "Capex_t-2/Total Assets_t-3 - Trimmed"
lab var capex_frac_tr_lag3 "Capex_t-3/Total Assets_t-4 - Trimmed"
lab var part_of_annual_report "Corrupt Host Country - CPI 2013 larger than 25"
lab var pmt_tot_assets_100 "Government Payments/Tot. Assets x 100"
lab var pmt_tot_assets_tr_100 "Government Payments/Tot. Assets x 100 - Trimmed"
lab var EPD_effective_since "EPD Effective Since - Date"
lab var country "Host Country"
lab var parent_country "Parent Country"
lab var company_cleaned "Clean Company Name"
lab var parent "Parent Company"
lab var year "Year(s) of EITI report coverage"
lab var yr "Year"
lab var naics "North American Industry Classification (NAICS) code"
lab var gvkey "Compustat Global Company Key (GVKEY)"
lab var EPD_implementation_wave "EPD Waves of Implementation"

// Define sample
drop if year < 2010
drop if small == 1

// Generate dependent variable
gen ln_payment = ln(1 + pmt_tot_assets_100)

// Generate fixed effects
gen naics3 = substr(naics,1,3)
encode naics3, gen(naics_3no)
egen naics3_year = group(naics_3no year)
rename naics3_year resource_year_FE

egen firm_subsidiary_FE = group(company_cleaned)
egen host_country_year_FE = group(country year)

egen treated = max(EPD), by(parent)
egen treated_year_FE = group(treated year)

// Label regression variables
label var ln_payment "Ln(1+Extractive Payment/Total Assets\textsubscript{t-1} $\times$ 100)"
label var EPD "EPD"
label var EPD_corrupt_host_cty "EPD $\times$ Highly Corrupt Host Country"
label var EPD_non_corrupt_host_cty "EPD $\times$ Less Corrupt Host Country"
label var EPD_foreign_host_cty "EPD $\times$ Foreign Host Country"
label var EPD_domestic_host_cty "EPD $\times$ Domestic Host Country"
label var ln_tot_assets_lag1 "\emph{Control Variables:} \vspace{0.1cm} \\ Ln(Total Assets\textsubscript{t-1})"
label var roa_lag1_tr "Return on Assets\textsubscript{t-1}"
label var leverage_lag1_tr "Leverage\textsubscript{t-1}"
label var corrupt_host_cty "Highly Corrupt Host Country"
label var non_corrupt_host_cty "Less Corrupt Host Country"
label var EPD_activist_campaign "EPD $\times$ Target of NGO Shaming Campaign"
label var EPD_no_activist_campaign "EPD $\times$ Never Target of NGO Shaming Campaign"
label var EPD_high_media_cov "EPD $\times$ High Media Coverage"
label var EPD_low_media_cov "EPD $\times$ Low Media Coverage"


// Save cleaned and merged payment dataset
save "$final_data/payment_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******   	 ARTICLE: Extraction Payment Disclosures                     *******
******  	 AUTHOR: Thomas Rauter                                       *******
******       JOURNAL OF ACCOUNTING RESEARCH                              *******
******       CODE TYPE: Data Preparation for Segment Capex Analysis      *******
******   	 LAST UPDATED: August 2020                                   *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "investment"


********************************************************************************
*********************  1. EXTRACT GVKEYs AND NAICS CODES  **********************
********************************************************************************

// Compustat North America
import delimited "$raw_data/compustat_north_america_naics.txt", clear stringcols(_all)
gen dummy = 1
collapse (sum) dummy, by(gvkey cusip naics)
drop dummy
drop if cusip == ""
isid gvkey cusip 
save "$clean_data/compustat_north_america_naics.dta", replace 

// Compustat Global
import delimited "$raw_data/compustat_global_naics.txt", clear stringcols(_all)
gen dummy = 1
collapse (sum) dummy, by(gvkey sedol isin naics)
drop dummy
replace isin = "missing" if isin == "" 
replace sedol = "missing" if sedol == "" 

// Check that (i) gvkey-sedol and (ii) gvkey-isin uniquely identify observations
isid gvkey sedol
isid gvkey isin 

save "$clean_data/compustat_global_naics.dta", replace


********************************************************************************
**********************  2. CLEAN WORLDSCOPE SEGMENT DATA  **********************
********************************************************************************

import delimited "$raw_data/segment_data_worldscope_2017.csv", clear

replace freq="1" if freq=="A"
replace freq="2" if freq=="B"
destring freq, replace
label define freq 1 "Annual" 2 "Restated-Annual"
label values freq freq

// Firm identifying information
rename item6008 isin
label variable isin "ISIN"
rename item6004 cusip
label variable cusip "CUSIP"
rename item6006 sedol
label variable sedol "SEDOL"
rename item5601 ticker 
label variable ticker "TICKER"
rename item6105 ws_id 
label variable ws_id "Worldscope Identifier"
rename item6001 name 
label variable name "Company Name"
rename item6026 nation 
label variable nation "Country Out; country where the company is headquartered"
rename item6027 nation_code
label variable nation_code "Country Out code"
rename item6028 region
label variable region "Region of the world where the company is headquartered"
rename year_ year
label variable year "Year"
rename item5352 fyearend
label variable fyearend "Fiscal Year End"

// Identify geographic segments (each firm has up to 10 segments)
local segment 1 2 3 4 5 6 7 8 9 10
foreach segment in `segment' {
	local item=`segment'-1
	di `segment'
	di `item'
	rename item196`item'0 segment_description`segment'
	label var segment_description`segment' "Segment Description"
	rename item196`item'3 segment_assets`segment'
	label var segment_assets`segment' "Segment Assets"
	rename item196`item'4 segment_capex`segment'
	label var segment_capex`segment' "Segment Capital Expenditure"
	}
drop item*

keep if year >= 2000

// Keep unique ws_id-year observations (segments are still separate variables in wide format)
sort ws_id year freq
by ws_id year: generate duplicate=cond(_N==1, 0, _n)

keep if duplicate==0 | (duplicate==2 & freq==2)
drop duplicate

isid ws_id year
order nation nation_code, after(ws_id)

// Generate lagged parent assets and merge to segment dataset
preserve
	use "$raw_data/firm_fundamentals_worldscope_parent.dta", clear
	rename total_assets tot_assets_USD // Total Assets in USD (item 07230)
	keep ws_id year tot_assets_USD
	rename tot_assets_USD tot_assets_USD_lag1
	replace year = year + 1
	tempfile tot_assets_USD_lag1
	save `tot_assets_USD_lag1'
restore
merge 1:1 ws_id year using `tot_assets_USD_lag1', keep(1 3) nogen

// Reshape dataset to long format
reshape long segment_description segment_capex segment_oic segment_assets, i(ws_id year) j(segment)
duplicates drop

// Merge parent fundamentals and drop observations without segment data
merge m:1 ws_id year using "$raw_data/firm_fundamentals_worldscope_parent.dta", keepusing(total_assets roa total_assets_local total_liabilities_local) keep(1 3) nogen
rename total_assets tot_assets_USD


********************************************************************************
******************  3. CLEAN AND STANDARDIZE COUNTRY NAMES  ********************
********************************************************************************

// Cleaning of country-in names
replace segment_description=upper(segment_description)
replace segment_description=subinstr(segment_description, "(COUNTRY)", "", .)
do "$code/clean_country_name.do"

// Standardize country names
rename MARKER CHECK1
kountry NAMES, from(other) marker
drop NAMES
rename NAMES_STD Country_In
label variable Country_In "Capex Destination Country"
rename nation Country_Out
drop if MARKER==0
drop MARKER

// Generate ISO3 codes and country names
kountry Country_In, from(other) stuck marker
drop if Country_In=="European Union"
drop MARKER

rename _ISO3N_ Country_In_iso3N
kountry Country_In_iso3N, from(iso3n) to(iso3c) marker
drop NAMES_STD MARKER
rename _ISO3C_ Country_In_iso3C

replace Country_Out="British Virgin Islands" if Country_Out=="VIRGIN ISLANDS(BRIT)" | ///
	    Country_Out=="Virgin Islands" | Country_Out=="VIRGIN ISLANDS (BRIT)"
		
kountry Country_Out, from(other) marker
drop Country_Out MARKER
rename NAMES_STD Country_Out 

kountry Country_Out, from(other) stuck marker
drop MARKER

rename _ISO3N_ Country_Out_iso3N
kountry Country_Out_iso3N, from(iso3n) to(iso3c) marker
drop NAMES_STD MARKER
rename _ISO3C_ Country_Out_iso3C

replace Country_Out_iso3C="GGY" if Country_Out=="guernsey"
replace Country_Out_iso3C="IMN" if Country_Out=="isle of man"
replace Country_Out_iso3C="JEY" if Country_Out=="jersey"
drop if Country_In_iso3C=="" | Country_Out_iso3C==""


********************************************************************************
******************  4. CONVERT SEGMENT CAPEX INTO USD AMOUNTS  *****************
********************************************************************************

// Merge exchange rate dataset
replace nation_code = 840 if Country_Out == "United States" & nation_code == . // if nation_code is missing but country_out is United States -> replace with US nation_code
label define nation_codes 012 "Algeria" 422 "Lebanon" 025 "Argentina" 428 "Latvia" 036 "Australia" 440 "Lithuania" ///
040 "Austria" 442 "Luxembourg" 044 "Bahamas" 454 "Malawi" 048 "Bahrain" 458 "Malaysia" ///
052 "Barbados" 470 "Malta" 056 "Belgium" 480 "Mauritius" 060 "Bermuda" 484 "Mexico" ///
068 "Bolivia" 496 " Mongolia" 070 "Bosnia and Herzegovina" 499 "Montenegro" ///
072 "Botswana" 504 "Morocco" 076 " Brazil" 516 "Namibia" 092 "British Virgin Islands" ///
528 "Netherlands" 100 "Bulgaria" 554 "New Zealand" 124 "Canada" 566 "Nigeria" ///
136 "Cayman Islands" 578 "Norway" 152 "Chile" 582 "Oman" 156 "China" 586 "Pakistan" ///
175 "Colombia" 591 "Panama" 178 "Costa Rica" 597 "Peru" 182 "Cote d’Ivoire" 593 "Paraguay" ///
191 "Croatia" 608 " Philippines" 196 "Cyprus" 617 "Poland" 203 "Czech Republic" 620 "Portugal" ///
208 "Denmark" 634 "Qatar" 214 "Dominican Republic" 642 "Romania" 218 "Ecuador" 643 "Russia" ///
220 "Egypt" 682 "Saudi Arabia" 222 "El Salvador" 688 "Serbia" 233 "Estonia" 702 "Singapore" ///
234 "Faroe Islands" 703 "Slovakia" 242 "Fiji" 704 "Vietnam" 246 "Finland" 705 "Slovenia" ///
250 "France" 710 "South Africa" 268 "Georgia" 724 "Spain" 275 "Palestine" 730 "Sri Lanka" ///
280 "Germany" 736 "Sudan" 300 "Greece" 748 "Swaziland" 320 "Guatemala" 752 "Sweden" ///
328 "Guyana" 756 "Switzerland" 340 "Honduras" 760 "Taiwan" 344 "Hong Kong" 764 "Thailand" ///
350 "Hungary" 780 "Trinidad and Tobago" 352 "Iceland" 784 "United Arab Emirates" ///
356 "India" 788 "Tunisia" 366 "Indonesia" 796 "Turkey" 372 "Ireland" 800 "Uganda" ///
376 "Israel" 804 "Ukraine" 380 "Italy" 807 "Macedonia" 388 "Jamaica" 826 "United Kingdom" ///
392 "Japan" 833 "Isle of Man" 398 "Kazakhstan" 834 "Tanzania" 400 "Jordan" 840 "United States" ///
404 "Kenya" 862 "Venezuela" 410 "South Korea" 894 "Zambia" 414 "Kuwait" 897 "Zimbabwe" ///
831 "South Africa" 50 "Bangladesh" 116 "Cambodia" 120 "Cameroon" 288 "Ghana" 369 "Iraq" ///
646 "Rwanda" 686 "Senegal" 860 "Uzbekistan"

label values nation_code nation_codes
decode nation_code, generate(currency_country)
replace currency_country = strtrim(currency_country)

// Generate ISO3 codes for currency country
kountry currency_country, from(other) stuck marker
drop MARKER
rename _ISO3N_ currency_country_iso3N
kountry currency_country_iso3N, from(iso3n) to(iso3c) marker
drop MARKER NAMES currency_country_iso3N
rename _ISO3C_ currency_country_iso3C
replace currency_country_iso3C = "CIV" if nation_code == 182

// Merge World Bank exchange rate data
merge m:1 currency_country_iso3C year using "$raw_data/exchange_rates_2017" 
drop if _m==2
drop _m

// Transform values into USD millions
gen segment_capex_USD = segment_capex / (exchangerate * 1000000)
gen segment_assets_USD = segment_assets / (exchangerate * 1000000)

// Order variables
order Country_Out Country_Out_iso3C, before(Country_In)
order year fyearend, before(segment_capex_USD)


********************************************************************************
*************************  5. CLEAN AND MERGE CPI DATA  ************************
********************************************************************************

// Construct CPI panel from 1998 to 2017
preserve

* Import 1998 to 2015 data
import excel "$raw_data/cpi_1998_2015.xlsx", first clear
destring  cpi1998 cpi1999 cpi2000 cpi2001 cpi2002 cpi2003 cpi2004 cpi2005 cpi2006 cpi2007 ///
          cpi2008 cpi2009 cpi2010 cpi2011 cpi2012 cpi2013 cpi2014 cpi2015, force replace
tempfile 1998_2015
save `1998_2015'

* Import 2016 data
import excel "$raw_data/cpi_2016.xlsx", first clear sheet(CPI2016_FINAL_16Jan)
rename Country country
rename CPI2016 cpi2016
keep country cpi2016
tempfile 2016
save `2016'

* Import 2017 data
import excel "$raw_data/cpi_2017.xls", first clear sheet(CPI 2017) cellrange(A3)
rename Country country
rename CPIScore2017 cpi2017
rename ISO3 iso3
drop if country == "" | country == "GLOBAL AVARAGE"
keep country cpi2017
tempfile 2017
save `2017'

* Merge datasets
use `1998_2015', clear
merge m:1 country using `2016'
drop _merge
gsort country

merge m:1 country using `2017'
drop _merge
gsort country

* Reshape to long format
gen id = _n
reshape long cpi, i(id) j(year 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 /// 
2008 2009 2010 2011 2012 2013 2014 2015 2016 2017)

* Generate ISO3 country codes
kountry country, from(other) stuck
replace _ISO3N_ = 70 if country == "Bosnia and Herzgegovina"
replace _ISO3N_ = 180 if country == "Congo Democratic Republic"
replace _ISO3N_ = 178 if country == "Congo Republic"
replace _ISO3N_ = 178 if country == "Congo-Brazzaville"
replace _ISO3N_ = 180 if country == "Congo. Democratic Republic"
replace _ISO3N_ = 178 if country == "Congo. Republic"
replace _ISO3N_ = 384 if country == "Cote d´Ivoire"
replace _ISO3N_ = 203 if country == "Czech Republik"
replace _ISO3N_ = 384 if country == "Côte d´Ivoire"
replace _ISO3N_ = 384 if country == "Côte d’Ivoire"
replace _ISO3N_ = 384 if country == "Côte-d'Ivoire"
replace _ISO3N_ = 384 if country == "Côte D'Ivoire"
replace _ISO3N_ = 132 if country == "Cabo Verde"
replace _ISO3N_ = 807 if country == "FYR Macedonia"
replace _ISO3N_ = 414 if country == "Kuweit"
replace _ISO3N_ = 807 if country == "Macedonia (Former Yugoslav Republic of)"
replace _ISO3N_ = 498 if country == "Moldovaa"
replace _ISO3N_ = 275 if country == "Palestinian Authority "
replace _ISO3N_ = 178 if country == "Republic of Congo "
replace _ISO3N_ = 762 if country == "Taijikistan "
replace _ISO3N_ = 807 if country == "The FYR of Macedonia"
replace _ISO3N_ = 275 if country == "Palestinian Authority"
replace _ISO3N_ = 178 if country == "Republic of Congo"
replace _ISO3N_ = 762 if country == "Taijikistan"
replace _ISO3N_ = 688 if country == "Serbia"

gen country_intermed = _ISO3N_
kountry country_intermed, from(iso3n) to(iso3c)

* Fix ISO3 code errors
replace _ISO3C_="SRB" if country=="Serbia"
replace _ISO3C_="SCG" if country=="Serbia and Montenegro" | country=="Serbia & Montenegro"
replace _ISO3C_="KSV" if country=="Kosovo"

* Drop CPI duplicates
replace cpi = 0 if (cpi ==.)
collapse (max) cpi, by(_ISO3C_ year)

rename _ISO3C_ iso3
drop if iso3 == ""
replace cpi =. if (cpi == 0)
duplicates report iso3 year

* Rescale data before 2012 (1998-2011: 0-10; 2012-2016: 0-100)
replace cpi = cpi * 10 if (year < 2012)
rename iso3 iso3_code
label variable cpi "CPI - Transparency International"

* Ensure data is unique at country-year level
isid iso3_code year

* Save CPI dataset
save "$clean_data/cpi_1998_2017.dta", replace
restore

preserve
	use "$clean_data/cpi_1998_2017.dta", clear
	drop if cpi==.
	rename iso3_code Country_In_iso3C
	rename cpi cpi_in
	save "$clean_data/cpi_in.dta", replace
    rename Country_In_iso3C Country_Out_iso3C
	rename cpi_in cpi_out
	save "$clean_data/cpi_out.dta", replace
restore

* Merge CPI of Country_In 
merge m:1 Country_In_iso3C year using "$clean_data/cpi_in.dta", keep(1 3) nogen
order cpi_in, after(Country_In_iso3C)

* Merge CPI of Country_Out
merge m:1 Country_Out_iso3C year using "$clean_data/cpi_out.dta", keep(1 3) nogen

// Save cleaned Worldscope segment dataset
save "$clean_data/clean_worldscope_segment_panel.dta", replace


********************************************************************************
**********************  6. MERGE GVKEYs AND NAICS CODES  ***********************
********************************************************************************

use "$clean_data/clean_worldscope_segment_panel.dta", clear

// Merge North American gvkeys and naics codes based on CUSIP
merge m:1 cusip using "$raw_data/gvkey_to_naics_north_america.dta", keep(1 3) nogen
rename gvkey NAgvkey
rename naics NAnaics

// Merge Global gvkeys and naics codes based on SEDOL
preserve
use "$raw_data/gvkey_to_naics_global.dta", clear
keep gvkey sedol naics
duplicates drop sedol, force
save "$raw_data/gvkey_to_naics_global_sedol.dta", replace
restore

merge m:1 sedol using "$raw_data/gvkey_to_naics_global_sedol.dta", keepusing(gvkey naics) keep(1 3) nogen
rename gvkey GSgvkey
rename naics GSnaics

// Merge Global gvkeys and naics codes based on ISIN
preserve
use "$raw_data/gvkey_to_naics_global.dta", clear
keep gvkey isin naics
duplicates drop isin, force
save "$raw_data/gvkey_to_naics_global_isin.dta", replace
restore

merge m:1 isin using "$raw_data/gvkey_to_naics_global_isin.dta", keepusing(gvkey naics) keep(1 3) nogen
rename gvkey GISINgvkey
rename naics GISINnaics

// Get unique identifier
replace NAgvkey = GSgvkey if NAgvkey == ""
replace NAgvkey = GISINgvkey if NAgvkey == ""
rename NAgvkey gvkey
label var gvkey "gvkey"
drop GSgvkey GISINgvkey
sort gvkey

// Generate NAICS code
replace NAnaics = GSnaics if NAnaics == ""
replace NAnaics = GISINnaics if NAnaics == ""
rename NAnaics naics
label var naics "NAICS"
drop GSnaics GISINnaics

// Order variables
order ws_id gvkey ticker cusip sedol isin name region year segment IN fyearend /// 
freq nation_code segment_capex segment_oic segment_assets ///
segment_capex_USD segment_assets_USD naics Country_Out ///
Country_Out_iso3C Country_In Country_In_iso3C cpi_in cpi_out currency_country ///
currency_country_iso3C exchangerate in_euro

// Drop duplicates and observations with multiple values at firm x country-in x year-level
sort ws_id Country_In year IN 
duplicates tag ws_id Country_In year, generate(tagged)
duplicates drop ws_id Country_In IN year segment_capex segment_assets segment_oic, force
drop if tagged != 0


********************************************************************************
************************  7. PREPARE REGRESSION SAMPLE  ************************
********************************************************************************

egen segment_id = group(ws_id Country_In)

// Generate lagged parent fundamentals
preserve
	keep ws_id year tot_assets_USD roa total_assets_local total_liabilities_local
	foreach v of var tot_assets_USD roa total_assets_local total_liabilities_local {
	rename `v' `v'_lag1
	label var `v'_lag1 "`v'_t-1"
	}
	replace year = year + 1
	duplicates drop ws_id year, force
	tempfile lagged_parent_controls
	save `lagged_parent_controls'
restore
merge m:1 ws_id year using `lagged_parent_controls', keep(1 3) nogen

// Merge EPD masterfile
merge m:1 gvkey using "$raw_data/epd_masterfile.dta", force
drop if _merge == 2
replace report = 0 if report == .

// Keep extractive firms (NAICS code of 21 or 324 OR EPD reporting)
gen naics_2 = substr(naics, 1, 2)
gen naics_3 = substr(naics, 1, 3)
keep if naics_2 == "21" | naics_3 == "324" | _merge == 3
drop _merge

// Generate EPD variable
gen EPD_effective_since_year = year(effective_since)

gen EPD = 0
replace EPD = 1 if year >= EPD_effective_since_year
label var EPD_effective "EPD"

// Merge public shaming data
gen loc = Country_Out_iso3C
do "$code/clean_shaming_data.do"

// Foreign vs. domestic segment indicators
gen foreign = 0
replace foreign = 1 if (Country_In_iso3N != Country_Out_iso3N)
gen domestic = 0
replace domestic = 1 if (Country_In_iso3N == Country_Out_iso3N)

gen EPD_foreign_host_cty = EPD * foreign
gen EPD_domestic_host_cty = EPD * domestic

// High vs. low corruption in host country
gen cpi_2013 = cpi_in if year == 2013
gsort Country_In_iso3C
by Country_In_iso3C: egen cpi_2013_max = max(cpi_2013)

gen corrupt_host_cty = 0
replace corrupt_host_cty = 1 if (cpi_2013_max <= 28) // CPI value of 28 = 25th percentile
gen non_corrupt_host_cty = 0
replace non_corrupt_host_cty = 1 if (cpi_2013_max > 28)

gen EPD_corrupt_host_cty = EPD * corrupt_host_cty
gen EPD_non_corrupt_host_cty = EPD * non_corrupt_host_cty

// Company subject to high vs. low media coverage
replace high_media_cov_d = 0 if high_media_cov_d ==.
replace low_media_cov_d = 0 if low_media_cov_d ==.
gen EPD_high_media_cov = EPD * high_media_cov_d
gen EPD_low_media_cov = EPD * low_media_cov_d

// Company target vs. no target of NGO shaming campaign
replace campaign_before_effective_d = 0 if campaign_before_effective_d ==. 
replace no_campaign_before_effective_d = 0 if no_campaign_before_effective_d ==. 
gen EPD_activist_campaign = EPD * campaign_before_effective_d
gen EPD_no_activist_campaign = EPD * no_campaign_before_effective_d

// Generate dependent variable
gen seg_capex_ta = segment_capex_USD / (tot_assets_USD_lag1 / 1000000)
gen seg_capex_ta_100 = seg_capex_ta * 100

// Generate control variables
gen ln_tot_assets_lag1 = ln(tot_assets_USD_lag1)

gen leverage_lag1 = total_liabilities_local_lag1 / total_assets_local_lag1
winsor2 leverage_lag1, cuts(0 95) trim

winsor2 roa_lag1, cuts(5 95) trim
replace roa_lag1_tr = roa_lag1_tr / 100

// Drop negative segment capex observations
drop if seg_capex_ta < 0

// Generate Total Assets in USD millions
gen tot_assets_mn_USD = tot_assets_USD / 1000000

// Identify tax havens 
gen imf_1_in = 0
replace imf_1_in = 1 if (Country_In == "Guernsey" | Country_In == "Hong Kong" | Country_In == "Ireland" | Country_In == "Isle of Man" | Country_In == "Jersey" | Country_In == "Luxembourg" | Country_In == "Singapore" | Country_In == "Switzerland")

gen imf_2_in = 0
replace imf_2_in = 1 if (Country_In == "Andorra" | Country_In == "Bahrain" | Country_In == "Barbados" | Country_In == "Bermuda" | Country_In == "Gibraltar" | Country_In == "Macao" | Country_In == "Malaysia" | Country_In == "Malta" | Country_In == "Monaco")

gen imf_3_in = 0
replace imf_3_in = 1 if (Country_In == "Anguilla" | Country_In == "Antigua and Barbuda" | Country_In == "Aruba" | Country_In == "Bahamas" | Country_In == "Belize" | Country_In == "British Virgin Islands" ///
				    | Country_In == "Cayman Islands" | Country_In == "Cook Islands" | Country_In == "Costa Rica" | Country_In == "Cyprus" | Country_In == "Dominica" | Country_In == "Grenada" ///
					| Country_In == "Lebanon" | Country_In == "Liechtenstein" | Country_In == "Marshall Islands" | Country_In == "Mauritius" | Country_In == "Montserrat" | Country_In == "Nauru" ///
					| Country_In == "Netherlands Antilles" | Country_In == "Niue" | Country_In == "Panama" | Country_In == "Palau" | Country_In == "Samoa"  | Country_In == "Seychelles"  | Country_In == "St. Kitts and Nevis"  ///
					| Country_In == "St. Lucia" | Country_In == "St. Vincent and the Grenadines"  | Country_In == "Turks and Caicos Islands"  | Country_In == "Vanuatu")							
			
// Drop tax havens
keep if imf_1_in == 0 & imf_2_in == 0 & imf_3_in == 0

// Define sample
keep if year >= 2010 & year <= 2017
keep if seg_capex_ta < 0.10 & tot_assets_mn_USD > 10

// Keep segments with at least 1 observation in the pre- and post-2014 periods (results also hold without this restriction)
gen pre = 0
replace pre = 1 if year < 2014
gen post = 0
replace post = 1 if year >= 2014

egen segment_group = group(ws_id Country_In) 
bysort segment_group: egen pre_obs = sum(pre)
bysort segment_group: egen post_obs = sum(post)
keep if pre_obs > 0 & post_obs > 0

// Generate fixed effects and groups
egen firm_subsidiary_FE = group(ws_id Country_In_iso3C)
encode naics_3, gen(naics_3no)
egen resource_year_FE = group(naics_3no year)
egen host_country_year_FE = group(Country_In_iso3C year)
egen parent_country_FE = group(Country_Out)
egen treated_year_FE = group(report year)

// Label regression variables
lab var seg_capex_ta "Segment Capex/Total Assets\textsubscript{t-1}"
lab var seg_capex_ta_100 "Segment Capex/Total Assets\textsubscript{t-1} $\times$ 100"
lab var EPD "EPD"
lab var EPD_corrupt_host_cty "EPD $\times$ Highly Corrupt Host Country"
lab var EPD_non_corrupt_host_cty "EPD $\times$ Less Corrupt Host Country"
lab var EPD_foreign_host_cty "EPD $\times$ Foreign Host Country"
lab var EPD_domestic_host_cty "EPD $\times$ Domestic Host Country"
lab var corrupt_host_cty "Highly Corrupt Host Country"
lab var non_corrupt_host_cty "Less Corrupt Host Country"
lab var ln_tot_assets_lag1 "Ln(Total Assets\textsubscript{t-1})"
lab var roa_lag1_tr "Return on Assets\textsubscript{t-1}"
lab var leverage_lag1_tr "Leverage\textsubscript{t-1}"
lab var EPD_activist_campaign "EPD $\times$ Target of NGO Shaming Campaign"
lab var EPD_no_activist_campaign "EPD $\times$ Never Target of NGO Shaming Campaign"
lab var EPD_high_media_cov "EPD $\times$ High Media Coverage"
lab var EPD_low_media_cov "EPD $\times$ Low Media Coverage"


// Save clean and merged segment capex analysis dataset
save "$final_data/segment_capex_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******         ARTICLE: Extraction Payment Disclosures                   *******
******  	   AUTHOR: Thomas Rauter                                     *******
******         JOURNAL OF ACCOUNTING RESEARCH                            *******
******   	   CODE TYPE: Data Preparation for Parent Capex Analysis     *******
******         LAST UPDATED: August 2020                                 *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "investment"


********************************************************************************
*******************  1. CLEAN COMPUSTAT FIRM FUNDAMENTALS  *********************
********************************************************************************

// Prepare exchange rate data
use "$raw_data/g_exr_monthly.dta", clear
rename tocurm curcdq
save "$clean_data/currencies_monthly_clean.dta", replace

// Remove duplicates in securities dataset
use "$raw_data/security_data.dta", clear
gsort gvkey datadate
gen check = 0
replace check = 1 if (gvkey[_n] == gvkey[_n-1] & (datadate[_n] == datadate[_n-1]))
drop if check == 1
drop check
save "$clean_data/security_data_clean.dta", replace

// Remove duplicates in Compustat Global
use "$raw_data/compustat_global.dta", clear
gsort gvkey datadate
gen check = 0
replace check = 1 if (gvkey[_n] == gvkey[_n-1] & (datadate[_n] == datadate[_n-1]))
drop if check == 1
drop check

// Merge datasets (Compustat + Exchange Rates + Securities)
merge m:1 curcdq datadate using "$clean_data/currencies_monthly_clean.dta", keep(1 3) nogen

merge 1:1 gvkey datadate using "$clean_data/security_data_clean.dta", keep(1 3) nogen

order gvkey conm datacqtr datafqtr fyr fyearq loc atq capxy

save "$clean_data/compustat_global_incl_exr_and_security.dta", replace

// Import Compustat North America
use "$raw_data/compustat_northamerica.dta", clear

rename loc hq_cty
rename fic incorp_cty

// Keep only firms headquartered and incorporated in the USA or Canada
keep if ((hq_cty == "USA") & (incorp_cty == "USA") | (hq_cty == "CAN") & (incorp_cty == "CAN"))

// Merge exchange rate data
merge m:1 curcdq datadate using "$clean_data/currencies_monthly_clean.dta", keep(1 3) nogen

// Keep only relevant variables
keep gvkey fyearq hq_cty atq datacqtr datafqtr fyr fqtr naics conm capxy aqcy oibdpy ltq exratm

gen isin = ""
save "$clean_data/compustat_northamerica_incl_exr.dta", replace


********************************************************************************
**************************  2. BUILD MERGED DATASET  ***************************
********************************************************************************

// Import cleaned Compustat Global data
use "$clean_data/compustat_global_incl_exr_and_security.dta", clear

// Keep only relevant variables
keep gvkey fyearq datacqtr exratm loc isin atq datacqtr datafqtr fyr fqtr naics conm capxy aqcy oibdpy ltq 

// Keep only relevant countries 
rename loc hq_cty
keep if (hq_cty == "AUT" | hq_cty == "BEL" | hq_cty == "BUL" | hq_cty == "HRV" | hq_cty == "CYP" | hq_cty == "CZE" | hq_cty == "DNK" | hq_cty == "EST" | hq_cty == "FIN" | hq_cty == "FRA" | hq_cty == "DEU" | hq_cty == "GRC" | hq_cty == "HUN" | hq_cty == "IRL" | hq_cty == "ITA" | hq_cty == "LVA" | hq_cty == "LTU" | hq_cty == "LUX" | hq_cty == "MLT" | hq_cty == "NLD" | hq_cty == "POL" | hq_cty == "PRT" | hq_cty == "ROU" | hq_cty == "SVK" | hq_cty == "SVN" | hq_cty == "ESP" | hq_cty == "SWE" | hq_cty == "GBR" | hq_cty == "CHE" | hq_cty == "LIE" | hq_cty == "ISL" | hq_cty == "NOR" | hq_cty == "RUS" | hq_cty == "IND" | hq_cty == "CHN" | hq_cty == "AUS"  | hq_cty == "ZAF")

drop if isin == ""

// Append cleaned Compustat North America data
append using "$clean_data/compustat_northamerica_incl_exr.dta"

// Rename variables
rename conm company_name
rename capxy capex_qtly
rename aqcy acquisitions
rename oibdpy oibd
rename ltq tot_liabilities
rename atq tot_assets
rename datacqtr calendar_yrqt
rename datafqtr fiscal_yrqt
rename fyearq fiscal_yr
rename fyr fiscal_yr_end_month

// Remove duplicates
duplicates drop gvkey calendar_yrqt, force // based on calendar year
duplicates drop gvkey fiscal_yrqt, force // based on fiscal year

// Drop observations with missing total assets
drop if tot_assets >=.

// Define time variables
encode calendar_yrqt, gen(qrt_id)
drop if qrt_id >=.
label list qrt_id
encode fiscal_yrqt, gen(fisc_qrt_id)
label list fisc_qrt_id

encode gvkey, gen(gv_no)
encode hq_cty, gen(hq_cty_no)

// Identify extractive firms based on NAICS codes
gen naics2 = substr(naics,1,2)
gen naics3 = substr(naics,1,3)

gen extractive = 0
replace extractive = 1 if (naics2 == "21")
replace extractive = 1 if (naics3 == "324")
keep if extractive == 1

encode naics3, gen(naics3_no)


********************************************************************************
************************  3. PREPARE REGRESSION SAMPLE  ************************
********************************************************************************

// Merge EPD data
merge m:1 gvkey using "$raw_data/epd_masterfile.dta"
drop if _merge ==2

// Generate EPD effective quarter
gen effective_since_qrt = qofd(effective_since) if effective_since !=.

// Rebase quarters relative to start of sample
replace effective_since_qrt = effective_since_qrt - 198

// Manually add EPD dates for subsidiaries of reporting firms (that have different gvkeys as their parent company)
replace effective_since_qrt = 20 if (gvkey == "105595")
replace effective_since = td(01jul2014) if (gvkey == "105595")
replace report = 1 if (gvkey == "105595")

replace effective_since_qrt = 22 if (gvkey == "213127")
replace effective_since = td(01jan2015) if (gvkey == "213127")
replace report = 1 if (gvkey == "213127")

replace effective_since_qrt = 22 if (gvkey == "289282")
replace effective_since = td(01jan2015) if (gvkey == "289282")
replace report = 1 if (gvkey == "289282")

replace effective_since_qrt = 22 if (gvkey == "288747")
replace effective_since = td(01jan2015) if (gvkey == "288747")
replace report = 1 if (gvkey == "288747")

replace effective_since_qrt = 22 if (gvkey == "212085")
replace effective_since = td(01jan2015) if (gvkey == "212085")
replace report = 1 if (gvkey == "212085")

replace report = 0 if report ==.

// Generate EPD indicator
gen EPD = 0
replace EPD = 1 if (report == 1 & qrt_id >= effective_since_qrt & effective_since !=.)

// Convert firm fundamentals into GBP values
foreach var of varlist tot_assets capex_qtly oibd tot_liabilities {
   replace `var' = `var' / exratm
}

// Generate firm fundamentals
gsort gvkey fiscal_yrqt
by gvkey: gen tot_assets_lag1 = tot_assets[_n-1] if ((qrt_id[_n] == qrt_id[_n-1] + 1))

by gvkey: gen capex = (capex_qtly[_n] - capex_qtly[_n-1]) if (fiscal_yr[_n] == fiscal_yr[_n-1] & (fqtr == 2 | fqtr == 3 | fqtr == 4) & (fqtr[_n] == fqtr[_n-1] + 1))
replace capex = capex_qtly if (fqtr == 1)
drop if capex < 0

by gvkey: gen op_income = (oibd[_n] - oibd[_n-1]) if (fiscal_yr[_n] == fiscal_yr[_n-1] & (fqtr == 2 | fqtr == 3 | fqtr == 4) & (fqtr[_n] == fqtr[_n-1] + 1))
replace op_income = oibd if (fqtr == 1)

// Generate dependent variable
gen invest = capex / tot_assets_lag1

// Generate (non-lagged) control variables
gen ln_tot_assets = ln(tot_assets)
gen roa = op_income / tot_assets_lag1
gen leverage = tot_liabilities / tot_assets

// Trim variables
replace leverage =. if leverage < 0
winsor2 invest leverage, cuts(0 99) trim
winsor2 roa, cuts(1 99) trim

// Multiply dependent variable by 100
gen invest_tr_100 = invest_tr * 100

// Generate lagged variables
gsort gvkey fiscal_yrqt
foreach var of varlist invest_tr leverage_tr roa_tr ln_tot_assets {
	by gvkey: gen `var'_lag1 = `var'[_n-1] if ((fisc_qrt_id[_n] == fisc_qrt_id[_n-1] + 1))
}

// Define sample period (Q1-2010 to Q4-2017)
label list qrt_id
drop if qrt_id == 1 // Q4-2009
drop if qrt_id > 33 // > Q4-2017
tab qrt_id

// Generate firm fundamentals prior to EPD for Coarsened Exact Matching (CEM)
foreach var of varlist ln_tot_assets leverage_tr roa_tr tot_assets {
	gen `var'_mod = `var' if (qrt_id == 17)
	replace `var'_mod = 0 if (`var'_mod ==.)
	egen `var'_20131231 = max(`var'_mod), by(gvkey)
}

// Define fixed effects
egen industry_quarter_FE = group(naics3_no qrt_id)
egen country_quarter_FE = group(hq_cty_no qrt_id)
egen gvkey_no = group(gvkey)
egen treated = max(EPD), by(gvkey)
egen treated_quarter_FE = group(treated qrt_id)

// Label regression variables
lab var EPD "EPD"
lab var invest_tr "Parent Capex/Total Assets\textsubscript{t-1}"
lab var invest_tr_100 "Parent Capex/Total Assets\textsubscript{t-1} $\times$ 100"
lab var ln_tot_assets_lag1 "Ln(Total Assets\textsubscript{t-1})"
lab var roa_tr_lag1 "Return on Assets\textsubscript{t-1}"
lab var leverage_tr_lag1 "Leverage\textsubscript{t-1}"


// Save cleaned and merged parent capex analysis dataset
save "$final_data/parent_capex_analysis_clean_FINAL_new.dta", replace
********************************************************************************
******                                                                   *******
******   ARTICLE: Extraction Payment Disclosures                         *******
******   AUTHOR: Thomas Rauter                                           *******
******   JOURNAL OF ACCOUNTING RESEARCH                                  *******
******   CODE TYPE: Data Preparation for Bidding Participation Analysis  *******
******   LAST UPDATED: August 2020                                       *******
******                                                                   *******
********************************************************************************

clear all
set more off

global raw_data_new "$main_dir/05_New Analyses"


********************************************************************************
*********************** 1. CLEAN ENVERUS BIDDING DATA **************************
********************************************************************************

import excel "$raw_data_new/Hist_Bid_Blocks Africa.xlsx", sheet("Bid Data") firstrow allstring clear

// Define auction status
rename General_co general_comment
replace general_comment = upper(general_comment)

gen info_negotiation = 0
replace info_negotiation =  (strpos(general_comment, "NEGOTIATIONS") > 0)

gen info_pre_award= 0
replace info_pre_award = (strpos(general_comment, "PRE-AWARDED TO") > 0)

gen info_application = 0
replace info_application = (strpos(general_comment, "SUBMITTED APPLICATION") > 0)

gen info_award = 0
replace info_award = (strpos(general_comment, "AWARDED BLOCK") > 0)
replace info_award = 0 if (strpos(general_comment, "PRE-AWARDED") > 0) & info_award==1

gen info_rejection = 0
replace info_rejection = (strpos(general_comment, "REJECTED") > 0)

gen info_invitation = 0
replace info_invitation = (strpos(general_comment, "INVITED TO DISCUSS") > 0)

gen has_info_in_comment = 0
replace has_info_in_comment = info_negotiation + info_pre_award + info_application + info_award + info_rejection + info_invitation

// Drop auctions without any information on participants
drop if Bidding_Co=="n/a" & has_info_in_comment==0 | Bidding_Co=="No bid" & has_info_in_comment==0 | Bidding_Co=="No information post-round" & has_info_in_comment==0 | ///
Bidding_Co=="Unknown company in negotiation" & has_info_in_comment==0 | Bidding_Co=="" & has_info_in_comment==0

// Clean firm names
replace Bidding_Co = subinstr(Bidding_Co, "Pacific Oil & Gas", "Pacific Oil_Gas",.)
replace Bidding_Co = subinstr(Bidding_Co, "First E&P", "First E_P",.)
replace Bidding_Co = subinstr(Bidding_Co, "Sonangol P&P", "Sonangol P_P",.)

split Bidding_Co, p(".")
rename Bidding_Co Bidding_Co_Orig
rename Bidding_Co1 Bidding_Co
replace Bidding_Co2 = strtrim(Bidding_Co2) 
replace Bidding_Co2 = "" if Bidding_Co2=="No other bids"
split Bidding_Co2, p("also")
drop Bidding_Co22
split Bidding_Co21, p("," "and")
replace Bidding_Co211 = subinstr(Bidding_Co211, "Two additional bids by", "",.)
drop Bidding_Co2 Bidding_Co21

// Identify winning firms
gen winner = substr(Bidding_Co, 1, strpos(Bidding_Co, "winner") - 1)
replace winner = strtrim(winner) 
split winner, p("&")
drop winner
gen winner = substr(Bidding_Co, 1, strpos(Bidding_Co, "awarded") - 1)
replace winner1=winner if winner1==""
drop winner
rename winner1 winner_1
rename winner2 winner_2

// Identify other bidders
split Bidding_Co, p("&" " and " ",")
replace Bidding_Co1="" if (strpos(Bidding_Co, "winner") > 0) | (strpos(Bidding_Co, "awarded") > 0)
replace Bidding_Co2="" if (strpos(Bidding_Co, "winner") > 0) | (strpos(Bidding_Co, "awarded") > 0)
replace Bidding_Co2 = subinstr(Bidding_Co2, "understood to have submitted joint bid", "",.)

foreach n of numlist 1/7{
	replace Bidding_Co`n' = strtrim(Bidding_Co`n') 
	replace Bidding_Co`n'="" if Bidding_Co`n'=="n/a" | Bidding_Co`n'=="Unknown company in negotiations"
}

foreach m of numlist 1/5{
	replace Bidding_Co21`m'=Bidding_Co`m' if missing(Bidding_Co21`m')
	drop Bidding_Co`m'
}

rename Bidding_Co Bidding_Co_temp
	foreach v of numlist 1/5{
	rename Bidding_Co21`v' Bidding_Co_`v'
}

rename Bidding_Co6 Bidding_Co_6
rename Bidding_Co7 Bidding_Co_7
order Bidding_Co_6 Bidding_Co_7, before(winner_1)

// Manually add any remaining bidders
replace Bidding_Co_3 = "Shell" if general_comment=="AWARDED TO NOBLE ENERGY EVEN THOUGH BLOCK WAS NEVER FEATURED ON LIST OF BLOCKS UNDER NEGOTIATIONS. SHELL WAS ALSO NEGOTIATING FOR BLOCK"
replace Bidding_Co_3 = "Tullow" if general_comment=="BLOCK AVAILABLE VIA COMPETITIVE BIDDING. 15 OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DIRECT NEGOTIATIONS, 1 TO GNPC. 21 JAN 19 14 COMPANIES PRE-QUALIFIED. 21 MAY 19 ENI, VITOL & TULLOW SUBMIT BIDS FOR BLOCK 3"
replace Bidding_Co_2 = "Clontarf" if Block_ID=="1916000059" | Block_ID=="1916000061"
replace Bidding_Co_2 = "" if general_comment=="BLOCK AVAILABLE VIA COMPETITIVE BIDDING. 15 OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DIRECT NEGOTIATIONS, 1 TO GNPC. 21 JAN 19 14 COMPANIES PRE-QUALIFIED. 21 MAY 19 FIRST E&P ONLY BIDDER FOR BLOCK 2"

// Drop variables that are not used
keep Block_name Block_ID Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig Onlyonecompany Clearifallbiddersrevealed general_comment Country_IS BidRoundSt info_negotiation info_pre_award info_application info_award info_rejection info_invitation has_info_in_comment Bidding_Co_temp Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 winner_1 winner_2

// Identify auctions without information on winners and other bidders
gen no_winners_no_bidders = 0
replace no_winners_no_bidders = 1 if Bidding_Co_1=="" & Bidding_Co_2=="" & Bidding_Co_3=="" & Bidding_Co_4=="" & Bidding_Co_5=="" & Bidding_Co_6=="" & Bidding_Co_7=="" & winner_1=="" & winner_2=="" 

// Extract information on winning and bidding firms from comments if "Bidding_Co" variable is empty 
preserve 
keep if Bidding_Co_Orig=="n/a" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="No bid" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="No information post-round" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="Unknown company in negotiation" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="Unknown company in negotiations" & has_info_in_comment!=0 & no_winners_no_bidders==1

drop Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 winner_1 winner_2
drop if general_comment=="COMPANIES NOT ALREADY PRESENT IN EG MUST PRE-QUALIFY, PRE-QUALIFICATION DOCUMENT TO BE SUBMITTED BY 15/09/2014. DATAROOM OPEN IN UK FROM 01/07/2014 BY APPOINTMENT. NEGOTIATIONS HELD BUT NO AWARD FOLLOWING BID ROUND" | ///
general_comment=="BLOCK AVAILABLE VIA DIRECT NEGOTIATIONS (DN). OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DN, 1 TO GNPC. JAN 19 14 COMPANIES PRE-QUALIFIED. MAY 19 16 APPLICATIONS RECEIVED FOR DN FOR BLOCKS 5 & 6, EXXON & BP WITHDREW APPLICATIONS"

split general_comment, p(".")
drop general_comment2 general_comment5
gen bidders = substr(general_comment4, strpos(general_comment4, "APPLICATION BY") + 15,  .) if (strpos(general_comment4, "APPLICATION BY")>0)
split bidders, p(",")
drop bidders bidders2 general_comment4
gen bidders2 = substr(general_comment3, 1, strpos(general_comment3, "INVITED TO DISCUSS") - 1)
drop general_comment3
split general_comment1, p("(")

gen other_bidders=""
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "SUBMITTED") - 1)
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "REJECTED") - 1) if missing(other_bidders)
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "NEGOTIATION") - 1) if missing(other_bidders)

replace other_bidders=subinstr(other_bidders, "WAS IN", "",.)
replace other_bidders=subinstr(other_bidders, "WERE IN", "",.)
split other_bidders, p("&")
drop general_comment12 other_bidders
rename other_bidders1 bidders3
rename other_bidders2 bidders4

gen other_bidders = substr(general_comment1, 1, strpos(general_comment1, "IN NEGOTIATION") - 1)
replace other_bidders=subinstr(other_bidders, "WAS", "",.)
replace other_bidders=subinstr(other_bidders, "WERE", "",.)
split other_bidders, p("&")
drop other_bidders
replace other_bidders1 = "" if (strpos(other_bidders1, "AWARDED")>0)
replace other_bidders1 = strtrim(other_bidders1) 
replace other_bidders2 = strtrim(other_bidders2) 

gen other_winners = substr(general_comment11, strpos(general_comment11, "PRE-AWARDED TO") + 15, .) if (strpos(general_comment1, "PRE-AWARDED TO") >0)
replace other_winners = substr(general_comment11, 1, strpos(general_comment11, "AWARDED") - 1) if missing(other_winners) & (strpos(general_comment11, "AWARDED") >0)
replace other_winners = strtrim(other_winners) 
replace other_winners = "IMPACT OIL_GAS" if other_winners=="JAN 2014: IMPACT OIL & GAS OFFERED RIGHT TO NEGOTIATE BLOCK AS PART OF 2013 LICENSING ROUND AND SUBSEQUENTLY"
replace other_winners = "TOTAL" if general_comment11=="MARATHON WAS  IN NEGOTIATIONS FOR BLOCK, REJECTED IN FAVOUR OF TOTAL"

split other_winners, p("&")
drop other_winners
replace other_winners1 = strtrim(other_winners1) 
replace other_winners2 = strtrim(other_winners2) 
drop general_comment11

gen Bidding_Co_1=""
replace Bidding_Co_1=bidders1
replace Bidding_Co_1=bidders2 if missing(Bidding_Co_1)
replace Bidding_Co_1=bidders3 if missing(Bidding_Co_1)

drop bidders1 bidders2 bidders3
rename other_bidders1 Bidding_Co_2
replace bidders4 = other_bidders2 if missing(bidders4)
drop other_bidders2
rename bidders4 Bidding_Co_3
rename other_winners1 winner_1
rename other_winners2 winner_2

tempfile info_recovered
save `info_recovered'
restore

// Drop auctions without any information on winners and other bidders after checking comments
drop if Bidding_Co_Orig=="n/a" & has_info_in_comment!=0 & no_winners_no_bidders==1 | Bidding_Co_Orig=="No bid" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
		Bidding_Co_Orig=="No information post-round" & has_info_in_comment!=0 & no_winners_no_bidders==1 | Bidding_Co_Orig=="Unknown company in negotiation" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
		Bidding_Co_Orig=="Unknown company in negotiations" & has_info_in_comment!=0 & no_winners_no_bidders==1

append using `info_recovered'
drop no_winners_no_bidders

gen no_winners_no_bidders = 0
replace no_winners_no_bidders=1 if Bidding_Co_1=="" & Bidding_Co_2=="" & Bidding_Co_3=="" & Bidding_Co_4=="" & ///
Bidding_Co_5=="" & Bidding_Co_6=="" & Bidding_Co_7=="" & winner_1=="" & winner_2=="" 
drop if no_winners_no_bidders==1 & has_info_in_comment==1
drop general_comment1 no_winners_no_bidders

foreach n of numlist 1/7 {
replace Bidding_Co_`n' = strtrim(Bidding_Co_`n') 
}
replace winner_1 = strtrim(winner_1)
replace winner_2 = strtrim(winner_2)

// Save identified bidders in one variable
gen all_bidders = Bidding_Co_1 + "/" + Bidding_Co_2 + "/" + Bidding_Co_3 + "/" + Bidding_Co_4 + "/" +Bidding_Co_5 + "/" + Bidding_Co_6 + "/" + Bidding_Co_7 + "/" + winner_1 + "/" + winner_2

forval n=1/5 {
	replace all_bidders = subinstr(all_bidders, "//", "/",.) 
}

gen all_bidders2 = all_bidders
replace all_bidders2 = substr(all_bidders, 2, .) if substr(all_bidders, 1, 1)== "/"
split all_bidders2, p("/")

drop Bidding_Co_temp Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 all_bidders ///
all_bidders2 info_negotiation info_pre_award info_application info_award info_rejection info_invitation has_info_in_comment

foreach m of numlist 1/7 {
	rename all_bidders2`m' bidder_`m'
}

// Replace name of Statoil with correct/new company name (Equinor)
foreach v in winner_1 winner_2 bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7 {
	replace `v'="Equinor" if `v'=="Statoil"
}

foreach v in winner_1 winner_2 bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7 {
	replace `v'="IMPACT" if `v'=="IMPACT OIL_GAS"
}

// Add manually-collected information
replace bidder_3 = "Total" if Block_ID =="1943000009" | Block_ID =="1943000010"
replace bidder_4 = "Galp" if Block_ID =="1943000009" | Block_ID =="1943000010"
replace bidder_2 = "Rift Energy" if Block_ID =="1956000004"
replace bidder_3 = "Total" if Block_ID =="1920000071"
replace bidder_3 = "Noble Energy" if Block_ID =="1920000077"
replace bidder_3 = "Shell" if Block_ID =="1920000061"

// Save cleaned bidding data
preserve
keep Block_name Block_ID Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ ///
Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig ///
general_comment Onlyonecompany Clearifallbiddersrevealed Country_IS BidRoundSt
save "$clean_data/bidding_hist_temp.dta", replace
restore


********************************************************************************
***********************  2. BUILD REGRESSION DATASET  **************************
********************************************************************************

// Extract and save data on winning firms
preserve
keep Block_ID winner_1 winner_2
reshape long winner_ , i(Block_ID) j(winning_company)
rename winner_ winner
drop if missing(winner)
merge m:1 Block_ID using "$clean_data/bidding_hist_temp.dta", keep(1 3) nogen
rename winner bidder
tempfile winners
save `winners'
restore

// Reshape data to level of bidding company
keep Block_ID bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7
reshape long bidder_ , i(Block_ID) j(bidding_company)
rename bidder_ bidder
drop if missing(bidder)

merge m:1 Block_ID using "$clean_data/bidding_hist_temp.dta", keep(1 3) nogen

merge 1:1 Block_ID bidder using `winners', nogen

replace winning_company = 0 if missing(winning_company)
replace winning_company = 1 if winning_company > 1

sort Block_ID bidding_company
gen count_bids = 1
bys Block_ID: egen bids_no = sum(count_bids)
bys Block_ID: egen winners_no = sum(winning_company)

gen multiple_winners = 0
replace multiple_winners = 1 if winners_no > 1
gen company_standardized = upper(bidder)

* Clean company names for merging with company HQ data
replace company_standardized = "AFRICA OIL" if company_standardized == "AFRICA OIL CORP"
replace company_standardized = "OPHIR ENERGY" if company_standardized == "OPHIR"
replace company_standardized = "REPSOL" if company_standardized == "REPSOL YPF"
replace company_standardized = "ROSNEFT OIL COMPANY" if company_standardized == "ROSNEFT"
replace company_standardized = "ROYAL DUTCH SHELL" if company_standardized == "SHELL"
replace company_standardized = "ENEL" if company_standardized == "ENEL POWER"
replace company_standardized = "KOSMOS" if company_standardized == "KOSMOS ENERGY"
replace company_standardized = "EQUINOR" if company_standardized == "STATOIL"
replace company_standardized = "NOBLE ENERGY" if company_standardized == "NOBLE"

* Align company names in EPD file
preserve
use "$clean_data/participant_EPD_clean.dta", clear
keep participantintname hq_country
rename participantintname company_standardized
replace company_standardized = upper(company_standardized)
duplicates drop company_standardized, force
drop if company_standardized=="NOT OPERATED"

replace company_standardized = "AFRICA ENERGY CORP" if company_standardized=="AFRICA ENERGY"
replace company_standardized = "AFRICA OIL" if company_standardized=="AFRICA OIL & GAS"
replace company_standardized = "DRAGON OIL" if company_standardized=="DRAGON"
replace company_standardized = "EDF (EDISON)" if company_standardized=="EDF"
replace company_standardized = "ENEL POWER" if company_standardized=="ENEL"
replace company_standardized = "FIRST E_P" if company_standardized=="FIRST E&P"
replace company_standardized = "GDF-SUEZ" if company_standardized=="ENGIE"
replace company_standardized = "HIBISCUS PETROLEUM JV" if company_standardized=="HIBISCUS"
replace company_standardized = "MEDITERRA ENERGY" if company_standardized=="MEDITERRA"
replace company_standardized = "MERLON INTERNATIONAL" if company_standardized=="MERLON"
replace company_standardized = "NEPTUNE ENERGY" if company_standardized=="NEPTUNE"
replace company_standardized = "NOBLE ENERGY" if company_standardized=="NOBLE"
replace company_standardized = "OPHIR ENERGY" if company_standardized == "OPHIR"
replace company_standardized = "ORANTO" if company_standardized=="ATLAS ORANTO"
replace company_standardized = "PURAVIDA" if company_standardized=="PURA VIDA"
replace company_standardized = "ROSNEFT OIL COMPANY" if company_standardized == "ROSNEFT"
replace company_standardized = "ROYAL DUTCH SHELL" if company_standardized == "SHELL"
replace company_standardized = "SONANGOL P_P" if company_standardized=="SONANGOL"
replace company_standardized = "SONTRACH" if company_standardized=="SONATRACH"
replace company_standardized = "TOWER RESOURCES" if company_standardized=="TOWER"
replace company_standardized = "TRIDENT" if company_standardized=="TRIDENT PETROLEUM"
replace company_standardized = "VEGA PETROLEUM" if company_standardized=="VEGA"
replace company_standardized = "WOODSIDE ENERGY" if company_standardized=="WOODSIDE"
replace company_standardized = "ENEL" if company_standardized == "ENEL POWER"

tempfile EPD_hq
save `EPD_hq'
restore 

// Merge HQ information and EPD effective dates
merge m:1 company_standardized using `EPD_hq', keep(1 3) nogen

replace company_standardized = subinstr(company_standardized, "_", "&",.)
replace company_standardized = "EDF - EDISON" if company_standardized == "EDF (EDISON)"
replace company_standardized = "KOSMOS ENERGY" if company_standardized=="KOSMOS"

// Merge with EPD masterfile
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keep(1 3)

// Generate date of bidding
split Bid_Round_, p("/")
drop Bid_Round_1 Bid_Round_2
rename Bid_Round_3 bid_round_year
destring bid_round_year, replace

split Bid_Round_, p("/")
foreach n of numlist 1/9{
	replace Bid_Round_1="0`n'" if Bid_Round_1=="`n'"
	replace Bid_Round_2="0`n'" if Bid_Round_2=="`n'"
}

gen bid_round_date = Bid_Round_1 + "\" + Bid_Round_2 + "\" + Bid_Round_3
gen date = date(bid_round_date,"MDY")
format date %td
drop bid_round_date Bid_Round_1 Bid_Round_2 Bid_Round_3
rename date bid_round_date

// Save all bidder information in one dataset
preserve
duplicates drop company_standardized, force
sort company_standardized Block_ID
keep company_standardized effective_since part_of_annual_report number_of_pages ///
direct_to_consumer_market attestation_reporting_entity attestation_independent_audit hq_country ///
student ticker_not_sure reporting_issue report
save "$clean_data/all_bidders.dta", replace
restore

// Span bidder-auction panel
local blocks 1301000017 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 ///
1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 ///
1301000041 1301000042 1301000043 1301000044 1301000045 1301000048 1301000060 1301000061 1301000062 1301000068 1301000070 ///
1301000073 1315000507 1315000508 1315000510 1315000511 1315000514 1315000516 1315000518 1315000519 1315000532 1315000536 ///
1315000537 1315000538 1315000553 1315000554 1315000578 1315000579 1315000584 1315000588 1315000594 1315000601 1315000604 ///
1315000607 1315000609 1315000612 1315000616 1315000618 1315000619 1315000643 1315000664 1315000667 1315000669 1315000670 ///
1315000672 1315000676 1315000677 1315000683 1315000684 1315000687 1315000692 1315000695 1315000698 1315000713 1315000714 ///
1902000237 1907000009 1907000012 1907000027 1907000028 1911000050 1911000053 1911000056 1911000059 1916000024 1916000028 ///
1916000033 1916000034 1916000059 1916000061 1920000048 1920000049 1920000050 1920000051 1920000056 1920000061 1920000062 ///
1920000063 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000078 1920000080 1920000081 1920000082 ///
1920000084 1920000085 1921000002 1921000003 1937000673 1937000674 1937000676 1937000677 1937000682 1937000683 1937000686 ///
1943000009 1943000010 1952000004 1956000000 1956000001 1956000002 1956000003 1956000004

local block_vars "Block_ID Block_name Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig general_comment Onlyonecompany Clearifallbiddersrevealed Country_IS BidRoundSt count_bids bids_no winners_no multiple_winners bid_round_year bid_round_date"

foreach b of local blocks {
preserve
keep if Block_ID=="`b'"
drop _merge
append using "$clean_data/all_bidders.dta"
duplicates tag company_standardized, gen(dup)
drop if dup==1 & missing(Block_ID)
replace bidding_company=0 if missing(bidding_company)
foreach v of local block_vars{
replace `v'=`v'[1]
}
tempfile block_`b'
save `block_`b''
restore
}

local blocks2 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 ///
1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 ///
1301000041 1301000042 1301000043 1301000044 1301000045 1301000048 1301000060 1301000061 1301000062 1301000068 1301000070 ///
1301000073 1315000507 1315000508 1315000510 1315000511 1315000514 1315000516 1315000518 1315000519 1315000532 1315000536 ///
1315000537 1315000538 1315000553 1315000554 1315000578 1315000579 1315000584 1315000588 1315000594 1315000601 1315000604 ///
1315000607 1315000609 1315000612 1315000616 1315000618 1315000619 1315000643 1315000664 1315000667 1315000669 1315000670 ///
1315000672 1315000676 1315000677 1315000683 1315000684 1315000687 1315000692 1315000695 1315000698 1315000713 1315000714 ///
1902000237 1907000009 1907000012 1907000027 1907000028 1911000050 1911000053 1911000056 1911000059 1916000024 1916000028 ///
1916000033 1916000034 1916000059 1916000061 1920000048 1920000049 1920000050 1920000051 1920000056 1920000061 1920000062 ///
1920000063 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000078 1920000080 1920000081 1920000082 ///
1920000084 1920000085 1921000002 1921000003 1937000673 1937000674 1937000676 1937000677 1937000682 1937000683 1937000686 ///
1943000009 1943000010 1952000004 1956000000 1956000001 1956000002 1956000003 1956000004

local blocks
use `block_1301000017', clear
foreach b of local blocks2 {
	append using `block_`b''
}
drop dup count_bids


// Clean variables
replace bidder="Not a bidder" if missing(bidder)
replace report=0 if report==.
replace company_standardized="SONATRACH" if company_standardized=="SONTRACH"

gen company_HC_type=company_standardized
replace company_HC_type = "EDF" if company_standardized=="EDF - EDISON"
replace company_HC_type = "AFRICA ENERGY" if company_standardized=="AFRICA ENERGY CORP"
replace company_HC_type = "KNOC" if company_standardized=="DANA PETROLEUM"
replace company_HC_type = "ACR" if company_standardized=="ACREP"
replace company_HC_type = "DEA" if company_standardized=="DEA EGYPT"
replace company_HC_type = "ENOC" if company_standardized=="DRAGON OIL"
replace company_HC_type = "EDF" if company_standardized=="EDF - EDISON"
replace company_HC_type = "EDF" if company_standardized=="EDISON" & bid_round_year>=2012
replace company_HC_type = "IMPACT" if company_standardized=="IMPACT OIL&GAS"
replace company_HC_type = "IOCL" if company_standardized=="INDIAN OIL"
replace company_HC_type = "KOSMOS" if company_standardized=="KOSMOS ENERGY"
replace company_HC_type = "MEDITERRA" if company_standardized=="MEDITERRA ENERGY"
replace company_HC_type = "MERLON" if company_standardized=="MERLON INTERNATIONAL"
replace company_HC_type = "NOBLE" if company_standardized=="NOBLE ENERGY"
replace company_HC_type = "OPHIR" if company_standardized=="OPHIR ENERGY"
replace company_HC_type = "ATLAS ORANTO" if company_standardized=="ORANTO"
replace company_HC_type = "PURA VIDA" if company_standardized=="PURAVIDA"
replace company_HC_type = "ROSNEFT" if company_standardized=="ROSNEFT OIL COMPANY"
replace company_HC_type = "SONANGOL" if company_standardized=="SONANGOL P&P"
replace company_HC_type = "SONATRACH" if company_standardized=="SONTRACH"
replace company_HC_type = "EQUINOR" if company_standardized=="STATOIL"
replace company_HC_type = "TOWER" if company_standardized=="TOWER RESOURCES"
replace company_HC_type = "TRIDENT ENERGY" if company_standardized=="TRIDENT"
replace company_HC_type = "WOODSIDE" if company_standardized=="WOODSIDE ENERGY"

// Merge data on main hydrocarbon type at bidding-company level 
preserve
use "$main_dir/01_Clean_Data/mainHC_type.dta", clear
replace participantintname=upper(participantintname)
rename participantintname company_HC_type
drop if company_HC_type=="NOT OPERATED"
replace company_HC_type="ROYAL DUTCH SHELL" if company_HC_type=="SHELL"
duplicates drop company_HC_type, force
tempfile main_resource_type
save `main_resource_type'
restore

merge m:1 company_HC_type using `main_resource_type', keep(1 3)

// Manually add missing HQ country information
replace hq_country = "Angola" if company_standardized=="ACREP"
replace hq_country = "Australia" if company_standardized=="ARMOUR"
replace hq_country = "United States" if company_standardized=="ASPECT"
replace hq_country = "Switzerland" if company_standardized=="BLUEGREEN"
replace hq_country = "United States" if company_standardized=="COBALT"
replace hq_country = "South Korea" if company_standardized=="DANA PETROLEUM"
replace hq_country = "Germany" if company_standardized=="DEA EGYPT"
replace hq_country = "Germany" if company_standardized=="DELONEX ENERGY"
replace hq_country = "France" if company_standardized=="EDISON"
replace hq_country = "Ghana" if company_standardized=="ELANDEL ENERGY"
replace hq_country = "United Kingdom" if company_standardized=="ELENILTO"
replace hq_country = "Mozambique" if company_standardized=="ENH"
replace hq_country = "United States" if company_standardized=="GLINT"
replace hq_country = "United Kingdom" if company_standardized=="IMPACT OIL&GAS"
replace hq_country = "India" if company_standardized=="INDIAN OIL"
replace hq_country = "Mozambique" if company_standardized=="INDICO"
replace hq_country = "Egypt" if company_standardized=="KIERON MAGAWISH"
replace hq_country = "Nigeria" if company_standardized=="LEVENE ENERGY"
replace hq_country = "Singapore" if company_standardized=="PACIFIC OIL&GAS"
replace hq_country = "Portugal" if company_standardized=="PARTEX"
replace hq_country = "Thailand" if company_standardized=="PTTP"
replace hq_country = "United Kingdom" if company_standardized=="SEA DRAGON"
replace hq_country = "Tanzania" if company_standardized=="SWALA"
replace hq_country = "Ireland" if company_standardized=="CLONTARF"
replace hq_country = "Canada" if company_standardized=="RIFT ENERGY"
replace hq_country = "Nigeria" if company_standardized=="OFFSHORE EQUATOR PLC"

// Final clean up of bidding company and HQ variables
replace bidder = subinstr(bidder, "_", "&", .)
replace bidder = subinstr(bidder, "Sontrach", "Sonatrach", .)
replace hq_country = "Australia" if hq_country=="Austalia"
replace hq_country = strtrim(hq_country)

// Only keep auctions for which there is evidence that all bidding companies are included (after online cross validations)
local keep "1301000048 1301000060 1301000061 1301000062 1301000070 1301000073 1315000612 1315000664 1315000683 1315000684 1315000714 1921000002 1921000003 1937000683 1956000000 1956000001 1956000002 1956000003 1956000004 1920000061 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000080 1920000084 1920000085 1301000017 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 1301000041 1301000042 1301000043 1301000044 1301000045 1301000068 1916000059 1916000061 1920000078 1943000009 1943000010 1920000050 1920000051 1920000056 1920000062 1920000081 1920000082"
gen keep=0

foreach k in `keep'{
replace keep=1 if Block_ID=="`k'"
}
keep if keep==1

// Generate "Submitted Bid" indicator
gen active_bidder = ""
replace active_bidder = "YES" if bidder != "Not a bidder"
replace active_bidder = "NO" if bidder == "Not a bidder"

gen submitted_bid = 0
replace submitted_bid = 1 if active_bidder=="YES"
lab var submitted_bid "Company Submitted Bid for Auction"

// Generate EPD treatment indicator
gen EPD=0
replace EPD = 1 if bid_round_date >= effective_since & bid_round_date <.
gen EPD_submitted_bid = submitted_bid * report
gen EPD_effective_yr=year(effective_since) 

// Generate "Number of Bids per Auction" variable
bys Block_ID: egen bids_per_auction = total(submitted_bid)
bys Block_ID: egen EPD_bids_per_auction = total(EPD_submitted_bid)
gen non_EPD_bids_per_auction = bids_per_auction - EPD_bids_per_auction
gen EPD_bids_per_auction_pct = EPD_bids_per_auction/bids_per_auction*100
gen non_EPD_bids_per_auction_pct = non_EPD_bids_per_auction/bids_per_auction*100

// Quantify bidding activity by firm
gen sub_bid = submitted_bid
bys company_standardized: egen bid_activity = sum(sub_bid)

// Drop firms that never submitted any bid
drop if bid_activity == 0

// Define regression sample
keep if bid_round_year >= 2010

// Generate control variables
rename Contract_t contract_type
replace contract_type=strtrim(contract_type)
gen exploration=0
replace exploration = 1 if contract_type=="Exploration"
destring Block_Area, replace
gen ln_block_size = ln(Block_Area)
*gen post_EPD = 0
*replace post_EPD = 1 if bid_round_year > 2013

// Generate fixed effects
egen year_FE = group(bid_round_year)
egen firm_FE = group(company_standardized)
egen treated_FE = group(report)
egen treated_year_FE = group(report bid_round_year)
egen resourcetype_FE = group(main_hc_type)
egen resourcetype_year_FE = group(main_hc_type bid_round_year)
egen host_country_FE = group(Country_IS)
egen hq_country_FE = group(hq_country)

// Label regression variables
lab var EPD "EPD"
lab var submitted_bid "Firm Submitted Bid"
lab var submitted_bid "Submitted Bid"
lab var bids_per_auction "Tot. bids received for auction X"
lab var EPD_bids_per_auction "Tot. bids received from EPD firms"
lab var non_EPD_bids_per_auction "Tot. bids received from Non-EPD firms"
lab var exploration "Exploration"
lab var ln_block_size "Ln(Size of Oil \& Gas Block)"
lab var Block_ID "Enverus Block ID"
lab var On_Offshor "License for On- vs. Offshore Block"
lab var contract_type "License Type Being Awarded"
lab var Block_Area "Size of Block in sqkm"
lab var Country_IS "2-digit ISO code of Country where Block is located"
lab var company_standardized "Standardized Name of Bidding Firm"
lab var hq_country "Headquarter Country of Bidding Firm"
lab var effective_since "Firm is subject to EPD regulation since - Date" 
lab var bid_round_year "Year of Block Auction"
lab var bid_round_date "Date of Block Auction"
lab var main_hc_type "Main Hydrocarbon Extracted by Firm"
lab var bid_activity "Total Bids Sumbitted by Firm"
lab var EPD_effective_yr "Firm is subject to EPD regulation since - Year" 
lab var EPD_bids_per_auction_pct "Pct of Bids received by Firms subject to EPD"
lab var non_EPD_bids_per_auction_pct "Pct of Bids received by Firms never subject to EPD"
lab var post_EPD "Post EPD Period (2014 and after)"


// Save cleaned and merged bidding behaviour dataset
save "$final_data/bidding_behaviour_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******   ARTICLE: Extraction Payment Disclosures                         *******
******   AUTHOR: Thomas Rauter                                           *******
******   JOURNAL OF ACCOUNTING RESEARCH                                  *******
******   CODE TYPE: Data Preparation for Oil and Gas Licensing Analysis  *******
******   LAST UPDATED: August 2020                                       *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "licensing"


********************************************************************************
**********************  1. BUILD FIRM-COUNTRY-YEAR PANEL ***********************
********************************************************************************

// Import block data (unique at blockid level)
import delimited "$raw_data/BlocksTable.CSV", clear 

// Keep major blocks
keep if areasqkm >= 1000

// Reshape data to block-participant level
rename operatorlocalname participant0localname
rename operatorintname participant0intname
rename operatorwi participant0wi

forvalues i=0/6 {
	rename participant`i'localname participantlocalname`i'
	rename participant`i'intname participantintname`i'
	rename participant`i'wi participantwi`i'
	}

reshape long participantlocalname participantintname participantwi, i(blockid) j(participant_number)
drop if participantlocalname=="" & participantintname=="" & participantwi==.

// Check if data is unique at block id-participant level
isid blockid participant_number

save "$clean_data/oil_block_participant.dta", replace

// Generate key dates
generate award_date=date(awarddate, "YMD")
format award_date %td
generate year=year(award_date)

generate expiry_date=date(expirydate, "YMD")
format expiry_date %td
generate expiry_year=year(expiry_date)

// Generate participant id
replace participantlocalname="Unknown" if participantlocalname==""
egen participantID=group(participantintname participantlocalname)

generate number_blocks_opened = 1

// Add time and country dimensions
fillin participantintname country year
	
// Identify earliest year participant had block in given country
bys participantintname country: egen min_award_date=min(award_date)
format min_award_date %td
label variable min_award_date "Earliest award date for participant-country"

// Identify latest year participant had block in given country
bys participantintname country: egen max_expiry_date=max(expiry_date)
format max_expiry_date %td
label variable max_expiry_date "Latest expiry date for participant-country"
		
// Collapse to participant-country-year level
if "`version'"=="ID" local keep "participantlocalname participantintname"
collapse (sum) number_blocks_opened, by(participantintname country year min_award_date max_expiry_date  `keep')
isid participant`version' country year, missok
label variable number_blocks_opened "# blocks participant opened in that county-year"
		
// Identify whether participant ever had a block in the country
bys participantintname country: egen ever_had_block=max(number_blocks_opened>=1)
label variable ever_had_block "Participant-country appears in block dataset"

// Create an indicator = 1 for every year past award date
bys participantintname country: generate has_block=(year>=year(min_award_date) & year<=year(max_expiry_date)) if (min_award_date!=. & max_expiry_date!=.)
replace has_block=0 if ever_had_block==0
label variable has_block "Participant-country award date<=year"
		
// Create an indicator = 1 for block openings
generate any_blocks_opened=(number_blocks_opened>=1)
label variable any_blocks_opened "Dummy for 1+ block opening(s) by participant in that country-year"		

// Save firm-country-year panel
drop if year==.
order participant* country year min_award_date max_expiry_date has_block ever_had_block number_blocks_opened any_blocks_opened

save "$raw_data/oil_block_participantintname_country_year.dta", replace


********************************************************************************
***************************  2. CLEAN LICENSING DATA ***************************
********************************************************************************

import excel "$raw_data/operator_headquarters_merged.xlsx", clear sheet("Manual_merge_Formulas") cellrange(A1:P622) firstrow

// Unify manually-collected gvkeys
gen gvkey=""
replace gvkey=gvkey_HANNAH if gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_E=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_A if gvkey_HANNAH=="" & gvkey_VLOOKUP_E=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_E if gvkey_HANNAH=="" & gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_F if gvkey_HANNAH=="" & gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_E==""

global gvkey "gvkey_VLOOKUP_A gvkey_VLOOKUP_E gvkey_VLOOKUP_F gvkey_HANNAH"
foreach g of global gvkey{
	replace gvkey=`g' if gvkey=="" & `g'==gvkey_VLOOKUP_A | gvkey=="" & `g'==gvkey_VLOOKUP_E | gvkey=="" & `g'==gvkey_VLOOKUP_F
}

// Drop redundant variables
drop Modifications company FirstwordofFullName Firstwordofoperatorintname $gvkey

// Rename remaining variables
rename operatorintname participantintname
rename HeadquartersHannahFederica hq_country

// Clean firms' headquarter country
replace hq_country="Angola" if participantintname=="ACR" & hq_country=="Angola/ Mauritius"
replace hq_country="United Kingdom" if participantintname=="Global Connect" & hq_country=="British Virgin Islands/UK"
replace hq_country="Canada" if participantintname=="PetroSinai" & hq_country=="Canada/Egypt"
replace hq_country="Kuwait" if participantintname=="EASPCO" & hq_country=="Egypt/Kuwait"
replace hq_country="Egypt" if participantintname=="Mansoura" & hq_country=="Egypt??"
replace hq_country="Egypt" if participantintname=="EKH" & hq_country=="France/UK"
replace hq_country="United Kingdom" if participantintname=="Minexco OGG" & hq_country=="Gibraltar/UK"
replace hq_country="United Kingdom" if participantintname=="Rapetco" & hq_country=="Italy/UK (50/50)"
replace hq_country="United Kingdom" if participantintname=="BWEH" & hq_country=="Mauritania - BW Offshore/Bermuda - BW Offshore Limited/UK - Limited/Netherlands - Mgmt"
replace hq_country="Namibia" if participantintname=="Trago" & hq_country=="Namibia?"
replace hq_country="Netherlands" if participantintname=="West Sitra" & hq_country=="Netherlands/Egypt"
replace hq_country="United States" if participantintname=="Grasso Consortium" & hq_country=="Nigeria/USA" | participantintname=="Grasso" & hq_country=="Nigeria/USA"
replace hq_country="South Korea" if hq_country=="South Corea"
replace hq_country="United States" if participantintname=="NOPCO" & hq_country=="USA?"
replace hq_country="United Kingdom" if participantintname=="Chariot" & hq_country=="United Kingdom / Channel Islands"
replace hq_country="United Kingdom" if participantintname=="North El Burg" & hq_country=="United Kingdom /Italy"
replace hq_country="United Kingdom" if participantintname=="Equator Hydrocarbons" & hq_country=="United Kingdom/Nigeria"
replace hq_country="Yemen" if participantintname=="PEPA" & hq_country=="Yemen?"

replace participantintname="Shell" if participantintname=="Royal Dutch Shell"

replace EPD_effective_since=. if participantintname == "Africa Oil & Gas"
replace EPD_publication_date=. if participantintname == "Africa Oil & Gas"

save "$clean_data/participant_EPD_clean.dta", replace


********************************************************************************
************************  3. PREPARE REGRESSION SAMPLE *************************
********************************************************************************

// Merge licensing panel with EPD masterfile
use "$raw_data/oil_block_participantintname_country_year.dta", clear
merge m:1 participantintname using "$clean_data/participant_EPD_clean.dta"

// Drop unidentified firms
drop if participantintname=="Not Operated" | participantintname=="Not operated" | participantintname=="Unassigned" | participantintname=="Unknown"
drop if _merge == 2
drop if year==.

// Identify firms subject to EPD reporting      
gen EPD_effective_yr = year(EPD_effective_since) 
gen EPD_publication_yr = year(EPD_publication_date) 
gen EPD=0
bys participantintname year: replace EPD=1 if year >= EPD_effective_yr & EPD_effective_yr !=.
bys participantintname year: replace EPD=0 if EPD_effective_yr==.
drop _merge
rename FullName participant_full_name

// Clean host country names
replace country = "Tunisia" if country == "Libya-Tunisia JEZ"
replace country = "Senegal" if country == "S-GB AGC"
replace country = "Nigeria" if country == "Sao Tome & Nigeria"

// Generate ISO codes for (i) host countries and (ii) HQ countries
kountry country, from(other) stuck marker
rename _ISO3N_ iso_n
kountry iso_n, from(iso3n) to(iso3c) 
rename _ISO3C_ iso
kountry hq_country, from(other) stuck 
rename _ISO3N_ iso_n_hq
kountry iso_n_hq, from(iso3n) to(iso3c) 
rename _ISO3C_ iso_hq

// Clean and merge data on firms' main hydrocarbon
preserve
use "$raw_data/oil_block_participant.dta", clear

gen oil = 0
gen gas = 0

gen gas_and_oil = 0
replace oil = 1 if hydrocarbontype=="Oil"
replace gas = 1 if hydrocarbontype=="Gas and Condensate"
replace gas = 1 if hydrocarbontype=="Gas"
replace gas_and_oil = 1 if hydrocarbontype=="Oil and Gas" 

collapse (sum) oil gas gas_and_oil, by (participantintname)

gen only_oil=0
gen only_gas=0
gen mix_gas_and_oil=0
replace only_oil=1 if oil>0 & gas==0 & gas_and_oil==0
replace only_gas=1 if gas>0 & oil==0 & gas_and_oil==0
replace mix_gas_and_oil=1 if gas_and_oil>0 
replace mix_gas_and_oil=1 if gas_and_oil==0 & oil>0 & gas>0

gen main_hc_type=""
replace main_hc_type="Only oil" if only_oil==1
replace main_hc_type="Only gas" if only_gas==1
replace main_hc_type="Oil and Gas" if mix_gas_and_oil==1
drop oil gas gas_and_oil only_oil only_gas mix_gas_and_oil

save "$clean_data/mainHC_type.dta", replace
restore
 
merge m:1 participantintname using "$clean_data/mainHC_type.dta", keep(1 3)

// Define dependent variable
replace any_blocks_opened = any_blocks_opened * 100

// Identify treatment group
bys participantintname: egen disclosing = max(EPD)

// Define sample period
keep if (year >= 2000 & year <= 2018)

// Create fixed effects
egen host_country_FE = group(iso)
egen host_country_year_FE = group(iso year)
egen resourcetype_year_FE = group(main_hc_type year)
egen treatment_year_FE = group(disclosing year)
egen hq_country_id = group(hq_country)

// Label regression variables
lab var EPD "EPD"
lab var any_blocks_opened "Obtained License $\times$ 100"

// Save cleaned and merged licensing dataset
save "$final_data/extensive_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******        ARTICLE: Extraction Payment Disclosures                    *******
******        AUTHOR: Thomas Rauter                                      *******
******        JOURNAL OF ACCOUNTING RESEARCH                             *******
******        CODE TYPE: Data Preparation for Productivity Analysis      *******
******        LAST UPDATED: August 2020                                  *******
******                                                                   *******
********************************************************************************

clear all
set more off


********************************************************************************
****************** 1. CLEAN ENVERUS ASSET-TRANSACTIONS DATA ********************
********************************************************************************

import delimited "$raw_data/AssetTransactionsFull.CSV", encoding(ISO-8859-1)clear 

// Prepare variables
rename country block_country
rename agreementdate agreement_date 
rename closedate closed_date 
rename effectivedate effective_date
rename blockname block_name
rename transactionstatus transaction_status
rename sellingentitylocalname seller_local_name
rename sellingentityintname seller_int_name
rename purchasingentityintname buyer_int_name
rename purchasingentitylocalname buyer_local_name
rename interestpurchased interest_purchased
rename blockid block_id_enverus
rename operatorchange operator_change

replace block_country = upper(block_country)
replace block_name = upper(block_name)
replace block_id_enverus = strtrim(block_id_enverus)

foreach phase in agreement closed effective {
	gen deal_`phase'_date = date(`phase'_date, "YMD")
	format deal_`phase'_date %td
}

// Generate date of asset transaction => pecking order: 1. effective, 2. closed, 3. agreement
gen deal_date_combined = deal_effective_date
replace deal_date_combined = deal_closed_date if missing(deal_date_combined)
replace deal_date_combined = deal_agreement_date if missing(deal_date_combined)
format deal_date_combined %td

gen deal_date_type = ""
replace deal_date_type = "Effective" if deal_date_combined == deal_effective_date
replace deal_date_type = "Closed" if deal_date_combined == deal_closed_date
replace deal_date_type = "Agreement" if deal_date_combined == deal_agreement_date

// Keep host countries with production data
keep if block_country =="ANGOLA" | block_country =="GHANA" | block_country =="MAURITANIA" | block_country =="NIGERIA" | ///
	block_country =="SENEGAL" | block_country =="TUNISIA"

// Keep deals with known deal date
drop if missing(deal_date_combined)

// Keep finalized deals that can impact production
keep if transaction_status == "Complete"

// Generate deal date variables
gen month = month(deal_date_combined)
gen year = year(deal_date_combined)
sort block_name year month

// Clean seller names
replace seller_int_name = upper(seller_int_name)
gen company_standardized = seller_int_name
replace company_standardized ="AKER BP" if seller_int_name=="AKER ENERGY"
replace company_standardized ="ENI" if seller_int_name=="ENI PETROLEUM CO., INC."
replace company_standardized ="SEPLAT PETROLEUM DEVELOPMENT COMPANY" if seller_int_name=="SEPLAT"
replace company_standardized ="SERINUS ENERGY" if seller_int_name=="SERINUS" | seller_int_name=="KULCZYK"
replace company_standardized ="ROYAL DUTCH SHELL" if seller_int_name=="SHELL"
replace company_standardized ="TULLOW OIL" if seller_int_name=="TULLOW"

// Identify EPD sellers
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keepusing(effective_since report)
rename company_standardized seller_standardized
rename effective_since effective_since_seller
rename report reporting_seller

replace reporting_seller = 0 if missing(reporting_seller)
drop if _merge==2
drop _merge

// Clean buyer names
replace buyer_int_name = upper(buyer_int_name)
gen company_standardized = buyer_int_name
replace company_standardized ="AKER BP" if buyer_int_name=="AKER ENERGY"
replace company_standardized ="ENI" if buyer_int_name=="ENI PETROLEUM CO., INC."
replace company_standardized ="SEPLAT PETROLEUM DEVELOPMENT COMPANY" if buyer_int_name=="SEPLAT"
replace company_standardized ="SERINUS ENERGY" if buyer_int_name=="SERINUS" | buyer_int_name=="KULCZYK"
replace company_standardized ="ROYAL DUTCH SHELL" if buyer_int_name=="SHELL"
replace company_standardized ="TULLOW OIL" if buyer_int_name=="TULLOW"

// Identify non-EPD buyers
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keepusing(effective_since report)
rename company_standardized buyer_standardized
rename effective_since effective_since_buyer
rename report reporting_buyer

replace reporting_buyer = 0 if missing(reporting_buyer)
drop if _merge==2
drop _merge 

// Clean-up specific block IDs based on feedback from ENVERUS
replace block_id_enverus = "1940000434" if block_name=="OML 71"
replace block_id_enverus = "1355000175" if block_name=="BENI KHALED" & block_id_enverus=="1355000245"

// Generate indicator for transactions with change in block operator
gen operator_changed=0
replace operator_changed = 1 if operator_change== "true"

// Generate indicator for transactions with EPD buyer (to be netted out at block level)
gen neutral_deal = 1
replace neutral_deal = 0 if reporting_buyer == 0

// Change sign of acquired share by EPD buyers (for netting out at block level)
replace interest_purchased = - interest_purchased if neutral_deal == 1

// Collapse license transactions at block-month level
sort block_name year month  
collapse (sum) interest_purchased operator_changed (min) neutral_deal, ///
by(block_id_enverus block_name deal_date_combined year month)

// Classify "temporary" transactions as non-treated because they are reversed right after deal closes
sort block_name year month
replace neutral_deal = 1 if block_name == "DIDON" & year==2015
replace interest_purchased = 0 if block_name == "DIDON" & year==2015 

replace neutral_deal = 1  if block_name == "EL JEM"
replace interest_purchased = 0 if block_name == "EL JEM" 

replace neutral_deal = 1 if block_name == "C-3"
replace interest_purchased = 0 if block_name == "C-3" 

replace neutral_deal = 1 if block_name == "OML 55" & deal_date_combined==td(05feb2015) | block_name == "OML 55" &  deal_date_combined==td(30jun2016)
replace interest_purchased = 0 if block_name == "OML 55" & deal_date_combined==td(05feb2015) | block_name == "OML 55" &  deal_date_combined==td(30jun2016)

gen month_date = ym(year, month) 
format month_date %tm

save "$clean_data/block_asset_transactions.dta", replace


********************************************************************************
********************** 2. CLEAN MONTHLY PRODUCTION DATA ************************
********************************************************************************

use "$clean_data/production_field_block_EPD.dta", clear

// Merge block and production data
merge 1:m field_name using "$raw_data/Production_monthly_field_well_level.dta", keep(1 3) nogen

// Generate production date variables
sort field_name MonthlyProductionDate
gen production_date = date(MonthlyProductionDate, "MDY")
format production_date %td
sort field_name production_date
gen month = month(production_date)
gen year = year(production_date)
sort block_name field_name year month

// Identify whether field and block operators are EPD reporting
gen EPD_field_operator = 0
replace EPD_field_operator = 1 if field_operator_reporting==1

gen EPD_block_operator = 0
replace EPD_block_operator = 1 if block_operator_reporting==1

// Drop variables that are not used
keep field_name block_name block_country contract_name tot_completed_wells area_block_sqkm operator_field_well block_operator ///
MonthlyProductionDate MonthlyOil MonthlyGas MonthlyWater WellCount Days DailyAvgOil DailyAvgGas DailyAvgWater WellNumber ProductionType ProductionStatus ///
ProducingMonthNumber production_date EPD_field_operator EPD_block_operator EntityType block_id_enverus year month Province ProducingMonthNumber

// Clean production variables
foreach v in DailyAvgOil DailyAvgGas MonthlyOil MonthlyGas area_block_sqkm WellCount ProducingMonthNumber {
	destring `v', replace
}
rename DailyAvgOil daily_avg_oil
rename DailyAvgGas daily_avg_gas
rename WellCount well_count
rename MonthlyOil monthly_oil
rename MonthlyGas monthly_gas
rename ProducingMonthNumber months_producing_since

// Drop observations with missing operator information
drop if operator_field_well == "NOT OPERATED"

// Since there is production data, there must be at least one well by definition
replace tot_completed_wells = 1 if tot_completed_wells==0  

// Generate total monthly output
gen tot_oilgas_output_month = monthly_oil
replace tot_oilgas_output_month = monthly_oil + monthly_gas if !missing(monthly_gas)
replace tot_oilgas_output_month = monthly_gas if missing(tot_oilgas_output_month)

// Generate average daily output
gen daily_avg_oil_gas = daily_avg_oil 
replace daily_avg_oil_gas = daily_avg_oil + daily_avg_gas if !missing(daily_avg_gas)
replace daily_avg_oil_gas = daily_avg_gas if missing(daily_avg_oil_gas)

// Normalize daily average output by (i) number of wells and (ii) area of block
gen daily_avg_oil_gas_per_well = daily_avg_oil_gas / well_count
gen daily_avg_oilgas_per_well_alt = daily_avg_oil_gas / tot_completed_wells
gen daily_avg_oilgas_per_sqkm = daily_avg_oil_gas / area_block_sqkm

// Generate indicators for hydrocarbon types
gen oil = 0
replace oil = 1 if !missing(daily_avg_oil)
gen gas = 0
replace gas = 1 if !missing(daily_avg_gas)

// Generate year-month variable
gen month_date = ym(year, month) 
format month_date %tm


********************************************************************************
*************** 3. AGGREGATE PRODUCTION DATA TO THE BLOCK LEVEL ****************
********************************************************************************
preserve

// Keep only field-level production data (to be aggregated at the block-level)
keep if EntityType=="FIELD"
encode field_name, gen(field_code)

// Tsset data at field-month level
tsset field_code month_date
tsfill

// Fill up field characteristics that are constant over time
local field_strings "field_name operator_field_well block_id_enverus block_name contract_name block_country block_operator Province EntityType"
local field_numeric "area_block_sqkm tot_completed_wells"

foreach s in `field_strings'{
	bys field_code (`s'): replace `s' = `s'[_N] if missing(`s')
}

foreach n in `field_numeric'{
	bys field_code (`n'): replace `n' = `n'[1] if missing(`n')
}

// Compute number of consecutive months for which production data is missing
bys field_code (month_date): gen spell = sum(missing(daily_avg_oilgas_per_well_alt) != missing(daily_avg_oilgas_per_well_alt[_n-1]))
bys field_code spell (month_date): gen spell_length = _N
bysort field_code (month_date) : gen seq = missing(daily_avg_oilgas_per_well_alt) & (!missing(daily_avg_oilgas_per_well_alt[_n-1]) | _n == 1) 
by field_code : replace seq = seq[_n-1] + 1 if missing(daily_avg_oilgas_per_well_alt) & seq[_n-1] >= 1 & _n > 1 
bys field_code spell: egen gap = max(seq)
bys field_code: egen largest_gap_field = max(gap)
bys block_id_enverus: egen largest_gap_block = max(largest_gap_field)

// Interpolate missing production data points (up to a maximum of 2 consecutive quarters)
rename tot_oilgas_output_month tot_oilgas_month
local interp_vars "tot_oilgas_month daily_avg_oilgas_per_well_alt months_producing_since"

foreach d in `interp_vars'{
	bys field_code (month_date): ipolate `d' month_date if gap <= 6, gen(`d'_ip)
}

// Identify blocks with data gaps larger than 2 consecutive quarters
gen blocks_excl_large_gaps = 0
replace blocks_excl_large_gaps = 1 if largest_gap_block > 6

save "$final_data/field_production_data_interpol_FINAL.dta", replace


// Aggregate monthly field-level production data to block level
collapse (mean) monthly_oil monthly_gas daily_avg_oilgas_per_well_alt daily_avg_oilgas_per_well_alt_ip months_producing_since months_producing_since_ip blocks_excl_large_gaps ///
(sum) tot_oilgas_month tot_oilgas_month_ip tot_completed_wells well_count (max) oil gas, ///
by(block_name block_id_enverus block_country area_block_sqkm block_operator month_date year month Province)

replace tot_oilgas_month=. if tot_oilgas_month==0 & missing(monthly_oil) & missing(monthly_gas)
replace tot_oilgas_month_ip=. if tot_oilgas_month_ip==0 & missing(monthly_oil) & missing(monthly_gas)

tempfile field_production_data
save `field_production_data'
restore

// Keep only contract-level production data
keep if EntityType=="CONTRACT" /* "EntityType" specifies the level of reporting. "CONTRACT" refers to blocks. */

// Clean-up block names and IDs
replace block_id_enverus = strtrim(block_id_enverus)
replace block_name = strtrim(block_name)
replace block_name = upper(block_name)
replace block_name = "ANAGUID" if block_name == "ANAGUID EST"
replace block_id = "1355000006" if block_id == "1355000215"
destring(block_id_enverus), replace
format block_id_enverus %20.0f

// Tsset data at block-month level
tsset block_id_enverus month_date
tsfill 

// Fill up characteristics that are constant over time
local block_strings "block_country block_name field_name contract_name block_operator Province"
local block_numeric "tot_completed_wells well_count WellNumber area_block_sqkm"

foreach v in `block_strings'{
	bys block_id_enverus (`v'): replace `v' = `v'[_N] if missing(`v')
}

foreach v in `block_numeric'{
	bys block_id_enverus (`v'): replace `v' = `v'[1] if missing(`v')
}

// Compute number of consecutive months for which production data is missing
tostring block_id_enverus, replace
bys block_id_enverus (month_date): gen spell = sum(missing(daily_avg_oilgas_per_well_alt) != missing(daily_avg_oilgas_per_well_alt[_n-1]))
bys block_id_enverus spell (month_date): gen spell_length = _N
bysort block_id_enverus (month_date) : gen seq = missing(daily_avg_oilgas_per_well_alt) & (!missing(daily_avg_oilgas_per_well_alt[_n-1]) | _n == 1) 
by block_id_enverus : replace seq = seq[_n-1] + 1 if missing(daily_avg_oilgas_per_well_alt) & seq[_n-1] >= 1 & _n > 1 
bys block_id_enverus spell: egen gap = max(seq)
bys block_id_enverus: egen largest_gap_block = max(gap)

// Identify blocks with data gaps larger than 2 consecutive quarters
gen blocks_excl_large_gaps = 0
replace blocks_excl_large_gaps = 1 if largest_gap_block > 6 

// Interpolate missing production data points (up to a maximum of 2 consecutive quarters)
rename tot_oilgas_output_month tot_oilgas_month
local interp_vars "tot_oilgas_month daily_avg_oilgas_per_well_alt months_producing_since"

foreach d in `interp_vars'{
	bys block_id_enverus (month_date): ipolate `d' month_date if gap<=6, gen(`d'_ip)
}

// Data is now aggregated at the block level. Drop all field-level variables
drop field_name operator_field_well EPD_field_operator 

// Append field-level data which has been aggregated at the block level (see code lines 262 to 316)
append using `field_production_data'


********************************************************************************
************ 4. MERGE ASSET TRANSACTIONS DATA AT BLOCK-MONTH LEVEL *************
********************************************************************************

merge m:1 block_id_enverus month_date using "$clean_data/block_asset_transactions.dta"

// Identify blocks with any asset transaction in the given month
gen any_deal = 0
replace any_deal = 1 if _merge==3
bys block_id_enverus: egen has_transaction = max(any_deal)
drop if _merge==2
drop _merge
sort block_name month_date

// Prepare variables for aggregation at quarterly level
gen year_quarter = qofd(dofm(month_date))
format year_quarter %tq
rename daily_avg_oilgas_per_well_alt daily_avg_oilgas_per_well_raw
rename tot_oilgas_month tot_oilgas_month_raw 

// Aggregate monthly data to quarters
collapse (mean) monthly_gas monthly_oil daily_avg_oilgas_per_well_alt_ip daily_avg_oilgas_per_well_raw ///
(max) any_deal oil gas operator_changed has_transaction (min) neutral_deal blocks_excl_large_gaps ///
(sum) tot_oilgas_quarter_ip=tot_oilgas_month_ip tot_oilgas_quarter_raw=tot_oilgas_month_raw interest_purchased ///
tot_completed_wells , ///
by(block_id_enverus block_name block_country area_block_sqkm block_operator year_quarter Province)

replace tot_oilgas_quarter_raw=. if tot_oilgas_quarter_raw==0 & missing(monthly_oil) & missing(monthly_gas)
replace tot_oilgas_quarter_ip=. if tot_oilgas_quarter_ip==0 & missing(monthly_oil) & missing(monthly_gas) & missing(daily_avg_oilgas_per_well_alt_ip)

replace neutral_deal = 1 if interest_purchased < 0

// Determine whether block is (i) purely oil, (ii) purely gas or (iii) both resource types
bys block_id_enverus: egen oil_block = max(oil)
bys block_id_enverus: egen gas_block = max(gas)
gen resource_type = ""
replace resource_type = "OIL" if oil_block==1 & gas_block==0
replace resource_type = "GAS" if gas_block==1 & oil_block==0
replace resource_type = "OIL & GAS" if gas_block==1 & oil_block==1

// Identify firms' headquarter countries
gen hq = ""
replace hq = "Senegal" if block_operator=="AFRICA FORTESA"
replace hq = "Nigeria" if block_operator=="AITEO CONSORTIUM"
replace hq = "Nigeria" if block_operator=="AMNI"
replace hq = "United States" if block_operator=="APO"
replace hq = "Nigeria" if block_operator=="ATLAS ORANTO"
replace hq = "Nigeria" if block_operator=="BELEMAOIL"
replace hq = "United Kingdom" if block_operator=="BP"
replace hq = "Nigeria" if block_operator=="BRITTANIA-U"
replace hq = "Sweden/Tunisia" if block_operator=="CFTP"
replace hq = "United States" if block_operator=="CHEVRON"
replace hq = "Nigeria" if block_operator=="CONOIL"
replace hq = "Tunisia" if block_operator=="CTKCP"
replace hq = "Nigeria" if block_operator=="DUBRI"
replace hq = "United Kingdom/Nigeria" if block_operator=="ELCREST"
replace hq = "Nigeria" if block_operator=="ENERGIA"
replace hq = "Italy" if block_operator=="ENI"
replace hq = "Nigeria" if block_operator=="EROTON"
replace hq = "Tunisia" if block_operator=="ETAP"
replace hq = "Tunisia" if block_operator=="EXXOIL"
replace hq = "United States" if block_operator=="EXXONMOBIL"
replace hq = "United States" if block_operator=="FRONTIER"
replace hq = "Netherlands" if block_operator=="GEOFINANCE"
replace hq = "Egypt" if block_operator=="HBS"
replace hq = "United Kingdom" if block_operator=="HERITAGE ENERGY"
replace hq = "Sweden" if block_operator=="LUNDIN PETROLEUM"
replace hq = "Canada/Tunisia" if block_operator=="MARETAP"
replace hq = "Netherlands" if block_operator=="MAZARINE"
replace hq = "Indonesia" if block_operator=="MEDCO"
replace hq = "Nigeria" if block_operator=="MIDWESTERN"
replace hq = "Nigeria" if block_operator=="MONI PULO"
replace hq = "Nigeria" if block_operator=="NECONDE"
replace hq = "Nigeria" if block_operator=="NEPN"
replace hq = "Nigeria" if block_operator=="NEWCROSS"
replace hq = "Nigeria" if block_operator=="NIGER DELTA"
replace hq = "Nigeria" if block_operator=="NNPC"
replace hq = "" if block_operator=="NOT OPERATED"
replace hq = "Austria" if block_operator=="OMV"
replace hq = "Nigeria" if block_operator=="ORIENTAL ENERGY"
replace hq = "United Kingdom" if block_operator=="PERENCO"
replace hq = "Nigeria" if block_operator=="PILLAR"
replace hq = "Nigeria" if block_operator=="PLATFORM"
replace hq = "Nigeria" if block_operator=="PLUSPETROL"
replace hq = "Nigeria" if block_operator=="PRIME"
replace hq = "Nigeria" if block_operator=="SAHARA GROUP"
replace hq = "india" if block_operator=="SANDESARA"
replace hq = "United Kingdom" if block_operator=="SEPLAT"
replace hq = "United Kingdom/Tunisia" if block_operator=="SEREPT"
replace hq = "United Kingdom" if block_operator=="SERINUS"
replace hq = "Nigeria" if block_operator=="SAVANNAH"
replace hq = "Netherlands" if block_operator=="SHELL"
replace hq = "China" if block_operator=="SINOPEC"
replace hq = "Italy/Tunisia" if block_operator=="SITEP"
replace hq = "Italy/Tunisia" if block_operator=="SODEPS"
replace hq = "Angola" if block_operator=="SOMOIL"
replace hq = "Angola" if block_operator=="SONANGOL"
replace hq = "France" if block_operator=="TOTAL"
replace hq = "United States" if block_operator=="TPS"
replace hq = "United Kingdom" if block_operator=="TULLOW"
replace hq = "Nigeria" if block_operator=="WALTERSMITH"
replace hq = "Nigeria" if block_operator=="YINKA FOLAWIYO"
replace hq = "United States" if block_operator=="ANGOLA LNG"	
replace hq = "United Kingdom" if block_operator=="ATOG"

// Trim production variables at 99th percentile
winsor2 daily_avg_oilgas_per_well_alt_ip, cuts(0 99) trim replace
winsor2 tot_oilgas_quarter_ip, cuts(0 99) trim replace

// Generate dependent variables
gen ln_daily_avg_oilgas_per_well = ln(daily_avg_oilgas_per_well_alt_ip)
gen ln_tot_oilgas_quarter = ln(tot_oilgas_quarter_ip)

// Generate post period indicator
gen post_2013 = 0
replace post_2013 = 1 if year_quarter>=tq(2014q1)

// Identify license acquisitions by non-EPD firms
gen non_epd_deal = 0
replace non_epd_deal = 1 if neutral_deal !=1 & any_deal == 1 

// Identify year-quarter of license acquisitions
gen deal_date = year_quarter if any_deal==1
bys block_id_enverus: egen first_deal_date = min(deal_date)
format deal_date first_deal_date %tq

gen non_epd_deal_date = year_quarter if any_deal==1 & non_epd_deal==1
bys block_id_enverus: egen first_non_epd_deal_date = min(non_epd_deal_date)
format non_epd_deal_date first_non_epd_deal_date %tq

// Generate "Acquired Share" variable 
gen ln_interest_purchased = ln(interest_purchased) if any_deal == 1 & neutral_deal != 1
bys block_id_enverus (year_quarter): replace ln_interest_purchased = ln_interest_purchased[_n-1] if year_quarter > first_non_epd_deal_date
replace ln_interest_purchased = 0 if missing(ln_interest_purchased)

// Identify block ownership changes
gen OC = 0
replace OC = 1 if year_quarter >= first_deal_date

// Identify license acquisitions by non-EPD firms
gen OC_non_EPD = 0
replace OC_non_EPD = 1 * ln_interest_purchased if year_quarter >= first_non_epd_deal_date

// Identify block ownership changes in the post period
gen OC_post_2013 = 0
replace OC_post_2013 = 1 if OC==1 & first_deal_date >= tq(2014q1)

// Identify license acquisitions by non-EPD firms in the post period
gen OC_non_EPD_post_2013 = 0
replace OC_non_EPD_post_2013 = 1 * ln_interest_purchased if year_quarter>=first_non_epd_deal_date & first_non_epd_deal_date>=tq(2014q1)

// Identify treated blocks (i.e., blocks with at least 1 acquisition by non-EPD firms in the post-period)
bys block_id_enverus: egen treated = max(OC_non_EPD_post_2013)

// Define regression sample
keep if year_quarter >= tq(2010q1) & year_quarter <= tq(2017q4) & blocks_excl_large_gaps == 0

// Generate fixed effects
egen block_FE = group(block_id_enverus)
egen resourcetype_yrqt_FE = group(resource_type year_quarter)

// Label variables
label var ln_daily_avg_oilgas_per_well "Ln(Output per Well)"
label var ln_interest_purchased "Ln(Acquired Share)"
label var ln_tot_oilgas_quarter "Ln(Total Output)"
label var non_epd_deal "Non-EPD Firm Entry"
label var OC_non_EPD_post_2013 "Non-EPD Firm Entry $\times$ Post 2013 $\times$ Ln(Acquired Share)"
label var OC_non_EPD "OC $\times$ Non-EPD Acquiror"
label var OC_post_2013 "OC $\times$ Post 2013"
label var post_2013 "Post 2013"
label var OC "OC"


// Save merged and cleaned productivity dataset
save "$final_data/block_entry_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******             ARTICLE: Extraction Payment Disclosures               *******
******             AUTHOR: Thomas Rauter                                 *******
******             JOURNAL OF ACCOUNTING RESEARCH                        *******
******             CODE TYPE: Clean and Standardize Company Names        *******
******             LAST UPDATED: August 2020                             *******
******                                                                   *******
********************************************************************************

// Clean company names
gen company_cleaned = company

replace company_cleaned = subinstr(company_cleaned,"LLC","",.) 
replace company_cleaned = subinstr(company_cleaned,"LLP","",.) 
replace company_cleaned = subinstr(company_cleaned,"AS","",.) 
replace company_cleaned = subinstr(company_cleaned,"Ltd","",.) 
replace company_cleaned = subinstr(company_cleaned,"JSC","",.) 
replace company_cleaned = subinstr(company_cleaned,"ХХК","",.) 
replace company_cleaned = subinstr(company_cleaned,"LIMITED","",.) 
replace company_cleaned = subinstr(company_cleaned,"(ХХК)","",.) 
replace company_cleaned = subinstr(company_cleaned,"Limited","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD","",.) 
replace company_cleaned = subinstr(company_cleaned,"SPRL","",.) 
replace company_cleaned = subinstr(company_cleaned,"SA","",.)
replace company_cleaned = subinstr(company_cleaned,"SARL","",.) 
replace company_cleaned = subinstr(company_cleaned,"ASA","",.) 
replace company_cleaned = subinstr(company_cleaned,"PLC","",.) 
replace company_cleaned = subinstr(company_cleaned,"Corporation","",.) 
replace company_cleaned = subinstr(company_cleaned,"Company","",.) 
replace company_cleaned = subinstr(company_cleaned,"Ltd.","",.) 
replace company_cleaned = subinstr(company_cleaned,"SAS","",.) 
replace company_cleaned = subinstr(company_cleaned,"Plc","",.) 
replace company_cleaned = subinstr(company_cleaned,"B.V.","",.) 
replace company_cleaned = subinstr(company_cleaned,"Inc.","",.) 
replace company_cleaned = subinstr(company_cleaned,"MINING","",.) 
replace company_cleaned = subinstr(company_cleaned,"S.A.","",.) 
replace company_cleaned = subinstr(company_cleaned,"COMPANY","",.) 
replace company_cleaned = subinstr(company_cleaned,"JSC*","",.) 
replace company_cleaned = subinstr(company_cleaned,"AS2)","",.) 
replace company_cleaned = subinstr(company_cleaned,"International","",.) 
replace company_cleaned = subinstr(company_cleaned,"CORPORATION","",.) 
replace company_cleaned = subinstr(company_cleaned,"Inc","",.) 
replace company_cleaned = subinstr(company_cleaned,"Resources","",.) 
replace company_cleaned = subinstr(company_cleaned,"plc","",.) 
replace company_cleaned = subinstr(company_cleaned,"(ХК)","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD.","",.) 
replace company_cleaned = subinstr(company_cleaned,"NUF","",.) 
replace company_cleaned = subinstr(company_cleaned,"ХК","",.) 
replace company_cleaned = subinstr(company_cleaned,"B.V","",.) 
replace company_cleaned = subinstr(company_cleaned,"DRC","",.) 
replace company_cleaned = subinstr(company_cleaned,"Branch","",.) 
replace company_cleaned = subinstr(company_cleaned,"C","",.) 
replace company_cleaned = subinstr(company_cleaned,"Co.","",.) 
replace company_cleaned = subinstr(company_cleaned,"Incorporated","",.) 
replace company_cleaned = subinstr(company_cleaned,"Group","",.) 
replace company_cleaned = subinstr(company_cleaned,"S.A","",.) 
replace company_cleaned = subinstr(company_cleaned,"COMPAGNY","",.) 
replace company_cleaned = subinstr(company_cleaned,"INC","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD**","",.) 
replace company_cleaned = subinstr(company_cleaned,"A/S","",.) 

replace company_cleaned = rtrim(company_cleaned)
replace company_cleaned = ltrim(company_cleaned)
replace company_cleaned = strtrim(company_cleaned)
replace company_cleaned = strltrim(company_cleaned)
replace company_cleaned = stritrim(company_cleaned)
replace company_cleaned = strrtrim(company_cleaned)

replace company_cleaned = subinstr(company_cleaned, char(34),"",.)
replace company_cleaned = subinstr(company_cleaned," ","",.) 
replace company_cleaned = subinstr(company_cleaned,".","",.) 
replace company_cleaned = subinstr(company_cleaned,",","",.) 
replace company_cleaned = subinstr(company_cleaned,"(","",.) 
replace company_cleaned = subinstr(company_cleaned,")","",.)
replace company_cleaned = subinstr(company_cleaned,"&","",.)
replace company_cleaned = subinstr(company_cleaned,"*","",.) 
replace company_cleaned = subinstr(company_cleaned,"-","",.) 
replace company_cleaned = subinstr(company_cleaned,"'","",.) 
replace company_cleaned = subinstr(company_cleaned,"´","",.) 
replace company_cleaned = subinstr(company_cleaned,"`","",.) 
replace company_cleaned = subinstr(company_cleaned,"̂","",.)

replace company_cleaned = subinstr(company_cleaned,"è","e",.) 
replace company_cleaned = subinstr(company_cleaned,"é","e",.) 
replace company_cleaned = subinstr(company_cleaned,"é","e",.) 
replace company_cleaned = subinstr(company_cleaned,"É","E",.) 

replace company_cleaned = upper(company_cleaned)
********************************************************************************
******                                                                   *******
******           ARTICLE: Extraction Payment Disclosures                 *******
******           AUTHOR: Thomas Rauter                                   *******
******           JOURNAL OF ACCOUNTING RESEARCH                          *******
******           CODE TYPE: Clean and Standardize Country Names          *******
******           LAST UPDATED: August 2020                               *******
******                                                                   *******
********************************************************************************

kountry segment_description, from(other) marker

*Replace country names that are misspelt
rename segment_description IN 
rename NAMES_STD NAMES

replace NAMES="China" if IN=="/CHINA " | IN=="/CHINA" | IN=="B&Q CHINA SALES" | ///
	IN=="BEIJING" | IN=="CHINA EX HONG KONG AND MACAU " | ///
	IN=="CHINA INLAND" |  IN=="CHINA(EXCEPT HONGKONG,TAIWAN)" | ///
	IN=="CHINA-SHENZHEN" | IN=="CHINESE MAINLAND" | IN=="EAST CHINA" | ///
	IN=="EASTERN CHINA" | IN=="ELSEWHERE IN PRC" | IN=="ELSEWHERE IN THE PRC" | ///
	IN=="ELSWHERE IN THE PRC" | IN=="GREAT CHINA" | IN=="GREATER CHINA" | ///
	IN=="GUANGDONG" | IN=="GUANGXI (AUTONOMOUS REGION)" |  ///
	IN=="MAINLANC CHINA" | IN=="MAINLAND CHINA" | ///
	IN=="MAINLAND PRC" | IN=="NORTH CHINA" | IN=="NORTHEASTERN CHINA" | ///
	IN=="NORTHERN CHINA" | IN=="OTHER PARTS OF CHINA" | ///
	IN=="OTHER PARTS OF PRC" | IN=="OTHER REGION IN PRC" | IN=="OTHER REGIONS IN PR" | ///
	IN=="OTHER REGIONS IN PRC" | IN=="OTHER REGIONS IN THE PRC" | ///
	IN=="P R CHINA"| IN=="P. R. CHINA" | IN=="P.R. CHINA" | IN=="P.R. OF CHINA" | ///
	IN=="P.R.CHINA" | strpos(IN, "REPUBLIC OF CHINA") | IN=="PEOPLE'S REPUBLIC'S OF CHINA" | ///
	IN=="PEOPLES REPUBLIC OF" | IN=="PEOPLES REPUBLIC OF C" | IN=="PEOPLES REPUBLIC OF CHINA" | ///
	IN=="PRC" | IN=="PRC (DOMICILE)" | IN=="PRC (OTHER THAN HONG KONG)" | IN=="PRC EXCEPT HONG KONG" | ///
	IN=="PRC MAINLAND" | IN=="PRC OTHER THAN HONG KONG,MACAO & TAIWAN" | ///
	IN=="REGIONS IN THE PRC OTH THAN HK AND MACAU" | IN=="REPUBLIC OF CHINA" | IN=="REST OF PRC" | ///
	IN=="REST OF PRC & OTHER" | IN=="REST OF PRC AND OTHERS" | IN=="SHANDONG PROVINCE" | ///
	IN=="SHANGHAI" | IN=="SHANXI PROVINCE" | IN=="SOUTH CHINA" | IN=="SOUTHERN CHINA" | ///
	IN=="THE  PRC" | IN=="THE MAINLAND CHINA" | IN=="THE PEOPLE'S REPUBLIC OF CHINA" | ///
	IN=="THE PRC" | IN=="THE PRC EXCL HONGKONG" | IN=="THE PRC OTHER THAN" | ///
	IN=="THE PRC OTHER THAN HONG KONG AND MACAU" | IN=="WEST CHINA" | ///
	IN=="WESTERN CHINA" | IN=="WITHIN PRC" | IN=="XINJIANG PROVINCE" | IN=="CENTRAL CHINA" | ///
	IN=="OTHER REGIONS OF MAINLAND CHINA" | IN=="PEOPLE OF REPUBLIC CHINA" 
replace NAMES="Hong Kong" if IN=="HK" | IN=="HONG KONG & CORPORATE" | IN=="HONG KONG SAR" | ///
	IN=="HONG KONG, SAR" | IN=="OTHER HK"
replace NAMES="Macao" if IN=="MACAU OPERATIONS"
replace NAMES="Taiwan" if IN=="TAIWAN, REPUBLIC OF"
replace NAMES="India" if IN=="ANDHRA PRADESH" | IN=="CHHATTISGARH" | ///
	IN=="DISCONTINUED OPERATIONS- INDIA"  | IN=="ELIMINATIONS/INDIA" | IN=="IN INDIA" | ///
	IN=="INDIA REGION" | IN=="INDIAN OPERATIONS" | IN=="INDIAN SUB-CONTINENT" | ///
	IN=="INIDA" | IN=="JAMMU" | IN=="SALES WITHIN INDIA" | IN=="WITH IN INDIA" | ///
	IN=="WITH-ININDIA" | IN=="WITHIN INDIA" | IN=="WTIHIN INDIA" | IN=="ANDHRA PRADESH" | ///
	IN=="INDAI"
replace NAMES="UAE" if IN=="ABU DHABI (EMIRATE)" | IN=="DUBAI" | ///
	IN=="DUBAI (EMIRATE)" | IN=="EMIRATES" | IN=="NORTHERN EMIRATES" | ///
	IN=="UNITED ARAB EMIRATE" | IN=="UNITED ARAB EMIRATESZ" | ///
	IN=="ABU DHABI (EMIRATE)"
replace NAMES="Canada" if IN=="ALBERTA" | IN=="BRITISH COLUMBIA" | ///
	IN=="CANADA - BACK WATER PROJECT" | IN=="CANADA - NEW AFTON" | ///
	IN=="CANADA- OPERATING SEGMENT" | IN=="CANADA- RAINY RIVER" | ///
	IN=="CANADIAN" | IN=="CANADIAN OILFIELD SERVICES" | ///
	IN=="CANADIAN OPERATIONS" | IN=="CANANDA" | IN=="CANDA" | ///
	IN=="CHILDREN'S PLACE CANADA" | IN=="OTHER CANADIAN OPERATIONS" | ///
	IN=="RED LAKE - CANADA" | IN=="ROCKY MOUNTAINS" | IN=="SASKATCHEWAN" | ///
	IN=="SOUTHERN ONTARIO" | IN=="SYNCRUDE" | IN=="WESTERN CANADA" | ///
	IN=="ALBERTA"
replace NAMES="United States" if IN=="AMERICA" | IN=="ALASKA" | ///
	IN=="AHOLD USA" | IN=="AMERICAN OPERATIONS" | ///
	IN=="AMERICAN REGION" | IN=="AMERICAN ZONE" | ///
	IN=="AMRERICANS" | IN=="ATLANTA" | ///
	IN=="CENTRAL UNITED STATES (DIVISION)" | ///
	IN=="CHICAGO" | IN=="CHILDREN'S PLACE UNITED STATES" | ///
	IN=="CONTINENTAL US" | IN=="CORPORATE & TRADICO (U.S.)" | ///
	IN=="DALLAS" | IN=="DELAWARE" | IN=="DENVER" | IN=="DETROIT" | ///
	IN=="EAST TEXAS/LOUISIANA" | IN=="EASTERN UNITED STATES (DIVISION)" | ///
	IN=="HOUSTON" | IN=="LAS VEGAS OPERATIONS" | IN=="LOS ANGELES" | ///
	IN=="MARYLAND" | IN=="MIDDLE AMERICA" | IN=="MIDSTREAM UNITED STATES" | ///
	IN=="NEW MEXICO" | IN=="NEW YORK" | IN=="NORTHEAST UNITED STATES (DIVISION)" | ///
	IN=="NORTHERN VIRGINI" | IN=="OKLAHOMA" | IN=="PLP-USA" | ///
	IN=="REGIONAL UNITED STATES" | IN=="SAN DIEGO" | IN=="SAN FRANCISCO BAY" | ///
	IN=="SAO FRANCISCO MINE" | IN=="LASALLE INVESTMENT MANAGEMENT SERVICES" | ///
	IN=="LUMMUS" | IN=="MARCELLUS SHALE" | IN=="PICEANCE BASIN" | ///
	IN=="SOUTH UNITED STATES (DIVISION)" | IN=="SOUTHERN VIRGINIA" | ///
	IN=="STAMFORD / NEW YORK" | IN=="T.R.N.C." | IN=="TEXAS" | IN=="TEXAS (STATE)" | ///
	IN=="TEXAS PANHANDLE" | IN=="U S A" | IN=="U. S. MEDICAL" | ///
	IN=="U.S - MESQUITE MINE" | IN=="U.S. & POSSESSIONS" | IN=="U.S. DOMESTIC" | ///
	IN=="U.S. GULF OF MEXICO" | IN=="U.S. OPERATIONS" | IN=="UINITED STATES" | ///
	IN=="UINITED STATES" | IN=="UMITED STATES" | IN=="UNIRED STATES" | ///
	IN=="UNITATED STATES" | IN=="UNITE STATES" | IN=="UNITED  STATE" | ///
	IN=="UNITED SATES" | IN=="UNITED STAES" | IN=="UNITED STARES" | ///
	IN=="UNITED STATE" | IN=="UNITED STATED" | ///
	IN=="UNITED STATES                      UNITE" | IN=="UNITED STATES / DOMESTIC" | ///
	IN=="UNITED STATES AMERICA"  | IN=="UNITED STATES AND ITS TERRITORIES" | ///
	IN=="UNITED STATES OF AM" | IN=="UNITED STATES OF AMER" | ///
	IN=="UNITED STATES OILFIELD SERVICES" | IN=="UNITED STATES OPERATIONS" | ///
	IN=="UNITED STATESS" | IN=="UNITES STATES" | IN=="UNITTED STATES" | ///
	IN=="UNTIED STATES" | IN=="US GULF" | IN=="US WEST" | IN=="US- AMESBURYTRUTH" | ///
	IN=="USA (NAFTA)" | IN=="USA EXPLORATION" | IN=="USA PRODUCTION"  | ///
	IN=="UUNITED STATES" | IN=="WASHINGTON (D.C)" | IN=="WEST UNITED STATES (DIVISION)" | ///
	IN=="WHARF - UNITED STATES" | IN=="WYNN BOSTON HARBOR" | IN=="CENTRAL APPALACHIA" | ///
	IN=="UINTED STATES" | IN=="WILLISTON BASIN" | IN=="AHOLD USA" | IN=="ALASKA"
replace NAMES="Germany" if IN=="AIRLINE GERMANY" | IN=="DEUTSCHLAND" | ///
	IN=="GEMANY" | IN=="GERMAN LANGUAGE COUNT"	| IN=="GERMAN MARKET" | ///
	IN=="GERMANY - LYING SYSTEMS" | IN=="GERMANY - SURFACE CARE" | ///
	IN=="GERMANY RETAIL" | IN=="GERMEN" | IN=="NORTHERN GERMANY" | ///
	IN=="PARENT COMPANY - GERMANY" | IN=="SOUTHERN GERMANY" | IN=="AIRLINE GERMANY" | ///
	IN=="GERMAN OPERATIONS"
replace NAMES="Argentina" if IN=="ALUMBERA - ARGENTINA" | IN=="MISC ARGENTINA" | ///
	IN=="ARGENTINA-OIL GAS" | IN=="ALUMBERA - ARGENTINA"
replace NAMES="Russia" if IN=="AMURSK ALBAZINO" | IN=="INTERNATIONAL OPERATION/RUSSIA" | ///
	IN=="MOSCOW" | IN=="MOSCOW AND  MOSCOW RE" | IN=="RUSSIA  - MOBILE" | ///
	IN=="RUSSIA FIXED" | IN=="RUSSIAN" | IN=="RUSSIAN FEDERATIONS" | ///
	IN=="SALES IN RUSSIA" | IN=="KRASNOYARSK BUSINESS UNIT" | IN=="KYZYL" | ///
	IN=="MAGADAN BUSINESS UNIT" | IN=="MAYSKOYE" | IN=="OKHOTSK" | IN=="OMOLON" | ///
	IN=="ST. PETERSBURG" | IN=="YAKUTSK KURANAKH BUSINESS UNIT"
replace NAMES="Jordan" if IN=="AQABA" | IN=="INSIDE JORDAN" | IN=="JORDAN EXCEPT AQABA"
replace NAMES="Egypt" if IN=="ARAB REPUBLIC OF EGYPT"
replace NAMES="Mexico" if IN=="ARANZAZU MINES" | IN=="MEXCIO" | IN=="MEXICO (AMERICAS)" | ///
	IN=="OTHER INTERNATIONAL(MEXICO)" | IN=="PENASQUITO" 
replace NAMES="Australia" if IN=="AUATRALIA" | IN=="AUSTALIA" | ///
	IN=="AUSTRALIA EXPLORATION" | IN=="AUSTRALIA PACIFIC" | ///
	IN=="AUSTRALIA PRODUCTION" | IN=="AUSTRALIAN" | ///
	IN=="AUSTRALIAN CAPITAL TERRITORY" | IN=="AUSTRALIAN OPEARTIONS" | ///
	IN=="AUTRALIA" | IN=="CORPORATE AUSTRALIA" | IN=="GULLEWA" | ///
	IN=="OTHER AUSTRALIA" | IN=="RECTRON AUSTRALIA" | IN=="NEW SOUTH WALES" | ///
	IN=="QUEENSLAND" | IN=="QUEENSLAND." | IN=="SOUTH AUSTRALIA" | IN=="WESTERN AUSTRALIA" | ///
	IN=="EASTERN AUSTRALIA"
replace NAMES="Austria" if IN=="AUSTRIA (HOLDING)"
replace NAMES="Bahrain" if IN=="BAHARAIN"
replace NAMES="Bangladesh" if IN=="BANGALDESH"
replace NAMES="Guinea" if IN=="BAOULE - GUINEA"
replace NAMES="Barbados" if IN=="BARBODOS"
replace NAMES="Indonesia" if IN=="BEKASI" | IN=="CAKUNG" | IN=="CIKANDE" | ///
	IN=="DKI JAKARTA" | IN=="INDONESIAN" | IN=="INDONSIA" | ///
	IN=="REPUBLIC OF INDONESIA" | IN=="JABODETABEK" | IN=="JAKARTA" | ///
	IN=="JAKARTA AND BOGOR" | IN=="JAVA ISLAND" | IN=="JAVA ISLAND (EXC. JAKARTA)" | ///
	IN=="JAWA" | IN=="JAWA (EXCLUDING JAKARTA)" | IN=="JAWA, BALI DAN NUSA TENGGARA" | ///
	IN=="JAWA, BALI DAN NUSA TENGGARA" | IN=="JAWA-BALI" | IN=="JAYAPURA" | ///
	IN=="KALIMANTAN" | IN=="KALIMANTAN,SULAWESI & MALUKU" | IN=="MAKASSAR" | IN=="MEDAN" | ///
	IN=="PALEMBANG" | IN=="PASURUAN" | IN=="PONDOK CABE" | IN=="PURWAKARTA" | ///
	IN=="SEMARANG" | IN=="SERANG" | IN=="SULAWESI AND MALUKU" | IN=="SULAWESI DAN PAPUA" | ///
	IN=="SUMATERA" | IN=="TANGERANG" | IN=="THE REPUBLIC OF INDONESIA" | IN=="BALI AND LOMBOK ISLAND" | ///
	IN=="EAST JAVA" | IN=="BANDUNG"
replace NAMES="Belarus" if IN=="BELORUSSIA" | IN=="REPUBLIC OF BELARUS" | IN=="BELAUS"
replace NAMES="Bulgaria" if IN=="BOLGARIA"
replace NAMES="Bosnia and Herzegovina" if IN=="BOSNIA AND  HERZEGOVI" | ///
	IN=="BOSNIA AND HERZEGOVIN"
replace NAMES="France" if IN=="BOURGOGNE (METROPOLITAN REGION)" | ///
	IN=="EUROPE (REGION)-FRANCE " | IN=="FBB FRANCE" | IN=="FRANCE & DOM-TOM" | ///
	IN=="FRANCE & TERRITORIES" | IN=="FRANCE (DOM)" | IN=="FRANCE (REUNION ISLAND)" | ///
	IN=="FRANCE (REUNION ISLAND)" | IN=="FRANCE WITH DOM-TOM" | IN=="FRANCE/DOM-TOM" | ///
	IN=="FRENCH OVERSEAS DOMINIONS & TERRITORIES" | IN=="FRENCH OVERSEAS TERRITORIES" | ///
	IN=="LE-DE-FRANCE (METROPOLITAN REGION)" | IN=="PARIS" | ///
	IN=="PROVENCE-ALPES-C TE-D'AZUR (METROPOLITAN REGION)" | IN=="PIXMANIA" | ///
	IN=="RH NE ALPES (METROPOLITAN REGION)" | IN=="FRANCE - RENTAL PROPERTIES" | ///
	IN=="FRENCH"
replace NAMES="Brazil" if IN=="BRASIL" | IN=="BRAZIL/EXPORT" | IN=="BRAZILIAN MINES" | ///
	IN=="BRAZIL DRILLING OPERATIONS" | IN=="BRAZIL EXPLORATION & EVALUATION" | IN=="BRAZIL/IMPORTS"
replace NAMES="United Kingdom" if IN=="BRITAIN" | IN=="BRITIAN" | IN=="INTERNATIONAL (UK)" | ///
	IN=="U.K. AND ELIMINATION" | IN=="UK BUS (LONDON)" | IN=="UK BUS (REGIONAL OPERATIONS)" | ///
	IN=="UK RAIL" | IN=="UK RETAIL" | IN=="UNITED  KINDOM" | IN=="UNITED KINDOM" | ///
	IN=="UNITED KINGDOM (INCLUDING EXPORTS)" | IN=="UNITED KINGDOM - CONTINUING" | ///
	IN=="UNITED KINGDOM - INVESTING ACTIVITIES" | IN=="UNITED KINGDOM- OPERATING SEGMENT" | ///
	IN=="UNITED KINGDOM/BVI" | IN=="UNITED KINGDON" | IN=="UNITED KINGSOM" | IN=="XANSA" | ///
	IN=="UNITED KIGDOM" | IN=="GREAT BRITAN" | IN=="GREAT BRITIAN" | IN=="REST OF UK" | ///
	IN=="UK OPERATIONS"
replace NAMES="British Virgin Islands" if IN=="BRITISH VIRGIN ISLAND" | IN=="BVI"
replace NAMES="Belgium" if IN=="BRUSSELS" | IN=="FLANDERS" | IN=="WALLONIA"
replace NAMES="Israel" if IN=="BUILDINGS FOR SALE IN ISRAEL" | IN=="ISRAEL - RENTAL PROPERTIES"
replace NAMES="Tanzania" if IN=="BULYANHULU" | IN=="BUZWAGI" | IN=="NORTH MARA" | ///
	IN=="TANZANIA - AGRICULTURE & FORESTRY" | IN=="TANZANIA - EXPLORATION & DEVELOPMENT" | ///
	IN=="TULAWAKA"
replace NAMES="Burkina Faso" if IN=="BURKINA FASOFASO" 
replace NAMES="Chile" if IN=="CABECERAS" | IN=="CHILE - ELMORRO PROJECT" | ///
	IN=="LATAM" | IN=="LATAM OPERATIONS" | IN=="LATAM."
replace NAMES="Cambodia" if IN=="CAMBODGE" | IN=="KINGDOM OF CAMBODIA"
replace NAMES="Cameroon" if IN=="CAMEROON, UNITED REPUBLIC OF" | ///
	IN=="REPUBLIC OF CAMEROON"
replace NAMES="Turkey" if IN=="CAYELI (TURKEY)" | IN=="TURKEY OPERATIONS" | ///
	IN=="TURKISH REPUBLIC" | IN=="TURKISH REPUBLIC OF NORTHERN CYPRUS" | IN=="TURKY"
replace NAMES="Japan" if IN=="CENTRAL JAPAN" | IN=="EASTERN JAPAN" | ///
	IN=="JAPAN EAST" | IN=="JAPAN WEST" | IN=="JAPANP" | IN=="JAPNA" | ///
	IN=="OPERATING SEGEMENT-JAPAN" | IN=="WEST JAPAN" | IN=="JAPAN OPERATION"
replace NAMES="England" if IN=="CENTRAL LONDON" | IN=="DORSET" | ///
	IN=="LONDON" | IN=="LONDON & SOUTH" | IN=="SLAD" | IN=="SOUTHERN ENGLAND EXPLORATION" | ///
	IN=="THAMES VALLEY" | IN=="THAMES VALLEY AND THE REGIONS" | IN=="CENTRAL LONDON" | ///
	IN=="DORSET" 
replace NAMES="Norway" if IN=="CENTRAL NORWAY" | IN=="MEKONOMEN NORWAY" | ///
	IN=="MID-NORWAY" | IN=="NORTH-NORWAY" | IN=="NORTHERN NORWAY" | IN=="MALM" | ///
	IN=="THE OSLO FJORD"
replace NAMES="Colombia" if IN=="COLUMBIA"
replace NAMES="Congo" if IN=="CONGO-BRAZZAVILLE / REPUBLIC OF CONGO" | ///
	IN=="REPUBLIC OF CONGO" | IN=="REPUBLIC OF THE CONGA" | IN=="REPUBLIC OF THE CONGO" | ///
	IN=="CONGO-BRAZZAVILLE / REPUBLIC OF CONGO" | IN=="REPUBLIC OF CONGO"
replace NAMES="Democratic Republic of Congo" if IN=="DR CONGO" | IN=="DRC"
replace NAMES="Ivory Coast" if strpos(IN, "IVOIRE") | IN=="IVORY COASTIVORY CO" | ///
	IN=="VORY COAST"
replace NAMES="Croatia" if IN=="CROTATIA" | IN=="CROTIA" | IN=="REPUBLIC OF CROATIA"
replace NAMES="Czech Republic" if IN=="CZECH REPUBLIC TOTAL" | IN=="CZECH REPUBLIC LOTTERY" | ///
	IN=="CZECH REPUBLIC SPORTS BETTING"
replace NAMES="Dominican Republic" if IN=="DOMINICAN REPB."
replace NAMES="Malaysia" if IN=="EAST MALAYSIA" | IN=="MALAYSIA (ASIA)" | ///
	IN=="MALAYSIA(DOMESTIC)" | IN=="MALAYSIA/LOCAL" | IN=="MALAYSIAN OPERATIONS" | ///
	IN=="NALAYSIA" | IN=="WEST MALAYSIA" | IN=="WITHIN MALAYSIA"
replace NAMES="Timor-Leste" if IN=="EAST TIMOR / TIMOR-LESTE"
replace NAMES="Uruguay" if IN=="URUGUAY DRILLING OPERATIONS"
replace NAMES="Spain" if IN=="EL SAUZAL" | IN=="LAS CRUCES(SPAIN)" | ///
	IN=="SPAIN - DISC. OP."
replace NAMES="Ethiopia" if IN=="ETHOPIA"
replace NAMES="Finland" if IN=="FINLAND (DISCONTINUED OPERATIONS)" | ///
	IN=="FINLAND/OUTOKUMPU" | IN=="FINNLAND" | IN=="OTHER FINLAND" | ///
	IN=="PYHASALMI (FINLAND)" | IN=="REST OF FINLAND" | IN=="RAUMA"
replace NAMES="Guiana" if IN=="FRENCH GUYANA" | IN=="FRENCH GUYANE" | ///
	IN=="FRENCH GUIANA (DEPENDENT TERRITORY)"
replace NAMES="Greece" if IN=="GEECE" | IN=="GREEK"
replace NAMES="Greenland" if IN=="GREEN LAND"
replace NAMES="Guatemala" if IN=="GUATEMAL"
replace NAMES="Sweden" if IN=="HELSINGBORG" | IN=="HUDDINGE" | IN=="OTHER SWEDEN" | ///
	IN=="LIDINGO" | IN=="LUND" | IN=="SOUTHERN STOCKHOLM" | IN=="STOCKHOLM" | ///
	IN=="SWEDEN- OPERATING SEGMENT" | IN=="WESTERN STOCKHOLM" | IN=="HELSINGFORS"
replace NAMES="Netherlands" if IN=="HOLAND" | IN=="THE NETHERLAND"
replace NAMES="Hungary" if IN=="HUNGARIAN"
replace NAMES="Switzerland" if IN=="INDIVIDUAL LIFE SWITZERLAND" | IN=="SWIZERLAND" | ///
	IN=="SWIZTERLAND"
replace NAMES="Kuwait" if IN=="INSIDE KUWAIT" | IN=="STATE OF KUWAIT"
replace NAMES="South Africa" if IN=="INTRA- SEGMENTAL SOUTH AFRICA" | ///
	IN=="REPUBLIC OF SOUTH AFRICA" | IN=="KWAZULU-NATAL" | IN=="SOUTH AFRICA (VODACOM" | ///
	IN=="SOUTH AFRICA (VODACOM)" | IN=="GAUTENG"
replace NAMES="Kazakhstan" if IN=="KAZAKHISTAN" | IN=="KAZACHSTAN" | ///
	IN=="KAZAKHSTHAN BUSINESS UNIT" | IN=="REP OF KAZAKHSTAN" | ///
	IN=="REPUBLIC OF KAZAKHSTAN"
replace NAMES="Saudi Arabia" if strpos(IN, "KINGDOM OF SAUDI ARA") | ///
	IN=="SAUDI" | IN=="SAUDI AERABIA" | IN=="SAUDI ARAB" | IN=="SAUDI ARBIA" 
replace NAMES="Thailand" if IN=="KINGDOM OF THAILAND" | IN=="THAILLAND"
replace NAMES="Sierra Leone" if IN=="KONO - SIERRA LEONE" | IN=="SIERRA LOENE"
replace NAMES="South Korea" if IN=="KOREA(SOUTH)" | IN=="OTHER FOREIGN-SOUTH KOREA" 
replace NAMES="North Korea" if IN=="KOREA, DEMOCRATIC REBUCLIC OF KOREA"
replace NAMES="Iraq" if	IN=="KURDISTAN REGION OF IRAQ" | IN=="NORTHERN IRAQ"
replace NAMES="Libya" if IN=="LIBIA" | IN=="LYBIA"
replace NAMES="Lithuania" if IN=="LITHUENIA" | IN=="LITHUNIA"
replace NAMES="Madagascar" if IN=="MADAGASKAR"
replace NAMES="Mongolia" if IN=="MANGOLIA"
replace NAMES="Mauritius" if IN=="MAUTITIUS" | IN=="REPUBLIC OF MAURITIUS"
replace NAMES="Pakistan" if IN=="MIDDLE EAST- PAKISTAN" | ///
	IN=="PAKISTHAN"
replace NAMES="Morocco" if IN=="MORROCCO"
replace NAMES="Kenya" if IN=="MOUNT KENYA REGION" | IN=="WEST KENYA REGION" | ///
	IN=="NAIROBI REGION"
replace NAMES="Myanmar" if IN=="MYAMAR" | IN=="UNION OF MYANMAR"
replace NAMES="Namibia" if IN=="NAMIBIAN"
replace NAMES="Netherlands" if IN=="NETHERLAND" | IN=="NETHERLANDS (EUROPE)"
replace NAMES="New Zealand" if IN=="NEW ZELAND" | IN=="NEWZEALAND"
replace NAMES="Papua New Guinea" if IN=="PAPUA NEW-GUINEA" | IN=="PNG" | IN=="DROUJBA"
replace NAMES="Peru" if IN=="PERU-MINING" | IN=="PERUVIAN FISHMEAL" | ///
	IN=="PERUVIAN WATERS"
replace NAMES="Philippines" if IN=="PHILIPPINE" | IN=="PHLIPPINES" | IN=="PHILIPINES"
replace NAMES="Laos" if IN=="PS LAOS"
replace NAMES="Chad" if IN=="REPUBLIC OF CHAD"
replace NAMES="Ghana" if IN=="REPUBLIC OF GHANA"
replace NAMES="Singapore" if IN=="REPUBLIC OF SINGAPORE" | IN=="SINAGPORE" | ///
	IN=="SINGAPRE" | IN=="SINGAPUR" | IN=="WITHIN SINGAPORE"
replace NAMES="Yemen" if IN=="REPUBLIC OF YEMEN"
replace NAMES="Romania" if IN=="ROMANIAN" | IN=="ROMENIA"
replace NAMES="Fiji" if IN=="KAMBUNA"
replace NAMES="Kosovo" if IN=="KOSOVO."
replace NAMES="Lesotho" if IN=="LESOTHO - RETAIL"
replace NAMES="Italy" if IN=="MESSINA" | IN=="ITALY - MACHINES"
replace NAMES="North Mariana Islands" if IN=="N. MARIANA ISLANDS"
replace NAMES="Falkland Islands" if IN=="NORTH FALKLAND" | IN=="NORTH FALKLAND BASIN"
replace NAMES="Cyprus" if IN=="NORTHERN CYPRUS"
replace NAMES="Northern Ireland" if IN=="NORTHERN IRELAND" | IN=="NOTHERN IRELAND"
replace NAMES="Ireland" if IN=="REPUBLIC OF IRELAND" | IN=="REPUBLIC OF IRELAND - CONTINUING" | ///
	IN=="REPULBLIC OF IRELAND" | IN=="REPULBLIC OF IRLAND" | IN=="ISLAND OF IRELAND"
replace NAMES="United Kingdom" if IN=="SCOTLAND" | IN=="TESCO BANK" | IN=="WALES"
replace NAMES="Syria" if IN=="SIRIA" | IN=="SIRYA"
replace NAMES="Slovakia" if IN=="SLOVAKIA REPUBLIC" | IN=="SLOVAKIAN" | IN=="SOLVAKIA"
replace NAMES="Slovenia" if IN=="SOLVANIA"
replace NAMES="Sri Lanka" if IN=="SRI LANAKA" | IN=="SRI LANAKA" | IN=="SRILANKA" | IN=="SRI LNKA"
replace NAMES="Oman" if IN=="SULTANATE OF OMAN" | IN=="SULTANATE OF OMAN."
replace NAMES="Trinidad" if IN=="TRINDAD" 
replace NAMES="Trinidad and Tobago" if IN=="TRINIDAD & TABAGO" | IN=="TRNIDAD & TOBAGO"
replace NAMES="Tunisia" if IN=="TUNISIE"
replace NAMES="Uganda" if IN=="UGANDA - DISCONTINUED"
replace NAMES="Ukraine" if IN=="UKRAIN"
replace NAMES="Venezuela" if IN=="VENEZEULA" | IN=="VENEZUELAN FOODS"
replace NAMES="Siberia" if IN=="WESTERN SIBERIA"
replace NAMES="Azerbaijan" if IN=="AZERBAYCAN"
replace NAMES="Nicaragua" if IN=="CERRO NEGRO"
replace NAMES="Panama" if IN=="COBRE(PANAMA)"
replace NAMES="Denmark" if IN=="COPENHAGEN"
replace NAMES="Honduras" if IN=="SAN ANDRES MINE"
replace NAMES="Vietnam" if IN=="VEITNAM"
replace NAMES="Zimbabwe" if IN=="ZIMBAWE"

*Group England and Northern Ireland as UK
replace NAMES="United Kingdom" if NAMES=="England" | NAMES=="Northern Ireland" | ///
	NAMES=="england"
********************************************************************************
******                                                                   *******
******   			 ARTICLE: Extraction Payment Disclosures             *******
******  			 AUTHOR: Thomas Rauter                               *******
******               JOURNAL OF ACCOUNTING RESEARCH                      *******
******   			 CODE TYPE: Clean Shaming Channel Data               *******
******   			 LAST UPDATED: August 2020                           *******
******                                                                   *******
********************************************************************************


********************************************************************************
************************* 1. CLEAN MEDIA COVERAGE DATA *************************
********************************************************************************

preserve

// Save EPD data as tempfile
use "$raw_data/epd_masterfile.dta", clear
drop if effective_since == .
tempfile master_file
save `master_file'

// Import media coverage data
use "$raw_data/media_coverage.dta", clear
keep if language == "English"
collapse (sum) number_media_articles, by(gvkey year)

// Merge EPD data
merge m:1 gvkey using `master_file'
drop if _merge == 1
replace number_media_articles = 0 if _merge == 2
drop _merge

// Compute average media coverage prior to EPD
gen effective_since_year = year(effective_since)
gen number_media_articles_before = number_media_articles if year < effective_since_year
drop if year >= effective_since_year | effective_since_year == .
collapse (mean) number_media_articles_before, by(gvkey)
tempfile media_coverage

// Save media coverage data
save `media_coverage'
restore

// Merge media coverage data with EITI payment data
merge m:1 gvkey using `media_coverage', keep(1 3) nogen

// Generate media coverage indicators
local threshold_media_coverage 75
egen threshold_n_m_art_bef = pctile(number_media_articles_before), p(`threshold_media_coverage')

// Define High media coverage
gen high_media_cov_d = .
replace high_media_cov_d = 1 if number_media_articles_before > threshold_n_m_art_bef & number_media_articles_before != .
replace high_media_cov_d = 0 if number_media_articles_before <= threshold_n_m_art_bef & number_media_articles_before != .
replace high_media_cov_d = . if number_media_articles_before == .

// Define Low media coverage
gen low_media_cov_d = .
replace low_media_cov_d = 1 if number_media_articles_before <= threshold_n_m_art_bef & number_media_articles_before != .
replace low_media_cov_d = 0 if number_media_articles_before > threshold_n_m_art_bef & number_media_articles_before != .
replace low_media_cov_d = . if number_media_articles_before == .


********************************************************************************
************************** 2. CLEAN NGO SHAMING DATA ***************************
********************************************************************************

preserve

// Save EPD data as tempfile
use "$raw_data/epd_masterfile.dta", clear
drop if effective_since == .
tempfile master_file
save `master_file'

// Import activist shaming data
if "$analysis_type"=="investment" {
use "$raw_data/asc_investments.dta", clear
}
else{
use "$raw_data/asc_payments.dta", clear
}

keep if ngo_campaign == 1

// Merge EPD data
merge m:1 gvkey using `master_file', keep(2 3)
drop if _merge == 1
gen effective_since_year = year(effective_since)

// Identify NGO campaigns prior to EPD 
gen campaign_before_effective = 0
replace campaign_before_effective = 1 if year < effective_since_year
replace campaign_before_effective = 0 if _merge == 2
collapse (sum) campaign_before_effective, by(gvkey)
	
// Generate NGO shaming indicators

// Target of NGO shaming campaign
gen campaign_before_effective_d = 0
replace campaign_before_effective_d = 1 if campaign_before_effective > 0 & campaign_before_effective != .
replace campaign_before_effective_d =. if campaign_before_effective ==.
label var campaign_before_effective_d "1=firm target of ngo shaming campaign before epd effective; 0=otherwise"

// Never target of NGO shaming campaign
gen no_campaign_before_effective_d =.
replace no_campaign_before_effective_d = 1 if campaign_before_effective_d == 0
replace no_campaign_before_effective_d = 0 if campaign_before_effective_d == 1
label var no_campaign_before_effective_d "1=firm no target of ngo shaming campaign before epd effective; 0=otherwise"

// Keep only relevant variables
keep gvkey campaign_before_effective_d no_campaign_before_effective_d
tempfile activist_shaming_investments
save `activist_shaming_investments'
restore

// Merge NGO shaming data
merge m:1 gvkey using `activist_shaming_investments', keep(1 3) nogen
********************************************************************************
**********                                                            **********
**********      ARTICLE: Extraction Payment Disclosures               **********
**********      AUTHOR: Thomas Rauter                                 **********
**********      JOURNAL OF ACCOUNTING RESEARCH                        **********
**********      CODE TYPE: Run all Do-Files  		                  **********
**********      LAST UPDATED: August 2020                             **********
**********                                                            **********
**********                                                            **********
**********      README / DESCRIPTION:                                 **********
**********      This STATA code runs all do-files that convert        **********
**********      the raw data into my final regression datasets.       **********
**********      The do-files use the raw data listed in Section 2     **********
**********      of the datasheet as input and produce the final       **********
**********	    regression datasets as output.                        **********
**********                                                            **********
********************************************************************************


// Set main directory => copy path into ""
global main_dir ""

global raw_data "$main_dir/00_Raw_Data"
global clean_data "$main_dir/01_Clean_Data"
global final_data "$main_dir/02_Final_data"


********************************************************************************
*****************************  1) PAYMENT ANALYSIS  ****************************
********************************************************************************

	do "$main_dir/1_data_payment.do"
	

********************************************************************************
**************************  2) SEGMENT CAPEX ANALYSIS  *************************
********************************************************************************
	
	do "$main_dir/2_data_segment_capex.do"
	
	
********************************************************************************
**************************  3) PARENT CAPEX ANALYSIS  **************************
********************************************************************************
	
	do "$main_dir/3_data_parent_capex.do"


********************************************************************************
********************** 4) AUCTION PARTICIPATION ANALYSIS ***********************
********************************************************************************

	do "$main_dir/4_data_hist_bidding.do"

	
********************************************************************************
***************************  5) LICENSING ANALYSIS  ****************************
********************************************************************************

	do "$main_dir/5_data_licensing.do"
	

********************************************************************************
*************************  6) PRODUCTIVITY ANALYSIS  ***************************
********************************************************************************

	do "$main_dir/6_data_productivity.do"
********************************************************************************
******                                                                   *******
******   			 ARTICLE: Extraction Payment Disclosures             *******
******  			 AUTHOR: Thomas Rauter                               *******
******               JOURNAL OF ACCOUNTING RESEARCH                      *******
******   			 CODE TYPE: Data Preparation for Payment Analysis    *******
******   			 LAST UPDATED: August 2020                           *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "payment"


********************************************************************************
********** 1. IMPORT PARENT INFORMATION FOR FIRMS IN EITI REPORT DATA **********
********************************************************************************

foreach s in all parent_gvkeys all_update {
	import excel "$raw_data/eiti_data_enrichment.xls", firstrow sheet(`s')
	save "$clean_data/eiti_data_enrich_`s'.dta", replace
clear
}

********************************************************************************
**************************  2. CLEAN COMPUSTAT DATA  ***************************
********************************************************************************

// Compustat North America data
use "$raw_data/compustat_north_america_fundamentals.dta", clear
keep gvkey datadate fyear curcd fyr at capx dlc dltt oibdp sale naics
save "$clean_data/compustat_north_america_fundamentals_clean.dta", replace 

// Compustat Global data
use "$raw_data/compustat_global_fundamentals.dta", clear
keep gvkey datadate fyear curcd fyr at capx dlc dltt oibdp sale naics
save "$clean_data/compustat_global_fundamentals_clean.dta", replace

// Append Compustat North America and Compustat Global data
use "$clean_data/compustat_north_america_fundamentals_clean.dta", clear
append using "$clean_data/compustat_global_fundamentals_clean.dta"

// Drop duplicates
duplicates drop gvkey fyear, force

// Merge exchange rates
rename curcd curcdq
merge m:1 curcdq datadate using "$raw_data/currencies.dta", keepusing(exratm) keep(1 3) nogen
rename at tot_assets

// Convert all currencies to GBP
foreach var of varlist tot_assets capx dlc dltt oibdp sale {
   replace `var' = `var' / exratm
}

// Generate firm fundamentals
gsort gvkey fyear
by gvkey: gen tot_assets_lag1 = tot_assets[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
gen ln_tot_assets = ln(tot_assets)
gen ln_tot_assets_lag1 = ln(tot_assets_lag1)
gen leverage = (dlc + dltt) / tot_assets
gen roa = oibdp / tot_assets_lag1
gen capex_frac = capx / tot_assets_lag1

gsort gvkey fyear
foreach var of varlist leverage roa {
   by gvkey: gen `var'_lag1 = `var'[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
}

// Trim firm fundamentals
foreach var of varlist roa_lag1  {
   winsor2 `var', cuts(1 99) trim
}
foreach var of varlist leverage_lag1 capex_frac {
   winsor2 `var', cuts(0 99) trim
}

// Generate lagged capex variables
gsort gvkey fyear
by gvkey: gen capex_frac_tr_lag1 = capex_frac_tr[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
by gvkey: gen capex_frac_tr_lag2 = capex_frac_tr[_n-2] if ((fyear[_n] == fyear[_n-2] + 2))
by gvkey: gen capex_frac_tr_lag3 = capex_frac_tr[_n-3] if ((fyear[_n] == fyear[_n-3] + 3))
by gvkey: gen capex_frac_tr_lag4 = capex_frac_tr[_n-4] if ((fyear[_n] == fyear[_n-4] + 4))
by gvkey: gen capex_frac_tr_lag5 = capex_frac_tr[_n-5] if ((fyear[_n] == fyear[_n-5] + 5))

// Generate year variable for merging with EITI data
gen year = fyear
drop if year ==.

// Drop variables without gvkey and drop duplicates
drop if gvkey == ""
duplicates drop gvkey year, force

// Convert year variable to string
gen yr = year
tostring yr, replace
drop year
gsort gvkey yr

// Save firm fundamentals data
save "$clean_data/compustat_fundamentals.dta", replace
clear

********************************************************************************
******** 3. CLEAN CORRUPTION PERCEPTIONS DATA FOR CROSS-SECTIONAL TESTS ********
********************************************************************************

// Import and clean Corruption Perceptions Index (CPI) for 2013
import excel "$raw_data/CPI_2005_2018.xlsx", firstrow sheet(CPI_2013) clear
save "$clean_data/2013_CPI.dta", replace
use "$clean_data/2013_CPI.dta", clear

drop if year >=.
replace country = "Democratic Republic of Congo" if (country == "Congo, Democratic Republic")
replace country = "Democratic Republic of Congo" if (country == "Congo. Democratic Republic")
gsort country year

gen cpi_13 = 0
replace cpi_13 = cpi if (year == 2013)

// Classify countries as highly- or less corrupt based on 2013 CPI
gen corrupt_host_cty = 0
replace corrupt_host_cty = 1 if (cpi_13 <= 28) // CPI value of 28 = 25th percentile

gen non_corrupt_host_cty = 0
replace non_corrupt_host_cty = 1 if (cpi_13 > 28)

lab var corrupt_host_cty "Corrupt Country"
lab var non_corrupt_host_cty "Non-Corrupt Country"

// Save CPI data
save "$clean_data/CPI_2013_new.dta", replace
clear

********************************************************************************
******************* 4. IMPORT PAYMENT DATA FROM EITI REPORTS ******************* 
********************************************************************************

import excel "$raw_data/eiti_country_company_payments_FINAL.xlsx", firstrow clear

// Rename variables
rename paymentgovernmentreconciled pmt_gov_reconciled
rename governmentinitial pmt_gov_initial
rename companygovernment pmt_gap_com_gov
rename commodity commodity_reported

lab var country "Country"
lab var year "Year"
lab var currency "Currency"
lab var unit "Unit"
lab var company "Company"
lab var identification_number "ID_Number"
lab var commodity_reported "Commodity Reported"
lab var pmt_gov_reconciled "Payment Government Reconciled"
lab var pmt_gov_initial "Payment Government Initial"
lab var pmt_gap_com_gov "Payment Reported by Company - Payment Received by Government"

// Drop missing payment observations
drop if pmt_gov_initial >=.
gsort country year company

// Merge parent company information
foreach file in all all_update {
if "`file'"=="all"{
merge m:1 company country ///
using "$clean_data/eiti_data_enrich_`file'.dta"
drop _merge
}
else{
merge m:1 company country ///
using "$clean_data/eiti_data_enrich_`file'.dta", update
drop _merge
}
}

// Merge Compustat data
merge m:1 parent parent_country ///
using "$clean_data/eiti_data_enrich_parent_gvkeys.dta", update keep(1 3 4 5) nogen

gen yr = year
forvalues v = 2009/2015{
local next = `v' + 1
display `next'
replace yr = "`v'" if yr == "`v'-`next'"
}

merge m:1 gvkey yr using "$clean_data/compustat_fundamentals.dta", keep(1 3) nogen

********************************************************************************
********** 5. CONVERT PAYMENT VARIABLES FROM LOCAL CURRENCY INTO GBP ***********
********************************************************************************
gsort country year

preserve
import excel "$raw_data/fx_rates_payments.xlsx", firstrow clear
gen fx_eop = (period_end_gbp_fx_bid + period_end_gbp_fx_ask) / 2
save "$clean_data/fx_payments.dta", replace
restore

merge m:1 country currency year unit ///
using "$clean_data/fx_payments.dta", keepusing(fx_eop) keep(1 3) nogen

lab var fx_eop "FX End of Period"

foreach var of varlist pmt_gov_initial pmt_gap_com_gov resolved unresolved {
   gen `var'_gbp = `var' * unit * fx_eop
}

forvalues v = 2009/2015{
local next = `v' + 1
replace year = "`v'.5" if year == "`v'-`next'"
}
destring year, replace

********************************************************************************
**************  6. MERGE EPD DATA AND CROSS-SECTIONAL VARIABLES ****************
********************************************************************************

// Merge EPD masterfile 
merge m:1 gvkey using "$raw_data/epd_masterfile.dta", keep(1 3) nogen

// Merge CPI data
kountry country, from(other) stuck
gen country_intermed = _ISO3N_
kountry country_intermed, from(iso3n) to(iso3c)
rename _ISO3C_ segment_country
drop _ISO3N_

kountry parent_country, from(other) stuck
gen parent_country_intermed = _ISO3N_
kountry parent_country_intermed, from(iso3n) to(iso3c)
rename _ISO3C_ loc

merge m:1 country using "$clean_data/CPI_2013_new.dta", keep(1 3) nogen

egen corrupt_new = max(corrupt_host_cty), by(country)
egen non_corrupt_new = max(non_corrupt_host_cty), by(country)

// Merge shaming channel data
do "$code/clean_shaming_data.do"


********************************************************************************
**********************  7. CLEAN SUBSIDIARY NAMES  *****************************
********************************************************************************
do "$code/clean_company_name.do"


********************************************************************************
************************  8. PREPARE REGRESSION SAMPLE *************************
********************************************************************************

// Rename variables
rename pmt_gov_initial_gbp pmt_gov
rename pmt_gap_com_gov_gbp pmt_gap
rename resolved_gbp res
gen pmt_company = pmt_gap + pmt_gov

// Drop missing year observations
drop if year >=.

// Define EPD treatment indicators
gen EPD_effective_year_masterfile = year(effective_since)
gen EPD_implementation_wave = 0
replace EPD_implementation_wave = 1 if (EPD_effective_year_masterfile == 2014)
replace EPD_implementation_wave = 2 if (EPD_effective_year_masterfile == 2015)
replace EPD_implementation_wave = 3 if (EPD_effective_year_masterfile == 2016)
 
// Generate dependent variables
gen pmt_tot_assets = pmt_company / (tot_assets_lag1 * 1000000)
replace pmt_tot_assets =. if (pmt_tot_assets < 0)

// Trim dependent variables
winsor2 pmt_tot_assets, cuts(1 99) trim

// Multiply dependent variables by 100
gen pmt_tot_assets_tr_100 = pmt_tot_assets_tr * 100
gen pmt_tot_assets_100 = pmt_tot_assets * 100

// Generate EPD indicators
gen EPD = 0
replace EPD = 1 if ((EPD_implementation_wave == 1 & year > 2013 & year <.) | (EPD_implementation_wave == 2 & year > 2014 & year <.) | (EPD_implementation_wave == 3 & year > 2015 & year <.))

// Generate event-time indicators
gen EPD_0plus = EPD

gen EPD_minus1 = 0
replace EPD_minus1 = 1 if ((EPD_implementation_wave == 1 & (year == 2013 | year == 2012.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2014 | year == 2013.5) & year <.)  | (EPD_implementation_wave == 3 & (year == 2015 | year == 2014.5) & year <.))

gen EPD_minus2 = 0
replace EPD_minus2 = 1 if ((EPD_implementation_wave == 1 & (year == 2012 | year == 2011.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2013 | year == 2012.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2014 | year == 2013.5) & year <.))

gen EPD_minus3 = 0
replace EPD_minus3 = 1 if ((EPD_implementation_wave == 1 & (year == 2011 | year == 2010.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2012 | year == 2011.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2013 | year == 2012.5) & year <.))

gen EPD_minus4 = 0
replace EPD_minus4 = 1 if ((EPD_implementation_wave == 1 & (year == 2010 | year == 2009.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2011 | year == 2010.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2012 | year == 2011.5) & year <.))

gen EPD_minus5 = 0
replace EPD_minus5 = 1 if ((EPD_implementation_wave == 1 & (year == 2009 | year == 2008.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2010 | year == 2009.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2011 | year == 2010.5) & year <.))

gen EPD_3minus = 0
replace EPD_3minus = 1 if (EPD_minus3 == 1  | EPD_minus4 == 1  | EPD_minus5 == 1)

// High vs. low corruption in host country
gen EPD_corrupt_host_cty = EPD * corrupt_host_cty
gen EPD_non_corrupt_host_cty = EPD * non_corrupt_host_cty

// Foreign vs. domestic host country
gen foreign_host_cty = 0
replace foreign_host_cty = 1 if (country != parent_country)

gen domestic_host_cty = 0
replace domestic_host_cty = 1 if (country == parent_country)

gen EPD_foreign_host_cty = EPD * foreign_host_cty
gen EPD_domestic_host_cty = EPD * domestic_host_cty

// Company subject to high vs. low media coverage
replace high_media_cov_d = 0 if high_media_cov_d ==.
replace low_media_cov_d = 0 if low_media_cov_d ==.
gen EPD_high_media_cov = EPD * high_media_cov_d
gen EPD_low_media_cov = EPD * low_media_cov_d

// Company target vs. no target of NGO shaming campaign
replace campaign_before_effective_d = 0 if campaign_before_effective_d ==.
replace no_campaign_before_effective_d = 0 if no_campaign_before_effective_d ==.

gen EPD_activist_campaign = EPD * campaign_before_effective_d
gen EPD_no_activist_campaign = EPD * no_campaign_before_effective_d

// Identify micro firms with less than USD 10 mn in total assets
gen small = 0
replace small = 1 if (tot_assets < 6.2) // USD 10 mn * average USD/GBP FX rate; results also hold when including micro firms

// Keep only relevant variables
rename effective_since EPD_effective_since

keep pmt_tot_assets_100 pmt_tot_assets_tr_100 EPD_implementation_wave EPD EPD_effective_since ln_tot_assets_lag1 tot_assets_lag1 tot_assets roa_lag1_tr leverage_lag1_tr ///
EPD_corrupt_host_cty EPD_non_corrupt_host_cty naics yr year country parent_country company_cleaned parent ///
corrupt_host_cty non_corrupt_host_cty EPD_activist_campaign EPD_no_activist_campaign EPD_high_media_cov EPD_low_media_cov gvkey ///
part_of_annual_report EPD_foreign_host_cty EPD_domestic_host_cty capex_frac_tr capex_frac_tr_lag1 capex_frac_tr_lag2 capex_frac_tr_lag3 capex_frac_tr_lag4 capex_frac_tr_lag5 ///
EPD_0plus EPD_minus1 EPD_minus2 EPD_minus3 EPD_minus4 EPD_minus5 EPD_3minus small company_standardized fyear pmt_company oibdp sale

// Label variables
lab var capex_frac_tr "Capex_t/Total Assets_t-1 - Trimmed"
lab var capex_frac_tr_lag1 "Capex_t-1/Total Assets_t-2 - Trimmed"
lab var capex_frac_tr_lag2 "Capex_t-2/Total Assets_t-3 - Trimmed"
lab var capex_frac_tr_lag3 "Capex_t-3/Total Assets_t-4 - Trimmed"
lab var part_of_annual_report "Corrupt Host Country - CPI 2013 larger than 25"
lab var pmt_tot_assets_100 "Government Payments/Tot. Assets x 100"
lab var pmt_tot_assets_tr_100 "Government Payments/Tot. Assets x 100 - Trimmed"
lab var EPD_effective_since "EPD Effective Since - Date"
lab var country "Host Country"
lab var parent_country "Parent Country"
lab var company_cleaned "Clean Company Name"
lab var parent "Parent Company"
lab var year "Year(s) of EITI report coverage"
lab var yr "Year"
lab var naics "North American Industry Classification (NAICS) code"
lab var gvkey "Compustat Global Company Key (GVKEY)"
lab var EPD_implementation_wave "EPD Waves of Implementation"

// Define sample
drop if year < 2010
drop if small == 1

// Generate dependent variable
gen ln_payment = ln(1 + pmt_tot_assets_100)

// Generate fixed effects
gen naics3 = substr(naics,1,3)
encode naics3, gen(naics_3no)
egen naics3_year = group(naics_3no year)
rename naics3_year resource_year_FE

egen firm_subsidiary_FE = group(company_cleaned)
egen host_country_year_FE = group(country year)

egen treated = max(EPD), by(parent)
egen treated_year_FE = group(treated year)

// Label regression variables
label var ln_payment "Ln(1+Extractive Payment/Total Assets\textsubscript{t-1} $\times$ 100)"
label var EPD "EPD"
label var EPD_corrupt_host_cty "EPD $\times$ Highly Corrupt Host Country"
label var EPD_non_corrupt_host_cty "EPD $\times$ Less Corrupt Host Country"
label var EPD_foreign_host_cty "EPD $\times$ Foreign Host Country"
label var EPD_domestic_host_cty "EPD $\times$ Domestic Host Country"
label var ln_tot_assets_lag1 "\emph{Control Variables:} \vspace{0.1cm} \\ Ln(Total Assets\textsubscript{t-1})"
label var roa_lag1_tr "Return on Assets\textsubscript{t-1}"
label var leverage_lag1_tr "Leverage\textsubscript{t-1}"
label var corrupt_host_cty "Highly Corrupt Host Country"
label var non_corrupt_host_cty "Less Corrupt Host Country"
label var EPD_activist_campaign "EPD $\times$ Target of NGO Shaming Campaign"
label var EPD_no_activist_campaign "EPD $\times$ Never Target of NGO Shaming Campaign"
label var EPD_high_media_cov "EPD $\times$ High Media Coverage"
label var EPD_low_media_cov "EPD $\times$ Low Media Coverage"


// Save cleaned and merged payment dataset
save "$final_data/payment_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******   	 ARTICLE: Extraction Payment Disclosures                     *******
******  	 AUTHOR: Thomas Rauter                                       *******
******       JOURNAL OF ACCOUNTING RESEARCH                              *******
******       CODE TYPE: Data Preparation for Segment Capex Analysis      *******
******   	 LAST UPDATED: August 2020                                   *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "investment"


********************************************************************************
*********************  1. EXTRACT GVKEYs AND NAICS CODES  **********************
********************************************************************************

// Compustat North America
import delimited "$raw_data/compustat_north_america_naics.txt", clear stringcols(_all)
gen dummy = 1
collapse (sum) dummy, by(gvkey cusip naics)
drop dummy
drop if cusip == ""
isid gvkey cusip 
save "$clean_data/compustat_north_america_naics.dta", replace 

// Compustat Global
import delimited "$raw_data/compustat_global_naics.txt", clear stringcols(_all)
gen dummy = 1
collapse (sum) dummy, by(gvkey sedol isin naics)
drop dummy
replace isin = "missing" if isin == "" 
replace sedol = "missing" if sedol == "" 

// Check that (i) gvkey-sedol and (ii) gvkey-isin uniquely identify observations
isid gvkey sedol
isid gvkey isin 

save "$clean_data/compustat_global_naics.dta", replace


********************************************************************************
**********************  2. CLEAN WORLDSCOPE SEGMENT DATA  **********************
********************************************************************************

import delimited "$raw_data/segment_data_worldscope_2017.csv", clear

replace freq="1" if freq=="A"
replace freq="2" if freq=="B"
destring freq, replace
label define freq 1 "Annual" 2 "Restated-Annual"
label values freq freq

// Firm identifying information
rename item6008 isin
label variable isin "ISIN"
rename item6004 cusip
label variable cusip "CUSIP"
rename item6006 sedol
label variable sedol "SEDOL"
rename item5601 ticker 
label variable ticker "TICKER"
rename item6105 ws_id 
label variable ws_id "Worldscope Identifier"
rename item6001 name 
label variable name "Company Name"
rename item6026 nation 
label variable nation "Country Out; country where the company is headquartered"
rename item6027 nation_code
label variable nation_code "Country Out code"
rename item6028 region
label variable region "Region of the world where the company is headquartered"
rename year_ year
label variable year "Year"
rename item5352 fyearend
label variable fyearend "Fiscal Year End"

// Identify geographic segments (each firm has up to 10 segments)
local segment 1 2 3 4 5 6 7 8 9 10
foreach segment in `segment' {
	local item=`segment'-1
	di `segment'
	di `item'
	rename item196`item'0 segment_description`segment'
	label var segment_description`segment' "Segment Description"
	rename item196`item'3 segment_assets`segment'
	label var segment_assets`segment' "Segment Assets"
	rename item196`item'4 segment_capex`segment'
	label var segment_capex`segment' "Segment Capital Expenditure"
	}
drop item*

keep if year >= 2000

// Keep unique ws_id-year observations (segments are still separate variables in wide format)
sort ws_id year freq
by ws_id year: generate duplicate=cond(_N==1, 0, _n)

keep if duplicate==0 | (duplicate==2 & freq==2)
drop duplicate

isid ws_id year
order nation nation_code, after(ws_id)

// Generate lagged parent assets and merge to segment dataset
preserve
	use "$raw_data/firm_fundamentals_worldscope_parent.dta", clear
	rename total_assets tot_assets_USD // Total Assets in USD (item 07230)
	keep ws_id year tot_assets_USD
	rename tot_assets_USD tot_assets_USD_lag1
	replace year = year + 1
	tempfile tot_assets_USD_lag1
	save `tot_assets_USD_lag1'
restore
merge 1:1 ws_id year using `tot_assets_USD_lag1', keep(1 3) nogen

// Reshape dataset to long format
reshape long segment_description segment_capex segment_oic segment_assets, i(ws_id year) j(segment)
duplicates drop

// Merge parent fundamentals and drop observations without segment data
merge m:1 ws_id year using "$raw_data/firm_fundamentals_worldscope_parent.dta", keepusing(total_assets roa total_assets_local total_liabilities_local) keep(1 3) nogen
rename total_assets tot_assets_USD


********************************************************************************
******************  3. CLEAN AND STANDARDIZE COUNTRY NAMES  ********************
********************************************************************************

// Cleaning of country-in names
replace segment_description=upper(segment_description)
replace segment_description=subinstr(segment_description, "(COUNTRY)", "", .)
do "$code/clean_country_name.do"

// Standardize country names
rename MARKER CHECK1
kountry NAMES, from(other) marker
drop NAMES
rename NAMES_STD Country_In
label variable Country_In "Capex Destination Country"
rename nation Country_Out
drop if MARKER==0
drop MARKER

// Generate ISO3 codes and country names
kountry Country_In, from(other) stuck marker
drop if Country_In=="European Union"
drop MARKER

rename _ISO3N_ Country_In_iso3N
kountry Country_In_iso3N, from(iso3n) to(iso3c) marker
drop NAMES_STD MARKER
rename _ISO3C_ Country_In_iso3C

replace Country_Out="British Virgin Islands" if Country_Out=="VIRGIN ISLANDS(BRIT)" | ///
	    Country_Out=="Virgin Islands" | Country_Out=="VIRGIN ISLANDS (BRIT)"
		
kountry Country_Out, from(other) marker
drop Country_Out MARKER
rename NAMES_STD Country_Out 

kountry Country_Out, from(other) stuck marker
drop MARKER

rename _ISO3N_ Country_Out_iso3N
kountry Country_Out_iso3N, from(iso3n) to(iso3c) marker
drop NAMES_STD MARKER
rename _ISO3C_ Country_Out_iso3C

replace Country_Out_iso3C="GGY" if Country_Out=="guernsey"
replace Country_Out_iso3C="IMN" if Country_Out=="isle of man"
replace Country_Out_iso3C="JEY" if Country_Out=="jersey"
drop if Country_In_iso3C=="" | Country_Out_iso3C==""


********************************************************************************
******************  4. CONVERT SEGMENT CAPEX INTO USD AMOUNTS  *****************
********************************************************************************

// Merge exchange rate dataset
replace nation_code = 840 if Country_Out == "United States" & nation_code == . // if nation_code is missing but country_out is United States -> replace with US nation_code
label define nation_codes 012 "Algeria" 422 "Lebanon" 025 "Argentina" 428 "Latvia" 036 "Australia" 440 "Lithuania" ///
040 "Austria" 442 "Luxembourg" 044 "Bahamas" 454 "Malawi" 048 "Bahrain" 458 "Malaysia" ///
052 "Barbados" 470 "Malta" 056 "Belgium" 480 "Mauritius" 060 "Bermuda" 484 "Mexico" ///
068 "Bolivia" 496 " Mongolia" 070 "Bosnia and Herzegovina" 499 "Montenegro" ///
072 "Botswana" 504 "Morocco" 076 " Brazil" 516 "Namibia" 092 "British Virgin Islands" ///
528 "Netherlands" 100 "Bulgaria" 554 "New Zealand" 124 "Canada" 566 "Nigeria" ///
136 "Cayman Islands" 578 "Norway" 152 "Chile" 582 "Oman" 156 "China" 586 "Pakistan" ///
175 "Colombia" 591 "Panama" 178 "Costa Rica" 597 "Peru" 182 "Cote d’Ivoire" 593 "Paraguay" ///
191 "Croatia" 608 " Philippines" 196 "Cyprus" 617 "Poland" 203 "Czech Republic" 620 "Portugal" ///
208 "Denmark" 634 "Qatar" 214 "Dominican Republic" 642 "Romania" 218 "Ecuador" 643 "Russia" ///
220 "Egypt" 682 "Saudi Arabia" 222 "El Salvador" 688 "Serbia" 233 "Estonia" 702 "Singapore" ///
234 "Faroe Islands" 703 "Slovakia" 242 "Fiji" 704 "Vietnam" 246 "Finland" 705 "Slovenia" ///
250 "France" 710 "South Africa" 268 "Georgia" 724 "Spain" 275 "Palestine" 730 "Sri Lanka" ///
280 "Germany" 736 "Sudan" 300 "Greece" 748 "Swaziland" 320 "Guatemala" 752 "Sweden" ///
328 "Guyana" 756 "Switzerland" 340 "Honduras" 760 "Taiwan" 344 "Hong Kong" 764 "Thailand" ///
350 "Hungary" 780 "Trinidad and Tobago" 352 "Iceland" 784 "United Arab Emirates" ///
356 "India" 788 "Tunisia" 366 "Indonesia" 796 "Turkey" 372 "Ireland" 800 "Uganda" ///
376 "Israel" 804 "Ukraine" 380 "Italy" 807 "Macedonia" 388 "Jamaica" 826 "United Kingdom" ///
392 "Japan" 833 "Isle of Man" 398 "Kazakhstan" 834 "Tanzania" 400 "Jordan" 840 "United States" ///
404 "Kenya" 862 "Venezuela" 410 "South Korea" 894 "Zambia" 414 "Kuwait" 897 "Zimbabwe" ///
831 "South Africa" 50 "Bangladesh" 116 "Cambodia" 120 "Cameroon" 288 "Ghana" 369 "Iraq" ///
646 "Rwanda" 686 "Senegal" 860 "Uzbekistan"

label values nation_code nation_codes
decode nation_code, generate(currency_country)
replace currency_country = strtrim(currency_country)

// Generate ISO3 codes for currency country
kountry currency_country, from(other) stuck marker
drop MARKER
rename _ISO3N_ currency_country_iso3N
kountry currency_country_iso3N, from(iso3n) to(iso3c) marker
drop MARKER NAMES currency_country_iso3N
rename _ISO3C_ currency_country_iso3C
replace currency_country_iso3C = "CIV" if nation_code == 182

// Merge World Bank exchange rate data
merge m:1 currency_country_iso3C year using "$raw_data/exchange_rates_2017" 
drop if _m==2
drop _m

// Transform values into USD millions
gen segment_capex_USD = segment_capex / (exchangerate * 1000000)
gen segment_assets_USD = segment_assets / (exchangerate * 1000000)

// Order variables
order Country_Out Country_Out_iso3C, before(Country_In)
order year fyearend, before(segment_capex_USD)


********************************************************************************
*************************  5. CLEAN AND MERGE CPI DATA  ************************
********************************************************************************

// Construct CPI panel from 1998 to 2017
preserve

* Import 1998 to 2015 data
import excel "$raw_data/cpi_1998_2015.xlsx", first clear
destring  cpi1998 cpi1999 cpi2000 cpi2001 cpi2002 cpi2003 cpi2004 cpi2005 cpi2006 cpi2007 ///
          cpi2008 cpi2009 cpi2010 cpi2011 cpi2012 cpi2013 cpi2014 cpi2015, force replace
tempfile 1998_2015
save `1998_2015'

* Import 2016 data
import excel "$raw_data/cpi_2016.xlsx", first clear sheet(CPI2016_FINAL_16Jan)
rename Country country
rename CPI2016 cpi2016
keep country cpi2016
tempfile 2016
save `2016'

* Import 2017 data
import excel "$raw_data/cpi_2017.xls", first clear sheet(CPI 2017) cellrange(A3)
rename Country country
rename CPIScore2017 cpi2017
rename ISO3 iso3
drop if country == "" | country == "GLOBAL AVARAGE"
keep country cpi2017
tempfile 2017
save `2017'

* Merge datasets
use `1998_2015', clear
merge m:1 country using `2016'
drop _merge
gsort country

merge m:1 country using `2017'
drop _merge
gsort country

* Reshape to long format
gen id = _n
reshape long cpi, i(id) j(year 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 /// 
2008 2009 2010 2011 2012 2013 2014 2015 2016 2017)

* Generate ISO3 country codes
kountry country, from(other) stuck
replace _ISO3N_ = 70 if country == "Bosnia and Herzgegovina"
replace _ISO3N_ = 180 if country == "Congo Democratic Republic"
replace _ISO3N_ = 178 if country == "Congo Republic"
replace _ISO3N_ = 178 if country == "Congo-Brazzaville"
replace _ISO3N_ = 180 if country == "Congo. Democratic Republic"
replace _ISO3N_ = 178 if country == "Congo. Republic"
replace _ISO3N_ = 384 if country == "Cote d´Ivoire"
replace _ISO3N_ = 203 if country == "Czech Republik"
replace _ISO3N_ = 384 if country == "Côte d´Ivoire"
replace _ISO3N_ = 384 if country == "Côte d’Ivoire"
replace _ISO3N_ = 384 if country == "Côte-d'Ivoire"
replace _ISO3N_ = 384 if country == "Côte D'Ivoire"
replace _ISO3N_ = 132 if country == "Cabo Verde"
replace _ISO3N_ = 807 if country == "FYR Macedonia"
replace _ISO3N_ = 414 if country == "Kuweit"
replace _ISO3N_ = 807 if country == "Macedonia (Former Yugoslav Republic of)"
replace _ISO3N_ = 498 if country == "Moldovaa"
replace _ISO3N_ = 275 if country == "Palestinian Authority "
replace _ISO3N_ = 178 if country == "Republic of Congo "
replace _ISO3N_ = 762 if country == "Taijikistan "
replace _ISO3N_ = 807 if country == "The FYR of Macedonia"
replace _ISO3N_ = 275 if country == "Palestinian Authority"
replace _ISO3N_ = 178 if country == "Republic of Congo"
replace _ISO3N_ = 762 if country == "Taijikistan"
replace _ISO3N_ = 688 if country == "Serbia"

gen country_intermed = _ISO3N_
kountry country_intermed, from(iso3n) to(iso3c)

* Fix ISO3 code errors
replace _ISO3C_="SRB" if country=="Serbia"
replace _ISO3C_="SCG" if country=="Serbia and Montenegro" | country=="Serbia & Montenegro"
replace _ISO3C_="KSV" if country=="Kosovo"

* Drop CPI duplicates
replace cpi = 0 if (cpi ==.)
collapse (max) cpi, by(_ISO3C_ year)

rename _ISO3C_ iso3
drop if iso3 == ""
replace cpi =. if (cpi == 0)
duplicates report iso3 year

* Rescale data before 2012 (1998-2011: 0-10; 2012-2016: 0-100)
replace cpi = cpi * 10 if (year < 2012)
rename iso3 iso3_code
label variable cpi "CPI - Transparency International"

* Ensure data is unique at country-year level
isid iso3_code year

* Save CPI dataset
save "$clean_data/cpi_1998_2017.dta", replace
restore

preserve
	use "$clean_data/cpi_1998_2017.dta", clear
	drop if cpi==.
	rename iso3_code Country_In_iso3C
	rename cpi cpi_in
	save "$clean_data/cpi_in.dta", replace
    rename Country_In_iso3C Country_Out_iso3C
	rename cpi_in cpi_out
	save "$clean_data/cpi_out.dta", replace
restore

* Merge CPI of Country_In 
merge m:1 Country_In_iso3C year using "$clean_data/cpi_in.dta", keep(1 3) nogen
order cpi_in, after(Country_In_iso3C)

* Merge CPI of Country_Out
merge m:1 Country_Out_iso3C year using "$clean_data/cpi_out.dta", keep(1 3) nogen

// Save cleaned Worldscope segment dataset
save "$clean_data/clean_worldscope_segment_panel.dta", replace


********************************************************************************
**********************  6. MERGE GVKEYs AND NAICS CODES  ***********************
********************************************************************************

use "$clean_data/clean_worldscope_segment_panel.dta", clear

// Merge North American gvkeys and naics codes based on CUSIP
merge m:1 cusip using "$raw_data/gvkey_to_naics_north_america.dta", keep(1 3) nogen
rename gvkey NAgvkey
rename naics NAnaics

// Merge Global gvkeys and naics codes based on SEDOL
preserve
use "$raw_data/gvkey_to_naics_global.dta", clear
keep gvkey sedol naics
duplicates drop sedol, force
save "$raw_data/gvkey_to_naics_global_sedol.dta", replace
restore

merge m:1 sedol using "$raw_data/gvkey_to_naics_global_sedol.dta", keepusing(gvkey naics) keep(1 3) nogen
rename gvkey GSgvkey
rename naics GSnaics

// Merge Global gvkeys and naics codes based on ISIN
preserve
use "$raw_data/gvkey_to_naics_global.dta", clear
keep gvkey isin naics
duplicates drop isin, force
save "$raw_data/gvkey_to_naics_global_isin.dta", replace
restore

merge m:1 isin using "$raw_data/gvkey_to_naics_global_isin.dta", keepusing(gvkey naics) keep(1 3) nogen
rename gvkey GISINgvkey
rename naics GISINnaics

// Get unique identifier
replace NAgvkey = GSgvkey if NAgvkey == ""
replace NAgvkey = GISINgvkey if NAgvkey == ""
rename NAgvkey gvkey
label var gvkey "gvkey"
drop GSgvkey GISINgvkey
sort gvkey

// Generate NAICS code
replace NAnaics = GSnaics if NAnaics == ""
replace NAnaics = GISINnaics if NAnaics == ""
rename NAnaics naics
label var naics "NAICS"
drop GSnaics GISINnaics

// Order variables
order ws_id gvkey ticker cusip sedol isin name region year segment IN fyearend /// 
freq nation_code segment_capex segment_oic segment_assets ///
segment_capex_USD segment_assets_USD naics Country_Out ///
Country_Out_iso3C Country_In Country_In_iso3C cpi_in cpi_out currency_country ///
currency_country_iso3C exchangerate in_euro

// Drop duplicates and observations with multiple values at firm x country-in x year-level
sort ws_id Country_In year IN 
duplicates tag ws_id Country_In year, generate(tagged)
duplicates drop ws_id Country_In IN year segment_capex segment_assets segment_oic, force
drop if tagged != 0


********************************************************************************
************************  7. PREPARE REGRESSION SAMPLE  ************************
********************************************************************************

egen segment_id = group(ws_id Country_In)

// Generate lagged parent fundamentals
preserve
	keep ws_id year tot_assets_USD roa total_assets_local total_liabilities_local
	foreach v of var tot_assets_USD roa total_assets_local total_liabilities_local {
	rename `v' `v'_lag1
	label var `v'_lag1 "`v'_t-1"
	}
	replace year = year + 1
	duplicates drop ws_id year, force
	tempfile lagged_parent_controls
	save `lagged_parent_controls'
restore
merge m:1 ws_id year using `lagged_parent_controls', keep(1 3) nogen

// Merge EPD masterfile
merge m:1 gvkey using "$raw_data/epd_masterfile.dta", force
drop if _merge == 2
replace report = 0 if report == .

// Keep extractive firms (NAICS code of 21 or 324 OR EPD reporting)
gen naics_2 = substr(naics, 1, 2)
gen naics_3 = substr(naics, 1, 3)
keep if naics_2 == "21" | naics_3 == "324" | _merge == 3
drop _merge

// Generate EPD variable
gen EPD_effective_since_year = year(effective_since)

gen EPD = 0
replace EPD = 1 if year >= EPD_effective_since_year
label var EPD_effective "EPD"

// Merge public shaming data
gen loc = Country_Out_iso3C
do "$code/clean_shaming_data.do"

// Foreign vs. domestic segment indicators
gen foreign = 0
replace foreign = 1 if (Country_In_iso3N != Country_Out_iso3N)
gen domestic = 0
replace domestic = 1 if (Country_In_iso3N == Country_Out_iso3N)

gen EPD_foreign_host_cty = EPD * foreign
gen EPD_domestic_host_cty = EPD * domestic

// High vs. low corruption in host country
gen cpi_2013 = cpi_in if year == 2013
gsort Country_In_iso3C
by Country_In_iso3C: egen cpi_2013_max = max(cpi_2013)

gen corrupt_host_cty = 0
replace corrupt_host_cty = 1 if (cpi_2013_max <= 28) // CPI value of 28 = 25th percentile
gen non_corrupt_host_cty = 0
replace non_corrupt_host_cty = 1 if (cpi_2013_max > 28)

gen EPD_corrupt_host_cty = EPD * corrupt_host_cty
gen EPD_non_corrupt_host_cty = EPD * non_corrupt_host_cty

// Company subject to high vs. low media coverage
replace high_media_cov_d = 0 if high_media_cov_d ==.
replace low_media_cov_d = 0 if low_media_cov_d ==.
gen EPD_high_media_cov = EPD * high_media_cov_d
gen EPD_low_media_cov = EPD * low_media_cov_d

// Company target vs. no target of NGO shaming campaign
replace campaign_before_effective_d = 0 if campaign_before_effective_d ==. 
replace no_campaign_before_effective_d = 0 if no_campaign_before_effective_d ==. 
gen EPD_activist_campaign = EPD * campaign_before_effective_d
gen EPD_no_activist_campaign = EPD * no_campaign_before_effective_d

// Generate dependent variable
gen seg_capex_ta = segment_capex_USD / (tot_assets_USD_lag1 / 1000000)
gen seg_capex_ta_100 = seg_capex_ta * 100

// Generate control variables
gen ln_tot_assets_lag1 = ln(tot_assets_USD_lag1)

gen leverage_lag1 = total_liabilities_local_lag1 / total_assets_local_lag1
winsor2 leverage_lag1, cuts(0 95) trim

winsor2 roa_lag1, cuts(5 95) trim
replace roa_lag1_tr = roa_lag1_tr / 100

// Drop negative segment capex observations
drop if seg_capex_ta < 0

// Generate Total Assets in USD millions
gen tot_assets_mn_USD = tot_assets_USD / 1000000

// Identify tax havens 
gen imf_1_in = 0
replace imf_1_in = 1 if (Country_In == "Guernsey" | Country_In == "Hong Kong" | Country_In == "Ireland" | Country_In == "Isle of Man" | Country_In == "Jersey" | Country_In == "Luxembourg" | Country_In == "Singapore" | Country_In == "Switzerland")

gen imf_2_in = 0
replace imf_2_in = 1 if (Country_In == "Andorra" | Country_In == "Bahrain" | Country_In == "Barbados" | Country_In == "Bermuda" | Country_In == "Gibraltar" | Country_In == "Macao" | Country_In == "Malaysia" | Country_In == "Malta" | Country_In == "Monaco")

gen imf_3_in = 0
replace imf_3_in = 1 if (Country_In == "Anguilla" | Country_In == "Antigua and Barbuda" | Country_In == "Aruba" | Country_In == "Bahamas" | Country_In == "Belize" | Country_In == "British Virgin Islands" ///
				    | Country_In == "Cayman Islands" | Country_In == "Cook Islands" | Country_In == "Costa Rica" | Country_In == "Cyprus" | Country_In == "Dominica" | Country_In == "Grenada" ///
					| Country_In == "Lebanon" | Country_In == "Liechtenstein" | Country_In == "Marshall Islands" | Country_In == "Mauritius" | Country_In == "Montserrat" | Country_In == "Nauru" ///
					| Country_In == "Netherlands Antilles" | Country_In == "Niue" | Country_In == "Panama" | Country_In == "Palau" | Country_In == "Samoa"  | Country_In == "Seychelles"  | Country_In == "St. Kitts and Nevis"  ///
					| Country_In == "St. Lucia" | Country_In == "St. Vincent and the Grenadines"  | Country_In == "Turks and Caicos Islands"  | Country_In == "Vanuatu")							
			
// Drop tax havens
keep if imf_1_in == 0 & imf_2_in == 0 & imf_3_in == 0

// Define sample
keep if year >= 2010 & year <= 2017
keep if seg_capex_ta < 0.10 & tot_assets_mn_USD > 10

// Keep segments with at least 1 observation in the pre- and post-2014 periods (results also hold without this restriction)
gen pre = 0
replace pre = 1 if year < 2014
gen post = 0
replace post = 1 if year >= 2014

egen segment_group = group(ws_id Country_In) 
bysort segment_group: egen pre_obs = sum(pre)
bysort segment_group: egen post_obs = sum(post)
keep if pre_obs > 0 & post_obs > 0

// Generate fixed effects and groups
egen firm_subsidiary_FE = group(ws_id Country_In_iso3C)
encode naics_3, gen(naics_3no)
egen resource_year_FE = group(naics_3no year)
egen host_country_year_FE = group(Country_In_iso3C year)
egen parent_country_FE = group(Country_Out)
egen treated_year_FE = group(report year)

// Label regression variables
lab var seg_capex_ta "Segment Capex/Total Assets\textsubscript{t-1}"
lab var seg_capex_ta_100 "Segment Capex/Total Assets\textsubscript{t-1} $\times$ 100"
lab var EPD "EPD"
lab var EPD_corrupt_host_cty "EPD $\times$ Highly Corrupt Host Country"
lab var EPD_non_corrupt_host_cty "EPD $\times$ Less Corrupt Host Country"
lab var EPD_foreign_host_cty "EPD $\times$ Foreign Host Country"
lab var EPD_domestic_host_cty "EPD $\times$ Domestic Host Country"
lab var corrupt_host_cty "Highly Corrupt Host Country"
lab var non_corrupt_host_cty "Less Corrupt Host Country"
lab var ln_tot_assets_lag1 "Ln(Total Assets\textsubscript{t-1})"
lab var roa_lag1_tr "Return on Assets\textsubscript{t-1}"
lab var leverage_lag1_tr "Leverage\textsubscript{t-1}"
lab var EPD_activist_campaign "EPD $\times$ Target of NGO Shaming Campaign"
lab var EPD_no_activist_campaign "EPD $\times$ Never Target of NGO Shaming Campaign"
lab var EPD_high_media_cov "EPD $\times$ High Media Coverage"
lab var EPD_low_media_cov "EPD $\times$ Low Media Coverage"


// Save clean and merged segment capex analysis dataset
save "$final_data/segment_capex_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******         ARTICLE: Extraction Payment Disclosures                   *******
******  	   AUTHOR: Thomas Rauter                                     *******
******         JOURNAL OF ACCOUNTING RESEARCH                            *******
******   	   CODE TYPE: Data Preparation for Parent Capex Analysis     *******
******         LAST UPDATED: August 2020                                 *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "investment"


********************************************************************************
*******************  1. CLEAN COMPUSTAT FIRM FUNDAMENTALS  *********************
********************************************************************************

// Prepare exchange rate data
use "$raw_data/g_exr_monthly.dta", clear
rename tocurm curcdq
save "$clean_data/currencies_monthly_clean.dta", replace

// Remove duplicates in securities dataset
use "$raw_data/security_data.dta", clear
gsort gvkey datadate
gen check = 0
replace check = 1 if (gvkey[_n] == gvkey[_n-1] & (datadate[_n] == datadate[_n-1]))
drop if check == 1
drop check
save "$clean_data/security_data_clean.dta", replace

// Remove duplicates in Compustat Global
use "$raw_data/compustat_global.dta", clear
gsort gvkey datadate
gen check = 0
replace check = 1 if (gvkey[_n] == gvkey[_n-1] & (datadate[_n] == datadate[_n-1]))
drop if check == 1
drop check

// Merge datasets (Compustat + Exchange Rates + Securities)
merge m:1 curcdq datadate using "$clean_data/currencies_monthly_clean.dta", keep(1 3) nogen

merge 1:1 gvkey datadate using "$clean_data/security_data_clean.dta", keep(1 3) nogen

order gvkey conm datacqtr datafqtr fyr fyearq loc atq capxy

save "$clean_data/compustat_global_incl_exr_and_security.dta", replace

// Import Compustat North America
use "$raw_data/compustat_northamerica.dta", clear

rename loc hq_cty
rename fic incorp_cty

// Keep only firms headquartered and incorporated in the USA or Canada
keep if ((hq_cty == "USA") & (incorp_cty == "USA") | (hq_cty == "CAN") & (incorp_cty == "CAN"))

// Merge exchange rate data
merge m:1 curcdq datadate using "$clean_data/currencies_monthly_clean.dta", keep(1 3) nogen

// Keep only relevant variables
keep gvkey fyearq hq_cty atq datacqtr datafqtr fyr fqtr naics conm capxy aqcy oibdpy ltq exratm

gen isin = ""
save "$clean_data/compustat_northamerica_incl_exr.dta", replace


********************************************************************************
**************************  2. BUILD MERGED DATASET  ***************************
********************************************************************************

// Import cleaned Compustat Global data
use "$clean_data/compustat_global_incl_exr_and_security.dta", clear

// Keep only relevant variables
keep gvkey fyearq datacqtr exratm loc isin atq datacqtr datafqtr fyr fqtr naics conm capxy aqcy oibdpy ltq 

// Keep only relevant countries 
rename loc hq_cty
keep if (hq_cty == "AUT" | hq_cty == "BEL" | hq_cty == "BUL" | hq_cty == "HRV" | hq_cty == "CYP" | hq_cty == "CZE" | hq_cty == "DNK" | hq_cty == "EST" | hq_cty == "FIN" | hq_cty == "FRA" | hq_cty == "DEU" | hq_cty == "GRC" | hq_cty == "HUN" | hq_cty == "IRL" | hq_cty == "ITA" | hq_cty == "LVA" | hq_cty == "LTU" | hq_cty == "LUX" | hq_cty == "MLT" | hq_cty == "NLD" | hq_cty == "POL" | hq_cty == "PRT" | hq_cty == "ROU" | hq_cty == "SVK" | hq_cty == "SVN" | hq_cty == "ESP" | hq_cty == "SWE" | hq_cty == "GBR" | hq_cty == "CHE" | hq_cty == "LIE" | hq_cty == "ISL" | hq_cty == "NOR" | hq_cty == "RUS" | hq_cty == "IND" | hq_cty == "CHN" | hq_cty == "AUS"  | hq_cty == "ZAF")

drop if isin == ""

// Append cleaned Compustat North America data
append using "$clean_data/compustat_northamerica_incl_exr.dta"

// Rename variables
rename conm company_name
rename capxy capex_qtly
rename aqcy acquisitions
rename oibdpy oibd
rename ltq tot_liabilities
rename atq tot_assets
rename datacqtr calendar_yrqt
rename datafqtr fiscal_yrqt
rename fyearq fiscal_yr
rename fyr fiscal_yr_end_month

// Remove duplicates
duplicates drop gvkey calendar_yrqt, force // based on calendar year
duplicates drop gvkey fiscal_yrqt, force // based on fiscal year

// Drop observations with missing total assets
drop if tot_assets >=.

// Define time variables
encode calendar_yrqt, gen(qrt_id)
drop if qrt_id >=.
label list qrt_id
encode fiscal_yrqt, gen(fisc_qrt_id)
label list fisc_qrt_id

encode gvkey, gen(gv_no)
encode hq_cty, gen(hq_cty_no)

// Identify extractive firms based on NAICS codes
gen naics2 = substr(naics,1,2)
gen naics3 = substr(naics,1,3)

gen extractive = 0
replace extractive = 1 if (naics2 == "21")
replace extractive = 1 if (naics3 == "324")
keep if extractive == 1

encode naics3, gen(naics3_no)


********************************************************************************
************************  3. PREPARE REGRESSION SAMPLE  ************************
********************************************************************************

// Merge EPD data
merge m:1 gvkey using "$raw_data/epd_masterfile.dta"
drop if _merge ==2

// Generate EPD effective quarter
gen effective_since_qrt = qofd(effective_since) if effective_since !=.

// Rebase quarters relative to start of sample
replace effective_since_qrt = effective_since_qrt - 198

// Manually add EPD dates for subsidiaries of reporting firms (that have different gvkeys as their parent company)
replace effective_since_qrt = 20 if (gvkey == "105595")
replace effective_since = td(01jul2014) if (gvkey == "105595")
replace report = 1 if (gvkey == "105595")

replace effective_since_qrt = 22 if (gvkey == "213127")
replace effective_since = td(01jan2015) if (gvkey == "213127")
replace report = 1 if (gvkey == "213127")

replace effective_since_qrt = 22 if (gvkey == "289282")
replace effective_since = td(01jan2015) if (gvkey == "289282")
replace report = 1 if (gvkey == "289282")

replace effective_since_qrt = 22 if (gvkey == "288747")
replace effective_since = td(01jan2015) if (gvkey == "288747")
replace report = 1 if (gvkey == "288747")

replace effective_since_qrt = 22 if (gvkey == "212085")
replace effective_since = td(01jan2015) if (gvkey == "212085")
replace report = 1 if (gvkey == "212085")

replace report = 0 if report ==.

// Generate EPD indicator
gen EPD = 0
replace EPD = 1 if (report == 1 & qrt_id >= effective_since_qrt & effective_since !=.)

// Convert firm fundamentals into GBP values
foreach var of varlist tot_assets capex_qtly oibd tot_liabilities {
   replace `var' = `var' / exratm
}

// Generate firm fundamentals
gsort gvkey fiscal_yrqt
by gvkey: gen tot_assets_lag1 = tot_assets[_n-1] if ((qrt_id[_n] == qrt_id[_n-1] + 1))

by gvkey: gen capex = (capex_qtly[_n] - capex_qtly[_n-1]) if (fiscal_yr[_n] == fiscal_yr[_n-1] & (fqtr == 2 | fqtr == 3 | fqtr == 4) & (fqtr[_n] == fqtr[_n-1] + 1))
replace capex = capex_qtly if (fqtr == 1)
drop if capex < 0

by gvkey: gen op_income = (oibd[_n] - oibd[_n-1]) if (fiscal_yr[_n] == fiscal_yr[_n-1] & (fqtr == 2 | fqtr == 3 | fqtr == 4) & (fqtr[_n] == fqtr[_n-1] + 1))
replace op_income = oibd if (fqtr == 1)

// Generate dependent variable
gen invest = capex / tot_assets_lag1

// Generate (non-lagged) control variables
gen ln_tot_assets = ln(tot_assets)
gen roa = op_income / tot_assets_lag1
gen leverage = tot_liabilities / tot_assets

// Trim variables
replace leverage =. if leverage < 0
winsor2 invest leverage, cuts(0 99) trim
winsor2 roa, cuts(1 99) trim

// Multiply dependent variable by 100
gen invest_tr_100 = invest_tr * 100

// Generate lagged variables
gsort gvkey fiscal_yrqt
foreach var of varlist invest_tr leverage_tr roa_tr ln_tot_assets {
	by gvkey: gen `var'_lag1 = `var'[_n-1] if ((fisc_qrt_id[_n] == fisc_qrt_id[_n-1] + 1))
}

// Define sample period (Q1-2010 to Q4-2017)
label list qrt_id
drop if qrt_id == 1 // Q4-2009
drop if qrt_id > 33 // > Q4-2017
tab qrt_id

// Generate firm fundamentals prior to EPD for Coarsened Exact Matching (CEM)
foreach var of varlist ln_tot_assets leverage_tr roa_tr tot_assets {
	gen `var'_mod = `var' if (qrt_id == 17)
	replace `var'_mod = 0 if (`var'_mod ==.)
	egen `var'_20131231 = max(`var'_mod), by(gvkey)
}

// Define fixed effects
egen industry_quarter_FE = group(naics3_no qrt_id)
egen country_quarter_FE = group(hq_cty_no qrt_id)
egen gvkey_no = group(gvkey)
egen treated = max(EPD), by(gvkey)
egen treated_quarter_FE = group(treated qrt_id)

// Label regression variables
lab var EPD "EPD"
lab var invest_tr "Parent Capex/Total Assets\textsubscript{t-1}"
lab var invest_tr_100 "Parent Capex/Total Assets\textsubscript{t-1} $\times$ 100"
lab var ln_tot_assets_lag1 "Ln(Total Assets\textsubscript{t-1})"
lab var roa_tr_lag1 "Return on Assets\textsubscript{t-1}"
lab var leverage_tr_lag1 "Leverage\textsubscript{t-1}"


// Save cleaned and merged parent capex analysis dataset
save "$final_data/parent_capex_analysis_clean_FINAL_new.dta", replace
********************************************************************************
******                                                                   *******
******   ARTICLE: Extraction Payment Disclosures                         *******
******   AUTHOR: Thomas Rauter                                           *******
******   JOURNAL OF ACCOUNTING RESEARCH                                  *******
******   CODE TYPE: Data Preparation for Bidding Participation Analysis  *******
******   LAST UPDATED: August 2020                                       *******
******                                                                   *******
********************************************************************************

clear all
set more off

global raw_data_new "$main_dir/05_New Analyses"


********************************************************************************
*********************** 1. CLEAN ENVERUS BIDDING DATA **************************
********************************************************************************

import excel "$raw_data_new/Hist_Bid_Blocks Africa.xlsx", sheet("Bid Data") firstrow allstring clear

// Define auction status
rename General_co general_comment
replace general_comment = upper(general_comment)

gen info_negotiation = 0
replace info_negotiation =  (strpos(general_comment, "NEGOTIATIONS") > 0)

gen info_pre_award= 0
replace info_pre_award = (strpos(general_comment, "PRE-AWARDED TO") > 0)

gen info_application = 0
replace info_application = (strpos(general_comment, "SUBMITTED APPLICATION") > 0)

gen info_award = 0
replace info_award = (strpos(general_comment, "AWARDED BLOCK") > 0)
replace info_award = 0 if (strpos(general_comment, "PRE-AWARDED") > 0) & info_award==1

gen info_rejection = 0
replace info_rejection = (strpos(general_comment, "REJECTED") > 0)

gen info_invitation = 0
replace info_invitation = (strpos(general_comment, "INVITED TO DISCUSS") > 0)

gen has_info_in_comment = 0
replace has_info_in_comment = info_negotiation + info_pre_award + info_application + info_award + info_rejection + info_invitation

// Drop auctions without any information on participants
drop if Bidding_Co=="n/a" & has_info_in_comment==0 | Bidding_Co=="No bid" & has_info_in_comment==0 | Bidding_Co=="No information post-round" & has_info_in_comment==0 | ///
Bidding_Co=="Unknown company in negotiation" & has_info_in_comment==0 | Bidding_Co=="" & has_info_in_comment==0

// Clean firm names
replace Bidding_Co = subinstr(Bidding_Co, "Pacific Oil & Gas", "Pacific Oil_Gas",.)
replace Bidding_Co = subinstr(Bidding_Co, "First E&P", "First E_P",.)
replace Bidding_Co = subinstr(Bidding_Co, "Sonangol P&P", "Sonangol P_P",.)

split Bidding_Co, p(".")
rename Bidding_Co Bidding_Co_Orig
rename Bidding_Co1 Bidding_Co
replace Bidding_Co2 = strtrim(Bidding_Co2) 
replace Bidding_Co2 = "" if Bidding_Co2=="No other bids"
split Bidding_Co2, p("also")
drop Bidding_Co22
split Bidding_Co21, p("," "and")
replace Bidding_Co211 = subinstr(Bidding_Co211, "Two additional bids by", "",.)
drop Bidding_Co2 Bidding_Co21

// Identify winning firms
gen winner = substr(Bidding_Co, 1, strpos(Bidding_Co, "winner") - 1)
replace winner = strtrim(winner) 
split winner, p("&")
drop winner
gen winner = substr(Bidding_Co, 1, strpos(Bidding_Co, "awarded") - 1)
replace winner1=winner if winner1==""
drop winner
rename winner1 winner_1
rename winner2 winner_2

// Identify other bidders
split Bidding_Co, p("&" " and " ",")
replace Bidding_Co1="" if (strpos(Bidding_Co, "winner") > 0) | (strpos(Bidding_Co, "awarded") > 0)
replace Bidding_Co2="" if (strpos(Bidding_Co, "winner") > 0) | (strpos(Bidding_Co, "awarded") > 0)
replace Bidding_Co2 = subinstr(Bidding_Co2, "understood to have submitted joint bid", "",.)

foreach n of numlist 1/7{
	replace Bidding_Co`n' = strtrim(Bidding_Co`n') 
	replace Bidding_Co`n'="" if Bidding_Co`n'=="n/a" | Bidding_Co`n'=="Unknown company in negotiations"
}

foreach m of numlist 1/5{
	replace Bidding_Co21`m'=Bidding_Co`m' if missing(Bidding_Co21`m')
	drop Bidding_Co`m'
}

rename Bidding_Co Bidding_Co_temp
	foreach v of numlist 1/5{
	rename Bidding_Co21`v' Bidding_Co_`v'
}

rename Bidding_Co6 Bidding_Co_6
rename Bidding_Co7 Bidding_Co_7
order Bidding_Co_6 Bidding_Co_7, before(winner_1)

// Manually add any remaining bidders
replace Bidding_Co_3 = "Shell" if general_comment=="AWARDED TO NOBLE ENERGY EVEN THOUGH BLOCK WAS NEVER FEATURED ON LIST OF BLOCKS UNDER NEGOTIATIONS. SHELL WAS ALSO NEGOTIATING FOR BLOCK"
replace Bidding_Co_3 = "Tullow" if general_comment=="BLOCK AVAILABLE VIA COMPETITIVE BIDDING. 15 OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DIRECT NEGOTIATIONS, 1 TO GNPC. 21 JAN 19 14 COMPANIES PRE-QUALIFIED. 21 MAY 19 ENI, VITOL & TULLOW SUBMIT BIDS FOR BLOCK 3"
replace Bidding_Co_2 = "Clontarf" if Block_ID=="1916000059" | Block_ID=="1916000061"
replace Bidding_Co_2 = "" if general_comment=="BLOCK AVAILABLE VIA COMPETITIVE BIDDING. 15 OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DIRECT NEGOTIATIONS, 1 TO GNPC. 21 JAN 19 14 COMPANIES PRE-QUALIFIED. 21 MAY 19 FIRST E&P ONLY BIDDER FOR BLOCK 2"

// Drop variables that are not used
keep Block_name Block_ID Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig Onlyonecompany Clearifallbiddersrevealed general_comment Country_IS BidRoundSt info_negotiation info_pre_award info_application info_award info_rejection info_invitation has_info_in_comment Bidding_Co_temp Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 winner_1 winner_2

// Identify auctions without information on winners and other bidders
gen no_winners_no_bidders = 0
replace no_winners_no_bidders = 1 if Bidding_Co_1=="" & Bidding_Co_2=="" & Bidding_Co_3=="" & Bidding_Co_4=="" & Bidding_Co_5=="" & Bidding_Co_6=="" & Bidding_Co_7=="" & winner_1=="" & winner_2=="" 

// Extract information on winning and bidding firms from comments if "Bidding_Co" variable is empty 
preserve 
keep if Bidding_Co_Orig=="n/a" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="No bid" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="No information post-round" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="Unknown company in negotiation" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="Unknown company in negotiations" & has_info_in_comment!=0 & no_winners_no_bidders==1

drop Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 winner_1 winner_2
drop if general_comment=="COMPANIES NOT ALREADY PRESENT IN EG MUST PRE-QUALIFY, PRE-QUALIFICATION DOCUMENT TO BE SUBMITTED BY 15/09/2014. DATAROOM OPEN IN UK FROM 01/07/2014 BY APPOINTMENT. NEGOTIATIONS HELD BUT NO AWARD FOLLOWING BID ROUND" | ///
general_comment=="BLOCK AVAILABLE VIA DIRECT NEGOTIATIONS (DN). OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DN, 1 TO GNPC. JAN 19 14 COMPANIES PRE-QUALIFIED. MAY 19 16 APPLICATIONS RECEIVED FOR DN FOR BLOCKS 5 & 6, EXXON & BP WITHDREW APPLICATIONS"

split general_comment, p(".")
drop general_comment2 general_comment5
gen bidders = substr(general_comment4, strpos(general_comment4, "APPLICATION BY") + 15,  .) if (strpos(general_comment4, "APPLICATION BY")>0)
split bidders, p(",")
drop bidders bidders2 general_comment4
gen bidders2 = substr(general_comment3, 1, strpos(general_comment3, "INVITED TO DISCUSS") - 1)
drop general_comment3
split general_comment1, p("(")

gen other_bidders=""
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "SUBMITTED") - 1)
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "REJECTED") - 1) if missing(other_bidders)
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "NEGOTIATION") - 1) if missing(other_bidders)

replace other_bidders=subinstr(other_bidders, "WAS IN", "",.)
replace other_bidders=subinstr(other_bidders, "WERE IN", "",.)
split other_bidders, p("&")
drop general_comment12 other_bidders
rename other_bidders1 bidders3
rename other_bidders2 bidders4

gen other_bidders = substr(general_comment1, 1, strpos(general_comment1, "IN NEGOTIATION") - 1)
replace other_bidders=subinstr(other_bidders, "WAS", "",.)
replace other_bidders=subinstr(other_bidders, "WERE", "",.)
split other_bidders, p("&")
drop other_bidders
replace other_bidders1 = "" if (strpos(other_bidders1, "AWARDED")>0)
replace other_bidders1 = strtrim(other_bidders1) 
replace other_bidders2 = strtrim(other_bidders2) 

gen other_winners = substr(general_comment11, strpos(general_comment11, "PRE-AWARDED TO") + 15, .) if (strpos(general_comment1, "PRE-AWARDED TO") >0)
replace other_winners = substr(general_comment11, 1, strpos(general_comment11, "AWARDED") - 1) if missing(other_winners) & (strpos(general_comment11, "AWARDED") >0)
replace other_winners = strtrim(other_winners) 
replace other_winners = "IMPACT OIL_GAS" if other_winners=="JAN 2014: IMPACT OIL & GAS OFFERED RIGHT TO NEGOTIATE BLOCK AS PART OF 2013 LICENSING ROUND AND SUBSEQUENTLY"
replace other_winners = "TOTAL" if general_comment11=="MARATHON WAS  IN NEGOTIATIONS FOR BLOCK, REJECTED IN FAVOUR OF TOTAL"

split other_winners, p("&")
drop other_winners
replace other_winners1 = strtrim(other_winners1) 
replace other_winners2 = strtrim(other_winners2) 
drop general_comment11

gen Bidding_Co_1=""
replace Bidding_Co_1=bidders1
replace Bidding_Co_1=bidders2 if missing(Bidding_Co_1)
replace Bidding_Co_1=bidders3 if missing(Bidding_Co_1)

drop bidders1 bidders2 bidders3
rename other_bidders1 Bidding_Co_2
replace bidders4 = other_bidders2 if missing(bidders4)
drop other_bidders2
rename bidders4 Bidding_Co_3
rename other_winners1 winner_1
rename other_winners2 winner_2

tempfile info_recovered
save `info_recovered'
restore

// Drop auctions without any information on winners and other bidders after checking comments
drop if Bidding_Co_Orig=="n/a" & has_info_in_comment!=0 & no_winners_no_bidders==1 | Bidding_Co_Orig=="No bid" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
		Bidding_Co_Orig=="No information post-round" & has_info_in_comment!=0 & no_winners_no_bidders==1 | Bidding_Co_Orig=="Unknown company in negotiation" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
		Bidding_Co_Orig=="Unknown company in negotiations" & has_info_in_comment!=0 & no_winners_no_bidders==1

append using `info_recovered'
drop no_winners_no_bidders

gen no_winners_no_bidders = 0
replace no_winners_no_bidders=1 if Bidding_Co_1=="" & Bidding_Co_2=="" & Bidding_Co_3=="" & Bidding_Co_4=="" & ///
Bidding_Co_5=="" & Bidding_Co_6=="" & Bidding_Co_7=="" & winner_1=="" & winner_2=="" 
drop if no_winners_no_bidders==1 & has_info_in_comment==1
drop general_comment1 no_winners_no_bidders

foreach n of numlist 1/7 {
replace Bidding_Co_`n' = strtrim(Bidding_Co_`n') 
}
replace winner_1 = strtrim(winner_1)
replace winner_2 = strtrim(winner_2)

// Save identified bidders in one variable
gen all_bidders = Bidding_Co_1 + "/" + Bidding_Co_2 + "/" + Bidding_Co_3 + "/" + Bidding_Co_4 + "/" +Bidding_Co_5 + "/" + Bidding_Co_6 + "/" + Bidding_Co_7 + "/" + winner_1 + "/" + winner_2

forval n=1/5 {
	replace all_bidders = subinstr(all_bidders, "//", "/",.) 
}

gen all_bidders2 = all_bidders
replace all_bidders2 = substr(all_bidders, 2, .) if substr(all_bidders, 1, 1)== "/"
split all_bidders2, p("/")

drop Bidding_Co_temp Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 all_bidders ///
all_bidders2 info_negotiation info_pre_award info_application info_award info_rejection info_invitation has_info_in_comment

foreach m of numlist 1/7 {
	rename all_bidders2`m' bidder_`m'
}

// Replace name of Statoil with correct/new company name (Equinor)
foreach v in winner_1 winner_2 bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7 {
	replace `v'="Equinor" if `v'=="Statoil"
}

foreach v in winner_1 winner_2 bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7 {
	replace `v'="IMPACT" if `v'=="IMPACT OIL_GAS"
}

// Add manually-collected information
replace bidder_3 = "Total" if Block_ID =="1943000009" | Block_ID =="1943000010"
replace bidder_4 = "Galp" if Block_ID =="1943000009" | Block_ID =="1943000010"
replace bidder_2 = "Rift Energy" if Block_ID =="1956000004"
replace bidder_3 = "Total" if Block_ID =="1920000071"
replace bidder_3 = "Noble Energy" if Block_ID =="1920000077"
replace bidder_3 = "Shell" if Block_ID =="1920000061"

// Save cleaned bidding data
preserve
keep Block_name Block_ID Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ ///
Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig ///
general_comment Onlyonecompany Clearifallbiddersrevealed Country_IS BidRoundSt
save "$clean_data/bidding_hist_temp.dta", replace
restore


********************************************************************************
***********************  2. BUILD REGRESSION DATASET  **************************
********************************************************************************

// Extract and save data on winning firms
preserve
keep Block_ID winner_1 winner_2
reshape long winner_ , i(Block_ID) j(winning_company)
rename winner_ winner
drop if missing(winner)
merge m:1 Block_ID using "$clean_data/bidding_hist_temp.dta", keep(1 3) nogen
rename winner bidder
tempfile winners
save `winners'
restore

// Reshape data to level of bidding company
keep Block_ID bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7
reshape long bidder_ , i(Block_ID) j(bidding_company)
rename bidder_ bidder
drop if missing(bidder)

merge m:1 Block_ID using "$clean_data/bidding_hist_temp.dta", keep(1 3) nogen

merge 1:1 Block_ID bidder using `winners', nogen

replace winning_company = 0 if missing(winning_company)
replace winning_company = 1 if winning_company > 1

sort Block_ID bidding_company
gen count_bids = 1
bys Block_ID: egen bids_no = sum(count_bids)
bys Block_ID: egen winners_no = sum(winning_company)

gen multiple_winners = 0
replace multiple_winners = 1 if winners_no > 1
gen company_standardized = upper(bidder)

* Clean company names for merging with company HQ data
replace company_standardized = "AFRICA OIL" if company_standardized == "AFRICA OIL CORP"
replace company_standardized = "OPHIR ENERGY" if company_standardized == "OPHIR"
replace company_standardized = "REPSOL" if company_standardized == "REPSOL YPF"
replace company_standardized = "ROSNEFT OIL COMPANY" if company_standardized == "ROSNEFT"
replace company_standardized = "ROYAL DUTCH SHELL" if company_standardized == "SHELL"
replace company_standardized = "ENEL" if company_standardized == "ENEL POWER"
replace company_standardized = "KOSMOS" if company_standardized == "KOSMOS ENERGY"
replace company_standardized = "EQUINOR" if company_standardized == "STATOIL"
replace company_standardized = "NOBLE ENERGY" if company_standardized == "NOBLE"

* Align company names in EPD file
preserve
use "$clean_data/participant_EPD_clean.dta", clear
keep participantintname hq_country
rename participantintname company_standardized
replace company_standardized = upper(company_standardized)
duplicates drop company_standardized, force
drop if company_standardized=="NOT OPERATED"

replace company_standardized = "AFRICA ENERGY CORP" if company_standardized=="AFRICA ENERGY"
replace company_standardized = "AFRICA OIL" if company_standardized=="AFRICA OIL & GAS"
replace company_standardized = "DRAGON OIL" if company_standardized=="DRAGON"
replace company_standardized = "EDF (EDISON)" if company_standardized=="EDF"
replace company_standardized = "ENEL POWER" if company_standardized=="ENEL"
replace company_standardized = "FIRST E_P" if company_standardized=="FIRST E&P"
replace company_standardized = "GDF-SUEZ" if company_standardized=="ENGIE"
replace company_standardized = "HIBISCUS PETROLEUM JV" if company_standardized=="HIBISCUS"
replace company_standardized = "MEDITERRA ENERGY" if company_standardized=="MEDITERRA"
replace company_standardized = "MERLON INTERNATIONAL" if company_standardized=="MERLON"
replace company_standardized = "NEPTUNE ENERGY" if company_standardized=="NEPTUNE"
replace company_standardized = "NOBLE ENERGY" if company_standardized=="NOBLE"
replace company_standardized = "OPHIR ENERGY" if company_standardized == "OPHIR"
replace company_standardized = "ORANTO" if company_standardized=="ATLAS ORANTO"
replace company_standardized = "PURAVIDA" if company_standardized=="PURA VIDA"
replace company_standardized = "ROSNEFT OIL COMPANY" if company_standardized == "ROSNEFT"
replace company_standardized = "ROYAL DUTCH SHELL" if company_standardized == "SHELL"
replace company_standardized = "SONANGOL P_P" if company_standardized=="SONANGOL"
replace company_standardized = "SONTRACH" if company_standardized=="SONATRACH"
replace company_standardized = "TOWER RESOURCES" if company_standardized=="TOWER"
replace company_standardized = "TRIDENT" if company_standardized=="TRIDENT PETROLEUM"
replace company_standardized = "VEGA PETROLEUM" if company_standardized=="VEGA"
replace company_standardized = "WOODSIDE ENERGY" if company_standardized=="WOODSIDE"
replace company_standardized = "ENEL" if company_standardized == "ENEL POWER"

tempfile EPD_hq
save `EPD_hq'
restore 

// Merge HQ information and EPD effective dates
merge m:1 company_standardized using `EPD_hq', keep(1 3) nogen

replace company_standardized = subinstr(company_standardized, "_", "&",.)
replace company_standardized = "EDF - EDISON" if company_standardized == "EDF (EDISON)"
replace company_standardized = "KOSMOS ENERGY" if company_standardized=="KOSMOS"

// Merge with EPD masterfile
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keep(1 3)

// Generate date of bidding
split Bid_Round_, p("/")
drop Bid_Round_1 Bid_Round_2
rename Bid_Round_3 bid_round_year
destring bid_round_year, replace

split Bid_Round_, p("/")
foreach n of numlist 1/9{
	replace Bid_Round_1="0`n'" if Bid_Round_1=="`n'"
	replace Bid_Round_2="0`n'" if Bid_Round_2=="`n'"
}

gen bid_round_date = Bid_Round_1 + "\" + Bid_Round_2 + "\" + Bid_Round_3
gen date = date(bid_round_date,"MDY")
format date %td
drop bid_round_date Bid_Round_1 Bid_Round_2 Bid_Round_3
rename date bid_round_date

// Save all bidder information in one dataset
preserve
duplicates drop company_standardized, force
sort company_standardized Block_ID
keep company_standardized effective_since part_of_annual_report number_of_pages ///
direct_to_consumer_market attestation_reporting_entity attestation_independent_audit hq_country ///
student ticker_not_sure reporting_issue report
save "$clean_data/all_bidders.dta", replace
restore

// Span bidder-auction panel
local blocks 1301000017 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 ///
1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 ///
1301000041 1301000042 1301000043 1301000044 1301000045 1301000048 1301000060 1301000061 1301000062 1301000068 1301000070 ///
1301000073 1315000507 1315000508 1315000510 1315000511 1315000514 1315000516 1315000518 1315000519 1315000532 1315000536 ///
1315000537 1315000538 1315000553 1315000554 1315000578 1315000579 1315000584 1315000588 1315000594 1315000601 1315000604 ///
1315000607 1315000609 1315000612 1315000616 1315000618 1315000619 1315000643 1315000664 1315000667 1315000669 1315000670 ///
1315000672 1315000676 1315000677 1315000683 1315000684 1315000687 1315000692 1315000695 1315000698 1315000713 1315000714 ///
1902000237 1907000009 1907000012 1907000027 1907000028 1911000050 1911000053 1911000056 1911000059 1916000024 1916000028 ///
1916000033 1916000034 1916000059 1916000061 1920000048 1920000049 1920000050 1920000051 1920000056 1920000061 1920000062 ///
1920000063 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000078 1920000080 1920000081 1920000082 ///
1920000084 1920000085 1921000002 1921000003 1937000673 1937000674 1937000676 1937000677 1937000682 1937000683 1937000686 ///
1943000009 1943000010 1952000004 1956000000 1956000001 1956000002 1956000003 1956000004

local block_vars "Block_ID Block_name Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig general_comment Onlyonecompany Clearifallbiddersrevealed Country_IS BidRoundSt count_bids bids_no winners_no multiple_winners bid_round_year bid_round_date"

foreach b of local blocks {
preserve
keep if Block_ID=="`b'"
drop _merge
append using "$clean_data/all_bidders.dta"
duplicates tag company_standardized, gen(dup)
drop if dup==1 & missing(Block_ID)
replace bidding_company=0 if missing(bidding_company)
foreach v of local block_vars{
replace `v'=`v'[1]
}
tempfile block_`b'
save `block_`b''
restore
}

local blocks2 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 ///
1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 ///
1301000041 1301000042 1301000043 1301000044 1301000045 1301000048 1301000060 1301000061 1301000062 1301000068 1301000070 ///
1301000073 1315000507 1315000508 1315000510 1315000511 1315000514 1315000516 1315000518 1315000519 1315000532 1315000536 ///
1315000537 1315000538 1315000553 1315000554 1315000578 1315000579 1315000584 1315000588 1315000594 1315000601 1315000604 ///
1315000607 1315000609 1315000612 1315000616 1315000618 1315000619 1315000643 1315000664 1315000667 1315000669 1315000670 ///
1315000672 1315000676 1315000677 1315000683 1315000684 1315000687 1315000692 1315000695 1315000698 1315000713 1315000714 ///
1902000237 1907000009 1907000012 1907000027 1907000028 1911000050 1911000053 1911000056 1911000059 1916000024 1916000028 ///
1916000033 1916000034 1916000059 1916000061 1920000048 1920000049 1920000050 1920000051 1920000056 1920000061 1920000062 ///
1920000063 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000078 1920000080 1920000081 1920000082 ///
1920000084 1920000085 1921000002 1921000003 1937000673 1937000674 1937000676 1937000677 1937000682 1937000683 1937000686 ///
1943000009 1943000010 1952000004 1956000000 1956000001 1956000002 1956000003 1956000004

local blocks
use `block_1301000017', clear
foreach b of local blocks2 {
	append using `block_`b''
}
drop dup count_bids


// Clean variables
replace bidder="Not a bidder" if missing(bidder)
replace report=0 if report==.
replace company_standardized="SONATRACH" if company_standardized=="SONTRACH"

gen company_HC_type=company_standardized
replace company_HC_type = "EDF" if company_standardized=="EDF - EDISON"
replace company_HC_type = "AFRICA ENERGY" if company_standardized=="AFRICA ENERGY CORP"
replace company_HC_type = "KNOC" if company_standardized=="DANA PETROLEUM"
replace company_HC_type = "ACR" if company_standardized=="ACREP"
replace company_HC_type = "DEA" if company_standardized=="DEA EGYPT"
replace company_HC_type = "ENOC" if company_standardized=="DRAGON OIL"
replace company_HC_type = "EDF" if company_standardized=="EDF - EDISON"
replace company_HC_type = "EDF" if company_standardized=="EDISON" & bid_round_year>=2012
replace company_HC_type = "IMPACT" if company_standardized=="IMPACT OIL&GAS"
replace company_HC_type = "IOCL" if company_standardized=="INDIAN OIL"
replace company_HC_type = "KOSMOS" if company_standardized=="KOSMOS ENERGY"
replace company_HC_type = "MEDITERRA" if company_standardized=="MEDITERRA ENERGY"
replace company_HC_type = "MERLON" if company_standardized=="MERLON INTERNATIONAL"
replace company_HC_type = "NOBLE" if company_standardized=="NOBLE ENERGY"
replace company_HC_type = "OPHIR" if company_standardized=="OPHIR ENERGY"
replace company_HC_type = "ATLAS ORANTO" if company_standardized=="ORANTO"
replace company_HC_type = "PURA VIDA" if company_standardized=="PURAVIDA"
replace company_HC_type = "ROSNEFT" if company_standardized=="ROSNEFT OIL COMPANY"
replace company_HC_type = "SONANGOL" if company_standardized=="SONANGOL P&P"
replace company_HC_type = "SONATRACH" if company_standardized=="SONTRACH"
replace company_HC_type = "EQUINOR" if company_standardized=="STATOIL"
replace company_HC_type = "TOWER" if company_standardized=="TOWER RESOURCES"
replace company_HC_type = "TRIDENT ENERGY" if company_standardized=="TRIDENT"
replace company_HC_type = "WOODSIDE" if company_standardized=="WOODSIDE ENERGY"

// Merge data on main hydrocarbon type at bidding-company level 
preserve
use "$main_dir/01_Clean_Data/mainHC_type.dta", clear
replace participantintname=upper(participantintname)
rename participantintname company_HC_type
drop if company_HC_type=="NOT OPERATED"
replace company_HC_type="ROYAL DUTCH SHELL" if company_HC_type=="SHELL"
duplicates drop company_HC_type, force
tempfile main_resource_type
save `main_resource_type'
restore

merge m:1 company_HC_type using `main_resource_type', keep(1 3)

// Manually add missing HQ country information
replace hq_country = "Angola" if company_standardized=="ACREP"
replace hq_country = "Australia" if company_standardized=="ARMOUR"
replace hq_country = "United States" if company_standardized=="ASPECT"
replace hq_country = "Switzerland" if company_standardized=="BLUEGREEN"
replace hq_country = "United States" if company_standardized=="COBALT"
replace hq_country = "South Korea" if company_standardized=="DANA PETROLEUM"
replace hq_country = "Germany" if company_standardized=="DEA EGYPT"
replace hq_country = "Germany" if company_standardized=="DELONEX ENERGY"
replace hq_country = "France" if company_standardized=="EDISON"
replace hq_country = "Ghana" if company_standardized=="ELANDEL ENERGY"
replace hq_country = "United Kingdom" if company_standardized=="ELENILTO"
replace hq_country = "Mozambique" if company_standardized=="ENH"
replace hq_country = "United States" if company_standardized=="GLINT"
replace hq_country = "United Kingdom" if company_standardized=="IMPACT OIL&GAS"
replace hq_country = "India" if company_standardized=="INDIAN OIL"
replace hq_country = "Mozambique" if company_standardized=="INDICO"
replace hq_country = "Egypt" if company_standardized=="KIERON MAGAWISH"
replace hq_country = "Nigeria" if company_standardized=="LEVENE ENERGY"
replace hq_country = "Singapore" if company_standardized=="PACIFIC OIL&GAS"
replace hq_country = "Portugal" if company_standardized=="PARTEX"
replace hq_country = "Thailand" if company_standardized=="PTTP"
replace hq_country = "United Kingdom" if company_standardized=="SEA DRAGON"
replace hq_country = "Tanzania" if company_standardized=="SWALA"
replace hq_country = "Ireland" if company_standardized=="CLONTARF"
replace hq_country = "Canada" if company_standardized=="RIFT ENERGY"
replace hq_country = "Nigeria" if company_standardized=="OFFSHORE EQUATOR PLC"

// Final clean up of bidding company and HQ variables
replace bidder = subinstr(bidder, "_", "&", .)
replace bidder = subinstr(bidder, "Sontrach", "Sonatrach", .)
replace hq_country = "Australia" if hq_country=="Austalia"
replace hq_country = strtrim(hq_country)

// Only keep auctions for which there is evidence that all bidding companies are included (after online cross validations)
local keep "1301000048 1301000060 1301000061 1301000062 1301000070 1301000073 1315000612 1315000664 1315000683 1315000684 1315000714 1921000002 1921000003 1937000683 1956000000 1956000001 1956000002 1956000003 1956000004 1920000061 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000080 1920000084 1920000085 1301000017 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 1301000041 1301000042 1301000043 1301000044 1301000045 1301000068 1916000059 1916000061 1920000078 1943000009 1943000010 1920000050 1920000051 1920000056 1920000062 1920000081 1920000082"
gen keep=0

foreach k in `keep'{
replace keep=1 if Block_ID=="`k'"
}
keep if keep==1

// Generate "Submitted Bid" indicator
gen active_bidder = ""
replace active_bidder = "YES" if bidder != "Not a bidder"
replace active_bidder = "NO" if bidder == "Not a bidder"

gen submitted_bid = 0
replace submitted_bid = 1 if active_bidder=="YES"
lab var submitted_bid "Company Submitted Bid for Auction"

// Generate EPD treatment indicator
gen EPD=0
replace EPD = 1 if bid_round_date >= effective_since & bid_round_date <.
gen EPD_submitted_bid = submitted_bid * report
gen EPD_effective_yr=year(effective_since) 

// Generate "Number of Bids per Auction" variable
bys Block_ID: egen bids_per_auction = total(submitted_bid)
bys Block_ID: egen EPD_bids_per_auction = total(EPD_submitted_bid)
gen non_EPD_bids_per_auction = bids_per_auction - EPD_bids_per_auction
gen EPD_bids_per_auction_pct = EPD_bids_per_auction/bids_per_auction*100
gen non_EPD_bids_per_auction_pct = non_EPD_bids_per_auction/bids_per_auction*100

// Quantify bidding activity by firm
gen sub_bid = submitted_bid
bys company_standardized: egen bid_activity = sum(sub_bid)

// Drop firms that never submitted any bid
drop if bid_activity == 0

// Define regression sample
keep if bid_round_year >= 2010

// Generate control variables
rename Contract_t contract_type
replace contract_type=strtrim(contract_type)
gen exploration=0
replace exploration = 1 if contract_type=="Exploration"
destring Block_Area, replace
gen ln_block_size = ln(Block_Area)
*gen post_EPD = 0
*replace post_EPD = 1 if bid_round_year > 2013

// Generate fixed effects
egen year_FE = group(bid_round_year)
egen firm_FE = group(company_standardized)
egen treated_FE = group(report)
egen treated_year_FE = group(report bid_round_year)
egen resourcetype_FE = group(main_hc_type)
egen resourcetype_year_FE = group(main_hc_type bid_round_year)
egen host_country_FE = group(Country_IS)
egen hq_country_FE = group(hq_country)

// Label regression variables
lab var EPD "EPD"
lab var submitted_bid "Firm Submitted Bid"
lab var submitted_bid "Submitted Bid"
lab var bids_per_auction "Tot. bids received for auction X"
lab var EPD_bids_per_auction "Tot. bids received from EPD firms"
lab var non_EPD_bids_per_auction "Tot. bids received from Non-EPD firms"
lab var exploration "Exploration"
lab var ln_block_size "Ln(Size of Oil \& Gas Block)"
lab var Block_ID "Enverus Block ID"
lab var On_Offshor "License for On- vs. Offshore Block"
lab var contract_type "License Type Being Awarded"
lab var Block_Area "Size of Block in sqkm"
lab var Country_IS "2-digit ISO code of Country where Block is located"
lab var company_standardized "Standardized Name of Bidding Firm"
lab var hq_country "Headquarter Country of Bidding Firm"
lab var effective_since "Firm is subject to EPD regulation since - Date" 
lab var bid_round_year "Year of Block Auction"
lab var bid_round_date "Date of Block Auction"
lab var main_hc_type "Main Hydrocarbon Extracted by Firm"
lab var bid_activity "Total Bids Sumbitted by Firm"
lab var EPD_effective_yr "Firm is subject to EPD regulation since - Year" 
lab var EPD_bids_per_auction_pct "Pct of Bids received by Firms subject to EPD"
lab var non_EPD_bids_per_auction_pct "Pct of Bids received by Firms never subject to EPD"
lab var post_EPD "Post EPD Period (2014 and after)"


// Save cleaned and merged bidding behaviour dataset
save "$final_data/bidding_behaviour_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******   ARTICLE: Extraction Payment Disclosures                         *******
******   AUTHOR: Thomas Rauter                                           *******
******   JOURNAL OF ACCOUNTING RESEARCH                                  *******
******   CODE TYPE: Data Preparation for Oil and Gas Licensing Analysis  *******
******   LAST UPDATED: August 2020                                       *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "licensing"


********************************************************************************
**********************  1. BUILD FIRM-COUNTRY-YEAR PANEL ***********************
********************************************************************************

// Import block data (unique at blockid level)
import delimited "$raw_data/BlocksTable.CSV", clear 

// Keep major blocks
keep if areasqkm >= 1000

// Reshape data to block-participant level
rename operatorlocalname participant0localname
rename operatorintname participant0intname
rename operatorwi participant0wi

forvalues i=0/6 {
	rename participant`i'localname participantlocalname`i'
	rename participant`i'intname participantintname`i'
	rename participant`i'wi participantwi`i'
	}

reshape long participantlocalname participantintname participantwi, i(blockid) j(participant_number)
drop if participantlocalname=="" & participantintname=="" & participantwi==.

// Check if data is unique at block id-participant level
isid blockid participant_number

save "$clean_data/oil_block_participant.dta", replace

// Generate key dates
generate award_date=date(awarddate, "YMD")
format award_date %td
generate year=year(award_date)

generate expiry_date=date(expirydate, "YMD")
format expiry_date %td
generate expiry_year=year(expiry_date)

// Generate participant id
replace participantlocalname="Unknown" if participantlocalname==""
egen participantID=group(participantintname participantlocalname)

generate number_blocks_opened = 1

// Add time and country dimensions
fillin participantintname country year
	
// Identify earliest year participant had block in given country
bys participantintname country: egen min_award_date=min(award_date)
format min_award_date %td
label variable min_award_date "Earliest award date for participant-country"

// Identify latest year participant had block in given country
bys participantintname country: egen max_expiry_date=max(expiry_date)
format max_expiry_date %td
label variable max_expiry_date "Latest expiry date for participant-country"
		
// Collapse to participant-country-year level
if "`version'"=="ID" local keep "participantlocalname participantintname"
collapse (sum) number_blocks_opened, by(participantintname country year min_award_date max_expiry_date  `keep')
isid participant`version' country year, missok
label variable number_blocks_opened "# blocks participant opened in that county-year"
		
// Identify whether participant ever had a block in the country
bys participantintname country: egen ever_had_block=max(number_blocks_opened>=1)
label variable ever_had_block "Participant-country appears in block dataset"

// Create an indicator = 1 for every year past award date
bys participantintname country: generate has_block=(year>=year(min_award_date) & year<=year(max_expiry_date)) if (min_award_date!=. & max_expiry_date!=.)
replace has_block=0 if ever_had_block==0
label variable has_block "Participant-country award date<=year"
		
// Create an indicator = 1 for block openings
generate any_blocks_opened=(number_blocks_opened>=1)
label variable any_blocks_opened "Dummy for 1+ block opening(s) by participant in that country-year"		

// Save firm-country-year panel
drop if year==.
order participant* country year min_award_date max_expiry_date has_block ever_had_block number_blocks_opened any_blocks_opened

save "$raw_data/oil_block_participantintname_country_year.dta", replace


********************************************************************************
***************************  2. CLEAN LICENSING DATA ***************************
********************************************************************************

import excel "$raw_data/operator_headquarters_merged.xlsx", clear sheet("Manual_merge_Formulas") cellrange(A1:P622) firstrow

// Unify manually-collected gvkeys
gen gvkey=""
replace gvkey=gvkey_HANNAH if gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_E=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_A if gvkey_HANNAH=="" & gvkey_VLOOKUP_E=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_E if gvkey_HANNAH=="" & gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_F if gvkey_HANNAH=="" & gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_E==""

global gvkey "gvkey_VLOOKUP_A gvkey_VLOOKUP_E gvkey_VLOOKUP_F gvkey_HANNAH"
foreach g of global gvkey{
	replace gvkey=`g' if gvkey=="" & `g'==gvkey_VLOOKUP_A | gvkey=="" & `g'==gvkey_VLOOKUP_E | gvkey=="" & `g'==gvkey_VLOOKUP_F
}

// Drop redundant variables
drop Modifications company FirstwordofFullName Firstwordofoperatorintname $gvkey

// Rename remaining variables
rename operatorintname participantintname
rename HeadquartersHannahFederica hq_country

// Clean firms' headquarter country
replace hq_country="Angola" if participantintname=="ACR" & hq_country=="Angola/ Mauritius"
replace hq_country="United Kingdom" if participantintname=="Global Connect" & hq_country=="British Virgin Islands/UK"
replace hq_country="Canada" if participantintname=="PetroSinai" & hq_country=="Canada/Egypt"
replace hq_country="Kuwait" if participantintname=="EASPCO" & hq_country=="Egypt/Kuwait"
replace hq_country="Egypt" if participantintname=="Mansoura" & hq_country=="Egypt??"
replace hq_country="Egypt" if participantintname=="EKH" & hq_country=="France/UK"
replace hq_country="United Kingdom" if participantintname=="Minexco OGG" & hq_country=="Gibraltar/UK"
replace hq_country="United Kingdom" if participantintname=="Rapetco" & hq_country=="Italy/UK (50/50)"
replace hq_country="United Kingdom" if participantintname=="BWEH" & hq_country=="Mauritania - BW Offshore/Bermuda - BW Offshore Limited/UK - Limited/Netherlands - Mgmt"
replace hq_country="Namibia" if participantintname=="Trago" & hq_country=="Namibia?"
replace hq_country="Netherlands" if participantintname=="West Sitra" & hq_country=="Netherlands/Egypt"
replace hq_country="United States" if participantintname=="Grasso Consortium" & hq_country=="Nigeria/USA" | participantintname=="Grasso" & hq_country=="Nigeria/USA"
replace hq_country="South Korea" if hq_country=="South Corea"
replace hq_country="United States" if participantintname=="NOPCO" & hq_country=="USA?"
replace hq_country="United Kingdom" if participantintname=="Chariot" & hq_country=="United Kingdom / Channel Islands"
replace hq_country="United Kingdom" if participantintname=="North El Burg" & hq_country=="United Kingdom /Italy"
replace hq_country="United Kingdom" if participantintname=="Equator Hydrocarbons" & hq_country=="United Kingdom/Nigeria"
replace hq_country="Yemen" if participantintname=="PEPA" & hq_country=="Yemen?"

replace participantintname="Shell" if participantintname=="Royal Dutch Shell"

replace EPD_effective_since=. if participantintname == "Africa Oil & Gas"
replace EPD_publication_date=. if participantintname == "Africa Oil & Gas"

save "$clean_data/participant_EPD_clean.dta", replace


********************************************************************************
************************  3. PREPARE REGRESSION SAMPLE *************************
********************************************************************************

// Merge licensing panel with EPD masterfile
use "$raw_data/oil_block_participantintname_country_year.dta", clear
merge m:1 participantintname using "$clean_data/participant_EPD_clean.dta"

// Drop unidentified firms
drop if participantintname=="Not Operated" | participantintname=="Not operated" | participantintname=="Unassigned" | participantintname=="Unknown"
drop if _merge == 2
drop if year==.

// Identify firms subject to EPD reporting      
gen EPD_effective_yr = year(EPD_effective_since) 
gen EPD_publication_yr = year(EPD_publication_date) 
gen EPD=0
bys participantintname year: replace EPD=1 if year >= EPD_effective_yr & EPD_effective_yr !=.
bys participantintname year: replace EPD=0 if EPD_effective_yr==.
drop _merge
rename FullName participant_full_name

// Clean host country names
replace country = "Tunisia" if country == "Libya-Tunisia JEZ"
replace country = "Senegal" if country == "S-GB AGC"
replace country = "Nigeria" if country == "Sao Tome & Nigeria"

// Generate ISO codes for (i) host countries and (ii) HQ countries
kountry country, from(other) stuck marker
rename _ISO3N_ iso_n
kountry iso_n, from(iso3n) to(iso3c) 
rename _ISO3C_ iso
kountry hq_country, from(other) stuck 
rename _ISO3N_ iso_n_hq
kountry iso_n_hq, from(iso3n) to(iso3c) 
rename _ISO3C_ iso_hq

// Clean and merge data on firms' main hydrocarbon
preserve
use "$raw_data/oil_block_participant.dta", clear

gen oil = 0
gen gas = 0

gen gas_and_oil = 0
replace oil = 1 if hydrocarbontype=="Oil"
replace gas = 1 if hydrocarbontype=="Gas and Condensate"
replace gas = 1 if hydrocarbontype=="Gas"
replace gas_and_oil = 1 if hydrocarbontype=="Oil and Gas" 

collapse (sum) oil gas gas_and_oil, by (participantintname)

gen only_oil=0
gen only_gas=0
gen mix_gas_and_oil=0
replace only_oil=1 if oil>0 & gas==0 & gas_and_oil==0
replace only_gas=1 if gas>0 & oil==0 & gas_and_oil==0
replace mix_gas_and_oil=1 if gas_and_oil>0 
replace mix_gas_and_oil=1 if gas_and_oil==0 & oil>0 & gas>0

gen main_hc_type=""
replace main_hc_type="Only oil" if only_oil==1
replace main_hc_type="Only gas" if only_gas==1
replace main_hc_type="Oil and Gas" if mix_gas_and_oil==1
drop oil gas gas_and_oil only_oil only_gas mix_gas_and_oil

save "$clean_data/mainHC_type.dta", replace
restore
 
merge m:1 participantintname using "$clean_data/mainHC_type.dta", keep(1 3)

// Define dependent variable
replace any_blocks_opened = any_blocks_opened * 100

// Identify treatment group
bys participantintname: egen disclosing = max(EPD)

// Define sample period
keep if (year >= 2000 & year <= 2018)

// Create fixed effects
egen host_country_FE = group(iso)
egen host_country_year_FE = group(iso year)
egen resourcetype_year_FE = group(main_hc_type year)
egen treatment_year_FE = group(disclosing year)
egen hq_country_id = group(hq_country)

// Label regression variables
lab var EPD "EPD"
lab var any_blocks_opened "Obtained License $\times$ 100"

// Save cleaned and merged licensing dataset
save "$final_data/extensive_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******        ARTICLE: Extraction Payment Disclosures                    *******
******        AUTHOR: Thomas Rauter                                      *******
******        JOURNAL OF ACCOUNTING RESEARCH                             *******
******        CODE TYPE: Data Preparation for Productivity Analysis      *******
******        LAST UPDATED: August 2020                                  *******
******                                                                   *******
********************************************************************************

clear all
set more off


********************************************************************************
****************** 1. CLEAN ENVERUS ASSET-TRANSACTIONS DATA ********************
********************************************************************************

import delimited "$raw_data/AssetTransactionsFull.CSV", encoding(ISO-8859-1)clear 

// Prepare variables
rename country block_country
rename agreementdate agreement_date 
rename closedate closed_date 
rename effectivedate effective_date
rename blockname block_name
rename transactionstatus transaction_status
rename sellingentitylocalname seller_local_name
rename sellingentityintname seller_int_name
rename purchasingentityintname buyer_int_name
rename purchasingentitylocalname buyer_local_name
rename interestpurchased interest_purchased
rename blockid block_id_enverus
rename operatorchange operator_change

replace block_country = upper(block_country)
replace block_name = upper(block_name)
replace block_id_enverus = strtrim(block_id_enverus)

foreach phase in agreement closed effective {
	gen deal_`phase'_date = date(`phase'_date, "YMD")
	format deal_`phase'_date %td
}

// Generate date of asset transaction => pecking order: 1. effective, 2. closed, 3. agreement
gen deal_date_combined = deal_effective_date
replace deal_date_combined = deal_closed_date if missing(deal_date_combined)
replace deal_date_combined = deal_agreement_date if missing(deal_date_combined)
format deal_date_combined %td

gen deal_date_type = ""
replace deal_date_type = "Effective" if deal_date_combined == deal_effective_date
replace deal_date_type = "Closed" if deal_date_combined == deal_closed_date
replace deal_date_type = "Agreement" if deal_date_combined == deal_agreement_date

// Keep host countries with production data
keep if block_country =="ANGOLA" | block_country =="GHANA" | block_country =="MAURITANIA" | block_country =="NIGERIA" | ///
	block_country =="SENEGAL" | block_country =="TUNISIA"

// Keep deals with known deal date
drop if missing(deal_date_combined)

// Keep finalized deals that can impact production
keep if transaction_status == "Complete"

// Generate deal date variables
gen month = month(deal_date_combined)
gen year = year(deal_date_combined)
sort block_name year month

// Clean seller names
replace seller_int_name = upper(seller_int_name)
gen company_standardized = seller_int_name
replace company_standardized ="AKER BP" if seller_int_name=="AKER ENERGY"
replace company_standardized ="ENI" if seller_int_name=="ENI PETROLEUM CO., INC."
replace company_standardized ="SEPLAT PETROLEUM DEVELOPMENT COMPANY" if seller_int_name=="SEPLAT"
replace company_standardized ="SERINUS ENERGY" if seller_int_name=="SERINUS" | seller_int_name=="KULCZYK"
replace company_standardized ="ROYAL DUTCH SHELL" if seller_int_name=="SHELL"
replace company_standardized ="TULLOW OIL" if seller_int_name=="TULLOW"

// Identify EPD sellers
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keepusing(effective_since report)
rename company_standardized seller_standardized
rename effective_since effective_since_seller
rename report reporting_seller

replace reporting_seller = 0 if missing(reporting_seller)
drop if _merge==2
drop _merge

// Clean buyer names
replace buyer_int_name = upper(buyer_int_name)
gen company_standardized = buyer_int_name
replace company_standardized ="AKER BP" if buyer_int_name=="AKER ENERGY"
replace company_standardized ="ENI" if buyer_int_name=="ENI PETROLEUM CO., INC."
replace company_standardized ="SEPLAT PETROLEUM DEVELOPMENT COMPANY" if buyer_int_name=="SEPLAT"
replace company_standardized ="SERINUS ENERGY" if buyer_int_name=="SERINUS" | buyer_int_name=="KULCZYK"
replace company_standardized ="ROYAL DUTCH SHELL" if buyer_int_name=="SHELL"
replace company_standardized ="TULLOW OIL" if buyer_int_name=="TULLOW"

// Identify non-EPD buyers
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keepusing(effective_since report)
rename company_standardized buyer_standardized
rename effective_since effective_since_buyer
rename report reporting_buyer

replace reporting_buyer = 0 if missing(reporting_buyer)
drop if _merge==2
drop _merge 

// Clean-up specific block IDs based on feedback from ENVERUS
replace block_id_enverus = "1940000434" if block_name=="OML 71"
replace block_id_enverus = "1355000175" if block_name=="BENI KHALED" & block_id_enverus=="1355000245"

// Generate indicator for transactions with change in block operator
gen operator_changed=0
replace operator_changed = 1 if operator_change== "true"

// Generate indicator for transactions with EPD buyer (to be netted out at block level)
gen neutral_deal = 1
replace neutral_deal = 0 if reporting_buyer == 0

// Change sign of acquired share by EPD buyers (for netting out at block level)
replace interest_purchased = - interest_purchased if neutral_deal == 1

// Collapse license transactions at block-month level
sort block_name year month  
collapse (sum) interest_purchased operator_changed (min) neutral_deal, ///
by(block_id_enverus block_name deal_date_combined year month)

// Classify "temporary" transactions as non-treated because they are reversed right after deal closes
sort block_name year month
replace neutral_deal = 1 if block_name == "DIDON" & year==2015
replace interest_purchased = 0 if block_name == "DIDON" & year==2015 

replace neutral_deal = 1  if block_name == "EL JEM"
replace interest_purchased = 0 if block_name == "EL JEM" 

replace neutral_deal = 1 if block_name == "C-3"
replace interest_purchased = 0 if block_name == "C-3" 

replace neutral_deal = 1 if block_name == "OML 55" & deal_date_combined==td(05feb2015) | block_name == "OML 55" &  deal_date_combined==td(30jun2016)
replace interest_purchased = 0 if block_name == "OML 55" & deal_date_combined==td(05feb2015) | block_name == "OML 55" &  deal_date_combined==td(30jun2016)

gen month_date = ym(year, month) 
format month_date %tm

save "$clean_data/block_asset_transactions.dta", replace


********************************************************************************
********************** 2. CLEAN MONTHLY PRODUCTION DATA ************************
********************************************************************************

use "$clean_data/production_field_block_EPD.dta", clear

// Merge block and production data
merge 1:m field_name using "$raw_data/Production_monthly_field_well_level.dta", keep(1 3) nogen

// Generate production date variables
sort field_name MonthlyProductionDate
gen production_date = date(MonthlyProductionDate, "MDY")
format production_date %td
sort field_name production_date
gen month = month(production_date)
gen year = year(production_date)
sort block_name field_name year month

// Identify whether field and block operators are EPD reporting
gen EPD_field_operator = 0
replace EPD_field_operator = 1 if field_operator_reporting==1

gen EPD_block_operator = 0
replace EPD_block_operator = 1 if block_operator_reporting==1

// Drop variables that are not used
keep field_name block_name block_country contract_name tot_completed_wells area_block_sqkm operator_field_well block_operator ///
MonthlyProductionDate MonthlyOil MonthlyGas MonthlyWater WellCount Days DailyAvgOil DailyAvgGas DailyAvgWater WellNumber ProductionType ProductionStatus ///
ProducingMonthNumber production_date EPD_field_operator EPD_block_operator EntityType block_id_enverus year month Province ProducingMonthNumber

// Clean production variables
foreach v in DailyAvgOil DailyAvgGas MonthlyOil MonthlyGas area_block_sqkm WellCount ProducingMonthNumber {
	destring `v', replace
}
rename DailyAvgOil daily_avg_oil
rename DailyAvgGas daily_avg_gas
rename WellCount well_count
rename MonthlyOil monthly_oil
rename MonthlyGas monthly_gas
rename ProducingMonthNumber months_producing_since

// Drop observations with missing operator information
drop if operator_field_well == "NOT OPERATED"

// Since there is production data, there must be at least one well by definition
replace tot_completed_wells = 1 if tot_completed_wells==0  

// Generate total monthly output
gen tot_oilgas_output_month = monthly_oil
replace tot_oilgas_output_month = monthly_oil + monthly_gas if !missing(monthly_gas)
replace tot_oilgas_output_month = monthly_gas if missing(tot_oilgas_output_month)

// Generate average daily output
gen daily_avg_oil_gas = daily_avg_oil 
replace daily_avg_oil_gas = daily_avg_oil + daily_avg_gas if !missing(daily_avg_gas)
replace daily_avg_oil_gas = daily_avg_gas if missing(daily_avg_oil_gas)

// Normalize daily average output by (i) number of wells and (ii) area of block
gen daily_avg_oil_gas_per_well = daily_avg_oil_gas / well_count
gen daily_avg_oilgas_per_well_alt = daily_avg_oil_gas / tot_completed_wells
gen daily_avg_oilgas_per_sqkm = daily_avg_oil_gas / area_block_sqkm

// Generate indicators for hydrocarbon types
gen oil = 0
replace oil = 1 if !missing(daily_avg_oil)
gen gas = 0
replace gas = 1 if !missing(daily_avg_gas)

// Generate year-month variable
gen month_date = ym(year, month) 
format month_date %tm


********************************************************************************
*************** 3. AGGREGATE PRODUCTION DATA TO THE BLOCK LEVEL ****************
********************************************************************************
preserve

// Keep only field-level production data (to be aggregated at the block-level)
keep if EntityType=="FIELD"
encode field_name, gen(field_code)

// Tsset data at field-month level
tsset field_code month_date
tsfill

// Fill up field characteristics that are constant over time
local field_strings "field_name operator_field_well block_id_enverus block_name contract_name block_country block_operator Province EntityType"
local field_numeric "area_block_sqkm tot_completed_wells"

foreach s in `field_strings'{
	bys field_code (`s'): replace `s' = `s'[_N] if missing(`s')
}

foreach n in `field_numeric'{
	bys field_code (`n'): replace `n' = `n'[1] if missing(`n')
}

// Compute number of consecutive months for which production data is missing
bys field_code (month_date): gen spell = sum(missing(daily_avg_oilgas_per_well_alt) != missing(daily_avg_oilgas_per_well_alt[_n-1]))
bys field_code spell (month_date): gen spell_length = _N
bysort field_code (month_date) : gen seq = missing(daily_avg_oilgas_per_well_alt) & (!missing(daily_avg_oilgas_per_well_alt[_n-1]) | _n == 1) 
by field_code : replace seq = seq[_n-1] + 1 if missing(daily_avg_oilgas_per_well_alt) & seq[_n-1] >= 1 & _n > 1 
bys field_code spell: egen gap = max(seq)
bys field_code: egen largest_gap_field = max(gap)
bys block_id_enverus: egen largest_gap_block = max(largest_gap_field)

// Interpolate missing production data points (up to a maximum of 2 consecutive quarters)
rename tot_oilgas_output_month tot_oilgas_month
local interp_vars "tot_oilgas_month daily_avg_oilgas_per_well_alt months_producing_since"

foreach d in `interp_vars'{
	bys field_code (month_date): ipolate `d' month_date if gap <= 6, gen(`d'_ip)
}

// Identify blocks with data gaps larger than 2 consecutive quarters
gen blocks_excl_large_gaps = 0
replace blocks_excl_large_gaps = 1 if largest_gap_block > 6

save "$final_data/field_production_data_interpol_FINAL.dta", replace


// Aggregate monthly field-level production data to block level
collapse (mean) monthly_oil monthly_gas daily_avg_oilgas_per_well_alt daily_avg_oilgas_per_well_alt_ip months_producing_since months_producing_since_ip blocks_excl_large_gaps ///
(sum) tot_oilgas_month tot_oilgas_month_ip tot_completed_wells well_count (max) oil gas, ///
by(block_name block_id_enverus block_country area_block_sqkm block_operator month_date year month Province)

replace tot_oilgas_month=. if tot_oilgas_month==0 & missing(monthly_oil) & missing(monthly_gas)
replace tot_oilgas_month_ip=. if tot_oilgas_month_ip==0 & missing(monthly_oil) & missing(monthly_gas)

tempfile field_production_data
save `field_production_data'
restore

// Keep only contract-level production data
keep if EntityType=="CONTRACT" /* "EntityType" specifies the level of reporting. "CONTRACT" refers to blocks. */

// Clean-up block names and IDs
replace block_id_enverus = strtrim(block_id_enverus)
replace block_name = strtrim(block_name)
replace block_name = upper(block_name)
replace block_name = "ANAGUID" if block_name == "ANAGUID EST"
replace block_id = "1355000006" if block_id == "1355000215"
destring(block_id_enverus), replace
format block_id_enverus %20.0f

// Tsset data at block-month level
tsset block_id_enverus month_date
tsfill 

// Fill up characteristics that are constant over time
local block_strings "block_country block_name field_name contract_name block_operator Province"
local block_numeric "tot_completed_wells well_count WellNumber area_block_sqkm"

foreach v in `block_strings'{
	bys block_id_enverus (`v'): replace `v' = `v'[_N] if missing(`v')
}

foreach v in `block_numeric'{
	bys block_id_enverus (`v'): replace `v' = `v'[1] if missing(`v')
}

// Compute number of consecutive months for which production data is missing
tostring block_id_enverus, replace
bys block_id_enverus (month_date): gen spell = sum(missing(daily_avg_oilgas_per_well_alt) != missing(daily_avg_oilgas_per_well_alt[_n-1]))
bys block_id_enverus spell (month_date): gen spell_length = _N
bysort block_id_enverus (month_date) : gen seq = missing(daily_avg_oilgas_per_well_alt) & (!missing(daily_avg_oilgas_per_well_alt[_n-1]) | _n == 1) 
by block_id_enverus : replace seq = seq[_n-1] + 1 if missing(daily_avg_oilgas_per_well_alt) & seq[_n-1] >= 1 & _n > 1 
bys block_id_enverus spell: egen gap = max(seq)
bys block_id_enverus: egen largest_gap_block = max(gap)

// Identify blocks with data gaps larger than 2 consecutive quarters
gen blocks_excl_large_gaps = 0
replace blocks_excl_large_gaps = 1 if largest_gap_block > 6 

// Interpolate missing production data points (up to a maximum of 2 consecutive quarters)
rename tot_oilgas_output_month tot_oilgas_month
local interp_vars "tot_oilgas_month daily_avg_oilgas_per_well_alt months_producing_since"

foreach d in `interp_vars'{
	bys block_id_enverus (month_date): ipolate `d' month_date if gap<=6, gen(`d'_ip)
}

// Data is now aggregated at the block level. Drop all field-level variables
drop field_name operator_field_well EPD_field_operator 

// Append field-level data which has been aggregated at the block level (see code lines 262 to 316)
append using `field_production_data'


********************************************************************************
************ 4. MERGE ASSET TRANSACTIONS DATA AT BLOCK-MONTH LEVEL *************
********************************************************************************

merge m:1 block_id_enverus month_date using "$clean_data/block_asset_transactions.dta"

// Identify blocks with any asset transaction in the given month
gen any_deal = 0
replace any_deal = 1 if _merge==3
bys block_id_enverus: egen has_transaction = max(any_deal)
drop if _merge==2
drop _merge
sort block_name month_date

// Prepare variables for aggregation at quarterly level
gen year_quarter = qofd(dofm(month_date))
format year_quarter %tq
rename daily_avg_oilgas_per_well_alt daily_avg_oilgas_per_well_raw
rename tot_oilgas_month tot_oilgas_month_raw 

// Aggregate monthly data to quarters
collapse (mean) monthly_gas monthly_oil daily_avg_oilgas_per_well_alt_ip daily_avg_oilgas_per_well_raw ///
(max) any_deal oil gas operator_changed has_transaction (min) neutral_deal blocks_excl_large_gaps ///
(sum) tot_oilgas_quarter_ip=tot_oilgas_month_ip tot_oilgas_quarter_raw=tot_oilgas_month_raw interest_purchased ///
tot_completed_wells , ///
by(block_id_enverus block_name block_country area_block_sqkm block_operator year_quarter Province)

replace tot_oilgas_quarter_raw=. if tot_oilgas_quarter_raw==0 & missing(monthly_oil) & missing(monthly_gas)
replace tot_oilgas_quarter_ip=. if tot_oilgas_quarter_ip==0 & missing(monthly_oil) & missing(monthly_gas) & missing(daily_avg_oilgas_per_well_alt_ip)

replace neutral_deal = 1 if interest_purchased < 0

// Determine whether block is (i) purely oil, (ii) purely gas or (iii) both resource types
bys block_id_enverus: egen oil_block = max(oil)
bys block_id_enverus: egen gas_block = max(gas)
gen resource_type = ""
replace resource_type = "OIL" if oil_block==1 & gas_block==0
replace resource_type = "GAS" if gas_block==1 & oil_block==0
replace resource_type = "OIL & GAS" if gas_block==1 & oil_block==1

// Identify firms' headquarter countries
gen hq = ""
replace hq = "Senegal" if block_operator=="AFRICA FORTESA"
replace hq = "Nigeria" if block_operator=="AITEO CONSORTIUM"
replace hq = "Nigeria" if block_operator=="AMNI"
replace hq = "United States" if block_operator=="APO"
replace hq = "Nigeria" if block_operator=="ATLAS ORANTO"
replace hq = "Nigeria" if block_operator=="BELEMAOIL"
replace hq = "United Kingdom" if block_operator=="BP"
replace hq = "Nigeria" if block_operator=="BRITTANIA-U"
replace hq = "Sweden/Tunisia" if block_operator=="CFTP"
replace hq = "United States" if block_operator=="CHEVRON"
replace hq = "Nigeria" if block_operator=="CONOIL"
replace hq = "Tunisia" if block_operator=="CTKCP"
replace hq = "Nigeria" if block_operator=="DUBRI"
replace hq = "United Kingdom/Nigeria" if block_operator=="ELCREST"
replace hq = "Nigeria" if block_operator=="ENERGIA"
replace hq = "Italy" if block_operator=="ENI"
replace hq = "Nigeria" if block_operator=="EROTON"
replace hq = "Tunisia" if block_operator=="ETAP"
replace hq = "Tunisia" if block_operator=="EXXOIL"
replace hq = "United States" if block_operator=="EXXONMOBIL"
replace hq = "United States" if block_operator=="FRONTIER"
replace hq = "Netherlands" if block_operator=="GEOFINANCE"
replace hq = "Egypt" if block_operator=="HBS"
replace hq = "United Kingdom" if block_operator=="HERITAGE ENERGY"
replace hq = "Sweden" if block_operator=="LUNDIN PETROLEUM"
replace hq = "Canada/Tunisia" if block_operator=="MARETAP"
replace hq = "Netherlands" if block_operator=="MAZARINE"
replace hq = "Indonesia" if block_operator=="MEDCO"
replace hq = "Nigeria" if block_operator=="MIDWESTERN"
replace hq = "Nigeria" if block_operator=="MONI PULO"
replace hq = "Nigeria" if block_operator=="NECONDE"
replace hq = "Nigeria" if block_operator=="NEPN"
replace hq = "Nigeria" if block_operator=="NEWCROSS"
replace hq = "Nigeria" if block_operator=="NIGER DELTA"
replace hq = "Nigeria" if block_operator=="NNPC"
replace hq = "" if block_operator=="NOT OPERATED"
replace hq = "Austria" if block_operator=="OMV"
replace hq = "Nigeria" if block_operator=="ORIENTAL ENERGY"
replace hq = "United Kingdom" if block_operator=="PERENCO"
replace hq = "Nigeria" if block_operator=="PILLAR"
replace hq = "Nigeria" if block_operator=="PLATFORM"
replace hq = "Nigeria" if block_operator=="PLUSPETROL"
replace hq = "Nigeria" if block_operator=="PRIME"
replace hq = "Nigeria" if block_operator=="SAHARA GROUP"
replace hq = "india" if block_operator=="SANDESARA"
replace hq = "United Kingdom" if block_operator=="SEPLAT"
replace hq = "United Kingdom/Tunisia" if block_operator=="SEREPT"
replace hq = "United Kingdom" if block_operator=="SERINUS"
replace hq = "Nigeria" if block_operator=="SAVANNAH"
replace hq = "Netherlands" if block_operator=="SHELL"
replace hq = "China" if block_operator=="SINOPEC"
replace hq = "Italy/Tunisia" if block_operator=="SITEP"
replace hq = "Italy/Tunisia" if block_operator=="SODEPS"
replace hq = "Angola" if block_operator=="SOMOIL"
replace hq = "Angola" if block_operator=="SONANGOL"
replace hq = "France" if block_operator=="TOTAL"
replace hq = "United States" if block_operator=="TPS"
replace hq = "United Kingdom" if block_operator=="TULLOW"
replace hq = "Nigeria" if block_operator=="WALTERSMITH"
replace hq = "Nigeria" if block_operator=="YINKA FOLAWIYO"
replace hq = "United States" if block_operator=="ANGOLA LNG"	
replace hq = "United Kingdom" if block_operator=="ATOG"

// Trim production variables at 99th percentile
winsor2 daily_avg_oilgas_per_well_alt_ip, cuts(0 99) trim replace
winsor2 tot_oilgas_quarter_ip, cuts(0 99) trim replace

// Generate dependent variables
gen ln_daily_avg_oilgas_per_well = ln(daily_avg_oilgas_per_well_alt_ip)
gen ln_tot_oilgas_quarter = ln(tot_oilgas_quarter_ip)

// Generate post period indicator
gen post_2013 = 0
replace post_2013 = 1 if year_quarter>=tq(2014q1)

// Identify license acquisitions by non-EPD firms
gen non_epd_deal = 0
replace non_epd_deal = 1 if neutral_deal !=1 & any_deal == 1 

// Identify year-quarter of license acquisitions
gen deal_date = year_quarter if any_deal==1
bys block_id_enverus: egen first_deal_date = min(deal_date)
format deal_date first_deal_date %tq

gen non_epd_deal_date = year_quarter if any_deal==1 & non_epd_deal==1
bys block_id_enverus: egen first_non_epd_deal_date = min(non_epd_deal_date)
format non_epd_deal_date first_non_epd_deal_date %tq

// Generate "Acquired Share" variable 
gen ln_interest_purchased = ln(interest_purchased) if any_deal == 1 & neutral_deal != 1
bys block_id_enverus (year_quarter): replace ln_interest_purchased = ln_interest_purchased[_n-1] if year_quarter > first_non_epd_deal_date
replace ln_interest_purchased = 0 if missing(ln_interest_purchased)

// Identify block ownership changes
gen OC = 0
replace OC = 1 if year_quarter >= first_deal_date

// Identify license acquisitions by non-EPD firms
gen OC_non_EPD = 0
replace OC_non_EPD = 1 * ln_interest_purchased if year_quarter >= first_non_epd_deal_date

// Identify block ownership changes in the post period
gen OC_post_2013 = 0
replace OC_post_2013 = 1 if OC==1 & first_deal_date >= tq(2014q1)

// Identify license acquisitions by non-EPD firms in the post period
gen OC_non_EPD_post_2013 = 0
replace OC_non_EPD_post_2013 = 1 * ln_interest_purchased if year_quarter>=first_non_epd_deal_date & first_non_epd_deal_date>=tq(2014q1)

// Identify treated blocks (i.e., blocks with at least 1 acquisition by non-EPD firms in the post-period)
bys block_id_enverus: egen treated = max(OC_non_EPD_post_2013)

// Define regression sample
keep if year_quarter >= tq(2010q1) & year_quarter <= tq(2017q4) & blocks_excl_large_gaps == 0

// Generate fixed effects
egen block_FE = group(block_id_enverus)
egen resourcetype_yrqt_FE = group(resource_type year_quarter)

// Label variables
label var ln_daily_avg_oilgas_per_well "Ln(Output per Well)"
label var ln_interest_purchased "Ln(Acquired Share)"
label var ln_tot_oilgas_quarter "Ln(Total Output)"
label var non_epd_deal "Non-EPD Firm Entry"
label var OC_non_EPD_post_2013 "Non-EPD Firm Entry $\times$ Post 2013 $\times$ Ln(Acquired Share)"
label var OC_non_EPD "OC $\times$ Non-EPD Acquiror"
label var OC_post_2013 "OC $\times$ Post 2013"
label var post_2013 "Post 2013"
label var OC "OC"


// Save merged and cleaned productivity dataset
save "$final_data/block_entry_analysis_clean_FINAL.dta", replace
********************************************************************************
******                                                                   *******
******             ARTICLE: Extraction Payment Disclosures               *******
******             AUTHOR: Thomas Rauter                                 *******
******             JOURNAL OF ACCOUNTING RESEARCH                        *******
******             CODE TYPE: Clean and Standardize Company Names        *******
******             LAST UPDATED: August 2020                             *******
******                                                                   *******
********************************************************************************

// Clean company names
gen company_cleaned = company

replace company_cleaned = subinstr(company_cleaned,"LLC","",.) 
replace company_cleaned = subinstr(company_cleaned,"LLP","",.) 
replace company_cleaned = subinstr(company_cleaned,"AS","",.) 
replace company_cleaned = subinstr(company_cleaned,"Ltd","",.) 
replace company_cleaned = subinstr(company_cleaned,"JSC","",.) 
replace company_cleaned = subinstr(company_cleaned,"ХХК","",.) 
replace company_cleaned = subinstr(company_cleaned,"LIMITED","",.) 
replace company_cleaned = subinstr(company_cleaned,"(ХХК)","",.) 
replace company_cleaned = subinstr(company_cleaned,"Limited","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD","",.) 
replace company_cleaned = subinstr(company_cleaned,"SPRL","",.) 
replace company_cleaned = subinstr(company_cleaned,"SA","",.)
replace company_cleaned = subinstr(company_cleaned,"SARL","",.) 
replace company_cleaned = subinstr(company_cleaned,"ASA","",.) 
replace company_cleaned = subinstr(company_cleaned,"PLC","",.) 
replace company_cleaned = subinstr(company_cleaned,"Corporation","",.) 
replace company_cleaned = subinstr(company_cleaned,"Company","",.) 
replace company_cleaned = subinstr(company_cleaned,"Ltd.","",.) 
replace company_cleaned = subinstr(company_cleaned,"SAS","",.) 
replace company_cleaned = subinstr(company_cleaned,"Plc","",.) 
replace company_cleaned = subinstr(company_cleaned,"B.V.","",.) 
replace company_cleaned = subinstr(company_cleaned,"Inc.","",.) 
replace company_cleaned = subinstr(company_cleaned,"MINING","",.) 
replace company_cleaned = subinstr(company_cleaned,"S.A.","",.) 
replace company_cleaned = subinstr(company_cleaned,"COMPANY","",.) 
replace company_cleaned = subinstr(company_cleaned,"JSC*","",.) 
replace company_cleaned = subinstr(company_cleaned,"AS2)","",.) 
replace company_cleaned = subinstr(company_cleaned,"International","",.) 
replace company_cleaned = subinstr(company_cleaned,"CORPORATION","",.) 
replace company_cleaned = subinstr(company_cleaned,"Inc","",.) 
replace company_cleaned = subinstr(company_cleaned,"Resources","",.) 
replace company_cleaned = subinstr(company_cleaned,"plc","",.) 
replace company_cleaned = subinstr(company_cleaned,"(ХК)","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD.","",.) 
replace company_cleaned = subinstr(company_cleaned,"NUF","",.) 
replace company_cleaned = subinstr(company_cleaned,"ХК","",.) 
replace company_cleaned = subinstr(company_cleaned,"B.V","",.) 
replace company_cleaned = subinstr(company_cleaned,"DRC","",.) 
replace company_cleaned = subinstr(company_cleaned,"Branch","",.) 
replace company_cleaned = subinstr(company_cleaned,"C","",.) 
replace company_cleaned = subinstr(company_cleaned,"Co.","",.) 
replace company_cleaned = subinstr(company_cleaned,"Incorporated","",.) 
replace company_cleaned = subinstr(company_cleaned,"Group","",.) 
replace company_cleaned = subinstr(company_cleaned,"S.A","",.) 
replace company_cleaned = subinstr(company_cleaned,"COMPAGNY","",.) 
replace company_cleaned = subinstr(company_cleaned,"INC","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD**","",.) 
replace company_cleaned = subinstr(company_cleaned,"A/S","",.) 

replace company_cleaned = rtrim(company_cleaned)
replace company_cleaned = ltrim(company_cleaned)
replace company_cleaned = strtrim(company_cleaned)
replace company_cleaned = strltrim(company_cleaned)
replace company_cleaned = stritrim(company_cleaned)
replace company_cleaned = strrtrim(company_cleaned)

replace company_cleaned = subinstr(company_cleaned, char(34),"",.)
replace company_cleaned = subinstr(company_cleaned," ","",.) 
replace company_cleaned = subinstr(company_cleaned,".","",.) 
replace company_cleaned = subinstr(company_cleaned,",","",.) 
replace company_cleaned = subinstr(company_cleaned,"(","",.) 
replace company_cleaned = subinstr(company_cleaned,")","",.)
replace company_cleaned = subinstr(company_cleaned,"&","",.)
replace company_cleaned = subinstr(company_cleaned,"*","",.) 
replace company_cleaned = subinstr(company_cleaned,"-","",.) 
replace company_cleaned = subinstr(company_cleaned,"'","",.) 
replace company_cleaned = subinstr(company_cleaned,"´","",.) 
replace company_cleaned = subinstr(company_cleaned,"`","",.) 
replace company_cleaned = subinstr(company_cleaned,"̂","",.)

replace company_cleaned = subinstr(company_cleaned,"è","e",.) 
replace company_cleaned = subinstr(company_cleaned,"é","e",.) 
replace company_cleaned = subinstr(company_cleaned,"é","e",.) 
replace company_cleaned = subinstr(company_cleaned,"É","E",.) 

replace company_cleaned = upper(company_cleaned)
********************************************************************************
******                                                                   *******
******           ARTICLE: Extraction Payment Disclosures                 *******
******           AUTHOR: Thomas Rauter                                   *******
******           JOURNAL OF ACCOUNTING RESEARCH                          *******
******           CODE TYPE: Clean and Standardize Country Names          *******
******           LAST UPDATED: August 2020                               *******
******                                                                   *******
********************************************************************************

kountry segment_description, from(other) marker

*Replace country names that are misspelt
rename segment_description IN 
rename NAMES_STD NAMES

replace NAMES="China" if IN=="/CHINA " | IN=="/CHINA" | IN=="B&Q CHINA SALES" | ///
	IN=="BEIJING" | IN=="CHINA EX HONG KONG AND MACAU " | ///
	IN=="CHINA INLAND" |  IN=="CHINA(EXCEPT HONGKONG,TAIWAN)" | ///
	IN=="CHINA-SHENZHEN" | IN=="CHINESE MAINLAND" | IN=="EAST CHINA" | ///
	IN=="EASTERN CHINA" | IN=="ELSEWHERE IN PRC" | IN=="ELSEWHERE IN THE PRC" | ///
	IN=="ELSWHERE IN THE PRC" | IN=="GREAT CHINA" | IN=="GREATER CHINA" | ///
	IN=="GUANGDONG" | IN=="GUANGXI (AUTONOMOUS REGION)" |  ///
	IN=="MAINLANC CHINA" | IN=="MAINLAND CHINA" | ///
	IN=="MAINLAND PRC" | IN=="NORTH CHINA" | IN=="NORTHEASTERN CHINA" | ///
	IN=="NORTHERN CHINA" | IN=="OTHER PARTS OF CHINA" | ///
	IN=="OTHER PARTS OF PRC" | IN=="OTHER REGION IN PRC" | IN=="OTHER REGIONS IN PR" | ///
	IN=="OTHER REGIONS IN PRC" | IN=="OTHER REGIONS IN THE PRC" | ///
	IN=="P R CHINA"| IN=="P. R. CHINA" | IN=="P.R. CHINA" | IN=="P.R. OF CHINA" | ///
	IN=="P.R.CHINA" | strpos(IN, "REPUBLIC OF CHINA") | IN=="PEOPLE'S REPUBLIC'S OF CHINA" | ///
	IN=="PEOPLES REPUBLIC OF" | IN=="PEOPLES REPUBLIC OF C" | IN=="PEOPLES REPUBLIC OF CHINA" | ///
	IN=="PRC" | IN=="PRC (DOMICILE)" | IN=="PRC (OTHER THAN HONG KONG)" | IN=="PRC EXCEPT HONG KONG" | ///
	IN=="PRC MAINLAND" | IN=="PRC OTHER THAN HONG KONG,MACAO & TAIWAN" | ///
	IN=="REGIONS IN THE PRC OTH THAN HK AND MACAU" | IN=="REPUBLIC OF CHINA" | IN=="REST OF PRC" | ///
	IN=="REST OF PRC & OTHER" | IN=="REST OF PRC AND OTHERS" | IN=="SHANDONG PROVINCE" | ///
	IN=="SHANGHAI" | IN=="SHANXI PROVINCE" | IN=="SOUTH CHINA" | IN=="SOUTHERN CHINA" | ///
	IN=="THE  PRC" | IN=="THE MAINLAND CHINA" | IN=="THE PEOPLE'S REPUBLIC OF CHINA" | ///
	IN=="THE PRC" | IN=="THE PRC EXCL HONGKONG" | IN=="THE PRC OTHER THAN" | ///
	IN=="THE PRC OTHER THAN HONG KONG AND MACAU" | IN=="WEST CHINA" | ///
	IN=="WESTERN CHINA" | IN=="WITHIN PRC" | IN=="XINJIANG PROVINCE" | IN=="CENTRAL CHINA" | ///
	IN=="OTHER REGIONS OF MAINLAND CHINA" | IN=="PEOPLE OF REPUBLIC CHINA" 
replace NAMES="Hong Kong" if IN=="HK" | IN=="HONG KONG & CORPORATE" | IN=="HONG KONG SAR" | ///
	IN=="HONG KONG, SAR" | IN=="OTHER HK"
replace NAMES="Macao" if IN=="MACAU OPERATIONS"
replace NAMES="Taiwan" if IN=="TAIWAN, REPUBLIC OF"
replace NAMES="India" if IN=="ANDHRA PRADESH" | IN=="CHHATTISGARH" | ///
	IN=="DISCONTINUED OPERATIONS- INDIA"  | IN=="ELIMINATIONS/INDIA" | IN=="IN INDIA" | ///
	IN=="INDIA REGION" | IN=="INDIAN OPERATIONS" | IN=="INDIAN SUB-CONTINENT" | ///
	IN=="INIDA" | IN=="JAMMU" | IN=="SALES WITHIN INDIA" | IN=="WITH IN INDIA" | ///
	IN=="WITH-ININDIA" | IN=="WITHIN INDIA" | IN=="WTIHIN INDIA" | IN=="ANDHRA PRADESH" | ///
	IN=="INDAI"
replace NAMES="UAE" if IN=="ABU DHABI (EMIRATE)" | IN=="DUBAI" | ///
	IN=="DUBAI (EMIRATE)" | IN=="EMIRATES" | IN=="NORTHERN EMIRATES" | ///
	IN=="UNITED ARAB EMIRATE" | IN=="UNITED ARAB EMIRATESZ" | ///
	IN=="ABU DHABI (EMIRATE)"
replace NAMES="Canada" if IN=="ALBERTA" | IN=="BRITISH COLUMBIA" | ///
	IN=="CANADA - BACK WATER PROJECT" | IN=="CANADA - NEW AFTON" | ///
	IN=="CANADA- OPERATING SEGMENT" | IN=="CANADA- RAINY RIVER" | ///
	IN=="CANADIAN" | IN=="CANADIAN OILFIELD SERVICES" | ///
	IN=="CANADIAN OPERATIONS" | IN=="CANANDA" | IN=="CANDA" | ///
	IN=="CHILDREN'S PLACE CANADA" | IN=="OTHER CANADIAN OPERATIONS" | ///
	IN=="RED LAKE - CANADA" | IN=="ROCKY MOUNTAINS" | IN=="SASKATCHEWAN" | ///
	IN=="SOUTHERN ONTARIO" | IN=="SYNCRUDE" | IN=="WESTERN CANADA" | ///
	IN=="ALBERTA"
replace NAMES="United States" if IN=="AMERICA" | IN=="ALASKA" | ///
	IN=="AHOLD USA" | IN=="AMERICAN OPERATIONS" | ///
	IN=="AMERICAN REGION" | IN=="AMERICAN ZONE" | ///
	IN=="AMRERICANS" | IN=="ATLANTA" | ///
	IN=="CENTRAL UNITED STATES (DIVISION)" | ///
	IN=="CHICAGO" | IN=="CHILDREN'S PLACE UNITED STATES" | ///
	IN=="CONTINENTAL US" | IN=="CORPORATE & TRADICO (U.S.)" | ///
	IN=="DALLAS" | IN=="DELAWARE" | IN=="DENVER" | IN=="DETROIT" | ///
	IN=="EAST TEXAS/LOUISIANA" | IN=="EASTERN UNITED STATES (DIVISION)" | ///
	IN=="HOUSTON" | IN=="LAS VEGAS OPERATIONS" | IN=="LOS ANGELES" | ///
	IN=="MARYLAND" | IN=="MIDDLE AMERICA" | IN=="MIDSTREAM UNITED STATES" | ///
	IN=="NEW MEXICO" | IN=="NEW YORK" | IN=="NORTHEAST UNITED STATES (DIVISION)" | ///
	IN=="NORTHERN VIRGINI" | IN=="OKLAHOMA" | IN=="PLP-USA" | ///
	IN=="REGIONAL UNITED STATES" | IN=="SAN DIEGO" | IN=="SAN FRANCISCO BAY" | ///
	IN=="SAO FRANCISCO MINE" | IN=="LASALLE INVESTMENT MANAGEMENT SERVICES" | ///
	IN=="LUMMUS" | IN=="MARCELLUS SHALE" | IN=="PICEANCE BASIN" | ///
	IN=="SOUTH UNITED STATES (DIVISION)" | IN=="SOUTHERN VIRGINIA" | ///
	IN=="STAMFORD / NEW YORK" | IN=="T.R.N.C." | IN=="TEXAS" | IN=="TEXAS (STATE)" | ///
	IN=="TEXAS PANHANDLE" | IN=="U S A" | IN=="U. S. MEDICAL" | ///
	IN=="U.S - MESQUITE MINE" | IN=="U.S. & POSSESSIONS" | IN=="U.S. DOMESTIC" | ///
	IN=="U.S. GULF OF MEXICO" | IN=="U.S. OPERATIONS" | IN=="UINITED STATES" | ///
	IN=="UINITED STATES" | IN=="UMITED STATES" | IN=="UNIRED STATES" | ///
	IN=="UNITATED STATES" | IN=="UNITE STATES" | IN=="UNITED  STATE" | ///
	IN=="UNITED SATES" | IN=="UNITED STAES" | IN=="UNITED STARES" | ///
	IN=="UNITED STATE" | IN=="UNITED STATED" | ///
	IN=="UNITED STATES                      UNITE" | IN=="UNITED STATES / DOMESTIC" | ///
	IN=="UNITED STATES AMERICA"  | IN=="UNITED STATES AND ITS TERRITORIES" | ///
	IN=="UNITED STATES OF AM" | IN=="UNITED STATES OF AMER" | ///
	IN=="UNITED STATES OILFIELD SERVICES" | IN=="UNITED STATES OPERATIONS" | ///
	IN=="UNITED STATESS" | IN=="UNITES STATES" | IN=="UNITTED STATES" | ///
	IN=="UNTIED STATES" | IN=="US GULF" | IN=="US WEST" | IN=="US- AMESBURYTRUTH" | ///
	IN=="USA (NAFTA)" | IN=="USA EXPLORATION" | IN=="USA PRODUCTION"  | ///
	IN=="UUNITED STATES" | IN=="WASHINGTON (D.C)" | IN=="WEST UNITED STATES (DIVISION)" | ///
	IN=="WHARF - UNITED STATES" | IN=="WYNN BOSTON HARBOR" | IN=="CENTRAL APPALACHIA" | ///
	IN=="UINTED STATES" | IN=="WILLISTON BASIN" | IN=="AHOLD USA" | IN=="ALASKA"
replace NAMES="Germany" if IN=="AIRLINE GERMANY" | IN=="DEUTSCHLAND" | ///
	IN=="GEMANY" | IN=="GERMAN LANGUAGE COUNT"	| IN=="GERMAN MARKET" | ///
	IN=="GERMANY - LYING SYSTEMS" | IN=="GERMANY - SURFACE CARE" | ///
	IN=="GERMANY RETAIL" | IN=="GERMEN" | IN=="NORTHERN GERMANY" | ///
	IN=="PARENT COMPANY - GERMANY" | IN=="SOUTHERN GERMANY" | IN=="AIRLINE GERMANY" | ///
	IN=="GERMAN OPERATIONS"
replace NAMES="Argentina" if IN=="ALUMBERA - ARGENTINA" | IN=="MISC ARGENTINA" | ///
	IN=="ARGENTINA-OIL GAS" | IN=="ALUMBERA - ARGENTINA"
replace NAMES="Russia" if IN=="AMURSK ALBAZINO" | IN=="INTERNATIONAL OPERATION/RUSSIA" | ///
	IN=="MOSCOW" | IN=="MOSCOW AND  MOSCOW RE" | IN=="RUSSIA  - MOBILE" | ///
	IN=="RUSSIA FIXED" | IN=="RUSSIAN" | IN=="RUSSIAN FEDERATIONS" | ///
	IN=="SALES IN RUSSIA" | IN=="KRASNOYARSK BUSINESS UNIT" | IN=="KYZYL" | ///
	IN=="MAGADAN BUSINESS UNIT" | IN=="MAYSKOYE" | IN=="OKHOTSK" | IN=="OMOLON" | ///
	IN=="ST. PETERSBURG" | IN=="YAKUTSK KURANAKH BUSINESS UNIT"
replace NAMES="Jordan" if IN=="AQABA" | IN=="INSIDE JORDAN" | IN=="JORDAN EXCEPT AQABA"
replace NAMES="Egypt" if IN=="ARAB REPUBLIC OF EGYPT"
replace NAMES="Mexico" if IN=="ARANZAZU MINES" | IN=="MEXCIO" | IN=="MEXICO (AMERICAS)" | ///
	IN=="OTHER INTERNATIONAL(MEXICO)" | IN=="PENASQUITO" 
replace NAMES="Australia" if IN=="AUATRALIA" | IN=="AUSTALIA" | ///
	IN=="AUSTRALIA EXPLORATION" | IN=="AUSTRALIA PACIFIC" | ///
	IN=="AUSTRALIA PRODUCTION" | IN=="AUSTRALIAN" | ///
	IN=="AUSTRALIAN CAPITAL TERRITORY" | IN=="AUSTRALIAN OPEARTIONS" | ///
	IN=="AUTRALIA" | IN=="CORPORATE AUSTRALIA" | IN=="GULLEWA" | ///
	IN=="OTHER AUSTRALIA" | IN=="RECTRON AUSTRALIA" | IN=="NEW SOUTH WALES" | ///
	IN=="QUEENSLAND" | IN=="QUEENSLAND." | IN=="SOUTH AUSTRALIA" | IN=="WESTERN AUSTRALIA" | ///
	IN=="EASTERN AUSTRALIA"
replace NAMES="Austria" if IN=="AUSTRIA (HOLDING)"
replace NAMES="Bahrain" if IN=="BAHARAIN"
replace NAMES="Bangladesh" if IN=="BANGALDESH"
replace NAMES="Guinea" if IN=="BAOULE - GUINEA"
replace NAMES="Barbados" if IN=="BARBODOS"
replace NAMES="Indonesia" if IN=="BEKASI" | IN=="CAKUNG" | IN=="CIKANDE" | ///
	IN=="DKI JAKARTA" | IN=="INDONESIAN" | IN=="INDONSIA" | ///
	IN=="REPUBLIC OF INDONESIA" | IN=="JABODETABEK" | IN=="JAKARTA" | ///
	IN=="JAKARTA AND BOGOR" | IN=="JAVA ISLAND" | IN=="JAVA ISLAND (EXC. JAKARTA)" | ///
	IN=="JAWA" | IN=="JAWA (EXCLUDING JAKARTA)" | IN=="JAWA, BALI DAN NUSA TENGGARA" | ///
	IN=="JAWA, BALI DAN NUSA TENGGARA" | IN=="JAWA-BALI" | IN=="JAYAPURA" | ///
	IN=="KALIMANTAN" | IN=="KALIMANTAN,SULAWESI & MALUKU" | IN=="MAKASSAR" | IN=="MEDAN" | ///
	IN=="PALEMBANG" | IN=="PASURUAN" | IN=="PONDOK CABE" | IN=="PURWAKARTA" | ///
	IN=="SEMARANG" | IN=="SERANG" | IN=="SULAWESI AND MALUKU" | IN=="SULAWESI DAN PAPUA" | ///
	IN=="SUMATERA" | IN=="TANGERANG" | IN=="THE REPUBLIC OF INDONESIA" | IN=="BALI AND LOMBOK ISLAND" | ///
	IN=="EAST JAVA" | IN=="BANDUNG"
replace NAMES="Belarus" if IN=="BELORUSSIA" | IN=="REPUBLIC OF BELARUS" | IN=="BELAUS"
replace NAMES="Bulgaria" if IN=="BOLGARIA"
replace NAMES="Bosnia and Herzegovina" if IN=="BOSNIA AND  HERZEGOVI" | ///
	IN=="BOSNIA AND HERZEGOVIN"
replace NAMES="France" if IN=="BOURGOGNE (METROPOLITAN REGION)" | ///
	IN=="EUROPE (REGION)-FRANCE " | IN=="FBB FRANCE" | IN=="FRANCE & DOM-TOM" | ///
	IN=="FRANCE & TERRITORIES" | IN=="FRANCE (DOM)" | IN=="FRANCE (REUNION ISLAND)" | ///
	IN=="FRANCE (REUNION ISLAND)" | IN=="FRANCE WITH DOM-TOM" | IN=="FRANCE/DOM-TOM" | ///
	IN=="FRENCH OVERSEAS DOMINIONS & TERRITORIES" | IN=="FRENCH OVERSEAS TERRITORIES" | ///
	IN=="LE-DE-FRANCE (METROPOLITAN REGION)" | IN=="PARIS" | ///
	IN=="PROVENCE-ALPES-C TE-D'AZUR (METROPOLITAN REGION)" | IN=="PIXMANIA" | ///
	IN=="RH NE ALPES (METROPOLITAN REGION)" | IN=="FRANCE - RENTAL PROPERTIES" | ///
	IN=="FRENCH"
replace NAMES="Brazil" if IN=="BRASIL" | IN=="BRAZIL/EXPORT" | IN=="BRAZILIAN MINES" | ///
	IN=="BRAZIL DRILLING OPERATIONS" | IN=="BRAZIL EXPLORATION & EVALUATION" | IN=="BRAZIL/IMPORTS"
replace NAMES="United Kingdom" if IN=="BRITAIN" | IN=="BRITIAN" | IN=="INTERNATIONAL (UK)" | ///
	IN=="U.K. AND ELIMINATION" | IN=="UK BUS (LONDON)" | IN=="UK BUS (REGIONAL OPERATIONS)" | ///
	IN=="UK RAIL" | IN=="UK RETAIL" | IN=="UNITED  KINDOM" | IN=="UNITED KINDOM" | ///
	IN=="UNITED KINGDOM (INCLUDING EXPORTS)" | IN=="UNITED KINGDOM - CONTINUING" | ///
	IN=="UNITED KINGDOM - INVESTING ACTIVITIES" | IN=="UNITED KINGDOM- OPERATING SEGMENT" | ///
	IN=="UNITED KINGDOM/BVI" | IN=="UNITED KINGDON" | IN=="UNITED KINGSOM" | IN=="XANSA" | ///
	IN=="UNITED KIGDOM" | IN=="GREAT BRITAN" | IN=="GREAT BRITIAN" | IN=="REST OF UK" | ///
	IN=="UK OPERATIONS"
replace NAMES="British Virgin Islands" if IN=="BRITISH VIRGIN ISLAND" | IN=="BVI"
replace NAMES="Belgium" if IN=="BRUSSELS" | IN=="FLANDERS" | IN=="WALLONIA"
replace NAMES="Israel" if IN=="BUILDINGS FOR SALE IN ISRAEL" | IN=="ISRAEL - RENTAL PROPERTIES"
replace NAMES="Tanzania" if IN=="BULYANHULU" | IN=="BUZWAGI" | IN=="NORTH MARA" | ///
	IN=="TANZANIA - AGRICULTURE & FORESTRY" | IN=="TANZANIA - EXPLORATION & DEVELOPMENT" | ///
	IN=="TULAWAKA"
replace NAMES="Burkina Faso" if IN=="BURKINA FASOFASO" 
replace NAMES="Chile" if IN=="CABECERAS" | IN=="CHILE - ELMORRO PROJECT" | ///
	IN=="LATAM" | IN=="LATAM OPERATIONS" | IN=="LATAM."
replace NAMES="Cambodia" if IN=="CAMBODGE" | IN=="KINGDOM OF CAMBODIA"
replace NAMES="Cameroon" if IN=="CAMEROON, UNITED REPUBLIC OF" | ///
	IN=="REPUBLIC OF CAMEROON"
replace NAMES="Turkey" if IN=="CAYELI (TURKEY)" | IN=="TURKEY OPERATIONS" | ///
	IN=="TURKISH REPUBLIC" | IN=="TURKISH REPUBLIC OF NORTHERN CYPRUS" | IN=="TURKY"
replace NAMES="Japan" if IN=="CENTRAL JAPAN" | IN=="EASTERN JAPAN" | ///
	IN=="JAPAN EAST" | IN=="JAPAN WEST" | IN=="JAPANP" | IN=="JAPNA" | ///
	IN=="OPERATING SEGEMENT-JAPAN" | IN=="WEST JAPAN" | IN=="JAPAN OPERATION"
replace NAMES="England" if IN=="CENTRAL LONDON" | IN=="DORSET" | ///
	IN=="LONDON" | IN=="LONDON & SOUTH" | IN=="SLAD" | IN=="SOUTHERN ENGLAND EXPLORATION" | ///
	IN=="THAMES VALLEY" | IN=="THAMES VALLEY AND THE REGIONS" | IN=="CENTRAL LONDON" | ///
	IN=="DORSET" 
replace NAMES="Norway" if IN=="CENTRAL NORWAY" | IN=="MEKONOMEN NORWAY" | ///
	IN=="MID-NORWAY" | IN=="NORTH-NORWAY" | IN=="NORTHERN NORWAY" | IN=="MALM" | ///
	IN=="THE OSLO FJORD"
replace NAMES="Colombia" if IN=="COLUMBIA"
replace NAMES="Congo" if IN=="CONGO-BRAZZAVILLE / REPUBLIC OF CONGO" | ///
	IN=="REPUBLIC OF CONGO" | IN=="REPUBLIC OF THE CONGA" | IN=="REPUBLIC OF THE CONGO" | ///
	IN=="CONGO-BRAZZAVILLE / REPUBLIC OF CONGO" | IN=="REPUBLIC OF CONGO"
replace NAMES="Democratic Republic of Congo" if IN=="DR CONGO" | IN=="DRC"
replace NAMES="Ivory Coast" if strpos(IN, "IVOIRE") | IN=="IVORY COASTIVORY CO" | ///
	IN=="VORY COAST"
replace NAMES="Croatia" if IN=="CROTATIA" | IN=="CROTIA" | IN=="REPUBLIC OF CROATIA"
replace NAMES="Czech Republic" if IN=="CZECH REPUBLIC TOTAL" | IN=="CZECH REPUBLIC LOTTERY" | ///
	IN=="CZECH REPUBLIC SPORTS BETTING"
replace NAMES="Dominican Republic" if IN=="DOMINICAN REPB."
replace NAMES="Malaysia" if IN=="EAST MALAYSIA" | IN=="MALAYSIA (ASIA)" | ///
	IN=="MALAYSIA(DOMESTIC)" | IN=="MALAYSIA/LOCAL" | IN=="MALAYSIAN OPERATIONS" | ///
	IN=="NALAYSIA" | IN=="WEST MALAYSIA" | IN=="WITHIN MALAYSIA"
replace NAMES="Timor-Leste" if IN=="EAST TIMOR / TIMOR-LESTE"
replace NAMES="Uruguay" if IN=="URUGUAY DRILLING OPERATIONS"
replace NAMES="Spain" if IN=="EL SAUZAL" | IN=="LAS CRUCES(SPAIN)" | ///
	IN=="SPAIN - DISC. OP."
replace NAMES="Ethiopia" if IN=="ETHOPIA"
replace NAMES="Finland" if IN=="FINLAND (DISCONTINUED OPERATIONS)" | ///
	IN=="FINLAND/OUTOKUMPU" | IN=="FINNLAND" | IN=="OTHER FINLAND" | ///
	IN=="PYHASALMI (FINLAND)" | IN=="REST OF FINLAND" | IN=="RAUMA"
replace NAMES="Guiana" if IN=="FRENCH GUYANA" | IN=="FRENCH GUYANE" | ///
	IN=="FRENCH GUIANA (DEPENDENT TERRITORY)"
replace NAMES="Greece" if IN=="GEECE" | IN=="GREEK"
replace NAMES="Greenland" if IN=="GREEN LAND"
replace NAMES="Guatemala" if IN=="GUATEMAL"
replace NAMES="Sweden" if IN=="HELSINGBORG" | IN=="HUDDINGE" | IN=="OTHER SWEDEN" | ///
	IN=="LIDINGO" | IN=="LUND" | IN=="SOUTHERN STOCKHOLM" | IN=="STOCKHOLM" | ///
	IN=="SWEDEN- OPERATING SEGMENT" | IN=="WESTERN STOCKHOLM" | IN=="HELSINGFORS"
replace NAMES="Netherlands" if IN=="HOLAND" | IN=="THE NETHERLAND"
replace NAMES="Hungary" if IN=="HUNGARIAN"
replace NAMES="Switzerland" if IN=="INDIVIDUAL LIFE SWITZERLAND" | IN=="SWIZERLAND" | ///
	IN=="SWIZTERLAND"
replace NAMES="Kuwait" if IN=="INSIDE KUWAIT" | IN=="STATE OF KUWAIT"
replace NAMES="South Africa" if IN=="INTRA- SEGMENTAL SOUTH AFRICA" | ///
	IN=="REPUBLIC OF SOUTH AFRICA" | IN=="KWAZULU-NATAL" | IN=="SOUTH AFRICA (VODACOM" | ///
	IN=="SOUTH AFRICA (VODACOM)" | IN=="GAUTENG"
replace NAMES="Kazakhstan" if IN=="KAZAKHISTAN" | IN=="KAZACHSTAN" | ///
	IN=="KAZAKHSTHAN BUSINESS UNIT" | IN=="REP OF KAZAKHSTAN" | ///
	IN=="REPUBLIC OF KAZAKHSTAN"
replace NAMES="Saudi Arabia" if strpos(IN, "KINGDOM OF SAUDI ARA") | ///
	IN=="SAUDI" | IN=="SAUDI AERABIA" | IN=="SAUDI ARAB" | IN=="SAUDI ARBIA" 
replace NAMES="Thailand" if IN=="KINGDOM OF THAILAND" | IN=="THAILLAND"
replace NAMES="Sierra Leone" if IN=="KONO - SIERRA LEONE" | IN=="SIERRA LOENE"
replace NAMES="South Korea" if IN=="KOREA(SOUTH)" | IN=="OTHER FOREIGN-SOUTH KOREA" 
replace NAMES="North Korea" if IN=="KOREA, DEMOCRATIC REBUCLIC OF KOREA"
replace NAMES="Iraq" if	IN=="KURDISTAN REGION OF IRAQ" | IN=="NORTHERN IRAQ"
replace NAMES="Libya" if IN=="LIBIA" | IN=="LYBIA"
replace NAMES="Lithuania" if IN=="LITHUENIA" | IN=="LITHUNIA"
replace NAMES="Madagascar" if IN=="MADAGASKAR"
replace NAMES="Mongolia" if IN=="MANGOLIA"
replace NAMES="Mauritius" if IN=="MAUTITIUS" | IN=="REPUBLIC OF MAURITIUS"
replace NAMES="Pakistan" if IN=="MIDDLE EAST- PAKISTAN" | ///
	IN=="PAKISTHAN"
replace NAMES="Morocco" if IN=="MORROCCO"
replace NAMES="Kenya" if IN=="MOUNT KENYA REGION" | IN=="WEST KENYA REGION" | ///
	IN=="NAIROBI REGION"
replace NAMES="Myanmar" if IN=="MYAMAR" | IN=="UNION OF MYANMAR"
replace NAMES="Namibia" if IN=="NAMIBIAN"
replace NAMES="Netherlands" if IN=="NETHERLAND" | IN=="NETHERLANDS (EUROPE)"
replace NAMES="New Zealand" if IN=="NEW ZELAND" | IN=="NEWZEALAND"
replace NAMES="Papua New Guinea" if IN=="PAPUA NEW-GUINEA" | IN=="PNG" | IN=="DROUJBA"
replace NAMES="Peru" if IN=="PERU-MINING" | IN=="PERUVIAN FISHMEAL" | ///
	IN=="PERUVIAN WATERS"
replace NAMES="Philippines" if IN=="PHILIPPINE" | IN=="PHLIPPINES" | IN=="PHILIPINES"
replace NAMES="Laos" if IN=="PS LAOS"
replace NAMES="Chad" if IN=="REPUBLIC OF CHAD"
replace NAMES="Ghana" if IN=="REPUBLIC OF GHANA"
replace NAMES="Singapore" if IN=="REPUBLIC OF SINGAPORE" | IN=="SINAGPORE" | ///
	IN=="SINGAPRE" | IN=="SINGAPUR" | IN=="WITHIN SINGAPORE"
replace NAMES="Yemen" if IN=="REPUBLIC OF YEMEN"
replace NAMES="Romania" if IN=="ROMANIAN" | IN=="ROMENIA"
replace NAMES="Fiji" if IN=="KAMBUNA"
replace NAMES="Kosovo" if IN=="KOSOVO."
replace NAMES="Lesotho" if IN=="LESOTHO - RETAIL"
replace NAMES="Italy" if IN=="MESSINA" | IN=="ITALY - MACHINES"
replace NAMES="North Mariana Islands" if IN=="N. MARIANA ISLANDS"
replace NAMES="Falkland Islands" if IN=="NORTH FALKLAND" | IN=="NORTH FALKLAND BASIN"
replace NAMES="Cyprus" if IN=="NORTHERN CYPRUS"
replace NAMES="Northern Ireland" if IN=="NORTHERN IRELAND" | IN=="NOTHERN IRELAND"
replace NAMES="Ireland" if IN=="REPUBLIC OF IRELAND" | IN=="REPUBLIC OF IRELAND - CONTINUING" | ///
	IN=="REPULBLIC OF IRELAND" | IN=="REPULBLIC OF IRLAND" | IN=="ISLAND OF IRELAND"
replace NAMES="United Kingdom" if IN=="SCOTLAND" | IN=="TESCO BANK" | IN=="WALES"
replace NAMES="Syria" if IN=="SIRIA" | IN=="SIRYA"
replace NAMES="Slovakia" if IN=="SLOVAKIA REPUBLIC" | IN=="SLOVAKIAN" | IN=="SOLVAKIA"
replace NAMES="Slovenia" if IN=="SOLVANIA"
replace NAMES="Sri Lanka" if IN=="SRI LANAKA" | IN=="SRI LANAKA" | IN=="SRILANKA" | IN=="SRI LNKA"
replace NAMES="Oman" if IN=="SULTANATE OF OMAN" | IN=="SULTANATE OF OMAN."
replace NAMES="Trinidad" if IN=="TRINDAD" 
replace NAMES="Trinidad and Tobago" if IN=="TRINIDAD & TABAGO" | IN=="TRNIDAD & TOBAGO"
replace NAMES="Tunisia" if IN=="TUNISIE"
replace NAMES="Uganda" if IN=="UGANDA - DISCONTINUED"
replace NAMES="Ukraine" if IN=="UKRAIN"
replace NAMES="Venezuela" if IN=="VENEZEULA" | IN=="VENEZUELAN FOODS"
replace NAMES="Siberia" if IN=="WESTERN SIBERIA"
replace NAMES="Azerbaijan" if IN=="AZERBAYCAN"
replace NAMES="Nicaragua" if IN=="CERRO NEGRO"
replace NAMES="Panama" if IN=="COBRE(PANAMA)"
replace NAMES="Denmark" if IN=="COPENHAGEN"
replace NAMES="Honduras" if IN=="SAN ANDRES MINE"
replace NAMES="Vietnam" if IN=="VEITNAM"
replace NAMES="Zimbabwe" if IN=="ZIMBAWE"

*Group England and Northern Ireland as UK
replace NAMES="United Kingdom" if NAMES=="England" | NAMES=="Northern Ireland" | ///
	NAMES=="england"
********************************************************************************
******                                                                   *******
******   			 ARTICLE: Extraction Payment Disclosures             *******
******  			 AUTHOR: Thomas Rauter                               *******
******               JOURNAL OF ACCOUNTING RESEARCH                      *******
******   			 CODE TYPE: Clean Shaming Channel Data               *******
******   			 LAST UPDATED: August 2020                           *******
******                                                                   *******
********************************************************************************


********************************************************************************
************************* 1. CLEAN MEDIA COVERAGE DATA *************************
********************************************************************************

preserve

// Save EPD data as tempfile
use "$raw_data/epd_masterfile.dta", clear
drop if effective_since == .
tempfile master_file
save `master_file'

// Import media coverage data
use "$raw_data/media_coverage.dta", clear
keep if language == "English"
collapse (sum) number_media_articles, by(gvkey year)

// Merge EPD data
merge m:1 gvkey using `master_file'
drop if _merge == 1
replace number_media_articles = 0 if _merge == 2
drop _merge

// Compute average media coverage prior to EPD
gen effective_since_year = year(effective_since)
gen number_media_articles_before = number_media_articles if year < effective_since_year
drop if year >= effective_since_year | effective_since_year == .
collapse (mean) number_media_articles_before, by(gvkey)
tempfile media_coverage

// Save media coverage data
save `media_coverage'
restore

// Merge media coverage data with EITI payment data
merge m:1 gvkey using `media_coverage', keep(1 3) nogen

// Generate media coverage indicators
local threshold_media_coverage 75
egen threshold_n_m_art_bef = pctile(number_media_articles_before), p(`threshold_media_coverage')

// Define High media coverage
gen high_media_cov_d = .
replace high_media_cov_d = 1 if number_media_articles_before > threshold_n_m_art_bef & number_media_articles_before != .
replace high_media_cov_d = 0 if number_media_articles_before <= threshold_n_m_art_bef & number_media_articles_before != .
replace high_media_cov_d = . if number_media_articles_before == .

// Define Low media coverage
gen low_media_cov_d = .
replace low_media_cov_d = 1 if number_media_articles_before <= threshold_n_m_art_bef & number_media_articles_before != .
replace low_media_cov_d = 0 if number_media_articles_before > threshold_n_m_art_bef & number_media_articles_before != .
replace low_media_cov_d = . if number_media_articles_before == .


********************************************************************************
************************** 2. CLEAN NGO SHAMING DATA ***************************
********************************************************************************

preserve

// Save EPD data as tempfile
use "$raw_data/epd_masterfile.dta", clear
drop if effective_since == .
tempfile master_file
save `master_file'

// Import activist shaming data
if "$analysis_type"=="investment" {
use "$raw_data/asc_investments.dta", clear
}
else{
use "$raw_data/asc_payments.dta", clear
}

keep if ngo_campaign == 1

// Merge EPD data
merge m:1 gvkey using `master_file', keep(2 3)
drop if _merge == 1
gen effective_since_year = year(effective_since)

// Identify NGO campaigns prior to EPD 
gen campaign_before_effective = 0
replace campaign_before_effective = 1 if year < effective_since_year
replace campaign_before_effective = 0 if _merge == 2
collapse (sum) campaign_before_effective, by(gvkey)
	
// Generate NGO shaming indicators

// Target of NGO shaming campaign
gen campaign_before_effective_d = 0
replace campaign_before_effective_d = 1 if campaign_before_effective > 0 & campaign_before_effective != .
replace campaign_before_effective_d =. if campaign_before_effective ==.
label var campaign_before_effective_d "1=firm target of ngo shaming campaign before epd effective; 0=otherwise"

// Never target of NGO shaming campaign
gen no_campaign_before_effective_d =.
replace no_campaign_before_effective_d = 1 if campaign_before_effective_d == 0
replace no_campaign_before_effective_d = 0 if campaign_before_effective_d == 1
label var no_campaign_before_effective_d "1=firm no target of ngo shaming campaign before epd effective; 0=otherwise"

// Keep only relevant variables
keep gvkey campaign_before_effective_d no_campaign_before_effective_d
tempfile activist_shaming_investments
save `activist_shaming_investments'
restore

// Merge NGO shaming data
merge m:1 gvkey using `activist_shaming_investments', keep(1 3) nogen
********************************************************************************
**********                                                            **********
**********      ARTICLE: Extraction Payment Disclosures               **********
**********      AUTHOR: Thomas Rauter                                 **********
**********      JOURNAL OF ACCOUNTING RESEARCH                        **********
**********      CODE TYPE: Run all Do-Files  		                  **********
**********      LAST UPDATED: August 2020                             **********
**********                                                            **********
**********                                                            **********
**********      README / DESCRIPTION:                                 **********
**********      This STATA code runs all do-files that convert        **********
**********      the raw data into my final regression datasets.       **********
**********      The do-files use the raw data listed in Section 2     **********
**********      of the datasheet as input and produce the final       **********
**********	    regression datasets as output.                        **********
**********                                                            **********
********************************************************************************


// Set main directory => copy path into ""
global main_dir ""

global raw_data "$main_dir/00_Raw_Data"
global clean_data "$main_dir/01_Clean_Data"
global final_data "$main_dir/02_Final_data"


********************************************************************************
*****************************  1) PAYMENT ANALYSIS  ****************************
********************************************************************************

	do "$main_dir/1_data_payment.do"
	

********************************************************************************
**************************  2) SEGMENT CAPEX ANALYSIS  *************************
********************************************************************************
	
	do "$main_dir/2_data_segment_capex.do"
	
	
********************************************************************************
**************************  3) PARENT CAPEX ANALYSIS  **************************
********************************************************************************
	
	do "$main_dir/3_data_parent_capex.do"


********************************************************************************
********************** 4) AUCTION PARTICIPATION ANALYSIS ***********************
********************************************************************************

	do "$main_dir/4_data_hist_bidding.do"

	
********************************************************************************
***************************  5) LICENSING ANALYSIS  ****************************
********************************************************************************

	do "$main_dir/5_data_licensing.do"
	

********************************************************************************
*************************  6) PRODUCTIVITY ANALYSIS  ***************************
********************************************************************************

	do "$main_dir/6_data_productivity.do"

********************************************************************************
******                                                                   *******
******   			 ARTICLE: Extraction Payment Disclosures             *******
******  			 AUTHOR: Thomas Rauter                               *******
******               JOURNAL OF ACCOUNTING RESEARCH                      *******
******   			 CODE TYPE: Data Preparation for Payment Analysis    *******
******   			 LAST UPDATED: August 2020                           *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "payment"


********************************************************************************
********** 1. IMPORT PARENT INFORMATION FOR FIRMS IN EITI REPORT DATA **********
********************************************************************************

foreach s in all parent_gvkeys all_update {
	import excel "$raw_data/eiti_data_enrichment.xls", firstrow sheet(`s')
	save "$clean_data/eiti_data_enrich_`s'.dta", replace
clear
}

********************************************************************************
**************************  2. CLEAN COMPUSTAT DATA  ***************************
********************************************************************************

// Compustat North America data
use "$raw_data/compustat_north_america_fundamentals.dta", clear
keep gvkey datadate fyear curcd fyr at capx dlc dltt oibdp sale naics
save "$clean_data/compustat_north_america_fundamentals_clean.dta", replace 

// Compustat Global data
use "$raw_data/compustat_global_fundamentals.dta", clear
keep gvkey datadate fyear curcd fyr at capx dlc dltt oibdp sale naics
save "$clean_data/compustat_global_fundamentals_clean.dta", replace

// Append Compustat North America and Compustat Global data
use "$clean_data/compustat_north_america_fundamentals_clean.dta", clear
append using "$clean_data/compustat_global_fundamentals_clean.dta"

// Drop duplicates
duplicates drop gvkey fyear, force

// Merge exchange rates
rename curcd curcdq
merge m:1 curcdq datadate using "$raw_data/currencies.dta", keepusing(exratm) keep(1 3) nogen
rename at tot_assets

// Convert all currencies to GBP
foreach var of varlist tot_assets capx dlc dltt oibdp sale {
   replace `var' = `var' / exratm
}

// Generate firm fundamentals
gsort gvkey fyear
by gvkey: gen tot_assets_lag1 = tot_assets[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
gen ln_tot_assets = ln(tot_assets)
gen ln_tot_assets_lag1 = ln(tot_assets_lag1)
gen leverage = (dlc + dltt) / tot_assets
gen roa = oibdp / tot_assets_lag1
gen capex_frac = capx / tot_assets_lag1

gsort gvkey fyear
foreach var of varlist leverage roa {
   by gvkey: gen `var'_lag1 = `var'[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
}

// Trim firm fundamentals
foreach var of varlist roa_lag1  {
   winsor2 `var', cuts(1 99) trim
}
foreach var of varlist leverage_lag1 capex_frac {
   winsor2 `var', cuts(0 99) trim
}

// Generate lagged capex variables
gsort gvkey fyear
by gvkey: gen capex_frac_tr_lag1 = capex_frac_tr[_n-1] if ((fyear[_n] == fyear[_n-1] + 1))
by gvkey: gen capex_frac_tr_lag2 = capex_frac_tr[_n-2] if ((fyear[_n] == fyear[_n-2] + 2))
by gvkey: gen capex_frac_tr_lag3 = capex_frac_tr[_n-3] if ((fyear[_n] == fyear[_n-3] + 3))
by gvkey: gen capex_frac_tr_lag4 = capex_frac_tr[_n-4] if ((fyear[_n] == fyear[_n-4] + 4))
by gvkey: gen capex_frac_tr_lag5 = capex_frac_tr[_n-5] if ((fyear[_n] == fyear[_n-5] + 5))

// Generate year variable for merging with EITI data
gen year = fyear
drop if year ==.

// Drop variables without gvkey and drop duplicates
drop if gvkey == ""
duplicates drop gvkey year, force

// Convert year variable to string
gen yr = year
tostring yr, replace
drop year
gsort gvkey yr

// Save firm fundamentals data
save "$clean_data/compustat_fundamentals.dta", replace
clear

********************************************************************************
******** 3. CLEAN CORRUPTION PERCEPTIONS DATA FOR CROSS-SECTIONAL TESTS ********
********************************************************************************

// Import and clean Corruption Perceptions Index (CPI) for 2013
import excel "$raw_data/CPI_2005_2018.xlsx", firstrow sheet(CPI_2013) clear
save "$clean_data/2013_CPI.dta", replace
use "$clean_data/2013_CPI.dta", clear

drop if year >=.
replace country = "Democratic Republic of Congo" if (country == "Congo, Democratic Republic")
replace country = "Democratic Republic of Congo" if (country == "Congo. Democratic Republic")
gsort country year

gen cpi_13 = 0
replace cpi_13 = cpi if (year == 2013)

// Classify countries as highly- or less corrupt based on 2013 CPI
gen corrupt_host_cty = 0
replace corrupt_host_cty = 1 if (cpi_13 <= 28) // CPI value of 28 = 25th percentile

gen non_corrupt_host_cty = 0
replace non_corrupt_host_cty = 1 if (cpi_13 > 28)

lab var corrupt_host_cty "Corrupt Country"
lab var non_corrupt_host_cty "Non-Corrupt Country"

// Save CPI data
save "$clean_data/CPI_2013_new.dta", replace
clear

********************************************************************************
******************* 4. IMPORT PAYMENT DATA FROM EITI REPORTS ******************* 
********************************************************************************

import excel "$raw_data/eiti_country_company_payments_FINAL.xlsx", firstrow clear

// Rename variables
rename paymentgovernmentreconciled pmt_gov_reconciled
rename governmentinitial pmt_gov_initial
rename companygovernment pmt_gap_com_gov
rename commodity commodity_reported

lab var country "Country"
lab var year "Year"
lab var currency "Currency"
lab var unit "Unit"
lab var company "Company"
lab var identification_number "ID_Number"
lab var commodity_reported "Commodity Reported"
lab var pmt_gov_reconciled "Payment Government Reconciled"
lab var pmt_gov_initial "Payment Government Initial"
lab var pmt_gap_com_gov "Payment Reported by Company - Payment Received by Government"

// Drop missing payment observations
drop if pmt_gov_initial >=.
gsort country year company

// Merge parent company information
foreach file in all all_update {
if "`file'"=="all"{
merge m:1 company country ///
using "$clean_data/eiti_data_enrich_`file'.dta"
drop _merge
}
else{
merge m:1 company country ///
using "$clean_data/eiti_data_enrich_`file'.dta", update
drop _merge
}
}

// Merge Compustat data
merge m:1 parent parent_country ///
using "$clean_data/eiti_data_enrich_parent_gvkeys.dta", update keep(1 3 4 5) nogen

gen yr = year
forvalues v = 2009/2015{
local next = `v' + 1
display `next'
replace yr = "`v'" if yr == "`v'-`next'"
}

merge m:1 gvkey yr using "$clean_data/compustat_fundamentals.dta", keep(1 3) nogen

********************************************************************************
********** 5. CONVERT PAYMENT VARIABLES FROM LOCAL CURRENCY INTO GBP ***********
********************************************************************************
gsort country year

preserve
import excel "$raw_data/fx_rates_payments.xlsx", firstrow clear
gen fx_eop = (period_end_gbp_fx_bid + period_end_gbp_fx_ask) / 2
save "$clean_data/fx_payments.dta", replace
restore

merge m:1 country currency year unit ///
using "$clean_data/fx_payments.dta", keepusing(fx_eop) keep(1 3) nogen

lab var fx_eop "FX End of Period"

foreach var of varlist pmt_gov_initial pmt_gap_com_gov resolved unresolved {
   gen `var'_gbp = `var' * unit * fx_eop
}

forvalues v = 2009/2015{
local next = `v' + 1
replace year = "`v'.5" if year == "`v'-`next'"
}
destring year, replace

********************************************************************************
**************  6. MERGE EPD DATA AND CROSS-SECTIONAL VARIABLES ****************
********************************************************************************

// Merge EPD masterfile 
merge m:1 gvkey using "$raw_data/epd_masterfile.dta", keep(1 3) nogen

// Merge CPI data
kountry country, from(other) stuck
gen country_intermed = _ISO3N_
kountry country_intermed, from(iso3n) to(iso3c)
rename _ISO3C_ segment_country
drop _ISO3N_

kountry parent_country, from(other) stuck
gen parent_country_intermed = _ISO3N_
kountry parent_country_intermed, from(iso3n) to(iso3c)
rename _ISO3C_ loc

merge m:1 country using "$clean_data/CPI_2013_new.dta", keep(1 3) nogen

egen corrupt_new = max(corrupt_host_cty), by(country)
egen non_corrupt_new = max(non_corrupt_host_cty), by(country)

// Merge shaming channel data
do "$code/clean_shaming_data.do"


********************************************************************************
**********************  7. CLEAN SUBSIDIARY NAMES  *****************************
********************************************************************************
do "$code/clean_company_name.do"


********************************************************************************
************************  8. PREPARE REGRESSION SAMPLE *************************
********************************************************************************

// Rename variables
rename pmt_gov_initial_gbp pmt_gov
rename pmt_gap_com_gov_gbp pmt_gap
rename resolved_gbp res
gen pmt_company = pmt_gap + pmt_gov

// Drop missing year observations
drop if year >=.

// Define EPD treatment indicators
gen EPD_effective_year_masterfile = year(effective_since)
gen EPD_implementation_wave = 0
replace EPD_implementation_wave = 1 if (EPD_effective_year_masterfile == 2014)
replace EPD_implementation_wave = 2 if (EPD_effective_year_masterfile == 2015)
replace EPD_implementation_wave = 3 if (EPD_effective_year_masterfile == 2016)
 
// Generate dependent variables
gen pmt_tot_assets = pmt_company / (tot_assets_lag1 * 1000000)
replace pmt_tot_assets =. if (pmt_tot_assets < 0)

// Trim dependent variables
winsor2 pmt_tot_assets, cuts(1 99) trim

// Multiply dependent variables by 100
gen pmt_tot_assets_tr_100 = pmt_tot_assets_tr * 100
gen pmt_tot_assets_100 = pmt_tot_assets * 100

// Generate EPD indicators
gen EPD = 0
replace EPD = 1 if ((EPD_implementation_wave == 1 & year > 2013 & year <.) | (EPD_implementation_wave == 2 & year > 2014 & year <.) | (EPD_implementation_wave == 3 & year > 2015 & year <.))

// Generate event-time indicators
gen EPD_0plus = EPD

gen EPD_minus1 = 0
replace EPD_minus1 = 1 if ((EPD_implementation_wave == 1 & (year == 2013 | year == 2012.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2014 | year == 2013.5) & year <.)  | (EPD_implementation_wave == 3 & (year == 2015 | year == 2014.5) & year <.))

gen EPD_minus2 = 0
replace EPD_minus2 = 1 if ((EPD_implementation_wave == 1 & (year == 2012 | year == 2011.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2013 | year == 2012.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2014 | year == 2013.5) & year <.))

gen EPD_minus3 = 0
replace EPD_minus3 = 1 if ((EPD_implementation_wave == 1 & (year == 2011 | year == 2010.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2012 | year == 2011.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2013 | year == 2012.5) & year <.))

gen EPD_minus4 = 0
replace EPD_minus4 = 1 if ((EPD_implementation_wave == 1 & (year == 2010 | year == 2009.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2011 | year == 2010.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2012 | year == 2011.5) & year <.))

gen EPD_minus5 = 0
replace EPD_minus5 = 1 if ((EPD_implementation_wave == 1 & (year == 2009 | year == 2008.5) & year <.) | (EPD_implementation_wave == 2 & (year == 2010 | year == 2009.5) & year <.) | (EPD_implementation_wave == 3 & (year == 2011 | year == 2010.5) & year <.))

gen EPD_3minus = 0
replace EPD_3minus = 1 if (EPD_minus3 == 1  | EPD_minus4 == 1  | EPD_minus5 == 1)

// High vs. low corruption in host country
gen EPD_corrupt_host_cty = EPD * corrupt_host_cty
gen EPD_non_corrupt_host_cty = EPD * non_corrupt_host_cty

// Foreign vs. domestic host country
gen foreign_host_cty = 0
replace foreign_host_cty = 1 if (country != parent_country)

gen domestic_host_cty = 0
replace domestic_host_cty = 1 if (country == parent_country)

gen EPD_foreign_host_cty = EPD * foreign_host_cty
gen EPD_domestic_host_cty = EPD * domestic_host_cty

// Company subject to high vs. low media coverage
replace high_media_cov_d = 0 if high_media_cov_d ==.
replace low_media_cov_d = 0 if low_media_cov_d ==.
gen EPD_high_media_cov = EPD * high_media_cov_d
gen EPD_low_media_cov = EPD * low_media_cov_d

// Company target vs. no target of NGO shaming campaign
replace campaign_before_effective_d = 0 if campaign_before_effective_d ==.
replace no_campaign_before_effective_d = 0 if no_campaign_before_effective_d ==.

gen EPD_activist_campaign = EPD * campaign_before_effective_d
gen EPD_no_activist_campaign = EPD * no_campaign_before_effective_d

// Identify micro firms with less than USD 10 mn in total assets
gen small = 0
replace small = 1 if (tot_assets < 6.2) // USD 10 mn * average USD/GBP FX rate; results also hold when including micro firms

// Keep only relevant variables
rename effective_since EPD_effective_since

keep pmt_tot_assets_100 pmt_tot_assets_tr_100 EPD_implementation_wave EPD EPD_effective_since ln_tot_assets_lag1 tot_assets_lag1 tot_assets roa_lag1_tr leverage_lag1_tr ///
EPD_corrupt_host_cty EPD_non_corrupt_host_cty naics yr year country parent_country company_cleaned parent ///
corrupt_host_cty non_corrupt_host_cty EPD_activist_campaign EPD_no_activist_campaign EPD_high_media_cov EPD_low_media_cov gvkey ///
part_of_annual_report EPD_foreign_host_cty EPD_domestic_host_cty capex_frac_tr capex_frac_tr_lag1 capex_frac_tr_lag2 capex_frac_tr_lag3 capex_frac_tr_lag4 capex_frac_tr_lag5 ///
EPD_0plus EPD_minus1 EPD_minus2 EPD_minus3 EPD_minus4 EPD_minus5 EPD_3minus small company_standardized fyear pmt_company oibdp sale

// Label variables
lab var capex_frac_tr "Capex_t/Total Assets_t-1 - Trimmed"
lab var capex_frac_tr_lag1 "Capex_t-1/Total Assets_t-2 - Trimmed"
lab var capex_frac_tr_lag2 "Capex_t-2/Total Assets_t-3 - Trimmed"
lab var capex_frac_tr_lag3 "Capex_t-3/Total Assets_t-4 - Trimmed"
lab var part_of_annual_report "Corrupt Host Country - CPI 2013 larger than 25"
lab var pmt_tot_assets_100 "Government Payments/Tot. Assets x 100"
lab var pmt_tot_assets_tr_100 "Government Payments/Tot. Assets x 100 - Trimmed"
lab var EPD_effective_since "EPD Effective Since - Date"
lab var country "Host Country"
lab var parent_country "Parent Country"
lab var company_cleaned "Clean Company Name"
lab var parent "Parent Company"
lab var year "Year(s) of EITI report coverage"
lab var yr "Year"
lab var naics "North American Industry Classification (NAICS) code"
lab var gvkey "Compustat Global Company Key (GVKEY)"
lab var EPD_implementation_wave "EPD Waves of Implementation"

// Define sample
drop if year < 2010
drop if small == 1

// Generate dependent variable
gen ln_payment = ln(1 + pmt_tot_assets_100)

// Generate fixed effects
gen naics3 = substr(naics,1,3)
encode naics3, gen(naics_3no)
egen naics3_year = group(naics_3no year)
rename naics3_year resource_year_FE

egen firm_subsidiary_FE = group(company_cleaned)
egen host_country_year_FE = group(country year)

egen treated = max(EPD), by(parent)
egen treated_year_FE = group(treated year)

// Label regression variables
label var ln_payment "Ln(1+Extractive Payment/Total Assets\textsubscript{t-1} $\times$ 100)"
label var EPD "EPD"
label var EPD_corrupt_host_cty "EPD $\times$ Highly Corrupt Host Country"
label var EPD_non_corrupt_host_cty "EPD $\times$ Less Corrupt Host Country"
label var EPD_foreign_host_cty "EPD $\times$ Foreign Host Country"
label var EPD_domestic_host_cty "EPD $\times$ Domestic Host Country"
label var ln_tot_assets_lag1 "\emph{Control Variables:} \vspace{0.1cm} \\ Ln(Total Assets\textsubscript{t-1})"
label var roa_lag1_tr "Return on Assets\textsubscript{t-1}"
label var leverage_lag1_tr "Leverage\textsubscript{t-1}"
label var corrupt_host_cty "Highly Corrupt Host Country"
label var non_corrupt_host_cty "Less Corrupt Host Country"
label var EPD_activist_campaign "EPD $\times$ Target of NGO Shaming Campaign"
label var EPD_no_activist_campaign "EPD $\times$ Never Target of NGO Shaming Campaign"
label var EPD_high_media_cov "EPD $\times$ High Media Coverage"
label var EPD_low_media_cov "EPD $\times$ Low Media Coverage"


// Save cleaned and merged payment dataset
save "$final_data/payment_analysis_clean_FINAL.dta", replace

********************************************************************************
******                                                                   *******
******   	 ARTICLE: Extraction Payment Disclosures                     *******
******  	 AUTHOR: Thomas Rauter                                       *******
******       JOURNAL OF ACCOUNTING RESEARCH                              *******
******       CODE TYPE: Data Preparation for Segment Capex Analysis      *******
******   	 LAST UPDATED: August 2020                                   *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "investment"


********************************************************************************
*********************  1. EXTRACT GVKEYs AND NAICS CODES  **********************
********************************************************************************

// Compustat North America
import delimited "$raw_data/compustat_north_america_naics.txt", clear stringcols(_all)
gen dummy = 1
collapse (sum) dummy, by(gvkey cusip naics)
drop dummy
drop if cusip == ""
isid gvkey cusip 
save "$clean_data/compustat_north_america_naics.dta", replace 

// Compustat Global
import delimited "$raw_data/compustat_global_naics.txt", clear stringcols(_all)
gen dummy = 1
collapse (sum) dummy, by(gvkey sedol isin naics)
drop dummy
replace isin = "missing" if isin == "" 
replace sedol = "missing" if sedol == "" 

// Check that (i) gvkey-sedol and (ii) gvkey-isin uniquely identify observations
isid gvkey sedol
isid gvkey isin 

save "$clean_data/compustat_global_naics.dta", replace


********************************************************************************
**********************  2. CLEAN WORLDSCOPE SEGMENT DATA  **********************
********************************************************************************

import delimited "$raw_data/segment_data_worldscope_2017.csv", clear

replace freq="1" if freq=="A"
replace freq="2" if freq=="B"
destring freq, replace
label define freq 1 "Annual" 2 "Restated-Annual"
label values freq freq

// Firm identifying information
rename item6008 isin
label variable isin "ISIN"
rename item6004 cusip
label variable cusip "CUSIP"
rename item6006 sedol
label variable sedol "SEDOL"
rename item5601 ticker 
label variable ticker "TICKER"
rename item6105 ws_id 
label variable ws_id "Worldscope Identifier"
rename item6001 name 
label variable name "Company Name"
rename item6026 nation 
label variable nation "Country Out; country where the company is headquartered"
rename item6027 nation_code
label variable nation_code "Country Out code"
rename item6028 region
label variable region "Region of the world where the company is headquartered"
rename year_ year
label variable year "Year"
rename item5352 fyearend
label variable fyearend "Fiscal Year End"

// Identify geographic segments (each firm has up to 10 segments)
local segment 1 2 3 4 5 6 7 8 9 10
foreach segment in `segment' {
	local item=`segment'-1
	di `segment'
	di `item'
	rename item196`item'0 segment_description`segment'
	label var segment_description`segment' "Segment Description"
	rename item196`item'3 segment_assets`segment'
	label var segment_assets`segment' "Segment Assets"
	rename item196`item'4 segment_capex`segment'
	label var segment_capex`segment' "Segment Capital Expenditure"
	}
drop item*

keep if year >= 2000

// Keep unique ws_id-year observations (segments are still separate variables in wide format)
sort ws_id year freq
by ws_id year: generate duplicate=cond(_N==1, 0, _n)

keep if duplicate==0 | (duplicate==2 & freq==2)
drop duplicate

isid ws_id year
order nation nation_code, after(ws_id)

// Generate lagged parent assets and merge to segment dataset
preserve
	use "$raw_data/firm_fundamentals_worldscope_parent.dta", clear
	rename total_assets tot_assets_USD // Total Assets in USD (item 07230)
	keep ws_id year tot_assets_USD
	rename tot_assets_USD tot_assets_USD_lag1
	replace year = year + 1
	tempfile tot_assets_USD_lag1
	save `tot_assets_USD_lag1'
restore
merge 1:1 ws_id year using `tot_assets_USD_lag1', keep(1 3) nogen

// Reshape dataset to long format
reshape long segment_description segment_capex segment_oic segment_assets, i(ws_id year) j(segment)
duplicates drop

// Merge parent fundamentals and drop observations without segment data
merge m:1 ws_id year using "$raw_data/firm_fundamentals_worldscope_parent.dta", keepusing(total_assets roa total_assets_local total_liabilities_local) keep(1 3) nogen
rename total_assets tot_assets_USD


********************************************************************************
******************  3. CLEAN AND STANDARDIZE COUNTRY NAMES  ********************
********************************************************************************

// Cleaning of country-in names
replace segment_description=upper(segment_description)
replace segment_description=subinstr(segment_description, "(COUNTRY)", "", .)
do "$code/clean_country_name.do"

// Standardize country names
rename MARKER CHECK1
kountry NAMES, from(other) marker
drop NAMES
rename NAMES_STD Country_In
label variable Country_In "Capex Destination Country"
rename nation Country_Out
drop if MARKER==0
drop MARKER

// Generate ISO3 codes and country names
kountry Country_In, from(other) stuck marker
drop if Country_In=="European Union"
drop MARKER

rename _ISO3N_ Country_In_iso3N
kountry Country_In_iso3N, from(iso3n) to(iso3c) marker
drop NAMES_STD MARKER
rename _ISO3C_ Country_In_iso3C

replace Country_Out="British Virgin Islands" if Country_Out=="VIRGIN ISLANDS(BRIT)" | ///
	    Country_Out=="Virgin Islands" | Country_Out=="VIRGIN ISLANDS (BRIT)"
		
kountry Country_Out, from(other) marker
drop Country_Out MARKER
rename NAMES_STD Country_Out 

kountry Country_Out, from(other) stuck marker
drop MARKER

rename _ISO3N_ Country_Out_iso3N
kountry Country_Out_iso3N, from(iso3n) to(iso3c) marker
drop NAMES_STD MARKER
rename _ISO3C_ Country_Out_iso3C

replace Country_Out_iso3C="GGY" if Country_Out=="guernsey"
replace Country_Out_iso3C="IMN" if Country_Out=="isle of man"
replace Country_Out_iso3C="JEY" if Country_Out=="jersey"
drop if Country_In_iso3C=="" | Country_Out_iso3C==""


********************************************************************************
******************  4. CONVERT SEGMENT CAPEX INTO USD AMOUNTS  *****************
********************************************************************************

// Merge exchange rate dataset
replace nation_code = 840 if Country_Out == "United States" & nation_code == . // if nation_code is missing but country_out is United States -> replace with US nation_code
label define nation_codes 012 "Algeria" 422 "Lebanon" 025 "Argentina" 428 "Latvia" 036 "Australia" 440 "Lithuania" ///
040 "Austria" 442 "Luxembourg" 044 "Bahamas" 454 "Malawi" 048 "Bahrain" 458 "Malaysia" ///
052 "Barbados" 470 "Malta" 056 "Belgium" 480 "Mauritius" 060 "Bermuda" 484 "Mexico" ///
068 "Bolivia" 496 " Mongolia" 070 "Bosnia and Herzegovina" 499 "Montenegro" ///
072 "Botswana" 504 "Morocco" 076 " Brazil" 516 "Namibia" 092 "British Virgin Islands" ///
528 "Netherlands" 100 "Bulgaria" 554 "New Zealand" 124 "Canada" 566 "Nigeria" ///
136 "Cayman Islands" 578 "Norway" 152 "Chile" 582 "Oman" 156 "China" 586 "Pakistan" ///
175 "Colombia" 591 "Panama" 178 "Costa Rica" 597 "Peru" 182 "Cote d’Ivoire" 593 "Paraguay" ///
191 "Croatia" 608 " Philippines" 196 "Cyprus" 617 "Poland" 203 "Czech Republic" 620 "Portugal" ///
208 "Denmark" 634 "Qatar" 214 "Dominican Republic" 642 "Romania" 218 "Ecuador" 643 "Russia" ///
220 "Egypt" 682 "Saudi Arabia" 222 "El Salvador" 688 "Serbia" 233 "Estonia" 702 "Singapore" ///
234 "Faroe Islands" 703 "Slovakia" 242 "Fiji" 704 "Vietnam" 246 "Finland" 705 "Slovenia" ///
250 "France" 710 "South Africa" 268 "Georgia" 724 "Spain" 275 "Palestine" 730 "Sri Lanka" ///
280 "Germany" 736 "Sudan" 300 "Greece" 748 "Swaziland" 320 "Guatemala" 752 "Sweden" ///
328 "Guyana" 756 "Switzerland" 340 "Honduras" 760 "Taiwan" 344 "Hong Kong" 764 "Thailand" ///
350 "Hungary" 780 "Trinidad and Tobago" 352 "Iceland" 784 "United Arab Emirates" ///
356 "India" 788 "Tunisia" 366 "Indonesia" 796 "Turkey" 372 "Ireland" 800 "Uganda" ///
376 "Israel" 804 "Ukraine" 380 "Italy" 807 "Macedonia" 388 "Jamaica" 826 "United Kingdom" ///
392 "Japan" 833 "Isle of Man" 398 "Kazakhstan" 834 "Tanzania" 400 "Jordan" 840 "United States" ///
404 "Kenya" 862 "Venezuela" 410 "South Korea" 894 "Zambia" 414 "Kuwait" 897 "Zimbabwe" ///
831 "South Africa" 50 "Bangladesh" 116 "Cambodia" 120 "Cameroon" 288 "Ghana" 369 "Iraq" ///
646 "Rwanda" 686 "Senegal" 860 "Uzbekistan"

label values nation_code nation_codes
decode nation_code, generate(currency_country)
replace currency_country = strtrim(currency_country)

// Generate ISO3 codes for currency country
kountry currency_country, from(other) stuck marker
drop MARKER
rename _ISO3N_ currency_country_iso3N
kountry currency_country_iso3N, from(iso3n) to(iso3c) marker
drop MARKER NAMES currency_country_iso3N
rename _ISO3C_ currency_country_iso3C
replace currency_country_iso3C = "CIV" if nation_code == 182

// Merge World Bank exchange rate data
merge m:1 currency_country_iso3C year using "$raw_data/exchange_rates_2017" 
drop if _m==2
drop _m

// Transform values into USD millions
gen segment_capex_USD = segment_capex / (exchangerate * 1000000)
gen segment_assets_USD = segment_assets / (exchangerate * 1000000)

// Order variables
order Country_Out Country_Out_iso3C, before(Country_In)
order year fyearend, before(segment_capex_USD)


********************************************************************************
*************************  5. CLEAN AND MERGE CPI DATA  ************************
********************************************************************************

// Construct CPI panel from 1998 to 2017
preserve

* Import 1998 to 2015 data
import excel "$raw_data/cpi_1998_2015.xlsx", first clear
destring  cpi1998 cpi1999 cpi2000 cpi2001 cpi2002 cpi2003 cpi2004 cpi2005 cpi2006 cpi2007 ///
          cpi2008 cpi2009 cpi2010 cpi2011 cpi2012 cpi2013 cpi2014 cpi2015, force replace
tempfile 1998_2015
save `1998_2015'

* Import 2016 data
import excel "$raw_data/cpi_2016.xlsx", first clear sheet(CPI2016_FINAL_16Jan)
rename Country country
rename CPI2016 cpi2016
keep country cpi2016
tempfile 2016
save `2016'

* Import 2017 data
import excel "$raw_data/cpi_2017.xls", first clear sheet(CPI 2017) cellrange(A3)
rename Country country
rename CPIScore2017 cpi2017
rename ISO3 iso3
drop if country == "" | country == "GLOBAL AVARAGE"
keep country cpi2017
tempfile 2017
save `2017'

* Merge datasets
use `1998_2015', clear
merge m:1 country using `2016'
drop _merge
gsort country

merge m:1 country using `2017'
drop _merge
gsort country

* Reshape to long format
gen id = _n
reshape long cpi, i(id) j(year 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 /// 
2008 2009 2010 2011 2012 2013 2014 2015 2016 2017)

* Generate ISO3 country codes
kountry country, from(other) stuck
replace _ISO3N_ = 70 if country == "Bosnia and Herzgegovina"
replace _ISO3N_ = 180 if country == "Congo Democratic Republic"
replace _ISO3N_ = 178 if country == "Congo Republic"
replace _ISO3N_ = 178 if country == "Congo-Brazzaville"
replace _ISO3N_ = 180 if country == "Congo. Democratic Republic"
replace _ISO3N_ = 178 if country == "Congo. Republic"
replace _ISO3N_ = 384 if country == "Cote d´Ivoire"
replace _ISO3N_ = 203 if country == "Czech Republik"
replace _ISO3N_ = 384 if country == "Côte d´Ivoire"
replace _ISO3N_ = 384 if country == "Côte d’Ivoire"
replace _ISO3N_ = 384 if country == "Côte-d'Ivoire"
replace _ISO3N_ = 384 if country == "Côte D'Ivoire"
replace _ISO3N_ = 132 if country == "Cabo Verde"
replace _ISO3N_ = 807 if country == "FYR Macedonia"
replace _ISO3N_ = 414 if country == "Kuweit"
replace _ISO3N_ = 807 if country == "Macedonia (Former Yugoslav Republic of)"
replace _ISO3N_ = 498 if country == "Moldovaa"
replace _ISO3N_ = 275 if country == "Palestinian Authority "
replace _ISO3N_ = 178 if country == "Republic of Congo "
replace _ISO3N_ = 762 if country == "Taijikistan "
replace _ISO3N_ = 807 if country == "The FYR of Macedonia"
replace _ISO3N_ = 275 if country == "Palestinian Authority"
replace _ISO3N_ = 178 if country == "Republic of Congo"
replace _ISO3N_ = 762 if country == "Taijikistan"
replace _ISO3N_ = 688 if country == "Serbia"

gen country_intermed = _ISO3N_
kountry country_intermed, from(iso3n) to(iso3c)

* Fix ISO3 code errors
replace _ISO3C_="SRB" if country=="Serbia"
replace _ISO3C_="SCG" if country=="Serbia and Montenegro" | country=="Serbia & Montenegro"
replace _ISO3C_="KSV" if country=="Kosovo"

* Drop CPI duplicates
replace cpi = 0 if (cpi ==.)
collapse (max) cpi, by(_ISO3C_ year)

rename _ISO3C_ iso3
drop if iso3 == ""
replace cpi =. if (cpi == 0)
duplicates report iso3 year

* Rescale data before 2012 (1998-2011: 0-10; 2012-2016: 0-100)
replace cpi = cpi * 10 if (year < 2012)
rename iso3 iso3_code
label variable cpi "CPI - Transparency International"

* Ensure data is unique at country-year level
isid iso3_code year

* Save CPI dataset
save "$clean_data/cpi_1998_2017.dta", replace
restore

preserve
	use "$clean_data/cpi_1998_2017.dta", clear
	drop if cpi==.
	rename iso3_code Country_In_iso3C
	rename cpi cpi_in
	save "$clean_data/cpi_in.dta", replace
    rename Country_In_iso3C Country_Out_iso3C
	rename cpi_in cpi_out
	save "$clean_data/cpi_out.dta", replace
restore

* Merge CPI of Country_In 
merge m:1 Country_In_iso3C year using "$clean_data/cpi_in.dta", keep(1 3) nogen
order cpi_in, after(Country_In_iso3C)

* Merge CPI of Country_Out
merge m:1 Country_Out_iso3C year using "$clean_data/cpi_out.dta", keep(1 3) nogen

// Save cleaned Worldscope segment dataset
save "$clean_data/clean_worldscope_segment_panel.dta", replace


********************************************************************************
**********************  6. MERGE GVKEYs AND NAICS CODES  ***********************
********************************************************************************

use "$clean_data/clean_worldscope_segment_panel.dta", clear

// Merge North American gvkeys and naics codes based on CUSIP
merge m:1 cusip using "$raw_data/gvkey_to_naics_north_america.dta", keep(1 3) nogen
rename gvkey NAgvkey
rename naics NAnaics

// Merge Global gvkeys and naics codes based on SEDOL
preserve
use "$raw_data/gvkey_to_naics_global.dta", clear
keep gvkey sedol naics
duplicates drop sedol, force
save "$raw_data/gvkey_to_naics_global_sedol.dta", replace
restore

merge m:1 sedol using "$raw_data/gvkey_to_naics_global_sedol.dta", keepusing(gvkey naics) keep(1 3) nogen
rename gvkey GSgvkey
rename naics GSnaics

// Merge Global gvkeys and naics codes based on ISIN
preserve
use "$raw_data/gvkey_to_naics_global.dta", clear
keep gvkey isin naics
duplicates drop isin, force
save "$raw_data/gvkey_to_naics_global_isin.dta", replace
restore

merge m:1 isin using "$raw_data/gvkey_to_naics_global_isin.dta", keepusing(gvkey naics) keep(1 3) nogen
rename gvkey GISINgvkey
rename naics GISINnaics

// Get unique identifier
replace NAgvkey = GSgvkey if NAgvkey == ""
replace NAgvkey = GISINgvkey if NAgvkey == ""
rename NAgvkey gvkey
label var gvkey "gvkey"
drop GSgvkey GISINgvkey
sort gvkey

// Generate NAICS code
replace NAnaics = GSnaics if NAnaics == ""
replace NAnaics = GISINnaics if NAnaics == ""
rename NAnaics naics
label var naics "NAICS"
drop GSnaics GISINnaics

// Order variables
order ws_id gvkey ticker cusip sedol isin name region year segment IN fyearend /// 
freq nation_code segment_capex segment_oic segment_assets ///
segment_capex_USD segment_assets_USD naics Country_Out ///
Country_Out_iso3C Country_In Country_In_iso3C cpi_in cpi_out currency_country ///
currency_country_iso3C exchangerate in_euro

// Drop duplicates and observations with multiple values at firm x country-in x year-level
sort ws_id Country_In year IN 
duplicates tag ws_id Country_In year, generate(tagged)
duplicates drop ws_id Country_In IN year segment_capex segment_assets segment_oic, force
drop if tagged != 0


********************************************************************************
************************  7. PREPARE REGRESSION SAMPLE  ************************
********************************************************************************

egen segment_id = group(ws_id Country_In)

// Generate lagged parent fundamentals
preserve
	keep ws_id year tot_assets_USD roa total_assets_local total_liabilities_local
	foreach v of var tot_assets_USD roa total_assets_local total_liabilities_local {
	rename `v' `v'_lag1
	label var `v'_lag1 "`v'_t-1"
	}
	replace year = year + 1
	duplicates drop ws_id year, force
	tempfile lagged_parent_controls
	save `lagged_parent_controls'
restore
merge m:1 ws_id year using `lagged_parent_controls', keep(1 3) nogen

// Merge EPD masterfile
merge m:1 gvkey using "$raw_data/epd_masterfile.dta", force
drop if _merge == 2
replace report = 0 if report == .

// Keep extractive firms (NAICS code of 21 or 324 OR EPD reporting)
gen naics_2 = substr(naics, 1, 2)
gen naics_3 = substr(naics, 1, 3)
keep if naics_2 == "21" | naics_3 == "324" | _merge == 3
drop _merge

// Generate EPD variable
gen EPD_effective_since_year = year(effective_since)

gen EPD = 0
replace EPD = 1 if year >= EPD_effective_since_year
label var EPD_effective "EPD"

// Merge public shaming data
gen loc = Country_Out_iso3C
do "$code/clean_shaming_data.do"

// Foreign vs. domestic segment indicators
gen foreign = 0
replace foreign = 1 if (Country_In_iso3N != Country_Out_iso3N)
gen domestic = 0
replace domestic = 1 if (Country_In_iso3N == Country_Out_iso3N)

gen EPD_foreign_host_cty = EPD * foreign
gen EPD_domestic_host_cty = EPD * domestic

// High vs. low corruption in host country
gen cpi_2013 = cpi_in if year == 2013
gsort Country_In_iso3C
by Country_In_iso3C: egen cpi_2013_max = max(cpi_2013)

gen corrupt_host_cty = 0
replace corrupt_host_cty = 1 if (cpi_2013_max <= 28) // CPI value of 28 = 25th percentile
gen non_corrupt_host_cty = 0
replace non_corrupt_host_cty = 1 if (cpi_2013_max > 28)

gen EPD_corrupt_host_cty = EPD * corrupt_host_cty
gen EPD_non_corrupt_host_cty = EPD * non_corrupt_host_cty

// Company subject to high vs. low media coverage
replace high_media_cov_d = 0 if high_media_cov_d ==.
replace low_media_cov_d = 0 if low_media_cov_d ==.
gen EPD_high_media_cov = EPD * high_media_cov_d
gen EPD_low_media_cov = EPD * low_media_cov_d

// Company target vs. no target of NGO shaming campaign
replace campaign_before_effective_d = 0 if campaign_before_effective_d ==. 
replace no_campaign_before_effective_d = 0 if no_campaign_before_effective_d ==. 
gen EPD_activist_campaign = EPD * campaign_before_effective_d
gen EPD_no_activist_campaign = EPD * no_campaign_before_effective_d

// Generate dependent variable
gen seg_capex_ta = segment_capex_USD / (tot_assets_USD_lag1 / 1000000)
gen seg_capex_ta_100 = seg_capex_ta * 100

// Generate control variables
gen ln_tot_assets_lag1 = ln(tot_assets_USD_lag1)

gen leverage_lag1 = total_liabilities_local_lag1 / total_assets_local_lag1
winsor2 leverage_lag1, cuts(0 95) trim

winsor2 roa_lag1, cuts(5 95) trim
replace roa_lag1_tr = roa_lag1_tr / 100

// Drop negative segment capex observations
drop if seg_capex_ta < 0

// Generate Total Assets in USD millions
gen tot_assets_mn_USD = tot_assets_USD / 1000000

// Identify tax havens 
gen imf_1_in = 0
replace imf_1_in = 1 if (Country_In == "Guernsey" | Country_In == "Hong Kong" | Country_In == "Ireland" | Country_In == "Isle of Man" | Country_In == "Jersey" | Country_In == "Luxembourg" | Country_In == "Singapore" | Country_In == "Switzerland")

gen imf_2_in = 0
replace imf_2_in = 1 if (Country_In == "Andorra" | Country_In == "Bahrain" | Country_In == "Barbados" | Country_In == "Bermuda" | Country_In == "Gibraltar" | Country_In == "Macao" | Country_In == "Malaysia" | Country_In == "Malta" | Country_In == "Monaco")

gen imf_3_in = 0
replace imf_3_in = 1 if (Country_In == "Anguilla" | Country_In == "Antigua and Barbuda" | Country_In == "Aruba" | Country_In == "Bahamas" | Country_In == "Belize" | Country_In == "British Virgin Islands" ///
				    | Country_In == "Cayman Islands" | Country_In == "Cook Islands" | Country_In == "Costa Rica" | Country_In == "Cyprus" | Country_In == "Dominica" | Country_In == "Grenada" ///
					| Country_In == "Lebanon" | Country_In == "Liechtenstein" | Country_In == "Marshall Islands" | Country_In == "Mauritius" | Country_In == "Montserrat" | Country_In == "Nauru" ///
					| Country_In == "Netherlands Antilles" | Country_In == "Niue" | Country_In == "Panama" | Country_In == "Palau" | Country_In == "Samoa"  | Country_In == "Seychelles"  | Country_In == "St. Kitts and Nevis"  ///
					| Country_In == "St. Lucia" | Country_In == "St. Vincent and the Grenadines"  | Country_In == "Turks and Caicos Islands"  | Country_In == "Vanuatu")							
			
// Drop tax havens
keep if imf_1_in == 0 & imf_2_in == 0 & imf_3_in == 0

// Define sample
keep if year >= 2010 & year <= 2017
keep if seg_capex_ta < 0.10 & tot_assets_mn_USD > 10

// Keep segments with at least 1 observation in the pre- and post-2014 periods (results also hold without this restriction)
gen pre = 0
replace pre = 1 if year < 2014
gen post = 0
replace post = 1 if year >= 2014

egen segment_group = group(ws_id Country_In) 
bysort segment_group: egen pre_obs = sum(pre)
bysort segment_group: egen post_obs = sum(post)
keep if pre_obs > 0 & post_obs > 0

// Generate fixed effects and groups
egen firm_subsidiary_FE = group(ws_id Country_In_iso3C)
encode naics_3, gen(naics_3no)
egen resource_year_FE = group(naics_3no year)
egen host_country_year_FE = group(Country_In_iso3C year)
egen parent_country_FE = group(Country_Out)
egen treated_year_FE = group(report year)

// Label regression variables
lab var seg_capex_ta "Segment Capex/Total Assets\textsubscript{t-1}"
lab var seg_capex_ta_100 "Segment Capex/Total Assets\textsubscript{t-1} $\times$ 100"
lab var EPD "EPD"
lab var EPD_corrupt_host_cty "EPD $\times$ Highly Corrupt Host Country"
lab var EPD_non_corrupt_host_cty "EPD $\times$ Less Corrupt Host Country"
lab var EPD_foreign_host_cty "EPD $\times$ Foreign Host Country"
lab var EPD_domestic_host_cty "EPD $\times$ Domestic Host Country"
lab var corrupt_host_cty "Highly Corrupt Host Country"
lab var non_corrupt_host_cty "Less Corrupt Host Country"
lab var ln_tot_assets_lag1 "Ln(Total Assets\textsubscript{t-1})"
lab var roa_lag1_tr "Return on Assets\textsubscript{t-1}"
lab var leverage_lag1_tr "Leverage\textsubscript{t-1}"
lab var EPD_activist_campaign "EPD $\times$ Target of NGO Shaming Campaign"
lab var EPD_no_activist_campaign "EPD $\times$ Never Target of NGO Shaming Campaign"
lab var EPD_high_media_cov "EPD $\times$ High Media Coverage"
lab var EPD_low_media_cov "EPD $\times$ Low Media Coverage"


// Save clean and merged segment capex analysis dataset
save "$final_data/segment_capex_analysis_clean_FINAL.dta", replace

********************************************************************************
******                                                                   *******
******         ARTICLE: Extraction Payment Disclosures                   *******
******  	   AUTHOR: Thomas Rauter                                     *******
******         JOURNAL OF ACCOUNTING RESEARCH                            *******
******   	   CODE TYPE: Data Preparation for Parent Capex Analysis     *******
******         LAST UPDATED: August 2020                                 *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "investment"


********************************************************************************
*******************  1. CLEAN COMPUSTAT FIRM FUNDAMENTALS  *********************
********************************************************************************

// Prepare exchange rate data
use "$raw_data/g_exr_monthly.dta", clear
rename tocurm curcdq
save "$clean_data/currencies_monthly_clean.dta", replace

// Remove duplicates in securities dataset
use "$raw_data/security_data.dta", clear
gsort gvkey datadate
gen check = 0
replace check = 1 if (gvkey[_n] == gvkey[_n-1] & (datadate[_n] == datadate[_n-1]))
drop if check == 1
drop check
save "$clean_data/security_data_clean.dta", replace

// Remove duplicates in Compustat Global
use "$raw_data/compustat_global.dta", clear
gsort gvkey datadate
gen check = 0
replace check = 1 if (gvkey[_n] == gvkey[_n-1] & (datadate[_n] == datadate[_n-1]))
drop if check == 1
drop check

// Merge datasets (Compustat + Exchange Rates + Securities)
merge m:1 curcdq datadate using "$clean_data/currencies_monthly_clean.dta", keep(1 3) nogen

merge 1:1 gvkey datadate using "$clean_data/security_data_clean.dta", keep(1 3) nogen

order gvkey conm datacqtr datafqtr fyr fyearq loc atq capxy

save "$clean_data/compustat_global_incl_exr_and_security.dta", replace

// Import Compustat North America
use "$raw_data/compustat_northamerica.dta", clear

rename loc hq_cty
rename fic incorp_cty

// Keep only firms headquartered and incorporated in the USA or Canada
keep if ((hq_cty == "USA") & (incorp_cty == "USA") | (hq_cty == "CAN") & (incorp_cty == "CAN"))

// Merge exchange rate data
merge m:1 curcdq datadate using "$clean_data/currencies_monthly_clean.dta", keep(1 3) nogen

// Keep only relevant variables
keep gvkey fyearq hq_cty atq datacqtr datafqtr fyr fqtr naics conm capxy aqcy oibdpy ltq exratm

gen isin = ""
save "$clean_data/compustat_northamerica_incl_exr.dta", replace


********************************************************************************
**************************  2. BUILD MERGED DATASET  ***************************
********************************************************************************

// Import cleaned Compustat Global data
use "$clean_data/compustat_global_incl_exr_and_security.dta", clear

// Keep only relevant variables
keep gvkey fyearq datacqtr exratm loc isin atq datacqtr datafqtr fyr fqtr naics conm capxy aqcy oibdpy ltq 

// Keep only relevant countries 
rename loc hq_cty
keep if (hq_cty == "AUT" | hq_cty == "BEL" | hq_cty == "BUL" | hq_cty == "HRV" | hq_cty == "CYP" | hq_cty == "CZE" | hq_cty == "DNK" | hq_cty == "EST" | hq_cty == "FIN" | hq_cty == "FRA" | hq_cty == "DEU" | hq_cty == "GRC" | hq_cty == "HUN" | hq_cty == "IRL" | hq_cty == "ITA" | hq_cty == "LVA" | hq_cty == "LTU" | hq_cty == "LUX" | hq_cty == "MLT" | hq_cty == "NLD" | hq_cty == "POL" | hq_cty == "PRT" | hq_cty == "ROU" | hq_cty == "SVK" | hq_cty == "SVN" | hq_cty == "ESP" | hq_cty == "SWE" | hq_cty == "GBR" | hq_cty == "CHE" | hq_cty == "LIE" | hq_cty == "ISL" | hq_cty == "NOR" | hq_cty == "RUS" | hq_cty == "IND" | hq_cty == "CHN" | hq_cty == "AUS"  | hq_cty == "ZAF")

drop if isin == ""

// Append cleaned Compustat North America data
append using "$clean_data/compustat_northamerica_incl_exr.dta"

// Rename variables
rename conm company_name
rename capxy capex_qtly
rename aqcy acquisitions
rename oibdpy oibd
rename ltq tot_liabilities
rename atq tot_assets
rename datacqtr calendar_yrqt
rename datafqtr fiscal_yrqt
rename fyearq fiscal_yr
rename fyr fiscal_yr_end_month

// Remove duplicates
duplicates drop gvkey calendar_yrqt, force // based on calendar year
duplicates drop gvkey fiscal_yrqt, force // based on fiscal year

// Drop observations with missing total assets
drop if tot_assets >=.

// Define time variables
encode calendar_yrqt, gen(qrt_id)
drop if qrt_id >=.
label list qrt_id
encode fiscal_yrqt, gen(fisc_qrt_id)
label list fisc_qrt_id

encode gvkey, gen(gv_no)
encode hq_cty, gen(hq_cty_no)

// Identify extractive firms based on NAICS codes
gen naics2 = substr(naics,1,2)
gen naics3 = substr(naics,1,3)

gen extractive = 0
replace extractive = 1 if (naics2 == "21")
replace extractive = 1 if (naics3 == "324")
keep if extractive == 1

encode naics3, gen(naics3_no)


********************************************************************************
************************  3. PREPARE REGRESSION SAMPLE  ************************
********************************************************************************

// Merge EPD data
merge m:1 gvkey using "$raw_data/epd_masterfile.dta"
drop if _merge ==2

// Generate EPD effective quarter
gen effective_since_qrt = qofd(effective_since) if effective_since !=.

// Rebase quarters relative to start of sample
replace effective_since_qrt = effective_since_qrt - 198

// Manually add EPD dates for subsidiaries of reporting firms (that have different gvkeys as their parent company)
replace effective_since_qrt = 20 if (gvkey == "105595")
replace effective_since = td(01jul2014) if (gvkey == "105595")
replace report = 1 if (gvkey == "105595")

replace effective_since_qrt = 22 if (gvkey == "213127")
replace effective_since = td(01jan2015) if (gvkey == "213127")
replace report = 1 if (gvkey == "213127")

replace effective_since_qrt = 22 if (gvkey == "289282")
replace effective_since = td(01jan2015) if (gvkey == "289282")
replace report = 1 if (gvkey == "289282")

replace effective_since_qrt = 22 if (gvkey == "288747")
replace effective_since = td(01jan2015) if (gvkey == "288747")
replace report = 1 if (gvkey == "288747")

replace effective_since_qrt = 22 if (gvkey == "212085")
replace effective_since = td(01jan2015) if (gvkey == "212085")
replace report = 1 if (gvkey == "212085")

replace report = 0 if report ==.

// Generate EPD indicator
gen EPD = 0
replace EPD = 1 if (report == 1 & qrt_id >= effective_since_qrt & effective_since !=.)

// Convert firm fundamentals into GBP values
foreach var of varlist tot_assets capex_qtly oibd tot_liabilities {
   replace `var' = `var' / exratm
}

// Generate firm fundamentals
gsort gvkey fiscal_yrqt
by gvkey: gen tot_assets_lag1 = tot_assets[_n-1] if ((qrt_id[_n] == qrt_id[_n-1] + 1))

by gvkey: gen capex = (capex_qtly[_n] - capex_qtly[_n-1]) if (fiscal_yr[_n] == fiscal_yr[_n-1] & (fqtr == 2 | fqtr == 3 | fqtr == 4) & (fqtr[_n] == fqtr[_n-1] + 1))
replace capex = capex_qtly if (fqtr == 1)
drop if capex < 0

by gvkey: gen op_income = (oibd[_n] - oibd[_n-1]) if (fiscal_yr[_n] == fiscal_yr[_n-1] & (fqtr == 2 | fqtr == 3 | fqtr == 4) & (fqtr[_n] == fqtr[_n-1] + 1))
replace op_income = oibd if (fqtr == 1)

// Generate dependent variable
gen invest = capex / tot_assets_lag1

// Generate (non-lagged) control variables
gen ln_tot_assets = ln(tot_assets)
gen roa = op_income / tot_assets_lag1
gen leverage = tot_liabilities / tot_assets

// Trim variables
replace leverage =. if leverage < 0
winsor2 invest leverage, cuts(0 99) trim
winsor2 roa, cuts(1 99) trim

// Multiply dependent variable by 100
gen invest_tr_100 = invest_tr * 100

// Generate lagged variables
gsort gvkey fiscal_yrqt
foreach var of varlist invest_tr leverage_tr roa_tr ln_tot_assets {
	by gvkey: gen `var'_lag1 = `var'[_n-1] if ((fisc_qrt_id[_n] == fisc_qrt_id[_n-1] + 1))
}

// Define sample period (Q1-2010 to Q4-2017)
label list qrt_id
drop if qrt_id == 1 // Q4-2009
drop if qrt_id > 33 // > Q4-2017
tab qrt_id

// Generate firm fundamentals prior to EPD for Coarsened Exact Matching (CEM)
foreach var of varlist ln_tot_assets leverage_tr roa_tr tot_assets {
	gen `var'_mod = `var' if (qrt_id == 17)
	replace `var'_mod = 0 if (`var'_mod ==.)
	egen `var'_20131231 = max(`var'_mod), by(gvkey)
}

// Define fixed effects
egen industry_quarter_FE = group(naics3_no qrt_id)
egen country_quarter_FE = group(hq_cty_no qrt_id)
egen gvkey_no = group(gvkey)
egen treated = max(EPD), by(gvkey)
egen treated_quarter_FE = group(treated qrt_id)

// Label regression variables
lab var EPD "EPD"
lab var invest_tr "Parent Capex/Total Assets\textsubscript{t-1}"
lab var invest_tr_100 "Parent Capex/Total Assets\textsubscript{t-1} $\times$ 100"
lab var ln_tot_assets_lag1 "Ln(Total Assets\textsubscript{t-1})"
lab var roa_tr_lag1 "Return on Assets\textsubscript{t-1}"
lab var leverage_tr_lag1 "Leverage\textsubscript{t-1}"


// Save cleaned and merged parent capex analysis dataset
save "$final_data/parent_capex_analysis_clean_FINAL_new.dta", replace

********************************************************************************
******                                                                   *******
******   ARTICLE: Extraction Payment Disclosures                         *******
******   AUTHOR: Thomas Rauter                                           *******
******   JOURNAL OF ACCOUNTING RESEARCH                                  *******
******   CODE TYPE: Data Preparation for Bidding Participation Analysis  *******
******   LAST UPDATED: August 2020                                       *******
******                                                                   *******
********************************************************************************

clear all
set more off

global raw_data_new "$main_dir/05_New Analyses"


********************************************************************************
*********************** 1. CLEAN ENVERUS BIDDING DATA **************************
********************************************************************************

import excel "$raw_data_new/Hist_Bid_Blocks Africa.xlsx", sheet("Bid Data") firstrow allstring clear

// Define auction status
rename General_co general_comment
replace general_comment = upper(general_comment)

gen info_negotiation = 0
replace info_negotiation =  (strpos(general_comment, "NEGOTIATIONS") > 0)

gen info_pre_award= 0
replace info_pre_award = (strpos(general_comment, "PRE-AWARDED TO") > 0)

gen info_application = 0
replace info_application = (strpos(general_comment, "SUBMITTED APPLICATION") > 0)

gen info_award = 0
replace info_award = (strpos(general_comment, "AWARDED BLOCK") > 0)
replace info_award = 0 if (strpos(general_comment, "PRE-AWARDED") > 0) & info_award==1

gen info_rejection = 0
replace info_rejection = (strpos(general_comment, "REJECTED") > 0)

gen info_invitation = 0
replace info_invitation = (strpos(general_comment, "INVITED TO DISCUSS") > 0)

gen has_info_in_comment = 0
replace has_info_in_comment = info_negotiation + info_pre_award + info_application + info_award + info_rejection + info_invitation

// Drop auctions without any information on participants
drop if Bidding_Co=="n/a" & has_info_in_comment==0 | Bidding_Co=="No bid" & has_info_in_comment==0 | Bidding_Co=="No information post-round" & has_info_in_comment==0 | ///
Bidding_Co=="Unknown company in negotiation" & has_info_in_comment==0 | Bidding_Co=="" & has_info_in_comment==0

// Clean firm names
replace Bidding_Co = subinstr(Bidding_Co, "Pacific Oil & Gas", "Pacific Oil_Gas",.)
replace Bidding_Co = subinstr(Bidding_Co, "First E&P", "First E_P",.)
replace Bidding_Co = subinstr(Bidding_Co, "Sonangol P&P", "Sonangol P_P",.)

split Bidding_Co, p(".")
rename Bidding_Co Bidding_Co_Orig
rename Bidding_Co1 Bidding_Co
replace Bidding_Co2 = strtrim(Bidding_Co2) 
replace Bidding_Co2 = "" if Bidding_Co2=="No other bids"
split Bidding_Co2, p("also")
drop Bidding_Co22
split Bidding_Co21, p("," "and")
replace Bidding_Co211 = subinstr(Bidding_Co211, "Two additional bids by", "",.)
drop Bidding_Co2 Bidding_Co21

// Identify winning firms
gen winner = substr(Bidding_Co, 1, strpos(Bidding_Co, "winner") - 1)
replace winner = strtrim(winner) 
split winner, p("&")
drop winner
gen winner = substr(Bidding_Co, 1, strpos(Bidding_Co, "awarded") - 1)
replace winner1=winner if winner1==""
drop winner
rename winner1 winner_1
rename winner2 winner_2

// Identify other bidders
split Bidding_Co, p("&" " and " ",")
replace Bidding_Co1="" if (strpos(Bidding_Co, "winner") > 0) | (strpos(Bidding_Co, "awarded") > 0)
replace Bidding_Co2="" if (strpos(Bidding_Co, "winner") > 0) | (strpos(Bidding_Co, "awarded") > 0)
replace Bidding_Co2 = subinstr(Bidding_Co2, "understood to have submitted joint bid", "",.)

foreach n of numlist 1/7{
	replace Bidding_Co`n' = strtrim(Bidding_Co`n') 
	replace Bidding_Co`n'="" if Bidding_Co`n'=="n/a" | Bidding_Co`n'=="Unknown company in negotiations"
}

foreach m of numlist 1/5{
	replace Bidding_Co21`m'=Bidding_Co`m' if missing(Bidding_Co21`m')
	drop Bidding_Co`m'
}

rename Bidding_Co Bidding_Co_temp
	foreach v of numlist 1/5{
	rename Bidding_Co21`v' Bidding_Co_`v'
}

rename Bidding_Co6 Bidding_Co_6
rename Bidding_Co7 Bidding_Co_7
order Bidding_Co_6 Bidding_Co_7, before(winner_1)

// Manually add any remaining bidders
replace Bidding_Co_3 = "Shell" if general_comment=="AWARDED TO NOBLE ENERGY EVEN THOUGH BLOCK WAS NEVER FEATURED ON LIST OF BLOCKS UNDER NEGOTIATIONS. SHELL WAS ALSO NEGOTIATING FOR BLOCK"
replace Bidding_Co_3 = "Tullow" if general_comment=="BLOCK AVAILABLE VIA COMPETITIVE BIDDING. 15 OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DIRECT NEGOTIATIONS, 1 TO GNPC. 21 JAN 19 14 COMPANIES PRE-QUALIFIED. 21 MAY 19 ENI, VITOL & TULLOW SUBMIT BIDS FOR BLOCK 3"
replace Bidding_Co_2 = "Clontarf" if Block_ID=="1916000059" | Block_ID=="1916000061"
replace Bidding_Co_2 = "" if general_comment=="BLOCK AVAILABLE VIA COMPETITIVE BIDDING. 15 OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DIRECT NEGOTIATIONS, 1 TO GNPC. 21 JAN 19 14 COMPANIES PRE-QUALIFIED. 21 MAY 19 FIRST E&P ONLY BIDDER FOR BLOCK 2"

// Drop variables that are not used
keep Block_name Block_ID Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig Onlyonecompany Clearifallbiddersrevealed general_comment Country_IS BidRoundSt info_negotiation info_pre_award info_application info_award info_rejection info_invitation has_info_in_comment Bidding_Co_temp Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 winner_1 winner_2

// Identify auctions without information on winners and other bidders
gen no_winners_no_bidders = 0
replace no_winners_no_bidders = 1 if Bidding_Co_1=="" & Bidding_Co_2=="" & Bidding_Co_3=="" & Bidding_Co_4=="" & Bidding_Co_5=="" & Bidding_Co_6=="" & Bidding_Co_7=="" & winner_1=="" & winner_2=="" 

// Extract information on winning and bidding firms from comments if "Bidding_Co" variable is empty 
preserve 
keep if Bidding_Co_Orig=="n/a" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="No bid" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="No information post-round" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="Unknown company in negotiation" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
Bidding_Co_Orig=="Unknown company in negotiations" & has_info_in_comment!=0 & no_winners_no_bidders==1

drop Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 winner_1 winner_2
drop if general_comment=="COMPANIES NOT ALREADY PRESENT IN EG MUST PRE-QUALIFY, PRE-QUALIFICATION DOCUMENT TO BE SUBMITTED BY 15/09/2014. DATAROOM OPEN IN UK FROM 01/07/2014 BY APPOINTMENT. NEGOTIATIONS HELD BUT NO AWARD FOLLOWING BID ROUND" | ///
general_comment=="BLOCK AVAILABLE VIA DIRECT NEGOTIATIONS (DN). OCT 18 1ST LR LAUNCHED. 3 BLOCKS AVAILABLE VIA TENDER, 2 VIA DN, 1 TO GNPC. JAN 19 14 COMPANIES PRE-QUALIFIED. MAY 19 16 APPLICATIONS RECEIVED FOR DN FOR BLOCKS 5 & 6, EXXON & BP WITHDREW APPLICATIONS"

split general_comment, p(".")
drop general_comment2 general_comment5
gen bidders = substr(general_comment4, strpos(general_comment4, "APPLICATION BY") + 15,  .) if (strpos(general_comment4, "APPLICATION BY")>0)
split bidders, p(",")
drop bidders bidders2 general_comment4
gen bidders2 = substr(general_comment3, 1, strpos(general_comment3, "INVITED TO DISCUSS") - 1)
drop general_comment3
split general_comment1, p("(")

gen other_bidders=""
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "SUBMITTED") - 1)
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "REJECTED") - 1) if missing(other_bidders)
replace other_bidders = substr(general_comment12, 1, strpos(general_comment12, "NEGOTIATION") - 1) if missing(other_bidders)

replace other_bidders=subinstr(other_bidders, "WAS IN", "",.)
replace other_bidders=subinstr(other_bidders, "WERE IN", "",.)
split other_bidders, p("&")
drop general_comment12 other_bidders
rename other_bidders1 bidders3
rename other_bidders2 bidders4

gen other_bidders = substr(general_comment1, 1, strpos(general_comment1, "IN NEGOTIATION") - 1)
replace other_bidders=subinstr(other_bidders, "WAS", "",.)
replace other_bidders=subinstr(other_bidders, "WERE", "",.)
split other_bidders, p("&")
drop other_bidders
replace other_bidders1 = "" if (strpos(other_bidders1, "AWARDED")>0)
replace other_bidders1 = strtrim(other_bidders1) 
replace other_bidders2 = strtrim(other_bidders2) 

gen other_winners = substr(general_comment11, strpos(general_comment11, "PRE-AWARDED TO") + 15, .) if (strpos(general_comment1, "PRE-AWARDED TO") >0)
replace other_winners = substr(general_comment11, 1, strpos(general_comment11, "AWARDED") - 1) if missing(other_winners) & (strpos(general_comment11, "AWARDED") >0)
replace other_winners = strtrim(other_winners) 
replace other_winners = "IMPACT OIL_GAS" if other_winners=="JAN 2014: IMPACT OIL & GAS OFFERED RIGHT TO NEGOTIATE BLOCK AS PART OF 2013 LICENSING ROUND AND SUBSEQUENTLY"
replace other_winners = "TOTAL" if general_comment11=="MARATHON WAS  IN NEGOTIATIONS FOR BLOCK, REJECTED IN FAVOUR OF TOTAL"

split other_winners, p("&")
drop other_winners
replace other_winners1 = strtrim(other_winners1) 
replace other_winners2 = strtrim(other_winners2) 
drop general_comment11

gen Bidding_Co_1=""
replace Bidding_Co_1=bidders1
replace Bidding_Co_1=bidders2 if missing(Bidding_Co_1)
replace Bidding_Co_1=bidders3 if missing(Bidding_Co_1)

drop bidders1 bidders2 bidders3
rename other_bidders1 Bidding_Co_2
replace bidders4 = other_bidders2 if missing(bidders4)
drop other_bidders2
rename bidders4 Bidding_Co_3
rename other_winners1 winner_1
rename other_winners2 winner_2

tempfile info_recovered
save `info_recovered'
restore

// Drop auctions without any information on winners and other bidders after checking comments
drop if Bidding_Co_Orig=="n/a" & has_info_in_comment!=0 & no_winners_no_bidders==1 | Bidding_Co_Orig=="No bid" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
		Bidding_Co_Orig=="No information post-round" & has_info_in_comment!=0 & no_winners_no_bidders==1 | Bidding_Co_Orig=="Unknown company in negotiation" & has_info_in_comment!=0 & no_winners_no_bidders==1 | ///
		Bidding_Co_Orig=="Unknown company in negotiations" & has_info_in_comment!=0 & no_winners_no_bidders==1

append using `info_recovered'
drop no_winners_no_bidders

gen no_winners_no_bidders = 0
replace no_winners_no_bidders=1 if Bidding_Co_1=="" & Bidding_Co_2=="" & Bidding_Co_3=="" & Bidding_Co_4=="" & ///
Bidding_Co_5=="" & Bidding_Co_6=="" & Bidding_Co_7=="" & winner_1=="" & winner_2=="" 
drop if no_winners_no_bidders==1 & has_info_in_comment==1
drop general_comment1 no_winners_no_bidders

foreach n of numlist 1/7 {
replace Bidding_Co_`n' = strtrim(Bidding_Co_`n') 
}
replace winner_1 = strtrim(winner_1)
replace winner_2 = strtrim(winner_2)

// Save identified bidders in one variable
gen all_bidders = Bidding_Co_1 + "/" + Bidding_Co_2 + "/" + Bidding_Co_3 + "/" + Bidding_Co_4 + "/" +Bidding_Co_5 + "/" + Bidding_Co_6 + "/" + Bidding_Co_7 + "/" + winner_1 + "/" + winner_2

forval n=1/5 {
	replace all_bidders = subinstr(all_bidders, "//", "/",.) 
}

gen all_bidders2 = all_bidders
replace all_bidders2 = substr(all_bidders, 2, .) if substr(all_bidders, 1, 1)== "/"
split all_bidders2, p("/")

drop Bidding_Co_temp Bidding_Co_1 Bidding_Co_2 Bidding_Co_3 Bidding_Co_4 Bidding_Co_5 Bidding_Co_6 Bidding_Co_7 all_bidders ///
all_bidders2 info_negotiation info_pre_award info_application info_award info_rejection info_invitation has_info_in_comment

foreach m of numlist 1/7 {
	rename all_bidders2`m' bidder_`m'
}

// Replace name of Statoil with correct/new company name (Equinor)
foreach v in winner_1 winner_2 bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7 {
	replace `v'="Equinor" if `v'=="Statoil"
}

foreach v in winner_1 winner_2 bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7 {
	replace `v'="IMPACT" if `v'=="IMPACT OIL_GAS"
}

// Add manually-collected information
replace bidder_3 = "Total" if Block_ID =="1943000009" | Block_ID =="1943000010"
replace bidder_4 = "Galp" if Block_ID =="1943000009" | Block_ID =="1943000010"
replace bidder_2 = "Rift Energy" if Block_ID =="1956000004"
replace bidder_3 = "Total" if Block_ID =="1920000071"
replace bidder_3 = "Noble Energy" if Block_ID =="1920000077"
replace bidder_3 = "Shell" if Block_ID =="1920000061"

// Save cleaned bidding data
preserve
keep Block_name Block_ID Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ ///
Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig ///
general_comment Onlyonecompany Clearifallbiddersrevealed Country_IS BidRoundSt
save "$clean_data/bidding_hist_temp.dta", replace
restore


********************************************************************************
***********************  2. BUILD REGRESSION DATASET  **************************
********************************************************************************

// Extract and save data on winning firms
preserve
keep Block_ID winner_1 winner_2
reshape long winner_ , i(Block_ID) j(winning_company)
rename winner_ winner
drop if missing(winner)
merge m:1 Block_ID using "$clean_data/bidding_hist_temp.dta", keep(1 3) nogen
rename winner bidder
tempfile winners
save `winners'
restore

// Reshape data to level of bidding company
keep Block_ID bidder_1 bidder_2 bidder_3 bidder_4 bidder_5 bidder_6 bidder_7
reshape long bidder_ , i(Block_ID) j(bidding_company)
rename bidder_ bidder
drop if missing(bidder)

merge m:1 Block_ID using "$clean_data/bidding_hist_temp.dta", keep(1 3) nogen

merge 1:1 Block_ID bidder using `winners', nogen

replace winning_company = 0 if missing(winning_company)
replace winning_company = 1 if winning_company > 1

sort Block_ID bidding_company
gen count_bids = 1
bys Block_ID: egen bids_no = sum(count_bids)
bys Block_ID: egen winners_no = sum(winning_company)

gen multiple_winners = 0
replace multiple_winners = 1 if winners_no > 1
gen company_standardized = upper(bidder)

* Clean company names for merging with company HQ data
replace company_standardized = "AFRICA OIL" if company_standardized == "AFRICA OIL CORP"
replace company_standardized = "OPHIR ENERGY" if company_standardized == "OPHIR"
replace company_standardized = "REPSOL" if company_standardized == "REPSOL YPF"
replace company_standardized = "ROSNEFT OIL COMPANY" if company_standardized == "ROSNEFT"
replace company_standardized = "ROYAL DUTCH SHELL" if company_standardized == "SHELL"
replace company_standardized = "ENEL" if company_standardized == "ENEL POWER"
replace company_standardized = "KOSMOS" if company_standardized == "KOSMOS ENERGY"
replace company_standardized = "EQUINOR" if company_standardized == "STATOIL"
replace company_standardized = "NOBLE ENERGY" if company_standardized == "NOBLE"

* Align company names in EPD file
preserve
use "$clean_data/participant_EPD_clean.dta", clear
keep participantintname hq_country
rename participantintname company_standardized
replace company_standardized = upper(company_standardized)
duplicates drop company_standardized, force
drop if company_standardized=="NOT OPERATED"

replace company_standardized = "AFRICA ENERGY CORP" if company_standardized=="AFRICA ENERGY"
replace company_standardized = "AFRICA OIL" if company_standardized=="AFRICA OIL & GAS"
replace company_standardized = "DRAGON OIL" if company_standardized=="DRAGON"
replace company_standardized = "EDF (EDISON)" if company_standardized=="EDF"
replace company_standardized = "ENEL POWER" if company_standardized=="ENEL"
replace company_standardized = "FIRST E_P" if company_standardized=="FIRST E&P"
replace company_standardized = "GDF-SUEZ" if company_standardized=="ENGIE"
replace company_standardized = "HIBISCUS PETROLEUM JV" if company_standardized=="HIBISCUS"
replace company_standardized = "MEDITERRA ENERGY" if company_standardized=="MEDITERRA"
replace company_standardized = "MERLON INTERNATIONAL" if company_standardized=="MERLON"
replace company_standardized = "NEPTUNE ENERGY" if company_standardized=="NEPTUNE"
replace company_standardized = "NOBLE ENERGY" if company_standardized=="NOBLE"
replace company_standardized = "OPHIR ENERGY" if company_standardized == "OPHIR"
replace company_standardized = "ORANTO" if company_standardized=="ATLAS ORANTO"
replace company_standardized = "PURAVIDA" if company_standardized=="PURA VIDA"
replace company_standardized = "ROSNEFT OIL COMPANY" if company_standardized == "ROSNEFT"
replace company_standardized = "ROYAL DUTCH SHELL" if company_standardized == "SHELL"
replace company_standardized = "SONANGOL P_P" if company_standardized=="SONANGOL"
replace company_standardized = "SONTRACH" if company_standardized=="SONATRACH"
replace company_standardized = "TOWER RESOURCES" if company_standardized=="TOWER"
replace company_standardized = "TRIDENT" if company_standardized=="TRIDENT PETROLEUM"
replace company_standardized = "VEGA PETROLEUM" if company_standardized=="VEGA"
replace company_standardized = "WOODSIDE ENERGY" if company_standardized=="WOODSIDE"
replace company_standardized = "ENEL" if company_standardized == "ENEL POWER"

tempfile EPD_hq
save `EPD_hq'
restore 

// Merge HQ information and EPD effective dates
merge m:1 company_standardized using `EPD_hq', keep(1 3) nogen

replace company_standardized = subinstr(company_standardized, "_", "&",.)
replace company_standardized = "EDF - EDISON" if company_standardized == "EDF (EDISON)"
replace company_standardized = "KOSMOS ENERGY" if company_standardized=="KOSMOS"

// Merge with EPD masterfile
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keep(1 3)

// Generate date of bidding
split Bid_Round_, p("/")
drop Bid_Round_1 Bid_Round_2
rename Bid_Round_3 bid_round_year
destring bid_round_year, replace

split Bid_Round_, p("/")
foreach n of numlist 1/9{
	replace Bid_Round_1="0`n'" if Bid_Round_1=="`n'"
	replace Bid_Round_2="0`n'" if Bid_Round_2=="`n'"
}

gen bid_round_date = Bid_Round_1 + "\" + Bid_Round_2 + "\" + Bid_Round_3
gen date = date(bid_round_date,"MDY")
format date %td
drop bid_round_date Bid_Round_1 Bid_Round_2 Bid_Round_3
rename date bid_round_date

// Save all bidder information in one dataset
preserve
duplicates drop company_standardized, force
sort company_standardized Block_ID
keep company_standardized effective_since part_of_annual_report number_of_pages ///
direct_to_consumer_market attestation_reporting_entity attestation_independent_audit hq_country ///
student ticker_not_sure reporting_issue report
save "$clean_data/all_bidders.dta", replace
restore

// Span bidder-auction panel
local blocks 1301000017 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 ///
1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 ///
1301000041 1301000042 1301000043 1301000044 1301000045 1301000048 1301000060 1301000061 1301000062 1301000068 1301000070 ///
1301000073 1315000507 1315000508 1315000510 1315000511 1315000514 1315000516 1315000518 1315000519 1315000532 1315000536 ///
1315000537 1315000538 1315000553 1315000554 1315000578 1315000579 1315000584 1315000588 1315000594 1315000601 1315000604 ///
1315000607 1315000609 1315000612 1315000616 1315000618 1315000619 1315000643 1315000664 1315000667 1315000669 1315000670 ///
1315000672 1315000676 1315000677 1315000683 1315000684 1315000687 1315000692 1315000695 1315000698 1315000713 1315000714 ///
1902000237 1907000009 1907000012 1907000027 1907000028 1911000050 1911000053 1911000056 1911000059 1916000024 1916000028 ///
1916000033 1916000034 1916000059 1916000061 1920000048 1920000049 1920000050 1920000051 1920000056 1920000061 1920000062 ///
1920000063 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000078 1920000080 1920000081 1920000082 ///
1920000084 1920000085 1921000002 1921000003 1937000673 1937000674 1937000676 1937000677 1937000682 1937000683 1937000686 ///
1943000009 1943000010 1952000004 1956000000 1956000001 1956000002 1956000003 1956000004

local block_vars "Block_ID Block_name Contract_n Contract_I Country Region_Wor On_Offshor Province Basin Contract_s Bid_round_ Contract_b Contract_t Block_Area Bid_Round_ Bid_Roun00 Bid_Submis Bid_Subm00 Award_Noti Status_of_ Bidding_Co_Orig general_comment Onlyonecompany Clearifallbiddersrevealed Country_IS BidRoundSt count_bids bids_no winners_no multiple_winners bid_round_year bid_round_date"

foreach b of local blocks {
preserve
keep if Block_ID=="`b'"
drop _merge
append using "$clean_data/all_bidders.dta"
duplicates tag company_standardized, gen(dup)
drop if dup==1 & missing(Block_ID)
replace bidding_company=0 if missing(bidding_company)
foreach v of local block_vars{
replace `v'=`v'[1]
}
tempfile block_`b'
save `block_`b''
restore
}

local blocks2 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 ///
1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 ///
1301000041 1301000042 1301000043 1301000044 1301000045 1301000048 1301000060 1301000061 1301000062 1301000068 1301000070 ///
1301000073 1315000507 1315000508 1315000510 1315000511 1315000514 1315000516 1315000518 1315000519 1315000532 1315000536 ///
1315000537 1315000538 1315000553 1315000554 1315000578 1315000579 1315000584 1315000588 1315000594 1315000601 1315000604 ///
1315000607 1315000609 1315000612 1315000616 1315000618 1315000619 1315000643 1315000664 1315000667 1315000669 1315000670 ///
1315000672 1315000676 1315000677 1315000683 1315000684 1315000687 1315000692 1315000695 1315000698 1315000713 1315000714 ///
1902000237 1907000009 1907000012 1907000027 1907000028 1911000050 1911000053 1911000056 1911000059 1916000024 1916000028 ///
1916000033 1916000034 1916000059 1916000061 1920000048 1920000049 1920000050 1920000051 1920000056 1920000061 1920000062 ///
1920000063 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000078 1920000080 1920000081 1920000082 ///
1920000084 1920000085 1921000002 1921000003 1937000673 1937000674 1937000676 1937000677 1937000682 1937000683 1937000686 ///
1943000009 1943000010 1952000004 1956000000 1956000001 1956000002 1956000003 1956000004

local blocks
use `block_1301000017', clear
foreach b of local blocks2 {
	append using `block_`b''
}
drop dup count_bids


// Clean variables
replace bidder="Not a bidder" if missing(bidder)
replace report=0 if report==.
replace company_standardized="SONATRACH" if company_standardized=="SONTRACH"

gen company_HC_type=company_standardized
replace company_HC_type = "EDF" if company_standardized=="EDF - EDISON"
replace company_HC_type = "AFRICA ENERGY" if company_standardized=="AFRICA ENERGY CORP"
replace company_HC_type = "KNOC" if company_standardized=="DANA PETROLEUM"
replace company_HC_type = "ACR" if company_standardized=="ACREP"
replace company_HC_type = "DEA" if company_standardized=="DEA EGYPT"
replace company_HC_type = "ENOC" if company_standardized=="DRAGON OIL"
replace company_HC_type = "EDF" if company_standardized=="EDF - EDISON"
replace company_HC_type = "EDF" if company_standardized=="EDISON" & bid_round_year>=2012
replace company_HC_type = "IMPACT" if company_standardized=="IMPACT OIL&GAS"
replace company_HC_type = "IOCL" if company_standardized=="INDIAN OIL"
replace company_HC_type = "KOSMOS" if company_standardized=="KOSMOS ENERGY"
replace company_HC_type = "MEDITERRA" if company_standardized=="MEDITERRA ENERGY"
replace company_HC_type = "MERLON" if company_standardized=="MERLON INTERNATIONAL"
replace company_HC_type = "NOBLE" if company_standardized=="NOBLE ENERGY"
replace company_HC_type = "OPHIR" if company_standardized=="OPHIR ENERGY"
replace company_HC_type = "ATLAS ORANTO" if company_standardized=="ORANTO"
replace company_HC_type = "PURA VIDA" if company_standardized=="PURAVIDA"
replace company_HC_type = "ROSNEFT" if company_standardized=="ROSNEFT OIL COMPANY"
replace company_HC_type = "SONANGOL" if company_standardized=="SONANGOL P&P"
replace company_HC_type = "SONATRACH" if company_standardized=="SONTRACH"
replace company_HC_type = "EQUINOR" if company_standardized=="STATOIL"
replace company_HC_type = "TOWER" if company_standardized=="TOWER RESOURCES"
replace company_HC_type = "TRIDENT ENERGY" if company_standardized=="TRIDENT"
replace company_HC_type = "WOODSIDE" if company_standardized=="WOODSIDE ENERGY"

// Merge data on main hydrocarbon type at bidding-company level 
preserve
use "$main_dir/01_Clean_Data/mainHC_type.dta", clear
replace participantintname=upper(participantintname)
rename participantintname company_HC_type
drop if company_HC_type=="NOT OPERATED"
replace company_HC_type="ROYAL DUTCH SHELL" if company_HC_type=="SHELL"
duplicates drop company_HC_type, force
tempfile main_resource_type
save `main_resource_type'
restore

merge m:1 company_HC_type using `main_resource_type', keep(1 3)

// Manually add missing HQ country information
replace hq_country = "Angola" if company_standardized=="ACREP"
replace hq_country = "Australia" if company_standardized=="ARMOUR"
replace hq_country = "United States" if company_standardized=="ASPECT"
replace hq_country = "Switzerland" if company_standardized=="BLUEGREEN"
replace hq_country = "United States" if company_standardized=="COBALT"
replace hq_country = "South Korea" if company_standardized=="DANA PETROLEUM"
replace hq_country = "Germany" if company_standardized=="DEA EGYPT"
replace hq_country = "Germany" if company_standardized=="DELONEX ENERGY"
replace hq_country = "France" if company_standardized=="EDISON"
replace hq_country = "Ghana" if company_standardized=="ELANDEL ENERGY"
replace hq_country = "United Kingdom" if company_standardized=="ELENILTO"
replace hq_country = "Mozambique" if company_standardized=="ENH"
replace hq_country = "United States" if company_standardized=="GLINT"
replace hq_country = "United Kingdom" if company_standardized=="IMPACT OIL&GAS"
replace hq_country = "India" if company_standardized=="INDIAN OIL"
replace hq_country = "Mozambique" if company_standardized=="INDICO"
replace hq_country = "Egypt" if company_standardized=="KIERON MAGAWISH"
replace hq_country = "Nigeria" if company_standardized=="LEVENE ENERGY"
replace hq_country = "Singapore" if company_standardized=="PACIFIC OIL&GAS"
replace hq_country = "Portugal" if company_standardized=="PARTEX"
replace hq_country = "Thailand" if company_standardized=="PTTP"
replace hq_country = "United Kingdom" if company_standardized=="SEA DRAGON"
replace hq_country = "Tanzania" if company_standardized=="SWALA"
replace hq_country = "Ireland" if company_standardized=="CLONTARF"
replace hq_country = "Canada" if company_standardized=="RIFT ENERGY"
replace hq_country = "Nigeria" if company_standardized=="OFFSHORE EQUATOR PLC"

// Final clean up of bidding company and HQ variables
replace bidder = subinstr(bidder, "_", "&", .)
replace bidder = subinstr(bidder, "Sontrach", "Sonatrach", .)
replace hq_country = "Australia" if hq_country=="Austalia"
replace hq_country = strtrim(hq_country)

// Only keep auctions for which there is evidence that all bidding companies are included (after online cross validations)
local keep "1301000048 1301000060 1301000061 1301000062 1301000070 1301000073 1315000612 1315000664 1315000683 1315000684 1315000714 1921000002 1921000003 1937000683 1956000000 1956000001 1956000002 1956000003 1956000004 1920000061 1920000067 1920000068 1920000071 1920000072 1920000076 1920000077 1920000080 1920000084 1920000085 1301000017 1301000018 1301000019 1301000020 1301000021 1301000022 1301000023 1301000024 1301000025 1301000026 1301000027 1301000028 1301000029 1301000030 1301000034 1301000035 1301000036 1301000037 1301000038 1301000039 1301000040 1301000041 1301000042 1301000043 1301000044 1301000045 1301000068 1916000059 1916000061 1920000078 1943000009 1943000010 1920000050 1920000051 1920000056 1920000062 1920000081 1920000082"
gen keep=0

foreach k in `keep'{
replace keep=1 if Block_ID=="`k'"
}
keep if keep==1

// Generate "Submitted Bid" indicator
gen active_bidder = ""
replace active_bidder = "YES" if bidder != "Not a bidder"
replace active_bidder = "NO" if bidder == "Not a bidder"

gen submitted_bid = 0
replace submitted_bid = 1 if active_bidder=="YES"
lab var submitted_bid "Company Submitted Bid for Auction"

// Generate EPD treatment indicator
gen EPD=0
replace EPD = 1 if bid_round_date >= effective_since & bid_round_date <.
gen EPD_submitted_bid = submitted_bid * report
gen EPD_effective_yr=year(effective_since) 

// Generate "Number of Bids per Auction" variable
bys Block_ID: egen bids_per_auction = total(submitted_bid)
bys Block_ID: egen EPD_bids_per_auction = total(EPD_submitted_bid)
gen non_EPD_bids_per_auction = bids_per_auction - EPD_bids_per_auction
gen EPD_bids_per_auction_pct = EPD_bids_per_auction/bids_per_auction*100
gen non_EPD_bids_per_auction_pct = non_EPD_bids_per_auction/bids_per_auction*100

// Quantify bidding activity by firm
gen sub_bid = submitted_bid
bys company_standardized: egen bid_activity = sum(sub_bid)

// Drop firms that never submitted any bid
drop if bid_activity == 0

// Define regression sample
keep if bid_round_year >= 2010

// Generate control variables
rename Contract_t contract_type
replace contract_type=strtrim(contract_type)
gen exploration=0
replace exploration = 1 if contract_type=="Exploration"
destring Block_Area, replace
gen ln_block_size = ln(Block_Area)
*gen post_EPD = 0
*replace post_EPD = 1 if bid_round_year > 2013

// Generate fixed effects
egen year_FE = group(bid_round_year)
egen firm_FE = group(company_standardized)
egen treated_FE = group(report)
egen treated_year_FE = group(report bid_round_year)
egen resourcetype_FE = group(main_hc_type)
egen resourcetype_year_FE = group(main_hc_type bid_round_year)
egen host_country_FE = group(Country_IS)
egen hq_country_FE = group(hq_country)

// Label regression variables
lab var EPD "EPD"
lab var submitted_bid "Firm Submitted Bid"
lab var submitted_bid "Submitted Bid"
lab var bids_per_auction "Tot. bids received for auction X"
lab var EPD_bids_per_auction "Tot. bids received from EPD firms"
lab var non_EPD_bids_per_auction "Tot. bids received from Non-EPD firms"
lab var exploration "Exploration"
lab var ln_block_size "Ln(Size of Oil \& Gas Block)"
lab var Block_ID "Enverus Block ID"
lab var On_Offshor "License for On- vs. Offshore Block"
lab var contract_type "License Type Being Awarded"
lab var Block_Area "Size of Block in sqkm"
lab var Country_IS "2-digit ISO code of Country where Block is located"
lab var company_standardized "Standardized Name of Bidding Firm"
lab var hq_country "Headquarter Country of Bidding Firm"
lab var effective_since "Firm is subject to EPD regulation since - Date" 
lab var bid_round_year "Year of Block Auction"
lab var bid_round_date "Date of Block Auction"
lab var main_hc_type "Main Hydrocarbon Extracted by Firm"
lab var bid_activity "Total Bids Sumbitted by Firm"
lab var EPD_effective_yr "Firm is subject to EPD regulation since - Year" 
lab var EPD_bids_per_auction_pct "Pct of Bids received by Firms subject to EPD"
lab var non_EPD_bids_per_auction_pct "Pct of Bids received by Firms never subject to EPD"
lab var post_EPD "Post EPD Period (2014 and after)"


// Save cleaned and merged bidding behaviour dataset
save "$final_data/bidding_behaviour_analysis_clean_FINAL.dta", replace

********************************************************************************
******                                                                   *******
******   ARTICLE: Extraction Payment Disclosures                         *******
******   AUTHOR: Thomas Rauter                                           *******
******   JOURNAL OF ACCOUNTING RESEARCH                                  *******
******   CODE TYPE: Data Preparation for Oil and Gas Licensing Analysis  *******
******   LAST UPDATED: August 2020                                       *******
******                                                                   *******
********************************************************************************

clear all
set more off

global analysis_type "licensing"


********************************************************************************
**********************  1. BUILD FIRM-COUNTRY-YEAR PANEL ***********************
********************************************************************************

// Import block data (unique at blockid level)
import delimited "$raw_data/BlocksTable.CSV", clear 

// Keep major blocks
keep if areasqkm >= 1000

// Reshape data to block-participant level
rename operatorlocalname participant0localname
rename operatorintname participant0intname
rename operatorwi participant0wi

forvalues i=0/6 {
	rename participant`i'localname participantlocalname`i'
	rename participant`i'intname participantintname`i'
	rename participant`i'wi participantwi`i'
	}

reshape long participantlocalname participantintname participantwi, i(blockid) j(participant_number)
drop if participantlocalname=="" & participantintname=="" & participantwi==.

// Check if data is unique at block id-participant level
isid blockid participant_number

save "$clean_data/oil_block_participant.dta", replace

// Generate key dates
generate award_date=date(awarddate, "YMD")
format award_date %td
generate year=year(award_date)

generate expiry_date=date(expirydate, "YMD")
format expiry_date %td
generate expiry_year=year(expiry_date)

// Generate participant id
replace participantlocalname="Unknown" if participantlocalname==""
egen participantID=group(participantintname participantlocalname)

generate number_blocks_opened = 1

// Add time and country dimensions
fillin participantintname country year
	
// Identify earliest year participant had block in given country
bys participantintname country: egen min_award_date=min(award_date)
format min_award_date %td
label variable min_award_date "Earliest award date for participant-country"

// Identify latest year participant had block in given country
bys participantintname country: egen max_expiry_date=max(expiry_date)
format max_expiry_date %td
label variable max_expiry_date "Latest expiry date for participant-country"
		
// Collapse to participant-country-year level
if "`version'"=="ID" local keep "participantlocalname participantintname"
collapse (sum) number_blocks_opened, by(participantintname country year min_award_date max_expiry_date  `keep')
isid participant`version' country year, missok
label variable number_blocks_opened "# blocks participant opened in that county-year"
		
// Identify whether participant ever had a block in the country
bys participantintname country: egen ever_had_block=max(number_blocks_opened>=1)
label variable ever_had_block "Participant-country appears in block dataset"

// Create an indicator = 1 for every year past award date
bys participantintname country: generate has_block=(year>=year(min_award_date) & year<=year(max_expiry_date)) if (min_award_date!=. & max_expiry_date!=.)
replace has_block=0 if ever_had_block==0
label variable has_block "Participant-country award date<=year"
		
// Create an indicator = 1 for block openings
generate any_blocks_opened=(number_blocks_opened>=1)
label variable any_blocks_opened "Dummy for 1+ block opening(s) by participant in that country-year"		

// Save firm-country-year panel
drop if year==.
order participant* country year min_award_date max_expiry_date has_block ever_had_block number_blocks_opened any_blocks_opened

save "$raw_data/oil_block_participantintname_country_year.dta", replace


********************************************************************************
***************************  2. CLEAN LICENSING DATA ***************************
********************************************************************************

import excel "$raw_data/operator_headquarters_merged.xlsx", clear sheet("Manual_merge_Formulas") cellrange(A1:P622) firstrow

// Unify manually-collected gvkeys
gen gvkey=""
replace gvkey=gvkey_HANNAH if gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_E=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_A if gvkey_HANNAH=="" & gvkey_VLOOKUP_E=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_E if gvkey_HANNAH=="" & gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_F==""
replace gvkey=gvkey_VLOOKUP_F if gvkey_HANNAH=="" & gvkey_VLOOKUP_A=="" & gvkey_VLOOKUP_E==""

global gvkey "gvkey_VLOOKUP_A gvkey_VLOOKUP_E gvkey_VLOOKUP_F gvkey_HANNAH"
foreach g of global gvkey{
	replace gvkey=`g' if gvkey=="" & `g'==gvkey_VLOOKUP_A | gvkey=="" & `g'==gvkey_VLOOKUP_E | gvkey=="" & `g'==gvkey_VLOOKUP_F
}

// Drop redundant variables
drop Modifications company FirstwordofFullName Firstwordofoperatorintname $gvkey

// Rename remaining variables
rename operatorintname participantintname
rename HeadquartersHannahFederica hq_country

// Clean firms' headquarter country
replace hq_country="Angola" if participantintname=="ACR" & hq_country=="Angola/ Mauritius"
replace hq_country="United Kingdom" if participantintname=="Global Connect" & hq_country=="British Virgin Islands/UK"
replace hq_country="Canada" if participantintname=="PetroSinai" & hq_country=="Canada/Egypt"
replace hq_country="Kuwait" if participantintname=="EASPCO" & hq_country=="Egypt/Kuwait"
replace hq_country="Egypt" if participantintname=="Mansoura" & hq_country=="Egypt??"
replace hq_country="Egypt" if participantintname=="EKH" & hq_country=="France/UK"
replace hq_country="United Kingdom" if participantintname=="Minexco OGG" & hq_country=="Gibraltar/UK"
replace hq_country="United Kingdom" if participantintname=="Rapetco" & hq_country=="Italy/UK (50/50)"
replace hq_country="United Kingdom" if participantintname=="BWEH" & hq_country=="Mauritania - BW Offshore/Bermuda - BW Offshore Limited/UK - Limited/Netherlands - Mgmt"
replace hq_country="Namibia" if participantintname=="Trago" & hq_country=="Namibia?"
replace hq_country="Netherlands" if participantintname=="West Sitra" & hq_country=="Netherlands/Egypt"
replace hq_country="United States" if participantintname=="Grasso Consortium" & hq_country=="Nigeria/USA" | participantintname=="Grasso" & hq_country=="Nigeria/USA"
replace hq_country="South Korea" if hq_country=="South Corea"
replace hq_country="United States" if participantintname=="NOPCO" & hq_country=="USA?"
replace hq_country="United Kingdom" if participantintname=="Chariot" & hq_country=="United Kingdom / Channel Islands"
replace hq_country="United Kingdom" if participantintname=="North El Burg" & hq_country=="United Kingdom /Italy"
replace hq_country="United Kingdom" if participantintname=="Equator Hydrocarbons" & hq_country=="United Kingdom/Nigeria"
replace hq_country="Yemen" if participantintname=="PEPA" & hq_country=="Yemen?"

replace participantintname="Shell" if participantintname=="Royal Dutch Shell"

replace EPD_effective_since=. if participantintname == "Africa Oil & Gas"
replace EPD_publication_date=. if participantintname == "Africa Oil & Gas"

save "$clean_data/participant_EPD_clean.dta", replace


********************************************************************************
************************  3. PREPARE REGRESSION SAMPLE *************************
********************************************************************************

// Merge licensing panel with EPD masterfile
use "$raw_data/oil_block_participantintname_country_year.dta", clear
merge m:1 participantintname using "$clean_data/participant_EPD_clean.dta"

// Drop unidentified firms
drop if participantintname=="Not Operated" | participantintname=="Not operated" | participantintname=="Unassigned" | participantintname=="Unknown"
drop if _merge == 2
drop if year==.

// Identify firms subject to EPD reporting      
gen EPD_effective_yr = year(EPD_effective_since) 
gen EPD_publication_yr = year(EPD_publication_date) 
gen EPD=0
bys participantintname year: replace EPD=1 if year >= EPD_effective_yr & EPD_effective_yr !=.
bys participantintname year: replace EPD=0 if EPD_effective_yr==.
drop _merge
rename FullName participant_full_name

// Clean host country names
replace country = "Tunisia" if country == "Libya-Tunisia JEZ"
replace country = "Senegal" if country == "S-GB AGC"
replace country = "Nigeria" if country == "Sao Tome & Nigeria"

// Generate ISO codes for (i) host countries and (ii) HQ countries
kountry country, from(other) stuck marker
rename _ISO3N_ iso_n
kountry iso_n, from(iso3n) to(iso3c) 
rename _ISO3C_ iso
kountry hq_country, from(other) stuck 
rename _ISO3N_ iso_n_hq
kountry iso_n_hq, from(iso3n) to(iso3c) 
rename _ISO3C_ iso_hq

// Clean and merge data on firms' main hydrocarbon
preserve
use "$raw_data/oil_block_participant.dta", clear

gen oil = 0
gen gas = 0

gen gas_and_oil = 0
replace oil = 1 if hydrocarbontype=="Oil"
replace gas = 1 if hydrocarbontype=="Gas and Condensate"
replace gas = 1 if hydrocarbontype=="Gas"
replace gas_and_oil = 1 if hydrocarbontype=="Oil and Gas" 

collapse (sum) oil gas gas_and_oil, by (participantintname)

gen only_oil=0
gen only_gas=0
gen mix_gas_and_oil=0
replace only_oil=1 if oil>0 & gas==0 & gas_and_oil==0
replace only_gas=1 if gas>0 & oil==0 & gas_and_oil==0
replace mix_gas_and_oil=1 if gas_and_oil>0 
replace mix_gas_and_oil=1 if gas_and_oil==0 & oil>0 & gas>0

gen main_hc_type=""
replace main_hc_type="Only oil" if only_oil==1
replace main_hc_type="Only gas" if only_gas==1
replace main_hc_type="Oil and Gas" if mix_gas_and_oil==1
drop oil gas gas_and_oil only_oil only_gas mix_gas_and_oil

save "$clean_data/mainHC_type.dta", replace
restore
 
merge m:1 participantintname using "$clean_data/mainHC_type.dta", keep(1 3)

// Define dependent variable
replace any_blocks_opened = any_blocks_opened * 100

// Identify treatment group
bys participantintname: egen disclosing = max(EPD)

// Define sample period
keep if (year >= 2000 & year <= 2018)

// Create fixed effects
egen host_country_FE = group(iso)
egen host_country_year_FE = group(iso year)
egen resourcetype_year_FE = group(main_hc_type year)
egen treatment_year_FE = group(disclosing year)
egen hq_country_id = group(hq_country)

// Label regression variables
lab var EPD "EPD"
lab var any_blocks_opened "Obtained License $\times$ 100"

// Save cleaned and merged licensing dataset
save "$final_data/extensive_analysis_clean_FINAL.dta", replace

********************************************************************************
******                                                                   *******
******        ARTICLE: Extraction Payment Disclosures                    *******
******        AUTHOR: Thomas Rauter                                      *******
******        JOURNAL OF ACCOUNTING RESEARCH                             *******
******        CODE TYPE: Data Preparation for Productivity Analysis      *******
******        LAST UPDATED: August 2020                                  *******
******                                                                   *******
********************************************************************************

clear all
set more off


********************************************************************************
****************** 1. CLEAN ENVERUS ASSET-TRANSACTIONS DATA ********************
********************************************************************************

import delimited "$raw_data/AssetTransactionsFull.CSV", encoding(ISO-8859-1)clear 

// Prepare variables
rename country block_country
rename agreementdate agreement_date 
rename closedate closed_date 
rename effectivedate effective_date
rename blockname block_name
rename transactionstatus transaction_status
rename sellingentitylocalname seller_local_name
rename sellingentityintname seller_int_name
rename purchasingentityintname buyer_int_name
rename purchasingentitylocalname buyer_local_name
rename interestpurchased interest_purchased
rename blockid block_id_enverus
rename operatorchange operator_change

replace block_country = upper(block_country)
replace block_name = upper(block_name)
replace block_id_enverus = strtrim(block_id_enverus)

foreach phase in agreement closed effective {
	gen deal_`phase'_date = date(`phase'_date, "YMD")
	format deal_`phase'_date %td
}

// Generate date of asset transaction => pecking order: 1. effective, 2. closed, 3. agreement
gen deal_date_combined = deal_effective_date
replace deal_date_combined = deal_closed_date if missing(deal_date_combined)
replace deal_date_combined = deal_agreement_date if missing(deal_date_combined)
format deal_date_combined %td

gen deal_date_type = ""
replace deal_date_type = "Effective" if deal_date_combined == deal_effective_date
replace deal_date_type = "Closed" if deal_date_combined == deal_closed_date
replace deal_date_type = "Agreement" if deal_date_combined == deal_agreement_date

// Keep host countries with production data
keep if block_country =="ANGOLA" | block_country =="GHANA" | block_country =="MAURITANIA" | block_country =="NIGERIA" | ///
	block_country =="SENEGAL" | block_country =="TUNISIA"

// Keep deals with known deal date
drop if missing(deal_date_combined)

// Keep finalized deals that can impact production
keep if transaction_status == "Complete"

// Generate deal date variables
gen month = month(deal_date_combined)
gen year = year(deal_date_combined)
sort block_name year month

// Clean seller names
replace seller_int_name = upper(seller_int_name)
gen company_standardized = seller_int_name
replace company_standardized ="AKER BP" if seller_int_name=="AKER ENERGY"
replace company_standardized ="ENI" if seller_int_name=="ENI PETROLEUM CO., INC."
replace company_standardized ="SEPLAT PETROLEUM DEVELOPMENT COMPANY" if seller_int_name=="SEPLAT"
replace company_standardized ="SERINUS ENERGY" if seller_int_name=="SERINUS" | seller_int_name=="KULCZYK"
replace company_standardized ="ROYAL DUTCH SHELL" if seller_int_name=="SHELL"
replace company_standardized ="TULLOW OIL" if seller_int_name=="TULLOW"

// Identify EPD sellers
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keepusing(effective_since report)
rename company_standardized seller_standardized
rename effective_since effective_since_seller
rename report reporting_seller

replace reporting_seller = 0 if missing(reporting_seller)
drop if _merge==2
drop _merge

// Clean buyer names
replace buyer_int_name = upper(buyer_int_name)
gen company_standardized = buyer_int_name
replace company_standardized ="AKER BP" if buyer_int_name=="AKER ENERGY"
replace company_standardized ="ENI" if buyer_int_name=="ENI PETROLEUM CO., INC."
replace company_standardized ="SEPLAT PETROLEUM DEVELOPMENT COMPANY" if buyer_int_name=="SEPLAT"
replace company_standardized ="SERINUS ENERGY" if buyer_int_name=="SERINUS" | buyer_int_name=="KULCZYK"
replace company_standardized ="ROYAL DUTCH SHELL" if buyer_int_name=="SHELL"
replace company_standardized ="TULLOW OIL" if buyer_int_name=="TULLOW"

// Identify non-EPD buyers
merge m:1 company_standardized using "$raw_data/epd_masterfile.dta", keepusing(effective_since report)
rename company_standardized buyer_standardized
rename effective_since effective_since_buyer
rename report reporting_buyer

replace reporting_buyer = 0 if missing(reporting_buyer)
drop if _merge==2
drop _merge 

// Clean-up specific block IDs based on feedback from ENVERUS
replace block_id_enverus = "1940000434" if block_name=="OML 71"
replace block_id_enverus = "1355000175" if block_name=="BENI KHALED" & block_id_enverus=="1355000245"

// Generate indicator for transactions with change in block operator
gen operator_changed=0
replace operator_changed = 1 if operator_change== "true"

// Generate indicator for transactions with EPD buyer (to be netted out at block level)
gen neutral_deal = 1
replace neutral_deal = 0 if reporting_buyer == 0

// Change sign of acquired share by EPD buyers (for netting out at block level)
replace interest_purchased = - interest_purchased if neutral_deal == 1

// Collapse license transactions at block-month level
sort block_name year month  
collapse (sum) interest_purchased operator_changed (min) neutral_deal, ///
by(block_id_enverus block_name deal_date_combined year month)

// Classify "temporary" transactions as non-treated because they are reversed right after deal closes
sort block_name year month
replace neutral_deal = 1 if block_name == "DIDON" & year==2015
replace interest_purchased = 0 if block_name == "DIDON" & year==2015 

replace neutral_deal = 1  if block_name == "EL JEM"
replace interest_purchased = 0 if block_name == "EL JEM" 

replace neutral_deal = 1 if block_name == "C-3"
replace interest_purchased = 0 if block_name == "C-3" 

replace neutral_deal = 1 if block_name == "OML 55" & deal_date_combined==td(05feb2015) | block_name == "OML 55" &  deal_date_combined==td(30jun2016)
replace interest_purchased = 0 if block_name == "OML 55" & deal_date_combined==td(05feb2015) | block_name == "OML 55" &  deal_date_combined==td(30jun2016)

gen month_date = ym(year, month) 
format month_date %tm

save "$clean_data/block_asset_transactions.dta", replace


********************************************************************************
********************** 2. CLEAN MONTHLY PRODUCTION DATA ************************
********************************************************************************

use "$clean_data/production_field_block_EPD.dta", clear

// Merge block and production data
merge 1:m field_name using "$raw_data/Production_monthly_field_well_level.dta", keep(1 3) nogen

// Generate production date variables
sort field_name MonthlyProductionDate
gen production_date = date(MonthlyProductionDate, "MDY")
format production_date %td
sort field_name production_date
gen month = month(production_date)
gen year = year(production_date)
sort block_name field_name year month

// Identify whether field and block operators are EPD reporting
gen EPD_field_operator = 0
replace EPD_field_operator = 1 if field_operator_reporting==1

gen EPD_block_operator = 0
replace EPD_block_operator = 1 if block_operator_reporting==1

// Drop variables that are not used
keep field_name block_name block_country contract_name tot_completed_wells area_block_sqkm operator_field_well block_operator ///
MonthlyProductionDate MonthlyOil MonthlyGas MonthlyWater WellCount Days DailyAvgOil DailyAvgGas DailyAvgWater WellNumber ProductionType ProductionStatus ///
ProducingMonthNumber production_date EPD_field_operator EPD_block_operator EntityType block_id_enverus year month Province ProducingMonthNumber

// Clean production variables
foreach v in DailyAvgOil DailyAvgGas MonthlyOil MonthlyGas area_block_sqkm WellCount ProducingMonthNumber {
	destring `v', replace
}
rename DailyAvgOil daily_avg_oil
rename DailyAvgGas daily_avg_gas
rename WellCount well_count
rename MonthlyOil monthly_oil
rename MonthlyGas monthly_gas
rename ProducingMonthNumber months_producing_since

// Drop observations with missing operator information
drop if operator_field_well == "NOT OPERATED"

// Since there is production data, there must be at least one well by definition
replace tot_completed_wells = 1 if tot_completed_wells==0  

// Generate total monthly output
gen tot_oilgas_output_month = monthly_oil
replace tot_oilgas_output_month = monthly_oil + monthly_gas if !missing(monthly_gas)
replace tot_oilgas_output_month = monthly_gas if missing(tot_oilgas_output_month)

// Generate average daily output
gen daily_avg_oil_gas = daily_avg_oil 
replace daily_avg_oil_gas = daily_avg_oil + daily_avg_gas if !missing(daily_avg_gas)
replace daily_avg_oil_gas = daily_avg_gas if missing(daily_avg_oil_gas)

// Normalize daily average output by (i) number of wells and (ii) area of block
gen daily_avg_oil_gas_per_well = daily_avg_oil_gas / well_count
gen daily_avg_oilgas_per_well_alt = daily_avg_oil_gas / tot_completed_wells
gen daily_avg_oilgas_per_sqkm = daily_avg_oil_gas / area_block_sqkm

// Generate indicators for hydrocarbon types
gen oil = 0
replace oil = 1 if !missing(daily_avg_oil)
gen gas = 0
replace gas = 1 if !missing(daily_avg_gas)

// Generate year-month variable
gen month_date = ym(year, month) 
format month_date %tm


********************************************************************************
*************** 3. AGGREGATE PRODUCTION DATA TO THE BLOCK LEVEL ****************
********************************************************************************
preserve

// Keep only field-level production data (to be aggregated at the block-level)
keep if EntityType=="FIELD"
encode field_name, gen(field_code)

// Tsset data at field-month level
tsset field_code month_date
tsfill

// Fill up field characteristics that are constant over time
local field_strings "field_name operator_field_well block_id_enverus block_name contract_name block_country block_operator Province EntityType"
local field_numeric "area_block_sqkm tot_completed_wells"

foreach s in `field_strings'{
	bys field_code (`s'): replace `s' = `s'[_N] if missing(`s')
}

foreach n in `field_numeric'{
	bys field_code (`n'): replace `n' = `n'[1] if missing(`n')
}

// Compute number of consecutive months for which production data is missing
bys field_code (month_date): gen spell = sum(missing(daily_avg_oilgas_per_well_alt) != missing(daily_avg_oilgas_per_well_alt[_n-1]))
bys field_code spell (month_date): gen spell_length = _N
bysort field_code (month_date) : gen seq = missing(daily_avg_oilgas_per_well_alt) & (!missing(daily_avg_oilgas_per_well_alt[_n-1]) | _n == 1) 
by field_code : replace seq = seq[_n-1] + 1 if missing(daily_avg_oilgas_per_well_alt) & seq[_n-1] >= 1 & _n > 1 
bys field_code spell: egen gap = max(seq)
bys field_code: egen largest_gap_field = max(gap)
bys block_id_enverus: egen largest_gap_block = max(largest_gap_field)

// Interpolate missing production data points (up to a maximum of 2 consecutive quarters)
rename tot_oilgas_output_month tot_oilgas_month
local interp_vars "tot_oilgas_month daily_avg_oilgas_per_well_alt months_producing_since"

foreach d in `interp_vars'{
	bys field_code (month_date): ipolate `d' month_date if gap <= 6, gen(`d'_ip)
}

// Identify blocks with data gaps larger than 2 consecutive quarters
gen blocks_excl_large_gaps = 0
replace blocks_excl_large_gaps = 1 if largest_gap_block > 6

save "$final_data/field_production_data_interpol_FINAL.dta", replace


// Aggregate monthly field-level production data to block level
collapse (mean) monthly_oil monthly_gas daily_avg_oilgas_per_well_alt daily_avg_oilgas_per_well_alt_ip months_producing_since months_producing_since_ip blocks_excl_large_gaps ///
(sum) tot_oilgas_month tot_oilgas_month_ip tot_completed_wells well_count (max) oil gas, ///
by(block_name block_id_enverus block_country area_block_sqkm block_operator month_date year month Province)

replace tot_oilgas_month=. if tot_oilgas_month==0 & missing(monthly_oil) & missing(monthly_gas)
replace tot_oilgas_month_ip=. if tot_oilgas_month_ip==0 & missing(monthly_oil) & missing(monthly_gas)

tempfile field_production_data
save `field_production_data'
restore

// Keep only contract-level production data
keep if EntityType=="CONTRACT" /* "EntityType" specifies the level of reporting. "CONTRACT" refers to blocks. */

// Clean-up block names and IDs
replace block_id_enverus = strtrim(block_id_enverus)
replace block_name = strtrim(block_name)
replace block_name = upper(block_name)
replace block_name = "ANAGUID" if block_name == "ANAGUID EST"
replace block_id = "1355000006" if block_id == "1355000215"
destring(block_id_enverus), replace
format block_id_enverus %20.0f

// Tsset data at block-month level
tsset block_id_enverus month_date
tsfill 

// Fill up characteristics that are constant over time
local block_strings "block_country block_name field_name contract_name block_operator Province"
local block_numeric "tot_completed_wells well_count WellNumber area_block_sqkm"

foreach v in `block_strings'{
	bys block_id_enverus (`v'): replace `v' = `v'[_N] if missing(`v')
}

foreach v in `block_numeric'{
	bys block_id_enverus (`v'): replace `v' = `v'[1] if missing(`v')
}

// Compute number of consecutive months for which production data is missing
tostring block_id_enverus, replace
bys block_id_enverus (month_date): gen spell = sum(missing(daily_avg_oilgas_per_well_alt) != missing(daily_avg_oilgas_per_well_alt[_n-1]))
bys block_id_enverus spell (month_date): gen spell_length = _N
bysort block_id_enverus (month_date) : gen seq = missing(daily_avg_oilgas_per_well_alt) & (!missing(daily_avg_oilgas_per_well_alt[_n-1]) | _n == 1) 
by block_id_enverus : replace seq = seq[_n-1] + 1 if missing(daily_avg_oilgas_per_well_alt) & seq[_n-1] >= 1 & _n > 1 
bys block_id_enverus spell: egen gap = max(seq)
bys block_id_enverus: egen largest_gap_block = max(gap)

// Identify blocks with data gaps larger than 2 consecutive quarters
gen blocks_excl_large_gaps = 0
replace blocks_excl_large_gaps = 1 if largest_gap_block > 6 

// Interpolate missing production data points (up to a maximum of 2 consecutive quarters)
rename tot_oilgas_output_month tot_oilgas_month
local interp_vars "tot_oilgas_month daily_avg_oilgas_per_well_alt months_producing_since"

foreach d in `interp_vars'{
	bys block_id_enverus (month_date): ipolate `d' month_date if gap<=6, gen(`d'_ip)
}

// Data is now aggregated at the block level. Drop all field-level variables
drop field_name operator_field_well EPD_field_operator 

// Append field-level data which has been aggregated at the block level (see code lines 262 to 316)
append using `field_production_data'


********************************************************************************
************ 4. MERGE ASSET TRANSACTIONS DATA AT BLOCK-MONTH LEVEL *************
********************************************************************************

merge m:1 block_id_enverus month_date using "$clean_data/block_asset_transactions.dta"

// Identify blocks with any asset transaction in the given month
gen any_deal = 0
replace any_deal = 1 if _merge==3
bys block_id_enverus: egen has_transaction = max(any_deal)
drop if _merge==2
drop _merge
sort block_name month_date

// Prepare variables for aggregation at quarterly level
gen year_quarter = qofd(dofm(month_date))
format year_quarter %tq
rename daily_avg_oilgas_per_well_alt daily_avg_oilgas_per_well_raw
rename tot_oilgas_month tot_oilgas_month_raw 

// Aggregate monthly data to quarters
collapse (mean) monthly_gas monthly_oil daily_avg_oilgas_per_well_alt_ip daily_avg_oilgas_per_well_raw ///
(max) any_deal oil gas operator_changed has_transaction (min) neutral_deal blocks_excl_large_gaps ///
(sum) tot_oilgas_quarter_ip=tot_oilgas_month_ip tot_oilgas_quarter_raw=tot_oilgas_month_raw interest_purchased ///
tot_completed_wells , ///
by(block_id_enverus block_name block_country area_block_sqkm block_operator year_quarter Province)

replace tot_oilgas_quarter_raw=. if tot_oilgas_quarter_raw==0 & missing(monthly_oil) & missing(monthly_gas)
replace tot_oilgas_quarter_ip=. if tot_oilgas_quarter_ip==0 & missing(monthly_oil) & missing(monthly_gas) & missing(daily_avg_oilgas_per_well_alt_ip)

replace neutral_deal = 1 if interest_purchased < 0

// Determine whether block is (i) purely oil, (ii) purely gas or (iii) both resource types
bys block_id_enverus: egen oil_block = max(oil)
bys block_id_enverus: egen gas_block = max(gas)
gen resource_type = ""
replace resource_type = "OIL" if oil_block==1 & gas_block==0
replace resource_type = "GAS" if gas_block==1 & oil_block==0
replace resource_type = "OIL & GAS" if gas_block==1 & oil_block==1

// Identify firms' headquarter countries
gen hq = ""
replace hq = "Senegal" if block_operator=="AFRICA FORTESA"
replace hq = "Nigeria" if block_operator=="AITEO CONSORTIUM"
replace hq = "Nigeria" if block_operator=="AMNI"
replace hq = "United States" if block_operator=="APO"
replace hq = "Nigeria" if block_operator=="ATLAS ORANTO"
replace hq = "Nigeria" if block_operator=="BELEMAOIL"
replace hq = "United Kingdom" if block_operator=="BP"
replace hq = "Nigeria" if block_operator=="BRITTANIA-U"
replace hq = "Sweden/Tunisia" if block_operator=="CFTP"
replace hq = "United States" if block_operator=="CHEVRON"
replace hq = "Nigeria" if block_operator=="CONOIL"
replace hq = "Tunisia" if block_operator=="CTKCP"
replace hq = "Nigeria" if block_operator=="DUBRI"
replace hq = "United Kingdom/Nigeria" if block_operator=="ELCREST"
replace hq = "Nigeria" if block_operator=="ENERGIA"
replace hq = "Italy" if block_operator=="ENI"
replace hq = "Nigeria" if block_operator=="EROTON"
replace hq = "Tunisia" if block_operator=="ETAP"
replace hq = "Tunisia" if block_operator=="EXXOIL"
replace hq = "United States" if block_operator=="EXXONMOBIL"
replace hq = "United States" if block_operator=="FRONTIER"
replace hq = "Netherlands" if block_operator=="GEOFINANCE"
replace hq = "Egypt" if block_operator=="HBS"
replace hq = "United Kingdom" if block_operator=="HERITAGE ENERGY"
replace hq = "Sweden" if block_operator=="LUNDIN PETROLEUM"
replace hq = "Canada/Tunisia" if block_operator=="MARETAP"
replace hq = "Netherlands" if block_operator=="MAZARINE"
replace hq = "Indonesia" if block_operator=="MEDCO"
replace hq = "Nigeria" if block_operator=="MIDWESTERN"
replace hq = "Nigeria" if block_operator=="MONI PULO"
replace hq = "Nigeria" if block_operator=="NECONDE"
replace hq = "Nigeria" if block_operator=="NEPN"
replace hq = "Nigeria" if block_operator=="NEWCROSS"
replace hq = "Nigeria" if block_operator=="NIGER DELTA"
replace hq = "Nigeria" if block_operator=="NNPC"
replace hq = "" if block_operator=="NOT OPERATED"
replace hq = "Austria" if block_operator=="OMV"
replace hq = "Nigeria" if block_operator=="ORIENTAL ENERGY"
replace hq = "United Kingdom" if block_operator=="PERENCO"
replace hq = "Nigeria" if block_operator=="PILLAR"
replace hq = "Nigeria" if block_operator=="PLATFORM"
replace hq = "Nigeria" if block_operator=="PLUSPETROL"
replace hq = "Nigeria" if block_operator=="PRIME"
replace hq = "Nigeria" if block_operator=="SAHARA GROUP"
replace hq = "india" if block_operator=="SANDESARA"
replace hq = "United Kingdom" if block_operator=="SEPLAT"
replace hq = "United Kingdom/Tunisia" if block_operator=="SEREPT"
replace hq = "United Kingdom" if block_operator=="SERINUS"
replace hq = "Nigeria" if block_operator=="SAVANNAH"
replace hq = "Netherlands" if block_operator=="SHELL"
replace hq = "China" if block_operator=="SINOPEC"
replace hq = "Italy/Tunisia" if block_operator=="SITEP"
replace hq = "Italy/Tunisia" if block_operator=="SODEPS"
replace hq = "Angola" if block_operator=="SOMOIL"
replace hq = "Angola" if block_operator=="SONANGOL"
replace hq = "France" if block_operator=="TOTAL"
replace hq = "United States" if block_operator=="TPS"
replace hq = "United Kingdom" if block_operator=="TULLOW"
replace hq = "Nigeria" if block_operator=="WALTERSMITH"
replace hq = "Nigeria" if block_operator=="YINKA FOLAWIYO"
replace hq = "United States" if block_operator=="ANGOLA LNG"	
replace hq = "United Kingdom" if block_operator=="ATOG"

// Trim production variables at 99th percentile
winsor2 daily_avg_oilgas_per_well_alt_ip, cuts(0 99) trim replace
winsor2 tot_oilgas_quarter_ip, cuts(0 99) trim replace

// Generate dependent variables
gen ln_daily_avg_oilgas_per_well = ln(daily_avg_oilgas_per_well_alt_ip)
gen ln_tot_oilgas_quarter = ln(tot_oilgas_quarter_ip)

// Generate post period indicator
gen post_2013 = 0
replace post_2013 = 1 if year_quarter>=tq(2014q1)

// Identify license acquisitions by non-EPD firms
gen non_epd_deal = 0
replace non_epd_deal = 1 if neutral_deal !=1 & any_deal == 1 

// Identify year-quarter of license acquisitions
gen deal_date = year_quarter if any_deal==1
bys block_id_enverus: egen first_deal_date = min(deal_date)
format deal_date first_deal_date %tq

gen non_epd_deal_date = year_quarter if any_deal==1 & non_epd_deal==1
bys block_id_enverus: egen first_non_epd_deal_date = min(non_epd_deal_date)
format non_epd_deal_date first_non_epd_deal_date %tq

// Generate "Acquired Share" variable 
gen ln_interest_purchased = ln(interest_purchased) if any_deal == 1 & neutral_deal != 1
bys block_id_enverus (year_quarter): replace ln_interest_purchased = ln_interest_purchased[_n-1] if year_quarter > first_non_epd_deal_date
replace ln_interest_purchased = 0 if missing(ln_interest_purchased)

// Identify block ownership changes
gen OC = 0
replace OC = 1 if year_quarter >= first_deal_date

// Identify license acquisitions by non-EPD firms
gen OC_non_EPD = 0
replace OC_non_EPD = 1 * ln_interest_purchased if year_quarter >= first_non_epd_deal_date

// Identify block ownership changes in the post period
gen OC_post_2013 = 0
replace OC_post_2013 = 1 if OC==1 & first_deal_date >= tq(2014q1)

// Identify license acquisitions by non-EPD firms in the post period
gen OC_non_EPD_post_2013 = 0
replace OC_non_EPD_post_2013 = 1 * ln_interest_purchased if year_quarter>=first_non_epd_deal_date & first_non_epd_deal_date>=tq(2014q1)

// Identify treated blocks (i.e., blocks with at least 1 acquisition by non-EPD firms in the post-period)
bys block_id_enverus: egen treated = max(OC_non_EPD_post_2013)

// Define regression sample
keep if year_quarter >= tq(2010q1) & year_quarter <= tq(2017q4) & blocks_excl_large_gaps == 0

// Generate fixed effects
egen block_FE = group(block_id_enverus)
egen resourcetype_yrqt_FE = group(resource_type year_quarter)

// Label variables
label var ln_daily_avg_oilgas_per_well "Ln(Output per Well)"
label var ln_interest_purchased "Ln(Acquired Share)"
label var ln_tot_oilgas_quarter "Ln(Total Output)"
label var non_epd_deal "Non-EPD Firm Entry"
label var OC_non_EPD_post_2013 "Non-EPD Firm Entry $\times$ Post 2013 $\times$ Ln(Acquired Share)"
label var OC_non_EPD "OC $\times$ Non-EPD Acquiror"
label var OC_post_2013 "OC $\times$ Post 2013"
label var post_2013 "Post 2013"
label var OC "OC"


// Save merged and cleaned productivity dataset
save "$final_data/block_entry_analysis_clean_FINAL.dta", replace

********************************************************************************
******                                                                   *******
******             ARTICLE: Extraction Payment Disclosures               *******
******             AUTHOR: Thomas Rauter                                 *******
******             JOURNAL OF ACCOUNTING RESEARCH                        *******
******             CODE TYPE: Clean and Standardize Company Names        *******
******             LAST UPDATED: August 2020                             *******
******                                                                   *******
********************************************************************************

// Clean company names
gen company_cleaned = company

replace company_cleaned = subinstr(company_cleaned,"LLC","",.) 
replace company_cleaned = subinstr(company_cleaned,"LLP","",.) 
replace company_cleaned = subinstr(company_cleaned,"AS","",.) 
replace company_cleaned = subinstr(company_cleaned,"Ltd","",.) 
replace company_cleaned = subinstr(company_cleaned,"JSC","",.) 
replace company_cleaned = subinstr(company_cleaned,"ХХК","",.) 
replace company_cleaned = subinstr(company_cleaned,"LIMITED","",.) 
replace company_cleaned = subinstr(company_cleaned,"(ХХК)","",.) 
replace company_cleaned = subinstr(company_cleaned,"Limited","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD","",.) 
replace company_cleaned = subinstr(company_cleaned,"SPRL","",.) 
replace company_cleaned = subinstr(company_cleaned,"SA","",.)
replace company_cleaned = subinstr(company_cleaned,"SARL","",.) 
replace company_cleaned = subinstr(company_cleaned,"ASA","",.) 
replace company_cleaned = subinstr(company_cleaned,"PLC","",.) 
replace company_cleaned = subinstr(company_cleaned,"Corporation","",.) 
replace company_cleaned = subinstr(company_cleaned,"Company","",.) 
replace company_cleaned = subinstr(company_cleaned,"Ltd.","",.) 
replace company_cleaned = subinstr(company_cleaned,"SAS","",.) 
replace company_cleaned = subinstr(company_cleaned,"Plc","",.) 
replace company_cleaned = subinstr(company_cleaned,"B.V.","",.) 
replace company_cleaned = subinstr(company_cleaned,"Inc.","",.) 
replace company_cleaned = subinstr(company_cleaned,"MINING","",.) 
replace company_cleaned = subinstr(company_cleaned,"S.A.","",.) 
replace company_cleaned = subinstr(company_cleaned,"COMPANY","",.) 
replace company_cleaned = subinstr(company_cleaned,"JSC*","",.) 
replace company_cleaned = subinstr(company_cleaned,"AS2)","",.) 
replace company_cleaned = subinstr(company_cleaned,"International","",.) 
replace company_cleaned = subinstr(company_cleaned,"CORPORATION","",.) 
replace company_cleaned = subinstr(company_cleaned,"Inc","",.) 
replace company_cleaned = subinstr(company_cleaned,"Resources","",.) 
replace company_cleaned = subinstr(company_cleaned,"plc","",.) 
replace company_cleaned = subinstr(company_cleaned,"(ХК)","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD.","",.) 
replace company_cleaned = subinstr(company_cleaned,"NUF","",.) 
replace company_cleaned = subinstr(company_cleaned,"ХК","",.) 
replace company_cleaned = subinstr(company_cleaned,"B.V","",.) 
replace company_cleaned = subinstr(company_cleaned,"DRC","",.) 
replace company_cleaned = subinstr(company_cleaned,"Branch","",.) 
replace company_cleaned = subinstr(company_cleaned,"C","",.) 
replace company_cleaned = subinstr(company_cleaned,"Co.","",.) 
replace company_cleaned = subinstr(company_cleaned,"Incorporated","",.) 
replace company_cleaned = subinstr(company_cleaned,"Group","",.) 
replace company_cleaned = subinstr(company_cleaned,"S.A","",.) 
replace company_cleaned = subinstr(company_cleaned,"COMPAGNY","",.) 
replace company_cleaned = subinstr(company_cleaned,"INC","",.) 
replace company_cleaned = subinstr(company_cleaned,"LTD**","",.) 
replace company_cleaned = subinstr(company_cleaned,"A/S","",.) 

replace company_cleaned = rtrim(company_cleaned)
replace company_cleaned = ltrim(company_cleaned)
replace company_cleaned = strtrim(company_cleaned)
replace company_cleaned = strltrim(company_cleaned)
replace company_cleaned = stritrim(company_cleaned)
replace company_cleaned = strrtrim(company_cleaned)

replace company_cleaned = subinstr(company_cleaned, char(34),"",.)
replace company_cleaned = subinstr(company_cleaned," ","",.) 
replace company_cleaned = subinstr(company_cleaned,".","",.) 
replace company_cleaned = subinstr(company_cleaned,",","",.) 
replace company_cleaned = subinstr(company_cleaned,"(","",.) 
replace company_cleaned = subinstr(company_cleaned,")","",.)
replace company_cleaned = subinstr(company_cleaned,"&","",.)
replace company_cleaned = subinstr(company_cleaned,"*","",.) 
replace company_cleaned = subinstr(company_cleaned,"-","",.) 
replace company_cleaned = subinstr(company_cleaned,"'","",.) 
replace company_cleaned = subinstr(company_cleaned,"´","",.) 
replace company_cleaned = subinstr(company_cleaned,"`","",.) 
replace company_cleaned = subinstr(company_cleaned,"̂","",.)

replace company_cleaned = subinstr(company_cleaned,"è","e",.) 
replace company_cleaned = subinstr(company_cleaned,"é","e",.) 
replace company_cleaned = subinstr(company_cleaned,"é","e",.) 
replace company_cleaned = subinstr(company_cleaned,"É","E",.) 

replace company_cleaned = upper(company_cleaned)

********************************************************************************
******                                                                   *******
******           ARTICLE: Extraction Payment Disclosures                 *******
******           AUTHOR: Thomas Rauter                                   *******
******           JOURNAL OF ACCOUNTING RESEARCH                          *******
******           CODE TYPE: Clean and Standardize Country Names          *******
******           LAST UPDATED: August 2020                               *******
******                                                                   *******
********************************************************************************

kountry segment_description, from(other) marker

*Replace country names that are misspelt
rename segment_description IN 
rename NAMES_STD NAMES

replace NAMES="China" if IN=="/CHINA " | IN=="/CHINA" | IN=="B&Q CHINA SALES" | ///
	IN=="BEIJING" | IN=="CHINA EX HONG KONG AND MACAU " | ///
	IN=="CHINA INLAND" |  IN=="CHINA(EXCEPT HONGKONG,TAIWAN)" | ///
	IN=="CHINA-SHENZHEN" | IN=="CHINESE MAINLAND" | IN=="EAST CHINA" | ///
	IN=="EASTERN CHINA" | IN=="ELSEWHERE IN PRC" | IN=="ELSEWHERE IN THE PRC" | ///
	IN=="ELSWHERE IN THE PRC" | IN=="GREAT CHINA" | IN=="GREATER CHINA" | ///
	IN=="GUANGDONG" | IN=="GUANGXI (AUTONOMOUS REGION)" |  ///
	IN=="MAINLANC CHINA" | IN=="MAINLAND CHINA" | ///
	IN=="MAINLAND PRC" | IN=="NORTH CHINA" | IN=="NORTHEASTERN CHINA" | ///
	IN=="NORTHERN CHINA" | IN=="OTHER PARTS OF CHINA" | ///
	IN=="OTHER PARTS OF PRC" | IN=="OTHER REGION IN PRC" | IN=="OTHER REGIONS IN PR" | ///
	IN=="OTHER REGIONS IN PRC" | IN=="OTHER REGIONS IN THE PRC" | ///
	IN=="P R CHINA"| IN=="P. R. CHINA" | IN=="P.R. CHINA" | IN=="P.R. OF CHINA" | ///
	IN=="P.R.CHINA" | strpos(IN, "REPUBLIC OF CHINA") | IN=="PEOPLE'S REPUBLIC'S OF CHINA" | ///
	IN=="PEOPLES REPUBLIC OF" | IN=="PEOPLES REPUBLIC OF C" | IN=="PEOPLES REPUBLIC OF CHINA" | ///
	IN=="PRC" | IN=="PRC (DOMICILE)" | IN=="PRC (OTHER THAN HONG KONG)" | IN=="PRC EXCEPT HONG KONG" | ///
	IN=="PRC MAINLAND" | IN=="PRC OTHER THAN HONG KONG,MACAO & TAIWAN" | ///
	IN=="REGIONS IN THE PRC OTH THAN HK AND MACAU" | IN=="REPUBLIC OF CHINA" | IN=="REST OF PRC" | ///
	IN=="REST OF PRC & OTHER" | IN=="REST OF PRC AND OTHERS" | IN=="SHANDONG PROVINCE" | ///
	IN=="SHANGHAI" | IN=="SHANXI PROVINCE" | IN=="SOUTH CHINA" | IN=="SOUTHERN CHINA" | ///
	IN=="THE  PRC" | IN=="THE MAINLAND CHINA" | IN=="THE PEOPLE'S REPUBLIC OF CHINA" | ///
	IN=="THE PRC" | IN=="THE PRC EXCL HONGKONG" | IN=="THE PRC OTHER THAN" | ///
	IN=="THE PRC OTHER THAN HONG KONG AND MACAU" | IN=="WEST CHINA" | ///
	IN=="WESTERN CHINA" | IN=="WITHIN PRC" | IN=="XINJIANG PROVINCE" | IN=="CENTRAL CHINA" | ///
	IN=="OTHER REGIONS OF MAINLAND CHINA" | IN=="PEOPLE OF REPUBLIC CHINA" 
replace NAMES="Hong Kong" if IN=="HK" | IN=="HONG KONG & CORPORATE" | IN=="HONG KONG SAR" | ///
	IN=="HONG KONG, SAR" | IN=="OTHER HK"
replace NAMES="Macao" if IN=="MACAU OPERATIONS"
replace NAMES="Taiwan" if IN=="TAIWAN, REPUBLIC OF"
replace NAMES="India" if IN=="ANDHRA PRADESH" | IN=="CHHATTISGARH" | ///
	IN=="DISCONTINUED OPERATIONS- INDIA"  | IN=="ELIMINATIONS/INDIA" | IN=="IN INDIA" | ///
	IN=="INDIA REGION" | IN=="INDIAN OPERATIONS" | IN=="INDIAN SUB-CONTINENT" | ///
	IN=="INIDA" | IN=="JAMMU" | IN=="SALES WITHIN INDIA" | IN=="WITH IN INDIA" | ///
	IN=="WITH-ININDIA" | IN=="WITHIN INDIA" | IN=="WTIHIN INDIA" | IN=="ANDHRA PRADESH" | ///
	IN=="INDAI"
replace NAMES="UAE" if IN=="ABU DHABI (EMIRATE)" | IN=="DUBAI" | ///
	IN=="DUBAI (EMIRATE)" | IN=="EMIRATES" | IN=="NORTHERN EMIRATES" | ///
	IN=="UNITED ARAB EMIRATE" | IN=="UNITED ARAB EMIRATESZ" | ///
	IN=="ABU DHABI (EMIRATE)"
replace NAMES="Canada" if IN=="ALBERTA" | IN=="BRITISH COLUMBIA" | ///
	IN=="CANADA - BACK WATER PROJECT" | IN=="CANADA - NEW AFTON" | ///
	IN=="CANADA- OPERATING SEGMENT" | IN=="CANADA- RAINY RIVER" | ///
	IN=="CANADIAN" | IN=="CANADIAN OILFIELD SERVICES" | ///
	IN=="CANADIAN OPERATIONS" | IN=="CANANDA" | IN=="CANDA" | ///
	IN=="CHILDREN'S PLACE CANADA" | IN=="OTHER CANADIAN OPERATIONS" | ///
	IN=="RED LAKE - CANADA" | IN=="ROCKY MOUNTAINS" | IN=="SASKATCHEWAN" | ///
	IN=="SOUTHERN ONTARIO" | IN=="SYNCRUDE" | IN=="WESTERN CANADA" | ///
	IN=="ALBERTA"
replace NAMES="United States" if IN=="AMERICA" | IN=="ALASKA" | ///
	IN=="AHOLD USA" | IN=="AMERICAN OPERATIONS" | ///
	IN=="AMERICAN REGION" | IN=="AMERICAN ZONE" | ///
	IN=="AMRERICANS" | IN=="ATLANTA" | ///
	IN=="CENTRAL UNITED STATES (DIVISION)" | ///
	IN=="CHICAGO" | IN=="CHILDREN'S PLACE UNITED STATES" | ///
	IN=="CONTINENTAL US" | IN=="CORPORATE & TRADICO (U.S.)" | ///
	IN=="DALLAS" | IN=="DELAWARE" | IN=="DENVER" | IN=="DETROIT" | ///
	IN=="EAST TEXAS/LOUISIANA" | IN=="EASTERN UNITED STATES (DIVISION)" | ///
	IN=="HOUSTON" | IN=="LAS VEGAS OPERATIONS" | IN=="LOS ANGELES" | ///
	IN=="MARYLAND" | IN=="MIDDLE AMERICA" | IN=="MIDSTREAM UNITED STATES" | ///
	IN=="NEW MEXICO" | IN=="NEW YORK" | IN=="NORTHEAST UNITED STATES (DIVISION)" | ///
	IN=="NORTHERN VIRGINI" | IN=="OKLAHOMA" | IN=="PLP-USA" | ///
	IN=="REGIONAL UNITED STATES" | IN=="SAN DIEGO" | IN=="SAN FRANCISCO BAY" | ///
	IN=="SAO FRANCISCO MINE" | IN=="LASALLE INVESTMENT MANAGEMENT SERVICES" | ///
	IN=="LUMMUS" | IN=="MARCELLUS SHALE" | IN=="PICEANCE BASIN" | ///
	IN=="SOUTH UNITED STATES (DIVISION)" | IN=="SOUTHERN VIRGINIA" | ///
	IN=="STAMFORD / NEW YORK" | IN=="T.R.N.C." | IN=="TEXAS" | IN=="TEXAS (STATE)" | ///
	IN=="TEXAS PANHANDLE" | IN=="U S A" | IN=="U. S. MEDICAL" | ///
	IN=="U.S - MESQUITE MINE" | IN=="U.S. & POSSESSIONS" | IN=="U.S. DOMESTIC" | ///
	IN=="U.S. GULF OF MEXICO" | IN=="U.S. OPERATIONS" | IN=="UINITED STATES" | ///
	IN=="UINITED STATES" | IN=="UMITED STATES" | IN=="UNIRED STATES" | ///
	IN=="UNITATED STATES" | IN=="UNITE STATES" | IN=="UNITED  STATE" | ///
	IN=="UNITED SATES" | IN=="UNITED STAES" | IN=="UNITED STARES" | ///
	IN=="UNITED STATE" | IN=="UNITED STATED" | ///
	IN=="UNITED STATES                      UNITE" | IN=="UNITED STATES / DOMESTIC" | ///
	IN=="UNITED STATES AMERICA"  | IN=="UNITED STATES AND ITS TERRITORIES" | ///
	IN=="UNITED STATES OF AM" | IN=="UNITED STATES OF AMER" | ///
	IN=="UNITED STATES OILFIELD SERVICES" | IN=="UNITED STATES OPERATIONS" | ///
	IN=="UNITED STATESS" | IN=="UNITES STATES" | IN=="UNITTED STATES" | ///
	IN=="UNTIED STATES" | IN=="US GULF" | IN=="US WEST" | IN=="US- AMESBURYTRUTH" | ///
	IN=="USA (NAFTA)" | IN=="USA EXPLORATION" | IN=="USA PRODUCTION"  | ///
	IN=="UUNITED STATES" | IN=="WASHINGTON (D.C)" | IN=="WEST UNITED STATES (DIVISION)" | ///
	IN=="WHARF - UNITED STATES" | IN=="WYNN BOSTON HARBOR" | IN=="CENTRAL APPALACHIA" | ///
	IN=="UINTED STATES" | IN=="WILLISTON BASIN" | IN=="AHOLD USA" | IN=="ALASKA"
replace NAMES="Germany" if IN=="AIRLINE GERMANY" | IN=="DEUTSCHLAND" | ///
	IN=="GEMANY" | IN=="GERMAN LANGUAGE COUNT"	| IN=="GERMAN MARKET" | ///
	IN=="GERMANY - LYING SYSTEMS" | IN=="GERMANY - SURFACE CARE" | ///
	IN=="GERMANY RETAIL" | IN=="GERMEN" | IN=="NORTHERN GERMANY" | ///
	IN=="PARENT COMPANY - GERMANY" | IN=="SOUTHERN GERMANY" | IN=="AIRLINE GERMANY" | ///
	IN=="GERMAN OPERATIONS"
replace NAMES="Argentina" if IN=="ALUMBERA - ARGENTINA" | IN=="MISC ARGENTINA" | ///
	IN=="ARGENTINA-OIL GAS" | IN=="ALUMBERA - ARGENTINA"
replace NAMES="Russia" if IN=="AMURSK ALBAZINO" | IN=="INTERNATIONAL OPERATION/RUSSIA" | ///
	IN=="MOSCOW" | IN=="MOSCOW AND  MOSCOW RE" | IN=="RUSSIA  - MOBILE" | ///
	IN=="RUSSIA FIXED" | IN=="RUSSIAN" | IN=="RUSSIAN FEDERATIONS" | ///
	IN=="SALES IN RUSSIA" | IN=="KRASNOYARSK BUSINESS UNIT" | IN=="KYZYL" | ///
	IN=="MAGADAN BUSINESS UNIT" | IN=="MAYSKOYE" | IN=="OKHOTSK" | IN=="OMOLON" | ///
	IN=="ST. PETERSBURG" | IN=="YAKUTSK KURANAKH BUSINESS UNIT"
replace NAMES="Jordan" if IN=="AQABA" | IN=="INSIDE JORDAN" | IN=="JORDAN EXCEPT AQABA"
replace NAMES="Egypt" if IN=="ARAB REPUBLIC OF EGYPT"
replace NAMES="Mexico" if IN=="ARANZAZU MINES" | IN=="MEXCIO" | IN=="MEXICO (AMERICAS)" | ///
	IN=="OTHER INTERNATIONAL(MEXICO)" | IN=="PENASQUITO" 
replace NAMES="Australia" if IN=="AUATRALIA" | IN=="AUSTALIA" | ///
	IN=="AUSTRALIA EXPLORATION" | IN=="AUSTRALIA PACIFIC" | ///
	IN=="AUSTRALIA PRODUCTION" | IN=="AUSTRALIAN" | ///
	IN=="AUSTRALIAN CAPITAL TERRITORY" | IN=="AUSTRALIAN OPEARTIONS" | ///
	IN=="AUTRALIA" | IN=="CORPORATE AUSTRALIA" | IN=="GULLEWA" | ///
	IN=="OTHER AUSTRALIA" | IN=="RECTRON AUSTRALIA" | IN=="NEW SOUTH WALES" | ///
	IN=="QUEENSLAND" | IN=="QUEENSLAND." | IN=="SOUTH AUSTRALIA" | IN=="WESTERN AUSTRALIA" | ///
	IN=="EASTERN AUSTRALIA"
replace NAMES="Austria" if IN=="AUSTRIA (HOLDING)"
replace NAMES="Bahrain" if IN=="BAHARAIN"
replace NAMES="Bangladesh" if IN=="BANGALDESH"
replace NAMES="Guinea" if IN=="BAOULE - GUINEA"
replace NAMES="Barbados" if IN=="BARBODOS"
replace NAMES="Indonesia" if IN=="BEKASI" | IN=="CAKUNG" | IN=="CIKANDE" | ///
	IN=="DKI JAKARTA" | IN=="INDONESIAN" | IN=="INDONSIA" | ///
	IN=="REPUBLIC OF INDONESIA" | IN=="JABODETABEK" | IN=="JAKARTA" | ///
	IN=="JAKARTA AND BOGOR" | IN=="JAVA ISLAND" | IN=="JAVA ISLAND (EXC. JAKARTA)" | ///
	IN=="JAWA" | IN=="JAWA (EXCLUDING JAKARTA)" | IN=="JAWA, BALI DAN NUSA TENGGARA" | ///
	IN=="JAWA, BALI DAN NUSA TENGGARA" | IN=="JAWA-BALI" | IN=="JAYAPURA" | ///
	IN=="KALIMANTAN" | IN=="KALIMANTAN,SULAWESI & MALUKU" | IN=="MAKASSAR" | IN=="MEDAN" | ///
	IN=="PALEMBANG" | IN=="PASURUAN" | IN=="PONDOK CABE" | IN=="PURWAKARTA" | ///
	IN=="SEMARANG" | IN=="SERANG" | IN=="SULAWESI AND MALUKU" | IN=="SULAWESI DAN PAPUA" | ///
	IN=="SUMATERA" | IN=="TANGERANG" | IN=="THE REPUBLIC OF INDONESIA" | IN=="BALI AND LOMBOK ISLAND" | ///
	IN=="EAST JAVA" | IN=="BANDUNG"
replace NAMES="Belarus" if IN=="BELORUSSIA" | IN=="REPUBLIC OF BELARUS" | IN=="BELAUS"
replace NAMES="Bulgaria" if IN=="BOLGARIA"
replace NAMES="Bosnia and Herzegovina" if IN=="BOSNIA AND  HERZEGOVI" | ///
	IN=="BOSNIA AND HERZEGOVIN"
replace NAMES="France" if IN=="BOURGOGNE (METROPOLITAN REGION)" | ///
	IN=="EUROPE (REGION)-FRANCE " | IN=="FBB FRANCE" | IN=="FRANCE & DOM-TOM" | ///
	IN=="FRANCE & TERRITORIES" | IN=="FRANCE (DOM)" | IN=="FRANCE (REUNION ISLAND)" | ///
	IN=="FRANCE (REUNION ISLAND)" | IN=="FRANCE WITH DOM-TOM" | IN=="FRANCE/DOM-TOM" | ///
	IN=="FRENCH OVERSEAS DOMINIONS & TERRITORIES" | IN=="FRENCH OVERSEAS TERRITORIES" | ///
	IN=="LE-DE-FRANCE (METROPOLITAN REGION)" | IN=="PARIS" | ///
	IN=="PROVENCE-ALPES-C TE-D'AZUR (METROPOLITAN REGION)" | IN=="PIXMANIA" | ///
	IN=="RH NE ALPES (METROPOLITAN REGION)" | IN=="FRANCE - RENTAL PROPERTIES" | ///
	IN=="FRENCH"
replace NAMES="Brazil" if IN=="BRASIL" | IN=="BRAZIL/EXPORT" | IN=="BRAZILIAN MINES" | ///
	IN=="BRAZIL DRILLING OPERATIONS" | IN=="BRAZIL EXPLORATION & EVALUATION" | IN=="BRAZIL/IMPORTS"
replace NAMES="United Kingdom" if IN=="BRITAIN" | IN=="BRITIAN" | IN=="INTERNATIONAL (UK)" | ///
	IN=="U.K. AND ELIMINATION" | IN=="UK BUS (LONDON)" | IN=="UK BUS (REGIONAL OPERATIONS)" | ///
	IN=="UK RAIL" | IN=="UK RETAIL" | IN=="UNITED  KINDOM" | IN=="UNITED KINDOM" | ///
	IN=="UNITED KINGDOM (INCLUDING EXPORTS)" | IN=="UNITED KINGDOM - CONTINUING" | ///
	IN=="UNITED KINGDOM - INVESTING ACTIVITIES" | IN=="UNITED KINGDOM- OPERATING SEGMENT" | ///
	IN=="UNITED KINGDOM/BVI" | IN=="UNITED KINGDON" | IN=="UNITED KINGSOM" | IN=="XANSA" | ///
	IN=="UNITED KIGDOM" | IN=="GREAT BRITAN" | IN=="GREAT BRITIAN" | IN=="REST OF UK" | ///
	IN=="UK OPERATIONS"
replace NAMES="British Virgin Islands" if IN=="BRITISH VIRGIN ISLAND" | IN=="BVI"
replace NAMES="Belgium" if IN=="BRUSSELS" | IN=="FLANDERS" | IN=="WALLONIA"
replace NAMES="Israel" if IN=="BUILDINGS FOR SALE IN ISRAEL" | IN=="ISRAEL - RENTAL PROPERTIES"
replace NAMES="Tanzania" if IN=="BULYANHULU" | IN=="BUZWAGI" | IN=="NORTH MARA" | ///
	IN=="TANZANIA - AGRICULTURE & FORESTRY" | IN=="TANZANIA - EXPLORATION & DEVELOPMENT" | ///
	IN=="TULAWAKA"
replace NAMES="Burkina Faso" if IN=="BURKINA FASOFASO" 
replace NAMES="Chile" if IN=="CABECERAS" | IN=="CHILE - ELMORRO PROJECT" | ///
	IN=="LATAM" | IN=="LATAM OPERATIONS" | IN=="LATAM."
replace NAMES="Cambodia" if IN=="CAMBODGE" | IN=="KINGDOM OF CAMBODIA"
replace NAMES="Cameroon" if IN=="CAMEROON, UNITED REPUBLIC OF" | ///
	IN=="REPUBLIC OF CAMEROON"
replace NAMES="Turkey" if IN=="CAYELI (TURKEY)" | IN=="TURKEY OPERATIONS" | ///
	IN=="TURKISH REPUBLIC" | IN=="TURKISH REPUBLIC OF NORTHERN CYPRUS" | IN=="TURKY"
replace NAMES="Japan" if IN=="CENTRAL JAPAN" | IN=="EASTERN JAPAN" | ///
	IN=="JAPAN EAST" | IN=="JAPAN WEST" | IN=="JAPANP" | IN=="JAPNA" | ///
	IN=="OPERATING SEGEMENT-JAPAN" | IN=="WEST JAPAN" | IN=="JAPAN OPERATION"
replace NAMES="England" if IN=="CENTRAL LONDON" | IN=="DORSET" | ///
	IN=="LONDON" | IN=="LONDON & SOUTH" | IN=="SLAD" | IN=="SOUTHERN ENGLAND EXPLORATION" | ///
	IN=="THAMES VALLEY" | IN=="THAMES VALLEY AND THE REGIONS" | IN=="CENTRAL LONDON" | ///
	IN=="DORSET" 
replace NAMES="Norway" if IN=="CENTRAL NORWAY" | IN=="MEKONOMEN NORWAY" | ///
	IN=="MID-NORWAY" | IN=="NORTH-NORWAY" | IN=="NORTHERN NORWAY" | IN=="MALM" | ///
	IN=="THE OSLO FJORD"
replace NAMES="Colombia" if IN=="COLUMBIA"
replace NAMES="Congo" if IN=="CONGO-BRAZZAVILLE / REPUBLIC OF CONGO" | ///
	IN=="REPUBLIC OF CONGO" | IN=="REPUBLIC OF THE CONGA" | IN=="REPUBLIC OF THE CONGO" | ///
	IN=="CONGO-BRAZZAVILLE / REPUBLIC OF CONGO" | IN=="REPUBLIC OF CONGO"
replace NAMES="Democratic Republic of Congo" if IN=="DR CONGO" | IN=="DRC"
replace NAMES="Ivory Coast" if strpos(IN, "IVOIRE") | IN=="IVORY COASTIVORY CO" | ///
	IN=="VORY COAST"
replace NAMES="Croatia" if IN=="CROTATIA" | IN=="CROTIA" | IN=="REPUBLIC OF CROATIA"
replace NAMES="Czech Republic" if IN=="CZECH REPUBLIC TOTAL" | IN=="CZECH REPUBLIC LOTTERY" | ///
	IN=="CZECH REPUBLIC SPORTS BETTING"
replace NAMES="Dominican Republic" if IN=="DOMINICAN REPB."
replace NAMES="Malaysia" if IN=="EAST MALAYSIA" | IN=="MALAYSIA (ASIA)" | ///
	IN=="MALAYSIA(DOMESTIC)" | IN=="MALAYSIA/LOCAL" | IN=="MALAYSIAN OPERATIONS" | ///
	IN=="NALAYSIA" | IN=="WEST MALAYSIA" | IN=="WITHIN MALAYSIA"
replace NAMES="Timor-Leste" if IN=="EAST TIMOR / TIMOR-LESTE"
replace NAMES="Uruguay" if IN=="URUGUAY DRILLING OPERATIONS"
replace NAMES="Spain" if IN=="EL SAUZAL" | IN=="LAS CRUCES(SPAIN)" | ///
	IN=="SPAIN - DISC. OP."
replace NAMES="Ethiopia" if IN=="ETHOPIA"
replace NAMES="Finland" if IN=="FINLAND (DISCONTINUED OPERATIONS)" | ///
	IN=="FINLAND/OUTOKUMPU" | IN=="FINNLAND" | IN=="OTHER FINLAND" | ///
	IN=="PYHASALMI (FINLAND)" | IN=="REST OF FINLAND" | IN=="RAUMA"
replace NAMES="Guiana" if IN=="FRENCH GUYANA" | IN=="FRENCH GUYANE" | ///
	IN=="FRENCH GUIANA (DEPENDENT TERRITORY)"
replace NAMES="Greece" if IN=="GEECE" | IN=="GREEK"
replace NAMES="Greenland" if IN=="GREEN LAND"
replace NAMES="Guatemala" if IN=="GUATEMAL"
replace NAMES="Sweden" if IN=="HELSINGBORG" | IN=="HUDDINGE" | IN=="OTHER SWEDEN" | ///
	IN=="LIDINGO" | IN=="LUND" | IN=="SOUTHERN STOCKHOLM" | IN=="STOCKHOLM" | ///
	IN=="SWEDEN- OPERATING SEGMENT" | IN=="WESTERN STOCKHOLM" | IN=="HELSINGFORS"
replace NAMES="Netherlands" if IN=="HOLAND" | IN=="THE NETHERLAND"
replace NAMES="Hungary" if IN=="HUNGARIAN"
replace NAMES="Switzerland" if IN=="INDIVIDUAL LIFE SWITZERLAND" | IN=="SWIZERLAND" | ///
	IN=="SWIZTERLAND"
replace NAMES="Kuwait" if IN=="INSIDE KUWAIT" | IN=="STATE OF KUWAIT"
replace NAMES="South Africa" if IN=="INTRA- SEGMENTAL SOUTH AFRICA" | ///
	IN=="REPUBLIC OF SOUTH AFRICA" | IN=="KWAZULU-NATAL" | IN=="SOUTH AFRICA (VODACOM" | ///
	IN=="SOUTH AFRICA (VODACOM)" | IN=="GAUTENG"
replace NAMES="Kazakhstan" if IN=="KAZAKHISTAN" | IN=="KAZACHSTAN" | ///
	IN=="KAZAKHSTHAN BUSINESS UNIT" | IN=="REP OF KAZAKHSTAN" | ///
	IN=="REPUBLIC OF KAZAKHSTAN"
replace NAMES="Saudi Arabia" if strpos(IN, "KINGDOM OF SAUDI ARA") | ///
	IN=="SAUDI" | IN=="SAUDI AERABIA" | IN=="SAUDI ARAB" | IN=="SAUDI ARBIA" 
replace NAMES="Thailand" if IN=="KINGDOM OF THAILAND" | IN=="THAILLAND"
replace NAMES="Sierra Leone" if IN=="KONO - SIERRA LEONE" | IN=="SIERRA LOENE"
replace NAMES="South Korea" if IN=="KOREA(SOUTH)" | IN=="OTHER FOREIGN-SOUTH KOREA" 
replace NAMES="North Korea" if IN=="KOREA, DEMOCRATIC REBUCLIC OF KOREA"
replace NAMES="Iraq" if	IN=="KURDISTAN REGION OF IRAQ" | IN=="NORTHERN IRAQ"
replace NAMES="Libya" if IN=="LIBIA" | IN=="LYBIA"
replace NAMES="Lithuania" if IN=="LITHUENIA" | IN=="LITHUNIA"
replace NAMES="Madagascar" if IN=="MADAGASKAR"
replace NAMES="Mongolia" if IN=="MANGOLIA"
replace NAMES="Mauritius" if IN=="MAUTITIUS" | IN=="REPUBLIC OF MAURITIUS"
replace NAMES="Pakistan" if IN=="MIDDLE EAST- PAKISTAN" | ///
	IN=="PAKISTHAN"
replace NAMES="Morocco" if IN=="MORROCCO"
replace NAMES="Kenya" if IN=="MOUNT KENYA REGION" | IN=="WEST KENYA REGION" | ///
	IN=="NAIROBI REGION"
replace NAMES="Myanmar" if IN=="MYAMAR" | IN=="UNION OF MYANMAR"
replace NAMES="Namibia" if IN=="NAMIBIAN"
replace NAMES="Netherlands" if IN=="NETHERLAND" | IN=="NETHERLANDS (EUROPE)"
replace NAMES="New Zealand" if IN=="NEW ZELAND" | IN=="NEWZEALAND"
replace NAMES="Papua New Guinea" if IN=="PAPUA NEW-GUINEA" | IN=="PNG" | IN=="DROUJBA"
replace NAMES="Peru" if IN=="PERU-MINING" | IN=="PERUVIAN FISHMEAL" | ///
	IN=="PERUVIAN WATERS"
replace NAMES="Philippines" if IN=="PHILIPPINE" | IN=="PHLIPPINES" | IN=="PHILIPINES"
replace NAMES="Laos" if IN=="PS LAOS"
replace NAMES="Chad" if IN=="REPUBLIC OF CHAD"
replace NAMES="Ghana" if IN=="REPUBLIC OF GHANA"
replace NAMES="Singapore" if IN=="REPUBLIC OF SINGAPORE" | IN=="SINAGPORE" | ///
	IN=="SINGAPRE" | IN=="SINGAPUR" | IN=="WITHIN SINGAPORE"
replace NAMES="Yemen" if IN=="REPUBLIC OF YEMEN"
replace NAMES="Romania" if IN=="ROMANIAN" | IN=="ROMENIA"
replace NAMES="Fiji" if IN=="KAMBUNA"
replace NAMES="Kosovo" if IN=="KOSOVO."
replace NAMES="Lesotho" if IN=="LESOTHO - RETAIL"
replace NAMES="Italy" if IN=="MESSINA" | IN=="ITALY - MACHINES"
replace NAMES="North Mariana Islands" if IN=="N. MARIANA ISLANDS"
replace NAMES="Falkland Islands" if IN=="NORTH FALKLAND" | IN=="NORTH FALKLAND BASIN"
replace NAMES="Cyprus" if IN=="NORTHERN CYPRUS"
replace NAMES="Northern Ireland" if IN=="NORTHERN IRELAND" | IN=="NOTHERN IRELAND"
replace NAMES="Ireland" if IN=="REPUBLIC OF IRELAND" | IN=="REPUBLIC OF IRELAND - CONTINUING" | ///
	IN=="REPULBLIC OF IRELAND" | IN=="REPULBLIC OF IRLAND" | IN=="ISLAND OF IRELAND"
replace NAMES="United Kingdom" if IN=="SCOTLAND" | IN=="TESCO BANK" | IN=="WALES"
replace NAMES="Syria" if IN=="SIRIA" | IN=="SIRYA"
replace NAMES="Slovakia" if IN=="SLOVAKIA REPUBLIC" | IN=="SLOVAKIAN" | IN=="SOLVAKIA"
replace NAMES="Slovenia" if IN=="SOLVANIA"
replace NAMES="Sri Lanka" if IN=="SRI LANAKA" | IN=="SRI LANAKA" | IN=="SRILANKA" | IN=="SRI LNKA"
replace NAMES="Oman" if IN=="SULTANATE OF OMAN" | IN=="SULTANATE OF OMAN."
replace NAMES="Trinidad" if IN=="TRINDAD" 
replace NAMES="Trinidad and Tobago" if IN=="TRINIDAD & TABAGO" | IN=="TRNIDAD & TOBAGO"
replace NAMES="Tunisia" if IN=="TUNISIE"
replace NAMES="Uganda" if IN=="UGANDA - DISCONTINUED"
replace NAMES="Ukraine" if IN=="UKRAIN"
replace NAMES="Venezuela" if IN=="VENEZEULA" | IN=="VENEZUELAN FOODS"
replace NAMES="Siberia" if IN=="WESTERN SIBERIA"
replace NAMES="Azerbaijan" if IN=="AZERBAYCAN"
replace NAMES="Nicaragua" if IN=="CERRO NEGRO"
replace NAMES="Panama" if IN=="COBRE(PANAMA)"
replace NAMES="Denmark" if IN=="COPENHAGEN"
replace NAMES="Honduras" if IN=="SAN ANDRES MINE"
replace NAMES="Vietnam" if IN=="VEITNAM"
replace NAMES="Zimbabwe" if IN=="ZIMBAWE"

*Group England and Northern Ireland as UK
replace NAMES="United Kingdom" if NAMES=="England" | NAMES=="Northern Ireland" | ///
	NAMES=="england"

********************************************************************************
******                                                                   *******
******   			 ARTICLE: Extraction Payment Disclosures             *******
******  			 AUTHOR: Thomas Rauter                               *******
******               JOURNAL OF ACCOUNTING RESEARCH                      *******
******   			 CODE TYPE: Clean Shaming Channel Data               *******
******   			 LAST UPDATED: August 2020                           *******
******                                                                   *******
********************************************************************************


********************************************************************************
************************* 1. CLEAN MEDIA COVERAGE DATA *************************
********************************************************************************

preserve

// Save EPD data as tempfile
use "$raw_data/epd_masterfile.dta", clear
drop if effective_since == .
tempfile master_file
save `master_file'

// Import media coverage data
use "$raw_data/media_coverage.dta", clear
keep if language == "English"
collapse (sum) number_media_articles, by(gvkey year)

// Merge EPD data
merge m:1 gvkey using `master_file'
drop if _merge == 1
replace number_media_articles = 0 if _merge == 2
drop _merge

// Compute average media coverage prior to EPD
gen effective_since_year = year(effective_since)
gen number_media_articles_before = number_media_articles if year < effective_since_year
drop if year >= effective_since_year | effective_since_year == .
collapse (mean) number_media_articles_before, by(gvkey)
tempfile media_coverage

// Save media coverage data
save `media_coverage'
restore

// Merge media coverage data with EITI payment data
merge m:1 gvkey using `media_coverage', keep(1 3) nogen

// Generate media coverage indicators
local threshold_media_coverage 75
egen threshold_n_m_art_bef = pctile(number_media_articles_before), p(`threshold_media_coverage')

// Define High media coverage
gen high_media_cov_d = .
replace high_media_cov_d = 1 if number_media_articles_before > threshold_n_m_art_bef & number_media_articles_before != .
replace high_media_cov_d = 0 if number_media_articles_before <= threshold_n_m_art_bef & number_media_articles_before != .
replace high_media_cov_d = . if number_media_articles_before == .

// Define Low media coverage
gen low_media_cov_d = .
replace low_media_cov_d = 1 if number_media_articles_before <= threshold_n_m_art_bef & number_media_articles_before != .
replace low_media_cov_d = 0 if number_media_articles_before > threshold_n_m_art_bef & number_media_articles_before != .
replace low_media_cov_d = . if number_media_articles_before == .


********************************************************************************
************************** 2. CLEAN NGO SHAMING DATA ***************************
********************************************************************************

preserve

// Save EPD data as tempfile
use "$raw_data/epd_masterfile.dta", clear
drop if effective_since == .
tempfile master_file
save `master_file'

// Import activist shaming data
if "$analysis_type"=="investment" {
use "$raw_data/asc_investments.dta", clear
}
else{
use "$raw_data/asc_payments.dta", clear
}

keep if ngo_campaign == 1

// Merge EPD data
merge m:1 gvkey using `master_file', keep(2 3)
drop if _merge == 1
gen effective_since_year = year(effective_since)

// Identify NGO campaigns prior to EPD 
gen campaign_before_effective = 0
replace campaign_before_effective = 1 if year < effective_since_year
replace campaign_before_effective = 0 if _merge == 2
collapse (sum) campaign_before_effective, by(gvkey)
	
// Generate NGO shaming indicators

// Target of NGO shaming campaign
gen campaign_before_effective_d = 0
replace campaign_before_effective_d = 1 if campaign_before_effective > 0 & campaign_before_effective != .
replace campaign_before_effective_d =. if campaign_before_effective ==.
label var campaign_before_effective_d "1=firm target of ngo shaming campaign before epd effective; 0=otherwise"

// Never target of NGO shaming campaign
gen no_campaign_before_effective_d =.
replace no_campaign_before_effective_d = 1 if campaign_before_effective_d == 0
replace no_campaign_before_effective_d = 0 if campaign_before_effective_d == 1
label var no_campaign_before_effective_d "1=firm no target of ngo shaming campaign before epd effective; 0=otherwise"

// Keep only relevant variables
keep gvkey campaign_before_effective_d no_campaign_before_effective_d
tempfile activist_shaming_investments
save `activist_shaming_investments'
restore

// Merge NGO shaming data
merge m:1 gvkey using `activist_shaming_investments', keep(1 3) nogen

