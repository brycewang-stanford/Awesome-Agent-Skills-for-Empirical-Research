*********************************************************************************
*																				*
*				The Real Effects of Modern Information Technologies:			*
*						Evidence from the EDGAR Implementation					*
*																				*
*				Converting raw data into the dataset for main Table 2			*
*																				*
*********************************************************************************

*********************************************************************************
*								Sample construction								*
*********************************************************************************

// #1: Compustat Data

	use "data\sources\20191009 Compustat data (quarterly)", clear
	keep if fyearq>=1990 & fyearq<=2000
	gen fquarter=qofd(mdy(real(substr(datafqtr,6,1))*3,1,real(substr(datafqtr,1,4))))
	format fquarter %tq
	destring gvkey, gen(gvkeyx)
	xtset gvkeyx fquarter
	
	* corporate investment
	gen capxq=capxy if fqtr==1
	replace capxq=d.capxy if fqtr>1
	gen investment=(f.capxq)/ppentq
	
	* Tobin’s Q
	gen q=(atq-ceqq+cshoq*prccq)/atq
	
	* cash flow
	gen cf=(ibq+dpq)/l.atq
	
	* firm size
	gen size=ln(atq)
	
	* variable labels
	label var investment "INVESTMENT"
	label var q "Q"
	label var cf "CF"
	label var size "SIZE"
	keep fyearq fquarter gvkey gvkeyx datadate cik sic investment q cf size
	save "data\_compustat_var_q", replace

// #2: EDGAR data
	
	* gvkey-cik link
	use "data\sources\20191009 Compustat data (quarterly)", clear
	drop if cik==""
	destring cik, replace
	keep gvkey cik
	duplicates drop
	save "data\_gvkey_cik", replace
	
	* finalized EDGAR implementation dates
	clear
	input str5 phase_in str9 date
	CF-01	26apr1993
	CF-02	19jul1993
	CF-03	04oct1993
	CF-04	06dec1993
	CF-05	30jan1995
	CF-06	06mar1995
	CF-07	01may1995
	CF-08	07aug1995
	CF-09	06nov1995
	CF-10	06may1996
	end
	gen edgar_date=date(date,"DMY")
	format edgar_date %td
	keep phase_in edgar_date
	save "data\sources\20190930 EDGAR Phase-in Dates", replace
	
	* EDGAR firm list with gvkey
	use "data\sources\20190930 EDGAR Phase-in Groups", clear
	merge 1:1 cik using "data\_gvkey_cik", keep(3) nogen
	merge m:1 phase_in using "data\sources\20190930 EDGAR Phase-in Dates", nogen
	ta phase_in
	keep gvkey edgar_date phase_in
	save "data\_edgar_list", replace
	
//	#3: Combine data

	use "data\_compustat_var_q", clear
	merge m:1 gvkey using "data\_edgar_list", keep(3) nogen
	
	* expressed in percentage points
	foreach var of varlist investment cf {
		replace `var'=`var'*100
	}
	
	* define EDGAR
	gen edgar=(datadate>=edgar_date)
	label var edgar "EDGAR"
	save "data\01 combined data", replace
	
//	#4: Baseline sample

	use "data\01 combined data", clear
	
	* sample period
	gen quarter=qofd(datadate)
	keep if quarter>=qofd(mdy(4,26,1993))-8 & quarter<=qofd(mdy(5,6,1996))+8
	
	* exclude firms in the financial and utility industries
	destring sic, replace
	drop if int(sic/1000)==6
	drop if int(sic/100)==49
	
	* drop firms with total assets less than $10 million in 1992
	preserve
		use "data\sources\20191009 Compustat data (annual)", clear
		keep if at!=.
		keep if year(datadate)==1992
		bysort gvkey (datadate): keep if _n==_N
		gen y1992_assets=at
		drop if y1992_assets<10
		keep gvkey
		duplicates drop
		save "data\_assets1992", replace
	restore	
	merge m:1 gvkey using "data\_assets1992", nogen keep(3)
	
	* common sample
	foreach var of varlist investment q cf size { 
		drop if `var'==.
	}
	
	* winsorize
	foreach var of varlist investment q cf size   {
		di "`var'", _c
		winsor `var', gen(`var'_w) p(0.01)
		replace `var'=`var'_w
		drop `var'_w
	}
	
	* identifier list for JAR
	preserve
		keep gvkey
		duplicates drop
		count
		save "identifier_gvkey", replace
		export delimited using "identifier_gvkey.txt", replace
	restore
	
	compress
	save "data\02 baseline sample", replace
	
//	#5: Stacked dataset
	
	use "data\01 combined data", clear
	
	* covariates
	xtset gvkeyx fquarter
	gen lag_size=l.size
	gen lag_cf=l.cf
	gen lag_q=l.q
	
	* define event quarter
	gen quarter=qofd(datadate)
	gen event_quarter=qofd(edgar_date)
	gen rel_quarter=quarter-event_quarter

	* industry
	destring sic, replace
	drop if int(sic/1000)==6
	drop if int(sic/100)==49

	* drop firms with total assets < $10 million in 1992
	merge m:1 gvkey using "data\_assets1992", nogen keep(3)
	
	* define treated firms
	gen treat=(rel_quarter==0)
	ta phase_in if treat==1
	drop if (phase_in=="CF-08" | phase_in=="CF-09" | phase_in=="CF-10") & treat==1
	bysort quarter: egen max_treat=max(treat)
	keep if max_treat==1
	drop max_treat
	ta rel_quarter
	drop if rel_quarter>0
	ta quarter treat 
	ta phase_in treat 
	
	* common sample of covariates
	foreach var of varlist lag_q lag_cf lag_size { 
		drop if `var'==.
	}
	
	* propensity score matching
	forval i=1/7 {
	local phase_in="CF-0`i'"
	preserve
		drop if phase_in!="`phase_in'" & treat==1
		bysort quarter: egen max_treat=max(treat)
		keep if max_treat==1
		keep if treat==1| rel_quarter<=-4 
		psmatch2 treat lag_q lag_cf lag_size, neighbor(1) caliper(0.05) common	
		ta treat _support, missing
		keep if _support==1
		ta _weight treat
		keep if _weight!=.
		ta _weight treat
		su _weight
		local max=r(max)
		gen id=_n
		expand `max'
		bysort id: keep if _n<=_weight
		bysort gvkey: gen double gvkey_c=(treat*1000+_n*10+`i')*1000000+gvkeyx
		gen quarter0=quarter
		keep gvkey treat gvkey_c quarter0 phase_in
		duplicates drop
		gen group=`i'
		save "data\_stacked_`i'", replace
	restore
	}
	clear
	forval i=1/7 {
		append using data\_stacked_`i'
		erase data\_stacked_`i'.dta
	}
	save "data\_stacked_all", replace
	
	* stacked dataset
	use "data\02 baseline sample", clear
	joinby gvkey using "data\_stacked_all"
	replace gvkeyx=gvkey_c
	gen rel_quarter=quarter-quarter0
	keep if abs(rel_quarter)<=4
	gen post=(rel_quarter>=0)
	gen treat_post=treat*post
	label var treat_post "EDGAR"
	save "data\03 stacked dataset", replace
	
*********************************************************************************
*									Main Results								*
*********************************************************************************
	
	* Table 2: Main Results on Corporate Investment	
	* Panel A: Baseline Analysis
	use "data\02 baseline sample", clear
	reghdfe investment edgar, absorb(gvkeyx quarter) vce(cluster gvkeyx) keepsingl
	outreg2 using "results\Table 2a", label adjr2 word excel tstat dec(3) tdec(2) replace
	reghdfe investment edgar q cf size, absorb(gvkeyx quarter) vce(cluster gvkeyx) keepsingl
	outreg2 using "results\Table 2a", label adjr2 word excel tstat dec(3) tdec(2) append
	
	* Panel B: Controlling for Group-Specific Trends
	use "data\02 baseline sample", clear
	ta phase_in, gen(_phase_in)
	foreach var of varlist _phase_in* {
		gen trend`var'=(quarter-124)*`var'
		drop `var'
	} 
	reghdfe investment edgar trend*, absorb(gvkeyx quarter) vce(cluster gvkeyx) keepsingl
	outreg2 using "results\Table 2b", label adjr2 word excel tstat dec(3) tdec(2) replace
	reghdfe investment edgar q cf size trend*, absorb(gvkeyx quarter) vce(cluster gvkeyx) keepsingl
	outreg2 using "results\Table 2b", label adjr2 word excel tstat dec(3) tdec(2) append
	
	* Panel C: Stacked Diff-in-Diff Regression
	use "data\03 stacked dataset", clear
	egen group_gvkeyx=group(group gvkeyx)
	egen group_quarter=group(group quarter)
	reghdfe investment treat_post, absorb(group_gvkeyx group_quarter) vce(cluster group_gvkeyx) keepsingl
	outreg2 using "results\Table 2c", label adjr2 word excel tstat dec(3) tdec(2) replace
	reghdfe investment treat_post q cf size, absorb(group_gvkeyx group_quarter) vce(cluster group_gvkeyx) keepsingl
	outreg2 using "results\Table 2c", label adjr2 word excel tstat dec(3) tdec(2) append