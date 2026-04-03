/******************************************************************************/

/* This file cleans SDC data. */
/*
Date: 2020.03.13


/******************************/		
Input files:
/******************************/		

	- (1) /Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/SDC/SDC_IssuerSaleDate_19902014.csv.
	
cusip_6	saledate	county	issuer	ratingagency
729773	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729778	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729780	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729783	01/02/90	Hennepin	Plymouth City-Minnesota	SP
864048	01/02/90	Door	Sturgeon Bay-Wisconsin	
864056	01/02/90	Door	Sturgeon Bay-Wisconsin	
944048	01/02/90	Kosciusko	Wawasee Comm School Corp	
944050	01/02/90	Kosciusko	Wawasee Comm School Corp	
947644	01/02/90	Weber	Weber Co-Utah	
947648	01/02/90	Weber	Weber Co-Utah	
947651	01/02/90	Weber	Weber Co-Utah	
947659	01/02/90	Weber	Weber Co-Utah	
004590	01/03/90	Franklin-Hardin	Ackley City-Iowa	
004606	01/03/90	Franklin-Hardin	Ackley City-Iowa	
004613	01/03/90	Franklin-Hardin	Ackley City-Iowa	
048339	01/03/90	Atlantic	Atlantic City-New Jersey	
048343	01/03/90	Atlantic	Atlantic City-New Jersey	
048339	01/03/90	Atlantic	Atlantic City-New Jersey	MOODY;SP
048343	01/03/90	Atlantic	Atlantic City-New Jersey	MOODY;SP
	
	
*/
/******************************************************************************/

clear all 
set more off 
set matsize 750

// cd "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\SDC"
cd "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/SDC"
global data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Analysis/Round 2 new"



***********************************************************************/
/* SDC data cleaning */
**********************************************************************/



use SDC_IssuerSaleDate_19902014, clear // created by 01_sdc_issuer.R


* Sale date
gen year = substr(saledate, 7,2) 
gen month = substr(saledate, 1,2)
gen day = substr(saledate, 4,2)

destring year, replace
destring month, replace
destring day, replace
replace year = 2000+year if year <=14
replace year = 1900+year if year >=90 & year <=99 & year !=.

tab year
tab month
tab day
count 
*857,323

drop saledate
gen saledate = mdy(month, day, year)
format saledate %td

* Ratinng agency
replace ratingagency = lower(ratingagency)
tab ratingagency

gen moody_rated = strpos(ratingagency, "moody")>0
gen sp_rated = strpos(ratingagency, "sp")>0
gen fitch_rated = strpos(ratingagency, "fitch")>0
count if moody_rated == 0 & sp_rated == 0 & fitch_rated == 0 & rateddealflag == "Yes" 
*0

gen rated = rateddealflag == "Yes"

* Credit enhancement
gen insurance = creditenhancetype != ""

* Callable
gen call = callable == "Yes"
tab call

* Go vs reveneu
gen go = security == "GO"


* amount of issue
destring amountofissue, replace force 
*forced is used because missing amount is denoted by NA.


* Maturity

gen yearm = substr(maxmaturity, 1,4)
gen monthm = substr(maxmaturity, 6,2)
gen daym = substr(maxmaturity,9,2)
destring monthm daym, replace
destring yearm, replace force
tab yearm
gen max_maturity = mdy(monthm, daym, yearm)
replace max_maturity = . if maxmaturity == "NA" | yearm <1990
format max_maturity %td
drop yearm monthm daym




* Underwriter
gen underwriter = leadmng 
*857,323










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
* Generate issuer-year level data
/**********************************************************************/

preserve

gen year1 = year
replace year1 = year - 1 if month <=6

drop if year <= 1990 & month <=6
drop if year >=2014 & month>=7
tab year1
drop year
rename year1 year

* Compute average issuer-year rating, insurance, call, go
sort cusip_6 year

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6 year: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6 year: egen first_offer_date = min(saledate)
by cusip_6 year: egen last_offer_date = max(saledate)
by cusip_6 year: gen num_offer = _N
format first_offer_date last_offer_date %td
by cusip_6 year: egen nvals = total(amountofissue)
gen amountofissue0=amountofissue
replace amountofissue = nvals
drop nvals

* Max maturity

by cusip_6 year: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals
format max_maturity %td



* Drop duplicates
* Keep issuers that issue the highest amount of debt and highest frequency of debt
gsort cusip_6 year issuerdscrp -saledate state uop1
by cusip_6 year issuerdscrp: egen nvals = total(amountofissue0) 
** total amount
by cusip_6 year issuerdscrp: gen nvals1 = _N 
** total number
by cusip_6 year issuerdscrp: gen nvals0 =_n ==1

keep if nvals0 == 1
drop nvals0
gsort cusip_6 year -saledate
by cusip_6 year: egen nvals2 = max(nvals) 
** max total amount of debt by cusip_6 year and issuerdscrp
keep if nvals == nvals2 
** keep issuers that issue the highest total amount of debt.
duplicates report cusip_6 year


by cusip_6 year: egen nvals3 = max(nvals1)
keep if nvals3 == nvals1
duplicates report cusip_6 year


sort cusip_6 year state uop1 issuerdscrp
by cusip_6 year: gen issuerdscrp1 = issuerdscrp[_n+1]
sort cusip_6 year 



keep cusip_6 year moody_rated rated sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state amountofissue issuerdscrp issuerdscrp1 uop1 underwriter issuer
sort cusip_6 year state uop1 issuerdscrp issuerdscrp1
cap drop nvals*
by cusip_6 year: gen nvals = _n==1
keep if nvals == 1
drop nvals

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable rated "issuer is rated"
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"
		label variable amountofissue "total annual issuance amount"
		label variable uop1 "purpose"
		label variable underwriter "underwriter"
		label variable issuer "issuer name"

count 
* 387,174 issuer-year


saveold "${data}/sdc_issuer_year20190530.dta", replace version(12)
restore
















/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/* Issuer level: debt outstanding */
/**********************************************************************/


preserve

keep if saledate <= mdy(06,30,2010) & max_maturity >= mdy(06,30,2010) & max_maturity !=. 
keep if rated ==1
sort cusip_6

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6: egen first_offer_date = min(saledate)
by cusip_6: egen last_offer_date = max(saledate)
by cusip_6: gen num_offer = _N
format first_offer_date last_offer_date %td

* Max maturity

by cusip_6: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals

duplicates drop cusip_6, force
keep cusip_6 moody_rated  sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"

count 
*39,158

saveold "${data}/sdc_debtoustanding_20190530.dta", replace version(12) // only sample itself is used. 

restore





/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/* access market */


preserve

keep if saledate <= mdy(06,30,2010) & saledate >= mdy(07,01,2006) 
sort cusip_6

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6: egen first_offer_date = min(saledate)
by cusip_6: egen last_offer_date = max(saledate)
by cusip_6: gen num_offer = _N
format first_offer_date last_offer_date %td
by cusip_6: egen nvals = total(amountofissue)
gen amountofissue0=amountofissue
replace amountofissue = nvals
drop nvals

* Max maturity

by cusip_6: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals

* Drop duplicates
* Keep issuers that issue the highest amount of debt and highest frequency of debt
gsort cusip_6 issuerdscrp -saledate state uop1 issuer
by cusip_6 issuerdscrp: egen nvals = total(amountofissue0) 
** total amount
by cusip_6 issuerdscrp: gen nvals1 = _N 
** total number
by cusip_6 issuerdscrp: gen nvals0 =_n ==1

keep if nvals0 == 1
drop nvals0
gsort cusip_6 issuerdscrp -saledate state uop1 issuer
by cusip_6: egen nvals2 = max(nvals) 
** max total amount of debt by cusip_6 and issuerdscrp
keep if nvals == nvals2 
** keep issuers that issue the highest total amount of debt.
duplicates report cusip_6
/*
--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |        32362             0
        2 |           18             9
--------------------------------------
*/

by cusip_6: egen nvals3 = max(nvals1)
keep if nvals3 == nvals1
duplicates report cusip_6
/*
--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |        32362             0
        2 |           18             9
--------------------------------------
*/
sort cusip_6 year state uop1 issuerdscrp issuer
by cusip_6 (year state uop1 issuerdscrp issuer): gen issuerdscrp1 = issuerdscrp[_n+1]
cap drop nvals
by cusip_6: gen nvals = _n==1
keep if nvals ==1
drop nvals


keep cusip_6 rated moody_rated sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state issuerdscrp issuerdscrp1 amountofissue uop1  underwriter issuer

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"
		label variable amountofissue "total annual issuance amount"

count 
*32,371


saveold "${data}/sdc_accessmarket_20190530.dta", replace version(12)

restore










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

* Issue level

preserve

keep if saledate <= mdy(06,30,2010) & saledate >= mdy(07,01,2006) 
sort cusip_6 saledate 
by cusip_6 saledate: gen nvals =_n==1
keep if nvals ==1
drop nvals

gen issue_id = _n
keep cusip_6 saledate year

saveold "${data}/sdc_issuereg_20190304.dta", replace version(12)

restore









/******************************************************************************/

/*


This file creates the data for financial disclosures. 
Date: 2020.03.13

	
*/


global Data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/Timeliness"
global Data "/Users/szho/Documents/Temp"


* Change formats
forvalues i=2009(1)2014{
	use "${Data}/cd`i'.dta", clear
	saveold "${Data}/cd`i'.dta", replace version(12)
}


























/******************************************************************************/

* STEP 1: CREATE FINANCIAL DISCLOSURE DATA

/******************************************************************************/


* Other disclosures that are CAFR

import excel "${Data}/OtherVoluntaryFinancialDisclosures.xlsx", sheet("Sheet1") firstrow clear
keep othervoluntarydisclosure CAFR
keep if CAFR == 1
sort othervoluntarydisclosure
duplicates drop othervoluntarydisclosure, force
save "${Data}/tempCAFR.dta", replace




* Create disclosure data

forvalues i=2009(1)2014{

	use "${Data}/cd`i'.dta", clear
	
	sort submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure submissiondatetime
	drop if financialdisclosurecat == "NA" // drop non-financial disclosures
	duplicates drop submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure, force // drop duplicates 
	
	gen other = financialdisclosurecat == "OtherFinancialVoluntaryInformation"
	by submissionidentifier: egen nvals = sd(other)
	drop if other == 1 & nvals >0 & nvals !=. // drop footnote disclosures 
	drop nvals other
	
	
	keep submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure submissiondatetime endingdate periodtype
		
	
	* Create disclosure types
	
	gen CAFR = financialdisclosurecat == "AuditedFinancialStatementsOrCAFR15c212"
	gen AnnualFinancial =  financialdisclosurecat == "AnnualFinancialInformationOperatingData15c212"
	gen QMFinancial = financialdisclosurecat == "QuarterlyMonthlyFinancialInformation" | financialdisclosurecat == "InterimAdditionalFinancialInformationOperatingData"
	gen DisclosureFailure = financialdisclosurecat == "FailureToProvideAnnualFinancialInformationAsRequired15c212"
	gen Budget = financialdisclosurecat == "Budget" 

	
	* Create date
	replace submissiondatetime = trim(submissiondatetime)
	gen date = substr(submissiondatetime, 1, 10)
	
	
	keep submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure endingdate periodtype date CAFR AnnualFinancial QMFinancial DisclosureFailure Budget
	
	save "${Data}/tempcd_`i'.dta", replace
	
}

use "${Data}/tempcd_2009.dta", clear
forvalues i=2010(1)2014{
	append using "${Data}/tempcd_`i'.dta"
}


saveold "${Data}/cd2009to2014.dta", replace version(12)
shell rm "${Data}/temp"*






/******************************************************************************/

* STEP 2: DROP DUPLICATE ANNUAL FINANCIAL STATEMENTS

/******************************************************************************/


use "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\Timeliness\cd2009to2014.dta", clear

sort cusip9 date
duplicates tag cusip9 date, gen(tag)

bysort cusip9 date: egen sumcafr=sum(CAFR)
bysort cusip9 date: egen sumannual=sum( AnnualFinancial )

drop if tag>0 & sumcafr==1 & sumannual==1 & AnnualFinancial==1

saveold cd2009to2014_20180725, replace version(12)






/******************************************************************************/

* STEP 3: CREATE FILE TO COUNT NUMBER OF MATERIAL EVENTS

/******************************************************************************/


cd "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\Timeliness"

forvalues i=2009(1)2014{

	use "cd`i'.dta", clear
	
	sort submissionidentifier cusip9 eventdisclosurecat
	drop if eventdisclosurecat == "NA" 
	
	* Create date
	replace submissiondatetime = trim(submissiondatetime)
	gen date = substr(submissiondatetime, 1, 10)
	
	keep submissionidentifier cusip9 eventdisclosurecat submissiondatetime endingdate periodtype date
		
	save "tempcd_`i'.dta", replace
}

use "tempcd_2009.dta", clear
forvalues i=2010(1)2014{
	append using "tempcd_`i'.dta"
}


saveold "events2009to2014.dta", replace version(12)

























/*


* Match financial statement sample cd2009to2014 (produced by FinancialDisclosure.do)
* with the regression sample




*/



global rawdata "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/Timeliness"
global data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Analysis"






********************************************************************************
********************************************************************************

* Regression sample from gsz_20200313.do

********************************************************************************
********************************************************************************

use "${data}/sample_20190530.dta", clear

sort cusip_6 year
egen cusip_id = group(cusip_6)
egen state_id = group(state)
xtset cusip_id year


* ISSUE INDICATOR
gen issue = log_amountofissue >0


* CREATE UNDERWRITER VARIABLES
capture drop leadmng*
sort cusip_6 year
merge 1:1 cusip_6 year using tempunderwriter, keep (1 3) nogen // tempunderwriter is a balanced panel by cusip_6 year
gen missuw = leadmng == ""

foreach var of varlist leadmng leadmng1{
	replace `var' = "NA" if missuw == 1
}
replace mktshr = 0  if missuw == 1
egen uwid1 = group(leadmng1)


* ISSUER TYPE FIXED EFFECTS
egen issuerdscrp_pre_id = group(issuerdscrp_pre)


* SECTOR FIXED EFFECTS
replace uop1_pre="NA" if uop1_pre==""
egen uop1_pre_id = group(uop1_pre)


 
* IMPORT LAGGED MACRO VARIABLES
sort state year
merge m:1 state year using "${data}/tempmacro.dta", keep(1 3) nogen

gen gsp_avg_sc=gsp_avg/10000
gen pci_avg_sc=pci_avg/100
gen hpi_avg_sc=hpi_avg/100








/***********************************************/
* TABLE 3 - MAIN RESULTS
/***********************************************/

capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre ==1 & insurance_pre<1

capture drop samp1
xtreg financials_all treated_post post log_amountofissue call go gsp_avg_sc pci_avg_sc hpi_avg_sc unemploy_avg if sample==1
gen samp1=1 if e(sample)

keep if samp1==1
keep cusip_6
duplicates drop cusip_6, force

sort cusip_6
save "${rawdata}/tempregsample.dta", replace

























********************************************************************************
********************************************************************************

* Load linking table

********************************************************************************
********************************************************************************

import delimited "/Volumes/Frank's Passport for Mac Files/msrb_disclosure/SubmissionFileLink2009.csv", encoding(ISO-8859-1) clear
forvalues i=2010(1)2015{
	preserve 
	import delimited "/Volumes/Frank's Passport for Mac Files/msrb_disclosure/SubmissionFileLink`i'.csv", encoding(ISO-8859-1) clear
	save "${rawdata}/tempSubmissionFileLink`i'", replace
	restore
	append using "${rawdata}/tempSubmissionFileLink`i'"
}
shell rm "${rawdata}/tempSubmissionFileLink"*
capture erase "${rawdata}/tempSubmissionFileLink"*

sort submissionidentifier fileidentifier year month submissiontransactiondatetime
by submissionidentifier fileidentifier: gen nvals=_n==1
keep if nvals ==1
drop nvals
keep submissionidentifier fileidentifier year month
save "${rawdata}/SubmissionFileLink.dta", replace




















********************************************************************************
********************************************************************************


* Merge linking table with regression sample

********************************************************************************
********************************************************************************

use "${rawdata}/cd2009to2014.dta", clear

gen cusip_6 = substr(cusip9, 1, 6)
merge m:1 cusip_6 using  "${rawdata}/tempregsample.dta", keep(3)
duplicates drop submissionidentifier, force

keep submissionidentifier
sort submissionidentifier

merge 1:m submissionidentifier using "${rawdata}/SubmissionFileLink.dta", nogen keep(3)
gen month1 = string(month)
replace month1 = "0" + month1 if strlen(month1)==1

keep if year<=2013 | (year ==2014 & month<=6) 
saveold "${rawdata}/SubmissionFileLinkRegSample.dta", replace version(12)
shell rm "${rawdata}/tempregsample.dta"

capture erase "${rawdata}/tempregsample.dta"















clear all 
set more off 
set matsize 750


global author "/Users/szho/Dropbox/My Projects/Municipal Disclosure" 
cd "${author}/Analysis/Round 3"





/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   CREATE LAGGED MACRO VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

/*

* This file computes the annual macro variables by states and the outputs are later
* merged to our regression sample to compute the lagged macro variables. 


Input files:
	- Macro data in the folder: RawData/Economic_Characteristics

	
Output file:
	- By year measure of economic variables
	
*/

global macrolag "${author}/Rawdata/Economic_Characteristics"


preserve

clear

* GSP
import delimited "${macrolag}/GSP/GSP20160129.csv", encoding(ISO-8859-1)clear
sort state year
save tempgsp, replace

* PCI
import delimited "${macrolag}/Personal_Income/percapitaIncome20170909.csv", encoding(ISO-8859-1)clear
sort state year
save temppci, replace

* HPI
import excel "${macrolag}/HPI/HPI_PO_state.xls", clear first
sort state yr qtr
by state yr: egen hpi_avg = mean(index_sa)
rename yr year
keep state year hpi_avg
duplicates drop state year, force
sort state year
save temphpi, replace

* UNEMP
import delimited "${macrolag}/Unemployment/Unemploy20160908.csv", encoding(ISO-8859-1)clear
sort state year
by state year: egen unemploy_avg = mean(unemploy)
keep state year unemploy_avg
duplicates drop state year, force
sort state year

* Combine outputs
merge 1:1 state year using temphpi
keep if _merge == 3
drop _merge

merge 1:1 state year using temppci
keep if _merge == 3
drop _merge

merge 1:1 state year using tempgsp
keep if _merge == 3
drop _merge

rename gsp gsp_avg
rename percapitaincome pci_avg

replace year = year +1 
* so that year 2008 is matched to year 2009 for our data
sort state year

winsor2 unemploy_avg, replace cuts(1 99)
winsor2 gsp_avg, replace cuts(1 99)
winsor2 pci_avg, replace cuts(1 99)
winsor2 hpi_avg, replace cuts(1 99)

save tempmacro, replace

restore







/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   IMPORT 2NDARY MARKET TRADE VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/


/*
	- RetailTrades20190530, number and volume of trades at the bond-year level, created by 05_retail_trades.sas 
*/

* INDICATOR FOR THE EXISTENCE OF SECONDARY MARKET TRADE in 2009

preserve

use RetailTrades20190530, clear
gen num = inst1_num_2nd + inst2_num_2nd + retail1_num_2nd + retail2_num_2nd
keep if num > 1 & year ==2009
gen trade1=1
keep cusip_6 trade1
duplicates drop
sort cusip_6
save XSretail1, replace

restore



* CHANGES IN INVESTOR BASE VARIABLES

preserve
use RetailTrades20190530, clear 
sort cusip9 year

sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}
gen pct_retail_num_2nd = (retail1_num_2nd_t + retail2_num_2nd_t) / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
gen pct_inst_num_2nd   = (inst2_num_2nd_t)  / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
keep cusip_6 year pct_retail_num_2nd pct_inst_num_2nd
duplicates drop
sort cusip_6 year

save PctTrade, replace

restore



* For alternative control group:

preserve
use RetailTradesAltControl20190530, clear
sort cusip9 year

* Aggregate trading at the issuer level
sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}
gen pct_retail_num_2nd = (retail1_num_2nd_t + retail2_num_2nd_t) / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
gen pct_inst_num_2nd   = (inst2_num_2nd_t)  / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
keep cusip_6 year pct_retail_num_2nd pct_inst_num_2nd
duplicates drop
sort cusip_6 year
rename pct_retail_num_2nd pct_retail_num_2nd_alt
rename pct_inst_num_2nd pct_inst_num_2nd_alt

save PctTrade_altcontrol, replace
restore



preserve

use RetailTrades20190530, clear 

* Aggregate total number of trades at the issuer-year level:

sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}

gen total_trade_2nd = (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)

keep cusip_6 year total_trade_2nd
duplicates drop cusip_6 year, force
sort cusip_6 year

sum total_trade_2nd,d

save TotalTrade, replace

restore














/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   CREATE UNDERWRITER VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/


/*
 
Input file:
		- Underwriters20190530.csv, created by 06_underwriters.R, which is at the cusip_6 by year level. 
		# 1. For each underwriter and year, construct the amount of debt issuance by each underwriter
		# as a percentage of total debt issuance in that year. 	
		# 2. If multiple underwriters are used in a given issue, then assign the issuer's underwriter market share
		# with the largest market share. 
		# For example, for a cusip_6 issuer and 2010, there might be underwriters A, B, C and A has the largest market share in 2010. 
		# We assign the issuer's underwriter market share as A's market share. 
		
*/


* DEFINE UNDERWRITER FE 

preserve

clear

import delimited "Underwriters20190530.csv", encoding(ISO-8859-1) clear

drop v1
duplicates report cusip_6 year
* sanity check, should be zero

egen cusipid = group(cusip_6)
xtset cusipid year

tsfill,full
tab year
count if cusipid == .
* 0

* Fill in data of the missing year
sort cusipid year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist mktshr leadmng leadmng1 numstate{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

gsort cusipid -year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist mktshr leadmng leadmng1 numstate{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

* Check if all non-missing
foreach var of varlist cusip_6 mktshr leadmng leadmng1 numstate{
	count if missing(`var')
}

drop cusipid
sort cusip_6 year
save tempunderwriter, replace

restore



* DEFINE UNDERWRITER XS VARIABLES
preserve

clear

import delimited "Underwriters_2_20190530.csv", encoding(ISO-8859-1) clear

drop v1
duplicates report cusip_6 year
* sanity check, should be zero

egen cusipid = group(cusip_6)
xtset cusipid year

tsfill,full
tab year
count if cusipid == .
* 0

* Fill in data of the missing year
sort cusipid year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

gsort cusipid -year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

* Check if all non-missing
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	count if missing(`var')
}

drop cusipid
sort cusip_6 year
save tempunderwriter_20190530, replace

restore










/******************************************************************************/
/******************************************************************************/
/******************************************************************************/




* Timeliness




/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

global Timeliness  "${author}/Rawdata/Timeliness"

preserve

use "${Timeliness}/cd2009to2014.dta", clear 
// created by 03_disclosures.do 
// Includes only financial disclosures

* Submission date
gen year=substr(date, 1,4)
gen month=substr(date,6,2)
gen day=substr(date,9,2)
destring year month day, replace force
gen date1 = mdy(month, day, year)
keep if date1 !=.

* Fiscal year end date, benchmark year
drop year month day
gen year=substr(endingdate, 1,4)
gen month=substr(endingdate,6,2)
gen day=substr(endingdate,9,2)
destring year month day, replace force
gen fye=mdy(month,day,year)
keep if fye !=.

* Timeliness measure
gen timeliness = date1 - fye // larger, less timely!!!
gen cusip_6 = substr(cusip9,1,6)
keep if cusip_6 !=""
gen year1= year
forvalues i=2010(1)2014{
	replace year = `i'-1 if year1 == `i' & month<=6
}
drop year1 month day
keep if year>=2009 & year<=2013

sort cusip_6 year
by cusip_6 year: egen timeliness2 = min(timeliness) // select the most timely disclosures
duplicates drop cusip_6 year, force
keep cusip_6 year timeliness2

saveold "timeliness2_20190304.dta", replace version(12)

restore












/* COMPUTE AVERAGE ISSUER-LEVEL CREDIT RATING:*/

preserve

use "sample_20190530.dta", clear
keep cusip_6 year treated state moody_rated_pre sp_rated_pre
sort cusip_6 year treated state moody_rated_pre sp_rated_pre
by cusip_6: gen nvals = _n==1
keep if nvals ==1
drop nvals
save "tempsample0.dta", replace

restore

preserve

use "sample_20190530.dta", clear
capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre == 1 & insurance_pre<1
keep if sample ==1
keep cusip_6 year
save "tempratingagency1.dta", replace

restore


global rawdata "${author}/Rawdata/SDC"
use "${rawdata}/SDC_BondSaleDate_19902014.dta", clear

* Sale date
gen year = substr(saledate, 7,2) 
gen month = substr(saledate, 1,2)
gen day = substr(saledate, 4,2)

destring year, replace
destring month, replace
destring day, replace
replace year = 2000+year if year <=14
replace year = 1900+year if year >=90 & year <=99 & year !=.

tab year
tab month
tab day
count // 1,564,258

drop saledate
gen saledate = mdy(month, day, year)
format saledate %td

gen year1 = year
replace year1 = year - 1 if month <=6

drop if year <= 1990 & month <=6
drop if year >=2014 & month>=7
tab year1
drop year
rename year1 year


* Rating agency
replace ratingagency = lower(ratingagency)
tab ratingagency

gen moody_rated = strpos(ratingagency, "moody")>0
gen sp_rated = strpos(ratingagency, "sp")>0
gen fitch_rated = strpos(ratingagency, "fitch")>0
count if moody_rated == 0 & sp_rated == 0 & fitch_rated == 0 & rateddealflag == "Yes" // 0
gen rated = rateddealflag == "Yes"


* Moodys long term underlying rating
gen moody_rate_scale = .
replace moody_rate_scale = 9 if strpos(moodylongtermunderlying, "Aaa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 8 if strpos(moodylongtermunderlying, "Aa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 7 if strpos(moodylongtermunderlying, "A")>0 & moody_rate_scale ==.
replace moody_rate_scale = 6 if strpos(moodylongtermunderlying, "Baa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 5 if strpos(moodylongtermunderlying, "Ba")>0 & moody_rate_scale ==.
replace moody_rate_scale = 4 if strpos(moodylongtermunderlying, "B")>0 & moody_rate_scale ==.
replace moody_rate_scale = 3 if strpos(moodylongtermunderlying, "Caa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 2 if strpos(moodylongtermunderlying, "Ca")>0 & moody_rate_scale ==.
replace moody_rate_scale = 1 if strpos(moodylongtermunderlying, "C")>0 & moody_rate_scale ==.
replace moody_rate_scale = 0 if strpos(moodylongtermunderlying, "D")>0 & moody_rate_scale ==.
replace moody_rate_scale = 0 if strpos(moodylongtermunderlying, "E")>0 & moody_rate_scale ==.
tab moody_rate_scale 

gen sp_rate_scale = .
replace sp_rate_scale = 9 if strpos(splongtermunderlying, "AAA")>0 & sp_rate_scale ==.
replace sp_rate_scale = 8 if strpos(splongtermunderlying, "AA")>0 & sp_rate_scale ==.
replace sp_rate_scale = 7 if strpos(splongtermunderlying, "A")>0 & sp_rate_scale ==.
replace sp_rate_scale = 6 if strpos(splongtermunderlying, "BBB")>0 & sp_rate_scale ==.
replace sp_rate_scale = 5 if strpos(splongtermunderlying, "BB")>0 & sp_rate_scale ==.
replace sp_rate_scale = 4 if strpos(splongtermunderlying, "B")>0 & sp_rate_scale ==.
replace sp_rate_scale = 3 if strpos(splongtermunderlying, "CCC")>0 & sp_rate_scale ==.
replace sp_rate_scale = 2 if strpos(splongtermunderlying, "CC")>0 & sp_rate_scale ==.
replace sp_rate_scale = 1 if strpos(splongtermunderlying, "C")>0 & sp_rate_scale ==.
replace sp_rate_scale = 0 if strpos(splongtermunderlying, "D")>0 & sp_rate_scale ==.
replace sp_rate_scale = 0 if strpos(splongtermunderlying, "E")>0 & sp_rate_scale ==.

gen fitch_rate_scale = .
replace fitch_rate_scale = 9 if strpos(fitchlongtermunderlying, "AAA")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 8 if strpos(fitchlongtermunderlying, "AA")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 7 if strpos(fitchlongtermunderlying, "A")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 6 if strpos(fitchlongtermunderlying, "BBB")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 5 if strpos(fitchlongtermunderlying, "BB")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 4 if strpos(fitchlongtermunderlying, "B")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 3 if strpos(fitchlongtermunderlying, "CCC")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 2 if strpos(fitchlongtermunderlying, "CC")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 1 if strpos(fitchlongtermunderlying, "C")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 0 if strpos(fitchlongtermunderlying, "D")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 0 if strpos(fitchlongtermunderlying, "E")>0 & fitch_rate_scale ==.

egen rating = rowmean(sp_rate_scale fitch_rate_scale moody_rate_scale) // command ignores missing value
tab rating

cap drop state 
gen cusip_6 = substr(cusip1, 1,6)
merge m:1 cusip_6 using "tempsample0.dta", nogen keep(3)
sort cusip1 rating moody_rated sp_rated fitch_rated treated amount creditenhancer year state moody_rated_pre sp_rated_pre

merge m:1 cusip_6 year using "tempratingagency1.dta"
drop if _merge ==2
bys cusip_6: egen nvals = mean(_merge == 3)
keep if nvals >0
drop _merge nvals

keep cusip1 cusip_6 rating moody_rated sp_rated fitch_rated treated amount creditenhancer rated year state moody_rated_pre sp_rated_pre
sort cusip1 rating moody_rated sp_rated fitch_rated treated amount creditenhancer year state moody_rated_pre sp_rated_pre
by cusip1: gen nvals = _n==1
keep if nvals ==1
drop nvals

save "tempsdc.dta", replace // bond characteristics at the bond level, also used for parallel trends for yield. 






* Compute rating at issuer-year level. 
use "tempsdc.dta", clear

keep cusip_6 year rating
sort cusip_6 year
by cusip_6 year: egen avgrating = max(rating)
keep if avgrating !=.
duplicates drop cusip_6 year, force


preserve

use sample_20190530, clear
keep cusip_6 year
sort cusip_6 year
save tempsample1, replace

restore

merge 1:1 cusip_6 year using tempsample1 // to get back to a balanced panel
sort cusip_6 year
replace avgrating = avgrating[_n-1] if cusip_6 == cusip_6[_n-1] & avgrating ==.
keep cusip_6 year avgrating 

saveold IssuerRating20190530, replace version(12)

 
preserve
use IssuerRating20190530, clear
keep if year==2009
save avgrating2009, replace

restore 











/* Parallel trends */


use "sdc_issuer_year20190530.dta", clear // created by 02_sdc_processing.do, unique issuer-year level data

keep cusip_6 year moody_rated sp_rated fitch_rated call go amountofissue
egen cusipid = group(cusip_6)

xtset cusipid year
tsfill, full
sort cusipid year
foreach var of varlist moody_rated sp_rated fitch_rated{
	replace `var' = `var'[_n-1] if `var' ==. & `var'[_n-1] !=. & cusipid == cusipid[_n-1]
	rename `var' `var'_issuer
}
replace cusip_6 = cusip_6[_n-1] if cusipid == cusipid[_n-1] & cusip_6[_n-1] !=""
drop if cusip_6 ==""
sort cusip_6 year

replace moody_rated_issuer = moody_rated >0 & moody_rated !=.
replace sp_rated_issuer = sp_rated >0 & sp_rated !=.
replace fitch_rated_issuer = fitch_rated >0 & fitch_rated !=.

gen log_amountofissue = log(1 + amountofissue)
replace log_amountofissue = 0 if log_amountofissue ==.
gen call_issuer = call >0 & call !=.
gen go_issuer = go >0 & go !=.

keep cusip_6 year moody_rated_issuer sp_rated_issuer fitch_rated_issuer call_issuer go_issuer log_amountofissue
save "temptrends_rating.dta", replace










/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   SAMPLE TO GENERATE TABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/



/***********************************************/

global author "/Users/szho/Dropbox/My Projects/Municipal Disclosure" 


cd "${author}/Analysis/Round 3"
global Timeliness  "${author}/Rawdata/Timeliness" 

* CHOOSE A CLUSTERING DIMENSION
global clustervar cusip_id
// global clustervar state_id



use sample_20190530.dta, clear

sort cusip_6 year
egen cusip_id = group(cusip_6)
egen state_id = group(state)
xtset cusip_id year

* ISSUE INDICATOR
gen issue = log_amountofissue >0


* CREATE UNDERWRITER VARIABLES
capture drop leadmng*
sort cusip_6 year
merge 1:1 cusip_6 year using tempunderwriter, keep (1 3) nogen // tempunderwriter is a balanced panel by cusip_6 year
gen missuw = leadmng == ""

foreach var of varlist leadmng leadmng1{
	replace `var' = "NA" if missuw == 1
}
replace mktshr = 0  if missuw == 1
egen uwid1 = group(leadmng1)


* ISSUER TYPE FIXED EFFECTS
egen issuerdscrp_pre_id = group(issuerdscrp_pre)


* SECTOR FIXED EFFECTS
replace uop1_pre="NA" if uop1_pre==""
egen uop1_pre_id = group(uop1_pre)


* PRE-PERIOD ISSUER RATING FIXED EFFECTS
merge m:1 cusip_6 year using avgrating2009, keep(1 3) nogen
bysort cusip_6 (year): egen avgrating_pre=sum(avgrating)
replace avgrating_pre=. if avgrating_pre==0 & avgrating!=0
replace avgrating_pre=-1 if missing(avgrating_pre) // create -1 group for missing longtermratings
egen avgrating_pre_id = group(avgrating_pre)
drop avgrating

 
* IMPORT LAGGED MACRO VARIABLES
sort state year
merge m:1 state year using tempmacro, keep(1 3) nogen
gen gsp_avg_sc=gsp_avg/10000
gen pci_avg_sc=pci_avg/100
gen hpi_avg_sc=hpi_avg/100


* STATE BY YEAR FIXED EFFECTS
gen stateXyear = year*100+state_id


* SAMPLE FOR OUR ANALYSES
capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre ==1 & insurance_pre<1

capture drop samp1
xtreg financials_all treated_post post log_amountofissue call go  gsp_avg_sc pci_avg_sc hpi_avg_sc unemploy_avg if sample==1
gen samp1=1 if e(sample)
tab samp1

















/******************************************************************************/

/* This file cleans SDC data. */
/*
Date: 2020.03.13


/******************************/		
Input files:
/******************************/		

	- (1) /Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/SDC/SDC_IssuerSaleDate_19902014.csv.
	
cusip_6	saledate	county	issuer	ratingagency
729773	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729778	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729780	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729783	01/02/90	Hennepin	Plymouth City-Minnesota	SP
864048	01/02/90	Door	Sturgeon Bay-Wisconsin	
864056	01/02/90	Door	Sturgeon Bay-Wisconsin	
944048	01/02/90	Kosciusko	Wawasee Comm School Corp	
944050	01/02/90	Kosciusko	Wawasee Comm School Corp	
947644	01/02/90	Weber	Weber Co-Utah	
947648	01/02/90	Weber	Weber Co-Utah	
947651	01/02/90	Weber	Weber Co-Utah	
947659	01/02/90	Weber	Weber Co-Utah	
004590	01/03/90	Franklin-Hardin	Ackley City-Iowa	
004606	01/03/90	Franklin-Hardin	Ackley City-Iowa	
004613	01/03/90	Franklin-Hardin	Ackley City-Iowa	
048339	01/03/90	Atlantic	Atlantic City-New Jersey	
048343	01/03/90	Atlantic	Atlantic City-New Jersey	
048339	01/03/90	Atlantic	Atlantic City-New Jersey	MOODY;SP
048343	01/03/90	Atlantic	Atlantic City-New Jersey	MOODY;SP
	
	
*/
/******************************************************************************/

clear all 
set more off 
set matsize 750

// cd "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\SDC"
cd "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/SDC"
global data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Analysis/Round 2 new"



***********************************************************************/
/* SDC data cleaning */
**********************************************************************/



use SDC_IssuerSaleDate_19902014, clear // created by 01_sdc_issuer.R


* Sale date
gen year = substr(saledate, 7,2) 
gen month = substr(saledate, 1,2)
gen day = substr(saledate, 4,2)

destring year, replace
destring month, replace
destring day, replace
replace year = 2000+year if year <=14
replace year = 1900+year if year >=90 & year <=99 & year !=.

tab year
tab month
tab day
count 
*857,323

drop saledate
gen saledate = mdy(month, day, year)
format saledate %td

* Ratinng agency
replace ratingagency = lower(ratingagency)
tab ratingagency

gen moody_rated = strpos(ratingagency, "moody")>0
gen sp_rated = strpos(ratingagency, "sp")>0
gen fitch_rated = strpos(ratingagency, "fitch")>0
count if moody_rated == 0 & sp_rated == 0 & fitch_rated == 0 & rateddealflag == "Yes" 
*0

gen rated = rateddealflag == "Yes"

* Credit enhancement
gen insurance = creditenhancetype != ""

* Callable
gen call = callable == "Yes"
tab call

* Go vs reveneu
gen go = security == "GO"


* amount of issue
destring amountofissue, replace force 
*forced is used because missing amount is denoted by NA.


* Maturity

gen yearm = substr(maxmaturity, 1,4)
gen monthm = substr(maxmaturity, 6,2)
gen daym = substr(maxmaturity,9,2)
destring monthm daym, replace
destring yearm, replace force
tab yearm
gen max_maturity = mdy(monthm, daym, yearm)
replace max_maturity = . if maxmaturity == "NA" | yearm <1990
format max_maturity %td
drop yearm monthm daym




* Underwriter
gen underwriter = leadmng 
*857,323










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
* Generate issuer-year level data
/**********************************************************************/

preserve

gen year1 = year
replace year1 = year - 1 if month <=6

drop if year <= 1990 & month <=6
drop if year >=2014 & month>=7
tab year1
drop year
rename year1 year

* Compute average issuer-year rating, insurance, call, go
sort cusip_6 year

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6 year: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6 year: egen first_offer_date = min(saledate)
by cusip_6 year: egen last_offer_date = max(saledate)
by cusip_6 year: gen num_offer = _N
format first_offer_date last_offer_date %td
by cusip_6 year: egen nvals = total(amountofissue)
gen amountofissue0=amountofissue
replace amountofissue = nvals
drop nvals

* Max maturity

by cusip_6 year: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals
format max_maturity %td



* Drop duplicates
* Keep issuers that issue the highest amount of debt and highest frequency of debt
gsort cusip_6 year issuerdscrp -saledate state uop1
by cusip_6 year issuerdscrp: egen nvals = total(amountofissue0) 
** total amount
by cusip_6 year issuerdscrp: gen nvals1 = _N 
** total number
by cusip_6 year issuerdscrp: gen nvals0 =_n ==1

keep if nvals0 == 1
drop nvals0
gsort cusip_6 year -saledate
by cusip_6 year: egen nvals2 = max(nvals) 
** max total amount of debt by cusip_6 year and issuerdscrp
keep if nvals == nvals2 
** keep issuers that issue the highest total amount of debt.
duplicates report cusip_6 year


by cusip_6 year: egen nvals3 = max(nvals1)
keep if nvals3 == nvals1
duplicates report cusip_6 year


sort cusip_6 year state uop1 issuerdscrp
by cusip_6 year: gen issuerdscrp1 = issuerdscrp[_n+1]
sort cusip_6 year 



keep cusip_6 year moody_rated rated sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state amountofissue issuerdscrp issuerdscrp1 uop1 underwriter issuer
sort cusip_6 year state uop1 issuerdscrp issuerdscrp1
cap drop nvals*
by cusip_6 year: gen nvals = _n==1
keep if nvals == 1
drop nvals

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable rated "issuer is rated"
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"
		label variable amountofissue "total annual issuance amount"
		label variable uop1 "purpose"
		label variable underwriter "underwriter"
		label variable issuer "issuer name"

count 
* 387,174 issuer-year


saveold "${data}/sdc_issuer_year20190530.dta", replace version(12)
restore
















/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/* Issuer level: debt outstanding */
/**********************************************************************/


preserve

keep if saledate <= mdy(06,30,2010) & max_maturity >= mdy(06,30,2010) & max_maturity !=. 
keep if rated ==1
sort cusip_6

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6: egen first_offer_date = min(saledate)
by cusip_6: egen last_offer_date = max(saledate)
by cusip_6: gen num_offer = _N
format first_offer_date last_offer_date %td

* Max maturity

by cusip_6: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals

duplicates drop cusip_6, force
keep cusip_6 moody_rated  sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"

count 
*39,158

saveold "${data}/sdc_debtoustanding_20190530.dta", replace version(12) // only sample itself is used. 

restore





/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/* access market */


preserve

keep if saledate <= mdy(06,30,2010) & saledate >= mdy(07,01,2006) 
sort cusip_6

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6: egen first_offer_date = min(saledate)
by cusip_6: egen last_offer_date = max(saledate)
by cusip_6: gen num_offer = _N
format first_offer_date last_offer_date %td
by cusip_6: egen nvals = total(amountofissue)
gen amountofissue0=amountofissue
replace amountofissue = nvals
drop nvals

* Max maturity

by cusip_6: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals

* Drop duplicates
* Keep issuers that issue the highest amount of debt and highest frequency of debt
gsort cusip_6 issuerdscrp -saledate state uop1 issuer
by cusip_6 issuerdscrp: egen nvals = total(amountofissue0) 
** total amount
by cusip_6 issuerdscrp: gen nvals1 = _N 
** total number
by cusip_6 issuerdscrp: gen nvals0 =_n ==1

keep if nvals0 == 1
drop nvals0
gsort cusip_6 issuerdscrp -saledate state uop1 issuer
by cusip_6: egen nvals2 = max(nvals) 
** max total amount of debt by cusip_6 and issuerdscrp
keep if nvals == nvals2 
** keep issuers that issue the highest total amount of debt.
duplicates report cusip_6
/*
--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |        32362             0
        2 |           18             9
--------------------------------------
*/

by cusip_6: egen nvals3 = max(nvals1)
keep if nvals3 == nvals1
duplicates report cusip_6
/*
--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |        32362             0
        2 |           18             9
--------------------------------------
*/
sort cusip_6 year state uop1 issuerdscrp issuer
by cusip_6 (year state uop1 issuerdscrp issuer): gen issuerdscrp1 = issuerdscrp[_n+1]
cap drop nvals
by cusip_6: gen nvals = _n==1
keep if nvals ==1
drop nvals


keep cusip_6 rated moody_rated sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state issuerdscrp issuerdscrp1 amountofissue uop1  underwriter issuer

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"
		label variable amountofissue "total annual issuance amount"

count 
*32,371


saveold "${data}/sdc_accessmarket_20190530.dta", replace version(12)

restore










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

* Issue level

preserve

keep if saledate <= mdy(06,30,2010) & saledate >= mdy(07,01,2006) 
sort cusip_6 saledate 
by cusip_6 saledate: gen nvals =_n==1
keep if nvals ==1
drop nvals

gen issue_id = _n
keep cusip_6 saledate year

saveold "${data}/sdc_issuereg_20190304.dta", replace version(12)

restore









/******************************************************************************/

/*


This file creates the data for financial disclosures. 
Date: 2020.03.13

	
*/


global Data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/Timeliness"
global Data "/Users/szho/Documents/Temp"


* Change formats
forvalues i=2009(1)2014{
	use "${Data}/cd`i'.dta", clear
	saveold "${Data}/cd`i'.dta", replace version(12)
}


























/******************************************************************************/

* STEP 1: CREATE FINANCIAL DISCLOSURE DATA

/******************************************************************************/


* Other disclosures that are CAFR

import excel "${Data}/OtherVoluntaryFinancialDisclosures.xlsx", sheet("Sheet1") firstrow clear
keep othervoluntarydisclosure CAFR
keep if CAFR == 1
sort othervoluntarydisclosure
duplicates drop othervoluntarydisclosure, force
save "${Data}/tempCAFR.dta", replace




* Create disclosure data

forvalues i=2009(1)2014{

	use "${Data}/cd`i'.dta", clear
	
	sort submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure submissiondatetime
	drop if financialdisclosurecat == "NA" // drop non-financial disclosures
	duplicates drop submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure, force // drop duplicates 
	
	gen other = financialdisclosurecat == "OtherFinancialVoluntaryInformation"
	by submissionidentifier: egen nvals = sd(other)
	drop if other == 1 & nvals >0 & nvals !=. // drop footnote disclosures 
	drop nvals other
	
	
	keep submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure submissiondatetime endingdate periodtype
		
	
	* Create disclosure types
	
	gen CAFR = financialdisclosurecat == "AuditedFinancialStatementsOrCAFR15c212"
	gen AnnualFinancial =  financialdisclosurecat == "AnnualFinancialInformationOperatingData15c212"
	gen QMFinancial = financialdisclosurecat == "QuarterlyMonthlyFinancialInformation" | financialdisclosurecat == "InterimAdditionalFinancialInformationOperatingData"
	gen DisclosureFailure = financialdisclosurecat == "FailureToProvideAnnualFinancialInformationAsRequired15c212"
	gen Budget = financialdisclosurecat == "Budget" 

	
	* Create date
	replace submissiondatetime = trim(submissiondatetime)
	gen date = substr(submissiondatetime, 1, 10)
	
	
	keep submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure endingdate periodtype date CAFR AnnualFinancial QMFinancial DisclosureFailure Budget
	
	save "${Data}/tempcd_`i'.dta", replace
	
}

use "${Data}/tempcd_2009.dta", clear
forvalues i=2010(1)2014{
	append using "${Data}/tempcd_`i'.dta"
}


saveold "${Data}/cd2009to2014.dta", replace version(12)
shell rm "${Data}/temp"*






/******************************************************************************/

* STEP 2: DROP DUPLICATE ANNUAL FINANCIAL STATEMENTS

/******************************************************************************/


use "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\Timeliness\cd2009to2014.dta", clear

sort cusip9 date
duplicates tag cusip9 date, gen(tag)

bysort cusip9 date: egen sumcafr=sum(CAFR)
bysort cusip9 date: egen sumannual=sum( AnnualFinancial )

drop if tag>0 & sumcafr==1 & sumannual==1 & AnnualFinancial==1

saveold cd2009to2014_20180725, replace version(12)






/******************************************************************************/

* STEP 3: CREATE FILE TO COUNT NUMBER OF MATERIAL EVENTS

/******************************************************************************/


cd "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\Timeliness"

forvalues i=2009(1)2014{

	use "cd`i'.dta", clear
	
	sort submissionidentifier cusip9 eventdisclosurecat
	drop if eventdisclosurecat == "NA" 
	
	* Create date
	replace submissiondatetime = trim(submissiondatetime)
	gen date = substr(submissiondatetime, 1, 10)
	
	keep submissionidentifier cusip9 eventdisclosurecat submissiondatetime endingdate periodtype date
		
	save "tempcd_`i'.dta", replace
}

use "tempcd_2009.dta", clear
forvalues i=2010(1)2014{
	append using "tempcd_`i'.dta"
}


saveold "events2009to2014.dta", replace version(12)

























/*


* Match financial statement sample cd2009to2014 (produced by FinancialDisclosure.do)
* with the regression sample




*/



global rawdata "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/Timeliness"
global data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Analysis"






********************************************************************************
********************************************************************************

* Regression sample from gsz_20200313.do

********************************************************************************
********************************************************************************

use "${data}/sample_20190530.dta", clear

sort cusip_6 year
egen cusip_id = group(cusip_6)
egen state_id = group(state)
xtset cusip_id year


* ISSUE INDICATOR
gen issue = log_amountofissue >0


* CREATE UNDERWRITER VARIABLES
capture drop leadmng*
sort cusip_6 year
merge 1:1 cusip_6 year using tempunderwriter, keep (1 3) nogen // tempunderwriter is a balanced panel by cusip_6 year
gen missuw = leadmng == ""

foreach var of varlist leadmng leadmng1{
	replace `var' = "NA" if missuw == 1
}
replace mktshr = 0  if missuw == 1
egen uwid1 = group(leadmng1)


* ISSUER TYPE FIXED EFFECTS
egen issuerdscrp_pre_id = group(issuerdscrp_pre)


* SECTOR FIXED EFFECTS
replace uop1_pre="NA" if uop1_pre==""
egen uop1_pre_id = group(uop1_pre)


 
* IMPORT LAGGED MACRO VARIABLES
sort state year
merge m:1 state year using "${data}/tempmacro.dta", keep(1 3) nogen

gen gsp_avg_sc=gsp_avg/10000
gen pci_avg_sc=pci_avg/100
gen hpi_avg_sc=hpi_avg/100








/***********************************************/
* TABLE 3 - MAIN RESULTS
/***********************************************/

capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre ==1 & insurance_pre<1

capture drop samp1
xtreg financials_all treated_post post log_amountofissue call go gsp_avg_sc pci_avg_sc hpi_avg_sc unemploy_avg if sample==1
gen samp1=1 if e(sample)

keep if samp1==1
keep cusip_6
duplicates drop cusip_6, force

sort cusip_6
save "${rawdata}/tempregsample.dta", replace

























********************************************************************************
********************************************************************************

* Load linking table

********************************************************************************
********************************************************************************

import delimited "/Volumes/Frank's Passport for Mac Files/msrb_disclosure/SubmissionFileLink2009.csv", encoding(ISO-8859-1) clear
forvalues i=2010(1)2015{
	preserve 
	import delimited "/Volumes/Frank's Passport for Mac Files/msrb_disclosure/SubmissionFileLink`i'.csv", encoding(ISO-8859-1) clear
	save "${rawdata}/tempSubmissionFileLink`i'", replace
	restore
	append using "${rawdata}/tempSubmissionFileLink`i'"
}
shell rm "${rawdata}/tempSubmissionFileLink"*
capture erase "${rawdata}/tempSubmissionFileLink"*

sort submissionidentifier fileidentifier year month submissiontransactiondatetime
by submissionidentifier fileidentifier: gen nvals=_n==1
keep if nvals ==1
drop nvals
keep submissionidentifier fileidentifier year month
save "${rawdata}/SubmissionFileLink.dta", replace




















********************************************************************************
********************************************************************************


* Merge linking table with regression sample

********************************************************************************
********************************************************************************

use "${rawdata}/cd2009to2014.dta", clear

gen cusip_6 = substr(cusip9, 1, 6)
merge m:1 cusip_6 using  "${rawdata}/tempregsample.dta", keep(3)
duplicates drop submissionidentifier, force

keep submissionidentifier
sort submissionidentifier

merge 1:m submissionidentifier using "${rawdata}/SubmissionFileLink.dta", nogen keep(3)
gen month1 = string(month)
replace month1 = "0" + month1 if strlen(month1)==1

keep if year<=2013 | (year ==2014 & month<=6) 
saveold "${rawdata}/SubmissionFileLinkRegSample.dta", replace version(12)
shell rm "${rawdata}/tempregsample.dta"

capture erase "${rawdata}/tempregsample.dta"















clear all 
set more off 
set matsize 750


global author "/Users/szho/Dropbox/My Projects/Municipal Disclosure" 
cd "${author}/Analysis/Round 3"





/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   CREATE LAGGED MACRO VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

/*

* This file computes the annual macro variables by states and the outputs are later
* merged to our regression sample to compute the lagged macro variables. 


Input files:
	- Macro data in the folder: RawData/Economic_Characteristics

	
Output file:
	- By year measure of economic variables
	
*/

global macrolag "${author}/Rawdata/Economic_Characteristics"


preserve

clear

* GSP
import delimited "${macrolag}/GSP/GSP20160129.csv", encoding(ISO-8859-1)clear
sort state year
save tempgsp, replace

* PCI
import delimited "${macrolag}/Personal_Income/percapitaIncome20170909.csv", encoding(ISO-8859-1)clear
sort state year
save temppci, replace

* HPI
import excel "${macrolag}/HPI/HPI_PO_state.xls", clear first
sort state yr qtr
by state yr: egen hpi_avg = mean(index_sa)
rename yr year
keep state year hpi_avg
duplicates drop state year, force
sort state year
save temphpi, replace

* UNEMP
import delimited "${macrolag}/Unemployment/Unemploy20160908.csv", encoding(ISO-8859-1)clear
sort state year
by state year: egen unemploy_avg = mean(unemploy)
keep state year unemploy_avg
duplicates drop state year, force
sort state year

* Combine outputs
merge 1:1 state year using temphpi
keep if _merge == 3
drop _merge

merge 1:1 state year using temppci
keep if _merge == 3
drop _merge

merge 1:1 state year using tempgsp
keep if _merge == 3
drop _merge

rename gsp gsp_avg
rename percapitaincome pci_avg

replace year = year +1 
* so that year 2008 is matched to year 2009 for our data
sort state year

winsor2 unemploy_avg, replace cuts(1 99)
winsor2 gsp_avg, replace cuts(1 99)
winsor2 pci_avg, replace cuts(1 99)
winsor2 hpi_avg, replace cuts(1 99)

save tempmacro, replace

restore







/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   IMPORT 2NDARY MARKET TRADE VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/


/*
	- RetailTrades20190530, number and volume of trades at the bond-year level, created by 05_retail_trades.sas 
*/

* INDICATOR FOR THE EXISTENCE OF SECONDARY MARKET TRADE in 2009

preserve

use RetailTrades20190530, clear
gen num = inst1_num_2nd + inst2_num_2nd + retail1_num_2nd + retail2_num_2nd
keep if num > 1 & year ==2009
gen trade1=1
keep cusip_6 trade1
duplicates drop
sort cusip_6
save XSretail1, replace

restore



* CHANGES IN INVESTOR BASE VARIABLES

preserve
use RetailTrades20190530, clear 
sort cusip9 year

sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}
gen pct_retail_num_2nd = (retail1_num_2nd_t + retail2_num_2nd_t) / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
gen pct_inst_num_2nd   = (inst2_num_2nd_t)  / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
keep cusip_6 year pct_retail_num_2nd pct_inst_num_2nd
duplicates drop
sort cusip_6 year

save PctTrade, replace

restore



* For alternative control group:

preserve
use RetailTradesAltControl20190530, clear
sort cusip9 year

* Aggregate trading at the issuer level
sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}
gen pct_retail_num_2nd = (retail1_num_2nd_t + retail2_num_2nd_t) / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
gen pct_inst_num_2nd   = (inst2_num_2nd_t)  / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
keep cusip_6 year pct_retail_num_2nd pct_inst_num_2nd
duplicates drop
sort cusip_6 year
rename pct_retail_num_2nd pct_retail_num_2nd_alt
rename pct_inst_num_2nd pct_inst_num_2nd_alt

save PctTrade_altcontrol, replace
restore



preserve

use RetailTrades20190530, clear 

* Aggregate total number of trades at the issuer-year level:

sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}

gen total_trade_2nd = (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)

keep cusip_6 year total_trade_2nd
duplicates drop cusip_6 year, force
sort cusip_6 year

sum total_trade_2nd,d

save TotalTrade, replace

restore














/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   CREATE UNDERWRITER VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/


/*
 
Input file:
		- Underwriters20190530.csv, created by 06_underwriters.R, which is at the cusip_6 by year level. 
		# 1. For each underwriter and year, construct the amount of debt issuance by each underwriter
		# as a percentage of total debt issuance in that year. 	
		# 2. If multiple underwriters are used in a given issue, then assign the issuer's underwriter market share
		# with the largest market share. 
		# For example, for a cusip_6 issuer and 2010, there might be underwriters A, B, C and A has the largest market share in 2010. 
		# We assign the issuer's underwriter market share as A's market share. 
		
*/


* DEFINE UNDERWRITER FE 

preserve

clear

import delimited "Underwriters20190530.csv", encoding(ISO-8859-1) clear

drop v1
duplicates report cusip_6 year
* sanity check, should be zero

egen cusipid = group(cusip_6)
xtset cusipid year

tsfill,full
tab year
count if cusipid == .
* 0

* Fill in data of the missing year
sort cusipid year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist mktshr leadmng leadmng1 numstate{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

gsort cusipid -year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist mktshr leadmng leadmng1 numstate{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

* Check if all non-missing
foreach var of varlist cusip_6 mktshr leadmng leadmng1 numstate{
	count if missing(`var')
}

drop cusipid
sort cusip_6 year
save tempunderwriter, replace

restore



* DEFINE UNDERWRITER XS VARIABLES
preserve

clear

import delimited "Underwriters_2_20190530.csv", encoding(ISO-8859-1) clear

drop v1
duplicates report cusip_6 year
* sanity check, should be zero

egen cusipid = group(cusip_6)
xtset cusipid year

tsfill,full
tab year
count if cusipid == .
* 0

* Fill in data of the missing year
sort cusipid year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

gsort cusipid -year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

* Check if all non-missing
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	count if missing(`var')
}

drop cusipid
sort cusip_6 year
save tempunderwriter_20190530, replace

restore










/******************************************************************************/
/******************************************************************************/
/******************************************************************************/




* Timeliness




/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

global Timeliness  "${author}/Rawdata/Timeliness"

preserve

use "${Timeliness}/cd2009to2014.dta", clear 
// created by 03_disclosures.do 
// Includes only financial disclosures

* Submission date
gen year=substr(date, 1,4)
gen month=substr(date,6,2)
gen day=substr(date,9,2)
destring year month day, replace force
gen date1 = mdy(month, day, year)
keep if date1 !=.

* Fiscal year end date, benchmark year
drop year month day
gen year=substr(endingdate, 1,4)
gen month=substr(endingdate,6,2)
gen day=substr(endingdate,9,2)
destring year month day, replace force
gen fye=mdy(month,day,year)
keep if fye !=.

* Timeliness measure
gen timeliness = date1 - fye // larger, less timely!!!
gen cusip_6 = substr(cusip9,1,6)
keep if cusip_6 !=""
gen year1= year
forvalues i=2010(1)2014{
	replace year = `i'-1 if year1 == `i' & month<=6
}
drop year1 month day
keep if year>=2009 & year<=2013

sort cusip_6 year
by cusip_6 year: egen timeliness2 = min(timeliness) // select the most timely disclosures
duplicates drop cusip_6 year, force
keep cusip_6 year timeliness2

saveold "timeliness2_20190304.dta", replace version(12)

restore












/* COMPUTE AVERAGE ISSUER-LEVEL CREDIT RATING:*/

preserve

use "sample_20190530.dta", clear
keep cusip_6 year treated state moody_rated_pre sp_rated_pre
sort cusip_6 year treated state moody_rated_pre sp_rated_pre
by cusip_6: gen nvals = _n==1
keep if nvals ==1
drop nvals
save "tempsample0.dta", replace

restore

preserve

use "sample_20190530.dta", clear
capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre == 1 & insurance_pre<1
keep if sample ==1
keep cusip_6 year
save "tempratingagency1.dta", replace

restore


global rawdata "${author}/Rawdata/SDC"
use "${rawdata}/SDC_BondSaleDate_19902014.dta", clear

* Sale date
gen year = substr(saledate, 7,2) 
gen month = substr(saledate, 1,2)
gen day = substr(saledate, 4,2)

destring year, replace
destring month, replace
destring day, replace
replace year = 2000+year if year <=14
replace year = 1900+year if year >=90 & year <=99 & year !=.

tab year
tab month
tab day
count // 1,564,258

drop saledate
gen saledate = mdy(month, day, year)
format saledate %td

gen year1 = year
replace year1 = year - 1 if month <=6

drop if year <= 1990 & month <=6
drop if year >=2014 & month>=7
tab year1
drop year
rename year1 year


* Rating agency
replace ratingagency = lower(ratingagency)
tab ratingagency

gen moody_rated = strpos(ratingagency, "moody")>0
gen sp_rated = strpos(ratingagency, "sp")>0
gen fitch_rated = strpos(ratingagency, "fitch")>0
count if moody_rated == 0 & sp_rated == 0 & fitch_rated == 0 & rateddealflag == "Yes" // 0
gen rated = rateddealflag == "Yes"


* Moodys long term underlying rating
gen moody_rate_scale = .
replace moody_rate_scale = 9 if strpos(moodylongtermunderlying, "Aaa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 8 if strpos(moodylongtermunderlying, "Aa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 7 if strpos(moodylongtermunderlying, "A")>0 & moody_rate_scale ==.
replace moody_rate_scale = 6 if strpos(moodylongtermunderlying, "Baa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 5 if strpos(moodylongtermunderlying, "Ba")>0 & moody_rate_scale ==.
replace moody_rate_scale = 4 if strpos(moodylongtermunderlying, "B")>0 & moody_rate_scale ==.
replace moody_rate_scale = 3 if strpos(moodylongtermunderlying, "Caa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 2 if strpos(moodylongtermunderlying, "Ca")>0 & moody_rate_scale ==.
replace moody_rate_scale = 1 if strpos(moodylongtermunderlying, "C")>0 & moody_rate_scale ==.
replace moody_rate_scale = 0 if strpos(moodylongtermunderlying, "D")>0 & moody_rate_scale ==.
replace moody_rate_scale = 0 if strpos(moodylongtermunderlying, "E")>0 & moody_rate_scale ==.
tab moody_rate_scale 

gen sp_rate_scale = .
replace sp_rate_scale = 9 if strpos(splongtermunderlying, "AAA")>0 & sp_rate_scale ==.
replace sp_rate_scale = 8 if strpos(splongtermunderlying, "AA")>0 & sp_rate_scale ==.
replace sp_rate_scale = 7 if strpos(splongtermunderlying, "A")>0 & sp_rate_scale ==.
replace sp_rate_scale = 6 if strpos(splongtermunderlying, "BBB")>0 & sp_rate_scale ==.
replace sp_rate_scale = 5 if strpos(splongtermunderlying, "BB")>0 & sp_rate_scale ==.
replace sp_rate_scale = 4 if strpos(splongtermunderlying, "B")>0 & sp_rate_scale ==.
replace sp_rate_scale = 3 if strpos(splongtermunderlying, "CCC")>0 & sp_rate_scale ==.
replace sp_rate_scale = 2 if strpos(splongtermunderlying, "CC")>0 & sp_rate_scale ==.
replace sp_rate_scale = 1 if strpos(splongtermunderlying, "C")>0 & sp_rate_scale ==.
replace sp_rate_scale = 0 if strpos(splongtermunderlying, "D")>0 & sp_rate_scale ==.
replace sp_rate_scale = 0 if strpos(splongtermunderlying, "E")>0 & sp_rate_scale ==.

gen fitch_rate_scale = .
replace fitch_rate_scale = 9 if strpos(fitchlongtermunderlying, "AAA")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 8 if strpos(fitchlongtermunderlying, "AA")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 7 if strpos(fitchlongtermunderlying, "A")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 6 if strpos(fitchlongtermunderlying, "BBB")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 5 if strpos(fitchlongtermunderlying, "BB")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 4 if strpos(fitchlongtermunderlying, "B")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 3 if strpos(fitchlongtermunderlying, "CCC")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 2 if strpos(fitchlongtermunderlying, "CC")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 1 if strpos(fitchlongtermunderlying, "C")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 0 if strpos(fitchlongtermunderlying, "D")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 0 if strpos(fitchlongtermunderlying, "E")>0 & fitch_rate_scale ==.

egen rating = rowmean(sp_rate_scale fitch_rate_scale moody_rate_scale) // command ignores missing value
tab rating

cap drop state 
gen cusip_6 = substr(cusip1, 1,6)
merge m:1 cusip_6 using "tempsample0.dta", nogen keep(3)
sort cusip1 rating moody_rated sp_rated fitch_rated treated amount creditenhancer year state moody_rated_pre sp_rated_pre

merge m:1 cusip_6 year using "tempratingagency1.dta"
drop if _merge ==2
bys cusip_6: egen nvals = mean(_merge == 3)
keep if nvals >0
drop _merge nvals

keep cusip1 cusip_6 rating moody_rated sp_rated fitch_rated treated amount creditenhancer rated year state moody_rated_pre sp_rated_pre
sort cusip1 rating moody_rated sp_rated fitch_rated treated amount creditenhancer year state moody_rated_pre sp_rated_pre
by cusip1: gen nvals = _n==1
keep if nvals ==1
drop nvals

save "tempsdc.dta", replace // bond characteristics at the bond level, also used for parallel trends for yield. 






* Compute rating at issuer-year level. 
use "tempsdc.dta", clear

keep cusip_6 year rating
sort cusip_6 year
by cusip_6 year: egen avgrating = max(rating)
keep if avgrating !=.
duplicates drop cusip_6 year, force


preserve

use sample_20190530, clear
keep cusip_6 year
sort cusip_6 year
save tempsample1, replace

restore

merge 1:1 cusip_6 year using tempsample1 // to get back to a balanced panel
sort cusip_6 year
replace avgrating = avgrating[_n-1] if cusip_6 == cusip_6[_n-1] & avgrating ==.
keep cusip_6 year avgrating 

saveold IssuerRating20190530, replace version(12)

 
preserve
use IssuerRating20190530, clear
keep if year==2009
save avgrating2009, replace

restore 











/* Parallel trends */


use "sdc_issuer_year20190530.dta", clear // created by 02_sdc_processing.do, unique issuer-year level data

keep cusip_6 year moody_rated sp_rated fitch_rated call go amountofissue
egen cusipid = group(cusip_6)

xtset cusipid year
tsfill, full
sort cusipid year
foreach var of varlist moody_rated sp_rated fitch_rated{
	replace `var' = `var'[_n-1] if `var' ==. & `var'[_n-1] !=. & cusipid == cusipid[_n-1]
	rename `var' `var'_issuer
}
replace cusip_6 = cusip_6[_n-1] if cusipid == cusipid[_n-1] & cusip_6[_n-1] !=""
drop if cusip_6 ==""
sort cusip_6 year

replace moody_rated_issuer = moody_rated >0 & moody_rated !=.
replace sp_rated_issuer = sp_rated >0 & sp_rated !=.
replace fitch_rated_issuer = fitch_rated >0 & fitch_rated !=.

gen log_amountofissue = log(1 + amountofissue)
replace log_amountofissue = 0 if log_amountofissue ==.
gen call_issuer = call >0 & call !=.
gen go_issuer = go >0 & go !=.

keep cusip_6 year moody_rated_issuer sp_rated_issuer fitch_rated_issuer call_issuer go_issuer log_amountofissue
save "temptrends_rating.dta", replace










/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   SAMPLE TO GENERATE TABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/



/***********************************************/

global author "/Users/szho/Dropbox/My Projects/Municipal Disclosure" 


cd "${author}/Analysis/Round 3"
global Timeliness  "${author}/Rawdata/Timeliness" 

* CHOOSE A CLUSTERING DIMENSION
global clustervar cusip_id
// global clustervar state_id



use sample_20190530.dta, clear

sort cusip_6 year
egen cusip_id = group(cusip_6)
egen state_id = group(state)
xtset cusip_id year

* ISSUE INDICATOR
gen issue = log_amountofissue >0


* CREATE UNDERWRITER VARIABLES
capture drop leadmng*
sort cusip_6 year
merge 1:1 cusip_6 year using tempunderwriter, keep (1 3) nogen // tempunderwriter is a balanced panel by cusip_6 year
gen missuw = leadmng == ""

foreach var of varlist leadmng leadmng1{
	replace `var' = "NA" if missuw == 1
}
replace mktshr = 0  if missuw == 1
egen uwid1 = group(leadmng1)


* ISSUER TYPE FIXED EFFECTS
egen issuerdscrp_pre_id = group(issuerdscrp_pre)


* SECTOR FIXED EFFECTS
replace uop1_pre="NA" if uop1_pre==""
egen uop1_pre_id = group(uop1_pre)


* PRE-PERIOD ISSUER RATING FIXED EFFECTS
merge m:1 cusip_6 year using avgrating2009, keep(1 3) nogen
bysort cusip_6 (year): egen avgrating_pre=sum(avgrating)
replace avgrating_pre=. if avgrating_pre==0 & avgrating!=0
replace avgrating_pre=-1 if missing(avgrating_pre) // create -1 group for missing longtermratings
egen avgrating_pre_id = group(avgrating_pre)
drop avgrating

 
* IMPORT LAGGED MACRO VARIABLES
sort state year
merge m:1 state year using tempmacro, keep(1 3) nogen
gen gsp_avg_sc=gsp_avg/10000
gen pci_avg_sc=pci_avg/100
gen hpi_avg_sc=hpi_avg/100


* STATE BY YEAR FIXED EFFECTS
gen stateXyear = year*100+state_id


* SAMPLE FOR OUR ANALYSES
capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre ==1 & insurance_pre<1

capture drop samp1
xtreg financials_all treated_post post log_amountofissue call go  gsp_avg_sc pci_avg_sc hpi_avg_sc unemploy_avg if sample==1
gen samp1=1 if e(sample)
tab samp1

















/******************************************************************************/

/* This file cleans SDC data. */
/*
Date: 2020.03.13


/******************************/		
Input files:
/******************************/		

	- (1) /Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/SDC/SDC_IssuerSaleDate_19902014.csv.
	
cusip_6	saledate	county	issuer	ratingagency
729773	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729778	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729780	01/02/90	Hennepin	Plymouth City-Minnesota	SP
729783	01/02/90	Hennepin	Plymouth City-Minnesota	SP
864048	01/02/90	Door	Sturgeon Bay-Wisconsin	
864056	01/02/90	Door	Sturgeon Bay-Wisconsin	
944048	01/02/90	Kosciusko	Wawasee Comm School Corp	
944050	01/02/90	Kosciusko	Wawasee Comm School Corp	
947644	01/02/90	Weber	Weber Co-Utah	
947648	01/02/90	Weber	Weber Co-Utah	
947651	01/02/90	Weber	Weber Co-Utah	
947659	01/02/90	Weber	Weber Co-Utah	
004590	01/03/90	Franklin-Hardin	Ackley City-Iowa	
004606	01/03/90	Franklin-Hardin	Ackley City-Iowa	
004613	01/03/90	Franklin-Hardin	Ackley City-Iowa	
048339	01/03/90	Atlantic	Atlantic City-New Jersey	
048343	01/03/90	Atlantic	Atlantic City-New Jersey	
048339	01/03/90	Atlantic	Atlantic City-New Jersey	MOODY;SP
048343	01/03/90	Atlantic	Atlantic City-New Jersey	MOODY;SP
	
	
*/
/******************************************************************************/

clear all 
set more off 
set matsize 750

// cd "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\SDC"
cd "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/SDC"
global data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Analysis/Round 2 new"



***********************************************************************/
/* SDC data cleaning */
**********************************************************************/



use SDC_IssuerSaleDate_19902014, clear // created by 01_sdc_issuer.R


* Sale date
gen year = substr(saledate, 7,2) 
gen month = substr(saledate, 1,2)
gen day = substr(saledate, 4,2)

destring year, replace
destring month, replace
destring day, replace
replace year = 2000+year if year <=14
replace year = 1900+year if year >=90 & year <=99 & year !=.

tab year
tab month
tab day
count 
*857,323

drop saledate
gen saledate = mdy(month, day, year)
format saledate %td

* Ratinng agency
replace ratingagency = lower(ratingagency)
tab ratingagency

gen moody_rated = strpos(ratingagency, "moody")>0
gen sp_rated = strpos(ratingagency, "sp")>0
gen fitch_rated = strpos(ratingagency, "fitch")>0
count if moody_rated == 0 & sp_rated == 0 & fitch_rated == 0 & rateddealflag == "Yes" 
*0

gen rated = rateddealflag == "Yes"

* Credit enhancement
gen insurance = creditenhancetype != ""

* Callable
gen call = callable == "Yes"
tab call

* Go vs reveneu
gen go = security == "GO"


* amount of issue
destring amountofissue, replace force 
*forced is used because missing amount is denoted by NA.


* Maturity

gen yearm = substr(maxmaturity, 1,4)
gen monthm = substr(maxmaturity, 6,2)
gen daym = substr(maxmaturity,9,2)
destring monthm daym, replace
destring yearm, replace force
tab yearm
gen max_maturity = mdy(monthm, daym, yearm)
replace max_maturity = . if maxmaturity == "NA" | yearm <1990
format max_maturity %td
drop yearm monthm daym




* Underwriter
gen underwriter = leadmng 
*857,323










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
* Generate issuer-year level data
/**********************************************************************/

preserve

gen year1 = year
replace year1 = year - 1 if month <=6

drop if year <= 1990 & month <=6
drop if year >=2014 & month>=7
tab year1
drop year
rename year1 year

* Compute average issuer-year rating, insurance, call, go
sort cusip_6 year

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6 year: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6 year: egen first_offer_date = min(saledate)
by cusip_6 year: egen last_offer_date = max(saledate)
by cusip_6 year: gen num_offer = _N
format first_offer_date last_offer_date %td
by cusip_6 year: egen nvals = total(amountofissue)
gen amountofissue0=amountofissue
replace amountofissue = nvals
drop nvals

* Max maturity

by cusip_6 year: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals
format max_maturity %td



* Drop duplicates
* Keep issuers that issue the highest amount of debt and highest frequency of debt
gsort cusip_6 year issuerdscrp -saledate state uop1
by cusip_6 year issuerdscrp: egen nvals = total(amountofissue0) 
** total amount
by cusip_6 year issuerdscrp: gen nvals1 = _N 
** total number
by cusip_6 year issuerdscrp: gen nvals0 =_n ==1

keep if nvals0 == 1
drop nvals0
gsort cusip_6 year -saledate
by cusip_6 year: egen nvals2 = max(nvals) 
** max total amount of debt by cusip_6 year and issuerdscrp
keep if nvals == nvals2 
** keep issuers that issue the highest total amount of debt.
duplicates report cusip_6 year


by cusip_6 year: egen nvals3 = max(nvals1)
keep if nvals3 == nvals1
duplicates report cusip_6 year


sort cusip_6 year state uop1 issuerdscrp
by cusip_6 year: gen issuerdscrp1 = issuerdscrp[_n+1]
sort cusip_6 year 



keep cusip_6 year moody_rated rated sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state amountofissue issuerdscrp issuerdscrp1 uop1 underwriter issuer
sort cusip_6 year state uop1 issuerdscrp issuerdscrp1
cap drop nvals*
by cusip_6 year: gen nvals = _n==1
keep if nvals == 1
drop nvals

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable rated "issuer is rated"
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"
		label variable amountofissue "total annual issuance amount"
		label variable uop1 "purpose"
		label variable underwriter "underwriter"
		label variable issuer "issuer name"

count 
* 387,174 issuer-year


saveold "${data}/sdc_issuer_year20190530.dta", replace version(12)
restore
















/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/* Issuer level: debt outstanding */
/**********************************************************************/


preserve

keep if saledate <= mdy(06,30,2010) & max_maturity >= mdy(06,30,2010) & max_maturity !=. 
keep if rated ==1
sort cusip_6

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6: egen first_offer_date = min(saledate)
by cusip_6: egen last_offer_date = max(saledate)
by cusip_6: gen num_offer = _N
format first_offer_date last_offer_date %td

* Max maturity

by cusip_6: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals

duplicates drop cusip_6, force
keep cusip_6 moody_rated  sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"

count 
*39,158

saveold "${data}/sdc_debtoustanding_20190530.dta", replace version(12) // only sample itself is used. 

restore





/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/* access market */


preserve

keep if saledate <= mdy(06,30,2010) & saledate >= mdy(07,01,2006) 
sort cusip_6

capture drop nvals
foreach var of varlist moody_rated sp_rated fitch_rated rated insurance call go {
	by cusip_6: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}

* Offer
by cusip_6: egen first_offer_date = min(saledate)
by cusip_6: egen last_offer_date = max(saledate)
by cusip_6: gen num_offer = _N
format first_offer_date last_offer_date %td
by cusip_6: egen nvals = total(amountofissue)
gen amountofissue0=amountofissue
replace amountofissue = nvals
drop nvals

* Max maturity

by cusip_6: egen nvals = max(max_maturity)
replace max_maturity = nvals
drop nvals

* Drop duplicates
* Keep issuers that issue the highest amount of debt and highest frequency of debt
gsort cusip_6 issuerdscrp -saledate state uop1 issuer
by cusip_6 issuerdscrp: egen nvals = total(amountofissue0) 
** total amount
by cusip_6 issuerdscrp: gen nvals1 = _N 
** total number
by cusip_6 issuerdscrp: gen nvals0 =_n ==1

keep if nvals0 == 1
drop nvals0
gsort cusip_6 issuerdscrp -saledate state uop1 issuer
by cusip_6: egen nvals2 = max(nvals) 
** max total amount of debt by cusip_6 and issuerdscrp
keep if nvals == nvals2 
** keep issuers that issue the highest total amount of debt.
duplicates report cusip_6
/*
--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |        32362             0
        2 |           18             9
--------------------------------------
*/

by cusip_6: egen nvals3 = max(nvals1)
keep if nvals3 == nvals1
duplicates report cusip_6
/*
--------------------------------------
   copies | observations       surplus
----------+---------------------------
        1 |        32362             0
        2 |           18             9
--------------------------------------
*/
sort cusip_6 year state uop1 issuerdscrp issuer
by cusip_6 (year state uop1 issuerdscrp issuer): gen issuerdscrp1 = issuerdscrp[_n+1]
cap drop nvals
by cusip_6: gen nvals = _n==1
keep if nvals ==1
drop nvals


keep cusip_6 rated moody_rated sp_rated fitch_rated first_offer_date last_offer_date num_offer max_maturity insurance call go state issuerdscrp issuerdscrp1 amountofissue uop1  underwriter issuer

		label variable cusip_6 "6 digit cusip"
		label variable moody_rated "issuer is rated by moody's"
		label variable sp_rated "issuer is rated by sp"
		label variable fitch_rated "issuer is rated by fitch
		label variable first_offer_date "issuer's first offering"
		label variable last_offer_date "issuer's last offering"
		label variable num_offer "issuer's total number of offering"
		label variable max_maturity "issuer's longest maturity bond offered"
		label variable insurance "percentage of insured bonds"
		label variable call "percentage of callable issues"
		label variable go "percentage of go issues"
		label variable amountofissue "total annual issuance amount"

count 
*32,371


saveold "${data}/sdc_accessmarket_20190530.dta", replace version(12)

restore










/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

* Issue level

preserve

keep if saledate <= mdy(06,30,2010) & saledate >= mdy(07,01,2006) 
sort cusip_6 saledate 
by cusip_6 saledate: gen nvals =_n==1
keep if nvals ==1
drop nvals

gen issue_id = _n
keep cusip_6 saledate year

saveold "${data}/sdc_issuereg_20190304.dta", replace version(12)

restore










/******************************************************************************/

/*


This file creates the data for financial disclosures. 
Date: 2020.03.13

	
*/


global Data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/Timeliness"
global Data "/Users/szho/Documents/Temp"


* Change formats
forvalues i=2009(1)2014{
	use "${Data}/cd`i'.dta", clear
	saveold "${Data}/cd`i'.dta", replace version(12)
}


























/******************************************************************************/

* STEP 1: CREATE FINANCIAL DISCLOSURE DATA

/******************************************************************************/


* Other disclosures that are CAFR

import excel "${Data}/OtherVoluntaryFinancialDisclosures.xlsx", sheet("Sheet1") firstrow clear
keep othervoluntarydisclosure CAFR
keep if CAFR == 1
sort othervoluntarydisclosure
duplicates drop othervoluntarydisclosure, force
save "${Data}/tempCAFR.dta", replace




* Create disclosure data

forvalues i=2009(1)2014{

	use "${Data}/cd`i'.dta", clear
	
	sort submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure submissiondatetime
	drop if financialdisclosurecat == "NA" // drop non-financial disclosures
	duplicates drop submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure, force // drop duplicates 
	
	gen other = financialdisclosurecat == "OtherFinancialVoluntaryInformation"
	by submissionidentifier: egen nvals = sd(other)
	drop if other == 1 & nvals >0 & nvals !=. // drop footnote disclosures 
	drop nvals other
	
	
	keep submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure submissiondatetime endingdate periodtype
		
	
	* Create disclosure types
	
	gen CAFR = financialdisclosurecat == "AuditedFinancialStatementsOrCAFR15c212"
	gen AnnualFinancial =  financialdisclosurecat == "AnnualFinancialInformationOperatingData15c212"
	gen QMFinancial = financialdisclosurecat == "QuarterlyMonthlyFinancialInformation" | financialdisclosurecat == "InterimAdditionalFinancialInformationOperatingData"
	gen DisclosureFailure = financialdisclosurecat == "FailureToProvideAnnualFinancialInformationAsRequired15c212"
	gen Budget = financialdisclosurecat == "Budget" 

	
	* Create date
	replace submissiondatetime = trim(submissiondatetime)
	gen date = substr(submissiondatetime, 1, 10)
	
	
	keep submissionidentifier cusip9 financialdisclosurecat othervoluntarydisclosure endingdate periodtype date CAFR AnnualFinancial QMFinancial DisclosureFailure Budget
	
	save "${Data}/tempcd_`i'.dta", replace
	
}

use "${Data}/tempcd_2009.dta", clear
forvalues i=2010(1)2014{
	append using "${Data}/tempcd_`i'.dta"
}


saveold "${Data}/cd2009to2014.dta", replace version(12)
shell rm "${Data}/temp"*






/******************************************************************************/

* STEP 2: DROP DUPLICATE ANNUAL FINANCIAL STATEMENTS

/******************************************************************************/


use "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\Timeliness\cd2009to2014.dta", clear

sort cusip9 date
duplicates tag cusip9 date, gen(tag)

bysort cusip9 date: egen sumcafr=sum(CAFR)
bysort cusip9 date: egen sumannual=sum( AnnualFinancial )

drop if tag>0 & sumcafr==1 & sumannual==1 & AnnualFinancial==1

saveold cd2009to2014_20180725, replace version(12)






/******************************************************************************/

* STEP 3: CREATE FILE TO COUNT NUMBER OF MATERIAL EVENTS

/******************************************************************************/


cd "C:\Users\dsamuels\Dropbox (MIT)\Municipal Disclosure\Rawdata\Timeliness"

forvalues i=2009(1)2014{

	use "cd`i'.dta", clear
	
	sort submissionidentifier cusip9 eventdisclosurecat
	drop if eventdisclosurecat == "NA" 
	
	* Create date
	replace submissiondatetime = trim(submissiondatetime)
	gen date = substr(submissiondatetime, 1, 10)
	
	keep submissionidentifier cusip9 eventdisclosurecat submissiondatetime endingdate periodtype date
		
	save "tempcd_`i'.dta", replace
}

use "tempcd_2009.dta", clear
forvalues i=2010(1)2014{
	append using "tempcd_`i'.dta"
}


saveold "events2009to2014.dta", replace version(12)


























/*


* Match financial statement sample cd2009to2014 (produced by FinancialDisclosure.do)
* with the regression sample




*/



global rawdata "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Rawdata/Timeliness"
global data "/Users/szho/Dropbox/My Projects/Municipal Disclosure/Analysis"






********************************************************************************
********************************************************************************

* Regression sample from gsz_20200313.do

********************************************************************************
********************************************************************************

use "${data}/sample_20190530.dta", clear

sort cusip_6 year
egen cusip_id = group(cusip_6)
egen state_id = group(state)
xtset cusip_id year


* ISSUE INDICATOR
gen issue = log_amountofissue >0


* CREATE UNDERWRITER VARIABLES
capture drop leadmng*
sort cusip_6 year
merge 1:1 cusip_6 year using tempunderwriter, keep (1 3) nogen // tempunderwriter is a balanced panel by cusip_6 year
gen missuw = leadmng == ""

foreach var of varlist leadmng leadmng1{
	replace `var' = "NA" if missuw == 1
}
replace mktshr = 0  if missuw == 1
egen uwid1 = group(leadmng1)


* ISSUER TYPE FIXED EFFECTS
egen issuerdscrp_pre_id = group(issuerdscrp_pre)


* SECTOR FIXED EFFECTS
replace uop1_pre="NA" if uop1_pre==""
egen uop1_pre_id = group(uop1_pre)


 
* IMPORT LAGGED MACRO VARIABLES
sort state year
merge m:1 state year using "${data}/tempmacro.dta", keep(1 3) nogen

gen gsp_avg_sc=gsp_avg/10000
gen pci_avg_sc=pci_avg/100
gen hpi_avg_sc=hpi_avg/100








/***********************************************/
* TABLE 3 - MAIN RESULTS
/***********************************************/

capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre ==1 & insurance_pre<1

capture drop samp1
xtreg financials_all treated_post post log_amountofissue call go gsp_avg_sc pci_avg_sc hpi_avg_sc unemploy_avg if sample==1
gen samp1=1 if e(sample)

keep if samp1==1
keep cusip_6
duplicates drop cusip_6, force

sort cusip_6
save "${rawdata}/tempregsample.dta", replace

























********************************************************************************
********************************************************************************

* Load linking table

********************************************************************************
********************************************************************************

import delimited "/Volumes/Frank's Passport for Mac Files/msrb_disclosure/SubmissionFileLink2009.csv", encoding(ISO-8859-1) clear
forvalues i=2010(1)2015{
	preserve 
	import delimited "/Volumes/Frank's Passport for Mac Files/msrb_disclosure/SubmissionFileLink`i'.csv", encoding(ISO-8859-1) clear
	save "${rawdata}/tempSubmissionFileLink`i'", replace
	restore
	append using "${rawdata}/tempSubmissionFileLink`i'"
}
shell rm "${rawdata}/tempSubmissionFileLink"*
capture erase "${rawdata}/tempSubmissionFileLink"*

sort submissionidentifier fileidentifier year month submissiontransactiondatetime
by submissionidentifier fileidentifier: gen nvals=_n==1
keep if nvals ==1
drop nvals
keep submissionidentifier fileidentifier year month
save "${rawdata}/SubmissionFileLink.dta", replace




















********************************************************************************
********************************************************************************


* Merge linking table with regression sample

********************************************************************************
********************************************************************************

use "${rawdata}/cd2009to2014.dta", clear

gen cusip_6 = substr(cusip9, 1, 6)
merge m:1 cusip_6 using  "${rawdata}/tempregsample.dta", keep(3)
duplicates drop submissionidentifier, force

keep submissionidentifier
sort submissionidentifier

merge 1:m submissionidentifier using "${rawdata}/SubmissionFileLink.dta", nogen keep(3)
gen month1 = string(month)
replace month1 = "0" + month1 if strlen(month1)==1

keep if year<=2013 | (year ==2014 & month<=6) 
saveold "${rawdata}/SubmissionFileLinkRegSample.dta", replace version(12)
shell rm "${rawdata}/tempregsample.dta"

capture erase "${rawdata}/tempregsample.dta"
















clear all 
set more off 
set matsize 750


global author "/Users/szho/Dropbox/My Projects/Municipal Disclosure" 
cd "${author}/Analysis/Round 3"





/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   CREATE LAGGED MACRO VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

/*

* This file computes the annual macro variables by states and the outputs are later
* merged to our regression sample to compute the lagged macro variables. 


Input files:
	- Macro data in the folder: RawData/Economic_Characteristics

	
Output file:
	- By year measure of economic variables
	
*/

global macrolag "${author}/Rawdata/Economic_Characteristics"


preserve

clear

* GSP
import delimited "${macrolag}/GSP/GSP20160129.csv", encoding(ISO-8859-1)clear
sort state year
save tempgsp, replace

* PCI
import delimited "${macrolag}/Personal_Income/percapitaIncome20170909.csv", encoding(ISO-8859-1)clear
sort state year
save temppci, replace

* HPI
import excel "${macrolag}/HPI/HPI_PO_state.xls", clear first
sort state yr qtr
by state yr: egen hpi_avg = mean(index_sa)
rename yr year
keep state year hpi_avg
duplicates drop state year, force
sort state year
save temphpi, replace

* UNEMP
import delimited "${macrolag}/Unemployment/Unemploy20160908.csv", encoding(ISO-8859-1)clear
sort state year
by state year: egen unemploy_avg = mean(unemploy)
keep state year unemploy_avg
duplicates drop state year, force
sort state year

* Combine outputs
merge 1:1 state year using temphpi
keep if _merge == 3
drop _merge

merge 1:1 state year using temppci
keep if _merge == 3
drop _merge

merge 1:1 state year using tempgsp
keep if _merge == 3
drop _merge

rename gsp gsp_avg
rename percapitaincome pci_avg

replace year = year +1 
* so that year 2008 is matched to year 2009 for our data
sort state year

winsor2 unemploy_avg, replace cuts(1 99)
winsor2 gsp_avg, replace cuts(1 99)
winsor2 pci_avg, replace cuts(1 99)
winsor2 hpi_avg, replace cuts(1 99)

save tempmacro, replace

restore







/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   IMPORT 2NDARY MARKET TRADE VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/


/*
	- RetailTrades20190530, number and volume of trades at the bond-year level, created by 05_retail_trades.sas 
*/

* INDICATOR FOR THE EXISTENCE OF SECONDARY MARKET TRADE in 2009

preserve

use RetailTrades20190530, clear
gen num = inst1_num_2nd + inst2_num_2nd + retail1_num_2nd + retail2_num_2nd
keep if num > 1 & year ==2009
gen trade1=1
keep cusip_6 trade1
duplicates drop
sort cusip_6
save XSretail1, replace

restore



* CHANGES IN INVESTOR BASE VARIABLES

preserve
use RetailTrades20190530, clear 
sort cusip9 year

sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}
gen pct_retail_num_2nd = (retail1_num_2nd_t + retail2_num_2nd_t) / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
gen pct_inst_num_2nd   = (inst2_num_2nd_t)  / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
keep cusip_6 year pct_retail_num_2nd pct_inst_num_2nd
duplicates drop
sort cusip_6 year

save PctTrade, replace

restore



* For alternative control group:

preserve
use RetailTradesAltControl20190530, clear
sort cusip9 year

* Aggregate trading at the issuer level
sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}
gen pct_retail_num_2nd = (retail1_num_2nd_t + retail2_num_2nd_t) / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
gen pct_inst_num_2nd   = (inst2_num_2nd_t)  / (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)
keep cusip_6 year pct_retail_num_2nd pct_inst_num_2nd
duplicates drop
sort cusip_6 year
rename pct_retail_num_2nd pct_retail_num_2nd_alt
rename pct_inst_num_2nd pct_inst_num_2nd_alt

save PctTrade_altcontrol, replace
restore



preserve

use RetailTrades20190530, clear 

* Aggregate total number of trades at the issuer-year level:

sort cusip_6 year
foreach var of varlist retail1_num_2nd retail2_num_2nd inst1_num_2nd inst2_num_2nd {
	by cusip_6 year: egen `var'_t = total(`var')
}

gen total_trade_2nd = (retail1_num_2nd_t + retail2_num_2nd_t + inst1_num_2nd_t + inst2_num_2nd_t)

keep cusip_6 year total_trade_2nd
duplicates drop cusip_6 year, force
sort cusip_6 year

sum total_trade_2nd,d

save TotalTrade, replace

restore














/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   CREATE UNDERWRITER VARIABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/


/*
 
Input file:
		- Underwriters20190530.csv, created by 06_underwriters.R, which is at the cusip_6 by year level. 
		# 1. For each underwriter and year, construct the amount of debt issuance by each underwriter
		# as a percentage of total debt issuance in that year. 	
		# 2. If multiple underwriters are used in a given issue, then assign the issuer's underwriter market share
		# with the largest market share. 
		# For example, for a cusip_6 issuer and 2010, there might be underwriters A, B, C and A has the largest market share in 2010. 
		# We assign the issuer's underwriter market share as A's market share. 
		
*/


* DEFINE UNDERWRITER FE 

preserve

clear

import delimited "Underwriters20190530.csv", encoding(ISO-8859-1) clear

drop v1
duplicates report cusip_6 year
* sanity check, should be zero

egen cusipid = group(cusip_6)
xtset cusipid year

tsfill,full
tab year
count if cusipid == .
* 0

* Fill in data of the missing year
sort cusipid year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist mktshr leadmng leadmng1 numstate{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

gsort cusipid -year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist mktshr leadmng leadmng1 numstate{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

* Check if all non-missing
foreach var of varlist cusip_6 mktshr leadmng leadmng1 numstate{
	count if missing(`var')
}

drop cusipid
sort cusip_6 year
save tempunderwriter, replace

restore



* DEFINE UNDERWRITER XS VARIABLES
preserve

clear

import delimited "Underwriters_2_20190530.csv", encoding(ISO-8859-1) clear

drop v1
duplicates report cusip_6 year
* sanity check, should be zero

egen cusipid = group(cusip_6)
xtset cusipid year

tsfill,full
tab year
count if cusipid == .
* 0

* Fill in data of the missing year
sort cusipid year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

gsort cusipid -year
by cusipid: replace cusip_6 = cusip_6[_n-1] if cusip_6 ==""
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	by cusipid: replace `var'=`var'[_n-1] if missing(`var')
}

* Check if all non-missing
foreach var of varlist leadmng1 mktshr numstate pctgo pctrev mktsharestate herfin{
	count if missing(`var')
}

drop cusipid
sort cusip_6 year
save tempunderwriter_20190530, replace

restore










/******************************************************************************/
/******************************************************************************/
/******************************************************************************/




* Timeliness




/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

global Timeliness  "${author}/Rawdata/Timeliness"

preserve

use "${Timeliness}/cd2009to2014.dta", clear 
// created by 03_disclosures.do 
// Includes only financial disclosures

* Submission date
gen year=substr(date, 1,4)
gen month=substr(date,6,2)
gen day=substr(date,9,2)
destring year month day, replace force
gen date1 = mdy(month, day, year)
keep if date1 !=.

* Fiscal year end date, benchmark year
drop year month day
gen year=substr(endingdate, 1,4)
gen month=substr(endingdate,6,2)
gen day=substr(endingdate,9,2)
destring year month day, replace force
gen fye=mdy(month,day,year)
keep if fye !=.

* Timeliness measure
gen timeliness = date1 - fye // larger, less timely!!!
gen cusip_6 = substr(cusip9,1,6)
keep if cusip_6 !=""
gen year1= year
forvalues i=2010(1)2014{
	replace year = `i'-1 if year1 == `i' & month<=6
}
drop year1 month day
keep if year>=2009 & year<=2013

sort cusip_6 year
by cusip_6 year: egen timeliness2 = min(timeliness) // select the most timely disclosures
duplicates drop cusip_6 year, force
keep cusip_6 year timeliness2

saveold "timeliness2_20190304.dta", replace version(12)

restore












/* COMPUTE AVERAGE ISSUER-LEVEL CREDIT RATING:*/

preserve

use "sample_20190530.dta", clear
keep cusip_6 year treated state moody_rated_pre sp_rated_pre
sort cusip_6 year treated state moody_rated_pre sp_rated_pre
by cusip_6: gen nvals = _n==1
keep if nvals ==1
drop nvals
save "tempsample0.dta", replace

restore

preserve

use "sample_20190530.dta", clear
capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre == 1 & insurance_pre<1
keep if sample ==1
keep cusip_6 year
save "tempratingagency1.dta", replace

restore


global rawdata "${author}/Rawdata/SDC"
use "${rawdata}/SDC_BondSaleDate_19902014.dta", clear

* Sale date
gen year = substr(saledate, 7,2) 
gen month = substr(saledate, 1,2)
gen day = substr(saledate, 4,2)

destring year, replace
destring month, replace
destring day, replace
replace year = 2000+year if year <=14
replace year = 1900+year if year >=90 & year <=99 & year !=.

tab year
tab month
tab day
count // 1,564,258

drop saledate
gen saledate = mdy(month, day, year)
format saledate %td

gen year1 = year
replace year1 = year - 1 if month <=6

drop if year <= 1990 & month <=6
drop if year >=2014 & month>=7
tab year1
drop year
rename year1 year


* Rating agency
replace ratingagency = lower(ratingagency)
tab ratingagency

gen moody_rated = strpos(ratingagency, "moody")>0
gen sp_rated = strpos(ratingagency, "sp")>0
gen fitch_rated = strpos(ratingagency, "fitch")>0
count if moody_rated == 0 & sp_rated == 0 & fitch_rated == 0 & rateddealflag == "Yes" // 0
gen rated = rateddealflag == "Yes"


* Moodys long term underlying rating
gen moody_rate_scale = .
replace moody_rate_scale = 9 if strpos(moodylongtermunderlying, "Aaa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 8 if strpos(moodylongtermunderlying, "Aa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 7 if strpos(moodylongtermunderlying, "A")>0 & moody_rate_scale ==.
replace moody_rate_scale = 6 if strpos(moodylongtermunderlying, "Baa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 5 if strpos(moodylongtermunderlying, "Ba")>0 & moody_rate_scale ==.
replace moody_rate_scale = 4 if strpos(moodylongtermunderlying, "B")>0 & moody_rate_scale ==.
replace moody_rate_scale = 3 if strpos(moodylongtermunderlying, "Caa")>0 & moody_rate_scale ==.
replace moody_rate_scale = 2 if strpos(moodylongtermunderlying, "Ca")>0 & moody_rate_scale ==.
replace moody_rate_scale = 1 if strpos(moodylongtermunderlying, "C")>0 & moody_rate_scale ==.
replace moody_rate_scale = 0 if strpos(moodylongtermunderlying, "D")>0 & moody_rate_scale ==.
replace moody_rate_scale = 0 if strpos(moodylongtermunderlying, "E")>0 & moody_rate_scale ==.
tab moody_rate_scale 

gen sp_rate_scale = .
replace sp_rate_scale = 9 if strpos(splongtermunderlying, "AAA")>0 & sp_rate_scale ==.
replace sp_rate_scale = 8 if strpos(splongtermunderlying, "AA")>0 & sp_rate_scale ==.
replace sp_rate_scale = 7 if strpos(splongtermunderlying, "A")>0 & sp_rate_scale ==.
replace sp_rate_scale = 6 if strpos(splongtermunderlying, "BBB")>0 & sp_rate_scale ==.
replace sp_rate_scale = 5 if strpos(splongtermunderlying, "BB")>0 & sp_rate_scale ==.
replace sp_rate_scale = 4 if strpos(splongtermunderlying, "B")>0 & sp_rate_scale ==.
replace sp_rate_scale = 3 if strpos(splongtermunderlying, "CCC")>0 & sp_rate_scale ==.
replace sp_rate_scale = 2 if strpos(splongtermunderlying, "CC")>0 & sp_rate_scale ==.
replace sp_rate_scale = 1 if strpos(splongtermunderlying, "C")>0 & sp_rate_scale ==.
replace sp_rate_scale = 0 if strpos(splongtermunderlying, "D")>0 & sp_rate_scale ==.
replace sp_rate_scale = 0 if strpos(splongtermunderlying, "E")>0 & sp_rate_scale ==.

gen fitch_rate_scale = .
replace fitch_rate_scale = 9 if strpos(fitchlongtermunderlying, "AAA")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 8 if strpos(fitchlongtermunderlying, "AA")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 7 if strpos(fitchlongtermunderlying, "A")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 6 if strpos(fitchlongtermunderlying, "BBB")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 5 if strpos(fitchlongtermunderlying, "BB")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 4 if strpos(fitchlongtermunderlying, "B")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 3 if strpos(fitchlongtermunderlying, "CCC")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 2 if strpos(fitchlongtermunderlying, "CC")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 1 if strpos(fitchlongtermunderlying, "C")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 0 if strpos(fitchlongtermunderlying, "D")>0 & fitch_rate_scale ==.
replace fitch_rate_scale = 0 if strpos(fitchlongtermunderlying, "E")>0 & fitch_rate_scale ==.

egen rating = rowmean(sp_rate_scale fitch_rate_scale moody_rate_scale) // command ignores missing value
tab rating

cap drop state 
gen cusip_6 = substr(cusip1, 1,6)
merge m:1 cusip_6 using "tempsample0.dta", nogen keep(3)
sort cusip1 rating moody_rated sp_rated fitch_rated treated amount creditenhancer year state moody_rated_pre sp_rated_pre

merge m:1 cusip_6 year using "tempratingagency1.dta"
drop if _merge ==2
bys cusip_6: egen nvals = mean(_merge == 3)
keep if nvals >0
drop _merge nvals

keep cusip1 cusip_6 rating moody_rated sp_rated fitch_rated treated amount creditenhancer rated year state moody_rated_pre sp_rated_pre
sort cusip1 rating moody_rated sp_rated fitch_rated treated amount creditenhancer year state moody_rated_pre sp_rated_pre
by cusip1: gen nvals = _n==1
keep if nvals ==1
drop nvals

save "tempsdc.dta", replace // bond characteristics at the bond level, also used for parallel trends for yield. 






* Compute rating at issuer-year level. 
use "tempsdc.dta", clear

keep cusip_6 year rating
sort cusip_6 year
by cusip_6 year: egen avgrating = max(rating)
keep if avgrating !=.
duplicates drop cusip_6 year, force


preserve

use sample_20190530, clear
keep cusip_6 year
sort cusip_6 year
save tempsample1, replace

restore

merge 1:1 cusip_6 year using tempsample1 // to get back to a balanced panel
sort cusip_6 year
replace avgrating = avgrating[_n-1] if cusip_6 == cusip_6[_n-1] & avgrating ==.
keep cusip_6 year avgrating 

saveold IssuerRating20190530, replace version(12)

 
preserve
use IssuerRating20190530, clear
keep if year==2009
save avgrating2009, replace

restore 











/* Parallel trends */


use "sdc_issuer_year20190530.dta", clear // created by 02_sdc_processing.do, unique issuer-year level data

keep cusip_6 year moody_rated sp_rated fitch_rated call go amountofissue
egen cusipid = group(cusip_6)

xtset cusipid year
tsfill, full
sort cusipid year
foreach var of varlist moody_rated sp_rated fitch_rated{
	replace `var' = `var'[_n-1] if `var' ==. & `var'[_n-1] !=. & cusipid == cusipid[_n-1]
	rename `var' `var'_issuer
}
replace cusip_6 = cusip_6[_n-1] if cusipid == cusipid[_n-1] & cusip_6[_n-1] !=""
drop if cusip_6 ==""
sort cusip_6 year

replace moody_rated_issuer = moody_rated >0 & moody_rated !=.
replace sp_rated_issuer = sp_rated >0 & sp_rated !=.
replace fitch_rated_issuer = fitch_rated >0 & fitch_rated !=.

gen log_amountofissue = log(1 + amountofissue)
replace log_amountofissue = 0 if log_amountofissue ==.
gen call_issuer = call >0 & call !=.
gen go_issuer = go >0 & go !=.

keep cusip_6 year moody_rated_issuer sp_rated_issuer fitch_rated_issuer call_issuer go_issuer log_amountofissue
save "temptrends_rating.dta", replace










/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

//   SAMPLE TO GENERATE TABLES

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/



/***********************************************/

global author "/Users/szho/Dropbox/My Projects/Municipal Disclosure" 


cd "${author}/Analysis/Round 3"
global Timeliness  "${author}/Rawdata/Timeliness" 

* CHOOSE A CLUSTERING DIMENSION
global clustervar cusip_id
// global clustervar state_id



use sample_20190530.dta, clear

sort cusip_6 year
egen cusip_id = group(cusip_6)
egen state_id = group(state)
xtset cusip_id year

* ISSUE INDICATOR
gen issue = log_amountofissue >0


* CREATE UNDERWRITER VARIABLES
capture drop leadmng*
sort cusip_6 year
merge 1:1 cusip_6 year using tempunderwriter, keep (1 3) nogen // tempunderwriter is a balanced panel by cusip_6 year
gen missuw = leadmng == ""

foreach var of varlist leadmng leadmng1{
	replace `var' = "NA" if missuw == 1
}
replace mktshr = 0  if missuw == 1
egen uwid1 = group(leadmng1)


* ISSUER TYPE FIXED EFFECTS
egen issuerdscrp_pre_id = group(issuerdscrp_pre)


* SECTOR FIXED EFFECTS
replace uop1_pre="NA" if uop1_pre==""
egen uop1_pre_id = group(uop1_pre)


* PRE-PERIOD ISSUER RATING FIXED EFFECTS
merge m:1 cusip_6 year using avgrating2009, keep(1 3) nogen
bysort cusip_6 (year): egen avgrating_pre=sum(avgrating)
replace avgrating_pre=. if avgrating_pre==0 & avgrating!=0
replace avgrating_pre=-1 if missing(avgrating_pre) // create -1 group for missing longtermratings
egen avgrating_pre_id = group(avgrating_pre)
drop avgrating

 
* IMPORT LAGGED MACRO VARIABLES
sort state year
merge m:1 state year using tempmacro, keep(1 3) nogen
gen gsp_avg_sc=gsp_avg/10000
gen pci_avg_sc=pci_avg/100
gen hpi_avg_sc=hpi_avg/100


* STATE BY YEAR FIXED EFFECTS
gen stateXyear = year*100+state_id


* SAMPLE FOR OUR ANALYSES
capture drop sample
gen sample=1 if ( (treated==1 )|(treated==0 & sp_rated_pre==1 & moody_rated_pre==0) ) & fitch_rated_pre==0 & rated_pre ==1 & insurance_pre<1

capture drop samp1
xtreg financials_all treated_post post log_amountofissue call go  gsp_avg_sc pci_avg_sc hpi_avg_sc unemploy_avg if sample==1
gen samp1=1 if e(sample)
tab samp1


















