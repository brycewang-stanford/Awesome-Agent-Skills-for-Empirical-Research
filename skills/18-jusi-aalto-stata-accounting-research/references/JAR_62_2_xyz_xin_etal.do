
clear
set more off
set mat 5000
cd "D:\Dropbox\Research\XYZ_MutualFundWindowDressing\data"

use "finalsam",clear
	keep wficn year yrqtr rdate treat wd80_v3 wd3 wd60_v3 wd80_v1 wd170_v3 pumpvw1 delayperiod1 size alpha30 alpha91 alpha182 flow_p3 flow_p6 turnover tcost exp age load amdm anam abret_f3 abret_f6 abret_f9 flow_f3 flow_f6 flow_f9 

	local wd "wd80_v3 wd3 wd60_v3 wd80_v1 wd170_v3 " 
	foreach v in `wd' pumpvw1 alpha* {
		replace `v'=`v'*100
	}
	gen post=0
	replace post=1 if yrqtr>200402
	gen treatpost=treat*post
	
	tempfile all
save `all'	


*************************************************************************************
*																					*
*			Tables 1, 2, 3, 8 (Panel A), 9, and 10 (Panels A & B)					*
*																					*
*************************************************************************************

*~~~~~~~~~~~~~~~~~~~~~~~ Quarterly Intervals ~~~~~~~~~~~~~~~~~~~~~~~ 
	keep if year>=2001 & year<=2007
	
	preserve
	
	*Classify high-, low-skill groups
	gen skill_1=(alpha91) if yrqtr==200304
	bys wficn: egen skill_pre1=mean(skill_1)
	
	xtile skill_q=skill_pre1, nq(2)
	gen skill_h=(skill_q==2)
	gen skill_l=(skill_q==1)
	drop if skill_h~=1 & skill_l~=1
	
	local contr_q "size alpha30 alpha91 flow_p3 turnover tcost exp age load amdm anam" 
	
	gen delayperiod=log(delayperiod1)
	
	foreach v in wd80_v3 `contr_q'{
		drop if missing(`v')
	}
	winsor2 wd80_v3 wd3 pumpvw1 delayperiod1 size alpha30 alpha91 flow_p3 turnover tcost exp age load amdm anam, c(1 99) replace 

	
****Table 1: Summary statistics
	eststo clear
	eststo: qui estpost tabstat wd80_v3 wd3 delayperiod pumpvw1 `contr_q', statistics(n mean sd p10 p25 p50 p75 p90) columns(statistics)
	eststo: qui estpost tabstat wd80_v3 wd3 delayperiod pumpvw1 `contr_q' if treat==1 & post==0, statistics(n mean p25 p50 p75 ) columns(statistics)
	eststo: qui estpost tabstat wd80_v3 wd3 delayperiod pumpvw1 `contr_q' if treat==0 & post==0, statistics(n mean p25 p50 p75 ) columns(statistics)
	eststo: qui estpost tabstat wd80_v3 wd3 delayperiod pumpvw1 `contr_q' if treat==1 & post==1, statistics(n mean p25 p50 p75 ) columns(statistics)
	eststo: qui estpost tabstat wd80_v3 wd3 delayperiod pumpvw1 `contr_q' if treat==0 & post==1, statistics(n mean p25 p50 p75 ) columns(statistics)
	esttab est* , replace  cells("count(lab(N)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))")  nostar nonumbers noobs label unstack title(Summary Statistics) 
	

****Table 2: Baseline
	eststo clear
	eststo: quiet xi: reghdfe wd80_v3 treatpost `contr_q' , absorb(wficn yrqtr) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe wd3 	  treatpost `contr_q' , absorb(wficn yrqtr) keepsing cluster(wficn) 
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(treatpost `contr_q') label legend  title(Baseline) nogaps 
	
****Table 3: By skill group
	foreach v in wd80_v3 wd3 {
	eststo clear
	eststo: quiet xi: reghdfe `v' treatpost `contr_q' if skill_l==0, absorb(wficn yrqtr) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe `v' treatpost `contr_q' if skill_l==1, absorb(wficn yrqtr) keepsing cluster(wficn) 
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) label legend  title(By skill subsamples) nogaps 
	}
	restore
	
	
*~~~~~~~~~~~~~~~~~~~~~~~ Semiannual Intervals ~~~~~~~~~~~~~~~~~~~~~~~
	gen h = hofd(rdate)	
	format h %th
	
	collapse (sum)wd80_v3 wd3 wd60_v3 wd80_v1 pumpvw1 delayperiod1 (mean)alpha30 (max)rdate (count)n=year, by(wficn h)
	gen delayperiod=log(delayperiod1)
	tempfile semi
	save `semi'

	use `all'
	drop wd80_v3 wd3 wd60_v3 wd80_v1 pump* delay* alpha30
	merge 1:1 wficn rdate using `semi', keep(match) nogen 

	*Classify high-, low-skill groups
	gen skill_1=(alpha182) if yrqtr==200304
	bys wficn: egen skill_pre1=mean(skill_1)
	
	xtile skill_q=skill_pre1, nq(2)
	gen skill_h=(skill_q==2)
	gen skill_l=(skill_q==1)
	drop if skill_h~=1 & skill_l~=1

	local contr_h "size alpha30 alpha182 flow_p6 turnover tcost exp age load amdm anam" 
	foreach v in `contr_h' {
		drop if `v'==.
	}

	replace wd3=wd6 if treat==1 & post==0
	replace wd80_v3=wd170_v3 if treat==1 & post==0

	gen bhrg_10pct=0
	gen bhrg_20pct=0
	xtile wdq=wd3 , nq(10)
	replace bhrg_10pct=(wdq>9)
	replace bhrg_20pct=(wdq>8)

	winsor2 wd80_v3 wd3 wd60_v3 wd80_v1 wd170_v3 pumpvw1 delayperiod `contr_h', c(1 99) replace 

	
****Table 2: Baseline
	eststo clear
	eststo: quiet xi: reghdfe wd80_v3 treatpost `contr_h' , absorb(wficn h) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe wd3 treatpost `contr_h' , absorb(wficn h) keepsing cluster(wficn) 
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(treatpost treat `contr_h') label legend  title(Baseline) nogaps 

****Table 3: Skill groups
	local depvar "wd80_v3 wd3" 
	foreach v in `depvar' {
	eststo clear
	eststo: quiet xi: reghdfe `v' treatpost `contr_h' if skill_l==0, absorb(wficn h) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe `v' treatpost `contr_h' if skill_l==1, absorb(wficn h) keepsing cluster(wficn) 
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) label legend  title(By skill subsamples) nogaps 
	}

	
****Table 8 Dynamic Analysis 
	forval i=0(1)7 {
		gen h_`i'=0
		gen h`i'=0
	}
	replace h_4=1 if yrqtr<=200202 & treat==1
	replace h_3=1 if (yrqtr==200203|yrqtr==200204) & treat==1
	replace h_2=1 if (yrqtr==200301|yrqtr==200302) & treat==1
	replace h_1=1 if (yrqtr==200303|yrqtr==200304) & treat==1
	replace h0=1 if (yrqtr==200401|yrqtr==200402) & treat==1
	replace h1=1 if (yrqtr==200403|yrqtr==200404) & treat==1
	replace h2=1 if (yrqtr==200501|yrqtr==200502) & treat==1
	replace h3=1 if (yrqtr==200503|yrqtr==200504) & treat==1
	replace h4=1 if (yrqtr>=200601) & treat==1
	
	eststo clear
	foreach v in `depvar' {
	eststo: quiet xi: areg `v' h_3 h_2 h_1 h0 h1 h2 h3 h4 `contr_h' i.h, absorb(wficn) cluster(wficn) 
	eststo: quiet xi: areg `v' h_3 h_2 h_1    h1 h2 h3 h4 `contr_h' i.h if (yrqtr~=200402 & yrqtr~=200401), absorb(wficn) cluster(wficn) 
	}
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(h* `contr_h') label legend title(Dynamic) nogaps indicate("Semiannual FE=_Ih*")


****Table 9A: Alternative measures
	eststo clear
	eststo: quiet xi: reghdfe bhrg_10pct treatpost `contr_h', absorb(wficn h) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe bhrg_20pct treatpost `contr_h', absorb(wficn h) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe wd60_v3 treatpost `contr_h', absorb(wficn h) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe wd80_v1 treatpost `contr_h', absorb(wficn h) keepsing cluster(wficn) 
	eststo: quiet xi: reghdfe wd170_v3 treatpost `contr_h', absorb(wficn h) keepsing cluster(wficn) 
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(treatpost `contr_q') label legend  title(Alternative measures) nogaps 
		
****Table 9B: Alternative periods
	eststo clear
	eststo: quiet xi: reghdfe wd80_v3 treatpost `contr_h' if year>=2002 & year<=2006, absorb(wficn h) cluster(wficn) 
	eststo: quiet xi: reghdfe wd80_v3 treatpost `contr_h' if year>=2003 & year<=2005, absorb(wficn h) cluster(wficn) 
	eststo: quiet xi: reghdfe wd3 treatpost `contr_h' if year>=2002 & year<=2006, absorb(wficn h) cluster(wficn) 
	eststo: quiet xi: reghdfe wd3 treatpost `contr_h' if year>=2003 & year<=2005, absorb(wficn h) cluster(wficn) 
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(treatpost `contr_q') label legend  title(Alternative periods) nogaps 
	
	
****Table 10: Pumping and Delay
	egen wd_med=median(wd80_v3) 
	gen wd_hi=(wd80_v3>=wd_med) 

	eststo clear
	eststo: quiet xi: reghdfe pumpvw1 treatpost `contr_h' if wd_hi, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe pumpvw1 treatpost `contr_h' if !wd_hi, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe pumpvw1 treatpost `contr_h' if skill_l==0, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe pumpvw1 treatpost `contr_h' if skill_l==1, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe delayperiod treatpost `contr_h' if wd_hi, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe delayperiod treatpost `contr_h' if !wd_hi, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe delayperiod treatpost `contr_h' if skill_l==0, absorb(wficn h) cluster(wficn) keepsing
	eststo: quiet xi: reghdfe delayperiod treatpost `contr_h' if skill_l==1, absorb(wficn h) cluster(wficn) keepsing
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) label legend title(WD vs. Pumping and Delay) nogaps 

	

*************************************************************************************
*																					*
*			Tables 4 and 5	Future returns and future flows							*
*																					*
*************************************************************************************

*~~~~~~~~~~~~~~~~~~~~~~~ Semiannual Intervals ~~~~~~~~~~~~~~~~~~~~~~~

use `all',clear

	local futret "abret_f3 abret_f6 abret_f9" 
	local futflow "flow_f3 flow_f6 flow_f9" 

	keep if year>=2001 & year<=2007
	keep if treat==1
****Classify high-, medium-, low-skill groups
	gen skill_1=(alpha182) if yrqtr==200304
	bys wficn: egen skill_pre1=mean(skill_1)
	xtile skill_q=skill_pre1, nq(2)
	gen skill_h=(skill_q==2)
	gen skill_l=(skill_q==1)
	drop if skill_h~=1 & skill_l~=1

****Compute changes in WD
	gen wd=wd80_v3
	gen _wd=wd3
	local change "wd _wd "
	foreach v in `change' {
		sort wficn year
		bys wficn: egen `v'_pre=mean(`v') if post==0
		bys wficn: egen `v'_aft=mean(`v') if post==1
		bys wficn: egen `v'pre=min(`v'_pre)
		bys wficn: egen `v'aft=min(`v'_aft)
		gen `v'_dif=`v'aft-`v'pre
		
		egen `v'_med=median(`v'_dif) if ~missing(`v'_dif)
		gen `v'_hi=1  if ~missing(`v'_dif)
		replace `v'_hi=0 if `v'_dif<=`v'_med & ~missing(`v'_dif)
		gen post_`v'=post*`v'_hi
	}
		
	tempfile all
save `temp1'
	

****Semiannual 
	gen h = hofd(rdate)
	format h %th

	collapse (mean)alpha30 (max)rdate (count)n=year, by(wficn h)
	tempfile semi
	save `semi'

	use `temp1'
	drop alpha30
	merge 1:1 wficn rdate using `semi', keep(match) nogen 
	

****Table 4: Future Return; Semiannual interval
preserve
	foreach v in `futret' `contr_h' {
		drop if `v'==.
		}
	winsor2 `futret' `contr_h', c(1 99) replace 

	foreach v in `change' {
	eststo clear
	foreach r in `futret'{
	eststo: quiet xi: reghdfe `r' post_`v' `contr_h' if skill_h==1, absorb(wficn h) cluster(wficn)
	eststo: quiet xi: reghdfe `r' post_`v' `contr_h' if skill_h==0, absorb(wficn h) cluster(wficn)
	}
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) keep(post_`v') label legend title(Future return `v' subsample) nogaps order(post_`v' )
	}
restore

****Table 5: Future Flow; Semiannual interval
	foreach v in `futflow' `contr_h' {
		drop if `v'==.
	}
	winsor2 `futflow' `contr_h', c(1 99) replace 

	foreach v in `change' {
	eststo clear
	foreach r in `futflow'{
	eststo: quiet xi: reghdfe `r' post_`v' `contr_h' if skill_h==1, absorb(wficn h) cluster(wficn)
	eststo: quiet xi: reghdfe `r' post_`v' `contr_h' if skill_h==0, absorb(wficn h) cluster(wficn)
	}
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) keep(post_`v') label legend title(Future flow `v' subsample) nogaps order(post_`v' )
	}


*~~~~~~~~~~~~~~~~~~~~~~~ Quarterly Intervals ~~~~~~~~~~~~~~~~~~~~~~~
use `all',clear

	keep if year>=2001 & year<=2007
	keep if treat==1
****Classify high-, medium-, low-skill groups
	gen skill_1=(alpha91) if yrqtr==200304
	bys wficn: egen skill_pre1=mean(skill_1)
	xtile skill_q=skill_pre1, nq(2)
	gen skill_h=(skill_q==2)
	gen skill_l=(skill_q==1)
	drop if skill_h~=1 & skill_l~=1

****Compute changes in WD
	gen wd=wd80_v3
	gen _wd=wd3
	local change "wd _wd "
	foreach v in `change' {
		sort wficn year
		bys wficn: egen `v'_pre=mean(`v') if post==0
		bys wficn: egen `v'_aft=mean(`v') if post==1
		bys wficn: egen `v'pre=min(`v'_pre)
		bys wficn: egen `v'aft=min(`v'_aft)
		gen `v'_dif=`v'aft-`v'pre
		
		egen `v'_med=median(`v'_dif) if ~missing(`v'_dif)
		gen `v'_hi=1  if ~missing(`v'_dif)
		replace `v'_hi=0 if `v'_dif<=`v'_med & ~missing(`v'_dif)
		gen post_`v'=post*`v'_hi
	}

	
****Table 4: Future Return; Quarterly interval
preserve
	foreach v in `futret' `contr_q' {
		drop if `v'==.
	}	
	winsor2 `contr_q' `futret', c(1 99) replace

	foreach v in `change' {
	eststo clear
	foreach r in `futret'{
	eststo: quiet xi: reghdfe `r' post_`v' `contr_q' if skill_h==1, absorb(wficn yrqtr) cluster(wficn)
	eststo: quiet xi: reghdfe `r' post_`v' `contr_q' if skill_l==1, absorb(wficn yrqtr) cluster(wficn)
	}
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(`contr_q' _cons) label legend title(Future return Skill subsample) nogaps order(post_`v' )
	}
restore

****Table 5: Future Flow; Quarterly interval
	foreach v in `futflow' `contr_q' {
		drop if `v'==.
	}		
	winsor2 `contr_q' `futflow', c(1 99) replace

	foreach v in `change' {
	eststo clear
	foreach r in `futflow'{
	eststo: quiet xi: reghdfe `r' post_`v' `contr_q' if skill_h==1, absorb(wficn yrqtr) cluster(wficn)
	eststo: quiet xi: reghdfe `r' post_`v' `contr_q' if skill_l==1, absorb(wficn yrqtr) cluster(wficn)
	}
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(`contr_q' _cons) label legend title(Future flow Skill subsample) nogaps order(post_`v' )
	}
	
	

*************************************************************************************
*																					*
*			Tables 7 Propensity score match 										*
*																					*
*************************************************************************************

use `all',clear

****Propensity Score Match
	keep if yrqtr==200304
	winsor2 wd80_v3 wd3 `contr_q' , c(1 99) replace
	
	xi: psmatch2 treat wd80_v3 `contr_q', neighbor(1) caliper(0.005) quiet noreplace common

	keep wficn yrqtr _* 
	sort _id
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	sort pair
	bysort pair: egen paircount = count(pair)
	drop if paircount!=2	/*Define matched pairs for the first nearest match*/
	keep wficn pair
	
merge 1:m wficn using `all', keep(match) nogen /*Match psm-pairs back to the sample*/

	keep if year>=2001 & year<=2007

*~~~~~~~~~~~~~~~~~~~~~~~ Quarterly Intervals ~~~~~~~~~~~~~~~~~~~~~~~
	preserve
	winsor2 wd80_v3 wd3 `contr_q' , c(1 99) replace
	eststo clear
	eststo: quiet xi: reghdfe wd80_v3 treatpost `contr_q' i.yrqtr, absorb(wficn yrqtr) keepsing cluster(wficn)
	eststo: quiet xi: reghdfe wd3 treatpost `contr_q' i.yrqtr, absorb(wficn yrqtr) keepsing cluster(wficn)
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(treat* `contr_q') label legend  title(PSM) nogaps indicate("Quarter FE=_Iyrqtr*")
	restore

*~~~~~~~~~~~~~~~~~~~~~~~ Semiannual Intervals ~~~~~~~~~~~~~~~~~~~~~~~
	gen h = hofd(rdate)
	format h %th
	
	collapse (sum) wd80_v3 wd3 (mean)alpha30 (max)rdate (count)n=year, by(wficn h)
	tempfile semi
	save `semi'

use `all'
	drop wd* alpha30
	merge 1:1 wficn rdate using `semi', keep(match) nogen 

****Regression
	winsor2 wd80_v3 wd3 `contr_h' , c(1 99) replace
	eststo clear
	eststo: quiet xi: reghdfe wd80_v3 treatpost `contr_h' i.h, absorb(wficn h) keepsing cluster(wficn)
	eststo: quiet xi: reghdfe wd3 treatpost `contr_h' i.h, absorb(wficn h) keepsing cluster(wficn)
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(treat* `contr_h') label legend  title(PSM) nogaps indicate("Semiannual FE=_Ih*")

	

*************************************************************************************
*																					*
*			Tables 8 Panel B: Pseudo Regulation Events  										*
*																					*
*************************************************************************************
use `all',clear
	gen h=.
	replace h=-10 if (yrqtr==199901|yrqtr==199902)
	replace h=-9 if (yrqtr==199903|yrqtr==199904)
	replace h=-8 if (yrqtr==200001|yrqtr==200002)
	replace h=-7 if (yrqtr==200003|yrqtr==200004)
	replace h=-6 if (yrqtr==200101|yrqtr==200102)
	replace h=-5 if (yrqtr==200103|yrqtr==200104)
	replace h=-4 if (yrqtr==200201|yrqtr==200202)
	replace h=-3 if (yrqtr==200203|yrqtr==200204)
	replace h=-2 if (yrqtr==200301|yrqtr==200302)
	replace h=-1 if (yrqtr==200303|yrqtr==200304)
	replace h=0 if (yrqtr==200401|yrqtr==200402)
	replace h=1 if (yrqtr==200403|yrqtr==200404)
	replace h=2 if (yrqtr==200501|yrqtr==200502)
	replace h=3 if (yrqtr==200503|yrqtr==200504)
	replace h=4 if (yrqtr==200601|yrqtr==200602)
	replace h=5 if (yrqtr==200603|yrqtr==200604)
	replace h=6 if (yrqtr==200701|yrqtr==200702)
	replace h=7 if (yrqtr==200703|yrqtr==200704)
	replace h=8 if (yrqtr==200801|yrqtr==200802)
	replace h=9 if (yrqtr==200803|yrqtr==200804)
	replace h=10 if (yrqtr==200901|yrqtr==200902)
	replace h=11 if (yrqtr==200903|yrqtr==200904)
	replace h=12 if (yrqtr==201001|yrqtr==201002)
	replace h=13 if (yrqtr==201003|yrqtr==201004)
	replace h=14 if (yrqtr==201101|yrqtr==201102)
	replace h=15 if (yrqtr==201103|yrqtr==201104)

	collapse (sum)wd80_v3 (mean)alpha30 (max)rdate, by(wficn h)
	tempfile semi
	save `semi'

	use `all'
	drop wd80_v3 alpha30
	merge m:m wficn rdate using `semi', keep(match) nogen 
	
	foreach v in wd80_v3 `contr_h' {
		drop if `v'==.
	}
	
	winsor2 wd80_v3 `contr_h', c(1 99) replace 
	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Pseudo Post ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	eststo clear
	gen post=0
	replace post=1 if h>-8
	gen treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h<=1, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>-5
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-11 & h<=2, absorb(wficn )  cluster(wficn)
		
	replace post=0
	replace post=1 if h>-4
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-10 & h<=3, absorb(wficn )  cluster(wficn)
		
	replace post=0
	replace post=1 if h>-3
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-9 & h<=4, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>-2
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-8 & h<=5, absorb(wficn )  cluster(wficn)
		
	replace post=0
	replace post=1 if h>-1
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-7 & h<=6, absorb(wficn )  cluster(wficn)
		
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) keep(treatpost) label legend  title(Placebo) nogaps 

	
	eststo clear
	replace post=0
	replace post=1 if h>1
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-5 & h<=8, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>2
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-4 & h<=9, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>3
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-3 & h<=10, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>4
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-2 & h<=11, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>5
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=-1 & h<=12, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>6
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=0 & h<=13, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>7
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=1 & h<=14, absorb(wficn )  cluster(wficn)
	
	replace post=0
	replace post=1 if h>8
	replace treatpost=treat*post
	eststo: quiet xi: areg wd80_v3 treatpost `contr_h' i.h if h>=2 & h<=15, absorb(wficn )  cluster(wficn)

	esttab est* , append cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_a N, labels("Adjusted R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) keep(treatpost) label legend  title(Placebo) nogaps 

	

*************************************************************************************
*			 																		*
*				Table 6 Collapse (Hazard model)									 	*
*																					*
*************************************************************************************

*Note: While we enforce the selection criterion of "at least 5 years of observations during 2010-2017" to the baseline sample ("finalsam"), this requirement does not apply here ("finalsam_unbalance"). Here, funds are eligible for inclusion regardless of their survival duration.

use "finalsam_unbalance",clear
	keep if year>=2001 & year<=2007
	keep wficn year yrqtr rdate treat wd80_v3 wd3 wd60_v3 wd80_v1 wd170_v3 pumpvw1 delayperiod1 size alpha30 alpha91 alpha182 flow_p3 flow_p6 turnover tcost exp age load amdm anam rdate1 rdate2
	
	gen post=0
	replace post=1 if yrqtr>200402

	gen skill_L=alpha182	
	
****Define fund collapses
	gen entr=0
	replace entr=1 if year(rdate1)>2001 
	
	gen yq = qofd(rdate)
	gen yq1 = qofd(rdate2)
	format yq yq1 %tq
	gen datedif = rdate2-rdate

	gen clp1=0
	replace clp1=1 if yq==yq1 & rdate2>mdy(6,30,2004)
 
	global contr_h "size alpha30 skill_L flow_p6 turnover tcost exp age load amdm anam"

	keep wficn yrqtr rdate* $contr_h clp* wd80_v3 wd3 treat post year yq
	
****Classify high-, low-skill groups
	gen skill_1=(skill_L) if yrqtr==200304
	bys wficn: egen skill_pre1=mean(skill_1)
	xtile skill_q=skill_pre1, nq(2)
	gen skill_h=(skill_q==2)
	gen skill_l=(skill_q==1)
	drop if skill_h~=1 & skill_l~=1	

****Compute changes in WD
	gen wd=wd80_v3
	gen _wd=wd3
	local change "wd _wd"
	foreach v in `change' {
		sort wficn year
		bys wficn: egen `v'_pre=mean(`v') if post==0
		bys wficn: egen `v'_aft=mean(`v') if post==1
		bys wficn: egen `v'pre=min(`v'_pre)
		bys wficn: egen `v'aft=min(`v'_aft)
		gen `v'_dif=`v'aft-`v'pre
		
		egen `v'_med=median(`v'_dif) if `v'_dif~=.
		gen `v'_hi=1 if `v'_dif~=.
		replace `v'_hi=0 if `v'_dif<=`v'_med & `v'_dif~=.
		
		gen post_`v'=post*`v'_hi
	}

	
****Semiannual
	gen yh = hofd(rdate)	
	format yh %th

tempfile all
save `all'

	collapse (max)yq rdate (max)clp=clp1 , by(wficn yh)
tempfile semi
save `semi'

use `all'
merge 1:1 wficn rdate using `semi', keep(match) nogen 

winsor2 $contr_h, c(1 99) replace 


****Summary statistics	
	keep if treat==1
	
	preserve
	keep if post==1
	eststo clear
	eststo: qui estpost tabstat clp1, statistics(n mean median sd) columns(statistics)
	esttab est*, replace  cells("count(lab(N)) mean(fmt(3)) p50(fmt(3)) sd(fmt(3))")  nostar nonumbers noobs label unstack title(Collapse Summary) 
	
	eststo clear
	eststo: qui estpost tabstat clp1 if skill_h==1, statistics(n mean ) columns(statistics)
	eststo: qui estpost tabstat clp1 if skill_h==0, statistics(n mean ) columns(statistics)
	eststo: qui estpost tabstat clp1 if wd_hi==1, statistics(n mean ) columns(statistics)
	eststo: qui estpost tabstat clp1 if wd_hi==0, statistics(n mean ) columns(statistics)
	eststo: qui estpost tabstat clp1 if _wd_hi==1, statistics(n mean ) columns(statistics)
	eststo: qui estpost tabstat clp1 if _wd_hi==0, statistics(n mean ) columns(statistics)
	esttab est*, replace  cells("mean(fmt(3))")  nostar nonumbers noobs label unstack title(Collapse Summary) 
	restore
	
****Regression of Treated Funds

	*Cox PH
	stset rdate, id(wficn) failure(clp) origin(rdate1) exit(time mdy(12,31,2007))  

	eststo clear
	eststo: qui xi: stcox post_wd $contr_h if skill_h==1,  vce(cluster wficn) nohr
	eststo: qui xi: stcox post_wd $contr_h if skill_h==0,  vce(cluster wficn) nohr
	eststo: qui xi: stcox post__wd $contr_h if skill_h==1,  vce(cluster wficn) nohr
	eststo: qui xi: stcox post__wd $contr_h if skill_h==0,  vce(cluster wficn) nohr
	esttab est* , replace cells("b(star label(Coef.) fmt(3))" t(par(( )) fmt(2))) stats(r2_p N, labels("Pseudo R2" "Observations") fmt(3 0))  ///
	starlevels(* 0.1 ** 0.05 *** 0.01) label legend title(Collapse) nogaps order(post_wd post__wd) mtitle(High Low High Low)
