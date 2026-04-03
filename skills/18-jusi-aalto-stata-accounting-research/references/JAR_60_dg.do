********************************************************************************************************************************************
*  Managers' Body Expansiveness, Investor Perceptions, and Firm Forecast Errors and Valuation
*  By Antonio Dávila (HEC Lausanne) and Martí Guasch (ESADE Business School)

*  Data are confidential and provided by a European Business Angel and Venture Capital Network as described in the attached datasheet. Contact information has been provided to the JAR editorial office.

********************************************************************************************************************************************


use Davila_Guasch_raw.dta, replace

**************** GENERATING MAIN VARIABLES
* Forecast revenue errors
g frev_cont = (bud_rev - rev)/tot_assets
xtile frev_err = frev_cont, nq(5)

* Forecast income errors
g finc_cont = (bud_opinc - opinc)/tot_assets
xtile finc_err = finc_cont, nq(5)

* Firm valuation above (peers) round mean 
* Gen valuation mean by round_number
preserve
keep if fcstyear==1 /* keep only cross section (i.e. N=154) sample */
bysort round_number: egen meanval_round=mean(firmval_rev_ksol)
tempfile t1
save `t1'
restore
merge m:1 firmid using `t1', keepusing(meanval_round)
drop _merge
* Gen dummy if above round mean
gen upmean_round=.
replace upmean_round=0 if firmval_rev_ksol<meanval_round
replace upmean_round=1 if firmval_rev_ksol>=meanval_round
replace upmean_round=. if firmval_rev_ksol==.

* active and invest come straight from raw data

**************** GENERATING DEPENDENT VARIABLES - DONE

* save
save Davila_Guasch.dta, replace






********************* Table 1 - Final sample

* Panel A. Sample selection 
* See description in paper. Current dataset uses final sample of projects

* Panel B. Industry distribution
tab cnae if fcstyear==1




********************* Table 2 - Physical expansiveness - Principal Component Analysis
* Section 3.2 and Figure 1 in the paper provide the process (and raw code) to convert video images into tractable variables. We average each physical joint distances (between frames t and t-1) to obtain an expansiveness measure per physical joint: feet (lfmov_avg1 rfmov_avg1), hands (lhmov_avg1 rhmov_avg1) and head (nosemov_avg1)


* Panel A. Correlations (we use the fcstyear==1 condition to work with the N=154 sample)
pwcorr lfmov_avg1 rfmov_avg1 lhmov_avg1 rhmov_avg1 nosemov_avg1 if fcstyear==1

* Panel B. Principal Component Analysis (in R) to reduce the above five variables to the overall Expansiveness measure
/* R code
require(psych)
x=principal(data, nfactors=1, rotate="varimax") ## "data" contains vars lfmov_avg1-nosemov_avg1 for each of the 154 projects/
f=factor.scores(data, x, method="Anderson") ## extract factor scores
ff=f$scores ##keep factor scores
Expan=ff[,1] ## name the factor scores vector
data2 <- cbind(data_with_firmid,Expan) ## link PCA results to firm ids dataset
library("rio") ## export data
export(data2,"anderson_scoresExpan_all.dta")
*/

* merge results from PCA in R with master dataset
merge m:1 firmid using "~\userpath\anderson_scoresExpan_all.dta", keepusing(Expan)
drop _merge

* rerun above code with physical joints variables for the 137 one-speaker projects: obtain Expan_1speak variable




********************* Table 3 - Descriptives

* Panel A. Time invariant (and first-year observations)
local rest "fcstyear==1" /*fcstyear==1 indicates first year (i.e., N=154 sample)*/
tabstat Expan Expan_1speak frev_err finc_err upmean_round active invest presence profession attract ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg avg_bud_revg breakeven if `rest', stat(n mean sd min max p25 p50 p75) col(stats)

* Panel B - Time variant (second year and more)
tabstat frev_err finc_err empl if fcstyear>1, stat(n mean sd min max p25 p50 p75) col(stats)

* Panel C - Financing rounds (N=154 sample -> fcstyear==1 condition)
tab round_number if fcstyear==1




********************* Table 4. Correlation matrix (N=154 sample -> fcstyear==1 condition)
pwcorr Expan frev_err finc_err upmean_round active invest presence profession attract f0mean fwhr2 sent_neg avg_bud_revg breakeven if fcstyear==1





********************* Table 5 
* Panel A. Full sample (all projects)
local iv1 "Expan"
local controls "ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly logit upmean_round `iv1' `controls' `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit active `iv1' `controls' `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit invest `iv1' `controls' `entrep' avg_bud_revg breakeven i.year i.cnae if fcstyear==1,  vce(cluster cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear

* Panel B (sample restricted to one-speaker projects)
local rest "num_speak_check==1"
local iv1 "Expan"
local controls "ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if `rest',  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if `rest',  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly logit upmean_round `iv1' `controls' `entrep' i.year i.cnae if `rest' & fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit active `iv1' `controls' `entrep' i.year i.cnae if `rest' & fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit invest `iv1' `controls' `entrep' avg_bud_revg breakeven i.year i.cnae if `rest' & fcstyear==1,  vce(cluster cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear





********************* Table 6 - MTurkers descriptives
* Turk Prime stats are taken from a separate .dta file with the 1,772 Turk Prime responses
use qualtrics_resp.dta, clear
tab gender
tab experience
tab age
tab educ
tab race




********************* Table 7. Perceptions

* To obtain presence, attract, and profession: reproduce R code in Table 2 and perform the PCA with the five personal characteristics (trustowrthiness, competence, attractiveness, dominance, and passion). Online Appendix 3 provides details.

* back to main dataset
use Davila_Guasch.dta, clear

* Panel A. Full sample
local iv1 "presence attract profession"
local controls "ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly logit upmean_round `iv1' `controls' `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit active `iv1' `controls' `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit invest `iv1' `controls' `entrep' avg_bud_revg breakeven i.year i.cnae if fcstyear==1,  vce(cluster cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear





********************* Table 8 - Physical expansiveness and growth

* NOTE: This table uses out of sample observations. We expand our sample to obtain the highest number of (revenue) growth observations from our sampled firms (irrespective of whether we can match observations to our firm-year forecasts). Observations increase to N=527 and are stored in another dataset:

use growth_tests_jun21.dta, clear

* Panel A. Descriptive statistics
tabstat revg_milions_jun21 revg_perc_jun21_w revg_acc2_jun21, stat(n mean sd min max p25 p50 p75) col(stats) format(%9.3fc) va(20)


* Panel B. Growth regressions
local iv1 "Expan"
local controls "ageforo empl_jun21 inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 revg_milions_jun21 `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 revg_perc_jun21_w `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 revg_acc2_jun21 `iv1' `controls' `entrep' i.year i.cnae,  tcluster(firmid) fcluster(cnae)
*conditional on survival ==1
eststo: xi: quietly cluster2 revg_milions_jun21 `iv1' `controls' `entrep' i.year i.cnae if active==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 revg_perc_jun21_w `iv1' `controls' `entrep' i.year i.cnae if active==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 revg_acc2_jun21 `iv1' `controls' `entrep' i.year i.cnae if active==1,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear





********************* Table 9. Expansiveness (40-80% portion of the pitch)

* come back to main dataset
use Davila_Guasch.dta, clear

* Reproduce R code for Expansiveness measure in Table 2 but only taking averages of the physical joint distances (between frames t and t-1) from the 40-80% portion of the pitch (we have the duration of the pitch in seconds).

* Merge with main dataset
merge m:1 firmid using "~\userpath\anderson_scoresExpan_4080.dta", keepusing(Expan_4080)
drop _merge

* Run regression
local iv1 "Expan_4080"
local controls "ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae, tcluster(cnae) fcluster(firmid)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae, tcluster(cnae) fcluster(firmid)
eststo: xi: quietly logit upmean_round `iv1' `controls' `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit active `iv1' `controls' `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
eststo: xi: quietly logit invest `iv1' `controls' `entrep' avg_bud_revg breakeven i.year i.cnae if  fcstyear==1,  vce(cluster cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear






********************* Table 10. Cross section (Age + VC presence)

* 10a. Firm age median split (ageforo variable ommitted)
* gen agemedian
tabstat ageforo, stat(p50) /* median = 27 months */
g agemedian=.
replace agemedian=1 if ageforo>=27
replace agemedian=0 if ageforo<27

* Table specifications
local iv1 "Expan"
local controls "empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==0,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==0,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap b(%8.3f) nocons order(`iv1')
eststo clear


* 10b. VC presence split (VC variable ommitted)
local iv1 "Expan"
local controls "ageforo empl inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==0,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==0,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap b(%8.3f) nocons order(`iv1')
eststo clear





**********                         ********************************************************************
**********     PAPER TABLES END    ********************************************************************







**********                         ********************************************************************
**********     ONLINE APPENDIX     ********************************************************************


********************* Online Appendix 1: Ok Forum packages examples

********************* Online Appendix 2: Ok survey instrument

********************* Online Appendix 3: PCA perceptions variables

* Panel A. Correlations
/* R code
r = round(cor(data), 2) ## data = five personal characteristics per project/
*/

* Panel B. (Unrestricted) PCA on five personal characteristics
/* R code
require(psych)
x=principal(data, rotate="varimax") ## not restricting number of components
print(x$loadings, digits = 3, cutoff = .5) ## obtain components' loadings
*/

* Panel C. (Two-component) PCA on five personal characteristics + Figure
/* R code
require(psych)
x2=principal(data, nfactors=2, rotate="varimax") ## restricting to 2 components
print(x2$loadings, digits = 3, cutoff = .5)

# Loadings plot
plot(x2$loadings, main='Principal component analysis: 2 component space', pch=18, 
     xlab='Component 1', ylab='Component 2')
text(0.55, 0.6, "Trustworthiness", cex=1) ## positioning label text
text(0.59, 0.51, "Competence", cex=1)
text(0.86, 0.30, "Passionate", cex=1)
text(0.86, 0.20, "Dominance", cex=1)
text(0.23, 0.85, "Attractiveness", cex=1)
*/

* Panel D. (Three-component) PCA on five personal characteristics
/* R code
require(psych)
x1=principal(data, nfactors=3, rotate="varimax") ## restricting to 3 components
print(x1$loadings, digits = 3, cutoff = .6) ## Panel D depicts these component loadings
*/

* We store the three components and name them presence, attract, and profession








********************* Online Appendix 4. Robustness tests 

*** Table OA4.1. Descriptives alternative variables
tabstat frev_err2 finc_err2 upmean_ind if fcstyear==1, stat(n mean sd min max p25 p50 p75) col(stats)
tabstat frev_err2 finc_err2 if fcstyear>1, stat(n mean sd min max p25 p50 p75) col(stats)

*** Table OA4.2 - Panel A
local iv1 "Expan"
local controls "ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err2 `iv1' `controls' `entrep' i.year i.cnae, tcluster(cnae) fcluster(firmid)
eststo: xi: quietly cluster2 finc_err2 `iv1' `controls' `entrep' i.year i.cnae, tcluster(cnae) fcluster(firmid)
* inv_vc dropped to allow for N=136 sample (lacks variation with DV)
eststo: xi: quietly logit upmean_ind `iv1' ageforo empl inv_ba inv_acc inv_debt lnksolicit round_number `entrep' i.year i.cnae if fcstyear==1,  vce(cluster cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear


*** Table OA4.2  - Panel B (single-speaker projects analysis)
local rest "num_speak_check==1"
local iv1 "Expan"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
local controls "ageforo empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
eststo: xi: quietly cluster2 frev_err2 `iv1' `controls' `entrep' i.year i.cnae if `rest', tcluster(cnae) fcluster(firmid)
eststo: xi: quietly cluster2 finc_err2 `iv1' `controls' `entrep' i.year i.cnae if `rest', tcluster(cnae) fcluster(firmid)
eststo: xi: quietly logit upmean_ind `iv1' ageforo empl inv_ba inv_acc inv_debt lnksolicit round_number `entrep' i.year i.cnae if `rest' & fcstyear==1,  vce(cluster cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap  b(%8.3f) nocons order(`iv1')
eststo clear


*** Table OA4.2  - Panel C (Age and VC heterogeneity)

* AGE - median split (ageforo omitted)
local iv1 "Expan"
local controls "empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err2 `iv1' `controls' `entrep' i.year i.cnae if agemedian==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err2 `iv1' `controls' `entrep' i.year i.cnae if agemedian==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 frev_err2 `iv1' `controls' `entrep' i.year i.cnae if agemedian==0,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err2 `iv1' `controls' `entrep' i.year i.cnae if agemedian==0,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap b(%8.3f) nocons order(`iv1')
eststo clear

* VC - sample split (inv_vc omitted)
local iv1 "Expan"
local controls "ageforo empl inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err2 `iv1' `controls' `entrep' i.year i.cnae if inv_vc==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err2 `iv1' `controls' `entrep' i.year i.cnae if inv_vc==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 frev_err2 `iv1' `controls' `entrep' i.year i.cnae if inv_vc==0,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err2 `iv1' `controls' `entrep' i.year i.cnae if inv_vc==0,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap b(%8.3f) nocons order(`iv1')
eststo clear





********************* Online Appendix 5. Age and VC heterogeneity (3 components)
* 1. AGE
local iv1 "presence profession attract"
local controls "empl inv_vc inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==0,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if agemedian==0,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap b(%8.3f) nocons order(`iv1')
eststo clear

* 2. VC
local iv1 "presence profession attract"
local controls "ageforo empl inv_ba inv_acc inv_debt lnksolicit round_number"
local entrep "gender_ratio ent_exp_inind_ratio ent_startup_exp_ratio f0mean fwhr2 sent_neg"
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==1,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 frev_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==0,  tcluster(firmid) fcluster(cnae)
eststo: xi: quietly cluster2 finc_err `iv1' `controls' `entrep' i.year i.cnae if inv_vc==0,  tcluster(firmid) fcluster(cnae)
esttab, drop(_cons _Iyear* _Icnae*) star(* 0.10 ** 0.05 *** 0.01) nogap b(%8.3f) nocons order(`iv1')
eststo clear

**********                         ********************************************************************
**********     ONLINE APPENDIX TABLES END    ********************************************************************