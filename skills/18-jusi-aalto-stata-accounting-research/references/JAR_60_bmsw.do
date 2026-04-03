*LOAD DATA *********************************************************************


*change to the directory this do file lives in
//you have to manually change to this directory, it won't do it automatically.


//Eric Desktop
cd  "D:\Dropbox\IBES project 2\Code"

//Eric KU Laptop
cd "C:\Users\e679w418\Dropbox\IBES project 2\Code"

//For Musa
cd "C:\Users\msubasi\Dropbox\IBES project 2\Code"


// KB
cd "D:\Dropbox\IBES project 2\Code"


clear
set more off

macro drop _all

*use relative path from the code folder to the data folder

*load raw data
use "..\Data\main_sample_2021.dta", clear


//log variables that need logging
replace all_count = 0 if missing(all_count)
gen ln_media_coverage = ln(1+all_count)
gen ln_lagmins = ln(1 + pr_lagmins)


gen ln_size = ln(size)
gen ln_analyst_following = ln(1+analyst_following)
gen ln_advertising = ln(1+advertising_expense)
gen ln_firmage = ln(1+firm_age)

drop if reporting_lag < 1
gen ln_reporting_lag = ln(reporting_lag)

gen ln_unactivated_actuals = ln(1+ unact_ea)
 
//other transformations
gen abs_surprise = abs(surprise_con)

//check st earnings sample sizes
egen stmis=rmiss2 ( f_st_earnings f_cfo st_earnings)
replace f_st_earnings  = . if stmis != 0
replace f_cfo  = . if stmis != 0
replace st_earnings = . if stmis != 0


//winsorize intraday analyses variables to a 1-day timeframe

replace act_tmin_delay = 960 if act_tmin_delay > 960
replace aly_tmin_delay = 960 if aly_tmin_delay > 960
replace aly_tmin_delay = 960 if missing(aly_tmin_delay)
replace wmrt = -2.5 if missing(wmrt)

//log trading delays
gen ln_act_tmin_delay = ln(1+act_tmin_delay)
gen ln_aly_tmin_delay = ln(1+aly_tmin_delay)


*define controls
global controls abs_gaap_st_diff abs_surprise bnews guidance qtr4 ///
ln_reporting_lag  ///
ln_size ln_firmage io ln_analyst_following  sp500 ///
ln_advertising ln_unactivated_actuals friday ///
log_allwords hardinfomix nongaap_scaled ln_media_coverage 


//drop any missing controls
egen miss_control = rmiss2 ( $controls)
drop if miss_control > 0

//drop qtrs pre-2004 SEC regulation change because few/no 8-Ks
drop if yearqtr <= mdy(12,31,2004) 


// align samples for analyst tests


gen analyst_delay = aly_tmin_delay

replace analyst_delay=. if missing(dispersion_act_w)
replace analyst_delay=. if missing(mafe_act_w)
replace analyst_delay=. if n_fpi6_fcasts_5day < 3
replace dispersion_act_w=. if n_fpi6_fcasts_5day < 3
replace mafe_act_w = . if missing(dispersion_act_w)
replace mafe_act_w = . if n_fpi6_fcasts_5day < 3


gen ln_analyst_delay = ln(1 + analyst_delay)


//generate post_treatment interactions
gen post_treatment = post*treatment
gen post_st_earnings = post*st_earnings
gen treatment_st_earnings = treatment*st_earnings
gen post_treatment_st_earnings = post*treatment*st_earnings


*identify singleton observations
//table 3 singletons
reghdfe ln_lagmins post treatment post_treatment $controls ///
,absorb(permno yearqtr pr_hr) cluster(permno pr_date)

drop if e(sample)==0

//table 4 singletons
reghdfe f_st_earnings treatment post_treatment st_earnings ///
post_st_earnings treatment_st_earnings post_treatment_st_earnings ///
$controls , absorb(permno yearqtr pr_hr) cluster(permno pr_date)

replace f_st_earnings  = . if e(sample) == 0
replace f_cfo  = . if e(sample)==0
replace st_earnings = . if e(sample)==0

//Table 5, col 1
reghdfe diff post treatment post_treatment ///
$controls if !missing(dispersion_act_w) & n_fpi6_fcasts_5day > 2 ///
, absorb(permno yearqtr pr_hr) cluster(permno pr_date)

replace diff = . if e(sample)==0

//Table 5, col 2
reghdfe ln_aly_tmin_delay post treatment post_treatment ///
$controls if !missing(dispersion_act_w) & n_fpi6_fcasts_5day > 2 ///
, absorb(permno yearqtr pr_hr) cluster(permno pr_date)

replace analyst_delay =. if e(sample) == 0
replace ln_analyst_delay =. if e(sample) == 0
replace dispersion_act_w=. if e(sample) == 0
replace mafe_act_w = . if e(sample) == 0

/* WINSORIZE VARIABLES */
winsor2 ln_size ln_analyst_following ln_firmage abs_gaap_st_diff mafe_act_w dispersion_act_w st_earnings f_st_earnings  f_cfo abs_surprise ln_reporting_lag log_allwords hardinfomix nongaap_scaled ln_media_coverage ln_unactivated_actuals ln_advertising ln_analyst_delay ln_aly_tmin_delay ln_act_tmin_delay onetimeitems_scaled, replace

//after winsorizing, we need to
//replace post_treatment interactions with winsorized st earnings
replace post_st_earnings = post*st_earnings
replace treatment_st_earnings = treatment*st_earnings
replace post_treatment_st_earnings = post*treatment*st_earnings




//Alternate treatment for internet appendix
sum onetimeitems_scaled, d

gen treatment2=(onetimeitems_scaled> r(p50)) // text-based treatment

gen post_treatment2 = post*treatment2

gen treatment2_st_earnings = treatment2*st_earnings

gen post_treatment2_st_earnings = post*treatment2*st_earnings



//Label variables

label var pr_lagmins "\emph{Activation Delay}"
label var ln_lagmins "\emph{Ln(Activation Delay)}"
label var post "\emph{Post}"
label var treatment "\emph{Treatment}"
label var post_treatment "\emph{Post} $\times$ \emph{Treatment}"

label var f_st_earnings "\emph{Future Street Earnings}"
label var f_cfo "\emph{Future Cash Flows}"
label var st_earnings "\emph{Street Earnings}"
label var post_st_earnings "\emph{Street Earnings} $\times$ \emph{Post}"
label var treatment_st_earnings "\emph{Street Earnings} $\times$ \emph{Treatment}"
label var post_treatment_st_earnings "\emph{Street Earnings} $\times$ \emph{Post} $\times$ \emph{Treatment}"

label var diff "\emph{DIFF}"
label var analyst_delay"\emph{Forecasting Delay}"
label var ln_analyst_delay"\emph{Ln(Forecasting Delay)}"
label var mafe_act_w "\emph{mafe_act_w}"
label var dispersion_act_w "\emph{dispersion_act_w}"

label var abs_gaap_st_diff "\emph{Abs(GAAP-Street)}"
label var abs_surprise "\emph{Abs(Surprise)}"
label var bnews "\emph{Bad News}"
label var guidance "\emph{EPS Guidance}"
label var qtr4 "\emph{QTR4}"
label var ln_reporting_lag "\emph{Reporting Lag}"
label var ln_size "\emph{Size}"
label var ln_firmage "\emph{Firm Age}"
label var io "\emph{Institutional Ownership}"
label var ln_analyst_following "\emph{Analyst Following}"
label var sp500 "\emph{S\&P 500}"

label var ln_advertising "\emph{Advertising}"
label var ln_unactivated_actuals "\emph{Unactivated Actuals}"
label var friday "\emph{Friday}"

label var log_allwords "\emph{Press Release Words}"
label var nongaap_scaled "\emph{Non-GAAP Words}"
label var hardinfomix "\emph{HardInfoMix}"
label var ln_media_coverage "\emph{Media Coverage}"
label var wmrt "\emph{MRT}"

//financial crisis dates for internet appendix 
gen crisis2 = pr_date> td(01jul2007) & pr_date< td(30mar2009)

save "..\Data\wins_sample_2021.dta", replace


*change to the directory this do file lives in
//you have to manually change to this directory, it won't do it automatically.


//Eric Desktop
cd  "D:\Dropbox\IBES project 2\Code"

//Eric KU Laptop
cd "C:\Users\e679w418\Dropbox\IBES project 2\Code"

//For Musa
cd "C:\Users\msubasi\Dropbox\IBES project 2\Code"


// KB
cd "D:\Dropbox\IBES project 2\Code"



// Analyst Wins Sample *********************************************************


clear
set more off

macro drop _all


use "..\Data\analyst_level_sample.dta", clear 

//generate the ana_first variable
gen ana_first = 1 if  analyst_cmin_delay < pr_lagmins
replace ana_first = 0 if  analyst_cmin_delay > pr_lagmins

//winsorize the continuous variables 
winsor2 gexp fexp analysts_employed mean_abs_fcast_error_act_w abs_fcast_error_prc abs_fcast_error_act_w n_ea_covered_5d, by(yearqtr) replace



//generate analyst-level variables
gen ln_analysts_employed=ln(analysts_employed)
gen ln_gexp=ln(gexp)
gen ln_fexp=ln(fexp)
gen ln_ea_covered_5d = ln(1+n_ea_covered_5d)
gen accuracy=-1* mean_abs_fcast_error_act_w


save "..\Data\wins_analyst_sample_2021.dta", replace