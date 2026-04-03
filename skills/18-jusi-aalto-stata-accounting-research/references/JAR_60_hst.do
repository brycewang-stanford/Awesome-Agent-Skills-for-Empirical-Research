

* The two lines of code below set the directory so that all future file references are relative *
global home_directory "/Users/nicholashallman/Documents/Academic/Research Projects/Published Projects/Audit Reporting Model - Materiality/Programs/Stata/Nick/FOR JAR/"
cd "$home_directory"

*-----------------------------------*
*-----------------------------------*
*---------- Prepare Data -----------*
*-----------------------------------*
* The data below begins with raw	*
* data and prepares that data for 	*
* merging. Then variables are 		*
* created in the merged dataset 	*
* to arrive at the final dataset 	*
* used to perform our analysis. 	*
*-----------------------------------*
{
*---------------------------------------------------------------------------*
* Create Stata dataset with IDs of client-firms in hand collected sample 	*
*---------------------------------------------------------------------------*
* This allows me to keep only the needed observations for larger handled 	*
* in the code sections below. 												*
*---------------------------------------------------------------------------*
{
import excel "DATA/RAW DATA/HAND_COLLECTED_DATA.xlsx", first clear

keep gvkey isin regno sedol2
sort gvkey
by gvkey: keep if _n == 1 

save "DATA/PROC DATA/FIRM_ID.dta", replace
}
*-------------------------------------------*
* 1.2.K Import Currency Conversion Rates	*
*-------------------------------------------*
* This dataset contains the daily currency	* 
* exchange rates as reported to the 		*
* International Monetary Fund by the 		*
* issuing central bank. Included are 51 	*
* currencies over the period from 			*
* 01-01-1995 to 11-04-2018. Downloaded in	*
* March if 2020. 							*
*-------------------------------------------*
{
clear
import delim "DATA/RAW DATA/currency_exchange_rates_1-1-1995_-_11-4-2018 2.csv", varnames(1)


keep euro ukpoundsterling australiandollar russianruble indianrupee malaysianringgit date

rename euro EUR_USD_Convert
rename ukpoundsterling GBP_USD_Convert
rename australiandollar AUD_USD_Convert
rename russianruble RUB_USD_Convert
rename indianrupee INR_USD_Convert
rename malaysianringgit MYR_USD_Convert

gen Date = date(date, "YMD")
format Date %td
drop if year(Date) < 2012

tset Date
tsfill

/* Fill in missing days with adjsent day's conversion rate */
foreach i in EUR_USD_Convert GBP_USD_Convert AUD_USD_Convert RUB_USD_Convert INR_USD_Convert MYR_USD_Convert {
	replace `i' = l1.`i' if `i' == .
}

keep Date EUR_USD_Convert GBP_USD_Convert AUD_USD_Convert RUB_USD_Convert INR_USD_Convert MYR_USD_Convert

/* Manually add coversion rates for GEL missing from file */
gen GEL_USD_Convert = .
replace GEL_USD_Convert = 1/1.7348 if Date == date("12/31/2013", "MDY")
replace GEL_USD_Convert = 1/1.8828 if Date == date("12/31/2014", "MDY")

rename Date curr_date

save "DATA/PROC DATA/1.2.K.dta", replace

}
*-----------------------------------------------*
* 1.2.A Prepare Compustat Global data for merge *
*-----------------------------------------------*
* This section of code begins with a full		*
* download of the Compustat Global FundA file	*
* from WRDS. The file was downloaded on June 7	*
* 2021. 										*
*-----------------------------------------------*
{
clear
gzuse if year(datadate) > 2007 using "DATA/RAW DATA/g_funda_20210607.dta.gz"

/* Keep only needed variables */
keep /* currency based */ pi oancf am at lt nicon revt spi ibc ppent sppch sppiv dispoch epsincon teq aqc do sstk act lct re ceq oiadp rect ap cogs ppegt/* non-currency based */ sich gvkey sedol datadate curcd cshpria fyear au cshoi auop conm compst

/* Destring variables */
destring gvkey au, replace

/* Keep needed firm's */
merge m:1 gvkey using "DATA/PROC DATA/FIRM_ID.dta"
drop if _merge != 3
drop _merge

/* Drop non-comparable fiscal year-end changes */
sort gvkey fyear
by gvkey fyear: drop if _N > 1 & compst == "DB"

/* Set as panel */
xtset gvkey fyear

/* Covert to base currency units instead of millions (all currency based excpet for per-share varaibles) plus shares outstanding (cshpria) */
foreach i in pi oancf am at lt nicon revt spi ibc ppent sppch sppiv dispoch teq aqc do sstk act lct re ceq oiadp rect ap cogs ppegt cshpria {
	replace `i' = `i' * 1000000
}

/* Merge in Exchange Rates and Convert to Dollars */
gen curr_date = datadate

nearmrg using "DATA/PROC DATA/1.2.K.dta", nearvar(curr_date) genmatch(exchange_rate_date) limit(30)
drop _merge

foreach var in pi oancf am at lt nicon revt spi ibc ppent sppch sppiv dispoch epsincon teq aqc do sstk act lct re ceq oiadp rect ap cogs ppegt {
	foreach cur in AUD EUR INR MYR RUB GBP GEL {
		replace `var' = `var' * `cur'_USD_Convert if curcd == "`cur'"
	}
}

drop *_Convert curr_date

/* Create leads/lags */
sort gvkey fyear
foreach var in at revt oancf pi nicon spi ibc ppent sppiv teq epsincon rect ap am au {
	forval i = 1/4 {
		gen `var'_lag`i' = l`i'.`var'
		gen `var'_lead`i' = f`i'.`var'
	}
	
}

/* Save */
save "DATA/PROC DATA/1.2.A.dta", replace

}
*-----------------------------------*
* 1.2.F Prepare FAME data for merge *
*-----------------------------------*
* This section starts with data		* 
* from the FAME obtained in August	*
* 2016. 							*
*-----------------------------------*
{
clear
use "DATA/RAW DATA/lst2_fornick.dta"

/* Rename varaibles */
rename registered_number regno
rename firmtenure aud_firm_tenure
rename non_audit_fee nas_fee

/* Keep needed firm's */
merge m:1 regno using "DATA/PROC DATA/FIRM_ID.dta"
drop if _merge != 3
drop _merge

/* Create fyear */
gen fyear = .
replace fyear = year(date(accounts_date,"DMY")) if month(date(accounts_date,"DMY")) >=6 & date(accounts_date,"DMY") != .
replace fyear = year(date(accounts_date,"DMY"))-1 if month(date(accounts_date,"DMY")) < 6 & date(accounts_date,"DMY") != .

/* Unscale variables expressed in 1000's */
foreach var in nas_fee audit_fee {
	replace `var' = `var' * 1000	
}

/* Drop observations missing identifer or fiscal year info */
dropmiss regno fyear, any obs force

/* Set as panel and keep lead/lags */
egen group = group(regno)
xtset group fyear
sort group fyear

/* Merge in Exchange Rates and Convert to Dollars */
gen Currency = "GBP"
gen curr_date = date(accounts_date,"DMY")

nearmrg using "DATA/PROC DATA/1.2.K.dta", nearvar(curr_date) genmatch(exchange_rate_date) limit(30)
drop _merge

foreach var in audit_fee nas_fee {
	foreach cur in AUD EUR INR MYR RUB GBP GEL {
		replace `var' = `var' * `cur'_USD_Convert if Currency == "`cur'"
	}
}

keep regno fyear aud_firm_tenure audit_fee nas_fee ticker_symbol

save "DATA/PROC DATA/1.2.F.dta", replace
}
*---------------------------*
* 1.2.J Prepare IBES Data	* 
*---------------------------*
* This section starts with	*
* a full download of the 	*
* IBES eps international 	*
* file from WRDS. The file	*
* was downloaded on Sept. 	*
* 30, 2017. 				*
*---------------------------*
{
clear
gzuse "DATA/RAW DATA/statsum_epsint_20170930"

/* Rename variables */
rename *, lower
rename actual value
rename fiscalp pdicity
rename fpedats pends
rename cname ibes_co_name

/* Keep only current year EPS forecasts */
keep if fpi == "1"
drop if pdicity != "ANN"
drop if measure != "EPS"

/* Drop observations with missing values of required variables */
drop if value == .
drop if cusip == ""

/* Create sedol variable for merging */
gen sedol2 = substr(cusip,3,8)

/* Keep needed firm's */
merge m:1 sedol2 using "DATA/PROC DATA/FIRM_ID.dta"
drop if _merge != 3
drop _merge

/* Create fyear */
gen fyear = .
replace fyear = year(pends) if month(pends) >=6 & pends != .
replace fyear = year(pends)-1 if month(pends) < 6 & pends != .
keep if fyear > 2012 & fyear < 2017

/* Drop older estimate dates for each firm-year, prioritizing those denominated in dollars */
gen curr_priority = (curr_act == "USD")
gsort cusip fyear statpers curr_priority
by cusip fyear: keep if _n == _N

/* Merge in Exchange Rates and Convert to Dollars */
gen curr_date = pends

replace curcode = "GBP" if curcode == "BPN"
replace curr_act = "GBP" if curr_act == "BPN"

nearmrg using "DATA/PROC DATA/1.2.K.dta", nearvar(curr_date) genmatch(exchange_rate_date) limit(30)
drop _merge

foreach var in medest meanest highest lowest {
	foreach cur in AUD EUR INR MYR RUB GBP GEL {
		replace `var' = `var'/100 if `cur' == GBP & curcode == "GBP"
		replace `var' = `var' * `cur'_USD_Convert if curcode == "`cur'"
		
	}
}

foreach cur in AUD EUR INR MYR RUB GBP GEL {
	replace value = value/100 if `cur' == GBP & curr_act == "GBP"
	replace value = value * `cur'_USD_Convert if curr_act == "`cur'"
}

/* Keep only needed varaibles */
keep cusip value pends numest meanest stdev medest ibes_co_name fyear sedol2

save "DATA/PROC DATA/1.2.J.dta", replace
}
*---------------------------------------------------------------*
* 1.2.T Create dataset containing fee data from audit analytics	*
*---------------------------------------------------------------*
* This section starts with a full download of the audit 		*
* analytics audit fee file from AuditAnalytics.com. The data	*
* was downloaded on Oct. 30, 2019. 								*
*---------------------------------------------------------------*
{
clear
import delimited using "DATA/RAW DATA/europe-audit-fees-1572455007.csv", bindquote(strict) clear

/* Create fyear */
gen fyear = .
replace fyear = year(date(auditfeefiscalyearend,"YMD")) if month(date(auditfeefiscalyearend,"YMD")) >=6 & date(auditfeefiscalyearend,"YMD") != .
replace fyear = year(date(auditfeefiscalyearend,"YMD"))-1 if month(date(auditfeefiscalyearend,"YMD")) < 6 & date(auditfeefiscalyearend,"YMD") != .

/* Keep only needed firms */
merge m:1 isin using "DATA/PROC DATA/FIRM_ID.dta"
drop if _merge != 3
drop _merge

/* Format fee variables */
replace auditfeesusd = subinstr(auditfeesusd, ",", "",.)
replace totalnonauditfeesusd = subinstr(totalnonauditfeesusd, ",", "",.)
destring auditfeesusd totalnonauditfeesusd, replace

/* Rename varaibles */
rename auditfeesusd audit_fee
rename totalnonauditfeesusd nas_fee

/* Replace missing values of NAS with 0 (the zero values were coded as missing) */
replace nas_fee = 0 if nas_fee == .

/* Standardize audit firm names */
gen audit_firm_aa = ""
replace audit_firm_aa = "DT" if (strpos(lower(auditorname),"deloitte") != 0)
replace audit_firm_aa = "PWC" if (strpos(lower(auditorname),"waterhouse") != 0)
replace audit_firm_aa = "EY" if  (strpos(lower(auditorname),"ernst") != 0)
replace audit_firm_aa = "KPMG" if (strpos(lower(auditorname),"kpmg") != 0)
replace audit_firm_aa = "BDO" if (strpos(lower(auditorname),"bdo") != 0)
replace audit_firm_aa = "GT" if  (strpos(lower(auditorname),"thornton") != 0)
replace audit_firm_aa = "Other" if audit_firm_aa == ""

/* Drop observations missing required data */
dropmiss isin fyear audit_fee, any obs force

/* Drop years outside relevant range */
keep if fyear > 2011 & fyear < 2017

/* Create audit_firm variable for merging */
gen audit_firm_hand = audit_firm_aa
compress audit_firm_hand

/* Limit to one obserbation per firm-year, prioritizing higher paid auditors when two are paid by same client */
sort isin fyear audit_firm_hand audit_fee, stable
by isin fyear audit_firm_hand: keep if _n == _N

/* Keep only needed variables */
keep isin fyear auditorname audit_fee nas_fee audit_firm_aa audit_firm_hand

save "DATA/PROC DATA/1.2.T.dta", replace
}
*-------------------*
*    2.1 Merge 		*
*-------------------*
* This section 		*
* merges together	*
* the datasets 		*
* created above		*
*-------------------*
{
/* Start with hand collected data */
import excel "DATA/RAW DATA/HAND_COLLECTED_DATA.xlsx", first clear

/* Merge in Compustat */
merge 1:1 gvkey fyear using "DATA/PROC DATA/1.2.A.dta"
drop if _merge == 2
drop _merge

/* Merge in Audit Analytics data */
merge 1:1 isin fyear audit_firm_hand using "DATA/PROC DATA/1.2.T.dta"
drop if _merge == 2
drop _merge

/* Merge in FAME data */
merge 1:1 regno fyear using "DATA/PROC DATA/1.2.F.dta", update 
drop if _merge == 2
drop _merge

/* Merge in IBES data */
merge 1:1 sedol2 fyear using "DATA/PROC DATA/1.2.J.dta" 
drop if _merge == 2
drop _merge

save "DATA/PROC DATA/2.1.dta", replace

}
*----------------------------------------*
* 2.2 Calculate Variables in Merged Data *
*----------------------------------------*
{
clear
use "DATA/PROC DATA/2.1.dta"	

/* Set data as panel */
xtset gvkey fyear

/* Expand audit firm tenure to second year (only have from FAME for first year) */
replace aud_firm_tenure = l1.aud_firm_tenure + 1 if audit_firm_id == l1.audit_firm_id & year == 2
replace aud_firm_tenure = 1 if audit_firm_id != l1.audit_firm_id & audit_firm_id != . & l1.audit_firm_id != . & year == 2
gen ln_aud_firm_tenure = ln(aud_firm_tenure)

/* Create simple variables */ 
gen ln_at = log(at)
gen ln_pi = log(abs(pi))
gen loss = (pi<0)
gen ln_aud_rmms = log(aud_rmms)
gen roa = pi/at_lag1
gen roa_lag1 = pi_lag1/at_lag2
gen leverage = lt/at
gen sich1 = int(sich/1000)
gen revenue_growth = (revt - revt_lag1)/revt_lag1
gen restructure = (do != 0 & do != .)
gen aquisition = (aqc > 0 & aqc != .)
gen bv_ps = teq/cshpria
gen rec_turn = revt/((rect+rect_lag1)/2)
gen pay_turn = cogs/((ap+ap_lag1)/2)
gen abs_ta_s_at = abs((ibc - oancf)/at_lag1)
gen opinmod = (auop != "1" & auop != "")
gen breakeven = (abs(pi)/at < .02)
gen am_s_pi = am/abs(pi)
gen am_s_pi_lag1 = am_lag1/abs(pi_lag1)
gen cashflow_s_at = oancf/at_lag1
gen ln_sharesout = log(cshpria)
gen ppe_s_at = ppegt/at_lag1
gen big4 = (audit_firm_id == 4 | audit_firm_id == 5 | audit_firm_id == 6 | audit_firm_id == 7)
gen fee_ratio = nas_fee/audit_fee

/* Create materiality varaibles */
gen mgmt_adj_amt_s_pi = mgmt_adj_amt/abs(pi)
gen aud_adj_amt_s_pi = aud_adj_amt/abs(pi)
gen perc_calculated = materiality_amt/(abs(pi))
gen mgmt_adj_pi = pi + mgmt_adj_amt
gen aud_adj_pi = pi + aud_adj_amt
gen disagreement = mgmt_adj_amt_s_pi - aud_adj_amt_s_pi
gen revt_mat_perc = materiality_amt/revt
gen revt_mat_perc_no_adj = (abs(pi)*perc)/revt

/* Create volatility measures */
egen earnings_vol = rowsd(pi pi_lag1 pi_lag2 pi_lag3)
replace earnings_vol = ln(earnings_vol)

egen cash_vol = rowsd(oancf oancf_lag1 oancf_lag2 oancf_lag3)
replace cash_vol = ln(cash_vol)

/* Create contextual factor score variable */
gen large_earnings_decrease = (pi < .25 * ((pi_lag1 + pi_lag2 + pi_lag3)/3) & pi != . & pi_lag1 != . & pi_lag2 != . & pi_lag3 != .) 
gen near_change_eps = (abs(epsincon-epsincon_lag1) <= .02 & epsincon != . & epsincon_lag1 != .)
gen small_profit = (roa > 0 & roa < .01 & roa != .)
gen small_loss = (roa < 0 & roa > -.01 & roa != .)
gen small_pos_streak = (  (pi - pi_lag1)/pi_lag1 > 0 & (pi - pi_lag1)/pi_lag1 < .03     &    (pi_lag1 - pi_lag2)/pi_lag2 > 0 & (pi_lag1 - pi_lag2)/pi_lag2 < .03     &    (pi_lag2 - pi_lag3)/pi_lag3 > 0 & (pi_lag2 - pi_lag3)/pi_lag3 < .03 ) 
gen capital_raising = (sstk > (.2*at_lag1) & sstk != . & at_lag1 != . )
gen contextual_factor_score = large_earnings_decrease + near_change_eps + small_profit + small_loss + small_pos_streak + capital_raising
	
/* Create analyst variables */
replace numest = 0 if numest == . 
replace stdev = 0 if numest == 1 
gen forecast_error = (value - meanest)
gen meet_or_beat_1cent = (forecast_error <= .01 & forecast_error >= 0)

gen analyst_adj_amt = ((value * cshpria) - nicon) - (pi - nicon)
gen analyst_adj_amt_s_pi = analyst_adj_amt/abs(pi)

gen aud_excess_adj = aud_adj_amt - analyst_adj_amt 
gen aud_excess_adj_s_pi = aud_excess_adj/abs(pi)

gen mgmt_excess_adj = mgmt_adj_amt - analyst_adj_amt
gen mgmt_excess_adj_s_pi = mgmt_excess_adj/abs(pi)

/* Create asset-scaled variables for persistence tests */
gen mgmt_exclude_s_at = mgmt_adj_amt/at_lag1
gen aud_exclude_s_at = aud_adj_amt/at_lag1
gen pi_lead1_s_at = pi_lead1/at
gen mgmt_adj_pi_s_at = mgmt_adj_pi/at_lag1
gen aud_adj_pi_s_at = aud_adj_pi/at_lag1

/* Create benchmark category variable for mlogit test */
gen benchmark_cat = 1 if pbt_benchmark == 1 & aud_adj_dummy == 0
replace benchmark_cat = 2 if pbt_benchmark == 1 & aud_adj_dummy == 1
replace benchmark_cat = 3 if pbt_benchmark == 0

/* Create variables for market return test */
gen aud_adj_pi_ps = aud_adj_pi/cshpria
gen mgmt_adj_pi_ps = mgmt_adj_pi/cshpria
gen aud_excess_adj_dummy = (aud_excess_adj > 0)

/* Save file */
save "DATA/PROC DATA/2.2.a.dta", replace
}
*-----------------------*
* Crate Final Data File * 
*-----------------------*
{
clear
use "DATA/PROC DATA/2.2.a.dta" 

/* Keep needed variables */
keep mgmt_adj_amt_s_pi aud_adj_amt_s_pi mgmt_adj_dummy aud_adj_dummy aud_amort_adj mgmt_amort_adj earnings_vol ln_at ///
ln_pi loss crosslisted ln_aud_rmms aud_ng_rmm am_s_pi big4 ln_aud_firm_tenure revenue_growth ///
contextual_factor_score aud_excess_adj_s_pi mgmt_excess_adj_s_pi analyst_adj_amt_s_pi numest pi_lead1_s_at ///
mgmt_adj_pi_s_at mgmt_exclude_s_at aud_adj_pi_s_at aud_exclude_s_at disagreement aud_partner_change aud_firm_change leverage ///
roa roa_lag1 cashflow_s_at cash_vol restructure aquisition ppe_s_at rec_turn pay_turn opinmod breakeven /// 
ln_sharesout stdev perc_calculated am_s_pi_lag1 revt pi SensCount Largest* WouldaMade abs_ta_s_at fee_ratio ///
aud_adj_pi_ps mgmt_adj_pi_ps epsincon close bv_ps value next_year_mkt_return btm ///
/*  Variables that don't need winsorizing */ sich1 benchmark_cat pbt_benchmark regno fyear perc audit_firm_id revt_mat_perc ///
revt_mat_perc_no_adj revenue_benchmark year materiality_amt at outobs aud_excess_adj_dummy aud_rmms meet_or_beat_1cent value meanest

/* Winsor at 1 and 99 */
winsor2 mgmt_adj_amt_s_pi aud_adj_amt_s_pi mgmt_adj_dummy aud_adj_dummy aud_amort_adj mgmt_amort_adj earnings_vol ln_at ///
ln_pi loss crosslisted ln_aud_rmms aud_ng_rmm am_s_pi big4 ln_aud_firm_tenure revenue_growth ///
contextual_factor_score aud_excess_adj_s_pi mgmt_excess_adj_s_pi analyst_adj_amt_s_pi numest pi_lead1_s_at ///
mgmt_adj_pi_s_at mgmt_exclude_s_at aud_adj_pi_s_at aud_exclude_s_at disagreement aud_partner_change aud_firm_change leverage ///
roa roa_lag1 cashflow_s_at cash_vol restructure aquisition ppe_s_at rec_turn pay_turn opinmod breakeven /// 
ln_sharesout stdev perc_calculated am_s_pi_lag1 pi Largest* abs_ta_s_at fee_ratio aud_adj_pi_ps mgmt_adj_pi_ps ///
epsincon close bv_ps value next_year_mkt_return btm, replace

/* Drop observations missing key variables from Compustat */
dropmiss ln_at ln_pi earnings_vol big4 contextual_factor_score sich1 pi_lead1_s_at, any obs force

/* Drop observations missing rmm/auditor data */
dropmiss ln_aud_rmms aud_ng_rmm ln_aud_firm_tenure, any obs force

/* Drop observations missing materiality data */
dropmiss benchmark_cat mgmt_adj_dummy, any obs force
dropmiss mgmt_adj_amt aud_adj_amt mgmt_adj_dummy aud_adj_dummy perc_calculated if pbt_benchmark == 1, any obs force

save "DATA/PROC DATA/FINAL.dta", replace
}
*
}

