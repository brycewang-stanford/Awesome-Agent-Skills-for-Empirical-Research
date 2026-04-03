

//------------------------------------------------------------------------------
local folder "C:\Users\Jzureich\Dropbox\Dissertation\Data\FinalData\"	//***Adjust this for your machine

local Condition0 "BothMCsCorrect >= 0" //Full sample
local Condition1 "BothMCsCorrect == 1" //Both manipulation checks correct
local conditionnum = 1

//------------------------
//LOADING IN THE LONG DATA
use "`folder'\AnalyticDataset_Long.dta", clear

keep if `Condition`conditionnum'' //keeping the desired sample (full or both mcs correct)


//Recoding the binary variables to be -.5/.5 rather than 0/1
local Low = -.5
local High = .5
replace LowContr = `Low' if LowContr == 0
replace Informativeness_Other = `Low' if Informativeness_Other == 0
replace Informativeness_Own = `Low' if Informativeness_Own == 0
replace LowContr = `High' if LowContr == 1
replace Informativeness_Other = `High' if Informativeness_Other == 1
replace Informativeness_Own = `High' if Informativeness_Own == 1

//Standardizing the continuous variables (this needs to be done after keeping the desired sample)
egen GF_RespTimes_std = std(GF_RespTimes) if NumMisses < 14 //omitting one person who did not take the response-time task seriously (see footnote 18)
egen GF_Survey_std = std(GF_Survey)
replace GF_RespTimes_std = GF_RespTimes_std*`High'
replace GF_Survey_std = GF_Survey_std*`High'

//Creating a factor analysis of the two goal-focus measures for a robustness check
factor GF_RespTimes_std GF_Survey_std, factors(1)
predict GF_Factor
egen GF_Factor_std = std(GF_Factor)
replace GF_Factor_std = GF_Factor_std*`High'


cls
//------------------------
//ANALYSES
//Note that using i.Round##i.Trial fixed effects gives 60 fixed effect estiamtes (3*20). 
//This is statistically identical to using fixed effects for each of the 60 choice numbers.

//------------
//MAIN ANALYSIS (column 1)
logit DecQual c.LowContr i.Round##i.Trial, vce(cluster workerId) 
margins, dydx(LowContr)


//------------
//MAIN ANALYSIS robustness check without fixed effects (column 2)
logit DecQual c.LowContr, vce(cluster workerId) 
margins, dydx(LowContr)


//------------
//Effect of the controllability manipulation across rounds (averaged across trials)
logit DecQual c.LowContr##i.Round##i.Trial, vce(cluster workerId)
margins, dydx(LowContr) at(Round=(1 2 3)) post

//all pairwise comparisons of rounds
lincom _b[LowContr:2._at] - _b[LowContr:1bn._at]
lincom _b[LowContr:3._at] - _b[LowContr:2._at]


//------------
//Effect of the controllability manipulation across trials (averaged across rounds)
logit DecQual c.LowContr##(i.Round##i.Trial), vce(cluster workerId)
margins, dydx(c.LowContr) at(Trial=(1(1)20)) post

//making comparisons across different sets of trials
forvalues cutoff = 1/19 {
	local lintest1 "(-1/`cutoff')*_b[LowContr:1bn._at]"
	if `cutoff' >= 2 {
		forvalues i = 2/`cutoff' {
			local lintest1 "`lintest1' + (-1/`cutoff')*_b[LowContr:`i'._at]"
		}
	}
	local x = `cutoff' + 1
	local y = `cutoff' + 2
	local lintest2 "(1/(20-`cutoff'))*_b[LowContr:`x'._at]"
	if `y' <= 20 {
		forvalues i = `y'/20 {
			local lintest2 "`lintest2' + (1/(20-`cutoff'))*_b[LowContr:`i'._at]"
		}
	}
	
	quietly: lincom -1*(`lintest1')
	local m1 = string(round(100*`r(estimate)', .01), "%9.2f")
	local p1 = string(round(`r(p)', .001), "%9.3f")
	quietly: lincom `lintest2'
	local m2 = string(round(100*`r(estimate)', .01), "%9.2f")
	local p2 = string(round(`r(p)', .001), "%9.3f")
	quietly: lincom `lintest2' + `lintest1'
	local mdiff = string(round(100*`r(estimate)', .01), "%9.2f")
	local pdiff = string(round(`r(p)', .001), "%9.3f")
	
	di "Cutoff: `cutoff'; Effect (early): `m1'%; p (early): `p1'; Effect (late): `m2'%; p (late): `p2'; Effect (Diff): `mdiff'%; p (diff): `pdiff'"
}


//------------
//Interactions with informativeness_Other (informativeness of outcomes in the uncontrollable factories) (column 3)
logit DecQual c.LowContr##c.Informativeness_Other i.Round##i.Trial, vce(cluster workerId)
margins, dydx(LowContr) //main effect of LowContr
margins, dydx(Informativeness_Other) //main effect of Informativeness_Other
margins, dydx(LowContr) at(Informativeness_Other=(`Low' `High')) post
lincom _b[LowContr:2._at] - _b[LowContr:1bn._at]
di round(`r(p)'/2, .001)


//------------
//Footnote 17: Checking whether the results are robust to including Informativeness_Own 
logit DecQual c.LowContr##(c.Informativeness_Other c.Informativeness_Own) i.Round##i.Trial, vce(cluster workerId)
margins, dydx(LowContr) //main effect of LowContr
margins, dydx(Informativeness_Own) //main effect of Informativeness_Own
margins, dydx(LowContr) at(Informativeness_Other=(`Low' `High')) post
lincom _b[LowContr:2._at] - _b[LowContr:1bn._at]
di round(`r(p)'/2, .001)


//------------
//Showing that interacting the controllability manipulation with Informativneness_Other kills the interaction with round 
//This suggests that the controllability manipulation's effect on learning across rounds is explained by its effect on how
//well participants utilize information in the uncontrollable factories
logit DecQual c.LowContr##(c.Informativeness_Other i.Round##i.Trial), vce(cluster workerId)
margins, dydx(c.LowContr) at(Round=(1 2 3)) post coeflegend
lincom _b[LowContr:2._at] - _b[LowContr:1bn._at]
lincom _b[LowContr:3._at] - _b[LowContr:2._at]


//------------
//Interacting the controllability manipulation with goal-focus, measured using the response-time task (column 4)
logit DecQual c.LowContr##c.GF_RespTimes_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(LowContr) //main effect of LowContr
margins, dydx(GF_RespTimes_std) //main effect of GF_RespTimes_std
margins, dydx(c.GF_RespTimes_std) at(LowContr=(`Low' `High')) post
lincom _b[GF_RespTimes_std:2._at] - _b[GF_RespTimes_std:1bn._at]
di round(`r(p)'/2, .001)

//Follow-up simple effects of the controllability manipulation at different levels of goal-focus
logit DecQual c.LowContr##c.GF_RespTimes_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(c.LowContr) at(GF_RespTimes_std=(`Low' 0 `High'))


//------------
//Interacting the controllability manipulation with goal-focus, measured using the survey responses (column 5)
logit DecQual c.LowContr##c.GF_Survey_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(LowContr) //main effect of LowContr
margins, dydx(GF_Survey_std) //main effect of GF_Survey_std
margins, dydx(c.GF_Survey_std) at(LowContr=(`Low' `High')) post
lincom _b[GF_Survey_std:2._at] - _b[GF_Survey_std:1bn._at]
di round(`r(p)'/2, .001)

//Follow-up simple effects of the controllability manipulation at different levels of goal-focus
logit DecQual c.LowContr##c.GF_Survey_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(c.LowContr) at(GF_Survey_std=(`Low' 0 `High'))


//------------
//Footnote 19: Checking whether the results also hold when using a factor analysis of the two goal-focus measures
logit DecQual c.LowContr##c.GF_Factor_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(c.GF_Factor_std) at(LowContr=(`Low' `High')) post
lincom _b[GF_Factor_std:2._at] - _b[GF_Factor_std:1bn._at]
di round(`r(p)'/2, .001)

//Follow-up simple effects of the controllability manipulation at different levels of goal-focus
logit DecQual c.LowContr##c.GF_Factor_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(c.LowContr) at(GF_Factor_std=(`Low' 0 `High'))

logit DecQual c.LowContr##c.GF_Factor_std i.Round##i.Trial, vce(cluster workerId)
margins, dydx(c.LowContr) at(GF_Factor_std=(`Low' 0 `High'))




//------------------------------------------------------------------------------
//ANALYSES ON PARTICIPANT ATTENTION ALLOCATION (WIDE DATASET)
//LOADING IN THE WIDE DATA
use "`folder'\AnalyticDataset_Wide.dta", clear

keep if `Condition`conditionnum''

replace LowContr = `Low' if LowContr == 0
replace LowContr = `High' if LowContr == 1

egen GF_RespTimes_std = std(GF_RespTimes) if NumMisses < 14 
egen GF_Survey_std = std(GF_Survey)
replace GF_RespTimes_std = GF_RespTimes_std*`High'
replace GF_Survey_std = GF_Survey_std*`High'


//-------------
//Examining how the controllability manipulation affects the amount of attention participants allocate to the uncontrollable factories (column 6)
reg AttnUncontr c.LowContr, r
lincom _b[_cons] + `Low'*_b[c.LowContr]
lincom _b[_cons] + `High'*_b[c.LowContr]


//-------------
//Examining whether the attention effects of the controllability manipulation depends on goal-focus, measuring using the response-time task (column 7)
reg AttnUncontr c.LowContr##c.GF_RespTimes_std, r
margins, dydx(LowContr) at(GF_RespTimes_std=(`Low' 0 `High'))


//-------------
//Examining whether the attention effects of the controllability manipulation depends on goal-focus, measuring using the survey responses (column 8)
reg AttnUncontr c.LowContr##c.GF_Survey_std, r
margins, dydx(LowContr) at(GF_Survey_std=(`Low' 0 `High'))



local folder "C:\Users\Jzureich\Dropbox\Dissertation\Data\FinalData\"	//***Adjust this for your machine
import excel "`folder'\RawData_Anonymized__.xlsx", sheet("RawData") firstrow clear

rename LowControllability LowContr 

//------------------------------------------------------------------------------
//DROPPING EXTRANEOUS VARIABLE
drop Status Durationinseconds Finished RecipientLastName RecipientFirstName RecordedDate
drop RecipientEmail ExternalReference DistributionChannel UserLanguage Q16_FirstClick 
drop Q16_LastClick Q16_ClickCount Q48_FirstClick Q48_LastClick Q48_ClickCount 
drop Q2 Q17_FirstClick Q17_LastClick Q17_ClickCount Q44_FirstClick Q44_LastClick 
drop Q44_ClickCount Q45_FirstClick Q45_LastClick Q45_ClickCount Q46_FirstClick 
drop Q46_LastClick Q46_ClickCount Q47_FirstClick Q47_LastClick Q47_ClickCount 
drop Q18_FirstClick Q18_LastClick Q18_ClickCount Q29_FirstClick Q29_LastClick 
drop Q29_ClickCount BO BP BR Q42_FirstClick Q42_LastClick Q42_ClickCount Q23_FirstClick 
drop Q23_LastClick Q23_ClickCount CQ CR CT Q35_FirstClick Q35_LastClick Q35_ClickCount 
drop Q38_FirstClick Q38_LastClick Q38_ClickCount Q41_FirstClick Q41_LastClick 
drop Q41_ClickCount Q43_FirstClick Q43_LastClick Q43_ClickCount Q49_FirstClick 
drop Q49_LastClick Q49_ClickCount TimePerfReports TimePerfReports_String LexicalData 
drop TotalTime_GoalGoal TotalTime_ControlGoal TotalTime_GoalControl 
drop TotalTime_ControlControl TotalTime_NonGoalGoal TotalTimeLn_GoalGoal
drop TotalTimeLn_ControlGoal TotalTimeLn_GoalControl TotalTimeLn_ControlControl TotalTimeLn_NonGoalGoal


//------------------------------------------------------------------------------
//DROPPING PARTICIPANTS TO REACH THE FINAL SAMPLE

//--------------------
//dropping duplicates (see footnote 11 in the manuscript)
local Varlist ""workerId""
foreach Var in `Varlist' {
	sort `Var' StartDate
	quietly by `Var': gen dup_`Var' = cond(_N==1,0,_n) 
}
drop if dup_workerId > 0 
drop dup_workerId
//IPAddress is deleted for the public data posting. There are no duplicates IPs after dropping duplicate ID

//--------------------
//dropping people who didn't finish
//Progress is a variable recorded by Qualtrics based on the % of pages reached. Some people aren't 100% b/c they didn't click continue on the final page
drop if Progress < 95  
drop Progress 

//------------------------------------------------------------------------------
//ATTENTION CHECKS
rename (Q6_1 Q6_2 Q52_1 Q52_2 Q26_1 Q26_2 Q44_1 Q44_2 Q45_1 Q45_2 Q48_1_1) (AC1 AC2 AC3 AC4 AC5 AC6 AC7 AC8 AC9 AC11 AC10)
foreach num of numlist 1, 2, 4, 5, 6, 7, 8, 9 { //TRUE
	replace AC`num' = [AC`num' == 0]
}
foreach num of numlist 3, 11 { //FALSE
	replace AC`num' = [AC`num' == 1]
}
replace AC10 = [AC10 == .08]
gen BothMCsCorrect = [AC9 == 1 & AC10 == 1]
egen ACTotal = rowtotal(AC1 AC2 AC3 AC4 AC5 AC6 AC7 AC8 AC9 AC10 AC11)

local ACsOrder "AC1 AC2 AC3 AC4 AC5 AC6 AC7 AC8 AC9 AC10 AC11 ACTotal BothMCsCorrect"

//------------------------------------------------------------------------------
//PAY
//-Calculating participants' hourly pay
replace Pay = .08*OwnPointsTotal if LowContr == 0 & Pay ==. 
replace Pay = .04*OwnPointsTotal + .02*(OtherPointsTotal1 + OtherPointsTotal2) if LowContr == 1 & Pay ==. 
gen Minutes = Q_TotalDuration/60
gen HourlyPay = Pay/(Minutes/60)

local PayOrder "Pay Minutes HourlyPay"

//------------------------------------------------------------------------------
//TIME VARIABLES
//-Creating and logging time variables
rename (Q29_PageSubmit) (TimeDecisionTask)

local varlist "Q_TotalDuration TimeOtherFB1 TimeOtherFB2 TimeOtherBonus1 TimeOtherBonus2 TimeDecisionTask TimeOwnFB TimeOwnBonus"
foreach var in `varlist' {
	gen Ln`var' = ln(`var' + .01)
}

drop *PageSubmit* BQ CS
drop Time*String*

local TimeOrder ""


//------------------------------------------------------------------------------
//RECORDING THE VARIABLES FOR DECISION QUALITY
//-Decision quality (points scored by the participant and the points scored by the two employees [controlled by an algorithm] in the other factories)


//--------------------
rename (OwnPointsTotal) (DecQual) //OwnPointsTotal is the total number of correct choices made by the participant in their own factory (calculated in Qualtrics)

//-OwnPoints_String = points scored by the participant (a string that sequentially recorded points in each round separated by a comma: e.g., '2, 3, ...')
//-OtherPoints_String1 = points scored by the employee in the factory Beta (same formatting as OwnPoints_String)
//-OtherPoints_String2 = points scored by the employee in the factory Gamma (same formatting as OwnPoints_String)

//-OwnChoices_String = the model of car the participant chose to produce in their factory, i.e., factory Alpha (same formatting as OwnPoints_String)
//-OtherChoices_String1 = the model of car the employee in factory Beta chose to produce (same formatting as OwnPoints_String)
//-OtherChoices_String2 = the model of car the employee in factory Gamma (same formatting as OwnPoints_String)

rename (OwnPoints_String OtherPoints_String1 OtherPoints_String2 OwnChoices_String OtherChoices_String1 OtherChoices_String2) ////
       (OwnPoints OtherPoints1 OtherPoints2 OwnChoices OtherChoices1 OtherChoices2)
	   
local varlist "OwnPoints OtherPoints1 OtherPoints2 OwnChoices OtherChoices1 OtherChoices2"
foreach var in `varlist' {
	split `var', p(", ")
	forvalues i = 1/60 {
		replace `var'`i' = substr(`var'`i', 1, 1)
		destring `var'`i', replace
	}
	drop `var'
}


//------------------------------------------------------------------------------
//RECORDING THE VARIABLES FOR HOW PARTICIPANTS ALLOCATED THEIR ATTENTION

//--------------------
//-TimeOwnFB: The total amount of time (across all 60 choices) participants spent hovering their mouse over the feedback for their own factory (Alpha)
//-TimeOtherFB1: The total amount of time (across all 60 choices) participants spent hovering their mouse over the feedback for the first other factory (Beta)
//-TimeOtherFB2: The total amount of time (across all 60 choices) participants spent hovering their mouse over the feedback for the second other (Gamma)
//-TimeOwnBonus: The total amount of time (across all 60 choices) participants spent hovering their mouse of the bonus amount they received from their factory (Alpha)
//-TimeOtherBonus1: The total amount of time (across all 60 choices) participants spent hovering their mouse of the bonus amount they received from their factory (Beta)
//-TimeOtherBonus2: The total amount of time (across all 60 choices) participants spent hovering their mouse of the bonus amount they received from their factory (Gamma)

//-TimeFB's are the most important variables. These variables record the amount of time participants spent looking at the decision and outcome.
//-TimeBonus's are less important because viewing the bonus does not give any information about the optimal action. Just seeing the bonus
// without the associated decision provides no help. Thus, if participants in the less controllable condition are only curious how 
// much money they received from the other employees, they would view the bonus and would not get any information to help them make
// better decisions. 

egen TimeOtherFB = rowmean(TimeOtherFB1 TimeOtherFB2)
egen LnTimeOtherFB = rowmean(LnTimeOtherFB1 LnTimeOtherFB2)
gen AttnUncontr = LnTimeOtherFB - LnTimeOwnFB //this is the main variable. 

local TimeOrder "Q_TotalDuration TimeDecisionTask TimeOwnFB TimeOwnBonus TimeOtherFB1 TimeOtherFB2 TimeOtherFB TimeOtherBonus1 TimeOtherBonus2"
local TimeOrder "`TimeOrder' LnQ_TotalDuration LnTimeDecisionTask LnTimeOwnFB LnTimeOwnBonus LnTimeOtherFB1 LnTimeOtherFB2 LnTimeOtherFB LnTimeOtherBonus1 LnTimeOtherBonus2"

//------------------------------------------------------------------------------
//POST-EXPERIMENTAL QUESTIONNAIRE 

rename Q11 FreeResponse
rename (Q46_1 Q46_2 Q41_1 Q41_2 Q41_3) (GoalFocusPEQ1 GoalFocusPEQ2 GoalFocusPEQ3 GoalFocusPEQ4 GoalFocusPEQ5)
replace GoalFocusPEQ3 = 4 - GoalFocusPEQ3 //reverse coded
replace GoalFocusPEQ4 = 4 - GoalFocusPEQ4 //reverse coded
egen GoalFocusPEQ_Task = rowmean(GoalFocusPEQ1 GoalFocusPEQ2) //these 2 questions capture self-reported goal-focus on the experimental task
egen GF_Survey = rowmean(GoalFocusPEQ3 GoalFocusPEQ4 GoalFocusPEQ5) //these 3 questions (from prior research) capture generalized goal-focus in everyday life

rename (Q46_3 Q46_4 Q46_5 Q46_6) (OtherFBPEQ1 OtherFBPEQ2 Effort CaredAboutMoney)
egen OtherFBPEQ = rowmean(OtherFBPEQ1 OtherFBPEQ2)

rename (Q46_7 Q46_8 Q46_9) (UncontrollablePay ControllablePay AversionToUncontrollable)
gen ControllablePayDiff = ControllablePay - UncontrollablePay

local PEQsOrder "FreeResponse GoalFocusPEQ1 GoalFocusPEQ2 GoalFocusPEQ_Task OtherFBPEQ1 OtherFBPEQ2 OtherFBPEQ"
local PEQsOrder "`PEQsOrder'  Effort CaredAboutMoney UncontrollablePay ControllablePay ControllablePayDiff AversionToUncontrollable"
local PEQsOrder "`PEQsOrder' GoalFocusPEQ3 GoalFocusPEQ4 GoalFocusPEQ5"


//--------------------
//Demographics
rename (Q40 Q41 Q42 Q44) (Age Male Education Income)
replace Male =. if Male >= 2

local DemographicsOrder "Age Male Education Income"


//------------------------------------------------------------------------------
//Running the python scripts and merging with the data created in those scripts

//--------------------
//Goal Focus
//-This python script calculates the goal-focus scores from the response-time task (see the "Goal-Focus" subsection in section 4.3)
python script "`folder'\DoFiles\ProcessingGoalFocusData.py"
sort workerId StartDate
merge 1:m workerId using "`folder'\PythonGoalFocus.dta"
drop if _merge == 2 //the python script use the raw data with duplicates, etc. - this line drops them after the merge
drop _merge
gen GF_RespTimes1P = GoalGoal1 - ControlGoal1
gen GF_RespTimes2P = GoalGoal2 - ControlGoal2
gen GF_RespTimes3P = GoalGoal3 - ControlGoal3
drop GoalGoal* ControlGoal*

local GFRespTimeOrder "GF_RespTimes1P GF_RespTimes2P GF_RespTimes3P NumMisses Q33_1_TEXT Q33_1_1 Q33_2_TEXT Q33_2_1 Q33_3_TEXT Q33_3_1 Q36_1_TEXT"


//--------------------
//Informativeness of the other factories' choices
//-This python script calculates the total informativness of the feedback provided by the other factories across all 60 choice rounds
python script "`folder'\DoFiles\ProcessingInformativeness.py"
merge 1:m workerId using "`folder'\PythonInformativeness.dta"
drop if _merge == 2
drop _merge



//------------------------------------------------------------------------------
//Labelling the variables
label variable DecQual "DecQual"
label variable LowContr "LowContr"
label variable AttnUncontr "AttnUncontr"
label variable Informativeness "Informativeness"
label variable LnTimeDecisionTask "LnTimeDecisionTask"
label variable Effort "Self-reported Effort"
label variable GF_RespTimes "GF_RespTimes"
label variable GF_Survey "GF_Survey"
label variable Age "Age"
label variable Education "Education"
label variable Income "Income"
label variable Male "Male"

label define LowContrl 0 "More Controllable Measure" 1 "Less Controllable Measure"
label values LowContr LowContrl


local KeyVarsOrder "workerId LowContr DecQual Informativeness_Total GF_RespTimes GF_Survey AttnUncontr"
local OtherVarsOrder "StartDate EndDate StartDate EndDate Q30_Browser Q30_Version Q30_OperatingSystem Q30_Resolution OtherPointsTotal1 OtherPointsTotal2"
local OtherWideVarsOrder "OwnPoints* OtherPoints1* OtherPoints2*"
local OtherWideVarsOrder "`OtherWideVarsOrder' OwnChoices* OtherChoices1* OtherChoices2* OptimalChoices_String"

order `KeyVarsOrder' `ACsOrder' `PayOrder' `TimeOrder' `PEQsOrder' `DemographicsOrder' `OtherVarsOrder' `OtherWideVarsOrder' 

//------------------------------------------------------------------------------
//SAVING THE FINAL PRODUCT
save "`folder'\AnalyticDataset_Wide.dta", replace



//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//CREATING THE LONG DATASET

drop DecQual //This is total decision quality across all 60 rounds used in the wide dataset

reshape long OwnPoints OtherPoints1 OtherPoints2 OwnChoices OtherChoices1 OtherChoices2, i(workerId) j(ChoiceNum)

rename OwnPoints DecQual
egen OtherPoints = rowtotal(OtherPoints1 OtherPoints2)

//Participants make 60 total choices: They play 20 independent iterations (i.e., Trials) of the game and each game has 3 Rounds
//At the start of each trial, the winning model (i.e., the state of nature) resets and is randomly chosen (i.i.d across Trials)
gen Trial = floor((ChoiceNum-1)/3)+1
bys workerId Trial (ChoiceNum): gen Round = _n

//whether the participant has chosen the right answer in a previous choice for the given trial (always 0 for choice 1)
gen Informativeness_Own = 0
bys workerId Trial: replace Informativeness_Own = 1 if DecQual[_n-1] >= 1 & Round >= 2

//whether one of the bots has chosen the right answer in a previous choice for the given trial in the uncontrollable factories (always 0 for choice 1)
gen Informativeness_Other = 0
bys workerId Trial: replace Informativeness_Other = 1 if OtherPoints[_n-1] >= 1 & Round >= 2

//Whether anyone (either the participant or the bots) has chosen the right answer in a previous choice for the given trial (always 0 for choice 1)
gen Informativeness = [Informativeness_Other + Informativeness_Own >= 1]



local KeyVarsOrder "workerId Trial Round LowContr DecQual Informativeness_Other GF_RespTimes GF_Survey AttnUncontr"
local OtherLongVarsOrder "Informativeness_Own Informativeness OtherPoints1 OtherPoints2 OtherPoints"

order `KeyVarsOrder' `ACsOrder' `PayOrder' `TimeOrder' `PEQsOrder' `DemographicsOrder' `OtherVarsOrder' `OtherLongVarsOrder' 

save "`folder'/AnalyticDataset_Long.dta", replace

