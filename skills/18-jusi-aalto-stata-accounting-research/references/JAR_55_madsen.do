cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata"

use demand7, clear


gen year = year(date)
gen month = month(date)
gen week = week(date)
gen dow = dow(date)
gen news_dummy = (article_cnt > 0 )
replace news_dummy = . if article_cnt == .
bysort permno: egen max_qea = max(qea_dummy)

drop if max_qea == 0
drop if news_dummy == .
drop if pre_qea_supp == .


label var lnsvi "Google"
label var ln_hits_k "Edgar 10-K"
label var ln_hits_all "Edgar All"
label var pre_qea "Earnings[-3,-1]"
label var qea "Earnings[0,2]"
label var pre_qea_supp "Supp Earnings[-3,-1]"
label var qea_supp "Supp Earnings[0,2]"


label var pre_pseudo "Pseudo Earnings[-3,-1]"
label var pseudo "Pseudo Earnings[0,2]"
label var pre_pseudo_supp "Supp Pseudo Earnings[-3,-1]"
label var pseudo_supp "Supp Pseudo Earnings[0,2]"
label var news_dummy "News Dummy"

global cust0 pre_qea qea news_dummy
global supp0 pre_qea_supp qea_supp  

sum $cust0 $supp0
*Pseudo Events - Paper Version

********
*Google
eststo A0: reghdfe lnsvi $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
*one-sided p-value 0.067


*Edgar
eststo B0: reghdfe ln_hits_all $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
*test pre_qea - pre_pseudo == 0
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))

eststo C0: reghdfe ln_hits_k $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
*test pre_qea - pre_pseudo == 0
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))


esttab A0 B0 C0, compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp0 $cust0)   label ///
		scalar("N Observations" "r2_a Adj R-Squared" "prepost Supp Pre-Earnings vs Supp Post Earnings" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f)
			
			
esttab A0 B0 C0 using "$drop/Table2_paper.tex", booktabs replace nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp0 $cust0)   label ///
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f)
	
**************************************	
*Table 7: unbundled and pseudo events
**************************************
	
global cust1 pre_cust cust news_dummy
global supp1 pre_supp supp  
			
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_mgmt
gen cust = mgmt
gen pre_supp = pre_mgmt_supp
gen supp = mgmt_supp


*Google
eststo A1: reghdfe lnsvi $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

*Edgar
eststo B1: reghdfe ln_hits_all $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

eststo C1: reghdfe ln_hits_k $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

 
***Psuedo events
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_pseudo
gen cust = pseudo
gen pre_supp = pre_pseudo_supp
gen supp = pseudo_supp

*Google
eststo A2: reghdfe lnsvi $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

*Edgar
eststo B2: reghdfe ln_hits_all $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

eststo C2: reghdfe ln_hits_k $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 



esttab A2 B2 C2 A1 B1 C1 , compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp1 $cust1)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "prepost prepost" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "Guidance" , pattern(1 0 0 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
esttab A2 B2 C2  A1 B1 C1 using "$drop/table7.tex", booktabs replace nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp1 $cust1)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "Guidance", pattern(1 0 0 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
		
***************************	
*Including Multiple events and testing differences across actual and pseudo announcement dates
***************************

global cust2 pre_qea pre_cust qea cust news_dummy
global supp2 pre_qea_supp pre_supp qea_supp supp

capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_mgmt
gen cust = mgmt
gen pre_supp = pre_mgmt_supp
gen supp = mgmt_supp


*Google
eststo A3: reghdfe lnsvi $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

*Edgar
eststo B3: reghdfe ln_hits_all $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

eststo C3: reghdfe ln_hits_k  $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace
 
***Psuedo events
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_pseudo
gen cust = pseudo
gen pre_supp = pre_pseudo_supp
gen supp = pseudo_supp

*Google
eststo A4: reghdfe lnsvi $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

*Edgar
eststo B5: reghdfe ln_hits_all $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

eststo C5: reghdfe ln_hits_k $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace
 
eststo blank: reg ln_hits_all

esttab  A4 B5 C5 blank A3 B3 C3, compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp2 $cust2) drop(_cons)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "prepost prepost" "Pseudo Pseudo" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "" "Earnings Forecast", pattern(1 0 0 1 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
esttab  A4 B5 C5 blank A3 B3 C3 using "$drop/TableS4.tex", booktabs nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp2 $cust2)  drop(_cons) label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "" "Earnings Forecast", pattern(1 0 0 1 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
		
		
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"

use cust_qea3, clear

gen month = month(eadate_crsp)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .

label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var ue_dec "UE"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"
label var size_dec "Size Decile"
label var btm_dec "Book-to-Market Decile"
label var log_analyst "Log(Analysts)"
label var replag "Reporting Lag"
label var volatility "Earnings Volatility"
label var persist "Earnings Persistence"
label var turn "Turnover"
label var instown "Inst. Ownership"
label var sue1 "UE"

global controls   ue_dec size_dec btm_dec log_analyst replag volatility persist turn instown ///
	 ue_dec_size_dec ue_dec_btm_dec ue_dec_log_analyst ue_dec_replag ue_dec_volatility ///
	ue_dec_persist	ue_dec_turn ue_dec_instown

global controls_drop   size_dec btm_dec log_analyst replag volatility persist turn instown ///
	 ue_dec_size_dec ue_dec_btm_dec ue_dec_log_analyst ue_dec_replag ue_dec_volatility ///
	ue_dec_persist	ue_dec_turn ue_dec_instown

sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6

capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo a1: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo a2: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo a3: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car85_6
	eststo a7: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car63_4
	eststo a10: reg car3_1 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
	
	
replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo b1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo b2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo b3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo b4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo b5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo b6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo b7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo b8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo b9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
	eststo b10: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
	
	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo c1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo c2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo c3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo c4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo c5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo c6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo c7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo c8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo c9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
replace cust_ind = cust_ind63_4
replace ind  = ind63_4
	eststo c10: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace

esttab a1 a2 a3 a4 a5 a6 a7 a8 a9 a10, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")

esttab b1 b2 b3 b4 b5 b6 b7 b8 b9 b10, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")

esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")
	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo aa1: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo aa2: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo aa3: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo aa4: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo aa5: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo aa6: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo aa7: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo aa8: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo aa9: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
	eststo aa10: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
	
replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo bb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo bb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo bb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo bb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo bb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo bb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo bb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo bb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo bb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
	eststo bb10: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo cc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo cc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo cc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo cc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo cc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo cc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo cc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo cc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo cc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
replace cust_ind = cust_ind63_4
replace ind  = ind63_4
	eststo cc10: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace	
	

esttab aa1 aa2 aa3 aa4 aa5 aa6 aa7 aa8 aa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab bb1 bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

**Table 3 Panel A: 60 trading days which approximates the number of trading days in a quarter;	
esttab a3 b3 c3 aa3 bb3 cc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


esttab a3 b3 c3 aa3 bb3 cc3 using "$drop/Table3PanelA.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
*Robustness
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car ue_dec) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table3PanelB.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car ue_dec) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

*internet Appendix - 63-4
esttab a10 b10 c10 aa10 bb10 cc10 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-63,-4]" supp_car "Abret[-63,-4]" cust_ind "Cust Ind Abret[-63,-4]" ind "Ind Abret [-63,-4]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


esttab a10 b10 c10 aa10 bb10 cc10 using "$drop/Table3PanelA_robust.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-63,-4]" supp_car "Abret[-63,-4]" cust_ind "Cust Ind Abret[-63,-4]" ind "Ind Abret [-63,-4]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
*********	
***SUR***
*********
reg car3_1 cust_sw_car85_6 car85_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car85_6 car85_6 $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car85_6=[j_mean]cust_sw_car85_6 
*cust_ind85_6 ind85_6
*p-value 0.46

reg car3_1 cust_sw_car65_6 car65_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car65_6 car65_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car65_6=[j_mean]cust_sw_car65_6 	
*cust_ind65_6 ind65_6
*p-value: 0.09
	
reg car3_1 cust_sw_car45_6 car45_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car45_6 car45_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car45_6=[j_mean]cust_sw_car45_6 	
*p-value: 0.0577

reg car3_1 cust_sw_car25_6 car25_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car25_6 car25_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car25_6=[j_mean]cust_sw_car25_6 	
*p-value: 0.0806



	
	
*******************************
* Interact with Edgar
*******************************	

label var cust_edgar_all_abn3_1 "Cust Edgar[-3,-1]"

capture drop cust_car supp_car

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo e1: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo e2: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo e3: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo e4: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
	eststo ee1: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo ee2: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo ee3: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo ee4: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

		
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo f1: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo f2: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo f3: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo f4: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
replace cust_ind = cust_ind25_6
replace ind = ind25_6
	eststo ff1: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo ff2: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo ff3: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo ff4: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	

esttab e1 e2 e3 e4 ee1 ee2 ee3 ee4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab e1 e2 e3 e4 ee1 ee2 ee3 ee4 using "$drop/Table4_edgar.tex" ,booktabs replace nonotes noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
			
esttab f1 f2 f3 f4 ff1 ff2 ff3 ff4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
	
*******************************
* Interact with Google
*******************************	


capture drop cust_car supp_car
sum cust_ln_ab_svi3_1 cust_lnsvi3_1, d

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo g1: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo g2: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo g3: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo g4: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
	eststo gg1: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gg2: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gg3: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gg4: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo h1: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo h2: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo h3: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo h4: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
replace cust_ind = cust_ind25_6
replace ind = ind25_6
	eststo hh1: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo hh2: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo hh3: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo hh4: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	

	
	
esttab g1 g2 g3 g4 gg1 gg2 gg3 gg4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab h1 h2 h3 h4 hh1 hh2 hh3 hh4 , noobs var(30) label ///
	compress b(%9.3f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car cust_lnsvi3_1  c.cust_car#c.cust_lnsvi3_1 supp_car ue_dec) /// 
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab g1 g2 g3 g4 gg1 gg2 gg3 gg4 using "$drop/Table4_lnsvi.tex" ,booktabs replace nonotes noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
	
	
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_sorts2, clear

eststo a0: reg _0
eststo a1: reg _1
eststo a2: reg _2
eststo a3: reg _3
eststo a4: reg _4
eststo a5: reg ls


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "CAR[-3,-1]") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


****CAR[0,2]***
use cust_sorts2a, clear


eststo aa0: reg _0
eststo aa1: reg _1
eststo aa2: reg _2
eststo aa3: reg _3
eststo aa4: reg _4
eststo aa5: reg ls


esttab aa0 aa1 aa2 aa3 aa4 aa5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "CAR[0,2]") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)
 
 
 *****By Cust Returns and Edgar***
 
 use qtrs_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00

esttab Q0_cons2 Q0_cons6 Q0_cons7 blank Q1_cons2 Q1_cons6 Q1_cons7, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 ) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons6 Q0_cons7 Q1_cons2 Q1_cons6 Q1_cons7 using "$drop/double_sorts_v2.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle("Low" "High" "High-Low" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" "Google Search", pattern(1 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 Q0_cons5 Q0_cons6 Q0_cons7, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle( "Search(Low)" "Search2" "Search3" "Search4" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 Q0_cons5 Q0_cons6 Q0_cons7 using "$drop/edgar_sorts.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle( "Search(Low)" "Search2" "Search3" "Search4" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)

	 
	 
 *****Run this to figure out Stars to add to above table***
 
 use qtrs_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53, se
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54, se
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55, se
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53, se
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54, se
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55, se
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}


cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cf_replication, clear

gen year = year(date)
*drop if year > 2004

eststo a0: reg q1
eststo a1: reg q2
eststo a2: reg q3
eststo a3: reg q4
eststo a4: reg q5
eststo a5: reg ls


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo aa0: reg q1 mktrf smb hml, robust
eststo aa1: reg q2 mktrf smb hml, robust
eststo aa2: reg q3 mktrf smb hml, robust
eststo aa3: reg q4 mktrf smb hml, robust
eststo aa4: reg q5 mktrf smb hml, robust
eststo aa5: reg ls mktrf smb hml, robust


esttab aa0 aa1 aa2 aa3 aa4 aa5, booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaa0: reg q1 mktrf smb hml umd, robust
eststo aaa1: reg q2 mktrf smb hml umd, robust
eststo aaa2: reg q3 mktrf smb hml umd, robust
eststo aaa3: reg q4 mktrf smb hml umd, robust
eststo aaa4: reg q5 mktrf smb hml umd, robust
eststo aaa5: reg ls mktrf smb hml umd, robust


esttab aaa0 aaa1 aaa2 aaa3 aaa4 aaa5, booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaaa0: reg q1 mktrf smb hml umd ps_vwf, robust
eststo aaaa1: reg q2 mktrf smb hml umd ps_vwf, robust
eststo aaaa2: reg q3 mktrf smb hml umd ps_vwf, robust
eststo aaaa3: reg q4 mktrf smb hml umd ps_vwf, robust
eststo aaaa4: reg q5 mktrf smb hml umd ps_vwf, robust
eststo aaaa5: reg ls mktrf smb hml umd ps_vwf, robust


esttab aaaa0 aaaa1 aaaa2 aaaa3 aaaa4 aaaa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
****
*Save the intercepts as file Table6.tex
****
 
 use cust_sorts_ea2, clear

eststo a0: reg q1_non
eststo a1: reg q2_non
eststo a2: reg q3_non
eststo a3: reg q4_non
eststo a4: reg q5_non
eststo a5: reg ls_non


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes  transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo a0b: reg q1_ea
eststo a1b: reg q2_ea
eststo a2b: reg q3_ea
eststo a3b: reg q4_ea
eststo a4b: reg q5_ea
eststo a5b: reg ls_ea

esttab a0b a1b a2b a3b a4b a5b, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes  transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

		
eststo aa0: reg q1_non mktrf smb hml, robust
eststo aa1: reg q2_non mktrf smb hml, robust
eststo aa2: reg q3_non mktrf smb hml, robust
eststo aa3: reg q4_non mktrf smb hml, robust
eststo aa4: reg q5_non mktrf smb hml, robust
eststo aa5: reg ls_non mktrf smb hml, robust

esttab aa0 aa1 aa2 aa3 aa4 aa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aa0b: reg q1_ea mktrf smb hml, robust
eststo aa1b: reg q2_ea mktrf smb hml, robust
eststo aa2b: reg q3_ea mktrf smb hml, robust
eststo aa3b: reg q4_ea mktrf smb hml, robust
eststo aa4b: reg q5_ea mktrf smb hml, robust
eststo aa5b: reg ls_ea mktrf smb hml, robust

esttab aa0b aa1b aa2b aa3b aa4b aa5b, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
**********
*4-factor
**********		
eststo aaa0: reg q1_non mktrf smb hml umd, robust
eststo aaa1: reg q2_non mktrf smb hml umd, robust
eststo aaa2: reg q3_non mktrf smb hml umd, robust
eststo aaa3: reg q4_non mktrf smb hml umd, robust
eststo aaa4: reg q5_non mktrf smb hml umd, robust
eststo aaa5: reg ls_non mktrf smb hml umd, robust


esttab aaa0 aaa1 aaa2 aaa3 aaa4 aaa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaa0b: reg q1_ea mktrf smb hml umd, robust
eststo aaa1b: reg q2_ea mktrf smb hml umd, robust
eststo aaa2b: reg q3_ea mktrf smb hml umd, robust
eststo aaa3b: reg q4_ea mktrf smb hml umd, robust
eststo aaa4b: reg q5_ea mktrf smb hml umd, robust
eststo aaa5b: reg ls_ea mktrf smb hml umd, robust


esttab aaa0b aaa1b aaa2b aaa3b aaa4b aaa5b,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

**********
*5-factor
**********	

eststo aaaa0: reg q1_non mktrf smb hml umd ps_vwf, robust
eststo aaaa1: reg q2_non mktrf smb hml umd ps_vwf, robust
eststo aaaa2: reg q3_non mktrf smb hml umd ps_vwf, robust
eststo aaaa3: reg q4_non mktrf smb hml umd ps_vwf, robust
eststo aaaa4: reg q5_non mktrf smb hml umd ps_vwf, robust
eststo aaaa5: reg ls_non mktrf smb hml umd ps_vwf, robust


esttab aaaa0 aaaa1 aaaa2 aaaa3 aaaa4 aaaa5, keep(_cons) booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaaa0b: reg q1_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa1b: reg q2_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa2b: reg q3_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa3b: reg q4_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa4b: reg q5_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa5b: reg ls_ea mktrf smb hml umd ps_vwf, robust


esttab aaaa0b aaaa1b aaaa2b aaaa3b aaaa4b aaaa5b, booktabs keep(_cons) noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
reg double_	mktrf smb hml umd ps_vwf, robust	
****
*Save the intercepts as file 
****


 *****By Cust Returns and Edgar***
 
 use qtrs5_2_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}
/*
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' mktrf smb hml, robust
}
}
*/
esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)


forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs5_2_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}
/*
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' mktrf smb hml umd, robust
}
}
*/
esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)

forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00

esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4 using "$drop/Table6_double_sorts.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" "" "Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
esttab Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) title("SVI")  ///
	compress mtitle( "Search(Low)" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) title("Edgar")  ///
	compress mtitle( "Search(Low)" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 

	 
	 
 *Run this to figure out stars
 
 use qtrs5_2_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)


forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs5_2_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)

forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00


esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4 using "$drop/Table6_double_sorts_stars.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100) ///
	 mgroups("Edgar Search" "" "Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
		 cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"


global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_qea_pseudo3, clear

gen month = month(date_pseudo)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

*drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .
drop if cust_sw_car65_6 == .
drop if car65_6 == .

label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"

	
global controls  size_dec btm_dec log_analyst  volatility persist turn instown 
	
	
sum $controls 
sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6



*Pre-announcement returns
	
	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo a1: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo a2: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo a3: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo a4: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo a5: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo a6: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo a7: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo a8: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo a9: reg car3_1 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo b1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo b2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo b3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo b4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo b5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo b6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo b7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo b8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo b9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo c1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo c2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo c3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo c4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo c5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo c6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo c7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo c8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo c9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace


esttab a1 a2 a3 a4 a5 a6 a7 a8 a9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab b1 b2 b3 b4 b5 b6 b7 b8 b9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab c1 c2 c3 c4 c5 c6 c7 c8 c9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
	
	
	
*Announcement Returns


capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo aa1: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo aa2: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo aa3: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo aa4: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo aa5: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo aa6: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo aa7: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo aa8: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo aa9: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo bb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo bb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo bb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo bb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo bb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo bb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo bb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo bb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo bb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo cc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo cc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo cc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo cc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo cc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo cc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo cc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo cc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo cc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
	
	

esttab aa1 aa2 aa3 aa4 aa5 aa6 aa7 aa8 aa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab bb1 bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

esttab a1 b1 c1 aa1 bb1 cc1, replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-25,-6]" supp_car "Abret[-25,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-25,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab a3 b3 c3 aa3 bb3 cc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
**Table 7 : Going with 60 trading days which approximates the number of trading days in a quarter;	
** Guidance regressions estimated in file "cust QEA guidance.do"

esttab c3 cc3 gc3 gcc3 , replace nonotes noobs label var(25)  ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Pseudo Events" "Guidance" , pattern(1 0 1  0)span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	mtitle("CAR[-3,-1]" "CAR[0,2]" "CAR[-3,-1]" "CAR[0,2]")  

esttab c3 cc3 gc3 gcc3 using "$drop/Table7.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Pseudo Events" "Guidance" , pattern(1 0 1  0)span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	mtitle("CAR[-3,-1]" "CAR[0,2]" "CAR[-3,-1]" "CAR[0,2]")  
	
	

*Robustness
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

/*
esttab a3 b3 c3 aa3 bb3 cc3 using "$drop/Table7PanelA.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table7PanelA_robust.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"


global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_qea_guidance, clear

gen month = month(anndate)
gen year = year(anndate)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

*drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .


label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"

	
global controls  size_dec btm_dec log_analyst  volatility persist turn instown 

sum $controls	
sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6

	
*Pre-announcement returns
	
	
capture  drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo ga1: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo ga2: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo ga3: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo ga4: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo ga5: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo ga6: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo ga7: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo ga8: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo ga9: reg car3_1 cust_car, cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo gb1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gb2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gb3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo gb4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo gb5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo gb6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gb7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo gb8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo gb9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo gc1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo gc2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo gc3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo gc4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo gc5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo gc6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo gc7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo gc8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo gc9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace


esttab ga1 ga2 ga3 ga4 ga5 ga6 ga7 ga8 ga9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gb1 gb2 gb3 gb4 gb5 gb6 gb7 gb8 gb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gc1 gc2 gc3 gc4 gc5 gc6 gc7 gc8 gc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
	
	
	
*Announcement Returns


capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo gaa1: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo gaa2: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo gaa3: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo gaa4: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo gaa5: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo gaa6: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo gaa7: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo gaa8: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo gaa9: reg car0_2 cust_car, cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo gbb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gbb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gbb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo gbb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo gbb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo gbb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gbb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo gbb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo gbb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo gcc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo gcc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo gcc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo gcc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo gcc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo gcc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo gcc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo gcc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo gcc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
	
	

esttab gaa1 gaa2 gaa3 gaa4 gaa5 gaa6 gaa7 gaa8 gaa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gbb1 gbb2 gbb3 gbb4 gbb5 gbb6 gbb7 gbb8 gbb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gcc1 gcc2 gcc3 gcc4 gcc5 gcc6 gcc7 gcc8 gcc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

**Table XXX Panel A: Going with 60 trading days which approximates the number of trading days in a quarter;	
esttab ga3 gb3 gc3 gaa3 gbb3 gcc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

***Tabulated as part of CUST QEA Pseudo.do file*****

	
*Robustness
esttab gc1 gc2 gc3 gc7  gcc1 gcc2 gcc3 gcc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

/*

esttab ga3 gb3 gc3 gaa3 gbb3 gcc3 using "$drop/Table7PanelB.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table7PanelA_robust.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata"

use demand7, clear


gen year = year(date)
gen month = month(date)
gen week = week(date)
gen dow = dow(date)
gen news_dummy = (article_cnt > 0 )
replace news_dummy = . if article_cnt == .
bysort permno: egen max_qea = max(qea_dummy)

drop if max_qea == 0
drop if news_dummy == .
drop if pre_qea_supp == .


label var lnsvi "Google"
label var ln_hits_k "Edgar 10-K"
label var ln_hits_all "Edgar All"
label var pre_qea "Earnings[-3,-1]"
label var qea "Earnings[0,2]"
label var pre_qea_supp "Supp Earnings[-3,-1]"
label var qea_supp "Supp Earnings[0,2]"


label var pre_pseudo "Pseudo Earnings[-3,-1]"
label var pseudo "Pseudo Earnings[0,2]"
label var pre_pseudo_supp "Supp Pseudo Earnings[-3,-1]"
label var pseudo_supp "Supp Pseudo Earnings[0,2]"
label var news_dummy "News Dummy"

global cust0 pre_qea qea news_dummy
global supp0 pre_qea_supp qea_supp  

sum $cust0 $supp0
*Pseudo Events - Paper Version

********
*Google
eststo A0: reghdfe lnsvi $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
*one-sided p-value 0.067


*Edgar
eststo B0: reghdfe ln_hits_all $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
*test pre_qea - pre_pseudo == 0
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))

eststo C0: reghdfe ln_hits_k $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
*test pre_qea - pre_pseudo == 0
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))


esttab A0 B0 C0, compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp0 $cust0)   label ///
		scalar("N Observations" "r2_a Adj R-Squared" "prepost Supp Pre-Earnings vs Supp Post Earnings" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f)
			
			
esttab A0 B0 C0 using "$drop/Table2_paper.tex", booktabs replace nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp0 $cust0)   label ///
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f)
	
**************************************	
*Table 7: unbundled and pseudo events
**************************************
	
global cust1 pre_cust cust news_dummy
global supp1 pre_supp supp  
			
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_mgmt
gen cust = mgmt
gen pre_supp = pre_mgmt_supp
gen supp = mgmt_supp


*Google
eststo A1: reghdfe lnsvi $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

*Edgar
eststo B1: reghdfe ln_hits_all $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

eststo C1: reghdfe ln_hits_k $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

 
***Psuedo events
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_pseudo
gen cust = pseudo
gen pre_supp = pre_pseudo_supp
gen supp = pseudo_supp

*Google
eststo A2: reghdfe lnsvi $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

*Edgar
eststo B2: reghdfe ln_hits_all $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

eststo C2: reghdfe ln_hits_k $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 



esttab A2 B2 C2 A1 B1 C1 , compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp1 $cust1)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "prepost prepost" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "Guidance" , pattern(1 0 0 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
esttab A2 B2 C2  A1 B1 C1 using "$drop/table7.tex", booktabs replace nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp1 $cust1)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "Guidance", pattern(1 0 0 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
		
***************************	
*Including Multiple events and testing differences across actual and pseudo announcement dates
***************************

global cust2 pre_qea pre_cust qea cust news_dummy
global supp2 pre_qea_supp pre_supp qea_supp supp

capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_mgmt
gen cust = mgmt
gen pre_supp = pre_mgmt_supp
gen supp = mgmt_supp


*Google
eststo A3: reghdfe lnsvi $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

*Edgar
eststo B3: reghdfe ln_hits_all $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

eststo C3: reghdfe ln_hits_k  $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace
 
***Psuedo events
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_pseudo
gen cust = pseudo
gen pre_supp = pre_pseudo_supp
gen supp = pseudo_supp

*Google
eststo A4: reghdfe lnsvi $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

*Edgar
eststo B5: reghdfe ln_hits_all $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

eststo C5: reghdfe ln_hits_k $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace
 
eststo blank: reg ln_hits_all

esttab  A4 B5 C5 blank A3 B3 C3, compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp2 $cust2) drop(_cons)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "prepost prepost" "Pseudo Pseudo" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "" "Earnings Forecast", pattern(1 0 0 1 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
esttab  A4 B5 C5 blank A3 B3 C3 using "$drop/TableS4.tex", booktabs nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp2 $cust2)  drop(_cons) label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "" "Earnings Forecast", pattern(1 0 0 1 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
		
		
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"

use cust_qea3, clear

gen month = month(eadate_crsp)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .

label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var ue_dec "UE"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"
label var size_dec "Size Decile"
label var btm_dec "Book-to-Market Decile"
label var log_analyst "Log(Analysts)"
label var replag "Reporting Lag"
label var volatility "Earnings Volatility"
label var persist "Earnings Persistence"
label var turn "Turnover"
label var instown "Inst. Ownership"
label var sue1 "UE"

global controls   ue_dec size_dec btm_dec log_analyst replag volatility persist turn instown ///
	 ue_dec_size_dec ue_dec_btm_dec ue_dec_log_analyst ue_dec_replag ue_dec_volatility ///
	ue_dec_persist	ue_dec_turn ue_dec_instown

global controls_drop   size_dec btm_dec log_analyst replag volatility persist turn instown ///
	 ue_dec_size_dec ue_dec_btm_dec ue_dec_log_analyst ue_dec_replag ue_dec_volatility ///
	ue_dec_persist	ue_dec_turn ue_dec_instown

sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6

capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo a1: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo a2: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo a3: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car85_6
	eststo a7: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car63_4
	eststo a10: reg car3_1 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
	
	
replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo b1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo b2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo b3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo b4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo b5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo b6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo b7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo b8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo b9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
	eststo b10: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
	
	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo c1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo c2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo c3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo c4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo c5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo c6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo c7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo c8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo c9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
replace cust_ind = cust_ind63_4
replace ind  = ind63_4
	eststo c10: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace

esttab a1 a2 a3 a4 a5 a6 a7 a8 a9 a10, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")

esttab b1 b2 b3 b4 b5 b6 b7 b8 b9 b10, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")

esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")
	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo aa1: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo aa2: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo aa3: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo aa4: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo aa5: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo aa6: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo aa7: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo aa8: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo aa9: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
	eststo aa10: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
	
replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo bb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo bb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo bb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo bb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo bb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo bb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo bb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo bb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo bb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
	eststo bb10: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo cc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo cc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo cc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo cc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo cc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo cc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo cc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo cc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo cc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
replace cust_ind = cust_ind63_4
replace ind  = ind63_4
	eststo cc10: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace	
	

esttab aa1 aa2 aa3 aa4 aa5 aa6 aa7 aa8 aa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab bb1 bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

**Table 3 Panel A: 60 trading days which approximates the number of trading days in a quarter;	
esttab a3 b3 c3 aa3 bb3 cc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


esttab a3 b3 c3 aa3 bb3 cc3 using "$drop/Table3PanelA.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
*Robustness
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car ue_dec) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table3PanelB.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car ue_dec) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

*internet Appendix - 63-4
esttab a10 b10 c10 aa10 bb10 cc10 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-63,-4]" supp_car "Abret[-63,-4]" cust_ind "Cust Ind Abret[-63,-4]" ind "Ind Abret [-63,-4]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


esttab a10 b10 c10 aa10 bb10 cc10 using "$drop/Table3PanelA_robust.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-63,-4]" supp_car "Abret[-63,-4]" cust_ind "Cust Ind Abret[-63,-4]" ind "Ind Abret [-63,-4]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
*********	
***SUR***
*********
reg car3_1 cust_sw_car85_6 car85_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car85_6 car85_6 $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car85_6=[j_mean]cust_sw_car85_6 
*cust_ind85_6 ind85_6
*p-value 0.46

reg car3_1 cust_sw_car65_6 car65_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car65_6 car65_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car65_6=[j_mean]cust_sw_car65_6 	
*cust_ind65_6 ind65_6
*p-value: 0.09
	
reg car3_1 cust_sw_car45_6 car45_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car45_6 car45_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car45_6=[j_mean]cust_sw_car45_6 	
*p-value: 0.0577

reg car3_1 cust_sw_car25_6 car25_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car25_6 car25_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car25_6=[j_mean]cust_sw_car25_6 	
*p-value: 0.0806



	
	
*******************************
* Interact with Edgar
*******************************	

label var cust_edgar_all_abn3_1 "Cust Edgar[-3,-1]"

capture drop cust_car supp_car

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo e1: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo e2: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo e3: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo e4: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
	eststo ee1: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo ee2: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo ee3: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo ee4: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

		
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo f1: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo f2: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo f3: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo f4: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
replace cust_ind = cust_ind25_6
replace ind = ind25_6
	eststo ff1: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo ff2: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo ff3: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo ff4: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	

esttab e1 e2 e3 e4 ee1 ee2 ee3 ee4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab e1 e2 e3 e4 ee1 ee2 ee3 ee4 using "$drop/Table4_edgar.tex" ,booktabs replace nonotes noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
			
esttab f1 f2 f3 f4 ff1 ff2 ff3 ff4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
	
*******************************
* Interact with Google
*******************************	


capture drop cust_car supp_car
sum cust_ln_ab_svi3_1 cust_lnsvi3_1, d

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo g1: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo g2: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo g3: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo g4: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
	eststo gg1: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gg2: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gg3: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gg4: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo h1: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo h2: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo h3: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo h4: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
replace cust_ind = cust_ind25_6
replace ind = ind25_6
	eststo hh1: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo hh2: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo hh3: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo hh4: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	

	
	
esttab g1 g2 g3 g4 gg1 gg2 gg3 gg4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab h1 h2 h3 h4 hh1 hh2 hh3 hh4 , noobs var(30) label ///
	compress b(%9.3f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car cust_lnsvi3_1  c.cust_car#c.cust_lnsvi3_1 supp_car ue_dec) /// 
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab g1 g2 g3 g4 gg1 gg2 gg3 gg4 using "$drop/Table4_lnsvi.tex" ,booktabs replace nonotes noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
	
	
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_sorts2, clear

eststo a0: reg _0
eststo a1: reg _1
eststo a2: reg _2
eststo a3: reg _3
eststo a4: reg _4
eststo a5: reg ls


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "CAR[-3,-1]") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


****CAR[0,2]***
use cust_sorts2a, clear


eststo aa0: reg _0
eststo aa1: reg _1
eststo aa2: reg _2
eststo aa3: reg _3
eststo aa4: reg _4
eststo aa5: reg ls


esttab aa0 aa1 aa2 aa3 aa4 aa5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "CAR[0,2]") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)
 
 
 *****By Cust Returns and Edgar***
 
 use qtrs_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00

esttab Q0_cons2 Q0_cons6 Q0_cons7 blank Q1_cons2 Q1_cons6 Q1_cons7, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 ) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons6 Q0_cons7 Q1_cons2 Q1_cons6 Q1_cons7 using "$drop/double_sorts_v2.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle("Low" "High" "High-Low" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" "Google Search", pattern(1 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 Q0_cons5 Q0_cons6 Q0_cons7, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle( "Search(Low)" "Search2" "Search3" "Search4" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 Q0_cons5 Q0_cons6 Q0_cons7 using "$drop/edgar_sorts.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle( "Search(Low)" "Search2" "Search3" "Search4" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)

	 
	 
 *****Run this to figure out Stars to add to above table***
 
 use qtrs_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53, se
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54, se
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55, se
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53, se
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54, se
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55, se
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}


cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cf_replication, clear

gen year = year(date)
*drop if year > 2004

eststo a0: reg q1
eststo a1: reg q2
eststo a2: reg q3
eststo a3: reg q4
eststo a4: reg q5
eststo a5: reg ls


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo aa0: reg q1 mktrf smb hml, robust
eststo aa1: reg q2 mktrf smb hml, robust
eststo aa2: reg q3 mktrf smb hml, robust
eststo aa3: reg q4 mktrf smb hml, robust
eststo aa4: reg q5 mktrf smb hml, robust
eststo aa5: reg ls mktrf smb hml, robust


esttab aa0 aa1 aa2 aa3 aa4 aa5, booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaa0: reg q1 mktrf smb hml umd, robust
eststo aaa1: reg q2 mktrf smb hml umd, robust
eststo aaa2: reg q3 mktrf smb hml umd, robust
eststo aaa3: reg q4 mktrf smb hml umd, robust
eststo aaa4: reg q5 mktrf smb hml umd, robust
eststo aaa5: reg ls mktrf smb hml umd, robust


esttab aaa0 aaa1 aaa2 aaa3 aaa4 aaa5, booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaaa0: reg q1 mktrf smb hml umd ps_vwf, robust
eststo aaaa1: reg q2 mktrf smb hml umd ps_vwf, robust
eststo aaaa2: reg q3 mktrf smb hml umd ps_vwf, robust
eststo aaaa3: reg q4 mktrf smb hml umd ps_vwf, robust
eststo aaaa4: reg q5 mktrf smb hml umd ps_vwf, robust
eststo aaaa5: reg ls mktrf smb hml umd ps_vwf, robust


esttab aaaa0 aaaa1 aaaa2 aaaa3 aaaa4 aaaa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
****
*Save the intercepts as file Table6.tex
****
 
 use cust_sorts_ea2, clear

eststo a0: reg q1_non
eststo a1: reg q2_non
eststo a2: reg q3_non
eststo a3: reg q4_non
eststo a4: reg q5_non
eststo a5: reg ls_non


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes  transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo a0b: reg q1_ea
eststo a1b: reg q2_ea
eststo a2b: reg q3_ea
eststo a3b: reg q4_ea
eststo a4b: reg q5_ea
eststo a5b: reg ls_ea

esttab a0b a1b a2b a3b a4b a5b, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes  transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

		
eststo aa0: reg q1_non mktrf smb hml, robust
eststo aa1: reg q2_non mktrf smb hml, robust
eststo aa2: reg q3_non mktrf smb hml, robust
eststo aa3: reg q4_non mktrf smb hml, robust
eststo aa4: reg q5_non mktrf smb hml, robust
eststo aa5: reg ls_non mktrf smb hml, robust

esttab aa0 aa1 aa2 aa3 aa4 aa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aa0b: reg q1_ea mktrf smb hml, robust
eststo aa1b: reg q2_ea mktrf smb hml, robust
eststo aa2b: reg q3_ea mktrf smb hml, robust
eststo aa3b: reg q4_ea mktrf smb hml, robust
eststo aa4b: reg q5_ea mktrf smb hml, robust
eststo aa5b: reg ls_ea mktrf smb hml, robust

esttab aa0b aa1b aa2b aa3b aa4b aa5b, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
**********
*4-factor
**********		
eststo aaa0: reg q1_non mktrf smb hml umd, robust
eststo aaa1: reg q2_non mktrf smb hml umd, robust
eststo aaa2: reg q3_non mktrf smb hml umd, robust
eststo aaa3: reg q4_non mktrf smb hml umd, robust
eststo aaa4: reg q5_non mktrf smb hml umd, robust
eststo aaa5: reg ls_non mktrf smb hml umd, robust


esttab aaa0 aaa1 aaa2 aaa3 aaa4 aaa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaa0b: reg q1_ea mktrf smb hml umd, robust
eststo aaa1b: reg q2_ea mktrf smb hml umd, robust
eststo aaa2b: reg q3_ea mktrf smb hml umd, robust
eststo aaa3b: reg q4_ea mktrf smb hml umd, robust
eststo aaa4b: reg q5_ea mktrf smb hml umd, robust
eststo aaa5b: reg ls_ea mktrf smb hml umd, robust


esttab aaa0b aaa1b aaa2b aaa3b aaa4b aaa5b,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

**********
*5-factor
**********	

eststo aaaa0: reg q1_non mktrf smb hml umd ps_vwf, robust
eststo aaaa1: reg q2_non mktrf smb hml umd ps_vwf, robust
eststo aaaa2: reg q3_non mktrf smb hml umd ps_vwf, robust
eststo aaaa3: reg q4_non mktrf smb hml umd ps_vwf, robust
eststo aaaa4: reg q5_non mktrf smb hml umd ps_vwf, robust
eststo aaaa5: reg ls_non mktrf smb hml umd ps_vwf, robust


esttab aaaa0 aaaa1 aaaa2 aaaa3 aaaa4 aaaa5, keep(_cons) booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaaa0b: reg q1_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa1b: reg q2_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa2b: reg q3_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa3b: reg q4_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa4b: reg q5_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa5b: reg ls_ea mktrf smb hml umd ps_vwf, robust


esttab aaaa0b aaaa1b aaaa2b aaaa3b aaaa4b aaaa5b, booktabs keep(_cons) noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
reg double_	mktrf smb hml umd ps_vwf, robust	
****
*Save the intercepts as file 
****


 *****By Cust Returns and Edgar***
 
 use qtrs5_2_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}
/*
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' mktrf smb hml, robust
}
}
*/
esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)


forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs5_2_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}
/*
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' mktrf smb hml umd, robust
}
}
*/
esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)

forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00

esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4 using "$drop/Table6_double_sorts.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" "" "Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
esttab Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) title("SVI")  ///
	compress mtitle( "Search(Low)" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) title("Edgar")  ///
	compress mtitle( "Search(Low)" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 

	 
	 
 *Run this to figure out stars
 
 use qtrs5_2_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)


forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs5_2_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)

forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00


esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4 using "$drop/Table6_double_sorts_stars.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100) ///
	 mgroups("Edgar Search" "" "Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
		 cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"


global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_qea_pseudo3, clear

gen month = month(date_pseudo)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

*drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .
drop if cust_sw_car65_6 == .
drop if car65_6 == .

label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"

	
global controls  size_dec btm_dec log_analyst  volatility persist turn instown 
	
	
sum $controls 
sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6



*Pre-announcement returns
	
	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo a1: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo a2: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo a3: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo a4: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo a5: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo a6: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo a7: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo a8: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo a9: reg car3_1 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo b1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo b2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo b3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo b4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo b5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo b6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo b7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo b8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo b9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo c1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo c2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo c3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo c4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo c5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo c6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo c7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo c8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo c9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace


esttab a1 a2 a3 a4 a5 a6 a7 a8 a9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab b1 b2 b3 b4 b5 b6 b7 b8 b9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab c1 c2 c3 c4 c5 c6 c7 c8 c9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
	
	
	
*Announcement Returns


capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo aa1: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo aa2: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo aa3: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo aa4: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo aa5: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo aa6: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo aa7: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo aa8: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo aa9: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo bb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo bb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo bb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo bb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo bb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo bb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo bb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo bb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo bb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo cc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo cc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo cc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo cc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo cc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo cc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo cc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo cc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo cc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
	
	

esttab aa1 aa2 aa3 aa4 aa5 aa6 aa7 aa8 aa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab bb1 bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

esttab a1 b1 c1 aa1 bb1 cc1, replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-25,-6]" supp_car "Abret[-25,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-25,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab a3 b3 c3 aa3 bb3 cc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
**Table 7 : Going with 60 trading days which approximates the number of trading days in a quarter;	
** Guidance regressions estimated in file "cust QEA guidance.do"

esttab c3 cc3 gc3 gcc3 , replace nonotes noobs label var(25)  ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Pseudo Events" "Guidance" , pattern(1 0 1  0)span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	mtitle("CAR[-3,-1]" "CAR[0,2]" "CAR[-3,-1]" "CAR[0,2]")  

esttab c3 cc3 gc3 gcc3 using "$drop/Table7.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Pseudo Events" "Guidance" , pattern(1 0 1  0)span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	mtitle("CAR[-3,-1]" "CAR[0,2]" "CAR[-3,-1]" "CAR[0,2]")  
	
	

*Robustness
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

/*
esttab a3 b3 c3 aa3 bb3 cc3 using "$drop/Table7PanelA.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table7PanelA_robust.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"


global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_qea_guidance, clear

gen month = month(anndate)
gen year = year(anndate)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

*drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .


label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"

	
global controls  size_dec btm_dec log_analyst  volatility persist turn instown 

sum $controls	
sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6

	
*Pre-announcement returns
	
	
capture  drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo ga1: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo ga2: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo ga3: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo ga4: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo ga5: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo ga6: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo ga7: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo ga8: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo ga9: reg car3_1 cust_car, cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo gb1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gb2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gb3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo gb4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo gb5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo gb6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gb7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo gb8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo gb9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo gc1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo gc2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo gc3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo gc4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo gc5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo gc6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo gc7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo gc8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo gc9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace


esttab ga1 ga2 ga3 ga4 ga5 ga6 ga7 ga8 ga9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gb1 gb2 gb3 gb4 gb5 gb6 gb7 gb8 gb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gc1 gc2 gc3 gc4 gc5 gc6 gc7 gc8 gc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
	
	
	
*Announcement Returns


capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo gaa1: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo gaa2: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo gaa3: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo gaa4: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo gaa5: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo gaa6: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo gaa7: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo gaa8: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo gaa9: reg car0_2 cust_car, cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo gbb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gbb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gbb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo gbb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo gbb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo gbb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gbb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo gbb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo gbb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo gcc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo gcc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo gcc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo gcc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo gcc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo gcc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo gcc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo gcc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo gcc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
	
	

esttab gaa1 gaa2 gaa3 gaa4 gaa5 gaa6 gaa7 gaa8 gaa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gbb1 gbb2 gbb3 gbb4 gbb5 gbb6 gbb7 gbb8 gbb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gcc1 gcc2 gcc3 gcc4 gcc5 gcc6 gcc7 gcc8 gcc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

**Table XXX Panel A: Going with 60 trading days which approximates the number of trading days in a quarter;	
esttab ga3 gb3 gc3 gaa3 gbb3 gcc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

***Tabulated as part of CUST QEA Pseudo.do file*****

	
*Robustness
esttab gc1 gc2 gc3 gc7  gcc1 gcc2 gcc3 gcc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

/*

esttab ga3 gb3 gc3 gaa3 gbb3 gcc3 using "$drop/Table7PanelB.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table7PanelA_robust.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata"

use demand7, clear


gen year = year(date)
gen month = month(date)
gen week = week(date)
gen dow = dow(date)
gen news_dummy = (article_cnt > 0 )
replace news_dummy = . if article_cnt == .
bysort permno: egen max_qea = max(qea_dummy)

drop if max_qea == 0
drop if news_dummy == .
drop if pre_qea_supp == .


label var lnsvi "Google"
label var ln_hits_k "Edgar 10-K"
label var ln_hits_all "Edgar All"
label var pre_qea "Earnings[-3,-1]"
label var qea "Earnings[0,2]"
label var pre_qea_supp "Supp Earnings[-3,-1]"
label var qea_supp "Supp Earnings[0,2]"


label var pre_pseudo "Pseudo Earnings[-3,-1]"
label var pseudo "Pseudo Earnings[0,2]"
label var pre_pseudo_supp "Supp Pseudo Earnings[-3,-1]"
label var pseudo_supp "Supp Pseudo Earnings[0,2]"
label var news_dummy "News Dummy"

global cust0 pre_qea qea news_dummy
global supp0 pre_qea_supp qea_supp  

sum $cust0 $supp0
*Pseudo Events - Paper Version

********
*Google
eststo A0: reghdfe lnsvi $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
*one-sided p-value 0.067


*Edgar
eststo B0: reghdfe ln_hits_all $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
*test pre_qea - pre_pseudo == 0
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))

eststo C0: reghdfe ln_hits_k $supp0 $cust0, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_qea_supp - qea_supp == 0
qui: estadd scalar prepost r(p), replace 
*test pre_qea - pre_pseudo == 0
local sign_wgt = sign(_b[pre_qea_supp]-_b[qea_supp])
display "Ho: coef <= 0  p-value = " ttail(r(df_r),`sign_wgt'*sqrt(r(F)))
display "Ho: coef >= 0  p-value = " 1-ttail(r(df_r),`sign_wgt'*sqrt(r(F)))


esttab A0 B0 C0, compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp0 $cust0)   label ///
		scalar("N Observations" "r2_a Adj R-Squared" "prepost Supp Pre-Earnings vs Supp Post Earnings" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f)
			
			
esttab A0 B0 C0 using "$drop/Table2_paper.tex", booktabs replace nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp0 $cust0)   label ///
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f)
	
**************************************	
*Table 7: unbundled and pseudo events
**************************************
	
global cust1 pre_cust cust news_dummy
global supp1 pre_supp supp  
			
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_mgmt
gen cust = mgmt
gen pre_supp = pre_mgmt_supp
gen supp = mgmt_supp


*Google
eststo A1: reghdfe lnsvi $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

*Edgar
eststo B1: reghdfe ln_hits_all $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

eststo C1: reghdfe ln_hits_k $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

 
***Psuedo events
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_pseudo
gen cust = pseudo
gen pre_supp = pre_pseudo_supp
gen supp = pseudo_supp

*Google
eststo A2: reghdfe lnsvi $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

*Edgar
eststo B2: reghdfe ln_hits_all $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 

eststo C2: reghdfe ln_hits_k $supp1 $cust1, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 



esttab A2 B2 C2 A1 B1 C1 , compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp1 $cust1)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "prepost prepost" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "Guidance" , pattern(1 0 0 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
esttab A2 B2 C2  A1 B1 C1 using "$drop/table7.tex", booktabs replace nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp1 $cust1)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "Guidance", pattern(1 0 0 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
		
***************************	
*Including Multiple events and testing differences across actual and pseudo announcement dates
***************************

global cust2 pre_qea pre_cust qea cust news_dummy
global supp2 pre_qea_supp pre_supp qea_supp supp

capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_mgmt
gen cust = mgmt
gen pre_supp = pre_mgmt_supp
gen supp = mgmt_supp


*Google
eststo A3: reghdfe lnsvi $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

*Edgar
eststo B3: reghdfe ln_hits_all $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

eststo C3: reghdfe ln_hits_k  $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace
 
***Psuedo events
capture drop pre_cust cust pre_supp supp
gen pre_cust = pre_pseudo
gen cust = pseudo
gen pre_supp = pre_pseudo_supp
gen supp = pseudo_supp

*Google
eststo A4: reghdfe lnsvi $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

*Edgar
eststo B5: reghdfe ln_hits_all $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace

eststo C5: reghdfe ln_hits_k $supp2 $cust2, a(permno dow month#year) cluster(permno date)
qui: estadd local firm "Yes", replace
qui: estadd local dow "Yes", replace
qui: estadd local month "Yes", replace
qui: estadd local controls "Yes", replace
test pre_supp - supp == 0
qui: estadd scalar prepost r(p), replace 
test pre_qea_supp - pre_supp == 0
qui: estadd scalar Pseudo r(p), replace
 
eststo blank: reg ln_hits_all

esttab  A4 B5 C5 blank A3 B3 C3, compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp2 $cust2) drop(_cons)   label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "prepost prepost" "Pseudo Pseudo" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "" "Earnings Forecast", pattern(1 0 0 1 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
esttab  A4 B5 C5 blank A3 B3 C3 using "$drop/TableS4.tex", booktabs nonotes compress b(%9.3f) var(35) star(* 0.1 ** 0.05 *** 0.01) noobs ///
		order($supp2 $cust2)  drop(_cons) label ///
		coeflabel(pre_supp "Supp[-3,-1]" supp "Supp[0,2]" pre_cust "Cust[-3,-1]" cust "Cust[0,2]") /// 
		scalar("N Observations" "r2_a Adj R-Squared" "firm Firm FE" "dow Day of Week FE" ///
			"month Year-Month FE") sfmt(%9.0fc %9.2f) ///
		mgroups("Pseudo Events" "" "Earnings Forecast", pattern(1 0 0 1 1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
		
		

cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"

use cust_qea3, clear

gen month = month(eadate_crsp)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .

label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var ue_dec "UE"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"
label var size_dec "Size Decile"
label var btm_dec "Book-to-Market Decile"
label var log_analyst "Log(Analysts)"
label var replag "Reporting Lag"
label var volatility "Earnings Volatility"
label var persist "Earnings Persistence"
label var turn "Turnover"
label var instown "Inst. Ownership"
label var sue1 "UE"

global controls   ue_dec size_dec btm_dec log_analyst replag volatility persist turn instown ///
	 ue_dec_size_dec ue_dec_btm_dec ue_dec_log_analyst ue_dec_replag ue_dec_volatility ///
	ue_dec_persist	ue_dec_turn ue_dec_instown

global controls_drop   size_dec btm_dec log_analyst replag volatility persist turn instown ///
	 ue_dec_size_dec ue_dec_btm_dec ue_dec_log_analyst ue_dec_replag ue_dec_volatility ///
	ue_dec_persist	ue_dec_turn ue_dec_instown

sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6

capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo a1: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo a2: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo a3: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car85_6
	eststo a7: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car63_4
	eststo a10: reg car3_1 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
	
	
replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo b1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo b2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo b3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo b4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo b5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo b6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo b7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo b8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo b9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
	eststo b10: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
	
	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo c1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo c2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo c3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo c4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo c5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo c6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo c7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo c8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo c9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
replace cust_ind = cust_ind63_4
replace ind  = ind63_4
	eststo c10: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace

esttab a1 a2 a3 a4 a5 a6 a7 a8 a9 a10, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")

esttab b1 b2 b3 b4 b5 b6 b7 b8 b9 b10, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")

esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day" "60 day alt")
	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo aa1: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo aa2: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo aa3: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo aa4: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo aa5: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo aa6: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo aa7: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo aa8: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo aa9: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
	eststo aa10: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
	
replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo bb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo bb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo bb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo bb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo bb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo bb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo bb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo bb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo bb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
	eststo bb10: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo cc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo cc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo cc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo cc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo cc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo cc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo cc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo cc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo cc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car63_4
replace supp_car = car63_4
replace cust_ind = cust_ind63_4
replace ind  = ind63_4
	eststo cc10: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace	
	

esttab aa1 aa2 aa3 aa4 aa5 aa6 aa7 aa8 aa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab bb1 bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

**Table 3 Panel A: 60 trading days which approximates the number of trading days in a quarter;	
esttab a3 b3 c3 aa3 bb3 cc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


esttab a3 b3 c3 aa3 bb3 cc3 using "$drop/Table3PanelA.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
*Robustness
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car ue_dec) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table3PanelB.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car ue_dec) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

*internet Appendix - 63-4
esttab a10 b10 c10 aa10 bb10 cc10 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-63,-4]" supp_car "Abret[-63,-4]" cust_ind "Cust Ind Abret[-63,-4]" ind "Ind Abret [-63,-4]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


esttab a10 b10 c10 aa10 bb10 cc10 using "$drop/Table3PanelA_robust.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls_drop _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-63,-4]" supp_car "Abret[-63,-4]" cust_ind "Cust Ind Abret[-63,-4]" ind "Ind Abret [-63,-4]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
*********	
***SUR***
*********
reg car3_1 cust_sw_car85_6 car85_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car85_6 car85_6 $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car85_6=[j_mean]cust_sw_car85_6 
*cust_ind85_6 ind85_6
*p-value 0.46

reg car3_1 cust_sw_car65_6 car65_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car65_6 car65_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car65_6=[j_mean]cust_sw_car65_6 	
*cust_ind65_6 ind65_6
*p-value: 0.09
	
reg car3_1 cust_sw_car45_6 car45_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car45_6 car45_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car45_6=[j_mean]cust_sw_car45_6 	
*p-value: 0.0577

reg car3_1 cust_sw_car25_6 car25_6  $controls  i.month i.year
eststo i
reg car0_2 cust_sw_car25_6 car25_6  $controls  i.month i.year
eststo j
suest i j, cluster(eadate_crsp)
test [i_mean]cust_sw_car25_6=[j_mean]cust_sw_car25_6 	
*p-value: 0.0806



	
	
*******************************
* Interact with Edgar
*******************************	

label var cust_edgar_all_abn3_1 "Cust Edgar[-3,-1]"

capture drop cust_car supp_car

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo e1: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo e2: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo e3: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo e4: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
	eststo ee1: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo ee2: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo ee3: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo ee4: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

		
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo f1: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo f2: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo f3: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo f4: reg car3_1 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
replace cust_ind = cust_ind25_6
replace ind = ind25_6
	eststo ff1: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo ff2: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo ff3: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo ff4: reg car0_2 c.cust_car##c.cust_edgar_all_abn3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	

esttab e1 e2 e3 e4 ee1 ee2 ee3 ee4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab e1 e2 e3 e4 ee1 ee2 ee3 ee4 using "$drop/Table4_edgar.tex" ,booktabs replace nonotes noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
			
esttab f1 f2 f3 f4 ff1 ff2 ff3 ff4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_edgar_all_abn "Cust Edgar * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
	
*******************************
* Interact with Google
*******************************	


capture drop cust_car supp_car
sum cust_ln_ab_svi3_1 cust_lnsvi3_1, d

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo g1: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo g2: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo g3: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo g4: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
	eststo gg1: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gg2: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gg3: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gg4: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
gen supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo h1: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo h2: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo h3: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo h4: reg car3_1 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace

	
replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
replace cust_ind = cust_ind25_6
replace ind = ind25_6
	eststo hh1: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo hh2: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo hh3: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo hh4: reg car0_2 c.cust_car##c.cust_lnsvi3_1 supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	

	
	
esttab g1 g2 g3 g4 gg1 gg2 gg3 gg4 , noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab h1 h2 h3 h4 hh1 hh2 hh3 hh4 , noobs var(30) label ///
	compress b(%9.3f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car cust_lnsvi3_1  c.cust_car#c.cust_lnsvi3_1 supp_car ue_dec) /// 
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab g1 g2 g3 g4 gg1 gg2 gg3 gg4 using "$drop/Table4_lnsvi.tex" ,booktabs replace nonotes noobs var(30) label ///
	compress b(%9.2f) drop($controls_drop *.year *.month _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(c.cust_car#c.cust_lnsvi3_1 "Cust Google * Cust Abret" cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls \& Interactions") sfmt(%9.0gc %9.3f) /// 
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	
	
	

cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_sorts2, clear

eststo a0: reg _0
eststo a1: reg _1
eststo a2: reg _2
eststo a3: reg _3
eststo a4: reg _4
eststo a5: reg ls


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "CAR[-3,-1]") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))


****CAR[0,2]***
use cust_sorts2a, clear


eststo aa0: reg _0
eststo aa1: reg _1
eststo aa2: reg _2
eststo aa3: reg _3
eststo aa4: reg _4
eststo aa5: reg ls


esttab aa0 aa1 aa2 aa3 aa4 aa5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "CAR[0,2]") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)
 
 
 *****By Cust Returns and Edgar***
 
 use qtrs_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00

esttab Q0_cons2 Q0_cons6 Q0_cons7 blank Q1_cons2 Q1_cons6 Q1_cons7, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 ) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons6 Q0_cons7 Q1_cons2 Q1_cons6 Q1_cons7 using "$drop/double_sorts_v2.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle("Low" "High" "High-Low" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" "Google Search", pattern(1 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 Q0_cons5 Q0_cons6 Q0_cons7, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle( "Search(Low)" "Search2" "Search3" "Search4" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 Q0_cons5 Q0_cons6 Q0_cons7 using "$drop/edgar_sorts.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  ///
	compress mtitle( "Search(Low)" "Search2" "Search3" "Search4" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)

	 
	 
 *****Run this to figure out Stars to add to above table***
 
 use qtrs_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53, se
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54, se
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55, se
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/5{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)
esttab  a03 a13 a23 a33 a43 a53, se
matrix Q5 = r(coefs)
esttab  a04 a14 a24 a34 a44 a54, se
matrix Q6 = r(coefs)
esttab  a05 a15 a25 a35 a45 a55, se
matrix Q7 = r(coefs)

forvalue k = 2/7{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}



cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cf_replication, clear

gen year = year(date)
*drop if year > 2004

eststo a0: reg q1
eststo a1: reg q2
eststo a2: reg q3
eststo a3: reg q4
eststo a4: reg q5
eststo a5: reg ls


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes booktabs transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo aa0: reg q1 mktrf smb hml, robust
eststo aa1: reg q2 mktrf smb hml, robust
eststo aa2: reg q3 mktrf smb hml, robust
eststo aa3: reg q4 mktrf smb hml, robust
eststo aa4: reg q5 mktrf smb hml, robust
eststo aa5: reg ls mktrf smb hml, robust


esttab aa0 aa1 aa2 aa3 aa4 aa5, booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaa0: reg q1 mktrf smb hml umd, robust
eststo aaa1: reg q2 mktrf smb hml umd, robust
eststo aaa2: reg q3 mktrf smb hml umd, robust
eststo aaa3: reg q4 mktrf smb hml umd, robust
eststo aaa4: reg q5 mktrf smb hml umd, robust
eststo aaa5: reg ls mktrf smb hml umd, robust


esttab aaa0 aaa1 aaa2 aaa3 aaa4 aaa5, booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaaa0: reg q1 mktrf smb hml umd ps_vwf, robust
eststo aaaa1: reg q2 mktrf smb hml umd ps_vwf, robust
eststo aaaa2: reg q3 mktrf smb hml umd ps_vwf, robust
eststo aaaa3: reg q4 mktrf smb hml umd ps_vwf, robust
eststo aaaa4: reg q5 mktrf smb hml umd ps_vwf, robust
eststo aaaa5: reg ls mktrf smb hml umd ps_vwf, robust


esttab aaaa0 aaaa1 aaaa2 aaaa3 aaaa4 aaaa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
****
*Save the intercepts as file Table6.tex
****
 
 use cust_sorts_ea2, clear

eststo a0: reg q1_non
eststo a1: reg q2_non
eststo a2: reg q3_non
eststo a3: reg q4_non
eststo a4: reg q5_non
eststo a5: reg ls_non


esttab a0 a1 a2 a3 a4 a5, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes  transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo a0b: reg q1_ea
eststo a1b: reg q2_ea
eststo a2b: reg q3_ea
eststo a3b: reg q4_ea
eststo a4b: reg q5_ea
eststo a5b: reg ls_ea

esttab a0b a1b a2b a3b a4b a5b, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Excess returns") nonotes  transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01) ///
		mgroups("Customer Abret" , pattern(1 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

		
eststo aa0: reg q1_non mktrf smb hml, robust
eststo aa1: reg q2_non mktrf smb hml, robust
eststo aa2: reg q3_non mktrf smb hml, robust
eststo aa3: reg q4_non mktrf smb hml, robust
eststo aa4: reg q5_non mktrf smb hml, robust
eststo aa5: reg ls_non mktrf smb hml, robust

esttab aa0 aa1 aa2 aa3 aa4 aa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aa0b: reg q1_ea mktrf smb hml, robust
eststo aa1b: reg q2_ea mktrf smb hml, robust
eststo aa2b: reg q3_ea mktrf smb hml, robust
eststo aa3b: reg q4_ea mktrf smb hml, robust
eststo aa4b: reg q5_ea mktrf smb hml, robust
eststo aa5b: reg ls_ea mktrf smb hml, robust

esttab aa0b aa1b aa2b aa3b aa4b aa5b, noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Three-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
**********
*4-factor
**********		
eststo aaa0: reg q1_non mktrf smb hml umd, robust
eststo aaa1: reg q2_non mktrf smb hml umd, robust
eststo aaa2: reg q3_non mktrf smb hml umd, robust
eststo aaa3: reg q4_non mktrf smb hml umd, robust
eststo aaa4: reg q5_non mktrf smb hml umd, robust
eststo aaa5: reg ls_non mktrf smb hml umd, robust


esttab aaa0 aaa1 aaa2 aaa3 aaa4 aaa5,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaa0b: reg q1_ea mktrf smb hml umd, robust
eststo aaa1b: reg q2_ea mktrf smb hml umd, robust
eststo aaa2b: reg q3_ea mktrf smb hml umd, robust
eststo aaa3b: reg q4_ea mktrf smb hml umd, robust
eststo aaa4b: reg q5_ea mktrf smb hml umd, robust
eststo aaa5b: reg ls_ea mktrf smb hml umd, robust


esttab aaa0b aaa1b aaa2b aaa3b aaa4b aaa5b,  noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Four-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

**********
*5-factor
**********	

eststo aaaa0: reg q1_non mktrf smb hml umd ps_vwf, robust
eststo aaaa1: reg q2_non mktrf smb hml umd ps_vwf, robust
eststo aaaa2: reg q3_non mktrf smb hml umd ps_vwf, robust
eststo aaaa3: reg q4_non mktrf smb hml umd ps_vwf, robust
eststo aaaa4: reg q5_non mktrf smb hml umd ps_vwf, robust
eststo aaaa5: reg ls_non mktrf smb hml umd ps_vwf, robust


esttab aaaa0 aaaa1 aaaa2 aaaa3 aaaa4 aaaa5, keep(_cons) booktabs noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

eststo aaaa0b: reg q1_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa1b: reg q2_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa2b: reg q3_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa3b: reg q4_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa4b: reg q5_ea mktrf smb hml umd ps_vwf, robust
eststo aaaa5b: reg ls_ea mktrf smb hml umd ps_vwf, robust


esttab aaaa0b aaaa1b aaaa2b aaaa3b aaaa4b aaaa5b, booktabs keep(_cons) noobs nonumb mtitle("Q1 (Low)" "Q2" "Q3" "Q4" "Q5 (High)" "High-Low") ///
		coeflabel(_cons "Five-factor alpha") nonotes transform(@*100 100)  star(* 0.1 ** 0.05 *** 0.01)

		
reg double_	mktrf smb hml umd ps_vwf, robust	
****
*Save the intercepts as file 
****


 *****By Cust Returns and Edgar***
 
 use qtrs5_2_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}
/*
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' mktrf smb hml, robust
}
}
*/
esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)


forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs5_2_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}
/*
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' mktrf smb hml umd, robust
}
}
*/
esttab  a00 a10 a20 a30 a40 a50
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52
matrix Q4 = r(coefs)

forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00

esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4 using "$drop/Table6_double_sorts.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100) ///
	 mgroups("Edgar Search" "" "Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
esttab Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) title("SVI")  ///
	compress mtitle( "Search(Low)" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) title("Edgar")  ///
	compress mtitle( "Search(Low)" "Search(High)" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100)
	 

	 
	 
 *Run this to figure out stars
 
 use qtrs5_2_Edgar, clear
 
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)


forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q0`name'`k'
  }
}
**********************
 use qtrs5_2_SVI, clear
 ********************
 *i increments the rows (customer returns)
*j increments the columns (customer search)
forvalue i = 0/5{
forvalue j = 0/2{
qui: eststo a`i'`j': reg c`i'`j' 
}
}


esttab  a00 a10 a20 a30 a40 a50, se
matrix Q2 = r(coefs)
esttab  a01 a11 a21 a31 a41 a51, se
matrix Q3 = r(coefs)
esttab  a02 a12 a22 a32 a42 a52, se
matrix Q4 = r(coefs)

forvalue k = 2/4{
local rnames : rownames Q`k'
local models  CustAbret(Low) CustAbretQ2 CustAbretQ3 CustAbretQ4 CustAbret(High) High-Low
local i 0

foreach name of local rnames {
      local ++i
      local j 0
      capture matrix drop b
      capture matrix drop se
      foreach model of local models {
          local ++j
          matrix tmp = Q`k'[`i', 3*`j'-2]
          if tmp[1,1]<. {
           matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = Q`k'[`i', 3*`j'-1]
              matrix se = nullmat(se), tmp
        }
     }
      ereturn post b
      quietly estadd matrix se
      eststo Q1`name'`k'
  }
}
eststo blank: reg c00


esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4, var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f)  drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100) ///
	 mgroups("Edgar Search" """Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 
esttab Q0_cons2 Q0_cons3 Q0_cons4 blank Q1_cons2 Q1_cons3 Q1_cons4 using "$drop/Table6_double_sorts_stars.tex", replace booktabs var(25) nonotes ///
	nonumb se mtitle noobs b(%9.3f) drop(_cons) ///
	compress mtitle("Low" "High" "High-Low" "" "Low" "High" "High-Low") ///
	 star(* 0.10 ** 0.05 *** 0.01) transform(@*100 100) ///
	 mgroups("Edgar Search" "" "Google Search", pattern(1 0 0 1 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	 	 
		 
cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"


global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_qea_pseudo3, clear

gen month = month(date_pseudo)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

*drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .
drop if cust_sw_car65_6 == .
drop if car65_6 == .

label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"

	
global controls  size_dec btm_dec log_analyst  volatility persist turn instown 
	
	
sum $controls 
sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6



*Pre-announcement returns
	
	
capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo a1: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo a2: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo a3: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo a4: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo a5: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo a6: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo a7: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo a8: reg car3_1 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo a9: reg car3_1 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo b1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo b2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo b3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo b4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo b5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo b6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo b7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo b8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo b9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo c1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo c2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo c3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo c4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo c5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo c6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo c7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo c8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo c9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace


esttab a1 a2 a3 a4 a5 a6 a7 a8 a9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab b1 b2 b3 b4 b5 b6 b7 b8 b9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab c1 c2 c3 c4 c5 c6 c7 c8 c9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
	
	
	
*Announcement Returns


capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo aa1: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo aa2: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo aa3: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo aa4: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo aa5: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo aa6: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo aa7: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo aa8: reg car0_2 cust_car , cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo aa9: reg car0_2 cust_car, cluster(eadate_crsp)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo bb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo bb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo bb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo bb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo bb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo bb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo bb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo bb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo bb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo cc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo cc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo cc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo cc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo cc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo cc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo cc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo cc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo cc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(eadate_crsp)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
	
	

esttab aa1 aa2 aa3 aa4 aa5 aa6 aa7 aa8 aa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab bb1 bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

esttab a1 b1 c1 aa1 bb1 cc1, replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-25,-6]" supp_car "Abret[-25,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-25,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab a3 b3 c3 aa3 bb3 cc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
**Table 7 : Going with 60 trading days which approximates the number of trading days in a quarter;	
** Guidance regressions estimated in file "cust QEA guidance.do"

esttab c3 cc3 gc3 gcc3 , replace nonotes noobs label var(25)  ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Pseudo Events" "Guidance" , pattern(1 0 1  0)span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	mtitle("CAR[-3,-1]" "CAR[0,2]" "CAR[-3,-1]" "CAR[0,2]")  

esttab c3 cc3 gc3 gcc3 using "$drop/Table7.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Pseudo Events" "Guidance" , pattern(1 0 1  0)span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	mtitle("CAR[-3,-1]" "CAR[0,2]" "CAR[-3,-1]" "CAR[0,2]")  
	
	

*Robustness
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

/*
esttab a3 b3 c3 aa3 bb3 cc3 using "$drop/Table7PanelA.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-65,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table7PanelA_robust.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	

cd "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"
cd "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Stata Round 3"


global drop "E:\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"
global drop "C:\Users\jmmadsen\Dropbox\Research Projects\Dissertation\JAR Revisions\Tables"

use cust_qea_guidance, clear

gen month = month(anndate)
gen year = year(anndate)

replace car3_1 = car3_1 * 100 if car3_1 ~= .
replace car0_2 = car0_2 * 100 if car0_2 ~= .

drop if ind65_6 == .
drop if cust_ind65_6 == .
drop if car65_6 == .
drop if cust_sw_car65_6 == .

*drop if ue_dec == .
drop if volatility == .
drop if instown == .
drop if btm_dec == .
drop if turn == .


label var cust_sw_car25_6 "Cust Abret[-25,-6]"
label var car3_1 "CAR[-3,-1]"
label var car0_2 "CAR[0,2]"
label var ind25_6 "Ind Abret[-25,-6]"
label var cust_ind25_6 "Cust Ind Abret[-25,-6]"
label var car25_6 "Abret[-25,-6]"
label var cust_lnsvi3_1 "Cust Google[-3,-1]"

	
global controls  size_dec btm_dec log_analyst  volatility persist turn instown 

sum $controls	
sum car25_6 car45_6 car65_6 car70_6
sum cust_sw_car25_6 cust_sw_car45_6 cust_sw_car65_6 cust_sw_car70_6

	
*Pre-announcement returns
	
	
capture  drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo ga1: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo ga2: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo ga3: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo ga4: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo ga5: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo ga6: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo ga7: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo ga8: reg car3_1 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo ga9: reg car3_1 cust_car, cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo gb1: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gb2: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gb3: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo gb4: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo gb5: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo gb6: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gb7: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo gb8: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo gb9: reg car3_1 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo gc1: reg car3_1 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo gc2: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo gc3: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo gc4: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo gc5: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo gc6: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo gc7: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo gc8: reg car3_1 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo gc9: reg car3_1 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace


esttab ga1 ga2 ga3 ga4 ga5 ga6 ga7 ga8 ga9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gb1 gb2 gb3 gb4 gb5 gb6 gb7 gb8 gb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gc1 gc2 gc3 gc4 gc5 gc6 gc7 gc8 gc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "40 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
	
	
	
*Announcement Returns


capture drop cust_car supp_car cust_ind ind

gen cust_car = cust_sw_car25_6
	eststo gaa1: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
	eststo gaa2: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
	eststo gaa3: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
	eststo gaa4: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car75_6
	eststo gaa5: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
	eststo gaa6: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
	eststo gaa7: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
	eststo gaa8: reg car0_2 cust_car , cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
	eststo gaa9: reg car0_2 cust_car, cluster(anndate)
	qui: estadd local controls "No", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
gen supp_car = car25_6
	eststo gbb1: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
	eststo gbb2: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
	eststo gbb3: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
	eststo gbb4: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace	
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
	eststo gbb5: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
	eststo gbb6: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
	eststo gbb7: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
	eststo gbb8: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
	eststo gbb9: reg car0_2 cust_car supp_car $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "No", replace

replace cust_car = cust_sw_car25_6
replace supp_car = car25_6
gen cust_ind = cust_ind25_6
gen ind = ind25_6
	eststo gcc1: reg car0_2 cust_car supp_car cust_ind ind $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car45_6
replace supp_car = car45_6
replace cust_ind = cust_ind45_6
replace ind = ind45_6
	eststo gcc2: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car65_6
replace supp_car = car65_6
replace cust_ind = cust_ind65_6
replace ind = ind65_6
	eststo gcc3: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car70_6
replace supp_car = car70_6
replace cust_ind = cust_ind70_6
replace ind = ind70_6
	eststo gcc4: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car75_6
replace supp_car = car75_6
replace cust_ind = cust_ind75_6
replace ind = ind75_6
	eststo gcc5: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car80_6
replace supp_car = car80_6
replace cust_ind = cust_ind80_6
replace ind = ind80_6
	eststo gcc6: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car85_6
replace supp_car = car85_6
replace cust_ind = cust_ind85_6
replace ind = ind85_6
	eststo gcc7: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car90_6
replace supp_car = car90_6
replace cust_ind = cust_ind90_6
replace ind = ind90_6
	eststo gcc8: reg car0_2 cust_car supp_car cust_ind ind  $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
replace cust_car = cust_sw_car95_6
replace supp_car = car95_6
replace cust_ind = cust_ind95_6
replace ind  = ind95_6
	eststo gcc9: reg car0_2 cust_car supp_car cust_ind ind   $controls  i.month i.year, cluster(anndate)
	qui: estadd local controls "Yes", replace
	qui: estadd local ind "Yes", replace
	
	

esttab gaa1 gaa2 gaa3 gaa4 gaa5 gaa6 gaa7 gaa8 gaa9, noobs var(25) ///
	compress b(%9.3f) drop( _cons) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gbb1 gbb2 gbb3 gbb4 gbb5 gbb6 gbb7 gbb8 gbb9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f)  ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")

esttab gcc1 gcc2 gcc3 gcc4 gcc5 gcc6 gcc7 gcc8 gcc9, noobs var(25) ///
	compress b(%9.3f) drop(*.month *.year _cons $controls) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car) ///
	scalar(N "r2_a Adj R-Squared" "controls Controls" "ind Industry Ret") sfmt(%9.0gc %9.3f) ///
	mtitle("20 day" "60 day" "65 day" "70 day" "75 day" "80 day" "85 day" "90 day")
		
/*
1- 20 day
2- 40 day
3- 60 day
4- 65 day
5- 70 day
6- 75 day
7- 80 day
8- 85 day
9- 90 day
*/

**Table XXX Panel A: Going with 60 trading days which approximates the number of trading days in a quarter;	
esttab ga3 gb3 gc3 gaa3 gbb3 gcc3 , replace nonotes noobs label var(25) nomtitle ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

***Tabulated as part of CUST QEA Pseudo.do file*****

	
*Robustness
esttab gc1 gc2 gc3 gc7  gcc1 gcc2 gcc3 gcc7, replace nonotes noobs label var(25) nonumb ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	order(cust_car supp_car) ///
	coeflabel(cust_car "Cust Abret" supp_car "Abret" cust_ind "Cust Ind Abret" ind "Ind Abret") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

/*

esttab ga3 gb3 gc3 gaa3 gbb3 gcc3 using "$drop/Table7PanelB.tex", nomtitle booktabs replace nonotes noobs label var(25) ///
	compress b(%9.3f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[-65,-6]" supp_car "Abret[-65,-6]" cust_ind "Cust Ind Abret[-25,-6]" ind "Ind Abret [-65,-6]") ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f) ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 1  0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))

	
esttab c1 c2 c3 c7  cc1 cc2 cc3 cc7 using "$drop/Table7PanelA_robust.tex", booktabs replace nonotes noobs label var(25)  ///
	compress b(%9.2f) drop($controls _cons *.year *.month) star(* 0.1 ** 0.05 *** 0.01) ///
	coeflabel(cust_car "Cust Abret[x,y]" supp_car "Abret[x,y]" cust_ind "Cust Ind Abret[x,y]" ind "Ind Abret[x,y]") ///
	order(cust_car supp_car) ///
	scalar("N Observations" "r2_a Adj R-Squared" "controls Controls") sfmt(%9.0gc %9.3f)  ///
	mtitle("[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]" "[-25,-6]" "[-45,-6]" "[-65,-6]" "[-85,-6]") ///
	mgroups("Dep Var = CAR[-3,-1]" "Dep Var = CAR[0,3]" , pattern(1 0 0 0 1 0 0 0)span prefix(\multicolumn{@span}{c}{) suffix(}))
	

