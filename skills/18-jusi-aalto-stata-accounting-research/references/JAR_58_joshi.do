
***Journal of Accounting Research****
***Does Private Country by Country Reporting Deter Tax Avoidance & Income Shifting? Evidence from BEPS Action Item 13***
*** Joshi (2020)***

*** Steps for downloading raw data, collating data and creating dependant and independant variables for the primary tax avoidance tests reported in tables 4-7***

*Step 1: Download data from Orbis using the data selection criteria's specified in sections 3.0 and 3.1 as well as in Table 1 of the paper
*Step 2: Download information on STR using OECD's tax database 
*Step 3: Download information on cash taxes paid from Compustat
*Step 4: Merge primary dataset from Orbis with the STR dataset using Country and Year as identifiers
*Step 5: Merge primary dataset from Orbis with the Compustat dataset using ISIN number and Year as identifiers
*Step 6: Compare the pre-tax income and total assets in the matched sample from step 5 and exclude any observations with discrepency
*Step 7: Create the dependant and independant variables used in the study
*Step 8: Conduct empirical analyses

******************************************************************************
*Step 1: Step 1: Download data from Orbis using the data selection criteria's specified in sections 3.0 and 3.1 as well as in Table 1 of the paper
The primary sample in the study consists of EU MNCs. I restrict the sample to EU MNCs because CbCr was effective in EU member states on the same date (January 1, 2016). 
In addition, the tax and legal environments in EU nations are comparable across jurisdictions, and there is better availability of affiliate-level data through 
databases compiled by Bureau van Dijk. I obtain annual financial statements and ownership data for the years 2010 to 2018 from the Orbis database (Bureau van Dijk). 
In the EU, a primary reporting obligation under CbCr arises when, in a multinational group, either the ultimate parent or a member of the group is resident in 
a member state. CbCr requirements for resident and nonresident EU firms when the parent entity is headquartered outside an EU member state depends on whether 
the parent jurisdiction has adopted the rules and on the exchange relationship between parent home country and EU member states. I therefore restrict my primary 
sample to EU headquartered firms and, in an additional analysis (section 8.3), include nonresident EU firms. I start with EU-headquartered firms that are identified 
as global ultimate owners in the Orbis database and that have at least one foreign subsidiary. I exclude financial institutions and firms in the extractive industries 
because they are subject to additional CbCr requirements.  After excluding firms with missing data required to calculate the regression variables, the final sample
 consists of 5,312 EU-headquartered multinationals (57,131 firm year-ends). 

 bysort BvDIDnumber:gen dup = cond(_N==1,0,_n)
drop if dup>1

reshape long varlist, i( BvDIDnumber) j(Year)
drop if misisng( BvDIDnumber)

tab Conscode
drop if Conscode=="U2"


*****************************************************************************
*Step 2:Download information on STR using OECD's tax database 
*https://www.oecd.org/tax/tax-policy/tax-database/



******************************************************************************
*Step 3: Download information on cash taxes paid from Compustat


******************************************************************************
*Step 4: Merge primary dataset from Orbis with the STR dataset using Country and Year as identifiers
merge m:m Year country using "C:\Users\STR Only.dta"
drop if misisng( BvDIDnumber)

***********************************************************************************************************************************************************
*Step 5: Merge primary dataset from Orbis with the Compustat dataset using ISIN number and Year as identifiers
merge m:m ISIN Year using "C:\Users\CETR.dta"
drop if misisng( BvDIDnumber)

***********************************************************************************************************************************************************

*Step 6: Compare the pre-tax income and total assets in the matched sample from step 5 and exclude any observations with discrepency
gen Match=0
replace Match=1 if PTI==PTI_CETR
gen Match1=0
replace Match1=1 if TA==TA_CETR

*****************************************************************************

*Step 7: Create the dependant and independant variables used in the study



gen ETR=TaxationmEUR/PLbeforetaxmEUR
gen MissingETR=0
replace MissingETR=1 if missing(ETR)
gen ETR_R=ETR
replace ETR_R=1 if ETR>1 & MissingETR==0
replace ETR_R=0 if ETR<0 & MissingETR==0

gen ETR_T=ETR
replace ETR_T=. if ETR>1 & MissingETR==0
replace ETR_T=. if ETR<0 & MissingETR==0

gen TaxDiff_R=ETR_R-STR
gen TaxDiff_T=ETR_T-STR

gen CETR=CashTaxPaid/PLbeforetaxmEUR
gen MissingCETR=0
replace MissingCETR=1 if missing(CETR)
gen CETR_R=CETR
replace CETR_R=1 if CETR>1 & MissingCETR==0
replace CETR_R=0 if CETR<0 & MissingCETR==0

gen CETR_T=ETR
replace CETR_T=. if CETR>1 & MissingCETR==0
replace CETR_T=. if CETR<0 & MissingCETR==0


gen ROA= NetIncome/ Totalassets if NetIncome>=0
replace ROA=. if ROA<0

gen Size=log( Totalassets) if Totalassets>0

gen Leverage=( TotalEquityLiab-ShareholdersfundsmEUR)/ Totalassets if Totalassets>0

gen Intang=log( Intangibles) if Intangibles>0

gen R&D= RD/ Totalassets if Totalassets>0

gen Innovation=( Numberofpatents+ Numberoftrademarks)/Totalassets if Totalassets>0



gen POST=1 if Year>2015
replace POST=0 if Year<2016

gen CETR=CashTaxes_CETR_w/PTI_CETR_w
gen MissingCETR=0
replace MissingCETR=1 if missing(CETR)

gen CETR_R=CETR
replace CETR_R=1 if CETR>1 & MissingCETR==0
replace CETR_R=0 if CETR<0 & MissingCETR==0

gen CETR_T=CETR
replace CETR_T=. if CETR>1 & MissingCETR==0
replace CETR_T=. if CETR<0 & MissingCETR==0


sort BvDIDnumber Year
by BvDIDnumber: egen PYRevenue=Revenue[_n-1]
gen CBCR=0
replace CBCR=1 if PYRevenue>=750 
replace CBCR=. if Year<2016
by BvDIDnumber: egen MaxCBCR=max(CBCR)
by BvDIDnumber: egen MinCBCR=min(CBCR)
gen Equals=1 if MaxCBCR==MinCBCR
rename CBCR CBCRPOST2015
rename MaxCBCR CBCR if Equals==1
gen CBCR_POST=CBCR*POST

gen EUHQ=0
replace EUHQ=1 if HQLocatedEU=1 
*HQLocatedEU is 1 if the headquarer of the company is located in one of the 21 EU member states
*****************************************************************************

*Step 8: Conduct empirical analyses (below I provide the codes for the base specifications used to estimate the results reported in tables 4-7 in the paper)

*Table 4 (t test)
ttest ETR_R if Year>2015, by(CBCR)
ttest ETR_R, by(BW1_250) 
ttest ETR_R, by(BW1_450) 
ttest ETR_R, by(BW1_550) 

ttest CETR_R if Year>2015, by(CBCR)
ttest CETR_R, by(BW1_250) 
ttest CETR_R, by(BW1_450) 
ttest CETR_R, by(BW1_550) 

ttest TaxDiff_R if Year>2015, by(CBCR)
ttest TaxDiff_R, by(BW1_250) 
ttest TaxDiff_R, by(BW1_450) 
ttest TaxDiff_R, by(BW1_550) 

ttest STR if Year>2015, by(CBCR)
ttest STR, by(BW1_250) 
ttest STR, by(BW1_450) 
ttest STR, by(BW1_550) 

*Table 5 (RDD Base Model)
eststo clear
eststo: rdrobust ETR_R PYRevenue if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust ETR_R PYRevenue if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
eststo: rdrobust TaxDiff_R PYRevenue  if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust TaxDiff_R PYRevenue  if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
eststo: rdrobust CETR_R PYRevenue  if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust CETR_R PYRevenue  if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
esttab using ResultTable5.csv, ar2  p star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*Table 6 (DID Base Model) 
eststo: reghdfe ETR_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe TaxDiff_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe CETR_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
esttab using ResultTable6.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*** Steps for downloading raw data, collating data and creating dependant and independant variables for the primary income shifting tests reported in tables 8***

*Step 1: Start with the BVDId number of primary sample  used for the tax avoidance test. Following the data selection criteria's specified in sections 3.0 and 3.1 
*as well as in Table 1 in the paper, download financial information on the majority owned affiliates via Orbis
*Step 2: Merge CBCR indicator (as this indicator is calculated at the parent level) and other parent level variables with the affiliate dataset using the parent BVDID number
*Step 3: Create the dependant and independant variables used in the study
*Step 4: Conduct empirical analyses

******************************************************************************

*Step 1: Star with the BVDId number of primary sample  used for the tax avoidance test. Following the data selection criteria's specified in sections 3.0 and 3.1 

reshape long varlist , i( BvDIDnumber) j(Year)
drop if missing(BvDIDnumber)
******************************************************************************

*Step 2: Merge CBCR indicator (as this indicator is calculated at the parnet level) and other parent level variables with the affiliate dataset using the parent BVDID number

merge m:m GUOBvDIDnumber Year using "C:\Users\ParentData.dta"
drop if misisng( BvDIDnumber)

******************************************************************************
*Step 3: Create the dependant and independant variables used in the study


Calculation of C (Tax Incentive Variable)
*Though the formula to calculate C is not propriteary, the code developed is propriertary. As such instead of providing the code, I am providing a detail desciption of
*how C is calculated in section 7.0 of the paper. C is the weighted-average statutory tax rate faced by an affilaite and is calculated using the STR of all affiliates
*in thc corporate group as well as scale of firms' operations in the country. C is calculated using affiliate revenue as the measure of scale and alternate C is calculated
*using total assets.C is increasing in the tax burden faced by a firm’s affiliate relative to all other affiliates in the same year.  
 
gen missingC=1 if C==.
egen meanmissingC = mean( missingC), by(GUOBvDIDnumber Year)
egen totalmissingC = sum( missingC), by(GUOBvDIDnumber Year)
egen totalaffiliate = count( BvDIDnumber ), by(GUOBvDIDnumber Year)
gen dummy_affiliate=1
egen totalaffilliate = sum( dummy_affiliate ), by(GUOBvDIDnumber Year)
gen perctmissing= totalmissingC/ totalaffilliate

gen LogPTI=log( PTI) if PTI>=0
replace LogPTI=. if missing(PTI)
gen LogFA=log(Tangiblefixedassets) if Tangiblefixedassets>=0
replace LogFA=. if missing(Tangiblefixedassets)
gen LogGDP=log(GDP) if GDP>=0
gen LogComp=log(EmployeesCost) if EmployeesCost>0
gen LogEmp=log(Employees) if Employees>0
egen Firm=group(BvDIDnumber)
egen Industry=group(NACERev2Corecode4digits)
egen Parent=group(GUOBvDIDnumber)

gen POST=1 if Year>2015
replace POST=0 if Year<2016

*CBCR is determined at the parent level

gen POST_CBCR=POST*CBCR
gen C_POST=C*POST
gen C_POST_CBCR=C*POST*CBCR

******************************************************************************
*Step 4: Conduct empirical analyses

*Base Model used to estimate the results reported in table 8
eststo clear
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  , absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if perctmissingC<0.3 ,  absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC<.2 ,  absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC<.1 , absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC==0 ,  absorb(Parent Year) cluster (Parent)
esttab using ResultTable8-1.csv,  ar2 se star(* 0.1 ** 0.05 *** 0.01)

*Base Model modified by including control variables and different fixed effects

******************************************************************************

*Codes for constructing variables used in the additional analyses 

*Table 7 (Panel A)
gen Year2013=0
replace Year2013=1 if Year==2013
gen CBCR_Year2013=CBCR*Year2013
gen Year2014=0
replace Year2014=1 if Year==2014
gen CBCR_Year2014=CBCR*Year2014
gen Year2015=0
replace Year2015=1 if Year==2015
gen CBCR_Year2015=CBCR*Year2015
gen Year2016=0
replace Year2016=1 if Year==2016
gen CBCR_Year2016=CBCR*Year2016
gen Year2017=0
replace Year2017=1 if Year==2017
gen CBCR_Year2017=CBCR*Year2017
gen Year2018=0
replace Year2018=1 if Year==2018
gen CBCR_Year2018=CBCR*Year2018

eststo: reghdfe ETR_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)
eststo: reghdfe TaxDiff_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe CETR_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)    
esttab using ResultTable7PanelA.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*Table 7 (Panel B)
eststo clear 
eststo: reghdfe ETR_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe ETR_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm) 
eststo: reghdfe TaxDiff_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe TaxDiff_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe CETR_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe CETR_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm)
esttab using ResultTable7PanelB.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects


******************************************************************************

***Journal of Accounting Research****
***Does Private Country by Country Reporting Deter Tax Avoidance & Income Shifting? Evidence from BEPS Action Item 13***
*** Joshi (2020)***

*** Steps for downloading raw data, collating data and creating dependant and independant variables for the primary tax avoidance tests reported in tables 4-7***

*Step 1: Download data from Orbis using the data selection criteria's specified in sections 3.0 and 3.1 as well as in Table 1 of the paper
*Step 2: Download information on STR using OECD's tax database 
*Step 3: Download information on cash taxes paid from Compustat
*Step 4: Merge primary dataset from Orbis with the STR dataset using Country and Year as identifiers
*Step 5: Merge primary dataset from Orbis with the Compustat dataset using ISIN number and Year as identifiers
*Step 6: Compare the pre-tax income and total assets in the matched sample from step 5 and exclude any observations with discrepency
*Step 7: Create the dependant and independant variables used in the study
*Step 8: Conduct empirical analyses

******************************************************************************
*Step 1: Step 1: Download data from Orbis using the data selection criteria's specified in sections 3.0 and 3.1 as well as in Table 1 of the paper
The primary sample in the study consists of EU MNCs. I restrict the sample to EU MNCs because CbCr was effective in EU member states on the same date (January 1, 2016). 
In addition, the tax and legal environments in EU nations are comparable across jurisdictions, and there is better availability of affiliate-level data through 
databases compiled by Bureau van Dijk. I obtain annual financial statements and ownership data for the years 2010 to 2018 from the Orbis database (Bureau van Dijk). 
In the EU, a primary reporting obligation under CbCr arises when, in a multinational group, either the ultimate parent or a member of the group is resident in 
a member state. CbCr requirements for resident and nonresident EU firms when the parent entity is headquartered outside an EU member state depends on whether 
the parent jurisdiction has adopted the rules and on the exchange relationship between parent home country and EU member states. I therefore restrict my primary 
sample to EU headquartered firms and, in an additional analysis (section 8.3), include nonresident EU firms. I start with EU-headquartered firms that are identified 
as global ultimate owners in the Orbis database and that have at least one foreign subsidiary. I exclude financial institutions and firms in the extractive industries 
because they are subject to additional CbCr requirements.  After excluding firms with missing data required to calculate the regression variables, the final sample
 consists of 5,312 EU-headquartered multinationals (57,131 firm year-ends). 

 bysort BvDIDnumber:gen dup = cond(_N==1,0,_n)
drop if dup>1

reshape long varlist, i( BvDIDnumber) j(Year)
drop if misisng( BvDIDnumber)

tab Conscode
drop if Conscode=="U2"


*****************************************************************************
*Step 2:Download information on STR using OECD's tax database 
*https://www.oecd.org/tax/tax-policy/tax-database/



******************************************************************************
*Step 3: Download information on cash taxes paid from Compustat


******************************************************************************
*Step 4: Merge primary dataset from Orbis with the STR dataset using Country and Year as identifiers
merge m:m Year country using "C:\Users\STR Only.dta"
drop if misisng( BvDIDnumber)

***********************************************************************************************************************************************************
*Step 5: Merge primary dataset from Orbis with the Compustat dataset using ISIN number and Year as identifiers
merge m:m ISIN Year using "C:\Users\CETR.dta"
drop if misisng( BvDIDnumber)

***********************************************************************************************************************************************************

*Step 6: Compare the pre-tax income and total assets in the matched sample from step 5 and exclude any observations with discrepency
gen Match=0
replace Match=1 if PTI==PTI_CETR
gen Match1=0
replace Match1=1 if TA==TA_CETR

*****************************************************************************

*Step 7: Create the dependant and independant variables used in the study



gen ETR=TaxationmEUR/PLbeforetaxmEUR
gen MissingETR=0
replace MissingETR=1 if missing(ETR)
gen ETR_R=ETR
replace ETR_R=1 if ETR>1 & MissingETR==0
replace ETR_R=0 if ETR<0 & MissingETR==0

gen ETR_T=ETR
replace ETR_T=. if ETR>1 & MissingETR==0
replace ETR_T=. if ETR<0 & MissingETR==0

gen TaxDiff_R=ETR_R-STR
gen TaxDiff_T=ETR_T-STR

gen CETR=CashTaxPaid/PLbeforetaxmEUR
gen MissingCETR=0
replace MissingCETR=1 if missing(CETR)
gen CETR_R=CETR
replace CETR_R=1 if CETR>1 & MissingCETR==0
replace CETR_R=0 if CETR<0 & MissingCETR==0

gen CETR_T=ETR
replace CETR_T=. if CETR>1 & MissingCETR==0
replace CETR_T=. if CETR<0 & MissingCETR==0


gen ROA= NetIncome/ Totalassets if NetIncome>=0
replace ROA=. if ROA<0

gen Size=log( Totalassets) if Totalassets>0

gen Leverage=( TotalEquityLiab-ShareholdersfundsmEUR)/ Totalassets if Totalassets>0

gen Intang=log( Intangibles) if Intangibles>0

gen R&D= RD/ Totalassets if Totalassets>0

gen Innovation=( Numberofpatents+ Numberoftrademarks)/Totalassets if Totalassets>0



gen POST=1 if Year>2015
replace POST=0 if Year<2016

gen CETR=CashTaxes_CETR_w/PTI_CETR_w
gen MissingCETR=0
replace MissingCETR=1 if missing(CETR)

gen CETR_R=CETR
replace CETR_R=1 if CETR>1 & MissingCETR==0
replace CETR_R=0 if CETR<0 & MissingCETR==0

gen CETR_T=CETR
replace CETR_T=. if CETR>1 & MissingCETR==0
replace CETR_T=. if CETR<0 & MissingCETR==0


sort BvDIDnumber Year
by BvDIDnumber: egen PYRevenue=Revenue[_n-1]
gen CBCR=0
replace CBCR=1 if PYRevenue>=750 
replace CBCR=. if Year<2016
by BvDIDnumber: egen MaxCBCR=max(CBCR)
by BvDIDnumber: egen MinCBCR=min(CBCR)
gen Equals=1 if MaxCBCR==MinCBCR
rename CBCR CBCRPOST2015
rename MaxCBCR CBCR if Equals==1
gen CBCR_POST=CBCR*POST

gen EUHQ=0
replace EUHQ=1 if HQLocatedEU=1 
*HQLocatedEU is 1 if the headquarer of the company is located in one of the 21 EU member states
*****************************************************************************

*Step 8: Conduct empirical analyses (below I provide the codes for the base specifications used to estimate the results reported in tables 4-7 in the paper)

*Table 4 (t test)
ttest ETR_R if Year>2015, by(CBCR)
ttest ETR_R, by(BW1_250) 
ttest ETR_R, by(BW1_450) 
ttest ETR_R, by(BW1_550) 

ttest CETR_R if Year>2015, by(CBCR)
ttest CETR_R, by(BW1_250) 
ttest CETR_R, by(BW1_450) 
ttest CETR_R, by(BW1_550) 

ttest TaxDiff_R if Year>2015, by(CBCR)
ttest TaxDiff_R, by(BW1_250) 
ttest TaxDiff_R, by(BW1_450) 
ttest TaxDiff_R, by(BW1_550) 

ttest STR if Year>2015, by(CBCR)
ttest STR, by(BW1_250) 
ttest STR, by(BW1_450) 
ttest STR, by(BW1_550) 

*Table 5 (RDD Base Model)
eststo clear
eststo: rdrobust ETR_R PYRevenue if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust ETR_R PYRevenue if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
eststo: rdrobust TaxDiff_R PYRevenue  if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust TaxDiff_R PYRevenue  if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
eststo: rdrobust CETR_R PYRevenue  if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust CETR_R PYRevenue  if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
esttab using ResultTable5.csv, ar2  p star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*Table 6 (DID Base Model) 
eststo: reghdfe ETR_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe TaxDiff_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe CETR_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
esttab using ResultTable6.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*** Steps for downloading raw data, collating data and creating dependant and independant variables for the primary income shifting tests reported in tables 8***

*Step 1: Start with the BVDId number of primary sample  used for the tax avoidance test. Following the data selection criteria's specified in sections 3.0 and 3.1 
*as well as in Table 1 in the paper, download financial information on the majority owned affiliates via Orbis
*Step 2: Merge CBCR indicator (as this indicator is calculated at the parent level) and other parent level variables with the affiliate dataset using the parent BVDID number
*Step 3: Create the dependant and independant variables used in the study
*Step 4: Conduct empirical analyses

******************************************************************************

*Step 1: Star with the BVDId number of primary sample  used for the tax avoidance test. Following the data selection criteria's specified in sections 3.0 and 3.1 

reshape long varlist , i( BvDIDnumber) j(Year)
drop if missing(BvDIDnumber)
******************************************************************************

*Step 2: Merge CBCR indicator (as this indicator is calculated at the parnet level) and other parent level variables with the affiliate dataset using the parent BVDID number

merge m:m GUOBvDIDnumber Year using "C:\Users\ParentData.dta"
drop if misisng( BvDIDnumber)

******************************************************************************
*Step 3: Create the dependant and independant variables used in the study


Calculation of C (Tax Incentive Variable)
*Though the formula to calculate C is not propriteary, the code developed is propriertary. As such instead of providing the code, I am providing a detail desciption of
*how C is calculated in section 7.0 of the paper. C is the weighted-average statutory tax rate faced by an affilaite and is calculated using the STR of all affiliates
*in thc corporate group as well as scale of firms' operations in the country. C is calculated using affiliate revenue as the measure of scale and alternate C is calculated
*using total assets.C is increasing in the tax burden faced by a firm’s affiliate relative to all other affiliates in the same year.  
 
gen missingC=1 if C==.
egen meanmissingC = mean( missingC), by(GUOBvDIDnumber Year)
egen totalmissingC = sum( missingC), by(GUOBvDIDnumber Year)
egen totalaffiliate = count( BvDIDnumber ), by(GUOBvDIDnumber Year)
gen dummy_affiliate=1
egen totalaffilliate = sum( dummy_affiliate ), by(GUOBvDIDnumber Year)
gen perctmissing= totalmissingC/ totalaffilliate

gen LogPTI=log( PTI) if PTI>=0
replace LogPTI=. if missing(PTI)
gen LogFA=log(Tangiblefixedassets) if Tangiblefixedassets>=0
replace LogFA=. if missing(Tangiblefixedassets)
gen LogGDP=log(GDP) if GDP>=0
gen LogComp=log(EmployeesCost) if EmployeesCost>0
gen LogEmp=log(Employees) if Employees>0
egen Firm=group(BvDIDnumber)
egen Industry=group(NACERev2Corecode4digits)
egen Parent=group(GUOBvDIDnumber)

gen POST=1 if Year>2015
replace POST=0 if Year<2016

*CBCR is determined at the parent level

gen POST_CBCR=POST*CBCR
gen C_POST=C*POST
gen C_POST_CBCR=C*POST*CBCR

******************************************************************************
*Step 4: Conduct empirical analyses

*Base Model used to estimate the results reported in table 8
eststo clear
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  , absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if perctmissingC<0.3 ,  absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC<.2 ,  absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC<.1 , absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC==0 ,  absorb(Parent Year) cluster (Parent)
esttab using ResultTable8-1.csv,  ar2 se star(* 0.1 ** 0.05 *** 0.01)

*Base Model modified by including control variables and different fixed effects

******************************************************************************

*Codes for constructing variables used in the additional analyses 

*Table 7 (Panel A)
gen Year2013=0
replace Year2013=1 if Year==2013
gen CBCR_Year2013=CBCR*Year2013
gen Year2014=0
replace Year2014=1 if Year==2014
gen CBCR_Year2014=CBCR*Year2014
gen Year2015=0
replace Year2015=1 if Year==2015
gen CBCR_Year2015=CBCR*Year2015
gen Year2016=0
replace Year2016=1 if Year==2016
gen CBCR_Year2016=CBCR*Year2016
gen Year2017=0
replace Year2017=1 if Year==2017
gen CBCR_Year2017=CBCR*Year2017
gen Year2018=0
replace Year2018=1 if Year==2018
gen CBCR_Year2018=CBCR*Year2018

eststo: reghdfe ETR_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)
eststo: reghdfe TaxDiff_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe CETR_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)    
esttab using ResultTable7PanelA.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*Table 7 (Panel B)
eststo clear 
eststo: reghdfe ETR_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe ETR_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm) 
eststo: reghdfe TaxDiff_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe TaxDiff_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe CETR_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe CETR_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm)
esttab using ResultTable7PanelB.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects


******************************************************************************

***Journal of Accounting Research****
***Does Private Country by Country Reporting Deter Tax Avoidance & Income Shifting? Evidence from BEPS Action Item 13***
*** Joshi (2020)***

*** Steps for downloading raw data, collating data and creating dependant and independant variables for the primary tax avoidance tests reported in tables 4-7***

*Step 1: Download data from Orbis using the data selection criteria's specified in sections 3.0 and 3.1 as well as in Table 1 of the paper
*Step 2: Download information on STR using OECD's tax database 
*Step 3: Download information on cash taxes paid from Compustat
*Step 4: Merge primary dataset from Orbis with the STR dataset using Country and Year as identifiers
*Step 5: Merge primary dataset from Orbis with the Compustat dataset using ISIN number and Year as identifiers
*Step 6: Compare the pre-tax income and total assets in the matched sample from step 5 and exclude any observations with discrepency
*Step 7: Create the dependant and independant variables used in the study
*Step 8: Conduct empirical analyses

******************************************************************************
*Step 1: Step 1: Download data from Orbis using the data selection criteria's specified in sections 3.0 and 3.1 as well as in Table 1 of the paper
The primary sample in the study consists of EU MNCs. I restrict the sample to EU MNCs because CbCr was effective in EU member states on the same date (January 1, 2016). 
In addition, the tax and legal environments in EU nations are comparable across jurisdictions, and there is better availability of affiliate-level data through 
databases compiled by Bureau van Dijk. I obtain annual financial statements and ownership data for the years 2010 to 2018 from the Orbis database (Bureau van Dijk). 
In the EU, a primary reporting obligation under CbCr arises when, in a multinational group, either the ultimate parent or a member of the group is resident in 
a member state. CbCr requirements for resident and nonresident EU firms when the parent entity is headquartered outside an EU member state depends on whether 
the parent jurisdiction has adopted the rules and on the exchange relationship between parent home country and EU member states. I therefore restrict my primary 
sample to EU headquartered firms and, in an additional analysis (section 8.3), include nonresident EU firms. I start with EU-headquartered firms that are identified 
as global ultimate owners in the Orbis database and that have at least one foreign subsidiary. I exclude financial institutions and firms in the extractive industries 
because they are subject to additional CbCr requirements.  After excluding firms with missing data required to calculate the regression variables, the final sample
 consists of 5,312 EU-headquartered multinationals (57,131 firm year-ends). 

 bysort BvDIDnumber:gen dup = cond(_N==1,0,_n)
drop if dup>1

reshape long varlist, i( BvDIDnumber) j(Year)
drop if misisng( BvDIDnumber)

tab Conscode
drop if Conscode=="U2"


*****************************************************************************
*Step 2:Download information on STR using OECD's tax database 
*https://www.oecd.org/tax/tax-policy/tax-database/



******************************************************************************
*Step 3: Download information on cash taxes paid from Compustat


******************************************************************************
*Step 4: Merge primary dataset from Orbis with the STR dataset using Country and Year as identifiers
merge m:m Year country using "C:\Users\STR Only.dta"
drop if misisng( BvDIDnumber)

***********************************************************************************************************************************************************
*Step 5: Merge primary dataset from Orbis with the Compustat dataset using ISIN number and Year as identifiers
merge m:m ISIN Year using "C:\Users\CETR.dta"
drop if misisng( BvDIDnumber)

***********************************************************************************************************************************************************

*Step 6: Compare the pre-tax income and total assets in the matched sample from step 5 and exclude any observations with discrepency
gen Match=0
replace Match=1 if PTI==PTI_CETR
gen Match1=0
replace Match1=1 if TA==TA_CETR

*****************************************************************************

*Step 7: Create the dependant and independant variables used in the study



gen ETR=TaxationmEUR/PLbeforetaxmEUR
gen MissingETR=0
replace MissingETR=1 if missing(ETR)
gen ETR_R=ETR
replace ETR_R=1 if ETR>1 & MissingETR==0
replace ETR_R=0 if ETR<0 & MissingETR==0

gen ETR_T=ETR
replace ETR_T=. if ETR>1 & MissingETR==0
replace ETR_T=. if ETR<0 & MissingETR==0

gen TaxDiff_R=ETR_R-STR
gen TaxDiff_T=ETR_T-STR

gen CETR=CashTaxPaid/PLbeforetaxmEUR
gen MissingCETR=0
replace MissingCETR=1 if missing(CETR)
gen CETR_R=CETR
replace CETR_R=1 if CETR>1 & MissingCETR==0
replace CETR_R=0 if CETR<0 & MissingCETR==0

gen CETR_T=ETR
replace CETR_T=. if CETR>1 & MissingCETR==0
replace CETR_T=. if CETR<0 & MissingCETR==0


gen ROA= NetIncome/ Totalassets if NetIncome>=0
replace ROA=. if ROA<0

gen Size=log( Totalassets) if Totalassets>0

gen Leverage=( TotalEquityLiab-ShareholdersfundsmEUR)/ Totalassets if Totalassets>0

gen Intang=log( Intangibles) if Intangibles>0

gen R&D= RD/ Totalassets if Totalassets>0

gen Innovation=( Numberofpatents+ Numberoftrademarks)/Totalassets if Totalassets>0



gen POST=1 if Year>2015
replace POST=0 if Year<2016

gen CETR=CashTaxes_CETR_w/PTI_CETR_w
gen MissingCETR=0
replace MissingCETR=1 if missing(CETR)

gen CETR_R=CETR
replace CETR_R=1 if CETR>1 & MissingCETR==0
replace CETR_R=0 if CETR<0 & MissingCETR==0

gen CETR_T=CETR
replace CETR_T=. if CETR>1 & MissingCETR==0
replace CETR_T=. if CETR<0 & MissingCETR==0


sort BvDIDnumber Year
by BvDIDnumber: egen PYRevenue=Revenue[_n-1]
gen CBCR=0
replace CBCR=1 if PYRevenue>=750 
replace CBCR=. if Year<2016
by BvDIDnumber: egen MaxCBCR=max(CBCR)
by BvDIDnumber: egen MinCBCR=min(CBCR)
gen Equals=1 if MaxCBCR==MinCBCR
rename CBCR CBCRPOST2015
rename MaxCBCR CBCR if Equals==1
gen CBCR_POST=CBCR*POST

gen EUHQ=0
replace EUHQ=1 if HQLocatedEU=1 
*HQLocatedEU is 1 if the headquarer of the company is located in one of the 21 EU member states
*****************************************************************************

*Step 8: Conduct empirical analyses (below I provide the codes for the base specifications used to estimate the results reported in tables 4-7 in the paper)

*Table 4 (t test)
ttest ETR_R if Year>2015, by(CBCR)
ttest ETR_R, by(BW1_250) 
ttest ETR_R, by(BW1_450) 
ttest ETR_R, by(BW1_550) 

ttest CETR_R if Year>2015, by(CBCR)
ttest CETR_R, by(BW1_250) 
ttest CETR_R, by(BW1_450) 
ttest CETR_R, by(BW1_550) 

ttest TaxDiff_R if Year>2015, by(CBCR)
ttest TaxDiff_R, by(BW1_250) 
ttest TaxDiff_R, by(BW1_450) 
ttest TaxDiff_R, by(BW1_550) 

ttest STR if Year>2015, by(CBCR)
ttest STR, by(BW1_250) 
ttest STR, by(BW1_450) 
ttest STR, by(BW1_550) 

*Table 5 (RDD Base Model)
eststo clear
eststo: rdrobust ETR_R PYRevenue if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust ETR_R PYRevenue if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
eststo: rdrobust TaxDiff_R PYRevenue  if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust TaxDiff_R PYRevenue  if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
eststo: rdrobust CETR_R PYRevenue  if PYRevenue>0  & Year<2016 & EUHQ==1,  c(750)all
eststo: rdrobust CETR_R PYRevenue  if PYRevenue>0  & Year>2015 & EUHQ==1,  c(750)all
esttab using ResultTable5.csv, ar2  p star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*Table 6 (DID Base Model) 
eststo: reghdfe ETR_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe TaxDiff_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe CETR_R CBCR POST CBCR_POST if EUHQ==1, absorb (Firm Year) cluster(Firm)  
esttab using ResultTable6.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*** Steps for downloading raw data, collating data and creating dependant and independant variables for the primary income shifting tests reported in tables 8***

*Step 1: Start with the BVDId number of primary sample  used for the tax avoidance test. Following the data selection criteria's specified in sections 3.0 and 3.1 
*as well as in Table 1 in the paper, download financial information on the majority owned affiliates via Orbis
*Step 2: Merge CBCR indicator (as this indicator is calculated at the parent level) and other parent level variables with the affiliate dataset using the parent BVDID number
*Step 3: Create the dependant and independant variables used in the study
*Step 4: Conduct empirical analyses

******************************************************************************

*Step 1: Star with the BVDId number of primary sample  used for the tax avoidance test. Following the data selection criteria's specified in sections 3.0 and 3.1 

reshape long varlist , i( BvDIDnumber) j(Year)
drop if missing(BvDIDnumber)
******************************************************************************

*Step 2: Merge CBCR indicator (as this indicator is calculated at the parnet level) and other parent level variables with the affiliate dataset using the parent BVDID number

merge m:m GUOBvDIDnumber Year using "C:\Users\ParentData.dta"
drop if misisng( BvDIDnumber)

******************************************************************************
*Step 3: Create the dependant and independant variables used in the study


Calculation of C (Tax Incentive Variable)
*Though the formula to calculate C is not propriteary, the code developed is propriertary. As such instead of providing the code, I am providing a detail desciption of
*how C is calculated in section 7.0 of the paper. C is the weighted-average statutory tax rate faced by an affilaite and is calculated using the STR of all affiliates
*in thc corporate group as well as scale of firms' operations in the country. C is calculated using affiliate revenue as the measure of scale and alternate C is calculated
*using total assets.C is increasing in the tax burden faced by a firm’s affiliate relative to all other affiliates in the same year.  
 
gen missingC=1 if C==.
egen meanmissingC = mean( missingC), by(GUOBvDIDnumber Year)
egen totalmissingC = sum( missingC), by(GUOBvDIDnumber Year)
egen totalaffiliate = count( BvDIDnumber ), by(GUOBvDIDnumber Year)
gen dummy_affiliate=1
egen totalaffilliate = sum( dummy_affiliate ), by(GUOBvDIDnumber Year)
gen perctmissing= totalmissingC/ totalaffilliate

gen LogPTI=log( PTI) if PTI>=0
replace LogPTI=. if missing(PTI)
gen LogFA=log(Tangiblefixedassets) if Tangiblefixedassets>=0
replace LogFA=. if missing(Tangiblefixedassets)
gen LogGDP=log(GDP) if GDP>=0
gen LogComp=log(EmployeesCost) if EmployeesCost>0
gen LogEmp=log(Employees) if Employees>0
egen Firm=group(BvDIDnumber)
egen Industry=group(NACERev2Corecode4digits)
egen Parent=group(GUOBvDIDnumber)

gen POST=1 if Year>2015
replace POST=0 if Year<2016

*CBCR is determined at the parent level

gen POST_CBCR=POST*CBCR
gen C_POST=C*POST
gen C_POST_CBCR=C*POST*CBCR

******************************************************************************
*Step 4: Conduct empirical analyses

*Base Model used to estimate the results reported in table 8
eststo clear
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  , absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if perctmissingC<0.3 ,  absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC<.2 ,  absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC<.1 , absorb(Parent Year) cluster (Parent)
eststo: reghdfe LogPTI C CBCR POST CBCR_POST  C_CBCR C_POST C_CBCR_POST LogFA LogComp LogGDP  if  perctmissingC==0 ,  absorb(Parent Year) cluster (Parent)
esttab using ResultTable8-1.csv,  ar2 se star(* 0.1 ** 0.05 *** 0.01)

*Base Model modified by including control variables and different fixed effects

******************************************************************************

*Codes for constructing variables used in the additional analyses 

*Table 7 (Panel A)
gen Year2013=0
replace Year2013=1 if Year==2013
gen CBCR_Year2013=CBCR*Year2013
gen Year2014=0
replace Year2014=1 if Year==2014
gen CBCR_Year2014=CBCR*Year2014
gen Year2015=0
replace Year2015=1 if Year==2015
gen CBCR_Year2015=CBCR*Year2015
gen Year2016=0
replace Year2016=1 if Year==2016
gen CBCR_Year2016=CBCR*Year2016
gen Year2017=0
replace Year2017=1 if Year==2017
gen CBCR_Year2017=CBCR*Year2017
gen Year2018=0
replace Year2018=1 if Year==2018
gen CBCR_Year2018=CBCR*Year2018

eststo: reghdfe ETR_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)
eststo: reghdfe TaxDiff_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)  
eststo: reghdfe CETR_R CBCR Year2013 Year2014 Year2015 Year2016 Year2017 Year2018 CBCR_Year2013 CBCR_Year2014 CBCR_Year2015 CBCR_Year2016 CBCR_Year2017 CBCR_Year2018 if EUHQ==1, absorb (Firm Year) cluster(Firm)    
esttab using ResultTable7PanelA.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects

*Table 7 (Panel B)
eststo clear 
eststo: reghdfe ETR_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe ETR_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm) 
eststo: reghdfe TaxDiff_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe TaxDiff_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe CETR_R POST if CBCR==1 &  EUHQ==1, absorb (Firm) cluster(Firm)  
eststo: reghdfe CETR_R POST if CBCR==0 &  EUHQ==1, absorb (Firm) cluster(Firm)
esttab using ResultTable7PanelB.csv, ar2  se star(* 0.1 ** 0.05 *** 0.01)
*Base Model modified by including control variables and different fixed effects


******************************************************************************

