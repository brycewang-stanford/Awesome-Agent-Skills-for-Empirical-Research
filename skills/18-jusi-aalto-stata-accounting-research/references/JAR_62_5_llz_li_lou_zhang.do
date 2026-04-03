

cd "D:\CRA ESG\Results"
global control size leverage tangibility tobinq roa cash salesgrowth rdmiss rd dividend analyst institution
global fix_cl absorb(event_firm event_country_year event_ind_year) cluster(esg_identifier)
global fix_cl_subsample absorb(esg_identifier country_year ind_year) cluster(esg_identifier)
global export tstat bdec(3) tdec(2) rdec(3) adjr2



// T1 Sample Selection See Log File
// T2 Country Distribution
use "D:\CRA ESG\Data_Main.dta", clear
bysort event country: gen obs=_N
bysort event country: egen esg_mean=mean(esg)
bysort event country: egen treat_mean=mean(treat)
keep event country obs esg_mean treat_mean
duplicates drop
gen sub="Moody" if event==1
replace sub="S&P" if event==0
drop event
sort sub country
format esg_mean treat_mean %10.3f
list



// T3 Summary Statistics
use "D:\CRA ESG\Data_Main.dta", clear
gen control=1-treat // this is to make treat shown on the left side for by(control)
tabstat ben_esg $control, s(n mean sd p1 p25 p50 p75 p99) c(s) f(%10.3f)
tabstat $control, by(control) s(n mean median sd) c(s) f(%10.3f)
ttable3 $control, by(control)



// T4 Main Results
use "D:\CRA ESG\Data_Main.dta", clear
egen ind_year=group(industry year)
egen country_year=group(country year)
reghdfe ben_esg treat_post $control, $fix_cl
	outreg2 using T4.doc, ctitle(Full Sample) $export replace
reghdfe ben_esg treat_post $control if event==1, $fix_cl_subsample
	outreg2 using T4.doc, ctitle(Moody's Subsample) $export append
reghdfe ben_esg treat_post $control if event==0, $fix_cl_subsample
	outreg2 using T4.doc, ctitle(S&P Subsample) $export append



// T5 Dynamic Analysis
use "D:\CRA ESG\Data_Main.dta", clear
gen year17=0
replace year17=1 if year==2017
gen treat_year17=treat*year17
gen year18=0
replace year18=1 if year==2018
gen treat_year18=treat*year18
gen year19=0
replace year19=1 if year==2019
gen treat_year19=treat*year19
gen year20=0
replace year20=1 if year==2020
gen treat_year20=treat*year20
gen year21=0
replace year21=1 if year==2021
gen treat_year21=treat*year21
egen ind_year=group(industry year)
egen country_year=group(country year)
reghdfe ben_esg treat_year17 treat_year18 treat_year19 treat_year20 treat_year21 $control, $fix_cl
	outreg2 using T5.doc, ctitle(Full Sample) $export replace
reghdfe ben_esg treat_year17 treat_year18 treat_year19 treat_year20 treat_year21 $control if event==1, $fix_cl_subsample
	outreg2 using T5.doc, ctitle(Moody's Subsample) $export append
reghdfe ben_esg treat_year17 treat_year18 treat_year19 treat_year20 treat_year21 $control if event==0, $fix_cl_subsample
	outreg2 using T5.doc, ctitle(S&P Subsample) $export append



// T6 Cross Sectional Analysis
use "D:\CRA ESG\Data_T6.dta", clear
reghdfe ben_esg treat_highratingnumb_post treat_lowratingnumb_post $control, $fix_cl
	test treat_highratingnumb_post=treat_lowratingnumb_post
	outreg2 using T6.doc, ctitle(Credit Rating Number) $export replace
reghdfe ben_esg treat_post_highesgd post_highesgd treat_post $control, $fix_cl
	outreg2 using T6.doc, ctitle(ESG Disclosure) $export append
reghdfe ben_esg treat_post_longterm post_longterm treat_post $control, $fix_cl
	outreg2 using T6.doc, ctitle(Long Term Holding) $export append



// T7 ESG Ratings and Green Bond Issuance
use "D:\CRA ESG\Data_T7.dta", clear
global d_control d_size d_leverage d_tangibility d_tobinq d_roa d_cash d_salesgrowth d_rdmiss d_rd d_dividend d_analyst d_institution
reghdfe d_green_num d_ben_esg $d_control, absorb(event_country event_ind) cluster(event_country event_ind)
	outreg2 using T7.doc, ctitle(d Number of Green Bonds) $export replace
reghdfe d_green_amt d_ben_esg $d_control, absorb(event_country event_ind) cluster(event_country event_ind)
	outreg2 using T7.doc, ctitle(d Amount of Green Bonds) $export append



// T8 ESG Ratings and Credit Rating Business
use "D:\CRA ESG\Data_T8.dta", clear
gen ben_esg_post=ben_esg*post
reghdfe havecredit ben_esg_post ben_esg $control, $fix_cl 
	outreg2 using T8.doc, ctitle(Have Credit Rating) $export replace
reghdfe havecredit ben_esg_post ben_esg bond_size bond_yield bond_maturity $control, $fix_cl
	outreg2 using T8.doc, ctitle(Have Credit Rating) $export append
reghdfe havecredit ben_esg_post ben_esg bond_size bond_yield bond_maturity issuer_rating $control, $fix_cl
	outreg2 using T8.doc, ctitle(Have Credit Rating) $export append
use "D:\CRA ESG\Data_T8_C4.dta", clear
gen ben_esg_post=ben_esg*post
reghdfe havecredit ben_esg_post ben_esg bond_size bond_yield bond_maturity issuer_rating $control, $fix_cl
	outreg2 using T8.doc, ctitle(Have Credit Rating) $export append



// T9 ESG Rating Informativeness
use "D:\CRA ESG\Data_T9.dta", clear
gen besg_treat_post=ben_esg*treat*post
gen besg_treat=ben_esg*treat
gen besg_post=ben_esg*post
reghdfe tv_insight besg_treat_post besg_treat besg_post treat_post ben_esg $control, $fix_cl
	outreg2 using T9.doc, ctitle(ESG Insight Score) $export replace
reghdfe reprisk_no_sev_inci  besg_treat_post besg_treat besg_post treat_post ben_esg $control, $fix_cl
	outreg2 using T9.doc, ctitle(No Severe ESG Incident) $export append	
reghdfe tc_emission besg_treat_post besg_treat besg_post treat_post ben_esg $control, $fix_cl
	outreg2 using T9.doc, ctitle(Greenhouse Gas Emission) $export append	



// T10 Entropy Balancing
use "D:\CRA ESG\Data_Main.dta", clear
keep if post==0
gsort event esg_identifier -year
duplicates drop event esg_identifier, force
ebalance treat $control, g(ebw) tar(3)
keep event esg_identifier ebw
merge 1:m event esg_identifier using "D:\CRA ESG\Data_Main.dta"
reghdfe ben_esg treat_post $control [aw=ebw], $fix_cl
	outreg2 using T10.doc, ctitle(Entropy Balancing) $export replace



// T11 Robustness Tests
use "D:\CRA ESG\Data_Main.dta", clear
reghdfe ben_esg treat_post $control if country=="UNITED STATES", $fix_cl
	outreg2 using T11.doc, ctitle(U.S. Firms) $export replace
reghdfe ben_esg treat_post $control if country!="UNITED STATES", $fix_cl
	outreg2 using T11.doc, ctitle(Non-U.S. Firms) $export append
reghdfe ben_esg treat_post $control if int(industry/1000)!=6 & int(industry/100)!=49, $fix_cl
	outreg2 using T11.doc, ctitle(Drop Finance and Utility) $export append
use "D:\CRA ESG\Data_T11_C4.dta", clear
reghdfe ben_esg treat_post $control, $fix_cl
	outreg2 using T11.doc, ctitle(Keep Switching Firms) $export append


