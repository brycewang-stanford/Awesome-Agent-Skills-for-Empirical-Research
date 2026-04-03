******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
***                                                                                                                                              						   ***
***                                                                                                                                              						   ***
***                                                                                                       																   ***
*** Article: 		Labor Market Effects of Spatial Licensing Requirements: Evidence from CPA Mobility    																   ***
*** Authors: 		Stefano Cascino, Ane Tamayo, and Felix Vetter                                         																   ***
*** Journal:		Journal of Accounting Research                                                        																   ***
***                                                                                                    	  																   ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.          																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************

******************************************************************************************************************************************************************************
* 0. CD to folder

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
* 1. Preparation controls used in multiple analyses

do "./Dofiles/01_CPAMob_ControlsPrep.do"

******************************************************************************************************************************************************************************
* 2. Law prediction

do "./Dofiles/02_CPAMob_AdoptionPrediction.do" 

******************************************************************************************************************************************************************************
* 3. QCEW state-level

do "./Dofiles/03_CPAMob_QCEW_State.do"

******************************************************************************************************************************************************************************
* 4. SUSB state-level

do "./Dofiles/04_CPAMob_SUSB_State.do"

******************************************************************************************************************************************************************************
* 5. QCEW county-level 

do "./Dofiles/05_CPAMob_QCEW_BorderCounty.do"

******************************************************************************************************************************************************************************
* 6. QCEW MSA-level

do "./Dofiles/06_CPAMob_QCEW_MSA.do"

******************************************************************************************************************************************************************************
* 7. AICPA MAP Survey

do "./Dofiles/07_CPAMob_AICPAMap.do"

******************************************************************************************************************************************************************************
* 8. Pension plan fees 

do "./Dofiles/08_CPAMob_PensionPlanFees.do"

******************************************************************************************************************************************************************************
* 9. AICPA Misconduct

do "./Dofiles/09_CPAMob_Qual1_AICPAMisconduct.do"

******************************************************************************************************************************************************************************
* 10. EBSA enforcement 

do "./Dofiles/10_CPAMob_Qual2_EBSA.do"

******************************************************************************************************************************************************************************
* 11. Disciplinary actions

do "./Dofiles/11_CPAMob_Qual3_CODiscAction.do"******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prep controls used in multiple analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
* GDP  

import excel "./Data/Controls/BEA_GDPbyState_clear.xls", sheet("Sheet0") firstrow clear
* rename from label 
foreach v of varlist C-W {
   local x : variable label `v'
   rename `v' gdp`x'
}
* reshape 
reshape long gdp, i(GeoFips GeoName) j(year)

* rename for consistency 
rename GeoFips area_fips

tempfile gdp
save `gdp'

******************************************************************************************************************************************************************************
* Unemployment 

import excel "./Data/Controls/UnemploymentState_cleanforimport.xlsx", sheet("Sheet1") firstrow clear
keep statefips year unemployment_peroflabor
keep if strlen(statefips) == 2
destring year, replace 
rename statefips area_fips 
replace area_fips = area_fips + "000"
rename unemployment_peroflabor unemp

******************************************************************************************************************************************************************************
* Merge macro files and generate lags 

* merge the two 
merge 1:1 area_fips year using `gdp'
keep if _merge == 3
drop _merge 
tab year

* introduce lag
replace year = year + 1
tab year 
rename gdp L1_gdp 
rename unemp L1_unemp 

* save tempfile
tempfile macrocontrols
save `macrocontrols'

******************************************************************************************************************************************************************************
* Migration controls (raw data obtained via IPUMS ACS)

use "./Data/Controls/Data_ExtendedControls/usa_00015.dta", clear /*downloaded IPUMS file*/

* housekeeping for var names
tostring statefip, gen(area_fips)
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000"

* gen variables of interest 
gen betweenstatemigration = (migrate1 == 3)
gen abroadmigration = (migrate1 == 4)

* collapse to panel structure 
collapse abroadmigration betweenstatemigration, by(area_fips year)

* gen lags
replace year = year + 1
rename abroadmigration L1_abroadmigration 
rename betweenstatemigration L1_betweenstatemigration

******************************************************************************************************************************************************************************
* Merge control files and save 

* merge migration and macro 
merge 1:1 area_fips year using `macrocontrols'
keep if _merge == 3
drop _merge 

* save new control file 
save "./Data/Controls/extendedstatecontrols.dta", replace







******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prepare law adoption file and analysis 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Data imports and preparation

******************************************************************************************************************************************************************************
* Import laws passed (hand collected, source: http://knowledgecenter.csg.org/kc/category/content-type/bos-archive)

import excel "./Data/LawPrediction/LawsByState.xls", sheet("Sheet1") firstrow clear
drop if State =="Dist. of Columbia" /*no available data*/

******************************************************************************************************************************************************************************
* Merge in FIPS indentifiers 

rename Year year
preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear 
keep State year area_fips lq_annual_avg_emplvl
tempfile merger 
save `merger'

restore 
capture drop _merge 
merge 1:1 State year using `merger'
keep if _merge == 3 /*all merged from master*/

******************************************************************************************************************************************************************************
* Merge in macro controls

capture drop _merge
merge 1:1 area_fips year using "./Data/LawPrediction/macrocontrols.dta"
keep if _merge == 3  /*all from master are merged*/
drop _merge  

******************************************************************************************************************************************************************************
* Merge in BDS

preserve
import delimited "./Data/LawPrediction/Data_BDS/bds_e_st_release.csv", encoding(ISO-8859-1)clear
gen firm_birth = estabs_entry / estabs
gen jobcreation_netbirth = net_job_creation_rate
xtset state year2, yearly
foreach var of varlist firm_birth jobcreation_netbirth {
	gen L1_`var' = L.`var'

}
keep if year >= 2003 & year <= 2015
keep state year2 firm_birth jobcreation_netbirth L1_*
* prep for merge
tostring state, gen(area_fips)
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000" 
drop state 
rename year2 year
tempfile bds
save `bds'

restore 
merge 1:1 area_fips year using `bds'
assert _merge != 1 
keep if _merge == 3
drop _merge

******************************************************************************************************************************************************************************
* Merge in political economy predictors

preserve
import excel "./Data/LawPrediction/CPAMob_PoliticalEconomy.xlsx", sheet("Sheet1") firstrow clear
drop K L M N O P Q /*drop notes from hand collection*/
drop if State == "" /*drop empty lines in hand collection sheet*/
drop if State == "DC" /*no legislation vars, as before*/
tempfile polecon
save `polecon'

restore 
merge m:1 State using `polecon' 
keep if _merge == 3 
drop _merge  


******************************************************************************************************************************************************************************
* Merge in State Board of Accountancy predictors from Colbert and Murray (2013)

* interim step: merge in cross walk file to merge with Colbert and Murray (2013) data
preserve
import excel "./Data/LawPrediction/StatesPostalCodeCrosswald.xlsx", sheet("Sheet1") clear
gen StatePostal = substr(A, -2, .)
gen State = substr(A, 1, strlen(A) - 5)
tempfile postcode
save `postcode'
restore
merge m:1 State using `postcode'
assert _merge != 1 
keep if _merge == 3
drop _merge 

* merge in
merge m:1 StatePostal using "./Data/LawPrediction/ColbertMurray.dta"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Variable prep and analysis

******************************************************************************************************************************************************************************
* Variable prep 

* Set STCox structure for checking
egen id = group(State)
gen coxtime = year - 2002 

* Set failure event
sort State year
by State: gen CPAMob = (_n ==_N)
stset coxtime, id(id) failure(CPAMob==1)
* check Cox structure
* sts graph

* Prep bill load variables
replace Session = "1" if Session =="" 
gen nosessionid = (Session == "na" | Session == "0")
* When there is no session, nothing can be passed
foreach var of varlist IntroBill IntroResol EnactBill EnactResol {
	replace `var' = "0" if nosessionid == 1

}
replace LengthSession = "0" if nosessionid == 1 

* Prep Dem / Rep variables
destring Senate_Dem, replace force
destring Senate_Rep, replace force
gen Senate_Total = Senate_Dem + Senate_Rep
gen Senate_Dem_Share = Senate_Dem / Senate_Total
* For Nebraska, assume equal splits (house / senate and rep / dem)
replace Senate_Total = 25 if State == "Nebraska"
replace Senate_Dem_Share = 0.5 if State == "Nebraska"

* House share and total
destring House_Dem, replace force
destring House_Rep, replace force
gen House_Total = House_Dem + House_Rep
gen House_Dem_Share = House_Dem / House_Total
* For Nebraska, assume equal splits (house / senate and rep / dem)
replace House_Total = 25 if State == "Nebraska"
replace House_Dem_Share = 0.5 if State == "Nebraska"

* Total state split
gen HouseSenate_Dem = House_Dem + Senate_Dem
gen HouseSenate_Rep = House_Rep + Senate_Rep
gen HouseSenate_Total = HouseSenate_Dem + HouseSenate_Rep
gen HouseSenate_Dem_Share = HouseSenate_Dem / HouseSenate_Total
replace HouseSenate_Total = 49 if State == "Nebraska"
replace HouseSenate_Dem_Share = 0.5 if State == "Nebraska"

* Bills enacted / introduced 
destring EnactBill, replace force
destring IntroBill, replace force
gen logbills = log(1 + IntroBill)
gen logenact = log(1 + EnactBill)

* Pol economy: Mob Task Force
gen mobilitytaskforce = (MobTaskForce != "0") 

* Pol economy: board structure
gen CPAinBoard = CPABoard / TotalBoard
gen Big4inBoard = Big4Board / TotalBoard

* Pol economy: Colbert / Murray 
gen pubprac = real(PUBPRAC) 
gen fundingautonomy = FUND_AUT
gen localCPAs = NO_LOCAL / (NO_NAT + NO_LOCAL) 

******************************************************************************************************************************************************************************
* Wage and employment trends, difference to mean

preserve

* import QCEW state-level data for years 2000 and 2005
foreach i in 2000 2005 {
	import delimited "./Data/Census/Data_QCEW/QCEW_RAWData/`i'.annual.singlefile.csv", stringcols(_all) clear
	keep if industry_code == "541211" /*keep CPAs only*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if agglvl_code == "58" /*keep only state-level 6 digits*/
	gen excludestate = (area_fips == "51000" | area_fips == "39000" | area_fips == "78000" | area_fips == "72000" | area_fips == "15000")
	drop if excludestate == 1 /*align with main sample*/
	rename avg_annual_pay pay
	rename annual_avg_emplvl emp
	keep area_fips year pay emp
	tempfile qcew`i'
	save "`qcew`i''"
}
use "`qcew2000'", clear
append using "`qcew2005'"
ds area_fips, not
foreach v of var `r(varlist)' {
	destring `v', replace
}
egen state_id = group(area_fips)
xtset state_id year, yearly
gen logpay = log(pay)
gen logemp = log(emp)

* gen difference over time
gen d5logpay = logpay - L5.logpay
gen d5logemp = logemp - L5.logemp

* gen difference to mean
keep if year == 2005 /*calc diffs to national */
egen logpaymean = mean(logpay)
egen logempmean = mean(logemp)
gen logpaydiff = logpay - logpaymean
gen logempdiff = logemp - logempmean
keep area_fips d*log* logpaydiff logempdiff
tempfile qcewcontrols
save `qcewcontrols'
restore
capture drop _merge 
merge m:1 area_fips using  `qcewcontrols'
keep if _merge == 3

******************************************************************************************************************************************************************************
* Prediction analysis 

* Table 1, Panel B: CPA Mobility Adoption Prediction 
preserve
qui stcox logpaydiff logempdiff d5logpay d5logemp pubprac localCPAs i.mobilitytaskforce i.fundingautonomy L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
keep if (e(sample)) == 1 /*estimate full model to ascertain equal obs across specs*/
eststo clear
eststo: stcox logpaydiff logempdiff d5logpay d5logemp, cluster(id)
eststo: stcox pubprac localCPAs i.mobilitytaskforce i.fundingautonomy, cluster(id)
eststo: stcox L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth
eststo: stcox Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
eststo: stcox logpaydiff logempdiff d5logpay d5logemp pubprac localCPAs i.mobilitytaskforce i.fundingautonomy L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
esttab using "./Output/Table1_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace eform
restore 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW state-level prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Read raw data and prep file

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import QCEW data


filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace
use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename /*needed for getting the years*/ 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "58" /*keep only State-level 6 digits*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" | industry_code == "541110" /*keep only CPAs and lawyers*/
	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Clean file / var formats

******************************************************************************************************************************************************************************
* Var format
ds area_fips industry_code qtr filename disclosure_code_str lq_disclosure_code_str oty_disclosure_code_str, not
foreach v of var `r(varlist)' {
	destring `v', replace 
}

******************************************************************************************************************************************************************************
* Clean up state variable

* interim step to get the state name: merge with a name cross walk file 
merge m:1 area_fips using "./Data/Census/Data_QCEW/FIPSandNamesCrosswalk.dta" 
assert _merge != 1
keep if _merge == 3
drop _merge

* area_title
split area_title, p(" -- ")
replace area_title = area_title1
drop area_title1 area_title2


******************************************************************************************************************************************************************************
* Sample screen

* toss out excluded sates
gen excludestate = (area_title == "Virginia" | area_title == "Ohio" | area_title == "Virgin Islands" | area_title == "Puerto Rico" | area_title == "Hawaii")
drop if excludestate == 1

* sample period alignment
keep if year >= 2003

******************************************************************************************************************************************************************************
* Merge in controls

merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta" 
keep if _merge == 3
drop _merge 

******************************************************************************************************************************************************************************
* Analyses prep

* gen shorter var names for handling
gen pay = avg_annual_pay
gen emp = annual_avg_emplvl

* gen main responses
gen logpay = log(pay) 
gen logemp = log(emp)

* gen weights -- empshares
egen occ_year_id = group(industry_code year)
preserve 
collapse (sum) emp, by(occ_year_id)
rename emp emptotal
tempfile emptotal
save `emptotal'
restore 
merge m:1 occ_year_id using `emptotal'
assert _merge == 3 
drop _merge
gen empshare = emp / emptotal

* gen x-section treatment dummies for DiDiD and sample inclusion
capture gen cpa = (industry_code == "541211")
capture gen lawyer = (industry_code == "541110")
capture gen cpalawyer = (cpa == 1 | lawyer == 1)

* merge in treatment dummies
capture drop L1_CPAMobility_Effec_longpanel
preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear
keep area_fips year adoption_year L1_CPAMobility_Effec_longpanel
tempfile mobilitydummies
save `mobilitydummies'
restore 
capture drop _merge 
merge m:1 area_fips year using `mobilitydummies'
drop if _merge == 2
drop _merge 

* shorten name for handling in DiDiD
rename L1_CPAMobility_Effec_longpanel L1_CPAMob
replace L1_CPAMob = 1 if year > 2015 /*all sample states adopted then*/

* gen DiDiD treatment dummies
gen L1_CPAMob_cpa = L1_CPAMob * cpa 

* gen event time dummies for graph analysis
gen effectiveyear = adoption_year
do "./Dofiles/reltimedummmies.do" /*outsourced event-time dummy generator for brevity*/

* gen FEs 
egen cpa_year = group(cpa year)
egen state_year = group(area_fips year)
egen state_occ_id = group(industry_code area_fips)
egen state_id = group(area_fips)

* gen logestab 
gen logestab = log(annual_avg_estabs)

* gen empl2estab
gen empl2estab = annual_avg_emplvl / annual_avg_estabs
gen logempl2estab = log(empl2estab)

* gen estabshares 
bysort occ_year_id: egen estabtotal = total(annual_avg_estabs)
gen estabshare = annual_avg_estabs / estabtotal


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analyses: QCEW state-Level

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Figure 1

******************************************************************************************************************************************************************************
* Figure 1, Panel A: Timing reg CPA only 

capture gen zero = 0 
label variable zero "t-1" 
reghdfe logpay reltimeleadlarger3_cpa reltimelead3_cpa reltimelead2_cpa zero /*reltimelead1_cpa */  reltime0_cpa reltimelag1_cpa ///
	reltimelag2_cpa reltimelag3_cpa reltimelaglarger3_cpa ///
	L1_unemp L1_gdp L1_abroadmigration L1_betweenstatemigration if cpa == 1 [aw = empshare], a(state_id year) cluster(state_id)
coefplot, keep(reltime* zero) omitted vertical ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(4.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelA.pdf", as(pdf) replace
graph close

******************************************************************************************************************************************************************************
* Figure 1, Panel C: Timing reg CPA vs lawyers

capture gen zero = 0 
label variable zero "t-1" 
reghdfe logpay reltimeleadlarger3_cpa reltimelead3_cpa reltimelead2_cpa zero /* reltimelead1_cpa */ reltime0_cpa reltimelag1_cpa ///
	reltimelag2_cpa reltimelag3_cpa reltimelaglarger3_cpa if cpalawyer == 1 [aw = empshare], a(cpa_year state_year state_occ_id) cluster(state_id)
coefplot, keep(reltime* zero) omitted vertical ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(4.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelC.pdf", as(pdf) replace
graph close
	
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 2

******************************************************************************************************************************************************************************
* Table 2, Panel A: Descriptives

* CPA only
tabstat pay logpay emp logemp L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1 ///
	, s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

******************************************************************************************************************************************************************************
* Table 2, Panel B: Baseline wage

eststo clear 
eststo: reghdfe logpay L1_CPAMob if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_unemp if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_gdp if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_betweenstatemigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_abroadmigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
esttab using "./Output/Table2_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
* Table 2, Panel C: Employment

eststo clear
eststo: reghdfe logemp L1_CPAMob if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_unemp if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_gdp if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_betweenstatemigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_abroadmigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
esttab using "./Output/Table2_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel B: Triple Diff CPA vs lawyers

eststo clear 
eststo: reghdfe logpay L1_CPAMob_cpa if cpalawyer == 1 [aw = empshare], a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob_cpa if cpalawyer == 1, a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logempl2estab L1_CPAMob_cpa if cpalawyer == 1 [aw = estabshare], a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logestab L1_CPAMob_cpa if cpalawyer == 1, a(cpa_year state_year state_occ_id) cluster(state_id)
esttab using "./Output/Table3_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* SUSB State-level prep and analyses 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Read in and clean data

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Raw data processing 

filelist, dir("./Data/Census/Data_SUSB/SUSB_6digitnaics/") pat("*.txt") save("./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta") replace

use "./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta" in `i', clear
	local f = dirname + "/" + filename
	local g = filename
	import delimited "`f'", encoding(ISO-8859-1) clear
	keep if naics == "541211" | naics == "541110" /*keep CPAs and Lawyers for triple and quadruple diff*/
	gen source = "`f'"
	tempfile save`i'
	save "`save`i''"
}

*append all files
use "`save1'", clear
	forvalues i=2/`obs' {
    append using "`save`i''"
}


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Clean up file 

* keep only state-level variables
drop if state == 0 /*drop national-level variables */

* gen year variable 
capture drop year
gen year = substr(source, -8, 4)
destring year, replace

* sort data
sort state statedscr entrsize year

* gen area fips / statename for merges
gen area_fips = state
tostring area_fips, replace 
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000"
gen statename = statedscr

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Variable consistency checks and adjustments

* sort out differences in variable names (not definitions) across SUSB year files variable by variable: 

******************************************************************************************************************************************************************************
* Employment

tab year if missing(empl) /*this is as of 2011*/
tab year if missing(empl_n) /*this is before 2011*/
gen empltemp = .
replace empltemp = empl if year < 2011
replace empltemp = empl_n if year >= 2011
tab year if missing(empltemp) /* none missing*/
drop empl empl_n
rename empltemp empl

******************************************************************************************************************************************************************************
* Payroll

tab year if missing(payr) /*as of 2011 missing*/
tab year if missing(payr_n) /*up until 2010*/
gen paytemp = .
replace paytemp = payr if year < 2011
replace paytemp = payr_n if year >= 2011
tab year if missing(paytemp) /*done - none missing*/
drop payr payr_n
rename paytemp payr 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis prep

******************************************************************************************************************************************************************************
* Merge in treatment dummies

preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear
keep area_fips year adoption_year L1_CPAMobility_Effec_longpanel
tempfile mobilitydummies
save `mobilitydummies'

restore 
* merge m:1 (multiple size classes per area_fips and year)
merge m:1 area_fips year using `mobilitydummies'
keep if _merge == 3 
drop _merge 

******************************************************************************************************************************************************************************
*  Gen outcome variables 

gen pay = payr / empl 
gen logpay = log(pay)
gen logempl = log(empl)
gen logestb = log(estb)
gen emp2estb = empl / estb
gen logemp2estb = log(emp2estb)

tab year if missing(logpay)
tab entrsize year if missing(logpay)  /*Tests are conducted on Class 5 (<20) and Class 6 (20-99) to max coverage -- next step*/

******************************************************************************************************************************************************************************
* Gen and keep size buckets 

gen smallfirm = (entrsize == 5) /*<20 employees*/
gen largefirm = (entrsize == 6) /*20-99 employees*/
gen inclfirm = (entrsize == 5 | entrsize == 6)
keep if inclfirm == 1

******************************************************************************************************************************************************************************
* Gen industry FE for DiDiD and DiDiDiD

gen cpa = (naics == "541211")
gen lawyer = (naics == "541110")

******************************************************************************************************************************************************************************
* Gen FEs 

capture drop *_id
egen state_id = group(area_fips)
egen state_naics_id = group(area_fips naics)
egen state_size_id = group(area_fips entrsize)
egen state_naics_size_id = group(area_fips naics entrsize)
egen year_id = group(year)
egen state_year_id = group(area_fips year)
egen naics_year_id = group(naics year)
egen size_year_id = group(entrsize year)
egen naics_size_year_id = group(naics entrsize year)
egen state_naics_year_id = group(area_fips naics year)  
egen state_size_year_id = group(area_fips entrsize year)

******************************************************************************************************************************************************************************
* Gen treatments 

* Shorten var name for DiDiD and DiDiDiD treatment dummy construction
rename L1_CPAMobility_Effec_longpanel L1_CPAMob 

capture gen L1_CPAMob_small = L1_CPAMob * smallfirm * cpa
capture gen L1_CPAMob_small_cpa = L1_CPAMob * smallfirm * cpa

capture gen L1_CPAMob_large = L1_CPAMob * largegfirm * cpa
capture gen L1_CPAMob_large_cpa = L1_CPAMob * largefirm * cpa

******************************************************************************************************************************************************************************
* Sample screens

* drop states 
drop if statename == "Ohio" | statename == "Virginia"

* balance
bysort state_naics_size_id: egen totalobs = count(logpay)
qui sum totalobs
keep if totalobs == `r(max)'

******************************************************************************************************************************************************************************
* Calc weights

capture drop empltotal 
capture drop estbshare
bysort naics_size_year_id: egen empltotal = total(empl)
gen emplshare = empl / empltotal
bysort naics_size_year_id: egen estbtotal3 = total(estb)
gen estbshare = estb / estbtotal


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Restriction on double-matched state-years

* restrict to sample with full coverage to estimate quadruple diff
qui reghdfe logpay L1_CPAMob_small_cpa [aw = emplshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl1 = (e(sample) == 1)
qui reghdfe logempl L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl2 = (e(sample) == 1)
qui reghdfe logemp2estb L1_CPAMob_small_cpa [aw = estbshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl3 = (e(sample) == 1)
qui reghdfe logestb L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl4 = (e(sample) == 1)
keep if incl1 == 1 & incl2 == 1 & incl3 == 1 & incl4 == 1

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel C: Quadruple diff spec 

eststo clear
eststo: reghdfe logpay L1_CPAMob_small_cpa [aw = emplshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logempl L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logemp2estb L1_CPAMob_small_cpa [aw = estbshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logestb L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
esttab using "./Output/Table3_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel A: CPA only estimates

* keep only CPAs and re-prep weights
keep if cpa == 1

capture drop emplshare 
capture drop emptotal 
capture drop estbtotal 
capture drop estbshare
bysort entrsize year: egen emptotal = total(empl)
gen empshare = empl / emptotal
bysort entrsize year: egen estbtotal = total(estb)
gen estbshare = estb / estbtotal

* merge in state-year controls -- before: state-year FE, controls absorbed
capture drop _merge 
merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta"
assert _merge != 1
drop if _merge == 2 /*years available in QCEW but not in SUSB (starting in 2007)*/
drop _merge 

* Table 3, Panel A: CPA small vs Large
eststo clear
eststo: reghdfe logpay L1_CPAMob_small if cpa == 1 [aw = empshare], a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logempl L1_CPAMob_small if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logemp2estb L1_CPAMob_small [aw = estbshare] if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logestb L1_CPAMob_small if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
esttab using "./Output/Table3_PanelA.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Graphical Analysis -- note: SUSB program starts in 2007 --> fewer pre-period data points

******************************************************************************************************************************************************************************
* Event time dummies 

gen eventtime = year - adoption_year
gen lead1small = (eventtime == -1 & smallfirm == 1)
label var lead1small "t=-1"
gen leadlarger2small = (eventtime <= -2 & smallfirm == 1)
label var leadlarger2small "t≤-2"
gen lag0small = (eventtime == 0 & smallfirm == 1)
label var lag0small "t=0"
gen lag1small = (eventtime == 1 & smallfirm == 1)
label var lag1small "t=1"
gen lag2small = (eventtime == 2 & smallfirm == 1)
label var lag2small "t=2"
gen lag3small = (eventtime == 3 & smallfirm == 1)
label var lag3small "t=3"
gen laglarger4small = (eventtime >= 4 & smallfirm == 1)
labe var laglarger4small "t≥4"

******************************************************************************************************************************************************************************
* Figure 1, Panel B: Event time plot SUSB-state CPA large vs small 

capture gen zero = 0
label var zero "t=-1"
reghdfe logpay leadlarger2small zero /* lead1small */ lag0small lag1small lag2small lag3small laglarger4small if cpa == 1 [aw = empshare], ///
	a(state_year_id state_size_id size_year_id) cluster(state_id)
coefplot, keep(*small zero) vert omit ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(2.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelB.pdf", as(pdf) replace
graph close 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW border-county-level prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and clean data

******************************************************************************************************************************************************************************
* Import raw QCEW data

filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace
use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename /*needed for getting the years*/ 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "78" /*keep only 6 digits naics county-level variables*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" /*keep only CPAs*/
	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}

* var format 
ds area_fips industry_code qtr filename disclosure_code_str lq_disclosure_code_str oty_disclosure_code_str, not
foreach v of var `r(varlist)' {
	destring `v', replace 
}


******************************************************************************************************************************************************************************		 
* Align sample period

* align sample period with state-level QCEW analyses
tab year
keep if year >= 2003

******************************************************************************************************************************************************************************		 
* Merge in treatments and sample screen

******************************************************************************************************************************************************************************
* Merge prep and merge with law dummies

* (temp) recode the state indetifiers for the merges
gen area_fips_merge_temp = substr(area_fips,1,2) + "000" /*only need the first two--treatment assignment at the state level*/
rename area_fips area_fips_original /*renaming required for merge*/
rename area_fips_merge_temp area_fips
merge m:1 area_fips year using "./Data/Helper/LawDummiesCensusCounty.dta"
rename area_fips area_fips_merge_temp /*reverse renaming*/
rename area_fips_original area_fips  

* tab year if _merge == 1 /*not matched from master*/
drop if year <= 2002 /*consistency with State-level and Dummy file*/

* impose sample restriction
drop if area_fips_merge_temp == "15000" /*Hawaii*/
drop if area_fips_merge_temp == "72000" /*Puerto Rico*/
drop if area_fips_merge_temp == "78000" /*Virgin Island*/ 

* adjust treatment dummies to be equal to 1 for later years, when all sample states adopted
replace L1_CPAMobility_Effec_longpanel = 1 if year >= 2015 
drop _merge 


******************************************************************************************************************************************************************************		 
* Balancing check

egen county_id = group(area_fips)
xtset county_id year, yearly

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Merge in identifiers and control variables

******************************************************************************************************************************************************************************
* Merge with the adjanct county file

capture drop _merge
merge m:1 area_fips using "./Data/Helper/CPAMobility_AdjanctCountiesBorderIDs.dta"
tab statepair if _merge == 2
tab homestate if _merge == 2
drop if _merge == 2
gen neighbor_county = 0
replace neighbor_county = 1 if _merge == 3
drop _merge

******************************************************************************************************************************************************************************
* Merge in mapping info

capture drop _merge
merge m:1 area_fips using "./Data/Helper/us_county_db.dta" 
tab NAME if _merge == 2 
drop if _merge == 2 
drop _merge

******************************************************************************************************************************************************************************
* Merge state-level controls 

rename area_fips area_fips_original /*renaming needed for merge -- macro controls except for unemp (merged in below) are only available at the state level*/
rename area_fips_merge_temp area_fips
capture drop _merge
merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta"
rename area_fips area_fips_merge_temp /*reverse renaming*/ 
rename area_fips_original area_fips 
drop if _merge != 3

******************************************************************************************************************************************************************************
* Merge county-level controls 

preserve
use "./Data/Controls/CPAMobility_BLS_LAUS_CountyEmployment.dta", clear
keep area_fips area_title_LAUS year unemploymentrate
replace year = year + 1 /*gen lagged structure*/
rename unemploymentrate L1_unemploymentrate
* Rename county level control for consistency and clarity
rename L1_unemploymentrate L1_unemp_county 
tempfile unempcounty
save `unempcounty'
restore

capture drop _merge
merge 1:1 area_fips year using `unempcounty'
keep if _merge ==3

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis and variable preparation

******************************************************************************************************************************************************************************
* Prep response vars

* Prep pay 
gen pay = avg_annual_pay
gen logpay = log(avg_annual_pay)

* Prep emp
rename annual_avg_emplvl emp
gen logemp = log(emp)


******************************************************************************************************************************************************************************
* Prep FEs 

qui capture drop border_id
capture egen border_id = group(BORDINDX)
capture egen county_id = group(area_fips)
capture egen state_id = group(area_fips_merge_temp)

******************************************************************************************************************************************************************************
* Introduce non-overlaping treatdate condition

capture drop adoption_year
gen adoption_year = .
bysort area_fips year: replace adoption_year = year if CPAMobility_Effec == 1


levelsof statefip, local(states)
foreach s of local states {
	sum adoption_year if statefip == `s'
	replace adoption_year = r(max) if statefip == `s' & missing(adoption_year)
}

capture drop diff_adoption 
gen diff_adoption = 0
levelsof border_id, local(levels)
foreach l of local levels {
	sum adoption_year if border_id == `l'
	replace diff_adoption = 1 if r(sd) != 0 & border_id == `l'

}

******************************************************************************************************************************************************************************
* Figure 2: Border counties with non-overlapping treatment dates 

spmap neighbor_county using us_county_coord if year == 2005 & stateicp != 81, id(id) fcolor(Blues) clmethod(unique)
graph export "./Output/Figure2.pdf", as(pdf) replace

******************************************************************************************************************************************************************************
* Keep only diff-adoption counties 

keep if diff_adoption == 1

******************************************************************************************************************************************************************************
* Further est sample conditions to ascertain estimation on consistently disclosing--that is, no Census confidentiality--counties

* gen counter for balancing
sort area_fips year
bysort area_fips: gen counter = _N

* condition: only disclosing counties--that is, counties displaying above-zero employees throughout
capture drop minemp
bysort county_id: egen minemp = min(emp)

******************************************************************************************************************************************************************************
* Calc weights

capture drop empshare emptotal
bysort year: egen emptotal = total(emp)
gen empshare = emp / emptotal

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis 

preserve 

* impose restriction
keep if counter == 15 & neighbor_county == 1 & border_id != 74 & diff_adoption == 1 & !missing(logpay) & minemp > 0 /*BorderID 74 is Lake Michigan*/

* impose reg restriction to ascertain same obs across specifications
qui reghdfe logpay L1_CPAMobility_Effec_longpanel [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
keep if (e(sample)) == 1

* Table 4, Panel B: Border-county analysis
eststo clear
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_betweenstatemigration L1_abroadmigration [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)

eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_betweenstatemigration L1_abroadmigration, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration, a(county_id i.border_id#i.year) cluster(state_id)
esttab using "./Output/Table4_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Table 4, Panel A: Desc stats 
tabstat pay logpay emp logemp L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration, ///
	s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

restore 
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW MSA-level prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and clean data

******************************************************************************************************************************************************************************
* Import Census MSA data

filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace

use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "48" /*keep only MSA-level 6 digits -- Census codes available here: https://data.bls.gov/cew/doc/titles/agglevel/agglevel_titles.htm*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" | industry_code == "541110" /*keep only CPAs and lawyers*/

	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}

******************************************************************************************************************************************************************************
* Clean up and adjust variable formatting

drop oty_* lq_* filename qtr disclosure_code_st size_code own_code total_annual_wages taxable_annual_wages annual_avg_wkly_wage annual_contributions 

foreach var of varlist year annual_avg_estabs annual_avg_emplvl avg_annual_pay {
	destring `var', replace 
}

******************************************************************************************************************************************************************************
* Merge in GDP MSA 

preserve
import delimited "./Data/Controls/bea_gdp_annual_naicsall_msa_clean.csv", encoding(ISO-8859-1)clear stringc(_all)
foreach var of varlist v3-v19 {
   local x : variable label `var' 
   rename `var' msagdp`x'
   destring msagdp`x', replace force
}
reshape long msagdp, i(geofips geoname) j(year)
* adjust to msa fips 
gen area_fips = "C" + substr(geofips, 1, 4)
drop geofips
tempfile msagdp
save `msagdp'
restore 
merge m:1 area_fips year using `msagdp'
drop if _merge == 2
drop _merge 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis and variable preparation

* gen industry ID 
encode industry_code, gen(industry_id) label(industry_id)

* rename variables
gen pay = avg_annual_pay
gen logpay = log(pay)
gen emp = annual_avg_emplvl
gen logemp = log(emp)
gen logmsagdp = log(msagdp)

* difference variables
capture drop msa_industry_id 
egen msa_industry_id = group(area_fips industry_id)
xtset msa_industry_id year, yearly
foreach var of varlist logpay logmsagdp {
	capture gen d1`var' = (`var' - L1.`var') 
}

* IDs and screen
gen cpa = (industry_code == "541211")
gen lawyer = (industry_code == "541110")
keep if cpa == 1 | lawyer == 1 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Helper variables and screen

* est periods
gen postperiod = (year >= 2014)
gen prepreriod = (year >= 2002 & year <= 2005)
gen estperiod = (prepreriod == 1 | postperiod == 1)

* label for outputs
label define cpal 0 "Lawyers" 1 "CPAs" 
label values cpa cpal 
label define postperiodl 0 "Pre-Period" 1 "Post-Period" 
label values postperiod postperiodl 
label define preperiodl 0 "Post-Period" 1 "Pre-Period" 
label values prepreriod preperiodl 
label var d1logpay ""

* min data availablity criterion
egen msa_id = group(area_fips)
gen inclobs = (!missing(d1logpay))
bysort msa_id cpa estperiod: egen totalinclobs = total(inclobs)
keep if totalinclobs >= 5

* calc empshares
bysort cpa year: egen totalemp = total(emp)
gen empshare = emp / totalemp


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Figure 3, Panel A and B: Visual sens analysis 

binscatter d1logpay d1logmsagdp [aw = empshare] if prepreriod == 1 & cpa == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("CPAs: Pre-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelA-1.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if postperiod == 1 & cpa == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("CPAs: Post-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelA-2.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if prepreriod == 1 & lawyer == 1 /// 
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("Lawyers: Pre-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelB-1.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if postperiod == 1 & lawyer == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("Lawyers: Post-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelB-2.pdf", as(pdf) replace
graph close


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel A: Sens analysis regression

gen d1logmsagdp_post = d1logmsagdp * postperiod
gen d1logmsagdp_pre = d1logmsagdp * prepreriod

gen d1logmsagdp_cpa = d1logmsagdp * cpa
gen d1logmsagdp_lawyer = d1logmsagdp * lawyer
gen d1logmsagdp_cpa_post = d1logmsagdp * cpa * postperiod
gen d1logmsagdp_lawyer_post = d1logmsagdp * lawyer * postperiod

* Desc Stats 
gen cpalawyer = (cpa == 1 | lawyer == 1)
tabstat pay logpay d1logpay if cpa == 1 & estperiod == 1 & !missing(d1logpay) & !missing(d1logmsagdp), s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
tabstat pay logpay d1logpay if lawyer == 1 & estperiod == 1 & !missing(d1logpay) & !missing(d1logmsagdp), s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
tabstat msagdp logmsagdp d1logmsagdp if estperiod == 1 & !missing(d1logpay) & cpalawyer == 1, s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* Table 5, Panel A: Reg | profession 
eststo clear
eststo: reg d1logpay d1logmsagdp_post d1logmsagdp postperiod [aw = empshare] if cpa == 1 & estperiod == 1, cluster(msa_id)
eststo: reg d1logpay d1logmsagdp_post d1logmsagdp postperiod [aw = empshare] if lawyer == 1 & estperiod == 1, cluster(msa_id)
esttab using "./Output/Table5_PanelA.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Aux reg: for difference in coefficient test 
capture egen cpa_year_id = group(cpa year)
capture egen cpa_period_id = group(cpa postperiod)
capture egen msa_id = group(area_fips)
capture egen msa_cpa_id = group(area_fips cpa)

reg d1logpay d1logmsagdp_cpa_post d1logmsagdp_cpa d1logmsagdp_lawyer_post d1logmsagdp_lawyer i.cpa i.postperiod i.postperiod#i.cpa [aw = empshare] if estperiod == 1, cluster(msa_id)
test d1logmsagdp_cpa_post = d1logmsagdp_lawyer_post


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel B: Volatility analysis 

eststo clear

* Table 5, Panel B, Col 1
preserve
keep if estperiod == 1
local testvar d1logpay
collapse (sd) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa post, vce(robust)
restore 

* Table 5, Panel B, Col2
preserve
keep if estperiod == 1
local testvar d1logpay
collapse (iqr) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa post, vce(robust)
restore 
esttab using "./Output/Table5_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel C: Convergence analysis 

eststo clear

* Tabel 5, Panel C, Col1 
preserve
keep if estperiod == 1
local testvar logpay
collapse (sd) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa postperiod, vce(robust)
restore 

* Tabel 5, Panel C, Col2 
preserve
keep if estperiod == 1
local testvar logpay
collapse (iqr) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa postperiod, vce(robust)
restore 
esttab using "./Output/Table5_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* AICPA MAP Survey prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Raw data import, prep, and checks

filelist, dir("./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/") pat("*.xlsx") save("./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta") replace

use "./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta", clear /*23 obs - correct*/
local obs = _N
forvalues i=1/`obs' {
	use "./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta" in `i', clear
	local f = dirname + "/" + filename
	local g = filename
	import excel "`f'", sheet("Sheet1") allstring clear
	drop if missing(A) /*drop empty columns in collection sheet*/
	drop B /*drop notes column */

	sxpose, clear /*ssc install, if required*/
	renvars , map(`=word("@", 1)') /*take the first row as variable name*/
	drop if _n == 1 /*drop empty row -- collection notes*/
	rename Variable size_class
	capture replace size_class = "single_medium_2002" if size_class == "single_medium_2004" /*correcting a labeling issues in raw files*/
	drop if missing(size_class) /*drop empty cells*/

	ds size_class, not
	foreach var in `r(varlist)' {
		gen r_`var' = real(`var')
		drop `var' 
		rename r_`var' `var'  
	}	
	gen year = substr(size_class, length(size_class) - 3, 4)
	gen size_class_temp = substr(size_class, 1, length(size_class) - 5)
	drop size_class
	rename size_class_temp size_class
	gen source = "`f'"
	gen source_file = "`g'"
	tempfile save`i'
	save "`save`i''"
}

* append all files
use "`save1'", clear
	forvalues i=2/`obs' {
    append using "`save`i''"
}
/*71 vars = 69 vars + source var + filename var --> correct*/
/*805 obs = 35 obs per state * 23 states = 805 -- > correct*/


* Introduce area fips for merging in dummy structure
replace source_file = subinstr(source_file, "StataImport_Staffing_", "", .)
replace source_file = subinstr(source_file, ".xlsx", "", .)
gen area_fips = "."
replace area_fips = "04000" if source_file == "Arizona"
replace area_fips = "06000" if source_file == "California"
replace area_fips = "08000" if source_file == "Colorado"
replace area_fips = "12000" if source_file == "Florida"
replace area_fips = "13000" if source_file == "Georgia"
replace area_fips = "17000" if source_file == "Illinois"
replace area_fips = "18000" if source_file == "Indiana"
replace area_fips = "22000" if source_file == "Louisiana"
replace area_fips = "24000" if source_file == "Maryland"
replace area_fips = "25000" if source_file == "Massachusetts"
replace area_fips = "26000" if source_file == "Michigan"
replace area_fips = "27000" if source_file == "Minnesota"
replace area_fips = "34000" if source_file == "NewJersey"
replace area_fips = "36000" if source_file == "NewYork"
replace area_fips = "37000" if source_file == "NorthCarolina"
replace area_fips = "39000" if source_file == "Ohio"
replace area_fips = "40000" if source_file == "Oklahoma"
replace area_fips = "41000" if source_file == "Oregon"
replace area_fips = "42000" if source_file == "Pennsylvania"
replace area_fips = "48000" if source_file == "Texas"
replace area_fips = "51000" if source_file == "Virginia"
replace area_fips = "53000" if source_file == "Washington"
replace area_fips = "55000" if source_file == "Wisconsin"

* year variable
capture drop r_year
gen r_year = real(year) 
drop year
rename r_year year

* save temp set
preserve


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Preparation of law dummy file (adjust to accommodate biennial structure of the MAP survey) and sample screen

* merge in adjusted dummy structure
import excel "./Data/Helper/CPAMobility_MAPSurvey_Adoption.xlsx", sheet("Mobility_Effective") firstrow clear
reshape long v_, i(effective_sequence stateicp_string stateicp stateicp_valuelabel ST STATE statefip area_fips Effective_Date) j(year)

* gen long panel variable
sort ST year

gen CPAMobility_Effec_longpanel = 0
replace CPAMobility_Effec_longpanel = 1 if v_ == 1 
sort ST year
by ST: replace CPAMobility_Effec_longpanel = 1 if  CPAMobility_Effec_longpanel[_n-1] == 1
 
* generate merge variable
gen area_fips_temp = string(area_fips)
drop area_fips
rename area_fips_temp area_fips
replace area_fips = "0" + area_fips if length(area_fips) == 4

* save dummy file
tempfile dummies
save `dummies'

* use master and merge in law dummies
restore
merge m:1 area_fips year using `dummies' /*all matched from master*/
tab STATE if _merge == 2
codebook STATE if _merge == 2 /*27 states --> correct */
keep if _merge == 3
drop _merge

* drops
drop if source_file == "Ohio"
drop if source_file == "Virginia"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prep and aux regressions 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Compensation prep

* Missing Check
foreach var of varlist comp_partner comp_director comp_sr_manager comp_manager comp_sr_associate comp_associate comp_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}
egen comp_all = rmean(comp_partner comp_director comp_sr_manager comp_manager comp_sr_associate comp_associate)
gen logcomp_all = log(comp_all)
egen comp_senior = rmean(comp_partner )
gen logcomp_senior = log(comp_senior)
egen comp_mid = rmean(comp_director comp_sr_manager comp_manager)
gen logcomp_mid = log(comp_mid)
egen comp_low = rmean(comp_sr_associate comp_associate)
gen logcomp_low = log(comp_low)

gen non_miss = 0 
replace non_miss = 1 if !missing(comp_senior) & !missing(comp_mid) & !missing(comp_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Billing rate prep

foreach var of varlist avgbill_partner avgbill_director avgbill_sr_manager avgbill_manager avgbill_sr_associate avgbill_associate avgbill_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}

* generate position partitions
egen avgbill_all = rmean( avgbill_partner avgbill_director avgbill_sr_manager avgbill_manager avgbill_sr_associate avgbill_associate)
gen logavgbill_all = log(avgbill_all)
egen avgbill_senior = rmean( avgbill_partner )
gen logavgbill_senior = log(avgbill_senior)
egen avgbill_mid = rmean( avgbill_director avgbill_sr_manager avgbill_manager)
gen logavgbill_mid = log(avgbill_mid)
egen avgbill_low = rmean( avgbill_sr_associate avgbill_associate)
gen logavgbill_low = log(avgbill_low)

gen non_miss_bill = 0 
replace non_miss_bill = 1 if !missing(avgbill_senior) & !missing(avgbill_mid) & !missing(avgbill_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Hours billed prep

foreach var of varlist avgcharg_partner avgcharg_director avgcharg_sr_manager avgcharg_manager avgcharg_sr_associate avgcharg_associate avgcharg_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}

* generate different position partitions
egen avgcharg_all = rmean( avgcharg_partner avgcharg_director avgcharg_sr_manager avgcharg_manager avgcharg_sr_associate avgcharg_associate)
gen logavgcharg_all = log(avgcharg_all)
egen avgcharg_senior = rmean( avgcharg_partner)
gen logavgcharg_senior = log(avgcharg_senior)
egen avgcharg_mid = rmean( avgcharg_director avgcharg_sr_manager avgcharg_manager)
gen logavgcharg_mid = log(avgcharg_mid)
egen avgcharg_low = rmean( avgcharg_sr_associate avgcharg_associate)
gen logavgcharg_low = log(avgcharg_low)

gen non_miss_charge = 0 
replace non_miss_charge = 1 if !missing(avgcharg_senior) & !missing(avgcharg_mid) & !missing(avgcharg_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* condition to ascertain constant estimation sample across specs
capture drop triple_condition
gen triple_condition = 0
replace triple_condition = 1 if non_miss == 1 & non_miss_bill == 1 & non_miss_charge == 1 

* gen FE
egen state_id = group(area_fips)

* Table 6, Panel B: Baseline
eststo clear		
foreach var of varlist logcomp_all avgbill_all logavgcharg_all {
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2014 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)	
}	
esttab using "./Output/Table6_PanelB.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel C: Logratio test comp
gen logseniorlow = logcomp_senior - logcomp_low
gen logseniormid = logcomp_senior - logcomp_mid
gen logmidlow = logcomp_mid - logcomp_low

eststo clear
foreach var of varlist logseniorlow logseniormid logmidlow {	
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelC.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel D: Logratio for billing rates
gen logbill_seniorlow = logavgbill_senior - logavgbill_low
gen logbill_seniormid = logavgbill_senior - logavgbill_mid
gen logbill_midlow = logavgbill_mid - logavgbill_low


eststo clear
foreach var of varlist logbill_seniorlow logbill_seniormid logbill_midlow {	
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelD.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel E: Logratios for hours 
gen loghour_seniorlow = logavgcharg_senior - logavgcharg_low
gen loghour_seniormid = logavgcharg_senior - logavgcharg_mid
gen loghour_midlow = logavgcharg_mid - logavgcharg_low

eststo clear
foreach var of varlist loghour_seniorlow loghour_seniormid loghour_midlow {
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelE.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel A: Descriptive stats 

* compensation
tabstat comp_all logcomp_all comp_senior comp_mid comp_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* billing rates
tabstat avgbill_all avgbill_senior avgbill_mid avgbill_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* hours charged 
tabstat avgcharg_all logavgcharg_all avgcharg_senior avgcharg_mid avgcharg_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Pension plan prep and analysis 

* File Structure:
* Require three IRS forms: Form 5500 for the plan information, Schedule H for the auditor EIN, and Schedule C for audit fees.
* File imports are split into a 2003-2008 part and 2009-2015 part. Import is split to accommodate file format differences. 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Imports and merges

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* 2003 to 2008 files


******************************************************************************************************************************************************************************
* Extract auditor and financial info from Schedule H 
 
forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_H_`i'.csv",  encoding(ISO-8859-1) clear 
	keep filing_id accountant_firm_name accountant_firm_ein acct_performed_ltd_audit_ind acct_opin_not_on_file_ind acctnt_opinion_type_ind /*controls:*/ joint_venture_boy_amt real_estate_boy_amt tot_assets_boy_amt tot_liabilities_boy_amt tot_contrib_amt professional_fees_amt contract_admin_fees_amt invst_mgmt_fees_amt other_admin_fees_amt tot_admin_expenses_amt aggregate_proceeds_amt net_income_amt
	drop if missing(accountant_firm_ein) 
	tostring accountant_firm_ein, replace /*convert to string for consistency across files and years*/
	tostring net_income_amt, replace force 
	gen year = `i'
	tempfile temp`i'
	save `temp`i''
}
use `temp2003', clear
forvalues i = 2004/2008{
	append using `temp`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0308.dta", replace 

******************************************************************************************************************************************************************************
* Extract fees from Schedule C Part 1

forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_C_PART1_`i'.csv", encoding(ISO-8859-1) clear 
	drop if missing(provider_01_ein)
	tostring provider_01_ein, replace
	tostring provider_01_srvc_code, replace
	gen year = `i'
	tempfile temp2`i'
	save `temp2`i''
}
use `temp22003', clear
forvalues i = 2004/2008{
	append using `temp2`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0308.dta", replace 


******************************************************************************************************************************************************************************
* Merge Schedule H and Schedule C

use "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0308.dta", clear
gen provider_01_ein = accountant_firm_ein /*adjust for merge*/
duplicates tag filing_id provider_01_ein year, gen(dupl)
duplicates drop filing_id provider_01_ein year, force /*5 true duplicates*/
merge 1:m filing_id provider_01_ein year using "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0308.dta"
keep if _merge == 3
drop _merge 

* keep only main service provider role
capture drop dupl
duplicates tag filing_id year, gen(dupl)
tab dupl
sort filing_id year
* browse if dupl > 0 /*Only keep the main service--that is, audit not preparation*/
capture drop dupl
duplicates tag filing_id year row_num, gen(dupl) 
tab dupl 
sort filing_id year row_num 
by filing_id year: gen counter = _n 
keep if counter == 1 /*keep main role*/
drop counter 

* save merged file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0308.dta", replace 


******************************************************************************************************************************************************************************
* Extract location and other plan info from Form 5500

forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/f_5500_`i'.csv", encoding(ISO-8859-1) clear
	* keep location and info for controls
	keep filing_id spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state preparer_name preparer_ein preparer_city preparer_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt
	* Convert the variables to strings except for filing id for merges and consistency
	foreach var of varlist spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state preparer_name preparer_ein preparer_city preparer_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt {
		capture tostring `var', replace 
	}

	gen year = `i'
	tempfile temp3`i'
	save `temp3`i''
}

use `temp32003', clear
forvalues i = 2004/2008{
	append using `temp3`i''
}

* save file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0308.dta", replace 

******************************************************************************************************************************************************************************
* Merge Form 5500 with merged auditor and fee File (Schedules H and C, merged above)

use "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0308.dta", clear 
merge m:1 filing_id year using "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0308.dta"
keep if _merge == 3 
drop _merge

* drop vars no longer needed and save merged file for handling
capture drop dupl image_form_id	page_id	page_row_num page_seq row_num
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* 2009 to 2015 files

******************************************************************************************************************************************************************************
* Extract Auditor and financial info from Schedule H

forvalues i = 2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_H_`i'_latest.csv", encoding(ISO-8859-1) clear
	keep ack_id accountant_firm_name accountant_firm_ein acct_performed_ltd_audit_ind acct_opin_not_on_file_ind acctnt_opinion_type_cd /*controls:*/ joint_venture_boy_amt real_estate_boy_amt tot_assets_boy_amt tot_liabilities_boy_amt tot_contrib_amt professional_fees_amt contract_admin_fees_amt invst_mgmt_fees_amt other_admin_fees_amt tot_admin_expenses_amt aggregate_proceeds_amt net_income_amt
	rename acctnt_opinion_type_cd acctnt_opinion_type_ind /*rename the only one that is not consistent other than the identifier*/
	drop if missing(accountant_firm_ein) 
	tostring accountant_firm_ein, replace /*align format*/
    tostring net_income_amt, replace force /*align format*/
	gen year = `i'
	tempfile temp`i'
	save `temp`i''
}

use `temp2009', clear
forvalues i = 2010/2015{
	append using `temp`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0915.dta", replace 


******************************************************************************************************************************************************************************
* Extract fees from Schedule C Part 1

forvalues i=2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_C_PART1_ITEM2_`i'_latest.csv", encoding(ISO-8859-1) clear
	* drop the following that cannot be obtained in prior files 
	drop prov_other_foreign_address1 prov_other_foreign_address2 prov_other_foreign_city prov_other_foreign_prov_state prov_other_foreign_cntry prov_other_foreign_postal_cd
	
	* rename the variables to correspond with the 2003-2008 file (imported above)
	rename provider_other_name provider_01_name 
	rename provider_other_ein provider_01_ein
	gen provider_01_position = "" /*does not exist in the 09 and onwards file*/
	rename provider_other_relation provider_01_relation
	rename prov_other_tot_ind_comp_amt provider_01_salary_amt
	rename provider_other_direct_comp_amt provider_01_fees_amt
	gen provider_01_srvc_code = "." /*converted to string in earlier import*/
	drop provider_other_amt_formula_ind
	drop prov_other_elig_ind_comp_ind 
	drop prov_other_indirect_comp_ind

	* convert the service provider ein to string variable for consistency with 2003-2008 file
	* also have to rename the variable to correspond to the id in the merging file 
	tostring provider_01_ein, replace
	tostring provider_01_srvc_code, replace
	
	* gen year and tempfile
	gen year = `i'
	tempfile temp2`i'
	save `temp2`i''
}

use `temp22009', clear
forvalues i = 2010/2015{
	append using `temp2`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0915.dta", replace 


******************************************************************************************************************************************************************************
* Merge Schedule H and Schedule C

use "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0915.dta", clear
gen provider_01_ein = accountant_firm_ein /*this needs to be the same in the files*/
duplicates tag ack_id provider_01_ein year, gen(dupl)
tab dupl /*no duplicates here*/
drop dupl 
capture duplicates drop ack_id provider_01_ein year, force /* no obs deleted*/

merge 1:m ack_id provider_01_ein year using "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0915.dta" 

* as before, missing are the ones with below threshold or missing auditor ein info, drop
keep if _merge == 3
drop _merge 

* check and inspect duplicates
capture drop dupl
duplicates tag ack_id year, gen(dupl)
tab dupl

* keep main function only (see 2003-2008 import)
* browse if dupl > 0 
sort ack_id year row_order
by ack_id year: gen counter = _n 
keep if counter == 1 
drop counter   

capture drop dupl
duplicates tag ack_id year, gen(dupl)
tab dupl /*de-duplicated*/
drop dupl

* drop row_order for file concistency with 2003-2008 imports
drop row_order 

* save merged file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0915.dta", replace 


******************************************************************************************************************************************************************************
* Extract location and other plan info from Form 5500

forvalues i=2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/f_5500_`i'_latest.csv", encoding(ISO-8859-1) clear
	
	* renaming and format adjustment for consistency with 2003-2008 import
	rename spons_dfe_mail_us_city spons_dfe_city
	rename spons_dfe_mail_us_state spons_dfe_state
	rename admin_us_city admin_city
	rename admin_us_state admin_state
	rename type_plan_entity_cd type_plan_entity_ind 
	rename type_dfe_plan_entity_cd type_dfe_plan_entity

	keep ack_id spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt
	
	foreach var of varlist spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt {
		capture tostring `var', replace 
	}

	gen year = `i'
	tempfile temp3`i'
	save `temp3`i''
}

use `temp32009', clear
forvalues i = 2010/2015{
	append using `temp3`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0915.dta", replace 


******************************************************************************************************************************************************************************
* Merge Form 5500 with merged auditor and fee file (Schedules H and C, merged above)

* earlier file 
use "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0915.dta", clear 
merge m:1 ack_id year using "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0915.dta" /*all merged*/
keep if _merge == 3 
capture drop _merge

* save complete 09-15 file 
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta", replace




******************************************************************************************************************************************************************************
* Append 03-08 file with 09-15 file

/*
* manual check on import -- all var names in order and same across file? yes
use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", clear
capture drop dupl image_form_id	page_id	page_row_num page_seq row_num
order _all, alpha
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", replace 

* same for the later file 
use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta", clear
order _all, alpha
*/ 

use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", clear
append using "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta"


******************************************************************************************************************************************************************************
* Checks on file structure and drop true duplicates

* multiple entries by plan (number):
duplicates drop spons_dfe_ein year spons_dfe_pn, force /*clean dupl based on plan numbers--manual check via DOL: true duplicates!*/

******************************************************************************************************************************************************************************
* Treatments

gen state = spons_dfe_state 
drop if missing(state) /*required for merge*/

capture drop L1_CPAMobility_Effec_longpanel 
capture drop STUSPS
preserve
use "./Data/Helper/LawDummiesPensionPlans.dta", clear
keep L1_CPAMobility_Effec_longpanel year STUSPS
rename STUSPS state /*state is US postal to allow for merges*/
tempfile lawdummies
save `lawdummies'
restore 
merge m:1 state year using `lawdummies'
keep if _merge == 3
drop _merge 


******************************************************************************************************************************************************************************
* Generate response

* the fees are disclosed as one or the other. checked against DOL plan lookup
replace provider_01_salary_amt = 0 if missing(provider_01_salary_amt)
replace provider_01_fees_amt = 0 if missing(provider_01_fees_amt)
gen fees = provider_01_fees_amt + provider_01_salary_amt

winsor2 fees, suffix(_w) cuts(1 99)
gen logfees = log(fees)
winsor2 logfees, suffix(_w) cuts(1 99)

******************************************************************************************************************************************************************************
* Generate controls

* size: assets
gen logassets = log(tot_assets_boy_amt)
winsor2 logassets, suffix(_w) cuts (1 99)

* contribution to assets
gen contribution2assets = tot_contrib_amt / tot_assets_boy_amt
winsor2 contribution2assets, suffix(_w) cuts(1 99)

* participants to assets
destring tot_partcp_boy_cnt, replace /*to-string before for consistency*/
gen participants2assets = tot_partcp_boy_cnt / tot_assets_boy_amt
winsor2 participants2assets, suffix(_w) cuts(1 99)

* hardtoaudit
replace joint_venture_boy_amt = 0 if missing(joint_venture_boy_amt) /*true zeros according to DoL plan lookup*/
replace real_estate_boy_amt = 0 if missing(real_estate_boy_amt) /*true zeros according to DoL plan lookup*/
gen hardtoaudit = (joint_venture_boy_amt + real_estate_boy_amt) / tot_assets_boy_amt
winsor2 hardtoaudit, suffix(_w) cuts(1 99)

* investment mgmt fees
gen investfees2assets = invst_mgmt_fees_amt / tot_assets_boy_amt
winsor2 investfees2assets, suffix(_w) cuts(1 99)

* profitibality
destring net_income_amt, gen(netincome)  
gen income2assets = netincome / tot_assets_boy_amt
winsor2 income2assets, suffix(_w) cuts(1 99)

* limited 
gen limited = (acct_performed_ltd_audit_ind == 1)

* Big 4 (raw)
gen big4 = 0
gen auditor_name = lower(accountant_firm_name)
replace big4 = 1 if strpos(auditor_name, "kpmg")
replace big4 = 1 if strpos(auditor_name, "price")
replace big4 = 1 if strpos(auditor_name, "deloit")
replace big4 = 1 if strpos(auditor_name, "ernst")

* adjust Big4 -- recursive approach: min type 1 / 2 error 
tab auditor_name if strpos(auditor_name, "kpmg") 
tab auditor_name if strpos(auditor_name, "price")
replace big4 = 0 if strpos(auditor_name, "price")
replace big4 = 1 if strpos(auditor_name, "price") & strpos(auditor_name, "waterhouse")
tab auditor_name if strpos(auditor_name, "price") & strpos(auditor_name, "waterhouse")
tab auditor_name if strpos(auditor_name, "deloit") 
tab auditor_name if strpos(auditor_name, "ernst") 
replace big4 = 0 if strpos(auditor_name, "ernst")
replace big4 = 1 if strpos(auditor_name, "ernst") & strpos(auditor_name, "young")
tab auditor_name if strpos(auditor_name, "ernst") & strpos(auditor_name, "young")

* add national audit firms -- based on statista -- top 10 audit firms -- string searches based on recursive process with min type 1 / 2 error (as before)
gen national = 0
replace national = 1 if big4 ==1
replace national = 1 if strpos(auditor_name, "rsm")
replace national = 1 if strpos(auditor_name, "thornton")
replace national = 1 if strpos(auditor_name, "bdo")
replace national = 1 if strpos(auditor_name, "clifton")
replace national = 1 if strpos(auditor_name, "mayer") & strpos(auditor_name, "hoffman")
replace national = 1 if strpos(auditor_name, "crowe")

* non Big 4
gen nonbig4 = (big4 == 0)

******************************************************************************************************************************************************************************
* FEs
capture egen state_id = group(state)
capture egen state_year_id = group(state year)
capture egen state_nonbig4_id = group(state nonbig4)
capture egen state_complex_id = group(state complex)
capture egen sponsor_id = group(spons_dfe_ein)
capture egen plan_id = group(spons_dfe_ein spons_dfe_pn)
capture egen auditfirm_id = group(accountant_firm_ein)

******************************************************************************************************************************************************************************
* Sample restriction and check

gen OHVA = (state == "OH" | state == "VA")

* duplicate check
sort spons_dfe_ein spons_dfe_pn year 
duplicates tag spons_dfe_ein spons_dfe_pn year, gen(dupl) 
assert dupl == 0
drop dupl 

* Impose sample restriction
drop if OHVA == 1 
drop if limited == 0  

* Define controls and easy-to-handle treatment
global controls contribution2assets_w  income2assets_w  hardtoaudit_w  logassets_w investfees2assets_w participants2assets_w
gen CPAMob = L1_CPAMobility_Effec_longpanel

******************************************************************************************************************************************************************************
* gen FEs 

capture gen small = (national == 0)
capture gen big = (national == 1)
capture gen CPAMob_small = small * CPAMob
capture gen CPAMob_big = big * CPAMob
capture egen state_national_id = group(state national)
capture egen national_year_id = group(national year)
capture egen state_national_year_id = group(state national year)
capture egen auditfirm_state_id = group(auditfirm state)

******************************************************************************************************************************************************************************
* Collapse regression to have at least a minimum level of obs per state-firmsize-year cell to estimate the full model

preserve
reghdfe logfees_w ${controls}, a(state_national_year_id auditfirm_state_id, savefe)
gen includedobs = (e(sample) == 1)
rename __hdfe1__ state_national_year_fees
collapse state_national_year_fees CPAMob* national (sum) includedobs, by(state_national_year_id state_national_id state_id state year)

keep if includedobs >= 5 /*minimum level of obs to identify groups*/

bysort state_id: egen stateyears = count(state_national_year_fees)
keep if stateyears == 26 /*time-group balancing*/
keep state_national_year_id stateyears
tempfile national
save `national'
restore
capture drop _merge 
merge m:1 state_national_year_id using `national'
rename _merge nationalbalancedstate


******************************************************************************************************************************************************************************
* Run models one by one to hold estimation sample constant across specifications 

capture drop inclreg*
qui reghdfe logfees_w CPAMob ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) /*2.3% decline*/
gen inclreg1 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob ${controls} if national == 1 & nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) 
gen inclreg2 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob ${controls} if national == 0 & nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) 
gen inclreg3 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob_small CPAMob_big ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id national_year_id) cluster(state_id) 
gen inclreg4 = (e(sample) == 1)
gen inclreg = (inclreg1 == 1 & (inclreg2 == 1 | inclreg3 == 1) & inclreg4 == 1)

******************************************************************************************************************************************************************************
* Estimate model on sample meeting all requirements

preserve 
keep if inclreg == 1

* Table 7, Panel B: Pension plan audit fee response 
eststo clear 
eststo: reghdfe logfees_w CPAMob ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id)
eststo: reghdfe logfees_w CPAMob_small CPAMob_big ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id national_year_id) cluster(state_id) 
test CPAMob_small CPAMob_big
esttab using "./Output/Table7_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Table 7, Panel A: Desc stats 
tabstat fees_w logfees_w ${controls} national if nationalbalancedstate == 3, s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

restore



******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* AICPA Misconduct prep and analysis 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import data received from Armitage and Moriarity (28 June 2017) and prep

* import
import excel "./Data/Quality/AICPA_Notification/Complete Data Set Disciplinary Sanctions_1999-2015.xlsx", sheet("Sheet1") firstrow clear
rename Year year
drop if year < 2003
tab year

* restriction following Armitage and Moriarity
drop if NatureofAct == "F to meet CPE requirement" 
drop if TypeofAct == "F to meet CPE requirement" 
drop if TypeofAct == "Crime" 

* gen temp variable for counting cases
gen case_count = 1

* generate temp variable for counting cases by severity
gen admonished_count = .
replace admonished_count = 1 if case_count == 1 & Outcome == "admonished"
gen suspended_count = 0
replace suspended_count = 1 if case_count == 1 & Outcome == "suspended"
gen terminated_count = 0
replace terminated_count = 1 if case_count == 1 & Outcome == "terminated"

gen total_count = .
replace total_count = 1 if admonished_count == 1
replace total_count = 1 if suspended_count == 1
replace total_count = 1 if terminated_count == 1

* weighted counted to align with EBSA analysis 
gen weighted_count = total_count
replace weighted_count = 1 if admonished_count == 1 
replace weighted_count = 2 if suspended_count == 1
replace weighted_count = 3 if terminated_count == 1 

* collapse case data to state-year panel
collapse (sum) admonished_count (sum) suspended_count (sum) terminated_count (sum) total_count (sum) weighted_count, by(State year) 
rename State ST

* save interim data
tempfile aicpa_misc
save `aicpa_misc'

* merging into a frame to capture true zeros
use "./Data/Helper/LawDummiesAICPAMisconduct.dta", clear
merge 1:1 ST year using `aicpa_misc'

* browse if _merge == 2 /*Note: these are out of sample cases ,e.g., the Al cases from Alberta, Canada*/
drop if _merge ==2

* fill in missing variables -- "true" zeros
foreach var of varlist admonished_count suspended_count terminated_count total_count weighted_count {
	replace `var' = 0 if missing(`var')
}

* drop states not in main analyses for consistency
drop if ST == "HI"
drop if ST == "PR"
drop if ST == "OH"
drop if ST == "VA"
drop if year < 2003

* Prep FEs
egen state_id = group(STATE)
xtset state_id year, yearly


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* Total count check-reg to ascertain Poisson can be run (min counts)
qui xtpoisson total_count L1_CPAMobility_Effec_longpanel i.year, fe i(state_id) vce(robust) 
gen estsample = (e(sample) == 1) 

* Table 8, Panel A: AICPA Misconduct 

* Total count spec (Poisson and OLS)
eststo clear
qui eststo: reghdfe total_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(year) cluster(state_id)
qui eststo: reghdfe total_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(state_id year) cluster(state_id)
qui eststo: xtpoisson total_count L1_CPAMobility_Effec_longpanel if estsample == 1, fe i(year) vce(robust) /*vce(robust) with specified panel id clusters standard error on the panel id level in xtpoisson (Stata default)*/
qui eststo: xtpoisson total_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, fe i(state_id) vce(robust) 
qui eststo: reghdfe weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(year) cluster(state_id)
qui eststo: reghdfe weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(state_id year) cluster(state_id)
qui eststo: xtpoisson weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, fe i(year) 
qui eststo: xtpoisson weighted_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, fe i(state_id) 
estout, keep(L1_CPAMobility_Effec_longpanel) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelA.csv", keep(L1_CPAMobility_Effec_longpanel) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace 

* Re-est Poisson spec for R-Sq output (not displayed in xtpossion, which is needed for standard error clustering) 
eststo clear
qui eststo: poisson total_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, vce(robust) 
qui eststo: poisson total_count L1_CPAMobility_Effec_longpanel i.year i.state_id if estsample == 1, vce(robust) 
qui eststo: poisson weighted_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, vce(robust) 
qui eststo: poisson weighted_count L1_CPAMobility_Effec_longpanel i.year i.state_id if estsample == 1, vce(robust) 
estout, keep(L1_CPAMobility_Effec_longpanel) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelA_R-Squared.csv", keep(L1_CPAMobility_Effec_longpanel) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* EBSA Deficient Filer prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and prep 

* Import raw data from DoL
import delimited "./Data/Quality/Data_EBSA_Form5500_Enforcement/ebsa_ocats.csv", encoding(ISO-8859-1)clear

* sample restriction to align with main analyses
drop if plan_admin_state == " "
drop if plan_admin_state == "Ohio"
drop if plan_admin_state == "Virginia"
drop if plan_admin_state == "Hawaii"
drop if plan_admin_state == "Puerto Rico"
rename plan_admin_state state

* prepare year variable
gen year = substr(final_close_date, 1, 4)
destring year, replace 
tab year
drop if year < 2003
drop if year > 2015

* restrict to deficient filers only
keep if case_type == "Deficient Filer"

* generate severity groups as well as a total in line with AICPA Misconduct Analysis
gen sevclass_1 = (penalty_amount == "$0-$10,000")
gen sevclass_2 = (penalty_amount == "$10,001 - $50,000")
gen sevclass_3 = (penalty_amount == "$50,001 - $100,000") 
gen sevclass_4 = (penalty_amount == "over $100,000")

* collapse to casecounts 
preserve
collapse (count) casecount_total=pn, by(state year) /*just count the number of incidents per state and year*/
tempfile ebsa_total
save `ebsa_total'
restore 

* collapse by sev class 
forvalues i=1/4{
	preserve
	keep if sevclass_`i' == 1
	collapse (count) casecount_`i' = pn, by(state year)
	tempfile ebsa_`i'
	save `ebsa_`i''
	restore 
}

* build frame to account for true zeros and generate treatment dummies
import excel "./Data/Helper/DataCollectionFrame.xls", sheet("Sheet1") firstrow clear
rename State state
keep state adoption_year
bysort state: keep if _n == 1 /*start with a cross section of sample states and build frame*/
expand 13
bysort state: gen year = 2002 + _n

* gen the treatment
gen CPAMob = (year - adoption_year >=0)
gen L1_CPAMob = (year - adoption_year > 0) /*here the name is Dist of Columbia - in merge file the state is named*/
replace state = "District of Columbia" if state == "Dist. of Columbia"

* merge with total file 
merge 1:1 state year using `ebsa_total' /*zero from using --> correct*/
replace casecount_total = 0 if _merge == 1 
drop _merge

* merge with the severity files
forvalues i=1/4{
	merge 1:1 state year using `ebsa_`i''
	assert _merge != 2 
	replace casecount_`i' = 0 if _merge == 1
	drop _merge
}

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Outcome prep, control prep, and analysis

******************************************************************************************************************************************************************************
* Prep FEs and set data
egen state_id = group(state)
xtset state_id year, yearly

******************************************************************************************************************************************************************************
* Prep severity weighting aligned with AICPA Misconduct Analysis (Table 8, Panel A)

gen casecount_weighted = casecount_1 * 1 + casecount_2 * 2 + casecount_3 * 3 + casecount_4 * 4

******************************************************************************************************************************************************************************
* Regression analysis

* Table 8, Panel B: EBSA Deficient Filer Cases

eststo clear
qui eststo: reghdfe casecount_total L1_CPAMob, a(year) cluster(state_id)
qui eststo: reghdfe casecount_total L1_CPAMob, a(year state_id) cluster(state_id)
qui eststo: xtpoisson casecount_total L1_CPAMob , fe i(year) vce(robust) /*vce(robust) with specified panel id clusters standard error on the panel id level (Stata default)*/
qui eststo: xtpoisson casecount_total L1_CPAMob i.year, fe i(state_id) vce(robust) 
qui eststo: reghdfe casecount_weighted L1_CPAMob, a(year) cluster(state_id)
qui eststo: reghdfe casecount_weighted L1_CPAMob, a(year state_id) cluster(state_id)
qui eststo: xtpoisson casecount_weighted L1_CPAMob, fe i(year) vce(robust) 
qui eststo: xtpoisson casecount_weighted L1_CPAMob i.year, fe i(state_id) vce(robust)
estout, keep(L1_CPAMob) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelB.csv", keep(L1_CPAMob) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace 


* Re-est Poisson spec for R-Sq output (not displayed in xtpossion, which is needed for standard error clustering)
eststo clear 
qui eststo: poisson casecount_total L1_CPAMob i.year, vce(robust) 
qui eststo: poisson casecount_total L1_CPAMob i.year i.state_id, vce(robust) 
qui eststo: poisson casecount_weighted L1_CPAMob i.year, vce(robust) 
qui eststo: poisson casecount_weighted L1_CPAMob i.year i.state_id, vce(robust)
estout, keep(L1_CPAMob) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelB_R-Squared.csv", keep(L1_CPAMob) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace 
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* CO CPA Disciplinary Actions prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and prep

******************************************************************************************************************************************************************************
* Import raw data

import delimited "./Data/Quality/CO_Quality/FRM_-_Public_Accounting_Firm_-_All_Statuses.csv", encoding(ISO-8859-1) stringc(_all) clear /*Downloaded data on 31 August 2019*/

******************************************************************************************************************************************************************************
* Clean Data: Keep only vars needed, entry and exit dates 

* keep variables of interest
keep formattedname state mailzipcode licensetype licensenumber licensefirstissuedate licenselastreneweddate licenseexpirationdate ///
	licensestatusdescription casenumber programaction disciplineeffectivedate disciplinecompletedate /*v29 empty due to csv format*/

* gen entry 
gen firmentryyear = substr(licensefirstissuedate, -4, 4)
destring firmentryyear, replace
drop if missing(firmentryyear) 

* gen exit
gen firmexityear = substr(licenseexpirationdate, -4, 4)
destring firmexityear, replace
drop if missing(firmexityear)

* align licensenumber (all 7 digits)
destring licensenumber, replace 
gen firmlicensenumber = string(licensenumber,"%07.0f")
replace firmlicensenumber = "FRM." + firmlicensenumber 

******************************************************************************************************************************************************************************
* Create tempfile that only holds discplinary actions

preserve

* keep only disciplinary actions
keep if !missing(casenumber)

* gen caseyear
gen caseyear = substr(casenumber, 1, 4)
destring caseyear, replace force
browse if missing(caseyear)
replace caseyear = 2006 if missing(caseyear) /*manually checked these individuals*/

* gen effectiveyear
gen caseeffectiveyear = substr(disciplineeffectivedate, -4,4)
destring caseeffectiveyear, replace /*here all good*/

* check for duplicates in the file
duplicates tag firmlicensenumber caseyear, gen(dupl1)
sort firmlicensenumber caseyear 
browse if dupl1 > 0 /*true duplicates --> remove*/
duplicates drop firmlicensenumber caseyear, force

* keep vars needed for tempfile
keep firmlicensenumber caseyear disciplineeffectivedate casenumber programaction disciplineeffectivedate disciplinecompletedate

* gen year for merging 
gen year = caseyear /*year of the actual violation is what is needed*/

* save tempfile 
tempfile codisc
save `codisc'


******************************************************************************************************************************************************************************
* Reload main file, drop disc action (--> drop duplicates), convert to panel, and merge in disc actions

restore

* drop the disc actions, which are now stored in the tempfile
drop casenumber programaction disciplineeffectivedate disciplinecompletedate 

* drop duplicates (these are coming from disc ations --> taken care of via storing this info in temp file)
duplicates drop firmlicensenumber, force

* convert to panel structure
gen expander = firmexityear - firmentryyear + 1
expand expander
bysort firmlicensenumber: gen sequence = _n - 1
gen year = firmentryyear + sequence

* merge in disc ations and gen outcome
merge 1:1 firmlicensenumber year using `codisc'
drop if _merge == 2
gen discipline = (_merge == 3)
drop _merge

******************************************************************************************************************************************************************************
* Sample restriction, age partition, reg prep

* restriction
keep if year >= 2003 & year <= 2015
keep if firmentryyear <= 2007 /*keep only firms active prior to treatment*/
keep if state == "CO"

* partition on Age
preserve
keep if year == 2007 
egen agequantile = xtile(firmentryyear), n(2)
keep firmlicensenumber agequantile
tempfile age
save `age'
restore
capture drop agequantile
merge m:1 firmlicensenumber using `age'

* gen split variables
gen old = (agequantile == 1)
gen young = (agequantile == 2)

* gen treatment and FEs
capture egen firm_id = group(firmlicensenumber)
capture gen L1_CPAMob_young = (year >= 2009 & young == 1)

* sample inclusion variable
capture gen oldyoung = (old == 1 | young == 1)


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* Table 8, Panel C: CPA Mobility and Discplinary Actions in Colorado
eststo clear
eststo: reghdfe discipline L1_CPAMob_young if oldyoung == 1, a(young year) cluster(firm_id)
eststo: reghdfe discipline L1_CPAMob_young if oldyoung == 1, a(firm_id year) cluster(firm_id)
esttab using "./Output/Table8_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

capture gen cpa = (industry_code == "541211")
capture gen timediff = effectiveyear - year
capture drop reltime*

gen reltimeleadlarger3 = (timediff > 3) /*before*/
label variable reltimeleadlarger3 "t≤-4"
gen reltimeleadlarger3_cpa = reltimeleadlarger3 * cpa /*before*/
label variable reltimeleadlarger3_cpa "t≤-4"

gen reltimelead3 = (timediff == 3) /*before*/
label variable reltimelead3 "t-3"
gen reltimelead3_cpa = reltimelead3 * cpa /*before*/
label variable reltimelead3_cpa "t-3"

gen reltimelead2 = (timediff == 2) /*before*/
label variable reltimelead2 "t-2"
gen reltimelead2_cpa = reltimelead2 * cpa /*before*/
label variable reltimelead2_cpa "t-2"

gen reltimelead1 = (timediff == 1) /*before*/
label variable reltimelead1 "t-1"
gen reltimelead1_cpa = reltimelead1 * cpa /*before*/
label variable reltimelead1_cpa "t-1"

gen reltime0 = (timediff == 0)
label variable reltime0 "t=0"
gen reltime0_cpa = reltime0 * cpa
label variable reltime0_cpa "t=0"

gen reltimelag1 = (timediff == -1) /*after*/
label variable reltimelag1 "t+1"
gen reltimelag1_cpa = reltimelag1 * cpa /*after*/
label variable reltimelag1_cpa "t+1"

gen reltimelag2 = (timediff == -2) /*after*/
label variable reltimelag2 "t+2"
gen reltimelag2_cpa = reltimelag2 * cpa /*after*/
label variable reltimelag2_cpa "t+2"

gen reltimelag3 = (timediff == -3) /*after*/
label variable reltimelag3 "t+3"
gen reltimelag3_cpa = reltimelag3 * cpa /*after*/
label variable reltimelag3_cpa "t+3"

gen reltimelaglarger3 = (timediff < -3) /*after*/
label variable reltimelaglarger3 "t≥4"
gen reltimelaglarger3_cpa = reltimelaglarger3 * cpa  /*after*/
label variable reltimelaglarger3_cpa "t≥4"
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
***                                                                                                                                              						   ***
***                                                                                                                                              						   ***
***                                                                                                       																   ***
*** Article: 		Labor Market Effects of Spatial Licensing Requirements: Evidence from CPA Mobility    																   ***
*** Authors: 		Stefano Cascino, Ane Tamayo, and Felix Vetter                                         																   ***
*** Journal:		Journal of Accounting Research                                                        																   ***
***                                                                                                    	  																   ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.          																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************

******************************************************************************************************************************************************************************
* 0. CD to folder

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
* 1. Preparation controls used in multiple analyses

do "./Dofiles/01_CPAMob_ControlsPrep.do"

******************************************************************************************************************************************************************************
* 2. Law prediction

do "./Dofiles/02_CPAMob_AdoptionPrediction.do" 

******************************************************************************************************************************************************************************
* 3. QCEW state-level

do "./Dofiles/03_CPAMob_QCEW_State.do"

******************************************************************************************************************************************************************************
* 4. SUSB state-level

do "./Dofiles/04_CPAMob_SUSB_State.do"

******************************************************************************************************************************************************************************
* 5. QCEW county-level 

do "./Dofiles/05_CPAMob_QCEW_BorderCounty.do"

******************************************************************************************************************************************************************************
* 6. QCEW MSA-level

do "./Dofiles/06_CPAMob_QCEW_MSA.do"

******************************************************************************************************************************************************************************
* 7. AICPA MAP Survey

do "./Dofiles/07_CPAMob_AICPAMap.do"

******************************************************************************************************************************************************************************
* 8. Pension plan fees 

do "./Dofiles/08_CPAMob_PensionPlanFees.do"

******************************************************************************************************************************************************************************
* 9. AICPA Misconduct

do "./Dofiles/09_CPAMob_Qual1_AICPAMisconduct.do"

******************************************************************************************************************************************************************************
* 10. EBSA enforcement 

do "./Dofiles/10_CPAMob_Qual2_EBSA.do"

******************************************************************************************************************************************************************************
* 11. Disciplinary actions

do "./Dofiles/11_CPAMob_Qual3_CODiscAction.do"******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prep controls used in multiple analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
* GDP  

import excel "./Data/Controls/BEA_GDPbyState_clear.xls", sheet("Sheet0") firstrow clear
* rename from label 
foreach v of varlist C-W {
   local x : variable label `v'
   rename `v' gdp`x'
}
* reshape 
reshape long gdp, i(GeoFips GeoName) j(year)

* rename for consistency 
rename GeoFips area_fips

tempfile gdp
save `gdp'

******************************************************************************************************************************************************************************
* Unemployment 

import excel "./Data/Controls/UnemploymentState_cleanforimport.xlsx", sheet("Sheet1") firstrow clear
keep statefips year unemployment_peroflabor
keep if strlen(statefips) == 2
destring year, replace 
rename statefips area_fips 
replace area_fips = area_fips + "000"
rename unemployment_peroflabor unemp

******************************************************************************************************************************************************************************
* Merge macro files and generate lags 

* merge the two 
merge 1:1 area_fips year using `gdp'
keep if _merge == 3
drop _merge 
tab year

* introduce lag
replace year = year + 1
tab year 
rename gdp L1_gdp 
rename unemp L1_unemp 

* save tempfile
tempfile macrocontrols
save `macrocontrols'

******************************************************************************************************************************************************************************
* Migration controls (raw data obtained via IPUMS ACS)

use "./Data/Controls/Data_ExtendedControls/usa_00015.dta", clear /*downloaded IPUMS file*/

* housekeeping for var names
tostring statefip, gen(area_fips)
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000"

* gen variables of interest 
gen betweenstatemigration = (migrate1 == 3)
gen abroadmigration = (migrate1 == 4)

* collapse to panel structure 
collapse abroadmigration betweenstatemigration, by(area_fips year)

* gen lags
replace year = year + 1
rename abroadmigration L1_abroadmigration 
rename betweenstatemigration L1_betweenstatemigration

******************************************************************************************************************************************************************************
* Merge control files and save 

* merge migration and macro 
merge 1:1 area_fips year using `macrocontrols'
keep if _merge == 3
drop _merge 

* save new control file 
save "./Data/Controls/extendedstatecontrols.dta", replace







******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prepare law adoption file and analysis 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Data imports and preparation

******************************************************************************************************************************************************************************
* Import laws passed (hand collected, source: http://knowledgecenter.csg.org/kc/category/content-type/bos-archive)

import excel "./Data/LawPrediction/LawsByState.xls", sheet("Sheet1") firstrow clear
drop if State =="Dist. of Columbia" /*no available data*/

******************************************************************************************************************************************************************************
* Merge in FIPS indentifiers 

rename Year year
preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear 
keep State year area_fips lq_annual_avg_emplvl
tempfile merger 
save `merger'

restore 
capture drop _merge 
merge 1:1 State year using `merger'
keep if _merge == 3 /*all merged from master*/

******************************************************************************************************************************************************************************
* Merge in macro controls

capture drop _merge
merge 1:1 area_fips year using "./Data/LawPrediction/macrocontrols.dta"
keep if _merge == 3  /*all from master are merged*/
drop _merge  

******************************************************************************************************************************************************************************
* Merge in BDS

preserve
import delimited "./Data/LawPrediction/Data_BDS/bds_e_st_release.csv", encoding(ISO-8859-1)clear
gen firm_birth = estabs_entry / estabs
gen jobcreation_netbirth = net_job_creation_rate
xtset state year2, yearly
foreach var of varlist firm_birth jobcreation_netbirth {
	gen L1_`var' = L.`var'

}
keep if year >= 2003 & year <= 2015
keep state year2 firm_birth jobcreation_netbirth L1_*
* prep for merge
tostring state, gen(area_fips)
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000" 
drop state 
rename year2 year
tempfile bds
save `bds'

restore 
merge 1:1 area_fips year using `bds'
assert _merge != 1 
keep if _merge == 3
drop _merge

******************************************************************************************************************************************************************************
* Merge in political economy predictors

preserve
import excel "./Data/LawPrediction/CPAMob_PoliticalEconomy.xlsx", sheet("Sheet1") firstrow clear
drop K L M N O P Q /*drop notes from hand collection*/
drop if State == "" /*drop empty lines in hand collection sheet*/
drop if State == "DC" /*no legislation vars, as before*/
tempfile polecon
save `polecon'

restore 
merge m:1 State using `polecon' 
keep if _merge == 3 
drop _merge  


******************************************************************************************************************************************************************************
* Merge in State Board of Accountancy predictors from Colbert and Murray (2013)

* interim step: merge in cross walk file to merge with Colbert and Murray (2013) data
preserve
import excel "./Data/LawPrediction/StatesPostalCodeCrosswald.xlsx", sheet("Sheet1") clear
gen StatePostal = substr(A, -2, .)
gen State = substr(A, 1, strlen(A) - 5)
tempfile postcode
save `postcode'
restore
merge m:1 State using `postcode'
assert _merge != 1 
keep if _merge == 3
drop _merge 

* merge in
merge m:1 StatePostal using "./Data/LawPrediction/ColbertMurray.dta"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Variable prep and analysis

******************************************************************************************************************************************************************************
* Variable prep 

* Set STCox structure for checking
egen id = group(State)
gen coxtime = year - 2002 

* Set failure event
sort State year
by State: gen CPAMob = (_n ==_N)
stset coxtime, id(id) failure(CPAMob==1)
* check Cox structure
* sts graph

* Prep bill load variables
replace Session = "1" if Session =="" 
gen nosessionid = (Session == "na" | Session == "0")
* When there is no session, nothing can be passed
foreach var of varlist IntroBill IntroResol EnactBill EnactResol {
	replace `var' = "0" if nosessionid == 1

}
replace LengthSession = "0" if nosessionid == 1 

* Prep Dem / Rep variables
destring Senate_Dem, replace force
destring Senate_Rep, replace force
gen Senate_Total = Senate_Dem + Senate_Rep
gen Senate_Dem_Share = Senate_Dem / Senate_Total
* For Nebraska, assume equal splits (house / senate and rep / dem)
replace Senate_Total = 25 if State == "Nebraska"
replace Senate_Dem_Share = 0.5 if State == "Nebraska"

* House share and total
destring House_Dem, replace force
destring House_Rep, replace force
gen House_Total = House_Dem + House_Rep
gen House_Dem_Share = House_Dem / House_Total
* For Nebraska, assume equal splits (house / senate and rep / dem)
replace House_Total = 25 if State == "Nebraska"
replace House_Dem_Share = 0.5 if State == "Nebraska"

* Total state split
gen HouseSenate_Dem = House_Dem + Senate_Dem
gen HouseSenate_Rep = House_Rep + Senate_Rep
gen HouseSenate_Total = HouseSenate_Dem + HouseSenate_Rep
gen HouseSenate_Dem_Share = HouseSenate_Dem / HouseSenate_Total
replace HouseSenate_Total = 49 if State == "Nebraska"
replace HouseSenate_Dem_Share = 0.5 if State == "Nebraska"

* Bills enacted / introduced 
destring EnactBill, replace force
destring IntroBill, replace force
gen logbills = log(1 + IntroBill)
gen logenact = log(1 + EnactBill)

* Pol economy: Mob Task Force
gen mobilitytaskforce = (MobTaskForce != "0") 

* Pol economy: board structure
gen CPAinBoard = CPABoard / TotalBoard
gen Big4inBoard = Big4Board / TotalBoard

* Pol economy: Colbert / Murray 
gen pubprac = real(PUBPRAC) 
gen fundingautonomy = FUND_AUT
gen localCPAs = NO_LOCAL / (NO_NAT + NO_LOCAL) 

******************************************************************************************************************************************************************************
* Wage and employment trends, difference to mean

preserve

* import QCEW state-level data for years 2000 and 2005
foreach i in 2000 2005 {
	import delimited "./Data/Census/Data_QCEW/QCEW_RAWData/`i'.annual.singlefile.csv", stringcols(_all) clear
	keep if industry_code == "541211" /*keep CPAs only*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if agglvl_code == "58" /*keep only state-level 6 digits*/
	gen excludestate = (area_fips == "51000" | area_fips == "39000" | area_fips == "78000" | area_fips == "72000" | area_fips == "15000")
	drop if excludestate == 1 /*align with main sample*/
	rename avg_annual_pay pay
	rename annual_avg_emplvl emp
	keep area_fips year pay emp
	tempfile qcew`i'
	save "`qcew`i''"
}
use "`qcew2000'", clear
append using "`qcew2005'"
ds area_fips, not
foreach v of var `r(varlist)' {
	destring `v', replace
}
egen state_id = group(area_fips)
xtset state_id year, yearly
gen logpay = log(pay)
gen logemp = log(emp)

* gen difference over time
gen d5logpay = logpay - L5.logpay
gen d5logemp = logemp - L5.logemp

* gen difference to mean
keep if year == 2005 /*calc diffs to national */
egen logpaymean = mean(logpay)
egen logempmean = mean(logemp)
gen logpaydiff = logpay - logpaymean
gen logempdiff = logemp - logempmean
keep area_fips d*log* logpaydiff logempdiff
tempfile qcewcontrols
save `qcewcontrols'
restore
capture drop _merge 
merge m:1 area_fips using  `qcewcontrols'
keep if _merge == 3

******************************************************************************************************************************************************************************
* Prediction analysis 

* Table 1, Panel B: CPA Mobility Adoption Prediction 
preserve
qui stcox logpaydiff logempdiff d5logpay d5logemp pubprac localCPAs i.mobilitytaskforce i.fundingautonomy L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
keep if (e(sample)) == 1 /*estimate full model to ascertain equal obs across specs*/
eststo clear
eststo: stcox logpaydiff logempdiff d5logpay d5logemp, cluster(id)
eststo: stcox pubprac localCPAs i.mobilitytaskforce i.fundingautonomy, cluster(id)
eststo: stcox L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth
eststo: stcox Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
eststo: stcox logpaydiff logempdiff d5logpay d5logemp pubprac localCPAs i.mobilitytaskforce i.fundingautonomy L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
esttab using "./Output/Table1_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace eform
restore 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW state-level prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Read raw data and prep file

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import QCEW data


filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace
use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename /*needed for getting the years*/ 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "58" /*keep only State-level 6 digits*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" | industry_code == "541110" /*keep only CPAs and lawyers*/
	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Clean file / var formats

******************************************************************************************************************************************************************************
* Var format
ds area_fips industry_code qtr filename disclosure_code_str lq_disclosure_code_str oty_disclosure_code_str, not
foreach v of var `r(varlist)' {
	destring `v', replace 
}

******************************************************************************************************************************************************************************
* Clean up state variable

* interim step to get the state name: merge with a name cross walk file 
merge m:1 area_fips using "./Data/Census/Data_QCEW/FIPSandNamesCrosswalk.dta" 
assert _merge != 1
keep if _merge == 3
drop _merge

* area_title
split area_title, p(" -- ")
replace area_title = area_title1
drop area_title1 area_title2


******************************************************************************************************************************************************************************
* Sample screen

* toss out excluded sates
gen excludestate = (area_title == "Virginia" | area_title == "Ohio" | area_title == "Virgin Islands" | area_title == "Puerto Rico" | area_title == "Hawaii")
drop if excludestate == 1

* sample period alignment
keep if year >= 2003

******************************************************************************************************************************************************************************
* Merge in controls

merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta" 
keep if _merge == 3
drop _merge 

******************************************************************************************************************************************************************************
* Analyses prep

* gen shorter var names for handling
gen pay = avg_annual_pay
gen emp = annual_avg_emplvl

* gen main responses
gen logpay = log(pay) 
gen logemp = log(emp)

* gen weights -- empshares
egen occ_year_id = group(industry_code year)
preserve 
collapse (sum) emp, by(occ_year_id)
rename emp emptotal
tempfile emptotal
save `emptotal'
restore 
merge m:1 occ_year_id using `emptotal'
assert _merge == 3 
drop _merge
gen empshare = emp / emptotal

* gen x-section treatment dummies for DiDiD and sample inclusion
capture gen cpa = (industry_code == "541211")
capture gen lawyer = (industry_code == "541110")
capture gen cpalawyer = (cpa == 1 | lawyer == 1)

* merge in treatment dummies
capture drop L1_CPAMobility_Effec_longpanel
preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear
keep area_fips year adoption_year L1_CPAMobility_Effec_longpanel
tempfile mobilitydummies
save `mobilitydummies'
restore 
capture drop _merge 
merge m:1 area_fips year using `mobilitydummies'
drop if _merge == 2
drop _merge 

* shorten name for handling in DiDiD
rename L1_CPAMobility_Effec_longpanel L1_CPAMob
replace L1_CPAMob = 1 if year > 2015 /*all sample states adopted then*/

* gen DiDiD treatment dummies
gen L1_CPAMob_cpa = L1_CPAMob * cpa 

* gen event time dummies for graph analysis
gen effectiveyear = adoption_year
do "./Dofiles/reltimedummmies.do" /*outsourced event-time dummy generator for brevity*/

* gen FEs 
egen cpa_year = group(cpa year)
egen state_year = group(area_fips year)
egen state_occ_id = group(industry_code area_fips)
egen state_id = group(area_fips)

* gen logestab 
gen logestab = log(annual_avg_estabs)

* gen empl2estab
gen empl2estab = annual_avg_emplvl / annual_avg_estabs
gen logempl2estab = log(empl2estab)

* gen estabshares 
bysort occ_year_id: egen estabtotal = total(annual_avg_estabs)
gen estabshare = annual_avg_estabs / estabtotal


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analyses: QCEW state-Level

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Figure 1

******************************************************************************************************************************************************************************
* Figure 1, Panel A: Timing reg CPA only 

capture gen zero = 0 
label variable zero "t-1" 
reghdfe logpay reltimeleadlarger3_cpa reltimelead3_cpa reltimelead2_cpa zero /*reltimelead1_cpa */  reltime0_cpa reltimelag1_cpa ///
	reltimelag2_cpa reltimelag3_cpa reltimelaglarger3_cpa ///
	L1_unemp L1_gdp L1_abroadmigration L1_betweenstatemigration if cpa == 1 [aw = empshare], a(state_id year) cluster(state_id)
coefplot, keep(reltime* zero) omitted vertical ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(4.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelA.pdf", as(pdf) replace
graph close

******************************************************************************************************************************************************************************
* Figure 1, Panel C: Timing reg CPA vs lawyers

capture gen zero = 0 
label variable zero "t-1" 
reghdfe logpay reltimeleadlarger3_cpa reltimelead3_cpa reltimelead2_cpa zero /* reltimelead1_cpa */ reltime0_cpa reltimelag1_cpa ///
	reltimelag2_cpa reltimelag3_cpa reltimelaglarger3_cpa if cpalawyer == 1 [aw = empshare], a(cpa_year state_year state_occ_id) cluster(state_id)
coefplot, keep(reltime* zero) omitted vertical ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(4.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelC.pdf", as(pdf) replace
graph close
	
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 2

******************************************************************************************************************************************************************************
* Table 2, Panel A: Descriptives

* CPA only
tabstat pay logpay emp logemp L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1 ///
	, s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

******************************************************************************************************************************************************************************
* Table 2, Panel B: Baseline wage

eststo clear 
eststo: reghdfe logpay L1_CPAMob if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_unemp if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_gdp if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_betweenstatemigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_abroadmigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
esttab using "./Output/Table2_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
* Table 2, Panel C: Employment

eststo clear
eststo: reghdfe logemp L1_CPAMob if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_unemp if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_gdp if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_betweenstatemigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_abroadmigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
esttab using "./Output/Table2_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel B: Triple Diff CPA vs lawyers

eststo clear 
eststo: reghdfe logpay L1_CPAMob_cpa if cpalawyer == 1 [aw = empshare], a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob_cpa if cpalawyer == 1, a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logempl2estab L1_CPAMob_cpa if cpalawyer == 1 [aw = estabshare], a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logestab L1_CPAMob_cpa if cpalawyer == 1, a(cpa_year state_year state_occ_id) cluster(state_id)
esttab using "./Output/Table3_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* SUSB State-level prep and analyses 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Read in and clean data

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Raw data processing 

filelist, dir("./Data/Census/Data_SUSB/SUSB_6digitnaics/") pat("*.txt") save("./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta") replace

use "./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta" in `i', clear
	local f = dirname + "/" + filename
	local g = filename
	import delimited "`f'", encoding(ISO-8859-1) clear
	keep if naics == "541211" | naics == "541110" /*keep CPAs and Lawyers for triple and quadruple diff*/
	gen source = "`f'"
	tempfile save`i'
	save "`save`i''"
}

*append all files
use "`save1'", clear
	forvalues i=2/`obs' {
    append using "`save`i''"
}


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Clean up file 

* keep only state-level variables
drop if state == 0 /*drop national-level variables */

* gen year variable 
capture drop year
gen year = substr(source, -8, 4)
destring year, replace

* sort data
sort state statedscr entrsize year

* gen area fips / statename for merges
gen area_fips = state
tostring area_fips, replace 
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000"
gen statename = statedscr

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Variable consistency checks and adjustments

* sort out differences in variable names (not definitions) across SUSB year files variable by variable: 

******************************************************************************************************************************************************************************
* Employment

tab year if missing(empl) /*this is as of 2011*/
tab year if missing(empl_n) /*this is before 2011*/
gen empltemp = .
replace empltemp = empl if year < 2011
replace empltemp = empl_n if year >= 2011
tab year if missing(empltemp) /* none missing*/
drop empl empl_n
rename empltemp empl

******************************************************************************************************************************************************************************
* Payroll

tab year if missing(payr) /*as of 2011 missing*/
tab year if missing(payr_n) /*up until 2010*/
gen paytemp = .
replace paytemp = payr if year < 2011
replace paytemp = payr_n if year >= 2011
tab year if missing(paytemp) /*done - none missing*/
drop payr payr_n
rename paytemp payr 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis prep

******************************************************************************************************************************************************************************
* Merge in treatment dummies

preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear
keep area_fips year adoption_year L1_CPAMobility_Effec_longpanel
tempfile mobilitydummies
save `mobilitydummies'

restore 
* merge m:1 (multiple size classes per area_fips and year)
merge m:1 area_fips year using `mobilitydummies'
keep if _merge == 3 
drop _merge 

******************************************************************************************************************************************************************************
*  Gen outcome variables 

gen pay = payr / empl 
gen logpay = log(pay)
gen logempl = log(empl)
gen logestb = log(estb)
gen emp2estb = empl / estb
gen logemp2estb = log(emp2estb)

tab year if missing(logpay)
tab entrsize year if missing(logpay)  /*Tests are conducted on Class 5 (<20) and Class 6 (20-99) to max coverage -- next step*/

******************************************************************************************************************************************************************************
* Gen and keep size buckets 

gen smallfirm = (entrsize == 5) /*<20 employees*/
gen largefirm = (entrsize == 6) /*20-99 employees*/
gen inclfirm = (entrsize == 5 | entrsize == 6)
keep if inclfirm == 1

******************************************************************************************************************************************************************************
* Gen industry FE for DiDiD and DiDiDiD

gen cpa = (naics == "541211")
gen lawyer = (naics == "541110")

******************************************************************************************************************************************************************************
* Gen FEs 

capture drop *_id
egen state_id = group(area_fips)
egen state_naics_id = group(area_fips naics)
egen state_size_id = group(area_fips entrsize)
egen state_naics_size_id = group(area_fips naics entrsize)
egen year_id = group(year)
egen state_year_id = group(area_fips year)
egen naics_year_id = group(naics year)
egen size_year_id = group(entrsize year)
egen naics_size_year_id = group(naics entrsize year)
egen state_naics_year_id = group(area_fips naics year)  
egen state_size_year_id = group(area_fips entrsize year)

******************************************************************************************************************************************************************************
* Gen treatments 

* Shorten var name for DiDiD and DiDiDiD treatment dummy construction
rename L1_CPAMobility_Effec_longpanel L1_CPAMob 

capture gen L1_CPAMob_small = L1_CPAMob * smallfirm * cpa
capture gen L1_CPAMob_small_cpa = L1_CPAMob * smallfirm * cpa

capture gen L1_CPAMob_large = L1_CPAMob * largegfirm * cpa
capture gen L1_CPAMob_large_cpa = L1_CPAMob * largefirm * cpa

******************************************************************************************************************************************************************************
* Sample screens

* drop states 
drop if statename == "Ohio" | statename == "Virginia"

* balance
bysort state_naics_size_id: egen totalobs = count(logpay)
qui sum totalobs
keep if totalobs == `r(max)'

******************************************************************************************************************************************************************************
* Calc weights

capture drop empltotal 
capture drop estbshare
bysort naics_size_year_id: egen empltotal = total(empl)
gen emplshare = empl / empltotal
bysort naics_size_year_id: egen estbtotal3 = total(estb)
gen estbshare = estb / estbtotal


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Restriction on double-matched state-years

* restrict to sample with full coverage to estimate quadruple diff
qui reghdfe logpay L1_CPAMob_small_cpa [aw = emplshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl1 = (e(sample) == 1)
qui reghdfe logempl L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl2 = (e(sample) == 1)
qui reghdfe logemp2estb L1_CPAMob_small_cpa [aw = estbshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl3 = (e(sample) == 1)
qui reghdfe logestb L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl4 = (e(sample) == 1)
keep if incl1 == 1 & incl2 == 1 & incl3 == 1 & incl4 == 1

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel C: Quadruple diff spec 

eststo clear
eststo: reghdfe logpay L1_CPAMob_small_cpa [aw = emplshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logempl L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logemp2estb L1_CPAMob_small_cpa [aw = estbshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logestb L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
esttab using "./Output/Table3_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel A: CPA only estimates

* keep only CPAs and re-prep weights
keep if cpa == 1

capture drop emplshare 
capture drop emptotal 
capture drop estbtotal 
capture drop estbshare
bysort entrsize year: egen emptotal = total(empl)
gen empshare = empl / emptotal
bysort entrsize year: egen estbtotal = total(estb)
gen estbshare = estb / estbtotal

* merge in state-year controls -- before: state-year FE, controls absorbed
capture drop _merge 
merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta"
assert _merge != 1
drop if _merge == 2 /*years available in QCEW but not in SUSB (starting in 2007)*/
drop _merge 

* Table 3, Panel A: CPA small vs Large
eststo clear
eststo: reghdfe logpay L1_CPAMob_small if cpa == 1 [aw = empshare], a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logempl L1_CPAMob_small if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logemp2estb L1_CPAMob_small [aw = estbshare] if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logestb L1_CPAMob_small if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
esttab using "./Output/Table3_PanelA.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Graphical Analysis -- note: SUSB program starts in 2007 --> fewer pre-period data points

******************************************************************************************************************************************************************************
* Event time dummies 

gen eventtime = year - adoption_year
gen lead1small = (eventtime == -1 & smallfirm == 1)
label var lead1small "t=-1"
gen leadlarger2small = (eventtime <= -2 & smallfirm == 1)
label var leadlarger2small "t≤-2"
gen lag0small = (eventtime == 0 & smallfirm == 1)
label var lag0small "t=0"
gen lag1small = (eventtime == 1 & smallfirm == 1)
label var lag1small "t=1"
gen lag2small = (eventtime == 2 & smallfirm == 1)
label var lag2small "t=2"
gen lag3small = (eventtime == 3 & smallfirm == 1)
label var lag3small "t=3"
gen laglarger4small = (eventtime >= 4 & smallfirm == 1)
labe var laglarger4small "t≥4"

******************************************************************************************************************************************************************************
* Figure 1, Panel B: Event time plot SUSB-state CPA large vs small 

capture gen zero = 0
label var zero "t=-1"
reghdfe logpay leadlarger2small zero /* lead1small */ lag0small lag1small lag2small lag3small laglarger4small if cpa == 1 [aw = empshare], ///
	a(state_year_id state_size_id size_year_id) cluster(state_id)
coefplot, keep(*small zero) vert omit ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(2.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelB.pdf", as(pdf) replace
graph close 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW border-county-level prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and clean data

******************************************************************************************************************************************************************************
* Import raw QCEW data

filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace
use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename /*needed for getting the years*/ 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "78" /*keep only 6 digits naics county-level variables*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" /*keep only CPAs*/
	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}

* var format 
ds area_fips industry_code qtr filename disclosure_code_str lq_disclosure_code_str oty_disclosure_code_str, not
foreach v of var `r(varlist)' {
	destring `v', replace 
}


******************************************************************************************************************************************************************************		 
* Align sample period

* align sample period with state-level QCEW analyses
tab year
keep if year >= 2003

******************************************************************************************************************************************************************************		 
* Merge in treatments and sample screen

******************************************************************************************************************************************************************************
* Merge prep and merge with law dummies

* (temp) recode the state indetifiers for the merges
gen area_fips_merge_temp = substr(area_fips,1,2) + "000" /*only need the first two--treatment assignment at the state level*/
rename area_fips area_fips_original /*renaming required for merge*/
rename area_fips_merge_temp area_fips
merge m:1 area_fips year using "./Data/Helper/LawDummiesCensusCounty.dta"
rename area_fips area_fips_merge_temp /*reverse renaming*/
rename area_fips_original area_fips  

* tab year if _merge == 1 /*not matched from master*/
drop if year <= 2002 /*consistency with State-level and Dummy file*/

* impose sample restriction
drop if area_fips_merge_temp == "15000" /*Hawaii*/
drop if area_fips_merge_temp == "72000" /*Puerto Rico*/
drop if area_fips_merge_temp == "78000" /*Virgin Island*/ 

* adjust treatment dummies to be equal to 1 for later years, when all sample states adopted
replace L1_CPAMobility_Effec_longpanel = 1 if year >= 2015 
drop _merge 


******************************************************************************************************************************************************************************		 
* Balancing check

egen county_id = group(area_fips)
xtset county_id year, yearly

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Merge in identifiers and control variables

******************************************************************************************************************************************************************************
* Merge with the adjanct county file

capture drop _merge
merge m:1 area_fips using "./Data/Helper/CPAMobility_AdjanctCountiesBorderIDs.dta"
tab statepair if _merge == 2
tab homestate if _merge == 2
drop if _merge == 2
gen neighbor_county = 0
replace neighbor_county = 1 if _merge == 3
drop _merge

******************************************************************************************************************************************************************************
* Merge in mapping info

capture drop _merge
merge m:1 area_fips using "./Data/Helper/us_county_db.dta" 
tab NAME if _merge == 2 
drop if _merge == 2 
drop _merge

******************************************************************************************************************************************************************************
* Merge state-level controls 

rename area_fips area_fips_original /*renaming needed for merge -- macro controls except for unemp (merged in below) are only available at the state level*/
rename area_fips_merge_temp area_fips
capture drop _merge
merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta"
rename area_fips area_fips_merge_temp /*reverse renaming*/ 
rename area_fips_original area_fips 
drop if _merge != 3

******************************************************************************************************************************************************************************
* Merge county-level controls 

preserve
use "./Data/Controls/CPAMobility_BLS_LAUS_CountyEmployment.dta", clear
keep area_fips area_title_LAUS year unemploymentrate
replace year = year + 1 /*gen lagged structure*/
rename unemploymentrate L1_unemploymentrate
* Rename county level control for consistency and clarity
rename L1_unemploymentrate L1_unemp_county 
tempfile unempcounty
save `unempcounty'
restore

capture drop _merge
merge 1:1 area_fips year using `unempcounty'
keep if _merge ==3

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis and variable preparation

******************************************************************************************************************************************************************************
* Prep response vars

* Prep pay 
gen pay = avg_annual_pay
gen logpay = log(avg_annual_pay)

* Prep emp
rename annual_avg_emplvl emp
gen logemp = log(emp)


******************************************************************************************************************************************************************************
* Prep FEs 

qui capture drop border_id
capture egen border_id = group(BORDINDX)
capture egen county_id = group(area_fips)
capture egen state_id = group(area_fips_merge_temp)

******************************************************************************************************************************************************************************
* Introduce non-overlaping treatdate condition

capture drop adoption_year
gen adoption_year = .
bysort area_fips year: replace adoption_year = year if CPAMobility_Effec == 1


levelsof statefip, local(states)
foreach s of local states {
	sum adoption_year if statefip == `s'
	replace adoption_year = r(max) if statefip == `s' & missing(adoption_year)
}

capture drop diff_adoption 
gen diff_adoption = 0
levelsof border_id, local(levels)
foreach l of local levels {
	sum adoption_year if border_id == `l'
	replace diff_adoption = 1 if r(sd) != 0 & border_id == `l'

}

******************************************************************************************************************************************************************************
* Figure 2: Border counties with non-overlapping treatment dates 

spmap neighbor_county using us_county_coord if year == 2005 & stateicp != 81, id(id) fcolor(Blues) clmethod(unique)
graph export "./Output/Figure2.pdf", as(pdf) replace

******************************************************************************************************************************************************************************
* Keep only diff-adoption counties 

keep if diff_adoption == 1

******************************************************************************************************************************************************************************
* Further est sample conditions to ascertain estimation on consistently disclosing--that is, no Census confidentiality--counties

* gen counter for balancing
sort area_fips year
bysort area_fips: gen counter = _N

* condition: only disclosing counties--that is, counties displaying above-zero employees throughout
capture drop minemp
bysort county_id: egen minemp = min(emp)

******************************************************************************************************************************************************************************
* Calc weights

capture drop empshare emptotal
bysort year: egen emptotal = total(emp)
gen empshare = emp / emptotal

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis 

preserve 

* impose restriction
keep if counter == 15 & neighbor_county == 1 & border_id != 74 & diff_adoption == 1 & !missing(logpay) & minemp > 0 /*BorderID 74 is Lake Michigan*/

* impose reg restriction to ascertain same obs across specifications
qui reghdfe logpay L1_CPAMobility_Effec_longpanel [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
keep if (e(sample)) == 1

* Table 4, Panel B: Border-county analysis
eststo clear
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_betweenstatemigration L1_abroadmigration [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)

eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_betweenstatemigration L1_abroadmigration, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration, a(county_id i.border_id#i.year) cluster(state_id)
esttab using "./Output/Table4_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Table 4, Panel A: Desc stats 
tabstat pay logpay emp logemp L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration, ///
	s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

restore 
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW MSA-level prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and clean data

******************************************************************************************************************************************************************************
* Import Census MSA data

filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace

use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "48" /*keep only MSA-level 6 digits -- Census codes available here: https://data.bls.gov/cew/doc/titles/agglevel/agglevel_titles.htm*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" | industry_code == "541110" /*keep only CPAs and lawyers*/

	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}

******************************************************************************************************************************************************************************
* Clean up and adjust variable formatting

drop oty_* lq_* filename qtr disclosure_code_st size_code own_code total_annual_wages taxable_annual_wages annual_avg_wkly_wage annual_contributions 

foreach var of varlist year annual_avg_estabs annual_avg_emplvl avg_annual_pay {
	destring `var', replace 
}

******************************************************************************************************************************************************************************
* Merge in GDP MSA 

preserve
import delimited "./Data/Controls/bea_gdp_annual_naicsall_msa_clean.csv", encoding(ISO-8859-1)clear stringc(_all)
foreach var of varlist v3-v19 {
   local x : variable label `var' 
   rename `var' msagdp`x'
   destring msagdp`x', replace force
}
reshape long msagdp, i(geofips geoname) j(year)
* adjust to msa fips 
gen area_fips = "C" + substr(geofips, 1, 4)
drop geofips
tempfile msagdp
save `msagdp'
restore 
merge m:1 area_fips year using `msagdp'
drop if _merge == 2
drop _merge 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis and variable preparation

* gen industry ID 
encode industry_code, gen(industry_id) label(industry_id)

* rename variables
gen pay = avg_annual_pay
gen logpay = log(pay)
gen emp = annual_avg_emplvl
gen logemp = log(emp)
gen logmsagdp = log(msagdp)

* difference variables
capture drop msa_industry_id 
egen msa_industry_id = group(area_fips industry_id)
xtset msa_industry_id year, yearly
foreach var of varlist logpay logmsagdp {
	capture gen d1`var' = (`var' - L1.`var') 
}

* IDs and screen
gen cpa = (industry_code == "541211")
gen lawyer = (industry_code == "541110")
keep if cpa == 1 | lawyer == 1 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Helper variables and screen

* est periods
gen postperiod = (year >= 2014)
gen prepreriod = (year >= 2002 & year <= 2005)
gen estperiod = (prepreriod == 1 | postperiod == 1)

* label for outputs
label define cpal 0 "Lawyers" 1 "CPAs" 
label values cpa cpal 
label define postperiodl 0 "Pre-Period" 1 "Post-Period" 
label values postperiod postperiodl 
label define preperiodl 0 "Post-Period" 1 "Pre-Period" 
label values prepreriod preperiodl 
label var d1logpay ""

* min data availablity criterion
egen msa_id = group(area_fips)
gen inclobs = (!missing(d1logpay))
bysort msa_id cpa estperiod: egen totalinclobs = total(inclobs)
keep if totalinclobs >= 5

* calc empshares
bysort cpa year: egen totalemp = total(emp)
gen empshare = emp / totalemp


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Figure 3, Panel A and B: Visual sens analysis 

binscatter d1logpay d1logmsagdp [aw = empshare] if prepreriod == 1 & cpa == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("CPAs: Pre-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelA-1.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if postperiod == 1 & cpa == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("CPAs: Post-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelA-2.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if prepreriod == 1 & lawyer == 1 /// 
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("Lawyers: Pre-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelB-1.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if postperiod == 1 & lawyer == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("Lawyers: Post-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelB-2.pdf", as(pdf) replace
graph close


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel A: Sens analysis regression

gen d1logmsagdp_post = d1logmsagdp * postperiod
gen d1logmsagdp_pre = d1logmsagdp * prepreriod

gen d1logmsagdp_cpa = d1logmsagdp * cpa
gen d1logmsagdp_lawyer = d1logmsagdp * lawyer
gen d1logmsagdp_cpa_post = d1logmsagdp * cpa * postperiod
gen d1logmsagdp_lawyer_post = d1logmsagdp * lawyer * postperiod

* Desc Stats 
gen cpalawyer = (cpa == 1 | lawyer == 1)
tabstat pay logpay d1logpay if cpa == 1 & estperiod == 1 & !missing(d1logpay) & !missing(d1logmsagdp), s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
tabstat pay logpay d1logpay if lawyer == 1 & estperiod == 1 & !missing(d1logpay) & !missing(d1logmsagdp), s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
tabstat msagdp logmsagdp d1logmsagdp if estperiod == 1 & !missing(d1logpay) & cpalawyer == 1, s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* Table 5, Panel A: Reg | profession 
eststo clear
eststo: reg d1logpay d1logmsagdp_post d1logmsagdp postperiod [aw = empshare] if cpa == 1 & estperiod == 1, cluster(msa_id)
eststo: reg d1logpay d1logmsagdp_post d1logmsagdp postperiod [aw = empshare] if lawyer == 1 & estperiod == 1, cluster(msa_id)
esttab using "./Output/Table5_PanelA.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Aux reg: for difference in coefficient test 
capture egen cpa_year_id = group(cpa year)
capture egen cpa_period_id = group(cpa postperiod)
capture egen msa_id = group(area_fips)
capture egen msa_cpa_id = group(area_fips cpa)

reg d1logpay d1logmsagdp_cpa_post d1logmsagdp_cpa d1logmsagdp_lawyer_post d1logmsagdp_lawyer i.cpa i.postperiod i.postperiod#i.cpa [aw = empshare] if estperiod == 1, cluster(msa_id)
test d1logmsagdp_cpa_post = d1logmsagdp_lawyer_post


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel B: Volatility analysis 

eststo clear

* Table 5, Panel B, Col 1
preserve
keep if estperiod == 1
local testvar d1logpay
collapse (sd) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa post, vce(robust)
restore 

* Table 5, Panel B, Col2
preserve
keep if estperiod == 1
local testvar d1logpay
collapse (iqr) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa post, vce(robust)
restore 
esttab using "./Output/Table5_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel C: Convergence analysis 

eststo clear

* Tabel 5, Panel C, Col1 
preserve
keep if estperiod == 1
local testvar logpay
collapse (sd) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa postperiod, vce(robust)
restore 

* Tabel 5, Panel C, Col2 
preserve
keep if estperiod == 1
local testvar logpay
collapse (iqr) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa postperiod, vce(robust)
restore 
esttab using "./Output/Table5_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* AICPA MAP Survey prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Raw data import, prep, and checks

filelist, dir("./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/") pat("*.xlsx") save("./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta") replace

use "./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta", clear /*23 obs - correct*/
local obs = _N
forvalues i=1/`obs' {
	use "./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta" in `i', clear
	local f = dirname + "/" + filename
	local g = filename
	import excel "`f'", sheet("Sheet1") allstring clear
	drop if missing(A) /*drop empty columns in collection sheet*/
	drop B /*drop notes column */

	sxpose, clear /*ssc install, if required*/
	renvars , map(`=word("@", 1)') /*take the first row as variable name*/
	drop if _n == 1 /*drop empty row -- collection notes*/
	rename Variable size_class
	capture replace size_class = "single_medium_2002" if size_class == "single_medium_2004" /*correcting a labeling issues in raw files*/
	drop if missing(size_class) /*drop empty cells*/

	ds size_class, not
	foreach var in `r(varlist)' {
		gen r_`var' = real(`var')
		drop `var' 
		rename r_`var' `var'  
	}	
	gen year = substr(size_class, length(size_class) - 3, 4)
	gen size_class_temp = substr(size_class, 1, length(size_class) - 5)
	drop size_class
	rename size_class_temp size_class
	gen source = "`f'"
	gen source_file = "`g'"
	tempfile save`i'
	save "`save`i''"
}

* append all files
use "`save1'", clear
	forvalues i=2/`obs' {
    append using "`save`i''"
}
/*71 vars = 69 vars + source var + filename var --> correct*/
/*805 obs = 35 obs per state * 23 states = 805 -- > correct*/


* Introduce area fips for merging in dummy structure
replace source_file = subinstr(source_file, "StataImport_Staffing_", "", .)
replace source_file = subinstr(source_file, ".xlsx", "", .)
gen area_fips = "."
replace area_fips = "04000" if source_file == "Arizona"
replace area_fips = "06000" if source_file == "California"
replace area_fips = "08000" if source_file == "Colorado"
replace area_fips = "12000" if source_file == "Florida"
replace area_fips = "13000" if source_file == "Georgia"
replace area_fips = "17000" if source_file == "Illinois"
replace area_fips = "18000" if source_file == "Indiana"
replace area_fips = "22000" if source_file == "Louisiana"
replace area_fips = "24000" if source_file == "Maryland"
replace area_fips = "25000" if source_file == "Massachusetts"
replace area_fips = "26000" if source_file == "Michigan"
replace area_fips = "27000" if source_file == "Minnesota"
replace area_fips = "34000" if source_file == "NewJersey"
replace area_fips = "36000" if source_file == "NewYork"
replace area_fips = "37000" if source_file == "NorthCarolina"
replace area_fips = "39000" if source_file == "Ohio"
replace area_fips = "40000" if source_file == "Oklahoma"
replace area_fips = "41000" if source_file == "Oregon"
replace area_fips = "42000" if source_file == "Pennsylvania"
replace area_fips = "48000" if source_file == "Texas"
replace area_fips = "51000" if source_file == "Virginia"
replace area_fips = "53000" if source_file == "Washington"
replace area_fips = "55000" if source_file == "Wisconsin"

* year variable
capture drop r_year
gen r_year = real(year) 
drop year
rename r_year year

* save temp set
preserve


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Preparation of law dummy file (adjust to accommodate biennial structure of the MAP survey) and sample screen

* merge in adjusted dummy structure
import excel "./Data/Helper/CPAMobility_MAPSurvey_Adoption.xlsx", sheet("Mobility_Effective") firstrow clear
reshape long v_, i(effective_sequence stateicp_string stateicp stateicp_valuelabel ST STATE statefip area_fips Effective_Date) j(year)

* gen long panel variable
sort ST year

gen CPAMobility_Effec_longpanel = 0
replace CPAMobility_Effec_longpanel = 1 if v_ == 1 
sort ST year
by ST: replace CPAMobility_Effec_longpanel = 1 if  CPAMobility_Effec_longpanel[_n-1] == 1
 
* generate merge variable
gen area_fips_temp = string(area_fips)
drop area_fips
rename area_fips_temp area_fips
replace area_fips = "0" + area_fips if length(area_fips) == 4

* save dummy file
tempfile dummies
save `dummies'

* use master and merge in law dummies
restore
merge m:1 area_fips year using `dummies' /*all matched from master*/
tab STATE if _merge == 2
codebook STATE if _merge == 2 /*27 states --> correct */
keep if _merge == 3
drop _merge

* drops
drop if source_file == "Ohio"
drop if source_file == "Virginia"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prep and aux regressions 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Compensation prep

* Missing Check
foreach var of varlist comp_partner comp_director comp_sr_manager comp_manager comp_sr_associate comp_associate comp_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}
egen comp_all = rmean(comp_partner comp_director comp_sr_manager comp_manager comp_sr_associate comp_associate)
gen logcomp_all = log(comp_all)
egen comp_senior = rmean(comp_partner )
gen logcomp_senior = log(comp_senior)
egen comp_mid = rmean(comp_director comp_sr_manager comp_manager)
gen logcomp_mid = log(comp_mid)
egen comp_low = rmean(comp_sr_associate comp_associate)
gen logcomp_low = log(comp_low)

gen non_miss = 0 
replace non_miss = 1 if !missing(comp_senior) & !missing(comp_mid) & !missing(comp_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Billing rate prep

foreach var of varlist avgbill_partner avgbill_director avgbill_sr_manager avgbill_manager avgbill_sr_associate avgbill_associate avgbill_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}

* generate position partitions
egen avgbill_all = rmean( avgbill_partner avgbill_director avgbill_sr_manager avgbill_manager avgbill_sr_associate avgbill_associate)
gen logavgbill_all = log(avgbill_all)
egen avgbill_senior = rmean( avgbill_partner )
gen logavgbill_senior = log(avgbill_senior)
egen avgbill_mid = rmean( avgbill_director avgbill_sr_manager avgbill_manager)
gen logavgbill_mid = log(avgbill_mid)
egen avgbill_low = rmean( avgbill_sr_associate avgbill_associate)
gen logavgbill_low = log(avgbill_low)

gen non_miss_bill = 0 
replace non_miss_bill = 1 if !missing(avgbill_senior) & !missing(avgbill_mid) & !missing(avgbill_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Hours billed prep

foreach var of varlist avgcharg_partner avgcharg_director avgcharg_sr_manager avgcharg_manager avgcharg_sr_associate avgcharg_associate avgcharg_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}

* generate different position partitions
egen avgcharg_all = rmean( avgcharg_partner avgcharg_director avgcharg_sr_manager avgcharg_manager avgcharg_sr_associate avgcharg_associate)
gen logavgcharg_all = log(avgcharg_all)
egen avgcharg_senior = rmean( avgcharg_partner)
gen logavgcharg_senior = log(avgcharg_senior)
egen avgcharg_mid = rmean( avgcharg_director avgcharg_sr_manager avgcharg_manager)
gen logavgcharg_mid = log(avgcharg_mid)
egen avgcharg_low = rmean( avgcharg_sr_associate avgcharg_associate)
gen logavgcharg_low = log(avgcharg_low)

gen non_miss_charge = 0 
replace non_miss_charge = 1 if !missing(avgcharg_senior) & !missing(avgcharg_mid) & !missing(avgcharg_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* condition to ascertain constant estimation sample across specs
capture drop triple_condition
gen triple_condition = 0
replace triple_condition = 1 if non_miss == 1 & non_miss_bill == 1 & non_miss_charge == 1 

* gen FE
egen state_id = group(area_fips)

* Table 6, Panel B: Baseline
eststo clear		
foreach var of varlist logcomp_all avgbill_all logavgcharg_all {
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2014 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)	
}	
esttab using "./Output/Table6_PanelB.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel C: Logratio test comp
gen logseniorlow = logcomp_senior - logcomp_low
gen logseniormid = logcomp_senior - logcomp_mid
gen logmidlow = logcomp_mid - logcomp_low

eststo clear
foreach var of varlist logseniorlow logseniormid logmidlow {	
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelC.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel D: Logratio for billing rates
gen logbill_seniorlow = logavgbill_senior - logavgbill_low
gen logbill_seniormid = logavgbill_senior - logavgbill_mid
gen logbill_midlow = logavgbill_mid - logavgbill_low


eststo clear
foreach var of varlist logbill_seniorlow logbill_seniormid logbill_midlow {	
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelD.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel E: Logratios for hours 
gen loghour_seniorlow = logavgcharg_senior - logavgcharg_low
gen loghour_seniormid = logavgcharg_senior - logavgcharg_mid
gen loghour_midlow = logavgcharg_mid - logavgcharg_low

eststo clear
foreach var of varlist loghour_seniorlow loghour_seniormid loghour_midlow {
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelE.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel A: Descriptive stats 

* compensation
tabstat comp_all logcomp_all comp_senior comp_mid comp_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* billing rates
tabstat avgbill_all avgbill_senior avgbill_mid avgbill_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* hours charged 
tabstat avgcharg_all logavgcharg_all avgcharg_senior avgcharg_mid avgcharg_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Pension plan prep and analysis 

* File Structure:
* Require three IRS forms: Form 5500 for the plan information, Schedule H for the auditor EIN, and Schedule C for audit fees.
* File imports are split into a 2003-2008 part and 2009-2015 part. Import is split to accommodate file format differences. 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Imports and merges

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* 2003 to 2008 files


******************************************************************************************************************************************************************************
* Extract auditor and financial info from Schedule H 
 
forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_H_`i'.csv",  encoding(ISO-8859-1) clear 
	keep filing_id accountant_firm_name accountant_firm_ein acct_performed_ltd_audit_ind acct_opin_not_on_file_ind acctnt_opinion_type_ind /*controls:*/ joint_venture_boy_amt real_estate_boy_amt tot_assets_boy_amt tot_liabilities_boy_amt tot_contrib_amt professional_fees_amt contract_admin_fees_amt invst_mgmt_fees_amt other_admin_fees_amt tot_admin_expenses_amt aggregate_proceeds_amt net_income_amt
	drop if missing(accountant_firm_ein) 
	tostring accountant_firm_ein, replace /*convert to string for consistency across files and years*/
	tostring net_income_amt, replace force 
	gen year = `i'
	tempfile temp`i'
	save `temp`i''
}
use `temp2003', clear
forvalues i = 2004/2008{
	append using `temp`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0308.dta", replace 

******************************************************************************************************************************************************************************
* Extract fees from Schedule C Part 1

forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_C_PART1_`i'.csv", encoding(ISO-8859-1) clear 
	drop if missing(provider_01_ein)
	tostring provider_01_ein, replace
	tostring provider_01_srvc_code, replace
	gen year = `i'
	tempfile temp2`i'
	save `temp2`i''
}
use `temp22003', clear
forvalues i = 2004/2008{
	append using `temp2`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0308.dta", replace 


******************************************************************************************************************************************************************************
* Merge Schedule H and Schedule C

use "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0308.dta", clear
gen provider_01_ein = accountant_firm_ein /*adjust for merge*/
duplicates tag filing_id provider_01_ein year, gen(dupl)
duplicates drop filing_id provider_01_ein year, force /*5 true duplicates*/
merge 1:m filing_id provider_01_ein year using "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0308.dta"
keep if _merge == 3
drop _merge 

* keep only main service provider role
capture drop dupl
duplicates tag filing_id year, gen(dupl)
tab dupl
sort filing_id year
* browse if dupl > 0 /*Only keep the main service--that is, audit not preparation*/
capture drop dupl
duplicates tag filing_id year row_num, gen(dupl) 
tab dupl 
sort filing_id year row_num 
by filing_id year: gen counter = _n 
keep if counter == 1 /*keep main role*/
drop counter 

* save merged file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0308.dta", replace 


******************************************************************************************************************************************************************************
* Extract location and other plan info from Form 5500

forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/f_5500_`i'.csv", encoding(ISO-8859-1) clear
	* keep location and info for controls
	keep filing_id spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state preparer_name preparer_ein preparer_city preparer_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt
	* Convert the variables to strings except for filing id for merges and consistency
	foreach var of varlist spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state preparer_name preparer_ein preparer_city preparer_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt {
		capture tostring `var', replace 
	}

	gen year = `i'
	tempfile temp3`i'
	save `temp3`i''
}

use `temp32003', clear
forvalues i = 2004/2008{
	append using `temp3`i''
}

* save file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0308.dta", replace 

******************************************************************************************************************************************************************************
* Merge Form 5500 with merged auditor and fee File (Schedules H and C, merged above)

use "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0308.dta", clear 
merge m:1 filing_id year using "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0308.dta"
keep if _merge == 3 
drop _merge

* drop vars no longer needed and save merged file for handling
capture drop dupl image_form_id	page_id	page_row_num page_seq row_num
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* 2009 to 2015 files

******************************************************************************************************************************************************************************
* Extract Auditor and financial info from Schedule H

forvalues i = 2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_H_`i'_latest.csv", encoding(ISO-8859-1) clear
	keep ack_id accountant_firm_name accountant_firm_ein acct_performed_ltd_audit_ind acct_opin_not_on_file_ind acctnt_opinion_type_cd /*controls:*/ joint_venture_boy_amt real_estate_boy_amt tot_assets_boy_amt tot_liabilities_boy_amt tot_contrib_amt professional_fees_amt contract_admin_fees_amt invst_mgmt_fees_amt other_admin_fees_amt tot_admin_expenses_amt aggregate_proceeds_amt net_income_amt
	rename acctnt_opinion_type_cd acctnt_opinion_type_ind /*rename the only one that is not consistent other than the identifier*/
	drop if missing(accountant_firm_ein) 
	tostring accountant_firm_ein, replace /*align format*/
    tostring net_income_amt, replace force /*align format*/
	gen year = `i'
	tempfile temp`i'
	save `temp`i''
}

use `temp2009', clear
forvalues i = 2010/2015{
	append using `temp`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0915.dta", replace 


******************************************************************************************************************************************************************************
* Extract fees from Schedule C Part 1

forvalues i=2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_C_PART1_ITEM2_`i'_latest.csv", encoding(ISO-8859-1) clear
	* drop the following that cannot be obtained in prior files 
	drop prov_other_foreign_address1 prov_other_foreign_address2 prov_other_foreign_city prov_other_foreign_prov_state prov_other_foreign_cntry prov_other_foreign_postal_cd
	
	* rename the variables to correspond with the 2003-2008 file (imported above)
	rename provider_other_name provider_01_name 
	rename provider_other_ein provider_01_ein
	gen provider_01_position = "" /*does not exist in the 09 and onwards file*/
	rename provider_other_relation provider_01_relation
	rename prov_other_tot_ind_comp_amt provider_01_salary_amt
	rename provider_other_direct_comp_amt provider_01_fees_amt
	gen provider_01_srvc_code = "." /*converted to string in earlier import*/
	drop provider_other_amt_formula_ind
	drop prov_other_elig_ind_comp_ind 
	drop prov_other_indirect_comp_ind

	* convert the service provider ein to string variable for consistency with 2003-2008 file
	* also have to rename the variable to correspond to the id in the merging file 
	tostring provider_01_ein, replace
	tostring provider_01_srvc_code, replace
	
	* gen year and tempfile
	gen year = `i'
	tempfile temp2`i'
	save `temp2`i''
}

use `temp22009', clear
forvalues i = 2010/2015{
	append using `temp2`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0915.dta", replace 


******************************************************************************************************************************************************************************
* Merge Schedule H and Schedule C

use "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0915.dta", clear
gen provider_01_ein = accountant_firm_ein /*this needs to be the same in the files*/
duplicates tag ack_id provider_01_ein year, gen(dupl)
tab dupl /*no duplicates here*/
drop dupl 
capture duplicates drop ack_id provider_01_ein year, force /* no obs deleted*/

merge 1:m ack_id provider_01_ein year using "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0915.dta" 

* as before, missing are the ones with below threshold or missing auditor ein info, drop
keep if _merge == 3
drop _merge 

* check and inspect duplicates
capture drop dupl
duplicates tag ack_id year, gen(dupl)
tab dupl

* keep main function only (see 2003-2008 import)
* browse if dupl > 0 
sort ack_id year row_order
by ack_id year: gen counter = _n 
keep if counter == 1 
drop counter   

capture drop dupl
duplicates tag ack_id year, gen(dupl)
tab dupl /*de-duplicated*/
drop dupl

* drop row_order for file concistency with 2003-2008 imports
drop row_order 

* save merged file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0915.dta", replace 


******************************************************************************************************************************************************************************
* Extract location and other plan info from Form 5500

forvalues i=2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/f_5500_`i'_latest.csv", encoding(ISO-8859-1) clear
	
	* renaming and format adjustment for consistency with 2003-2008 import
	rename spons_dfe_mail_us_city spons_dfe_city
	rename spons_dfe_mail_us_state spons_dfe_state
	rename admin_us_city admin_city
	rename admin_us_state admin_state
	rename type_plan_entity_cd type_plan_entity_ind 
	rename type_dfe_plan_entity_cd type_dfe_plan_entity

	keep ack_id spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt
	
	foreach var of varlist spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt {
		capture tostring `var', replace 
	}

	gen year = `i'
	tempfile temp3`i'
	save `temp3`i''
}

use `temp32009', clear
forvalues i = 2010/2015{
	append using `temp3`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0915.dta", replace 


******************************************************************************************************************************************************************************
* Merge Form 5500 with merged auditor and fee file (Schedules H and C, merged above)

* earlier file 
use "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0915.dta", clear 
merge m:1 ack_id year using "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0915.dta" /*all merged*/
keep if _merge == 3 
capture drop _merge

* save complete 09-15 file 
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta", replace




******************************************************************************************************************************************************************************
* Append 03-08 file with 09-15 file

/*
* manual check on import -- all var names in order and same across file? yes
use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", clear
capture drop dupl image_form_id	page_id	page_row_num page_seq row_num
order _all, alpha
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", replace 

* same for the later file 
use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta", clear
order _all, alpha
*/ 

use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", clear
append using "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta"


******************************************************************************************************************************************************************************
* Checks on file structure and drop true duplicates

* multiple entries by plan (number):
duplicates drop spons_dfe_ein year spons_dfe_pn, force /*clean dupl based on plan numbers--manual check via DOL: true duplicates!*/

******************************************************************************************************************************************************************************
* Treatments

gen state = spons_dfe_state 
drop if missing(state) /*required for merge*/

capture drop L1_CPAMobility_Effec_longpanel 
capture drop STUSPS
preserve
use "./Data/Helper/LawDummiesPensionPlans.dta", clear
keep L1_CPAMobility_Effec_longpanel year STUSPS
rename STUSPS state /*state is US postal to allow for merges*/
tempfile lawdummies
save `lawdummies'
restore 
merge m:1 state year using `lawdummies'
keep if _merge == 3
drop _merge 


******************************************************************************************************************************************************************************
* Generate response

* the fees are disclosed as one or the other. checked against DOL plan lookup
replace provider_01_salary_amt = 0 if missing(provider_01_salary_amt)
replace provider_01_fees_amt = 0 if missing(provider_01_fees_amt)
gen fees = provider_01_fees_amt + provider_01_salary_amt

winsor2 fees, suffix(_w) cuts(1 99)
gen logfees = log(fees)
winsor2 logfees, suffix(_w) cuts(1 99)

******************************************************************************************************************************************************************************
* Generate controls

* size: assets
gen logassets = log(tot_assets_boy_amt)
winsor2 logassets, suffix(_w) cuts (1 99)

* contribution to assets
gen contribution2assets = tot_contrib_amt / tot_assets_boy_amt
winsor2 contribution2assets, suffix(_w) cuts(1 99)

* participants to assets
destring tot_partcp_boy_cnt, replace /*to-string before for consistency*/
gen participants2assets = tot_partcp_boy_cnt / tot_assets_boy_amt
winsor2 participants2assets, suffix(_w) cuts(1 99)

* hardtoaudit
replace joint_venture_boy_amt = 0 if missing(joint_venture_boy_amt) /*true zeros according to DoL plan lookup*/
replace real_estate_boy_amt = 0 if missing(real_estate_boy_amt) /*true zeros according to DoL plan lookup*/
gen hardtoaudit = (joint_venture_boy_amt + real_estate_boy_amt) / tot_assets_boy_amt
winsor2 hardtoaudit, suffix(_w) cuts(1 99)

* investment mgmt fees
gen investfees2assets = invst_mgmt_fees_amt / tot_assets_boy_amt
winsor2 investfees2assets, suffix(_w) cuts(1 99)

* profitibality
destring net_income_amt, gen(netincome)  
gen income2assets = netincome / tot_assets_boy_amt
winsor2 income2assets, suffix(_w) cuts(1 99)

* limited 
gen limited = (acct_performed_ltd_audit_ind == 1)

* Big 4 (raw)
gen big4 = 0
gen auditor_name = lower(accountant_firm_name)
replace big4 = 1 if strpos(auditor_name, "kpmg")
replace big4 = 1 if strpos(auditor_name, "price")
replace big4 = 1 if strpos(auditor_name, "deloit")
replace big4 = 1 if strpos(auditor_name, "ernst")

* adjust Big4 -- recursive approach: min type 1 / 2 error 
tab auditor_name if strpos(auditor_name, "kpmg") 
tab auditor_name if strpos(auditor_name, "price")
replace big4 = 0 if strpos(auditor_name, "price")
replace big4 = 1 if strpos(auditor_name, "price") & strpos(auditor_name, "waterhouse")
tab auditor_name if strpos(auditor_name, "price") & strpos(auditor_name, "waterhouse")
tab auditor_name if strpos(auditor_name, "deloit") 
tab auditor_name if strpos(auditor_name, "ernst") 
replace big4 = 0 if strpos(auditor_name, "ernst")
replace big4 = 1 if strpos(auditor_name, "ernst") & strpos(auditor_name, "young")
tab auditor_name if strpos(auditor_name, "ernst") & strpos(auditor_name, "young")

* add national audit firms -- based on statista -- top 10 audit firms -- string searches based on recursive process with min type 1 / 2 error (as before)
gen national = 0
replace national = 1 if big4 ==1
replace national = 1 if strpos(auditor_name, "rsm")
replace national = 1 if strpos(auditor_name, "thornton")
replace national = 1 if strpos(auditor_name, "bdo")
replace national = 1 if strpos(auditor_name, "clifton")
replace national = 1 if strpos(auditor_name, "mayer") & strpos(auditor_name, "hoffman")
replace national = 1 if strpos(auditor_name, "crowe")

* non Big 4
gen nonbig4 = (big4 == 0)

******************************************************************************************************************************************************************************
* FEs
capture egen state_id = group(state)
capture egen state_year_id = group(state year)
capture egen state_nonbig4_id = group(state nonbig4)
capture egen state_complex_id = group(state complex)
capture egen sponsor_id = group(spons_dfe_ein)
capture egen plan_id = group(spons_dfe_ein spons_dfe_pn)
capture egen auditfirm_id = group(accountant_firm_ein)

******************************************************************************************************************************************************************************
* Sample restriction and check

gen OHVA = (state == "OH" | state == "VA")

* duplicate check
sort spons_dfe_ein spons_dfe_pn year 
duplicates tag spons_dfe_ein spons_dfe_pn year, gen(dupl) 
assert dupl == 0
drop dupl 

* Impose sample restriction
drop if OHVA == 1 
drop if limited == 0  

* Define controls and easy-to-handle treatment
global controls contribution2assets_w  income2assets_w  hardtoaudit_w  logassets_w investfees2assets_w participants2assets_w
gen CPAMob = L1_CPAMobility_Effec_longpanel

******************************************************************************************************************************************************************************
* gen FEs 

capture gen small = (national == 0)
capture gen big = (national == 1)
capture gen CPAMob_small = small * CPAMob
capture gen CPAMob_big = big * CPAMob
capture egen state_national_id = group(state national)
capture egen national_year_id = group(national year)
capture egen state_national_year_id = group(state national year)
capture egen auditfirm_state_id = group(auditfirm state)

******************************************************************************************************************************************************************************
* Collapse regression to have at least a minimum level of obs per state-firmsize-year cell to estimate the full model

preserve
reghdfe logfees_w ${controls}, a(state_national_year_id auditfirm_state_id, savefe)
gen includedobs = (e(sample) == 1)
rename __hdfe1__ state_national_year_fees
collapse state_national_year_fees CPAMob* national (sum) includedobs, by(state_national_year_id state_national_id state_id state year)

keep if includedobs >= 5 /*minimum level of obs to identify groups*/

bysort state_id: egen stateyears = count(state_national_year_fees)
keep if stateyears == 26 /*time-group balancing*/
keep state_national_year_id stateyears
tempfile national
save `national'
restore
capture drop _merge 
merge m:1 state_national_year_id using `national'
rename _merge nationalbalancedstate


******************************************************************************************************************************************************************************
* Run models one by one to hold estimation sample constant across specifications 

capture drop inclreg*
qui reghdfe logfees_w CPAMob ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) /*2.3% decline*/
gen inclreg1 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob ${controls} if national == 1 & nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) 
gen inclreg2 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob ${controls} if national == 0 & nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) 
gen inclreg3 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob_small CPAMob_big ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id national_year_id) cluster(state_id) 
gen inclreg4 = (e(sample) == 1)
gen inclreg = (inclreg1 == 1 & (inclreg2 == 1 | inclreg3 == 1) & inclreg4 == 1)

******************************************************************************************************************************************************************************
* Estimate model on sample meeting all requirements

preserve 
keep if inclreg == 1

* Table 7, Panel B: Pension plan audit fee response 
eststo clear 
eststo: reghdfe logfees_w CPAMob ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id)
eststo: reghdfe logfees_w CPAMob_small CPAMob_big ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id national_year_id) cluster(state_id) 
test CPAMob_small CPAMob_big
esttab using "./Output/Table7_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Table 7, Panel A: Desc stats 
tabstat fees_w logfees_w ${controls} national if nationalbalancedstate == 3, s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

restore



******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* AICPA Misconduct prep and analysis 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import data received from Armitage and Moriarity (28 June 2017) and prep

* import
import excel "./Data/Quality/AICPA_Notification/Complete Data Set Disciplinary Sanctions_1999-2015.xlsx", sheet("Sheet1") firstrow clear
rename Year year
drop if year < 2003
tab year

* restriction following Armitage and Moriarity
drop if NatureofAct == "F to meet CPE requirement" 
drop if TypeofAct == "F to meet CPE requirement" 
drop if TypeofAct == "Crime" 

* gen temp variable for counting cases
gen case_count = 1

* generate temp variable for counting cases by severity
gen admonished_count = .
replace admonished_count = 1 if case_count == 1 & Outcome == "admonished"
gen suspended_count = 0
replace suspended_count = 1 if case_count == 1 & Outcome == "suspended"
gen terminated_count = 0
replace terminated_count = 1 if case_count == 1 & Outcome == "terminated"

gen total_count = .
replace total_count = 1 if admonished_count == 1
replace total_count = 1 if suspended_count == 1
replace total_count = 1 if terminated_count == 1

* weighted counted to align with EBSA analysis 
gen weighted_count = total_count
replace weighted_count = 1 if admonished_count == 1 
replace weighted_count = 2 if suspended_count == 1
replace weighted_count = 3 if terminated_count == 1 

* collapse case data to state-year panel
collapse (sum) admonished_count (sum) suspended_count (sum) terminated_count (sum) total_count (sum) weighted_count, by(State year) 
rename State ST

* save interim data
tempfile aicpa_misc
save `aicpa_misc'

* merging into a frame to capture true zeros
use "./Data/Helper/LawDummiesAICPAMisconduct.dta", clear
merge 1:1 ST year using `aicpa_misc'

* browse if _merge == 2 /*Note: these are out of sample cases ,e.g., the Al cases from Alberta, Canada*/
drop if _merge ==2

* fill in missing variables -- "true" zeros
foreach var of varlist admonished_count suspended_count terminated_count total_count weighted_count {
	replace `var' = 0 if missing(`var')
}

* drop states not in main analyses for consistency
drop if ST == "HI"
drop if ST == "PR"
drop if ST == "OH"
drop if ST == "VA"
drop if year < 2003

* Prep FEs
egen state_id = group(STATE)
xtset state_id year, yearly


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* Total count check-reg to ascertain Poisson can be run (min counts)
qui xtpoisson total_count L1_CPAMobility_Effec_longpanel i.year, fe i(state_id) vce(robust) 
gen estsample = (e(sample) == 1) 

* Table 8, Panel A: AICPA Misconduct 

* Total count spec (Poisson and OLS)
eststo clear
qui eststo: reghdfe total_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(year) cluster(state_id)
qui eststo: reghdfe total_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(state_id year) cluster(state_id)
qui eststo: xtpoisson total_count L1_CPAMobility_Effec_longpanel if estsample == 1, fe i(year) vce(robust) /*vce(robust) with specified panel id clusters standard error on the panel id level in xtpoisson (Stata default)*/
qui eststo: xtpoisson total_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, fe i(state_id) vce(robust) 
qui eststo: reghdfe weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(year) cluster(state_id)
qui eststo: reghdfe weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(state_id year) cluster(state_id)
qui eststo: xtpoisson weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, fe i(year) 
qui eststo: xtpoisson weighted_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, fe i(state_id) 
estout, keep(L1_CPAMobility_Effec_longpanel) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelA.csv", keep(L1_CPAMobility_Effec_longpanel) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace 

* Re-est Poisson spec for R-Sq output (not displayed in xtpossion, which is needed for standard error clustering) 
eststo clear
qui eststo: poisson total_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, vce(robust) 
qui eststo: poisson total_count L1_CPAMobility_Effec_longpanel i.year i.state_id if estsample == 1, vce(robust) 
qui eststo: poisson weighted_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, vce(robust) 
qui eststo: poisson weighted_count L1_CPAMobility_Effec_longpanel i.year i.state_id if estsample == 1, vce(robust) 
estout, keep(L1_CPAMobility_Effec_longpanel) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelA_R-Squared.csv", keep(L1_CPAMobility_Effec_longpanel) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* EBSA Deficient Filer prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and prep 

* Import raw data from DoL
import delimited "./Data/Quality/Data_EBSA_Form5500_Enforcement/ebsa_ocats.csv", encoding(ISO-8859-1)clear

* sample restriction to align with main analyses
drop if plan_admin_state == " "
drop if plan_admin_state == "Ohio"
drop if plan_admin_state == "Virginia"
drop if plan_admin_state == "Hawaii"
drop if plan_admin_state == "Puerto Rico"
rename plan_admin_state state

* prepare year variable
gen year = substr(final_close_date, 1, 4)
destring year, replace 
tab year
drop if year < 2003
drop if year > 2015

* restrict to deficient filers only
keep if case_type == "Deficient Filer"

* generate severity groups as well as a total in line with AICPA Misconduct Analysis
gen sevclass_1 = (penalty_amount == "$0-$10,000")
gen sevclass_2 = (penalty_amount == "$10,001 - $50,000")
gen sevclass_3 = (penalty_amount == "$50,001 - $100,000") 
gen sevclass_4 = (penalty_amount == "over $100,000")

* collapse to casecounts 
preserve
collapse (count) casecount_total=pn, by(state year) /*just count the number of incidents per state and year*/
tempfile ebsa_total
save `ebsa_total'
restore 

* collapse by sev class 
forvalues i=1/4{
	preserve
	keep if sevclass_`i' == 1
	collapse (count) casecount_`i' = pn, by(state year)
	tempfile ebsa_`i'
	save `ebsa_`i''
	restore 
}

* build frame to account for true zeros and generate treatment dummies
import excel "./Data/Helper/DataCollectionFrame.xls", sheet("Sheet1") firstrow clear
rename State state
keep state adoption_year
bysort state: keep if _n == 1 /*start with a cross section of sample states and build frame*/
expand 13
bysort state: gen year = 2002 + _n

* gen the treatment
gen CPAMob = (year - adoption_year >=0)
gen L1_CPAMob = (year - adoption_year > 0) /*here the name is Dist of Columbia - in merge file the state is named*/
replace state = "District of Columbia" if state == "Dist. of Columbia"

* merge with total file 
merge 1:1 state year using `ebsa_total' /*zero from using --> correct*/
replace casecount_total = 0 if _merge == 1 
drop _merge

* merge with the severity files
forvalues i=1/4{
	merge 1:1 state year using `ebsa_`i''
	assert _merge != 2 
	replace casecount_`i' = 0 if _merge == 1
	drop _merge
}

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Outcome prep, control prep, and analysis

******************************************************************************************************************************************************************************
* Prep FEs and set data
egen state_id = group(state)
xtset state_id year, yearly

******************************************************************************************************************************************************************************
* Prep severity weighting aligned with AICPA Misconduct Analysis (Table 8, Panel A)

gen casecount_weighted = casecount_1 * 1 + casecount_2 * 2 + casecount_3 * 3 + casecount_4 * 4

******************************************************************************************************************************************************************************
* Regression analysis

* Table 8, Panel B: EBSA Deficient Filer Cases

eststo clear
qui eststo: reghdfe casecount_total L1_CPAMob, a(year) cluster(state_id)
qui eststo: reghdfe casecount_total L1_CPAMob, a(year state_id) cluster(state_id)
qui eststo: xtpoisson casecount_total L1_CPAMob , fe i(year) vce(robust) /*vce(robust) with specified panel id clusters standard error on the panel id level (Stata default)*/
qui eststo: xtpoisson casecount_total L1_CPAMob i.year, fe i(state_id) vce(robust) 
qui eststo: reghdfe casecount_weighted L1_CPAMob, a(year) cluster(state_id)
qui eststo: reghdfe casecount_weighted L1_CPAMob, a(year state_id) cluster(state_id)
qui eststo: xtpoisson casecount_weighted L1_CPAMob, fe i(year) vce(robust) 
qui eststo: xtpoisson casecount_weighted L1_CPAMob i.year, fe i(state_id) vce(robust)
estout, keep(L1_CPAMob) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelB.csv", keep(L1_CPAMob) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace 


* Re-est Poisson spec for R-Sq output (not displayed in xtpossion, which is needed for standard error clustering)
eststo clear 
qui eststo: poisson casecount_total L1_CPAMob i.year, vce(robust) 
qui eststo: poisson casecount_total L1_CPAMob i.year i.state_id, vce(robust) 
qui eststo: poisson casecount_weighted L1_CPAMob i.year, vce(robust) 
qui eststo: poisson casecount_weighted L1_CPAMob i.year i.state_id, vce(robust)
estout, keep(L1_CPAMob) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelB_R-Squared.csv", keep(L1_CPAMob) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace 
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* CO CPA Disciplinary Actions prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and prep

******************************************************************************************************************************************************************************
* Import raw data

import delimited "./Data/Quality/CO_Quality/FRM_-_Public_Accounting_Firm_-_All_Statuses.csv", encoding(ISO-8859-1) stringc(_all) clear /*Downloaded data on 31 August 2019*/

******************************************************************************************************************************************************************************
* Clean Data: Keep only vars needed, entry and exit dates 

* keep variables of interest
keep formattedname state mailzipcode licensetype licensenumber licensefirstissuedate licenselastreneweddate licenseexpirationdate ///
	licensestatusdescription casenumber programaction disciplineeffectivedate disciplinecompletedate /*v29 empty due to csv format*/

* gen entry 
gen firmentryyear = substr(licensefirstissuedate, -4, 4)
destring firmentryyear, replace
drop if missing(firmentryyear) 

* gen exit
gen firmexityear = substr(licenseexpirationdate, -4, 4)
destring firmexityear, replace
drop if missing(firmexityear)

* align licensenumber (all 7 digits)
destring licensenumber, replace 
gen firmlicensenumber = string(licensenumber,"%07.0f")
replace firmlicensenumber = "FRM." + firmlicensenumber 

******************************************************************************************************************************************************************************
* Create tempfile that only holds discplinary actions

preserve

* keep only disciplinary actions
keep if !missing(casenumber)

* gen caseyear
gen caseyear = substr(casenumber, 1, 4)
destring caseyear, replace force
browse if missing(caseyear)
replace caseyear = 2006 if missing(caseyear) /*manually checked these individuals*/

* gen effectiveyear
gen caseeffectiveyear = substr(disciplineeffectivedate, -4,4)
destring caseeffectiveyear, replace /*here all good*/

* check for duplicates in the file
duplicates tag firmlicensenumber caseyear, gen(dupl1)
sort firmlicensenumber caseyear 
browse if dupl1 > 0 /*true duplicates --> remove*/
duplicates drop firmlicensenumber caseyear, force

* keep vars needed for tempfile
keep firmlicensenumber caseyear disciplineeffectivedate casenumber programaction disciplineeffectivedate disciplinecompletedate

* gen year for merging 
gen year = caseyear /*year of the actual violation is what is needed*/

* save tempfile 
tempfile codisc
save `codisc'


******************************************************************************************************************************************************************************
* Reload main file, drop disc action (--> drop duplicates), convert to panel, and merge in disc actions

restore

* drop the disc actions, which are now stored in the tempfile
drop casenumber programaction disciplineeffectivedate disciplinecompletedate 

* drop duplicates (these are coming from disc ations --> taken care of via storing this info in temp file)
duplicates drop firmlicensenumber, force

* convert to panel structure
gen expander = firmexityear - firmentryyear + 1
expand expander
bysort firmlicensenumber: gen sequence = _n - 1
gen year = firmentryyear + sequence

* merge in disc ations and gen outcome
merge 1:1 firmlicensenumber year using `codisc'
drop if _merge == 2
gen discipline = (_merge == 3)
drop _merge

******************************************************************************************************************************************************************************
* Sample restriction, age partition, reg prep

* restriction
keep if year >= 2003 & year <= 2015
keep if firmentryyear <= 2007 /*keep only firms active prior to treatment*/
keep if state == "CO"

* partition on Age
preserve
keep if year == 2007 
egen agequantile = xtile(firmentryyear), n(2)
keep firmlicensenumber agequantile
tempfile age
save `age'
restore
capture drop agequantile
merge m:1 firmlicensenumber using `age'

* gen split variables
gen old = (agequantile == 1)
gen young = (agequantile == 2)

* gen treatment and FEs
capture egen firm_id = group(firmlicensenumber)
capture gen L1_CPAMob_young = (year >= 2009 & young == 1)

* sample inclusion variable
capture gen oldyoung = (old == 1 | young == 1)


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* Table 8, Panel C: CPA Mobility and Discplinary Actions in Colorado
eststo clear
eststo: reghdfe discipline L1_CPAMob_young if oldyoung == 1, a(young year) cluster(firm_id)
eststo: reghdfe discipline L1_CPAMob_young if oldyoung == 1, a(firm_id year) cluster(firm_id)
esttab using "./Output/Table8_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

capture gen cpa = (industry_code == "541211")
capture gen timediff = effectiveyear - year
capture drop reltime*

gen reltimeleadlarger3 = (timediff > 3) /*before*/
label variable reltimeleadlarger3 "t≤-4"
gen reltimeleadlarger3_cpa = reltimeleadlarger3 * cpa /*before*/
label variable reltimeleadlarger3_cpa "t≤-4"

gen reltimelead3 = (timediff == 3) /*before*/
label variable reltimelead3 "t-3"
gen reltimelead3_cpa = reltimelead3 * cpa /*before*/
label variable reltimelead3_cpa "t-3"

gen reltimelead2 = (timediff == 2) /*before*/
label variable reltimelead2 "t-2"
gen reltimelead2_cpa = reltimelead2 * cpa /*before*/
label variable reltimelead2_cpa "t-2"

gen reltimelead1 = (timediff == 1) /*before*/
label variable reltimelead1 "t-1"
gen reltimelead1_cpa = reltimelead1 * cpa /*before*/
label variable reltimelead1_cpa "t-1"

gen reltime0 = (timediff == 0)
label variable reltime0 "t=0"
gen reltime0_cpa = reltime0 * cpa
label variable reltime0_cpa "t=0"

gen reltimelag1 = (timediff == -1) /*after*/
label variable reltimelag1 "t+1"
gen reltimelag1_cpa = reltimelag1 * cpa /*after*/
label variable reltimelag1_cpa "t+1"

gen reltimelag2 = (timediff == -2) /*after*/
label variable reltimelag2 "t+2"
gen reltimelag2_cpa = reltimelag2 * cpa /*after*/
label variable reltimelag2_cpa "t+2"

gen reltimelag3 = (timediff == -3) /*after*/
label variable reltimelag3 "t+3"
gen reltimelag3_cpa = reltimelag3 * cpa /*after*/
label variable reltimelag3_cpa "t+3"

gen reltimelaglarger3 = (timediff < -3) /*after*/
label variable reltimelaglarger3 "t≥4"
gen reltimelaglarger3_cpa = reltimelaglarger3 * cpa  /*after*/
label variable reltimelaglarger3_cpa "t≥4"
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
***                                                                                                                                              						   ***
***                                                                                                                                              						   ***
***                                                                                                       																   ***
*** Article: 		Labor Market Effects of Spatial Licensing Requirements: Evidence from CPA Mobility    																   ***
*** Authors: 		Stefano Cascino, Ane Tamayo, and Felix Vetter                                         																   ***
*** Journal:		Journal of Accounting Research                                                        																   ***
***                                                                                                    	  																   ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.          																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
***                                                                                                       																   ***
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************

******************************************************************************************************************************************************************************
* 0. CD to folder

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
* 1. Preparation controls used in multiple analyses

do "./Dofiles/01_CPAMob_ControlsPrep.do"

******************************************************************************************************************************************************************************
* 2. Law prediction

do "./Dofiles/02_CPAMob_AdoptionPrediction.do" 

******************************************************************************************************************************************************************************
* 3. QCEW state-level

do "./Dofiles/03_CPAMob_QCEW_State.do"

******************************************************************************************************************************************************************************
* 4. SUSB state-level

do "./Dofiles/04_CPAMob_SUSB_State.do"

******************************************************************************************************************************************************************************
* 5. QCEW county-level 

do "./Dofiles/05_CPAMob_QCEW_BorderCounty.do"

******************************************************************************************************************************************************************************
* 6. QCEW MSA-level

do "./Dofiles/06_CPAMob_QCEW_MSA.do"

******************************************************************************************************************************************************************************
* 7. AICPA MAP Survey

do "./Dofiles/07_CPAMob_AICPAMap.do"

******************************************************************************************************************************************************************************
* 8. Pension plan fees 

do "./Dofiles/08_CPAMob_PensionPlanFees.do"

******************************************************************************************************************************************************************************
* 9. AICPA Misconduct

do "./Dofiles/09_CPAMob_Qual1_AICPAMisconduct.do"

******************************************************************************************************************************************************************************
* 10. EBSA enforcement 

do "./Dofiles/10_CPAMob_Qual2_EBSA.do"

******************************************************************************************************************************************************************************
* 11. Disciplinary actions

do "./Dofiles/11_CPAMob_Qual3_CODiscAction.do"
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prep controls used in multiple analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
* GDP  

import excel "./Data/Controls/BEA_GDPbyState_clear.xls", sheet("Sheet0") firstrow clear
* rename from label 
foreach v of varlist C-W {
   local x : variable label `v'
   rename `v' gdp`x'
}
* reshape 
reshape long gdp, i(GeoFips GeoName) j(year)

* rename for consistency 
rename GeoFips area_fips

tempfile gdp
save `gdp'

******************************************************************************************************************************************************************************
* Unemployment 

import excel "./Data/Controls/UnemploymentState_cleanforimport.xlsx", sheet("Sheet1") firstrow clear
keep statefips year unemployment_peroflabor
keep if strlen(statefips) == 2
destring year, replace 
rename statefips area_fips 
replace area_fips = area_fips + "000"
rename unemployment_peroflabor unemp

******************************************************************************************************************************************************************************
* Merge macro files and generate lags 

* merge the two 
merge 1:1 area_fips year using `gdp'
keep if _merge == 3
drop _merge 
tab year

* introduce lag
replace year = year + 1
tab year 
rename gdp L1_gdp 
rename unemp L1_unemp 

* save tempfile
tempfile macrocontrols
save `macrocontrols'

******************************************************************************************************************************************************************************
* Migration controls (raw data obtained via IPUMS ACS)

use "./Data/Controls/Data_ExtendedControls/usa_00015.dta", clear /*downloaded IPUMS file*/

* housekeeping for var names
tostring statefip, gen(area_fips)
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000"

* gen variables of interest 
gen betweenstatemigration = (migrate1 == 3)
gen abroadmigration = (migrate1 == 4)

* collapse to panel structure 
collapse abroadmigration betweenstatemigration, by(area_fips year)

* gen lags
replace year = year + 1
rename abroadmigration L1_abroadmigration 
rename betweenstatemigration L1_betweenstatemigration

******************************************************************************************************************************************************************************
* Merge control files and save 

* merge migration and macro 
merge 1:1 area_fips year using `macrocontrols'
keep if _merge == 3
drop _merge 

* save new control file 
save "./Data/Controls/extendedstatecontrols.dta", replace








******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prepare law adoption file and analysis 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Data imports and preparation

******************************************************************************************************************************************************************************
* Import laws passed (hand collected, source: http://knowledgecenter.csg.org/kc/category/content-type/bos-archive)

import excel "./Data/LawPrediction/LawsByState.xls", sheet("Sheet1") firstrow clear
drop if State =="Dist. of Columbia" /*no available data*/

******************************************************************************************************************************************************************************
* Merge in FIPS indentifiers 

rename Year year
preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear 
keep State year area_fips lq_annual_avg_emplvl
tempfile merger 
save `merger'

restore 
capture drop _merge 
merge 1:1 State year using `merger'
keep if _merge == 3 /*all merged from master*/

******************************************************************************************************************************************************************************
* Merge in macro controls

capture drop _merge
merge 1:1 area_fips year using "./Data/LawPrediction/macrocontrols.dta"
keep if _merge == 3  /*all from master are merged*/
drop _merge  

******************************************************************************************************************************************************************************
* Merge in BDS

preserve
import delimited "./Data/LawPrediction/Data_BDS/bds_e_st_release.csv", encoding(ISO-8859-1)clear
gen firm_birth = estabs_entry / estabs
gen jobcreation_netbirth = net_job_creation_rate
xtset state year2, yearly
foreach var of varlist firm_birth jobcreation_netbirth {
	gen L1_`var' = L.`var'

}
keep if year >= 2003 & year <= 2015
keep state year2 firm_birth jobcreation_netbirth L1_*
* prep for merge
tostring state, gen(area_fips)
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000" 
drop state 
rename year2 year
tempfile bds
save `bds'

restore 
merge 1:1 area_fips year using `bds'
assert _merge != 1 
keep if _merge == 3
drop _merge

******************************************************************************************************************************************************************************
* Merge in political economy predictors

preserve
import excel "./Data/LawPrediction/CPAMob_PoliticalEconomy.xlsx", sheet("Sheet1") firstrow clear
drop K L M N O P Q /*drop notes from hand collection*/
drop if State == "" /*drop empty lines in hand collection sheet*/
drop if State == "DC" /*no legislation vars, as before*/
tempfile polecon
save `polecon'

restore 
merge m:1 State using `polecon' 
keep if _merge == 3 
drop _merge  


******************************************************************************************************************************************************************************
* Merge in State Board of Accountancy predictors from Colbert and Murray (2013)

* interim step: merge in cross walk file to merge with Colbert and Murray (2013) data
preserve
import excel "./Data/LawPrediction/StatesPostalCodeCrosswald.xlsx", sheet("Sheet1") clear
gen StatePostal = substr(A, -2, .)
gen State = substr(A, 1, strlen(A) - 5)
tempfile postcode
save `postcode'
restore
merge m:1 State using `postcode'
assert _merge != 1 
keep if _merge == 3
drop _merge 

* merge in
merge m:1 StatePostal using "./Data/LawPrediction/ColbertMurray.dta"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Variable prep and analysis

******************************************************************************************************************************************************************************
* Variable prep 

* Set STCox structure for checking
egen id = group(State)
gen coxtime = year - 2002 

* Set failure event
sort State year
by State: gen CPAMob = (_n ==_N)
stset coxtime, id(id) failure(CPAMob==1)
* check Cox structure
* sts graph

* Prep bill load variables
replace Session = "1" if Session =="" 
gen nosessionid = (Session == "na" | Session == "0")
* When there is no session, nothing can be passed
foreach var of varlist IntroBill IntroResol EnactBill EnactResol {
	replace `var' = "0" if nosessionid == 1

}
replace LengthSession = "0" if nosessionid == 1 

* Prep Dem / Rep variables
destring Senate_Dem, replace force
destring Senate_Rep, replace force
gen Senate_Total = Senate_Dem + Senate_Rep
gen Senate_Dem_Share = Senate_Dem / Senate_Total
* For Nebraska, assume equal splits (house / senate and rep / dem)
replace Senate_Total = 25 if State == "Nebraska"
replace Senate_Dem_Share = 0.5 if State == "Nebraska"

* House share and total
destring House_Dem, replace force
destring House_Rep, replace force
gen House_Total = House_Dem + House_Rep
gen House_Dem_Share = House_Dem / House_Total
* For Nebraska, assume equal splits (house / senate and rep / dem)
replace House_Total = 25 if State == "Nebraska"
replace House_Dem_Share = 0.5 if State == "Nebraska"

* Total state split
gen HouseSenate_Dem = House_Dem + Senate_Dem
gen HouseSenate_Rep = House_Rep + Senate_Rep
gen HouseSenate_Total = HouseSenate_Dem + HouseSenate_Rep
gen HouseSenate_Dem_Share = HouseSenate_Dem / HouseSenate_Total
replace HouseSenate_Total = 49 if State == "Nebraska"
replace HouseSenate_Dem_Share = 0.5 if State == "Nebraska"

* Bills enacted / introduced 
destring EnactBill, replace force
destring IntroBill, replace force
gen logbills = log(1 + IntroBill)
gen logenact = log(1 + EnactBill)

* Pol economy: Mob Task Force
gen mobilitytaskforce = (MobTaskForce != "0") 

* Pol economy: board structure
gen CPAinBoard = CPABoard / TotalBoard
gen Big4inBoard = Big4Board / TotalBoard

* Pol economy: Colbert / Murray 
gen pubprac = real(PUBPRAC) 
gen fundingautonomy = FUND_AUT
gen localCPAs = NO_LOCAL / (NO_NAT + NO_LOCAL) 

******************************************************************************************************************************************************************************
* Wage and employment trends, difference to mean

preserve

* import QCEW state-level data for years 2000 and 2005
foreach i in 2000 2005 {
	import delimited "./Data/Census/Data_QCEW/QCEW_RAWData/`i'.annual.singlefile.csv", stringcols(_all) clear
	keep if industry_code == "541211" /*keep CPAs only*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if agglvl_code == "58" /*keep only state-level 6 digits*/
	gen excludestate = (area_fips == "51000" | area_fips == "39000" | area_fips == "78000" | area_fips == "72000" | area_fips == "15000")
	drop if excludestate == 1 /*align with main sample*/
	rename avg_annual_pay pay
	rename annual_avg_emplvl emp
	keep area_fips year pay emp
	tempfile qcew`i'
	save "`qcew`i''"
}
use "`qcew2000'", clear
append using "`qcew2005'"
ds area_fips, not
foreach v of var `r(varlist)' {
	destring `v', replace
}
egen state_id = group(area_fips)
xtset state_id year, yearly
gen logpay = log(pay)
gen logemp = log(emp)

* gen difference over time
gen d5logpay = logpay - L5.logpay
gen d5logemp = logemp - L5.logemp

* gen difference to mean
keep if year == 2005 /*calc diffs to national */
egen logpaymean = mean(logpay)
egen logempmean = mean(logemp)
gen logpaydiff = logpay - logpaymean
gen logempdiff = logemp - logempmean
keep area_fips d*log* logpaydiff logempdiff
tempfile qcewcontrols
save `qcewcontrols'
restore
capture drop _merge 
merge m:1 area_fips using  `qcewcontrols'
keep if _merge == 3

******************************************************************************************************************************************************************************
* Prediction analysis 

* Table 1, Panel B: CPA Mobility Adoption Prediction 
preserve
qui stcox logpaydiff logempdiff d5logpay d5logemp pubprac localCPAs i.mobilitytaskforce i.fundingautonomy L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
keep if (e(sample)) == 1 /*estimate full model to ascertain equal obs across specs*/
eststo clear
eststo: stcox logpaydiff logempdiff d5logpay d5logemp, cluster(id)
eststo: stcox pubprac localCPAs i.mobilitytaskforce i.fundingautonomy, cluster(id)
eststo: stcox L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth
eststo: stcox Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
eststo: stcox logpaydiff logempdiff d5logpay d5logemp pubprac localCPAs i.mobilitytaskforce i.fundingautonomy L1_unemprate L1_realgdp L1_firm_birth L1_jobcreation_netbirth Senate_Dem_Share House_Dem_Share logbills logenact, cluster(id)
esttab using "./Output/Table1_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace eform
restore 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW state-level prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Read raw data and prep file

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import QCEW data


filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace
use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename /*needed for getting the years*/ 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "58" /*keep only State-level 6 digits*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" | industry_code == "541110" /*keep only CPAs and lawyers*/
	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Clean file / var formats

******************************************************************************************************************************************************************************
* Var format
ds area_fips industry_code qtr filename disclosure_code_str lq_disclosure_code_str oty_disclosure_code_str, not
foreach v of var `r(varlist)' {
	destring `v', replace 
}

******************************************************************************************************************************************************************************
* Clean up state variable

* interim step to get the state name: merge with a name cross walk file 
merge m:1 area_fips using "./Data/Census/Data_QCEW/FIPSandNamesCrosswalk.dta" 
assert _merge != 1
keep if _merge == 3
drop _merge

* area_title
split area_title, p(" -- ")
replace area_title = area_title1
drop area_title1 area_title2


******************************************************************************************************************************************************************************
* Sample screen

* toss out excluded sates
gen excludestate = (area_title == "Virginia" | area_title == "Ohio" | area_title == "Virgin Islands" | area_title == "Puerto Rico" | area_title == "Hawaii")
drop if excludestate == 1

* sample period alignment
keep if year >= 2003

******************************************************************************************************************************************************************************
* Merge in controls

merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta" 
keep if _merge == 3
drop _merge 

******************************************************************************************************************************************************************************
* Analyses prep

* gen shorter var names for handling
gen pay = avg_annual_pay
gen emp = annual_avg_emplvl

* gen main responses
gen logpay = log(pay) 
gen logemp = log(emp)

* gen weights -- empshares
egen occ_year_id = group(industry_code year)
preserve 
collapse (sum) emp, by(occ_year_id)
rename emp emptotal
tempfile emptotal
save `emptotal'
restore 
merge m:1 occ_year_id using `emptotal'
assert _merge == 3 
drop _merge
gen empshare = emp / emptotal

* gen x-section treatment dummies for DiDiD and sample inclusion
capture gen cpa = (industry_code == "541211")
capture gen lawyer = (industry_code == "541110")
capture gen cpalawyer = (cpa == 1 | lawyer == 1)

* merge in treatment dummies
capture drop L1_CPAMobility_Effec_longpanel
preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear
keep area_fips year adoption_year L1_CPAMobility_Effec_longpanel
tempfile mobilitydummies
save `mobilitydummies'
restore 
capture drop _merge 
merge m:1 area_fips year using `mobilitydummies'
drop if _merge == 2
drop _merge 

* shorten name for handling in DiDiD
rename L1_CPAMobility_Effec_longpanel L1_CPAMob
replace L1_CPAMob = 1 if year > 2015 /*all sample states adopted then*/

* gen DiDiD treatment dummies
gen L1_CPAMob_cpa = L1_CPAMob * cpa 

* gen event time dummies for graph analysis
gen effectiveyear = adoption_year
do "./Dofiles/reltimedummmies.do" /*outsourced event-time dummy generator for brevity*/

* gen FEs 
egen cpa_year = group(cpa year)
egen state_year = group(area_fips year)
egen state_occ_id = group(industry_code area_fips)
egen state_id = group(area_fips)

* gen logestab 
gen logestab = log(annual_avg_estabs)

* gen empl2estab
gen empl2estab = annual_avg_emplvl / annual_avg_estabs
gen logempl2estab = log(empl2estab)

* gen estabshares 
bysort occ_year_id: egen estabtotal = total(annual_avg_estabs)
gen estabshare = annual_avg_estabs / estabtotal


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analyses: QCEW state-Level

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Figure 1

******************************************************************************************************************************************************************************
* Figure 1, Panel A: Timing reg CPA only 

capture gen zero = 0 
label variable zero "t-1" 
reghdfe logpay reltimeleadlarger3_cpa reltimelead3_cpa reltimelead2_cpa zero /*reltimelead1_cpa */  reltime0_cpa reltimelag1_cpa ///
	reltimelag2_cpa reltimelag3_cpa reltimelaglarger3_cpa ///
	L1_unemp L1_gdp L1_abroadmigration L1_betweenstatemigration if cpa == 1 [aw = empshare], a(state_id year) cluster(state_id)
coefplot, keep(reltime* zero) omitted vertical ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(4.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelA.pdf", as(pdf) replace
graph close

******************************************************************************************************************************************************************************
* Figure 1, Panel C: Timing reg CPA vs lawyers

capture gen zero = 0 
label variable zero "t-1" 
reghdfe logpay reltimeleadlarger3_cpa reltimelead3_cpa reltimelead2_cpa zero /* reltimelead1_cpa */ reltime0_cpa reltimelag1_cpa ///
	reltimelag2_cpa reltimelag3_cpa reltimelaglarger3_cpa if cpalawyer == 1 [aw = empshare], a(cpa_year state_year state_occ_id) cluster(state_id)
coefplot, keep(reltime* zero) omitted vertical ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(4.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelC.pdf", as(pdf) replace
graph close
	
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 2

******************************************************************************************************************************************************************************
* Table 2, Panel A: Descriptives

* CPA only
tabstat pay logpay emp logemp L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1 ///
	, s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

******************************************************************************************************************************************************************************
* Table 2, Panel B: Baseline wage

eststo clear 
eststo: reghdfe logpay L1_CPAMob if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_unemp if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_gdp if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_betweenstatemigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_abroadmigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMob L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1 [aw = empshare], a(state_occ_id cpa_year) cluster(state_id)
esttab using "./Output/Table2_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
* Table 2, Panel C: Employment

eststo clear
eststo: reghdfe logemp L1_CPAMob if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_unemp if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_gdp if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_betweenstatemigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_abroadmigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob L1_unemp L1_gdp L1_betweenstatemigration L1_abroadmigration if cpa == 1, a(state_occ_id cpa_year) cluster(state_id)
esttab using "./Output/Table2_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel B: Triple Diff CPA vs lawyers

eststo clear 
eststo: reghdfe logpay L1_CPAMob_cpa if cpalawyer == 1 [aw = empshare], a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logemp L1_CPAMob_cpa if cpalawyer == 1, a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logempl2estab L1_CPAMob_cpa if cpalawyer == 1 [aw = estabshare], a(cpa_year state_year state_occ_id) cluster(state_id)
eststo: reghdfe logestab L1_CPAMob_cpa if cpalawyer == 1, a(cpa_year state_year state_occ_id) cluster(state_id)
esttab using "./Output/Table3_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* SUSB State-level prep and analyses 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Read in and clean data

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Raw data processing 

filelist, dir("./Data/Census/Data_SUSB/SUSB_6digitnaics/") pat("*.txt") save("./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta") replace

use "./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_SUSB/SUSB_6digitnaics/SUSB_datasets.dta" in `i', clear
	local f = dirname + "/" + filename
	local g = filename
	import delimited "`f'", encoding(ISO-8859-1) clear
	keep if naics == "541211" | naics == "541110" /*keep CPAs and Lawyers for triple and quadruple diff*/
	gen source = "`f'"
	tempfile save`i'
	save "`save`i''"
}

*append all files
use "`save1'", clear
	forvalues i=2/`obs' {
    append using "`save`i''"
}


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Clean up file 

* keep only state-level variables
drop if state == 0 /*drop national-level variables */

* gen year variable 
capture drop year
gen year = substr(source, -8, 4)
destring year, replace

* sort data
sort state statedscr entrsize year

* gen area fips / statename for merges
gen area_fips = state
tostring area_fips, replace 
replace area_fips = "0" + area_fips if strlen(area_fips) == 1
replace area_fips = area_fips + "000"
gen statename = statedscr

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Variable consistency checks and adjustments

* sort out differences in variable names (not definitions) across SUSB year files variable by variable: 

******************************************************************************************************************************************************************************
* Employment

tab year if missing(empl) /*this is as of 2011*/
tab year if missing(empl_n) /*this is before 2011*/
gen empltemp = .
replace empltemp = empl if year < 2011
replace empltemp = empl_n if year >= 2011
tab year if missing(empltemp) /* none missing*/
drop empl empl_n
rename empltemp empl

******************************************************************************************************************************************************************************
* Payroll

tab year if missing(payr) /*as of 2011 missing*/
tab year if missing(payr_n) /*up until 2010*/
gen paytemp = .
replace paytemp = payr if year < 2011
replace paytemp = payr_n if year >= 2011
tab year if missing(paytemp) /*done - none missing*/
drop payr payr_n
rename paytemp payr 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis prep

******************************************************************************************************************************************************************************
* Merge in treatment dummies

preserve
use "./Data/Helper/LawDummiesCensusState.dta", clear
keep area_fips year adoption_year L1_CPAMobility_Effec_longpanel
tempfile mobilitydummies
save `mobilitydummies'

restore 
* merge m:1 (multiple size classes per area_fips and year)
merge m:1 area_fips year using `mobilitydummies'
keep if _merge == 3 
drop _merge 

******************************************************************************************************************************************************************************
*  Gen outcome variables 

gen pay = payr / empl 
gen logpay = log(pay)
gen logempl = log(empl)
gen logestb = log(estb)
gen emp2estb = empl / estb
gen logemp2estb = log(emp2estb)

tab year if missing(logpay)
tab entrsize year if missing(logpay)  /*Tests are conducted on Class 5 (<20) and Class 6 (20-99) to max coverage -- next step*/

******************************************************************************************************************************************************************************
* Gen and keep size buckets 

gen smallfirm = (entrsize == 5) /*<20 employees*/
gen largefirm = (entrsize == 6) /*20-99 employees*/
gen inclfirm = (entrsize == 5 | entrsize == 6)
keep if inclfirm == 1

******************************************************************************************************************************************************************************
* Gen industry FE for DiDiD and DiDiDiD

gen cpa = (naics == "541211")
gen lawyer = (naics == "541110")

******************************************************************************************************************************************************************************
* Gen FEs 

capture drop *_id
egen state_id = group(area_fips)
egen state_naics_id = group(area_fips naics)
egen state_size_id = group(area_fips entrsize)
egen state_naics_size_id = group(area_fips naics entrsize)
egen year_id = group(year)
egen state_year_id = group(area_fips year)
egen naics_year_id = group(naics year)
egen size_year_id = group(entrsize year)
egen naics_size_year_id = group(naics entrsize year)
egen state_naics_year_id = group(area_fips naics year)  
egen state_size_year_id = group(area_fips entrsize year)

******************************************************************************************************************************************************************************
* Gen treatments 

* Shorten var name for DiDiD and DiDiDiD treatment dummy construction
rename L1_CPAMobility_Effec_longpanel L1_CPAMob 

capture gen L1_CPAMob_small = L1_CPAMob * smallfirm * cpa
capture gen L1_CPAMob_small_cpa = L1_CPAMob * smallfirm * cpa

capture gen L1_CPAMob_large = L1_CPAMob * largegfirm * cpa
capture gen L1_CPAMob_large_cpa = L1_CPAMob * largefirm * cpa

******************************************************************************************************************************************************************************
* Sample screens

* drop states 
drop if statename == "Ohio" | statename == "Virginia"

* balance
bysort state_naics_size_id: egen totalobs = count(logpay)
qui sum totalobs
keep if totalobs == `r(max)'

******************************************************************************************************************************************************************************
* Calc weights

capture drop empltotal 
capture drop estbshare
bysort naics_size_year_id: egen empltotal = total(empl)
gen emplshare = empl / empltotal
bysort naics_size_year_id: egen estbtotal3 = total(estb)
gen estbshare = estb / estbtotal


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Restriction on double-matched state-years

* restrict to sample with full coverage to estimate quadruple diff
qui reghdfe logpay L1_CPAMob_small_cpa [aw = emplshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl1 = (e(sample) == 1)
qui reghdfe logempl L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl2 = (e(sample) == 1)
qui reghdfe logemp2estb L1_CPAMob_small_cpa [aw = estbshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl3 = (e(sample) == 1)
qui reghdfe logestb L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
gen incl4 = (e(sample) == 1)
keep if incl1 == 1 & incl2 == 1 & incl3 == 1 & incl4 == 1

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel C: Quadruple diff spec 

eststo clear
eststo: reghdfe logpay L1_CPAMob_small_cpa [aw = emplshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logempl L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logemp2estb L1_CPAMob_small_cpa [aw = estbshare], a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
eststo: reghdfe logestb L1_CPAMob_small_cpa, a(state_naics_size_id state_naics_year_id state_size_year_id naics_size_year_id) cluster(state_id)
esttab using "./Output/Table3_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 3, Panel A: CPA only estimates

* keep only CPAs and re-prep weights
keep if cpa == 1

capture drop emplshare 
capture drop emptotal 
capture drop estbtotal 
capture drop estbshare
bysort entrsize year: egen emptotal = total(empl)
gen empshare = empl / emptotal
bysort entrsize year: egen estbtotal = total(estb)
gen estbshare = estb / estbtotal

* merge in state-year controls -- before: state-year FE, controls absorbed
capture drop _merge 
merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta"
assert _merge != 1
drop if _merge == 2 /*years available in QCEW but not in SUSB (starting in 2007)*/
drop _merge 

* Table 3, Panel A: CPA small vs Large
eststo clear
eststo: reghdfe logpay L1_CPAMob_small if cpa == 1 [aw = empshare], a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logempl L1_CPAMob_small if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logemp2estb L1_CPAMob_small [aw = estbshare] if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
eststo: reghdfe logestb L1_CPAMob_small if cpa == 1 , a(state_size_id size_year_id state_year_id) cluster(state_id)
esttab using "./Output/Table3_PanelA.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Graphical Analysis -- note: SUSB program starts in 2007 --> fewer pre-period data points

******************************************************************************************************************************************************************************
* Event time dummies 

gen eventtime = year - adoption_year
gen lead1small = (eventtime == -1 & smallfirm == 1)
label var lead1small "t=-1"
gen leadlarger2small = (eventtime <= -2 & smallfirm == 1)
label var leadlarger2small "t≤-2"
gen lag0small = (eventtime == 0 & smallfirm == 1)
label var lag0small "t=0"
gen lag1small = (eventtime == 1 & smallfirm == 1)
label var lag1small "t=1"
gen lag2small = (eventtime == 2 & smallfirm == 1)
label var lag2small "t=2"
gen lag3small = (eventtime == 3 & smallfirm == 1)
label var lag3small "t=3"
gen laglarger4small = (eventtime >= 4 & smallfirm == 1)
labe var laglarger4small "t≥4"

******************************************************************************************************************************************************************************
* Figure 1, Panel B: Event time plot SUSB-state CPA large vs small 

capture gen zero = 0
label var zero "t=-1"
reghdfe logpay leadlarger2small zero /* lead1small */ lag0small lag1small lag2small lag3small laglarger4small if cpa == 1 [aw = empshare], ///
	a(state_year_id state_size_id size_year_id) cluster(state_id)
coefplot, keep(*small zero) vert omit ///
	yscale(r(-0.1 0.1)) ylabel(-0.1(.05)0.1) ci(95) ciopt(recast(rcap) lcolor(gs0)) mcolor(gs0) lcolor(gs0) mcolor(gs0) xline(2.5, lpattern(dash) lcolor(gs0)) graphregion(color(white)) 
graph export "./Output/Figure1_PanelB.pdf", as(pdf) replace
graph close 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW border-county-level prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and clean data

******************************************************************************************************************************************************************************
* Import raw QCEW data

filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace
use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename /*needed for getting the years*/ 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "78" /*keep only 6 digits naics county-level variables*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" /*keep only CPAs*/
	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}

* var format 
ds area_fips industry_code qtr filename disclosure_code_str lq_disclosure_code_str oty_disclosure_code_str, not
foreach v of var `r(varlist)' {
	destring `v', replace 
}


******************************************************************************************************************************************************************************		 
* Align sample period

* align sample period with state-level QCEW analyses
tab year
keep if year >= 2003

******************************************************************************************************************************************************************************		 
* Merge in treatments and sample screen

******************************************************************************************************************************************************************************
* Merge prep and merge with law dummies

* (temp) recode the state indetifiers for the merges
gen area_fips_merge_temp = substr(area_fips,1,2) + "000" /*only need the first two--treatment assignment at the state level*/
rename area_fips area_fips_original /*renaming required for merge*/
rename area_fips_merge_temp area_fips
merge m:1 area_fips year using "./Data/Helper/LawDummiesCensusCounty.dta"
rename area_fips area_fips_merge_temp /*reverse renaming*/
rename area_fips_original area_fips  

* tab year if _merge == 1 /*not matched from master*/
drop if year <= 2002 /*consistency with State-level and Dummy file*/

* impose sample restriction
drop if area_fips_merge_temp == "15000" /*Hawaii*/
drop if area_fips_merge_temp == "72000" /*Puerto Rico*/
drop if area_fips_merge_temp == "78000" /*Virgin Island*/ 

* adjust treatment dummies to be equal to 1 for later years, when all sample states adopted
replace L1_CPAMobility_Effec_longpanel = 1 if year >= 2015 
drop _merge 


******************************************************************************************************************************************************************************		 
* Balancing check

egen county_id = group(area_fips)
xtset county_id year, yearly

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Merge in identifiers and control variables

******************************************************************************************************************************************************************************
* Merge with the adjanct county file

capture drop _merge
merge m:1 area_fips using "./Data/Helper/CPAMobility_AdjanctCountiesBorderIDs.dta"
tab statepair if _merge == 2
tab homestate if _merge == 2
drop if _merge == 2
gen neighbor_county = 0
replace neighbor_county = 1 if _merge == 3
drop _merge

******************************************************************************************************************************************************************************
* Merge in mapping info

capture drop _merge
merge m:1 area_fips using "./Data/Helper/us_county_db.dta" 
tab NAME if _merge == 2 
drop if _merge == 2 
drop _merge

******************************************************************************************************************************************************************************
* Merge state-level controls 

rename area_fips area_fips_original /*renaming needed for merge -- macro controls except for unemp (merged in below) are only available at the state level*/
rename area_fips_merge_temp area_fips
capture drop _merge
merge m:1 area_fips year using "./Data/Controls/extendedstatecontrols.dta"
rename area_fips area_fips_merge_temp /*reverse renaming*/ 
rename area_fips_original area_fips 
drop if _merge != 3

******************************************************************************************************************************************************************************
* Merge county-level controls 

preserve
use "./Data/Controls/CPAMobility_BLS_LAUS_CountyEmployment.dta", clear
keep area_fips area_title_LAUS year unemploymentrate
replace year = year + 1 /*gen lagged structure*/
rename unemploymentrate L1_unemploymentrate
* Rename county level control for consistency and clarity
rename L1_unemploymentrate L1_unemp_county 
tempfile unempcounty
save `unempcounty'
restore

capture drop _merge
merge 1:1 area_fips year using `unempcounty'
keep if _merge ==3

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis and variable preparation

******************************************************************************************************************************************************************************
* Prep response vars

* Prep pay 
gen pay = avg_annual_pay
gen logpay = log(avg_annual_pay)

* Prep emp
rename annual_avg_emplvl emp
gen logemp = log(emp)


******************************************************************************************************************************************************************************
* Prep FEs 

qui capture drop border_id
capture egen border_id = group(BORDINDX)
capture egen county_id = group(area_fips)
capture egen state_id = group(area_fips_merge_temp)

******************************************************************************************************************************************************************************
* Introduce non-overlaping treatdate condition

capture drop adoption_year
gen adoption_year = .
bysort area_fips year: replace adoption_year = year if CPAMobility_Effec == 1


levelsof statefip, local(states)
foreach s of local states {
	sum adoption_year if statefip == `s'
	replace adoption_year = r(max) if statefip == `s' & missing(adoption_year)
}

capture drop diff_adoption 
gen diff_adoption = 0
levelsof border_id, local(levels)
foreach l of local levels {
	sum adoption_year if border_id == `l'
	replace diff_adoption = 1 if r(sd) != 0 & border_id == `l'

}

******************************************************************************************************************************************************************************
* Figure 2: Border counties with non-overlapping treatment dates 

spmap neighbor_county using us_county_coord if year == 2005 & stateicp != 81, id(id) fcolor(Blues) clmethod(unique)
graph export "./Output/Figure2.pdf", as(pdf) replace

******************************************************************************************************************************************************************************
* Keep only diff-adoption counties 

keep if diff_adoption == 1

******************************************************************************************************************************************************************************
* Further est sample conditions to ascertain estimation on consistently disclosing--that is, no Census confidentiality--counties

* gen counter for balancing
sort area_fips year
bysort area_fips: gen counter = _N

* condition: only disclosing counties--that is, counties displaying above-zero employees throughout
capture drop minemp
bysort county_id: egen minemp = min(emp)

******************************************************************************************************************************************************************************
* Calc weights

capture drop empshare emptotal
bysort year: egen emptotal = total(emp)
gen empshare = emp / emptotal

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis 

preserve 

* impose restriction
keep if counter == 15 & neighbor_county == 1 & border_id != 74 & diff_adoption == 1 & !missing(logpay) & minemp > 0 /*BorderID 74 is Lake Michigan*/

* impose reg restriction to ascertain same obs across specifications
qui reghdfe logpay L1_CPAMobility_Effec_longpanel [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
keep if (e(sample)) == 1

* Table 4, Panel B: Border-county analysis
eststo clear
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_betweenstatemigration L1_abroadmigration [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logpay L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration [aw = empshare], a(county_id i.border_id#i.year) cluster(state_id)

eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_betweenstatemigration L1_abroadmigration, a(county_id i.border_id#i.year) cluster(state_id)
eststo: reghdfe logemp L1_CPAMobility_Effec_longpanel L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration, a(county_id i.border_id#i.year) cluster(state_id)
esttab using "./Output/Table4_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Table 4, Panel A: Desc stats 
tabstat pay logpay emp logemp L1_unemp_county L1_gdp L1_betweenstatemigration L1_abroadmigration, ///
	s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

restore 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* QCEW MSA-level prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and clean data

******************************************************************************************************************************************************************************
* Import Census MSA data

filelist, dir("./Data/Census/Data_QCEW/QCEW_RAWData/") pat("*.csv") save("./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta") replace

use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta", clear 
local obs = _N
forvalues i=1/`obs' {
	use "./Data/Census/Data_QCEW/QCEW_RAWData/csv_qcew_cpas_datasets.dta" in `i', clear
	local d = dirname + "/" + filename
	local f = filename 
	import delimited using "`d'", stringcols(_all) clear 
	gen filename = "`f'"
	keep if agglvl_code == "48" /*keep only MSA-level 6 digits -- Census codes available here: https://data.bls.gov/cew/doc/titles/agglevel/agglevel_titles.htm*/
	keep if own_code == "5" /*keep only privately owned*/
	keep if industry_code == "541211" | industry_code == "541110" /*keep only CPAs and lawyers*/

	foreach var of varlist *disclosure_code {
		gen `var'_str = "null" 
		if missing(`var') {
			replace `var'_str = "blank"
		}
		else {
			replace `var'_str = "N"
		}
		drop `var'
	}
	tempfile save`i'
	save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''"
}

******************************************************************************************************************************************************************************
* Clean up and adjust variable formatting

drop oty_* lq_* filename qtr disclosure_code_st size_code own_code total_annual_wages taxable_annual_wages annual_avg_wkly_wage annual_contributions 

foreach var of varlist year annual_avg_estabs annual_avg_emplvl avg_annual_pay {
	destring `var', replace 
}

******************************************************************************************************************************************************************************
* Merge in GDP MSA 

preserve
import delimited "./Data/Controls/bea_gdp_annual_naicsall_msa_clean.csv", encoding(ISO-8859-1)clear stringc(_all)
foreach var of varlist v3-v19 {
   local x : variable label `var' 
   rename `var' msagdp`x'
   destring msagdp`x', replace force
}
reshape long msagdp, i(geofips geoname) j(year)
* adjust to msa fips 
gen area_fips = "C" + substr(geofips, 1, 4)
drop geofips
tempfile msagdp
save `msagdp'
restore 
merge m:1 area_fips year using `msagdp'
drop if _merge == 2
drop _merge 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Analysis and variable preparation

* gen industry ID 
encode industry_code, gen(industry_id) label(industry_id)

* rename variables
gen pay = avg_annual_pay
gen logpay = log(pay)
gen emp = annual_avg_emplvl
gen logemp = log(emp)
gen logmsagdp = log(msagdp)

* difference variables
capture drop msa_industry_id 
egen msa_industry_id = group(area_fips industry_id)
xtset msa_industry_id year, yearly
foreach var of varlist logpay logmsagdp {
	capture gen d1`var' = (`var' - L1.`var') 
}

* IDs and screen
gen cpa = (industry_code == "541211")
gen lawyer = (industry_code == "541110")
keep if cpa == 1 | lawyer == 1 


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Helper variables and screen

* est periods
gen postperiod = (year >= 2014)
gen prepreriod = (year >= 2002 & year <= 2005)
gen estperiod = (prepreriod == 1 | postperiod == 1)

* label for outputs
label define cpal 0 "Lawyers" 1 "CPAs" 
label values cpa cpal 
label define postperiodl 0 "Pre-Period" 1 "Post-Period" 
label values postperiod postperiodl 
label define preperiodl 0 "Post-Period" 1 "Pre-Period" 
label values prepreriod preperiodl 
label var d1logpay ""

* min data availablity criterion
egen msa_id = group(area_fips)
gen inclobs = (!missing(d1logpay))
bysort msa_id cpa estperiod: egen totalinclobs = total(inclobs)
keep if totalinclobs >= 5

* calc empshares
bysort cpa year: egen totalemp = total(emp)
gen empshare = emp / totalemp


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Figure 3, Panel A and B: Visual sens analysis 

binscatter d1logpay d1logmsagdp [aw = empshare] if prepreriod == 1 & cpa == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("CPAs: Pre-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelA-1.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if postperiod == 1 & cpa == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("CPAs: Post-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelA-2.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if prepreriod == 1 & lawyer == 1 /// 
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("Lawyers: Pre-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelB-1.pdf", as(pdf) replace
graph close

binscatter d1logpay d1logmsagdp [aw = empshare] if postperiod == 1 & lawyer == 1 ///
	, reportreg yscale(r(0.01 0.06)) ylabel(0.01(0.01)0.06) xscale(r(-0.05 0.1)) xlabel(-0.05(0.05)0.1) ///
	title("Lawyers: Post-Period") ytitle("∆LogWage") xtitle("∆LogGDP") 
graph export "./Output/Figure3_PanelB-2.pdf", as(pdf) replace
graph close


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel A: Sens analysis regression

gen d1logmsagdp_post = d1logmsagdp * postperiod
gen d1logmsagdp_pre = d1logmsagdp * prepreriod

gen d1logmsagdp_cpa = d1logmsagdp * cpa
gen d1logmsagdp_lawyer = d1logmsagdp * lawyer
gen d1logmsagdp_cpa_post = d1logmsagdp * cpa * postperiod
gen d1logmsagdp_lawyer_post = d1logmsagdp * lawyer * postperiod

* Desc Stats 
gen cpalawyer = (cpa == 1 | lawyer == 1)
tabstat pay logpay d1logpay if cpa == 1 & estperiod == 1 & !missing(d1logpay) & !missing(d1logmsagdp), s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
tabstat pay logpay d1logpay if lawyer == 1 & estperiod == 1 & !missing(d1logpay) & !missing(d1logmsagdp), s(n mean sd p1 p25 p50 p75 p99) columns(statistics)
tabstat msagdp logmsagdp d1logmsagdp if estperiod == 1 & !missing(d1logpay) & cpalawyer == 1, s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* Table 5, Panel A: Reg | profession 
eststo clear
eststo: reg d1logpay d1logmsagdp_post d1logmsagdp postperiod [aw = empshare] if cpa == 1 & estperiod == 1, cluster(msa_id)
eststo: reg d1logpay d1logmsagdp_post d1logmsagdp postperiod [aw = empshare] if lawyer == 1 & estperiod == 1, cluster(msa_id)
esttab using "./Output/Table5_PanelA.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Aux reg: for difference in coefficient test 
capture egen cpa_year_id = group(cpa year)
capture egen cpa_period_id = group(cpa postperiod)
capture egen msa_id = group(area_fips)
capture egen msa_cpa_id = group(area_fips cpa)

reg d1logpay d1logmsagdp_cpa_post d1logmsagdp_cpa d1logmsagdp_lawyer_post d1logmsagdp_lawyer i.cpa i.postperiod i.postperiod#i.cpa [aw = empshare] if estperiod == 1, cluster(msa_id)
test d1logmsagdp_cpa_post = d1logmsagdp_lawyer_post


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel B: Volatility analysis 

eststo clear

* Table 5, Panel B, Col 1
preserve
keep if estperiod == 1
local testvar d1logpay
collapse (sd) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa post, vce(robust)
restore 

* Table 5, Panel B, Col2
preserve
keep if estperiod == 1
local testvar d1logpay
collapse (iqr) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa post, vce(robust)
restore 
esttab using "./Output/Table5_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Table 5, Panel C: Convergence analysis 

eststo clear

* Tabel 5, Panel C, Col1 
preserve
keep if estperiod == 1
local testvar logpay
collapse (sd) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa postperiod, vce(robust)
restore 

* Tabel 5, Panel C, Col2 
preserve
keep if estperiod == 1
local testvar logpay
collapse (iqr) `testvar' [aw = emp], by(cpa year prepreriod postperiod)
gen cpapost = postperiod * cpa
eststo: reg `testvar' cpapost cpa postperiod, vce(robust)
restore 
esttab using "./Output/Table5_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* AICPA MAP Survey prep and analyses

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Raw data import, prep, and checks

filelist, dir("./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/") pat("*.xlsx") save("./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta") replace

use "./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta", clear /*23 obs - correct*/
local obs = _N
forvalues i=1/`obs' {
	use "./Data/AICPA/Data_MapSurvey/CPAMobility_Staffing/CPAMobility_Staffing_StataImport/MAPSurvey_Staffing_datasets.dta" in `i', clear
	local f = dirname + "/" + filename
	local g = filename
	import excel "`f'", sheet("Sheet1") allstring clear
	drop if missing(A) /*drop empty columns in collection sheet*/
	drop B /*drop notes column */

	sxpose, clear /*ssc install, if required*/
	renvars , map(`=word("@", 1)') /*take the first row as variable name*/
	drop if _n == 1 /*drop empty row -- collection notes*/
	rename Variable size_class
	capture replace size_class = "single_medium_2002" if size_class == "single_medium_2004" /*correcting a labeling issues in raw files*/
	drop if missing(size_class) /*drop empty cells*/

	ds size_class, not
	foreach var in `r(varlist)' {
		gen r_`var' = real(`var')
		drop `var' 
		rename r_`var' `var'  
	}	
	gen year = substr(size_class, length(size_class) - 3, 4)
	gen size_class_temp = substr(size_class, 1, length(size_class) - 5)
	drop size_class
	rename size_class_temp size_class
	gen source = "`f'"
	gen source_file = "`g'"
	tempfile save`i'
	save "`save`i''"
}

* append all files
use "`save1'", clear
	forvalues i=2/`obs' {
    append using "`save`i''"
}
/*71 vars = 69 vars + source var + filename var --> correct*/
/*805 obs = 35 obs per state * 23 states = 805 -- > correct*/


* Introduce area fips for merging in dummy structure
replace source_file = subinstr(source_file, "StataImport_Staffing_", "", .)
replace source_file = subinstr(source_file, ".xlsx", "", .)
gen area_fips = "."
replace area_fips = "04000" if source_file == "Arizona"
replace area_fips = "06000" if source_file == "California"
replace area_fips = "08000" if source_file == "Colorado"
replace area_fips = "12000" if source_file == "Florida"
replace area_fips = "13000" if source_file == "Georgia"
replace area_fips = "17000" if source_file == "Illinois"
replace area_fips = "18000" if source_file == "Indiana"
replace area_fips = "22000" if source_file == "Louisiana"
replace area_fips = "24000" if source_file == "Maryland"
replace area_fips = "25000" if source_file == "Massachusetts"
replace area_fips = "26000" if source_file == "Michigan"
replace area_fips = "27000" if source_file == "Minnesota"
replace area_fips = "34000" if source_file == "NewJersey"
replace area_fips = "36000" if source_file == "NewYork"
replace area_fips = "37000" if source_file == "NorthCarolina"
replace area_fips = "39000" if source_file == "Ohio"
replace area_fips = "40000" if source_file == "Oklahoma"
replace area_fips = "41000" if source_file == "Oregon"
replace area_fips = "42000" if source_file == "Pennsylvania"
replace area_fips = "48000" if source_file == "Texas"
replace area_fips = "51000" if source_file == "Virginia"
replace area_fips = "53000" if source_file == "Washington"
replace area_fips = "55000" if source_file == "Wisconsin"

* year variable
capture drop r_year
gen r_year = real(year) 
drop year
rename r_year year

* save temp set
preserve


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Preparation of law dummy file (adjust to accommodate biennial structure of the MAP survey) and sample screen

* merge in adjusted dummy structure
import excel "./Data/Helper/CPAMobility_MAPSurvey_Adoption.xlsx", sheet("Mobility_Effective") firstrow clear
reshape long v_, i(effective_sequence stateicp_string stateicp stateicp_valuelabel ST STATE statefip area_fips Effective_Date) j(year)

* gen long panel variable
sort ST year

gen CPAMobility_Effec_longpanel = 0
replace CPAMobility_Effec_longpanel = 1 if v_ == 1 
sort ST year
by ST: replace CPAMobility_Effec_longpanel = 1 if  CPAMobility_Effec_longpanel[_n-1] == 1
 
* generate merge variable
gen area_fips_temp = string(area_fips)
drop area_fips
rename area_fips_temp area_fips
replace area_fips = "0" + area_fips if length(area_fips) == 4

* save dummy file
tempfile dummies
save `dummies'

* use master and merge in law dummies
restore
merge m:1 area_fips year using `dummies' /*all matched from master*/
tab STATE if _merge == 2
codebook STATE if _merge == 2 /*27 states --> correct */
keep if _merge == 3
drop _merge

* drops
drop if source_file == "Ohio"
drop if source_file == "Virginia"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Prep and aux regressions 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Compensation prep

* Missing Check
foreach var of varlist comp_partner comp_director comp_sr_manager comp_manager comp_sr_associate comp_associate comp_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}
egen comp_all = rmean(comp_partner comp_director comp_sr_manager comp_manager comp_sr_associate comp_associate)
gen logcomp_all = log(comp_all)
egen comp_senior = rmean(comp_partner )
gen logcomp_senior = log(comp_senior)
egen comp_mid = rmean(comp_director comp_sr_manager comp_manager)
gen logcomp_mid = log(comp_mid)
egen comp_low = rmean(comp_sr_associate comp_associate)
gen logcomp_low = log(comp_low)

gen non_miss = 0 
replace non_miss = 1 if !missing(comp_senior) & !missing(comp_mid) & !missing(comp_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Billing rate prep

foreach var of varlist avgbill_partner avgbill_director avgbill_sr_manager avgbill_manager avgbill_sr_associate avgbill_associate avgbill_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}

* generate position partitions
egen avgbill_all = rmean( avgbill_partner avgbill_director avgbill_sr_manager avgbill_manager avgbill_sr_associate avgbill_associate)
gen logavgbill_all = log(avgbill_all)
egen avgbill_senior = rmean( avgbill_partner )
gen logavgbill_senior = log(avgbill_senior)
egen avgbill_mid = rmean( avgbill_director avgbill_sr_manager avgbill_manager)
gen logavgbill_mid = log(avgbill_mid)
egen avgbill_low = rmean( avgbill_sr_associate avgbill_associate)
gen logavgbill_low = log(avgbill_low)

gen non_miss_bill = 0 
replace non_miss_bill = 1 if !missing(avgbill_senior) & !missing(avgbill_mid) & !missing(avgbill_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Hours billed prep

foreach var of varlist avgcharg_partner avgcharg_director avgcharg_sr_manager avgcharg_manager avgcharg_sr_associate avgcharg_associate avgcharg_newprof {
  replace `var' = .  if `var' == 0
  gen log`var' = log(`var')
}

* generate different position partitions
egen avgcharg_all = rmean( avgcharg_partner avgcharg_director avgcharg_sr_manager avgcharg_manager avgcharg_sr_associate avgcharg_associate)
gen logavgcharg_all = log(avgcharg_all)
egen avgcharg_senior = rmean( avgcharg_partner)
gen logavgcharg_senior = log(avgcharg_senior)
egen avgcharg_mid = rmean( avgcharg_director avgcharg_sr_manager avgcharg_manager)
gen logavgcharg_mid = log(avgcharg_mid)
egen avgcharg_low = rmean( avgcharg_sr_associate avgcharg_associate)
gen logavgcharg_low = log(avgcharg_low)

gen non_miss_charge = 0 
replace non_miss_charge = 1 if !missing(avgcharg_senior) & !missing(avgcharg_mid) & !missing(avgcharg_low)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* condition to ascertain constant estimation sample across specs
capture drop triple_condition
gen triple_condition = 0
replace triple_condition = 1 if non_miss == 1 & non_miss_bill == 1 & non_miss_charge == 1 

* gen FE
egen state_id = group(area_fips)

* Table 6, Panel B: Baseline
eststo clear		
foreach var of varlist logcomp_all avgbill_all logavgcharg_all {
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2014 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)	
}	
esttab using "./Output/Table6_PanelB.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel C: Logratio test comp
gen logseniorlow = logcomp_senior - logcomp_low
gen logseniormid = logcomp_senior - logcomp_mid
gen logmidlow = logcomp_mid - logcomp_low

eststo clear
foreach var of varlist logseniorlow logseniormid logmidlow {	
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelC.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel D: Logratio for billing rates
gen logbill_seniorlow = logavgbill_senior - logavgbill_low
gen logbill_seniormid = logavgbill_senior - logavgbill_mid
gen logbill_midlow = logavgbill_mid - logavgbill_low


eststo clear
foreach var of varlist logbill_seniorlow logbill_seniormid logbill_midlow {	
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelD.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel E: Logratios for hours 
gen loghour_seniorlow = logavgcharg_senior - logavgcharg_low
gen loghour_seniormid = logavgcharg_senior - logavgcharg_mid
gen loghour_midlow = logavgcharg_mid - logavgcharg_low

eststo clear
foreach var of varlist loghour_seniorlow loghour_seniormid loghour_midlow {
	qui eststo: reghdfe `var' i.CPAMobility_Effec_longpanel if triple_condition == 1 & year <= 2015 & size_class =="all" [aw = number_firms], a(state_id year) cluster(state_id)
}
esttab using "./Output/Table6_PanelE.csv", replace b(3) se(3) ar2 star(* 0.10 ** 0.05 *** 0.01)

* Table 6, Panel A: Descriptive stats 

* compensation
tabstat comp_all logcomp_all comp_senior comp_mid comp_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* billing rates
tabstat avgbill_all avgbill_senior avgbill_mid avgbill_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

* hours charged 
tabstat avgcharg_all logavgcharg_all avgcharg_senior avgcharg_mid avgcharg_low if triple_condition == 1 & year <= 2015 & size_class =="all", s(n mean sd p1 p25 p50 p75 p99) columns(statistics)

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Pension plan prep and analysis 

* File Structure:
* Require three IRS forms: Form 5500 for the plan information, Schedule H for the auditor EIN, and Schedule C for audit fees.
* File imports are split into a 2003-2008 part and 2009-2015 part. Import is split to accommodate file format differences. 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Imports and merges

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* 2003 to 2008 files


******************************************************************************************************************************************************************************
* Extract auditor and financial info from Schedule H 
 
forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_H_`i'.csv",  encoding(ISO-8859-1) clear 
	keep filing_id accountant_firm_name accountant_firm_ein acct_performed_ltd_audit_ind acct_opin_not_on_file_ind acctnt_opinion_type_ind /*controls:*/ joint_venture_boy_amt real_estate_boy_amt tot_assets_boy_amt tot_liabilities_boy_amt tot_contrib_amt professional_fees_amt contract_admin_fees_amt invst_mgmt_fees_amt other_admin_fees_amt tot_admin_expenses_amt aggregate_proceeds_amt net_income_amt
	drop if missing(accountant_firm_ein) 
	tostring accountant_firm_ein, replace /*convert to string for consistency across files and years*/
	tostring net_income_amt, replace force 
	gen year = `i'
	tempfile temp`i'
	save `temp`i''
}
use `temp2003', clear
forvalues i = 2004/2008{
	append using `temp`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0308.dta", replace 

******************************************************************************************************************************************************************************
* Extract fees from Schedule C Part 1

forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_C_PART1_`i'.csv", encoding(ISO-8859-1) clear 
	drop if missing(provider_01_ein)
	tostring provider_01_ein, replace
	tostring provider_01_srvc_code, replace
	gen year = `i'
	tempfile temp2`i'
	save `temp2`i''
}
use `temp22003', clear
forvalues i = 2004/2008{
	append using `temp2`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0308.dta", replace 


******************************************************************************************************************************************************************************
* Merge Schedule H and Schedule C

use "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0308.dta", clear
gen provider_01_ein = accountant_firm_ein /*adjust for merge*/
duplicates tag filing_id provider_01_ein year, gen(dupl)
duplicates drop filing_id provider_01_ein year, force /*5 true duplicates*/
merge 1:m filing_id provider_01_ein year using "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0308.dta"
keep if _merge == 3
drop _merge 

* keep only main service provider role
capture drop dupl
duplicates tag filing_id year, gen(dupl)
tab dupl
sort filing_id year
* browse if dupl > 0 /*Only keep the main service--that is, audit not preparation*/
capture drop dupl
duplicates tag filing_id year row_num, gen(dupl) 
tab dupl 
sort filing_id year row_num 
by filing_id year: gen counter = _n 
keep if counter == 1 /*keep main role*/
drop counter 

* save merged file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0308.dta", replace 


******************************************************************************************************************************************************************************
* Extract location and other plan info from Form 5500

forvalues i=2003/2008 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/f_5500_`i'.csv", encoding(ISO-8859-1) clear
	* keep location and info for controls
	keep filing_id spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state preparer_name preparer_ein preparer_city preparer_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt
	* Convert the variables to strings except for filing id for merges and consistency
	foreach var of varlist spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state preparer_name preparer_ein preparer_city preparer_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt {
		capture tostring `var', replace 
	}

	gen year = `i'
	tempfile temp3`i'
	save `temp3`i''
}

use `temp32003', clear
forvalues i = 2004/2008{
	append using `temp3`i''
}

* save file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0308.dta", replace 

******************************************************************************************************************************************************************************
* Merge Form 5500 with merged auditor and fee File (Schedules H and C, merged above)

use "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0308.dta", clear 
merge m:1 filing_id year using "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0308.dta"
keep if _merge == 3 
drop _merge

* drop vars no longer needed and save merged file for handling
capture drop dupl image_form_id	page_id	page_row_num page_seq row_num
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", replace


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* 2009 to 2015 files

******************************************************************************************************************************************************************************
* Extract Auditor and financial info from Schedule H

forvalues i = 2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_H_`i'_latest.csv", encoding(ISO-8859-1) clear
	keep ack_id accountant_firm_name accountant_firm_ein acct_performed_ltd_audit_ind acct_opin_not_on_file_ind acctnt_opinion_type_cd /*controls:*/ joint_venture_boy_amt real_estate_boy_amt tot_assets_boy_amt tot_liabilities_boy_amt tot_contrib_amt professional_fees_amt contract_admin_fees_amt invst_mgmt_fees_amt other_admin_fees_amt tot_admin_expenses_amt aggregate_proceeds_amt net_income_amt
	rename acctnt_opinion_type_cd acctnt_opinion_type_ind /*rename the only one that is not consistent other than the identifier*/
	drop if missing(accountant_firm_ein) 
	tostring accountant_firm_ein, replace /*align format*/
    tostring net_income_amt, replace force /*align format*/
	gen year = `i'
	tempfile temp`i'
	save `temp`i''
}

use `temp2009', clear
forvalues i = 2010/2015{
	append using `temp`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0915.dta", replace 


******************************************************************************************************************************************************************************
* Extract fees from Schedule C Part 1

forvalues i=2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/F_SCH_C_PART1_ITEM2_`i'_latest.csv", encoding(ISO-8859-1) clear
	* drop the following that cannot be obtained in prior files 
	drop prov_other_foreign_address1 prov_other_foreign_address2 prov_other_foreign_city prov_other_foreign_prov_state prov_other_foreign_cntry prov_other_foreign_postal_cd
	
	* rename the variables to correspond with the 2003-2008 file (imported above)
	rename provider_other_name provider_01_name 
	rename provider_other_ein provider_01_ein
	gen provider_01_position = "" /*does not exist in the 09 and onwards file*/
	rename provider_other_relation provider_01_relation
	rename prov_other_tot_ind_comp_amt provider_01_salary_amt
	rename provider_other_direct_comp_amt provider_01_fees_amt
	gen provider_01_srvc_code = "." /*converted to string in earlier import*/
	drop provider_other_amt_formula_ind
	drop prov_other_elig_ind_comp_ind 
	drop prov_other_indirect_comp_ind

	* convert the service provider ein to string variable for consistency with 2003-2008 file
	* also have to rename the variable to correspond to the id in the merging file 
	tostring provider_01_ein, replace
	tostring provider_01_srvc_code, replace
	
	* gen year and tempfile
	gen year = `i'
	tempfile temp2`i'
	save `temp2`i''
}

use `temp22009', clear
forvalues i = 2010/2015{
	append using `temp2`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0915.dta", replace 


******************************************************************************************************************************************************************************
* Merge Schedule H and Schedule C

use "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_h_0915.dta", clear
gen provider_01_ein = accountant_firm_ein /*this needs to be the same in the files*/
duplicates tag ack_id provider_01_ein year, gen(dupl)
tab dupl /*no duplicates here*/
drop dupl 
capture duplicates drop ack_id provider_01_ein year, force /* no obs deleted*/

merge 1:m ack_id provider_01_ein year using "./Data/PensionPlans/Data_Form5500_AuditFees/schedule_c_0915.dta" 

* as before, missing are the ones with below threshold or missing auditor ein info, drop
keep if _merge == 3
drop _merge 

* check and inspect duplicates
capture drop dupl
duplicates tag ack_id year, gen(dupl)
tab dupl

* keep main function only (see 2003-2008 import)
* browse if dupl > 0 
sort ack_id year row_order
by ack_id year: gen counter = _n 
keep if counter == 1 
drop counter   

capture drop dupl
duplicates tag ack_id year, gen(dupl)
tab dupl /*de-duplicated*/
drop dupl

* drop row_order for file concistency with 2003-2008 imports
drop row_order 

* save merged file for handling
save "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0915.dta", replace 


******************************************************************************************************************************************************************************
* Extract location and other plan info from Form 5500

forvalues i=2009/2015 {
	import delimited "./Data/PensionPlans/Data_Form5500_AuditFees/RawData_Unzipped/f_5500_`i'_latest.csv", encoding(ISO-8859-1) clear
	
	* renaming and format adjustment for consistency with 2003-2008 import
	rename spons_dfe_mail_us_city spons_dfe_city
	rename spons_dfe_mail_us_state spons_dfe_state
	rename admin_us_city admin_city
	rename admin_us_state admin_state
	rename type_plan_entity_cd type_plan_entity_ind 
	rename type_dfe_plan_entity_cd type_dfe_plan_entity

	keep ack_id spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt
	
	foreach var of varlist spons_dfe_ein spons_dfe_pn plan_name sponsor_dfe_name spons_dfe_city spons_dfe_state admin_name admin_ein admin_city admin_state tot_partcp_boy_cnt collective_bargain_ind type_plan_entity_ind type_dfe_plan_entity partcp_account_bal_cnt {
		capture tostring `var', replace 
	}

	gen year = `i'
	tempfile temp3`i'
	save `temp3`i''
}

use `temp32009', clear
forvalues i = 2010/2015{
	append using `temp3`i''
}
save "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0915.dta", replace 


******************************************************************************************************************************************************************************
* Merge Form 5500 with merged auditor and fee file (Schedules H and C, merged above)

* earlier file 
use "./Data/PensionPlans/Data_Form5500_AuditFees/form5500_0915.dta", clear 
merge m:1 ack_id year using "./Data/PensionPlans/Data_Form5500_AuditFees/planauditors_0915.dta" /*all merged*/
keep if _merge == 3 
capture drop _merge

* save complete 09-15 file 
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta", replace




******************************************************************************************************************************************************************************
* Append 03-08 file with 09-15 file

/*
* manual check on import -- all var names in order and same across file? yes
use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", clear
capture drop dupl image_form_id	page_id	page_row_num page_seq row_num
order _all, alpha
save "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", replace 

* same for the later file 
use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta", clear
order _all, alpha
*/ 

use "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0308.dta", clear
append using "./Data/PensionPlans/Data_Form5500_AuditFees/pensionplanaudits_0915.dta"


******************************************************************************************************************************************************************************
* Checks on file structure and drop true duplicates

* multiple entries by plan (number):
duplicates drop spons_dfe_ein year spons_dfe_pn, force /*clean dupl based on plan numbers--manual check via DOL: true duplicates!*/

******************************************************************************************************************************************************************************
* Treatments

gen state = spons_dfe_state 
drop if missing(state) /*required for merge*/

capture drop L1_CPAMobility_Effec_longpanel 
capture drop STUSPS
preserve
use "./Data/Helper/LawDummiesPensionPlans.dta", clear
keep L1_CPAMobility_Effec_longpanel year STUSPS
rename STUSPS state /*state is US postal to allow for merges*/
tempfile lawdummies
save `lawdummies'
restore 
merge m:1 state year using `lawdummies'
keep if _merge == 3
drop _merge 


******************************************************************************************************************************************************************************
* Generate response

* the fees are disclosed as one or the other. checked against DOL plan lookup
replace provider_01_salary_amt = 0 if missing(provider_01_salary_amt)
replace provider_01_fees_amt = 0 if missing(provider_01_fees_amt)
gen fees = provider_01_fees_amt + provider_01_salary_amt

winsor2 fees, suffix(_w) cuts(1 99)
gen logfees = log(fees)
winsor2 logfees, suffix(_w) cuts(1 99)

******************************************************************************************************************************************************************************
* Generate controls

* size: assets
gen logassets = log(tot_assets_boy_amt)
winsor2 logassets, suffix(_w) cuts (1 99)

* contribution to assets
gen contribution2assets = tot_contrib_amt / tot_assets_boy_amt
winsor2 contribution2assets, suffix(_w) cuts(1 99)

* participants to assets
destring tot_partcp_boy_cnt, replace /*to-string before for consistency*/
gen participants2assets = tot_partcp_boy_cnt / tot_assets_boy_amt
winsor2 participants2assets, suffix(_w) cuts(1 99)

* hardtoaudit
replace joint_venture_boy_amt = 0 if missing(joint_venture_boy_amt) /*true zeros according to DoL plan lookup*/
replace real_estate_boy_amt = 0 if missing(real_estate_boy_amt) /*true zeros according to DoL plan lookup*/
gen hardtoaudit = (joint_venture_boy_amt + real_estate_boy_amt) / tot_assets_boy_amt
winsor2 hardtoaudit, suffix(_w) cuts(1 99)

* investment mgmt fees
gen investfees2assets = invst_mgmt_fees_amt / tot_assets_boy_amt
winsor2 investfees2assets, suffix(_w) cuts(1 99)

* profitibality
destring net_income_amt, gen(netincome)  
gen income2assets = netincome / tot_assets_boy_amt
winsor2 income2assets, suffix(_w) cuts(1 99)

* limited 
gen limited = (acct_performed_ltd_audit_ind == 1)

* Big 4 (raw)
gen big4 = 0
gen auditor_name = lower(accountant_firm_name)
replace big4 = 1 if strpos(auditor_name, "kpmg")
replace big4 = 1 if strpos(auditor_name, "price")
replace big4 = 1 if strpos(auditor_name, "deloit")
replace big4 = 1 if strpos(auditor_name, "ernst")

* adjust Big4 -- recursive approach: min type 1 / 2 error 
tab auditor_name if strpos(auditor_name, "kpmg") 
tab auditor_name if strpos(auditor_name, "price")
replace big4 = 0 if strpos(auditor_name, "price")
replace big4 = 1 if strpos(auditor_name, "price") & strpos(auditor_name, "waterhouse")
tab auditor_name if strpos(auditor_name, "price") & strpos(auditor_name, "waterhouse")
tab auditor_name if strpos(auditor_name, "deloit") 
tab auditor_name if strpos(auditor_name, "ernst") 
replace big4 = 0 if strpos(auditor_name, "ernst")
replace big4 = 1 if strpos(auditor_name, "ernst") & strpos(auditor_name, "young")
tab auditor_name if strpos(auditor_name, "ernst") & strpos(auditor_name, "young")

* add national audit firms -- based on statista -- top 10 audit firms -- string searches based on recursive process with min type 1 / 2 error (as before)
gen national = 0
replace national = 1 if big4 ==1
replace national = 1 if strpos(auditor_name, "rsm")
replace national = 1 if strpos(auditor_name, "thornton")
replace national = 1 if strpos(auditor_name, "bdo")
replace national = 1 if strpos(auditor_name, "clifton")
replace national = 1 if strpos(auditor_name, "mayer") & strpos(auditor_name, "hoffman")
replace national = 1 if strpos(auditor_name, "crowe")

* non Big 4
gen nonbig4 = (big4 == 0)

******************************************************************************************************************************************************************************
* FEs
capture egen state_id = group(state)
capture egen state_year_id = group(state year)
capture egen state_nonbig4_id = group(state nonbig4)
capture egen state_complex_id = group(state complex)
capture egen sponsor_id = group(spons_dfe_ein)
capture egen plan_id = group(spons_dfe_ein spons_dfe_pn)
capture egen auditfirm_id = group(accountant_firm_ein)

******************************************************************************************************************************************************************************
* Sample restriction and check

gen OHVA = (state == "OH" | state == "VA")

* duplicate check
sort spons_dfe_ein spons_dfe_pn year 
duplicates tag spons_dfe_ein spons_dfe_pn year, gen(dupl) 
assert dupl == 0
drop dupl 

* Impose sample restriction
drop if OHVA == 1 
drop if limited == 0  

* Define controls and easy-to-handle treatment
global controls contribution2assets_w  income2assets_w  hardtoaudit_w  logassets_w investfees2assets_w participants2assets_w
gen CPAMob = L1_CPAMobility_Effec_longpanel

******************************************************************************************************************************************************************************
* gen FEs 

capture gen small = (national == 0)
capture gen big = (national == 1)
capture gen CPAMob_small = small * CPAMob
capture gen CPAMob_big = big * CPAMob
capture egen state_national_id = group(state national)
capture egen national_year_id = group(national year)
capture egen state_national_year_id = group(state national year)
capture egen auditfirm_state_id = group(auditfirm state)

******************************************************************************************************************************************************************************
* Collapse regression to have at least a minimum level of obs per state-firmsize-year cell to estimate the full model

preserve
reghdfe logfees_w ${controls}, a(state_national_year_id auditfirm_state_id, savefe)
gen includedobs = (e(sample) == 1)
rename __hdfe1__ state_national_year_fees
collapse state_national_year_fees CPAMob* national (sum) includedobs, by(state_national_year_id state_national_id state_id state year)

keep if includedobs >= 5 /*minimum level of obs to identify groups*/

bysort state_id: egen stateyears = count(state_national_year_fees)
keep if stateyears == 26 /*time-group balancing*/
keep state_national_year_id stateyears
tempfile national
save `national'
restore
capture drop _merge 
merge m:1 state_national_year_id using `national'
rename _merge nationalbalancedstate


******************************************************************************************************************************************************************************
* Run models one by one to hold estimation sample constant across specifications 

capture drop inclreg*
qui reghdfe logfees_w CPAMob ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) /*2.3% decline*/
gen inclreg1 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob ${controls} if national == 1 & nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) 
gen inclreg2 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob ${controls} if national == 0 & nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id) 
gen inclreg3 = (e(sample) == 1)
qui reghdfe logfees_w CPAMob_small CPAMob_big ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id national_year_id) cluster(state_id) 
gen inclreg4 = (e(sample) == 1)
gen inclreg = (inclreg1 == 1 & (inclreg2 == 1 | inclreg3 == 1) & inclreg4 == 1)

******************************************************************************************************************************************************************************
* Estimate model on sample meeting all requirements

preserve 
keep if inclreg == 1

* Table 7, Panel B: Pension plan audit fee response 
eststo clear 
eststo: reghdfe logfees_w CPAMob ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id year) cluster(state_id)
eststo: reghdfe logfees_w CPAMob_small CPAMob_big ${controls} if nationalbalancedstate == 3, a(auditfirm_state_id national_year_id) cluster(state_id) 
test CPAMob_small CPAMob_big
esttab using "./Output/Table7_PanelB.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace

* Table 7, Panel A: Desc stats 
tabstat fees_w logfees_w ${controls} national if nationalbalancedstate == 3, s(n mean sd p1 p25 p50 p75 p99) columns(statistics) 

restore




******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* AICPA Misconduct prep and analysis 

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import data received from Armitage and Moriarity (28 June 2017) and prep

* import
import excel "./Data/Quality/AICPA_Notification/Complete Data Set Disciplinary Sanctions_1999-2015.xlsx", sheet("Sheet1") firstrow clear
rename Year year
drop if year < 2003
tab year

* restriction following Armitage and Moriarity
drop if NatureofAct == "F to meet CPE requirement" 
drop if TypeofAct == "F to meet CPE requirement" 
drop if TypeofAct == "Crime" 

* gen temp variable for counting cases
gen case_count = 1

* generate temp variable for counting cases by severity
gen admonished_count = .
replace admonished_count = 1 if case_count == 1 & Outcome == "admonished"
gen suspended_count = 0
replace suspended_count = 1 if case_count == 1 & Outcome == "suspended"
gen terminated_count = 0
replace terminated_count = 1 if case_count == 1 & Outcome == "terminated"

gen total_count = .
replace total_count = 1 if admonished_count == 1
replace total_count = 1 if suspended_count == 1
replace total_count = 1 if terminated_count == 1

* weighted counted to align with EBSA analysis 
gen weighted_count = total_count
replace weighted_count = 1 if admonished_count == 1 
replace weighted_count = 2 if suspended_count == 1
replace weighted_count = 3 if terminated_count == 1 

* collapse case data to state-year panel
collapse (sum) admonished_count (sum) suspended_count (sum) terminated_count (sum) total_count (sum) weighted_count, by(State year) 
rename State ST

* save interim data
tempfile aicpa_misc
save `aicpa_misc'

* merging into a frame to capture true zeros
use "./Data/Helper/LawDummiesAICPAMisconduct.dta", clear
merge 1:1 ST year using `aicpa_misc'

* browse if _merge == 2 /*Note: these are out of sample cases ,e.g., the Al cases from Alberta, Canada*/
drop if _merge ==2

* fill in missing variables -- "true" zeros
foreach var of varlist admonished_count suspended_count terminated_count total_count weighted_count {
	replace `var' = 0 if missing(`var')
}

* drop states not in main analyses for consistency
drop if ST == "HI"
drop if ST == "PR"
drop if ST == "OH"
drop if ST == "VA"
drop if year < 2003

* Prep FEs
egen state_id = group(STATE)
xtset state_id year, yearly


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* Total count check-reg to ascertain Poisson can be run (min counts)
qui xtpoisson total_count L1_CPAMobility_Effec_longpanel i.year, fe i(state_id) vce(robust) 
gen estsample = (e(sample) == 1) 

* Table 8, Panel A: AICPA Misconduct 

* Total count spec (Poisson and OLS)
eststo clear
qui eststo: reghdfe total_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(year) cluster(state_id)
qui eststo: reghdfe total_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(state_id year) cluster(state_id)
qui eststo: xtpoisson total_count L1_CPAMobility_Effec_longpanel if estsample == 1, fe i(year) vce(robust) /*vce(robust) with specified panel id clusters standard error on the panel id level in xtpoisson (Stata default)*/
qui eststo: xtpoisson total_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, fe i(state_id) vce(robust) 
qui eststo: reghdfe weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(year) cluster(state_id)
qui eststo: reghdfe weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, a(state_id year) cluster(state_id)
qui eststo: xtpoisson weighted_count L1_CPAMobility_Effec_longpanel if estsample == 1, fe i(year) 
qui eststo: xtpoisson weighted_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, fe i(state_id) 
estout, keep(L1_CPAMobility_Effec_longpanel) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelA.csv", keep(L1_CPAMobility_Effec_longpanel) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace 

* Re-est Poisson spec for R-Sq output (not displayed in xtpossion, which is needed for standard error clustering) 
eststo clear
qui eststo: poisson total_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, vce(robust) 
qui eststo: poisson total_count L1_CPAMobility_Effec_longpanel i.year i.state_id if estsample == 1, vce(robust) 
qui eststo: poisson weighted_count L1_CPAMobility_Effec_longpanel i.year if estsample == 1, vce(robust) 
qui eststo: poisson weighted_count L1_CPAMobility_Effec_longpanel i.year i.state_id if estsample == 1, vce(robust) 
estout, keep(L1_CPAMobility_Effec_longpanel) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelA_R-Squared.csv", keep(L1_CPAMobility_Effec_longpanel) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace 



******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* EBSA Deficient Filer prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and prep 

* Import raw data from DoL
import delimited "./Data/Quality/Data_EBSA_Form5500_Enforcement/ebsa_ocats.csv", encoding(ISO-8859-1)clear

* sample restriction to align with main analyses
drop if plan_admin_state == " "
drop if plan_admin_state == "Ohio"
drop if plan_admin_state == "Virginia"
drop if plan_admin_state == "Hawaii"
drop if plan_admin_state == "Puerto Rico"
rename plan_admin_state state

* prepare year variable
gen year = substr(final_close_date, 1, 4)
destring year, replace 
tab year
drop if year < 2003
drop if year > 2015

* restrict to deficient filers only
keep if case_type == "Deficient Filer"

* generate severity groups as well as a total in line with AICPA Misconduct Analysis
gen sevclass_1 = (penalty_amount == "$0-$10,000")
gen sevclass_2 = (penalty_amount == "$10,001 - $50,000")
gen sevclass_3 = (penalty_amount == "$50,001 - $100,000") 
gen sevclass_4 = (penalty_amount == "over $100,000")

* collapse to casecounts 
preserve
collapse (count) casecount_total=pn, by(state year) /*just count the number of incidents per state and year*/
tempfile ebsa_total
save `ebsa_total'
restore 

* collapse by sev class 
forvalues i=1/4{
	preserve
	keep if sevclass_`i' == 1
	collapse (count) casecount_`i' = pn, by(state year)
	tempfile ebsa_`i'
	save `ebsa_`i''
	restore 
}

* build frame to account for true zeros and generate treatment dummies
import excel "./Data/Helper/DataCollectionFrame.xls", sheet("Sheet1") firstrow clear
rename State state
keep state adoption_year
bysort state: keep if _n == 1 /*start with a cross section of sample states and build frame*/
expand 13
bysort state: gen year = 2002 + _n

* gen the treatment
gen CPAMob = (year - adoption_year >=0)
gen L1_CPAMob = (year - adoption_year > 0) /*here the name is Dist of Columbia - in merge file the state is named*/
replace state = "District of Columbia" if state == "Dist. of Columbia"

* merge with total file 
merge 1:1 state year using `ebsa_total' /*zero from using --> correct*/
replace casecount_total = 0 if _merge == 1 
drop _merge

* merge with the severity files
forvalues i=1/4{
	merge 1:1 state year using `ebsa_`i''
	assert _merge != 2 
	replace casecount_`i' = 0 if _merge == 1
	drop _merge
}

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Outcome prep, control prep, and analysis

******************************************************************************************************************************************************************************
* Prep FEs and set data
egen state_id = group(state)
xtset state_id year, yearly

******************************************************************************************************************************************************************************
* Prep severity weighting aligned with AICPA Misconduct Analysis (Table 8, Panel A)

gen casecount_weighted = casecount_1 * 1 + casecount_2 * 2 + casecount_3 * 3 + casecount_4 * 4

******************************************************************************************************************************************************************************
* Regression analysis

* Table 8, Panel B: EBSA Deficient Filer Cases

eststo clear
qui eststo: reghdfe casecount_total L1_CPAMob, a(year) cluster(state_id)
qui eststo: reghdfe casecount_total L1_CPAMob, a(year state_id) cluster(state_id)
qui eststo: xtpoisson casecount_total L1_CPAMob , fe i(year) vce(robust) /*vce(robust) with specified panel id clusters standard error on the panel id level (Stata default)*/
qui eststo: xtpoisson casecount_total L1_CPAMob i.year, fe i(state_id) vce(robust) 
qui eststo: reghdfe casecount_weighted L1_CPAMob, a(year) cluster(state_id)
qui eststo: reghdfe casecount_weighted L1_CPAMob, a(year state_id) cluster(state_id)
qui eststo: xtpoisson casecount_weighted L1_CPAMob, fe i(year) vce(robust) 
qui eststo: xtpoisson casecount_weighted L1_CPAMob i.year, fe i(state_id) vce(robust)
estout, keep(L1_CPAMob) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelB.csv", keep(L1_CPAMob) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace 


* Re-est Poisson spec for R-Sq output (not displayed in xtpossion, which is needed for standard error clustering)
eststo clear 
qui eststo: poisson casecount_total L1_CPAMob i.year, vce(robust) 
qui eststo: poisson casecount_total L1_CPAMob i.year i.state_id, vce(robust) 
qui eststo: poisson casecount_weighted L1_CPAMob i.year, vce(robust) 
qui eststo: poisson casecount_weighted L1_CPAMob i.year i.state_id, vce(robust)
estout, keep(L1_CPAMob) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) label
esttab using "./Output/Table8_PanelB_R-Squared.csv", keep(L1_CPAMob) label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) pr2 nodep nonote nomti noli nogap alignment(c) replace 

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* CO CPA Disciplinary Actions prep and analysis

******************************************************************************************************************************************************************************
* Set directory (only necessary if you are not executing this file from "00_CPAMob_Master.do")

cd "/CPAMobility/"

******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Import and prep

******************************************************************************************************************************************************************************
* Import raw data

import delimited "./Data/Quality/CO_Quality/FRM_-_Public_Accounting_Firm_-_All_Statuses.csv", encoding(ISO-8859-1) stringc(_all) clear /*Downloaded data on 31 August 2019*/

******************************************************************************************************************************************************************************
* Clean Data: Keep only vars needed, entry and exit dates 

* keep variables of interest
keep formattedname state mailzipcode licensetype licensenumber licensefirstissuedate licenselastreneweddate licenseexpirationdate ///
	licensestatusdescription casenumber programaction disciplineeffectivedate disciplinecompletedate /*v29 empty due to csv format*/

* gen entry 
gen firmentryyear = substr(licensefirstissuedate, -4, 4)
destring firmentryyear, replace
drop if missing(firmentryyear) 

* gen exit
gen firmexityear = substr(licenseexpirationdate, -4, 4)
destring firmexityear, replace
drop if missing(firmexityear)

* align licensenumber (all 7 digits)
destring licensenumber, replace 
gen firmlicensenumber = string(licensenumber,"%07.0f")
replace firmlicensenumber = "FRM." + firmlicensenumber 

******************************************************************************************************************************************************************************
* Create tempfile that only holds discplinary actions

preserve

* keep only disciplinary actions
keep if !missing(casenumber)

* gen caseyear
gen caseyear = substr(casenumber, 1, 4)
destring caseyear, replace force
browse if missing(caseyear)
replace caseyear = 2006 if missing(caseyear) /*manually checked these individuals*/

* gen effectiveyear
gen caseeffectiveyear = substr(disciplineeffectivedate, -4,4)
destring caseeffectiveyear, replace /*here all good*/

* check for duplicates in the file
duplicates tag firmlicensenumber caseyear, gen(dupl1)
sort firmlicensenumber caseyear 
browse if dupl1 > 0 /*true duplicates --> remove*/
duplicates drop firmlicensenumber caseyear, force

* keep vars needed for tempfile
keep firmlicensenumber caseyear disciplineeffectivedate casenumber programaction disciplineeffectivedate disciplinecompletedate

* gen year for merging 
gen year = caseyear /*year of the actual violation is what is needed*/

* save tempfile 
tempfile codisc
save `codisc'


******************************************************************************************************************************************************************************
* Reload main file, drop disc action (--> drop duplicates), convert to panel, and merge in disc actions

restore

* drop the disc actions, which are now stored in the tempfile
drop casenumber programaction disciplineeffectivedate disciplinecompletedate 

* drop duplicates (these are coming from disc ations --> taken care of via storing this info in temp file)
duplicates drop firmlicensenumber, force

* convert to panel structure
gen expander = firmexityear - firmentryyear + 1
expand expander
bysort firmlicensenumber: gen sequence = _n - 1
gen year = firmentryyear + sequence

* merge in disc ations and gen outcome
merge 1:1 firmlicensenumber year using `codisc'
drop if _merge == 2
gen discipline = (_merge == 3)
drop _merge

******************************************************************************************************************************************************************************
* Sample restriction, age partition, reg prep

* restriction
keep if year >= 2003 & year <= 2015
keep if firmentryyear <= 2007 /*keep only firms active prior to treatment*/
keep if state == "CO"

* partition on Age
preserve
keep if year == 2007 
egen agequantile = xtile(firmentryyear), n(2)
keep firmlicensenumber agequantile
tempfile age
save `age'
restore
capture drop agequantile
merge m:1 firmlicensenumber using `age'

* gen split variables
gen old = (agequantile == 1)
gen young = (agequantile == 2)

* gen treatment and FEs
capture egen firm_id = group(firmlicensenumber)
capture gen L1_CPAMob_young = (year >= 2009 & young == 1)

* sample inclusion variable
capture gen oldyoung = (old == 1 | young == 1)


******************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************
* Regression analysis

* Table 8, Panel C: CPA Mobility and Discplinary Actions in Colorado
eststo clear
eststo: reghdfe discipline L1_CPAMob_young if oldyoung == 1, a(young year) cluster(firm_id)
eststo: reghdfe discipline L1_CPAMob_young if oldyoung == 1, a(firm_id year) cluster(firm_id)
esttab using "./Output/Table8_PanelC.csv", label b(3) se(3) pa star(* 0.10 ** 0.05 *** 0.01) ar2 nodep nonote nomti noli nogap alignment(c) replace


capture gen cpa = (industry_code == "541211")
capture gen timediff = effectiveyear - year
capture drop reltime*

gen reltimeleadlarger3 = (timediff > 3) /*before*/
label variable reltimeleadlarger3 "t≤-4"
gen reltimeleadlarger3_cpa = reltimeleadlarger3 * cpa /*before*/
label variable reltimeleadlarger3_cpa "t≤-4"

gen reltimelead3 = (timediff == 3) /*before*/
label variable reltimelead3 "t-3"
gen reltimelead3_cpa = reltimelead3 * cpa /*before*/
label variable reltimelead3_cpa "t-3"

gen reltimelead2 = (timediff == 2) /*before*/
label variable reltimelead2 "t-2"
gen reltimelead2_cpa = reltimelead2 * cpa /*before*/
label variable reltimelead2_cpa "t-2"

gen reltimelead1 = (timediff == 1) /*before*/
label variable reltimelead1 "t-1"
gen reltimelead1_cpa = reltimelead1 * cpa /*before*/
label variable reltimelead1_cpa "t-1"

gen reltime0 = (timediff == 0)
label variable reltime0 "t=0"
gen reltime0_cpa = reltime0 * cpa
label variable reltime0_cpa "t=0"

gen reltimelag1 = (timediff == -1) /*after*/
label variable reltimelag1 "t+1"
gen reltimelag1_cpa = reltimelag1 * cpa /*after*/
label variable reltimelag1_cpa "t+1"

gen reltimelag2 = (timediff == -2) /*after*/
label variable reltimelag2 "t+2"
gen reltimelag2_cpa = reltimelag2 * cpa /*after*/
label variable reltimelag2_cpa "t+2"

gen reltimelag3 = (timediff == -3) /*after*/
label variable reltimelag3 "t+3"
gen reltimelag3_cpa = reltimelag3 * cpa /*after*/
label variable reltimelag3_cpa "t+3"

gen reltimelaglarger3 = (timediff < -3) /*after*/
label variable reltimelaglarger3 "t≥4"
gen reltimelaglarger3_cpa = reltimelaglarger3 * cpa  /*after*/
label variable reltimelaglarger3_cpa "t≥4"

