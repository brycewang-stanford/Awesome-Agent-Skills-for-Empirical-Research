
****************************************************************************************************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************
***                                                                                                                                              ***
***                                                                                                                                              ***
***                                                                                                                                              ***
*** Article: 		Does Consumer Protection Enhance Disclosure Credibility in Reward Crowdfunding?                                              ***
*** Authors: 		Stefano Cascino, Maria Correia, and Ane Tamayo                                                                               ***
*** Journal:		Journal of Accounting Research                                                                                               ***
***                                                                                                                                              ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.                                                 ***
***                                                                                                                                              ***
***                                                                                                                                              ***
***                                                                                                                                              ***
****************************************************************************************************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************

******************
* STATA settings *
******************

clear all
clear matrix
set more off
set linesize 120
set matsize 11000
set maxvar 32767

*Define project path
local path C:\project_kickstarter\STATA

*Define log file
log using "`path'\log\log_file.log", replace

*Define ado file directory
sysdir set PLUS "`path'\ado\plus"

*Define empirical analyses output directory
cd "`path'\empirical_analysis_output"

*Dataset
use "`path'\data\dset_final.dta", clear

**********************************************
* Table 1 - Sample selection and composition *
**********************************************

*Table 1 - Panel A: Sample selection criteria
drop if end_date==. /*drops 414 obs*/
drop if beg_date==. /*drops 3 obs*/
drop if location_country=="" /*drops 1,772 obs*/
drop if foreign==1 /*drops 75,131 obs*/
drop if location_state=="" /*drops 24 obs*/
drop if goal_amount_USD==0 /*drops 3 obs*/

*Fixed effects
encode Subcategory, generate(num_Subcategory)
encode location_state, generate(num_location_state)
encode border_id, generate(num_border_id)
egen state_county = group(County location_state)

*Create a macro for all success variables
global success_variables ///
successful_d ///
logpledged_amount_USD ///
logbackers_n ///
lognewbackers_n ///
logreturningbackers_n ///
logparticipantsreplies_length ///
logsuperbackerreplies_length

*Create a macro for all project variables
global project_variables ///
loggoal_amount_USD ///
logproject_duration ///
projectoftheday_d  ///
multiplecreators_d ///
logrewards_n

*Create a macro for all creator variables
global creator_variables ///
logbio_length_combined ///
logprojectsbacked_n ///
logfacebook_n

*Create a macro for all macro factor variables
global macro_variables ///
logper_capita_gdp ///
high_trust ///
md_comphome ///
HH_state_fdic ///
mpledged_pct_yearstate

*Create a macro for all disclosure variables
global disclosure_variables ///
logtext_length ///
logriskandchal_length

*Create a macro for all disclosure attribute variables
global disclosure_attribute_variables ///
readability_text ///
readability_risks ///
SentimentGI_text ///
SentimentGI_risks ///
CTTR_text ///
CTTR_risks ///
d_legalese_text ///
d_legalese_risk ///
lognumber_numbers_text ///
lognumber_numbers_risks

*Create a macro for all direct cost of disclosure variables
global disclosure_direct_cost_variables ///
logcreator_coll_rep_n ///
logcreator_coll_rep_length ///
creator_involvement

*Create a macro for all variables for which descriptive statistics are provided
global variables_for_descriptives ///
successful_d ///
pledged_amount_USD ///
backers_n ///
newbackers_n ///
returningbackers_n ///
participantsreplies_length ///
superbackerreplies_length ///
text_length ///
riskandchal_length ///
goal_amount_USD ///
project_duration ///
projectoftheday_d  ///
multiplecreators_d ///
rewards_n ///
bio_length_combined ///
projectsbacked_n ///
facebook_n ///
per_capita_gdp ///
high_trust ///
md_comphome ///
HH_state_fdic ///
mpledged_pct_yearstate

*Create a macro for all continuous variables
global continuous_variables ///
loggoal_amount_USD  ///
logproject_duration ///
logrewards_n  ///
logbio_length_combined ///
logprojectsbacked_n ///
logfacebook_n ///
logpledged_amount_USD ///
logbackers_n ///
lognewbackers_n ///
logreturningbackers_n ///
logparticipantsreplies_length ///
logsuperbackerreplies_length ///
logtext_length ///
logcreator_coll_rep_n ///
logcreator_coll_rep_length ///
creator_involvement ///
logriskandchal_length ///
SentimentGI_text ///
SentimentGI_risks ///
readability_text ///
readability_risks ///
pledged_amount_USD ///
backers_n ///
newbackers_n ///
returningbackers_n ///
participantsreplies_length ///
superbackerreplies_length ///
text_length ///
riskandchal_length ///
goal_amount_USD ///
project_duration ///
rewards_n ///
bio_length_combined ///
projectsbacked_n ///
facebook_n ///
number_numbers_risks ///
number_numbers_text ///
lognumber_numbers_risks ///
lognumber_numbers_text ///
CTTR_text ///
CTTR_risks ///
md_comphome ///
per_capita_gdp ///
logper_capita_gdp ///
mpledged_pct_yearstate ///
HH_state_fdic ///
suspected_fraud

*Winsorize continous variables
winsor2 $continuous_variables, cuts(1 99) replace

*Table 1 - Panel B: Projects by year
tab beg_year

*Table 1 - Panel C: Projects by category
tab Category

*Table 1 - Panel D: Projects by size
tab projectsize

*Label variables
label var successful_d "Funded"
label var logpledged_amount_USD "Ln(Pledged)"
label var logbackers_n "Ln(Backers)"
label var lognewbackers_n "Ln(New Backers)"
label var logreturningbackers_n "Ln(Returning Backers)"
label var logparticipantsreplies_length "Ln(Backer Comments) "
label var logsuperbackerreplies_length "Ln(Superbacker Comments)"
label var loggoal_amount_USD "Ln(Goal)"
label var logproject_duration "Ln(Duration)"
label var projectoftheday_d  "Project of the Day"
label var multiplecreators_d "Multiple Creators"
label var logrewards_n "Ln(Rewards)"
label var logbio_length_combined "Ln(Bio Length)"
label var logprojectsbacked_n "Ln(Projects Backed)"
label var logfacebook_n "Ln(Facebook Friends)"
label var logper_capita_gdp "Ln(GDP)"
label var high_trust "Trust"
label var md_comphome "Internet Access"
label var HH_state_fdic "Credit Constraints"
label var mpledged_pct_yearstate "Funding Performance"
label var logtext_length "Ln(Campaign Pitch)"
label var logriskandchal_length "Ln(Risks and Challenges)"
label var readability_text "Readibility"
label var readability_risks "Readibility"
label var SentimentGI_text "Sentiment"
label var SentimentGI_risks "Sentiment"
label var CTTR_text "Lexical Diversity"
label var CTTR_risks "Lexical Diversity"
label var d_legalese_text "Legalese"
label var d_legalese_risk "Legalese"
label var lognumber_numbers_text "Quantitative Information"
label var lognumber_numbers_risks "Quantitative Information"
label var logcreator_coll_rep_n "Ln(Creator Replies)"
label var logcreator_coll_rep_length "Ln(Creator Replies Length)"
label var creator_involvement "Creator Involvement"

*Table 1 - Panel E: Descriptive statistics
tabstat ///
$variables_for_descriptives ///
, columns(statistics) statistics(n mean sd p10 p25 median p75 p90)

********************************************
* Table 2 - Disclosure and project success *
********************************************

*Table 2 - Panel A: Probability of success
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
xi:logit2 $dep_var logtext_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) nocons replace label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logtext_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Test var = logriskandchal_length
xi:logit2 $dep_var logriskandchal_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) nocons append label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Test vars = logtext_length and logriskandchal_length
xi:logit2 $dep_var logtext_length logriskandchal_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) nocons append label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logtext_length logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)

*Table 2 - Panel B: Amount pledged
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
reghdfe $dep_var logtext_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) replace label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Test var = logriskandchal_length
reghdfe $dep_var logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) append label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Test vars = logtext_length and logriskandchal_length
reghdfe $dep_var logtext_length logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) append label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*********************************************
* Table 3 - The role of consumer protection *
*********************************************

*Table 3 - Panel A: Probability of success
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
gen disclosure=logtext_length
gen post_X_treated=post*treated
gen disclosure_X_post=disclosure*post
gen disclosure_X_treated=disclosure*treated
gen disclosure_X_post_X_treated=disclosure*post*treated
label var disclosure "Disclosure"
label var treated "Treated"
label var post "Post"
label var post_X_treated "Post x Treated"
label var disclosure_X_post "Disclosure x Post"
label var disclosure_X_treated "Disclosure x Treated"
label var disclosure_X_post_X_treated "Disclosure x Post x Treated"
xi:logit2 $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) nocons replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
xi:logit2 $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) nocons append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)

*Table 3 - Panel B: Amount pledged
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
**************************************************************************
* Table 4 - Mitigating the influence of state-level time-varying factors *
**************************************************************************

*Table 4 - Panel A: Short event windows
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 4 - Panel B: Border county analysis
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)

*Table 4 - Panel C: Fixed effects analysis
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)

*****************************************************
* Table 5 - Consumer protection and project backers *
*****************************************************

*Table 5 - Panel A: Number of backers
*Dep var = logbackers_n
global dep_var logbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_A.xls, ctitle("Dependent variable: Ln(Backer)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logbackers_n
global dep_var logbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_A.xls, ctitle("Dependent variable: Ln(Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
*Table 5 - Panel B: Type of backers
*Dep var = lognewbackers_n
global dep_var lognewbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(New Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = lognewbackers_n
global dep_var lognewbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(New Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logreturningbackers_n
global dep_var logreturningbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(Returning Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logreturningbackers_n
global dep_var logreturningbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(Returning Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 5 - Panel C: Backer engagement
*Dep var = logparticipantsreplies_length
global dep_var logparticipantsreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Backer Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logparticipantsreplies_length
global dep_var logparticipantsreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Backer Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logsuperbackerreplies_length
global dep_var logsuperbackerreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Superbacker Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logsuperbackerreplies_length
global dep_var logsuperbackerreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Superbacker Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
**************************************
* Table 6 - Cross-sectional analysis *
**************************************

*Table 6 - Panel A: Reward magnitude
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
gen d1_= high_rewards
gen d1_disclosure=d1_*disclosure
gen d1_post_X_treated=d1_*post_X_treated
gen d1_disclosure_X_post=d1_*disclosure_X_post
gen d1_disclosure_X_treated=d1_*disclosure_X_treated
gen d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
gen d1_loggoal_amount_USD=d1_*loggoal_amount_USD
gen d1_logproject_duration=d1_*logproject_duration
gen d1_projectoftheday_d=d1_*projectoftheday_d
gen d1_multiplecreators_d=d1_*multiplecreators_d
gen d1_logrewards_n=d1_*logrewards_n
gen d1_logbio_length_combined=d1_*logbio_length_combined
gen d1_logprojectsbacked_n=d1_*logprojectsbacked_n
gen d1_logfacebook_n=d1_*logfacebook_n
gen d1_logper_capita_gdp=d1_*logper_capita_gdp
gen d1_high_trust=d1_*high_trust
gen d1_md_comphome=d1_*md_comphome
gen d1_HH_state_fdic=d1_*HH_state_fdic
gen d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_= high_rewards
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

*Table 6 - Panel B: Confidence in courts
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
*Split var = high_courts_deal_criminal
drop d1_
gen d1_=high_courts_deal_criminal /* variable replaces dummy */
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
*Split var = high_courts_deal_criminal
drop d1_
gen d1_=high_courts_deal_criminal /* variable replaces dummy */
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

*Table 6 - Panel C: Court caseload
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
drop d1_
gen d1_= busy_courts
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
drop d1_
gen d1_= busy_courts
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

********************************************
* Table 7 - Disclosure and project quality *
********************************************

*Table 7: Disclosure and project quality
global dep_var suspected_fraud
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if successful_d==1 & comments_n>0 & projectscreated_n==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_7.xls, ctitle("Dependent variable: Suspected Fraud") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
global dep_var suspected_fraud
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if successful_d==1 & comments_n>0 & projectscreated_n==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_7.xls, ctitle("Dependent variable: Suspected Fraud") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
***********************************
* Table 8 - Disclosure attributes *
***********************************

*Table 8 - Panel A: Campaign pitch
*Dep var = logtext_length
global dep_var logtext_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Length") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = readability_text
global dep_var readability_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Readibility") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = SentimentGI_text
global dep_var SentimentGI_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Sentiment") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = CTTR_text
global dep_var CTTR_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Lexical Diversity") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = d_legalese_text
global dep_var d_legalese_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Legalese") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = lognumber_numbers_text
global dep_var lognumber_numbers_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Quantitative Information") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 8 - Panel B: Risks and challanges	
*Dep var = logriskandchal_length
global dep_var logriskandchal_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Length") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = readability_risks
global dep_var readability_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Readibility") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = SentimentGI_risks
global dep_var SentimentGI_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Sentiment") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = CTTR_risks
global dep_var CTTR_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Lexical Diversity") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = d_legalese_risk
global dep_var d_legalese_risk
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Legalese") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = lognumber_numbers_risks
global dep_var lognumber_numbers_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Quantitative Information") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
******************************
* Table 9 - Disclosure costs *
******************************

*Table 9 - Panel A: Proprietary costs of disclosure
*Dep var = logtext_length
global dep_var logtext_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
replace d1_= d_novel
replace d1_post_X_treated=d1_*post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Campaign Pitch)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Campaign Pitch)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var post_X_treated $indep_vars ///
d1_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on post_X_treated
test d1_post_X_treated
*Dep var = logriskandchal_length
global dep_var logriskandchal_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
replace d1_= d_novel
replace d1_post_X_treated=d1_*post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Risks and Challanges)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Risks and Challanges)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var post_X_treated $indep_vars ///
d1_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on post_X_treated
test d1_post_X_treated

*Table 9 - Panel B: Direct costs of disclosure
*Dep var = creator_involvement
global dep_var creator_involvement
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Creator Involvement") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = creator_involvement
global dep_var creator_involvement
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Creator Involvement") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_n
global dep_var logcreator_coll_rep_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_n
global dep_var logcreator_coll_rep_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_length
global dep_var logcreator_coll_rep_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies Length)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_length
global dep_var logcreator_coll_rep_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies Length)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Close log file
log close

****************************************************************************************************************************************************
***                                                                     End                                                                      ***
****************************************************************************************************************************************************

****************************************************************************************************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************
***                                                                                                                                              ***
***                                                                                                                                              ***
***                                                                                                                                              ***
*** Article: 		Does Consumer Protection Enhance Disclosure Credibility in Reward Crowdfunding?                                              ***
*** Authors: 		Stefano Cascino, Maria Correia, and Ane Tamayo                                                                               ***
*** Journal:		Journal of Accounting Research                                                                                               ***
***                                                                                                                                              ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.                                                 ***
***                                                                                                                                              ***
***                                                                                                                                              ***
***                                                                                                                                              ***
****************************************************************************************************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************

******************
* STATA settings *
******************

clear all
clear matrix
set more off
set linesize 120
set matsize 11000
set maxvar 32767

*Define project path
local path C:\project_kickstarter\STATA

*Define log file
log using "`path'\log\log_file.log", replace

*Define ado file directory
sysdir set PLUS "`path'\ado\plus"

*Define empirical analyses output directory
cd "`path'\empirical_analysis_output"

*Dataset
use "`path'\data\dset_final.dta", clear

**********************************************
* Table 1 - Sample selection and composition *
**********************************************

*Table 1 - Panel A: Sample selection criteria
drop if end_date==. /*drops 414 obs*/
drop if beg_date==. /*drops 3 obs*/
drop if location_country=="" /*drops 1,772 obs*/
drop if foreign==1 /*drops 75,131 obs*/
drop if location_state=="" /*drops 24 obs*/
drop if goal_amount_USD==0 /*drops 3 obs*/

*Fixed effects
encode Subcategory, generate(num_Subcategory)
encode location_state, generate(num_location_state)
encode border_id, generate(num_border_id)
egen state_county = group(County location_state)

*Create a macro for all success variables
global success_variables ///
successful_d ///
logpledged_amount_USD ///
logbackers_n ///
lognewbackers_n ///
logreturningbackers_n ///
logparticipantsreplies_length ///
logsuperbackerreplies_length

*Create a macro for all project variables
global project_variables ///
loggoal_amount_USD ///
logproject_duration ///
projectoftheday_d  ///
multiplecreators_d ///
logrewards_n

*Create a macro for all creator variables
global creator_variables ///
logbio_length_combined ///
logprojectsbacked_n ///
logfacebook_n

*Create a macro for all macro factor variables
global macro_variables ///
logper_capita_gdp ///
high_trust ///
md_comphome ///
HH_state_fdic ///
mpledged_pct_yearstate

*Create a macro for all disclosure variables
global disclosure_variables ///
logtext_length ///
logriskandchal_length

*Create a macro for all disclosure attribute variables
global disclosure_attribute_variables ///
readability_text ///
readability_risks ///
SentimentGI_text ///
SentimentGI_risks ///
CTTR_text ///
CTTR_risks ///
d_legalese_text ///
d_legalese_risk ///
lognumber_numbers_text ///
lognumber_numbers_risks

*Create a macro for all direct cost of disclosure variables
global disclosure_direct_cost_variables ///
logcreator_coll_rep_n ///
logcreator_coll_rep_length ///
creator_involvement

*Create a macro for all variables for which descriptive statistics are provided
global variables_for_descriptives ///
successful_d ///
pledged_amount_USD ///
backers_n ///
newbackers_n ///
returningbackers_n ///
participantsreplies_length ///
superbackerreplies_length ///
text_length ///
riskandchal_length ///
goal_amount_USD ///
project_duration ///
projectoftheday_d  ///
multiplecreators_d ///
rewards_n ///
bio_length_combined ///
projectsbacked_n ///
facebook_n ///
per_capita_gdp ///
high_trust ///
md_comphome ///
HH_state_fdic ///
mpledged_pct_yearstate

*Create a macro for all continuous variables
global continuous_variables ///
loggoal_amount_USD  ///
logproject_duration ///
logrewards_n  ///
logbio_length_combined ///
logprojectsbacked_n ///
logfacebook_n ///
logpledged_amount_USD ///
logbackers_n ///
lognewbackers_n ///
logreturningbackers_n ///
logparticipantsreplies_length ///
logsuperbackerreplies_length ///
logtext_length ///
logcreator_coll_rep_n ///
logcreator_coll_rep_length ///
creator_involvement ///
logriskandchal_length ///
SentimentGI_text ///
SentimentGI_risks ///
readability_text ///
readability_risks ///
pledged_amount_USD ///
backers_n ///
newbackers_n ///
returningbackers_n ///
participantsreplies_length ///
superbackerreplies_length ///
text_length ///
riskandchal_length ///
goal_amount_USD ///
project_duration ///
rewards_n ///
bio_length_combined ///
projectsbacked_n ///
facebook_n ///
number_numbers_risks ///
number_numbers_text ///
lognumber_numbers_risks ///
lognumber_numbers_text ///
CTTR_text ///
CTTR_risks ///
md_comphome ///
per_capita_gdp ///
logper_capita_gdp ///
mpledged_pct_yearstate ///
HH_state_fdic ///
suspected_fraud

*Winsorize continous variables
winsor2 $continuous_variables, cuts(1 99) replace

*Table 1 - Panel B: Projects by year
tab beg_year

*Table 1 - Panel C: Projects by category
tab Category

*Table 1 - Panel D: Projects by size
tab projectsize

*Label variables
label var successful_d "Funded"
label var logpledged_amount_USD "Ln(Pledged)"
label var logbackers_n "Ln(Backers)"
label var lognewbackers_n "Ln(New Backers)"
label var logreturningbackers_n "Ln(Returning Backers)"
label var logparticipantsreplies_length "Ln(Backer Comments) "
label var logsuperbackerreplies_length "Ln(Superbacker Comments)"
label var loggoal_amount_USD "Ln(Goal)"
label var logproject_duration "Ln(Duration)"
label var projectoftheday_d  "Project of the Day"
label var multiplecreators_d "Multiple Creators"
label var logrewards_n "Ln(Rewards)"
label var logbio_length_combined "Ln(Bio Length)"
label var logprojectsbacked_n "Ln(Projects Backed)"
label var logfacebook_n "Ln(Facebook Friends)"
label var logper_capita_gdp "Ln(GDP)"
label var high_trust "Trust"
label var md_comphome "Internet Access"
label var HH_state_fdic "Credit Constraints"
label var mpledged_pct_yearstate "Funding Performance"
label var logtext_length "Ln(Campaign Pitch)"
label var logriskandchal_length "Ln(Risks and Challenges)"
label var readability_text "Readibility"
label var readability_risks "Readibility"
label var SentimentGI_text "Sentiment"
label var SentimentGI_risks "Sentiment"
label var CTTR_text "Lexical Diversity"
label var CTTR_risks "Lexical Diversity"
label var d_legalese_text "Legalese"
label var d_legalese_risk "Legalese"
label var lognumber_numbers_text "Quantitative Information"
label var lognumber_numbers_risks "Quantitative Information"
label var logcreator_coll_rep_n "Ln(Creator Replies)"
label var logcreator_coll_rep_length "Ln(Creator Replies Length)"
label var creator_involvement "Creator Involvement"

*Table 1 - Panel E: Descriptive statistics
tabstat ///
$variables_for_descriptives ///
, columns(statistics) statistics(n mean sd p10 p25 median p75 p90)

********************************************
* Table 2 - Disclosure and project success *
********************************************

*Table 2 - Panel A: Probability of success
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
xi:logit2 $dep_var logtext_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) nocons replace label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logtext_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Test var = logriskandchal_length
xi:logit2 $dep_var logriskandchal_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) nocons append label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Test vars = logtext_length and logriskandchal_length
xi:logit2 $dep_var logtext_length logriskandchal_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) nocons append label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logtext_length logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)

*Table 2 - Panel B: Amount pledged
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
reghdfe $dep_var logtext_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) replace label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Test var = logriskandchal_length
reghdfe $dep_var logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) append label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Test vars = logtext_length and logriskandchal_length
reghdfe $dep_var logtext_length logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) append label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*********************************************
* Table 3 - The role of consumer protection *
*********************************************

*Table 3 - Panel A: Probability of success
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
gen disclosure=logtext_length
gen post_X_treated=post*treated
gen disclosure_X_post=disclosure*post
gen disclosure_X_treated=disclosure*treated
gen disclosure_X_post_X_treated=disclosure*post*treated
label var disclosure "Disclosure"
label var treated "Treated"
label var post "Post"
label var post_X_treated "Post x Treated"
label var disclosure_X_post "Disclosure x Post"
label var disclosure_X_treated "Disclosure x Treated"
label var disclosure_X_post_X_treated "Disclosure x Post x Treated"
xi:logit2 $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) nocons replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
xi:logit2 $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) nocons append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)

*Table 3 - Panel B: Amount pledged
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
**************************************************************************
* Table 4 - Mitigating the influence of state-level time-varying factors *
**************************************************************************

*Table 4 - Panel A: Short event windows
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 4 - Panel B: Border county analysis
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)

*Table 4 - Panel C: Fixed effects analysis
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)

*****************************************************
* Table 5 - Consumer protection and project backers *
*****************************************************

*Table 5 - Panel A: Number of backers
*Dep var = logbackers_n
global dep_var logbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_A.xls, ctitle("Dependent variable: Ln(Backer)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logbackers_n
global dep_var logbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_A.xls, ctitle("Dependent variable: Ln(Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
*Table 5 - Panel B: Type of backers
*Dep var = lognewbackers_n
global dep_var lognewbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(New Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = lognewbackers_n
global dep_var lognewbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(New Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logreturningbackers_n
global dep_var logreturningbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(Returning Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logreturningbackers_n
global dep_var logreturningbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(Returning Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 5 - Panel C: Backer engagement
*Dep var = logparticipantsreplies_length
global dep_var logparticipantsreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Backer Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logparticipantsreplies_length
global dep_var logparticipantsreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Backer Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logsuperbackerreplies_length
global dep_var logsuperbackerreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Superbacker Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logsuperbackerreplies_length
global dep_var logsuperbackerreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Superbacker Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
**************************************
* Table 6 - Cross-sectional analysis *
**************************************

*Table 6 - Panel A: Reward magnitude
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
gen d1_= high_rewards
gen d1_disclosure=d1_*disclosure
gen d1_post_X_treated=d1_*post_X_treated
gen d1_disclosure_X_post=d1_*disclosure_X_post
gen d1_disclosure_X_treated=d1_*disclosure_X_treated
gen d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
gen d1_loggoal_amount_USD=d1_*loggoal_amount_USD
gen d1_logproject_duration=d1_*logproject_duration
gen d1_projectoftheday_d=d1_*projectoftheday_d
gen d1_multiplecreators_d=d1_*multiplecreators_d
gen d1_logrewards_n=d1_*logrewards_n
gen d1_logbio_length_combined=d1_*logbio_length_combined
gen d1_logprojectsbacked_n=d1_*logprojectsbacked_n
gen d1_logfacebook_n=d1_*logfacebook_n
gen d1_logper_capita_gdp=d1_*logper_capita_gdp
gen d1_high_trust=d1_*high_trust
gen d1_md_comphome=d1_*md_comphome
gen d1_HH_state_fdic=d1_*HH_state_fdic
gen d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_= high_rewards
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

*Table 6 - Panel B: Confidence in courts
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
*Split var = high_courts_deal_criminal
drop d1_
gen d1_=high_courts_deal_criminal /* variable replaces dummy */
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
*Split var = high_courts_deal_criminal
drop d1_
gen d1_=high_courts_deal_criminal /* variable replaces dummy */
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

*Table 6 - Panel C: Court caseload
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
drop d1_
gen d1_= busy_courts
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
drop d1_
gen d1_= busy_courts
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

********************************************
* Table 7 - Disclosure and project quality *
********************************************

*Table 7: Disclosure and project quality
global dep_var suspected_fraud
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if successful_d==1 & comments_n>0 & projectscreated_n==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_7.xls, ctitle("Dependent variable: Suspected Fraud") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
global dep_var suspected_fraud
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if successful_d==1 & comments_n>0 & projectscreated_n==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_7.xls, ctitle("Dependent variable: Suspected Fraud") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
***********************************
* Table 8 - Disclosure attributes *
***********************************

*Table 8 - Panel A: Campaign pitch
*Dep var = logtext_length
global dep_var logtext_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Length") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = readability_text
global dep_var readability_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Readibility") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = SentimentGI_text
global dep_var SentimentGI_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Sentiment") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = CTTR_text
global dep_var CTTR_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Lexical Diversity") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = d_legalese_text
global dep_var d_legalese_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Legalese") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = lognumber_numbers_text
global dep_var lognumber_numbers_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Quantitative Information") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 8 - Panel B: Risks and challanges	
*Dep var = logriskandchal_length
global dep_var logriskandchal_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Length") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = readability_risks
global dep_var readability_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Readibility") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = SentimentGI_risks
global dep_var SentimentGI_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Sentiment") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = CTTR_risks
global dep_var CTTR_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Lexical Diversity") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = d_legalese_risk
global dep_var d_legalese_risk
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Legalese") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = lognumber_numbers_risks
global dep_var lognumber_numbers_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Quantitative Information") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
******************************
* Table 9 - Disclosure costs *
******************************

*Table 9 - Panel A: Proprietary costs of disclosure
*Dep var = logtext_length
global dep_var logtext_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
replace d1_= d_novel
replace d1_post_X_treated=d1_*post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Campaign Pitch)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Campaign Pitch)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var post_X_treated $indep_vars ///
d1_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on post_X_treated
test d1_post_X_treated
*Dep var = logriskandchal_length
global dep_var logriskandchal_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
replace d1_= d_novel
replace d1_post_X_treated=d1_*post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Risks and Challanges)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Risks and Challanges)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var post_X_treated $indep_vars ///
d1_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on post_X_treated
test d1_post_X_treated

*Table 9 - Panel B: Direct costs of disclosure
*Dep var = creator_involvement
global dep_var creator_involvement
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Creator Involvement") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = creator_involvement
global dep_var creator_involvement
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Creator Involvement") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_n
global dep_var logcreator_coll_rep_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_n
global dep_var logcreator_coll_rep_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_length
global dep_var logcreator_coll_rep_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies Length)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_length
global dep_var logcreator_coll_rep_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies Length)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Close log file
log close

****************************************************************************************************************************************************
***                                                                     End                                                                      ***
****************************************************************************************************************************************************

****************************************************************************************************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************
***                                                                                                                                              ***
***                                                                                                                                              ***
***                                                                                                                                              ***
*** Article: 		Does Consumer Protection Enhance Disclosure Credibility in Reward Crowdfunding?                                              ***
*** Authors: 		Stefano Cascino, Maria Correia, and Ane Tamayo                                                                               ***
*** Journal:		Journal of Accounting Research                                                                                               ***
***                                                                                                                                              ***
*** Description:	This Stata code performs the main empirical analyses presented in the paper.                                                 ***
***                                                                                                                                              ***
***                                                                                                                                              ***
***                                                                                                                                              ***
****************************************************************************************************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************

******************
* STATA settings *
******************

clear all
clear matrix
set more off
set linesize 120
set matsize 11000
set maxvar 32767

*Define project path
local path C:\project_kickstarter\STATA

*Define log file
log using "`path'\log\log_file.log", replace

*Define ado file directory
sysdir set PLUS "`path'\ado\plus"

*Define empirical analyses output directory
cd "`path'\empirical_analysis_output"

*Dataset
use "`path'\data\dset_final.dta", clear

**********************************************
* Table 1 - Sample selection and composition *
**********************************************

*Table 1 - Panel A: Sample selection criteria
drop if end_date==. /*drops 414 obs*/
drop if beg_date==. /*drops 3 obs*/
drop if location_country=="" /*drops 1,772 obs*/
drop if foreign==1 /*drops 75,131 obs*/
drop if location_state=="" /*drops 24 obs*/
drop if goal_amount_USD==0 /*drops 3 obs*/

*Fixed effects
encode Subcategory, generate(num_Subcategory)
encode location_state, generate(num_location_state)
encode border_id, generate(num_border_id)
egen state_county = group(County location_state)

*Create a macro for all success variables
global success_variables ///
successful_d ///
logpledged_amount_USD ///
logbackers_n ///
lognewbackers_n ///
logreturningbackers_n ///
logparticipantsreplies_length ///
logsuperbackerreplies_length

*Create a macro for all project variables
global project_variables ///
loggoal_amount_USD ///
logproject_duration ///
projectoftheday_d  ///
multiplecreators_d ///
logrewards_n

*Create a macro for all creator variables
global creator_variables ///
logbio_length_combined ///
logprojectsbacked_n ///
logfacebook_n

*Create a macro for all macro factor variables
global macro_variables ///
logper_capita_gdp ///
high_trust ///
md_comphome ///
HH_state_fdic ///
mpledged_pct_yearstate

*Create a macro for all disclosure variables
global disclosure_variables ///
logtext_length ///
logriskandchal_length

*Create a macro for all disclosure attribute variables
global disclosure_attribute_variables ///
readability_text ///
readability_risks ///
SentimentGI_text ///
SentimentGI_risks ///
CTTR_text ///
CTTR_risks ///
d_legalese_text ///
d_legalese_risk ///
lognumber_numbers_text ///
lognumber_numbers_risks

*Create a macro for all direct cost of disclosure variables
global disclosure_direct_cost_variables ///
logcreator_coll_rep_n ///
logcreator_coll_rep_length ///
creator_involvement

*Create a macro for all variables for which descriptive statistics are provided
global variables_for_descriptives ///
successful_d ///
pledged_amount_USD ///
backers_n ///
newbackers_n ///
returningbackers_n ///
participantsreplies_length ///
superbackerreplies_length ///
text_length ///
riskandchal_length ///
goal_amount_USD ///
project_duration ///
projectoftheday_d  ///
multiplecreators_d ///
rewards_n ///
bio_length_combined ///
projectsbacked_n ///
facebook_n ///
per_capita_gdp ///
high_trust ///
md_comphome ///
HH_state_fdic ///
mpledged_pct_yearstate

*Create a macro for all continuous variables
global continuous_variables ///
loggoal_amount_USD  ///
logproject_duration ///
logrewards_n  ///
logbio_length_combined ///
logprojectsbacked_n ///
logfacebook_n ///
logpledged_amount_USD ///
logbackers_n ///
lognewbackers_n ///
logreturningbackers_n ///
logparticipantsreplies_length ///
logsuperbackerreplies_length ///
logtext_length ///
logcreator_coll_rep_n ///
logcreator_coll_rep_length ///
creator_involvement ///
logriskandchal_length ///
SentimentGI_text ///
SentimentGI_risks ///
readability_text ///
readability_risks ///
pledged_amount_USD ///
backers_n ///
newbackers_n ///
returningbackers_n ///
participantsreplies_length ///
superbackerreplies_length ///
text_length ///
riskandchal_length ///
goal_amount_USD ///
project_duration ///
rewards_n ///
bio_length_combined ///
projectsbacked_n ///
facebook_n ///
number_numbers_risks ///
number_numbers_text ///
lognumber_numbers_risks ///
lognumber_numbers_text ///
CTTR_text ///
CTTR_risks ///
md_comphome ///
per_capita_gdp ///
logper_capita_gdp ///
mpledged_pct_yearstate ///
HH_state_fdic ///
suspected_fraud

*Winsorize continous variables
winsor2 $continuous_variables, cuts(1 99) replace

*Table 1 - Panel B: Projects by year
tab beg_year

*Table 1 - Panel C: Projects by category
tab Category

*Table 1 - Panel D: Projects by size
tab projectsize

*Label variables
label var successful_d "Funded"
label var logpledged_amount_USD "Ln(Pledged)"
label var logbackers_n "Ln(Backers)"
label var lognewbackers_n "Ln(New Backers)"
label var logreturningbackers_n "Ln(Returning Backers)"
label var logparticipantsreplies_length "Ln(Backer Comments) "
label var logsuperbackerreplies_length "Ln(Superbacker Comments)"
label var loggoal_amount_USD "Ln(Goal)"
label var logproject_duration "Ln(Duration)"
label var projectoftheday_d  "Project of the Day"
label var multiplecreators_d "Multiple Creators"
label var logrewards_n "Ln(Rewards)"
label var logbio_length_combined "Ln(Bio Length)"
label var logprojectsbacked_n "Ln(Projects Backed)"
label var logfacebook_n "Ln(Facebook Friends)"
label var logper_capita_gdp "Ln(GDP)"
label var high_trust "Trust"
label var md_comphome "Internet Access"
label var HH_state_fdic "Credit Constraints"
label var mpledged_pct_yearstate "Funding Performance"
label var logtext_length "Ln(Campaign Pitch)"
label var logriskandchal_length "Ln(Risks and Challenges)"
label var readability_text "Readibility"
label var readability_risks "Readibility"
label var SentimentGI_text "Sentiment"
label var SentimentGI_risks "Sentiment"
label var CTTR_text "Lexical Diversity"
label var CTTR_risks "Lexical Diversity"
label var d_legalese_text "Legalese"
label var d_legalese_risk "Legalese"
label var lognumber_numbers_text "Quantitative Information"
label var lognumber_numbers_risks "Quantitative Information"
label var logcreator_coll_rep_n "Ln(Creator Replies)"
label var logcreator_coll_rep_length "Ln(Creator Replies Length)"
label var creator_involvement "Creator Involvement"

*Table 1 - Panel E: Descriptive statistics
tabstat ///
$variables_for_descriptives ///
, columns(statistics) statistics(n mean sd p10 p25 median p75 p90)

********************************************
* Table 2 - Disclosure and project success *
********************************************

*Table 2 - Panel A: Probability of success
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
xi:logit2 $dep_var logtext_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) nocons replace label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logtext_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Test var = logriskandchal_length
xi:logit2 $dep_var logriskandchal_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) nocons append label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Test vars = logtext_length and logriskandchal_length
xi:logit2 $dep_var logtext_length logriskandchal_length $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) nocons append label ///
	addtext (Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var logtext_length logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) append label ///
	addtext (Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)

*Table 2 - Panel B: Amount pledged
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
reghdfe $dep_var logtext_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length $indep_vars) replace label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Test var = logriskandchal_length
reghdfe $dep_var logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logriskandchal_length $indep_vars) append label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Test vars = logtext_length and logriskandchal_length
reghdfe $dep_var logtext_length logriskandchal_length $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_2_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(logtext_length logriskandchal_length $indep_vars) append label ///
	addtext (State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*********************************************
* Table 3 - The role of consumer protection *
*********************************************

*Table 3 - Panel A: Probability of success
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
gen disclosure=logtext_length
gen post_X_treated=post*treated
gen disclosure_X_post=disclosure*post
gen disclosure_X_treated=disclosure*treated
gen disclosure_X_post_X_treated=disclosure*post*treated
label var disclosure "Disclosure"
label var treated "Treated"
label var post "Post"
label var post_X_treated "Post x Treated"
label var disclosure_X_post "Disclosure x Post"
label var disclosure_X_treated "Disclosure x Treated"
label var disclosure_X_post_X_treated "Disclosure x Post x Treated"
xi:logit2 $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) nocons replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
xi:logit2 $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars i.num_Subcategory i.num_location_state i.beg_year_month, fcluster(num_location_state) tcluster(beg_year_month)
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) nocons append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, State fixed effects, Yes, Year-month fixed effects, Yes, Subcategory x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, No, State fixed effects, Yes, Year-month fixed effects, No, Subcategory x Year-month fixed effects, Yes)

*Table 3 - Panel B: Amount pledged
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_3_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
**************************************************************************
* Table 4 - Mitigating the influence of state-level time-varying factors *
**************************************************************************

*Table 4 - Panel A: Short event windows
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,09,2013) & beg_date<td(20,09,2015)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if (beg_date>=td(20,03,2012) & beg_date<td(15,07,2017)), absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 4 - Panel B: Border county analysis
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, Yes, Border x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory  state_county num_border_id#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, Subcategory fixed effects, Yes, County fixed effects, Yes, Year-month fixed effects, No, Border x Year-month fixed effects, Yes)

*Table 4 - Panel C: Fixed effects analysis
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, Yes, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, Yes, State x Year-month fixed effects, Yes, Subcategory x State x Year-month fixed effects, No)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#num_location_state#beg_year_month) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_4_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Subcategory fixed effects, No, Subcategory x Year-month fixed effects, No, State x Year-month fixed effects, No, Subcategory x State x Year-month fixed effects, Yes)

*****************************************************
* Table 5 - Consumer protection and project backers *
*****************************************************

*Table 5 - Panel A: Number of backers
*Dep var = logbackers_n
global dep_var logbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_A.xls, ctitle("Dependent variable: Ln(Backer)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logbackers_n
global dep_var logbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_A.xls, ctitle("Dependent variable: Ln(Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
*Table 5 - Panel B: Type of backers
*Dep var = lognewbackers_n
global dep_var lognewbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(New Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = lognewbackers_n
global dep_var lognewbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(New Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logreturningbackers_n
global dep_var logreturningbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(Returning Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logreturningbackers_n
global dep_var logreturningbackers_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_B.xls, ctitle("Dependent variable: Ln(Returning Backers)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 5 - Panel C: Backer engagement
*Dep var = logparticipantsreplies_length
global dep_var logparticipantsreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Backer Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logparticipantsreplies_length
global dep_var logparticipantsreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Backer Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logsuperbackerreplies_length
global dep_var logsuperbackerreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Superbacker Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logsuperbackerreplies_length
global dep_var logsuperbackerreplies_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_5_Panel_C.xls, ctitle("Dependent variable: Ln(Superbacker Comments)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
**************************************
* Table 6 - Cross-sectional analysis *
**************************************

*Table 6 - Panel A: Reward magnitude
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
gen d1_= high_rewards
gen d1_disclosure=d1_*disclosure
gen d1_post_X_treated=d1_*post_X_treated
gen d1_disclosure_X_post=d1_*disclosure_X_post
gen d1_disclosure_X_treated=d1_*disclosure_X_treated
gen d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
gen d1_loggoal_amount_USD=d1_*loggoal_amount_USD
gen d1_logproject_duration=d1_*logproject_duration
gen d1_projectoftheday_d=d1_*projectoftheday_d
gen d1_multiplecreators_d=d1_*multiplecreators_d
gen d1_logrewards_n=d1_*logrewards_n
gen d1_logbio_length_combined=d1_*logbio_length_combined
gen d1_logprojectsbacked_n=d1_*logprojectsbacked_n
gen d1_logfacebook_n=d1_*logfacebook_n
gen d1_logper_capita_gdp=d1_*logper_capita_gdp
gen d1_high_trust=d1_*high_trust
gen d1_md_comphome=d1_*md_comphome
gen d1_HH_state_fdic=d1_*HH_state_fdic
gen d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_= high_rewards
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = high_rewards
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_A.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

*Table 6 - Panel B: Confidence in courts
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
*Split var = high_courts_deal_criminal
drop d1_
gen d1_=high_courts_deal_criminal /* variable replaces dummy */
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
*Split var = high_courts_deal_criminal
drop d1_
gen d1_=high_courts_deal_criminal /* variable replaces dummy */
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = confidence_in_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_B.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

*Table 6 - Panel C: Court caseload
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
drop d1_
gen d1_= busy_courts
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = successful_d
global dep_var successful_d
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Funded") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
drop d1_
gen d1_= busy_courts
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated
*Dep var = logpledged_amount_USD
global dep_var logpledged_amount_USD
global indep_vars $project_variables $creator_variables $macro_variables
*Split var = busy_courts
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
replace d1_disclosure=d1_*disclosure
replace d1_post_X_treated=d1_*post_X_treated
replace d1_disclosure_X_post=d1_*disclosure_X_post
replace d1_disclosure_X_treated=d1_*disclosure_X_treated
replace d1_disclosure_X_post_X_treated=d1_*disclosure_X_post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_6_Panel_C.xls, ctitle("Dependent variable: Ln(Pledged)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars ///
d1_disclosure  ///
d1_post_X_treated ///
d1_disclosure_X_post ///
d1_disclosure_X_treated ///
d1_disclosure_X_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on disclosure_X_post_X_treated
test d1_disclosure_X_post_X_treated

********************************************
* Table 7 - Disclosure and project quality *
********************************************

*Table 7: Disclosure and project quality
global dep_var suspected_fraud
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if successful_d==1 & comments_n>0 & projectscreated_n==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_7.xls, ctitle("Dependent variable: Suspected Fraud") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
global dep_var suspected_fraud
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars if successful_d==1 & comments_n>0 & projectscreated_n==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_7.xls, ctitle("Dependent variable: Suspected Fraud") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
***********************************
* Table 8 - Disclosure attributes *
***********************************

*Table 8 - Panel A: Campaign pitch
*Dep var = logtext_length
global dep_var logtext_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Length") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = readability_text
global dep_var readability_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Readibility") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = SentimentGI_text
global dep_var SentimentGI_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Sentiment") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = CTTR_text
global dep_var CTTR_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Lexical Diversity") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = d_legalese_text
global dep_var d_legalese_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Legalese") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = lognumber_numbers_text
global dep_var lognumber_numbers_text
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_A.xls, ctitle("Dependent variable: Quantitative Information") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Table 8 - Panel B: Risks and challanges	
*Dep var = logriskandchal_length
global dep_var logriskandchal_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Length") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = readability_risks
global dep_var readability_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Readibility") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = SentimentGI_risks
global dep_var SentimentGI_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Sentiment") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)	
*Dep var = CTTR_risks
global dep_var CTTR_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Lexical Diversity") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = d_legalese_risk
global dep_var d_legalese_risk
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Legalese") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = lognumber_numbers_risks
global dep_var lognumber_numbers_risks
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
reghdfe $dep_var post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_8_Panel_B.xls, ctitle("Dependent variable: Quantitative Information") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
	
******************************
* Table 9 - Disclosure costs *
******************************

*Table 9 - Panel A: Proprietary costs of disclosure
*Dep var = logtext_length
global dep_var logtext_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
replace d1_= d_novel
replace d1_post_X_treated=d1_*post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Campaign Pitch)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Campaign Pitch)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var post_X_treated $indep_vars ///
d1_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on post_X_treated
test d1_post_X_treated
*Dep var = logriskandchal_length
global dep_var logriskandchal_length
global indep_vars $project_variables $creator_variables $macro_variables
replace post_X_treated=post*treated
replace d1_= d_novel
replace d1_post_X_treated=d1_*post_X_treated
replace d1_loggoal_amount_USD=d1_*loggoal_amount_USD
replace d1_logproject_duration=d1_*logproject_duration
replace d1_projectoftheday_d=d1_*projectoftheday_d
replace d1_multiplecreators_d=d1_*multiplecreators_d
replace d1_logrewards_n=d1_*logrewards_n
replace d1_logbio_length_combined=d1_*logbio_length_combined
replace d1_logprojectsbacked_n=d1_*logprojectsbacked_n
replace d1_logfacebook_n=d1_*logfacebook_n
replace d1_logper_capita_gdp=d1_*logper_capita_gdp
replace d1_high_trust=d1_*high_trust
replace d1_md_comphome=d1_*md_comphome
replace d1_HH_state_fdic=d1_*HH_state_fdic
replace d1_mpledged_pct_yearstate=d1_*mpledged_pct_yearstate
reghdfe $dep_var post_X_treated $indep_vars if d1_==0, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Risks and Challanges)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
reghdfe $dep_var post_X_treated $indep_vars if d1_==1, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_A.xls, ctitle("Dependent variable: Ln(Risks and Challanges)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*X-Sq test for difference in coefficients (based on fully interacted model)
reghdfe $dep_var post_X_treated $indep_vars ///
d1_post_X_treated ///
d1_loggoal_amount_USD ///
d1_logproject_duration ///
d1_projectoftheday_d ///
d1_multiplecreators_d ///
d1_logrewards_n ///
d1_logbio_length_combined ///
d1_logprojectsbacked_n ///
d1_logfacebook_n ///
d1_logper_capita_gdp ///
d1_high_trust ///
d1_md_comphome ///
d1_HH_state_fdic ///
d1_mpledged_pct_yearstate ///
, absorb(num_Subcategory#beg_year_month#d1_ num_location_state#d1_) vce(cluster num_location_state beg_year_month) keepsingletons
*X-Sq test on post_X_treated
test d1_post_X_treated

*Table 9 - Panel B: Direct costs of disclosure
*Dep var = creator_involvement
global dep_var creator_involvement
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Creator Involvement") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) replace label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = creator_involvement
global dep_var creator_involvement
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Creator Involvement") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_n
global dep_var logcreator_coll_rep_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_n
global dep_var logcreator_coll_rep_n
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_length
global dep_var logcreator_coll_rep_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logtext_length
replace disclosure=logtext_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies Length)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)
*Dep var = logcreator_coll_rep_length
global dep_var logcreator_coll_rep_length
global indep_vars $project_variables $creator_variables $macro_variables
*Test var = logriskandchal_length
replace disclosure=logriskandchal_length
replace post_X_treated=post*treated
replace disclosure_X_post=disclosure*post
replace disclosure_X_treated=disclosure*treated
replace disclosure_X_post_X_treated=disclosure*post*treated
reghdfe $dep_var disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated $indep_vars, absorb(num_Subcategory#beg_year_month num_location_state) vce(cluster num_location_state beg_year_month) keepsingletons
	outreg2 using Table_9_Panel_B.xls, ctitle("Dependent variable: Ln(Creator Replies Length)") excel bdec(3) tdec(2) symbol(***,**,*) tstat keep(disclosure post_X_treated disclosure_X_post disclosure_X_treated disclosure_X_post_X_treated) append label ///
	addtext (Project controls, Yes, Creator controls, Yes, Macro controls, Yes, State fixed effects, Yes, Subcategory x Year-month fixed effects, Yes)

*Close log file
log close

****************************************************************************************************************************************************
***                                                                     End                                                                      ***
****************************************************************************************************************************************************

