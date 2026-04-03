/*********************************************************
Filename: Equity_plan_grant_tests.do

This code runs the tests and outputs the results for Tables 1-8. 

Main inputs:
	1) Equilar-based equity incentive plan proposal sample (equity_plan_sample.dta from Equity_plan_sample.sas)
	2) Equilar-based annual equity grant sample (equity_grant_sample.dta from Equity_grant_sample.sas)
*********************************************************/

drop _all
clear matrix
set memory 500m
set matsize 3400

cd /*Path for input/output files*/
local printdir /*Path for output results*/ 

/*********************************************************
Preprocess equity incentive plan proposal sample
*********************************************************/

use equity_plan_sample, replace

keep if at0>0
drop if shares_req<=0

gen plandate=Date_of_Request
format %d plandate
gen yr=year(plandate)

*Equity plan proposal/grant measures
gen planshares=(shares_req+shares_avail)/1000000
gen req_shares=shares_req/1000000
gen avail_shares=shares_avail/1000000

gen shrout0=shares_out/1000000

gen pdilute=(planshares/shrout0)*100
gen pdilute_avail=(avail_shares/shrout0)*100
gen pdilute_req=(req_shares/shrout0)*100

foreach tv in pdilute pdilute_avail pdilute_req {
	replace `tv'=. if `tv'>100
	}

replace runratenet3yave=. if runratenet3yave<=0 | runratenet3yave>1
gen runratenet3yavel=ln(runratenet3yave)
gen runsharesnet3yave=runratenet3yave*shrout0

gen duration_rrnet=planshares/runsharesnet3yave if runsharesnet3yave>0
gen duration_avail=avail_shares/runsharesnet3yave if runsharesnet3yave>0
gen duration_req=req_shares/runsharesnet3yave if runsharesnet3yave>0

foreach tv in duration_rrnet duration_avail duration_req {
	replace `tv'=. if `tv'>100
	gen `tv'l=ln(1+`tv')
	}

gen duration_avail_lt1=(duration_avail<1 & !missing(duration_avail))
replace duration_avail_lt1=0 if !missing(duration_avail) & missing(duration_avail_lt1) 
	
gen rsgrant_pct=eq_rs_grants_3y/(eq_opt_grants_3y+eq_rs_grants_3y)
gen rsgrant_pct_adj=(eq_rs_grants_3y*rs_adj_fy1)/(eq_opt_grants_3y+eq_rs_grants_3y*rs_adj_fy1)

replace runratenetfy1=. if runratenetfy1<-1 | runratenetfy1>1
replace runratenetfy3=. if runratenetfy3<-1 | runratenetfy3>1
gen runrate_delta=runratenetfy1-runratenetfy3

replace espp=0 if missing(espp)

gen new_plan=(new_plan_n>0)

*Proposal frequency, available v. requested shares
gen prior_plan_yrs=ceil((plandate-prior_date_of_request)/365)
gen requested_shares_pct=(req_shares/planshares)*100
	
*Labor market measures
gen outside_ceo_pct=100-insiders_perc_10yr*100
replace outside_ceo_pct=. if (internal_10yr+external_10yr)<10

gen score_neg=nca_score*-1

gen lintl=ln(lint)
gen lstrl=ln(lstr)

*Governance measures 
gen dual1=(DUALCLASS=="YES")
gen dual2=(crsp_dc==1)
gen dual3=(comp_crsp_shrout_pct>1.01) if !missing(comp_crsp_shrout_pct)
gen dual=max(dual1, dual2, dual3)

replace instpct=. if instpct>1

gen board_indeppct=indeppct if indepn>2 & !missing(indeppct)
replace board_indeppct=boardex_indeppct if missing(board_indeppct) & boardex_indepn>2 & !missing(boardex_indeppct)

gen board_indepchair=boardex_indepchair
gen fpct=(votes_for/(votes_for+votes_against+votes_abstentions)) if !missing(votes_for) & !missing(votes_against) &!missing(votes_abstentions)

*ISS recommendations
gen issfor=(issrec=="For") if !missing(issrec) & plan_n==1

*Firm characteristics
gen at0l=ln(at0)
gen retstdann0=retstdann if retn>=200
gen retann0=retann if retn>=200

label variable pdilute "\it{Plan Dilution}"
label variable pdilute_avail "\it{Plan Dilution-Available}"
label variable pdilute_req "\it{Plan Dilution-Requested"

label variable duration_rrnetl "\it{Plan Duration}"
label variable duration_availl "\it{Plan Duration-Available}"
label variable duration_reql "\it{Plan Duration-Requested}"
label variable planflex "\it{Plan Flexibility}"

label variable outside_ceo_pct "\it{Outside CEO \%}"
label variable score_neg "\it{Noncompete Score (-)}"
label variable lintl "\it{Labor Intensity}"
label variable retstdann0 "\it{Stock Return Volatility}"

label variable board_indeppct "\it{Independent Board \%}"
label variable board_indepchair "\it{Independent Chair}"
label variable instpct "\it{Institutional Ownership}"
label variable dual "\it{Dual Class Shares}"

label variable retann0 "\it{Stock Return}"
label variable roa0 "\it{ROA}"
label variable at0l "\it{Size}"
label variable mba0 "\it{Market-to-Book Assets}"

label variable runratenet3yavel "\it{Net Run Rate}"
label variable new_plan "\it{New Plan}"
label variable rsgrant_pct "\it{Stock Grant \%}"

label variable prior_plan_yrs "Years since prior proposal"
label variable requested_shares_pct "Requested plan shares as a percentage of total plan shares"
label variable ceo_pct_grants_3ymax "CEO equity grants as a percentage of total grants, 3-year max"

label variable duration_rrnet "\it{Plan Duration}"
label variable duration_avail "\it{Plan Duration-Available}"
label variable duration_req "\it{Plan Duration-Requested}"

label variable runratenet3yave "\it{Net Run Rate}"
label variable at0 "\it{Size}"
save eps0, replace

use eps0, replace

local planv pdilute pdilute_avail pdilute_req planflex
local durv duration_rrnetl duration_availl duration_reql 
local competition outside_ceo_pct score_neg lintl 
local vol retstdann0 
local boardgov board_indeppct board_indepchair 
local shgov	instpct dual 
local firmc retann0 roa0 at0l mba0 
local planc runratenet3yavel new_plan rsgrant_pct 

local trimv pdilute pdilute_avail pdilute_req `durv' `planc' `competition' `vol' `boardgov' `shgov' `firmc' 
foreach tv in `trimv' {
	drop if missing(`tv')
	}

save eps1, replace 

use eps1, replace

local wvar  `competition' `vol' board_indeppct instpct `firmc' runratenet3yavel rsgrant_pct duration_rrnet duration_avail duration_req runratenet3yave at0 

foreach wv in `wvar' {
	winsor `wv', gen(tmp) p(.01)
	replace `wv'=tmp
	drop tmp
	}

save ep_det_samp, replace

/*********************************************************
Table I: Equity incentive plan sample summary statistics
*********************************************************/

use ep_det_samp, replace

distinct company_id 

local pvs pdilute pdilute_avail pdilute_req duration_rrnet duration_avail duration_req planflex new_plan
local ovs `competition' `vol' `boardgov' `shgov' retann0 roa0 at0 mba0 runratenet3yave rsgrant_pct
 
tabstat `pvs' `ovs', statistics(n mean sd p25 median p75) save
mat ss0=[ r(StatTotal)']

outtable using "`printdir'/summarystats", label mat(ss0) replace format(%9.0fc %9.3f %9.3f %9.3f %9.3f %9.3f) center  nobox caption("Summary statistics")

/*********************************************************
Table II: Equity incentive plan discretion determinants
*********************************************************/	

use ep_det_samp, replace

local planc runratenet3yavel new_plan rsgrant_pct 
local fe i.yr i.FFI12 
local full `competition' `vol' `boardgov' `shgov' `firmc' `planc' 

local iv `competition' `vol' `boardgov' `shgov' `firmc' `planc' 

sum `full'

foreach dv in pdilute planflex {	
	local rep append
	if "`dv'"=="pdilute" {
		local rep replace
		}
		
	xi: reg `dv' `iv' `fe', vce(cluster gvkey)	
	predict `dv'_pred
	predict `dv'_res, resid

	outreg2 `full' using "`printdir'/plandiscretion_total", `rep' ///
		label long addstat(Adj. R-squared, e(r2_a)) alpha(0.01, 0.05, 0.10) dec(3) ///
		addtext(Year FE, YES, Industry FE, YES) sortvar(`full') tex(fragment) excel 		
	}
	
sort company_id plandate
keep company_id plandate *_pred *_res

label variable pdilute_pred "\it{Plan Dilution-Predicted}"
label variable pdilute_res "\it{Plan Dilution-Abnormal}"
save ep_det_samp_pred, replace

use eps1, replace

*Merge predicted values/residuals from determinants regression
merge 1:1 company_id plandate using ep_det_samp_pred

foreach tv in fpct pdilute duration_rrnetl {
	keep if !missing(`tv')
	}
	
local wvar pdilute pdilute_avail pdilute_req duration_rrnetl duration_availl duration_reql planflex  ///
 pdilute_pred pdilute_res retann0 roa0 at0l mba0 runratenet3yavel runrate_delta runratenetfy3

foreach wv in `wvar' {
	winsor `wv', gen(tmp) p(.01)
	replace `wv'=tmp
	drop tmp
	}

save ep_vote_samp, replace
	
/*********************************************************
Table III: Equity incentive plan voting results
*********************************************************/
use ep_vote_samp, replace

replace approved=0 if approved<1 & !missing(approved)

tabstat fpct,  statistics(n mean sd p25 median p75) save
mat fpct_for=[r(StatTotal)']

tabstat fpct, by(approved) statistics(n mean sd p25 median p75) save
mat fpct0=[ r(Stat1)' \ r(Stat2)']

tabstat fpct, by(new_plan) statistics(n mean sd p25 median p75) save
mat fpct1=[ r(Stat1)' \ r(Stat2)' ]

tabstat fpct, by(issfor) statistics(n mean sd p25 median p75) save
mat fpct2=[ r(Stat1)' \ r(Stat2)' ]

mat fpct3=[fpct_for \ fpct0 \ fpct1 \ fpct2 ]

outtable using "`printdir'/voting_sumstats", label mat(fpct3) replace format(%9.0fc %9.3f %9.3f %9.3f %9.3f %9.3f) center  nobox caption("Equity incentive plan results")


/*********************************************************
Table IV: Equity plan voting and plan discretion
*********************************************************/

use ep_vote_samp, replace
	
local fe i.yr i.FFI12 
local full pdilute_pred pdilute_res duration_rrnetl_pred duration_rrnetl_res 1.duration_avail_lt1 duration_reql retann0 roa0 at0l mba0 runratenet3yavel 1.issfor

local iv1 pdilute_pred pdilute_res
local iv2 i.duration_avail_lt1##c.pdilute_res pdilute_pred

pwcorr pdilute_pred pdilute_res retann0 roa0 at0l mba0 runratenet3yavel issfor

forvalues n=1(1)4 {
	local rep append
	if `n'==1 {
		est clear
		}
	
	local iv `iv1'	
	if `n'==2{
		local iv `iv2'
		}
	
	local controls retann0 roa0 at0l mba0 runratenet3yavel
	
	if `n'==3  {
		local controls retann0 roa0  at0l mba0 runratenet3yavel i.issfor
		}
	
	if `n'<4 {
		eststo: reg fpct `iv' `controls' `fe', vce(cluster gvkey)	
		vif
		}
	else if `n'==4 {
		logit issfor `iv' retann0 roa0 at0l mba0 runratenet3yavel `fe', vce(cluster gvkey)
		eststo: margins, dydx(`iv' retann0 roa0  at0l mba0 runratenet3yavel) post	
		}
	
	if `n'==1 | `n'==3 | `n'==4 {
		test c.pdilute_pred==c.pdilute_res
		}

	if `n'==4 {
		esttab using "`printdir'/votes_for.tex", replace noconstant ar2 pr2 b(3) se(3) label star(* .10 ** .05 *** .01) booktabs nonotes title("Equity plan voting and plan discretion")
		}
	}
	
/*********************************************************
Preprocess annual equity grant sample 
*********************************************************/
	
use equity_grant_sample, replace

gen yr=year(fye1)
drop if (fye1-fye2>372 | fye1-fye2<358)

replace runratenet3yave=. if runratenet3yave<=0 | runratenet3yave>1
gen runsharesnet3yave=runratenet3yave*(shrout_fy1*(ajex_fy1/ajex_current))

gen new_plan_shares=(shares_req/1000000)/runsharesnet3yave
gen dur=(shares_avail_fy2/1000000)/runsharesnet3yave

foreach tv in new_plan_shares dur {
	replace `tv'=. if `tv'>100
	gen `tv'l=ln(1+`tv')
	}

gen burnsharesl=ln(grants_fy1_adj)
gen burnshares0l=ln(grants_fy2_adj)
gen burnshares_deltal=ln(grants_fy1_adj/grants_fy2_adj) if grants_fy1_adj>0 & grants_fy2_adj>0

gen opt_pct=eq_opt_grants_3y/(eq_opt_grants_3y+eq_rs_grants_3y)

local tvar burnshares_deltal durl new_plan_sharesl retann1 retann0 FFI12
foreach tv in `tvar' {
	drop if missing(`tv')
	}

local wvar retann1 retann0 durl new_plan_sharesl dur new_plan_shares 
sum `wvar'
foreach wv in `wvar' {
	winsor `wv', gen(tmp) p(.01)
	replace `wv'=tmp
	drop tmp
	}

foreach rv in retann0 retann1 {
	gen `rv'pos=`rv'
	replace `rv'pos=0 if `rv'<=0 & !missing(`rv')

	gen `rv'neg=`rv'
	replace `rv'neg=0 if `rv'>0 & !missing(`rv')

	gen a`rv'=`rv'-m`rv'
	}
	
egen obsct=count(dur), by(cik)

label variable burnshares_deltal "\it{Delta Shares Granted}"
label variable dur "\it{Duration-Available_{t-1}}"
label variable new_plan_shares "\it{Duration-Requested_{t}}"

label variable durl "\it{Duration-Available_{t-1}}"
label variable new_plan_sharesl "\it{Duration-Requested_{t}}"
label variable retann0 "\it{Stock Return_{t-1}}"
label variable retann1 "\it{Stock Return_{t}}"
label variable retann0pos "\it{Stock Return_{t-1} (+)}"
label variable retann0neg "\it{Stock Return_{t-1} (-)}"
label variable retann1pos "\it{Stock Return_{t} (+)}"
label variable retann1neg "\it{Stock Return_{t} (-)}"

/*********************************************************
*Table V: Equity grant sample summary statistics
*********************************************************/

local mvs burnshares_deltal dur new_plan_shares retann1 retann0
tabstat `mvs', statistics(n mean sd p25 median p75) save
mat grantss=[r(StatTotal)']

outtable using "`printdir'/annual_grants_sumstats", label mat(grantss) replace format(%9.0fc %9.3f %9.3f %9.3f %9.3f %9.3f) center  nobox caption("Equity grant sample summary statistics")

/*********************************************************
*Table VI: Equity incentive plan discretion and equity grants
*********************************************************/

local iv1 durl new_plan_sharesl retann0 retann1
local iv2 c.durl##c.retann0 c.new_plan_sharesl##c.retann0 c.durl##c.retann1 c.new_plan_sharesl##c.retann1
local iv3 durl new_plan_sharesl retann0pos retann0neg 
local iv4 c.durl##c.retann0pos c.durl##c.retann0neg c.new_plan_sharesl##c.retann0pos c.new_plan_sharesl##c.retann0neg

local fe i.FFI12 i.yr
local full durl new_plan_sharesl retann0 retann1 retann0pos retann0neg

forvalues n=1(1)4 {
	local rep append
	if `n'==1 {
		local rep replace
		}
	
	reg burnshares_deltal `iv`n'' `fe', vce(cluster cik)
	outreg2 `full' using "`printdir'/annual_grants", `rep' label ///
		long addstat(Adj. R-squared, e(r2_a)) alpha(0.01, 0.05, 0.10) dec(3) ///
		addtext(Industry FE, YES, Year FE, YES) sortvar(`full') tex(fragment) excel 		
	}
	

use equity_grant_sample, replace

gen yr=year(fye1)
drop if (fye1-fye2>372 | fye1-fye2<358)

replace runratenetfy1=. if runratenetfy1<-1 | runratenetfy1>1
replace runratenetfy2=. if runratenetfy2<-1 | runratenetfy2>1

replace runratenet3yave=. if runratenet3yave<=0 | runratenet3yave>1
gen runsharesnet3yave=runratenet3yave*(shrout_fy1*(ajex_fy1/ajex_current))

gen dur=(shares_avail_fy2/1000000)/runsharesnet3yave
replace dur=. if dur>100
gen durl=ln(1+dur)

gen dur_lt1=(dur<1 & !missing(dur))

gen proposal=(!missing(plan_n))

gen proposal_new=(new_plan_n>0) if !missing(new_plan_n)
replace proposal_new=0 if missing(proposal_new)

gen proposal_amend=(plan_n>new_plan_n) if !missing(plan_n) & !missing(new_plan_n)
replace proposal_amend=0 if missing(proposal_amend)

local tvar durl runratenetfy1 runratenetfy2 retann0 retann1 roa0 roa1 FFI12 yr
foreach tv in `tvar' {
	drop if missing(`tv')
	}

local wvar durl runratenetfy1 runratenetfy2 retann0 retann1 roa0 roa1 dur
sum `wvar'
foreach wv in `wvar' {
	winsor `wv', gen(tmp) p(.01)
	replace `wv'=tmp
	drop tmp
	}

label variable proposal "Proposal"
label variable proposal_new "Proposal-New Plan"
label variable proposal_amend "Proposal-Amendment"
label variable durl "Duration-Available_{t-1}"
label variable runratenetfy1 "Net\ Run\ Rate_{t}"
label variable runratenetfy2 "Net\ Run\ Rate_{t-1}"
label variable retann0 "Stock\ Return_{t-1}"
label variable retann1 "Stock\ Return_{t}"
label variable roa0 "ROA_{t-1}"
label variable roa1 "ROA_{t}"

/*********************************************************
*Table VII: Equity proposal timing sample summary statistics
*********************************************************/

local iv dur runratenetfy2 runratenetfy1 retann0 retann1 roa0 roa1 

tabstat proposal proposal_new proposal_amend `iv', statistics(n mean sd p25 median p75) save
mat timingss=[r(StatTotal)']

outtable using "`printdir'/proposal_timing_sumstats", label mat(timingss) replace format(%9.0fc %9.3f %9.3f %9.3f %9.3f %9.3f) center  nobox caption("Equity proposal timing sample summary statistics")

/*********************************************************
*Table VIII: Equity proposal timing
*********************************************************/
local iv durl runratenetfy2 runratenetfy1 retann0 retann1 roa0 roa1 

logit proposal `iv' i.yr i.FFI12, vce(cluster cik)
eststo proposal_mfx1: margins, dydx(`iv') post
logit proposal_new `iv' i.yr i.FFI12, vce(cluster cik)
eststo proposal_mfx2: margins, dydx(`iv') post
logit proposal_amend `iv' i.yr i.FFI12, vce(cluster cik)
eststo proposal_mfx3: margins, dydx(`iv') post
xtset company_id fye1 
xtlogit proposal `iv' i.yr, fe vce(bootstrap)
eret list
eststo proposal_mfx4: margins, dydx(`iv') post

esttab proposal_mfx1 proposal_mfx2 proposal_mfx3 proposal_mfx4 using "`printdir'/proposal_timing.tex", replace b(%8.3f) se label star(* .1 ** .05 *** .01)  order(`iv')

/*********************************************************
Filename: Internal_External_CEO.do

This code reproduces Table III in K. J. Martijn Cremers, Yaniv Grinstein, Does the Market for CEO Talent Explain Controversial CEO Pay Practices?, Review of Finance, Volume 18, Issue 3, July 2014, Pages 921–960, https://doi.org/10.1093/rof/rft024.

Main inputs: Execucomp annual compensation data
	
Downloaded WRDS files (downloaded 9/21/22): 
execucomp_anncomp.dta: Execucomp annual compensation data (comp.anncomp)
	
Macro: ffind.do (J. Caskey)

Output: Internal/external CEO hires by industry-year (insiders_perc.dta)
*********************************************************/

global path /*Path for input/output files*/

*Import Execucomp data
use "$path/execucomp_anncomp.dta", clear
destring GVKEY, replace
destring EXECID, replace
	
egen gid=group(GVKEY)

*Create CEO and CFO flags
gen CEO=1 if CEOANN=="CEO"
replace CEO=0 if CEO==.
order CEO, after(CEOANN)

drop gid
egen gid=group(GVKEY)
sum gid if YEAR>=1993 & YEAR<=2005

*Identify the entry of new CEOs into the sample
gen BECAMECEO_YEAR=year(BECAMECEO)
gen REJOIN_YEAR=year(YEAR)

gen newCEO=0
replace newCEO=1 if BECAMECEO_YEAR==YEAR | REJOIN_YEAR==YEAR

drop if CEOANN==""

duplicates report GVKEY YEAR
duplicates tag GVKEY YEAR, gen(tag)
duplicates drop GVKEY YEAR, force

sort GVKEY YEAR
tsset GVKEY YEAR

replace newCEO=1 if l.CO_PER_ROL!=CO_PER_ROL & (l.GVKEY!=. | l2.GVKEY!=. | l3.GVKEY!=. ) & l2.CO_PER_ROL!=CO_PER_ROL & l3.CO_PER_ROL!=CO_PER_ROL & l4.CO_PER_ROL!=CO_PER_ROL & l5.CO_PER_ROL!=CO_PER_ROL & l6.CO_PER_ROL!=CO_PER_ROL & l7.CO_PER_ROL!=CO_PER_ROL & l8.CO_PER_ROL!=CO_PER_ROL & l9.CO_PER_ROL!=CO_PER_ROL & l10.CO_PER_ROL!=CO_PER_ROL

keep EXECID GVKEY YEAR newCEO	
sum newCEO
save "$path/execucomp_anncomp_newCEOs.dta", replace

use "$path/execucomp_anncomp.dta", clear
destring GVKEY, replace
destring EXECID, replace
	
egen gid=group(GVKEY)
sum gid if YEAR>=1993 & YEAR<=2020

*Create CEO and CFO flags
gen CEO=1 if CEOANN=="CEO"
replace CEO=0 if CEO==.
order CEO, after(CEOANN)

gen BECAMECEO_YEAR=year(BECAMECEO)
gen REJOIN_YEAR=year(YEAR)

joinby EXECID GVKEY YEAR using "$path/execucomp_anncomp_newCEOs.dta", unmatched(master)
drop _merge
sum newCEO

*Identify internal and external CEOs
keep EXEC_FULLNAME CONAME CEOANN YEAR  newCEO CO_PER_ROL GVKEY EXECID SIC

tsset CO_PER_ROL YEAR
sort CO_PER_ROL YEAR

gen external=0
replace external=1 if newCEO==1 & l2.CO_PER_ROL==. &  l3.CO_PER_ROL==. & l4.CO_PER_ROL==. & l5.CO_PER_ROL==. & l6.CO_PER_ROL==. & l7.CO_PER_ROL==. & l8.CO_PER_ROL==. & l9.CO_PER_ROL==. & l10.CO_PER_ROL==.

gen internal=0
replace internal=1 if newCEO==1 & external==0

drop if CEOANN==""

*Exclude observations if executive only appears for one year as CEO (interim appointment or rapid-switch)
egen count=count(EXECID), by(CO_PER_ROL) 
gen interim=0
replace interim=1 if count==1
drop count
replace external=0 if interim==1
replace internal=0 if interim==1

ffind SIC, newvar(FFI48) type(48)	

collapse (sum) internal external, by (FFI48 YEAR)

preserve
collapse (sum) internal_00_14 = internal external_00_14 = external if YEAR>=1993 & YEAR<=2020, by (FFI48)
gen insiders_perc_93_20 = internal_00_14/(internal_00_14+external_00_14)
save perc_insider_93_20, replace
restore

preserve
clear
gen YEAR=1
save perc_insider, replace
restore

local z=2003
while `z'<2021{
	preserve
	local y = `z'-10
	collapse (sum) internal_10yr = internal external_10yr = external if YEAR>=`y' & YEAR<=`z', by (FFI48)
	gen YEAR = `z'
	gen insiders_perc_10yr = internal_10yr/(internal_10yr+external_10yr)

	append using perc_insider
	save perc_insider, replace
	restore
	local z = `z'+1
	}

use perc_insider, clear
merge m:1 FFI48 using perc_insider_93_20 
drop _merge
save "$path/insiders_perc.dta", replace

