/* **************************************************************************************** */
/* Paper: The Economic Consequences of Financial Audit Regulation in the Charitable Sector
   
   Author: Raphael Duguay
   
   Refer to "0- Readme.pdf" for detailed instructions 
   
   Stata .do file to generate tables
*/
/* **************************************************************************************** */

* ********************************************************
* Tables
* ********************************************************

* ********************************************************
* Table 2

* SMPL A
clear
odbc load, table(SMPL_A) dsn(JMP)
gen GDP_PER_CAPITA_K = GDP_PER_CAPITA / 1000
tabstat INST_MANDATORY_AUDIT_SHARE MANDATORY_AUDIT_SHARE CONCENTRATION_DONATIONS LN_TOTAL_DONATIONS GEOGRAPHIC_CONCENTRATION SHARE_LARGEST_CITY SOCIAL_NEED_CONCENTRATION, s(mean sd p25 p50 p75 N) columns(statistics)

* SMPL B
clear
odbc load, table(SMPL_B) dsn(JMP)
tabstat INST_MANDATORY_AUDIT_SHARE CONCENTRATION_DONATIONS LN_TOTAL_DONATIONS RATINGS_COVERAGE_STD, s(mean sd p25 p50 p75 N) columns(statistics)

* SMPL C
clear 
odbc load, table(SMPL_C) dsn(JMP)
gen GDP_PER_CAPITA_K = GDP_PER_CAPITA / 1000
tabstat INST_MANDATORY_AUDIT_SHARE TAXPAYERS_WHO_GIVE_SHARE GDP_PER_CAPITA_K UNEMPLOYMENT_RATE ADJ_GROSS_INCOME, s(mean sd p25 p50 p75 N) columns(statistics)

* SMPL D
clear 
odbc load, table(SMPL_D) dsn(JMP)
gen GDP_PER_CAPITA_K = GDP_PER_CAPITA 
tabstat MANDATORY_AUDIT_SHARE TAXPAYERS_WHO_GIVE_SHARE GDP_PER_CAPITA_K UNEMPLOYMENT_RATE ADJ_GROSS_INCOME, s(mean sd p25 p50 p75 N) columns(statistics)

* SMPL E
clear 
odbc load, table(SMPL_E) dsn(JMP)
tabstat INST_MANDATORY_AUDIT_SHARE MANDATORY_AUDIT_SHARE AUDIT_SHARE DONATIONS_5K, s(mean sd p25 p50 p75 N) columns(statistics)

* ********************************************************
* Table 3
clear 
odbc load, table(SMPL_A) dsn(JMP)
xtset STATE_ACTIVITY_ID FISCAL_YEAR

eststo:quietly reghdfe MANDATORY_AUDIT_SHARE INST_MANDATORY_AUDIT_SHARE, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) keep(INST_MANDATORY_AUDIT_SHARE)	
estimates clear 

* ********************************************************
* Table 4
* Panel A
clear
odbc load, table(SMPL_A) dsn(JMP)

xtset STATE_ACTIVITY_ID FISCAL_YEAR

eststo:quietly reghdfe CONCENTRATION_DONATIONS L_INST_MANDATORY_AUDIT_SHARE                                                                                 , absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
eststo:quietly reghdfe CONCENTRATION_DONATIONS L_INST_MANDATORY_AUDIT_SHARE c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) keep(L_INST_MANDATORY_AUDIT_SHARE c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA) 	
estimates clear 

eststo:quietly reghdfe CONCENTRATION_DONATIONS L_INST_MANDATORY_AUDIT_SHARE c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
test L_INST_MANDATORY_AUDIT_SHARE + c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA  = 0	
test L_INST_MANDATORY_AUDIT_SHARE + c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA = 0
test c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA - c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA = 0
estimates clear 

* Panel B
clear
odbc load, table(SMPL_B) dsn(JMP)
xtset STATE_ACTIVITY_ID FISCAL_YEAR
eststo:quietly reghdfe CONCENTRATION_DONATIONS L_INST_MANDATORY_AUDIT_SHARE c.RATINGS_COVERAGE_STD#c.L_INST_MANDATORY_AUDIT_SHARE RATINGS_COVERAGE_STD, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID)
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(c.RATINGS_COVERAGE_STD#c.L_INST_MANDATORY_AUDIT_SHARE L_INST_MANDATORY_AUDIT_SHARE RATINGS_COVERAGE_STD)
estimates clear 


* ********************************************************
* Table 5
clear 
odbc load, table(SMPL_A) dsn(JMP)

xtset STATE_ACTIVITY_ID FISCAL_YEAR

eststo:quietly reghdfe GEOGRAPHIC_CONCENTRATION  L_INST_MANDATORY_AUDIT_SHARE, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
eststo:quietly reghdfe SHARE_LARGEST_CITY        L_INST_MANDATORY_AUDIT_SHARE, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
eststo:quietly reghdfe SOCIAL_NEED_CONCENTRATION L_INST_MANDATORY_AUDIT_SHARE, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) 	
estimates clear 


* ********************************************************
* Table 6
* Panel A
* Column 1
clear 
odbc load, table(SMPL_C) dsn(JMP)

xtset STATE_ID FISCAL_YEAR

gen GDP_PER_CAPITA_10K   = GDP_PER_CAPITA   / 10000
gen ADJ_GROSS_INCOME_10K = ADJ_GROSS_INCOME / 10

eststo:quietly reghdfe TAXPAYERS_WHO_GIVE_SHARE L_INST_MANDATORY_AUDIT_SHARE GDP_PER_CAPITA_10K UNEMPLOYMENT_RATE ADJ_GROSS_INCOME_10K, absorb(FISCAL_YEAR) vce(cluster STATE_ID) 

* Column 2
clear 
odbc load, table(SMPL_D) dsn(JMP)

xtset FIPS_ID FISCAL_YEAR	

gen GDP_PER_CAPITA_10K   = GDP_PER_CAPITA   / 10
gen ADJ_GROSS_INCOME_10K = ADJ_GROSS_INCOME / 10

eststo:quietly reghdfe TAXPAYERS_WHO_GIVE_SHARE L_MANDATORY_AUDIT_SHARE GDP_PER_CAPITA_10K UNEMPLOYMENT_RATE ADJ_GROSS_INCOME_10K, absorb(STATE_YEAR_ID) vce(cluster STATE_ID) 
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) order(L_INST_MANDATORY_AUDIT_SHARE L_MANDATORY_AUDIT_SHARE) drop(_cons)	
estimates clear 

* Panel B
clear
odbc load, table(SMPL_A) dsn(JMP)

xtset STATE_ACTIVITY_ID FISCAL_YEAR

eststo:quietly reghdfe LN_TOTAL_DONATIONS L_INST_MANDATORY_AUDIT_SHARE                                                                                 , absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
eststo:quietly reghdfe LN_TOTAL_DONATIONS L_INST_MANDATORY_AUDIT_SHARE c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) keep(L_INST_MANDATORY_AUDIT_SHARE c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA) 	
estimates clear 

eststo:quietly reghdfe LN_TOTAL_DONATIONS L_INST_MANDATORY_AUDIT_SHARE c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
test L_INST_MANDATORY_AUDIT_SHARE + c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA  = 0	
test L_INST_MANDATORY_AUDIT_SHARE + c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA = 0
test c.L_INST_MANDATORY_AUDIT_SHARE#c.HIGH_IA - c.L_INST_MANDATORY_AUDIT_SHARE#c.LOW_IA = 0
estimates clear 

* Panel C
clear
odbc load, table(SMPL_B) dsn(JMP)

xtset STATE_ACTIVITY_ID FISCAL_YEAR

eststo:quietly reghdfe LN_TOTAL_DONATIONS L_INST_MANDATORY_AUDIT_SHARE c.RATINGS_COVERAGE_STD#c.L_INST_MANDATORY_AUDIT_SHARE RATINGS_COVERAGE_STD, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID)
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons) order(c.RATINGS_COVERAGE_STD#c.L_INST_MANDATORY_AUDIT_SHARE L_INST_MANDATORY_AUDIT_SHARE RATINGS_COVERAGE_STD)
estimates clear 

* Panel D
clear 
odbc load, table(SMPL_E) dsn(JMP)

xtset STATE_ACTIVITY_ID FISCAL_YEAR

eststo:quietly reghdfe DONATIONS_5K L_INST_MANDATORY_AUDIT_SHARE, absorb(STATE_YEAR_ID ACTIVITY_YEAR_ID) vce(cluster STATE_ID) 
estout, cells(b(star fmt(3)) t(par([ ]) fmt(2))) stats(r2_a N, fmt(%9.3f %9.0g) labels(AdjR2 N)) starlevels(* 0.1 ** 0.05 *** 0.01) drop(_cons)	
estimates clear 

