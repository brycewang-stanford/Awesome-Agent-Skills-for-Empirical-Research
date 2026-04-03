
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
*
*	REAL EFFECTS OF A WIDESPREAD CSR REPORTING MANDATE: EVIDENCE FROM THE EUROPEAN UNION'S CSR DIRECTIVE
*	This version: January 2022
*
*	Peter Fiechter (University of Neuchatel)	
*	Jörg-Markus Hitz (Georg-August University of Goettingen)
*	Nico Lehmann (Erasmus University Rotterdam)
*
*	This do-file shows the STATA code for the main empirical analyses presented in Tables 1-4 of the paper.
*	The analyses are based on TWO different data sources:
*		(1) Commercially available data (i.e., WORLDSCOPE / IBES and ASSET4 data),
*		(2) Publically available data (handcolleted CSR data from annual reports). 
*	Note that the underlying WORLDSCOPE / IBES data are stored in and inserted into STATA from six separate files (EU 1-2, US 1-2, INT 1-2). 
*	Note that the underlying ASSET4 data are stored in and inserted into STATA from 15 separate files (EU 1-5, US 1-5, INT 1-5). 
*	Please read the data description accompanying this do-file beforehand for more details about the different data sources. 
*
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************

*** Stata ado files: 
ssc install winsor
ssc install rbounds
ssc install psmatch2
ssc install estout
ssc install eret2
ssc install ftools
ssc install boottest
*copy/paste "ffind" ado file into stata ado folder under "f" (e.g., C:\Program Files (x86)\Stata15\ado\base\f) or (C:\Program Files\Stata16\ado\base\f)
*find "ffind" under https://sites.google.com/site/judsoncaskey/data
*help npsynth (install npsynth.ado)



****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************

**# Start #1


macro dir 
macro drop PATH
global PATH "C:\Users\ision\OneDrive\Documents\(1) Forschung\(2) Forschungsprojekte\(10) FHL\(1) Stata 2.0"
cd "$PATH"


*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*  I. Data preparation
* 
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


********************************************************************************
********************************************************************************
*  Step 1: Read and clean datasets
********************************************************************************
********************************************************************************

*-------------------------------------------------------------------------------
*  (1.1): Add EU WORLDSCOPE / IBES data (2010-2018) from multiple source files  
*-------------------------------------------------------------------------------

***(1) Insert first file
insheet using "$PATH\(1) Data\TR_data_2020-04\Request\tr_eu_2010-2018_p1.txt",  clear 
drop if wc06008==""
drop if wc05350==""
duplicates drop wc06008 wc05350, force
sort wc06008 wc05350
save "$PATH\(2) Temp\tr_eu_2010-2018_p1", replace

***(2) Insert second file
insheet using "$PATH\(1) Data\TR_data_2020-04\Request\tr_eu_2010-2018_p2.txt",  clear 
drop if wc06008==""
drop if wc05350==""
duplicates drop wc06008 wc05350, force
sort wc06008 wc05350
save "$PATH\(2) Temp\tr_eu_2010-2018_p2", replace

***(3) Merge both files
merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\tr_eu_2010-2018_p1", force
drop _merge

***(4) Clean merged file and create year, month, day variables
drop if wc06008==""
drop if wc02999==.
drop if wc05350==""
drop if wc07011==.
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503
drop if year>2019

***(5) Indicate EU data origin and save
gen Sample="EU"
sort wc06008 wc05350
save "$PATH\(2) Temp\tr_eu_2010-2018_p12", replace

*-------------------------------------------------------------------------------
*  (1.2): Add US WORLDSCOPE / IBES data (2010-2018) from multiple source files  
*-------------------------------------------------------------------------------

***(1) Insert first file
insheet using "$PATH\(1) Data\TR_data_2020-04\Request\tr_us_2010-2018_p1.txt",  clear 
drop if wc06008==""
drop if wc05350==""
drop if wc06008=="NA"
drop if wc05350=="NA"
duplicates drop wc06008 wc05350, force
sort wc06008 wc05350
save "$PATH\(2) Temp\tr_us_2010-2018_p1", replace

***(2) Insert second file
insheet using "$PATH\(1) Data\TR_data_2020-04\Request\tr_us_2010-2018_p2.txt",  clear 
drop if wc06008==""
drop if wc05350==""
drop if wc06008=="NA"
drop if wc05350=="NA"
duplicates drop wc06008 wc05350, force
sort wc06008 wc05350
save "$PATH\(2) Temp\tr_us_2010-2018_p2", replace


***(3) Merge both files
merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\tr_us_2010-2018_p1", force
drop _merge

***(4) Clean merged file and create year, month, day variables
drop if wc06008==""
drop if wc02999==.
drop if wc05350==""
drop if wc07011==.
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503
drop if year>2019


***(5) Indicate US data origin and save
gen Sample="US"
sort wc06008 wc05350
save "$PATH\(2) Temp\tr_us_2010-2018_p12", replace


*-------------------------------------------------------------------------------
*  (1.3): Add EU & US ASSET4 CSR data (2010-2018) from multiple source files  
*-------------------------------------------------------------------------------

***(1) Insert five EU ASSET4 data files
qui	forvalues i = 1(1)5 {
	***
	insheet using "$PATH\(1) Data\TR_data_2020-04\Lian Auftrag\csr_eu_2010-2018_p`i'.txt",  clear 
	drop if wc06008==""
	drop if wc05350==""
	drop if wc06008=="NA"
	drop if wc05350=="NA"
	duplicates drop wc06008 wc05350, force
	sort wc06008 wc05350
	save "$PATH\(2) Temp\csr_eu_2010-2018_p`i'", replace
}
***

***(2) Merge five EU ASSET4 data files and create time variables
use "$PATH\(2) Temp\csr_eu_2010-2018_p1", clear
qui	forvalues i = 2(1)5 {
	***
	merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\csr_eu_2010-2018_p`i'", force
	keep if _merge==3
	drop _merge
}
***
drop if wc06008==""
drop if wc05350==""
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503
drop if year>2019

***(3) Indicate EU data origin and save
gen Sample="EU"
sort wc06008 wc05350
save "$PATH\(2) Temp\csr_eu_2010-2018_pAll", replace


***(4) Include five US ASSET4 data files
qui	forvalues i = 1(1)5 {
	***
	insheet using "$PATH\(1) Data\TR_data_2020-04\Lian Auftrag\csr_us_2010-2018_p`i'.txt",  clear 
	drop if wc06008==""
	drop if wc05350==""
	drop if wc06008=="NA"
	drop if wc05350=="NA"
	duplicates drop wc06008 wc05350, force
	sort wc06008 wc05350
	save "$PATH\(2) Temp\csr_us_2010-2018_p`i'", replace
}
***

***(5) Merge five US ASSET4 data files and create time variables
use "$PATH\(2) Temp\csr_us_2010-2018_p1", clear
qui	forvalues i = 2(1)5 {
	***
	merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\csr_us_2010-2018_p`i'", force
	keep if _merge==3
	drop _merge
}
***
drop if wc06008==""
drop if wc05350==""
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503
drop if year>2019

***(6) Indicate US data origin and save
gen Sample="US"
sort wc06008 wc05350
save "$PATH\(2) Temp\csr_us_2010-2018_pAll", replace


***(7) Append EU and US ASSET4 data files
use "$PATH\(2) Temp\csr_eu_2010-2018_pAll", clear
append using "$PATH\(2) Temp\csr_us_2010-2018_pAll", force


***(8) Keep ASSET4 CSR data for which summary ratings are available
drop if enscore==.


***(9) Save combined EU & US ASSET4 data
sort wc06008 wc05350
save "$PATH\(2) Temp\csr_euus_2010-2018_pAll", replace




*-------------------------------------------------------------------------------
*  (1.4): Add international (Norway & Switzerland) data  
*-------------------------------------------------------------------------------


***(1) Insert five ASSET4 INT Data
qui	forvalues i = 1(1)5 {
	***
	insheet using "$PATH\(1) Data\TR_data_2020-04\Jana Auftrag\CSR_INT_`i'.txt",  clear 
	drop if wc06008==""
	drop if wc05350==""
	drop if wc06008=="NA"
	drop if wc05350=="NA"
	duplicates drop wc06008 wc05350, force
	sort wc06008 wc05350
	save "$PATH\(2) Temp\CSR_INT_`i'", replace
}
***

***(2) Merge five ASSET4 INT Data and create time variables
use "$PATH\(2) Temp\CSR_INT_1", clear
qui	forvalues i = 2(1)5 {
	***
	merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\CSR_INT_`i'", force
	keep if _merge==3
	drop _merge
}
***
drop if wc06008==""
drop if wc05350==""
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503
drop if year>2019

***(3) Indicate INT ASSET4 data origin and save
gen Sample="INT"
sort wc06008 wc05350
save "$PATH\(2) Temp\CSR_INT_All", replace


***(4) Insert two WORLDSCOPE INT Data
qui	forvalues i = 1(1)2 {
	***
	insheet using "$PATH\(1) Data\TR_data_2020-04\Jana Auftrag\WS_INT_`i'.txt",  clear 
	drop if wc06008==""
	drop if wc05350==""
	drop if wc06008=="NA"
	drop if wc05350=="NA"
	duplicates drop wc06008 wc05350, force
	sort wc06008 wc05350
	save "$PATH\(2) Temp\WS_INT_`i'", replace
}
***

***(5) Merge two WORLDSCOPE INT Data and create time variables
use "$PATH\(2) Temp\WS_INT_1", clear
merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\WS_INT_2", force
keep if _merge==3
drop _merge
***
drop if wc06008==""
drop if wc05350==""
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503
drop if year>2019


***(6) Indicate INT WORLDSCOPE data origin and save
gen Sample="INT"
sort wc06008 wc05350
save "$PATH\(2) Temp\WS_INT_All", replace


***(7) Merge ASSET4 INT Data & WORLDSCOPE INT Data
use "$PATH\(2) Temp\CSR_INT_All", clear
merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\WS_INT_All", force
keep if _merge==3
drop _merge


***(8) Keep Norway and Switzerland
keep if (wc06027==756|wc06027==578)


***(9) Adjust country-identifier 
tostring wc06027, gen(wc06027s)
rename wc06027 wc06027old
rename wc06027s wc06027


***(10) Check for duplicates and save 
duplicates drop wc06008 wc05350, force
sort wc06008 wc05350
save "$PATH\(2) Temp\INT_2010-2018_All", replace


*-------------------------------------------------------------------------------
*  (1.5): Create Masterfile by merging / appending all data files 
*-------------------------------------------------------------------------------

***(1) Create EU & US WORLDSCOPE file
use "$PATH\(2) Temp\tr_eu_2010-2018_p12", clear
append using "$PATH\(2) Temp\tr_us_2010-2018_p12", force
sort wc06008 wc05350


***(2) Extend EU & US WORLDSCOPE file with ASSET4 data
merge 1:1 wc06008 wc05350 using "$PATH\(2) Temp\csr_euus_2010-2018_pAll", force
drop if wc02999==.
drop if _merge==2
drop _merge


***(3) Append Swiss and Norwegian data
append using "$PATH\(2) Temp\INT_2010-2018_All", force
duplicates drop wc06008 wc05350, force
sort wc06008 wc05350


*** (4) Define firm identifier
egen i=group(wc06008)
gen isin=wc06008


***(5) Check for duplicates
drop if i==.
drop if year==.
duplicates drop i year, force


***(6) Identifying pooled data structure
tsset i year


***(7) Create Year-Dummies (one dummy for each year)
tab year, gen(year_)


*-------------------------------------------------------------------------------
*  (1.6): Labeling variables 
*-------------------------------------------------------------------------------

* COMPANY INFO 
label var wc05350 "Date Of Fiscal Year End (Key Item) "
label var wc06001 "Company Name (Key Item) "
label var wc06008 "Isin Number "
label var wc07011 "Employees (Key Item) "
label var wc06026 "Nation "
label var wc06027 "Nation Code "
label var wc07021 "Sic Code 1 "
label var wc05427 "Stock Exchange(s) Listed"
    
	
* BALANCE 
label var wc03501 "Common Equity (Key Item) "
label var wc02501 "Property, Plant And Equipment - Net (Key Item) "
label var wc02999 "Total Assets (WS) (Key Item) "
label var wc03351 "Total Liabilities (WS) (Key Item) "
label var xwc02999u "Total Assets in USD"


* INCOME 
label var wc01001 "Net Sales Or Revenues (Key Item) "
label var wc01751 "Net Income available to common shareholder"
label var wc05201 "EPS (WS) (Key Item) "
label var wc01051 "Cost of Goods Sold (Excl. Depreciation)"
label var wc01101 "Selling, General & Administrative Expenses"
label var wc01201 "Research & Development Expenses"


* DIVIDENDS, SHARES, AND OWNERSHIP 
label var wc05101 "Dividends Per Share (WS) (Key Item) "
label var nosh "Number of shares "
label var noshff "Free Float Number Of Shares "

    
* CFS AND OTHER INFO 
label var wc01201 "Research & Development Expense(WS) (Key Item) "
label var wc04601 "Capital Expenditures (Additions To Fixed Assets) (Key Item) "
label var wc04860 "Net Cash Flow - Operating Activities (Key Item) "
label var wc05001 "Market Price - Year End "


* Key ASSET4 CSR DATA 
label var cgvsdp029 "CSR Report Global Activities" 
label var cgvsdp030  "CSR Sustainability External Audit" 
label var cgvsdp026  "CSR Sustainability Reporting" 
label var cgscore  "Corporate Governance Score"
label var cgvsdp028  "GRI Report Guidelines" 
label var socodp013  "OECD Guidelines for Multinational Enterprises" 
label var enscore   "Environmental Score" 
label var soscore   "Social Score"  
label var cgvsdp005   "CSR Sustainability Committee" 


* ASSET4 CSR DATA (additional data)
label var cgvsdp020 "Global Compact Signatory" // 
label var cgvsdp025  "UNPRI Signatory" // 
label var  soprdp0546 "Controversies Responsible Marketing" // 
label var  cgcpdp0013  "Policy Executive Compensation ESG Performance" // 
label var  enerdp0051  "Policy Emissions" // 
label var  enrrdp0121  "Policy Water Efficiency" // 
label var  enrrdp0122 "Policy Energy Efficiency" // 
label var  sododp0081  "Policy Diversity and Opportunity" // 
label var  sohrdp0102  "Policy Child Labor" // 
label var  sohrdp0103  "Policy Forced Labor" // 
label var sohrdp0105  "Policy Human Rights" // 
label var sohsdp0121  "Policy Employee Health & Safety" // 
label var soprdp0121  "Policy Customer Health & Safety" // 
label var soprdp0124  "Policy Data Privacy" // 
label var soprdp0126 "Policy Responsible Marketing" // 
label var  soprdp0128 "Policy Fair Trade" //
label var  eccldp040  "Customer Satisfaction" // 
label var  ecpedp039 "Employee Satisfaction" // 
label var enerdp045  "Waste Total" // 
label var  enerdp052 "Waste Recycled Total" // 
label var enerdp062  "Waste Reduction Initiatives" // 
label var enerdp063 "e-Waste Reduction" // 
label var enerdp095 "Environmental Investments Initiatives" // 
label var  enerdp103  "Self-Reported Environmental Fines" // 
label var  enero24v "Environmental Expenditures Investments" //
label var enpidp066  "Renewable/Clean Energy Products" // 
label var enrrdp008  "Environment Management Training" // 
label var  enrrdp033 "Energy Use Total" // 
label var  enrrdp0451  "Renewable Energy Purchased" // 
label var  enrrdp0452  "Renewable Energy Produced" // 
label var  enrrdp046 "Renewable Energy Use" // 
label var socodp027 "Donations Total" // 
label var sohsdp0081 "Health & Safety Training" // 
label var  sohsdp024  "Total Injury Rate Total" // 
label var  sohsdp027  "Accidents Total" // 
label var  sohsdp029  "Employee Accidents" // 
label var  soprdp016 "Product Responsibility Monitoring" // 
label var  sotddp030 "Supplier ESG training" // 
label var  cgcpo07v  "Executive Compensation LT Objectives" //
 

*-------------------------------------------------------------------------------
*  (1.3): Creating Country Identifier 
*-------------------------------------------------------------------------------

********************************************************************************
*
*	NOTE that we need to CONTROL for CROSSLISTINGS (e.g., EU firms into US):
*
*	"NATION CODE (wc06027) represents the country under which the company is followed on Worldscope. 
*	The currency of analysis is the currency of the nation indicated by NATION CODE (wc06027). 
*	NATION CODE (wc06027) usually corresponds to the country of domicile as shown in NATION (wc06026) but there are some exceptions. 
*	For example, the NATION CODE (wc06027) for an ADR record is 840 (United States) and the currency of analysis is USD while NATION (wc06026) shows the non-US country of domicile." 
*	(see Worldscope Definition Guide (Issue 12, 23 February 2012) p. 552)
*
********************************************************************************


***To control for EU CROSSLISTINGS into the US, we apply four steps: 

*(1) drop if NATION CODE (wc06027) and NATION (wc06026) is not available 
drop if wc06026=="NA"
drop if wc06027=="NA"
destring wc06027, replace

*(2) drop US firms with non-US domicile 
drop if wc06027==840 & wc06026!="UNITED STATES"

*(3) drop OTC US firms
drop if wc06027==840 & wc05427=="OTC" 

*(4) check for identical names between US listed and EU listed firms (and remove US listing) 
duplicates tag wc06001 year, gen (_dupl)
drop if wc06027==840 & _dupl>0
drop _dupl 


***Creating Country Identifier based on NATION CODE (WC06027)
gen Country=""
replace Country="Austria" 			if wc06027==40
replace Country="Belgium" 			if wc06027==56
replace Country="Bulgaria" 			if wc06027==100
replace Country="Croatia" 			if wc06027==191
replace Country="Cyprus" 			if wc06027==196
replace Country="Czech Republic" 	if wc06027==203
replace Country="Denmark" 			if wc06027==208
replace Country="Estonia" 			if wc06027==233
replace Country="Finland" 			if wc06027==246
replace Country="France" 			if wc06027==250
replace Country="Germany" 			if wc06027==280
replace Country="Greece" 			if wc06027==300
replace Country="Hungary" 			if wc06027==350
replace Country="Ireland" 			if wc06027==372
replace Country="Italy" 			if wc06027==380
replace Country="Latvia" 			if wc06027==428
replace Country="Lithuania" 		if wc06027==440
replace Country="Luxembourg" 		if wc06027==442
replace Country="Malta" 			if wc06027==470
replace Country="Netherlands" 		if wc06027==528
replace Country="Poland" 			if wc06027==617
replace Country="Portugal" 			if wc06027==620
replace Country="Romania" 			if wc06027==642
replace Country="Slovakia" 			if wc06027==703
replace Country="Slovenia" 			if wc06027==705
replace Country="Spain" 			if wc06027==724
replace Country="Sweden" 			if wc06027==752
replace Country="United Kingdom" 	if wc06027==826
***
replace Country="United States" 	if wc06027==840
***
replace Country="Norway"		 	if wc06027==578
replace Country="Switzerland"	 	if wc06027==756

***Drop INT firms with non-country specific domicile 
drop if wc06027==578 & wc06026!="NORWAY"
drop if wc06027==756 & wc06026!="SWITZERLAND"
drop if year>2018


***Save data
sort i year
save "$PATH\(2) Temp\Master1", replace // master data file with EU and US panel data from 2010 - 2018


*-------------------------------------------------------------------------------
*  (1.5): Handcollected CSR INVESTMENT data (see separate Excel file "FHL_data_2019 10 03") 
*-------------------------------------------------------------------------------

***Handcolletion (as of March 2019)
import excel "$PATH\(1) Data\CSR investments anecdotals\FHL_data_2019 10 03.xlsx", clear first sheet(stata 2.0) 
keep Country wc06008 year NewCSRinitiative Realinitiative CSRcommitteeinitiative CSRdatamgtsysteminitiative SOCreal ENVreal Increasedvisibility_restructure WebpageSource TwitterSource
sort wc06008 year
keep if Country=="United States"
save "$PATH\(2) Temp\CSRhandcollected_data1", replace


***Handcolletion (as of Sept 2020)
import excel "$PATH\(1) Data\CSR investments anecdotals\Collection CSR 2020 June_EU and US nl.xlsx", clear first sheet(Stata) 
drop if wc06008==""
rename AC NewCSRinitiative
rename realinitiative Realinitiative
rename SOC SOCreal
rename ENV ENVreal
rename increasedvisibilityandorrest Increasedvisibility_restructure
rename CSRinitiativesourcewebpage  WebpageSource
rename CSRinitiativesourcetwitter TwitterSource
keep Country wc06008 year NewCSRinitiative Realinitiative CSRcommitteeinitiative CSRdatamgtsysteminitiative SOCreal ENVreal Increasedvisibility_restructure WebpageSource TwitterSource Sample_HandcollRev
sort wc06008 year
save "$PATH\(2) Temp\CSRhandcollected_data2", replace


***Merge both datasets (as of Sept 2020)
merge 1:1 wc06008 year using "$PATH\(2) Temp\CSRhandcollected_data1"
drop _merge
gen Sample_Handcoll=1
sort wc06008 year
save "$PATH\(2) Temp\CSRhandcollected_data3", replace



*-------------------------------------------------------------------------------
*  (1.6): Merge handcollected data to Masterfile 
*-------------------------------------------------------------------------------

use "$PATH\(2) Temp\Master1", clear
sort wc06008 year
merge m:1 wc06008 using "$PATH\(2) Temp\CSRhandcollected_data3"
drop if _merge==2
drop _merge
sort i year
save "$PATH\(2) Temp\Master1_merge", replace


********************************************************************************
********************************************************************************
*  Step 2: Compute key variables
********************************************************************************
********************************************************************************

*-------------------------------------------------------------------------------
*  (2.1): ASSET4 CSR variables  
*-------------------------------------------------------------------------------


***(1) CSR activities variables (Following Lys et al. (2015, JAE), we divide the raw scores by 100)

replace soscore = soscore/100 
replace enscore = enscore/100 
gen CSR=((soscore + enscore)/2)
label var CSR "CSR Activities (main DV)"


***(2) CSR Disclosure variables (Note: if GRI report available, CSRreporting should be 1 as well, see Commerzbank, 2012)

gen CSRreportingD=0
replace CSRreportingD=1 if cgvsdp026=="Y"
replace CSRreportingD=1 if cgvsdp028=="Y"
***
gen CSRgriD=0
replace CSRgriD=1 if cgvsdp028=="Y"
***
gen CSRauditD=0
replace CSRauditD=1 if cgvsdp030=="Y"
***
gen CSRoecd=0
replace CSRoecd=1 if socodp013=="Y"
***
gen CSRreportGlobal=0
replace CSRreportGlobal=1 if cgvsdp029=="Y"
***
gen CSRreportScore=CSRreportingD+CSRgriD+CSRauditD+CSRoecd+CSRreportGlobal
label var CSRreportScore "CSR Reporting Score"


***(3) CSR Infrastructure variables

gen CSRcommittee=0
replace CSRcommittee=1 if cgvsdp005=="Y"
label var  CSRcommittee  "CSR committee" // 
***
gen ESGCompPOLICY=0
replace ESGCompPOLICY=1 if cgcpdp0013=="Y"
label var ESGCompPOLICY "Executive compensation ESG performance Policy"
***
gen CSRtraining=0 
replace CSRtraining=1 if enrrdp008=="Y" // "Environment Management Training"
replace CSRtraining=1 if sohsdp0081=="Y" // "Health & Safety Training"
replace CSRtraining=1 if sotddp030=="Y" // "Supplier ESG training"
label var CSRtraining "CSR training"

gen CSRInfra=CSRtraining+ CSRcommittee +ESGCompPOLICY
label var CSRInfra "CSR infrastructure (combined measure)"

gen CSRInfra_core=CSRcommittee +ESGCompPOLICY // FN26 (untabulated tests)
label var CSRInfra_core "CSR infrastructure (combined measure without training)"



***(4) CSR (Placebo) variables

gen GCsign=0
replace GCsign=1 if cgvsdp020=="Y"
label var GCsign "global compact signatory"
***
gen UNPRIsign=0
replace UNPRIsign=1 if cgvsdp025=="Y"
label var UNPRIsign "UN principles of responsible investments signatory"
***
gen ExeccompLT=0 
replace ExeccompLT=1 if cgcpo07v=="Y"
label var  ExeccompLT  "Executive compensation LT objectives" 


***(5) CSR Initiatives (+ New CSR score), Quantitative measures, Greenwashing measures

*Environmental REDUCTION initiatives: 
gen EnergyEffPOLICY=0
replace EnergyEffPOLICY=1 if enrrdp0122=="Y"
gen EmissionPOLICY=0 
replace EmissionPOLICY=1 if enerdp0051=="Y"
gen WaterEffPOLICY=0 
replace WaterEffPOLICY=1 if enrrdp0121=="Y"
gen WaterReducInitiat=0 
replace WaterReducInitiat=1 if enerdp062=="Y"
gen eWasteReducInitiat=0 
replace eWasteReducInitiat=1 if enerdp063=="Y"
gen RenEnergyUse=0 
replace RenEnergyUse=1 if enrrdp046=="Y"
gen CleanEnergyPoduct=0
replace CleanEnergyPoduct=1 if enpidp066=="Y"
***
gen EnvReduct=EnergyEffPOLICY+EmissionPOLICY+ WaterEffPOLICY+WaterReducInitiat+ eWasteReducInitiat  + RenEnergyUse+ CleanEnergyPoduct
label var EnvReduct "Environmental reduction policy and intiatives based on energy, emission, water policies, water, ewaste, ren energy, clean energy, emission initiatives"


*Environmental INVESTMENT initiatives: 
gen EnvExpendInvest_1=0 
replace EnvExpendInvest_1=1 if enero24v=="Y"
gen EnvExpendInvest_2=0 
replace EnvExpendInvest_2=1 if enerdp095=="Y"
***
gen EnvInvestInitiatives=EnvExpendInvest_1 + EnvExpendInvest_2 
label var EnvInvestInitiatives "Environmental investment initiative based on EnvExpendInvest and EnvInvestInitiat"


*Social LABOR initiatives: 
gen DiversityPOLICY=0 
replace DiversityPOLICY=1 if sododp0081=="Y"
gen ChildLaborPOLICY=0 
replace ChildLaborPOLICY=1 if sohrdp0102=="Y"
gen ForcedLaborPOLICY=0 
replace ForcedLaborPOLICY=1 if sohrdp0103=="Y"
gen HumanRightPOLICY=0 
replace HumanRightPOLICY=1 if sohrdp0105=="Y"
gen EmplHealthPOLICY=0
replace EmplHealthPOLICY=1 if sohsdp0121=="Y"
***
gen LaborPolicy=DiversityPOLICY+ChildLaborPOLICY+ForcedLaborPOLICY+HumanRightPOLICY+EmplHealthPOLICY 
label var LaborPolicy "Labor policy based on diversity, child labor, forced labor, Human R., empl health policies"


*Social CUSTOMER initiatives: 
gen CustHealthPOLICY=0 
replace CustHealthPOLICY=1 if soprdp0121=="Y"
gen DataPrivacyPOLICY=0
replace DataPrivacyPOLICY=1 if soprdp0124=="Y"
gen RespMarketingPOLICY=0 
replace RespMarketingPOLICY=1 if soprdp0126=="Y"
gen FairTradePOLICY=0
replace FairTradePOLICY=1 if soprdp0128=="Y"
gen ProdRespMonitor=0 
replace ProdRespMonitor=1 if soprdp016=="Y"
***
gen CustPolicy=CustHealthPOLICY+DataPrivacyPOLICY+RespMarketingPOLICY+FairTradePOLICY+ProdRespMonitor
label var CustPolicy "Customer policy based on cust health, data privacy, respons. marketing, fair trade"


*Key ENV and SOC quantiative measures
gen Waste_TA= enerdp045/xwc02999u 
gen EnergyUse_TA= enrrdp033/xwc02999u 
gen TotalInjury=sohsdp024
gen Donations_TA= socodp027/wc02999 // Donations is already in local currency (hence "wc02999" instead of "xwc02999u")


*Alternative quantiative measures for SOC (Online Appendix I)
gen AccidentsTotal_TA=(sohsdp027/xwc02999u)*1000 
gen AccidentsEmployee_TA=(sohsdp029/xwc02999u)*1000
gen Cust_Satisfaction=eccldp040
gen Empl_Satisfaction=ecpedp039


*Alternative quantiative measures for ENV (Online Appendix I)
gen SelfReportENVFines_TA= enerdp103/xwc02999u 
gen RecWaste_TA= enerdp052/xwc02999u 
gen RenewEnergyPurchased_TA=enrrdp0451/xwc02999u
gen RenewEnergyProduced_TA=enrrdp0452/xwc02999u


*Greenwashing-related communication
gen RespMarketingControversies=0
replace RespMarketingControversies=1 if soprdp0546>0 & soprdp0546!=.
gen RespMarketingPolicy=0
replace RespMarketingPolicy=1 if soprdp0126=="Y"


***(6) Other ASSET4 variables

replace cgscore = cgscore/100 
label var cgscore "Corporate Governance Score"


***(7) Sample Identifier (CSR_sample) 
 
pca CSR CSRreportScore 
predict CSR_sample, score


*-------------------------------------------------------------------------------
*  (2.2): Winsorize ASSET4 CSR VARs
*-------------------------------------------------------------------------------

***Winsorize separately for US and EU sample
 foreach x of varlist CSR - Donations_TA RespMarketingControversies {
		winsor `x' if Sample=="EU", generate (helpEUwin99) p(0.01)
		winsor `x' if Sample=="US", generate (helpUSwin99) p(0.01)
		winsor `x' if Sample=="INT", generate (helpINTwin99) p(0.01)
		gen `x'win99=.
		replace `x'win99=helpEUwin99  if  Sample=="EU"
		replace `x'win99=helpUSwin99  if  Sample=="US"
		replace `x'win99=helpINTwin99 if  Sample=="INT"
		drop helpEUwin99 helpUSwin99 helpINTwin99		
 }
*

*-------------------------------------------------------------------------------
*  (2.3): Non-CSR Dependent (or control) variables  
*-------------------------------------------------------------------------------

***Tobin's Q
gen lnQ = ln((wc02999+(nosh*wc05001)-wc03501) / (wc02999))
label var lnQ "Ln of Tobin's Q based on Worldscope data"

***ROA 
gen ROA = wc01751/wc02999
label var ROA "NI available to common shareholder to total assets"

***ROE 
gen ROE = wc01751/wc03501
label var ROE "NI available to common shareholder to common equity"

***Operating Expense 
gen COGS_Sales = wc01051/wc01001
label var COGS_Sales "Cost of Goods Sold (Excl. Depreciation) divided by sales revenue"

gen SGA_Sales = wc01101/wc01001
label var SGA_Sales "Selling, General & Administrative Expenses divided by sales revenue"

 foreach x of varlist COGS_Sales SGA_Sales{
		replace `x' =0 if `x' ==.		
 }
 
***CAPEX 
gen help1=wc01201
replace help1=0 if wc01201==. // set missing R&D value = 0

gen CAPEXRD_TA = (wc04601+help1)/l.wc02999
label var CAPEXRD_TA "Capital Expenditures (Additions To Fixed Assets) and R&D expenses to lagged total assets"
drop help1 
 
 
***Winsorize separately for US and EU sample
 foreach x of varlist lnQ-CAPEXRD_TA  {
		winsor `x' if Sample=="EU", generate (helpEUwin99) p(0.01)
		winsor `x' if Sample=="US", generate (helpUSwin99) p(0.01)
		winsor `x' if Sample=="INT", generate (helpINTwin99) p(0.01)
		gen `x'win99=.
		replace `x'win99=helpEUwin99  if  Sample=="EU"
		replace `x'win99=helpUSwin99  if  Sample=="US"
		replace `x'win99=helpINTwin99 if  Sample=="INT"
		drop helpEUwin99 helpUSwin99 helpINTwin99			
 }
*

***Sample Identifier (DV_sample)
pca ROA lnQ COGS_Sales SGA_Sales
predict DV_sample, score


*-------------------------------------------------------------------------------
*  (2.4): Control variables  
*-------------------------------------------------------------------------------


***Firm Size 
gen lnsize=ln(xwc02999u)
label var lnsize "Ln of total assets (xwc02999u) in USD "

***Leverage
gen lev=wc03351 /wc02999 
label var lev"Accounting leverage total liability (wc03351) to ta (wc02999)"

***Cash flow from operations
gen cfo=wc04860/wc02999 
label var cfo "Cash flow from operations (direct) deflated by ta"

***Percentage change in dividends per share
gen ddps=wc05101/wc05201 
label var ddps "dividends per share (wc05101) scaled by earnings per share (wc05201)"

***Asset turnover
gen ATO=wc01001/wc02999 
label var ATO "Net sales divided by total assets, measured at the end of fiscal year" 


***Ownership structure 
gen lognoshff=log(noshff+1) 


***PPE to TA
gen PPE_TA=wc02501/wc02999
label var PPE_TA "Net PPE (wc02501) to total assets (wc02999)"


***Industry membership: FAMA & FRENCH industry classification (http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/det_12_ind_port.html)
ffind wc07021 , newvar(ffi12) type(12) 
ffind wc07021 , newvar(ffi48) type(48) 
gen ind1=ffi12 
label var ind1 "Fama & French 12 industry group"
tab ind1, gen(ind1_)
gen ind2=ffi48 
label var ind2 "Fama & French 48 industry group"


***Financial analyst following (Capital market visibility)
gen lnAF=ln(recno)
label var lnAF "Financial analyst following (based on recno)"

 foreach x of varlist lnAF {
	replace `x'=0 if `x'==.
}
*

***Mean-industry-adjusted firm-level CSR values (separated for EU & US and per FF12 ind & Year) 

*For loop commands: 
* ind1=ffi12 
* ind2=ffi48

 foreach x of varlist CSR {
	***
	forvalues i= 1(1)1 {
	
	*(a)Based on all industry-year observations
	egen helpEU1=mean(`x') if Sample=="EU", by(ind`i' year)
	egen helpUS1=mean(`x') if Sample=="US", by(ind`i' year)
	egen helpINT1=mean(`x') if Sample=="INT", by(ind`i' year)
	***
	gen helpEU2=`x'-helpEU1 if Sample=="EU"
	gen helpUS2=`x'-helpUS1 if Sample=="US"
	gen helpINT2=`x'-helpINT1 if Sample=="INT"
	***
	gen `x'_ind`i'=. // based on all industry-year observations
	replace `x'_ind`i'=helpEU2 if Sample=="EU"
	replace `x'_ind`i'=helpUS2 if Sample=="US"
	replace `x'_ind`i'=helpINT2 if Sample=="INT"
	***
	drop helpEU1 helpUS1 helpINT1 helpEU2 helpUS2 helpINT2
	***
	
	}
}
*

*-------------------------------------------------------------------------------
*  (2.5): Winsorize firm-level control variables    
*-------------------------------------------------------------------------------

***Winsorize separately for US and EU sample
 foreach x of varlist lnsize - lnAF CSR_ind1 {
		winsor `x' if Sample=="EU", generate (helpEUwin99) p(0.01)
		winsor `x' if Sample=="US", generate (helpUSwin99) p(0.01)
		winsor `x' if Sample=="INT", generate (helpINTwin99) p(0.01)
		gen `x'win99=.
		replace `x'win99=helpEUwin99  if  Sample=="EU"
		replace `x'win99=helpUSwin99  if  Sample=="US"
		replace `x'win99=helpINTwin99 if  Sample=="INT"
		drop helpEUwin99 helpUSwin99 helpINTwin99		
}
*

***Sample Identifier (CONTROL_sample)
pca lnsize lev  cfo lnAF lognoshff  ATO ddps PPE_TA lnQ ROA ROE CAPEXRD_TA 
predict CONTROL_sample, score

*-------------------------------------------------------------------------------
*  (2.6): Local time trend in CSR activities and CSR reporting (unbalanced sample) 
*-------------------------------------------------------------------------------

foreach x of varlist CSR {
		***
		egen help1=median(`x') if wc07011<500 , by(year Sample)
		egen `x'_LTP50Unbal=max(help1), by(year Sample)
		drop help1	
}
*

*-------------------------------------------------------------------------------
*  (2.7): Define subsamples w.r.t. individual data availability   
*-------------------------------------------------------------------------------

***Overall Sample
gen sample1 = .
replace sample1=1 if (CSR_sample!=. &  CONTROL_sample!=. & wc07011!=. ) // Core sample requirements

gen sample2 = .
replace sample2=1 if (CONTROL_sample!=. & wc07011!=.) // Without Asset4 data requirements

gen sample3 = .
replace sample3=1 if (CSR_sample!=. & wc07011!=.) // Without Worldscope data requirements


***Save data
sort wc06008 year
save "$PATH\(2) Temp\Master2", replace // master data file with EU and US panel data from 2010 - 2018




********************************************************************************
********************************************************************************
*  Step 3: Impose balanced sample restrictions & define DiD structure
********************************************************************************
********************************************************************************


*-------------------------------------------------------------------------------
*  (3.1): Define balanced DiD samples for each subsample 
*-------------------------------------------------------------------------------

macro dir 
macro drop NYEARS NPREYEARS PREYEARS YEARTM2 YEARTM1 YEARTP1 YEARTP2
global NYEARS 		"8" 	// 8-years panel structure (default: 2011-2018)
global NPREYEARS 	"3" 	// 3-years panel structure (default: 2011-2013)
global PREYEARS		"year==2011|year==2012|year==2013"
global POSTYEARS	"year==2014|year==2015|year==2016|year==2017|year==2018" 
global YEARTM2 		"2009" 	// downloaded data commonly starts with 2009 values
global YEARTM1 		"2010" 
global YEARTP1 		"2019" 	
global YEARTP2 		"2020" 	


set more off
	forvalues i = 1(1)3 {
		
		use "$PATH\(2) Temp\Master2", replace
		drop if  sample`i' ==. // creates sample selection specific balanced samples 

		*-------------------------------------------------------------------------------
		*  (3.1.1): Define Complete (EU&US), EU, US, and INT BALANCED samples
		*-------------------------------------------------------------------------------
		
		*(1)COMPLETE ALL (EU & US)	
		gen company_id=i 
		replace company_id=0 if year==$YEARTM2 
		replace company_id=0 if year==$YEARTM1 
		replace company_id=0 if year==$YEARTP1
		replace company_id=0 if year==$YEARTP2
		***
		bysort company_id: gen eventcount=_N 		
		replace eventcount=0 if company_id==0
		***
		gen CompleteSample=0 // defines complete (EU&US) panel sample
		replace CompleteSample=1 if eventcount==$NYEARS
		drop eventcount
		
		*(2)EU ONLY 
		gen Treatment_id = company_id
		replace Treatment_id=0 if Sample!="EU"
		replace Treatment_id=0 if wc07011<500 // excludes firms with below 500 employees
		***  
		bysort  Treatment_id: gen eventcount=_N 
		replace eventcount=0 if company_id==0
		replace eventcount=0 if Treatment_id==0
		***
		gen CompleteSampleEU=0 // defines EU only panel sample
		replace CompleteSampleEU=1 if eventcount==$NYEARS
		drop eventcount Treatment_id
		
		*(3)US ONLY 	
		gen Treatment_id = company_id
		replace Treatment_id=0 if Sample!="US"
		replace Treatment_id=0 if wc07011<500 // excludes firms with below 500 employees
		***
		bysort  Treatment_id: gen eventcount=_N 
		replace eventcount=0 if company_id==0
		replace eventcount=0 if Treatment_id==0
		***
		gen CompleteSampleUS=0 // defines US only panel sample
		replace CompleteSampleUS=1 if eventcount==$NYEARS
		drop eventcount Treatment_id
			
		*(4)INT ONLY 	
		gen Treatment_id = company_id
		replace Treatment_id=0 if Sample!="INT"
		replace Treatment_id=0 if wc07011<500 // excludes firms with below 500 employees
		***
		bysort  Treatment_id: gen eventcount=_N 
		replace eventcount=0 if company_id==0
		replace eventcount=0 if Treatment_id==0
		***
		gen CompleteSampleINT=0 // defines INT only panel sample
		replace CompleteSampleINT=1 if eventcount==$NYEARS
		drop eventcount Treatment_id	
			
				
		*-------------------------------------------------------------------------------
		*  (3.1.2): Define EU, US, and INT below-500-employees BALANCED subsamples (<500)
		*-------------------------------------------------------------------------------

		*(1)EU CONTROL1: EU Firms (<500)
		gen nonTreatment_id=1
		replace nonTreatment_id=0 if wc07011>499
		replace nonTreatment_id=0 if Sample!="EU"
		***
		bysort  nonTreatment_id  company_id: gen eventcount=_N 
		replace eventcount=0 if company_id==0
		replace eventcount=0 if nonTreatment_id==0
		***
		gen Control1aEU=0 // defines EU below 500 firms
		replace Control1aEU=1 if eventcount==$NYEARS
		drop eventcount nonTreatment_id

		*(2)US CONTROL1: US Firms (<500)
		gen nonTreatment_id=1
		replace nonTreatment_id=0 if wc07011>499
		replace nonTreatment_id=0 if Sample!="US"
		***
		bysort  nonTreatment_id  company_id: gen eventcount=_N 
		replace eventcount=0 if company_id==0
		replace eventcount=0 if nonTreatment_id==0
		***
		gen Control1aUS=0 // defines US below 500 firms
		replace Control1aUS=1 if eventcount==$NYEARS
		drop eventcount nonTreatment_id

		*(3)INT CONTROL1: INT Firms (<500)
		gen nonTreatment_id=1
		replace nonTreatment_id=0 if wc07011>499
		replace nonTreatment_id=0 if Sample!="INT"
		***
		bysort  nonTreatment_id  company_id: gen eventcount=_N 
		replace eventcount=0 if company_id==0
		replace eventcount=0 if nonTreatment_id==0
		***
		gen Control1aINT=0 // defines INT below 500 firms
		replace Control1aINT=1 if eventcount==$NYEARS
		drop eventcount nonTreatment_id
		
		
		
		*-------------------------------------------------------------------------------
		*  (3.1.3): Define TIME STRUCTURE
		*-------------------------------------------------------------------------------

		gen Post= $POSTYEARS
		gen Ante= $PREYEARS
 		
		foreach x of varlist CompleteSample-Control1aINT {
		gen Post_`x'=`x'*Post
		}
		***		
			
		*-------------------------------------------------------------------------------
		*  (3.1.4): Subsample specific labeling
		*-------------------------------------------------------------------------------
		
		foreach x of varlist CompleteSample-Post_Control1aINT {
		rename `x' `x'_s`i'
		}
		***
		
		*-------------------------------------------------------------------------------
		*  (3.1.5): Clean and save
		*-------------------------------------------------------------------------------
				
		keep isin year CompleteSample_s`i' - Post_Control1aINT_s`i'
		***
		save "$PATH\(2) Temp\Master2_s`i'", replace	
}
***




*-------------------------------------------------------------------------------
*  (3.2): Merge Subsamples and Sample Selection variables with Masterfile 
*-------------------------------------------------------------------------------

set more off
use "$PATH\(2) Temp\Master2_s1", replace
sort isin year
 forvalues i = 2(1)3 {
		merge 1:1 isin year using "$PATH\(2) Temp\Master2_s`i'"
		drop _merge
		save "$PATH\(2) Temp\Master2_sALL", replace
}
*

use "$PATH\(2) Temp\Master2", replace
sort isin year
set more off
merge 1:1 isin year using "$PATH\(2) Temp\Master2_sALL"
drop if _merge ==2
drop _merge
	

*-------------------------------------------------------------------------------
*  (3.3): Adjust Selection Variables for Masterfile 
*-------------------------------------------------------------------------------
	
set more off	
 forvalues i = 1(1)3 {
		foreach x of varlist CompleteSample_s`i' - Post_Control1aINT_s`i' {
		replace  `x' =0 if `x'==.
		}
}
*
capture drop sample1-sample3



*-------------------------------------------------------------------------------
*  (3.4): Local time trend in CSR activities and CSR reporting (balanced sample) 
*-------------------------------------------------------------------------------

macro drop SAMPLE_EU SAMPLE_US
global SAMPLE_EU		"Control1aEU_s3" // Control1aEU_s1
global SAMPLE_US 		"Control1aUS_s3" // Control1aUS_s1


 foreach x of varlist CSR {
		***
		egen help1=median(`x') if wc07011<500 & ($SAMPLE_EU|$SAMPLE_US), by(year Sample)
		egen `x'_LTP50Bal=max(help1), by(year Sample)
		drop help1 
		***
		egen help1=median(`x') if ((wc07011<250 & Country=="Denmark")|(wc07011<250 & Country=="Sweden")|(wc07011<500 & Country!="Denmark" & Country!="Sweden")) & Country!="Greece" & ($SAMPLE_EU|$SAMPLE_US), by(year Sample)
		egen `x'_LTP50Bal_adj1=max(help1), by(year Sample)
		drop help1 
		***
		egen help1=median(`x') if wc07011<500 & Country!="Greece" & Country!="Denmark" & Country!="Sweden" & ($SAMPLE_EU|$SAMPLE_US), by(year Sample)
		egen `x'_LTP50Bal_adj2=max(help1), by(year Sample)
		drop help1 
}
*




***Save data

sort wc06008 year
save "$PATH\(2) Temp\Master3", replace 
***
use "$PATH\(2) Temp\Master3", clear


	
*-------------------------------------------------------------------------------
*  (3.4.2): Propensity Score Matching (PSM) 
*-------------------------------------------------------------------------------

	
********************************************************************************
*
*	PSM Strategy (April 2019):
*	- With replacement (to increase matching power, see Shipman et al., 2017, TAR)
*	- One-on-one matching as default
*	- Caliper of 0.05 (for max. caliper size, see Shipman et al., 2017, TAR, p. 221)
*	- Matching is based on the average values of the covariates over the pre-period (2011-2013) - we use mean values to keep balanced panel structure.
*	- PSM (1): EU complete (>500) balanced sample vs. US complete (>500) balanced sample
*
********************************************************************************



 forvalues i = 1(1)1 {
		use "$PATH\(2) Temp\Master3", clear
		
		
		*(1)Define GENERAL PSM Parameter
		macro drop PERIOD CALIPER NUMBERNB PREYEAR VARLIST // macro dir (to check existing macros)
		global EXCLUDE		"!(Control1aEU_s1|Control1aUS_s1|Control1aINT_s1)" // exclude firms with below 500 empl.
		global PERIOD 		"Ante_s1" // Ante_s1 comprises the years 2011-2013
		global CALIPER		"caliper(0.05)" // defines the caliper size "caliper(0.05)"
		global NUMBERNB		"1" // defines the number of included nearest neighbors
		global PREYEAR		"year==2013" // selects base year (year prior to passage of the CSR Directive)
		global VARLIST		"CSR CSRreportScore lnsizewin99 lnAFwin99 levwin99 cfowin99 lognoshffwin99 ATOwin99 ddpswin99 PPE_TAwin99 lnQwin99 ROAwin99 ind1_1- ind1_12  " 
		global OUTCOME		"CSR"
			
		*(2)Define SAMPLE SPECIFIC PSM Parameter
		*PSM (1): EU vs. US 		
		gen TREATMENT1 = CompleteSampleEU_s1
		gen CG1 = CompleteSampleUS_s1
		

		*(3)Define Outcome & Matching Variables: Base PSM on average values of covariates for pre-treatment period (2011-2013) to keep balanced sample structure
		foreach x of varlist $OUTCOME {
		egen OUTCOMEVAR=mean(`x') if  (TREATMENT`i'|CG`i') & ($PERIOD) & $EXCLUDE, by(i)
		}
		***
		foreach x of varlist $VARLIST {
		egen `x'_avMV=mean(`x') if  (TREATMENT`i'|CG`i') & ($PERIOD) & $EXCLUDE, by(i)
		}
		macro drop MATCHINGVAR
		global MATCHINGVAR	"*_avMV" 
		***
		
		*(4)PSM Command
		psmatch2 TREATMENT`i' $MATCHINGVAR if (TREATMENT`i'|CG`i') & ($PREYEAR) & $EXCLUDE, outcome(OUTCOMEVAR) $CALIPER n($NUMBERNB)
		sum _nn // number of matched neighbors
		
		*(5)Rosenbaum (2002) hidden bias analysis
		gen diff =  OUTCOMEVAR - _OUTCOMEVAR
		rbounds diff, gamma(1(.1)3) alpha(.90)
		
		*(6)Describe sample differences
		pstest $MATCHINGVAR, both graph
		sum  OUTCOMEVAR if TREATMENT`i' & ($PREYEAR) & $EXCLUDE // Unmatched differences
		sum  OUTCOMEVAR if CG`i' & ($PREYEAR) & $EXCLUDE  // Unmatched differences
		
		*(7)Select matched sample
		sort _id
		gen test=_weight*$NUMBERNB
		replace test=_weight if TREATMENT`i'
		egen max_weight=max(test) , by(i)
		drop if max_weight==.
		expand max_weight
		drop test
		
		*(8)Matched differences
		sum  OUTCOMEVAR if TREATMENT`i' & ($PREYEAR) & $EXCLUDE
		sum  OUTCOMEVAR if CG`i' & ($PREYEAR) & $EXCLUDE
		
		*(9)Set balanced sample structure and account for US duplicates due to the "replacement" option in PSM 
		duplicates report i year
		duplicates tag i year, gen(_dupl)
		bysort year i: gen DuplID=_n
		egen firmID=group(i DuplID)
		duplicates report firmID year
		xtset firmID year


		*(10)Save Matched Sample
		gen PSM`i'=1
		drop _pscore-max_weight TREATMENT1-CG1 OUTCOMEVAR
		save "$PATH\(2) Temp\PSMhelp`i'Master3", replace
}
***

*-------------------------------------------------------------------------------
*  (3.6): Sample Overview and Append PSM Files 
*-------------------------------------------------------------------------------

***Add PSM sample to unmatched Masterfile
use "$PATH\(2) Temp\Master3", clear
gen UNMATCHED=1
append using "$PATH\(2) Temp\PSMhelp1Master3"
replace PSM1=0 if PSM1==.
replace UNMATCHED=0 if UNMATCHED==.

***Save data
sort wc06008 year
save "$PATH\(2) Temp\Master4", replace
***
use "$PATH\(2) Temp\Master4", clear


********************************************************************************
*
*	SAMPLE DEFINITIONS AND CODING OVERVIEW:
*
*	Master4, clear // Masterfile that includes both, unmatched sample and PSM sample
*
*	keep if UNMATCHED==1	//	All TG & CG unmatched
*								
*		EU SUBSAMPLES (indicator variables):	
*			Control1aEU_s1			=	EU firms with below 500 employees
*			CompleteSampleEU_s1		=	Complete EU sample (ONLY includes EU firms that have constantly above 500 employees) 
*
*		US SUBSAMPLES (indicator variables):
*			Control1aUS_s1			=	US with below 500 employees 
*			CompleteSampleUS_s1		=	Complete US sample (ONLY includes US firms that have constantly above 500 employees) 
*
*		INT SUBSAMPLES (indicator variables):
*			Control1aINT_s1			=	INT firms (Swiss and Norwegian firms) with below 500 employees 
*			CompleteSampleUS_s1		=	Complete INT sample (ONLY includes INT firms that have constantly above 500 employees) 
*
*		COMPLETE SAMPLE (indicator variables):
*			CompleteSample_s1		=	Sample includes all EU, US, and INT firms (includes all above and below 500 firms with balanced sample)
*
*	keep if PSM1==1 	//	EU complete (>500) balanced sample & matched US complete (>500) 	// 	(CompleteSampleEU_s1|CompleteSampleUS_s1) & !(Control1aEU_s1|Control1aUS_s1) 					
*
********************************************************************************




*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*		I. SAMPLE
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////



********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 1: Sample description
*
********************************************************************************
********************************************************************************
********************************************************************************


use "$PATH\(2) Temp\Master4", clear
keep if UNMATCHED==1

macro drop PERIOD 
global PERIOD 	"(year>2010 & year<2019)" 

*-------------------------------------------------------------------------------
* Panel A. Sample Selection
*-------------------------------------------------------------------------------

* (0) Start: EU 28 firms between 2011-2018 (with WORLDSCOPE / IBES data available)
tab year if $PERIOD  & Sample=="EU" & CONTROL_sample !=.
tab year if $PERIOD  & Sample=="US" & CONTROL_sample !=.

* (1) without ASSET4 data 
tab year if $PERIOD & Sample=="EU" & CONTROL_sample !=. & CSR_sample==. 
tab year if $PERIOD & Sample=="US" & CONTROL_sample !=. & CSR_sample==. 

* (2) without number of employees<500
tab year if $PERIOD & Sample=="EU" & CONTROL_sample !=. & CSR_sample!=. & wc07011<500
tab year if $PERIOD & Sample=="US" & CONTROL_sample !=. & CSR_sample!=. & wc07011<500

* (3) without balanced sample structure
tab year if $PERIOD & Sample=="EU" & CONTROL_sample !=. & CSR_sample!=. & wc07011>499 & !(CompleteSampleEU_s1|CompleteSampleUS_s1) 
tab year if $PERIOD & Sample=="US" & CONTROL_sample !=. & CSR_sample!=. & wc07011>499 & !(CompleteSampleEU_s1|CompleteSampleUS_s1) 

* (4) Final sample BEFORE matching
tab year if $PERIOD & Sample=="EU" & CONTROL_sample !=. & CSR_sample!=. & wc07011>499 & (CompleteSampleEU_s1|CompleteSampleUS_s1) & !(Control1aEU_s1|Control1aUS_s1)
tab year if $PERIOD & Sample=="US" & CONTROL_sample !=. & CSR_sample!=. & wc07011>499 & (CompleteSampleEU_s1|CompleteSampleUS_s1) & !(Control1aEU_s1|Control1aUS_s1)

* (5) Final sample AFTER matching
use "$PATH\(2) Temp\Master4", clear
keep if PSM1==1
tab year if $PERIOD & Sample=="EU" & CONTROL_sample !=. & CSR_sample!=. & (CompleteSampleEU_s1|CompleteSampleUS_s1) & !(Control1aEU_s1|Control1aUS_s1)
tab year if $PERIOD & Sample=="US" & CONTROL_sample !=. & CSR_sample!=. & (CompleteSampleEU_s1|CompleteSampleUS_s1) & !(Control1aEU_s1|Control1aUS_s1)



*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*		II. KEY RESULTS
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


*-------------------------------------------------------------------------------
*  (1): Select PSM Sample 
*-------------------------------------------------------------------------------

use "$PATH\(2) Temp\Master4", clear
keep if PSM1==1 // Complete EU sample (>500) and complete US sample (>500) based on PSM	

set matsize 500

*-------------------------------------------------------------------------------
*  (2): Define baseline variables for moderators estimation and regressions
*-------------------------------------------------------------------------------

set more off
sort i year
macro dir  
macro drop CG TREATMENT POST POST_TREAT DV*  CONTROLVAR* PREPERIOD POSTPERIOD PREYEAR SAMPLE FE CLUSTER
global CG				"CompleteSampleUS_s1"
global TREATMENT  		"CompleteSampleEU_s1" 
global POST				"Post_s1"
global POST_TREAT  		"Post_CompleteSampleEU_s1"  
***
global PREPERIOD 		"Ante_s1"
global POSTPERIOD 		"Post_s1"
global PREYEAR	 		"year==2013" // Base year to specify moderators
global SAMPLE	 		"!(Control1aEU_s1|Control1aUS_s1|Control1aINT_s1)" // Exclude firms with below 500 empl.
***
global DV1 				"CSR" 
global DV2 				"soscore" 
global DV3 				"enscore"
***
global CONTROLVAR 		"CSRreportScore lnsizewin99  lnAFwin99 levwin99 cfowin99 lognoshffwin99  ATOwin99 ddpswin99 PPE_TAwin99 lnQwin99 ROAwin99  cgscore"
global CONTROLVAR2 		"               lnsizewin99  lnAFwin99 levwin99 cfowin99 lognoshffwin99  ATOwin99 ddpswin99 PPE_TAwin99 lnQwin99 ROAwin99  cgscore" 
***
egen CountryInd2FE=group(ind2 Country)
egen Ind2Year=group(year ind2)
egen CountryFE=group(Country)
egen CountryYearFE=group(year Country)
***
global FE				"i.Ind2Year" 
global CLUSTER			"ind2" 
***


*-------------------------------------------------------------------------------
*  (3.1): Define - EU - High vs. Low Exposure Firms
*-------------------------------------------------------------------------------

***Key input
gen statusC1 = CSR_ind1   
gen statusC2 = CSRreportScore 

qui	forvalues i = 1(1)2 {
		***
		qui sum statusC`i' if ($TREATMENT) & ($PREYEAR) & $SAMPLE, d
		gen help1=1 if statusC`i' > r(p50) & statusC`i'!=. & ($PREYEAR) & ($TREATMENT) & $SAMPLE
		replace help1=0 if help1==.
		egen statusC`i'highPre=max(help1), by(i)
		drop help1
		***
		qui sum statusC`i' if ($TREATMENT) & ($PREYEAR) & $SAMPLE, d
		gen help1=1 if statusC`i' <= r(p50) & statusC`i'!=. & ($PREYEAR)  & ($TREATMENT) & $SAMPLE
		replace help1=0 if help1==.
		egen statusC`i'lowPre=max(help1), by(i)
		drop help1
		***
		gen PT1statusC`i'high=$POST_TREAT * statusC`i'highPre
		gen PT1statusC`i'low=$POST_TREAT * statusC`i'lowPre
		drop statusC`i'highPre statusC`i'lowPre
		***
}
***
capture drop statusC*
***


***Define High and low EU exposure firms
gen CSR_HH=PT1statusC1high*PT1statusC2high 
gen CSR_HL=PT1statusC1high*PT1statusC2low
gen CSR_LH=PT1statusC1low*PT1statusC2high
gen CSR_LL=PT1statusC1low*PT1statusC2low // EU high exposure firms (indicator 1 = post 2014)
gen CSR_rest=CSR_HL+CSR_LH+CSR_HH // EU low exposure firms (indicator 1 = post 2014)

egen CSR_HHd=max(CSR_HH), by(i) 
egen CSR_HLd=max(CSR_HL), by(i)
egen CSR_LHd=max(CSR_LH), by(i)
egen CSR_LLd=max(CSR_LL), by(i) // EU high exposure firms (indicator 1 for all sample years)
gen CSR_restd=CSR_HLd+CSR_LHd+CSR_HHd // EU low exposure firms (indicator 1 for all sample years)


*-------------------------------------------------------------------------------
*  (3.2): Define - US - High vs. Low Exposure Firms
*-------------------------------------------------------------------------------

***Key input
gen statusC1 = CSR_ind1   
gen statusC2 = CSRreportScore 

***
qui	forvalues i = 1(1)2 {
		***
		qui sum statusC`i' if (CompleteSampleUS_s1) & ($PREYEAR) & $SAMPLE, d
		gen help1=1 if statusC`i' > r(p50) & statusC`i'!=. & ($PREYEAR) & (CompleteSampleUS_s1) & $SAMPLE
		replace help1=0 if help1==.
		egen statusC`i'highPre=max(help1), by(i)
		drop help1
		***
		qui sum statusC`i' if (CompleteSampleUS_s1) & ($PREYEAR) & $SAMPLE, d
		gen help1=1 if statusC`i' <= r(p50) & statusC`i'!=. & ($PREYEAR)  & (CompleteSampleUS_s1) & $SAMPLE
		replace help1=0 if help1==.
		egen statusC`i'lowPre=max(help1), by(i)
		drop help1
		***
		gen PT1statusC`i'highUS=Post_CompleteSampleUS_s1 * statusC`i'highPre
		gen PT1statusC`i'lowUS=Post_CompleteSampleUS_s1 * statusC`i'lowPre
		drop statusC`i'highPre statusC`i'lowPre
		***
}
***
capture drop statusC*
***

***Define High and low US exposure firms
gen CSR_HHUS=PT1statusC1highUS*PT1statusC2highUS
gen CSR_HLUS=PT1statusC1highUS*PT1statusC2lowUS
gen CSR_LHUS=PT1statusC1lowUS*PT1statusC2highUS
gen CSR_LLUS=PT1statusC1lowUS*PT1statusC2lowUS // US high exposure firms (indicator 1 = post 2014)
gen CSR_restUS=CSR_HLUS+CSR_LHUS+CSR_HHUS // US low exposure firms (indicator 1 = post 2014)

egen CSR_HHdUS=max(CSR_HHUS), by(i)
egen CSR_HLdUS=max(CSR_HLUS), by(i)
egen CSR_LHdUS=max(CSR_LHUS), by(i)
egen CSR_LLdUS=max(CSR_LLUS), by(i) // US high exposure firms (indicator 1 for all sample years)
gen CSR_restdUS=CSR_HLdUS+CSR_LHdUS+CSR_HHdUS // US low exposure firms (indicator 1 for all sample years)


*-------------------------------------------------------------------------------
*  (4.1): Pre-Post Differences with HIGH exposure firms
*-------------------------------------------------------------------------------

macro drop CORETREATMENT
global CORETREATMENT 	"CSR_LLd" 

*** Generates "diff_`x'_core" variable based on EU high exposure firms 
 foreach x of varlist CSR soscore enscore CSRtraining CSRcommittee ESGCompPOLICY CSRInfra CSRInfra_core {
		***
		egen pre_`x'=mean(`x') if ($CORETREATMENT) & ($PREPERIOD) & $SAMPLE, by(i)
		egen post_`x'=mean(`x') if ($CORETREATMENT) & ($POSTPERIOD) & $SAMPLE & year<=2018, by(i)
		***
		egen pre_`x'max=max(pre_`x'), by(i)
		egen post_`x'max=max(post_`x'), by(i)
		***
		gen diff_`x'_core=  post_`x'max -pre_`x'max
		***
		drop pre_`x' post_`x' pre_`x'max post_`x'max
}
*


*-------------------------------------------------------------------------------
*  (4.2): Define TWO-fold moderators (second-level interaction)
*-------------------------------------------------------------------------------

*** For continuous variables
gen statusC1 = diff_CSR_core  
gen statusC2 = diff_ESGCompPOLICY_core 
gen statusC3 = diff_CSRcommittee_core   
gen statusC4 = diff_CSRtraining_core  
gen statusC5 = diff_soscore_core  
gen statusC6 = diff_enscore_core  
gen statusC7 = diff_CSRInfra_core 
gen statusC8 = diff_CSRInfra_core_core 

***
qui forvalues i = 1(1)8 {
		***
		*(1) EU TREATMENT GROUP:
		qui sum statusC`i' if ($CORETREATMENT) & ($PREYEAR) & $SAMPLE, d
		gen help1=1 if statusC`i' > r(p50) & statusC`i'!=. & ($PREYEAR) & ($CORETREATMENT) & $SAMPLE
		replace help1=0 if help1==.
		egen statusC`i'highPre=max(help1), by(i)
		drop help1
		***
		qui sum statusC`i' if ($CORETREATMENT) & ($PREYEAR) & $SAMPLE, d
		gen help1=1 if statusC`i' <= r(p50) & statusC`i'!=. & ($PREYEAR)  & ($CORETREATMENT) & $SAMPLE
		replace help1=0 if help1==.
		egen statusC`i'lowPre=max(help1), by(i)
		drop help1
		***
		gen PT2statusC`i'high=$POST_TREAT * statusC`i'highPre
		gen PT2statusC`i'low=$POST_TREAT * statusC`i'lowPre
		drop statusC`i'highPre statusC`i'lowPre
}
***
capture drop statusC*
***


*-------------------------------------------------------------------------------
*  (5): Define YEARLY treatment effects
*-------------------------------------------------------------------------------

set more off
sum year if ($PREPERIOD|$POSTPERIOD)
scalar max2=r(max)
local k=max2

forvalues i=2011(1)`k' {
	gen YEAR_`i'=1 if year==`i'
	replace YEAR_`i'=0 if YEAR_`i'==.
	di `i' " / " `k'
}
***

set more off
sum year if ($PREPERIOD|$POSTPERIOD)
scalar max2=r(max)
local k=max2

foreach varr of varlist PT1statusC1low PT1statusC1high PT1statusC2low PT1statusC2high CSR_restd CSR_LLd CSR_restdUS CSR_LLdUS CompleteSampleEU_s1 {
    egen help1=max(`varr'), by(i)
	gen `varr'D=0 
	replace `varr'D=1 if help1
	drop help1
	***
	forvalues i=2011(1)`k' {
		capture drop YEAR_*
		gen YEAR_`i'=1 if year==`i'
		replace YEAR_`i'=0 if YEAR_`i'==.
		gen `varr'D_Y`i' = `varr'D*YEAR_`i'
		capture drop YEAR_*
		di `i' " / " `k'
	}
	*
}
*



********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 1: Sample description
*
********************************************************************************
********************************************************************************
********************************************************************************

*-------------------------------------------------------------------------------
*  Panel B: Sample distribution per year
*-------------------------------------------------------------------------------

tabstat $DV1  if ($TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, stat(n) by(year)
tabstat $DV1  if ($CG) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, stat(n) by(year)

*-------------------------------------------------------------------------------
*  Panel C: Sample distribution per industry
*-------------------------------------------------------------------------------

tabstat $DV1  if ($TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, stat(n) by(ind1)
tabstat $DV1  if ($CG) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, stat(n) by(ind1)

*-------------------------------------------------------------------------------
*  Panel D: Sample distribution per country
*-------------------------------------------------------------------------------

tabstat $DV1  if ($TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, stat(n) by(Country)
tabstat $DV1  if ($CG) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, stat(n) by(Country)

					
********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 2: Effect of the CSR directive on firm’s CSR disclosures (+ ONLINE APPENDIX G)
*
********************************************************************************
********************************************************************************
********************************************************************************


set matsize 1000
macro drop YEARLYTREAT DV*  
global YEARLYTREAT "CompleteSampleEU_s1D_Y2011 CompleteSampleEU_s1D_Y2012 CompleteSampleEU_s1D_Y2014 CompleteSampleEU_s1D_Y2015 CompleteSampleEU_s1D_Y2016 CompleteSampleEU_s1D_Y2017 CompleteSampleEU_s1D_Y2018" 
*global YEARLYTREAT "PT1statusC2lowD_Y2011 PT1statusC2highD_Y2011 PT1statusC2lowD_Y2012 PT1statusC2highD_Y2012  PT1statusC2lowD_Y2014 PT1statusC2highD_Y2014 PT1statusC2lowD_Y2015 PT1statusC2highD_Y2015 PT1statusC2lowD_Y2016 PT1statusC2highD_Y2016 PT1statusC2lowD_Y2017 PT1statusC2highD_Y2017 PT1statusC2lowD_Y2018 PT1statusC2highD_Y2018"
global DV1 			"CSRreportScore" 
global DV2 			"CSRreportingD"
global DV3 			"CSRreportGlobal"
global DV4 			"CSRgriD"
global DV5 			"CSRoecd"
global DV6 			"CSRauditD"


estimates clear
quietly	xtreg $DV1 $YEARLYTREAT   $CONTROLVAR2 $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV2 $YEARLYTREAT   $CONTROLVAR2 $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV3 $YEARLYTREAT    $CONTROLVAR2 $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV4 $YEARLYTREAT    $CONTROLVAR2 $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV5 $YEARLYTREAT    $CONTROLVAR2 $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV6  $YEARLYTREAT    $CONTROLVAR2 $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
***
esttab,  	star(* 0.10 ** 0.05 *** 0.01)   b(3) stats(F N r2_a p_diff)   title (TABLE 2: Effect of the CSR directive on firm’s CSR disclosures) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep  ($YEARLYTREAT  $CONTROLVAR2) ///
				order ($YEARLYTREAT  $CONTROLVAR2) 
esttab using "$PATH\(3) Output\TABLE2.rtf", replace ///
				star(* 0.10 ** 0.05 *** 0.01)   b(3) stats(F N r2_a p_diff)  label title (TABLE 2: Effect of the CSR directive on firm’s CSR disclosures) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress ///
				varwidth(12)  modelwidth(6) ///
				keep  ($YEARLYTREAT  $CONTROLVAR2) ///
				order ($YEARLYTREAT  $CONTROLVAR2) 
estimates clear



********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 3: Effect of the CSR Directive on firms’ CSR activities (+ Figure 1)
*
********************************************************************************
********************************************************************************
********************************************************************************


set matsize 500
macro drop YEARLYTREAT  DV* 
global YEARLYTREAT "CompleteSampleEU_s1D_Y2011 CompleteSampleEU_s1D_Y2012 CompleteSampleEU_s1D_Y2014 CompleteSampleEU_s1D_Y2015 CompleteSampleEU_s1D_Y2016 CompleteSampleEU_s1D_Y2017 CompleteSampleEU_s1D_Y2018" 
global DV1 			"CSR"
global DV2 			"soscore"
global DV3 			"enscore"

estimates clear
quietly	xtreg $DV1 $YEARLYTREAT   $CONTROLVAR $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV2 $YEARLYTREAT   $CONTROLVAR $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV3 $YEARLYTREAT    $CONTROLVAR $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
***
esttab,  	star(* 0.10 ** 0.05 *** 0.01)   b(3) stats(F N r2_a N_clust p_diff)   title (TABLE 3: Effect of the CSR Directive on firms’ CSR activities) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3") compress ///
				keep  ($YEARLYTREAT  $CONTROLVAR) ///
				order ($YEARLYTREAT  $CONTROLVAR) 
esttab using "$PATH\(3) Output\TABLE3.rtf", replace ///
				star(* 0.10 ** 0.05 *** 0.01)   b(3) stats(F N r2_a N_clust p_diff)  label title (TABLE 3: Effect of the CSR Directive on firms’ CSR activities) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3") compress ///
				varwidth(12)  modelwidth(6) ///
				keep  ($YEARLYTREAT  $CONTROLVAR) ///
				order ($YEARLYTREAT  $CONTROLVAR) 
estimates clear




********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 4: Effect of the CSR Directive on firms’ CSR activities (+ Figure 2)
*
********************************************************************************
********************************************************************************
********************************************************************************

set matsize 500
macro drop YEARLYTREAT  DV*  HIGH_LOW_DID
*global YEARLYTREAT "PT1statusC2lowD_Y2011 PT1statusC2highD_Y2011 PT1statusC2lowD_Y2012 PT1statusC2highD_Y2012  PT1statusC2lowD_Y2014 PT1statusC2highD_Y2014 PT1statusC2lowD_Y2015 PT1statusC2highD_Y2015 PT1statusC2lowD_Y2016 PT1statusC2highD_Y2016 PT1statusC2lowD_Y2017 PT1statusC2highD_Y2017 PT1statusC2lowD_Y2018 PT1statusC2highD_Y2018"
*global YEARLYTREAT "PT1statusC1lowD_Y2011 PT1statusC1highD_Y2011 PT1statusC1lowD_Y2012 PT1statusC1highD_Y2012  PT1statusC1lowD_Y2014 PT1statusC1highD_Y2014 PT1statusC1lowD_Y2015 PT1statusC1highD_Y2015 PT1statusC1lowD_Y2016 PT1statusC1highD_Y2016 PT1statusC1lowD_Y2017 PT1statusC1highD_Y2017 PT1statusC1lowD_Y2018 PT1statusC1highD_Y2018"
global YEARLYTREAT "CSR_LLdD_Y2011 CSR_restdD_Y2011 CSR_LLdD_Y2012 CSR_restdD_Y2012   CSR_LLdD_Y2014 CSR_restdD_Y2014  CSR_LLdD_Y2015 CSR_restdD_Y2015 CSR_LLdD_Y2016   CSR_restdD_Y2016   CSR_LLdD_Y2017  CSR_restdD_Y2017    CSR_LLdD_Y2018 CSR_restdD_Y2018   "
global DV1 			"CSR"
global DV2 			"soscore"
global DV3 			"enscore"
global HIGH_LOW_DID "CSR_LL CSR_rest"


estimates clear
quietly	xtreg $DV1 $YEARLYTREAT   $CONTROLVAR $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV2 $YEARLYTREAT   $CONTROLVAR $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
quietly xtreg $DV3 $YEARLYTREAT    $CONTROLVAR $FE if ($CG|$TREATMENT) & ($PREPERIOD|$POSTPERIOD) & $SAMPLE, fe vce(cluster $CLUSTER) nonest
eststo
***
esttab,  	star(* 0.10 ** 0.05 *** 0.01)  wide b(3) stats(F N r2_a p_diff)   title (TABLE 4: CSR Activities and firm-level variation in exposure to the CSR Directive) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3"   ) compress ///
				keep  ($YEARLYTREAT  $CONTROLVAR) ///
				order ($YEARLYTREAT  $CONTROLVAR) 
esttab using "$PATH\(3) Output\TABLE4.rtf", replace ///
				star(* 0.10 ** 0.05 *** 0.01)  wide b(3) stats(F N r2_a p_diff)  label title (TABLE 4: CSR Activities and firm-level variation in exposure to the CSR Directive) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" ) compress ///
				varwidth(12)  modelwidth(6) ///
				keep  ($YEARLYTREAT  $CONTROLVAR) ///
				order ($YEARLYTREAT  $CONTROLVAR) 
estimates clear




*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************

*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************

*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************


***

*********************************************************************************************************************
************************************************* THE END ***********************************************************
*********************************************************************************************************************

*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
