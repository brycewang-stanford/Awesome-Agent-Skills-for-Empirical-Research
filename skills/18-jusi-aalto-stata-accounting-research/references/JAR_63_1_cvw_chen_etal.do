
/*Step 2 cont'd*/
/* The code below fills in fqe for all periods based on known fqe in the period when fqe is not missing */

use ".../Data/financialdata2_fqecode2.dta", clear

sort SNLid code
by SNLid: replace fcode = fcode[_n-1]+1 if fcode == .

gen negcode = -code
sort SNLid negcode
by SNLid: replace fcode = fcode[_n-1]-1 if fcode == .

br SNLid year quarter fcode code
mdesc fcode
sort SNLid fcode fqe code fv_financialassets
save ".../Data/financialdata2_fqecode3.dta", replace


/*========================================================================================================
                                                                          
        ARTICLE: The decision relevance of loan fair values for depositors                      
        AUTHORS: Qi Chen, Rahul Vashishtha, Shuyan Wang              
        JOURNAL OF ACCOUNTING RESEARCH 

 		The code below processes several SNL variables with missing values and 
		constructs a smaller dataset with key variables needed for subsequent analyses.

 =========================================================================================================*/


global runpath ".../Code"
cd "$runpath"

use ".../Data/ds_larger.dta", clear

/*** Process missing fv_financialassets and cv_financialassets data ***/
/*** For quarters missing fv_financialassets and cv_financialassets, assume the variables' values equal year-end values ***/
sort group_id year negcode 
by group_id year: replace fv_financialassets_mil = fv_financialassets_mil[_n-1] if fv_financialassets_mil == .
by group_id year: replace cv_financialassets_mil = cv_financialassets_mil[_n-1] if cv_financialassets_mil == .

/*** Process missing fv_netloans and cv_netloans data ***/
/*** For quarters missing fv_netloans and cv_netloans, assume the variables' values equal year-end values ***/
replace fv_netloans = . if fv_netloans == 0
replace cv_netloans = . if cv_netloans == 0
by group_id year: replace fv_netloans = fv_netloans[_n-1] if fv_netloans == .
by group_id year: replace cv_netloans = cv_netloans[_n-1] if cv_netloans == .
gen snl_totdep_mil = snl_totdep/1000

/*** keep variables needed***/
keep group_id SNLid	date BHC_number Federal_Reserve_ID	assets_mil	fv_financialassets_* loans_mil	realestateloans_mil	realestateloans_comm_mil unusedcom_unscaled	totdep	insureddep_mil	wholesalefund_mil	equity_mil	ebllp_mil llp_mil	netincome_mil	writeoff_mil npl_mil catfat_mil	gta_mil	LC_A_mil	LC_L_mil	intexp_mil	ltdeposits_mil	coreintexp_mil	coredeposits_mil FF_O mktret fvglfa_taxadj  cv_financialassets_*  fvfreq fvglfa_a awgt_loan_ORG0  RCFD3814 RCFD3816 RCFD3817 RCFD3818 RCFD6550 RCFD3411 fvglfa_netloans  snl_totdep_mil state_count_SOD STALPBR  fv_netloans cash trading_secs afs_secs fvglfa_adjsca_taxadj

save ds_small.dta, replace




/*========================================================================================================
                                                                          
        ARTICLE: The decision relevance of loan fair values for depositors                      
        AUTHORS: Qi Chen, Rahul Vashishtha, Shuyan Wang              
        JOURNAL OF ACCOUNTING RESEARCH 

 		The code below merges the main dataset with the SOD data and aggregate deposit data and constructs
		additional variables used for regression analyses.

 =========================================================================================================*/


   local c_date = c(current_date) 
   global today = subinstr("`c_date'", " ", "", .)  
   
*** Set directory    	
	global runpath ".../Code"
	cd "$runpath"

*************************************************************************************************
************************** Prepare SOD data and aggregate deposit data **************************
*************************************************************************************************		
// Prepare SOD dataset constructed in "1d. Process and construct SOD data.sas". Calculate weighted average aggregate deposit growth in a bank's states of operations.
	use ".../Bank_States_06032023.dta", clear
	rename YEAR year
	bys bankid year: egen all_state_dep = sum(state_dep)
	bys bankid year: egen bank_dep = sum(bk_state_dep)
	gen bk_state_share = bk_state_dep/bank_dep
	gen dep_gr_wt = dep_gr * bk_state_share
	bys bankid year: egen dep_gr_mean = sum(dep_gr_wt)
	replace dep_gr_mean = . if dep_gr_mean == 0
	
	*Generate state-qtr fixed effects
	tab STALPBR, gen(state)
	forvalues x = 1/59 {
	bys bankid year: egen state_`x' = max(state`x')
	drop state`x' 
	}

	duplicates drop bankid year, force
	save bank_states_FE, replace
	
// Prepare aggregate deposit dataset downloaded from St. Louis Fed website. Calcualte economy-wide aggregate deposit growth. 
	import delimited ".../Data/DPSACBM027NBOG.csv", clear
	gen date2 = date(date, "MDY")
	format date2 %td
	gen qtr=qofd(date2)
	format qtr %tq
	gen year_month = mofd(date2)
	format year_month %tm

	tsset year_month
	gen aggdep = f.dpsacbm027nbog
	gen month = month(date2)
	keep if inlist(month, 3, 6, 9, 12)
	
	tsset qtr
	gen agg_dep_gr = (f2.aggdep - aggdep) / aggdep * 200
	keep qtr aggdep agg_dep_gr
	save aggdep, replace
	

*****************************************************************************************************
********************* Merge Main dataset with SOD data and aggregate deposit data *******************
*****************************************************************************************************		
	use "$runpath/ds_small.dta", clear 

	tostring date, gen(datevar)
		 gen date2 = date(datevar, "YMD")
	  format date2 %td
		drop date
	  rename date2 date
		 gen qtr=qofd(date)
	  format qtr %tq
		sort qtr

	   gen year=yofd(date)
	   format year %ty
		
		xtset group_id qtr
		sort group_id qtr
		gen bankid = BHC_number
		replace bankid = Federal_Reserve_ID if BHC_number == .
		
// Merge with SOD bank-state dataset
		gen quarter = quarter(date)
		capture drop _merge
		joinby bankid year using bank_states_FE.dta, unmatched(master) 
		drop _merge
		replace dep_gr_mean = (dep_gr_mean + l.dep_gr_mean) / 2 if quarter == 1
		
		forvalues x = 1/59 {
		egen stateq`x' = group(state_`x' qtr)
	    drop state_`x'
}
		
// Merge with aggregate depsosit dataset
		joinby qtr using aggdep.dta, unmatched(master) 
		drop _merge
		
		
********************************************************************************
********************* Compute and process additional variables *****************
********************************************************************************

//Deposit related variables
		gen uninsured = totdep -insureddep_mil
		gen ddep_t	= 100*2*(F2.totdep - totdep)/assets_mil
		gen ddep_i	= 100*2*(F2.insureddep_mil - insureddep_mil)/assets_mil
		gen ddep_u  = 100*2*(F2.uninsured - uninsured)/assets_mil
		gen ddep_i_3mo	= 100*2*(F.insureddep_mil - insureddep_mil)/assets_mil
		gen ddep_u_3mo  = 100*2*(F.uninsured - uninsured)/assets_mil
		gen pct_uninsured = uninsured/totdep 
		gen diff_dep = totdep - snl_totdep_mil
		gen diff_dep_scaled = diff_dep/snl_totdep_mil
		
//Bank performance variables
		gen roe = 100*4*netincome_mil/L1.equity_mil
		gen woff2equity =	100*4*writeoff_mil/L1.equity_mil
		gen dwoff2equity =	100*4*(writeoff_mil - L1.writeoff_mil)/L1.equity_mil
		gen dnpl2equity = 100*4*(npl_mil-L1.npl_mil)/L1.equity_mil
		gen fut_dwoff2equity = f.dwoff2equity
		gen llp2equity  =   100*4*llp_mil/L1.equity_mil
		gen core_rate	= 100*4*coreintexp_mil/L1.coredeposits_mil   
		gen lt_rate		= 100*4*intexp_mil/L1.ltdeposits_mil     
		gen avg_rate	= 100*4*(coreintexp_mil+intexp_mil)/(L1.coredeposits_mil+L1.ltdeposits_mil) 
		gen avg_rate_c = 100*4*(F1.coreintexp_mil+coreintexp_mil+F1.intexp_mil+intexp_mil)/(coredeposits_mil+ltdeposits_mil+F1.coredeposits_mil+F1.ltdeposits_mil)   
		gen core_rate_c	= 100*4*(F1.coreintexp_mil+coreintexp_mil)/(coredeposits_mil+F1.coredeposits_mil)   
		gen lt_rate_c	= 100*4*(F1.intexp_mil+intexp_mil)/(ltdeposits_mil+F1.ltdeposits_mil)  
		rangestat (sd) sd_roe = roe (sd) sd_woff = woff2equity , interval (qtr -11 0)  by(group_id)
		gen fvgl  = fvglfa_taxadj*4  
		gen fvgl_adjscal2 = fvglfa_adjsca_taxadj*4
		
//Bank characteristics variables
		gen ln_asset	= ln(assets_mil)
		gen loan2asset 	= loans_mil/assets_mil
		gen real2asset 	= realestateloans_mil/assets_mil    
		gen comm2real 	= realestateloans_comm_mil/realestateloans_mil
		gen unused2loan = unusedcom_unscaled/(loans_mil+unusedcom_unscaled)
		gen book2asset	  = equity_mil/assets_mil
		gen whole2asset   = wholesalefund_mil/assets_mil
		gen catfat 			= catfat_mil/gta_mil
		gen catfat_asset	= LC_A_mil/gta_mil
		gen catfat_liab		= LC_L_mil/gta_mil
		gen assetgr = (assets_mil - L1.assets_mil)/L1.assets_mil
		replace cash = 0 if cash == .
		replace trading_secs = 0 if trading_secs == .
		replace afs_secs = 0 if afs_secs == .
		gen fv2cv_netloans_adj3 = (fv_financialassets_mil - (cash + trading_secs + afs_secs)/1000) / (cv_financialassets_mil - (cash + trading_secs + afs_secs)/1000)

//Future performance variables
		gen fut4_roe	=	(F1.roe+F2.roe+F3.roe+F4.roe)/4
		gen fut4_dnpl	=	(F1.dnpl2equity+F2.dnpl2equity+F3.dnpl2equity+F4.dnpl2equity)/4
		gen fut4_woff	=	(F1.woff2equity+F2.woff2equity+F3.woff2equity+F4.woff2equity)/4
		gen fut4_llp	=	(F1.llp2equity+F2.llp2equity+F3.llp2equity+F4.llp2equity)/4
		gen fut5_8_roe	=	(F5.roe+F6.roe+F7.roe+F8.roe)/4
		gen fut5_8_dnpl	=	(F5.dnpl2equity+F6.dnpl2equity+F7.dnpl2equity+F8.dnpl2equity)/4
		gen fut5_8_woff	=	(F5.woff2equity+F6.woff2equity+F7.woff2equity+F8.woff2equity)/4
		gen fut5_8_llp	=	(F5.llp2equity+F6.llp2equity+F7.llp2equity+F8.llp2equity)/4
		gen fut9_12_roe	=	(F9.roe+F10.roe+F11.roe+F12.roe)/4
		gen fut9_12_dnpl	=	(F9.dnpl2equity+F10.dnpl2equity+F11.dnpl2equity+F12.dnpl2equity)/4
		gen fut9_12_woff	=	(F9.woff2equity+F10.woff2equity+F11.woff2equity+F12.woff2equity)/4
		gen fut9_12_llp	=	(F9.llp2equity+F10.llp2equity+F11.llp2equity+F12.llp2equity)/4
		gen fut4_core_rate = (F1.core_rate+F2.core_rate+F3.core_rate+F4.core_rate)/4
		gen fut4_lt_rate   = (F1.lt_rate+F2.lt_rate+F3.lt_rate+F4.lt_rate)/4
		gen fut4_avg_rate  = (F1.avg_rate+F2.avg_rate+F3.avg_rate+F4.avg_rate)/4
		foreach i in fut4_core_rate fut4_lt_rate fut4_avg_rate {
		gen ln_`i' = ln(`i') 
		}


//Further adjustment to FVGL variables (For a few bank years when a bank transitions to quarterly reporting of fair values, the bank may disclose fair values for only two or three quarters out of four quarters. This step adjusts FVGL for years with one or two missing quarters of fair value data. Results are largely unchanged without this adjustment)

		//Calculate FVGL (Stata variable name: fvgl1) when fair value data are available on a quarterly basis
		gen dfv2equity1	= 	100*4*(fv_financialassets_mil-L1.fv_financialassets_mil) / L1.equity_mil
		gen dcv2equity1	=	100*4*(cv_financialassets_mil-L1.cv_financialassets_mil) / L1.equity_mil
		gen fvgl1 = (dfv2equity1 - dcv2equity1)
		replace fvgl1 = (dfv2equity1 - dcv2equity1)*0.65 if year(date)<=2017
		replace fvgl1 = (dfv2equity1 - dcv2equity1)*0.79 if year(date)>2017
		 
		//Calculate FVGL with an alternative scaler used for Table OA7 (Stata variable name: fvgl1_adjsca) when fair value data are available on a quarterly basis 
		gen dfv2equity1_adjsca	= 	100*4*(fv_financialassets_mil-L1.fv_financialassets_mil) / (L1.equity_mil + L1.fv_financialassets_mil - L1.cv_financialassets_mil)
		gen dcv2equity1_adjsca	=	100*4*(cv_financialassets_mil-L1.cv_financialassets_mil) / (L1.equity_mil + L1.fv_financialassets_mil - L1.cv_financialassets_mil)
		gen fvgl1_adjsca = (dfv2equity1_adjsca - dcv2equity1_adjsca)
		replace fvgl1_adjsca = (dfv2equity1_adjsca - dcv2equity1_adjsca)*0.65 if year(date)<=2017
		replace fvgl1_adjsca = (dfv2equity1_adjsca - dcv2equity1_adjsca)*0.79 if year(date)>2017
		 
		//Identify the observations with only annual fair value data available; alternatively, we can create the variable annualfiler using the variable fvfreq. Differences between these two approaches are negligible
		sort group_id year
		by group_id year: egen avgfv_yr=mean(fv_financialassets_mil)
		gen annualfiler = 0
		replace annualfiler = 1 if abs(avgfv_yr - fv_financialassets_mil) <=0.1   
		
		//Calculate FVGL (Stata variable name: fvgl2) and FVGL with an alternative scaler (Stata variable name: fvgl2_adjsca) when fair value data are available annually as identified above
		preserve
		drop if annualfiler   == 0
		keep if quarter(date) == 4
		xtset group_id year
		sort group_id year
		gen dfv2equity2	= 	100*(fv_financialassets_mil-L1.fv_financialassets_mil) / L1.equity_mil
		gen dcv2equity2	=	100*(cv_financialassets_mil-L1.cv_financialassets_mil) / L1.equity_mil
		gen fvgl2 = (dfv2equity2 - dcv2equity2)
	  replace fvgl2 = (dfv2equity2 - dcv2equity2)*0.65 if year(date)<=2017
	  replace fvgl2 = (dfv2equity2 - dcv2equity2)*0.79 if year(date)>2017
	  
		gen dfv2equity2_adjsca	= 	100*(fv_financialassets_mil-L1.fv_financialassets_mil) / (L1.equity_mil + L1.fv_financialassets_mil - L1.cv_financialassets_mil)
		gen dcv2equity2_adjsca	=	100*(cv_financialassets_mil-L1.cv_financialassets_mil) / (L1.equity_mil + L1.fv_financialassets_mil - L1.cv_financialassets_mil)
		gen fvgl2_adjsca = (dfv2equity2_adjsca - dcv2equity2_adjsca)
		replace fvgl2_adjsca = (dfv2equity2_adjsca - dcv2equity2_adjsca)*0.65 if year(date)<=2017
		replace fvgl2_adjsca = (dfv2equity2_adjsca - dcv2equity2_adjsca)*0.79 if year(date)>2017

		keep group_id year fvgl2 dfv2equity2 dcv2equity2 dfv2equity2_adjsca dcv2equity2_adjsca fvgl2_adjsca
		save FV_rawAnnualFiler.dta, replace
		restore 

		merge m:1 group_id year using FV_rawAnnualFiler.dta
		gen fvgl_a = fvgl1 
		replace fvgl_a = fvgl2 if annualfiler == 1
		gen fvgl_a_adjsca = fvgl1_adjsca 
		replace fvgl_a_adjsca = fvgl2_adjsca if annualfiler == 1

		 //Identify observations for which SNL fair value data are available (i.e., dup == 0)
		 sort group_id year fv_financialassets_mil
		 quietly by group_id year fv_financialassets_mil:  gen dup = cond(_N==1,0,_n)
		 egen max = max(dup), by(group_id year)
		 gen dupgr = 1
		 replace dupgr = 0 if dup == 0 
		 sort group_id year qtr
		 
		 //For quarters where fair value data are available, use quarterly FVGL calculated previously
		 replace fvgl =  fvgl_a if  (fvfreq == 2 | fvfreq == 3) & dup == 0 
		 
		 //For quarters missing either beginning or ending fair values, use FVGL calculated using fair values available in the closest quarters (assume fair values change at a constant rate through those quarters)
		 gen fvgl_a_2 = fvgl_a/max
		 egen fvgl_a_tot = total(fvgl_a_2), by(group_id year dupgr) 
		 replace fvgl = fvgl_a_tot if (fvfreq == 2 | fvfreq == 3) & dupgr == 1 & fvgl_a_tot ~= 0   
		 
		 //Adjusted FVGL with an alternative scaler: For quarters where fair value data are available, use quarterly FVGL calculated previously
		 replace fvgl_adjscal2 =  fvgl_a_adjsca if  (fvfreq == 2 | fvfreq == 3) & dup == 0  
		 
		 //Adjusted FVGL with an alternative scaler: For quarters missing either beginning or ending fair values, use FVGL calculated using fair values available in the closest quarters (assume fair values change at a constant rate through those quarters)
		 gen fvgl_a_2_adjsca = fvgl_a_adjsca/max
		 egen fvgl_a_tot_adjsca = total(fvgl_a_2_adjsca), by(group_id year dupgr) 
		 replace fvgl_adjscal2 = fvgl_a_tot_adjsca if (fvfreq == 2 | fvfreq == 3) & dupgr == 1 & fvgl_a_tot_adjsca ~= 0  
		 
		 sort group_id qtr
		 rename FF_O fedrate
		 gen mktret_c = F1.mktret+F2.mktret     
		 gen fedrate_c  = F1.fedrate+F2.fedrate    
	 
//FVGL computed using loan fair values and book values; used for robustness check
		gen fvgl_loans = fvglfa_netloans*4
		replace fvgl_loans = . if year <2006
		
	
/**Sample Cleaning**/
	keep if ddep_u*ddep_i*fvgl*roe*avg_rate*sd_woff*ln_asset*loan2asset*real2asset*comm2real*unused2loan*book2asset*fut4_roe ~= . 
	drop if assetgr > 0.1 
	*drop if diff_dep_scaled < -0.02 | diff_dep_scaled > 0.02 //apply this criteria to generate FV_clean_OA4.dta used for Table OA4


/**Winsorization**/	
	local bankdep ddep_u ddep_i ddep_t  pct_uninsured  ddep_u_3mo ddep_i_3mo
	univar `bankdep' 
	winsor2 `bankdep', replace

	local bankchara sd_roe sd_woff  book2asset whole2asset ln_asset real2asset unused2loan 
	univar `bankchara' 
	winsor2 `bankchara' , replace
	
	local bankrate lt_rate core_rate avg_rate avg_rate_c core_rate_c lt_rate_c fut4_*_rate
	univar `bankrate' 
	winsor2 `bankrate', replace
	
	local bankperf fvgl  fvgl_a roe llp2equity  woff2equity  dnpl2equity  fvgl_loans dwoff2equity  fv2cv fv2cv_*  fvgl_adjscal fvgl_adjscal2 
	univar `bankperf' 
	winsor2 `bankperf', replace
	
	local catfatvar catfat catfat_asset catfat_liab
	univar `catfatvar' 
	winsor2 `catfatvar', replace	

	local fut4_perf fut4_roe fut4_woff fut4_core_rate fut4_lt_rate fut4_avg_rate ln_fut4_core_rate ln_fut4_lt_rate ln_fut4_avg_rate fut4_dnpl  fut4_llp fut_dwoff2equity 
	univar `fut4_perf'
	winsor2 `fut4_perf', replace
	
	local fut5_8_perf fut5_8_roe fut5_8_woff fut5_8_dnpl fut5_8_llp
	univar `fut5_8_perf'
	winsor2 `fut5_8_perf', replace
	
	local fut9_12_perf fut9_12_roe fut9_12_woff fut9_12_dnpl fut9_12_llp
	univar `fut9_12_perf'
	winsor2 `fut9_12_perf', replace
	
	local loanhc awgt_loan_ORG0 
	univar `loanhc'
	winsor2 `loanhc', replace
	
	winsor2  agg_dep_gr dep_gr_mean, replace

sort group_id qtr

save FV_clean_main.dta, replace 
*save FV_clean_OA4.dta, replace     //Save the dataset to be used for Table OA4






/*========================================================================================================
                                                                          
        ARTICLE: The decision relevance of loan fair values for depositors                      
        AUTHORS: Qi Chen, Rahul Vashishtha, Shuyan Wang              
        JOURNAL OF ACCOUNTING RESEARCH 

 		The code below generates tables in the main text.

 =========================================================================================================*/

*Setting macro for date
local c_date = c(current_date) 
global today = subinstr("`c_date'", " ", "", .)  

global runpath ".../Code"
cd "$runpath"

*open dataset
use FV_clean_main.dta, clear 
	
**************************************************
*Defining useful macro variables
**************************************************
global bankchara "avg_rate_c sd_woff book2asset whole2asset real2asset ln_asset unused2loan"
global bankcharanorate "sd_woff book2asset whole2asset real2asset ln_asset unused2loan"
global macrocon "fedrate fedrate_c mktret mktret_c "  
global cbankchara "c.avg_rate_c c.sd_woff c.book2asset c.whole2asset c.real2asset c.ln_asset c.unused2loan"
global futfunda "fut4_woff fut4_roe fut5_8_woff fut9_12_woff fut5_8_roe fut9_12_roe fut4_llp fut5_8_llp fut9_12_llp fut4_dnpl fut5_8_dnpl fut9_12_dnpl"

********************************************************************
**dropping observations where control variables are missing
********************************************************************
foreach x in $bankchara $macrocon {
drop if `x'==.
}

**********************************************************
***Descritpives: T1 with 2 panels
**********************************************************
************************************************	
/*** Table 1 Panel A Descriptive Statistics ***/
************************************************	

cap erase T1AB_$today.xlsx

//Summary Statistics
local vars ddep_u fvgl roe avg_rate_c sd_woff book2asset whole2asset real2asset ln_asset unused2loan fedrate agg_dep_gr catfat_asset pct_uninsured  ddep_i awgt_loan_ORG0

tabstat `vars', stats(n mean sd p10 p25 p50 p75 p90) save
return list
matlist r(StatTotal)
matrix results = r(StatTotal)'
matlist results
putexcel set T1AB_$today.xlsx, sheet(desc) modify
putexcel A1 = matrix(results), names nformat(number_d2)

//Correlation Table
local vars ddep_u fvgl roe avg_rate_c sd_woff book2asset whole2asset real2asset ln_asset unused2loan fedrate agg_dep_gr catfat_asset pct_uninsured  ddep_i awgt_loan_ORG0
pwcorr `vars', sig
return list
matlist r(C)
putexcel set T1AB_$today.xlsx, sheet(corr) modify
putexcel A1 = matrix(r(C)), names nformat(number_d2) 	

************************************************************	
/*** Table 2 Unindured deposit flow baseline regressions ***/
************************************************************	

***Specify list of all variables to be retained and sorted
local keepvars fvgl fvgl_adjscal2 roe $bankchara agg_dep_gr $macrocon 

local output "T2_unin_flow_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach y in fvgl{
	
**Without controls
reghdfe ddep_u `y' , noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
reghdfe ddep_u `y' roe , noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
							
**with time-varying bank controls				
reghdfe ddep_u `y' roe $bankchara, noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
**with bank FE
reghdfe ddep_u `y' roe $bankchara, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**with control for aggregate deposit demand
reghdfe ddep_u `y' roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**include time dummies
reghdfe ddep_u `y' roe $bankchara , absorb(group_id qtr)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, Y)

}

****************************************************************	
/*** Table 3 Robustness to address concerns about confounders **/
****************************************************************		
*generating deposit rate variables
cap drop sp_fvgl*
mkspline sp_fvgl1 0 sp_fvgl2  = fvgl
encode STALPBR, generate(state2)

local output "T3_Robustness_confounders_$today"
cap erase `output'.xml
cap erase `output'.txt

**controlling for local deposit growth
reghdfe ddep_u fvgl roe $bankchara dep_gr_mean, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) sortvar(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**estimation on single state sample with stat*qtr FEs
reghdfe ddep_u fvgl roe $bankchara dep_gr_mean if state_count_SOD!=., absorb(group_id i.qtr#i.state2)  vce(cluster group_id)
outreg2 using `output', append excel keep(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) sortvar(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) dec(3) adjr2 tstat addtext(Bank FE, Y, State*Quarter FE, Y) ///
cttop(single state sample)

*insured deposit flows
reghdfe ddep_i fvgl roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(fvgl roe dep_gr_mean) sortvar(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

*rate response
*we control for fed fund rates in these regressions
reghdfe ln_fut4_lt_rate  fvgl roe $bankcharanorate agg_dep_gr fedrate fedrate_c , absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(fvgl roe dep_gr_mean) sortvar(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

reghdfe ln_fut4_core_rate  fvgl roe $bankcharanorate agg_dep_gr fedrate fedrate_c , absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(fvgl roe dep_gr_mean) sortvar(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**Asymmetry in FVG&L response using spline regressions with a knot at zero
reghdfe ddep_u sp_fvgl* roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) sortvar(fvgl roe sp_fvgl1 sp_fvgl2 dep_gr_mean) dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)


******************************************************************************************	
/*** Table 4 **Information content of loan fair values about credit quality **/
******************************************************************************************	

*generating terciles for loan hair cuts
gen hcut=1-awgt_loan_ORG0
xtile hcut3=hcut, nq(3)
xtile hcut2=hcut, nq(2)
xtile hcut4=hcut, nq(4)

*dummy for low liquidity
gen lowliq=(hcut3==3)
replace lowliq=. if hcut3==.

**generating a residual measure of fvgl stripped of movements in market rates
reg fvgl fedrate fedrate_c
predict fvgl_res, res

**generating components of roe
gen llp=llp2equity
gen ebllp=roe-llp

***Specify list of all variables to be retained and sorted
local keepvars fvgl fvgl_res roe llp ebllp $bankchara agg_dep_gr 

local output "T4A_pred_woff_$today"
cap erase `output'.xml
cap erase `output'.txt
	
foreach y in fut4_woff {
    
			reghdfe `y' fvgl , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' roe, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' llp ebllp, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
						
			reghdfe `y' fvgl_res llp ebllp, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res llp ebllp $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)
									
			}
	
**Variation based on loan market liquidity
local output "T4B_woffby_liquidity_$today"
cap erase `output'.xml
cap erase `output'.txt

*Estimation on smaller smaple where liquidity measure is available
reghdfe fut4_woff fvgl_res roe $bankchara agg_dep_gr if hcut3!=., absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

***Predicting future write-offs
	reghdfe fut4_woff i.lowliq##(c.fvgl_res c.roe) i.lowliq##($cbankchara c.agg_dep_gr) if hcut3!=., absorb(group_id) vce(cluster group_id)

	lincom _b[1.lowliq#c.fvgl_res]+_b[c.fvgl_res]
	 local tot1=r(estimate)
	 local tstat1=r(estimate)/r(se)

	lincom _b[1.lowliq#c.roe]+_b[c.roe]
	 local tot2=r(estimate)
	 local tstat2=r(estimate)/r(se)
		 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl_res roe 1.lowliq#c.fvgl_res 1.lowliq#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b2_roe, `tot2', t_b2_roe, (`tstat2'))  

			
******************************************************************************************
/*** Table 5 **Can information about credit quality explain the loan fair value relevance**/
******************************************************************************************

**TEST 1: Is there flow-performance association even in periods of low liquidity?			
local output "T5A_Flow_cutby_liquidity_$today"
cap erase `output'.xml
cap erase `output'.txt

	reghdfe ddep_u i.lowliq##(c.fvgl c.roe) i.lowliq##($cbankchara c.agg_dep_gr), absorb(group_id) vce(cluster group_id)

	lincom _b[1.lowliq#c.fvgl]+_b[c.fvgl]
	 local tot1=r(estimate)
	 local tstat1=r(estimate)/r(se)

	lincom _b[1.lowliq#c.roe]+_b[c.roe]
	 local tot2=r(estimate)
	 local tstat2=r(estimate)/r(se)
		 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 1.lowliq#c.fvgl 1.lowliq#c.roe) adjr2 tstat ///
	addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b2_roe, `tot2', t_b2_roe, (`tstat2'))  cttop(BankFE, bank controls, macro controls)
				
**TEST 2: Controlling for future fundamentals
***Specify list of all variables to be retained and sorted
local keepvars fvgl roe  roe llp ebllp $futfunda $bankchara agg_dep_gr $macrocon

local output "T5B_funda_control_$today"
cap erase `output'.xml
cap erase `output'.txt

*baseline regression
reghdfe ddep_u fvgl roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

*controlling for fut4 qtr woff 
reghdfe ddep_u fvgl roe fut4_woff  $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**Estimating on a subsample where longer horizon variables are available
reghdfe ddep_u fvgl roe $bankchara agg_dep_gr if fut5_8_woff!=. & fut9_12_woff!=., absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**Comprehensively controlling for all perf metric inclduing long horizon vars
reghdfe ddep_u fvgl roe fut4_woff fut4_roe fut5_8_woff fut9_12_woff fut5_8_roe fut9_12_roe ///
fut4_llp fut5_8_llp fut9_12_llp fut4_dnpl fut5_8_dnpl fut9_12_dnpl $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)



************************************************************	
/*** Table 6 Role of panic based withdrawal motives **/
************************************************************	

**Panel A: Do fair values contain information on exit values?

*Demean variables
foreach x in hcut catfat_asset {
cap drop dm_`x'
egen avg_`x'=mean(`x')
gen dm_`x'=`x'-avg_`x'
drop avg_`x'
}

local output "T6_ExitValues_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach x in fv2cv_netloans_adj3 {
	
*no FE or future fundamenals
reghdfe `x' fedrate , noabsorb vce(cluster group_id)
outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Future, N, Bank FE, N)

reghdfe `x' fedrate dm_catfat_asset, noabsorb vce(cluster group_id)
outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Future, N, Bank FE, N)

reghdfe `x' fedrate c.dm_catfat_asset##c.dm_hcut, noabsorb vce(cluster group_id)
outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Future, N, Bank FE, N)

*FE and future fundamentals
reghdfe `x' fedrate dm_catfat_asset fut4_woff fut4_roe fut5_8_woff fut9_12_woff fut5_8_roe fut9_12_roe ///
fut4_llp fut5_8_llp fut9_12_llp fut4_dnpl fut5_8_dnpl fut9_12_dnpl, absorb(i.group_id) vce(cluster group_id)
outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Future, Y, Bank FE, Y)

reghdfe `x' fedrate c.dm_catfat_asset##c.dm_hcut fut4_woff fut4_roe fut5_8_woff fut9_12_woff fut5_8_roe fut9_12_roe ///
fut4_llp fut5_8_llp fut9_12_llp fut4_dnpl fut5_8_dnpl fut9_12_dnpl, absorb(i.group_id) vce(cluster group_id)
outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Future, Y, Bank FE, Y)
}


***Panels A and B: partioning by %UNinsured and Asset illiquidity
***creating moving averages of %UNinsured and Asset illiquidity based on pastn quarters
	global pastn 1
	foreach x in  pct_uninsured catfat_asset {
		cap drop movave_`x'
		rangestat (mean) movave_`x' = `x', interval (qtr -$pastn -1)  by(group_id)
		}

		
local output "T6BC_Strat_Comp_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach x in  pct_uninsured catfat_asset {
			cap drop movaverank
			   xtile movaverank=movave_`x', nq(3)
			
			cap drop lliq3 
			gen lliq3 = movaverank 

	***without interest rate control
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr ), absorb(group_id) vce(cluster group_id)

	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)

	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', wo fedrate) 
					

	***with interest rate control
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ), absorb(group_id) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', with fedrate) 
					
	***Estimation on single state banks with state-qtr FEs
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ) if state_count_SOD!=., absorb(group_id i.qtr#i.state2) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, Y) cttop(`x', with fedrate, single state) 
					
	}		
	
	
	

	
*** Table B: Relative weights depositors place on fair values and historical cost-based measures
	
qui: reg ddep_u fvgl  roe $bankchara agg_dep_gr i.group_id
est store ddepu
est table, keep(fvgl  roe) b se
testnl _b[fvgl]/_b[roe] = 0

qui: reg fut4_woff fvgl  roe $bankchara agg_dep_gr i.group_id fedrate fedrate_c
est store netincome
est table, keep(fvgl  roe) b se
testnl _b[fvgl]/_b[roe]=0

suest ddepu netincome, vce(cluster group_id)

testnl [ddepu_mean]fvgl/[ddepu_mean]roe = [netincome_mean]fvgl/[netincome_mean]roe


qui: reg fut4_roe fvgl  roe $bankchara agg_dep_gr i.group_id fedrate fedrate_c
est store netincome2
est table, keep(fvgl  roe) b se
testnl _b[fvgl]/_b[roe]=0

suest ddepu netincome2, vce(cluster group_id)

testnl [ddepu_mean]fvgl/[ddepu_mean]roe = [netincome2_mean]fvgl/[netincome2_mean]roe

***Specify list of all variables to be retained and sorted
local keepvars fvgl roe $bankchara agg_dep_gr $macrocon

local output "TOB_$today"
cap erase `output'.xml
cap erase `output'.txt

reghdfe ddep_u fvgl roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

reghdfe fut4_woff fvgl roe $bankchara agg_dep_gr fedrate fedrate_c, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

reghdfe fut4_roe fvgl roe $bankchara agg_dep_gr fedrate fedrate_c, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)
	
	
	


/*========================================================================================================
                                                                          
        ARTICLE: The decision relevance of loan fair values for depositors                      
        AUTHORS: Qi Chen, Rahul Vashishtha, Shuyan Wang              
        JOURNAL OF ACCOUNTING RESEARCH 

 		The code below generates tables in the online appendix.

 =========================================================================================================*/


*Setting macro for date
local c_date = c(current_date) 
global today = subinstr("`c_date'", " ", "", .)  

global runpath ".../Code"
cd "$runpath"
	
*open dataset
use FV_clean_main.dta, clear 	
	
**************************************************
*Defining useful macro variables
******************************************************
global bankchara "avg_rate_c sd_woff book2asset whole2asset real2asset ln_asset unused2loan"
global macrocon "fedrate fedrate_c mktret mktret_c "  
global cbankchara "c.avg_rate_c c.sd_woff c.book2asset c.whole2asset c.real2asset c.ln_asset c.unused2loan"

********************************************************************
**dropping observations where some key variables are missing
**********************************************************************
foreach x in $bankchara $macrocon {
drop if `x'==.
}

********************************************************************
**Online Appendix Tables
**********************************************************************
*** Table OA1: Robustness to Choices of Future Fundamental Variables

**Generating a residual measure of fvgl stripped of movements in market rates
capture drop fvgl_res
reg fvgl fedrate fedrate_c
predict fvgl_res, res

**generating components of roe
gen llp=llp2equity
gen ebllp=roe-llp

***Specify list of all variables to be retained and sorted
local keepvars fvgl fvgl_res roe llp ebllp $bankchara agg_dep_gr 

local output "TOA1_$today"
cap erase `output'.xml
cap erase `output'.txt
	
foreach y in fut4_llp fut4_dnp fut4_roe fut_dwoff2equity{
    
			reghdfe `y' fvgl , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' roe, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' llp ebllp, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
						
			reghdfe `y' fvgl_res llp ebllp, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res llp ebllp $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)
									
			}

			
*** Table OA2: Robustness to Future Write-offs over Longer Horizons

local output "TOA2_$today"
cap erase `output'.xml
cap erase `output'.txt
	
foreach y in fut5_8_woff fut9_12_woff {
    
			reghdfe `y' fvgl , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' roe, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' llp ebllp, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
						
			reghdfe `y' fvgl_res llp ebllp, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res llp ebllp $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)
									
			}
			
			
*** Table OA3： Robustness to Using Sample after 2009
gen post_2009 = (year >= 2009)

** Panel A: Unindured deposit flow baseline regressions 
local keepvars fvgl roe $bankchara agg_dep_gr $macrocon

local output "OA3PA_$today"
cap erase `output'.xml
cap erase `output'.txt

	**Without controls
	reghdfe ddep_u fvgl if post_2009 == 1, noabsorb  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
				
	reghdfe ddep_u fvgl roe  if post_2009 == 1, noabsorb  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
								
	**with time-varying bank controls				
	reghdfe ddep_u fvgl roe $bankchara if post_2009 == 1, noabsorb  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
				
	**with bank FE
	reghdfe ddep_u fvgl roe $bankchara if post_2009 == 1, absorb(group_id)  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

	**with control for aggregate deposit demand
	reghdfe ddep_u fvgl roe $bankchara agg_dep_gr if post_2009 == 1, absorb(group_id)  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

	**B: Include time dummies
	reghdfe ddep_u fvgl roe $bankchara  if post_2009 == 1, absorb(group_id qtr)  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, Y)

** Panel B: Information content of loan fair values about credit quality
capture drop fvgl_res
reg fvgl fedrate fedrate_c if post_2009 == 1
predict fvgl_res  if post_2009 == 1, res

local keepvars fvgl fvgl_res roe llp ebllp $bankchara agg_dep_gr 

local output "OA3PB_$today"
cap erase `output'.xml
cap erase `output'.txt
	
foreach y in fut4_woff {
    
			reghdfe `y' fvgl  if post_2009 == 1, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res  if post_2009 == 1, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' roe  if post_2009 == 1, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' llp ebllp  if post_2009 == 1, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
						
			reghdfe `y' fvgl_res llp ebllp  if post_2009 == 1, noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res llp ebllp $bankchara agg_dep_gr  if post_2009 == 1, absorb(group_id)  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)
									
			}
			

***Panels C and D: partioning by %UNinsured and Asset illiquidity
encode STALPBR, generate(state2)

***creating moving averages of liabilty side variables based on pastn quarters
	global pastn 1
	foreach x in  pct_uninsured catfat_asset {
		cap drop movave_`x'
		rangestat (mean) movave_`x' = `x', interval (qtr -$pastn -1)  by(group_id)
		}

local output "OA3PCD_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach x in  pct_uninsured catfat_asset {
			cap drop movaverank
			   xtile movaverank=movave_`x' if post_2009 == 1, nq(3)
			
			cap drop lliq3 
			gen lliq3 = movaverank 

	***without interest rate control
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr )  if post_2009 == 1, absorb(group_id) vce(cluster group_id)

	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)

	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', wo fedrate) 
					

	***with interest rate control
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ) if post_2009 == 1, absorb(group_id) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', with fedrate) 
					
	***Estimation on single state banks with adding state-qtr FEs
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ) if state_count_SOD!=. & post_2009 == 1, absorb(group_id i.qtr#i.state2) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, Y) cttop(`x', with fedrate, single state) 
					
	}		
	
	
	
*** Table OA4 (to be run as the last step - see below): Removing obs with large aggregated deposit difference . 
			
*** Table OA5： Loan Fair Value Relevance for Insured Depositors and Strategic Complementarities

***creating moving averages of variables based on pastn quarters
	global pastn 1
	foreach x in  pct_uninsured catfat_asset {
		cap drop movave_`x'
		rangestat (mean) movave_`x' = `x', interval (qtr -$pastn -1)  by(group_id)
		}

		
local output "TOA5_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach x in  pct_uninsured catfat_asset {
			cap drop movaverank
			   xtile movaverank=movave_`x', nq(3)
			
			cap drop lliq3 
			gen lliq3 = movaverank 

	***without interest rate control
	reghdfe ddep_i i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr ), absorb(group_id) vce(cluster group_id)

	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)

	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', wo fedrate) 
					

	***with interest rate control
	reghdfe ddep_i i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ), absorb(group_id) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', with fedrate) 
					
	***Estimation on single state banks with adding state-qtr FEs
	reghdfe ddep_i i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ) if state_count_SOD!=., absorb(group_id i.qtr#i.state2) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	

	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, Y) cttop(`x', with fedrate, single state) 
					
	}		
	


*** Table OA6： Total deposit flow baseline regressions

***Specify list of all variables to be retained and sorted
local keepvars fvgl roe $bankchara agg_dep_gr $macrocon

local output "TOA6_$today"
cap erase `output'.xml
cap erase `output'.txt

**Without controls
reghdfe ddep_t fvgl , noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
reghdfe ddep_t fvgl roe , noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
							
**with time-varying bank controls				
reghdfe ddep_t fvgl roe $bankchara, noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
**with bank FE
reghdfe ddep_t fvgl roe $bankchara, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**with control for aggregate deposit demand
reghdfe ddep_t fvgl roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**B: Include time dummies
reghdfe ddep_t fvgl roe $bankchara , absorb(group_id qtr)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, Y)


*** Table OA7： Alternative scaling of changes in loan fair values

***Specify list of all variables to be retained and sorted
local keepvars fvgl fvgl_adjscal2 roe $bankchara agg_dep_gr $macrocon 

local output "TOA7_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach y in fvgl_adjscal2{
	
**Without controls
reghdfe ddep_u `y' , noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
reghdfe ddep_u `y' roe , noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
							
**with time-varying bank controls				
reghdfe ddep_u `y' roe $bankchara, noabsorb  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
**with bank FE
reghdfe ddep_u `y' roe $bankchara, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**with control for aggregate deposit demand
reghdfe ddep_u `y' roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

**include time dummies
reghdfe ddep_u `y' roe $bankchara , absorb(group_id qtr)  vce(cluster group_id)
outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, Y)

}

*** Table OA4: Removing obs with large aggregated deposit difference (use FV_clean_OA4.dta). 

*open dataset
use FV_clean_OA4.dta, clear   //Use this dataset only for Table OA4
	
	
**************************************************
*Defining useful macro variables
******************************************************
global bankchara "avg_rate_c sd_woff book2asset whole2asset real2asset ln_asset unused2loan"
global macrocon "fedrate fedrate_c mktret mktret_c "  
global cbankchara "c.avg_rate_c c.sd_woff c.book2asset c.whole2asset c.real2asset c.ln_asset c.unused2loan"

********************************************************************
**dropping observations where some key variables are missing
**********************************************************************
foreach x in $bankchara $macrocon {
drop if `x'==.
}

** Panel A: Unindured deposit flow baseline regressions 
local keepvars fvgl roe $bankchara agg_dep_gr $macrocon

local output "OA4PA_$today"
cap erase `output'.xml
cap erase `output'.txt

	**Without controls
	reghdfe ddep_u fvgl, noabsorb  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
				
	reghdfe ddep_u fvgl roe, noabsorb  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
								
	**with time-varying bank controls				
	reghdfe ddep_u fvgl roe $bankchara, noabsorb  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
				
	**with bank FE
	reghdfe ddep_u fvgl roe $bankchara, absorb(group_id)  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

	**with control for aggregate deposit demand
	reghdfe ddep_u fvgl roe $bankchara agg_dep_gr, absorb(group_id)  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)

	**B: Include time dummies
	reghdfe ddep_u fvgl roe $bankchara , absorb(group_id qtr)  vce(cluster group_id)
	outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, Y)

** Panel B: Information content of loan fair values about credit quality
*generating terciles for loan hair cuts
gen hcut=1-awgt_loan_ORG0
xtile hcut3=hcut, nq(3)
xtile hcut2=hcut, nq(2)
xtile hcut4=hcut, nq(4)

*dummy for low liquidity
gen lowliq=(hcut3==3)
replace lowliq=. if hcut3==.

**generating a residual measure of fvgl stripped of movements in market rates
reg fvgl fedrate fedrate_c
predict fvgl_res, res

**generating components of roe
gen llp=llp2equity
gen ebllp=roe-llp

local keepvars fvgl fvgl_res roe llp ebllp $bankchara agg_dep_gr 

local output "OA4PB_$today"
cap erase `output'.xml
cap erase `output'.txt
	
foreach y in fut4_woff {
    
			reghdfe `y' fvgl , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' roe  , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' llp ebllp , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
						
			reghdfe `y' fvgl_res llp ebllp  , noabsorb  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, N, Quarter FE, N)
			
			reghdfe `y' fvgl_res llp ebllp $bankchara agg_dep_gr , absorb(group_id)  vce(cluster group_id)
			outreg2 using `output', append excel keep(`keepvars') sortvar(`keepvars') dec(3) adjr2 tstat addtext(Bank FE, Y, Quarter FE, N)
									
			}
			

***Panels C and D: partioning by %UNinsured and Asset illiquidity
encode STALPBR, generate(state2)

***creating moving averages of liabilty side variables based on pastn quarters
	global pastn 1
	foreach x in  pct_uninsured catfat_asset {
		cap drop movave_`x'
		rangestat (mean) movave_`x' = `x', interval (qtr -$pastn -1)  by(group_id)
		}

local output "OA4PCD_$today"
cap erase `output'.xml
cap erase `output'.txt

foreach x in  pct_uninsured catfat_asset {
			cap drop movaverank
			   xtile movaverank=movave_`x' , nq(3)
			
			cap drop lliq3 
			gen lliq3 = movaverank 

	***without interest rate control
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr )  , absorb(group_id) vce(cluster group_id)

	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)

	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', wo fedrate) 
					

	***with interest rate control
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ), absorb(group_id) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, N) cttop(`x', with fedrate) 
					
	***Estimation on single state banks with adding state-qtr FEs
	reghdfe ddep_u i.lliq3##(c.fvgl c.roe) i.lliq3##($cbankchara c.agg_dep_gr c.fedrate c.fedrate_c ) if state_count_SOD!=. , absorb(group_id i.qtr#i.state2) vce(cluster group_id)
	
	lincom _b[2.lliq3#c.fvgl]+_b[c.fvgl]
	local tot1=r(estimate)
	local tstat1=r(estimate)/r(se)

	lincom _b[3.lliq3#c.fvgl]+_b[c.fvgl]
	local tot2=r(estimate)
	local tstat2=r(estimate)/r(se)
	
	lincom _b[2.lliq3#c.roe]+_b[c.roe]
	local tot3=r(estimate)
	local tstat3=r(estimate)/r(se)

	lincom _b[3.lliq3#c.roe]+_b[c.roe]
	local tot4=r(estimate)
	local tstat4=r(estimate)/r(se)
	 
	outreg2 using `output', excel dec(3) adec(3) keep(fvgl roe 3.lliq3#c.fvgl 3.lliq3#c.roe) adjr2 tstat ///
			addstat(b2_fvgl, `tot1', t_b2_fvgl, (`tstat1'), b3_fvgl, `tot2', t_b3_fvgl, (`tstat2'),  ///
					b2_roe,  `tot3', t_b2_roe, (`tstat3'),  b3_roe,  `tot4', t_b3_roe,  (`tstat4')) ///
					addtext(Bank FE, Y, Quarter FE, N, State*Qtr FE, Y) cttop(`x', with fedrate, single state) 
					
	}		


