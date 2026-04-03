
clear
set more off


*************************************************************************************
* to run the code for all our analyses below, the following three datasets are needed
* FINAL_SAMPLE: our main dataset with IPO, EGC, all financial data
* IND_MTB_FF17: Industry M/B and P/E data at the famafrench 17 industry levels
* HIGHTECH: SIC codes for hightech industries 
*************************************************************************************


******* TABLE 2: Sumary Statistics

use FINAL_SAMPLE, clear

* three sets of IPO firms
* egcbyrev==1, Actual EGC IPOs "after" the Act
* egcbyrev==0, EGC-qualifying IPOs "before" the Act
* egcbyrev==. (missing), all other IPOs that do not qaulity EGC status

keep if !missing(egcbyrev)

*mean and median difference test results are by default [egcbyrev==0 - egcbyrec==1], so reverse the order on purpose
*to get results for [egcbyrev==1 - egcbyrec==0]
gen reverse_egcbyrev=!egcbyrev


est clear
estpost summ sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n acctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter if egcbyrev==1, detail  
esttab using full_summ_byEGC.csv, cell("mean(fmt(2)) p50(lab(median)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant replace

estpost summ sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n acctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter if egcbyrev==0, detail
esttab using full_summ_byEGC.csv, cell("mean(fmt(2)) p50(lab(median)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant append

*mean difference test
estpost ttest sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n wacctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter , by(reverse_egcbyrev) 
esttab using full_summ_byEGC.csv, cell("b(lab(mean diff) star fmt(2))") nonumber nonotes eqlabels("") noconstant label star(* 0.10 ** 0.05 *** 0.01) append

*median difference test
median sale, by(reverse_egcbyrev)
median sale_CPIadj1, by(reverse_egcbyrev)
median asset, by(reverse_egcbyrev)
median booklev, by(reverse_egcbyrev)
median ppenet_asset, by(reverse_egcbyrev)
median rnd_asset, by(reverse_egcbyrev)
median drnd, by(reverse_egcbyrev)
median salegr, by(reverse_egcbyrev)
median age, by(reverse_egcbyrev)
median unprofitable, by(reverse_egcbyrev)
median dum_VC, by(reverse_egcbyrev)
median proceeds, by(reverse_egcbyrev)
median proceeds_CPIadj1, by(reverse_egcbyrev)
median avrg_uwmktsh, by(reverse_egcbyrev)
median diffdate, by(reverse_egcbyrev)
median dp, by(reverse_egcbyrev)
median dp_p, by(reverse_egcbyrev)
median acctlegalpct, by(reverse_egcbyrev)
median wgspreadpct_new, by(reverse_egcbyrev)
median totfeepct, by(reverse_egcbyrev)
median ir, by(reverse_egcbyrev)
median totcost, by(reverse_egcbyrev)
median nasdaq90d, by(reverse_egcbyrev)
median nreg_filter, by(reverse_egcbyrev)


******* TABLE 3 & 4: Propensity Score Matching + OLS or Diff-in-diff

use FINAL_SAMPLE, clear

keep if !missing(egcbyrev)

drop if missing(acctlegalpct) & egcatipo!=1
drop if missing(wgspreadpct_new) & egcatipo!=1 
drop if missing(dp)  & egcatipo!=1

gen treated=(src==0)
gen post=(idate>=date("4/5/2012","MDY",2003))
gen treated_post=treated*post

*For matching, we use FF17 instead of FF50
drop famafrench
do famafrench17

joinby famafrench yr qt using IND_MTB_FF17, unmatched(master) update
tab _merge
drop _merge

label var indprc_earn17 "Ind P/E"

bys famafrench: egen negcipos=sum(egcipo)
tab famafrench egcipo


*psmtch for each ff industry
*aggregate several ff industries when those industries do not have enough control IPOs to match with

gen sample=.

foreach i of numlist 7 11 16 17 {
	di "famafrench `i'"
	psmatch2 egcipo lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if famafrench==`i', n(1) logit norepla
	replace sample=_weight if famafrench==`i'
}

gen pscore=_pscore

psmatch2 egcipo lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15, n(1) logit norepla
replace sample=_weight if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15
replace pscore=_pscore if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15


*restrict to the psmatch sample
keep if !missing(sample)
tab egcipo

gen reverse_egcipo=!egcipo


******* TABLE 3, Panel A

est clear
estpost summ lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if egcipo==1, detail  
esttab using psmmatchedsample.csv, cell("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(lab(median) fmt(3)) max(fmt(3)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant replace

estpost summ lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if egcipo==0, detail
esttab using psmmatchedsample.csv, cell("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(lab(median) fmt(3)) max(fmt(3)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant append

estpost ttest lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17, by(reverse_egcipo) 
esttab using psmmatchedsample.csv, cell("b(lab(mean diff) star fmt(3)) t(lab(t-stat) fmt(2))") nonumber nonotes eqlabels("") noconstant label star(* 0.10 ** 0.05 *** 0.01) append


******* TABLE 3, Panel B: OLS

est clear
eststo: xi: reg totfeepct egcbyrev lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==0, robust cluster(ff_yr_qt) 
eststo: xi: reg totfeepct egcbyrev lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==1, robust cluster(ff_yr_qt) 
eststo: xi: reg ir egcbyrev dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==0, robust cluster(ff_yr_qt) 
eststo: xi: reg ir egcbyrev dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==1 , robust cluster(ff_yr_qt) 

esttab using psm_ols.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* TABLE 4: Diff-in-Diff

est clear

eststo: xi: reg acctlegalpct treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg wgspreadpct_new treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg totfeepct treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg ir treated_post treated post dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench , robust cluster(ff_yr_qt) 
eststo: xi: reg totcost treated_post treated post dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
esttab using psm_dd.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* TABLE 5: Regression Discontinuity with SRC (After the Act)

use FINAL_SAMPLE, clear

*restrict the sample to actual EGCs after the Act
keep if egcbyrev==1

gen nosrc=(proceeds>75)
gen x = proceeds-75
gen nosrc_x=nosrc*x

label var nosrc "Non-SRC"
label var x "(Proceeds-75)"
label var nosrc_x "Non-SRC x (Proceeds-75)"
label var ir "Initial Return"
label var proceeds "Proceeds"


est clear
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=50 & proceeds<=100, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=30 & proceeds<=120, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=0 & proceeds<=150, robust cluster(ff_yr_qt) 
esttab using rd_ir.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 2: McCrary Test of Proceeds

preserve
keep if proceeds>=0 & proceeds<=300
DCdensity proceeds, breakpoint(75) generate(Xj Yj r0 fhat se_fhat) 
graph export McCrary.png, replace
restore


******* Figure 3: Regression Discontinuity around SRC Threshold

preserve
drop if ir>100
twoway (scatter ir proceeds, mcolor(gs10) msize(tiny)) ///
(lfit ir proceeds if proceeds<=75, lcolor(navy) lwidth(medthick)) ///
(lfit ir proceeds if proceeds>75, lcolor(maroon) lwidth(medthick)) ///
if proceeds>=50 & proceeds<=100, xline(75, lcolor(gs6) lpattern(dash)) legend(off) xtitle(Proceeds) ytitle(Initial Return (%)) yscale(range(-30,100)) ylabel(-20(20)100)
graph export rd.png, replace
restore


******* TABLE 5: Regression Discontinuity with SRC (Before the Act)
use FINAL_SAMPLE, clear

*restrict the sample to EGC-qualifying IPOs before the Act
keep if egcbyrev==0

gen nosrc=(proceeds>75)
gen x = proceeds-75
gen nosrc_x=nosrc*x

label var nosrc "Non-SRC"
label var x "(Proceeds-75)"
label var nosrc_x "Non-SRC x (Proceeds-75)"
label var ir "Initial Return"
label var proceeds "Proceeds"


est clear
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=50 & proceeds<=100, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=30 & proceeds<=120, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=0 & proceeds<=150, robust cluster(ff_yr_qt) 
esttab using rd_ir_preAct.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 2: McCrary Test of Proceeds

preserve
keep if proceeds>=0 & proceeds<=300
DCdensity proceeds, breakpoint(75) generate(Xj Yj r0 fhat se_fhat) 
graph export McCrary_preAct.png, replace
restore


******* Figure 3: Regression Discontinuity around SRC Threshold

preserve
drop if ir>100
twoway (scatter ir proceeds, mcolor(gs10) msize(tiny)) ///
(lfit ir proceeds if proceeds<=75, lcolor(navy) lwidth(medthick)) ///
(lfit ir proceeds if proceeds>75, lcolor(maroon) lwidth(medthick)) ///
if proceeds>=50 & proceeds<=100, xline(75, lcolor(gs6) lpattern(dash)) legend(off) xtitle(Proceeds) ytitle(Initial Return (%)) yscale(range(-30,100)) ylabel(-20(20)100)
graph export rd_preAct.png, replace
restore


******* Table 6: JOBS Act Provisions

use FINAL_SAMPLE, clear

keep if egcipo==1

gen ttw_yes=1 if  testwaters==1 & egcatipo==1
replace ttw_yes=0 if  testwaters==0 & egcatipo==1
replace ttw_yes=0 if  testwaters==-1 & egcatipo==1

gen ttw_no=1 if testwaters==0 & egcatipo==1
replace ttw_no=0 if testwaters==1 & egcatipo==1
replace ttw_no=0 if testwaters==-1 & egcatipo==1

gen ttw_yesmay=1 if testwaters==1  & egcatipo==1
replace ttw_yesmay=1 if testwaters==-1 & egcatipo==1
replace ttw_yesmay=0 if testwaters==0 & egcatipo==1

gen soxvoted_yes=0
replace soxvoted_yes=1 if sox_yes==1
replace soxvoted_yes=1 if voted_yes==1

gen soxvoted_no=0
replace soxvoted_no=1 if sox_no==1
replace soxvoted_no=1 if voted_no==1

gen soxvoted_yesmay=0
replace soxvoted_yesmay=1 if sox_yes==1
replace soxvoted_yesmay=1 if sox_may==1
replace soxvoted_yesmay=1 if voted_yes==1
replace soxvoted_yesmay=1 if voted_may==1

gen egcchoice_yes=confidential_yes+sox_yes+execcomp_yes+voted_yes+newrule_yes+financial_yes+ttw_yes
gen egcchoice_no=confidential_no+sox_no+execcomp_no+voted_no+newrule_no+financial_no+ttw_no
gen egcchoice_may=sox_may+execcomp_may+voted_may+newrule_may+financial_may
gen egcchoice_yesmay=confidential_yesmay+sox_yesmay+execcomp_yesmay+voted_yesmay+newrule_yesmay+financial_yesmay+ttw_yesmay


gen period=.
replace period=1 if idate>=date("4/5/2012","MDY",2012) & idate<date("4/4/2013","MDY",2012)
replace period=2 if idate>=date("4/5/2013","MDY",2012) & idate<date("4/4/2014","MDY",2012)
replace period=3 if idate>=date("4/5/2014","MDY",2012) & idate<date("4/30/2015","MDY",2012)


tab confidential if egcatipo==1 
bys period: tab confidential if egcatipo==1 

tab testwaters if egcatipo==1 
bys period: tab testwaters if egcatipo==1 

tab financial if egcatipo==1 
bys period: tab financial if egcatipo==1 

tab execcomp if egcatipo==1 
bys period: tab execcomp if egcatipo==1 

tab sox if egcatipo==1 
bys period: tab sox if egcatipo==1 

tab voted if egcatipo==1 
bys period: tab voted if egcatipo==1 

tab newrule if egcatipo==1 
bys period: tab newrule if egcatipo==1 

tabstat egcchoice_may if egcatipo==1
tabstat egcchoice_may if egcatipo==1,  by(period)

tabstat egcchoice_no if egcatipo==1
tabstat egcchoice_no if egcatipo==1, by(period)

tabstat egcchoice_yes if egcatipo==1
tabstat egcchoice_yes if egcatipo==1, by(period)



******* Table 7: Determinants of Disclosure Choices

label var egcchoice_no "Number of 'No' Choices"

joinby sic using HIGHTECH, unmatched(master)
tab _merge
drop _merge
replace hightech=0 if missing(hightech)

drop famafrench
gen famafrench=1
replace famafrench=2 if hightech==1
replace famafrench=3 if dum_biopharma==1

est clear

eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh, robust 
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.period, robust  
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.famafrench, robust  
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.famafrench i.period, robust 

esttab using disclosure.csv, pr2 ar2 notes eqlabels("") nonumber replace depvars star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 1 & Table 1: Sample of IPOs

use FINAL_SAMPLE, clear
drop mo qt
gen mo=month(idate)
gen qt=1 if mo==1|mo==2|mo==3
replace qt=2 if mo==4|mo==5|mo==6
replace qt=3 if mo==7|mo==8|mo==9
replace qt=4 if mo==10|mo==11|mo==12
gen ipo=1
gen control=(egcbyrev==0)
gen egcc=(egcbyrev==1)
gen nonq=(missing(egcbyrev))
gen nonsrc=(src==0)
collapse (sum) ipo control egcc nonq src nonsrc, by(yr qt)
browse



******* Figure 4: Residual IR 

use FINAL_SAMPLE, clear

keep if !missing(egcbyrev)

xi: reg ir dp lnproceeds_res unprofitable lnage avrg_uwmktsh diffdate nasdaq90d nreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
predict ir_res, res

drop mo qt
gen mo=month(idate)
gen qt=1 if mo==1|mo==2|mo==3
replace qt=2 if mo==4|mo==5|mo==6
replace qt=3 if mo==7|mo==8|mo==9
replace qt=4 if mo==10|mo==11|mo==12

collapse (count) nipos=ir (mean) ir_res, by(yr)
browse


clear
set more off


*************************************************************************************
* to run the code for all our analyses below, the following three datasets are needed
* FINAL_SAMPLE: our main dataset with IPO, EGC, all financial data
* IND_MTB_FF17: Industry M/B and P/E data at the famafrench 17 industry levels
* HIGHTECH: SIC codes for hightech industries 
*************************************************************************************


******* TABLE 2: Sumary Statistics

use FINAL_SAMPLE, clear

* three sets of IPO firms
* egcbyrev==1, Actual EGC IPOs "after" the Act
* egcbyrev==0, EGC-qualifying IPOs "before" the Act
* egcbyrev==. (missing), all other IPOs that do not qaulity EGC status

keep if !missing(egcbyrev)

*mean and median difference test results are by default [egcbyrev==0 - egcbyrec==1], so reverse the order on purpose
*to get results for [egcbyrev==1 - egcbyrec==0]
gen reverse_egcbyrev=!egcbyrev


est clear
estpost summ sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n acctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter if egcbyrev==1, detail  
esttab using full_summ_byEGC.csv, cell("mean(fmt(2)) p50(lab(median)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant replace

estpost summ sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n acctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter if egcbyrev==0, detail
esttab using full_summ_byEGC.csv, cell("mean(fmt(2)) p50(lab(median)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant append

*mean difference test
estpost ttest sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n wacctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter , by(reverse_egcbyrev) 
esttab using full_summ_byEGC.csv, cell("b(lab(mean diff) star fmt(2))") nonumber nonotes eqlabels("") noconstant label star(* 0.10 ** 0.05 *** 0.01) append

*median difference test
median sale, by(reverse_egcbyrev)
median sale_CPIadj1, by(reverse_egcbyrev)
median asset, by(reverse_egcbyrev)
median booklev, by(reverse_egcbyrev)
median ppenet_asset, by(reverse_egcbyrev)
median rnd_asset, by(reverse_egcbyrev)
median drnd, by(reverse_egcbyrev)
median salegr, by(reverse_egcbyrev)
median age, by(reverse_egcbyrev)
median unprofitable, by(reverse_egcbyrev)
median dum_VC, by(reverse_egcbyrev)
median proceeds, by(reverse_egcbyrev)
median proceeds_CPIadj1, by(reverse_egcbyrev)
median avrg_uwmktsh, by(reverse_egcbyrev)
median diffdate, by(reverse_egcbyrev)
median dp, by(reverse_egcbyrev)
median dp_p, by(reverse_egcbyrev)
median acctlegalpct, by(reverse_egcbyrev)
median wgspreadpct_new, by(reverse_egcbyrev)
median totfeepct, by(reverse_egcbyrev)
median ir, by(reverse_egcbyrev)
median totcost, by(reverse_egcbyrev)
median nasdaq90d, by(reverse_egcbyrev)
median nreg_filter, by(reverse_egcbyrev)


******* TABLE 3 & 4: Propensity Score Matching + OLS or Diff-in-diff

use FINAL_SAMPLE, clear

keep if !missing(egcbyrev)

drop if missing(acctlegalpct) & egcatipo!=1
drop if missing(wgspreadpct_new) & egcatipo!=1 
drop if missing(dp)  & egcatipo!=1

gen treated=(src==0)
gen post=(idate>=date("4/5/2012","MDY",2003))
gen treated_post=treated*post

*For matching, we use FF17 instead of FF50
drop famafrench
do famafrench17

joinby famafrench yr qt using IND_MTB_FF17, unmatched(master) update
tab _merge
drop _merge

label var indprc_earn17 "Ind P/E"

bys famafrench: egen negcipos=sum(egcipo)
tab famafrench egcipo


*psmtch for each ff industry
*aggregate several ff industries when those industries do not have enough control IPOs to match with

gen sample=.

foreach i of numlist 7 11 16 17 {
	di "famafrench `i'"
	psmatch2 egcipo lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if famafrench==`i', n(1) logit norepla
	replace sample=_weight if famafrench==`i'
}

gen pscore=_pscore

psmatch2 egcipo lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15, n(1) logit norepla
replace sample=_weight if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15
replace pscore=_pscore if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15


*restrict to the psmatch sample
keep if !missing(sample)
tab egcipo

gen reverse_egcipo=!egcipo


******* TABLE 3, Panel A

est clear
estpost summ lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if egcipo==1, detail  
esttab using psmmatchedsample.csv, cell("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(lab(median) fmt(3)) max(fmt(3)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant replace

estpost summ lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if egcipo==0, detail
esttab using psmmatchedsample.csv, cell("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(lab(median) fmt(3)) max(fmt(3)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant append

estpost ttest lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17, by(reverse_egcipo) 
esttab using psmmatchedsample.csv, cell("b(lab(mean diff) star fmt(3)) t(lab(t-stat) fmt(2))") nonumber nonotes eqlabels("") noconstant label star(* 0.10 ** 0.05 *** 0.01) append


******* TABLE 3, Panel B: OLS

est clear
eststo: xi: reg totfeepct egcbyrev lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==0, robust cluster(ff_yr_qt) 
eststo: xi: reg totfeepct egcbyrev lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==1, robust cluster(ff_yr_qt) 
eststo: xi: reg ir egcbyrev dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==0, robust cluster(ff_yr_qt) 
eststo: xi: reg ir egcbyrev dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==1 , robust cluster(ff_yr_qt) 

esttab using psm_ols.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* TABLE 4: Diff-in-Diff

est clear

eststo: xi: reg acctlegalpct treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg wgspreadpct_new treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg totfeepct treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg ir treated_post treated post dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench , robust cluster(ff_yr_qt) 
eststo: xi: reg totcost treated_post treated post dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
esttab using psm_dd.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* TABLE 5: Regression Discontinuity with SRC (After the Act)

use FINAL_SAMPLE, clear

*restrict the sample to actual EGCs after the Act
keep if egcbyrev==1

gen nosrc=(proceeds>75)
gen x = proceeds-75
gen nosrc_x=nosrc*x

label var nosrc "Non-SRC"
label var x "(Proceeds-75)"
label var nosrc_x "Non-SRC x (Proceeds-75)"
label var ir "Initial Return"
label var proceeds "Proceeds"


est clear
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=50 & proceeds<=100, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=30 & proceeds<=120, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=0 & proceeds<=150, robust cluster(ff_yr_qt) 
esttab using rd_ir.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 2: McCrary Test of Proceeds

preserve
keep if proceeds>=0 & proceeds<=300
DCdensity proceeds, breakpoint(75) generate(Xj Yj r0 fhat se_fhat) 
graph export McCrary.png, replace
restore


******* Figure 3: Regression Discontinuity around SRC Threshold

preserve
drop if ir>100
twoway (scatter ir proceeds, mcolor(gs10) msize(tiny)) ///
(lfit ir proceeds if proceeds<=75, lcolor(navy) lwidth(medthick)) ///
(lfit ir proceeds if proceeds>75, lcolor(maroon) lwidth(medthick)) ///
if proceeds>=50 & proceeds<=100, xline(75, lcolor(gs6) lpattern(dash)) legend(off) xtitle(Proceeds) ytitle(Initial Return (%)) yscale(range(-30,100)) ylabel(-20(20)100)
graph export rd.png, replace
restore


******* TABLE 5: Regression Discontinuity with SRC (Before the Act)
use FINAL_SAMPLE, clear

*restrict the sample to EGC-qualifying IPOs before the Act
keep if egcbyrev==0

gen nosrc=(proceeds>75)
gen x = proceeds-75
gen nosrc_x=nosrc*x

label var nosrc "Non-SRC"
label var x "(Proceeds-75)"
label var nosrc_x "Non-SRC x (Proceeds-75)"
label var ir "Initial Return"
label var proceeds "Proceeds"


est clear
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=50 & proceeds<=100, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=30 & proceeds<=120, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=0 & proceeds<=150, robust cluster(ff_yr_qt) 
esttab using rd_ir_preAct.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 2: McCrary Test of Proceeds

preserve
keep if proceeds>=0 & proceeds<=300
DCdensity proceeds, breakpoint(75) generate(Xj Yj r0 fhat se_fhat) 
graph export McCrary_preAct.png, replace
restore


******* Figure 3: Regression Discontinuity around SRC Threshold

preserve
drop if ir>100
twoway (scatter ir proceeds, mcolor(gs10) msize(tiny)) ///
(lfit ir proceeds if proceeds<=75, lcolor(navy) lwidth(medthick)) ///
(lfit ir proceeds if proceeds>75, lcolor(maroon) lwidth(medthick)) ///
if proceeds>=50 & proceeds<=100, xline(75, lcolor(gs6) lpattern(dash)) legend(off) xtitle(Proceeds) ytitle(Initial Return (%)) yscale(range(-30,100)) ylabel(-20(20)100)
graph export rd_preAct.png, replace
restore


******* Table 6: JOBS Act Provisions

use FINAL_SAMPLE, clear

keep if egcipo==1

gen ttw_yes=1 if  testwaters==1 & egcatipo==1
replace ttw_yes=0 if  testwaters==0 & egcatipo==1
replace ttw_yes=0 if  testwaters==-1 & egcatipo==1

gen ttw_no=1 if testwaters==0 & egcatipo==1
replace ttw_no=0 if testwaters==1 & egcatipo==1
replace ttw_no=0 if testwaters==-1 & egcatipo==1

gen ttw_yesmay=1 if testwaters==1  & egcatipo==1
replace ttw_yesmay=1 if testwaters==-1 & egcatipo==1
replace ttw_yesmay=0 if testwaters==0 & egcatipo==1

gen soxvoted_yes=0
replace soxvoted_yes=1 if sox_yes==1
replace soxvoted_yes=1 if voted_yes==1

gen soxvoted_no=0
replace soxvoted_no=1 if sox_no==1
replace soxvoted_no=1 if voted_no==1

gen soxvoted_yesmay=0
replace soxvoted_yesmay=1 if sox_yes==1
replace soxvoted_yesmay=1 if sox_may==1
replace soxvoted_yesmay=1 if voted_yes==1
replace soxvoted_yesmay=1 if voted_may==1

gen egcchoice_yes=confidential_yes+sox_yes+execcomp_yes+voted_yes+newrule_yes+financial_yes+ttw_yes
gen egcchoice_no=confidential_no+sox_no+execcomp_no+voted_no+newrule_no+financial_no+ttw_no
gen egcchoice_may=sox_may+execcomp_may+voted_may+newrule_may+financial_may
gen egcchoice_yesmay=confidential_yesmay+sox_yesmay+execcomp_yesmay+voted_yesmay+newrule_yesmay+financial_yesmay+ttw_yesmay


gen period=.
replace period=1 if idate>=date("4/5/2012","MDY",2012) & idate<date("4/4/2013","MDY",2012)
replace period=2 if idate>=date("4/5/2013","MDY",2012) & idate<date("4/4/2014","MDY",2012)
replace period=3 if idate>=date("4/5/2014","MDY",2012) & idate<date("4/30/2015","MDY",2012)


tab confidential if egcatipo==1 
bys period: tab confidential if egcatipo==1 

tab testwaters if egcatipo==1 
bys period: tab testwaters if egcatipo==1 

tab financial if egcatipo==1 
bys period: tab financial if egcatipo==1 

tab execcomp if egcatipo==1 
bys period: tab execcomp if egcatipo==1 

tab sox if egcatipo==1 
bys period: tab sox if egcatipo==1 

tab voted if egcatipo==1 
bys period: tab voted if egcatipo==1 

tab newrule if egcatipo==1 
bys period: tab newrule if egcatipo==1 

tabstat egcchoice_may if egcatipo==1
tabstat egcchoice_may if egcatipo==1,  by(period)

tabstat egcchoice_no if egcatipo==1
tabstat egcchoice_no if egcatipo==1, by(period)

tabstat egcchoice_yes if egcatipo==1
tabstat egcchoice_yes if egcatipo==1, by(period)



******* Table 7: Determinants of Disclosure Choices

label var egcchoice_no "Number of 'No' Choices"

joinby sic using HIGHTECH, unmatched(master)
tab _merge
drop _merge
replace hightech=0 if missing(hightech)

drop famafrench
gen famafrench=1
replace famafrench=2 if hightech==1
replace famafrench=3 if dum_biopharma==1

est clear

eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh, robust 
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.period, robust  
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.famafrench, robust  
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.famafrench i.period, robust 

esttab using disclosure.csv, pr2 ar2 notes eqlabels("") nonumber replace depvars star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 1 & Table 1: Sample of IPOs

use FINAL_SAMPLE, clear
drop mo qt
gen mo=month(idate)
gen qt=1 if mo==1|mo==2|mo==3
replace qt=2 if mo==4|mo==5|mo==6
replace qt=3 if mo==7|mo==8|mo==9
replace qt=4 if mo==10|mo==11|mo==12
gen ipo=1
gen control=(egcbyrev==0)
gen egcc=(egcbyrev==1)
gen nonq=(missing(egcbyrev))
gen nonsrc=(src==0)
collapse (sum) ipo control egcc nonq src nonsrc, by(yr qt)
browse



******* Figure 4: Residual IR 

use FINAL_SAMPLE, clear

keep if !missing(egcbyrev)

xi: reg ir dp lnproceeds_res unprofitable lnage avrg_uwmktsh diffdate nasdaq90d nreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
predict ir_res, res

drop mo qt
gen mo=month(idate)
gen qt=1 if mo==1|mo==2|mo==3
replace qt=2 if mo==4|mo==5|mo==6
replace qt=3 if mo==7|mo==8|mo==9
replace qt=4 if mo==10|mo==11|mo==12

collapse (count) nipos=ir (mean) ir_res, by(yr)
browse


clear
set more off


*************************************************************************************
* to run the code for all our analyses below, the following three datasets are needed
* FINAL_SAMPLE: our main dataset with IPO, EGC, all financial data
* IND_MTB_FF17: Industry M/B and P/E data at the famafrench 17 industry levels
* HIGHTECH: SIC codes for hightech industries 
*************************************************************************************


******* TABLE 2: Sumary Statistics

use FINAL_SAMPLE, clear

* three sets of IPO firms
* egcbyrev==1, Actual EGC IPOs "after" the Act
* egcbyrev==0, EGC-qualifying IPOs "before" the Act
* egcbyrev==. (missing), all other IPOs that do not qaulity EGC status

keep if !missing(egcbyrev)

*mean and median difference test results are by default [egcbyrev==0 - egcbyrec==1], so reverse the order on purpose
*to get results for [egcbyrev==1 - egcbyrec==0]
gen reverse_egcbyrev=!egcbyrev


est clear
estpost summ sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n acctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter if egcbyrev==1, detail  
esttab using full_summ_byEGC.csv, cell("mean(fmt(2)) p50(lab(median)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant replace

estpost summ sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n acctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter if egcbyrev==0, detail
esttab using full_summ_byEGC.csv, cell("mean(fmt(2)) p50(lab(median)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant append

*mean difference test
estpost ttest sale sale_CPIadj1 asset booklev ppenet_asset rnd_asset drnd salegr age unprofitable dum_VC ///
proceeds proceeds_CPIadj1 avrg_uwmktsh diffdate dp_p dp_n wacctlegalpct wgspreadpct_new totfeepct ir totcost ///
nasdaq90d nreg_filter , by(reverse_egcbyrev) 
esttab using full_summ_byEGC.csv, cell("b(lab(mean diff) star fmt(2))") nonumber nonotes eqlabels("") noconstant label star(* 0.10 ** 0.05 *** 0.01) append

*median difference test
median sale, by(reverse_egcbyrev)
median sale_CPIadj1, by(reverse_egcbyrev)
median asset, by(reverse_egcbyrev)
median booklev, by(reverse_egcbyrev)
median ppenet_asset, by(reverse_egcbyrev)
median rnd_asset, by(reverse_egcbyrev)
median drnd, by(reverse_egcbyrev)
median salegr, by(reverse_egcbyrev)
median age, by(reverse_egcbyrev)
median unprofitable, by(reverse_egcbyrev)
median dum_VC, by(reverse_egcbyrev)
median proceeds, by(reverse_egcbyrev)
median proceeds_CPIadj1, by(reverse_egcbyrev)
median avrg_uwmktsh, by(reverse_egcbyrev)
median diffdate, by(reverse_egcbyrev)
median dp, by(reverse_egcbyrev)
median dp_p, by(reverse_egcbyrev)
median acctlegalpct, by(reverse_egcbyrev)
median wgspreadpct_new, by(reverse_egcbyrev)
median totfeepct, by(reverse_egcbyrev)
median ir, by(reverse_egcbyrev)
median totcost, by(reverse_egcbyrev)
median nasdaq90d, by(reverse_egcbyrev)
median nreg_filter, by(reverse_egcbyrev)


******* TABLE 3 & 4: Propensity Score Matching + OLS or Diff-in-diff

use FINAL_SAMPLE, clear

keep if !missing(egcbyrev)

drop if missing(acctlegalpct) & egcatipo!=1
drop if missing(wgspreadpct_new) & egcatipo!=1 
drop if missing(dp)  & egcatipo!=1

gen treated=(src==0)
gen post=(idate>=date("4/5/2012","MDY",2003))
gen treated_post=treated*post

*For matching, we use FF17 instead of FF50
drop famafrench
do famafrench17

joinby famafrench yr qt using IND_MTB_FF17, unmatched(master) update
tab _merge
drop _merge

label var indprc_earn17 "Ind P/E"

bys famafrench: egen negcipos=sum(egcipo)
tab famafrench egcipo


*psmtch for each ff industry
*aggregate several ff industries when those industries do not have enough control IPOs to match with

gen sample=.

foreach i of numlist 7 11 16 17 {
	di "famafrench `i'"
	psmatch2 egcipo lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if famafrench==`i', n(1) logit norepla
	replace sample=_weight if famafrench==`i'
}

gen pscore=_pscore

psmatch2 egcipo lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15, n(1) logit norepla
replace sample=_weight if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15
replace pscore=_pscore if famafrench==1 | famafrench==2 | famafrench==3 | famafrench==5 |  famafrench==6 | famafrench==8 | famafrench==12 |  famafrench==13 |  famafrench==14 | famafrench==15


*restrict to the psmatch sample
keep if !missing(sample)
tab egcipo

gen reverse_egcipo=!egcipo


******* TABLE 3, Panel A

est clear
estpost summ lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if egcipo==1, detail  
esttab using psmmatchedsample.csv, cell("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(lab(median) fmt(3)) max(fmt(3)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant replace

estpost summ lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17 if egcipo==0, detail
esttab using psmmatchedsample.csv, cell("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(lab(median) fmt(3)) max(fmt(3)) count(fmt(0))") label nonumber nonotes eqlabels("") noconstant append

estpost ttest lnproceeds lnsale unprofitable salegr lnage booklev ppenet_asset rnd_asset avrg_brmktsh nasdaq90d indprc_earn17, by(reverse_egcipo) 
esttab using psmmatchedsample.csv, cell("b(lab(mean diff) star fmt(3)) t(lab(t-stat) fmt(2))") nonumber nonotes eqlabels("") noconstant label star(* 0.10 ** 0.05 *** 0.01) append


******* TABLE 3, Panel B: OLS

est clear
eststo: xi: reg totfeepct egcbyrev lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==0, robust cluster(ff_yr_qt) 
eststo: xi: reg totfeepct egcbyrev lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==1, robust cluster(ff_yr_qt) 
eststo: xi: reg ir egcbyrev dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==0, robust cluster(ff_yr_qt) 
eststo: xi: reg ir egcbyrev dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench if src==1 , robust cluster(ff_yr_qt) 

esttab using psm_ols.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* TABLE 4: Diff-in-Diff

est clear

eststo: xi: reg acctlegalpct treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg wgspreadpct_new treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg totfeepct treated_post treated post lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
eststo: xi: reg ir treated_post treated post dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench , robust cluster(ff_yr_qt) 
eststo: xi: reg totcost treated_post treated post dp_p dp_n lnproceeds_res unprofitable drnd lnage avrg_brmktsh lndiffdate nasdaq90d lnnreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
esttab using psm_dd.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* TABLE 5: Regression Discontinuity with SRC (After the Act)

use FINAL_SAMPLE, clear

*restrict the sample to actual EGCs after the Act
keep if egcbyrev==1

gen nosrc=(proceeds>75)
gen x = proceeds-75
gen nosrc_x=nosrc*x

label var nosrc "Non-SRC"
label var x "(Proceeds-75)"
label var nosrc_x "Non-SRC x (Proceeds-75)"
label var ir "Initial Return"
label var proceeds "Proceeds"


est clear
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=50 & proceeds<=100, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=30 & proceeds<=120, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=0 & proceeds<=150, robust cluster(ff_yr_qt) 
esttab using rd_ir.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 2: McCrary Test of Proceeds

preserve
keep if proceeds>=0 & proceeds<=300
DCdensity proceeds, breakpoint(75) generate(Xj Yj r0 fhat se_fhat) 
graph export McCrary.png, replace
restore


******* Figure 3: Regression Discontinuity around SRC Threshold

preserve
drop if ir>100
twoway (scatter ir proceeds, mcolor(gs10) msize(tiny)) ///
(lfit ir proceeds if proceeds<=75, lcolor(navy) lwidth(medthick)) ///
(lfit ir proceeds if proceeds>75, lcolor(maroon) lwidth(medthick)) ///
if proceeds>=50 & proceeds<=100, xline(75, lcolor(gs6) lpattern(dash)) legend(off) xtitle(Proceeds) ytitle(Initial Return (%)) yscale(range(-30,100)) ylabel(-20(20)100)
graph export rd.png, replace
restore


******* TABLE 5: Regression Discontinuity with SRC (Before the Act)
use FINAL_SAMPLE, clear

*restrict the sample to EGC-qualifying IPOs before the Act
keep if egcbyrev==0

gen nosrc=(proceeds>75)
gen x = proceeds-75
gen nosrc_x=nosrc*x

label var nosrc "Non-SRC"
label var x "(Proceeds-75)"
label var nosrc_x "Non-SRC x (Proceeds-75)"
label var ir "Initial Return"
label var proceeds "Proceeds"


est clear
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=50 & proceeds<=100, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=30 & proceeds<=120, robust cluster(ff_yr_qt) 
eststo: xi: reg ir nosrc x nosrc_x unprofitable drnd lnage lndiffdate nasdaq90d lnnreg_filter i.famafrench if proceeds>=0 & proceeds<=150, robust cluster(ff_yr_qt) 
esttab using rd_ir_preAct.csv, pr2 ar2 nonotes eqlabels("") nonumber noconstant replace depvars drop(_I*) star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 2: McCrary Test of Proceeds

preserve
keep if proceeds>=0 & proceeds<=300
DCdensity proceeds, breakpoint(75) generate(Xj Yj r0 fhat se_fhat) 
graph export McCrary_preAct.png, replace
restore


******* Figure 3: Regression Discontinuity around SRC Threshold

preserve
drop if ir>100
twoway (scatter ir proceeds, mcolor(gs10) msize(tiny)) ///
(lfit ir proceeds if proceeds<=75, lcolor(navy) lwidth(medthick)) ///
(lfit ir proceeds if proceeds>75, lcolor(maroon) lwidth(medthick)) ///
if proceeds>=50 & proceeds<=100, xline(75, lcolor(gs6) lpattern(dash)) legend(off) xtitle(Proceeds) ytitle(Initial Return (%)) yscale(range(-30,100)) ylabel(-20(20)100)
graph export rd_preAct.png, replace
restore


******* Table 6: JOBS Act Provisions

use FINAL_SAMPLE, clear

keep if egcipo==1

gen ttw_yes=1 if  testwaters==1 & egcatipo==1
replace ttw_yes=0 if  testwaters==0 & egcatipo==1
replace ttw_yes=0 if  testwaters==-1 & egcatipo==1

gen ttw_no=1 if testwaters==0 & egcatipo==1
replace ttw_no=0 if testwaters==1 & egcatipo==1
replace ttw_no=0 if testwaters==-1 & egcatipo==1

gen ttw_yesmay=1 if testwaters==1  & egcatipo==1
replace ttw_yesmay=1 if testwaters==-1 & egcatipo==1
replace ttw_yesmay=0 if testwaters==0 & egcatipo==1

gen soxvoted_yes=0
replace soxvoted_yes=1 if sox_yes==1
replace soxvoted_yes=1 if voted_yes==1

gen soxvoted_no=0
replace soxvoted_no=1 if sox_no==1
replace soxvoted_no=1 if voted_no==1

gen soxvoted_yesmay=0
replace soxvoted_yesmay=1 if sox_yes==1
replace soxvoted_yesmay=1 if sox_may==1
replace soxvoted_yesmay=1 if voted_yes==1
replace soxvoted_yesmay=1 if voted_may==1

gen egcchoice_yes=confidential_yes+sox_yes+execcomp_yes+voted_yes+newrule_yes+financial_yes+ttw_yes
gen egcchoice_no=confidential_no+sox_no+execcomp_no+voted_no+newrule_no+financial_no+ttw_no
gen egcchoice_may=sox_may+execcomp_may+voted_may+newrule_may+financial_may
gen egcchoice_yesmay=confidential_yesmay+sox_yesmay+execcomp_yesmay+voted_yesmay+newrule_yesmay+financial_yesmay+ttw_yesmay


gen period=.
replace period=1 if idate>=date("4/5/2012","MDY",2012) & idate<date("4/4/2013","MDY",2012)
replace period=2 if idate>=date("4/5/2013","MDY",2012) & idate<date("4/4/2014","MDY",2012)
replace period=3 if idate>=date("4/5/2014","MDY",2012) & idate<date("4/30/2015","MDY",2012)


tab confidential if egcatipo==1 
bys period: tab confidential if egcatipo==1 

tab testwaters if egcatipo==1 
bys period: tab testwaters if egcatipo==1 

tab financial if egcatipo==1 
bys period: tab financial if egcatipo==1 

tab execcomp if egcatipo==1 
bys period: tab execcomp if egcatipo==1 

tab sox if egcatipo==1 
bys period: tab sox if egcatipo==1 

tab voted if egcatipo==1 
bys period: tab voted if egcatipo==1 

tab newrule if egcatipo==1 
bys period: tab newrule if egcatipo==1 

tabstat egcchoice_may if egcatipo==1
tabstat egcchoice_may if egcatipo==1,  by(period)

tabstat egcchoice_no if egcatipo==1
tabstat egcchoice_no if egcatipo==1, by(period)

tabstat egcchoice_yes if egcatipo==1
tabstat egcchoice_yes if egcatipo==1, by(period)



******* Table 7: Determinants of Disclosure Choices

label var egcchoice_no "Number of 'No' Choices"

joinby sic using HIGHTECH, unmatched(master)
tab _merge
drop _merge
replace hightech=0 if missing(hightech)

drop famafrench
gen famafrench=1
replace famafrench=2 if hightech==1
replace famafrench=3 if dum_biopharma==1

est clear

eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh, robust 
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.period, robust  
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.famafrench, robust  
eststo: xi: reg egcchoice_no lnproceeds_res unprofitable lnage booklev ppenet_asset rnd_asset avrg_brmktsh i.famafrench i.period, robust 

esttab using disclosure.csv, pr2 ar2 notes eqlabels("") nonumber replace depvars star(* 0.10 ** 0.05 *** 0.01) label b(%9.3f)


******* Figure 1 & Table 1: Sample of IPOs

use FINAL_SAMPLE, clear
drop mo qt
gen mo=month(idate)
gen qt=1 if mo==1|mo==2|mo==3
replace qt=2 if mo==4|mo==5|mo==6
replace qt=3 if mo==7|mo==8|mo==9
replace qt=4 if mo==10|mo==11|mo==12
gen ipo=1
gen control=(egcbyrev==0)
gen egcc=(egcbyrev==1)
gen nonq=(missing(egcbyrev))
gen nonsrc=(src==0)
collapse (sum) ipo control egcc nonq src nonsrc, by(yr qt)
browse



******* Figure 4: Residual IR 

use FINAL_SAMPLE, clear

keep if !missing(egcbyrev)

xi: reg ir dp lnproceeds_res unprofitable lnage avrg_uwmktsh diffdate nasdaq90d nreg_filter crisis i.famafrench, robust cluster(ff_yr_qt) 
predict ir_res, res

drop mo qt
gen mo=month(idate)
gen qt=1 if mo==1|mo==2|mo==3
replace qt=2 if mo==4|mo==5|mo==6
replace qt=3 if mo==7|mo==8|mo==9
replace qt=4 if mo==10|mo==11|mo==12

collapse (count) nipos=ir (mean) ir_res, by(yr)
browse


