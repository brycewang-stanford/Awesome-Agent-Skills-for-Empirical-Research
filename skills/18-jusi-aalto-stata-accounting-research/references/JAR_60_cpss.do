/*
Coles, Jeffrey L., Elena Patel, Nathan Seegert, and Matthew Smith, "How Do Private Firms Respond to Corporate Taxes" Journal of Accounid_varg Research

Input files are drawn from U.S. administrative tax data. Each file contains annual records filed on IRS Form 1120. 
Extraction code is available upon request for authorized data users.


Setup file proceeds in the following steps
		1. Create panel data from annual population data. (full_panel.dta)
		2. Clean duplicate firm-year records. 
		3. Identify estimation sample. (clean_panel.dta)
		4. Produce sample for empirical analysis. (sample_panel.dta)
		5. Produce sample for effective tax rate analysis. (sample_panel_graham.dta)

Additional Notes:
	For both the bunching analysis and accounid_varg response estimates, we impose a sample restriction removing outliers with respect to revenue.
	
	For the accounid_varg response estimates, we further restrict the sample to only include observations in the bunching analysis, using the  "sample_bins" file to identify firms in the bunching sample. 

	The bunching analysis file further requires bins with zero observations, which would otherwise be missing. 

	The code to produce the "sample bin" file, along with the zeroes file is included in this package. 


Reference for Business Definition: Knittel, M., Nelson, S., DeBacker, J., Kitchen, J., Pearce, J. and Prisinzano, R., 2011. Methodology to identify small businesses and their owners. Office of Tax Analysis, Department of the Treasury.

*/

*=======================================*
*				Step One				*
*										*
*	Read in raw population dataset		*
*										*
*	Restrict sample by dropping some	*
*	businesses							*
*										*
*	Merge together to create panel		*
*=======================================*
	local bYear=2004			
	local eYear=2015	
	
	quietly forvalues k=`bYear'/`eYear'{
			
			use f1120y`k'.dta, clear		// load in annual population data extracts
			
			qui gen NOL_stock= nolc_var
			qui gen inc_spec= net_income_var -  special_deductions_var
			
			/*	Generate Small Business Definition Following Knittel et. al (2011)	*/
			
				/*
					Small Biz Definition requires Cost of Goods Sold Labor Expenses 
					These data are not contained in the population files
					As a result, we simulate these values
				*/
					quietly{
						gen cogL=.
						replace cogL=0 if costs_of_good_sold_var==0
						local a=0
						foreach v in `cogL'{
							local a=`a'+1
							replace cogL=`v'*costs_of_good_sold_var if industry==`a' & cogL==.
						}
						replace cogL=.3647431*costs_of_good_sold_var if cogL==.	
					}
			
				/* The code below implements the Knittel et al. definition	*/
					quietly{
						gen gross_receipts_var=gross_profits_var + costs_of_good_sold_var
						
						gen income_test= gross_receipts_var + dividends_var + rents_var + interest_income_var + royalties_var + abs(cap_gains_var) + abs(ordinary_gains_losses_var)
						
						gen other_income = royalties_var + interest_income_var + abs(ordinary_gains_losses_var) + oth_inc + dividends_var + abs(cap_gains_var)
						
						gen deduct_test = deductions_var - comp_of_officers_var + cogL + costs_of_good_sold_var
						
						gen total_income=gross_receipts_var + rents_var + other_income
						
						gen business = 1 if income_test >= 10000 & deduct_test >= 5000 & (gross_receipts_var + rents_var)>=.05*total_income 
							replace business = 1 if deduct_test >= 15000 & deduct_test >= 5000  & (gross_receipts_var + rents_var)>=.05*total_income 
							replace business = 1 if income_test + deduct_test >= 15000 & deduct_test >= 5000 & (gross_receipts_var + rents_var)>=.05*total_income 
							replace business = 1 if income_test + deduct_test >= 20000 & deduct_test >= 5000
							replace business = 0 if business==. 
					}
					
			keep if business==1	
			
			keep id_var tax_time_var month tax_year_var post_time_var inc_spec NOL_stock assets_var method_var receipts
			
			duplicates drop
			
			save f1120_`k'_short.dta, replace
	}		

	local bYear=2004			
	local eYear=2015
	local sYear=`bYear'+1
	use f1120_`bYear'_short.dta, clear
	quietly forvalues k=`sYear'/`eYear'{
		append using f1120_`k'_short.dta
	}
	save  full_panel.dta, replace

*=======================================*
*				Step Two				*
*										*
*		Make panel unique at firm 		*
*		year level						*
*										*
*=======================================*

	/* If a firm has two tax years, one full year and one part year, keep full year	*/
	
	use full_panel.dta, clear
		
		tostring tax_time_var, replace
		gen tax_mo=substr(tax_time_var,5,2)
		destring tax_mo, replace
		drop tax_time_var  month
		
		gen soi_yr=tax_year_var
			replace soi_yr = tax_year_var-1 if tax_mo<=6
		
		drop if soi_yr==2015
		
		by id_var soi_yr, sort: egen min_mo=min(tax_mo)
		by id_var soi_yr, sort: egen max_mo=max(tax_mo)
		
		gen mo=tax_mo
			replace mo=. if min_mo!=max_mo
		
		by id_var: egen mode_mo=mode(tax_mo)
			replace mo=mode_mo if mo==. & (mode_mo==min_mo|mode_mo==max_mo)
		
		drop  if  mo!=. & mo!=tax_mo
		drop min_mo max_mo mo 
	save clean_panel.dta, replace

	/*	Next, drop extra records where [method_var] or [assets_var] is missing or zero	*/
		
		// Identify missing method_var 
		
			by id_var soi_yr, sort: gen wtf=_N
			drop if wtf==1
			
			save dups_panel.dta, replace

			gen drop=0
			
			by id_var soi_yr, sort: egen max_method_var=max(method_var)
			
			by id_var soi_yr, sort: egen min_method_var=min(method_var)
			
			replace drop=1 if method_var==. & max_method_var!=. & max_method_var==min_method_var
			by id_var soi_yr, sort: egen mindrop=min(drop)
			drop if drop==1

		// Identify missing assets 
				
			drop mindrop
			
			by id_var soi_yr, sort: egen max_assets=max(assets_var)
			
			by id_var soi_yr, sort: egen min_assets=min(assets_var)
				replace drop=1 if assets_var==. & max_assets!=. & max_assets==min_assets
			
			by id_var soi_yr, sort: egen mindrop=min(drop)
			
			drop if drop==1
			
			drop max_method_var min_method_var max_assets min_assets mindrop

		// Keep non-zero records	
			
			// method_var
			gen mc=method_var if method_var!=0
			
			by id_var soi_yr, sort: egen max_method_var=max(mc)
			
			by id_var soi_yr, sort: egen min_method_var=min(mc)
			
			replace drop=1 if mc==. & max_method_var!=. & max_method_var==min_method_var
			
			by id_var soi_yr, sort: egen mindrop=min(drop)
			
			drop if drop==1
			
			drop mc max_method_var min_method_var  mindrop

			// assets
			gen assets=assets_var if assets_var!=0
			
			by id_var soi_yr, sort: egen max_assets=max(assets_var)
			
			by id_var soi_yr, sort: egen min_assets=min(assets_var)
			
			replace drop=1 if assets==. & max_assets!=. & max_assets==min_assets & max_assets!=0
			
			by id_var soi_yr, sort: egen mindrop=min(drop)

			drop if drop==1
			
			drop assets max_assets min_assets mindrop drop

	/*	For remaining duplicate firm-year records, keep the record most recently posted	*/

		sort id_var soi_yr post_time_var
		
		by id_var soi_yr, sort: gen wtf2=_n
		
		drop if wtf2>1
		
		drop wtf2 wtf
		
		save dups_panel.dta, replace

	/* Append the clenad observations back to panel	*/
		
		use "clean_panel.dta", clear
		
		by id_var soi_yr, sort: gen wtf=_N
		drop if wtf>1
		
		append using "dups_panel.dta"
		
		save clean_panel.dta, replace

*=======================================*
*				Step Three				*
*										*
*		Identify firms that enter		*
*		our sample						*
*=======================================*

	/* Tuning Parameter Values	*/

		local kink = 0
		local binSize =	50	
		local midBin  = `binSize'/2
		local kink_lb = 5000			// Lower bound firm-specific kink considered
		local kink_ub = 15000			// Upper bound firm-specific kink considered
		local inc_window = 10000		// Defines half of the income window
		local alpha_lb = -600			// Defines the lower bound of the bunching region
		local alpha_ub = 100			// Defines the upper bound of the bunching region
		local cf_lb1 = 500				// Defines the lower bound of the counterfactual region
		local cf_ub1 = 5000				// Defines the upper bound of the counterfactual region


	use "clean_panel.dta", clear

	/*
	identify firms that enter the sample 
	step 1: assign bins
	*/

	qui gen Income=(int((inc_spec+`midBin')/`binSize'))*`binSize'
	
	qui gen NOLs=(int((NOL_stock+`midBin')/`binSize'))*`binSize'

	/*
	identify firms that enter the sample 
	step 2: determine if the observation would enter the sample
	*/


	gen new_sample=0
	
	quietly forvalues v = `kink_lb'(`binSize')`kink_ub' {
		gen inc_window=0
		gen nol_samp=1
			
		*set the income window:
			replace inc_window=1 if Income <= (`v' + `inc_window')*1.2 & Income >= `v' - `inc_window'
		*identifying the counterfactual sample: 				local cf_lb = `v' + `cf_lb1'
			local cf_ub = `v' + `cf_ub1'
		*indicate firms that are within the counterfactual or treatment sample
			replace nol_samp=0 if NOLs > `cf_ub'							// Drop if NOL values above the upper bound
			replace nol_samp=0 if NOLs < `v'								// Drop NOL values below the kink
			replace nol_samp=0 if NOLs > `v' & NOLs < `cf_lb'				// Drop buffer zone values		
			replace new_sample=1 if nol_samp==1 & inc_window==1 & Income>=1000							
			
			drop inc_window nol_samp
	} //  End the loop over the kink points

	save clean_panel.dta, replace


	
*===========================================*
*				Step Four					*
*											*
*	Produce Sample for Empirical Analysis	*
*===========================================*
	
	use "clean_panel.dta", clear
	
	keep if new_sample==1
	
	drop post_time_var mode_mo tax_year_var tax_mo wtf sample new_sample
	
	save "sample_panel.dta", replace

*===========================================*
*				Step Five					*
*											*
*	Produce Sample for Effective Tax Rates	*
*===========================================*

	use "clean_panel.dta", clear
	
	bys id_var: egen everSample=max(new_sample)
	
	keep if everSample==1
	
	drop post_time_var mode_mo tax_year_var tax_mo wtf sample
	
	save "sample_panel_graham.dta", replace


*===========================================*
*											*
*				Misc Code					*
*											*
*===========================================*


	/* the following code is used to produce the final dataset for the accounid_varg response estimates */

	do "restrictions.do"
	
	use "sample_panel.dta", clear
	
	drop if soi_yr>2014
	
	sort Income NOLs
	
	merge m:1 Income NOLs using "sample_bins"
	
	keep if all_sample==1		
	
	gen restrict5a=0
		replace restrict5a=1 if toid_varcm < $rev_5
		replace restrict5a=1 if toid_varcm > $rev_95
	
	keep if restrict5a==0 	

	/* the following code is used to produce the final dataset for the bunching analysis. */

	do "restrictions.do"
	
	use "sample_panel.dta", clear
	
	drop if soi_yr>2014
	
	gen restrict5a=0
		replace restrict5a=1 if toid_varcm < $rev_5
		replace restrict5a=1 if toid_varcm > $rev_95
		keep if restrict5a==0 	
	
	qui gen Y=1
	
	keep Y Income NOLs 
	
	collapse (sum) Y, by(Income NOLs)
	
	sort Income NOLs 
	
	merge m:1 Income NOLs using "zeroes.dta"







































/* create sample restrictions globals */
use "sample_panel.dta", clear

/* step 1: set up sample for real vs reporting regression */ 
gen lpm_r=log(inc_spec/totIncm)
gen buffer=0
replace buffer=1 if Income-NOLs<-600 & Income-NOLs>-1000

/* step 2: trim top and bottom 5% for revenue */ 
reg lpm_r Income NOLs if buffer==0
sum totIncm if e(sample), detail
global rev_5= r(p5)
global rev_95 = r(p95)

/*
This produces the "sample_bins" file used to identify [income, nol] bins entering the bunching sample.
We use this file to ensure the sample for the accounting response estimates matches the bunching sample.
*/

/* create sample restrictions globals */

do "restrictions.do"

local buffer = -1000
local kink = 0
local rateAtKink = 0.15
local taxrateratio = 1/(1-`rateAtKink')
local alpha_lb = -600
local alpha_ub = 100
local cf_lb = 500
local cf_ub = 5000 
local inc_window = 12500


use "sample_panel.dta", clear
drop if soi_yr>2014
gen restrict5a=0
replace restrict5a=1 if totIncm < $rev_5
replace restrict5a=1 if totIncm > $rev_95
keep if restrict5a==0 	
keep if Income>=1000

gen alpha = 1
replace alpha=0 if Income-NOLs < `alpha_lb'     	
replace alpha=0 if Income-NOLs > `alpha_ub'
gen t_sample=0
gen c_sample=0
gen all_sample=0

quietly forvalues v = 5000(50)15000 {
								gen inc_window = (Income <= `v' + `inc_window') & (Income >= `v' - `inc_window')
								*identifying the counterfactual sample: 
								local CF_lb = `v' + `cf_lb'
								local CF_ub = `v' + `cf_ub'
								*Dropping firms that are not within the counterfactual sample
								gen t_samp = (NOLs==`v')
								*new correction to rescale obs entering counterfactual
								// CF Y reweights # of Observations to equalize
								*exclude firms outside of cf sample and firms in bunching region (or right of the kink) for use in CF distribution estimation
								gen c_samp=1
								replace c_samp= 0 if NOLs < `CF_lb'						// Excluding those outside of the CF Region
								replace c_samp= 0 if NOLs > `CF_ub'						// Excluding those outside of the CF Region (Didn't we already drop these guys?)					
								replace c_samp= 0 if alpha==1							// Excluding the bunching region itself					
								replace c_samp= 0 if Income-NOLs> `buffer'				// Excluding those to the Right of the buffer region
								replace t_sample = 1 if t_samp==1 & inc_window==1
								replace c_sample = 1 if c_samp==1 & inc_window==1
								replace all_sample = (t_sample==1 | c_sample==1)
								drop inc_window c_samp t_samp
}
								
count if all_sample==1	
count if t_sample==1
count if c_sample==1							


keep Income NOLs all_sample
duplicates drop
sort Income NOLs

save sample_bins, replace

/*

. count if all_sample==1  
  565,020

. count if t_sample==1
  448,059

. count if c_sample==1                                                  
  370,078




/*
Coles, Jeffrey L., Elena Patel, Nathan Seegert, and Matthew Smith, "How Do Private Firms Respond to Corporate Taxes" Journal of Accounting Research

This file adds zero records for certain bins that do not contain any firms

*/

clear
set obs 301
gen NOLs =_n*50 +4950
save "cross_2.dta", replace

clear
set obs 641
gen Income =_n*50 + 950
cross using "cross_2.dta"
gen Y=0
sort Income NOLs 
save "zeroes.dta", replace


/*
Here I only keep the bins that enter the sample
*/

local kink = 0
local kink_lb = 5000			// Lower bound firm-specific kink considered
local kink_ub = 15000			// Upper bound firm-specific kink considered
local inc_window = 12500		// Defines half of the income window
local alpha_lb = -600			// Defines the lower bound of the bunching region
local alpha_ub = 100			// Defines the upper bound of the bunching region
local cf_lb1 = 500				// Defines the lower bound of the counterfactual region
local cf_ub1 = 5000				// Defines the upper bound of the counterfactual region

use  "zeroes.dta", clear

gen new_sample=0
quietly forvalues v = `kink_lb'(50)`kink_ub' {
			gen inc_window=0
			gen nol_samp=1
			*set the income window:
			replace inc_window=1 if Income <= (`v' + `inc_window')*1.2 & Income >= `v' - `inc_window'
			*identifying the counterfactual sample: 
			local cf_lb = `v' + `cf_lb1'
			local cf_ub = `v' + `cf_ub1'
			*indicate firms that are within the counterfactual or treatment sample
			replace nol_samp=0 if NOLs > `cf_ub'							// Drop if NOL values above the upper bound
			replace nol_samp=0 if NOLs < `v'								// Drop NOL values below the kink
			replace nol_samp=0 if NOLs > `v' & NOLs < `cf_lb'				// Drop buffer zone values		
			replace new_sample=1 if nol_samp==1 & inc_window==1 & Income>=1000			
			drop inc_window nol_samp
} //  End the loop over the kink points
keep if new_sample==1
sort Income NOLs
save "zeroes.dta", replace


