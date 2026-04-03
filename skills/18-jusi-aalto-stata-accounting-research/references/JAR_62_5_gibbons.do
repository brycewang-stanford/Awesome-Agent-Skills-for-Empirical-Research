*******************************************************************************
**Purpose: master file for "The Financially Material Effects of Mandatory Non-Financial Disclosure"
**Author:  Brian Gibbons
**Date:    6/27/2023
*******************************************************************************

////////////////////////////////////////////////////////////////////////////////
// set directories 
set more off, permanently

* file path directory
global path "C:/Users/gibbobri/Dropbox/PhD/Research/ESG Disclosure/"

* general directories
global data "$path/data"
global figures "$path/figures"
global tables "$path/tables"
global code "$path/code"

////////////////////////////////////////////////////////////////////////////////
// do files

///// "1", "2", & "3" level do-files that build the main datasets
//Import data from worldscope (pulled from excel plugin), merge together, create panel with variables at company-year level 
do "$code/1a-gen_ws_vars.do"		
//Import data from world bank and database of political insititutions merge together, create panel with variables at country-year level 
do "$code/1b-gen_cntry_lvl_vars.do"		
//Import disclosure scores from bloomberg
do "$code/1c-gen_bbg_vars.do"		
//Import and format data from factset lionshares, treatment key, and compustat accounting regime data
do "$code/1d-gen_other_vars.do"		
//Import patent data, generate annual count of patents and citations by gvkey
do "$code/1e-gen_patent_measures.do"	
//Merge all datasets together to get main firm-year panel
do "$code/2-merge_data_firm_panel.do"		
//Add labels to variables
do "$code/2X-label-vars.do"					
//Generate s34 Investment Fund holdings data for CUSIPS in final sample
do "$code/3-setup-tr-inst-own.do"		

///// "a" level files run main analyses 
//generate summary stats for table 1 and table 2
do "$code/a-T1-2-sum_stats.do"		
//generate Tables 3,4,5,6,7 and IA Tables 2,3,4,6
do "$code/a-T3-4-5-6-7-C2-C3-C4-C6.do"		
//generate Table 8
do "$code/a-T8-test_equity_reliance.do"		
//generate Table 9
do "$code/a-T9-inst-own-churn.do"		
//generate Table 10
do "$code/a-T10-clientele-effects.do"		
	


///// f level files generate figures 
//Creates balanced panels to use in augsynth R code 
do "$code/a-F3a-gen_data _for_augsynth.do"	

//these files must be run in R because augsynth is coded in R
//a-F3b-synth_controls
//a-F3b-synth_controls_partial
//a-F3b-synth_controls_pooled
//a-F3b-synth_controls_seperate

// after augsynth is run in R graphs for Figure 3 are made in Stata
do "$code/a-F3c-graphs_did_r_syncontr.do"		


*******************************************************************************
**Purpose: Import data from worldscope (pulled from excel plugin), merge together,
** 			create panel with variables at company-year level 
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: uses all the files in fundamentals_annual_vals from Worldscope
** 				plus "ws_mo_prc_vals" monthly returns from Worldscope
**Creates files: "ret_var_ann" "ws_company_data_52520"
*******************************************************************************

////////////////////////////////////////////////////////////////////////////
/////import excel files
/////
//worldscope
foreach x in assets bidask bkeqty capx assetsusd cash eqtyiss_net incr_ltd invst liab mkeqty mkeqtyusd op_profit ppne ppne_reduc reduc_ltd rnd sales salesUSD ltd buyback div acquis employees stdebt esgdisctr ocf shrs turn stck_opt_procd{
	import excel "$data/worldscope/fundamentals_annual_vals/ws_`x'_vals.xlsx", sheet("`x'-ann") firstrow clear
	compress
	save "$data/ws_`x'-ann.dta", replace
}

foreach x in Country ISIN SIC4 tr_ind cusip year_incorp ws_id name sedol{
	import excel "$data/worldscope/fundamentals_annual_vals/ws_company_desc_info_vals.xlsx", sheet("`x'") firstrow  clear
	save "$data/ws_`x'.dta", replace
}

use "$data/ws_Country.dta", clear
foreach x in  ISIN SIC4 tr_ind cusip year_incorp ws_id name sedol{
	joinby Code using "$data/ws_`x'.dta", unm(master)
	tab _m
	drop _m
	rm "$data/ws_`x'.dta"
	}

foreach x in ISIN SIC4 sedol name{
	replace `x'="" if `x'=="NA"
}

save "$data/ws_company_desc_info.dta", replace
rm "$data/ws_Country.dta"

////////////////////////////////////////////////////////////////////////////
/////clean & reshape annual data

/////worldscope data
//reshape

foreach x in assets bkeqty capx assetsusd cash  eqtyiss_net incr_ltd invst liab mkeqty mkeqtyusd op_profit ppne ppne_reduc reduc_ltd rnd sales salesUSD ltd buyback div acquis employees stdebt bidask   esgdisctr  ocf  shrs turn stck_opt_procd{
	use "$data/ws_`x'-ann.dta", clear
	bysort Code: keep if _n==1
	destring Y*, replace force
	reshape long Y, i(Code) j(`x', string)
	rename (`x' Y) (year `x'_ann)
	save "$data/ws_`x'-ann.dta", replace
}

tostring Code, replace 
save "$data/ws_stck_opt_procd-ann.dta", replace

//merge into one
use "$data/ws_assets-ann.dta", clear
drop if mi(Code)
drop if mi(assets_ann)


foreach x in bkeqty-ann capx-ann assetsusd-ann cash-ann eqtyiss_net-ann incr_ltd-ann invst-ann liab-ann mkeqty-ann mkeqtyusd-ann op_profit-ann ppne-ann ppne_reduc-ann reduc_ltd-ann rnd-ann sales-ann salesUSD-ann ltd-ann buyback-ann div-ann acquis-ann employees-ann stdebt-ann bidask-ann esgdisctr-ann  ocf-ann shrs-ann turn-ann stck_opt_procd-ann{
	joinby Code year using "$data/ws_`x'.dta", unm(master)
	drop _m
	rm "$data/ws_`x'.dta"
}


//drop empty columns remnants from excel pull
drop AA AB AC AD AE AF AG AH 

//join descriptive info
joinby Code using "$data/ws_company_desc_info.dta", unm(master)
tab _m
drop _m
rm "$data/ws_company_desc_info.dta"

//clean up
compress
rename Code WSCode 

foreach x in assets bkeqty capx assetsusd cash eqtyiss_net incr_ltd invst liab mkeqty mkeqtyusd  op_profit ppne ppne_reduc reduc_ltd rnd sales salesUSD ltd buyback div acquis employees stdebt bidask esgdisctr ocf  shrs turn stck_opt_procd{
	rename (`x'_ann) (`x')
}

gen summissing = 0
foreach var of varlist assets bkeqty assetsusd cash eqtyiss_net incr_ltd invst liab mkeqty  op_profit ppne ppne_reduc reduc_ltd sales salesUSD ltd buyback div acquis {
    replace summissing = summissing + 1 if mi(`var')
}

//deal with duplicates
foreach x in ISIN WSCode ws_id name{
	replace `x'="" if `x'=="NA"
}

bysort WSCode year: keep if _n==1

drop if mi(ISIN)
bysort ISIN year (summissing WSCode ws_id assets): keep if _n==1

count if mi(name)
drop if mi(name)
bysort name year (summissing WSCode ws_id assets): keep if _n==1


//save
save "$data/ws_data_merged.dta", replace

////////////////////////////////////////////////////////////////////////////
/////generate annual variables 

/////
//worldscope data
use "$data/ws_data_merged.dta", clear

//generate lags
egen WSfirmid=group(WSCode)
destring year, replace
bysort WSfirmid year: keep if _n==1
tsset WSfirmid year

//generate fundamental variables
*assets
gen lag1y_assetUSD=L1.assetsusd
gen lag1y_assets=L1.assetsusd

gen chg_assets=(assets-L1.assets)/L1.assets

*sales
gen salestoassets=sales/L1.assets
gen lag1y_salestoassets=L1.salestoassets

*tangibility to assets
gen tangtoasset=ppne/L1.assets
gen lag1y_tangtoasset=L1.tangtoasset

*market to book
gen mtb=mkeqty/L1.bkeqty
replace mtb=. if assets<liab & !mi(liab)
gen lag1y_mtb=L1.mtb

*book eqty 
gen log_bkeqty=log(bkeqty)

*equity dependence
gen eqty_dep=bkeqty/(ltd+stdebt)

*return
gen ret=log(mkeqty/L1.mkeqty)
gen lag1y_ret=L1.ret

*Q
gen q=(mkeqty+liab)/(L1.assets)
gen lag1y_q=L1.q

*ltd to assets
gen ltdratio=ltd/L1.assets
gen lag1y_ltdratio=L1.ltdratio

*market leverage
gen mktlev=(ltd+stdebt)/(L1.mkeqty+L1.ltd+L1.stdebt)
gen lag1y_mktlev=L1.mktlev

*net debt
gen netdebttoassets=(ltd+stdebt-cash)/L1.assets
gen lag1y_netdebttoassets=L1.netdebttoassets

*total leverage
gen leverage=(ltd+stdebt)/L1.assets
gen lag1y_leverage=L1.leverage

*net debt issuance 
gen netdebtiss=incr_ltd
*gen netdebtiss=reduc_ltd+incr_ltd
gen netdebtisstoasset=netdebtiss/L1.assets
gen lag1y_netdebtisstoasset=L1.netdebtisstoasset

*equity issuance
gen eqtyisstoassets=eqtyiss_net/L1.assets
gen lag1y_eqtyisstoassets=L1.eqtyisstoassets

gen neteqtyisstoassets=(eqtyiss_net-buyback)/L1.assets
replace neteqtyisstoassets=(eqtyiss_net-stck_opt_procd-buyback)/L1.assets if !mi(stck_opt_procd)
gen lag1y_neteqtyisstoassets=L1.eqtyisstoassets


gen eqtyiss_indc=1 if eqtyisstoassets>0 & !mi(eqtyisstoassets)
replace eqtyiss_indc=0 if eqtyisstoassets==0 & !mi(eqtyisstoassets)

gen neteqtyiss_indc=1 if neteqtyisstoassets>0 & !mi(neteqtyisstoassets)
replace neteqtyiss_indc=0 if neteqtyisstoassets==0 & !mi(neteqtyisstoassets)

*capex
gen capxtoasset=capx/L1.assets
gen lag1y_capxtoasset=L1.capxtoasset

gen capxtoppne=capx/L1.ppne

*r&d
gen randdtosalesnozero=(rnd/L1.sales)
gen lag1y_randdtosalesnozero=L1.randdtosales

gen randdtoassetsnozero=(rnd/L1.assets)
gen lag1y_randdtoassetsnozero=L1.randdtoassets
gen chg_randdnozero=(rnd-L1.rnd)/L1.assets

gen randdnozero_indc=1 if randdtoassetsnozero>0 & !mi(randdtoassetsnozero)
replace randdnozero_indc=0 if randdtoassetsnozero==0 & !mi(randdtoassetsnozero)


replace rnd=0 if mi(rnd) & !mi(capxtoasset) // replace missing with zeros 

gen randdtosales=(rnd/L1.sales)
gen lag1y_randdtosales=L1.randdtosales

gen randdtoassets=(rnd/L1.assets)
gen lag1y_randdtoassets=L1.randdtoassets

gen randd_indc=1 if randdtoassets>0
replace randd_indc=0 if randdtoassets==0

gen chg_randd=(rnd-L1.rnd)/L1.assets

*investments
gen inv=capx+rnd
gen invtoasset=inv/L1.assets
gen lag1y_invtoasset=L1.invtoasset

*cash
gen cashtoasset= cash/L1.assets
gen lag1y_cashtoasset=L1.cashtoasset

gen chg_cash=(cash-L1.cash)/L1.assets

*profitability
gen proftoasset=op_profit/L1.assets
gen lag1y_proftoasset=L1.proftoasset

*change in profitability
gen chgproftoasset=(op_profit-L1.op_profit)/L1.assets
gen lag1y_chgproftoasset=L1.chgproftoasset

*sales
gen lag1y_sales=L1.sales

*market equity
gen lag1y_mkeqty=L1.mkeqty

gen lag1y_mkeqtyusd=L1.mkeqtyusd

*buyback
gen buybacktoasset= buyback/L1.assets
gen lag1y_buybacktoasset=L1.buybacktoasset
 
*div
gen divtoasset= div/L1.assets
gen lag1y_divtoasset=L1.divtoasset

gen divyield=div/lag1y_mkeqty
gen lag1y_divyield=L1.divyield

gen chg_div=(div-L1.div)/L1.assets

gen div_dummy=100 if div>0
replace div_dummy=0 if mi(div_dummy)

gen lag_div_dummy=L1.div_dummy

*payout
gen payouttoasset=buybacktoasset+divtoasset
gen lag1y_payouttoasset=L1.payouttoasset

gen payout=buyback+div
gen lag1y_payout=L1.payout

*acquis
gen acquistoasset= acquis/L1.assets
gen lag1y_acquistoasset=L1.acquistoasset

*ocf-ann
gen ocftoasset=ocf/L1.assets
gen lag1y_ocftoasset=L1.ocftoasset

*employees
gen emptoasset= employees/(L1.assets/1000)
gen chg_emp= employees-L1.employees/(L1.assets/1000)
gen pctchg_emp=(employees/L1.employees)-1

*turnover
gen turnover=turn/shrs
gen lag1y_turnover=L1.turnover

*bidask
gen log_bidask=log(bidask)
gen lag1y_bidask_log=L1.log_bidask

*price
gen prc=mkeqtyusd/shrs

//create exchange rate using assets 
gen exchg_rt= assets/assetsusd


//keep only if has assets / controls 
foreach var of varlist lag1y_assetUSD lag1y_ltdratio lag1y_tangtoasset lag1y_q lag1y_randdtoassets lag1y_proftoasset  lag1y_cashtoasset {
	drop if mi(`var')
}

//winsorize at 1% in both tails
local wsvars "assetsusd lag1y_assetUSD netdebtisstoasset lag1y_netdebtisstoasset  lag1y_ltdratio ltdratio lag1y_q q lag1y_mtb mtb lag1y_tangtoasset tangtoasset  eqtyisstoassets lag1y_eqtyisstoassets cash eqtyiss_net netdebtiss invtoasset lag1y_invtoasset randdtosales lag1y_randdtosales randdtoassets lag1y_randdtoassets capxtoasset  lag1y_capxtoasset cashtoasset lag1y_cashtoasset lag1y_proftoasset proftoasset sales salesUSD lag1y_sales mkeqty lag1y_mkeqty divtoasset lag1y_divtoasset buybacktoasset lag1y_buybacktoasset acquistoasset lag1y_acquistoasset div buyback payouttoasset lag1y_payouttoasset emptoasset chg_cash chg_assets chg_randd chg_randdnozero chg_div  chg_emp pctchg_emp lag1y_ret ret mktlev lag1y_mktlev netdebttoassets lag1y_netdebttoassets leverage lag1y_leverage payout ltd inv capx rnd acquis bidask neteqtyisstoassets lag1y_neteqtyisstoassets randdtosalesnozero randdtoassetsnozero eqty_dep ocftoasset lag1y_ocftoasset chgproftoasset lag1y_chgproftoasset lag1y_divyield lag1y_mkeqtyusd lag1y_turnover turnover lag1y_bidask_log log_bidask mkeqtyusd divyield prc capxtoppne"

foreach var of local wsvars{
	winsor `var', generate(`var'_w) p(.01)
	drop `var'
	rename `var'_w `var'
} 


//put in pct (whole number)
local wsvars "netdebtisstoasset lag1y_netdebtisstoasset  lag1y_ltdratio ltdratio lag1y_tangtoasset tangtoasset  eqtyisstoassets lag1y_eqtyisstoassets invtoasset lag1y_invtoasset randdtosales lag1y_randdtosales randdtoassets lag1y_randdtoassets capxtoasset  lag1y_capxtoasset cashtoasset lag1y_cashtoasset lag1y_proftoasset proftoasset divtoasset lag1y_divtoasset buybacktoasset lag1y_buybacktoasset acquistoasset lag1y_acquistoasset payouttoasset lag1y_payouttoasset emptoasset pctchg_emp chg_randd chg_randdnozero lag1y_ret ret mktlev lag1y_mktlev netdebttoassets lag1y_netdebttoassets leverage lag1y_leverage  neteqtyisstoassets lag1y_neteqtyisstoassets randdtosalesnozero randdtoassetsnozero randd_indc randdnozero_indc neteqtyiss_indc eqtyiss_indc ocftoasset chgproftoasset lag1y_chgproftoasset lag1y_divyield lag1y_turnover turnover divyield capxtoppne"
foreach var of local wsvars{
	replace `var'=`var'*100
} 

//rename a few variables to match factset code
rename SIC4 sic4
rename assetsusd assetUSD

//drop a few outliers with unusual R&D numbers 
replace lag1y_randdtosales=. if lag1y_randdtosales >100 & !mi(lag1y_randdtosales)
replace randdtosales=. if randdtosales >100 & !mi(randdtosales)

//replace miscode
replace Country="HONG KONG" if Country=="HONGKONG"

//replace with NAs 
foreach x in ISIN Country sic4{
	replace `x'="." if `x'=="NA"
}

destring sic4, replace

//save and clean up
compress
save "$data/ws_company_data_52520.dta", replace 
rm "$data/ws_data_merged.dta"

////////////////////////////////////////////////////////////////////////////
/////clean & reshape monthly return data
import excel "$data/worldscope/monthly_ret/ws_mo_prc_vals.xlsx", sheet("mo_prc") firstrow clear
save "$data/ws_prc_mo.dta", replace

/////worldscope monthly ret data
//reshape
use "$data/ws_prc_mo.dta", clear
bysort WSCode: keep if _n==1
destring M*, replace force
reshape long M, i(WSCode) j(prc, string)
rename (prc M) (mo prc_mo)
save "$data/ws_prc_mo.dta", replace

//format months
drop if mi(WSCode)
gen month=real(substr(mo,1,2))
gen year=real(substr(mo,3,4))
gen month2=ym(year,month)
format month2 %tm
drop month mo
rename month2 mo

//time set
egen WSfirmid=group(WSCode)
destring mo, replace
bysort WSfirmid mo: keep if _n==1
tsset WSfirmid mo

//clean & generate monthly returns
replace prc_mo=. if prc_mo<=0
gen ret_mo=(prc_mo/L1.prc_mo)-1
replace ret_mo=. if prc_mo==L1.prc_mo
sum ret_mo, det
winsor2 ret_mo, cuts(1 99) replace

//generate 2 year variance
rangestat (variance) ret_mo, interval(mo -24 0) by(WSCode)

//keep only one obs per year
bysort WSCode year (mo): keep if _n==_N

keep WSCode year ret_mo_variance
bysort WSCode year: keep if _n==1

//winsorize 1% 
sum ret_mo_variance, det
winsor2 ret_mo_variance, cuts(1 99) replace

//clean up and save
compress
save "$data/ret_var_ann.dta", replace 
rm "$data/ws_prc_mo.dta"*******************************************************************************
**Purpose: Import data from world bank and database of political insititutions merge together,
** 			create panel with variables at country-year level 
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: uses csvs downloaded from world bank, "DPI2017", creates and uses a header file "Countryname_header"
**Creates files: "wrldbnk_country_data", "pol_country_data"
*******************************************************************************


////////////////////////////////////////////////////////////////////////////
/////import world bank csv files 

local varlist "co2 gdp_pc gdp_pc_grwth gross_cap_form inflation oil_use prime_rt real_prime_rt renewable_energy resource_rents risk_pre taxes_pct_gdp unemply urban_pop"

// single variables 
foreach x of local varlist{
	import delimited "$data/country_level/world_bank/`x'/`x'.csv", varnames(1) case(preserve) encoding(UTF-8) clear 
	compress
	save "$data/wrldbnk_`x'.dta", replace
}

// governance file 
local gov_sheets "corruption_control gov_effect pol_stabl rule_law reg_qual voice"

foreach sheet of local gov_sheets {
	import excel "$data/country_level/world_bank/governance_indicators/WGIData_clean.xlsx", sheet(`sheet') firstrow clear
	compress
	save "$data/wrldbnk_`sheet'.dta", replace
}
////////////////////////////////////////////////////////////////////////////
/////clean & reshape  worldbank

//reshape
foreach x of local varlist{
	use "$data/wrldbnk_`x'.dta", clear
	bysort Country: keep if _n==1
	destring Y*, replace force
	reshape long Y, i(Country) j(`x', string)
	rename (`x' Y) (year `x')
	destring year, replace
	drop if year<1997
	save  "$data/wrldbnk_`x'.dta", replace
}

foreach x of local gov_sheets{
	use "$data/wrldbnk_`x'.dta", clear
	bysort Country: keep if _n==1
	destring Y*, replace force
	reshape long Y, i(Country) j(`x', string)
	rename (`x' Y) (year `x')
	destring year, replace
	drop if year<1997
	save  "$data/wrldbnk_`x'.dta", replace
}

//merge into one
use "$data/wrldbnk_co2.dta", clear
foreach x in gov_effect pol_stabl rule_law reg_qual voice corruption_control gdp_pc gdp_pc_grwth gross_cap_form inflation oil_use prime_rt real_prime_rt renewable_energy resource_rents risk_pre taxes_pct_gdp unemply urban_pop {
joinby Country year using "$data/wrldbnk_`x'.dta", unm(master)
drop _m
rm "$data/wrldbnk_`x'.dta"
}

//generate lags
egen country_id=group(Country)
bysort country_id year: keep if _n==1
tsset country_id year

//winsorize
local wrldbnk_vars "co2 gov_effect pol_stabl rule_law reg_qual voice corruption_control gdp_pc gdp_pc_grwth gross_cap_form inflation oil_use prime_rt real_prime_rt renewable_energy resource_rents risk_pre taxes_pct_gdp unemply urban_pop" 

foreach x of local wrldbnk_vars  {
	winsor `x', generate(`x'_w) p(.01)
	drop `x'
	rename `x'_w `x'
}

sum `wrldbnk_vars', det

//makes lags
foreach x of local wrldbnk_vars  {
	gen lag1y_`x'=L1.`x'
}

/*
//get countries to match to worldscope (handmatch to worldscope Countries and save as Countryname_header in excel)
rename Country wbCountry
bysort wbCountry: keep if _n==1
keep wbCountry
export excel using "$data/country_level/world_bank/wb_country_names.xls", firstrow(variables) replace

import excel "$data/Countryname_header.xls", sheet("Sheet1") firstrow allstring clear
save "$data/Countryname_header.dta", replace 
*/

rename Country wbCountry
joinby  wbCountry using  "$data/Countryname_header.dta", unm(master)
tab _m
drop _m

//clean up and save
compress
save "$data/wrldbnk_country_data.dta", replace
rm "$data/wrldbnk_co2.dta"

////////////////////////////////////////////////////////////////////////////
/////clean  database of political institutions

//load data
use "$data/country_level/database_of_political_insitutions/DPI2017.dta", clear 

//keep relevant variables
keep countryname year gov1rlc herfgov  
rename countryname polCountry

//generate variables
tab gov1rlc
tostring gov1rlc, replace force
tab gov1rlc
gen left=1 if gov1rlc=="3"
replace left=0 if inlist(gov1rlc, "1","2")
tab left

egen dpi_id=group(polCountry)
tsset dpi_id year
foreach x in herfgov left gov1rlc{
	gen lag1y_`x'=L1.`x'
}

/*
//get countries to match to worldscope (handmatch to worldscope Countries and save as Countryname_header in excel)
bysort polCountry: keep if _n==1
keep polCountry
export excel using "C:/Users/gibbobri/Dropbox/PhD/Research/ESG Disclosure/data/pol_country_names.xls", firstrow(variables) replace

import excel "C:/Users/gibbobri/Dropbox/PhD/Research/ESG Disclosure/data/Countryname_header.xls", sheet("Sheet1") firstrow allstring clear
save Countryname_header, replace 
*/

joinby polCountry using  "$data/Countryname_header.dta", unm(master)
tab _m
keep if _m==3
drop _m


//save
save "$data/pol_country_data.dta", replace

*******************************************************************************
**Purpose: imports disclosure scores from bloomberg
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: uses disclosure scores pulled from Bloomberg using excel in bloomberg folder 
**Creates files: creates bbg_X for the different types of disclosure scores
*******************************************************************************



/////
//bloomberg data
import excel "$data/bloomberg/Disclosure_Score.xlsx", sheet("ISIN-bbg") firstrow clear
compress
save "$data/fs_bbg_key.dta", replace 

import excel "$data/bloomberg/Disclosure_Score.xlsx", sheet("ESG Score Vals") firstrow clear
compress
destring year*, replace
reshape long year, i(ULT_PARENT_TICKER_EXCHANGE) j(esg_disc_scor)
rename (esg_disc_scor year) (year esg_disc_scor)
bysort ULT_PARENT_TICKER_EXCHANGE year: keep if _n==1
joinby ULT_PARENT_TICKER_EXCHANGE using "$data/fs_bbg_key.dta", unm(master)
drop _m
rename FF_ISIN ISIN
save "$data/bbg_esg_disc_scor.dta", replace 


//original sample
foreach x in GOVNCE_DISC_SCR ENVIRON_DISC_SCR SOCIAL_DISC_SCR{
	import excel "$data/bloomberg/Disc_Score_Comp_Vals.xlsx", sheet("`x'") firstrow clear
	compress
	drop if mi(ULT_PARENT_TICKER_EXCHANGE)
	destring year*, replace
	reshape long year, i(ULT_PARENT_TICKER_EXCHANGE) j(`x')
	rename (`x' year) (year `x')
	bysort ULT_PARENT_TICKER_EXCHANGE year: keep if _n==1
	drop if mi(`x')
	joinby ULT_PARENT_TICKER_EXCHANGE using "$data/fs_bbg_key.dta", unm(master)
	drop _m
	rename FF_ISIN ISIN
	save "$data/bbg_`x'.dta", replace 
}


//expanded sample (couldnt download all from BBG at once so its in 2 files)
foreach x in esg_disc_scor GOVNCE_DISC_SCR ENVIRON_DISC_SCR SOCIAL_DISC_SCR{
	import excel "$data/bloomberg/Disc_Score_Expanded_vals.xlsx", sheet("`x'") firstrow clear
	compress
	drop if mi(FF_ISIN)
	bysort FF_ISIN: keep if _n==1
	destring year*, replace
	reshape long year, i(ULT_PARENT_TICKER_EXCHANGE) j(`x')
	rename (`x' year) (year `x')
	bysort FF_ISIN year: keep if _n==1
	drop if mi(`x')
	rename FF_ISIN ISIN
	save "$data/bbg_`x'_expanded.dta", replace 
}


*******************************************************************************
**Purpose: Import and format data from factset lionshares, treatment key, and compustat accounting regime data
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: "ws_company_data" "treat_key_updated51520.xlsx" "inst_own_vals.xlsx"  "comp_global_acct_std"
**Creates files: "fs_industry_sic" "fs_industry_other" "treat_key" "fs_inst_own_final" 
*******************************************************************************

////////////////////////////////////////////////////////////////////////////////
/////create list of isins and countries to get industry codes from Factset, import
/*
//get list of country names 
use "$data/ws_company_data.dta", clear
keep Country
bysort Country: keep if _n==1
save country_list, replace 
export excel using "$data/country_list.xls", firstrow(variables) replace

//get list of ISINs for factset data
use "$data/ws_company_data.dta", clear
keep ISIN
bysort ISIN: keep if _n==1
export excel using "$data/isin_list.xls", firstrow(variables) replace
*/

/////after feeding isin to factset to get industry codes, import data (don't think this is actually used)
//import factset industries
import excel "$data/factset/ws_isins_industry_vals_new.xlsx", sheet("Sheet1") firstrow clear
compress
keep FF_ISIN sic4
save "$data/fs_industry_sic.dta", replace

import excel "$data/factset/ws_isins_industry_vals_new.xlsx", sheet("Sheet1") firstrow clear
compress
drop sic4
save "$data/fs_industry_other.dta", replace

////////////////////////////////////////////////////////////////////////////////
/////import other datasets: treated years/countries, factset IO, compustat global accounting regimes

/////import treated key (list of countries and when they had disc regulations)
import excel "$data/treat_key_updated51520.xlsx", firstrow clear
save "$data/treat_key.dta", replace

/////import and generate factset variables
//factset institutional ownership (lionshares aggregate)
import excel "$data/factset/inst_own_vals.xlsx", sheet("inst_own") firstrow clear
compress

//reshape factset variables
destring Y*, replace force
reshape long Y, i(ISIN) j(inst_own, string)
rename (inst_own Y) (year inst_own)
destring year, replace
bysort ISIN year: keep if _n==1

//factset inst. own 
drop if mi(inst_own)
winsor2 inst_own, replace cuts(1 99) 
sum inst_own, det

//top code inst. own at 100
replace inst_own=100 if inst_own>100 & !mi(inst_own)
bysort ISIN year: keep if _n==1
save "$data/fs_inst_own_final.dta", replace

//factset locations
import excel "$data/factset/fs_location_vals.xlsx", sheet("Country_finalsamp") firstrow clear
compress
drop if mi(ISIN)
bysort ISIN: keep if _n==1
save "$data/fs_location.dta", replace

/////switching of accounting regimes from compustat global
use "$data/comp_global_acct_std.dta", clear 

tab fyear
keep if fyear>2005 //keep if after IFRS adoption in 2005 (test will drop all obs pre 2005)
tab acctstd // DI is IFRS DS is local accounting std 
egen accstd_code=group(acctstd)
bysort gvkey: egen accstd_code_max=max(accstd_code)
bysort gvkey: egen accstd_code_min=min(accstd_code)
gen check= accstd_code_max- accstd_code_min // accounting regime changes if check isnt 0 

egen firmid=group(gvkey)
bysort firmid fyear: keep if _n==1
tsset firmid fyear
tab accstd_code
gen check2=1 if accstd_code==2 & L1.accstd_code==3
tab check2
rename check2 chg_acct_std_to_IFRS
keep chg_acct_std_to_IFRS gvkey datadate fyear
keep if chg_acct_std_to_IFRS==1
gen year=year(datadate)
save "$data/acct_std_chg.dta", replace*******************************************************************************
**Purpose: import patent data, generate annual count of patents and citations by gvkey
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: "GCPD_granular_data.txt" "GCPD_granular_citFt.txt" "cmpstat_global_gvkeys"
**Creates files: "ptnt_filings_annual" "ptnt_issues_annual" "gvkey_patent_link" "ptnt_cites_annual" "gvkey_sedol_key" "gvkey_cusip_key_NA"
*******************************************************************************

////////////////////////////////////////////////////////////////////////////////
/////import patent filing data from Matos et al

/////patent filings
//load patent data
import delimited using "$data/patents/darden/GCPD_granular_data.txt", clear

//generate count and years
gen ptnt_ones=1

preserve
gen date=date(date_filing,"DMY")
format date %td
gen year=year(date)

//collapse into yearly 
collapse (sum)ptnt_filings=ptnt_ones, by(gvkey year)

foreach var in ptnt_filings{
	winsor `var', generate(`var'_w) p(.01)
	drop `var'
	rename `var'_w `var'
} 

save "$data/ptnt_filings_annual.dta", replace 

/////patent issues
restore
gen date=date(date_issue,"DMY")
format date %td
gen year=year(date)

//collapse into yearly 
collapse (sum)ptnt_issues=ptnt_ones, by(gvkey year)

foreach var in ptnt_issues{
	winsor `var', generate(`var'_w) p(.01)
	drop `var'
	rename `var'_w `var'
} 

save "$data/ptnt_issues_annual.dta", replace 


////////////////////////////////////////////////////////////////////////////////
/////import patent citation data from Matos et al 
//get gvkey for all patents 
import delimited using "$data/patents/darden/GCPD_granular_data.txt", clear

keep nr_pt gvkey
bysort nr_pt gvkey: keep if _n==1
save "$data/gvkey_patent_link.dta", replace 

//get citation data 
import delimited using "$data/patents/darden/GCPD_granular_citF.txt", clear
gen year=year(date(citf_date_filing,"DMY"))


//keep only needed vars 
drop citf_nr_pt citf_date_issue examiner citf_date_filing

//add gkveys
joinby nr_pt using "$data/gvkey_patent_link.dta", unm(master)
keep if _m==3
drop _m

//aggregate by gvkey by year
compress
gen cite=1
collapse (sum)cite_count=cite, by(gvkey year)

foreach var in cite_count{
	winsor `var', generate(`var'_w) p(.01)
	drop `var'
	rename `var'_w `var'
} 

save "$data/ptnt_cites_annual.dta", replace 


////////////////////////////////////////////////////////////////////////////////
set seed 100
set sortseed 100

/////get sedols from compustat global (needed to match patents)
use "$data/cmpstat_global_gvkeys.dta", clear
bysort sedol fyear (gvkey): keep if _n==1 //unique at sedol level

keep gvkey sedol fic conm fyear
rename fyear year
destring gvkey, replace 
save "$data/gvkey_sedol_key.dta", replace 

/////get cusips from compustat north america 
use "$data/cmpstat_NA_gvkeys.dta", clear
gen cusip6=substr(cusip,1,6)
bysort cusip6 fyear gvkey: keep if _n==1 //unique at sedol level
bysort cusip6 fyear (gvkey): keep if _n==1 //unique at sedol level

keep gvkey cusip6 fyear
rename fyear year
destring gvkey, replace 
save "$data/gvkey_cusip_key_NA.dta", replace 

*******************************************************************************
**Purpose: Merge all datasets together to get main firm-year panel
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: "ws_company_data_52520" "treat_key" "wrldbnk_country_data" "pol_country_data"
** "fs_inst_own_final" "bbg_`x'" (for dislclosure score type) "gvkey_sedol_key" "gvkey_cusip_key_NA"
**"ptnt_filings_annual" "ptnt_issues_annual" "ptnt_cites_annual" "ret_var_ann" "fs_location" "acct_std_chg"
**Creates files: "qtr_firm_panel" "qtr_firm_panel_stacked" "firmpanel_s12s34"
*******************************************************************************


////////////////////////////////////////////////////////////////////////////////
/////merge
//use holdings data
use "$data/ws_company_data_52520.dta", clear 

//merge treated key
drop if mi(Country)
drop if Country=="." | Country=="NA"
joinby Country using "$data/treat_key.dta", unm(master)
drop if Country=="." | Country=="NA"
tab Country _m
tab _m
drop _m

//merge country-level vars
joinby Country year using "$data/wrldbnk_country_data.dta", unm(master)
tab _m
drop _m

joinby Country year using "$data/pol_country_data.dta", unm(master)
tab _m
drop _m

//merge factset inst. ownership
joinby ISIN year using "$data/fs_inst_own_final.dta", unm(master)
tab _m
drop _m

//merge bloomberg disclosure
foreach x in esg_disc_scor GOVNCE_DISC_SCR ENVIRON_DISC_SCR SOCIAL_DISC_SCR{
	joinby ISIN year using "$data/bbg_`x'.dta", unm(master) update
	tab _m
	drop _m
}

foreach x in esg_disc_scor GOVNCE_DISC_SCR ENVIRON_DISC_SCR SOCIAL_DISC_SCR{
	joinby ISIN year using "$data/bbg_`x'_expanded.dta", unm(master) update
	tab _m
	drop _m
}

//merge gvkey-sedol mapping
joinby sedol year using "$data/gvkey_sedol_key.dta", unm(master)
tab _m
drop _m

count if mi(gvkey)

//merge gvkey-cusip mapping
joinby cusip6 year using  "$data/gvkey_cusip_key_NA.dta", unm(master) update
tab _m
drop _m

count if mi(gvkey)

//merge patent data
joinby gvkey year using "$data/ptnt_filings_annual.dta", unm(master)
tab _m
drop _m

joinby gvkey year using "$data/ptnt_issues_annual.dta", unm(master)
tab _m
drop _m

joinby gvkey year using "$data/ptnt_cites_annual.dta", unm(master) 
tab _m
drop _m

//merge monthly ret variance
joinby WSCode year using "$data/ret_var_ann.dta", unm(master) 
tab _m
drop _m

//merge factset location
joinby ISIN using "$data/fs_location.dta", unm(master)
tab _m
drop _m

//merge year firm switches accounting regime from non-IFRS to IFRS 
tostring gvkey, replace 
joinby gvkey year using "$data/acct_std_chg.dta", unm(master)
tab _m
drop _m

////////////////////////////////////////////////////////////////////////////////
/////generate treatment and post
egen firmFE=group(WSCode)
tsset firmFE year

//gen overall treatment 
gen treat=1 if !mi(Policy1Year)
replace treat=0 if mi(Policy1Year)

gen post=1 if year>Policy1Year
replace post=0 if mi(post)

gen treatxpost=treat*post
bysort firmFE: egen treatedfirm= max(treat)

//generate voluntary treat 
gen vol_treat=1 if !mi(Vol1Year) 
replace vol_treat=0 if mi(vol_treat)

gen vol_post=1 if year>Vol1Year  & vol_treat==1
replace vol_post=0 if mi(vol_post)

gen vol_treatxpost=vol_treat*vol_post
bysort firmFE: egen voltreatedfirm= max(vol_treat)


//generate dynamic treatment
bysort firmFE: egen mintreatyr=min(Policy1Year)
gen eventtimeyr=year-mintreatyr 

foreach x of numlist 1/5{

	gen before`x'=1 if eventtimeyr==-`x'
	replace before`x'=0 if mi(before`x')

	gen before`x'plus=1 if eventtimeyr<-`x'
	replace before`x'plus=0 if mi(before`x'plus)

	gen after`x'=1 if eventtimeyr==`x'
	replace after`x'=0 if mi(after`x')

	gen after`x'plus=1 if eventtimeyr>`x'
	replace after`x'plus=0 if mi(after`x'plus)
	}

gen after0=1 if eventtimeyr==0
replace after0=0 if mi(after0)

////////////////////////////////////////////////////////////////////////////////
/////generate other variables

//2 digit industry codes 
gen digit3=1 if sic4<1000
replace digit3=0 if sic4>999
foreach x in sic4{
	tostring `x', generate(str_`x')
	gen str2_`x'=substr(str_`x',1,2) if digit3==0
	replace str2_`x'=substr(str_`x',1,1) if digit3==1
	destring str2_`x', gen(`x'_2) force
	destring `x', replace force
	drop str2_`x'
}
drop digit3
rename (sic4_2)(sic2)

//other fixed effects 
egen countryFE=group(Country)
egen countryxyearFE=group(Country year)
egen industryFE=group(sic2)
egen industryxyearFE=group(sic2 year)
egen countryxindxyearFE=group(Country sic2 year)

//total issuance 
sort firmFE year
gen totisstoasset=netdebtisstoasset+neteqtyisstoassets
gen lag1y_totisstoasset=L1.totisstoasset
gen capxplusrndtoasset=capxtoasset+randdtoassets
gen lag1y_capxplusrndtoasset=L1.capxplusrndtoasset

//lag inst ownership
gen lag1y_inst_own=L1.inst_own


//generate patent non-missing sample
gen ptnt_nomiss=1 if !mi(ptnt_filings) | !mi(ptnt_filings) | !mi(cite_count)
replace ptnt_nomiss=0 if mi(ptnt_nomiss)
bysort firmFE: egen ptnt_nomiss_samp=max(ptnt_nomiss)

//replace missing patent measures 
foreach x in ptnt_issues ptnt_filings cite_count{
	replace `x'=0 if mi(`x')
}

//generate inverse hyperbolic sine 
ihstrans  ptnt_filings cite_count

//generate future rolling patent measures
gen ptnt_filings_roll=ptnt_filings+F1.ptnt_filings+F2.ptnt_filings
gen cite_count_roll=cite_count+F1.cite_count+F2.cite_count

//log size variables that are not rebased 
sum assetUSD lag1y_assetUSD sales lag1y_sales mkeqty lag1y_mkeqty, det
foreach var of varlist lag1y_assets assets assetUSD lag1y_assetUSD sales lag1y_sales  mkeqty lag1y_mkeqty employees cash salesUSD lag1y_gdp_pc bidask lag1y_mkeqtyusd mkeqtyusd prc turnover{
	gen `var'_log=log(`var')
}

foreach var of varlist div buyback payout eqtyiss_net netdebtiss ltd inv capx rnd acquis ptnt_filings ptnt_issues cite_count cite_count_roll ptnt_filings_roll divyield{
	gen `var'_log=log(1+`var')
}

//generate lagged  measures 
foreach var of varlist ptnt_filings cite_count ptnt_filings_log cite_count_log ihs_ptnt_filings ihs_cite_count ret_mo_variance{
	gen lag1y_`var'=L1.`var'
}

//gen risk free rate 
gen lag1y_rf_rate=lag1y_risk_pre-lag1y_prime_rt

//scale annual report
replace esgdisctr=esgdisctr*100


//replace missing herf_gov
replace herfgov=. if herfgov==-999

//drop if mi Country
drop if Country=="." 

//////////////////////////////////////////////////////
/////clean up/data constraints

//keep only if assets >10M
keep if assetUSD>10000

//drop financial utility industry
drop if sic4>5999 & sic4<7000 //drop financials
drop if sic4>4899 & sic4<5000 //drop utilities 
drop if inlist(tr_ind, 73, 76, 77, 91 102, 104, 106, 107, 108, 109, 111, 112, 113, 133, 135, 136, 137, 141, 144, 149, 152, 159, 160, 161, 162, 163, 164, 166, 169, 222, 226, 236, 237, 238, 239, 252, 255, 264)

//keep only if has controls 
foreach var of varlist lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q lag1y_randdtoassets lag1y_proftoasset   lag1y_cashtoasset  lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy Country lag1y_gdp_pc_grwth mkeqtyusd_log ltdratio q proftoasset tangtoasset ret_mo_variance ret prc_log  divyield_log  turnover_log{
	drop if mi(`var')
}

//keep only if has outcomes 
foreach var of varlist randd_indc randdtosales randdtoassets  eqtyisstoassets eqtyiss_indc neteqtyisstoassets   leverage mktlev netdebttoassets ltdratio cashtoasset netdebtisstoasset  acquistoasset capxtoasset  invtoasset assets_log  tangtoasset q  proftoasset{
	drop if mi(`var')
}

//drop known tax havens 
drop if inlist(Country, "BAHAMAS", "CAYMAN ISLANDS", "OMAN", "PANAMA") //Full List:American Samoa, Cayman Islands, Fiji, Guam, Oman, Palau, Panama, Samoa, Seychelles, Trinidad and Tobago, US Virgin Island Vanuatu

//keep only if 3+ observations for firmFE
gen pre=1 if post==0
replace pre=0 if mi(pre)
bysort firmFE: egen N=total(pre)
drop if N<3
drop N pre

//at least 10 firms per country 
bysort firmFE: gen n1=1 if _n==1
replace n1=0 if mi(n1)
bysort Country: egen Nfirms=total(n1)
drop if Nfirms <11
drop n1 Nfirms


////////////////////////////////////////////////////////////////////////////////
/////above indicators for above/below med in pre-period(firm level)
preserve 

//keep untreated firms and treated firms prior to treatment 

drop if post==1
drop if eventtimeyr==0

//medians 
foreach x in assetUSD inst_own esg_disc_scor neteqtyisstoassets eqtyisstoassets eqty_dep{
	//sample med
	*bysort year: egen med_`x'=median(`x')
	egen med_`x'=median(`x')
	bysort Country sic2: egen med_c_`x'= median(`x')

	//firm med
	bysort firmFE: egen `x'firm=median(`x')
	
	//industry med
	bysort sic2: egen med_i_`x'=median(`x')

	//above or below sample med
	gen above_med_`x'=1 if `x'firm>med_`x' & !mi(`x'firm)
	replace above_med_`x'=0 if `x'firm<=med_`x' & !mi(`x'firm)

	gen below_med_`x'=1 if `x'firm<=med_`x' & !mi(`x'firm)
	replace below_med_`x'=0 if `x'firm>med_`x' & !mi(`x'firm)
	

	
	gen above_med_i_`x'=1 if `x'firm>med_i_`x' & !mi(`x'firm)
	replace above_med_i_`x'=0 if `x'firm<=med_i_`x' & !mi(`x'firm)

	gen below_med_i_`x'=1 if `x'firm<=med_i_`x' & !mi(`x'firm)
	replace below_med_i_`x'=0 if `x'firm>med_i_`x' & !mi(`x'firm)
}

foreach x in assetUSD inst_own esg_disc_scor neteqtyisstoassets eqtyisstoassets eqty_dep{
	drop med_`x'
}


//keep year in data closest prior to treatment 
*bysort firmFE: egen close_year=max(eventtimeyr)
*keep if eventtimeyr==close_year | treat==0
bysort WSCode year: keep if _n==1
bysort WSCode: keep if _n==1
keep WSCode above* below*

//save 
save "$data/exante_splits.dta", replace
restore 


////////////////////////////////////////////////////////////////////////////////
/////above indicators for above/below med in pre-period(industry level)
preserve 

drop if post==1
drop if eventtimeyr==0
*keep if eventtimeyr<0 | treat==0

//collapse to get median by industry and generate whether above below overall medians
rename neteqtyisstoassets neteqtyiss
rename eqtyisstoassets eqtyiss

foreach x in neteqtyiss eqty_dep eqtyiss    {
	//median
	egen med_`x'=median(`x')
}

collapse (median) ind_med_neteqtyiss=neteqtyiss  ind_med_eqtyiss=eqtyiss ind_med_eqty_dep=eqty_dep (max)med_neteqtyiss med_eqtyiss med_eqty_dep, by(sic4)

foreach x in neteqtyiss eqty_dep eqtyiss {
	gen above_medind_`x'=1 if ind_med_`x'>med_`x'
	replace above_medind_`x'=0 if ind_med_`x'<=med_`x'

	gen below_medind_`x'=1 if ind_med_`x'<=med_`x' 
	replace below_medind_`x'=0 if ind_med_`x'>med_`x' 
}

bysort sic4: keep if _n==1

//save 
save "$data/external_fin_splits.dta", replace
restore 

/////generate pre period investment sensitivity to equity issuance
preserve 
keep if eventtimeyr<0 | treat==0
reghdfe randdtoassets lag1y_eqtyisstoassets, a(firmFE year, savefe)
rename __hdfe1__ rd_eqty_sens //coefficients unique to firm 

//generate sample median 
bysort WSCode: keep if _n==1
egen med_rd_eqty_sens=median(rd_eqty_sens)
bysort sic4: egen indmed_rd_eqty_sens=median(rd_eqty_sens)


keep WSCode rd_eqty_sens med_rd_eqty_sens  indmed_rd_eqty_sens 

foreach x in rd_eqty_sens{

	gen above_medind_`x'=1 if indmed_`x'>med_`x' & !mi(`x')
	replace above_medind_`x'=0 if indmed_`x'<=med_`x' & !mi(`x')

	gen below_medind_`x'=1 if indmed_`x'<=med_`x' & !mi(`x')
	replace below_medind_`x'=0 if indmed_`x'>med_`x' & !mi(`x')
}

keep WSCode above* below*

save "$data/firm_rd_eqty_sens.dta", replace
restore 

////////////////////////////////////////////////////////////////////////////////
/////merge exante splits
joinby WSCode using "$data/exante_splits.dta", unm(master)
tab _m
drop _m

joinby sic4 using "$data/external_fin_splits.dta", unm(master)
tab _m
drop _m
  
joinby WSCode using "$data/firm_rd_eqty_sens.dta", unm(master)
tab _m
drop _m

rm "$data/exante_splits.dta"
rm "$data/external_fin_splits.dta"
rm "$data/firm_rd_eqty_sens.dta"
  
local abovevars "above_med_assetUSD above_med_inst_own above_med_i_inst_own above_med_esg_disc_scor above_med_neteqtyisstoassets above_med_eqtyisstoassets above_med_eqty_dep  above_medind_neteqtyiss  above_medind_eqtyiss  above_medind_eqty_dep  above_medind_rd_eqty_sens"

foreach var of local abovevars {
	gen `var'XTXP=`var'*treatxpost
	replace `var'XTXP=0 if mi(`var'XTXP) & !mi(`var')
}

local belowvars "below_med_assetUSD below_med_inst_own below_med_i_inst_own below_med_esg_disc_scor  below_med_neteqtyisstoassets below_med_eqtyisstoassets   below_med_eqty_dep  "

foreach var of local belowvars {
	gen `var'XTXP=`var'*treatxpost
	replace `var'XTXP=0 if mi(`var'XTXP) & !mi(`var')
}

////////////////////////////////////////////////////////////////////////////////
/////generate a few other variables

//gen country-year variables
foreach x in lag1y_q lag1y_proftoasset lag1y_capxtoasset lag1y_capxplusrndtoasset lag1y_ltdratio lag1y_totisstoasset lag1y_payouttoasset lag1y_randdtoassets lag1y_eqtyisstoassets lag1y_invtoasset{
	bysort country_id year: egen cyr_`x'=median(`x')
}

//winsorize disclosure score 
foreach var in  esg_disc_scor ENVIRON_DISC_SCR SOCIAL_DISC_SCR{
	winsor `var', generate(`var'_w) p(.01)
	drop `var'
	rename `var'_w `var'
} 

//indicator for companies that change from non-IFRS to IFRS post 2005
gen year_acct_chg=1000
replace year_acct_chg=year if chg_acct_std_to_IFRS==1
bysort firmFE: egen chg_acct_std_to_IFRS_max=max(year_acct_chg)
gen pre_acct_chg=1 if year<chg_acct_std_to_IFRS_max


////////////////////////////////////////////////////////////////////////////////
/////label and save base sample

////drop if missing inst own
drop if mi(inst_own)

//check unique 
bysort firmFE year: keep if _n==1 

//get sample 
reghdfe randdtoassets treatxpost lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset lag1y_inst_own lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset, a(firmFE year) vce(cl firmFE)
eststo est_est1
rename _est_est_est1 model1

keep if model1==1

//label
qui do "$code/2X-label-vars.do"

//save
save "$data/qtr_firm_panel.dta", replace


////////////////////////////////////////////////////////////////////////////////
/////get list of final cusip8s,isin, sedols in sample for holdings match in 3-setup-tr-inst-own
//deal with missing/multiple cusip6 for firm level holdings
use "$data/qtr_firm_panel.dta", clear 
drop if mi(cusip6)
bysort cusip6 year: keep if _n==1
keep cusip6 year WSCode
save "$data/qtr_firm_panel_ids_hldng.dta", replace 

bysort cusip6: keep if _n==1
keep cusip6 WSCode
save "$data/qtr_firm_panel_ids_hldng_cusip_only.dta", replace 


////////////////////////////////////////////////////////////////////////////////
/////get list of variables to match to s12/s34 data
use  "$data/qtr_firm_panel.dta", clear 
keep WSCode year treatxpost lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q  lag1y_randdtoassets lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset lag1y_inst_own lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset ltdratio q proftoasset tangtoasset ret_mo_variance ret  mkeqtyusd_log ltdratio q proftoasset tangtoasset ret_mo_variance ret prc_log  divyield_log  turnover_log 
save  "$data/firmpanel_s12s34.dta", replace


////////////////////////////////////////////////////////////////////////////////
/////stack panel
use "$data/qtr_firm_panel.dta", clear 

/////get individual cohorts containing all treated obs in cohort, controls, and all yet untreated obs for future treat cohorts
levelsof mintreatyr, local(levels) 
foreach yr of local levels {
	preserve
	keep if mintreatyr>=`yr' | mi(mintreatyr)
	keep if  year<mintreatyr | mi(mintreatyr) | mintreatyr==`yr'
	gen stackid=`yr'
	save "$data/stacked_reg_data/maintests/stacked`yr'.dta", replace
	restore
}

/////stack indidivdual cohorts
use "$data/stacked_reg_data/maintests/stacked2001.dta", clear

foreach yr in 02 03 04 05 06 07 08 09 10 12 13 14 {
		append using "$data/stacked_reg_data/maintests/stacked20`yr'.dta"
		rm "$data/stacked_reg_data/maintests/stacked20`yr'.dta"
	}
	
/////generate fixed effect interactions
egen firmFE_stack= group(firmFE stackid)
egen year_stack= group(year stackid)
egen industryxyearFE_stack= group(industryxyearFE stackid)


bysort firmFE year stackid: keep if _n==1 
save "$data/qtr_firm_panel_stacked.dta", replace

*******************************************************************************
**Purpose: Generate s34 Investment Fund holdings data for CUSIPS in final sample
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: "all_s34_holdings" "qtr_firm_panel_ids_hldng"
**Creates files: tr_inst_own_final
*******************************************************************************



////////////////////////////////////////////////////////////////////////////////
/////load up, clean and generate position size
//get firms in final sample from full s34 data 
use "$data\holdings\all_s34_holdings.dta", clear
rename cusip cusip8
drop if mi(cusip8)
gen cusip6=substr(cusip8,1,6) 

//drop missing data
drop if mi(prc) | mi(shares)
drop if mi(shrout1) & mi(shrout2)

//drop if price is negative or zero
drop if prc<=0

//keep single position per security per reporting period (revised reports)
gen year=year(rdate)
gen reportq=qofd(rdate)

//keep last filings from two+ obs for same report date
bysort mgrno rdate cusip8 (fdate): keep if _n==1

//gen % of funds portfolio 
gen pos_size= prc*shares

////////////////////////////////////////////////////////////////////////////////
/////gen churn rate for manager using all holdings with data
preserve 
keep mgrno cusip8 cusip6 reportq pos_size shares prc 

//time set panel
egen mgr_co_id = group(mgrno cusip8)
tsset mgr_co_id reportq

// set up data
bysort mgrno: egen min_qtr=min(reportq) //first qtr mgr is in data
bysort cusip8: egen min_qtr_co=min(reportq) //first qtr comapny is in data
sort mgr_co_id reportq
gen L1_pos_size= L1.pos_size

replace L1_pos_size=0 if mi(L1_pos_size) & reportq!=min_qtr & reportq!=min_qtr_co //replace lagged position size to zero if not first year in data for mgr
gen chg_prc=L1.shares*(prc-L1.prc)
replace chg_prc=0 if mi(chg_prc) & reportq!=min_qtr & reportq!=min_qtr_co


/////numerator of churn rate from Gaspar, Massa, and Matos (2005)
sort mgr_co_id reportq
replace chg_prc=0 if mi(chg_prc) & reportq!=min_qtr & reportq!=min_qtr_co
gen cr_numerator_stock=abs(pos_size-L1_pos_size-chg_prc)
bysort mgrno reportq: egen cr_numerator_mgr=total(cr_numerator_stock)

/////denominator of churn rate from Gaspar, Massa, and Matos (2005)
gen cr_denom_stock=(pos_size+L1_pos_size)/2
bysort mgrno reportq: egen cr_denom_mgr=total(cr_denom_stock)


//generate mgr churn rate
gen mgr_churnrate=cr_numerator_mgr/cr_denom_mgr
replace mgr_churnrate=. if mgr_churnrate>2 // ~7000 obs>2. cannot be above 2 so something must be wrong with data. 

//generate stock level investor turnover 
bysort cusip8 reportq: egen inst_pos_size=total(pos_size)
gen mgr_weight=pos_size/inst_pos_size

/*
//check only 1 unique value for mgr_churnrate per mgr-qtr 
egen tag = tag(mgr_churnrate)
egen distinct = total(tag), by(mgrno reportq)
tab distinct
*/

//keep only 1 obs per mgr-qtr 
bysort mgrno cusip8 reportq: keep if _n==1
keep mgr_co_id mgrno cusip8 reportq mgr_churnrate mgr_weight

forvalues i = 1/3{
	sort mgr_co_id reportq
	gen L`i'mgr_churnrate_stp1=L`i'.mgr_churnrate if !mi(L`i'.mgr_churnrate)
	bysort mgrno reportq: egen L`i'mgr_churnrate=max(L`i'mgr_churnrate_stp1)
	drop L`i'mgr_churnrate_stp1
}

gen mgr_churnrate4_step1=.25*(mgr_churnrate+L1mgr_churnrate+L2mgr_churnrate+L3mgr_churnrate)*mgr_weight 
bysort mgrno reportq: egen mgr_churnrate4=max(mgr_churnrate4_step1)
bysort cusip8 reportq: egen investor_turn=total(mgr_churnrate4_step1)
keep cusip8 reportq investor_turn


//save and restore
bysort cusip8 reportq: keep if _n==1
save "$data\holdings\s34_invest_turn.dta", replace 
restore 

////////////////////////////////////////////////////////////////////////////////
/////finish creating investor turnover rate for firms in final sample
//lots of multiple cusip8s within cusip6 try to find primary shares to match to final sample
//if more than one cusip8 per cusip6 drop if not 10 or multiple of 10 for last 2 cusip digits (most likely primary shares)
//first keep 10, then 20, then 30, then 40, 50, 60, 70,80, then min last two digits

bysort mgrno rdate cusip6 (cusip8 fdate): gen N=_N 
gen cusip8last2=substr(cusip8,7,2)
save "$data\holdings\temp_hld.dta", replace

keep if N>1

*10-80
foreach x of numlist 1/8{
	preserve
	keep if cusip8last2=="`x'0"
	gen ordering=`x'
	save "$data\holdings\cusip6_`x'0s.dta", replace
	restore
}


*min last dig
preserve
destring cusip8last2, replace force
drop if mi(cusip8last2)
bysort mgrno rdate cusip6: egen min_last2=min(cusip8last2) 
keep if cusip8last2==min_last2
gen ordering=9
save "$data\holdings\cusip6_90s.dta", replace
restore

//append all together and keep minimum to create unique cusip6 cvales
use "$data\holdings\cusip6_10s.dta", clear
foreach x of numlist 2/9{
	disp "working on `x'"
	append using "$data\holdings\cusip6_`x'0s.dta",  force
	rm "$data\holdings\cusip6_`x'0s.dta"
}
bysort mgrno rdate cusip6 (fdate): egen min_order=min(ordering)
keep if order==min_order 
save "$data\holdings\mult_cusip8_clean.dta", replace

//append new unique cusip6s back to original data with unique values
use "$data\holdings\temp_hld.dta", clear
keep if N==1
append using "$data\holdings\mult_cusip8_clean.dta",  force
 

bysort mgrno rdate cusip6 (fdate): gen n=_N //unique
tab n
drop n N cusip8last2 min_last2 ordering  min_order
 
//joinby cusips in final sample 
count
joinby cusip6 using "$data\qtr_firm_panel_ids_hldng_cusip_only.dta", unm(master) 
*tab _m 
count
keep if _m==3
drop _m
bysort mgrno rdate cusip6 (fdate): gen n=_N //unique
tab n
drop n
 
//join investor turn number
joinby cusip8 reportq using "$data\holdings\s34_invest_turn.dta", unm(master) 
*tab _m
drop _m
bysort mgrno rdate cusip6 (fdate): gen n=_N //unique
tab n
drop n

//clean and save 
compress
save "$data\s34_holdings_fin_samp.dta", replace

//remove intermediate files
rm "$data\holdings\temp_hld.dta"
rm "$data\holdings\cusip6_10s.dta"
rm "$data\holdings\mult_cusip8_clean.dta"
rm "$data\holdings\s34_invest_turn.dta"


/////get ownership pct unique by inst-firm-year
use "$data\s34_holdings_fin_samp.dta", clear //unique at the mgrno-cusip6 (or WSCode)-rdate level

//fix share counts (shares in actual, shrout1 in millions, shrout2 in thousands)
replace shrout1=shrout1*1000000 
replace shrout2=shrout2*1000 
replace shrout2=shrout1 if mi(shrout2) & !mi(shrout1)
drop shrout1

//generate % held by insitutions  funds
gen pct_inst=shares/shrout2*100 if !mi(shrout2)
replace pct_inst=. if shares>shrout2
drop if mi(pct_inst)
sum pct_inst,det


/*
/////merge PRI signatories
//get excel sheet to match morningstar commitment levels by hand 
preserve
bysort mgrname: keep if _n==1
keep mgrno mgrname
sort mgrname
export excel using "$data\pri\pri_funds_list_tomatch.xlsx", firstrow(variables) replace

//hand match in excel

//reimport and save as dta file 
import excel "$data\pri\pri_funds_signs_final.xlsx", sheet("Sheet1") firstrow clear
bysort  mgrno mgrname (priyear): keep if _n==1
save "$data\pri\pri_s34.dta, replace 
restore
*/

//merge PRI signers 
joinby mgrno mgrname using "$data\pri\pri_s34.dta", unm(master)
*tab _m
drop _m 

//generate PRI year indicator
gen pri=1 if prisign==1 & priyear>year & !mi(prisign) & !mi(priyear)
replace pri=0 if mi(pri)

gen nonpri=0 if pri==1
replace nonpri=1 if pri==0


/////generate % ownership for different categories
foreach x of varlist pri nonpri {
	gen pct_`x'=pct_inst if `x'==1
	replace pct_`x'=0 if mi(pct_`x')
}

//keep last position in year 
*tab reportq
bysort mgrno WSCode year  (rdate fdate cusip8): gen n=_n
bysort mgrno WSCode year  (rdate fdate cusip8): gen N=_N
keep if n==N 
drop n N reportq
 
bysort mgrno WSCode year: gen N=_N
tab N
drop N

//collapse into annual holding level
collapse (sum ) pct_* (max)investor_turn, by(WSCode year)
replace investor_turn=investor_turn*100

save "$data/pct_esg_hold_s34.dta", replace 

/////join annual holdings to firm level data and finalize
//join s34 holdings data to firm level
use "$data/qtr_firm_panel.dta", replace
joinby WSCode year using "$data/pct_esg_hold_s34.dta", unm(master)
tab _m

rm "$data/pct_esg_hold_s34.dta"

//replace missings to zero if they have a cusip but arent held by the funds 
foreach x of varlist  pct_inst    pct_pri pct_nonpri{
	replace `x'=0 if mi(`x') & !mi(cusip6)
}

//keep only firms with non-missing cusip
drop if mi(cusip6)
drop _m

//topcode at 100
foreach x of varlist  pct_inst   pct_pri pct_nonpri {
	replace `x'=0 if mi(`x')
	replace `x'=100 if `x'>100  & !mi(`x')
}

//winsorize holdings 
*sum  pct_*, det
winsor2  pct_* investor_turn, cuts (1 99) replace
*sum  pct_*, det

//generate lagged and forward values 
tsset firmFE year

foreach x of varlist  pct_pri pct_nonpri eqtyisstoassets eqtyiss_indc{
	gen f1_`x'=F1.`x'
	gen L1_`x'=L1.`x'
}


//save
bysort WSCode year: keep if _n==1
save "$data/tr_inst_own_final.dta", replace

*******************************************************************************
**Purpose: Creates balanced panels to use in augsynth R code 
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: qtr_firm_panel
**Creates files: augsynth_test
*******************************************************************************


////////////////////////////////////////////////////////////////////////////////
/////loop thru and create a 6 year balanced panel around all years 2004-2016
foreach x of numlist 2004/2016{
	use "$data/qtr_firm_panel.dta", clear
	est clear
	keep if model1==1
	keep if !mi(randdtoassets)
	keep if !mi(inst_own)
	keep if !mi(lag1y_assets_log)


	//keep all treated firms that year and untreated 
	keep if mintreatyr==`x' | mi(mintreatyr)

	//keep -3,+3 around t=0 with full balance
	egen wanted = total(inrange(year, `x'-3, `x'+3)), by(firmFE)
	tab wanted 
	keep if wanted==7 & year>=`x'-3 & year<=`x'+3
	gen eventtime2=`x'-year

	//check balanced
	tsset firmFE year

	save "$data/augsynth/bal_`x'.dta", replace
}

/////append balanced panels together
//load start
use "$data/augsynth/bal_2004.dta", clear 

foreach x of numlist 2005/2013{
	append using "$data/augsynth/bal_`x'.dta"
	rm "$data/augsynth/bal_`x'.dta"
}

//keep unique obs
bysort firmFE year: keep if _n==1

//save 
save "$data/augsynth/augsynth_test.dta", replace
rm "$data/augsynth/bal_2004.dta"
*******************************************************************************
**Purpose: Create Figure 3
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: augsynth_output_did
**Creates files: "`var'_synthcont_did.png" "`var'_synthcont_did.png"
*******************************************************************************

////////////////////////////////////////////////////////////////////////////////
//import augsynth output from R (code to generate in code/augsynth file directory)
**note: I took the output from the R files for partial, pooled, and seperate and aggregated them in to "augsynth_output_did.xlsx"
import excel "$data/augsynth/augsynth_output_did.xlsx", sheet("Sheet1") firstrow clear
set scheme s1mono // black and white

////////////////////////////////////////////////////////////////////////////////
//loop thru and create att d-i-d graphs for each var 

replace eventtime=eventtime+.1 if code=="pooled"
replace eventtime=eventtime-.1 if code=="separate"


foreach var in randdtoassets instown neteqtyiss capxtoassets{
preserve
keep if variable=="`var'"


twoway ///
(scatter  xbar eventtime if code=="separate", lpattern(dash) msymbol(S))  /// 
(scatter  xbar eventtime if code=="partial", lpattern(solid) msymbol(D))  /// 
(scatter  xbar eventtime if code=="pooled", lpattern(dash_dot) msymbol(C))  ///
(rcap low95 high95 eventtime if code=="separate", vert) /// code for 95% CI
(rcap low95 high95 eventtime if code=="partial", vert) /// code for 95% CI
(rcap low95 high95 eventtime if code=="pooled", vert), /// code for 95% CI
legend(pos(1) ring(0) col(1) order(1 "Separate" 2 "Partial" 3 "Pooled"))  ///
xtitle("Event Year") /// 
ytitle("Avg. Treated - Avg. Synth. Control") /// 
yline(0.0, lpattern(dash) lcolor(gs8)) ///
xline(0.0,  lcolor(red)) ///
xlabel(-3(1)3) /// 
/// aspect (next line) is how tall or wide the figure is
xsize(5) ysize(3) ///
graphregion(margin(medlarge) fcolor(white) lcolor(white)) ///
plotregion(fcolor(white) ifcolor(white)) ///

graph export "$figures/`var'_synthcont_did.png", replace width(2000)
restore
}*******************************************************************************
**Purpose: Generate Tables 1 and 2
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: qtr_firm_panel
**Creates files: T1-sample_dist T2-sum-stats
******************************************************************************

/////Table 1 -- obs by country, year
//by country
use "$data/qtr_firm_panel.dta", clear
keep if model1==1

bysort Country: gen Observations=_N
bysort firmFE: keep if _n==1
bysort Country: gen Nfirms=_N
bysort Country: keep if _n==1
keep Country Observations Nfirms

export excel using "$tables/T1-sample_dist.xls", firstrow(variables) replace

//treated and untreated by  year
use "$data/qtr_firm_panel.dta", clear
keep if model1==1
gen ones=1
gen treatcnt=1 if treatxpost==1
replace treatcnt=0 if treatxpost==0
gen untreatcnt=1 if treatxpost==0
replace untreatcnt=0 if treatxpost==1
gen frsttrt=1 if Policy1Year+1==year
replace frsttrt=0 if mi(frsttrt)

collapse (sum) frsttrt treatcnt untreatcnt ones, by (year)
bysort year: gen Observations=_N
export excel using "$tables/T1b-sample_dist_by year.xls", firstrow(variables) replace

/////Table 2 -- sum stats 
use "$data/qtr_firm_panel.dta", clear
keep if model1==1

//label variables
qui do "$code/2X-label-vars.do"

local treat "treatxpost"
local rnd "randdtoassets randdtoassetsnozero randd_indc ptnt_filings cite_count" 
local equity "eqtyisstoassets neteqtyisstoassets"
local cap "netdebtisstoasset totisstoasset cashtoasset leverage mktlev netdebttoassets ltdratio"
local otherinv "capxtoasset acquistoasset invtoasset"
local controls "lag1y_q lag1y_assetUSD lag1y_tangtoasset lag1y_proftoasset lag_div_dummy inst_own bidask"
local owncontrols "mkeqtyusd ret_mo_variance ret prc divyield turnover"
local esg " esgdisctr esg_disc_scor ENVIRON_DISC_SCR SOCIAL_DISC_SCR bidask "
local econcontrols "lag1y_gdp_pc lag1y_gdp_pc_grwth lag1y_unemply lag1y_taxes_pct_gdp"
local socialcontrols "lag1y_herfgov lag1y_left lag1y_rule_law lag1y_pol_stabl lag1y_corruption_control"
local envirocontrols "lag1y_co2 lag1y_renewable_energy"

local sumstats "treatxpost capxtoasset randdtoassets invtoasset randdtoassetsnozero randd_indc inst_own eqtyisstoassets neteqtyisstoassets mkeqtyusd ltdratio tangtoasset q proftoasset  ret_mo_variance ret prc  divyield  turnover lag1y_assetUSD lag_div_dummy lag1y_gdp_pc lag1y_gdp_pc_grwth lag1y_unemply lag1y_taxes_pct_gdp lag1y_herfgov lag1y_left lag1y_rule_law lag1y_pol_stabl lag1y_corruption_control lag1y_co2 lag1y_renewable_energy esgdisctr esg_disc_scor ENVIRON_DISC_SCR SOCIAL_DISC_SCR bidask"


/////panel a -- full sample
replace lag1y_assetUSD=lag1y_assetUSD/1000
replace mkeqtyusd=mkeqtyusd/1000
replace ret_mo_variance=ret_mo_variance*100

est clear
estpost summarize `sumstats', de 
esttab using "$tables/T2-sum-stats.rtf", cells("mean(fmt(%9.2fc)) p50(fmt(%9.2fc)) sd(fmt(%9.2fc))  count(fmt(%9.0fc)) ") noobs replace label title("Summary Statistics")     


*****note: detail on patents and cites in test_patent_outcome file*******************************************************************************
**Purpose: Genrate Table 10
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: tr_inst_own_final
**Creates files: FILE NAMES HERE
*******************************************************************************


////////////////////////////////////////////////////////////////////////////////
/////
use "$data/tr_inst_own_final.dta", clear 

//set up fixed effects and clustering
local cluster "cl firmFE"

local fixed2  "firmFE industryxyearFE"
local fixedtxt2 "Firm & Industry x Year"


//generate new fixed effects
egen listcntryxindxyearFE = group(fs_prim_list_country sic2 year)
egen listcntryxyearFE = group(fs_prim_list_country year)

//generate changes
local changes "pct_pri pct_nonpri pct_inst" 

sort firmFE year

foreach x of local changes{
	gen chg_trt_`x'=`x'-L2.`x' if eventtimeyr==1
	replace chg_trt_`x'=0 if mi(chg_trt_`x') & treat==0
	replace chg_trt_`x'=0 if mi(chg_trt_`x') & eventtimeyr<0 & treat==1
	bysort firmFE: egen maxchg_trt_`x'=max(chg_trt_`x')
	replace chg_trt_`x'=maxchg_trt_`x' if mi(chg_trt_`x') & eventtimeyr>0 & treat==1
	
	bysort firmFE: egen med_post_`x'=median(`x') if treat==1 & treatxpost==1
	bysort firmFE: egen max_med_post_`x'=max(med_post_`x') 

	bysort firmFE: egen med_pre_`x'=median(`x') if treat==1 & treatxpost==0
	bysort firmFE: egen max_med_pre_`x'=max(med_pre_`x') 

	gen chg_trt_med_`x'=max_med_post_`x'-max_med_pre_`x' if treatxpost==1
	replace chg_trt_med_`x'=0 if mi(chg_trt_med_`x')
}


//standardize variables
local controls "lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q  lag1y_randdtoassets lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset lag1y_inst_own lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset ltdratio q proftoasset tangtoasset ret_mo_variance ret L1_eqtyisstoassets" 

foreach x of local controls{
egen `x'1 = std(`x')
drop `x'
rename `x'1 `x'
}


//controls
local invcontrols "lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset "
local capcontrols "lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q  lag1y_proftoasset lag1y_netdebtisstoasset  lag_div_dummy lag1y_cashtoasset"
local ctrycontrols "lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset"
local owncontrols "mkeqtyusd_log ltdratio q proftoasset tangtoasset ret_mo_variance ret prc_log  divyield_log  turnover_log "

////////////////////////////////////////////////////////////////////////////////
/////test 

//placeholder regression
est clear
local sumstats "pct_pri pct_nonpri"

estpost summarize `sumstats', de 
esttab using "$tables/T10-clientele.rtf", cells("mean(fmt(%9.3fc)) p50(fmt(%9.2fc)) sd(fmt(%9.2fc))  count(fmt(%9.0fc)) ") noobs replace label title("Summary Statistics")     


/////changes from event time t-1 to event time t+1
//equity issuance lag 1 year
est clear

reghdfe eqtyisstoassets chg_trt_pct_inst   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_nonpri     `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_inst chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
test chg_trt_pct_inst=chg_trt_pct_pri
est store e4
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri chg_trt_pct_nonpri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
test chg_trt_pct_pri=chg_trt_pct_nonpri
est store e5
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b T10.} {/i Issuance})


//R&D lag 1 year
est clear
reghdfe randdtosales chg_trt_pct_inst  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_pri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_nonpri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_inst chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
test chg_trt_pct_inst=chg_trt_pct_pri
est store e4
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_pri chg_trt_pct_nonpri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
test chg_trt_pct_pri=chg_trt_pct_nonpri
est store e5
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b T10.} {/i R&D})


/////changes from event time t-1 to event time t+1, Table IA 7a
local fixed2  "firmFE countryxyearFE"
local fixedtxt2 "Firm, Country x Year"


//equity issuance lag 1 year
est clear

reghdfe eqtyisstoassets chg_trt_pct_inst   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_nonpri     `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_inst chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC7A.} {/i Issuance})


//R&D lag 1 year
est clear
reghdfe randdtosales chg_trt_pct_inst  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_pri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_nonpri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_inst chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC7A.} {/i R&D})


/////other vars 
est clear
reghdfe neteqtyisstoassets chg_trt_pct_pri `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri  `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt'" , replace

reghdfe randdtosales chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt'" , replace
 
reghdfe capxtoasset chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt'" , replace

reghdfe invtoasset chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e5
estadd local fixed "`fixedtxt'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC7A.} {/i Untabulated})


/////changes from event time t-1 to event time t+1, Table 7C
local fixed2  "firmFE listcntryxyearFE" 
local fixedtxt2 "Firm,  List Country x Year"


//equity issuance lag 1 year
est clear
reghdfe eqtyisstoassets chg_trt_pct_inst   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_nonpri     `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_inst chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC7C.} {/i Issuance})


//R&D lag 1 year
est clear
reghdfe randdtosales chg_trt_pct_inst  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_pri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_nonpri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_inst chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC7C.} {/i R&D})

//other vars 
est clear
reghdfe neteqtyisstoassets chg_trt_pct_pri `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri  `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt'" , replace
 
reghdfe randdtosales chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt'" , replace
 
reghdfe capxtoasset chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt'" , replace

reghdfe invtoasset chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e5
estadd local fixed "`fixedtxt'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC7C.} {/i Untabulated})




/////changes from event time t-1 to event time t+1, IA Table 6
drop if Country=="UNITED STATES" | Country=="JAPAN"
local fixed2  "firmFE industryxyearFE"
local fixedtxt2 "Firm & Industry x Year"

est clear

reghdfe eqtyisstoassets chg_trt_pct_inst   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri   `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe eqtyisstoassets chg_trt_pct_nonpri     `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC6B.} {/i Issuance})


//R&D lag 1 year
est clear
reghdfe randdtosales chg_trt_pct_inst  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_pri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe randdtosales chg_trt_pct_nonpri `invcontrols'  `ctrycontrols' , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace


esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC6B.} {/i Untabulated})


//other vars 
est clear 
reghdfe neteqtyisstoassets chg_trt_pct_pri `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt'" , replace

reghdfe eqtyisstoassets chg_trt_pct_pri  `capcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt'" , replace
 
reghdfe randdtosales chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt'" , replace
 
reghdfe capxtoasset chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt'" , replace

reghdfe invtoasset chg_trt_pct_pri  `invcontrols'  `ctrycontrols'  , a(`fixed2') vce(`cluster')
est store e5
estadd local fixed "`fixedtxt'" , replace

esttab e* using "$tables/T10-clientele.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(chg_trt_*) keep(chg_trt_*) ///
title({/b TC6B.} {/i Untabulated})
*******************************************************************************
**Purpose: Generate Table 8
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: qtr_firm_panel
**Creates files: "T8-DID-equity-reliance.rtf"
******************************************"*************************************

/////Financial Policy -- FULL SAMPLE
use "$data/qtr_firm_panel.dta", clear
est clear

//set up fixed effects and clustering
local fixed2  "firmFE industryxyearFE"
local fixedtxt2 "Firm & Industry x Year"

local cluster "cl firmFE"

//set up models (above)
foreach x in  above_medind_neteqtyissXTXP above_medind_eqty_depXTXP above_medind_rd_eqty_sensXTXP{
gen `x'XD=`x'*below_med_inst_ownXTXP
}

local model1 "above_medind_neteqtyissXTXP treatxpost"
local model2 "above_medind_eqty_depXTXP treatxpost"
local model3 "above_medind_rd_eqty_sensXTXP treatxpost"

local model4 "above_medind_neteqtyissXTXPXD above_medind_neteqtyissXTXP below_med_inst_ownXTXP treatxpost"
local model5 "above_medind_eqty_depXTXPXD above_medind_eqty_depXTXP below_med_inst_ownXTXP treatxpost"
local model6 "above_medind_rd_eqty_sensXTXPXD above_medind_rd_eqty_sensXTXP below_med_inst_ownXTXP treatxpost"

//standardize variables
local controls "lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q  lag1y_randdtoassets lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset lag1y_inst_own lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset" 
foreach x of local controls{
egen `x'1 = std(`x')
drop `x'
rename `x'1 `x'
}

//controls
local invcontrols "lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset"
local ctrycontrols "lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset"

//label variables
qui do "$code/2X-label-vars.do"

//placeholder regression
reg ltdratio treatxpost
est store e1
esttab e* using "$tables/T8-DID-equity-reliance.rtf", replace compress nogaps se onecell b(3) ///
title("Placeholder") 

/////R&D
foreach x in 1 2 3 4 5 6{
est clear

reghdfe randdtosales `model`x'' `invcontrols' lag1y_inst_own `ctrycontrols', a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T8-DID-equity-reliance.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
title("Full Sample - R&D") ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(`model`x'') keep(`model`x'') 

}

*******************************************************************************
**Purpose: ADD DESCRPTION
**Author:  Brian Gibbons
**Date:    6/27/2023
**Using files: FILE NAMES HERE
**Creates files: FILE NAMES HERE
*******************************************************************************

////////////////////////////////////////////////////////////////////////////////
/////set up models for Tables 9 / 10 and Internet Appendix
use "$data/tr_inst_own_final.dta", clear 

//set up fixed effects and clustering
local cluster "cl firmFE"

local fixed2  "firmFE industryxyearFE"
local fixedtxt2 "Firm & Industry x Year"

//set up models 
local model1 "treatxpost"

//standardize variables
local controls "lag1y_assets_log lag1y_ltdratio lag1y_tangtoasset lag1y_q  lag1y_randdtoassets lag1y_proftoasset lag1y_netdebtisstoasset lag1y_eqtyisstoassets lag_div_dummy lag1y_cashtoasset lag1y_inst_own lag1y_gdp_pc_grwth  cyr_lag1y_q cyr_lag1y_totisstoasset   cyr_lag1y_invtoasset ltdratio q proftoasset tangtoasset ret_mo_variance ret  L1_eqtyisstoassets " 

foreach x of local controls{
egen `x'1 = std(`x')
drop `x'
rename `x'1 `x'
}

//generate interaction with treatment
foreach x of varlist L1_pct_pri L1_pct_nonpri {
	gen `x'_TXP=`x'*treatxpost
	gen `x'_T=`x'*treat
}

//controls
local owncontrols "mkeqtyusd_log ltdratio q proftoasset tangtoasset ret_mo_variance ret prc_log  divyield_log  turnover_log "

////////////////////////////////////////////////////////////////////////////////
/////Create Tables  

/////Table 9A
//ESG Norms 
est clear

reghdfe pct_pri `model1' `owncontrols'  , a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe pct_nonpri `model1' `owncontrols'  , a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

local sumstats "pct_pri pct_nonpri"
estpost summarize `sumstats' if e(sample)==1, de 
esttab using "$tables/T9-DID-inst-own.rtf", cells("mean(fmt(%9.3fc)) p50(fmt(%9.2fc)) sd(fmt(%9.2fc))  count(fmt(%9.0fc)) ") noobs replace label title("Summary Statistics")     

esttab e* using "$tables/T9-DID-inst-own.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order(`model1') keep(`model1') 


local sumstats "inst_own pct_inst pct_HI_ENV_DYCK pct_LO_ENV_DYCK pct_pri pct_nonpri"



/////Table 9B
//overall relationship
est clear
reghdfe investor_turn L1_pct_pri `owncontrols', a(`fixed2') vce(`cluster')
est store e1
estadd local fixed "`fixedtxt2'" , replace

reghdfe investor_turn L1_pct_pri_TXP L1_pct_pri `owncontrols', a(`fixed2') vce(`cluster')
est store e2
estadd local fixed "`fixedtxt2'" , replace

reghdfe investor_turn L1_pct_nonpri  `owncontrols', a(`fixed2') vce(`cluster')
est store e3
estadd local fixed "`fixedtxt2'" , replace

reghdfe investor_turn L1_pct_nonpri_TXP L1_pct_nonpri `owncontrols', a(`fixed2') vce(`cluster')
est store e4
estadd local fixed "`fixedtxt2'" , replace

esttab e* using "$tables/T9-DID-inst-own.rtf", append compress nogaps se onecell b(3) modelwidth(7) ///
stats(fixed r2_a  N , fmt(%9.3fc %9.3fc %9.0fc ) labels("Fixed Effects" "Adj. R-squared" "Observations" ) ) ///
label collabels(none)  starlevels(* 0.10 ** 0.05 *** 0.01) nonote ///
order( L1_pct_pri L1_pct_pri_TXP  L1_pct_nonpri L1_pct_nonpri_TXP) keep(L1_pct_pri_TXP L1_pct_pri L1_pct_nonpri_TXP L1_pct_nonpri) 
