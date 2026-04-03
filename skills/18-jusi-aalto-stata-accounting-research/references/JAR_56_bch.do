***Analysis for "Investor Behavior and the Benefits of Direct Stock Ownership"***
*Darren Bernard, Nicole Cade, and Frank Hodge
*Last updated with annotations December 2017

*Bring in data
use ""
*See dataset available on JAR website
 
set more off

****Clean up variables
*SingleName variable from survey instrument indicates absence of any direct stock ownership
replace NumberInvestments = 0 if SingleName == 0
*Missing for ShareCr (for sharing a credit card) actually indicates no shared credit card data
replace ShareCr = 0 if missing(ShareCr) & Finished == 1
*Reset OwnMoney DV to zero if participant never pays for anything at Starbucks
replace OwnMoney = 0 if Pay_Never == 100
*Reset OwnMoney_Alt (an alternative construction) DV to zero if participant never pays for anything at Starbucks
replace OwnMoney_Alt = 0 if Pay_Never == 100
*Reset NumVisits DV to zero if participant never pays for anything at Starbucks
replace NumVisits = 0 if Pay_Never == 100
*Sum cash payment and gift card proportions
gen Cash_GC_Pays = Pay_Cash + Pay_GiftCard
*Set OwnMoney, OwnMoney_Alt, and NumVisits to be missing when missing a lot of (untrackable) purchase data
replace OwnMoney = . if Cash_GC_Pays > 50 & !missing(Pay_Cash) & !missing(Pay_GiftCard)
replace OwnMoney_Alt = . if Cash_GC_Pays > 50 & !missing(Pay_Cash) & !missing(Pay_GiftCard)
replace NumVisits = . if Cash_GC_Pays > 50 & !missing(Pay_Cash) & !missing(Pay_GiftCard)
*Reset SelfReported to be zero if participant did not self report either CC purchases or App
replace SelfReported = 0 if SelfReported == .5
*Reset Include condition for a couple observations with invalid data
replace Include = 0 if missing(SingleName)

*Do continuous variable standardization
foreach var in OwnMoney OwnMoney_Alt NumVisits RegulatoryAlignment Influence_Purchasing Influence_Voting Affect Dissonance_Purchasing Dissonance_Voting Income Age NumberInvestments CoffeeTeaDrinks WorkGroupTime SBUXLinks FreqComments ToneComments NumberMeetings ReportingConfidence EarningsBeatLikelihood PerceivedConsistency Conservative Access {
	forvalues x = 1(1)3 {
		egen z_`var'`x' = std(`var') if University == `x' & Include == 1
		replace z_`var'`x' = 0 if missing(z_`var'`x')
	}
	gen z_`var' = z_`var'1 + z_`var'2 + z_`var'3
	replace z_`var' = . if missing(`var')
	drop z_`var'1 z_`var'2 z_`var'3
}

*Generate treatment interactions for potential moderators
foreach var in z_Income Female z_Age USNational z_NumberInvestments z_CoffeeTeaDrinks {
	gen T_`var' = Treatment*`var'
}

*Generate treatment interactions for mediation
foreach var in z_Influence_Purchasing z_Influence_Voting {
	gen T_`var' = Treatment*`var'
}

*Generate treatment interactions for social connections
foreach var in z_WorkGroupTime z_SBUXLinks {
	gen T_`var' = Treatment*`var'
}


***************************************************************
***CODE FOR MAIN TABLES***


***TABLE 1: Descriptive statistics***
matrix descriptives = J(29,5,0)
local n = 0
foreach var in OwnMoney OthersMoney RegulatoryAlignment Influence_Purchasing Influence_Voting Affect Dissonance_Purchasing Dissonance_Voting Income Female Age USNational NumberInvestments CoffeeTeaDrinks WorkGroupTime SBUXLinks NumberMeetings FreqComments ToneComments ReportingConfidence PerceivedConsistency EarningsBeatLikelihood SelfReported ShareCr Conservative Coffee_YN Access {
	local n = `n' + 1
	qui su `var' if Include == 1, detail
	matrix descriptives[`n',1] = `r(p25)'
	matrix descriptives[`n',2] = `r(p50)'
	matrix descriptives[`n',3] = `r(p75)'
	matrix descriptives[`n',4] = `r(mean)'
	matrix descriptives[`n',5] = `r(N)'
}
matrix list descriptives


***TABLE 2: Comparisons across experimental conditions of OwnMoney, OthersMoney, and Regulatory Alignment***
*Panel A: OwnMoney
ttest z_OwnMoney if Include == 1, by(Treatment)
*Panel B: OthersMoney
tabulate OthersMoney Treatment if Include == 1, chi2
su OthersMoney if Treatment == 1 & Include == 1
su OthersMoney if Treatment == 0 & Include == 1
*Panel C: RegulatoryAlignment
ttest z_RegulatoryAlignment if Include == 1, by(Treatment)


***TABLE 3 ORIGINAL: Mediation analyses for OwnMoney, OthersMoney, and RegulatoryAlignment***
*Panel A: OwnMoney
reg z_OwnMoney Treatment T_z_Influence_Purchasing z_Affect z_Dissonance_Purchasing if Include == 1
*Panel B: OthersMoney
logit OthersMoney Treatment T_z_Influence_Purchasing z_Affect z_Dissonance_Purchasing if Include == 1
*Panel C: RegulatoryAlignment
reg z_RegulatoryAlignment Treatment T_z_Influence_Voting z_Affect z_Dissonance_Voting if Include == 1


***TABLE 3 ALTERNATIVE (DUE TO NULL RESULTS): Comparisons across experimental conditions of mediation variables***
corr z_OwnMoney z_Influence_Purchasing if Include == 1 & Treatment == 1
pwcorr z_OwnMoney z_Influence_Purchasing if Include == 1 & Treatment == 1, sig
corr z_OwnMoney z_Influence_Purchasing if Include == 1 & Treatment == 0
pwcorr z_OwnMoney z_Influence_Purchasing if Include == 1 & Treatment == 0, sig
reg z_OwnMoney Treatment z_Influence_Purchasing T_z_Influence_Purchasing if Include == 1
 /*
*Check results using "cortesti" command
cortesti 0.0999 106 -0.0672 115
*/
corr OthersMoney z_Influence_Purchasing if Include == 1 & Treatment == 1
pwcorr OthersMoney z_Influence_Purchasing if Include == 1 & Treatment == 1, sig
corr OthersMoney z_Influence_Purchasing if Include == 1 & Treatment == 0
pwcorr OthersMoney z_Influence_Purchasing if Include == 1 & Treatment == 0, sig
reg OthersMoney Treatment z_Influence_Purchasing T_z_Influence_Purchasing if Include == 1

corr z_RegulatoryAlignment z_Influence_Voting if Include == 1 & Treatment == 1
pwcorr z_RegulatoryAlignment z_Influence_Voting if Include == 1 & Treatment == 1, sig
corr z_RegulatoryAlignment z_Influence_Voting if Include == 1 & Treatment == 0
pwcorr z_RegulatoryAlignment z_Influence_Voting if Include == 1 & Treatment == 0, sig
reg z_RegulatoryAlignment Treatment z_Influence_Voting T_z_Influence_Voting if Include == 1

ttest z_Affect if Include == 1, by(Treatment)
ttest z_Dissonance_Purchasing if Include == 1, by(Treatment)
ttest z_Dissonance_Voting if Include == 1, by(Treatment)


***TABLE 4: Individual characteristics as potential moderators***
*Panel A: OwnMoney
reg z_OwnMoney Treatment z_Income T_z_Income if Include == 1
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(1) replace
reg z_OwnMoney Treatment Female T_Female if Include == 1
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(2) 
reg z_OwnMoney Treatment z_Age T_z_Age if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(3) 
reg z_OwnMoney Treatment USNational T_USNational if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(4) 
reg z_OwnMoney Treatment z_NumberInvestments T_z_NumberInvestments if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(5) 
reg z_OwnMoney Treatment z_CoffeeTeaDrinks T_z_CoffeeTeaDrinks if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(6) 
reg z_OwnMoney Treatment z_Income Female z_Age USNational z_NumberInvestments z_CoffeeTeaDrinks T_z_Income T_Female T_z_Age T_USNational T_z_NumberInvestments T_z_CoffeeTeaDrinks if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(7) 
*Panel B: OthersMoney
logit OthersMoney Treatment z_Income T_z_Income if Include == 1
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(1) replace
logit OthersMoney Treatment Female T_Female if Include == 1
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(2) 
logit OthersMoney Treatment z_Age T_z_Age if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(3) 
logit OthersMoney Treatment USNational T_USNational if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(4) 
logit OthersMoney Treatment z_NumberInvestments T_z_NumberInvestments if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(5) 
logit OthersMoney Treatment z_CoffeeTeaDrinks T_z_CoffeeTeaDrinks if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(6) 
logit OthersMoney Treatment z_Income Female z_Age USNational z_NumberInvestments z_CoffeeTeaDrinks T_z_Income T_Female T_z_Age T_USNational T_z_NumberInvestments T_z_CoffeeTeaDrinks if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(7) 
*Panel C: RegulatoryAlignment
reg z_RegulatoryAlignment Treatment z_Income T_z_Income if Include == 1
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(1) replace
reg z_RegulatoryAlignment Treatment Female T_Female if Include == 1
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(2) 
reg z_RegulatoryAlignment Treatment z_Age T_z_Age if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(3) 
reg z_RegulatoryAlignment Treatment USNational T_USNational if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(4) 
reg z_RegulatoryAlignment Treatment z_NumberInvestments T_z_NumberInvestments if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(5) 
reg z_RegulatoryAlignment Treatment z_CoffeeTeaDrinks T_z_CoffeeTeaDrinks if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(6) 
reg z_RegulatoryAlignment Treatment z_Income Female z_Age USNational z_NumberInvestments z_CoffeeTeaDrinks T_z_Income T_Female T_z_Age T_USNational T_z_NumberInvestments T_z_CoffeeTeaDrinks if Include == 1 
outreg2 using table4_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(7) 


***TABLE 5: The effects of social connections***
*Panel A: Field Measures of Social Connections
reg z_OwnMoney Treatment z_WorkGroupTime T_z_WorkGroupTime if Include == 1
outreg2 using table5_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(1) replace
reg z_OwnMoney Treatment z_SBUXLinks T_z_SBUXLinks if Include == 1
outreg2 using table5_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(2) 
logit OthersMoney Treatment z_WorkGroupTime T_z_WorkGroupTime if Include == 1
outreg2 using table5_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(3)
logit OthersMoney Treatment z_SBUXLinks T_z_SBUXLinks if Include == 1
outreg2 using table5_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(4)
reg z_RegulatoryAlignment Treatment z_WorkGroupTime T_z_WorkGroupTime if Include == 1
outreg2 using table5_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(5)
reg z_RegulatoryAlignment Treatment z_SBUXLinks T_z_SBUXLinks if Include == 1
outreg2 using table5_reg, stats(coef tstat) bdec(3) tdec(2) excel ctitle(6)

*Panel B: Self-Reported Measures of Social Connections
ttest z_NumberMeetings if Include == 1, by(Treatment)
ttest z_FreqComments if Include == 1, by(Treatment)
ttest z_ToneComments if Include == 1, by(Treatment)


***TABLE 6: Other investor preferences and perceptions***
ttest z_ReportingConfidence if Include == 1, by(Treatment)
ttest z_PerceivedConsistency if Include == 1, by(Treatment)
ttest z_EarningsBeatLikelihood if Include == 1, by(Treatment)


***TABLE 7: Bayesian analysis***
set seed 14
bayesmh OwnMoney Treatment if Include == 1, likelihood(normal({var})) prior({OwnMoney: _cons}, flat) prior ({OwnMoney: Treatment}, normal(0,10)) prior({var}, jeffreys)
bayesgraph diagnostics _all
set seed 14
bayesmh OwnMoney Treatment if Include == 1, likelihood(normal({var})) prior({OwnMoney: _cons}, flat) prior ({OwnMoney: Treatment}, normal(0,100)) prior({var}, jeffreys)
bayesgraph diagnostics _all
set seed 14
bayesmh OwnMoney Treatment if Include == 1, likelihood(normal({var})) prior({OwnMoney: _cons}, flat) prior ({OwnMoney: Treatment}, normal(40,10)) prior({var}, jeffreys)
bayesgraph diagnostics _all
set seed 14
bayesmh OwnMoney Treatment if Include == 1, likelihood(normal({var})) prior({OwnMoney: _cons}, flat) prior ({OwnMoney: Treatment}, normal(40,100)) prior({var}, jeffreys)
bayesgraph diagnostics _all

set seed 14
bayesmh OthersMoney Treatment if Include == 1, likelihood(logit) prior({OthersMoney: _cons}, flat) prior ({OthersMoney: Treatment}, normal(0,0.01)) 
bayesgraph diagnostics _all
set seed 14
bayesmh OthersMoney Treatment if Include == 1, likelihood(logit) prior({OthersMoney: _cons}, flat) prior ({OthersMoney: Treatment}, normal(0,0.1)) 
bayesgraph diagnostics _all
set seed 14
bayesmh OthersMoney Treatment if Include == 1, likelihood(logit) prior({OthersMoney: _cons}, flat) prior ({OthersMoney: Treatment}, normal(0.2,0.01)) 
bayesgraph diagnostics _all
set seed 14
bayesmh OthersMoney Treatment if Include == 1, likelihood(logit) prior({OthersMoney: _cons}, flat) prior ({OthersMoney: Treatment}, normal(0.2,0.1)) 
bayesgraph diagnostics _all

set seed 14
bayesmh RegulatoryAlignment Treatment if Include == 1, likelihood(normal({var})) prior({RegulatoryAlignment: _cons}, flat) prior ({RegulatoryAlignment: Treatment}, normal(0,10)) prior({var}, jeffreys)
bayesgraph diagnostics _all
set seed 14
bayesmh RegulatoryAlignment Treatment if Include == 1, likelihood(normal({var})) prior({RegulatoryAlignment: _cons}, flat) prior ({RegulatoryAlignment: Treatment}, normal(0,100)) prior({var}, jeffreys)
bayesgraph diagnostics _all
set seed 14
bayesmh RegulatoryAlignment Treatment if Include == 1, likelihood(normal({var})) prior({RegulatoryAlignment: _cons}, flat) prior ({RegulatoryAlignment: Treatment}, normal(20,10)) prior({var}, jeffreys)
bayesgraph diagnostics _all
set seed 14
bayesmh RegulatoryAlignment Treatment if Include == 1, likelihood(normal({var})) prior({RegulatoryAlignment: _cons}, flat) prior ({RegulatoryAlignment: Treatment}, normal(20,100)) prior({var}, jeffreys)
bayesgraph diagnostics _all



