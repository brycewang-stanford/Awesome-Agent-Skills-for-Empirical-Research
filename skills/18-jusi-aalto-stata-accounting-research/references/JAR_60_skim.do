
/*Tables 2 - 3*/ 
**Import ZIP-Year data
clear
use "C:\Dropbox\Securitization\Submission\JAR - Final\delr_zip_r.dta", clear

**Standardize the Exposure measure
egen ms_h_pre_std=std(ms_h_pre)

**Create various fixed effects
egen cdummy = group(fips_code)
egen zdummy = group(zcta5)
egen sdummy = group(state)
egen ydummy = group(year)
egen cydummy = group(fips_code year)

**Create Crisis, Exposure*Crisis, and Exposure High*Crisis variables
gen post=0
replace post=1 if year>=2007

gen treat=ms_h_pre_std*post
gen treat2=delr_r_h*post

**Designate control variables
global xlist lag_tieronecap_zip g_emp g_est g_gross_income ln_avg_income hhi nonbank_share d_amt_zip_nonbank 
global census ln_pop black_population_pct hispanic_population_pct poverty_pct bachelor_higher_pct 
global xlist_zip g_emp g_est g_gross_income ln_avg_income hhi nonbank_share

**Table 2
***Panel A
reghdfe ln_amount_zip treat $xlist [aw=total_population] if year<2010, absorb(cydummy zdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, replace addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe d_amt_zip treat $xlist [aw=total_population] if year<2010, absorb(cydummy zdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe foreclosure_rate treat $xlist [aw=total_population], absorb(cydummy zdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe shortsale_rate treat $xlist [aw=total_population], absorb(cydummy zdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe d_price1 treat $xlist [aw=total_population] if year<2010, absorb(zdummy cydummy) vce(cluster sdummy)
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe d_price2 treat $xlist [aw=total_population] if year<2010, absorb(zdummy cydummy) vce(cluster sdummy)  
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)

***Panel B
reghdfe ln_amount_zip treat2 $xlist [aw=total_population] if year<2010, absorb(cydummy zdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, replace addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe d_amt_zip treat2 $xlist [aw=total_population] if year<2010, absorb(cydummy zdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe foreclosure_rate treat2 $xlist [aw=total_population], absorb(cydummy zdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe shortsale_rate treat2 $xlist [aw=total_population], absorb(cydummy zdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe d_price1 treat2 $xlist [aw=total_population] if year<2010, absorb(zdummy cydummy) vce(cluster sdummy)
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
reghdfe d_price2 treat2 $xlist [aw=total_population] if year<2010, absorb(zdummy cydummy) vce(cluster sdummy)  
outreg2 using myreg.xls, append addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)


*Table 3
gen iv_sec_post=iv_sec_pre*post

reghdfe treat iv_sec_post iv_public $xlist [aw=total_population] if year<2010, absorb(cydummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, replace addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
ivreghdfe d_price1 iv_public $xlist (treat = iv_sec_post) [aw=total_population] if year<2010, absorb(cydummy zdummy) cluster (sdummy)  
outreg2 using myreg.xls, append addstat(Adj. Within R-squared, e(r2_a)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)
ivreghdfe d_price2 iv_public $xlist (treat = iv_sec_post) [aw=total_population] if year<2010, absorb(cydummy zdummy) cluster (sdummy)  
outreg2 using myreg.xls, append addstat(Adj. Within R-squared, e(r2_a)) addtext(County-Year FE, YES, Zip FE, YES) dec(3)

***Partial F-Statistics
test iv_sec_post

/*Table 4*/
**Import the bank-ZIP-Year data
clear
use "C:\Dropbox\Securitization\Submission\JAR - Final\delr_zip_bank.dta", clear

**Create various fixed effects
egen cdummy = group(fips_code)
egen zdummy = group(zcta5)
egen sdummy = group(state)
egen ydummy = group(year)
egen bdummy = group(mergeid)
egen cydummy = group(fips_code year)
egen zydummy = group(zcta5 year)

**Create Crisis, DLR HIgh*Crisis, and control variables

gen post=0
replace post=1 if year>=2007

gen treat=delr_h_bank*post

gen lnat_p = lnat*post
gen cash_p = cash*post 
gen deposit_p = deposit*post
gen lag_tieronecap_p = lag_tieronecap*post 
gen liq_p = liq*post
gen llr_p = llr*post
gen npl_p = npl*post
gen roa_p = roa*post
gen off_bs_rate_p = off_bs_rate*post

**Designate control variables
global xlist lnat cash deposit lag_tieronecap liq llr npl roa off_bs_rate
global xlist_p lnat_p cash_p deposit_p lag_tieronecap_p liq_p llr_p npl_p roa_p off_bs_rate_p
global xlist_zip lag_tieronecap_zip g_emp g_est g_gross_income ln_avg_income hhi nonbank_share d_amt_zip_nonbank
global census ln_pop black_population_pct hispanic_population_pct poverty_pct bachelor_higher_pct 

*Table 4
reg amount_ins_ms treat delr_h_bank post $xlist $xlist_p [aw=total_population], vce(cluster sdummy)  
outreg2 using myreg.xls, replace ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a)) addtext(ZIP-by-Year FE, NO, Bank FE, NO) dec(3)
reghdfe amount_ins_ms treat $xlist $xlist_p [aw=total_population], absorb(zydummy bdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(ZIP-by-Year FE, YES, Bank FE, YES) dec(3)
reghdfe amount_ins_ms treat $xlist $xlist_p [aw=total_population] if lag_tieronecap_h==0, absorb(zydummy bdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(ZIP-by-Year FE, YES, Bank FE, YES) dec(3)
reghdfe amount_ins_ms treat $xlist $xlist_p [aw=total_population] if lag_tieronecap_h==1, absorb(zydummy bdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(ZIP-by-Year FE, YES, Bank FE, YES) dec(3)
reghdfe amount_ins_ms treat $xlist $xlist_p [aw=total_population] if lag_alwn_h==0, absorb(zydummy bdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(ZIP-by-Year FE, YES, Bank FE, YES) dec(3)
reghdfe amount_ins_ms treat $xlist $xlist_p [aw=total_population] if lag_alwn_h==1, absorb(zydummy bdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(ZIP-by-Year FE, YES, Bank FE, YES) dec(3)


/*Table 5*/
*Panel A
**Import the bank-MSA-level data
clear
use "C:\Dropbox\Securitization\Submission\JAR - Final\delr_msa.dta", clear

**Create various fixed effects
egen cdummy = group(fips_code)
egen sdummy = group(state)
egen ydummy = group(year)
egen bdummy = group(mergeid)
egen mdummy = group(msa_code)
egen mydummy = group(msa_code year)

**Create Crisis, DLR HIgh*Crisis, and control variables
gen post=0
replace post=1 if year>=2007

gen treat=delr_h_bank*post

gen lnat_p = lnat*post
gen cash_p = cash*post 
gen deposit_p = deposit*post
gen lag_tieronecap_p = lag_tieronecap*post 
gen liq_p = liq*post
gen llr_p = llr*post
gen npl_p = npl*post
gen roa_p = roa*post
gen off_bs_rate_p = off_bs_rate*post

**Designate control variables
global xlist lnat cash deposit lag_tieronecap liq llr npl roa off_bs_rate
global xlist_p lnat_p cash_p deposit_p lag_tieronecap_p liq_p llr_p npl_p roa_p off_bs_rate_p

**Regressions
reghdfe conven_ins_ms treat $xlist $xlist_p [aw=total_population], absorb(mydummy bdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, replace ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(MSA-Year FE, YES, Firm FE, YES) dec(3)
reghdfe fha_ins_ms treat $xlist $xlist_p [aw=total_population], absorb(mydummy bdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(MSA-Year FE, YES, Firm FE, YES) dec(3)
reghdfe diff_ins_ms treat $xlist $xlist_p [aw=total_population], absorb(mydummy bdummy) vce(cluster sdummy)  
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(MSA-Year FE, YES, Firm FE, YES) dec(3)

*Panel B
**Import the application data
clear
use "C:\Dropbox\Securitization\Submission\JAR - Final\delr_application.dta", clear

**Create various fixed effects
egen sdummy = group(state)
egen cdummy = group(fips_code)
egen zdummy = group(zcta5)
egen ydummy = group(year)
egen bdummy = group(mergeid)
egen racedummy = group(race1)
egen pdummy = group(loanpurpose)

**Create Crisis, DLR HIgh*Crisis, Conventional*DLR HIgh*Crisis, and control variables
gen post=0
replace post=1 if year>=2007

gen treat=delr_h_bank*post
gen treat_con=treat*conventional

gen lnat_p = lnat*post
gen cash_p = cash*post 
gen deposit_p = deposit*post
gen lag_tieronecap_p = lag_tieronecap*post 
gen liq_p = liq*post
gen llr_p = llr*post
gen npl_p = npl*post
gen roa_p = roa*post
gen off_bs_rate_p = off_bs_rate*post

gen male=0
replace male=1 if sex==1
gen ln_pop = log(total_population)

gen ethnicity=0
replace ethnicity=1 if ethnic==1

gen owner_occupancy=0
replace owner_occupancy=1 if occupancy==1

**Designate control variables
global xlist lnat cash deposit lag_tieronecap liq llr npl roa off_bs_rate
global xlist_p lnat_p cash_p deposit_p lag_tieronecap_p liq_p llr_p npl_p roa_p off_bs_rate_p
global xlist_zip g_emp g_est g_gross_income ln_avg_income
global census ln_pop black_population_pct hispanic_population_pct poverty_pct bachelor_higher_pct
global loan lnincome lnamount male loan_to_income ethnicity owner_occupancy jumbo 

*Regressions
reghdfe approve treat_con treat $xlist $xlist_p $loan, ///
absorb(ydummy#zdummy ydummy#conventional bdummy#conventional racedummy pdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, replace ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within))  addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe approve treat_con treat $xlist $xlist_p $loan if jumbo==0, ///
absorb(ydummy#zdummy ydummy#conventional bdummy#conventional racedummy pdummy) vce(cluster sdummy) 
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within))  addtext(Year FE, YES, Firm FE, YES) dec(3)

/*Table 6*/
clear
use "C:\Dropbox\Securitization\Submission\JAR - Final\matched_loan.dta", clear

**Create various fixed effects
egen sdummy = group(state)
egen cdummy = group(fips_code)
egen ydummy = group(year)
egen zdummy = group(zcta5)
egen bdummy = group(mergeid)
egen racedummy = group(race1)

*Create loan-level variables
gen male=0
replace male=1 if sex==1
gen ethnicity=0
replace ethnicity=1 if ethnic==1
gen owner_occupancy=0
replace owner_occupancy=1 if occupancy==1

*Create Exposure High*DLR High variable
gen delr_h_r_bank=delr_h_bank*delr_r_h

*Designate control variables
global xlist lnat cash deposit lag_tieronecap liq llr npl roa off_bs_rate
global xlist_pre lnat_pre cash_pre deposit_pre tieronecap_pre liq_pre llr_pre npl_pre roa_pre 
global xlist_post lnat_post cash_post deposit_post tieronecap_post liq_post llr_post npl_post roa_post 
global loan lnincome lnamount male loan_to_income ethnicity owner_occupancy jumbo conventional sold
global xlist_zip lag_tieronecap_zip g_emp g_est g_gross_income ln_avg_income hhi nonbank_share d_amt_zip_nonbank
global census ln_pop black_population_pct hispanic_population_pct poverty_pct bachelor_higher_pct

*Regressions
reghdfe foreclosure delr_h_r_bank $xlist $loan $xlist_zip, absorb(bdummy ydummy racedummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, replace ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(Year FE, YES, Race FE, YES, Bank FE, YES, ZIP FE, YES) dec(3)
reghdfe shortsale delr_h_r_bank $xlist $loan $xlist_zip, absorb(bdummy ydummy racedummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(Year FE, YES, Race FE, YES, Bank FE, YES, ZIP FE, YES) dec(3)
reghdfe dist_all delr_h_r_bank $xlist $loan $xlist_zip, absorb(bdummy ydummy racedummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(Year FE, YES, Race FE, YES, Bank FE, YES, ZIP FE, YES) dec(3)
reghdfe dist_all delr_h_r_bank $xlist $loan $xlist_zip if conventional==1 & jumbo==0, absorb(bdummy ydummy racedummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(Year FE, YES, Race FE, YES, Bank FE, YES, ZIP FE, YES) dec(3)
reghdfe dist_all delr_h_r_bank $xlist $loan $xlist_zip if jumbo==1, absorb(bdummy ydummy racedummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(Year FE, YES, Race FE, YES, Bank FE, YES, ZIP FE, YES) dec(3)
reghdfe dist_all delr_h_r_bank $xlist $loan $xlist_zip if fha==1, absorb(bdummy ydummy racedummy zdummy) vce(cluster sdummy)
outreg2 using myreg.xls, append ctitle(Fixed Effects) addstat(Adj. Overall R-squared, e(r2_a), Adj. Within R-squared, e(r2_a_within)) addtext(Year FE, YES, Race FE, YES, Bank FE, YES, ZIP FE, YES) dec(3)


