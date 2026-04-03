**********************************************************************
**********************************************************************
*** Preparation of raw data ******************************************
**********************************************************************
**********************************************************************

**********************************************************************
*** Preparation of actual sales data *********************************
**********************************************************************

*** Load excel "sub_salesnumbers_act"

*** Reshape data to long format
reshape long sub_sales_numbers_act_2016 sub_sales_numbers_act_2015 sub_sales_numbers_act_2014 sub_sales_numbers_act_2013 sub_sales_numbers_act_2012 ///
sub_sales_numbers_act_2011 sub_sales_numbers_act_2010 sub_sales_numbers_act_2009 sub_sales_numbers_act_2008 ///
sub_sales_numbers_act_2007, i(sub_id sub_sales_split_type) j(month)

rename sub_sales_numbers_act_2016 sub_sales_numbers_act2016
rename sub_sales_numbers_act_2015 sub_sales_numbers_act2015
rename sub_sales_numbers_act_2014 sub_sales_numbers_act2014
rename sub_sales_numbers_act_2013 sub_sales_numbers_act2013
rename sub_sales_numbers_act_2012 sub_sales_numbers_act2012
rename sub_sales_numbers_act_2011 sub_sales_numbers_act2011
rename sub_sales_numbers_act_2010 sub_sales_numbers_act2010
rename sub_sales_numbers_act_2009 sub_sales_numbers_act2009
rename sub_sales_numbers_act_2008 sub_sales_numbers_act2008
rename sub_sales_numbers_act_2007 sub_sales_numbers_act2007

drop if sub_id==""

reshape long sub_sales_numbers_act, i(sub_id sub_sales_split_type month) j(year)

*** Label variables
label variable sub_id "identification of subsidiary"
label variable year "year of analysis"
label variable month "month of analysis"
label variable sub_sales_split_type "business category"
label variable sub_sales_numbers_act "actual sales"

*** Aggregate data for both business categories
bysort sub_id year month: egen sub_sales_numbers_act_1and2=sum(sub_sales_numbers_act)
drop sub_sales_numbers_act sub_sales_split_type
rename sub_sales_numbers_act_1and2 sub_sales_numbers_act

duplicates drop sub_id year month, force

*** Save file
sort sub_id year month
save sub_sales_numbers_act.dta, replace


clear all


**********************************************************************
*** Preparation of sales target data *********************************
**********************************************************************

*** Load excel "sub_salesnumbers_plan"

*** Reshape data to long format
reshape long sub_sales_numbers_plan_2016 sub_sales_numbers_plan_2015 sub_sales_numbers_plan_2014 sub_sales_numbers_plan_2013 sub_sales_numbers_plan_2012 ///
sub_sales_numbers_plan_2011 sub_sales_numbers_plan_2010, i(sub_id sub_sales_split_type) j(month)

rename sub_sales_numbers_plan_2016 sub_sales_numbers_plan2016
rename sub_sales_numbers_plan_2015 sub_sales_numbers_plan2015
rename sub_sales_numbers_plan_2014 sub_sales_numbers_plan2014
rename sub_sales_numbers_plan_2013 sub_sales_numbers_plan2013
rename sub_sales_numbers_plan_2012 sub_sales_numbers_plan2012
rename sub_sales_numbers_plan_2011 sub_sales_numbers_plan2011
rename sub_sales_numbers_plan_2010 sub_sales_numbers_plan2010

reshape long sub_sales_numbers_plan, i(sub_id sub_sales_split_type month) j(year)

*** Label variables
label variable sub_id "identification of subsidiary"
label variable year "year of analysis"
label variable month "month of analysis"
label variable sub_sales_split_type "business category"
label variable sub_sales_numbers_plan "sales target"

*** Aggregate data for both business categories
bysort sub_id year month: egen sub_sales_numbers_plan_1and2=sum(sub_sales_numbers_plan) if sub_sales_numbers_plan!=.
drop sub_sales_numbers_plan sub_sales_split_type
rename sub_sales_numbers_plan_1and2 sub_sales_numbers_plan

duplicates drop sub_id year month, force

*** Save file
sort sub_id year month
save sub_sales_numbers_plan.dta, replace


clear all


**********************************************************************
*** Preparation of headcount data ************************************
**********************************************************************

*** Load excel "headcount"

*** Reshape data to long format
reshape long sub_headcount_total, i(sub_id) j(year)
sort sub_id year

tostring year, replace

gen year_new=substr(year,1,4)
gen month=substr(year,5,.)
drop year
rename year_new year

destring year, replace
destring month, replace

*** Label variables
label variable sub_id "identification of subsidiary"
label variable year "year of analysis"
label variable month "month of analysis"
label variable sub_headcount_total "total headcount"

*** Save file
sort sub_id year month
save sub_headcount.dta, replace


clear all


**********************************************************************
*** Preparation of working days data *********************************
**********************************************************************

*** Load excel "working_days"

*** Clean data
destring year, replace

*** Label variables
label variable sub_region "identification of the region where the subsidiary is located"
label variable year "year of analysis"
label variable month "month of analysis"
label variable sub_working_days "number of working days per month"

*** Save file
sort sub_region year month
save sub_working_days.dta, replace


clear all


****************************************************************************************************
*** Preparation of region data (Note: The dataset subsidiaries_merged1 is generated in line 292) ***
****************************************************************************************************

use subsidiaries_merged1.dta

gen sub_region=substr(sub_id,1,3)
label variable sub_region "region where subsidiary is located"

bysort sub_region year month: egen region_sales_numbers_plan=sum(sub_sales_numbers_plan)
label variable region_sales_numbers_plan "sales target per region"

bysort sub_region year month: egen region_sales_numbers_act=sum(sub_sales_numbers_act)
label variable region_sales_numbers_act "actual sales per region"

duplicates drop sub_region year month, force
drop sub_id sub_sales_numbers_act sub_sales_numbers_plan
drop if year<2010

sort sub_region year month
by sub_region: gen region_reltargetchange=(region_sales_numbers_plan-region_sales_numbers_plan[_n-12])/region_sales_numbers_plan[_n-12]
label variable region_reltargetchange "relative change in target from prior year to this year per region"

sort sub_region year month
by sub_region: gen region_reltargetachiev_prioryear=(region_sales_numbers_act[_n-12]-region_sales_numbers_plan[_n-12])/region_sales_numbers_plan[_n-12]
label variable region_reltargetachiev_prioryear "relative target achievement prior year per region"

sort sub_region year month
gen region_targetmiss_prioryear=.
replace region_targetmiss_prioryear=0 if region_reltargetachiev_prioryear!=.
by sub_region: replace region_targetmiss_prioryear=1 if region_sales_numbers_act[_n-12]<region_sales_numbers_plan[_n-12] & region_reltargetachiev_prioryear!=.
label variable region_targetmiss_prioryear "indicator equal 1 if actual below target in prior year per region"

bysort sub_region year: egen region_sales_numbers_act_y=sum(region_sales_numbers_act)
replace region_sales_numbers_act_y=. if region_sales_numbers_act==.
label variable region_sales_numbers_act_y "annual actual sales numbers per region"

bysort sub_region year: egen region_sales_numbers_plan_y=sum(region_sales_numbers_plan)
replace region_sales_numbers_plan_y=. if region_sales_numbers_plan==.
label variable region_sales_numbers_plan_y "annual sales target per region"

gen region_targetmiss_y_prioryear=0
bysort sub_region: replace region_targetmiss_y_prioryear=1 if region_sales_numbers_act_y[_n-12]<region_sales_numbers_plan_y[_n-12]
bysort sub_region: replace region_targetmiss_y_prioryear=. if region_sales_numbers_act_y[_n-12]==. | region_sales_numbers_plan_y[_n-12]==.
label variable region_targetmiss_y_prioryear "indicator whether region missed its annual target in the prior year"

sort sub_region year month
by sub_region: gen region_reltargetchange_y=(region_sales_numbers_plan_y-region_sales_numbers_plan_y[_n-12])/region_sales_numbers_plan_y[_n-12]
label variable region_reltargetchange_y "relative change in annual target per region"

sort sub_region year month
save region_target_setting.dta, replace


clear all


************************************************************************************************
*** Preparation of HQ data (Note: The dataset subsidiaries_merged1 is generated in line 292) ***
************************************************************************************************

use subsidiaries_merged1.dta

bysort year month: egen HQ_sales_numbers_plan=sum(sub_sales_numbers_plan)
replace HQ_sales_numbers_plan=. if sub_sales_numbers_plan==.
label variable HQ_sales_numbers_plan "HQ sales targets"

bysort year month: egen HQ_sales_numbers_act=sum(sub_sales_numbers_act)
label variable HQ_sales_numbers_act "HQ actual sales"

duplicates drop year month, force
drop sub_id sub_sales_numbers_act sub_sales_numbers_plan
drop if year<2010

sort year month
gen HQ_reltargetchange=(HQ_sales_numbers_plan-HQ_sales_numbers_plan[_n-12])/HQ_sales_numbers_plan[_n-12]
label variable HQ_reltargetchange "HQ relative change in targets from prior year to this year"

sort year month
gen HQ_reltargetachiev_prioryear=(HQ_sales_numbers_act[_n-12]-HQ_sales_numbers_plan[_n-12])/HQ_sales_numbers_plan[_n-12]
label variable HQ_reltargetachiev_prioryear "HQ relative target achievement prior year"

sort year month
gen HQ_targetmiss_prioryear=.
replace HQ_targetmiss_prioryear=0 if HQ_reltargetachiev_prioryear!=.
replace HQ_targetmiss_prioryear=1 if HQ_sales_numbers_act[_n-12]<HQ_sales_numbers_plan[_n-12] & HQ_reltargetachiev_prioryear!=.
label variable HQ_targetmiss_prioryear "indicator equal 1 if HQ actual below target in prior year"


bysort year: egen HQ_sales_numbers_act_y=sum(HQ_sales_numbers_act)
replace HQ_sales_numbers_act_y=. if HQ_sales_numbers_act==.
label variable HQ_sales_numbers_act_y "HQ actual sales numbers per year"

bysort year: egen HQ_sales_numbers_plan_y=sum(HQ_sales_numbers_plan)
replace HQ_sales_numbers_plan_y=. if HQ_sales_numbers_plan==.
label variable HQ_sales_numbers_plan_y "HQ sales target per year"

gen HQ_targetmiss_y_prioryear=0
replace HQ_targetmiss_y_prioryear=1 if HQ_sales_numbers_act_y[_n-12]<HQ_sales_numbers_plan_y[_n-12]
replace HQ_targetmiss_y_prioryear=. if HQ_sales_numbers_act_y[_n-12]==. | HQ_sales_numbers_plan_y[_n-12]==.
label variable HQ_targetmiss_y_prioryear "indicator whether the firm missed its annual target in the prior year"

sort year month
save HQ_target_setting.dta, replace


clear all



**********************************************************************
**********************************************************************
*** Merge files ******************************************************
**********************************************************************
**********************************************************************

**********************************************************************
*** Merge actual sales and sales target data *************************
**********************************************************************

*** Open actual sales data
use sub_sales_numbers_act.dta


*** Merge actual sales data with sales target data
sort sub_id year month
merge sub_id year month using sub_sales_numbers_plan.dta
drop _merge

*** Relabel variables
label variable sub_sales_numbers_act "actual sales"
label variable sub_sales_numbers_plan "sales target"

sort sub_id year month 
save subsidiaries_merged1.dta, replace

clear all


**********************************************************************
*** Merge merged data with headcount data ****************************
**********************************************************************

use subsidiaries_merged1.dta

sort sub_id year month
merge sub_id year month using sub_headcount.dta
drop _merge

save subsidiaries_merged2.dta, replace



**********************************************************************
*** Merge merged data with working days data *************************
**********************************************************************

gen sub_region=substr(sub_id,1,3)
label variable sub_region "region where subsidiary is located"

sort sub_region year month
merge sub_region year month using sub_working_days.dta
drop _merge

sort sub_id year month
save subsidiaries_merged3.dta, replace



**********************************************************************
*** Merge merged data with region data *******************************
**********************************************************************

sort sub_region year month
merge sub_region year month using region_target_setting.dta
drop _merge

sort sub_id year month
save subsidiaries_merged4.dta, replace



**********************************************************************
*** Merge merged data with HQ data ***********************************
**********************************************************************

sort year month
merge year month using HQ_target_setting.dta
drop _merge

sort sub_id year month
save subsidiaries_merged5.dta, replace





**********************************************************************
**********************************************************************
*** Generate variables ***********************************************
**********************************************************************
**********************************************************************

**********************************************************************
*** Target ratcheting ***********************************************
**********************************************************************

sort sub_id year month
by sub_id: gen sub_reltargetchange=(sub_sales_numbers_plan-sub_sales_numbers_plan[_n-12])/sub_sales_numbers_plan[_n-12]
label variable sub_reltargetchange "relative change in targets from prior year to this year"

sort sub_id year month
by sub_id: gen sub_reltargetachiev_prioryear=(sub_sales_numbers_act[_n-12]-sub_sales_numbers_plan[_n-12])/sub_sales_numbers_plan[_n-12]
label variable sub_reltargetachiev_prioryear "relative target achievement prior year"

sort sub_id year month
gen sub_targetmiss_prioryear=.
replace sub_targetmiss_prioryear=0 if sub_reltargetachiev_prioryear!=.
by sub_id: replace sub_targetmiss_prioryear=1 if sub_sales_numbers_act[_n-12]<sub_sales_numbers_plan[_n-12] & sub_reltargetachiev_prioryear!=.
label variable sub_targetmiss_prioryear "indicator variable equal to 1 if actual below target in the prior year, 0 otherwise"



**********************************************************************
*** Target difficulty ************************************************
**********************************************************************

bysort sub_region year month: egen sub_averagetarget_region=mean(sub_sales_numbers_plan/sub_headcount_total)
label variable sub_averagetarget_region "average relative target per region"

gen sub_reltargetdiff_plan=((sub_sales_numbers_plan/sub_headcount_total)-sub_averagetarget_region)/sub_averagetarget_region
label variable sub_reltargetdiff_plan "relative target difficulty"

sort sub_id year month
by sub_id: gen sub_reltargetdiff_plan_prioryear=((sub_sales_numbers_plan[_n-12]/sub_headcount_total[_n-12])-sub_averagetarget_region[_n-12])/sub_averagetarget_region[_n-12]
label variable sub_reltargetdiff_plan_prioryear "relative target difficulty prior year"


bysort sub_region year month: egen sub_averageact_region=mean(sub_sales_numbers_act/sub_headcount_total)
label variable sub_averageact_region "average relative actual per region"

gen sub_reltargetdiff=((sub_sales_numbers_plan/sub_headcount_total)-sub_averageact_region)/sub_averageact_region
label variable sub_reltargetdiff "relative target difficulty"

sort sub_id year month
by sub_id: gen sub_reltargetdiff_prioryear=((sub_sales_numbers_plan[_n-12]/sub_headcount_total[_n-12])-sub_averageact_region[_n-12])/sub_averageact_region[_n-12]
label variable sub_reltargetdiff_prioryear "relative target difficulty prior year"



**********************************************************************
*** Headcount ********************************************************
**********************************************************************

sort sub_id year month
by sub_id: gen sub_headcount_prioryear=sub_headcount_total[_n-12]
label variable sub_headcount_prioryear "number of employees prior year"

sort sub_id year month
by sub_id: gen sub_relheadcount_deltaprioryear=(sub_headcount_total-sub_headcount_total[_n-12])/sub_headcount_total[_n-12]
label variable sub_relheadcount_deltaprioryear "change in the number of employees relative to prior year"




**********************************************************************
*** Change in working days *******************************************
**********************************************************************

sort sub_id year month
by sub_id: gen sub_working_days_delta=(sub_working_days-sub_working_days[_n-12])/sub_working_days[_n-12]
label variable sub_working_days_delta "change in the number of working days relative to prior year"




**********************************************************************
*** Serial correlation ***********************************************
**********************************************************************

sort sub_id year month
gen sub_targetmiss=.
replace sub_targetmiss=0 if sub_sales_numbers_plan!=.
by sub_id: replace sub_targetmiss=1 if sub_sales_numbers_act<sub_sales_numbers_plan & sub_sales_numbers_plan!=.
label variable sub_targetmiss "indicator variable equal to 1 if actual below target, 0 otherwise"

sort sub_id year month
by sub_id: gen sub_reltargetachiev=(sub_sales_numbers_act-sub_sales_numbers_plan)/sub_sales_numbers_plan
label variable sub_reltargetachiev "relative target achievement"




**********************************************************************
*** Target setting at the regional level *****************************
**********************************************************************

sort sub_region year month
by sub_region year month: egen region_targetmiss_py_subcount=sum(sub_targetmiss_prioryear)
replace region_targetmiss_py_subcount=. if sub_targetmiss_prioryear==.
label variable region_targetmiss_py_subcount "number of subsidiaries which missed their target per region"

sort sub_region year month
by sub_region year month: gen counter=_n

sort sub_region year month
by sub_region year month: egen region_number_sub=max(counter)
label variable region_number_sub "number of subsidiaries per region"

drop counter

gen region_targetmiss_py_subcount_r=region_targetmiss_py_subcount/region_number_sub
label variable region_targetmiss_py_subcount_r "relative number of subsidiaries which missed their target per region"




**********************************************************************
*** Annual variables *************************************************
**********************************************************************

bysort sub_id year: egen sub_sales_numbers_act_y=sum(sub_sales_numbers_act)
replace sub_sales_numbers_act_y=. if sub_sales_numbers_act==.
label variable sub_sales_numbers_act_y "annual actual sales"

bysort sub_id year: egen sub_sales_numbers_plan_y=sum(sub_sales_numbers_plan)
replace sub_sales_numbers_plan_y=. if sub_sales_numbers_plan==.
label variable sub_sales_numbers_plan_y "annual sales target"

sort sub_id year month
gen sub_targetmiss_y_prioryear=0
by sub_id: replace sub_targetmiss_y_prioryear=1 if sub_sales_numbers_act_y[_n-12]<sub_sales_numbers_plan_y[_n-12]
by sub_id: replace sub_targetmiss_y_prioryear=. if sub_sales_numbers_act_y[_n-12]==. | sub_sales_numbers_plan_y[_n-12]==.
label variable sub_targetmiss_y_prioryear "indicator variable equal to 1 if subsidiary missed its annual target prior year, 0 otherwise"

sort sub_id year month
bysort sub_id: gen sub_reltargetchange_y=(sub_sales_numbers_plan_y-sub_sales_numbers_plan_y[_n-12])/sub_sales_numbers_plan_y[_n-12]
label variable sub_reltargetchange_y "annual change in sales target"




**********************************************************************
*** Allocation of targets across subsidiaries within region **********
**********************************************************************
gen sub_sales_numbers_p_relr=sub_sales_numbers_plan/region_sales_numbers_plan
label variable sub_sales_numbers_p_relr "subsidiary target relative to region target"

sort sub_id year month
by sub_id: gen sub_sales_numbers_p_relr_c=(sub_sales_numbers_p_relr-sub_sales_numbers_p_relr[_n-12])/sub_sales_numbers_p_relr[_n-12]
label variable sub_sales_numbers_p_relr_c "change in the proportion of regional target compared to prior year"




**********************************************************************
*** Alternative RTS measure ******************************************
**********************************************************************
gen sub_sales_numbers_act_plan=sub_sales_numbers_act-sub_sales_numbers_plan

sort sub_id year month
by sub_id: gen sub_sales_numbers_ap_rel_py=sub_sales_numbers_act_plan[_n-12]/sub_sales_numbers_plan[_n-12]
label variable sub_sales_numbers_ap_rel_py "difference between actual performance and performance target scaled by the performance target in the prior year"

bysort sub_region year month: egen region_sales_numb_ap_r_py=sum(sub_sales_numbers_ap_rel_py)
label variable region_sales_numb_ap_r_py "sum of sub_sales_numbers_act_plan_rel_py per region"

sort sub_id year month
gen region_sales_numb_ap_r_py_a=region_sales_numb_ap_r_py-sub_sales_numbers_ap_rel_py
label variable region_sales_numb_ap_r_py_a "sum of sub_sales_numb_act_plan_r_py per region without respective subsidiary"

gen region_sales_numb_ap_r_py_a_a=region_sales_numb_ap_r_py_a/5 if sub_region=="RG3"
replace region_sales_numb_ap_r_py_a_a=region_sales_numb_ap_r_py_a/5 if sub_region=="RG4"
replace region_sales_numb_ap_r_py_a_a=region_sales_numb_ap_r_py_a/7 if sub_region=="RG1"
replace region_sales_numb_ap_r_py_a_a=region_sales_numb_ap_r_py_a/7 if sub_region=="RG2"
replace region_sales_numb_ap_r_py_a_a=region_sales_numb_ap_r_py_a/1 if sub_region=="RG5"
label variable region_sales_numb_ap_r_py_a_a "average of sub_sales_numb_act_plan_r_py per region without respective subsidiary"
replace region_sales_numb_ap_r_py_a_a=. if sub_sales_numbers_ap_rel_py==.




**********************************************************************
*** Drop years with missing data *************************************
**********************************************************************

drop if year<2011


**********************************************************************
*** Region and year fixed effects ************************************
**********************************************************************

tabulate sub_region, generate (dumr)
tabulate year, generate (dumy)


sort sub_id year month
save subsidiaries_final.dta, replace






**********************************************************************
**********************************************************************
*** Descriptives *****************************************************
**********************************************************************
**********************************************************************

**********************************************************************
*** Table 2 **********************************************************
**********************************************************************

* Panel A
use subsidiaries_final.dta
duplicates drop sub_region year month, force

bysort year: sum region_sales_numbers_act region_sales_numbers_plan

gen region_sales_numbers_act_plan=region_sales_numbers_act-region_sales_numbers_plan
bysort year: sum region_sales_numbers_act_plan

gen region_targetachievement=0
replace region_targetachievement=1 if region_sales_numbers_act>=region_sales_numbers_plan
bysort year: tab region_targetachievement

clear all


* Panel B
use subsidiaries_final.dta
bysort year: sum sub_sales_numbers_act sub_sales_numbers_plan

bysort year: sum sub_sales_numbers_act_plan

gen sub_targetachievement=1-sub_targetmiss
bysort year: tab sub_targetachievement

clear all


* Panel C
use subsidiaries_final.dta

sum sub_reltargetchange, d 
sum sub_reltargetachiev_prioryear, d
sum sub_targetmiss_prioryear, d
sum region_targetmiss_prioryear, d
sum sub_reltargetdiff_plan_prioryear, d
sum sub_headcount_prioryear, d
sum sub_relheadcount_deltaprioryear, d
sum sub_working_days_delta, d
sum region_reltargetchange_y, d


clear all




**********************************************************************
**********************************************************************
*** Correlations *****************************************************
**********************************************************************
**********************************************************************

**********************************************************************
*** Table 3 **********************************************************
**********************************************************************

use subsidiaries_final.dta

pwcorr sub_reltargetchange sub_reltargetachiev_prioryear sub_targetmiss_prioryear region_targetmiss_prioryear sub_reltargetdiff_plan_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear ///
sub_working_days_delta region_reltargetchange_y, sig obs star(0.10)

estpost correlate sub_reltargetchange sub_reltargetachiev_prioryear sub_targetmiss_prioryear region_targetmiss_prioryear sub_reltargetdiff_plan_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear ///
sub_working_days_delta region_reltargetchange_y, matrix listwise
est store c1
esttab using Table3.csv, unstack not noobs b(%12.2f) star(* 0.10 ** 0.05 *** 0.01) replace


clear all



**********************************************************************
**********************************************************************
*** Regressions ******************************************************
**********************************************************************
**********************************************************************

use subsidiaries_final.dta

**********************************************************************
*** Table 4 **********************************************************
**********************************************************************

* Panel A
ttest sub_reltargetchange if sub_targetmiss_prioryear==0 & HQ_targetmiss_prioryear==0, by(region_targetmiss_prioryear)
ttest sub_reltargetchange if sub_targetmiss_prioryear==1 & HQ_targetmiss_prioryear==0, by(region_targetmiss_prioryear)


* Panel B
ttest sub_reltargetchange if sub_targetmiss_prioryear==0 & HQ_targetmiss_prioryear==1, by(region_targetmiss_prioryear)
ttest sub_reltargetchange if sub_targetmiss_prioryear==1 & HQ_targetmiss_prioryear==1, by(region_targetmiss_prioryear)


* Panel C
egen sub_reltargetachiev_prioryear_m=mean(sub_reltargetachiev_prioryear)
gen sub_reltargetachiev_prioryear_s=sub_reltargetachiev_prioryear-sub_reltargetachiev_prioryear_m

egen sub_targetmiss_prioryear_m=mean(sub_targetmiss_prioryear)
gen sub_targetmiss_prioryear_s=sub_targetmiss_prioryear-sub_targetmiss_prioryear_m

egen region_targetmiss_prioryear_m=mean(region_targetmiss_prioryear)
gen region_targetmiss_prioryear_s=region_targetmiss_prioryear-region_targetmiss_prioryear_m


reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear, robust cluster(sub_id)
outreg2 using Table4_PanelC.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_PanelC.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

testparm c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear if region_targetmiss_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear if region_targetmiss_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


* Difference in coefficients across subsamples
reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==0
est store first

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==1
est store second

suest first second
test [first_mean]sub_reltargetachiev_prioryear=[second_mean]sub_reltargetachiev_prioryear





* Robustness tests
* Footnote 9: Regional manager's target achievement as continuous variable
egen region_reltargetachiev_py_m=mean(region_reltargetachiev_prioryear)
gen region_reltargetachiev_py_s=region_reltargetachiev_prioryear-region_reltargetachiev_py_m

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_reltargetachiev_py_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_continuousmeasure.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_reltargetachiev_py_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_continuousmeasure.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


* Footnote 10: Alternative RTS measure (ex-post Aranda et al. (2016) measure and measure by Casas-Arce et al. (2018))
reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_prioryear, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_alternative_rel.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a)) 

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_alternative_rel.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a)) 


reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s region_sales_numb_ap_r_py_a_a, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_alternative_rel.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a)) 

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s region_sales_numb_ap_r_py_a_a ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_alternative_rel.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a)) 


* Page 24: Subsidiary manager's annual target change as additional control variable
reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 sub_targetmiss_y_prioryear, robust cluster(sub_id)
vif
outreg2 using Table4_PanelC_rob_annualchangetarget.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))


* Page 24: Subsidiary and/or regional manager's target achievement indicator measured at the annual instead of month level
egen region_targetmiss_y_prioryear_m=mean(region_targetmiss_y_prioryear)
gen region_targetmiss_y_prioryear_s=region_targetmiss_y_prioryear-region_targetmiss_y_prioryear_m

egen sub_targetmiss_y_prioryear_m=mean(sub_targetmiss_y_prioryear)
gen sub_targetmiss_y_prioryear_s=sub_targetmiss_y_prioryear-sub_targetmiss_y_prioryear_m


reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss1.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))
testparm c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear if region_targetmiss_y_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear if region_targetmiss_y_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==0
est store first

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==1
est store second

suest first second
test [first_mean]sub_reltargetachiev_prioryear=[second_mean]sub_reltargetachiev_prioryear



reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_y_prioryear_s sub_reltargetdiff_plan_prioryear, robust cluster(sub_id)
outreg2 using Table4_Panelc_rob_yearlytargetmiss2.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_y_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_Panelc_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))
testparm c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear if region_targetmiss_y_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_y_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear if region_targetmiss_y_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_y_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_y_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==0
est store first

reg sub_reltargetchange sub_reltargetachiev_prioryear sub_reltargetdiff_plan_prioryear ///
sub_targetmiss_y_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==1
est store second

suest first second
test [first_mean]sub_reltargetachiev_prioryear=[second_mean]sub_reltargetachiev_prioryear



* Page 24: Exclude data from 2013
reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear if year!=2013, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_newsample.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s ///
c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6  if year!=2013, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_newsample.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


* Page 24: Three-way interaction
reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s##c.sub_targetmiss_prioryear_s ///
sub_reltargetdiff_plan_prioryear, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_threeway.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetchange c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s##c.sub_targetmiss_prioryear_s ///
sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_threeway.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))
testparm c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s


* Footnote 14: Allocation of targets across subsidiaries
reg sub_sales_numbers_p_relr_c c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
if region_targetmiss_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_targetallocation.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_sales_numbers_p_relr_c c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y  ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==0, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_targetallocation.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_sales_numbers_p_relr_c c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear /// 
if region_targetmiss_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_targetallocation.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_sales_numbers_p_relr_c c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y  ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==1, robust cluster(sub_id)
outreg2 using Table4_PanelC_rob_targetallocation.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))




**********************************************************************
*** Figure 1 *********************************************************
**********************************************************************

reg sub_reltargetchange c.sub_reltargetachiev_prioryear##i.region_targetmiss_prioryear ///
c.sub_reltargetachiev_prioryear##c.sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)

margins , at(sub_reltargetachiev_prioryear=(0(0.05)0.3) sub_targetmiss_prioryear==0 region_targetmiss_prioryear==0) post
est store model1


reg sub_reltargetchange c.sub_reltargetachiev_prioryear##i.region_targetmiss_prioryear ///
c.sub_reltargetachiev_prioryear##c.sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)

margins , at(sub_reltargetachiev_prioryear=(-0.3(0.05)0) sub_targetmiss_prioryear==1 region_targetmiss_prioryear==0) post
est store model2


reg sub_reltargetchange c.sub_reltargetachiev_prioryear##i.region_targetmiss_prioryear ///
c.sub_reltargetachiev_prioryear##c.sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)

margins , at(sub_reltargetachiev_prioryear=(0(0.05)0.3) sub_targetmiss_prioryear==0 region_targetmiss_prioryear==1) post
est store model3


reg sub_reltargetchange c.sub_reltargetachiev_prioryear##i.region_targetmiss_prioryear ///
c.sub_reltargetachiev_prioryear##c.sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)

margins , at(sub_reltargetachiev_prioryear=(-0.3(0.05)0) sub_targetmiss_prioryear==1 region_targetmiss_prioryear==1) post
est store model4



coefplot (model1, lpattern(solid) lcolor(black)) (model2, lpattern(dash) lcolor(black)) (model3, lpattern(shortdash) lcolor(black)) (model4, lpattern(dot) lcolor(black)), at xtitle("subsidiary manager's target achievement", size(small)) noci recast(line) legend(label(1 "Successful subsidiary manager" "Successful regional manager") label(2 "Failing subsidiary manager" "Successful regional manager") label(3 "Successful subsidiary manager" "Failing regional manager") label(4 "Failing subsidiary manager" "Failing regional manager") size(vsmall)) ytitle("relative change in subsidiary manager's target", size(small))



**********************************************************************
*** Table 5 **********************************************************
**********************************************************************

* Panel A
logit sub_targetmiss i.sub_targetmiss_prioryear##i.region_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelA.xls, replace dec(3)

logit sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==0, robust cluster(sub_id)
outreg2 using Table5_PanelA.xls, append dec(3)

logit sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==1, robust cluster(sub_id)
outreg2 using Table5_PanelA.xls, append dec(3)


* Difference in coefficients across subsamples
reg sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==0
est store first

reg sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_prioryear==1
est store second

suest first second
test [first_mean]sub_targetmiss_prioryear=[second_mean]sub_targetmiss_prioryear


* Cross-partial derivative
gen interact_inteff=sub_targetmiss_prioryear*region_targetmiss_prioryear

logit sub_targetmiss sub_targetmiss_prioryear region_targetmiss_prioryear interact_inteff sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)

inteff sub_targetmiss sub_targetmiss_prioryear region_targetmiss_prioryear interact_inteff sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6


* Robustness test (page 27)
logit sub_targetmiss i.sub_targetmiss_prioryear##i.region_targetmiss_y_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelA_rob_yearlytargetmiss1.xls, replace dec(3)

logit sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==0, robust cluster(sub_id)
outreg2 using Table5_PanelA_rob_yearlytargetmiss1.xls, append dec(3)

logit sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==1, robust cluster(sub_id)
outreg2 using Table5_PanelA_rob_yearlytargetmiss1.xls, append dec(3)


reg sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==0
est store first

reg sub_targetmiss sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6 if region_targetmiss_y_prioryear==1
est store second

suest first second
test [first_mean]sub_targetmiss_prioryear=[second_mean]sub_targetmiss_prioryear


* Panel B
reg sub_reltargetachiev sub_reltargetachiev_prioryear sub_targetmiss_prioryear region_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s region_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_prioryear_s c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s ///
sub_reltargetdiff_plan_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


* Robustness tests (page 28)
reg sub_reltargetachiev sub_reltargetachiev_prioryear sub_targetmiss_prioryear region_targetmiss_y_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss1.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s sub_targetmiss_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s region_targetmiss_y_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_prioryear_s ///
sub_reltargetdiff_plan_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss1.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))


reg sub_reltargetachiev sub_reltargetachiev_prioryear sub_targetmiss_y_prioryear region_targetmiss_y_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss2.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s sub_targetmiss_y_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_y_prioryear_s region_targetmiss_y_prioryear sub_reltargetdiff_plan_prioryear ///
sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))

reg sub_reltargetachiev c.sub_reltargetachiev_prioryear_s##c.region_targetmiss_y_prioryear_s c.sub_reltargetachiev_prioryear_s##c.sub_targetmiss_y_prioryear_s ///
sub_reltargetdiff_plan_prioryear sub_headcount_prioryear sub_relheadcount_deltaprioryear sub_working_days_delta region_reltargetchange_y ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust cluster(sub_id)
outreg2 using Table5_PanelB_rob_yearlytargetmiss2.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))




************************************************************************************
****  Table 6 **********************************************************************
************************************************************************************

duplicates drop sub_region year month, force
keep sub_region year month region_sales_numbers_plan region_sales_numbers_act ///
region_reltargetchange region_reltargetachiev_prioryear region_targetmiss_prioryear region_targetmiss_py_subcount_r ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6

egen region_reltargetachiev_py_m=mean(region_reltargetachiev_prioryear)
gen region_reltargetachiev_py_s=region_reltargetachiev_prioryear-region_reltargetachiev_py_m

egen region_targetmiss_prioryear_m=mean(region_targetmiss_prioryear)
gen region_targetmiss_prioryear_s=region_targetmiss_prioryear-region_targetmiss_prioryear_m

egen region_targetmiss_py_subcount_rm=mean(region_targetmiss_py_subcount_r)
gen region_targetmiss_py_subcount_rs=region_targetmiss_py_subcount_r-region_targetmiss_py_subcount_rm

reg region_reltargetchange c.region_reltargetachiev_py_s##c.region_targetmiss_py_subcount_rs, robust
outreg2 using Table6.xls, replace dec(3) addstat(Adjusted R-squared, e(r2_a))

reg region_reltargetchange c.region_reltargetachiev_py_s##c.region_targetmiss_py_subcount_rs ///
dumr1 dumr2 dumr3 dumr4 dumr5 dumy1 dumy2 dumy3 dumy4 dumy5 dumy6, robust
outreg2 using Table6.xls, append dec(3) addstat(Adjusted R-squared, e(r2_a))
testparm c.region_reltargetachiev_py_s##c.region_targetmiss_py_subcount_rs




************************************************************************************
****  Figure 2 *********************************************************************
************************************************************************************

graph bar region_reltargetchange if region_targetmiss_prioryear==0, over(region_targetmiss_py_subcount_r, relabel(1 "0%" 2 "12.50%" 3 "16.67%" 4 "25.00%" 5 "33.33%" 6 "37.50%" 7 "50.00%" 8 "66.67%") label(labsize(vsmall))) ytitle("relative change in regional manager's target", size(small)) b1title("proportion of failing subsidiary managers within the region", size(small))

graph bar region_reltargetchange if region_targetmiss_prioryear==1, over(region_targetmiss_py_subcount_r, relabel(0 "0%" 1 "33.33%" 2 "37.50%" 3 "50.00%" 4 "62.50%" 5 "66.67%" 6 "75.00%" 7 "83.33%" 8 "87.50%" 9 "100%") label(labsize(vsmall))) ytitle("relative change in regional manager's target", size(small)) b1title("proportion of failing subsidiary managers within the region", size(small))



gen region_reltargetchange_miss=region_reltargetchange if region_targetmiss_prioryear==1
label variable region_reltargetchange_miss "regional manager missed her target"

gen region_reltargetchange_meet=region_reltargetchange if region_targetmiss_prioryear==0
label variable region_reltargetchange_miss "regional manager met her target"
  
graph bar region_reltargetchange_meet region_reltargetchange_miss, over(region_targetmiss_py_subcount_r, relabel(1 "0%" 2 "12.50%" 3 "16.67%" 4 "25.00%" 5 "33.33%" 6 "37.50%" 7 "50.00%" 8 "62.50%" 9 "66.67%" 10 "75.00%" 11 "83.33%" 12 "87.50%" 13 "100%") label(labsize(small) angle(45)))  ytitle("relative change in regional manager's target", size(small)) b1title("proportion of failing subsidiary managers within the region", size(small)) legend(label(1 "successful regional managers") label(2 "failing regional managers") size(small)) ylabel(,labsize(small)) bar(1, color(black) lpattern(solid)) bar(2, color(white) lcolor(black) lpattern(dash))
 


 
 
  
		  