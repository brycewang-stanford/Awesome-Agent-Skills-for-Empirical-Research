***************************************************************************************************************************************************************
**********                                                                    																    	 **********
**********        ARTICLE: Disclosure Regulation in the Commercial Banking Industry: Evidence from the National Banking Era                     	 **********
**********        AUTHOR:  Joao Granja                          																					 **********
**********        JOURNAL OF ACCOUNTING RESEARCH                               																		 **********
**********                                                         																	             	 **********
**********                                    		                	        														       		 **********
**********        TABLE OF CONTENTS:                                            																     **********
**********        -- A: Formation of the Datasets used in the Analysis																                 **********
**********        -- B: Merging the Datasets                    																               	     **********
**********        -- C: Regressions and Figures - Published Paper              																         **********
**********                                                          															         	       	 **********
**********                                                                        																	 **********
**********        README / DESCRIPTION:                                       																	     **********
**********        This STATA do-file converts the raw data into our final     																	     **********
**********        dataset and performs the main statistical analyses. The code         																 **********
**********        uses multiple hand-collected datasets as inputs and yields the content         													 **********
**********        of the main analysis as output. 			        																				 **********
**********                                                                         																	 **********
***************************************************************************************************************************************************************

global dropbox "/Users/joaogranja/Dropbox (Personal)/Mandatory bank disclosure and bank failures/Data"
cd "$dropbox/Source Data/"

*****************************************************************************************
*****************************************************************************************
******************************  A: SAMPLE FORMATION   ***********************************
*****************************************************************************************
*****************************************************************************************

*********************************************************************************************
* Step A.0 - Setting Up the Panel Dataset (Year x State x Banking-System)
*********************************************************************************************

use base, clear
cross using stabr
cross using banktypes
drop c2 c3
rename c1 banktype
sort banktype year state
save "$dropbox/cleaned files/baseline", replace

************************************************************************************************
* Step A.1 - Clean file containing the number of banks (data hand-collected from Barnett and Cooke, 1911)
************************************************************************************************

use number_of_banks, clear
gen banktype = "State"

append using number_of_banks_pri
replace banktype = "Private" if banktype==""

append using number_of_banks_nat
replace banktype = "National" if banktype==""

rename c1 year

foreach x of varlist alabama-wyoming{ 
rename `x' nbank`x'
}


reshape long nbank, i(year banktype) j(state) string

gen ln_nbank = ln(1 + nbank)
replace state = proper(state)
replace state = subinstr(state,"_"," ",.)

save "$dropbox/cleaned files/nbank", replace 

*********************************************************
* Step A.2 - Preparing the Total Population by State
*********************************************************

clear all
import excel "Population.xlsx", sheet("Sheet1") firstrow // File with Population by U.S. State extracted from the NHGIS on May 8th, 2012

rename State state
rename TotalPoulation pop
rename Year year

replace state = "Arizona" if state=="Arizona Territory"
replace state = "Colorado" if state=="Colorado Territory"
replace state = "Idaho" if state=="Idaho Territory"
replace state = "Montana" if state=="Montana Territory"
replace state = "New Mexico" if state=="New Mexico Territory"
replace state = "Oklahoma" if state=="Oklahoma Territory"
replace state = "Utah" if state=="Utah Territory"
replace state = "Washington" if state=="Washington Territory"
replace state = "Wyoming" if state=="Wyoming Territory"

drop if state == "Persons in the Military"
drop if state == "Hawaii Territory"
drop if state == "Alaska Territory"
drop if state == "Dakota Territory"
drop if state == "District Of Columbia"
drop if state == "Indian Territory" 

egen stn = group(state)
tsset stn year
tsfill

// Interpolate for non-decennial years using cubic splines
csipolate pop year , gen(totpop) by(stn)
forvalues i = 1/2388{
replace state = state[`i'-1] in `i' if state==""
 }
 
drop stn pop
replace state= proper(state)

save "$dropbox/cleaned files/popula", replace

******************************************************
* Step A.3 - Preparing the Total Urban Population by State file // File with Urban Population by U.S. State extracted from the NHGIS on May 8th, 2012
*********************************************************

clear all
import excel "Urbanpop.xlsx", sheet("Sheet1") firstrow

rename State state
rename Year year

replace state = "Arizona" if state=="Arizona Territory"
replace state = "Colorado" if state=="Colorado Territory"
replace state = "Idaho" if state=="Idaho Territory"
replace state = "Montana" if state=="Montana Territory"
replace state = "New Mexico" if state=="New Mexico Territory"
replace state = "Oklahoma" if state=="Oklahoma Territory"
replace state = "Utah" if state=="Utah Territory"
replace state = "Washington" if state=="Washington Territory"
replace state = "Wyoming" if state=="Wyoming Territory"

drop if state == "Persons in the Military"
drop if state == "Hawaii Territory"
drop if state == "Alaska Territory"
drop if state == "Dakota Territory"
drop if state == "District Of Columbia"
drop if state == "Indian Territory" 

egen stn = group(state)
tsset stn year
tsfill

// Interpolate for non-decennial years using cubic splines
csipolate urbpop year , gen(toturb) by(stn)
forvalues i = 1/2439{
replace state = state[`i'-1] in `i' if state==""
 }
 

drop stn urbpop
replace state= proper(state)

replace toturb = 0 if state=="Arizona" & year <1910
replace toturb = 0 if state=="Arkansas" & year <1880
replace toturb = 0 if state=="Florida" & year <1890
replace toturb = 0 if state=="Iowa" & year <1880
replace toturb = 0 if state=="Kansas" & year <1880
replace toturb = 0 if state=="Montana" & year <1890
replace toturb = 0 if state=="North Carolina" & year <1900
replace toturb = 0 if state=="Oklahoma" & year <1900
replace toturb = 0 if state=="Oregon" & year <1880
replace toturb = 0 if state=="South Dakota" & year <1910
replace toturb = 0 if state=="Texas" & year <1880
replace toturb = 0 if state=="Utah" & year <1880
replace toturb = 0 if state=="Washington" & year <1880

save "$dropbox/cleaned files/urbpop", replace


********************************************************
* Step A.4 - Preparing the Gini coefficient data (Using the Rajan and Ramcharan (2011) measure
*********************************************************

* Calculating Gini coefficient and (Manufacturing output/Total output) for states for the years 1880 ; 1890 ; 1900 ; 1910 ; 1920

// Census 1870
use 1870, clear

drop if county !=0

gen totfarms = farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm500 + farm1000
gen elementthree = 2/(totfarms*(1*farm02+6*farm39 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 300*farm100 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm500) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) +1) + 300*(farm100/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) + totfarms - (farm02 + farm39 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049) + totfarms - (farm02 + farm39 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm02 + farm39 + farm1019) + totfarms - (farm02 + farm39) +1) + 6*(farm39/2)*(totfarms - (farm02 + farm39) + totfarms - farm02 +1) + 1*(farm02/2)*(totfarms - farm02 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

gen pct_manu = mfgout/(mfgout+farmout)

keep name gini pct_manu
save "$dropbox/cleaned files/gini1870", replace

// Census 1880
use 1880, clear

drop if county !=0

gen totfarms = farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm500 + farm1000
gen elementthree = 2/(totfarms*(1*farm02+6*farm39 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 300*farm100 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm500) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) +1) + 300*(farm100/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) + totfarms - (farm02 + farm39 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049) + totfarms - (farm02 + farm39 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm02 + farm39 + farm1019) + totfarms - (farm02 + farm39) +1) + 6*(farm39/2)*(totfarms - (farm02 + farm39) + totfarms - farm02 +1) + 1*(farm02/2)*(totfarms - farm02 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

gen pct_manu = mfgout/(mfgout+farmout)

keep name gini pct_manu
save "$dropbox/cleaned files/gini1880", replace

// Census 1890
use 1890, clear

drop if county !=0

gen totfarms =  farm09 + farm1019 + farm2049 + farm5099 + farm100 + farm500 + farm1000
gen elementthree = 2/(totfarms*(5*farm09 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 300*farm100 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100 + farm500) + totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100) +1) + 300*(farm100/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm09 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099) + totfarms - (farm09 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm09 + farm1019 + farm2049) + totfarms - (farm09 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm09 + farm1019) + totfarms - farm09 +1) + 5*(farm09/2)*(totfarms - farm09 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

gen pct_manu = mfgout/(mfgout+farmout)
keep name gini pct_manu

save "$dropbox/cleaned files/gini1890", replace

// Census 1900
use 1900, clear

drop if county !=0

gen totfarms = farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500 + farm1000
gen elementthree = 2/(totfarms*(1*farm12+6*farm39 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 137.5*farm100 + 217.5*farm175 + 380*farm260 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500) + totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 ) +1) + 380*(farm260/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260) + totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175) +1) +  217.5*(farm175/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175) + totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100) +1) + 137.5*(farm100/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049 + farm5099) + totfarms - (farm12 + farm39 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm12 + farm39 + farm1019 + farm2049) + totfarms - (farm12 + farm39 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm12 + farm39 + farm1019) + totfarms - (farm12 + farm39) +1) + 6*(farm39/2)*(totfarms - (farm12 + farm39) + totfarms - farm12 +1) + 1*(farm12/2)*(totfarms - farm12 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

gen pct_manu = mfgout/(mfgout+farmout)

keep name gini pct_manu
save "$dropbox/cleaned files/gini1900", replace

// Census 1910
use 1910, clear

drop if county !=0

gen totfarms = farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500 + farm1000
gen elementthree = 2/(totfarms*(1*farm02+6*farm39 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 137.5*farm100 + 217.5*farm175 + 380*farm260 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 ) +1) + 380*(farm260/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175) +1) +  217.5*(farm175/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) +1) + 137.5*(farm100/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) + totfarms - (farm02 + farm39 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049) + totfarms - (farm02 + farm39 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm02 + farm39 + farm1019) + totfarms - (farm02 + farm39) +1) + 6*(farm39/2)*(totfarms - (farm02 + farm39) + totfarms - farm02 +1) + 1*(farm02/2)*(totfarms - farm02 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

keep name gini  area
save "$dropbox/cleaned files/gini1910", replace

// Census 1920
use 1920, clear

drop if county !=0

gen totfarms = farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500 + farm1000
gen elementthree = 2/(totfarms*(1*farm02+6*farm39 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 137.5*farm100 + 217.5*farm175 + 380*farm260 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 + farm500) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260 ) +1) + 380*(farm260/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175 + farm260) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175) +1) +  217.5*(farm175/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100 + farm175) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) +1) + 137.5*(farm100/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049 + farm5099) + totfarms - (farm02 + farm39 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm02 + farm39 + farm1019 + farm2049) + totfarms - (farm02 + farm39 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm02 + farm39 + farm1019) + totfarms - (farm02 + farm39) +1) + 6*(farm39/2)*(totfarms - (farm02 + farm39) + totfarms - farm02 +1) + 1*(farm02/2)*(totfarms - farm02 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

gen pct_manu = mfgout/(mfgout+cropval)
keep name gini pct_manu

save "$dropbox/cleaned files/gini1920", replace


* Appending all Gini files
use "$dropbox/cleaned files/gini1920", clear
gen year = 1920
append using "$dropbox/cleaned files/gini1910"
replace year = 1910 if year==.
append using "$dropbox/cleaned files/gini1900"
replace year = 1900 if year==.
append using "$dropbox/cleaned files/gini1890"
replace year =1890 if year==.
append using "$dropbox/cleaned files/gini1880"
replace year = 1880 if year==.
append using "$dropbox/cleaned files/gini1870"
replace year = 1870 if year==.

drop if gini==.

rename name state
replace state = proper(state)

sort state year
drop if state== "Continental U.S." | state=="Dakota Territory" | state=="Dist Columbia" | state=="Hawaii" | state=="Indian Territory" | state=="United States" | state=="Cont. United States" | state=="Alaska"

*Interpolating values for the non-decennial years

egen stn = group(state)
tsset stn year
tsfill

csipolate gini year , gen(gini_index) by(stn)
forvalues i = 1/2388{
replace state = state[`i'-1] in `i' if state==""
 }
 
csipolate pct_manu year , gen(man) by(stn)
forvalues i = 1/2388{
replace state = state[`i'-1] in `i' if state==""
 }
 
keep state year man gini_index area
egen totarea = total(area), by(state)
drop area
save "$dropbox/cleaned files/gini", replace

*************************************************************
* Step A.5 Preparing the % Black Population
**************************************************************

use 1870, clear

drop if county !=0

gen blackpop = cotot
keep state name blackpop
save "$dropbox/cleaned files/black1870", replace

use 1880, clear
drop if county !=0

gen blackpop = cotot
keep state name blackpop
save "$dropbox/cleaned files/black1880", replace

use 1890, clear
drop if county !=0

gen blackpop = negtot
keep state name blackpop
save "$dropbox/cleaned files/black1890", replace

use 1900, clear

drop if county !=0

gen blackpop = negmtot + negftot
keep state name blackpop
save "$dropbox/cleaned files/black1900", replace

use 1910, clear

drop if county !=0
gen blackpop = negmtot + negftot
keep state name blackpop
save "$dropbox/cleaned files/black1910", replace

use 1920, clear

drop if county !=0
gen blackpop = negmtot + negftot
keep state name blackpop
save "$dropbox/cleaned files/black1920", replace


* Appending Total Black Population files

gen year = 1920
append using "$dropbox/cleaned files/black1910"
replace year = 1910 if year==.
append using "$dropbox/cleaned files/black1900"
replace year = 1900 if year==.
append using "$dropbox/cleaned files/black1890"
replace year =1890 if year==.
append using "$dropbox/cleaned files/black1880"
replace year = 1880 if year==.
append using "$dropbox/cleaned files/black1870"
replace year = 1870 if year==.

drop if blackpop==.
drop state
rename name state
replace state = proper(state)

sort state year
drop if state== "Continental U.S." | state=="Dakota Territory" | state=="Dist Columbia" | state=="Hawaii" | state=="Indian Territory" | state=="United States" | state=="Cont. United States" | state=="Alaska"

*Interpolating values for the non-decennial years

egen stn = group(state)
tsset stn year
tsfill

csipolate blackpop year , gen(black) by(stn)
forvalues i = 1/2388{
replace state = state[`i' - 1] in `i' if state==""
 }
 
keep state year black

save "$dropbox/cleaned files/black", replace

*************************************************************
* Step A.6 - Data on adoption states
*************************************************************

use states, clear
merge m:1 stabr using "$dropbox/cleaned files/reportdate"
keep if _merge==3 
drop _merge
tempfile state
save `state'

use "$dropbox/cleaned files/reportdate", clear
gen stabr_pair = stabr
gen report_pair = report
gen exam_pair = examination
drop stabr report examination
tempfile ab
save `ab'

use `state', clear
merge m:1 stabr_pair using `ab'
keep if _merge==3
drop _merge

keep if cont==1
collapse report_pair exam_pair, by(stabr)

save "$dropbox/cleaned files/adoption_pair", replace


************************************************************
* Step A.7 - Preparing the Treatment effects file
*********************************************************

clear all

foreach y in st nat{

use `y'finstat, clear
rename c1 year
foreach x of varlist alabama-wyoming{ 
rename `x' `y'finstat`x'
}

reshape long `y'finstat, i(year) j(state) string
replace state = subinstr(state,"_"," ",.)
replace state = proper(state)
replace state = "Wisconsin" if state == "Wisconcin"
rename `y'finstat rep

save "$dropbox/cleaned files/`y'finstat_fin", replace
}


clear all
foreach y in st nat{
use `y'exam, clear
rename c1 year

foreach x of varlist alabama-wyoming{ 
rename `x' `y'exam`x'
}

reshape long `y'exam, i(year) j(state) string
replace state = subinstr(state,"_"," ",.)
replace state = proper(state)
rename `y'exam exam

save  "$dropbox/cleaned files/`y'exam_fin", replace
}

foreach x in finstat exam{
use "$dropbox/cleaned files/st`x'_fin"
gen banktype = "State"
append using "$dropbox/cleaned files/nat`x'_fin"
replace banktype = "National" if banktype==""
replace state = "Wisconsin" if state=="Wisconcin"
save "$dropbox/cleaned files/`x'_fin", replace // These are the files that are going to be used

}
************************************************************************
* Step A.8 Balance Sheet Data from Flood - BS from 1896 - 1914 
****************************************************************************

clear all
use aggbsdata, clear

rename st stabr

foreach x in cash totln totre totinv govtsec totdep depibk depothd depotht borr bknotes totass totliab cap surp{
	gen `x'state = a_`x' - n_`x'
	rename n_`x' `x'national
}

keep stabr year cashstate cashnational ///
totlnnational totlnstate totrestate totrenational ///
totinvstate totinvnational govtsecstate govtsecnational ///
totdepstate totdepnational depothdstate depothtstate depothdnational depothtnational depibkstate depibknational ///
totassstate totassnational totliabstate totliabnational ///
capstate surpstate  capnational surpnational borrnational bknotesnational borrstate bknotesstate
reshape long cash totdep totre totln totinv depothd depotht govtsec depibk cap surp totass borr bknotes totliab, i(stabr year) j(banktype) string

replace banktype = proper(banktype)

save "$dropbox/cleaned files/statesbs", replace

***************************************************************
* Step A.9 - 1899 Annual Report of the Comptroller of the Currency Data file
***************************************************************

use data_on_deposit_loans_and_rates.dta, clear


forvalues x = 1/12{
local z`x' = c`x'[1]
label var c`x' "`z`x''"
}


rename c1 date
rename c2 bank_type
rename c3 state
rename c4 nbankex
rename c5 nbankreploan
rename c6 nbankrepint
rename c7 ndep
rename c8 depamount
rename c9 intdep
rename c10 nloans
rename c11 loanamount
rename c12 intloan

drop in 1

replace state = subinstr(state,":","",.)
replace state = subinstr(state,"-","",.)
replace state = subinstr(state,"ó","",.)
replace state = subinstr(state,"ï","",.)
replace state = subinstr(state,".","",.)
replace state = subinstr(state,";","",.)
replace state = subinstr(state,"1","",.)
replace state = rtrim(state)

replace date = subinstr(date,".","",.)
replace date = subinstr(date," ","",.)
replace date = rtrim(date)

gen date1 = date(date, "MDY")
gen year = year(date1)
gen month = month(date1)

drop date date1

foreach var of varlist intdep intloan {
replace `var' = subinstr(`var'," ",".",.)
replace `var' = subinstr(`var',"..",".",.)
replace `var' = subinstr(`var',",",".",.)
destring `var', replace force
}

foreach var of varlist nloans loanamount {
replace `var' = subinstr(`var'," ","",.)
replace `var' = subinstr(`var',".","",.)
replace `var' = subinstr(`var',",","",.)
replace `var' = subinstr(`var',"$","",.)
replace `var' = subinstr(`var',"i","",.)
replace `var' = subinstr(`var',"I","",.)
replace `var' = subinstr(`var',"|","",.)
replace `var' = subinstr(`var',"/","",.)
replace `var' = subinstr(`var',"j","",.)
replace `var' = subinstr(`var',"!","",.)
replace `var' = subinstr(`var',";","",.)
replace `var' = subinstr(`var',"ë","",.)
replace `var' = subinstr(`var',"'","",.)
replace `var' = subinstr(`var',":","",.)
destring `var', replace force
}
****

drop nbankex nbankreploan ndep depamount  month
rename bank_type banktype
replace banktype = "State" if banktype=="State/Private"

save "$dropbox/cleaned files/rates", replace

*****************************************************************************************
* Step A.10  Cleaning up the Bradstreets' Data on the Failure of State, Savings and Private Banks 1892-1913 (HAND-COLLECTED DATA)
*****************************************************************************************

use total, clear 
replace assets_state = "800.000" in 233

rename states_ state

replace state = subinstr(state,":","",.)
replace state = subinstr(state,"-","",.)
replace state = subinstr(state,"ó","",.)
replace state = subinstr(state,"ï","",.)
replace state = subinstr(state,".","",.)
replace state = subinstr(state,";","",.)
replace state = subinstr(state,"1","",.)
replace state = subinstr(state,"ÖÖÖÖ","",.)
replace state = subinstr(state,"!","",.)
replace state = rtrim(state)

replace state = "Kentucky" if state=="Kentuckv"
replace state = "Minnesota" if state=="Minnesotai"
replace state = "North Dakota" if state=="North Dakota b" | state=="North Dakota*"
replace state = "South Dakota" if state=="South Dakotab" | state=="South Dakota*" | state=="South Dakota (no info)"
replace state = "Kansas" if state=="Kanaaa" 
replace state = "Washington" if state=="Washington i" 
replace state = "Massachusetts" if state=="Massachussets" 
replace state = "New York" if state=="Now York" 
replace state = "New Hampshire" if state=="Mew Hampshire" 
replace state = "Oklahoma" if state=="Oklahoma Territory" 

rename  no__state nstate
replace nstate = "1" if nstate=="I"

label var nstate "Number of State Bank Suspension"
tab nstate
destring nstate, replace force
tab nstate

rename assets_state astate
rename liabilities_state lstate
 
replace astate = subinstr(astate,"ï","",.)
replace astate = subinstr(astate,".","",.)
replace astate = subinstr(astate,",","",.)
replace astate = subinstr(astate," ","",.)
replace astate = subinstr(astate,"$","",.)
replace astate = rtrim(astate)

replace lstate = subinstr(lstate,"ï","",.)
replace lstate = subinstr(lstate,".","",.)
replace lstate = subinstr(lstate,",","",.)
replace lstate = subinstr(lstate," ","",.)
replace lstate = subinstr(lstate,"$","",.)
replace lstate = rtrim(lstate)

replace astate = "0" in 428
replace astate = "0" in 338

label var astate "Estimated Assets of State Bank at the time of Suspension"
label var lstate "Estimated Liabilities of State Bank at the time of Suspension"

destring astate lstate, replace force

gen levstate = astate/lstate
label var levstate "Estimated Leverage of State Bank at the time of Suspension"

merge m:1 state using stabr
drop if _merge!=3
drop _merge

save bradstreet, replace

**********************************************
* Step A.11 Transforming the dataset into state-year-banktype form

foreach y in n l lev{
	clear all
	use bradstreet
	keep state stabr year `y'state
	reshape long `y', i(year state) j(banktype) string
	replace banktype = proper(banktype)
	replace banktype = "Private" if banktype =="Priv"
	save "$dropbox/cleaned files/bradstreet_`y'", replace
}


use "$dropbox/cleaned files/bradstreet_n", clear
rename n nfail
replace nfail = 0 if nfail==.
save "$dropbox/cleaned files/bradstreet_n", replace

use "$dropbox/cleaned files/bradstreet_l", clear
rename l lfail
replace lfail = 0 if lfail==.
replace lfail = lfail/1000
save "$dropbox/cleaned files/bradstreet_l", replace

*****************************************************************************************
* Step A.12 - Cleaning up the Annual Report of the Comptroller of the Currency Data on the Failure of National Banks 1892-1913
*****************************************************************************************

clear all
use national

keep name city state date_closed estimated_good_ estimated_doubtful_ estimated_worthless_  collected_from_assets_ amount_of_claims_proved_


foreach x of varlist name-amount_of_claims_proved_{
replace `x' = subinstr(`x',"ï","",.)
replace `x' = subinstr(`x',".","",.)
replace `x' = subinstr(`x',",","",.)
replace `x' = subinstr(`x',"$","",.)
replace `x' = subinstr(`x',"_","",.)
replace `x' = subinstr(`x',";","",.)
replace `x' = subinstr(`x',"'","",.)
replace `x' = subinstr(`x',"*","",.)
replace `x' = subinstr(`x',"!","",.)
replace `x' = subinstr(`x',"}","",.)
replace `x' = subinstr(`x',":","",.)
replace `x' = subinstr(`x',"[","",.)
replace `x' = subinstr(`x',"]","",.)
replace `x' = subinstr(`x',"|","",.)
replace `x' = subinstr(`x',">","",.)
replace `x' = rtrim(`x')
}

replace state = subinstr(state," ","",.)
replace state = subinstr(state,"2","",.)
replace state = subinstr(state,"3","",.)
replace date_closed = subinstr(date_closed," ","",.)
replace date_closed = "do" if date_closed=="" | date_closed=="ido"
replace date_closed = "June51895" in 142
replace date_closed = "Apr261895" in 140
replace date_closed = date_closed[_n-1] if date_closed[_n]=="do"

foreach x of varlist estimated_good_-amount_of_claims_proved_{
replace `x' = subinstr(`x'," ","",.)
}


gen year = substr(date_closed,-4,4)
gen month = substr(date_closed,1,3)
destring year, replace force
gen year1 = year if month =="Jan" | month =="Feb" | month =="Mar" | month =="Apr" | month =="May" | month =="Jun"
replace year1 = year + 1 if month =="Jul" | month =="Aug" | month =="Sep" | month =="Oct" | month =="Nov" | month =="Dec"
drop year
rename year1 year

replace state = "Alabama" if state == "Ala"
replace state = "Arizona" if state == "Ariz"
replace state = "Arkansas" if state == "Ark"
replace state = "California" if state == "Cal"
replace state = "Colorado" if state == "Col"
replace state = "Colorado" if state == "Colo"
replace state = "Connecticut" if state == "Conn"
replace state = "Dakota" if state == "Dak"
replace state = "Delaware" if state == "Del"
replace state = "Florida" if state == "Fla"
replace state = "Florida" if state == "Fla1"
replace state = "Florida" if state == "Fla3"
replace state = "Georgia" if state == "Ga"
replace state = "Illinois" if state == "Ill"
replace state = "Illinois" if state == "III"
replace state = "Illinois" if state == "III1"
replace state = "Illinois" if state == "111"
replace state = "Indiana" if state == "Ind"
replace state = "Indiana" if state == "Ind1"
replace state = "Kansas" if state == "Kan"
replace state = "Kansas" if state == "Kans"
replace state = "Kansas" if state == "Kans1"
replace state = "Kentucky" if state == "Ky"
replace state = "Kentucky" if state == "Ky1"
replace state = "Louisiana" if state == "La"
replace state = "Maine" if state == "Me"
replace state = "Michigan" if state == "Mich"
replace state = "Michigan" if state == "Mich1"
replace state = "Massachusetts" if state == "Mass"
replace state = "Massachusetts" if state == "MassA"
replace state = "Minnesota" if state == "Minn"
replace state = "Maryland" if state == "Md"
replace state = "Mississippi" if state == "Miss"
replace state = "Mississippi" if state == "MissI"
replace state = "Missouri" if state == "Mo"
replace state = "Missouri" if state == "Missodbi"
replace state = "Missouri" if state == "Missoubt"
replace state = "Montana" if state == "Mont"
replace state = "Montana" if state == "Mont1"
replace state = "New Mexico" if state == "N MEX"
replace state = "New Mexico" if state == "N Mex"
replace state = "New Mexico" if state == "New Mexico"
replace state = "New Mexico" if state == "New Mexico"
replace state = "New Mexico" if state == "NMexs"
replace state = "New Mexico" if state == "NMexj"
replace state = "New Mexico" if state == "NMex"
replace state = "New Hampshire" if state == "N H"
replace state = "New Hampshire" if state == "NH"
replace state = "New Hampshire" if state == "New Hampshire"
replace state = "New Jersey" if state == "N J"
replace state = "New Jersey" if state == "NJ"
replace state = "New York" if state == "N Y"
replace state = "New York" if state == "NY"
replace state = "New York" if state == "N"
replace state = "New York" if state == "New York"
replace state = "Nebraska" if state == "Neb"
replace state = "Nebraska" if state == "Nebr"
replace state = "Nevada" if state == "Nev"
replace state = "NorthCarolina" if state == "NC"
replace state = "North Carolina" if state == "N Carolina"
replace state = "North Carolina" if state == "N C"
replace state = "North Carolina" if state == "NC"
replace state = "North Carolina" if state == "N Carolina"
replace state = "North Carolina" if state == "NorthCarolina"
replace state = "North Dakota" if state == "N Dakota"
replace state = "North Dakota" if state == "DakN"
replace state = "North Dakota" if state == "NDak"
replace state = "North Dakota" if state == "Dak N"
replace state = "Oklahoma" if state == "Okl"
replace state = "Oklahoma" if state == "Okl T"
replace state = "Oklahoma" if state == "Okl Terr"
replace state = "Oklahoma" if state == "Okla"
replace state = "Oklahoma" if state == "Okla1"
replace state = "Oregon" if state == "Ore"
replace state = "Oregon" if state == "Oreg"
replace state = "Pennsylvania" if state == "Pa"
replace state = "Pennsylvania" if state == "Penn"
replace state = "Pennsylvania" if state == "Pai"
replace state = "Pennsylvania" if state == "Pa1"
replace state = "Rhode Island" if state == "R I"
replace state = "Rhode Island" if state == "RI"
replace state = "South Carolina" if state == "S Carolina"
replace state = "South Carolina" if state == "SC"
replace state = "South Carolina" if state == "S C"
replace state = "South Dakota" if state == "Dak S"
replace state = "South Dakota" if state == "SDak"
replace state = "South Dakota" if state == "S Dakota"
replace state = "South Dakota" if state == "Dakota S"
replace state = "Tennessee" if state == "Tenn"
replace state = "Texas" if state == "Tex"
replace state = "Texas" if state == "TexA"
replace state = "Texas" if state == "Tex1"
replace state = "Virginia" if state == "Va"
replace state = "Vermont" if state == "Vt"
replace state = "Vermont" if state == "Swanton"
replace state = "West Virginia" if state == "W Va"
replace state = "West Virginia" if state == "WVa"
replace state = "Washington" if state == "Wash"
replace state = "Washington" if state == "Wa"
replace state = "Washington" if state == "Wash1"
replace state = "Wisconsin" if state == "Wis"
replace state = "Wisconsin" if state == "Wisconcin"
replace state = "Wyoming" if state == "Wyom"
replace state = "Wyoming" if state == "Wyo"

merge m:1 state using stabr
drop if _merge!=3
drop _merge

* Calculating estimated leverage at the time of suspension for National Banks
destring estimated_good_-amount_of_claims_proved_, replace force

save nationaldata, replace

egen group = group(year state)
egen nfail = count(group), by(group)
duplicates drop state year, force

drop name city date_closed month group estimated_good_-amount_of_claims_proved_ 
drop if year==1914

gen banktype = "National"

save nnat, replace
append using "$dropbox/cleaned files/bradstreet_n"
save "$dropbox/cleaned files/bradstreet_n", replace

use nationaldata, clear
gen estimated_a = 1*estimated_good_ 

egen group = group(year state)
egen anat = total(estimated_a), by(group)
egen lnat = total(amount_of_claims_proved_), by(group)
duplicates drop state year, force

gen lev = anat/lnat
drop name city date_closed month group estimated_good_-amount_of_claims_proved_ anat lnat estimated_a
drop if year==1914

gen banktype = "National"

save levnat, replace
append using "$dropbox/cleaned files/bradstreet_lev"
save "$dropbox/cleaned files/bradstreet_lev", replace

clear all
use nationaldata
egen group = group(year state)
egen lfail = total(amount_of_claims_proved_), by(group)
replace lfail = lfail/1000
duplicates drop state year, force
drop name city date_closed month group estimated_good_-amount_of_claims_proved_  
drop if year==1914
gen banktype = "National"
save lnat, replace
append using "$dropbox/cleaned files/bradstreet_l"
save "$dropbox/cleaned files/bradstreet_l", replace

********************************************************************************************
* Step A.13 - Setting up the Grossman (2001) double liability file ready for merger with the main file
**********************************************************************************************

use doubleliab ,clear
preserve


drop no
drop nb- nbafnba
rename statenum state

gen banktype = "State"

* Changing the code of the double liability variable to: No double liability: "0"; Double Liability: "1"

replace m3 = "0" if m3=="1"
replace m3 = "1" if m3=="2"

* Transforming the variable from string to numerical

foreach x of varlist m3-asbfsba{
replace `x' = subinstr(`x',",","",.)
destring `x', force replace
}

* Renaming the variables

rename sb nb
rename sba bassets
rename sbf bfail
rename asbf assbfail
rename sbfsb bfailrate
rename asbfsba assfailrate

save state_dl, replace

* Repeat the procedure for the national bank data

restore
drop no
drop sb-asbfsba
rename statenum state

gen banktype = "National"

* Changing the code of the double liability variable to: No double liability: "0"; Double Liability: "1" - Note that National banks were always subject to double liability

replace m3 = "1" if m3=="2"

* Transforming the variable from string to numerical

foreach x of varlist m3-nbafnba{
replace `x' = subinstr(`x',",","",.)
destring `x', force replace
}

* Renaming the variables

rename nba bassets
rename nbf bfail
rename nbaf assbfail
rename nbfnb bfailrate
rename nbafnba assfailrate

save nat_dl, replace

* Appending the double liability files
append using state_dl
drop if year>1913
save "$dropbox/cleaned files/dl", replace

********************************************************************************************
* Step A.14 - Setting up the Mitchener and Jaremski (2015) State Banking Authority Dates
**********************************************************************************************

import excel "sba.xlsx", sheet("Sheet1") firstrow clear
gen sba = 1
rename Year year

egen stn = group(State)
tsset stn year
tsfill, full
sort stn year
egen state = mode(State), by(stn)
drop State

forvalues i = 1/5184{
replace sba = sba[`i'-1] in `i' if sba==. & stn[`i'] == stn[`i'-1]
 }
 
drop stn
replace state= proper(state)
replace sba= 0 if sba==.
drop if year<1865 | year>1914
save "$dropbox/cleaned files/sba", replace

********************************************************************************************
* Step A.15 - Setting up the Reserve Requirements data from Bokley (1934)
**********************************************************************************************

import excel "reserve.xlsx", sheet("Sheet1") firstrow clear
sort stabr year
duplicates  drop stabr , force
gen reserve = 1

egen stn = group(stabr)
tsset stn year
tsfill, full
sort stn year
egen stabr2 = mode(stabr), by(stn)
replace stabr = stabr2
drop stabr2

forvalues i = 1/2058{
replace reserve = reserve[`i'-1] in `i' if reserve==. & stn[`i'] == stn[`i'-1]
 }

drop stn
replace reserve= 0 if reserve==.
save "$dropbox/cleaned files/reserve", replace

********************************************************************************************
* Step A.16 - Compute Population in each county of Illinois and Michigan during 1887
**********************************************************************************************

import excel "countypop.xlsx", sheet("Sheet1") firstrow

egen cty = group(county state)
tsset cty year
tsfill

csipolate pop year , gen(totpop) by(cty)
forvalues i = 1/1986{
replace state = state[`i'-1] in `i' if state==""
replace county = county[`i'-1] in `i' if county==""

 }
 
drop cty pop
replace state= proper(state)
replace county = proper(county)

save ctypop, replace

********************************************************************************************
* Step A.17 - Clean Referenda and Election Voting datasets
**********************************************************************************************

import excel "Election Returns.xls", sheet("Referendum") firstrow

replace county = subinstr(county,".","",.)
replace county = subinstr(county,",","",.)
replace county = subinstr(county,"_","",.)
replace county = subinstr(county,"-","",.)
replace county = subinstr(county,"Ö","",.)
replace county = rtrim(county)
replace county = proper(county)

replace yesvote = subinstr(yesvote,".","",.)
replace yesvote = subinstr(yesvote,",","",.)
replace novote = subinstr(novote,".","",.)
replace novote = subinstr(novote,",","",.)
replace totalvote = subinstr(totalvote,".","",.)
replace totalvote = subinstr(totalvote,",","",.)

replace county = "De Witt" if county =="Dewitt"
replace county = "Du Page" if county =="Dupage"
replace county = "Vermilion" if county =="Vermillion"
replace county = "Leelanau" if county =="Leelanaw"
replace county = "Jo Daviess" if county =="Jodaviess"
replace county = "La Salle" if county =="Lasalle"
replace county = "De Kalb" if county=="Dekalb"
replace county = "Mackinac/Michilim" if county=="Mackinac"

destring yesvote novote totalvote, replace 

drop in 186/187
save electionres, replace

import excel "Election Returns.xls", sheet("Presidentials") firstrow

drop G-J
drop in 187/189

rename Counties county
rename State state

replace county = subinstr(county,".","",.)
replace county = subinstr(county,",","",.)
replace county = subinstr(county,"_","",.)
replace county = subinstr(county,"-","",.)
replace county = subinstr(county,"Ö","",.)
replace county = rtrim(county)
replace county = proper(county)

replace Republican = subinstr(Republican,".","",.)
replace Republican = subinstr(Republican,",","",.)
replace Democrat = subinstr(Democrat,".","",.)
replace Democrat = subinstr(Democrat,",","",.)
replace Progressive = subinstr(Progressive,".","",.)
replace Progressive = subinstr(Progressive,",","",.)
replace Labor = subinstr(Labor,".","",.)
replace Labor = subinstr(Labor,",","",.)

replace county = "De Witt" if county =="Dewitt"
replace county = "Du Page" if county =="Dupage"
replace county = "Vermilion" if county =="Vermillion"
replace county = "Leelanau" if county =="Leelanaw"
replace county = "Jo Daviess" if county =="Jodaviess"
replace county = "La Salle" if county =="Lasalle"
replace county = "De Kalb" if county=="Dekalb"
replace county = "Mackinac/Michilim" if county=="Mackinac"

destring Republican Democrat Progressive Labor, replace 
replace Labor = 0 if Labor==.

gen presvote = Republican + Democrat + Progressive + Labor
gen pc_rep = Republican/presvote
gen pc_dem = Democrat/presvote
gen pc_prog = Progressive/presvote

save pres_res, replace


********************************************************************************************
* Step A.18 - Compute Gini coefficient at the county level using the 1890 census data
**********************************************************************************************

clear all

use census1890
keep if state==21 | state==23
drop if county==0

rename state stnum
rename county ctynum
rename name county
replace county = proper(county)
gen state = "Illinois" if stnum == 21
replace state = "Michigan" if stnum==23

* 3.1 Calculating the Gini coefficient for each county

gen totfarms =  farm09 + farm1019 + farm2049 + farm5099 + farm100 + farm500 + farm1000
gen elementthree = 2/(totfarms*(5*farm09 + 15*farm1019 + 35*farm2049 + 75*farm5099 + 300*farm100 + 750*farm500 +1000*farm1000))
gen element = 1000*(farm1000/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100 + farm500) +1) + 750*(farm500/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100 + farm500) + totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100) +1) + 300*(farm100/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099 + farm100) + totfarms - (farm09 + farm1019 + farm2049 + farm5099) +1) + 75*(farm5099/2)*(totfarms - (farm09 + farm1019 + farm2049 + farm5099) + totfarms - (farm09 + farm1019 + farm2049)+1) + 35*(farm2049/2)*(totfarms - (farm09 + farm1019 + farm2049) + totfarms - (farm09 + farm1019)+1) + 15*(farm1019/2)*(totfarms - (farm09 + farm1019) + totfarms - farm09 +1) + 5*(farm09/2)*(totfarms - farm09 + totfarms +1)
gen prod = elementthree*element
gen gini = 1+ 1/totfarms - prod
drop totfarms-prod

save gini, replace

********************************************************************************************
* Step A.19 - Compute Number of banks per county in Illinois and Michigan as of 1887
**********************************************************************************************

use illinois1887, clear

* 1. Labeling variables

forvalues x = 1/10{
local z`x' = c`x'[1]
label var c`x' "`z`x''"
}

* 2 - Renaming variables

rename c1 place
rename c2 county
rename c3 bankname
rename c4 banktype
rename c5 president
rename c6 cashier
rename c7 capital
rename c8 surplus
rename c9 undprof

drop c10
drop in 1

* 3 - Cleaning Place and County variables

replace county = subinstr(county,".","",.)
replace county = subinstr(county,"_","",.)
replace county = subinstr(county,"-","",.)
replace county = subinstr(county,",","",.)
replace county = subinstr(county,"ó","",.)
replace county = subinstr(county,";","",.)
replace county = subinstr(county,"Ö","",.)
replace county = rtrim(county)
replace county = ltrim(county)
replace county = proper(county)

replace county = "Sangamon" if county=="Sangamon  I"
replace county = "Sangamon" if county=="Sangamon  i"
replace county = "Sangamon" if county=="Samgamon"
replace county = "De Kalb" if county=="Dekalb"
replace county = "De Witt" if county=="Dewitt"
replace county = "Livingston" if county=="Livingstone"
replace county = "Mackinac/Michilim" if county=="Mackinac"
replace county = "Vermilion" if county=="Vermillion"


replace place = subinstr(place,".","",.)
replace place = subinstr(place,"_","",.)
replace place = subinstr(place,"-","",.)
replace place = subinstr(place,",","",.)
replace place = subinstr(place,"ó","",.)
replace place = subinstr(place,";","",.)
replace place = subinstr(place,"Ö","",.)
replace place = subinstr(place,"<","",.)
replace place = rtrim(place)
replace place = ltrim(place)

keep county banktype
replace banktype = "State" if banktype=="Savings"
egen ctybktype = group(county banktype)
egen nbanks = count(ctybktype) , by(ctybktype)


duplicates drop county banktype, force
drop ctybktype
reshape wide nbanks, i(county) j(banktype) string

foreach var of varlist  nbanksNational nbanksPrivate nbanksState{
	replace `var' = 0 if `var'==.
}

replace nbanksNational = 18 if county=="Cook"
replace nbanksState = 9 if county=="Cook"
replace nbanksPrivate = 41 if county=="Cook"

gen totalbanks = nbanksNational + nbanksPrivate + nbanksState

save bankspercounty, replace


use michigan1887, clear

* 2 - Renaming variables

rename c1 place
rename c2 county
rename c3 bankname
rename c4 banktype
rename c5 president
rename c6 cashier
rename c7 capital
rename c8 surplus
rename c9 undprof

* 3 - Cleaning Place and County variables

replace county = subinstr(county,".","",.)
replace county = subinstr(county,"_","",.)
replace county = subinstr(county,"-","",.)
replace county = subinstr(county,",","",.)
replace county = subinstr(county,"ó","",.)
replace county = subinstr(county,";","",.)
replace county = subinstr(county,"Ö","",.)
replace county = subinstr(county,"'","",.)

replace county = "St Clair" if county =="rSt Clair"
replace county = "Van Buren" if county =="VanBuren"
replace county = "Grand Traverse" if county =="GríndTraverse"
replace county = "Mackinac/Michilim" if county=="Mackinac"
replace county = "Emmet" if county=="Emmett"


replace county = rtrim(county)
replace county = ltrim(county)


replace place = subinstr(place,".","",.)
replace place = subinstr(place,"_","",.)
replace place = subinstr(place,"-","",.)
replace place = subinstr(place,",","",.)
replace place = subinstr(place,"ó","",.)
replace place = subinstr(place,";","",.)
replace place = subinstr(place,"Ö","",.)
replace place = subinstr(place,"<","",.)
replace place = rtrim(place)
replace place = ltrim(place)

keep county banktype
replace banktype = "State" if banktype=="Savings"
egen ctybktype = group(county banktype)
egen nbanks = count(ctybktype) , by(ctybktype)


duplicates drop county banktype, force
drop ctybktype
reshape wide nbanks, i(county) j(banktype) string

foreach var of varlist  nbanksNational nbanksPrivate nbanksState{
	replace `var' = 0 if `var'==.
}

replace nbanksNational = 9 if county=="Wayne"
replace nbanksState = 12 if county=="Wayne"
replace nbanksPrivate = 8 if county=="Wayne"

gen totalbanks = nbanksNational + nbanksPrivate + nbanksState

save bankspercountymich, replace

*  Append the datafiles

use bankspercounty
gen state = "Illinois"
append using bankspercountymich
replace state = "Michigan" if state==""

save bankspercounty,replace


********************************************************************************************
* Step A.20 - Cleaning Matt Jaremski's decennial data on number of banks per county
**********************************************************************************************

import excel "BanksByCounty1870-1910.xlsx", sheet("Sheet1") firstrow clear
rename state stabr
rename yr year
rename countycode FIPScounty
replace FIPScounty = FIPScounty/10
tostring FIPScounty, replace force
replace FIPScounty = "0" + regexs(0) if regexm(FIPScounty, "^[0-9][0-9]$")
replace FIPScounty = "00" + regexs(0) if regexm(FIPScounty, "^[0-9]$")

save "$dropbox/cleaned files/nbanks_jaremski", replace

********************************************************************************************
* Step A.21 - Creating the county-pairs dataset
**********************************************************************************************

import delimited "09835-0001-Data.txt", delimiter(" ") clear stringc(1 2 4 5)
replace v7 = v7 + " " + v8 + " " + v9 + " " + v10 if v7!="" & v8!=""
replace v7 = rtrim(v7)
replace v8 = v8 + " " + v9 + " " + v10 + " " + v11 if v7=="" & v9!=""
replace v8 = rtrim(v8)
replace v7 = proper(v7)
replace v8 = proper(v8)
drop v9-v43
replace v8 = "" if v7!=""

drop if v6!="A" & v3!=1
drop v6

rename v1 FIPSstate
rename v2 FIPScounty
rename v8 CountyName
rename v4 FIPSstate_pair
rename v5 FIPScounty_pair
rename v7 CountyName_pair

 forvalues i = 1/`=_N'{
	foreach var of varlist CountyName{
		quietly replace `var' = `var'[`i'-1] in `i' if `var'==""
	}
}

drop if CountyName_pair==""

// Identifying countiguous counties across state lines

gen FIPScode = FIPSstate + FIPScounty
gen FIPSpair = FIPSstate_pair + FIPScounty_pair
egen group1 = group(FIPScode FIPSpair)
egen group2 = group(FIPSpair FIPScode)
egen pair = rowmin(group1 group2)

keep if FIPSstate != FIPSstate_pair
drop group1 group2 CountyName_pair FIPSpair FIPScounty_pair v3 
destring FIPSstate FIPScode, replace force

// Create Same State Border Indicator
egen border = group(FIPSstate FIPSstate_pair)
egen border1 = group(FIPSstate_pair FIPSstate)
egen same_border = rowmin(border border1)

drop border border1 FIPSstate_pair

save "$dropbox/cleaned files/countypairs", replace


*********************************************************
* A.22 - Computing Total Population per county
**************************************************************

foreach num of numlist 1870(10)1910{
import delimited "nhgis0012_csv/`num'_county.csv", clear
tempfile `num'file
save ``num'file'
}

append using `1900file'
append using `1890file'
append using `1880file'
append using `1870file'

// Cleaning the Population Data

// Step 1.1 - Change the names of name-changing counties to their modern-day name

replace gisjoin = "G0100210" if gisjoin == "G0100015"
replace county = "Chilton" if county == "Baker" & gisjoin == "G0100210"
replace countya = 210 if countya == 15 & gisjoin == "G0100210"

replace gisjoin = "G0100750" if gisjoin == "G0101155"
replace county = "Lamar" if county == "Sanford" & gisjoin == "G0100750"
replace countya = 750 if countya == 1155 & gisjoin == "G0100750"

replace gisjoin = "G0500250" if gisjoin == "G0500415"
replace county = "Cleveland" if county == "Dorsey" & gisjoin == "G0500250"
replace countya = 250 if countya == 415 & gisjoin == "G0500250"

replace gisjoin = "G2100130" if gisjoin == "G2101155"
replace county = "Bell" if county == "Josh Bell" & gisjoin == "G2100130"
replace countya = 130 if countya == 1155 & gisjoin == "G2100130"

replace gisjoin = "G4800670" if gisjoin == "G4801135"
replace county = "Cass" if county == "Davis" & gisjoin == "G4800670"
replace countya = 670 if countya == 1135 & gisjoin == "G4800670"

replace gisjoin = "G5300270" if gisjoin == "G5300055"
replace county = "Grays Harbor" if county == "Chehalis" & gisjoin == "G5300270"
replace countya = 270 if countya == 55 & gisjoin == "G5300270"

replace countya = 610 if countya == 605 & state == "Oregon"

// Step 1.2 Change the county codes of Arizona Territory
replace countya = countya - 5 if state ==  "Arizona Territory"

// Step 2 - Drop/Change name of Territories - Drop counties that ceased to exist from early on
replace state = regexs(1) if regexm(state, "([a-zA-Z]+.*)[ ](Territory)")
drop if state == "Alaska"

drop if county =="Pah-Ute"
drop if county =="Greenwood" & state =="Colorado"

// Step 2.3 -  Change the county codes in Colorado - The following code solves problems with classification in Colorado in 1870 (it was still a Territory)
egen gisjoin1 = mode(gisjoin) if state=="Colorado", by(county)
egen countya1 = mode(countya) if state=="Colorado", by(county)
replace gisjoin = gisjoin1 if statea == 85 & state =="Colorado"
replace countya = countya1 if statea == 85 & state =="Colorado"
replace statea = 80 if statea==85
drop gisjoin1 countya1 

// Step 2.3 -  Change the county codes in Montana
egen gisjoin1 = mode(gisjoin) if state=="Montana", by(county)
egen countya1 = mode(countya) if state=="Montana", by(county)
replace gisjoin = gisjoin1 if statea == 305 & state =="Montana"
replace countya = countya1 if statea == 305 & state =="Montana"
replace statea = 300 if statea==305
drop gisjoin1 countya1

// Step 2.3 -  Change the county codes in Idaho
egen gisjoin1 = mode(gisjoin) if state=="Idaho", by(county)
egen countya1 = mode(countya) if state=="Idaho", by(county)
replace gisjoin = gisjoin1 if statea == 165 & state =="Idaho"
replace countya = countya1 if statea == 165 & state =="Idaho"
replace statea = 160 if statea==165
drop gisjoin1 countya1

// Step 2.3 -  Change the county codes in Kansas
egen gisjoin1 = mode(gisjoin) if state=="Idaho", by(county)
egen countya1 = mode(countya) if state=="Idaho", by(county)
replace gisjoin = gisjoin1 if statea == 165 & state =="Idaho"
replace countya = countya1 if statea == 165 & state =="Idaho"
replace statea = 160 if statea==165
drop gisjoin1 countya1

// Step 2.3 -  Change the county codes in Wyoming
egen gisjoin1 = mode(gisjoin) if state=="Wyoming", by(county)
egen countya1 = mode(countya) if state=="Wyoming", by(county)
replace gisjoin = gisjoin1 if statea == 565 & state =="Wyoming"
replace countya = countya1 if statea == 565 & state =="Wyoming"
replace statea = 560 if statea==565
drop gisjoin1 countya1

// Step 2.3 -  Change the county codes in Washington
egen gisjoin1 = mode(gisjoin) if state=="Washington", by(county)
egen countya1 = mode(countya) if state=="Washington", by(county)
replace gisjoin = gisjoin1 if statea == 535 & state =="Washington"
replace countya = countya1 if statea == 535 & state =="Washington"
replace statea = 530 if statea==535
drop gisjoin1 countya1

// Step 2.5. - Fixing the New Mexico County codes

replace countya = 10 if county=="Bernalillo" & state=="New Mexico"
replace countya = 50 if county=="Chaves" & state=="New Mexico"
replace countya = 70 if county=="Colfax" & state=="New Mexico"
replace countya = 90 if county=="Curry" & state=="New Mexico"
replace countya = 130 if county=="Dona Ana" & state=="New Mexico"
replace countya = 150 if county=="Eddy" & state=="New Mexico"
replace countya = 170 if county=="Grant" & state=="New Mexico"
replace countya = 190 if county=="Guadalupe" & state=="New Mexico"
replace countya = 270 if county=="Lincoln" & state=="New Mexico"
replace countya = 290 if county=="Luna" & state=="New Mexico"
replace countya = 310 if county=="McKinley" & state=="New Mexico"
replace countya = 330 if county=="Mora" & state=="New Mexico"
replace countya = 350 if county=="Otero" & state=="New Mexico"
replace countya = 370 if county=="Quay" & state=="New Mexico"
replace countya = 390 if county=="Rio Arriba" & state=="New Mexico"
replace countya = 410 if county=="Roosevelt" & state=="New Mexico"
replace countya = 430 if county=="Sandoval" & state=="New Mexico"
replace countya = 450 if county=="San Juan" & state=="New Mexico"
replace countya = 470 if county=="San Miguel" & state=="New Mexico"
replace countya = 490 if county=="Santa Fe" & state=="New Mexico"
replace countya = 510 if county=="Sierra" & state=="New Mexico"
replace countya = 530 if county=="Socorro" & state=="New Mexico"
replace countya = 550 if county=="Taos" & state=="New Mexico"
replace countya = 570 if county=="Torrance" & state=="New Mexico"
replace countya = 590 if county=="Union" & state=="New Mexico"
replace countya = 610 if county=="Valencia" & state=="New Mexico"

// Step 2.5. - Fixing the Oklahoma counties codes
replace countya = 70 if county=="Beaver" & state=="Oklahoma"
replace countya = 110 if county=="Blaine" & state=="Oklahoma"
replace countya = 170 if county=="Canadian" & state=="Oklahoma"
replace countya = 270 if county=="Cleveland" & state=="Oklahoma"
replace countya = 390 if county=="Custer" & state=="Oklahoma"
replace countya = 430 if county=="Dewey" & state=="Oklahoma"
replace countya = 470 if county=="Garfield" & state=="Oklahoma"
replace countya = 530 if county=="Grant" & state=="Oklahoma"
replace countya = 550 if county=="Greer" & state=="Oklahoma"
replace countya = 710 if county=="Kay" & state=="Oklahoma"
replace countya = 730 if county=="Kingfisher" & state=="Oklahoma"
replace countya = 810 if county=="Lincoln" & state=="Oklahoma"
replace countya = 830 if county=="Logan" & state=="Oklahoma"
replace countya = 1030 if county=="Noble" & state=="Oklahoma"
replace countya = 1090 if county=="Oklahoma" & state=="Oklahoma"
replace countya = 1170 if county=="Pawnee" & state=="Oklahoma"
replace countya = 1190 if county=="Payne" & state=="Oklahoma"
replace countya = 1250 if county=="Pottawatomie" & state=="Oklahoma"
replace countya = 1290 if county=="Roger Mills" & state=="Oklahoma"
replace countya = 1490 if county=="Washita" & state=="Oklahoma"
replace countya = 1530 if county=="Woodward" & state=="Oklahoma"
replace countya = 1510 if county=="Woods" & state=="Oklahoma"

// Step 2.5. - Fixing the Utah counties codes
replace countya = 10 if county=="Beaver" & state=="Utah"
replace countya = 30 if county=="Box Elder" & state=="Utah"
replace countya = 50 if county=="Cache" & state=="Utah"
replace countya = 70 if county=="Carbon" & state=="Utah"
replace countya = 90 if county=="Daggett" & state=="Utah"
replace countya = 110 if county=="Davis" & state=="Utah"
replace countya = 130 if county=="Duchesne" & state=="Utah"
replace countya = 150 if county=="Emery" & state=="Utah"
replace countya = 170 if county=="Garfield" & state=="Utah"
replace countya = 190 if county=="Grand" & state=="Utah"
replace countya = 210 if county=="Iron" & state=="Utah"
replace countya = 230 if county=="Juab" & state=="Utah"
replace countya = 250 if county=="Kane" & state=="Utah"
replace countya = 270 if county=="Millard" & state=="Utah"
replace countya = 290 if county=="Morgan" & state=="Utah"
replace countya = 310 if county=="Piute" & state=="Utah"
replace countya = 330 if county=="Rich" & state=="Utah"
replace countya = 350 if county=="Salt Lake" & state=="Utah"
replace countya = 370 if county=="San Juan" & state=="Utah"
replace countya = 390 if county=="Sanpete" & state=="Utah"
replace countya = 410 if county=="Sevier" & state=="Utah"
replace countya = 430 if county=="Summit" & state=="Utah"
replace countya = 450 if county=="Tooele" & state=="Utah"
replace countya = 470 if county=="Uintah" & state=="Utah"
replace countya = 490 if county=="Utah" & state=="Utah"
replace countya = 510 if county=="Wasatch" & state=="Utah"
replace countya = 530 if county=="Washington" & state=="Utah"
replace countya = 550 if county=="Wayne" & state=="Utah"
replace countya = 570 if county=="Weber" & state=="Utah"

* Allocating Dakota counties to North and South Dakota
replace state = "North Dakota" if state == "Dakota"
egen gisjoin1 = mode(gisjoin) if state=="North Dakota", by(county)
egen countya1 = mode(countya) if state=="North Dakota", by(county)
egen statea1 = mode(statea) if state=="North Dakota", by(county)
replace gisjoin = gisjoin1 if statea == 95 & gisjoin != gisjoin1
replace countya = countya1 if statea == 95 & countya != countya1
replace statea = statea1 if statea == 95 & statea != statea1
drop gisjoin1 countya1  statea1

replace state = "South Dakota" if statea == 95
egen gisjoin1 = mode(gisjoin) if state=="South Dakota", by(county)
egen countya1 = mode(countya) if state=="South Dakota", by(county)
egen statea1 = mode(statea) if state=="South Dakota", by(county)
replace gisjoin = gisjoin1 if statea == 95 & gisjoin != gisjoin1
replace countya = countya1 if statea == 95 & countya != countya1
replace statea = statea1 if statea == 95 & statea != statea1
drop gisjoin1 countya1  statea1
drop if statea == 95
drop if statea ==.																

egen pop_county = rowtotal(a3y001 aym001 aum001 aot001 aj3001)
egen urbpop_county = rowtotal(a36001 ayt001 auu001 ao4001 ake001)
drop  a3y001- ako001

gen FIPScode = statea*100 +countya/10

tsset FIPScode year
tsfill

csipolate pop year , gen(totpop) by(FIPScode)
csipolate urbpop_county year , gen(urbpop) by(FIPScode)

forvalues i = 1/107339{
replace state = state[`i'-1] in `i' if state==""
replace county = county[`i'-1] in `i' if county=="" 
 }

keep year state county FIPScode totpop urbpop

save "$dropbox/cleaned files/countypop", replace


**********************************************************
* A.23 - Cleaning Failure Data from 1893 Bradstreets' Dataset
***********************************************************

import excel "failures1893.xls", /*sheet("Sheet 1")*/ firstrow clear

rename City Place
rename County county
rename State state
rename Banktype banktype
destring Assets , replace force
drop in 562
drop county
replace banktype= "State" if banktype!="National" & banktype != "Private"
destring Sr, replace force
drop if Sr==. // I am choosing to throw out the banks that I could not match to the Bank Almanac. Might worth to check if there is a better way.
merge 1:1 Sr using "$dropbox/cleaned files/1893"


gen clearing =  regexm(Name,"(^[a-zA-Z]+.*)( clearing)")
replace clearing = regexm(Name,"(^[a-zA-Z]+.*)( Clearing)")
drop if clearing ==1
drop clearing

// 2 - Creating Banktype Variable

replace banktype = "National" if No!=. & banktype==""
replace banktype = "Private" if PrivateBank==1 & banktype==""
replace banktype = "State" if  banktype==""

gen failures = _merge==3
gen nbanks = 1
collapse (sum) failures nbanks, by(FIPSState FIPSCounty banktype)

save "$dropbox/cleaned files/nfailbks1893", replace

**********************************************************
* A.25 Creating Type of Banking System File
***********************************************************

clear all

gen banktype = ""
set obs 3
replace banktype="National" in 1
replace banktype="State" in 2
replace banktype="Private" in 3

save "$dropbox/cleaned files/banktype", replace


*****************************************************************************************
*****************************************************************************************
******************************  B: MERGING DATASETS   ***********************************
*****************************************************************************************
*****************************************************************************************

********************************************************************************************
* Step B.1. - Merging the Dataset for the Main Sample
**********************************************************************************************

cd "$dropbox/cleaned files/"
use baseline, clear

merge m:1 state year using popula
drop if _merge==2
drop _merge

merge m:1 state year using urbpop
drop if _merge==2
drop _merge

merge m:1 state year using gini
drop if _merge==2
drop _merge

merge m:1 state year using black
drop if _merge==2
drop _merge

merge 1:1 state year banktype using finstat_fin
drop if _merge==2
drop _merge

merge 1:1 state year banktype using exam_fin
drop if _merge==2
drop _merge

merge m:1 stabr using reportdate.dta
drop if _merge==2
drop _merge

merge m:1 stabr using adoption_pair.dta
drop if _merge==2
drop _merge

merge 1:1 state year banktype using nbank
drop if _merge==2
drop _merge

merge 1:1 state year banktype using bradstreet_n
drop if _merge==2
drop _merge

merge 1:1 state year banktype using bradstreet_lev
drop if _merge==2
drop _merge

merge 1:1 state year banktype using rates
drop if _merge==2
drop _merge

merge 1:1 stabr year banktype using statesbs
drop if _merge==2
drop _merge

merge 1:1 state year banktype using dl
drop if _merge==2
drop _merge

merge m:1 state year using sba
drop if _merge==2
drop _merge

merge m:1 stabr year using reserve
drop if _merge==2
drop _merge

save "sample", replace

********************************************************************************************
* Step B.2. - Merging the Dataset for the Referenda Sample
**********************************************************************************************

use gini, clear 
merge 1:1 county state using electionres
drop if _merge==2
drop _merge

merge 1:1 county state using pres_res
drop if _merge==2
drop _merge

merge 1:1 county state using bankspercounty
drop _merge

save sample_ref, replace

********************************************************************************************
* Step B.3. - Merging the Dataset for the Contiguous county Analysis
**********************************************************************************************

clear all

gen year = .
set obs 5
replace year = 1870 in 1
replace year = 1880 in 2
replace year = 1890 in 3
replace year = 1900 in 4
replace year = 1910 in 5

cross using "state codes"

merge m:1 state year using "stfinstat_fin.dta"
keep if _merge==3
drop _merge

merge m:1 state year using "stexam_fin.dta"
keep if _merge==3
drop _merge

merge m:1 stabr using "reportdate.dta"
keep if _merge==3
drop _merge

joinby FIPSstate using "countypairs"

merge m:1 FIPScounty stabr year using "nbanks_jaremski"
drop if _merge==2
drop _merge

foreach var of varlist countState-countTrust{
	replace `var' = 0 if `var'==. & year==1870 | `var'==. & year==1880 | `var'==. & year==1890 | `var'==. & year==1900 | `var'==. & year==1910
	}
	
merge m:1 FIPScode year using "countypop"
keep if _merge==3
drop _merge

save contiguous_county, replace


********************************************************************************************
* Step B.4. - Merging the Datasets for the 1893 Banking Crisis Analysis
**********************************************************************************************

use "state codes",clear 

// 2 - Merge with File Containing all counties

merge 1:m state using "US_FIPS_Codes.dta"
keep if _merge==3
drop _merge
gen FIPScode = FIPSState + FIPSCounty
destring FIPScode, replace force

// 2.1 - Merge with county pairs
merge 1:m FIPScode using "countypairs"
drop if _merge==2
drop _merge

cross using "banktype.dta"
gen year=1893

// 3 - Merge with File containing number of Failures by county and Banking System in 1893

merge m:1 FIPSState FIPSCounty banktype using "nfailbks1893"
drop if _merge==2
drop _merge

// 4 - Merge Treatment Variables

merge m:1 state year using "stfinstat_fin.dta"
keep if _merge==3
drop _merge

merge m:1 state year using "stexam_fin.dta"
keep if _merge==3
drop _merge
replace exam = 1 if banktype=="National"
replace rep = 1 if banktype=="National"

// 4.1 - Report Requirements adoption date

merge m:1 stabr using "reportdate.dta"
keep if _merge==3
drop _merge

save failures1893sample, replace

*****************************************************************************************
*****************************************************************************************
******************************  C: Regressions and Figures - Published Paper    ***********************************
*****************************************************************************************
*****************************************************************************************

clear all
use "sample", replace
set matsize 3000

log using granja_disclosurereg, replace


***********************************
* C.0 - Creating the fixed effects
********************************

drop if state=="Alaska" | state=="Hawaii"

egen styr = group(state year)
egen yrbt = group(banktype year)
egen stbt = group(banktype state)
egen btype = group(banktype)
egen stategroup = group(state)

***********************************
* C.1 Defining the Panel
***********************************

tsset stbt year

***********************************
* C.2 - Creating Leads and Lags of main treatment variables
***********************************
 
foreach x in rep exam{
	gen t0`x' = `x' - l.`x'
	gen t1`x' = l.t0`x'
	gen t2`x' = l2.t0`x'
	gen t3`x' = l3.t0`x'
	gen t4`x' = l4.t0`x'
	gen t5`x' = l5.t0`x'
	gen t_1`x' = f.t0`x'
	gen t_2`x' = f2.t0`x'
	gen t_3`x' = f3.t0`x'
	gen t_4`x' = f4.t0`x'
	gen t_5`x' = f5.t0`x'
	replace t0`x' = 0 if t0`x'==.
	replace t1`x' = 0 if t1`x'==.
	replace t2`x' = 0 if t2`x'==.
	replace t3`x' = 0 if t3`x'==.
	replace t4`x' = 0 if t4`x'==.
	replace t5`x' = 0 if t5`x'==.

	replace t_1`x' = 0 if t_1`x'==.
	replace t_2`x' = 0 if t_2`x'==.
	replace t_3`x' = 0 if t_3`x'==.
	replace t_4`x' = 0 if t_4`x'==.
	replace t_5`x' = 0 if t_5`x'==.

	gen t3long`x' = `x'
	replace t3long`x' = 0 if t0`x'==1 | t1`x' == 1 | t2`x'==1
	gen t3short`x' = t0`x' + t1`x' + t2`x'
	gen t3pre`x' = t_1`x' + t_2`x' + t_3`x'
	
	gen t5long`x' = `x'
	replace t5long`x' = 0 if t0`x'==1 | t1`x' == 1 | t2`x'==1 | t3`x'==1 | t4`x'==1
	gen t5short`x' = t0`x' + t1`x' + t2`x' + t3`x' + t4`x' 	
	
	gen eventime`x' = 0 if t0`x'==1
	replace eventime`x' = -4 if t_4`x'==1
	replace eventime`x' = -3 if t_3`x'==1
	replace eventime`x' = -2 if t_2`x'==1
	replace eventime`x' = -1 if t_1`x'==1
	replace eventime`x' = 1 if t1`x'==1
	replace eventime`x' = 2 if t2`x'==1
	replace eventime`x' = 3 if t3`x'==1
	replace eventime`x' = 4 if t4`x'==1
}
***************************************************************
* C.3 -> Computing main independent and dependent variables

* C.3.1 - Failure Rate Variable

replace nbank = nb if year>1908 // Supplementing with data from Grossman (2001) following 1909
gen frate = nfail/nbank
replace frate = 0 if nfail==. & year>1891

* C.3.2 - Creating the Balance Sheet Ratios

gen liqratio = cash/depothd
gen gvratio = govtsec/totass
gen reratio = totre/totass
gen capratio = (cap + surp)/totliab
gen demratio = depothd/totdep
gen timeratio = depotht/totdep
gen interbkratio = depibk/totdep
replace totass = totass/1000000
replace totdep = totdep/1000000


* Control Variables -> Splines 
// Quadratic Spline in the number of banks
mkspline nbank 4 = nbank, pctile
foreach num of numlist 1(1)4{
	gen nb`num' = nbank`num'^2
}

* C.3.3 - Within state-year differences in the main variables (

foreach var of varlist frate totass capratio liqratio demratio interbkratio gvratio reratio{
	tempvar nat_`var'
	gen `nat_`var'' = `var' if banktype=="National"
	egen t_`var' = total(`nat_`var''), by(styr)
	gen diff_`var' = `var' - t_`var'
	drop t_`var'
}

* C.3.4 - Creating variables for the Financial Development and Duration Analysis

egen totbanks = total(nbank), by(styr)
replace totbanks=. if totbanks==0

gen totbankspc = totbanks/totpop*1000000
gen lnbankspc = ln(totbankspc)

gen urbpct = toturb/totpop
gen lngini = ln(gini_index)
gen lnpop = ln(totpop)

* Splines for Total Population 
mkspline totpop 5 = totpop, pctile
foreach num of numlist 1(1)5{
	gen tpop`num' = totpop`num'^2
}

*********************************************************
*** Table 2: Summary Statistics
*********************************************************

tabstat frate nbank totass totdep liqratio gvratio reratio capratio demratio timeratio interbkratio intloan intdep if banktype=="State", s(n me sd p25 p50 p75) c(stats)
tabstat frate nbank totass totdep liqratio gvratio reratio capratio demratio timeratio interbkratio intloan intdep if banktype=="National" , s(n me sd p25 p50 p75) c(stats)

*********************************************************
*** Table 3: Disclosure and Supervisory Regulation and Bank Failures
*********************************************************
	
areg frate l.rep l.exam nbank1-nb4 i.yrbt i.stbt if year>1895, absorb(styr) vce(cluster stbt)
	outreg2 frate l.rep l.exam ///
	using Table3.tex, ///
	tex nocons adjr replace bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate l.rep l.exam totass capratio  nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 frate l.rep l.exam totass capratio ///
	using Table3.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)

areg frate l.rep l.exam liqratio gvratio reratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 frate l.rep l.exam liqratio gvratio reratio ///
	using Table3.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate l.rep l.exam demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 frate l.rep l.exam demratio interbkratio ///
	using Table3.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg frate l.rep totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table3.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate l.exam totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.exam totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table3.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table3.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)		

*************************************************	
* Table 4 - Robustness: Disclosure and Supervisory Regulation and Bank Failures
*************************************************			
	
replace reserve = 0 if reserve==. & year<1914	
replace reserve = 0 if banktype!="State" // The reserve requirement for national banks does not vary across states and will be absorbed by the year - Banktype FE
replace sba = 0 if banktype!="State" // The State Banking Authority concept does not apply for national banks. I choose an arbitrary number and it will be absorbed by the year - Banktype FE

areg frate l.rep l.exam reserve totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam reserve totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons replace adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample, Full Sample, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)		

areg frate l.rep l.exam m3 totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam m3 totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample, Full Sample, State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    
			
areg frate l.rep l.exam sba totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam sba totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample, Full Sample, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)		
	
areg frate l.rep l.exam reserve sba m3 totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam reserve sba m3 totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample, Full Sample, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)

preserve
winsor2 frate, replace cuts(0 99) 
areg frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons  adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample,"Winsorize Top 1%" ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	
restore

areg frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if nbank>20, absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample,"> 20 Banks" ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	
	
areg frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt [aw=totass], absorb(styr) vce(cl stbt)
	outreg2 frate l.rep l.exam totass capratio liqratio gvratio reratio demratio interbkratio ///
	using Table4.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(Sample,"Weighted by Total Assets" , State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)  	
	
*************************************************	
* Table 5 - Intertemporal Effects of Disclosure and Supervisory Regulation
*************************************************			
		
areg frate l.rep l.frate totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt , absorb(styr) vce(cluster stbt)
	outreg2 frate l.rep l.frate ///
	using Table5.tex, ///
	tex nocons adjr replace bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate l.exam l.frate totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 frate l.exam l.frate ///
	using Table5.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate l.rep l.exam l.frate totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 frate l.rep l.exam l.frate ///
	using Table5.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	

areg frate t_2rep t_1rep t0rep t1rep t2rep t3longrep totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 frate t_2rep t_1rep t0rep t1rep t2rep t3longrep ///
	using Table5.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	
	
*************************************************	
* Table 6 - Disclosure and Supervisory Regulation and Bank Failures - Within State-Year Estimator
*************************************************					

areg diff_frate l.rep l.exam diff_totass diff_capratio diff_liqratio diff_gvratio diff_reratio diff_demratio diff_interbkratio lnpop  nbank1-nb4 i.year if banktype=="State" , absorb(state) vce(cl state)
	outreg2 diff_frate l.rep l.exam lnpop ///
	using Table6.tex, ///
	tex nocons adjr replace bdec(4)tdec(4) label title("") addtext(Sample, Full Sample ,Controls, Yes, State Fixed-Effects, Yes, Year Fixed-Effects, Yes)    	

areg diff_frate l.rep l.exam diff_totass diff_capratio diff_liqratio diff_gvratio diff_reratio diff_demratio diff_interbkratio urbpct nbank1-nb4 i.year if banktype=="State" , absorb(state) vce(cl state)
	outreg2 diff_frate l.rep l.exam urbpct  ///
	using Table6.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(Sample, Full Sample ,Controls, Yes, State Fixed-Effects, Yes, Year Fixed-Effects, Yes)    	
	
areg diff_frate l.rep l.exam diff_totass diff_capratio diff_liqratio diff_gvratio diff_reratio diff_demratio diff_interbkratio man nbank1-nb4 i.year if banktype=="State" , absorb(state) vce(cl state)
	outreg2 diff_frate l.rep l.exam man ///
	using Table6.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(Sample, Full Sample ,Controls, Yes, State Fixed-Effects, Yes, Year Fixed-Effects, Yes)    	
	
areg diff_frate l.rep l.exam diff_totass diff_capratio diff_liqratio diff_gvratio diff_reratio diff_demratio diff_interbkratio lngini  nbank1-nb4 i.year if banktype=="State" , absorb(state) vce(cl state)
	outreg2 diff_frate l.rep l.exam lngini ///
	using Table6.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(Sample, Full Sample ,Controls, Yes, State Fixed-Effects, Yes, Year Fixed-Effects, Yes)    	
	
areg diff_frate l.rep l.exam diff_totass diff_capratio diff_liqratio diff_gvratio diff_reratio diff_demratio diff_interbkratio lnpop urbpct man  lngini  nbank1-nb4 i.year if banktype=="State" , absorb(state) vce(cl state)
	outreg2 diff_frate l.rep l.exam lnpop urbpct man  lngini ///
	using Table6.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(Sample, Full Sample ,Controls, Yes, State Fixed-Effects, Yes, Year Fixed-Effects, Yes)    	

*************************************************	
* Table 8: Panel A - Disclosure and Supervisory Regulation and Access to Credit
*************************************************

areg lnbankspc l.rep i.year totpop1-tpop4 urbpct lngini man if banktype=="State" , absorb(state) vce(cluster state)
	outreg2 lnbankspc l.rep ///
	using Table8.tex, ///
	tex nocons adjr replace bdec(4)tdec(4) label title("") addtext(State Fixed-Effects, Yes, Year Fixed-Effects, Yes, State/Charter Type Fixed-Effects, No)    

areg lnbankspc l.exam i.year totpop1-tpop4 urbpct lngini man if banktype=="State" , absorb(state) vce(cluster state)
	outreg2 lnbankspc l.exam ///
	using Table8.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(State Fixed-Effects, Yes, Year Fixed-Effects, Yes, State/Charter Type Fixed-Effects, No)	
	
areg lnbankspc l.rep l.exam i.year totpop1-tpop5 urbpct lngini man if banktype=="State", absorb(state) vce (cluster state)
	outreg2 lnbankspc l.rep l.exam ///
	using Table8.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(State Fixed-Effects, Yes, Year Fixed-Effects, Yes, State/Charter Type Fixed-Effects, No)    
	
areg intloan  l.rep i.year nbank1-nb4, absorb(stbt) vce(cluster stbt)
	outreg2 intloan l.rep ///
	using Table8.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(State Fixed-Effects, No, Year Fixed-Effects, Yes, State/Charter Type Fixed-Effects, Yes)

areg intloan  l.exam i.year nbank1-nb4, absorb(stbt) vce(cluster stbt)
	outreg2 intloan l.exam ///
	using Table8.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(State Fixed-Effects, No, Year Fixed-Effects, Yes, State/Charter Type Fixed-Effects, Yes)
	
areg intloan l.rep l.exam i.year nbank1-nb4 , absorb(stbt) vce(cl stbt)
	outreg2 intloan l.rep l.exam ///
	using Table8.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title("") addtext(State Fixed-Effects, No, Year Fixed-Effects, Yes, State/Charter Type Fixed-Effects, Yes)

*************************************************	
* Table 9: Disclosure and Supervisory Regulation and Banking Outcomes
*************************************************

areg capratio l.rep gvratio interbkratio  i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 capratio l.rep ///
	using Table9.xls, ///
	excel nocons adjr replace bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg capratio l.exam gvratio interbkratio  i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 capratio l.exam ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	
	
areg capratio l.rep l.exam gvratio interbkratio i.yrbt i.stbt  , absorb(styr) vce(cluster stbt)
	outreg2 capratio l.rep l.exam ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

* Time Deposits

areg timeratio l.rep i.yrbt i.stbt gvratio interbkratio , absorb(styr) vce(cluster stbt)
	outreg2 timeratio l.rep ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg timeratio l.exam i.yrbt i.stbt gvratio interbkratio, absorb(styr) vce(cluster stbt)
	outreg2 timeratio l.exam ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	
	
areg timeratio l.rep l.exam gvratio interbkratio i.yrbt i.stbt, absorb(styr) vce(cluster stbt)
	outreg2 timeratio l.rep l.exam ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

* Interest Rates on Deposits	
	
areg intdep l.rep i.year nbank1-nb4, absorb(stbt) vce(cluster stbt)
	outreg2 intdep l.rep ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, No, Year-BankType fixed effects?, No, Year fixed effects?, Yes, State-BankType fixed effects?, Yes)

areg intdep l.exam i.year nbank1-nb4, absorb(stbt) vce(cluster stbt)
	outreg2 intdep l.exam ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, No, Year-BankType fixed effects?, No, Year fixed effects?, Yes, State-BankType fixed effects?, Yes)	
	
areg intdep l.rep l.exam i.year nbank1-nb4, absorb(stbt) vce(cluster stbt)
	outreg2 intdep l.rep l.exam ///
	using Table9.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(State-Year fixed effects?, No, Year-BankType fixed effects?, No, Year fixed effects?, Yes, State-BankType fixed effects?, Yes)

*************************************************	
* Table 11: Heterogeneous Effects of Disclosure and Supervisory Regulations
*************************************************

egen median_gini = median(gini_index), by(year)
gen hi_gini = gini_index>=median_gini & gini_index!=.
gen low_gini = gini_index<median_gini & gini_index!=.

// PANEL A - Split the treatment effects from low/high Gini

gen rep_hg = rep*hi_gini
gen rep_lg = rep*low_gini

gen exam_hg = exam*hi_gini
gen exam_lg = exam*low_gini	

label var rep_hg "Rep \times High Gini"
label var rep_lg "Rep \times Low Gini"
label var exam_hg "Exam \times High Gini"
label var exam_lg "Exam \times Low Gini"

	
areg frate l.rep_hg l.rep_lg totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
	testparm l.rep_hg l.rep_lg, equal
	local a `r(p)'
	outreg2 frate l.rep_hg l.rep_lg ///
	using Table11.tex, ///
	tex nocons adjr replace bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients, - ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg frate l.exam_hg l.exam_lg totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
	testparm l.exam_hg l.exam_lg, equal
	local a `r(p)'
	outreg2 frate l.exam_hg l.exam_lg ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, - ,F-Test for Difference across Exam Coefficients, `a' ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    
	
areg frate l.rep_hg l.rep_lg l.exam_hg l.exam_lg totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
	testparm l.rep_hg l.rep_lg, equal
	local a `r(p)'
	testparm l.exam_hg l.exam_lg, equal
	local b `r(p)'
	outreg2 frate l.rep_hg l.rep_lg l.exam_hg l.exam_lg ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients,`b',State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    
	
areg lnbankspc l.rep_hg l.rep_lg i.year totpop1-tpop4 urbpct if banktype=="State", absorb(state) vce(cl state)
	testparm l.rep_hg l.rep_lg, equal
	local a `r(p)'
	outreg2 lnbankspc l.rep_hg l.rep_lg ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients, - ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)
    
areg lnbankspc l.exam_hg l.exam_lg i.year totpop1-tpop4 urbpct if banktype=="State", absorb(state) vce(cl state)
	testparm l.exam_hg l.exam_lg, equal
	local a `r(p)'
	outreg2 lnbankspc l.exam_hg l.exam_lg ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, - ,F-Test for Difference across Exam Coefficients, `a' ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)

areg lnbankspc l.rep_hg l.rep_lg l.exam_hg l.exam_lg i.year totpop1-tpop4 urbpct if banktype=="State", absorb(state) vce(cluster state)
	testparm l.rep_hg l.rep_lg, equal
	local a `r(p)'
	testparm l.exam_hg l.exam_lg, equal
	local b `r(p)'
	outreg2 lnbankspc l.rep_hg l.rep_lg l.exam_hg l.exam_lg ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients, `b' ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

// PANEL B - Stratify sample into high/low percentage of private unincorporated banks in the state

gen priv_share = nbank/totbanks if banktype=="Private"
egen pct_priv = total(priv_share), by(styr)

egen median_pctpriv = median(pct_priv), by(year)

gen hi_priv =  pct_priv>median_pctpriv & pct_priv!=.
gen lo_priv =  pct_priv<=median_pctpriv & pct_priv!=.

gen rep_hp =rep*hi_priv
gen rep_lp = rep*lo_priv

gen exam_hp = exam*hi_priv
gen exam_lp = exam*lo_priv

areg frate l.rep_hp l.rep_lp totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
	testparm l.rep_hp l.rep_lp, equal
	local a `r(p)'
	outreg2 frate l.rep_hp l.rep_lp  ///
	using Table11.tex, ///
	tex nocons adjr replace bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients, - ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg frate l.exam_hp l.exam_lp totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
	testparm l.exam_hp l.exam_lp, equal
	local a `r(p)'
	outreg2 frate l.exam_hp l.exam_lp ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, - ,F-Test for Difference across Exam Coefficients, `a' ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)	
	
areg frate l.rep_hp l.rep_lp l.exam_hp l.exam_lp totass capratio liqratio gvratio reratio demratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
	testparm l.rep_hp l.rep_lp, equal
	local a `r(p)'
	testparm l.exam_hp l.exam_lp, equal
	local b `r(p)'
	outreg2 frate l.rep_hp l.rep_lp l.exam_hp l.exam_lp ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients,`b',State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg lnbankspc l.rep_hp l.rep_lp i.year totpop1-tpop4 urbpct if banktype=="State", absorb(state) vce(cl state)
	testparm l.rep_hp l.rep_lp, equal
	local a `r(p)'
	outreg2 lnbankspc l.rep_hp l.rep_lp ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients, - ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

areg lnbankspc l.exam_hp l.exam_lp i.year totpop1-tpop4 urbpct if banktype=="State", absorb(state) vce(cl state)
	testparm l.exam_hp l.exam_lp, equal
	local a `r(p)'
	outreg2 lnbankspc l.exam_hp l.exam_lp ///
	using Table11.tex, ///
	tex nocons adjr bdec(4) tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients,- ,F-Test for Difference across Exam Coefficients,  `a' ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    	
	
areg lnbankspc l.rep_hp l.rep_lp l.exam_hp l.exam_lp i.year totpop1-tpop4 urbpct if banktype=="State", absorb(state) vce(cl state)
	testparm l.rep_hp l.rep_lp, equal
	local a `r(p)'
	testparm l.exam_hp l.exam_lp, equal
	local b `r(p)'
	outreg2 lnbankspc l.rep_hp l.rep_lp l.exam_hp l.exam_lp ///
	using Table11.tex, ///
	tex nocons adjr bdec(4)tdec(4) label title ("Capital Ratio") addtext(F-Test for Difference across Rep. Coefficients, `a',F-Test for Difference across Exam Coefficients, `b' ,State-Year fixed effects?, Yes, Year-BankType fixed effects?, Yes, State-BankType fixed effects?, Yes)    

	
*************************************************	
* Figure 4: Heterogeneous Effects of Disclosure and Supervisory Regulations
*************************************************

preserve	
areg frate c.l.rep#i.stategroup l.exam totass liqratio2 capratio gvratio reratio interbkratio nbank1-nb4 i.yrbt i.stbt if banktype!="Private" , absorb(styr) vce(cl stbt)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..48]
matrix A1 = A1'

putexcel A1=matrix(A1)

import excel "regcoefs.xls", sheet("Sheet1") clear
drop if A==0

twoway ///
hist A, width(.04) start(-.12) ///
	xlabel(-.12(.04)0.04, labsize(vsmall)) ylab(, nogrid labsize(vsmall)) ///
	title("", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 	///
	xtitle("State-Specific Coefficients ({&gamma}{sub:s})", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(vsmall)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(5.5 -200 "Density", place(se) si(vsmall) orientation(vertical)) ///
	saving(treatmenteffects, replace)
	graph export treatmenteffects.pdf, replace
restore	
		
	
*************************************************	
* Table 10: Political Economy of Disclosure and Supervisory Regulations
*************************************************

***************************************************************************************************
* Computing Hazard models
***************************************************************************************************

// Declaring Survival Time Dataset

gen freebank = stabr =="MI" | stabr =="GA" | stabr =="NY" | stabr =="AL" | stabr =="NJ" | stabr =="IL" | stabr =="MA" | stabr =="OH" | stabr =="VT" | stabr =="CT" | stabr =="IN" | stabr =="TN" | stabr =="WI" | stabr =="FL" | stabr =="LA" | stabr =="IA" | stabr =="MN" | stabr =="PA"
gen lnblack = ln(black)
gen blackpop = black/totpop
drop priv_share pct_priv
gen priv_share = nbank/totbanks if banktype=="Private"
egen pct_priv = total(priv_share), by(styr)

gen ln_reppair = ln(report_pair)
gen ln_exampair = ln(exam_pair)
gen ln_area = ln(totarea)

gen pct_state = nbank/totbanks
gen statebankspc = nbank/totpop
replace statebankspc = statebankspc*1000000

label var lngini "Ln(Gini)"
label var pct_priv "\% Private Bk."
label var pct_state "\% State Bk."
label var lnpop "Ln(Total Population)"
label var lnblack "Ln(Black)"
label var urbpct "\% Urbanization"
label var ln_area "Ln(Area Size)"
label var man "\% Manufacturing"

stset year, id(stbt) failure(rep==1) origin(year==1876) scale(365.25)
streg lngini pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man  if banktype=="State", distribution(weibull) robust ti nohr
		outreg2 lngini  pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man ///
		using duration.tex, ///
		tex replace bdec(4)tdec(4) e(ll) label title("Capital Ratio") ctitle("Exam")
		
streg pct_priv pct_state freebank c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man if banktype=="State", distribution(weibull) robust ti
		outreg2 lngini pct_priv pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man ///
		using duration.tex, ///
		tex  bdec(4)tdec(4) e(ll) label title ("Capital Ratio") ctitle("Exam")

streg lngini pct_priv pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man if banktype=="State", distribution(weibull) robust ti
		outreg2 lngini pct_priv pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man ///
		using duration.tex, ///
		tex  nocons bdec(4)tdec(4) e(ll) label title ("Capital Ratio") ctitle("Exam")	
		
stset year, id(stbt) failure(exam==1) origin(year==1876) scale(365.25)

streg lngini pct_state freebank c.statebankspc##c.statebankspc lnpop lnblack urbpct ln_area man if banktype=="State", distribution(weibull) robust ti 
		outreg2 lngini pct_priv pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man ///
		using duration.tex, ///
		tex  nocons bdec(4)tdec(4) e(ll) label title ("Capital Ratio") ctitle("Exam")

streg pct_priv pct_state freebank c.statebankspc##c.statebankspc lnpop lnblack urbpct ln_area man if banktype=="State", distribution(weibull) robust ti
		outreg2 lngini pct_priv pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man ///
		using duration.tex, ///
		tex  nocons bdec(4)tdec(4) e(ll) label title ("Capital Ratio") ctitle("Exam")
		
streg lngini pct_priv pct_state freebank c.statebankspc##c.statebankspc lnpop lnblack urbpct ln_area man if banktype=="State", distribution(weibull) robust ti
		outreg2 lngini pct_priv pct_state c.statebankspc##c.statebankspc freebank lnpop lnblack urbpct ln_area man ///
		using duration.tex, ///
		tex nocons bdec(4)tdec(4) e(ll) label title ("Capital Ratio") ctitle("Exam")
	
log close
clear


*************************************************	
* Table 10 PanelB : Political Economy of Disclosure and Supervisory Regulations
*************************************************

use sample_ref, clear

* Populate the number of banks variables for the counties with no banks in the data

foreach var of varlist  nbanksNational nbanksPrivate nbanksState totalbanks {
	replace `var' = 0 if `var'==.
}


* Generating the outcome and political variables

gen pct_yes = yesvote/totalvote
gen pct_rep = Republican/presvote
gen pct_dem = Democrat/presvote
gen pct_pro = Progressive/presvote

gen ele_part = presvote/totpop

* Generating Economical variables and ration

gen man_share = mfgout/(mfgout+farmout)

* Generating the demographical variables

tab state, gen (state)
gen pct_urb = urb890/totpop
gen ln_totpop = ln(totpop)

gen pct_bla = negtot/totpop
gen lnblack = ln(1 + negtot)

* Creating the Banking Variables

gen bks_pc = (totalbanks/totpop)*1000
gen pct_nat = nbanksNational/totalbanks
gen pct_pri =nbanksPrivate/totalbanks
replace pct_pri = 0 if pct_pri==.

gen nobks = 1 if totalbanks==0
replace nobks = 0 if nobks==.

* The Gini Coefficient

gen lngini = ln(gini)
gen lngini_manu = lngini*man_share
gen pct_pri_manu = pct_pri*man_share


reg pct_yes lngini state1, robust
reg pct_yes lngini pct_pri, robust

reg pct_yes lngini, robust
	outreg2 pct_yes lngini  ///
	using main_pol.xls, ///
	excel nocons adjr replace bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, Agr. Elite) 

reg pct_yes pct_pri nobks, robust
	outreg2 pct_pri nobks  ///
	using main_pol.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, Inc. Fin)

reg pct_yes lngini pct_pri nobks, robust
	outreg2 lngini pct_pri nobks  ///
	using main_pol.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, Agr. + Fin.)

reg pct_yes lngini pct_pri nobks pct_dem pct_pro ele_part, robust
	outreg2 lngini pct_pri nobks pct_dem pct_pro ele_part  ///
	using main_pol.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, Political)
	
reg pct_yes lngini pct_pri nobks ln_totpop lnblack pct_urb, robust
	outreg2 lngini pct_pri nobks ln_totpop lnblack pct_urb ///
	using main_pol.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, Demograph)

reg pct_yes lngini pct_pri nobks man_share , robust
	outreg2 pct_yes lngini pct_pri nobks man_share ///
	using main_pol.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, Manufacturing)
	
reg pct_yes lngini nobks pct_pri ln_totpop pct_urb lnblack pct_pri pct_dem pct_pro ele_part  man_share, robust
	outreg2 lngini nobks pct_pri ln_totpop pct_urb lnblack pct_pri pct_dem pct_pro ele_part  man_share ///
	using main_pol.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Determinants of voting") addtext(Specification, All controls)	

	
*************************************************	
* Table 7: Disclosure and Supervisory Regulation and Bank Failures: State Border Analysis
*************************************************	
	
use failures1893sample, clear


gen trep = year - report if banktype=="State"
replace trep = year - 1865 if banktype=="National"
replace trep = 0 if trep < 0
gen ln_trep = ln(1+trep)

gen texam = year - examination if banktype=="State"
replace texam = year - 1865 if banktype=="National"
replace texam = 0 if texam < 0
gen ln_texam = ln(1+texam)

* Splines 
// Quadratic Spline in the number of banks
mkspline nbank 4 = nbank, pctile
foreach num of numlist 1(1)4{
	gen nb`num' = nbank`num'^2
}

// Failure Rates
gen fail = failures>0 if failures!=.

// Indicator variables
egen btype = group(banktype)

// 
egen totnat = total(nbanks) if banktype=="National",by (FIPScode)
egen totalnat = total(totnat),by(FIPScode)

egen totstat = total(nbanks) if banktype=="State",by (FIPScode)
egen totalstate = total(totstat),by(FIPScode)

egen stbt = group(FIPSState banktype)
egen pairbt = group(pair btype)
destring FIPSState, replace force


areg fail ln_trep i.FIPSState nbank1-nb4 if banktype!="Private" & totalnat>0, absorb(pairbt) vce(cluster stbt)
	outreg2 fail ln_trep ///
	using Table7.tex, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State Fixed-Effects, Yes, County Pair/Charter Type Fixed-Effects, Yes)
	
areg fail ln_texam i.FIPSState nbank1-nb4 if banktype!="Private" & totalnat>0, absorb(pairbt) vce(cluster stbt)
	outreg2 fail ln_texam ///
	using Table7.tex, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State Fixed-Effects, Yes, County Pair/Charter Type Fixed-Effects, Yes)
	
areg fail ln_trep ln_texam i.FIPSState nbank1-nb4 if banktype!="Private" & totalnat>0 , absorb(pairbt) vce(cluster stbt)
	outreg2 fail ln_trep ln_texam ///
	using Table7.tex, ///
	excel nocons adjr bdec(4)tdec(4) label title ("Failure Rate") ctitle("Fail Rate") addtext(State Fixed-Effects, Yes, County Pair/Charter Type Fixed-Effects, Yes)
		

*************************************************	
* Table 8 Panel B : Disclosure and Supervisory Regulation and Access to Credit: Counties Straddling State Borders
*************************************************	

use contiguous_county, clear

gen nbanks = countState + countNational 
gen nbankspc = nbanks/totpop*1000
gen ln_nbanks = ln(1+nbankspc)

gen urbpct= urbpop/totpop
gen lntotpop = ln(totpop)

egen pair_yr = group (pair year)

gen trep = year - report
replace trep = 0 if trep < 0
gen ln_trep = ln(1+trep)

gen texam = year - examination
replace texam = 0 if texam < 0
gen ln_texam = ln(1+texam)

mkspline totpop 5 = totpop, pctile
foreach num of numlist 1(1)5{
	gen tpop`num' = totpop`num'^2
}

set matsize 10000
	

areg ln_nbanks ln_trep i.FIPScode totpop1-tpop5 urbpct, absorb(pair_yr) vce(cluster FIPSstate)
	outreg2 ln_nbanks ln_trep ///
	using Table8B.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("") addtext(State Fixed-Effects, Yes, County Pair/Year Fixed-Effects, Yes)

areg ln_nbanks ln_texam i.FIPScode totpop1-tpop5 urbpct, absorb(pair_yr) vce(cluster FIPSstate)
	outreg2 ln_nbanks ln_texam ///
	using Table8B.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("") addtext(State Fixed-Effects, Yes, County Pair/Year Fixed-Effects, Yes)	
	
areg ln_nbanks ln_trep ln_texam i.FIPScode totpop1-tpop5 urbpct, absorb(pair_yr) vce(cluster FIPSstate)
	outreg2 ln_nbanks ln_trep ln_texam ///
	using Table8B.xls, ///
	excel nocons adjr bdec(4)tdec(4) label title ("") addtext(State Fixed-Effects, Yes, County Pair/Year Fixed-Effects, Yes)	

	
