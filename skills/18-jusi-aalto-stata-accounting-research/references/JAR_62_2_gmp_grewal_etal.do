
****************************************************************************************** 

*** Paper: Payment Practices Transparency and Customer-Supplier Contracting
*** Authors: Jody Grewal, Aditya Mohan, Gerardo Perez Cavazos

* The code below details the steps used to obtain and manipulate the raw data used for the main analyses in the paper.

******************************************************************************************
* 1. Manual Download from S&P

*For each variable below, use a new screen and input the screening criteria Geography In United Kingdom. Select fiscal years 2010 through 2020. Include the additional fields in each screen: EntityID EntityName yearstring Geography CompanyName Ticker CompanyStatus  IndustryClassification Sector IndustryGroup Industry PrimaryIndustry SICCode CompanyType CountryRegionName.
*Once the output is created, download each screen, open in excel, import to stata, and reshape the data to panel format using the command " reshape long var, i(EntityID) j(year, string) "
*merge files by EntityID and year
*variables: IQ_INT_EXP IQ_Debt FTE IQ_Total_Rev IQ_COGS IQ_GEO_SEG_REV_ABS IQ_TOTAL_ASSETS IQ_AR IQ_STDEBT IQ_EBITDA IQ_COMMON_DIV_DECLARED

* 2. Create variables

rename year yearstring
gen  year=.
replace year=2010 if  yearstring=="FY2010"
replace year=2011 if  yearstring=="FY2011"
replace year=2012 if  yearstring=="FY2012"
replace year=2013 if  yearstring=="FY2013"
replace year=2014 if  yearstring=="FY2014"
replace year=2015 if  yearstring=="FY2015"
replace year=2016 if  yearstring=="FY2016"
replace year=2017 if  yearstring=="FY2017"
replace year=2018 if  yearstring=="FY2018"
replace year=2019 if  yearstring=="FY2019"
replace year=2020 if  yearstring=="FY2020"

gen ASSETSforthr=IQ_TOTAL_ASSETS_*1000
gen REVforthr=IQ_TOTAL_REV_*1000

gen thrassets2017=0
replace thrassets2017=1 if ASSETSforthr>18000000 & !missing(ASSETSforthr) & year==2017
gen thrsales2017=0
replace thrsales2017=1 if REVforthr>36000000 & !missing(REVforthr) & year==2017
gen thrempl2017=0
replace thrempl2017=1 if FTE_>250 & !missing(FTE_) & year==2017
gen sum2017=0
replace sum2017=thrassets2017+thrsales2017+thrempl2017
gen exceed2017=0
replace exceed2017=1 if sum2017>=2

gen thrassets2016=0
replace thrassets2016=1 if ASSETSforthr>18000000 & !missing(ASSETSforthr) & year==2016
gen thrsales2016=0
replace thrsales2016=1 if REVforthr>36000000 & !missing(REVforthr) & year==2016
gen thrempl2016=0
replace thrempl2016=1 if FTE_>250 & !missing(FTE_) & year==2016
gen sum2016=0
replace sum2016=thrassets2016+thrsales2016+thrempl2016
gen exceed2016=0
replace exceed2016=1 if sum2016>=2

bysort EntityID: replace exceed2017=exceed2017[_n-1] if exceed2017==0 & exceed2017[_n-1]==1
bysort EntityID: replace exceed2017=exceed2017[_n-1] if exceed2017==0 & exceed2017[_n-1]==1
bysort EntityID: replace exceed2017=exceed2017[_n-1] if exceed2017==0 & exceed2017[_n-1]==1
bysort EntityID: replace exceed2017=exceed2017[_n-1] if exceed2017==0 & exceed2017[_n-1]==1

bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1
bysort EntityID: replace exceed2017=exceed2017[_n+1] if exceed2017==0 & exceed2017[_n+1]==1

bysort EntityID: replace exceed2016=exceed2016[_n-1] if exceed2016==0 & exceed2016[_n-1]==1
bysort EntityID: replace exceed2016=exceed2016[_n-1] if exceed2016==0 & exceed2016[_n-1]==1
bysort EntityID: replace exceed2016=exceed2016[_n-1] if exceed2016==0 & exceed2016[_n-1]==1
bysort EntityID: replace exceed2016=exceed2016[_n-1] if exceed2016==0 & exceed2016[_n-1]==1

bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1
bysort EntityID: replace exceed2016=exceed2016[_n+1] if exceed2016==0 & exceed2016[_n+1]==1

*repeat until all replacements are done

gen treat=0
replace treat=1 if exceed2017==1 & exceed2016==1

gen post=0
replace post=1 if year>2017

gen treat_post=treat*post

gen control=0
replace control=1 if treat==0

gen control_post=control*post

foreach var of varlist  IQ_AR_ IQ_TOTAL_ASSETS_  IQ_Total_Rev_ IQ_Debt_ {
replace `var'="." if `var'=="NA"
}

foreach var of varlist IQ_AR_ IQ_TOTAL_ASSETS_  IQ_Total_Rev_ IQ_Debt_ {
destring `var', replace 
}

foreach var of varlist IQ_AR_ IQ_TOTAL_ASSETS_  IQ_Total_Rev_ IQ_Debt_ {
winsor2 `var', cuts(1 99) suffix(_1_99) label
}

gen ln_AR=ln(1+IQ_AR__1_99)
gen LnAssets_1_99=ln(1+IQ_TOTAL_ASSETS__1_99)
gen LnSales_1_99=ln(1+IQ_TOTAL_REV__1_99)
gen smp_prd=0
replace smp_prd=1 if year>2010 & year <2021

bysort IQ_INDUSTRY_GROUP treat post: egen avgAP=mean(APoverRev_1_99)  

gen avgAPtreatpre=avgAP if treat==1 & post==0
gen avgAPcontrolpre=avgAP if treat==0 & post==0

preserve
duplicates drop IQ_INDUSTRY_GROUP avgAPtreatpre avgAPcontrolpre, force
drop if missing(avgAPtreatpre) & missing(avgAPcontrolpre)
drop if missing(IQ_INDUSTRY_GROUP)
keep IQ_INDUSTRY_GROUP avgAPtreatpre avgAPcontrolpre
bysort IQ_INDUSTRY_GROUP: replace avgAPtreatpre=avgAPtreatpre[_n-1] if missing(avgAPtreatpre) & !missing(avgAPtreatpre[_n-1])
bysort IQ_INDUSTRY_GROUP: replace avgAPtreatpre=avgAPtreatpre[_n+1] if missing(avgAPtreatpre) & !missing(avgAPtreatpre[_n+1])
bysort IQ_INDUSTRY_GROUP: replace avgAPcontrolpre=avgAPcontrolpre[_n-1] if missing(avgAPcontrolpre) & !missing(avgAPcontrolpre[_n-1])
bysort IQ_INDUSTRY_GROUP: replace avgAPcontrolpre=avgAPcontrolpre[_n+1] if missing(avgAPcontrolpre) & !missing(avgAPcontrolpre[_n+1])
duplicates drop IQ_INDUSTRY_GROUP avgAPtreatpre avgAPcontrolpre, force
save "...\IQ_INDUSTRY_GROUP_AP.dta"
restore

drop _merge
merge m:1 IQ_INDUSTRY_GROUP using "...\IQ_INDUSTRY_GROUP_AP.dta"
drop if _merge==2

gen APDiffPre=avgAPtreatpre-avgAPcontrolpre if !missing(avgAPcontrolpre) & !missing(avgAPtreatpre)
gen post_APDiffPre=post*APDiffPre
gen control_APDiffPre=control*APDiffPre
gen post_control_APDiffPre=control_post*APDiffPre

bysort IQ_INDUSTRY: egen indrev=sum(IQ_TOTAL_REV__1_99) if post==0
gen mktsharepct=(IQ_TOTAL_REV_/indrev)*100 if post==0
gen mktsharepctsq=mktsharepct^2 if post==0
bysort IQ_INDUSTRY: egen HHI=sum(mktsharepctsq) if post==0
bysort EntityID: replace HHI=HHI[_n-1] if missing(HHI) & !missing(HHI[_n-1])
bysort EntityID: replace HHI=HHI[_n-1] if missing(HHI) & !missing(HHI[_n-1])
bysort EntityID: replace HHI=HHI[_n+1] if missing(HHI) & !missing(HHI[_n+1])
bysort EntityID: replace HHI=HHI[_n+1] if missing(HHI) & !missing(HHI[_n+1])
bysort EntityID: replace HHI=HHI[_n+1] if missing(HHI) & !missing(HHI[_n+1])
bysort EntityID: replace HHI=HHI[_n+1] if missing(HHI) & !missing(HHI[_n+1])
replace HHI = HHI/10000

use "...\q5874d8b8ee069c40.dta" 
tab HEADQUARTER_COUNTRY
keep if HEADQUARTER_COUNTRY=="GB"
save "...\reprisk identifiers UK only.dta"

clear
use "...\qb72a60cba72fa61f.dta" 
merge m:1 REPRISK_ID using "...\reprisk identifiers UK only.dta"
gen year=year(date)
drop if missing(ISIN)
replace CURRENT_RRI=CURRENT_RRI/100
bysort ISIN year: egen annualRRI=mean(CURRENT_RRI)
duplicates drop ISIN year, force
drop _merge
merge 1:1 ISIN year using "...\Combined Annual AP and AR unique ISIN year.dta"
bysort IQ_INDUSTRY_GROUP: egen IndustryRRI=mean(CURRENT_RRI)
duplicates drop IQ_INDUSTRY_GROUP IndustryRRI, force
save "...\reprisk1.dta" 

use "...\Combined Annual AP and AR.dta", clear
drop _merge
merge m:1 IQ_INDUSTRY_GROUP using "...\reprisk1.dta" 

gen leverage= IQ_DEBT_ / IQ_TOTAL_ASSETS_

replace leverage =0 if leverage <0 & leverage!=.
replace leverage =1 if leverage >1 & leverage!=.

foreach var of varlist IQ_COMMON_DIV_DECLARED_ IQ_EBITDA_ IQ_STDEBT_ IQ_INT_EXP_  {
replace `var'="." if `var'=="NA"
}

foreach var of varlist IQ_STDEBT_ IQ_INT_EXP_ {
destring `var', replace 
}

destring IQ_COMMON_DIV_DECLARED_, gen(IQ_div)
destring IQ_EBITDA_, gen(IQ_ebitda_)

winsor2 IQ_INT_EXP_, cuts(1 99) suffix(_1_99) label
winsor2 IQ_STDEBT_, cuts(1 99) suffix(_1_99) label

gen std = IQ_STDEBT_ / IQ_TOTAL_ASSETS_
replace std =0 if std <0 & std!=.
replace std =.85 if std >.85 & std!=. 
gen ln_debt = ln(1+IQ_DEBT_)
gen ln_assets = ln(1+IQ_TOTAL_ASSETS_)
gen interest_cost = -IQ_INT_EXP__1_99 / IQ_DEBT__1_99
winsor2 interest_cost, cuts(1 99) suffix(_1_99) label
gen cf = IQ_ebitda_ / IQ_TOTAL_ASSETS_
winsor2 cf, cuts(1 99) suffix(_1_99) label
gen TLTD = (IQ_DEBT__1_99-IQ_STDEBT__1_99)/ IQ_TOTAL_ASSETS__1_99
replace TLTD = 0 if TLTD < 0 
gen TLTD2 = (IQ_DEBT__1_99)/ IQ_TOTAL_ASSETS_1_99 
gen TLTD3 = TLTD
replace TLTD3=TLTD2 if TLTD ==.
gen div_payer =0
replace div_payer =1 if IQ_div_ > 0 & IQ_div_ != .
gen div_payer2 = div_payer
replace div_payer2 =0 if div_payer ==.

bysort IQ_INDUSTRY_GROUP year: egen industry_sales = sum(IQ_TOTAL_REV__1_99)
egen tag = tag(IQ_INDUSTRY_GROUP year)
bysort tag IQ_INDUSTRY_GROUP (year) : gen GrowthInd = cond(_n == 1, 0, (industry_sales - industry_sales[_n-1]) / industry_sales[_n-1]) if tag
bysort IQ_INDUSTRY_GROUP year (GrowthInd) : replace GrowthInd = GrowthInd[1]

bysort EntityID: gen sales_growth=(IQ_TOTAL_REV__1_99-IQ_TOTAL_REV__1_99[_n-1])/IQ_TOTAL_REV__1_99[_n-1]
winsor2 sales_growth, cuts(1 99) suffix(_1_99) label

gen ww_index = -0.091*cf_1_99 -0.062*div_payer2 +0.021*TLTD3- 0.044*LnAssets_1_99 +.102*GrowthInd -.035*sales_growth_1_99 +.65

winsor2 ww_index, cuts(1 99) suffix(_1_99) label

gen iq_std = IQ_STDEBT_
gen ln_std = ln(1+iq_std)
winsor2 ln_std, cuts(1 99) suffix(_1_99)

gen lev_post = leverage * post
gen sme_lev_post = control*lev_post

gen int_post = interest_cost_1_99 * post
gen sme_int_post = control*int_post

gen std_post = std * post
gen sme_std_post = control*std_post

save "...\GMP dataset_f.dta"

* 3. Main Analyses

* Table 2
use "...\GMP dataset_f.dta", clear

reghdfe ln_AR control_post control post LnSales_1_99 if smp_prd ==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

gen lim_thrsales2017_1=0
replace lim_thrsales2017_1=1 if IQ_TOTAL_REV__1_99>000 & IQ_TOTAL_REV__1_99<86000 & !missing(IQ_TOTAL_REV__1_99) 

reghdfe ln_AR control_post control post LnSales_1_99 if smp_prd ==1 & lim_thrsales2017_1==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

gen thrassets2017_pl1 =0
replace thrassets2017_pl1=1 if ASSETSforthr>218000000 & !missing(ASSETSforthr) & year==2017
gen thrsales2017_pl1=0
replace thrsales2017_pl1=1 if REVforthr>236000000 & !missing(REVforthr) & year==2017
gen sum2017_pl1=0
replace sum2017_pl1=thrassets2017_pl1+thrsales2017_pl1
gen exceed2017_pl1=0
replace exceed2017_pl1=1 if sum2017_pl1>=2
 
gen thrassets2016_pl1 =0
replace thrassets2016_pl1=1 if ASSETSforthr>218000000 & !missing(ASSETSforthr) & year==2016
gen thrsales2016_pl1=0
replace thrsales2016_pl1=1 if REVforthr>236000000 & !missing(REVforthr) & year==2016
gen sum2016_pl1=0
replace sum2016_pl1=thrassets2016_pl1+thrsales2016_pl1
gen exceed2016_pl1=0
replace exceed2016_pl1=1 if sum2016_pl1>=2

bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n-1] if exceed2017_pl1==0 & exceed2017_pl1[_n-1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n-1] if exceed2017_pl1==0 & exceed2017_pl1[_n-1]==1

bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1
bysort EntityID: replace exceed2017_pl1=exceed2017_pl1[_n+1] if exceed2017_pl1==0 & exceed2017_pl1[_n+1]==1

bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n-1] if exceed2016_pl1==0 & exceed2016_pl1[_n-1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n-1] if exceed2016_pl1==0 & exceed2016_pl1[_n-1]==1

bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1
bysort EntityID: replace exceed2016_pl1=exceed2016_pl1[_n+1] if exceed2016_pl1==0 & exceed2016_pl1[_n+1]==1

gen treat_pl1=0
replace treat_pl1=1 if exceed2017_pl1==1 & exceed2016_pl1==1

gen post_pl1=0
replace post_pl1=1 if year>2017

gen treat_post_pl1=treat_pl1*post_pl1

gen control_pl1=0
replace control_pl1=1 if treat_pl1==0

gen control_post_pl1=control_pl1*post_pl1

gen lim_thrassets2017_pl1 =0
replace lim_thrassets2017_pl1=1 if ASSETSforthr<118000000 & !missing(ASSETSforthr) & year==2017
gen lim_thrsales2017_pl1=0
replace lim_thrsales2017_pl1=1 if REVforthr<136000000 & !missing(REVforthr) & year==2017

bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n-1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n-1]==1

bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrsales2017_pl1=lim_thrsales2017_pl1[_n+1] if lim_thrsales2017_pl1==0 & lim_thrsales2017_pl1[_n+1]==1

bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n-1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n-1]==1

bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1
bysort EntityID: replace lim_thrassets2017_pl1=lim_thrassets2017_pl1[_n+1] if lim_thrassets2017_pl1==0 & lim_thrassets2017_pl1[_n+1]==1

reghdfe ln_AR control_post_pl1 control_pl1 post_pl1 LnSales_1_99 if year>2010 & year < 2021 & ASSETSforthr>118000000 & REVforthr>136000000, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP) 

* Table 3

* Download data from https://publish-payment-practices.service.gov.uk 

*import excel "...\payment-practices_datapull September 29 2022.xlsx", sheet("payment-practices_datapull Sept") firstrow allstring
*save "...\PPDR data.dta"

use "...\PPDR data.dta", clear

gen filing_date = date(Filingdate, "MDY")
format filing_date %td
gen filingyear=year(filing_date)

sort Companynumber filing_date
quietly by Companynumber filing_date: gen dup = cond(_N==1, 0, _n)
tab dup
drop if dup > 1

sort Companynumber filing_date
by Companynumber: gen rep_num = _n
tab rep_num
gen rep = 0
replace rep = 1 if rep_num == 1
replace rep = 2 if rep_num == 2
replace rep = 3 if rep_num == 3
replace rep = 4 if rep_num == 4
replace rep = 5 if rep_num == 5
replace rep = 6 if rep_num == 6
replace rep = 7 if rep_num == 7
replace rep = 8 if rep_num == 8
replace rep = 9 if rep_num == 9
replace rep = 10 if rep_num == 10
replace rep = 11 if rep_num == 11

foreach var of varlist Paymentsmadeinthereportingp Averagetimetopay Invoicespaidwithin30days Invoicespaidbetween31and6 Invoicespaidlaterthan60da Invoicesnotpaidwithinagree Shortestoronlystandardpaym Longeststandardpaymentperiod Maximumcontractualpaymentperi Paymenttermshavechanged Suppliersnotifiedofchanges Participatesinpaymentcodes EInvoicingoffered Supplychainfinancingoffered Policycoverschargesforremain Chargeshavebeenmadeforremai {
    destring `var', replace
}

preserve
keep if filingyear<2020
tab rep
*max 5 reports*

foreach var of varlist Invoicesnotpaidwithinagree Shortestoronlystandardpaym  Averagetimetopay Invoicespaidwithin30days Invoicespaidbetween31and6 Invoicespaidlaterthan60da {
drop if missing(`var')
}

tabstat Invoicesnotpaidwithinagree Shortestoronlystandardpaym  Averagetimetopay Invoicespaidwithin30days Invoicespaidbetween31and6 Invoicespaidlaterthan60da, statistics(count mean  p25 median p75 sd ) columns (statistics)

areg Invoicesnotpaidwithinagree rep, absorb(Companynumber) vce (cluster Companynumber)

areg Shortestoronlystandardpaym rep, absorb(Companynumber) vce (cluster Companynumber)

areg Averagetimetopay rep, absorb(Companynumber) vce (cluster Companynumber)

areg Invoicespaidwithin30days rep, absorb(Companynumber) vce (cluster Companynumber)

areg Invoicespaidbetween31and6 rep, absorb(Companynumber) vce (cluster Companynumber)

areg Invoicespaidlaterthan60da rep, absorb(Companynumber) vce (cluster Companynumber)


* Table 4

*Survey response data downloaded from SoGoSurvey 
*import excel "...\SoGoSurvey_Payment Practices and Reportin_download.xlsx", sheet("SME") firstrow allstring
*save "...\SME response.dta"
*clear
*import excel "...\SoGoSurvey_Payment Practices and Reportin_download.xlsx", sheet("Large") firstrow allstring clear
*save "...\Large response.dta"
*clear
*use "...\SME response.dta"
*append using "...\Large response.dta"
*save "...\SME Large combined response.dta"

* Table 4 Panel A

use "...\SME Large combined response.dta", clear
preserve
keep if Doesthecompanysupplygoods=="Yes"

tab Towhatextentiscollectingp

gen _bigproblem=0
replace _bigproblem=1 if Towhatextentiscollectingp=="A big problem"

gen _noproblem=0
replace _noproblem=1 if Towhatextentiscollectingp=="Not a problem"

gen _somewhatproblem=0
replace _somewhatproblem=1 if Towhatextentiscollectingp=="Somewhat of a problem"

prtest _bigproblem=_somewhatproblem
prtest _bigproblem=_noproblem
prtest _somewhatproblem=_noproblem

foreach var of varlist aTheytakeadvantageofus bTheirpaymentsystemsare cPoorcommunicationbetwee dOurinvoicingsystemsare eWesometimeshaveerrors fTheyhavemanysuppliers gWedisagreeonwhengoods hWedisagreeonpaymentte {
	tab `var'
}

foreach var of varlist aTheytakeadvantageofus bTheirpaymentsystemsare cPoorcommunicationbetwee dOurinvoicingsystemsare eWesometimeshaveerrors fTheyhavemanysuppliers gWedisagreeonwhengoods hWedisagreeonpaymentte {
	gen _agree`var'=1 if `var'=="Agree"|`var'=="Somewhat agree"
	gen _neither`var'=1 if `var'=="Neither agree nor disagree"
	gen _dis`var'=1 if `var'=="Disagree"|`var'=="Somewhat disagree"

}

foreach var of varlist _agreeaTheytakeadvantageofus _neitheraTheytakeadvantageofus _disaTheytakeadvantageofus _agreebTheirpaymentsystemsare _neitherbTheirpaymentsystemsare _disbTheirpaymentsystemsare _agreecPoorcommunicationbetwee _neithercPoorcommunicationbetwee _discPoorcommunicationbetwee _agreedOurinvoicingsystemsare _neitherdOurinvoicingsystemsare _disdOurinvoicingsystemsare _agreeeWesometimeshaveerrors _neithereWesometimeshaveerrors _diseWesometimeshaveerrors _agreefTheyhavemanysuppliers _neitherfTheyhavemanysuppliers _disfTheyhavemanysuppliers _agreegWedisagreeonwhengoods _neithergWedisagreeonwhengoods _disgWedisagreeonwhengoods _agreehWedisagreeonpaymentte _neitherhWedisagreeonpaymentte _dishWedisagreeonpaymentte {
	replace `var'=0 if missing(`var')
}

prtest _agreeaTheytakeadvantageofus=_neitheraTheytakeadvantageofus
prtest _agreeaTheytakeadvantageofus=_disaTheytakeadvantageofus
prtest _disaTheytakeadvantageofus=_neitheraTheytakeadvantageofus

prtest _agreebTheirpaymentsystemsare=_neitherbTheirpaymentsystemsare
prtest _agreebTheirpaymentsystemsare=_disbTheirpaymentsystemsare
prtest _disbTheirpaymentsystemsare=_neitherbTheirpaymentsystemsare

prtest _agreecPoorcommunicationbetwee=_neithercPoorcommunicationbetwee
prtest _agreecPoorcommunicationbetwee=_discPoorcommunicationbetwee
prtest _discPoorcommunicationbetwee=_neithercPoorcommunicationbetwee

prtest _agreedOurinvoicingsystemsare=_neitherdOurinvoicingsystemsare
prtest _agreedOurinvoicingsystemsare=_disdOurinvoicingsystemsare
prtest _disdOurinvoicingsystemsare=_neitherdOurinvoicingsystemsare

prtest _agreeeWesometimeshaveerrors=_neithereWesometimeshaveerrors
prtest _agreeeWesometimeshaveerrors=_diseWesometimeshaveerrors
prtest _diseWesometimeshaveerrors=_neithereWesometimeshaveerrors

prtest _agreefTheyhavemanysuppliers=_neitherfTheyhavemanysuppliers
prtest _agreefTheyhavemanysuppliers=_disfTheyhavemanysuppliers
prtest _disfTheyhavemanysuppliers=_neitherfTheyhavemanysuppliers

prtest _agreegWedisagreeonwhengoods=_neithergWedisagreeonwhengoods
prtest _agreegWedisagreeonwhengoods=_disgWedisagreeonwhengoods
prtest _disgWedisagreeonwhengoods=_neithergWedisagreeonwhengoods

prtest _agreehWedisagreeonpaymentte=_neitherhWedisagreeonpaymentte
prtest _agreehWedisagreeonpaymentte=_dishWedisagreeonpaymentte
prtest _dishWedisagreeonpaymentte=_neitherhWedisagreeonpaymentte

tab Pleaseestimatewhatofinv

gen _under25pct=0
replace _under25pct=1 if Pleaseestimatewhatofinv=="<1%"|Pleaseestimatewhatofinv=="1-5%"|Pleaseestimatewhatofinv=="5-15%"|Pleaseestimatewhatofinv=="15-25%"

gen _25to50pct=0
replace _25to50pct=1 if Pleaseestimatewhatofinv=="25-50%"

gen _over50pct=0
replace _over50pct=1 if Pleaseestimatewhatofinv=="50-75%"|Pleaseestimatewhatofinv=="75-90%"|Pleaseestimatewhatofinv==">90%"

tab Doesyourcompanyutilizethe

gen _usedata=0
replace _usedata=1 if Doesyourcompanyutilizethe=="Yes"

gen _nousedata=0
replace _nousedata=1 if Doesyourcompanyutilizethe=="No"

prtest _usedata=_nousedata

tab aWehavelearnedthatwea
tab bWehavelearnedthatwea
tab cWehavelearnedthatour
tab dWehavelearnedthatour
tab eWehavenotlearnedmuch

foreach var of varlist aWehavelearnedthatwea bWehavelearnedthatwea cWehavelearnedthatour dWehavelearnedthatour eWehavenotlearnedmuch {
	gen _agree`var'=1 if `var'=="Agree"|`var'=="Somewhat agree"
	gen _neither`var'=1 if `var'=="Neither agree nor disagree"
	gen _disagree`var'=1 if `var'=="Disagree"|`var'=="Somewhat disagree"

}

foreach var of varlist _agreeaWehavelearnedthatwea _neitheraWehavelearnedthatwea _disagreeaWehavelearnedthatwea _agreebWehavelearnedthatwea _neitherbWehavelearnedthatwea _disagreebWehavelearnedthatwea _agreecWehavelearnedthatour _neithercWehavelearnedthatour _disagreecWehavelearnedthatour _agreedWehavelearnedthatour _neitherdWehavelearnedthatour _disagreedWehavelearnedthatour _agreeeWehavenotlearnedmuch _neithereWehavenotlearnedmuch _disagreeeWehavenotlearnedmuch {
	replace `var'=0 if missing(`var')
}

prtest _agreeaWehavelearnedthatwea=_neitheraWehavelearnedthatwea
prtest _agreeaWehavelearnedthatwea=_disagreeaWehavelearnedthatwea
prtest _disagreeaWehavelearnedthatwea=_neitheraWehavelearnedthatwea

prtest _agreebWehavelearnedthatwea=_neitherbWehavelearnedthatwea
prtest _agreebWehavelearnedthatwea=_disagreebWehavelearnedthatwea
prtest _disagreebWehavelearnedthatwea=_neitherbWehavelearnedthatwea
  
prtest _agreecWehavelearnedthatour=_neithercWehavelearnedthatour
prtest _agreecWehavelearnedthatour=_disagreecWehavelearnedthatour
prtest _disagreecWehavelearnedthatour=_neithercWehavelearnedthatour
  
prtest _agreedWehavelearnedthatour=_neitherdWehavelearnedthatour
prtest _agreedWehavelearnedthatour=_disagreedWehavelearnedthatour
prtest _disagreedWehavelearnedthatour=_neitherdWehavelearnedthatour
  
prtest _agreeeWehavenotlearnedmuch=_neithereWehavenotlearnedmuch
prtest _agreeeWehavenotlearnedmuch=_disagreeeWehavenotlearnedmuch
prtest _disagreeeWehavenotlearnedmuch=_neithereWehavenotlearnedmuch

tab aWeusethedatatonegoti 
tab bWeusethedatatothreat 
tab cWeusethedatatothreat 
tab dWeusethedatatoidenti 
tab eWeusethedatatothreat

foreach var of varlist aWeusethedatatonegoti bWeusethedatatothreat cWeusethedatatothreat dWeusethedatatoidenti eWeusethedatatothreat {
		gen _yes`var'=1 if `var'=="Yes"
		gen _no`var'=1 if `var'=="No"
}

foreach var of varlist _yesaWeusethedatatonegoti _noaWeusethedatatonegoti _yesbWeusethedatatothreat _nobWeusethedatatothreat _yescWeusethedatatothreat _nocWeusethedatatothreat _yesdWeusethedatatoidenti _nodWeusethedatatoidenti _yeseWeusethedatatothreat _noeWeusethedatatothreat {
	replace `var'=0 if missing(`var')
}

prtest _yesaWeusethedatatonegoti=_noaWeusethedatatonegoti

prtest _yesbWeusethedatatothreat=_nobWeusethedatatothreat

prtest _yescWeusethedatatothreat=_nocWeusethedatatothreat

prtest _yesdWeusethedatatoidenti=_nodWeusethedatatoidenti

prtest _yeseWeusethedatatothreat=_noeWeusethedatatothreat

tab aDoesnegotiatiebetterpa
tab bDoesthreatenandpursue
tab cDoesthreatenandbringn
tab dDoesidentifypotentialc
tab eDoesthreatentonolonge


foreach var of varlist aDoesnegotiatiebetterpa bDoesthreatenandpursue cDoesthreatenandbringn dDoesidentifypotentialc eDoesthreatentonolonge {
		gen _yes`var'=1 if `var'=="Yes, Significantly"|`var'=="Yes, Somewhat"
		gen _no`var'=1 if `var'=="No, not at all"
}

foreach var of varlist _yesaDoesnegotiatiebetterpa _noaDoesnegotiatiebetterpa _yesbDoesthreatenandpursue _nobDoesthreatenandpursue _yescDoesthreatenandbringn _nocDoesthreatenandbringn _yesdDoesidentifypotentialc _nodDoesidentifypotentialc _yeseDoesthreatentonolonge _noeDoesthreatentonolonge {
	replace `var'=0 if missing(`var')
}

prtest _yesaDoesnegotiatiebetterpa=_noaDoesnegotiatiebetterpa
prtest _yesbDoesthreatenandpursue=_nobDoesthreatenandpursue
prtest _yescDoesthreatenandbringn=_nocDoesthreatenandbringn
prtest _yesdDoesidentifypotentialc=_nodDoesidentifypotentialc
prtest _yeseDoesthreatentonolonge=_noeDoesthreatentonolonge

restore
clear

* Table 4 Panel B

use "...\SME Large combined response.dta",clear
preserve
keep if Isthecompanyrequiredtodis=="Yes"

tab Towhatextentispayingyour

gen _bigproblem=0
replace _bigproblem=1 if Towhatextentispayingyour=="A big problem"

gen _noproblem=0
replace _noproblem=1 if Towhatextentispayingyour=="Not a problem"

gen _somewhatproblem=0
replace _somewhatproblem=1 if Towhatextentispayingyour=="Somewhat of a problem"

prtest _bigproblem=_somewhatproblem
prtest _bigproblem=_noproblem
prtest _somewhatproblem=_noproblem

foreach var of varlist aWeusesuppliersasasou bPoorcommunicationbetwee cTheirinvoicingsystemsa dOurpaymentsystemsareo eTheyhaveinvoicingerror fWehavemanysuppliersin gWedisagreeonwhengoods hWedisagreeonpaymentte iWedelaypaymentincase {
	tab `var'
}

foreach var of varlist aWeusesuppliersasasou bPoorcommunicationbetwee cTheirinvoicingsystemsa dOurpaymentsystemsareo eTheyhaveinvoicingerror fWehavemanysuppliersin gWedisagreeonwhengoods hWedisagreeonpaymentte iWedelaypaymentincase {
	gen _agree`var'=1 if `var'=="Agree"|`var'=="Somewhat agree"
	gen _neither`var'=1 if `var'=="Neither agree nor disagree"
	gen _dis`var'=1 if `var'=="Disagree"|`var'=="Somewhat disagree"
}

foreach var of varlist _agreeaWeusesuppliersasasou _neitheraWeusesuppliersasasou _disaWeusesuppliersasasou _agreebPoorcommunicationbetwee _neitherbPoorcommunicationbetwee _disbPoorcommunicationbetwee _agreecTheirinvoicingsystemsa _neithercTheirinvoicingsystemsa _discTheirinvoicingsystemsa _agreedOurpaymentsystemsareo _neitherdOurpaymentsystemsareo _disdOurpaymentsystemsareo _agreeeTheyhaveinvoicingerror _neithereTheyhaveinvoicingerror _diseTheyhaveinvoicingerror _agreefWehavemanysuppliersin _neitherfWehavemanysuppliersin _disfWehavemanysuppliersin _agreegWedisagreeonwhengoods _neithergWedisagreeonwhengoods _disgWedisagreeonwhengoods _agreehWedisagreeonpaymentte _neitherhWedisagreeonpaymentte _dishWedisagreeonpaymentte _agreeiWedelaypaymentincase _neitheriWedelaypaymentincase _disiWedelaypaymentincase {
	replace `var'=0 if missing(`var')
}

prtest _agreeaWeusesuppliersasasou=_neitheraWeusesuppliersasasou
prtest _agreeaWeusesuppliersasasou=_disaWeusesuppliersasasou
prtest _disaWeusesuppliersasasou=_neitheraWeusesuppliersasasou

prtest _agreebPoorcommunicationbetwee=_neitherbPoorcommunicationbetwee
prtest _agreebPoorcommunicationbetwee=_disbPoorcommunicationbetwee
prtest _disbPoorcommunicationbetwee=_neitherbPoorcommunicationbetwee

prtest _agreecTheirinvoicingsystemsa=_neithercTheirinvoicingsystemsa
prtest _agreecTheirinvoicingsystemsa=_discTheirinvoicingsystemsa
prtest _discTheirinvoicingsystemsa=_neithercTheirinvoicingsystemsa

prtest _agreedOurpaymentsystemsareo=_neitherdOurpaymentsystemsareo
prtest _agreedOurpaymentsystemsareo=_disdOurpaymentsystemsareo
prtest _disdOurpaymentsystemsareo=_neitherdOurpaymentsystemsareo

prtest _agreeeTheyhaveinvoicingerror=_neithereTheyhaveinvoicingerror
prtest _agreeeTheyhaveinvoicingerror=_diseTheyhaveinvoicingerror
prtest _diseTheyhaveinvoicingerror=_neithereTheyhaveinvoicingerror

prtest _agreefWehavemanysuppliersin=_neitherfWehavemanysuppliersin
prtest _agreefWehavemanysuppliersin=_disfWehavemanysuppliersin
prtest _disfWehavemanysuppliersin=_neitherfWehavemanysuppliersin

prtest _agreegWedisagreeonwhengoods=_neithergWedisagreeonwhengoods
prtest _agreegWedisagreeonwhengoods=_disgWedisagreeonwhengoods
prtest _disgWedisagreeonwhengoods=_neithergWedisagreeonwhengoods

prtest _agreehWedisagreeonpaymentte=_neitherhWedisagreeonpaymentte
prtest _agreehWedisagreeonpaymentte=_dishWedisagreeonpaymentte
prtest _dishWedisagreeonpaymentte=_neitherhWedisagreeonpaymentte

prtest _agreeiWedelaypaymentincase=_neitheriWedelaypaymentincase
prtest _agreeiWedelaypaymentincase=_disiWedelaypaymentincase
prtest _disiWedelaypaymentincase=_neitheriWedelaypaymentincase

tab aOursuppliersusethedat 
tab bOursuppliersusethedat 
tab cOursuppliersusethedat 
tab dOursuppliersusethedat 

foreach var of varlist aOursuppliersusethedat bOursuppliersusethedat cOursuppliersusethedat dOursuppliersusethedat {
		gen _yes`var'=1 if `var'=="Yes"
		gen _no`var'=1 if `var'=="No"
}

foreach var of varlist _yesaOursuppliersusethedat _noaOursuppliersusethedat _yesbOursuppliersusethedat _nobOursuppliersusethedat _yescOursuppliersusethedat _nocOursuppliersusethedat _yesdOursuppliersusethedat _nodOursuppliersusethedat {
	replace `var'=0 if missing(`var')
}

prtest _yesaOursuppliersusethedat=_noaOursuppliersusethedat
prtest _yesbOursuppliersusethedat=_nobOursuppliersusethedat
prtest _yescOursuppliersusethedat=_nocOursuppliersusethedat
prtest _yesdOursuppliersusethedat=_nodOursuppliersusethedat

tab aValidreasonThemedia
tab bValidreasonWearecon
tab cValidreasonWearecon 
tab dValidreasonWeanticip
tab eValidreasonWeanticip 
tab fValidreasonTheregula 
tab gValidreasonHavingto 
tab hValidreasonThedatai 
tab iValidreasonWewantto

foreach var of varlist aValidreasonThemedia bValidreasonWearecon cValidreasonWearecon dValidreasonWeanticip eValidreasonWeanticip fValidreasonTheregula gValidreasonHavingto hValidreasonThedatai iValidreasonWewantto {
		gen _yes`var'=1 if `var'=="Yes"
		gen _no`var'=1 if `var'=="No"
}

foreach var of varlist _yesaValidreasonThemedia _noaValidreasonThemedia _yesbValidreasonWearecon _nobValidreasonWearecon _yescValidreasonWearecon _nocValidreasonWearecon _yesdValidreasonWeanticip _nodValidreasonWeanticip _yeseValidreasonWeanticip _noeValidreasonWeanticip _yesfValidreasonTheregula _nofValidreasonTheregula _yesgValidreasonHavingto _nogValidreasonHavingto _yeshValidreasonThedatai _nohValidreasonThedatai _yesiValidreasonWewantto _noiValidreasonWewantto {
	replace `var'=0 if missing(`var')
}

prtest _yesaValidreasonThemedia=_noaValidreasonThemedia
prtest _yesbValidreasonWearecon=_nobValidreasonWearecon
prtest _yescValidreasonWearecon=_nocValidreasonWearecon
prtest _yesdValidreasonWeanticip=_nodValidreasonWeanticip
prtest _yeseValidreasonWeanticip=_noeValidreasonWeanticip
prtest _yesfValidreasonTheregula=_nofValidreasonTheregula
prtest _yesgValidreasonHavingto=_nogValidreasonHavingto
prtest _yeshValidreasonThedatai=_nohValidreasonThedatai
prtest _yesiValidreasonWewantto=_noiValidreasonWewantto

foreach var of varlist aIsthisaffectingyourpa bIsthisaffectingyourpa cIsthisaffectingyourpa dIsthisaffectingyourpa eIsthisaffectingyourpa fIsthisaffectingyourpa gIsthisaffectingyourpa hIsthisaffectingyourpa iIsthisaffectingyourpa {
	tab `var'
}

foreach var of varlist aIsthisaffectingyourpa bIsthisaffectingyourpa cIsthisaffectingyourpa dIsthisaffectingyourpa eIsthisaffectingyourpa fIsthisaffectingyourpa gIsthisaffectingyourpa hIsthisaffectingyourpa iIsthisaffectingyourpa {
		gen _yes`var'=1 if `var'=="Yes, significantly"|`var'=="Yes, somewhat"
		gen _no`var'=1 if `var'=="No, not at all"
}

foreach var of varlist _yesaIsthisaffectingyourpa _noaIsthisaffectingyourpa _yesbIsthisaffectingyourpa _nobIsthisaffectingyourpa _yescIsthisaffectingyourpa _nocIsthisaffectingyourpa _yesdIsthisaffectingyourpa _nodIsthisaffectingyourpa _yeseIsthisaffectingyourpa _noeIsthisaffectingyourpa _yesfIsthisaffectingyourpa _nofIsthisaffectingyourpa _yesgIsthisaffectingyourpa _nogIsthisaffectingyourpa _yeshIsthisaffectingyourpa _nohIsthisaffectingyourpa _yesiIsthisaffectingyourpa _noiIsthisaffectingyourpa {
	replace `var'=0 if missing(`var')
}

prtest _yesaIsthisaffectingyourpa=_noaIsthisaffectingyourpa
prtest _yesbIsthisaffectingyourpa=_nobIsthisaffectingyourpa
prtest _yescIsthisaffectingyourpa=_nocIsthisaffectingyourpa
prtest _yesdIsthisaffectingyourpa=_nodIsthisaffectingyourpa
prtest _yeseIsthisaffectingyourpa=_noeIsthisaffectingyourpa
prtest _yesfIsthisaffectingyourpa=_nofIsthisaffectingyourpa
prtest _yesgIsthisaffectingyourpa=_nogIsthisaffectingyourpa
prtest _yeshIsthisaffectingyourpa=_nohIsthisaffectingyourpa
prtest _yesiIsthisaffectingyourpa=_noiIsthisaffectingyourpa

foreach var of varlist Weareinvestinginimprovedtec Weareintegratingprocurements Weareprovidingincentivestod Wearecommunicatingwithoursu {
	tab `var'
}

* Table 5 - Link to Mechanisms

use "...\GMP dataset_f.dta", clear

reghdfe ln_AR post_control_APDiffPre control_APDiffPre post_APDiffPre APDiffPre control post control_post LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

gen post_HHI=post*HHI
gen control_HHI=control*HHI
gen post_control_HHI=control_post*HHI

reghdfe ln_AR post_control_HHI control_HHI post_HHI HHI control post control_post LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

gen post_control_RepRisk=control_post*IndustryRRI
gen post_RepRisk=post*IndustryRRI
gen control_RepRisk=control*IndustryRRI

reghdfe ln_AR post_control_RepRisk control_RepRisk post_RepRisk IndustryRRI control post control_post LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

* Table 6 - Financial Constraints
use "...\GMP dataset_f.dta", clear

reghdfe ln_std_1_99 control_post control post  LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)
 
reghdfe ww_index_1_99 control_post control post if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

reghdfe ln_AR sme_lev_post lev_post control_post leverage control post LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)
  
reghdfe ln_AR sme_std_post std_post control_post std control post LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)

reghdfe ln_AR sme_int_post int_post control_post interest_cost_1_99 control post LnSales_1_99 if smp_prd==1, ab(EntityID year) cluster(IQ_INDUSTRY_GROUP)
