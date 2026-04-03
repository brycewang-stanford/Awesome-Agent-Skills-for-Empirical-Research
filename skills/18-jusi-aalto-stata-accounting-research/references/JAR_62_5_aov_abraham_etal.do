log using "logfile_step6_winsorizeLabel", replace

**PE Firms
use "..\Data\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
keep fm_id snapshot_year snapshot_date snapshot_datetime length word_count dict_e1 dict_e2 dict_s2 dict_g2 dict_esg2 positive valuation dict_e2_ihs dict_s2_ihs dict_g2_ihs dict_esg2_ihs logWordCount logLength
order fm_id snapshot_year snapshot_date snapshot_datetime length word_count logWordCount logLength dict_e2 dict_s2 dict_g2 dict_esg2 positive valuation dict_e2_ihs dict_s2_ihs dict_g2_ihs dict_esg2_ihs
replace length = length/1000000
label var dict_esg2 "Log. ESG Ratio"
label var dict_e2 "Log. Envir. Ratio"
label var dict_s2 "Log. Social Ratio"
label var dict_g2 "Log. Gov. Ratio"
label var dict_esg2_ihs "IHS. ESG Ratio"
label var dict_e2_ihs "IHS. Envir. Ratio"
label var dict_s2_ihs "IHS. Social Ratio"
label var dict_g2_ihs "IHS. Gov. Ratio"
label var word_count "Total number of words (in 10k)"
label var logWordCount "Log. Total number of words (in 10k)"
label var positive "Log. Positive Words Ratio"
label var valuation "Log. Valuation Words Ratio"
label var snapshot_year "Year"
label var snapshot_date "Date"
label var snapshot_datetime "Date-Time"
label var logLength "Log. Website Size (in MB)"
label var length "Website Size (in MB)"

winsor2 length word_count logWordCount logLength dict_e1 dict_e2 dict_s2 dict_g2 dict_esg2 positive valuation dict_e2_ihs dict_s2_ihs dict_g2_ihs dict_esg2_ihs, cut(0 99) trim replace
keep if snapshot_year>=2000
save "..\Data\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", replace

use "..\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep fm_id
merge 1:m fm_id using "..\Data\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
drop _m
save "..\Data\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", replace

**Hedge Funds
use "..\Data\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final_HF.dta", clear
keep fm_id snapshot_year snapshot_date snapshot_datetime length word_count dict_e2 dict_s2 dict_g2 dict_esg2 positive valuation dict_e2_ihs dict_s2_ihs dict_g2_ihs dict_esg2_ihs logWordCount logLength
order fm_id snapshot_year snapshot_date snapshot_datetime length word_count logWordCount logLength dict_e2 dict_s2 dict_g2 dict_esg2 positive valuation dict_e2_ihs dict_s2_ihs dict_g2_ihs dict_esg2_ihs
replace length = length/1000000
label var dict_esg2 "Log. ESG Ratio"
label var dict_e2 "Log. Envir. Ratio"
label var dict_s2 "Log. Social Ratio"
label var dict_g2 "Log. Gov. Ratio"
label var dict_esg2_ihs "IHS. ESG Ratio"
label var dict_e2_ihs "IHS. Envir. Ratio"
label var dict_s2_ihs "IHS. Social Ratio"
label var dict_g2_ihs "IHS. Gov. Ratio"
label var word_count "Total number of words (in 10k)"
label var logWordCount "Log. Total number of words (in 10k)"
label var positive "Log. Positive Words Ratio"
label var valuation "Log. Valuation Words Ratio"
label var snapshot_year "Year"
label var snapshot_date "Date"
label var snapshot_datetime "Date-Time"
label var logLength "Log. Website Size (in MB)"
label var length "Website Size (in MB)"

keep if snapshot_year>=2000
save "..\Data\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final_HF.dta", replace

log closelog using "logfile_analysis", replace

set more off
clear all

cd "..\Data\Data_working"

********************************************************************************
*************************LIST OF BUYOUT/GROWTH DEALS****************************
********************************************************************************
{
use "..\Data_preqin\\preqin_dealsBuyout_investors.dta", clear
keep d_dealID d_investorID
merge m:1 d_dealID using "..\Data_preqin\\preqin_dealsBuyout.dta"
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
keep if inrange(d_dealYear,2000,2022)
drop if d_firmCountry==""
keep d_dealID d_dealYear d_firmID d_investorID d_firmCountry
duplicates drop
save listOfBOGrowthDeals.dta, replace

use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep fm_id fm_pe_mainFirmStrategy
ren fm_id d_investorID
merge 1:m d_investorID using listOfBOGrowthDeals.dta
keep if _m==3
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
drop _m
bysort d_firmID: egen d_firstDealYear = min(d_dealYear)
save listOfBOGrowthDeals.dta, replace
}
********************************************************************************
*********************************LP Weights*************************************
********************************************************************************
{
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
keep fm_id f_id year
duplicates drop
gen cntr = 1
bysort fm_id year: egen double totalActiveFunds = total(cntr)
keep fm_id f_id year totalActiveFunds
merge 1:m fm_id f_id year using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
drop _m
gen cntr = 1
bysort fm_id i_ID year: egen double LPCommits = total(cntr), missing
gen double LPWgt = LPCommits/totalActiveFunds
keep fm_id i_ID year LPWgt
duplicates drop
save LPWgt.dta, replace

use "..\Data_preqin\\preqin_LPs.dta", clear
gen publicLP = cond(inlist(i_firmType,"PUBLIC PENSION FUND","GOVERNMENT AGENCY","BANK","SUPERANNUATION SCHEME","SOVEREIGN WEALTH FUND"),"Public","Private")
keep i_ID i_country publicLP
merge 1:m i_ID using LPWgt.dta
keep if _m==3
drop _m
replace i_country = "UNITED KINGDOM" if i_country=="UK"
replace i_country = "UNITED STATES" if i_country=="US"
collapse (sum) LPWgt, by(fm_id i_country year publicLP)
reshape wide LPWgt, i(fm_id i_country year) j(publicLP) string
recode LPWgtPrivate LPWgtPublic (.=0)
egen double LPWgt = rowtotal(LPWgtPrivate LPWgtPublic)
save LPWgt.dta, replace
}

********************************************************************************
****************************CONTROL VARIABLES***********************************
********************************************************************************
{
use LPWgt.dta, clear
drop LPWgtPublic LPWgtPrivate
ren i_country countryname
keep if inrange(year,2000,2022)

//World Bank Controls
merge m:1 countryname year using "..\Data_worldbank\worldbank.dta"
keep if _m==3
drop _m

foreach var of varlist GDP GDPGrowth population laborForceParticipation womenSeatsParliament {
	replace `var' = `var' * LPWgt
}
collapse (sum) GDP GDPGrowth population laborForceParticipation womenSeatsParliament, by(fm_id year)
foreach var of varlist GDP population {
	qui gen log_`var'=ln(`var')
}
drop GDP population
order fm_id year log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament
sort fm_id year
drop if year==2022
label var log_GDP "Log. GDP"
label var GDPGrowth "GDP Growth"
label var log_population "Log. Population"
label var laborForceParticipation "Labor Force (%)"
label var womenSeatsParliament "Female Representation (%)"
save Controls.dta, replace
}
********************************************************************************
****************************PANEL CONSTRUCTION**********************************
********************************************************************************
//ESG Panel
{
//Retaining only years after the year of formation of the GP & identifying years when GPs have signed the UN-PRI
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep fm_id fm_year_est fm_country dateUNPRI
merge 1:m fm_id using Controls.dta
keep if _m==3
drop _m
drop if year<fm_year_est & fm_year_est!=.
drop fm_year_est
gen dummy_GPPRI = cond(year>year(dateUNPRI) & !missing(dateUNPRI),1,0)
label var dummy_GPPRI "Post UN-PRI Pledge (PE Firm)"
save ESGPanel.dta, replace

//Adding ESG measures
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
ren snapshot_year year
collapse (mean) word_count, by(fm_id)
egen wordDecile = xtile(word_count), nq(10)
drop word_count
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
ren snapshot_year year
egen double wordDecileYear = group(wordDecile year)
keep fm_id wordDecileYear year length word_count dict_e1 dict_e2 dict_s2 dict_g2 dict_esg2 positive valuation dict_e2_ihs dict_s2_ihs dict_g2_ihs dict_esg2_ihs logWordCount logLength

merge 1:1 fm_id year using ESGPanel.dta
keep if _m==3
drop _m
egen double ctry_yr = group(fm_country year)
save ESGPanel.dta, replace
}
//LP Panel
{
//LP Investors
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
keep fm_id f_id year
duplicates drop
merge m:1 fm_id f_id using "..\Data_preqin\\preqin_fund.dta", keepus(f_fundSize_USD)
keep if _m==3
drop _m
bysort fm_id year: egen double totalSize = total(f_fundSize_USD)
gen double fundWgt = f_fundSize_USD/totalSize
keep fm_id f_id year fundWgt
merge 1:m fm_id f_id year using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
drop _m
bysort fm_id i_ID year: egen double LPWgt = total(fundWgt), missing
keep fm_id i_ID year LPWgt LPPRISignatory
duplicates drop
gen totalInvestors = 1
gen wgtTotalInvestors = LPWgt*totalInvestors
gen wgtPRIInvestors = LPWgt*LPPRISignatory
collapse (sum) PRIInvestors = LPPRISignatory totalInvestors wgtTotalInvestors wgtPRIInvestors (max) PRIInvestorPresent = LPPRISignatory, by(fm_id year)
gen logPRIInvestors = log(1+PRIInvestors)
gen logTotalInvestors = log(1+totalInvestors)
gen logWgtPRIInvestors = log(1+wgtPRIInvestors)
gen logWgtTotalInvestors = log(1+wgtTotalInvestors)
keep fm_id year PRIInvestorPresent logPRIInvestors logTotalInvestors logWgtPRIInvestors logWgtTotalInvestors
order fm_id year PRIInvestorPresent logPRIInvestors logTotalInvestors logWgtPRIInvestors logWgtTotalInvestors

//Merging with ESG Panel
merge 1:1 fm_id year using ESGPanel.dta
keep if _m==3
drop _m

label var PRIInvestorPresent "Post PRI Investor Present"
label var logPRIInvestors "Log. PRI Investors"
label var logTotalInvestors "Log. Total Investors"
label var logWgtPRIInvestors "Log. Wgtd. PRI Investors"
label var logWgtTotalInvestors "Log. Wgtd. Total Investors"

gen forReg = cond(positive!=. & valuation!=. & log_GDP!=. & GDPGrowth!=. & log_population!=. & laborForceParticipation!=. & womenSeatsParliament!=.,1,0)
save LPPRI.dta, replace

//Variables for Stacked Regressions [Cengiz et al (2019)]
use LPPRI.dta, clear
gen treatYear = year if PRIInvestorPresent==1
bysort fm_id: egen firstTreatYear = min(treatYear)
bysort fm_id: egen neverTreated = max(PRIInvestorPresent)
replace neverTreated = 1-neverTreated
drop treatYear
save LPPRI.dta, replace
}
//Mandatory Panel
{
//Regulation Exposure measure
import excel using "..\Data_Mandatory ESG\mandatory disclosure year.xlsx", clear first
replace Country = upper(Country)
replace Country = "HONG KONG SAR - CHINA" if Country=="HONG KONG"
ren (Country ESG Environment Social Governance) (i_country eventYear eventYearE eventYearS eventYearG)
drop allInSameYear
merge 1:m i_country using LPWgt.dta
drop if _m==1
drop _m
gen postPeriod = cond(eventYear==.,0,cond(year>=eventYear,1,0))
gen postPeriodE = cond(eventYearE==.,0,cond(year>=eventYearE,1,0))
gen postPeriodS = cond(eventYearS==.,0,cond(year>=eventYearS,1,0))
gen postPeriodG = cond(eventYearG==.,0,cond(year>=eventYearG,1,0))
gen regExposureE2 = LPWgt*postPeriodE
gen regExposureS2 = LPWgt*postPeriodS
gen regExposureG2 = LPWgt*postPeriodG
gen regExposure2 = LPWgt*postPeriod
gen regExposure2Private = LPWgtPrivate*postPeriod
gen regExposure2Public = LPWgtPublic*postPeriod
collapse (sum) regExposure2 regExposure2Public regExposure2Private regExposureE2 regExposureS2 regExposureG2, by(fm_id year)

label var regExposure2 "LP ESG Regulation Exposure"
label var regExposure2Public "LP ESG Regulation Exposure (Public)"
label var regExposure2Private "LP ESG Regulation Exposure (Private)"
label var regExposureE2 "LP Envir. Regn. Exposure"
label var regExposureS2 "LP Social Regn. Exposure"
label var regExposureG2 "LP Gov. Regn. Exposure"

keep fm_id year regExposure*

//Merging with ESG Panel
merge 1:1 fm_id year using ESGPanel.dta
keep if _m==3
drop _m

gen forReg = cond(positive!=. & valuation!=. & log_GDP!=. & GDPGrowth!=. & log_population!=. & laborForceParticipation!=. & womenSeatsParliament!=.,1,0)
save mandat.dta, replace
}
//Fundraising Panel
{
use "..\Data_preqin\\preqin_fund.dta", clear
gen closeDate = f_finalCloseDate
replace closeDate = f_latestCloseDate if closeDate==.
gen launchDate = f_fundRaisingLaunchDate
gen closeYear = year(closeDate)
drop if missing(closeYear)
keep if inrange(closeYear,2000,2022)
collapse (sum) f_fundSize_USD, by(fm_id closeYear)
recode f_fundSize_USD (0=-1)
bysort fm_id: egen firstFundYear = min(closeYear)
save fundRaising.dta, replace

use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_year_est fm_pe_dateUpdated
gen fm_yearLast = year(fm_pe_dateUpdated)
drop fm_pe_dateUpdated
merge 1:m fm_id using fundRaising.dta
keep if _m==3
drop _m
replace fm_year_est = firstFundYear - 5 if missing(fm_year_est)
save fundRaising.dta, replace

keep fm_id fm_year_est fm_yearLast 
ren (fm_year_est fm_yearLast) (closeYear1 closeYear2)
duplicates drop
reshape long closeYear, i(fm_id) j(j)
drop j
duplicates drop
tsset fm_id closeYear
tsfill
merge 1:1 fm_id closeYear using fundRaising.dta
drop if _m==2
keep fm_id closeYear f_fundSize_USD
recode f_fundSize_USD (.=0)
recode f_fundSize_USD (-1=.)
save fundRaising.dta, replace

use fundRaising.dta, clear
gen fundRaise = cond(f_fundSize_USD!=0,1,0)
tsset fm_id closeYear
gen largeFundRaise = 0
replace largeFundRaise = 1 if f_fundSize_USD>l.f_fundSize_USD & f_fundSize_USD>f.f_fundSize_USD & f_fundSize_USD!=.
replace largeFundRaise = 1 if l.f_fundSize_USD==0 & f.f_fundSize_USD==0 & f_fundSize_USD==.
replace largeFundRaise = 1 if _n==1 & f_fundSize_USD>f.f_fundSize_USD & f_fundSize_USD!=.
replace largeFundRaise = 1 if _n==1 & f.f_fundSize_USD==0 & f_fundSize_USD==.
replace largeFundRaise = 1 if _n==_N & f_fundSize_USD>l.f_fundSize_USD & f_fundSize_USD!=.
replace largeFundRaise = 1 if _n==_N & l.f_fundSize_USD==0 & f_fundSize_USD==.
keep if inrange(closeYear,2000,2022)
keep fm_id f_fundSize_USD closeYear fundRaise largeFundRaise
ren closeYear year
save fundRaising.dta, replace

use fundRaising.dta, clear
keep if largeFundRaise==1
gen fundraisingyear=year 
gen year1 = year-5
gen year2 = year+3
keep fm_id year1 year2 fundraisingyear
merge m:1 fm_id using "..\Data_preqin\\preqin_fund_mgr.dta", keepus(fm_country)
keep if _m==3
drop _m
gen i = _n
reshape long year, i(fm_id i) j(j)
tsset i year
tsfill
bysort i (year): carryforward fm_id fm_country fundraisingyear, replace
keep fm_id year fm_country fundraisingyear
duplicates drop
egen double ctry_yr = group(fm_country year)
drop fm_country
ren year snapshot_year
duplicates report snapshot_year fm_id
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", keepus(dict_esg2 logLength) // 
keep if _m==3
reghdfe dict_esg2 logLength, absorb(fm_id  snapshot_year) cluster(ctry_yr) resid(esgResid)

gen fund_event_year = fundraisingyear-snapshot_year
collapse (mean) esgResid , by(fund_event_year fm_id)
save fundRaising.dta, replace
}
//IPO Panel - for D-i-D
{
use  "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
gen public = cond(fm_listed=="YES",1,0)
gen yearIPO = year(IPODate)
drop if public==1 & (yearIPO==.|yearIPO<2000|yearIPO>2022)
save temp.dta, replace

keep fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep fm_id
duplicates drop
merge 1:m fm_id using temp.dta
keep if _m==3
drop _m
save temp.dta, replace

keep if public==1
keep fm_id fm_country
bysort fm_country: gen cntr = _N
keep fm_country cntr
duplicates drop
merge 1:m fm_country using temp.dta
keep if _m==3
drop if public==1
drop if missing(fm_total_AUM_USD)
bysort fm_country (fm_total_AUM_USD): keep if inrange(_n,_N-cntr,_N)
keep fm_id
merge 1:m fm_id using temp.dta
keep if _m==3|public==1
keep fm_id yearIPO fm_country public
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
drop _m
keep if inrange(snapshot_year,2000,2022)
gen postIPO = cond(snapshot_year>=yearIPO,1,0)
egen double ctry_yr = group(fm_country snapshot_year)
gen private = 1-public
label var postIPO "Post Public Listing (IPO)"
save IPO.dta, replace
}
//Fundraise Speed Panel
{
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_country
merge 1:m fm_id using "..\Data_preqin\\preqin_fund.dta"
keep if _m==3
keep fm_id f_id f_vintageInceptionYear f_finalCloseDate fm_country f_fundRaisingLaunchDate f_finalCloseSize_USD
gen closeYear = year(f_finalCloseDate)
save temp.dta, replace

use "..\Data_preqin\\LP_GP_map.dta", clear
collapse (max) anyPRILP = LPPRISignatory, by(fm_id f_id year)
gen anyPRILP_100 = anyPRILP*100
ren year closeYear
merge 1:1 fm_id f_id closeYear using temp.dta
drop if _m==1
drop _m

gen fundRaiseDuration = f_finalCloseDate - f_fundRaisingLaunchDate
gen approxLaunchDate = mdy(06,01,f_vintageInceptionYear)
gen approxFundRaiseDuration = f_finalCloseDate - approxLaunchDate
replace fundRaiseDuration = . if fundRaiseDuration<0 
sum approxFundRaiseDuration, d
replace approxFundRaiseDuration = 1 if approxFundRaiseDuration<180
replace approxFundRaiseDuration = 2 if inrange(approxFundRaiseDuration,180,365)
replace approxFundRaiseDuration = 3 if inrange(approxFundRaiseDuration,366,547)
replace approxFundRaiseDuration = 4 if inrange(approxFundRaiseDuration,548,730)
replace approxFundRaiseDuration = 5 if inrange(approxFundRaiseDuration,731,912)
replace approxFundRaiseDuration = 6 if approxFundRaiseDuration>912 & !missing(approxFundRaiseDuration)

gen USD_fundRaiseDuration = f_finalCloseSize_USD/fundRaiseDuration
gen USD_approxFundRaiseDuration = f_finalCloseSize_USD/approxFundRaiseDuration

collapse (mean) fundRaiseDuration approxFundRaiseDuration USD_* f_finalCloseSize_USD (max) anyPRILP, by(fm_id closeYear fm_country)
gen anyPRILP_100 = anyPRILP*100
ren closeYear snapshot_year
save temp.dta, replace

use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
bysort snapshot_year: egen esgQuartile = xtile(dict_esg2), nq(4)
xtset fm_id snapshot_year
gen esgQuartile_pre = l.esgQuartile
foreach var of varlist dict_esg2 logLength positive valuation {
	qui  gen `var'_r=exp(`var') - 1
	qui gen `var'_preAvg = (l3.`var'_r + l2.`var'_r + l.`var'_r)/3
	qui gen `var'_preAvg_ln=ln(1+`var'_preAvg) 
	qui gen `var'_pre3 = l3.`var' 
	qui gen `var'_pre = l.`var' 

}
keep fm_id snapshot_year logLength positive valuation  dict_esg2 *_pre* *_preAvg*
merge 1:1 fm_id snapshot_year using temp.dta
keep if _m==3
egen ctry_yr = group(fm_country snapshot_year)
drop _m

gen USD_approxFundRaiseDuration_log=ln(1+USD_approxFundRaiseDuration)
gen USD_fundRaiseDuration_log=ln(1+USD_fundRaiseDuration)
g fundRaiseDuration_log=ln(1 + fundRaiseDuration)
g approxFundRaiseDuration_log=ln(1 + approxFundRaiseDuration)

gen ln_raiseratio=ln(f_finalCloseSize_USD/fundRaiseDuration)
gen ln_raiseratio_approx=ln( f_finalCloseSize_USD/(approxFundRaiseDuration))
gen raiseratio_approx= f_finalCloseSize_USD/(approxFundRaiseDuration)
gen  raiseratio= f_finalCloseSize_USD/fundRaiseDuration 

ren dict_esg2_preAvg_ln dict_esg2_preAvg_lnESG

label var raiseratio_approx "USD Mn Raised/6 mo Fundraising"
label var ln_raiseratio_approx "Log. USD Mn Raised/6 mo Fundraising"
label var anyPRILP_100 "PRI Investor in Fundraise"
save fundRaiseResponse.dta, replace
}
//TRI Panel
{
use listOfBOGrowthDeals.dta, clear
keep if d_dealYear==d_firstDealYear
keep d_firmID d_investorID d_dealYear d_firstDealYear
save tri_analysis.dta, replace

//In the year of the deal a target firm can get investments from multiple GPs. In order to address this I take a simple mean of the ESG score
//of all GPs tagged to the portfolio firm in the year of the deal.
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
bysort snapshot_year: egen eQuartile = xtile(dict_e2), nq(4)
bysort snapshot_year: egen eQuartile_ihs = xtile(dict_e2_ihs), nq(4)
bysort snapshot_year: egen sQuartile = xtile(dict_s2), nq(4)
ren (fm_id snapshot_year) (d_investorID d_dealYear)
keep d_investorID d_dealYear dict_e2 eQuartile eQuartile_ihs sQuartile
merge 1:m d_investorID d_dealYear using tri_analysis.dta
keep if _m==3
drop _m
save tri_analysis.dta, replace

collapse (mean) dict_e2 eQuartile eQuartile_ihs sQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firmID d_firstDealYear using "..\Data_TRI\fileType1a_PreqinFirmLevel.dta"
drop if _m==1
replace d_firmID=. if _m==2
drop _m
replace dist_to_deal = . if d_firmID==.
save tri_analysis.dta, replace

//Dropping facilities that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort trifd: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000

//For each facility I map the E/ESG score and E/ESG quartile of the deal year, even in years where the facility did not have a match to a target firm.
foreach var of varlist dict_e2 eQuartile eQuartile_ihs sQuartile {
	bysort trifd: egen double t`var' = min(`var')
	drop `var'
	ren t`var' `var'
}
gen highEn = cond(eQuartile==4,1,cond(eQuartile==.,.,0))
gen highEn_ihs = cond(eQuartile_ihs==4,1,cond(eQuartile_ihs==.,.,0))
gen highS = cond(sQuartile==4,1,cond(sQuartile==.,.,0))

//recoding for control facilities
recode dict_e2 highEn highEn_ihs highS (.=0) if d_firmID==.

//Interaction terms.
gen t_4 = cond(dist_to_deal<=-4,1,0)
gen t_3 = cond(dist_to_deal==-3,1,0)
gen t_2 = cond(dist_to_deal==-2,1,0)
gen t_1 = cond(dist_to_deal==-1,1,0)
gen t0 = cond(dist_to_deal==0,1,0)
gen t1 = cond(dist_to_deal==1,1,0)
gen t2 = cond(dist_to_deal==2,1,0)
gen t3 = cond(dist_to_deal==3,1,0)
gen t4 = cond(dist_to_deal>=4 & dist_to_deal!=.,1,0)

gen interEDPost = postPeriod * highEn
gen interEDPost_ihs = postPeriod * highEn_ihs
gen interECPost = postPeriod * dict_e2
gen interSDPost = postPeriod * highS

label var dict_e2 "Log. Envir. Ratio\$_{t0}$"
label var highEn "High Envir. Discl.\$_{t0}$" 
label var highEn_ihs "IHS. High Envir. Quartile\$_{t0}$" 

label var postPeriod "Post Deal Period"
label var t_3 "Deal Year <=-3"
label var t_2 "Deal Year =-2"
label var t_1 "Deal Year =-1"
label var t0 "Deal Year =0"
label var t1 "Deal Year =1"
label var t2 "Deal Year =2"
label var t3 "Deal Year >=3"

label var interEDPost "High Envir. Discl.\$_{t0}$ * Post Deal Period"
label var interEDPost_ihs "IHS. High Envir. Discl.\$_{t0}$ * Post Deal Period"
label var interECPost "Log. Envir. Ratio\$_{t0}$ * Post Deal Period"

egen double industryYear = group(primarynaicscode reportingyear)
egen double stateYear = group(state reportingyear)
save tri_analysis.dta, replace

//Adding website size as a time-varying variable based on the PE firm at the time of the acquisition - to be used for robustness test
keep d_firmID d_firstDealYear reportingyear trifd
keep if d_firstDealYear==reportingyear
drop if missing(d_firmID)
drop reportingyear
duplicates drop
save temp.dta, replace

keep trifd
duplicates drop
merge 1:m trifd using tri_analysis.dta
keep if _m==3
keep trifd reportingyear
ren reportingyear d_firstDealYear
duplicates drop
merge 1:1 trifd d_firstDealYear using temp.dta
ren d_firstDealYear reportingyear
gen d_firstDealYear = reportingyear if _m==3
drop _m
bysort trifd (reportingyear): carryforward d_firmID d_firstDealYear, replace
gsort trifd -reportingyear
by trifd: carryforward d_firmID d_firstDealYear, replace
save temp.dta, replace

keep d_firmID d_firstDealYear reportingyear
duplicates drop
joinby d_firmID d_firstDealYear using listOfBOGrowthDeals.dta
keep reportingyear d_firmID d_firstDealYear d_investorID
ren (d_investorID reportingyear) (fm_id snapshot_year)
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
collapse (mean) length, by(d_firmID d_firstDealYear snapshot_year)
ren snapshot_year reportingyear
merge 1:m d_firmID d_firstDealYear reportingyear using temp.dta
keep if _m==3
keep trifd reportingyear length
merge 1:m trifd reportingyear using tri_analysis.dta
gen logLength = log(length/1000000)
replace logLength = log(1/1000000) if _m!=3 & d_firmID==.
drop _m length
label var logLength "Log. Website Size (in MB)"
save tri_analysis.dta, replace

//Adding in the variables for stacked Cengiz regressions
use tri_analysis.dta, clear
gen firstTreatYear=d_firstDealYear
bysort trifd: egen neverTreated = min(d_firstDealYear)
replace neverTreated = cond(neverTreated==.,1,0)
egen double trifd_num = group(trifd)
save tri_analysis.dta, replace
}
//Trucost Panel 
{
use listOfBOGrowthDeals.dta, clear
keep if d_dealYear==d_firstDealYear
keep d_firmID d_investorID d_dealYear d_firstDealYear
save trucost_analysis.dta, replace

//In the year of the deal a target firm can get investments from multiple GPs. In order to address this I take a simple mean of the ESG score
//of all GPs tagged to the portfolio firm in the year of the deal.
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
bysort snapshot_year: egen eQuartile = xtile(dict_e2), nq(4)
bysort snapshot_year: egen eQuartile_ihs = xtile(dict_e2_ihs), nq(4)
ren (fm_id snapshot_year) (d_investorID d_dealYear)
keep d_investorID d_dealYear dict_e2 eQuartile eQuartile_ihs
merge 1:m d_investorID d_dealYear using trucost_analysis.dta
keep if _m==3
drop _m
save trucost_analysis.dta, replace

collapse (mean) dict_e2 eQuartile eQuartile_ihs, by(d_firmID d_firstDealYear)
merge 1:m d_firmID d_firstDealYear using "..\Data_trucost\trucost.dta"
drop if _m==1
replace d_firmID=. if _m==2
drop _m
save trucost_analysis.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort institutionid: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000

gen highEn = cond(eQuartile==4,1,cond(eQuartile==.,.,0))
gen highEn_ihs = cond(eQuartile_ihs==4,1,cond(eQuartile_ihs==.,.,0))

//recoding for control facilities
recode dict_e2 highEn highEn_ihs (.=0) if d_firmID==.

//Interaction terms.
gen t_3 = cond(dist_to_deal<=-3,1,0)
gen t_2 = cond(dist_to_deal==-2,1,0)
gen t_1 = cond(dist_to_deal==-1,1,0)
gen t0 = cond(dist_to_deal==0,1,0)
gen t1 = cond(dist_to_deal==1,1,0)
gen t2 = cond(dist_to_deal==2,1,0)
gen t3 = cond(dist_to_deal>=3 & dist_to_deal!=.,1,0)

gen interEDPost = postPeriod * highEn
gen interEDPost_ihs = postPeriod * highEn_ihs
gen interECPost = postPeriod * dict_e2

label var dict_e2 "Log. Envir. Ratio\$_{t0}$"
label var highEn "High Envir. Quartile\$_{t0}$" 
label var highEn_ihs "IHS. High Envir. Quartile\$_{t0}$" 

label var postPeriod "Post Deal Period"
label var t_3 "Deal Year <=-3"
label var t_2 "Deal Year =-2"
label var t_1 "Deal Year =-1"
label var t0 "Deal Year =0"
label var t1 "Deal Year =1"
label var t2 "Deal Year =2"
label var t3 "Deal Year >=3"

label var interEDPost "High Envir. Discl.\$_{t0}$ * Post Deal Period"
label var interEDPost_ihs "IHS. High Envir. Discl.\$_{t0}$ * Post Deal Period"
label var interECPost "Log. Envir. Ratio\$_{t0}$ * Post Deal Period"

save trucost_analysis.dta, replace

//Adding website size as a time-varying variable based on the PE firm at the time of the acquisition - to be used for robustness test
use trucost_analysis.dta, clear
keep d_firmID d_firstDealYear institutionid fiscalyear
keep if d_firstDealYear==fiscalyear
drop if missing(d_firmID)
drop fiscalyear
duplicates drop
save temp.dta, replace

keep institutionid
duplicates drop
merge 1:m institutionid using trucost_analysis.dta
keep if _m==3
keep institutionid fiscalyear
duplicates drop
bysort institutionid (fiscalyear): gen fiscalyear1 = fiscalyear[1]
bysort institutionid (fiscalyear): gen fiscalyear2 = fiscalyear[_N]
keep institutionid fiscalyear1 fiscalyear2
duplicates drop

merge 1:m institutionid using temp.dta
drop _m
gen id = _n
reshape long fiscalyear, i(id institutionid d_firmID d_firstDealYear) j(j)
drop j
tsset id fiscalyear
tsfill
bysort id (fiscalyear): carryforward institutionid d_firmID d_firstDealYear, replace
drop id
save temp.dta, replace

keep d_firmID d_firstDealYear fiscalyear
duplicates drop
joinby d_firmID d_firstDealYear using listOfBOGrowthDeals.dta
keep fiscalyear d_firmID d_firstDealYear d_investorID
ren (d_investorID fiscalyear) (fm_id snapshot_year)
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
collapse (mean) length, by(d_firmID d_firstDealYear snapshot_year)
ren snapshot_year fiscalyear
merge 1:m d_firmID d_firstDealYear fiscalyear using temp.dta
keep if _m==3
drop _m
merge 1:m d_firmID d_firstDealYear institutionid fiscalyear using trucost_analysis.dta
drop if _m==1
gen logLength = log(length/1000000)
replace logLength = log(1/1000000) if _m!=3 & d_firmID==.
drop _m length
label var logLength "Log. Website Size (in MB)"
save trucost_analysis.dta, replace

//Adding in the variables for stacked Cengiz regressions
use trucost_analysis.dta, clear
gen firstTreatYear=d_firstDealYear
bysort institutionid: egen neverTreated = min(d_firstDealYear)
replace neverTreated = cond(neverTreated==.,1,0)
save trucost_analysis.dta, replace
}
//Reprisk Panel
{
use listOfBOGrowthDeals.dta, clear
keep if d_dealYear==d_firstDealYear
keep d_firmID d_investorID d_dealYear d_firstDealYear
save reprisk_analysis.dta, replace

//In the year of the deal a target firm can get investments from multiple GPs. In order to address this I take a simple mean of the ESG score
//of all GPs tagged to the portfolio firm in the year of the deal.
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
bysort snapshot_year: egen esgQuartile = xtile(dict_esg2), nq(4)
ren (fm_id snapshot_year) (d_investorID d_dealYear)
keep d_investorID d_dealYear esgQuartile
merge 1:m d_investorID d_dealYear using reprisk_analysis.dta
keep if _m==3
drop _m
save reprisk_analysis.dta, replace

collapse (mean) esgQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firmID d_firstDealYear using "..\Data_Reprisk_ESG\reprisk.dta"
drop if _m==1
replace d_firmID=. if _m==2
drop _m
save reprisk_analysis.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort reprisk_id: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000

gen highESG = cond(esgQuartile==4,1,cond(esgQuartile==.,.,0))

//recoding for control facilities
recode highESG (.=0) if d_firmID==.

gen interESGDPost = postPeriod * highESG

label var highESG "High ESG Discl.\$_{t0}$" 
label var postPeriod "Post Deal Period"
label var interESGDPost "High ESG Discl.\$_{t0}$ * Post Deal Period"
save reprisk_analysis.dta, replace

//Adding website size as a time-varying variable based on the PE firm at the time of the acquisition - to be used for robustness test
use reprisk_analysis.dta, clear
keep d_firmID d_firstDealYear reprisk_id year
keep if d_firstDealYear==year
drop if missing(d_firmID)
drop year
duplicates drop
save temp.dta, replace

keep reprisk_id
duplicates drop
merge 1:m reprisk_id using reprisk_analysis.dta
keep if _m==3
keep reprisk_id year
duplicates drop
bysort reprisk_id (year): gen year1 = year[1]
bysort reprisk_id (year): gen year2 = year[_N]
keep reprisk_id year1 year2
duplicates drop

merge 1:m reprisk_id using temp.dta
drop _m
gen id = _n
reshape long year, i(id reprisk_id d_firmID d_firstDealYear) j(j)
drop j
tsset id year
tsfill
bysort id (year): carryforward reprisk_id d_firmID d_firstDealYear, replace
drop id
save temp.dta, replace

keep d_firmID d_firstDealYear year
duplicates drop
joinby d_firmID d_firstDealYear using listOfBOGrowthDeals.dta
keep year d_firmID d_firstDealYear d_investorID
ren (d_investorID year) (fm_id snapshot_year)
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
collapse (mean) length, by(d_firmID d_firstDealYear snapshot_year)
ren snapshot_year year
merge 1:m d_firmID d_firstDealYear year using temp.dta
keep if _m==3
drop _m
merge 1:m d_firmID d_firstDealYear reprisk_id year using reprisk_analysis.dta
drop if _m==1
gen logLength = log(length/1000000)
replace logLength = log(1/1000000) if _m!=3 & d_firmID==.
drop _m length
label var logLength "Log. Website Size (in MB)"
save reprisk_analysis.dta, replace

//Adding variables for stacked Cengiz regressions
use reprisk_analysis.dta, clear
gen firstTreatYear=d_firstDealYear
bysort reprisk_id: egen neverTreated = min(d_firstDealYear)
replace neverTreated = cond(neverTreated==.,1,0)
save reprisk_analysis.dta, replace
}
//OSHA Panel 
{
use listOfBOGrowthDeals.dta, clear
keep if d_dealYear==d_firstDealYear
keep d_firmID d_investorID d_dealYear d_firstDealYear
save osha_analysis.dta, replace

//In the year of the deal a target firm can get investments from multiple GPs. In order to address this I take a simple mean of the ESG score
//of all GPs tagged to the portfolio firm in the year of the deal.
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
bysort snapshot_year: egen esgQuartile = xtile(dict_esg2), nq(4)
bysort snapshot_year: egen eQuartile = xtile(dict_e2), nq(4)
bysort snapshot_year: egen sQuartile = xtile(dict_s2), nq(4)
bysort snapshot_year: egen gQuartile = xtile(dict_g2), nq(4)
ren (fm_id snapshot_year) (d_investorID d_dealYear)
keep d_investorID d_dealYear esgQuartile eQuartile sQuartile gQuartile 
merge 1:m d_investorID d_dealYear using osha_analysis.dta
keep if _m==3
drop _m
save osha_analysis.dta, replace

**Inspections Panel - All
use osha_analysis.dta, clear
collapse (mean) esgQuartile eQuartile sQuartile gQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firstDealYear d_firmID using "..\Data_OSHA\oshaPanel_inspections_final.dta"
drop if _m==1
drop _m
save oshaInspections_analysis.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort OSHAID: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000
save oshaInspections_analysis.dta, replace

gen highESG = cond(esgQuartile==4,1,0)
gen highE = cond(eQuartile==4,1,0)
gen highS = cond(sQuartile==4,1,0)
gen highG = cond(gQuartile==4,1,0)

gen interESGDPost = postPeriod * highESG
gen interEDPost = postPeriod * highE
gen interSDPost = postPeriod * highS
gen interGDPost = postPeriod * highG

label var highS "High Social Discl.\$_{t0}$" 
label var postPeriod "Post Deal Period"
label var interSDPost "High Social Discl.\$_{t0}$ * Post Deal Period"
save oshaInspections_analysis.dta, replace

**Inspections Panel - Planned
use osha_analysis.dta, clear
collapse (mean) esgQuartile eQuartile sQuartile gQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firstDealYear d_firmID using "..\Data_OSHA\oshaPanel_inspections_finalPlanned.dta"
drop if _m==1
drop _m
save oshaInspections_analysisPlanned.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort OSHAID: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000
save oshaInspections_analysisPlanned.dta, replace

gen highESG = cond(esgQuartile==4,1,0)
gen highE = cond(eQuartile==4,1,0)
gen highS = cond(sQuartile==4,1,0)
gen highG = cond(gQuartile==4,1,0)

gen interESGDPost = postPeriod * highESG
gen interEDPost = postPeriod * highE
gen interSDPost = postPeriod * highS
gen interGDPost = postPeriod * highG

label var highS "High Social Discl.\$_{t0}$" 
label var postPeriod "Post Deal Period"
label var interSDPost "High Social Discl.\$_{t0}$ * Post Deal Period"
save oshaInspections_analysisPlanned.dta, replace

**Inspections Panel - Complaints
use osha_analysis.dta, clear
collapse (mean) esgQuartile eQuartile sQuartile gQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firstDealYear d_firmID using "..\Data_OSHA\oshaPanel_inspections_finalComplaint.dta"
drop if _m==1
drop _m
save oshaInspections_analysisComplaint.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort OSHAID: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000
save oshaInspections_analysisComplaint.dta, replace

gen highESG = cond(esgQuartile==4,1,0)
gen highE = cond(eQuartile==4,1,0)
gen highS = cond(sQuartile==4,1,0)
gen highG = cond(gQuartile==4,1,0)

gen interESGDPost = postPeriod * highESG
gen interEDPost = postPeriod * highE
gen interSDPost = postPeriod * highS
gen interGDPost = postPeriod * highG

label var highS "High Social Discl.\$_{t0}$" 
label var postPeriod "Post Deal Period"
label var interSDPost "High Social Discl.\$_{t0}$ * Post Deal Period"
save oshaInspections_analysisComplaint.dta, replace

//Adding website size as a time-varying variable based on the PE firm at the time of the acquisition - to be used for robustness test
use oshaInspections_analysisComplaint.dta, clear
keep d_firmID d_firstDealYear OSHAID yearInspection
keep if d_firstDealYear==yearInspection
drop if missing(d_firmID)
drop yearInspection
duplicates drop
save temp.dta, replace

keep OSHAID
duplicates drop
merge 1:m OSHAID using oshaInspections_analysisComplaint.dta
keep if _m==3
keep OSHAID yearInspection
duplicates drop
bysort OSHAID (yearInspection): gen yearInspection1 = yearInspection[1]
bysort OSHAID (yearInspection): gen yearInspection2 = yearInspection[_N]
keep OSHAID yearInspection1 yearInspection2
duplicates drop

merge 1:m OSHAID using temp.dta
drop _m
gen id = _n
reshape long yearInspection, i(id OSHAID d_firmID d_firstDealYear) j(j)
drop j
tsset id yearInspection
tsfill
bysort id (yearInspection): carryforward OSHAID d_firmID d_firstDealYear, replace
drop id
save temp.dta, replace

keep d_firmID d_firstDealYear yearInspection
duplicates drop
joinby d_firmID d_firstDealYear using listOfBOGrowthDeals.dta
keep yearInspection d_firmID d_firstDealYear d_investorID
ren (d_investorID yearInspection) (fm_id snapshot_year)
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
collapse (mean) length, by(d_firmID d_firstDealYear snapshot_year)
ren snapshot_year yearInspection
merge 1:m d_firmID d_firstDealYear yearInspection using temp.dta
keep if _m==3
drop _m
merge 1:m d_firmID d_firstDealYear OSHAID yearInspection using oshaInspections_analysisComplaint.dta
drop if _m==1
gen logLength = log(length/1000000)
replace logLength = log(1/1000000) if _m!=3 & d_firmID==.
drop _m length
label var logLength "Log. Website Size (in MB)"
save oshaInspections_analysisComplaint.dta, replace

**Violations Panel
use osha_analysis.dta, clear
collapse (mean) esgQuartile eQuartile sQuartile gQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firstDealYear d_firmID using "..\Data_OSHA\oshaPanel_violations_final.dta"
drop if _m==1
drop _m
save oshaViolations_analysis.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort OSHAID: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000
save oshaViolations_analysis.dta, replace

gen highESG = cond(esgQuartile==4,1,0)
gen highE = cond(eQuartile==4,1,0)
gen highS = cond(sQuartile==4,1,0)
gen highG = cond(gQuartile==4,1,0)

gen interESGDPost = postPeriod * highESG
gen interEDPost = postPeriod * highE
gen interSDPost = postPeriod * highS
gen interGDPost = postPeriod * highG

label var highS "High Social Discl.\$_{t0}$" 
label var postPeriod "Post Deal Period"
label var interSDPost "High Social Discl.\$_{t0}$ * Post Deal Period"
save oshaViolations_analysis.dta, replace

**Accidents Panel
use osha_analysis.dta, clear
collapse (mean) esgQuartile eQuartile sQuartile gQuartile, by(d_firmID d_firstDealYear)
merge 1:m d_firstDealYear d_firmID using "..\Data_OSHA\oshaPanel_accidents_final.dta"
drop if _m==1
drop _m
save oshaAccidents_analysis.dta, replace

//Dropping firms that record their first deal year prior to 2000, since we don't have ESG data prior to 2000.
bysort OSHAID: egen min_firstDealYear = min(d_firstDealYear)
drop if min_firstDealYear<2000
save oshaAccidents_analysis.dta, replace

gen highESG = cond(esgQuartile==4,1,0)
gen highE = cond(eQuartile==4,1,0)
gen highS = cond(sQuartile==4,1,0)
gen highG = cond(gQuartile==4,1,0)

gen interESGDPost = postPeriod * highESG
gen interEDPost = postPeriod * highE
gen interSDPost = postPeriod * highS
gen interGDPost = postPeriod * highG

label var highS "High Social Discl.\$_{t0}$" 
label var postPeriod "Post Deal Period"
label var interSDPost "High Social Discl.\$_{t0}$ * Post Deal Period"
save oshaAccidents_analysis.dta, replace
}
//Addition to LP Panel - based on PE firm availability in TRI, Trucost, OSHA and Reprisk 
{
use tri_analysis.dta, clear
keep d_firmID d_firstDealYear
drop if missing(d_firmID)|missing(d_firstDealYear)
duplicates drop
merge 1:m d_firmID d_firstDealYear using listOfBOGrowthDeals.dta
drop if _m==1
gen tri_sample = cond(_m==3,1,0)
drop _m
save temp.dta, replace

use trucost_analysis.dta, clear
keep d_firmID d_firstDealYear
drop if missing(d_firmID)|missing(d_firstDealYear)
duplicates drop
merge 1:m d_firmID d_firstDealYear using temp.dta
drop if _m==1
gen trucost_sample = cond(_m==3,1,0)
drop _m
save temp.dta, replace

use oshaInspections_analysisComplaint.dta, clear
keep d_firmID d_firstDealYear
drop if missing(d_firmID)|missing(d_firstDealYear)
duplicates drop
merge 1:m d_firmID d_firstDealYear using temp.dta
drop if _m==1
gen osha_sample = cond(_m==3,1,0)
drop _m
save temp.dta, replace

use reprisk_analysis.dta, clear
keep d_firmID d_firstDealYear
drop if missing(d_firmID)|missing(d_firstDealYear)
duplicates drop
merge 1:m d_firmID d_firstDealYear using temp.dta
drop if _m==1
gen reprisk_sample = cond(_m==3,1,0)
drop _m
save temp.dta, replace

keep d_investorID tri_sample trucost_sample osha_sample reprisk_sample
foreach var of varlist tri_sample trucost_sample osha_sample reprisk_sample {
	bysort d_investorID: egen t_`var' = max(`var')
	drop `var'
	ren t_`var' `var'
}
duplicates drop
gen anyOutcomeSample = cond(tri_sample==1|trucost_sample==1|osha_sample==1|reprisk_sample==1,1,0)
gen allOutcomeSample = cond(tri_sample==1 & trucost_sample==1 & osha_sample==1 & reprisk_sample==1,1,0)

ren d_investorID fm_id
merge 1:m fm_id using LPPRI.dta
drop if _m==1
drop _m

order tri_sample trucost_sample osha_sample reprisk_sample anyOutcomeSample allOutcomeSample, a(neverTreated)
sort fm_id year
save LPPRI.dta, replace
}
********************************************************************************
*********************************MAIN TABLES************************************
********************************************************************************
**Table 1: Sample Selection & Bias Tests
{
**Sample Selection	
//Full Sample
use "..\Data_preqin\\preqin_fund_mgrRaw.dta", clear
drop if missing(fm_website)|missing(fm_country)
distinct fm_website
local totalWebsites = `r(ndistinct)'
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
distinct fm_website
local englishWebsites = `r(ndistinct)'

//Firms with either Buyout or Growth as main firm strategy.
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
distinct fm_id
local PEStrat = `r(ndistinct)'

//PE Firms with website data on Wayback
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id 
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
distinct fm_id
local waybackWebsites = `r(ndistinct)'

//Firms with BO deal data available AND with either Buyout or Growth as main firm strategy.
use listOfBOGrowthDeals.dta, clear
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
distinct fm_id
local BOnPEStrat = `r(ndistinct)'

clear all 
gen v1 = ""
gen N = . 
set obs 5
replace v1 = "Unique PE Firms in Preqin with website & domicile information" if _n==1
replace v1 = "English language websites with Alexa rank > 10,000" if _n==2
replace v1 = "Unique PE Firms with BO/Growth strategy" if _n==3
replace v1 = "Unique PE Firms with available website date" if _n==4
replace v1 = "Unique PE Firms with BuyOut deal data" if _n==5
replace N = `totalWebsites' if _n==1
replace N = `englishWebsites' if _n==2
replace N = `PEStrat' if _n==3
replace N = `waybackWebsites' if _n==4
replace N = `BOnPEStrat' if _n==5
save sampleSelect.dta, replace

export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_sampleSelect", replace) first(var)
erase sampleSelect.dta

**Bias Tests
****Comparison on Firm characteristics
//Only PE Firms
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_total_staff fm_total_AUM_USD no_of_geographies no_of_industries
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD no_of_geographies no_of_industries, statistics(count mean var) columns(statistics) 
estout using ".\ta_fullPE.txt", cells("count(l(N_full) f(%12.0f)) mean(l(Mean_full) f(%12.4f)) variance(l(Var_full) f(%12.4f))") label replace

//PE Firms with Available Website Data
eststo clear
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
keep fm_id
duplicates drop
merge 1:m fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_total_staff fm_total_AUM_USD no_of_geographies no_of_industries
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD no_of_geographies no_of_industries, statistics(count mean var) columns(statistics) 
estout using ".\ta_PEwWebsites.txt", cells("count(l(N_allWeb) f(%12.0f)) mean(l(Mean_allWeb) f(%12.4f)) variance(l(Var_allWeb) f(%12.4f))") label replace

//Firms with BO deal data AND main firm strategy is Buyout/Growth AND available website data
use listOfBOGrowthDeals.dta, clear
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep fm_id
duplicates drop
merge 1:1 fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_total_staff fm_total_AUM_USD no_of_geographies no_of_industries
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD no_of_geographies no_of_industries, statistics(count mean var) columns(statistics) 
estout using ".\ta_BOstrat.txt", cells("count(l(N_BOstrat) f(%12.0f)) mean(l(Mean_BOstrat) f(%12.4f)) variance(l(Var_BOstrat) f(%12.4f))") label replace

//Combining all samples
import delimited using ".\ta_fullPE.txt", clear
foreach var of varlist v2-v4 {
	local name = `var'[2]
	ren `var' `name'
}
drop in 1/2
destring N_* Mean_* Var_*, replace
gen id = _n
save temp.dta, replace

local items = `" PEwWebsites BOstrat "'
foreach i of local items {
	import delimited using ".\ta_`i'.txt", clear
	foreach var of varlist v2-v4 {
		local name = `var'[2]
		ren `var' `name'
	}
	drop in 1/2
	destring N_* Mean_* Var_*, replace

	gen id = _n
	merge 1:1 id using temp.dta
	drop _m
	save temp.dta, replace
}
drop id
order v1 N_full Mean_full Var_full N_allWeb Mean_allWeb Var_allWeb N_BOstrat Mean_BOstrat Var_BOstrat N_BO Mean_BO Var_BO

export excel using "..\..\Output\\R2_Results.xlsx", sheet("taRaw_biasTests", replace) first(var)
erase temp.dta
}
**Table 2: Summary Statistics
{
//ESG variables
clear all
gen Variable = ""
gen N = .
gen Mean = .
gen SD = .
gen P5 = .
gen Median = .
gen P95 = .
save summaryStat.dta, replace

use listOfBOGrowthDeals.dta, clear
keep d_investorID
duplicates drop
ren d_investorID fm_id 
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
foreach var of varlist dict_esg2 dict_e2 dict_s2 dict_g2 positive valuation logLength logWordCount {
	use listOfBOGrowthDeals.dta, clear
	keep d_investorID
	duplicates drop
	ren d_investorID fm_id 
	merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
	keep if _m==3
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//World Bank Controls
use ESGPanel.dta, clear
foreach var of varlist log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament {
	use ESGPanel.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab' (World Bank)"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//LP Sample
use LPPRI.dta, clear
foreach var of varlist PRIInvestorPresent logPRIInvestors logWgtPRIInvestors {
	use LPPRI.dta, clear
	label var PRIInvestorPresent "Post UN-PRI Investor Present"
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//Mandat Sample
use mandat.dta, clear
foreach var of varlist regExposure2 {
	use mandat.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//GPPRI Sample
use ESGPanel.dta, clear
foreach var of varlist dummy_GPPRI {
	use mandat.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//IPO Sample
use IPO.dta, clear
foreach var of varlist postIPO {
	use IPO.dta, clear
	label var postIPO "Post IPO Listing"
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//Fundraising Response sample
use fundRaiseResponse.dta, clear
foreach var of varlist raiseratio_approx ln_raiseratio_approx anyPRILP_100 {
	use fundRaiseResponse.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}


//TRI Sample
use tri_analysis.dta, clear
local list = `" "All Chemicals" "CERCL Act" "Clean Air Act" "Safe Drinking Water Act" "Hazardous Air Pollutant" "Less Harmful Chemicals" "'
foreach l of local list {
	use tri_analysis.dta, clear
	keep if aggregationType=="`l'"
	local Variable = "`l'"
	summ Lnv218_TotalOnsite, detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//Trucost Sample
use trucost_analysis.dta, clear
foreach var of varlist log_s1tot log_s2tot log_s3totup {
	use trucost_analysis.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//Reprisk Sample
use reprisk_analysis.dta, clear
foreach var of varlist current_rri rating {
	use reprisk_analysis.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

//OSHA Sample
use oshaInspections_analysisPlanned.dta, clear
foreach var of varlist countInspectionsPlanned {
	use oshaInspections_analysisPlanned.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

use oshaInspections_analysisComplaint.dta, clear
foreach var of varlist countInspectionsComplaint {
	use oshaInspections_analysisComplaint.dta, clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

use oshaViolations_analysis.dta, clear
foreach var of varlist violation {
	use oshaViolations_analysis, clear
	label var violation "Violations (Count)"
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use summaryStat.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save summaryStat.dta, replace
}

use summaryStat.dta, clear
format Mean SD P5 Median P95 %3.2f
format N %10.0fc
export delimited using ".\ta.txt", replace dataf
import delimited using ".\ta.txt", clear varn(1) stringc(_all) case(preserve)
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_summaryStat", replace) first(var)
}
**Table 3: Impact of LP UNPRI signatories on PE disclosures
{
//Panel A
use LPPRI.dta, clear
local controls = `" logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament "'

xtset fm_id year

eststo clear
reghdfe dict_esg2 PRIInvestorPresent if forReg==1, absorb(fm_id year) cluster(ctry_yr) //16,632 - enter this manually in the table
eststo P1: stackedev dict_esg2 PRIInvestorPresent if forReg==1, cohort(firstTreatYear) time(year) never_treat(neverTreated) unit_fe(fm_id) clust_unit(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace

use LPPRI.dta, clear
eststo P2: reghdfe dict_esg2 logPRIInvestors if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace
eststo P3: reghdfe dict_esg2 logWgtPRIInvestors logWgtTotalInvestors `controls' if forReg==1, absorb(fm_id wordDecileYear) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "No", replace
estadd local quintyr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe year_fe quintyr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "PE Firm FE" "Year FE" "Size Group-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_investorsPRI_panelA", replace)

//Panel B
use LPPRI.dta, clear
eststo clear
reghdfe dict_e2 PRIInvestorPresent if forReg==1, absorb(fm_id year) cluster(ctry_yr) //only for N (observations) 16,628 - enter this manually in the table
eststo P4: stackedev dict_e2 PRIInvestorPresent if forReg==1, cohort(firstTreatYear) time(year) never_treat(neverTreated) unit_fe(fm_id) clust_unit(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
use LPPRI.dta, clear
reghdfe dict_s2 PRIInvestorPresent if forReg==1, absorb(fm_id year) cluster(ctry_yr) //16,678 - enter this manually in the table
eststo P5: stackedev dict_s2 PRIInvestorPresent if forReg==1, cohort(firstTreatYear) time(year) never_treat(neverTreated) unit_fe(fm_id) clust_unit(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
use LPPRI.dta, clear
reghdfe dict_g2 PRIInvestorPresent if forReg==1, absorb(fm_id year) cluster(ctry_yr) //16,548 - enter this manually in the table
eststo P6: stackedev dict_g2 PRIInvestorPresent if forReg==1, cohort(firstTreatYear) time(year) never_treat(neverTreated) unit_fe(fm_id) clust_unit(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe year_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "PE Firm FE" "Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_investorsPRI_panelB", replace)
}
**Table 4: ESG Mandatory Disclosures
{
//Panel A
use mandat.dta, clear
local controls = `" logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament "'

eststo clear
//main Regressions
eststo P1: reghdfe dict_esg2 regExposure2 if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local size_yr "No", replace
eststo P2: reghdfe dict_esg2 regExposure2 `controls' if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local size_yr "No", replace
eststo P3: reghdfe dict_esg2 regExposure2 `controls' if forReg==1, absorb(fm_id wordDecileYear) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "No", replace
estadd local size_yr "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe year_fe size_yr, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "PE Firm FE" "Year FE" "Size Group-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_MandatA", replace)

//Panel B
use mandat.dta, clear

eststo clear
eststo P1: reghdfe dict_e2 regExposureE2 if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local size_yr "No", replace
eststo P2: reghdfe dict_s2 regExposureS2 if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local size_yr "No", replace
eststo P3: reghdfe dict_g2 regExposureG2 if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local size_yr "No", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe year_fe size_yr, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "PE Firm FE" "Year FE" "Size Group-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_MandatB", replace)
}
**Table 5: FundRaising Responses
{
use fundRaiseResponse.dta, clear

loc controls ="*_pre3"

eststo clear
eststo P1: reghdfe raiseratio_approx dict_esg2  `controls', absorb(snapshot_year) cluster(ctry_yr)
estadd local year_fe "Yes", replace
estadd local ctryyear_fe "No", replace

eststo P2: reghdfe ln_raiseratio_approx  dict_esg2  `controls', absorb(ctry_yr ) cluster(ctry_yr)
estadd local year_fe "Yes", replace
estadd local ctryyear_fe "Yes", replace
loc controls ="*_pre3"
eststo P3: reghdfe anyPRILP_100 dict_esg2 `controls',  absorb(snapshot_year) cluster(ctry_yr)
estadd local year_fe "Yes", replace
estadd local ctryyear_fe "No", replace
sum anyPRILP_100 if e(sample), d

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a year_fe ctryyear_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Fundraise Year FE" "Country * Fundraise Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_fundRaise", replace)
}
**Table 5a/b: TRI Environmental performance of portfolio firms' facilities & PE E Score--
{
**High vs. Low E-PE firms emissions post deal.
use tri_analysis.dta, clear

eststo clear
eststo P1: reghdfe Lnv218_TotalOnsite interEDPost postPeriod B_Lnv218_IndYr if aggregationType=="All Chemicals", absorb(trifd countyYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "No", replace
eststo P2: reghdfe Lnv218_TotalOnsite interEDPost postPeriod if aggregationType=="All Chemicals", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace
eststo P3: reghdfe Lnv218_TotalOnsite interECPost postPeriod if aggregationType=="All Chemicals", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a plant_fe countyYr_fe indYr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Facility FE" "County-Year FE" "Industry-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_TRIA", replace)

**Distinction between bad and not-bad chemical releases.
use tri_analysis.dta, clear

eststo clear
eststo P1: reghdfe Lnv218_TotalOnsite interEDPost postPeriod if aggregationType=="CERCL Act", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace
eststo P2: reghdfe Lnv218_TotalOnsite interEDPost postPeriod if aggregationType=="Clean Air Act", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace
eststo P3: reghdfe Lnv218_TotalOnsite interEDPost postPeriod if aggregationType=="Safe Drinking Water Act", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace
eststo P4: reghdfe Lnv218_TotalOnsite interEDPost postPeriod if aggregationType=="Hazardous Air Pollutant", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace
eststo P5: reghdfe Lnv218_TotalOnsite interEDPost postPeriod if aggregationType=="Less Harmful Chemicals", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace
estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a plant_fe countyYr_fe indYr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Facility FE" "County-Year FE" "Industry-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_TRIB", replace)

**High vs. Low S-PE firms emissions post deal (Untabulated).
use tri_analysis.dta, clear

eststo clear
eststo P1: reghdfe Lnv218_TotalOnsite interSDPost postPeriod B_Lnv218_IndYr if aggregationType=="All Chemicals", absorb(trifd countyYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "No", replace
eststo P2: reghdfe Lnv218_TotalOnsite interSDPost postPeriod if aggregationType=="All Chemicals", absorb(trifd countyYear industryYear) cluster(stateYear)
estadd local plant_fe "Yes", replace
estadd local countyYr_fe "Yes", replace
estadd local indYr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a plant_fe countyYr_fe indYr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Facility FE" "County-Year FE" "Industry-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("UntabulatedtaRaw_TRI", replace)
}
**Table 6c: Trucost Environmental performance of portfolio firms and PE E Score
{
use trucost_analysis.dta, clear
eststo clear
eststo P1: reghdfe log_s1tot interEDPost postPeriod, absorb(institutionid countryYear) cluster(countryYear)
estadd local firm_fe "Yes", replace
estadd local ctryr_fe "Yes", replace
eststo P2: reghdfe log_s2tot interEDPost postPeriod, absorb(institutionid countryYear) cluster(countryYear)
estadd local firm_fe "Yes", replace
estadd local ctryr_fe "Yes", replace
eststo P3: reghdfe log_s3totup interEDPost postPeriod, absorb(institutionid countryYear) cluster(countryYear)
estadd local firm_fe "Yes", replace
estadd local ctryr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe ctryr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Portfolio Company FE" "Country-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_trucost", replace)
}
**Table 7: OSHA social performance of portfolio firms and PE S Score
{
//Using S- and Poisson regressions
use oshaInspections_analysisComplaint.dta, clear
eststo clear
eststo P1: ppmlhdfe countInspectionsComplaint interSDPost postPeriod, absorb(OSHAID stateYear) cluster(stateYear)
estadd local firm_fe "Yes", replace
estadd local stateyr_fe "Yes", replace

use oshaInspections_analysisPlanned.dta, clear
eststo P2: ppmlhdfe countInspectionsPlanned interSDPost postPeriod, absorb(OSHAID stateYear) cluster(stateYear)
estadd local firm_fe "Yes", replace
estadd local stateyr_fe "Yes", replace

use oshaViolations_analysis.dta, clear
eststo P3: ppmlhdfe violation interSDPost postPeriod, absorb(OSHAID stateYear) cluster(stateYear)
estadd local firm_fe "Yes", replace
estadd local stateyr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_p firm_fe stateyr_fe, fmt(%9.0f %9.3f) labels("Observations" "Pseudo. R2" "Facility FE" "State-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_OSHAA", replace)
}
**Table 8: Reprisk ESG reputation risk of portfolio firms and PE ESG Score
{
use reprisk_analysis.dta, clear

eststo clear
eststo P1: reghdfe current_rri interESGDPost postPeriod, absorb(reprisk_id countryYear) cluster(countryYear)
estadd local firm_fe "Yes", replace
estadd local ctryr_fe "Yes", replace
eststo P2: reghdfe rating interESGDPost postPeriod, absorb(reprisk_id countryYear) cluster(countryYear)
estadd local firm_fe "Yes", replace
estadd local ctryr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe ctryr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Portfolio Company FE" "Country-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("taRaw_reprisk", replace)
}
********************************************************************************
*********************************MAIN FIGURES************************************
*******************************************************************************
graph set window fontface "Times New Roman"
**Figure 1: IPOs vs. PE funds raised and LP repeat investors --
{
//Panel A
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep fm_id fm_country
merge 1:m fm_id using "..\Data_preqin\\preqin_fund.dta"
keep if _m==3
keep if inlist(f_assetClass,"PRIVATE EQUITY","VENTURE CAPITAL")
drop if inlist(f_strategy,"FUND OF FUNDS","CO-INVESTMENT","SECONDARIES","DIRECT SECONDARIES","CO-INVESTMENT MULTI-MANAGER","PIPE")
drop if missing(f_vintageInceptionYear)
keep fm_id f_id f_vintageInceptionYear f_fundSize_USD fm_country
collapse (sum) f_fundSize_USD, by(f_vintageInceptionYear)
keep if f_vintageInceptionYear>=2000
replace f_fundSize_USD = f_fundSize_USD/1000
format f_fundSize_USD %4.0f
ren (f_vintageInceptionYear f_fundSize_USD) (year private)
save publicvsPvtMkts.dta, replace

local files: dir "..\Data_IPO\raw_data\" file "IPO Data_CapitalIQ_*.xls", respect
local i = 1
foreach f of local files {
	di "`f'"
	qui import excel using "..\Data_IPO\raw_data\\`f'", clear
	qui keep K H O
	qui ren (H K O) (public date country)
	qui drop in 1/3
	qui gen year = substr(date,6,4)
	qui destring year public, replace force
	qui drop date
	if `i'==1 {
		qui save temp.dta, replace
		local ++i
	}
	else {
		qui append using temp.dta
		qui save temp.dta, replace
	}
}
collapse (sum) public, by(year)
replace public = public/1000
merge 1:1 year using publicvsPvtMkts.dta
keep if _m==3
drop _m

ren (public private) (mpublic mprivate)
gen time = 3*_n-2
reshape long m, i(year time) j(type) str
replace time = time+1 if type=="private"

twoway (bar m time if inlist(time,1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58,61,64,67), barw(0.8) col(gs0) lp(solid) lc(gs0) lw(medium))|| ///
	(bar m time if inlist(time,2,5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,62,65,68), barw(0.8) col(gs16) lp(solid) lc(gs0) lw(medium)), ///
	ylabel(, angle(horiz) labsize(small) nogrid) ///
	xlabel(1.5 "2000" 4.5 "2001" 7.5 "2002" 10.5 "2003" 13.5 "2004" 16.5 "2005" 19.5 "2006" 22.5 "2007" 25.5 "2008" 28.5 "2009" 31.5 "2010" 34.5 "2011" 37.5 "2012" 40.5 "2013" 43.5 "2014" 46.5 "2015" 49.5 "2016" 52.5 "2017" 55.5 "2018" 58.5 "2019" 61.5 "2020" 64.5 "2021" 67.5 "2022", angle(90) labsize(small)) ytitle("Capital Formation ($ Bn)", size(small)) ///
		legend(order(1 "Global IPO Gross Proceeds ($ Bn)" 2 "Private Capital - Funds Raised ($ Bn)") cols(2) size(small) symx(8) symy(2)) ///
		graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\R2_fig_IPOvsPE.pdf", as(pdf) name("Graph") replace
graph close

erase publicvsPvtMkts.dta
erase temp.dta

//Panel B
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
drop _m
bysort fm_id f_id i_ID (year): keep if _n==1
dropmiss f_id i_ID year, force obs
drop f_id
duplicates drop
gen repeatInvestor = 0
save temp.dta, replace

qui count
forvalues i = 1/`r(N)' {
	di `i'
	qui use temp.dta, clear
	local f = fm_id[`i']
	local i = i_ID[`i']
	local y = year[`i']
	
	qui keep if fm_id==`f' & i_ID==`i' & year<`y'-1 //inrange(year,`y'-5,`y'-1)
	qui count
	if `r(N)'!=0 {
		qui use temp.dta, clear
		qui replace repeatInvestor = 1 if _n==`i'
		qui save temp.dta, replace
	}
}
use temp.dta, clear
collapse (max) repeatInvestor, by(i_ID year LPPRISignatory)
gen investor = 1
collapse (sum) investor repeatInvestor, by(year LPPRISignatory)
keep if inrange(year,2006,2022)
gen y = year
tostring y, replace
replace y = "2010" if year<=2010
drop year
ren y year
collapse (mean) investor repeatInvestor, by(year LPPRISignatory)
gen frac = repeatInvestor/investor*100
gsort -LPPRISignatory year
gen id = _n*3-2
replace id = id-38 if LPPRISignatory==0

twoway (bar frac id if LPPRISignatory==1, barw(0.7) col(gs0) lp(solid) lc(gs0) lw(medium))||(bar frac id if LPPRISignatory==0, barw(0.7) col(gs16) lp(solid) lc(gs0) lw(medium)), ///
	ylabel(0(10)50, labsize(small) angle(horiz) nogrid) ///
	xlabel(1.5 "<=2010" 4.5 "2011" 7.5 "2012" 10.5 "2013" 13.5 "2014" 16.5 "2015" 19.5 "2016" 22.5 "2017" 25.5 "2018" 28.5 "2019" 31.5 "2020" 34.5 "2021" 37.5 "2022", angle(90) labsize(small) nogrid) ///
	ytitle("Repeat Investors (as % of Total Investors)", size(small)) xtitle("Year", size(small)) legend(order(1 "UN PRI LPs" 2 "non-UN PRI LPs") cols(2) size(small) symx(8) symy(2)) graphregion(color(white))
graph export "..\..\Output\R2_fig_repeatInvestor.pdf", as(pdf) name("Graph") replace
graph close
}
**Figure 2: Development of Private Equity Firms' ESG Focus from 2000 to 2022 --
{
//Panel A: Full Sample
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep if inrange(snapshot_year,2000,2022)
gen ESGRaw = exp(dict_esg2)
gen valuationRaw = exp(valuation)
gen ValminusESG = valuationRaw - ESGRaw
replace ESGRaw = ESGRaw-1
collapse (mean) ESGRaw valuationRaw ValminusESG word_count, by(snapshot_year)

twoway (connected ESGRaw snapshot_year, m(o) mc(gs0) msize(small) lp(solid) lc(gs0))|| ///
		(connected ValminusESG snapshot_year, m(t) mc(gs0) msize(small) lw(vthin) lp(dash) lc(gs0))|| ///
		(bar word_count snapshot_year, barw(0.5) yaxis(2) lc(gray) fc(none)), ///
		legend(order(1 "ESG Ratio" 2 "Valuation Words Ratio - ESG Ratio" 3 "Word Count (10k)") size(small) cols(4) symx(5)) ///
		xtitle("Year", size(small)) xlabel(2000(1)2022, labsize(small) angle(90)) ytitle("Disclosure Ratio (per 10k words)", size(small)) ///
		ylabel(10(20)70,labsize(small) angle(horiz) nogrid) ///
		ytitle("Word Count (10k)", size(small) axis(2)) ylabel(0(10)30,labsize(small) angle(horiz) axis(2)) graphregion(color(white))
graph export "..\..\Output\R2_fig_ESGEvol.pdf", as(pdf) name("Graph") replace
graph close

//Panel B: E- S- and G- separately
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep if inrange(snapshot_year,2000,2022)
gen ERaw = [exp(dict_e2)-1]
gen SRaw = [exp(dict_s2)-1]
gen GRaw = [exp(dict_g2)-1]

twoway (lpolyci ERaw snapshot_year, degree(0) ciplot(rarea) fc(none) lc(gs0) fitp(connected) m(oh) mc(gs0) msize(small) lp(solid))|| ////
		(lpolyci SRaw snapshot_year, degree(0) ciplot(rarea) fc(none) lc(gs3) fitp(connected) m(d) mc(gs3) msize(small) lp(solid))|| ////
		(lpolyci GRaw snapshot_year, degree(0) ciplot(rarea) fc(none) lc(gs6) fitp(connected) m(t) mc(gs6) msize(small) lp(solid)), ///
		xlabel(2000(1)2022, labsize(small) angle(90)) xtitle("Year", size(small)) ///
		ylabel(, labsize(small) angle(horiz) nogrid) ytitle("Disclosure Ratio (per 10k words)", size(small)) ///
		graphregion(color(white)) legend(order(1 "95% CI" 2 "Environmental Ratio" 4 "Social Ratio" 6 "Governance Ratio") cols(4) symx(7) symy(4) size(small))

graph export "..\..\Output\R2_fig_ESGEvolSeparate.pdf", as(pdf) name("Graph") replace
graph close
}
**Figure 3: ESG Disclosures and Private Equity Firm Characteristics --
{
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id country_us country_uk country_eu country_cn fm_pe_mainFirmStrategy fm_listed fm_log_total_AUM_USD
gen country_others = cond(country_us|country_uk|country_eu|country_cn,0,1)
replace fm_pe_mainFirmStrategy = strproper(fm_pe_mainFirmStrategy)
replace fm_listed = cond(fm_listed=="YES","Listed",cond(fm_listed=="NO","Unlisted",""))
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", keepus(snapshot_year dict_esg2)
keep if _m==3
drop _m
ren snapshot_year year
replace dict_esg = exp(dict_esg2)-1
save temp.dta, replace

//PE Headquarters.
use temp.dta, clear
keep if inlist(year,2002,2012,2022)
count if country_us==1
local us = `r(N)'
local usfmt: di %5.0fc `us'
count if country_cn==1
local cn = `r(N)'
local cnfmt: di %3.0fc `cn'
count if country_uk==1
local uk = `r(N)'
local ukfmt: di %3.0fc `uk'
count if country_eu==1
local eu = `r(N)'
local eufmt: di %3.0fc `eu'
count if country_others==1
local ot = `r(N)'
local otfmt: di %5.0fc `ot'
collapse (mean) dict_esg2, by(country_us country_cn country_uk country_eu country_others year)

gen country = cond(country_us==1,1,cond(country_eu==1,2,cond(country_uk==1,3,cond(country_cn==1,4,5))))
sort year country
gen id = _n
replace id = id + 1 if year==2012
replace id = id + 2 if year==2022
twoway (bar dict_esg2 id if inlist(id,1,7,13), color(gs0) barw(0.8) lp(solid) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,2,8,14), col(gs3) barw(0.8) lp(dash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,3,9,15), color(gs6) barw(0.8) lp(shortdash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,4,10,16), color(gs9) barw(0.8) lp(dash_dot) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,5,11,17), color(gs12) barw(0.8) lp(dot) lc(gs0) lw(medium)), ylabel(0(10)100, labsize(small) angle(horiz) nogrid) legend(order(1 "United States (`usfmt')" 2 "European Union (`eufmt')" 3 "United Kingdom  (`ukfmt')" 4 "China (`cnfmt')" 5 "Others (`otfmt')") size(small) rows(2) cols(3) symx(8) symy(4)) ytitle("ESG Ratio", size(small)) xlabel(0 " " 3 "2002" 9 "2012" 15 "2022" 18 " ", labsize(small)) graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\R2_fig_FirmCharHQ.pdf", as(pdf) name("Graph") replace
graph close

//Investee Countries
use "..\Data_preqin\\preqin_dealsBuyout.dta", clear
keep d_firmID d_firmPrimaryIndustry
duplicates drop
bysort d_firmID (d_firmPrimaryIndustry): keep if _n==1
merge 1:m d_firmID using listofBOGrowthDeals.dta
keep if _m==3
keep d_firmID d_firmPrimaryIndustry d_investorID d_firmCountry d_dealYear d_dealID
ren (d_investorID d_dealYear) (fm_id snapshot_year)
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", keepus(snapshot_year dict_esg2)
keep if _m==3
drop _m
save temp.dta, replace

gen countryPortfolio_us = cond(d_firmCountry=="UNITED STATES",1,0)
gen countryPortfolio_uk = cond(d_firmCountry=="UNITED KINGDOM",1,0)
gen countryPortfolio_eu = cond(inlist(d_firmCountry ,"AUSTRIA","BELGIUM","BULGARIA","CROATIA","CYPRUS","CZECH REPUBLIC")|inlist(d_firmCountry ,"DENMARK","ESTONIA","FINLAND","FRANCE","GERMANY","GREECE")|inlist(d_firmCountry ,"HUNGARY","IRELAND","ITALY","LATVIA","LITHUANIA","LUXEMBOURG")|inlist(d_firmCountry ,"MALTA","NETHERLANDS","POLAND","PORTUGAL","ROMANIA","SLOVAKIA")|inlist(d_firmCountry ,"SLOVENIA","SPAIN","SWEDEN"),1,0)
gen countryPortfolio_others = cond(countryPortfolio_us==1|countryPortfolio_uk==1|countryPortfolio_eu==1,0,1)
ren snapshot_year year
replace dict_esg2 = exp(dict_esg2)-1
save temp.dta, replace

use temp.dta, clear
keep if inlist(year,2002,2012,2022)
count if countryPortfolio_us==1
local us = `r(N)'
local usfmt: di %5.0fc `us'
count if countryPortfolio_uk==1
local uk = `r(N)'
local ukfmt: di %3.0fc `uk'
count if countryPortfolio_eu==1
local eu = `r(N)'
local eufmt: di %3.0fc `eu'
count if countryPortfolio_others==1
local ot = `r(N)'
local otfmt: di %5.0fc `ot'
collapse (mean) dict_esg2, by(countryPortfolio_us countryPortfolio_uk countryPortfolio_eu countryPortfolio_others year)

gen country = cond(countryPortfolio_us==1,1,cond(countryPortfolio_eu==1,2,cond(countryPortfolio_uk==1,3,4)))
sort year country
gen id = _n
replace id = id + 1 if year==2012
replace id = id + 2 if year==2022
twoway (bar dict_esg2 id if inlist(id,1,6,11), color(gs0) barw(0.8) lp(solid) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,2,7,12), col(gs3) barw(0.8) lp(dash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,3,8,13), color(gs6) barw(0.8) lp(shortdash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,4,9,14), color(gs9) barw(0.8) lp(dash_dot) lc(gs0) lw(medium)), ylabel(0(10)100, labsize(small) angle(horiz) nogrid) legend(order(1 "United States (`usfmt')" 2 "European Union (`eufmt')" 3 "United Kingdom  (`ukfmt')" 4 "Others (`otfmt')") size(small) rows(2) cols(3) symx(8) symy(4)) ytitle("ESG Ratio", size(small)) xlabel(0 " " 2.5 "2002" 7.5 "2012" 12.5 "2022" 15 " ", labsize(small)) graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\R2_fig_FirmCharInvCountr.pdf", as(pdf) name("Graph") replace
graph close

//Investee Industries
use temp.dta, clear
keep if inlist(year,2002,2012,2022)

gen group1 = cond(inlist(d_firmPrimaryIndustry,"ENERGY STORAGE & BATTERIES","ENVIRONMENTAL SERVICES","RENEWABLE ENERGY"),1,0)
gen group2 = cond(inlist(d_firmPrimaryIndustry,"MINING","OIL & GAS","POWER & UTILITIES"),1,0)
gen group3 = cond(inlist(d_firmPrimaryIndustry,"SOFTWARE","SEMICONDUCTORS"),1,0)
keep if group1==1|group2==1|group3==1
replace d_firmPrimaryIndustry = strproper(d_firmPrimaryIndustry)
count if group1==1
local ind1 = `r(N)'
local ind1fmt: di %3.0fc `ind1'
count if group2==1
local ind2 = `r(N)'
local ind2fmt: di %3.0fc `ind2'
count if group3==1
local ind3 = `r(N)'
local ind3fmt: di %5.0fc `ind3'
collapse (mean) dict_esg2, by(year group1 group2 group3)

gen industry = cond(group1==1,1,cond(group2==1,2,3))
sort year industry
gen id = _n
replace id = id + 1 if year==2012
replace id = id + 2 if year==2022
twoway (bar dict_esg2 id if inlist(id,1,5,9), color(gs0) barw(0.8) lp(solid) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,2,6,10), col(gs3) barw(0.8) lp(dash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,3,7,11), color(gs6) barw(0.8) lp(shortdash) lc(gs0) lw(medium)), ylabel(0(10)100, labsize(small) angle(horiz) nogrid) legend(order(1 "Energy Storage/Renewables/Environmental Services (`ind1fmt')" 2 "Mining/Oil & Gas/Power & Utilities (`ind2fmt')" 3 "Software/Semiconductors  (`ind3fmt')") size(small) rows(3) cols(1) symx(4) symy(4)) ytitle("ESG Ratio", size(small)) xlabel(0 " " 2 "2002" 6 "2012" 10 "2022" 12 " ", labsize(small)) graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\R2_fig_FirmCharInvIndus.pdf", as(pdf) name("Graph") replace
graph close

erase temp.dta

//LP Country
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_preqin\\preqin_fund.dta", keepus(fm_id f_id f_vintageInceptionYear)
keep if _m==3
keep if !missing(f_vintageInceptionYear)
keep fm_id f_id f_vintageInceptionYear
merge 1:m fm_id f_id using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
keep fm_id f_id i_ID f_vintageInceptionYear
duplicates drop
ren f_vintageInceptionYear snapshot_year
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", keepus(snapshot_year dict_esg2)
keep if _m==3
drop _m
save temp.dta, replace

use "..\Data_preqin\\preqin_LPs.dta", clear
keep i_ID i_country
merge 1:m i_ID using temp.dta
keep if _m==3
drop _m
replace i_country = "UNITED KINGDOM" if i_country=="UK"
replace i_country = "UNITED STATES" if i_country=="US"

gen countryLP_us = cond(i_country=="UNITED STATES",1,0)
gen countryLP_uk = cond(i_country=="UNITED KINGDOM",1,0)
gen countryLP_eu = cond(inlist(i_country ,"AUSTRIA","BELGIUM","BULGARIA","CROATIA","CYPRUS","CZECH REPUBLIC")|inlist(i_country ,"DENMARK","ESTONIA","FINLAND","FRANCE","GERMANY","GREECE")|inlist(i_country ,"HUNGARY","IRELAND","ITALY","LATVIA","LITHUANIA","LUXEMBOURG")|inlist(i_country ,"MALTA","NETHERLANDS","POLAND","PORTUGAL","ROMANIA","SLOVAKIA")|inlist(i_country,"SLOVENIA","SPAIN","SWEDEN"),1,0)
gen countryLP_others = cond(countryLP_us==1|countryLP_uk==1|countryLP_eu==1,0,1)
ren snapshot_year year
replace dict_esg2 = exp(dict_esg2)-1
save temp.dta, replace

use temp.dta, clear
keep if inlist(year,2002,2012,2022)
count if countryLP_us==1
local us = `r(N)'
local usfmt: di %5.0fc `us'
count if countryLP_uk==1
local uk = `r(N)'
local ukfmt: di %3.0fc `uk'
count if countryLP_eu==1
local eu = `r(N)'
local eufmt: di %3.0fc `eu'
count if countryLP_others==1
local ot = `r(N)'
local otfmt: di %5.0fc `ot'
collapse (mean) dict_esg2, by(countryLP_us countryLP_uk countryLP_eu countryLP_others year)

gen country = cond(countryLP_us==1,1,cond(countryLP_eu==1,2,cond(countryLP_uk==1,3,4)))
sort year country
gen id = _n
replace id = id + 1 if year==2012
replace id = id + 2 if year==2022
twoway (bar dict_esg2 id if inlist(id,1,6,11), color(gs0) barw(0.8) lp(solid) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,2,7,12), col(gs3) barw(0.8) lp(dash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,3,8,13), color(gs6) barw(0.8) lp(shortdash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,4,9,14), color(gs9) barw(0.8) lp(dash_dot) lc(gs0) lw(medium)), ylabel(0(10)100, labsize(small) angle(horiz) nogrid) legend(order(1 "United States (`usfmt')" 2 "European Union (`eufmt')" 3 "United Kingdom  (`ukfmt')" 4 "Others (`otfmt')") size(small) rows(2) cols(3) symx(8) symy(4)) ytitle("ESG Ratio", size(small)) xlabel(0 " " 2.5 "2002" 7.5 "2012" 12.5 "2022" 15 " ", labsize(small)) graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\R2_fig_FirmCharLPCountr.pdf", as(pdf) name("Graph") replace
graph close
erase temp.dta
}
**Figure 4: PE versus other firm type ESG Disclosures --
{
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_country,"UNITED STATES")
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using  "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
ren snapshot_year year
keep fm_id year dict_esg2
keep if inrange(year,2008,2022)
bysort fm_id: egen firstYear = min(year)
drop if firstYear!=2008
gen firmType="PE"
tostring fm_id, replace
save PEvsOthers.dta, replace

use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final_HF.dta", clear
ren snapshot_year year
keep fm_id year dict_esg2
keep if inrange(year,2008,2022)
bysort fm_id: egen firstYear = min(year)
drop if firstYear!=2008
gen firmType="Hedge"
append using PEvsOthers.dta
save PEvsOthers.dta, replace

gen ESGRaw = exp(dict_esg2)-1

twoway 	(lpolyci ESGRaw year if firmType=="PE", degree(0) ciplot(rarea) fc(none) lc(gs0) fitp(connected) m(oh) mc(gs0) msize(small) lp(solid))|| ///
		(lpolyci ESGRaw year if firmType=="Hedge", degree(0) ciplot(rarea) fc(none) lc(gs6) fitp(connected) m(th) mc(gs6) msize(small) lp(solid)), ///
		xlabel(2008(1)2022, labsize(small) angle(90)) xtitle("Year", size(small)) ///
		ylabel(24(2)34, labsize(small) angle(horiz) nogrid) ytitle("ESG Ratio (per 10k words)", size(small)) ///
		graphregion(color(white)) legend(order(1 "95% CI" 2 "US Private Equity Firms" 4 "US Domiciled Hedge Funds") cols(1) size(small))
graph export "..\..\Output\R2_fig_PEvsOthersESGLevel.pdf", as(pdf) name("Graph") replace
graph close

erase PEvsOthers.dta
}
**Figure 5: PE ESG Disclosures and Signing up to UN-PRI --
{
//Using Stacked design
clear all
set obs 8
gen b = .
gen ll = .
gen ul = .
save temp.dta, replace 

use ESGPanel.dta, clear
gen GPPRIYear = year(dateUNPRI)
gen neverTreated = cond(GPPRIYear==.,1,0)
gen time_to_treat = year - GPPRIYear

gen t_4 = cond(time_to_treat<=-4,1,0)
gen t_3 = cond(time_to_treat==-3,1,0)
gen t_2 = cond(time_to_treat==-2,1,0)
gen t_1 = cond(time_to_treat==-1,1,0)
gen t0 = cond(time_to_treat==0,1,0)
gen t1 = cond(time_to_treat==1,1,0)
gen t2 = cond(time_to_treat==2,1,0)
gen t3 = cond(time_to_treat==3,1,0)
gen t4 = cond(time_to_treat>=4 & time_to_treat!=.,1,0)

gen forReg = cond(positive!=. & valuation!=. & log_GDP!=. & GDPGrowth!=. & log_population!=. & laborForceParticipation!=. & womenSeatsParliament!=.,1,0)

stackedev dict_esg2 t_4 t_3 t_2 t0 t1 t2 t3 t4 if forReg==1, cohort(GPPRIYear) time(year) never_treat(neverTreated) unit_fe(fm_id) clust_unit(ctry_yr) covariates(logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament)

matrix A = r(table)
forvalues i = 1/8 {
	use temp.dta, clear
	replace b = A[1,`i'] if _n==`i'
	replace ll = A[5,`i'] if _n==`i'
	replace ul = A[6,`i'] if _n==`i'
	save temp.dta, replace
}
gen dist_to_PRI = _n-5
replace dist_to_PRI = dist_to_PRI+1 if dist_to_PRI>=-1
set obs 9
replace dist_to_PRI = -1 if dist_to_PRI == .
replace b = 0 if dist_to_PRI == -1
replace ll = 0 if dist_to_PRI == -1
replace ul = 0 if dist_to_PRI == -1
sort dist_to_PRI
keep if inrange(dist_to_PRI,-3,3)
twoway (rcap ll ul dist_to_PRI, col(gs0) lp(dash) lw(thin)  msize(vsmall) m(d))||(scatter b dist_to_PRI, m(d) msize(small) col(gs0)), ///
	ylabel(-0.3(0.1)0.4, labsize(small) angle(horiz) nogrid) xlabel(-3(1)3, labsize(small)) yline(0, lw(thin) lc(red)) xtitle("Time (in years) to UN-PRI Pledge by PE Firm", size(small)) ///
	ytitle("Coefficient Estimate & 95% CI", size(small)) legend(off) graphregion(color(white))
graph export "..\..\Output\R2_fig_GPUNPRI.pdf", as(pdf) name("Graph") replace
graph close
}
**Figure 6: Visualising DiD in Table 3 (LP-PRI) --
{
//LP-PRI DiD graph
clear all
set obs 7
gen b = .
gen ll = .
gen ul = .
save temp.dta, replace 

use LPPRI.dta, clear

bysort fm_id: egen no_treat = max(PRIInvestorPresent)
replace no_treat = 1- no_treat

gen PRIInvestorYear = year if PRIInvestorPresent==1
bysort fm_id: egen PRIInvestor1stYear = min(PRIInvestorYear)
gen dist_to_PRIInvestor = year - PRIInvestor1stYear

gen t_4 = cond(dist_to_PRIInvestor<=-4,1,0)
gen t_3 = cond(dist_to_PRIInvestor==-3,1,0)
gen t_2 = cond(dist_to_PRIInvestor==-2,1,0)
gen t_1 = cond(dist_to_PRIInvestor==-1,1,0)
gen t0 = cond(dist_to_PRIInvestor==0,1,0)
gen t1 = cond(dist_to_PRIInvestor==1,1,0)
gen t2 = cond(dist_to_PRIInvestor==2,1,0)
gen t3 = cond(dist_to_PRIInvestor==3,1,0)
gen t4 = cond(dist_to_PRIInvestor>=4 & dist_to_PRIInvestor!=.,1,0)

replace t0 = 0 if PRIInvestorPresent==0
replace t1 = 0 if PRIInvestorPresent==0
replace t2 = 0 if PRIInvestorPresent==0
replace t3 = 0 if PRIInvestorPresent==0
replace t4 = 0 if PRIInvestorPresent==0

drop if t0==1
stackedev dict_esg2 t_4 t_3 t_2 t1 t2 t3 t4 if forReg==1, cohort(PRIInvestor1stYear) time(year) never_treat(no_treat) unit_fe(fm_id) clust_unit(ctry_yr)

matrix A = r(table)
forvalues i = 1/7 {
	use temp.dta, clear
	replace b = A[1,`i'] if _n==`i'
	replace ll = A[5,`i'] if _n==`i'
	replace ul = A[6,`i'] if _n==`i'
	save temp.dta, replace
}
gen dist_to_PRIInvestorPresent = _n-5
replace dist_to_PRIInvestorPresent = dist_to_PRIInvestorPresent+1 if dist_to_PRIInvestorPresent>=-1
set obs 8
replace dist_to_PRIInvestorPresent = -1 if dist_to_PRIInvestorPresent == .
replace b = 0 if dist_to_PRIInvestorPresent == -1
replace ll = 0 if dist_to_PRIInvestorPresent == -1
replace ul = 0 if dist_to_PRIInvestorPresent == -1
sort dist_to_PRIInvestorPresent
keep if inrange(dist_to_PRIInvestorPresent,-3,3)
twoway (rcap ll ul dist_to_PRIInvestorPresent, col(gs0) lp(dash) lw(thin)  msize(vsmall) m(d))||(scatter b dist_to_PRIInvestorPresent, m(d) msize(small) col(gs0)), ///
	ylabel(-0.2(0.1)0.2, labsize(small) angle(horiz) nogrid) xlabel(-3(1)3, labsize(small)) yline(0, lw(thin) lc(red)) xtitle("Time (in years) to PRI Investor presence", size(small)) ///
	ytitle("Coefficient Estimate & 95% CI", size(small)) legend(off) graphregion(color(white))
graph export "..\..\Output\R2_fig_LPUNPRI.pdf", as(pdf) name("Graph") replace
graph close
}
**Figure 7: PE ESG Disclosures and Fundraising --
{
use fundRaising.dta, clear
twoway (function y=0.05, range(-1 0) base(-0.02) recast(area) col(gs14))|| ///
		(lpolyci esgResid fund_event_year if inrange(fund_event_year,-3,2), n(6) ciplot(rcap) alp(dash) alw(thin) fitp(connected) m(d) msize(small) col(gs0)), ///
		ytitle("Log. ESG Ratio (Residual) & 95% CI", size(small)) ylabel(-.02(0.01)0.05, labsize(small) nogrid angle(horiz)) xlabel(-3(1)2, labsize(small)) xtitle("Time (in years) after close of Fund-raise", size(small)) graphregion(color(white)) legend(order(1 "Fund-Raising Year" 3 "Log. ESG Residual") size(small)) yline(0, lw(vthin) lc(red))
graph export "..\..\Output\R2_fig_fundRaiseResidual.pdf", as(pdf) name("Graph") replace
graph close
}
**Figure 8: PE ESG Disclosures and TRI Outcomes
{
//Panel A
use tri_analysis.dta, clear

reghdfe Lnv218_TotalOnsite t_4 t_3 t_2 t0 t1 t2 t3 t4 B_Lnv218_IndYr if aggregationType=="All Chemicals", absorb(trifd countyYear) cluster(stateYear) level(95)
matrix A = r(table)
forvalues i = 2/7 {
	local b`=`i'-1' = A[1,`i']
	local ll`=`i'-1' = A[5,`i']
	local ul`=`i'-1' = A[6,`i']
}
clear all
set obs 7
gen distDeal = _n - 4
drop if distDeal==-1
gen b = .
gen ll = .
gen ul = .
forvalues i = 1/6 {
	replace b = `b`i'' if _n==`i'
	replace ll = `ll`i'' if _n==`i'
	replace ul = `ul`i'' if _n==`i'
}
set obs `=_N+1'
replace distDeal = -1 if _n==_N
replace b = 0 if distDeal==-1
sort distDeal

twoway (connected b distDeal, m(d) msize(small) col(gs0))||(rcap ll ul distDeal, col(gs0) lw(thin) lp(solid) msize(vsmall)), ///
	ylabel(-0.3(0.1)0.2, labsize(small) angle(horiz) nogrid) xlabel(-3(1)3, labsize(small)) yline(0, lw(thin) lc(red)) xtitle("Years to Deal", size(small)) ///
	ytitle("Coefficient Estimate & 95% CI", size(small)) legend(off) graphregion(color(white)) title("Total Onsite Releases" , size(small))
graph export "..\..\Output\R2_fig_TRI_panelA.pdf", as(pdf) name("Graph") replace
graph close

//Panel B
**High vs Low E-firms
use tri_analysis.dta, clear

reghdfe Lnv218_TotalOnsite t_4 t_3 t_2 t0 t1 t2 t3 t4 B_Lnv218_IndYr if aggregationType=="All Chemicals" & (highEn==1|d_firmID==.), absorb(trifd countyYear) cluster(stateYear) level(95)
matrix A = r(table)
forvalues i = 2/7 {
	local b`=`i'-1' = A[1,`i']
	local ll`=`i'-1' = A[5,`i']
	local ul`=`i'-1' = A[6,`i']
}
clear all
set obs 7
gen double distDeal = _n - 4
drop if distDeal==-1
gen b = .
gen ll = .
gen ul = .
forvalues i = 1/6 {
	replace b = `b`i'' if _n==`i'
	replace ll = `ll`i'' if _n==`i'
	replace ul = `ul`i'' if _n==`i'
}
set obs `=_N+1'
replace distDeal = -1 if _n==_N
sort distDeal
gen highEn = 1
save temp.dta, replace

use tri_analysis.dta, clear

reghdfe Lnv218_TotalOnsite t_4 t_3 t_2 t0 t1 t2 t3 t4 B_Lnv218_IndYr if aggregationType=="All Chemicals" & (highEn==0|d_firmID==.), absorb(trifd countyYear) cluster(stateYear) level(95)
matrix A = r(table)
forvalues i = 2/7 {
	local b`=`i'-1' = A[1,`i']
	local ll`=`i'-1' = A[5,`i']
	local ul`=`i'-1' = A[6,`i']
}
clear all
set obs 7
gen double distDeal = _n - 4
drop if distDeal==-1
gen b = .
gen ll = .
gen ul = .
forvalues i = 1/6 {
	replace b = `b`i'' if _n==`i'
	replace ll = `ll`i'' if _n==`i'
	replace ul = `ul`i'' if _n==`i'
}
set obs `=_N+1'
replace distDeal = -1 if _n==_N
sort distDeal
gen highEn = 0
append using temp.dta
replace b = 0 if distDeal==-1

replace distDeal = distDeal - 0.04 if highEn==1
replace distDeal = distDeal + 0.04 if highEn==0
replace distDeal = -1 if inlist(distDeal,-0.96,-1.04)

twoway (connected b distDeal if highEn==1, m(Dh) msize(small) col(gs0))||(rcap ll ul distDeal if highEn==1, col(gs0) lw(thin) lp(solid) msize(vsmall))|| ///
	(connected b distDeal if highEn==0, lp(dash) m(s) msize(small) col(gs3))||(rcap ll ul distDeal if highEn==0, col(gs3) lw(thin) lp(solid) msize(vsmall)), ///
	ylabel(-0.6(0.2)0.4, labsize(small) angle(horiz) nogrid) xlabel(-3(1)3, labsize(small)) yline(0, lw(thin) lc(red)) xtitle("Years to Deal", size(small)) ///
	ytitle("Coefficient Estimate & 95% CI", size(small)) graphregion(color(white)) title("Total Onsite Releases" , size(small)) ///
	legend(order(1 "High Envir. PE Disclosure facilities" 3 "Other PE affiliated facilities") size(small))
graph export "..\..\Output\R2_fig_TRI_panelB.pdf", as(pdf) name("Graph") replace
graph close
}

********************************************************************************
***************************ONLINE APPENDIX TABLES*******************************
********************************************************************************
**Figure OA6: Comparing AUMs of different samples
{
//Only PE Firms
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_PE_AUM_USD
recode fm_PE_AUM_USD (0=.)
replace fm_PE_AUM_USD=fm_PE_AUM_USD/1000000 //Converting to Tn
keep if !missing(fm_PE_AUM_USD)
gen allPESample = 1
save temp.dta, replace

//PE Firms with Available Website Data
use "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", clear
keep fm_id
duplicates drop
merge 1:m fm_id using temp.dta
drop if _m==1
gen websiteData = 1 if _m==3
drop _m
save temp.dta, replace

//Firms with BO deal data AND main firm strategy is Buyout/Growth AND available website data
use listOfBOGrowthDeals.dta, clear
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using temp.dta
drop if _m==1
gen dealData = 1 if _m==3 & websiteData==1
drop _m
save temp.dta, replace

//LP Sample
use LPPRI.dta, clear
keep fm_id
duplicates drop
merge 1:m fm_id using temp.dta
drop if _m==1
gen lpSample = 1 if _m==3
drop _m
save temp.dta, replace

//Mandat Sample
use mandat.dta, clear
keep fm_id
duplicates drop
merge 1:m fm_id using temp.dta
drop if _m==1
gen mandatSample = 1 if _m==3
drop _m
save temp.dta, replace

//Fundraise Sample
use fundRaising.dta, clear
keep fm_id
duplicates drop
merge 1:m fm_id using temp.dta
drop if _m==1
gen fundRaiseSample = 1 if _m==3
drop _m
save temp.dta, replace

//TRI Sample
use tri_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using temp.dta
drop if _m==1
gen triSample = 1 if _m==3
drop _m
save temp.dta, replace

//Trucost Sample
use trucost_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using temp.dta
drop if _m==1
gen trucostSample = 1 if _m==3
drop _m
save temp.dta, replace

//Reprisk Sample
use reprisk_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using temp.dta
drop if _m==1
gen repriskSample = 1 if _m==3
drop _m
save temp.dta, replace

//OSHA Sample
use oshaInspections_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using temp.dta
drop if _m==1
gen oshaSample = 1 if _m==3
drop _m
save temp.dta, replace

local i = 1
use temp.dta, clear
foreach var of varlist allPESample websiteData dealData lpSample mandatSample fundRaiseSample triSample trucostSample oshaSample repriskSample {
	use temp.dta, clear
	keep if `var'==1
	collapse (sum) fm_PE_AUM_USD
	gen v1 = "`var'"
	if `i'==1 {
		save temp1.dta, replace
		local ++i
	}
	else {
		append using temp1.dta
		save temp1.dta, replace
	}
}

gen id = _N-_n
sort id
format fm_PE_AUM_USD %2.1f
twoway bar fm_PE_AUM_USD id, ylabel(0(0.5)3.5, labsize(small) angle(horiz) nogrid) ytitle("PE AUM (Tn USD)", size(small)) ///
	barw(0.5) col(gs6) xtitle("", size(small)) ///
	xlabel(0 `" "All PE" "Firms" "' 1 `" "w/ Website" "Data" "' 2 `" "w/ Deal" "Data" "' 3 `""UN PRI" "Sample""' 4 `""Mandatory" "Sample""' 5 `""Fundraise" "Sample""' 6 `""TRI" "Sample""' 7 `""Trucost" "Sample""' 8 `""OSHA" "Sample""' 9 `""Reprisk" "Sample""', labsize(small)) graphregion(color(white))
graph export "..\..\Output\OA_R2_fig_AUM_Samples.pdf", as(pdf) name("Graph") replace
graph close
}
**Table OA6: Sample selection bias tests
{
****Comparison between different analyses samples - on PE firm Characteristics
//PE Firms with BO/Growth Deals
eststo clear
use listOfBOGrowthDeals.dta, clear
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep fm_id
duplicates drop
merge 1:1 fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_BOstrat.txt", cells("count(l(N_BOstrat) f(%12.0f)) mean(l(Mean_BOstrat) f(%12.4f)) variance(l(Var_BOstrat) f(%12.4f))") label replace

//LP Sample
eststo clear
use LPPRI.dta, clear
keep fm_id
duplicates drop
merge 1:1 fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_LP.txt", cells("count(l(N_LP) f(%12.0f)) mean(l(Mean_LP) f(%12.4f)) variance(l(Var_LP) f(%12.4f))") label replace

//Mandat Sample
eststo clear
use mandat.dta, clear
keep fm_id
duplicates drop
merge 1:1 fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_mandat.txt", cells("count(l(N_mandat) f(%12.0f)) mean(l(Mean_mandat) f(%12.4f)) variance(l(Var_mandat) f(%12.4f))") label replace

//Fundraise Sample
eststo clear
use  fundRaising.dta, clear
keep fm_id
duplicates drop
merge 1:1 fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_fundraise.txt", cells("count(l(N_fundraise) f(%12.0f)) mean(l(Mean_fundraise) f(%12.4f)) variance(l(Var_fundraise) f(%12.4f))") label replace

//TRI Sample
eststo clear
use tri_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_tri.txt", cells("count(l(N_tri) f(%12.0f)) mean(l(Mean_tri) f(%12.4f)) variance(l(Var_tri) f(%12.4f))") label replace

//Trucost Sample
eststo clear
use trucost_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_trucost.txt", cells("count(l(N_trucost) f(%12.0f)) mean(l(Mean_trucost) f(%12.4f)) variance(l(Var_trucost) f(%12.4f))") label replace

//Reprisk Sample
eststo clear
use reprisk_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_reprisk.txt", cells("count(l(N_reprisk) f(%12.0f)) mean(l(Mean_reprisk) f(%12.4f)) variance(l(Var_reprisk) f(%12.4f))") label replace

//OSHA Sample
eststo clear
use oshaInspections_analysisComplaint.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_preqin\\preqin_fund_mgr.dta"
keep if _m==3
keep fm_id fm_total_AUM_USD fm_total_staff
recode fm_total_AUM_USD fm_total_staff (0=.)
replace fm_total_AUM_USD=fm_total_AUM_USD/1000 //Converting to Bn
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD)
gen fm_log_total_staff = log(fm_total_staff)
keep fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD
label var fm_total_staff "No. of Employees"
label var fm_total_AUM_USD "Total AUM (USD Bn)"
label var fm_log_total_staff "Log. No. of Employees"
label var fm_log_total_AUM_USD "Log. Total AUM (USD Bn)"
eststo clear
estpost tabstat fm_id fm_total_staff fm_total_AUM_USD fm_log_total_staff fm_log_total_AUM_USD, statistics(count mean var) columns(statistics)
estout using ".\ta_osha.txt", cells("count(l(N_osha) f(%12.0f)) mean(l(Mean_osha) f(%12.4f)) variance(l(Var_osha) f(%12.4f))") label replace

//Combining all samples
import delimited using ".\ta_BOstrat.txt", clear
foreach var of varlist v2-v4 {
	local name = `var'[2]
	ren `var' `name'
}
drop in 1/2
destring N_* Mean_* Var_*, replace
gen id = _n
save temp.dta, replace

local items = `" LP mandat tri fundraise trucost reprisk osha "'
foreach i of local items {
	import delimited using ".\ta_`i'.txt", clear
	foreach var of varlist v2-v4 {
		local name = `var'[2]
		ren `var' `name'
	}
	drop in 1/2
	destring N_* Mean_* Var_*, replace
	gen id = _n
	merge 1:1 id using temp.dta
	drop _m
	save temp.dta, replace
}

order v1 N_BOstrat Mean_BOstrat Var_BOstrat N_LP Mean_LP Var_LP N_mandat Mean_mandat Var_mandat N_fundraise Mean_fundraise Var_fundraise N_tri Mean_tri Var_tri N_trucost Mean_trucost Var_trucost N_osha Mean_osha Var_osha N_reprisk Mean_reprisk Var_reprisk
drop id

export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_biasTests_panelA", replace) first(var)
erase temp.dta

****Comparison between different analyses samples - on website characteristics

//Firms with BO deal data AND main firm strategy is Buyout/Growth
use listOfBOGrowthDeals.dta, clear
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_BOstrat.txt", cells("count(l(N_BOstrat) f(%12.0f)) mean(l(Mean_BOstrat) f(%12.4f)) variance(l(Var_BOstrat) f(%12.4f))") label replace

//LP Sample
eststo clear
use LPPRI.dta, clear
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_LP.txt", cells("count(l(N_LP) f(%12.0f)) mean(l(Mean_LP) f(%12.4f)) variance(l(Var_LP) f(%12.4f))") label replace

//Mandatory Sample
eststo clear
use mandat.dta, clear
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_mandat.txt", cells("count(l(N_mandat) f(%12.0f)) mean(l(Mean_mandat) f(%12.4f)) variance(l(Var_mandat) f(%12.4f))") label replace

//Fundraise sample
eststo clear
use  fundRaising.dta, clear
keep fm_id
duplicates drop
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if inrange(snapshot_year,2000,2022)
keep if _m==3
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_fundraise.txt", cells("count(l(N_fundraise) f(%12.0f)) mean(l(Mean_fundraise) f(%12.4f)) variance(l(Var_fundraise) f(%12.4f))") label replace

//TRI Sample
eststo clear
use tri_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep if inrange(snapshot_year,2000,2022)
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_tri.txt", cells("count(l(N_TRI) f(%12.0f)) mean(l(Mean_TRI) f(%12.4f)) variance(l(Var_TRI) f(%12.4f))") label replace

//Trucost Sample
eststo clear
use trucost_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep if inrange(snapshot_year,2000,2022)
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_trucost.txt", cells("count(l(N_tru) f(%12.0f)) mean(l(Mean_tru) f(%12.4f)) variance(l(Var_tru) f(%12.4f))") label replace

//Reprisk Sample
eststo clear
use reprisk_analysis.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep if inrange(snapshot_year,2000,2022)
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_reprisk.txt", cells("count(l(N_reprisk) f(%12.0f)) mean(l(Mean_reprisk) f(%12.4f)) variance(l(Var_reprisk) f(%12.4f))") label replace

//OSHA Sample
eststo clear
use oshaInspections_analysisComplaint.dta, clear
keep d_firmID
duplicates drop
drop if missing(d_firmID)
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
keep if inrange(snapshot_year,2000,2022)
estpost tabstat dict_esg2 logLength logWordCount, statistics(count mean var) columns(statistics) 
estout using ".\ta_osha.txt", cells("count(l(N_osha) f(%12.0f)) mean(l(Mean_osha) f(%12.4f)) variance(l(Var_osha) f(%12.4f))") label replace

//Combining all samples
import delimited using ".\ta_BOstrat.txt", clear
foreach var of varlist v2-v4 {
	local name = `var'[2]
	ren `var' `name'
}
drop in 1/2
destring N_* Mean_* Var_*, replace
gen id = _n
save temp.dta, replace

local items = `" LP mandat fundraise tri trucost reprisk osha "'
foreach i of local items {
	import delimited using ".\ta_`i'.txt", clear
	foreach var of varlist v2-v4 {
		local name = `var'[2]
		ren `var' `name'
	}
	drop in 1/2
	destring N_* Mean_* Var_*, replace
	gen id = _n
	merge 1:1 id using temp.dta
	drop _m
	save temp.dta, replace
}

order v1 N_BOstrat Mean_BOstrat Var_BOstrat N_LP Mean_LP Var_LP N_mandat Mean_mandat Var_mandat N_fundraise Mean_fundraise Var_fundraise N_TRI Mean_TRI Var_TRI N_tru Mean_tru Var_tru N_osha Mean_osha Var_osha N_reprisk Mean_reprisk Var_reprisk
drop id

export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_biasTests_panelB", replace) first(var)
erase temp.dta
}
**Table OA7: Tabulation of PE Firms with ESG measure by Country and Year
{
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_country
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
drop _m
replace fm_country = "BRUNEI DARUSSALAM" if fm_country=="BRUNEI"
replace fm_country = "VENEZUELA, BOLIVARIAN REPUBLIC OF" if fm_country=="VENEZUELA"
replace fm_country = "HONG KONG" if fm_country=="HONG KONG SAR - CHINA"
replace fm_country = "Cur\c{c}ao" if fm_country=="CuraçAo"
gen Y = 1
ren snapshot_year year
save temp1.dta, replace

collapse (sum) Y, by(fm_country year)
keep if year>1999
save temp.dta, replace

collapse (sum) Y, by(fm_country)
gsort -Y
keep if _n<=25
keep fm_country
merge 1:m fm_country using temp.dta
replace fm_country = "Rest of the world" if _m==2
collapse (sum) Y, by(fm_country year)
save temp.dta, replace

collapse (sum) Y, by(year)
gen fm_country = "Total"
append using temp.dta
reshape wide Y, i(fm_country) j(year)
save temp.dta, replace

keep fm_country
merge 1:m fm_country using temp1.dta
drop if _m==1
replace fm_country = "Rest of the world" if _m==2
drop _m
keep fm_id fm_country
duplicates drop
gen Y=1
collapse (sum) Total=Y, by(fm_country)
set obs `=_N+1'
replace fm_country = "Total" if Total==.
egen tot = total(Total)
replace Total = tot if Total==.
drop tot
merge 1:1 fm_country using temp.dta
drop _m
gsort -Total
replace fm_country = strproper(fm_country)
gen id = _n
replace id = `=_N+1' if _n==1
sort id
drop id
ren fm_country Country
local yr = 2000
foreach var of varlist Y2000 - Y2022 {
	label var `var' "`yr'"
	local ++yr
}
tostring Y* Total, replace format(%13.0fc) force
order Total, a(Y2022)
label var Total "Total"
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_ESGbyCtryYr", replace) first(varl)
}
**Table OA8: UN PRI Signatories by year
{
import excel using "..\Data_PRI\PRISignatory_20231029.xlsx", clear first locale("locale") 
drop SignatoryCategory
gen date = date(SignatureDate,"DMY")
drop if missing(date)
drop SignatureDate
ren date SignatureDate
format SignatureDate %td
gen year = year(SignatureDate)
gen CountAll = 1
collapse (sum) Count, by(year)
keep if year<=2022
save temp.dta, replace

use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
distinct fm_id
local PEGPs = `r(ndistinct)'
keep if dateUNPRI!=.
gen year = year(dateUNPRI)
gen CountGP = 1
collapse (sum) CountGP, by(year)
keep if year<=2022
merge 1:1 year using temp.dta
drop _m
gen PercentGP = CountGP/`PEGPs'*100
gen cumulPercentGP = sum(PercentGP)
replace cumulPercentGP = round(cumulPercentGP,0.1)
drop PercentGP
save temp.dta, replace

use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id
merge 1:m fm_id using "..\Data_preqin\\LP_GP_map.dta"
keep if _m==3
keep i_ID
duplicates drop
merge 1:m i_ID using "..\Data_preqin\\preqin_LPs.dta"
keep if _m==3
distinct i_ID
local PELPs = `r(ndistinct)'
keep if dateUNPRI!=.
gen year = year(dateUNPRI)
gen CountLP = 1
collapse (sum) CountLP, by(year)
keep if year<=2022
merge 1:1 year using temp.dta
drop _m
gen PercentLP = CountLP/`PELPs'*100
gen cumulPercentLP = sum(PercentLP)
replace cumulPercentLP = round(cumulPercentLP,0.1)
drop PercentLP
order year CountAll CountGP cumulPercentGP CountLP cumulPercentLP
label var CountAll "UN-PRI Signatories"
label var CountGP "PE-Firms"
label var cumulPercentGP "Percent GP"
label var CountLP "Limited Partners"
label var cumulPercentLP "Percent LP"
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_PRISignatory", replace) first(varl)
erase temp.dta
}
**Table OA9: ESG Scores by Industry
{
use "..\Data_preqin\\preqin_dealsBuyout.dta", clear
keep d_firmID d_firmPrimaryIndustry
duplicates drop
merge 1:m d_firmID using listOfBOGrowthDeals.dta
keep if _m==3
drop _m
keep d_firmID d_firmPrimaryIndustry d_investorID d_dealYear
duplicates drop
ren (d_investorID d_dealYear) (fm_id snapshot_year)
merge m:1 fm_id snapshot_year using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta"
keep if _m==3
drop _m
gen NoofObs = 1
replace dict_esg2 = exp(dict_esg2)-1
collapse (mean) dict_esg2 (sum) NoofObs, by(d_firmPrimaryIndustry)
drop if missing(d_firmPrimaryIndustry)
replace d_firmPrimaryIndustry = strproper(d_firmPrimaryIndustry)
replace dict_esg2 = round(dict_esg2,0.001)
label var d_firmPrimaryIndustry "Primary Industry"
label var dict_esg2 "ESG Ratio"
label var NoofObs "No. of Observations"
gsort -dict_esg2
replace d_firmPrimaryIndustry = subinstr(d_firmPrimaryIndustry," It", " IT",.)
replace d_firmPrimaryIndustry = subinstr(d_firmPrimaryIndustry," It ", " IT ",.)
replace d_firmPrimaryIndustry = subinstr(d_firmPrimaryIndustry,"It ", "IT ",.)
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_ESGbyIndustry", replace) first(varl)
}
**Figure OA7: ESG Disclosures and PE Firm Characteristics - Additional Firm Characteristics
{
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
keep if inlist(fm_pe_mainFirmStrategy,"BUYOUT","GROWTH")
keep fm_id fm_pe_mainFirmStrategy fm_log_total_AUM_USD
replace fm_pe_mainFirmStrategy = strproper(fm_pe_mainFirmStrategy)
merge 1:m fm_id using "..\Data_website\Scrapping\ESGmetrics\Final Stata Files\R1_snapshot_data_final.dta", keepus(snapshot_year dict_esg2)
keep if _m==3
drop _m
ren snapshot_year year
replace dict_esg = exp(dict_esg2)-1
save temp.dta, replace

//PE Firm Main Strategy
use temp.dta, clear
keep if inlist(year,2002,2012,2022)
drop if fm_pe_mainFirmStrategy==""
count if fm_pe_mainFirmStrategy=="Buyout"
local buy = `r(N)'
local buyfmt: di %5.0fc `buy'
count if fm_pe_mainFirmStrategy=="Growth"
local gro = `r(N)'
local grofmt: di %5.0fc `gro'
collapse (mean) dict_esg2, by(fm_pe_mainFirmStrategy year)
*gen strat = cond(fm_pe_mainFirmStrategy=="Buyout",1,cond(fm_pe_mainFirmStrategy=="Growth",2,cond(fm_pe_mainFirmStrategy=="Venture Capital",3,4)))
gen strat = cond(fm_pe_mainFirmStrategy=="Buyout",1,2)
sort year strat
gen id = _n
replace id = id + 1 if year==2012
replace id = id + 2 if year==2022
twoway (bar dict_esg2 id if inlist(id,1,4,7), color(gs0) barw(0.8) lp(solid) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,2,5,8), col(gs3) barw(0.8) lp(dash) lc(gs0) lw(medium)), ylabel(0(10)70, labsize(small) angle(horiz) nogrid) legend(order(1 "Buyout (`buyfmt')" 2 "Growth (`grofmt')") size(small) rows(1) cols(4) symx(8) symy(4)) ytitle("ESG Ratio", size(small)) xlabel(0 " " 1.5 "2002" 4.5 "2012" 7.5 "2022" 9 " ", labsize(small)) graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\OA_R2_fig_FirmCharStrategy.pdf", as(pdf) name("Graph") replace
graph close

//PE Firm Size
use temp.dta, clear
egen sizeQuintile = xtile(fm_log_total_AUM_USD), nq(5)
drop if sizeQuintile==.
keep if inlist(year,2002,2012,2022)
count if sizeQuintile==1
local one = `r(N)'
local onefmt: di %3.0fc `one'
count if sizeQuintile==2
local two = `r(N)'
local twofmt: di %3.0fc `two'
count if sizeQuintile==3
local thr = `r(N)'
local thrfmt: di %3.0fc `thr'
count if sizeQuintile==4
local four = `r(N)'
local fourfmt: di %3.0fc `four'
count if sizeQuintile==5
local five = `r(N)'
local fivefmt: di %3.0fc `five'
collapse (mean) dict_esg2, by(sizeQuintile year)
gsort year -sizeQuintile
gen id = _n
replace id = id + 1 if year==2012
replace id = id + 2 if year==2022
twoway (bar dict_esg2 id if inlist(id,1,7,13), color(gs0) barw(0.8) lp(solid) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,2,8,14), col(gs3) barw(0.8) lp(dash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,3,9,15), color(gs6) barw(0.8) lp(shortdash) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,4,10,16), color(gs9) barw(0.8) lp(dash_dot) lc(gs0) lw(medium))||(bar dict_esg2 id if inlist(id,5,11,17), color(gs12) barw(0.8) lp(dot) lc(gs0) lw(medthick)), ylabel(0(10)70, labsize(small) angle(horiz) nogrid) legend(order(1 "Highest Quintile (`fivefmt')" 2 "Quintile 4 (`fourfmt')" 3 "Quintile 3 (`thrfmt')" 4 "Quintile 2 (`twofmt')" 5 "Lowest Quintile (`onefmt')") size(small) rows(2) cols(3) symx(8) symy(4)) ytitle("ESG Ratio", size(small)) xlabel(0 " " 3 "2002" 9 "2012" 15 "2022" 18 " ", labsize(small)) graphregion(color(white)) xtitle("Year", size(small))
graph export "..\..\Output\OA_R2_fig_FirmCharSize.pdf", as(pdf) name("Graph") replace
graph close
}
**Table OA10: Publicly Listed PE Firm ESG disclosures
{
use IPO.dta, clear

eststo clear
reghdfe dict_esg2 postIPO logLength positive valuation, absorb(snapshot_year fm_id) cluster(ctry_yr) //1,542 - enter this manually in the table
eststo P1: stackedev dict_esg2 postIPO, time(snapshot_year) cohort(yearIPO) never_treat(private) unit_fe(fm_id) clust_unit(ctry_yr) covariates(logLength positive valuation)

estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local firm_ctrl "Yes", replace
estadd local list_ctrl "No", replace

***Responses of Public Firms to PRI Investor Presense and Mandatory ESG Regulation
//PRI Investor Presence
use "..\Data_preqin\\preqin_fund_mgr.dta", clear
gen public = cond(fm_listed=="YES",1,0)
keep fm_id public
merge 1:m fm_id using LPPRI.dta
keep if _m==3

egen double yearPublic = group(public year)
gen publicPRI = PRIInvestorPresent * public
gen public_logPRIInvestors = public*logPRIInvestors
label var publicPRI "Post PRI Investor Present * Listed PE Firm"
label var public_logPRIInvestors "Log. PRI Investors * Listed PE Firm"
save temp.dta, replace

reghdfe dict_esg2 publicPRI PRIInvestorPresent public#c.(logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament), absorb(fm_id year) cluster(ctry_yr) //16562 - enter this manually in the table
eststo P2: stackedev dict_esg2 publicPRI PRIInvestorPresent, cohort(firstTreatYear) time(year) never_treat(neverTreated) unit_fe(fm_id) clust_unit(ctry_yr) covariates(public#c.(logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament))
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local firm_ctrl "Yes", replace
estadd local list_ctrl "Yes", replace

use temp.dta, clear
eststo P3: reghdfe dict_esg2 public_logPRIInvestors logPRIInvestors public#c.(logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament), absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local firm_ctrl "Yes", replace
estadd local list_ctrl "Yes", replace

estout P* using  ".\ta.txt", ///
	drop (_cons *.public*) stats(N r2_a firm_fe year_fe firm_ctrl list_ctrl, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "PE Firm FE" "Year FE" "PE Firm Controls" "Controls * Listed FE")) ///
	cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_IPO", replace)
}
**Table OA11: Voluntary Disclosure of Public Firms
{
clear all
gen Variable = ""
gen N = .
gen Mean = .
gen SD = .
gen P5 = .
gen Median = .
gen P95 = .
save voluntaryDisclosures.dta, replace

use "..\Data_IPO\VoluntaryDisclosuresAnn.dta", clear
foreach var of varlist dq txtFileSize {
	use "..\Data_IPO\VoluntaryDisclosuresAnn.dta", clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use voluntaryDisclosures.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save voluntaryDisclosures.dta, replace
}

use "..\Data_IPO\VoluntaryDisclosuresQtr.dta", clear
foreach var of varlist val_1 wordCount {
	use "..\Data_IPO\VoluntaryDisclosuresQtr.dta", clear
	keep if `var'!=.
	local lab: variable label `var'
	local Variable = "`lab'"
	summ `var', detail
	local N = `r(N)'
	local Mean = `r(mean)'
	local SD = `r(sd)'
	local P5 = `r(p5)'
	local Median = `r(p50)'
	local P95 = `r(p95)'
	
	use voluntaryDisclosures.dta, clear
	set obs `=_N+1'
	replace Variable = "`Variable'" if _n==_N
	replace N = `N' if _n==_N
	replace Mean = `Mean' if _n==_N
	replace SD = `SD' if _n==_N
	replace P5 = `P5' if _n==_N
	replace Median = `Median' if _n==_N
	replace P95 = `P95' if _n==_N
	save voluntaryDisclosures.dta, replace
}
format Mean SD P5 Median P95 %15.3f
format N %10.0fc
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_voluntaryDisc", replace) first(var)
}
**Table OA12: Examining the R2 from different fixed effects regressions of Log. ESG Ratio
{
use LPPRI.dta, clear
local controls1 = `" logLength positive valuation "'
local controls2 = `" logLength positive valuation log_GDP GDPGrowth log_population laborForceParticipation womenSeatsParliament "'
reghdfe dict_esg2 logPRIInvestors `controls2' if forReg==1, absorb(fm_id wordDecileYear ctry_yr) cluster(ctry_yr)
gen byte sample2keep = e(sample)
keep if sample2keep==1

eststo clear
eststo P1: reghdfe dict_esg2, absorb(fm_id year) cluster(ctry_yr) savefe
estadd local pri "No", replace
estadd local ctrl "No", replace
qui distinct __hdfe1__
local j = `r(ndistinct)'
qui distinct __hdfe2__
local j= `j'+ `r(ndistinct)'
local i = `:word count `controls2''
local j= `i'+`j'
estadd local cntfe "`j'", replace
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace

eststo P2: reghdfe dict_esg2 logPRIInvestors, absorb(fm_id year) cluster(ctry_yr) savefe
estadd local pri "Yes", replace
estadd local ctrl "No", replace
qui distinct __hdfe1__
local j = `r(ndistinct)'
qui distinct __hdfe2__
local j= `j'+ `r(ndistinct)'
local i = `:word count `controls2''
local j= 1+`i'+`j'
estadd local cntfe "`j'", replace
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace

eststo P3: reghdfe dict_esg2 logPRIInvestors, noabsorb cluster(ctry_yr) savefe
estadd local pri "Yes", replace
estadd local ctrl "No", replace
estadd local cntfe "1", replace
estadd local firm_fe "No", replace
estadd local year_fe "No", replace
estadd local quintyr_fe "No", replace

eststo P4: reghdfe dict_esg2 logPRIInvestors, absorb(year) cluster(ctry_yr) savefe
estadd local pri "Yes", replace
estadd local ctrl "No", replace
qui distinct __hdfe1__
local j = `r(ndistinct)'
local j= 1+`j'
estadd local cntfe "`j'", replace
estadd local firm_fe "No", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace

eststo P5: reghdfe dict_esg2 logPRIInvestors, absorb(fm_id year) cluster(ctry_yr) savefe
estadd local pri "Yes", replace
estadd local ctrl "No", replace
qui distinct __hdfe1__
local j = `r(ndistinct)'
qui distinct __hdfe2__
local j= `j'+`r(ndistinct)'
local j= 1+`j'
estadd local cntfe "`j'", replace
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace

eststo P6: reghdfe dict_esg2 logPRIInvestors `controls2', absorb(fm_id year) cluster(ctry_yr) savefe
estadd local pri "Yes", replace
estadd local ctrl "Yes", replace
qui distinct __hdfe1__
local j = `r(ndistinct)'
qui distinct __hdfe2__
local j= `j'+`r(ndistinct)'
local i = `:word count `controls1''
local j= 1+`i'+`j'
estadd local cntfe "`j'", replace
estadd local firm_fe "Yes", replace
estadd local year_fe "Yes", replace
estadd local quintyr_fe "No", replace

eststo P7: reghdfe dict_esg2 logPRIInvestors `controls2', absorb(fm_id wordDecileYear) cluster(ctry_yr) savefe
estadd local pri "Yes", replace
estadd local ctrl "Yes", replace
qui distinct __hdfe1__
local j = `r(ndistinct)'
qui distinct __hdfe2__
local j= `j'+`r(ndistinct)'
local i = `:word count `controls1''
local j= 1+`i'+`j'
estadd local cntfe "`j'", replace
estadd local firm_fe "Yes", replace
estadd local year_fe "No", replace
estadd local quintyr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a pri cntfe ctrl year_fe firm_fe quintyr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "Log. PRI Investors" "Number of Predictors" "Controls" "Year FE" "PE Firm FE" "Size Group-Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_R2s", replace)
}
**Table OA13: Table UNPRI for PE firms that are part of the Outcomes sample
{
use LPPRI.dta, clear

eststo P1: reghdfe dict_esg2 logPRIInvestors if forReg==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local yr_fe "Yes", replace
eststo P2: reghdfe dict_esg2 logPRIInvestors if forReg==1 & tri_sample==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local yr_fe "Yes", replace
eststo P3: reghdfe dict_esg2 logPRIInvestors if forReg==1 & trucost_sample==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local yr_fe "Yes", replace
eststo P4: reghdfe dict_esg2 logPRIInvestors if forReg==1 & osha_sample==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local yr_fe "Yes", replace
eststo P5: reghdfe dict_esg2 logPRIInvestors if forReg==1 & reprisk_sample==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local yr_fe "Yes", replace
eststo P6: reghdfe dict_esg2 logPRIInvestors if forReg==1 & anyOutcomeSample==1, absorb(fm_id year) cluster(ctry_yr)
estadd local firm_fe "Yes", replace
estadd local yr_fe "Yes", replace

estout P* using  ".\ta.txt", ///
drop( _cons)  stats(N r2_a firm_fe yr_fe, fmt(%9.0f %9.3f) labels("Observations" "Adj. R2" "PE Firm FE" "Year FE")) ///
cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.1 ** 0.05 *** 0.01) mlabels(,dep) numbers replace label

import delimited using ".\ta.txt", clear
export excel using "..\..\Output\R2_Results.xlsx", sheet("OA_taRaw_investorsPRI_outSample", replace)
}

log closelog using ".\logfile_hedgefund", replace

set more off
clear all

import excel using ".\Data\Data_HedgeFunds\Eikon_HedgeFundsOnlyUS_20230507.xlsx", clear first
ren (FundTNAMilUSDollar D) (TNADate TNAValue)
drop in 1
gen USDomicile=1
save ".\Data\Data_HedgeFunds\hedgeFunds.dta", replace

import excel using ".\Data\Data_HedgeFunds\Eikon_HedgeFundsNotUS_20230507.xlsx", clear first
ren (FundTNAMilUSDollar D) (TNADate TNAValue)
drop in 1
gen USDomicile=0
append using ".\Data\Data_HedgeFunds\hedgeFunds.dta"
save ".\Data\Data_HedgeFunds\hedgeFunds.dta", replace

gen tDate = date(TNADate,"MDY")
drop TNADate
ren tDate TNADate
format TNADate %td
destring TNAValue, force replace
keep LipperRIC AssetName TNAValue TNADate FundManagementCompanyWebSite USDomicile
order LipperRIC USDomicile AssetName TNAValue TNADate FundManagementCompanyWebSite
replace FundManagementCompanyWebSite = lower(FundManagementCompanyWebSite)
replace FundManagementCompanyWebSite = stritrim(FundManagementCompanyWebSite)
replace FundManagementCompanyWebSite = "" if FundManagementCompanyWebSite=="no website available"
replace FundManagementCompanyWebSite = "" if FundManagementCompanyWebSite=="no website available."
replace FundManagementCompanyWebSite = "" if FundManagementCompanyWebSite=="notavailable"
replace FundManagementCompanyWebSite = "" if FundManagementCompanyWebSite=="not available"
replace FundManagementCompanyWebSite = "" if FundManagementCompanyWebSite=="nowebsiteavailable"
drop if FundManagementCompanyWebSite==""

ren FundManagementCompanyWebSite website
replace website = regexr(website,"^http://","")
replace website = regexr(website,"^https://","")
replace website = regexr(website,"^www\.","")
forvalues i = 1/3 {
	replace website = regexr(website,"#$","")
	replace website = regexr(website,"/$","")
}
replace website = strtrim(website)
replace website = lower(website)
replace website = "http://" + website if website!=""
save ".\Data\Data_HedgeFunds\hedgeFunds.dta", replace

keep if USDomicile==1
keep website
duplicates drop
ren website fm_website
merge 1:m fm_website using ".\Data\Data_preqin\preqin_fund_mgr.dta"
keep if _m==1
keep fm_website
sort fm_website
gen fm_id = _n
tostring fm_id, replace
replace fm_id = "H"+fm_id
order fm_id fm_website
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\hedgeFunds.txt", replace

log closelog using "logfile_osha", replace

set more off
clear all

**Violation Tracker based OSHA data**
{
//Accidents
{
import delimited using ".\Data\Data_OSHA\osha_accident_20230417\osha_accident.csv", clear varn(1) stringc(_all)
gen teventDate = substr(event_date,1,10)
gen double eventTime = clock(event_date,"YMDhms")
gen eventDate = date(teventDate,"YMD")
format eventDate %td
format eventTime %tc
destring summary_nr report_id, replace
order report_id summary_nr eventDate eventTime
drop event_date event_time load_dt teventDate abstract_text
replace event_desc = strproper(event_desc)
save ".\Data\Data_OSHA\osha_accident.dta", replace
}
//Accident abstract
{
local files: dir ".\Data\Data_OSHA\osha_accident_abstract_20230417\" file "*.csv", respectcase
local i = 1
foreach f of local files {
	qui import delimited using ".\Data\Data_OSHA\osha_accident_abstract_20230417\\`f'", clear varn(1) stringc(_all)
	if `i'==1 {
		qui save ".\Data\Data_OSHA\osha_accident_abstract.dta", replace
		local ++i
	}
	else {
		qui append using ".\Data\Data_OSHA\osha_accident_abstract.dta"
		qui save ".\Data\Data_OSHA\osha_accident_abstract.dta", replace
	}
	di "`f'"
}
drop load_dt
destring line_nr, replace
summ line_nr
local maxVal = `r(max)'
reshape wide abstract_text, i(summary_nr) j(line_nr)
gen abstract_text = ""
forvalues i = 1/`maxVal' {
	replace abstract_text = abstract_text + abstract_text`i'
	drop abstract_text`i'
}
replace abstract_text = strtrim(abstract_text)
replace abstract_text = stritrim(abstract_text)
replace abstract_text = strproper(abstract_text)
drop if abstract_text==""
destring summary_nr, replace
save ".\Data\Data_OSHA\osha_accident_abstract.dta", replace

merge 1:1 summary_nr using ".\Data\Data_OSHA\osha_accident.dta"
drop _m
save ".\Data\Data_OSHA\osha_accident.dta", replace
erase ".\Data\Data_OSHA\osha_accident_abstract.dta"
}
//Accident injury
{
import delimited using ".\Data\Data_OSHA\osha_accident_injury_20230417\osha_accident_injury.csv", clear varn(1) stringc(_all)
destring summary_nr rel_insp_nr, replace
drop load_dt
save ".\Data\Data_OSHA\osha_accident_injury.dta", replace
}
//Inspection
{
local files: dir ".\Data\Data_OSHA\osha_inspection_20230417\" file "*.csv", respectcase
local i = 1
foreach f of local files {
	qui import delimited using ".\Data\Data_OSHA\osha_inspection_20230417\\`f'", clear varn(1) stringc(_all)
	if `i'==1 {
		qui save ".\Data\Data_OSHA\osha_inspection.dta", replace
		local ++i
	}
	else {
		qui append using ".\Data\Data_OSHA\osha_inspection.dta"
		qui save ".\Data\Data_OSHA\osha_inspection.dta", replace
	}
	di "`f'"
}
destring activity_nr reporting_id nr_in_estab, replace
drop state_flag ld_dt
foreach var of varlist open_date close_conf_date close_case_date case_mod_date {
	gen t`var' = date(`var',"YMD")
	drop `var'
	ren t`var' `var'
	format `var' %td
}
gen year = year(open_date)

foreach var of varlist estab_name site_address site_city site_state mail_street mail_city mail_state {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
}

foreach var of varlist safety_manuf safety_const safety_marit health_manuf health_const health_marit migrant {
	replace `var' = cond(`var'=="X","YES","NO")
}
replace why_no_insp = cond(why_no_insp=="A","Not Found",cond(why_no_insp=="B","Out of Business",cond(why_no_insp=="C","Process Inactive",cond(why_no_insp=="D","10 or Fewer Emp",cond(why_no_insp=="E","Denied Entry",cond(why_no_insp=="F","SIC not on PG",cond(why_no_insp=="G","Exempt Voluntary",cond(why_no_insp=="I","Other",cond(why_no_insp=="J","Employer Exempted By Appropriation Act",cond(why_no_insp=="H","NonExempt Consult",""))))))))))
replace why_no_insp = upper(why_no_insp)
replace adv_notice = cond(adv_notice=="Y","YES",cond(adv_notice=="N","NO",""))
replace safety_hlth = cond(safety_hlth=="S","SAFETY",cond(safety_hlth=="H","HEALTH",""))
replace owner_type = cond(owner_type=="A","PRIVATE",cond(owner_type=="B","LOCAL GOVT.",cond(owner_type=="C","STATE GOVT.",cond(owner_type=="D","FEDERAL GOVT.",""))))
replace union_status = cond(inlist(union_status,"Y","U","A"),"YES","NO")
replace insp_scope = cond(insp_scope=="A","COMPLETE",cond(insp_scope=="B","PARTIAL",cond(insp_scope=="C","RECORDS",cond(insp_scope=="D","NO INSPECTION",""))))
replace insp_type = cond(insp_type=="A","ACCIDENT",cond(insp_type=="B","COMPLAINT",cond(insp_type=="C","REFERRAL",cond(insp_type=="D","MONITORING",cond(insp_type=="E","VARIANCE",cond(insp_type=="F","FOLLOW UP",cond(insp_type=="G","UNPROG RELATED",cond(insp_type=="H","PLANNED",cond(insp_type=="I","PROG RELATED",cond(insp_type=="J","UNPROG OTHER",cond(insp_type=="K","PROG OTHER",cond(insp_type=="L","OTHER",cond(insp_type=="M","FAT/CAT","")))))))))))))
sort reporting_id open_date activity_nr

order activity_nr reporting_id year open_date close_conf_date close_case_date case_mod_date host_est_key estab_name site_address site_city site_state site_zip mail_street mail_city mail_state mail_zip sic_code naics_code nr_in_estab union_status insp_type insp_scope why_no_insp owner_type owner_code safety_hlth adv_notice safety_manuf safety_const safety_marit health_manuf health_const health_marit migrant

label var activity_nr "Activity Number"
label var reporting_id "OSHA office"
label var year "Year"
label var open_date "Inspection open date"
label var close_conf_date "Ending date of onsite part of inspection"
label var close_case_date "Ending date of inspection"
label var case_mod_date "Case modification date"
label var host_est_key "Internal establishment key"
label var estab_name "Establishment name"
label var site_address "Site address"
label var site_city "Site city"
label var site_state "Site state"
label var site_zip "Site zip"
label var mail_street "Mailing address"
label var mail_city "Mailing city"
label var mail_state "Mailing state"
label var mail_zip "Mailing zip"
label var sic_code "SIC code"
label var naics_code "NAICS code"
label var nr_in_estab "No of employees in establishment"
label var union_status "Union represenation during inspection"
label var insp_type "Inspection type"
label var insp_scope "Inspection scope"
label var why_no_insp "Reason for no inspection"
label var owner_type "Owner type"
label var owner_code "Owner code"
label var safety_hlth "Inspection focus - Safety/Health "
label var adv_notice "Advance notice for inspection"
label var safety_manuf "Safety planning guide - manufacturing"
label var safety_const "Safety planning guide - construction"
label var safety_marit "Safety planning guide - maritime"
label var health_manuf "Health planning guide - manufacturing"
label var health_const "Health planning guide - construction"
label var health_marit "Health planning guide - maritime"
label var migrant "Migrant labor inspection"

keep if year>=1999
save ".\Data\Data_OSHA\osha_inspection.dta", replace
}
//Violations
{
local files: dir ".\Data\Data_OSHA\osha_violation_20230417\" file "*.csv", respectcase
local i = 1
foreach f of local files {
	qui import delimited using ".\Data\Data_OSHA\osha_violation_20230417\\`f'", clear varn(1) stringc(_all)
	if `i'==1 {
		qui save ".\Data\Data_OSHA\osha_violation.dta", replace
		local ++i
	}
	else {
		qui append using ".\Data\Data_OSHA\osha_violation.dta"
		qui save ".\Data\Data_OSHA\osha_violation.dta", replace
	}
	di "`f'"
}
destring activity_nr citation_id, replace
foreach var of varlist issuance_date abate_date contest_date final_order_date initial_penalty current_penalty fta_issuance_date fta_contest_date fta_final_order_date {
	gen t`var' = date(`var',"YMD")
	drop `var'
	ren t`var' `var'
	format `var' %td
}
replace viol_type = cond(viol_type=="O","Other",cond(viol_type=="P","P",cond(viol_type=="R","Repeat",cond(viol_type=="S","Serious",cond(viol_type=="U","U",cond(viol_type=="W","Willful",""))))))
gen accident = cond(strpos(rec,"A"),1,0)
gen complaint = cond(strpos(rec,"C"),1,0)
gen imminentDanger = cond(strpos(rec,"I"),1,0)
gen referral = cond(strpos(rec,"R"),1,0)
gen variance = cond(strpos(rec,"V"),1,0)
drop rec load_dt
destring nr_exposed nr_instances current_penalty initial_penalty gravity fta_penalty, replace
order activity_nr citation_id issuance_date abate_date contest_date final_order_date delete_flag standard viol_type gravity nr_exposed nr_instances hazcat hazsub1 hazsub2 hazsub3 hazsub4 hazsub5 emphasis fta_insp_nr fta_issuance_date fta_contest_date fta_final_order_date fta_penalty

label var activity_nr "Activity number"
label var citation_id "Unique violation identifier"
label var issuance_date "Citation issuance date"
label var abate_date "Date by which violation must be corrected"
label var contest_date "Date violation contested by employer"
label var delete_flag "Deleted due to settlement/judicial actions"
label var standard "OSHA standard violated"
label var initial_penalty "Initial penalty"
label var current_penalty "Current penalty assessed"
label var viol_type "Violation type"
label var gravity "Level of gravity for serious violation"
label var nr_exposed "No of employees exposed"
label var nr_instances "No of instances"
label var fta_insp_nr "FTA inspection number"
label var final_order_date "Final order date"
label var fta_issuance_date "FTA issuance date" //FTA- Failure to abate
label var fta_contest_date "FTA contested date"
label var fta_final_order_date "FTA final order date"
label var fta_penalty "FTA penalty"
label var hazcat "Hazard Category"
label var hazsub1 "Hazardous substance code 1"
label var hazsub2 "Hazardous substance code 2"
label var hazsub3 "Hazardous substance code 3"
label var hazsub4 "Hazardous substance code 4"
label var hazsub5 "Hazardous substance code 5"

sort activity_nr citation_id
save ".\Data\Data_OSHA\osha_violation.dta", replace
}
//Combining inspections, violations and accidents
{
use ".\Data\Data_OSHA\osha_inspection.dta", clear
drop if strpos(estab_name,"UNKNOWN")
drop if estab_name=="U.S. POSTAL SERVICE"
drop if estab_name=="LOCATING JOBSITE"
keep if inrange(year,2000,2022)
keep if owner_type=="PRIVATE"
gen address = site_address + " " + site_city + " " + site_state + " " + site_zip
replace address = strtrim(address)
replace address = stritrim(address)
drop if missing(address)
gen yearInspection = year(open_date)
gen countInspectionsPlanned = cond(insp_type=="PLANNED",1,0)
gen countInspectionsComplaint = cond(insp_type=="COMPLAINT",1,0)
keep activity_nr yearInspection host_est_key estab_name nr_in_estab address site_state site_city naics_code countInspectionsPlanned countInspectionsComplaint 
replace host_est_key="" if host_est_key=="HOST_EST_KEY_VALUE"
save ".\Data\Data_OSHA\osha_inspections_final.dta", replace

use ".\Data\Data_OSHA\osha_violation.dta", clear
drop if delete_flag=="X"
gen violation = 1
gen yearViolation = year(issuance_date)
keep if inrange(yearViolation,2000,2022)
collapse (sum) violation accident, by(activity_nr yearViolation)
merge m:1 activity_nr using ".\Data\Data_OSHA\osha_inspections_final.dta", keepus(activity_nr)
keep if _m==3
drop _m
sort activity_nr yearViolation
save ".\Data\Data_OSHA\osha_violations_final.dta", replace

use ".\Data\Data_OSHA\osha_accident.dta", clear
keep summary_nr eventDate fatality
merge 1:m summary_nr using ".\Data\Data_OSHA\osha_accident_injury.dta"
keep if _m==3
keep summary_nr eventDate fatality rel_insp_nr degree_of_inj
ren rel_insp_nr activity_nr
gen yearAccident = year(eventDate)
gen hospitalization = cond(degree_of_inj=="2",1,0)
collapse (sum) hospitalization, by(activity_nr yearAccident)
keep if inrange(yearAccident,2000,2022)
merge m:1 activity_nr using ".\Data\Data_OSHA\osha_inspections_final.dta", keepus(activity_nr)
keep if _m==3
drop _m
save ".\Data\Data_OSHA\osha_accidents_final.dta", replace
}
}
**Matching Names**
{
**Creating unique OSHA establishment identifiers and relevant panels
use ".\Data\Data_OSHA\osha_inspections_final.dta", clear
keep host_est_key estab_name address
duplicates drop
save temp.dta, replace

//First I construct a unique identifier for each establishment because almost 42% of the establishments do not have an identifier.
//In order to do this I make use of the establishment address which is unique. 
//But there are some cases where the same establishment has multiple addresses. I encode all the multiple addresses as belonging to the same establishment.
//In other cases slightly differently names establishments have the same address - these are the same entities.
egen double addressID = group(address)
bysort host_est_key (addressID): replace addressID = addressID[1] if host_est_key!=""
save temp.dta, replace
keep addressID 
duplicates drop
sort addressID 
gen OSHAID = _n
merge 1:m addressID using temp.dta
keep OSHAID host_est_key estab_name address
save temp.dta, replace

merge 1:m estab_name host_est_key address using ".\Data\Data_OSHA\osha_inspections_final.dta"
keep if _m==3
drop _m
replace site_state = "MD" if estab_name=="MP INDUSTRIAL COATINGS, INC."
replace site_state = "DC" if estab_name=="CAULKING SERVICES, INC"
save ".\Data\Data_OSHA\osha_inspections_final.dta", replace

use ".\Data\Data_OSHA\osha_inspections_final.dta", clear
keep OSHAID activity_nr nr_in_estab
merge 1:m activity_nr using ".\Data\Data_OSHA\osha_violations_final.dta"
keep if _m==3
collapse (sum) violation (max) nr_in_estab, by(OSHAID yearViolation)
bysort OSHAID: egen totalViol = total(violation)
drop if totalViol==0
drop totalViol
save ".\Data\Data_OSHA\oshaPanel_violations.dta", replace

use ".\Data\Data_OSHA\osha_inspections_final.dta", clear
keep OSHAID activity_nr nr_in_estab
merge 1:m activity_nr using ".\Data\Data_OSHA\osha_accidents_final.dta"
keep if _m==3
collapse (sum) hospitalization (max) nr_in_estab, by(OSHAID yearAccident)
gen injury = hospitalization!=0
bysort OSHAID: egen totalInjury = total(injury)
drop if totalInjury==0
drop totalInjury injury
save ".\Data\Data_OSHA\oshaPanel_accidents.dta", replace

use ".\Data\Data_OSHA\osha_inspections_final.dta", clear
collapse (max) nr_in_estab (sum) countInspectionsPlanned, by(OSHAID yearInspection)
bysort OSHAID: egen totalInspections = total(countInspectionsPlanned)
drop if totalInspections==0
drop totalInspections
save ".\Data\Data_OSHA\oshaPanel_inspectionsPlanned.dta", replace

use ".\Data\Data_OSHA\osha_inspections_final.dta", clear
collapse (max) nr_in_estab (sum) countInspectionsComplaint, by(OSHAID yearInspection)
bysort OSHAID: egen totalInspections = total(countInspectionsComplaint)
drop if totalInspections==0
drop totalInspections
save ".\Data\Data_OSHA\oshaPanel_inspectionsComplaint.dta", replace

use ".\Data\Data_OSHA\osha_inspections_final.dta", clear
egen countInspections = rowtotal(countInspectionsComplaint countInspectionsPlanned)
collapse (max) nr_in_estab (sum) countInspections, by(OSHAID yearInspection)
bysort OSHAID: egen totalInspections = total(countInspections)
drop if totalInspections==0
drop totalInspections
save ".\Data\Data_OSHA\oshaPanel_inspections.dta", replace

use ".\Data\Data_OSHA\oshaPanel_inspectionsPlanned.dta", clear
use ".\Data\Data_OSHA\oshaPanel_inspectionsComplaint.dta", clear
append using ".\Data\Data_OSHA\oshaPanel_violations.dta"
append using ".\Data\Data_OSHA\oshaPanel_accidents.dta"
keep OSHAID
duplicates drop
merge 1:m OSHAID using temp.dta
keep if _m==3
drop _m

gen cleanedName = estab_name
replace cleanedName = upper(cleanedName)
local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace cleanedName = subinstr(cleanedName,"`a'","a",.)
}
foreach e of local specialEs {
	replace cleanedName = subinstr(cleanedName,"`e'","e",.)
}
foreach i of local specialIs {
	replace cleanedName = subinstr(cleanedName,"`i'","i",.)
}
foreach o of local specialOs {
	replace cleanedName = subinstr(cleanedName,"`o'","o",.)
}
foreach u of local specialUs {
	replace cleanedName = subinstr(cleanedName,"`u'","u",.)
}
foreach y of local specialYs {
	replace cleanedName = subinstr(cleanedName,"`y'","y",.)
}
replace cleanedName = subinstr(cleanedName,"ñ","n",.)
replace cleanedName = subinstr(cleanedName,"Ñ","n",.)
replace cleanedName = subinstr(cleanedName,"æ","ae",.)
replace cleanedName = subinstr(cleanedName,"Æ","ae",.)
replace cleanedName = subinstr(cleanedName,"Œ","ce",.)
replace cleanedName = subinstr(cleanedName,"œ","ce",.)
replace cleanedName = subinstr(cleanedName,"Ç","c",.)
replace cleanedName = subinstr(cleanedName,"ç","c",.)
replace cleanedName = usubinstr(cleanedName,"ž","z",.)

replace cleanedName = subinstr(cleanedName,".","",.)
replace cleanedName = subinstr(cleanedName,",","",.)
replace cleanedName = subinstr(cleanedName,"-","",.)
replace cleanedName = subinstr(cleanedName,"/","",.)
replace cleanedName = subinstr(cleanedName,"'","",.)
replace cleanedName = subinstr(cleanedName,"!","",.)
replace cleanedName = subinstr(cleanedName,":","",.)
replace cleanedName = subinstr(cleanedName,";","",.)
replace cleanedName = subinstr(cleanedName,"#","",.)
replace cleanedName = subinstr(cleanedName,"*","",.)
replace cleanedName = subinstr(cleanedName,"@","",.)
replace cleanedName = subinstr(cleanedName,"_","",.)
replace cleanedName = subinstr(cleanedName,"|","",.)
replace cleanedName = subinstr(cleanedName,"$","",.)
replace cleanedName = subinstr(cleanedName,"\","",.)
replace cleanedName = subinstr(cleanedName,"+","",.)
replace cleanedName = usubinstr(cleanedName,"¿","",.)

replace cleanedName = subinstr(cleanedName,"&"," & ",.)
replace cleanedName  = subinstr(cleanedName ," AND "," & ",.)

forvalues i = 1/3 {
	replace cleanedName  = regexr(cleanedName,"PRIVATE","PVT")
	replace cleanedName  = regexr(cleanedName,"LIMITED","LTD")
	replace cleanedName  = regexr(cleanedName,"COMPANY","CO")
	replace cleanedName  = regexr(cleanedName,"INCORPORATED","INC")
	replace cleanedName  = regexr(cleanedName,"PTY","PVT")
	replace cleanedName  = regexr(cleanedName,"CORPORATION","CORP")
	replace cleanedName  = regexr(cleanedName ,"L L C","LLC")
	replace cleanedName  = regexr(cleanedName," INTL "," INTERNATIONAL ")
	replace cleanedName  = regexr(cleanedName," COS "," CO ")
	replace cleanedName  = regexr(cleanedName," COS$"," CO$")
	replace cleanedName  = regexr(cleanedName," S A$"," SA")
	replace cleanedName  = regexr(cleanedName," S C$"," SC")
	replace cleanedName  = regexr(cleanedName," P C$"," PC")
	replace cleanedName  = regexr(cleanedName," N V$"," NV")
	replace cleanedName  = regexr(cleanedName," SA RL$"," SARL")
}

replace cleanedName  = subinstr(cleanedName ,"SERVICES","SERVICE",.)
replace cleanedName  = subinstr(cleanedName ,"SYSTEMS","SYSTEM",.)
replace cleanedName  = subinstr(cleanedName ,"HOLDINGS","HOLDING",.)
replace cleanedName  = subinstr(cleanedName ,"SOLUTIONS","SOLUTION",.)
replace cleanedName  = subinstr(cleanedName ,"PRODUCTS","PRODUCT",.)
replace cleanedName  = subinstr(cleanedName ,"PARTNERS","PARTNER",.)
replace cleanedName  = subinstr(cleanedName ,"ENTERPRISES","ENTERPRISE",.)
replace cleanedName  = subinstr(cleanedName ,"MATERIALS","MATERIAL",.)
replace cleanedName  = subinstr(cleanedName ,"METALS","METAL",.)
replace cleanedName  = subinstr(cleanedName ,"CHEMICALS","CHEMICAL",.)

replace cleanedName  = strtrim(cleanedName )
replace cleanedName  = stritrim(cleanedName )
replace cleanedName = upper(cleanedName)
duplicates drop
save ".\Data\Data_OSHA\OSHANames.dta", replace

gen cleanedName_noExt = cleanedName

forvalues i = 1/3 {
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"^THE ","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CO$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PVT LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CO LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTDA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LLC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LLP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," INC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PVT$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PTY$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PLC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," INC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CORP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"^OOO ","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," GMBH$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," MBH$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," SARL$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AS$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AB$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AG$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SCA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," NV$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SL$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," BV$","")
	replace cleanedName_noExt  = subinstr(cleanedName_noExt ," OOO$","",.)
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"S$","")
	replace cleanedName_noExt  = strtrim(cleanedName_noExt )
	replace cleanedName_noExt  = stritrim(cleanedName_noExt )
}
gen cleanedName_noSpace = subinstr(cleanedName_noExt," ","",.)
gen cleanedName_noFreq = cleanedName_noSpace

forvalues i = 1/3 {
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"INDUSTRIES","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"HOLDING","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"GROUP","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"PRODUCT","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"INTERNATIONAL","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"TECHNOLOGIES","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"&","",.)	
}
 
save ".\Data\Data_OSHA\OSHANames.dta", replace

//Deal data
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep if d_firmCountry=="UNITED STATES"
keep d_dealID d_firmName d_dealYear d_firmID d_firmCountry d_firmWebsite
duplicates drop
save ".\Data\Data_OSHA\PreqinNames.dta", replace

bysort d_firmID: egen d_firstDealYear = min(d_dealYear)
keep d_firmID d_firmName d_firmCountry d_firmWebsite d_firstDealYear
duplicates drop
bysort d_firmID (d_firmName): keep if _n==_N
save ".\Data\Data_OSHA\PreqinNames.dta", replace

keep d_firmID d_firmName d_firstDealYear  
duplicates drop
save ".\Data\Data_OSHA\PreqinNames.dta", replace

local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace d_firmName = subinstr(d_firmName,"`a'","a",.)
}
foreach e of local specialEs {
	replace d_firmName = subinstr(d_firmName,"`e'","e",.)
}
foreach i of local specialIs {
	replace d_firmName = subinstr(d_firmName,"`i'","i",.)
}
foreach o of local specialOs {
	replace d_firmName = subinstr(d_firmName,"`o'","o",.)
}
foreach u of local specialUs {
	replace d_firmName = subinstr(d_firmName,"`u'","u",.)
}
foreach y of local specialYs {
	replace d_firmName = subinstr(d_firmName,"`y'","y",.)
}
replace d_firmName = subinstr(d_firmName,"ñ","n",.)
replace d_firmName = subinstr(d_firmName,"Ñ","n",.)
replace d_firmName = subinstr(d_firmName,"æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Œ","ce",.)
replace d_firmName = subinstr(d_firmName,"œ","ce",.)
replace d_firmName = subinstr(d_firmName,"Ç","c",.)
replace d_firmName = subinstr(d_firmName,"ç","c",.)
replace d_firmName = usubinstr(d_firmName,"ž","z",.)

replace d_firmName = subinstr(d_firmName,".","",.)
replace d_firmName = subinstr(d_firmName,",","",.)
replace d_firmName = subinstr(d_firmName,"-","",.)
replace d_firmName = subinstr(d_firmName,"/","",.)
replace d_firmName = subinstr(d_firmName,"'","",.)
replace d_firmName = subinstr(d_firmName,"!","",.)
replace d_firmName = subinstr(d_firmName,":","",.)
replace d_firmName = subinstr(d_firmName,";","",.)
replace d_firmName = subinstr(d_firmName,"#","",.)
replace d_firmName = subinstr(d_firmName,"*","",.)
replace d_firmName = subinstr(d_firmName,"@","",.)
replace d_firmName = subinstr(d_firmName,"_","",.)
replace d_firmName = subinstr(d_firmName,"|","",.)
replace d_firmName = subinstr(d_firmName,"$","",.)
replace d_firmName = subinstr(d_firmName,"\","",.)
replace d_firmName = subinstr(d_firmName,"+","",.)
replace d_firmName = usubinstr(d_firmName,"¿","",.)

replace d_firmName = subinstr(d_firmName,"&"," & ",.)
replace d_firmName  = subinstr(d_firmName ," AND "," & ",.)

forvalues i = 1/3 {
	replace d_firmName  = regexr(d_firmName,"PRIVATE","PVT")
	replace d_firmName  = regexr(d_firmName,"LIMITED","LTD")
	replace d_firmName  = regexr(d_firmName,"COMPANY","CO")
	replace d_firmName  = regexr(d_firmName,"INCORPORATED","INC")
	replace d_firmName  = regexr(d_firmName,"PTY","PVT")
	replace d_firmName  = regexr(d_firmName,"CORPORATION","CORP")
	replace d_firmName  = regexr(d_firmName ,"L L C","LLC")
	replace d_firmName  = regexr(d_firmName," INTL "," INTERNATIONAL ")
	replace d_firmName  = regexr(d_firmName," COS "," CO ")
	replace d_firmName  = regexr(d_firmName," COS$"," CO$")
	replace d_firmName  = regexr(d_firmName," S A$"," SA")
	replace d_firmName  = regexr(d_firmName," S C$"," SC")
	replace d_firmName  = regexr(d_firmName," P C$"," PC")
	replace d_firmName  = regexr(d_firmName," N V$"," NV")
	replace d_firmName  = regexr(d_firmName," SA RL$"," SARL")
}

replace d_firmName  = subinstr(d_firmName ,"SERVICES","SERVICE",.)
replace d_firmName  = subinstr(d_firmName ,"SYSTEMS","SYSTEM",.)
replace d_firmName  = subinstr(d_firmName ,"HOLDINGS","HOLDING",.)
replace d_firmName  = subinstr(d_firmName ,"SOLUTIONS","SOLUTION",.)
replace d_firmName  = subinstr(d_firmName ,"PRODUCTS","PRODUCT",.)
replace d_firmName  = subinstr(d_firmName ,"PARTNERS","PARTNER",.)
replace d_firmName  = subinstr(d_firmName ,"ENTERPRISES","ENTERPRISE",.)
replace d_firmName  = subinstr(d_firmName ,"MATERIALS","MATERIAL",.)
replace d_firmName  = subinstr(d_firmName ,"METALS","METAL",.)
replace d_firmName  = subinstr(d_firmName ,"CHEMICALS","CHEMICAL",.)

replace d_firmName  = strtrim(d_firmName )
replace d_firmName  = stritrim(d_firmName )
replace d_firmName = upper(d_firmName)
duplicates drop
save ".\Data\Data_OSHA\PreqinNames.dta", replace

use ".\Data\Data_OSHA\PreqinNames.dta", clear
gen d_firmName_noExt = d_firmName
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^THE ","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTDA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PTY$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CORP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^OOO ","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," GMBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," MBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," SARL$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AS$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AB$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AG$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SCA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," NV$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SL$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," BV$","")
replace d_firmName_noExt  = subinstr(d_firmName_noExt ," OOO$","",.)
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"S$","")
replace d_firmName_noExt  = strtrim(d_firmName_noExt )
replace d_firmName_noExt  = stritrim(d_firmName_noExt )

gen d_firmName_noSpace = subinstr(d_firmName_noExt," ","",.)
gen d_firmName_noFreq = d_firmName_noSpace

forvalues i = 1/3 {
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INDUSTRIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"HOLDING","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"GROUP","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"PRODUCT","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INTERNATIONAL","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"TECHNOLOGIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"&","",.)	
}

save ".\Data\Data_OSHA\PreqinNames.dta", replace

//Exact Match
use ".\Data\Data_OSHA\PreqinNames.dta", clear
ren (d_firmName) (cleanedName)
joinby cleanedName using ".\Data\Data_OSHA\OSHANames.dta"

keep d_firmID d_firstDealYear OSHAID cleanedName
save ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta", replace

keep d_firmID d_firstDealYear OSHAID
order d_firmID d_firstDealYear OSHAID
save ".\Data\Data_OSHA\preqinOSHAMap.dta", replace

keep OSHAID
duplicates drop
merge 1:m OSHAID using ".\Data\Data_OSHA\OSHANames.dta"
keep if _m==2
drop _m
save ".\Data\Data_OSHA\OSHANames.dta", replace

//No Extensions match
use ".\Data\Data_OSHA\PreqinNames.dta", clear
ren (d_firmName_noExt) (cleanedName_noExt)
joinby cleanedName_noExt using ".\Data\Data_OSHA\OSHANames.dta"

keep d_firmID d_firstDealYear OSHAID cleanedName
append using ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta"
duplicates drop
save ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta", replace

keep d_firmID d_firstDealYear OSHAID
order d_firmID d_firstDealYear OSHAID
append using ".\Data\Data_OSHA\preqinOSHAMap.dta"
duplicates drop
save ".\Data\Data_OSHA\preqinOSHAMap.dta", replace

keep OSHAID
duplicates drop
merge 1:m OSHAID using ".\Data\Data_OSHA\OSHANames.dta"
keep if _m==2
drop _m
save ".\Data\Data_OSHA\OSHANames.dta", replace

//Removing spaces
use ".\Data\Data_OSHA\PreqinNames.dta", clear
ren (d_firmName_noSpace) (cleanedName_noSpace)
joinby cleanedName_noSpace using ".\Data\Data_OSHA\OSHANames.dta"

keep d_firmID d_firstDealYear OSHAID cleanedName
append using ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta"
duplicates drop
save ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta", replace

keep d_firmID d_firstDealYear OSHAID
order d_firmID d_firstDealYear OSHAID
append using ".\Data\Data_OSHA\preqinOSHAMap.dta"
duplicates drop
save ".\Data\Data_OSHA\preqinOSHAMap.dta", replace

keep OSHAID
duplicates drop
merge 1:m OSHAID using ".\Data\Data_OSHA\OSHANames.dta"
keep if _m==2
drop _m
save ".\Data\Data_OSHA\OSHANames.dta", replace

//I check if an establishment is mapped to a unique firm. If it is then I consider it a correct match and I keep only these.
use ".\Data\Data_OSHA\preqinOSHAMap.dta", clear
bysort OSHAID: egen uniq_preqinID = nvals(d_firmID)
drop if uniq_preqinID!=1
drop uniq_preqinID
duplicates drop
save ".\Data\Data_OSHA\preqinOSHAMap.dta", replace

keep OSHAID d_firmID
merge 1:m OSHAID d_firmID using ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta"
keep if _m==3
drop _m
bysort OSHAID d_firstDealYear (cleanedName): keep if _n==1
save ".\Data\Data_OSHA\preqinOSHAMap_wNames.dta", replace

use ".\Data\Data_OSHA\oshaPanel_inspectionsPlanned.dta", clear
append using ".\Data\Data_OSHA\oshaPanel_inspectionsComplaint.dta"
append using ".\Data\Data_OSHA\oshaPanel_violations.dta"
append using ".\Data\Data_OSHA\oshaPanel_accidents.dta"
keep OSHAID
duplicates drop
merge 1:m OSHAID using ".\Data\Data_OSHA\osha_inspections_final.dta"
keep if _m==3
keep OSHAID site_state site_city naics_code
drop if missing(site_state)
bysort OSHAID (site_city): replace site_city = site_city[1]
duplicates drop
duplicates tag OSHAID, gen(tag)
drop if tag!=0 & naics_code=="000000"
drop tag
replace naics_code = substr(naics_code,1,2)
duplicates drop
bysort OSHAID (naics_code): replace naics_code = naics_code[1]
duplicates drop

merge m:1 OSHAID using ".\Data\Data_OSHA\preqinOSHAMap.dta"
keep if _m==3
drop _m
duplicates drop
drop if d_firstDealYear<2000
gen year1 = 2000
gen year2 = 2022
reshape long year, i(OSHAID d_firstDealYear site_state site_city naics_code) j(j)
drop j
tsset OSHAID year
tsfill
bysort OSHAID (year): carryforward site_state site_city naics_code d_firmID d_firstDealYear, replace
egen double stateYear = group(site_state year)
egen double cityYear = group(site_city year)
egen double industryYear = group(naics_code year)
save ".\Data\Data_OSHA\oshaIDPanel.dta", replace

***Inspections Panel - All
use ".\Data\Data_OSHA\oshaIDPanel.dta", clear
ren year yearInspection
merge 1:1 OSHAID yearInspection using ".\Data\Data_OSHA\oshaPanel_inspections.dta"
drop if _m==2
bysort OSHAID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_OSHA\oshaPanel_inspections_final.dta", replace

//For treated firms I keep the time period (-5,5) from the deal year.
gen postPeriod = cond(yearInspection>=d_firstDealYear,1,cond(d_firstDealYear==.,.,0))
gen dist_to_deal = yearInspection-d_firstDealYear
drop if !inrange(dist_to_deal,-5,5) & dist_to_deal!=.

//Dropping treated firms that don't have either pre- or post- periods present
bysort OSHAID: egen minPost = min(postPeriod)
bysort OSHAID: egen maxPost = max(postPeriod)
drop if !(minPost==0 & maxPost==1) & postPeriod!=.
drop minPost maxPost
save ".\Data\Data_OSHA\oshaPanel_inspections_final.dta", replace

//Keeping only acquired establishments that have seen an inspection in the pre-period (bad establishments)
gen inspectionPreperiod = cond(countInspections!=0 & countInspections!=. & postPeriod==0,1,0)
bysort OSHAID: egen maxInspectionPreperiod = max(inspectionPreperiod)
drop if maxInspectionPreperiod==0 & postPeriod!=.
drop inspectionPreperiod maxInspectionPreperiod
save ".\Data\Data_OSHA\oshaPanel_inspections_final.dta", replace

bysort OSHAID (yearInspection): carryforward nr_in_estab, replace
gsort OSHAID -yearInspection
by OSHAID: carryforward nr_in_estab, replace
recode countInspections (.=0)

gen logInspections = log(1+countInspections)
gen logNrEstab = log(1+nr_in_estab)

label var countInspections "Inspections (Count) - All"
label var logInspections "Log. [1+#Inspections (All)]"
label var logNrEstab "Log. [1+#Employees]"
save ".\Data\Data_OSHA\oshaPanel_inspections_final.dta", replace

***Inspections Panel - Planned
use ".\Data\Data_OSHA\oshaIDPanel.dta", clear
ren year yearInspection
merge 1:1 OSHAID yearInspection using ".\Data\Data_OSHA\oshaPanel_inspectionsPlanned.dta"
drop if _m==2
bysort OSHAID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_OSHA\oshaPanel_inspections_finalPlanned.dta", replace

//For treated firms I keep the time period (-5,5) from the deal year.
gen postPeriod = cond(yearInspection>=d_firstDealYear,1,cond(d_firstDealYear==.,.,0))
gen dist_to_deal = yearInspection-d_firstDealYear
drop if !inrange(dist_to_deal,-5,5) & dist_to_deal!=.

//Dropping treated firms that don't have either pre- or post- periods present
bysort OSHAID: egen minPost = min(postPeriod)
bysort OSHAID: egen maxPost = max(postPeriod)
drop if !(minPost==0 & maxPost==1) & postPeriod!=.
drop minPost maxPost
save ".\Data\Data_OSHA\oshaPanel_inspections_finalPlanned.dta", replace

//Keeping only acquired establishments that have seen an inspection in the pre-period (bad establishments)
gen inspectionPreperiod = cond(countInspectionsPlanned!=0 & countInspectionsPlanned!=. & postPeriod==0,1,0)
bysort OSHAID: egen maxInspectionPreperiod = max(inspectionPreperiod)
drop if maxInspectionPreperiod==0 & postPeriod!=.
drop inspectionPreperiod maxInspectionPreperiod
save ".\Data\Data_OSHA\oshaPanel_inspections_finalPlanned.dta", replace

bysort OSHAID (yearInspection): carryforward nr_in_estab, replace
gsort OSHAID -yearInspection
by OSHAID: carryforward nr_in_estab, replace
recode countInspectionsPlanned (.=0)

gen logInspectionsPlanned = log(1+countInspectionsPlanned)
gen logNrEstab = log(1+nr_in_estab)

label var countInspectionsPlanned "Inspections (Count) - Planned"
label var logInspectionsPlanned "Log. [1+#Inspections (Planned)]"
label var logNrEstab "Log. [1+#Employees]"
save ".\Data\Data_OSHA\oshaPanel_inspections_finalPlanned.dta", replace

***Inspections Panel - Complaint
use ".\Data\Data_OSHA\oshaIDPanel.dta", clear
ren year yearInspection
merge 1:1 OSHAID yearInspection using ".\Data\Data_OSHA\oshaPanel_inspectionsComplaint.dta"
drop if _m==2
bysort OSHAID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_OSHA\oshaPanel_inspections_finalComplaint.dta", replace

//For treated firms I keep the time period (-5,5) from the deal year.
gen postPeriod = cond(yearInspection>=d_firstDealYear,1,cond(d_firstDealYear==.,.,0))
gen dist_to_deal = yearInspection-d_firstDealYear
drop if !inrange(dist_to_deal,-5,5) & dist_to_deal!=.

//Dropping treated firms that don't have either pre- or post- periods present
bysort OSHAID: egen minPost = min(postPeriod)
bysort OSHAID: egen maxPost = max(postPeriod)
drop if !(minPost==0 & maxPost==1) & postPeriod!=.
drop minPost maxPost
save ".\Data\Data_OSHA\oshaPanel_inspections_finalComplaint.dta", replace

//Keeping only acquired establishments that have seen an inspection in the pre-period (bad establishments)
gen inspectionPreperiod = cond(countInspectionsComplaint!=0 & countInspectionsComplaint!=. & postPeriod==0,1,0)
bysort OSHAID: egen maxInspectionPreperiod = max(inspectionPreperiod)
drop if maxInspectionPreperiod==0 & postPeriod!=.
drop inspectionPreperiod maxInspectionPreperiod
save ".\Data\Data_OSHA\oshaPanel_inspections_finalComplaint.dta", replace

bysort OSHAID (yearInspection): carryforward nr_in_estab, replace
gsort OSHAID -yearInspection
by OSHAID: carryforward nr_in_estab, replace
recode countInspectionsComplaint (.=0)

gen logInspectionsComplaint = log(1+countInspectionsComplaint)
gen logNrEstab = log(1+nr_in_estab)

label var countInspectionsComplaint "Inspections (Count) - Complaints"
label var logInspectionsComplaint "Log. [1+#Inspections (Complaints)]"
label var logNrEstab "Log. [1+#Employees]"
save ".\Data\Data_OSHA\oshaPanel_inspections_finalComplaint.dta", replace

***Violations Panel
use ".\Data\Data_OSHA\oshaIDPanel.dta", clear
ren year yearViolation
merge 1:1 OSHAID yearViolation using ".\Data\Data_OSHA\oshaPanel_violations.dta"
drop if _m==2
bysort OSHAID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_OSHA\oshaPanel_violations_final.dta", replace

//For treated firms I keep the time period (-5,5) from the deal year.
gen postPeriod = cond(yearViolation>=d_firstDealYear,1,cond(d_firstDealYear==.,.,0))
gen dist_to_deal = yearViolation-d_firstDealYear
drop if !inrange(dist_to_deal,-5,5) & dist_to_deal!=.

//Dropping treated firms that don't have either pre- or post- periods present
bysort OSHAID: egen minPost = min(postPeriod)
bysort OSHAID: egen maxPost = max(postPeriod)
drop if !(minPost==0 & maxPost==1) & postPeriod!=.
drop minPost maxPost
save ".\Data\Data_OSHA\oshaPanel_violations_final.dta", replace

//Keeping only acquired establishments that have seen a violation in the pre-period (bad establishments)
gen violationPreperiod = cond(violation!=0 & violation!=. & postPeriod==0,1,0)
bysort OSHAID: egen maxViolationPreperiod = max(violationPreperiod)
drop if maxViolationPreperiod==0 & postPeriod!=.
drop violationPreperiod maxViolationPreperiod
save ".\Data\Data_OSHA\oshaPanel_violations_final.dta", replace

bysort OSHAID (yearViolation): carryforward nr_in_estab, replace
gsort OSHAID -yearViolation
by OSHAID: carryforward nr_in_estab, replace
recode violation (.=0)

gen logViolation = log(1+violation)
gen logNrEstab = log(1+nr_in_estab)

label var violation "Violations [Count]"
label var logViolation "Log. [1+#Violations]"
label var logNrEstab "Log. [1+#Employees]"
save ".\Data\Data_OSHA\oshaPanel_violations_final.dta", replace

***Accidents Panel
use ".\Data\Data_OSHA\oshaIDPanel.dta", clear
ren year yearAccident
merge 1:1 OSHAID yearAccident using ".\Data\Data_OSHA\oshaPanel_accidents.dta"
drop if _m==2
bysort OSHAID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_OSHA\oshaPanel_accidents_final.dta", replace

//For treated firms I keep the time period (-5,5) from the deal year.
gen postPeriod = cond(yearAccident>=d_firstDealYear,1,cond(d_firstDealYear==.,.,0))
gen dist_to_deal = yearAccident-d_firstDealYear
drop if !inrange(dist_to_deal,-5,5) & dist_to_deal!=.

//Dropping treated firms that don't have either pre- or post- periods present
bysort OSHAID: egen minPost = min(postPeriod)
bysort OSHAID: egen maxPost = max(postPeriod)
drop if !(minPost==0 & maxPost==1) & postPeriod!=.
drop minPost maxPost
save ".\Data\Data_OSHA\oshaPanel_accidents_final.dta", replace

//Keeping only acquired establishments that have seen a violation in the pre-period (bad establishments)
gen accidentPreperiod = cond(hospitalization!=0 & hospitalization!=. & postPeriod==0,1,0)
bysort OSHAID: egen maxAccidentPreperiod = max(accidentPreperiod)
drop if maxAccidentPreperiod==0 & postPeriod!=.
drop accidentPreperiod maxAccidentPreperiod
save ".\Data\Data_OSHA\oshaPanel_accident_final.dta", replace

bysort OSHAID (yearAccident): carryforward nr_in_estab, replace
gsort OSHAID -yearAccident
by OSHAID: carryforward nr_in_estab, replace
recode hospitalization (.=0)

gen logHospitalization = log(1+hospitalization)
gen logNrEstab = log(1+nr_in_estab)

label var hospitalization "Hospitalization (Count)"
label var logHospitalization "Log. [1+#Hospitalization]"
label var logNrEstab "Log. [1+#Employees]"
save ".\Data\Data_OSHA\oshaPanel_accidents_final.dta", replace

erase ".\Data\Data_OSHA\preqinOSHAMap.dta"
erase ".\Data\Data_OSHA\PreqinNames.dta"
erase ".\Data\Data_OSHA\OSHANames.dta"
erase ".\Data\Data_OSHA\oshaIDPanel.dta"
erase ".\Data\Data_OSHA\osha_accident.dta"
erase ".\Data\Data_OSHA\osha_inspection.dta"
erase ".\Data\Data_OSHA\osha_violation.dta"
erase ".\Data\Data_OSHA\osha_accident_injury.dta"
erase ".\Data\Data_OSHA\osha_accidents_final.dta"
erase ".\Data\Data_OSHA\osha_violations_final.dta"
erase ".\Data\Data_OSHA\oshaPanel_inspectionsPlanned.dta"
erase ".\Data\Data_OSHA\oshaPanel_inspectionsComplaint.dta"
erase ".\Data\Data_OSHA\oshaPanel_violations.dta"
erase ".\Data\Data_OSHA\oshaPanel_accidents.dta"
erase ".\Data\Data_OSHA\osha_inspections_final.dta"
erase temp.dta
}
log closelog using "logfile_preqin.smcl", replace

set more off
clear all

**Fund Manager**
{
import excel using ".\Data\Data_preqin\Preqin_fundManagers_20230218.xlsx", clear first
drop LOCALLANGUAGEFIRMNAME
order FIRMID FIRMNAME CITY COUNTRY REGION ADDRESS STATECOUNTY ZIPCODE WEBSITE EMAIL TEL FAX SECONDARYLOCATIONS FIRMTYPE YEAREST TOTALSTAFF MANAGEMENTTEAMSTAFF INVESTMENTTEAMSTAFF FIRMSMAINCURRENCY CURRENCYOFFUNDSMANAGED WOMENOWNEDFIRM MINORITYOWNEDFIRM FIRMOWNERSHIP LISTED TICKERSYMBOL STOCKEXCHANGE TOTALASSETSUNDERMANAGEMENTC TOTALASSETSUNDERMANAGEMENTU TOTALASSETSUNDERMANAGEMENTE TOTALASSETSUNDERMANAGEMENTD ALTERNATIVESASSETSUNDERMANAG CJ CK CL PEASSETSUNDERMANAGEMENTCUR PEASSETSUNDERMANAGEMENTUSD PEASSETSUNDERMANAGEMENTEUR PEASSETSUNDERMANAGEMENTDATE PEMAINFIRMSTRATEGY PESOURCESOFCAPITAL PEGEOGRAPHICEXPOSURE PEINDUSTRIES PEINDUSTRYVERTICALS PESTRATEGIES PEINVESTORCOINVESTMENTRIGHT PECOMPANYSIZE PECOMPANYSITUATION PEINVESTMENTSTAGE PEGPPOSITIONININVESTMENT PEBOARDREPRESENTATION PESHAREHOLDING PEMAINAPPLIEDSTRATEGIES PEMAINEXPERTISEPROVIDED PEPORTFOLIOCOMPANYMINIMUMEB PEPORTFOLIOCOMPANYMAXIMUMEB AU AV AW AX PEPORTFOLIOCOMPANYMINIMUMAN PEPORTFOLIOCOMPANYMAXIMUMAN BA BB BC BD PEPORTFOLIOCOMPANYMINIMUMVA PEPORTFOLIOCOMPANYMAXIMUMVA BG BH BI BJ PEINITIALMINIMUMEQUITYINVES PEINITIALMAXIMUMEQUITYINVES BM BN BO BP PEMINIMUMTRANSACTIONSIZEMN PEMAXIMUMTRANSACTIONSIZEMN PEMINIMUMTRANSACTIONSIZEUS PEMAXIMUMTRANSACTIONSIZEUS PEMINIMUMTRANSACTIONSIZEEU PEMAXIMUMTRANSACTIONSIZEEU PEMINIMUMHOLDINGPERIODYEAR PEMAXIMUMHOLDINGPERIODYEAR PETOTALFUNDSRAISEDLAST10Y AP PEESTIMATEDDRYPOWDERUSDMN PEESTIMATEDDRYPOWDEREURMN PETOTALNOOFFUNDSINMARKET PETOTALNOOFFUNDSCLOSED PEDATEINSERTED PEDATEUPDATED

ren (FIRMID FIRMNAME CITY COUNTRY REGION ADDRESS STATECOUNTY ZIPCODE WEBSITE EMAIL TEL FAX SECONDARYLOCATIONS FIRMTYPE YEAREST TOTALSTAFF MANAGEMENTTEAMSTAFF INVESTMENTTEAMSTAFF FIRMSMAINCURRENCY CURRENCYOFFUNDSMANAGED WOMENOWNEDFIRM MINORITYOWNEDFIRM FIRMOWNERSHIP LISTED TICKERSYMBOL STOCKEXCHANGE TOTALASSETSUNDERMANAGEMENTC TOTALASSETSUNDERMANAGEMENTU TOTALASSETSUNDERMANAGEMENTE TOTALASSETSUNDERMANAGEMENTD ALTERNATIVESASSETSUNDERMANAG CJ CK CL PEASSETSUNDERMANAGEMENTCUR PEASSETSUNDERMANAGEMENTUSD PEASSETSUNDERMANAGEMENTEUR PEASSETSUNDERMANAGEMENTDATE PEMAINFIRMSTRATEGY PESOURCESOFCAPITAL PEGEOGRAPHICEXPOSURE PEINDUSTRIES PEINDUSTRYVERTICALS PESTRATEGIES PEINVESTORCOINVESTMENTRIGHT PECOMPANYSIZE PECOMPANYSITUATION PEINVESTMENTSTAGE PEGPPOSITIONININVESTMENT PEBOARDREPRESENTATION PESHAREHOLDING PEMAINAPPLIEDSTRATEGIES PEMAINEXPERTISEPROVIDED PEPORTFOLIOCOMPANYMINIMUMEB PEPORTFOLIOCOMPANYMAXIMUMEB AU AV AW AX PEPORTFOLIOCOMPANYMINIMUMAN PEPORTFOLIOCOMPANYMAXIMUMAN BA BB BC BD PEPORTFOLIOCOMPANYMINIMUMVA PEPORTFOLIOCOMPANYMAXIMUMVA BG BH BI BJ PEINITIALMINIMUMEQUITYINVES PEINITIALMAXIMUMEQUITYINVES BM BN BO BP PEMINIMUMTRANSACTIONSIZEMN PEMAXIMUMTRANSACTIONSIZEMN PEMINIMUMTRANSACTIONSIZEUS PEMAXIMUMTRANSACTIONSIZEUS PEMINIMUMTRANSACTIONSIZEEU PEMAXIMUMTRANSACTIONSIZEEU PEMINIMUMHOLDINGPERIODYEAR PEMAXIMUMHOLDINGPERIODYEAR PETOTALFUNDSRAISEDLAST10Y AP PEESTIMATEDDRYPOWDERUSDMN PEESTIMATEDDRYPOWDEREURMN PETOTALNOOFFUNDSINMARKET PETOTALNOOFFUNDSCLOSED PEDATEINSERTED PEDATEUPDATED) ///
	(fm_id fm_firm_name fm_city fm_country fm_region fm_address fm_state_county fm_zipcode fm_website fm_email fm_tel fm_fax fm_secondary_locns fm_firm_type fm_year_est fm_total_staff fm_management_team_staff fm_investment_team_staff fm_firm_main_curr fm_managed_funds_curr fm_women_owned fm_minority_owned fm_firm_ownership fm_listed fm_ticker fm_stock_exchange fm_total_AUM_curr fm_total_AUM_USD fm_total_AUM_EUR fm_total_AUM_date fm_alternatives_AUM_curr fm_alternatives_AUM_USD fm_alternatives_AUM_EUR fm_alternatives_AUM_date fm_PE_AUM_curr fm_PE_AUM_USD fm_PE_AUM_EUR fm_PE_AUM_date fm_pe_mainFirmStrategy fm_pe_sourcesOfCapital fm_pe_geographicExposure fm_pe_industries fm_pe_industryVerticals fm_pe_strategies fm_pe_investorCoinvstRights fm_pe_companySize fm_pe_companySituation fm_pe_investmentStage fm_pe_GPpositionInInvestment fm_pe_boardRepresentation fm_pe_shareHolding fm_pe_mainAppliedStrategies fm_pe_mainExpertiseProvided fm_pe_folioFirmMinEBITDA_curr fm_pe_folioFirmMaxEBITDA_curr fm_pe_folioFirmMinEBITDA_USD fm_pe_folioFirmMaxEBITDA_USD fm_pe_folioFirmMinEBITDA_EUR fm_pe_folioFirmMaxEBITDA_EUR fm_pe_folioFirmMinRevenue_curr fm_pe_folioFirmMaxRevenue_curr fm_pe_folioFirmMinRevenue_USD fm_pe_folioFirmMaxRevenue_USD fm_pe_folioFirmMinRevenue_EUR fm_pe_folioFirmMaxRevenue_EUR fm_pe_folioFirmMinValue_curr fm_pe_folioFirmMaxValue_curr fm_pe_folioFirmMinValue_USD fm_pe_folioFirmMaxValue_USD fm_pe_folioFirmMinValue_EUR fm_pe_folioFirmMaxValue_EUR fm_pe_InitialMinEquityInvst_curr fm_pe_InitialMaxEquityInvst_curr fm_pe_InitialMinEquityInvst_USD fm_pe_InitialMaxEquityInvst_USD fm_pe_InitialMinEquityInvst_EUR fm_pe_InitialMaxEquityInvst_EUR fm_pe_MinTxnSize_curr fm_pe_MaxTxnSize_curr fm_pe_MinTxnSize_USD fm_pe_MaxTxnSize_USD fm_pe_MinTxnSize_EUR fm_pe_MaxTxnSize_EUR fm_pe_minHldgPeriod fm_pe_maxHldgPeriod fm_pe_totalFundsRaised10Yrs_USD fm_pe_totalFundsRaised10Yrs_EUR fm_pe_estimatedDryPowder_USD fm_pe_estimatedDryPowder_EUR fm_pe_totalFundsinMarket fm_pe_totalFundsClosed fm_pe_dateInserted fm_pe_dateUpdated)

foreach var of varlist fm_firm_name fm_city fm_country fm_region fm_address fm_state_county fm_secondary_locns fm_firm_type fm_firm_main_curr fm_managed_funds_curr fm_women_owned fm_minority_owned fm_firm_ownership fm_listed fm_stock_exchange fm_pe_mainFirmStrategy fm_pe_sourcesOfCapital fm_pe_geographicExposure fm_pe_industries fm_pe_industryVerticals fm_pe_strategies fm_pe_investorCoinvstRights fm_pe_companySize fm_pe_companySituation fm_pe_investmentStage fm_pe_GPpositionInInvestment fm_pe_boardRepresentation fm_pe_shareHolding fm_pe_mainAppliedStrategies fm_pe_mainExpertiseProvided {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')	
}
sort fm_id

//Website
replace fm_website = "" if inlist(fm_website,"No Website Available","http://No Website Available","http://No website available")
replace fm_website = "https://www.social-ea.org/g" if fm_website=="http://social-ea.orhttps://www.social-ea.org/g"
replace fm_website = "https://odba.vc" if fm_website=="http://www.https://odba.vc"
replace fm_website = regexr(fm_website,"^http://","")
replace fm_website = regexr(fm_website,"^https://","")
replace fm_website = regexr(fm_website,"^www\.","")
forvalues i = 1/3 {
	replace fm_website = regexr(fm_website,"#$","")
	replace fm_website = regexr(fm_website,"/$","")
}
replace fm_website = strtrim(fm_website)
replace fm_website = "http://" + fm_website if fm_website!=""

//Countries
replace fm_country = "UNITED STATES" if fm_country=="US"
replace fm_country = "UNITED KINGDOM" if fm_country=="UK"
gen country_us = cond(fm_country=="",.,cond(fm_country=="US"|fm_country=="UNITED STATES",1,0))
gen country_cn = cond(fm_country=="",.,cond(fm_country=="CHINA"|fm_country=="HONG KONG SAR - CHINA",1,0))
gen country_eu = cond(fm_country=="",.,cond(inlist(fm_country,"AUSTRIA","BELGIUM","BULGARIA","CROATIA","CYPRUS","CZECH REPUBLIC")|inlist(fm_country,"DENMARK","ESTONIA","FINLAND","FRANCE","GERMANY","GREECE")|inlist(fm_country,"HUNGARY","IRELAND","ITALY","LATVIA","LITHUANIA","LUXEMBOURG")|inlist(fm_country,"MALTA","NETHERLANDS","POLAND","PORTUGAL","ROMANIA","SLOVAKIA")|inlist(fm_country,"SLOVENIA","SPAIN","SWEDEN"),1,0))
gen country_uk = cond(fm_country=="",.,cond(fm_country=="UK"|fm_country=="UNITED KINGDOM",1,0))
gen country_canada = cond(fm_country=="",.,cond(fm_country=="CANADA",1,0))
gen country_india = cond(fm_country=="",.,cond(fm_country=="INDIA",1,0))
gen country_others = cond(country_us|country_cn|country_uk|country_canada|country_india|country_eu,0,1)

//Ownership
foreach var of varlist fm_women_owned fm_minority_owned fm_listed {
	gen `var'_num = cond(`var'=="",.,cond(`var'=="NO",0,1))
}
gen fm_ownership_independent = cond(fm_firm_ownership=="",.,cond(fm_firm_ownership=="INDEPENDENT FIRM",1,0))
gen fm_ownership_captive = cond(fm_firm_ownership=="",.,cond(strpos(fm_firm_ownership,"CAPTIVE ARM"),1,0))
gen fm_ownership_spinoff = cond(fm_firm_ownership=="",.,cond(strpos(fm_firm_ownership,"SPIN-OFF"),1,0))
gen fm_ownership_family = cond(fm_firm_ownership=="",.,cond(fm_firm_ownership=="FAMILY OFFICE FOUNDED",1,0))

//Main Firm Strategy
gen fm_pe_strat_buyout = cond(fm_pe_mainFirmStrategy=="",.,cond(fm_pe_mainFirmStrategy=="BUYOUT",1,0))
gen fm_pe_strat_venture = cond(fm_pe_mainFirmStrategy=="",.,cond(fm_pe_mainFirmStrategy=="VENTURE CAPITAL",1,0))
gen fm_pe_strat_growth = cond(fm_pe_mainFirmStrategy=="",.,cond(fm_pe_mainFirmStrategy=="GROWTH",1,0))
gen fm_pe_strat_balanced = cond(fm_pe_mainFirmStrategy=="",.,cond(fm_pe_mainFirmStrategy=="BALANCED",1,0))
gen fm_pe_strat_others = cond(fm_pe_mainFirmStrategy=="",.,cond(fm_pe_strat_buyout|fm_pe_strat_venture|fm_pe_strat_growth|fm_pe_strat_balanced,0,1))

save ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace

//Industries
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
split fm_pe_industries, p(",")
keep fm_id fm_pe_industries*
drop fm_pe_industries
reshape long fm_pe_industries, i(fm_id) j(j)
drop j
drop if missing(fm_pe_industries)
replace fm_pe_industries = strtrim(fm_pe_industries)
replace fm_pe_industries = stritrim(fm_pe_industries)
gen pe_ind_1 = cond(inlist(fm_pe_industries,"IT SECURITY/CYBERSECURITY","INFORMATION TECHNOLOGY","SOFTWARE","INTERNET","INFORMATION SERVICES","IT INFRASTRUCTURE"),1,0)
gen pe_ind_2 = cond(inlist(fm_pe_industries,"MEDIA","TELECOMS","TELECOMS & MEDIA"),1,0)
gen pe_ind_3 = cond(inlist(fm_pe_industries,"BUSINESS SERVICES","BUSINESS SUPPORT SERVICES","OUTSOURCING"),1,0)
gen pe_ind_4 = cond(inlist(fm_pe_industries,"MEDICAL DEVICES & EQUIPMENT","HEALTHCARE","PHARMACEUTICALS","HEALTHCARE IT","BIOTECHNOLOGY","HEALTHCARE SPECIALISTS"),1,0)
gen pe_ind_5 = cond(inlist(fm_pe_industries,"FORESTRY & TIMBER","AGRIBUSINESS","FOOD"),1,0)
gen pe_ind_6 = cond(inlist(fm_pe_industries,"ENERGY & UTILITIES","OIL & GAS","POWER & UTILITIES"),1,0)
gen pe_ind_7 = cond(inlist(fm_pe_industries,"INDUSTRIAL MACHINERY","HARDWARE","INDUSTRIALS"),1,0)
gen pe_ind_8 = cond(inlist(fm_pe_industries,"ELECTRONICS","SEMICONDUCTORS"),1,0)
gen pe_ind_9 = cond(inlist(fm_pe_industries,"CHEMICALS","MATERIALS","RAW MATERIALS & NATURAL RESOURCES","MINING","BIOPOLYMERS"),1,0)
gen pe_ind_10 = cond(inlist(fm_pe_industries,"COMMERCIAL PROPERTY","CONSTRUCTION","REAL ESTATE DEVELOPMENT & OPERATING COMPANIES","REAL ESTATE"),1,0)
gen pe_ind_11 = cond(inlist(fm_pe_industries,"INSURANCE","FINANCIAL SERVICES","FINANCIAL & INSURANCE SERVICES"),1,0)
gen pe_ind_12 = cond(inlist(fm_pe_industries,"RETAIL","CONSUMER PRODUCTS","MARKETING/ADVERTISING","CONSUMER DISCRETIONARY","CONSUMER SERVICES","TRAVEL & LEISURE"),1,0)
gen pe_ind_13 = cond(inlist(fm_pe_industries,"RAIL TRANSPORT","SHIP BUILDING & REPAIR","AUTOMOBILES","OTHER VEHICLES & PARTS"),1,0)
gen pe_ind_14 = cond(inlist(fm_pe_industries,"COOLING & VENTILATION EQUIPMENT AND SERVICES","HEATING"),1,0)
gen pe_ind_15 = cond(inlist(fm_pe_industries,"DEFENCE","AEROSPACE"),1,0)
gen pe_ind_16 = cond(inlist(fm_pe_industries,"TRANSPORTATION SERVICES","LOGISTICS & DISTRIBUTION"),1,0)
gen pe_ind_17 = cond(inlist(fm_pe_industries,"BOTTLING","PACKAGING"),1,0)
gen pe_ind_18 = cond(inlist(fm_pe_industries,"ENVIRONMENTAL SERVICES","RENEWABLE ENERGY","ENERGY STORAGE & BATTERIES"),1,0)
gen pe_ind_19 = cond(inlist(fm_pe_industries,"EDUCATION/TRAINING"),1,0)
gen pe_ind_20 = cond(inlist(fm_pe_industries,"DIVERSIFIED"),1,0)
drop fm_pe_industries
foreach var of varlist pe_ind_* {
	bysort fm_id: egen t_`var' = max(`var')
	drop `var'
	ren t_`var' `var'
}
duplicates drop
save temp.dta, replace

use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
merge 1:1 fm_id using temp.dta
drop _m
egen no_of_industries = rowtotal(pe_ind_1 - pe_ind_20), missing
save ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace
erase temp.dta

//Geographic Exposure
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
split fm_pe_geographicExposure, p(",")
keep fm_id fm_pe_geographicExposure*
drop fm_pe_geographicExposure
reshape long fm_pe_geographicExposure, i(fm_id) j(j)
drop j
drop if missing(fm_pe_geographicExposure)
replace fm_pe_geographicExposure = strtrim(fm_pe_geographicExposure)
replace fm_pe_geographicExposure = stritrim(fm_pe_geographicExposure)
gen geo_exp_us = cond(inlist(fm_pe_geographicExposure,"US","UNITED STATES","WEST","MIDWEST","SOUTHEAST","NORTHEAST","SOUTHWEST"),1,0)
gen geo_exp_canada = cond(fm_pe_geographicExposure=="CANADA",1,0)
gen geo_exp_northamerica = cond(geo_exp_us==1|geo_exp_canada==1|fm_pe_geographicExposure=="NORTH AMERICA",1,0)
gen geo_exp_southamerica = cond(inlist(fm_pe_geographicExposure,"BRAZIL","COLOMBIA","CHILE","PERU","ARGENTINA","URUGUAY","ECUADOR","VENEZUELA")|inlist(fm_pe_geographicExposure,"BOLIVIA","PARAGUAY","GUYANA","SURINAME","TRINIDAD AND TOBAGO","SOUTH AMERICA"),1,0)
gen geo_exp_centralamerica = cond(inlist(fm_pe_geographicExposure,"MEXICO","PANAMA","COSTA RICA","GUATEMALA","NICARAGUA","HONDURAS","EL SALVADOR","BELIZE")|inlist(fm_pe_geographicExposure,"BAHAMAS","CUBA","PUERTO RICO","DOMINICAN REPUBLIC","JAMAICA","BARBADOS","CARIBBEAN","CAYMAN ISLANDS")|inlist(fm_pe_geographicExposure,"HAITI","SAINT KITTS AND NEVIS","SAINT LUCIA","CENTRAL AMERICA"),1,0)
gen geo_exp_america = cond(geo_exp_northamerica==1|geo_exp_southamerica==1|geo_exp_centralamerica==1|fm_pe_geographicExposure=="AMERICAS",1,0)
gen geo_exp_nordic = cond(inlist(fm_pe_geographicExposure,"SWEDEN","FINLAND","DENMARK","NORWAY","ICELAND","NORDIC"),1,0)
gen geo_exp_westeurope = cond(inlist(fm_pe_geographicExposure,"UK","UNITED KINGDOM","GUERNSEY","GERMANY","FRANCE","SWITZERLAND","NETHERLANDS")|inlist(fm_pe_geographicExposure,"AUSTRIA","BELGIUM","LUXEMBOURG","LUXEMBOURG (CH)","IRELAND","LIECHTENSTEIN","MONACO","ANDORRA","WEST EUROPE"),1,0)
gen geo_exp_uk = cond(inlist(fm_pe_geographicExposure,"UK","UNITED KINGDOM"),1,0)
gen geo_exp_southeurope = cond(inlist(fm_pe_geographicExposure,"SPAIN","ITALY","PORTUGAL","GREECE","CYPRUS","MALTA","SAN MARINO"),1,0)
gen geo_exp_easteurope = cond(inlist(fm_pe_geographicExposure,"RUSSIA","POLAND","UKRAINE","CZECH REPUBLIC","HUNGARY","ROMANIA","SLOVAKIA","BULGARIA")|inlist(fm_pe_geographicExposure,"MOLDOVA","BELARUS","CROATIA","SLOVENIA","ARMENIA","AZERBAIJAN","SERBIA","GEORGIA")|inlist(fm_pe_geographicExposure,"MACEDONIA","ALBANIA","BOSNIA & HERZEGOVINA","MONTENEGRO","KOSOVO","CENTRAL AND EAST EUROPE"),1,0)
gen geo_exp_baltics = cond(inlist(fm_pe_geographicExposure,"ESTONIA","LATVIA","LITHUANIA"),1,0)
gen geo_exp_eu = cond(inlist(fm_pe_geographicExposure,"SWEDEN","FINLAND","DENMARK","GERMANY","FRANCE","NETHERLANDS","AUSTRIA","BELGIUM")|inlist(fm_pe_geographicExposure,"LUXEMBOURG","IRELAND","SPAIN","ITALY","PORTUGAL","GREECE","CYPRUS","MALTA")|inlist(fm_pe_geographicExposure,"POLAND","CZECH REPUBLIC","HUNGARY","ROMANIA","SLOVAKIA","BULGARIA","CROATIA","SLOVENIA")|inlist(fm_pe_geographicExposure,"ESTONIA","LATVIA","LITHUANIA","EU"),1,0)
gen geo_exp_europe = cond(geo_exp_nordic==1|geo_exp_westeurope==1|geo_exp_easteurope==1|geo_exp_baltics==1|fm_pe_geographicExposure=="EUROPE",1,0)
gen geo_exp_africa = cond(inlist(fm_pe_geographicExposure,"SOUTH AFRICA","SUB-SAHARAN AFRICA","KENYA","NIGERIA","EGYPT","GHANA","UGANDA","TANZANIA")|inlist(fm_pe_geographicExposure,"ZAMBIA","MOROCCO","TUNISIA","RWANDA","MAURITIUS","ETHIOPIA","MOZAMBIQUE","IVORY COAST")|inlist(fm_pe_geographicExposure,"SENEGAL","ZIMBABWE","MALAWI","NAMIBIA","BOTSWANA","SIERRA LEONE","ALGERIA","LIBERIA")|inlist(fm_pe_geographicExposure,"ANGOLA","BURKINA FASO","MADAGASCAR","MALI","CAMEROON","BENIN","TOGO","DEMOCRATIC REPUBLIC OF CONGO")|inlist(fm_pe_geographicExposure,"NIGER","GUINEA","BURUNDI","LIBYA","CONGO","GAMBIA","SOUTH SUDAN","MAURITANIA")|inlist(fm_pe_geographicExposure,"LESOTHO","GUINEA BISSAU","GABON","SEYCHELLES","SUDAN","DJIBOUTI","CENTRAL AFRICAN REPUBLIC","CHAD")|inlist(fm_pe_geographicExposure,"COMORO ISLANDS","SOMALIA","ERITREA","EQUATORIAL GUINEA","REUNION","CAPE VERDE","SWAZILAND","NORTH AFRICA")|fm_pe_geographicExposure=="AFRICA",1,0)
gen geo_exp_middleeast = cond(inlist(fm_pe_geographicExposure,"ISRAEL","UNITED ARAB EMIRATES","TURKEY","SAUDI ARABIA","BAHRAIN","JORDAN","KUWAIT")|inlist(fm_pe_geographicExposure,"OMAN","QATAR","LEBANON","IRAQ","IRAN","PALESTINE","SYRIA","YEMEN")|fm_pe_geographicExposure=="MIDDLE EAST",1,0)
gen geo_exp_mena = cond(inlist(fm_pe_geographicExposure,"EGYPT","ISRAEL","UNITED ARAB EMIRATES","TURKEY","SAUDI ARABIA","BAHRAIN","JORDAN","KUWAIT")|inlist(fm_pe_geographicExposure,"OMAN","QATAR","LEBANON","IRAQ","IRAN","PALESTINE","SYRIA","YEMEN")|inlist(fm_pe_geographicExposure,"MENA","MOROCCO","TUNISIA","ALGERIA","LIBYA"),1,0)
gen geo_exp_gcc = cond(inlist(fm_pe_geographicExposure,"UNITED ARAB EMIRATES","SAUDI ARABIA","BAHRAIN","KUWAIT","OMAN","QATAR","GCC"),1,0)
gen geo_exp_southasia = cond(inlist(fm_pe_geographicExposure,"INDIA","PAKISTAN","BANGLADESH","SRI LANKA","NEPAL","MALDIVES","BHUTAN","SOUTH ASIA"),1,0)
gen geo_exp_india = fm_pe_geographicExposure=="INDIA"
gen geo_exp_eastasia = cond(inlist(fm_pe_geographicExposure,"CHINA","GREATER CHINA","JAPAN","SINGAPORE","SOUTH KOREA","HONG KONG","INDONESIA","VIETNAM")|inlist(fm_pe_geographicExposure,"TAIWAN","MALAYSIA","PHILIPPINES","MYANMAR","CAMBODIA","LAOS","HONG KONG SAR - CHINA","BRUNEI")|inlist(fm_pe_geographicExposure,"TAIWAN - CHINA","MACAU","NORTH KOREA","EAST AND SOUTHEAST ASIA"),1,0)
gen geo_exp_china = cond(inlist(fm_pe_geographicExposure,"CHINA","GREATER CHINA"),1,0)
gen geo_exp_centralasia = cond(inlist(fm_pe_geographicExposure,"KAZAKHSTAN","KYRGYZSTAN","TAJIKISTAN","UZBEKISTAN","TURKMENISTAN","MONGOLIA","AFGHANISTAN","CENTRAL ASIA"),1,0)
gen geo_exp_asia = cond(geo_exp_middleeast==1|geo_exp_southasia==1|geo_exp_eastasia==1|geo_exp_centralasia==1|fm_pe_geographicExposure=="ASIA",1,0)
gen geo_exp_oecd = cond(geo_exp_northamerica==1|geo_exp_nordic==1|geo_exp_baltics==1|inlist(fm_pe_geographicExposure,"COLOMBIA","CHILE","MEXICO","COSTA RICA","UK","UNITED KINGDOM","GERMANY")|inlist(fm_pe_geographicExposure,"FRANCE","SWITZERLAND","NETHERLANDS","AUSTRIA","BELGIUM","LUXEMBOURG","IRELAND","SPAIN")|inlist(fm_pe_geographicExposure,"ITALY","PORTUGAL","POLAND","CZECH REPUBLIC","HUNGARY","SLOVAKIA","SLOVENIA","ISRAEL")|inlist(fm_pe_geographicExposure,"TURKEY","JAPAN","SOUTH KOREA","AUSTRALIA","NEW ZEALAND","OECD"),1,0)
gen geo_exp_asean = cond(inlist(fm_pe_geographicExposure,"SINGAPORE","INDONESIA","VIETNAM","MALAYSIA","THAILAND","PHILIPPINES","MYANMAR","CAMBODIA")|inlist(fm_pe_geographicExposure,"LAOS","BRUNEI","ASEAN"),1,0)
gen geo_exp_brics = cond(inlist(fm_pe_geographicExposure,"BRAZIL","RUSSIA","SOUTH AFRICA","INDIA","CHINA","GREATER CHINA","BRIC"),1,0)
gen geo_exp_australia = fm_pe_geographicExposure=="AUSTRALIA"|fm_pe_geographicExposure=="NEW ZEALAND"

foreach var of varlist geo_exp_* {
	bysort fm_id: egen t_`var' = max(`var')
	drop `var'
	ren t_`var' `var'
}
drop fm_pe_geographicExposure
duplicates drop
merge 1:m fm_id using ".\Data\Data_preqin\preqin_fund_mgrRaw.dta"
drop _m
order geo_exp_*, a(pe_ind_20)
egen no_of_geographies = rowtotal(geo_exp_us geo_exp_canada geo_exp_southamerica geo_exp_centralamerica geo_exp_westeurope geo_exp_easteurope geo_exp_nordic geo_exp_southeurope geo_exp_baltics geo_exp_southasia geo_exp_eastasia geo_exp_centralasia geo_exp_middleeast geo_exp_africa geo_exp_australia), missing
save ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace

//Employees
gen fm_log_total_staff = log(1+fm_total_staff)
gen fm_log_management_team_staff = log(1+fm_management_team_staff)
gen fm_log_investment_team_staff = log(1+fm_investment_team_staff)
gen fm_log_total_AUM_USD = log(fm_total_AUM_USD/1000000)
winsor2 fm_log_total_AUM_USD fm_log_total_staff fm_log_management_team_staff fm_log_investment_team_staff, trim replace cut(0 99)
save ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace

//Top PE firms
//Based on PEI 300 2022, 2021, 2020 and 2019
import excel using ".\Data\Data_preqin\Top 300 PE firms_Source PEI 2022 rankings.xlsx", clear first
keep Institution
ren Institution fm_firm_name
save temp.dta, replace
import excel using ".\Data\Data_preqin\Top 300 PE firms_Source PEI 2021 rankings.xlsx", clear first
keep Firm
ren Firm fm_firm_name
append using temp.dta
save temp.dta, replace
import excel using ".\Data\Data_preqin\Top 300 PE firms_Source PEI 2020 rankings.xlsx", clear first
keep Firm
ren Firm fm_firm_name
append using temp.dta
save temp.dta, replace
import excel using ".\Data\Data_preqin\Top 300 PE firms_Source PEI 2019 rankings.xlsx", clear first
keep Firm
ren Firm fm_firm_name
append using temp.dta
save temp.dta, replace
duplicates drop
sort fm_firm_name

replace fm_firm_name = upper(fm_firm_name)
replace fm_firm_name = "3I" if fm_firm_name=="3I GROUP"
replace fm_firm_name = "50 SOUTH CAPITAL ADVISORS" if fm_firm_name=="50 SOUTH CAPITAL"
replace fm_firm_name = "AGIC CAPITAL" if fm_firm_name=="AGIC GROUP"
replace fm_firm_name = "ALTARIS" if fm_firm_name=="ALTARIS CAPITAL PARTNERS"
replace fm_firm_name = "ALTOR" if fm_firm_name=="ALTOR EQUITY PARTNERS"
replace fm_firm_name = "ALVAREZ & MARSAL CAPITAL" if fm_firm_name=="ALVAREZ & MARSAL CAPITAL PARTNERS"
replace fm_firm_name = "APAX PARTNERS FRANCE" if fm_firm_name=="APAX PARTNERS SAS"
replace fm_firm_name = "ASTORG" if fm_firm_name=="ASTORG PARTNERS"
replace fm_firm_name = "BLACKSTONE GROUP" if fm_firm_name=="BLACKSTONE"
replace fm_firm_name = "BREAKTHROUGH ENERGY VENTURES" if fm_firm_name=="BREAKTHROUGH ENERGY"
replace fm_firm_name = "CATHAY CAPITAL PRIVATE EQUITY" if fm_firm_name=="CATHAY CAPITAL"
replace fm_firm_name = "CDH INVESTMENT" if fm_firm_name=="CDH INVESTMENTS"
replace fm_firm_name = "CHINA EVERBRIGHT LIMITED" if fm_firm_name=="CHINA EVERBRIGHT"
replace fm_firm_name = "CHINA REFORM HOLDINGS" if fm_firm_name=="CHINA REFORM FUND MANAGEMENT CORPORATION"
replace fm_firm_name = "HUAXING GROWTH CAPITAL" if fm_firm_name=="CHINA RENAISSANCE GROUP"
replace fm_firm_name = "CLAYTON DUBILIER & RICE" if fm_firm_name=="CLAYTON, DUBILIER & RICE"
replace fm_firm_name = "CMC CAPITAL GROUP" if fm_firm_name=="CMC CAPITAL PARTNERS"
replace fm_firm_name = "COURT SQUARE" if fm_firm_name=="COURT SQUARE CAPITAL PARTNERS"
replace fm_firm_name = "CPE FUNDS MANAGEMENT" if fm_firm_name=="CPE"
replace fm_firm_name = "CVC" if fm_firm_name=="CVC CAPITAL PARTNERS"
replace fm_firm_name = "CATHAY CAPITAL" if fm_firm_name=="CATHAY CAPITAL PRIVATE EQUITY"
replace fm_firm_name = "CMC CAPITAL PARTNERS" if fm_firm_name=="CMC CAPITAL GROUP"
replace fm_firm_name = "CBC GROUP" if fm_firm_name=="C-BRIDGE CAPITAL"
replace fm_firm_name = "DENHAM CAPITAL" if fm_firm_name=="DENHAM CAPITAL MANAGEMENT"
replace fm_firm_name = "EVOLUTION CAPITAL PARTNERS (ECP)" if fm_firm_name=="ECP"
replace fm_firm_name = "EIGHT ROADS VENTURES" if fm_firm_name=="EIGHT ROADS"
replace fm_firm_name = "FREEMAN SPOGLI & CO" if fm_firm_name=="FREEMAN SPOGLI & CO."
replace fm_firm_name = "FSN CAPITAL" if fm_firm_name=="FSN CAPITAL PARTNERS"
replace fm_firm_name = "FUNDAMENTAL PARTNERS" if fm_firm_name=="FUNDAMENTAL ADVISORS"
replace fm_firm_name = "GENSTAR CAPITAL PARTNERS" if fm_firm_name=="GENSTAR CAPITAL"
replace fm_firm_name = "GHO CAPITAL" if fm_firm_name=="GHO CAPITAL PARTNERS"
replace fm_firm_name = "GHO CAPITAL" if fm_firm_name=="GHO CAPITAL PARTNERS"
replace fm_firm_name = "GOLDMAN SACHS ASSET MANAGEMENT" if fm_firm_name=="GOLDMAN SACHS"
replace fm_firm_name = "GOLDMAN SACHS ASSET MANAGEMENT" if fm_firm_name=="GOLDMAN SACHS MERCHANT BANKING DIVISION"
replace fm_firm_name = "HAHN & COMPANY" if fm_firm_name=="HAHN & CO."
replace fm_firm_name = "HILLHOUSE CAPITAL MANAGEMENT" if fm_firm_name=="HILLHOUSE CAPITAL GROUP"
replace fm_firm_name = "IK PARTNERS" if fm_firm_name=="IK INVESTMENT PARTNERS"
replace fm_firm_name = "IMPERIAL CAPITAL GROUP" if fm_firm_name=="IMPERIAL CAPITAL"
replace fm_firm_name = "INFLEXION PRIVATE EQUITY PARTNERS" if fm_firm_name=="INFLEXION PRIVATE EQUITY"
replace fm_firm_name = "INSTITUTIONAL VENTURE PARTNERS" if fm_firm_name=="IVP"
replace fm_firm_name = "JAFCO GROUP" if fm_firm_name=="JAFCO CO"
replace fm_firm_name = "LINDEN" if fm_firm_name=="LINDEN CAPITAL PARTNERS"
replace fm_firm_name = "LITTLEJOHN & CO." if fm_firm_name=="LITTLEJOHN & CO"
replace fm_firm_name = "LUX CAPITAL" if fm_firm_name=="LUX CAPITAL MANAGEMENT"
replace fm_firm_name = "LENOVO VENTURE CAPITAL" if fm_firm_name=="LENOVO GROUP"
replace fm_firm_name = "MORGAN STANLEY" if fm_firm_name=="MORGAN STANLEY INVESTMENT MANAGEMENT"
replace fm_firm_name = "NEUBERGER BERMAN" if fm_firm_name=="NEUBERGER BERMAN PRIVATE MARKETS"
replace fm_firm_name = "NEUBERGER BERMAN" if fm_firm_name=="NB ALTERNATIVES"
replace fm_firm_name = "NGP" if fm_firm_name=="NGP ENERGY CAPITAL MANAGEMENT"
replace fm_firm_name = "OAK HC/FT PARTNERS" if fm_firm_name=="OAK HC/FT"
replace fm_firm_name = "OAKLEY CAPITAL" if fm_firm_name=="OAKLEY CAPITAL PRIVATE EQUITY"
replace fm_firm_name = "PAMPLONA CAPITAL MANAGEMENT" if fm_firm_name=="PAMPLONA CAPITAL PARTNERS"
replace fm_firm_name = "PARTHENON CAPITAL" if fm_firm_name=="PARTHENON CAPITAL PARTNERS"
replace fm_firm_name = "PARTECH" if fm_firm_name=="PARTECH PARTNERS"
replace fm_firm_name = "PERMIRA" if fm_firm_name=="PERMIRA ADVISERS"
replace fm_firm_name = "PRIMAVERA CAPITAL" if fm_firm_name=="PRIMAVERA CAPITAL GROUP"
replace fm_firm_name = "PROVIDENCE STRATEGIC GROWTH" if fm_firm_name=="PSG"
replace fm_firm_name = "QUAD-C" if fm_firm_name=="QUAD-C MANAGEMENT"
replace fm_firm_name = "RHôNE GROUP" if fm_firm_name=="RHONE GROUP"
replace fm_firm_name = "RIDGEWOOD CAPITAL" if fm_firm_name=="RIDGEWOOD ENERGY"
replace fm_firm_name = "THE RIVERSIDE COMPANY" if fm_firm_name=="RIVERSIDE COMPANY"
replace fm_firm_name = "ROCKET INTERNET SE" if fm_firm_name=="ROCKET INTERNET"
replace fm_firm_name = "SIRIS CAPITAL" if fm_firm_name=="SIRIS CAPITAL GROUP"
replace fm_firm_name = "SK CAPITAL" if fm_firm_name=="SK CAPITAL PARTNERS"
replace fm_firm_name = "CARLYLE GROUP" if fm_firm_name=="THE CARLYLE GROUP"
replace fm_firm_name = "ENERGY & MINERALS GROUP" if fm_firm_name=="THE ENERGY & MINERALS GROUP"
replace fm_firm_name = "RIVERSIDE COMPANY" if fm_firm_name=="THE RIVERSIDE COMPANY"
replace fm_firm_name = "THOMAS H LEE PARTNERS" if fm_firm_name=="THOMAS H. LEE PARTNERS"
replace fm_firm_name = "TOWERBROOK" if fm_firm_name=="TOWERBROOK CAPITAL PARTNERS"
replace fm_firm_name = "TRILANTIC NORTH AMERICA" if fm_firm_name=="TRILANTIC CAPITAL PARTNERS NORTH AMERICA"
replace fm_firm_name = "VäRDE PARTNERS" if fm_firm_name=="VARDE PARTNERS"
replace fm_firm_name = "VERTEX" if fm_firm_name=="VERTEX HOLDINGS"
replace fm_firm_name = "THE VISTRIA GROUP" if fm_firm_name=="VISTRIA GROUP"
replace fm_firm_name = "THE VISTRIA GROUP" if fm_firm_name=="VISTRIA GROUP"
replace fm_firm_name = "WATERLAND PRIVATE EQUITY INVESTMENTS B.V." if fm_firm_name=="WATERLAND PRIVATE EQUITY INVESTMENTS"
replace fm_firm_name = "WELLINGTON MANAGEMENT" if fm_firm_name=="WELLINGTON MANAGEMENT COMPANY"
replace fm_firm_name = "YF CAPITAL" if fm_firm_name=="YUNFENG CAPITAL"
replace fm_firm_name = "BPEA EQT" if fm_firm_name=="BARING PRIVATE EQUITY ASIA"
replace fm_firm_name = "PáTRIA INVESTIMENTOS" if fm_firm_name=="PATRIA INVESTMENTS"
replace fm_firm_name = "PáTRIA INVESTIMENTOS" if fm_firm_name=="PATRIA INVESTMENTOS"
replace fm_firm_name = "J.F. LEHMAN & COMPANY" if fm_firm_name=="JF LEHMAN & COMPANY"
replace fm_firm_name = "JP MORGAN ASSET MANAGEMENT" if fm_firm_name=="JPMORGAN ASSET MANAGEMENT"
replace fm_firm_name = "HG" if fm_firm_name=="HG CAPITAL"
replace fm_firm_name = "PINE BROOK PARTNERS" if fm_firm_name=="PINE BROOK"
replace fm_firm_name = "NEUBERGER BERMAN" if fm_firm_name=="NEUBERGER BERMAN GROUP"
replace fm_firm_name = "TAILWIND CAPITAL" if fm_firm_name=="TAILWIND CAPITAL PARTNERS"
replace fm_firm_name = "PARTECH PARTNERS" if fm_firm_name=="PARTECH"
replace fm_firm_name = "GEORGIAN" if fm_firm_name=="GEORGIAN PARTNERS"
replace fm_firm_name = "DCM" if fm_firm_name=="DCM VENTURES"
replace fm_firm_name = "TRITON" if fm_firm_name=="TRITON PARTNERS"
replace fm_firm_name = "ENERGY CAPITAL PARTNERS" if fm_firm_name=="ENERGY CAPITAL PARTNERS MANAGEMENT"
replace fm_firm_name = "BERNHARD CAPITAL PARTNERS MANAGEMENT" if fm_firm_name=="BERNHARD CAPITAL PARTNERS"
replace fm_firm_name = "FORESITE CAPITAL" if fm_firm_name=="FORESITE CAPITAL MANAGEMENT"
replace fm_firm_name = "JAFCO GROUP" if fm_firm_name=="JAFCO"
replace fm_firm_name = "ASTORG" if fm_firm_name=="ASTORG CAPITAL PARTNERS"
replace fm_firm_name = "EDGEWATER FUNDS" if fm_firm_name=="THE EDGEWATER FUNDS"
replace fm_firm_name = "DEUTSCHE BETEILIGUNGS" if fm_firm_name=="DEUTSCHE BETEILIGUNGS AG"
replace fm_firm_name = "WATERLAND PRIVATE EQUITY INVESTMENTS B.V." if fm_firm_name=="WATERLAND PRIVATE EQUITY INVESTMENT"
replace fm_firm_name = "EQT LIFE SCIENCES" if fm_firm_name=="LIFE SCIENCES PARTNERS"
replace fm_firm_name = "FSI SGR" if fm_firm_name=="FONDO FSI"
replace fm_firm_name = "ARBOR PRIVATE INVESTMENT COMPANY" if fm_firm_name=="ARBOR INVESTMENTS"
replace fm_firm_name = "KLEINER PERKINS" if fm_firm_name=="KLEINER PERKINS CAUFIELD & BYERS"
replace fm_firm_name = "PRITZKER PRIVATE CAPITAL" if fm_firm_name=="PPC PARTNERS"
replace fm_firm_name = "MORNINGSIDE VENTURE PARTNERS" if fm_firm_name=="MORNINGSIDE VENTURE CAPITAL"
replace fm_firm_name = "DATA COLLECTIVE" if fm_firm_name=="DCVC"
replace fm_firm_name = "CITI PRIVATE EQUITY" if fm_firm_name=="CITIC PRIVATE EQUITY FUNDS MANAGEMENT"
replace fm_firm_name = "CITI PRIVATE EQUITY" if fm_firm_name=="CITIC PRIVATE EQUITY FUNDS MANAGEMENT"
replace fm_firm_name = "ARES MANAGEMENT" if fm_firm_name=="SSG CAPITAL MANAGEMENT"
replace fm_firm_name = "DST GLOBAL" if fm_firm_name=="DIGITAL SKY TECHNOLOGIES"
replace fm_firm_name = "RIVEAN CAPITAL" if fm_firm_name=="GILDE BUY OUT PARTNERS"
replace fm_firm_name = "HAHN & COMPANY" if fm_firm_name=="HAHN & CO"
replace fm_firm_name = "ARC FINANCIAL CORP" if fm_firm_name=="ARC FINANCIAL CORPORATION"
duplicates drop
merge 1:m fm_firm_name using ".\Data\Data_preqin\preqin_fund_mgrRaw.dta"
gen topPEFirm = cond(_m==3,1,0)
drop if _m==1
drop _m

//Based on Preqin Top 100 PE 2017
replace topPEFirm = 1 if fm_firm_name=="COLLER CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="JC FLOWERS & CO"
replace topPEFirm = 1 if fm_firm_name=="LEXINGTON PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="RRJ CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="ATP PRIVATE EQUITY PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="CCMP CAPITAL ADVISORS"
replace topPEFirm = 1 if fm_firm_name=="CHARTERHOUSE CAPITAL PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="COMMONFUND"
replace topPEFirm = 1 if fm_firm_name=="DST GLOBAL"
replace topPEFirm = 1 if fm_firm_name=="FORTRESS INVESTMENT GROUP"
replace topPEFirm = 1 if fm_firm_name=="HORSLEY BRIDGE PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="JPMORGAN PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="PORTFOLIO ADVISORS"
replace topPEFirm = 1 if fm_firm_name=="TERRA FIRMA CAPITAL PARTNERS"

//Based on Preqin Top 100 VC 2017
replace topPEFirm = 1 if fm_firm_name=="ABINGWORTH"
replace topPEFirm = 1 if fm_firm_name=="ATHYRIUM CAPITAL MANAGEMENT"
replace topPEFirm = 1 if fm_firm_name=="AUGUST CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="BAIN CAPITAL VENTURES"
replace topPEFirm = 1 if fm_firm_name=="BANYAN CAPITAL PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="BENCHMARK CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="BLUE RIDGE CHINA"
replace topPEFirm = 1 if fm_firm_name=="BRYSAM GLOBAL PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="DAG VENTURES"
replace topPEFirm = 1 if fm_firm_name=="DEERFIELD MANAGEMENT"
replace topPEFirm = 1 if fm_firm_name=="DRI CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="FORMATION8"
replace topPEFirm = 1 if fm_firm_name=="FORTUNE VENTURE CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="FOUNDATION CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="INTELLECTUAL VENTURES"
replace topPEFirm = 1 if fm_firm_name=="KHOSLA VENTURES"
replace topPEFirm = 1 if fm_firm_name=="LONGITUDE CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="MAYFIELD FUND"
replace topPEFirm = 1 if fm_firm_name=="MEDICI FIRMA VENTURE"
replace topPEFirm = 1 if fm_firm_name=="MITHRIL CAPITAL MANAGEMENT"
replace topPEFirm = 1 if fm_firm_name=="MPM CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="NEWMARGIN VENTURES"
replace topPEFirm = 1 if fm_firm_name=="NEXUS VENTURE PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="ROCKET INTERNET SE"
replace topPEFirm = 1 if fm_firm_name=="SAMSUNG VENTURE INVESTMENT"
replace topPEFirm = 1 if fm_firm_name=="SINOVATION VENTURES"
replace topPEFirm = 1 if fm_firm_name=="SOCIAL CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="SOFINNOVA PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="TENAYA CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="THIRD ROCK VENTURES"
replace topPEFirm = 1 if fm_firm_name=="TRINITY VENTURES"
replace topPEFirm = 1 if fm_firm_name=="WESTERN TECHNOLOGY INVESTMENT"
replace topPEFirm = 1 if fm_firm_name=="HEALTHCARE ROYALTY PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="NORTHERN LIGHT VENTURE CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="SOFTBANK CHINA VENTURE CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="OAK INVESTMENT PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="THE COLUMN GROUP"
replace topPEFirm = 1 if fm_firm_name=="HIGHLAND CAPITAL PARTNERS" & fm_id==368
replace topPEFirm = 1 if fm_firm_name=="ICONIQ CAPITAL"
replace topPEFirm = 1 if fm_firm_name=="REVOLUTION VENTURES"
replace topPEFirm = 1 if fm_firm_name=="FRAZIER HEALTHCARE PARTNERS"
replace topPEFirm = 1 if fm_firm_name=="KLEINER PERKINS"
replace topPEFirm = 1 if fm_firm_name=="LUX CAPITAL"

//Based on participants in the Walker report
replace topPEFirm=1 if fm_firm_name=="TEACHERS' INNOVATION PLATFORM"
replace topPEFirm=1 if fm_firm_name=="BAIN CAPITAL CREDIT"
replace topPEFirm=1 if fm_firm_name=="DH PRIVATE EQUITY PARTNERS"
replace topPEFirm=1 if fm_firm_name=="CBPE CAPITAL"
replace topPEFirm=1 if fm_firm_name=="EPIRIS"
replace topPEFirm=1 if fm_firm_name=="CIC INTERNATIONAL"
replace topPEFirm=1 if fm_firm_name=="HORIZON CAPITAL"
replace topPEFirm=1 if fm_firm_name=="VISION CAPITAL"
replace topPEFirm=1 if fm_firm_name=="ICG"
replace topPEFirm=1 if fm_firm_name=="AMP CAPITAL INVESTORS"
replace topPEFirm=1 if fm_firm_name=="AVENUE CAPITAL GROUP"
replace topPEFirm=1 if fm_firm_name=="CANDOVER PARTNERS"
replace topPEFirm=1 if fm_firm_name=="WPP VENTURES"
replace topPEFirm=1 if fm_firm_name=="ALBERTA INVESTMENT MANAGEMENT CORPORATION"
replace topPEFirm=1 if fm_firm_name=="ALCHEMY PARTNERS"
replace topPEFirm=1 if fm_firm_name=="ANGELO, GORDON & CO"
replace topPEFirm=1 if fm_firm_name=="ARCAPITA"
replace topPEFirm=1 if fm_firm_name=="ARLE CAPITAL PARTNERS"
replace topPEFirm=1 if fm_firm_name=="CAIRD CAPITAL"
replace topPEFirm=1 if fm_firm_name=="DUBAI INTERNATIONAL CAPITAL"
replace topPEFirm=1 if fm_firm_name=="DUKE STREET"
replace topPEFirm=1 if fm_firm_name=="EXPONENT PRIVATE EQUITY"
replace topPEFirm=1 if fm_firm_name=="FORMATION CAPITAL"
replace topPEFirm=1 if fm_firm_name=="GOLDENTREE ASSET MANAGEMENT"
replace topPEFirm=1 if fm_firm_name=="HONY CAPITAL"
replace topPEFirm=1 if fm_firm_name=="IFM INVESTORS"
replace topPEFirm=1 if fm_firm_name=="LION CAPITAL"
replace topPEFirm=1 if fm_firm_name=="LONE STAR FUNDS"
replace topPEFirm=1 if fm_firm_name=="MARATHON ASSET MANAGEMENT"
replace topPEFirm=1 if fm_firm_name=="MAY CAPITAL"
replace topPEFirm=1 if fm_firm_name=="PALAMON CAPITAL PARTNERS"
replace topPEFirm=1 if fm_firm_name=="QIC"
replace topPEFirm=1 if fm_firm_name=="SAFANAD"
replace topPEFirm=1 if fm_firm_name=="STAR CAPITAL PARTNERS"
replace topPEFirm=1 if fm_firm_name=="YORK CAPITAL MANAGEMENT"
ren topPEFirm topPEFirmReports

//Based on total 
gen topPEFirmAUM=1 if fm_total_AUM_USD>1000 & !missing(fm_total_AUM_USD)
replace topPEFirmAUM=1 if fm_PE_AUM_USD>300 & !missing(fm_PE_AUM_USD)
sort fm_id

//Variable Labels
label var fm_log_total_AUM_USD "Log(Total AUM Tn.) "
label var pe_ind_1 "PE Industry: IT/Technology"
label var pe_ind_2 "PE Industry: Media"
label var pe_ind_3 "PE Industry: Business Services"
label var pe_ind_4 "PE Industry: Healthcare/Pharma"
label var pe_ind_5 "PE Industry: Agribusiness"
label var pe_ind_6 "PE Industry: Energy/Oil"
label var pe_ind_7 "PE Industry: Industrials"
label var pe_ind_8 "PE Industry: Electronics"
label var pe_ind_9 "PE Industry: Chemicals"
label var pe_ind_10 "PE Industry: Real Estate"
label var pe_ind_11 "PE Industry: Financial Services"
label var pe_ind_12 "PE Industry: Retail/Consumer goods"
label var pe_ind_13 "PE Industry: Automotive"
label var pe_ind_14 "PE Industry: Heating/Cooling Equipment"
label var pe_ind_15 "PE Industry: Defense"
label var pe_ind_16 "PE Industry: Logistics"
label var pe_ind_17 "PE Industry: Packaging"
label var pe_ind_18 "PE Industry: Renewables"
label var pe_ind_19 "PE Industry: Education"
label var pe_ind_20 "PE Industry: Diversified"
label var no_of_industries "Number of Industries"
label var fm_pe_strat_buyout "PE Strategy: Buyout"
label var fm_pe_strat_venture "PE Strategy: Venture"
label var fm_pe_strat_growth "PE Strategy: Growth"
label var fm_pe_strat_balance "PE Strategy: Balanced"
label var fm_pe_strat_others "PE Strategy: Others"
label var fm_ownership_independent "PE Ownership: Independent"
label var fm_ownership_captive "PE Ownership: Captive"
label var fm_ownership_spinoff "PE Ownership: Spinoff"
label var fm_ownership_family "PE Ownership: Family"
label var fm_women_owned_num "Women Owned"
label var fm_minority_owned_num "Minority Owned"
label var fm_listed_num "Listed"
label var fm_log_total_staff "Log(No. of Employees)"
label var fm_log_investment_team_staff "Log(No. of Investment staff)"
label var fm_log_management_team_staff "Log(No. of Management staff)"
label var geo_exp_us "Geo Exposure: US"
label var geo_exp_canada "Geo Exposure: Canada"
label var geo_exp_southamerica "Geo Exposure: South America"
label var geo_exp_centralamerica "Geo Exposure: Central America"
label var geo_exp_westeurope "Geo Exposure: West Europe"
label var geo_exp_easteurope "Geo Exposure: East Europe"
label var geo_exp_southeurope "Geo Exposure: South Europe"
label var geo_exp_nordic "Geo Exposure: Nordics"
label var geo_exp_baltics "Geo Exposure: Baltics"
label var geo_exp_southasia "Geo Exposure: South Asia"
label var geo_exp_eastasia "Geo Exposure: East Asia"
label var geo_exp_centralasia "Geo Exposure: Central Asia"
label var geo_exp_middleeast "Geo Exposure: Middle East"
label var geo_exp_africa "Geo Exposure: Africa"
label var geo_exp_china "Geo Exposure: China"
label var geo_exp_australia "Geo Exposure: Australia"
label var no_of_geographies "Number of Geographies"
label var country_us "PE Firm HQ: US"
label var country_cn "PE Firm HQ: China"
label var country_eu "PE Firm HQ: EU"
label var country_uk "PE Firm HQ: UK"
label var country_canada "PE Firm HQ: Canada"
label var country_india "PE Firm HQ: India"
label var topPEFirmReports "Top PE Firm - Preqin & PEI Based"
label var topPEFirmAUM "Top PE Firm - Size Based"
save ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace
}
**Funds & Fund Performance**
{
import excel using ".\Data\Data_preqin\Preqin_funds_20230218.xlsx", clear first
save ".\Data\Data_preqin\preqin_fund.dta", replace

use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace
keep fm_id
ren fm_id FIRMID
merge 1:m FIRMID using ".\Data\Data_preqin\preqin_fund.dta"
keep if _m==3 //keeping only funds for which I can identify the parent firm
drop _m 

drop FUNDMANAGER REGION ADDRESS CITY STATE ZIPCODE COUNTRY WEBSITE EMAIL TEL FAX SECONDARYLOCATIONS OPENENDRETURNSASATDATE OPENENDRETURNS1MONTH OPENENDRETURNS3MONTHS OPENENDRETURNS6MONTHS OPENENDRETURNS9MONTHS OPENENDRETURNS12MONTHS OPENENDRETURNSYTD OPENENDRETURNS2YEARSPA OPENENDRETURNS3YEARSPA OPENENDRETURNS5YEARSPA OPENENDRETURNS10YEARSP FUNDMANAGERTOTALAUMCURRMN FUNDMANAGERTOTALAUMUSDMN FUNDMANAGERTOTALAUMEURMN

ren (FIRMID - GEOGRAPHICEXPOSURE) ///
	(fm_id f_id f_fundSeriesID f_name f_vintageInceptionYear f_assetClass f_strategy f_primaryRegionFocus f_status f_fundSize_USD f_fundStructure f_domicile f_dateAdded f_fundLegalStructure f_fundNumberOverall f_fundNumberSeries f_fundSeriesName f_singleDealFund f_lifeSpanYears f_lifeSpanExtension f_solelyFinancedBy f_targetIRRNetMin f_targetIRRNetMax f_targetIRRGrossMin f_targetIRRGrossMax f_fundCurrency f_targetSize_curr f_targetSize_USD f_targetSize_EUR f_initialTarget_curr f_initialTarget_USD f_initialTarget_EUR f_harcap_curr f_hardcap_USD f_hardcap_EUR f_fundRaisingLaunchDate f_latestCloseDate f_latestInterimCloseDate f_latestInterimCloseSize_curr f_latestInterimCloseSize_USD f_latestInterimCloseSize_EUR f_finalCloseDate f_finalCloseSize_curr f_finalCloseSize_USD f_finalCloseSize_EUR f_offerCoInvstOpporunties f_coInvstCapitalAmount_curr f_coInvstCapitalAmount_USD f_coInvstCapitalAmount_EUR f_months2FirstClose f_monthsInMarket f_coreIndustries f_industries f_industryVerticals f_buyoutFundLeverage f_buyoutFundSize f_invstSizePerFolioFirmMin f_invstSizePerFolioFirmMax f_PEFOFPreferences f_placementAgents f_lawFirms f_mgmtFeeInInvstPeriod f_chargeFrequency f_invstPeriod f_mgmtFeeRednMechanism f_mgmtFeeAfterInvstPeriod f_largeLPSpecialProv f_carriedInterest f_carriedIntBasis f_GPCatchUpRate f_hurdleRate f_KeyManClause f_LPTxnFeeRebateShare f_NoFaultDivorce f_reqdLPMajority f_fundFormationCost f_AdvisoryBoardLPRep f_GPCommits2Fund f_noOfLPsMin f_noOfLPsMax f_returningLPspercent f_estimatedLaunch f_geographicFocus f_administrators f_auditors f_primeBrokers f_custodians f_otherGeographies f_subscriptionCreditFacility f_geographicExposure)
	
order fm_id f_id f_name f_status f_assetClass f_strategy f_fundSeriesID f_fundSeriesName f_dateAdded f_fundStructure f_fundLegalStructure f_domicile f_vintageInceptionYear f_fundSize_USD f_fundNumberOverall f_fundNumberSeries f_singleDealFund f_lifeSpanYears f_lifeSpanExtension f_solelyFinancedBy f_subscriptionCreditFacility f_targetIRRNetMin f_targetIRRNetMax f_targetIRRGrossMin f_targetIRRGrossMax f_fundCurrency f_estimatedLaunch f_targetSize_curr f_targetSize_USD f_targetSize_EUR f_fundRaisingLaunchDate f_latestCloseDate f_latestInterimCloseDate f_latestInterimCloseSize_curr f_latestInterimCloseSize_USD f_latestInterimCloseSize_EUR f_finalCloseDate f_finalCloseSize_curr f_finalCloseSize_USD f_finalCloseSize_EUR f_monthsInMarket f_months2FirstClose f_initialTarget_curr f_initialTarget_USD f_initialTarget_EUR f_harcap_curr f_hardcap_USD f_hardcap_EUR f_offerCoInvstOpporunties f_coInvstCapitalAmount_curr f_coInvstCapitalAmount_USD f_coInvstCapitalAmount_EUR f_primaryRegionFocus f_geographicExposure f_geographicFocus f_otherGeographies f_coreIndustries f_industries f_industryVerticals f_buyoutFundSize f_buyoutFundLeverage f_invstSizePerFolioFirmMin f_invstSizePerFolioFirmMax f_placementAgents f_lawFirms f_administrators f_auditors f_primeBrokers f_custodians f_mgmtFeeInInvstPeriod f_chargeFrequency f_invstPeriod f_mgmtFeeRednMechanism f_mgmtFeeAfterInvstPeriod f_largeLPSpecialProv f_carriedInterest f_carriedIntBasis f_GPCatchUpRate f_hurdleRate f_KeyManClause f_LPTxnFeeRebateShare f_NoFaultDivorce f_reqdLPMajority f_fundFormationCost f_AdvisoryBoardLPRep f_GPCommits2Fund f_noOfLPsMin f_noOfLPsMax f_returningLPspercent

foreach var of varlist f_name f_status f_assetClass f_strategy f_fundStructure f_fundLegalStructure f_domicile f_singleDealFund f_subscriptionCreditFacility f_primaryRegionFocus f_geographicExposure f_geographicFocus f_otherGeographies f_coreIndustries f_industries f_industryVerticals f_buyoutFundSize f_placementAgents f_lawFirms f_administrators f_auditors f_primeBrokers f_custodians f_chargeFrequency f_mgmtFeeRednMechanism f_carriedIntBasis {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
}
sort fm_id f_fundNumberOverall	
save ".\Data\Data_preqin\preqin_fund.dta", replace

local i = 1
forvalues y = 2000/2022 {
	forvalues m = 3(3)12 {
		local Y: di %4.0f `y'
		local M: di %02.0f `m' 
		local newname = "`Y'`M'"
		capture confirm file ".\Data\Data_preqin\Preqin_Fundperformance_`newname'_20230218.xlsx"
		if _rc==0 {
			qui import excel using ".\Data\Data_preqin\Preqin_Fundperformance_`newname'_20230218.xlsx", clear first all
			if `i'==1 {
				qui save ".\Data\Data_preqin\preqin_fundPerformance.dta", replace
				local ++i
			}
			else {
				qui append using ".\Data\Data_preqin\preqin_fundPerformance.dta"
				qui save ".\Data\Data_preqin\preqin_fundPerformance.dta", replace
			}
			di "`newname'"
		}
	}
}
keep FUNDID FIRMID NAME NETIRR NETMULTIPLEX RVPI DPI CALLED PREQINQUARTILERANK QUARTILERANK DATEREPORTED BENCHMARKNAME MEDIANBENCHMARKNETIRR MEDIANBENCHMARKCALLED MEDIANBENCHMARKDISTRIBUTED MEDIANBENCHMARKNETMULTIPLEX MEDIANBENCHMARKRVPI AVERAGEBENCHMARKNETIRR AVERAGEBENCHMARKCALLED AVERAGEBENCHMARKDISTRIBUTED AVERAGEBENCHMARKNETMULTIPLE AVERAGEBENCHMARKRVPI WEIGHTEDBENCHMARKNETIRR WEIGHTEDBENCHMARKCALLED WEIGHTEDBENCHMARKDISTRIBUTED WEIGHTEDBENCHMARKNETMULTIPLE WEIGHTEDBENCHMARKRVPI POOLEDBENCHMARKNETIRR SP500DIRECTALPHA SP500LNPME SP500KSPME SP500PME RUSSELL2000DIRECTALPHA RUSSELL2000LNPME RUSSELL2000KSPME RUSSELL2000PME RUSSELL3000DIRECTALPHA RUSSELL3000LNPME RUSSELL3000KSPME RUSSELL3000PME MSCIEMERGINGMARKETSDIRECTA MSCIEMERGINGMARKETSLNPME MSCIEMERGINGMARKETSKSPME MSCIEMERGINGMARKETSPME MSCIEUROPESTANDARDDIRECTAL MSCIEUROPESTANDARDLNPME MSCIEUROPESTANDARDKSPME MSCIEUROPESTANDARDPME MSCIUSREITDIRECTALPHA MSCIUSREITLNPME MSCIUSREITKSPME MSCIUSREITPME MSCIWORLDDIRECTALPHA MSCIWORLDLNPME MSCIWORLDKSPME MSCIWORLDPME FUNDAUMCURRMN FUNDAUMUSDMN FUNDAUMEURMN FUNDDRYPOWDERCURRMN FUNDDRYPOWDERUSDMN FUNDDRYPOWDEREURMN FUNDUNREALIZEDVALUECURRMN FUNDUNREALIZEDVALUEUSDMN FUNDUNREALIZEDVALUEEURMN

order FUNDID FIRMID NAME NETIRR NETMULTIPLEX RVPI DPI CALLED PREQINQUARTILERANK QUARTILERANK DATEREPORTED BENCHMARKNAME MEDIANBENCHMARKNETIRR MEDIANBENCHMARKCALLED MEDIANBENCHMARKDISTRIBUTED MEDIANBENCHMARKNETMULTIPLEX MEDIANBENCHMARKRVPI AVERAGEBENCHMARKNETIRR AVERAGEBENCHMARKCALLED AVERAGEBENCHMARKDISTRIBUTED AVERAGEBENCHMARKNETMULTIPLE AVERAGEBENCHMARKRVPI WEIGHTEDBENCHMARKNETIRR WEIGHTEDBENCHMARKCALLED WEIGHTEDBENCHMARKDISTRIBUTED WEIGHTEDBENCHMARKNETMULTIPLE WEIGHTEDBENCHMARKRVPI POOLEDBENCHMARKNETIRR SP500DIRECTALPHA SP500LNPME SP500KSPME SP500PME RUSSELL2000DIRECTALPHA RUSSELL2000LNPME RUSSELL2000KSPME RUSSELL2000PME RUSSELL3000DIRECTALPHA RUSSELL3000LNPME RUSSELL3000KSPME RUSSELL3000PME MSCIEMERGINGMARKETSDIRECTA MSCIEMERGINGMARKETSLNPME MSCIEMERGINGMARKETSKSPME MSCIEMERGINGMARKETSPME MSCIEUROPESTANDARDDIRECTAL MSCIEUROPESTANDARDLNPME MSCIEUROPESTANDARDKSPME MSCIEUROPESTANDARDPME MSCIUSREITDIRECTALPHA MSCIUSREITLNPME MSCIUSREITKSPME MSCIUSREITPME MSCIWORLDDIRECTALPHA MSCIWORLDLNPME MSCIWORLDKSPME MSCIWORLDPME FUNDAUMCURRMN FUNDAUMUSDMN FUNDAUMEURMN FUNDDRYPOWDERCURRMN FUNDDRYPOWDERUSDMN FUNDDRYPOWDEREURMN FUNDUNREALIZEDVALUECURRMN FUNDUNREALIZEDVALUEUSDMN FUNDUNREALIZEDVALUEEURMN

destring FIRMID FUNDID NETIRR NETMULTIPLEX RVPI DPI CALLED MEDIANBENCHMARKNETIRR - FUNDUNREALIZEDVALUEEURMN, replace force
gen t_DATEREPORTED = date(DATEREPORTED,"DMY")
drop DATEREPORTED
ren t_DATEREPORTED DATEREPORTED
order DATEREPORTED, a(QUARTILERANK)
order FIRMID, b(FUNDID)
format DATEREPORTED %td
sort FIRMID FUNDID DATEREPORTED

ren (FIRMID FUNDID NAME) (fm_id f_id f_name)
ren (NETIRR - MSCIWORLDPME) ///
	(f_netIRR f_netMultipleX f_RVPI f_DPI f_Called f_preqinQuartileRank f_quartileRank f_dateReported f_benchmarkName f_medianBenchmarkNetIRR f_medianBenchmarkCalled f_medianBenchmarkDPI f_medianBenchmarkNetMultiple f_medianBenchmarkRVPI f_meanBenchmarkNetIRR f_meanBenchmarkCalled f_meanBenchmarkDPI f_meanBenchmarkNetMultiple f_meanBenchmarkRVPI f_wgtBenchmarkNetIRR f_wgtBenchmarkCalled f_wgtBenchmarkDPI f_wgtBenchmarkNetMultiple f_wgtBenchmarkRVPI f_pooledBenchmarkNetIRR f_SP500DirectAlpha f_SP500LNPME f_SP500KSPME f_SP500PMEplus f_Russell2kDirectAlpha f_Russell2kLNPME f_Russell2kKSPME f_Russell2kPMEplus f_Russell3kDirectAlpha f_Russell3kLNPME f_Russell3kKSPME f_Russell3kPMEplus f_MSCIEMDirectAlpha f_MSCIEMLNPME f_MSCIEMKSPME f_MSCIEMPMEPlus f_MSCIEuropeDirectAlpha f_MSCIEuropeLNPME f_MSCIEuropeKSPME f_MSCIEuropePMEPlus f_MSCIUSDirectAlpha f_MSCIUSLNPME f_MSCIUSKSPME f_MSCIUSPMEPlus f_MSCIWorldDirectAlpha f_MSCIWorldLNPME f_MSCIWorldKSPME f_MSCIWorldPMEPlus)
ren (FUNDAUMCURRMN - FUNDUNREALIZEDVALUEEURMN) ///
	(f_AUM_curr f_AUM_USD f_AUM_EUR f_dryPowder_curr f_dryPowder_USD f_dryPowder_EUR f_unrealizedValue_curr f_unrealizedValue_USD f_unrealizedValue_EUR)
foreach var of varlist f_preqinQuartileRank f_quartileRank {
	replace `var' = substr(`var',1,1)
}
destring f_preqinQuartileRank f_quartileRank, replace force
foreach var of varlist f_name f_benchmarkName {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')	
}
save ".\Data\Data_preqin\preqin_fundPerformance.dta", replace
}
**Deals & Exits**
{
**Buyouts
import excel using ".\Data\Data_preqin\Preqin_investors_lenders_Buyout_20230324.xlsx", clear first
order DEALID  DEALDATE  DEALSTATUS ACQUIREDSHARE  DEALCURRENCY  DEALSIZECURRMN  DEALSIZEUSDMN  DEALSIZEEURMN  DEALSIZEEQUITYCURRMN  DEALSIZEEQUITYUSDMN  DEALSIZEEQUITYEURMN  PORTFOLIOCOMPANYID  PORTFOLIOCOMPANY    PORTFOLIOCOMPANYCITY  PORTFOLIOCOMPANYSTATECOUNTY  PORTFOLIOCOMPANYCOUNTRY  PORTFOLIOCOMPANYREGION  PORTFOLIOCOMPANYWEBSITE    PORTFOLIOCOMPANYSTATUS  PRIMARYINDUSTRY  SUBINDUSTRIES  INDUSTRYVERTICALS  INDUSTRYCLASSIFICATION  COMPANYREVENUECURRMN  ENTRYREVENUEMULTIPLE  EBITDACURRMN  ENTRYEBITDAMULTIPLE    CAPITALSTRUCTURE  INVESTORID  INVESTORSBUYERSFIRMS  INVESTORSBUYERSFUNDS  INVESTORTYPE  INVESTORCITY  INVESTORSTATECOUNTY  INVESTORCOUNTRY  INVESTORREGION  INVESTMENTTYPE  INVESTMENTSTAKE  BOUGHTFROMSELLERSFIRMS  LEADPARTNERS  BOARDREPRESENTATIVES  DEBTSIZECURRMN  DEBTSIZEUSDMN  DEBTSIZEEURMN  FINANCIALADVISORSBUYERS  FINANCIALADVISORSSELLERS  LEGALADVISORSBUYERS  LEGALADVISORSSELLERS  DEBTPROVIDERID  DEBTPROVIDERNAME  DEBTPROVIDERSFUNDS
ren (DEALID - DEBTPROVIDERSFUNDS) ///
	(d_dealID  d_dealDate  d_dealStatus  d_acquiredShare  d_dealCurrency  d_dealSize_curr  d_dealSizeUSD  d_dealSizeEUR  d_dealSizeEquity_curr  d_dealSizeEquity_USD  d_dealSizeEquity_EUR  d_firmID  d_firmName  d_firmCity  d_firmStateCounty  d_firmCountry  d_firmRegion  d_firmWebsite  d_firmStatus  d_firmPrimaryIndustry  d_firmSubIndustries  d_firmIndustryVerticals  d_firmIndustryClassification  d_firmRevenue_curr  d_firmEntryRevenueMltple  d_firmEBITDA_curr  d_firmEntryEBITDAMltple  d_capitalStructure  d_investorID  d_investorName  d_investorFunds  d_investorType  d_investorCity  d_investorStatecounty  d_investorCountry  d_investorRegion  d_investmentType  d_investmentStake  d_sellers  d_leadPartners  d_boardReps  d_debtSize_curr  d_debtSize_USD  d_debtSize_EUR  d_buyerFinAdvisors  d_sellerFinAdvisors  d_buyerLegalAdvisors  d_sellerLegalAdvisors  d_debtProviderID  d_debtProviderName  d_debtProviderFunds)

foreach var of varlist d_firmName d_firmRegion d_firmCountry d_firmStateCounty d_firmCity d_dealStatus d_firmStatus d_firmIndustryClassification d_firmPrimaryIndustry d_firmSubIndustries d_firmIndustryVerticals d_sellers d_dealCurrency d_buyerFinAdvisors d_sellerFinAdvisors d_buyerLegalAdvisors d_sellerLegalAdvisors d_debtProviderName d_debtProviderFund d_investorName d_investorFund d_investmentType d_investmentStake d_investorStatecounty d_investorCity d_investorRegion d_investorCountry d_leadPartners d_boardReps {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)
}
drop if missing(d_dealDate)
sort d_firmID d_dealDate d_dealID
replace d_firmCountry = "UNITED STATES" if d_firmCountry=="US"
replace d_firmCountry = "UNITED KINGDOM" if d_firmCountry=="UK"
replace d_firmWebsite = "" if inlist(d_firmWebsite,"No Website Available","http://No Website Available","http://No website available")
replace d_firmWebsite = "https://www.social-ea.org/g" if d_firmWebsite=="http://social-ea.orhttps://www.social-ea.org/g"
replace d_firmWebsite = "https://odba.vc" if d_firmWebsite=="http://www.https://odba.vc"
replace d_firmWebsite = regexr(d_firmWebsite,"^http://","")
replace d_firmWebsite = regexr(d_firmWebsite,"^https://","")
replace d_firmWebsite = regexr(d_firmWebsite,"^www\.","")
forvalues i = 1/3 {
	replace d_firmWebsite = regexr(d_firmWebsite,"#$","")
	replace d_firmWebsite = regexr(d_firmWebsite,"/$","")
}
replace d_firmWebsite = strtrim(d_firmWebsite)
replace d_firmWebsite = "http://" + d_firmWebsite if d_firmWebsite!=""
save ".\Data\Data_preqin\preqin_dealsBuyout.dta", replace

//I ensure that all deals have at least one PE GP
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
keep fm_id
ren fm_id d_investorID
merge 1:m d_investorID using ".\Data\Data_preqin\preqin_dealsBuyout.dta"
drop if _m==1
bysort d_dealID: egen max_merge = max(_m)
drop if max_merge!=3
gen d_GP = cond(_m==3,1,0)
drop max_merge _m
order d_investorID, b(d_investorName)
order d_GP, a(d_investorName)
save ".\Data\Data_preqin\preqin_dealsBuyout.dta", replace

//Investors
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep d_dealID d_investorID d_investorName d_GP d_investorFunds d_investorType d_investorCity d_investorStatecounty d_investorCountry d_investorRegion d_investmentType d_investmentStake d_leadPartners d_boardReps
duplicates drop
save ".\Data\Data_preqin\preqin_dealsBuyout_investors.dta", replace

//Debt Providers
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep d_dealID d_debtProviderID d_debtProviderName d_debtProviderFunds
duplicates drop
dropmiss d_debtProviderID d_debtProviderName d_debtProviderFunds, force obs
save ".\Data\Data_preqin\preqin_dealsBuyout_debtProviders.dta", replace

//Deal data
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
drop d_investorID d_investorName d_GP d_investorFunds d_investorType d_investorCity d_investorStatecounty d_investorCountry d_investorRegion d_investmentType d_investmentStake d_debtProviderID d_debtProviderName d_debtProviderFunds d_leadPartners d_boardReps
duplicates drop
save ".\Data\Data_preqin\preqin_dealsBuyout.dta", replace

//Addn data
import excel using ".\Data\Data_preqin\Preqin_deals_Buyout_20230325.xlsx", clear first
keep DEALID DEALDATE DEALSTATUS DEALOVERVIEW EXIT ACQUIREDSTAKE DEALTYPES TARGETCOMPANYID TARGETCOMPANY YEARESTABLISHED TARGETDESCRIPTION ENTERPRISEVALUECURR SELLERS INVESTORS
order DEALID DEALDATE DEALSTATUS DEALOVERVIEW EXIT ACQUIREDSTAKE DEALTYPES TARGETCOMPANYID TARGETCOMPANY YEARESTABLISHED TARGETDESCRIPTION ENTERPRISEVALUECURR SELLERS INVESTORS

ren (DEALID - INVESTORS) ///
	(d_dealID d_dealDate d_dealStatus d_dealOverview d_dealExit d_acquiredStake d_dealType d_firmID d_firmName d_firmYearEstablished d_firmDescription d_enterpriseValue_curr d_sellers d_investors)
sort d_firmID d_dealDate d_dealID
foreach var of varlist d_dealStatus d_dealOverview d_dealExit d_acquiredStake d_dealType d_firmName d_firmDescription d_sellers d_investors {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)
}
gen td_dealDate = date(d_dealDate,"YMD")
format td_dealDate %td
drop d_dealDate
ren td_dealDate d_dealDate
order d_dealDate, a(d_dealID)
drop if missing(d_dealDate)
save ".\Data\Data_preqin\preqin_dealsBuyout_addnData.dta", replace

keep d_firmID d_firmYearEstablished
duplicates drop
drop if missing(d_firmYearEstablished)
merge 1:m d_firmID using ".\Data\Data_preqin\preqin_dealsBuyout.dta"
drop if _m==1
drop _m
order d_firmID, b(d_firmName)
order d_firmYearEstablished, a(d_firmName)
sort d_dealDate d_dealID
save ".\Data\Data_preqin\preqin_dealsBuyout.dta", replace

//Exits
import excel using ".\Data\Data_preqin\Preqin_exits_Buyout_20220324.xlsx", clear first
save temp.dta, replace

use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep d_dealID
ren d_dealID DEALID
merge 1:m DEALID using temp.dta
keep if _m==3 //910 exits don't have a corresponding identifying originating deal
drop _m

ren (DEALID - EXITIRR) ///
	(d_dealID d_firmID d_firmName d_dealDate e_exitDate e_exitType e_exitCurrency e_exitValue_curr e_exitValue_USD e_exitValue_EUR e_buyerName e_partialExit e_exitMultiple e_exitIRR)
foreach var of varlist d_firmName e_exitType e_exitCurrency e_buyerName e_partialExit {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)	
}
destring e_exitMultiple e_exitIRR, replace
save ".\Data\Data_preqin\preqin_dealsBuyout_exits.dta", replace
erase temp.dta

//Adding seller data for Exits
use ".\Data\Data_preqin\preqin_dealsBuyout_addnData.dta", clear
keep if d_dealExit=="YES"
keep d_dealDate d_firmID d_sellers
replace d_seller = subinstr(d_seller,".","",.)
replace d_seller = subinstr(d_seller,", INC"," INC",.)
replace d_seller = subinstr(d_seller,", LLC"," LLC",.)
replace d_seller = subinstr(d_seller,", LTD"," LTD",.)
replace d_seller = subinstr(d_seller,", SA"," SA",.)
replace d_seller = subinstr(d_seller,", SL"," SL",.)
replace d_seller = subinstr(d_seller,", BV"," BV",.)
replace d_seller = subinstr(d_seller,", NV"," NV",.)
replace d_seller = subinstr(d_seller,", LP"," LP",.)
replace d_seller = subinstr(d_seller,"CO,LTD","CO LTD",.)
replace d_seller = subinstr(d_seller,"TPG SAB","TPG, SAB",.)
replace d_seller = subinstr(d_seller,"NORTHWESTERN MUTUAL CAPITAL SL CAPITAL PARTNERS","NORTHWESTERN MUTUAL CAPITAL, SL CAPITAL PARTNERS",.)
replace d_seller = subinstr(d_seller,"WELSH, CARSON, ANDERSON & STOWE","WELSH CARSON ANDERSON & STOWE",.)
replace d_seller = subinstr(d_seller,"HAMMOND, KENNEDY, WHITNEY & CO","HAMMOND KENNEDY WHITNEY & CO",.)
replace d_seller = subinstr(d_seller,"ANGELO, GORDON & CO","ANGELO GORDON & CO",.)
replace d_seller = subinstr(d_seller,"HICKS, MUSE, TATE & FURST","HICKS MUSE TATE & FURST",.)
replace d_seller = subinstr(d_seller,"TRUARC PARTNERS SAC PRIVATE CAPITAL GROUP","TRUARC PARTNERS, SAC PRIVATE CAPITAL GROUP",.)
replace d_seller = subinstr(d_seller,"APAX PARTNERS SABAN CAPITAL GROUP","APAX PARTNERS, SABAN CAPITAL GROUP",.)
replace d_seller = subinstr(d_seller,"GE CAPITAL, EQUITY","GE CAPITAL EQUITY",.)
replace d_seller = subinstr(d_seller,"LIBERTY GLOBAL PLC SARONA ASSET MANAGEMENT","LIBERTY GLOBAL PLC, SARONA ASSET MANAGEMENT",.)
replace d_seller = subinstr(d_seller,"DELOS CAPITAL SATORI CAPITAL","DELOS CAPITAL, SATORI CAPITAL",.)
replace d_seller = subinstr(d_seller,"SURVEYOR CAPITAL BVF PARTNERS","SURVEYOR CAPITAL, BVF PARTNERS",.)
replace d_seller = subinstr(d_seller,"BLUM CAPITAL PARTNERS SADDLE POINT GROUP","BLUM CAPITAL PARTNERS, SADDLE POINT GROUP",.)
replace d_seller = subinstr(d_seller,"SPELL CAPITAL PARTNERS SALT CREEK CAPITAL MANAGEMENT","SPELL CAPITAL PARTNERS, SALT CREEK CAPITAL MANAGEMENT",.)
replace d_seller = subinstr(d_seller,"PRIMUS CAPITAL INCLINE EQUITY PARTNERS","PRIMUS CAPITAL, INCLINE EQUITY PARTNERS",.)
replace d_seller = subinstr(d_seller,"IFC ASSET MANAGEMENT COMPANY SAHAM GROUP SA","IFC ASSET MANAGEMENT COMPANY, SAHAM GROUP SA",.)
replace d_seller = subinstr(d_seller,"FERRER, FREEMAN & CO","FERRER FREEMAN & CO",.)
drop if missing(d_seller)
split d_sellers, p(",")
drop d_sellers
gen i = _n
reshape long d_sellers, i(i d_firmID d_dealDate) j(j)
drop i j
drop if missing(d_sellers)
replace d_sellers = strtrim(d_sellers)
replace d_sellers = stritrim(d_sellers)
duplicates drop
ren d_dealDate e_exitDate
save temp.dta, replace

use ".\Data\Data_preqin\preqin_dealsBuyout_exits.dta", clear
keep d_dealID d_firmID e_exitDate e_exitType e_partialExit
drop if missing(e_exitDate)
joinby d_firmID e_exitDate using temp.dta
save temp.dta, replace

use ".\Data\Data_preqin\preqin_dealsBuyout_investors.dta", clear
keep d_dealID d_investorID d_investorName d_GP
replace d_investorName = subinstr(d_investorName,".","",.)
replace d_investorName = subinstr(d_investorName,", INC"," INC",.)
replace d_investorName = subinstr(d_investorName,", LLC"," LLC",.)
replace d_investorName = subinstr(d_investorName,", LTD"," LTD",.)
replace d_investorName = subinstr(d_investorName,", SA"," SA",.)
replace d_investorName = subinstr(d_investorName,", SL"," SL",.)
replace d_investorName = subinstr(d_investorName,", BV"," BV",.)
replace d_investorName = subinstr(d_investorName,", NV"," NV",.)
replace d_investorName = subinstr(d_investorName,", LP"," LP",.)
replace d_investorName = subinstr(d_investorName,"CO,LTD","CO LTD",.)
joinby d_dealID using temp.dta
replace d_sellers="ICG" if d_sellers=="INTERMEDIATE CAPITAL GROUP"
replace d_sellers="IBERIA, LíNEAS AéREAS DE ESPAñA SA" if d_sellers=="IBERIA"
replace d_sellers="IBERIA, LíNEAS AéREAS DE ESPAñA SA" if d_sellers=="LíNEAS AéREAS DE ESPAñA SA"
replace d_sellers="CVC" if d_sellers=="CVC CAPITAL PARTNERS"
replace d_sellers="TERRA FIRMA" if d_sellers=="TERRA FIRMA CAPITAL PARTNERS"
replace d_sellers="BLACKSTONE GROUP" if d_sellers=="BLACKSTONE CREDIT"
replace d_sellers="GUGGENHEIM INVESTMENTS" if d_sellers=="GUGGENHEIM INVESTMENT MANAGEMENT"
replace d_sellers="GOLDMAN SACHS ASSET MANAGEMENT" if d_sellers=="GOLDMAN SACHS MERCHANT BANKING DIVISION"
replace d_sellers="JPEL PRIVATE EQUITY" if d_sellers=="JPEL PRIVATE EQUITY LIMITED"
replace d_sellers="WELSH, CARSON, ANDERSON & STOWE" if d_sellers=="WELSH CARSON ANDERSON & STOWE"
replace d_sellers="HAMMOND, KENNEDY, WHITNEY & CO" if d_sellers=="HAMMOND KENNEDY WHITNEY & CO"
replace d_sellers="MESIROW FINANCIAL" if d_sellers=="MESIROW FINANCIAL PRIVATE EQUITY"
replace d_sellers="ANGELO, GORDON & CO" if d_sellers=="ANGELO GORDON & CO"
replace d_sellers="MACQUARIE GROUP" if d_sellers=="MACQUARIE CAPITAL"
replace d_sellers="ELLIOTT MANAGEMENT" if d_sellers=="ELLIOTT ASSOCIATES"
replace d_sellers="TRITON" if d_sellers=="TRITON PARTNERS"
replace d_sellers="TUDOR, PICKERING, HOLT & CO" if d_sellers=="TPH PARTNERS"
replace d_sellers="HICKS, MUSE, TATE & FURST" if d_sellers=="HICKS MUSE TATE & FURST"
replace d_sellers="GE CAPITAL, EQUITY" if d_sellers=="GE CAPITAL EQUITY"
replace d_sellers="FIDELITY NATIONAL FINANCIAL INC" if d_sellers=="FIDELITY NATIONAL FINANCIAL"
replace d_sellers="KENSINGTON CAPITAL PARTNERS" if d_sellers=="KENSINGTON"
replace d_sellers="KELLY CAPITAL" if d_sellers=="KELLY COMPANIES"
replace d_sellers="EDMOND DE ROTHSCHILD FRANCE" if d_sellers=="EDMOND DE ROTHSCHILD PRIVATE EQUITY (FRANCE)"
replace d_sellers="ALTIMETER CAPITAL" if d_sellers=="ALTIMETER CAPITAL MANAGEMENT"
replace d_sellers="T ROWE PRICE" if d_sellers=="T ROWE PRICE ASSOCIATES"
replace d_sellers="CDH INVESTMENT" if d_sellers=="CDH INVESTMENTS"
replace d_sellers="BB CAPITAL" if d_sellers=="BB CAPITAL INVESTMENTS"
replace d_sellers="CMB INTERNATIONAL ASSET MANAGEMENT" if d_sellers=="CMB INTERNATIONAL CAPITAL MANAGEMENT"
replace d_sellers="MOTILAL OSWAL" if d_sellers=="MOTILAL OSWAL ASSET MANAGEMENT"
replace d_sellers="BB CAPITAL" if d_sellers=="BB CAPITAL INVESTMENTS"
replace d_sellers="LFPI GROUP" if d_sellers=="LFPI GESTION"
replace d_sellers="HILLHOUSE CAPITAL MANAGEMENT" if d_sellers=="HILLHOUSE CAPITAL GROUP"
replace d_sellers="HARWOOD CAPITAL MANAGEMENT GROUP" if d_sellers=="HARWOOD PRIVATE EQUITY"
replace d_sellers="EOS" if d_sellers=="EOS PARTNERS"
replace d_sellers="KINEA INVESTIMENTOS" if d_sellers=="KINEA INVESTIMENTOS - PRIVATE EQUITY"
replace d_sellers="SIMON PROPERTY GROUP, L P" if d_sellers=="SIMON PROPERTY GROUP"
replace d_sellers="PROMUS ASSET MANAGEMENT" if d_sellers=="PROMUS EQUITY PARTNERS"
replace d_sellers="TIKEHAU CAPITAL" if d_sellers=="TIKEHAU INVESTMENT MANAGEMENT"
replace d_sellers="NINETY ONE" if d_sellers=="NINETY ONE UK"
replace d_sellers="CLAYTON DUBILIER & RICE" if d_sellers=="CLAYTON DUBILIER & RICE SAFWAY GROUP HOLDING LLC"
replace d_sellers="OAKLEY CAPITAL" if d_sellers=="OAKLEY CAPITAL PRIVATE EQUITY"
replace d_sellers="BNP PARIBAS ASSET MANAGEMENT" if d_sellers=="BNP PARIBAS CAPITAL PARTNERS"
replace d_sellers="EVERSTONE GROUP" if d_sellers=="EVERSTONE CAPITAL PARTNERS"
replace d_sellers="JP MORGAN ASSET MANAGEMENT" if d_sellers=="JP MORGAN ASSET MANAGEMENT - PRIVATE EQUITY GROUP"
replace d_sellers="AMUNDI" if d_sellers=="AMUNDI PRIVATE EQUITY"
replace d_sellers="DEMETER PARTNERS" if d_sellers=="DEMETER IM"
replace d_sellers="BNP PARIBAS ASSET MANAGEMENT" if d_sellers=="BNP PARIBAS CAPITAL"
replace d_sellers="PROMUS ASSET MANAGEMENT" if d_sellers=="PROMUS EQUITY PARTNERS"
replace d_sellers="FERRER, FREEMAN & CO" if d_sellers=="FERRER FREEMAN & CO"
ustrdist d_investorName d_sellers, gen(dist)
bysort d_dealID d_investorID e_exitDate: egen minDist = min(dist)
drop if minDist==0 & dist!=0
keep if dist==0
keep d_dealID d_investorID d_investorName d_GP d_firmID e_exitDate e_exitType e_partialExit
order d_dealID d_firmID e_exitDate e_exitType e_partialExit d_investorID d_investorName d_GP
sort d_firmID e_exitDate d_investorID
save ".\Data\Data_preqin\preqin_dealsBuyout_exitsSellers.dta", replace
erase temp.dta

use ".\Data\Data_preqin\preqin_dealsBuyout_exits.dta", clear
keep d_dealID d_dealDate
duplicates drop
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsBuyout_exitsSellers.dta"
keep if _m==3
drop _m
order d_dealDate, b(e_exitDate)
save ".\Data\Data_preqin\preqin_dealsBuyout_exitsSellers.dta", replace

erase ".\Data\Data_preqin\preqin_dealsBuyout_addnData.dta"

**Venture Capital Deals
import excel using ".\Data\Data_preqin\Preqin_deals_Venture Capital_20230416.xlsx", clear first
order DEALID DEALDATE DEALSTATUS STAGE ACQUIREDSHARE DEALCURRENCY DEALSIZECURRMN DEALSIZEUSDMN DEALSIZEEURMN PORTFOLIOCOMPANYID PORTFOLIOCOMPANY YEARESTABLISHED PORTFOLIOCOMPANYCITY PORTFOLIOCOMPANYSTATECOUNTY PORTFOLIOCOMPANYCOUNTRY PORTFOLIOCOMPANYREGION PORTFOLIOCOMPANYWEBSITE PORTFOLIOCOMPANYSTATUS PRIMARYINDUSTRY SUBINDUSTRIES INDUSTRYVERTICALS INDUSTRYCLASSIFICATION COMPANYREVENUECURRMN ENTRYREVENUEMULTIPLE EBITDACURRMN ENTRYEBITDAMULTIPLE FINANCIALADVISORSBUYERS FINANCIALADVISORSSELLERS LEGALADVISORSBUYERS LEGALADVISORSSELLERS
ren (DEALID - LEGALADVISORSSELLERS) ///
	(d_dealID d_dealDate d_dealStatus d_stage d_acquiredShare d_dealCurrency d_dealSize_curr d_dealSizeUSD d_dealSizeEUR d_firmID d_firmName d_fimrYearEstablished d_firmCity d_firmStateCounty d_firmCountry d_firmRegion d_firmWebsite d_firmStatus d_firmPrimaryIndustry d_firmSubIndustries d_firmIndustryVerticals d_firmIndustryClassification d_firmRevenue_curr d_firmEntryRevenueMltple d_firmEBITDA_curr d_firmEntryEBITDAMltple d_buyerFinAdvisors d_sellerFinAdvisors d_buyerLegalAdvisors d_sellerLegalAdvisors)

foreach var of varlist d_dealStatus d_stage d_dealCurrency d_firmName d_firmCity d_firmStateCounty d_firmCountry d_firmRegion d_firmStatus d_firmPrimaryIndustry d_firmSubIndustries d_firmIndustryVerticals d_firmIndustryClassification d_buyerFinAdvisors d_sellerFinAdvisors d_buyerLegalAdvisors d_sellerLegalAdvisors {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)
}
drop if missing(d_dealDate)
sort d_firmID d_dealDate d_dealID
replace d_firmCountry = "UNITED STATES" if d_firmCountry=="US"
replace d_firmCountry = "UNITED KINGDOM" if d_firmCountry=="UK"
replace d_firmWebsite = "" if inlist(d_firmWebsite,"No Website Available","http://No Website Available","http://No website available")
replace d_firmWebsite = "https://www.social-ea.org/g" if d_firmWebsite=="http://social-ea.orhttps://www.social-ea.org/g"
replace d_firmWebsite = "https://odba.vc" if d_firmWebsite=="http://www.https://odba.vc"
replace d_firmWebsite = regexr(d_firmWebsite,"^http://","")
replace d_firmWebsite = regexr(d_firmWebsite,"^https://","")
replace d_firmWebsite = regexr(d_firmWebsite,"^www\.","")
forvalues i = 1/3 {
	replace d_firmWebsite = regexr(d_firmWebsite,"#$","")
	replace d_firmWebsite = regexr(d_firmWebsite,"/$","")
}
replace d_firmWebsite = strtrim(d_firmWebsite)
replace d_firmWebsite = "http://" + d_firmWebsite if d_firmWebsite!=""
save ".\Data\Data_preqin\preqin_dealsVC.dta", replace

import excel using ".\Data\Data_preqin\Preqin_investors_lenders_Venture Capital_20230416.xlsx", clear first
drop PORTFOLIOCOMPANYID
order DEALID INVESTORID INVESTORSBUYERSFIRMS INVESTORSBUYERSFUNDS INVESTORTYPE INVESTORCITY INVESTORSTATECOUNTY INVESTORCOUNTRY INVESTORREGION BOUGHTFROMSELLERSFIRMS LEADPARTNERS BOARDREPRESENTATIVES
ren (DEALID INVESTORID INVESTORSBUYERSFIRMS INVESTORSBUYERSFUNDS INVESTORTYPE INVESTORCITY INVESTORSTATECOUNTY INVESTORCOUNTRY INVESTORREGION BOUGHTFROMSELLERSFIRMS LEADPARTNERS BOARDREPRESENTATIVES) ///
	(d_dealID d_investorID d_investorName d_investorFunds d_investorType d_investorCity d_investorStatecounty d_investorCountry d_investorRegion d_sellers d_leadPartners d_boardReps)
foreach var of varlist d_investorName d_investorFunds d_investorType d_investorCity d_investorStatecounty d_investorCountry d_investorRegion d_sellers d_leadPartners d_boardReps {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)
}
save ".\Data\Data_preqin\preqin_dealsVC_investors.dta", replace

//Keeping only deals with a PE GP
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
keep fm_id
ren fm_id d_investorID
merge 1:m d_investorID using ".\Data\Data_preqin\preqin_dealsVC_investors.dta"
drop if _m==1
bysort d_dealID: egen max_merge = max(_m)
drop if max_merge!=3
gen d_GP = cond(_m==3,1,0)
keep d_dealID d_investorID d_GP
merge 1:m d_dealID d_investorID using ".\Data\Data_preqin\preqin_dealsVC_investors.dta"
keep if _m==3
drop _m
order d_GP, a(d_investorName)
save ".\Data\Data_preqin\preqin_dealsVC_investors.dta", replace

keep d_dealID
duplicates drop
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsVC.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsVC.dta", replace

use ".\Data\Data_preqin\preqin_dealsVC_investors.dta", clear
keep d_dealID d_sellers
duplicates drop
merge 1:1 d_dealID using ".\Data\Data_preqin\preqin_dealsVC.dta"
drop _m
order d_sellers, a(d_firmEntryEBITDAMltple)
save ".\Data\Data_preqin\preqin_dealsVC.dta", replace

use ".\Data\Data_preqin\preqin_dealsVC_investors.dta", clear
drop d_sellers
save ".\Data\Data_preqin\preqin_dealsVC_investors.dta", replace

//Exits
import excel using ".\Data\Data_preqin\Preqin_exits_Venture Capital_20230416.xlsx", clear first
order DEALID PORTFOLIOCOMPANYID PORTFOLIOCOMPANY EXITDATE EXITTYPE EXITCURRENCY EXITVALUECURRMN EXITVALUEUSDMN EXITVALUEEURMN ACQUIROREXIT PARTIALLYEXITED EXITMULTIPLE EXITIRR
ren (DEALID - EXITIRR) ///
	(d_dealID d_firmID d_firmName e_exitDate e_exitType e_exitCurrency e_exitValue_curr e_exitValue_USD e_exitValue_EUR e_buyerName e_partialExit e_exitMultiple e_exitIRR)
foreach var of varlist e_exitType e_exitCurrency e_buyerName e_partialExit {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)	
}
save ".\Data\Data_preqin\preqin_dealsVC_exits.dta", replace

use ".\Data\Data_preqin\preqin_dealsVC.dta", clear
keep d_dealID d_dealDate 
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsVC_exits.dta"
keep if _m==3
drop _m
order d_dealDate, a(d_firmName)
save ".\Data\Data_preqin\preqin_dealsVC_exits.dta", replace
}
**LPs** 
{
import excel using ".\Data\Data_preqin\Preqin_LPs_20230307.xlsx", clear first
drop LOCALLANGUAGEFIRMNAME
order FIRMID FIRMNAME RIA FUNDSCOUNT REGION ADDRESS CITY STATECOUNTY ZIPCODE COUNTRY WEBSITE EMAIL TEL FAX GENERALCONSULTANT SECONDARYLOCATIONS FIRMTYPE YEAREST INVESTORCURRENCY AUMCURRMN AUMUSDMN AUMEURMN ALLOCATIONALTERNATIVES ALLOCATIONALTERNATIVESCURR ALLOCATIONALTERNATIVESUSDMN ALLOCATIONALTERNATIVESEURMN ALLOCATIONEQUITIES ALLOCATIONEQUITIESCURRMN ALLOCATIONEQUITIESUSDMN ALLOCATIONEQUITIESEURMN ALLOCATIONFIXEDINCOME ALLOCATIONFIXEDINCOMECURR ALLOCATIONFIXEDINCOMEUSDMN ALLOCATIONFIXEDINCOMEEURMN ALLOCATIONCASH ALLOCATIONCASHCURRMN ALLOCATIONCASHUSDMN ALLOCATIONCASHEURMN ALLOCATIONOTHER ALLOCATIONOTHERCURRMN ALLOCATIONOTHERUSDMN ALLOCATIONOTHEREURMN TARGETALLOCATIONALTERNATIVES AS AT AU AV AW AX AY TARGETALLOCATIONEQUITIES BA TARGETALLOCATIONEQUITIESCUR BC TARGETALLOCATIONEQUITIESUSD BE TARGETALLOCATIONEQUITIESEUR BG TARGETALLOCATIONFIXEDINCOME BI BJ BK BL BM BN BO TARGETALLOCATIONCASHMIN TARGETALLOCATIONCASHMAX TARGETALLOCATIONCASHCURRM BS TARGETALLOCATIONCASHUSDMN BU TARGETALLOCATIONCASHEURMN BW TARGETALLOCATIONOTHERMI TARGETALLOCATIONOTHERMA TARGETALLOCATIONOTHERCURR CA TARGETALLOCATIONOTHERUSDMN CC TARGETALLOCATIONOTHEREURMN CE INVESTINGINPE PEALLOCATION PEALLOCATIONCURRMN PEALLOCATIONUSDMN PEALLOCATIONEURMN PETARGETALLOCATION PETARGETALLOCATIONCURRMN PETARGETALLOCATIONUSDMN PETARGETALLOCATIONEURMN PEALLOCATIONPRIMARY PEALLOCATIONPRIMARYCURRM PEALLOCATIONPRIMARYUSDMN PEALLOCATIONPRIMARYEURMN PEALLOCATIONSECONDARY PEALLOCATIONSECONDARYCURR PEALLOCATIONSECONDARYUSDM PEALLOCATIONSECONDARYEURM PEALLOCATIONDIRECT PEALLOCATIONDIRECTCURRMN PEALLOCATIONDIRECTUSDMN PEALLOCATIONDIRECTEURMN PESTRATEGYPREFERENCES PEGEOGRAPHICPREFERENCES PEINDUSTRIES PEINDUSTRYVERTICALS PEFIRSTTIMEFUNDS PECOINVEST PEFIRSTCLOSEINVESTOR PESEPARATEACCOUNTS PEBUYOUTFUNDPREFERENCES PEOTHERMANAGERREQUIREMENTS PEINVESTMENTCURRENCYINCHINA PETYPICALINVESTMENTCURRMN DM PETYPICALINVESTMENTUSDMN DO PETYPICALINVESTMENTEURMN DQ PENEXT12MTHS PENEXT12MTHSSTRATEGIES PENEXT12MTHSBUYOUTPREF PENEXT12MTHSREGIONS PENEXT12MTHSINDUSTRIES PENEXT12MTHSINDUSTRYVERTIC PENEXT12MTHSDATEOFPLANS PENEXT12MTHSDATEOFPLANSI PENEXT12MTHSGPRELATIONSHIP PENEXT12MTHSNOFUNDSMIN PENEXT12MTHSNOFUNDSMAX PENEXT12MTHSMINCURRMN PENEXT12MTHSMAXCURRMN PENEXT12MTHSMINUSDMN PENEXT12MTHSMAXUSDMN PENEXT12MTHSMINEURMN PENEXT12MTHSMAXEURMN PEPREFERREDMETHODOFINITIAL PEPREFERREDINITIALCONTACTEM PEPRIORITYCONTACTJOBTITLE PEPRIORITYCONTACTEMAIL PEPRIORITYCONTACTPHONE PEPRIORITYCONTACTNAME PECONSULTANT PEDATEADDED PELASTUPDATEDDATE

ren (FIRMID - PELASTUPDATEDDATE) ///
	(i_ID i_firmName i_RIA i_fundsCount i_region i_address i_city i_stateCounty i_zipcode i_country i_website i_email i_telephone i_fax i_generalConsultant i_secondaryLocations i_firmType i_yearEstablished i_investorCurrency i_AUM_curr i_AUM_USD i_AUM_EUR i_crrntAllocAlternatives_pct i_crrntAllocAlternatives_curr i_crrntAllocAlternatives_USD i_crrntAllocAlternatives_EUR i_crrntAllocEquities_pct i_crrntAllocEquities_curr i_crrntAllocEquities_USD i_crrntAllocEquities_EUR i_crrntAllocFixedIncome_pct i_crrntAllocFixedIncome_curr i_crrntAllocFixedIncome_USD i_crrntAllocFixedIncome_EUR i_crrntAllocCash_pct i_crrntAllocCash_curr i_crrntAllocCash_USD i_crrntAllocCash_EUR i_crrntAllocOther_pct i_crrntAllocOther_curr i_crrntAllocOther_USD i_crrntAllocOther_EUR i_tgtAllocAlternativesMin_pct i_tgtAllocAlternativesMax_pct i_tgtAllocAlternativesMin_curr i_tgtAllocAlternativesMax_curr i_tgtAllocAlternativesMin_USD i_tgtAllocAlternativesMax_USD i_tgtAllocAlternativesMin_EUR i_tgtAllocAlternativesMax_EUR i_tgtAllocEquitiesMin_pct i_tgtAllocEquitiesMax_pct i_tgtAllocEquitiesMin_curr i_tgtAllocEquitiesMax_curr i_tgtAllocEquitiesMin_USD i_tgtAllocEquitiesMax_USD i_tgtAllocEquitiesMin_EUR i_tgtAllocEquitiesMax_EUR i_tgtAllocFixedIncomeMin_pct i_tgtAllocFixedIncomeMax_pct i_tgtAllocFixedIncomeMin_curr i_tgtAllocFixedIncomeMax_curr i_tgtAllocFixedIncomeMin_USD i_tgtAllocFixedIncomeMax_USD i_tgtAllocFixedIncomeMin_EUR i_tgtAllocFixedIncomeMax_EUR i_tgtAllocCashMin_pct i_tgtAllocCashMax_pct i_tgtAllocCashMin_curr i_tgtAllocCashMax_curr i_tgtAllocCashMin_USD i_tgtAllocCashMax_USD i_tgtAllocCashMin_EUR i_tgtAllocCashMax_EUR i_tgtAllocOtherMin_pct i_tgtAllocOtherMax_pct i_tgtAllocOtherMin_curr i_tgtAllocOtherMax_curr i_tgtAllocOtherMin_USD i_tgtAllocOtherMax_USD i_tgtAllocOtherMin_EUR i_tgtAllocOtherMax_EUR i_investInPE i_PEAlloc_pct i_PEAlloc_curr i_PEAlloc_USD i_PEAlloc_EUR i_PETgtAlloc_pct i_PETgtAlloc_curr i_PETgtAlloc_USD i_PETgtAlloc_EUR i_PEPrimaryAlloc_pct i_PEPrimaryAlloc_curr i_PEPrimaryAlloc_USD i_PEPrimaryAlloc_EUR i_PEScndryAlloc_pct i_PEScndryAlloc_curr i_PEScndryAlloc_USD i_PEScndryAlloc_EUR i_PEDirectAlloc_pct i_PEDirectAlloc_curr i_PEDirectAlloc_USD i_PEDirectAlloc_EUR i_PEStrategyPrefs i_PEGeoPrefs i_PEIndustries i_PEIndustryVerticals i_PEFirstTimeFunds i_PECoInvest i_PEFirstCloseInvestor i_PESeparateAccts i_PEBuyoutFundPrefs i_PEOtherMgrReq i_PEInvstCurrInChina i_PETypicalInvstMin_curr i_PETypicalInvstMax_curr i_PETypicalInvstMin_USD i_PETypicalInvstMax_USD i_PETypicalInvstMin_EUR i_PETypicalInvstMax_EUR i_PEN12MPlans i_PEN12MStrategies i_PEN12MBuyoutPrefs i_PEN12MRegions i_PEN12MIndustries i_PEN12MIndustryVerticals i_PEN12MDtOfPlans i_PEN12MDtOfPlansInsert i_PEN12MGPRelationships i_PEN12MNoFundsMin i_PEN12MNoFundsMax i_PEN12MAmtMin_curr i_PEN12MAmtMax_curr i_PEN12MAmtMin_USD i_PEN12MAmtMax_USD i_PEN12MAmtMin_EUR i_PEN12MAmtMax_EUR i_PEPrefContactMethd i_PEPrefContactEmail i_PEPriorityContactTitle i_PEPriorityContactEmail i_PEPriorityContactPhone i_PEPriorityContactName i_PEConsultant i_PEDateAdded i_PELastUpdateDt)
	
foreach var of varlist i_firmName i_region i_address i_city i_stateCounty i_country i_generalConsultant i_secondaryLocations i_firmType i_investorCurrency i_investInPE i_PEStrategyPrefs i_PEGeoPrefs i_PEIndustries i_PEIndustryVerticals i_PEFirstTimeFunds i_PECoInvest i_PEFirstCloseInvestor i_PESeparateAccts i_PEBuyoutFundPrefs i_PEOtherMgrReq i_PEInvstCurrInChina i_PEN12MPlans i_PEN12MStrategies i_PEN12MBuyoutPrefs i_PEN12MRegions i_PEN12MIndustries i_PEN12MIndustryVerticals i_PEN12MGPRelationships i_PEPrefContactMethd i_PEPriorityContactTitle i_PEPriorityContactName i_PEConsultant {
	replace `var' = upper(`var')
	replace `var' = strtrim(`var')
	replace `var' = stritrim(`var')
	replace `var' = subinstr(`var',"`=char(9)'","",.)
}
save ".\Data\Data_preqin\preqin_LPs.dta", replace
}
**PRI Mapping
{
//Signatories
import excel using ".\Data\Data_PRI\PRISignatory_20231029.xlsx", clear first locale("locale") 
gen date = date(SignatureDate,"DMY")
drop if missing(date)
drop SignatureDate
ren (date AccountName) (SignatureDate Signatory)
format SignatureDate %td

replace HQCountry = upper(HQCountry)
replace HQCountry = "BOLIVIA" if HQCountry=="BOLIVIA, PLURINATIONAL STATE OF"
replace HQCountry = "BRITISH VIRGIN ISLANDS" if HQCountry=="VIRGIN ISLANDS, BRITISH"
replace HQCountry = "BRUNEI" if HQCountry=="BRUNEI DARUSSALAM"
replace HQCountry = "HONG KONG SAR - CHINA" if HQCountry=="HONG KONG SAR"
replace HQCountry = "SOUTH KOREA" if HQCountry=="KOREA, REPUBLIC OF"
replace HQCountry = "RUSSIA" if HQCountry=="RUSSIAN FEDERATION"
replace HQCountry = "VENEZUELA" if HQCountry=="VENEZUELA, BOLIVARIAN REPUBLIC OF"
replace HQCountry = "VIETNAM" if HQCountry=="VIET NAM"
replace Signatory = usubinstr(Signatory,"ü","u",.)
replace Signatory = usubinstr(Signatory,"Å","A",.)
replace Signatory = usubinstr(Signatory,"Í","I",.)
replace Signatory = usubinstr(Signatory,"Ö","O",.)
replace Signatory = usubinstr(Signatory,"ö","o",.)
replace Signatory = usubinstr(Signatory,"Œ","CE",.)
replace Signatory = usubinstr(Signatory,"Â","A",.)
replace Signatory = usubinstr(Signatory,"ü","u",.)
replace Signatory = usubinstr(Signatory,"ÿ","y",.)
replace Signatory = usubinstr(Signatory,"ý","y",.)
replace Signatory = usubinstr(Signatory,"û","u",.)
replace Signatory = usubinstr(Signatory,"ú","u",.)
replace Signatory = usubinstr(Signatory,"ù","u",.)
replace Signatory = usubinstr(Signatory,"ø","o",.)
replace Signatory = usubinstr(Signatory,"ö","o",.)
replace Signatory = usubinstr(Signatory,"õ","o",.)
replace Signatory = usubinstr(Signatory,"ô","o",.)
replace Signatory = usubinstr(Signatory,"ó","o",.)
replace Signatory = usubinstr(Signatory,"ò","o",.)
replace Signatory = usubinstr(Signatory,"ñ","n",.)
replace Signatory = usubinstr(Signatory,"ï","i",.)
replace Signatory = usubinstr(Signatory,"î","i",.)
replace Signatory = usubinstr(Signatory,"í","i",.)
replace Signatory = usubinstr(Signatory,"ì","i",.)
replace Signatory = usubinstr(Signatory,"ë","e",.)
replace Signatory = usubinstr(Signatory,"ê","e",.)
replace Signatory = usubinstr(Signatory,"é","e",.)
replace Signatory = usubinstr(Signatory,"è","e",.)
replace Signatory = usubinstr(Signatory,"ç","c",.)
replace Signatory = usubinstr(Signatory,"æ","ae",.)
replace Signatory = usubinstr(Signatory,"å","a",.)
replace Signatory = usubinstr(Signatory,"ä","a",.)
replace Signatory = usubinstr(Signatory,"ã","a",.)
replace Signatory = usubinstr(Signatory,"â","a",.)
replace Signatory = usubinstr(Signatory,"á","a",.)
replace Signatory = usubinstr(Signatory,"à","a",.)
replace Signatory = usubinstr(Signatory,"Ý","y",.)
replace Signatory = usubinstr(Signatory,"Ü","U",.)
replace Signatory = usubinstr(Signatory,"Û","u",.)
replace Signatory = usubinstr(Signatory,"Ú","u",.)
replace Signatory = usubinstr(Signatory,"Ù","u",.)
replace Signatory = usubinstr(Signatory,"Ø","o",.)
replace Signatory = usubinstr(Signatory,"Ö","o",.)
replace Signatory = usubinstr(Signatory,"Õ","o",.)
replace Signatory = usubinstr(Signatory,"Ô","o",.)
replace Signatory = usubinstr(Signatory,"Ó","o",.)
replace Signatory = usubinstr(Signatory,"Ò","o",.)
replace Signatory = usubinstr(Signatory,"Ï","i",.)
replace Signatory = usubinstr(Signatory,"Î","i",.)
replace Signatory = usubinstr(Signatory,"Í","i",.)
replace Signatory = usubinstr(Signatory,"Ì","i",.)
replace Signatory = usubinstr(Signatory,"Ë","e",.)
replace Signatory = usubinstr(Signatory,"Ê","e",.)
replace Signatory = usubinstr(Signatory,"É","e",.)
replace Signatory = usubinstr(Signatory,"È","e",.)
replace Signatory = usubinstr(Signatory,"Ç","c",.)
replace Signatory = usubinstr(Signatory,"Æ","ae",.)
replace Signatory = usubinstr(Signatory,"Å","a",.)
replace Signatory = usubinstr(Signatory,"Ä","a",.)
replace Signatory = usubinstr(Signatory,"Ã","a",.)
replace Signatory = usubinstr(Signatory,"Â","a",.)
replace Signatory = usubinstr(Signatory,"Á","a",.)
replace Signatory = usubinstr(Signatory,"À","a",.)
replace Signatory = usubinstr(Signatory,"Ÿ","y",.)
replace Signatory = usubinstr(Signatory,"ž","z",.)
replace Signatory = usubinstr(Signatory,"č","c",.)
replace Signatory = usubinstr(Signatory,"Č","c",.)
replace Signatory = usubinstr(Signatory,"ř","r",.)
replace Signatory = usubinstr(Signatory," & "," AND ",.)
replace Signatory = upper(Signatory)
replace Signatory = cond(strpos(Signatory,"("),substr(Signatory,1,strpos(Signatory,"(")-1)+substr(Signatory,strpos(Signatory,")")+1,.),Signatory)
replace Signatory = regexr(Signatory," LTD.$"," LIMITED")
replace Signatory = regexr(Signatory," LTD$"," LIMITED")
replace Signatory = regexr(Signatory," L.L.C.$"," LLC")
replace Signatory =   regexr(Signatory," L.L.C$"," LLC")
replace Signatory =   regexr(Signatory," L.L.P.$"," LLP")
replace Signatory =   regexr(Signatory," L.L.P$"," LLP")
replace Signatory =   regexr(Signatory," P.T.Y.$"," PTY")
replace Signatory =   regexr(Signatory," P.T.Y$"," PTY")
replace Signatory =   regexr(Signatory," PTY.$"," PTY")
replace Signatory =   regexr(Signatory," P.L.C.$"," PLC")
replace Signatory =   regexr(Signatory," P.L.C$"," PLC")
replace Signatory =   regexr(Signatory," PLC.$"," PLC")
replace Signatory =   regexr(Signatory," G.M.B.H.$"," GMBH")
replace Signatory =   regexr(Signatory," G.M.B.H$"," GMBH")
replace Signatory =   regexr(Signatory," GMBH.$"," GMBH")
replace Signatory =   regexr(Signatory," M.B.H.$"," MBH")
replace Signatory =   regexr(Signatory," M.B.H$"," MBH")
replace Signatory =   regexr(Signatory," MBH.$"," MBH")
replace Signatory =   regexr(Signatory," S.A.R.L.$"," SARL")
replace Signatory =   regexr(Signatory," S.A.R.L$"," SARL")
replace Signatory =   regexr(Signatory," SARL.$"," SARL")
replace Signatory =   regexr(Signatory," SA RL$"," SARL")
replace Signatory =   regexr(Signatory," A.S.$"," AS")
replace Signatory =   regexr(Signatory," AS.$"," AS")
replace Signatory =   regexr(Signatory," A.S$"," AS")
replace Signatory =   regexr(Signatory," A.B.$"," AB")
replace Signatory =   regexr(Signatory," AB.$"," AB")
replace Signatory =   regexr(Signatory," A.B$"," AB")
replace Signatory =   regexr(Signatory," A.G.$"," AG")
replace Signatory =   regexr(Signatory," AG.$"," AG")
replace Signatory =   regexr(Signatory," A.G$"," AG")
replace Signatory =   regexr(Signatory," L.P.$"," LP")
replace Signatory =   regexr(Signatory," LP.$"," LP")
replace Signatory =   regexr(Signatory," L.P$"," LP")
replace Signatory = regexr(Signatory," LLP$","")
replace Signatory = regexr(Signatory," LLC$","")
replace Signatory = regexr(Signatory," PTY$","")
replace Signatory = regexr(Signatory," PLC$","")
replace Signatory = regexr(Signatory," GMBH$","")
replace Signatory = regexr(Signatory," MBH$","")
replace Signatory = regexr(Signatory," AS$","")
replace Signatory = regexr(Signatory," AB","")
replace Signatory = regexr(Signatory," AG$","")
replace Signatory = regexr(Signatory," SARL$","")
replace Signatory = regexr(Signatory," LP$","")
replace Signatory = regexr(Signatory,"INC.$","INCORPORATED")
replace Signatory = regexr(Signatory,"INCORP$","INCORPORATED")
replace Signatory = regexr(Signatory,"INC$","INCORPORATED")
replace Signatory = regexr(Signatory,"LIMITED$","")
replace Signatory = regexr(Signatory,"INCORPORATED$","")
replace Signatory = regexr(Signatory,"CORPORATION$","")
replace Signatory = regexr(Signatory,"COMPANY$","")
replace Signatory = regexr(Signatory,"PARTNERS$","")
replace Signatory = regexr(Signatory,"GROUP$","")
replace Signatory = regexr(Signatory,"CAPITAL$","")
replace Signatory = regexr(Signatory,"FUND$","")
replace Signatory = regexr(Signatory,"ASSOCIATES$","")
replace Signatory = subinstr(Signatory,",","",.)
replace Signatory = subinstr(Signatory,".","",.)
replace Signatory = strtrim(Signatory)
replace Signatory = stritrim(Signatory)
sort Signatory
drop SignatoryCategory
duplicates drop
drop if Signatory=="MERCER" & SignatureDate==mdy(04,27,2006)
drop if Signatory=="SWISS PRIME SITE SOLUTIONS" & SignatureDate==mdy(11,17,2022)
save temp_signatory.dta, replace

//Investors
use ".\Data\Data_preqin\preqin_LPs.dta", clear
keep i_ID i_firmName i_country
replace i_country = "UNITED STATES" if i_country=="US"
replace i_country = "UNITED KINGDOM" if i_country=="UK"
replace i_country = "CHINA" if i_country=="MACAO SAR - CHINA"
replace i_firmName = usubinstr(i_firmName,"ü","u",.)
replace i_firmName = usubinstr(i_firmName,"Å","A",.)
replace i_firmName = usubinstr(i_firmName,"Í","I",.)
replace i_firmName = usubinstr(i_firmName,"Ö","O",.)
replace i_firmName = usubinstr(i_firmName,"ö","o",.)
replace i_firmName = usubinstr(i_firmName,"Œ","CE",.)
replace i_firmName = usubinstr(i_firmName,"Â","A",.)
replace i_firmName = usubinstr(i_firmName,"ü","u",.)
replace i_firmName = usubinstr(i_firmName,"ÿ","y",.)
replace i_firmName = usubinstr(i_firmName,"ý","y",.)
replace i_firmName = usubinstr(i_firmName,"û","u",.)
replace i_firmName = usubinstr(i_firmName,"ú","u",.)
replace i_firmName = usubinstr(i_firmName,"ù","u",.)
replace i_firmName = usubinstr(i_firmName,"ø","o",.)
replace i_firmName = usubinstr(i_firmName,"ö","o",.)
replace i_firmName = usubinstr(i_firmName,"õ","o",.)
replace i_firmName = usubinstr(i_firmName,"ô","o",.)
replace i_firmName = usubinstr(i_firmName,"ó","o",.)
replace i_firmName = usubinstr(i_firmName,"ò","o",.)
replace i_firmName = usubinstr(i_firmName,"ñ","n",.)
replace i_firmName = usubinstr(i_firmName,"ï","i",.)
replace i_firmName = usubinstr(i_firmName,"î","i",.)
replace i_firmName = usubinstr(i_firmName,"í","i",.)
replace i_firmName = usubinstr(i_firmName,"ì","i",.)
replace i_firmName = usubinstr(i_firmName,"ë","e",.)
replace i_firmName = usubinstr(i_firmName,"ê","e",.)
replace i_firmName = usubinstr(i_firmName,"é","e",.)
replace i_firmName = usubinstr(i_firmName,"è","e",.)
replace i_firmName = usubinstr(i_firmName,"ç","c",.)
replace i_firmName = usubinstr(i_firmName,"æ","ae",.)
replace i_firmName = usubinstr(i_firmName,"å","a",.)
replace i_firmName = usubinstr(i_firmName,"ä","a",.)
replace i_firmName = usubinstr(i_firmName,"ã","a",.)
replace i_firmName = usubinstr(i_firmName,"â","a",.)
replace i_firmName = usubinstr(i_firmName,"á","a",.)
replace i_firmName = usubinstr(i_firmName,"à","a",.)
replace i_firmName = usubinstr(i_firmName,"Ý","y",.)
replace i_firmName = usubinstr(i_firmName,"Ü","U",.)
replace i_firmName = usubinstr(i_firmName,"Û","u",.)
replace i_firmName = usubinstr(i_firmName,"Ú","u",.)
replace i_firmName = usubinstr(i_firmName,"Ù","u",.)
replace i_firmName = usubinstr(i_firmName,"Ø","o",.)
replace i_firmName = usubinstr(i_firmName,"Ö","o",.)
replace i_firmName = usubinstr(i_firmName,"Õ","o",.)
replace i_firmName = usubinstr(i_firmName,"Ô","o",.)
replace i_firmName = usubinstr(i_firmName,"Ó","o",.)
replace i_firmName = usubinstr(i_firmName,"Ò","o",.)
replace i_firmName = usubinstr(i_firmName,"Ï","i",.)
replace i_firmName = usubinstr(i_firmName,"Î","i",.)
replace i_firmName = usubinstr(i_firmName,"Í","i",.)
replace i_firmName = usubinstr(i_firmName,"Ì","i",.)
replace i_firmName = usubinstr(i_firmName,"Ë","e",.)
replace i_firmName = usubinstr(i_firmName,"Ê","e",.)
replace i_firmName = usubinstr(i_firmName,"É","e",.)
replace i_firmName = usubinstr(i_firmName,"È","e",.)
replace i_firmName = usubinstr(i_firmName,"Ç","c",.)
replace i_firmName = usubinstr(i_firmName,"Æ","ae",.)
replace i_firmName = usubinstr(i_firmName,"Å","a",.)
replace i_firmName = usubinstr(i_firmName,"Ä","a",.)
replace i_firmName = usubinstr(i_firmName,"Ã","a",.)
replace i_firmName = usubinstr(i_firmName,"Â","a",.)
replace i_firmName = usubinstr(i_firmName,"Á","a",.)
replace i_firmName = usubinstr(i_firmName,"À","a",.)
replace i_firmName = usubinstr(i_firmName,"Ÿ","y",.)
replace i_firmName = usubinstr(i_firmName,"ž","z",.)
replace i_firmName = usubinstr(i_firmName,"č","c",.)
replace i_firmName = usubinstr(i_firmName,"Č","c",.)
replace i_firmName = usubinstr(i_firmName,"ř","r",.)
replace i_firmName = usubinstr(i_firmName," & "," AND ",.)
replace i_firmName = upper(i_firmName)
replace i_firmName = cond(strpos(i_firmName,"("),substr(i_firmName,1,strpos(i_firmName,"(")-1)+substr(i_firmName,strpos(i_firmName,")")+1,.),i_firmName)
replace i_firmName = regexr(i_firmName," LTD.$"," LIMITED")
replace i_firmName = regexr(i_firmName," LTD$"," LIMITED")
replace i_firmName = regexr(i_firmName," L.L.C.$"," LLC")
replace i_firmName =   regexr(i_firmName," L.L.C$"," LLC")
replace i_firmName =   regexr(i_firmName," L.L.P.$"," LLP")
replace i_firmName =   regexr(i_firmName," L.L.P$"," LLP")
replace i_firmName =   regexr(i_firmName," P.T.Y.$"," PTY")
replace i_firmName =   regexr(i_firmName," P.T.Y$"," PTY")
replace i_firmName =   regexr(i_firmName," PTY.$"," PTY")
replace i_firmName =   regexr(i_firmName," P.L.C.$"," PLC")
replace i_firmName =   regexr(i_firmName," P.L.C$"," PLC")
replace i_firmName =   regexr(i_firmName," PLC.$"," PLC")
replace i_firmName =   regexr(i_firmName," G.M.B.H.$"," GMBH")
replace i_firmName =   regexr(i_firmName," G.M.B.H$"," GMBH")
replace i_firmName =   regexr(i_firmName," GMBH.$"," GMBH")
replace i_firmName =   regexr(i_firmName," M.B.H.$"," MBH")
replace i_firmName =   regexr(i_firmName," M.B.H$"," MBH")
replace i_firmName =   regexr(i_firmName," MBH.$"," MBH")
replace i_firmName =   regexr(i_firmName," S.A.R.L.$"," SARL")
replace i_firmName =   regexr(i_firmName," S.A.R.L$"," SARL")
replace i_firmName =   regexr(i_firmName," SARL.$"," SARL")
replace i_firmName =   regexr(i_firmName," SA RL$"," SARL")
replace i_firmName =   regexr(i_firmName," A.S.$"," AS")
replace i_firmName =   regexr(i_firmName," AS.$"," AS")
replace i_firmName =   regexr(i_firmName," A.S$"," AS")
replace i_firmName =   regexr(i_firmName," A.B.$"," AB")
replace i_firmName =   regexr(i_firmName," AB.$"," AB")
replace i_firmName =   regexr(i_firmName," A.B$"," AB")
replace i_firmName =   regexr(i_firmName," A.G.$"," AG")
replace i_firmName =   regexr(i_firmName," AG.$"," AG")
replace i_firmName =   regexr(i_firmName," A.G$"," AG")
replace i_firmName =   regexr(i_firmName," L.P.$"," LP")
replace i_firmName =   regexr(i_firmName," LP.$"," LP")
replace i_firmName =   regexr(i_firmName," L.P$"," LP")
replace i_firmName = regexr(i_firmName," LLP$","")
replace i_firmName = regexr(i_firmName," LLC$","")
replace i_firmName = regexr(i_firmName," PTY$","")
replace i_firmName = regexr(i_firmName," PLC$","")
replace i_firmName = regexr(i_firmName," GMBH$","")
replace i_firmName = regexr(i_firmName," MBH$","")
replace i_firmName = regexr(i_firmName," AS$","")
replace i_firmName = regexr(i_firmName," AB","")
replace i_firmName = regexr(i_firmName," AG$","")
replace i_firmName = regexr(i_firmName," SARL$","")
replace i_firmName = regexr(i_firmName," LP$","")
replace i_firmName = regexr(i_firmName,"INC.$","INCORPORATED")
replace i_firmName = regexr(i_firmName,"INCORP$","INCORPORATED")
replace i_firmName = regexr(i_firmName,"INC$","INCORPORATED")
replace i_firmName = regexr(i_firmName,"LIMITED$","")
replace i_firmName = regexr(i_firmName,"INCORPORATED$","")
replace i_firmName = regexr(i_firmName,"CORPORATION$","")
replace i_firmName = regexr(i_firmName,"COMPANY$","")
replace i_firmName = regexr(i_firmName,"PARTNERS$","")
replace i_firmName = regexr(i_firmName,"GROUP$","")
replace i_firmName = regexr(i_firmName,"CAPITAL$","")
replace i_firmName = regexr(i_firmName,"FUND$","")
replace i_firmName = regexr(i_firmName,"ASSOCIATES$","")
replace i_firmName = subinstr(i_firmName,",","",.)
replace i_firmName = subinstr(i_firmName,".","",.)
replace i_firmName = strtrim(i_firmName)
replace i_firmName = stritrim(i_firmName)
sort i_firmName
save temp_LP.dta, replace

//Fund Managers
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
keep fm_id fm_firm_name fm_country
replace fm_country = "UNITED STATES" if fm_country=="US"
replace fm_country = "UNITED KINGDOM" if fm_country=="UK"
replace fm_country = "CHINA" if fm_country=="MACAO SAR - CHINA"
replace fm_firm_name = usubinstr(fm_firm_name,"ü","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Å","A",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Í","I",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ö","O",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ö","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Œ","CE",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Â","A",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ü","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ÿ","y",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ý","y",.)
replace fm_firm_name = usubinstr(fm_firm_name,"û","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ú","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ù","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ø","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ö","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"õ","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ô","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ó","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ò","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ñ","n",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ï","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"î","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"í","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ì","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ë","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ê","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"é","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"è","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ç","c",.)
replace fm_firm_name = usubinstr(fm_firm_name,"æ","ae",.)
replace fm_firm_name = usubinstr(fm_firm_name,"å","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ä","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ã","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"â","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"á","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"à","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ý","y",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ü","U",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Û","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ú","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ù","u",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ø","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ö","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Õ","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ô","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ó","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ò","o",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ï","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Î","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Í","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ì","i",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ë","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ê","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"É","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"È","e",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ç","c",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Æ","ae",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Å","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ä","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ã","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Â","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Á","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"À","a",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Ÿ","y",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ž","z",.)
replace fm_firm_name = usubinstr(fm_firm_name,"č","c",.)
replace fm_firm_name = usubinstr(fm_firm_name,"Č","c",.)
replace fm_firm_name = usubinstr(fm_firm_name,"ř","r",.)
replace fm_firm_name = usubinstr(fm_firm_name," & "," AND ",.)
replace fm_firm_name = upper(fm_firm_name)
replace fm_firm_name = cond(strpos(fm_firm_name,"("),substr(fm_firm_name,1,strpos(fm_firm_name,"(")-1)+substr(fm_firm_name,strpos(fm_firm_name,")")+1,.),fm_firm_name)
replace fm_firm_name = regexr(fm_firm_name," LTD.$"," LIMITED")
replace fm_firm_name = regexr(fm_firm_name," LTD$"," LIMITED")
replace fm_firm_name = regexr(fm_firm_name," L.L.C.$"," LLC")
replace fm_firm_name =   regexr(fm_firm_name," L.L.C$"," LLC")
replace fm_firm_name =   regexr(fm_firm_name," L.L.P.$"," LLP")
replace fm_firm_name =   regexr(fm_firm_name," L.L.P$"," LLP")
replace fm_firm_name =   regexr(fm_firm_name," P.T.Y.$"," PTY")
replace fm_firm_name =   regexr(fm_firm_name," P.T.Y$"," PTY")
replace fm_firm_name =   regexr(fm_firm_name," PTY.$"," PTY")
replace fm_firm_name =   regexr(fm_firm_name," P.L.C.$"," PLC")
replace fm_firm_name =   regexr(fm_firm_name," P.L.C$"," PLC")
replace fm_firm_name =   regexr(fm_firm_name," PLC.$"," PLC")
replace fm_firm_name =   regexr(fm_firm_name," G.M.B.H.$"," GMBH")
replace fm_firm_name =   regexr(fm_firm_name," G.M.B.H$"," GMBH")
replace fm_firm_name =   regexr(fm_firm_name," GMBH.$"," GMBH")
replace fm_firm_name =   regexr(fm_firm_name," M.B.H.$"," MBH")
replace fm_firm_name =   regexr(fm_firm_name," M.B.H$"," MBH")
replace fm_firm_name =   regexr(fm_firm_name," MBH.$"," MBH")
replace fm_firm_name =   regexr(fm_firm_name," S.A.R.L.$"," SARL")
replace fm_firm_name =   regexr(fm_firm_name," S.A.R.L$"," SARL")
replace fm_firm_name =   regexr(fm_firm_name," SARL.$"," SARL")
replace fm_firm_name =   regexr(fm_firm_name," SA RL$"," SARL")
replace fm_firm_name =   regexr(fm_firm_name," A.S.$"," AS")
replace fm_firm_name =   regexr(fm_firm_name," AS.$"," AS")
replace fm_firm_name =   regexr(fm_firm_name," A.S$"," AS")
replace fm_firm_name =   regexr(fm_firm_name," A.B.$"," AB")
replace fm_firm_name =   regexr(fm_firm_name," AB.$"," AB")
replace fm_firm_name =   regexr(fm_firm_name," A.B$"," AB")
replace fm_firm_name =   regexr(fm_firm_name," A.G.$"," AG")
replace fm_firm_name =   regexr(fm_firm_name," AG.$"," AG")
replace fm_firm_name =   regexr(fm_firm_name," A.G$"," AG")
replace fm_firm_name =   regexr(fm_firm_name," L.P.$"," LP")
replace fm_firm_name =   regexr(fm_firm_name," LP.$"," LP")
replace fm_firm_name =   regexr(fm_firm_name," L.P$"," LP")
replace fm_firm_name = regexr(fm_firm_name," LLP$","")
replace fm_firm_name = regexr(fm_firm_name," LLC$","")
replace fm_firm_name = regexr(fm_firm_name," PTY$","")
replace fm_firm_name = regexr(fm_firm_name," PLC$","")
replace fm_firm_name = regexr(fm_firm_name," GMBH$","")
replace fm_firm_name = regexr(fm_firm_name," MBH$","")
replace fm_firm_name = regexr(fm_firm_name," AS$","")
replace fm_firm_name = regexr(fm_firm_name," AB","")
replace fm_firm_name = regexr(fm_firm_name," AG$","")
replace fm_firm_name = regexr(fm_firm_name," SARL$","")
replace fm_firm_name = regexr(fm_firm_name," LP$","")
replace fm_firm_name = regexr(fm_firm_name,"INC.$","INCORPORATED")
replace fm_firm_name = regexr(fm_firm_name,"INCORP$","INCORPORATED")
replace fm_firm_name = regexr(fm_firm_name,"INC$","INCORPORATED")
replace fm_firm_name = regexr(fm_firm_name,"LIMITED$","")
replace fm_firm_name = regexr(fm_firm_name,"INCORPORATED$","")
replace fm_firm_name = regexr(fm_firm_name,"CORPORATION$","")
replace fm_firm_name = regexr(fm_firm_name,"COMPANY$","")
replace fm_firm_name = regexr(fm_firm_name,"PARTNERS$","")
replace fm_firm_name = regexr(fm_firm_name,"GROUP$","")
replace fm_firm_name = regexr(fm_firm_name,"CAPITAL$","")
replace fm_firm_name = regexr(fm_firm_name,"FUND$","")
replace fm_firm_name = regexr(fm_firm_name,"ASSOCIATES$","")
replace fm_firm_name = subinstr(fm_firm_name,",","",.)
replace fm_firm_name = subinstr(fm_firm_name,".","",.)
replace fm_firm_name = strtrim(fm_firm_name)
replace fm_firm_name = stritrim(fm_firm_name)
sort fm_firm_name
save temp_GP.dta, replace

use temp_signatory.dta, clear
ren (Signatory HQCountry) (i_firmName i_country)
merge 1:m i_firmName i_country using temp_LP.dta
keep if _m==3
keep i_ID SignatureDate
ren SignatureDate dateUNPRI
merge 1:m i_ID using ".\Data\Data_preqin\preqin_LPs.dta"
drop _m
order dateUNPRI, a(i_yearEstablished)
sort i_ID
save ".\Data\Data_preqin\preqin_LPs.dta", replace

use temp_signatory.dta, clear
ren (Signatory HQCountry) (fm_firm_name fm_country)
merge 1:m fm_firm_name fm_country using temp_GP.dta
keep if _m==3
keep fm_id SignatureDate
drop if inlist(fm_id,162732,30579,190894,14454,2496,753)
ren SignatureDate dateUNPRI
merge 1:m fm_id using ".\Data\Data_preqin\preqin_fund_mgrRaw.dta"
drop _m
order dateUNPRI, a(fm_year_est)
sort fm_id
save ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", replace
erase temp_signatory.dta
erase temp_LP.dta
erase temp_GP.dta
}
**Mapping LPs to GPs
{
import excel using ".\Data\Data_preqin\Preqin_fund_Investor_mapping_20230307.xlsx", clear first
save ".\Data\Data_preqin\LP_GP_map.dta", replace
import excel using ".\Data\Data_preqin\Preqin_fund_Investor_mapping_20230418.xlsx", clear first
append using ".\Data\Data_preqin\LP_GP_map.dta"
duplicates drop
keep INVESTORID FUNDID FUNDMANAGERID
ren (INVESTORID FUNDID FUNDMANAGERID) (i_ID f_id fm_id)
save ".\Data\Data_preqin\LP_GP_map.dta", replace

use ".\Data\Data_preqin\preqin_fund.dta", clear
keep fm_id f_id f_vintageInceptionYear f_status f_lifeSpanYears
drop if missing(f_vintageInceptionYear)
merge 1:m f_id using ".\Data\Data_preqin\LP_GP_map.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\LP_GP_map.dta", replace

//To add the end date of the fund (and therefore the investor)
keep if f_status=="LIQUIDATED"
keep fm_id f_id
duplicates drop
merge 1:m fm_id f_id using ".\Data\Data_preqin\preqin_fundPerformance.dta"
drop if _m==2
keep fm_id f_id f_RVPI f_dateReported _m
drop if _m==3 & f_RVPI>1
gen zero_present = cond(f_RVPI==0,1,0)
bysort fm_id f_id (f_dateReported): egen max_zeroPresent = max(zero_present)
drop if max_zeroPresent==1 & zero_present==0
bysort fm_id f_id (f_dateReported): drop if _n!=1 & _m==3 & max_zeroPresent==1 //first zero observed for RVPI
bysort fm_id f_id (f_dateReported): drop if _n!=_N & _m==3 & max_zeroPresent==0 //obs closest to zero for RVPI (in cases where zero is not present)
gen yearLiquidation = year(f_dateReported)
keep fm_id f_id yearLiquidation
merge 1:m fm_id f_id using ".\Data\Data_preqin\LP_GP_map.dta"
drop _m
save temp.dta, replace

gen yearstart = f_vintageInceptionYear
gen yearstop = yearLiquidation
//the average and median duration is around 15years. So, for the liquidated funds missing the end year I use 15 years as the duration.
replace yearstop = yearstart + 15 if f_status=="LIQUIDATED" & missing(yearstop)
replace yearstop = 2023 if f_status!="LIQUIDATED"
keep fm_id f_id i_ID yearstart yearstop
duplicates drop
reshape long year, i(fm_id f_id i_ID) j(j) str
drop j
egen double id = group(fm_id f_id i_ID)
duplicates drop
tsset id year
tsfill
bysort id (year): carryforward fm_id f_id i_ID, replace
drop id
save ".\Data\Data_preqin\LP_GP_map.dta", replace

use ".\Data\Data_preqin\preqin_LPs.dta", clear
keep i_ID dateUNPRI
gen yearUNPRI = year(dateUNPRI)
drop if missing(yearUNPRI)
drop dateUNPRI
merge 1:m i_ID using ".\Data\Data_preqin\LP_GP_map.dta"
drop if _m==1
gen LPPRISignatory = cond(year>=yearUNPRI & !missing(yearUNPRI),1,0)
drop yearUNPRI _merge
save ".\Data\Data_preqin\LP_GP_map.dta", replace
erase temp.dta
}
**Websites
{
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
drop if missing(fm_website)|missing(fm_country) //7,391 obs dropped
keep fm_id fm_website
sort fm_id

//For websites that get mapped to more than one preqin GP, I retain the GP that has the maximum number of funds
duplicates tag fm_website, gen(tag)
save temp.dta, replace

keep if tag!=0
merge 1:m fm_id using ".\Data\Data_preqin\preqin_fund.dta"
drop if _m==2
bysort fm_website: egen max_merge = max(_m)
drop if max_merge==3 & _m==1
drop _m max_merge
gen fundCntr = 1
replace fundCntr=0 if f_id==.
collapse (sum) fundCntr, by(fm_id fm_website)
bysort fm_website: egen max_fundCntr = max(fundCntr)
drop if fundCntr!=max_fundCntr
drop fundCntr max_fundCntr
save temp1.dta, replace

use temp.dta, clear
keep if tag==0
drop tag
append using temp1.dta
save temp.dta, replace

//for the remaining duplicates, I try to retain the one with the earlier year of establishment or the one with the largest AUM
use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
keep fm_id fm_year_est fm_total_AUM_USD fm_pe_dateUpdated
merge 1:m fm_id using temp.dta
keep if _m==3
drop _m
duplicates tag fm_website, gen(tag)
bysort fm_website: egen double max_AUM = max(fm_total_AUM_USD)
drop if max_AUM!=fm_total_AUM_USD & tag!=0
bysort fm_website: egen double min_year = min(fm_year_est)
drop if min_year!=fm_year_est & tag!=0
bysort fm_website: egen double max_update = max(fm_pe_dateUpdated)
drop if max_update!=fm_pe_dateUpdated & tag!=0
drop fm_year_est fm_total_AUM_USD fm_pe_dateUpdated tag max_AUM min_year max_update
save temp.dta, replace

use ".\Data\Data_preqin\preqin_fund_mgrRaw.dta", clear
drop fm_website
merge 1:1 fm_id using temp.dta
keep if _m==3
drop _m
order fm_website, b(fm_email)
sort fm_id
save ".\Data\Data_preqin\preqin_fund_mgr.dta", replace

erase temp.dta
erase temp1.dta

//Removing websites with Alexa rank < 10,000
import delimited using ".\Data\Data_website\Scrapping\alexaRank\website_exclusion_list.txt", clear delim(" ")
ren v1 fm_website
merge 1:m fm_website using ".\Data\Data_preqin\preqin_fund_mgr.dta"
keep if _m==2 //39 websites with Alexa rank < 10,000
drop _m
order fm_website, a(fm_email)
save ".\Data\Data_preqin\preqin_fund_mgr.dta", replace

//Next we run the python script to identify non-English websites and drop them.
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep fm_website
sort fm_website
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\websites_EnglishIdentification.txt", replace novar

//Run the python script to check which websites have non-English content.

//Dropping websites that are not English content
import delimited ".\Data\Data_website\Scrapping\englishCheck\websites_EnglishIdentification.csv", clear bindq(strict)
gen to_keep = 1 if pycld2=="en" & pycld2_confidence>=70
replace to_keep = 1 if strpos(language_frm_source,"en")
replace to_keep = 1 if langdetect=="en"

keep if to_keep==1
keep url websiteavailable
ren url fm_website
merge 1:m fm_website using ".\Data\Data_preqin\preqin_fund_mgr.dta"
keep if _m==3
drop _m
order fm_website, a(fm_email)
sort fm_id
save ".\Data\Data_preqin\preqin_fund_mgr.dta", replace

//I also identify those fund managers for which we have deal level data. Since deal data is required for weighting in all analyses.
use ".\Data\Data_preqin\preqin_dealsBuyout_investors.dta", clear
keep d_investorID
duplicates drop
ren d_investorID fm_id
merge 1:m fm_id using ".\Data\Data_preqin\preqin_fund_mgr.dta"
drop if _m==1
gen BOdealDataPresent = cond(_m==3,1,0)
drop _m
sort fm_id
save ".\Data\Data_preqin\preqin_fund_mgr.dta", replace

//Based on the above I only retain funds with the fund managers (GPs) in the above list
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep fm_id
merge 1:m fm_id using ".\Data\Data_preqin\preqin_fund.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_fund.dta", replace

use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep fm_id
merge 1:m fm_id using ".\Data\Data_preqin\preqin_fundPerformance.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_fundPerformance.dta", replace

use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep fm_id
ren fm_id d_investorID
merge 1:m d_investorID using ".\Data\Data_preqin\preqin_dealsBuyout_investors.dta"
drop if _m==1
bysort d_dealID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_preqin\preqin_dealsBuyout_investors.dta", replace

keep d_dealID
duplicates drop
save temp.dta, replace

use temp.dta, clear
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsBuyout.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsBuyout.dta", replace

use temp.dta, clear
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsBuyout_debtProviders.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsBuyout_debtProviders.dta", replace

use temp.dta, clear
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsBuyout_exits.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsBuyout_exits.dta", replace

use temp.dta, clear
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsBuyout_exitsSellers.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsBuyout_exitsSellers.dta", replace

use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep fm_id
ren fm_id d_investorID
merge 1:m d_investorID using ".\Data\Data_preqin\preqin_dealsVC_investors.dta"
drop if _m==1
bysort d_dealID: egen maxMerge = max(_m)
drop if maxMerge!=3
drop _m maxMerge
save ".\Data\Data_preqin\preqin_dealsVC_investors.dta", replace

keep d_dealID
duplicates drop
save temp.dta, replace

use temp.dta, clear
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsVC.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsVC.dta", replace

use temp.dta, clear
merge 1:m d_dealID using ".\Data\Data_preqin\preqin_dealsVC_exits.dta"
keep if _m==3
drop _m
save ".\Data\Data_preqin\preqin_dealsVC_exits.dta", replace

erase temp.dta

//One small cleanup
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
replace fm_website = subinstr(fm_website,"#tabteaser-tab","",.)
replace fm_website = regexr(fm_website,"/#!$","")
replace fm_website = regexr(fm_website,"#home$","")
replace fm_website = regexr(fm_website,"#about$","")
replace fm_website = regexr(fm_website,"#mvcf$","")
replace fm_website = regexr(fm_website,"#header$","")
replace fm_website = regexr(fm_website,"#private-equity$","private-equity")
replace fm_website = regexr(fm_website,"#start$","")
replace fm_website = regexr(fm_website,"#top$","")
replace fm_website = regexr(fm_website,"#main$","")
replace fm_website = regexr(fm_website,"#mosaic$","")
replace fm_website = regexr(fm_website,"#nwv$","")
replace fm_website = regexr(fm_website,"#1$","")
replace fm_website = regexr(fm_website,"#page1$","")
replace fm_website = regexr(fm_website,"/#/en$","/en")
replace fm_website = regexr(fm_website,"#woven-capital-overview$","")
replace fm_website = regexr(fm_website,"/#/who-we-are$","")
replace fm_website = regexr(fm_website,"#bhpventures$","/ventures")
replace fm_website = regexr(fm_website,"/#accelerator$","")
replace fm_website = regexr(fm_website,"/#/home$","")
replace fm_website = regexr(fm_website,"/#section/0$","")
replace fm_website = regexr(fm_website,"/#about-us$","")
replace fm_website = "https://advocateaurorahealth.org/advocateauroraenterprises/" if fm_website=="http://advocateaurorahealth.org/advocateauroraenterprises/#:~:text=aae%20is%20a%20subsidiary%20"
save ".\Data\Data_preqin\preqin_fund_mgr.dta", replace

use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep if fm_listed_num==1
keep fm_id fm_country fm_firm_name fm_website fm_city fm_region fm_address fm_firm_type
save ".\Data\Data_IPO\listOfPublicPEfirms.dta", replace

//Generating the scraping rounds
//First round - PE firms with BO deals and part of the first dataset
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
keep if BOdealDataPresent==1
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 1.txt", replace

//Second round - PE firms with no BO deals and top PE firms
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
keep if topPEFirmReports==1
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 2.txt", replace

//Third round - PE firms with no BO deals and top AUM
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
drop if topPEFirmReports==1
keep if topPEFirmAUM==1
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 3.txt", replace

//Fourth round - PE firms with no BO deals and main strat is BUYOUT (all countries)
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
drop if topPEFirmReports==1|topPEFirmAUM==1
keep if fm_pe_mainFirmStrategy=="BUYOUT"
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 4.txt", replace

//Fifth round - PE firms with no BO deals and country is US and main strat is VC
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
drop if topPEFirmReports==1|topPEFirmAUM==1|fm_pe_mainFirmStrategy=="BUYOUT"
keep if country_us==1 & fm_pe_mainFirmStrategy=="VENTURE CAPITAL"
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 5.txt", replace

//Sixth round - PE firms with no BO deals and country is US and all other firms
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
drop if topPEFirmReports==1|topPEFirmAUM==1|fm_pe_mainFirmStrategy=="BUYOUT"
keep if country_us==1 & fm_pe_mainFirmStrategy!="VENTURE CAPITAL"
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 6.txt", replace

//Seventh round - PE firms with no BO deals and EU firms 
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
drop if topPEFirmReports==1|topPEFirmAUM==1|fm_pe_mainFirmStrategy=="BUYOUT"|country_us==1
keep if country_eu==1
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 7.txt", replace

//Eighth round - PE firms with no BO deals and non-EU and US firms 
use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
drop if BOdealDataPresent==1
drop if topPEFirmReports==1|topPEFirmAUM==1|fm_pe_mainFirmStrategy=="BUYOUT"|country_us==1|country_eu==1
keep fm_id fm_website
sort fm_id
export delimited using ".\Data\Data_website\Scrapping\Inputs to the scraping process\rounds\round 8.txt", replace
}

log closelog using ".\logfile_publicFirms", replace

set more off
clear all

import excel using ".\Data\Data_IPO\raw_data\EikonIPODates_1_20230325.xlsx", clear first
save temp.dta, replace
import excel using ".\Data\Data_IPO\raw_data\EikonIPODates_2_20230325.xlsx", clear first
append using temp.dta
replace OrganizationWebsite = regexr(OrganizationWebsite,"^https://","")
replace OrganizationWebsite = regexr(OrganizationWebsite,"^http://","")
replace OrganizationWebsite = regexr(OrganizationWebsite,"^www.","")
replace OrganizationWebsite = regexr(OrganizationWebsite,"/$","")
replace OrganizationWebsite = cond(OrganizationWebsite=="",OrganizationWebsite,"http://"+OrganizationWebsite)
replace CompanyName = upper(CompanyName)
replace CountryofHeadquarters = upper(CountryofHeadquarters)
foreach var of varlist * {
	ren `var' Ek_`var'
}
save tempEikon.dta, replace

import excel using ".\Data\Data_IPO\raw_data\FactsetIPODates_20230325.xlsx", clear first 
ren (FactSetUniversalScreening B C D E F G H I J K L M) ///
	(symbol firmName stockExchg website website2 sicCode announcementDate listingDate offerDate pricingDate firstTradeDate ticker countryIncorp)
drop in 1/6
foreach var of varlist announcementDate listingDate offerDate pricingDate firstTradeDate {
	gen t`var' = date(`var',"YMD")
	drop `var'
	ren t`var' `var'
	format `var' %td
}
replace firmName = upper(firmName)
foreach var of varlist website website2 sicCode {
	replace `var' = "" if `var'=="@NA"
}
foreach var of varlist website website2 {
	replace `var' = regexr(`var',"^https://","")
	replace `var' = regexr(`var',"^http://","")
	replace `var' = regexr(`var',"^www.","")
	replace `var' = regexr(`var',"/$","")
	replace `var' = "http://"+`var' if `var'!=""
}
foreach var of varlist * {
	ren `var' Fs_`var'
}
save tempFactset.dta, replace

import excel using ".\Data\Data_IPO\raw_data\IPO Data_CapitalIQ_2000-2009_20230425.xls", clear first 
ren (CapitalIQTransactionScreening B C D E F G H I J K L M N O P Q) ///
	(announcementDate firmName ticker ticker2 transactionType transactionStatus transactionValue grossProceeds netProceeds CIQTxnID closeDate txnPrimaryFeature buyer seller countryIncorp website exchange)
drop in 1/2
save tempCIQ.dta, replace
import excel using ".\Data\Data_IPO\raw_data\IPO Data_CapitalIQ_2010-2016_20230425.xls", clear first 
ren (CapitalIQTransactionScreening B C D E F G H I J K L M N O P Q) ///
	(announcementDate firmName ticker ticker2 transactionType transactionStatus transactionValue grossProceeds netProceeds CIQTxnID closeDate txnPrimaryFeature buyer seller countryIncorp website exchange)
drop in 1/2
append using tempCIQ.dta
save tempCIQ.dta, replace
import excel using ".\Data\Data_IPO\raw_data\IPO Data_CapitalIQ_2017-2020_20230425.xls", clear first 
ren (CapitalIQTransactionScreening B C D E F G H I J K L M N O P Q) ///
	(announcementDate firmName ticker ticker2 transactionType transactionStatus transactionValue grossProceeds netProceeds CIQTxnID closeDate txnPrimaryFeature buyer seller countryIncorp website exchange)
drop in 1/2
append using tempCIQ.dta
save tempCIQ.dta, replace
import excel using ".\Data\Data_IPO\raw_data\IPO Data_CapitalIQ_2021-2022_20230425.xls", clear first 
ren (CapitalIQTransactionScreening B C D E F G H I J K L M N O P Q) ///
	(announcementDate firmName ticker ticker2 transactionType transactionStatus transactionValue grossProceeds netProceeds CIQTxnID closeDate txnPrimaryFeature buyer seller countryIncorp website exchange)
drop in 1/2
append using tempCIQ.dta
replace firmName = upper(firmName)
replace website = "" if website=="-"
replace website = regexr(website,"^https://","")
replace website = regexr(website,"^http://","")
replace website = regexr(website,"^www.","")
replace website = regexr(website,"/$","")
replace website = "http://"+website if website!=""
foreach var of varlist announcementDate closeDate {
	gen t`var' = date(`var',"DMY")
	drop `var'
	ren t`var' `var'
	format `var' %td
}
foreach var of varlist * {
	ren `var' Cq_`var'
}
save tempCIQ.dta, replace

use ".\Data\Data_IPO\raw_data\CompustatNA_20230430.dta", clear
keep gvkey conm exchg add1 city weburl tic ipodate
duplicates drop
replace weburl = "" if weburl=="-"
replace weburl = regexr(weburl,"^https://","")
replace weburl = regexr(weburl,"^http://","")
replace weburl = regexr(weburl,"^www.","")
replace weburl = regexr(weburl,"/$","")
replace weburl = "http://"+weburl if weburl!=""
drop if missing(ipodate)
foreach var of varlist * {
	ren `var' CompNA_`var'
}
save tempCompNA.dta, replace

use ".\Data\Data_IPO\raw_data\CompustatGlobal_20230430.dta", clear
keep gvkey conm exchg add1 city fic weburl isin ipodate
duplicates drop
replace weburl = "" if weburl=="-"
replace weburl = regexr(weburl,"^https://","")
replace weburl = regexr(weburl,"^http://","")
replace weburl = regexr(weburl,"^www.","")
replace weburl = regexr(weburl,"/$","")
replace weburl = "http://"+weburl if weburl!=""
drop if missing(ipodate)
foreach var of varlist * {
	ren `var' CompGl_`var'
}
save tempCompGl.dta, replace

import excel using ".\Data\Data_IPO\raw_data\CountryISOCodes.xlsx", clear first
keep Englishshortname Alpha2code
ren (Englishshortname Alpha2code) (fm_country country2Code)
merge 1:m fm_country using ".\Data\Data_IPO\listOfPublicPEfirms.dta"
keep if _m==3
drop _m
save ".\Data\Data_IPO\listOfPublicPEfirms.dta", replace

use ".\Data\Data_IPO\listOfPublicPEfirms.dta", clear
ren fm_website Fs_website
merge 1:m Fs_website using tempFactset.dta
drop if _m==2
duplicates tag fm_id, gen(tag)
drop if tag!=0 & Fs_stockExchg=="@NA"
drop tag
drop if fm_id==771 & Fs_ticker!="FSG-LON"
drop if fm_id==9306 & Fs_ticker!="GAON-TAE"
drop if fm_id==22154 & Fs_ticker!="BN-TSE"
drop if fm_id==23114 & Fs_ticker!="JEF-USA"
drop if fm_id==165100 & Fs_ticker!="BBXIA-USA"
drop if fm_id==249042 & Fs_ticker!="JHG-USA"
drop if fm_id==289862 & Fs_ticker!="5211-KLS"
drop if fm_id==173801 & Fs_ticker!="STZ-USA"
drop if fm_id==36630 & Fs_ticker!="KINV.B-OME"
drop _m
save temp.dta, replace

ren Fs_website Ek_OrganizationWebsite
merge 1:m Ek_OrganizationWebsite using tempEikon.dta
drop if _m==2
drop _m
save temp.dta, replace

ren Ek_OrganizationWebsite Cq_website
merge 1:m Cq_website using tempCIQ.dta
drop if _m==2
drop _m
drop if fm_id==7931 & Cq_ticker=="IDX:AMOR"
drop if fm_id==554 & Cq_firmName=="OAKTREE SPECIALTY LENDING CORPORATION"
save temp.dta, replace

ren Cq_website CompNA_weburl
merge 1:m CompNA_weburl using tempCompNA.dta
drop if _m==2
drop _m
save temp.dta, replace

ren CompNA_weburl CompGl_weburl
merge 1:m CompGl_weburl using tempCompGl.dta
drop if _m==2
drop _m
drop if fm_id==7931 & CompGl_exchg==175
save temp.dta, replace

gen IPODate = Fs_firstTradeDate
replace IPODate = Ek_IPODate if missing(IPODate)
replace IPODate = Cq_closeDate if missing(IPODate)
replace IPODate = CompNA_ipodate if missing(IPODate)
replace IPODate = CompGl_ipodate if missing(IPODate)
keep fm_id IPODate Fs_ticker Ek_TickerSymbol Cq_ticker Cq_ticker2 CompNA_tic CompGl_isin
save temp.dta, replace

import excel using ".\Data\Data_IPO\raw_data\FactsetManuallyCollectedIPODates_20230430.xlsx", clear first all sheet(Sheet1)
gen ipoDate = date(dateoffirsttrade,"YMD")
gen ipoDate2 = date(pricingdate,"YMD")
destring fm_id, replace
keep ipoDate ipoDate2 fm_id ticker
merge 1:m fm_id using temp.dta
replace IPODate = ipoDate if _m==3 & missing(IPODate)
replace IPODate = ipoDate2 if _m==3 & missing(IPODate)
replace Fs_ticker = ticker if _m==3
keep fm_id IPODate Fs_ticker
format IPODate %td
save ".\Data\Data_IPO\IPODates.dta", replace

use ".\Data\Data_IPO\listOfPublicPEfirms.dta", clear
keep fm_id fm_firm_name
merge 1:1 fm_id using ".\Data\Data_IPO\IPODates.dta"
drop _m
save ".\Data\Data_IPO\IPODates.dta", replace

use ".\Data\Data_preqin\preqin_fund_mgr.dta", clear
merge 1:1 fm_id using ".\Data\Data_IPO\IPODates.dta", keepus(IPODate)
drop _m
order IPODate, a(fm_listed_num)
save ".\Data\Data_preqin\preqin_fund_mgr.dta", replace

erase temp.dta
erase tempCIQ.dta
erase tempFactset.dta
erase tempCompGl.dta
erase tempCompNA.dta
erase tempEikon.dta

//In order to control for the correlates of voluntary disclosures - following Bouland et al (2022), we need the following:
//1. Gross size of 10-K filings - the size in bytes of the complete submission text file. [(Loughran and McDonald (2014)]
//2. Management forecasts [Marquardt and Wiedman (1998), King et al. (1990)]
//3. Extent of disaggregation of financial statements [Chen et al. (2015)]
//4. Word count of voluntary 8-K filings, specifically items 2.02, 7.01 and 8.01 [He & Plumlee (2020)]
//Given the items 1 and 4, we limit ourselves to US listed firms specifically.
use ".\Data\Data_IPO\IPODatesUS.dta", clear
gen country = substr(Fs_ticker,strlen(Fs_ticker)-2,.)
keep if country=="USA"
gen ticker = substr(Fs_ticker,1,strpos(Fs_ticker,"-")-1)
save temp.dta, replace

use ".\Data\Data_IPO\raw_data\gvkey_ticker_CIK_map_20230509.dta", clear
keep gvkey tic conm cik
duplicates drop
drop if missing(cik)
ren tic ticker
joinby ticker using temp.dta, unmatched(using)
replace cik = "0001813603" if ticker=="HSTA"
replace cik = "0001814974" if ticker=="BBXIA"
keep fm_id fm_firm_name Fs_ticker IPODate cik gvkey
order fm_id fm_firm_name Fs_ticker IPODate cik gvkey
sort fm_id
save ".\Data\Data_IPO\IPODatesUS.dta", replace

keep cik
duplicates drop
drop if missing(cik)
export delimited ".\Data\Data_IPO\raw_data\cik_input2WRDS.txt", replace novar

**1. Gross size of 10-K filings
use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep cik
duplicates drop
drop if missing(cik)
export delimited using ".\Data\Data_IPO\raw_data\10k gross size\cik.txt", replace novar

use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep cik
duplicates drop
drop if missing(cik)
merge 1:m cik using ".\Data\Data_IPO\raw_data\10k gross size\10KGrossSize_20230806.dta"
keep if _m==3
drop _m
gen url = "https://www.sec.gov/Archives/" + fname
keep cik fdate fsize secpdate url
save ".\Data\Data_IPO\raw_data\10k gross size\10KGrossSizeforPy.dta", replace
//Now run the Python code on the above to get the file size.

**2. Management Guidance - No of Mgmt Guidance
use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep gvkey 
duplicates drop
drop if missing(gvkey)
export delimited using ".\Data\Data_IPO\raw_data\management forecasts\gvkey.txt", replace novar

use ".\Data\Data_IPO\raw_data\management forecasts\gvkey_PERMCO.dta", clear
keep gvkey LPERMCO LPERMNO LINKDT LINKENDDT
replace LINKENDDT = mdy(12,31,2022) if LINKENDDT==.e
ren (LINKDT LINKENDDT) (date1 date2)
gen i = _n
reshape long date, i(i gvkey LPERMCO LPERMNO) j(j)
drop j
tsset i date
tsfill
bysort i (date): carryforward gvkey LPERMCO LPERMNO, replace
drop if !inrange(date,mdy(01,01,2000),mdy(12,31,2022))
gen year = year(date)
drop date i
duplicates drop
save temp.dta, replace

keep LPERMNO
duplicates drop
drop if missing(LPERMNO)
export delimited using ".\Data\Data_IPO\raw_data\management forecasts\permno.txt", replace novar

use ".\Data\Data_IPO\raw_data\management forecasts\PERMNO_ibes.dta", clear
keep TICKER PERMNO sdate edate
ren (sdate edate) (date1 date2)
gen i = _n
reshape long date, i(i TICKER PERMNO) j(j)
drop j
tsset i date
tsfill
bysort i (date): carryforward TICKER PERMNO, replace
drop if !inrange(date,mdy(01,01,2000),mdy(12,31,2022))
gen year = year(date)
drop date i
duplicates drop
ren PERMNO LPERMNO
joinby LPERMNO year using temp.dta
keep gvkey TICKER year
drop if TICKER=="COLN" & year==2017
save temp.dta, replace

keep TICKER
duplicates drop
export delimited using ".\Data\Data_IPO\raw_data\management forecasts\ibesTickers.txt", replace novar

use ".\Data\Data_IPO\raw_data\management forecasts\IBESGuidance_20230805.dta", clear
keep if measure=="EPS"
keep ticker anndats prd_yr prd_mon val_1 val_2 
ren ticker TICKER
ren prd_yr year
joinby TICKER year using temp.dta
keep gvkey anndats year prd_mon val_1 val_2
save ".\Data\Data_IPO\MgmtForecasts.dta", replace
erase temp.dta

**3. Extent of disaggregation in financial statements
use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep cik
duplicates drop
drop if missing(cik)
export delimited using ".\Data\Data_IPO\raw_data\FSdisaggregation\cik.txt", replace novar

use ".\Data\Data_IPO\raw_data\FSdisaggregation\FSitems_20230806.dta", clear
keep if indfmt=="INDL"
rename *, upper
egen nm1 = rownonmiss(ACODO ACOX XPP ACDO ACO CHE INVT RECT CB CH IVST INVFG INVO INVRM INVWIP RECCO RECD RECTR RECUB TXR)
replace nm1 = nm1/20
replace nm1 = . if ACT==0|ACT==.
egen nm2 = rownonmiss(ALDO AODO AOX DC)
replace nm2 = nm2/4
replace nm2 = . if AO==0|AO==.
egen nm3 = rownonmiss(AOCIDERGL AOCIOTHER AOCIPEN AOCISECGL RECTA CAPS CEQL CEQT CSTK RE TSTK CSTKCV ACOMINC REA REAJO REAJO REUNA REUNR SEQO TSTKC TSTKP)
replace nm3 = nm3/21
replace nm3 = . if CEQ==0|CEQ==.
egen nm4 = rownonmiss(DCLO DCS DCVSR DCVSUB DCVT DD DD2 DD3 DD4 DD5 DFS DLTO DLTP DM DN DS DUDD)
replace nm4 = nm4/17
replace nm4 = . if DLTT==0|DLTT==.
egen nm5 = rownonmiss(GDWL INTANO)
replace nm5 = nm5/2
replace nm5 = . if INTAN==.|INTAN==0
gen nm6 = (MSA!=.)
replace nm6 = . if IVAO==.|IVAO==0
egen nm7 = rownonmiss(BASTR BAST DD1 NP DRC LCOX XACC AP DLC LCO TXP)
replace nm7 = nm7/11
replace nm7 = . if LCT==.|LCT==0
gen nm8 = (DRLT!=.)
replace nm8 = . if LO==.|LO==0
egen nm9 = rownonmiss(DPACO DPACT FATB FATC FATE FATL FATN FATO PPEGT)
replace nm9 = nm9/9
replace nm9 = . if PPENT==.|PPENT==0
egen nm10 = rownonmiss(DVPA PSTKC PSTKL PSTKN PSTKR PSTKRV)
replace nm10 = nm10/6
replace nm10 = . if PSTK==.|PSTK==0
egen nm11 = rownonmiss(ITCB	TXDB)
replace nm11 = nm11/2
replace nm11 = . if TXDITC==.|TXDITC==0

egen dq_bs = rowmean(nm1 - nm11)

egen nm12 = rownonmiss(CIBEGNI CICURR CIDERGL CIOTHER CIPEN CISECGL)
replace nm12 = nm12/6
replace nm12 = . if CITOTAL==.|CITOTAL==0
egen nm13 = rownonmiss(ESUB FCA IDIT INTC IRENT NOPIO)
replace nm13 = nm13/6
replace nm13 = . if NOPI==.|NOPI==0
egen nm14 = rownonmiss(AQP DTEP GDWLIP GLP NRTXT RCP RDIP RRP SETP SPIOP WDP)
replace nm14 = nm14/11
replace nm14 = . if SPI==.|SPI==0
egen nm15 = rownonmiss(ITCI TXC TXDFED TXDFO TXDI TXDS TXFED TXFO TXO TXS TXW)
replace nm15 = nm15/11
replace nm15 = . if TXT==.|TXT==0
egen nm16 = rownonmiss(ACCHG DO DONR XI)
replace nm16 = nm16/4
replace nm16 = . if XIDO==.|XIDO==0
gen nm17 = (XINTD!=.)
replace nm17 = . if XINT==.|XINT==0
egen nm18 = rownonmiss(AM COGS DFXA DP STKCPA XAD XLR XPR XRD XRENT XSGA XSTFO)
replace nm18 = nm18/12
replace nm18 = . if XOPR==.|XOPR==0

egen dq_is = rowmean(nm12 - nm18)
egen dq = rowmean(dq_bs dq_is)
keep CIK FYEAR dq
ren (CIK FYEAR) (cik year)
save ".\Data\Data_IPO\FSitems.dta", replace

//4. Voluntary 8-K filings - word count
use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep cik
duplicates drop
drop if missing(cik)
merge 1:m cik using ".\Data\Data_IPO\raw_data\voluntary 8k\8Kitems_20230805.dta"
keep if _m==3
drop _m
keep if inlist(nitem,"2.02","7.01","8.01")
gen text_url = "https://www.sec.gov/Archives/" + fname
replace text_url = strtrim(text_url)
split text_url, g(end) p("/")
gen index_url = end1+"/"+end2+"/"+end3+"/"+end4+"/"+end5+"/"+end6+"/"+end7+"/"
drop end1-end7
gen inter = subinstr(end8,"-","",.)
replace inter = subinstr(inter,".txt","",.)
replace index_url = index_url+inter+"/"
replace end8 = subinstr(end8,".txt","-index.htm",.)
replace index_url = index_url+end8
drop end8 inter
keep cik fdate index_url 
save ".\Data\Data_IPO\raw_data\voluntary 8k\8KitemsforPy.dta", replace
//Now run the Python code on the above to get the word count.

//Following Boulland et al, disclosure quality (disaggregation) and 10K size is at annual frequency and the other two are at quarterly frequency
use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep fm_id cik
joinby cik using ".\Data\Data_IPO\10KGrossSize.dta"
gen year = year(dofc(fdate))
keep fm_id year txtFileSize
label var txtFileSize "10-K file size (gross) (in MB)"
replace txtFileSize = txtFileSize/1000000
bysort fm_id year (txtFileSize): keep if _n==_N //1 duplicate
save ".\Data\Data_IPO\VoluntaryDisclosuresAnn.dta", replace

use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep fm_id cik
joinby cik using ".\Data\Data_IPO\FSitems.dta"
keep fm_id year dq
label var dq "Disclosure Quality"
merge 1:1 fm_id year using ".\Data\Data_IPO\VoluntaryDisclosuresAnn.dta"
drop _m
save ".\Data\Data_IPO\VoluntaryDisclosuresAnn.dta", replace

use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep fm_id gvkey
drop if missing(gvkey)
joinby gvkey using ".\Data\Data_IPO\MgmtForecasts.dta"
gen yearQtr = yq(year(anndats),quarter(anndats))
drop if missing(val_1)
collapse (count) val_1, by(fm_id yearQtr)
keep fm_id yearQtr val_1
label var val_1 "Management Forecast"
save ".\Data\Data_IPO\VoluntaryDisclosuresQtr.dta", replace

use ".\Data\Data_IPO\IPODatesUS.dta", clear
keep fm_id cik
drop if missing(cik)
joinby cik using ".\Data\Data_IPO\8KWordCount.dta"
gen yearQtr = yq(year(dofc(fdate)),quarter(dofc(fdate)))
collapse (sum) wordCount, by(fm_id yearQtr)
label var wordCount "Voluntary 8-K filings"
merge 1:1 fm_id yearQtr using ".\Data\Data_IPO\VoluntaryDisclosuresQtr.dta"
drop _m
save ".\Data\Data_IPO\VoluntaryDisclosuresQtr.dta", replace

log closelog using "logfile_reprisk", replace

set more off
clear all

********************************************************************************
*********************************REPRISK FIRMS**********************************
********************************************************************************
import delimited using ".\Data\Data_Reprisk_ESG\companyIdentifiers_20230609.txt", clear
ren (company_name headquarters_country url) (companyname country webpage)
replace country = upper(country)
replace country = "UNITED STATES" if country=="UNITED STATES OF AMERICA"
replace country = "UNITED KINGDOM" if country=="UNITED KINGDOM OF GREAT BRITAIN AND NORTHERN IRELAND"
replace country = "US VIRGIN ISLANDS" if country=="VIRGIN ISLANDS (U.S.)"
replace country = "BOSNIA & HERZEGOVINA" if country=="BOSNIA AND HERZEGOVINA"
replace country = "CURAçAO" if country=="CURAÃ§AO"
replace country = "VIETNAM" if country=="VIET NAM (VIETNAM)"
replace country = "DEMOCRATIC REPUBLIC OF CONGO" if country=="CONGO (THE DEMOCRATIC REPUBLIC OF THE)"
replace country = "TAIWAN - CHINA" if country=="TAIWAN"
replace country = "CZECH REPUBLIC" if country=="CZECHIA"
replace country = "LAOS" if country=="LAO PEOPLE'S DEMOCRATIC REPUBLIC"
replace country = "RUSSIA" if country=="RUSSIAN FEDERATION"
replace country = "TANZANIA" if country=="TANZANIA, THE UNITED REPUBLIC OF"
replace country = "BOLIVIA" if country=="BOLIVIA (PLURINATIONAL STATE OF)"
replace country = "VENEZUELA" if country=="VENEZUELA (BOLIVARIAN REPUBLIC OF)"
replace country = "MACAO SAR - CHINA" if country=="MACAO"
replace country = "MOLDOVA" if country=="MOLDOVA (THE REPUBLIC OF)"
replace country = "SOUTH KOREA" if country=="KOREA, THE REPUBLIC OF (SOUTH KOREA)"
replace country = "PALESTINE" if country=="PALESTINE, STATE OF"
replace country = "COMORO ISLANDS" if country=="COMOROS"
replace country = "IVORY COAST" if country=="CÃ´TE D'IVOIRE (IVORY COAST)"
replace country = "SAINT VINCENT" if country=="SAINT VINCENT AND THE GRENADINES"
replace country = "BRUNEI" if country=="BRUNEI DARUSSALAM"
replace country = "CAPE VERDE" if country=="CABO VERDE (CAPE VERDE)"
replace country = "HONG KONG SAR - CHINA" if country=="HONG KONG"
replace country = "MACEDONIA" if country=="NORTH MACEDONIA"

replace webpage = "" if inlist(webpage,"No Website Available","http://No Website Available","http://No website available")
forvalues i = 1/3 {
	replace webpage = regexr(webpage,"^http://","")
	replace webpage = regexr(webpage,"^https://","")
	replace webpage = regexr(webpage,"^www\.","")
	replace webpage = regexr(webpage,"#$","")
	replace webpage = regexr(webpage,"/$","")
}
replace webpage = strtrim(webpage)
replace webpage = "http://" + webpage if webpage!=""

forvalues i = 1/3 {
	replace webpage = regexr(webpage,"#$","")
	replace webpage = regexr(webpage,"/$","")
	replace webpage = regexr(webpage,"/en-gb$","")
	replace webpage = regexr(webpage,"/en$","")
}
replace webpage = cond(strpos(webpage,".com/"),substr(webpage,1,strpos(webpage,".com/")+3),webpage)

replace companyname = upper(companyname)
gen cleanedName = companyname
replace cleanedName = upper(cleanedName)
local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace cleanedName = subinstr(cleanedName,"`a'","a",.)
}
foreach e of local specialEs {
	replace cleanedName = subinstr(cleanedName,"`e'","e",.)
}
foreach i of local specialIs {
	replace cleanedName = subinstr(cleanedName,"`i'","i",.)
}
foreach o of local specialOs {
	replace cleanedName = subinstr(cleanedName,"`o'","o",.)
}
foreach u of local specialUs {
	replace cleanedName = subinstr(cleanedName,"`u'","u",.)
}
foreach y of local specialYs {
	replace cleanedName = subinstr(cleanedName,"`y'","y",.)
}
replace cleanedName = subinstr(cleanedName,"ñ","n",.)
replace cleanedName = subinstr(cleanedName,"Ñ","n",.)
replace cleanedName = subinstr(cleanedName,"æ","ae",.)
replace cleanedName = subinstr(cleanedName,"Æ","ae",.)
replace cleanedName = subinstr(cleanedName,"Œ","ce",.)
replace cleanedName = subinstr(cleanedName,"œ","ce",.)
replace cleanedName = subinstr(cleanedName,"Ç","c",.)
replace cleanedName = subinstr(cleanedName,"ç","c",.)
replace cleanedName = usubinstr(cleanedName,"ž","z",.)

replace cleanedName = subinstr(cleanedName,".","",.)
replace cleanedName = subinstr(cleanedName,",","",.)
replace cleanedName = subinstr(cleanedName,"-","",.)
replace cleanedName = subinstr(cleanedName,"/","",.)
replace cleanedName = subinstr(cleanedName,"'","",.)
replace cleanedName = subinstr(cleanedName,"!","",.)
replace cleanedName = subinstr(cleanedName,":","",.)
replace cleanedName = subinstr(cleanedName,";","",.)
replace cleanedName = subinstr(cleanedName,"#","",.)
replace cleanedName = subinstr(cleanedName,"*","",.)
replace cleanedName = subinstr(cleanedName,"@","",.)
replace cleanedName = subinstr(cleanedName,"_","",.)
replace cleanedName = subinstr(cleanedName,"|","",.)
replace cleanedName = subinstr(cleanedName,"$","",.)
replace cleanedName = subinstr(cleanedName,"\","",.)
replace cleanedName = subinstr(cleanedName,"+","",.)
replace cleanedName = usubinstr(cleanedName,"¿","",.)

replace cleanedName = subinstr(cleanedName,"&"," & ",.)
replace cleanedName  = subinstr(cleanedName ," AND "," & ",.)

forvalues i = 1/3 {
	replace cleanedName  = regexr(cleanedName,"BERHAD","BHD")
	replace cleanedName  = regexr(cleanedName,"PRIVATE","PVT")
	replace cleanedName  = regexr(cleanedName,"LIMITED","LTD")
	replace cleanedName  = regexr(cleanedName,"COMPANY","CO")
	replace cleanedName  = regexr(cleanedName,"INCORPORATED","INC")
	replace cleanedName  = regexr(cleanedName,"PTY","PVT")
	replace cleanedName  = regexr(cleanedName,"CORPORATION","CORP")
	replace cleanedName  = regexr(cleanedName,"CO LTD","COLTD")
	replace cleanedName  = regexr(cleanedName ,"L L C","LLC")
	replace cleanedName  = regexr(cleanedName," INTL "," INTERNATIONAL ")
	replace cleanedName  = regexr(cleanedName," COS "," CO ")
	replace cleanedName  = regexr(cleanedName," COS$"," CO$")
	replace cleanedName  = regexr(cleanedName," S A$"," SA")
	replace cleanedName  = regexr(cleanedName," S C$"," SC")
	replace cleanedName  = regexr(cleanedName," P C$"," PC")
	replace cleanedName  = regexr(cleanedName," N V$"," NV")
	replace cleanedName  = regexr(cleanedName," SA RL$"," SARL")
}

replace cleanedName  = subinstr(cleanedName ,"SERVICES","SERVICE",.)
replace cleanedName  = subinstr(cleanedName ,"SYSTEMS","SYSTEM",.)
replace cleanedName  = subinstr(cleanedName ,"HOLDINGS","HOLDING",.)
replace cleanedName  = subinstr(cleanedName ,"SOLUTIONS","SOLUTION",.)
replace cleanedName  = subinstr(cleanedName ,"PRODUCTS","PRODUCT",.)
replace cleanedName  = subinstr(cleanedName ,"PARTNERS","PARTNER",.)
replace cleanedName  = subinstr(cleanedName ,"ENTERPRISES","ENTERPRISE",.)
replace cleanedName  = subinstr(cleanedName ,"MATERIALS","MATERIAL",.)
replace cleanedName  = subinstr(cleanedName ,"METALS","METAL",.)
replace cleanedName  = subinstr(cleanedName ,"CHEMICALS","CHEMICAL",.)

replace cleanedName  = strtrim(cleanedName )
replace cleanedName  = stritrim(cleanedName )
replace cleanedName = upper(cleanedName)
duplicates drop

gen cleanedName_noExt = cleanedName

forvalues i = 1/3 {
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"^THE ","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CO$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PVT LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CO LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTDA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LLC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LLP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," INC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PVT$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PTY$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PLC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," INC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CORP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"^OOO ","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," GMBH$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," MBH$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," SARL$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AS$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AB$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AG$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SCA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," NV$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SL$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," BV$","")
	replace cleanedName_noExt  = subinstr(cleanedName_noExt ," OOO$","",.)
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"S$","")
	replace cleanedName_noExt  = strtrim(cleanedName_noExt )
	replace cleanedName_noExt  = stritrim(cleanedName_noExt )
}
gen cleanedName_noSpace = subinstr(cleanedName_noExt," ","",.)
gen cleanedName_noFreq = cleanedName_noSpace

forvalues i = 1/3 {
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"INDUSTRIES","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"HOLDING","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"GROUP","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"PRODUCT","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"INTERNATIONAL","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"TECHNOLOGIES","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"&","",.)	
}
 
compress
recast str400 webpage
save ".\Data\Data_Reprisk_ESG\repriskNames.dta", replace
********************************************************************************
****************************TARGET FIRMS - PREQIN*******************************
********************************************************************************
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep d_dealID d_firmName d_dealYear d_firmID d_firmCountry d_firmWebsite
duplicates drop
save ".\Data\Data_Reprisk_ESG\PreqinNames.dta", replace

use ".\Data\Data_preqin\preqin_dealsVC.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep d_dealID d_firmName d_dealYear d_firmID d_firmCountry d_firmWebsite
append using ".\Data\Data_Reprisk_ESG\PreqinNames.dta"
duplicates drop
save ".\Data\Data_Reprisk_ESG\PreqinNames.dta", replace

bysort d_firmID: egen d_firstDealYear = min(d_dealYear)
keep d_firmID d_firmName d_firmCountry d_firmWebsite d_firstDealYear
duplicates drop
bysort d_firmID (d_firmName): keep if _n==_N
save ".\Data\Data_Reprisk_ESG\PreqinNames.dta", replace

local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace d_firmName = subinstr(d_firmName,"`a'","a",.)
}
foreach e of local specialEs {
	replace d_firmName = subinstr(d_firmName,"`e'","e",.)
}
foreach i of local specialIs {
	replace d_firmName = subinstr(d_firmName,"`i'","i",.)
}
foreach o of local specialOs {
	replace d_firmName = subinstr(d_firmName,"`o'","o",.)
}
foreach u of local specialUs {
	replace d_firmName = subinstr(d_firmName,"`u'","u",.)
}
foreach y of local specialYs {
	replace d_firmName = subinstr(d_firmName,"`y'","y",.)
}
replace d_firmName = subinstr(d_firmName,"ñ","n",.)
replace d_firmName = subinstr(d_firmName,"Ñ","n",.)
replace d_firmName = subinstr(d_firmName,"æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Œ","ce",.)
replace d_firmName = subinstr(d_firmName,"œ","ce",.)
replace d_firmName = subinstr(d_firmName,"Ç","c",.)
replace d_firmName = subinstr(d_firmName,"ç","c",.)
replace d_firmName = usubinstr(d_firmName,"ž","z",.)

replace d_firmName = subinstr(d_firmName,".","",.)
replace d_firmName = subinstr(d_firmName,",","",.)
replace d_firmName = subinstr(d_firmName,"-","",.)
replace d_firmName = subinstr(d_firmName,"/","",.)
replace d_firmName = subinstr(d_firmName,"'","",.)
replace d_firmName = subinstr(d_firmName,"!","",.)
replace d_firmName = subinstr(d_firmName,":","",.)
replace d_firmName = subinstr(d_firmName,";","",.)
replace d_firmName = subinstr(d_firmName,"#","",.)
replace d_firmName = subinstr(d_firmName,"*","",.)
replace d_firmName = subinstr(d_firmName,"@","",.)
replace d_firmName = subinstr(d_firmName,"_","",.)
replace d_firmName = subinstr(d_firmName,"|","",.)
replace d_firmName = subinstr(d_firmName,"$","",.)
replace d_firmName = subinstr(d_firmName,"\","",.)
replace d_firmName = subinstr(d_firmName,"+","",.)
replace d_firmName = usubinstr(d_firmName,"¿","",.)

replace d_firmName = subinstr(d_firmName,"&"," & ",.)
replace d_firmName  = subinstr(d_firmName ," AND "," & ",.)

forvalues i = 1/3 {
	replace d_firmName  = regexr(d_firmName,"BERHAD","BHD")
	replace d_firmName  = regexr(d_firmName,"PRIVATE","PVT")
	replace d_firmName  = regexr(d_firmName,"LIMITED","LTD")
	replace d_firmName  = regexr(d_firmName,"COMPANY","CO")
	replace d_firmName  = regexr(d_firmName,"INCORPORATED","INC")
	replace d_firmName  = regexr(d_firmName,"PTY","PVT")
	replace d_firmName  = regexr(d_firmName,"CORPORATION","CORP")
	replace d_firmName  = regexr(d_firmName,"CO LTD","COLTD")
	replace d_firmName  = regexr(d_firmName ,"L L C","LLC")
	replace d_firmName  = regexr(d_firmName," INTL "," INTERNATIONAL ")
	replace d_firmName  = regexr(d_firmName," COS "," CO ")
	replace d_firmName  = regexr(d_firmName," COS$"," CO$")
	replace d_firmName  = regexr(d_firmName," S A$"," SA")
	replace d_firmName  = regexr(d_firmName," S C$"," SC")
	replace d_firmName  = regexr(d_firmName," P C$"," PC")
	replace d_firmName  = regexr(d_firmName," N V$"," NV")
	replace d_firmName  = regexr(d_firmName," SA RL$"," SARL")
}

replace d_firmName  = subinstr(d_firmName ,"SERVICES","SERVICE",.)
replace d_firmName  = subinstr(d_firmName ,"SYSTEMS","SYSTEM",.)
replace d_firmName  = subinstr(d_firmName ,"HOLDINGS","HOLDING",.)
replace d_firmName  = subinstr(d_firmName ,"SOLUTIONS","SOLUTION",.)
replace d_firmName  = subinstr(d_firmName ,"PRODUCTS","PRODUCT",.)
replace d_firmName  = subinstr(d_firmName ,"PARTNERS","PARTNER",.)
replace d_firmName  = subinstr(d_firmName ,"ENTERPRISES","ENTERPRISE",.)
replace d_firmName  = subinstr(d_firmName ,"MATERIALS","MATERIAL",.)
replace d_firmName  = subinstr(d_firmName ,"METALS","METAL",.)
replace d_firmName  = subinstr(d_firmName ,"CHEMICALS","CHEMICAL",.)

replace d_firmName  = strtrim(d_firmName )
replace d_firmName  = stritrim(d_firmName )
replace d_firmName = upper(d_firmName)
duplicates drop
save ".\Data\Data_Reprisk_ESG\PreqinNames.dta", replace

use ".\Data\Data_Reprisk_ESG\PreqinNames.dta", clear
gen d_firmName_noExt = d_firmName
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^THE ","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTDA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PTY$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CORP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^OOO ","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," GMBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," MBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," SARL$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AS$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AB$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AG$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SCA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," NV$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SL$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," BV$","")
replace d_firmName_noExt  = subinstr(d_firmName_noExt ," OOO$","",.)
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"S$","")
replace d_firmName_noExt  = strtrim(d_firmName_noExt )
replace d_firmName_noExt  = stritrim(d_firmName_noExt )

gen d_firmName_noSpace = subinstr(d_firmName_noExt," ","",.)
gen d_firmName_noFreq = d_firmName_noSpace

forvalues i = 1/3 {
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INDUSTRIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"HOLDING","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"GROUP","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"PRODUCT","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INTERNATIONAL","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"TECHNOLOGIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"&","",.)	
}

save ".\Data\Data_Reprisk_ESG\PreqinNames.dta", replace

********************************************************************************
********************************MATCHING****************************************
********************************************************************************
//Exact Match - website and country
use ".\Data\Data_Reprisk_ESG\PreqinNames.dta", clear
ren (d_firmWebsite d_firmCountry) (webpage country)
drop if missing(webpage)
joinby webpage country using ".\Data\Data_Reprisk_ESG\repriskNames.dta"
keep d_firmID reprisk_id
duplicates drop
save ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta", replace

//Exact Match - name and country
keep d_firmID
duplicates drop
merge 1:m d_firmID using ".\Data\Data_Reprisk_ESG\PreqinNames.dta"
keep if _m==2
drop _m
ren (d_firmName d_firmCountry) (cleanedName country)
joinby cleanedName country using ".\Data\Data_Reprisk_ESG\repriskNames.dta"
keep d_firmID reprisk_id
duplicates drop
append using ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta"
save ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta", replace

//Exact Match - no extention name and country
keep d_firmID
duplicates drop
merge 1:m d_firmID using ".\Data\Data_Reprisk_ESG\PreqinNames.dta"
keep if _m==2
drop _m
ren (d_firmName d_firmCountry) (cleanedName_noExt country)
joinby cleanedName_noExt country using ".\Data\Data_Reprisk_ESG\repriskNames.dta"
keep d_firmID reprisk_id
duplicates drop
append using ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta"
save ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta", replace

//Control firms
keep reprisk_id
duplicates drop
merge 1:m reprisk_id using ".\Data\Data_Reprisk_ESG\repriskNames.dta"
keep if _m==2
keep reprisk_id country sector
save ".\Data\Data_Reprisk_ESG\reprisk_ctrl.dta", replace

********************************************************************************
************************PROCESSING RAW DATA*************************************
********************************************************************************
//I keep only annual data - to be aligned with TRI and Trucost
forvalues i = 2007/2022 {
	qui import delimited using ".\Data\Data_Reprisk_ESG\\`i'_20230410.txt", clear varn(1) colr(1:1)
	qui count
	local chunks = int(`r(N)'/800000)+1
	local start = 2
	local stop = 800000
	forvalues j = 1/`chunks' {
		di "`i' `j'"
		qui import delimited using ".\Data\Data_Reprisk_ESG\\`i'_20230410.txt", clear varn(1) rowr(`start':`stop') stringc(_all)
		qui destring reprisk_id current_rri, replace force
		qui gen tdate = date(date,"DMY")
		qui format tdate %td
		qui drop date
		qui ren tdate date
		qui gen year = year(date)
		if `j'==1 {
			qui save ".\Data\Data_Reprisk_ESG\reprisk_`i'.dta", replace
		}
		else {
			qui append using ".\Data\Data_Reprisk_ESG\reprisk_`i'.dta"
			qui bysort reprisk_id (date): keep if _n==_N
			qui save ".\Data\Data_Reprisk_ESG\reprisk_`i'.dta", replace
		}
		local start = `stop' + 1
		local stop = `start' + 800000 - 1
		di "`i' `chunks' `j'"
	}
}

qui  use ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta", clear
qui keep reprisk_id
qui duplicates drop
save ".\Data\Data_Reprisk_ESG\reprisk_trt.dta", replace
forvalues i = 2007/2022 {
	qui use ".\Data\Data_Reprisk_ESG\reprisk_`i'.dta", clear
	qui merge m:1 reprisk_id using ".\Data\Data_Reprisk_ESG\reprisk_ctrl.dta"
	qui keep if _m==3
	qui drop _m
	if `i'==2007 {
		qui save ".\Data\Data_Reprisk_ESG\reprisk_ctrlFirms.dta", replace
	}
	else {
		qui append using ".\Data\Data_Reprisk_ESG\reprisk_ctrlFirms.dta"
		qui save ".\Data\Data_Reprisk_ESG\reprisk_ctrlFirms.dta", replace
	}
	
	qui use ".\Data\Data_Reprisk_ESG\reprisk_`i'.dta", clear
	qui merge m:1 reprisk_id using ".\Data\Data_Reprisk_ESG\reprisk_trt.dta"
	qui keep if _m==3
	qui drop _m
	if `i'==2007 {
		qui save ".\Data\Data_Reprisk_ESG\reprisk_trtFirms.dta", replace
	}
	else {
		qui append using ".\Data\Data_Reprisk_ESG\reprisk_trtFirms.dta"
		qui save ".\Data\Data_Reprisk_ESG\reprisk_trtFirms.dta", replace
	}
	di `i'
}

********************************************************************************
************************REMOVING DUPLICATES*************************************
********************************************************************************
use ".\Data\Data_Reprisk_ESG\reprisk_trtFirms.dta", clear
keep reprisk_id
duplicates drop
merge 1:m reprisk_id using ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta"
keep if _m==3
drop _m
save ".\Data\Data_Reprisk_ESG\preqinRepriskMap_withData.dta", replace

use ".\Data\Data_Reprisk_ESG\PreqinNames.dta", clear
merge 1:m d_firmID using ".\Data\Data_Reprisk_ESG\preqinRepriskMap_withData.dta"
keep if _m==3
drop _m
merge m:1 reprisk_id using ".\Data\Data_Reprisk_ESG\repriskNames.dta"
keep if _m==3
drop _m
replace cleanedName = substr(cleanedName,1,strpos(cleanedName,"(")-1) if strpos(cleanedName,"(")
replace cleanedName = strtrim(cleanedName)
replace cleanedName = stritrim(cleanedName)

duplicates tag d_firmID, gen(tag)
ustrdist d_firmName cleanedName, gen(dist)
bysort d_firmID: egen minDist = min(dist)
drop if minDist==0 & dist!=minDist & tag!=0
drop tag

duplicates tag d_firmID, gen(tag)

drop if d_firmID==58751 & reprisk_id!=490128 & tag!=0
drop if d_firmID==28944	& reprisk_id!=16678 & tag!=0
drop if d_firmID==81232	& reprisk_id!=3445 & tag!=0
drop if d_firmID==165059 & reprisk_id!=174170 & tag!=0
drop if d_firmID==108251 & reprisk_id!=2481 & tag!=0
drop if d_firmID==326150 & reprisk_id!=125515 & tag!=0
drop if d_firmID==322575 & reprisk_id!=103105 & tag!=0
drop if d_firmID==320233 & reprisk_id!=1022 & tag!=0
drop if d_firmID==278347 & reprisk_id!=196118 & tag!=0
drop if d_firmID==247694 & reprisk_id!=2168108 & tag!=0
drop if d_firmID==237224 & reprisk_id!=1158203 & tag!=0
drop if d_firmID==223234 & reprisk_id!=1204658 & tag!=0
drop if d_firmID==176729 & reprisk_id!=205700 & tag!=0
drop if d_firmID==176724 & reprisk_id!=6180 & tag!=0
drop if d_firmID==136977 & reprisk_id!=1311174 & tag!=0
drop if d_firmID==124484 & reprisk_id!=8372 & tag!=0
drop if d_firmID==120003 & reprisk_id!=1142158 & tag!=0
drop if d_firmID==93517 & reprisk_id!=12535 & tag!=0
drop if d_firmID==57929 & reprisk_id!=24611 & tag!=0
drop if d_firmID==49869 & reprisk_id!=174610 & tag!=0
drop if d_firmID==49701 & reprisk_id!=194165 & tag!=0
drop if d_firmID==41705 & reprisk_id!=679 & tag!=0
drop if d_firmID==37564 & reprisk_id!=68359 & tag!=0
drop if d_firmID==36433 & reprisk_id!=10290 & tag!=0
drop if d_firmID==36061 & reprisk_id!=630 & tag!=0
drop if d_firmID==31237 & reprisk_id!=222933 & tag!=0
drop if d_firmID==29456 & reprisk_id!=83640 & tag!=0
drop if d_firmID==26649 & reprisk_id!=110958 & tag!=0
drop if d_firmID==26600 & reprisk_id!=33466 & tag!=0
drop if d_firmID==25597 & reprisk_id!=1293 & tag!=0
drop if d_firmID==6733 & reprisk_id!=2455767 & tag!=0
drop if d_firmID==733 & reprisk_id!=536 & tag!=0
drop if d_firmID==496002 & reprisk_id!=22376 & tag!=0
drop if d_firmID==492101 & reprisk_id!=636763 & tag!=0
drop if d_firmID==484428 & reprisk_id!=63218 & tag!=0
drop if d_firmID==427957 & reprisk_id!=11510 & tag!=0
drop if d_firmID==400460 & reprisk_id!=609510 & tag!=0
drop if d_firmID==389565 & reprisk_id!=10615 & tag!=0
drop if d_firmID==357817 & reprisk_id!=556928 & tag!=0
drop if d_firmID==350051 & reprisk_id!=564285 & tag!=0
drop if d_firmID==343459 & reprisk_id!=389055 & tag!=0
drop if d_firmID==343156 & reprisk_id!=3336 & tag!=0
drop if d_firmID==338818 & reprisk_id!=256193 & tag!=0
drop if d_firmID==329496 & reprisk_id!=1733439 & tag!=0
drop if d_firmID==329479 & reprisk_id!=111789 & tag!=0
drop if d_firmID==326507 & reprisk_id!=183059 & tag!=0
drop if d_firmID==326211 & reprisk_id!=2190553 & tag!=0
drop if d_firmID==325742 & reprisk_id!=183558 & tag!=0
drop if d_firmID==311897 & reprisk_id!=93333 & tag!=0
drop if d_firmID==309542 & reprisk_id!=385767 & tag!=0
drop if d_firmID==308644 & reprisk_id!=216963 & tag!=0
drop if d_firmID==304826 & reprisk_id!=981560 & tag!=0
drop if d_firmID==292076 & reprisk_id!=119821 & tag!=0
drop if d_firmID==288028 & reprisk_id!=11893 & tag!=0
drop if d_firmID==287281 & reprisk_id!=411210 & tag!=0
drop if d_firmID==261129 & reprisk_id!=2087979 & tag!=0
drop if d_firmID==259787 & reprisk_id!=381690 & tag!=0
drop if d_firmID==252765 & reprisk_id!=563813 & tag!=0
drop if d_firmID==250269 & reprisk_id!=1538107 & tag!=0
drop if d_firmID==243628 & reprisk_id!=64240 & tag!=0
drop if d_firmID==237973 & reprisk_id!=484037 & tag!=0
drop if d_firmID==236847 & reprisk_id!=19146 & tag!=0
drop if d_firmID==217188 & reprisk_id!=118108 & tag!=0
drop if d_firmID==212022 & reprisk_id!=298896 & tag!=0
drop if d_firmID==199692 & reprisk_id!=1186238 & tag!=0
drop if d_firmID==189407 & reprisk_id!=439199 & tag!=0
drop if d_firmID==185729 & reprisk_id!=1290104 & tag!=0
drop if d_firmID==183040 & reprisk_id!=1814152 & tag!=0
drop if d_firmID==179261 & reprisk_id!=954985 & tag!=0
drop if d_firmID==174290 & reprisk_id!=138320 & tag!=0
drop if d_firmID==170332 & reprisk_id!=522172 & tag!=0
drop if d_firmID==168638 & reprisk_id!=114490 & tag!=0
drop if d_firmID==164574 & reprisk_id!=173818 & tag!=0
drop if d_firmID==162085 & reprisk_id!=1179993 & tag!=0
drop if d_firmID==159271 & reprisk_id!=219672 & tag!=0
drop if d_firmID==157661 & reprisk_id!=2551066 & tag!=0
drop if d_firmID==156091 & reprisk_id!=252735 & tag!=0
drop if d_firmID==154347 & reprisk_id!=48590 & tag!=0
drop if d_firmID==152335 & reprisk_id!=425156 & tag!=0
drop if d_firmID==152335 & reprisk_id!=425156 & tag!=0
drop if d_firmID==143893 & reprisk_id!=76083 & tag!=0
drop if d_firmID==141497 & reprisk_id!=427007 & tag!=0
drop if d_firmID==138310 & reprisk_id!=26573 & tag!=0
drop if d_firmID==134738 & reprisk_id!=204929 & tag!=0
drop if d_firmID==133145 & reprisk_id!=2469124 & tag!=0
drop if d_firmID==130316 & reprisk_id!=64781 & tag!=0
drop if d_firmID==126556 & reprisk_id!=1327129 & tag!=0
drop if d_firmID==124476 & reprisk_id!=696528 & tag!=0
drop if d_firmID==123617 & reprisk_id!=959420 & tag!=0
drop if d_firmID==122298 & reprisk_id!=6295 & tag!=0
drop if d_firmID==117784 & reprisk_id!=64273 & tag!=0
drop if d_firmID==116219 & reprisk_id!=2520295 & tag!=0
drop if d_firmID==115492 & reprisk_id!=109877 & tag!=0
drop if d_firmID==115476 & reprisk_id!=226231 & tag!=0
drop if d_firmID==114730 & reprisk_id!=1116143 & tag!=0
drop if d_firmID==107955 & reprisk_id!=197602 & tag!=0
drop if d_firmID==102551 & reprisk_id!=5554 & tag!=0
drop if d_firmID==100734 & reprisk_id!=181126 & tag!=0
drop if d_firmID==100467 & reprisk_id!=62033 & tag!=0
drop if d_firmID==93447 & reprisk_id!=9806 & tag!=0
drop if d_firmID==82897 & reprisk_id!=167525 & tag!=0
drop if d_firmID==74930 & reprisk_id!=520592 & tag!=0
drop if d_firmID==68373 & reprisk_id!=19382 & tag!=0
drop if d_firmID==67352 & reprisk_id!=155967 & tag!=0
drop if d_firmID==65321 & reprisk_id!=2558931 & tag!=0
drop if d_firmID==64569 & reprisk_id!=96542 & tag!=0
drop if d_firmID==59270 & reprisk_id!=24331 & tag!=0
drop if d_firmID==58411 & reprisk_id!=1156038 & tag!=0
drop if d_firmID==56615 & reprisk_id!=109041 & tag!=0
drop if d_firmID==55966 & reprisk_id!=70732 & tag!=0
drop if d_firmID==55556 & reprisk_id!=890493 & tag!=0
drop if d_firmID==54907 & reprisk_id!=1346774 & tag!=0
drop if d_firmID==53985 & reprisk_id!=169798 & tag!=0
drop if d_firmID==52883 & reprisk_id!=13274 & tag!=0
drop if d_firmID==51435 & reprisk_id!=11659 & tag!=0
drop if d_firmID==49053 & reprisk_id!=2425567 & tag!=0
drop if d_firmID==48074 & reprisk_id!=407602 & tag!=0
drop if d_firmID==47166 & reprisk_id!=115900 & tag!=0
drop if d_firmID==46587 & reprisk_id!=1120128 & tag!=0
drop if d_firmID==45447 & reprisk_id!=502663 & tag!=0
drop if d_firmID==45422 & reprisk_id!=9730 & tag!=0
drop if d_firmID==45002 & reprisk_id!=73496 & tag!=0
drop if d_firmID==44688 & reprisk_id!=249489 & tag!=0
drop if d_firmID==44308 & reprisk_id!=184043 & tag!=0
drop if d_firmID==40881 & reprisk_id!=15305 & tag!=0
drop if d_firmID==39800 & reprisk_id!=291504 & tag!=0
drop if d_firmID==39589 & reprisk_id!=287856 & tag!=0
drop if d_firmID==39013 & reprisk_id!=7642 & tag!=0
drop if d_firmID==38926 & reprisk_id!=1227353 & tag!=0
drop if d_firmID==38913 & reprisk_id!=744938 & tag!=0
drop if d_firmID==38751 & reprisk_id!=76335 & tag!=0
drop if d_firmID==38527 & reprisk_id!=256029 & tag!=0
drop if d_firmID==38137 & reprisk_id!=87805 & tag!=0
drop if d_firmID==38136 & reprisk_id!=6577 & tag!=0
drop if d_firmID==37979 & reprisk_id!=2162913 & tag!=0
drop if d_firmID==37801 & reprisk_id!=123962 & tag!=0
drop if d_firmID==37370 & reprisk_id!=103420 & tag!=0
drop if d_firmID==37249 & reprisk_id!=760128 & tag!=0
drop if d_firmID==36835 & reprisk_id!=1119813 & tag!=0
drop if d_firmID==36550 & reprisk_id!=33620 & tag!=0
drop if d_firmID==34980 & reprisk_id!=116514 & tag!=0
drop if d_firmID==34465 & reprisk_id!=206308 & tag!=0
drop if d_firmID==33864 & reprisk_id!=207395 & tag!=0
drop if d_firmID==33783 & reprisk_id!=177419 & tag!=0
drop if d_firmID==33651 & reprisk_id!=13222 & tag!=0
drop if d_firmID==33480 & reprisk_id!=19775 & tag!=0
drop if d_firmID==32571 & reprisk_id!=106395 & tag!=0
drop if d_firmID==31679 & reprisk_id!=9340 & tag!=0
drop if d_firmID==31635 & reprisk_id!=3827 & tag!=0
drop if d_firmID==30927 & reprisk_id!=194434 & tag!=0
drop if d_firmID==30472 & reprisk_id!=8579 & tag!=0
drop if d_firmID==29968 & reprisk_id!=67628 & tag!=0
drop if d_firmID==29693 & reprisk_id!=116718 & tag!=0
drop if d_firmID==28706 & reprisk_id!=325201 & tag!=0
drop if d_firmID==28645 & reprisk_id!=8611 & tag!=0
drop if d_firmID==28505 & reprisk_id!=76182 & tag!=0
drop if d_firmID==28023 & reprisk_id!=103463 & tag!=0
drop if d_firmID==27089 & reprisk_id!=612032 & tag!=0
drop if d_firmID==26844 & reprisk_id!=2501217 & tag!=0
drop if d_firmID==26782 & reprisk_id!=25245 & tag!=0
drop if d_firmID==26617 & reprisk_id!=178360 & tag!=0
drop if d_firmID==26235 & reprisk_id!=184437 & tag!=0
drop if d_firmID==26113 & reprisk_id!=1684502 & tag!=0

drop tag
duplicates tag d_firmID, gen(tag)
drop if tag!=0
keep d_firmID reprisk_id d_firstDealYear country
joinby reprisk_id using ".\Data\Data_Reprisk_ESG\reprisk_trtFirms.dta"
append using ".\Data\Data_Reprisk_ESG\reprisk_ctrlFirms.dta"
keep d_firmID reprisk_id current_rri reprisk_rating year d_firstDealYear country

gen postPeriod = cond(year>=d_firstDealYear,1,0)
gen dist_to_deal = year - d_firstDealYear
encode reprisk_rating, gen(rating)
drop reprisk_rating
egen double countryYear = group(country year)
order d_firmID reprisk_id country d_firstDealYear year current_rri rating postPeriod dist_to_deal countryYear

label var current_rri "Reprisk Index"
label var rating "Reprisk Rating"

sort d_firmID year
save ".\Data\Data_Reprisk_ESG\reprisk.dta", replace

erase ".\Data\Data_Reprisk_ESG\PreqinNames.dta"
erase ".\Data\Data_Reprisk_ESG\preqinRepriskMap.dta"
erase ".\Data\Data_Reprisk_ESG\preqinRepriskMap_withData.dta"
erase ".\Data\Data_Reprisk_ESG\reprisk_ctrl.dta"
erase ".\Data\Data_Reprisk_ESG\reprisk_ctrlFirms.dta"
erase ".\Data\Data_Reprisk_ESG\reprisk_trt.dta"
erase ".\Data\Data_Reprisk_ESG\reprisk_trtFirms.dta"
erase ".\Data\Data_Reprisk_ESG\repriskNames.dta"
forvalues i = 2007/2022 {
	erase ".\Data\Data_Reprisk_ESG\reprisk_`i'.dta"
}

log closelog using "logfile_TRI", replace

set more off
clear all

**Basic Plus
{
//File Type 1A
{
forvalues yr = 2000/2021 {
	qui filefilter ".\Data\Data_TRI\Basic Plus\US_1a_`yr'.txt" ".\US_1a.txt", from(\Q) to(') replace
    qui import delimited ".\US_1a.txt", clear bindq(strict) maxquotedrows(unlimited) stringc(_all) delim(tab)
	qui destring reportingyear, replace
	if `yr'==2000 {
	    qui save ".\Data\Data_TRI\fileType1a.dta", replace
	}
	else {
	    qui append using ".\Data\Data_TRI\fileType1a.dta"
		qui save ".\Data\Data_TRI\fileType1a.dta", replace
		di `yr'
	}
}
qui erase ".\US_1a.txt"
}
//File Type 4
{
forvalues yr = 2000/2021 {
    qui import delimited ".\Data\Data_TRI\Basic Plus\US_4_`yr'.txt", clear bindq(strict) maxquotedrows(unlimited) stringc(_all)
	qui drop v90 v91
	if `yr'==2000 {
	    qui save ".\Data\Data_TRI\fileType4.dta", replace
	}
	else {
	    qui append using ".\Data\Data_TRI\fileType4.dta"
		qui save ".\Data\Data_TRI\fileType4.dta", replace
		di `yr'
	}
}
use ".\Data\Data_TRI\fileType4.dta", clear
ren eparegistryid frsfacilityid
destring reportingyear, replace
save ".\Data\Data_TRI\fileType4.dta", replace
}
//Vintage File Type 4
{
local vintages: dir ".\Data\Data_TRI\Vintage files" file "*.txt", respectcase
local i = 1
foreach v of local vintages {
	if "`v'"!="readme.txt" {
		di "`v'"
		if substr("`v'",1,2)=="US" {
			local yr = substr("`v'",6,4)
		}
		else {
			local yr = substr("`v'",7,4)
		}
		qui import delimited using ".\Data\Data_TRI\Vintage files//`v'", clear bindq(strict) maxquotedrows(unlimited) stringc(_all)
		qui drop if reportingyear!="`yr'"
		qui destring reportingyear, replace
		qui capture confirm var trifid
		if _rc==0 {
			qui ren trifid trifd
		}
		qui bysort trifd (reportingyear): keep if _n==_N
		if `i'==1 {
			qui save ".\Data\Data_TRI\fileType4_vintage.dta", replace
			local ++i
		}
		else {
			qui append using ".\Data\Data_TRI\fileType4_vintage.dta"
			qui save ".\Data\Data_TRI\fileType4_vintage.dta", replace
		}
	}
}
use ".\Data\Data_TRI\fileType4_vintage.dta", clear
keep trifd reportingyear parentcompanyname standardizedparentcompanyname
order trifd reportingyear parentcompanyname standardizedparentcompanyname
drop if missing(trifd)
dropmiss parentcompanyname standardizedparentcompanyname, obs force
duplicates drop
sort trifd reportingyear
save ".\Data\Data_TRI\fileType4_vintage.dta", replace

use ".\Data\Data_TRI\fileType4.dta", clear
keep trifd
duplicates drop
merge 1:m trifd using ".\Data\Data_TRI\fileType4_vintage.dta"
keep if _m==3
drop _m
sort trifd reportingyear
save ".\Data\Data_TRI\fileType4_vintage.dta", replace
}
//Mapping to Preqin 
{
use ".\Data\Data_TRI\fileType1a.dta", clear
keep trifd reportingyear
duplicates drop
merge 1:1 trifd reportingyear using ".\Data\Data_TRI\fileType4.dta"
keep if _m==3
keep trifd reportingyear submittedfacilityname parentcompanyname standardizedparentcompanyname submittedparentcompanyname submittedstandardizedparentcompa city county state submittedindustrycode submittedindustryname
order trifd reportingyear submittedfacilityname parentcompanyname standardizedparentcompanyname submittedparentcompanyname submittedstandardizedparentcompa city county state submittedindustrycode submittedindustryname
replace submittedindustryname = upper(submittedindustryname)
dropmiss submittedfacilityname parentcompanyname standardizedparentcompanyname submittedparentcompanyname submittedstandardizedparentcompa, force obs
foreach var of varlist submittedfacilityname parentcompanyname standardizedparentcompanyname submittedparentcompanyname submittedstandardizedparentcompa {
    replace `var' = "" if `var'=="NA"
}
ren (submittedfacilityname parentcompanyname standardizedparentcompanyname submittedparentcompanyname submittedstandardizedparentcompa) ///
	(subFacilityName firmName stdFirmName subfirmName subStdFirmName)
save ".\Data\Data_TRI\TRINames.dta", replace

use ".\Data\Data_TRI\fileType4_vintage.dta", clear
ren (parentcompanyname standardizedparentcompanyname) (vintageName vintageStdName)
foreach var of varlist vintageName vintageStdName {
	replace `var' = "" if `var'=="NA"
}
merge 1:1 trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
drop if _m==1
keep trifd reportingyear subFacilityName firmName stdFirmName subfirmName subStdFirmName vintageName vintageStdName city county state
order trifd reportingyear subFacilityName firmName stdFirmName subfirmName subStdFirmName vintageName vintageStdName city county state

local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach var of varlist subFacilityName firmName stdFirmName subfirmName subStdFirmName vintageName vintageStdName {
	foreach a of local specialAs {
		replace `var' = subinstr(`var',"`a'","a",.)
	}
	foreach e of local specialEs {
		replace `var' = subinstr(`var',"`e'","e",.)
	}
	foreach i of local specialIs {
		replace `var' = subinstr(`var',"`i'","i",.)
	}
	foreach o of local specialOs {
		replace `var' = subinstr(`var',"`o'","o",.)
	}
	foreach u of local specialUs {
		replace `var' = subinstr(`var',"`u'","u",.)
	}
	foreach y of local specialYs {
		replace `var' = subinstr(`var',"`y'","y",.)
	}
	replace `var' = subinstr(`var',"ñ","n",.)
	replace `var' = subinstr(`var',"Ñ","n",.)
	replace `var' = subinstr(`var',"æ","ae",.)
	replace `var' = subinstr(`var',"Æ","ae",.)
	replace `var' = subinstr(`var',"Œ","ce",.)
	replace `var' = subinstr(`var',"œ","ce",.)
	replace `var' = subinstr(`var',"Ç","c",.)
	replace `var' = subinstr(`var',"ç","c",.)
	replace `var' = usubinstr(`var',"ž","z",.)

	replace `var' = subinstr(`var',".","",.)
	replace `var' = subinstr(`var',",","",.)
	replace `var' = subinstr(`var',"-","",.)
	replace `var' = subinstr(`var',"/","",.)
	replace `var' = subinstr(`var',"'","",.)
	replace `var' = subinstr(`var',"!","",.)
	replace `var' = subinstr(`var',":","",.)
	replace `var' = subinstr(`var',";","",.)
	replace `var' = subinstr(`var',"#","",.)
	replace `var' = subinstr(`var',"*","",.)
	replace `var' = subinstr(`var',"@","",.)
	replace `var' = subinstr(`var',"_","",.)
	replace `var' = subinstr(`var',"|","",.)
	replace `var' = subinstr(`var',"$","",.)
	replace `var' = subinstr(`var',"\","",.)
	replace `var' = subinstr(`var',"+","",.)
	replace `var' = usubinstr(`var',"¿","",.)

	replace `var' = subinstr(`var',"&"," & ",.)
	replace `var'  = subinstr(`var' ," AND "," & ",.)

	forvalues i = 1/3 {
		replace `var'  = regexr(`var',"PRIVATE","PVT")
		replace `var'  = regexr(`var',"LIMITED","LTD")
		replace `var'  = regexr(`var',"COMPANY","CO")
		replace `var'  = regexr(`var',"INCORPORATED","INC")
		replace `var'  = regexr(`var',"PTY","PVT")
		replace `var'  = regexr(`var',"CORPORATION","CORP")
		replace `var'  = regexr(`var' ,"L L C","LLC")
		replace `var'  = regexr(`var'," INTL "," INTERNATIONAL ")
		replace `var'  = regexr(`var'," COS "," CO ")
		replace `var'  = regexr(`var'," COS$"," CO$")
		replace `var'  = regexr(`var'," S A$"," SA")
		replace `var'  = regexr(`var'," S C$"," SC")
		replace `var'  = regexr(`var'," P C$"," PC")
		replace `var'  = regexr(`var'," N V$"," NV")
		replace `var'  = regexr(`var'," SA RL$"," SARL")
	}

	replace `var'  = subinstr(`var' ,"SERVICES","SERVICE",.)
	replace `var'  = subinstr(`var' ,"SYSTEMS","SYSTEM",.)
	replace `var'  = subinstr(`var' ,"HOLDINGS","HOLDING",.)
	replace `var'  = subinstr(`var' ,"SOLUTIONS","SOLUTION",.)
	replace `var'  = subinstr(`var' ,"PRODUCTS","PRODUCT",.)
	replace `var'  = subinstr(`var' ,"PARTNERS","PARTNER",.)
	replace `var'  = subinstr(`var' ,"ENTERPRISES","ENTERPRISE",.)
	replace `var'  = subinstr(`var' ,"MATERIALS","MATERIAL",.)
	replace `var'  = subinstr(`var' ,"METALS","METAL",.)
	replace `var'  = subinstr(`var' ,"CHEMICALS","CHEMICAL",.)

	replace `var'  = strtrim(`var' )
	replace `var'  = stritrim(`var' )
	replace `var' = upper(`var')
	duplicates drop
}
save ".\Data\Data_TRI\TRINames.dta", replace

foreach var of varlist subFacilityName firmName stdFirmName subfirmName subStdFirmName vintageName vintageStdName {
	gen `var'_noExt = `var'
	
	forvalues i = 1/3 {
		replace `var'_noExt  = regexr(`var'_noExt ,"^THE ","")
		replace `var'_noExt  = regexr(`var'_noExt ," CO$","")
		replace `var'_noExt  = regexr(`var'_noExt ," PVT LTD$","")
		replace `var'_noExt  = regexr(`var'_noExt ," CO LTD$","")
		replace `var'_noExt  = regexr(`var'_noExt ," LTD$","")
		replace `var'_noExt  = regexr(`var'_noExt ," LTD$","")
		replace `var'_noExt  = regexr(`var'_noExt ," LTDA$","")
		replace `var'_noExt  = regexr(`var'_noExt ," LLC$","")
		replace `var'_noExt  = regexr(`var'_noExt ," LLP$","")
		replace `var'_noExt  = regexr(`var'_noExt ," INC$","")
		replace `var'_noExt  = regexr(`var'_noExt ," PVT$","")
		replace `var'_noExt  = regexr(`var'_noExt ," PTY$","")
		replace `var'_noExt  = regexr(`var'_noExt ," PLC$","")
		replace `var'_noExt  = regexr(`var'_noExt ," INC$","")
		replace `var'_noExt  = regexr(`var'_noExt ," CORP$","")
		replace `var'_noExt  = regexr(`var'_noExt ," LP$","")
		replace `var'_noExt  = regexr(`var'_noExt ," SA$","")
		replace `var'_noExt  = regexr(`var'_noExt ,"^OOO ","")
		replace `var'_noExt  =   regexr(`var'_noExt ," GMBH$","")
		replace `var'_noExt  =   regexr(`var'_noExt ," MBH$","")
		replace `var'_noExt  =   regexr(`var'_noExt ," SARL$","")
		replace `var'_noExt  =   regexr(`var'_noExt ," AS$","")
		replace `var'_noExt  =   regexr(`var'_noExt ," AB$","")
		replace `var'_noExt  =   regexr(`var'_noExt ," AG$","")
		replace `var'_noExt  = regexr(`var'_noExt ," SCA$","")
		replace `var'_noExt  = regexr(`var'_noExt ," SA$","")
		replace `var'_noExt  = regexr(`var'_noExt ," SC$","")
		replace `var'_noExt  = regexr(`var'_noExt ," PC$","")
		replace `var'_noExt  = regexr(`var'_noExt ," NV$","")
		replace `var'_noExt  = regexr(`var'_noExt ," SL$","")
		replace `var'_noExt  = regexr(`var'_noExt ," BV$","")
		replace `var'_noExt  = subinstr(`var'_noExt ," OOO$","",.)
		replace `var'_noExt  = regexr(`var'_noExt ,"S$","")
		replace `var'_noExt  = strtrim(`var'_noExt )
		replace `var'_noExt  = stritrim(`var'_noExt )
	}
	gen `var'_noSpace = subinstr(`var'_noExt," ","",.)
	gen `var'_noFreq = `var'_noSpace
	
	forvalues i = 1/3 {
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"INDUSTRIES","",.)
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"HOLDING","",.)
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"GROUP","",.)
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"PRODUCT","",.)
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"INTERNATIONAL","",.)
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"TECHNOLOGIES","",.)
		replace `var'_noFreq  = subinstr(`var'_noFreq ,"&","",.)	
		}
}
 
save ".\Data\Data_TRI\TRINames.dta", replace
save ".\Data\Data_TRI\TRINamesFull.dta", replace

//Deal data
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep if d_firmCountry=="UNITED STATES"
keep d_firmID d_firmName d_dealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry
duplicates drop
save ".\Data\Data_TRI\PreqinNames.dta", replace

use ".\Data\Data_preqin\preqin_dealsVC.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep if d_firmCountry=="UNITED STATES"
keep d_firmID d_firmName d_dealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry
append using ".\Data\Data_TRI\PreqinNames.dta"
duplicates drop
save ".\Data\Data_TRI\PreqinNames.dta", replace

bysort d_firmID: egen d_firstDealYear = min(d_dealYear)
duplicates drop
bysort d_firmID (d_firmName): keep if _n==_N
save ".\Data\Data_TRI\PreqinNames.dta", replace

keep d_firmID d_firmName d_dealYear d_firstDealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry
duplicates drop
save ".\Data\Data_TRI\PreqinNames.dta", replace

keep d_firmID d_firmName d_firstDealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry
duplicates drop
gen reportingyearf = 2000
gen reportingyearl = 2021
reshape long reportingyear, i(d_firmID d_firmName d_firstDealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry) j(j) str
drop j
tsset d_firmID reportingyear
tsfill
bysort d_firmID (reportingyear): carryforward d_firmName d_firstDealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry, replace
ren reportingyear d_dealYear
merge 1:1 d_firmID d_dealYear d_firmName d_firstDealYear d_firmWebsite d_firmCity d_firmStateCounty d_firmPrimaryIndustry using ".\Data\Data_TRI\PreqinNames.dta"
drop if _m==2
gen d_dealDummy = cond(_m==3,1,0)
drop _m
ren d_dealYear reportingyear
bysort d_firmID: egen maxDeal = max(d_dealDummy)
drop if maxDeal==0
drop maxDeal
save ".\Data\Data_TRI\PreqinNames.dta", replace

//Post-period construction
gen postPeriod = cond(reportingyear>=d_firstDealYear,1,0)
gen dist_to_deal = reportingyear-d_firstDealYear

local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace d_firmName = subinstr(d_firmName,"`a'","a",.)
}
foreach e of local specialEs {
	replace d_firmName = subinstr(d_firmName,"`e'","e",.)
}
foreach i of local specialIs {
	replace d_firmName = subinstr(d_firmName,"`i'","i",.)
}
foreach o of local specialOs {
	replace d_firmName = subinstr(d_firmName,"`o'","o",.)
}
foreach u of local specialUs {
	replace d_firmName = subinstr(d_firmName,"`u'","u",.)
}
foreach y of local specialYs {
	replace d_firmName = subinstr(d_firmName,"`y'","y",.)
}
replace d_firmName = subinstr(d_firmName,"ñ","n",.)
replace d_firmName = subinstr(d_firmName,"Ñ","n",.)
replace d_firmName = subinstr(d_firmName,"æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Œ","ce",.)
replace d_firmName = subinstr(d_firmName,"œ","ce",.)
replace d_firmName = subinstr(d_firmName,"Ç","c",.)
replace d_firmName = subinstr(d_firmName,"ç","c",.)
replace d_firmName = usubinstr(d_firmName,"ž","z",.)

replace d_firmName = subinstr(d_firmName,".","",.)
replace d_firmName = subinstr(d_firmName,",","",.)
replace d_firmName = subinstr(d_firmName,"-","",.)
replace d_firmName = subinstr(d_firmName,"/","",.)
replace d_firmName = subinstr(d_firmName,"'","",.)
replace d_firmName = subinstr(d_firmName,"!","",.)
replace d_firmName = subinstr(d_firmName,":","",.)
replace d_firmName = subinstr(d_firmName,";","",.)
replace d_firmName = subinstr(d_firmName,"#","",.)
replace d_firmName = subinstr(d_firmName,"*","",.)
replace d_firmName = subinstr(d_firmName,"@","",.)
replace d_firmName = subinstr(d_firmName,"_","",.)
replace d_firmName = subinstr(d_firmName,"|","",.)
replace d_firmName = subinstr(d_firmName,"$","",.)
replace d_firmName = subinstr(d_firmName,"\","",.)
replace d_firmName = subinstr(d_firmName,"+","",.)
replace d_firmName = usubinstr(d_firmName,"¿","",.)

replace d_firmName = subinstr(d_firmName,"&"," & ",.)
replace d_firmName  = subinstr(d_firmName ," AND "," & ",.)

forvalues i = 1/3 {
	replace d_firmName  = regexr(d_firmName,"PRIVATE","PVT")
	replace d_firmName  = regexr(d_firmName,"LIMITED","LTD")
	replace d_firmName  = regexr(d_firmName,"COMPANY","CO")
	replace d_firmName  = regexr(d_firmName,"INCORPORATED","INC")
	replace d_firmName  = regexr(d_firmName,"PTY","PVT")
	replace d_firmName  = regexr(d_firmName,"CORPORATION","CORP")
	replace d_firmName  = regexr(d_firmName ,"L L C","LLC")
	replace d_firmName  = regexr(d_firmName," INTL "," INTERNATIONAL ")
	replace d_firmName  = regexr(d_firmName," COS "," CO ")
	replace d_firmName  = regexr(d_firmName," COS$"," CO$")
	replace d_firmName  = regexr(d_firmName," S A$"," SA")
	replace d_firmName  = regexr(d_firmName," S C$"," SC")
	replace d_firmName  = regexr(d_firmName," P C$"," PC")
	replace d_firmName  = regexr(d_firmName," N V$"," NV")
	replace d_firmName  = regexr(d_firmName," SA RL$"," SARL")
}

replace d_firmName  = subinstr(d_firmName ,"SERVICES","SERVICE",.)
replace d_firmName  = subinstr(d_firmName ,"SYSTEMS","SYSTEM",.)
replace d_firmName  = subinstr(d_firmName ,"HOLDINGS","HOLDING",.)
replace d_firmName  = subinstr(d_firmName ,"SOLUTIONS","SOLUTION",.)
replace d_firmName  = subinstr(d_firmName ,"PRODUCTS","PRODUCT",.)
replace d_firmName  = subinstr(d_firmName ,"PARTNERS","PARTNER",.)
replace d_firmName  = subinstr(d_firmName ,"ENTERPRISES","ENTERPRISE",.)
replace d_firmName  = subinstr(d_firmName ,"MATERIALS","MATERIAL",.)
replace d_firmName  = subinstr(d_firmName ,"METALS","METAL",.)
replace d_firmName  = subinstr(d_firmName ,"CHEMICALS","CHEMICAL",.)

replace d_firmName  = strtrim(d_firmName )
replace d_firmName  = stritrim(d_firmName )
replace d_firmName = upper(d_firmName)
duplicates drop
save ".\Data\Data_TRI\PreqinNames.dta", replace

use ".\Data\Data_TRI\PreqinNames.dta", clear
gen d_firmName_noExt = d_firmName
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^THE ","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTDA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PTY$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CORP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^OOO ","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," GMBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," MBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," SARL$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AS$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AB$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AG$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SCA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," NV$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SL$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," BV$","")
replace d_firmName_noExt  = subinstr(d_firmName_noExt ," OOO$","",.)
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"S$","")
replace d_firmName_noExt  = strtrim(d_firmName_noExt )
replace d_firmName_noExt  = stritrim(d_firmName_noExt )

gen d_firmName_noSpace = subinstr(d_firmName_noExt," ","",.)
gen d_firmName_noFreq = d_firmName_noSpace

forvalues i = 1/3 {
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INDUSTRIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"HOLDING","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"GROUP","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"PRODUCT","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INTERNATIONAL","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"TECHNOLOGIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"&","",.)	
}

save ".\Data\Data_TRI\PreqinNames.dta", replace

****ON SUBMITTED NAME OF PARENT****
//Exact Match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (subfirmName)
joinby subfirmName reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
order d_firmID trifd reportingyear
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//No Extensions match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName_noExt) (subfirmName_noExt)
joinby subfirmName_noExt reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName_noSpace) (subfirmName_noSpace)
joinby subfirmName_noSpace reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

****ON SUBMITTED STANDARDIZED NAME OF PARENT****
//Exact Match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (subStdFirmName)
joinby subStdFirmName reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//No Extensions match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName_noExt) (subStdFirmName_noExt)
joinby subStdFirmName_noExt reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName_noSpace) (subStdFirmName_noSpace)
joinby subStdFirmName_noSpace reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

****USING THE vintage name of parent****
//Exact name match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (vintageName)
joinby vintageName reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing extensions
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (vintageName_noExt)
joinby vintageName_noExt reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (vintageName_noSpace)
joinby vintageName_noSpace reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

***On VINTAGE STANDARD Name of parent
//Exact name match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (vintageStdName)
joinby vintageStdName reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing extensions
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (vintageStdName_noExt)
joinby vintageStdName_noExt reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (vintageStdName_noSpace)
joinby vintageStdName_noSpace reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

****ON PARENT NAME for the last year****
use ".\Data\Data_TRI\TRINamesFull.dta", clear
bysort trifd (reportingyear): keep if _n==_N
keep if reportingyear==2021 | reportingyear<=2019 //I leave the 2019-2020 range to make sure that we avoid instances these years are missing due to records yet to be updated
keep trifd reportingyear firmName stdFirmName firmName_noExt firmName_noSpace firmName_noFreq stdFirmName_noExt stdFirmName_noSpace stdFirmName_noFreq
save temp.dta, replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
keep trifd reportingyear
duplicates drop
merge 1:1 trifd reportingyear using temp.dta
keep if _m==2
drop _m
save temp.dta, replace

//Exact name match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (firmName)
joinby firmName reportingyear using temp.dta
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing extensions
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (firmName_noExt)
joinby firmName_noExt reportingyear using temp.dta
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (firmName_noSpace)
joinby firmName_noSpace reportingyear using temp.dta
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

****ON STANDARDIZED PARENT NAME for the last year****
//Exact name match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (stdFirmName)
joinby stdFirmName reportingyear using temp.dta
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing extensions
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (stdFirmName_noExt)
joinby stdFirmName_noExt reportingyear using temp.dta
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (stdFirmName_noSpace)
joinby stdFirmName_noSpace reportingyear using temp.dta
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

***On SUBMITTED FACILITY NAME
//Exact name match
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (subFacilityName)
joinby subFacilityName reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing extensions
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (subFacilityName_noExt)
joinby subFacilityName_noExt reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

//Removing spaces
use ".\Data\Data_TRI\PreqinNames.dta", clear
ren (d_firmName) (subFacilityName_noSpace)
joinby subFacilityName_noSpace reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

****DOING PYTHON fuzzy match
use ".\Data\Data_TRI\TRINames.dta", clear
keep trifd reportingyear subFacilityName_noSpace subfirmName_noSpace subStdFirmName_noSpace vintageName_noSpace vintageStdName_noSpace
dropmiss subFacilityName_noSpace subfirmName_noSpace subStdFirmName_noSpace vintageName_noSpace vintageStdName_noSpace, obs force
save "./Data/Data_TRI/tempTRINames.dta", replace

use ".\Data\Data_TRI\PreqinNames.dta", clear
keep d_firmID d_firmName_noSpace
duplicates drop
save "./Data/Data_TRI/tempPreqinNames.dta", replace

*Run the python code named code_TRI_name_matching.py at this point

import delimited using ".\Data\Data_TRI\name_matched\stdMatched.txt", clear
keep if matchedscore>=97
drop if matchedscore==.
keep trifd substdfirmname_nospace d_firmid
ren (substdfirmname_nospace d_firmid) (subStdFirmName_noSpace d_firmID)
merge 1:m trifd subStdFirmName_noSpace using ".\Data\Data_TRI\TRINames.dta"
keep if _m==3
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

import delimited using ".\Data\Data_TRI\name_matched\vinMatched.txt", clear
keep if matchedscore>=97
drop if matchedscore==.
keep trifd vintagename_nospace d_firmid
ren (vintagename_nospace d_firmid) (vintageName_noSpace d_firmID)
merge 1:m trifd vintageName_noSpace using ".\Data\Data_TRI\TRINames.dta"
keep if _m==3
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

import delimited using ".\Data\Data_TRI\name_matched\vinStdMatched.txt", clear
keep if matchedscore>=97
drop if matchedscore==.
keep trifd vintagestdname_nospace d_firmid
ren (vintagestdname_nospace d_firmid) (vintageStdName_noSpace d_firmID)
merge 1:m trifd vintageStdName_noSpace using ".\Data\Data_TRI\TRINames.dta"
keep if _m==3
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

import delimited using ".\Data\Data_TRI\name_matched\subMatched.txt", clear
keep if matchedscore>=97
drop if matchedscore==.
keep trifd subfirmname_nospace d_firmid
ren (subfirmname_nospace d_firmid) (subfirmName_noSpace d_firmID)
merge 1:m trifd subfirmName_noSpace using ".\Data\Data_TRI\TRINames.dta"
keep if _m==3
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\TRINames.dta"
keep if _m==2
drop _m
save ".\Data\Data_TRI\TRINames.dta", replace

import delimited using ".\Data\Data_TRI\name_matched\FacMatched.txt", clear
keep if matchedscore>=97
drop if matchedscore==.
keep trifd subfacilityname_nospace d_firmid
ren (subfacilityname_nospace d_firmid) (subFacilityName_noSpace d_firmID)
duplicates tag trifd subFacilityName_noSpace, gen(tag)
drop if tag!=0
drop tag
merge 1:m trifd subFacilityName_noSpace using ".\Data\Data_TRI\TRINames.dta"
keep if _m==3
keep d_firmID trifd reportingyear
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

//In case there is no change in the mapped firm forward and backward then I use that to fill up missing years
use ".\Data\Data_TRI\preqinTRIMap.dta", clear
keep trifd reportingyear
duplicates drop
egen double id = group(trifd)
tsset id reportingyear
tsfill
bysort id (reportingyear): carryforward trifd, replace
drop id
merge 1:m trifd reportingyear using ".\Data\Data_TRI\preqinTRIMap.dta"

gen fwd = d_firmID
gen bwd = d_firmID
bysort trifd (reportingyear d_firmID): carryforward fwd, replace
gsort trifd -reportingyear d_firmID
by trifd: carryforward bwd, replace
replace d_firmID = fwd if fwd==bwd & missing(d_firmID)
drop fwd bwd _m
drop if missing(d_firmID)
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

keep trifd
duplicates drop
merge 1:m trifd using ".\Data\Data_TRI\fileType1a.dta"
keep if _m==3
drop _m
keep trifd reportingyear
duplicates drop
merge 1:m trifd reportingyear using ".\Data\Data_TRI\preqinTRIMap.dta"
drop if _m==2
drop _m
sort trifd reportingyear d_firmID
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\TRINamesFull.dta", clear
keep trifd reportingyear firmName stdFirmName subFacilityName subfirmName subStdFirmName vintageName vintageStdName
merge 1:m trifd reportingyear using ".\Data\Data_TRI\preqinTRIMap.dta"
drop if _m==1
drop _m
order trifd reportingyear d_firmID firmName stdFirmName subFacilityName subfirmName subStdFirmName vintageName vintageStdName
sort trifd reportingyear
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

//Finally, if the submitted firm name OR the submitted standard firm name has not changed from the previous year then I carry along the d_firmID if it is missing.
use ".\Data\Data_TRI\preqinTRIMap.dta", clear
duplicates tag trifd reportingyear, gen(tag)
bysort trifd: egen maxtag = max(tag)
drop if maxtag!=0
drop tag maxtag
save temp.dta, replace
forvalues i = 1/25 {
	bysort trifd (reportingyear): gen ID = d_firmID[_n-1] if d_firmID==. & d_firmID[_n-1]!=. & ((subfirmName==subfirmName[_n-1] & subfirmName!="")|(subStdFirmName==subStdFirmName[_n-1] & subStdFirmName!=""))
	replace d_firmID = ID if ID!=.
	drop ID
}
save temp.dta, replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
duplicates tag trifd reportingyear, gen(tag)
bysort trifd: egen maxtag = max(tag)
keep if maxtag!=0
drop tag maxtag
append using temp.dta
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

//I also do the following year (like the previous year)
use ".\Data\Data_TRI\preqinTRIMap.dta", clear
duplicates tag trifd reportingyear, gen(tag)
bysort trifd: egen maxtag = max(tag)
drop if maxtag!=0
drop tag maxtag
save temp.dta, replace
forvalues i = 1/25 {
	bysort trifd (reportingyear): replace d_firmID = d_firmID[_n+1] if d_firmID==. & d_firmID[_n+1]!=. & ((subfirmName==subfirmName[_n+1] & subfirmName!="")|(subStdFirmName==subStdFirmName[_n+1] & subStdFirmName!=""))
}
save temp.dta, replace

use ".\Data\Data_TRI\preqinTRIMap.dta", clear
duplicates tag trifd reportingyear, gen(tag)
bysort trifd: egen maxtag = max(tag)
keep if maxtag!=0
drop tag maxtag
append using temp.dta
sort trifd reportingyear
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\name_matched\manually_matched.dta", clear
keep trifd d_firmID subFacilityName subfirmName subStdFirmName vintageName vintageStdName
merge 1:m trifd subFacilityName subfirmName subStdFirmName vintageName vintageStdName using ".\Data\Data_TRI\TRINamesFull.dta"
keep if _m==3
keep trifd reportingyear d_firmID firmName stdFirmName subfirmName subStdFirmName vintageName vintageStdName subFacilityName
append using ".\Data\Data_TRI\preqinTRIMap.dta"
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

use ".\Data\Data_TRI\PreqinNames.dta", clear
keep d_firmID d_firmName d_firstDealYear postPeriod dist_to_deal reportingyear d_dealDummy
duplicates drop
merge 1:m d_firmID reportingyear using ".\Data\Data_TRI\preqinTRIMap.dta"
drop if _m==1
drop _m
recode postPeriod (.=0)
sort trifd reportingyear d_firmID
order trifd reportingyear d_firmID d_firstDealYear postPeriod dist_to_deal d_dealDummy d_firmName subFacilityName firmName stdFirmName subfirmName subStdFirmName vintageName vintageStdName
save ".\Data\Data_TRI\preqinTRIMap.dta", replace

//I check if a facility is mapped to a unique firm. If it is then I consider it a correct match and I keep only these.
bysort trifd reportingyear: egen uniq_preqinID = nvals(d_firmID)
bysort trifd: egen maxuniq_preqinID = max(uniq_preqinID) 
drop if maxuniq_preqinID!=1
drop uniq_preqinID maxuniq_preqinID
duplicates drop
save ".\Data\Data_TRI\preqinTRIMap.dta", replace
}
}
**Preqin matched data.
{
use ".\Data\Data_TRI\fileType1a.dta", clear
destring totalonsitereleases, replace force
keep reportingyear trichemicalid chemicalname casnumber classification unitofmeasure cleanairactind carcinogenind pfasind metalind trifd totalonsitereleases
ren totalonsitereleases v218_TotalOnsite
bysort trifd: gen cntr = _N
drop if cntr==1 //dropping singleton observations
drop cntr
save temp.dta, replace

use ".\Data\Data_TRI\fileType4.dta", clear
keep trifd reportingyear county state primarynaics
merge 1:m trifd reportingyear using temp.dta
keep if _m==3
drop _m
save temp.dta, replace

import delimited ".\Data\Data_TRI\RSEI\chemical_data_rsei_v2311.csv", clear bindq(strict) maxquotedrows(unlimited) stringc(_all)
keep casstandard hapflag prioritypollutantflag sdwaflag cerclaflag oshacarcinogens
foreach var of varlist hapflag prioritypollutantflag sdwaflag cerclaflag oshacarcinogens {
	replace `var' = cond(`var'=="TRUE","1","0")
}
destring hapflag prioritypollutantflag sdwaflag cerclaflag oshacarcinogens, replace
ren casstandard casnumber
merge 1:m casnumber using temp.dta
drop if _m==1
drop _m
replace casnumber = subinstr(casnumber,"-","",.)
gen carcinogenind1 = cond(carcinogenind=="YES",1,0)
replace carcinogenind1 = 1 if oshacarcinogens==1
drop oshacarcinogens carcinogenind
ren carcinogenind1 carcinogenind
save temp.dta, replace

import excel using ".\Data\Data_TRI\Chemicals List\clean air act.xlsx", clear first all
keep CASNumber
ren CASNumber casnumber
drop if casnumber=="0"
merge 1:m casnumber using temp.dta
drop if _m==1
replace chemicalname = lower(chemicalname)
replace _m=3 if strpos(chemicalname,"antimony")|strpos(chemicalname,"arsenic")|strpos(chemicalname,"beryllium")|strpos(chemicalname,"cadmium")|strpos(chemicalname,"chromium")|strpos(chemicalname,"cobalt")|strpos(chemicalname,"cyanide")|strpos(chemicalname,"lead")|strpos(chemicalname,"manganese")|strpos(chemicalname,"mercury")|strpos(chemicalname,"nickel")|strpos(chemicalname,"selenium")|strpos(chemicalname,"glycol ether")|inlist(casnumber,"12185103","N120","N150","N590")
gen caaflag = 1 if _m==3
drop _m
drop cleanairactind
save temp.dta, replace

gen type1 = cond(caaflag==1,1,0)
gen type2 = cond(carcinogenind==1,1,0)
gen type3 = cond(hapflag==1,1,0)
gen type4 = cond(prioritypollutantflag==1,1,0)
gen type5 = cond(sdwaflag==1,1,0)
gen type6 = cond(cerclaflag==1,1,0)
gen type7 = cond(type1|type2|pfasind=="YES"|classification=="PBT"|type3|type4|type5|type6,0,1)
replace unitofmeasure="Pounds" if inlist(unitofmeasure,"Pounds","POUNDS")
save temp.dta, replace	

//I drop facilities with zero onsite releases through the entire time period
bysort trifd: egen double totalOnsite = total(v218_TotalOnsite)
drop if totalOnsite==0
drop totalOnsite

label var type1 "Clean Air Act"
label var type2 "Carcinogenic"
label var type3 "Hazardous Air Pollutant"
label var type4 "Priority Pollutant"
label var type5 "Safe Drinking Water Act"
label var type6 "CERCL Act"
label var type7 "Less Harmful Chemicals"

replace v218_TotalOnsite = v218_TotalOnsite * 0.00220462 if unitofmeasure=="Grams"
drop if unitofmeasure=="TRI"
drop unitofmeasure
save temp.dta, replace	

keep casnumber trifd county state primarynaicscode reportingyear trichemicalid chemicalname v218_TotalOnsite type*
order trifd reportingyear county state primarynaicscode casnumber trichemicalid chemicalname v218_TotalOnsite type*
sort trifd casnumber reportingyear
gen aggregationType = "Individual Chemical"
save temp1.dta, replace

forvalues i = 1/7 {
	use temp.dta, clear
	local lab: variable label type`i'
	keep if type`i'==1
	collapse (sum) v218_TotalOnsite, by(trifd reportingyear county state primarynaicscode)
	gen aggregationType = "`lab'"
	append using temp1.dta
	save temp1.dta, replace
}
keep trifd reportingyear county state primarynaicscode aggregationType casnumber trichemicalid chemicalname v218_TotalOnsite
order trifd reportingyear county state primarynaicscode aggregationType casnumber trichemicalid chemicalname v218_TotalOnsite
save temp1.dta, replace

use temp.dta, clear
collapse (sum) v218_TotalOnsite, by(trifd reportingyear county state primarynaicscode)
gen aggregationType = "All Chemicals"
append using temp1.dta
keep trifd reportingyear county state primarynaicscode aggregationType casnumber trichemicalid chemicalname v218_TotalOnsite
order trifd reportingyear county state primarynaicscode aggregationType casnumber trichemicalid chemicalname v218_TotalOnsite
sort trifd aggregationType casnumber reportingyear 
save temp1.dta, replace

local i = 1
levelsof aggregationType, local(aggs)
foreach agg of local aggs {
	use temp1.dta, clear
	keep if aggregationType=="`agg'"
	foreach var of varlist v218_TotalOnsite {
		gen Ln`var' = log(1+`var')
		winsor2 Ln`var', replace trim cut(0 99)
		winsor2 `var', cut(0 99) trim suffix(tr)
	}
	if `i'==1 {
		save temp.dta, replace
		local ++i
	}
	else {
		append using temp.dta
		save temp.dta, replace
	}
}

egen double IndustryYear = group(primarynaics reportingyear)
save temp.dta, replace

collapse (mean) v218_TotalOnsite, by(IndustryYear aggregationType casnumber)
ren v218_TotalOnsite B_v218_IndYr
gen B_Lnv218_IndYr = log(1+B_v218_IndYr)
drop if missing(IndustryYear)
merge 1:m IndustryYear aggregationType casnumber using temp.dta
drop _m IndustryYear
save temp.dta, replace

keep trifd reportingyear county state primarynaicscode aggregationType casnumber trichemicalid chemicalname v218_TotalOnsite Lnv218_TotalOnsite v218_TotalOnsitetr B_Lnv218_IndYr
order trifd reportingyear county state primarynaicscode aggregationType casnumber trichemicalid chemicalname v218_TotalOnsite Lnv218_TotalOnsite v218_TotalOnsitetr B_Lnv218_IndYr
sort trifd aggregationType casnumber reportingyear 
save temp.dta, replace

egen double countyYear = group(county reportingyear)
save temp.dta, replace

label var v218_TotalOnsite "Total Onsite Releases"
label var Lnv218_TotalOnsite "Log. Total Onsite Releases" 
label var v218_TotalOnsitetr "Total Onsite Releases (Winsorized)"

label var B_Lnv218_IndYr "Industry-Year Benchmark Release"
label var countyYear "County-Year"
save temp.dta, replace

merge m:1 trifd reportingyear using ".\Data\Data_TRI\preqinTRIMap.dta", keepus(d_firmID d_dealDummy d_firstDealYear postPeriod dist_to_deal)
drop if _m==2
recode postPeriod (.=0)

drop _m
order d_firmID d_firstDealYear d_dealDummy postPeriod dist_to_deal, a(trifd)
label var d_firmID "Preqin ID of PE Portfolio Firm"
label var postPeriod "Post-Deal Period"

//Ensuring that each facility has at least one observation in the pre and post periods
bysort trifd (reportingyear): egen maxPost = max(postPeriod)
bysort trifd (reportingyear): egen minPost = min(postPeriod)
drop if !(minPost==0 & maxPost==1) & d_firmID!=.
drop minPost maxPost
sort d_firmID d_firstDealYear trifd aggregationType casnumber reportingyear
label var dist_to_deal "Time to PE Deal"
save ".\Data\Data_TRI\fileType1a_PreqinFirmLevel.dta", replace
erase temp.dta
erase temp1.dta

*erase ".\Data\Data_TRI\tempPreqinNames.dta"
*erase ".\Data\Data_TRI\tempTRINames.dta"
*erase ".\Data\Data_TRI\TRINames.dta"
*erase ".\Data\Data_TRI\TRINamesFull.dta"
}

log closelog using ".\logfile_trucost", replace

set more off
clear all

//Trucost dataset
import delimited using ".\Data\Data_trucost\trucost_rawData_20230608.txt", clear
gen tperiodenddate = date(periodenddate,"DMY")
drop periodenddate
ren tperiodenddate periodenddate
format periodenddate %td

rename di_319413 s1tot
rename di_319414 s2tot
rename di_326737 s3totdown
rename di_319415 s3totup
rename di_319407 s1int
rename di_319408 s2int
rename di_326738 s3intdown
rename di_319409 s3intup
save temp.dta, replace

keep institutionid fiscalyear
duplicates drop
bysort institutionid: gen noObs = _N
drop if noObs==1
drop noObs fiscalyear
duplicates drop
merge 1:m institutionid using temp.dta
keep if _m==3
drop _m
save temp.dta, replace

drop gvkey ticker companyid status companytype
duplicates drop
duplicates tag institutionid fiscalyear, gen(tag)
gen webpagePresent = cond(webpage=="",0,1)
bysort institutionid fiscalyear: egen maxwebpagePresent = max(webpagePresent)
drop if tag!=0 & webpagePresent==0 & maxwebpagePresent==1
drop tag webpagePresent maxwebpagePresent
save temp.dta, replace

use temp.dta, clear
keep institutionid tcprimarysectorid fiscalyear periodenddate s1int s3intup s2int s1tot s2tot s3totup s3intdown s3totdown
duplicates drop
save ".\Data\Data_trucost\trucostFirms.dta", replace

use temp.dta, clear
keep institutionid companyname webpage country
duplicates drop
replace country = upper(country)
replace country = "BOSNIA & HERZEGOVINA" if country=="BOSNIA-HERZEGOVINA"
replace country = "COMORO ISLANDS" if country=="COMOROS"
replace country = "GUYANA" if country=="FRENCH GUIANA"
replace country = "HONG KONG SAR - CHINA" if country=="HONG KONG"
replace country = "MACAO SAR - CHINA" if country=="MACAU"
replace country = "TAIWAN - CHINA" if country=="TAIWAN"

replace webpage = "" if inlist(webpage,"No Website Available","http://No Website Available","http://No website available")
forvalues i = 1/3 {
	replace webpage = regexr(webpage,"^http://","")
	replace webpage = regexr(webpage,"^https://","")
	replace webpage = regexr(webpage,"^www\.","")
	replace webpage = regexr(webpage,"#$","")
	replace webpage = regexr(webpage,"/$","")
}
replace webpage = strtrim(webpage)
replace webpage = "http://" + webpage if webpage!=""

forvalues i = 1/3 {
	replace webpage = regexr(webpage,"#$","")
	replace webpage = regexr(webpage,"/$","")
	replace webpage = regexr(webpage,"/en-gb$","")
	replace webpage = regexr(webpage,"/en$","")
}
replace webpage = cond(strpos(webpage,".com/"),substr(webpage,1,strpos(webpage,".com/")+3),webpage)

replace companyname = upper(companyname)
gen cleanedName = companyname
replace cleanedName = upper(cleanedName)
local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace cleanedName = subinstr(cleanedName,"`a'","a",.)
}
foreach e of local specialEs {
	replace cleanedName = subinstr(cleanedName,"`e'","e",.)
}
foreach i of local specialIs {
	replace cleanedName = subinstr(cleanedName,"`i'","i",.)
}
foreach o of local specialOs {
	replace cleanedName = subinstr(cleanedName,"`o'","o",.)
}
foreach u of local specialUs {
	replace cleanedName = subinstr(cleanedName,"`u'","u",.)
}
foreach y of local specialYs {
	replace cleanedName = subinstr(cleanedName,"`y'","y",.)
}
replace cleanedName = subinstr(cleanedName,"ñ","n",.)
replace cleanedName = subinstr(cleanedName,"Ñ","n",.)
replace cleanedName = subinstr(cleanedName,"æ","ae",.)
replace cleanedName = subinstr(cleanedName,"Æ","ae",.)
replace cleanedName = subinstr(cleanedName,"Œ","ce",.)
replace cleanedName = subinstr(cleanedName,"œ","ce",.)
replace cleanedName = subinstr(cleanedName,"Ç","c",.)
replace cleanedName = subinstr(cleanedName,"ç","c",.)
replace cleanedName = usubinstr(cleanedName,"ž","z",.)

replace cleanedName = subinstr(cleanedName,".","",.)
replace cleanedName = subinstr(cleanedName,",","",.)
replace cleanedName = subinstr(cleanedName,"-","",.)
replace cleanedName = subinstr(cleanedName,"/","",.)
replace cleanedName = subinstr(cleanedName,"'","",.)
replace cleanedName = subinstr(cleanedName,"!","",.)
replace cleanedName = subinstr(cleanedName,":","",.)
replace cleanedName = subinstr(cleanedName,";","",.)
replace cleanedName = subinstr(cleanedName,"#","",.)
replace cleanedName = subinstr(cleanedName,"*","",.)
replace cleanedName = subinstr(cleanedName,"@","",.)
replace cleanedName = subinstr(cleanedName,"_","",.)
replace cleanedName = subinstr(cleanedName,"|","",.)
replace cleanedName = subinstr(cleanedName,"$","",.)
replace cleanedName = subinstr(cleanedName,"\","",.)
replace cleanedName = subinstr(cleanedName,"+","",.)
replace cleanedName = usubinstr(cleanedName,"¿","",.)

replace cleanedName = subinstr(cleanedName,"&"," & ",.)
replace cleanedName  = subinstr(cleanedName ," AND "," & ",.)

forvalues i = 1/3 {
	replace cleanedName  = regexr(cleanedName,"BERHAD","BHD")
	replace cleanedName  = regexr(cleanedName,"PRIVATE","PVT")
	replace cleanedName  = regexr(cleanedName,"LIMITED","LTD")
	replace cleanedName  = regexr(cleanedName,"COMPANY","CO")
	replace cleanedName  = regexr(cleanedName,"INCORPORATED","INC")
	replace cleanedName  = regexr(cleanedName,"PTY","PVT")
	replace cleanedName  = regexr(cleanedName,"CORPORATION","CORP")
	replace cleanedName  = regexr(cleanedName,"CO LTD","COLTD")
	replace cleanedName  = regexr(cleanedName ,"L L C","LLC")
	replace cleanedName  = regexr(cleanedName," INTL "," INTERNATIONAL ")
	replace cleanedName  = regexr(cleanedName," COS "," CO ")
	replace cleanedName  = regexr(cleanedName," COS$"," CO$")
	replace cleanedName  = regexr(cleanedName," S A$"," SA")
	replace cleanedName  = regexr(cleanedName," S C$"," SC")
	replace cleanedName  = regexr(cleanedName," P C$"," PC")
	replace cleanedName  = regexr(cleanedName," N V$"," NV")
	replace cleanedName  = regexr(cleanedName," SA RL$"," SARL")
}

replace cleanedName  = subinstr(cleanedName ,"SERVICES","SERVICE",.)
replace cleanedName  = subinstr(cleanedName ,"SYSTEMS","SYSTEM",.)
replace cleanedName  = subinstr(cleanedName ,"HOLDINGS","HOLDING",.)
replace cleanedName  = subinstr(cleanedName ,"SOLUTIONS","SOLUTION",.)
replace cleanedName  = subinstr(cleanedName ,"PRODUCTS","PRODUCT",.)
replace cleanedName  = subinstr(cleanedName ,"PARTNERS","PARTNER",.)
replace cleanedName  = subinstr(cleanedName ,"ENTERPRISES","ENTERPRISE",.)
replace cleanedName  = subinstr(cleanedName ,"MATERIALS","MATERIAL",.)
replace cleanedName  = subinstr(cleanedName ,"METALS","METAL",.)
replace cleanedName  = subinstr(cleanedName ,"CHEMICALS","CHEMICAL",.)

replace cleanedName  = strtrim(cleanedName )
replace cleanedName  = stritrim(cleanedName )
replace cleanedName = upper(cleanedName)
duplicates drop

gen cleanedName_noExt = cleanedName

forvalues i = 1/3 {
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"^THE ","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CO$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PVT LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CO LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTD$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LTDA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LLC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LLP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," INC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PVT$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PTY$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PLC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," INC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," CORP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," LP$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"^OOO ","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," GMBH$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," MBH$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," SARL$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AS$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AB$","")
	replace cleanedName_noExt  =   regexr(cleanedName_noExt ," AG$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SCA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SA$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," PC$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," NV$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," SL$","")
	replace cleanedName_noExt  = regexr(cleanedName_noExt ," BV$","")
	replace cleanedName_noExt  = subinstr(cleanedName_noExt ," OOO$","",.)
	replace cleanedName_noExt  = regexr(cleanedName_noExt ,"S$","")
	replace cleanedName_noExt  = strtrim(cleanedName_noExt )
	replace cleanedName_noExt  = stritrim(cleanedName_noExt )
}
gen cleanedName_noSpace = subinstr(cleanedName_noExt," ","",.)
gen cleanedName_noFreq = cleanedName_noSpace

forvalues i = 1/3 {
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"INDUSTRIES","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"HOLDING","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"GROUP","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"PRODUCT","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"INTERNATIONAL","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"TECHNOLOGIES","",.)
	replace cleanedName_noFreq  = subinstr(cleanedName_noFreq ,"&","",.)	
}
 
compress
recast str160 webpage
save ".\Data\Data_trucost\trucostNames.dta", replace
erase temp.dta
********************************************************************************
****************************TARGET FIRMS - PREQIN*******************************
********************************************************************************
use ".\Data\Data_preqin\preqin_dealsBuyout.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep d_dealID d_firmName d_dealYear d_firmID d_firmCountry d_firmWebsite
duplicates drop
save ".\Data\Data_trucost\preqinNames.dta", replace

use ".\Data\Data_preqin\preqin_dealsVC.dta", clear
keep if d_dealStatus=="COMPLETED"
gen d_dealYear = year(d_dealDate)
drop if d_firmCountry==""
keep d_dealID d_firmName d_dealYear d_firmID d_firmCountry d_firmWebsite
append using ".\Data\Data_trucost\preqinNames.dta"
duplicates drop
save ".\Data\Data_trucost\preqinNames.dta", replace

bysort d_firmID: egen d_firstDealYear = min(d_dealYear)
keep d_firmID d_firmName d_firmCountry d_firmWebsite d_firstDealYear
duplicates drop
bysort d_firmID (d_firmName): keep if _n==_N
save ".\Data\Data_trucost\preqinNames.dta", replace

local specialAs = `" "à" "á" "â" "ã" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
local specialEs = `" "è" "é" "ê" "ë" "È" "É" "Ê" "Ë" "'
local specialIs = `" "ì" "í" "î" "ï" "Ì" "Í" "Î" "Ï" "'
local specialOs = `" "ò" "ó" "ô" "õ" "ö" "ø" "Ò" "Ó" "Ô" "Õ" "Ö" "Ø" "'
local specialUs = `" "ù" "ú" "û" "ü" "Ù" "Ú" "Û" "Ü" "'
local specialYs = `" "ý" "ÿ" "Ÿ" "Ý" "ä" "å" "Å" "À" "Á" "Â" "Ã" "Ä" "'
foreach a of local specialAs {
	replace d_firmName = subinstr(d_firmName,"`a'","a",.)
}
foreach e of local specialEs {
	replace d_firmName = subinstr(d_firmName,"`e'","e",.)
}
foreach i of local specialIs {
	replace d_firmName = subinstr(d_firmName,"`i'","i",.)
}
foreach o of local specialOs {
	replace d_firmName = subinstr(d_firmName,"`o'","o",.)
}
foreach u of local specialUs {
	replace d_firmName = subinstr(d_firmName,"`u'","u",.)
}
foreach y of local specialYs {
	replace d_firmName = subinstr(d_firmName,"`y'","y",.)
}
replace d_firmName = subinstr(d_firmName,"ñ","n",.)
replace d_firmName = subinstr(d_firmName,"Ñ","n",.)
replace d_firmName = subinstr(d_firmName,"æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Æ","ae",.)
replace d_firmName = subinstr(d_firmName,"Œ","ce",.)
replace d_firmName = subinstr(d_firmName,"œ","ce",.)
replace d_firmName = subinstr(d_firmName,"Ç","c",.)
replace d_firmName = subinstr(d_firmName,"ç","c",.)
replace d_firmName = usubinstr(d_firmName,"ž","z",.)

replace d_firmName = subinstr(d_firmName,".","",.)
replace d_firmName = subinstr(d_firmName,",","",.)
replace d_firmName = subinstr(d_firmName,"-","",.)
replace d_firmName = subinstr(d_firmName,"/","",.)
replace d_firmName = subinstr(d_firmName,"'","",.)
replace d_firmName = subinstr(d_firmName,"!","",.)
replace d_firmName = subinstr(d_firmName,":","",.)
replace d_firmName = subinstr(d_firmName,";","",.)
replace d_firmName = subinstr(d_firmName,"#","",.)
replace d_firmName = subinstr(d_firmName,"*","",.)
replace d_firmName = subinstr(d_firmName,"@","",.)
replace d_firmName = subinstr(d_firmName,"_","",.)
replace d_firmName = subinstr(d_firmName,"|","",.)
replace d_firmName = subinstr(d_firmName,"$","",.)
replace d_firmName = subinstr(d_firmName,"\","",.)
replace d_firmName = subinstr(d_firmName,"+","",.)
replace d_firmName = usubinstr(d_firmName,"¿","",.)

replace d_firmName = subinstr(d_firmName,"&"," & ",.)
replace d_firmName  = subinstr(d_firmName ," AND "," & ",.)

forvalues i = 1/3 {
	replace d_firmName  = regexr(d_firmName,"BERHAD","BHD")
	replace d_firmName  = regexr(d_firmName,"PRIVATE","PVT")
	replace d_firmName  = regexr(d_firmName,"LIMITED","LTD")
	replace d_firmName  = regexr(d_firmName,"COMPANY","CO")
	replace d_firmName  = regexr(d_firmName,"INCORPORATED","INC")
	replace d_firmName  = regexr(d_firmName,"PTY","PVT")
	replace d_firmName  = regexr(d_firmName,"CORPORATION","CORP")
	replace d_firmName  = regexr(d_firmName,"CO LTD","COLTD")
	replace d_firmName  = regexr(d_firmName ,"L L C","LLC")
	replace d_firmName  = regexr(d_firmName," INTL "," INTERNATIONAL ")
	replace d_firmName  = regexr(d_firmName," COS "," CO ")
	replace d_firmName  = regexr(d_firmName," COS$"," CO$")
	replace d_firmName  = regexr(d_firmName," S A$"," SA")
	replace d_firmName  = regexr(d_firmName," S C$"," SC")
	replace d_firmName  = regexr(d_firmName," P C$"," PC")
	replace d_firmName  = regexr(d_firmName," N V$"," NV")
	replace d_firmName  = regexr(d_firmName," SA RL$"," SARL")
}

replace d_firmName  = subinstr(d_firmName ,"SERVICES","SERVICE",.)
replace d_firmName  = subinstr(d_firmName ,"SYSTEMS","SYSTEM",.)
replace d_firmName  = subinstr(d_firmName ,"HOLDINGS","HOLDING",.)
replace d_firmName  = subinstr(d_firmName ,"SOLUTIONS","SOLUTION",.)
replace d_firmName  = subinstr(d_firmName ,"PRODUCTS","PRODUCT",.)
replace d_firmName  = subinstr(d_firmName ,"PARTNERS","PARTNER",.)
replace d_firmName  = subinstr(d_firmName ,"ENTERPRISES","ENTERPRISE",.)
replace d_firmName  = subinstr(d_firmName ,"MATERIALS","MATERIAL",.)
replace d_firmName  = subinstr(d_firmName ,"METALS","METAL",.)
replace d_firmName  = subinstr(d_firmName ,"CHEMICALS","CHEMICAL",.)

replace d_firmName  = strtrim(d_firmName )
replace d_firmName  = stritrim(d_firmName )
replace d_firmName = upper(d_firmName)
duplicates drop
save ".\Data\Data_trucost\preqinNames.dta", replace

use ".\Data\Data_trucost\preqinNames.dta", clear
gen d_firmName_noExt = d_firmName
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^THE ","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CO LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTD$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LTDA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LLP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PVT$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PTY$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PLC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," INC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," CORP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," LP$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"^OOO ","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," GMBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," MBH$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," SARL$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AS$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AB$","")
replace d_firmName_noExt  =   regexr(d_firmName_noExt ," AG$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SCA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SA$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," PC$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," NV$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," SL$","")
replace d_firmName_noExt  = regexr(d_firmName_noExt ," BV$","")
replace d_firmName_noExt  = subinstr(d_firmName_noExt ," OOO$","",.)
replace d_firmName_noExt  = regexr(d_firmName_noExt ,"S$","")
replace d_firmName_noExt  = strtrim(d_firmName_noExt )
replace d_firmName_noExt  = stritrim(d_firmName_noExt )

gen d_firmName_noSpace = subinstr(d_firmName_noExt," ","",.)
gen d_firmName_noFreq = d_firmName_noSpace

forvalues i = 1/3 {
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INDUSTRIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"HOLDING","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"GROUP","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"PRODUCT","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"INTERNATIONAL","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"TECHNOLOGIES","",.)
	replace d_firmName_noFreq  = subinstr(d_firmName_noFreq ,"&","",.)	
}

save ".\Data\Data_trucost\preqinNames.dta", replace

********************************************************************************
********************************MATCHING****************************************
********************************************************************************
//Exact Match - website and country
use ".\Data\Data_trucost\preqinNames.dta", clear
ren (d_firmWebsite d_firmCountry) (webpage country)
drop if missing(webpage)
joinby webpage country using ".\Data\Data_trucost\trucostNames.dta"
keep d_firmID institutionid
duplicates drop
save ".\Data\Data_trucost\preqinTrucostMap.dta", replace

//Exact Match - name and country
keep d_firmID
duplicates drop
merge 1:m d_firmID using ".\Data\Data_trucost\preqinNames.dta"
keep if _m==2
drop _m
ren (d_firmName d_firmCountry) (cleanedName country)
joinby cleanedName country using ".\Data\Data_trucost\trucostNames.dta"
keep d_firmID institutionid
duplicates drop
append using ".\Data\Data_trucost\preqinTrucostMap.dta"
save ".\Data\Data_trucost\preqinTrucostMap.dta", replace

//Exact Match - no extention name and country
keep d_firmID
duplicates drop
merge 1:m d_firmID using ".\Data\Data_trucost\preqinNames.dta"
keep if _m==2
drop _m
ren (d_firmName d_firmCountry) (cleanedName_noExt country)
joinby cleanedName_noExt country using ".\Data\Data_trucost\trucostNames.dta"
keep d_firmID institutionid
duplicates drop
append using ".\Data\Data_trucost\preqinTrucostMap.dta"
save ".\Data\Data_trucost\preqinTrucostMap.dta", replace

//Control firms
keep institutionid
duplicates drop
merge 1:m institutionid using ".\Data\Data_trucost\trucostFirms.dta"
keep if _m==2
drop _m
save ".\Data\Data_trucost\trucostFirms_ctrl.dta", replace

use ".\Data\Data_trucost\trucostNames.dta", clear
keep institutionid country
duplicates drop
bysort institutionid (country): keep if _n==1 //there are 9 duplicates on country. I keep the first country alphabetically for reproducability
merge 1:m institutionid using ".\Data\Data_trucost\trucostFirms_ctrl.dta"
keep if _m==3
drop _m
ren country d_firmCountry
save ".\Data\Data_trucost\trucostFirms_ctrl.dta", replace

//Removing duplicates in the name matching
use ".\Data\Data_trucost\preqinTrucostMap.dta", clear
joinby institutionid using ".\Data\Data_trucost\trucostFirms.dta"

drop if d_firmID==50734 & institutionid!=4056944
drop if d_firmID==29970 & institutionid!=4074390
drop if d_firmID==66196 & institutionid!=4315535
drop if d_firmID==191974 & institutionid!=4222888
drop if d_firmID==25465 & institutionid!=4011165
drop if d_firmID==25781 & institutionid!=4239834
drop if d_firmID==26089 & institutionid!=4079844
drop if d_firmID==26102 & institutionid!=4547331
drop if d_firmID==28562 & institutionid!=4211819
drop if d_firmID==28773 & institutionid!=113873
drop if d_firmID==30222 & institutionid!=4289238
drop if d_firmID==31173 & institutionid!=4635041
drop if d_firmID==31785 & institutionid!=4409177
drop if d_firmID==32305 & institutionid!=4583780
drop if d_firmID==537262 & institutionid!=4916027
drop if d_firmID==496002 & institutionid!=4059727
drop if d_firmID==492751 & institutionid!=4916027
drop if d_firmID==332483 & institutionid!=4099043
drop if d_firmID==243114 & institutionid!=103540
drop if d_firmID==332121 & institutionid!=4099043
drop if d_firmID==325538 & institutionid!=4393634
drop if d_firmID==277747 & institutionid!=4010375
drop if d_firmID==190101 & institutionid!=4583780
drop if d_firmID==33945 & institutionid!=4060605
drop if d_firmID==37613 & institutionid!=4051708
drop if d_firmID==36389 & institutionid!=4421633
drop if d_firmID==32574 & institutionid!=4581367
drop if d_firmID==37801 & institutionid!=4915427
drop if d_firmID==54508 & institutionid!=4964093
drop if d_firmID==38751 & institutionid!=4147538
drop if d_firmID==292917 & institutionid!=4981606
drop if d_firmID==216106 & institutionid!=4689464
drop if d_firmID==165708 & institutionid!=4472962
drop if d_firmID==149558 & institutionid!=4295253
drop if d_firmID==149161 & institutionid!=4994797
drop if d_firmID==147784 & institutionid!=5000797
drop if d_firmID==142642 & institutionid!=4295253
drop if d_firmID==140892 & institutionid!=4168701
drop if d_firmID==123012 & institutionid!=4239834
drop if d_firmID==103422 & institutionid!=4057056
drop if d_firmID==98390 & institutionid!=6676006
drop if d_firmID==77611 & institutionid!=4011047
drop if d_firmID==74320 & institutionid!=4916027
drop if d_firmID==60822 & institutionid!=4344712
drop if d_firmID==58967 & institutionid!=4041201
drop if d_firmID==56771 & institutionid!=4138465
drop if d_firmID==38751 & institutionid!=4147538
drop if d_firmID==47587 & institutionid!=4088449
drop if d_firmID==51922 & institutionid!=4417220
drop if d_firmID==124931 & institutionid!=4415922

save ".\Data\Data_trucost\trucostFirms_trt.dta", replace

use ".\Data\Data_trucost\preqinNames.dta", clear
keep d_firmID d_firmCountry d_firstDealYear
duplicates drop
merge 1:m d_firmID using ".\Data\Data_trucost\trucostFirms_trt.dta"
keep if _m==3
drop _m
append using ".\Data\Data_trucost\trucostFirms_ctrl.dta"
gen postPeriod = cond(fiscalyear>=d_firstDealYear,1,0)
gen dist_to_deal = fiscalyear - d_firstDealYear
egen double countryYear = group(d_firmCountry fiscalyear)
egen double industryYear = group(tcprimarysectorid fiscalyear)
sort institutionid fiscalyear

//Log variables
foreach var of varlist s1tot s2tot s3totup s3totdown {
	gen log_`var' = log(`var')
}
save ".\Data\Data_trucost\trucost.dta", replace

//For treatment firms I ensure that there is at least one non-missing year in both the pre and post period
use ".\Data\Data_trucost\trucost.dta", clear
bysort d_firmID: egen minPost = min(postPeriod)
bysort d_firmID: egen maxPost = max(postPeriod)
drop if d_firmID!=. & !(minPost==0 & maxPost==1)
drop minPost maxPost
save ".\Data\Data_trucost\trucost.dta", replace

label var log_s1tot "Log. Scope 1 Emissions"
label var log_s2tot "Log. Scope 2 Emissions"
label var log_s3totup "Log. Scope 3 Emissions (Upstream)"
label var log_s3totdown "Log. Scope 3 Emissions (Downstream)"
save ".\Data\Data_trucost\trucost.dta", replace

erase ".\Data\Data_trucost\preqinNames.dta"
erase ".\Data\Data_trucost\preqinTrucostMap.dta"
erase ".\Data\Data_trucost\trucostFirms.dta"
erase ".\Data\Data_trucost\trucostFirms_ctrl.dta"
erase ".\Data\Data_trucost\trucostFirms_trt.dta"
erase ".\Data\Data_trucost\trucostNames.dta"

log closelog using "logfile_worldbank", replace

set more off
clear all

*db wbopendata
wbopendata, long indicator(SP.POP.TOTL; NY.GDP.MKTP.CD; NY.GDP.MKTP.KD.ZG; SL.TLF.ACTI.ZS; SG.GEN.PARL.ZS) year(1999:2023) clear 
drop region regionname adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename
kountry countrycode, from(iso3c) to(iso2c)
ren (sp_pop_totl - _ISO2C_) (population GDP GDPGrowth laborForceParticipation womenSeatsParliament countryISO2)
	
label var population "Total population"
label var GDP "GDP"
label var GDPGrowth "GDP growth"
label var laborForceParticipation "Labor force (%)"
label var womenSeatsParliament "Female Representation (%)"

drop if missing(countryISO2)

keep countryname countryISO2 year population GDP GDPGrowth laborForceParticipation womenSeatsParliament
order countryISO2, a(countryname)

replace countryname = "Russia" if countryname=="Russian Federation"
replace countryname = "Iran" if countryname=="Iran, Islamic Rep"
replace countryname = "South Korea" if countryname=="Korea, Rep"
replace countryname = "HONG KONG SAR - CHINA" if countryname=="Hong Kong SAR, China"
replace countryname = "Egypt" if countryname=="Egypt, Arab Rep"
replace countryname = "Slovakia" if countryname=="Slovak Republic"
replace countryname = "Venezuela" if countryname=="Venezuela, RB"
replace countryname = "Taiwan - China" if countryname=="Taiwan, China"
replace countryname = "Macedonia" if countryname=="North Macedonia"
replace countryname = "Macao" if countryname=="Macao SAR, China"
replace countryname = "Laos" if countryname=="Lao PDR"
replace countryname = "KYRGYZSTAN" if countryname=="Kyrgyz Republic"
replace countryname = "Gambia" if countryname=="Gambia, The"
replace countryname = "IVORY COAST" if countryname=="Cote d'Ivoire"
replace countryname = "CONGO" if countryname=="Congo, Rep"
replace countryname = "DEMOCRATIC REPUBLIC OF CONGO" if countryname=="Congo, Dem Rep"
replace countryname = "Comoro Islands" if countryname=="Comoros"
replace countryname = "CAPE VERDE" if countryname=="Cabo Verde"
replace countryname = "BRUNEI" if countryname=="Brunei Darussalam"
replace countryname = "BOSNIA & HERZEGOVINA" if countryname=="Bosnia and Herzegovina"
replace countryname = "Bahamas" if countryname=="Bahamas, The"
replace countryname = "MACAO SAR - CHINA" if countryname=="Macao"
replace countryname = "US VIRGIN ISLANDS" if countryname=="Virgin Islands (US)"
replace countryname = upper(countryname)

order countryname countryISO2 year GDP GDPGrowth population laborForceParticipation womenSeatsParliament
dropmiss GDP GDPGrowth population laborForceParticipation womenSeatsParliament, force obs
save "./Data/Data_worldbank/worldbank.dta", replace

log close
