**********************************************************************************************************************************

**** This STATA do-file is used to conduct statistical analyses and generate the following figures and tables.  

*    reg1_main.dta:           Figure 1, Table 2, Table 3(Panel A), Table 4, Table 5, Table 7(Column 4), Table 8-10, Table A1
*    reg2_match_TA.dta:       Table 7(Column 1)  
*    reg3_match_TA_ROA.dta:   Table 7(Column 2) 
*    reg4_match_PSM.dta:      Table 7(Column 3)
*    reg5_placebo.dta:        Table 6(Panel A)  
*    reg6_falsify.dta:        Table 3(Panel B), Table 6(Panel B) 

*    Note: 1. These .dta datasets are obtained by running the SAS_code_submit program.
*          2. Results in Table 1 can be obtained by running the SAS_code_submit program.

**********************************************************************************************************************************

set linesize 255
cd "E:\projects\richlist"
use "E:\projects\richlist\reg1_main.dta", clear 

keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2) 
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage bign nonlocal)
drop if miss>=1
count

*winsorize
foreach x of varlist ///
 logdcost quick arinv current turnover lev roa logta logage ///
 lognews_neg lognews_pos tobinq dacc noa {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}

*Figure 1 The distribution of treatment firms
*Panel A: By event year
ta year if rich==1 & ryear==0

*Panel B: By industry
ta indd if ryear==0
ta indd

*Table2 Descriptive statistics for variables
eststo clear
estpost tabstat op logdcost quick arinv current turnover lev roa loss logta logage bign nonlocal lagop ///
 , stats(n mean sd p25 median p75) c(s) 
esttab, cell("count mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3))  p75(fmt(3))") unstack compress noobs nonumber ///
coeflabels(op "AO" logdcost "Ln(Fee)" lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" ///
lev "Leverage" roa "ROA" loss "Loss" logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table3 Rich listing and changes in firms¡¯ press coverage
*Table3 Panel A: Rich listing for the top-200 billionaires and changes in firms¡¯ press coverage
eststo clear 
eststo: quietly xi:xtreg lognews_neg list logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos list logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2) coeflabels(list "Rich[T,T+2]" lev "Leverage" roa "ROA" tobinq "Tobin's Q")

*Table4 Univariate analysis for the treatment firms
ttable2 op logdcost quick arinv current turnover lev roa loss logta logage bign nonlocal lagop ///
 if rich==1, by(list)
 
*Table5 Multivariate regression analysis
eststo clear
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table8 Analysis of differential auditor responses by client circumstances
*Table8 Panel A: The acquisition of state assets 
gen k1=0
replace k1=1 if list==1 & acqsoe==1
gen k2=0
replace k2=1 if list==1 & acqsoe==0
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Acquirers" k2 "Rich[T,T+2]*Industrialists")

*Table8 Panel B: Tax aggressiveness
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & taxavoider==1
gen k2=0
replace k2=1 if list==1 & taxavoider==0 
gen k3=1 if rich==1 & taxavoider==.
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Tax-avoiders" k2 "Rich[T,T+2]*Non-avoiders")

*Table8 Panel C: Reporting transparency
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & opaque==1
gen k2=0
replace k2=1 if list==1 & opaque==0 
gen k3=1 if rich==1 & opaque==.
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Opaque" k2 "Rich[T,T+2]*Transparent")

*Table8 Panel D: Regional corruptness
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & qcorrupt<=2
gen k2=0
replace k2=1 if list==1 & qcorrupt>2
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Corrput Regions" k2 "Rich[T,T+2]*Clean Regions")

*Table9 Analysis of differential auditor responses by auditor characteristics
*Table9 Panel A: Audit-firm size
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & audrank<=10 
gen k2=0
replace k2=1 if list==1 & audrank>10
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Top 10" k2 "Rich[T,T+2]*Non-Top 10")

*Table9 Panel B: Engagement auditors¡¯ reporting styles
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & sensitive==1
gen k2=0
replace k2=1 if list==1 & sensitive==0
gen k3=0
replace k3=1 if list==1 & sensitive==. 
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Sensitive" k2 "Rich[T,T+2]*Tolerant")

*Table10 Further analyses of the impacts of rich listing
*Table10 Panel A: Controlling for clients¡¯ financial-reporting strategy
eststo clear
eststo: quietly xi:xtreg op lagop list dacc quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list dacc quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(list dacc) coeflabels(list "Rich[T,T+2]" dacc "DAC")

*Table10 Panel B: Controlling for clients¡¯ financial-reporting strategy during the post-listing period
gen dacc_list=dacc*list
eststo clear
eststo: quietly xi:xtreg op lagop list dacc dacc_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list dacc dacc_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(list dacc dacc_list) coeflabels(list "Rich[T,T+2]" dacc "DAC" dacc_list "Rich[T,T+2]¡ÁDAC")

*Table10 Panel C: Possible benefits of the rich listing
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & benefit==1 
gen k2=0
replace k2=1 if list==1 & benefit==0
gen k3=0
replace k3=1 if rich==1 & benefit==.
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Benefied" k2 "Rich[T,T+2]*Suffered")

*Table10 Panel D: Public views about the billionaires
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & hero==1 
gen k2=0
replace k2=1 if list==1 & hero==0
gen k3=0
replace k3=1 if rich==1 & hero==.
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Heroes" k2 "Rich[T,T+2]*Villains")

*********************************************************
*Table7 Tests based on other designs
*Table7 column (1) exact matching by client size
use "E:\projects\richlist\reg2_match_TA.dta", clear 
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column (2) exact matching by client size and ROA
use "E:\projects\richlist\reg3_match_TA_ROA.dta", clear 
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column (3) PSM
use "E:\projects\richlist\reg4_match_PSM.dta", clear
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column(4) Treatment-only sample
use "E:\projects\richlist\reg1_main.dta", clear
keep if rich==1 & ryear>=-3 & ryear<=2
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if rich==1,robust cl(code)
eststo: quietly xi:reg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if rich==1,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) pr2(3) ar2(3) title() nocons compress nogap ///
keep(list) coeflabels(list "Post")

*Table6 Placebo and falsification tests
*Table6 Panel A: Placebo test based on randomly created rich-listing events
use "E:\projects\richlist\reg5_placebo.dta", clear 
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2) 
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage bign nonlocal)
drop if miss>=1
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table6 Panel B: Falsification test based on billionaires that are first ranked between 201 and 600 and are never ranked within top 200 on the Rich List
use "E:\projects\richlist\reg6_falsify.dta", clear 
count
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2)
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage)
drop if miss>=1
count
*winsorize
foreach x of varlist ///
 logdcost quick arinv current turnover lev roa logta logage ///
 lognews_neg lognews_pos tobinq {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}

eststo clear 
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table3 Rich listing and changes in firms¡¯ press coverage
*Table3 Panel B: Rich listing for non-top 200 billionaires and changes in firms¡¯ press coverage
count if ryear==0 & (firstrank>200 & firstrank<=600) //89 rich firms
eststo clear
*201-400
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>200 & firstrank<=400),robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>200 & firstrank<=400),robust fe i(code) cl(code)
*401-600
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>400 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>400 & firstrank<=600),robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
coeflabels(logta "Ln(TAST)" lev "Leverage" roa "ROA" tobinq "Tobin's Q")

*Appendix 
*Table A1 Analysis of regulatory risks
use "E:\projects\richlist\reg1_main.dta", clear 
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>5)
egen miss=rmiss(sanction list logta lev roa st soe noa loss tobinq)
drop if miss>=1
count
*winsorize
foreach x of varlist logta lev roa noa tobinq {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
drop if rich==1 & ryear==0 

eststo clear 
eststo: quietly xi:xtreg sanction list logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg sanction pre2 pre1 post1 post2 post3 post4 post5 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post1 post2 post3 post4 post5 logta lev roa loss tobinq st noa soe) ///
coeflabels(list "Rich[T+1,T+5]" logta "Ln(TAST)" lev "Leverage" roa "ROA" loss "Loss" tobinq "Tobin's Q" ///
st "ST" noa "NOA" soe "SOE")

*A: The acquisition of state assets 
gen k1=0
replace k1=1 if list==1 & acqsoe==1
gen k2=0
replace k2=1 if list==1 & acqsoe==0
eststo clear
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Acquirers" k2 "Rich[T,T+2]*Industrialists")

*B: Tax aggressiveness
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & taxavoider==1
gen k2=0
replace k2=1 if list==1 & taxavoider==0 
gen k3=1 if rich==1 & taxavoider==.
eststo clear
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Tax-avoiders" k2 "Rich[T,T+2]*Non-avoiders")

*C: Reporting transparency
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & opaque==1
gen k2=0
replace k2=1 if list==1 & opaque==0 
gen k3=1 if rich==1 & opaque==.
eststo clear 
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Opaque" k2 "Rich[T,T+2]*Transparent")

*D: Regional corruptness
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & qcorrupt<=2
gen k2=0
replace k2=1 if list==1 & qcorrupt>2
eststo clear 
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Corrput Regions" k2 "Rich[T,T+2]*Clean Regions")








**********************************************************************************************************************************

**** This STATA do-file is used to conduct statistical analyses and generate the following figures and tables.  

*    reg1_main.dta:           Figure 1, Table 2, Table 3(Panel A), Table 4, Table 5, Table 7(Column 4), Table 8-10, Table A1
*    reg2_match_TA.dta:       Table 7(Column 1)  
*    reg3_match_TA_ROA.dta:   Table 7(Column 2) 
*    reg4_match_PSM.dta:      Table 7(Column 3)
*    reg5_placebo.dta:        Table 6(Panel A)  
*    reg6_falsify.dta:        Table 3(Panel B), Table 6(Panel B) 

*    Note: 1. These .dta datasets are obtained by running the SAS_code_submit program.
*          2. Results in Table 1 can be obtained by running the SAS_code_submit program.

**********************************************************************************************************************************

set linesize 255
cd "E:\projects\richlist"
use "E:\projects\richlist\reg1_main.dta", clear 

keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2) 
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage bign nonlocal)
drop if miss>=1
count

*winsorize
foreach x of varlist ///
 logdcost quick arinv current turnover lev roa logta logage ///
 lognews_neg lognews_pos tobinq dacc noa {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}

*Figure 1 The distribution of treatment firms
*Panel A: By event year
ta year if rich==1 & ryear==0

*Panel B: By industry
ta indd if ryear==0
ta indd

*Table2 Descriptive statistics for variables
eststo clear
estpost tabstat op logdcost quick arinv current turnover lev roa loss logta logage bign nonlocal lagop ///
 , stats(n mean sd p25 median p75) c(s) 
esttab, cell("count mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3))  p75(fmt(3))") unstack compress noobs nonumber ///
coeflabels(op "AO" logdcost "Ln(Fee)" lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" ///
lev "Leverage" roa "ROA" loss "Loss" logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table3 Rich listing and changes in firms¡¯ press coverage
*Table3 Panel A: Rich listing for the top-200 billionaires and changes in firms¡¯ press coverage
eststo clear 
eststo: quietly xi:xtreg lognews_neg list logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos list logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2) coeflabels(list "Rich[T,T+2]" lev "Leverage" roa "ROA" tobinq "Tobin's Q")

*Table4 Univariate analysis for the treatment firms
ttable2 op logdcost quick arinv current turnover lev roa loss logta logage bign nonlocal lagop ///
 if rich==1, by(list)
 
*Table5 Multivariate regression analysis
eststo clear
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table8 Analysis of differential auditor responses by client circumstances
*Table8 Panel A: The acquisition of state assets 
gen k1=0
replace k1=1 if list==1 & acqsoe==1
gen k2=0
replace k2=1 if list==1 & acqsoe==0
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Acquirers" k2 "Rich[T,T+2]*Industrialists")

*Table8 Panel B: Tax aggressiveness
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & taxavoider==1
gen k2=0
replace k2=1 if list==1 & taxavoider==0 
gen k3=1 if rich==1 & taxavoider==.
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Tax-avoiders" k2 "Rich[T,T+2]*Non-avoiders")

*Table8 Panel C: Reporting transparency
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & opaque==1
gen k2=0
replace k2=1 if list==1 & opaque==0 
gen k3=1 if rich==1 & opaque==.
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Opaque" k2 "Rich[T,T+2]*Transparent")

*Table8 Panel D: Regional corruptness
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & qcorrupt<=2
gen k2=0
replace k2=1 if list==1 & qcorrupt>2
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Corrput Regions" k2 "Rich[T,T+2]*Clean Regions")

*Table9 Analysis of differential auditor responses by auditor characteristics
*Table9 Panel A: Audit-firm size
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & audrank<=10 
gen k2=0
replace k2=1 if list==1 & audrank>10
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Top 10" k2 "Rich[T,T+2]*Non-Top 10")

*Table9 Panel B: Engagement auditors¡¯ reporting styles
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & sensitive==1
gen k2=0
replace k2=1 if list==1 & sensitive==0
gen k3=0
replace k3=1 if list==1 & sensitive==. 
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Sensitive" k2 "Rich[T,T+2]*Tolerant")

*Table10 Further analyses of the impacts of rich listing
*Table10 Panel A: Controlling for clients¡¯ financial-reporting strategy
eststo clear
eststo: quietly xi:xtreg op lagop list dacc quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list dacc quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(list dacc) coeflabels(list "Rich[T,T+2]" dacc "DAC")

*Table10 Panel B: Controlling for clients¡¯ financial-reporting strategy during the post-listing period
gen dacc_list=dacc*list
eststo clear
eststo: quietly xi:xtreg op lagop list dacc dacc_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list dacc dacc_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(list dacc dacc_list) coeflabels(list "Rich[T,T+2]" dacc "DAC" dacc_list "Rich[T,T+2]¡ÁDAC")

*Table10 Panel C: Possible benefits of the rich listing
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & benefit==1 
gen k2=0
replace k2=1 if list==1 & benefit==0
gen k3=0
replace k3=1 if rich==1 & benefit==.
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Benefied" k2 "Rich[T,T+2]*Suffered")

*Table10 Panel D: Public views about the billionaires
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & hero==1 
gen k2=0
replace k2=1 if list==1 & hero==0
gen k3=0
replace k3=1 if rich==1 & hero==.
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Heroes" k2 "Rich[T,T+2]*Villains")

*********************************************************
*Table7 Tests based on other designs
*Table7 column (1) exact matching by client size
use "E:\projects\richlist\reg2_match_TA.dta", clear 
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column (2) exact matching by client size and ROA
use "E:\projects\richlist\reg3_match_TA_ROA.dta", clear 
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column (3) PSM
use "E:\projects\richlist\reg4_match_PSM.dta", clear
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column(4) Treatment-only sample
use "E:\projects\richlist\reg1_main.dta", clear
keep if rich==1 & ryear>=-3 & ryear<=2
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if rich==1,robust cl(code)
eststo: quietly xi:reg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if rich==1,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) pr2(3) ar2(3) title() nocons compress nogap ///
keep(list) coeflabels(list "Post")

*Table6 Placebo and falsification tests
*Table6 Panel A: Placebo test based on randomly created rich-listing events
use "E:\projects\richlist\reg5_placebo.dta", clear 
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2) 
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage bign nonlocal)
drop if miss>=1
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table6 Panel B: Falsification test based on billionaires that are first ranked between 201 and 600 and are never ranked within top 200 on the Rich List
use "E:\projects\richlist\reg6_falsify.dta", clear 
count
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2)
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage)
drop if miss>=1
count
*winsorize
foreach x of varlist ///
 logdcost quick arinv current turnover lev roa logta logage ///
 lognews_neg lognews_pos tobinq {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}

eststo clear 
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table3 Rich listing and changes in firms¡¯ press coverage
*Table3 Panel B: Rich listing for non-top 200 billionaires and changes in firms¡¯ press coverage
count if ryear==0 & (firstrank>200 & firstrank<=600) //89 rich firms
eststo clear
*201-400
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>200 & firstrank<=400),robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>200 & firstrank<=400),robust fe i(code) cl(code)
*401-600
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>400 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>400 & firstrank<=600),robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
coeflabels(logta "Ln(TAST)" lev "Leverage" roa "ROA" tobinq "Tobin's Q")

*Appendix 
*Table A1 Analysis of regulatory risks
use "E:\projects\richlist\reg1_main.dta", clear 
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>5)
egen miss=rmiss(sanction list logta lev roa st soe noa loss tobinq)
drop if miss>=1
count
*winsorize
foreach x of varlist logta lev roa noa tobinq {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
drop if rich==1 & ryear==0 

eststo clear 
eststo: quietly xi:xtreg sanction list logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg sanction pre2 pre1 post1 post2 post3 post4 post5 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post1 post2 post3 post4 post5 logta lev roa loss tobinq st noa soe) ///
coeflabels(list "Rich[T+1,T+5]" logta "Ln(TAST)" lev "Leverage" roa "ROA" loss "Loss" tobinq "Tobin's Q" ///
st "ST" noa "NOA" soe "SOE")

*A: The acquisition of state assets 
gen k1=0
replace k1=1 if list==1 & acqsoe==1
gen k2=0
replace k2=1 if list==1 & acqsoe==0
eststo clear
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Acquirers" k2 "Rich[T,T+2]*Industrialists")

*B: Tax aggressiveness
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & taxavoider==1
gen k2=0
replace k2=1 if list==1 & taxavoider==0 
gen k3=1 if rich==1 & taxavoider==.
eststo clear
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Tax-avoiders" k2 "Rich[T,T+2]*Non-avoiders")

*C: Reporting transparency
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & opaque==1
gen k2=0
replace k2=1 if list==1 & opaque==0 
gen k3=1 if rich==1 & opaque==.
eststo clear 
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Opaque" k2 "Rich[T,T+2]*Transparent")

*D: Regional corruptness
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & qcorrupt<=2
gen k2=0
replace k2=1 if list==1 & qcorrupt>2
eststo clear 
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Corrput Regions" k2 "Rich[T,T+2]*Clean Regions")








**********************************************************************************************************************************

**** This STATA do-file is used to conduct statistical analyses and generate the following figures and tables.  

*    reg1_main.dta:           Figure 1, Table 2, Table 3(Panel A), Table 4, Table 5, Table 7(Column 4), Table 8-10, Table A1
*    reg2_match_TA.dta:       Table 7(Column 1)  
*    reg3_match_TA_ROA.dta:   Table 7(Column 2) 
*    reg4_match_PSM.dta:      Table 7(Column 3)
*    reg5_placebo.dta:        Table 6(Panel A)  
*    reg6_falsify.dta:        Table 3(Panel B), Table 6(Panel B) 

*    Note: 1. These .dta datasets are obtained by running the SAS_code_submit program.
*          2. Results in Table 1 can be obtained by running the SAS_code_submit program.

**********************************************************************************************************************************

set linesize 255
cd "E:\projects\richlist"
use "E:\projects\richlist\reg1_main.dta", clear 

keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2) 
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage bign nonlocal)
drop if miss>=1
count

*winsorize
foreach x of varlist ///
 logdcost quick arinv current turnover lev roa logta logage ///
 lognews_neg lognews_pos tobinq dacc noa {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}

*Figure 1 The distribution of treatment firms
*Panel A: By event year
ta year if rich==1 & ryear==0

*Panel B: By industry
ta indd if ryear==0
ta indd

*Table2 Descriptive statistics for variables
eststo clear
estpost tabstat op logdcost quick arinv current turnover lev roa loss logta logage bign nonlocal lagop ///
 , stats(n mean sd p25 median p75) c(s) 
esttab, cell("count mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3))  p75(fmt(3))") unstack compress noobs nonumber ///
coeflabels(op "AO" logdcost "Ln(Fee)" lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" ///
lev "Leverage" roa "ROA" loss "Loss" logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table3 Rich listing and changes in firms¡¯ press coverage
*Table3 Panel A: Rich listing for the top-200 billionaires and changes in firms¡¯ press coverage
eststo clear 
eststo: quietly xi:xtreg lognews_neg list logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos list logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2) coeflabels(list "Rich[T,T+2]" lev "Leverage" roa "ROA" tobinq "Tobin's Q")

*Table4 Univariate analysis for the treatment firms
ttable2 op logdcost quick arinv current turnover lev roa loss logta logage bign nonlocal lagop ///
 if rich==1, by(list)
 
*Table5 Multivariate regression analysis
eststo clear
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table8 Analysis of differential auditor responses by client circumstances
*Table8 Panel A: The acquisition of state assets 
gen k1=0
replace k1=1 if list==1 & acqsoe==1
gen k2=0
replace k2=1 if list==1 & acqsoe==0
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Acquirers" k2 "Rich[T,T+2]*Industrialists")

*Table8 Panel B: Tax aggressiveness
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & taxavoider==1
gen k2=0
replace k2=1 if list==1 & taxavoider==0 
gen k3=1 if rich==1 & taxavoider==.
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Tax-avoiders" k2 "Rich[T,T+2]*Non-avoiders")

*Table8 Panel C: Reporting transparency
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & opaque==1
gen k2=0
replace k2=1 if list==1 & opaque==0 
gen k3=1 if rich==1 & opaque==.
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Opaque" k2 "Rich[T,T+2]*Transparent")

*Table8 Panel D: Regional corruptness
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & qcorrupt<=2
gen k2=0
replace k2=1 if list==1 & qcorrupt>2
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Corrput Regions" k2 "Rich[T,T+2]*Clean Regions")

*Table9 Analysis of differential auditor responses by auditor characteristics
*Table9 Panel A: Audit-firm size
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & audrank<=10 
gen k2=0
replace k2=1 if list==1 & audrank>10
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Top 10" k2 "Rich[T,T+2]*Non-Top 10")

*Table9 Panel B: Engagement auditors¡¯ reporting styles
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & sensitive==1
gen k2=0
replace k2=1 if list==1 & sensitive==0
gen k3=0
replace k3=1 if list==1 & sensitive==. 
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Sensitive" k2 "Rich[T,T+2]*Tolerant")

*Table10 Further analyses of the impacts of rich listing
*Table10 Panel A: Controlling for clients¡¯ financial-reporting strategy
eststo clear
eststo: quietly xi:xtreg op lagop list dacc quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list dacc quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(list dacc) coeflabels(list "Rich[T,T+2]" dacc "DAC")

*Table10 Panel B: Controlling for clients¡¯ financial-reporting strategy during the post-listing period
gen dacc_list=dacc*list
eststo clear
eststo: quietly xi:xtreg op lagop list dacc dacc_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list dacc dacc_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(list dacc dacc_list) coeflabels(list "Rich[T,T+2]" dacc "DAC" dacc_list "Rich[T,T+2]¡ÁDAC")

*Table10 Panel C: Possible benefits of the rich listing
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & benefit==1 
gen k2=0
replace k2=1 if list==1 & benefit==0
gen k3=0
replace k3=1 if rich==1 & benefit==.
ta k1 k2
eststo clear 
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Benefied" k2 "Rich[T,T+2]*Suffered")

*Table10 Panel D: Public views about the billionaires
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & hero==1 
gen k2=0
replace k2=1 if list==1 & hero==0
gen k3=0
replace k3=1 if rich==1 & hero==.
ta k1 k2
eststo clear
eststo: quietly xi:xtreg op lagop k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost k1 k2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Heroes" k2 "Rich[T,T+2]*Villains")

*********************************************************
*Table7 Tests based on other designs
*Table7 column (1) exact matching by client size
use "E:\projects\richlist\reg2_match_TA.dta", clear 
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column (2) exact matching by client size and ROA
use "E:\projects\richlist\reg3_match_TA_ROA.dta", clear 
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column (3) PSM
use "E:\projects\richlist\reg4_match_PSM.dta", clear
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op rich list rich_list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
eststo: quietly xi:reg logdcost rich list rich_list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) pr2(3) title() nocons compress nogap  ///
keep(rich list rich_list) coeflabels(rich "Rich" list "Post" rich_list "Rich*Post")

*Table7 column(4) Treatment-only sample
use "E:\projects\richlist\reg1_main.dta", clear
keep if rich==1 & ryear>=-3 & ryear<=2
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear 
eststo: quietly xi:ologit op list lagop quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if rich==1,robust cl(code)
eststo: quietly xi:reg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year if rich==1,robust cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) pr2(3) ar2(3) title() nocons compress nogap ///
keep(list) coeflabels(list "Post")

*Table6 Placebo and falsification tests
*Table6 Panel A: Placebo test based on randomly created rich-listing events
use "E:\projects\richlist\reg5_placebo.dta", clear 
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2) 
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage bign nonlocal)
drop if miss>=1
*winsorize
foreach x of varlist logdcost quick arinv current turnover lev roa logta logage {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
eststo clear
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table6 Panel B: Falsification test based on billionaires that are first ranked between 201 and 600 and are never ranked within top 200 on the Rich List
use "E:\projects\richlist\reg6_falsify.dta", clear 
count
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>2)
capture drop miss
egen miss=rmiss(op lagop quick arinv current turnover lev roa loss logta logage)
drop if miss>=1
count
*winsorize
foreach x of varlist ///
 logdcost quick arinv current turnover lev roa logta logage ///
 lognews_neg lognews_pos tobinq {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}

eststo clear 
eststo: quietly xi:xtreg op lagop list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg op lagop pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost list quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg logdcost pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal i.indd i.year ///
 if rich==0 | (firstrank>200 & firstrank<=600),robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post0 post1 post2 quick arinv current turnover lev roa loss logta logage bign nonlocal lagop) ///
coeflabels(lagop "Lag(AO)" quick "Quick" arinv "ARINV" current "Current" turnover "Turnover" lev "Leverage" roa "ROA" loss "Loss" ///
logta "Ln(TAST)" logage "Ln(Age)" bign "BigN" nonlocal "Non-local" lagop "Lag(AO)")

*Table3 Rich listing and changes in firms¡¯ press coverage
*Table3 Panel B: Rich listing for non-top 200 billionaires and changes in firms¡¯ press coverage
count if ryear==0 & (firstrank>200 & firstrank<=600) //89 rich firms
eststo clear
*201-400
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>200 & firstrank<=400),robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>200 & firstrank<=400),robust fe i(code) cl(code)
*401-600
eststo: quietly xi:xtreg lognews_neg pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>400 & firstrank<=600),robust fe i(code) cl(code)
eststo: quietly xi:xtreg lognews_pos pre2 pre1 post0 post1 post2 logta lev roa tobinq i.indd i.year if rich==0 | (firstrank>400 & firstrank<=600),robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
coeflabels(logta "Ln(TAST)" lev "Leverage" roa "ROA" tobinq "Tobin's Q")

*Appendix 
*Table A1 Analysis of regulatory risks
use "E:\projects\richlist\reg1_main.dta", clear 
keep if year>=1996
drop if rich==1 & (ryear<-3 | ryear>5)
egen miss=rmiss(sanction list logta lev roa st soe noa loss tobinq)
drop if miss>=1
count
*winsorize
foreach x of varlist logta lev roa noa tobinq {
winsor `x', gen(tmp) p(0.01)
replace `x'=tmp
drop tmp
}
drop if rich==1 & ryear==0 

eststo clear 
eststo: quietly xi:xtreg sanction list logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
eststo: quietly xi:xtreg sanction pre2 pre1 post1 post2 post3 post4 post5 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap drop(_I* _con*) ///
order(list pre2 pre1 post1 post2 post3 post4 post5 logta lev roa loss tobinq st noa soe) ///
coeflabels(list "Rich[T+1,T+5]" logta "Ln(TAST)" lev "Leverage" roa "ROA" loss "Loss" tobinq "Tobin's Q" ///
st "ST" noa "NOA" soe "SOE")

*A: The acquisition of state assets 
gen k1=0
replace k1=1 if list==1 & acqsoe==1
gen k2=0
replace k2=1 if list==1 & acqsoe==0
eststo clear
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Acquirers" k2 "Rich[T,T+2]*Industrialists")

*B: Tax aggressiveness
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & taxavoider==1
gen k2=0
replace k2=1 if list==1 & taxavoider==0 
gen k3=1 if rich==1 & taxavoider==.
eststo clear
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Tax-avoiders" k2 "Rich[T,T+2]*Non-avoiders")

*C: Reporting transparency
capture drop k1 k2
capture drop k3
gen k1=0
replace k1=1 if list==1 & opaque==1
gen k2=0
replace k2=1 if list==1 & opaque==0 
gen k3=1 if rich==1 & opaque==.
eststo clear 
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year if k3~=1,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Opaque" k2 "Rich[T,T+2]*Transparent")

*D: Regional corruptness
capture drop k1 k2
gen k1=0
replace k1=1 if list==1 & qcorrupt<=2
gen k2=0
replace k2=1 if list==1 & qcorrupt>2
eststo clear 
eststo: quietly xi:xtreg sanction k1 k2 logta lev roa st soe noa loss tobinq i.indd i.year,robust fe i(code) cl(code)
esttab est*,b(%6.3f) t(2) star(* 0.1 ** 0.05 *** 0.01) ar2(3) title() nocons compress nogap ///
keep(k1 k2) coeflabels(k1 "Rich[T,T+2]*Corrput Regions" k2 "Rich[T,T+2]*Clean Regions")









