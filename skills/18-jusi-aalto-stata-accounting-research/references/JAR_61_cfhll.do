**************************************************************************************
*** Journal of Accounting Research                                                 ***
*** Reciprocity in Corporate Tax Compliance--Evidence from Ozone Pollution         ***
*** Chow, Fan, Huang, Li and Li (2023)											   ***
*** May, 2023																	   ***
**************************************************************************************

*Figure 1
set more off
cap log close

use "...\main.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
hist ozone8 if cash_etr3 != ., freq xlabel(0.04(0.01)0.185) graphregion(color(white)) xtitle(Ozone (ppm)) ytitle(Number of Observations) fcolor(gs10) lcolor(black) lalign(center)



*Figure 2
reghdfe cash_etr3 ozone_marginal ozone_moderate ozone_serious ozone_severeandextreme median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc, ///
absorb(fyear gvkey) vce(cluster state)

coefplot, drop(_cons cash_etr3 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc) omitted mcolor(black) msymbol(Oh) vertical byopts(yrescale) recast(connected) ciopts(recast(rarea) lpattern(dash) color(ltblue%45))  ytitle(Point Estimate) xtitle(Ozone Levels) yline(0, lcolor(black)) lcolor(black) lwidth(medthick) coeflabels(ozone_marginal ="Marginal" ozone_moderate="Moderate" ozone_serious="Serious" ozone_severeandextreme="Severe/Extreme", labsize(small)) graphregion(color(white))


*Figure 3 
**Figure 3 Panel A
set more off
cap log close

use "...\ptcombine.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
egen reg2 = group(reg)
egen reggvkey = group(reg gvkey)
egen regfyear = group(reg fyear)

gen period1=0
replace period1=1 if period==1
gen period2=0
replace period2=1 if period==2
gen period3=0
replace period3=1 if period==3
gen period0=0
replace period0=1 if period==0
gen period5=0
replace period5=1 if period==5
gen period6=0
replace period6=1 if period==6
gen period7=0
replace period7=1 if period==7
gen period8=0
replace period8=1 if period==8

gen treatXperiod1= period1*treat
gen treatXperiod2= period2*treat
gen treatXperiod3= period3*treat
gen treatXperiod0= period0*treat
gen treatXperiod5= period5*treat
gen treatXperiod6= period6*treat
gen treatXperiod7= period7*treat
gen treatXperiod8= period8*treat

qui reghdfe cash_etr3 treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod5 treatXperiod6 treatXperiod7 treatXperiod0, ///
absorb(reggvkey regfyear i.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc)) vce(cluster state)

coefplot, drop(_cons cash_etr3) omitted mcolor(black) msymbol(Oh) vertical byopts(yrescale) recast(connected) ciopts(recast(rarea) lpattern(dash) color(ltblue%45))  ytitle(Point Estimate) xtitle(Period) yline(0, lcolor(black)) lcolor(black) lwidth(medthick) order(treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod0 treatXperiod5 treatXperiod6 treatXperiod7) coeflabels(treatXperiod1="t-11 : t-9" treatXperiod2="t-8 : t-6" treatXperiod3="t-5 : t-3" treatXperiod0="t-2 : t" treatXperiod5="t+1 : t+3" treatXperiod6="t+4 : t+6" treatXperiod7="t+7 : t+9", labsize(small)) graphregion(color(white))

**Figure 3 Panel B 
set more off
cap log close

use "...\ptcombine.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
keep if bandwidth15==1

egen reg2 = group(reg)
egen reggvkey = group(reg gvkey)
egen regfyear = group(reg fyear)

gen period1=0
replace period1=1 if period==1
gen period2=0
replace period2=1 if period==2
gen period3=0
replace period3=1 if period==3
gen period0=0
replace period0=1 if period==0
gen period5=0
replace period5=1 if period==5
gen period6=0
replace period6=1 if period==6
gen period7=0
replace period7=1 if period==7
gen period8=0
replace period8=1 if period==8

gen treatXperiod1= period1*treat
gen treatXperiod2= period2*treat
gen treatXperiod3= period3*treat
gen treatXperiod0= period0*treat
gen treatXperiod5= period5*treat
gen treatXperiod6= period6*treat
gen treatXperiod7= period7*treat
gen treatXperiod8= period8*treat

qui reghdfe cash_etr3 treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod5 treatXperiod6 treatXperiod7 treatXperiod0, ///
absorb(reggvkey regfyear i.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc)) vce(cluster state)

coefplot, drop(_cons cash_etr3) omitted mcolor(black) msymbol(Oh) vertical byopts(yrescale) recast(connected) ciopts(recast(rarea) lpattern(dash) color(ltblue%45))  ytitle(Point Estimate) xtitle(Period) yline(0, lcolor(black)) lcolor(black) lwidth(medthick) order(treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod0 treatXperiod5 treatXperiod6 treatXperiod7) coeflabels(treatXperiod1="t-11 : t-9" treatXperiod2="t-8 : t-6" treatXperiod3="t-5 : t-3" treatXperiod0="t-2 : t" treatXperiod5="t+1 : t+3" treatXperiod6="t+4 : t+6" treatXperiod7="t+7 : t+9", labsize(small)) graphregion(color(white))

**Figure 3 Panel C
set more off
cap log close
 
use "...\ptcombine.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
keep if bandwidth10==1

egen reg2 = group(reg)
egen reggvkey = group(reg gvkey)
egen regfyear = group(reg fyear)

gen period1=0
replace period1=1 if period==1
gen period2=0
replace period2=1 if period==2
gen period3=0
replace period3=1 if period==3
gen period0=0
replace period0=1 if period==0
gen period5=0
replace period5=1 if period==5
gen period6=0
replace period6=1 if period==6
gen period7=0
replace period7=1 if period==7
gen period8=0
replace period8=1 if period==8

gen treatXperiod1= period1*treat
gen treatXperiod2= period2*treat
gen treatXperiod3= period3*treat
gen treatXperiod0= period0*treat
gen treatXperiod5= period5*treat
gen treatXperiod6= period6*treat
gen treatXperiod7= period7*treat
gen treatXperiod8= period8*treat

qui reghdfe cash_etr3 treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod5 treatXperiod6 treatXperiod7 treatXperiod0, ///
absorb(reggvkey regfyear i.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc)) vce(cluster state)

coefplot, drop(_cons cash_etr3) omitted mcolor(black) msymbol(Oh) vertical byopts(yrescale) recast(connected) ciopts(recast(rarea) lpattern(dash) color(ltblue%45))  ytitle(Point Estimate) xtitle(Period) yline(0, lcolor(black)) lcolor(black) lwidth(medthick) order(treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod0 treatXperiod5 treatXperiod6 treatXperiod7) coeflabels(treatXperiod1="t-11 : t-9" treatXperiod2="t-8 : t-6" treatXperiod3="t-5 : t-3" treatXperiod0="t-2 : t" treatXperiod5="t+1 : t+3" treatXperiod6="t+4 : t+6" treatXperiod7="t+7 : t+9", labsize(small)) graphregion(color(white))



*Figure 4
set more off
cap log close
 
use "...\superfund_did.dta", clear
foreach var of varlist * {
	  rename `var' `=strlower("`var'")'
}

egen reggvkey = group(epaid gvkey)
egen reg2 = group(epaid)
egen regfyear = group(epaid fyear)

gen period1=0
replace period1=1 if period==1
gen period2=0
replace period2=1 if period==2
gen period3=0
replace period3=1 if period==3
gen period0=0
replace period0=1 if period==0
gen period5=0
replace period5=1 if period==4
gen period6=0
replace period6=1 if period==5
gen period7=0
replace period7=1 if period==6

gen treatXperiod1= period1*treat
gen treatXperiod2= period2*treat
gen treatXperiod3= period3*treat
gen treatXperiod0= period0*treat
gen treatXperiod5= period5*treat
gen treatXperiod6= period6*treat
gen treatXperiod7= period7*treat

qui reghdfe cash_etr3 treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod5 treatXperiod6 treatXperiod7 treatXperiod0, ///
absorb(reggvkey regfyear i.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc)) vce(cluster state)

coefplot, drop(_cons cash_etr3) omitted mcolor(black) msymbol(Oh) vertical byopts(yrescale) recast(connected) ciopts(recast(rarea) lpattern(dash) color(ltblue%45))  ytitle(Point Estimate) xtitle(Period) yline(0, lcolor(black)) lcolor(black) lwidth(medthick) order(treatXperiod1 treatXperiod2 treatXperiod3 treatXperiod0 treatXperiod5 treatXperiod6 treatXperiod7) coeflabels(treatXperiod1="t-3" treatXperiod2="t-2" treatXperiod3="t-1" treatXperiod0="cleanup" treatXperiod5="z+1" treatXperiod6="z+2" treatXperiod7="z+3", labsize(small)) graphregion(color(white))



*Table 2: baseline regressions
set more off
cap log close

use "...\main.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

qui xi: reghdfe cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp, ///
absorb(fyear gvkey) vce(cluster state)
est store m1
qui xi: reghdfe cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc, ///
absorb(fyear gvkey) vce(cluster state)
est store m2

esttab m1 m2 using table2.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Oster test
qui tab fyear, gen (dfyear)
egen gvkey2 = group(gvkey)
xtset gvkey2
xtreg cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc dfyear1-dfyear24, fe

display e(r2)
gen r2= 1.3*e(r2)
display r2
				
psacalc delta ozone8, rmax(.05986235) mcontrol(dfyear1 dfyear2 dfyear3 dfyear4 dfyear5 dfyear6 dfyear7 dfyear8 dfyear9 dfyear10 dfyear11 dfyear12 dfyear13 dfyear14 dfyear15 dfyear16 dfyear17 dfyear18 dfyear19 dfyear20 dfyear21 dfyear22 dfyear23 dfyear24)
psacalc beta ozone8, rmax(.05986235) mcontrol(dfyear1 dfyear2 dfyear3 dfyear4 dfyear5 dfyear6 dfyear7 dfyear8 dfyear9 dfyear10 dfyear11 dfyear12 dfyear13 dfyear14 dfyear15 dfyear16 dfyear17 dfyear18 dfyear19 dfyear20 dfyear21 dfyear22 dfyear23 dfyear24)


*Table 3
**Table 3A: high dimension FE
egen stateyear = group(fyear state)
egen stateindyear = group(fyear state sic2)

qui xi: reghdfe cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc, ///
absorb(stateyear gvkey) vce(cluster state)
est store m1
qui xi: reghdfe cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc, ///
absorb(stateindyear gvkey) vce(cluster state)
est store m2

esttab m1 m2 using table3a.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Table 3B Column (1)
set more off
cap log close

use "...\prediction.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

qui xi: reghdfe ozone8 log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa, ///
absorb(county_fips fyear) vce(cluster state)
est store m1

esttab m1 using table3b1.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Table 3B Column (2): account for endogeneity of ozone level
set more off
cap log close

use "...\main.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

qui xi: reghdfe cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa, ///
absorb(fyear gvkey) vce(cluster state)
est store m1

esttab m1 using table3b2.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Oster test
qui tab fyear, gen (dfyear)
egen gvkey2 = group(gvkey)
xtset gvkey2
xtreg cash_etr3 ozone8 median_income income_inequality education age urban rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev nol change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa dfyear1-dfyear24, fe
est store m1

display e(r2)
gen r2_2= 1.3*e(r2)
display r2_2
				
psacalc delta ozone8, rmax(.06551942) mcontrol(dfyear1 dfyear2 dfyear3 dfyear4 dfyear5 dfyear6 dfyear7 dfyear8 dfyear9 dfyear10 dfyear11 dfyear12 dfyear13 dfyear14 dfyear15 dfyear16 dfyear17 dfyear18 dfyear19 dfyear20 dfyear21 dfyear22 dfyear23 dfyear24)
psacalc beta ozone8, rmax(.06551942) mcontrol(dfyear1 dfyear2 dfyear3 dfyear4 dfyear5 dfyear6 dfyear7 dfyear8 dfyear9 dfyear10 dfyear11 dfyear12 dfyear13 dfyear14 dfyear15 dfyear16 dfyear17 dfyear18 dfyear19 dfyear20 dfyear21 dfyear22 dfyear23 dfyear24)



*Table 4: Attention to ozone/air pollution
pwcorr ozone8 medianozone8 ap ozonep, sig

center ozone8 ap ozonep medianozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & ap !=. & ozonep !=., s prefix(std_) 

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_ozonep c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m1
qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_ap c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c..nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m2
qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_ozonep c.std_medianozone8 c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m3
qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_ap c.std_medianozone8 c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c..nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m4

esttab m1 m2 m3 m4 using table4.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc



*Table 5
**Table 5 Pane A 
set more off
cap log close

use "...\nonattain_did_county.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
egen regcounty = group(reg county_fips)
egen reg2 = group(reg)
egen regfyear = group(reg fyear)

gen treatxpost=treat*post

xi: areg ozone3y treatxpost treat post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud) i.regfyear, absorb(regcounty) vce(cluster state)
est store m1
qui xi: areg ozone3y treatxpost treat post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud) i.regfyear, absorb(regcounty) vce(cluster state), if bandwidth15==1
est store m2
qui xi: areg ozone3y treatxpost treat post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud) i.regfyear, absorb(regcounty) vce(cluster state), if bandwidth10==1
est store m3

esttab m1 m2 m3 using table5a.rtf,replace cells(b(star fmt(3)) t(par fmt(2))) ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Table 5 Panel B
set more off
cap log close

use "...\nonattain_did.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
egen reggvkey = group(reg gvkey)
egen reg2 = group(reg)
egen regfyear = group(reg fyear)

qui xi: reghdfe cash_etr3 c.treat##c.post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc), ///
absorb(reggvkey regfyear) vce(cluster state)
est store m1
qui xi: reghdfe cash_etr3 c.treat##c.post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc), ///
absorb(reggvkey regfyear) vce(cluster state), if bandwidth15==1
est store m2
qui xi: reghdfe cash_etr3 c.treat##c.post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc), ///
absorb(reggvkey regfyear) vce(cluster state), if bandwidth10==1
est store m3

esttab m1 m2 m3 using table5b.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Table 5 Panel C
set more off
cap log close

use "...\prediction_did.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
qui xi: probit treat log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa i.reg, vce(cluster state)
est store m1
qui margins, dydx(log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa) post
est store ame1
qui xi: probit treat log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa i.reg, vce(cluster state), if bandwidth15==1
est store m2
qui margins, dydx(log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa) post
est store ame2
qui xi: probit treat log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa i.reg, vce(cluster state), if bandwidth10==1
est store m3
qui margins, dydx(log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth localrep_msa dlocalrep_msa) post
est store ame3

esttab m1 ame1 m2 ame2 m3 ame3 using table5c.rtf,replace cells(b(star fmt(3)) t(par fmt(2))) indicate("Event Fixed Effects = *_Ireg*") ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) scalars("N Observations" "r2_p Pseudo R-square" "chi2 Chi-square" "p p-value") sfmt(0 3 3 3) collabels(none) label ///
title(Table 1)

**Table 5 Panel D
set more off
cap log close

use "...\did_morecontrols.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
egen reggvkey = group(reg gvkey)
egen reg2 = group(reg)
egen regfyear = group(reg fyear)

qui xi: reghdfe cash_etr3 c.treat##c.post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc c.log_population c.log_realgdp c.log_employment c.population_growth c.realgdp_growth c.employment_growth c.log_total_expenditure c.total_expenditure_growth c.localrep_msa c.dlocalrep_msa), ///
absorb(reggvkey regfyear) vce(cluster state)
est store m1
qui xi: reghdfe cash_etr3 c.treat##c.post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc c.log_population c.log_realgdp c.log_employment c.population_growth c.realgdp_growth c.employment_growth c.log_total_expenditure c.total_expenditure_growth c.localrep_msa c.dlocalrep_msa), ///
absorb(reggvkey regfyear) vce(cluster state), if bandwidth15==1
est store m2
qui xi: reghdfe cash_etr3 c.treat##c.post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc c.log_population c.log_realgdp c.log_employment c.population_growth c.realgdp_growth c.employment_growth c.log_total_expenditure c.total_expenditure_growth c.localrep_msa c.dlocalrep_msa), ///
absorb(reggvkey regfyear) vce(cluster state), if bandwidth10==1
est store m3

esttab m1 m2 m3 using table5d.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

*****
tab regfyear, gen (dregfyear)
gen treatxpost = treat*post

*full sample
xtset reggvkey

xtreg cash_etr3 treatxpost treat post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc c.log_population c.log_realgdp c.log_employment c.population_growth c.realgdp_growth c.employment_growth c.log_total_expenditure c.total_expenditure_growth c.localrep_msa c.dlocalrep_msa) dregfyear1-dregfyear4, fe
est store m1

display e(r2)
gen r2b= 1.3*e(r2)
display r2b
				
psacalc delta treatxpost, rmax(.32199949) mcontrol(dregfyear1 dregfyear2 dregfyear3 dregfyear4)
psacalc beta treatxpost, rmax(.32199949) mcontrol(dregfyear1 dregfyear2 dregfyear3 dregfyear4)

*****************

*NAAQS 0.015
xtset reggvkey

xtreg cash_etr3 treatxpost treat post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc c.log_population c.log_realgdp c.log_employment c.population_growth c.realgdp_growth c.employment_growth c.log_total_expenditure c.total_expenditure_growth c.localrep_msa c.dlocalrep_msa) dregfyear1-dregfyear4, fe, if bandwidth15==1
est store m1

display e(r2)
gen r2d= 1.3*e(r2)
display r2d
				
psacalc delta treatxpost, rmax(.33870593) mcontrol(dregfyear1 dregfyear2 dregfyear3 dregfyear4)
psacalc beta treatxpost, rmax(.33870593) mcontrol(dregfyear1 dregfyear2 dregfyear3 dregfyear4)

******************

*NAAQS 0.010
xtset reggvkey

xtreg cash_etr3 treatxpost treat post c.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc c.log_population c.log_realgdp c.log_employment c.population_growth c.realgdp_growth c.employment_growth c.log_total_expenditure c.total_expenditure_growth c.localrep_msa c.dlocalrep_msa) dregfyear1-dregfyear4, fe, if bandwidth10==1
est store m1

display e(r2)
gen r2f= 1.3*e(r2)
display r2f
				
psacalc delta treatxpost, rmax(.40609401) mcontrol(dregfyear1 dregfyear2 dregfyear3 dregfyear4)
psacalc beta treatxpost, rmax(.40609401) mcontrol(dregfyear1 dregfyear2 dregfyear3 dregfyear4)



*Table 6
set more off
cap log close

use "...\main.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

**Table 6 Column (1) child percentage
center ozone8 age_kid_pct median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . , s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_age_kid_pct c.std_median_income c.std_income_inequality c.std_education c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m1

drop std_ozone8 std_age_kid_pct std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

**Table 6 Column (2) child asthma percentage
center ozone8 casthdx median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & casthdx != ., s prefix(std_) 

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_casthdx c.std_median_income c.std_income_inequality c.std_education c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m2

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

esttab m1 m2 using table6.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear



*Table 7
**Table 7 Column (1) labor violation
center ozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & dpenalty != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.dpenalty c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m1

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

**Table 7 Column (2,3) culture of respect
center ozone8 s_integrity s_teamwork s_innovation s_respect s_quality median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & s_respect != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_s_respect c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m2
qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_s_integrity c.std_s_teamwork c.std_s_innovation c.std_s_respect c.std_s_quality c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud  c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m3

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

**Table 7 Column (4) U.S. born CEO
center ozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & us_ceo != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.us_ceo c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m4

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

esttab m1 m2 m3 m4 using table7.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear



*Table 8
**Table 8 Column (1) road traffic
center ozone8 daily_vehicle0 annual_excess_fuel_consumed0 annual_hours_of_delay_total0 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & daily_vehicle0 != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_daily_vehicle0 c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m1

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

**Table 8 Column (2) emitters of ozone precursors
center ozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc urban nol if cash_etr3 != . & pollute != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(i.pollute c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m2

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

esttab m1 m2 using table8.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear



*Table 9
**Panel A: political preference and alignment
***Table 9A Column (1) manager
center ozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & (srep==1 | sdem==1), s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.srep c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state), if srep==1 | sdem==1
est store m1

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

***Table 9A Column (2) MSA
center ozone8 localrep_msa median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & localrep_msa != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_localrep_msa c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m2

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

***Table 9A Column (3) political alignment with the President
center ozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & (srep==1 | sdem==1) &president_rep != ., s prefix(std_)

gen std_ozone8xdemceo_reppre=std_ozone8*demceo_reppre
gen std_ozone8xrepceo_reppre=std_ozone8*repceo_reppre
gen std_ozone8xrepceo_dempre=std_ozone8*repceo_dempre

qui xi: reghdfe cash_etr3 std_ozone8xdemceo_reppre std_ozone8xrepceo_reppre std_ozone8xrepceo_dempre std_ozone8 demceo_reppre repceo_reppre repceo_dempre c.std_ozone8##(c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud  c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), absorb(fyear gvkey) vce(cluster state)
est store m3

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

***Table 9A Column (4) political alignment with the state population
center ozone8 median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != . & (srep==1 | sdem==1), s prefix(std_)

gen std_ozone8xdemceo_reploc=std_ozone8*demceo_reploc
gen std_ozone8xrepceo_reploc=std_ozone8*repceo_reploc
gen std_ozone8xrepceo_demloc=std_ozone8*repceo_demloc

qui xi: reghdfe cash_etr3 std_ozone8xdemceo_reploc std_ozone8xrepceo_reploc std_ozone8xrepceo_demloc std_ozone8 demceo_reploc repceo_reploc repceo_demloc c.std_ozone8##(c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_social_capital c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), ///
absorb(fyear gvkey) vce(cluster state)
est store m4

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc

esttab m1 m2 m3 m4 using table9a.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Table 9 Panel B: civic norms
center ozone8 pvote respn median_income income_inequality education age rel social_capital statetaxrate cloud temp wind prec1 dptemp roa lev change_nol foreign_income equity_income ppe intangible rd ads sga size mb instown_perc if cash_etr3 != ., s prefix(std_)

qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_pvote c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), absorb(fyear gvkey) vce(cluster state)
est store m1
qui xi: reghdfe cash_etr3 c.std_ozone8##(c.std_respn c.std_median_income c.std_income_inequality c.std_education c.std_age c.urban c.std_rel c.std_statetaxrate c.std_temp c.std_wind c.std_dptemp c.std_prec1 c.std_cloud   ///
c.std_roa c.std_lev c.nol c.std_change_nol c.std_foreign_income c.std_equity_income c.std_ppe c.std_intangible c.std_rd c.std_ads c.std_sga c.std_size c.std_mb c.std_instown_perc), absorb(fyear gvkey) vce(cluster state)
est store m2

esttab m1 m2 using table9b.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

drop std_ozone8 std_median_income std_income_inequality std_education std_age std_rel std_social_capital std_statetaxrate std_temp std_wind std_dptemp std_prec1 std_cloud std_roa std_lev std_change_nol std_foreign_income std_equity_income std_ppe std_intangible std_rd std_ads std_sga std_size std_mb std_instown_perc



*Table 10 
**Table 10 Panel A
use "...\CCES.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}
gen faminc1=faminc*d_income1
gen faminc2=faminc*d_income2

qui xi: reghdfe trustgov ozone8, absorb(year countyfips gender race educ marstat birthyr ideology faminc1 faminc2) vce(cluster state)
est store m1
qui xi: reghdfe trustgov ozone8 log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth, absorb(year countyfips gender race educ marstat birthyr ideology faminc1 faminc2) vce(cluster state)
est store m2

esttab m1 m2 using table10a.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear

**Table 10 Panel B
use "...\pew.dta", clear
foreach var of varlist * {
  rename `var' `=strlower("`var'")'
}

tab rairpollution, gen (drairpollution)

sum toolittle

qui xi: probit toolittle drairpollution2 drairpollution3 i.f_cregion_final i.f_agecat_final i.f_sex_final i.f_educcat_final i.f_racethn_recruitment i.f_citizen_recode_final i.f_marital_final i.f_relig_final i.f_partysum_final i.f_income_final, vce(robust)
est store m1
qui margins, dydx(drairpollution2 drairpollution3) post
est store ame1

esttab m1 ame1 using table10b.rtf,replace cells(b(star fmt(3)) t(par fmt(2))) ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) scalars("N Observations" "r2_p Pseudo R-square" "chi2 Chi-square" "p p-value") sfmt(0 3 3 3) collabels(none) label ///
title(Table 1)

**Table 10 Panel C, note that the code can only be run on the server (sensitive data)
use "...\anes_combine_ind.dta", clear

foreach var of varlist * {
	  rename `var' `=strlower("`var'")'
}

qui reghdfe wastetax ozone8, absorb(year county_code gender age_group party) vce(cluster state)
est store m1
qui reghdfe wastetax ozone8 log_total_expenditure log_population log_realgdp log_employment total_expenditure_growth population_growth realgdp_growth employment_growth, absorb(year county_code gender age_group party) vce(cluster state)
est store m2

esttab m1 m2 using baseline1.rtf, replace cells(b(star fmt(3)) t(par fmt(2))) ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons intercept) stats(N r2_a, fmt(0 3) label("N" "Adj. R-squared")) collabels(none) label ///
title(Table 1)
est clear



*Table 11
use "...\superfund_did.dta", clear
foreach var of varlist * {
	  rename `var' `=strlower("`var'")'
}
egen reggvkey = group(epaid gvkey)
egen reg2 = group(epaid)
egen regfyear = group(epaid fyear)

qui reghdfe cash_etr3 c.treat##c.during c.treat##c.after , ///
absorb(reggvkey regfyear i.reg2##(c.median_income c.income_inequality c.education c.age c.urban c.rel c.social_capital c.statetaxrate c.temp c.wind c.dptemp c.prec1 c.cloud c.roa c.lev c.nol c.change_nol c.foreign_income c.equity_income c.ppe c.intangible c.rd c.ads c.sga c.size c.mb c.instown_perc)) vce(cluster state)
est store m1

esttab m1 using table11.rtf,replace cells(b(star fmt(3)) t(par fmt(2)))  ///
starlevels(* 0.10 ** 0.05 *** 0.01) legend varlabels(_cons Intercept) stats(N_full N N_clust r2_a, fmt(0 0 0 3) label("N" "N(excluding singletons)" "N of clusters" "Adj. R-squared")) collabels(none) label ///
title(Table 1)



















