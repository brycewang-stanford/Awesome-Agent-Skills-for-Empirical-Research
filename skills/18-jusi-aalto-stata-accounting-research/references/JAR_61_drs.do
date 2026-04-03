* **********************************************************
* Cleansing local GDP data

* Import raw file 
import excel "GDP Raw Data\NAMA_10R_3GDP.xlsx", clear sheet("Sheet 2")
generate unit_of_measure = C[6]
drop in 1/7
rename A geo_code
rename B geo_label
ds, has(type string)
foreach var in `r(varlist)' {
if `var'!=unit_of_measure & `var'!=geo_code & `var'!=geo_label{
if `var'[1]!=""{
rename `var' year_`=`var'[1]'
}
}
}
drop in 1/2
keep geo_* year_* unit_of_measure

* reshape and cleanse data
reshape long year_, i(geo_code geo_label) j(year)
rename year_ nama_10r_3gdp_2
label variable nama_10r_3gdp_2 "`=unit_of_measure[1]'"
destring nama_10r_3gdp_2, replace ignore(":")
keep geo_code year nama_10r_3gdp_2
drop if geo_code=="" | geo_code==":"|geo_code=="b"| geo_code=="d"| geo_code=="e"|geo_code=="p"|geo_code=="u"

keep if strlen(geo_code)==5
replace geo_code=subinstr(geo_code, "EL", "GR",.)
rename geo_code NUTS3
rename year YR
keep YR NUTS3 nama_10r_3gdp_2 
keep if inrange(YR,2009,2014)

* Take average based on pre-period, making the variable time invariant
foreach v in nama_10r_3gdp_2{
bys NUTS3: egen `v'_avg_pre = mean(`v')
}
keep if YR==2014

* Rename variable and retain relevant fields 
rename nama_10r_3gdp_2_avg_pre LOCAL_GDP
keep NUTS3 LOCAL_GDP

odbc insert, table(LOCAL_GDP_CLEANSED) dsn(Procurement) create	


* **********************************************************
* Cleansing Media Coverage variables 

set more off
local countries "AUT BEL BGR CHE CZE DEU DNK ESP FRA GBR HUN IRL ITA NOR POL PRT SVK SWE "
local versions "1 2 3 4 5" 

* Import Factiva's raw csv output for the search of negative procurement coverage and mention of an NGO. (The first column is the year, the second column is the number of articles retrieved) 
foreach c in `countries'{
foreach v in `versions' {
        capture confirm file "Factiva Raw Data/`c'_`v'.csv"
        if !_rc {
                import delimited "Factiva Raw Data/`c'_`v'.csv", encoding(UTF-8) delimiter(comma) clear
				rename v1 date
				rename v2 publications
				replace date = subinstr(date, "Start Date: 1 January ", "",.)
				replace date = subinstr(date, "End Date: 31 December ", "",.)
				split date, p(" ")
				rename date1 year
				drop date*
				drop if year!="2010" & year!="2011" & year!="2012" & year!="2013" & year!="2014" & year!="2015" & year!="2016" & year!="2017" & year!="2018" & year!="2019"
				gen country = "`c'"
				gen file = "`c'_`v'"
				tempfile `c'_`v'_NGOs
				save "``c'_`v'_NGOs'"
				display "`c'_`v'_NGOs"
        }
        else {
                display "`c'_`v'.csv file does not exist"
        }
}
}

* Combine data for all countries 
use "`AUT_1_NGOs'", clear

foreach c in `countries'{
foreach v in `versions'{
		capture confirm file ``c'_`v'_NGOs'
		if !_rc {
				append using ``c'_`v'_NGOs'
		}
		else {
                display "``c'_`v'_NGOs' file does not exist"
        }
}
}

* Order variables and clean country names 
order year country

* Drop duplicates and ensure data format is consistent
duplicates drop country year file, force
destring year publications, replace
drop file

rename country country_iso3

* Aggregate at country-year level 
collapse (sum) publications, by(year country_iso3)

* Generate country ISO codes 
kountry country_iso3, from(iso3c)
rename NAMES_STD country
kountry(country_iso3), from(iso3c) to(iso2c)
rename _ISO2C_ country_iso2

* Clean variable, and fill in gaps in time variable 
rename publications target_NGOs
rename year YR 

encode country_iso3, gen (country_code)

tsset country_code YR
 
tsfill, full

bys country_code (country_iso3): replace country_iso3 = country_iso3[_N] if missing(country_iso3)
bys country_code (country_iso2): replace country_iso2 = country_iso2[_N] if missing(country_iso2)
bys country_code (country): replace country = country[_N] if missing(country)

replace target_NGOs = 0 if missing(target_NGOs)


sort country_iso3 YR

* Save intermediary dta file 
save "Media_Coverage_Temp1.dta", replace


* Number of countrats (to deflate measure) 

* Retrieve sample for analyses 
clear
odbc load, table(SAMPLE_FOR_ANALYSES) dsn(Procurement) 

gen country_iso2=COUNTRY
replace country_iso2="GB" if country_iso2=="UK"

* Generate counts of unique contracts to normalize media indices 
preserve
bys country_iso2 YR: egen no_contr_by_cty_yr = nvals(CONTRACT_ID)

* Keep only relevant variables and drop duplicates 
keep country_iso2 YR no_contr_by_cty_yr
duplicates drop country_iso2 YR no_contr_by_cty_yr, force

* Generate country code and span panel (country x year-level) 
encode country_iso2, gen(country_code)
tsset country_code YR
tsfill, full

* Missing contract counts correspond to zero contracts 
replace no_contr_by_cty_yr=0 if no_contr_by_cty_yr==.

* Fill our country ISO2 code by country 
bys country_code (country_iso2): replace country_iso2=country_iso2[_N] if missing(country_iso2) 
bys country_code: replace country_iso2=country_iso2[1] if missing(country_iso2)

* Keep only years 2010-2017 and ensure data is unique at country x year-level 
keep if inrange(YR, 2010, 2019)
isid YR country_iso2

* Save intermediary dta file 
drop country_code
save "Media_Coverage_Temp2.dta", replace
restore


* Generate Media Index by Country - Any Media Coverage (Country = Target of Article) 

* Import Factiva's raw csv output for the search of media coverage. (The first column is the year, the second column is the number of articles retrieved) 
local countries2 "Austria Belgium Bulgaria Croatia Cyprus Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Iceland Ireland Italy Latvia Lithuania Luxembourg Malta Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden Switzerland United_Kingdom"

foreach c in `countries2'{
import delimited "Factiva Raw Data/`c'_All_Media_Coverage.csv", encoding(UTF-8) delimiter(comma) clear
rename v1 date
rename v2 publications
replace date = subinstr(date, "Start Date: 1 January ", "",.)
replace date = subinstr(date, "End Date: 31 December ", "",.)
split date, p(" ")
rename date1 year
drop date*
drop if year!="2010" & year!="2011" & year!="2012" & year!="2013" & year!="2014" & year!="2015" & year!="2016" & year!="2017" & year!="2018" & year!="2019"
gen country = "`c'"
tempfile `c'_All_MC
save ``c'_All_MC'
display "`c'_All_MC"
}

* Append country media data together 
use `Austria_All_MC'
foreach c in `countries2'{
append using ``c'_All_MC'
}

* Order variables and clean country names 
order year country publications
replace country=subinstr(country, "_", " ",.)

* Drop duplicates and ensure data format is consistent 
duplicates drop country year, force
destring year publications, replace

* Generate country ISO codes 
kountry country, from(other) stuck
rename _ISO3N_ iso3n
kountry(iso3n), from(iso3n) to(iso2c)
rename _ISO2C_ country_iso2
kountry(country_iso2), from(iso2c) to(iso3c)
drop iso3n
rename _ISO3C_ country_iso3

* rename variable 
rename publications target_all_MC
rename year YR 

* Save intermediary dta file 
save "Media_Coverage_Temp3.dta", replace


* Generate Media Index by Country - Procurement Media Coverage (Country = Target of Article, Only Keywords) 

* Import Factiva's raw csv output for the search of negative procurement coverage. (The first column is the year, the second column is the number of articles retrieved) 
local countries "Austria Belgium Bulgaria Czech_Republic Denmark France Germany Hungary Ireland Italy Netherlands Norway Poland Portugal Slovakia Spain Sweden Switzerland United_Kingdom"

foreach c in `countries'{
import delimited "Factiva Raw Data/`c'_Only_Keywords_Yearly.csv", encoding(UTF-8) delimiter(comma) clear
rename v1 date
rename v2 publications
replace date = subinstr(date, "Start Date: 1 January ", "",.)
replace date = subinstr(date, "End Date: 31 December ", "",.)
split date, p(" ")
rename date1 year
drop date*
drop if year!="2010" & year!="2011" & year!="2012" & year!="2013" & year!="2014" & year!="2015" & year!="2016" & year!="2017" & year!="2018" & year!="2019"
gen country = "`c'"
tempfile `c'_Only_Keywords
save ``c'_Only_Keywords'
display "`c'_Only_Keywords"
}

* Combine data for all countries 
use `Austria_Only_Keywords'
foreach c in `countries'{
append using ``c'_Only_Keywords'
}

* Order variables and clean country names 
order year country publications
replace country=subinstr(country, "_", " ",.)

* Drop duplicates and ensure data format is consistent 
duplicates drop country year, force
destring year publications, replace

* Generate country ISO codes 
kountry country, from(other) stuck
rename _ISO3N_ iso3n
kountry(iso3n), from(iso3n) to(iso2c)
rename _ISO2C_ country_iso2
kountry(country_iso2), from(iso2c) to(iso3c)
drop iso3n
rename _ISO3C_ country_iso3

* rename variables 
rename publications neg_procur_pubs
rename year YR 

* Save Data 
save "Media_Coverage_Temp4.dta", replace


* Merge all Media Data together (incl. contract counts for normalization) 

use "Media_Coverage_Temp2.dta", clear

* Drop country not covered 
drop if country_iso2=="LI"

* Merge Media data at country x year-level (Any Media Coverage + Procurement-related Media Coverage + NGO Media Coverage) 
merge 1:1 country_iso2 YR using "Media_Coverage_Temp4.dta", nogen update
merge 1:1 country_iso2 YR using "Media_Coverage_Temp3.dta", nogen
merge 1:1 country_iso2 YR using "Media_Coverage_Temp1.dta", keep(1 3) nogen

* Drop countries not covered in Factiva 
drop if country_iso2=="CY" | country_iso2=="EE" | country_iso2=="FI" | country_iso2=="GR" | country_iso2=="HR" | country_iso2=="IS" | country_iso2=="LT" | country_iso2=="LU" | country_iso2=="LV" | country_iso2=="MT" | country_iso2=="RO" | country_iso2=="SI"

* Missing publication counts represent zero publications 
replace neg_procur_pubs = 0 if neg_procur_pubs == .
replace target_NGOs = 0 if target_NGOs == .

* Fill out country names and country codes within country 
bys country_iso2 (country): replace country=country[_N] if missing(country)
bys country_iso2 (country_iso3): replace country_iso3=country_iso3[_N] if missing(country_iso3)


* Create variables for TED analysis 
keep if YR<=2017
gen pre=0
replace pre=1 if inrange(YR, 2010, 2014)

bys country_iso2 pre: egen tot_neg_procur_pubs = total(neg_procur_pubs)
bys country_iso2 pre: egen tot_neg_procur_pubs_NGOs = total(target_NGOs)
bys country_iso2 pre: egen tot_contracts = total(no_contr_by_cty_yr)
bys country_iso2 pre: egen tot_MC = total(target_all_MC)

duplicates drop country_iso2 pre, force
keep country_iso2 pre tot_neg_procur_pubs* tot_contracts tot_MC

* Normalize N. of Negative Publications on Public procruement by Tot. No. of Contracts 
gen MC_index_allPC = tot_neg_procur_pubs / tot_contracts

* Normalize N. of Negative Publications on Public procruement with NGO mention by Tot. No. of Contracts 
gen MC_index_NGOs_allPC = tot_neg_procur_pubs_NGOs / tot_contracts

* Normalize N. of Negative Publications on Public procruement by Tot. No. of Publications 
gen MC_index_allMC = tot_neg_procur_pubs / tot_MC

* Normalize N. of Negative Publications on Public procruement with NGO mention by Tot. No. of Publications 
gen MC_index_NGOs_allMC = tot_neg_procur_pubs_NGOs / tot_MC

gen period=""
replace period="_pre" if pre==1
replace period="_post" if pre==0


keep country_iso2 period MC_index* tot_neg_procur_pubs tot_neg_procur_pubs_NGOs

reshape wide MC_index* tot_neg_procur_pubs tot_neg_procur_pubs_NGOs, i(country_iso2) j(period) string

* Delta Pre- vs. Post-Period of Negative Media Coverage (Normalized by Overall Media Coverage) 
gen DELTA_MEDIA_COVERAGE1 = (MC_index_allMC_post / MC_index_allMC_pre - 1)

* Delta Pre- vs. Post-Period of Negative Media Coverage (Normalized by No. of Contracts) 
gen DELTA_MEDIA_COVERAGE2 = (MC_index_allPC_post / MC_index_allPC_pre - 1)

* Delta Pre- vs. Post-Period of Negative Media Coverage with NGO mention (Normalized by Overall Media Coverage) 
gen DELTA_MEDIA_COVERAGE3 = (MC_index_NGOs_allMC_post / MC_index_NGOs_allMC_pre - 1)

* Delta Pre- vs. Post-Period of Negative Media Coverage with NGO mention (Normalized by No. of Contracts) 
gen DELTA_MEDIA_COVERAGE4 = (MC_index_NGOs_allPC_post / MC_index_NGOs_allPC_pre - 1)

keep country_iso2 DELTA_MEDIA_COVERAGE1 DELTA_MEDIA_COVERAGE2 DELTA_MEDIA_COVERAGE3 DELTA_MEDIA_COVERAGE4

rename country_iso2 COUNTRY    
replace COUNTRY="UK" if COUNTRY=="GB"

odbc insert, table(Media_Coverage_TED) dsn(Procurement) create	

* Drop intermediary data files 
erase Media_Coverage_Temp1.dta
erase Media_Coverage_Temp2.dta
erase Media_Coverage_Temp3.dta
erase Media_Coverage_Temp4.dta* Conditioning on samples for analysis 

* Open log file
log using "4-Prepare analysis sample", replace text

* Sample for TED Procurement Analysis 
odbc load, table(SAMPLE_FOR_ANALYSES) dsn(Procurement) 

* Sample selection for TED Open Data analysis  
keep if YR >= 2009 & YR <= 2017 & CONTRACT_VALUE_ESTIMATE >= 25000 

* Fixed Effects and variables 
egen YR_QT                       = group(YR_QUARTER)
egen COUNTRY_ID                  = group(COUNTRY)
egen CONTRACT_TYPE_ID            = group(CONTRACT_TYPE)
egen COUNTRY_TYPE_ID             = group(COUNTRY CONTRACT_TYPE)
egen COUNTRY_Q_ID                = group(COUNTRY YR_QUARTER)
egen TYPE_Q_ID                   = group(CONTRACT_TYPE YR_QUARTER)

winsor2 NUMBER_BIDS, replace cuts(0 95) by(COUNTRY TED_CONTRACT) trim
gen LN_NUMBER_BIDS = ln(NUMBER_BIDS)

bysort CONTRACT_TYPE_ID: egen group_median=median(N_CRIT) if N_CRIT!=.

gen     HIGH_N_CRIT = .
replace HIGH_N_CRIT = 1 if N_CRIT >  group_median & N_CRIT!=. & group_median!=.
replace HIGH_N_CRIT = 0 if N_CRIT <= group_median & N_CRIT!=. & group_median!=.

gen     OPEN_BIDDING_WITH_HIGH_NB_CRIT = .
replace OPEN_BIDDING_WITH_HIGH_NB_CRIT = 1 if  OPEN_BIDDING==1 & HIGH_N_CRIT==1
replace OPEN_BIDDING_WITH_HIGH_NB_CRIT = 0 if (OPEN_BIDDING==0 | HIGH_N_CRIT==0) & OPEN_BIDDING!=. & HIGH_N_CRIT!=.

* Regressions to condition on samples reported in tables 
quietly reghdfe OPEN_BIDDING                   c.TED_CONTRACT##c.POST PROCUREMENT_DIRECTIVE c.LN_CONTRACT_SIZE##i.YR_QT                            , absorb(COUNTRY_Q_ID TYPE_Q_ID COUNTRY_TYPE_ID) vce(cluster COUNTRY_ID) 
gen SAMPLE_TABLE2_COL1 = e(sample)               
count if SAMPLE_TABLE2_COL1==1
									           
quietly reghdfe CONTRACT_MODIFICATION          c.TED_CONTRACT##c.POST PROCUREMENT_DIRECTIVE c.LN_CONTRACT_SIZE##i.YR_QT if SAMPLE_CONTRACT_MODIF==1, absorb(COUNTRY_Q_ID TYPE_Q_ID COUNTRY_TYPE_ID) vce(cluster COUNTRY_TYPE_ID) 
gen SAMPLE_TABLE7_COL1 = e(sample)               
count if SAMPLE_TABLE7_COL1==1

quietly reghdfe LN_NUMBER_BIDS                 c.TED_CONTRACT##c.POST PROCUREMENT_DIRECTIVE c.LN_CONTRACT_SIZE##i.YR_QT                            , absorb(COUNTRY_Q_ID TYPE_Q_ID COUNTRY_TYPE_ID ) vce(cluster COUNTRY_TYPE_ID)
gen SAMPLE_TABLE6_PANELB_COL1 = e(sample)   
count if SAMPLE_TABLE6_PANELB_COL1==1
											   
quietly reghdfe OPEN_BIDDING_WITH_PRICE_ONLY   c.TED_CONTRACT##c.POST PROCUREMENT_DIRECTIVE c.LN_CONTRACT_SIZE##i.YR_QT                            , absorb(COUNTRY_Q_ID TYPE_Q_ID COUNTRY_TYPE_ID) vce(cluster COUNTRY_TYPE_ID)
gen SAMPLE_TABLE8_PANELA_COL1 = e(sample)                                                                                                                   
count if SAMPLE_TABLE8_PANELA_COL1==1
																																	               
quietly reghdfe OPEN_BIDDING_WITH_TECH         c.TED_CONTRACT##c.POST PROCUREMENT_DIRECTIVE c.LN_CONTRACT_SIZE##i.YR_QT                            , absorb(COUNTRY_Q_ID TYPE_Q_ID COUNTRY_TYPE_ID) vce(cluster COUNTRY_TYPE_ID)
gen SAMPLE_TABLE8_PANELA_COL2 = e(sample)                                                                                                             
count if SAMPLE_TABLE8_PANELA_COL2==1
																																	               
quietly reghdfe OPEN_BIDDING_WITH_HIGH_NB_CRIT c.TED_CONTRACT##c.POST PROCUREMENT_DIRECTIVE c.LN_CONTRACT_SIZE##i.YR_QT                            , absorb(COUNTRY_Q_ID TYPE_Q_ID COUNTRY_TYPE_ID) vce(cluster COUNTRY_TYPE_ID)
gen SAMPLE_TABLE8_PANELA_COL3 = e(sample)
count if SAMPLE_TABLE8_PANELA_COL3==1

* Close log file
log close
