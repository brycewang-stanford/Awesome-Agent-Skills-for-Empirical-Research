* ====================================================================================================================================
* Date : 01.03.2024
* Paper: Social Comparison on Multiple Tasks - Sacrificing Overall Performance for Local Excellence
*
* This program matches the following databases: 	- 220718 Combined Dataset.dta
*													- StoreData.dta
*													- personell records stata.dta
*
* This program prepares the raw data to a workfile dataset
* ====================================================================================================================================

clear
use "220718 Combined Dataset.dta"

*define variables
label variable v1 “Satzart”
rename  v1 art
label variable v2 “Date”
rename  v2 dat
label variable v3 “Time”
rename  v3 tim
label variable v4 “ScaleID“
rename  v4 idscale
label variable v5 “TransactionID“
rename  v5 idtrans
label variable v6 “EmployeeID“
rename  v6 idempl
label variable v7 “Kennung“
rename  v7 ken
label variable v8 “PLU”
rename  v8 plu
label variable v9 “ProductRange“
rename  v9 prange
label variable v10 “Quantity“
rename  v10 mesu
label variable v11 “Receipt“
rename  v11 recpt
label variable v12 “PriceID“
rename  v12 idprice
label variable v13 “KZStorno1Keinstorno9Storno“
rename  v13 storn
label variable v14 “DepartmentPosOr0Sum“
rename  v14 iddep
label variable v15 “ProductIDPosOr0Sum”
rename  v15 idprod
label variable v16 “RegistercodeSumOrEmptyPos”
rename  v16 regcode
label variable v17 “StoreID“
rename  v17 idstore

*delete individual items so that only the average receipt remains, i.e. each transaction has individual items and a total receipt
drop if ken == 1 
drop if ken == 2

*delete transactions that were not completed, i.e. when customer decides against completing the transaction 
drop if storn == 9

*drop unnecessary variables
drop art
drop plu
drop regcode
drop idprod
drop idprice
drop storn
drop mesu
drop iddep

*create individual employee id based on store number and employees’ id in the scale system
gen IDEMPLSTNR2 = string(idstore) + string(idempl)
destring IDEMPLSTNR2, generate (IDEMPLSTNR)
label variable IDEMPLSTNR “UniqueEmployeeNumber”
drop IDEMPLSTNR2
format %20.0g IDEMPLSTNR

*assign product range to department
*1 = Meat (1); 2 = Fish (6); 3 = Cheese (12, 17); 4 = Sausage (4); 5 = Other (2, 3, 5, 8,13)
gen iddepart = 1 if prange == 1
label variable iddepart “department”

replace iddepart = 1 if prange == 1
replace iddepart = 4 if prange == 4
replace iddepart = 2 if prange == 6
replace iddepart = 3 if prange == 12
replace iddepart = 3 if prange == 17
replace iddepart = 5 if prange == 2
replace iddepart = 5 if prange == 3
replace iddepart = 5 if prange == 5
replace iddepart = 5 if prange == 8
replace iddepart = 5 if prange == 13
drop if iddepart == 5

*generate string variable for department
gen depart = "Meat" 
replace depart = "Fish" if iddepart == 2
replace depart = "Cheese" if iddepart == 3
replace depart = "Sausage" if iddepart == 4

*date variable
tostring dat, replace format(%20.0f)
capture drop edatevar
gen edatevar = date(dat,"YMD")
format edatevar %td
gen year=year(edatevar)
gen month=month(edatevar)
gen day=day(edatevar)

*week
keep if year == 2021 | year==2022
gen int week = floor((edatevar-td(04jan2021))/7) + 1 if year==2021
gen int week22 = floor((edatevar-td(03jan2022))/7) + 1 if year==2022
replace week=week22 if year==2022

*merge store data
merge m:1 idstore using "STATA/StoreData.dta"

*only keep stores that are part of the experiment
keep if _merge == 3

*merge personell records
drop _merge 
merge m:m IDEMPLSTNR using "personell records stata.dta"
keep if _merge == 3 // only include employees who also have personnel records.
drop _merge

save "2200718 Workfile Dataset.dta", replace

* ====================================================================================================================================
* Date : 01.03.2024
* Paper: Social Comparison on Multiple Tasks - Sacrificing Overall Performance for Local Excellence
*
* This program matches the following databases: 	- departmentassignment.dta
*													- treatmentassaignment_priorexp.dta
*													- treatmentassignment_exp_final.dta
*													- usage_rate til 07.07.22_collapsed.dta
*													- 220715 Work Time Records Collapsed.dta
* This program prepares the dataset for analysis
* This program contains all relevant steps for analysis
* ====================================================================================================================================


use "2200718 Workfile Dataset.dta" , clear

*****************************************************************************************************************************************************
************************************************     DATA PREPARATION        *********************************************************************
*****************************************************************************************************************************************************
	
***************************************************************************
**## Dataset Set Up
***************************************************************************
	
*time variable for weeks 2021 and 2022
capture drop time
gen time=week if year==2021
replace time=week+52 if year==2022

*merge
capture drop _merge

*employees department assignment
merge m:1 persnr using "departmentassignment.dta"
capture drop _merge
*treatment assignment prior experiment
merge m:1 idstore using "treatmentassignment_priorexp.dta"
capture drop _merge
*treatment assignmant experiment JAR Social Comparison on Multiple Tasks
merge m:1 idstore using "treatmentassignment_exp_final.dta"
capture drop _merge
*usage rate data on employee level on a daily basis
merge m:1 persnr time using "usage_rate til 07.07.22_collapsed.dta"
capture drop _merge
*work time records of individual employees
merge m:1 persnr time using "220715 Work Time Records Collapsed.dta"
capture drop _merge

rename treatment treatment_old
rename treatment2 treatment

*employee numbers without age are anonymous numbers for short-term employees (<4 weeks)
drop if age =="0,01"
destring age, replace
drop if age==.
drop if time<31

destring ten, replace

sum recpt, d  
winsor2 recpt, cuts(1 99)  suf(_win_e)

drop recpt
rename recpt_win_e recpt
drop if recpt==.
		
		
*Amount of customers
*persnr week
bys persnr time: egen N_meat=count(depart) if depart=="Meat"
bys persnr time: egen N_saus=count(depart) if depart=="Sausage"
bys persnr time: egen N_butch=count(depart) if depart=="Meat" | depart=="Sausage"
bys persnr time: egen N_cheese=count(depart) if depart=="Cheese"
bys persnr time: egen N_fish=count(depart) if depart=="Fish"
bys persnr time: egen N_overall=count(depart)
			
*idstore week
bys idstore time: egen N_meat_store=count(depart) if depart=="Meat"
bys idstore time: egen N_saus_store =count(depart) if depart=="Sausage"
bys idstore time: egen N_butch_store =count(depart) if depart=="Meat" | depart=="Sausage"
bys idstore time: egen N_cheese_store =count(depart) if depart=="Cheese"
bys idstore time: egen N_fish_store =count(depart) if depart=="Fish"
bys idstore time: egen N_overall_store =count(depart)					

*Sales
*persnr week
bys persnr time: egen Sales_meat=sum(recpt) if depart=="Meat"
bys persnr time: egen Sales_saus=sum(recpt) if depart=="Sausage"
bys persnr time: egen Sales_butch=sum(recpt) if depart=="Meat" | depart=="Sausage"
bys persnr time: egen Sales_cheese=sum(recpt) if depart=="Cheese"
bys persnr time: egen Sales_fish=sum(recpt) if depart=="Fish"
bys persnr time: egen Sales_overall=sum(recpt)

*idstore week
bys idstore time: egen Sales_meat_store =sum(recpt) if depart=="Meat"
bys idstore time: egen Sales_saus_store =sum(recpt) if depart=="Sausage"
bys idstore time: egen Sales_butch_store =sum(recpt) if depart=="Meat" | depart=="Sausage"
bys idstore time: egen Sales_cheese_store =sum(recpt) if depart=="Cheese"
bys idstore time: egen Sales_fish_store =sum(recpt) if depart=="Fish"
bys idstore time: egen Sales_overall_store =sum(recpt)

*Avg Sale per customers
*persnr week
bys persnr time: egen AvgS_meat=mean(recpt) if depart=="Meat"
bys persnr time: egen AvgS_saus=mean(recpt) if depart=="Sausage"
bys persnr time: egen AvgS_butch=mean(recpt) if depart=="Meat" | depart=="Sausage"
bys persnr time: egen AvgS_cheese=mean(recpt) if depart=="Cheese"
bys persnr time: egen AvgS_fish=mean(recpt) if depart=="Fish"
bys persnr time: egen AvgS_overall=mean(recpt)

*idstore week
bys idstore time: egen AvgS_meat_store =mean(recpt) if depart=="Meat"
bys idstore time: egen AvgS_saus_store =mean(recpt) if depart=="Sausage"
bys idstore time: egen AvgS_butch_store =mean(recpt) if depart=="Meat" | depart=="Sausage"
bys idstore time: egen AvgS_cheese_store =mean(recpt) if depart=="Cheese"
bys idstore time: egen AvgS_fish_store =mean(recpt) if depart=="Fish"
bys idstore time: egen AvgS_overall_store =mean(recpt)
 
*gender
encode gender, gen(gen)

*keep only transactions from employees of the butchery department
keep if final_department=="Fleisch"

*drop weeks ex-post the experiment
drop if time>76

collapse ///
(firstnm) ///
final_department referencegroup departement_unclear  /// 
(max) ///
h_worked absent active gen age ten treatment treatment_old /// persnr
clength stsize idstore border_fr border_ch location_large locatoin_medium locatin_small butchers hotcounter /// idstore
N_meat N_saus N_cheese N_fish N_butch N_overall AvgS_meat AvgS_saus AvgS_cheese AvgS_fish AvgS_butch AvgS_overall Sales_meat Sales_saus Sales_cheese Sales_fish Sales_butch Sales_overall /// persnr time
N_meat_store N_saus_store N_cheese_store N_fish_store N_butch_store N_overall_store AvgS_meat_store AvgS_saus_store AvgS_cheese_store AvgS_fish_store AvgS_butch_store AvgS_overall_store Sales_meat_store Sales_saus_store Sales_cheese_store Sales_fish_store Sales_butch_store Sales_overall_store /// idstore time
, by(persnr time)

save "weekly_data_empl_exp2_win_MK_collapsed_weekly.dta", replace
		
***************************************************************************
**##  Variables for Analysis    
***************************************************************************	

clear
use "weekly_data_empl_exp2_win_MK_collapsed_weekly.dta"
	
**## calculate the number of weeks an employee worked during the experiment
gen during_experiment = 0
replace during_experiment = 1 if time >= 64 & time <= 76
bys persnr: egen worked_during=count(AvgS_butch) if during_experiment == 1 & absent !=. & absent !=1
bys persnr: egen howoften = max(worked_during)

*only include employees who worked >= 4 weeks
gen include_analysis = 0
replace include_analysis = 1 if howoften >=4 & howoften != .

**## treatment variables
*current experiment
*treatment started in week 12 2022. Week 12 == time 64
gen time_treatment= (time>=64)
gen treatment_Seperate=0
gen treatment_Both=0
replace treatment_Seperate=treatment*time_treatment if treatment==0|treatment==1
replace treatment_Both=treatment*time_treatment if treatment==0|treatment==2
replace treatment_Both=1 if treatment_Both==2
*old treatment variables
gen time_treatment_old=0
replace time_treatment_old=1 if time>=44 & time<57
gen old_treatment_MED=0
gen old_treatment_DEC=0
replace old_treatment_MED=treatment_old*time_treatment_old if treatment_old==0|treatment_old==1
replace old_treatment_DEC=treatment_old*time_treatment_old if treatment_old==0|treatment_old==2
replace old_treatment_DEC=1 if old_treatment_DEC==2

**## RPI usage rate
*usage data can be interpreted from week 64 on. In time 62 and 63 reports were adjusted to the treatment designs
gen active_prior=active if time<64
gen active_during=active if time>=64

capture drop active1
gen active1=.
replace active1=0 if active_during==0
replace active1=1 if active_during>0 & active_during!=.

*number of weeks in which an employee opened his/her report
bys persnr: egen Nactive = sum (active1) if time >=64
bys persnr: egen N_active = max (Nactive)

*variables for instrumental variable regression
bys persnr: egen active_once_during=max(active1)
gen active_twice_during = 0
replace active_twice_during = 1 if N_active > 1 & N_active != .
gen active_thrice_during = 0
replace active_thrice_during = 1 if N_active > 2 & N_active != .

*instrument participated in treatment
gen active_Seperate_1 = 0
replace active_Seperate_1 = treatment_Seperate * active_once_during if time >= 64
gen active_Both_1 = 0
replace active_Both_1 = treatment_Both * active_once_during if time >= 64

*instrument participated in treatment at least twice
gen active_Seperate_2 = 0
replace active_Seperate_2 = treatment_Seperate * active_twice_during if time >= 64
gen active_Both_2 = 0
replace active_Both_2 = treatment_Both * active_twice_during if time >= 64

*instrument participated in treatment at least thrice
gen active_Seperate_3 = 0
replace active_Seperate_3 = treatment_Seperate * active_thrice_during if time >= 64
gen active_Both_3 = 0
replace active_Both_3 = treatment_Both * active_thrice_during if time >= 64

*continuous instrument participated in treatment
gen active_Seperate_N = 0
replace active_Seperate_N = treatment_Seperate * N_active if time >= 64
gen active_Both_N = 0
replace active_Both_N = treatment_Both * N_active if time >= 64

*variable for noncompliers
gen notdone = 0
replace notdone =1 if ((treatment_Seperate==1 | treatment_Both ==1) & (active==0))

save "weekly_data_empl_exp2_win_MK_STEP1.dta", replace

use "weekly_data_empl_exp2_win_MK_STEP1.dta",clear

**## variable focus better
*performance decile per task including all employees as displayed in the app
bys referencegroup time: egen decile_butch = xtile(AvgS_butch), n(10)
replace decile_butch = 0 if decile_butch ==.
bys referencegroup time: egen decile_meat = xtile(AvgS_meat), n(10)
replace decile_meat = 0 if decile_meat ==. 
bys referencegroup time: egen decile_sausage = xtile(AvgS_saus), n(10)
replace decile_saus = 0 if decile_saus ==.

*dummy variable task_better which is 1 if better at meat and 2 if better at sausage and 0 if equal
gen task_better = .
replace task_better = 1 if decile_meat > decile_sausage
replace task_better = 2 if decile_saus > decile_meat

*generate variable sales_better
gen Sales_better = .
replace Sales_better = Sales_meat if task_better == 1
replace Sales_better = Sales_saus if task_better == 2

*generate variables contribution_better contribution_worse
gen contribution_better = .
replace contribution_better = Sales_better/Sales_butch
replace contribution_better = . if contribution_better == 1  // If employees focus 100% on one task one cannot say that it is the task in which they perform relatively better. Thus they do not get assigned a value for contribution_better
gen contribution_worse = .
replace contribution_worse = 1-contribution_better if contribution_better != .

*generate focus_better
gen focus_better = .
replace focus_better = contribution_better - contribution_worse

**## variable contribution meat
gen contribution_meat = .
replace contribution_meat = Sales_meat / Sales_butch
replace contribution_meat = 0 if Sales_meat ==. & Sales_butch !=.

**## variable high performer overall prior
*4 weeks prior
bys persnr: egen AvgS_butchprior4 = mean (AvgS_butch) if time>=60 & time < 64 & include_analysis == 1 & absent != 1 & absent !=.
bys persnr: egen AvgS_butch_prior4 = max (AvgS_butchprior4)

egen AvgS_butch_priordecile4 = xtile(AvgS_butch_prior) if time >= 60 & time < 64 & include_analysis == 1 & absent != 1 & absent !=., n(2)
bys persnr: egen AvgS_butch_prior_decile4 = max (AvgS_butch_priordecile4)
	
replace AvgS_butch_prior_decile4 = 0 if AvgS_butch_prior_decile4 == 1
replace AvgS_butch_prior_decile4 = 1 if AvgS_butch_prior_decile4 == 2
	
rename AvgS_butch_prior_decile4 High_Performer_Prior4

*8 weeks prior
bys persnr: egen AvgS_butchprior8 = mean (AvgS_butch) if time>=56 & time < 64 & include_analysis == 1 & absent != 1 & absent !=.
bys persnr: egen AvgS_butch_prior8 = max (AvgS_butchprior8)

egen AvgS_butch_priordecile8 = xtile(AvgS_butch_prior8) if time >= 56 & time < 64 & include_analysis == 1 & absent != 1 & absent !=., n(2)
bys persnr: egen AvgS_butch_prior_decile8 = max (AvgS_butch_priordecile8)
	
replace AvgS_butch_prior_decile8 = 0 if AvgS_butch_prior_decile8 == 1
replace AvgS_butch_prior_decile8 = 1 if AvgS_butch_prior_decile8 == 2
	
rename AvgS_butch_prior_decile8 High_Performer_Prior8

**## variable top tercile overall prior
*8 weeks prior
egen AvgS_butch_priortertial8 = xtile(AvgS_butch_prior8) if time >= 56 & time < 64 & include_analysis == 1 & absent != 1 & absent !=., n(3)
bys persnr: egen AvgS_butch_prior_tertial8 = max (AvgS_butch_priortertial8)
	
replace AvgS_butch_prior_tertial8 = 0 if AvgS_butch_prior_tertial8 == 1 | AvgS_butch_prior_tertial8 == 2
replace AvgS_butch_prior_tertial8 = 1 if AvgS_butch_prior_tertial8 == 3
	
rename AvgS_butch_prior_tertial8 Top_Performer_Prior8

**## variable top quartile overall prior
*8 weeks prior
egen AvgS_butch_priorquartile8 = xtile(AvgS_butch_prior8) if time >= 56 & time < 64 & include_analysis == 1 & absent != 1 & absent !=., n(4)
bys persnr: egen AvgS_butch_prior_quartile8 = max (AvgS_butch_priorquartile8)
	
replace AvgS_butch_prior_quartile8 = 0 if AvgS_butch_prior_quartile8 == 1 | AvgS_butch_prior_quartile8 == 2 | AvgS_butch_prior_quartile8 == 3
replace AvgS_butch_prior_quartile8 = 1 if AvgS_butch_prior_quartile8 == 4
	
rename AvgS_butch_prior_quartile8 Top_Quartile_Prior8

**## variable focus meat prior 
*8 weeks prior
bys persnr: egen contribution_meatprior8 = mean (contribution_meat) if time>=56 & time < 64 & include_analysis == 1 & absent != 1 & absent !=.
bys persnr: egen contribution_meat_prior8 = max (contribution_meatprior8)
	
egen contribution_meat_priordecile8 = xtile(contribution_meat_prior8) if time >= 56 & time < 64 & include_analysis == 1 & absent != 1 & absent !=., n(2)
bys persnr: egen contribution_meat_prior_decile8 = max (contribution_meat_priordecile8)
	
replace contribution_meat_prior_decile8 = 0 if contribution_meat_prior_decile8 == 1
replace contribution_meat_prior_decile8 = 1 if contribution_meat_prior_decile8 == 2
	
rename contribution_meat_prior_decile8 Focus_Meat_Prior8

**## variable average sale per transaction store level considering only transactions of employees that are included in the analysis
*1. Calculate weekly sum of sales and transactions per store from employees who worked at least 4 weeks during the experiment and were not absent in the specific week
bys idstore time: egen Sales_meat_store_include =sum(Sales_meat) if include_analysis == 1 & absent != 1 & absent != .
bys idstore time: egen Sales_saus_store_include =sum(Sales_saus) if include_analysis == 1 & absent != 1 & absent != .
bys idstore time: egen Sales_butch_store_include =sum(Sales_butch) if include_analysis == 1 & absent != 1 & absent != .
bys idstore time: egen N_meat_store_include =sum(N_meat) if include_analysis == 1 & absent != 1 & absent != .
bys idstore time: egen N_saus_store_include  =sum(N_saus) if include_analysis == 1 & absent != 1 & absent != .
bys idstore time: egen N_butch_store_include =sum(N_butch) if include_analysis == 1 & absent != 1 & absent != .
*2. Calculate average sale per transaction on store level by dividing (sum) tales / (sum) transactions  
gen AvgS_meat_store_include = Sales_meat_store_include/N_meat_store_include
gen AvgS_saus_store_include = Sales_saus_store_include/N_saus_store_include
gen AvgS_butch_store_include = Sales_butch_store_include/N_butch_store_include
		
	
save "weekly_data_empl_exp2_win_MK.dta", replace

*****************************************************************************************************************************************************
************************************************     DATA ANALYSIS        *********************************************************************
*****************************************************************************************************************************************************
cd "Analysen"
use "weekly_data_empl_exp2_win_MK.dta",clear
xtset persnr time
drop if time>76 // the experiment ended in week 24 2022, i.e. time == 76

***************************************************************************	
**## Employees Task Composition
***************************************************************************

	
preserve


gen task_compprior = N_meat/N_butch if time >= 56 & time <64 
bys persnr: egen task_comp_prior = mean(task_compprior) if time >= 56 & time <64 
bys persnr: egen sd_task_comp_prior = sd(task_compprior) if time >= 56 & time <64

collapse (max) task_comp_prior sd_task_comp_prior if time >=56 & time < 64 & include_analysis == 1, by(persnr)

**## Figure 1 - Multiple Tasks in the Butchery Department
	
sum task_comp_prior if task_comp_prior !=. , d 
sum sd_task_comp_prior if sd_task_comp_prior != ., d

sum persnr

histogram task_comp_prior if task_comp_prior !=., /// 
	frequency ///
	bin(10) gap(20) bcolor(gs9) ///
	xtitle("Task Composition = Number Transactions Meat / Number Transactions Overall", size(small)) ///
	xscale(range(0 1.05)) ///
	xlabel(,  glcolor(gs12) labsize(small)) ///
	ytitle("Number of Employees", size(small))  ///
	ylabel(20 "20" 40 "40" 60 "60" 80 "80" 100 "100" , glcolor(gs12) labsize(small)) ///
	graphregion(color(white)) ///
	plotregion(lcolor(black) istyle(white) icolor(white) ifcolor(white)) fxsize(100) 
	
graph export "Figure1_TaskComposition.png", as(png) name("Graph") replace
		

restore

***************************************************************************	
**## Descriptive Balance Tables
***************************************************************************
*ssc install stddiff	
	
**## Table1: Descriptive Statistics
**## Employee descriptives - time constant. Only 1 dataset per employee
preserve
keep if include_analysis == 1
collapse (max) gen age ten, by(persnr treatment)
*gen = 1 is female gen = 0 is male
replace gen = 0 if gen == 2
summarize gen age ten, detail
stddiff gen age ten if treatment == 0 | treatment == 1, by(treatment)
stddiff gen age ten if treatment == 0 | treatment == 2, by(treatment)
restore

**## Store descriptives - time constant. Only 1 dataset per store
preserve 
collapse (max) stsize clength, by(idstore treatment)
summarize stsize clength, detail
restore

**## Compliance with treatment in each treatment group. Only 1 dataset per employee
preserve
keep if include_analysis == 1
collapse (max) active_once_during, by(persnr treatment idstore)
summarize active_once_during
restore

**## Performance descriptives - time variable. Only 1 employee dataset per week
preserve
keep if time >= 56 & time < 64 & include_analysis == 1 & absent !=. & absent !=1
collapse (mean) Sales_butch Sales_saus Sales_meat AvgS_butch AvgS_saus AvgS_meat, by (persnr treatment time)
tabstat AvgS_saus, stat(mean sd)
collapse (mean) Sales_butch Sales_saus Sales_meat AvgS_butch AvgS_saus AvgS_meat, by (persnr treatment)
summarize Sales_butch Sales_saus Sales_meat AvgS_butch AvgS_saus AvgS_meat, detail
restore

**## Contribution meat ex-ante the experiment
preserve
keep if time >= 56 & time < 64 & include_analysis == 1 & absent !=. & absent !=1
collapse (mean) contribution_meat, by (persnr treatment)
summarize contribution_meat, detail
sort treatment
by treatment: summarize contribution_meat
restore

**## Focus Better ex-ante the experiment
preserve
keep if time >= 56 & time < 64 & include_analysis == 1 & absent !=. & absent !=1
bys persnr: egen sd_focus_better = sd(focus_better)
collapse (mean) focus_better sd_focus_better, by (persnr treatment)
histogram sd_focus_better
summarize focus_better, detail
restore

		
**## Table A 1 Descriptive Statistics Over Time
preserve
replace gen = 0 if gen == 2 // gen = 1 is female gen = 0 is male
collapse (mean) AvgS_butch (max) gen age ten include_analysis absent if time >= 64 & time <= 67, by(persnr)
asdoc sum gen age ten if include_analysis == 1 & absent != . & AvgS_butch != . , stat(N mean sd p25 p75) label save(descriptive_64to67.doc) dec(3) replace
restore

preserve
replace gen = 0 if gen == 2 // gen = 1 is female gen = 0 is male
collapse (mean) AvgS_butch (max) gen age ten include_analysis absent if time >= 68 & time <= 71, by(persnr)
asdoc sum gen age ten if include_analysis == 1 & absent != . & AvgS_butch != . , stat(N mean sd p25 p75) label save(descriptive_68to71.doc) dec(3) replace
restore

preserve
replace gen = 0 if gen == 2 // gen = 1 is female gen = 0 is male
collapse (mean) AvgS_butch (max) gen age ten include_analysis absent if time >= 72 & time <= 76, by(persnr)
asdoc sum gen age ten if include_analysis == 1 & absent != . & AvgS_butch != . , stat(N mean sd p25 p75) label save(descriptive_72to76.doc) dec(3) replace
restore

***************************************************************************	
**## Power Analysis
***************************************************************************
*"Panel data and experimental design, Burlig et al. (2020)" https://static1.squarespace.com/static/558eff8ce4b023b6b855320a/t/5e836c3a49d2885be17a7c0c/1585671232161/BPW_JDE.pdf
cd "Analysen"
use "weekly_data_empl_exp2_win_MK.dta",clear
xtset persnr time
		
drop if time<31
drop if time>54		
		
distinct time
unique persnr
 
set seed 123
pc_simulate AvgS_butch, model(DD)  n(490) p(0.333) pre(12) post(12) mde(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1) i(persnr) t(time) absorb(persnr time) vce(cluster idstore)  nsim(500) out(power_calcs_490) replace
 
pc_simulate AvgS_butch, model(DD)  n(245) p(0.333) pre(12) post(12) mde(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1) i(persnr) t(time) absorb(persnr time) vce(cluster idstore)  nsim(500) out(power_calcs_245) replace

pc_simulate AvgS_butch, model(DD)  n(125) p(0.333) pre(12) post(12) mde(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1) i(persnr) t(time) absorb(persnr time) vce(cluster idstore)  nsim(500) out(power_calcs_125) replace

clear
import delimited "power_calcs_490.csv"
save "power_calcs_490.dta", replace

clear
import delimited "power_calcs_245.csv"
save "power_calcs_245.dta", replace

clear
import delimited "power_calcs_125.csv"
save "power_calcs_125.dta", replace

clear
use "power_calcs_490.dta"
append using "power_calcs_245.dta"
append using "power_calcs_125.dta"

twoway 	(connected power mde if n == 490, lpattern(solid) lcolor(black) mcolor(black) msymbol(O) legend(label(1 "n = 490"))) ///
		(connected power mde if n == 245, lpattern(dash) lcolor(gs5) mcolor(gs5) msymbol(D) legend(label(2 "n = 245"))) ///
		(connected power mde if n == 125, lpattern(shortdash) lcolor(gs8) mcolor(gs8) msymbol(S) legend(label(3 "n = 125"))), ///
		xtitle("Minimum Detectable Effect Size (MDE)", size(medium)) xlabel(0.1(0.1)1.1)  ///
		ytitle("Statistical Power", size(medium)) ///
		graphregion(color(white)) plotregion(lcolor(black) lpattern(solid) istyle(white) icolor(white) ifcolor(white) margin(medium)) fxsize(100)
		
***************************************************************************	
**## 1) Main Results
***************************************************************************

cd "Analysen"
use "weekly_data_empl_exp2_win_MK.dta",clear
xtset persnr time
drop if time>76 // the experiment ended in week 24, i.e. time == 76
		

**## Table 2 Main Treatment Effects

eststo clear

*Employee Level

*Butchery Effect
eststo: reghdfe AvgS_butch treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
			
*Meat Effect
eststo: reghdfe AvgS_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both	
	
*Saus Effect
eststo: reghdfe AvgS_saus treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both

esttab, se label  title(Table 2: Main Treatment Effects) keep(treatment_Seperate treatment_Both )  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using Table2_Main_Results_FE_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (treatment_Seperate treatment_Both) ///
		title("{\b Table 2} Main Treatment Effects") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("Butchery" "Meat" "Sausage")
				 
**## Table 3 Further Treatment Effects

*Store Level
preserve

*collapse on store level
*ssc install unique 
unique(persnr) if include_analysis == 1, by(idstore) gen (N_employeesidstore)
bys idstore: egen N_employees_idstore = max(N_employeesidstore)
collapse (mean) AvgS_butch_store AvgS_saus_store AvgS_meat_store AvgS_butch_store_include AvgS_saus_store_include AvgS_meat_store_include treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC N_employees_idstore if include_analysis == 1, by(idstore treatment time)

*Fixed Effects
eststo clear
*Butchery Effect
eststo: reghdfe AvgS_butch_store_include treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  [aweight = N_employees_idstore], absorb (time idstore) cluster(idstore)
estat vce, corr
	test treatment_Seperate=treatment_Both
		reg AvgS_butch_store_include treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC [aweight = N_employees_idstore], cluster(idstore)
		estat vif
*Meat Effect
eststo: reghdfe AvgS_meat_store_include treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  [aweight = N_employees_idstore], absorb (time idstore) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Saus Effect
eststo: reghdfe AvgS_saus_store_include treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  [aweight = N_employees_idstore], absorb (time idstore) cluster(idstore)
	test treatment_Seperate=treatment_Both

esttab, se label  title(Table 3: Further Treatment Effects Store Level) keep(treatment_Seperate treatment_Both )  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using Table3_Main_Results_FE_StoreLevel_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (treatment_Seperate treatment_Both) ///
		title("{\b Table 3} Main Treatment Effects Store Level") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("Butchery" "Meat" "Sausage")
					 
restore
				
*Employee Level
eststo clear
*Butchery Effect
eststo: reghdfe decile_butch treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC 	h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Meat Effect
eststo: reghdfe decile_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Saus Effect
eststo: reghdfe decile_saus treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both


esttab, se label  title(Table 3: Main Treatment Effects Deciles) keep(treatment_Seperate treatment_Both )  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Decile Butchery" "Decile Meat" "Decile Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)

esttab using Table3_Main_Results_FE_Deciles_MK.rtf, replace  varwidth(15) modelwidth(6) ///
star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (treatment_Seperate treatment_Both) ///
	title("{\b Table 3} Main Treatment Effects Deciles") ///
	addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	 mtitles("Decile Butchery" "Decile Meat" "Decile Sausage")

			
***************************************************************************	
**## 2) Focus Better & Contribution Meat
***************************************************************************	

**## Table A 2 Treatment Effect on Effort Allocation
		
eststo clear

*ALL
eststo: reghdfe focus_better treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both

eststo: reghdfe contribution_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked  if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both


esttab, se label  title(Table A2: Treatment Effect on Effort Allocation) keep(treatment_Seperate treatment_Both)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("FocusBetter" "ContributionMeat")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using TableA2_EffectonEffortAllocation_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (treatment_Seperate treatment_Both) ///
		title("{\b Table A2} Treatment Effect on Effort Allocation") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("FocusBetter" "ContributionMeat")
	 				
***************************************************************************	
**## 3) Effect of Effort Allocation on the Effectiveness of RPI
***************************************************************************				
				
**## Table A 3 Treatment Effect of Employees' Focus Better Task
	
eststo clear				
				
*ALL
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##c.focus_better treatment_Both##c.focus_better old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##c.focus_better persnr) cluster(idstore)
	test 1.treatment_Seperate#c.focus_better=1.treatment_Both#c.focus_better
		
*Effect on Meat
eststo: reghdfe AvgS_meat  treatment_Seperate##c.focus_better treatment_Both##c.focus_better old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##c.focus_better persnr) cluster(idstore)
	test 1.treatment_Seperate#c.focus_better=1.treatment_Both#c.focus_better
	
*Effect on Sausage
eststo: reghdfe AvgS_saus  treatment_Seperate##c.focus_better treatment_Both##c.focus_better old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##c.focus_better persnr) cluster(idstore)
	test 1.treatment_Seperate#c.focus_better=1.treatment_Both#c.focus_better
	
esttab, se label  title(Table A3: Effect of Focus Better on Performance) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#c.focus_better 1.treatment_Both#c.focus_better)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using TableA3_EffectFocusBetterPerformance_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#c.focus_better 1.treatment_Both#c.focus_better) ///
		title("{\b Table A2} Effect of Focus Better on Performance") ///
		addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("Butchery" "Meat" "Sausage")	
				
				
**## Table A 4 Treatment Effect of Employees’ Contribution Meat
	
eststo clear				
				
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##c.contribution_meat treatment_Both##c.contribution_meat old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##c.contribution_meat persnr) cluster(idstore)
	test 1.treatment_Seperate#c.contribution_meat=1.treatment_Both#c.contribution_meat
	
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##c.contribution_meat treatment_Both##c.contribution_meat old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##c.contribution_meat persnr) cluster(idstore)
	test 1.treatment_Seperate#c.contribution_meat=1.treatment_Both#c.contribution_meat
	
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##c.contribution_meat treatment_Both##c.contribution_meat old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##c.contribution_meat persnr) cluster(idstore)
	test 1.treatment_Seperate#c.contribution_meat=1.treatment_Both#c.contribution_meat

esttab, se label  title(Table A4: Effect of Contribution Meat on Performance) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#c.contribution_meat 1.treatment_Both#c.contribution_meat)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using TableA4_EffectContributionMeatPerformance_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#c.contribution_meat 1.treatment_Both#c.contribution_meat) ///
		title("{\b Table A3} Effect of Contribution Meat on Performance") ///
		addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("Butchery" "Meat" "Sausage")	
	
	
**## Table A 5 Differences in the Treatment Effect Depending on Prior Effort Allocation
					
eststo clear				
				
*8 weeks prior
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##i.Focus_Meat_Prior8 treatment_Both##i.Focus_Meat_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Focus_Meat_Prior8 persnr) cluster(idstore)
	margins, dydx (treatment_Seperate treatment_Both) at(Focus_Meat_Prior8= (0 1)) noestimcheck		
				
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##i.Focus_Meat_Prior8 treatment_Both##i.Focus_Meat_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Focus_Meat_Prior8 persnr) cluster(idstore)
		margins, dydx (treatment_Seperate treatment_Both) at(Focus_Meat_Prior8= (0 1)) noestimcheck		
					
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##i.Focus_Meat_Prior8 treatment_Both##i.Focus_Meat_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Focus_Meat_Prior8 persnr) cluster(idstore)
		margins, dydx (treatment_Seperate treatment_Both) at(Focus_Meat_Prior8= (0 1)) noestimcheck		
					
esttab, se label  title(Table A5: Interaction Effect Treatment with Focus Meat Prior) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.Focus_Meat_Prior8 1.treatment_Both#1.Focus_Meat_Prior8)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
			
esttab using TableA5_InteractionEffectFocusMeatPrior_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.Focus_Meat_Prior8 1.treatment_Both#1.Focus_Meat_Prior8) ///
	title("{\b Table A5} Differences in the Treatment Effect Depending on Prior Effort Allocation") ///
	addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	 mtitles("Butchery" "Meat" "Sausage")		
			
***************************************************************************	
**## 4) Effect of Different Starting Points
***************************************************************************	
	
**## Figure A 3 Quantile Regression

preserve

use "weekly_data_empl_exp2_win_MK.dta",clear

*no xtset because this doesn't work with bootstrap, cl()
drop if time>76 // the experiment ended in week 24, i.e. time == 76

*butch
eststo clear
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_butch  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=. , i(persnr) quantile(.25)
estimates store Q25
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_butch  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=., i(persnr) quantile(.5)
estimates store Q50
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_butch  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=., i(persnr) quantile(.75)
estimates store Q75
	
*Coeflplot 
coefplot	(Q25, msymbol(O) mcolor(black) label(25th Quantile)) ///
			(Q50, msymbol(D) mcolor(black) label(50th Quantile)) ///
			(Q75, msymbol(T) mcolor(black) label(75th Quantile)), ///
	drop(_cons t) keep( treatment_Seperate treatment_Both ) ///
	coeflabel(treatment_Seperate= "Separate RPI" treatment_Both  = "Separate & Overall RPI") ///
	legend(cols(4) rows(1)) ///
	vertical level(90) ciopts(recast(rcap) lcolor(black)) citop ///
	ytitle("Treatment Effect on Average Sales Overall", size(small))  ///
	xlabel(, glcolor(gs12) labsize(small)) ///
	ylabel(, glcolor(gs12) labsize(small)) ///
	yline (0, lcolor(red)) ///
	graphregion(color(white)) plotregion(lcolor(black) lpattern(solid) istyle(white) icolor(white) ifcolor(white) margin(medium)) fxsize(100) 
	graph export "QuanReg_bon_win_Exp2_Q4_butch.png", as(png) name("Graph") replace
		
*saus
eststo clear
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_saus  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=. , i(persnr) quantile(.25)
estimates store Q25
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_saus  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=., i(persnr) quantile(.50)
estimates store Q50
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_saus  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=., i(persnr) quantile(.75)
estimates store Q75

*Coeflplot 
coefplot	(Q25, msymbol(O) mcolor(black) label(25th Quantile)) ///
			(Q50, msymbol(D) mcolor(black) label(50th Quantile)) ///
			(Q75, msymbol(T) mcolor(black) label(75th Quantile)), ///
	drop(_cons t) keep( treatment_Seperate treatment_Both ) ///
	coeflabel(treatment_Seperate= "Separate RPI" treatment_Both  = "Separate & Overall RPI") ///
	legend(cols(4) rows(1)) ///
	vertical level(90) ciopts(recast(rcap) lcolor(black)) citop ///
	ytitle("Treatment Effect on Average Sales Sausage", size(small))  ///
	xlabel(, glcolor(gs12) labsize(small)) ///
	ylabel(, glcolor(gs12) labsize(small)) ///
	yline (0, lcolor(red)) /// 
	graphregion(color(white)) plotregion(lcolor(black) lpattern(solid) istyle(white) icolor(white) ifcolor(white) margin(medium)) fxsize(100) 
	graph export "QuanReg_bon_win_Exp2_Q4_saus.png", as(png) name("Graph") replace
	
*meat
eststo clear
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_meat  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=. , i(persnr) quantile(.25)
estimates store Q25
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_meat  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=., i(persnr) quantile(.50)
estimates store Q50
bootstrap, cl(idstore) r(50)  seed(123): xtqreg AvgS_meat  treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC i.time h_worked if include_analysis == 1 & absent != 1 & absent !=., i(persnr) quantile(.75)
estimates store Q75

*Coeflplot 
coefplot	(Q25, msymbol(O) mcolor(black) label(25th Quantile)) ///
			(Q50, msymbol(D) mcolor(black) label(50th Quantile)) ///
			(Q75, msymbol(T) mcolor(black) label(75th Quantile)), ///
	drop(_cons t) keep( treatment_Seperate treatment_Both ) ///
	coeflabel(treatment_Seperate= "Separate RPI" treatment_Both  = "Separate & Overall RPI") ///
	legend(cols(4) rows(1)) ///
	vertical level(90) ciopts(recast(rcap) lcolor(black)) citop ///
	ytitle("Treatment Effect on Average Sales Meat", size(small))  ///
	xlabel(, glcolor(gs12) labsize(small)) ///
	ylabel(, glcolor(gs12) labsize(small)) ///
	yline (0, lcolor(red)) ///
	graphregion(color(white)) plotregion(lcolor(black) lpattern(solid) istyle(white) icolor(white) ifcolor(white) margin(medium)) fxsize(100) 
	graph export "QuanReg_bon_win_Exp2_Q4_meat.png", as(png) name("Graph") replace

restore
	
use "weekly_data_empl_exp2_win_MK.dta",clear
xtset persnr time
drop if time>76 // the experiment ended in week 24, i.e. time == 76

**## Table 4 Differences in the Treatment Effect Depending on Prior Performance
		
eststo clear				

*8 weeks prior
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##i.High_Performer_Prior8 treatment_Both##i.High_Performer_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.High_Performer_Prior8 persnr) cluster(idstore)
	margins, dydx (treatment_Seperate treatment_Both) at(High_Performer_Prior8= (0 1)) noestimcheck		
	marginsplot, ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall)) ///
		ytitle("AvgS Butchery", size(small)) xtitle("High Performer", size(small))  ///
		title("Differences in the Treatment Effect Depending on Prior Performance", box bexpand size(large)  fcolor(gs14)  margin(medium)) ///
		graphregion(color(white))
						
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##i.High_Performer_Prior8 treatment_Both##i.High_Performer_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.High_Performer_Prior8 persnr) cluster(idstore)
	margins, dydx (treatment_Seperate treatment_Both) at(High_Performer_Prior8= (0 1)) noestimcheck		
	marginsplot, ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall)) ///
		ytitle("AvgS Meat", size(small)) xtitle("High Performer", size(small))  ///
		title("Differences in the Treatment Effect Depending on Prior Performance", box bexpand size(large)  fcolor(gs14)  margin(medium)) ///
		graphregion(color(white))
							
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##i.High_Performer_Prior8 treatment_Both##i.High_Performer_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.High_Performer_Prior8 persnr) cluster(idstore)
	margins, dydx (treatment_Seperate treatment_Both) at(High_Performer_Prior8= (0 1)) noestimcheck		
	marginsplot, ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall)) ///
		ytitle("AvgS Sausage", size(small)) xtitle("High Performer", size(small))  ///
		title("Differences in the Treatment Effect Depending on Prior Performance", box bexpand size(large)  fcolor(gs14)  margin(medium)) ///
		graphregion(color(white))				
		
		
esttab, se label  title(Table 4: Differences in the Treatment Effect Depending on Prior Performance) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.High_Performer_Prior8 1.treatment_Both#1.High_Performer_Prior8)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
			
esttab using Table4_InteractionEffectLowHighPerformerButch8_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.High_Performer_Prior8 1.treatment_Both#1.High_Performer_Prior8) ///
	title("{\b Table 4} Differences in the Treatment Effect Depending on Prior Performance") ///
	addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage")
	
		
**## Table A 6 Differences in the Treatment Effect Depending on Prior Performance
		
eststo clear				

*4 weeks prior
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##i.High_Performer_Prior4 treatment_Both##i.High_Performer_Prior4 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.High_Performer_Prior4 persnr) cluster(idstore)
						
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##i.High_Performer_Prior4 treatment_Both##i.High_Performer_Prior4 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.High_Performer_Prior4 persnr) cluster(idstore)
							
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##i.High_Performer_Prior4 treatment_Both##i.High_Performer_Prior4 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.High_Performer_Prior4 persnr) cluster(idstore)

esttab, se label  title(Table A6: Differences in the Treatment Effect Depending on Prior Performance) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.High_Performer_Prior4 1.treatment_Both#1.High_Performer_Prior4)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
			
esttab using TableA6_InteractionEffectLowHighPerformerButch4_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.High_Performer_Prior4 1.treatment_Both#1.High_Performer_Prior4) ///
	title("{\b Table A6} Differences in the Treatment Effect Depending on Prior Performance") ///
	addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage")
	
	
**## Table A 7 Differences in the Treatment Effect Depending on Prior Performance (Top Tercile)
		
eststo clear				

*8 weeks prior
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##i.Top_Performer_Prior8 treatment_Both##i.Top_Performer_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Top_Performer_Prior8 persnr) cluster(idstore)
							
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##i.Top_Performer_Prior8 treatment_Both##i.Top_Performer_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Top_Performer_Prior8 persnr) cluster(idstore)
							
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##i.Top_Performer_Prior8 treatment_Both##i.Top_Performer_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Top_Performer_Prior8 persnr) cluster(idstore)

esttab, se label  title(Table A7: Differences in the Treatment Effect Depending on Prior Performance (Top Tercile)) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.Top_Performer_Prior8 1.treatment_Both#1.Top_Performer_Prior8)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
			
esttab using TableA7_InteractionEffectTopTercile8_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.Top_Performer_Prior8 1.treatment_Both#1.Top_Performer_Prior8) ///
	title("{\b Table A6} Differences in the Treatment Effect Depending on Prior Performance (Top Tercile)") ///
	addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage")
		
**## Table A 8 Differences in the Treatment Effect Depending on Prior Performance (Top Quartile)
		
eststo clear				

*8 weeks prior
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##i.Top_Quartile_Prior8 treatment_Both##i.Top_Quartile_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Top_Quartile_Prior8 persnr) cluster(idstore)
							
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##i.Top_Quartile_Prior8 treatment_Both##i.Top_Quartile_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Top_Quartile_Prior8 persnr) cluster(idstore)
							
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##i.Top_Quartile_Prior8 treatment_Both##i.Top_Quartile_Prior8 old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time##i.Top_Quartile_Prior8 persnr) cluster(idstore)

esttab, se label  title(Table A8: Differences in the Treatment Effect Depending on Prior Performance (Top Quartile)) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.Top_Quartile_Prior8 1.treatment_Both#1.Top_Quartile_Prior8)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
			
esttab using TableA8_InteractionEffectTopQuartileButch8_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#1.Top_Quartile_Prior8 1.treatment_Both#1.Top_Quartile_Prior8) ///
	title("{\b Table A8} Differences in the Treatment Effect Depending on Prior Performance (Top Quartile)") ///
	addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage")
	
		
***************************************************************************	
**## 5) Take-Up of the Treatment
***************************************************************************	
		
**## Table A 9 Compliers vs. Non-Comliers
**## Employee descriptives - time constant. Only 1 dataset per employee
preserve

keep if include_analysis == 1
collapse (max) gen age ten active_once_during active_twice_during, by(persnr)

*gen age ten
replace gen = 0 if gen == 2 // gen = 1 is female gen = 0 is male

asdoc sum gen age ten, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 1.doc) dec(3) replace
asdoc sum gen age ten if active_once_during == 0, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 2.doc) dec(3) replace
asdoc sum gen age ten if active_once_during == 1, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 3.doc) dec(3) replace	
asdoc sum gen age ten if active_twice_during == 1, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 4.doc) dec(3) replace

ttest age if active_once_during == 0 | active_once_during == 1, by(active_once_during)
ttest age if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest gen if active_once_during == 0 | active_once_during == 1, by(active_once_during) 
ttest gen if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest ten if active_once_during == 0 | active_once_during == 1, by(active_once_during) 
ttest ten if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

summarize active_once_during

restore	
			
**## Employee descriptives - time variant. Prior Experiment Only 1 dataset per employee
preserve

keep if include_analysis == 1
collapse (max) High_Performer_Prior8 (mean) AvgS_butch AvgS_saus AvgS_meat focus_better contribution_meat (max) active_once_during active_twice_during if time >= 56 & time <64, by(persnr)

asdoc sum High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 5.doc) dec(3) replace
asdoc sum High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_once_during == 0, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 6.doc) dec(3) replace
asdoc sum High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_once_during == 1, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 7.doc) dec(3) replace	
asdoc sum High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_twice_during == 1, stat(N mean sd p25 p75) label save(descriptive_complier vs non complier 8.doc) dec(3) replace

ttest High_Performer_Prior8 if active_once_during == 0 | active_once_during == 1, by(active_once_during)
ttest High_Performer_Prior8 if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest AvgS_butch if active_once_during == 0 | active_once_during == 1, by(active_once_during)
ttest AvgS_butch if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest AvgS_meat if active_once_during == 0 | active_once_during == 1, by(active_once_during) 
ttest AvgS_meat if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest AvgS_saus if active_once_during == 0 | active_once_during == 1, by(active_once_during) 
ttest AvgS_saus if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest contribution_meat if active_once_during == 0 | active_once_during == 1, by(active_once_during) 
ttest contribution_meat if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

ttest focus_better if active_once_during == 0 | active_once_during == 1, by(active_once_during) 
ttest focus_better if active_once_during == 0 | active_twice_during == 1, by(active_once_during)

restore


**## Table A 10: Non-Compliers vs. Compliers Across Treatments 
preserve

keep if include_analysis == 1
collapse (mean) AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better (max) High_Performer_Prior8 gen age ten active_once_during active_twice_during treatment if time >= 56 & time <64, by(persnr)

*gen age ten
replace gen = 0 if gen == 2
*gen = 1 is female gen = 0 is male
	
asdoc sum gen age ten High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_once_during == 0, stat(N mean sd p25 p75) label save(descriptive_non complier All.doc) dec(3) replace
asdoc sum gen age ten High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_once_during == 1 & treatment == 0, stat(N mean sd p25 p75) label save(descriptive_complier control 1.doc) dec(3) replace	
asdoc sum gen age ten High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_once_during == 1 & treatment == 1, stat(N mean sd p25 p75) label save(descriptive_complier separate 2.doc) dec(3) replace	
asdoc sum gen age ten High_Performer_Prior8 AvgS_butch AvgS_meat AvgS_saus contribution_meat focus_better if active_once_during == 1 & treatment == 2, stat(N mean sd p25 p75) label save(descriptive_complier both 3.doc) dec(3) replace	

gen complier_control = 0
gen complier_seperate = 0
gen complier_both = 0

replace complier_control = 1 if active_once_during == 1 & treatment == 0
replace complier_seperate = 1 if active_once_during == 1 & treatment == 1
replace complier_both = 1 if active_once_during == 1 & treatment == 2

ttest gen if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest age if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest ten if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest High_Performer_Prior8 if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest AvgS_butch if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest AvgS_meat if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest AvgS_saus if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest contribution_meat if complier_seperate != 1 & complier_both != 1, by(active_once_during)
ttest focus_better if complier_seperate != 1 & complier_both != 1, by(active_once_during)

ttest gen if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest age if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest ten if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest High_Performer_Prior8 if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest AvgS_butch if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest AvgS_meat if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest AvgS_saus if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest contribution_meat if complier_control != 1 & complier_both != 1, by(active_once_during)
ttest focus_better if complier_control != 1 & complier_both != 1, by(active_once_during)

ttest gen if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest age if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest ten if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest High_Performer_Prior8 if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest AvgS_butch if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest AvgS_meat if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest AvgS_saus if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest contribution_meat if complier_control != 1 & complier_seperate != 1, by(active_once_during)
ttest focus_better if complier_control != 1 & complier_seperate != 1, by(active_once_during)


restore	
	
**## Table A 11: Drivers of App Usage
preserve

collapse (max) treatment_Seperate treatment_Both include_analysis High_Performer_Prior8 contribution_meat_prior8 (mean) h_worked (firstnm) N_active active_once_during active_twice_during gen age ten clength stsize if time >= 64, by(persnr idstore)


eststo clear

eststo: reg active_once_during High_Performer_Prior8 contribution_meat_prior8 h_worked gen age ten clength stsize if include_analysis == 1, cluster(idstore)
eststo: reg active_twice_during High_Performer_Prior8 contribution_meat_prior8 h_worked gen age ten clength stsize if include_analysis == 1, cluster(idstore)
eststo: reg N_active High_Performer_Prior8 contribution_meat_prior8 h_worked gen age ten clength stsize if include_analysis == 1, cluster(idstore)
	
esttab, se label  title(Table A11: Drivers of App Usage) keep(High_Performer_Prior8 contribution_meat_prior8 h_worked gen age ten clength stsize)  ///
			s(con N cluster r2, label("Controls")) ///
			nonumbers mtitles("Active Once" "Active Twice" "Active N") b(%9.3f) ///
			star(* 0.10 ** 0.05 *** 0.01) varwidth (50)
			
esttab using TableA11_DriversUsageOLS_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (High_Performer_Prior8 contribution_meat_prior8 h_worked gen age ten clength stsize) ///
		title("{\b Table A11} Drivers of App Usage") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("Active Once" "Active Twice" "Active N")
		 
restore
	
**## Talbe 5 Local Average Treatment Effects (LATE)	
eststo clear
*Butchery
eststo: ivreghdfe AvgS_butch (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1, absorb (time persnr) cluster(idstore) first
	test active_Seperate_1=active_Both_1
*Meat
eststo: ivreghdfe AvgS_meat  (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1, absorb (time persnr) cluster(idstore) first	
	test active_Seperate_1=active_Both_1
*Sausage
eststo: ivreghdfe  AvgS_saus  (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1, absorb (time persnr) cluster(idstore) first		
	test active_Seperate_1=active_Both_1

esttab, se label  title(Table 5: Local Average Treatment Effects (LATE)) keep(active_Seperate_1 active_Both_1)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
		
esttab using Table5_LocalAverageTreatmentEffect_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (active_Seperate_1 active_Both_1) ///
	title("{\b Table 5} Local Average Treatment Effects (LATE)") ///
	addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage")
			
			
**## Talbe 6: Local Average Treatment Effects (LATE) for Low-/High Performers
eststo clear
*Low Performer
*Butchery
eststo: ivreghdfe AvgS_butch (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1 & High_Performer_Prior8 == 0, absorb (time persnr) cluster(idstore) first
	test active_Seperate_1=active_Both_1
*Meat
eststo: ivreghdfe AvgS_meat  (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1 & High_Performer_Prior8 == 0, absorb (time persnr) cluster(idstore) first	
	test active_Seperate_1=active_Both_1
*Sausage
eststo: ivreghdfe  AvgS_saus  (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1 & High_Performer_Prior8 == 0, absorb (time persnr) cluster(idstore) first		
	test active_Seperate_1=active_Both_1
	
*High Performer
*Butchery
eststo: ivreghdfe AvgS_butch (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1 & High_Performer_Prior8 == 1, absorb (time persnr) cluster(idstore) first
	test active_Seperate_1=active_Both_1
*Meat
eststo: ivreghdfe AvgS_meat  (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1 & High_Performer_Prior8 == 1, absorb (time persnr) cluster(idstore) first	
	test active_Seperate_1=active_Both_1
*Sausage
eststo: ivreghdfe  AvgS_saus  (active_Seperate_1 active_Both_1 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1 & High_Performer_Prior8 == 1, absorb (time persnr) cluster(idstore) first		
	test active_Seperate_1=active_Both_1
	
esttab, se label  title(Table 6: Local Average Treatment Effects (LATE) for Low-/High Performers) keep(active_Seperate_1 active_Both_1)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
		
esttab using Table6_LocalAverageTreatmentEffect_LowHighPerf_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (active_Seperate_1 active_Both_1) ///
	title("{\b Table 6} Local Average Treatment Effects (LATE) for Low-/High Performers") ///
	addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage")
			
**## Talbe A 12 Local Average Treatment Effects (LATE) Employees Who Accessed the App at Least Twice
eststo clear
*Butchery
eststo: ivreghdfe AvgS_butch (active_Seperate_2 active_Both_2 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1, absorb (time persnr) cluster(idstore) first
	test active_Seperate_2=active_Both_2
*Meat
eststo: ivreghdfe AvgS_meat  (active_Seperate_2 active_Both_2 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1, absorb (time persnr) cluster(idstore) first	
	test active_Seperate_2=active_Both_2
*Sausage
eststo: ivreghdfe  AvgS_saus  (active_Seperate_2 active_Both_2 = treatment_Seperate treatment_Both) old_treatment_MED old_treatment_DEC h_worked if  include_analysis == 1 & absent !=. & absent != 1, absorb (time persnr) cluster(idstore) first		
	test active_Seperate_2=active_Both_2

esttab, se label  title(Table A12: Local Average Treatment Effects (LATE) Employees Who Accessed the App at Least Twice) keep(active_Seperate_2 active_Both_2)  ///
	s(con N cluster r2, label("Controls")) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
		
esttab using TableA12_LocalAverageTreatmentEffec_Twice_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (active_Seperate_2 active_Both_2) ///
	title("{\b Table A12} Local Average Treatment Effects (LATE) Employees Who Accessed the App at Least Twice") ///
	addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage")
		
	
**## Table A 13 Main Treatment Effects for Low-/High Performers
eststo clear
*Butchery Effect
eststo: reghdfe AvgS_butch treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 0, absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
				
*Meat Effect
eststo: reghdfe AvgS_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 0, absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both	
		
*Saus Effect
eststo: reghdfe AvgS_saus treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 0, absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
		
*Butchery Effect
eststo: reghdfe AvgS_butch treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 1, absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
				
*Meat Effect
eststo: reghdfe AvgS_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 1, absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both	
		
*Saus Effect
eststo: reghdfe AvgS_saus treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 1, absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both

esttab, se label  title(Table A13: Main Treatment Effects for Low-/High Performers) keep(treatment_Seperate treatment_Both )  ///
	s(con N cluster r2, label("Controls")) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
		
esttab using TableA13_Main_Results_FE_LowHigh_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (treatment_Seperate treatment_Both) ///
		title("{\b Table A13} Main Treatment Effects for Low-/High Performers") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		mtitles("Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage")
				

***************************************************************************	
**## Additional Analysis
***************************************************************************							
				

**## Table A 14 Pre-Treatment Placebo Test
preserve

***PRE TREND
drop if time >= 64
gen pre=0
replace pre=1 if time==63 | time==62
gen treatment_Seperate_pre= pre*treatment
gen treatment_Both_pre=pre*treatment
replace treatment_Both_pre=1 if treatment_Both_pre==2
	
*Employee Level
eststo clear

*Butchery Effect
eststo: reghdfe AvgS_butch treatment_Seperate_pre treatment_Both_pre old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate_pre=treatment_Both_pre
			
*Meat Effect
eststo: reghdfe AvgS_meat treatment_Seperate_pre treatment_Both_pre old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate_pre=treatment_Both_pre	
	
*Saus Effect
eststo: reghdfe AvgS_saus treatment_Seperate_pre treatment_Both_pre old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate_pre=treatment_Both_pre

esttab, se label  title(Table A14: Pre-Treatment Placebo Test) keep(treatment_Seperate_pre treatment_Both_pre )  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using TableA14_CommonTrend_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (treatment_Seperate_pre treatment_Both_pre) ///
		title("{\b Table A14} Pre-Treatment Placebo Test") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		 mtitles("Butchery" "Meat" "Sausage")
	 
restore 	
	
	
**## Table A 15 Comparing Pre-Treatment Growth Rates

preserve

keep if include_analysis == 1 & absent != 1 & absent !=.

bys persnr: egen AvgS_butch1 = mean(AvgS_butch) if time >= 60 & time <= 63
bys persnr: egen AvgS_meat1 = mean(AvgS_meat) if time >= 60 & time <= 63
bys persnr: egen AvgS_saus1 = mean(AvgS_saus) if time >= 60 & time <= 63

bys persnr: egen AvgS_butch0 = mean(AvgS_butch) if time < 60
bys persnr: egen AvgS_meat0 = mean(AvgS_meat) if time < 60
bys persnr: egen AvgS_saus0 = mean(AvgS_saus) if time < 60


bys persnr: egen AvgS_butch_1 = max(AvgS_butch1)
bys persnr: egen AvgS_meat_1 = max(AvgS_meat1)
bys persnr: egen AvgS_saus_1 = max(AvgS_saus1)

bys persnr: egen AvgS_butch_0 = max(AvgS_butch0)
bys persnr: egen AvgS_meat_0 = max(AvgS_meat0)
bys persnr: egen AvgS_saus_0 = max(AvgS_saus0)

gen AvgS_butch_gr = AvgS_butch_1 / AvgS_butch_0 - 1
gen AvgS_meat_gr = AvgS_meat_1 / AvgS_meat_0 - 1
gen AvgS_saus_gr = AvgS_saus_1 / AvgS_saus_0 - 1


collapse (max) AvgS_butch_gr AvgS_meat_gr AvgS_saus_gr treatment_Seperate treatment_Both, by(persnr idstore)

eststo clear
eststo: reg AvgS_butch_gr treatment_Seperate treatment_Both, cluster(idstore)
eststo: reg AvgS_meat_gr treatment_Seperate treatment_Both, cluster(idstore)
eststo: reg AvgS_saus_gr treatment_Seperate treatment_Both, cluster(idstore)

esttab, se label  title(Table A15: Comparing Pre-Treatment Growth Rates) keep(treatment_Seperate treatment_Both)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)

esttab using TableA15_CommonTrendGrowth_MK.rtf, replace  varwidth(15) modelwidth(6) ///
		star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
		keep (treatment_Seperate treatment_Both) ///
		title("{\b Table A 15} Comparing Pre-Treatment Growth Rates") ///
		addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
		mtitles("Butchery" "Meat" "Sausage")

restore
		

**## Table A 17 Differences in the Treatment Effect Depending on Prior Performance and Tenure

preserve 
			
eststo clear				

*Low Performers
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##c.ten treatment_Both##c.ten old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 0, absorb (time##c.ten persnr) cluster(idstore)
	test 1.treatment_Seperate#c.ten = 1.treatment_Both#c.ten
						
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##c.ten treatment_Both##c.ten old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 0, absorb (time##c.ten persnr) cluster(idstore)
	test 1.treatment_Seperate#c.ten = 1.treatment_Both#c.ten
							
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##c.ten treatment_Both##c.ten old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 0, absorb (time##c.ten persnr) cluster(idstore)
	test 1.treatment_Seperate#c.ten = 1.treatment_Both#c.ten

*High Performers
*Effect on Butchery
eststo: reghdfe AvgS_butch treatment_Seperate##c.ten treatment_Both##c.ten old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 1, absorb (time##c.ten persnr) cluster(idstore)
	test 1.treatment_Seperate#c.ten = 1.treatment_Both#c.ten
						
*Effect on Meat
eststo: reghdfe AvgS_meat treatment_Seperate##c.ten treatment_Both##c.ten old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 1, absorb (time##c.ten persnr) cluster(idstore)
	test 1.treatment_Seperate#c.ten = 1.treatment_Both#c.ten
							
*Effect on Sausage
eststo: reghdfe AvgS_saus treatment_Seperate##c.ten treatment_Both##c.ten old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=. & High_Performer_Prior8 == 1, absorb (time##c.ten persnr) cluster(idstore)
	test 1.treatment_Seperate#c.ten = 1.treatment_Both#c.ten

esttab, se label  title(Table A17: Differences in the Treatment Effect Depending on Prior Performance and Tenure) keep(1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#c.ten 1.treatment_Both#c.ten)  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
			
esttab using TableA17_InteractionEffectLowHighPerformerTenure_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (1.treatment_Seperate 1.treatment_Both 1.treatment_Seperate#c.ten 1.treatment_Both#c.ten) ///
	title("{\b Table A17} Differences in the Treatment Effect Depending on Prior Performance and Tenure") ///
	addnotes("Fixed Effects Regression. Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Butchery" "Meat" "Sausage" "Butchery" "Meat" "Sausage")
	
		
restore
	
**## Table A18 Treatment Effect on Sales and the Number of Transactions
eststo clear
*Sales
*Butchery Effect
eststo: reghdfe Sales_butch treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Meat Effect
eststo: reghdfe Sales_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Saus Effect
eststo: reghdfe Sales_saus treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*#Transactions
*Butchery Effect
eststo: reghdfe N_butch treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Meat Effect
eststo: reghdfe N_meat treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both
*Saus Effect
eststo: reghdfe N_saus treatment_Seperate treatment_Both old_treatment_MED old_treatment_DEC  h_worked if include_analysis == 1 & absent != 1 & absent !=., absorb (time persnr) cluster(idstore)
	test treatment_Seperate=treatment_Both		


esttab, se label  title(Table A18: Treatment Effect on Sales and the Number of Transactions) keep(treatment_Seperate treatment_Both )  ///
	s(con N cluster r2, label("Controls")) b(%9.3f) ///
	nonumbers mtitles("Sales Butchery" "Sales Meat" "Sales Sausage" "#Transactions Butchery" "#Transactions Meat" "#Transactions Sausage")  ///
	star(* 0.10 ** 0.05 *** 0.01)
	
esttab using TableA18_SalesTransactions_MK.rtf, replace  varwidth(15) modelwidth(6) ///
	star(* 0.10 ** 0.05 *** 0.01) se compress nodepvars r2 noconstant label nonotes onecell b(%9.3f) ///
	keep (treatment_Seperate treatment_Both) ///
	title("{\b Table A18} Treatment Effect on Sales and the Number of Transactions"") ///
	addnotes("Robust standard errors clustered on district in parentheses" "* p<0.10, ** p<0.05, *** p<0.01") ///
	mtitles("Sales Butchery" "Sales Meat" "Sales Sausage" "#Transaction Butchery" "#Transaction Meat" "#Transaction Sausage")	
clear all
use "QuestShort.dta"

*drop time

label variable	Q1	"	Die Informationen, die ich zum Durchschnittsbon erhalten habe, waren interessant.	"
label variable	Q2	"	Ich würde den Durchschnittsbonbericht auch in Zukunft gerne erhalten.	"
label variable	Q3	"	Ich denke, dass der Durchschnittsbon ein wichtiger Faktor bei der Bewertung der Verkaufsleistung ist.	"
label variable	Q4	"	Die Informationen, die ich zum Durchschnittsbon erhalten habe, haben mir geholfen meine Verkaufsleistung zu bewerten.	"
label variable	Q5	"	Ich fühle mich bei der Arbeit motiviert.	"
label variable	Q6	"	Ich habe ein gutes Gefühl bei der Arbeit.	"
label variable	Q7	"	Ich gebe mein Bestes, um in meinem Job gut zu sein.	"
label variable	Q8	"	Meine Arbeitskollegen helfen und unterstützen sich gegenseitig so gut sie können.	"
label variable	Q9	"	Meine Arbeitskollegen stehen ständig in Konkurrenz zueinander.	"
label variable	Q10	"	Ich habe den Eindruck, dass ich ständig überwacht werde.	"
label variable	Q11	"	Ich fühle mich bei der Arbeit gestresst.	"
label variable	Q12	"	Ich bin mir nicht sicher, wie der Verkauf von Fleisch und der Verkauf von Wurst meinen Durchschnittsbon in der Metzgerei beeinflusst.	"
label variable	Q14	"	Ich habe meine(n) VORGESETZTEN über meinen Durchschnittsbon informiert:"
label variable	Q15	"	Ich habe meine(n) ARBEITSKOLLEGEN über meinen Durchschnittsbon informiert:"

****

label variable	Q16	"	Falls Sie in der Metzgerei arbeiten, was ist für Sie bei der Bewertung Ihrer Verkaufsleistung wichtig? (Mehrfachnennung möglich)	"
label variable	Q17	"	Falls Sie in der Metzgerei arbeiten, verkaufen Sie dann lieber Fleisch oder Wurst?	"
label variable	Q18 "	Falls Sie in der Metzgerei arbeiten, haben Sie spezielle Kenntnisse über die Produkte die Sie verkaufen?	"
label variable	Q19	"	Was hat Ihnen geholfen, Ihren Durchschnittsbon zu steigern? (Mehrfachnennung möglich) - Selected Choice	"


drop if treatment == .
keep if Finished == 1

*rename RecipientFirstName ID
capture drop treatment_Seperate treatment_Both
gen treatment_Seperate=0
gen treatment_Both=0
replace  treatment_Seperate=1 if treatment==1
replace  treatment_Both=1 if treatment==2


**** Recode
foreach var of varlist Q1-Q12{
	replace `var'=8-`var'
}

***Winner of lottery
preserve
drop if StartDate==""
set seed 123
sample 3, count
br
restore

**## Figure 2 - Results Survey

preserve
drop Q13_12 Q13_13 Q13_14 Q14 Q16 Q17 Q18 Q19 Q19_21_TEXT Q20 Q20_5_TEXT Q21 Q22 Q23 Q24
reshape long Q, i(ID) j(Question)

collapse (mean) Q (sd) sd_Q=Q  (count) n=Q , by(Question treatment)
	generate cu_1 = Q + invttail(n-1,0.1)*(sd_Q/ sqrt(n))
	generate cl_1 = Q - invttail(n-1,0.1)*(sd_Q / sqrt(n))

egen rank= rank(Q), unique
	
gen place=treatment if Question==1
replace place=treatment+4 if Question==2
replace place=treatment+8 if Question==3
replace place=treatment+12 if Question==4
replace place=treatment+16 if Question==5
replace place=treatment+20 if Question==6
replace place=treatment+24 if Question==7
replace place=treatment+28 if Question==8
replace place=treatment+32 if Question==9
replace place=treatment+36 if Question==10
replace place=treatment+40 if Question==11
replace place=treatment+44 if Question==12
replace place=treatment+48 if Question==13
replace place=treatment+52 if Question==14

twoway (bar Q  place if treatment==0 ,bcolor(gs2) ) ///
     (bar Q  place if treatment==1 ,bcolor(gs9) ) ///
	    (bar Q  place if treatment==2 ,bcolor(gs7) ) ///
   (rcap cu_1 cl_1 place, fcolor(gs4) lcolor(gs4)), ///
   ytitle("Agreement" "(1=not agree; 7=strongly agree)", size(small)) yscale(range(2(2)6)) ylabel(2[2]6)  ///
   ttitle(" ") ///
  legend(row(1) order(1 "Overall" 2 "Seperate" 3 "Separate&Overall") symxsize(*0.5) size(small)) ///
	 xlabel( 1.5 "(1) Interesting"  4.5 "(2) Future" 8.5 "(3) Important" 12.5 "(4) Helpful" 16.5 "(5) Motivated" ///
	   20.5 "(6) Feel Good" 24.5 "(7) Effort"  28.5 "(8) Collaboration"  32.5 "(9) Competition"  36.5 "(10) Monitoring" 40.5 "(11) Stress" 44.5 "(12) Uncertainty", noticks angle(30) labsize(small) labgap(1.5)) ///
   graphregion(color(white)) plotregion(lcolor(black)) ylabel(,grid glcolor(gs12) labsize(small)) fxsize(100)   
   
graph export "Quest 2_MK.png", as(png) name("Graph") replace

restore  
 
**## Qualitative Questions / MK
*Q14

capture drop Q14_1 Q14_2 Q14_3 Q14_4

gen Q14_1 = 1 if Q14 == 1
gen Q14_2 = 1 if Q14 == 2
gen Q14_4 = 1 if Q14 == 4
gen Q14_6 = 1 if Q14 == 6

label variable Q14_1 "Only when performed well"
label variable Q14_2 "Ony when performed poorly"
label variable Q14_4 "Yes, independent of performance "
label variable Q14_6 "No, independent of performance"

asdoc mrtab Q14_1-Q14_6, by(treatment) rcolumn  chi2 include  title(Informed Supervisor) width (24) save(Survey2_Q14.doc) fs(10) font(Times New Roman), replace


*Q15

capture drop Q15_1 Q15_2 Q15_3 Q15_4

gen Q15_1 = 1 if Q15 == 1
gen Q15_2 = 1 if Q15 == 2
gen Q15_4 = 1 if Q15 == 4
gen Q15_6 = 1 if Q15 == 6

label variable Q15_1 "Only when performed well"
label variable Q15_2 "Ony when performed poorly"
label variable Q15_4 "Yes, independent of performance "
label variable Q15_6 "No, independent of performance"

asdoc mrtab Q15_1-Q15_6, by(treatment) rcolumn  chi2 include  title(Informed Colleagues) width (24) save(Survey2_Q15.doc) fs(10) font(Times New Roman), replace
		 
*Q16

capture drop Q16_Overall Q16_Separate Q16_Both Q16_Nothing

gen Q16_Overall = 1 if strmatch(Q16, "1")
gen Q16_Separate = 1 if strmatch(Q16, "2") | strmatch(Q16, "3") | strmatch(Q16, "2,3")
gen Q16_Both = 1 if strmatch(Q16, "1,2,3")
gen Q16_Nothing = 1 if strmatch(Q16, "4") | strmatch(Q16, "*,4,*")

replace Q16_Overall = . if Q16_Nothing == 1
replace Q16_Separate = . if Q16_Nothing == 1
replace Q16_Both = . if Q16_Nothing == 1

label variable Q16_Overall "Important Overall"
label variable Q16_Separate "Important Separate"
label variable Q16_Both "Important Both"
label variable Q16_Nothing "Important Nothing"

asdoc mrtab Q16_Overall Q16_Separate Q16_Both Q16_Nothing, by(treatment) rcolumn  chi2 include  title(Important) width (24) save(Survey2_Q16.doc) fs(10) font(Times New Roman), replace

*Q17

capture drop Q17_1 Q17_2 Q17_3

gen Q17_1 = 1 if Q17 == 1
gen Q17_2 = 1 if Q17 == 2
gen Q17_3 = 1 if Q17 == 3


label variable Q17_1 "Preference selling meat"
label variable Q17_2 "Preference selling sausage"
label variable Q17_3 "No preference"

asdoc mrtab Q17_1-Q17_3, by(treatment) rcolumn  chi2 include  title(Preference Selling) width (24) save(Survey2_Q17.doc) fs(10) font(Times New Roman), replace

*Q18

capture drop Q18_1 Q18_2 Q18_3 Q18_4

gen Q18_1 = 1 if Q18 == 1
gen Q18_2 = 1 if Q18 == 2
gen Q18_3 = 1 if Q18 == 3
gen Q18_4 = 1 if Q18 == 4


label variable Q18_1 "Knowledge Meat"
label variable Q18_2 "Knowledge Sausage"
label variable Q18_3 "Knowledge Both"
label variable Q18_4 "No Knowledge"

asdoc mrtab Q18_1-Q18_4, by(treatment) rcolumn  chi2 include  title(Task Knowledge) width (24) save(Survey2_Q18.doc) fs(10) font(Times New Roman), replace

*Q19

capture drop Q19_1 Q19_2 Q19_4 Q19_12 Q19_13 Q19_20 Q19_21 Q19_15

gen Q19_1 = 1 if strmatch(Q19, "1") | strmatch(Q19, "1,*") | strmatch(Q19, "*,1") | strmatch(Q19, "*,1,*")
gen Q19_2 = 1 if strmatch(Q19, "2") | strmatch(Q19, "2,*") | strmatch(Q19, "*,2") | strmatch(Q19, "*,2,*")
gen Q19_4 = 1 if strmatch(Q19, "4") | strmatch(Q19, "4,*") | strmatch(Q19, "*,4") | strmatch(Q19, "*,4,*")
gen Q19_12 = 1 if strmatch(Q19, "12") | strmatch(Q19, "12,*") | strmatch(Q19, "*,12") | strmatch(Q19, "*,12,*")
gen Q19_13 = 1 if strmatch(Q19, "13") | strmatch(Q19, "13,*") | strmatch(Q19, "*,13") | strmatch(Q19, "*,13,*")
gen Q19_20 = 1 if strmatch(Q19, "20") | strmatch(Q19, "20,*") | strmatch(Q19, "*,20") | strmatch(Q19, "*,20,*")
gen Q19_21 = 1 if strmatch(Q19, "21") | strmatch(Q19, "21,*") | strmatch(Q19, "*,21") | strmatch(Q19, "*,21,*")
gen Q19_15 = 1 if strmatch(Q19, "15") | strmatch(Q19, "15,*") | strmatch(Q19, "*,15") | strmatch(Q19, "*,15,*")

label variable Q19_1 "Informationen Intranet"
label variable Q19_2 "Tips Colleagues"
label variable Q19_4 "Individual Transaction Receipt"
label variable Q19_12 "RPI Decision Facilitating"
label variable Q19_13 "RPI Motivation Intrinsic"
label variable Q19_20 "RPI Motivation Sharing"
label variable Q19_21 "Other"
label variable Q19_15"Nothing"

asdoc mrtab Q19_1-Q19_15, by(treatment) rcolumn  chi2 include  title(Useful for increasing AvgS) width (24) save(Survey2_Q19.doc) fs(10) font(Times New Roman), replace


*Q20

capture drop Q20_1 Q20_2 Q20_3 Q20_4 Q20_5 Q20_6

gen Q20_1 = 1 if strmatch(Q20, "1") | strmatch(Q20, "1,*") | strmatch(Q20, "*,1") | strmatch(Q20, "*,1,*")
gen Q20_2 = 1 if strmatch(Q20, "2") | strmatch(Q20, "2,*") | strmatch(Q20, "*,2") | strmatch(Q20, "*,2,*")
gen Q20_3 = 1 if strmatch(Q20, "3") | strmatch(Q20, "3,*") | strmatch(Q20, "*,3") | strmatch(Q20, "*,3,*")
gen Q20_4 = 1 if strmatch(Q20, "4") | strmatch(Q20, "4,*") | strmatch(Q20, "*,4") | strmatch(Q20, "*,4,*")
gen Q20_5 = 1 if strmatch(Q20, "5") | strmatch(Q20, "5,*") | strmatch(Q20, "*,5") | strmatch(Q20, "*,5,*")
gen Q20_6 = 1 if strmatch(Q20, "6") | strmatch(Q20, "6,*") | strmatch(Q20, "*,6") | strmatch(Q20, "*,6,*")


label variable Q20_1 "App"
label variable Q20_2 "Letter"
label variable Q20_3 "SMS"
label variable Q20_4 "Supervisor"
label variable Q20_5 "Other"
label variable Q20_6 "Do not want in future"

asdoc mrtab Q20_1-Q20_6, by(treatment) rcolumn chi2 include  title(Preference Medium RPI Information) width (24) save(Survey2_Q20.doc) fs(10) font(Times New Roman), replace

*Q22

capture drop Q22_1 Q22_2 Q22_3

gen Q22_1 = 1 if strmatch(Q22, "*ne*") | strmatch(Q22, "*Ne*") | strmatch(Q22, "*NE*") | strmatch(Q22, "*gut zu*")
gen Q22_2 = 1 if strmatch(Q22, "*ja*") | strmatch(Q22, "*Ja*") | strmatch(Q22, "*kompliziert*")
gen Q22_3 = 1 if strmatch(Q22, "*noch keine*")


label variable Q22_1 "No"
label variable Q22_2 "Yes"
label variable Q22_3 "Other"

asdoc mrtab Q22_1-Q22_3, by(treatment) rcolumn chi2 include  title(Complicated to Understand) width (24) save(Survey2_Q22.doc) fs(10) font(Times New Roman), replace


