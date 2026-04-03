
***************************************************************************
**************************JAR Final Version********************************
***************************************************************************

*Coding Description List*

*Choice: Coded 1 (0) for main (secondary) experiment
*Subjectnr: Coded 1 (2) [3] for supervisor (employee) [canddiate]
*Precise: Coded 1 (0) for precise (imprecise) condition

***************************************************************************
***Section 4 of the paper***
***************************************************************************

*Section 4.1
sum FinalTotalPay if Choice==1
sum male age if Choice==1

***************************************************************************
***Section 5 of the paper***
***************************************************************************

*Section 5.2
*Untabulated test - Employee Early Effort vs. External Candidate Effort
sum CostlyEarlyEffortT CostlyCanEffortT if subjectnr==3 & Choice==1
signrank CostlyEarlyEffortT = CostlyCanEffortT if subjectnr==3 & Choice==1
*Untabulated test - Employee Effort in Period 3 versus Period 1 and Period 2
sum r1effort r2effort r3effort  if subjectnr==1 & Choice==1
signrank r1effort=r3effort if subjectnr==1 & Choice==1
signrank r2effort=r3effort if subjectnr==1 & Choice==1
bysort Precise: sum r1effort r2effort r3effort  if subjectnr==1 & Choice==1
bysort Precise: signrank r1effort=r3effort if subjectnr==1 & Choice==1
bysort Precise: signrank r2effort=r3effort if subjectnr==1 & Choice==1

*Section 5.3
*Untabulated test - Promotion by gender
logit promote male if subjectnr==1 & Choice==1
*Untabulated test - Marginal effects for promotion (Figure 3)
logit promote Precise##c.EarlyEffortT male if subjectnr==1 & Choice==1, nolog
margins, dydx(Precise) at(EarlyEffortT==5)
margins, dydx(Precise) at(EarlyEffortT==10)
margins, dydx(Precise) at(EarlyEffortT==15)
margins, dydx(Precise) at(EarlyEffortT==20)
margins, dydx(Precise) at(EarlyEffortT==25)
margins, dydx(Precise) at(EarlyEffortT==30)
margins, dydx(Precise) at(EarlyEffortT==35)
margins, dydx(Precise) at(EarlyEffortT==40)
margins, dydx(Precise) at(EarlyEffortT==45)
margins, dydx(Precise) at(EarlyEffortT==50)
margins, dydx(Precise) at(EarlyEffortT==55)
margins, dydx(Precise) at(EarlyEffortT==60)
margins, dydx(Precise) at(EarlyEffortT==65)
margins, dydx(Precise) at(EarlyEffortT==70)
margins, dydx(Precise) at(EarlyEffortT==75)
margins, dydx(Precise) at(EarlyEffortT==80)
margins, dydx(Precise) at(EarlyEffortT==85)
margins, dydx(Precise) at(EarlyEffortT==90)
margins, dydx(Precise) at(EarlyEffortT==95)
margins, dydx(Precise) at(EarlyEffortT==100)
*Untabulated test - Effort change influcing promotion liklihood
logit promote c.r1empeffort c.r2ch c.r3ch  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 
logit promote gender Precise c.r1empeffort c.r2ch c.r3ch  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 

*Section 5.4
*Untabulated test - Worker post-decision effort staying above costless effort
signrank LateEffortT=20 if subjectnr==1 & Choice==1 & promote==1

*Section 5.6
*Untabulated test - Promotion across choice
logit promote Choice if subjectnr==1 & Precise==1

***************************************************************************
***Footnotes in the paper***
***************************************************************************

*Footnote 13: Wilk-shapiro test
swilk r1effort r2effort r3effort EarlyEffortT LateEffortT EffortChT if subjectnr==1 & Choice==1

*Footnote 15: Candidate Effort as DV
anova CanEffortT promote##Precise if subjectnr==3 & Choice==1

*Footnote 16: Effort Spike
bysort Spike10: sum emppeq2 emppeq3 if subjectnr==2 & Choice==1
ranksum emppeq2 if subjectnr==2 & Choice==1, by (Spike10)
ranksum emppeq3 if subjectnr==2 & Choice==1, by (Spike10)
bysort Spike15: sum emppeq2 emppeq3 if subjectnr==2 & Choice==1
ranksum emppeq2 if subjectnr==2 & Choice==1, by (Spike15)
ranksum emppeq3 if subjectnr==2 & Choice==1, by (Spike15)

*Footnote 18: Variance analysis
logit promote c.centered_EarlyEffortT EarlyEffortVar if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 
logit promote c.centered_EarlyEffortT##c.centered_Precise male EarlyEffortVar if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 

*Footnote 19: Non-Promoted employees' post-promotion effort
sum LateEffortT if subjectnr==1 & Choice==1 & promote == 0
signrank LateEffortT = 20 if subjectnr==1 & Choice==1 & promote == 0

*Footnote 20: PEQ analysis - See excel file

*Footnote 21: Social Vaule Orientation Scale
logit promote tot_prosoc  tot_comp  c.centered_EarlyEffortT##c.centered_Precise male  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 

*Footnote 22: External Worker's Effort
ranksum r4caneffort if subjectnr==3 & Choice==1, by (Precise)
ranksum r5caneffort if subjectnr==3 & Choice==1, by (Precise)
ranksum r6caneffort if subjectnr==3 & Choice==1, by (Precise)

*Footnote 24: Demographics
ttest gender, by (Choice)
ttest age, by (Choice)
ttest status, by (Choice)
ttest study, by (Choice)
ttest work, by (Choice)
ttest job, by (Choice)
ttest tot_right, by (Choice)

***************************************************************************
***Tables in the paper***
***************************************************************************

***Table 1***
*Panel A
bysort Precise: tabstat r1effort r2effort r3effort EarlyEffortT r4effort r5effort r6effort LateEffortT if subjectnr==1 & Choice==1, s( mean sd n) columns(statistics) format(%14.1fc) 
ranksum r1effort if subjectnr==1 & Choice==1, by (Precise)
ranksum r2effort if subjectnr==1 & Choice==1, by (Precise)
ranksum r3effort if subjectnr==1 & Choice==1, by (Precise)
ranksum EarlyEffortT if subjectnr==1 & Choice==1, by (Precise)
ranksum r4effort if subjectnr==1 & Choice==1, by (Precise)
ranksum r5effort if subjectnr==1 & Choice==1, by (Precise)
ranksum r6effort if subjectnr==1 & Choice==1, by (Precise)
ranksum LateEffortT if subjectnr==1 & Choice==1, by (Precise)
*Panel B
tab promote if subjectnr==1 & Choice==1
bysort Precise: tab promote if subjectnr==1 & Choice==1
tab promote Precise if subjectnr==1 & Choice==1, chi2
*Panel C
bysort Precise promote: tabstat EarlyEffortT LateEffortT if subjectnr==1 & Choice==1, s( mean sd n) columns(statistics) format(%14.1fc) 
bysort promote: tabstat EarlyEffortT LateEffortT if subjectnr==1 & Choice==1, s( mean sd n) columns(statistics) format(%14.1fc) 

***Table 2***
*Panel A
bysort Precise: sum r1effort r2effort r3effort EarlyEffortT if subjectnr==1  & Choice==1
signrank r1effort = 20 if subjectnr==1 & Precise==1  & Choice==1
return list
di "corrected p-value=" min(1,r(p)*4)
signrank r1effort = 20 if subjectnr==1 & Precise==0  & Choice==1
return list
di "corrected p-value=" min(1,r(p)*4)
signrank r2effort = 20 if subjectnr==1 & Precise==1  & Choice==1
signrank r2effort = 20 if subjectnr==1 & Precise==0  & Choice==1
signrank r3effort = 20 if subjectnr==1 & Precise==1  & Choice==1
signrank r3effort = 20 if subjectnr==1 & Precise==0  & Choice==1
signrank EarlyEffortT = 20 if subjectnr==1 & Precise==1  & Choice==1
signrank EarlyEffortT = 20 if subjectnr==1 & Precise==0  & Choice==1
*Panel B
/*Requires long-format data. - Provided below, but currently formated as a note.
use "C:\Users\jibble\Dropbox\CLM promote vs. external\Data\CLM EmpDataLongFormatTypes.dta", clear
anova effort cond / id|cond period cond#period if period<4, repeat(period) 
anova effort c.tot_comp c.tot_ind cond / id|cond period cond#period if period<4, repeat(period) 
anova effort c.tot_comp c.tot_ind cond / id|cond period c.tot_comp##period c.tot_ind##period cond##period if period<4, repeat(period)*/

***Table 3***
*Model 1
logit promote c.centered_EarlyEffortT##c.centered_Precise  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 
*Model 2
logit promote c.centered_EarlyEffortT##c.centered_Precise male  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 
*Model 3
logit promote c.r1effort c.r2effort c.r3effort  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 
*Model 4
logit promote  male c.centered_Precise##c.r1effort c.centered_Precise##c.r2effort c.centered_Precise##c.r3effort  if subjectnr==1 & Choice==1, cformat(%9.2f) pformat(%5.3f) 

***Table 4***
*Panel A
bysort promote: sum  EarlyEffortT LateEffortT EffortChT if subjectnr==1 & Choice==1
ranksum EarlyEffortT if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*3)
ranksum LateEffortT if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*3)
ranksum EffortChT if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*3)
*Panel B
bysort Precise: sum  EarlyEffortT LateEffortT EffortChT if subjectnr==1 & Choice==1 & promote==1
ranksum EarlyEffortT if subjectnr==1 & promote==1 & Choice==1, by (Precise)
return list
di "corrected p-value=" min(1,r(p)*3)
ranksum LateEffortT if subjectnr==1 & promote==1 & Choice==1, by (Precise)
return list
di "corrected p-value=" min(1,r(p)*3)
ranksum EffortChT if subjectnr==1 & promote==1 & Choice==1, by (Precise)
return list
di "corrected p-value=" min(1,r(p)*3)
*Panel C
bysort Precise: sum  EarlyEffortT LateEffortT EffortChT if subjectnr==1 & Choice==1 & promote==0
ranksum EarlyEffortT if subjectnr==1 & promote==0 & Choice==1, by (Precise)
return list
di "corrected p-value=" min(1,r(p)*3)
ranksum LateEffortT if subjectnr==1 & promote==0 & Choice==1, by (Precise)
return list
di "corrected p-value=" min(1,r(p)*3)
ranksum EffortChT if subjectnr==1 & promote==0 & Choice==1, by (Precise)
return list
di "corrected p-value=" min(1,r(p)*3)

***Table 5***
*Panel A
bysort promote: sum r4caneffortT r5caneffortT r6caneffortT CanEffortT if subjectnr==3 & Choice==1
*Panel B
bysort promote: sum tot_emp_pay tot_can_pay tot_sup_pay TotEffort if subjectnr==1 & Choice==1
ranksum tot_emp_pay if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*4)
ranksum tot_can_pay if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*4)
ranksum tot_sup_pay if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*4)
ranksum TotEffort if subjectnr==1 & Choice==1, by (promote)
return list
di "corrected p-value=" min(1,r(p)*4)

***Table 6***
*Panel A
tab promote if subjectnr==2 & Precise==1 & Choice==0
*Panel B
logit promote EarlyEffortT  if Choice==0 & subjectnr==2 
*Panel C
logit promote c.EarlyEffortT##Choice  if Precise==1 & subjectnr==2 


***************************************************************************
***Figures in the paper***
***************************************************************************

***Figure 2***
***Done in Excel, data below***
bysort Precise promote: sum r1effort r2effort r3effort r4effort r5effort r6effort if subjectnr==1 & Choice==1
bysort Precise promote: sum r4caneffortT r5caneffortT r6caneffortT  if subjectnr==3 & Choice==1

***Figure 3***
***Done in Excel, data below***
logit promote  i.Precise##c.EarlyEffort  if subjectnr==1, nolog
margins i.Precise, at(EarlyEffort==(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)) vsquish
*marginsplot,  ylabel(0(.1)1) noci

