* Create a complete panel at the gvkey-calendar date level

use "review_licw_wrds_20161206.dta", clear

duplicates drop gvkey reviewdatetime, force
destring gvkey, replace
xtset gvkey reviewdatetime
keep gvkey reviewdatetime

tsfill

saveold "review_licw_wrds_comppanel_20161206.dta", version(12)
/* This file analyzed the frequency of employee reviews before and after rdq*/

global path ""
global data "${path}/Data"
global rawdata "${path}/Rawdata"



cap log close
log using "${path}/Program/01_Sample/09_SampleConstruction_20210114.log", replace

/***********************************************************************************/


/***********************************************************************************/
* Variable creation and sample selection
/***********************************************************************************/



use "${data}/Reviews20200424.dta", clear

destring gvkey, replace
sort gvkey rdq reviewdatetime

gen y=year(datadate)/*generate year and quarter data*/
gen year=year(datadate)/*generate year and quarter data*/
gen q=quarter(datadate)
gen m=month(datadate)
gen ym_rdq = mofd(rdq)
keep if reviewdatetime>=rdqlag1 + 6  









* Generate weekly sample

* Generate weeks relative to RDQ.
sort gvkey datadate reviewdatetime
gen dif1 = reviewdatetime-rdq
gen dif_w1 = -ceil((-dif1-1)/7)
// For example, if EA is 01.30.2016, then the EA weeks spans from 01.29.2016 to 02.04.2016.
// In this week, dif1 >=-1 & dif1 <=5, so dif_week1 = 0.
// The week before the EA week spans from 01.22.2016 to 01.28.2016.
// In this week, dif1 >=-8 & dif1 <=-2, so dif_week1 =-1. 


* Identify the first day of the week.
sort gvkey datadate dif_w1 reviewdatetime
by gvkey datadate dif_w1: gen nvals = reviewdatetime[1]
gen firstday = wofd(nvals+3)
drop nvals
format firstday %tw


* EA week
gen ea_week = dif_w1 ==0



* Keep entire week
sort gvkey datadate dif_w1 reviewdatetime
by gvkey datadate dif_w1 reviewdatetime: gen nvals=_n==1
by gvkey datadate dif_w1: egen nvals1= total(nvals)
keep if nvals1 == 7
drop nvals*

by gvkey datadate dif_w1: gen nvals = reviewdatetime[1]
replace reviewdatetime = nvals // identify the first day of each window
drop nvals*



* Keep relevant reviews
keep if (iscurrentjobflag==1) | fk_reviewid ==.  // current employees






* Variable constructions

******************************************
* Reviews related
******************************************

* Aggregate reviews
by gvkey datadate dif_w1: gen firstday1 = _n==1
by gvkey datadate dif_w1: egen _freq_review_current = total(!missing(fk_reviewid))
by gvkey datadate dif_w1: egen _freq_es_bo1_current = total(!missing(es_bo1))
by gvkey datadate dif_w1: egen _freq_es_wl3_current = total(!missing(es_wl3))

gen nvals = es_o1!=. & es_co3!=. & es_cb3!=. & es_em1!=. & es_sl3!=. & es_wl3!=. & es_cv1!=. & es_bo1!=. & es_ceo1!=.
by gvkey datadate dif_w1: egen _freq_all_current = total(nvals)
drop nvals

foreach var of varlist _freq_review_current _freq_es_bo1_current _freq_es_wl3_current _freq_all_current{
	sum `var' if firstday1==1,d
	replace `var' = r(p99) if `var' > r(p99) & `var' !=.
}



* Average reviews
foreach var of varlist es_o1 es_bo1 es_wl3 es_em1 es_co3 es_cb3 es_sl3 es_cv1 es_ceo1{
	bys gvkey datadate firstday: egen nvals = mean(`var')
	replace `var' = nvals
	drop nvals
}



preserve
keep if mofd(reviewdatetime)>=ym(2012,6) & mofd(reviewdatetime)<=ym(2016,8)
keep if ym_rdq>=ym(2012,6) & ym_rdq<=ym(2016,8) // restrict within a window for which we have reviews
duplicates drop fk_reviewid, force
keep if fk_reviewid !=.
count
restore



keep if firstday1 ==1
drop if missingrdq==1 | earlyrdq == 1 | laterdq == 1
keep if mofd(reviewdatetime)>=ym(2012,6) & mofd(reviewdatetime)<=ym(2016,8)
keep if ym_rdq>=ym(2012,6) & ym_rdq<=ym(2016,8) // restrict within a window for which we have reviews

gen sic2d=floor(sic/100)










**********************************************
* Obtain fiscal quarter
**********************************************

merge m:1 gvkey datadate using "${data}/FQTR.dta", nogen keep(1 3)
rename fyearq fyear

// Restrict to firms that file 10-k and 10-Q before deadlines for current and previous quarters
gen delta=rdq-datadate
keep if ( ( delta <=45 & fqtr<=3 ) | (delta <=90 & fqtr==4) )

bysort gvkey datadate: egen difw1_min=min(dif_w1)
keep if difw1_min <0 

// Distribution
by gvkey datadate: gen nvals=_n==1
sum difw1_min if nvals ==1 & fqtr ==4,d
sum difw1_min if nvals ==1 & fqtr <4,d

count if nvals ==1
count if nvals ==1 & difw1_min <= -8 & difw1_min >=-17
keep if difw1_min <= -8 & difw1_min >=-17
drop nvals











**********************************************
* New labor mobility measures by NAICS
**********************************************

cap drop nvals*

gen nvals = substr(naics, 1,2)
gen industry = nvals
replace industry = "31-33" if nvals == "31" | nvals == "32" | nvals == "33"
replace industry = "44-45" if nvals == "44" | nvals == "45"
replace industry = "48-49" if nvals == "48" | nvals == "49"
drop nvals

tab industry
gen yq = yq(year, q)
replace yq=yq // current quarter

preserve
use "${data}/j2j_turnover.dta", clear
gen yq=yq(year,quarter)
sort industry yq
keep industry yq j2j
save "${data}/tempjob_20200506.dta", replace
restore

merge m:1 industry yq using "${data}/tempjob_20200506.dta", nogen keep(1 3)











**********************************************
* Change in employees and growth opp
**********************************************

merge m:1 gvkey fyear using "${data}/tempchgemp.dta", keep(1 3) nogen
merge m:1 gvkey datadate using "${data}/growth_20210113.dta", nogen keep(1 3)















**********************************************
* Earnings surprise 
**********************************************

preserve
use "${data}/surprise_gvkey20200424.dta", clear
destring gvkey, replace
duplicates drop gvkey datadate, force
replace sue_ccm = sue_ccm*1000
sort gvkey datadate
gen year=year(datadate)
gen quarter=quarter(datadate)
keep gvkey datadate sue_ibes sue_ccm
save "${data}/tempsurprise_20200506.dta", replace
restore



sort gvkey datadate
merge m:1 gvkey datadate using "${data}/tempsurprise_20200506.dta", nogen keep(1 3)  // merge with earnings surprise data
















**********************************************
* Obtain TA
**********************************************
merge m:1 gvkey datadate using "${data}/fundq_lag.dta", nogen keep(1 3) keepusing(at_lag1)




********************************************************************************
* Obtain employees data: annual level
********************************************************************************
merge m:1 gvkey datadate using "${data}/employee_lag.dta", nogen keep(1 3) keepusing(emp_lag)
winsor2 emp_lag, cuts(1 99) replace










********************************************************************************
* Merge Ravenpack layoff dataset
********************************************************************************



merge m:1 gvkey reviewdatetime using "${data}/layoffs.dta", nogen keep(1 3)

sort gvkey datadate dif_w1 reviewdatetime
by gvkey datadate: egen _freq_layoff_qtr = sum(freq_layoff_day)
by gvkey datadate: egen _covered_byrpna_qtr = sum(covered_byrpna)

gen layoff=1 if _freq_layoff_qtr!=0
replace layoff=0 if _freq_layoff_qtr==0 & _covered_byrpna_qtr!=0





********************************************************************************
* Merge the geographical dispersion by firm year
********************************************************************************

preserve

use "${rawdata}/review_licw_wrds_20161206.dta", clear

gen year=year(reviewdatetime)
keep if (iscurrentjobflag==1) | fk_reviewid ==.  // current employees

destring gvkey, replace
foreach var of varlist fk_cityid fk_metroid fk_stateid fk_countryid{
	cap drop nvals*
	sort gvkey year `var'
	by gvkey year `var': gen nvals = _n==1
	replace nvals = . if `var' ==.
	by gvkey year: egen `var'_t=total(nvals)
	drop nvals*
}
keep gvkey year fk_cityid_t fk_metroid_t fk_stateid_t fk_countryid_t
duplicates drop gvkey year, force
sum fk_cityid_t fk_metroid_t fk_stateid_t fk_countryid_t

save "${data}/nstate.dta", replace

restore

merge m:1 gvkey year using "${data}/nstate.dta", nogen keep(1 3)











********************************************************************************
* Analyst revision
********************************************************************************

preserve

merge m:1 gvkey datadate using "${data}/revision20201020.dta", nogen keep(1 3) 
gen revision = earn_consensus_post-earn_consensus_pre

keep gvkey datadate revision
duplicates drop gvkey datadate, force
winsor2 revision, cuts(1 99) replace
drop if revision ==.

keep gvkey datadate revision 
sort gvkey datadate

save "${data}/temprev.dta", replace
restore

merge m:1 gvkey datadate using "${data}/temprev.dta", nogen keep(1 3) 




********************************************************************************
* EA order
********************************************************************************

preserve

sort gvkey datadate industry rdq *
by gvkey datadate: gen nvals = _n==1
keep if nvals ==1
drop nvals

// Generate number of firms accnouncing earnings within industry and datadate
sort industry datadate rdq
by industry datadate: gen totaln = _N 

sort gvkey datadate totaln
keep gvkey datadate totaln

save "${data}/tempeaorder.dta", replace

restore

merge m:1 gvkey datadate using "${data}/tempeaorder.dta", nogen keep(1 3)







**********************************************
* Merge in peer firm news
**********************************************

merge m:1 gvkey reviewdatetime using "${data}/review_surprise_20210113.dta", nogen keep(1 3)
merge m:1 gvkey reviewdatetime using "${data}/review_revision_20210114.dta", nogen keep(1 3)

replace sue_ccm_ind = sue_ccm_ind * 1000













****************************************
* Exclude positive reviews and negative earnings surprise. 
****************************************


preserve
use "${data}/Reviews20200424.dta", clear

destring gvkey, replace
sort gvkey rdq reviewdatetime

gen y=year(datadate)/*generate year and quarter data*/
gen year=year(datadate)/*generate year and quarter data*/
gen q=quarter(datadate)
gen m=month(datadate)
gen ym_rdq = mofd(rdq)
keep if reviewdatetime>=rdqlag1 + 6  

merge m:1 gvkey datadate using "${data}/tempsurprise_20200506.dta", nogen keep(1 3)  // merge with earnings surprise data


* Generate weekly sample
* Generate weeks relative to RDQ.
sort gvkey datadate reviewdatetime
gen dif1 = reviewdatetime-rdq
gen dif_w1 = -ceil((-dif1-1)/7)
// For example, if EA is 01.30.2016, then the EA weeks spans from 01.29.2016 to 02.04.2016.
// In this week, dif1 >=-1 & dif1 <=5, so dif_week1 = 0.
// The week before the EA week spans from 01.22.2016 to 01.28.2016.
// In this week, dif1 >=-8 & dif1 <=-2, so dif_week1 =-1. 


* Keep entire week
sort gvkey datadate dif_w1 reviewdatetime
by gvkey datadate dif_w1 reviewdatetime: gen nvals=_n==1
by gvkey datadate dif_w1: egen nvals1= total(nvals)
keep if nvals1 == 7
drop nvals*

by gvkey datadate dif_w1: gen nvals = reviewdatetime[1]
replace reviewdatetime = nvals // identify the first day of each window
drop nvals*


* Aggregate reviews
keep if (iscurrentjobflag==1) | fk_reviewid ==.  // current employees
drop if es_o1 == 5 & sue_ccm <0 & sue_ibes <0 
drop if es_bo1 == 5 & sue_ccm <0 & sue_ibes <0 


cap drop firstday1 // some cases where firstday1=1 might be dropped in the previous step
sort gvkey datadate dif_w1 reviewdatetime
by gvkey datadate dif_w1: gen firstday1 = _n==1

by gvkey datadate dif_w1: egen _freq_review_current1 = total(!missing(es_o1))
by gvkey datadate dif_w1: egen _freq_es_bo1_current1 = total(!missing(es_bo1))
foreach var of varlist _freq_review_current1 _freq_es_bo1_current1{
	sum `var' if firstday1==1,d
	replace `var' = r(p99) if `var' > r(p99) & `var' !=.
}

keep if firstday1 ==1
drop if missingrdq==1 | earlyrdq == 1 | laterdq == 1
keep if mofd(reviewdatetime)>=ym(2012,6) & mofd(reviewdatetime)<=ym(2016,8)
keep if ym_rdq>=ym(2012,6) & ym_rdq<=ym(2016,8) // restrict within a window for which we have reviews

keep gvkey datadate dif_w1 _freq_review_current1 _freq_es_bo1_current1

save "${data}/tempfreq.dta", replace
restore


merge 1:1 gvkey datadate dif_w1 using "${data}/tempfreq.dta", keep(1 3) nogen
replace _freq_review_current1=0 if _freq_review_current1==.
replace _freq_es_bo1_current1=0 if _freq_es_bo1_current1==.














****************************************
* Exclude large changes in reviews
****************************************

preserve

* Compute large review changes relative to firm avedrage
keep if dif_w1 <=0
sort gvkey datadate

by gvkey: egen m_freq_review_current = mean(_freq_review_current)
gen _frac_freq_review_current = _freq_review_current/m_freq_review_current

sum _frac_freq_review_current if _frac_freq_review_current>0, d
gen largefreq = _frac_freq_review_current >= r(p95) & _frac_freq_review_current  !=.

by gvkey datadate: egen largefreqfirmq = mean(largefreq)
replace largefreqfirmq = 1 if largefreqfirmq >0 & largefreqfirmq !=.
replace largefreqfirmq = 0 if largefreqfirmq !=1
sum large*

keep gvkey datadate dif_w1 largefreq largefreqfirmq _frac_freq_review_current

save "${data}/templarge.dta", replace
restore


merge m:1 gvkey datadate dif_w1 using "${data}/templarge.dta", nogen keep(1 3)







****************************************
* Add media tone
****************************************

merge m:1 gvkey reviewdatetime using "${data}/review_media_20210113.dta", nogen keep(1 3)

preserve
keep if ea_week ==1
keep gvkey datadate mcq ess
save "${data}/temp_review_media.dta", replace
restore

drop mcq ess
merge m:1 gvkey datadate using "${data}/temp_review_media.dta", nogen keep(1 3)
sum mcq mcq_ind ess ess_ind


saveold "${data}/regsample_week20210114.dta", replace version(12) 
// shell rm "${data}/temp"*

log close
