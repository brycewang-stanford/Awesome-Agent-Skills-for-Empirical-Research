*!*************************************************************************************
*! PROGRAM: Call, Martin, Sharp, Wilde (2017, Journal of Accounting Research)         *
*! AUTHORS: Gerald S. Martin (gmartin@american.edu)                                   *
*! 			Jaron Wilde (jaron-wilde@uiowa.edu)                                       *
*! Data: cmsw_wb_final.dta                                                            *
*! DATE: March 1, 2014, updated April 21, 2017                                        * 
*!*************************************************************************************

cap log close
set more off
set matsize 800
use cmsw_wb_final, clear

* install user written programs used
net install winsor, from(http://fmwww.bc.edu/RePEc/bocode/w)
net install outreg2, from(http://fmwww.bc.edu/RePEc/bocode/o)
net install psacalc, from(http://fmwww.bc.edu/RePEc/bocode/p)

*!*************************************************************************************
*! PROGRAM: testgroup                                                                 *
*! DESCRIPTION: Performs statistical tests of significance (=0) and group tests on    *
*!              optional by() variable.                                               *
*! varlist: Stata numerica variables.                                                 *
*! if: optionally subsets observations that meet the condition                        *
*! by(): optionally performs between group comparisons on the by variable             *
*! DECimals: optionaly control the number of decimal places displayed                 *
*! SYNTAX: testgroup varlist [if], [by(newvar)] [decimals(#)]                         *
*! AUTHOR: Gerald S. Martin                                                           *
*! DATE: March 1, 2014, updated April 21, 2017                                        * 
*!*************************************************************************************
cap program drop testgroup
program testgroup
	syntax varlist(max=1) [if][, by(varlist) DECimals(integer 2)]
	local fmt = "%11.`decimals'f"		// format
	di
	di "Group test of `varlist' by `by'"
	di "{hline 90}"
	di %20s "`by'" "       N       Mean         t      p(t)     Median         z      p(z)"
	di "{hline 90}"
	qui sum `varlist' `if', detail
	local n = r(N)
	local mean = r(mean)	
	local median = r(p50)	
	qui ttest `varlist' = 0 `if'
	local t = r(t)					// t = r(mean)/(r(sd)/sqrt(r(N)))
	local pt = r(p)					// p = 2*ttail(r(N)-1,abs(r(mean)/(r(sd)/sqrt(r(N)))))
	qui signrank `varlist' = 0 `if'
	local z = r(z)
	local pz = 2*(1-normal(abs(r(z))))
	di %20s "All" %8.0f `n' `fmt' `mean' %10.4f `t' %10.3f `pt' `fmt' `median' %10.4f `z' %10.3f `pz' 
	if "`by'" != "" {
		local r = 0
		qui levelsof `by', local(levels)
		foreach l of local levels {		
			local r = `r' + 1
			if "`if'" == "" {
				qui sum `varlist' if `by'==`l', detail
			}
			else {
				qui sum `varlist' `if' & `by'==`l', detail
			}
			local n = r(N)
			local mean = r(mean)
			local median = r(p50)
			if `n' > 0 {
				if "`if'" == "" {
					qui ttest `varlist' = 0 if `by' == `l'
				}
				else {
					qui ttest `varlist' = 0 `if' & `by' == `l'
				}
				local t = r(t)
				local pt = r(p)
				if "`if'" == "" {
					qui signrank `varlist' = 0 if `by' == `l'
				}
				else {
					qui signrank `varlist' = 0 `if' & `by' == `l'
				}
				if `n' > 1 {
					local z = r(z)
					local pz = 2*(1-normal(abs(r(z))))
				}
				else {
					local z = .
					local pz = .
				}
				di %20s "`:label (`by') `l''" %8.0f `n' `fmt' `mean' %10.4f `t' %10.3f `pt' `fmt' `median' %10.4f `z' %10.3f `pz'
			}
		}
	}
	di "{hline 90}"
	if `r' == 2 {
		tempname m1 m2 
		qui tabstat `varlist' `if', by(`by') s(mean median) save
		matrix `m1' = r(Stat1)
		matrix `m2' = r(Stat2)
		local diffmd = (`m1'[2,1] - `m2'[2,1])
		qui inspect `varlist'
		local N_unique = r(N_unique)
		if `N_unique' > 2 {
			qui sdtest `varlist' `if', by(`by')
			if r(p) < 0.05 {
				local meandesc = "Mean-comparison test*"
				qui ttest `varlist' `if', by(`by') unequal
			}
			else {
				local meandesc = "Mean-comparison test"
				qui ttest `varlist' `if', by(`by')
			}
			local diffmn = (r(mu_1) - r(mu_2))
			local t = r(t)
			local pt = r(p)
			qui ranksum `varlist' `if', by(`by')	
			local z = r(z)
			local pz = 2 * normprob(-abs(r(z)))
		}
		else {
			qui prtest `varlist' `if', by(`by')
			local diffmn = (r(P_1) - r(P_2))
			local t = r(z)
			local pt = 2 * (1 - normal(abs(r(z))))
		}		
		di
		di %-21s "Two-group test" %12s "Difference" %13s "cr. value" %10s "p-value"
		di "{hline 56}"
		if `N_unique' > 2 {
			di %22s "`meandesc'"   `fmt' `diffmn' %8s "t=" %4.2f `t' %10.3f `pt' 
			di %22s "Wilcoxon rank-sum test" `fmt' `diffmd' %8s "z=" %4.2f `z' %10.3f `pz'
		}
		else {
			di %22s "Test of proportions"   `fmt' `diffmn' %8s "z=" %4.2f `t' %10.3f `pt' 
		}
		di "{hline 56}"
		di "* indicates test assuming unequal variances"
	}
end

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*Note: mark touse_sox is a dummy for Post-Sarbanes Oxley enforcement actions (i.e., the regenddt is after the SOX date, July 30, 2002)

*Winsorize relevant variables at 1st and 99th percentiles
winsor blckownpct, gen(blckownpct_w) p(.01)
label var blckownpct_w "% Blockholder ownership"											// % Blockholder ownership
winsor initabret, gen(initabret_w) p(.01)
label var initabret_w "% Initial abnormal return"											// % Initial abnormal return
winsor pct_ind_dir, gen(pct_ind_dir_w) p(.01)
label var pct_ind_dir_w "% Independent directors" 											// % Independent directors
winsor mkt2bk, gen(mkt2bk_w) p(.01)
label var mkt2bk_w "Market-to-book ratio"													// Market-to-book ratio
winsor lev, gen(lev_w) p(.01)
label var lev_w "Leverage ratio"															// Leverage ratio

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

******************
* Variable Lists *
******************
global WBFLAG  = "wbflag"
global TIPSTER = "tipsterflag nontipsterflag"

*primary control variables
global RHS1 	 	= "selfdealflag blckownpct_w initabret_w lnvioperiod bribeflag mobflag deter lnempclevel_n  lnuscodecnt  viofraudflag misledflag audit8flag exectermflag coopflag impedeflag pct_ind_dir_w recidivist lnmktcap mkt2bk_w lev_w lndistance"
global RHS1_nomob  	= "selfdealflag blckownpct_w initabret_w lnvioperiod bribeflag         deter lnempclevel_n  lnuscodecnt  viofraudflag misledflag audit8flag exectermflag coopflag impedeflag pct_ind_dir_w recidivist lnmktcap mkt2bk_w lev_w lndistance" /*mobflag*/

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 2 *
***********
*Descriptive Stats
* Panel A
tab wbtype if touse_sox

*tipster versus non-tipster analyses
tab nontipsterflag wbflag if touse_sox

* Panel B
tab wbflag if touse_sox==1
tab2 wbflag top3flag ceoflag clevelflag execflag dirflag nonexecflag nonempflag firmnamedflag firmnotnamed firmonly if touse_sox, firstonly col
tab2 wbflag top3flag ceoflag clevelflag execflag dirflag nonexecflag nonempflag firmnamedflag firmnotnamed firmonly if touse_sox, firstonly row

* Panel C
tab ff12 if touse_sox
tab ff12 wbflag if touse_sox, row chi

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 3 *
***********
global ds_depvar = "firmpenalty1 emp_penalty1 empprison_mos"
global ds_indvar = "selfdealflag blckownpct_w initabret_w vioperiod bribeflag mobflag deter empclevel_n  uscodecnt  viofraudflag misledflag audit8flag exectermflag coopflag impedeflag pct_ind_dir_w recidivist sox mktcap mkt2bk_w lev_w distance"

preserve

keep wbflag $ds_depvar $ds_indvar touse_sox 
outreg2 using table3, excel bdec(2) tdec(2) replace sum(detail) eqkeep(N mean sd p50 p75 p95 max) 

restore
preserve

keep if touse_sox & wbflag==0
keep wbflag $ds_depvar $ds_indvar touse_sox 
outreg2 using table3, excel bdec(2) tdec(2) append sum(detail) eqkeep(N mean sd p50 p75 p95 max) 

restore
preserve

keep if touse_sox & wbflag==1
keep wbflag $ds_depvar $ds_indvar touse_sox 
outreg2 using table3, excel bdec(2) tdec(2) append sum(detail) eqkeep(N mean sd p50 p75 p95 max) 

sum $ds_depvar $ds_indvar if touse_sox & wbflag==1

restore

*dependent variables
testgroup firmpenalty1 if touse_sox, by(wbflag)
testgroup emp_penalty1 if touse_sox, by(wbflag)
testgroup empprison_mos if touse_sox, by(wbflag)
testgroup otherpenalty1 if touse_sox, by(wbflag)

* independent variables
testgroup selfdealflag if touse_sox, by(wbflag) dec(4)
testgroup blckownpct_w if touse_sox, by(wbflag) dec(4)
testgroup initabret_w if touse_sox, by(wbflag) dec(4)
testgroup vioperiod if touse_sox, by(wbflag)
	testgroup lnvioperiod if touse_sox, by(wbflag)
testgroup bribeflag if touse_sox, by(wbflag) dec(4)
testgroup mobflag if touse_sox, by(wbflag) dec(4)
testgroup deter if touse_sox, by(wbflag) dec(4)
testgroup empclevel_n if touse_sox, by(wbflag)
	testgroup lnempclevel_n if touse_sox, by(wbflag)
testgroup uscodecnt if touse_sox, by(wbflag)
	testgroup lnuscodecnt if touse_sox, by(wbflag)
testgroup viofraudflag if touse_sox, by(wbflag) dec(4)
testgroup misledflag if touse_sox, by(wbflag) dec(4)
testgroup audit8flag if touse_sox, by(wbflag) dec(4)
testgroup exectermflag if touse_sox, by(wbflag) dec(4)
testgroup coopflag if touse_sox, by(wbflag) dec(4)
testgroup impedeflag if touse_sox, by(wbflag) dec(4)
testgroup pct_ind_dir_w if touse_sox, by(wbflag) dec(4)
testgroup recidivist if touse_sox, by(wbflag) dec(4)
testgroup mktcap if touse_sox, by(wbflag) dec(4)
	testgroup lnmktcap if touse_sox, by(wbflag)
testgroup mkt2bk_w if touse_sox, by(wbflag)
testgroup lev_w if touse_sox, by(wbflag)
testgroup distance if touse_sox, by(wbflag)
	testgroup lndistance if touse_sox, by(wbflag)

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 4 *
***********
*Primary Analysis: For Post-SOX sample (i.e., the regenddt after SOX date: July 30, 2002)
*WB flag
poisson firmpenalty1 $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
poisson emp_penalty1 $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
poisson empprison_mos $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 5 *
***********
*Panel A: Descriptives for tipster/non-tipster cases

preserve
keep if touse_sox & wbflag==0
keep wbflag $ds_depvar $ds_indvar touse_sox tipsterflag nontipsterflag
outreg2 using table5, excel bdec(2) tdec(2) replace sum(detail) eqkeep(N mean sd p50 p75 p95 max) 

restore
preserve

keep if touse_sox & wbflag==1 & tipsterflag==1
keep wbflag $ds_depvar $ds_indvar touse_sox tipsterflag nontipsterflag 
* What regression here?
outreg2 using table5, excel bdec(2) tdec(2) append sum(detail) eqkeep(N mean sd p50 p75 p95 max) 

restore
preserve

keep if touse_sox & wbflag==1 & nontipsterflag==1
keep wbflag $ds_depvar $ds_indvar touse_sox tipsterflag nontipsterflag
* What regression here?
outreg2 using table5, excel bdec(2) tdec(2) append sum(detail) eqkeep(N mean sd p50 p75 p95 max) 

restore

*Test for differences between tipster-WB and non-tipster-WB cases

*dependent variables
testgroup firmpenalty1 if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag)
testgroup emp_penalty1 if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag)
testgroup empprison_mos if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag)
testgroup otherpenalty1 if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag)

* independent variables
testgroup selfdealflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup blckownpct_w if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup initabret_w if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup vioperiod if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
	testgroup lnvioperiod if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup bribeflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup mobflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup deter if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup empclevel_n if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
	testgroup lnempclevel_n if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup uscodecnt if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
	testgroup lnuscodecnt if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup viofraudflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup misledflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup audit8flag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup exectermflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup coopflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup impedeflag if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup pct_ind_dir_w if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup recidivist if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup mktcap if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
	testgroup lnmktcap if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup mkt2bk_w if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup lev_w if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
testgroup distance if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
	testgroup lndistance if touse_sox & (tipsterflag==1 | nontipsterflag==1), by(tipsterflag) dec(4)
	
*Panel B	

*tipster and nontipster flags
poisson firmpenalty1 $TIPSTER $RHS1 i.ff12 if touse_sox, vce(robust)
test tipster nontipster

poisson emp_penalty1 $TIPSTER $RHS1 i.ff12 if touse_sox, vce(robust)
test tipster nontipster

poisson empprison_mos $TIPSTER $RHS1 i.ff12 if touse_sox, vce(robust)
test tipster nontipster
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 6 *
***********

poisson otherpenalty1 $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
poisson otherpenalty1 $TIPSTER $RHS1 i.ff12 if touse_sox, vce(robust)
test tipster nontipster

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 7 *
***********
*Panel A

*Discovery period 										   
	*set negative investigation periods to zero (i.e. if violation end is after first regulatory proceeding - violation continued even after first regulatory proceeding)
gen invperiod_no_neg = max(invperiod, 0)						
gen ln_invperiod = log(invperiod)																// LN(Time from Violation End to Regulatory Activity Begins (mos))
gen ln_invperiod_incl_neg = ln_invperiod
replace ln_invperiod_incl_neg = 0 if invperiod < 0 & ln_invperiod==.
label var invperiod_no_neg "Discovery Period (mos)"												// Non-negative discovery period in months
label var ln_invperiod_incl_neg "Discovery Period"												// Discovery Period (LN of Discovery Period (months))		

*WB versus non-WB
sum invperiod_no_neg if touse_sox & wbflag==0 , detail
sum invperiod_no_neg if touse_sox & wbflag==1 , detail

sum  regperiod if touse_sox & wbflag==0 & closedflag==1, detail
sum  regperiod if touse_sox & wbflag==1 & closedflag==1, detail

*tipster versus non-tipster
sum invperiod_no_neg if touse_sox & wbflag==1 & tipsterflag==1, detail
sum invperiod_no_neg if touse_sox & wbflag==1 & nontipsterflag==1, detail

sum  regperiod if touse_sox & wbflag==1 & closedflag==1 & tipsterflag==1, detail
sum  regperiod if touse_sox & wbflag==1 & closedflag==1 & nontipsterflag==1, detail

*WB versus non-WB
testgroup invperiod_no_neg if touse_sox, by(wbflag)									// in months
testgroup ln_invperiod_incl_neg if touse_sox, by(wbflag)							// LN of measure in months
testgroup regperiod if touse_sox & closedflag==1, by(wbflag)

*tipster versus non-tipster
testgroup invperiod_no_neg if touse_sox & wbflag==1, by(tipsterflag)				// in months
testgroup ln_invperiod_incl_neg if touse_sox & wbflag==1, by(tipsterflag)			// LN of measure in months
testgroup regperiod if touse_sox & wbflag==1 & closedflag==1, by(tipsterflag)

*Panel B
reg ln_invperiod_incl_neg $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)

*Regulatory period

tempvar regenddt
gen `regenddt' = regenddt + 1							// add 1 day so single day events are not dropped
*Note: regbegdt = date of first regulatory proceding
*Note: regenddt = date of last regulatory proceeding or 
stset `regenddt', failure(closedflag) origin(time regbegdt) scale(30.436875) time0(regbegdt)  
sts graph, by(wbflag)
stci, by(wbflag)
stci, by(wbflag) rmean
sts test wbflag, logrank
sts test wbflag, wilcoxon 

*length of regulatory period for actions that are closed
streg $WBFLAG $RHS1  i.ff12 if touse_sox & closedflag==1, dist(loglogistic) tr vce(robust)

*Panel C
reg ln_invperiod_incl_neg $TIPSTER $RHS1 i.ff12 if touse_sox, vce(robust)
test $TIPSTER

*length of regulatory period--tipster and non-tipster--for actions that are closed
streg $TIPSTER $RHS1  i.ff12 if touse_sox & closedflag==1, dist(loglogistic) tr vce(robust)
test $TIPSTER

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

***********
* Table 8 *
***********
*Panel A

*Logit
logit d_firmpenalty1 $WBFLAG $RHS1_nomob i.ff12 if touse_sox, vce(robust) 
lroc
logit d_emp_penalty1 $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
lroc
logit d_empprison_mos $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
lroc

*Tobit, logged dependent variable
tobit ln_firmpenalty $WBFLAG $RHS1_nomob i.ff12 if touse_sox, ll(0) vce(robust)
tobit ln_emppenalty $WBFLAG $RHS1 i.ff12 if touse_sox, ll(0) vce(robust)
tobit ln_empprison_mos $WBFLAG $RHS1 i.ff12 if touse_sox, ll(0) vce(robust)


*OLS, logged dependent variable
reg ln_firmpenalty $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
reg ln_emppenalty $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
reg ln_empprison_mos $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)

*Panel B
*Information to compute impact threshold for a confounding variable
xi: pcorr wbflag $RHS1 i.ff12 if touse_sox
xi: pwcorr wbflag $RHS1 i.ff12 if touse_sox

*ln_firmpenalty
reg ln_firmpenalty $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)

*partial correlations
xi: pcorr ln_firmpenalty $RHS1 i.ff12 if touse_sox

*raw correlations
xi: pwcorr ln_firmpenalty $RHS1 i.ff12 if touse_sox

*Panel C
*psacalc following Oster (2016): available at https://www.brown.edu/research/projects/oster/
*Note: this version of the psacalc ado file is dated December 13, 2016
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*ln_firmpenalty analysis
reg ln_firmpenalty wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.4632
*Pi		 	From *1		rmax
*1.3		0.4632		0.60216
*pi = 1.3
psacalc delta wbflag , rmax(0.60216)

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*ln_emppenalty analysis
reg ln_emppenalty wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.3250
*Pi			From *1		rmax
*1.3		0.3250		0.4225
*pi = 1.3
psacalc delta wbflag , rmax(.4225)
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*ln_empprison_mos analysis
reg ln_empprison_mos wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.2731
*Pi			From *1		rmax
*1.3		0.2731		0.35503
*pi = 1.3
psacalc delta wbflag , rmax(.35503)
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*ln_otherpenalty analysis
reg ln_otherpenalty wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.2052
*Pi			From *1		rmax
*1.3		0.2052		0.26676
*pi = 1.3
psacalc delta wbflag , rmax(.26676)

*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*d_firmpenalty1 analysis
reg d_firmpenalty1 wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.4910
*Pi			From *1		rmax
*1.3		0.4910		0.6383
*pi = 1.3
psacalc delta wbflag , rmax(0.6383)
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*d_emp_penalty1 analysis
reg d_emp_penalty1 wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.3998
*Pi			From *1		rmax
*1.3		0.3998		0.51974
*pi = 1.3
psacalc delta wbflag, rmax(0.51974)
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*d_empprison_mos analysis
reg d_empprison_mos wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.2552
*Pi			From *1		rmax
*1.3		0.2552		0.33176
*pi = 1.3
psacalc delta wbflag, rmax(0.33176)
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*d_otherpenalty1 analysis
reg d_otherpenalty1 wbflag $RHS1 i.ff12 if touse_sox , /*vce(robust) this option is not allowed*/
*1: R-squared of controlled regression = 0.2652
*Pi			From *1		rmax
*1.3		0.2652		0.34476
*pi = 1.3
psacalc delta wbflag,  rmax(.34476)
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________
*_____________________________________________________________________________________________________________________________________

*Online Appendix Analyses

************
* Table A1 * 
************
* Panel A
tab wbtype wbflag

* Panel B
tab wbflag
tab wbflag sox
tab2 wbflag top3flag ceoflag clevelflag execflag dirflag nonexecflag nonempflag firmnamedflag firmnotnamed firmonly, firstonly col
tab2 wbflag top3flag ceoflag clevelflag execflag dirflag nonexecflag nonempflag firmnamedflag firmnotnamed firmonly, firstonly row

* Panel C
tab ff12
tab ff12 wbflag, row chi

*Note: For consistency with the primary analyses, we use the same break-down of Compustat firms (from 1979 - 2012) in Panel C as 
* we use in the primary analyses

************
* Table A2 * 
************

poisson firmpenalty1 $WBFLAG $RHS1 sox i.ff12, vce(robust)
poisson emp_penalty1 $WBFLAG $RHS1 sox i.ff12, vce(robust)
poisson empprison_mos $WBFLAG $RHS1 sox i.ff12, vce(robust)

************
* Table A3 *
************
*Variance inflaction factors
reg ln_firmpenalty $WBFLAG $RHS1 i.ff12 if touse_sox, vce(robust)
estat vif

************
* Table A4 *
************
*More parsimonious model, using control variables that are significant (/ < 0.10) in one+ primary models and industry fixed effects
global RHS_parsimonius 	 	= "selfdealflag blckownpct_w initabret_w lnvioperiod bribeflag mobflag deter lnempclevel_n  lnuscodecnt audit8flag coopflag recidivist lnmktcap" /*viofraudflag misledflag exectermflag impedeflag pct_ind_dir_w mkt2bk_w lev_w lndistance*/

*WB flag

poisson firmpenalty1 $WBFLAG $RHS_parsimonius  i.ff12 if touse_sox, vce(robust)
poisson emp_penalty1 $WBFLAG $RHS_parsimonius i.ff12 if touse_sox, vce(robust)
poisson empprison_mos $WBFLAG $RHS_parsimonius i.ff12 if touse_sox, vce(robust)



