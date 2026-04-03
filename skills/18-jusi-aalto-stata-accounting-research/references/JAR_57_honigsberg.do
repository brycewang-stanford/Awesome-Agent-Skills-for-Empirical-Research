use "C:\Users...Raw_DF_Data.dta", clear

***generate ID variable and calculate fund age per month
		egen ID=group(productreference post) //used for Sadka calculation below
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post NEW)

		rename rateofreturn CV_ret
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_DF_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy		
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_DF.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			/* CODE TO GENERATE CV_sadka_DF.dta file (imported from separate do files for concision)
			
			***Using raw dta file with ID variable, regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
				
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka dta file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_DF.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_DF.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_DF.dta", replace
				
			*/
			
***merge existing controls with dta file containing the number of audited months		
	merge 1:1 productreference post using "C:\Users...CV_audit_DF.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		drop ID

save "C:\Users...DF_Controls.dta", replace
use "C:\Users...Raw_Goldstein_Data.dta", clear
	
***generate ID variable and calculate fund age per month
		egen ID=group(productreference post) //used for Sadka calculation below
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post remain control deregister)

		winsor rateofreturn, p(.01) gen (CV_ret) //this is to correct for one obs showing monthly return over 1M. Clear error.
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_Goldstein_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge
		
***generate US dummy		
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_Gold.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			/* CODE TO GENERATE CV_sadka_Gold.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_Gold.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_Gold.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_Gold.dta", replace
				
			*/
			
***merge existing controls with dta file containing the number of audited months			
	merge 1:1 productreference post using "C:\Users...CV_audit_Gold.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		drop ID

save "C:\Users...Gold_Controls.dta", replace
use "C:\Users...Raw_HF_Data.dta", clear

***generate ID variable and calculate fund age per month	
	egen ID=group(productreference post) //used for Sadka calculation below
	gsort productreference date
	bysort productreference: carryforward dateaddedtotass, replace
	g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post reg2006)

	rename rateofreturn CV_ret
	rename nav CV_nav
	rename age CV_age
	replace CV_age=CV_age/365
	replace CV_age=0 if CV_age<0
	replace CV_nav=ln(CV_nav)
	tempfile temp1
	save "`temp1'"

use "C:\Users...Raw_HF_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy
	g CV_US=1 if domicilecountry=="United States"
		replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_HF.dta" //the Sadka liquidity measure was supplied by Prof. Sadka. The code to generate the CV_sadka_HF.dta file is below.
		keep if _merge==3
		drop _merge
	
			/* CODE TO GENERATE CV_sadka_HF.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent liquidity variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_2006.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_2006.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_HF.dta", replace
				
			*/

***merge existing controls with dta file containing the number of audited months	
	merge 1:1 productreference post using "C:\Users...CV_audit_HF.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge	
		drop ID
		
save "C:\Users...HF_Controls.dta", replace
use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

***calculate fund age per month
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry remain control deregister)

		drop rateofreturn
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_3period_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference using "C:\Users...CV_sadka_3Period.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			
			/* CODE TO GENERATE CV_sadka_3Period.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(productreference) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_3Period.dta", replace

			***Merge liquidity dta file with original raw file, keeping only the relevant control
				merge m:1 productreference using "C:\Users...liquidity_3Period.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_3Period.dta", replace
				
			*/

***merge existing controls with dta file containing the number of audited months	
	merge 1:1 productreference using "C:\Users...CV_audit_3Period.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		g period = 2

	save "C:\Users...3Period_Controls.dta", replace
use "C:\Users...Raw_DF_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups) 
		drop if dups<29 
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.

	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). 
		***Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). 
			***https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
	
	***open the adj_december file containing the saved regression output and run the code below
	
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...DF_adjdecember", replace
*/
	
	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...DF_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep productreference post adj_dec
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...DF_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...DF_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...DF_FLAGS.dta", replace
use "C:\Users...Raw_DF_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post NEW)
	
	***keep only funds with 30 obs in each period
		keep if total_obs==30	
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket		
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat		
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard
		
	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.
		
	***keep only relevant variables
		keep productreference post abn_kink NEW
		
save "C:\Users...DF_KinkFlags.dta", replace
use "C:\Users...Raw_Goldstein_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups)
		drop if dups<29
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.
	
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm	
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
		
	***open the adj_december file containing the saved regression output and run the code below

		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...Gold_adjdecember", replace
*/
	
	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...Gold_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep adj_dec post productreference
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...Gold_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...Gold_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...Gold_FLAGS.dta", replace
use "C:\Users...Raw_Goldstein_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period.
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post control remain deregister)
		
	***keep only funds with 30 obs in each period	
		keep if total_obs==30
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.
	
	***keep only relevant variables
		keep productreference post abn_kink control remain deregister
		replace deregister = 0 if deregister == . //set to 1 if fund withdraws post Goldstein
		replace remain = 0 if remain ==. //set to 1 if fund remains registered post Goldstein
	
save "C:\Users...Gold_KinkFlags.dta", replace

use "C:\Users...Raw_HF_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups)
		drop if dups<29
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.
		
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm	
	merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
		keep if _merge==3
		drop _merge
		
	merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
		keep if _merge==3
		drop _merge
		
	merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
		keep if _merge==3
		drop _merge
	g crdt_sprd=chg_moody-yld_chg

	merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
		keep if _merge==3
		drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust

	***open the adj_december file containing the saved regression output and run the code below
		
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...HF_adjdecember", replace
*/

	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...HF_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep adj_dec post productreference
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...HF_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...HF_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...HF_FLAGS.dta", replace
use "C:\Users...Raw_HF_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period.
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post reg2006)
		
	***keep only funds with 30 obs in each period
		keep if total_obs==30	
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.

	***keep only relevant variables
		keep productreference post abn_kink reg2006

save "C:\Users...HF_KinkFlags.dta", replace



use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

	***generate key variables
		g december=1 if month==12
		replace december=0 if december==. & month!=.
	
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*			
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(productreference) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
	
	***open the adj_december file containing the saved regression output and run the code below
	
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...3Period_adjdecember", replace
*/

	***merge the adjdecember dta file generated above with the raw data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 productreference using "C:\Users...3Period_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.

	***keep one obs per fund in each period, keep only relevant variables
		keep productreference adj_dec
		duplicates drop

save "C:\Users...3Period_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference using "C:\Users...3Period_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...3Period_FLAGS.dta", replace

use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

	***classify each return into relevant bucket if that return falls from -1 to 0.5 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1

	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference control remain deregister)
		
	***calculate difference between actual and expected number of obs in middle bucket		
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat		
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.

	***keep only relevant variables
		keep productreference abn_kink control remain deregister
		duplicates drop
			replace deregister = 0 if deregister == .
			replace remain = 0 if remain ==.
	
save "C:\Users...3Period_KinkFlags.dta", replace



***Merge misreporting data with control variables
	use "C:\Users...DF_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...DF_Controls.dta"
			drop _merge
		
***Remove disclosure-only funds and those funds that registered in response to the HF Rule	
	drop if ERA == 1
	drop if previous_registrant==1

***Sum measures of misreporting
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1
	rename domicilecountry country	

***Generate matched sample that ensures: 
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit NEW CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	egen cat=group(primarycategory)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 NEW if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]

save "C:\Users...DF_PSM.dta", replace
***Merge misreporting data with control variables
	use "C:\Users...Gold_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...Gold_Controls.dta"
			drop _merge
			
***Remove the newly registered funds that remained registered (match only withdraw and control funds)
	drop if remain == 1

***Sum measures of misreporting	
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1

***Generate matched sample that ensures:
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit deregister CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	egen cat=group(primarycategory)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 deregister if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]
	
save "C:\Users...Gold_PSM.dta", replace
***Merge misreporting data with control variables
	use "C:\Users...HF_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...HF_Controls.dta"
			drop _merge
			
***Sum measures of misreporting
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1

***Generate matched sample that ensures: 
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit NEW CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	g cat1 = primarycategory
	replace cat1 = "Other" if primarycategory == "Dedicated Short Bias" //Reclassify these two funds as "other" to improve possibility of match 
	replace cat1 = "Other" if primarycategory == "Options Strategy" //Reclassify these four funds as "other" to improve possibility of match (all other categories have at least ten funds)
	egen cat=group(cat1)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 NEW if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]

save "C:\Users...HF_PSM.dta", replace









use "C:\Users...Raw_DF_Data.dta", clear

***generate ID variable and calculate fund age per month
		egen ID=group(productreference post) //used for Sadka calculation below
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post NEW)

		rename rateofreturn CV_ret
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_DF_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy		
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_DF.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			/* CODE TO GENERATE CV_sadka_DF.dta file (imported from separate do files for concision)
			
			***Using raw dta file with ID variable, regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
				
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka dta file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_DF.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_DF.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_DF.dta", replace
				
			*/
			
***merge existing controls with dta file containing the number of audited months		
	merge 1:1 productreference post using "C:\Users...CV_audit_DF.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		drop ID

save "C:\Users...DF_Controls.dta", replace
use "C:\Users...Raw_Goldstein_Data.dta", clear
	
***generate ID variable and calculate fund age per month
		egen ID=group(productreference post) //used for Sadka calculation below
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post remain control deregister)

		winsor rateofreturn, p(.01) gen (CV_ret) //this is to correct for one obs showing monthly return over 1M. Clear error.
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_Goldstein_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge
		
***generate US dummy		
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_Gold.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			/* CODE TO GENERATE CV_sadka_Gold.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_Gold.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_Gold.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_Gold.dta", replace
				
			*/
			
***merge existing controls with dta file containing the number of audited months			
	merge 1:1 productreference post using "C:\Users...CV_audit_Gold.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		drop ID

save "C:\Users...Gold_Controls.dta", replace
use "C:\Users...Raw_HF_Data.dta", clear

***generate ID variable and calculate fund age per month	
	egen ID=group(productreference post) //used for Sadka calculation below
	gsort productreference date
	bysort productreference: carryforward dateaddedtotass, replace
	g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post reg2006)

	rename rateofreturn CV_ret
	rename nav CV_nav
	rename age CV_age
	replace CV_age=CV_age/365
	replace CV_age=0 if CV_age<0
	replace CV_nav=ln(CV_nav)
	tempfile temp1
	save "`temp1'"

use "C:\Users...Raw_HF_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy
	g CV_US=1 if domicilecountry=="United States"
		replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_HF.dta" //the Sadka liquidity measure was supplied by Prof. Sadka. The code to generate the CV_sadka_HF.dta file is below.
		keep if _merge==3
		drop _merge
	
			/* CODE TO GENERATE CV_sadka_HF.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent liquidity variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_2006.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_2006.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_HF.dta", replace
				
			*/

***merge existing controls with dta file containing the number of audited months	
	merge 1:1 productreference post using "C:\Users...CV_audit_HF.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge	
		drop ID
		
save "C:\Users...HF_Controls.dta", replace
use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

***calculate fund age per month
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry remain control deregister)

		drop rateofreturn
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_3period_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference using "C:\Users...CV_sadka_3Period.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			
			/* CODE TO GENERATE CV_sadka_3Period.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(productreference) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_3Period.dta", replace

			***Merge liquidity dta file with original raw file, keeping only the relevant control
				merge m:1 productreference using "C:\Users...liquidity_3Period.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_3Period.dta", replace
				
			*/

***merge existing controls with dta file containing the number of audited months	
	merge 1:1 productreference using "C:\Users...CV_audit_3Period.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		g period = 2

	save "C:\Users...3Period_Controls.dta", replace
use "C:\Users...Raw_DF_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups) 
		drop if dups<29 
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.

	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). 
		***Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). 
			***https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
	
	***open the adj_december file containing the saved regression output and run the code below
	
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...DF_adjdecember", replace
*/
	
	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...DF_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep productreference post adj_dec
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...DF_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...DF_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...DF_FLAGS.dta", replace
use "C:\Users...Raw_DF_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post NEW)
	
	***keep only funds with 30 obs in each period
		keep if total_obs==30	
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket		
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat		
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard
		
	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.
		
	***keep only relevant variables
		keep productreference post abn_kink NEW
		
save "C:\Users...DF_KinkFlags.dta", replace
use "C:\Users...Raw_Goldstein_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups)
		drop if dups<29
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.
	
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm	
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
		
	***open the adj_december file containing the saved regression output and run the code below

		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...Gold_adjdecember", replace
*/
	
	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...Gold_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep adj_dec post productreference
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...Gold_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...Gold_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...Gold_FLAGS.dta", replace
use "C:\Users...Raw_Goldstein_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period.
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post control remain deregister)
		
	***keep only funds with 30 obs in each period	
		keep if total_obs==30
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.
	
	***keep only relevant variables
		keep productreference post abn_kink control remain deregister
		replace deregister = 0 if deregister == . //set to 1 if fund withdraws post Goldstein
		replace remain = 0 if remain ==. //set to 1 if fund remains registered post Goldstein
	
save "C:\Users...Gold_KinkFlags.dta", replace

use "C:\Users...Raw_HF_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups)
		drop if dups<29
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.
		
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm	
	merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
		keep if _merge==3
		drop _merge
		
	merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
		keep if _merge==3
		drop _merge
		
	merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
		keep if _merge==3
		drop _merge
	g crdt_sprd=chg_moody-yld_chg

	merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
		keep if _merge==3
		drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust

	***open the adj_december file containing the saved regression output and run the code below
		
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...HF_adjdecember", replace
*/

	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...HF_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep adj_dec post productreference
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...HF_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...HF_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...HF_FLAGS.dta", replace
use "C:\Users...Raw_HF_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period.
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post reg2006)
		
	***keep only funds with 30 obs in each period
		keep if total_obs==30	
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.

	***keep only relevant variables
		keep productreference post abn_kink reg2006

save "C:\Users...HF_KinkFlags.dta", replace



use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

	***generate key variables
		g december=1 if month==12
		replace december=0 if december==. & month!=.
	
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*			
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(productreference) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
	
	***open the adj_december file containing the saved regression output and run the code below
	
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...3Period_adjdecember", replace
*/

	***merge the adjdecember dta file generated above with the raw data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 productreference using "C:\Users...3Period_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.

	***keep one obs per fund in each period, keep only relevant variables
		keep productreference adj_dec
		duplicates drop

save "C:\Users...3Period_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference using "C:\Users...3Period_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...3Period_FLAGS.dta", replace

use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

	***classify each return into relevant bucket if that return falls from -1 to 0.5 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1

	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference control remain deregister)
		
	***calculate difference between actual and expected number of obs in middle bucket		
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat		
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.

	***keep only relevant variables
		keep productreference abn_kink control remain deregister
		duplicates drop
			replace deregister = 0 if deregister == .
			replace remain = 0 if remain ==.
	
save "C:\Users...3Period_KinkFlags.dta", replace



***Merge misreporting data with control variables
	use "C:\Users...DF_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...DF_Controls.dta"
			drop _merge
		
***Remove disclosure-only funds and those funds that registered in response to the HF Rule	
	drop if ERA == 1
	drop if previous_registrant==1

***Sum measures of misreporting
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1
	rename domicilecountry country	

***Generate matched sample that ensures: 
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit NEW CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	egen cat=group(primarycategory)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 NEW if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]

save "C:\Users...DF_PSM.dta", replace
***Merge misreporting data with control variables
	use "C:\Users...Gold_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...Gold_Controls.dta"
			drop _merge
			
***Remove the newly registered funds that remained registered (match only withdraw and control funds)
	drop if remain == 1

***Sum measures of misreporting	
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1

***Generate matched sample that ensures:
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit deregister CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	egen cat=group(primarycategory)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 deregister if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]
	
save "C:\Users...Gold_PSM.dta", replace
***Merge misreporting data with control variables
	use "C:\Users...HF_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...HF_Controls.dta"
			drop _merge
			
***Sum measures of misreporting
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1

***Generate matched sample that ensures: 
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit NEW CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	g cat1 = primarycategory
	replace cat1 = "Other" if primarycategory == "Dedicated Short Bias" //Reclassify these two funds as "other" to improve possibility of match 
	replace cat1 = "Other" if primarycategory == "Options Strategy" //Reclassify these four funds as "other" to improve possibility of match (all other categories have at least ten funds)
	egen cat=group(cat1)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 NEW if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]

save "C:\Users...HF_PSM.dta", replace









use "C:\Users...Raw_DF_Data.dta", clear

***generate ID variable and calculate fund age per month
		egen ID=group(productreference post) //used for Sadka calculation below
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post NEW)

		rename rateofreturn CV_ret
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_DF_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy		
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_DF.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			/* CODE TO GENERATE CV_sadka_DF.dta file (imported from separate do files for concision)
			
			***Using raw dta file with ID variable, regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
				
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka dta file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_DF.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_DF.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_DF.dta", replace
				
			*/
			
***merge existing controls with dta file containing the number of audited months		
	merge 1:1 productreference post using "C:\Users...CV_audit_DF.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		drop ID

save "C:\Users...DF_Controls.dta", replace

use "C:\Users...Raw_Goldstein_Data.dta", clear
	
***generate ID variable and calculate fund age per month
		egen ID=group(productreference post) //used for Sadka calculation below
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post remain control deregister)

		winsor rateofreturn, p(.01) gen (CV_ret) //this is to correct for one obs showing monthly return over 1M. Clear error.
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_Goldstein_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge
		
***generate US dummy		
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_Gold.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			/* CODE TO GENERATE CV_sadka_Gold.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_Gold.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_Gold.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_Gold.dta", replace
				
			*/
			
***merge existing controls with dta file containing the number of audited months			
	merge 1:1 productreference post using "C:\Users...CV_audit_Gold.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		drop ID

save "C:\Users...Gold_Controls.dta", replace

use "C:\Users...Raw_HF_Data.dta", clear

***generate ID variable and calculate fund age per month	
	egen ID=group(productreference post) //used for Sadka calculation below
	gsort productreference date
	bysort productreference: carryforward dateaddedtotass, replace
	g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry post reg2006)

	rename rateofreturn CV_ret
	rename nav CV_nav
	rename age CV_age
	replace CV_age=CV_age/365
	replace CV_age=0 if CV_age<0
	replace CV_nav=ln(CV_nav)
	tempfile temp1
	save "`temp1'"

use "C:\Users...Raw_HF_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference post)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference post using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy
	g CV_US=1 if domicilecountry=="United States"
		replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference post using "C:\Users...CV_sadka_HF.dta" //the Sadka liquidity measure was supplied by Prof. Sadka. The code to generate the CV_sadka_HF.dta file is below.
		keep if _merge==3
		drop _merge
	
			/* CODE TO GENERATE CV_sadka_HF.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent liquidity variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(ID) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_2006.dta", replace

			***Merge liquidity dta file with original raw file (including ID), keeping only the relevant control
				merge m:1 ID using "C:\Users...liquidity_2006.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference post
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_HF.dta", replace
				
			*/

***merge existing controls with dta file containing the number of audited months	
	merge 1:1 productreference post using "C:\Users...CV_audit_HF.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge	
		drop ID
		
save "C:\Users...HF_Controls.dta", replace

use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

***calculate fund age per month
		gsort productreference date
		bysort productreference: carryforward dateaddedtotass, replace
		g age=date- dateaddedtotass

***generate mean fund return, age, and net asset value over each period
	collapse (mean) rateofreturn nav age, by (productreference primarycategory domicilecountry remain control deregister)

		drop rateofreturn
		rename nav CV_nav
		rename age CV_age
		replace CV_age=CV_age/365
		replace CV_age=0 if CV_age<0
		replace CV_nav=ln(CV_nav)
		tempfile temp1
		save "`temp1'"

use "C:\Users...Raw_3period_Data.dta", clear

***generate fund volatility over each period
	collapse (sd) rateofreturn, by (productreference)
	rename rateofreturn CV_std

***merge fund volatility with mean variables generated above
	merge m:1 productreference using "`temp1'" 
		keep if _merge==3
		drop _merge

***generate US dummy
	g CV_US=1 if domicilecountry=="United States"
	replace CV_US=0 if CV_US==.

***merge existing controls with dta file containing the fund's sensitivity to liquidity (sadka control)
	merge 1:1 productreference using "C:\Users...CV_sadka_3Period.dta" //the Sadka liquidity measure was supplied by Prof. Sadka
		keep if _merge==3
		drop _merge
		
			
			/* CODE TO GENERATE CV_sadka_3Period.dta file (imported from separate do files for concision)
			
			***Regress return on sadka permanent variable provided by Prof. Sadka (line below creates a sadka.dta file with regression outputs)
			
				statsby _b[_cons] _se[_cons] _b[variablepermanent] _se[variablepermanent] e(r2), by(productreference) saving(sadka): regress rateofreturn variablepermanent i.year, robust 

			***Open sadka file generated above and run the code below
				
				rename  _stat_2 se_cons
				rename  _stat_3 beta_sadka
				rename  _stat_4 se_sadka
				rename  _stat_5 R2
				g t_sadka= beta_sadka/ se_sadka
				g t_cons= beta_cons/ se_cons
				drop if  t_sadka==.
				save "C:\Users...liquidity_3Period.dta", replace

			***Merge liquidity dta file with original raw file, keeping only the relevant control
				merge m:1 productreference using "C:\Users...liquidity_3Period.dta"
					keep if _merge==3
					drop _merge
				keep beta_sadka productreference
				rename beta_sadka CV_sadka
				duplicates drop
				save "C:\Users...CV_sadka_3Period.dta", replace
				
			*/

***merge existing controls with dta file containing the number of audited months	
	merge 1:1 productreference using "C:\Users...CV_audit_3Period.dta" //as mentioned in the paper, the audit variable relies on historical data that is not available in the standard WRDS download. Please contact me directly for this code.
		keep if _merge==3
		drop _merge
		g period = 2

	save "C:\Users...3Period_Controls.dta", replace

use "C:\Users...Raw_DF_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups) 
		drop if dups<29 
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.

	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). 
		***Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). 
			***https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
	
	***open the adj_december file containing the saved regression output and run the code below
	
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...DF_adjdecember", replace
*/
	
	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...DF_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep productreference post adj_dec
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...DF_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...DF_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...DF_FLAGS.dta", replace

use "C:\Users...Raw_DF_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post NEW)
	
	***keep only funds with 30 obs in each period
		keep if total_obs==30	
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket		
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat		
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard
		
	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.
		
	***keep only relevant variables
		keep productreference post abn_kink NEW
		
save "C:\Users...DF_KinkFlags.dta", replace

use "C:\Users...Raw_Goldstein_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups)
		drop if dups<29
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.
	
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm	
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
		
	***open the adj_december file containing the saved regression output and run the code below

		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...Gold_adjdecember", replace
*/
	
	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...Gold_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep adj_dec post productreference
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...Gold_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...Gold_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...Gold_FLAGS.dta", replace

use "C:\Users...Raw_Goldstein_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period.
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post control remain deregister)
		
	***keep only funds with 30 obs in each period	
		keep if total_obs==30
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.
	
	***keep only relevant variables
		keep productreference post abn_kink control remain deregister
		replace deregister = 0 if deregister == . //set to 1 if fund withdraws post Goldstein
		replace remain = 0 if remain ==. //set to 1 if fund remains registered post Goldstein
	
save "C:\Users...Gold_KinkFlags.dta", replace


use "C:\Users...Raw_HF_Data.dta", clear

	***keep only funds with 30 obs per period and generate key variables
		duplicates tag productreference post, gen (dups)
		drop if dups<29
		drop dups
		
		egen ID=group(productreference post)
		g december=1 if month==12
		replace december=0 if december==. & month!=.
		
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm	
	merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
		keep if _merge==3
		drop _merge
		
	merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
		keep if _merge==3
		drop _merge
		
	merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
		keep if _merge==3
		drop _merge
	g crdt_sprd=chg_moody-yld_chg

	merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
		keep if _merge==3
		drop _merge
/*	
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(ID) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust

	***open the adj_december file containing the saved regression output and run the code below
		
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...HF_adjdecember", replace
*/

	***merge the adjdecember dta file generated above with the TASS data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 ID using "C:\Users...HF_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.
	
	***keep one obs per fund in each period (only for funds with data in both period), keep only relevant variables
		keep adj_dec post productreference
		duplicates drop
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups

save "C:\Users...HF_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference post using "C:\Users...HF_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...HF_FLAGS.dta", replace

use "C:\Users...Raw_HF_Data.dta", clear

	***classify each return into relevant bucket if that return falls from -1 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1
		g total_obs=1 //later used to keep only funds with 30 obs in each period
		
	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period.
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference post reg2006)
		
	***keep only funds with 30 obs in each period
		keep if total_obs==30	
		duplicates tag productreference, gen (dups)
		drop if dups<2 
		drop dups
		
	***calculate difference between actual and expected number of obs in middle bucket
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.

	***keep only relevant variables
		keep productreference post abn_kink reg2006

save "C:\Users...HF_KinkFlags.dta", replace




use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

	***generate key variables
		g december=1 if month==12
		replace december=0 if december==. & month!=.
	
	***merge the TASS data with the fund factors used by Fung and Hsieh (2004). Please see Prof. Hsieh's website for detail on these factors (the data on the website are updated monthly). https://faculty.fuqua.duke.edu/~dah7/HFRFData.htm
		merge m:1 year month using "C:\Users...TrendRiskFactors.dta" //Hsieh excel file
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...BondYield.dta" //bond market factor https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
			
		merge m:1 year month using	"C:\Users...Moodys.dta" //credit spread factor https://fred.stlouisfed.org/series/DBAA  https://fred.stlouisfed.org/series/DGS10
			keep if _merge==3
			drop _merge
		g crdt_sprd=chg_moody-yld_chg

		merge m:1 year month using "C:\Users...Datastream.dta" //equity oriented risk factors (S&P500 & size spread)
			keep if _merge==3
			drop _merge
/*			
	***regress each fund's return on an indicator for December, fund risk factors, and year fixed effects (line below generates a dta file called adj_december). Runs regression by ID generated above (fund-period)

		statsby _b[_cons] _se[_cons] _b[december] _se[december] e(r2), by(productreference) saving(adj_december): reg rateofreturn december sizespread yld_chg chg_moody equity ptfsbd ptfsfx ptfscom i.year, robust
	
	***open the adj_december file containing the saved regression output and run the code below
	
		rename _stat_1 beta_cons
		rename  _stat_2 se_cons
		rename  _stat_3 beta_adjdec
		rename  _stat_4 se_adjdec
		rename  _stat_5 R2
		g t_adjdec= beta_adjdec/ se_adjdec
		g t_cons= beta_cons/ se_cons
		drop if  t_adjdec==.
		save "C:\Users...3Period_adjdecember", replace
*/

	***merge the adjdecember dta file generated above with the raw data, generate the misreporting flag based on the t-stat from the adjdecember dta file
		merge m:1 productreference using "C:\Users...3Period_adjdecember.dta"
			keep if _merge==3
			drop _merge
		g adj_dec=1 if t_adjdec>1.96 & t_adjdec!=.
		replace adj_dec=0 if adj_dec==. & t_adjdec!=.

	***keep one obs per fund in each period, keep only relevant variables
		keep productreference adj_dec
		duplicates drop

save "C:\Users...3Period_CookieJarFlags.dta", replace

///Merge measures of misreporting
	merge 1:1 productreference using "C:\Users...3Period_KinkFlags.dta"
		keep if _merge==3
		drop _merge

save "C:\Users...3Period_FLAGS.dta", replace


use "C:\Users...Raw_3period_Data.dta", clear //contains data for the middle period in the extended 3-period model

	***classify each return into relevant bucket if that return falls from -1 to 0.5 to 0.5
		g kink1=1 if rateofreturn>0 & rateofreturn<=.50
		g kink2=1 if rateofreturn<=0 & rateofreturn>-.50
		g kink3=1 if rateofreturn<=-.5 & rateofreturn>-1

	***sum the returns in each bucket and total obs per fund in each period. Line below generates one line of code per fund in each period
		collapse (sum) kink1 kink2 kink3 total_obs, by (productreference control remain deregister)
		
	***calculate difference between actual and expected number of obs in middle bucket		
		g expected=(kink1+kink3)/2
		g diff=expected-kink2
		
	***calculate standard deviation and t-stat		
		g pi=kink2/total_obs
		g pi1=kink1/total_obs
		g pi_1=kink3/total_obs
		g standard=total_obs*pi*(1-pi)+(1/4)*total_obs*(pi_1+pi1)*(2-pi_1-pi1)
		replace standard=sqrt(standard)
		g test_stat=diff/standard

	***generate misreporting flag based on t-stat
		g abn_kink=1 if test_stat>1.96 & test_stat!=.
		replace abn_kink=0 if abn_kink==. & test_stat!=.

	***keep only relevant variables
		keep productreference abn_kink control remain deregister
		duplicates drop
			replace deregister = 0 if deregister == .
			replace remain = 0 if remain ==.
	
save "C:\Users...3Period_KinkFlags.dta", replace




***Merge misreporting data with control variables
	use "C:\Users...DF_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...DF_Controls.dta"
			drop _merge
		
***Remove disclosure-only funds and those funds that registered in response to the HF Rule	
	drop if ERA == 1
	drop if previous_registrant==1

***Sum measures of misreporting
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1
	rename domicilecountry country	

***Generate matched sample that ensures: 
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit NEW CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	egen cat=group(primarycategory)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 NEW if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]

save "C:\Users...DF_PSM.dta", replace

***Merge misreporting data with control variables
	use "C:\Users...Gold_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...Gold_Controls.dta"
			drop _merge
			
***Remove the newly registered funds that remained registered (match only withdraw and control funds)
	drop if remain == 1

***Sum measures of misreporting	
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1

***Generate matched sample that ensures:
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit deregister CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	egen cat=group(primarycategory)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 deregister if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]
	
save "C:\Users...Gold_PSM.dta", replace

***Merge misreporting data with control variables
	use "C:\Users...HF_FLAGS.dta", clear
		merge 1:1 productreference post using "C:\Users...HF_Controls.dta"
			drop _merge
			
***Sum measures of misreporting
	g flag1=0
	replace flag1=flag1+1 if abn_kink==1
	replace flag1=flag1+1 if adj_dec==1

***Generate matched sample that ensures: 
	***(1) matched pairs have the same number of flags in the pre period, 
		***(2) US funds are matched to US funds (and non-US to non-US), and
			***(3) matched funds have the same fund strategy (primarycategory variable).
				***After these restrictions, preference is given to funds with similar propensity to be registered.
	
	xi: probit NEW CV_ret CV_nav CV_age CV_std CV_sadka CV_audit 
	predict double ps
	sum ps

	***weight three restrictions above so that no match can be made unless all three are met
	g cat1 = primarycategory
	replace cat1 = "Other" if primarycategory == "Dedicated Short Bias" //Reclassify these two funds as "other" to improve possibility of match 
	replace cat1 = "Other" if primarycategory == "Options Strategy" //Reclassify these four funds as "other" to improve possibility of match (all other categories have at least ten funds)
	egen cat=group(cat1)
	g pscore1 =cat*1000+ps
	g double pscore2 =CV_US*100000+pscore1
	replace pscore2=flag1*10000000+pscore2

	gsort productreference post
	psmatch2 NEW if post==0,  pscore(pscore2) caliper(100) noreplacement
	gen pair = _id if _treated==0
	replace pair = _n1 if _treated==1
	bysort pair: egen paircount = count(pair)
	save paired, replace

	sort productreference _treated
	g pspair=pair
	replace pspair=pair[_n-1] if pspair==. & productreference==productreference[_n-1]
	drop if pspair==.
	g pspaircount=paircount
	replace pspaircount=pspaircount[_n-1] if productreference==productreference[_n-1] & post==1
	keep if pspaircount>1
	g psweight=_weight
	replace psweight=_weight[_n-1] if psweight==. & productreference==productreference[_n-1]

save "C:\Users...HF_PSM.dta", replace










