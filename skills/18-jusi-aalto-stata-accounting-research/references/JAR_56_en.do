********************************************************************************************************************************************
*
*  Performance Effects of Setting a High Reference Point for Peer-Performance Comparison
*
*  Henry Eyring and V.G. Narayanan
*
*  Code for descriptive statistics and tests in Main Experiment
*  Data are confidential and provided by HarvardX
*
********************************************************************************************************************************************

use "/Users/eyring/Documents/Spring '16/2017 JAR Hx/Sep 2017 Submission/Data and Code/activity level exper data.dta", replace

************


*** Name partitions and winsorize

gen low = ((ph_x==1 & activity<=14) | (ph_x==2 & activity<=13) | (ph_x==3 & activity<=10))
gen med = ((ph_x==1 & activity>14 & activity<=55) | (ph_x==2 & activity>13 & activity<=77) | (ph_x==3 & activity>10 & activity<=52))
gen high = ((ph_x==1 & activity>55) | (ph_x==2 & activity>77) | (ph_x==3 & activity>52))
gen interact_med = type_75*med

gen activity_wd = activity_d
replace activity_wd = 361 if activity_d>361 & ph1==1 & activity_d!=.
replace activity_wd = 327 if activity_d>327 & ph1!=1 & activity_d!=.
replace activity_wd = 2170 if ph3==1 & activity_d>=2170 & activity_d!=.

gen activity_new_winz = activity_new
replace activity_new_w=1363 if activity_new>1363 & activity_new!=.
replace activity_new_w=868 if activity_new>868 & activity_new!=.
replace activity_new_w=2151 if activity_new>2151 & activity_new!=. 

***	Hypothesis Tests - Table OA8
**H1

reg activity_wd treated i.ph1 i.ph2, cluster(email)

**H2

reg activity_wd type_75 i.ph1 i.ph2 if med==1 & treated==1, cluster(email)
reg activity_wd type_75 i.ph1 i.ph2 if low==1 & treated==1, cluster(email)
reg activity_wd type_75 i.ph1 i.ph2 if high==1 & treated==1, cluster(email)

**Bayes Factor for H2C
*bayesmh activity_wd i.ph1 i.ph2 type_75 if high==1, likelihood(normal({var})) prior({activity_wd: type_75}, normal(0, {var})) prior({activity_wd: i.ph1 i.ph2 _cons}, flat) prior({var}, jeffreys) saving(bayes_h3c_prior)
*eststo bayes_h2c_prior 

*bayesmh activity_wd i.ph1 i.ph2 type_75 if high==1, likelihood(normal({var})) prior({activity_wd: type_75}, normal(-6.98, 4.25)) prior({activity_wd: i.ph1 i.ph2 _cons}, flat) prior({var}, jeffreys) saving(bayes_h3c_post)
*eststo bayes_h2c_post

*bayesstats ic bayes_h2c_prior bayes_h2c_post, bayesfactor

**H3

reg activity_wd type_75 med interact_med i.ph1 i.ph2 if treated==1, cluster(email)
reg activity_wd type_75 med interact_med i.ph1 i.ph2 if treated==1 & (med==1 | low==1), cluster(email)
reg activity_wd type_75 med interact_med i.ph1 i.ph2 if treated==1 & (med==1 | high==1), cluster(email)

**Overall

reg activity_wd type_75 i.ph1 i.ph2 if treated==1, cluster(email)

**Bayes Factor for Overall
*bayesmh activity_wd type_75 i.ph1 i.ph2 if treated==1, likelihood(normal({var})) prior({activity_wd: type_75}, normal(0, {var})) prior({activity_wd: i.ph1 i.ph2 _cons}, flat) prior({var}, jeffreys) saving(bayes_h4_prior)
*eststo bayes_h4_prior
*bayesmh activity_wd type_75 i.ph1 i.ph2 if treated==1, likelihood(normal({var})) prior({activity_wd: type_75}, normal(-2.11, 1.63)) prior({activity_wd: i.ph1 i.ph2 _cons}, flat) prior({var}, jeffreys) saving(bayes_h4_post)
*eststo bayes_h4_post
*bayesstats ic bayes_h4_prior bayes_h4_post


*** Graph access - Table 3
gen accessed = count!=.
gen treat_assign = 1 if ctrl==1
replace treat_assign = 2 if type_50==1
replace treat_assign = 3 if type_75==1
tab count treat_assign


*** Cell means - Tables OA5, 5, and 7
gen bin = 1 if ctrl_low ==1
replace bin = 2 if ctrl_med==1
replace bin = 3 if ctrl_high ==1
replace bin = 4 if low ==1 & type_50==1
replace bin = 7 if low ==1 & type_75==1
replace bin = 5 if med ==1 & type_50==1
replace bin = 8 if med ==1 & type_75==1
replace bin = 6 if high ==1 & type_50==1
replace bin = 9 if high ==1 & type_75==1
gen ph_cat = 1 if ph1==1
replace ph_cat = 2 if ph2==1
replace ph_cat = 3 if ph3==1
reg activity_wd ibn.bin, cluster(email) nocons

**F tests
gen bin_treat = 1 if (bin==1 | bin==2 | bin==3)
replace bin_treat = 2 if (bin==4 | bin==5 | bin==6 | bin==7 | bin==8 | bin==9)
gen bin_type = 1 if (bin==4 | bin==5 | bin==6)
replace bin_type = 2 if (bin==7 | bin==8 | bin==9)
reg activity_wd i.ph_cat ibn.bin_treat, cluster(email) nocons
test 1.bin_treat = 2.bin_treat
reg activity_wd i.ph_cat ibn.bin if (bin==4|bin==7), cluster(email) nocons
test 4.bin = 7.bin
reg activity_wd i.ph_cat ibn.bin if (bin==5|bin==8), cluster(email) nocons
test 5.bin = 8.bin
reg activity_wd i.ph_cat ibn.bin if (bin==6|bin==9), cluster(email) nocons
test 6.bin = 9.bin
reg activity_wd i.ph_cat ibn.bin_type if (bin_type==1 | bin_type==2), cluster(email) nocons
test 1.bin_type = 2.bin_type

**Chi-square tests
gen inner_med = bin==5
gen inner_top = bin==8
gen outer_med = (bin==4 | bin==6)
gen outer_top = (bin==7 | bin==9)
gen low_med = bin==4
gen low_top = bin==7
gen high_top = bin==9
gen high_med = bin==6


est clear 
reg activity_wd i.ph_cat outer_top if (outer_top==1 | outer_med==1)
est store outer
reg activity_wd i.ph_cat inner_top if (inner_top==1 | inner_med==1)
est store inner
suest outer inner, cluster(email)
test [outer_mean]outer_top = [inner_mean]inner_top

est clear 
reg activity_wd i.ph_cat inner_top if (inner_top==1 | inner_med==1)
est store inner_top
reg activity_wd i.ph_cat low_top if (low_top==1 | low_med==1)
est store low_top
suest low_top inner_top, cluster(email)
test [low_top_mean]low_top = [inner_top_mean]inner_top

est clear
reg activity_wd i.ph_cat high_top if (high_top==1 | high_med==1)
est store high_top
reg activity_wd i.ph_cat inner_top if (inner_top==1 | inner_med==1)
est store inner_top
suest inner_top high_top
test [inner_top_mean]inner_top = [high_top_mean]high_top

***Interest and Confidence Survey Analysis - Table 9

**code responses
gen c_median_interest = 1 if median_interest=="no"
replace c_median_interest = 2 if median_interest=="somewhat"
replace c_median_interest = 3 if median_interest=="yes"
gen c_topq_interest = 1 if topq_interest=="no"
replace c_topq_interest = 2 if topq_interest=="somewhat"
replace c_topq_interest = 3 if topq_interest=="yes"
gen c_median_import = 1 if median_import=="not at all important"
replace c_median_import = 2 if median_import=="somewhat important"
replace c_median_import = 3 if median_import=="important"
gen c_topq_import = 1 if topq_import=="not at all important"
replace c_topq_import = 2 if topq_import=="somewhat important"
replace c_topq_import = 3 if topq_import=="important"
gen c_median_confidence = 1 if median_conf=="not at all confident"
replace c_median_confidence = 2 if median_conf=="somewhat confident"
replace c_median_confidence = 3 if median_conf=="confident"
gen c_topq_confidence = 1 if topq_conf=="not at all confident"
replace c_topq_confidence = 2 if topq_conf=="somewhat confident"
replace c_topq_confidence = 3 if topq_conf=="confident"

**Wilcoxon Signed Rank Tests
signrank c_median_interest=c_topq_interest
signrank c_median_import=c_topq_import
signrank c_median_conf=c_topq_conf 

*** Demographic moderators (cross-sectional variation tests) - Table OA10

gen interact_gender = gender_c*treated
gen interact_loe = loe_c*treated
gen interact_age = age*treated
gen interact_dev = developed*treated
gen interact_activity = activity*treated
gen type_75_gender = gender_c*type_75
gen type_75_dev = developed*type_75
gen type_75_activity = activity*type_75
gen type_75_age = age*type_75
gen type_75_loe = loe_c*type_75

reg activity_wd treated gender_c developed age loe_c activity interact_gender interact_dev interact_loe interact_age interact_ac, cluster(email)
reg activity_wd type_75 gender_c developed age loe_c activity type_75_gender type_75_dev type_75_loe type_75_age type_75_ac if (low==1 | med==1 | high==1) & treated==1, cluster(email)


*** LATE - Table OA11

**H1

ivreg activity_wd (accessed = treated) ph1 ph2, cluster(email)

**H2

reg activity_wd type_75 i.ph1 i.ph2 if med==1 & accessed==1, cluster(email)
reg activity_wd type_75 i.ph1 i.ph2 if low==1 & accessed==1, cluster(email)
reg activity_wd type_75 i.ph1 i.ph2 if high==1 & accessed==1, cluster(email)

**H3

reg activity_wd type_75 med interact_med i.ph1 i.ph2 if (med==1 | low==1 | high==1) & accessed==1, cluster(email)
reg activity_wd type_75 med interact_med i.ph1 i.ph2 if (med==1 | low==1) & accessed==1, cluster(email)
reg activity_wd type_75 med interact_med i.ph1 i.ph2 if (med==1 | high==1) & accessed==1, cluster(email)

**Overall

reg activity_wd type_75 i.ph1 i.ph2 if (low==1 | med==1 | high==1) & accessed==1, cluster(email)


************

********************************************************************************************************************************************
*
*
*  Code for descriptive statistics and tests in Supplemental Experiment
*
********************************************************************************************************************************************

use "/Users/eyring/Documents/Spring '16/2017 JAR Hx/Sep 2017 Submission/Data and Code/grade exper data.dta", replace

************


***	Name partitions

gen low = grade_o<20
gen med = grade_o>19 & grade_o<41 
gen high = grade_o>40

gen interact_med = type_75*med


*** Hypothesis Tests - Table OA7
**H1

reg grade_diff treated, robust

**H2

reg grade_diff type_75 if treated==1 & grade_o<20, robust

reg grade_diff type_75 if treated==1 & grade_o>19 & grade_o<41, robust

reg grade_diff type_75 if treated==1 & grade_o>40, robust

**H3

reg grade_diff interact_med type_75 med if treated==1, robust

reg grade_diff interact_med type_75 med if treated==1 & grade_o<41, robust

reg grade_diff interact_med type_75 med if treated==1 & grade_o>20, robust

**Overall

reg grade_diff type_75 if treated==1, robust


*Bayes for H3C
*bayesmh grade_diff interact_med type_75 med if treated==1 & grade_o>20, likelihood(normal({var})) prior({grade_diff: interact_med}, normal(0, {var})) prior({grade_diff: type_75 med _cons}, flat) prior({var}, jeffreys) saving(bayes_grade_h3c_prior)
*eststo bayes_grade_h3c_prior
*bayesmh grade_diff interact_med type_75 med if treated==1 & grade_o>20, likelihood(normal({var})) prior({grade_diff: interact_med}, normal(-.051, 1.101)) prior({grade_diff: type_75 med _cons}, flat) prior({var}, jeffreys) saving(bayes_grade_h3c_post)
*eststo bayes_grade_h3c_post
*bayesstats ic bayes_grade_h3c_prior bayes_grade_h3c_post


*Bayes for H4
*bayesmh grade_diff type_75 if treated==1, likelihood(normal({var})) prior({grade_diff: type_75}, normal(0, {var})) prior({grade_diff: _cons}, flat) prior({var}, jeffreys) saving(bayes_grade_h4_prior)
*eststo bayes_grade_h4_prior
*bayesmh grade_diff type_75 if treated==1, likelihood(normal({var})) prior({grade_diff: type_75}, normal(-.257, .556)) prior({grade_diff: _cons}, flat) prior({var}, jeffreys) saving(bayes_grade_h4_post)
*eststo bayes_grade_h4_post
*bayesstats ic bayes_grade_h4_prior bayes_grade_h4_post


*** Graph access - Table 4
gen accessed = count!=.
gen treat_assign = 1 if ctrl==1
replace treat_assign = 2 if type_50==1
replace treat_assign = 3 if type_75==1
tab count treat_assign


*** Problem-attempt quantity and accuracy - Table OA9
gen nproblem_check_diff = nproblem_check - nproblem_check_orig
gen ans_diff = ans_tot - ans_tot_orig
reg ans_diff treated, robust
gen ans_diff_over_nprob_check_diff = ans_diff/nproblem_check_diff
reg ans_diff_over treated, robust
gen npcd_w = nproblem_check_diff
replace npcd_w = 244 if nproblem_check_diff>244
gen nproblem_check_w = nproblem_check
replace nproblem_check_w = 624 if nproblem_check>=624
reg npcd_w treated, robust


***	Cell means - Tables OA6, 6, and 8
gen control = treated==0
gen ctrl_low = control*low
gen ctrl_med = control*med
gen ctrl_high = control*high
gen bin = 1 if ctrl_low ==1
replace bin = 2 if ctrl_med==1
replace bin = 3 if ctrl_high ==1
replace bin = 4 if low ==1 & type_50==1
replace bin = 7 if low ==1 & type_75==1
replace bin = 5 if med ==1 & type_50==1
replace bin = 8 if med ==1 & type_75==1
replace bin = 6 if high ==1 & type_50==1
replace bin = 9 if high ==1 & type_75==1
reg grade_diff ibn.bin, robust noconstant
estat vce

**F tests
gen bin_treat = 1 if (bin==1 | bin==2 | bin==3)
replace bin_treat = 2 if (bin==4 | bin==5 | bin==6 | bin==7 | bin==8 | bin==9)
gen bin_type = 1 if (bin==4 | bin==5 | bin==6)
replace bin_type = 2 if (bin==7 | bin==8 | bin==9)
reg grade_diff ibn.bin_treat, cluster(email) nocons
test 1.bin_treat = 2.bin_treat
reg grade_diff ibn.bin if (bin==4|bin==7), cluster(email) nocons
test 4.bin = 7.bin
reg grade_diff ibn.bin if (bin==5|bin==8), cluster(email) nocons
test 5.bin = 8.bin
reg grade_diff ibn.bin if (bin==6|bin==9), cluster(email) nocons
test 6.bin = 9.bin
reg grade_diff ibn.bin_type if (bin_type==1 | bin_type==2), cluster(email) nocons
test 1.bin_type = 2.bin_type


**Chi-square tests
gen inner_med = bin==5
gen inner_top = bin==8
gen outer_med = (bin==4 | bin==6)
gen outer_top = (bin==7 | bin==9)
gen low_med = bin==4
gen low_top = bin==7
gen high_top = bin==9
gen high_med = bin==6


est clear 
reg grade_diff outer_top if (outer_top==1 | outer_med==1)
est store outer
reg grade_diff inner_top if (inner_top==1 | inner_med==1)
est store inner
suest outer inner, cluster(email)
test [outer_mean]outer_top = [inner_mean]inner_top

est clear 
reg grade_diff inner_top if (inner_top==1 | inner_med==1)
est store inner_top
reg grade_diff low_top if (low_top==1 | low_med==1)
est store low_top
suest low_top inner_top, cluster(email)
test [low_top_mean]low_top = [inner_top_mean]inner_top

est clear
reg grade_diff high_top if (high_top==1 | high_med==1)
est store high_top
reg grade_diff inner_top if (inner_top==1 | inner_med==1)
est store inner_top
suest inner_top high_top
test [inner_top_mean]inner_top = [high_top_mean]high_top

***Interest and Confidence Survey Analysis - Table 10

**code responses
gen c_median_interest = 1 if median_interest=="no"
replace c_median_interest = 2 if median_interest=="somewhat"
replace c_median_interest = 3 if median_interest=="yes"
gen c_topq_interest = 1 if topq_interest=="no"
replace c_topq_interest = 2 if topq_interest=="somewhat"
replace c_topq_interest = 3 if topq_interest=="yes"
gen c_median_import = 1 if median_import=="not at all important"
replace c_median_import = 2 if median_import=="somewhat important"
replace c_median_import = 3 if median_import=="important"
gen c_topq_import = 1 if topq_import=="not at all important"
replace c_topq_import = 2 if topq_import=="somewhat important"
replace c_topq_import = 3 if topq_import=="important"
gen c_median_confidence = 1 if median_conf=="not at all confident"
replace c_median_confidence = 2 if median_conf=="somewhat confident"
replace c_median_confidence = 3 if median_conf=="confident"
gen c_topq_confidence = 1 if topq_conf=="not at all confident"
replace c_topq_confidence = 2 if topq_conf=="somewhat confident"
replace c_topq_confidence = 3 if topq_conf=="confident"

**Wilcoxon Signed Rank Tests
signrank c_median_interest=c_topq_interest
signrank c_median_import=c_topq_import
signrank c_median_conf=c_topq_conf 

***	Demographic moderators (cross-sectional variation tests) - Table OA10

gen interact_gender = gender_c*treated
gen interact_dev = developed*treated
gen interact_gradeo = grade_o*treated
gen type_75_gender = gender_c*type_75
gen type_75_dev = developed*type_75
gen type_75_gradeo = grade_o*type_75
gen interact_loe = loe_c*treated
gen interact_age = age*treated
gen type_75_age = age*type_75
gen type_75_loe = loe_c*type_75
reg grade_diff type_75 gender_c developed grade_o type_75_gender type_75_dev type_75_grade if treated==1, robust
reg grade_diff type_75 gender_c developed age loe_c grade_o type_75_gender type_75_dev type_75_loe type_75_age type_75_grade if treated==1, robust
reg grade_diff treated gender_c developed age loe_c grade_o interact_gender interact_dev interact_loe interact_age interact_grade, robust


***	LATE - Table OA12
**H1

ivreg grade_diff (accessed = treated), robust

**H2

reg grade_diff type_75 if treated==1 & grade_o<20 & accessed==1, robust

reg grade_diff type_75 if treated==1 & grade_o>19 & grade_o<41 & accessed==1, robust

reg grade_diff type_75 if treated==1 & grade_o>40 & accessed==1, robust

**H3

reg grade_diff interact_med type_75 med if treated==1 & accessed==1, robust

reg grade_diff interact_med type_75 med if treated==1 & grade_o<41 & accessed==1, robust

reg grade_diff interact_med type_75 med if treated==1 & grade_o>20 & accessed==1, robust

**Overall

reg grade_diff type_75 if treated==1 & accessed==1, robust

************
* ********************************************************************************
* ********************************************************************************
* Attendance
* ********************************************************************************
* ********************************************************************************
* author: Kyle Thomas
* modified by: Tatiana Sandino 
* date: February 14, 2017
* purpose: compute weekly attendance promoter data
* ********************************************************************************
* Inputs: B. Data Preparation/02. Attendance Data/input
* Outputs: B. Data Preparation/02. Attendance Data/output
* Steps:
* 1. Read and Merge Data
* 2. Generate weekly unique promoters on store-brand level
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\02. Attendance Data\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\02. Attendance Data\output"

* ********************************************************************************
* 1. Read and Merge Data
* ********************************************************************************

	* local for each sheet
		local months jan-2017 dec-2016 nov-2016 oct-2016 sep-2016 aug-2016 jul-2016 jun-2016 may-2016

	* import 
		foreach i in `months'{
			import excel "T:\Data Prep and Analyses\B. Data Preparation\02. Attendance Data\input\attendance_work.xlsx", sheet("`i'") firstrow clear
			save `i', replace
		}
		
	* combine data
		qui foreach x in `months'{
			append using `x', force
		}

* ********************************************************************************
* 2. Generate Weekly Measures
* ********************************************************************************

	*format date
		gen week = wofd(date)
		format week %tw

	* fix brands 
		replace brand = lower(brand)
		**fix brand name related typos
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* redefine shop for promoters that were misidentified (confirmed with MPR)
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
	* drop locations not in experiment
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	/*Adjustments to exclude one-time promoter visits to stores 
	for induction or training, and to fix misspellings leading to
	double-counting promoters (TATIANA CHANGE)*/
	
		* before counting names, fix misspelled names (when caught) and 
		* make all names lower case 
		
			* fix misspelled names 
				*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				*redacted
				*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			
			* make all names lower case
				replace name=lower(name)
			
		* exclude promoters that did not last more than 7 days at the company
			bysort brand name: egen GM_totaldays=nvals(date)
			drop if GM_totaldays<=7
			*2,483 out of 111,171 observations were excluded
			
		* exclude promoters visiting a shop only occassionally
			gen month=mofd(date)
			format month %tm

			bysort shop brand month name: egen visitshopmonth=nvals(date)
			bysort shop brand name: egen maxvisitshopmonth=max(visitshopmonth)
			bysort shop brand name: egen visitshoptotal=nvals(date)
			
			gen pctvisitshop=visitshoptotal/GM_totaldays
			
			drop if (visitshopmonth<=2)
		
	/*End of adjustments to exclude exceptional promoter visits to stores*/
	
	* generate number of unique promoters per shop-brand-week
		bysort shop week brand : egen n_promoters = nvals(name)

		drop GM_totaldays month visitshopmonth maxvisitshopmonth visitshoptotal pctvisitshop
		
	* generate count to be summed
		gen count = 1

	* drop duplicate day entries
		duplicates drop shop brand name date, force

	save "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\output\attendance_name", replace

	* save data 
		save attendance_name, replace

	* generate count
		collapse (sum) count (mean) n_promoters, by(shop week brand)

	* generate attendance variable
		gen attendance = count/n_promoters

	*replace to zero if  brand = corporate brand
		replace brand = "corporate brand" if brand == "corporate"
		replace count = 0 if brand == "corporate brand"
		replace n_promoters = 0 if brand == "corporate brand"
		replace attendance = 0 if brand == "corporate brand"

	* save data
		save "T:\Data Prep and Analyses\C. Master Dataset\input\attendance_count", replace

***************************************************************************************
	* end log
		log close


