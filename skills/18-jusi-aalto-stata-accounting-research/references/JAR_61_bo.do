
*******************************************************
* Boosting Foreign Investment:                        *
* The Role of Certification of Corporate Governance   *
*                                                     *
* by Bonetti, P., and Ormazabal, G.                   *
*                                                     *
* This do file converts the raw data into the final   *
* dataset on which the analyses are performed.  	  *
* 													  *
* We used Stata MP – Parallel Edition 15.1 to perform *
* the analyses.										  *
*******************************************************

************************************
* Cleaning ACGS I (first editions) *
************************************

clear
set more off
cd "G:\Dropbox (IESE)\ASEAN"
import excel "DATA ASEAN\data_2012_2017_1_all.xls", sheet("Sheet1") firstrow clear

replace Country ="Malaysia" if Country =="MALAYSIA"
replace Country ="Singapore" if Country =="SINGAPORE"

destring PartA, replace
destring PartB, replace
destring PartC, replace
destring PartD, replace
destring PartE, replace
destring Total, replace
destring Bonus, replace
destring Penalty, replace
destring TotalScore, replace // it includes bonus and penalty [i.e., ACGS_Score]

egen firm_fe = group(isin)
egen year_fe = group(file_year)
egen country_fe = group(Country)
egen year_country_fe = group(file_year Country)

g TotalScore_2 = TotalScore*TotalScore
g TotalScore_3 = TotalScore*TotalScore*TotalScore
g TotalScore_4 = TotalScore*TotalScore*TotalScore*TotalScore
g TotalScore_5 = TotalScore*TotalScore*TotalScore*TotalScore*TotalScore

duplicates tag isin date_to, gen(FLAG)
tab FLAG

save "asean_temp_jul2020_isinDEF.dta", replace

******************************************
* Cleaning ACGS II (subsequent editions) *
******************************************

clear
set more off
cd "G:\Dropbox (IESE)\ASEAN"
import excel "DATA ASEAN\data_2017_on_all.xls", sheet("Sheet1") firstrow clear

replace Country ="Malaysia" if Country =="MALAYSIA"
replace Country ="Singapore" if Country =="SINGAPORE"

destring PartA, replace
destring PartB, replace
destring PartC, replace
destring PartD, replace
destring PartE, replace
destring Total, replace
destring Bonus, replace
destring Penalty, replace
destring TotalScore, replace // it includes bonus and penalty [i.e., ACGS_Score]

egen firm_fe = group(isin)
egen year_fe = group(file_year)
egen country_fe = group(Country)
egen year_country_fe = group(file_year Country) 

g TotalScore_2 = TotalScore*TotalScore
g TotalScore_3 = TotalScore*TotalScore*TotalScore
g TotalScore_4 = TotalScore*TotalScore*TotalScore*TotalScore
g TotalScore_5 = TotalScore*TotalScore*TotalScore*TotalScore*TotalScore

br CompanyName
duplicates tag isin date_to, gen(FLAG)
tab FLAG
br if FLAG == 1

save "asean_temp_jul2017_isinDEF.dta", replace

// check correspondence with factset (first editions)
use "asean_temp_jul2020_isinDEF.dta", clear

merge m:1 CompanyName using "fuzzy_matching_def_cleaned_isin.dta"
replace isin = isin_fact if isin_fact!=""
capture drop flag*
capture drop FLAG
duplicates tag isin datevar, gen(flag)
tab flag
br if flag == 1
drop if ID_files == 482 // duplicate

save "score_files_isinDEF.dta", replace

// check correspondence with factset (subsequent editions)
use "asean_temp_jul2017_isinDEF.dta", clear

merge m:1 CompanyName using "fuzzy_matching_def_cleaned_isin_2017.dta"
replace isin = isin_fact if isin_fact!=""
capture drop flag*
capture drop FLAG
duplicates tag isin datevar, gen(flag)
tab flag

save "score_files_isin_2017DEF.dta", replace

*************************
* cleaning FactSet data *
*************************

use "factset_data", clear
drop if cusip ==""
isid cusip rq
drop if rq<d(31dec2009)
codebook  tic isin
tostring quarter, gen(quarter_s)
g Q = substr(quarter_s, 5, 2)
save "FactSet_temp.dta", replace

// 2015 Edition (2015 assessment)
use "FactSet_temp.dta", clear

keep if rq==d(31dec2015) | /// t publication November 2015
rq==d(30sep2015) | /// t-1
rq==d(30jun2015) | /// t-2
rq==d(31mar2015) | /// t-3
rq==d(31dec2014) | /// t-4 
rq==d(31mar2016) | /// t+1
rq==d(30jun2016) | /// t+2
rq==d(30sep2016) | /// t+3
rq==d(31dec2016)    // t+4

g T = "0" if rq==d(31dec2015)
replace T = "m1" if rq==d(30sep2015)
replace T = "m2" if rq==d(30jun2015)
replace T = "m3" if rq==d(31mar2015)
replace T = "m4" if rq==d(31dec2014)
replace T = "p1" if rq==d(31mar2016)
replace T = "p2" if rq==d(30jun2016)
replace T = "p3" if rq==d(30sep2016)
replace T = "p4" if rq==d(31dec2016)

g date_to_merge = d(31dec2015)
format %td date_to_merge
keep entity_proper_name cusip tic isin sedol sec_country T mktcap  - herf date_to_merge
reshape wide mktcap  - herf , i(cusip) j(T) string
compress
order entity_proper_name cusip tic isin sedol sec_country date_to_merge

g file_year = 2015

save "FactSet_2015_wide.dta", replace

// 2014 Edition (2014 assessment) publication October 2014
use "FactSet_temp.dta", clear

keep if rq==d(31dec2014) | /// t
rq==d(30sep2014) | /// t-1
rq==d(30jun2014) | /// t-2
rq==d(31mar2014) | /// t-3
rq==d(31dec2013) | /// t-4
rq==d(31mar2015) | /// t+1
rq==d(30jun2015) | /// t+2
rq==d(30sep2015) | /// t+3
rq==d(31dec2015)    // t+4

g T = "0" if rq==d(31dec2014)
replace T = "m1" if rq==d(30sep2014)
replace T = "m2" if rq==d(30jun2014)
replace T = "m3" if rq==d(31mar2014)
replace T = "m4" if rq==d(31dec2013)
replace T = "p1" if rq==d(31mar2015)
replace T = "p2" if rq==d(30jun2015)
replace T = "p3" if rq==d(30sep2015)
replace T = "p4" if rq==d(31dec2015)

g date_to_merge = d(31dec2014)
format %td date_to_merge
keep entity_proper_name cusip tic isin sedol sec_country T mktcap  - herf date_to_merge
reshape wide mktcap  - herf , i(cusip) j(T) string
compress
order entity_proper_name cusip tic isin sedol sec_country date_to_merge

g file_year = 2014

save "FactSet_2014_wide.dta", replace

// 2013 Edition (2013 assessment)
use "FactSet_temp.dta", clear

keep if rq==d(30jun2014) | /// t publication June 2014
rq==d(31mar2014) | /// t-1
rq==d(31dec2013) | /// t-2
rq==d(30sep2013) | /// t-3
rq==d(30jun2013) | /// t-4 
rq==d(30sep2014) | /// t+1
rq==d(31dec2014) | /// t+2
rq==d(31mar2015) | /// t+3
rq==d(30jun2015)    // t+4

g T = "0" if rq==d(30jun2014)
replace T = "m1" if rq==d(31mar2014)
replace T = "m2" if rq==d(31dec2013)
replace T = "m3" if rq==d(30sep2013)
replace T = "m4" if rq==d(30jun2013)
replace T = "p1" if rq==d(30sep2014)
replace T = "p2" if rq==d(31dec2014)
replace T = "p3" if rq==d(31mar2015)
replace T = "p4" if rq==d(30jun2015)

g date_to_merge = d(30jun2014)
format %td date_to_merge
keep entity_proper_name cusip tic isin sedol sec_country T mktcap  - herf date_to_merge
reshape wide mktcap - herf , i(cusip) j(T) string
compress
order entity_proper_name cusip tic isin sedol sec_country date_to_merge

g file_year = 2013

save "FactSet_2013_wide.dta", replace

// 2012 Edition (2012 assessment)
use "FactSet_temp.dta", clear

keep if rq==d(30jun2013) | /// t publication May 2013 
rq==d(31mar2013) | /// t-1
rq==d(31dec2012) | /// t-2
rq==d(30sep2012) | /// t-3
rq==d(30jun2012) | /// t-4 
rq==d(30sep2013) | /// t+1
rq==d(31dec2013) | /// t+2
rq==d(31mar2014) | /// t+3
rq==d(30jun2014)    // t+4

g T = "0" if rq==d(30jun2013)
replace T = "m1" if rq==d(31mar2013)
replace T = "m2" if rq==d(31dec2012)
replace T = "m3" if rq==d(30sep2012)
replace T = "m4" if rq==d(30jun2012)
replace T = "p1" if rq==d(30sep2013)
replace T = "p2" if rq==d(31dec2013)
replace T = "p3" if rq==d(31mar2014)
replace T = "p4" if rq==d(30jun2014)

g date_to_merge = d(30jun2013)
format %td date_to_merge
keep entity_proper_name cusip tic isin sedol sec_country T mktcap - herf date_to_merge
reshape wide mktcap  - herf , i(cusip) j(T) string
compress
order entity_proper_name cusip tic isin sedol sec_country date_to_merge

g file_year = 2012

save "FactSet_2012_wide.dta", replace

// 2017 Edition (2017 assessment)
use "factset_dataII.dta", clear
rename CUSIP cusip
rename SEDOL sedol
drop if cusip ==""
isid cusip rq
drop if rq<d(31dec2009)
codebook  tic isin
tostring quarter, gen(quarter_s)
g Q = substr(quarter_s, 5, 2)
save "FactSet_temp2017.dta", replace

use "FactSet_temp2017.dta", clear

keep if rq==d(31dec2018) | /// t publication November 2018
rq==d(30sep2018) | /// t-1 
rq==d(30jun2018) | /// t-2
rq==d(31mar2018) | /// t-3
rq==d(31dec2017) | /// t-4 
rq==d(31mar2019) | /// t+1
rq==d(30jun2019) | /// t+2
rq==d(30sep2019) | /// t+3
rq==d(31dec2019)    // t+4

g T = "0" if rq==d(31dec2018)
replace T = "m1" if rq==d(30sep2018)
replace T = "m2" if rq==d(30jun2018)
replace T = "m3" if rq==d(31mar2018)
replace T = "m4" if rq==d(31dec2017)
replace T = "p1" if rq==d(31mar2019)
replace T = "p2" if rq==d(30jun2019)
replace T = "p3" if rq==d(30sep2019)
replace T = "p4" if rq==d(31dec2019)

g date_to_merge = d(31dec2018)
format %td date_to_merge
keep entity_proper_name cusip tic isin sedol sec_country T mktcap - herf date_to_merge
reshape wide mktcap  - herf , i(cusip) j(T) string
compress
order entity_proper_name cusip tic isin sedol sec_country date_to_merge

g file_year = 2017

save "FactSet_2017_wide.dta", replace

**************************************
* Append first editions (up to 2015) *
**************************************

use "FactSet_2015_wide.dta", clear
append using "FactSet_2014_wide.dta"
append using "FactSet_2013_wide.dta"
append using "FactSet_2012_wide.dta"

local Ys io_usd io io_dom io_for io_for_us io_for_cat1 io_for_cat3 io_for_cat6  
local Ps 0 m1 m2 m3 m4 p1 p2 p3 p4

foreach y of local Ys {
foreach p of local Ps {
replace `y'`p' = 0 if `y'`p'==.
}
}

foreach y of local Ys {

// post PLUS 1
egen `y'_post1 = rowmean(`y'p1)
// post PLUS 2
egen `y'_post2 = rowmean(`y'p2) 
// post AVG. PLUS 0 - 1 - 2
egen `y'_post1b = rowmean(`y'0 `y'p1 `y'p2)
// post AVG. PLUS 1 - 2
egen `y'_post2b = rowmean(`y'p1 `y'p2)

// pre MINUS 1
egen `y'_pre1 = rowmean(`y'm1)
// pre MINUS 2
egen `y'_pre2 = rowmean(`y'm2)
// pre MINUS 3
egen `y'_pre1b = rowmean(`y'm3)
// pre AVG. MINUS 1 - 2
egen `y'_pre2b = rowmean(`y'm1 `y'm2)

}

drop if isin == ""
duplicates tag isin date_to_merge, gen(flag)
tab flag

save "FactSet_full_wide_isin.dta", replace

use "FactSet_full_wide_isin.dta", clear
drop if (sec_country!="MY" & sec_country!="PH" & sec_country!="SG" & sec_country!="TH" & sec_country!="ID")

// merge with CG data
merge 1:1 isin date_to_merge using "score_files_isinDEF.dta", gen(_merge_d)
drop if _merge_d==1 // drop firms not in the ASEAN sample 
sort entity_proper_name
tab CompanyName if _merge_d==2
merge 1:1 isin date_to_merge using "_merge_d_2012_2017.dta", gen(_merge_dd) update // manually retrived non-matching observations (27 firm-years)

local Ys io_usd io io_dom io_for io_for_us io_for_cat1 io_for_cat3 io_for_cat6  
foreach y of local Ys {

replace `y'_post1 = 0 if `y'_post1 ==.
replace `y'_post2 = 0 if `y'_post2 ==.
replace `y'_post1b = 0 if `y'_post1b ==.
replace `y'_post2b = 0 if `y'_post2b ==.
replace `y'_pre1 = 0 if `y'_pre1 ==.
replace `y'_pre2 = 0 if `y'_pre2 ==.
replace `y'_pre1b = 0 if `y'_pre1b ==.
replace `y'_pre2b = 0 if `y'_pre2b ==.

// Ys-based ranking for placebo analysis
gsort Country file_year -`y'_pre1
by Country file_year: g position`y'_pre1 = _n
g treshold = 50
g position_adj`y'_pre1 = treshold - position`y'_pre1
drop treshold

}			

g treatment = 1 if position_ranking>=0 & position_ranking!=. // dummy marking firms in the lists [i.e., "Top50" dummy]
replace treatment = 0 if treatment==.

drop firm_fe year_fe country_fe year_country_fe
egen firm_fe = group(isin)
egen year_fe = group(file_year)
egen country_fe = group(Country)
egen year_country_fe = group(file_year Country)

drop if Country == "Vietnam"

save "ASEAN_factset_working_isin.dta", replace

*********************************************************
* Assemby the final dataset for the subsequent Editions *
*********************************************************

use "FactSet_2017_wide.dta", clear

local Ys io_usd io io_dom io_for io_for_us io_for_cat1 io_for_cat3 io_for_cat6  
local Ps 0 m1 m2 m3 m4 p1 p2 p3 p4

foreach y of local Ys {
foreach p of local Ps {
replace `y'`p' = 0 if `y'`p'==.
}
}

foreach y of local Ys {

// post PLUS 1
egen `y'_post1 = rowmean(`y'p1)
// post PLUS 2
egen `y'_post2 = rowmean(`y'p2) 
// post AVG. PLUS 0 - 1 - 2
egen `y'_post1b = rowmean(`y'0 `y'p1 `y'p2)
// post AVG. PLUS 1 - 2
egen `y'_post2b = rowmean(`y'p1 `y'p2)

// pre MINUS 1
egen `y'_pre1 = rowmean(`y'm1)
// pre MINUS 2
egen `y'_pre2 = rowmean(`y'm2)
// pre MINUS 3
egen `y'_pre1b = rowmean(`y'm3)
// pre AVG. MINUS 1 - 2
egen `y'_pre2b = rowmean(`y'm1 `y'm2)

}

drop if isin == ""

duplicates tag isin date_to_merge, gen(flag)
tab flag

save "FactSet_full_wide_isin_2017.dta", replace

use "FactSet_full_wide_isin_2017.dta", clear
drop if (sec_country!="MY" & sec_country!="PH" & sec_country!="SG" & sec_country!="TH" & sec_country!="ID")

// merge with CG data
merge 1:1 isin date_to_merge using "score_files_isin_2017DEF.dta", gen(_merge_d)
drop if _merge_d==1
sort entity_proper_name
tab CompanyName if _merge_d==2
merge 1:1 isin date_to_merge using "_merge_d_2017.dta", gen(_merge_dd) update // manually retrived non-matching observations (14 firm-years)
capture drop position_a*
									
local Ys io_usd io io_dom io_for io_for_us io_for_cat1 io_for_cat3 io_for_cat6  
foreach y of local Ys {
replace `y'_post1 = 0 if `y'_post1 ==.
replace `y'_post2 = 0 if `y'_post2 ==.
replace `y'_post1b = 0 if `y'_post1b ==.
replace `y'_post2b = 0 if `y'_post2b ==.
replace `y'_pre1 = 0 if `y'_pre1 ==.
replace `y'_pre2 = 0 if `y'_pre2 ==.
replace `y'_pre1b = 0 if `y'_pre1b ==.
replace `y'_pre2b = 0 if `y'_pre2b ==.

// Ys-based score
gsort Country file_year -`y'_pre1
by Country file_year: g position`y'_pre1 = _n
g treshold = 50
g position_adj`y'_pre1 = treshold - position`y'_pre1
drop treshold

}			

g treatment = 1 if position_ranking>=0 & position_ranking!=. // dummy marking firms in the lists [i.e., "Top50" dummy]
replace treatment = 0 if treatment==.

drop firm_fe year_fe country_fe year_country_fe
egen firm_fe = group(isin)
egen year_fe = group(file_year)
egen country_fe = group(Country)
egen year_country_fe = group(file_year Country)

drop if Country == "Vietnam"

save "ASEAN_factset_working_isin_2017DEF.dta", replace
															
sort Country isin file_year 

use "ASEAN_factset_working_isin.dta", clear

// ADD 2017 Edition
append using "ASEAN_factset_working_isin_2017DEF.dta"

// Fixed effects
drop firm_fe year_fe country_fe year_country_fe 
drop flag flag_bis _merge*
egen firm_fe = group(isin)
egen year_fe = group(file_year)
egen country_fe = group(Country)
egen year_country_fe = group(file_year Country)

// variables for Tables 2-4 & 6-8
g dif_post1 = io_for_post1 - io_for_pre1
g dif_post2 = io_for_post2 - io_for_pre1
g dif_post1b = io_for_post1b - io_for_pre1 // dependent variable for Tables 2-3
g dif_post2b = io_for_post2b - io_for_pre1
g dif_us_post1b = io_for_us_post1b - io_for_us_pre1 // dependent variable for Table 4
g dif_cat1_for_post1b = io_for_cat1_post1b - io_for_cat1_pre1 // dependent variable for Table 4
g dif_cat3_for_post1b = io_for_cat3_post1b - io_for_cat3_pre1 // dependent variable for Table 4
g dif_cat6_for_post1b = io_for_cat6_post1b - io_for_cat6_pre1 // dependent variable for Table 4
g dif_pre1 = io_for_pre1 - io_for_pre1b
g dif_post1_dom = io_dom_post1 - io_dom_pre1
g dif_post2_dom = io_dom_post2 - io_dom_pre1
g dif_post1b_dom = io_dom_post1b - io_dom_pre1
g dif_post2b_dom = io_dom_post2b - io_dom_pre1

replace io_for_post1b = io_for_post1b*100
replace dif_pre1 = dif_pre1*100
replace dif_us_post1b = dif_us_post1b*100
replace dif_cat1_for_post1b = dif_cat1_for_post1b*100
replace dif_cat3_for_post1b = dif_cat3_for_post1b*100
replace dif_cat6_for_post1b = dif_cat6_for_post1b*100
replace dif_post1b = dif_post1b*100
replace dif_post1b_dom = dif_post1b_dom*100

merge 1:1 isin file_year using "scores_lead_def.dta", gen(_merge)
drop if _merge == 2
drop _merge

// variables for Tables 6-8
g delta_TotalScore = (TotalScore_lead1 - TotalScore)
sort Country isin file_year 
g delta_PartA = (PartA_lead1 - PartA)
sort Country isin file_year 
g delta_PartB = (PartB_lead1 - PartB)
sort Country isin file_year 
g delta_PartC = (PartC_lead1 - PartC)
sort Country isin file_year 
g delta_PartD = (PartD_lead1 - PartD)
sort Country isin file_year 
g delta_PartE = (PartE_lead1 - PartE)

// lags Top Lists
sort Country isin file_year 
by Country isin: g pre_top50_1lag = 1 if treatment[_n-1] == 1 
replace pre_top50_1lag = 0 if pre_top50_1lag==.

// Accounting Variables
merge 1:1 isin file_year using Accounting_vars.dta, gen(_merge_wd) // in t-1
drop if _merge_wd == 2 
drop if _merge_wd == 1 
g LEV2 = Tot_Liabilities / Tot_Assets
g SIZE = log(1+Tot_Assets)
g ROA = NI / Tot_Assets	
g ROE = NI / CEQ
g SALES_TA = SALES / Tot_Assets

// Market Cap
merge 1:1 isin file_year using Mkt_vars.dta, gen(_merge_ds) // in t-1
drop if _merge_ds == 2
drop if _merge_ds == 1
g log_mkt = log(mkt)

local var LEV2 SIZE ROA ROE MTB log_mkt Tot_Assets SALES NI SALES_TA CEQ Tot_Liabilities
foreach y of local var {
winsor `y', gen(w1_`y') p(0.01)
winsor `y', gen(w5_`y') p(0.05)
}
drop _merge*
compress

merge 1:1 isin file_year using Accounting_vars__II.dta, gen(_merge__II) // in t and t+1
drop if _merge__II == 2

tostring datevar, gen(date_string) force usedisplayformat
g date_string_month = substr(date_string, 3, 3)

** DELTA ROE (Tables 10 & 11) & DELTA ROA (Table 10 Panel C): USE w1_
local FILE ""w1_" "w5_" """
foreach y of local FILE {

g `y'ROE_current = `y'NI_current / `y'CEQ_lag
g `y'ROA_current = `y'NI_current / `y'Tot_Assets_lag

g `y'ROE_lead = `y'NI_lead / `y'CEQ_current
g `y'ROA_lead = `y'NI_lead / `y'Tot_Assets_current

g `y'delta_ROE_1 = `y'ROE_lead - `y'ROE_current
g `y'delta_ROA_1 = `y'ROA_lead - `y'ROA_current

}

** DELTA LEV2 (Table 10 C): USE w1_
local FILE ""w1_" "w5_" """
foreach y of local FILE {

g `y'LEV2_current = `y'Tot_Liabilities_current / `y'Tot_Assets_current

g `y'LEV2_lead = `y'Tot_Liabilities_lead / `y'Tot_Assets_lead

g `y'delta_LEV2_1 = `y'LEV2_lead - `y'LEV2_current

}

** DELTA SALES_TA  (Table 10 C): USE w1_
local FILE ""w1_" "w5_" """
foreach y of local FILE {

g `y'SALES_TA_current = `y'SALES_current / `y'Tot_Assets_lag

g `y'SALES_TA_lead = `y'SALES_lead / `y'Tot_Assets_current

g `y'delta_SALES_TA_1 = `y'SALES_TA_lead - `y'SALES_TA_current

}

** DELTA Net Margin (Table 10 C): USE w1_
g NET_margin_lead = (NI_lead/SALES_lead) 
g NET_margin_current = (NI_current/SALES_current) 
winsor NET_margin_lead, gen(w1_NET_margin_lead) p(0.01)
winsor NET_margin_lead, gen(w5_NET_margin_lead) p(0.05)
winsor NET_margin_current, gen(w1_NET_margin_current) p(0.01)
winsor NET_margin_current, gen(w5_NET_margin_current) p(0.05)

local FILE NET_margin w1_NET_margin w5_NET_margin
foreach y of local FILE {
g delta_`y'1 = `y'_lead - `y'_current
}

** DELTA Book Value of Equity (Table 5, Coll. 1-2): USE w1_
local FILE ""w1_" "w5_" """
foreach y of local FILE {

g D`y'CEQ_currentd = `y'CEQ_current - `y'NI_current + DIV_current
g D`y'CEQd = `y'CEQ_lag - `y'NI_lag + DIV_lag
g D`y'delta_CEQ_3 = (D`y'CEQ_currentd - D`y'CEQd)

}

replace Ddelta_CEQ_3 = Ddelta_CEQ_3 / 1000000
replace Dw1_delta_CEQ_3 = Dw1_delta_CEQ_3 / 1000000
replace Dw5_delta_CEQ_3 = Dw5_delta_CEQ_3 / 1000000

// Treatment Variables for Tables 6-8 [Ranking[50–X;50+X]
local b 5
g treatment_`b' = 1 if position_ranking<=`b' & position_ranking>=-`b'
replace treatment_`b' = 0 if treatment_`b' ==.

local b 10
g treatment_`b' = 1 if position_ranking<=`b' & position_ranking>=-`b'
replace treatment_`b' = 0 if treatment_`b' ==.

local b 15
g treatment_`b' = 1 if position_ranking<=`b' & position_ranking>=-`b'
replace treatment_`b' = 0 if treatment_`b' ==.

local b 20
g treatment_`b' = 1 if position_ranking<=`b' & position_ranking>=-`b'
replace treatment_`b' = 0 if treatment_`b' ==.

local b 25
g treatment_`b' = 1 if position_ranking<=`b' & position_ranking>=-`b'
replace treatment_`b' = 0 if treatment_`b' ==.

local b 30
g treatment_`b' = 1 if position_ranking<=`b' & position_ranking>=-`b'
replace treatment_`b' = 0 if treatment_`b' ==.

save "ASEAN_working_file.dta", replace

*****************************************************
* Cleaning shares outstanding for Table 5 Coll. 3-4 *
*****************************************************

use "number_shares_tempI.dta", clear
g datevar = date(date_s, "DMY")
format datevar %d

bysort year month isin: egen max_datevar = max(datevar)
format max_datevar %d

g quarter = 1 if month =="jan" | month =="feb" | month =="mar"
replace quarter = 2 if month =="apr" | month =="may" | month =="jun"
replace quarter = 3 if month =="jul" | month =="aug" | month =="sep"
replace quarter = 4 if month =="oct" | month =="nov" | month =="dec"

bysort year quarter isin: egen max_datevarDEF = max(max_datevar)
format max_datevarDEF %d

save "shares_LHS_temp.dta", replace

// 2015 Edition (2015 assessment)
use shares_LHS_temp.dta, clear

rename max_datevarDEF rq  
keep if rq==d(31dec2015) | /// t
rq==d(30sep2015) | /// t-1
rq==d(30jun2015) | /// t-2
rq==d(31mar2015) | /// t-3
rq==d(31dec2014) | /// t-4 
rq==d(31mar2016) | /// t+1
rq==d(30jun2016) | /// t+2
rq==d(30sep2016) | /// t+3
rq==d(30dec2016)    // t+4

g T = "0" if rq==d(31dec2015)
replace T = "m1" if rq==d(30sep2015)
replace T = "m2" if rq==d(30jun2015)
replace T = "m3" if rq==d(31mar2015)
replace T = "m4" if rq==d(31dec2014)
replace T = "p1" if rq==d(31mar2016)
replace T = "p2" if rq==d(30jun2016)
replace T = "p3" if rq==d(30sep2016)
replace T = "p4" if rq==d(30dec2016)

g date_to_merge = d(31dec2015)
format %td date_to_merge

keep isin shares quarter rq T date_to_merge

bysort isin T: egen mean_shares = mean(shares)
bysort isin T: egen med_shares = median(shares)
bysort isin T: g ok = 1 if T==T[_n+1]
keep if ok ==.
drop ok quarter rq shares

reshape wide med_shares mean_shares , i(isin) j(T) string

save "shares_LHS_temp2015.dta", replace

// 2014 Edition (2014 assessment)
use shares_LHS_temp.dta, clear

rename max_datevarDEF rq  
keep if rq==d(31dec2014) | /// t
rq==d(30sep2014) | /// t-1
rq==d(30jun2014) | /// t-2
rq==d(31mar2014) | /// t-3
rq==d(31dec2013) | /// t-4 
rq==d(31mar2015) | /// t+1
rq==d(30jun2015) | /// t+2
rq==d(30sep2015) | /// t+3
rq==d(31dec2015)    // t+4

g T = "0" if rq==d(31dec2014)
replace T = "m1" if rq==d(30sep2014)
replace T = "m2" if rq==d(30jun2014)
replace T = "m3" if rq==d(31mar2014)
replace T = "m4" if rq==d(31dec2013)
replace T = "p1" if rq==d(31mar2015)
replace T = "p2" if rq==d(30jun2015)
replace T = "p3" if rq==d(30sep2015)
replace T = "p4" if rq==d(31dec2015)

g date_to_merge = d(31dec2014)
format %td date_to_merge

keep isin shares quarter rq T date_to_merge

bysort isin T: egen mean_shares = mean(shares)
bysort isin T: egen med_shares = median(shares)
bysort isin T: g ok = 1 if T==T[_n+1]
keep if ok ==.
drop ok quarter rq shares

reshape wide med_shares mean_shares , i(isin) j(T) string

save "shares_LHS_temp2014.dta", replace

// 2013 Edition (2013 assessment)
use shares_LHS_temp.dta, clear

rename max_datevarDEF rq  
keep if rq==d(30jun2014) | /// t
rq==d(31mar2014) | /// t-1
rq==d(31dec2013) | /// t-2
rq==d(30sep2013) | /// t-3
rq==d(28jun2013) | /// t-4 
rq==d(30sep2014) | /// t+1
rq==d(31dec2014) | /// t+2
rq==d(31mar2015) | /// t+3
rq==d(30jun2015)    // t+4

g T = "0" if rq==d(30jun2014)
replace T = "m1" if rq==d(31mar2014)
replace T = "m2" if rq==d(31dec2013)
replace T = "m3" if rq==d(30sep2013)
replace T = "m4" if rq==d(28jun2013)
replace T = "p1" if rq==d(30sep2014)
replace T = "p2" if rq==d(31dec2014)
replace T = "p3" if rq==d(31mar2015)
replace T = "p4" if rq==d(30jun2015)

g date_to_merge = d(30jun2014)
format %td date_to_merge

keep isin shares quarter rq T date_to_merge

bysort isin T: egen mean_shares = mean(shares)
bysort isin T: egen med_shares = median(shares)
bysort isin T: g ok = 1 if T==T[_n+1]
keep if ok ==.
drop ok quarter rq shares

reshape wide med_shares mean_shares , i(isin) j(T) string

save "shares_LHS_temp2013.dta", replace

// 2012 Edition (2012 assessment)
use shares_LHS_temp.dta, clear

rename max_datevarDEF rq  

keep if rq==d(28jun2013) | /// t
rq==d(29mar2013) | /// t-1
rq==d(31dec2012) | /// t-2
rq==d(28sep2012) | /// t-3
rq==d(29jun2012) | /// t-4 
rq==d(30sep2013) | /// t+1
rq==d(31dec2013) | /// t+2
rq==d(31mar2014) | /// t+3
rq==d(30jun2014)    // t+4

g T = "0" if rq==d(28jun2013)
replace T = "m1" if rq==d(29mar2013)
replace T = "m2" if rq==d(31dec2012)
replace T = "m3" if rq==d(28sep2012)
replace T = "m4" if rq==d(29jun2012)
replace T = "p1" if rq==d(30sep2013)
replace T = "p2" if rq==d(31dec2013)
replace T = "p3" if rq==d(31mar2014)
replace T = "p4" if rq==d(30jun2014)

g date_to_merge = d(30jun2013)
format %td date_to_merge

keep isin shares quarter rq T date_to_merge

bysort isin T: egen mean_shares = mean(shares)
bysort isin T: egen med_shares = median(shares)
bysort isin T: g ok = 1 if T==T[_n+1]
keep if ok ==.
drop ok quarter rq shares

reshape wide med_shares mean_shares , i(isin) j(T) string

save "shares_LHS_temp2012.dta", replace

// 2017 Edition (2017 assessment)
use shares_LHS_temp.dta, clear

rename max_datevarDEF rq  

keep if rq==d(31dec2018) | /// t
rq==d(28sep2018) | /// t-1
rq==d(29jun2018) | /// t-2
rq==d(30mar2018) | /// t-3
rq==d(29dec2017) | /// t-4 
rq==d(31mar2019) | /// t+1
rq==d(30jun2019) | /// t+2
rq==d(30sep2019) | /// t+3
rq==d(31dec2019)    // t+4

g T = "0" if rq==d(31dec2018)
replace T = "m1" if rq==d(28sep2018)
replace T = "m2" if rq==d(29jun2018)
replace T = "m3" if rq==d(30mar2018)
replace T = "m4" if rq==d(29dec2017)
replace T = "p1" if rq==d(31mar2019)
replace T = "p2" if rq==d(30jun2019)
replace T = "p3" if rq==d(30sep2019)
replace T = "p4" if rq==d(31dec2019)

g date_to_merge = d(31dec2018)
format %td date_to_merge

keep isin shares quarter rq T date_to_merge

bysort isin T: egen mean_shares = mean(shares)
bysort isin T: egen med_shares = median(shares)
bysort isin T: g ok = 1 if T==T[_n+1]
keep if ok ==.
drop ok quarter rq shares

reshape wide med_shares mean_shares , i(isin) j(T) string

save "shares_LHS_temp2017.dta", replace

use shares_LHS_temp2012, clear
append using shares_LHS_temp2013
append using shares_LHS_temp2014
append using shares_LHS_temp2015
append using shares_LHS_temp2017

local Ys mean_shares med_shares 
local Ps 0 m1 m2 m3 m4 p1 p2 p3 p4
foreach y of local Ys {
foreach p of local Ps {
replace `y'`p' = 0 if `y'`p'==.
}
}

foreach y of local Ys {

// post PLUS 1
egen `y'_post1 = rowmean(`y'p1)
// post PLUS 2
egen `y'_post2 = rowmean(`y'p2) 
// post AVG. PLUS 0 - 1 - 2
egen `y'_post1b = rowmean(`y'0 `y'p1 `y'p2)
// post AVG. PLUS 1 - 2
egen `y'_post2b = rowmean(`y'p1 `y'p2)

// pre MINUS 1
egen `y'_pre1 = rowmean(`y'm1)
// pre MINUS 2
egen `y'_pre2 = rowmean(`y'm2)
// pre MINUS 3
egen `y'_pre1b = rowmean(`y'm3)
// pre AVG. MINUS 1 - 2
egen `y'_pre2b = rowmean(`y'm1 `y'm2)

}

drop if isin == ""
duplicates tag isin date_to_merge, gen(flag)
tab flag

save "shares_full_wide_isin.dta", replace

cd "G:\Dropbox (IESE)\ASEAN"
use "ASEAN_working_file.dta", clear
capture drop merge_*
merge 1:1 isin date_to_merge using "shares_full_wide_isin.dta"
drop if _merge == 2

replace mean_shares_post1b = mean_shares_post1b / 1000
replace mean_shares_pre1 = mean_shares_pre1 / 1000
g dif_post1shares_mean = mean_shares_post1b - mean_shares_pre1
replace dif_post1shares_mean = 0 if dif_post1shares_mean==.

save "ASEAN_working_fileII.dta", replace

**************************************
* Cleaning stock returns for Table 9 *
**************************************

cd "G:\Dropbox (IESE)\ASEAN"
use "stock_price_data.dta", clear

// gen firm returns
sort isin datevar
by isin: g ret_firm = log(price/price[_n-1])
replace ret_firm = 0 if ret_firm==.

g adj_ret = ret_firm - ret_mkt

* CAR[0]
sort isin datevar
g car_1 = adj_ret

* CAR[0,1]
sort isin datevar
by isin: g car_3 = adj_ret + adj_ret[_n+1]

* CAR[-3,3]
sort isin datevar
by isin: g car_5 = adj_ret + adj_ret[_n+1] + adj_ret[_n-1] + adj_ret[_n-2] + adj_ret[_n-3] + adj_ret[_n+2] + adj_ret[_n+3]

keep if (datevar == event_2012) | (datevar == event_2013) | (datevar == event_2014) | (datevar == event_2015) | (datevar == event_2017)
bysort isin file_year: g ok = 1 if file_year==file_year[_n+1]
keep if ok ==.
compress
save "car.dta", replace

cd "G:\Dropbox (IESE)\ASEAN"
use "ASEAN_working_fileII.dta", clear
capture drop merge_*
merge 1:1 isin file_year using "car.dta", gen(_merge_car)
drop if _merge_car == 2

replace car_1 = 0 if car_1 ==.
replace car_3 = 0 if car_3 ==.
replace car_5 = 0 if car_5 ==.
winsor car_1, gen(w1car_1) p(0.01)
winsor car_3, gen(w1car_3) p(0.01)
winsor car_5, gen(w1car_5) p(0.01)

save "ASEAN_working_fileIII.dta", replace

**********************************************
* Cleaning X-sectional variables for Table 3 *
**********************************************

clear
set more off
cd "G:\Dropbox (IESE)\ASEAN"
use "wgidataset.dta" // Regulatory Quality and Rule of Law
keep if year == 2010
keep if countryname =="Indonesia" | ///
countryname =="Malaysia" | ///
countryname =="Philippines" | ///
countryname =="Singapore" | ///
countryname =="Thailand" | ///
countryname =="Vietnam"
br countryname rqe rle
tab rqe 
tab rle
rename countryname Country
keep Country rqe rle
g high_rle = 1 if Country=="Malaysia" | Country=="Singapore" // Cross-sectional variable for Table 3 Panel A
replace high_rle = 0 if high_rle==.
replace Country = "Philipines" if Country =="Philippines"
save "wgidataset_cleaned.dta", replace

clear
set more off
cd "G:\Dropbox (IESE)\ASEAN"
use "ASEAN_working_fileIII.dta", clear

// Cross-sectional variable for Table 3 Panel A
merge m:1 Country using "wgidataset_cleaned.dta", gen(_merge_d)
drop if _merge_d == 2
drop _merge_d

// number of analysts
merge m:1 isin file_year using "following_def_DEF.dta", gen(_merge_d)
drop if _merge_d == 2
drop _merge_d

replace tot_following = 0 if tot_following ==.

	g high_following =. // Cross-sectional variable for Table 3 Panel B
	forval i = 1/25 { // by country-year
	su tot_following if year_country_fe == `i', d
	g high_following`i' = 1 if tot_following>=r(p50) & year_country_fe == `i'
	replace high_following`i' = 0 if high_following`i'  ==. & year_country_fe == `i' 
	replace high_following =  high_following`i' if year_country_fe == `i'
	}

save "ASEAN_final_file.dta", replace
