********************************************************************************************************************************************
*
*  Disclosing Physician Ratings: Performance Effects and the Difficulty of Altering Ratings Consensus
*
*  Henry Eyring
*
*  Steps and program for main empirical analyses
*  Data are confidential and provided by University of Utah Health Care as described in the attached datasheet
*
********************************************************************************************************************************************


********************************************************************************************************************************************
*
** Table 3 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Data.dta", replace

* Code indicator for gender as 1 if Female.
gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Show coefficients on year dummies alone.

reg rating i.year_code, cluster(specialty)

* Estimate effect of disclosure on Rating (without controls vector).

reg rating i.provid i.period i.year_code disclosed_announce, cluster(specialty)

* Estimate effect of disclosure on Rating (include controls vector).

reg rating i.provid i.period i.year_code disclosed_announce charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 4 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate effect of disclosure on Quality Deductions (without controls vector).

reg hac_proc_306090  i.provid i.period i.year_code disclosed_announce, cluster(specialty)

* Estimate effect of disclosure on Quality Deductions (include controls vector).

reg hac_proc_306090  i.provid i.period i.year_code disclosed_announce gender_num charges_num rvus com_index medicare_e week_count age2 age3 age4 age5 age6 age7 age8, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 5 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Time_with_Patient_Data.dta"

* Merge covariates: gender, medicare_exp, rvus, age indicators, com_index, charges_num

merge m:1 unidentifiableid using "/Users/eyring/Documents/DPR Code and Data Sharing Components/Time_with_Patient_Covariates.dta", keep(match master)

**Gender is entered as F or M, recode to 1 or 0 (1=F)

gen gender_num = gender=="F"

**Age indicators are categories outlined by IEA (2020) for health care research.

**age1 = age<5
**age2 = age>4 & age<15
**age3 = age>14 & age<25
**age4 = age>24 & age<35
**age5 = age > 34 & age<45
**age6 = age >44 & age<55 
**age7 = age >54 & age <60 
**age8 = age > 59 

* Generate clinic indicators

tab clinic, gen(clinic_ind)

** Estimate effect of disclosure on Time with Patient (without controls vector).

reg time_with i.period i.provid clinic_ind* i.year_code disclosed_announce, cluster(specialty)

** Estimate effect of disclosure on Time with Patient (include controls vector).

reg time_with i.period i.provid clinic_ind* i.year_code disclosed_announce gender_num charges_num rvus com_ind medicare_exp week_count age2 age3 age4 age5 age6 age7 age8, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 7 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Var_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate effect of disclosure on Absolute Difference (include only sd_per from controls vector).

reg abs_diff i.period i.provid disclosed sd_per, cluster(clinic)

* Estimate effect of disclosure on Absolute Difference (include controls vector).

reg abs_diff i.period i.provid disclosed sd_per charges_num rvus gender medicare_exp firstvis_num week_count early_adol late_adol early_adult middle_adult later_adult old_age eng com_ind, cluster(clinic)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 8 **

* Generate Rating fixed effects for physicians before disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Before_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate physician fixed effects for Rating before disclosure

reg rating i.provid i.year_code charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

* Save results of regression.
regsave using rating_provid_indicators_aft, replace

* Use saved results and keep physician indicators along with coefficients representing physicians' rating fixed effects. 

use rating_provid_indicators_aft, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "99" in 1
destring var1, replace
rename var1 provid
rename coef rating_indicator
keep provid rating_indicator

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Rating_Fixed_Effects_Before.dta", replace


* Generate Rating fixed effects for physicians after disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_After_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate physician fixed effects for Rating after disclosure

reg rating i.provid i.year_code charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

* Save results of regression.
regsave using rating_provid_indicators_aft, replace

* Use saved results and keep physician indicators along with coefficients representing physicians' rating fixed effects. 

use rating_provid_indicators_aft, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "99" in 1
destring var1, replace
rename var1 provid
rename coef rating_indicator
keep provid rating_indicator

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Rating_Fixed_Effects_After.dta", replace


* Generate Quality fixed effects for physicians before disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_Before_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate physician fixed effects for Quality Deductions before disclosure.

reg hac_proc_306090 i.provid i.year_code gender_num charges_num rvus medicare_e week_count com_index age2 age3 age4 age5 age6 age7 age8, cluster(specialty)
regsave using quality_provid_indicators, replace
use quality_provid_indicators, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "974" in 1
destring var1, replace
rename var1 provid
rename coef quality_ind
order provid quality_ind
keep provid quality_ind

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Fixed_Effects_Quality_Before.dta", replace


* Generate Quality fixed effects for physicians after disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_After_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate physician fixed effects for Quality Deductions after disclosure.

reg hac_proc_306090 i.provid i.year_code gender_num charges_num rvus medicare_e week_count com_index age2 age3 age4 age5 age6 age7 age8, cluster(specialty)
regsave using quality_provid_indicators, replace
use quality_provid_indicators, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "974" in 1
destring var1, replace
rename var1 provid
rename coef quality_ind
order provid quality_ind
keep provid quality_ind

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Fixed_Effects_Quality_After.dta", replace


*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 9 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Responses_and_Time_Joint_Data.dta"

* Code indicator for gender as 1 if Female.
gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate pre-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng if before==1, cluster(specialty)

* Estimate post-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng if after==1, cluster(specialty)

* Alternate coding of indicators for age, which is truncated at 89 in the data in compliance with privacy regulations, in categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Estimate pre-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index age2 age3 age3 age5 age6 age7 age8 eng if before==1, cluster(specialty)

* Estimate post-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index age2 age3 age3 age5 age6 age7 age8 eng if after==1, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
*  Disclosing Physician Ratings: Performance Effects and the Difficulty of Altering Ratings Consensus
*
*  Henry Eyring
*
*  Steps and program for main empirical analyses
*  Data are confidential and provided by University of Utah Health Care as described in the attached datasheet
*
********************************************************************************************************************************************


********************************************************************************************************************************************
*
** Table 3 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Data.dta", replace

* Code indicator for gender as 1 if Female.
gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Show coefficients on year dummies alone.

reg rating i.year_code, cluster(specialty)

* Estimate effect of disclosure on Rating (without controls vector).

reg rating i.provid i.period i.year_code disclosed_announce, cluster(specialty)

* Estimate effect of disclosure on Rating (include controls vector).

reg rating i.provid i.period i.year_code disclosed_announce charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 4 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate effect of disclosure on Quality Deductions (without controls vector).

reg hac_proc_306090  i.provid i.period i.year_code disclosed_announce, cluster(specialty)

* Estimate effect of disclosure on Quality Deductions (include controls vector).

reg hac_proc_306090  i.provid i.period i.year_code disclosed_announce gender_num charges_num rvus com_index medicare_e week_count age2 age3 age4 age5 age6 age7 age8, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 5 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Time_with_Patient_Data.dta"

* Merge covariates: gender, medicare_exp, rvus, age indicators, com_index, charges_num

merge m:1 unidentifiableid using "/Users/eyring/Documents/DPR Code and Data Sharing Components/Time_with_Patient_Covariates.dta", keep(match master)

**Gender is entered as F or M, recode to 1 or 0 (1=F)

gen gender_num = gender=="F"

**Age indicators are categories outlined by IEA (2020) for health care research.

**age1 = age<5
**age2 = age>4 & age<15
**age3 = age>14 & age<25
**age4 = age>24 & age<35
**age5 = age > 34 & age<45
**age6 = age >44 & age<55 
**age7 = age >54 & age <60 
**age8 = age > 59 

* Generate clinic indicators

tab clinic, gen(clinic_ind)

** Estimate effect of disclosure on Time with Patient (without controls vector).

reg time_with i.period i.provid clinic_ind* i.year_code disclosed_announce, cluster(specialty)

** Estimate effect of disclosure on Time with Patient (include controls vector).

reg time_with i.period i.provid clinic_ind* i.year_code disclosed_announce gender_num charges_num rvus com_ind medicare_exp week_count age2 age3 age4 age5 age6 age7 age8, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 7 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Var_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate effect of disclosure on Absolute Difference (include only sd_per from controls vector).

reg abs_diff i.period i.provid disclosed sd_per, cluster(clinic)

* Estimate effect of disclosure on Absolute Difference (include controls vector).

reg abs_diff i.period i.provid disclosed sd_per charges_num rvus gender medicare_exp firstvis_num week_count early_adol late_adol early_adult middle_adult later_adult old_age eng com_ind, cluster(clinic)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 8 **

* Generate Rating fixed effects for physicians before disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Before_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate physician fixed effects for Rating before disclosure

reg rating i.provid i.year_code charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

* Save results of regression.
regsave using rating_provid_indicators_aft, replace

* Use saved results and keep physician indicators along with coefficients representing physicians' rating fixed effects. 

use rating_provid_indicators_aft, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "99" in 1
destring var1, replace
rename var1 provid
rename coef rating_indicator
keep provid rating_indicator

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Rating_Fixed_Effects_Before.dta", replace


* Generate Rating fixed effects for physicians after disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_After_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate physician fixed effects for Rating after disclosure

reg rating i.provid i.year_code charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

* Save results of regression.
regsave using rating_provid_indicators_aft, replace

* Use saved results and keep physician indicators along with coefficients representing physicians' rating fixed effects. 

use rating_provid_indicators_aft, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "99" in 1
destring var1, replace
rename var1 provid
rename coef rating_indicator
keep provid rating_indicator

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Rating_Fixed_Effects_After.dta", replace


* Generate Quality fixed effects for physicians before disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_Before_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate physician fixed effects for Quality Deductions before disclosure.

reg hac_proc_306090 i.provid i.year_code gender_num charges_num rvus medicare_e week_count com_index age2 age3 age4 age5 age6 age7 age8, cluster(specialty)
regsave using quality_provid_indicators, replace
use quality_provid_indicators, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "974" in 1
destring var1, replace
rename var1 provid
rename coef quality_ind
order provid quality_ind
keep provid quality_ind

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Fixed_Effects_Quality_Before.dta", replace


* Generate Quality fixed effects for physicians after disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_After_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate physician fixed effects for Quality Deductions after disclosure.

reg hac_proc_306090 i.provid i.year_code gender_num charges_num rvus medicare_e week_count com_index age2 age3 age4 age5 age6 age7 age8, cluster(specialty)
regsave using quality_provid_indicators, replace
use quality_provid_indicators, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "974" in 1
destring var1, replace
rename var1 provid
rename coef quality_ind
order provid quality_ind
keep provid quality_ind

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Fixed_Effects_Quality_After.dta", replace


*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 9 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Responses_and_Time_Joint_Data.dta"

* Code indicator for gender as 1 if Female.
gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate pre-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng if before==1, cluster(specialty)

* Estimate post-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng if after==1, cluster(specialty)

* Alternate coding of indicators for age, which is truncated at 89 in the data in compliance with privacy regulations, in categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Estimate pre-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index age2 age3 age3 age5 age6 age7 age8 eng if before==1, cluster(specialty)

* Estimate post-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index age2 age3 age3 age5 age6 age7 age8 eng if after==1, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
*  Disclosing Physician Ratings: Performance Effects and the Difficulty of Altering Ratings Consensus
*
*  Henry Eyring
*
*  Steps and program for main empirical analyses
*  Data are confidential and provided by University of Utah Health Care as described in the attached datasheet
*
********************************************************************************************************************************************


********************************************************************************************************************************************
*
** Table 3 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Data.dta", replace

* Code indicator for gender as 1 if Female.
gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Show coefficients on year dummies alone.

reg rating i.year_code, cluster(specialty)

* Estimate effect of disclosure on Rating (without controls vector).

reg rating i.provid i.period i.year_code disclosed_announce, cluster(specialty)

* Estimate effect of disclosure on Rating (include controls vector).

reg rating i.provid i.period i.year_code disclosed_announce charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 4 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate effect of disclosure on Quality Deductions (without controls vector).

reg hac_proc_306090  i.provid i.period i.year_code disclosed_announce, cluster(specialty)

* Estimate effect of disclosure on Quality Deductions (include controls vector).

reg hac_proc_306090  i.provid i.period i.year_code disclosed_announce gender_num charges_num rvus com_index medicare_e week_count age2 age3 age4 age5 age6 age7 age8, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 5 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Time_with_Patient_Data.dta"

* Merge covariates: gender, medicare_exp, rvus, age indicators, com_index, charges_num

merge m:1 unidentifiableid using "/Users/eyring/Documents/DPR Code and Data Sharing Components/Time_with_Patient_Covariates.dta", keep(match master)

**Gender is entered as F or M, recode to 1 or 0 (1=F)

gen gender_num = gender=="F"

**Age indicators are categories outlined by IEA (2020) for health care research.

**age1 = age<5
**age2 = age>4 & age<15
**age3 = age>14 & age<25
**age4 = age>24 & age<35
**age5 = age > 34 & age<45
**age6 = age >44 & age<55 
**age7 = age >54 & age <60 
**age8 = age > 59 

* Generate clinic indicators

tab clinic, gen(clinic_ind)

** Estimate effect of disclosure on Time with Patient (without controls vector).

reg time_with i.period i.provid clinic_ind* i.year_code disclosed_announce, cluster(specialty)

** Estimate effect of disclosure on Time with Patient (include controls vector).

reg time_with i.period i.provid clinic_ind* i.year_code disclosed_announce gender_num charges_num rvus com_ind medicare_exp week_count age2 age3 age4 age5 age6 age7 age8, cluster(specialty)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 7 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Var_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate effect of disclosure on Absolute Difference (include only sd_per from controls vector).

reg abs_diff i.period i.provid disclosed sd_per, cluster(clinic)

* Estimate effect of disclosure on Absolute Difference (include controls vector).

reg abs_diff i.period i.provid disclosed sd_per charges_num rvus gender medicare_exp firstvis_num week_count early_adol late_adol early_adult middle_adult later_adult old_age eng com_ind, cluster(clinic)

*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 8 **

* Generate Rating fixed effects for physicians before disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_Before_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate physician fixed effects for Rating before disclosure

reg rating i.provid i.year_code charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

* Save results of regression.
regsave using rating_provid_indicators_aft, replace

* Use saved results and keep physician indicators along with coefficients representing physicians' rating fixed effects. 

use rating_provid_indicators_aft, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "99" in 1
destring var1, replace
rename var1 provid
rename coef rating_indicator
keep provid rating_indicator

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Rating_Fixed_Effects_Before.dta", replace


* Generate Rating fixed effects for physicians after disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Response_After_Data.dta", replace

* Code indicator for gender as 1 if Female.

gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate physician fixed effects for Rating after disclosure

reg rating i.provid i.year_code charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng, cluster(specialty)

* Save results of regression.
regsave using rating_provid_indicators_aft, replace

* Use saved results and keep physician indicators along with coefficients representing physicians' rating fixed effects. 

use rating_provid_indicators_aft, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "99" in 1
destring var1, replace
rename var1 provid
rename coef rating_indicator
keep provid rating_indicator

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Rating_Fixed_Effects_After.dta", replace


* Generate Quality fixed effects for physicians before disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_Before_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate physician fixed effects for Quality Deductions before disclosure.

reg hac_proc_306090 i.provid i.year_code gender_num charges_num rvus medicare_e week_count com_index age2 age3 age4 age5 age6 age7 age8, cluster(specialty)
regsave using quality_provid_indicators, replace
use quality_provid_indicators, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "974" in 1
destring var1, replace
rename var1 provid
rename coef quality_ind
order provid quality_ind
keep provid quality_ind

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Fixed_Effects_Quality_Before.dta", replace


* Generate Quality fixed effects for physicians after disclosure.

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Procedures_After_Data.dta", replace

* Code quality deductions. 

**Note: 
*** hac are hospital acquired conditons, process are deviations from process standards, readmit_30 is readmission occured within 30 days, readmit_60 is readmission occured within 60 days, readmit_90 is readmission within 90 days.
*** readmit_60 is entered as 1 if readmit_30 is 1 (i.e., patient was, by definition, readmitted within 60 days if readmitted within 30 days).
*** readmit 90 is entered as 1 if readmit_60 is 1 (i.e., patient was, by definition, readmitted within 90 days if readmitted within 60 days).
*** Coding for quality deductions below avoids double counting readmissions

gen hac_proc_306090 = hac + process + readmit_30

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_30 == 0 & readmit_60==1

replace hac_proc_306090 = hac_proc_306090 + 1 if readmit_60 == 0 & readmit_90==1

* Code indicator for gender as 1 if Female.

gen gender_num = gender=="F"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (primarypayorcat == "MEDICARE A AND B" | primarypayorcat == "MEDICAID" | primarypayorcat == "MEDICARE PART A" | primarypayorcat == "MEDICARE PART B" | primarypayorcat == "UT MEDICAID")

* Estimate physician fixed effects for Quality Deductions after disclosure.

reg hac_proc_306090 i.provid i.year_code gender_num charges_num rvus medicare_e week_count com_index age2 age3 age4 age5 age6 age7 age8, cluster(specialty)
regsave using quality_provid_indicators, replace
use quality_provid_indicators, clear
keep coef var
split var, p(".")
keep if var2=="provid"
replace var1 = "974" in 1
destring var1, replace
rename var1 provid
rename coef quality_ind
order provid quality_ind
keep provid quality_ind

save "/Users/eyring/Documents/DPR Code and Data Sharing Components/Physician_Fixed_Effects_Quality_After.dta", replace


*
********************************************************************************************************************************************



********************************************************************************************************************************************
*
** Table 9 **

use "/Users/eyring/Documents/DPR Code and Data Sharing Components/Survey_Responses_and_Time_Joint_Data.dta"

* Code indicator for gender as 1 if Female.
gen gender = sex=="Female"

* Code indicators for age, which is truncated at 89 in the data in compliance with privacy regulations. Use age categories as advised by Newman and Newman (2014) to capture changes in psychological function associated with age.

gen early_adol = age>11 & age<18
gen late_adol = age>17 & age<25
gen early_adult = age>24 & age<35
gen middle_adult = age>34 & age<60
gen later_adult = age>59 & age<75
gen old_age = age>74

* Code indicator for payment provided by Medicare or Medicaid.

gen medicare_exp = (modified_pyr == "MEDICARE A AND B" | modified_pyr == "MEDICAID" | modified_pyr == "MEDICARE PART A" | modified_pyr == "MEDICARE PART B" | modified_pyr == "UT MEDICAID")

* Code indicator for visit is patient's first to the physician.

gen firstvis_num = firstvisit=="Yes"

* Code indicator for first language is English.

gen english = itlanguage=="ENG"

* Estimate pre-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng if before==1, cluster(specialty)

* Estimate post-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index early_adol late_adol early_adult middle_adult later_adult old_age eng if after==1, cluster(specialty)

* Alternate coding of indicators for age, which is truncated at 89 in the data in compliance with privacy regulations, in categories as outlined by IEA (2020) for health care research.

gen age1 = age<5
gen age2 = age>4 & age<15
gen age3 = age>14 & age<25
gen age4 = age>24 & age<35
gen age5 = age > 34 & age<45
gen age6 = age >44 & age<55 
gen age7 = age >54 & age <60 
gen age8 = age > 59 

* Estimate pre-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index age2 age3 age3 age5 age6 age7 age8 eng if before==1, cluster(specialty)

* Estimate post-disclosure relationship between Rating and Time with Patient.

reg rating time_with_patient charges_num rvus gender medicare_e firstvis_num week_count com_index age2 age3 age3 age5 age6 age7 age8 eng if after==1, cluster(specialty)

*
********************************************************************************************************************************************




