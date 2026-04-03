************************************************************************
*   Information Complementarities and the Dynamics of Transparency		*
*   Shock Spillovers													*
************************************************************************
	
	*folder path
	global jar "....../BDSY-datasheet-and-code"

	set more off
	set type double
	*In this do file, close peer firms are in the same SIC 4-digit industry as a 
	*high-profile fraudulent firm, distant peers share the same SIC 2-digit code 
	*but a different SIC 3-digit code as a high-profile fraudulent firm.

	

	*- Close peer firms	
	*comp_ann is the compustat annual file.
	*sic2 and sic3 are SIC 2-digit and SIC 3-digit code, respectively.
	use "$jar/cplist.dta", clear
	joinby gvkey using comp_ann
	drop if sic=="2000"
	*For firms that have SIC code "2000", close peer and distant peer firms have 
	*the same 4, 3, 2-digit SIC code.
	*evt_yr is the fraud revelation year.
	gen evt_time = fyear-evt_yr
	keep if evt_time<=4 & evt_time>=-4
	gen post=1 if evt_time>=0
	replace post=0 if evt_time<0
	tab evt_time post
	save "$jar/cpsample.dta", replace
	
	
	*- Distant peer firms		
	use "$jar/cplist.dta", clear
	keep i sic /*i denote cohorts*/
	gen sic2=substr(sic,1,2)
	keep i sic2
	duplicates drop
	joinby sic2 using comp_ann
	save "$jar/psample.dta", replace
	
	*remove firms that share the same SIC 3-digit code (including close peer firms)
	use "$jar/cplist.dta", clear
	keep i sic3 
	duplicates drop 
	merge 1:m i sic3 using "$jar/psample.dta"
	keep if _merge==2
	drop _merge 
	gen evt_time = fyear-evt_yr
	keep if evt_time<=4 & evt_time>=-4
	gen post=1 if evt_time>=0
	replace post=0 if evt_time<0
	tab evt_time post
	save "$jar/psample.dta", replace

	
	
	
	*Frauudlent firms are removed from both the close peer sample and distant 
	*peer sample.
	use "$jar/flist.dta", clear
	merge 1:m gvkey using "$jar/cpsample.dta"
	keep if _merge==2
	drop _merge 
	save "$jar/cpsample.dta", replace
	
	
	use "$jar/flist.dta", clear
	merge 1:m gvkey using "$jar/psample.dta"
	keep if _merge==2
	drop _merge 
	save "$jar/psample.dta", replace

	
	*Remove firm-year observations from the distant peer sample if it becomes 
	*treated by the high-profile fraud.
	use "$jar/flist.dta", clear
	keep sic3 evt_yr
	duplicates drop
	save "$jar/tmp1.dta", replace


	use "$jar/tmp1.dta", clear
	levelsof sic3, local(ind)
	foreach l of local ind {
	use "$jar/tmp1.dta", clear
	keep if sic3==`l'
	rename evt_year evt_check
	merge 1:m sic3 using "$jar/psample.dta"
	drop if _merge==1
	count if fyear-evt_check>=0&fyear-evt_check<=10&_merge==3
	drop if fyear-evt_check>=0&fyear-evt_check<=10&_merge==3
	drop evt_check _merge
	save "$jar/psample.dta", replace
	}


	use "$jar/cpsample.dta", clear
	gen close_peer=1
	append using "$jar/psample.dta"
	replace close_peer=0 if close_peer==.

	label var close_peer "SIC 4-digit peer (dummy)"
	label data "SIC 4-digit close peer vs SIC 2-digit distant peer, i denotes cohorts"
	save "$jar/peersample42.dta", replace	
	
	
	*The analyses is using simualated data for illustration. 
	do "....../BDSY-datasheet-and-code/sim_sample.do"
	
	egen ic = group(i firmid)
	egen tc = group(i fyear)	
	gen close_peer_post = close_peer * post
	
	/*The revelation years are removed from the analyses*/
	tab evt_time post	
	
	*cost of equity regressions*
	reghdfe icc close_peer_post, abs(tc ic) cluster(ind)
	
	
	
	*examination of the dynamics of the cost of equity
	gen a1=1 if evt_time==-1
	gen a2=1 if evt_time==1
	gen a3=1 if evt_time==2
	gen a4=1 if evt_time==3
	gen a5=1 if evt_time==4
	replace a1=0 if evt_time!=-1
	replace a2=0 if evt_time!=1
	replace a3=0 if evt_time!=2
	replace a4=0 if evt_time!=3
	replace a5=0 if evt_time!=4

	gen close_peer_a1=close_peer*a1
	gen close_peer_a2=close_peer*a2
	gen close_peer_a3=close_peer*a3
	gen close_peer_a4=close_peer*a4
	gen close_peer_a5=close_peer*a5

	
	reghdfe icc close_peer_a1 close_peer_a2 close_peer_a3 close_peer_a4 close_peer_a5 , abs(tc ic) cluster(ind)
	
	









************************************************************************
*   Information Complementarities and the Dynamics of Transparency		*
*   Shock Spillovers													*
************************************************************************
	
	
	*Generate simulated sample for illustration.
	
	*folder path
	global jar "....../BDSY-datasheet-and-code"
	
	use "$jar/sim_sample.dta", clear
	gen fyear= evt_yr
		
	*- Post fraud revelaitons
	*+1 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte last=_n==_N
	local b = _N+1
	expand 2 if last
	replace last=. in `b'/l
	replace fyear=fyear+1 if last==.
	drop last
	sort i firmid fyear
	duplicates report i firmid fyear

	*+2 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte last=_n==_N
	local b = _N+1
	expand 2 if last
	replace last=. in `b'/l
	replace fyear=fyear+1 if last==.
	drop last
	sort i firmid fyear
	duplicates report i firmid fyear
	
	*+3 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte last=_n==_N
	local b = _N+1
	expand 2 if last
	replace last=. in `b'/l
	replace fyear=fyear+1 if last==.
	drop last
	sort i firmid fyear
	duplicates report i firmid fyear
	
	
	*+4 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte last=_n==_N
	local b = _N+1
	expand 2 if last
	replace last=. in `b'/l
	replace fyear=fyear+1 if last==.
	drop last
	sort i firmid fyear
	duplicates report i firmid fyear	
	

	*- Prior to fraud revelaitons
	*-1 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte first=_n==1
	local b = _N+1
	expand 2 if first
	replace first=. in `b'/l
	replace fyear=fyear-1 if first==.
	drop first
	sort i firmid fyear
	duplicates report i firmid fyear		
	

	*-2 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte first=_n==1
	local b = _N+1
	expand 2 if first
	replace first=. in `b'/l
	replace fyear=fyear-1 if first==.
	drop first
	sort i firmid fyear
	duplicates report i firmid fyear	
	
	
	
	*-3 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte first=_n==1
	local b = _N+1
	expand 2 if first
	replace first=. in `b'/l
	replace fyear=fyear-1 if first==.
	drop first
	sort i firmid fyear
	duplicates report i firmid fyear
	
	
	*-4 year
	sort i firmid fyear 
	bysort i firmid (fyear): gen byte first=_n==1
	local b = _N+1
	expand 2 if first
	replace first=. in `b'/l
	replace fyear=fyear-1 if first==.
	drop first
	sort i firmid fyear
	duplicates report i firmid fyear	
	
	gen evt_time = fyear-evt_yr
	gen post=1 if evt_time>=0
	replace post=0 if evt_time<0
	tab evt_time post
	drop if evt_time==0 /*remove fraud year from the analyses*/
	drop if evt_time==-4 
	/*For our main analyses, we examine three years before and four years after
	the fraud revelation*/
	gen icc = rnormal(0.0612, 0.0860)
