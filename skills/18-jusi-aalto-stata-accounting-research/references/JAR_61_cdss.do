* Set key macros for the Stata program:
set more off, permanently
local file "D:\Pay Ratio\Stata Files"

use "`file'\Stata Table_UnexpComp_CEO.dta", clear

encode gvkey, gen (gvkey_num)
tsset gvkey_num fyear

drop if fyear<=2005
drop if total_sec>=.

* Transform CEO pay into raw form to match with employee pay
gen ln_total_sec = log(1+total_sec*1000) 
gen total_sec_cpi = total_sec/cpi_annual
gen ln_tenure = log(tenureyrs)
gen ln_age = log(age) 
replace sic2 = 99 if sic2>=.

* Loop through each fiscal year to estimate model; 
levels fyear, local(gr)
qui foreach j of local gr {

* Run and store expected values + residuals 
areg ln_total_sec lnat adjroa adjroa_std ln_tenure ln_age retfy lag_retfy sigma loss bm lev if fyear==`j', absorb(sic2) 
predict ceopay_pred_`j'
	continue
}

gen ceopay_pred = ceopay_pred_2006 if fyear==2006
replace ceopay_pred = ceopay_pred_2007 if fyear==2007
replace ceopay_pred = ceopay_pred_2008 if fyear==2008
replace ceopay_pred = ceopay_pred_2009 if fyear==2009
replace ceopay_pred = ceopay_pred_2010 if fyear==2010
replace ceopay_pred = ceopay_pred_2011 if fyear==2011
replace ceopay_pred = ceopay_pred_2012 if fyear==2012
replace ceopay_pred = ceopay_pred_2013 if fyear==2013
replace ceopay_pred = ceopay_pred_2014 if fyear==2014
replace ceopay_pred = ceopay_pred_2015 if fyear==2015
replace ceopay_pred = ceopay_pred_2016 if fyear==2016
replace ceopay_pred = ceopay_pred_2017 if fyear==2017
replace ceopay_pred = ceopay_pred_2018 if fyear==2018
replace ceopay_pred = ceopay_pred_2019 if fyear==2019
gen ceopay_unexp = ln_total_sec-ceopay_pred
gen lag3avg_ceopay_unexp = l3.ceopay_unexp+l2.ceopay_unexp+l1.ceopay_unexp/3 if l3.ceopay_unexp<. & l2.ceopay_unexp<. & l1.ceopay_unexp<.
replace lag3avg_ceopay_unexp = l3.ceopay_unexp+l2.ceopay_unexp/2 if l3.ceopay_unexp<. & l2.ceopay_unexp<. & l1.ceopay_unexp>=.
replace lag3avg_ceopay_unexp = l3.ceopay_unexp+l1.ceopay_unexp/2 if l3.ceopay_unexp<. & l2.ceopay_unexp>=. & l1.ceopay_unexp<.
replace lag3avg_ceopay_unexp = l2.ceopay_unexp+l1.ceopay_unexp/2 if l3.ceopay_unexp>=. & l2.ceopay_unexp<. & l1.ceopay_unexp<.

gen lag3avg_total_sec_cpi = l3.total_sec_cpi+l2.total_sec_cpi+l1.total_sec_cpi/3 if l3.total_sec_cpi<. & l2.total_sec_cpi<. & l1.total_sec_cpi<.
replace lag3avg_total_sec_cpi = l3.total_sec_cpi+l2.total_sec_cpi/2 if l3.total_sec_cpi<. & l2.total_sec_cpi<. & l1.total_sec_cpi>=.
replace lag3avg_total_sec_cpi = l3.total_sec_cpi+l1.total_sec_cpi/2 if l3.total_sec_cpi<. & l2.total_sec_cpi>=. & l1.total_sec_cpi<.
replace lag3avg_total_sec_cpi = l2.total_sec_cpi+l1.total_sec_cpi/2 if l3.total_sec_cpi>=. & l2.total_sec_cpi<. & l1.total_sec_cpi<.

* Output file for join to full panel data in SAS
saveold "`file'/Stata Table_UnexpComp_CEO_OUTPUT.dta", replace version(11)
* Set key macros for the Stata program:
set more off, permanently
local file "D:\Pay Ratio\Stata Files"

use "`file'\Stata Table_UnexpPR_OLD.dta", clear

encode gvkey, gen (gvkey_num)
tsset gvkey_num fyear

* Transform CEO pay into raw form to match with employee pay
gen ln_total_sec = log(1+total_sec*1000) 
gen ln_med_emp_pay = log(employee_median_pay)
gen ln_tenure = log(tenureyrs)
gen ln_age = log(age) 
replace sic2 = 99 if sic2>=.

* Run and store expected values + residuals 
areg ln_total_sec lnat adjroa adjroa_std ln_tenure ln_age retfy lag_retfy sigma loss bm lev, absorb(sic2) 
predict ceopay_pred
gen ceopay_unexp = ln_total_sec - ceopay_pred 
scatter ln_total_sec ceopay_pred
areg ln_med_emp_pay adjrnoa adjrnoa_std collegegradpct indregioncomp righttowork csale crspage empprod capex rd_sale, absorb(sic2) 
predict emppay_pred
gen emppay_unexp = ln_med_emp_pay - emppay_pred 
scatter ln_med_emp_pay emppay_pred
* Industry adjusted employee pay (omitting remaining controls)
areg ln_med_emp_pay, absorb(sic2) 
predict emppay_indfe
gen emppay_indadj = ln_med_emp_pay - emppay_indfe 

* Output file for join to full panel data in SAS
saveold "`file'/Stata Table_UnexpPR_OUTPUT.dta", replace version(11)
