cd "D:\Dropbox\EPA Data\Output"
log using step5log

*=================================================================*
*Appendix III Investigation Stage Prediction
cd "D:\Dropbox\EPA Data\Output"

clear
set more off
use case_distance.dta

*=================================================================*

rename *, lower
gen log_distance=log(distance)
gen log_penalty=log(1+penalty)
gen log_ccost=log(1+ccost)


*Final model
reghdfe log_distance expedited sep log_penalty log_ccost, a(primary_law region_code)
predict p_distance
saveold "D:\Dropbox\EPA Data\Output\case_pdistance.dta",replace


reghdfe log_distance expedited sep log_penalty log_ccost, a(primary_law region_code)
estimates store m1
esttab  m1  using "D:\Dropbox\case_pdistance.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(LawFE RegionFE n r2, fmt(0 0 0 3 )) keep(_cons expedited sep log_penalty log_ccost)  
esttab m1 using "D:\Dropbox\case_pdistance.rtf", ar2(4) append keep(_cons)




*=================================================================*
*Tables 2-8 and Figures 2-4;
cd "D:\Dropbox\EPA Data\Output"

clear
set more off
use sample.dta

*=================================================================*
rename *, lower
destring gvkey, replace
destring sic, replace
duplicates drop gvkey date_monthly,force
sort gvkey date_monthly
tsset gvkey date_monthly


*Table 2B
corrtbl edgar total log_total log_resolve_3yr log_mve btm cash tangibility lev zscore_qtl roa sg filings log_filings, ///
corrvars(edgar total log_total log_resolve_3yr log_mve btm cash tangibility lev zscore_qtl roa sg filings log_filings)


*Define variable list
global controls log_resolve_3yr log_mve btm cash tangibility lev zscore_qtl roa sg filings log_filings 
global enforce dum_discover dum_investigate dum_resolve dum_review
global inspect dum_prepare dum_inspect dum_postinspect
global rule dum_preparerule dum_publishrule dum_postrule



*Table 3 Enforcement
ppmlhdfe edgar $enforce, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model0
reghdfe log_total $enforce, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model1
ppmlhdfe edgar $enforce $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model2
reghdfe log_total $enforce $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model3
esttab  model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", nogaps ///
  label replace star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(MonthFE FirmFE n r2, fmt(0 0 0 3 )) keep(_cons $enforce $controls )  
esttab model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", ar2(4) append keep(_cons)



*Table 4 Cross sectional tests
global fa dum_discover dum_investigate dum_resolve dum_review 1.dum_discover#1.facase 1.dum_investigate#1.facase 1.dum_resolve#1.facase 1.dum_review#1.facase facase 
global highcc dum_discover dum_investigate dum_resolve dum_review 1.dum_discover#1.highcc 1.dum_investigate#1.highcc 1.dum_resolve#1.highcc 1.dum_review#1.highcc 1.highcc
global highp dum_discover dum_investigate dum_resolve dum_review 1.dum_discover#1.highp 1.dum_investigate#1.highp 1.dum_resolve#1.highp 1.dum_review#1.highp 1.highp

ppmlhdfe edgar $fa $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store m1
reghdfe log_total $fa $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store m2
ppmlhdfe edgar $highcc $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store m3
reghdfe log_total $highcc $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store m4
ppmlhdfe edgar $highp $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store m5 
reghdfe log_total $highp $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store m6
esttab  m1 m2 m3 m4 m5 m6 using "D:\Dropbox\epa.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(MonthFE FirmFE n r2, fmt(0 0 0 3 )) keep(_cons $fa $highcc $highp)  
esttab m1 m2 m3 m4 m5 m6  using "D:\Dropbox\epa.rtf", ar2(4) append keep(_cons)


*Table 5 Inspection
ppmlhdfe edgar $inspect, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model0
reghdfe log_total $inspect, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model1
ppmlhdfe edgar $inspect $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model2
reghdfe log_total $inspect $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model3
esttab  model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(MonthFE FirmFE n r2, fmt(0 0 0 3 )) keep(_cons $inspect $controls)  
esttab model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", ar2(4) append keep(_cons)

  
*Table 6 Financial review Inspection
global frinspect dum_prepare dum_inspect dum_postinspect 1.dum_prepare#1.fr_inspect 1.dum_inspect#1.fr_inspect 1.dum_postinspect#1.fr_inspect fr_inspect

ppmlhdfe edgar $frinspect $controls , a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model2
reghdfe log_total $frinspect $controls , a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model3
esttab  model2 model3 using "D:\Dropbox\epa.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(MonthFE FirmFE n r2, fmt(0 0 0 3 )) keep(_cons $frinspect )  
esttab model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", ar2(4) append keep(_cons)




*Table 7 Rule making test
ppmlhdfe edgar $rule, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model0 
reghdfe log_total $rule, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model1
ppmlhdfe edgar $rule $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model2
reghdfe log_total $rule $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model3
esttab model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(MonthFE FirmFE n r2, fmt(0 0 0 3 )) keep(_cons $rule $controls)  
esttab model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", ar2(4) append keep(_cons)
 



*Table 8 rules with financial consideration
global fin dum_preparerule dum_publishrule dum_postrule 1.dum_preparerule#1.finrule 1.dum_publishrule#1.finrule 1.dum_postrule#1.finrule finrule

ppmlhdfe edgar $fin $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store model2
reghdfe log_total $fin $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store model3
esttab  model2 model3  using "D:\Dropbox\epa.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(MonthFE FirmFE n r2, fmt(0 0 0 3 )) keep(_cons $fin)  
esttab model0 model1 model2 model3 using "D:\Dropbox\epa.rtf", ar2(4) append keep(_cons)








*==============================================================================*
*Table 9B
cd "D:\Dropbox\EPA Data\Output"
clear
set more off
use case.dta
*==============================================================================*

rename *, lower
duplicates drop case_number,force
keep if edgar==1
global controls log_filings p_distance


*Table 9B
reghdfe log_total liquid1 $controls, absorb(primary_law) vce(r)
est store m1
reghdfe log_total liquid2 $controls, absorb(primary_law) vce(r)
est store m2
reghdfe log_total solv1 $controls, absorb(primary_law) vce(r)
est store m3
reghdfe log_total solv2 $controls, absorb(primary_law) vce(r)
est store m4
reghdfe log_total solv3 $controls, absorb(primary_law) vce(r)
est store m5
reghdfe log_total prof1 $controls, absorb(primary_law) vce(r)
est store m6
reghdfe log_total prof2 $controls, absorb(primary_law) vce(r)
est store m7
esttab  m1 m2 m3 m4 m5 m6 m7 using "D:\Dropbox\ratio.rtf", nogaps ///
  label replace star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons liquid1 liquid2 solv1 solv2 solv3 prof1 prof2) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(NoFE n r2, fmt(0 0 3 )) 
esttab m1 m2 m3 m4 m5 m6 m7 using "D:\Dropbox\ratio.rtf", ar2(4) append keep(_cons)



*==============================================================================*
*Table 9C
cd "D:\Dropbox\EPA Data\Output"
clear
set more off
use inspect.dta
*==============================================================================*


rename *, lower
duplicates drop activity_id,force
keep if edgar==1
global controls log_filings

*Table 9C
reghdfe log_total liquid1 $controls, absorb(statute_code) vce(r)
est store m1
reghdfe log_total liquid2 $controls, absorb(statute_code) vce(r)
est store m2
reghdfe log_total solv1 $controls, absorb(statute_code) vce(r)
est store m3
reghdfe log_total solv2 $controls, absorb(statute_code) vce(r)
est store m4
reghdfe log_total solv3 $controls, absorb(statute_code) vce(r)
est store m5
reghdfe log_total prof1 $controls, absorb(statute_code) vce(r)
est store m6
reghdfe log_total prof2 $controls, absorb(statute_code) vce(r)
est store m7
esttab  m1 m2 m3 m4 m5 m6 m7 using "D:\Dropbox\ratio.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons liquid1 liquid2 solv1 solv2 solv3 prof1 prof2) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(NoFE n r2, fmt(0 0 3 )) 
esttab m1 m2 m3 m4 m5 m6 m7 using "D:\Dropbox\ratio.rtf", ar2(4) append keep(_cons)



*==============================================================================*
*Table 9
cd "D:\Dropbox\EPA Data\Output"
clear
set more off
use rule.dta
*==============================================================================*

rename *, lower
duplicates drop id gvkey,force
keep if edgar==1
global controls log_filings


*Table 9D
reghdfe log_total liquid1 $controls, absorb(primary_law) vce(r)
est store m1
reghdfe log_total liquid2 $controls, absorb(primary_law) vce(r)
est store m2
reghdfe log_total solv1 $controls, absorb(primary_law) vce(r)
est store m3
reghdfe log_total solv2 $controls, absorb(primary_law) vce(r)
est store m4
reghdfe log_total solv3 $controls, absorb(primary_law) vce(r)
est store m5
reghdfe log_total prof1 $controls, absorb(primary_law) vce(r)
est store m6
reghdfe log_total prof2 $controls, absorb(primary_law) vce(r)
est store m7
esttab  m1 m2 m3 m4 m5 m6 m7 using "D:\Dropbox\ratio.rtf", nogaps ///
  label append star(* 0.1049 ** 0.0549 *** 0.0149) parentheses t(2) b(3) ///
  order (_cons liquid1 liquid2 solv1 solv2 solv3 prof1 prof2) coeflabels(_cons "{\i INTERCEPT}") ///
  stats(NoFE n r2, fmt(0 0 3 )) 
esttab m1 m2 m3 m4 m5 m6 m7 using "D:\Dropbox\ratio.rtf", ar2(4) append keep(_cons)



*=================================================================*
*F-statistics  for Tables 4, 6, 8
cd "D:\Dropbox\EPA Data\Output"

clear
set more off
use sample.dta

*=================================================================*
rename *, lower
destring gvkey, replace
destring sic, replace
duplicates drop gvkey date_monthly,force
sort gvkey date_monthly
tsset gvkey date_monthly  
global controls log_resolve_3yr log_mve btm cash tangibility lev zscore_qtl roa sg filings log_filings 
  

  
*Table 4
gen interact=dum_investigate*facase
global fa1 dum_discover dum_investigate dum_resolve dum_review 1.dum_discover#1.facase interact 1.dum_resolve#1.facase 1.dum_review#1.facase facase 


ppmlhdfe edgar $fa1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
test interact+dum_investigate=0
reghdfe log_total $fa1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
test interact+dum_investigate=0


drop interact
gen interact=dum_investigate*highcc
global highcc1 dum_discover dum_investigate dum_resolve dum_review 1.dum_discover#1.highcc interact 1.dum_resolve#1.highcc 1.dum_review#1.highcc 1.highcc

ppmlhdfe edgar $highcc1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
test interact+dum_investigate=0
reghdfe log_total $highcc1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
test interact+dum_investigate=0


drop interact
gen interact=dum_investigate*highp
global highp1 dum_discover dum_investigate dum_resolve dum_review 1.dum_discover#1.highp interact 1.dum_resolve#1.highp 1.dum_review#1.highp 1.highp

ppmlhdfe edgar $highp1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
test interact+dum_investigate=0
reghdfe log_total $highp1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
test interact+dum_investigate=0




*Table 6 Financial review Inspection
drop interact
gen interact=dum_inspect*fr_inspect
global frinspect1 dum_prepare dum_inspect dum_postinspect 1.dum_prepare#1.fr_inspect interact 1.dum_postinspect#1.fr_inspect fr_inspect


ppmlhdfe edgar $frinspect1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
test interact+dum_inspect=0
reghdfe log_total $frinspect1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
test interact+dum_inspect=0




*Table 8 financial consideration rule post month
drop interact
gen interact=dum_postrule*finrule
global fin1 dum_preparerule dum_publishrule dum_postrule 1.dum_preparerule#1.finrule 1.dum_publishrule#1.finrule interact finrule


ppmlhdfe edgar $fin1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
test interact+dum_postrule=0
reghdfe log_total $fin1 $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
test interact+dum_postrule=0






*=================================================================*
*Figure 2-Figure 4
cd "D:\Dropbox\EPA Data\Output"

clear
set more off
use sample.dta

*=================================================================*
rename *, lower
destring gvkey, replace
destring sic, replace
duplicates drop gvkey date_monthly,force
sort gvkey date_monthly
tsset gvkey date_monthly  
global controls log_resolve_3yr log_mve btm cash tangibility lev zscore_qtl roa sg filings log_filings  
global enforce dum_discover dum_investigate dum_resolve dum_review
global inspect dum_prepare dum_inspect dum_postinspect
global rule dum_preparerule dum_publishrule dum_postrule

label variable dum_discover "Discovery"
label variable dum_investigate "Investigation"
label variable dum_resolve "Resolution"
label variable dum_review "Review"
label variable dum_prepare "Pre"
label variable dum_inspect "Inspection"
label variable dum_postinspect "Post"
label variable dum_preparerule "Pre"
label variable dum_publishrule "Proposal"
label variable dum_postrule "Post"


*Figure 2
ppmlhdfe edgar $enforce $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store m1
coefplot (m1, recast(connected) lpattern(dash) levels(90) ciopts(recast(rcap))), label vertical drop(_cons $controls) yline(0) ytitle("Coefficient")ylabel(-0.2(0.1)0.4, angle(0) grid)

reghdfe log_total $enforce $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store m1
coefplot (m1, recast(connected) lpattern(dash) levels(90) ciopts(recast(rcap))), label vertical drop(_cons $controls) yline(0) ytitle("Coefficient")ylabel(-0.02(0.02)0.06, angle(0) grid)

*Figure 3
ppmlhdfe edgar $inspect $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store m2
coefplot (m2, recast(connected) lpattern(dash) levels(90) ciopts(recast(rcap))), label vertical drop(_cons $controls) yline(0) ytitle("Coefficient")ylabel(-0.2(0.1)0.4, angle(0) grid)

reghdfe log_total $inspect $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store m2
coefplot (m2, recast(connected) lpattern(dash) levels(90) ciopts(recast(rcap))), label vertical drop(_cons $controls) yline(0) ytitle("Coefficient") ylabel(-0.02(0.02)0.06, angle(0) grid)

*Figure 4
ppmlhdfe edgar $rule $controls, a(gvkey date_monthly) cl(gvkey date_monthly) separation(simplex)
estimates store m3
coefplot (m3, recast(connected) lpattern(dash) levels(90) ciopts(recast(rcap))), label vertical drop(_cons $controls) yline(0) ytitle("Coefficient")ylabel(-0.2(0.1)0.4, angle(0) grid)

reghdfe log_total $rule $controls, a(gvkey date_monthly) cl(gvkey date_monthly)
estimates store m3
coefplot (m3, recast(connected) lpattern(dash) levels(90) ciopts(recast(rcap))), label vertical drop(_cons $controls) yline(0) ytitle("Coefficient") ylabel(-0.02(0.02)0.06, angle(0) grid)


log close 
translate step5log.smcl step5log.log


