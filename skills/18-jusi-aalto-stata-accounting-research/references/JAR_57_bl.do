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
