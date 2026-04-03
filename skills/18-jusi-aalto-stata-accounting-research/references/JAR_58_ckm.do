use "D:\CKM.dta", clear

/* Merge with EMMA */
encode dbkey, gen(id)
merge 1:1 dbkey audityear using "d:/new_issues_emma.dta"
gen new_issue=0
replace new_issue=1 if _merge==3
drop if _merge==2
drop _merge

/* Create lag variables */
sort dbkey1 audityear
tsset dbkey1 audityear
foreach i in 610 59 48 37 12 1121{ 
gen sum_tenure`i'_nolag = sum_tenure`i'
gen lag_sum_tenure`i'=l.sum_tenure`i'
drop sum_tenure`i'
rename lag_sum_tenure`i' sum_tenure`i'
}
foreach i in 610 59 48 37 { 
gen lag_d_death`i'=l.d_death`i'
drop d_death`i'
rename lag_d_death`i' d_death`i'
gen lag_app`i'=l.app`i'
drop app`i'
rename lag_app`i' app`i'
}
drop if missing(sum_tenure610)

/* Create First Principal Component Measures of Reporting Quality and Compliance */
gen no_mw=0 if !missing(mw)
replace no_mw=1 if (!missing(mw) & mw==0)
gen no_mao=0 if !missing(mao)
replace no_mao=1 if (!missing(mao) & mao==0)
gen no_rp=0 if !missing(rp)
replace no_rp=1 if (!missing(rp) & rp==0)
gen no_mnc=0 if !missing(mnc)
replace no_mnc=1 if (!missing(mnc) & mnc==0)
gen lag=(timing1*-1)/365
gen no_mw_rp=3
replace no_mw_rp=2 if (rp==1 & mw==0)
replace no_mw_rp=1 if (mw==1 & rp==0)
replace no_mw_rp=0 if (mw==1 & rp==1)

gen no_mw_mp=0 if !missing(mw_mp)
replace no_mw_mp=1 if (!missing(mw_mp) & mw_mp==0)
gen no_mao_mp=0 if !missing(mao_mp)
replace no_mao_mp=1 if (!missing(mao_mp) & mao_mp==0)
gen no_rp_mp=0 if !missing(rp_mp)
replace no_rp_mp=1 if (!missing(rp_mp) & rp_mp==0)
gen no_mw_rp_mp=0
replace no_mw_rp_mp=-1 if no_rp_mp==0
replace no_mw_rp_mp=-2 if no_mw_mp==0
replace no_mw_rp_mp=-3 if (no_mw_mp==0 & no_rp_mp==0)

/* Scale Main Independent Variables by 100 */
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 sum_tenure12 sum_tenure1121 sum_tenure610_nolag sum_tenure59_nolag sum_tenure48_nolag sum_tenure37_nolag{ 
replace `i'=`i'/100
}

/* PCA */
pca no_mw no_mao no_rp no_mnc lag, components(1)
predict pc1_finrep, score

pca no_mw_mp no_mao_mp no_rp_mp, components(1)
predict pc1_mp, score

sort dbkey1 audityear
tsset dbkey1 audityear

foreach i in pc1_finrep{
by dbkey1: gen lag_pc1_finrep  = pc1_finrep[_n-1] if audityear == audityear[_n-1] +1
by dbkey1: gen lag2_pc1_finrep = pc1_finrep[_n-2] if audityear == audityear[_n-2] +2
by dbkey1: gen lag3_pc1_finrep = pc1_finrep[_n-3] if audityear == audityear[_n-3] +3
by dbkey1: gen lag4_pc1_finrep = pc1_finrep[_n-4] if audityear == audityear[_n-4] +4
}
gen sum_pc1_finrep = lag_pc1_finrep + lag2_pc1_finrep + lag3_pc1_finrep + lag4_pc1_finrep
xtile pc1_finrep_rank = sum_pc1_finrep, nq(4)
gen low_finrep=1 if pc1_finrep_rank ==1
replace low_finrep=0 if missing(low_finrep)
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_low_finrep=sum_tenure`i'_nolag*low_finrep
}
gen lead_fin=f.pc1_finrep
gen simplesum = no_mao + no_mw + no_rp + no_mnc + lag

/* Make lrisk Increase in Opacity */
gen hrisk=0
replace hrisk=1 if lrisk==0
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_lrisk=sum_tenure`i'*lrisk
}

/* Size */
xtile size=population, nq(4)
gen small=0 
replace small=1 if size==1
replace small=1 if missing(size)
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_small=sum_tenure`i'*small
}

/* Bing */
replace valid_articles = 0 if missing(valid_articles)
gen n_bing = -valid_articles

sort dbkey
by dbkey: egen avg_bing2 = mean(n_bing)
sort audityear
by audityear: egen avg_bing3 = mean(n_bing)
gen n_bing1 = (n_bing - avg_bing2 - avg_bing3)

/* Bond-Market Participants as Monitor */
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_new_issue=sum_tenure`i'*new_issue
}

/* Independent Auditor as Monitors */
gen indep_audit=0
replace indep_audit=1 if state_audit==0
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_indep_audit=sum_tenure`i'*indep_audit
}

/* Media as Monitors */
gen news = (newspaper / population_st) * 1000
xtile xtile_news=news, nq(4)
gen high_news = 0
replace high_news = 1 if xtile_news >=4
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_news=sum_tenure`i'*high_news
}

/* Stewardship for Reputation Building */
xtile lag_fin_rank= lag_pc1_finrep, nq(4) 
xtile lead_fin_rank= lead_fin, nq(4) 
gen reputation = 0
replace reputation = 1 if lag_fin_rank <=2 & lead_fin_rank >=3
foreach i in 610 59 48 37 {
gen d_death`i'_reputation = d_death`i' * reputation
}

/* Favor - Partisan */
gen favor = 0
replace favor = 1 if n_democrat1 >=2 & d_democrat ==1
replace favor = 1 if n_democrat1 ==0 & d_republican ==1
foreach i in 610 59 48 37{
gen sum_tenure`i'_favor = sum_tenure`i'*favor
}

/* Favor - Hometown */
gen dist = min(dist1, dist2)
gen d_dist = 0
replace d_dist = 1 if dist <= 25
foreach i in 610 59 48 37{
gen sum_tenure`i'_dist = sum_tenure`i'*d_dist
}

/* Appropriation */
foreach i in 610 59 48 37{
egen app`i'_rank = xtile(app`i'), by(audityear) nq(4)
gen d_app`i' = 1 if app`i'_rank >= 4
replace d_app`i' = 0 if missing(d_app`i')
gen sum_tenure`i'_app = sum_tenure`i'*d_app`i'
}

/* Court */
gen court= (sum_totcase/1000)  /* time-invariant */
gen courti= (totcase/1000)  /* time-varying */

xtile xtile_court=court, nq(4)
gen low_court=0 if !missing(xtile_court)
replace low_court=1 if xtile_court==1 & !missing(xtile_court)

xtile xtile_courti=courti, nq(4)
gen low_courti=0 if !missing(xtile_courti)
replace low_courti=1 if xtile_courti==1 & !missing(xtile_courti)

foreach i in 610 59 48 37{ 
gen sum_tenure`i'_court=sum_tenure`i'*low_court
gen sum_tenure`i'_courti=sum_tenure`i'*low_courti
}

/* DOJ */
gen doj= sum_doj1  /* time-invariant */
gen doji= doj1  /* time-variant */

xtile xtile_doj=doj, nq(4)
gen low_doj=0 if !missing(xtile_doj)
replace low_doj=1 if xtile_doj==1 & !missing(xtile_doj)

xtile xtile_doji=doji, nq(4)
gen low_doji=0 if !missing(xtile_doji)
replace low_doji=1 if xtile_doji==1 & !missing(xtile_doji)

foreach i in 610 59 48 37{ 
gen sum_tenure`i'_doj=sum_tenure`i'*low_doj
gen sum_tenure`i'_doji=sum_tenure`i'*low_doji
}

/* Margin */
foreach i in 610 59 48 37{
gen sum_tenure`i'_margin1 = sum_tenure`i' * margin1
}

/* Alternative Congressional Representation */
foreach i in 6 5 4 3 {
gen senate_dtenure`i' = sum_dtenure`i'*democrat_r
replace senate_dtenure`i' = 0 if missing(senate_dtenure`i')
gen senate_rtenure`i' = sum_rtenure`i'*republican_r
replace senate_rtenure`i' = 0 if missing(senate_rtenure`i')
gen senate_tenure`i' = senate_dtenure`i' + senate_rtenure`i'
}
foreach i in 10 9 8 7 {
gen house_dtenure`i' = sum_dtenure`i'*democrat_district
replace house_dtenure`i' = 0 if missing(house_dtenure`i')
gen house_rtenure`i' = sum_rtenure`i'*republican_district
replace house_rtenure`i' = 0 if missing(house_rtenure`i')
gen house_tenure`i' = house_dtenure`i' + house_rtenure`i'
}
gen alt_tenure610 = (senate_tenure6 + house_tenure10)/100
gen alt_tenure59 = (senate_tenure5 + house_tenure9)/100
gen alt_tenure48 = (senate_tenure4 + house_tenure8)/100
gen alt_tenure37 = (senate_tenure3 + house_tenure7)/100

*************Main Paper*************

*Table 1 - Descriptive Statistics
tabstat pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 d_death610 d_death59 d_death48 d_death37 new_issue lexp lm_subsidy, statistics(n mean sd p25 p50 p75) columns(statistics)
tabstat court doj small margin1, statistics(n mean sd p25 p50 p75) columns(statistics)

estpost correlate pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix

*Table 2 - Local Stewardship, by State
sort statename
by statename: tabstat pc1_finrep, statistics(n mean) columns(statistics)

*Table 3 - Main Result
global control "new_issue lexp lm_subsidy d_subsidy"
foreach j in pc1_finrep{
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 4 - Death
foreach j in pc1_finrep{
foreach i in d_death610 d_death59 d_death48 d_death37 { 
	qui areg `j' `i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 5 - Misappropriation or Ineptitude
foreach j in pc1_finrep {
foreach i in 59 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_court $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_court ==0
	qui areg `j' sum_tenure`i' sum_tenure`i'_doj $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_doj ==0
}
}
foreach j in pc1_finrep {
foreach i in 610 59 48 37  { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_small small $control i.audityear, absorb(id) vce(cluster stcd)  
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_small =0
}
}
*Table 6 - Political Competition
foreach j in pc1_finrep{
foreach i in 610 59 48 37{
	qui areg `j' sum_tenure`i' sum_tenure`i'_margin1 margin1 $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_margin1 = 0
}
}

*************Online Appendix*************

*Table 1 - Components
foreach j in no_mao no_mw no_rp no_mnc lag {
foreach i in 59 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 2 - Simple Sum
estpost correlate simplesum pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix
foreach j in simplesum{
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 3 - Compliance 
foreach j in pc1_mp {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 4 - News Search-based
estpost correlate n_bing1 pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix
foreach j in n_bing {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 5 - Alternative congressional representation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' p75_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 6 - Falsification non-top 10 committees
gen sum_exten = sum_tenure1121 - sum_tenure37
foreach j in pc1_finrep {
foreach i in sum_exten { 
	qui areg `j' `i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 10 - Instrumented
foreach i in 610 59 48 37 {
	qui reghdfe pc1_finrep  $control i.audityear (sum_tenure`i'=d_death`i'), keepsin absorb(id) cluster(stcd)
	est tab, drop(d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
*Table 11 - Corruption (time-varying)
foreach j in pc1_finrep {
foreach i in 59 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_courti low_courti $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_courti ==0
	qui areg `j' sum_tenure`i' sum_tenure`i'_doji low_doji $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_doji ==0
}
}
*Table 12 - DOJ enforcements
foreach j in doji {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_low_finrep low_finrep $control i.audityear, absorb(id) vce(cluster stcd)    
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 13 - Measuring congressional representation based on party affiliation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' alt_tenure`i' $control i.audityear if missing(ranney)==0, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

*Table 14 - Favoritism
foreach j in lexp {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_favor favor new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_favor =0
}
}
foreach j in lexp {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_dist d_dist new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_dist==0
}
}
*Table 15 - Stewardship for reputation building
foreach j in lexp {
foreach i in d_death610 d_death59 d_death48 d_death37 { 
	qui areg `j' `i' `i'_reputation reputation new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_reputation = 0
}
}
*Table 16 - Bondholder as a monitor
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_new_issue $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_new_issue=0
}
}
*Table 17 - Independent auditor as a monitor
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_indep_audit indep_audit $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_indep_audit=0
}
}
*Table 18 -  Media as a monitor
foreach j in pc1_finrep {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_news $control i.audityear, absorb(id) vce(cluster stcd)    
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_news = 0
}
}
*Table 19 - Auditor effort
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_lrisk lrisk $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_lrisk=0
}
}
*Table 20 - Appropriation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_app d_app`i' $control i.audityear, absorb(id) vce(cluster stcd)  
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 21 - Exclude 12 largest states
gen large12 = 0
replace large12 = 1 if inlist(statename,"CA","FA","GA","IL","MI","NC")
replace large12 = 1 if inlist(statename,"NJ","NY","OH","PA","TX","VA")
foreach j in pc1_finrep {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' $control i.audityear if large12 ==0, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 22 - State-by-year fixed effects
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	reg2hdfe `j' sum_tenure`i' $control , id1(id) id2(styr) cluster (stcd)
}
}
*Table 23 - Including interactions
foreach j in pc1_finrep{
foreach i in 610 59 48 37{
	qui areg `j' sum_tenure`i' sum_tenure`i'_margin1 sum_tenure`i'_court sum_tenure`i'_doj sum_tenure`i'_small margin1 $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_margin1 = 0
}
}
use "D:\CKM_local.dta", clear

*Scale independent variables by 100
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
replace `i'=`i'/100
}
*Table 7 - Local Elections and Stewardship
tabstat lead_rvotes pc1_finrep_lag sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 lexp lm_subsidy margin1 lincome_cty ue_cty edu, statistics(n mean sd p25 p50 p75) columns(statistics)
global control "lexp lm_subsidy margin1 lincome_cty ue_cty edu d_subsidy "
foreach j in  lead_rvotes {
foreach i in 610 { 
	qui reg `j' pc1_finrep_lag $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
foreach j in  lead_rvotes {
foreach i in 610 59 48 37 { 
	qui reg `j' pc1_finrep_lag sum_tenure`i' $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

use "D:\CKM_congress.dta", clear

/* Scale independent variables by 100 */
foreach i in sum_tenure10 sum_tenure5 sum_tenure3 sum_tenure1 { 
replace `i'=`i'/100
}

*Table 8 - Congressional Elections and Stewardship
tabstat lead_rvotes pc1_finrep_lag sum_tenure1 sum_tenure3 sum_tenure5 sum_tenure10 lexp lm_subsidy margin1 lincome_cty ue_cty edu, statistics(n mean sd p25 p50 p75) columns(statistics)
global control "lexp lm_subsidy margin1 lincome_cty ue_cty edu d_subsidy "
foreach j in lead_rvotes {
foreach i in 1 { 
	qui reg `j' pc1_finrep_lag $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
foreach j in lead_rvotes {
foreach i in 1 3 5 10{ 
	qui reg `j' pc1_finrep_lag sum_tenure`i' $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

use "D:\CKM.dta", clear

/* Merge with EMMA */
encode dbkey, gen(id)
merge 1:1 dbkey audityear using "d:/new_issues_emma.dta"
gen new_issue=0
replace new_issue=1 if _merge==3
drop if _merge==2
drop _merge

/* Create lag variables */
sort dbkey1 audityear
tsset dbkey1 audityear
foreach i in 610 59 48 37 12 1121{ 
gen sum_tenure`i'_nolag = sum_tenure`i'
gen lag_sum_tenure`i'=l.sum_tenure`i'
drop sum_tenure`i'
rename lag_sum_tenure`i' sum_tenure`i'
}
foreach i in 610 59 48 37 { 
gen lag_d_death`i'=l.d_death`i'
drop d_death`i'
rename lag_d_death`i' d_death`i'
gen lag_app`i'=l.app`i'
drop app`i'
rename lag_app`i' app`i'
}
drop if missing(sum_tenure610)

/* Create First Principal Component Measures of Reporting Quality and Compliance */
gen no_mw=0 if !missing(mw)
replace no_mw=1 if (!missing(mw) & mw==0)
gen no_mao=0 if !missing(mao)
replace no_mao=1 if (!missing(mao) & mao==0)
gen no_rp=0 if !missing(rp)
replace no_rp=1 if (!missing(rp) & rp==0)
gen no_mnc=0 if !missing(mnc)
replace no_mnc=1 if (!missing(mnc) & mnc==0)
gen lag=(timing1*-1)/365
gen no_mw_rp=3
replace no_mw_rp=2 if (rp==1 & mw==0)
replace no_mw_rp=1 if (mw==1 & rp==0)
replace no_mw_rp=0 if (mw==1 & rp==1)

gen no_mw_mp=0 if !missing(mw_mp)
replace no_mw_mp=1 if (!missing(mw_mp) & mw_mp==0)
gen no_mao_mp=0 if !missing(mao_mp)
replace no_mao_mp=1 if (!missing(mao_mp) & mao_mp==0)
gen no_rp_mp=0 if !missing(rp_mp)
replace no_rp_mp=1 if (!missing(rp_mp) & rp_mp==0)
gen no_mw_rp_mp=0
replace no_mw_rp_mp=-1 if no_rp_mp==0
replace no_mw_rp_mp=-2 if no_mw_mp==0
replace no_mw_rp_mp=-3 if (no_mw_mp==0 & no_rp_mp==0)

/* Scale Main Independent Variables by 100 */
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 sum_tenure12 sum_tenure1121 sum_tenure610_nolag sum_tenure59_nolag sum_tenure48_nolag sum_tenure37_nolag{ 
replace `i'=`i'/100
}

/* PCA */
pca no_mw no_mao no_rp no_mnc lag, components(1)
predict pc1_finrep, score

pca no_mw_mp no_mao_mp no_rp_mp, components(1)
predict pc1_mp, score

sort dbkey1 audityear
tsset dbkey1 audityear

foreach i in pc1_finrep{
by dbkey1: gen lag_pc1_finrep  = pc1_finrep[_n-1] if audityear == audityear[_n-1] +1
by dbkey1: gen lag2_pc1_finrep = pc1_finrep[_n-2] if audityear == audityear[_n-2] +2
by dbkey1: gen lag3_pc1_finrep = pc1_finrep[_n-3] if audityear == audityear[_n-3] +3
by dbkey1: gen lag4_pc1_finrep = pc1_finrep[_n-4] if audityear == audityear[_n-4] +4
}
gen sum_pc1_finrep = lag_pc1_finrep + lag2_pc1_finrep + lag3_pc1_finrep + lag4_pc1_finrep
xtile pc1_finrep_rank = sum_pc1_finrep, nq(4)
gen low_finrep=1 if pc1_finrep_rank ==1
replace low_finrep=0 if missing(low_finrep)
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_low_finrep=sum_tenure`i'_nolag*low_finrep
}
gen lead_fin=f.pc1_finrep
gen simplesum = no_mao + no_mw + no_rp + no_mnc + lag

/* Make lrisk Increase in Opacity */
gen hrisk=0
replace hrisk=1 if lrisk==0
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_lrisk=sum_tenure`i'*lrisk
}

/* Size */
xtile size=population, nq(4)
gen small=0 
replace small=1 if size==1
replace small=1 if missing(size)
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_small=sum_tenure`i'*small
}

/* Bing */
replace valid_articles = 0 if missing(valid_articles)
gen n_bing = -valid_articles

sort dbkey
by dbkey: egen avg_bing2 = mean(n_bing)
sort audityear
by audityear: egen avg_bing3 = mean(n_bing)
gen n_bing1 = (n_bing - avg_bing2 - avg_bing3)

/* Bond-Market Participants as Monitor */
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_new_issue=sum_tenure`i'*new_issue
}

/* Independent Auditor as Monitors */
gen indep_audit=0
replace indep_audit=1 if state_audit==0
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_indep_audit=sum_tenure`i'*indep_audit
}

/* Media as Monitors */
gen news = (newspaper / population_st) * 1000
xtile xtile_news=news, nq(4)
gen high_news = 0
replace high_news = 1 if xtile_news >=4
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_news=sum_tenure`i'*high_news
}

/* Stewardship for Reputation Building */
xtile lag_fin_rank= lag_pc1_finrep, nq(4) 
xtile lead_fin_rank= lead_fin, nq(4) 
gen reputation = 0
replace reputation = 1 if lag_fin_rank <=2 & lead_fin_rank >=3
foreach i in 610 59 48 37 {
gen d_death`i'_reputation = d_death`i' * reputation
}

/* Favor - Partisan */
gen favor = 0
replace favor = 1 if n_democrat1 >=2 & d_democrat ==1
replace favor = 1 if n_democrat1 ==0 & d_republican ==1
foreach i in 610 59 48 37{
gen sum_tenure`i'_favor = sum_tenure`i'*favor
}

/* Favor - Hometown */
gen dist = min(dist1, dist2)
gen d_dist = 0
replace d_dist = 1 if dist <= 25
foreach i in 610 59 48 37{
gen sum_tenure`i'_dist = sum_tenure`i'*d_dist
}

/* Appropriation */
foreach i in 610 59 48 37{
egen app`i'_rank = xtile(app`i'), by(audityear) nq(4)
gen d_app`i' = 1 if app`i'_rank >= 4
replace d_app`i' = 0 if missing(d_app`i')
gen sum_tenure`i'_app = sum_tenure`i'*d_app`i'
}

/* Court */
gen court= (sum_totcase/1000)  /* time-invariant */
gen courti= (totcase/1000)  /* time-varying */

xtile xtile_court=court, nq(4)
gen low_court=0 if !missing(xtile_court)
replace low_court=1 if xtile_court==1 & !missing(xtile_court)

xtile xtile_courti=courti, nq(4)
gen low_courti=0 if !missing(xtile_courti)
replace low_courti=1 if xtile_courti==1 & !missing(xtile_courti)

foreach i in 610 59 48 37{ 
gen sum_tenure`i'_court=sum_tenure`i'*low_court
gen sum_tenure`i'_courti=sum_tenure`i'*low_courti
}

/* DOJ */
gen doj= sum_doj1  /* time-invariant */
gen doji= doj1  /* time-variant */

xtile xtile_doj=doj, nq(4)
gen low_doj=0 if !missing(xtile_doj)
replace low_doj=1 if xtile_doj==1 & !missing(xtile_doj)

xtile xtile_doji=doji, nq(4)
gen low_doji=0 if !missing(xtile_doji)
replace low_doji=1 if xtile_doji==1 & !missing(xtile_doji)

foreach i in 610 59 48 37{ 
gen sum_tenure`i'_doj=sum_tenure`i'*low_doj
gen sum_tenure`i'_doji=sum_tenure`i'*low_doji
}

/* Margin */
foreach i in 610 59 48 37{
gen sum_tenure`i'_margin1 = sum_tenure`i' * margin1
}

/* Alternative Congressional Representation */
foreach i in 6 5 4 3 {
gen senate_dtenure`i' = sum_dtenure`i'*democrat_r
replace senate_dtenure`i' = 0 if missing(senate_dtenure`i')
gen senate_rtenure`i' = sum_rtenure`i'*republican_r
replace senate_rtenure`i' = 0 if missing(senate_rtenure`i')
gen senate_tenure`i' = senate_dtenure`i' + senate_rtenure`i'
}
foreach i in 10 9 8 7 {
gen house_dtenure`i' = sum_dtenure`i'*democrat_district
replace house_dtenure`i' = 0 if missing(house_dtenure`i')
gen house_rtenure`i' = sum_rtenure`i'*republican_district
replace house_rtenure`i' = 0 if missing(house_rtenure`i')
gen house_tenure`i' = house_dtenure`i' + house_rtenure`i'
}
gen alt_tenure610 = (senate_tenure6 + house_tenure10)/100
gen alt_tenure59 = (senate_tenure5 + house_tenure9)/100
gen alt_tenure48 = (senate_tenure4 + house_tenure8)/100
gen alt_tenure37 = (senate_tenure3 + house_tenure7)/100

*************Main Paper*************

*Table 1 - Descriptive Statistics
tabstat pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 d_death610 d_death59 d_death48 d_death37 new_issue lexp lm_subsidy, statistics(n mean sd p25 p50 p75) columns(statistics)
tabstat court doj small margin1, statistics(n mean sd p25 p50 p75) columns(statistics)

estpost correlate pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix

*Table 2 - Local Stewardship, by State
sort statename
by statename: tabstat pc1_finrep, statistics(n mean) columns(statistics)

*Table 3 - Main Result
global control "new_issue lexp lm_subsidy d_subsidy"
foreach j in pc1_finrep{
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 4 - Death
foreach j in pc1_finrep{
foreach i in d_death610 d_death59 d_death48 d_death37 { 
	qui areg `j' `i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 5 - Misappropriation or Ineptitude
foreach j in pc1_finrep {
foreach i in 59 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_court $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_court ==0
	qui areg `j' sum_tenure`i' sum_tenure`i'_doj $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_doj ==0
}
}
foreach j in pc1_finrep {
foreach i in 610 59 48 37  { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_small small $control i.audityear, absorb(id) vce(cluster stcd)  
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_small =0
}
}
*Table 6 - Political Competition
foreach j in pc1_finrep{
foreach i in 610 59 48 37{
	qui areg `j' sum_tenure`i' sum_tenure`i'_margin1 margin1 $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_margin1 = 0
}
}

*************Online Appendix*************

*Table 1 - Components
foreach j in no_mao no_mw no_rp no_mnc lag {
foreach i in 59 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 2 - Simple Sum
estpost correlate simplesum pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix
foreach j in simplesum{
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 3 - Compliance 
foreach j in pc1_mp {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 4 - News Search-based
estpost correlate n_bing1 pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix
foreach j in n_bing {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 5 - Alternative congressional representation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' p75_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 6 - Falsification non-top 10 committees
gen sum_exten = sum_tenure1121 - sum_tenure37
foreach j in pc1_finrep {
foreach i in sum_exten { 
	qui areg `j' `i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 10 - Instrumented
foreach i in 610 59 48 37 {
	qui reghdfe pc1_finrep  $control i.audityear (sum_tenure`i'=d_death`i'), keepsin absorb(id) cluster(stcd)
	est tab, drop(d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
*Table 11 - Corruption (time-varying)
foreach j in pc1_finrep {
foreach i in 59 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_courti low_courti $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_courti ==0
	qui areg `j' sum_tenure`i' sum_tenure`i'_doji low_doji $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_doji ==0
}
}
*Table 12 - DOJ enforcements
foreach j in doji {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_low_finrep low_finrep $control i.audityear, absorb(id) vce(cluster stcd)    
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 13 - Measuring congressional representation based on party affiliation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' alt_tenure`i' $control i.audityear if missing(ranney)==0, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

*Table 14 - Favoritism
foreach j in lexp {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_favor favor new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_favor =0
}
}
foreach j in lexp {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_dist d_dist new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_dist==0
}
}
*Table 15 - Stewardship for reputation building
foreach j in lexp {
foreach i in d_death610 d_death59 d_death48 d_death37 { 
	qui areg `j' `i' `i'_reputation reputation new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_reputation = 0
}
}
*Table 16 - Bondholder as a monitor
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_new_issue $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_new_issue=0
}
}
*Table 17 - Independent auditor as a monitor
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_indep_audit indep_audit $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_indep_audit=0
}
}
*Table 18 -  Media as a monitor
foreach j in pc1_finrep {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_news $control i.audityear, absorb(id) vce(cluster stcd)    
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_news = 0
}
}
*Table 19 - Auditor effort
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_lrisk lrisk $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_lrisk=0
}
}
*Table 20 - Appropriation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_app d_app`i' $control i.audityear, absorb(id) vce(cluster stcd)  
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 21 - Exclude 12 largest states
gen large12 = 0
replace large12 = 1 if inlist(statename,"CA","FA","GA","IL","MI","NC")
replace large12 = 1 if inlist(statename,"NJ","NY","OH","PA","TX","VA")
foreach j in pc1_finrep {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' $control i.audityear if large12 ==0, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 22 - State-by-year fixed effects
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	reg2hdfe `j' sum_tenure`i' $control , id1(id) id2(styr) cluster (stcd)
}
}
*Table 23 - Including interactions
foreach j in pc1_finrep{
foreach i in 610 59 48 37{
	qui areg `j' sum_tenure`i' sum_tenure`i'_margin1 sum_tenure`i'_court sum_tenure`i'_doj sum_tenure`i'_small margin1 $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_margin1 = 0
}
}
use "D:\CKM_local.dta", clear

*Scale independent variables by 100
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
replace `i'=`i'/100
}
*Table 7 - Local Elections and Stewardship
tabstat lead_rvotes pc1_finrep_lag sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 lexp lm_subsidy margin1 lincome_cty ue_cty edu, statistics(n mean sd p25 p50 p75) columns(statistics)
global control "lexp lm_subsidy margin1 lincome_cty ue_cty edu d_subsidy "
foreach j in  lead_rvotes {
foreach i in 610 { 
	qui reg `j' pc1_finrep_lag $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
foreach j in  lead_rvotes {
foreach i in 610 59 48 37 { 
	qui reg `j' pc1_finrep_lag sum_tenure`i' $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

use "D:\CKM_congress.dta", clear

/* Scale independent variables by 100 */
foreach i in sum_tenure10 sum_tenure5 sum_tenure3 sum_tenure1 { 
replace `i'=`i'/100
}

*Table 8 - Congressional Elections and Stewardship
tabstat lead_rvotes pc1_finrep_lag sum_tenure1 sum_tenure3 sum_tenure5 sum_tenure10 lexp lm_subsidy margin1 lincome_cty ue_cty edu, statistics(n mean sd p25 p50 p75) columns(statistics)
global control "lexp lm_subsidy margin1 lincome_cty ue_cty edu d_subsidy "
foreach j in lead_rvotes {
foreach i in 1 { 
	qui reg `j' pc1_finrep_lag $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
foreach j in lead_rvotes {
foreach i in 1 3 5 10{ 
	qui reg `j' pc1_finrep_lag sum_tenure`i' $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

use "D:\CKM.dta", clear

/* Merge with EMMA */
encode dbkey, gen(id)
merge 1:1 dbkey audityear using "d:/new_issues_emma.dta"
gen new_issue=0
replace new_issue=1 if _merge==3
drop if _merge==2
drop _merge

/* Create lag variables */
sort dbkey1 audityear
tsset dbkey1 audityear
foreach i in 610 59 48 37 12 1121{ 
gen sum_tenure`i'_nolag = sum_tenure`i'
gen lag_sum_tenure`i'=l.sum_tenure`i'
drop sum_tenure`i'
rename lag_sum_tenure`i' sum_tenure`i'
}
foreach i in 610 59 48 37 { 
gen lag_d_death`i'=l.d_death`i'
drop d_death`i'
rename lag_d_death`i' d_death`i'
gen lag_app`i'=l.app`i'
drop app`i'
rename lag_app`i' app`i'
}
drop if missing(sum_tenure610)

/* Create First Principal Component Measures of Reporting Quality and Compliance */
gen no_mw=0 if !missing(mw)
replace no_mw=1 if (!missing(mw) & mw==0)
gen no_mao=0 if !missing(mao)
replace no_mao=1 if (!missing(mao) & mao==0)
gen no_rp=0 if !missing(rp)
replace no_rp=1 if (!missing(rp) & rp==0)
gen no_mnc=0 if !missing(mnc)
replace no_mnc=1 if (!missing(mnc) & mnc==0)
gen lag=(timing1*-1)/365
gen no_mw_rp=3
replace no_mw_rp=2 if (rp==1 & mw==0)
replace no_mw_rp=1 if (mw==1 & rp==0)
replace no_mw_rp=0 if (mw==1 & rp==1)

gen no_mw_mp=0 if !missing(mw_mp)
replace no_mw_mp=1 if (!missing(mw_mp) & mw_mp==0)
gen no_mao_mp=0 if !missing(mao_mp)
replace no_mao_mp=1 if (!missing(mao_mp) & mao_mp==0)
gen no_rp_mp=0 if !missing(rp_mp)
replace no_rp_mp=1 if (!missing(rp_mp) & rp_mp==0)
gen no_mw_rp_mp=0
replace no_mw_rp_mp=-1 if no_rp_mp==0
replace no_mw_rp_mp=-2 if no_mw_mp==0
replace no_mw_rp_mp=-3 if (no_mw_mp==0 & no_rp_mp==0)

/* Scale Main Independent Variables by 100 */
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 sum_tenure12 sum_tenure1121 sum_tenure610_nolag sum_tenure59_nolag sum_tenure48_nolag sum_tenure37_nolag{ 
replace `i'=`i'/100
}

/* PCA */
pca no_mw no_mao no_rp no_mnc lag, components(1)
predict pc1_finrep, score

pca no_mw_mp no_mao_mp no_rp_mp, components(1)
predict pc1_mp, score

sort dbkey1 audityear
tsset dbkey1 audityear

foreach i in pc1_finrep{
by dbkey1: gen lag_pc1_finrep  = pc1_finrep[_n-1] if audityear == audityear[_n-1] +1
by dbkey1: gen lag2_pc1_finrep = pc1_finrep[_n-2] if audityear == audityear[_n-2] +2
by dbkey1: gen lag3_pc1_finrep = pc1_finrep[_n-3] if audityear == audityear[_n-3] +3
by dbkey1: gen lag4_pc1_finrep = pc1_finrep[_n-4] if audityear == audityear[_n-4] +4
}
gen sum_pc1_finrep = lag_pc1_finrep + lag2_pc1_finrep + lag3_pc1_finrep + lag4_pc1_finrep
xtile pc1_finrep_rank = sum_pc1_finrep, nq(4)
gen low_finrep=1 if pc1_finrep_rank ==1
replace low_finrep=0 if missing(low_finrep)
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_low_finrep=sum_tenure`i'_nolag*low_finrep
}
gen lead_fin=f.pc1_finrep
gen simplesum = no_mao + no_mw + no_rp + no_mnc + lag

/* Make lrisk Increase in Opacity */
gen hrisk=0
replace hrisk=1 if lrisk==0
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_lrisk=sum_tenure`i'*lrisk
}

/* Size */
xtile size=population, nq(4)
gen small=0 
replace small=1 if size==1
replace small=1 if missing(size)
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_small=sum_tenure`i'*small
}

/* Bing */
replace valid_articles = 0 if missing(valid_articles)
gen n_bing = -valid_articles

sort dbkey
by dbkey: egen avg_bing2 = mean(n_bing)
sort audityear
by audityear: egen avg_bing3 = mean(n_bing)
gen n_bing1 = (n_bing - avg_bing2 - avg_bing3)

/* Bond-Market Participants as Monitor */
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_new_issue=sum_tenure`i'*new_issue
}

/* Independent Auditor as Monitors */
gen indep_audit=0
replace indep_audit=1 if state_audit==0
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_indep_audit=sum_tenure`i'*indep_audit
}

/* Media as Monitors */
gen news = (newspaper / population_st) * 1000
xtile xtile_news=news, nq(4)
gen high_news = 0
replace high_news = 1 if xtile_news >=4
foreach i in 610 59 48 37{ 
gen sum_tenure`i'_news=sum_tenure`i'*high_news
}

/* Stewardship for Reputation Building */
xtile lag_fin_rank= lag_pc1_finrep, nq(4) 
xtile lead_fin_rank= lead_fin, nq(4) 
gen reputation = 0
replace reputation = 1 if lag_fin_rank <=2 & lead_fin_rank >=3
foreach i in 610 59 48 37 {
gen d_death`i'_reputation = d_death`i' * reputation
}

/* Favor - Partisan */
gen favor = 0
replace favor = 1 if n_democrat1 >=2 & d_democrat ==1
replace favor = 1 if n_democrat1 ==0 & d_republican ==1
foreach i in 610 59 48 37{
gen sum_tenure`i'_favor = sum_tenure`i'*favor
}

/* Favor - Hometown */
gen dist = min(dist1, dist2)
gen d_dist = 0
replace d_dist = 1 if dist <= 25
foreach i in 610 59 48 37{
gen sum_tenure`i'_dist = sum_tenure`i'*d_dist
}

/* Appropriation */
foreach i in 610 59 48 37{
egen app`i'_rank = xtile(app`i'), by(audityear) nq(4)
gen d_app`i' = 1 if app`i'_rank >= 4
replace d_app`i' = 0 if missing(d_app`i')
gen sum_tenure`i'_app = sum_tenure`i'*d_app`i'
}

/* Court */
gen court= (sum_totcase/1000)  /* time-invariant */
gen courti= (totcase/1000)  /* time-varying */

xtile xtile_court=court, nq(4)
gen low_court=0 if !missing(xtile_court)
replace low_court=1 if xtile_court==1 & !missing(xtile_court)

xtile xtile_courti=courti, nq(4)
gen low_courti=0 if !missing(xtile_courti)
replace low_courti=1 if xtile_courti==1 & !missing(xtile_courti)

foreach i in 610 59 48 37{ 
gen sum_tenure`i'_court=sum_tenure`i'*low_court
gen sum_tenure`i'_courti=sum_tenure`i'*low_courti
}

/* DOJ */
gen doj= sum_doj1  /* time-invariant */
gen doji= doj1  /* time-variant */

xtile xtile_doj=doj, nq(4)
gen low_doj=0 if !missing(xtile_doj)
replace low_doj=1 if xtile_doj==1 & !missing(xtile_doj)

xtile xtile_doji=doji, nq(4)
gen low_doji=0 if !missing(xtile_doji)
replace low_doji=1 if xtile_doji==1 & !missing(xtile_doji)

foreach i in 610 59 48 37{ 
gen sum_tenure`i'_doj=sum_tenure`i'*low_doj
gen sum_tenure`i'_doji=sum_tenure`i'*low_doji
}

/* Margin */
foreach i in 610 59 48 37{
gen sum_tenure`i'_margin1 = sum_tenure`i' * margin1
}

/* Alternative Congressional Representation */
foreach i in 6 5 4 3 {
gen senate_dtenure`i' = sum_dtenure`i'*democrat_r
replace senate_dtenure`i' = 0 if missing(senate_dtenure`i')
gen senate_rtenure`i' = sum_rtenure`i'*republican_r
replace senate_rtenure`i' = 0 if missing(senate_rtenure`i')
gen senate_tenure`i' = senate_dtenure`i' + senate_rtenure`i'
}
foreach i in 10 9 8 7 {
gen house_dtenure`i' = sum_dtenure`i'*democrat_district
replace house_dtenure`i' = 0 if missing(house_dtenure`i')
gen house_rtenure`i' = sum_rtenure`i'*republican_district
replace house_rtenure`i' = 0 if missing(house_rtenure`i')
gen house_tenure`i' = house_dtenure`i' + house_rtenure`i'
}
gen alt_tenure610 = (senate_tenure6 + house_tenure10)/100
gen alt_tenure59 = (senate_tenure5 + house_tenure9)/100
gen alt_tenure48 = (senate_tenure4 + house_tenure8)/100
gen alt_tenure37 = (senate_tenure3 + house_tenure7)/100

*************Main Paper*************

*Table 1 - Descriptive Statistics
tabstat pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 d_death610 d_death59 d_death48 d_death37 new_issue lexp lm_subsidy, statistics(n mean sd p25 p50 p75) columns(statistics)
tabstat court doj small margin1, statistics(n mean sd p25 p50 p75) columns(statistics)

estpost correlate pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix

*Table 2 - Local Stewardship, by State
sort statename
by statename: tabstat pc1_finrep, statistics(n mean) columns(statistics)

*Table 3 - Main Result
global control "new_issue lexp lm_subsidy d_subsidy"
foreach j in pc1_finrep{
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 4 - Death
foreach j in pc1_finrep{
foreach i in d_death610 d_death59 d_death48 d_death37 { 
	qui areg `j' `i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 5 - Misappropriation or Ineptitude
foreach j in pc1_finrep {
foreach i in 59 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_court $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_court ==0
	qui areg `j' sum_tenure`i' sum_tenure`i'_doj $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_doj ==0
}
}
foreach j in pc1_finrep {
foreach i in 610 59 48 37  { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_small small $control i.audityear, absorb(id) vce(cluster stcd)  
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_small =0
}
}
*Table 6 - Political Competition
foreach j in pc1_finrep{
foreach i in 610 59 48 37{
	qui areg `j' sum_tenure`i' sum_tenure`i'_margin1 margin1 $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_margin1 = 0
}
}

*************Online Appendix*************

*Table 1 - Components
foreach j in no_mao no_mw no_rp no_mnc lag {
foreach i in 59 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 2 - Simple Sum
estpost correlate simplesum pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix
foreach j in simplesum{
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 3 - Compliance 
foreach j in pc1_mp {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 4 - News Search-based
estpost correlate n_bing1 pc1_finrep no_mao no_mw no_rp no_mnc lag sum_tenure37 sum_tenure48 sum_tenure59 sum_tenure610, matrix
foreach j in n_bing {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 5 - Alternative congressional representation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' p75_tenure`i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 6 - Falsification non-top 10 committees
gen sum_exten = sum_tenure1121 - sum_tenure37
foreach j in pc1_finrep {
foreach i in sum_exten { 
	qui areg `j' `i' $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 10 - Instrumented
foreach i in 610 59 48 37 {
	qui reghdfe pc1_finrep  $control i.audityear (sum_tenure`i'=d_death`i'), keepsin absorb(id) cluster(stcd)
	est tab, drop(d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
*Table 11 - Corruption (time-varying)
foreach j in pc1_finrep {
foreach i in 59 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_courti low_courti $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_courti ==0
	qui areg `j' sum_tenure`i' sum_tenure`i'_doji low_doji $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_doji ==0
}
}
*Table 12 - DOJ enforcements
foreach j in doji {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_low_finrep low_finrep $control i.audityear, absorb(id) vce(cluster stcd)    
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 13 - Measuring congressional representation based on party affiliation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' alt_tenure`i' $control i.audityear if missing(ranney)==0, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

*Table 14 - Favoritism
foreach j in lexp {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_favor favor new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_favor =0
}
}
foreach j in lexp {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_dist d_dist new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_dist==0
}
}
*Table 15 - Stewardship for reputation building
foreach j in lexp {
foreach i in d_death610 d_death59 d_death48 d_death37 { 
	qui areg `j' `i' `i'_reputation reputation new_issue i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_reputation = 0
}
}
*Table 16 - Bondholder as a monitor
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_new_issue $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_new_issue=0
}
}
*Table 17 - Independent auditor as a monitor
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_indep_audit indep_audit $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_indep_audit=0
}
}
*Table 18 -  Media as a monitor
foreach j in pc1_finrep {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' sum_tenure`i'_news $control i.audityear, absorb(id) vce(cluster stcd)    
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_news = 0
}
}
*Table 19 - Auditor effort
foreach j in pc1_finrep {
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
	qui areg `j' `i' `i'_lrisk lrisk $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test `i'+`i'_lrisk=0
}
}
*Table 20 - Appropriation
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	qui areg `j' sum_tenure`i' sum_tenure`i'_app d_app`i' $control i.audityear, absorb(id) vce(cluster stcd)  
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 21 - Exclude 12 largest states
gen large12 = 0
replace large12 = 1 if inlist(statename,"CA","FA","GA","IL","MI","NC")
replace large12 = 1 if inlist(statename,"NJ","NY","OH","PA","TX","VA")
foreach j in pc1_finrep {
foreach i in 610 59 48 37 {
	qui areg `j' sum_tenure`i' $control i.audityear if large12 ==0, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
*Table 22 - State-by-year fixed effects
foreach j in pc1_finrep {
foreach i in 610 59 48 37 { 
	reg2hdfe `j' sum_tenure`i' $control , id1(id) id2(styr) cluster (stcd)
}
}
*Table 23 - Including interactions
foreach j in pc1_finrep{
foreach i in 610 59 48 37{
	qui areg `j' sum_tenure`i' sum_tenure`i'_margin1 sum_tenure`i'_court sum_tenure`i'_doj sum_tenure`i'_small margin1 $control i.audityear, absorb(id) vce(cluster stcd)
	est tab, drop(_cons d_subsidy i.audityear)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
		test sum_tenure`i' + sum_tenure`i'_margin1 = 0
}
}
use "D:\CKM_local.dta", clear

*Scale independent variables by 100
foreach i in sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 { 
replace `i'=`i'/100
}
*Table 7 - Local Elections and Stewardship
tabstat lead_rvotes pc1_finrep_lag sum_tenure610 sum_tenure59 sum_tenure48 sum_tenure37 lexp lm_subsidy margin1 lincome_cty ue_cty edu, statistics(n mean sd p25 p50 p75) columns(statistics)
global control "lexp lm_subsidy margin1 lincome_cty ue_cty edu d_subsidy "
foreach j in  lead_rvotes {
foreach i in 610 { 
	qui reg `j' pc1_finrep_lag $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
foreach j in  lead_rvotes {
foreach i in 610 59 48 37 { 
	qui reg `j' pc1_finrep_lag sum_tenure`i' $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}

use "D:\CKM_congress.dta", clear

/* Scale independent variables by 100 */
foreach i in sum_tenure10 sum_tenure5 sum_tenure3 sum_tenure1 { 
replace `i'=`i'/100
}

*Table 8 - Congressional Elections and Stewardship
tabstat lead_rvotes pc1_finrep_lag sum_tenure1 sum_tenure3 sum_tenure5 sum_tenure10 lexp lm_subsidy margin1 lincome_cty ue_cty edu, statistics(n mean sd p25 p50 p75) columns(statistics)
global control "lexp lm_subsidy margin1 lincome_cty ue_cty edu d_subsidy "
foreach j in lead_rvotes {
foreach i in 1 { 
	qui reg `j' pc1_finrep_lag $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}
foreach j in lead_rvotes {
foreach i in 1 3 5 10{ 
	qui reg `j' pc1_finrep_lag sum_tenure`i' $control i.year1, vce(robust)
	est tab, drop(_cons d_subsidy i.year1)  b(%8.3f) se(%8.3f) stats(N r2) varwidth(20)
}
}


