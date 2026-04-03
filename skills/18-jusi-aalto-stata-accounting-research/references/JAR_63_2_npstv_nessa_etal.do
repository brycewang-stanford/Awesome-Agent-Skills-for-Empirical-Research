/*STEP 1: Use Orbis website to select entities that are global ultimate owners of U.S. MNEs:
We start with all US MNEs in Orbis (listed and unlisted) with at least one 
foreign affiliate (located anywhere (excluding unknown countries) not ultimately 
owned but at least 51% owned; May have other shareholder in the foreign country; 
Def. of the UO: min. path of 50.01%, known or unknown shareholder). 
There are 4,719 U.S. MNEs in total. We then applied additional filters, 
(1) Listed companies, (2) Corporate Utimate Owners located in the U.S., 
(3) Parent companies not already included (i.e. not duplicated, (4) Non-missing 
CIK, and (5) Parent companies are also global ultimate owners (GUO) as per Orbis.
These steps resulted in a total of 2,637 U.S. MNEs*/

/*STEP 2: We then merge this set of firms with Orbis ownership and financial data using 
sas code file "download aff financials from Orbis.sas". Final dataset
"AlldAffiliateFinancials061223.dta" was exported to STATA for cleaning and 
running analyses. The final dataset of affiliates' financials is associated 
with 1,518 U.S. MNEs out of the total 2,637 U.S. MNEs from the initial sample.*/

/*STEP 3: Use Orbis website to download consolidated financials associated with 
the final set of 1,518 U.S. MNEs. Export the data to USMNEs_consolidatedfinancials_061423.dta*/

/*STEP 4: Merge U.S. MNEs' consolidated financial data with affiliates data and perform cleaning*/
use "D:\Dropbox\Co-Authors\CbCR (1)\Data\BvD\AlldAffiliateFinancials061223.dta", replace
merge m:1 BvDIDnumber CLOSDATE_year using "D:\Dropbox\Co-Authors\CbCR (1)\Data\BvD\USMNEs_consolidatedfinancials_061423.dta"
drop if _merge==2
drop _merge

rename CompanynameLatinalphabet guo_name
rename BvDIDnumber uo_bvdid
rename bvdid aff_bvdid
rename CTRYISO aff_ctryiso
rename *, lower
rename conscode aff_conscode
rename filing_type aff_filing_type

*Drop observations with missing financial years
drop if mnefyear==.

*Generate financial year variable for affiliates
gen fyear=year(closdate)
replace fyear= closdate_year if fyear==.
replace fyear=year(closdate)-1 if month(closdate)<6

*Clean duplicates*
**Drop obserations where the number of months is less than 12
keep if nr_months=="12"
**Drop duplicated obserations where ownership information is missing or not available'
duplicates tag aff_bvdid aff_conscode aff_filing_type fyear, gen(dup)
drop if dup>0 &  guodirect=="-" & guototal=="n.a."
drop dup
**Drop remaining duplicated obserations
sort aff_bvdid aff_conscode aff_filing_type closdate
duplicates drop aff_bvdid aff_conscode aff_filing_type fyear, force

*Determining the treated observations

gen post=1 if mnefyear>2015
replace post=0 if mnefyear<2016
sum mnefyear if post==1
sum mnefyear if post==0

*Generate treatment variables
gen dum=.
foreach i of num 2016/2021 {
replace dum=1 if mnefyear==(`i') & mnel1revenue>=850000000 & mnel1revenue!=.
replace dum=0 if mnefyear==(`i') & mnel1revenue<850000000 & mnel1revenue!=.
}
bysort uo_bvdid: egen treat=max(dum)

gen treat500=.
foreach i of num 2008/2021 {
replace treat500=1 if treat==1 & mnefyear==(`i') & mnel1revenue>=850000000 & mnel1revenue<=(850000000+500000000) & mnel1revenue!=.
replace treat500=0 if treat==0 & mnefyear==(`i') & mnel1revenue<850000000 & mnel1revenue>=(850000000-500000000) & mnel1revenue!=.
}

*Income Shifting Tests*
*Merge in STR and GDP data*
rename fyear year
rename aff_ctryiso iso_2
merge m:1 iso_2 year using "D:\Dropbox\Co-Authors\CbCR (1)\Data\Sources\Corporate-Tax-Rates-Data-1980-2019.dta", keepusing(rate)
drop if _merge==2
drop _merge
destring rate, force gen(str)
replace str=str/100

rename iso_2 countrycode2
merge m:1 countrycode2 year using "D:\Dropbox\Co-Authors\CbCR (1)\Data\BvD\gdp_current_usd.dta", keepusing(gdp_current_usd)
drop if _merge==2
drop _merge
gen lngdp=ln(gdp_current_usd)
rename countrycode2 aff_ctryiso

rename year fyear
rename oppl ebit
rename opre rev
rename tfas tangiblefa
rename staf compexp

destring naics2022corecode4digits, replace

*Drop observations if total asset, total fixed asset, tota compensation expense or total revenue is negative
drop if toas<0
drop if fias<0
drop if compexp<0
drop if rev<0

*Calculating the necessary variable for income shifting tests
gen lnplbt=ln(plbt+1) if plbt>=0
gen lnebit=ln(ebit+1) if ebit>=0
gen tangiblefa_zero=tangiblefa
replace tangiblefa_zero=0 if tangiblefa==.
gen lntangiblefa_zero=ln(tangiblefa_zero+1)
gen compexp_zero=compexp
replace compexp_zero=0 if compexp==.
gen lncompexp_zero=ln(compexp_zero+1) if compexp_zero>=0

*Keep only majority owned affiliates (direct or indirect)
gen notmo=1 if sub_totalown==. & sub_directown==. 
replace notmo=1  if sub_totalown<=50 & sub_directown<=50
keep if notmo!=1

*Generate tax incentive variables
*Calculate C based on Total Revenue
gen arev= rev/(1-str) if rev>0
bysort uo_bvdid mnefyear: egen Sumofarev=sum(arev) 
gen Nominator1= str*(Sumofarev- arev)
gen arevtimestax= arev*str if arev>0
bysort uo_bvdid mnefyear: egen Sumofarevtimestax =sum(arevtimestax)
gen Nominator2= Sumofarevtimestax- arevtimestax
gen C= (Nominator1-Nominator2)/(Sumofarev*(1-str))

*Income Shifting 500M bandwidth tests
*Exclude insurance companies
eststo clear
reg lnplbt C lncompexp_zero lntangiblefa_zero lngdp if treat!=. & post!=. & mnefyear<2019 & mnefyear>2010 & treat500!=. &(naics2022corecode4digits<=5240 | naics2022corecode4digits>=5300) 
gen ISsample500_2011_2018=e(sample)

reghdfe lnplbt c.C##i.treat500##i.post lncompexp_zero lntangiblefa_zero lngdp if ISsample500_2011_2018==1, a(mnefyear uo_bvdid) cluster(uo_bvdid)
gen finalISsample500_2011_2018=e(sample)

*Generate weight by year, converge at 1st moment
forvalues v = 2011/2018{
qui ebalance treat500 C lncompexp_zero lntangiblefa_zero lngdp if mnefyear==`v' & finalISsample500_2011_2018==1, generate(eweight`v') tar(1)
}

*Assign weights to all firm years
gen _weightbyr = .
forvalues v = 2011/2018{
replace _weightbyr = eweight`v' if mnefyear== `v' & finalISsample500_2011_2018==1
}
 
*Income Shifting Regression with entropy balancing - as reported in Online Appendix H
reghdfe lnplbt c.C##i.treat500##i.post lncompexp_zero lntangiblefa_zero lngdp if finalISsample500_2011_2018==1 [pweight=_weightbyr], a(mnefyear uo_bvdid) cluster(uo_bvdid)
eststo

*Tests of Assets and Compensation
*Generate weight by year
drop eweight* _weightbyr
forvalues v = 2011/2018{
qui ebalance treat500 lngdp if mnefyear==`v' & finalISsample500_2011_2018==1, generate(eweight`v') tar(2)
}
 
*Assign weights to all firm years
gen _weightbyr = .
forvalues v = 2011/2018{
replace _weightbyr = eweight`v' if mnefyear== `v' & finalISsample500_2011_2018==1
}
 
*Assets and Compensation Regression with entropy balancing - as reported in Online Appendix H
reghdfe lntangiblefa_zero c.C##i.treat500##i.post lngdp if finalISsample500_2011_2018==1 [pweight=_weightbyr], a(mnefyear uo_bvdid) cluster(uo_bvdid)
eststo
reghdfe lncompexp_zero c.C##i.treat500##i.post lngdp if finalISsample500_2011_2018==1 [pweight=_weightbyr], a(mnefyear uo_bvdid) cluster(uo_bvdid)
eststo
esttab using Robustness_Results_BVD_061323.csv, replace t(3) scalars(F r2_o) b(%9.3f) ar2(4) star(* 0.10 ** 0.05 *** 0.01)  nogaps nonumbers

