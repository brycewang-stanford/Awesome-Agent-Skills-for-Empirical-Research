****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
*
*	Do corporate governance analysts matter? Evidence from the expansion of governance analyst coverage (2018)
*
*	Nico Lehmann (Georg-August University of Goettingen, nico.lehmann@wiwi.uni-goettingen.de)
*
*	The Stata do-file uses all nine datasets (see "NL_data description") as inputs and provides a detailed step-by-step description that enables other researchers to arrive at the same dataset used in my study. 
*	In addition, it shows the Stata code for the main empirical analysis presented in Table 2 of the paper.
*	The analysis is based on three different data source types:
*		(1) commercially available data (i.e., Datastream, Worldscope, IBES, TRAA),
*		(2) proprietary data (ISS coverage data, FTSE/ISS index membership data),
*		(3) publically available data (handcolleted governance data from annual reports). 
*	Please read the data description ("NL_data description") accompanying this do-file beforehand for more details on the different data sources. 
*
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************


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
*  (1.1): Read and clean Datastream, Worldscope, Asset4 raw data  
*-------------------------------------------------------------------------------

set more off
use TR_data, clear // Thomson Reuters dataset contains UK panel data for the years between 2001 and 2009

***Labelling variables

*COMPANY INFO 
label var wc05350 "Date Of Fiscal Year End (Key Item)"
label var wc06001 "Company Name (Key Item)"
label var wc06008 "Isin Number "
label var wc07536 "Accounting Standards Followed"
label var wc07021 "Sic Code 1 "
label var wc05661 "Stock Index Information "

*BALANCE 
label var wc03251 "Long Term Debt (WS) (Key Item) "
label var wc02501 "Property, Plant And Equipment - Net (Key Item) "
label var wc02999 "Total Assets (WS) (Key Item) "
label var dwta "Total Assets (Datastream)"
label var dwse "Book Value of Equity (Datastream)"
label var wc03501 "Common Equity (Key Item) "  
    
*INCOME 
label var wc01001 "Net Sales Or Revenues (Key Item)"
label var wc04001 "Net Income before extraordinary items"

*CFS
label var wc04860 "Net Cash Flow - Operating Activities (Key Item) "

*DIVIDENDS, SHARES & MARKET PRICES  
label var wc05101 "Dividends Per Share (WS) (Key Item) "
label var wc05001 "Market Price - Year End "
label var mv "Market Capitalisation (Datastream)"
label var nosh "Number of shares " 
  
*OWNERSHIP 
label var noshff "Free Float Number Of Shares "

*ASSET4 Info
label var cgvscore "Corporate Governance Score (ESG - ASSET4)"  


***Clean dataset to save estimation power: Delete observations where main variables are missing (total assets [numerical] and isin [string var])
drop if wc02999==.
drop if wc06008==""

***Creating variables***
***Creating fiscal year-end information (split the wc05350 - the month/day/year string var)
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503

***Duplicates
egen i=group(wc06008)
drop if i==.
drop if year==.
drop if year==2010
duplicates report i year
duplicates drop i year, force

***Identifying pooled data structure
tsset i year

***Creating Year-Dummies (one dummy for each year)
tab year, gen(year_)

***Save data
save Master1, replace


*-------------------------------------------------------------------------------
*  (1.2): Read and clean ISS data  
*-------------------------------------------------------------------------------

set more off
insheet using ISScoverage_data.txt, clear

*Labeling key variables
label var countrycgq	"ISS Country CGQ rating" 

***Identifier and country selection
capture drop wc06008
gen wc06008=isinmanuallycompleted
drop if wc06008==""
drop if indexcgq==.
keep if country=="United Kingdom"
sort wc06008 year

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data2, replace


*-------------------------------------------------------------------------------
*  (1.3): Read and clean IBES & stock data 
*-------------------------------------------------------------------------------

set more off
use IBES_data, clear

*Labelling key variables (all variables are averaged across a period of 60 days prior to the respective fiscal year-end)
label var RECNOmedian_m60FY		"Number of issued recommendations per firm " 
label var F1NEmedian_m60FY 		"Number of issued EPS forecasts per firm "
label var MVmedian_m60FY 		"Average fiscal year’s market value of equity "
label var RV_m60FY		 		"Standard deviation of daily share returns "
label var BASmedian_m60FY 		"Bid-ask spreads based on daily closing bid and ask prices "
label var ZTDmean_m60FY 		"Proportion of zero share return days "
label var TOmedian_m60FY	 	"Stock trading volume "

***Identifier
drop if isin==""
sort isin year
gen wc06008=isin

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data3, replace


*-------------------------------------------------------------------------------
*  (1.4): Read and clean TRAA data
*-------------------------------------------------------------------------------

set more off
use TRAA_data, clear

*Labelling key variables
label var IB_InvManNonIndex			"Number of institutional investors per firm scaled by the number of all institutional investors in the market" 
label var OTCountInvMan_nonIndex 	"Number of institutional investors per firm"

***Identifier
drop if isin==""
sort isin year
gen wc06008=isin

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data4, replace


*-------------------------------------------------------------------------------
*  (1.5): Read and clean FTSE/ISS data  
*-------------------------------------------------------------------------------

set more off
import excel ISSFTSE_data.xlsx, clear sheet(Handcollected_Feb2018) first

*Labelling key variables
capture drop FTSEISScoverage
gen FTSEISScoverage=1
label var FTSEISScoverage	"FTSEISS index inclusion dummy" 
label var WtCGI 			"FTSEISS index weights"

***Year 
split Date, p(/)
destring Date1, gen(month)
destring Date2, gen(day)
destring Date3, gen(year)
drop Date1 Date2 Date3

***Sample and identifier 
drop if year==.
drop if isin==""
capture drop wc06008
gen wc06008=isin
sort wc06008 year

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data5, replace


********************************************************************************
********************************************************************************
*  Step 2: Merge datasets  
********************************************************************************
********************************************************************************


set more off
use Master1, clear
sort wc06008 year
 forvalues i = 2(1)5 {
		merge 1:1 wc06008 year using Data`i', force
		drop if _merge==2 
		drop _merge 
}
*
sort i year
***
save Master2, replace
***
use Master2, clear



********************************************************************************
********************************************************************************
*  Step 3: Compute key variables
********************************************************************************
********************************************************************************



*-------------------------------------------------------------------------------
*  (3.1): ISS & ISS/FTSE variables  
*-------------------------------------------------------------------------------

***Treatment 
gen ISScoverage=.
replace ISScoverage=0 if countrycgq==.
replace ISScoverage=1 if ISScoverage==.

***FTSEISS Index Inclusion as Treatment reason  
replace FTSEISScoverage=0 if FTSEISScoverage==.
label var FTSEISScoverage "FTSEISS index inlusion dummy"
replace WtCGI=0 if WtCGI==.
label var WtCGI "FTSEISS index weights"


*-------------------------------------------------------------------------------
*  (3.2): Dependent variables  
*-------------------------------------------------------------------------------

***Financial Analyst Following
sum F1NEmean_CY - RECNOmax_m60FY 

*Key variables  
foreach x of varlist F1NEmean_CY - RECNOmax_m60FY {
	replace `x'=0 if `x'==.
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (AF_sample) 
pca F1NEmean_CY - RECNOmax_m60FY
predict AF_sample, score


***Stock Liquidity
sum BASmean_CY- MVmedian_m60FY

*Key variables 
foreach x of varlist BASmean_CY- MVmedian_m60FY {
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (ML_sample)  
pca BASmean_CY- ZTDmean_m60FY  TVmean_CY- MVmedian_m60FY   
predict ML_sample, score


	
***Institutional Ownership (IO measures multiplied by 1000 for the sake of interpretation ease)
sum OwnTypCount_ALL - IB_OthersNonIndex

*Key variables 
foreach x of varlist IB_ALL - IB_OthersNonIndex  {
	replace `x'=0 if `x'==.
	replace `x'=`x'*1000
 }
*
foreach x of varlist OwnTypCount_ALL - IB_OthersNonIndex  {
	*replace `x'=0 if `x'==.
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (IO_sample)  
pca OwnTypCount_ALL - IB_OthersNonIndex 
predict IO_sample, score
		
		
***Tobin's Q

*Key variables
gen lnQ = ln((dwta+(mv*1000)-dwse) / (dwta))
label var lnQ "Ln of Tobin's Q based on Datastream data"

***
foreach x of varlist lnQ {
	winsor `x', generate (`x'win99) p(0.01)
 }
*Sample Identifier (Q_sample)
pca lnQ lnQwin99  
predict Q_sample, score


*-------------------------------------------------------------------------------
*  (3.3): Control variables  
*-------------------------------------------------------------------------------

*Firm Size in Total Assets
gen lnsize=ln(dwta *1000)
label var lnsize "Ln of total assets (dwta)"

*Market Capitalization
gen lnMaCap1=ln(mv)
label var lnMaCap1 "Ln of market value (mv)"

gen lnMaCap2=ln(nosh*wc05001)
label var lnMaCap2 "Ln of market value (mv)"

*Return on assets
gen ROA=wc04001/wc02999
label var ROA "Net Income before extraordinary items (wc04001) scaled by TA (wc02999)"

* Growth in sales
gen growth=(wc01001-l.wc01001)/l.wc01001
label var growth "Percentage change in sales (wc01001)"

*Leverage
gen lev=wc03251  /wc02999
label var lev"Accounting leverage long-term debt (wc03251) to ta (wc02999)"

*Dividend per Share
gen dps= wc05101
label var dps "dividends per share (wc05101)"

*PPE to TA
gen PPE_TA=wc02501/wc02999
label var PPE_TA "Net PPE (wc02501) to total assets (wc02999)"

*Cash from operations
gen cfo=wc04860/wc02999
label var cfo "Cash flow from operations (direct) deflated by ta"

*Inverse Stock Price
gen inv_stockprice=(-1)*wc05001
label var inv_stockprice "Inverse Stock price based on (wc05001)"

*IFRS Dummy
gen IFRS=.
replace IFRS=1 if wc07536=="IFRS"
replace IFRS=0 if IFRS==.
label var IFRS "IFRS reporting (wc07536)"

*Asset4 Coverage
gen asset4=.
replace asset4=0 if cgvscore == .
replace asset4=1 if asset4 == .
label var asset4 "Asset4 coverage (based on cgvscore)"

*Creating index information (split the wc05661)
gen stockindex=wc05661
split stockindex, p(,)
sort i year
gen FTSE100=.
foreach x of varlist stockindex*  {
		replace FTSE100=1 if `x'=="FTSE 100"
		replace FTSE100=1 if `x'==" FTSE 100"
}
*
replace FTSE100=0 if FTSE100==.
label var FTSE100 "FTSE100 - 100 largest firms at the London Stock Exchange (based on wc05661)"

***
gen FTSE250=.
foreach x of varlist stockindex*  {
		replace FTSE250=1 if `x'=="FT-SE 250"
		replace FTSE250=1 if `x'==" FT-SE 250"
}
*
replace FTSE250=0 if FTSE250==.
label var FTSE250 "FTSE 250 - 250 largest firms at the London Stock Exchange (based on wc05661)"
***
gen FTSEall=.
foreach x of varlist stockindex*  {
		replace FTSEall=1 if `x'=="FTSE ALL"
		replace FTSEall=1 if `x'==" FTSE ALL"
}
*
replace FTSEall=0 if FTSEall==.
label var FTSEall "FTSE ALL - ca. 500 largest firms at the London Stock Exchange (based on wc05661)"
***
drop stockindex*


*SIC industry classification
tostring wc07021, replace
gen nul="0"
gen nul2="00"
gen nul3="000"
egen hulp=concat(nul wc07021) if length(wc07021)==3
replace wc07021=hulp if length(wc07021)==3
drop hulp
egen hulp=concat(nul wc07021) if length(wc07021)==2
replace wc07021=hulp if length(wc07021)==2
drop hulp
egen hulp=concat(nul wc07021) if length(wc07021)==1
replace wc07021=hulp if length(wc07021)==1
drop hulp
drop nul*

*First-digit SIC groups (depends on your sample size)
gen ind1=substr(wc07021,1,1)
label var ind1 "First-digit sic group"
destring ind1, replace
tab ind1, gen(ind1_)


*-------------------------------------------------------------------------------
*  (3.4): Winsorize all control variables  
*-------------------------------------------------------------------------------

set more off
foreach x of varlist lnsize- inv_stockprice noshff {
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (CONTROL_sample)
pca lnsize lnMaCap1 lnMaCap2 ROA growth lev dps PPE_TA cfo inv_stockprice noshff
predict CONTROL_sample, score

*-------------------------------------------------------------------------------
*  (3.5): Define subsamples w.r.t. individual data availability   
*-------------------------------------------------------------------------------

***Overall Sample
gen sample1 = .
replace sample1=1 if (AF_sample!=. & ML_sample!=. & IO_sample!=. & Q_sample!=.)

gen sample2 = .
replace sample2=1 if (AF_sample!=. & ML_sample!=. & IO_sample!=. & Q_sample!=. & CONTROL_sample!=.)

***

save Master3, replace
***
use Master3, clear


********************************************************************************
********************************************************************************
*  Step 4: Impose balanced sample restrictions & define DiD structure
********************************************************************************
********************************************************************************


*-------------------------------------------------------------------------------
*  (4.1): Define balanced DiD samples for each subsample 
*-------------------------------------------------------------------------------


set more off
	forvalues i = 1(1)2 {
	
		use Master3, replace
		drop if  sample`i' ==. 
		
		***PANEL Structure: 5-YEARS Structure (2003-2007) 
		gen company5y_id=i 
		replace company5y_id=0 if year_1==1
		replace company5y_id=0 if year_2==1
		replace company5y_id=0 if year_8==1
		replace company5y_id=0 if year_9==1
		sort company5y_id 
		by  company5y_id : gen eventcount5y1=_N 
		replace eventcount5y1=0 if company5y_id==0
		***
		gen CompleteSample5y=.
		replace CompleteSample5y=1 if eventcount5y1==5
		replace CompleteSample5y=0 if CompleteSample5y==.

		***CONTROL2: firms with constant ISS ratings
		gen ISS_id=ISScoverage
		sort  ISS_id  company5y_id
		by  ISS_id  company5y_id : gen eventcount5y2=_N 
		replace eventcount5y2=0 if company5y_id==0
		replace eventcount5y2=0 if ISScoverage==0
		***
		gen control5y2=.
		replace control5y2=1 if eventcount5y2==5
		replace control5y2=0 if control5y2==.

		***CONTROL1: firms with constant NON-ISS ratings
		gen nonISS_id=.
		replace nonISS_id=0 if ISScoverage ==1
		replace nonISS_id=1 if nonISS_id==.
		sort  nonISS_id  company5y_id
		by  nonISS_id  company5y_id: gen eventcount5y3=_N 
		replace eventcount5y3=0 if company5y_id==0
		replace eventcount5y3=0 if ISScoverage==1
		replace eventcount5y3=0 if control5y2==1
		***
		gen control5y1=.
		replace control5y1=1 if eventcount5y3==5
		replace control5y1=0 if control5y1==.

		***RESIDUAL: firms with and without ISS ratings (nonsystematic)
		gen ResidualGroup5y=.
		replace ResidualGroup5y=1 if CompleteSample5y==1
		replace ResidualGroup5y=0 if control5y2==1
		replace ResidualGroup5y=0 if control5y1==1
		replace ResidualGroup5y=0 if ResidualGroup5y==.

		***TREATMENT: firms with constant NON-ISS ratings prior to 2005 and constant ISS ratings afterwards
		sort isin
		by isin: egen ISScov0304y=sum(ISScoverage) if (year_3==1 | year_4==1)
		by isin: egen ISScov0507y=sum(ISScoverage) if (year_5==1 | year_6==1| year_7==1)
		replace ISScov0304y=0 if ResidualGroup5y==0
		replace ISScov0507y=0 if ResidualGroup5y==0
		replace ISScov0304y=0 if ISScov0304y==.
		replace ISScov0507y=0 if ISScov0507y==.
		sort isin
		by isin: egen MaxISScov0304y= max(ISScov0304y)
		by isin: egen MaxISScov0507y= max(ISScov0507y)
		***
		gen TreatmentGroup5y=.
		replace TreatmentGroup5y=1 if  MaxISScov0304y==0 & MaxISScov0507y==3  & ResidualGroup5y==1
		replace TreatmentGroup5y=0 if  TreatmentGroup5y==.

		***SUMMARY (control) REPORTS on each individual panel subsample
		tabstat ISScoverage if CompleteSample5y , stat (n sum mean) by(year)
		tabstat CompleteSample5y , stat (n sum mean) by(year)
		tabstat ISScoverage if control5y2 , stat (n sum mean) by(year)
		tabstat control5y2 , stat (n sum mean) by(year)
		tabstat ISScoverage if control5y1 , stat (n sum mean) by(year)
		tabstat control5y1 , stat (n sum mean) by(year)
		tabstat ISScoverage if ResidualGroup5y , stat (n sum mean) by(year)
		tabstat ResidualGroup5y , stat (n sum mean) by(year)
		tabstat ISScoverage if TreatmentGroup5y , stat (n sum mean) by(year)
		tabstat TreatmentGroup5y , stat (n sum mean) by(year)

		***TIME structure
		gen Post= year_5 + year_6 + year_7 
		gen Ante= year_3 + year_4
		gen Post_Treatment=TreatmentGroup5y*Post
		gen Ante_Treatment=TreatmentGroup5y*Ante
		gen Post_control5y1=control5y1*Post
		gen Ante_control5y1=control5y1*Ante
		gen Post_control5y2=control5y2*Post
		gen Ante_control5y2=control5y2*Ante


		***Subsample specific labelling
		rename control5y2 control5y2_s`i'
		rename control5y1 control5y1_s`i'
		rename TreatmentGroup5y TreatmentGroup5y_s`i'
		rename Post_Treatment Post_Treatment5y_s`i'
		rename Post Post5y_s`i'
		rename Ante Ante5y_s`i'

		***Clean and save
		keep wc06008 year control5y2_s`i' control5y1_s`i' TreatmentGroup5y_s`i' Post_Treatment5y_s`i' Post5y_s`i' Ante5y_s`i'
		save EM2data4_s`i', replace
}
*

*-------------------------------------------------------------------------------
*  (4.2): Merge Subsamples and Sample Selection variables with Masterfile 
*-------------------------------------------------------------------------------

set more off
use EM2data4_s1, replace	
sort wc06008 year
	forvalues i = 2(1)2 {
		merge 1:1 wc06008  year using EM2data4_s`i'
		drop if _merge ==2
		drop _merge
		save EM2data4_sALL, replace
}
*
use Master3, replace
sort wc06008 year
set more off
merge 1:1 wc06008 year using EM2data4_sALL
drop if _merge ==2
drop _merge
	
	
*-------------------------------------------------------------------------------
*  (4.3): Adjust Selection Variables for Masterfile
*-------------------------------------------------------------------------------
	
set more off
	forvalues i = 1(1)2 {
		replace  control5y2_s`i'=0 if control5y2_s`i'==.
		replace  control5y1_s`i'=0 if control5y1_s`i'==.
		replace  TreatmentGroup5y_s`i'=0 if TreatmentGroup5y_s`i'==.
		replace  Post_Treatment5y_s`i'=0 if Post_Treatment5y_s`i'==.
		replace  Post5y_s`i'=0 if Post5y_s`i'==.
		replace  Ante5y_s`i'=0 if Ante5y_s`i'==.
		
}
*
capture drop sample1-sample2


*-------------------------------------------------------------------------------
*  (4.4): PCA for COMPLETE sample with Controls (sample2)
*-------------------------------------------------------------------------------

*VARIABLE MANAGEMENT
set more off
macro dir
macro drop CG1 CG2 PERIOD TREATMENT
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global PERIOD		"year_3|year_4|year_5|year_6|year_7"
global TREATMENT  	"TreatmentGroup5y_s2"

***MARKET LIQUIDITY measures based on PCA
pca lnBASmedian_m60FYwin99  ZTDmean_m60FY lnTOmedian_m60FYwin99   if   ($CG1 | $CG2 | $TREATMENT) & ($PERIOD)
predict help1  if   ($CG1 | $CG2 | $TREATMENT) & ($PERIOD), score
gen MLpc_ALLm60FY_raw = help1  
gen MLpc_ALLm60FY = MLpc_ALLm60FY_raw*(-1)  
drop help1

*** DROP Melrose Resource (MRS, Melrose Resources, GB0009354589) as it is included in FTSEISS Index but NOT in CGQ dataset - I thus correct dataset for data inconsistency in ISS files (Revision Feb 2018, location of drop command does not affect my findings)  
drop if isin=="GB0009354589"

***
save Master4, replace


*-------------------------------------------------------------------------------
*  (4.5): Handcollected governance data based on COMPLETE sample 
*-------------------------------------------------------------------------------

set more off
import excel using GOV_data.xlsx, first  sheet(data_new1) clear

*Define key variables
foreach x of varlist Board1all Board2all  Comp1all Audit1all  {
	gen `x'_d=`x'=="YES"
	replace `x'_d=. if `x'==""
}
gen GOVscore= (Board1all_d+Board2all_d+Comp1all_d+Audit1all_d)/4

*Labelling key variables
label var GOVscore 		"Composite governance index"
label var Board1all_d 	"CEO/chairman duality" 
label var Board2all_d 	"Board Independence " 
label var Comp1all_d 	"Compensation committee independence " 
label var Audit1all_d 	"Audit committee independence " 


*Sample & duplicates
egen count =count(GOVscore), by(isin)
drop if count!=3
gen HandcollectedGOV=1
capture drop wc06008
gen wc06008=isin
duplicates report wc06008 year
sort wc06008 year
keep HandcollectedGOV wc06008 year CGQdata  annualreport Board1all Board2all Comp1all Audit1all BoardSize Board1all_d Board2all_d Comp1all_d Audit1all_d GOVscore  proxyreport

*Save handcolleted data
save Handcollected_ISSGOV6, replace

*Merge handcollected data back to main file 
set more off
use Master4, clear
merge 1:1 wc06008 year using Handcollected_ISSGOV6, force
drop if _merge==2  


*Adjust handcollected dummy variables 0 for Masterfile (do not adjust numerical variables, such as BoardSize and GOVscore)
foreach x of varlist HandcollectedGOV Board1all_d Board2all_d Comp1all_d Audit1all_d  {
	replace `x'=0 if `x'==.
}
*

*Adjust treatment and control dummies (_sample2) in Masterfile for coverage of handcollected data
foreach x of varlist control5y1_s2 control5y2_s2 TreatmentGroup5y_s2 Post5y_s2 Post_Treatment5y_s2  {
	replace `x'=0 if HandcollectedGOV==0
}
*
***

save Master5, replace
***
use Master5, clear

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
*		II. RESULTS (as of November 2018)
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 1: Sample Description
*
********************************************************************************
********************************************************************************
********************************************************************************

set more off
use Master3, clear

*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"

*-------------------------------------------------------------------------------
* Panel A (Table 1). Sample Selection
*-------------------------------------------------------------------------------

* (0) Start: Woldscope Firm universe (ISIN available)
tab year if (year_4|year_5|year_6)

* (1) Worldscope Data unavailable
drop if Q_sample ==.
drop if CONTROL_sample ==.
tab year if (year_4|year_5|year_6)

* (2) Datastream Data unavailable
drop if ML_sample ==.
tab year if (year_4|year_5|year_6)

* (3) IBES Data unavailable
drop if  AF_sample ==.
tab year if (year_4|year_5|year_6)

* (4) TRAA Data unavailable
drop if  IO_sample ==.
tab year if (year_4|year_5|year_6)

* (5) Balanced Sample Structure
use Master4, clear
*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"
***
tab year if (year_4|year_5|year_6)& ($TREATMENT_all | $CG1_all |$CG2_all)
tabstat ISScoverage if ($TREATMENT_all | $CG1_all|$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) 

* (6) Balanced Sample Structure with handcollected GOV data available: GOV
use Master5, clear
*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"
***
tab year if (year_4|year_5|year_6) & ($TREATMENT_all | $CG1_all |$CG2_all)
tabstat ISScoverage if ($TREATMENT_all | $CG1_all|$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) 


*-------------------------------------------------------------------------------
* Panel B (Table 1). Sample Distribution
*-------------------------------------------------------------------------------

tabstat ISScoverage if ($TREATMENT_all | $CG1_all |$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) by(year)
tabstat ISScoverage if $TREATMENT_all  & (year_4|year_5|year_6), stat (n sum mean) by(year)
tabstat ISScoverage if $CG1_all & (year_4|year_5|year_6), stat (n sum mean) by(year)
tabstat ISScoverage if $CG2_all & (year_4|year_5|year_6) , stat (n sum mean) by(year)

********************************************************************************
********************************************************************************
********************************************************************************
*
* TABLE 2: Baseline Results: Average Treatment Effect
*
********************************************************************************
********************************************************************************
********************************************************************************

set more off
use Master5, clear

*-------------------------------------------------------------------------------
* Panel A (Table 2): Mean comparisons 
*-------------------------------------------------------------------------------

qui estpost tabstat ISScoverage, stat(n) 
esttab using Platzhalter.rtf, replace cells("count(fmt(0))")  noobs nonumbers  title  (START)
	
foreach x of varlist GOVscore MLpc_ALLm60FY  lnRECNOmedian_m60FY IB_InvManNonIndex  {
	
set more off
use Master5, clear

*VARIABLE MANAGEMENT
set more off
macro dir  
macro drop CG1 CG2 TREATMENT POST DV PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global DV 			"`x'" 
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

						
*** PANEL A: Main Descriptive Analysis and Univariate DiD

qui estpost tabstat $DV if ($TREATMENT ) & ($PREPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))    count(fmt(0))")  noobs nonumbers  title  ((1) TREATMENT & PREPERIOD: `x' ) compress order ($DV) keep ($DV )
qui estpost tabstat $DV if ($TREATMENT ) & ($POSTPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))    count(fmt(0))")  noobs nonumbers  title  ((2) TREATMENT & POSTPERIOD: `x') compress order ($DV)  keep ($DV)
qui estpost ttest $DV  if  ($TREATMENT) & ($PREPERIOD|$POSTPERIOD), by($PREPERIOD) 
	esttab using Platzhalter.rtf, append cells("b(fmt(2))  t(fmt(2))  p(fmt(2))  count(fmt(0))")  noobs nonumbers coeflabels(`x') title  ((1) TREATMENT & PREPERIOD vs.POSTPERIOD: `x') compress order ($DV) keep ($DV)
***
qui estpost tabstat $DV if ($CG1|$CG2 ) & ($PREPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))     count(fmt(0))")  noobs nonumbers  title  ((3) CG1CG2 & PREPERIOD: `x') compress order ($DV) keep ($DV)
qui estpost tabstat $DV if ($CG1|$CG2 ) & ($POSTPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))   count(fmt(0))")  noobs nonumbers  title  ((4) CG1CG2 & POSTPERIOD: `x') compress order ($DV) keep ($DV)
qui estpost ttest $DV  if  ($CG1|$CG2) & ($PREPERIOD|$POSTPERIOD), by($PREPERIOD) 
	esttab using Platzhalter.rtf, append cells("b(fmt(2))  t(fmt(2))  p(fmt(2))  count(fmt(0))")  noobs nonumbers coeflabels(`x') title  ((1) TREATMENT & PREPERIOD vs.POSTPERIOD: `x') compress order ($DV)  keep ($DV)
***
set more off
sort i year
gen var1 = $TREATMENT
gen var2 = ($CG1|$CG2)
***
	forvalues i = 1(1)2 {
		
		gen help1 = $DV if (var`i') & ($PREPERIOD)
		egen meanhelp1=mean(help1) if (var`i') & ($PREPERIOD), by(i)
		egen maxhelp1=max(meanhelp1)  if (var`i'), by(i)

		gen help2 = $DV if (var`i') & ($POSTPERIOD)
		egen meanhelp2=mean(help2) if (var`i') & ($POSTPERIOD), by(i)
		egen maxhelp2=max(meanhelp2)  if (var`i'), by(i)

		gen DV_var`i'diff=maxhelp2-maxhelp1
		drop help1-maxhelp2

}
***
drop var1 - var2
ttest DV_var1diff==0 if  ($PREPERIOD)
ttest DV_var2diff==0 if  ($PREPERIOD)
ttest DV_var1diff == DV_var2diff if  ($PREPERIOD), unpaired
}
*

********************************************************************************
********************************************************************************

set more off
use Master5, clear

*VARIABLE MANAGEMENT:
set more off
macro dir 
macro drop CG1  CG2 TREATMENT POST POST_TREAT DV1 CONTROLVAR1 DV2 CONTROLVAR2 PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global POST_TREAT   "Post_Treatment5y_s2"
global DV1 			"GOVscore" 
global CONTROLVAR1 	"lnsizewin99 levwin99 ROAwin99  growthwin99  noshffwin99 BoardSize asset4"
global DV2 			"MLpc_ALLm60FY" 
global CONTROLVAR2 	"lnMVmedian_m60FYwin99 lnRV_m60FYwin99 levwin99 ROAwin99 PPE_TAwin99 inv_stockpricewin99  IFRS noshffwin99 asset4"
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

*-------------------------------------------------------------------------------
* Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity
*-------------------------------------------------------------------------------
						
estimates clear
quietly reg $DV1 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST  $CONTROLVAR1 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly reg $DV2 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST  $CONTROLVAR2 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
esttab,  	star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)   title (Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
esttab using Platzhalter.rtf, replace ///
				star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)  label title (Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress varwidth(12)  modelwidth(6) ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
estimates clear


********************************************************************************
********************************************************************************

set more off
use Master5, clear

*VARIABLE MANAGEMENT:
set more off
macro dir 
macro drop CG1  CG2 TREATMENT POST POST_TREAT DV1 CONTROLVAR1 DV2 CONTROLVAR2 PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global POST_TREAT   "Post_Treatment5y_s2"
global DV1 			"lnRECNOmedian_m60FY" 
global CONTROLVAR1 	"lnsizewin99 levwin99 ROAwin99 PPE_TAwin99 noshffwin99 IFRS inv_stockpricewin99 asset4"
global DV2 			"IB_InvManNonIndex" 
global CONTROLVAR2 	"lnsizewin99 levwin99 ROAwin99  cfowin99 dpswin99 PPE_TAwin99 IFRS inv_stockpricewin99 asset4 "
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

*-------------------------------------------------------------------------------
* Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth
*-------------------------------------------------------------------------------
						
estimates clear
quietly reg $DV1 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST  $CONTROLVAR1 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly reg $DV2 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST  $CONTROLVAR2 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
esttab,  	star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)   title (Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
esttab using Platzhalter.rtf, replace ///
				star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)  label title (Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress varwidth(12)  modelwidth(6) ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
estimates clear



*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*		THE END
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
*
*	Do corporate governance analysts matter? Evidence from the expansion of governance analyst coverage (2018)
*
*	Nico Lehmann (Georg-August University of Goettingen, nico.lehmann@wiwi.uni-goettingen.de)
*
*	The Stata do-file uses all nine datasets (see "NL_data description") as inputs and provides a detailed step-by-step description that enables other researchers to arrive at the same dataset used in my study. 
*	In addition, it shows the Stata code for the main empirical analysis presented in Table 2 of the paper.
*	The analysis is based on three different data source types:
*		(1) commercially available data (i.e., Datastream, Worldscope, IBES, TRAA),
*		(2) proprietary data (ISS coverage data, FTSE/ISS index membership data),
*		(3) publically available data (handcolleted governance data from annual reports). 
*	Please read the data description ("NL_data description") accompanying this do-file beforehand for more details on the different data sources. 
*
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************


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
*  (1.1): Read and clean Datastream, Worldscope, Asset4 raw data  
*-------------------------------------------------------------------------------

set more off
use TR_data, clear // Thomson Reuters dataset contains UK panel data for the years between 2001 and 2009

***Labelling variables

*COMPANY INFO 
label var wc05350 "Date Of Fiscal Year End (Key Item)"
label var wc06001 "Company Name (Key Item)"
label var wc06008 "Isin Number "
label var wc07536 "Accounting Standards Followed"
label var wc07021 "Sic Code 1 "
label var wc05661 "Stock Index Information "

*BALANCE 
label var wc03251 "Long Term Debt (WS) (Key Item) "
label var wc02501 "Property, Plant And Equipment - Net (Key Item) "
label var wc02999 "Total Assets (WS) (Key Item) "
label var dwta "Total Assets (Datastream)"
label var dwse "Book Value of Equity (Datastream)"
label var wc03501 "Common Equity (Key Item) "  
    
*INCOME 
label var wc01001 "Net Sales Or Revenues (Key Item)"
label var wc04001 "Net Income before extraordinary items"

*CFS
label var wc04860 "Net Cash Flow - Operating Activities (Key Item) "

*DIVIDENDS, SHARES & MARKET PRICES  
label var wc05101 "Dividends Per Share (WS) (Key Item) "
label var wc05001 "Market Price - Year End "
label var mv "Market Capitalisation (Datastream)"
label var nosh "Number of shares " 
  
*OWNERSHIP 
label var noshff "Free Float Number Of Shares "

*ASSET4 Info
label var cgvscore "Corporate Governance Score (ESG - ASSET4)"  


***Clean dataset to save estimation power: Delete observations where main variables are missing (total assets [numerical] and isin [string var])
drop if wc02999==.
drop if wc06008==""

***Creating variables***
***Creating fiscal year-end information (split the wc05350 - the month/day/year string var)
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503

***Duplicates
egen i=group(wc06008)
drop if i==.
drop if year==.
drop if year==2010
duplicates report i year
duplicates drop i year, force

***Identifying pooled data structure
tsset i year

***Creating Year-Dummies (one dummy for each year)
tab year, gen(year_)

***Save data
save Master1, replace


*-------------------------------------------------------------------------------
*  (1.2): Read and clean ISS data  
*-------------------------------------------------------------------------------

set more off
insheet using ISScoverage_data.txt, clear

*Labeling key variables
label var countrycgq	"ISS Country CGQ rating" 

***Identifier and country selection
capture drop wc06008
gen wc06008=isinmanuallycompleted
drop if wc06008==""
drop if indexcgq==.
keep if country=="United Kingdom"
sort wc06008 year

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data2, replace


*-------------------------------------------------------------------------------
*  (1.3): Read and clean IBES & stock data 
*-------------------------------------------------------------------------------

set more off
use IBES_data, clear

*Labelling key variables (all variables are averaged across a period of 60 days prior to the respective fiscal year-end)
label var RECNOmedian_m60FY		"Number of issued recommendations per firm " 
label var F1NEmedian_m60FY 		"Number of issued EPS forecasts per firm "
label var MVmedian_m60FY 		"Average fiscal year’s market value of equity "
label var RV_m60FY		 		"Standard deviation of daily share returns "
label var BASmedian_m60FY 		"Bid-ask spreads based on daily closing bid and ask prices "
label var ZTDmean_m60FY 		"Proportion of zero share return days "
label var TOmedian_m60FY	 	"Stock trading volume "

***Identifier
drop if isin==""
sort isin year
gen wc06008=isin

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data3, replace


*-------------------------------------------------------------------------------
*  (1.4): Read and clean TRAA data
*-------------------------------------------------------------------------------

set more off
use TRAA_data, clear

*Labelling key variables
label var IB_InvManNonIndex			"Number of institutional investors per firm scaled by the number of all institutional investors in the market" 
label var OTCountInvMan_nonIndex 	"Number of institutional investors per firm"

***Identifier
drop if isin==""
sort isin year
gen wc06008=isin

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data4, replace


*-------------------------------------------------------------------------------
*  (1.5): Read and clean FTSE/ISS data  
*-------------------------------------------------------------------------------

set more off
import excel ISSFTSE_data.xlsx, clear sheet(Handcollected_Feb2018) first

*Labelling key variables
capture drop FTSEISScoverage
gen FTSEISScoverage=1
label var FTSEISScoverage	"FTSEISS index inclusion dummy" 
label var WtCGI 			"FTSEISS index weights"

***Year 
split Date, p(/)
destring Date1, gen(month)
destring Date2, gen(day)
destring Date3, gen(year)
drop Date1 Date2 Date3

***Sample and identifier 
drop if year==.
drop if isin==""
capture drop wc06008
gen wc06008=isin
sort wc06008 year

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data5, replace


********************************************************************************
********************************************************************************
*  Step 2: Merge datasets  
********************************************************************************
********************************************************************************


set more off
use Master1, clear
sort wc06008 year
 forvalues i = 2(1)5 {
		merge 1:1 wc06008 year using Data`i', force
		drop if _merge==2 
		drop _merge 
}
*
sort i year
***
save Master2, replace
***
use Master2, clear



********************************************************************************
********************************************************************************
*  Step 3: Compute key variables
********************************************************************************
********************************************************************************



*-------------------------------------------------------------------------------
*  (3.1): ISS & ISS/FTSE variables  
*-------------------------------------------------------------------------------

***Treatment 
gen ISScoverage=.
replace ISScoverage=0 if countrycgq==.
replace ISScoverage=1 if ISScoverage==.

***FTSEISS Index Inclusion as Treatment reason  
replace FTSEISScoverage=0 if FTSEISScoverage==.
label var FTSEISScoverage "FTSEISS index inlusion dummy"
replace WtCGI=0 if WtCGI==.
label var WtCGI "FTSEISS index weights"


*-------------------------------------------------------------------------------
*  (3.2): Dependent variables  
*-------------------------------------------------------------------------------

***Financial Analyst Following
sum F1NEmean_CY - RECNOmax_m60FY 

*Key variables  
foreach x of varlist F1NEmean_CY - RECNOmax_m60FY {
	replace `x'=0 if `x'==.
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (AF_sample) 
pca F1NEmean_CY - RECNOmax_m60FY
predict AF_sample, score


***Stock Liquidity
sum BASmean_CY- MVmedian_m60FY

*Key variables 
foreach x of varlist BASmean_CY- MVmedian_m60FY {
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (ML_sample)  
pca BASmean_CY- ZTDmean_m60FY  TVmean_CY- MVmedian_m60FY   
predict ML_sample, score


	
***Institutional Ownership (IO measures multiplied by 1000 for the sake of interpretation ease)
sum OwnTypCount_ALL - IB_OthersNonIndex

*Key variables 
foreach x of varlist IB_ALL - IB_OthersNonIndex  {
	replace `x'=0 if `x'==.
	replace `x'=`x'*1000
 }
*
foreach x of varlist OwnTypCount_ALL - IB_OthersNonIndex  {
	*replace `x'=0 if `x'==.
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (IO_sample)  
pca OwnTypCount_ALL - IB_OthersNonIndex 
predict IO_sample, score
		
		
***Tobin's Q

*Key variables
gen lnQ = ln((dwta+(mv*1000)-dwse) / (dwta))
label var lnQ "Ln of Tobin's Q based on Datastream data"

***
foreach x of varlist lnQ {
	winsor `x', generate (`x'win99) p(0.01)
 }
*Sample Identifier (Q_sample)
pca lnQ lnQwin99  
predict Q_sample, score


*-------------------------------------------------------------------------------
*  (3.3): Control variables  
*-------------------------------------------------------------------------------

*Firm Size in Total Assets
gen lnsize=ln(dwta *1000)
label var lnsize "Ln of total assets (dwta)"

*Market Capitalization
gen lnMaCap1=ln(mv)
label var lnMaCap1 "Ln of market value (mv)"

gen lnMaCap2=ln(nosh*wc05001)
label var lnMaCap2 "Ln of market value (mv)"

*Return on assets
gen ROA=wc04001/wc02999
label var ROA "Net Income before extraordinary items (wc04001) scaled by TA (wc02999)"

* Growth in sales
gen growth=(wc01001-l.wc01001)/l.wc01001
label var growth "Percentage change in sales (wc01001)"

*Leverage
gen lev=wc03251  /wc02999
label var lev"Accounting leverage long-term debt (wc03251) to ta (wc02999)"

*Dividend per Share
gen dps= wc05101
label var dps "dividends per share (wc05101)"

*PPE to TA
gen PPE_TA=wc02501/wc02999
label var PPE_TA "Net PPE (wc02501) to total assets (wc02999)"

*Cash from operations
gen cfo=wc04860/wc02999
label var cfo "Cash flow from operations (direct) deflated by ta"

*Inverse Stock Price
gen inv_stockprice=(-1)*wc05001
label var inv_stockprice "Inverse Stock price based on (wc05001)"

*IFRS Dummy
gen IFRS=.
replace IFRS=1 if wc07536=="IFRS"
replace IFRS=0 if IFRS==.
label var IFRS "IFRS reporting (wc07536)"

*Asset4 Coverage
gen asset4=.
replace asset4=0 if cgvscore == .
replace asset4=1 if asset4 == .
label var asset4 "Asset4 coverage (based on cgvscore)"

*Creating index information (split the wc05661)
gen stockindex=wc05661
split stockindex, p(,)
sort i year
gen FTSE100=.
foreach x of varlist stockindex*  {
		replace FTSE100=1 if `x'=="FTSE 100"
		replace FTSE100=1 if `x'==" FTSE 100"
}
*
replace FTSE100=0 if FTSE100==.
label var FTSE100 "FTSE100 - 100 largest firms at the London Stock Exchange (based on wc05661)"

***
gen FTSE250=.
foreach x of varlist stockindex*  {
		replace FTSE250=1 if `x'=="FT-SE 250"
		replace FTSE250=1 if `x'==" FT-SE 250"
}
*
replace FTSE250=0 if FTSE250==.
label var FTSE250 "FTSE 250 - 250 largest firms at the London Stock Exchange (based on wc05661)"
***
gen FTSEall=.
foreach x of varlist stockindex*  {
		replace FTSEall=1 if `x'=="FTSE ALL"
		replace FTSEall=1 if `x'==" FTSE ALL"
}
*
replace FTSEall=0 if FTSEall==.
label var FTSEall "FTSE ALL - ca. 500 largest firms at the London Stock Exchange (based on wc05661)"
***
drop stockindex*


*SIC industry classification
tostring wc07021, replace
gen nul="0"
gen nul2="00"
gen nul3="000"
egen hulp=concat(nul wc07021) if length(wc07021)==3
replace wc07021=hulp if length(wc07021)==3
drop hulp
egen hulp=concat(nul wc07021) if length(wc07021)==2
replace wc07021=hulp if length(wc07021)==2
drop hulp
egen hulp=concat(nul wc07021) if length(wc07021)==1
replace wc07021=hulp if length(wc07021)==1
drop hulp
drop nul*

*First-digit SIC groups (depends on your sample size)
gen ind1=substr(wc07021,1,1)
label var ind1 "First-digit sic group"
destring ind1, replace
tab ind1, gen(ind1_)


*-------------------------------------------------------------------------------
*  (3.4): Winsorize all control variables  
*-------------------------------------------------------------------------------

set more off
foreach x of varlist lnsize- inv_stockprice noshff {
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (CONTROL_sample)
pca lnsize lnMaCap1 lnMaCap2 ROA growth lev dps PPE_TA cfo inv_stockprice noshff
predict CONTROL_sample, score

*-------------------------------------------------------------------------------
*  (3.5): Define subsamples w.r.t. individual data availability   
*-------------------------------------------------------------------------------

***Overall Sample
gen sample1 = .
replace sample1=1 if (AF_sample!=. & ML_sample!=. & IO_sample!=. & Q_sample!=.)

gen sample2 = .
replace sample2=1 if (AF_sample!=. & ML_sample!=. & IO_sample!=. & Q_sample!=. & CONTROL_sample!=.)

***

save Master3, replace
***
use Master3, clear


********************************************************************************
********************************************************************************
*  Step 4: Impose balanced sample restrictions & define DiD structure
********************************************************************************
********************************************************************************


*-------------------------------------------------------------------------------
*  (4.1): Define balanced DiD samples for each subsample 
*-------------------------------------------------------------------------------


set more off
	forvalues i = 1(1)2 {
	
		use Master3, replace
		drop if  sample`i' ==. 
		
		***PANEL Structure: 5-YEARS Structure (2003-2007) 
		gen company5y_id=i 
		replace company5y_id=0 if year_1==1
		replace company5y_id=0 if year_2==1
		replace company5y_id=0 if year_8==1
		replace company5y_id=0 if year_9==1
		sort company5y_id 
		by  company5y_id : gen eventcount5y1=_N 
		replace eventcount5y1=0 if company5y_id==0
		***
		gen CompleteSample5y=.
		replace CompleteSample5y=1 if eventcount5y1==5
		replace CompleteSample5y=0 if CompleteSample5y==.

		***CONTROL2: firms with constant ISS ratings
		gen ISS_id=ISScoverage
		sort  ISS_id  company5y_id
		by  ISS_id  company5y_id : gen eventcount5y2=_N 
		replace eventcount5y2=0 if company5y_id==0
		replace eventcount5y2=0 if ISScoverage==0
		***
		gen control5y2=.
		replace control5y2=1 if eventcount5y2==5
		replace control5y2=0 if control5y2==.

		***CONTROL1: firms with constant NON-ISS ratings
		gen nonISS_id=.
		replace nonISS_id=0 if ISScoverage ==1
		replace nonISS_id=1 if nonISS_id==.
		sort  nonISS_id  company5y_id
		by  nonISS_id  company5y_id: gen eventcount5y3=_N 
		replace eventcount5y3=0 if company5y_id==0
		replace eventcount5y3=0 if ISScoverage==1
		replace eventcount5y3=0 if control5y2==1
		***
		gen control5y1=.
		replace control5y1=1 if eventcount5y3==5
		replace control5y1=0 if control5y1==.

		***RESIDUAL: firms with and without ISS ratings (nonsystematic)
		gen ResidualGroup5y=.
		replace ResidualGroup5y=1 if CompleteSample5y==1
		replace ResidualGroup5y=0 if control5y2==1
		replace ResidualGroup5y=0 if control5y1==1
		replace ResidualGroup5y=0 if ResidualGroup5y==.

		***TREATMENT: firms with constant NON-ISS ratings prior to 2005 and constant ISS ratings afterwards
		sort isin
		by isin: egen ISScov0304y=sum(ISScoverage) if (year_3==1 | year_4==1)
		by isin: egen ISScov0507y=sum(ISScoverage) if (year_5==1 | year_6==1| year_7==1)
		replace ISScov0304y=0 if ResidualGroup5y==0
		replace ISScov0507y=0 if ResidualGroup5y==0
		replace ISScov0304y=0 if ISScov0304y==.
		replace ISScov0507y=0 if ISScov0507y==.
		sort isin
		by isin: egen MaxISScov0304y= max(ISScov0304y)
		by isin: egen MaxISScov0507y= max(ISScov0507y)
		***
		gen TreatmentGroup5y=.
		replace TreatmentGroup5y=1 if  MaxISScov0304y==0 & MaxISScov0507y==3  & ResidualGroup5y==1
		replace TreatmentGroup5y=0 if  TreatmentGroup5y==.

		***SUMMARY (control) REPORTS on each individual panel subsample
		tabstat ISScoverage if CompleteSample5y , stat (n sum mean) by(year)
		tabstat CompleteSample5y , stat (n sum mean) by(year)
		tabstat ISScoverage if control5y2 , stat (n sum mean) by(year)
		tabstat control5y2 , stat (n sum mean) by(year)
		tabstat ISScoverage if control5y1 , stat (n sum mean) by(year)
		tabstat control5y1 , stat (n sum mean) by(year)
		tabstat ISScoverage if ResidualGroup5y , stat (n sum mean) by(year)
		tabstat ResidualGroup5y , stat (n sum mean) by(year)
		tabstat ISScoverage if TreatmentGroup5y , stat (n sum mean) by(year)
		tabstat TreatmentGroup5y , stat (n sum mean) by(year)

		***TIME structure
		gen Post= year_5 + year_6 + year_7 
		gen Ante= year_3 + year_4
		gen Post_Treatment=TreatmentGroup5y*Post
		gen Ante_Treatment=TreatmentGroup5y*Ante
		gen Post_control5y1=control5y1*Post
		gen Ante_control5y1=control5y1*Ante
		gen Post_control5y2=control5y2*Post
		gen Ante_control5y2=control5y2*Ante


		***Subsample specific labelling
		rename control5y2 control5y2_s`i'
		rename control5y1 control5y1_s`i'
		rename TreatmentGroup5y TreatmentGroup5y_s`i'
		rename Post_Treatment Post_Treatment5y_s`i'
		rename Post Post5y_s`i'
		rename Ante Ante5y_s`i'

		***Clean and save
		keep wc06008 year control5y2_s`i' control5y1_s`i' TreatmentGroup5y_s`i' Post_Treatment5y_s`i' Post5y_s`i' Ante5y_s`i'
		save EM2data4_s`i', replace
}
*

*-------------------------------------------------------------------------------
*  (4.2): Merge Subsamples and Sample Selection variables with Masterfile 
*-------------------------------------------------------------------------------

set more off
use EM2data4_s1, replace	
sort wc06008 year
	forvalues i = 2(1)2 {
		merge 1:1 wc06008  year using EM2data4_s`i'
		drop if _merge ==2
		drop _merge
		save EM2data4_sALL, replace
}
*
use Master3, replace
sort wc06008 year
set more off
merge 1:1 wc06008 year using EM2data4_sALL
drop if _merge ==2
drop _merge
	
	
*-------------------------------------------------------------------------------
*  (4.3): Adjust Selection Variables for Masterfile
*-------------------------------------------------------------------------------
	
set more off
	forvalues i = 1(1)2 {
		replace  control5y2_s`i'=0 if control5y2_s`i'==.
		replace  control5y1_s`i'=0 if control5y1_s`i'==.
		replace  TreatmentGroup5y_s`i'=0 if TreatmentGroup5y_s`i'==.
		replace  Post_Treatment5y_s`i'=0 if Post_Treatment5y_s`i'==.
		replace  Post5y_s`i'=0 if Post5y_s`i'==.
		replace  Ante5y_s`i'=0 if Ante5y_s`i'==.
		
}
*
capture drop sample1-sample2


*-------------------------------------------------------------------------------
*  (4.4): PCA for COMPLETE sample with Controls (sample2)
*-------------------------------------------------------------------------------

*VARIABLE MANAGEMENT
set more off
macro dir
macro drop CG1 CG2 PERIOD TREATMENT
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global PERIOD		"year_3|year_4|year_5|year_6|year_7"
global TREATMENT  	"TreatmentGroup5y_s2"

***MARKET LIQUIDITY measures based on PCA
pca lnBASmedian_m60FYwin99  ZTDmean_m60FY lnTOmedian_m60FYwin99   if   ($CG1 | $CG2 | $TREATMENT) & ($PERIOD)
predict help1  if   ($CG1 | $CG2 | $TREATMENT) & ($PERIOD), score
gen MLpc_ALLm60FY_raw = help1  
gen MLpc_ALLm60FY = MLpc_ALLm60FY_raw*(-1)  
drop help1

*** DROP Melrose Resource (MRS, Melrose Resources, GB0009354589) as it is included in FTSEISS Index but NOT in CGQ dataset - I thus correct dataset for data inconsistency in ISS files (Revision Feb 2018, location of drop command does not affect my findings)  
drop if isin=="GB0009354589"

***
save Master4, replace


*-------------------------------------------------------------------------------
*  (4.5): Handcollected governance data based on COMPLETE sample 
*-------------------------------------------------------------------------------

set more off
import excel using GOV_data.xlsx, first  sheet(data_new1) clear

*Define key variables
foreach x of varlist Board1all Board2all  Comp1all Audit1all  {
	gen `x'_d=`x'=="YES"
	replace `x'_d=. if `x'==""
}
gen GOVscore= (Board1all_d+Board2all_d+Comp1all_d+Audit1all_d)/4

*Labelling key variables
label var GOVscore 		"Composite governance index"
label var Board1all_d 	"CEO/chairman duality" 
label var Board2all_d 	"Board Independence " 
label var Comp1all_d 	"Compensation committee independence " 
label var Audit1all_d 	"Audit committee independence " 


*Sample & duplicates
egen count =count(GOVscore), by(isin)
drop if count!=3
gen HandcollectedGOV=1
capture drop wc06008
gen wc06008=isin
duplicates report wc06008 year
sort wc06008 year
keep HandcollectedGOV wc06008 year CGQdata  annualreport Board1all Board2all Comp1all Audit1all BoardSize Board1all_d Board2all_d Comp1all_d Audit1all_d GOVscore  proxyreport

*Save handcolleted data
save Handcollected_ISSGOV6, replace

*Merge handcollected data back to main file 
set more off
use Master4, clear
merge 1:1 wc06008 year using Handcollected_ISSGOV6, force
drop if _merge==2  


*Adjust handcollected dummy variables 0 for Masterfile (do not adjust numerical variables, such as BoardSize and GOVscore)
foreach x of varlist HandcollectedGOV Board1all_d Board2all_d Comp1all_d Audit1all_d  {
	replace `x'=0 if `x'==.
}
*

*Adjust treatment and control dummies (_sample2) in Masterfile for coverage of handcollected data
foreach x of varlist control5y1_s2 control5y2_s2 TreatmentGroup5y_s2 Post5y_s2 Post_Treatment5y_s2  {
	replace `x'=0 if HandcollectedGOV==0
}
*
***

save Master5, replace
***
use Master5, clear

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
*		II. RESULTS (as of November 2018)
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 1: Sample Description
*
********************************************************************************
********************************************************************************
********************************************************************************

set more off
use Master3, clear

*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"

*-------------------------------------------------------------------------------
* Panel A (Table 1). Sample Selection
*-------------------------------------------------------------------------------

* (0) Start: Woldscope Firm universe (ISIN available)
tab year if (year_4|year_5|year_6)

* (1) Worldscope Data unavailable
drop if Q_sample ==.
drop if CONTROL_sample ==.
tab year if (year_4|year_5|year_6)

* (2) Datastream Data unavailable
drop if ML_sample ==.
tab year if (year_4|year_5|year_6)

* (3) IBES Data unavailable
drop if  AF_sample ==.
tab year if (year_4|year_5|year_6)

* (4) TRAA Data unavailable
drop if  IO_sample ==.
tab year if (year_4|year_5|year_6)

* (5) Balanced Sample Structure
use Master4, clear
*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"
***
tab year if (year_4|year_5|year_6)& ($TREATMENT_all | $CG1_all |$CG2_all)
tabstat ISScoverage if ($TREATMENT_all | $CG1_all|$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) 

* (6) Balanced Sample Structure with handcollected GOV data available: GOV
use Master5, clear
*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"
***
tab year if (year_4|year_5|year_6) & ($TREATMENT_all | $CG1_all |$CG2_all)
tabstat ISScoverage if ($TREATMENT_all | $CG1_all|$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) 


*-------------------------------------------------------------------------------
* Panel B (Table 1). Sample Distribution
*-------------------------------------------------------------------------------

tabstat ISScoverage if ($TREATMENT_all | $CG1_all |$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) by(year)
tabstat ISScoverage if $TREATMENT_all  & (year_4|year_5|year_6), stat (n sum mean) by(year)
tabstat ISScoverage if $CG1_all & (year_4|year_5|year_6), stat (n sum mean) by(year)
tabstat ISScoverage if $CG2_all & (year_4|year_5|year_6) , stat (n sum mean) by(year)

********************************************************************************
********************************************************************************
********************************************************************************
*
* TABLE 2: Baseline Results: Average Treatment Effect
*
********************************************************************************
********************************************************************************
********************************************************************************

set more off
use Master5, clear

*-------------------------------------------------------------------------------
* Panel A (Table 2): Mean comparisons 
*-------------------------------------------------------------------------------

qui estpost tabstat ISScoverage, stat(n) 
esttab using Platzhalter.rtf, replace cells("count(fmt(0))")  noobs nonumbers  title  (START)
	
foreach x of varlist GOVscore MLpc_ALLm60FY  lnRECNOmedian_m60FY IB_InvManNonIndex  {
	
set more off
use Master5, clear

*VARIABLE MANAGEMENT
set more off
macro dir  
macro drop CG1 CG2 TREATMENT POST DV PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global DV 			"`x'" 
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

						
*** PANEL A: Main Descriptive Analysis and Univariate DiD

qui estpost tabstat $DV if ($TREATMENT ) & ($PREPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))    count(fmt(0))")  noobs nonumbers  title  ((1) TREATMENT & PREPERIOD: `x' ) compress order ($DV) keep ($DV )
qui estpost tabstat $DV if ($TREATMENT ) & ($POSTPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))    count(fmt(0))")  noobs nonumbers  title  ((2) TREATMENT & POSTPERIOD: `x') compress order ($DV)  keep ($DV)
qui estpost ttest $DV  if  ($TREATMENT) & ($PREPERIOD|$POSTPERIOD), by($PREPERIOD) 
	esttab using Platzhalter.rtf, append cells("b(fmt(2))  t(fmt(2))  p(fmt(2))  count(fmt(0))")  noobs nonumbers coeflabels(`x') title  ((1) TREATMENT & PREPERIOD vs.POSTPERIOD: `x') compress order ($DV) keep ($DV)
***
qui estpost tabstat $DV if ($CG1|$CG2 ) & ($PREPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))     count(fmt(0))")  noobs nonumbers  title  ((3) CG1CG2 & PREPERIOD: `x') compress order ($DV) keep ($DV)
qui estpost tabstat $DV if ($CG1|$CG2 ) & ($POSTPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))   count(fmt(0))")  noobs nonumbers  title  ((4) CG1CG2 & POSTPERIOD: `x') compress order ($DV) keep ($DV)
qui estpost ttest $DV  if  ($CG1|$CG2) & ($PREPERIOD|$POSTPERIOD), by($PREPERIOD) 
	esttab using Platzhalter.rtf, append cells("b(fmt(2))  t(fmt(2))  p(fmt(2))  count(fmt(0))")  noobs nonumbers coeflabels(`x') title  ((1) TREATMENT & PREPERIOD vs.POSTPERIOD: `x') compress order ($DV)  keep ($DV)
***
set more off
sort i year
gen var1 = $TREATMENT
gen var2 = ($CG1|$CG2)
***
	forvalues i = 1(1)2 {
		
		gen help1 = $DV if (var`i') & ($PREPERIOD)
		egen meanhelp1=mean(help1) if (var`i') & ($PREPERIOD), by(i)
		egen maxhelp1=max(meanhelp1)  if (var`i'), by(i)

		gen help2 = $DV if (var`i') & ($POSTPERIOD)
		egen meanhelp2=mean(help2) if (var`i') & ($POSTPERIOD), by(i)
		egen maxhelp2=max(meanhelp2)  if (var`i'), by(i)

		gen DV_var`i'diff=maxhelp2-maxhelp1
		drop help1-maxhelp2

}
***
drop var1 - var2
ttest DV_var1diff==0 if  ($PREPERIOD)
ttest DV_var2diff==0 if  ($PREPERIOD)
ttest DV_var1diff == DV_var2diff if  ($PREPERIOD), unpaired
}
*

********************************************************************************
********************************************************************************

set more off
use Master5, clear

*VARIABLE MANAGEMENT:
set more off
macro dir 
macro drop CG1  CG2 TREATMENT POST POST_TREAT DV1 CONTROLVAR1 DV2 CONTROLVAR2 PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global POST_TREAT   "Post_Treatment5y_s2"
global DV1 			"GOVscore" 
global CONTROLVAR1 	"lnsizewin99 levwin99 ROAwin99  growthwin99  noshffwin99 BoardSize asset4"
global DV2 			"MLpc_ALLm60FY" 
global CONTROLVAR2 	"lnMVmedian_m60FYwin99 lnRV_m60FYwin99 levwin99 ROAwin99 PPE_TAwin99 inv_stockpricewin99  IFRS noshffwin99 asset4"
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

*-------------------------------------------------------------------------------
* Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity
*-------------------------------------------------------------------------------
						
estimates clear
quietly reg $DV1 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST  $CONTROLVAR1 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly reg $DV2 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST  $CONTROLVAR2 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
esttab,  	star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)   title (Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
esttab using Platzhalter.rtf, replace ///
				star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)  label title (Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress varwidth(12)  modelwidth(6) ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
estimates clear


********************************************************************************
********************************************************************************

set more off
use Master5, clear

*VARIABLE MANAGEMENT:
set more off
macro dir 
macro drop CG1  CG2 TREATMENT POST POST_TREAT DV1 CONTROLVAR1 DV2 CONTROLVAR2 PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global POST_TREAT   "Post_Treatment5y_s2"
global DV1 			"lnRECNOmedian_m60FY" 
global CONTROLVAR1 	"lnsizewin99 levwin99 ROAwin99 PPE_TAwin99 noshffwin99 IFRS inv_stockpricewin99 asset4"
global DV2 			"IB_InvManNonIndex" 
global CONTROLVAR2 	"lnsizewin99 levwin99 ROAwin99  cfowin99 dpswin99 PPE_TAwin99 IFRS inv_stockpricewin99 asset4 "
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

*-------------------------------------------------------------------------------
* Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth
*-------------------------------------------------------------------------------
						
estimates clear
quietly reg $DV1 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST  $CONTROLVAR1 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly reg $DV2 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST  $CONTROLVAR2 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
esttab,  	star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)   title (Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
esttab using Platzhalter.rtf, replace ///
				star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)  label title (Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress varwidth(12)  modelwidth(6) ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
estimates clear



*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*		THE END
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
*
*	Do corporate governance analysts matter? Evidence from the expansion of governance analyst coverage (2018)
*
*	Nico Lehmann (Georg-August University of Goettingen, nico.lehmann@wiwi.uni-goettingen.de)
*
*	The Stata do-file uses all nine datasets (see "NL_data description") as inputs and provides a detailed step-by-step description that enables other researchers to arrive at the same dataset used in my study. 
*	In addition, it shows the Stata code for the main empirical analysis presented in Table 2 of the paper.
*	The analysis is based on three different data source types:
*		(1) commercially available data (i.e., Datastream, Worldscope, IBES, TRAA),
*		(2) proprietary data (ISS coverage data, FTSE/ISS index membership data),
*		(3) publically available data (handcolleted governance data from annual reports). 
*	Please read the data description ("NL_data description") accompanying this do-file beforehand for more details on the different data sources. 
*
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************


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
*  (1.1): Read and clean Datastream, Worldscope, Asset4 raw data  
*-------------------------------------------------------------------------------

set more off
use TR_data, clear // Thomson Reuters dataset contains UK panel data for the years between 2001 and 2009

***Labelling variables

*COMPANY INFO 
label var wc05350 "Date Of Fiscal Year End (Key Item)"
label var wc06001 "Company Name (Key Item)"
label var wc06008 "Isin Number "
label var wc07536 "Accounting Standards Followed"
label var wc07021 "Sic Code 1 "
label var wc05661 "Stock Index Information "

*BALANCE 
label var wc03251 "Long Term Debt (WS) (Key Item) "
label var wc02501 "Property, Plant And Equipment - Net (Key Item) "
label var wc02999 "Total Assets (WS) (Key Item) "
label var dwta "Total Assets (Datastream)"
label var dwse "Book Value of Equity (Datastream)"
label var wc03501 "Common Equity (Key Item) "  
    
*INCOME 
label var wc01001 "Net Sales Or Revenues (Key Item)"
label var wc04001 "Net Income before extraordinary items"

*CFS
label var wc04860 "Net Cash Flow - Operating Activities (Key Item) "

*DIVIDENDS, SHARES & MARKET PRICES  
label var wc05101 "Dividends Per Share (WS) (Key Item) "
label var wc05001 "Market Price - Year End "
label var mv "Market Capitalisation (Datastream)"
label var nosh "Number of shares " 
  
*OWNERSHIP 
label var noshff "Free Float Number Of Shares "

*ASSET4 Info
label var cgvscore "Corporate Governance Score (ESG - ASSET4)"  


***Clean dataset to save estimation power: Delete observations where main variables are missing (total assets [numerical] and isin [string var])
drop if wc02999==.
drop if wc06008==""

***Creating variables***
***Creating fiscal year-end information (split the wc05350 - the month/day/year string var)
split wc05350, p(.)
destring wc053501, gen(day)
destring wc053502, gen(month)
destring wc053503, gen(year)
drop wc053501 wc053502 wc053503

***Duplicates
egen i=group(wc06008)
drop if i==.
drop if year==.
drop if year==2010
duplicates report i year
duplicates drop i year, force

***Identifying pooled data structure
tsset i year

***Creating Year-Dummies (one dummy for each year)
tab year, gen(year_)

***Save data
save Master1, replace


*-------------------------------------------------------------------------------
*  (1.2): Read and clean ISS data  
*-------------------------------------------------------------------------------

set more off
insheet using ISScoverage_data.txt, clear

*Labeling key variables
label var countrycgq	"ISS Country CGQ rating" 

***Identifier and country selection
capture drop wc06008
gen wc06008=isinmanuallycompleted
drop if wc06008==""
drop if indexcgq==.
keep if country=="United Kingdom"
sort wc06008 year

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data2, replace


*-------------------------------------------------------------------------------
*  (1.3): Read and clean IBES & stock data 
*-------------------------------------------------------------------------------

set more off
use IBES_data, clear

*Labelling key variables (all variables are averaged across a period of 60 days prior to the respective fiscal year-end)
label var RECNOmedian_m60FY		"Number of issued recommendations per firm " 
label var F1NEmedian_m60FY 		"Number of issued EPS forecasts per firm "
label var MVmedian_m60FY 		"Average fiscal year’s market value of equity "
label var RV_m60FY		 		"Standard deviation of daily share returns "
label var BASmedian_m60FY 		"Bid-ask spreads based on daily closing bid and ask prices "
label var ZTDmean_m60FY 		"Proportion of zero share return days "
label var TOmedian_m60FY	 	"Stock trading volume "

***Identifier
drop if isin==""
sort isin year
gen wc06008=isin

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data3, replace


*-------------------------------------------------------------------------------
*  (1.4): Read and clean TRAA data
*-------------------------------------------------------------------------------

set more off
use TRAA_data, clear

*Labelling key variables
label var IB_InvManNonIndex			"Number of institutional investors per firm scaled by the number of all institutional investors in the market" 
label var OTCountInvMan_nonIndex 	"Number of institutional investors per firm"

***Identifier
drop if isin==""
sort isin year
gen wc06008=isin

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data4, replace


*-------------------------------------------------------------------------------
*  (1.5): Read and clean FTSE/ISS data  
*-------------------------------------------------------------------------------

set more off
import excel ISSFTSE_data.xlsx, clear sheet(Handcollected_Feb2018) first

*Labelling key variables
capture drop FTSEISScoverage
gen FTSEISScoverage=1
label var FTSEISScoverage	"FTSEISS index inclusion dummy" 
label var WtCGI 			"FTSEISS index weights"

***Year 
split Date, p(/)
destring Date1, gen(month)
destring Date2, gen(day)
destring Date3, gen(year)
drop Date1 Date2 Date3

***Sample and identifier 
drop if year==.
drop if isin==""
capture drop wc06008
gen wc06008=isin
sort wc06008 year

***Duplicates
duplicates report wc06008 year
duplicates drop wc06008 year, force

***Save data
capture drop _merge
save Data5, replace


********************************************************************************
********************************************************************************
*  Step 2: Merge datasets  
********************************************************************************
********************************************************************************


set more off
use Master1, clear
sort wc06008 year
 forvalues i = 2(1)5 {
		merge 1:1 wc06008 year using Data`i', force
		drop if _merge==2 
		drop _merge 
}
*
sort i year
***
save Master2, replace
***
use Master2, clear



********************************************************************************
********************************************************************************
*  Step 3: Compute key variables
********************************************************************************
********************************************************************************



*-------------------------------------------------------------------------------
*  (3.1): ISS & ISS/FTSE variables  
*-------------------------------------------------------------------------------

***Treatment 
gen ISScoverage=.
replace ISScoverage=0 if countrycgq==.
replace ISScoverage=1 if ISScoverage==.

***FTSEISS Index Inclusion as Treatment reason  
replace FTSEISScoverage=0 if FTSEISScoverage==.
label var FTSEISScoverage "FTSEISS index inlusion dummy"
replace WtCGI=0 if WtCGI==.
label var WtCGI "FTSEISS index weights"


*-------------------------------------------------------------------------------
*  (3.2): Dependent variables  
*-------------------------------------------------------------------------------

***Financial Analyst Following
sum F1NEmean_CY - RECNOmax_m60FY 

*Key variables  
foreach x of varlist F1NEmean_CY - RECNOmax_m60FY {
	replace `x'=0 if `x'==.
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (AF_sample) 
pca F1NEmean_CY - RECNOmax_m60FY
predict AF_sample, score


***Stock Liquidity
sum BASmean_CY- MVmedian_m60FY

*Key variables 
foreach x of varlist BASmean_CY- MVmedian_m60FY {
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (ML_sample)  
pca BASmean_CY- ZTDmean_m60FY  TVmean_CY- MVmedian_m60FY   
predict ML_sample, score


	
***Institutional Ownership (IO measures multiplied by 1000 for the sake of interpretation ease)
sum OwnTypCount_ALL - IB_OthersNonIndex

*Key variables 
foreach x of varlist IB_ALL - IB_OthersNonIndex  {
	replace `x'=0 if `x'==.
	replace `x'=`x'*1000
 }
*
foreach x of varlist OwnTypCount_ALL - IB_OthersNonIndex  {
	*replace `x'=0 if `x'==.
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (IO_sample)  
pca OwnTypCount_ALL - IB_OthersNonIndex 
predict IO_sample, score
		
		
***Tobin's Q

*Key variables
gen lnQ = ln((dwta+(mv*1000)-dwse) / (dwta))
label var lnQ "Ln of Tobin's Q based on Datastream data"

***
foreach x of varlist lnQ {
	winsor `x', generate (`x'win99) p(0.01)
 }
*Sample Identifier (Q_sample)
pca lnQ lnQwin99  
predict Q_sample, score


*-------------------------------------------------------------------------------
*  (3.3): Control variables  
*-------------------------------------------------------------------------------

*Firm Size in Total Assets
gen lnsize=ln(dwta *1000)
label var lnsize "Ln of total assets (dwta)"

*Market Capitalization
gen lnMaCap1=ln(mv)
label var lnMaCap1 "Ln of market value (mv)"

gen lnMaCap2=ln(nosh*wc05001)
label var lnMaCap2 "Ln of market value (mv)"

*Return on assets
gen ROA=wc04001/wc02999
label var ROA "Net Income before extraordinary items (wc04001) scaled by TA (wc02999)"

* Growth in sales
gen growth=(wc01001-l.wc01001)/l.wc01001
label var growth "Percentage change in sales (wc01001)"

*Leverage
gen lev=wc03251  /wc02999
label var lev"Accounting leverage long-term debt (wc03251) to ta (wc02999)"

*Dividend per Share
gen dps= wc05101
label var dps "dividends per share (wc05101)"

*PPE to TA
gen PPE_TA=wc02501/wc02999
label var PPE_TA "Net PPE (wc02501) to total assets (wc02999)"

*Cash from operations
gen cfo=wc04860/wc02999
label var cfo "Cash flow from operations (direct) deflated by ta"

*Inverse Stock Price
gen inv_stockprice=(-1)*wc05001
label var inv_stockprice "Inverse Stock price based on (wc05001)"

*IFRS Dummy
gen IFRS=.
replace IFRS=1 if wc07536=="IFRS"
replace IFRS=0 if IFRS==.
label var IFRS "IFRS reporting (wc07536)"

*Asset4 Coverage
gen asset4=.
replace asset4=0 if cgvscore == .
replace asset4=1 if asset4 == .
label var asset4 "Asset4 coverage (based on cgvscore)"

*Creating index information (split the wc05661)
gen stockindex=wc05661
split stockindex, p(,)
sort i year
gen FTSE100=.
foreach x of varlist stockindex*  {
		replace FTSE100=1 if `x'=="FTSE 100"
		replace FTSE100=1 if `x'==" FTSE 100"
}
*
replace FTSE100=0 if FTSE100==.
label var FTSE100 "FTSE100 - 100 largest firms at the London Stock Exchange (based on wc05661)"

***
gen FTSE250=.
foreach x of varlist stockindex*  {
		replace FTSE250=1 if `x'=="FT-SE 250"
		replace FTSE250=1 if `x'==" FT-SE 250"
}
*
replace FTSE250=0 if FTSE250==.
label var FTSE250 "FTSE 250 - 250 largest firms at the London Stock Exchange (based on wc05661)"
***
gen FTSEall=.
foreach x of varlist stockindex*  {
		replace FTSEall=1 if `x'=="FTSE ALL"
		replace FTSEall=1 if `x'==" FTSE ALL"
}
*
replace FTSEall=0 if FTSEall==.
label var FTSEall "FTSE ALL - ca. 500 largest firms at the London Stock Exchange (based on wc05661)"
***
drop stockindex*


*SIC industry classification
tostring wc07021, replace
gen nul="0"
gen nul2="00"
gen nul3="000"
egen hulp=concat(nul wc07021) if length(wc07021)==3
replace wc07021=hulp if length(wc07021)==3
drop hulp
egen hulp=concat(nul wc07021) if length(wc07021)==2
replace wc07021=hulp if length(wc07021)==2
drop hulp
egen hulp=concat(nul wc07021) if length(wc07021)==1
replace wc07021=hulp if length(wc07021)==1
drop hulp
drop nul*

*First-digit SIC groups (depends on your sample size)
gen ind1=substr(wc07021,1,1)
label var ind1 "First-digit sic group"
destring ind1, replace
tab ind1, gen(ind1_)


*-------------------------------------------------------------------------------
*  (3.4): Winsorize all control variables  
*-------------------------------------------------------------------------------

set more off
foreach x of varlist lnsize- inv_stockprice noshff {
	gen ln`x'=ln(`x'+1)
	winsor `x', generate (`x'win99) p(0.01)
	winsor ln`x', generate (ln`x'win99) p(0.01)
 }
*Sample Identifier (CONTROL_sample)
pca lnsize lnMaCap1 lnMaCap2 ROA growth lev dps PPE_TA cfo inv_stockprice noshff
predict CONTROL_sample, score

*-------------------------------------------------------------------------------
*  (3.5): Define subsamples w.r.t. individual data availability   
*-------------------------------------------------------------------------------

***Overall Sample
gen sample1 = .
replace sample1=1 if (AF_sample!=. & ML_sample!=. & IO_sample!=. & Q_sample!=.)

gen sample2 = .
replace sample2=1 if (AF_sample!=. & ML_sample!=. & IO_sample!=. & Q_sample!=. & CONTROL_sample!=.)

***

save Master3, replace
***
use Master3, clear


********************************************************************************
********************************************************************************
*  Step 4: Impose balanced sample restrictions & define DiD structure
********************************************************************************
********************************************************************************


*-------------------------------------------------------------------------------
*  (4.1): Define balanced DiD samples for each subsample 
*-------------------------------------------------------------------------------


set more off
	forvalues i = 1(1)2 {
	
		use Master3, replace
		drop if  sample`i' ==. 
		
		***PANEL Structure: 5-YEARS Structure (2003-2007) 
		gen company5y_id=i 
		replace company5y_id=0 if year_1==1
		replace company5y_id=0 if year_2==1
		replace company5y_id=0 if year_8==1
		replace company5y_id=0 if year_9==1
		sort company5y_id 
		by  company5y_id : gen eventcount5y1=_N 
		replace eventcount5y1=0 if company5y_id==0
		***
		gen CompleteSample5y=.
		replace CompleteSample5y=1 if eventcount5y1==5
		replace CompleteSample5y=0 if CompleteSample5y==.

		***CONTROL2: firms with constant ISS ratings
		gen ISS_id=ISScoverage
		sort  ISS_id  company5y_id
		by  ISS_id  company5y_id : gen eventcount5y2=_N 
		replace eventcount5y2=0 if company5y_id==0
		replace eventcount5y2=0 if ISScoverage==0
		***
		gen control5y2=.
		replace control5y2=1 if eventcount5y2==5
		replace control5y2=0 if control5y2==.

		***CONTROL1: firms with constant NON-ISS ratings
		gen nonISS_id=.
		replace nonISS_id=0 if ISScoverage ==1
		replace nonISS_id=1 if nonISS_id==.
		sort  nonISS_id  company5y_id
		by  nonISS_id  company5y_id: gen eventcount5y3=_N 
		replace eventcount5y3=0 if company5y_id==0
		replace eventcount5y3=0 if ISScoverage==1
		replace eventcount5y3=0 if control5y2==1
		***
		gen control5y1=.
		replace control5y1=1 if eventcount5y3==5
		replace control5y1=0 if control5y1==.

		***RESIDUAL: firms with and without ISS ratings (nonsystematic)
		gen ResidualGroup5y=.
		replace ResidualGroup5y=1 if CompleteSample5y==1
		replace ResidualGroup5y=0 if control5y2==1
		replace ResidualGroup5y=0 if control5y1==1
		replace ResidualGroup5y=0 if ResidualGroup5y==.

		***TREATMENT: firms with constant NON-ISS ratings prior to 2005 and constant ISS ratings afterwards
		sort isin
		by isin: egen ISScov0304y=sum(ISScoverage) if (year_3==1 | year_4==1)
		by isin: egen ISScov0507y=sum(ISScoverage) if (year_5==1 | year_6==1| year_7==1)
		replace ISScov0304y=0 if ResidualGroup5y==0
		replace ISScov0507y=0 if ResidualGroup5y==0
		replace ISScov0304y=0 if ISScov0304y==.
		replace ISScov0507y=0 if ISScov0507y==.
		sort isin
		by isin: egen MaxISScov0304y= max(ISScov0304y)
		by isin: egen MaxISScov0507y= max(ISScov0507y)
		***
		gen TreatmentGroup5y=.
		replace TreatmentGroup5y=1 if  MaxISScov0304y==0 & MaxISScov0507y==3  & ResidualGroup5y==1
		replace TreatmentGroup5y=0 if  TreatmentGroup5y==.

		***SUMMARY (control) REPORTS on each individual panel subsample
		tabstat ISScoverage if CompleteSample5y , stat (n sum mean) by(year)
		tabstat CompleteSample5y , stat (n sum mean) by(year)
		tabstat ISScoverage if control5y2 , stat (n sum mean) by(year)
		tabstat control5y2 , stat (n sum mean) by(year)
		tabstat ISScoverage if control5y1 , stat (n sum mean) by(year)
		tabstat control5y1 , stat (n sum mean) by(year)
		tabstat ISScoverage if ResidualGroup5y , stat (n sum mean) by(year)
		tabstat ResidualGroup5y , stat (n sum mean) by(year)
		tabstat ISScoverage if TreatmentGroup5y , stat (n sum mean) by(year)
		tabstat TreatmentGroup5y , stat (n sum mean) by(year)

		***TIME structure
		gen Post= year_5 + year_6 + year_7 
		gen Ante= year_3 + year_4
		gen Post_Treatment=TreatmentGroup5y*Post
		gen Ante_Treatment=TreatmentGroup5y*Ante
		gen Post_control5y1=control5y1*Post
		gen Ante_control5y1=control5y1*Ante
		gen Post_control5y2=control5y2*Post
		gen Ante_control5y2=control5y2*Ante


		***Subsample specific labelling
		rename control5y2 control5y2_s`i'
		rename control5y1 control5y1_s`i'
		rename TreatmentGroup5y TreatmentGroup5y_s`i'
		rename Post_Treatment Post_Treatment5y_s`i'
		rename Post Post5y_s`i'
		rename Ante Ante5y_s`i'

		***Clean and save
		keep wc06008 year control5y2_s`i' control5y1_s`i' TreatmentGroup5y_s`i' Post_Treatment5y_s`i' Post5y_s`i' Ante5y_s`i'
		save EM2data4_s`i', replace
}
*

*-------------------------------------------------------------------------------
*  (4.2): Merge Subsamples and Sample Selection variables with Masterfile 
*-------------------------------------------------------------------------------

set more off
use EM2data4_s1, replace	
sort wc06008 year
	forvalues i = 2(1)2 {
		merge 1:1 wc06008  year using EM2data4_s`i'
		drop if _merge ==2
		drop _merge
		save EM2data4_sALL, replace
}
*
use Master3, replace
sort wc06008 year
set more off
merge 1:1 wc06008 year using EM2data4_sALL
drop if _merge ==2
drop _merge
	
	
*-------------------------------------------------------------------------------
*  (4.3): Adjust Selection Variables for Masterfile
*-------------------------------------------------------------------------------
	
set more off
	forvalues i = 1(1)2 {
		replace  control5y2_s`i'=0 if control5y2_s`i'==.
		replace  control5y1_s`i'=0 if control5y1_s`i'==.
		replace  TreatmentGroup5y_s`i'=0 if TreatmentGroup5y_s`i'==.
		replace  Post_Treatment5y_s`i'=0 if Post_Treatment5y_s`i'==.
		replace  Post5y_s`i'=0 if Post5y_s`i'==.
		replace  Ante5y_s`i'=0 if Ante5y_s`i'==.
		
}
*
capture drop sample1-sample2


*-------------------------------------------------------------------------------
*  (4.4): PCA for COMPLETE sample with Controls (sample2)
*-------------------------------------------------------------------------------

*VARIABLE MANAGEMENT
set more off
macro dir
macro drop CG1 CG2 PERIOD TREATMENT
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global PERIOD		"year_3|year_4|year_5|year_6|year_7"
global TREATMENT  	"TreatmentGroup5y_s2"

***MARKET LIQUIDITY measures based on PCA
pca lnBASmedian_m60FYwin99  ZTDmean_m60FY lnTOmedian_m60FYwin99   if   ($CG1 | $CG2 | $TREATMENT) & ($PERIOD)
predict help1  if   ($CG1 | $CG2 | $TREATMENT) & ($PERIOD), score
gen MLpc_ALLm60FY_raw = help1  
gen MLpc_ALLm60FY = MLpc_ALLm60FY_raw*(-1)  
drop help1

*** DROP Melrose Resource (MRS, Melrose Resources, GB0009354589) as it is included in FTSEISS Index but NOT in CGQ dataset - I thus correct dataset for data inconsistency in ISS files (Revision Feb 2018, location of drop command does not affect my findings)  
drop if isin=="GB0009354589"

***
save Master4, replace


*-------------------------------------------------------------------------------
*  (4.5): Handcollected governance data based on COMPLETE sample 
*-------------------------------------------------------------------------------

set more off
import excel using GOV_data.xlsx, first  sheet(data_new1) clear

*Define key variables
foreach x of varlist Board1all Board2all  Comp1all Audit1all  {
	gen `x'_d=`x'=="YES"
	replace `x'_d=. if `x'==""
}
gen GOVscore= (Board1all_d+Board2all_d+Comp1all_d+Audit1all_d)/4

*Labelling key variables
label var GOVscore 		"Composite governance index"
label var Board1all_d 	"CEO/chairman duality" 
label var Board2all_d 	"Board Independence " 
label var Comp1all_d 	"Compensation committee independence " 
label var Audit1all_d 	"Audit committee independence " 


*Sample & duplicates
egen count =count(GOVscore), by(isin)
drop if count!=3
gen HandcollectedGOV=1
capture drop wc06008
gen wc06008=isin
duplicates report wc06008 year
sort wc06008 year
keep HandcollectedGOV wc06008 year CGQdata  annualreport Board1all Board2all Comp1all Audit1all BoardSize Board1all_d Board2all_d Comp1all_d Audit1all_d GOVscore  proxyreport

*Save handcolleted data
save Handcollected_ISSGOV6, replace

*Merge handcollected data back to main file 
set more off
use Master4, clear
merge 1:1 wc06008 year using Handcollected_ISSGOV6, force
drop if _merge==2  


*Adjust handcollected dummy variables 0 for Masterfile (do not adjust numerical variables, such as BoardSize and GOVscore)
foreach x of varlist HandcollectedGOV Board1all_d Board2all_d Comp1all_d Audit1all_d  {
	replace `x'=0 if `x'==.
}
*

*Adjust treatment and control dummies (_sample2) in Masterfile for coverage of handcollected data
foreach x of varlist control5y1_s2 control5y2_s2 TreatmentGroup5y_s2 Post5y_s2 Post_Treatment5y_s2  {
	replace `x'=0 if HandcollectedGOV==0
}
*
***

save Master5, replace
***
use Master5, clear

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
*		II. RESULTS (as of November 2018)
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


********************************************************************************
********************************************************************************
********************************************************************************
*
*	TABLE 1: Sample Description
*
********************************************************************************
********************************************************************************
********************************************************************************

set more off
use Master3, clear

*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"

*-------------------------------------------------------------------------------
* Panel A (Table 1). Sample Selection
*-------------------------------------------------------------------------------

* (0) Start: Woldscope Firm universe (ISIN available)
tab year if (year_4|year_5|year_6)

* (1) Worldscope Data unavailable
drop if Q_sample ==.
drop if CONTROL_sample ==.
tab year if (year_4|year_5|year_6)

* (2) Datastream Data unavailable
drop if ML_sample ==.
tab year if (year_4|year_5|year_6)

* (3) IBES Data unavailable
drop if  AF_sample ==.
tab year if (year_4|year_5|year_6)

* (4) TRAA Data unavailable
drop if  IO_sample ==.
tab year if (year_4|year_5|year_6)

* (5) Balanced Sample Structure
use Master4, clear
*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"
***
tab year if (year_4|year_5|year_6)& ($TREATMENT_all | $CG1_all |$CG2_all)
tabstat ISScoverage if ($TREATMENT_all | $CG1_all|$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) 

* (6) Balanced Sample Structure with handcollected GOV data available: GOV
use Master5, clear
*Variable Management
macro drop CG1_all CG2_all TREATMENT_all   
global CG1_all 			"control5y1_s2"
global CG2_all  		"control5y2_s2"
global TREATMENT_all  	"TreatmentGroup5y_s2"
***
tab year if (year_4|year_5|year_6) & ($TREATMENT_all | $CG1_all |$CG2_all)
tabstat ISScoverage if ($TREATMENT_all | $CG1_all|$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) 


*-------------------------------------------------------------------------------
* Panel B (Table 1). Sample Distribution
*-------------------------------------------------------------------------------

tabstat ISScoverage if ($TREATMENT_all | $CG1_all |$CG2_all) & (year_4|year_5|year_6) , stat (n sum mean) by(year)
tabstat ISScoverage if $TREATMENT_all  & (year_4|year_5|year_6), stat (n sum mean) by(year)
tabstat ISScoverage if $CG1_all & (year_4|year_5|year_6), stat (n sum mean) by(year)
tabstat ISScoverage if $CG2_all & (year_4|year_5|year_6) , stat (n sum mean) by(year)

********************************************************************************
********************************************************************************
********************************************************************************
*
* TABLE 2: Baseline Results: Average Treatment Effect
*
********************************************************************************
********************************************************************************
********************************************************************************

set more off
use Master5, clear

*-------------------------------------------------------------------------------
* Panel A (Table 2): Mean comparisons 
*-------------------------------------------------------------------------------

qui estpost tabstat ISScoverage, stat(n) 
esttab using Platzhalter.rtf, replace cells("count(fmt(0))")  noobs nonumbers  title  (START)
	
foreach x of varlist GOVscore MLpc_ALLm60FY  lnRECNOmedian_m60FY IB_InvManNonIndex  {
	
set more off
use Master5, clear

*VARIABLE MANAGEMENT
set more off
macro dir  
macro drop CG1 CG2 TREATMENT POST DV PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global DV 			"`x'" 
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

						
*** PANEL A: Main Descriptive Analysis and Univariate DiD

qui estpost tabstat $DV if ($TREATMENT ) & ($PREPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))    count(fmt(0))")  noobs nonumbers  title  ((1) TREATMENT & PREPERIOD: `x' ) compress order ($DV) keep ($DV )
qui estpost tabstat $DV if ($TREATMENT ) & ($POSTPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))    count(fmt(0))")  noobs nonumbers  title  ((2) TREATMENT & POSTPERIOD: `x') compress order ($DV)  keep ($DV)
qui estpost ttest $DV  if  ($TREATMENT) & ($PREPERIOD|$POSTPERIOD), by($PREPERIOD) 
	esttab using Platzhalter.rtf, append cells("b(fmt(2))  t(fmt(2))  p(fmt(2))  count(fmt(0))")  noobs nonumbers coeflabels(`x') title  ((1) TREATMENT & PREPERIOD vs.POSTPERIOD: `x') compress order ($DV) keep ($DV)
***
qui estpost tabstat $DV if ($CG1|$CG2 ) & ($PREPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))     count(fmt(0))")  noobs nonumbers  title  ((3) CG1CG2 & PREPERIOD: `x') compress order ($DV) keep ($DV)
qui estpost tabstat $DV if ($CG1|$CG2 ) & ($POSTPERIOD) , stat(mean min max n) 
	esttab using Platzhalter.rtf, append cells("mean(fmt(2))   count(fmt(0))")  noobs nonumbers  title  ((4) CG1CG2 & POSTPERIOD: `x') compress order ($DV) keep ($DV)
qui estpost ttest $DV  if  ($CG1|$CG2) & ($PREPERIOD|$POSTPERIOD), by($PREPERIOD) 
	esttab using Platzhalter.rtf, append cells("b(fmt(2))  t(fmt(2))  p(fmt(2))  count(fmt(0))")  noobs nonumbers coeflabels(`x') title  ((1) TREATMENT & PREPERIOD vs.POSTPERIOD: `x') compress order ($DV)  keep ($DV)
***
set more off
sort i year
gen var1 = $TREATMENT
gen var2 = ($CG1|$CG2)
***
	forvalues i = 1(1)2 {
		
		gen help1 = $DV if (var`i') & ($PREPERIOD)
		egen meanhelp1=mean(help1) if (var`i') & ($PREPERIOD), by(i)
		egen maxhelp1=max(meanhelp1)  if (var`i'), by(i)

		gen help2 = $DV if (var`i') & ($POSTPERIOD)
		egen meanhelp2=mean(help2) if (var`i') & ($POSTPERIOD), by(i)
		egen maxhelp2=max(meanhelp2)  if (var`i'), by(i)

		gen DV_var`i'diff=maxhelp2-maxhelp1
		drop help1-maxhelp2

}
***
drop var1 - var2
ttest DV_var1diff==0 if  ($PREPERIOD)
ttest DV_var2diff==0 if  ($PREPERIOD)
ttest DV_var1diff == DV_var2diff if  ($PREPERIOD), unpaired
}
*

********************************************************************************
********************************************************************************

set more off
use Master5, clear

*VARIABLE MANAGEMENT:
set more off
macro dir 
macro drop CG1  CG2 TREATMENT POST POST_TREAT DV1 CONTROLVAR1 DV2 CONTROLVAR2 PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global POST_TREAT   "Post_Treatment5y_s2"
global DV1 			"GOVscore" 
global CONTROLVAR1 	"lnsizewin99 levwin99 ROAwin99  growthwin99  noshffwin99 BoardSize asset4"
global DV2 			"MLpc_ALLm60FY" 
global CONTROLVAR2 	"lnMVmedian_m60FYwin99 lnRV_m60FYwin99 levwin99 ROAwin99 PPE_TAwin99 inv_stockpricewin99  IFRS noshffwin99 asset4"
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

*-------------------------------------------------------------------------------
* Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity
*-------------------------------------------------------------------------------
						
estimates clear
quietly reg $DV1 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST  $CONTROLVAR1 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly reg $DV2 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST  $CONTROLVAR2 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
esttab,  	star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)   title (Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
esttab using Platzhalter.rtf, replace ///
				star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)  label title (Panel B (Table 2): Difference-in-differences regressions: CorpGov & Liquidity) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress varwidth(12)  modelwidth(6) ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
estimates clear


********************************************************************************
********************************************************************************

set more off
use Master5, clear

*VARIABLE MANAGEMENT:
set more off
macro dir 
macro drop CG1  CG2 TREATMENT POST POST_TREAT DV1 CONTROLVAR1 DV2 CONTROLVAR2 PREPERIOD POSTPERIOD
global CG1 			"control5y1_s2"
global CG2  		"control5y2_s2"
global TREATMENT  	"TreatmentGroup5y_s2" 
global POST			"Post5y_s2"
global POST_TREAT   "Post_Treatment5y_s2"
global DV1 			"lnRECNOmedian_m60FY" 
global CONTROLVAR1 	"lnsizewin99 levwin99 ROAwin99 PPE_TAwin99 noshffwin99 IFRS inv_stockpricewin99 asset4"
global DV2 			"IB_InvManNonIndex" 
global CONTROLVAR2 	"lnsizewin99 levwin99 ROAwin99  cfowin99 dpswin99 PPE_TAwin99 IFRS inv_stockpricewin99 asset4 "
global PREPERIOD 	"year_4"
global POSTPERIOD 	"year_5|year_6"

*-------------------------------------------------------------------------------
* Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth
*-------------------------------------------------------------------------------
						
estimates clear
quietly reg $DV1 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV1 i.$TREATMENT##i.$POST  $CONTROLVAR1 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly reg $DV2 i.$TREATMENT##i.$POST 	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), vce(cluster i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST   i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
quietly areg $DV2 i.$TREATMENT##i.$POST  $CONTROLVAR2 i.year	  	if  ($CG1|$CG2|$TREATMENT)  & ($PREPERIOD|$POSTPERIOD), a(i) cluster(i)
eststo
esttab,  	star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)   title (Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth) ///
				nonumbers mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6"   ) compress ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
esttab using Platzhalter.rtf, replace ///
				star(* 0.10 ** 0.05 *** 0.01) b(3) stats(F N r2_a p_diff)  label title (Panel C (Table 2): Difference-in-differences regressions: Ln(AF) & InvBreadth) ///
				nonumbers mtitles ("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" ) compress varwidth(12)  modelwidth(6) ///
				keep (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2) ///
				order (1.$POST  1.$TREATMENT  1.$TREATMENT#1.$POST  $CONTROLVAR1 $CONTROLVAR2)
estimates clear



*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*
*		THE END
*
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////

*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////
*///////////////////////////////////////////////////////////////////////////////


