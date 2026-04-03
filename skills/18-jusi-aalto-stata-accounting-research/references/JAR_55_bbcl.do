*********************************************************************************************************************************************************
*
*  The Effect of Regulatory Harmonization on Cross-Border Labor Migration: Evidence from the Accounting Profession
*
*  Matthew J. Bloomfield, Ulf Bruggemann, Hans B. Christensen and Christian Leuz
*
*  This do-file shows the code for the main empirical analysis presented in Table 3 of the paper. 
*  The analysis is based on the EU Labour Force Survey (LFS) core data (version: December 2012).
*  We use the annual files for 29 European countries for years 2002 to 2004 and 2008 to 2010, respectively. 
*
*********************************************************************************************************************************************************

*********************************************************************************************************************************************************
*  I. Data preparation 
*********************************************************************************************************************************************************
**************************************************************************************************************
*  Step 1: Read and clean key LFS items 
**************************************************************************************************************

clear
gen country = ""
save BBCL_Data_raw, replace

local varlist at be bg ch cy cz de dk ee es fi fr gr hu ie is it lt lu lv nl no pl pt ro se si sk uk
qui foreach country of local varlist {

	qui foreach year in 2002 2003 2004 2008 2009 2010 {

		use EU_LFS_yr_`country'`year', clear
		
		*  Clean job code item
		
		tostring isco3d, replace
		replace isco3d = "" if isco3d == "."
		replace isco3d = "0" if isco3d == "0 0" | isco3d == "010"
		destring isco3d, replace
		
		*  Clean items related to mobility
		
		tostring countryb national yearesid countr1y, replace
		
		gen countryb_own = (countryb == "OWN COUNTRY" | countryb == "0" | substr(countryb,1,3) == "000")
		gen countryb_na = (countryb == "NO ANSWER") 
		
		gen national_own = (national == "OWN COUNTRY" | national == "0" | substr(national,1,3) == "000")
		gen national_na = (national == "NO ANSWER")
		
		gen source_eu15 = ((countryb == "001-EU15" | countryb == "111") & (national == "001-EU15" | national == "111"))
		
		replace yearesid = "NA" if yearesid == "." | yearesid == ""
		replace yearesid = substr(yearesid,2,length(yearesid)-1) if substr(yearesid,1,1) == "0" & yearesid != "0"

		gen countr1y_own = (countr1y == country)
		gen countr1y_na = (countr1y == "NO ANSWER" | countr1y == "." | countr1y == "" | countr1y == "99" | real(countr1y) <= 14)
		
		*  Focus on key LFS items
		
		keep country year isco3d countryb_* national_* source_eu15 yearesid countr1y_* sex age marstat hhlink qhhnum hatlevel hatyear sizefirm startime coeffy
		order country year isco3d countryb_* national_* source_eu15 yearesid countr1y_* sex age marstat hhlink qhhnum hatlevel hatyear sizefirm startime coeffy
		
		append using BBCL_Data_raw
		
		compress

		save BBCL_Data_raw, replace

	}

}

**************************************************************************************************************
*  Step 2: Impose sample restrictions and compute key variables
**************************************************************************************************************

use BBCL_Data_raw, clear

*  Compute mobility metrics

gen mob_natbirth = (countryb_own == 0 & yearesid != "0" & national_own == 0)
replace mob_natbirth = . if (countryb_na == 1 & yearesid == "NA") | national_na == 1

gen mob_natbirth_eu15 = mob_natbirth
replace mob_natbirth_eu15 = 0 if source_eu15 == 0 & mob_natbirth == 1

gen startime_adj = startime + 6
gen startime_yrs = floor(startime_adj/12)
gen startyear = year - startime_yrs
gen recent = (startyear >= 1999 & year < 2005) | (startyear >= 2005 & year > 2005)
replace recent = . if startyear == .
gen mob_natbirth_chg = (mob_natbirth == 1 & recent == 1)
replace mob_natbirth_chg = . if startyear == . | mob_natbirth==.

gen mob_yearesid = 0
replace mob_yearesid = 1 if ((year == 2004 | year == 2010) & (yearesid == "1" | yearesid == "2" | yearesid == "3" | yearesid == "4" | yearesid == "5"))
replace mob_yearesid = 1 if ((year == 2003 | year == 2009) & (yearesid == "1" | yearesid == "2" | yearesid == "3" | yearesid == "4"))
replace mob_yearesid = 1 if ((year == 2002 | year == 2008) & (yearesid == "1" | yearesid == "2" | yearesid == "3"))
replace mob_yearesid = . if yearesid == "NA" | (year >= 2005 & year <= 2007)

gen mob_countr1y = (countr1y_own != 1)
replace mob_countr1y = . if countr1y_na == 1

*  Compute controls

***  Female yes/no
gen female = (sex == 2)

***  Has kids yes/no
gen help = (hhlink == 3) if age < 15
bysort country year qhhnum: egen hhlink3 = sum(help)
bysort country year: egen hhlink3_max = max(hhlink3)
replace hhlink3 = . if hhlink3_max == 0
rename hhlink3 hhkids

gen haskids = (hhkids >= 1)
replace haskids = -1 if hhkids == .
replace haskids = -1 if country == "IE"  
/* haskids set to missing for Ireland (see footnote 15 in the paper) */

***  Single yes/no
gen single = (marstat == 1)
replace single = . if marstat ==.

***  Higher education yes/no
gen education_pre = floor(hatlevel/10)
gen education = (education_pre == 5 | education_pre == 6)
replace education = . if education_pre < 3 | education_pre == .

*  Sample restrictions

***  Age restriction
keep if age >= 20 & age <= 59

***  Drop countries that do not provide ISCO3D information at three-digit level (see footnote 12 in the paper)
drop if country == "BG" | country == "PL" | country == "SI"

***  Drop professions subject to confounding regulatory treatment
drop if isco3d == 214 | isco3d == 222 | isco3d == 223 

*  Define samples

gen sample_acc = (isco3d == 241)
gen sample_law = (isco3d == 242)
gen sample_pro = (isco3d >= 200 & isco3d < 300 & isco3d != 241)
gen sample_biz = (isco3d == 121 | isco3d == 122 | isco3d == 123 | isco3d == 131 | isco3d == 341 | isco3d == 342)
keep if sample_acc == 1 | sample_law == 1 | sample_pro == 1 | sample_biz == 1

keep country year sample_* mob_* recent female age haskids single education sizefirm coeffy

compress

save BBCL_Data_clean, replace

*********************************************************************************************************************************************************
*  II. Data analysis
*********************************************************************************************************************************************************

log using "BBCL_LM_Code.log", replace

**************************************************************************************************************
*  Table 3, Panel A and B: Baseline regressions without/with domestic job mobility control
**************************************************************************************************************

use BBCL_Data_clean, clear

*  Prepare regressions 

***  Determine regression samples
gen sample_1 = (sample_acc == 1 | sample_law == 1)
gen sample_2 = (sample_acc == 1 | sample_pro == 1)
gen sample_3 = (sample_acc == 1 | sample_biz == 1)

***  Require mob_natbirth and mob_natbirth_chg to be non-missing
keep if mob_natbirth != . & mob_natbirth_chg != .

***  Compute test variables
gen treatment = sample_acc
gen post = (year > 2005)
gen treatment_post = treatment*post

***  Compute domestic job mobility control
qui forvalues i = 1/3 {

gen dom_obs_unwght = 1 if mob_natbirth == 0 & sample_`i' == 1
gen dom_recent_unwght = 1 if mob_natbirth == 0 & recent == 1 & sample_`i' == 1
gen dom_obs_wght = coeffy if mob_natbirth == 0 & sample_`i' == 1
gen dom_recent_wght = coeffy if mob_natbirth == 0 & recent == 1 & sample_`i' == 1

bysort country year treatment: egen help1 = sum(dom_obs_unwght)
bysort country year treatment: egen help2 = sum(dom_recent_unwght)
gen dom_mob_unwght_`i' = (help2/help1)*100

bysort country year treatment: egen help3 = sum(dom_obs_wght)
bysort country year treatment: egen help4 = sum(dom_recent_wght)
gen dom_mob_wght_`i' = (help4/help3)*100

drop dom_obs* dom_recent_* help*

}

***  Prepare fixed effects
egen bin = group(female age single haskids education)
egen country_job = group(country treatment)
egen country_year = group(country year)

*  Regressions without domestic job mobility control (Panel A)

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	reghdfe mob_natbirth treatment_post [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	reghdfe mob_natbirth treatment_post, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	reghdfe mob_natbirth_chg treatment_post [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	reghdfe mob_natbirth_chg treatment_post, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

*  Regressions with domestic job mobility control (Panel B)

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	rename dom_mob_wght_`i' dom_mob_wght
	reghdfe mob_natbirth treatment_post dom_mob_wght [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve	
	keep if sample_`i' == 1 
	rename dom_mob_unwght_`i' dom_mob_unwght
	reghdfe mob_natbirth treatment_post dom_mob_unwght, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	rename dom_mob_wght_`i' dom_mob_wght
	reghdfe mob_natbirth_chg treatment_post dom_mob_wght [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve	
	keep if sample_`i' == 1 
	rename dom_mob_unwght_`i' dom_mob_unwght
	reghdfe mob_natbirth_chg treatment_post dom_mob_unwght, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}


**************************************************************************************************************
*  Table 3, Panel C: Double matched diff-in-diff analysis
**************************************************************************************************************

*  Double matching

local matchvars single haskids age education female
local controlgroups sample_law sample_pro sample_biz
local mobilitymeasures natbirth natbirth_chg
local onlyrecentyesno 0 1
local coeffyweightsyesno 0 1

qui foreach control in `controlgroups' {
foreach measure in `mobilitymeasures' {
foreach onlyrecent in `onlyrecentyesno' {
foreach coeffyweight in `coeffyweightsyesno' {

	use BBCL_Data_clean, clear
	
	***  Require mob_natbirth and mob_natbirth_chg to be non-missing
	keep if mob_natbirth != . & mob_natbirth_chg != .

	if `onlyrecent'==1 {
		keep if recent == 1
	}
	
	if `coeffyweight'==1 {
		drop if coeffy == 0 | coeffy == .
	}
	
	foreach matchvar in `matchvars' {
		drop if `matchvar' == .
	}
	
	gen mobility = mob_`measure'
	keep if mobility != .
	
	gen treatment = sample_acc
	gen post = (year > 2005)
	gen control = `control'

	keep if treatment == 1 | control == 1

	***  2002 matched to 2008
	***  2003 matched to 2009
	***  2004 matched to 2010
	gen matchyear = year-6*(post==1)
	
	***  This is for any individual isco3d control group
	gen iscontrolpre = control*(1-post)
	gen istreatedpre = treatment*(1-post)
	gen iscontrolpost = control*post
	gen istreatedpost = treatment*post
	
	***  Identify number of obs in each cell
	sort country matchyear `matchvars'
	by country matchyear `matchvars': egen numcontrolpre = sum(iscontrolpre)
	by country matchyear `matchvars': egen numtreatedpre = sum(istreatedpre)
	by country matchyear `matchvars': egen numcontrolpost = sum(iscontrolpost)
	by country matchyear `matchvars': egen numtreatedpost = sum(istreatedpost)
	
	gen matched = 0
	gen matchweight = 0
	
	***  Identify observations in "common-support" (at least 1 obs in pre-treat, post-treat, pre-control and post-control)
	replace matched = 1 if numcontrolpre > 0 & numtreatedpre > 0 & numtreatedpost > 0 & numcontrolpost > 0
	
	***  Matched accountants in pre-period get a weight of 1.  Everyone else gets the required "balancing" weight.
	replace matchweight = 1 if treatment == 1 & matched == 1 & post == 0
	replace matchweight = numtreatedpre/numcontrolpre if control == 1 & matched == 1 & post == 0
	replace matchweight = numtreatedpre/numcontrolpost if control == 1 & matched == 1 & post == 1
	replace matchweight = numtreatedpre/numtreatedpost if treatment == 1 & matched == 1 & post == 1
		
	***  Check your work: only difference should be number of observations
	***  Weights of all should be equal to number of observations for pre-period accountants
	noisily summarize `matchvars' [aweight=matchweight] if treatment == 1 & post == 0
	noisily summarize `matchvars' [aweight=matchweight] if treatment == 1 & post == 1
	noisily summarize `matchvars' [aweight=matchweight] if control == 1 & post == 0
	noisily summarize `matchvars' [aweight=matchweight] if control == 1 & post == 1

	***  Keep only matched observations
	keep if matched == 1
	
	noisily save "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", replace

}
}
}
}

***  Doublematched country-matchyear-matchvariable-level analysis (NATBIRTH)
qui foreach control in `controlgroups' {
foreach measure in `mobilitymeasures' {
foreach onlyrecent in `onlyrecentyesno' {
foreach coeffyweight in `coeffyweightsyesno' {

	***  Aggregate coeffy-weights by match bin
	use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
	statsby meancoeffy=r(mean) sample=r(N), by(`matchvars' country matchyear) nodots clear: summarize coeffy [aweight=matchweight]
	gen coeffyweight=meancoeffy*sample
	keep `matchvars' country matchyear coeffyweight
	save "coeffyweights.dta", replace	
	
	use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
		
	***  Aggregate mobility by match bin
	statsby meanmobility = r(mean) sample=r(N), by(`matchvars' country matchyear treatment post) nodots clear: summarize mobility
	
	sort `matchvars' country matchyear treatment
	
	***  Calculate sample of smallest bin without each double-matched quadruplet
	***  This will be the statistical weighting on the quadruplets diff-in-diff
	by `matchvars' country matchyear: egen minsample = min(sample)
	by `matchvars' country matchyear: egen bincount = count(sample)
	drop if bincount != 4
	drop if minsample == 0
	merge m:1 `matchvars' country matchyear using "coeffyweights.dta", nogenerate

	***  Construct binning variables for clustering and FE's----we use 'country_job' for clusters and 'bin' for FE's
	egen bin = group(country matchyear post `matchvars')
	egen country_job = group(country treatment)

	noisily save "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", replace

}
}
}
}

*  Difference-in-differences analysis: full sample, NATBIRTH, LFS weighted (no)

local control sample_pro
local measure natbirth
local onlyrecent 0
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

*** Convert mobility to percent
replace meanmobility = 100*meanmobility
rename meanmobility meanmobility`mob'

*** Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: full sample, NATBIRTH, LFS weighted (yes)

local control sample_pro
local measure natbirth
local onlyrecent 0
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

*** Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

*** Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]

*  Difference-in-differences analysis: full sample, NATBIRTH_CHG, LFS weighted (no)

local control sample_pro
local measure natbirth_chg
local onlyrecent 0
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: full sample, NATBIRTH_CHG, LFS weighted (yes)

local control sample_pro
local measure natbirth_chg
local onlyrecent 0
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]


*  Difference-in-differences analysis: only recent job changers, NATBIRTH, LFS weighted (no)

local control sample_pro
local measure natbirth
local onlyrecent 1
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: only recent job changers, NATBIRTH, LFS weighted (yes)

local control sample_pro
local measure natbirth
local onlyrecent 1
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility = 100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]


log close
*********************************************************************************************************************************************************
*
*  The Effect of Regulatory Harmonization on Cross-Border Labor Migration: Evidence from the Accounting Profession
*
*  Matthew J. Bloomfield, Ulf Bruggemann, Hans B. Christensen and Christian Leuz
*
*  This do-file shows the code for the main empirical analysis presented in Table 3 of the paper. 
*  The analysis is based on the EU Labour Force Survey (LFS) core data (version: December 2012).
*  We use the annual files for 29 European countries for years 2002 to 2004 and 2008 to 2010, respectively. 
*
*********************************************************************************************************************************************************

*********************************************************************************************************************************************************
*  I. Data preparation 
*********************************************************************************************************************************************************
**************************************************************************************************************
*  Step 1: Read and clean key LFS items 
**************************************************************************************************************

clear
gen country = ""
save BBCL_Data_raw, replace

local varlist at be bg ch cy cz de dk ee es fi fr gr hu ie is it lt lu lv nl no pl pt ro se si sk uk
qui foreach country of local varlist {

	qui foreach year in 2002 2003 2004 2008 2009 2010 {

		use EU_LFS_yr_`country'`year', clear
		
		*  Clean job code item
		
		tostring isco3d, replace
		replace isco3d = "" if isco3d == "."
		replace isco3d = "0" if isco3d == "0 0" | isco3d == "010"
		destring isco3d, replace
		
		*  Clean items related to mobility
		
		tostring countryb national yearesid countr1y, replace
		
		gen countryb_own = (countryb == "OWN COUNTRY" | countryb == "0" | substr(countryb,1,3) == "000")
		gen countryb_na = (countryb == "NO ANSWER") 
		
		gen national_own = (national == "OWN COUNTRY" | national == "0" | substr(national,1,3) == "000")
		gen national_na = (national == "NO ANSWER")
		
		gen source_eu15 = ((countryb == "001-EU15" | countryb == "111") & (national == "001-EU15" | national == "111"))
		
		replace yearesid = "NA" if yearesid == "." | yearesid == ""
		replace yearesid = substr(yearesid,2,length(yearesid)-1) if substr(yearesid,1,1) == "0" & yearesid != "0"

		gen countr1y_own = (countr1y == country)
		gen countr1y_na = (countr1y == "NO ANSWER" | countr1y == "." | countr1y == "" | countr1y == "99" | real(countr1y) <= 14)
		
		*  Focus on key LFS items
		
		keep country year isco3d countryb_* national_* source_eu15 yearesid countr1y_* sex age marstat hhlink qhhnum hatlevel hatyear sizefirm startime coeffy
		order country year isco3d countryb_* national_* source_eu15 yearesid countr1y_* sex age marstat hhlink qhhnum hatlevel hatyear sizefirm startime coeffy
		
		append using BBCL_Data_raw
		
		compress

		save BBCL_Data_raw, replace

	}

}

**************************************************************************************************************
*  Step 2: Impose sample restrictions and compute key variables
**************************************************************************************************************

use BBCL_Data_raw, clear

*  Compute mobility metrics

gen mob_natbirth = (countryb_own == 0 & yearesid != "0" & national_own == 0)
replace mob_natbirth = . if (countryb_na == 1 & yearesid == "NA") | national_na == 1

gen mob_natbirth_eu15 = mob_natbirth
replace mob_natbirth_eu15 = 0 if source_eu15 == 0 & mob_natbirth == 1

gen startime_adj = startime + 6
gen startime_yrs = floor(startime_adj/12)
gen startyear = year - startime_yrs
gen recent = (startyear >= 1999 & year < 2005) | (startyear >= 2005 & year > 2005)
replace recent = . if startyear == .
gen mob_natbirth_chg = (mob_natbirth == 1 & recent == 1)
replace mob_natbirth_chg = . if startyear == . | mob_natbirth==.

gen mob_yearesid = 0
replace mob_yearesid = 1 if ((year == 2004 | year == 2010) & (yearesid == "1" | yearesid == "2" | yearesid == "3" | yearesid == "4" | yearesid == "5"))
replace mob_yearesid = 1 if ((year == 2003 | year == 2009) & (yearesid == "1" | yearesid == "2" | yearesid == "3" | yearesid == "4"))
replace mob_yearesid = 1 if ((year == 2002 | year == 2008) & (yearesid == "1" | yearesid == "2" | yearesid == "3"))
replace mob_yearesid = . if yearesid == "NA" | (year >= 2005 & year <= 2007)

gen mob_countr1y = (countr1y_own != 1)
replace mob_countr1y = . if countr1y_na == 1

*  Compute controls

***  Female yes/no
gen female = (sex == 2)

***  Has kids yes/no
gen help = (hhlink == 3) if age < 15
bysort country year qhhnum: egen hhlink3 = sum(help)
bysort country year: egen hhlink3_max = max(hhlink3)
replace hhlink3 = . if hhlink3_max == 0
rename hhlink3 hhkids

gen haskids = (hhkids >= 1)
replace haskids = -1 if hhkids == .
replace haskids = -1 if country == "IE"  
/* haskids set to missing for Ireland (see footnote 15 in the paper) */

***  Single yes/no
gen single = (marstat == 1)
replace single = . if marstat ==.

***  Higher education yes/no
gen education_pre = floor(hatlevel/10)
gen education = (education_pre == 5 | education_pre == 6)
replace education = . if education_pre < 3 | education_pre == .

*  Sample restrictions

***  Age restriction
keep if age >= 20 & age <= 59

***  Drop countries that do not provide ISCO3D information at three-digit level (see footnote 12 in the paper)
drop if country == "BG" | country == "PL" | country == "SI"

***  Drop professions subject to confounding regulatory treatment
drop if isco3d == 214 | isco3d == 222 | isco3d == 223 

*  Define samples

gen sample_acc = (isco3d == 241)
gen sample_law = (isco3d == 242)
gen sample_pro = (isco3d >= 200 & isco3d < 300 & isco3d != 241)
gen sample_biz = (isco3d == 121 | isco3d == 122 | isco3d == 123 | isco3d == 131 | isco3d == 341 | isco3d == 342)
keep if sample_acc == 1 | sample_law == 1 | sample_pro == 1 | sample_biz == 1

keep country year sample_* mob_* recent female age haskids single education sizefirm coeffy

compress

save BBCL_Data_clean, replace

*********************************************************************************************************************************************************
*  II. Data analysis
*********************************************************************************************************************************************************

log using "BBCL_LM_Code.log", replace

**************************************************************************************************************
*  Table 3, Panel A and B: Baseline regressions without/with domestic job mobility control
**************************************************************************************************************

use BBCL_Data_clean, clear

*  Prepare regressions 

***  Determine regression samples
gen sample_1 = (sample_acc == 1 | sample_law == 1)
gen sample_2 = (sample_acc == 1 | sample_pro == 1)
gen sample_3 = (sample_acc == 1 | sample_biz == 1)

***  Require mob_natbirth and mob_natbirth_chg to be non-missing
keep if mob_natbirth != . & mob_natbirth_chg != .

***  Compute test variables
gen treatment = sample_acc
gen post = (year > 2005)
gen treatment_post = treatment*post

***  Compute domestic job mobility control
qui forvalues i = 1/3 {

gen dom_obs_unwght = 1 if mob_natbirth == 0 & sample_`i' == 1
gen dom_recent_unwght = 1 if mob_natbirth == 0 & recent == 1 & sample_`i' == 1
gen dom_obs_wght = coeffy if mob_natbirth == 0 & sample_`i' == 1
gen dom_recent_wght = coeffy if mob_natbirth == 0 & recent == 1 & sample_`i' == 1

bysort country year treatment: egen help1 = sum(dom_obs_unwght)
bysort country year treatment: egen help2 = sum(dom_recent_unwght)
gen dom_mob_unwght_`i' = (help2/help1)*100

bysort country year treatment: egen help3 = sum(dom_obs_wght)
bysort country year treatment: egen help4 = sum(dom_recent_wght)
gen dom_mob_wght_`i' = (help4/help3)*100

drop dom_obs* dom_recent_* help*

}

***  Prepare fixed effects
egen bin = group(female age single haskids education)
egen country_job = group(country treatment)
egen country_year = group(country year)

*  Regressions without domestic job mobility control (Panel A)

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	reghdfe mob_natbirth treatment_post [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	reghdfe mob_natbirth treatment_post, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	reghdfe mob_natbirth_chg treatment_post [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	reghdfe mob_natbirth_chg treatment_post, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

*  Regressions with domestic job mobility control (Panel B)

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	rename dom_mob_wght_`i' dom_mob_wght
	reghdfe mob_natbirth treatment_post dom_mob_wght [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve	
	keep if sample_`i' == 1 
	rename dom_mob_unwght_`i' dom_mob_unwght
	reghdfe mob_natbirth treatment_post dom_mob_unwght, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	rename dom_mob_wght_`i' dom_mob_wght
	reghdfe mob_natbirth_chg treatment_post dom_mob_wght [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve	
	keep if sample_`i' == 1 
	rename dom_mob_unwght_`i' dom_mob_unwght
	reghdfe mob_natbirth_chg treatment_post dom_mob_unwght, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}


**************************************************************************************************************
*  Table 3, Panel C: Double matched diff-in-diff analysis
**************************************************************************************************************

*  Double matching

local matchvars single haskids age education female
local controlgroups sample_law sample_pro sample_biz
local mobilitymeasures natbirth natbirth_chg
local onlyrecentyesno 0 1
local coeffyweightsyesno 0 1

qui foreach control in `controlgroups' {
foreach measure in `mobilitymeasures' {
foreach onlyrecent in `onlyrecentyesno' {
foreach coeffyweight in `coeffyweightsyesno' {

	use BBCL_Data_clean, clear
	
	***  Require mob_natbirth and mob_natbirth_chg to be non-missing
	keep if mob_natbirth != . & mob_natbirth_chg != .

	if `onlyrecent'==1 {
		keep if recent == 1
	}
	
	if `coeffyweight'==1 {
		drop if coeffy == 0 | coeffy == .
	}
	
	foreach matchvar in `matchvars' {
		drop if `matchvar' == .
	}
	
	gen mobility = mob_`measure'
	keep if mobility != .
	
	gen treatment = sample_acc
	gen post = (year > 2005)
	gen control = `control'

	keep if treatment == 1 | control == 1

	***  2002 matched to 2008
	***  2003 matched to 2009
	***  2004 matched to 2010
	gen matchyear = year-6*(post==1)
	
	***  This is for any individual isco3d control group
	gen iscontrolpre = control*(1-post)
	gen istreatedpre = treatment*(1-post)
	gen iscontrolpost = control*post
	gen istreatedpost = treatment*post
	
	***  Identify number of obs in each cell
	sort country matchyear `matchvars'
	by country matchyear `matchvars': egen numcontrolpre = sum(iscontrolpre)
	by country matchyear `matchvars': egen numtreatedpre = sum(istreatedpre)
	by country matchyear `matchvars': egen numcontrolpost = sum(iscontrolpost)
	by country matchyear `matchvars': egen numtreatedpost = sum(istreatedpost)
	
	gen matched = 0
	gen matchweight = 0
	
	***  Identify observations in "common-support" (at least 1 obs in pre-treat, post-treat, pre-control and post-control)
	replace matched = 1 if numcontrolpre > 0 & numtreatedpre > 0 & numtreatedpost > 0 & numcontrolpost > 0
	
	***  Matched accountants in pre-period get a weight of 1.  Everyone else gets the required "balancing" weight.
	replace matchweight = 1 if treatment == 1 & matched == 1 & post == 0
	replace matchweight = numtreatedpre/numcontrolpre if control == 1 & matched == 1 & post == 0
	replace matchweight = numtreatedpre/numcontrolpost if control == 1 & matched == 1 & post == 1
	replace matchweight = numtreatedpre/numtreatedpost if treatment == 1 & matched == 1 & post == 1
		
	***  Check your work: only difference should be number of observations
	***  Weights of all should be equal to number of observations for pre-period accountants
	noisily summarize `matchvars' [aweight=matchweight] if treatment == 1 & post == 0
	noisily summarize `matchvars' [aweight=matchweight] if treatment == 1 & post == 1
	noisily summarize `matchvars' [aweight=matchweight] if control == 1 & post == 0
	noisily summarize `matchvars' [aweight=matchweight] if control == 1 & post == 1

	***  Keep only matched observations
	keep if matched == 1
	
	noisily save "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", replace

}
}
}
}

***  Doublematched country-matchyear-matchvariable-level analysis (NATBIRTH)
qui foreach control in `controlgroups' {
foreach measure in `mobilitymeasures' {
foreach onlyrecent in `onlyrecentyesno' {
foreach coeffyweight in `coeffyweightsyesno' {

	***  Aggregate coeffy-weights by match bin
	use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
	statsby meancoeffy=r(mean) sample=r(N), by(`matchvars' country matchyear) nodots clear: summarize coeffy [aweight=matchweight]
	gen coeffyweight=meancoeffy*sample
	keep `matchvars' country matchyear coeffyweight
	save "coeffyweights.dta", replace	
	
	use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
		
	***  Aggregate mobility by match bin
	statsby meanmobility = r(mean) sample=r(N), by(`matchvars' country matchyear treatment post) nodots clear: summarize mobility
	
	sort `matchvars' country matchyear treatment
	
	***  Calculate sample of smallest bin without each double-matched quadruplet
	***  This will be the statistical weighting on the quadruplets diff-in-diff
	by `matchvars' country matchyear: egen minsample = min(sample)
	by `matchvars' country matchyear: egen bincount = count(sample)
	drop if bincount != 4
	drop if minsample == 0
	merge m:1 `matchvars' country matchyear using "coeffyweights.dta", nogenerate

	***  Construct binning variables for clustering and FE's----we use 'country_job' for clusters and 'bin' for FE's
	egen bin = group(country matchyear post `matchvars')
	egen country_job = group(country treatment)

	noisily save "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", replace

}
}
}
}

*  Difference-in-differences analysis: full sample, NATBIRTH, LFS weighted (no)

local control sample_pro
local measure natbirth
local onlyrecent 0
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

*** Convert mobility to percent
replace meanmobility = 100*meanmobility
rename meanmobility meanmobility`mob'

*** Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: full sample, NATBIRTH, LFS weighted (yes)

local control sample_pro
local measure natbirth
local onlyrecent 0
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

*** Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

*** Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]

*  Difference-in-differences analysis: full sample, NATBIRTH_CHG, LFS weighted (no)

local control sample_pro
local measure natbirth_chg
local onlyrecent 0
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: full sample, NATBIRTH_CHG, LFS weighted (yes)

local control sample_pro
local measure natbirth_chg
local onlyrecent 0
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]


*  Difference-in-differences analysis: only recent job changers, NATBIRTH, LFS weighted (no)

local control sample_pro
local measure natbirth
local onlyrecent 1
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: only recent job changers, NATBIRTH, LFS weighted (yes)

local control sample_pro
local measure natbirth
local onlyrecent 1
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility = 100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]


log close
*********************************************************************************************************************************************************
*
*  The Effect of Regulatory Harmonization on Cross-Border Labor Migration: Evidence from the Accounting Profession
*
*  Matthew J. Bloomfield, Ulf Bruggemann, Hans B. Christensen and Christian Leuz
*
*  This do-file shows the code for the main empirical analysis presented in Table 3 of the paper. 
*  The analysis is based on the EU Labour Force Survey (LFS) core data (version: December 2012).
*  We use the annual files for 29 European countries for years 2002 to 2004 and 2008 to 2010, respectively. 
*
*********************************************************************************************************************************************************

*********************************************************************************************************************************************************
*  I. Data preparation 
*********************************************************************************************************************************************************
**************************************************************************************************************
*  Step 1: Read and clean key LFS items 
**************************************************************************************************************

clear
gen country = ""
save BBCL_Data_raw, replace

local varlist at be bg ch cy cz de dk ee es fi fr gr hu ie is it lt lu lv nl no pl pt ro se si sk uk
qui foreach country of local varlist {

	qui foreach year in 2002 2003 2004 2008 2009 2010 {

		use EU_LFS_yr_`country'`year', clear
		
		*  Clean job code item
		
		tostring isco3d, replace
		replace isco3d = "" if isco3d == "."
		replace isco3d = "0" if isco3d == "0 0" | isco3d == "010"
		destring isco3d, replace
		
		*  Clean items related to mobility
		
		tostring countryb national yearesid countr1y, replace
		
		gen countryb_own = (countryb == "OWN COUNTRY" | countryb == "0" | substr(countryb,1,3) == "000")
		gen countryb_na = (countryb == "NO ANSWER") 
		
		gen national_own = (national == "OWN COUNTRY" | national == "0" | substr(national,1,3) == "000")
		gen national_na = (national == "NO ANSWER")
		
		gen source_eu15 = ((countryb == "001-EU15" | countryb == "111") & (national == "001-EU15" | national == "111"))
		
		replace yearesid = "NA" if yearesid == "." | yearesid == ""
		replace yearesid = substr(yearesid,2,length(yearesid)-1) if substr(yearesid,1,1) == "0" & yearesid != "0"

		gen countr1y_own = (countr1y == country)
		gen countr1y_na = (countr1y == "NO ANSWER" | countr1y == "." | countr1y == "" | countr1y == "99" | real(countr1y) <= 14)
		
		*  Focus on key LFS items
		
		keep country year isco3d countryb_* national_* source_eu15 yearesid countr1y_* sex age marstat hhlink qhhnum hatlevel hatyear sizefirm startime coeffy
		order country year isco3d countryb_* national_* source_eu15 yearesid countr1y_* sex age marstat hhlink qhhnum hatlevel hatyear sizefirm startime coeffy
		
		append using BBCL_Data_raw
		
		compress

		save BBCL_Data_raw, replace

	}

}

**************************************************************************************************************
*  Step 2: Impose sample restrictions and compute key variables
**************************************************************************************************************

use BBCL_Data_raw, clear

*  Compute mobility metrics

gen mob_natbirth = (countryb_own == 0 & yearesid != "0" & national_own == 0)
replace mob_natbirth = . if (countryb_na == 1 & yearesid == "NA") | national_na == 1

gen mob_natbirth_eu15 = mob_natbirth
replace mob_natbirth_eu15 = 0 if source_eu15 == 0 & mob_natbirth == 1

gen startime_adj = startime + 6
gen startime_yrs = floor(startime_adj/12)
gen startyear = year - startime_yrs
gen recent = (startyear >= 1999 & year < 2005) | (startyear >= 2005 & year > 2005)
replace recent = . if startyear == .
gen mob_natbirth_chg = (mob_natbirth == 1 & recent == 1)
replace mob_natbirth_chg = . if startyear == . | mob_natbirth==.

gen mob_yearesid = 0
replace mob_yearesid = 1 if ((year == 2004 | year == 2010) & (yearesid == "1" | yearesid == "2" | yearesid == "3" | yearesid == "4" | yearesid == "5"))
replace mob_yearesid = 1 if ((year == 2003 | year == 2009) & (yearesid == "1" | yearesid == "2" | yearesid == "3" | yearesid == "4"))
replace mob_yearesid = 1 if ((year == 2002 | year == 2008) & (yearesid == "1" | yearesid == "2" | yearesid == "3"))
replace mob_yearesid = . if yearesid == "NA" | (year >= 2005 & year <= 2007)

gen mob_countr1y = (countr1y_own != 1)
replace mob_countr1y = . if countr1y_na == 1

*  Compute controls

***  Female yes/no
gen female = (sex == 2)

***  Has kids yes/no
gen help = (hhlink == 3) if age < 15
bysort country year qhhnum: egen hhlink3 = sum(help)
bysort country year: egen hhlink3_max = max(hhlink3)
replace hhlink3 = . if hhlink3_max == 0
rename hhlink3 hhkids

gen haskids = (hhkids >= 1)
replace haskids = -1 if hhkids == .
replace haskids = -1 if country == "IE"  
/* haskids set to missing for Ireland (see footnote 15 in the paper) */

***  Single yes/no
gen single = (marstat == 1)
replace single = . if marstat ==.

***  Higher education yes/no
gen education_pre = floor(hatlevel/10)
gen education = (education_pre == 5 | education_pre == 6)
replace education = . if education_pre < 3 | education_pre == .

*  Sample restrictions

***  Age restriction
keep if age >= 20 & age <= 59

***  Drop countries that do not provide ISCO3D information at three-digit level (see footnote 12 in the paper)
drop if country == "BG" | country == "PL" | country == "SI"

***  Drop professions subject to confounding regulatory treatment
drop if isco3d == 214 | isco3d == 222 | isco3d == 223 

*  Define samples

gen sample_acc = (isco3d == 241)
gen sample_law = (isco3d == 242)
gen sample_pro = (isco3d >= 200 & isco3d < 300 & isco3d != 241)
gen sample_biz = (isco3d == 121 | isco3d == 122 | isco3d == 123 | isco3d == 131 | isco3d == 341 | isco3d == 342)
keep if sample_acc == 1 | sample_law == 1 | sample_pro == 1 | sample_biz == 1

keep country year sample_* mob_* recent female age haskids single education sizefirm coeffy

compress

save BBCL_Data_clean, replace

*********************************************************************************************************************************************************
*  II. Data analysis
*********************************************************************************************************************************************************

log using "BBCL_LM_Code.log", replace

**************************************************************************************************************
*  Table 3, Panel A and B: Baseline regressions without/with domestic job mobility control
**************************************************************************************************************

use BBCL_Data_clean, clear

*  Prepare regressions 

***  Determine regression samples
gen sample_1 = (sample_acc == 1 | sample_law == 1)
gen sample_2 = (sample_acc == 1 | sample_pro == 1)
gen sample_3 = (sample_acc == 1 | sample_biz == 1)

***  Require mob_natbirth and mob_natbirth_chg to be non-missing
keep if mob_natbirth != . & mob_natbirth_chg != .

***  Compute test variables
gen treatment = sample_acc
gen post = (year > 2005)
gen treatment_post = treatment*post

***  Compute domestic job mobility control
qui forvalues i = 1/3 {

gen dom_obs_unwght = 1 if mob_natbirth == 0 & sample_`i' == 1
gen dom_recent_unwght = 1 if mob_natbirth == 0 & recent == 1 & sample_`i' == 1
gen dom_obs_wght = coeffy if mob_natbirth == 0 & sample_`i' == 1
gen dom_recent_wght = coeffy if mob_natbirth == 0 & recent == 1 & sample_`i' == 1

bysort country year treatment: egen help1 = sum(dom_obs_unwght)
bysort country year treatment: egen help2 = sum(dom_recent_unwght)
gen dom_mob_unwght_`i' = (help2/help1)*100

bysort country year treatment: egen help3 = sum(dom_obs_wght)
bysort country year treatment: egen help4 = sum(dom_recent_wght)
gen dom_mob_wght_`i' = (help4/help3)*100

drop dom_obs* dom_recent_* help*

}

***  Prepare fixed effects
egen bin = group(female age single haskids education)
egen country_job = group(country treatment)
egen country_year = group(country year)

*  Regressions without domestic job mobility control (Panel A)

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	reghdfe mob_natbirth treatment_post [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	reghdfe mob_natbirth treatment_post, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	reghdfe mob_natbirth_chg treatment_post [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	reghdfe mob_natbirth_chg treatment_post, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

*  Regressions with domestic job mobility control (Panel B)

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	rename dom_mob_wght_`i' dom_mob_wght
	reghdfe mob_natbirth treatment_post dom_mob_wght [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve	
	keep if sample_`i' == 1 
	rename dom_mob_unwght_`i' dom_mob_unwght
	reghdfe mob_natbirth treatment_post dom_mob_unwght, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve
	keep if sample_`i' == 1 
	keep if coeffy != . & coeffy > 0
	rename dom_mob_wght_`i' dom_mob_wght
	reghdfe mob_natbirth_chg treatment_post dom_mob_wght [aweight = coeffy], absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}

forvalues i = 1/3 {
	preserve	
	keep if sample_`i' == 1 
	rename dom_mob_unwght_`i' dom_mob_unwght
	reghdfe mob_natbirth_chg treatment_post dom_mob_unwght, absorb(bin country_job country_year) cluster(country_job) keepsingleton
	restore
}


**************************************************************************************************************
*  Table 3, Panel C: Double matched diff-in-diff analysis
**************************************************************************************************************

*  Double matching

local matchvars single haskids age education female
local controlgroups sample_law sample_pro sample_biz
local mobilitymeasures natbirth natbirth_chg
local onlyrecentyesno 0 1
local coeffyweightsyesno 0 1

qui foreach control in `controlgroups' {
foreach measure in `mobilitymeasures' {
foreach onlyrecent in `onlyrecentyesno' {
foreach coeffyweight in `coeffyweightsyesno' {

	use BBCL_Data_clean, clear
	
	***  Require mob_natbirth and mob_natbirth_chg to be non-missing
	keep if mob_natbirth != . & mob_natbirth_chg != .

	if `onlyrecent'==1 {
		keep if recent == 1
	}
	
	if `coeffyweight'==1 {
		drop if coeffy == 0 | coeffy == .
	}
	
	foreach matchvar in `matchvars' {
		drop if `matchvar' == .
	}
	
	gen mobility = mob_`measure'
	keep if mobility != .
	
	gen treatment = sample_acc
	gen post = (year > 2005)
	gen control = `control'

	keep if treatment == 1 | control == 1

	***  2002 matched to 2008
	***  2003 matched to 2009
	***  2004 matched to 2010
	gen matchyear = year-6*(post==1)
	
	***  This is for any individual isco3d control group
	gen iscontrolpre = control*(1-post)
	gen istreatedpre = treatment*(1-post)
	gen iscontrolpost = control*post
	gen istreatedpost = treatment*post
	
	***  Identify number of obs in each cell
	sort country matchyear `matchvars'
	by country matchyear `matchvars': egen numcontrolpre = sum(iscontrolpre)
	by country matchyear `matchvars': egen numtreatedpre = sum(istreatedpre)
	by country matchyear `matchvars': egen numcontrolpost = sum(iscontrolpost)
	by country matchyear `matchvars': egen numtreatedpost = sum(istreatedpost)
	
	gen matched = 0
	gen matchweight = 0
	
	***  Identify observations in "common-support" (at least 1 obs in pre-treat, post-treat, pre-control and post-control)
	replace matched = 1 if numcontrolpre > 0 & numtreatedpre > 0 & numtreatedpost > 0 & numcontrolpost > 0
	
	***  Matched accountants in pre-period get a weight of 1.  Everyone else gets the required "balancing" weight.
	replace matchweight = 1 if treatment == 1 & matched == 1 & post == 0
	replace matchweight = numtreatedpre/numcontrolpre if control == 1 & matched == 1 & post == 0
	replace matchweight = numtreatedpre/numcontrolpost if control == 1 & matched == 1 & post == 1
	replace matchweight = numtreatedpre/numtreatedpost if treatment == 1 & matched == 1 & post == 1
		
	***  Check your work: only difference should be number of observations
	***  Weights of all should be equal to number of observations for pre-period accountants
	noisily summarize `matchvars' [aweight=matchweight] if treatment == 1 & post == 0
	noisily summarize `matchvars' [aweight=matchweight] if treatment == 1 & post == 1
	noisily summarize `matchvars' [aweight=matchweight] if control == 1 & post == 0
	noisily summarize `matchvars' [aweight=matchweight] if control == 1 & post == 1

	***  Keep only matched observations
	keep if matched == 1
	
	noisily save "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", replace

}
}
}
}

***  Doublematched country-matchyear-matchvariable-level analysis (NATBIRTH)
qui foreach control in `controlgroups' {
foreach measure in `mobilitymeasures' {
foreach onlyrecent in `onlyrecentyesno' {
foreach coeffyweight in `coeffyweightsyesno' {

	***  Aggregate coeffy-weights by match bin
	use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
	statsby meancoeffy=r(mean) sample=r(N), by(`matchvars' country matchyear) nodots clear: summarize coeffy [aweight=matchweight]
	gen coeffyweight=meancoeffy*sample
	keep `matchvars' country matchyear coeffyweight
	save "coeffyweights.dta", replace	
	
	use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
		
	***  Aggregate mobility by match bin
	statsby meanmobility = r(mean) sample=r(N), by(`matchvars' country matchyear treatment post) nodots clear: summarize mobility
	
	sort `matchvars' country matchyear treatment
	
	***  Calculate sample of smallest bin without each double-matched quadruplet
	***  This will be the statistical weighting on the quadruplets diff-in-diff
	by `matchvars' country matchyear: egen minsample = min(sample)
	by `matchvars' country matchyear: egen bincount = count(sample)
	drop if bincount != 4
	drop if minsample == 0
	merge m:1 `matchvars' country matchyear using "coeffyweights.dta", nogenerate

	***  Construct binning variables for clustering and FE's----we use 'country_job' for clusters and 'bin' for FE's
	egen bin = group(country matchyear post `matchvars')
	egen country_job = group(country treatment)

	noisily save "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", replace

}
}
}
}

*  Difference-in-differences analysis: full sample, NATBIRTH, LFS weighted (no)

local control sample_pro
local measure natbirth
local onlyrecent 0
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

*** Convert mobility to percent
replace meanmobility = 100*meanmobility
rename meanmobility meanmobility`mob'

*** Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: full sample, NATBIRTH, LFS weighted (yes)

local control sample_pro
local measure natbirth
local onlyrecent 0
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

*** Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

*** Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]

*  Difference-in-differences analysis: full sample, NATBIRTH_CHG, LFS weighted (no)

local control sample_pro
local measure natbirth_chg
local onlyrecent 0
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: full sample, NATBIRTH_CHG, LFS weighted (yes)

local control sample_pro
local measure natbirth_chg
local onlyrecent 0
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]


*  Difference-in-differences analysis: only recent job changers, NATBIRTH, LFS weighted (no)

local control sample_pro
local measure natbirth
local onlyrecent 1
local coeffyweight 0

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility=100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample]


*  Difference-in-differences analysis: only recent job changers, NATBIRTH, LFS weighted (yes)

local control sample_pro
local measure natbirth
local onlyrecent 1
local coeffyweight 1

use "doublematchedsample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
tabulate treatment
use "readyforregssample_`control'_`measure'_onlyrecent`onlyrecent'_coeffyweight`coeffyweight'.dta", clear
gen treatment_post = treatment*post

***  Convert mobility to percent
replace meanmobility = 100*meanmobility
rename meanmobility meanmobility`mob'

***  Main effect of post is subsumed by FEs
areg meanmobility treatment_post treatment [aweight=minsample*coeffyweight], absorb(bin) cluster(country_job)
sort treatment post
by treatment post: summarize meanmobility [aweight=minsample*coeffyweight]


log close

