//create log file of code
log using "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW JAR Full Log Output 2024 11 29.smcl", replace
set more off
set linesize 200
set seed 2021

//import form ap data from csv 
cd "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1"

import delimited "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\formap20230612.csv", clear 
//generate fyear from fiscal year period end variable 
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
generate fyeardate=date(fiscalperiodenddate,"MDY")
order fiscalperiodenddate fyear
format fyeardate %td
gen fyear = year(fyeardate)
gen date = 100*month(fyeardate)+day(fyeardate)
replace fyear= fyear-1 if date <=531
///keep only issuers so exclude employee benefit plan and investment company
keep if auditreporttype=="Issuer, other than Employee Benefit Plan or Investment Company"
drop auditreporttype
//keep only US firms
keep if firmcountry=="United States"
drop firmcountry
rename issuercik cik
destring cik, replace
order cik fyear engagementpartnerid
//only care about audits from 2016 on 
//some observations are dated early we dont care about those so drop 
drop if fyear<2015
keep cik fyear engagementpartnerid 

destring engagementpartnerid, replace
duplicates drop cik fyear, force
xtset cik fyear

egen partner_client=group(cik engagementpartnerid)
order cik fyear engagementpartnerid   partner_client
///generate indicator for partner switching
//group clients by client and engagmenetpartner id then say if they changed "groups" they switched partners 
xtset cik fyear
gen f_partner=f.partner_client
gen change_partner_fy=0
replace change_partner_fy=1 if partner_client!=f_partner
// dont include missing future years because we cant determine whether or not that was a switch or the client "died"
replace change_partner_fy=. if missing(f_partner)
//these are partner changes that we can identify
xtset cik fyear
gen same_partner_py=0
replace same_partner_py=1 if partner_client==l.partner_client
replace same_partner_py=. if missing(l.partner_client)
//rename variable for easier identification but a partner change indicates changed partners from t to t+1
gen partner_change=change_partner_fy
gen partner_switch=partner_change
gen keep_partner=1 if partner_switch==0
replace keep_partner=0 if partner_switch==1
//keep variables needed for later
keep cik fyear engagementpartnerid partner_client f_partner change_partner_fy same_partner_py partner_change   partner_switch keep_partner
save partner_changes_tomerge, replace 
//compile all data to merge onto partner data above

//start with audit fees to get measures needed for portfolio growth
//use raw audit fees file 
use "auditfeesraw20230612.dta", clear

rename *, lower
rename company_fkey cik
destring cik, replace
//drop if missing audit fees because we wont be able to use in portfolio measures 
drop if audit_fees==.
//gen auditor tiers
gen BIGN=0
replace BIGN=1 if auditor_fkey==3|auditor_fkey==2|auditor_fkey==1|auditor_fkey==4
gen second_tier=0
replace second_tier=1 if auditor_fkey==11761 | auditor_fkey==6 | auditor_fkey==16168 | auditor_fkey==2830 
gen third_tier=1
replace third_tier=0 if auditor_fkey==1 | auditor_fkey==2 | auditor_fkey==3 | auditor_fkey==4 | auditor_fkey==11761 | auditor_fkey==6 | auditor_fkey==16168 | auditor_fkey==2830
//gen fyear
gen fyear = year(fiscal_year_ended)
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
gen date = 100*month(fiscal_year_ended)+day(fiscal_year_ended)
replace fyear= fyear-1 if date <=531
drop date
gsort cik fyear -audit_fees
duplicates drop fyear cik, force
//drop any restated audit fees we want original 
drop if restatement==1
drop restatement
//only keep if in USD
keep if currency_code_fkey=="USD"
drop currency_code_fkey
drop if co_is_notick_sub==1 | co_is_shlblnk_nonop==1 | co_is_shlblnk_hldco==1 | co_is_ft==1 | co_is_abs==1 | co_is_reit==1
drop co_is_notick_sub co_is_shlblnk_nonop co_is_shlblnk_hldco co_is_ft co_is_abs co_is_reit
///gen change in audit fees
xtset cik fyear
gen f_audit_fees=f.audit_fees
gen change_client_audit_fees=(f_audit_fees-audit_fees)/audit_fees 
//transform audit fees to be in millions (following gipper paper as this is closest to ours to transform as a control variable when measuring partner portfolio size)
replace audit_fees=audit_fees/1000000

save AAFees, replace 

// now using audit opinions data to create variables for merging onto partner level 
use "opinionsraw20230612.dta", clear
rename *, lower
rename company_fkey cik
destring cik, replace

//drop foreign auditors
keep if auditor_country=="USA"

//gen gco indicator
gen gco=0
replace gco=1 if going_concern==1
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
gen fyear = year(fiscal_year_end_op)
gen date = 100*month(fiscal_year_end_op)+day(fiscal_year_end_op)
replace fyear= fyear-1 if date <=531
drop date
drop if auditor_city==""
gsort cik fyear 
duplicates drop fyear cik auditor_fkey, force
save AAOpinionsPreMerge, replace

//merge fees and opinions data together
merge 1:1 fyear cik auditor_fkey using AAFees
//only keep if merged together we need both fees and the corresponding opinions
keep if _merge==3 
drop _merge
gsort fyear cik -audit_fees
save AuditFeesOpinions, replace

//get material weakness data to merge onto dataset of fees and opinions
//start with raw file and then code as elc vs plc weaknesses 
use "404raw20230612.dta", clear
rename *, lower
gen cik=company_fkey
//only keep auditor opinions// drop mgmt
keep if ic_op_type=="a"
//drop any restated opinons because we only want original to avoid res ann that occur concurrently with res ICOs 
keep if is_nth_restate==0
drop if co_is_notick_sub==1 | co_is_shlblnk_nonop==1 | co_is_shlblnk_hldco==1 | co_is_ft==1 | co_is_abs==1 | co_is_reit==1
drop co_is_notick_sub co_is_shlblnk_nonop co_is_shlblnk_hldco co_is_ft co_is_abs co_is_reit
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
gen fyear = year(fye_ic_op)
gen date = 100*month(fye_ic_op)+day(fye_ic_op)
replace fyear= fyear-1 if date <=531
drop date
gsort cik fyear -count_weak
duplicates drop cik fyear count_weak, force
duplicates drop cik fyear, force
//got a 404b audit if they received an IC audit // 404b is coded as whether they got ICO regardless of mandatory or voluntary
gen IC_audit=1
gen weakness=0
replace weakness=1 if count_weak>0 
replace weakness=0 if missing(count_weak)
replace IC_audit=0 if missing(IC_audit)
keep cik fyear IC_audit  weakness
destring cik, replace
save sox404clean, replace
///code elc vs plc weaknesses 
use 404raw20230612, clear
rename *, lower
rename company_fkey cik
destring cik, replace
keep if ic_op_type == "a"
drop ic_op_type

gen test1 = substr(noteff_acc_reas_keys,1,1)
gen test2 = substr(noteff_acc_reas_keys,2,1)
gen test3 = substr(noteff_acc_reas_keys,3,1)
gen test4 = substr(noteff_acc_reas_keys,4,1)
gen test5 = substr(noteff_acc_reas_keys,5,1)
gen test6 = substr(noteff_acc_reas_keys,6,1)
gen test7 = substr(noteff_acc_reas_keys,7,1)
gen test8 = substr(noteff_acc_reas_keys,8,1)
gen test9 = substr(noteff_acc_reas_keys,9,1)
gen test10 = substr(noteff_acc_reas_keys,10,1)
gen test11 = substr(noteff_acc_reas_keys,11,1)
gen test12 = substr(noteff_acc_reas_keys,12,1)
gen test13 = substr(noteff_acc_reas_keys,13,1)
gen test14 = substr(noteff_acc_reas_keys,14,1)
gen test15 = substr(noteff_acc_reas_keys,15,1)
gen test16 = substr(noteff_acc_reas_keys,16,1)
gen test17 = substr(noteff_acc_reas_keys,17,1)
gen test18 = substr(noteff_acc_reas_keys,18,1)
gen test19 = substr(noteff_acc_reas_keys,19,1)
gen test20 = substr(noteff_acc_reas_keys,20,1)
gen test21 = substr(noteff_acc_reas_keys,21,1)
gen test22 = substr(noteff_acc_reas_keys,22,1)
gen test23 = substr(noteff_acc_reas_keys,23,1)
gen test24 = substr(noteff_acc_reas_keys,24,1)
gen test25 = substr(noteff_acc_reas_keys,25,1)
gen test26 = substr(noteff_acc_reas_keys,26,1)
gen test27 = substr(noteff_acc_reas_keys,27,1)
gen test28 = substr(noteff_acc_reas_keys,28,1)
gen test29 = substr(noteff_acc_reas_keys,29,1)
gen test30 = substr(noteff_acc_reas_keys,30,1)
gen test31 = substr(noteff_acc_reas_keys,31,1)
gen test32 = substr(noteff_acc_reas_keys,32,1)
gen test33 = substr(noteff_acc_reas_keys,33,1)
gen test34 = substr(noteff_acc_reas_keys,34,1)
gen test35 = substr(noteff_acc_reas_keys,35,1)
gen test36 = substr(noteff_acc_reas_keys,36,1)
gen test37 = substr(noteff_acc_reas_keys,37,1)
gen test38 = substr(noteff_acc_reas_keys,38,1)
gen test39 = substr(noteff_acc_reas_keys,39,1)
gen test40 = substr(noteff_acc_reas_keys,40,1)
gen test41 = substr(noteff_acc_reas_keys,41,1)
gen test42 = substr(noteff_acc_reas_keys,42,1)
gen test43 = substr(noteff_acc_reas_keys,43,1)
gen test44 = substr(noteff_acc_reas_keys,44,1)
gen test45 = substr(noteff_acc_reas_keys,45,1)
gen test46 = substr(noteff_acc_reas_keys,46,1)
gen test47 = substr(noteff_acc_reas_keys,47,1)
gen test48 = substr(noteff_acc_reas_keys,48,1)
gen test49 = substr(noteff_acc_reas_keys,49,1)
gen test50 = substr(noteff_acc_reas_keys,50,1)

order noteff_acc_reas_keys test1 test2 test3 test4 test5 test6 test7 test8 ///
                test9 test10 test11 test12 test13 test14 test15 test16 test17 test18 ///
                test19 test20 test21 test22 test23 test24 test25 test26 test27 test28 ///
                test29 test30 test31 test32 test33 test34 test35 test36 test37 test38 ///
                test39 test40 test41 test42 test43 test44 test45 test46 test47 test48 ///
                test49 test50
               
gen thing1 = substr(noteff_acc_reas_keys,3,1) == "|"
replace thing1 = . if noteff_acc_reas_keys == ""
gen thing2 = substr(noteff_acc_reas_keys,5,1) == "|"
replace thing2 = 2 if substr(noteff_acc_reas_keys,6,1) == "|"
replace thing2 = . if test5 == ""
gen thing3 = substr(noteff_acc_reas_keys,8,1) == "|"
replace thing3 = 2 if substr(noteff_acc_reas_keys,9,1) == "|"
replace thing3 = . if test8 == ""
gen thing4 = substr(noteff_acc_reas_keys,11,1) == "|"
replace thing4 = 2 if substr(noteff_acc_reas_keys,12,1) == "|"
replace thing4 = . if test11 == ""
gen thing5 = substr(noteff_acc_reas_keys,14,1) == "|"
replace thing5 = 2 if substr(noteff_acc_reas_keys,15,1) == "|"
replace thing5 = . if test14 == ""
gen thing6 = substr(noteff_acc_reas_keys,17,1) == "|"
replace thing6 = 2 if substr(noteff_acc_reas_keys,18,1) == "|"
replace thing6 = . if test17 == ""
gen thing7 = substr(noteff_acc_reas_keys,20,1) == "|"
replace thing7 = 2 if substr(noteff_acc_reas_keys,21,1) == "|"
replace thing7 = . if test20 == ""
gen thing8 = substr(noteff_acc_reas_keys,23,1) == "|"
replace thing8 = 2 if substr(noteff_acc_reas_keys,24,1) == "|"
replace thing8 = . if test23 == ""
gen thing9 = substr(noteff_acc_reas_keys,26,1) == "|"
replace thing9 = 2 if substr(noteff_acc_reas_keys,27,1) == "|"
replace thing9 = . if test26 == ""
gen thing10 = substr(noteff_acc_reas_keys,29,1) == "|"
replace thing10 = 2 if substr(noteff_acc_reas_keys,30,1) == "|"
replace thing10 = . if test29 == ""
gen thing11 = substr(noteff_acc_reas_keys,32,1) == "|"
replace thing11 = 2 if substr(noteff_acc_reas_keys,33,1) == "|"
replace thing11 = . if test32 == ""
gen thing12 = substr(noteff_acc_reas_keys,35,1) == "|"
replace thing12 = 2 if substr(noteff_acc_reas_keys,36,1) == "|"
replace thing12 = . if test35 == ""
gen thing13 = substr(noteff_acc_reas_keys,38,1) == "|"
replace thing13 = 2 if substr(noteff_acc_reas_keys,39,1) == "|"
replace thing13 = . if test38 == ""
gen thing14 = substr(noteff_acc_reas_keys,41,1) == "|"
replace thing14 = 2 if substr(noteff_acc_reas_keys,42,1) == "|"
replace thing14 = . if test41 == ""
gen thing15 = substr(noteff_acc_reas_keys,44,1) == "|"
replace thing15 = 2 if substr(noteff_acc_reas_keys,45,1) == "|"
replace thing15 = . if test44 == ""
gen thing16 = substr(noteff_acc_reas_keys,47,1) == "|"
replace thing16 = 2 if substr(noteff_acc_reas_keys,48,1) == "|"
replace thing16 = . if test47 == ""
gen thing17 = substr(noteff_acc_reas_keys,50,1) == "|"
replace thing17 = 2 if substr(noteff_acc_reas_keys,51,1) == "|"
replace thing17 = . if test50 == ""

order noteff_acc_reas_keys thing1 thing2 thing3 thing4 thing5 thing6 thing7 thing8 thing9 thing10 ///
                thing11 thing12 thing13 thing14 thing15 thing16 thing17
save sox404_prelim, replace

use sox404_prelim, clear

gen issue1 = ""
replace issue1 = test2 if thing1 == 1
order issue1
egen testa = concat(test2 test3)
order testa
replace issue1 = testa if thing1 == 0
gen issue2 = ""
replace issue2 = test4 if thing1 == 1 & thing2 == 1
order issue2
egen testb = concat(test5 test6)
order testb
replace issue2 = testb if thing1 == 0 & thing2 == 0
egen testc = concat(test4 test5)
replace issue2 = testc if thing1 == 1 & thing2 == 2
destring issue1, replace
destring issue2, replace
sort issue1 issue2
order noteff_acc_reas_keys issue1 issue2
gen issue3 = ""
order issue3
egen testd = concat(test7 test8)
order testd
replace issue3 = testd if thing1 == 1 & thing2 == 2 & thing3 == 2
egen teste = concat(test8 test9)
order teste
replace issue3 = teste if thing1 == 0 & thing2 == 0 & thing3 == 0
egen testf = concat(test6 test7)
replace issue3 = testf if thing1 == 1 & thing2 == 1 & thing3 == 1
destring issue3, replace
sort issue1 issue2 issue3
order noteff_acc_reas_keys issue1 issue2 issue3
gen issue4 = ""
egen testg = concat(test10 test11)
replace issue4 = testg if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2
egen testh = concat(test11 test12)
replace issue4 = testh if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0
egen testi = concat(test9 test10)
replace issue4 = testi if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1
destring issue4, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 

gen issue5 = ""
egen testj = concat(test13 test14)
replace issue5 = testj if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 & thing5 == 2
egen testk = concat(test14 test15)
replace issue5 = testk if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 & thing5 == 0
egen testl = concat(test12 test13)
replace issue5 = testl if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 & thing5 == 1
destring issue5, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5
gen issue6 = ""
egen testm = concat(test16 test17)
replace issue6 = testm if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2
egen testn = concat(test17 test18)
replace issue6 = testn if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0
egen testo = concat(test15 test16)
replace issue6 = testo if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1
destring issue6, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6
gen issue7 = ""
egen testp = concat(test19 test20)
replace issue7 = testp if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2
egen testq = concat(test20 test21)
replace issue7 = testq if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0
egen testr = concat(test18 test19)
replace issue7 = testr if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1
destring issue7, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7
gen issue8 = ""
egen tests = concat(test22 test23)
replace issue8 = tests if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2
egen testt = concat(test23 test24)
replace issue8 = testt if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0
egen testu = concat(test21 test22)
replace issue8 = testu if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1
destring issue8, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8
gen issue9 = ""
egen testv = concat(test25 test26)
replace issue9 = testv if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2
egen testw = concat(test26 test27)
replace issue9 = testw if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0
egen testx = concat(test24 test25)
replace issue9 = testx if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1
destring issue9, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9

gen issue10 = ""
egen testy = concat(test28 test29)
replace issue10 = testy if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2
egen testz = concat(test29 test30)
replace issue10 = testz if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0
egen testaa = concat(test27 test28)
replace issue10 = testaa if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1
destring issue10, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10
            
              
             
gen issue11 = ""
egen testbb = concat(test31 test32)
replace issue11 = testbb if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2
egen testcc = concat(test32 test33)
replace issue11 = testcc if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0
egen testdd = concat(test30 test31)
replace issue11 = testdd if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1
destring issue11, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11
                
              
              
gen issue12 = ""
egen testee = concat(test34 test35)
replace issue12 = testee if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2
egen testff = concat(test35 test36)
replace issue12 = testff if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0
egen testgg = concat(test33 test34)
replace issue12 = testgg if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1
destring issue12, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11 issue12      
                
               
gen issue13 = ""
egen testhh = concat(test37 test38)
replace issue13 = testhh if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2 & thing13 == 2
egen testii = concat(test38 test39)
replace issue13 = testii if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0 & thing13 == 0
egen testjj = concat(test36 test37)
replace issue13 = testjj if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1 & thing13 == 1
destring issue13, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11 issue12 issue13      
               
              
               
gen issue14 = ""
egen testkk = concat(test40 test41)
replace issue14 = testkk if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2 & thing13 == 2 ///
                & thing14 == 2
egen testll = concat(test41 test42)
replace issue14 = testll if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0 & thing13 == 0 ///
                & thing14 == 0
egen testmm = concat(test39 test40)
replace issue14 = testmm if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1 & thing13 == 1 ///
                & thing14 == 1
destring issue14, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11 issue12 issue13 issue14      
                
                
gen issue15 = ""
egen testnn = concat(test43 test44)
replace issue15 = testnn if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2 & thing13 == 2 ///
                & thing14 == 2 & thing15 == 2
egen testoo = concat(test44 test45)
replace issue15 = testoo if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0 & thing13 == 0 ///
                & thing14 == 0 & thing15 == 0
egen testpp = concat(test42 test43)
replace issue15 = testpp if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1 & thing13 == 1 ///
                & thing14 == 1 & thing15 == 1
destring issue15, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11 issue12 issue13 issue14 issue15      
                
               
gen issue16 = ""
egen testqq = concat(test46 test47)
replace issue16 = testqq if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2 & thing13 == 2 ///
                & thing14 == 2 & thing15 == 2 & thing16 == 2

egen testrr = concat(test47 test48)
replace issue16 = testrr if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0 & thing13 == 0 ///
                & thing14 == 0 & thing15 == 0 & thing16 == 0
egen testss = concat(test45 test46)
replace issue16 = testss if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1 & thing13 == 1 ///
                & thing14 == 1 & thing15 == 1 & thing16 == 1
destring issue16, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11 issue12 issue13 issue14 issue15 issue16
               
                
gen issue17 = ""
egen testtt = concat(test49 test50)
replace issue17 = testtt if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2 & thing13 == 2 ///
                & thing14 == 2 & thing15 == 2 & thing16 == 2 & thing17 == 2
egen testvv = concat(test48 test49)
replace issue17 = testvv if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1 & thing13 == 1 ///
                & thing14 == 1 & thing15 == 1 & thing16 == 1 & thing17 == 1
destring issue17, replace
order noteff_acc_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 ///
                issue8 issue9 issue10 issue11 issue12 issue13 issue14 issue15 issue16 issue17
               
count if issue17 != .         
save sox404_prelim2, replace
use sox404_prelim2, clear
                
                
forvalues i = 1/99 {           
gen IC`i'=0
replace IC`i'=1 if issue1==`i' | issue2==`i' | issue3==`i' | issue4==`i' | issue5==`i' ///
                | issue6==`i' | issue7==`i' | issue8==`i' | issue9==`i' | issue10==`i' | issue11==`i' ///
                | issue12==`i' | issue13==`i' | issue14==`i' | issue15==`i' | issue16==`i' | issue17==`i'
sum IC`i'               
                }
//This is a loop.
//// adding in to the actual mw entity 
gen entity_level=0
replace entity_level=1 if IC77==1 | IC76==1 | IC38==1 | IC11==1 | IC13==1 | IC18==1 | IC21==1 | IC44==1

drop IC1 IC2 IC4 IC5 IC6 IC7 IC9 IC11 IC12 IC13 IC17 IC18 IC19 IC20 IC21 IC22 ///
                IC37 IC42 IC43 IC44 IC45 IC46 IC49 IC50 IC51 IC52 IC53 IC54 IC55 IC56 IC57 ///
                IC58 IC59 IC60 IC61 IC62 IC63 IC64 IC65 IC66 IC67 IC69 IC70 IC71 IC72 IC74 ///
                IC75 IC76 IC77 IC78 IC79 IC82 IC83 IC84 IC85 IC86 IC87 IC88 IC89 IC90 IC91 ///
                IC92 IC93 IC94 IC95 IC96 IC97 IC98 IC99

              
   
               
save sox404_IC, replace
                                             
use sox404_IC, clear        
           
drop issue1 issue2 issue3 issue4 issue5 issue6 issue7 issue8 issue9 issue10            ///
                issue11 issue12 issue13 issue14 issue15 issue16 issue17 thing1 thing2 ///
                thing3 thing4 thing5 thing6 thing7 thing8 thing9 thing10 thing11 thing12 ///
                thing13 thing14 thing15 thing16 thing17 test1 test2 test3 test4 test5 test6 ///
                test7 test8 test9 test10 test11 test12 test13 test14 test15 test16 test17 test18 ///
                test19 test20 test21 test22 test23 test24 test25 test26 test27 test28 test29 test30 ///
                test31 test32 test33 test34 test35 test36 test37 test38 test39 test40 test41 test42 ///
                test43 test44 test45 test46 test47 test48 test49 test50 testa testb testc ///
                testd teste testf testg testh testi testj testk testl testm testn testo ///
                testp testq testr tests testt testu testv testw testx testy testz testaa ///
                testbb testcc testdd testee testff testgg testhh testii testjj testkk testll ///
                testmm testnn testoo testpp testqq testrr testss testtt testvv
                
drop if is_nth_restate != 0
drop is_nth_restate
               
keep ic_op_fkey auditor_fkey auditor_agrees combined ic_op_fkey ic_is_effective ///
                fye_ic_op  count_weak    ///
                exe_reas_keys exe_reas_phr noteff_finfraud_phr ///
                noteff_finfraud_keys notefferrors noteff_reas_keys noteff_reas_phr ///
                noteff_other noteff_other_reas_keys noteff_other_reas_phr  ///
                  cik IC3 IC8 IC10 IC14 IC15 IC16 IC23 IC24 IC25 ///
                IC26 IC27 IC28 IC29 IC30 IC31 IC32 IC33 IC34 IC35 IC36 IC38 IC39 IC40 IC41 ///
                IC47 IC48 IC68 IC73 IC80 IC81  entity_level
                
gsort -exe_reas_keys     
              
gen test1 = substr(exe_reas_keys,1,1)
gen test2 = substr(exe_reas_keys,2,1)
gen test3 = substr(exe_reas_keys,3,1)
gen test4 = substr(exe_reas_keys,4,1)
gen test5 = substr(exe_reas_keys,5,1)
gen test6 = substr(exe_reas_keys,6,1)
gen test7 = substr(exe_reas_keys,7,1)
gen thing1 = substr(exe_reas_keys,3,1) == "|"
replace thing1 = . if exe_reas_keys == ""
gen thing2 = substr(exe_reas_keys,5,1) == "|"
replace thing2 = 2 if substr(exe_reas_keys,6,1) == "|"
replace thing2 = . if test5 == ""
              
gen issue1 = ""
replace issue1 = test2 if thing1 == 1
order issue1
egen testa = concat(test2 test3)
order testa
replace issue1 = testa if thing1 == 0

gen issue2 = ""
replace issue2 = test4 if thing1 == 1 & thing2 == 1
order issue2
egen testb = concat(test5 test6)
order testb
replace issue2 = testb if thing1 == 0 & thing2 == 0
egen testc = concat(test4 test5)
replace issue2 = testc if thing1 == 1 & thing2 == 2
destring issue1, replace
destring issue2, replace
sort issue1 issue2
order exe_reas_keys issue1 issue2
              
              
                               
gen EXE1=0
replace EXE1=1 if issue1==1 | issue2==1
gen EXE2=0
replace EXE2=1 if issue1==2 | issue2==2
gen EXE45=0
replace EXE45=1 if issue1==45 | issue2==45              
gen EXE46=0
replace EXE46=1 if issue1==46 | issue2==46                      
gen EXE71=0
replace EXE71=1 if issue1==71 | issue2==71         
gen EXE78=0
replace EXE78=1 if issue1==78 | issue2==78                         
gen EXE79=0
replace EXE79=1 if issue1==79 | issue2==79                                     
                
drop test1 test2 test3 test4 test5 test6 test7 thing1 thing2 issue1 issue2 ///
                                testa testb testc
             
drop exe_reas_keys exe_reas_phr            
gsort -noteff_finfraud_keys                     
gen test1 = substr(noteff_finfraud_keys,1,1)
gen test2 = substr(noteff_finfraud_keys,2,1)
gen test3 = substr(noteff_finfraud_keys,3,1)
gen test4 = substr(noteff_finfraud_keys,4,1)
gen test5 = substr(noteff_finfraud_keys,5,1)
gen test6 = substr(noteff_finfraud_keys,6,1)
gen test7 = substr(noteff_finfraud_keys,7,1)
gen test8 = substr(noteff_finfraud_keys,8,1)
gen test9 = substr(noteff_finfraud_keys,9,1)
gen test10 = substr(noteff_finfraud_keys,10,1)
gen test11 = substr(noteff_finfraud_keys,11,1)
gen test12 = substr(noteff_finfraud_keys,12,1)
gen test13 = substr(noteff_finfraud_keys,13,1)
gen test14 = substr(noteff_finfraud_keys,14,1)
gen test15 = substr(noteff_finfraud_keys,15,1)
gen test16 = substr(noteff_finfraud_keys,16,1)
gen test17 = substr(noteff_finfraud_keys,17,1)
gen test18 = substr(noteff_finfraud_keys,18,1)
gen test19 = substr(noteff_finfraud_keys,19,1)
gen test20 = substr(noteff_finfraud_keys,20,1)
gen test21 = substr(noteff_finfraud_keys,21,1)
gen test22 = substr(noteff_finfraud_keys,22,1)
gen test23 = substr(noteff_finfraud_keys,23,1)
gen test24 = substr(noteff_finfraud_keys,24,1)
gen test25 = substr(noteff_finfraud_keys,25,1)
gen test26 = substr(noteff_finfraud_keys,26,1)
gen test27 = substr(noteff_finfraud_keys,27,1)
gen test28 = substr(noteff_finfraud_keys,28,1)
              
order noteff_finfraud_keys test1 test2 test3 test4 test5 test6 test7 test8 ///
                test9 test10 test11 test12 test13 test14 test15 test16 test17 test18 ///
                test19 test20 test21 test22 test23 test24 test25 test26 test27 test28

                             
gen thing1 = substr(noteff_finfraud_keys,3,1) == "|"
replace thing1 = . if noteff_finfraud_keys == ""
gen thing2 = substr(noteff_finfraud_keys,5,1) == "|"
replace thing2 = 2 if substr(noteff_finfraud_keys,6,1) == "|"
replace thing2 = . if test5 == ""
gen thing3 = substr(noteff_finfraud_keys,8,1) == "|"
replace thing3 = 2 if substr(noteff_finfraud_keys,9,1) == "|"
replace thing3 = . if test8 == ""
gen thing4 = substr(noteff_finfraud_keys,11,1) == "|"
replace thing4 = 2 if substr(noteff_finfraud_keys,12,1) == "|"
replace thing4 = . if test11 == ""
gen thing5 = substr(noteff_finfraud_keys,14,1) == "|"
replace thing5 = 2 if substr(noteff_finfraud_keys,15,1) == "|"
replace thing5 = . if test14 == ""
gen thing6 = substr(noteff_finfraud_keys,17,1) == "|"
replace thing6 = 2 if substr(noteff_finfraud_keys,18,1) == "|"
replace thing6 = . if test17 == ""
gen thing7 = substr(noteff_finfraud_keys,20,1) == "|"
replace thing7 = 2 if substr(noteff_finfraud_keys,21,1) == "|"
replace thing7 = . if test20 == ""
gen thing8 = substr(noteff_finfraud_keys,23,1) == "|"
replace thing8 = 2 if substr(noteff_finfraud_keys,24,1) == "|"
replace thing8 = . if test23 == ""
gen thing9 = substr(noteff_finfraud_keys,26,1) == "|"
replace thing9 = 2 if substr(noteff_finfraud_keys,27,1) == "|"
replace thing9 = . if test26 == ""             
order noteff_finfraud_keys thing1 thing2 thing3 thing4 thing5 thing6 thing7 thing8 thing9
save sox404_prelim99, replace

use sox404_prelim99, clear
gen issue1 = ""
replace issue1 = test2 if thing1 == 1
order issue1
egen testa = concat(test2 test3)
order testa
replace issue1 = testa if thing1 == 0
gen issue2 = ""
replace issue2 = test4 if thing1 == 1 & thing2 == 1
order issue2
egen testb = concat(test5 test6)
order testb
replace issue2 = testb if thing1 == 0 & thing2 == 0
egen testc = concat(test4 test5)
replace issue2 = testc if thing1 == 1 & thing2 == 2
destring issue1, replace
destring issue2, replace
gen issue3 = ""
order issue3
egen testd = concat(test7 test8)
order testd
replace issue3 = testd if thing1 == 1 & thing2 == 2 & thing3 == 2
egen teste = concat(test8 test9)
order teste
replace issue3 = teste if thing1 == 0 & thing2 == 0 & thing3 == 0
egen testf = concat(test6 test7)
replace issue3 = testf if thing1 == 1 & thing2 == 1 & thing3 == 1
destring issue3, replace
gen issue4 = ""
egen testg = concat(test10 test11)
replace issue4 = testg if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2
egen testh = concat(test11 test12)
replace issue4 = testh if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0
egen testi = concat(test9 test10)
replace issue4 = testi if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1
destring issue4, replace
gen issue5 = ""
egen testj = concat(test13 test14)
replace issue5 = testj if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 & thing5 == 2
egen testk = concat(test14 test15)
replace issue5 = testk if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 & thing5 == 0
egen testl = concat(test12 test13)
replace issue5 = testl if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 & thing5 == 1
destring issue5, replace
gen issue6 = ""
egen testm = concat(test16 test17)
replace issue6 = testm if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2
egen testn = concat(test17 test18)
replace issue6 = testn if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0
egen testo = concat(test15 test16)
replace issue6 = testo if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1
destring issue6, replace
gen issue7 = ""
egen testp = concat(test19 test20)
replace issue7 = testp if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2
egen testq = concat(test20 test21)
replace issue7 = testq if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0
egen testr = concat(test18 test19)
replace issue7 = testr if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1
destring issue7, replace
gen issue8 = ""
egen tests = concat(test22 test23)
replace issue8 = tests if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2
egen testt = concat(test23 test24)
replace issue8 = testt if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0
egen testu = concat(test21 test22)
replace issue8 = testu if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1
destring issue8, replace
gen issue9 = ""
egen testv = concat(test25 test26)
replace issue9 = testv if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2
egen testw = concat(test26 test27)
replace issue9 = testw if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0
egen testx = concat(test24 test25)
replace issue9 = testx if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1
destring issue9, replace            
order noteff_finfraud_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 issue8 issue9                                                        
gen FF3=0
replace FF3=1 if issue1==3 | issue2==3 | issue3==3 | issue4==3 | issue4==3 ///
                | issue5==3 | issue6==3 | issue7==3 | issue8==3
gen FF14=0
replace FF14=1 if issue1==14 | issue2==14 | issue3==14 | issue4==14 | issue4==14 ///
                | issue5==14 | issue6==14 | issue7==14 | issue8==14
gen FF15=0
replace FF15=1 if issue1==15 | issue2==15 | issue3==15 | issue4==15 | issue4==15 ///
                | issue5==15 | issue6==15 | issue7==15 | issue8==15
gen FF16=0
replace FF16=1 if issue1==16 | issue2==16 | issue3==16 | issue4==16 | issue4==16 ///
                | issue5==16 | issue6==16 | issue7==16 | issue8==16
gen FF24=0
replace FF24=1 if issue1==24 | issue2==24 | issue3==24 | issue4==24 | issue4==24 ///
                | issue5==24 | issue6==24 | issue7==24 | issue8==24               
gen FF27=0
replace FF27=1 if issue1==27 | issue2==27 | issue3==27 | issue4==27 | issue4==27 ///
                | issue5==27 | issue6==27 | issue7==27 | issue8==27
gen FF28=0
replace FF28=1 if issue1==28 | issue2==28 | issue3==28 | issue4==28 | issue4==28 ///
                | issue5==28 | issue6==28 | issue7==28 | issue8==28                     
gen FF29=0
replace FF29=1 if issue1==29 | issue2==29 | issue3==29 | issue4==29 | issue4==29 ///
                | issue5==29 | issue6==29 | issue7==29 | issue8==29
gen FF30=0
replace FF30=1 if issue1==30 | issue2==30 | issue3==30 | issue4==30 | issue4==30 ///
                | issue5==30 | issue6==30 | issue7==30 | issue8==30             
gen FF32=0
replace FF32=1 if issue1==32 | issue2==32 | issue3==32 | issue4==32 | issue4==32 ///
                | issue5==32 | issue6==32 | issue7==32 | issue8==32
gen FF33=0
replace FF33=1 if issue1==33 | issue2==33 | issue3==33 | issue4==33 | issue4==33 ///
                | issue5==33 | issue6==33 | issue7==33 | issue8==33
gen FF35=0
replace FF35=1 if issue1==35 | issue2==35 | issue3==35 | issue4==35 | issue4==35 ///
                | issue5==35 | issue6==35 | issue7==35 | issue8==35                      
gen FF36=0
replace FF36=1 if issue1==36 | issue2==36 | issue3==36 | issue4==36 | issue4==36 ///
                | issue5==36 | issue6==36 | issue7==36 | issue8==36                
gen FF38=0
replace FF38=1 if issue1==38 | issue2==38 | issue3==38 | issue4==38 | issue4==38 ///
                | issue5==38 | issue6==38 | issue7==38 | issue8==38                      
gen FF39=0
replace FF39=1 if issue1==39 | issue2==39 | issue3==39 | issue4==39 | issue4==39 ///
                | issue5==39 | issue6==39 | issue7==39 | issue8==39                      
gen FF40=0
replace FF40=1 if issue1==40 | issue2==40 | issue3==40 | issue4==40 | issue4==40 ///
                | issue5==40 | issue6==40 | issue7==40 | issue8==40   
				gen FF41=0
replace FF41=1 if issue1==41 | issue2==41 | issue3==41 | issue4==41 | issue4==41 ///
                | issue5==41 | issue6==41 | issue7==41 | issue8==41                      
gen FF68=0
replace FF68=1 if issue1==68 | issue2==68 | issue3==68 | issue4==68 | issue4==68 ///
                | issue5==68 | issue6==68 | issue7==68 | issue8==68                      
                            
replace entity_level=1 if  FF38==1
            
drop test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 test11 ///
                test12 test13 test14 test15 test16 test17 test18 test19 test20 test21 ///
                test22 test23 test24 test25 test26 test27 test28 thing1 thing2 thing3 ///
                thing4 thing5 thing6 thing7 thing8 thing9 testa testb testc testd teste ///
                testf testg testh testi testj testk testl testm testn testo testp testq ///
                testr tests testt testu testv testw testx issue1 issue2 issue3 issue4 ///
                issue5 issue6 issue7 issue8 issue9               
drop noteff_finfraud_keys noteff_finfraud_phr               
save sox404_prelim100, replace                          
use sox404_prelim100, clear              
gsort -notefferrors
drop notefferrors
gen test1 = substr(noteff_reas_keys,1,1)
gen test2 = substr(noteff_reas_keys,2,1)
gen test3 = substr(noteff_reas_keys,3,1)
gen test4 = substr(noteff_reas_keys,4,1)
gen test5 = substr(noteff_reas_keys,5,1)
gen test6 = substr(noteff_reas_keys,6,1)
gen test7 = substr(noteff_reas_keys,7,1)
gen thing1 = substr(noteff_reas_keys,3,1) == "|"
replace thing1 = . if noteff_reas_keys == ""
gen thing2 = substr(noteff_reas_keys,5,1) == "|"
replace thing2 = 2 if substr(noteff_reas_keys,6,1) == "|"
replace thing2 = . if test5 == ""
gen issue1 = ""
replace issue1 = test2 if thing1 == 1
order issue1
egen testa = concat(test2 test3)
order testa
replace issue1 = testa if thing1 == 0
gen issue2 = ""
replace issue2 = test4 if thing1 == 1 & thing2 == 1
order issue2
egen testb = concat(test5 test6)
order testb
replace issue2 = testb if thing1 == 0 & thing2 == 0
egen testc = concat(test4 test5)
replace issue2 = testc if thing1 == 1 & thing2 == 2
destring issue1, replace
destring issue2, replace              
order noteff_reas_keys issue1 issue2                    
gen ERR28=0
replace ERR28=1 if issue1==28 | issue2==28               
gen ERR35=0
replace ERR35=1 if issue1==35 | issue2==35
gen ERR39=0
replace ERR39=1 if issue1==39 | issue2==39                      
drop test1 test2 test3 test4 test5 test6 test7 thing1 thing2 issue1 issue2 ///
                testa testb testc noteff_reas_keys noteff_reas_phr          
save sox404_prelim101, replace
use sox404_prelim101, clear      
gsort -noteff_other_reas_keys               
gen test1 = substr(noteff_other_reas_keys,1,1)
gen test2 = substr(noteff_other_reas_keys,2,1)
gen test3 = substr(noteff_other_reas_keys,3,1)
gen test4 = substr(noteff_other_reas_keys,4,1)
gen test5 = substr(noteff_other_reas_keys,5,1)
gen test6 = substr(noteff_other_reas_keys,6,1)
gen test7 = substr(noteff_other_reas_keys,7,1)
gen test8 = substr(noteff_other_reas_keys,8,1)
gen test9 = substr(noteff_other_reas_keys,9,1)
gen test10 = substr(noteff_other_reas_keys,10,1)
gen test11 = substr(noteff_other_reas_keys,11,1)
gen test12 = substr(noteff_other_reas_keys,12,1)
gen test13 = substr(noteff_other_reas_keys,13,1)
gen test14 = substr(noteff_other_reas_keys,14,1)
gen test15 = substr(noteff_other_reas_keys,15,1)
gen test16 = substr(noteff_other_reas_keys,16,1)
gen test17 = substr(noteff_other_reas_keys,17,1)
gen test18 = substr(noteff_other_reas_keys,18,1)
gen test19 = substr(noteff_other_reas_keys,19,1)
gen test20 = substr(noteff_other_reas_keys,20,1)
gen test21 = substr(noteff_other_reas_keys,21,1)
gen test22 = substr(noteff_other_reas_keys,22,1)
gen test23 = substr(noteff_other_reas_keys,23,1)
gen test24 = substr(noteff_other_reas_keys,24,1)
gen test25 = substr(noteff_other_reas_keys,25,1)
gen test26 = substr(noteff_other_reas_keys,26,1)
gen test27 = substr(noteff_other_reas_keys,27,1)
gen test28 = substr(noteff_other_reas_keys,28,1)
gen test29 = substr(noteff_other_reas_keys,29,1)
gen test30 = substr(noteff_other_reas_keys,30,1)
gen test31 = substr(noteff_other_reas_keys,31,1)
gen test32 = substr(noteff_other_reas_keys,32,1)
gen test33 = substr(noteff_other_reas_keys,33,1)
gen test34 = substr(noteff_other_reas_keys,34,1)
gen test35 = substr(noteff_other_reas_keys,35,1)
gen test36 = substr(noteff_other_reas_keys,36,1)
gen test37 = substr(noteff_other_reas_keys,37,1)
gen test38 = substr(noteff_other_reas_keys,38,1)
gen test39 = substr(noteff_other_reas_keys,39,1)
gen test40 = substr(noteff_other_reas_keys,40,1)
gen test41 = substr(noteff_other_reas_keys,41,1)
gen test42 = substr(noteff_other_reas_keys,42,1)
order noteff_other_reas_keys test1 test2 test3 test4 test5 test6 test7 test8 ///
                test9 test10 test11 test12 test13 test14 test15 test16 test17 test18 ///
                test19 test20 test21 test22 test23 test24 test25 test26 test27 test28 ///
                test29 test30 test31 test32 test33 test34 test35 test36 test37 test38 ///
                test39 test40 test41 test42             
                
gen thing1 = substr(noteff_other_reas_keys,3,1) == "|"
replace thing1 = . if noteff_other_reas_keys == ""
gen thing2 = substr(noteff_other_reas_keys,5,1) == "|"
replace thing2 = 2 if substr(noteff_other_reas_keys,6,1) == "|"
replace thing2 = . if test5 == ""
gen thing3 = substr(noteff_other_reas_keys,8,1) == "|"
replace thing3 = 2 if substr(noteff_other_reas_keys,9,1) == "|"
replace thing3 = . if test8 == ""
gen thing4 = substr(noteff_other_reas_keys,11,1) == "|"
replace thing4 = 2 if substr(noteff_other_reas_keys,12,1) == "|"
replace thing4 = . if test11 == ""
gen thing5 = substr(noteff_other_reas_keys,14,1) == "|"
replace thing5 = 2 if substr(noteff_other_reas_keys,15,1) == "|"
replace thing5 = . if test14 == ""
gen thing6 = substr(noteff_other_reas_keys,17,1) == "|"
replace thing6 = 2 if substr(noteff_other_reas_keys,18,1) == "|"
replace thing6 = . if test17 == ""
gen thing7 = substr(noteff_other_reas_keys,20,1) == "|"
replace thing7 = 2 if substr(noteff_other_reas_keys,21,1) == "|"
replace thing7 = . if test20 == ""
gen thing8 = substr(noteff_other_reas_keys,23,1) == "|"
replace thing8 = 2 if substr(noteff_other_reas_keys,24,1) == "|"
replace thing8 = . if test23 == ""
gen thing9 = substr(noteff_other_reas_keys,26,1) == "|"
replace thing9 = 2 if substr(noteff_other_reas_keys,27,1) == "|"
replace thing9 = . if test26 == ""
gen thing10 = substr(noteff_other_reas_keys,29,1) == "|"
replace thing10 = 2 if substr(noteff_other_reas_keys,30,1) == "|"
replace thing10 = . if test29 == ""
gen thing11 = substr(noteff_other_reas_keys,32,1) == "|"
replace thing11 = 2 if substr(noteff_other_reas_keys,33,1) == "|"
replace thing11 = . if test32 == ""
gen thing12 = substr(noteff_other_reas_keys,35,1) == "|"
replace thing12 = 2 if substr(noteff_other_reas_keys,36,1) == "|"
replace thing12 = . if test35 == ""
gen thing13 = substr(noteff_other_reas_keys,38,1) == "|"
replace thing13 = 2 if substr(noteff_other_reas_keys,39,1) == "|"
replace thing13 = . if test38 == ""
gen thing14 = substr(noteff_other_reas_keys,41,1) == "|"
replace thing14 = 2 if substr(noteff_other_reas_keys,42,1) == "|"
replace thing14 = . if test41 == ""                           
save sox404_prelim102, replace
use sox404_prelim102, clear
gen issue1 = ""
replace issue1 = test2 if thing1 == 1
egen testa = concat(test2 test3)
replace issue1 = testa if thing1 == 0
gen issue2 = ""
replace issue2 = test4 if thing1 == 1 & thing2 == 1
egen testb = concat(test5 test6)
replace issue2 = testb if thing1 == 0 & thing2 == 0
egen testc = concat(test4 test5)
replace issue2 = testc if thing1 == 1 & thing2 == 2
destring issue1, replace
destring issue2, replace
gen issue3 = ""
egen testd = concat(test7 test8)
replace issue3 = testd if thing1 == 1 & thing2 == 2 & thing3 == 2
egen teste = concat(test8 test9)
replace issue3 = teste if thing1 == 0 & thing2 == 0 & thing3 == 0
egen testf = concat(test6 test7)
replace issue3 = testf if thing1 == 1 & thing2 == 1 & thing3 == 1
destring issue3, replace
gen issue4 = ""
egen testg = concat(test10 test11)
replace issue4 = testg if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2
egen testh = concat(test11 test12)
replace issue4 = testh if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0
egen testi = concat(test9 test10)
replace issue4 = testi if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1
destring issue4, replace
gen issue5 = ""
egen testj = concat(test13 test14)
replace issue5 = testj if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 & thing5 == 2
egen testk = concat(test14 test15)
replace issue5 = testk if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 & thing5 == 0
egen testl = concat(test12 test13)
replace issue5 = testl if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 & thing5 == 1
destring issue5, replace
gen issue6 = ""
egen testm = concat(test16 test17)
replace issue6 = testm if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2
egen testn = concat(test17 test18)
replace issue6 = testn if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0
egen testo = concat(test15 test16)
replace issue6 = testo if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1
destring issue6, replace
gen issue7 = ""
egen testp = concat(test19 test20)
replace issue7 = testp if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2
egen testq = concat(test20 test21)
replace issue7 = testq if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
               & thing5 == 0 & thing6 == 0 & thing7 == 0
egen testr = concat(test18 test19)
replace issue7 = testr if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1
destring issue7, replace
gen issue8 = ""
egen tests = concat(test22 test23)
replace issue8 = tests if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2
egen testt = concat(test23 test24)
replace issue8 = testt if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0
egen testu = concat(test21 test22)
replace issue8 = testu if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1
destring issue8, replace
gen issue9 = ""
egen testv = concat(test25 test26)
replace issue9 = testv if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2
egen testw = concat(test26 test27)

replace issue9 = testw if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0
egen testx = concat(test24 test25)
replace issue9 = testx if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1
destring issue9, replace              
gen issue10 = ""
egen testy = concat(test28 test29)
replace issue10 = testy if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2
egen testz = concat(test29 test30)
replace issue10 = testz if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0
egen testaa = concat(test27 test28)
replace issue10 = testaa if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1
destring issue10, replace                                        
gen issue11 = ""
egen testbb = concat(test31 test32)
replace issue11 = testbb if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2
egen testcc = concat(test32 test33)
replace issue11 = testcc if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0
egen testdd = concat(test30 test31)
replace issue11 = testdd if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1
destring issue11, replace                        
gen issue12 = ""
egen testee = concat(test34 test35)
replace issue12 = testee if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2
egen testff = concat(test35 test36)
replace issue12 = testff if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0
egen testgg = concat(test33 test34)
replace issue12 = testgg if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1
destring issue12, replace                                            
gen issue13 = ""
egen testhh = concat(test37 test38)
replace issue13 = testhh if thing1 == 1 & thing2 == 2 & thing3 == 2 & thing4 == 2 ///
                & thing5 == 2 & thing6 == 2 & thing7 == 2 & thing8 == 2 & thing9 == 2 ///
                & thing10 == 2 & thing11 == 2 & thing12 == 2 & thing13 == 2
egen testii = concat(test38 test39)
replace issue13 = testii if thing1 == 0 & thing2 == 0 & thing3 == 0 & thing4 == 0 ///
                & thing5 == 0 & thing6 == 0 & thing7 == 0 & thing8 == 0 & thing9 == 0 ///
                & thing10 == 0 & thing11 == 0 & thing12 == 0 & thing13 == 0
egen testjj = concat(test36 test37)
replace issue13 = testjj if thing1 == 1 & thing2 == 1 & thing3 == 1 & thing4 == 1 ///
                & thing5 == 1 & thing6 == 1 & thing7 == 1 & thing8 == 1 & thing9 == 1 ///
                & thing10 == 1 & thing11 == 1 & thing12 == 1 & thing13 == 1
destring issue13, replace                                                            
order noteff_other_reas_keys issue1 issue2 issue3 issue4 issue5 issue6 issue7 issue8 issue9 ///
                issue10 issue11 issue12 issue13                                          
gen OTH4=0
replace OTH4=1 if issue1==4 | issue2==4 | issue3==4 | issue4==4 | issue4==4 ///
                | issue5==4 | issue6==4 | issue7==4 | issue8==4 | issue9==4 | issue10==4 ///
                | issue11==4 | issue12==4 | issue13==4
gen OTH5=0
replace OTH5=1 if issue1==5 | issue2==5 | issue3==5 | issue4==5 | issue4==5 ///
                | issue5==5 | issue6==5 | issue7==5 | issue8==5 | issue9==5 | issue10==5 ///
                | issue11==5 | issue12==5 | issue13==5
gen OTH6=0
replace OTH6=1 if issue1==6 | issue2==6 | issue3==6 | issue4==6 | issue4==6 ///
                | issue5==6 | issue6==6 | issue7==6 | issue8==6 | issue9==6 | issue10==6 ///
                | issue11==6 | issue12==6 | issue13==6              
gen OTH7=0
replace OTH7=1 if issue1==7 | issue2==7 | issue3==7 | issue4==7 | issue4==7 ///
                | issue5==7 | issue6==7 | issue7==7 | issue8==7 | issue9==7 | issue10==7 ///
                | issue11==7 | issue12==7 | issue13==7               
gen OTH9=0
replace OTH9=1 if issue1==9 | issue2==9 | issue3==9 | issue4==9 | issue4==9 ///
                | issue5==9 | issue6==9 | issue7==9 | issue8==9 | issue9==9 | issue10==9 ///
                | issue11==9 | issue12==9 | issue13==9               
gen OTH11=0
replace OTH11=1 if issue1==11 | issue2==11 | issue3==11 | issue4==11 | issue4==11 ///
                | issue5==11 | issue6==11 | issue7==11 | issue8==11 | issue9==11 | issue10==11 ///
                | issue11==11 | issue12==11 | issue13==11
gen OTH12=0
replace OTH12=1 if issue1==12 | issue2==12 | issue3==12 | issue4==12 | issue4==12 ///
                | issue5==12 | issue6==12 | issue7==12 | issue8==12 | issue9==12 | issue10==12 ///
                | issue11==12 | issue12==12 | issue13==12                
gen OTH13=0
replace OTH13=1 if issue1==13 | issue2==13 | issue3==13 | issue4==13 | issue4==13 ///
                | issue5==13 | issue6==13 | issue7==13 | issue8==13 | issue9==13 | issue10==13 ///
                | issue11==13 | issue12==13 | issue13==13               
gen OTH17=0
replace OTH17=1 if issue1==17 | issue2==17 | issue3==17 | issue4==17 | issue4==17 ///
                | issue5==17 | issue6==17 | issue7==17 | issue8==17 | issue9==17 | issue10==17 ///
                | issue11==17 | issue12==17 | issue13==17                
gen OTH18=0
replace OTH18=1 if issue1==18 | issue2==18 | issue3==18 | issue4==18 | issue4==18 ///
                | issue5==18 | issue6==18 | issue7==18 | issue8==18 | issue9==18 | issue10==18 ///
                | issue11==18 | issue12==18 | issue13==18                
gen OTH19=0
replace OTH19=1 if issue1==19 | issue2==19 | issue3==19 | issue4==19 | issue4==19 ///
                | issue5==19 | issue6==19 | issue7==19 | issue8==19 | issue9==19 | issue10==19 ///
                | issue11==19 | issue12==19 | issue13==19               
gen OTH20=0
replace OTH20=1 if issue1==20 | issue2==20 | issue3==20 | issue4==20 | issue4==20 ///
                | issue5==20 | issue6==20 | issue7==20 | issue8==20 | issue9==20 | issue10==20 ///
                | issue11==20 | issue12==20 | issue13==20
gen OTH21=0
replace OTH21=1 if issue1==21 | issue2==21 | issue3==21 | issue4==21 | issue4==21 ///
                | issue5==21 | issue6==21 | issue7==21 | issue8==21 | issue9==21 | issue10==21 ///
                | issue11==21 | issue12==21 | issue13==21
gen OTH22=0
replace OTH22=1 if issue1==22 | issue2==22 | issue3==22 | issue4==22 | issue4==22 ///
                | issue5==22 | issue6==22 | issue7==22 | issue8==22 | issue9==22 | issue10==22 ///
                | issue11==22 | issue12==22 | issue13==22                
gen OTH42=0
replace OTH42=1 if issue1==42 | issue2==42 | issue3==42 | issue4==42 | issue4==42 ///
                | issue5==42 | issue6==42 | issue7==42 | issue8==42 | issue9==42 | issue10==42 ///
                | issue11==42 | issue12==42 | issue13==42               
gen OTH43=0
replace OTH43=1 if issue1==43 | issue2==43 | issue3==43 | issue4==43 | issue4==43 ///
                | issue5==43 | issue6==43 | issue7==43 | issue8==43 | issue9==43 | issue10==43 ///
                | issue11==43 | issue12==43 | issue13==43
gen OTH44=0
replace OTH44=1 if issue1==44 | issue2==44 | issue3==44 | issue4==44 | issue4==44 ///
                | issue5==44 | issue6==44 | issue7==44 | issue8==44 | issue9==44 | issue10==44 ///
                | issue11==44 | issue12==44 | issue13==44                
gen OTH57=0
replace OTH57=1 if issue1==57 | issue2==57 | issue3==57 | issue4==57 | issue4==57 ///
                | issue5==57 | issue6==57 | issue7==57 | issue8==57 | issue9==57 | issue10==57 ///
                | issue11==57 | issue12==57 | issue13==57                
gen OTH75=0
replace OTH75=1 if issue1==75 | issue2==75 | issue3==75 | issue4==75 | issue4==75 ///
                | issue5==75 | issue6==75 | issue7==75 | issue8==75 | issue9==75 | issue10==75 ///
                | issue11==75 | issue12==75 | issue13==75
                gen OTH76=0
replace OTH76=1 if issue1==76 | issue2==76 | issue3==76 | issue4==76 | issue4==76 ///
                | issue5==76 | issue6==76 | issue7==76 | issue8==76 | issue9==76 | issue10==76 ///
                | issue11==76 | issue12==76 | issue13==76
gen OTH77=0
replace OTH77=1 if issue1==77 | issue2==77 | issue3==77 | issue4==77 | issue4==77 ///
                | issue5==77 | issue6==77 | issue7==77 | issue8==77 | issue9==77 | issue10==77 ///
                | issue11==77 | issue12==77 | issue13==77
replace entity_level=1 if OTH77==1 | OTH76==1 |  OTH11==1 | OTH13==1 | OTH18==1 | OTH21==1 | OTH44==1 
save sox404_prelim103, replace

use sox404_prelim103, clear                            
drop test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 test11 test12 ///
                test13 test14 test15 test16 test17 test18 test19 test20 test21 test22 ///
                test23 test24 test25 test26 test27 test28 test29 test30 test31 test32 ///
                test33 test34 test35 test36 test37 test38 test39 test40 test41 test42 ///
                thing1 thing2 thing3 thing4 thing5 thing6 thing7 thing8 thing9 thing10 ///
                thing11 thing12 thing13 thing14 testa testb testc testd teste testf testg ///
                testh testi testj testk testl testm testn testo testp testq testr tests ///
                testt testu testv testw testx testy testz testaa testbb testcc testdd ///
                testee testff testgg testhh testii testjj issue1 issue2 issue3 issue4 ///
                issue5 issue6 issue7 issue8 issue9 issue10 issue11 issue12 issue13

drop noteff_other noteff_other_reas_keys noteff_other_reas_phr
save sox404_final, replace           
use sox404_final, clear

gen sum_IC = IC3+IC8+IC10+IC14+IC15+IC16+IC23+IC24+IC25+IC26+IC27+IC28+IC29 ///
                +IC30+IC31+IC32+IC33+IC34+IC35+IC36+IC38+IC39+IC40+IC41+IC47+IC48+IC68 ///
                +IC73+IC80+IC81
                
gen sum_EXE = EXE1+EXE2+EXE45+EXE46+EXE71+EXE78+EXE79 
                
gen sum_FF = FF3+FF14+FF15+FF16+FF24+FF27+FF28+FF29+FF30+FF32+FF33+FF35+FF36 ///
                +FF38+FF39+FF40+FF41+FF68

gen sum_ERR = ERR28+ERR35+ERR39

gen sum_OTH = OTH4+OTH5+OTH6+OTH7+OTH9+OTH11+OTH12+OTH13+OTH17+OTH18+OTH19 ///
                +OTH20+OTH21+OTH22+OTH42+OTH43+OTH44+OTH57+OTH75+OTH76+OTH77
                
gen sum_total = sum_IC + sum_EXE + sum_FF + sum_ERR + sum_OTH

gsort -sum_total -count_weak   

order sum_total count_weak

corr sum_total count_weak if count_weak != 0
sum count_weak if count_weak != 0
sum count_weak if count_weak != 0 & auditor_fkey <= 4
sum count_weak if count_weak != 0 & auditor_fkey > 4
sum sum_total if count_weak != 0
sum sum_total if count_weak != 0 & auditor_fkey <= 4
sum sum_total if count_weak != 0 & auditor_fkey > 4
sum sum_IC if count_weak != 0
sum sum_IC if count_weak != 0 & auditor_fkey <= 4
sum sum_IC if count_weak != 0 & auditor_fkey > 4
sum sum_EXE if count_weak != 0
sum sum_EXE if count_weak != 0 & auditor_fkey <= 4
sum sum_EXE if count_weak != 0 & auditor_fkey > 4
sum sum_FF if count_weak != 0
sum sum_FF if count_weak != 0 & auditor_fkey <= 4
sum sum_FF if count_weak != 0 & auditor_fkey > 4
sum sum_ERR if count_weak != 0
sum sum_ERR if count_weak != 0 & auditor_fkey <= 4
sum sum_ERR if count_weak != 0 & auditor_fkey > 4
sum sum_OTH if count_weak != 0
sum sum_OTH if count_weak != 0 & auditor_fkey <= 4
sum sum_OTH if count_weak != 0 & auditor_fkey > 4
gen MW = 0
replace MW = 1 if OTH4==1 | OTH5==1 | OTH6==1 | OTH7==1 | OTH9==1 | OTH11==1 ///
                | OTH12==1 | OTH13==1 | OTH17==1 | OTH18==1 | OTH19==1 | OTH20==1 | OTH21==1 ///
                | OTH22==1 | OTH42==1 | OTH43==1 | OTH44==1 | OTH57==1 | OTH75==1 | OTH76==1 ///
                | OTH77==1             
rename sum_OTH sum_MWproblems    
gen ActgFail = 0
replace ActgFail = 1 if IC3==1 | IC8==1 | IC10==1 | IC14==1 | IC15==1 | IC16==1 ///
                | IC23==1 | IC24==1 | IC25==1 | IC26==1 | IC27==1 | IC28==1 | IC29==1 ///
                | IC30==1 | IC31==1 | IC32==1 | IC33==1 | IC34==1 | IC35==1 | IC36==1 ///
                | IC38==1 | IC39==1 | IC40==1 | IC41==1 | IC47==1 | IC48==1 | IC68==1 ///
                | IC73==1 | IC80==1 | IC81==1              
rename sum_IC sum_ActgFailProblems
count if MW == 1 & ActgFail != 1
count if MW != 1 & ActgFail == 1

gen Fraud = 0
replace Fraud = 1 if FF3==1 | FF14==1 | FF14==1 | FF15==1 | FF16==1 | FF24==1 ///
                | FF27==1 | FF28==1 | FF29==1 | FF30==1 | FF32==1 | FF33==1 | FF35==1 ///
                | FF36==1 | FF38==1 | FF39==1 | FF40==1 | FF41==1 | FF68==1               
rename sum_FF sum_FraudProblems
gen MW_only = 0
replace MW_only = 1 if MW==1 & ActgFail==0 & Fraud==0
gen AF_only = 0
replace AF_only = 1 if MW==0 & ActgFail==1 & Fraud==0
drop AF_only
gen fraud_only = 0
replace fraud_only = 1 if MW==0 & ActgFail==0 & Fraud==1
drop fraud_only
gen MW_AF = 0
replace MW_AF = 1 if MW==1 & ActgFail==1 & Fraud==0
gen MW_fraud = 0
replace MW_fraud = 1 if MW==1 & ActgFail==0 & Fraud==1
gen AF_fraud = 0
replace AF_fraud = 1 if MW==0 & ActgFail==1 & Fraud==1
drop AF_fraud
gen all3 = 0
replace all3 = 1 if MW==1 & ActgFail==1 & Fraud==1        
save sox404_final2, replace
use sox404_final2, clear
gen MW_govern = 0
replace MW_govern = 1 if OTH7==1 | OTH11==1 | OTH13==1 | OTH18==1 | OTH20==1
gen MW_pers_train = 0
replace MW_pers_train = 1 if OTH21==1 | OTH42==1 | OTH44==1
gen MW_regulatory = 0
replace MW_regulatory = 1 if OTH6==1 | OTH19==1
gen MW_IT = 0
replace MW_IT = 1 if OTH22==1
gen MW_disc = 0
replace MW_disc = 1 if OTH9==1
gen MW_actgproc = 0
replace MW_actgproc = 1 if OTH12==1 | OTH17==1 | OTH76==1 | OTH77==1 | OTH57==1 | OTH75==1
gen MW_auditadj = 0
replace MW_auditadj = 1 if OTH4==1
gen MW_restate = 0
replace MW_restate = 1 if OTH5==1 | OTH43==1
save sox404_final3, replace
use sox404_final3, clear
gen AF_tax = 0
replace AF_tax = 1 if IC41==1
gen AF_revrec = 0
replace AF_revrec = 1 if IC39==1
gen AF_classif = 0
replace AF_classif = 1 if IC10==1 | IC23==1 | IC25==1 | IC36==1
gen AF_unspecified = 0
replace AF_unspecified = 1 if IC68==1
gen AF_operations = 0
replace AF_operations = 1 if IC3==1 | IC14==1 | IC15==1 | IC16==1 | IC28==1 | IC29==1 ///
                | IC31==1 | IC32==1 | IC33==1 | IC73==1 | IC80==1 | IC81==1
gen AF_debt = 0
replace AF_debt = 1 if IC34==1 | IC47==1
gen AF_foreign = 0
replace AF_foreign = 1 if IC24==1 | IC38==1
gen AF_ma = 0
replace AF_ma = 1 if IC35==1
gen AF_disc = 0
replace AF_disc = 1 if IC26==1 | IC48==1 | IC40==1
gen AF_subsid = 0
replace AF_subsid = 1 if IC8==1
gen AF_execcomp = 0
replace AF_execcomp = 1 if IC27==1
gen AF_fas133 = 0
replace AF_fas133 = 1 if IC30==1
save sox404_final4, replace
use sox404_final4, clear
keep auditor_fkey fye_ic_op count_weak   cik sum_MWproblems entity_level ///
                sum_ActgFailProblems MW ActgFail Fraud MW_only MW_AF MW_fraud all3 sum_total         
gen process_level=1
replace process_level=0 if entity_level==1
gen fyear = year(fye_ic_op)
gen date = 100*month(fye_ic_op)+day(fye_ic_op)
replace fyear= fyear-1 if date <=620
drop date
gsort cik fyear -count_weak
drop if count_weak==0
gsort cik fyear
gen cik1=cik
destring cik1, replace
destring cik, replace
save sox404_final5, replace    
//merge this onto the cleaned 404 data set
use sox404_final5, clear
gsort  cik fyear -count_weak
order cik fyear count_weak
duplicates drop cik fyear, force
merge 1:1 cik fyear using sox404clean
drop if _merge==1
replace entity_level=0 if missing(entity_level)
//only keep info about mat weaknesses and then merge on to opinions data in next step
keep if _merge==3
drop _merge
drop cik1
save MatWeakPreMerge, replace

//merge material weakness data onto fees and opinions data and create variable to measure 1 if yes 0 if not for weakness
use AuditFeesOpinions, clear 
merge 1:1 cik fyear auditor_fkey using MatWeakPreMerge
drop if _merge==2
drop _merge
replace count_weak=0 if missing(count_weak)
replace weakness=1 if count_weak>0 
replace weakness=0 if missing(count_weak)
replace weakness=0 if missing(weakness)
replace MW_fraud=0 if missing(MW_fraud)
replace entity_level=0 if missing(entity_level)
//
save feesopinions, replace
use sox404clean, clear
merge 1:1 cik fyear using feesopinions
replace IC_audit=0 if missing(IC_audit)
keep cik fyear IC_audit weakness count_weak entity_level  MW_fraud 
replace count_weak=0 if missing(count_weak)
replace entity_level=0 if missing(entity_level)
replace weakness=0 if missing(weakness)
replace MW_fraud=0 if missing(MW_fraud)
save mergetofees, replace
//calculate partner weakness on full set. Some of these wont hit final sample due to lack of control variables but need to understand which partners are issuing observable MWs and code them as a "AICO partner"
//use partner file from before and merge to file with opinions fees and MW detail
use partner_changes_tomerge, clear
keep engagementpartnerid fyear cik 
merge 1:1 cik fyear using mergetofees
keep if _merge==3
bysort engagementpartnerid fyear: egen partner_weakness_count=sum(weakness) 
gen partner_weakness=0
replace partner_weakness=1 if partner_weakness_count>0
drop _merge
bysort engagementpartnerid fyear: egen partner_weakness_number=sum(count_weak) 
bysort engagementpartnerid fyear: egen partner_elcs=sum(entity_level) 
gen partner_weakness_elc=0
replace partner_weakness_elc=1 if partner_elcs>0 
save mergetofees, replace 

//create office level variables in case need them later 
use AuditFeesOpinions, clear
merge 1:1 cik fyear using mergetofees
keep if _merge==3
drop _merge
save auditoffice, replace
rename *, lower
order cik fyear auditor_fkey
//generate audit office as city and state where auditor is located
egen location = concat(auditor_city auditor_state_name), punct(",")
gsort auditor_fkey location fyear
egen audit_office=group(auditor_fkey location)
//gen public float variable
gen public_float=curr_price_close*curr_tso
///gen accel_filer=0
//replace accel_filer=1 if is_accel_filer==1
// generate office level variables 
bysort audit_office fyear: egen ao_gco_count=total(gco)
bysort audit_office fyear: egen ao_ic_client_count=total(ic_audit)
bysort audit_office fyear: egen ao_client_count=count(cik)
//bysort audit_office fyear: egen ao_accel_filer_count=total(accel_filer)
gen nas_client=0
replace nas_client=1 if non_audit_fees>0
bysort audit_office fyear: egen ao_nas_client_count=total(nas_client)
bysort audit_office fyear: egen ao_icmw_count=total(weakness)
gen ic_audit_fees=0
replace ic_audit_fees=audit_fees if ic_audit==1
bysort audit_office fyear: egen ao_icaudit_fees=total(ic_audit_fees)
bysort audit_office fyear: egen ao_tax_fees=total(tax_fees)
bysort audit_office fyear: egen ao_audrel_fees=total(audit_related_fees)
bysort audit_office fyear: egen ao_audit_fees=total(audit_fees)
bysort audit_office fyear: egen ao_nonaudit_fees=total(non_audit_fees)
replace entity_level=0 if missing(entity_level)
bysort audit_office fyear: egen ao_elc_weakness=total(entity_level)
bysort audit_office fyear: egen ao_icmw_number_weaknesses=total(count_weak)
save feesopinions1, replace
sort audit_office fyear
duplicates drop audit_office fyear,force
//create office growth measures in case we want to do anything with these vs partner growth later on 
xtset audit_office fyear
gen f_ao_client_count=f.ao_client_count
gen f2_ao_client_count=f2.ao_client_count
gen f_ao_audit_fees=f.ao_audit_fees
gen f2_ao_audit_fees=f2.ao_audit_fees
gen one_year_client_growth=(f_ao_client_count-ao_client_count)/ao_client_count
gen two_year_client_growth=(f2_ao_client_count-ao_client_count)/ao_client_count
gen one_year_fee_growth=(f_ao_audit_fees-ao_audit_fees)/ao_audit_fees
gen two_year_fee_growth=(f2_ao_audit_fees-ao_audit_fees)/ao_audit_fees
keep audit_office fyear f_ao_client_count f2_ao_client_count f_ao_audit_fees f2_ao_audit_fees one_year_client_growth two_year_client_growth one_year_fee_growth two_year_fee_growth
//merge office growth on to previous data
merge 1:m audit_office fyear using feesopinions1
drop _merge
gen auditor_city1= upper(auditor_city)
statastates, name(auditor_state_name)
drop _merge
gen auditor_city2= subinstr(auditor_city1," ","",.)
gen auditorlocation= auditor_city2 + state_abbrev
rename auditorlocation city_state
save feesopinions1, replace
//merge to MSA data
use MSA, clear
//add in the missing MSAs for the biggest missing cities 
merge 1:m city_state using feesopinions1
drop if _merge==1
replace MSA=45300 if city_state=="TEMPLETERRACEFL"
replace MSA=16980 if city_state=="TINLEYPARKIL"
replace MSA=47900 if city_state=="TYSONSVA"
replace MSA=33100 if city_state=="COCONUTCREEKFL"
replace MSA=39140 if city_state=="PRESCOTTVALLEYAZ"
replace MSA=26900 if city_state=="NOBLESVILLEIN"
replace MSA=19820 if city_state=="FARMINGTONMI"
replace MSA=18140 if city_state=="GRANDVIEWHEIGHTSOH"
replace MSA=35620 if city_state=="BAYVILLENJ"
replace MSA=31100 if city_state=="NEWHALLCA"
replace MSA=45300 if city_state=="GULFPORTFL"
replace MSA=33100 if city_state=="SOUTHMIAMIFL"
replace MSA=33100 if city_state=="PRINCETONFL"
replace MSA=41860 if city_state=="PLEASANTHILLCA"
replace MSA=35620 if city_state=="RIVERVALENJ"
replace MSA=39100 if city_state=="HYDEPARKNY"
order cik fyear
destring cik, replace
gsort auditor_fkey MSA fyear
egen office_msa=group(auditor_fkey MSA)
drop if missing(office_msa)
//gen number of auditor offices in MSA and in city for competition measures/ cuts later
bysort MSA fyear: egen msa_office_count=nvals(office_msa)
bysort city_state fyear: egen city_office_count=nvals(audit_office)
drop _merge
save aofeesopinions, replace
//merge these data to partner data and then merge to compustat and then restatement data once we get the datadate added from compustat
use partner_changes_tomerge, clear
merge 1:1 cik fyear using aofeesopinions
keep if _merge==3
drop _merge 
//count clients and fees and characteristics by partner year
bysort engagementpartnerid fyear: egen partner_num_clients=nvals(cik)
bysort engagementpartnerid fyear: egen partner_404b_count=sum(ic_audit) 
//non ic opinon clients dont receive an ic audit in line with 404b rules
gen non_ic_audit=0
replace non_ic_audit=1 if ic_audit==0
bysort engagementpartnerid fyear: egen partner_non404b_count=sum(non_ic_audit) 
bysort engagementpartnerid fyear: egen partner_404b_fees=sum(ic_audit_fees) 
//generate non ic fees by multiplying these opinions by audit fees
gen non_ic_fees=non_ic_audit*audit_fees
bysort engagementpartnerid fyear: egen partner_non404b_fees=sum(non_ic_fees) 
bysort engagementpartnerid fyear: egen partner_nonaudit_fees=sum(non_audit_fees) 
bysort engagementpartnerid fyear: egen partner_audit_fees=sum(audit_fees) 
gen ln_afee=ln(1+audit_fees)
bysort engagementpartnerid fyear: egen partner_lnaudit_fees=sum(ln_afee) 
bysort engagementpartnerid fyear: egen partner_num_offices=nvals(audit_office) 	
bysort engagementpartnerid fyear: egen avg_office_size=mean(ao_audit_fees)
gen sic1=substr(sic_code_fkey,1,1)
destring sic1, replace
bysort engagementpartnerid fyear: egen partner_num_industries_sic1=nvals(sic1) 
bys engagementpartnerid fyear: egen avg_fees_per_partner=mean(audit_fees)
bys engagementpartnerid fyear: gen avg_404fees_per_partner=partner_404b_fees/partner_404b_count
//if no 404b clients then the average 404 fees per client is just 0
replace avg_404fees_per_partner=0 if partner_404b_count==0
bys engagementpartnerid fyear: gen avg_non404fees_per_partner=partner_non404b_fees/partner_non404b_count
//if non n404b clients then average n404 fees per client is just 0
replace avg_non404fees_per_partner=0 if partner_non404b_count==0
bys engagementpartnerid fyear: egen partner_gcos=sum(gco)  
save partnerprecompustat1, replace 

use partnerprecompustat1, clear
//keep partner level stuff at time t then generate year ahead variables and take the difference to compute changes in portfolios 
keep engagementpartnerid fyear partner_weakness_number partner_weakness_count partner_elcs  partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos  
duplicates drop engagementpartnerid fyear, force
xtset engagementpartnerid fyear
	
xtset engagementpartnerid fyear
foreach var in partner_weakness_number partner_weakness_count partner_elcs  partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos {
 	gen f_`var'=f.`var'
}
//if missing future 404b or future non 404b clients then this means they have 0 of those clients in that year so replace missings here with 0s
//these observations will stay with the total average measure because you only need one of the two buckets of clients for that /// so if they have 0 clients then this will drop out as divide by 0 in the change in avg measures/// note that measures still work (at least on base model) without this design decision
replace f_avg_non404fees_per_partner=0 if missing(f_avg_non404fees_per_partner)
replace f_avg_404fees_per_partner=0 if missing(f_avg_404fees_per_partner)
replace f_partner_404b_fees=0 if missing(f_partner_404b_fees)
replace f_partner_non404b_fees=0 if missing(f_partner_non404b_fees)
replace f_partner_non404b_count=0 if missing(f_partner_non404b_count)
replace f_partner_404b_count=0 if missing(f_partner_404b_count)

gen elc_proportion=partner_elcs/partner_weakness_number
replace elc_proportion=0 if missing(elc_proportion)
foreach var in partner_weakness_number partner_weakness_count partner_elcs  partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos{
	gen chg_`var'=f_`var'-`var' 
}

//merge changes to dataset to compile  file to merge with compustat for controls
merge 1:m engagementpartnerid fyear using partnerprecompustat1
drop _merge
save partnerprecompustat2, replace
///generate engagement partner history of icmw
keep engagementpartnerid fyear partner_weakness
duplicates drop engagementpartnerid fyear, force
xtset  engagementpartnerid fyear
gen py_partner_weakness=l.partner_weakness
gen py2_partner_weakness=l2.partner_weakness
gen py3_partner_weakness=l3.partner_weakness
gen py4_partner_weakness=l4.partner_weakness
gen py5_partner_weakness=l5.partner_weakness
gen partner_weakness_5year=partner_weakness+py_partner_weakness+py2_partner_weakness+py3_partner_weakness+py4_partner_weakness
gen partner_weakness_3year=partner_weakness+py_partner_weakness+py2_partner_weakness
gen partner_weakness_2year=partner_weakness+py_partner_weakness
merge 1:m engagementpartnerid fyear using partnerprecompustat2
drop _merge
save partnerprecompustat3, replace

//now compute changes in partner portfolios 
// all of these are divided by the TOTAL avg fees at avg level , total fees for pct change in fees and then total clients for pct change in clients 
gen pct_change_avg_fees=chg_avg_fees_per_partner/avg_fees_per_partner
gen pct_change_avg_non404bfees=chg_avg_non404fees_per_partner/avg_fees_per_partner
gen pct_change_avg_404bfees=chg_avg_404fees_per_partner/avg_fees_per_partner
	
gen pct_change_audit_fees=chg_partner_audit_fees/partner_audit_fees
gen pct_change_404_fees=chg_partner_404b_fees/partner_audit_fees
gen pct_change_non404_fees=chg_partner_non404b_fees/partner_audit_fees

gen total_clients=partner_404b_count+partner_non404b_count
gen pct_change_audit_clients=(chg_partner_404b_count+chg_partner_non404b_count)/total_clients
gen pct_change_404_clients=chg_partner_404b_count/total_clients
gen pct_change_non404_clients=chg_partner_non404b_count/total_clients
gen partner_bign=1 if bign==1
replace partner_bign=0 if bign==0
save partnerprecompustat4, replace

//now merge with compustat to get control variables for other tests
use "compustatraw20230612.dta", clear
destring cik, replace
drop if missing(cik)
gsort cik fyear -at
duplicates drop cik fyear, force 
save Compustat, replace
use aofeesopinions, clear
merge 1:1 cik fyear using Compustat
keep if _merge==3
drop _merge
// check for ipo clients
gen ipo=ipodate<=datadate & ipodate>=datadate-365
tab ipo
bysort audit_office fyear: egen ao_ipo=total(ipo)
gen ipo_fee= ipo*audit_fees
bysort audit_office fyear: egen ao_ipo_fees=total(ipo_fee)
///calculate mve measure of visibility
gen mve=prcc_f*csho
//gen sic2
gen sic2=substr(sic,1,2)
destring sic2, replace
//gen sic1
gen sic1=substr(sic,1,1)
destring sic1, replace
//gen financial industries
gen financial1=0
replace financial1=1 if sic2>=60 &sic2<=69
//reg industries 
gen regulated=0
replace regulated=1 if sic2>43 & sic2<50
replace regulated=1 if sic2>59 & sic2<70
// gen foreign indicator
gen foreign1=0
replace foreign1=1 if fic!="USA"
replace foreign1=1 if auditor_country!="USA"
//intangibles and foreign obs 
gen intangibles = intan/at
gen forops=0
  replace forops=1 if cicurr!=0
//busy season and buckets for accel filers
gen busy=0
replace busy=1 if fyr==11|fyr==12|fyr==1
gen sm_accel_filer=0
replace sm_accel_filer=1 if is_accel_filer==2 & mkvalt>75 & mkvalt<700
replace sm_accel_filer=1 if is_accel_filer==1 & accel_filer_large==0
gen lg_accel_filer=0
replace lg_accel_filer=1 if accel_filer_large==2 & mkvalt>=700
replace lg_accel_filer=1 if accel_filer_large==1
//gen lag and forward variables  
gsort cik fyear
xtset cik fyear
//drop if missing(lt)
gen at_lag=l.at
gen at_forward=f.at
gen AA =(at+at_lag)/2
gen ROA=ni/AA
gen roa=ni/at_lag
winsor2 roa
winsor2 ROA
gen ret_on_assets=ib/AA
//drop if missing(AA)
//drop if missing(ROA)
gen leverage= lt/at
gen client_at_growth=(at-at_lag)/at_lag
//drop if missing(client_at_growth)
//generate audit firm tenure variable by long vs short , long if over four years 
bysort cik auditor_fkey: egen tenurestart=min(fyear)
by cik auditor_fkey: gen test=0 if fyear[_n]!=fyear[_n+1]-1
gen tenure=fyear-tenurestart
gen long_tenure=0
replace long_tenure=1 if tenure>3
gen newauditor=0
replace newauditor=1 if tenure==0
//gen lag and forward values 
xtset cik fyear
gen net_assets=ni/(at-lt)
gen net_assets_lag=l.net_assets
gen net_assets_f=f.net_assets
gen net_assets_f2=f2.net_assets
gen at_f=f.at
gen at_f2=f2.at
gen ib_lag=l.ib
gen ib_f=f.ib
gen ib_f2=f2.ib
gen ni_lag=l.ni
gen ni_f=f.ni
gen ni_f2=f2.ni
gen invt_lag=l.invt
gen invt_f=f.invt
gen invt_f2=f2.invt
gen rect_lag=l.rect
gen rect_f=f.rect
gen rect_f2=f2.rect
gen revt_lag=l.revt
gen revt_f=f.revt
gen revt_f2=f2.revt
gen che_lag=l.che
gen che_f=f.che
gen che_f2=f2.che
gen lt_lag=l.lt
gen lt_f=f.lt
gen lt_f2=f2.lt
//gen loss
gen loss=0
replace loss=1 if ni<0
//acquisitions
gen acquisition=0
replace acquisition=1 if aqc<0 | aqc>0
// generate expert variable as percentage of national fees in industry 
sort sic2 fyear
bysort sic2 fyear: egen national_ind_fees=total(audit_fees)
bysort sic2 auditor_fkey fyear: egen auditor_industry_fees=total(audit_fees)
gen nat_expert=auditor_industry_fees/national_ind_fees
// generate expert variable as percentage of MSA fees in industry 
bysort MSA sic2 fyear:egen msa_industry_total=total(audit_fees)
bysort sic2 audit_office fyear: egen local_industry_fees=total(audit_fees)
gen local_expert=local_industry_fees/msa_industry_total
//generate market leaders as those with max national or local share 
bysort sic2 fyear: egen nat_leader=max(nat_expert)
bysort MSA sic2 fyear: egen local_leader=max(local_expert)
//expert if MSA office is local leader 
generate expert=0
replace expert=1 if  local_leader==local_expert
///generate msa numbers of clients and audit fees
bysort office_msa fyear: egen  msa_office_client_count= count(cik)
bysort office_msa fyear: egen  msa_office_afee_total= total(audit_fees)
//count clients in MSA
bysort MSA fyear: egen  msa_client_count= count(cik)
//count fees in msa
bysort MSA fyear: egen  msa_afee_total= total(audit_fees)
//gen lag datadate for restatement stuff later  
 xtset cik fyear
gen lag_datadate=l.datadate 
//year end clients 
gen year_end = 0
replace year_end = 1 if fyr==12 | fyr==1 | fyr==2 | fyr==3
gen neg_bv = 0
replace neg_bv = 1 if ceq<0
//altman z
replace act=0 if act==.
replace lct=0 if lct==.
gen x1 = (act - lct)/at
gen x2 = re/at
gen x3 = ebit/at
gen x4 = (csho*prcc_f)/lt
gen x5 = revt/at
gen Z = (1.2*x1) + (1.4*x2) + (3.3*x3) + (.6*x4) + (1*x5)
drop x1 x2 x3 x4 x5
gen altman = Z*-1
gen cash=che/at
gen ln_at=ln(1+at)
gen invrec=(invt+rect)/at
//rsst accruals
gen working_capital=(act-che)-(lct-dlc)
gen iva=ivao+ivaeq
gen btm= ceq/mve
gen mtb = mve/ceq
gen lnmve = log(mve)
gen lev=lt/at
gen afiler=0
replace afiler=1 if mve>75
//profitability measures 
xtset cik fyear
gen rev_growth = (revt-l.revt)/(l.revt)
gen avg_at =(at+at_lag)/2
gen profitability=ib/avg_at
gen exfinance=(sstk+dltis)/avg_at 
drop cfo
//generate cash flow variable
gen cfo=oancf/avg_at
//size in fees and assets
gen ln_afee=ln(1+audit_fees)
gen clientsize=ln_at
winsor2 client_at_growth invrec leverage ln_at cash 

//mismatch variable following shu
gen proper = .

forvalues i=2016/2022{
probit bign  ln_at acquisition exfinance profitability mtb if fyear==`i'
_predict prop, xb
replace proper=prop if fyear==`i'
drop prop
}

drop rank
egen rank= xtile(proper), by(fyear) nq(20)
bysort fyear rank: egen big4p= mean(bign)
gen cutoff = big4p-.5 if big4p>.5

egen closest = min(cutoff), by(fyear)
gen cut= closest== cutoff
gen cut2 = cut*rank
egen cutrank=max(cut2), by(fyear)
drop big4p cutoff closest cut cut2

gen match1=.
replace match1=0 if rank<cutrank
replace match1=1 if rank>cutrank

gen mismatch= abs(bign-match1)
replace mismatch=0 if match1==.
drop rank cutrank match1

//client influence as a proportion of office fees 
gen client_influence= audit_fees/ ao_audit_fees
winsor2 client_influence
//litigious industries
gen litigious=0
replace litigious=1 if sic>"2832" & sic<"2838"
replace litigious=1 if sic>"8730" & sic<"8735"
replace litigious=1 if sic>"3569" & sic<"3578"
replace litigious=1 if sic>"7369" & sic<"7374"
replace litigious=1 if sic>"3599" & sic<"3675"
replace litigious=1 if sic>"5199" & sic<"5962"
save  compustatAAmerged3, replace
//merge compustat variables onto partner variables 
use partnerprecompustat4.dta, clear
merge 1:1 cik fyear using compustatAAmerged3
keep if _merge==3
drop _merge
//gen addl partner level variables 
bysort engagementpartnerid fyear: egen partner_expert=sum(expert)
bysort engagementpartnerid fyear: egen partner_loss=sum(loss)
bysort engagementpartnerid fyear: egen partner_ma=sum(acquisition)
//data before restatement merge
save partner_pre_res1, replace
//now merge all this on to restatement data and then start tests 
// add restatements
use "restatements20230612.dta", clear
rename *, lower
rename company_fkey cik
destring cik, replace
//keep if restatement is accounting or fraud 
keep if res_accounting==1 | res_fraud==1
rename file_date file_date_restate  
//indicator for big r is reported through 8k
gen big= 0
replace big = 1 if form_fkey == "8-K"
duplicates drop cik file_date_restate, force
//join onto dataset to capture fyears for when the restatement occurred or was announced
joinby cik using compustatAAmerged3, unmatched(master)
//any r
gen res_ann = 0
replace res_ann = 1 if file_date_restate > lag_datadate & file_date_restate <= datadate & datadate!=.	
//big r 
gen res_ann_big = 0
replace res_ann_big = 1 if file_date_restate > lag_datadate & file_date_restate <= datadate & datadate!=. & big==1
keep res_ann res_ann_big cik datadate  res_adverse res_improves file_date_aud_fkey
sort cik datadate
gsort cik datadate -res_ann 
drop if missing(datadate)
duplicates drop cik datadate, force
merge 1:1 cik datadate using compustatAAmerged3
replace res_ann=0 if _merge==2
replace res_ann_big=0 if missing(res_ann_big)
drop _merge
save mergedrestatement, replace
//generate misstatement indicators (above was announcement indicators)
use "restatements20230612.dta", clear
rename *, lower
rename company_fkey cik
destring cik, replace
gen bigr= 0
replace bigr = 1 if form_fkey == "8-K"
keep if res_accounting==1 | res_fraud==1
rename res_begin_date res_begin
rename res_end_date res_end
keep cik bigr  res_begin res_end 
save misstate, replace
use mergedrestatement, clear
joinby cik using misstate, unmatched(master)
gen misstate = 0
replace misstate = 1 if datadate >= res_begin & datadate <= res_end
gen misstate_bigr = 0
replace misstate_bigr = 1 if datadate >= res_begin & datadate <= res_end & bigr==1
egen group = group(cik fyear)
egen max_misstate = max(misstate), by(group)
drop misstate group
rename max_misstate misstate
egen group = group(cik fyear)
egen max_mistbigr = max(misstate_bigr), by(group)
drop misstate_bigr group
rename max_mistbigr misstate_bigr
duplicates drop cik fyear, force
drop _merge
drop bigr  res_begin res_end
keep cik fyear res_ann res_ann_big misstate misstate_bigr
duplicates drop cik fyear, force
save mergedrestatement, replace
use mergedrestatement, clear
merge 1:1 cik fyear using compustatAAmerged3
drop if _merge==2
replace res_ann =0 if missing(res_ann)
replace res_ann_big =0 if missing(res_ann_big)
replace misstate_bigr =0 if missing(misstate_bigr)
replace misstate =0 if missing(misstate)
drop _merge 
save compustatAAmerged4, replace
//merge back to data for partner level restatement vars
use compustatAAmerged4, clear
merge 1:1 cik fyear using partner_pre_res1
keep if _merge==3
save partnerweaknres, replace 
bysort engagementpartnerid fyear: egen res_ann_partner=sum(res_ann)
gen partner_resann=0
replace partner_resann=1 if res_ann_partner>0
xtset cik fyear
bysort engagementpartnerid fyear: egen res_ann_big_partner=sum(res_ann_big)
gen partner_resann_big=0
replace partner_resann_big=1 if res_ann_big_partner>0
drop _merge
save partnerfortesting, replace 
//this file has all variables we need for initial testing
use partnerfortesting, clear
sort engagementpartnerid fyear
duplicates drop engagementpartnerid fyear, force
xtset engagementpartnerid fyear
keep engagementpartnerid fyear partner_resann_big partner_resann
gen py_partner_resann=l.partner_resann
gen py_partner_resann_big=l.partner_resann_big
replace py_partner_resann=0 if missing(py_partner_resann)
replace py_partner_resann_big=0 if missing(py_partner_resann_big)
merge 1:m engagementpartnerid fyear using partnerfortesting
drop _merge
save partnerfortesting2, replace 
use partnerfortesting2, clear

///global client controls///
gen average_assets=(at_lag+at)/2
winsor2 average_assets
winsor2 ib
//calculate roa following aobdia and petacchi as this paper is closest to ours 
gen roa2= ib_w/average_assets_w

//if switch audit firm so can exclude these clients from client level analysis becuase they are going to mechanically change partners if they leave the firm
sort cik fyear
xtset cik fyear
gen f_auditor_fkey=f.auditor_fkey
gen audit_firm_switch=0
replace audit_firm_switch=1 if f_auditor_fkey!=auditor_fkey
replace audit_firm_switch=. if missing(f_auditor_fkey)
//we dont need fyear 2015 because we begin in 2016
drop if fyear==2015
reg partner_switch partner_weakness  i.fyear i.sic1 if fyear>2015  & foreign1==0 & fyear<2022 , robust cluster(cik)	
drop      cash_w  client_at_growth_w  ln_at_w   invrec_w leverage_w   
//winsorize controls if in sample
winsor2   cash  client_at_growth  ln_at   invrec leverage   roa2 if e(sample)

//we have fyear 2016, 2017,2018,2019, 2020, 2021 capturing changes through 2022 bc 2021 partner change means changed from 2021 to 2022 ... 2021-2022 incomplete because delay in AA through WRDS so need to pull additional year of data to make complete
//
	 
//table 4 main partner portfolio table 
//only include one observation per partner year 
bysort engagementpartnerid fyear: gen unique_partner1=_n
//winsorize controls
winsor2 partner_audit_fees  partner_expert partner_gcos partner_loss partner_ma   partner_num_industries_sic1 partner_num_offices
global partner_controls "partner_resann partner_bign partner_audit_fees_w  partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "
//winsorize dependent variables 
winsor2 pct_change_avg_fees pct_change_avg_non404bfees pct_change_avg_404bfees pct_change_audit_fees pct_change_404_fees pct_change_non404_fees pct_change_audit_clients pct_change_404_clients pct_change_non404_clients 
  save foranalysis, replace

//// need to add on data related to fyear 2022 so we can capture growth because audit analytics reprots on a delay and therefore 2021-2022 growth measures are incomplete 
	
//this code below is going to add an additional year of data so we can capture portfolio growth from 2021 to 2022
//then we perform tests here
//select working directory with additional data for updates 
cd "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW2_Additional"

//import form ap data and run same code so we can compute 2021-2022 partner growth
import delimited "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\formap20230612.csv", clear
//generate fyear from fiscal year period end variable 
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
generate fyeardate=date(fiscalperiodenddate,"MDY")
order fiscalperiodenddate fyear
format fyeardate %td
gen fyear = year(fyeardate)
gen date = 100*month(fyeardate)+day(fyeardate)
replace fyear= fyear-1 if date <=531
///keep only issuers so exclude employee benefit plan and investment company
keep if auditreporttype=="Issuer, other than Employee Benefit Plan or Investment Company"
drop auditreporttype
//keep only US firms
keep if firmcountry=="United States"
drop firmcountry
rename issuercik cik
destring cik, replace
order cik fyear engagementpartnerid
//only care about audits from 2016 on 
//some observations are dated early we dont care about those so drop 
drop if fyear<2015
keep cik fyear engagementpartnerid 
destring engagementpartnerid, replace
duplicates drop cik fyear, force
xtset cik fyear
egen partner_client=group(cik engagementpartnerid)
order cik fyear engagementpartnerid   partner_client
///generate indicator for partner switching
//group clients by client and engagmenetpartner id then say if they changed "groups" they switched partners 
xtset cik fyear
gen f_partner=f.partner_client
gen change_partner_fy=0
replace change_partner_fy=1 if partner_client!=f_partner
// dont include missing future years because we cant determine whether or not that was a switch or the client "died"
replace change_partner_fy=. if missing(f_partner)
xtset cik fyear
gen same_partner_py=0
replace same_partner_py=1 if partner_client==l.partner_client
replace same_partner_py=. if missing(l.partner_client)
//rename variable for easier identification but a partner change indicates changed partners from t to t+1
gen partner_change=change_partner_fy
gen partner_switch=partner_change
gen keep_partner=1 if partner_switch==0
replace keep_partner=0 if partner_switch==1
//keep variables needed for later
keep cik fyear engagementpartnerid partner_client f_partner change_partner_fy same_partner_py partner_change   partner_switch keep_partner
save partner_changes_tomerge1, replace 
//compile all data to merge onto partner data from above
//start with audit fees to get measures needed for portfolio growth
//use raw audit fees file 
use AuditFees20240610, clear
rename *, lower
rename company_fkey cik
destring cik, replace
//drop if missing audit fees because we wont be able to use in portfolio measures 
drop if audit_fees==.
//gen auditor tiers
gen BIGN=0
replace BIGN=1 if auditor_fkey==3|auditor_fkey==2|auditor_fkey==1|auditor_fkey==4
gen second_tier=0
replace second_tier=1 if auditor_fkey==11761 | auditor_fkey==6 | auditor_fkey==16168 | auditor_fkey==2830 
gen third_tier=1
replace third_tier=0 if auditor_fkey==1 | auditor_fkey==2 | auditor_fkey==3 | auditor_fkey==4 | auditor_fkey==11761 | auditor_fkey==6 | auditor_fkey==16168 | auditor_fkey==2830
//gen fyear
gen fyear = year(fiscal_year_ended)
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
gen date = 100*month(fiscal_year_ended)+day(fiscal_year_ended)
replace fyear= fyear-1 if date <=531
drop date
gsort cik fyear -audit_fees
duplicates drop fyear cik, force
//drop any restated audit fees we want original 
drop if restatement==1
drop restatement
//only keep if in USD
keep if currency_code_fkey=="USD"
drop currency_code_fkey
drop if co_is_notick_sub==1 | co_is_shlblnk_nonop==1 | co_is_shlblnk_hldco==1 | co_is_ft==1 | co_is_abs==1 | co_is_reit==1
drop co_is_notick_sub co_is_shlblnk_nonop co_is_shlblnk_hldco co_is_ft co_is_abs co_is_reit
///gen change in audit fees
xtset cik fyear
gen f_audit_fees=f.audit_fees
gen change_client_audit_fees=(f_audit_fees-audit_fees)/audit_fees 
//transform audit fees to be in millions (following gipper paper to transform as a control variable when measuring partner portfolio size)
replace audit_fees=audit_fees/1000000
//only keep 2022 because this is the additional year of data we need
keep if fyear==2022
save AAFees, replace 
//add fyear 2022 to previous dataset  
use  "\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\AAFees.dta", clear
//drop any partial obs from previous dataset related to 2022 because addl data set has complete 2022
drop if fyear==2022
//append prior dataset with additional year of data 
append using AAFees
save AAFees, replace 
// now using audit opinions data for fyear 2022 to create variables for merging onto partner level 
use AAOpinions20240614, clear
rename *, lower
rename company_fkey cik
destring cik, replace
//drop foreign
keep if auditor_country=="USA"
//gen gco indicator
gen gco=0
replace gco=1 if going_concern==1
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
gen fyear = year(fiscal_year_end_op)
gen date = 100*month(fiscal_year_end_op)+day(fiscal_year_end_op)
replace fyear= fyear-1 if date <=531
drop date
drop if auditor_city==""
gsort cik fyear 
duplicates drop fyear cik auditor_fkey, force
keep if fyear==2022
save AAOpinionsPreMerge, replace
//add fyear 2022 to data previously downloaded
use  "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\AAOpinionsPreMerge.dta", clear
drop if fyear==2022
append using AAOpinionsPreMerge
save AAOpinionsPreMerge, replace
//merge fees and opinions data together
merge 1:1 fyear cik auditor_fkey using AAFees
//only keep if merged together 
keep if _merge==3 
drop _merge
gsort fyear cik -audit_fees
//merge fyear 2022 onto other data set
keep if fyear==2022
save AuditFeesOpinions, replace
//add fyear 2022 to data previously downloaded
 use  "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\AuditFeesOpinions.dta", clear
 drop if fyear==2022
append using AuditFeesOpinions
save AuditFeesOpinions, replace 
//get info about ic audits for 2022 .. dont need anything from this other that fyear 2022 ic audit or not 
use "404Raw20240610", clear
rename *, lower
gen cik=company_fkey
//only keep auditor opinions
keep if ic_op_type=="a"
//drop any restated opinons 
keep if is_nth_restate==0
drop if co_is_notick_sub==1 | co_is_shlblnk_nonop==1 | co_is_shlblnk_hldco==1 | co_is_ft==1 | co_is_abs==1 | co_is_reit==1
drop co_is_notick_sub co_is_shlblnk_nonop co_is_shlblnk_hldco co_is_ft co_is_abs co_is_reit
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
gen fyear = year(fye_ic_op)
gen date = 100*month(fye_ic_op)+day(fye_ic_op)
replace fyear= fyear-1 if date <=531
drop date
gsort cik fyear -count_weak
duplicates drop cik fyear count_weak, force
duplicates drop cik fyear, force
//got a 404b audit if they received an IC audit 
gen IC_audit=1
gen weakness=0
replace weakness=1 if count_weak>0 
replace weakness=0 if missing(count_weak)
replace IC_audit=0 if missing(IC_audit)
keep cik fyear IC_audit  weakness
destring cik, replace
save MatWeakPreMerge, replace

//merge material weakness data and create variable to measure 1 if yes 0 if not for weakness
use AuditFeesOpinions, clear 
merge 1:1 cik fyear  using MatWeakPreMerge
drop if _merge==2
drop _merge
replace IC_audit=0 if missing(IC_audit)
save feesopinions, replace
replace IC_audit=0 if missing(IC_audit)
keep cik fyear IC_audit 
sort cik fyear IC_audit
save mergetofees, replace

//use partner file from above and merge to merge to fees file 
//code AICO partners if had a weakness
use partner_changes_tomerge1, clear
keep engagementpartnerid fyear cik 
merge 1:1 cik fyear using mergetofees
keep if _merge==3
drop _merge
save mergetofees, replace 

//create office level variables in case need them later 
use AuditFeesOpinions, clear
merge 1:1 cik fyear using mergetofees
keep if _merge==3
drop _merge
save auditoffice, replace
rename *, lower
order cik fyear auditor_fkey
//generate audit office as city and state where auditor is located
egen location = concat(auditor_city auditor_state_name), punct(",")
gsort auditor_fkey location fyear
egen audit_office=group(auditor_fkey location)
//gen public float variable
//gen public_float=curr_price_close*curr_tso
//will generate accel filer variable with compustat market value to get at which accel filers undisclosed are large vs small accel filer 
save feesopinions1, replace
gen auditor_city1= upper(auditor_city)
statastates, name(auditor_state_name)
drop _merge
gen auditor_city2= subinstr(auditor_city1," ","",.)
gen auditorlocation= auditor_city2 + state_abbrev
rename auditorlocation city_state
save feesopinions1, replace
//merge to MSA data
use MSA, clear
//add in the missing MSAs for the biggest missing cities 
merge 1:m city_state using feesopinions1
drop if _merge==1
replace MSA=45300 if city_state=="TEMPLETERRACEFL"
replace MSA=16980 if city_state=="TINLEYPARKIL"
replace MSA=47900 if city_state=="TYSONSVA"
replace MSA=33100 if city_state=="COCONUTCREEKFL"
replace MSA=39140 if city_state=="PRESCOTTVALLEYAZ"
replace MSA=26900 if city_state=="NOBLESVILLEIN"
replace MSA=19820 if city_state=="FARMINGTONMI"
replace MSA=18140 if city_state=="GRANDVIEWHEIGHTSOH"
replace MSA=35620 if city_state=="BAYVILLENJ"
replace MSA=31100 if city_state=="NEWHALLCA"
replace MSA=45300 if city_state=="GULFPORTFL"
replace MSA=33100 if city_state=="SOUTHMIAMIFL"
replace MSA=33100 if city_state=="PRINCETONFL"
replace MSA=41860 if city_state=="PLEASANTHILLCA"
replace MSA=35620 if city_state=="RIVERVALENJ"
replace MSA=39100 if city_state=="HYDEPARKNY"
order cik fyear
destring cik, replace
gsort cik fyear -audit_fees
duplicates drop cik fyear, force
drop _merge
save aofeesopinions, replace
//merge these data to partner data and then merge to compustat and then restatement data once we get the datadate added from compustat
use partner_changes_tomerge1, clear
merge 1:1 cik fyear using aofeesopinions
keep if _merge==3
drop _merge 
//count clients and fees and characteristics by partner year
bysort engagementpartnerid fyear: egen partner_num_clients=nvals(cik)
bysort engagementpartnerid fyear: egen partner_404b_count=sum(ic_audit) 
//non ic opinon clients dont receive an ic audit in line with 404b rules
gen ic_audit_fees=ic_audit*audit_fees
gen non_ic_audit=0
replace non_ic_audit=1 if ic_audit==0
bysort engagementpartnerid fyear: egen partner_non404b_count=sum(non_ic_audit) 
bysort engagementpartnerid fyear: egen partner_404b_fees=sum(ic_audit_fees) 
gen non_ic_fees=non_ic_audit*audit_fees
bysort engagementpartnerid fyear: egen partner_non404b_fees=sum(non_ic_fees) 
bysort engagementpartnerid fyear: egen partner_nonaudit_fees=sum(non_audit_fees) 
bysort engagementpartnerid fyear: egen partner_audit_fees=sum(audit_fees) 
gen ln_afee=ln(1+audit_fees)
bysort engagementpartnerid fyear: egen partner_lnaudit_fees=sum(ln_afee) 
bysort engagementpartnerid fyear: egen partner_num_offices=nvals(audit_office) 
gen sic1=substr(sic_code_fkey,1,1)
destring sic1, replace
bysort engagementpartnerid fyear: egen partner_num_industries_sic1=nvals(sic1) 
bys engagementpartnerid fyear: gen avg_fees_per_partner=partner_audit_fees/(partner_404b_count+partner_non404b_count)
bys engagementpartnerid fyear: gen avg_404fees_per_partner=partner_404b_fees/partner_404b_count
//if no 404b clients then the average 404 fees per client is just 0
replace avg_404fees_per_partner=0 if partner_404b_count==0
bys engagementpartnerid fyear: gen avg_non404fees_per_partner=partner_non404b_fees/partner_non404b_count
replace avg_non404fees_per_partner=0 if partner_non404b_count==0
bys engagementpartnerid fyear: egen partner_gcos=sum(gco)  
save partnerprecompustat1, replace 
use partnerprecompustat1, clear
//keep partner level stuff at time t then generate year ahead variables and take the difference to compute changes in portfolios 
keep engagementpartnerid fyear     partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner   
duplicates drop engagementpartnerid fyear, force
xtset engagementpartnerid fyear
xtset engagementpartnerid fyear
foreach var in  partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner   {
 	gen f_`var'=f.`var'
}
//if missing future 404b or future non 404b clients then this means they have 0 of those clients in that year so replace missings here with 0s
//these observations will stay with the total average measure because you only need one of the two buckets of clients for that /// so if they have 0 clients then this will drop out as divide by 0 in the change in avg measures/// note that measures still work (at least on base model) without this design decision
replace f_avg_non404fees_per_partner=0 if missing(f_avg_non404fees_per_partner)
replace f_avg_404fees_per_partner=0 if missing(f_avg_404fees_per_partner)
replace f_partner_404b_fees=0 if missing(f_partner_404b_fees)
replace f_partner_non404b_fees=0 if missing(f_partner_non404b_fees)
replace f_partner_non404b_count=0 if missing(f_partner_non404b_count)
replace f_partner_404b_count=0 if missing(f_partner_404b_count)


foreach var in  partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner  {
	gen chg_`var'=f_`var'-`var' 
}

//merge changes to dataset to compile testing file
merge 1:m engagementpartnerid fyear using partner_changes_tomerge1
drop _merge
save partnerprecompustat2, replace
///generate engagement partner history of icmw

//now compute changes in partner portfolios 
use partnerprecompustat2, clear
// all of these are divided by the TOTAL avg fees at avg level , total fees for pct change in fees and then total clients for pct change in clients 
gen pct_change_avg_fees=chg_avg_fees_per_partner/avg_fees_per_partner
gen pct_change_avg_non404bfees=chg_avg_non404fees_per_partner/avg_fees_per_partner
gen pct_change_avg_404bfees=chg_avg_404fees_per_partner/avg_fees_per_partner
	
gen pct_change_audit_fees=chg_partner_audit_fees/partner_audit_fees
gen pct_change_404_fees=chg_partner_404b_fees/partner_audit_fees
gen pct_change_non404_fees=chg_partner_non404b_fees/partner_audit_fees
gen total_clients=partner_404b_count+partner_non404b_count
gen pct_change_audit_clients=(chg_partner_404b_count+chg_partner_non404b_count)/total_clients
gen pct_change_404_clients=chg_partner_404b_count/total_clients
gen pct_change_non404_clients=chg_partner_non404b_count/total_clients

keep engagementpartnerid fyear pct_change_avg_fees pct_change_avg_non404bfees pct_change_avg_404bfees pct_change_audit_fees pct_change_404_fees  pct_change_non404_fees pct_change_audit_clients pct_change_404_clients pct_change_non404_clients

winsor2 pct_change_avg_fees pct_change_avg_non404bfees pct_change_avg_404bfees pct_change_audit_fees pct_change_404_fees  pct_change_non404_fees pct_change_audit_clients pct_change_404_clients pct_change_non404_clients

duplicates drop engagementpartnerid fyear, force

///keep only if fyear is 2021 because this has growth calculations for 2021 to 2022 
///merge onto prior dataset, merging will keep the growth measures from this update and replace any missings or incompletes for fyear 2021 in prior dataset
//controls for 2021 in prior dataset are complete
//so this data is just growth measures for 2021-2022
keep if fyear==2021
save 2021growthmeasurestomerge, replace
use 2021growthmeasurestomerge, clear
merge 1:m engagementpartnerid fyear using "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\foranalysis.dta"
drop _merge
//use file from JAR stuff and merge on 2021 measures that are corrected
save updated_foranalysis, replace 
///before submitting code file not that i added control for accel filers down here based on what made it to difinal dataset 
//add control for partner accel filers
duplicates drop cik fyear, force

bysort engagementpartnerid fyear: egen partner_accel_filer_lg=sum(lg_accel_filer) 	
bysort engagementpartnerid fyear: egen partner_accel_filer_sm=sum(sm_accel_filer) 	
// want small and large accel filers total at the partner level
gen partner_accel_filer=partner_accel_filer_lg + partner_accel_filer_sm
winsor2 partner_accel_filer
sort engagementpartnerid fyear


global partner_controls "  partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "
//PORTFOLIO LEVEL TESTS ///TABLE 4, Panels B-D

   eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022 , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	   partner_weakness  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   
///FN 14 average number of clients per partner in our sample is 2 clients
sum partner_num_clients if e(sample), detail


///robustness table  4  controlling for partner_resann
   eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022 , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	   partner_weakness  partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4 R.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4 R.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4 R.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")
				   
				   /////generating buckets of gains losses and no change for clients 
//TABLE 4 PANEL A UNIVARIATE COMPARISONS OF CLIENT GAINS AND LOSSES BY TYPE OF CLIENT
 reg pct_change_avg_fees_w  partner_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)	
	
	///tabulate buckets of loss, gain, no change  for 404b
	gen increase_404b=0
	replace increase_404b=1 if chg_partner_404b_count>0 
	gen nochange_404b=0
	replace nochange_404b=1 if chg_partner_404b_count==0
	gen decrease_404b=0
	replace decrease_404b=1 if chg_partner_404b_count<0
	
	tab decrease_404b if partner_weakness==1 &  e(sample)
	tab decrease_404b if partner_weakness==0 &   e(sample)

		tab nochange_404b if partner_weakness==1 &  e(sample)
	tab nochange_404b if partner_weakness==0 &   e(sample)

		tab increase_404b if partner_weakness==1 &  e(sample)
	tab increase_404b if partner_weakness==0 &   e(sample)

	///////tabulate buckets of gain loss change for non 404b
		gen increase_n404b=0
	replace increase_n404b=1 if chg_partner_non404b_count>0 
	gen nochange_n404b=0
	replace nochange_n404b=1 if chg_partner_non404b_count==0
	gen decrease_n404b=0
	replace decrease_n404b=1 if chg_partner_non404b_count<0
	
	tab decrease_n404b if partner_weakness==1 &  e(sample)
	tab decrease_n404b if partner_weakness==0 &   e(sample)

		tab nochange_n404b if partner_weakness==1 &  e(sample)
	tab nochange_n404b if partner_weakness==0 &   e(sample)

		tab increase_n404b if partner_weakness==1 &  e(sample)
	tab increase_n404b if partner_weakness==0 &   e(sample)
/////test for differences in coefficients 
local varlist "decrease_404b nochange_404b increase_404b  decrease_n404b nochange_n404b increase_n404b"


foreach i of local varlist {
 ttest `i' if e(sample), by(partner_weakness) 
 }

 ///////portfolio level descriptives 
//PORTFOLIO LEVEL DESCRIPTIVES 
	   ///TABLE 2 PANEL A

asdoc sum pct_change_avg_fees_w  pct_change_audit_fees_w  pct_change_audit_clients_w pct_change_avg_404bfees_w pct_change_404_fees_w pct_change_404_clients_w pct_change_avg_non404bfees_w pct_change_non404_fees_w pct_change_non404_clients_w partner_weakness   $partner_controls if e(sample), stat(N mean sd p25 median p75) replace	

asdoc sum pct_change_avg_fees_w  pct_change_audit_fees_w  pct_change_audit_clients_w pct_change_avg_404bfees_w pct_change_404_fees_w pct_change_404_clients_w pct_change_avg_non404bfees_w pct_change_non404_fees_w pct_change_non404_clients_w partner_weakness   $partner_controls if e(sample)  & partner_weakness==1, stat(N mean sd p25 median p75) append	

asdoc sum  pct_change_avg_fees_w  pct_change_audit_fees_w  pct_change_audit_clients_w pct_change_avg_404bfees_w pct_change_404_fees_w pct_change_404_clients_w pct_change_avg_non404bfees_w pct_change_non404_fees_w pct_change_non404_clients_w partner_weakness   $partner_controls if e(sample) & partner_weakness==0, stat(N mean sd p25 median p75) append	

local varlist "pct_change_avg_fees_w  pct_change_audit_fees_w  pct_change_audit_clients_w pct_change_avg_404bfees_w pct_change_404_fees_w pct_change_404_clients_w pct_change_avg_non404bfees_w pct_change_non404_fees_w pct_change_non404_clients_w partner_weakness   $partner_controls"

//PORTFOLIO LEVEL DESCRIPTIVES 
	   ///TABLE 2 PANEL B

foreach i of local varlist {
 ttest `i' if e(sample), by(partner_weakness) 
 }

//PORTFOLIO LEVEL TESTS ///TABLE 7 BIG 4 VS NON BIG 4 AUDITORS 
//big vs non big 
 //generate indicator for big 4 vs non big and then test differences 
 gen  partner_weakness_big=0
  replace partner_weakness_big=1 if partner_weakness==1 & bign==1

 gen partner_weakness_nbig=0
 replace partner_weakness_nbig=1 if partner_weakness==1 & bign==0
 
 eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")		
///test differences
 qui reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
qui  reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
qui  reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig

 qui reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
qui  reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
 qui reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig

  //////table 7 robustness controlling for partner_resann
  
   eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 R.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig  partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 R.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig  partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 R.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")		
///test differences
 qui reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
qui  reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
qui  reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig partner_resann  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig

 qui reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig partner_resann  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
qui  reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
 qui reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig  partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
  	save updated_for_analysis_main, replace
	   
  //PORTFOLIO LEVEL TESTS 				   
//TABLE 6 MORE VS LESS IMPORTANT CLIENTS
//START WITH CUT ON MEDIAN 404 FEES THEN EXAMINE TENURE as robustness 
  ///// splitting on whether the adverse ico went to a bigger or smaller client 				   
use updated_for_analysis_main, clear
bysort audit_office fyear: egen median_404fees= median(ic_audit_fees)
///fills in missing when there is only one  ic audit client so take max of the median here
bysort audit_office fyear: egen max_median_fees=max(median_404fees)
gen big_med_client=0
replace big_med_client=1 if audit_fees>=max_median_fees
gen partner_weakness_influence=0
replace partner_weakness_influence=1 if big_med_client==1 & weakness==1
bysort engagementpartnerid fyear: egen sum_weak_influence=sum(partner_weakness_influence) 
gen partner_weak_influence_client=0
replace partner_weak_influence_client=1 if sum_weak_influence>0

gen partner_weak_small=0 
replace partner_weak_small=1 if partner_weakness==1 & partner_weak_influence_client==0

  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 6 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 6 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 6 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

//test differences 
qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

////robustness test controlling for partner resann

  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 6 r.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 6 r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small partner_resann  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 6 r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

//test differences 
qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small  partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small  partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small


//PORTFOLIO LEVEL TESTS 

////INHERITED AICO TEST 
///table 5 in the manuscript

use updated_for_analysis_main, clear	
sort cik fyear
xtset cik fyear 
gen l_weakness=l.weakness
gen inherit_weakness=0
//inherit weakness if youre a new partner py partner change means that they changed from last year to this year so they are new to you and the client had a weakness last year 
replace inherit_weakness=1 if same_partner_py==0 & l_weakness==1 & weakness==1
bysort engagementpartnerid fyear: egen inherited_weakness=sum(inherit_weakness)

  eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness inherited_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w   partner_weakness inherited_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	   partner_weakness inherited_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 5 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w    partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 5 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_clients_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)	

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 5 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	
tab inherited_weakness if e(sample)
//29 of these make it to our sample 
	//test differences
	
  qui reg pct_change_avg_fees_w  partner_weakness inherited_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
   test  partner_weakness=inherited_weakness
 qui  reg pct_change_audit_fees_w   partner_weakness inherited_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test  partner_weakness=inherited_weakness
qui  reg pct_change_audit_clients_w	   partner_weakness inherited_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test  partner_weakness=inherited_weakness
 qui reg pct_change_avg_404bfees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
 qui  reg pct_change_404_fees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
 qui  reg 	pct_change_404_clients_w    partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
 qui reg pct_change_avg_non404bfees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
qui  reg  pct_change_non404_fees_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
 test  partner_weakness=inherited_weakness
 qui  reg  pct_change_non404_clients_w  partner_weakness inherited_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)	
  test  partner_weakness=inherited_weakness

 ///robust to controlling for partner resann
 
 
  eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w   partner_weakness inherited_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	   partner_weakness inherited_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 5r.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w    partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 5r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w  partner_weakness inherited_weakness  partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_clients_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)	

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 5r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	//test differences
	
  qui reg pct_change_avg_fees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
   test  partner_weakness=inherited_weakness
 qui  reg pct_change_audit_fees_w   partner_weakness inherited_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test  partner_weakness=inherited_weakness
qui  reg pct_change_audit_clients_w	   partner_weakness inherited_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test  partner_weakness=inherited_weakness
 qui reg pct_change_avg_404bfees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
 qui  reg pct_change_404_fees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
 qui  reg 	pct_change_404_clients_w    partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
 qui reg pct_change_avg_non404bfees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test  partner_weakness=inherited_weakness
qui  reg  pct_change_non404_fees_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
 test  partner_weakness=inherited_weakness
 qui  reg  pct_change_non404_clients_w  partner_weakness inherited_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)	
  test  partner_weakness=inherited_weakness


//PORTFOLIO LEVEL TESTS 				   
 
//////////////////////////
//additional tests
///////////////////////
						   
//////////////////////////
/////////////TABLE 8 IN MANUCRIPT  2 and 3 year windows 
///////////generate 2 and 3 year partner portfolio growth measures 
///need to append data with the 2022 years to get the 2 and 3 year out measures
use partnerprecompustat2, clear

keep if fyear==2022
bysort engagementpartnerid fyear: gen unique_partner1=_n
keep if unique_partner1==1
save partner_2022_measures, replace 

use updated_for_analysis_main, clear
drop if fyear==2022	
append using 	partner_2022_measures   
keep if unique_partner1==1

//drop duplicates from years
sort engagementpartnerid fyear
xtset engagementpartnerid fyear
	
	global partner_controls " partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "

sort engagementpartnerid fyear
xtset engagementpartnerid fyear
foreach var in partner_weakness_number partner_weakness_count   partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos {
 	gen f2_`var'=f2.`var'
}

xtset engagementpartnerid fyear
foreach var in partner_weakness_number partner_weakness_count   partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos {
 	gen f3_`var'=f3.`var'
}

/////if missing future 404b or future non 404b clients then this means they have 0 of those clients in that year so replace missings here with 0s
///these observations will stay with the total average measure because you only need one of the two buckets of clients for that /// so if they have 0 clients then this will drop out as divide by 0 in the change in avg measures//
replace f2_avg_non404fees_per_partner=0 if missing(f2_avg_non404fees_per_partner)
replace f2_avg_404fees_per_partner=0 if missing(f2_avg_404fees_per_partner)
replace f2_partner_404b_fees=0 if missing(f2_partner_404b_fees)
replace f2_partner_non404b_fees=0 if missing(f2_partner_non404b_fees)
replace f2_partner_non404b_count=0 if missing(f2_partner_non404b_count)
replace f2_partner_404b_count=0 if missing(f2_partner_404b_count)

replace f3_avg_non404fees_per_partner=0 if missing(f3_avg_non404fees_per_partner)
replace f3_avg_404fees_per_partner=0 if missing(f3_avg_404fees_per_partner)
replace f3_partner_404b_fees=0 if missing(f3_partner_404b_fees)
replace f3_partner_non404b_fees=0 if missing(f3_partner_non404b_fees)
replace f3_partner_non404b_count=0 if missing(f3_partner_non404b_count)
replace f3_partner_404b_count=0 if missing(f3_partner_404b_count)

foreach var in partner_weakness_number partner_weakness_count   partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos{
	gen chg2_`var'=f2_`var'-`var' 
}
	gen pct_change_avg_fees2=chg2_avg_fees_per_partner/avg_fees_per_partner
		gen pct_change_avg_non404bfees2=chg2_avg_non404fees_per_partner/avg_fees_per_partner
			gen pct_change_avg_404bfees2=chg2_avg_404fees_per_partner/avg_fees_per_partner
	
gen pct_change_audit_fees2=chg2_partner_audit_fees/partner_audit_fees
gen pct_change_404_fees2=chg2_partner_404b_fees/partner_audit_fees
gen pct_change_non404_fees2=chg2_partner_non404b_fees/partner_audit_fees
gen pct_change_audit_clients2=(chg2_partner_404b_count+chg2_partner_non404b_count)/total_clients
gen pct_change_404_clients2=chg2_partner_404b_count/total_clients
gen pct_change_non404_clients2=chg2_partner_non404b_count/total_clients

////3yr growth measure 

foreach var in partner_weakness_number partner_weakness_count   partner_404b_count partner_non404b_count  partner_404b_fees partner_non404b_fees partner_nonaudit_fees partner_audit_fees partner_lnaudit_fees partner_num_offices partner_num_industries_sic1  avg_office_size   avg_fees_per_partner avg_404fees_per_partner avg_non404fees_per_partner partner_gcos{
	gen chg3_`var'=f3_`var'-`var' 
}
	gen pct_change_avg_fees3=chg3_avg_fees_per_partner/avg_fees_per_partner
		gen pct_change_avg_non404bfees3=chg3_avg_non404fees_per_partner/avg_fees_per_partner
			gen pct_change_avg_404bfees3=chg3_avg_404fees_per_partner/avg_fees_per_partner
	
gen pct_change_audit_fees3=chg3_partner_audit_fees/partner_audit_fees
gen pct_change_404_fees3=chg3_partner_404b_fees/partner_audit_fees
gen pct_change_non404_fees3=chg3_partner_non404b_fees/partner_audit_fees
gen pct_change_audit_clients3=(chg3_partner_404b_count+chg3_partner_non404b_count)/total_clients
gen pct_change_404_clients3=chg3_partner_404b_count/total_clients
gen pct_change_non404_clients3=chg2_partner_non404b_count/total_clients


winsor2 pct_change_avg_fees2 pct_change_audit_fees2 pct_change_audit_clients2 pct_change_avg_404bfees2 pct_change_404_fees2 pct_change_404_clients2 pct_change_avg_non404bfees2  pct_change_non404_fees2 pct_change_non404_clients2, replace

   eststo clear
 eststo: qui reg pct_change_avg_fees2  partner_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees2  partner_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients2	   partner_weakness  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 2yr Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees2 partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees2 partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients2   partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 2yr Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees2 partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees2 partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients2  partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 2yr Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   

				   ///
				   

////3yr 
winsor2 pct_change_avg_fees3 pct_change_audit_fees3 pct_change_audit_clients3 pct_change_avg_404bfees3 pct_change_404_fees3 pct_change_404_clients3 pct_change_avg_non404bfees3  pct_change_non404_fees3 pct_change_non404_clients3, replace

   eststo clear
 eststo: qui reg pct_change_avg_fees3  partner_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees3  partner_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients3	   partner_weakness  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3yr Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees3 partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees3 partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients3   partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3yr Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees3 partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees3 partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients3  partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3yr Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")		
				   
				   
///robust to controlling for partner resann 
   eststo clear
 eststo: qui reg pct_change_avg_fees2  partner_weakness partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees2  partner_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients2	   partner_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 2yr r.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees2 partner_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees2 partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients2   partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 2yr r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees2 partner_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees2 partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients2  partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 2yr r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   

				   ///
				   

////3yr robustness
   eststo clear
 eststo: qui reg pct_change_avg_fees3  partner_weakness partner_resann $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees3  partner_weakness partner_resann $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients3	   partner_weakness partner_resann  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3yr r.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees3 partner_weakness partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees3 partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients3   partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3yr r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees3 partner_weakness  partner_resann $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees3 partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients3  partner_weakness partner_resann $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3yr r.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

				   save twoandthreeyeartests, replace 
				   
/////////////////////////////////
////////////////////////////////////

///CLIENT LEVEL TESTS table 3 and some untabulated tests 

cd "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW2_Additional"
//use merge of aa fees and opinons from updated data for complete years
use aofeesopinions, clear
xtset cik fyear
gen firm_change=0
replace firm_change=1 if auditor_fkey!=f.auditor_fkey
replace firm_change=. if missing(f.auditor_fkey)
keep cik fyear firm_change
keep if firm_change==1
merge 1:1 cik fyear using updated_for_analysis_main
//rate of firm switch is about 5% which is consistent with prior lit 
drop if _merge==1 
drop _merge
save for_client_analysis, replace

//import form ap data from csv 
//need to compute partner tenure variable before can run client level stuff
import delimited "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\formap20230612.csv", clear
//generate fyear from fiscal year period end variable 
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
generate fyeardate=date(fiscalperiodenddate,"MDY")
order fiscalperiodenddate fyear
format fyeardate %td
gen fyear = year(fyeardate)
gen date = 100*month(fyeardate)+day(fyeardate)
replace fyear= fyear-1 if date <=531
//keep only US firms
keep if firmcountry=="United States"
drop firmcountry
drop if auditreporttype=="Employee Benefit Plan"
drop if auditreporttype=="Investment Company"
rename issuercik cik
destring cik, replace
order cik fyear engagementpartnerid
keep cik fyear engagementpartnerid firmid
destring engagementpartnerid, replace
duplicates drop cik fyear, force
xtset cik fyear
egen partner_client=group(cik engagementpartnerid)
order cik fyear engagementpartnerid   partner_client
///generate indicator for partner switching
//group clients by client and engagmenetpartner id then say if they changed "groups" they switched partners 
xtset cik fyear
gen f_partner=f.partner_client
gen change_partner_fy=0
replace change_partner_fy=1 if partner_client!=f_partner
// dont include missing future years because we cant determine whether or not that was a switch or the client "died"
replace change_partner_fy=. if missing(f_partner)
//about 27% have a partner change that we can identify
xtset cik fyear
gen same_partner_py=0
replace same_partner_py=1 if partner_client==l.partner_client
replace same_partner_py=. if missing(l.partner_client)
//rename variable for easier identification but a partner change indicates changed partners from t to t+1
gen partner_change=change_partner_fy
//generate partner tenure variable on full dataset of form ap to get at whether the change is due to mandatory rotation in year 5 
sort cik fyear
xtset cik fyear 
destring firmid, replace
//generate indicator for changing audit firms as reported in form ap 
gen f_firmid=f.firmid
gen change_aud_firm=0
replace change_aud_firm=1 if f_firmid!=firmid & f_firmid!=.
gen py_partner_change=l.partner_change
gen py2_partner_change=l2.partner_change
gen py3_partner_change=l3.partner_change
gen py4_partner_change=l4.partner_change
//calculate first year of partner tenure with client
bysort cik engagementpartnerid: egen partner_tenurestart=min(fyear)
//the restriction below accomodates partners who may have audited early on and then come back in later years 
replace partner_tenurestart = fyear if py_partner_change==1 
gen partner_tenure=fyear-partner_tenurestart
replace partner_tenure=partner_tenure+1
sort cik fyear
xtset cik fyear
replace partner_tenure=l.partner_tenure+1 if partner_client==l.partner_client
////
winsor2 partner_tenure
gen ln_partner_tenure=ln(1+partner_tenure)
winsor2 ln_partner_tenure
//add these variables to main dataset with all of our controls
keep partner_tenure partner_tenure_w ln_partner_tenure ln_partner_tenure_w cik fyear change_aud_firm
//merge onto file for table 3 testing 
merge 1:1 cik fyear using for_client_analysis
keep if _merge==3
///recalculate leverage as total debt divide by total assets following aobdia 
gen leverage2= (dlc+dltt)/at
winsor2 dlc dltt
winsor2 at
winsor2 leverage2 
destring sic, replace
//two variables to denote whether partner gave weakness to this client or another client
gen partner_weak_other_client=partner_weakness
replace partner_weak_other_client=0 if weakness==1
reg partner_change weakness partner_weak_other_client  i.fyear i.sic if fyear>2015 & ic_audit==1 & firm_change!=1 & foreign1==0 & fyear<2022 , robust cluster(cik)
drop      cash_w  client_at_growth_w  ln_at_w   invrec_w     roa2_w
winsor2   cash  client_at_growth  ln_at   invrec    roa2 
global client_controls_main "py_partner_weakness  acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w"
global client_controls_no_py "  acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w"
//summary stats table 1 
qui reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015 & firm_change!=1 & foreign1==0 & fyear<2022 , robust cluster(cik)

asdoc sum partner_change partner_weakness weakness partner_weak_other_client py_partner_weakness   acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w if e(sample), stat(N mean sd p25 median p75) append	

asdoc sum partner_change partner_weakness weakness  partner_weak_other_client py_partner_weakness   acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w if e(sample) & ic_audit==1, stat(N mean sd p25 median p75) append	

asdoc sum partner_change partner_weakness weakness partner_weak_other_client py_partner_weakness   acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w if e(sample) & ic_audit==0, stat(N mean sd p25 median p75) append	

local varlist "partner_change partner_weakness weakness partner_weak_other_client py_partner_weakness    acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w"


foreach i of local varlist {
 ttest `i' if e(sample), by(ic_audit) 
 }

//see how many companies switch audit offices
	 qui reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015 & firm_change!=1 & foreign1==0 & fyear<2022 , robust cluster(cik)
sort cik fyear
gen f_audit_office=f.audit_office
gen change_office=0
replace change_office=1 if f_audit_office!=audit_office & f_audit_office!=.			   
	tab change_office if e(sample)			   				   
	//footnote 12 ... 3.12% of companies in our sample siwtch audit offices
		tab change_office weakness if e(sample)			   				   
//13 of the 342 office changes follow a weakness  of 3.8% of those switches 
////get total that dismissed firm and are excluded by running without restriction
	
				   reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015 & foreign1==0 & fyear<2022 , robust cluster(cik)
	///excluding about 5% which is consistent with a 5% switching rate 

				   
//main table table 3

//MAIN TABLE 3 // three columns and then test for difference in VOI in column2
		eststo clear

eststo: qui  reg partner_change weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022 & py_partner_weakness!=., robust cluster(cik)


eststo: qui  reg partner_change weakness partner_weak_other  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022, robust cluster(cik)

eststo: qui  reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==0 & firm_change!=1  & foreign1==0 & fyear<2022, robust cluster(cik)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" "Industry FE= *sic") label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year" "Industry FE= *sic") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("all" "404b" "non404b")	
///test coefficients between client aico and partner aico
//fn 15 test coef
reg partner_change weakness partner_weak_other  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022, robust cluster(cik)
//not different
	test weakness=partner_weak_other_client	   
///robust to logit 
eststo clear

eststo: qui  logit partner_change weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022 & py_partner_weakness!=., robust cluster(cik)

eststo: qui  logit partner_change weakness partner_weak_other  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022, robust cluster(cik)

eststo: qui  logit partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==0 & firm_change!=1  & foreign1==0 & fyear<2022, robust cluster(cik)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" "Industry FE= *sic") label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 3 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year" "Industry FE= *sic") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("all" "404b" "non404b")				   
				   
drop _merge
save clientlevel, replace 
	
////lost client analysis
///partner level analysis on lost clients //three tests here are untabulated in paper but discussed
///1 is controlling for, 2 is excluding, 3 is two separate variables and testing the difference 
use clientlevel, clear
sort cik fyear
xtset cik fyear
gen weakness_lost=0
replace weakness_lost=1 if weakness==1 & firm_change==1

gen weakness_no_lost=0
replace weakness_no_lost=1 if weakness==1 & firm_change!=1

////generate weakness that led to loss of client for the firm
 //gen partner_weakness_lost_client=0
 //replace partner_weakness_lost_client=1 if weakness==1 & dismiss_auditor==1
 bysort engagementpartnerid fyear: egen partner_weakness_and_lost=sum(weakness_lost)
 ///change this variable to indicator variable 
 replace partner_weakness_and_lost=1 if partner_weakness_and_lost>0
 bysort engagementpartnerid fyear: egen partner_weakn_no_loss=sum(weakness_no_lost)
 replace partner_weakn_no_loss=1 if partner_weakn_no_loss>1
 //control for weaknesses that led to loss clients/
 //this is discussed in the paper 
 //need to calculate which weaknesses we knwo did not result in weakness loss .. we drop any company that we dont know whether or not the weakness led to audit firm turnover or not 
//
gen partner_total_weakness=partner_weakness_and_lost+partner_weakn_no_loss 
replace partner_total_weakness=1 if partner_total_weakness>1

global partner_controls " partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "
  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_total_weakness partner_weakness_and_lost $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	 partner_total_weakness partner_weakness_and_lost  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")    
esttab using "Table r Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w  partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_total_weakness partner_weakness_and_lost  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

//// excluding loss of client partners page 30 test 
  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if unique_partner1==1 & fyear<2022 & partner_weakness_and_lost==0 , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_total_weakness partner_weakness_and_lost $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	 partner_total_weakness partner_weakness_and_lost  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w  partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_total_weakness partner_weakness_and_lost  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_total_weakness partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")
				   
				   						  
///now mutually exclusive variables for lost vs not lost // this is discussed in paper
gen weakness_no_loss=0
replace weakness_no_loss=1 if weakness==1 & firm_change!=1			  
			bysort engagementpartnerid fyear: egen partner_weakness_no_loss=sum(weakness_no_loss)
			//make indicator
			replace partner_weakness_no_loss=1 if partner_weakness_no_loss>1
				  
  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if unique_partner1==1 & fyear<2022 , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weakness_no_loss partner_weakness_and_lost $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	 partner_weakness_no_loss partner_weakness_and_lost  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r2 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w  partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r2 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weakness_no_loss partner_weakness_and_lost  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r2 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

///test for differences 
qui reg pct_change_avg_fees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if unique_partner1==1 & fyear<2022 , robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
qui  reg pct_change_audit_fees_w  partner_weakness_no_loss partner_weakness_and_lost $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
qui  reg pct_change_audit_clients_w	 partner_weakness_no_loss partner_weakness_and_lost  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
 qui reg pct_change_avg_404bfees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
 test partner_weakness_no_loss=partner_weakness_and_lost 
qui  reg pct_change_404_fees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
qui  reg 	pct_change_404_clients_w  partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
qui reg pct_change_avg_non404bfees_w partner_weakness_no_loss partner_weakness_and_lost  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
qui  reg  pct_change_non404_fees_w partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 
qui  reg 	 pct_change_non404_clients_w  partner_weakness_no_loss partner_weakness_and_lost $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weakness_no_loss=partner_weakness_and_lost 

 save auditor_lost_clients, replace

/////now look at replacement audit partner AICO history 
	
use auditor_lost_clients, clear
	
keep cik fyear partner_tenure partner_tenure_w firm_change
merge 1:1 cik fyear using clientlevel
destring sic, replace
sort cik fyear
xtset cik fyear
reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022 , robust cluster(cik)
gen weakness_and_switch=0
replace weakness_and_switch=1 if partner_change==1 & weakness==1 //& e(sample)
gen l_weakness_and_switch=l.weakness_and_switch

reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022 , robust cluster(cik)
gen weakness_no_switch=0
replace weakness_no_switch=1 if partner_change==1 & weakness==0 //& e(sample)
gen l_weakness_no_switch=l.weakness_no_switch

////keep if mw client and switch and look at just them an their partner history the year after the change 
///generate a 5 year partner history
gen aico_partner_history_5yrs=0
replace aico_partner_history_5yrs=1 if py_partner_weakness==1 | py2_partner_weakness==1 | py3_partner_weakness==1 | py4_partner_weakness==1 | py5_partner_weakness==1 
///this gets to future partner and aico history 
xtset cik fyear
gen f_partner_aico_history=f.aico_partner_history_5yrs
///if no aico history then no observable weaknesses so replace missings with 0s 
replace f_partner_aico_history=0 if missing(f_partner_aico_history)
reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022 , robust cluster(cik)

///AICO history test, discussed in paper, if you have a weakness and you change partners then you are less likely to be assigned to a partner that has a history of issuing AICOS
reg f_partner_aico_history c.weakness##c.partner_change  $client_controls_main i.fyear i.sic if fyear>2015  & ic_audit==1 & firm_change!=1  & foreign1==0 & fyear<2022 & ic_audit==1 , robust cluster(cik)
///less likely to have a future partner with history of aico if you have a weakness and change partners 

reg f_partner_aico_history c.weakness##c.partner_change  $client_controls_no_py i.fyear i.sic if e(sample) , robust cluster(cik)
keep cik fyear partner_tenure_w  firm_change
save partner_tenure_variable, replace 

///////mandatory rotation test 1 followed by another mandatory rotation test below
//make panel of mandatory rotation partners with the full dataset regardless of if they get picked up in our portfolio measures to ensure that partner changes arent due to portfolio changes 
//import form ap data from csv 
import delimited "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\formap20230612.csv", clear
//generate fyear from fiscal year period end variable 
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
generate fyeardate=date(fiscalperiodenddate,"MDY")
order fiscalperiodenddate fyear
format fyeardate %td
gen fyear = year(fyeardate)
gen date = 100*month(fyeardate)+day(fyeardate)
replace fyear= fyear-1 if date <=531
//keep only US firms
keep if firmcountry=="United States"
drop firmcountry
//keep only issuer cik 
drop if auditreporttype=="Employee Benefit Plan"
drop if auditreporttype=="Investment Company"
rename issuercik cik
destring cik, replace
order cik fyear engagementpartnerid
//only care about audits from 2016 on 
//some observations are dated early we dont care about those so drop 
keep cik fyear engagementpartnerid 
destring engagementpartnerid, replace
duplicates drop cik fyear, force
xtset cik fyear
egen partner_client=group(cik engagementpartnerid)
order cik fyear engagementpartnerid   partner_client
///generate indicator for partner switching
//group clients by client and engagmenetpartner id then say if they changed "groups" they switched partners 
xtset cik fyear
gen f_partner=f.partner_client
gen change_partner_fy=0
replace change_partner_fy=1 if partner_client!=f_partner
// dont include missing future years because we cant determine whether or not that was a switch or the client "died"
replace change_partner_fy=. if missing(f_partner)
xtset cik fyear
gen same_partner_py=0
replace same_partner_py=1 if partner_client==l.partner_client
replace same_partner_py=. if missing(l.partner_client)
//rename variable for easier identification but a partner change indicates changed partners from t to t+1
gen partner_change=change_partner_fy
//generate partner tenure variable to get at whether the change is due to mandatory rotation in year 5 
sort cik fyear
xtset cik fyear 
gen py_partner_change=l.partner_change
gen py2_partner_change=l2.partner_change
gen py3_partner_change=l3.partner_change
gen py4_partner_change=l4.partner_change
bysort cik engagementpartnerid: egen partner_tenurestart=min(fyear)
replace partner_tenurestart = fyear if py_partner_change==1 
gen partner_tenure=fyear-partner_tenurestart
//change this to a 1-5 scale instead of 0-4 
replace partner_tenure=partner_tenure+1
sort cik fyear
xtset cik fyear
replace partner_tenure=l.partner_tenure+1 if partner_client==l.partner_client
///the above is on a 0-4 year scale so update with a plus one to be on a 5 year scale
//replace partner_tenure=partner_tenure+1
///need to account for observations that switched partners and then switched back 
gen excludes_mandatory=0
///0s mean it is either mandatory or unknown 
replace excludes_mandatory=1 if py_partner_change==1 |  py2_partner_change==1 |  py3_partner_change==1 |  py4_partner_change==1  
///if they dont change partners then its not a mandatory rotation and therefore excludes mandatory
replace excludes_mandatory=1 if partner_change==0
save excludes_mandatory_form_ap, replace 

//use audit fees file to get auditor fkey this comes from main testing file 
use AAfees, clear
bysort cik auditor_fkey: egen tenurestart=min(fyear)
by cik auditor_fkey: gen test=0 if fyear[_n]!=fyear[_n+1]-1
gen tenure=fyear-tenurestart
keep cik fyear tenure 
rename tenure audit_firm_tenure
replace audit_firm_tenure=audit_firm_tenure+1
save mergetocomp, replace 

merge 1:1 cik fyear using excludes_mandatory_form_ap
replace excludes_mandatory=1 if audit_firm_tenure<5
drop _merge
drop if missing(engagementpartnerid)
save premerge, replace
///some partners are tagged as greater than 5 years these get picked up when we backfill based on no partner change ... examined each of these observations and they have longer than 5 years but no changes in form ap.. exclude these from analysis as precaution on mandatory rotation //
gen py_partner_change_sum=py_partner_change+ py2_partner_change +py3_partner_change+ py4_partner_change
///some have more than 5 years but this isnt due for mandatory change if they have more than one prior change
replace excludes_mandatory=0 if partner_tenure>4 & py_partner_change_sum<1 & partner_change==1	
	
//cant be mandatory if audit firm tenure is less than 5 years 	
bysort engagementpartner fyear: egen avg_excludes_mandatory=mean(excludes_mandatory)
////this will take a value of one when all clients exclude mandatory rotation for that year
gen portfolio_has_no_mandatory=0
replace portfolio_has_no_mandatory=1 if avg_excludes_mandatory==1

duplicates drop engagementpartnerid fyear , force
keep engagementpartnerid fyear portfolio_has_no_mandatory
//these partners are tagged as years where no mandatory rotation
merge 1:m engagementpartnerid fyear using updated_for_analysis_main
keep if _merge==3
drop _merge
gen partner_mandatory_or_unknown=0
replace partner_mandatory_or_unknown=1 if portfolio_has_no_mandatory==0
reg pct_change_audit_fees_w  partner_weakness  $partner_controls  i.fyear if unique_partner1==1 & fyear<2022 & portfolio_has_no_mandatory==1  ,  robust cluster(engagementpartnerid)
gen portfolio_has_mandatory=0
replace portfolio_has_mandatory=1 if portfolio_has_no_mandatory==0
replace portfolio_has_no_mandatory=0 if missing(portfolio_has_no_mandatory)
//global controls winsorized for new sample 
global partner_controls " partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w partner_num_offices_w"

//exlcude  mandatory rotations - robust 
	   eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness  $partner_controls  i.fyear if unique_partner1==1 & fyear<2022 & portfolio_has_no_mandatory==1  ,  robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weakness   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	   partner_weakness   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4b Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weakness  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4b Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weakness  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4b Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			  

////alternate way to specify mandatory rotation
//make panel of mandatory rotation partners with the full dataset regardless of if they get picked up in our portfolio measures to ensure that partner changes arent due to portfolio changes 
//import form ap data from csv 

import delimited "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\formap20230612.csv", clear
//generate fyear from fiscal year period end variable 
//want to back up any fiscal period ending in 5/31 because most of the audit occurred in the prior year and therefore fy should back up by one 
generate fyeardate=date(fiscalperiodenddate,"MDY")
order fiscalperiodenddate fyear
format fyeardate %td
gen fyear = year(fyeardate)
gen date = 100*month(fyeardate)+day(fyeardate)
replace fyear= fyear-1 if date <=531
//keep only US firms
keep if firmcountry=="United States"
drop firmcountry
//keep only issuer cik 
drop if auditreporttype=="Employee Benefit Plan"
drop if auditreporttype=="Investment Company"
rename issuercik cik
destring cik, replace
order cik fyear engagementpartnerid
keep cik fyear engagementpartnerid 
destring engagementpartnerid, replace
duplicates drop cik fyear, force
xtset cik fyear
egen partner_client=group(cik engagementpartnerid)
order cik fyear engagementpartnerid   partner_client
///generate indicator for partner switching
//group clients by client and engagmenetpartner id then say if they changed "groups" they switched partners 
xtset cik fyear
gen f_partner=f.partner_client
gen change_partner_fy=0
replace change_partner_fy=1 if partner_client!=f_partner
// dont include missing future years because we cant determine whether or not that was a switch or the client "died"
replace change_partner_fy=. if missing(f_partner)
xtset cik fyear
gen same_partner_py=0
replace same_partner_py=1 if partner_client==l.partner_client
replace same_partner_py=. if missing(l.partner_client)
//rename variable for easier identification but a partner change indicates changed partners from t to t+1
gen partner_change=change_partner_fy
//generate partner tenure variable to get at whether the change is due to mandatory rotation in year 5 
sort cik fyear
xtset cik fyear 
gen py_partner_change=l.partner_change
gen py2_partner_change=l2.partner_change
gen py3_partner_change=l3.partner_change
gen py4_partner_change=l4.partner_change
bysort cik engagementpartnerid: egen partner_tenurestart=min(fyear)
replace partner_tenurestart = fyear if py_partner_change==1 
gen partner_tenure=fyear-partner_tenurestart
//change this to a 1-5 scale instead of 0-4 
replace partner_tenure=partner_tenure+1
sort cik fyear
xtset cik fyear
replace partner_tenure=l.partner_tenure+1 if partner_client==l.partner_client
///the above is on a 0-4 year scale so update with a plus one to be on a 5 year scale
//replace partner_tenure=partner_tenure+1
///need to account for observations that switched partners and then switched back 
gen excludes_mandatory=0
///0s mean it is either mandatory or unknown 
replace excludes_mandatory=1 if py_partner_change==1 |  py2_partner_change==1 |  py3_partner_change==1 |  py4_partner_change==1  
///if they dont change partners then its not a mandatory rotation
replace excludes_mandatory=1 if partner_change==0
save excludes_mandatory_form_ap, replace 

///use auditor changes database for alt way to specify mandatory rotation tests
use AudChanges20240815, clear
rename *, lower
gen cik = company_fkey
drop if is_benefit_plan==1
keep cik company_fkey dismissed_gc dismissed_disagree auditor_resigned merger curr_audsnc_date  dismiss_date engage_date dismiss_name dismiss_key engaged_auditor_name engaged_auditor_key dismiss_aud_since_date
	 
//drop changes due to mergers
drop if merger==1
	 destring cik, replace
save aa_auditchange1.dta, replace

//use compustat file 
use Compustat, clear
gen l_datadate = datadate-365
 gen f_datadate = datadate+365
destring cik, replace
 
 rangejoin engage_date l_datadate datadate using aa_auditchange1.dta, by(cik)
gsort cik datadate -engage_date // keep last engagement of the year (engage the final year-end auditor)
  duplicates drop cik datadate, force
 drop dismissed_gc dismissed_disagree auditor_resigned merger dismiss_date dismiss_aud_since_date 
 rename engage_date engage_date1
 rename dismiss_name previous_aud_name1
 rename dismiss_key previous_aud_key1
 rename engaged_auditor_name engaged_auditor_name1
 rename engaged_auditor_key engaged_auditor_key1
 
rangejoin dismiss_date datadate f_datadate using aa_auditchange1.dta, by(cik)
gsort cik datadate dismiss_date // keep the first dismissal date in the year (dismiss last years audtor)
  duplicates drop cik datadate, force 
 drop auditor_resigned merger engage_date 
 rename engage_date1 engage_date
 
gen aud_dismissed = 0
  replace aud_dismissed = 1 if dismiss_date!=.
  label variable aud_dismissed "last year of audit"
gen aud_engaged = 0
  replace aud_engaged = 1 if engage_date!=.  
  label variable aud_engaged "first year of audit"
  
//auditor tenure  
  format curr_audsnc_date %td

gen     auditor_start_date = curr_audsnc_date if curr_audsnc_date<=datadate //this gives me the start date of the current auditor
  format auditor_start_date %d
//code pulls the start date of the previous auditor back until there is another start date present in the data 
replace auditor_start_date = dismiss_aud_since_date if dismiss_aud_since_date<=datadate
  format auditor_start_date %td
xtset cik fyear
//carry dismissed auditors back in time
  forvalues i=1/20 {
	replace auditor_start_date = f.auditor_start_date if auditor_start_date==. & f.auditor_start_date<=datadate
}
//carry current auditors forward in time
replace auditor_start_date = engage_date if engage_date<=datadate
forvalues i=1/20 {
	replace auditor_start_date = l.auditor_start_date if auditor_start_date==.
}  
gen aud_tenure1 = ((datadate-auditor_start_date)/365)+0.001
  sum aud_tenure1, d
gen aud_tenure = ceil(aud_tenure1) //Round up
  sum aud_tenure, d
keep cik fyear aud_tenure 
save aud_tenure, replace

merge 1:1 cik fyear using excludes_mandatory_form_ap

replace excludes_mandatory=1 if aud_tenure<5
drop _merge
drop if missing(engagementpartnerid)
save premerge, replace
///some partners are tagged as greater than 5 years these get picked up when we backfill based on no partner change ... examined each of these observations and they have longer than 5 years but no changes in form ap.. exclude these from analysis as precaution on mandatory rotation // see excel sheet for details mandatory rotations in BCRW updated folder
gen py_partner_change_sum=py_partner_change+ py2_partner_change +py3_partner_change+ py4_partner_change
///some have more than 5 years but this isnt due for mandatory change if they have more than one prior change
replace excludes_mandatory=0 if partner_tenure>4 & py_partner_change_sum<1 & partner_change==1	
//cant be mandatory if audit firm tenure is less than 5 years 	
	bysort engagementpartner fyear: egen avg_excludes_mandatory=mean(excludes_mandatory)
	////this will take a value of one when all clients exclude mandatory rotation for that year
gen portfolio_has_no_mandatory=0
replace portfolio_has_no_mandatory=1 if avg_excludes_mandatory==1
duplicates drop engagementpartnerid fyear , force
keep engagementpartnerid fyear portfolio_has_no_mandatory
//these partners are tagged as years where no mandatory rotation
merge 1:m engagementpartnerid fyear using updated_for_analysis_main
keep if _merge==3
drop _merge
gen partner_mandatory_or_unknown=0
replace partner_mandatory_or_unknown=1 if portfolio_has_no_mandatory==0
reg pct_change_audit_fees_w  partner_weakness  $partner_controls  i.fyear if unique_partner1==1 & fyear<2022 & portfolio_has_no_mandatory==1  ,  robust cluster(engagementpartnerid)
gen portfolio_has_mandatory=0
replace portfolio_has_mandatory=1 if portfolio_has_no_mandatory==0
replace portfolio_has_no_mandatory=0 if missing(portfolio_has_no_mandatory)
//global controls winsorized for new sample 
global partner_controls " partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w partner_num_offices_w"

//main table 4 excluding mandatory 
	   eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness  $partner_controls  i.fyear if unique_partner1==1 & fyear<2022 & portfolio_has_no_mandatory==1  ,  robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weakness   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	   partner_weakness   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4b Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weakness  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4b Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weakness  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weakness  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 4b Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			  


/////end mandatory rotation analyses


//alternate way to examine influential client using longer vs shorter tenure of ic audit clients 				   
///now splitting on whether the adverse ico went to a longer or shorter tenured client 		
//THIS IS FOOTNOTE 21 ALTERNATE WAY TO SPECIFY CLIENT INFLUENCE
// tenure variable from mergetocomp from mandatory rotation analysis above 
use mergetocomp, clear
merge 1:1 cik fyear using updated_for_analysis_main
keep if _merge==3
bysort audit_office fyear: egen median_tenure= median(audit_firm_tenure)  if ic_audit==1
///fills in missing when there is only one  ic audit client so take max of the median here
bysort audit_office fyear: egen max_median_tenure=max(median_tenure)
gen weakness_small=0
replace weakness_small=1 if weakness==1 & audit_firm_tenure<max_median_tenure
gen weakness_big=0
replace weakness_big=1 if  weakness==1 & audit_firm_tenure>=max_median_tenure
bysort engagementpartnerid fyear: egen sum_weak_influence=sum(weakness_big) 
gen partner_weak_influence_client=0
replace partner_weak_influence_client=1 if sum_weak_influence>0
gen partner_weak_small=0 
replace partner_weak_small=1 if partner_weakness==1 & partner_weak_influence_client==0

  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table 7 Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

				   //test differences 
qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
	
///////////"correctness" test 1-3 year windows looking at future restatements
	///looking at all misstatements 			
///misstatements updated data

	use "Restatements20240421.dta", clear
	rename *, lower
	rename company_fkey cik
	destring cik, replace
	gen bigr= 0
	replace bigr = 1 if form_fkey == "8-K"
	keep if res_accounting==1 | res_fraud==1
	rename res_begin_date res_begin
	rename res_end_date res_end
	keep cik bigr  res_begin res_end 
	save misstate_updated, replace

use updated_for_analysis_main, clear
joinby cik using misstate_updated, unmatched(master)

gen misstate_updated = 0
replace misstate_updated = 1 if datadate >= res_begin & datadate <= res_end
			
gen misstate_bigr_updated = 0
replace misstate_bigr_updated = 1 if datadate >= res_begin & datadate <= res_end & bigr==1
	
egen group = group(cik fyear)
egen max_misstate = max(misstate_updated), by(group)
drop misstate_updated group
rename max_misstate misstate_updated

egen group = group(cik fyear)
egen max_mistbigr = max(misstate_bigr_updated), by(group)
drop misstate_bigr_updated group
rename max_mistbigr misstate_bigr_updated

duplicates drop cik fyear, force

drop _merge

drop bigr  
keep cik fyear  misstate_updated misstate_bigr_updated  res_begin res_end
duplicates drop cik fyear, force
save restate_updated, replace

use restate_updated, clear
merge 1:1 cik fyear using updated_for_analysis_main
drop if _merge==2
replace misstate_bigr_updated =0 if missing(misstate_bigr_updated)
replace misstate_updated =0 if missing(misstate_updated)
drop _merge 

global partner_controls "partner_resann partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "

gen weak_misstate=0
replace weak_misstate=1 if weakness==1 & misstate_updated==1
bysort engagementpartnerid fyear: egen partner_weak_misst=sum(weak_misstate) 
///make into indicator
replace partner_weak_misst=1 if partner_weak_misst>0
//////now for big misstate 
gen weak_misstate_big=0
replace weak_misstate_big=1 if weakness==1 & misstate_bigr_updated==1
bysort engagementpartnerid fyear: egen partner_weak_misst_big=sum(weak_misstate_big) 
///make into indicator
replace partner_weak_misst_big=1 if partner_weak_misst_big>0
//little r
gen partner_weak_no_misstate=0
replace partner_weak_no_misstate=1 if partner_weakness==1 & partner_weak_misst==0
///big r 
gen partner_weak_no_misstatebig=0
replace partner_weak_no_misstatebig=1 if partner_weakness==1 & partner_weak_misst_big==0
//misstate no weakness
gen misstate_no_weak=0
replace misstate_no_weak=1 if weakness==0 & misstate_updated==1
bysort engagementpartnerid fyear: egen partner_noweak_misst=sum(misstate_no_weak) 
//make into indicator
replace partner_noweak_misst=1 if partner_noweak_misst>0
///make mutually exclusive weakness trumps misstatement
replace partner_noweak_misst=0 if partner_weak_no_misstate==1
replace partner_noweak_misst=0 if partner_weak_misst==1
/// what percent of misstate financies are accompanied by clean ico... want stats on misstate_no_weak misstate
tab misstate_updated misstate_no_weak if fyear<2022
global partner_controls "partner_resann partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "

 eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	partner_weak_no_misstate  partner_weak_misst   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")
	
	////test differences between groups
 qui reg pct_change_avg_fees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 
 qui  reg pct_change_audit_fees_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

qui  reg pct_change_audit_clients_w	partner_weak_no_misstate  partner_weak_misst   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui reg pct_change_avg_404bfees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg pct_change_404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg 	pct_change_404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui reg pct_change_avg_non404bfees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

qui  reg  pct_change_non404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg 	 pct_change_non404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

	
		///loooking at all misstatements but only if they are revealed  within the next year 
use "Restatements20240421.dta", clear
	rename *, lower
	rename company_fkey cik
	destring cik, replace
	gen bigr= 0
	replace bigr = 1 if form_fkey == "8-K"
	keep if res_accounting==1 | res_fraud==1
	rename res_begin_date res_begin
	rename res_end_date res_end
	keep cik bigr  res_begin res_end 
	save misstate_updated, replace

use updated_for_analysis_main, clear

joinby cik using misstate_updated, unmatched(master)

gen misstate_updated = 0
replace misstate_updated = 1 if datadate >= res_begin & datadate <= res_end

gen misstate_bigr_updated = 0
replace misstate_bigr_updated = 1 if datadate >= res_begin & datadate <= res_end & bigr==1
		
egen group = group(cik fyear)
egen max_misstate = max(misstate_updated), by(group)
drop misstate_updated group
rename max_misstate misstate_updated

egen group = group(cik fyear)
egen max_mistbigr = max(misstate_bigr_updated), by(group)
drop misstate_bigr_updated group
rename max_mistbigr misstate_bigr_updated

duplicates drop cik fyear, force

drop _merge

drop bigr  
keep cik fyear  misstate_updated misstate_bigr_updated  res_begin res_end
duplicates drop cik fyear, force
save restate_updated, replace

use restate_updated, clear
merge 1:1 cik fyear using updated_for_analysis_main
drop if _merge==2
replace misstate_bigr_updated =0 if missing(misstate_bigr_updated)
replace misstate_updated =0 if missing(misstate_updated)
drop _merge 

global partner_controls "partner_resann partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "

sort cik fyear
xtset cik fyear
gen f_res_ann=f.res_ann
gen f2_res_ann=f2.res_ann
gen f3_res_ann=f3.res_ann

gen weak_misstate=0
replace weak_misstate=1 if weakness==1 & misstate_updated==1 & f_res_ann==1  
bysort engagementpartnerid fyear: egen partner_weak_misst=sum(weak_misstate) 
///make into indicator
replace partner_weak_misst=1 if partner_weak_misst>0

gen partner_weak_no_misstate=0
replace partner_weak_no_misstate=1 if partner_weakness==1 & partner_weak_misst==0

 eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	partner_weak_no_misstate  partner_weak_misst   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

	////test differences between groups
 qui reg pct_change_avg_fees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 
 qui  reg pct_change_audit_fees_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

qui  reg pct_change_audit_clients_w	partner_weak_no_misstate  partner_weak_misst   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui reg pct_change_avg_404bfees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg pct_change_404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg 	pct_change_404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui reg pct_change_avg_non404bfees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

qui  reg  pct_change_non404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg 	 pct_change_non404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

///loooking at all misstatements but only if they are revealed  within the next 2 years 
use restate_updated, clear
merge 1:1 cik fyear using updated_for_analysis_main
drop if _merge==2
replace misstate_bigr_updated =0 if missing(misstate_bigr_updated)
replace misstate_updated =0 if missing(misstate_updated)
drop _merge 

global partner_controls "partner_resann partner_bign partner_audit_fees_w partner_accel_filer_w partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "

sort cik fyear
xtset cik fyear
gen f_res_ann=f.res_ann
gen f2_res_ann=f2.res_ann
gen f3_res_ann=f3.res_ann

gen weak_misstate=0
replace weak_misstate=1 if weakness==1 & misstate_updated==1 & f_res_ann==1 
replace weak_misstate=1 if weakness==1 & misstate_updated==1 & f2_res_ann==1 


bysort engagementpartnerid fyear: egen partner_weak_misst=sum(weak_misstate) 
///make into indicator
replace partner_weak_misst=1 if partner_weak_misst>0

//little r
gen partner_weak_no_misstate=0
replace partner_weak_no_misstate=1 if partner_weakness==1 & partner_weak_misst==0

 eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	partner_weak_no_misstate  partner_weak_misst   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table r Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")
	////test differences between groups
 qui reg pct_change_avg_fees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 
 qui  reg pct_change_audit_fees_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

qui  reg pct_change_audit_clients_w	partner_weak_no_misstate  partner_weak_misst   $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui reg pct_change_avg_404bfees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg pct_change_404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg 	pct_change_404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui reg pct_change_avg_non404bfees_w partner_weak_no_misstate  partner_weak_misst   $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

qui  reg  pct_change_non404_fees_w partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 

 qui  reg 	 pct_change_non404_clients_w  partner_weak_no_misstate  partner_weak_misst  $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_no_misstate=partner_weak_misst 


///FN 17 conservatism test 

///icmw prediction model 
/// when bound model then replace non ic audits with 0 because they had 0% chance of getting icmw

///using the file from main file that has auditor switching variable for main client level tests
use pre_aicohistorytest, clear
				   
///generate variables for ge et al preidction model
/// need to pull misstate for big dataset because need two prior years of data and this data set ends at 2016 

save prediction_model1, replace 

////go to first file with more years to calculate variables from ge et al.. this comes and is dataset before merging on to partners so we have max observations 

use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\aofeesopinions.dta", clear
merge 1:1 cik fyear using "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\Compustat.dta"
///drop some obs to get to less mem
drop if fyear<2012
///keep everything because we need the extra years that dont merge onto form ap data 
drop _merge

///calculate mve measure of visibility
gen mve=prcc_f*csho

gen sic2=substr(sic,1,2)
destring sic2, replace
gen sic1=substr(sic,1,1)
destring sic1, replace
//gen financial industries
gen financial1=0
replace financial1=1 if sic2>=60 &sic2<=69

/// reg industries 
gen regulated=0
	replace regulated=1 if sic2>43 & sic2<50
	replace regulated=1 if sic2>59 & sic2<70

/// gen foreign
gen foreign1=0
replace foreign1=1 if fic!="USA"

replace foreign1=1 if auditor_country!="USA"
   
gen intangibles = intan/at
gen forops=0
  replace forops=1 if cicurr!=0
gen busy=0
  replace busy=1 if fyr==11|fyr==12|fyr==1
	gen sm_accel_filer=0
	replace sm_accel_filer=1 if is_accel_filer==2 & mkvalt>75 & mkvalt<700
	 replace sm_accel_filer=1 if is_accel_filer==1 & accel_filer_large==0
	gen lg_accel_filer=0
	 replace lg_accel_filer=1 if accel_filer_large==2 & mkvalt>=700
	 replace lg_accel_filer=1 if accel_filer_large==1

gsort cik fyear
xtset cik fyear

//drop if missing(lt)
gen at_lag=l.at
gen at_forward=f.at
gen AA =(at+at_lag)/2
gen ROA=ni/AA
gen roa=ni/at_lag
winsor2 roa
winsor2 ROA
gen ret_on_assets=ib/AA

//drop if missing(AA)
//drop if missing(ROA)
gen leverage= lt/at
gen client_at_growth=(at-at_lag)/at_lag
//drop if missing(client_at_growth)

xtset cik fyear
gen net_assets=ni/(at-lt)
gen net_assets_lag=l.net_assets
gen net_assets_f=f.net_assets
gen net_assets_f2=f2.net_assets

gen at_f=f.at
gen at_f2=f2.at
gen ib_lag=l.ib
gen ib_f=f.ib
gen ib_f2=f2.ib
gen ni_lag=l.ni
gen ni_f=f.ni
gen ni_f2=f2.ni
gen invt_lag=l.invt
gen invt_f=f.invt
gen invt_f2=f2.invt
gen rect_lag=l.rect
gen rect_f=f.rect
gen rect_f2=f2.rect
gen revt_lag=l.revt
gen revt_f=f.revt
gen revt_f2=f2.revt
gen che_lag=l.che
gen che_f=f.che
gen che_f2=f2.che
gen lt_lag=l.lt
gen lt_f=f.lt
gen lt_f2=f2.lt

gen loss=0
replace loss=1 if ni<0

gen acquisition=0
replace acquisition=1 if aqc<0 | aqc>0

gen neg_bv = 0
replace neg_bv = 1 if ceq<0

///altman z
replace act=0 if act==.
replace lct=0 if lct==.

gen x1 = (act - lct)/at
gen x2 = re/at
gen x3 = ebit/at
gen x4 = (csho*prcc_f)/lt
gen x5 = revt/at
gen Z = (1.2*x1) + (1.4*x2) + (3.3*x3) + (.6*x4) + (1*x5)
drop x1 x2 x3 x4 x5

gen altman = Z*-1

gen cash=che/at
gen ln_at=ln(1+at)
gen invrec=(invt+rect)/at

///rsst accruals
gen working_capital=(act-che)-(lct-dlc)
gen iva=ivao+ivaeq
 gen btm= ceq/mve
gen mtb = mve/ceq
gen lnmve = log(mve)
gen lev=lt/at
gen afiler=0
  replace afiler=1 if mve>75

  xtset cik fyear
gen rev_growth = (revt-l.revt)/(l.revt)
gen avg_at =(at+at_lag)/2
gen profitability=ib/avg_at

drop cfo
gen cfo=oancf/avg_at

gen ln_afee=ln(1+audit_fees)
gen clientsize=ln_at

winsor2 client_at_growth invrec leverage ln_at cash 

bysort audit_office fyear: egen ao_cash_m=mean(cash_w)
bysort audit_office fyear: egen ao_clientsize_m=mean(ln_at_w)
bysort audit_office fyear: egen ao_loss_m=mean(loss)
bysort audit_office fyear: egen ao_acq_m=mean(acquisition)
bysort audit_office fyear: egen ao_lev_m=mean(leverage_w)

gen exfinance=(sstk+dltis)/avg_at 

gen proper = .

forvalues i=2016/2022{
probit bign  ln_at acquisition exfinance profitability mtb if fyear==`i'
_predict prop, xb
replace proper=prop if fyear==`i'
drop prop
}

drop rank
egen rank= xtile(proper), by(fyear) nq(20)
bysort fyear rank: egen big4p= mean(bign)
gen cutoff = big4p-.5 if big4p>.5

egen closest = min(cutoff), by(fyear)
gen cut= closest== cutoff
gen cut2 = cut*rank
egen cutrank=max(cut2), by(fyear)
drop big4p cutoff closest cut cut2

gen match1=.
replace match1=0 if rank<cutrank
replace match1=1 if rank>cutrank

gen mismatch= abs(bign-match1)
replace mismatch=0 if match1==.
drop rank cutrank match1

bysort audit_office fyear: egen ao_mismatch_m=mean(mismatch)

gen client_influence= audit_fees/ ao_audit_fees
winsor2 client_influence
gen litigious=0
replace litigious=1 if sic>"2832" & sic<"2838"
replace litigious=1 if sic>"8730" & sic<"8735"
replace litigious=1 if sic>"3569" & sic<"3578"
replace litigious=1 if sic>"7369" & sic<"7374"
replace litigious=1 if sic>"3599" & sic<"3675"
replace litigious=1 if sic>"5199" & sic<"5962"

sort cik datadate
duplicates drop cik datadate, force
gen lag_datadate=datadate-365

 save  compustatAAmerged3_prediction, replace

use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\partnerprecompustat4.dta", clear
merge 1:1 cik fyear using compustatAAmerged3_prediction
///we are keeping anything even if didnt merge 
// keep if _merge==3
 drop _merge

 save partner_pre_res1_prediction, replace
 /////now merge all this on to restatement data and then start tests 
use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\Restatements20230612.dta", clear
rename *, lower
rename company_fkey cik
destring cik, replace

keep if res_accounting==1 | res_fraud==1

rename file_date file_date_restate  
gen big= 0
replace big = 1 if form_fkey == "8-K"

duplicates drop cik file_date_restate, force

joinby cik using compustatAAmerged3_prediction, unmatched(master)

gen res_ann = 0
replace res_ann = 1 if file_date_restate > lag_datadate & file_date_restate <= datadate & datadate!=.	

gen res_ann_big = 0
replace res_ann_big = 1 if file_date_restate > lag_datadate & file_date_restate <= datadate & datadate!=. & big==1

keep res_ann res_ann_big cik datadate    

sort cik datadate
gsort cik datadate -res_ann 
drop if missing(datadate)
duplicates drop cik datadate, force

merge 1:1 cik datadate using compustatAAmerged3_prediction
replace res_ann=0 if _merge==2
replace res_ann_big=0 if missing(res_ann_big)
drop _merge


///////
save mergedrestatement_prediction, replace

// generate misstatement indicators


use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\Restatements20230612.dta", clear
	rename *, lower
	rename company_fkey cik
	destring cik, replace
	gen bigr= 0
	replace bigr = 1 if form_fkey == "8-K"
	keep if res_accounting==1 | res_fraud==1
	rename res_begin_date res_begin
	rename res_end_date res_end
	keep cik bigr  res_begin res_end 
	save misstate_prediction, replace

use mergedrestatement_prediction, clear

joinby cik using misstate_prediction, unmatched(master)

gen misstate = 0
replace misstate = 1 if datadate >= res_begin & datadate <= res_end	
	
gen misstate_bigr = 0
replace misstate_bigr = 1 if datadate >= res_begin & datadate <= res_end & bigr==1
	
egen group = group(cik fyear)
egen max_misstate = max(misstate), by(group)
drop misstate group
rename max_misstate misstate

egen group = group(cik fyear)
egen max_mistbigr = max(misstate_bigr), by(group)
drop misstate_bigr group
rename max_mistbigr misstate_bigr

duplicates drop cik fyear, force

drop _merge

drop bigr  res_begin res_end
keep cik fyear res_ann res_ann_big misstate misstate_bigr
duplicates drop cik fyear, force
save mergedrestatement_prediction, replace

use mergedrestatement_prediction, clear
merge 1:1 cik fyear using compustatAAmerged3_prediction
drop if _merge==2
replace res_ann =0 if missing(res_ann)
replace res_ann_big =0 if missing(res_ann_big)
replace misstate_bigr =0 if missing(misstate_bigr)
replace misstate =0 if missing(misstate)
drop _merge 
save compustatAAmerged4_prediction, replace
/////////////////
 
use compustatAAmerged4_prediction, clear
xtset cik fyear
gen l_misstate=l.misstate
gen l2_misstate=l2.misstate		
///restate 2 is the variable for the ge et al pediction model		   
gen restate2=0
replace restate2=1 if l_misstate==1 | l2_misstate==1

////this is using big restatements

xtset cik fyear
gen l_misstatebig=l.misstate_bigr
gen l2_misstatebig=l2.misstate_bigr	
///restate 2 is the variable for the ge et al pediction model	.. based on descriptives think they use ALL misstatements 	   
gen restate2big=0
replace restate2big=1 if l_misstatebig==1 | l2_misstatebig==1

////generating aggregate loss
gen l_ib=l.ib
gen agg_ib=l_ib+ib
gen agg_loss=0
replace agg_loss=1 if agg_ib<0

///bank ind
destring sic, replace
gen bank_ind=0
replace bank_ind=1 if  sic==6000 | sic>=6010 & sic<=6036 | sic>=6040 & sic<=6062 | sic>=6080 & sic<=6082 | sic>=6090 & sic<=6100 |sic>=6100 & sic<=6113 | sic>= 6120 & sic<=6179 | sic>=6190 & sic<=6199 

//now size // 
gen size= prcc_f*csho
gen ln_size_ge=ln(1+size)

///now cash and cash equivalents 
gen che_at=che/at
gen cash_ge=l.che_at

save prediction_preage, replace

///now add age variable 

use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\compustatage20230301.dta", clear
destring cik, replace
drop if missing(cik)

gsort cik fyear 
duplicates drop cik fyear, force 
bysort cik: egen fyear_start=min(fyear)
keep cik fyear_start
duplicates drop cik fyear_start, force
merge 1:m cik using prediction_preage
drop if _merge==1
///51 from using didnt have so put these as year 
drop _merge
gen age=fyear-fyear_start
gen ln_age=ln(1+age)
save prediction_model3, replace 


/////
////now need to add on segments and institutional ownership
///first merge on segments and datadate

use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\Comp_seg20240321.dta", clear
destring gvkey, gen(gvkey1)
destring cik, replace 
drop if datadate!=srcdate

//now the number of segments
bys gvkey datadate: egen nseg_tot = count(gvkey1)
bys gvkey datadate: egen nseg_bus1=count(gvkey1) if stype=="BUSSEG"
bys gvkey datadate: egen nseg_geo1=count(gvkey1) if stype=="GEOSEG"
bys gvkey datadate: egen nseg_op1=count(gvkey1) if stype=="OPSEG"
bys gvkey datadate: egen nseg_bus=max(nseg_bus1)
bys gvkey datadate: egen nseg_op=max(nseg_op1)
bys gvkey datadate: egen nseg_geo=max(nseg_geo1)
drop nseg_bus1 nseg_geo1 nseg_op1

//fill empty with 1 segment following ge
replace nseg_bus = 1 if nseg_bus==.
replace nseg_op = 1 if nseg_op==.
replace nseg_geo = 1 if nseg_geo==.
gsort gvkey -datadate
drop if missing(gvkey1)
drop if missing(cik)

duplicates tag  cik datadate , generate(cik_dup)
duplicates drop cik datadate nseg_tot, force
keep gvkey  cik datadate nseg_tot nseg_bus nseg_op nseg_geo
//generate segments variable following ge et al as # of bus and geo segments
gen tot_seg=nseg_bus+nseg_geo
save segments1, replace
////
use segments1, clear
merge 1:1 cik datadate using prediction_model3
drop if _merge==1
drop _merge
///replace missing segment disclosures with 1 following ge et al
replace tot_seg=1 if missing(tot_seg)
destring gvkey, replace
drop if missing(gvkey)
duplicates drop gvkey datadate, force
save prediction_model4, replace 
////now add on inst ownership data 
//this file comes from SAS AB
import sas using "C:\Users\lcowle\OneDrive - Colostate\BCRW Updated\ior_gvkeys_03282024.sas7bdat", clear
rename *, lower
///just merge to other data to get inst ownership data 
keep   ior gvkey datadate
format datadate %td
destring gvkey, replace
merge 1:1 gvkey datadate using prediction_model4

//now i want to back up inst ownership by one year
xtset gvkey fyear 
rename ior inst_own
gen l_inst_own=l.inst_own
///replace as zero if missing following ge
replace l_inst_own=0 if missing(l_inst_own)
///keep inst own total segments and merge onto main data set 
keep cik fyear l_inst_own tot_seg
duplicates drop cik fyear l_inst_own , force
drop if missing(cik)
///merge onto data set
merge 1:1 cik fyear using prediction_model4
///replace with 0 if missing inst own following ge et al
replace l_inst_own=0 if missing(l_inst_own)
drop _merge
save prediction_model5, replace
/////now need to add on prior management 
///now look for piror4040302 using management opinions and 302 disclosures.. so first if had ineffective 404a opinion in t-1 of ineffective 302 in the first 3 quarters of prior year... start with 404a 
///start with mgmt 404 a opinions
use  "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\404raw20230612.dta", clear
rename *, lower

gen cik=company_fkey
destring cik, replace
//get management weaknesses
keep if ic_op_type=="m"
keep if is_nth_restate==0
drop if co_is_notick_sub==1 | co_is_shlblnk_nonop==1 | co_is_shlblnk_hldco==1 | co_is_ft==1 | co_is_abs==1 | co_is_reit==1
drop co_is_notick_sub co_is_shlblnk_nonop co_is_shlblnk_hldco co_is_ft co_is_abs co_is_reit
gen fyear = year(fye_ic_op)
gen date = 100*month(fye_ic_op)+day(fye_ic_op)
replace fyear= fyear-1 if date <=531
drop date
gsort cik fyear -count_weak
duplicates drop cik fyear count_weak, force
duplicates drop cik fyear, force
gen mgmt_weakness=0
replace mgmt_weakness=1 if count_weak>0 
replace mgmt_weakness=0 if missing(count_weak)
keep cik fyear  mgmt_weakness
xtset cik fyear
 gen py_mgmt_weakness=l.mgmt_weakness
replace py_mgmt_weakness=0 if missing(py_mgmt_weakness)
keep cik fyear py_mgmt_weakness
///only keep when py mgmt weakness is 1
keep if py_mgmt_weakness==1
keep if fyear>2014
merge 1:1 cik fyear using prediction_model5
drop if _merge==1
replace py_mgmt_weakness=0 if missing(py_mgmt_weakness)
drop _merge
save prediction_model6, replace 

////now need to add quarterly 302 of last year 
///so 302 is ineffective when is_effective field is equal to 0 
//quarter end date is quarter end of disclosure 
	 use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW1\sox302raw20231111.dta", clear
	 rename *, lower
gen cik=company_fkey
destring cik, replace
order cik  period_end_date_num fiscal_ye
///keep only ineffectives 
keep if is_effective=="0"
////gen fiscal year based off period end date (quarter end) and fiscal_ye field 
gen fyear = year(period_end_date_num)
gen date = 100*month(period_end_date_num)+day(period_end_date_num)
///want to drop any 4th quarter 302 because that would coincide with 10k which would be the same as material weakness 
destring fiscal_ye, replace
//this will drop any 4th quarter 302s
drop if date==fiscal_ye
///month date is end of fiscal year... so align with other fyears as back up if before may 31 .. so any quarter that is in the wrong year for fiscal year ends 1/1-5/31 will get scooted back one year
gen  fyear_new= fyear-1 if  fiscal_ye<=531 & date <=531 
replace fyear=fyear-1  if  fiscal_ye<=531 & date <=531 
///if any of the three quarters has quarterly signifcnat deficient or material weakness, want to keep
gen quarterly302weakness=1
 keep fyear cik quarterly302weakness
 duplicates drop cik fyear, force
xtset cik fyear
gen py_302=0
replace py_302=l.quarterly302weakness
keep if py_302==1
merge 1:1 cik fyear using prediction_model6
replace py_302=0 if missing(py_302)
drop if _merge==1
drop _merge
gen prior404302=py_302+py_mgmt_weakness
replace prior404302=1 if prior404302>0
save prediction_model7, replace 

use prediction_model7, clear
keep cik fyear agg_loss  restate2  tot_seg ln_age  bank_ind  ln_size_ge  cash_ge  l_inst_own  prior404302
//client level file is from bcrw table 3 file 
merge 1:1 cik fyear using clientlevel
keep if _merge==3
drop _merge 
mdesc agg_loss  restate2  tot_seg ln_age  bank_ind  ln_size_ge  cash_ge  l_inst_own  prior404302
///////
gen aico_probability=.301*agg_loss +0.94*restate2 +.072*tot_seg-.344*ln_age -.714*bank_ind -.361*ln_size_ge -1.088*cash_ge -1.285*l_inst_own +3.161*prior404302

///exponentiate to bound between 0 and 1 with 1 being higher predicted value 

gen numerator=(exp(aico_probability))
gen denominator=(1+exp(aico_probability))
gen aico_prob_including_nonic=numerator/denominator
gen aico_predicted_prob=numerator/denominator 
///replace with 0 if client doesnt get an ic audit because partner cant give these 
replace aico_predicted_prob=0 if ic_audit==0
//this also works if i instead just estimat aico probability for ic audits and then replace with a 0 value for non ic audits after doing the aico  probability instead of before 

//check sum stats 
asdoc sum aico_probability aico_predicted_prob agg_loss  restate2  tot_seg ln_age  bank_ind  ln_size_ge  cash_ge  l_inst_own  prior404302, stat(N mean sd p25 median p75) append	
global client_controls_main "py_partner_weakness  acquisition  partner_tenure_w  cash_w  client_at_growth_w  ln_at_w expert gco invrec_w leverage2_w loss mismatch roa2_w"
/// compare aico probability amongst ic clients that have a partner weakness and switch partners against those that have partner weakness but dont switch partners 
reg partner_change partner_weakness  $client_controls_main i.fyear i.sic if fyear>2015 &  foreign1==0 & fyear<2022 & ic_audit==1 , robust cluster(cik)
gen difference=weakness-aico_predicted_prob
winsor2 difference 

sort cik fyear
xtset cik fyear
gen l_weakness=l.weakness
gen l_difference=l.difference
gen chg_difference=difference-l_difference
winsor2 chg_difference
sort cik fyear
xtset cik fyear 
gen py_partner_change=l.partner_change
// when an aico client changes partners their subsequent ico is less conservative and they are less likely to get an aico // p value <0.01
reg  weakness c.py_partner_change##c.l_weakness partner_weakness $client_controls_main i.fyear i.sic if fyear>2015 & firm_change!=1 & foreign1==0 & fyear<2022 & ic_audit==1 & partner_change!=., robust cluster(cik)

//this test is untabulated in paper 
reg  chg_difference_w c.py_partner_change##c.l_weakness partner_weakness $client_controls_main i.fyear i.sic if fyear>2015 & firm_change!=1 & foreign1==0 & fyear<2022 & ic_audit==1 & partner_change!=., robust cluster(cik)



//
use updated_for_analysis_main.dta, clear
reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022   , robust cluster(engagementpartnerid)
//untabulated stats 
tab partner_weakness if  partner_404b_count>0 & e(sample)
tab  partner_404b_count if e(sample)


//
use updated_for_analysis_main.dta, clear
reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022   , robust cluster(engagementpartnerid)
//untabulated stats 
tab partner_weakness if  partner_404b_count>0 & e(sample)
tab  partner_404b_count if e(sample)



///add on additional testing we did to remove inherited weakness from the big non big and the influential test
use updated_for_analysis_main, clear	
sort cik fyear
xtset cik fyear 
gen l_weakness=l.weakness
gen inherit_weakness=0
//inherit weakness if youre a new partner py partner change means that they changed from last year to this year so they are new to you and the client had a weakness last year 
replace inherit_weakness=1 if same_partner_py==0 & l_weakness==1 & weakness==1
bysort engagementpartnerid fyear: egen inherited_weakness=sum(inherit_weakness)

///exclude these from big n tests 
 eststo clear
 eststo: qui reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022 & inherited_weakness==0  , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				  
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")		
///test differences
 qui reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
qui  reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
qui  reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig

 qui reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
qui  reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
 qui reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 qui  reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
  
  
  ///excluding from bigger smaller analysis 
  
  
  bysort audit_office fyear: egen median_404fees= median(ic_audit_fees)
///fills in missing when there is only one  ic audit client so take max of the median here
bysort audit_office fyear: egen max_median_fees=max(median_404fees)
gen big_med_client=0
replace big_med_client=1 if audit_fees>=max_median_fees
gen partner_weakness_influence=0
replace partner_weakness_influence=1 if big_med_client==1 & weakness==1
bysort engagementpartnerid fyear: egen sum_weak_influence=sum(partner_weakness_influence) 
gen partner_weak_influence_client=0
replace partner_weak_influence_client=1 if sum_weak_influence>0

gen partner_weak_small=0 
replace partner_weak_small=1 if partner_weakness==1 & partner_weak_influence_client==0

  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022 & inherited_weakness==0 , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")

//test differences 
qui reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022  , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
qui reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

qui  reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

////
  eststo clear
 eststo: qui reg pct_change_avg_fees_w partner_weakness $partner_controls i.fyear if unique_partner1==1 & fyear<2022 & inherited_weakness==0 , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_fees_w  partner_weakness $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_audit_clients_w	  partner_weakness  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , replace b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")	
				   ///total fees
eststo clear
 eststo: qui reg pct_change_avg_404bfees_w partner_weakness $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg pct_change_404_fees_w partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	pct_change_404_clients_w   partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")			   	

	eststo clear
 eststo: qui reg pct_change_avg_non404bfees_w partner_weakness  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
eststo: qui  reg  pct_change_non404_fees_w partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
eststo: qui  reg 	 pct_change_non404_clients_w  partner_weakness $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)

esttab, cells(b(star fmt(3)) t(par fmt(2))) stats(r2 N) varwidth(25) indicate("Year FE = *year" ) label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("Weakness" "CountWeakness")           
esttab using "Table x Main.rtf"             , append b(3) t(2) r2(%9.3f) nogaps varwidth(25) indicate("Year FE = *year") ///
                   stardetach label starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("avg all" "avg 404b" "avg non 404b")
				   
log close

log using "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW JAR Full Log Output 2024 11 29.smcl", append

///add on additional testing we did to remove inherited weakness from the big non big and the influential test excluding partner resann as a control 
use "C:\Users\lcowle\OneDrive - Colostate\JAR Code and Log\BCRW2_Additional\updated_for_analysis_main", clear
sort cik fyear
xtset cik fyear 
gen l_weakness=l.weakness
gen inherit_weakness=0
//inherit weakness if youre a new partner py partner change means that they changed from last year to this year so they are new to you and the client had a weakness last year 
replace inherit_weakness=1 if same_partner_py==0 & l_weakness==1 & weakness==1
bysort engagementpartnerid fyear: egen inherited_weakness=sum(inherit_weakness)

global partner_controls "partner_bign partner_audit_fees_w  partner_expert_w   partner_gcos_w partner_loss_w partner_ma_w partner_num_industries_sic1_w      partner_num_offices_w "

///exclude these from big n tests 
	
///test differences
 reg pct_change_avg_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if unique_partner1==1 & fyear<2022 & inherited_weakness==0 , robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
 reg pct_change_audit_fees_w   partner_weakness_big partner_weakness_nbig $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
reg pct_change_audit_clients_w	    partner_weakness_big partner_weakness_nbig  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig

 reg pct_change_avg_404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
  reg pct_change_404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 reg 	pct_change_404_clients_w    partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
 test partner_weakness_big=partner_weakness_nbig
reg pct_change_avg_non404bfees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
  reg  pct_change_non404_fees_w  partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
 reg 	 pct_change_non404_clients_w   partner_weakness_big partner_weakness_nbig $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
  test partner_weakness_big=partner_weakness_nbig
  
  
  ///excluding from bigger smaller analysis 
  
  
  bysort audit_office fyear: egen median_404fees= median(ic_audit_fees)
///fills in missing when there is only one  ic audit client so take max of the median here
bysort audit_office fyear: egen max_median_fees=max(median_404fees)
gen big_med_client=0
replace big_med_client=1 if audit_fees>=max_median_fees
gen partner_weakness_influence=0
replace partner_weakness_influence=1 if big_med_client==1 & weakness==1
bysort engagementpartnerid fyear: egen sum_weak_influence=sum(partner_weakness_influence) 
gen partner_weak_influence_client=0
replace partner_weak_influence_client=1 if sum_weak_influence>0

gen partner_weak_small=0 
replace partner_weak_small=1 if partner_weakness==1 & partner_weak_influence_client==0

//test differences 
reg pct_change_avg_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if unique_partner1==1 & fyear<2022 & inherited_weakness==0 , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
reg pct_change_audit_fees_w  partner_weak_influence_client partner_weak_small $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small
 reg pct_change_audit_clients_w	  partner_weak_influence_client partner_weak_small  $partner_controls  i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

 reg pct_change_avg_404bfees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

reg pct_change_404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

 reg 	pct_change_404_clients_w   partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

 reg pct_change_avg_non404bfees_w partner_weak_influence_client partner_weak_small  $partner_controls i.fyear if e(sample) , robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

 reg  pct_change_non404_fees_w partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

 reg 	 pct_change_non404_clients_w  partner_weak_influence_client partner_weak_small $partner_controls i.fyear if e(sample), robust cluster(engagementpartnerid)
test partner_weak_influence_client=partner_weak_small

				   
log close