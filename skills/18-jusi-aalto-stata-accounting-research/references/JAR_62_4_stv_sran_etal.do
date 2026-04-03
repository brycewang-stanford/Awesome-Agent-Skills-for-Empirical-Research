clear all
macro drop _all
set more off

pause off

//File calls
global MAIN "Insert file path"
global DATA "Insert file path"
global OUTPUT "Insert file path"
global MAINDO "Insert file path"

//Prepare capital market data
use "$DATA/quarterly_dataset.dta", clear

rename dscode dscd
rename ffnum ind_ff
rename yearqtr date
rename qtr qrtr
rename country country_ds
gen yearqtr = qofd(date)
	format yearqtr %tq
	
sort dscd year qrtr	

//Drop missing identifiers
drop if dscd == ""  
drop if yearqtr == .   
drop if seccode == .  
drop if id == "" 

// Drop conflicting dscd
drop if seccode == 2467258 
drop if seccode == 332743 

//Drop nonsample countries
drop if inlist(exchctrycode,"BA","CH","ME","MK","RS","RU","UA") 

// Exchange codes
merge m:1 exchintcode exchctrycode using "$DATA/exchange_ids.dta"
drop if _merge == 2
drop _merge

sort dscd exchintcode year qrtr

by dscd exchintcode, sort: gen exch_tag = _n ==1
by dscd: replace exch_tag = sum(exch_tag)
by dscd: replace exch_tag = exch_tag[_N] 
by dscd exchintcode, sort: egen exch_max = max(yearqtr)
	format exch_max %tq
by dscd exchintcode, sort: egen exch_min = min(yearqtr)
	format exch_min %tq

//Regulated firms (reflected in final sample identifiers, see readme)
merge m:1 dscd year qrtr using "$DATA/Core_data/regulatedfirms.dta"
drop if _merge == 2
drop _merge

sort dscd year qrtr

by dscd: egen max_reg_indicator = max(reg_indicator)
gen reg_indicator_final = 0
replace reg_indicator_final = 1 if max_reg_indicator == 1
replace reg_indicator = 0 if reg_indicator == .
drop max_reg_indicator


gen country = exchctrycode
replace country = "Austria" if country == "AT"
replace country = "Belgium" if country == "BE"
replace country = "Bulgaria" if country == "BG"
replace country = "Cyprus" if country == "CY"
replace country = "Czech Republic" if country == "CZ"
replace country = "Germany" if country == "DE"
replace country = "Denmark" if country == "DK"
replace country = "Estonia" if country == "EE"
replace country = "Spain" if country == "ES"
replace country = "Finland" if country == "FI"
replace country = "France" if country == "FR"
replace country = "United Kingdom" if country == "GB"
replace country = "Greece" if country == "GR"
replace country = "Croatia" if country == "HR"
replace country = "Hungary" if country == "HU"
replace country = "Ireland" if country == "IE"
replace country = "Iceland" if country == "IS"
replace country = "Italy" if country == "IT"
replace country = "Lithuania" if country == "LT"
replace country = "Luxembourg" if country == "LU"
replace country = "Latvia" if country == "LV"
replace country = "Malta" if country == "MT"
replace country = "Netherlands" if country == "NL"
replace country = "Norway" if country == "NO"
replace country = "Poland" if country == "PL"
replace country = "Portugal" if country == "PT"
replace country = "Romania" if country == "RO"
replace country = "Sweden" if country == "SE"
replace country = "Slovenia" if country == "SI"
replace country = "Slovak Republic" if country == "SK"

//GDP
sort country year
merge m:1 country year using "$DATA/Core_data/GDP_Data", gen(_merge_gdp)
drop if _merge_gdp == 2 
drop _merge_gdp

//Panel
rename qrtr qtr
sort dscd year qtr
gen month = 1 if qtr == 1
replace month = 4 if qtr == 2
replace month = 7 if qtr == 3
replace month = 10 if qtr == 4
replace yearqtr = qofd(mdy(month,1,year))
	format yearqtr %tq
drop month
encode dscd, gen(firm_id)
tsset firm_id yearqtr
		
sort dscd year qtr

// Zero returns     
gen double zero = zero_trade_ret/trading_days_cor
gen double zero_vol = zero_trade_vol/trading_days_cor
replace zero = . if zero < 0
replace zero_vol = . if zero_vol < 0


// Bid-ask spreads
replace spread = . if spread < 0
replace spread = . if spread == 0
gen double ln_spread = ln(spread)

sort firm_id yearqtr

// Market value
by firm_id: gen double mv_eur_l4 = l4.mv_eur/1000000
gen double ln_mv_eur_l4 = ln(mv_eur_l4)

by firm_id: gen double mv_usd_l4 = l4.mv_usd/1000000
gen double ln_mv_usd_l4 = ln(mv_usd_l4)


// Return volatility
by firm_id: gen double ret_vol_l4 = l4.ret_vol
gen double ln_sd_ret_l4 = ln(ret_vol_l4) 

// Share turnover
gen double turnover = share_turnover*1000
by firm_id: gen double turnover_l4 = l4.turnover
gen double ln_turnover_l4 = ln(turnover_l4)

// GDP per capita
by firm_id: gen double gdpc_l4 = l4.gdpc/1000
gen double ln_gdpc_l4 = ln(gdpc_l4)	

// Winsorize	
sort country dscd year qtr

foreach var in spread ln_spread zero mv_usd_l4 ln_mv_usd_l4 ret_vol_l4 ln_sd_ret_l4 turnover_l4 ln_turnover_l4 ///
{
	by country: egen double p1_`var' = pctile(`var'), p(1)
	by country: egen double p9_`var' = pctile(`var'), p(99)
	gen double `var'_initial = `var'
	replace `var' = p9_`var' if `var'>p9_`var' & `var'!=.
	replace `var' = p1_`var' if `var'<p1_`var' & `var'!=.
	drop p1_`var' p9_`var'
}	

// Industry variables
sort firm_id yearqtr
by firm_id: egen minsic=min(sic_1)
by firm_id: egen maxsic=max(sic_1)
gen diff_ind = maxsic-minsic
	replace sic_1 = maxsic if diff_ind==0 & sic_1==.
drop minsic maxsic diff_ind


tostring sic_1, gen(sic_1string)
replace sic_1string="" if sic_1string=="."
gen sic2dig = substr(sic_1string, 1, 2) if length(sic_1string)==4
replace sic2dig = substr(sic_1string,1,1) if length(sic_1string)==3
destring sic2dig, replace
drop sic_1string

ffind sic_1, newvar(ff12) type(12) 
egen industry_ff = group(ff12) 
egen industry = group(sic2dig)

gen campbell_ind= 1 if sic2dig == 13 | sic2dig==29
	replace campbell_ind= 2 if sic2dig>=60 & sic2dig<=69
	replace campbell_ind= 3 if sic2dig == 25 | sic2dig == 30 | (sic2dig>=36 & sic2dig<=37) | sic2dig == 39 | sic2dig==50 | sic2dig==55 | sic2dig==57
	replace campbell_ind= 4 if sic2dig == 8 | sic2dig == 10 | sic2dig == 12 | sic2dig == 14 | sic2dig == 24 | sic2dig == 26 | sic2dig == 28 | sic2dig == 33
	replace campbell_ind= 5 if sic2dig == 1 | sic2dig == 2 | sic2dig == 7 | sic2dig == 9 | sic2dig == 20 | sic2dig == 21 | sic2dig == 54
	replace campbell_ind= 6 if (sic2dig >=15 & sic2dig <=17) | sic2dig == 32 | sic2dig == 52 
	replace campbell_ind= 7 if (sic2dig >= 34 & sic2dig <= 35) | sic2dig == 38
	replace campbell_ind= 8 if (sic2dig >= 40 & sic2dig <= 42) | sic2dig == 44 | sic2dig == 45 | sic2dig == 47
	replace campbell_ind= 9 if sic2dig == 46 | sic2dig == 48 | sic2dig == 49
	replace campbell_ind= 10 if (sic2dig >= 22 & sic2dig <= 23) | sic2dig == 31 | sic2dig == 51 | sic2dig == 53 | sic2dig == 56 | sic2dig == 59
	replace campbell_ind= 11 if (sic2dig >= 72 & sic2dig <= 73) | sic2dig == 75 | sic2dig == 76 | sic2dig == 80 | sic2dig == 81 | sic2dig == 82 | sic2dig == 82 | sic2dig == 83 | sic2dig == 87 | sic2dig == 89
	replace campbell_ind= 12 if (sic2dig >= 78 & sic2dig <= 79) | sic2dig == 27 | sic2dig == 58 | sic2dig == 70 | sic2dig == 84
		
egen industry_cam = group(campbell_ind)
drop campbell_ind

foreach var in industry_cam industry_ff ///
{
	by firm_id: egen mode_`var'= mode(`var')
		replace `var' = mode_`var' if `var' != mode_`var'
}

//Quarterly implementation dates (see readme)
gen OAMDATE = mdy(4,1,2007) if exchctrycode == "AT"
replace OAMDATE = mdy(1,1,2011) if exchctrycode == "BE"
replace OAMDATE = mdy(10,1,2012) if exchctrycode == "CY"
replace OAMDATE = mdy(7,1,2009) if exchctrycode == "CZ"
replace OAMDATE = mdy(4,1,2007) if exchctrycode == "DK"
replace OAMDATE =  mdy(10,1,2007) if exchctrycode == "FI"
replace OAMDATE =  mdy(4,1,2009) if exchctrycode == "FR"
replace OAMDATE =  mdy(1,1,2007) if exchctrycode == "DE"
replace OAMDATE = mdy(4,1,2007) if exchctrycode == "GR"
replace OAMDATE = mdy(1,1,2008) if exchctrycode == "IS"
replace OAMDATE = mdy(4,1,2007) if exchctrycode == "IE"
replace OAMDATE = mdy(4,1,2009) if exchctrycode == "IT"
replace OAMDATE = mdy(4,1,2007) if exchctrycode == "LV"
replace OAMDATE = mdy(1,1,2008) if exchctrycode == "LT"
replace OAMDATE = mdy(1,1,2009) if exchctrycode == "LU"
replace OAMDATE = mdy(1,1,2009) if exchctrycode == "NL" 
replace OAMDATE = mdy(1,1,2008) if exchctrycode == "NO"
replace OAMDATE = mdy(1,1,2009) if exchctrycode == "PL"
replace OAMDATE = mdy(10,1,2007) if exchctrycode == "PT"
replace OAMDATE = mdy(7,1,2007) if exchctrycode == "ES"
replace OAMDATE = mdy(7,1,2007) if exchctrycode == "SE"
replace OAMDATE = mdy(7,1,2010) if exchctrycode == "GB"
format OAMDATE %td	

gen TPDDATE = mdy(4,1,2007) if exchctrycode == "AT"
replace TPDDATE = mdy(7,1,2008) if exchctrycode == "BE"
replace TPDDATE = mdy(1,1,2007) if exchctrycode == "BG"
replace TPDDATE = mdy(7,1,2009) if exchctrycode == "CY"
replace TPDDATE = mdy(7,1,2009) if exchctrycode == "CZ"
replace TPDDATE = mdy(4,1,2007) if exchctrycode == "DK"
replace TPDDATE = mdy(10,1,2007) if exchctrycode == "EE"
replace TPDDATE = mdy(1,1,2007) if exchctrycode == "FI"
replace TPDDATE = mdy(10,1,2007) if exchctrycode == "FR"
replace TPDDATE = mdy(1,1,2007) if exchctrycode == "DE"
replace TPDDATE = mdy(4,1,2007) if exchctrycode == "GR"
replace TPDDATE = mdy(10,1,2007) if exchctrycode == "HU"
replace TPDDATE = mdy(10,1,2007) if exchctrycode == "IS"
replace TPDDATE = mdy(4,1,2007) if exchctrycode == "IE"
replace TPDDATE = mdy(4,1,2009) if exchctrycode == "IT"
replace TPDDATE = mdy(4,1,2007) if exchctrycode == "LV"
replace TPDDATE = mdy(1,1,2007) if exchctrycode == "LT"
replace TPDDATE = mdy(1,1,2008) if exchctrycode == "LU"
replace TPDDATE = mdy(7,1,2007) if exchctrycode == "MT"
replace TPDDATE = mdy(1,1,2009) if exchctrycode == "NL"
replace TPDDATE = mdy(1,1,2008) if exchctrycode == "NO"
replace TPDDATE = mdy(1,1,2009) if exchctrycode == "PL"
replace TPDDATE = mdy(10,1,2007) if exchctrycode == "PT"
replace TPDDATE = mdy(1,1,2007) if exchctrycode == "RO"
replace TPDDATE = mdy(4,1,2007) if exchctrycode == "SK"
replace TPDDATE = mdy(10,1,2007) if exchctrycode == "SI"
replace TPDDATE = mdy(7,1,2007) if exchctrycode == "ES"
replace TPDDATE = mdy(7,1,2007) if exchctrycode == "SE"
replace TPDDATE = mdy(1,1,2007) if exchctrycode == "GB"
replace TPDDATE = mdy(1,1,2009) if exchctrycode == "HR"
format TPDDATE %td


// Determine post variables
gen OAMDATE_q = qofd(OAMDATE)
	format OAMDATE_q %tq

gen TPDDATE_q = qofd(TPDDATE)
	format TPDDATE_q %tq

	
gen month = 3 if qtr==1
replace month = 6 if qtr==2
replace month = 9 if qtr==3
replace month = 12 if qtr==4

gen day=31 if qtr==1 |qtr==4
replace day =30 if qtr==3 | qtr==2

gen date_mdy = mdy(month, day, year)
	format date_mdy %td
drop day month

sort dscd date_mdy

gen oam_ind = 0 if OAMDATE!=.
gen tpd_ind = 0 if TPDDATE!=.

replace oam_ind = 1 if OAMDATE_q <= yearqtr & OAMDATE != .
replace tpd_ind = 1 if TPDDATE_q <=  yearqtr  & TPDDATE != .

gen oam_country_ind = 1
replace oam_country_ind = 0 if OAMDATE==.

gen tpdoam_diff = 0 if oam_ind != . & tpd_ind != .
replace tpdoam_diff = 1 if oam_ind!=tpd_ind & oam_ind != . & tpd_ind != .
sort country dscd yearqtr
by country: egen tpdoam_diffquarter = total(tpdoam_diff), m
replace tpdoam_diffquarter=1 if tpdoam_diffquarter>0 & tpdoam_diffquarter != .
gen tpdoam_samequarter=abs(tpdoam_diffquarter-1)
	
drop tpdoam_diff	


rename country country_txt
encode country_txt, gen(country)

saveold "$DATA/quarterly_dataset_processed", replace


//Draw identifiers
use "$DATA/quarterly_dataset_processed.dta", clear

keep isin yearqtr seccode dscd OAMDATE_q year

egen tagger = tag(isin yearqtr)

drop if tagger == 0

keep if year >= 2001 & year <= 2015

saveold "$DATA/quarterly_dataset_processed_identifiers.dta", replace


use "$DATA/quarterly_dataset_processed.dta", clear

//Sample restrictions 
drop if exchctrycode == "CZ" | exchctrycode == "GB"
drop if exchname == "IBIS (XETRA)"
keep if reg_indicator_final == 1
keep if oam_ind != .
drop if industry_cam == .
drop if zero == .
drop if spread == .
keep if year >= 2001 & year <= 2015

//Dummies
egen country_industry = group(country industry_cam)
egen country_year = group(country year)
gen tpdoam_ind = tpdoam_samequarter*tpd_ind
gen bundled_ind = tpdoam_ind

//Factor calculation
factor spread zero
predict f1, reg norotate
gen liq_fac=f1
drop f1

tabstat liq_fac, statistics( min p50 max )

gen ln_liq_fac = ln(liq_fac + 1)
gen ihs_liq_fac_no = ln(liq_fac + sqrt(liq_fac^2 + 1))

//Missing control variables
drop if ln_mv_usd_l4 == . | ln_turnover_l4 == . | ln_sd_ret_l4 ==. | ln_gdpc_l4 == .

//Time variables
gen t = yearqtr
replace t = t-163
gen t2 = t^2

	
//Regression sample excluding firm-level singletons
preserve
	
	reghdfe ln_liq_fac oam_ind tpd_ind bundled_ind ln_mv_usd_l4 ln_turnover_l4 ln_sd_ret_l4 ln_gdpc_l4 , nocons absorb(firm_id yearqtr) cluster(country#industry_cam yearqtr)
		
	keep if e(sample)
	
	keep dscd yearqtr industry_cam
	
	gen sample_ind = 1
	
	sort dscd yearqtr
	
	rename industry_cam industry_cam_forcm
	
	saveold "$DATA/sample_ind.dta", replace

restore

	
merge m:1 dscd yearqtr using "$DATA/sample_ind.dta"
	drop _merge	
	
keep if sample_ind == 1


preserve
	keep isin yearqtr seccode dscd country_txt ln_mv_usd_l4 ln_sd_ret_l4 ln_turnover_l4 ln_gdpc_l4 industry_cam oam_ind tpd_ind country bundled_ind ln_liq_fac OAMDATE OAMDATE_q tpdoam_samequarter

	saveold "$DATA/analysis_sample_identifiers.dta", replace
restore


//Event dates
preserve

	use "$DATA/annual_report_all_events.dta", clear

	gen yearqtr = qofd(eps_rdate)

	format yearqtr %tq

	sort dscode yearqtr
	
	gen dscd = dscode
	drop dscode
	drop year exchintcode infocode seccode typ exchctrycode
	rename eps_rdate focal_event_date
	saveold "$DATA/formerge_annual_report_all_events.dta", replace

restore

merge 1:1 dscd yearqtr using "$DATA/formerge_annual_report_all_events.dta"
	drop if _merge == 2

drop _merge


preserve
	keep if focal_event_date != .
	keep dscd yearqtr firm_id focal_event_date country_txt country industry_cam oam_ind tpd_ind bundled_ind ln_mv_usd_l4 ln_turnover_l4 ln_sd_ret_l4 ln_gdpc_l4 ln_liq_fac zero OAMDATE_q
	
	saveold "$DATA/analysis_sample_annual_events.dta", replace
restore


saveold "$DATA/analysis_sample.dta", replace
//File calls
global MAIN "Insert file path"
global DATA "Insert file path"
global OUTPUT "Insert file path"
global MAINDO "Insert file path"
global path "Insert file path"

//Import
forvalues yr=2001/2015 ///
{
cd "$path\raw data"
unzipfile "RPNA_DJEdition_`yr'_4.0-Equities.zip", replace
local allfiles : dir "$path\raw data\RPNA_DJEdition_`yr'_4.0-Equities\" files "*.csv"  
tempfile building
clear
cd "$path\raw data\RPNA_DJEdition_`yr'_4.0-Equities"
save `building', emptyok
foreach f of local allfiles {
	import delimited using `f', clear
	
	keep timestamp relevance topic group aev isin nip news_type
	gen year = `yr'
	order isin year timestamp relevance aev nip topic group news_type  
	append using `building'
	save `building', replace
}

foreach mth in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" ///
{
	capture erase "$path\raw data\RPNA_DJEdition_`yr'_4.0-Equities/`yr'-`mth'-equities.csv"
}


saveold "$path/cleaning and merging/ravenpack_`yr'.dta", replace

}

//Append
clear
save "$path/cleaning and merging/ravenpack_20012015", emptyok replace
forvalues yr=2001/2015 ///
{
append using "$path/cleaning and merging/ravenpack_`yr'.dta"
}

gen date=substr(timestamp_utc,1,10)
gen date2=date(date, "YMD") 
drop date
rename date2 date
format %td date
order isin date
drop timestamp_utc

saveold "$DATA/Core_data/ravenpack_20012015", replace

//Keep
use "$DATA/Core_data/ravenpack_20012015", clear
gen counter = 1
gen yearqtr = qofd(date)
format yearqtr %tq
drop if isin == ""

drop if news_type == "PRESS-RELEASE"
tab news_type
keep if topic == "business"
collapse (sum) counter, by(isin yearqtr)

saveold "$DATA/collapsed_ravenpack_20012015", replace


//Process
use "$DATA/collapsed_ravenpack_20012015", replace


merge 1:1 isin yearqtr using "$DATA/quarterly_dataset_processed_identifiers.dta", gen(_merge_identifiers)
tab _merge

byso isin: egen max_merge = max(_merge)
		
drop if max_merge == 1

fillin isin yearqtr

merge 1:1 isin yearqtr using "$DATA/quarterly_dataset_processed_identifiers.dta", gen(_merge_identifiers2) update
	
byso isin: egen max_merge2 = max(_merge_identifiers2)

byso isin: egen dscd_fill = mode(dscd)

replace dscd = dscd_fill if dscd == ""

egen firm_id = group(dscd)

byso dscd: egen OAMDATE_q_fill = mode(OAMDATE_q)

replace OAMDATE_q = OAMDATE_q_fill if OAMDATE_q == .
	
replace counter = 0 if counter == .
	gen ln_coverage = ln(1 + counter)
	rename counter coverage

sort firm_id yearqtr

gen date_coverage = yearqtr if coverage != 0
	format date_coverage %tq
by firm_id: egen min_date_coverage = min(date_coverage)
	format min_date_coverage %tq
	tab min_date_coverage

gen coverage_starts_after = .
	replace coverage_starts_after = 0 if min_date_coverage < OAMDATE_q
	replace coverage_starts_after = 1 if min_date_coverage >= OAMDATE_q & min_date_coverage != . & OAMDATE_q != .

gen pre_coverage = coverage if yearqtr < OAMDATE_q
byso firm_id: egen max_pre_coverage = max(pre_coverage)

keep dscd yearqtr coverage ln_coverage coverage_starts_after max_pre_coverage

order dscd yearqtr coverage ln_coverage coverage_starts_after max_pre_coverage


saveold "$DATA/formerge_ravenpack.dta", replace

clear all
macro drop _all
set more off

pause off

//File calls
global DATA "Insert file path"
global WORK "Insert file path"

//Crosswalks
use "$DATA/sym_v1.sym_isin_hist.csv.dta", clear 

sort fsym_id isin

by fsym_id isin, sort: gen nvals = _n == 1
by fsym_id: replace nvals = sum(nvals)
by fsym_id: replace nvals = nvals[_N] 

gen fsym_id_multiple_isin = 0
	replace fsym_id_multiple_isin = 1 if nvals > 1

order fsym_id isin fsym_id_multiple_isin nvals  	
	
save "$WORK/Factset_isin_list", replace


use "$DATA/analysis_sample_identifiers.dta", clear 

keep dscd isin yearqtr country_txt

			rename country_txt country
	
			replace country = "AT" if country == "Austria" 
			replace country = "BE" if country == "Belgium" 
			replace country = "BG" if country == "Bulgaria" 
			replace country = "CY" if country == "Cyprus"
			replace country = "CZ" if country == "Czech Republic"
			replace country = "DE" if country == "Germany"
			replace country = "DK" if country == "Denmark" 
			replace country = "EE" if country == "Estonia" 
			replace country = "ES" if country == "Spain"
			replace country = "FI" if country == "Finland"
			replace country = "FR" if country == "France"
			replace country = "GB" if country == "United Kingdom"
			replace country = "GR" if country == "Greece"
			replace country = "HR" if country == "Croatia" 
			replace country = "HU" if country == "Hungary" 
			replace country = "IE" if country == "Ireland" 
			replace country = "IS" if country == "Iceland" 
			replace country = "IT" if country == "Italy" 
			replace country = "LT" if country == "Lithuania"  
			replace country = "LU" if country == "Luxembourg" 
			replace country = "LV" if country =="Latvia" 
			replace country = "MT" if country == "Malta"  
			replace country = "NL" if country == "Netherlands" 
			replace country = "NO" if country == "Norway" 
			replace country = "PL" if country == "Poland"  
			replace country = "PT" if country == "Portugal"  
			replace country = "RO" if country == "Romania"  
			replace country = "SE" if country == "Sweden" 
			replace country = "SI" if country == "Slovenia"  
			replace country = "SK" if country == "Slovak Republic" 

save "$WORK/Datastream_sample_ids", replace

//Merge
use "$WORK/Datastream_sample_ids", clear

sort isin yearqtr

	merge m:1 isin using "$WORK/Factset_isin_list", gen(_merge)
	drop if _merge == 2
	
	gen isin_match = 0
		replace isin_match = 1 if _merge == 3
	
	drop _merge

	order dscd isin fsym_id yearqtr
	
	drop fsym_id_multiple_isin nvals start_date end_date most_recent isin_match

	save "$WORK/Datastream_Factset_merge_ids", replace
	
	drop if fsym_id == ""
		
		collapse (firstnm) country, by(fsym_id)
						
		sort fsym_id

		save "$WORK/Datastream_Factset_merge_unique_ids", replace

//Sample selection
use "$DATA/own_fund_detail.csv.dta", clear

	sort fsym_id
	
	merge m:1 fsym_id using "$WORK/Datastream_Factset_merge_unique_ids", gen(_merge)
	
	drop if _merge == 1 	
	drop if _merge == 2
	
	replace adj_holding = reported_holding if adj_holding == .
		replace adj_holding = reported_holding if adj_holding <= 0
		drop if adj_holding <= 0
	replace adj_mv = reported_mv if adj_mv == .
		replace adj_mv = reported_mv if adj_mv <= 0
		drop if adj_mv <= 0

save "$WORK/Factset_ownership_data_sample1", replace


use "$WORK/Factset_ownership_data_sample1", clear

		rename report_date report_date_txt
	
		gen report_date_year_txt = substr(report_date_txt,6,4)
			destring report_date_year_txt, gen(report_date_year)
	
		gen report_date_month_txt = substr(report_date_txt,3,3)
		
		gen report_date_month = 1 if report_date_month_txt == "jan"
			replace report_date_month = 2 if report_date_month_txt == "feb"
			replace report_date_month = 3 if report_date_month_txt == "mar"
			replace report_date_month = 4 if report_date_month_txt == "apr"
			replace report_date_month = 5 if report_date_month_txt == "may"
			replace report_date_month = 6 if report_date_month_txt == "jun"
			replace report_date_month = 7 if report_date_month_txt == "jul"
			replace report_date_month = 8 if report_date_month_txt == "aug"
			replace report_date_month = 9 if report_date_month_txt == "sep"
			replace report_date_month = 10 if report_date_month_txt == "oct"
			replace report_date_month = 11 if report_date_month_txt == "nov"
			replace report_date_month = 12 if report_date_month_txt == "dec"
		
		gen report_date_day_txt = substr(report_date_txt,1,2)
			destring report_date_day_txt, gen(report_date_day)
		
		gen report_date = mdy(report_date_month,report_date_day,report_date_year)	
			format report_date %td
		
	
	gen report_yearqtr = qofd(report_date)
		format report_yearqtr %tq
	
	order fsym_id factset_fund_id report_yearqtr report_date
	
	sort factset_fund_id fsym_id report_yearqtr report_date
		
	egen id = group(fsym_id factset_fund_id report_yearqtr)
	
	gen count = 1
		bys id: egen nobs = sum(count)
		drop count
	
	bys id: egen max_date = max(report_date)
		drop if report_date != max_date & nobs > 1
		drop max_date
	
	drop nobs
	gen count = 1
		bys id: egen nobs = sum(count)
		drop count
		
save "$WORK/Factset_ownership_data_sample2", replace


//Collapse
use "$WORK/Factset_ownership_data_sample2", clear

	generate yearqtr = report_yearqtr
	
	sort fsym_id yearqtr
	
	gen nfunds = 1
 	
	collapse (sum) nfunds adj_holding adj_mv, by(fsym_id yearqtr)
	
	sort fsym_id yearqtr 
	
save "$WORK/Factset_master_file_nofill", replace


//Time series
use "$WORK/Factset_master_file_nofill", clear
	
encode(fsym_id), gen(firm_id)
	
	sort firm_id yearqtr
	
tsset firm_id yearqtr

gen fillin = 0

tsfill

	replace fillin = 1 if fillin == .
	
	sort firm_id yearqtr
	
	foreach var in fsym_id ///
		{
			bysort firm_id: carryforward `var', replace
		}

	
		foreach var in nfunds adj_holding adj_mv ///
		{
			bysort firm_id: carryforward `var', replace
		}
			
save "$WORK/Factset_master_file_fill", replace


//Merge
use "$WORK/Datastream_Factset_merge_ids", clear
	
	sort fsym_id yearqtr
	
	drop country

	merge m:1 fsym_id yearqtr using "$WORK/Factset_master_file_fill"

	drop if _merge == 2
	
	gen fill_ind = 0
		replace fill_ind = 1 if _merge == 3
	
	drop _merge
	
	gen adj_holding_count = nfunds
	
save "$DATA/formerge_ownership", replace
clear all
macro drop _all
set more off

pause off

//File calls
global DATA "insert file path"
global WORK "insert file path"

//Coverage data
use "$DATA/formerge_ravenpack.dta", clear
		
gen year = year(dofq(yearqtr))

sort dscd yearqtr
		
collapse (mean) max_pre_coverage, by(dscd year)
		
sort dscd year
		
save "$WORK/ravenpack_comovement.dta", replace

//Merge
use "$DATA/weekly_returns_processed", clear

merge m:1 dscd year using "$WORK/ravenpack_comovement.dta"
keep if _merge == 3


drop begin_date end_date week year week_nr weekyear

//Sample selection	
drop if country_txt == "United Kingdom" | country_txt == "Luxembourg" | country_txt == "Bulgaria" | country_txt == "Croatia" | country_txt == "Czech Republic" | country_txt == "Estonia" | country_txt == "Hungary" | country_txt == "Malta" | country_txt == "Romania" | country_txt == "Slovak Republic" | country_txt == "Slovenia"
	
format date %td

encode(dscd), gen(firm_id)

duplicates drop firm_id date, force

//Time variables
gen year = year(date)
gen yearqtr = qofd(date)
format yearqtr %tq
gen yearweek = wofd(date)
format yearweek %tw
gen week = week(dofw(yearweek))
	
//Multiple observation drops
egen id = group(firm_id yearweek)
bys id: egen max_date = max(date)
drop if date != max_date
drop id max_date

//Sample selection
drop if year < 2001
drop if year > 2015
	
bys firm_id yearqtr: egen return_sum = sum(abs(ret))
drop if return_sum == 0
		
sort country industry_cam firm_id yearweek
gen obs = 1
bys firm_id year: egen nobs = sum(obs)
drop if nobs < 52
drop obs nobs
	
sort country industry_cam firm_id yearweek
gen obs = 1
bys firm_id yearqtr: egen nobs = sum(obs)
drop if nobs < 10
drop obs nobs

egen id = group(yearqtr country industry_cam)
sort id yearweek firm_id 
egen id_week = group(yearweek country industry_cam)
sort country industry_cam yearweek firm_id 
gen tag = 1
egen nfirms = sum(tag), by(id_week)
drop if nfirms < 4
drop id id_week tag nfirms
	
	
//Portfolio construction		
gen size_ = mv_usd_l1 if week == 1
bys firm_id year: egen size = max(size_)
drop if size == .
drop size_
sort country industry_cam firm_id yearweek
		
egen id_year = group(year country industry_cam)
astile split_size = size, nquantiles(2) qc(firm_id) by(id_year)

gen large_ind = 0
	replace large_ind = 1 if split_size == 2
gen small_ind = 0
	replace small_ind = 1 if split_size == 1

gen coverage_ind = 0
	replace coverage_ind = 1 if max_pre_coverage > 9

gen split101 = split_size	
	replace split101 = 2 if split_size == 1 & max_pre_coverage > 9 & max_pre_coverage != .

gen split_vis = split101

//Portfolio returns
sort country industry_cam yearweek firm_id
by country industry_cam yearweek, sort:  egen total_average_ind_return = mean(ret)
gen numerator = 1
bys country industry_cam yearweek: egen denominator = total(numerator)
gen average_ind_return = total_average_ind_return - ((numerator/denominator)*ret)
drop numerator denominator

sort country industry_cam yearweek split_vis firm_id

gen lowvis_return = ret if split_vis == 1
gen highvis_return = ret if split_vis == 2

by country industry_cam yearweek, sort:  egen total_average_lowvis_return = mean(lowvis_return)
by country industry_cam yearweek, sort:  egen total_average_highvis_return = mean(highvis_return)

gen is_lowvis = 0
replace is_lowvis = 1 if split_vis == 1
gen is_highvis = 0
replace is_highvis = 1 if split_vis == 2

by country industry_cam yearweek, sort:  egen denominator_lowvis = sum(is_lowvis)
by country industry_cam yearweek, sort:  egen denominator_highvis = sum(is_highvis)
		
gen average_lowvis_return = total_average_lowvis_return - ((is_lowvis/denominator_lowvis)*ret) 
gen average_highvis_return = total_average_highvis_return - ((is_highvis/denominator_highvis)*ret)

drop if ret == . | average_ind_return == . | average_lowvis_return == . | average_highvis_return == .

preserve
sort firm_id yearqtr
gen nobs_com = 1
gen zero_returns_com = 0
replace zero_returns_com = 1 if ret == 0
collapse (sum) zero_returns_com nobs_com, by(firm_id yearqtr)
save "$WORK/zero_returns", replace
restore

//Identifiers
merge m:1 dscd yearqtr using "$DATA/analysis_sample_identifiers.dta", gen(_merge2)
keep if _merge2 == 3

//Weekly returns
local countries `""Austria" "Belgium" "Cyprus" "Denmark" "Finland" "France" "Germany" "Greece" "Iceland" "Iceland" "Ireland" "Italy" "Latvia" "Lithuania" "Netherlands" "Norway" "Poland" "Portugal" "Spain" "Sweden""'

foreach m of local countries {

preserve 

keep if country_txt == "`m'"
	
sort country industry_cam firm_id yearweek
egen id = group(yearqtr firm_id)
gen country_id = country
gen industry_id = industry_cam
gen weekly_return = ret
egen ind_id = group(industry_id)
	
xtset firm_id yearweek
sort country industry_cam firm_id yearqtr yearweek
	
save "$WORK/weekly_returns_`m'", replace

restore

}


//Synchronicity measurement
local countries `""Austria" "Belgium" "Cyprus" "Denmark" "Finland" "France" "Germany" "Greece" "Iceland" "Ireland" "Italy" "Latvia" "Lithuania" "Netherlands" "Norway" "Poland" "Portugal" "Spain" "Sweden""'

foreach m of local countries {
use "$WORK/weekly_returns_`m'", clear
qui: sum id, meanonly
local target = r(max)
matrix com = J(`target',4,.)
forvalues i = 1/`target'{
preserve
qui: keep if id == `i'
qui: regress weekly_return average_ind_return
local synch1 = log(e(r2)/(1-e(r2)))
mat com[`i',1] = `i'
mat com[`i',2] = `synch1'
qui: regress weekly_return average_lowvis_return
local synch2 = log(e(r2)/(1-e(r2)))
mat com[`i',3] = `synch2'
qui: regress weekly_return average_highvis_return
local synch3 = log(e(r2)/(1-e(r2)))
mat com[`i',4] = `synch3'
restore
}

putexcel set "$WORK/comovement_measure_`m'.xlsx", sheet("A") replace
putexcel A1=matrix(com)

use "$WORK/weekly_returns_`m'", clear

collapse (firstnm) dscd firm_id country country_txt yearqtr industry_cam (mean) is_highvis is_lowvis, by(id)

save "$WORK/id_`m'_yearqtr_industry", replace

import excel using "$WORK/comovement_measure_`m'.xlsx", sheet("A") clear 
rename A id
rename B comovement_industry_reg
rename C comovement_lowvis_reg
rename D comovement_highvis_reg
sort id

merge m:1 id using "$WORK/id_`m'_yearqtr_industry"
drop if _merge == 2
drop _merge
drop id
sort firm_id yearqtr
save "$WORK/comovement_measure_`m'", replace

}


//Append
use "$WORK/comovement_measure_Austria", clear
local countries `""Belgium" "Cyprus" "Denmark" "Finland" "France" "Germany" "Greece" "Iceland" "Latvia" "Ireland" "Italy" "Lithuania" "Netherlands" "Norway" "Poland" "Portugal" "Spain" "Sweden""'
foreach m of local countries {
	append using "$WORK/comovement_measure_`m'"
}
merge m:1 firm_id yearqtr using "$WORK/zero_returns", gen(_merge)
keep if _merge == 3
drop _merge	
save "$DATA/formerge_synchronicity", replace

	
clear all
macro drop _all
set more off

pause off

//File calls
global MAIN "Insert file path"
global DATA "Insert file path"
global OUTPUT "Insert file path"
global MAINDO "Insert file path"


//Load
use "$DATA/analysis_sample.dta", clear


//Merge 
merge 1:1 dscd yearqtr using  "$DATA/formerge_ownership.dta" 
drop if _merge == 2
drop _merge

merge 1:1 dscd yearqtr using "$DATA/formerge_ravenpack.dta" 
drop if _merge == 2
drop _merge

preserve
	use "$DATA/formerge_synchronicity.dta", clear
	
	drop country country_txt industry_cam
	
	rename comovement_industry_reg comovement_industry_reg_vis
	rename zero_returns_com zero_returns_com_vis
	rename nobs_com nobs_com_vis
	
	replace comovement_industry_reg_vis = . if comovement_highvis_reg == .
	replace comovement_lowvis_reg = . if comovement_highvis_reg == .
	
	saveold "$DATA/formerge_synchronicity_processed.dta", replace

restore

merge 1:1 dscd yearqtr using "$DATA/formerge_synchronicity_processed.dta"
drop if _merge == 2
drop _merge


//Create
foreach var in coverage ln_coverage ///
{
	bys country: egen double p1_`var' = pctile(`var'), p(1)
	bys country: egen double p9_`var' = pctile(`var'), p(99)
	gen double `var'_initial = `var'
	replace `var' = p9_`var' if `var'>p9_`var' & `var'!=.
	replace `var' = p1_`var' if `var'<p1_`var' & `var'!=.
	drop p1_`var' p9_`var'
}	

foreach var in comovement_industry_reg_vis comovement_lowvis_reg comovement_highvis_reg ///
{
	bys country: egen double p1_`var' = pctile(`var'), p(1)
	bys country: egen double p9_`var' = pctile(`var'), p(99)
	gen double `var'_in = `var'
	replace `var' = p9_`var' if `var'>p9_`var' & `var'!=.
	replace `var' = p1_`var' if `var'<p1_`var' & `var'!=.
	drop p1_`var' p9_`var'
}

//Visibility and ownership
gen double frac_MF = adj_holding/numshrs
gen double frac_adj_mv = adj_mv/mv_usd

foreach var in frac_MF frac_adj_mv adj_holding_count ///
		{
			bys firm_id: egen max_`var' = max(`var')
			replace `var' = 0 if max_`var' == .
			drop max_`var'
		}
	
replace frac_MF = . if frac_MF > 1
replace frac_adj_mv = . if frac_adj_mv > 1

gen double frac_retail = 1 - frac_MF
gen double frac_retail2 = 1 - frac_adj_mv
	
byso firm_id: egen min_year = min(year)

egen firmertagger = tag(firm_id)
egen firmeryearertagger = tag(firm_id year)
egen firmerpretagger = tag(firm_id oam_ind)


local fff = 1
foreach var in mv_usd frac_MF frac_adj_mv ///
{
	
	byso firm_id year: egen double mean`var'byyear = mean(`var')
		
	astile tempsplit`fff' = mean`var'byyear, nquantiles(2) qc(firm_id) by(country year)
		by firm_id year: egen split`fff' = max(tempsplit`fff')
	local fff = `fff' + 1
	
	gen double `var'_pre = `var' if oam_ind == 0
	by firm_id: egen double mean`var'_pre = mean(`var'_pre)

	astile tempsplit`fff' = mean`var'_pre, nquantiles(2) qc(firm_id) by(country)
			by firm_id: egen split`fff' = max(tempsplit`fff')
	local fff = `fff' + 1
}


gen split101 = split1
	replace split101 = 2 if split1 == 1 & max_pre_coverage > 9 & max_pre_coverage != .
	
gen split102 = split2
	replace split102 = 2 if split2 == 1 & max_pre_coverage > 9 & max_pre_coverage != .
	

local fff = 103
foreach var in coverage ///
{

	gen double `var'_pre = `var' if oam_ind == 0
	by firm_id: egen double mean`var'_pre = mean(`var'_pre)

	astile tempsplit`fff' = mean`var'_pre, nquantiles(2) qc(firm_id) by(country)
			by firm_id: egen split`fff' = max(tempsplit`fff')
	local fff = `fff' + 1
}
	
egen split_sample_ind = rownonmiss(split3 split5)
replace split3 = . if split_sample_ind != 2 
replace split5 = . if split_sample_ind != 2 


//Partition
forvalues ttt=1/6 ///
	{
		foreach var in tpd_ind oam_ind bundled_ind ///
			{
				forvalues qqq=1/2 ///
				{
					gen `var'_split`ttt'_`qqq' = `var' if split`ttt' != . 
					replace `var'_split`ttt'_`qqq' = 0 if split`ttt' != `qqq' & split`ttt' != .
				}	
			}
	}
	
forvalues ttt=101/103 ///
	{
		foreach var in tpd_ind oam_ind bundled_ind ///
			{
				forvalues qqq=1/2 ///
				{
					gen `var'_split`ttt'_`qqq' = `var' if split`ttt' != . 
					replace `var'_split`ttt'_`qqq' = 0 if split`ttt' != `qqq' & split`ttt' != .
				}	
			}
	}

foreach ttt in coverage ///
{
foreach var in tpd_ind oam_ind bundled_ind ///
				{
					forvalues qqq=0/1 ///
					{
						gen `var'_split`ttt'_`qqq' = `var' if `ttt'_starts_after != . 
						replace `var'_split`ttt'_`qqq' = 0 if `ttt'_starts_after != `qqq' & `ttt'_starts_after != .
					}	
				}

}


//Share of same-OAM low visibility peers
gen small_firm = split101 == 1
	replace small_firm = . if split101 == .

byso country industry_cam year: gen num_firms = _N
byso country industry_cam year: egen num_smallfirms = total(small_firm)

byso firm_id year: egen num_smallobs = total(small_firm)
byso firm_id year: gen num_firmobs = _N

byso country industry_cam year: gen ratio_smallfirms_firms = num_smallfirms/num_firms
	replace ratio_smallfirms_firms = 0 if num_firmobs == num_firms & ratio_smallfirms_firms != . 
	

egen ciy_tagger = tag(country industry_cam year)
replace ratio_smallfirms_firms = . if ciy_tagger != 1
astile is_smallshare_rolling_temp = ratio_smallfirms_firms, nquantiles(2) by(country year)
byso country industry_cam year: egen is_smallshare_rolling = max(is_smallshare_rolling_temp)	

foreach var in tpd_ind oam_ind bundled_ind ///
{
		
		gen `var'_SSroll_spill = `var' == 1 & is_smallshare_rolling == 2
				replace `var'_SSroll_spill = . if is_smallshare_rolling == .
				
		gen `var'_SSroll_nospill = `var' == 1 & is_smallshare_rolling == 1
				replace `var'_SSroll_nospill = . if is_smallshare_rolling == .
}		
	
	
	rename is_smallshare_rolling is_SSroll

//Share of same-OAM peers
byso industry_cam year: egen mv_industry = total(mv_usd)
byso industry_cam year: gen firm_count_industry = _N 
byso country industry_cam year: gen firm_count_country_industry = _N
byso firm_id year: gen firm_counter = _N
gen perc_firm_cindustry_over_c = firm_count_country_industry/firm_count_industry
		replace perc_firm_cindustry_over_c = 0 if firm_count_country_industry == firm_counter  & perc_firm_cindustry_over_c != . 
egen split_tagger2 = tag(country industry_cam year)
replace perc_firm_cindustry_over_c = . if split_tagger2 != 1

astile is_manypeers_temp = perc_firm_cindustry_over_c, nquantiles(2) by(industry_cam year)

	byso country industry_cam year: egen is_manypeers = max(is_manypeers_temp)
	
	foreach var in tpd_ind oam_ind bundled_ind ///
	{
			
			gen `var'_DSirol_spill = `var' == 1 & is_manypeers == 2
				replace `var'_DSirol_spill = . if is_manypeers  == .
				
		gen `var'_DSirol_nospill = `var' == 1 &  is_manypeers  == 1
				replace `var'_DSirol_nospill = . if  is_manypeers  == .
	}
	
	rename is_manypeers is_DSirol

//OAM features
gen criteria_ind = 0
        replace criteria_ind = 1 if exchctrycode == "DK" | exchctrycode == "DE" | exchctrycode == "AT" | exchctrycode == "LT" | exchctrycode == "IS" | exchctrycode == "FI" | exchctrycode == "SE" | exchctrycode == "LV" | exchctrycode == "IT" | exchctrycode == "FR"  | exchctrycode == "CY"  | exchctrycode == "BE"

gen oam_ind_highcriteria = criteria_ind*oam_ind
gen oam_ind_lowcriteria = criteria_ind == 0 & oam_ind == 1
        replace oam_ind_lowcriteria  = . if oam_ind == .

gen cosearch_ind = 0
        replace cosearch_ind = 1 if exchctrycode == "FI" | exchctrycode == "IS" | exchctrycode == "LT" | exchctrycode == "SE"

gen oam_ind_cosearch = cosearch_ind*oam_ind
gen oam_ind_notcosearch = cosearch_ind == 0 & oam_ind == 1
        replace oam_ind_notcosearch = . if oam_ind == .


gen tier_ind = 2
        replace tier_ind = 1 if exchctrycode == "SE" | exchctrycode == "FI" | exchctrycode == "IS" | exchctrycode == "LT"
        replace tier_ind = 3 if exchctrycode == "GR" | exchctrycode == "NL" | exchctrycode == "PL" | exchctrycode == "PT" | exchctrycode == "IE" | exchctrycode == "ES" | exchctrycode == "NO"
		

gen oam_ind_tier1 = 0
        replace oam_ind_tier1 = oam_ind if tier_ind == 1 & oam_ind != .
gen oam_ind_tier2 = 0
        replace oam_ind_tier2 = oam_ind if tier_ind == 2 & oam_ind != .
gen oam_ind_tier3 = 0
        replace oam_ind_tier3 = oam_ind if tier_ind == 3 & oam_ind != .
		

//Save
saveold "$DATA/final_sample.dta", replace


//Events
use "$DATA/final_sample.dta", clear

preserve
	keep if focal_event_date != .
	keep dscd yearqtr firm_id split* focal_event_date country_txt country industry_cam oam_ind tpd_ind bundled_ind ln_mv_usd_l4 ln_turnover_l4 ln_sd_ret_l4 ln_gdpc_l4 ln_liq_fac zero OAMDATE_q
	
	saveold "$DATA/forreg_analysissample_annualevents.dta", replace
restore

preserve
	keep dscd yearqtr firm_id split* focal_event_date country_txt country industry_cam oam_ind tpd_ind bundled_ind ln_mv_usd_l4 ln_turnover_l4 ln_sd_ret_l4 ln_gdpc_l4 ln_liq_fac zero
	
	foreach var in dscd yearqtr firm_id split* focal_event_date country_txt country industry_cam oam_ind tpd_ind bundled_ind ln_mv_usd_l4 ln_turnover_l4 ln_sd_ret_l4 ln_gdpc_l4 ln_liq_fac zero ///
	{
		rename `var' peer_`var'
	}
	
	saveold "$DATA/analysissample_peercharacteristics.dta", replace
restore



//Calculate synchronicity
use "$DATA/annual_events_1.dta", clear

keep dscd yearqtr industry_cam country focal_event_date peer_dscd peer_event_date mdate peer_ret peer_exchintcode focal_ret exchintcode
rename yearqtr yearqtr_td
gen yearqtr = qofd(yearqtr_td)
format yearqtr %tq
egen id = group(dscd focal_event_date yearqtr peer_dscd peer_event_date)
gen R2 = .	

parallel setclusters 8

parallel do $MAINDO/7_syncher.do

parallel clean

saveold "$DATA/synchronicity_events.dta", replace




use "$DATA/synchronicity_events.dta", clear

drop if id == .

gen zero_ret = 1 if focal_ret == 0
byso id: egen count_zero_ret = total(zero_ret)
gen peer_zero_ret = 1 if peer_ret == 0
byso id: egen count_peer_zero_ret = total(peer_zero_ret)
egen tagger = tag(id)

keep if tagger == 1

gen double spsync = ln(R2) - ln(1-R2)

preserve
	use "$DATA/annual_events_2.dta", clear
	
	drop if peer_dscd == ""
	
	drop if exchintcode == .
	
	saveold "$DATA/formerge_annual_events_2.dta", replace
restore

merge m:1 dscd focal_event_date peer_dscd using"$DATA/formerge_annual_events_2.dta", gen(_merge_peerstuff)


merge m:1 dscd yearqtr using  "$DATA/forreg_analysissample_annualevents.dta", gen(_merge_regressors)
	drop if _merge_regressors == 2
	
gen peer_yearqtr = yearqtr
	format peer_yearqtr %tq
	
merge m:1 peer_dscd peer_yearqtr using  "$DATA/analysissample_peercharacteristics.dta", gen(_merge_peerchar)
	drop if _merge_peerchar == 2
	
egen peer_dscd_id = group(peer_dscd)


foreach var in spsync ///
{
	bys country: egen double p1_`var' = pctile(`var'), p(1)
	bys country: egen double p9_`var' = pctile(`var'), p(99)
	gen double `var'_in = `var'
	replace `var' = p9_`var' if `var'>p9_`var' & `var'!=.
	replace `var' = p1_`var' if `var'<p1_`var' & `var'!=.
	drop p1_`var' p9_`var'
}

gen year = year(focal_event_date)

byso firm_id yearqtr: egen max_count_zero_ret = max(count_zero_ret)
byso firm_id yearqtr: egen max_trading_days_ar10_focal = max(trading_days_ar10_focal)
gen perc_zero = max_count_zero_ret/max_trading_days_ar10_focal 
	replace perc_zero = max_count_zero_ret/12 if perc_zero == .

gen peer_perc_zero = count_peer_zero_ret/trading_days_ar10_peer
	replace peer_perc_zero = count_peer_zero_ret/12 if peer_perc_zero == .


byso firm_id yearqtr: egen min_perc_zero = min(perc_zero)
byso firm_id yearqtr: egen max_perc_zero = max(perc_zero)

gen liquiditycontrol = max_count_zero_ret
gen peerliquiditycontrol = count_peer_zero_ret		

capture drop sampler
reghdfe spsync oam_ind tpd_ind bundled_ind, nocons absorb(firm_id#peer_dscd_id liquiditycontrol#yearqtr peerliquiditycontrol#yearqtr split102#peer_split102#industry_cam#yearqtr) cluster(country#industry_cam yearqtr)
gen sampler = e(sample)

byso firm_id yearqtr: egen max_sampler = max(sampler) 

keep if max_sampler == 1

egen tagger_focal = tag(firm_id yearqtr)

saveold "$DATA/event_study_sample.dta", replace
egen max_id = max(id)
local maxxx = max_id[1]
display `maxxx'

egen min_id = min(id)
local minnn = min_id[1]
display `minnn'


forvalues l=`minnn'/`maxxx' ///
{
	capture reg peer_ret focal_ret if id == `l'
	replace R2 = e(r2) if id == `l'	
}