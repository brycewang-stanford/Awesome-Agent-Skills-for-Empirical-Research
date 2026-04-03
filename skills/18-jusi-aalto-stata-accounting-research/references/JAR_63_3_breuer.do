/******************************************************************************/
/*** Title: 	Correction													***/
/*** Author:	M. Breuer													***/
/*** Year:		2025														***/
/*** Program:	Analyses													***/
/******************************************************************************/

/* Preliminaries */
version 15.1
clear all
set more off
set maxvar 15000

/* Seed */
set seed 1234

/* Directory */

/* Working directory */
local directory = "H:\Project_Correction"
cd "`directory'\Data"

/******************************************************************************/
/* (1) Sample selection and variable truncation								  */
/******************************************************************************/

/* Data */
cd "`directory'\Data\JAR"
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel */
xtset ci year

/* Variable list

Manuscript labels:
	mc_scope		= Standardized Reporting Scope
	mc_audit		= Standardized Auditing Scope
	scope			= Actual Reporting Scope
	audit_scope		= Actual Auditing Scope
	m_audit			= Audit (Average)
	m_listed		= Publicly Listed (Average)
	w_listed		= Public Listed (Aggregate)
	m_shareholder	= Shareholders (Average)
	w_shareholder	= Shareholders (Aggregate)
	m_indep			= Independence (Average)
	w_indep			= Independence (Aggregate)
	m_entry			= Entry (Average)
	w_entry			= Entry (Aggregate)
	m_exit			= Exit (Average)
	w_exit			= Exit (Aggregate)
	hhi				= HHI
	cv_markup		= Dispersion (Gross Margin)
	sr_markup		= Distance (Gross Margin)
	cv_margin		= Dispersion (EBITDA/Sales)
	sr_margin		= Distance (EBITDA/Sales)
	cv_tfp_e		= Dispersion (TFP (Employees))
	sr_tfp_e		= Distance (TFP (Employees))
	p20_tfp_e		= Lower Tail (TFP (Employees))
	p80_tfp_e		= Upper Tail (TFP (Employees))
	cv_tfp_w		= Dispersion (TFP (Wage))
	sr_tfp_w		= Distance (TFP (Wage))
	p20_tfp_w		= Lower Tail (TFP (Wage))
	p80_tfp_w		= Upper Tail (TFP (Wage))
	cov_lp_e		= Covariance Y/L and Y (Employees)
	cov_tfp_e		= Covariance TFP and Y (Employees)
	cov_lp_w		= Covariance Y/L and Y (Wage)
	cov_tfp_w		= Covariance TFP and Y (Wage)
	m_lp_e			= Y/L (Employees) (Average)
	m_lp_w			= Y/L (Wage) (Average)
	m_tfp_e			= TFP (Employees) (Average)
	m_tfp_w			= TFP (Wage) (Average)
	w_lp_e			= Y/L (Employees) (Aggregate)
	w_lp_w			= Y/L (Wage) (Aggregate)
	w_tfp_e			= TFP (Employees) (Aggregate)
	w_tfp_w			= TFP (Wage) (Aggregate)
	dm_lp_e			= delta Y/L (Employees) (Average)
	dm_lp_w			= delta Y/L (Wage) (Average)
	dm_tfp_e		= delta TFP (Employees) (Average)
	dm_tfp_w		= delta TFP (Wage) (Average)
	dw_lp_e			= delta Y/L (Employees) (Aggregate)
	dw_lp_w			= delta Y/L (Wage) (Aggregate)
	dw_tfp_e		= delta TFP (Employees) (Aggregate)
	dw_tfp_w		= delta TFP (Wage) (Aggregate)

Notes:
	mc_ 		= prefix denoting simulated/standardized scopes (i.e., Monte Carlo simulation based scopes)
	m_ 			= prefix for equally-weighted mean
	w_			= prefix for sales-share-weighted total
	sr_			= prefix for standardized distance or range ((p80-p20)/mean)
	cv_			= prefix for coefficient of variation (standard deviation/mean)
	p20_		= prefix for 20th percentile
	p80_		= prefix for 80th percentile
	dm_			= prefix for mean growth (delta of mean)
	dw_ 		= prefix for aggregate growth (delta of sales-weighted total)
	_e			= suffix for employees-based measure (e.g., TFP calculated with number of employees as input)
	_w			= suffix for wage-based measure (e.g., TFP calculated with wage expense as input)
*/

/* Panel: country-industry year */
xtset ci year

/* Drop old scope */
drop scope mc_scope audit_scope mc_audit

/* Merge new scope */
cd "`directory'\Data"
merge 1:1 country industry year using Scope
drop if _merge == 2
drop _merge

/******************************************************************************/
/* Table 1 (Table 2 in Breuer [2021]): 										  */
/* Standardized Scope and Actual Scope	  									  */
/******************************************************************************/
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_1.smcl, replace smcl name(Table_1) 		
	
/* Regression inputs */
local DepVar = "scope audit_scope m_audit"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_1	
	
/******************************************************************************/
/* Table 2 (Table 3 in Breuer [2021]): 										  */
/* Standardized Scope and Ownership Concentration					 		  */
/******************************************************************************/
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_2.smcl, replace smcl name(Table_2) 		
		
/* Regression inputs */
local DepVar = "m_listed w_listed m_shareholders w_shareholders m_indep w_indep"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_2		
	
/******************************************************************************/
/* Table 3 (Table 4 in Breuer [2021]):										  */
/* Standardized Scope and Product-Market Competition						  */
/******************************************************************************/
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_3.smcl, replace smcl name(Table_3) 		
		
/* Regression inputs */
local DepVar = "m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_3	
	
/******************************************************************************/
/* Table 4 (Table 6 in Breuer [2021]):										  */
/* Standardized Scope, Revenue-Productivity Dispersion, and					  */
/* Size-Productivity Covariance												  */
/******************************************************************************/
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_4.smcl, replace smcl name(Table_4) 		
		
/* Regression inputs */
local DepVar = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cov_lp_e cov_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_w cov_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_4		
	
/******************************************************************************/
/* Table 5 (Table 6 in Breuer [2021]): 										  */
/* Standardized Scope and Revenue Productivity							 	  */
/******************************************************************************/
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_5.smcl, replace smcl name(Table_5) 		
		
/* Regression inputs */
local DepVar = "m_lp_e m_lp_w m_tfp_e m_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_5
/******************************************************************************/
/*** Title: 	Correction													***/
/*** Author:	M. Breuer													***/
/*** Year:		2025														***/
/*** Program:	Correction (Tests & Figures)								***/
/******************************************************************************/

/* Preliminaries */
clear all

/* Directory */
local directory = "H:\Project_Correction"
cd "`directory'\Data"

/******************************************************************************/
/* Above threshold comparison (example)										  */
/******************************************************************************/

/* Data */
cd "`directory'\Data\Simulation"
use MC, clear

/* Above thresholds */
gen above_jar = (at > 500000000*1.1)
gen above = (at > 500000000*0.003)

/* Sum */
sum above*

/******************************************************************************/
/* Scope Comparison															  */
/******************************************************************************/

/* Data */
cd "`directory'\Data\JAR"
use Data, clear

/* Rename JAR scopes and exchange rates */
local variables = "scope audit_scope mc_scope mc_audit exch_reporting exch_audit"
foreach var of varlist `variables' {

	/* Rename */
	rename `var' `var'_jar

}

/* Merge revised scopes */
cd "`directory'\Data"
merge 1:1 country industry year using Scope
drop if _merge == 2
drop _merge

/* Correlations */

	/* Raw */
	corr mc_scope mc_scope_jar
	corr mc_audit mc_audit_jar
	
	/* Residual */
	local varlist = "mc_scope mc_audit"
	foreach var of local varlist { 
	
		/* Residualizing */
		qui reghdfe `var', a(cy iy) res(res_`var')
		qui reghdfe `var'_jar, a(cy iy) res(res_`var'_jar)
		
	}
	
	corr res_mc_scope res_mc_scope_jar
	corr res_mc_audit res_mc_audit_jar
	
	
/* Graph: Differences by country */

	/* Directory */
	cd "`directory'\Output\Figures"
	
	/* Reporting */
		
		/* Preserve */
		preserve
				
			/* Difference */
			egen difference_reporting = mean(mc_scope - mc_scope_jar), by(country)

			/* Keep */
			keep difference_reporting country 
					
			/* Duplicates */
			duplicates drop country, force
					
			/* Sort */
			gsort -difference_reporting
					
			/* Encode */
			gen country_id = _n
								
			/* Value labels: country */
			label define country 1 "Hungary" 2 "Czech Republic" 3 "Slovakia" 4 "Norway" 5 "Lithuania" 6 "Denmark" 7 "Sweden" 8 "Bulgaria" 9 "Estonia" 10 "Slovenia" 11 "Croatia" 12 "Portugal" 13 "Romania" 14 "Germany" 15 "Luxembourg" 16 "Austria" 17 "Netherlands" 18 "Italy" 19 "Belgium" 20 "Finland" 21 "Spain" 22 "Ireland" 23 "United Kingdom" 24 "Greece" 25 "Poland" 26 "France"
			label values country_id country
							
			/* Graph */
			graph twoway ///
				(bar difference_reporting country_id, barwidth(0.8) color(black)) ///
					, graphregion(color(white)) plotregion(fcolor(white))	///
					legend(off) /// 
					xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26, valuelabel angle(90)) ///
					ytitle("Avg. Difference (Revised Scope - JAR Scope)") ///
					xtitle("") ///
					title("{bf:Panel A}" "Reporting Scope Differences", color(black)) ///					
					name(Figure_1a, replace)					
				
			/* Restore */
			restore	
			
	/* Auditing */
	
		/* Preserve */
		preserve
				
			/* Difference */
			egen difference_auditing = mean(mc_audit - mc_audit_jar), by(country)

			/* Keep */
			keep difference_auditing country 
					
			/* Duplicates */
			duplicates drop country, force
					
			/* Sort */
			gsort -difference_auditing
					
			/* Encode */
			gen country_id = _n
					
			/* Value labels: country */
			label define country 1 "Hungary" 2 "Estonia" 3 "Czech Republic" 4 "Denmark" 5 "Slovakia" 6 "Sweden" 7 "Lithuania" 8 "Bulgaria" 9 "Slovenia" 10 "Romania" 11 "Finland" 12 "Germany" 13 "Luxembourg" 14 "Austria" 15 "Netherlands" 16 "Italy" 17 "Belgium" 18 "Norway" 19 "Spain" 20 "Poland" 21 "Ireland" 22 "Greece" 23 "United Kingdom" 24 "France" 25 "Portugal" 26 "Croatia"
			label values country_id country
			
			/* Graph */
			graph twoway ///
				(bar difference_auditing country_id, barwidth(0.8) color(black)) ///
					, graphregion(color(white)) plotregion(fcolor(white))	///
					legend(off) /// 
					xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26, valuelabel angle(90)) ///
					ytitle("") ///
					xtitle("") ///
					title("{bf:Panel B}" "Auditing Scope Differences", color(black)) ///					
					name(Figure_1b, replace)					
				
			/* Restore */
			restore		
			
	/* Combined */
	graph combine Figure_1a Figure_1b ///
		, title("", color(black)) ///
		rows(1) cols(2) ///
		xsize(10) ysize(5) ///
		ycommon commonscheme altshrink ///
		graphregion(color(white)) plotregion(fcolor(white))	///
		name(Figure_1, replace) saving(Figure_1, replace)


/******************************************************************************/
/* Stacked Regression Tables: Differences									  */
/******************************************************************************/

/* JAR vs. Revised Scope */

	/* Data */
	cd "`directory'\Data\JAR"
	use Data, clear

	/* Duplicates drop */
	duplicates drop ci year, force

	/* Sample period */
	keep if year >= 2001 & year <= 2015

	/* Panel */
	xtset ci year

	/* Rename */
	foreach var of varlist mc_scope mc_audit scope audit_scope {

		/* Renaming JAR scopes */
		rename `var' `var'_jar

	}

	/* Merge */
	cd "`directory'\Data"
	merge 1:1 country industry year using Scope
	drop if _merge == 2
	drop _merge

	/* Observation ID */
	egen id = group(country industry year)

	/* Expanding */
	expand 2

	/* Observation / duplicate number */
	bys id: gen n = _n

	/* Generate scopes */

		/* JAR */
		replace mc_scope_jar = 0 if n == 2
		replace mc_audit_jar = 0 if n == 2
		
		/* Revised */
		replace mc_scope = 0 if n == 1
		replace mc_audit = 0 if n == 1
		
		/* Actual scopes */
		replace scope = scope_jar if n == 1
		replace audit_scope = audit_scope_jar if n == 1

	/* Delete stacked estimates (differences) */
	cd "`directory'\Data"
	cap rm Differences.dta
		
	/* Stacked regressions */

		/* Regression inputs */
		local DepVar = 	"scope audit_scope m_audit m_listed w_listed m_shareholders w_shareholders m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

		/* Regression */
		foreach y of varlist `DepVar' {
				
			/* Preserve */
			preserve
				
				/* Capture */
				capture noisily {
					
					/* Truncation (by group) */
					
						/* JAR */
						qui reghdfe `y' if (mc_scope_jar!=. & mc_audit_jar!=.) & n == 1, a(cy iy) residual(r_`y')
						qui reghdfe mc_scope_jar if `y'!=. & (mc_audit_jar!=.) & n == 1, a(cy iy) residual(r_mc_scope_jar)
						qui reghdfe mc_audit_jar if `y'!=. & (mc_scope_jar!=.) & n == 1, a(cy iy) residual(r_mc_audit_jar)
						
						qui sum r_`y' if n == 1, d
						qui replace `y' = . if (r_`y' < r(p1) | r_`y' > r(p99)) & n == 1

						qui sum r_mc_scope_jar if n == 1, d
						qui replace mc_scope = . if (r_mc_scope_jar < r(p1) | r_mc_scope_jar > r(p99)) & n == 1		
				
						qui sum r_mc_audit_jar if n == 1, d
						qui replace mc_audit = . if (r_mc_audit_jar < r(p1) | r_mc_audit_jar > r(p99)) & n == 1
						
						qui drop r_`y' r_mc_scope_jar r_mc_audit_jar
						
						/* Revision */
						qui reghdfe `y' if (mc_scope!=. & mc_audit!=.) & n == 2, a(cy iy) residual(r_`y')
						qui reghdfe mc_scope if `y'!=. & (mc_audit!=.) & n == 2, a(cy iy) residual(r_mc_scope)
						qui reghdfe mc_audit if `y'!=. & (mc_scope!=.) & n == 2, a(cy iy) residual(r_mc_audit)
						
						qui sum r_`y' if n == 2, d
						qui replace `y' = . if (r_`y' < r(p1) | r_`y' > r(p99)) & n == 2

						qui sum r_mc_scope if n == 2, d
						qui replace mc_scope = . if (r_mc_scope < r(p1) | r_mc_scope > r(p99)) & n == 2		
				
						qui sum r_mc_audit if n == 2, d
						qui replace mc_audit = . if (r_mc_audit < r(p1) | r_mc_audit > r(p99)) & n == 2					
					
						qui drop r_`y' r_mc_scope r_mc_audit
						
					/* Estimation */
					qui reghdfe `y' mc_scope_jar mc_audit_jar mc_scope mc_audit, a(cy#n iy#n) cluster(ci_cluster#n cy#n)
							
					/* Output */			
						
						/* Outcome */
						gen outcome = "`y'"			
						
						/* Linear combinations (differences) */
						qui lincom _b[mc_scope] - _b[mc_scope_jar]
						gen d_p_mc_scope = r(p)

						qui lincom _b[mc_audit] - _b[mc_audit_jar]
						gen d_p_mc_audit = r(p)				
						
						/* Keep */
						keep outcome d_*
						keep if _n == 1
						
						/* Merge */
						cd "`directory'\Data"
						cap append using Differences

						/* Number */
						cap gen n = _N
						replace n = _N if n == .					
						
						/* Save */
						save Differences, replace
						
				}
				
			/* Restore */
			restore
		}

/******************************************************************************/
/* Stacked Regression Tables: Summary of Significance Levels				  */
/******************************************************************************/

/* Data */
cd "`directory'\Data"
use Differences, clear

/* Table 1 (Table 2 in Breuer [2021]) */

	/* Outcomes */
	local DepVar = "scope audit_scope m_audit"

	/* Loop over outcomes  */
	foreach y of local DepVar {
		
		/* Sum */
		qui sum d_p_mc_scope if outcome == "`y'"
		local p_reporting = `r(mean)'
		
		qui sum d_p_mc_audit if outcome == "`y'"
		local p_auditing = `r(mean)'
		
		/* Stars */
		local star_reporting = ""
		if `p_reporting' < 0.1 {
			local star_reporting = "*"
		}
		if `p_reporting' < 0.05 {
			local star_reporting = "**"
		}
		if `p_reporting' < 0.01 {
			local star_reporting = "***"
		}

		local star_auditing = ""
		if `p_auditing' < 0.1 {
			local star_auditing = "*"
		}
		if `p_auditing' < 0.05 {
			local star_auditing = "**"
		}
		if `p_auditing' < 0.01 {
			local star_auditing = "***"
		}		
		
		/* Tabulate p-values for differences */
		di "p-Values for Differences in Estimates for Outcome: `y'"
		di "Standardized Reporting Scope:	`:display %9.2f `p_reporting'' (`star_reporting')"
		di "Standardized Auditing Scope: 	`:display %9.2f `p_auditing'' (`star_auditing')"
				
	}


/* Table 2 (Table 3 in Breuer [2021]) */

	/* Outcomes */
	local DepVar = "m_listed w_listed m_shareholders w_shareholders m_indep w_indep"

	/* Loop over outcomes  */
	foreach y of local DepVar {
		
		/* Sum */
		qui sum d_p_mc_scope if outcome == "`y'"
		local p_reporting = `r(mean)'
		
		qui sum d_p_mc_audit if outcome == "`y'"
		local p_auditing = `r(mean)'
		
		/* Stars */
		local star_reporting
		if `p_reporting' < 0.1 {
			local star_reporting = "*"
		}
		if `p_reporting' < 0.05 {
			local star_reporting = "**"
		}
		if `p_reporting' < 0.01 {
			local star_reporting = "***"
		}

		local star_auditing = ""
		if `p_auditing' < 0.1 {
			local star_auditing = "*"
		}
		if `p_auditing' < 0.05 {
			local star_auditing = "**"
		}
		if `p_auditing' < 0.01 {
			local star_auditing = "***"
		}		
		
		/* Tabulate p-values for differences */
		di "p-Values for Differences in Estimates for Outcome: `y'"
		di "Standardized Reporting Scope:	`:display %9.2f `p_reporting'' (`star_reporting')"
		di "Standardized Auditing Scope: 	`:display %9.2f `p_auditing'' (`star_auditing')"
				
	}
	

/* Table 3 (Table 4 in Breuer [2021]) */

	/* Outcomes */
	local DepVar = "m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"

	/* Loop over outcomes  */
	foreach y of local DepVar {
		
		/* Sum */
		qui sum d_p_mc_scope if outcome == "`y'"
		local p_reporting = `r(mean)'
		
		qui sum d_p_mc_audit if outcome == "`y'"
		local p_auditing = `r(mean)'
		
		/* Stars */
		local star_reporting
		if `p_reporting' < 0.1 {
			local star_reporting = "*"
		}
		if `p_reporting' < 0.05 {
			local star_reporting = "**"
		}
		if `p_reporting' < 0.01 {
			local star_reporting = "***"
		}

		local star_auditing = ""
		if `p_auditing' < 0.1 {
			local star_auditing = "*"
		}
		if `p_auditing' < 0.05 {
			local star_auditing = "**"
		}
		if `p_auditing' < 0.01 {
			local star_auditing = "***"
		}		
		
		/* Tabulate p-values for differences */
		di "p-Values for Differences in Estimates for Outcome: `y'"
		di "Standardized Reporting Scope:	`:display %9.2f `p_reporting'' (`star_reporting')"
		di "Standardized Auditing Scope: 	`:display %9.2f `p_auditing'' (`star_auditing')"
				
	}

	
/* Table 4 (Table 5 in Breuer [2021]) */

	/* Outcomes */
	local DepVar = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cov_lp_e cov_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_w cov_tfp_w"

	/* Loop over outcomes  */
	foreach y of local DepVar {
		
		/* Sum */
		qui sum d_p_mc_scope if outcome == "`y'"
		local p_reporting = `r(mean)'
		
		qui sum d_p_mc_audit if outcome == "`y'"
		local p_auditing = `r(mean)'
		
		/* Stars */
		local star_reporting = ""
		if `p_reporting' < 0.1 {
			local star_reporting = "*"
		}
		if `p_reporting' < 0.05 {
			local star_reporting = "**"
		}
		if `p_reporting' < 0.01 {
			local star_reporting = "***"
		}

		local star_auditing = ""		
		if `p_auditing' < 0.1 {
			local star_auditing = "*"
		}
		if `p_auditing' < 0.05 {
			local star_auditing = "**"
		}
		if `p_auditing' < 0.01 {
			local star_auditing = "***"
		}		
		
		/* Tabulate p-values for differences */
		di "p-Values for Differences in Estimates for Outcome: `y'"
		di "Standardized Reporting Scope:	`:display %9.2f `p_reporting'' (`star_reporting')"
		di "Standardized Auditing Scope: 	`:display %9.2f `p_auditing'' (`star_auditing')"
				
	}


/* Table 5 (Table 6 in Breuer [2021]) */

	/* Outcomes */
	local DepVar = "m_lp_e m_lp_w m_tfp_e m_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

	/* Loop over outcomes  */
	foreach y of local DepVar {
		
		/* Sum */
		qui sum d_p_mc_scope if outcome == "`y'"
		local p_reporting = `r(mean)'
		
		qui sum d_p_mc_audit if outcome == "`y'"
		local p_auditing = `r(mean)'
		
		/* Stars */
		local star_reporting = ""
		if `p_reporting' < 0.1 {
			local star_reporting = "*"
		}
		if `p_reporting' < 0.05 {
			local star_reporting = "**"
		}
		if `p_reporting' < 0.01 {
			local star_reporting = "***"
		}

		local star_auditing = ""
		if `p_auditing' < 0.1 {
			local star_auditing = "*"
		}
		if `p_auditing' < 0.05 {
			local star_auditing = "**"
		}
		if `p_auditing' < 0.01 {
			local star_auditing = "***"
		}		
		
		/* Tabulate p-values for differences */
		di "p-Values for Differences in Estimates for Outcome: `y'"
		di "Standardized Reporting Scope:	`:display %9.2f `p_reporting'' (`star_reporting')"
		di "Standardized Auditing Scope: 	`:display %9.2f `p_auditing'' (`star_auditing')"
				
	}	
/******************************************************************************/
/*** Title: 	Correction													***/
/*** Author:	M. Breuer													***/
/*** Year:		2025														***/
/*** Program:	Exchange Rates												***/
/******************************************************************************/

/* Preliminaries */
clear all
set more off

/* Seed */
set seed 1234

/* Directory */
local directory = "H:\Project_Correction"
cd "`directory'\Data"

/******************************************************************************/
/* (1) Historical Rates from Local to Euro (ECU/Euro Countries)				  */
*******************************************************************************/

/* Data */
cd "`directory'\Data\Eurostat"
import excel using Local_Euro_Historical.xlsx, clear firstrow

/* Cleaning */
drop BD

/* Destring */
destring year_*, force replace

/* Long format */
reshape long year_, i(currency) j(year)

/* Rename */
rename year_ exch_euro

/* Drop missing */
drop if exch_euro == .

/* Save */
cd "`directory'\Data"
save Exchange_Rates, replace


/******************************************************************************/
/* (2) Exchange Rates from Local to Euro (Non-ECU/Euro Countries)			  */
/******************************************************************************/

/* Data */
cd "`directory'\Data\Eurostat"
import excel using Local_Euro_Bilateral.xlsx, clear firstrow

/* Destring */
destring year_*, force replace

/* Long format */
reshape long year_, i(currency) j(year)

/* Rename */
rename year_ exch_euro

/* Drop missing */
drop if exch_euro == .

/* Append */
cd "`directory'\Data"
append using Exchange_Rates

/* Keep */
keep currency year exch_euro

/* Duplicates */
duplicates drop currency year, force

/* Save */
cd "`directory'\Data"
save Exchange_Rates, replace
/******************************************************************************/
/*** Title: 	Correction													***/
/*** Author:	M. Breuer													***/
/*** Year:		2025														***/
/*** Program:	MASTER Dofile												***/
/******************************************************************************/

/* Version */
version 15.1

/* Preliminaries */
clear all

/* Directory */
global directory = "H:\Project_Correction"
cd "$directory\Data"

/******************************************************************************/
/* Execute Dofiles in Sequence (creates log file)							  */
/******************************************************************************/

/* Open log */
cd "$directory\Output\Logs"
log using Correction, replace smcl name(Correction)

/* (1) Exchange rates (preparing Eurostat exchange inputs) */
cd "$directory\Dofiles"
do Exchange_Rates.do

/* (2) Regulation (prepares EUR rates and regulation information) */
cd "$directory\Dofiles"
do Regulation.do

/* (3) Scope (prepares revised scopes) */
cd "$directory\Dofiles"
do Scope.do

/* (4) Analyses (produces estimates) */
cd "$directory\Dofiles"
do Analyses.do

/* (5) Correction (produces correction figures and tests) */
cd "$directory\Dofiles"
do Correction.do

/* Close log */
cd "$directory\Output\Logs"
log close Correction
/******************************************************************************/
/*** Title: 	Correction													***/
/*** Author:	M. Breuer													***/
/*** Year:		2025														***/
/*** Program:	Regulations													***/
/******************************************************************************/

/* Preliminaries */
clear all
set more off

/* Seed */
set seed 1234

/* Directory */
local directory = "H:\Project_Correction"
cd "`directory'"

/******************************************************************************/
/* (1) Regulatory thresholds												  */
/******************************************************************************/

/* Data */
cd "`directory'\Data\JAR"
import delimited using Regulation.csv, delimiter(",") varnames(1) clear

/* Mode currency */
egen mode = mode(currency_reporting), by(country)
replace currency_reporting = mode if currency_reporting == ""
drop mode

egen mode = mode(currency_audit), by(country)
replace currency_audit = mode if currency_audit == ""
drop mode

/* Cleaning */
keep if year != . & year < 2016

/* Exchange rates (2015) */

	/* Reporting threshold currency */
	cd "`directory'\Data"
	rename currency_reporting currency
	merge m:m currency year using Exchange_Rates, keepusing(exch_euro)
	drop if _merge==2
	drop _merge
	rename exch_euro exch_reporting
	rename currency currency_reporting
	replace exch_reporting = 1 if currency_reporting == "EUR"
	
	/* Audit threshold currency */
	rename currency_audit currency
	merge m:m currency year using Exchange_Rates, keepusing(exch_euro)
	drop if _merge==2
	drop _merge	
	rename exch_euro exch_audit
	rename currency currency_audit		
	replace exch_audit = 1 if currency_audit == "EUR"

/* Keep threshold variables */
keep ///
	country ///
	year ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_reporting ///
	exch_audit ///
	currency_reporting ///
	currency_audit
	
/* Labeling */
label var country "Country"
label var year "Year"
label var at_reporting "Total Assets Threshold (Reporting Requirements)"
label var sales_reporting "Sales Threshold (Reporting Requirements)"
label var empl_reporting "Employees Threshold (Reporting Requirements)"
label var bs_preparation_abridged "Balance Sheet Preparation (Abridged)"
label var is_preparation_abridged "Income Statement Preparation (Abridged)"
label var notes_preparation_abridged "Notes Preparation (Abridged)"
label var bs_publication "Balance Sheet Publication"
label var is_publication "Income Statement Publication"
label var notes_publication "Notes Publication"
label var at_audit "Total Assets Threshold (Audit Requirements)"
label var sales_audit "Sales Threshold (Audit Requirements)"
label var empl_audit "Employees Threshold (Audit Requirements)"
label var currency_reporting "Currency (Reporting Requirements)"
label var currency_audit "Currency (Audit Requirements)"

/* Save */
cd "`directory'\Data"
save Regulation, replace
/******************************************************************************/
/*** Title: 	Correction													***/
/*** Author:	M. Breuer													***/
/*** Year:		2025														***/
/*** Program:	Scope														***/
/******************************************************************************/

/* Preliminaries */
clear all
set more off

/* Seed */
set seed 1234

/* Directory */
local directory = "H:\Project_Correction"
cd "`directory'\Data"

/******************************************************************************/
/* (1) Cross-country data													  */
/******************************************************************************/

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Scope_data.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Data */
	cd "`directory'\Data\Amadeus"
	use Data_`country', clear

	/* Keep relevant variables & observations */
	keep bvd_id_new toas empl empl_c opre turn year currency type industry country 
	drop if toas == . & empl == . & opre == . & turn == .
	
	/* Total assets */
	rename toas at
	
	/* Sales */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	drop opre turn
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1 
	
	/* Currency translation (to EURO; scope is free of monetary unit) */
		
		/* Filling missing */	
		egen firm_mode = mode(currency), by(id)
		egen country_mode = mode(currency), by(country year)
		replace currency = firm_mode if currency == "" | length(currency) > 3
		replace currency = country_mode if currency == "" | length(currency) > 3
		drop firm_mode country_mode
			
		/* Merge: account currency exchange rate */
		cd "`directory'\Data"
		merge m:m currency year using Exchange_Rates, keepusing(exch_euro)
		drop if _merge == 2
		drop _merge

		/* Conversion */
		local sizes = "at sales"
		foreach var of varlist `sizes' {
			
			/* Convert account currency to EUR */
			replace `var' = `var'/exch_euro if currency != "EUR"
		}
	
	/* Keep relevant variables */
	keep bvd_id country industry year at sales empl 
	
	/* Append */
	cd "`directory'\Data"
	cap append using Scope_data
	 
	/*Save */
	save Scope_data, replace
}
	

/******************************************************************************/
/* (2) Thresholds															  */
/******************************************************************************/

/* Data */
use Scope_data, clear

/* Merge: Thresholds */
merge m:1 country year using Regulation
keep if _merge==3
drop _merge

/* Threshold currency translation */
foreach var of varlist at_reporting sales_reporting {
	replace `var'=`var'/exch_reporting if currency_reporting!="EUR" & currency_reporting!=""
}

foreach var of varlist at_audit sales_audit {
	replace `var'=`var'/exch_audit if currency_audit!="EUR" & currency_audit!=""
}

drop exch_* currency_*

/* Reporting Requirements */
egen preparation=rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
replace preparation=3-preparation
label var preparation "Preparation Requirement Strength (Small)"

egen publication=rowtotal(bs_publication is_publication notes_publication), missing
label var publication "Publication Requirement Strength (Small)"


/******************************************************************************/
/* (3) Measured scope														  */
/******************************************************************************/

/* Reporting scope indicator */
gen regulation = .
label var regulation "Reporting Regulation (Indicator)"

	/* Three thresholds */
	replace regulation = ((at>at_reporting & at!=. & sales>sales_reporting & sales!=.) | (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) | (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.)) ///
		if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.)	
		
	/* Two thresholds */	
	replace regulation = (at>at_reporting & at!=. & sales>sales_reporting & sales!=.) ///
		if at_reporting != . & sales_reporting != . & empl_reporting == .
			
	replace regulation = (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting != . & sales_reporting == . & empl_reporting != .					
			
	replace regulation = (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting == . & sales_reporting != . & empl_reporting != .		
	
	/* One threshold  */
	replace regulation = (at>at_reporting & at!=.) ///
		if (at_reporting != . & sales_reporting == . & empl_reporting == .)	& regulation == .
		
	replace regulation = (sales>sales_reporting & sales!=.) ///
		if (at_reporting == . & sales_reporting != . & empl_reporting == .)	& regulation == .		

	replace regulation = (empl>empl_reporting & empl!=.) ///
		if (at_reporting == . & sales_reporting == . & empl_reporting != .)	& regulation == .

/* Audit scope indicator */
gen audit = .
label var audit "Audit Regulation (Indicator)"

	/* Three thresholds */
	replace audit = ((at>at_audit & at!=. & sales>sales_audit & sales!=.) | (at>at_audit & at!=. & empl>empl_audit & empl!=.) | (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.)) ///
		if (at_audit!=. & sales_audit!=. & empl_audit!=.)

	/* Two thresholds */	
	replace audit = (at>at_audit & at!=. & sales>sales_audit & sales!=.) ///
		if at_audit != . & sales_audit != . & empl_audit == .
			
	replace audit = (at>at_audit & at!=. & empl>empl_audit & empl!=.) ///
		if at_audit != . & sales_audit == . & empl_audit != .					
			
	replace audit = (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.) ///
		if at_audit == . & sales_audit != . & empl_audit != .		
	
	/* One threshold  */
	replace audit = (at>at_audit & at!=.) ///
		if (at_audit != . & sales_audit == . & empl_audit == .)	& audit == .
		
	replace audit = (sales>sales_audit & sales!=.) ///
		if (at_audit == . & sales_audit != . & empl_audit == .)	& audit == .		

	replace audit = (empl>empl_audit & empl!=.) ///
		if (at_audit == . & sales_audit == . & empl_audit != .)	& audit == .
		
/* Country-industry-level scope */
	
	/* Equally weighted */
		
		/* Reporting */
		egen scope = mean(regulation), by(country industry year)
		label var scope "Scope (Country-Industry-Year)"
	 
		/* Audit */
		egen audit_scope = mean(audit), by(country industry year)
		label var audit_scope "Audit Scope (Country-Industry-Year)"
		
/* Preserve */
preserve

	/* Duplicates */
	duplicates drop country industry year, force
		
	/* Keep */
	keep country industry year scope* audit_scope* at_reporting at_* sales_* empl_*
	
	/* Save */
	save Scope, replace
	
/* Restore */
restore


/******************************************************************************/
/* (4) Simulated scope														  */
/******************************************************************************/

/* Sample period restriction */
keep if year >= 2007

/* Keep full disclosure countries */
keep if bs_publication == 1 & is_publication == 1 
drop bs_* is_* notes_*

/* Drop irrelevant data */
keep industry at empl sales

/* Delete prior Monte Carlo simulation */
capture {
	cd "`directory'\Data\Simulation"
	local datafiles: dir "`directory'\Data\Simulation" files "MC*.dta"
	foreach datafile of local datafiles {
			rm `datafile'
	}
}
	
/* Monte Carlo/Multivariate distribution */

	/* Logarithm (wse +1 adjustment in regulatory thresholds) */
	gen ln_at=ln(at)
	gen ln_sales=ln(sales+1)
	gen ln_empl=ln(empl+1)
 
	/* Draws (multivariate log-normal following Gibrat's Law) [growth rate independent of absolute size; see JEL article in IO] */
	gen n_at = (at != .)
	gen n_sa = (sales != .)
	gen n_em = (empl != .)
	egen count = total(n_at*n_sa*n_em), by(industry) missing
	egen group = group(industry) if count >= 200
	
	/* Loop through industries */
	sum group
	forvalues i=1/`r(max)' {
		
		/* Moments */
		foreach var of varlist at sales empl {
			sum ln_`var' if group==`i'
			local `var'_mean=`r(mean)'
			local `var'_sd=`r(sd)'
				
			foreach var2 of varlist at sales empl {
				corr ln_`var' ln_`var2' if group==`i'
				local `var'_`var2'=`r(rho)'
			}
		}
			
		/* Monte Carlo (use correlations: scale free; alleviates upward bias from missing variables in lower tail) */
		preserve
		
			/* Matrices */
			matrix mean_vector=(`at_mean' \ `sales_mean' \ `empl_mean')
			matrix sd_vector=(`at_sd' \ `sales_sd' \ `empl_sd')
			matrix corr_matrix=(1, `at_sales', `at_empl' \ `sales_at', 1, `sales_empl' \ `empl_at', `empl_sales', 1)
		
			/* MV-normal draw */
			set seed 1234
			drawnorm at sales empl, n(100000) means(mean_vector) sds(sd_vector) corr(corr_matrix) clear
			
			/* Log variables */
			gen y = sales
			gen k = at // approximation of fias
			gen l = empl
			
			/* Exponentiate (including adjustments -1) */
			replace at = exp(at)
			replace sales = exp(sales)-1
			replace empl = exp(empl)-1							
				
			/* Group ID */
			gen group=`i'
			
			/* Saving */
			cd "`directory'\Data\Simulation"
			save MC_industry_`i', replace
			
		restore
	}
	
	/* Save group-industry-correspondence */
	keep if group!=.
	duplicates drop group, force
	keep industry group
	save Correspondence, replace
	
/* Data */	
cd "`directory'\Data"
use Scope, clear

/* Monte Carlo simulation */
				
	/* MC consolidation */
	preserve
		clear all
		cd "`directory'\Data\Simulation"
		! dir MC_industry_*.dta /a-d /b >"`directory'\Data\Simulation\filelist.txt", replace

		file open myfile using "`directory'\Data\Simulation\filelist.txt", read

		file read myfile line
		use `line'
		save MC, replace

		file read myfile line
		while r(eof)==0 { /* while you're not at the end of the file */
			append using `line'
			file read myfile line
		}
		file close myfile
		
		/* Merge Correspondence */
		merge m:1 group using Correspondence
		keep if _merge==3
		drop _merge group
		
		/* Saving */
		save MC, replace
		
	restore

/* Country-industry looping: Monte Carlo */
egen cy_id = group(country year) if at_reporting != . | sales_reporting != . | empl_reporting != . | at_audit != . | sales_audit != . | empl_audit != .
sum cy_id
forvalues i=1/`r(max)' {
	
	/* Reset all threshold globals */
	global at_rep = .
	global sa_rep = .
	global em_rep = .
	global at_au = .
	global sa_au = .
	global em_au = .
	
	/* Reporting */
	sum at_reporting if cy_id==`i'
	cap global at_rep=`r(mean)'
	
	sum sales_reporting if cy_id==`i'
	cap global sa_rep=`r(mean)'
	
	sum empl_reporting if cy_id==`i'
	cap global em_rep=`r(mean)'
	
	/* Audit */
	sum at_audit if cy_id==`i'
	cap global at_au=`r(mean)'
	
	sum sales_audit if cy_id==`i'
	cap global sa_au=`r(mean)'
	
	sum empl_audit if cy_id==`i'
	cap global em_au=`r(mean)'
	
	preserve

		/* MC Sample */
		cd "`directory'\Data\Simulation"
		use MC, clear
			
		/* Thresholds */

			/* Actual */	
				
				/* Reporting */
				gen rep = .
				
					/* Three thresholds */
					cap replace rep = ((at>${at_rep} & sales>${sa_rep}) | (at>${at_rep} & empl>${em_rep}) | (sales>${sa_rep} & empl>${em_rep})) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} != .

					/* Two thresholds */
					cap replace rep = (at>${at_rep} & sales>${sa_rep}) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} == .

					cap replace rep = (at>${at_rep} & empl>${em_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} != .						

					cap replace rep = (sales>${sa_rep} & empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} != .	
						
					/* One threshold */
					cap replace rep = (at>${at_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} == .					
					
					cap replace rep = (sales>${sa_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} == .	

					cap replace rep = (empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} == . & ${em_rep} != .	
						
				/* Auditing */
				gen aud = .
				
					/* Three thresholds */
					cap replace aud = ((at>${at_au} & sales>${sa_au}) | (at>${at_au} & empl>${em_au}) | (sales>${sa_au} & empl>${em_au})) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} != .

					/* Two thresholds */
					cap replace aud = (at>${at_au} & sales>${sa_au}) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} == .

					cap replace aud = (at>${at_au} & empl>${em_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} != .						

					cap replace aud = (sales>${sa_au} & empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} != .	
						
					/* One threshold */
					cap replace aud = (at>${at_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} == .					
					
					cap replace aud = (sales>${sa_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} == .	

					cap replace aud = (empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} == . & ${em_au} != .	
			
		/* Equally weighted */
		
			/* Actual */
			
				/* Reporting */	
				egen mc_scope = mean(rep), by(industry)
			
				/* Audit */
				egen mc_audit = mean(aud), by(industry)
			
		/* Relevant Observations */
		keep industry mc_*
		duplicates drop industry, force
		
		/* Identifier */
		gen cy_id = `i'			
			
		/* Saving */
		save MC_final_`i', replace
	
	restore
}

/* Merging */

	/* Monte Carlo (Industry) */
	sum cy_id, d
	forvalues i=1/`r(max)' {
		cd "`directory'\Data\Simulation\"
		merge m:m cy_id industry using MC_final_`i', update
		drop if _merge==2
		drop _merge
	}

	
/******************************************************************************/
/* (5) Cleaning, timing, and saving											  */
/******************************************************************************/

/* Duplicates */
keep country industry year scope* audit_scope* mc_*
duplicates drop country industry year, force

/* Time (shifting back 1 year) */
replace year = year + 1

/* Labeling */
label var country "Country"
label var industry "NACE Industry (4-Digit)"
label var year "Year" 
label var mc_scope "Scope (MC)"
label var mc_audit "Audit Scope (MC)"

/* Save */
cd "`directory'\Data"
save Scope, replace
