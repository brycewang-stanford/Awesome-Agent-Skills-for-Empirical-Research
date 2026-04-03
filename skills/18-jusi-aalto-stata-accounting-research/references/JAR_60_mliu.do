******************************************************************
******************************************************************
******************** Human vs. Machine **************************
******************************************************************
******************************************************************

local personal "i.age_num i.sex_num i.education_num i.marriage_num i.childamount_num i.resideamount_num i.residediffmonth_num i.residetype_num i.residewith_num i.monthearning_num i.workdiffmonth_num i.workproperties_num i.monthfixedpayout_num i.ishavehometel_num i.ishaveinsurance_num i.ishavecar_num i.ishavehouse_num i.customerfrom_num"
local credit "i.if_loan_over i.if_loan_bad i.if_loan_collateral i.if_loan_credit i.if_loan_house i.if_loan_business i.loan_over_period i.loan_over_amt i.loan_house_num i.loan_other_num i.loancard_num i.loancard_out_card_num i.loancard_out_bank_num i.loan_out_bank_num i.loan_out_num"
local business "i.hukou i.company_type i.job_position i.job_tenure i.loanuse_num i.companypeoplenum_num i.companyage_num i.companyproperties_num i.companytype_num i.businesssite_num i.isbusinessregisterno_num yearprofit"
local accounting "i.supplier i.buyer i.acc_receivable i.acc_payable i.inventory profit_mean profit_vol factin_smean factin_svol factin_lmean factin_lvol rent_mean rent_vol total_mean total_vol i.bank_month_income i.bank_tran_record i.bank_income_period i.alter_contact i.housing i.vehicle i.credit_record i.address_book"
local other "i.applymonth i.busitype_num"

set matsize 8000

******************************************************************
*Section 1: Data Manipulation
******************************************************************
*Loan contract
use Data, clear
gen loan_size_audit = auditmoney/100000
replace applymoney = applymoney/100000
replace approvamoney = approvamoney/100000
replace loan_size_audit = . if loan_size_audit <= 0
gen audit_approved = 1
replace audit_approved = 0 if loan_size_audit == .
gen loan_maturity_audit = auditperiodnum
replace loan_maturity_audit = . if audit_approved == 0
rename financemoney loan_size_signed 
replace loan_size_signed = loan_size_signed/100000
gen loan_approved = 1
replace loan_approved = 0 if approvamoney == .
tab loan_approved
gen loan_turndown = 0
replace loan_turndown = 1 if loan_approved == 1 & loan_size_signed == .
replace loan_turndown = . if loan_approved == 0
tab loan_turndown /*14.79% approved loans are not taken. I treat these as not approved*/
rename signperiodnum loan_maturity_signed
replace loan_maturity_signed = . if loan_approved == 0

replace yearprofit = yearprofit/100000

gen dollar_profit = (profit2-1) * loan_size_signed
replace dollar_profit = 0.001 if dollar_profit == 0
gen ldollar_profit = log(dollar_profit)
gen lloan_size_audit = log(loan_size_audit)
gen lloan_size_signed = log(loan_size_signed)
gen lapplymoney = log(applymoney)

rename approvaempname_num approvaemp_num

gen excess_demand = applymoney - loan_size_signed
gen excess_demand2 = applymoney - approvamoney
label variable excess_demand2 "Excess Credit Demand"
label variable loan_size_signed "Approved Loan Size"

hist excess_demand if excess_demand < 10, bin(30) percent ///
title("Excess Credit Demand") note("1.6% sample < 0")
graph save excess_demand, replace
hist excess_demand2 if excess_demand2 < 10, bin(30) percent ///
title("Histogram of Excess Credit Demand") note("0.17% sample < 0; medium = 1.3")
graph save excess_demand2, replace
hist loan_size_signed if loan_size_signed < 10, bin(30) percent ///
title("Histogram of Approved Loan Size") note(" ")
graph save approved,replace
graph combine excess_demand2.gph approved.gph, ycommon

sum excess_demand2,d
sum loan_size_signed,d

*Sample selection: keep officers with >=500 borrowers
keep if loan_size_audit ~= .
bysort audit_empname_num: egen officer_count = count(loan_size_signed)
drop if officer_count < 500


save Data_model, replace



**********************************************************************
*Section 3: Causal relation between loan size and loan outcome
*           and between loan size and loan turndown
**********************************************************************
use Data_model, clear
bysort audit_empname_num: egen officer_leniency = mean(loan_size_audit)
bysort audit_empname_num: egen officer_leniency2 = mean(loan_size_signed)
gen lofficer_leniency = log(officer_leniency)

hist lloan_size_signed, bin(10)
hist lofficer_leniency, bin(10)

twoway (hist lloan_size_signed, bin(20)) ///
(hist lofficer_leniency, bin(3) bcolor(yellow))

ssc install binscatter
binscatter dollar_profit loan_size_signed, nq(100) ///
xtitle(Loan Size) ytitle(Dollar Profit)


*Test reasons for loan turndown
probit loan_turndown approvamoney applymoney, vce(cluster audit_empname_num)

probit loan_turndown approvamoney applymoney ///
i.applymonth i.audit_empname_num, vce(cluster audit_empname_num)

probit loan_turndown approvamoney applymoney `personal' ///
`credit' `business' `accounting' `other', vce(cluster audit_empname_num)

ivprobit loan_turndown ///
(excess_demand2 = officer_leniency), first 

ivprobit loan_turndown ///
i.applymonth (excess_demand2 = officer_leniency), first 

ivprobit loan_turndown `personal' ///
`credit' `business' `accounting' `other' (excess_demand2 = officer_leniency), first 

reg profit2 loan_size_signed, vce(cluster audit_empname_num) 

reg profit2 loan_size_signed i.applymonth, vce(cluster audit_empname_num) 

reg profit2 loan_size_signed applymoney `personal' ///
`credit' `business' `accounting' `other', vce(cluster audit_empname_num) 

ivregress 2sls profit2 (loan_size_signed = officer_leniency), ///
first vce(cluster audit_empname_num) 

ivregress 2sls profit2 applymoney `personal' ///
`credit' `business' `accounting' (loan_size_signed = officer_leniency), ///
first vce(cluster audit_empname_num) 


reg dollar_profit loan_size_signed, vce(cluster audit_empname_num) 
reg dollar_profit loan_size_signed, vce(bootstrap, cluster(audit_empname_num)) 

reg dollar_profit loan_size_signed i.applymonth, vce(cluster audit_empname_num) 

reg dollar_profit loan_size_signed applymoney `personal' ///
`credit' `business' `accounting' `other', vce(cluster audit_empname_num) 
reg dollar_profit loan_size_signed applymoney `personal' ///
`credit' `business' `accounting' `other', vce(bootstrap, cluster(audit_empname_num)) 

ivregress 2sls dollar_profit (loan_size_signed = officer_leniency), ///
first vce(cluster audit_empname_num) 
ivregress 2sls dollar_profit (loan_size_signed = officer_leniency), ///
first vce(bootstrap, cluster(audit_empname_num)) 
reg loan_size_signed officer_leniency, vce(bootstrap, cluster(audit_empname_num))

ivregress 2sls dollar_profit applymoney `personal' ///
`credit' `business' `accounting' (loan_size_signed = officer_leniency), ///
first vce(cluster audit_empname_num) 
ivregress 2sls dollar_profit applymoney `personal' ///
`credit' `business' `accounting' (loan_size_signed = officer_leniency), ///
first vce(bootstrap, cluster(audit_empname_num))
reg loan_size_signed officer_leniency applymoney `personal' ///
`credit' `business' `accounting', ///
vce(bootstrap, cluster(audit_empname_num))

gen b_profit_loan_size = _b[loan_size_signed]

save Data_model_full_info, replace



**********************************************************************
*Section 3.1: Tests of random assignment
**********************************************************************

*Method 1: Regress officer leniency on borrower characteristics
reg officer_leniency applymoney `personal' ///
`credit' `business' `accounting', ///
vce(cluster, audit_empname_num)

*Method 2: Regress each borrower characteristics on officer leniency
*Continuous variables
reg age officer_leniency, vce(cluster audit_empname_num)
reg childamount_num officer_leniency, vce(cluster audit_empname_num)
*Discrete variables
reg sex_num officer_leniency, vce(cluster audit_empname_num) 
reg education_num officer_leniency, vce(cluster audit_empname_num)
reg marriage_num officer_leniency, vce(cluster audit_empname_num)

*Method 3: Regress each borrower characteristic on officer fixed effects (of that characteristic)
areg age, absorb(audit_empname_num)
areg childamount_num, absorb(audit_empname_num)
areg sex_num, absorb(audit_empname_num)
areg education_num, absorb(audit_empname_num)
areg marriage_num, absorb(audit_empname_num)

gen cont = 1
gen sex_dummy = 0
replace sex_dummy = 1 if sex_num == 2
logit sex_dummy i.audit_empname_num
estimates store A
prob sex_dummy i.applymonth i.audit_empname_num
estimates store B
lrtest A B

**********************************************************************
*Section 4: Identify soft info
**********************************************************************
*1. Regress loan size on hard info variables for each officer
use Data_model_full_info, clear

keep audit_empname_num
duplicates drop audit_empname_num, force
gen officer_index = _n
merge 1:m audit_empname_num using Data_model_full_info
drop _merge
save Data_model_full_info, replace

*Prepare a dataset for R program
keep applybillid loan_size_signed loan_maturity_signed applymoney officer_index ///
`personal' `credit' `business' `accounting' `other'

keep if loan_size_signed ~= .

save Data_ML_H, replace 
export delimited using Data_ML_H, replace


*Identifying soft info using OLS
use Data_model_full_info, clear
egen officer_max = max(officer_index)
local officer_index_max = officer_max

keep if loan_size_signed ~= .

*Fit H(X) for each officer
forvalues i = 1/`officer_index_max' {
 reg loan_size_signed /// /*Note: much more obs if use loan_size_audit*/
 applymoney `personal' `credit' `business' `accounting' `other' if officer_index == `i'
 gen r2_officer_size_`i' = e(r2_a)
 replace r2_officer_size_`i' = 0 if officer_index ~= `i'
 gen N_officer_size_`i' = e(N)
 replace N_officer_size_`i' = 0 if officer_index ~= `i'

 predict hard_size_ols_`i' if e(sample) 
 replace hard_size_ols_`i' = 0 if officer_index ~= `i' 
 predict double soft_size_ols_`i', residuals 
 replace soft_size_ols_`i' = 0 if officer_index ~= `i' 
}

gen hard_size_ols = hard_size_ols_1
gen soft_size_ols = soft_size_ols_1
gen r2_officer_size = r2_officer_size_1
gen N_officer_size = N_officer_size_1

*Collapse to a single column for each variable
foreach varname of varlist hard_size_ols soft_size_ols r2_officer_size N_officer_size  {
 forvalues i =2/`officer_index_max' {
  replace `varname' = `varname' + `varname'_`i' 
 }
 drop `varname'_*
}

bysort officer_index: egen officer_soft_size_ols = sd(soft_size_ols)
bysort officer_index: egen officer_profit2 = mean(profit2)
bysort officer_index: egen officer_default2 = mean(default2)
bysort officer_index: egen officer_audit_length = mean(auditlength)

keep applymonth applybillid default* profit* loss* officer_index loan_size_audit loan_size_signed ///
loan_maturity_audit loan_maturity_signed audit_gender auditlength applymoney ///
weekend friday overtime lunchtime shirktime sex_num salience* ///
officer_soft_size_ols officer_profit2 officer_default2 dollar_profit ///
b_profit_loan_size officer_leniency audit_empname_num ///
hard_size_ols soft_size_ols r2_officer_size N_officer_size Beta_Gender_size officer_audit_length ///
`personal' `credit' `business' `accounting' `other' 
save loan_result, replace 

*Identifying soft info using ML
*Import H(X) from R 
clear
import delimited using data_human_pred
keep applybillid humangbmpred
rename humangbmpred hard_size_gbm
merge 1:1 applybillid using loan_result
drop _merge
gen soft_size_gbm = loan_size_signed - hard_size_gbm
bysort officer_index: egen officer_soft_size_gbm = sd(soft_size_gbm)
save loan_result, replace

duplicates drop officer_index, force
keep r2_officer_size N_officer_size Beta_Gender_size officer_soft_size* officer_profit2 ///
officer_default2 officer_audit_length officer_index officer_leniency

corr officer_soft_size_ols r2_officer_size officer_profit2 officer_default2 N_officer_size officer_audit_length 

corr officer_soft_size_gbm r2_officer_size officer_profit2 officer_default2 N_officer_size officer_audit_length 

save officer_result, replace

*4. Plot histograms
use officer_result, clear
hist r2_officer, bin(20) title("R2 of Loan Size Decision across Officers")
hist Beta_Gender_size, bin(20) title("Gender Coefficient of Loan Size Decision across Officers")
hist officer_soft_size_gbm, bin(20) 
hist officer_audit_length, bin(20)
gen officer_net_profit = officer_profit2 - 1

label variable officer_default2 "officer average default rate"
label variable officer_net_profit "officer average profit rate"

graph twoway (scatter officer_net_profit officer_soft_size_ols) ///
(scatter officer_default2 officer_soft_size_ols) ///
(lfit officer_net_profit officer_soft_size_ols) ///
(lfit officer_default2 officer_soft_size_ols) ///
, xtitle(Officer Soft Information Acquisition Ability) ///
legend(order(1 "officer average profit rate" 2 "officer average defaul rate"))

graph twoway (lfit officer_net_profit officer_soft_size_gbm) (scatter officer_net_profit officer_soft_size_gbm) ///
(lfit officer_default2 officer_soft_size_gbm) (scatter officer_default2 officer_soft_size_gbm) ///
, title("Soft Info and Performance")

graph twoway (lfit r2_officer officer_audit_length) (scatter r2_officer officer_audit_length, yaxis(1)) ///
(lfit officer_soft_size_ols officer_audit_length, yaxis(2)) (scatter officer_soft_size_ols officer_audit_length, yaxis(2))

graph twoway (lfit r2_officer officer_audit_length) (scatter r2_officer officer_audit_length, yaxis(1)) ///
(lfit officer_soft_size_gbm officer_audit_length, yaxis(2)) (scatter officer_soft_size_gbm officer_audit_length, yaxis(2))
 

**************************************************************************
*Section 5: Machine Model M(X)
**************************************************************************
use Data_model_full_info, clear

*Prepare a dataset for R program
keep if profit2 ~= .
keep applybillid profit2 applymoney `personal' `credit' `business' `accounting' `other'
save Data_ML_M,replace 
export delimited using Data_ML_M, replace

*Import M(X) from R 
clear
import delimited using data_machine_pred
keep applybillid gbmpred olspred
replace olspred = "." if olspred == "NA"
destring olspred, replace
rename gbmpred ml_pred_gbm
rename olspred ml_pred_ols
merge 1:1 applybillid using loan_result
drop _merge
gen test_sample = 1
replace test_sample = 0 if ml_pred_gbm == .
save loan_result, replace 


**************************************************************************
*Section 6: Model Performance Comparison
**************************************************************************

*H(X) + S
use loan_result, clear
*keep if hard_size ~= . /*949 obs have missing values in at least one RHS variable*/
keep if profit2 ~= . /* 4 obs*/
gen profit_actual = profit2*loan_size_signed - loan_size_signed 
egen profit_total_actual = sum(profit_actual)
egen loan_size_total_actual = sum(loan_size_signed) 
gen profit_rate_total_actual = profit_total_actual/loan_size_total_actual
bysort applymonth: egen profit_month_actual = sum(profit_actual) 
bysort applymonth: egen loan_size_month_actual = sum(loan_size_signed) 
gen profit_rate_month_actual = profit_month_actual/loan_size_month_actual
save model_compare, replace

*H(X) and S
use model_compare, clear
gen profit_hard_gbm = hard_size_gbm*profit2 - b_profit_loan_size*profit2*soft_size_gbm - hard_size_gbm
gen profit_hard_gbm2 = hard_size_gbm*profit2 - hard_size_gbm /*unadjusted for endogeneity*/
egen profit_total_hard_gbm = sum(profit_hard_gbm)
egen profit_total_hard_gbm2 = sum(profit_hard_gbm2) 
gen profit_rate_total_hard_gbm = profit_total_hard_gbm/loan_size_total
gen profit_rate_total_hard_gbm2 = profit_total_hard_gbm2/loan_size_total
bysort applymonth: egen profit_month_hard_gbm = sum(profit_hard_gbm) 
bysort applymonth: egen profit_month_hard_gbm2 = sum(profit_hard_gbm2) 
gen profit_rate_month_hard = profit_month_hard_gbm/loan_size_month_actual
gen profit_rate_month_hard2 = profit_month_hard_gbm2/loan_size_month_actual

bysort officer_index: egen profit_officer_actual = sum(profit_actual)
bysort officer_index: egen profit_officer_hard_gbm = sum(profit_hard_gbm) 
bysort officer_index: egen loan_size_officer = sum(loan_size_signed)
gen profit_rate_officer_actual = profit_officer_actual/loan_size_officer
gen profit_rate_officer_hard_gbm = profit_officer_hard_gbm/loan_size_officer
gen profit_rate_officer_soft_gbm = profit_rate_officer_actual - profit_rate_officer_hard_gbm
save model_compare, replace

duplicates drop officer_index, force
keep officer_index profit_rate_officer_*
merge 1:m officer_index using officer_result
drop _merge
save officer_result, replace

*plot officer performance
use officer_result, clear
sort profit_rate_officer_actual
gen officer_profit_rank = _n
gen profit_rate_soft = profit_rate_officer_actual /*for graph bar purpose*/
graph twoway (bar profit_rate_soft officer_profit_rank) ///
(bar profit_rate_officer_hard_gbm officer_profit_rank) ///
,title("Officer Performance Decomposition")

*M(X)
use model_compare, clear
keep if test_sample == 1
drop if ml_pred_ols == . /*187 missing*/
bysort applymonth: egen ml_rank_gbm = rank(ml_pred_gbm), unique
bysort applymonth: egen ml_rank_ols = rank(ml_pred_ols), unique 
bysort applymonth: egen human_rank = rank(loan_size_signed) 
save model_compare, replace
*reallocate credit within month and credit demand
use model_compare, clear
keep applymonth loan_size_signed applymoney
bysort applymonth: egen ml_rank_gbm = rank(loan_size_signed), unique
rename loan_size_signed loan_size_ml_gbm /*prepare to assign larger loan size (within month) to higher ml predicted profit borrower*/
replace loan_size_ml_gbm = applymoney if loan_size_ml_gbm > applymoney
merge 1:1 applymonth ml_rank_gbm using model_compare 
drop _merge
gen ml_human_diff_gbm = loan_size_signed - loan_size_ml_gbm 
save model_compare, replace
use model_compare, clear
keep applymonth loan_size_signed applymoney
bysort applymonth: egen ml_rank_ols = rank(loan_size_signed), unique
rename loan_size_signed loan_size_ml_ols /*prepare to assign larger loan size (within month) to higher ml predicted profit borrower*/
replace loan_size_ml_ols = applymoney if loan_size_ml_ols > applymoney
merge 1:1 applymonth ml_rank_ols using model_compare 
drop _merge
gen ml_human_diff_ols = loan_size_signed - loan_size_ml_ols
save model_compare,replace

use model_compare, clear
egen loan_size_total_gbm_test = sum(loan_size_ml_gbm)
gen profit_ml_gbm = loan_size_ml_gbm*(profit2) - loan_size_ml_gbm
*gen profit_ml_gbm = loan_size_ml_gbm*profit2 - b_profit_loan_size*profit2*ml_human_diff_gbm - loan_size_ml_gbm
egen profit_total_ml_gbm = sum(profit_ml_gbm)
bysort applymonth: egen profit_month_ml_gbm = sum(profit_ml_gbm) 
bysort applymonth: egen loan_size_month_gbm_test = sum(loan_size_ml_gbm)
gen profit_rate_total_ml_gbm = profit_total_ml_gbm/loan_size_total_gbm_test
gen profit_rate_month_ml_gbm = profit_month_ml_gbm/loan_size_month_gbm_test

egen loan_size_total_ols_test = sum(loan_size_ml_ols)
gen profit_ml_ols = loan_size_ml_ols*profit2 - b_profit_loan_size*profit2*ml_human_diff_ols - loan_size_ml_ols
egen profit_total_ml_ols = sum(profit_ml_ols)
bysort applymonth: egen profit_month_ml_ols = sum(profit_ml_ols) 
bysort applymonth: egen loan_size_month_ols_test = sum(loan_size_ml_ols)
gen profit_rate_total_ml_ols = profit_total_ml_ols/loan_size_total_ols_test
gen profit_rate_month_ml_ols = profit_month_ml_ols/loan_size_month_ols_test

save model_compare, replace


label variable profit_rate_actual_dt "Actual Profit"
label variable profit_rate_gbm_dt "Profit GBM"
label variable period "month"
label variable profit_rate_rf_dt "Profit Random Forest"
label variable profit_rate_lasso_dt "Profit Lasso"
label variable profit_rate_nnet_dt "Profit Neural Nets"
label variable profit_rate_gbm_off_dt "Profit GBM Officer Specific"

graph twoway (line profit_rate_actual_dt period, lpattern(longdash) lwidth(thick)) ///
(line profit_rate_gbm_dt period, lwidth(thick)) ///
if period < 30

graph twoway (line profit_rate_actual_dt period, lpattern(longdash) lwidth(thick)) ///
(line profit_rate_gbm_dt period, lwidth(thick)) ///
(line profit_rate_gbm_off_dt period, lwidth(thick)) ///
if period < 30

graph twoway (line profit_rate_actual_dt period, lpattern(longdash) lwidth(thick)) ///
(line profit_rate_gbm_dt period, lwidth(medthick)) ///
(line profit_rate_rf_dt period, lwidth(medthick)) ///
(line profit_rate_lasso_dt period, lwidth(medthick)) ///
(line profit_rate_nnet_dt period, lwidth(medthick)) ///
if period < 30

save month_result, replace


*Machine vs. Human performance(Ranking)
*******!!! I should first unique rank before creating deciles
use model_compare, clear
gen human_decile = .
levelsof applymonth, local(tempmonth)
foreach i in `tempmonth' {
 xtile temp_decile = loan_size_signed if applymonth == `i', nq(10)
 replace human_decile = temp_decile if applymonth == `i'
 drop temp_decile
}
gen ml_decile_gbm = .
levelsof applymonth, local(tempmonth)
foreach i in `tempmonth' {
 xtile temp_decile = ml_pred_gbm if applymonth == `i', nq(10)
 replace ml_decile_gbm = temp_decile if applymonth == `i'
 drop temp_decile
}
gen ml_decile_ols = .
levelsof applymonth, local(tempmonth)
foreach i in `tempmonth' {
 xtile temp_decile = ml_pred_ols if applymonth == `i', nq(10)
 replace ml_decile_ols = temp_decile if applymonth == `i'
 drop temp_decile
}
bysort human_decile: egen human_decile_profit = mean(profit2)
bysort ml_decile_ols: egen ml_decile_ols_profit = mean(profit2)
bysort ml_decile_gbm: egen ml_decile_gbm_profit = mean(profit2)
save model_compare, replace

*Decile performance graph
use model_compare, clear
keep human_decile*
duplicates drop human_decile, force
rename human_decile predicted_decile
save decile_performance, replace
use model_compare, clear
keep ml_decile_ols*
duplicates drop ml_decile_ols, force
rename ml_decile_ols predicted_decile
merge 1:1 predicted_decile using decile_performance
drop _merge
save decile_performance, replace
use model_compare, clear
keep ml_decile_gbm*
duplicates drop ml_decile_gbm, force
rename ml_decile_gbm predicted_decile
merge 1:1 predicted_decile using decile_performance
drop _merge
save decile_performance, replace
rename ml_decile_gbm_profit GBM
rename ml_decile_ols_profit OLS
rename human_decile_profit Human
rename predicted_decile predicted_profit_decile
replace Human = Human -1
replace OLS = OLS - 1
replace GBM = GBM - 1
label variable predicted_profit_decile "predicted profit decile"

graph twoway (line Human predicted_profit_decile, lpattern(sold) lwidth(thick)) ///
(line OLS predicted_profit_decile, lpattern(shortdash) lwidth(thick)) ///
(line GBM predicted_profit_decile, lpattern(longdash) lwidth(thick)) ///
, xlab(1(1)10) ytitle("observed profit") 


label variable RF "Random Forest"
label variable predicted_profit_decile "predicted profit decile"
label variable NNet "Neural Nets"

graph twoway (line Human predicted_profit_decile, lpattern(longdash) lwidth(thick)) ///
(line GBM predicted_profit_decile, lwidth(medthick)) ///
(line RF predicted_profit_decile, lwidth(medthick)) ///
(line Lasso predicted_profit_decile, lwidth(medthick)) ///
(line NNet predicted_profit_decile, lwidth(medthick)) ///
, xlab(1(1)10) ytitle("observed profit") 




**************************************************************************
*Section 7: Explaining the Difference between Machine and Human
**************************************************************************
use model_compare, clear

gen ml_human_decile_diff_gbm = abs(ml_decile_gbm - human_decile)
gen ml_human_decile_diff_ols = abs(ml_decile_ols - human_decile)

graph hbar (percent), over(ml_human_decile_diff_gbm) blabel(bar, format(%9.1f)) 

bysort ml_human_decile_diff_gbm: egen ml_human_diff_profit_gbm = mean(profit2)
bysort ml_human_decile_diff_ols: egen ml_human_diff_profit_ols = mean(profit2)

graph twoway scatter ml_human_diff_profit_gbm ml_human_decile_diff_gbm
graph twoway line ml_human_diff_profit_ols ml_human_decile_diff_ols
 
gen misranking = 0
replace misranking = 1 if ml_human_decile_diff_gbm > 1
gen misranking2 = 0
replace misranking2 = 1 if ml_human_decile_diff_gbm > 5

probit misranking i.officer_index /*universal phenomenon*/

probit misranking i.sex_num, vce(cluster officer_index) 

probit misranking i.salience, vce(cluster officer_index) 

probit misranking i.sex_num i.salience, vce(cluster officer_index) 

probit misranking i.sex_num i.salience i.officer_index, vce(cluster officer_index) 

probit misranking i.salience i.officer_index, vce(cluster officer_index) 


probit misranking2 i.officer_index /*universal phenomenon*/

probit misranking2 i.sex_num, vce(cluster officer_index) 

probit misranking2 i.salience, vce(cluster officer_index) 

probit misranking2 i.sex_num i.salience, vce(cluster officer_index) 

probit misranking2 i.sex_num i.salience i.officer_index, vce(cluster officer_index) 

probit misranking2 i.salience i.officer_index, vce(cluster officer_index) 


*Directional misranking
gen ml_human_decile_diff_gbm_d = ml_decile_gbm - human_decile
gen misranking_over = 0
replace misranking_over = 1 if ml_human_decile_diff_gbm_d > 1
gen misranking_under = 0
replace misranking_under = 1 if ml_human_decile_diff_gbm_d < -1
gen misranking2_over = 0
replace misranking2_over = 1 if ml_human_decile_diff_gbm_d > 5
gen misranking2_under = 0
replace misranking2_under = 1 if ml_human_decile_diff_gbm_d < -5

probit misranking_over i.sex_num, vce(cluster officer_index) 

probit misranking_over i.salience, vce(cluster officer_index) 

probit misranking_over i.sex_num i.salience, vce(cluster officer_index) 

probit misranking_over i.sex_num i.salience i.officer_index, vce(cluster officer_index) 

probit misranking_over i.salience i.officer_index, vce(cluster officer_index) 


probit misranking_under i.sex_num, vce(cluster officer_index) 

probit misranking_under i.salience, vce(cluster officer_index) 

probit misranking_under i.sex_num i.salience, vce(cluster officer_index) 

probit misranking_under i.sex_num i.salience i.officer_index, vce(cluster officer_index) 

probit misranking_under i.salience i.officer_index, vce(cluster officer_index) 


probit misranking2_over i.sex_num, vce(cluster officer_index) 

probit misranking2_over i.salience, vce(cluster officer_index) 

probit misranking2_over i.sex_num i.salience, vce(cluster officer_index) 

probit misranking2_over i.sex_num i.salience i.officer_index, vce(cluster officer_index) 

probit misranking2_over i.salience i.officer_index, vce(cluster officer_index) 

probit misranking2_under i.sex_num, vce(cluster officer_index) 

probit misranking2_under i.salience, vce(cluster officer_index) 

probit misranking2_under i.sex_num i.salience, vce(cluster officer_index) 

probit misranking2_under i.sex_num i.salience i.officer_index, vce(cluster officer_index) 

probit misranking2_under i.salience i.officer_index, vce(cluster officer_index) 

save model_compare, replace

*Do officers learn overtime?
use Data, clear
bysort audit_empname_num: egen officer_experience = count(applybillid)
keep audit_empname_num officer_experience
duplicates drop audit_empname_num, force
merge 1:m audit_empname_num using model_compare
keep if _merge == 3
drop _merge

sum officer_experience, d
gen experienced = 0
replace experienced = 1 if officer_experience > r(p50)

probit misranking i.sex_num i.salience ///
if experienced == 0, vce(cluster officer_index) 
probit misranking i.sex_num i.salience ///
i.officer_index if experienced == 0, ///
vce(cluster officer_index) 

probit misranking i.sex_num i.salience ///
if experienced == 1, vce(cluster officer_index) 
probit misranking i.sex_num i.salience ///
i.officer_index if experienced == 1, ///
vce(cluster officer_index) 

probit misranking i.salience ///
if experienced == 0, vce(cluster officer_index) 
probit misranking i.salience ///
i.officer_index if experienced == 0, ///
vce(cluster officer_index) 

probit misranking i.salience ///
if experienced == 1, vce(cluster officer_index) 
probit misranking i.salience ///
i.officer_index if experienced == 1, ///
vce(cluster officer_index) 

probit misranking2 i.sex_num i.salience ///
if experienced == 0, vce(cluster officer_index) 
probit misranking2 i.sex_num i.salience ///
i.officer_index if experienced == 0, ///
vce(cluster officer_index) 

probit misranking2 i.sex_num i.salience ///
if experienced == 1, vce(cluster officer_index) 
probit misranking2 i.sex_num i.salience ///
i.officer_index if experienced == 1, ///
vce(cluster officer_index) 

probit misranking2 i.salience ///
if experienced == 0, vce(cluster officer_index) 
probit misranking2 i.salience ///
i.officer_index if experienced == 0, ///
vce(cluster officer_index) 

probit misranking2 i.salience ///
if experienced == 1, vce(cluster officer_index) 
probit misranking2 i.salience ///
i.officer_index if experienced == 1, ///
vce(cluster officer_index) 

save model_compare, replace

