***********************************************************************************************
********** create Foreign Leniency measure ***********************************************
***********************************************************************************************
cd "~"
use xm_sic87_72_105_20120424.dta, clear /*US SIC87-level imports and exports (1972-2005), https://sompks4.github.io/sub_data.html*/
replace wbcode="ROU" if wbcode=="ROM"
drop if vship==.
keep if year==1990 /*we use the import/export data in 1990 to calculate weights*/
rename wbcode fic
tostring sic, replace
g sic_2digits=substr(sic,1,2) 
preserve
keep sic_2digit sic vship /*vship is at the SIC level*/
duplicates drop
bys sic_2digit: egen totalvship=total(vship) /*aggregate vship to two digit SIC industry level*/
keep sic_2 totalvship
duplicates drop
sort sic_2
save temp.dta, replace
restore
**create weight
bys sic_2digit: egen totalimports=total(customs) /*industry level imports*/
bys sic_2digit: egen totalexports=total(x) /*industry level exports*/
bys fic sic_2digit: egen imports=total(customs) /*imports from country fic to the industry*/
keep fic sic_2digit totalimports totalexports imports
duplicates drop
sort sic_2
merge sic_2 using temp.dta, uniqusing nokeep
g imp= imports/( totalvship+ totalimports-totalexports)
bys fic sic_2digit: egen tot_imp=total(imp) /*the share of imports from country fic to the industry*/
drop imp _m
duplicates drop
sort fic sic_2digit
save temp.dta, replace
keep sic_2digit
duplicates drop
save temp2.dta, replace

use "country level.dta", clear 
/*country level.dta is a fic-year panel. 
Three variable: fic, year, leniency law. 
"leniency law" equals one if the country (fic) has adopted the law, following 
Internet Appendix A2 */
keep fic year leniencylaw
cross using temp2.dta
sort fic sic_2digit
merge fic sic_2digit using temp.dta, uniqusing nokeep
drop _m
g w_tot_imp=leniencylaw*tot_imp
bys sic_2digit year: egen global_imports=total(w_tot_imp)
keep sic_2digit year global
duplicates drop
sort sic_2digit year
save global_import_2d.dta, replace


 
***********************************************************************************************
*****Construct sample for industry-level analysis Table 1 Panel A & B *******************
***********************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
****1. Sample for Table 1, Panel A: Industry-level Cartel Convictions
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
use "global_import_2d",clear
preserve 
use "cartels by industry",clear 
/*proprietary data purchased from Dr. John M. Connor. We name-matched cartels to SIC industries.
For each SIC2 industry we compute the number of convicted cartels (total_cartels) and firms (total_convict)*/
keep if year>=1994 
tempfile x
keep total_cartels total_convict sic_2digits year
save `x',replace
restore
merge 1:1 sic_2digits year using `x',keep(1 3) nogen 
keep if year>=1994
replace total_cartels=0 if total_cartels==.
replace total_convict=0 if total_convict==.
destring sic_2digits,g(sic2)
g lnnum=ln(1+total_cartels)
g lnnum2=ln(1+total_convict)
label var lnnum "Log number of convicted cartels in the industry"
label var lnnum "Log number of convicted firms in the industry"
xtset sic2 year  
save Table1_PanelA.dta,replace

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
****2. Sample for Table 1, Panel B: Industry-level PPI
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 /*We get the PPI data from the Bureau of Labor Statistics (https://www.bls.gov/ppi/data.htm). 
 We conduct the test at NAICS industry level, because the PPI data for SIC industry discontinued in 2003. 
 The PPI data for NAICS industry is available after 1998. We conduct the test at six-digit NAICS industry level, 
 because the crosswalk files from NAICS code to SIC code is at the six-digit NAICS industry level (http://www.ddorn.net/data.htm). */ 
 
import delimited pc.data.0.Current.txt, clear

keep  if strmatch(ser,"*-*")~=1 /*remove coarser industries, e.g., 3-digit NAICS*/
  
bys series_id year:egen PPI=mean(value) /*the data is at the monthly level. We convert it to annually*/

duplicates drop series_id year,force

***keep (and generate) 6-digit NAICS codes
drop  if  strmatch(ser,"*A*")==1
drop  if  strmatch(ser,"*M*")==1 
replace series_id=subinstr(series_id, "PCU", "", .)
replace series_id=subinstr(series_id, " ", "", .)
replace series_id=subinstr(series_id, "--", "-", .)
g length=length(series_id)
tab length
keep if length==12
keep if year<=2012
g naics6=substr(ser,1,6)
drop if regexm(naics6,"[A-Z]")

destring naics6,replace

keep naics6 year PPI
order naics6 year PPI 

save PPI_NAICS,replace

**Next, cross-walk from NAICS to SIC2 , in order to mege with the treatment measures
set more off
forvalues i=1998/2012{ 
use PPI_NAICS , clear
keep if year==`i'
merge 1:m naics6 using cw_n97_s87\cw_n97_s87,keep(3) nogen /*http://www.ddorn.net/data.htm*/
tempfile `i'
save ``i'',replace
	if `i'>1998 {
	local j=`i'-1
	append using ``j''
	save ``i'',replace
	} 
} 

g sic2=int(sic4/100)
tostring sic2,g(sic_2digits) 
 
replace PPI=PPI/100 
 
**obtain the treatment variables 
drop _merge
merge m:1 sic_2digits year using "global_import_2d"
keep if _merge==3
drop _merge

/* If there are multiple SIC industries mapping to a NAICS industry, We estimate the value of the independent variable as the weight 
 average of the value in each SIC industry, where the weight is the share of a NAICS industry¡¯s 1997 employment that maps to the 
 SIC industry. */
foreach var of varlist global_imports    {
bys naics6 year:egen wt_`var'= wtmean(`var'),weight(weight) 
}

duplicates drop naics6 year,force
   
save Table1_PanelB_PPI.dta,replace




***********************************************************************************************
**********  Construct sample for firm-level analysis (Main)     ******************************
*********************************************************************************************** 
**Sample Construction 
use "Compustat_1990_2015.dta", clear

*** apply filters ***
drop if curcd!="USD"
keep if (indfmt=="INDL") & (datafmt=="STD") & (popsrc=="D") & (consol=="C") 
keep if fic =="USA"  /* eliminate non-us incorporated firms as they might be directly affected by foreign leniency laws*/
gen sic3 = substr(sic, 1, 3)
gen sic2 = substr(sic, 1, 2)
destring sic, replace
destring sic3, replace 
destring sic2, replace
drop if sic  >= 6000 & sic <= 6999   /* eliminate financials */
drop if sic  >= 4900 & sic <= 4999   /* eliminate utilities */
keep if gvkey!=""  /* eliminate missing gvkeys */
destring cik, replace 
keep if fyear!=. /* eliminate missing fiscal year */
keep if datadate~=. /* eliminates missing date of financials */
keep if at~=.   /* eliminates if total assets missing */
keep if at>0   /* eliminates if total assets negative */
keep if at>=0.5 /*eliminate micro firms*/
drop if sale<0  /*eliminate firm with negative revenue*/
gsort gvkey fyear -datadate
duplicates drop gvkey fyear, force /*check duplicates, 0 duplicates*/
*Correcting for non-standard fiscal year ends
replace fyr=. if fyr==0 /*0 case*/
g year=fyear /*use fiscal year to merge with other dataset*/

*** correct SIC codes ending with 0 or 9 Bustanmante and Donangelo (2017) ***
*** i.e., replace these SIC codes ending with 0 or 9 with the SIC of the primary segment     ***  
merge 1:1 gvkey datadate using "$draft3/sic_from_segment",keepus(sics1) keep(1 3) nogen
replace sic=sics1 if  int(sic/100)==int(sics1/100) & (mod(sic,10)==0|mod(sic,10)==9)&sics1~=.
drop sics1

*** Merging with Import Penetrating Data *** 
* The measure is at the four-digit SIC industry level. Value after 2005 is set to the value in 2005 
*data is from https://sompks4.github.io/sub_data.html. The value is cif/(cif+vship-x) 
merge m:1 sic  year using "import_penetrate",keep(1 3) nogen
 
*** Create Market Concentration Measures, Compustat HHI
hhi sale, by(sic2 year)
rename hhi_sale hh_index
  
destring gvkey, replace 
xtset gvkey fyear
 
*** Create control variable, lagged-one-period
gen size = log(l.at)
gen roa = ib / l.at
gen lroa=l.roa 
gen lat = l.at
gen ldltt=l.dltt
gen ldlc=l.dlc
 
*** Merging with Treatment variable  
sort gvkey year 
g sic_2digits = sic2
tostring sic_2digits,replace
merge m:1 sic_2digits year using "global_import_2d.dta", nogen keep(3)   

*** Disclosure Measures *** 
*1. Supplier contracts 
	merge 1:1 gvkey year using "$draft3/redact_supplier_June2017",keep(1 3) nogen  
*2. Conference Call data ****
	sort gvkey fyear 
	tostring gvkey,replace
	replace gvkey="00000"+gvkey if length(gvkey)==1
	replace gvkey="0000"+gvkey if length(gvkey)==2
	replace gvkey="000"+gvkey if length(gvkey)==3
	replace gvkey="00"+gvkey if length(gvkey)==4
	replace gvkey="0"+gvkey if length(gvkey)==5  
	merge 1:1 gvkey year using "words_conference",keep(1 3) nogen 
	
*** stock returns in the calendar year ***  
merge 1:1 gvkey  year using "$draft3/stockreturn",keep(1 3) nogen  
 

*** Eliminate observation with missing control variables ***
keep if  size~=. & hh_index~=. & import_penetrate~=. & lroa~=.
keep if  year>=1994 

** Variable construction, winsorize, etc.
destring gvkey,replace
** Gross Margins
cap drop profit_margin 
g profit_margin=(sale-cogs)/sale 
replace profit_margin=-1 if profit_margin<=-1   
/*we winsorize the gross margin between -1 and 1*/
/*otherwise there would be lots of extreme value*/ 
 
** Winsorize control variables at 1% and 99%
winsor2    lroa size hhi_ import_penetrate bhar_size,cut(1 99) replace  
  
*****Merge variables for cross-sectional tests 
***1. Census HHI  
**Merge with HHI Census 
g naics_4digit=substr(naicsh,1,4)
destring naics_4digit,replace 
g census_yr=cond(fyear<=1997,1997,cond(fyear<=2002,2002,cond(fyear<=2007,2007,2012))) 
cap drop _merge
merge m:1 naics_4digit census_yr using "hhi_census"
drop if _merge==2
drop _merge  

***2. Product Heterogeneity
preserve
import delimited tnic3_allyears_extend_scores.txt,clear
drop if gvkey1==gvkey2
qui sum score,de
g high=(score>= r(p75))
bys gvkey1 year:egen similar=sum(high)  /*number of peers with high similrity*/
g gvkey=gvkey1
keep gvkey year similar
duplicates drop gvkey fyear,force 
save similar,replace 
restore
cap drop _merge
cap drop similar   
merge m:1 gvkey year using similar,keep(1 3) nogen
***3. Entry cost, patents
**see the code 3additional variable construction.sas on variable construction
merge m:1 sic2 year  using "$draft3/patent_industry_level",keep(1 3) nogen  
 
***4. growth ver sus mature
cap drop _merge 
merge m:1 sic2 fyear using  "$draft3/indgrowth" ,keep(1 3) nogen  

***5. probability of conviction 
merge 1:1 gvkey year using  cartel_convict,keep(1 3) 
/*cartel_convict.dta indicates firm-years that are convicted*/
g convict=(_merge==3)
drop if _merge==2
drop _merge 
replace dltt=0 if dltt==.
replace dlc=0 if dlc==.
g lleverage = (ldltt+ldlc)/lat
winsor2 lleverage ,cut(1 99) replace  
probit convict size  lroa lleverage  if fyear<=1999  ,asis  
predict pconvict    , pr 
destring gvkey,replace  

***6. recent conviction of industry peers
preserve
use "$draft3/Compustat_1990_2015.dta", clear 
*** apply filters *** 
keep if (indfmt=="INDL") & (datafmt=="STD") & (popsrc=="D") & (consol=="C")  
destring gvkey,replace
g year= fyear
merge 1:1 gvkey year using cartel_convict,keep(3)   /*keep firm-years with convictions*/
g sic2=substr(sic,1,2)
destring sic2,replace
duplicates drop sic2 fyear,force /*identify industry-years with convictions*/
keep sic2 fyear
rename fyear tmpyear
tempfile x
save `x',replace
restore
forvalues i = 0/3 {
cap drop tmpyear
cap drop recent`i'
g tmpyear = year-`i'
cap drop _merge
merge m:1 sic2 tmpyear using `x',keep(1 3)
g recent`i'=(_merge==3)
} 
g RecentConviction =  recent1==1|recent2==1|recent3==1 

***7.  Num. Public Firm
**see the code 3additional variable construction.sas on variable construction
g naics_3digit=substr(naicsh,1,3)
merge m:1 naics_3digit  year using "$draft3\pctpublicfirm3d_s",keep(1 3) nogen

***8. bertrand versus cournot
**see the code 3additional variable construction.sas on variable construction
tostring sic3 ,replace 
cap drop _merge
merge m:1 sic3  year   using "$draft3\cournot",keep(1 3) nogen

save regress_sample.dta



***********************************************************************************************
********** create Foreign Leniency measure ***********************************************
***********************************************************************************************
cd "~"
use xm_sic87_72_105_20120424.dta, clear /*US SIC87-level imports and exports (1972-2005), https://sompks4.github.io/sub_data.html*/
replace wbcode="ROU" if wbcode=="ROM"
drop if vship==.
keep if year==1990 /*we use the import/export data in 1990 to calculate weights*/
rename wbcode fic
tostring sic, replace
g sic_2digits=substr(sic,1,2) 
preserve
keep sic_2digit sic vship /*vship is at the SIC level*/
duplicates drop
bys sic_2digit: egen totalvship=total(vship) /*aggregate vship to two digit SIC industry level*/
keep sic_2 totalvship
duplicates drop
sort sic_2
save temp.dta, replace
restore
**create weight
bys sic_2digit: egen totalimports=total(customs) /*industry level imports*/
bys sic_2digit: egen totalexports=total(x) /*industry level exports*/
bys fic sic_2digit: egen imports=total(customs) /*imports from country fic to the industry*/
keep fic sic_2digit totalimports totalexports imports
duplicates drop
sort sic_2
merge sic_2 using temp.dta, uniqusing nokeep
g imp= imports/( totalvship+ totalimports-totalexports)
bys fic sic_2digit: egen tot_imp=total(imp) /*the share of imports from country fic to the industry*/
drop imp _m
duplicates drop
sort fic sic_2digit
save temp.dta, replace
keep sic_2digit
duplicates drop
save temp2.dta, replace

use "country level.dta", clear 
/*country level.dta is a fic-year panel. 
Three variable: fic, year, leniency law. 
"leniency law" equals one if the country (fic) has adopted the law, following 
Internet Appendix A2 */
keep fic year leniencylaw
cross using temp2.dta
sort fic sic_2digit
merge fic sic_2digit using temp.dta, uniqusing nokeep
drop _m
g w_tot_imp=leniencylaw*tot_imp
bys sic_2digit year: egen global_imports=total(w_tot_imp)
keep sic_2digit year global
duplicates drop
sort sic_2digit year
save global_import_2d.dta, replace


 
***********************************************************************************************
*****Construct sample for industry-level analysis Table 1 Panel A & B *******************
***********************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
****1. Sample for Table 1, Panel A: Industry-level Cartel Convictions
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
use "global_import_2d",clear
preserve 
use "cartels by industry",clear 
/*proprietary data purchased from Dr. John M. Connor. We name-matched cartels to SIC industries.
For each SIC2 industry we compute the number of convicted cartels (total_cartels) and firms (total_convict)*/
keep if year>=1994 
tempfile x
keep total_cartels total_convict sic_2digits year
save `x',replace
restore
merge 1:1 sic_2digits year using `x',keep(1 3) nogen 
keep if year>=1994
replace total_cartels=0 if total_cartels==.
replace total_convict=0 if total_convict==.
destring sic_2digits,g(sic2)
g lnnum=ln(1+total_cartels)
g lnnum2=ln(1+total_convict)
label var lnnum "Log number of convicted cartels in the industry"
label var lnnum "Log number of convicted firms in the industry"
xtset sic2 year  
save Table1_PanelA.dta,replace

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
****2. Sample for Table 1, Panel B: Industry-level PPI
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 /*We get the PPI data from the Bureau of Labor Statistics (https://www.bls.gov/ppi/data.htm). 
 We conduct the test at NAICS industry level, because the PPI data for SIC industry discontinued in 2003. 
 The PPI data for NAICS industry is available after 1998. We conduct the test at six-digit NAICS industry level, 
 because the crosswalk files from NAICS code to SIC code is at the six-digit NAICS industry level (http://www.ddorn.net/data.htm). */ 
 
import delimited pc.data.0.Current.txt, clear

keep  if strmatch(ser,"*-*")~=1 /*remove coarser industries, e.g., 3-digit NAICS*/
  
bys series_id year:egen PPI=mean(value) /*the data is at the monthly level. We convert it to annually*/

duplicates drop series_id year,force

***keep (and generate) 6-digit NAICS codes
drop  if  strmatch(ser,"*A*")==1
drop  if  strmatch(ser,"*M*")==1 
replace series_id=subinstr(series_id, "PCU", "", .)
replace series_id=subinstr(series_id, " ", "", .)
replace series_id=subinstr(series_id, "--", "-", .)
g length=length(series_id)
tab length
keep if length==12
keep if year<=2012
g naics6=substr(ser,1,6)
drop if regexm(naics6,"[A-Z]")

destring naics6,replace

keep naics6 year PPI
order naics6 year PPI 

save PPI_NAICS,replace

**Next, cross-walk from NAICS to SIC2 , in order to mege with the treatment measures
set more off
forvalues i=1998/2012{ 
use PPI_NAICS , clear
keep if year==`i'
merge 1:m naics6 using cw_n97_s87\cw_n97_s87,keep(3) nogen /*http://www.ddorn.net/data.htm*/
tempfile `i'
save ``i'',replace
	if `i'>1998 {
	local j=`i'-1
	append using ``j''
	save ``i'',replace
	} 
} 

g sic2=int(sic4/100)
tostring sic2,g(sic_2digits) 
 
replace PPI=PPI/100 
 
**obtain the treatment variables 
drop _merge
merge m:1 sic_2digits year using "global_import_2d"
keep if _merge==3
drop _merge

/* If there are multiple SIC industries mapping to a NAICS industry, We estimate the value of the independent variable as the weight 
 average of the value in each SIC industry, where the weight is the share of a NAICS industry¡¯s 1997 employment that maps to the 
 SIC industry. */
foreach var of varlist global_imports    {
bys naics6 year:egen wt_`var'= wtmean(`var'),weight(weight) 
}

duplicates drop naics6 year,force
   
save Table1_PanelB_PPI.dta,replace




***********************************************************************************************
**********  Construct sample for firm-level analysis (Main)     ******************************
*********************************************************************************************** 
**Sample Construction 
use "Compustat_1990_2015.dta", clear

*** apply filters ***
drop if curcd!="USD"
keep if (indfmt=="INDL") & (datafmt=="STD") & (popsrc=="D") & (consol=="C") 
keep if fic =="USA"  /* eliminate non-us incorporated firms as they might be directly affected by foreign leniency laws*/
gen sic3 = substr(sic, 1, 3)
gen sic2 = substr(sic, 1, 2)
destring sic, replace
destring sic3, replace 
destring sic2, replace
drop if sic  >= 6000 & sic <= 6999   /* eliminate financials */
drop if sic  >= 4900 & sic <= 4999   /* eliminate utilities */
keep if gvkey!=""  /* eliminate missing gvkeys */
destring cik, replace 
keep if fyear!=. /* eliminate missing fiscal year */
keep if datadate~=. /* eliminates missing date of financials */
keep if at~=.   /* eliminates if total assets missing */
keep if at>0   /* eliminates if total assets negative */
keep if at>=0.5 /*eliminate micro firms*/
drop if sale<0  /*eliminate firm with negative revenue*/
gsort gvkey fyear -datadate
duplicates drop gvkey fyear, force /*check duplicates, 0 duplicates*/
*Correcting for non-standard fiscal year ends
replace fyr=. if fyr==0 /*0 case*/
g year=fyear /*use fiscal year to merge with other dataset*/

*** correct SIC codes ending with 0 or 9 Bustanmante and Donangelo (2017) ***
*** i.e., replace these SIC codes ending with 0 or 9 with the SIC of the primary segment     ***  
merge 1:1 gvkey datadate using "$draft3/sic_from_segment",keepus(sics1) keep(1 3) nogen
replace sic=sics1 if  int(sic/100)==int(sics1/100) & (mod(sic,10)==0|mod(sic,10)==9)&sics1~=.
drop sics1

*** Merging with Import Penetrating Data *** 
* The measure is at the four-digit SIC industry level. Value after 2005 is set to the value in 2005 
*data is from https://sompks4.github.io/sub_data.html. The value is cif/(cif+vship-x) 
merge m:1 sic  year using "import_penetrate",keep(1 3) nogen
 
*** Create Market Concentration Measures, Compustat HHI
hhi sale, by(sic2 year)
rename hhi_sale hh_index
  
destring gvkey, replace 
xtset gvkey fyear
 
*** Create control variable, lagged-one-period
gen size = log(l.at)
gen roa = ib / l.at
gen lroa=l.roa 
gen lat = l.at
gen ldltt=l.dltt
gen ldlc=l.dlc
 
*** Merging with Treatment variable  
sort gvkey year 
g sic_2digits = sic2
tostring sic_2digits,replace
merge m:1 sic_2digits year using "global_import_2d.dta", nogen keep(3)   

*** Disclosure Measures *** 
*1. Supplier contracts 
	merge 1:1 gvkey year using "$draft3/redact_supplier_June2017",keep(1 3) nogen  
*2. Conference Call data ****
	sort gvkey fyear 
	tostring gvkey,replace
	replace gvkey="00000"+gvkey if length(gvkey)==1
	replace gvkey="0000"+gvkey if length(gvkey)==2
	replace gvkey="000"+gvkey if length(gvkey)==3
	replace gvkey="00"+gvkey if length(gvkey)==4
	replace gvkey="0"+gvkey if length(gvkey)==5  
	merge 1:1 gvkey year using "words_conference",keep(1 3) nogen 
	
*** stock returns in the calendar year ***  
merge 1:1 gvkey  year using "$draft3/stockreturn",keep(1 3) nogen  
 

*** Eliminate observation with missing control variables ***
keep if  size~=. & hh_index~=. & import_penetrate~=. & lroa~=.
keep if  year>=1994 

** Variable construction, winsorize, etc.
destring gvkey,replace
** Gross Margins
cap drop profit_margin 
g profit_margin=(sale-cogs)/sale 
replace profit_margin=-1 if profit_margin<=-1   
/*we winsorize the gross margin between -1 and 1*/
/*otherwise there would be lots of extreme value*/ 
 
** Winsorize control variables at 1% and 99%
winsor2    lroa size hhi_ import_penetrate bhar_size,cut(1 99) replace  
  
*****Merge variables for cross-sectional tests 
***1. Census HHI  
**Merge with HHI Census 
g naics_4digit=substr(naicsh,1,4)
destring naics_4digit,replace 
g census_yr=cond(fyear<=1997,1997,cond(fyear<=2002,2002,cond(fyear<=2007,2007,2012))) 
cap drop _merge
merge m:1 naics_4digit census_yr using "hhi_census"
drop if _merge==2
drop _merge  

***2. Product Heterogeneity
preserve
import delimited tnic3_allyears_extend_scores.txt,clear
drop if gvkey1==gvkey2
qui sum score,de
g high=(score>= r(p75))
bys gvkey1 year:egen similar=sum(high)  /*number of peers with high similrity*/
g gvkey=gvkey1
keep gvkey year similar
duplicates drop gvkey fyear,force 
save similar,replace 
restore
cap drop _merge
cap drop similar   
merge m:1 gvkey year using similar,keep(1 3) nogen
***3. Entry cost, patents
**see the code 3additional variable construction.sas on variable construction
merge m:1 sic2 year  using "$draft3/patent_industry_level",keep(1 3) nogen  
 
***4. growth ver sus mature
cap drop _merge 
merge m:1 sic2 fyear using  "$draft3/indgrowth" ,keep(1 3) nogen  

***5. probability of conviction 
merge 1:1 gvkey year using  cartel_convict,keep(1 3) 
/*cartel_convict.dta indicates firm-years that are convicted*/
g convict=(_merge==3)
drop if _merge==2
drop _merge 
replace dltt=0 if dltt==.
replace dlc=0 if dlc==.
g lleverage = (ldltt+ldlc)/lat
winsor2 lleverage ,cut(1 99) replace  
probit convict size  lroa lleverage  if fyear<=1999  ,asis  
predict pconvict    , pr 
destring gvkey,replace  

***6. recent conviction of industry peers
preserve
use "$draft3/Compustat_1990_2015.dta", clear 
*** apply filters *** 
keep if (indfmt=="INDL") & (datafmt=="STD") & (popsrc=="D") & (consol=="C")  
destring gvkey,replace
g year= fyear
merge 1:1 gvkey year using cartel_convict,keep(3)   /*keep firm-years with convictions*/
g sic2=substr(sic,1,2)
destring sic2,replace
duplicates drop sic2 fyear,force /*identify industry-years with convictions*/
keep sic2 fyear
rename fyear tmpyear
tempfile x
save `x',replace
restore
forvalues i = 0/3 {
cap drop tmpyear
cap drop recent`i'
g tmpyear = year-`i'
cap drop _merge
merge m:1 sic2 tmpyear using `x',keep(1 3)
g recent`i'=(_merge==3)
} 
g RecentConviction =  recent1==1|recent2==1|recent3==1 

***7.  Num. Public Firm
**see the code 3additional variable construction.sas on variable construction
g naics_3digit=substr(naicsh,1,3)
merge m:1 naics_3digit  year using "$draft3\pctpublicfirm3d_s",keep(1 3) nogen

***8. bertrand versus cournot
**see the code 3additional variable construction.sas on variable construction
tostring sic3 ,replace 
cap drop _merge
merge m:1 sic3  year   using "$draft3\cournot",keep(1 3) nogen

save regress_sample.dta



***********************************************************************************************
********** create Foreign Leniency measure ***********************************************
***********************************************************************************************
cd "~"
use xm_sic87_72_105_20120424.dta, clear /*US SIC87-level imports and exports (1972-2005), https://sompks4.github.io/sub_data.html*/
replace wbcode="ROU" if wbcode=="ROM"
drop if vship==.
keep if year==1990 /*we use the import/export data in 1990 to calculate weights*/
rename wbcode fic
tostring sic, replace
g sic_2digits=substr(sic,1,2) 
preserve
keep sic_2digit sic vship /*vship is at the SIC level*/
duplicates drop
bys sic_2digit: egen totalvship=total(vship) /*aggregate vship to two digit SIC industry level*/
keep sic_2 totalvship
duplicates drop
sort sic_2
save temp.dta, replace
restore
**create weight
bys sic_2digit: egen totalimports=total(customs) /*industry level imports*/
bys sic_2digit: egen totalexports=total(x) /*industry level exports*/
bys fic sic_2digit: egen imports=total(customs) /*imports from country fic to the industry*/
keep fic sic_2digit totalimports totalexports imports
duplicates drop
sort sic_2
merge sic_2 using temp.dta, uniqusing nokeep
g imp= imports/( totalvship+ totalimports-totalexports)
bys fic sic_2digit: egen tot_imp=total(imp) /*the share of imports from country fic to the industry*/
drop imp _m
duplicates drop
sort fic sic_2digit
save temp.dta, replace
keep sic_2digit
duplicates drop
save temp2.dta, replace

use "country level.dta", clear 
/*country level.dta is a fic-year panel. 
Three variable: fic, year, leniency law. 
"leniency law" equals one if the country (fic) has adopted the law, following 
Internet Appendix A2 */
keep fic year leniencylaw
cross using temp2.dta
sort fic sic_2digit
merge fic sic_2digit using temp.dta, uniqusing nokeep
drop _m
g w_tot_imp=leniencylaw*tot_imp
bys sic_2digit year: egen global_imports=total(w_tot_imp)
keep sic_2digit year global
duplicates drop
sort sic_2digit year
save global_import_2d.dta, replace


 
***********************************************************************************************
*****Construct sample for industry-level analysis Table 1 Panel A & B *******************
***********************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
****1. Sample for Table 1, Panel A: Industry-level Cartel Convictions
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
use "global_import_2d",clear
preserve 
use "cartels by industry",clear 
/*proprietary data purchased from Dr. John M. Connor. We name-matched cartels to SIC industries.
For each SIC2 industry we compute the number of convicted cartels (total_cartels) and firms (total_convict)*/
keep if year>=1994 
tempfile x
keep total_cartels total_convict sic_2digits year
save `x',replace
restore
merge 1:1 sic_2digits year using `x',keep(1 3) nogen 
keep if year>=1994
replace total_cartels=0 if total_cartels==.
replace total_convict=0 if total_convict==.
destring sic_2digits,g(sic2)
g lnnum=ln(1+total_cartels)
g lnnum2=ln(1+total_convict)
label var lnnum "Log number of convicted cartels in the industry"
label var lnnum "Log number of convicted firms in the industry"
xtset sic2 year  
save Table1_PanelA.dta,replace

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
****2. Sample for Table 1, Panel B: Industry-level PPI
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 /*We get the PPI data from the Bureau of Labor Statistics (https://www.bls.gov/ppi/data.htm). 
 We conduct the test at NAICS industry level, because the PPI data for SIC industry discontinued in 2003. 
 The PPI data for NAICS industry is available after 1998. We conduct the test at six-digit NAICS industry level, 
 because the crosswalk files from NAICS code to SIC code is at the six-digit NAICS industry level (http://www.ddorn.net/data.htm). */ 
 
import delimited pc.data.0.Current.txt, clear

keep  if strmatch(ser,"*-*")~=1 /*remove coarser industries, e.g., 3-digit NAICS*/
  
bys series_id year:egen PPI=mean(value) /*the data is at the monthly level. We convert it to annually*/

duplicates drop series_id year,force

***keep (and generate) 6-digit NAICS codes
drop  if  strmatch(ser,"*A*")==1
drop  if  strmatch(ser,"*M*")==1 
replace series_id=subinstr(series_id, "PCU", "", .)
replace series_id=subinstr(series_id, " ", "", .)
replace series_id=subinstr(series_id, "--", "-", .)
g length=length(series_id)
tab length
keep if length==12
keep if year<=2012
g naics6=substr(ser,1,6)
drop if regexm(naics6,"[A-Z]")

destring naics6,replace

keep naics6 year PPI
order naics6 year PPI 

save PPI_NAICS,replace

**Next, cross-walk from NAICS to SIC2 , in order to mege with the treatment measures
set more off
forvalues i=1998/2012{ 
use PPI_NAICS , clear
keep if year==`i'
merge 1:m naics6 using cw_n97_s87\cw_n97_s87,keep(3) nogen /*http://www.ddorn.net/data.htm*/
tempfile `i'
save ``i'',replace
	if `i'>1998 {
	local j=`i'-1
	append using ``j''
	save ``i'',replace
	} 
} 

g sic2=int(sic4/100)
tostring sic2,g(sic_2digits) 
 
replace PPI=PPI/100 
 
**obtain the treatment variables 
drop _merge
merge m:1 sic_2digits year using "global_import_2d"
keep if _merge==3
drop _merge

/* If there are multiple SIC industries mapping to a NAICS industry, We estimate the value of the independent variable as the weight 
 average of the value in each SIC industry, where the weight is the share of a NAICS industry¡¯s 1997 employment that maps to the 
 SIC industry. */
foreach var of varlist global_imports    {
bys naics6 year:egen wt_`var'= wtmean(`var'),weight(weight) 
}

duplicates drop naics6 year,force
   
save Table1_PanelB_PPI.dta,replace




***********************************************************************************************
**********  Construct sample for firm-level analysis (Main)     ******************************
*********************************************************************************************** 
**Sample Construction 
use "Compustat_1990_2015.dta", clear

*** apply filters ***
drop if curcd!="USD"
keep if (indfmt=="INDL") & (datafmt=="STD") & (popsrc=="D") & (consol=="C") 
keep if fic =="USA"  /* eliminate non-us incorporated firms as they might be directly affected by foreign leniency laws*/
gen sic3 = substr(sic, 1, 3)
gen sic2 = substr(sic, 1, 2)
destring sic, replace
destring sic3, replace 
destring sic2, replace
drop if sic  >= 6000 & sic <= 6999   /* eliminate financials */
drop if sic  >= 4900 & sic <= 4999   /* eliminate utilities */
keep if gvkey!=""  /* eliminate missing gvkeys */
destring cik, replace 
keep if fyear!=. /* eliminate missing fiscal year */
keep if datadate~=. /* eliminates missing date of financials */
keep if at~=.   /* eliminates if total assets missing */
keep if at>0   /* eliminates if total assets negative */
keep if at>=0.5 /*eliminate micro firms*/
drop if sale<0  /*eliminate firm with negative revenue*/
gsort gvkey fyear -datadate
duplicates drop gvkey fyear, force /*check duplicates, 0 duplicates*/
*Correcting for non-standard fiscal year ends
replace fyr=. if fyr==0 /*0 case*/
g year=fyear /*use fiscal year to merge with other dataset*/

*** correct SIC codes ending with 0 or 9 Bustanmante and Donangelo (2017) ***
*** i.e., replace these SIC codes ending with 0 or 9 with the SIC of the primary segment     ***  
merge 1:1 gvkey datadate using "$draft3/sic_from_segment",keepus(sics1) keep(1 3) nogen
replace sic=sics1 if  int(sic/100)==int(sics1/100) & (mod(sic,10)==0|mod(sic,10)==9)&sics1~=.
drop sics1

*** Merging with Import Penetrating Data *** 
* The measure is at the four-digit SIC industry level. Value after 2005 is set to the value in 2005 
*data is from https://sompks4.github.io/sub_data.html. The value is cif/(cif+vship-x) 
merge m:1 sic  year using "import_penetrate",keep(1 3) nogen
 
*** Create Market Concentration Measures, Compustat HHI
hhi sale, by(sic2 year)
rename hhi_sale hh_index
  
destring gvkey, replace 
xtset gvkey fyear
 
*** Create control variable, lagged-one-period
gen size = log(l.at)
gen roa = ib / l.at
gen lroa=l.roa 
gen lat = l.at
gen ldltt=l.dltt
gen ldlc=l.dlc
 
*** Merging with Treatment variable  
sort gvkey year 
g sic_2digits = sic2
tostring sic_2digits,replace
merge m:1 sic_2digits year using "global_import_2d.dta", nogen keep(3)   

*** Disclosure Measures *** 
*1. Supplier contracts 
	merge 1:1 gvkey year using "$draft3/redact_supplier_June2017",keep(1 3) nogen  
*2. Conference Call data ****
	sort gvkey fyear 
	tostring gvkey,replace
	replace gvkey="00000"+gvkey if length(gvkey)==1
	replace gvkey="0000"+gvkey if length(gvkey)==2
	replace gvkey="000"+gvkey if length(gvkey)==3
	replace gvkey="00"+gvkey if length(gvkey)==4
	replace gvkey="0"+gvkey if length(gvkey)==5  
	merge 1:1 gvkey year using "words_conference",keep(1 3) nogen 
	
*** stock returns in the calendar year ***  
merge 1:1 gvkey  year using "$draft3/stockreturn",keep(1 3) nogen  
 

*** Eliminate observation with missing control variables ***
keep if  size~=. & hh_index~=. & import_penetrate~=. & lroa~=.
keep if  year>=1994 

** Variable construction, winsorize, etc.
destring gvkey,replace
** Gross Margins
cap drop profit_margin 
g profit_margin=(sale-cogs)/sale 
replace profit_margin=-1 if profit_margin<=-1   
/*we winsorize the gross margin between -1 and 1*/
/*otherwise there would be lots of extreme value*/ 
 
** Winsorize control variables at 1% and 99%
winsor2    lroa size hhi_ import_penetrate bhar_size,cut(1 99) replace  
  
*****Merge variables for cross-sectional tests 
***1. Census HHI  
**Merge with HHI Census 
g naics_4digit=substr(naicsh,1,4)
destring naics_4digit,replace 
g census_yr=cond(fyear<=1997,1997,cond(fyear<=2002,2002,cond(fyear<=2007,2007,2012))) 
cap drop _merge
merge m:1 naics_4digit census_yr using "hhi_census"
drop if _merge==2
drop _merge  

***2. Product Heterogeneity
preserve
import delimited tnic3_allyears_extend_scores.txt,clear
drop if gvkey1==gvkey2
qui sum score,de
g high=(score>= r(p75))
bys gvkey1 year:egen similar=sum(high)  /*number of peers with high similrity*/
g gvkey=gvkey1
keep gvkey year similar
duplicates drop gvkey fyear,force 
save similar,replace 
restore
cap drop _merge
cap drop similar   
merge m:1 gvkey year using similar,keep(1 3) nogen
***3. Entry cost, patents
**see the code 3additional variable construction.sas on variable construction
merge m:1 sic2 year  using "$draft3/patent_industry_level",keep(1 3) nogen  
 
***4. growth ver sus mature
cap drop _merge 
merge m:1 sic2 fyear using  "$draft3/indgrowth" ,keep(1 3) nogen  

***5. probability of conviction 
merge 1:1 gvkey year using  cartel_convict,keep(1 3) 
/*cartel_convict.dta indicates firm-years that are convicted*/
g convict=(_merge==3)
drop if _merge==2
drop _merge 
replace dltt=0 if dltt==.
replace dlc=0 if dlc==.
g lleverage = (ldltt+ldlc)/lat
winsor2 lleverage ,cut(1 99) replace  
probit convict size  lroa lleverage  if fyear<=1999  ,asis  
predict pconvict    , pr 
destring gvkey,replace  

***6. recent conviction of industry peers
preserve
use "$draft3/Compustat_1990_2015.dta", clear 
*** apply filters *** 
keep if (indfmt=="INDL") & (datafmt=="STD") & (popsrc=="D") & (consol=="C")  
destring gvkey,replace
g year= fyear
merge 1:1 gvkey year using cartel_convict,keep(3)   /*keep firm-years with convictions*/
g sic2=substr(sic,1,2)
destring sic2,replace
duplicates drop sic2 fyear,force /*identify industry-years with convictions*/
keep sic2 fyear
rename fyear tmpyear
tempfile x
save `x',replace
restore
forvalues i = 0/3 {
cap drop tmpyear
cap drop recent`i'
g tmpyear = year-`i'
cap drop _merge
merge m:1 sic2 tmpyear using `x',keep(1 3)
g recent`i'=(_merge==3)
} 
g RecentConviction =  recent1==1|recent2==1|recent3==1 

***7.  Num. Public Firm
**see the code 3additional variable construction.sas on variable construction
g naics_3digit=substr(naicsh,1,3)
merge m:1 naics_3digit  year using "$draft3\pctpublicfirm3d_s",keep(1 3) nogen

***8. bertrand versus cournot
**see the code 3additional variable construction.sas on variable construction
tostring sic3 ,replace 
cap drop _merge
merge m:1 sic3  year   using "$draft3\cournot",keep(1 3) nogen

save regress_sample.dta




