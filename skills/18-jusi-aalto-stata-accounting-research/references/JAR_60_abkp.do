***************************************************************************************************************************************************************
**********                                                                    									     **********
**********        "Did the Siebel Systems Case Limit the SEC’s Ability to Enforce Regulation Fair Disclosure?"					     **********
**********        Kristian D. Allee, Brian J. Bushee, Tyler J. Kleppe, and Andrew T. Pierce							     **********
**********                                                         										     **********
**********        NOTE: This STATA do-file converts the raw data into the final datasets used in the analyses reported in the paper.		     **********
**********                                                                         								     **********
***************************************************************************************************************************************************************



********************************************************************************
/*
	This code develops the sample and creates the variables related to the
	earnings break analysis following Ke et al. [2008]
	(doi: 10.1111/j.1475-679X.2008.00296.x).
*/
********************************************************************************



/// EARNINGS BREAK ANALYSIS: CREATE CRSP RETURNS VARIABLES ///
* CRSP DAILY *
use rfd_crsp_d, clear
gen DAY = day(date)
gen MONTH = month(date)
gen YEAR = year(date)
duplicates drop DAY MONTH YEAR, force
keep YEAR MONTH DAY
sort YEAR MONTH DAY
gen period = _n
save rfd_period_count_daily_F, replace
use rfd_crsp_d, clear
sort permno date
gen DAY = day(date)
gen MONTH = month(date)
gen YEAR = year(date)
merge m:1 YEAR MONTH DAY using rfd_period_count_daily_F
keep if _merge == 3
drop _merge
xtset permno period
gen RETQ0 = .
replace RETQ0 = [(1 + l3.ret) * (1 + l4.ret) * (1 + l5.ret) * (1 + l6.ret) * (1 + l7.ret) * (1 + l8.ret) * (1 + l9.ret) * (1 + l10.ret) * (1 + l11.ret) * (1 + l12.ret) * (1 + l13.ret) * (1 + l14.ret) * (1 + l15.ret) * (1 + l16.ret) * (1 + l17.ret) * (1 + l18.ret) * (1 + l19.ret) * (1 + l20.ret) * (1 + l21.ret) * (1 + l22.ret)] - 1
rename date ea_date
keep cusip ea_date RETQ0
save rfd_crsp_d_F, replace

* CRSP MONTHLY *
use rfd_crsp_m, clear
gen MONTH = month(date)
gen YEAR = year(date)
duplicates drop MONTH YEAR, force
sort YEAR MONTH
keep YEAR MONTH
gen period = _n
save rfd_period_count_F, replace
use rfd_crsp_m, clear
sort permno date
gen MONTH = month(date)
gen YEAR = year(date)
merge m:1 YEAR MONTH using rfd_period_count_F
keep if _merge == 3
drop _merge
gen qtr = qofd(date)
xtset permno period
gen RETQ1 = 0
replace RETQ1 = [(1 + ret) * (1 + l1.ret) * (1 + l2.ret)] - 1 if MONTH==3 | MONTH==6 | MONTH==9 | MONTH==12
replace RETQ1 = f.RETQ1 if MONTH==2 | MONTH==5 | MONTH==8 | MONTH==11
replace RETQ1 = f2.RETQ1 if MONTH==1 | MONTH==4 | MONTH==7 | MONTH==10
gen RETQ24 = 0
replace RETQ24 = [(1 + l3.ret) * (1 + l4.ret) * (1 + l5.ret) * (1 + l6.ret) * (1 + l7.ret) * (1 + l8.ret) * (1 + l9.ret) * (1 + l10.ret) * (1 + l11.ret)] - 1 if MONTH==3 | MONTH==6 | MONTH==9 | MONTH==12
replace RETQ24 = f.RETQ24 if MONTH==2 | MONTH==5 | MONTH==8 | MONTH==11
replace RETQ24 = f2.RETQ24 if MONTH==1 | MONTH==4 | MONTH==7 | MONTH==10
rename date date_crsp
rename shrout shrout_crsp
keep cusip ncusip permno qtr period RETQ1 RETQ24 date_crsp shrout_crsp
gen month = month(date_crsp)
gen year = year(date_crsp)
duplicates report cusip month year
save rfd_crsp_m_F, replace



/// EARNINGS BREAK ANALYSIS: CREATE I/B/E/S VARIABLES ///
* EPS FORECASTS *
use "IBES_Summary-EPS_1993-2018", clear
gen month=month(fpedats)
order ticker-statpers fpedats
keep if month==3 | month==6 | month==9 | month==12
drop month		
gen quart=qofd(statpers)
egen max=max(statpers),by(cusip quart)
keep if max==statpers			
drop quart max
gsort cusip fpedats -fpi
destring fpi, replace		
by cusip fpedats: gen l1medest=medest[_n-1] if fpi==7 & fpi[_n-1]==8		
keep if fpi==7 & l1medest!=.		
gen dforecast=medest-l1medest		
gen quart=qofd(fpedats)	
keep cusip quart anndats_act dforecast numest
keep if dforecast!=.
duplicates drop cusip quart, force			
save ibes1_F, replace

* RECOMMENDATIONS *
use "IBES_Summary-Recommendations_1993-2018", clear
gen month=month(statpers)
keep if month==3 | month==6 | month==9 | month==12
keep cusip statpers meanrec medrec
gen quart=qofd(statpers)
egen cgroup=group(cusip)
drop if cusip==""
duplicates drop cusip quart, force // 19 deleted
sort cgroup quart
xtset cgroup quart	
gen lmedrec=l.medrec
gen lmeanrec=l.meanrec	
gen dmedrec=(medrec-lmedrec)
drop if dmedrec==.		
gen dmeanrec=(meanrec-lmeanrec)
keep cusip quart medrec lmedrec dmedrec dmeanrec	
save ibes2_F, replace



/// EARNINGS BREAK ANALYSIS: CREATE TRANSIENT INSTITUTIONAL OWNERSHIP VARIABLES ///
* THOMSON REUTERS S34 INSTITUTIONAL HOLDINGS *
use "Thomson_S34_MasterFile_1980-201806", clear
	gen year=year(fdate)
	merge m:1 mgrno year using "Bushee_Inst_Classification_1981-2018", replace
		drop if _merge==2
		gen tra=perm_class=="TRA"
		keep if tra==1
	save "trs34_1981-2018", replace
	
* Randomly sort MGRNOs into 25 partitions to reduce size of data:
use "trs34_1981-2018", clear
	keep mgrno
	duplicates drop
	gen rand=runiform()
	egen fundgroup=xtile(rand), nq(25)
	keep mgrno fundgroup
	save "mgrno_groups", replace
	
* Randomly sort CUSIPs into 25 partitions to reduce size of data:
use "trs34_1981-2018", clear
	keep cusip
	duplicates drop
	gen rand=runiform()
	egen fundgroup=xtile(rand), nq(25)
	keep cusip firmgroup
	save "cusip_groups", replace
	
use "trs34_1981-2018", clear
	joinby mgrno using "mgrno_groups"
	joinby cusip using "cusip_groups"
	save "trs34_1981-2018_toClean", replace
	
* CRSP data for supplementing TRS34 data:
use "CRSP_Monthly_File_1980-2018", clear
	gen quart=qofd(date)
	*Convert to quarterly / retain Mar, Jun, Sep, Dec dates:
	egen maxdate=max(date), by(permno quart)
	keep if date==maxdate
	xtset permno quart
		rename prc crsp_prc
		rename shrout crsp_shrout
		gen l1crsp_prc=l.crsp_prc
		gen l1crsp_shrout=l.crsp_shrout
	keep permno ncusip date quart crsp_prc crsp_shrout l1crsp_prc l1crsp_shrout
	rename ncusip cusip
	save "crsp_trs34_supplement", replace
	
********************************************************************************
* Clean at MGRNO level:
forvalues y=1/25 {
	use "trs34_1981-2018_toClean", clear
	keep if fundgroup==`y'
	
	egen ifgroup=group(mgrno cusip)
	gen quart=qofd(fdate)
		duplicates drop ifgroup quart, force
		
	joinby cusip quart using "crsp_trs34_supplement"
		drop if prc==.
		drop if shares==.
		drop if crsp_shrout==.
		drop if crsp_shrout==0
		
	gen shrout = crsp_shrout if year(fdate)<1999
		replace shrout=shrout2 if shrout==. & shrout2>0 & shrout2!=.
		replace shrout=crsp_shrout if shrout==. & crsp_shrout>0 & crsp_shrout!=.
		drop if shrout==.
		replace prc=crsp_prc if prc==.
		drop date
		
	// Liquidations:
	sort ifgroup quart
		gen endperc=shares/(shrout*1000)
		
		xtset ifgroup quart
			gen begperc=l.endperc
			gen f1endperc=f.endperc
			replace begperc=0 if begperc==.
			order mgrno-shrout begperc endperc
			
		* Drop portfolio firm holdings & ifgroup series if ownership is greater than 100%:
			gen cut=begperc>1
			egen max=max(cut),by(ifgroup)
			drop if max==1
			drop cut max
			
			gen begshares=l.shares
			replace begshares=0 if begshares==.
			
		gen dup=0
			replace dup=1 if f1endperc==.
		
		expand 2 if dup==1, gen(liq)
		sort ifgroup quart liq
			replace quart=quart+1 if liq==1
			drop dup
			
		sort ifgroup quart
		xtset ifgroup quart
		
			replace endperc=0 if liq==1
			replace shares=0 if liq==1
			replace begperc=l.endperc if liq==1
				replace begperc=0 if begperc==.
			replace begshares=l.shares if liq==1
				replace begshares=0 if begshares==.
			replace l1prc=l.prc if liq==1
			replace fdate=fdate+90 if liq==1
				gen liqmonth=month(fdate)
				gen liqyear=year(fdate)
				gen liqday=1
					replace liqday=31 if liq==1 & liqmonth==3
					replace liqday=30 if liq==1 & liqmonth==6
					replace liqday=30 if liq==1 & liqmonth==9
					replace liqday=31 if liq==1 & liqmonth==12
				tostring liqmonth liqyear liqday, replace
				gen temp = liqyear + "/" + liqmonth + "/" + liqday
				gen fdate2=date(temp,"YMD")
				format fdate2 %td
				replace fdate=fdate2 if liq==1
				drop liqmonth liqyear liqday temp fdate2	
			drop f1endperc
				
		// Change
		gen ownchg=endperc-begperc
		
		gen holdval=begshares*l1prc
			replace holdval=0 if holdval==.
			
		egen begpv=total(holdval), by(mgrno quart)
			
		gen begconc=holdval/begpv
			replace begconc=0 if begconc==.
			
	save "mgrno_working_group`y'", replace
}

	use "mgrno_working_group1", clear
	forvalues y=2/25 {
		append using "mgrno_working_group`y'"
	}
	
	save "trs34_1981-2018_CLEANED-1", replace
	
********************************************************************************
* Clean at CUSIP level:
forvalues y=1/25 {
	use "trs34_1981-2018_CLEANED-1", clear
	keep if firmgroup==`y'
	sort cusip quart
	// Beginning & Ending TRA Ownership:
	egen tbegown = total(begperc), by(cusip quart)
	egen tendown = total(endperc), by(cusip quart)
	
		egen trachg2 = total(ownchg) if begperc>0, by(cusip quart)
	
	drop if tbegown==0
	
	// Portfolio Weight:
	egen holdval2=total(holdval), by(cusip quart)
		egen begpv2=total(begpv), by(cusip quart)
		
		gen traportwt=holdval2/begpv2
		
	// Large/Small Positions for ∆TRA_LG and ∆TRA_SM:
	gsort cusip quart -begperc
	egen base=count(mgrno) if begperc>0,by(cusip quart)
	egen count=max(base),by(cusip quart)
		drop base
	by cusip quart: gen sizerank=_n
	gen lgsh=(sizerank / count) <= (1/2)
	
	save "cusip_working_group`y'", replace	
}
	
	use "cusip_working_group1", replace
	forvalues y=2/25 {
		append using "cusip_working_group`y'"
	}
	
	save "trs34_1981-2018_CLEANED-2", replace

forvalues y=1/25 {
	use "trs34_1981-2018_CLEANED-2", clear
	keep if fundgroup==`y'
	egen group=group(mgrno cusip)
	sort group quart
	xtset group quart
	gen large=lgsh==1 | l.lgsh==1
		replace large=0 if larg==.
	gen small=large==0
	save "mgrno_working_group`y'", replace
}

	use "mgrno_working_group1", clear
	forvalues y=2/25 {
		append using "mgrno_working_group`y'"
	}
	
	save "trs34_1981-2018_CLEANED-3", replace

forvalues y=1/25 {
	use "trs34_1981-2018_CLEANED-3", clear
	keep if firmgroup==`y'
	local varlist "large small"
	foreach i of local varlist {
		egen own1=total(begperc) if `i'==1, by(cusip quart)
		egen `i'own=max(own1), by(cusip quart)
		drop own1
					
		egen chg1=total(ownchg) if `i'==1, by(cusip quart)
			egen `i'chg=max(chg1), by(cusip quart)
			drop chg1	
	}
	
	rename largeown block2own
	rename largechg block2chg
	rename smallown nblock2own
	rename smallchg nblock2chg
	
	duplicates drop cusip quart, force
	
	keep fdate cusip quart tbegown tendown trachg2 traportwt block2own block2chg nblock2own nblock2chg
	
	save "cusip_working_group`y'", replace	
}
	
	use "cusip_working_group1", replace
	forvalues y=2/25 {
		append using "cusip_working_group`y'"
	}
	
save trs34_variables, replace



/// EARNINGS BREAK ANALYSIS: CREATE MAIN COMPUSTAT SAMPLE, CREATE COMPUSTAT VARIABLES, and MERGE IN OTHER VARIABLES ///
* COMPUSTAT FUNDAMENTALS QUARTERLY *
use rfd_comp_q, clear
gen qtr = qofd(datadate)
rename cusip cusip9
gen cusip = substr(cusip9,1,8)
drop if cusip==""
duplicates report cusip qtr
duplicates drop cusip qtr, force
gen month = month(datadate)
gen year = year(datadate)
duplicates report cusip month year	
joinby gvkey using CRSP_Compustat_Linking_File, unmatched(master)
drop if _merge==1
drop _merge
keep if datadate>=linkdt & datadate<=linkenddt
duplicates report permno month year	
duplicates drop permno month year, force

* MERGE CRSP MONTHLY * 
merge 1:1 permno month year using rfd_crsp_m_F
keep if _merge==3
drop _merge

duplicates drop cusip qtr, force
destring gvkey, replace
duplicates report gvkey qtr
xtset gvkey qtr
gen lag_RETQ1 = l.RETQ1
gen lag_RETQ24 = l.RETQ24
gen MV = cshoq*prccq
xtset gvkey qtr
gen lag_MV = l.MV
gen LN_MV = ln(MV)
gen LN_lag_MV = ln(lag_MV)
gen cbe = atq - ltq
gen BM = cbe / MV
gen lag_BM = l.BM
rename epspxq eps
gen chg_eps = eps - l4.eps
egen group = group(gvkey fyr)
bysort gvkey: egen min = min(group)
bysort gvkey: egen max = max(group)
gen fye_change = 0
replace fye_change = 1 if min!=max
drop min max group
xtset gvkey qtr
gen lag_chg_eps = l.chg_eps
gen BREAK_A = 0
replace BREAK_A = 1 if lag_chg_eps>=0 & chg_eps<0
replace BREAK_A = . if lag_chg_eps==. | chg_eps==.
gen avg_assets = (f.atq + l3.atq) / 2
gen UE_old = f.chg_eps / avg_assets
gen lead_chg_eps = f.chg_eps
gen lead2_chg_eps = f2.chg_eps
gen lead3_chg_eps = f3.chg_eps
gen STRING1_A = 0
replace STRING1_A = 1 if chg_eps>=0 & lead_chg_eps<0
replace STRING1_A = . if chg_eps==. | lead_chg_eps==.
gen STRING2_A = 0
replace STRING2_A = 1 if chg_eps>=0 & lead_chg_eps>=0 & lead2_chg_eps<0
replace STRING2_A = . if chg_eps==. | lead_chg_eps==. | lead2_chg_eps==.
gen STRING3_A = 0
replace STRING3_A = 1 if chg_eps>=0 & lead_chg_eps>=0 & lead2_chg_eps>=0 & lead3_chg_eps<0
replace STRING3_A = . if chg_eps==. | lead_chg_eps==. | lead2_chg_eps==. | lead3_chg_eps==.
gen STRING4UP_A = 0
replace STRING4UP_A = 1 if chg_eps>=0 & lead_chg_eps>=0 & lead2_chg_eps>=0 & lead3_chg_eps>=0
replace STRING4UP_A = . if chg_eps==. | lead_chg_eps==. | lead2_chg_eps==. | lead3_chg_eps==.
egen group = group(gvkey)
bysort group: gen count = _N
egen max_count = max(count)
xtset gvkey qtr
gen censor = 0	
replace censor = 1 if BREAK_A!=1 & chg_eps>=0 & f.BREAK_A!=1 & f2.BREAK_A!=1 & f3.BREAK_A!=1 & f4.BREAK_A!=1 & f5.BREAK_A!=1 & f6.BREAK_A!=1 & f7.BREAK_A!=1 & f8.BREAK_A!=1 & f9.BREAK_A!=1 & f10.BREAK_A!=1 & f11.BREAK_A!=1 & f12.BREAK_A!=1 & f13.BREAK_A!=1 & f14.BREAK_A!=1 & f15.BREAK_A!=1 & f16.BREAK_A!=1 & f17.BREAK_A!=1 & f18.BREAK_A!=1 & f19.BREAK_A!=1 & f20.BREAK_A!=1 & f21.BREAK_A!=1 & f22.BREAK_A!=1 & f23.BREAK_A!=1 & f24.BREAK_A!=1 & f25.BREAK_A!=1 & f26.BREAK_A!=1 & f27.BREAK_A!=1 & f28.BREAK_A!=1 & f29.BREAK_A!=1 & f30.BREAK_A!=1 & f31.BREAK_A!=1 & f32.BREAK_A!=1 & f33.BREAK_A!=1 & f34.BREAK_A!=1 & f35.BREAK_A!=1 & f36.BREAK_A!=1 & f37.BREAK_A!=1 & f38.BREAK_A!=1 & f39.BREAK_A!=1 & f40.BREAK_A!=1 & f41.BREAK_A!=1 & f42.BREAK_A!=1 & f43.BREAK_A!=1 & f44.BREAK_A!=1 & f45.BREAK_A!=1 & f46.BREAK_A!=1 & f47.BREAK_A!=1 & f48.BREAK_A!=1 & f49.BREAK_A!=1 & f50.BREAK_A!=1 & f51.BREAK_A!=1 & f52.BREAK_A!=1 & f53.BREAK_A!=1 & f54.BREAK_A!=1 & f55.BREAK_A!=1 & f56.BREAK_A!=1 & f57.BREAK_A!=1 & f58.BREAK_A!=1 & f59.BREAK_A!=1 & f60.BREAK_A!=1 & f61.BREAK_A!=1 & f62.BREAK_A!=1 & f63.BREAK_A!=1 & f64.BREAK_A!=1 & f65.BREAK_A!=1 & f66.BREAK_A!=1 & f67.BREAK_A!=1 & f68.BREAK_A!=1 & f69.BREAK_A!=1 & f70.BREAK_A!=1 & f71.BREAK_A!=1 & f72.BREAK_A!=1 & f73.BREAK_A!=1 & f74.BREAK_A!=1 & f75.BREAK_A!=1 & f76.BREAK_A!=1 & f77.BREAK_A!=1 & f78.BREAK_A!=1 & f79.BREAK_A!=1 & f80.BREAK_A!=1 & f81.BREAK_A!=1 & f82.BREAK_A!=1 & f83.BREAK_A!=1 & f84.BREAK_A!=1 & f85.BREAK_A!=1 & f86.BREAK_A!=1 & f87.BREAK_A!=1 & f88.BREAK_A!=1 & f89.BREAK_A!=1 & f90.BREAK_A!=1 & f91.BREAK_A!=1 & f92.BREAK_A!=1 & f93.BREAK_A!=1 & f94.BREAK_A!=1 & f95.BREAK_A!=1 & f96.BREAK_A!=1 & f97.BREAK_A!=1 & f98.BREAK_A!=1 & f99.BREAK_A!=1 & f100.BREAK_A!=1 & f101.BREAK_A!=1 & f102.BREAK_A!=1 & f103.BREAK_A!=1 & f104.BREAK_A!=1 & f105.BREAK_A!=1 & f106.BREAK_A!=1 & f107.BREAK_A!=1 & f108.BREAK_A!=1 & f109.BREAK_A!=1 & f110.BREAK_A!=1 & f111.BREAK_A!=1 & f112.BREAK_A!=1 & f113.BREAK_A!=1 & f114.BREAK_A!=1 & f115.BREAK_A!=1 & f116.BREAK_A!=1 & f117.BREAK_A!=1 & f118.BREAK_A!=1 & f119.BREAK_A!=1 & f120.BREAK_A!=1 & f121.BREAK_A!=1 & f122.BREAK_A!=1 & f123.BREAK_A!=1 & f124.BREAK_A!=1 & f125.BREAK_A!=1 & f126.BREAK_A!=1 & f127.BREAK_A!=1 & f128.BREAK_A!=1 & f129.BREAK_A!=1 & f130.BREAK_A!=1 & f131.BREAK_A!=1 & f132.BREAK_A!=1 & f133.BREAK_A!=1 & f134.BREAK_A!=1 & f135.BREAK_A!=1
xtset gvkey qtr
gen lag_UE = l.UE_old
gen any_string_A = 0
replace any_string_A = 1 if STRING1_A==1 | STRING2_A==1 | STRING3_A==1 | STRING4UP_A==1
replace any_string_A=. if STRING1_A==. & STRING2_A==. & STRING3_A==. & STRING4UP_A==.
gen LONGSTRING_A = 0
replace LONGSTRING_A = 1 if any_string_A==1 & l.chg_eps>=0 & l2.chg_eps>=0 & l3.chg_eps>=0 & l.chg_eps!=. & l2.chg_eps!=. & l3.chg_eps!=.  
replace LONGSTRING_A = 1 if BREAK_A==1 & l.chg_eps>=0 & l2.chg_eps>=0 & l3.chg_eps>=0 & l.chg_eps!=. & l2.chg_eps!=. & l3.chg_eps!=.
replace LONGSTRING_A = . if l.chg_eps==. | l2.chg_eps==. | l3.chg_eps==.
replace LONGSTRING_A = . if BREAK_A==. & any_string_A==.	
gen LB_A = 0
replace LB_A = 1 if BREAK_A==1 & f.chg_eps<0 & f2.chg_eps<0
replace LB_A = . if BREAK_A==. | f.chg_eps==. | f2.chg_eps==.
gen LONGBREAK_A = 0
replace LONGBREAK_A=. if BREAK_A==. & any_string_A==.
replace LONGBREAK_A = 1 if STRING1_A==1 & f.LB_A==1
replace LONGBREAK_A = 1 if STRING2_A==1 & f2.LB_A==1
replace LONGBREAK_A = 1 if STRING3_A==1 & f3.LB_A==1
replace LONGBREAK_A = 1 if BREAK_A==1 & LB_A==1
gen STRING4UP_b = STRING4UP_A
gen LB = LB_A
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f4.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==0 & f5.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==0 & f6.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==0 & f7.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==0 & f8.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==0 & f9.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==0 & f10.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==0 & f11.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==0 & f12.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==0 & f13.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==0 & f14.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==0 & f15.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==0 & f16.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==0 & f17.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==0 & f18.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==0 & f19.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==0 & f20.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==0 & f21.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==0 & f22.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==0 & f23.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==0 & f24.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==0 & f25.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==0 & f26.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==0 & f27.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==0 & f28.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==0 & f29.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==0 & f30.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==0 & f31.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==0 & f33.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==0 & f34.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==0 & f35.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==0 & f36.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==0 & f37.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==0 & f38.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==0 & f39.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==0 & f40.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==0 & f41.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==0 & f42.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==0 & f43.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==1 & f41.STRING4UP_b==0 & f44.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==1 & f41.STRING4UP_b==1 & f42.STRING4UP_b==0 & f45.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==1 & f41.STRING4UP_b==1 & f42.STRING4UP_b==1 & f43.STRING4UP_b==0 & f46.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==1 & f41.STRING4UP_b==1 & f42.STRING4UP_b==1 & f43.STRING4UP_b==1 & f44.STRING4UP_b==0 & f47.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==1 & f41.STRING4UP_b==1 & f42.STRING4UP_b==1 & f43.STRING4UP_b==1 & f44.STRING4UP_b==1 & f45.STRING4UP_b==0 & f48.LB==1
replace LONGBREAK_A = 1 if STRING4UP_b==1 & f.STRING4UP_b==1 & f2.STRING4UP_b==1 & f3.STRING4UP_b==1 & f4.STRING4UP_b==1 & f5.STRING4UP_b==1 & f6.STRING4UP_b==1 & f7.STRING4UP_b==1 & f8.STRING4UP_b==1 & f9.STRING4UP_b==1 & f10.STRING4UP_b==1 & f11.STRING4UP_b==1 & f12.STRING4UP_b==1 & f13.STRING4UP_b==1 & f14.STRING4UP_b==1 & f15.STRING4UP_b==1 & f16.STRING4UP_b==1 & f17.STRING4UP_b==1 & f18.STRING4UP_b==1 & f19.STRING4UP_b==1 & f20.STRING4UP_b==1 & f21.STRING4UP_b==1 & f22.STRING4UP_b==1 & f23.STRING4UP_b==1 & f24.STRING4UP_b==1 & f25.STRING4UP_b==1 & f26.STRING4UP_b==1 & f27.STRING4UP_b==1 & f28.STRING4UP_b==1 & f29.STRING4UP_b==1 & f30.STRING4UP_b==1 & f31.STRING4UP_b==1 & f32.STRING4UP_b==1 & f33.STRING4UP_b==1 & f34.STRING4UP_b==1 & f35.STRING4UP_b==1 & f36.STRING4UP_b==1 & f37.STRING4UP_b==1 & f38.STRING4UP_b==1 & f39.STRING4UP_b==1 & f40.STRING4UP_b==1 & f41.STRING4UP_b==1 & f42.STRING4UP_b==1 & f43.STRING4UP_b==1 & f44.STRING4UP_b==1 & f45.STRING4UP_b==1 & f46.STRING4UP_b==0 & f49.LB==1
gen id_A = 0
replace id_A = 1 if any_string_A==1 | BREAK_A==1		
gen BREAK = BREAK_A
gen STRING1 = STRING1_A
gen STRING2 = STRING2_A
gen STRING3 = STRING3_A
gen STRING4UP = STRING4UP_A
rename LONGSTRING_A longstring
rename LONGBREAK_A longbreak
gen error2=0
replace error2=1 if STRING4UP==1 & f.STRING4UP!=1 & f4.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP!=1 & f5.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP!=1 & f6.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP!=1 & f7.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP!=1 & f8.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP!=1 & f9.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP!=1 & f10.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP!=1 & f11.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP!=1 & f12.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP!=1 & f13.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP!=1 & f14.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP!=1 & f15.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP!=1 & f16.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP!=1 & f17.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP!=1 & f18.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP!=1 & f19.chg_eps>=0
replace error2=1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP!=1 & f20.chg_eps>=0
drop if error2==1 & censor==0
drop error2
rename rdq ea_date
drop if ea_date==.	
duplicates report cusip ea_date
duplicates tag cusip ea_date, gen(dup)
gsort cusip ea_date dup -datafqtr
duplicates drop cusip ea_date, force
duplicates report cusip ea_date

* MERGE CRSP DAILY * 
merge 1:1 cusip ea_date using rfd_crsp_d_F
drop if _merge==2
drop _merge

rename UE_old UE
drop LN_lag_MV lag_BM lag_RETQ1 lag_RETQ24
gen month2 = month(datadate)
gen calquart = .
replace calquart = 1 if month2==1 | month2==2 | month2==3
replace calquart = 2 if month2==4 | month2==5 | month2==6
replace calquart = 3 if month2==7 | month2==8 | month2==9
replace calquart = 4 if month2==10 | month2==11 | month2==12
rename qtr quart
drop BREAK_A STRING1_A STRING2_A STRING3_A STRING4UP_A any_string_A STRING4UP_b	
drop if censor==1		
drop censor
keep if fyr==3 | fyr==6 | fyr==9 | fyr==12
gen diff = ea_date - datadate
drop if diff>60
drop if BREAK==. | STRING1==. | STRING2==. | STRING3==. | STRING4UP==. | longstring==. | longbreak==.
drop if quart<139

* MERGE IBES EPS FORECASTS * 
merge 1:1 cusip quart using ibes1_F
drop if _merge==2
drop _merge

* MERGE IBES RECOMMENDATIONS * 
merge 1:1 cusip quart using ibes2_F
drop if _merge==2
drop _merge

* MERGE ADR FIRMS * 
merge 1:1 cusip quart using ADR_Firms
drop if _merge==2
drop _merge

drop if adr==1
duplicates report cusip quart

* MERGE TRANSIENT INSTITUTIONAL OWNERSHIP VARIABLES * 
merge 1:1 cusip quart using trs34_variables
keep if _merge==3
drop _merge	

drop if quart>158 & quart<163
rename tbegown trabegown
rename dmedrec drec
drop if trabegown==0	
replace traportwt = traportwt*100	
areg trachg2 BREAK STRING1 STRING2 STRING3 STRING4UP longbreak longstring LN_MV BM RETQ24 RETQ1 RETQ0 UE traportwt dforecast drec trabegown i.year i.calquart, absorb(gvkey)	
keep if e(sample)
	/*	trachg2 --> ∆TRA
		BREAK --> STRING0
		traportwt --> PORTWT
		dforecast --> ∆FORECAST
		drec --> ∆RECOMMEND
		trabegown --> TRAOWN
	*/
gen id_new = 0
replace id_new = 1 if BREAK==1 | STRING1==1 | STRING2==1 | STRING3==1 | STRING4UP==1
egen median_new = median(BM) if id_new==1
gen growth = 0
replace growth = 1 if id_new==1 & BM < median_new
sort gvkey quart		
egen median_new_2 = median(chg_eps) if BREAK==1
gen LD = 0
replace LD = 1 if BREAK==1 & chg_eps < median_new_2
gen largedecline = 0
xtset gvkey quart
replace largedecline = 1 if BREAK==1 & LD==1
replace largedecline = 1 if STRING1==1 & f.LD==1
replace largedecline = 1 if STRING2==1 & f2.LD==1
replace largedecline = 1 if STRING3==1 & f3.LD==1
replace largedecline = 1 if STRING4UP==1 & f4.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==0 & f5.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==0 & f6.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==0 & f7.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==0 & f8.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==0 & f9.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==0 & f10.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==0 & f11.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==0 & f12.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==0 & f13.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==0 & f14.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==0 & f15.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==0 & f16.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==0 & f17.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==0 & f18.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==0 & f19.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==0 & f20.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==0 & f21.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==0 & f22.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==0 & f23.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==0 & f24.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==0 & f25.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==0 & f26.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==0 & f27.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==0 & f28.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==0 & f29.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==0 & f30.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==0 & f31.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==0 & f32.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==0 & f33.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==0 & f34.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==0 & f35.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==0 & f36.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==0 & f37.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==0 & f38.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==0 & f39.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==0 & f40.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==0 & f41.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==0 & f42.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==0 & f43.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==1 & f41.STRING4UP==0 & f44.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==1 & f41.STRING4UP==1 & f42.STRING4UP==0 & f45.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==1 & f41.STRING4UP==1 & f42.STRING4UP==1 & f43.STRING4UP==0 & f46.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==1 & f41.STRING4UP==1 & f42.STRING4UP==1 & f43.STRING4UP==1 & f44.STRING4UP==0 & f47.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==1 & f41.STRING4UP==1 & f42.STRING4UP==1 & f43.STRING4UP==1 & f44.STRING4UP==1 & f45.STRING4UP==0 & f48.LD==1
replace largedecline = 1 if STRING4UP==1 & f.STRING4UP==1 & f2.STRING4UP==1 & f3.STRING4UP==1 & f4.STRING4UP==1 & f5.STRING4UP==1 & f6.STRING4UP==1 & f7.STRING4UP==1 & f8.STRING4UP==1 & f9.STRING4UP==1 & f10.STRING4UP==1 & f11.STRING4UP==1 & f12.STRING4UP==1 & f13.STRING4UP==1 & f14.STRING4UP==1 & f15.STRING4UP==1 & f16.STRING4UP==1 & f17.STRING4UP==1 & f18.STRING4UP==1 & f19.STRING4UP==1 & f20.STRING4UP==1 & f21.STRING4UP==1 & f22.STRING4UP==1 & f23.STRING4UP==1 & f24.STRING4UP==1 & f25.STRING4UP==1 & f26.STRING4UP==1 & f27.STRING4UP==1 & f28.STRING4UP==1 & f29.STRING4UP==1 & f30.STRING4UP==1 & f31.STRING4UP==1 & f32.STRING4UP==1 & f33.STRING4UP==1 & f34.STRING4UP==1 & f35.STRING4UP==1 & f36.STRING4UP==1 & f37.STRING4UP==1 & f38.STRING4UP==1 & f39.STRING4UP==1 & f40.STRING4UP==1 & f41.STRING4UP==1 & f42.STRING4UP==1 & f43.STRING4UP==1 & f44.STRING4UP==1 & f45.STRING4UP==1 & f46.STRING4UP==0 & f49.LD==1		
replace trachg2 = trachg2*100
replace trabegown = trabegown*100
gen BREAK_x_longstring = BREAK*longstring	
gen BREAK_x_longbreak = BREAK*longbreak	
gen BREAK_x_growth = BREAK*growth
gen BREAK_x_largedecline = BREAK*largedecline	
gen STRING1_x_longstring = STRING1*longstring	
gen STRING1_x_longbreak = STRING1*longbreak	
gen STRING1_x_growth = STRING1*growth
gen STRING1_x_largedecline = STRING1*largedecline	
gen STRING2_x_longstring = STRING2*longstring	
gen STRING2_x_longbreak = STRING2*longbreak	
gen STRING2_x_growth = STRING2*growth
gen STRING2_x_largedecline = STRING2*largedecline	
gen STRING3_x_longstring = STRING3*longstring	
gen STRING3_x_longbreak = STRING3*longbreak	
gen STRING3_x_growth = STRING3*growth
gen STRING3_x_largedecline = STRING3*largedecline	
gen STRING4UP_x_longstring = STRING4UP*longstring	
gen STRING4UP_x_longbreak = STRING4UP*longbreak	
gen STRING4UP_x_growth = STRING4UP*growth
gen STRING4UP_x_largedecline = STRING4UP*largedecline	
gen post = 0
replace post = 1 if quart>158
gen BREAK_x_post = BREAK*post
gen STRING1_x_post = STRING1*post
gen STRING2_x_post = STRING2*post
gen STRING3_x_post = STRING3*post
gen STRING4UP_x_post = STRING4UP*post
gen BREAK_x_longbreak_x_post = BREAK_x_longbreak*post
gen STRING1_x_longbreak_x_post = STRING1_x_longbreak*post
gen STRING2_x_longbreak_x_post = STRING2_x_longbreak*post
gen STRING3_x_longbreak_x_post = STRING3_x_longbreak*post
gen STRING4UP_x_longbreak_x_post = STRING4UP_x_longbreak*post
gen BREAK_x_largedecline_x_post = BREAK_x_largedecline*post
gen STRING1_x_largedecline_x_post = STRING1_x_largedecline*post
gen STRING2_x_largedecline_x_post = STRING2_x_largedecline*post
gen STRING3_x_largedecline_x_post = STRING3_x_largedecline*post
gen STRING4UP_x_largedecline_x_post = STRING4UP_x_largedecline*post
gen BREAK_x_longstring_x_post = BREAK_x_longstring*post
gen STRING1_x_longstring_x_post = STRING1_x_longstring*post
gen STRING2_x_longstring_x_post = STRING2_x_longstring*post
gen STRING3_x_longstring_x_post = STRING3_x_longstring*post
gen STRING4UP_x_longstring_x_post = STRING4UP_x_longstring*post
gen BREAK_x_growth_x_post = BREAK_x_growth*post
gen STRING1_x_growth_x_post = STRING1_x_growth*post
gen STRING2_x_growth_x_post = STRING2_x_growth*post
gen STRING3_x_growth_x_post = STRING3_x_growth*post
gen STRING4UP_x_growth_x_post = STRING4UP_x_growth*post
save ABKP_1995_to_2017, replace
	
	

/// EARNINGS BREAK ANALYSIS: SAMPLE FOR TABLE 2 (BEFORE REMOVING OUTLIERS) ///
use ABKP_1995_to_2017, clear
drop if quart>198
drop if quart==181
gen postRFD = 0
replace postRFD = 1 if quart>158 & quart<181
gen postS = 0
replace postS = 1 if quart>181
gen BREAK_x_postRFD = BREAK*postRFD
gen STRING1_x_postRFD = STRING1*postRFD
gen STRING2_x_postRFD = STRING2*postRFD
gen STRING3_x_postRFD = STRING3*postRFD
gen STRING4UP_x_postRFD = STRING4UP*postRFD
gen BREAK_x_longbreak_x_postRFD = BREAK_x_longbreak*postRFD
gen STRING1_x_longbreak_x_postRFD = STRING1_x_longbreak*postRFD
gen STRING2_x_longbreak_x_postRFD = STRING2_x_longbreak*postRFD
gen STRING3_x_longbreak_x_postRFD = STRING3_x_longbreak*postRFD
gen STRING4UP_x_longbreak_x_postRFD = STRING4UP_x_longbreak*postRFD
gen BREAK_x_largedecline_x_postRFD = BREAK_x_largedecline*postRFD
gen STRING1_x_largedecline_x_postRFD = STRING1_x_largedecline*postRFD
gen STRING2_x_largedecline_x_postRFD = STRING2_x_largedecline*postRFD
gen STRING3_x_largedecline_x_postRFD = STRING3_x_largedecline*postRFD
gen STRING4UP_x_lgedecline_x_postRFD = STRING4UP_x_largedecline*postRFD
gen BREAK_x_longstring_x_postRFD = BREAK_x_longstring*postRFD
gen STRING1_x_longstring_x_postRFD = STRING1_x_longstring*postRFD
gen STRING2_x_longstring_x_postRFD = STRING2_x_longstring*postRFD
gen STRING3_x_longstring_x_postRFD = STRING3_x_longstring*postRFD
gen STRING4UP_x_longstring_x_postRFD = STRING4UP_x_longstring*postRFD
gen BREAK_x_growth_x_postRFD = BREAK_x_growth*postRFD
gen STRING1_x_growth_x_postRFD = STRING1_x_growth*postRFD
gen STRING2_x_growth_x_postRFD = STRING2_x_growth*postRFD
gen STRING3_x_growth_x_postRFD = STRING3_x_growth*postRFD
gen STRING4UP_x_growth_x_postRFD = STRING4UP_x_growth*postRFD
gen BREAK_x_postS = BREAK*postS
gen STRING1_x_postS = STRING1*postS
gen STRING2_x_postS = STRING2*postS
gen STRING3_x_postS = STRING3*postS
gen STRING4UP_x_postS = STRING4UP*postS
gen BREAK_x_longbreak_x_postS = BREAK_x_longbreak*postS
gen STRING1_x_longbreak_x_postS = STRING1_x_longbreak*postS
gen STRING2_x_longbreak_x_postS = STRING2_x_longbreak*postS
gen STRING3_x_longbreak_x_postS = STRING3_x_longbreak*postS
gen STRING4UP_x_longbreak_x_postS = STRING4UP_x_longbreak*postS
gen BREAK_x_largedecline_x_postS = BREAK_x_largedecline*postS
gen STRING1_x_largedecline_x_postS = STRING1_x_largedecline*postS
gen STRING2_x_largedecline_x_postS = STRING2_x_largedecline*postS
gen STRING3_x_largedecline_x_postS = STRING3_x_largedecline*postS
gen STRING4UP_x_largedecline_x_postS = STRING4UP_x_largedecline*postS
gen BREAK_x_longstring_x_postS = BREAK_x_longstring*postS
gen STRING1_x_longstring_x_postS = STRING1_x_longstring*postS
gen STRING2_x_longstring_x_postS = STRING2_x_longstring*postS
gen STRING3_x_longstring_x_postS = STRING3_x_longstring*postS
gen STRING4UP_x_longstring_x_postS = STRING4UP_x_longstring*postS
gen BREAK_x_growth_x_postS = BREAK_x_growth*postS
gen STRING1_x_growth_x_postS = STRING1_x_growth*postS
gen STRING2_x_growth_x_postS = STRING2_x_growth*postS
gen STRING3_x_growth_x_postS = STRING3_x_growth*postS
gen STRING4UP_x_growth_x_postS = STRING4UP_x_growth*postS
gen LN_MV_x_postRFD = LN_MV*postRFD
gen BM_x_postRFD = BM*postRFD
gen RETQ24_x_postRFD = RETQ24*postRFD
gen RETQ1_x_postRFD = RETQ1*postRFD
gen RETQ0_x_postRFD = RETQ0*postRFD
gen UE_x_postRFD = UE*postRFD
gen traportwt_x_postRFD = traportwt*postRFD
gen dforecast_x_postRFD = dforecast*postRFD
gen drec_x_postRFD = drec*postRFD
gen trabegown_x_postRFD = trabegown*postRFD
gen LN_MV_x_postS = LN_MV*postS
gen BM_x_postS = BM*postS
gen RETQ24_x_postS = RETQ24*postS
gen RETQ1_x_postS = RETQ1*postS
gen RETQ0_x_postS = RETQ0*postS
gen UE_x_postS = UE*postS
gen traportwt_x_postS = traportwt*postS
gen dforecast_x_postS = dforecast*postS
gen drec_x_postS = drec*postS
gen trabegown_x_postS = trabegown*postS
save ABKP_Sample_Table2, replace	



/// EARNINGS BREAK ANALYSIS: SAMPLE FOR TABLE 3 (BEFORE REMOVING OUTLIERS) ///
use ABKP_1995_to_2017, clear
bysort permno: egen min_quart = min(quart)
sort permno quart

* MERGE CONFERENCE CALL DATA * 
merge m:1 permno using CLOSED_Data
drop if _merge==2

gen closedcall=0
replace closedcall=1 if _merge==3 & closed==1
gen opencall=0
replace opencall=1 if _merge==3 & closed==0
drop _merge	
drop if quart>198
drop if quart==181
gen postRFD = 0
replace postRFD = 1 if quart>158 & quart<181
gen postS = 0
replace postS = 1 if quart>181
gen BREAK_x_postRFD = BREAK*postRFD
gen STRING1_x_postRFD = STRING1*postRFD
gen STRING2_x_postRFD = STRING2*postRFD
gen STRING3_x_postRFD = STRING3*postRFD
gen STRING4UP_x_postRFD = STRING4UP*postRFD
gen BREAK_x_longbreak_x_postRFD = BREAK_x_longbreak*postRFD
gen STRING1_x_longbreak_x_postRFD = STRING1_x_longbreak*postRFD
gen STRING2_x_longbreak_x_postRFD = STRING2_x_longbreak*postRFD
gen STRING3_x_longbreak_x_postRFD = STRING3_x_longbreak*postRFD
gen STRING4UP_x_longbreak_x_postRFD = STRING4UP_x_longbreak*postRFD
gen BREAK_x_largedecline_x_postRFD = BREAK_x_largedecline*postRFD
gen STRING1_x_largedecline_x_postRFD = STRING1_x_largedecline*postRFD
gen STRING2_x_largedecline_x_postRFD = STRING2_x_largedecline*postRFD
gen STRING3_x_largedecline_x_postRFD = STRING3_x_largedecline*postRFD
gen STRING4UP_x_lgedecline_x_postRFD = STRING4UP_x_largedecline*postRFD
gen BREAK_x_longstring_x_postRFD = BREAK_x_longstring*postRFD
gen STRING1_x_longstring_x_postRFD = STRING1_x_longstring*postRFD
gen STRING2_x_longstring_x_postRFD = STRING2_x_longstring*postRFD
gen STRING3_x_longstring_x_postRFD = STRING3_x_longstring*postRFD
gen STRING4UP_x_longstring_x_postRFD = STRING4UP_x_longstring*postRFD
gen BREAK_x_growth_x_postRFD = BREAK_x_growth*postRFD
gen STRING1_x_growth_x_postRFD = STRING1_x_growth*postRFD
gen STRING2_x_growth_x_postRFD = STRING2_x_growth*postRFD
gen STRING3_x_growth_x_postRFD = STRING3_x_growth*postRFD
gen STRING4UP_x_growth_x_postRFD = STRING4UP_x_growth*postRFD
gen BREAK_x_postS = BREAK*postS
gen STRING1_x_postS = STRING1*postS
gen STRING2_x_postS = STRING2*postS
gen STRING3_x_postS = STRING3*postS
gen STRING4UP_x_postS = STRING4UP*postS
gen BREAK_x_longbreak_x_postS = BREAK_x_longbreak*postS
gen STRING1_x_longbreak_x_postS = STRING1_x_longbreak*postS
gen STRING2_x_longbreak_x_postS = STRING2_x_longbreak*postS
gen STRING3_x_longbreak_x_postS = STRING3_x_longbreak*postS
gen STRING4UP_x_longbreak_x_postS = STRING4UP_x_longbreak*postS
gen BREAK_x_largedecline_x_postS = BREAK_x_largedecline*postS
gen STRING1_x_largedecline_x_postS = STRING1_x_largedecline*postS
gen STRING2_x_largedecline_x_postS = STRING2_x_largedecline*postS
gen STRING3_x_largedecline_x_postS = STRING3_x_largedecline*postS
gen STRING4UP_x_largedecline_x_postS = STRING4UP_x_largedecline*postS
gen BREAK_x_longstring_x_postS = BREAK_x_longstring*postS
gen STRING1_x_longstring_x_postS = STRING1_x_longstring*postS
gen STRING2_x_longstring_x_postS = STRING2_x_longstring*postS
gen STRING3_x_longstring_x_postS = STRING3_x_longstring*postS
gen STRING4UP_x_longstring_x_postS = STRING4UP_x_longstring*postS
gen BREAK_x_growth_x_postS = BREAK_x_growth*postS
gen STRING1_x_growth_x_postS = STRING1_x_growth*postS
gen STRING2_x_growth_x_postS = STRING2_x_growth*postS
gen STRING3_x_growth_x_postS = STRING3_x_growth*postS
gen STRING4UP_x_growth_x_postS = STRING4UP_x_growth*postS
gen LN_MV_x_postRFD = LN_MV*postRFD
gen BM_x_postRFD = BM*postRFD
gen RETQ24_x_postRFD = RETQ24*postRFD
gen RETQ1_x_postRFD = RETQ1*postRFD
gen RETQ0_x_postRFD = RETQ0*postRFD
gen UE_x_postRFD = UE*postRFD
gen traportwt_x_postRFD = traportwt*postRFD
gen dforecast_x_postRFD = dforecast*postRFD
gen drec_x_postRFD = drec*postRFD
gen trabegown_x_postRFD = trabegown*postRFD
gen LN_MV_x_postS = LN_MV*postS
gen BM_x_postS = BM*postS
gen RETQ24_x_postS = RETQ24*postS
gen RETQ1_x_postS = RETQ1*postS
gen RETQ0_x_postS = RETQ0*postS
gen UE_x_postS = UE*postS
gen traportwt_x_postS = traportwt*postS
gen dforecast_x_postS = dforecast*postS
gen drec_x_postS = drec*postS
gen trabegown_x_postS = trabegown*postS
keep if min_quart<159
save ABKP_Sample_Table3, replace	


	   
/// EARNINGS BREAK ANALYSIS: SAMPLE FOR TABLE 4 ///
use ABKP_1995_to_2017, clear

* LIMIT SAMPLE TO POST-REG FD *
merge 1:1 gvkey quart using invconfsample
keep if _merge==3
drop _merge

* MERGE CONFERENCE CALL DATA * 
merge m:1 cusip using INVCONF_Data
drop if _merge==2

gen INVCONF=0
replace INVCONF=1 if _merge==3
drop _merge			   		   
drop post BREAK_x_post STRING1_x_post STRING2_x_post STRING3_x_post STRING4UP_x_post BREAK_x_longbreak_x_post STRING1_x_longbreak_x_post STRING2_x_longbreak_x_post STRING3_x_longbreak_x_post STRING4UP_x_longbreak_x_post BREAK_x_largedecline_x_post STRING1_x_largedecline_x_post STRING2_x_largedecline_x_post STRING3_x_largedecline_x_post STRING4UP_x_largedecline_x_post BREAK_x_longstring_x_post STRING1_x_longstring_x_post STRING2_x_longstring_x_post STRING3_x_longstring_x_post STRING4UP_x_longstring_x_post BREAK_x_growth_x_post STRING1_x_growth_x_post STRING2_x_growth_x_post STRING3_x_growth_x_post STRING4UP_x_growth_x_post
gen post = 0
replace post = 1 if quart>181
gen BREAK_x_post = BREAK*post
gen STRING1_x_post = STRING1*post
gen STRING2_x_post = STRING2*post
gen STRING3_x_post = STRING3*post
gen STRING4UP_x_post = STRING4UP*post
gen BREAK_x_longbreak_x_post = BREAK_x_longbreak*post
gen STRING1_x_longbreak_x_post = STRING1_x_longbreak*post
gen STRING2_x_longbreak_x_post = STRING2_x_longbreak*post
gen STRING3_x_longbreak_x_post = STRING3_x_longbreak*post
gen STRING4UP_x_longbreak_x_post = STRING4UP_x_longbreak*post
gen BREAK_x_largedecline_x_post = BREAK_x_largedecline*post
gen STRING1_x_largedecline_x_post = STRING1_x_largedecline*post
gen STRING2_x_largedecline_x_post = STRING2_x_largedecline*post
gen STRING3_x_largedecline_x_post = STRING3_x_largedecline*post
gen STRING4UP_x_largedecline_x_post = STRING4UP_x_largedecline*post
gen BREAK_x_longstring_x_post = BREAK_x_longstring*post
gen STRING1_x_longstring_x_post = STRING1_x_longstring*post
gen STRING2_x_longstring_x_post = STRING2_x_longstring*post
gen STRING3_x_longstring_x_post = STRING3_x_longstring*post
gen STRING4UP_x_longstring_x_post = STRING4UP_x_longstring*post
gen BREAK_x_growth_x_post = BREAK_x_growth*post
gen STRING1_x_growth_x_post = STRING1_x_growth*post
gen STRING2_x_growth_x_post = STRING2_x_growth*post
gen STRING3_x_growth_x_post = STRING3_x_growth*post
gen STRING4UP_x_growth_x_post = STRING4UP_x_growth*post
gen LN_MV_x_post = LN_MV*post
gen BM_x_post = BM*post
gen RETQ24_x_post = RETQ24*post
gen RETQ1_x_post = RETQ1*post
gen RETQ0_x_post = RETQ0*post
gen UE_x_post = UE*post
gen traportwt_x_post = traportwt*post
gen dforecast_x_post = dforecast*post
gen drec_x_post = drec*post
gen trabegown_x_post = trabegown*post 
save ABKP_Sample_Table4, replace	



/// EARNINGS BREAK ANALYSIS: SAMPLE FOR TABLE 5 (BEFORE REMOVING OUTLIERS) ///
use ABKP_Sample_Table2, clear

* MERGE LARGE AND SMALL TRANSIENT OWNERSHIP (DERIVED FROM "trs34_variables") * 
merge 1:1 cusip quart using TRA_LG_TRA_SM_Data
drop if _merge==2
drop _merge

save ABKP_Sample_Table5, replace	

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



********************************************************************************
/*
	This code creates the BAR measures (TABLES 6-7) following:
		Baker et al. [2010] (doi: 10.1017/S0022109010000426) and
		Bhojraj et al. [2012] (doi: 10.1111/j.1475-679X.2011.00436.x).
	
	Steps in computing BAR:
	A) Create benchmark-adjusted earnings announcement returns
	B) Compute institution weight changes in portfolio firms
	C) Compute BAR measures
	
	Tests of BAR significance are based on t-tests of means.
*/
********************************************************************************



/*
  A) STEP-BY-STEP GUIDE FOR COMPUTING BENCHMARK-ADJUSTED EARNINGS ANNOUNCEMENT RETURNS:
	
	1) Sort firms into 5x5x5 portfolios following Daniel et al. [1997] (doi: 10.1111/j.1540-6261.1997.tb02724.x)
	2) Load Compustat Fundamentals Quarterly
	3) Merge Compustat to CRSP
	4) Retain observations wth non-missing earnings announcement dates (i.e., RDQ != .)
	5) Merge Compustat to CRSP Daily Returns file on PERMNO and RDQ date
	6) Compute stock i's 3-day [-1,+1] cumulative raw return surrounding RDQ-date t
	7) Compute each stock i's benchmark-adjusted EA return as the 3-day return less the 3-day return on the corresponding 5x5x5 (Daniel et al. [1997]) benchmark return
	8) Final EA return table contains:
		permno, cusip, rdq, eabmret, quart
		where "eabmret" is computed following above steps, and
		where "quart" = qofd(rdq)
	   
	* For referencing above .dta file, in code below: "rdq_dgtw_3d_returns.dta"
*/

* 	Quarts:
	* 1995: 140-143		1999: 156-159		2004: 176-179		2008: 192-195
	* 1996: 144-147		2001: 164-167		2005: 180-183		2009: 196-199
	* 1997: 148-151		2002: 168-171		2006: 184-187		2010: 200-203
	* 1998: 152-155		2003: 172-175 		2007: 188-191		2011: 204-207

* B and C) Compute institution weight changes in portfolio firms and compute BAR measures

	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL A:
	* BAR1 (Stock-picking ability based on all buys and all sales
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1 = allbuys - allsales
	
	save "bar1_for_T6-PanelA", replace
	
	* Code for testing BAR significance by sample testing period:
	
	ttest bar1=0 if preRFD==1
	ttest bar1=0 if postRFD_preSBL==1
	ttest bar1=0 if postSBL==1
	
	* Code to test across time periods:
	
	gen period=1 if quart<=162
		replace period=2 if quart>=163 & quart<=182
		replace period=3 if quart>=183
		
	ttest bar1 if period!=3, by(period)
	ttest bar1 if period!=1, by(period)
	ttest bar1 if period!=2, by(period)
	
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2 (Stock-picking ability based on entries & exits:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2 = entrybuys - exitsales
	
	save "bar2_for_T6-PanelA", replace
	
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL B:
	* BAR1_CL
	
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	* Note that data below come from Dawn Matsumoto using Bestcalls.com conference data
	* closed is an indicator=1 if a firm held a closed conf-call pre-Reg FD.
	
	joinby permno using "preRFD_closed_confcall_firms.dta"
		keep if closed==1
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1cl = allbuys - allsales
	
	save "bar1cl_for_T6-PanelB", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2_CL:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	joinby permno using "preRFD_closed_confcall_firms.dta"
		keep if closed==1
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2cl = entrybuys - exitsales
	
	save "bar2cl_for_T6-PanelB", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL B:
	* BAR1_OP
	
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	joinby permno using "preRFD_closed_confcall_firms.dta"
		keep if closed==0
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1op = allbuys - allsales
	
	save "bar1op_for_T6-PanelB", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2_OP:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	joinby permno using "preRFD_closed_confcall_firms.dta"
		keep if closed==0
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2op = entrybuys - exitsales
	
	save "bar2op_for_T6-PanelB", replace
	
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL C:
	* BAR1_A
	
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	* Note that data below come from the Thomson Reuters Eikon database
	* invconf is an indicator=1 if a firm attended an investor conference pre-Siebel.
	
	joinby permno using "preSBL_InvConf_attend.dta", unmatched(master)
		keep if invconf==1
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1a = allbuys - allsales
	
	save "bar1a_for_T6-PanelC", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2_A:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	joinby permno using "preSBL_InvConf_attend.dta", unmatched(master)
		keep if invconf==1
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2a = entrybuys - exitsales
	
	save "bar2a_for_T6-PanelC", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL C:
	* BAR1_NA
	
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	joinby permno using "preSBL_InvConf_attend.dta", unmatched(master)
		keep if invconf==.
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1na = allbuys - allsales
	
	save "bar1na_for_T6-PanelC", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2_NA:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	joinby permno using "preSBL_InvConf_attend.dta", unmatched(master)
		keep if invconf==.
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2na = entrybuys - exitsales
	
	save "bar2na_for_T6-PanelC", replace
	
	
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL D:
	* BAR1_LG
	
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	egen maxperc=rowmax(begperc endperc)
	gsort cusip quart -maxperc
	egen total=count(cusip),by(cusip quart)
	by cusip quart: gen sort=_n
	gen rank=sort/total
	gen lg=rank<=0.50
	gen sm=lg==0
	
	keep if lg==1
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1lg = allbuys - allsales
	
	save "bar1lg_for_T6-PanelD", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2_LG:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	egen maxperc=rowmax(begperc endperc)
	gsort cusip quart -maxperc
	egen total=count(cusip),by(cusip quart)
	by cusip quart: gen sort=_n
	gen rank=sort/total
	gen lg=rank<=0.50
	gen sm=lg==0
	
	keep if lg==1
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2lg = entrybuys - exitsales
	
	save "bar2lg_for_T6-PanelD", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* TABLE 6, PANEL D:
	* BAR1_SM
	
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	egen maxperc=rowmax(begperc endperc)
	gsort cusip quart -maxperc
	egen total=count(cusip),by(cusip quart)
	by cusip quart: gen sort=_n
	gen rank=sort/total
	gen lg=rank<=0.50
	gen sm=lg==0
	
	keep if sm==1
	
	gen begval = begshares*l1crsp_prc
	gen endval = shares*crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	egen endportval=total(endval), by(mgrno quart)
	egen begwt = begval / begportval
	egen endwt = endval / endportval
	
	drop if begportval==0
	
	gen buy = endwt > begwt
	gen sell = endwt < begwt
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen allbuys = total(ewtbret), by(mgrno quart)
	egen allsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "allbuys allsales"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 allbuys allsales, replace cuts(1 99)
	
	gen bar1sm = allbuys - allsales
	
	save "bar1sm_for_T6-PanelD", replace
	
	***   ***   ***   ***   ***   ***   ***   ***   ***   ***   ***
	* BAR2_SM:
	use "trs34_1981-2018_CLEANED-2", clear // File created in Do File: "Chg Transient Inst Own"
	keep fdate quart mgrno cusip begshares shares begperc endperc
	
	keep if begperc==0 | endperc==0
	
	replace quart=quart+1
	joinby cusip quart using "rdq_dgtw_3d_returns.dta" // From (A) above
	
	replace quart=quart-1
	joinby permno quart using "crsp_trs34_supplement" // File created in Do File: "Chg Transient Inst Own"
	
	egen maxperc=rowmax(begperc endperc)
	gsort cusip quart -maxperc
	egen total=count(cusip),by(cusip quart)
	by cusip quart: gen sort=_n
	gen rank=sort/total
	gen lg=rank<=0.50
	gen sm=lg==0
	
	keep if sm==1
	
	gen begval = begshares*l1crsp_prc
	
	egen begportval=total(begval), by(mgrno quart)
	
	drop if begportval==0
	
	gen buy = begperc==0
	gen sell = endperc==0
	
	gen lgbuy = buy==1 & lgsh==1
	gen lgsell = sell==1 & lgsh==1
	gen smbuy = buy==1 & lgsh==0
	gen smsell = sell==1 & lgsh==0
	
	egen buys=total(buy),by(mgrno quart)
	egen sells=total(sell),by(mgrno quart)
	keep if buys>=1 & sells>=1
	
	gen ewtbret=(1/buys)*eabmret if buy==1
	gen ewtsret=(1/sells)*eabmret if sell==1
	
	egen entrybuys = total(ewtbret), by(mgrno quart)
	egen exitsales = total(ewtsret), by(mgrno quart)
	
	duplicates drop mgrno quart, force
	
	keep if year(fdate)>=1995
	keep if year(fdate)<=2009
	
	gen preRFD = quart<=162
	gen postRFD_preSBL = quart>=163 & quart<=182
	gen postSBL = quart>=183
	
	local varlist "entrybuys exitsales bar2"
	foreach i of local varlist {
		replace `i' = `i' * 100
	}
	
	winsor2 entrybuys exitsales, replace cuts(1 99)
	
	gen bar2sm = entrybuys - exitsales
	
	save "bar2sm_for_T6-PanelD", replace

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



********************************************************************************
/*
	This code develops the sample and creates the variables related to the
	real effects analysis following Petacchi [2015]
	(doi: 10.1016/j.jacceco.2015.01.002).
*/
********************************************************************************



/// REAL EFFECTS ANALYSIS: RETRIEVE CRSP VARIABLES ///
* CRSP MONTHLY *
use CRSP19942012, clear
duplicates drop PERMNO, force
keep PERMNO CUSIP NCUSIP
save CRSP19942012_adj1, replace
use CRSP19942012, clear
gen month = mofd(date)
duplicates report CUSIP month
keep CUSIP month RET RETX vwretd vwretx ewretd ewretx sprtrn
save CRSP19942012_adj2, replace



/// REAL EFFECTS ANALYSIS: CREATE MAIN COMPUSTAT SAMPLE, CREATE COMPUSTAT VARIABLES, and MERGE IN OTHER VARIABLES (TABLE 8) ///
* COMPUSTAT ANNUAL *
use Compustat19942012, clear
destring gvkey, replace
rename cusip cusip_COMP
gen sic2 = substr(sic,1,2)
destring sic2, replace
gen MVofEquity=prcc_f*csho
gen MVofAssets=MVofEquity+lt
gen MTB=MVofAssets/at
gen RandD=xrd/at
bysort sic2 fyear: egen avgRandD = mean(RandD)
replace RandD=avgRandD if RandD==.
gen Dividend=0
replace Dividend=1 if dvt>0 & dvt!=.
gen Depreciation=dp/at
gen PPE=ppent/at
gen Profit=oibdp/at
gen Size=ln(1+sale)
gen BookLeverage=lt/at
gen MarketLeverage=lt/MVofAssets
gen cusip_COMP8 = substr(cusip_COMP,1,8)
drop cusip_COMP
drop if cusip_COMP8==""
rename cusip_COMP8 CUSIP
gen month = mofd(datadate)
duplicates report CUSIP month

* MERGE CRSP VARIABLES * 
merge 1:1 CUSIP month using CRSP19942012_adj2
rename _merge merge_CRSP
drop if merge_CRSP==2
merge m:1 CUSIP using CRSP19942012_adj1
keep if _merge==3
drop _merge

* MERGE WANG [2007] DATA *
merge m:1 gvkey using Wang2007_Data
rename _merge merge_Wang
drop if merge_Wang==2
rename cusip cusip_Wang

* MERGE ADJPIN DATA AND CREATE ADJPIN ESTIMATES *
rename PERMNO permno
gen year = fyear
duplicates report permno year
merge 1:1 permno year using AdjPIN_Data
keep if _merge==3
drop _merge
gen d_ub = d*ub
gen ld = 1-d
gen ld_us = ld*us
gen numerator=a*(d_ub+ld_us)
gen db_ds = sb+ss
gen a_o = a*tn
gen la = 1-a
gen la_o = la*tn
gen denom1 = a*(d_ub+ld_us)
gen denom2 = db_ds*(a_o+la_o)
gen denominator=denom1+denom2+es+eb
gen adjPIN=numerator/denominator

drop if fyear<1996
drop if fyear>2009
drop if fyear==2000
drop if fyear==2005
bysort gvkey: egen avgadjPIN = mean(adjPIN) if fyear<2000
replace avgadjPIN=0 if avgadjPIN==.
bysort gvkey: egen maxavgadjPIN = max(avgadjPIN)
rename maxavgadjPIN InfoAsym
drop if InfoAsym==0
keep if prefd_private!=.
gen Treat=0
replace Treat=1 if prefd_private!=2
gen FD=0
replace FD=1 if fyear>2000
gen SS=0
replace SS=1 if fyear>2005
winsor2 BookLeverage MarketLeverage InfoAsym vwretd MTB RandD Depreciation PPE Profit Size
gen Treat_x_FD = Treat*FD
gen Treat_x_FD_x_InfoAsym = Treat*FD*InfoAsym
gen Treat_x_FD_x_InfoAsym_w = Treat*FD*InfoAsym_w
gen InfoAsym_x_FD = InfoAsym*FD
gen InfoAsym_w_x_FD = InfoAsym_w*FD
gen Treat_x_SS = Treat*SS
gen Treat_x_SS_x_InfoAsym = Treat*SS*InfoAsym
gen Treat_x_SS_x_InfoAsym_w = Treat*SS*InfoAsym_w
gen InfoAsym_x_SS = InfoAsym*SS
gen InfoAsym_w_x_SS = InfoAsym_w*SS
gen fyearq=fyear

* MERGE ABNORMAL RETURNS VARIABLE *
merge 1:1 gvkey fyearq using ABRET_Variable
drop if _merge==2
drop _merge

winsor2 abret
bysort gvkey: gen countobs = _N
keep if countobs==12
drop if BookLeverage_w==. | abret_w==. | MTB_w==. | RandD_w==. | Depreciation_w==. | PPE_w==. | Profit_w==. | Size_w==.
gen year0102=0
replace year0102=1 if fyear==2001 | fyear==2002
gen year0304=0
replace year0304=1 if fyear==2003 | fyear==2004
gen year0607=0
replace year0607=1 if fyear==2006 | fyear==2007
gen year0809=0
replace year0809=1 if fyear==2008 | fyear==2009
gen Treat_x_year0102 = Treat*year0102
gen Treat_x_year0304 = Treat*year0304
gen Treat_x_year0607 = Treat*year0607
gen Treat_x_year0809 = Treat*year0809
gen Treat_x_year0102_x_InfoAsym_w = Treat*year0102*InfoAsym_w
gen Treat_x_year0304_x_InfoAsym_w = Treat*year0304*InfoAsym_w
gen Treat_x_year0607_x_InfoAsym_w = Treat*year0607*InfoAsym_w
gen Treat_x_year0809_x_InfoAsym_w = Treat*year0809*InfoAsym_w
gen InfoAsym_w_x_year0102 = InfoAsym_w*year0102
gen InfoAsym_w_x_year0304 = InfoAsym_w*year0304
gen InfoAsym_w_x_year0607 = InfoAsym_w*year0607
gen InfoAsym_w_x_year0809 = InfoAsym_w*year0809
save ABKP_Sample_Table8, replace	

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



********************************************************************************
/*
	This code details the construction of the suspect trading activity variables
	(STMONOP and STCOMP) examined in TABLE 9.
	
	The computation of these measures follows Acharya & Johnson [2010] 
	(doi: 10.1016/j.jfineco.2010.08.002).
	
	Initial step-by-step guidance:
	
	The suspect trading measures capture residual patterns in stock returns in
	the 5 days leading up to a corporate event; i.e., in this study, Item 7.01 8-K
	filings and investor conferences.
	
	To isolate trading activity related to the targeted event, we purge event
	instances where there are confounding events in the [-5, +1] window relative
	to event date t [0].
	
	Confounding events include:
		Press releases (obtained from SeekEdgar LLC)
		10-K, 10-Q, 6-K, and other 8-K filings (SEC Edgar Index File)
		Earnings announcements (Compustat RDQ date)
		M&A (Capital IQ Event ID: 80, 81, 82, 225)
		Dividends (Capital IQ Event ID: 94, 213)
		Guidance (Capital IQ Event ID: 26, 27)
		Executive changes (Capital IQ Event ID: 101, 102)
		
	The table "event_file.dta" contains a firm identifier (PERMNO) and the date
	(event date). This table is to be joined to the CRSP daily file to compute
	the suspect trading measures.
	
	This code uses the Stata rangestat command for firm-specific rolling-window
	estimations; hence, Stata users may need to install 'rangestat'.
*/
********************************************************************************



* MAX SUM from Acharya & Johnson [2010]:

use "CRSP_DAILY_STOCK_FILE_1998-2018", clear
	keep permno date ret vol ewretd vwretd shrout prc
	replace ret=ewretd if ret==.
	drop ewretd
	rename vwretd mktret
	
	merge 1:1 permno date using "event_file.dta" // This is either Item 7.01 8-K filings ore investor conferences, as described above.
		drop if _merge==2
		egen max=max(_merge),by(permno)
		keep if max==3
		gen mark=_merge==3 // ID the actual event date
		drop _merge max
	sort permno date
	by permno: gen car3=((1+ret) * (1+ret[_n-1]) * (1+ret[_n+1]) - 1) - ((1+mktret) * (1+mktret[_n-1]) * (1+mktret[_n+1]) - 1) if mark==1
		gen acar=abs(car3) // ACAR for Table 9, Panel C
	
	by permno: gen l1ret=ret[_n-1]
	by permno: gen series=_n
	
	gen day=dow(date)
		gen mon=day==1
		gen tue=day==2
		gen wed=day==3
		gen thu=day==4
		drop day
		
	drop if l1ret==.
	
	gen markdate=date if mark==1
	
	keep if year(date)>=2000
	keep if year(date)<2010
	
	egen group=group(permno markdate)
	sort permno date
	
	save "SuspectTrade_BaseFile", replace
	
use "SuspectTrade_BaseFile", clear
	keep permno
	duplicates drop
	gen rand=runiform()
	sort rand
	egen rank=xtile(rand),nq(25)
	keep permno rank
	save "permno_partitions", replace
	
use "SuspectTrade_BaseFile", clear
	joinby permno using "permno_partitions"
	save "SuspectTrade_BaseFile", replace
	erase "permno_partitions.dta"

forvalues z=1/25 {
	qui use "SuspectTrade_BaseFile", clear
		qui keep if rank==`z'
		qui rangestat (reg) ret l1ret mon tue wed thu mktret, interval(series -59 0) by(permno)
			qui gen retresid=ret-(b_l1ret*l1ret)-(b_mon*mon)-(b_tue*tue)-(b_wed*wed)-(b_thu*thu)-(b_mktret*mktret)
			qui drop reg_r2-se_cons
			qui rename reg_nobs ret_nobs
			
		qui rangestat (mean) retresid, interval(series -60 -1) by(permno)
		qui rangestat (sd) retresid, interval(series -60 -1) by(permno)
		
		qui gen stnd_retresid=(retresid-retresid_mean)/retresid_sd
		
		qui forvalues y=1/5 {
			gen stnd_retresid`y'=stnd_retresid[_n-`y'] if markdate!=.
		}
		
		qui keep if markdate!=.
		qui keep if ret_nobs>=30
		
		qui keep permno date mark car3 acar stnd_retresid1 stnd_retresid2 stnd_retresid3 stnd_retresid4 stnd_retresid5
		display `z'
		save "suspect_trade_partition_`z'", replace
	}
	
use "suspect_trade_partition_1", clear
	forvalues z=2/25 {
		append using "suspect_trade_partition_`z'"
	}
	
	local top=5
	
	forvalues i=1/`top' {
		gen resret`i'=stnd_retresid`i'
	}
	
	egen maxret=rowmax(resret1-resret`top')
	egen minret=rowmin(resret1-resret`top')
	
	forvalues i=1/`top' {
		gen presret`i'=resret`i' if resret`i'>0
		replace presret`i'=0 if presret`i'==.
	}
	
	forvalues i=1/`top' {
		gen nresret`i'=resret`i' if resret`i'<0
		replace nresret`i'=0 if nresret`i'==.
	}
	
	egen sumpret=rowtotal(presret1-presret`top')
	egen sumnret=rowtotal(nresret1-nresret`top')
	
	gen stcomp=maxret if car3>0
		replace stcomp=minret if car3<0
		replace stcomp=abs(stcomp)
		
	gen stmonop=sumpret if car3>0
		replace stmonop=sumnret if car3<0
		replace stmonop=abs(stmonop)
	
	keep permno date car3 acar stcomp stmonop
	
	save "Suspect-Trade_STCOMP_STMONOP.dta", replace

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



********************************************************************************
/*
	This code creates the matched sample used in the APPENDIX A analysis of
	Reg FD noncompliance costs. Treated firms are RFD violators based on
	SEC Enforcement Actions. Three control firms are matched based on time (RFD
	enforcement date), size quintile, SIC-2-digit industry, and nearest neighbor
	in terms of net profitability.
*/
********************************************************************************



use "Compustat-Quarterly-Fundamentals_Merged-with-CRSP", clear // Compustat Quarterly merged to CRSP w/ WRDS Compustat-CRSP merge file
	destring gvkey cik,replace
	drop if rdq==. // Missing RDQs
	duplicates tag gvkey rdq,gen(dup)
	drop if dup>0 // FQTR obs. with duplicate RDQs
	gen mv=prccq*cshoq
	gen bm=ceqq/(mv)
	gen lev=dlttq/atq
		replace lev=0 if lev==.
	gen roa=ibq/atq
	gen np=ibq/saleq
	gen sic2=substr(sic,1,2)
		destring sic2 sic,replace
	keep datadate fyearq gvkey permno cik conm mv bm lev roa sic2 np
	
	gen rfd=0
	replace rfd=1 if gvkey==8972 	// Raytheon
	replace rfd=1 if gvkey==61570 	// Secure Computing
	replace rfd=1 if gvkey==63180 	// Siebel Systems
	replace rfd=1 if gvkey==9459 	// Schering-Plough
	*replace rfd=1 if gvkey==14257  // Senetek PLC
	replace rfd=1 if gvkey==4108 	// Flowserve
	replace rfd=1 if gvkey==5074 	// Electronic Data Systems
	replace rfd=1 if gvkey==162897 	// American Commercial Lines
	replace rfd=1 if gvkey==15347   // Presstek
	replace rfd=1 if gvkey==14624 	// Office Depot
	replace rfd=1 if gvkey==4640 	// Fifth Third Bancorp
	replace rfd=1 if gvkey==175404 	// First Solar
	replace rfd=1 if gvkey==183322 	// TherapeuticsMD
	
	gen quart=qofd(datadate)+1
	gen testq=0
		replace testq=1 if gvkey==8972 & quart==171
		replace testq=1 if gvkey==61570 & quart==171
		replace testq=1 if gvkey==63180 & quart==171
		replace testq=1 if gvkey==9459 & quart==174
		replace testq=1 if gvkey==4108 & quart==180
		replace testq=1 if gvkey==5074 & quart==190
		replace testq=1 if gvkey==162897 & quart==198
		replace testq=1 if gvkey==14624 & quart==203
		replace testq=1 if gvkey==4640 & quart==207
		replace testq=1 if gvkey==175404 & quart==214
		replace testq=1 if gvkey==183322 & quart==238
		replace testq=1 if gvkey==15347 & quart==200
	
	drop if mv==. | bm==. | roa==. | np==.
	egen qmv=xtile(mv),by(quart) nq(5)
	
	save "AppA_Sample1", replace

use "AppA_Sample1", clear
	keep if rfd==1
	keep if testq==1
	gen testdate=0
		replace testdate=15669 if gvkey==8972
		replace testdate=15669 if gvkey==61570
		replace testdate=15669 if gvkey==63180
		replace testdate=15957 if gvkey==9459
		replace testdate=16519 if gvkey==4108
		replace testdate=17434 if gvkey==5074
		replace testdate=18164 if gvkey==162897
		replace testdate=18556 if gvkey==14624
		replace testdate=18953 if gvkey==4640
		replace testdate=19607 if gvkey==175404
		replace testdate=21781 if gvkey==183322
		replace testdate=18330 if gvkey==15347
		rename testdate date
		format date %td
		keep sic2 quart qmv date np
	save "AppA_RFD-Treated", replace
	
use "AppA_Sample1", clear	
	keep if rfd==0
	drop if cik==.
	joinby qmv sic2 quart using "AppA_RFD-Treated"
	keep gvkey permno conm date qmv sic2 quart
	
	joinby permno date using "CRSP_Daily_File" // Ensure active trade on test date
	drop if ret==.
	keep gvkey quart
	save "AppA_RFD-Control-Candidates", replace
			
use "AppA_Sample1", clear	
	keep datadate fyearq gvkey permno cik conm qmv mv bm lev roa sic2 np quart rfd
	sort gvkey quart
	egen maxrfd=max(rfd),by(gvkey)
	egen minrfd=min(rfd),by(gvkey)
	drop if minrfd==1
		drop maxrfd minrfd
	joinby gvkey quart using "AppA_RFD-Control-Candidates"
	rename gvkey match_gvkey
	rename permno match_permno
	gen match_qmv=qmv
	rename mv match_mv
	rename bm match_bm
	rename roa match_roa
	rename np match_np
	save "AppA_RFD-Control-Candidates_MergeTo_Treated", replace
	
use "AppA_Sample1", clear	
	keep datadate fyearq gvkey permno cik conm qmv mv bm lev roa sic2 np quart rfd testq
	keep if rfd==1 & testq==1
	joinby qmv sic2 quart using "AppA_RFD-Control-Candidates_MergeTo_Treated"
	gen diff=abs(np - match_np)
	sort gvkey diff
	bysort gvkey: gen neighbor3=_n
	keep if neighbor3<=3
	duplicates report match_gvkey
	keep quart gvkey match_gvkey
	gen treat_gvkey=gvkey
	egen matchpair=group(gvkey)
	gen ammend=1 if gvkey==gvkey[_n-1]
	replace gvkey=. if ammend==1
	drop ammend gvkey
	rename match_gvkey gvkey
	save "AppA_matched_control_sample", replace
	
use "AppA_Sample1", clear
	joinby gvkey quart using "AppA_matched_control_sample",unmatched(master)
	keep if _merge==3 | rfd==1
	drop if testq==0 & rfd==1
	drop _merge matchpair
	gen testdate=.
		replace testdate=15669 if treat_gvkey==8972
		replace testdate=15669 if treat_gvkey==61570
		replace testdate=15669 if treat_gvkey==63180
		replace testdate=15957 if treat_gvkey==9459
		replace testdate=16519 if treat_gvkey==4108
		replace testdate=17434 if treat_gvkey==5074
		replace testdate=18164 if treat_gvkey==162897
		replace testdate=18556 if treat_gvkey==14624
		replace testdate=18953 if treat_gvkey==4640
		replace testdate=19607 if treat_gvkey==175404
		replace testdate=21781 if treat_gvkey==183322
		replace testdate=18330 if treat_gvkey==15347
		
		replace testdate=15669 if gvkey==8972
		replace testdate=15669 if gvkey==61570
		replace testdate=15669 if gvkey==63180
		replace testdate=15957 if gvkey==9459
		replace testdate=16519 if gvkey==4108
		replace testdate=17434 if gvkey==5074
		replace testdate=18164 if gvkey==162897
		replace testdate=18556 if gvkey==14624
		replace testdate=18953 if gvkey==4640
		replace testdate=19607 if gvkey==175404
		replace testdate=21781 if gvkey==183322
		replace testdate=18330 if gvkey==15347
		format testdate %td
		format conm %30s
		replace treat_gvkey=gvkey if rfd==1
		gsort treat_gvkey -rfd
		replace cik=87245 if gvkey==9459
	order testdate rfd gvkey treat_gvkey permno conm
	rename testdate date
	gen month=mofd(date)
	save "AppA_matched_sample", replace



/// ADVERSE OUTCOME VARIABLES ///

* STOCK RETURN VOLATILITY
use "CRSP_DAILY_ALL_VARIABLES_1980-2020", clear
	keep date
	duplicates drop
	sort date
	gen series=_n
	save "CRSP_TRADING-DAYS_SERIES_1980-2020", replace

use "CRSP_DAILY_ALL_VARIABLES_1980-2020", clear
	* Set RET=0 when missing (e.g., trading suspension)
	replace ret=0 if ret==.
	keep permno date ret
	joinby date using "CRSP_TRADING-DAYS_SERIES_1980-2020"
	sort permno date
	rangestat (sd) ret, interval(series 0 254) by(permno)
	gen month=mofd(date)
	egen mind=min(date), by(permno month)
	keep if mind==date
	keep permno date month ret_sd
	save "12month_ReturnVolatility_from_CRSP", replace
			
* BOARD TURNOVER, EXECUTIVE TURNOVER, LITIGATION EVENTS
use "CapitalIQ_Key_Events_Database_ALL", clear
	gen board = keydeveventtypeid==16
	gen law = keydeveventtypeid==25
	gen exec = keydeveventtypeid==101 | keydeveventtypeid==102
	egen rsum = rowtotal(board law exec)
	keep if rsum>0
	gen month=mofd(announcedate)
	egen boardturn = max(board), by(gvkey month)
	egen lawsuit = max(law), by(gvkey month)
	egen execturn = max(exec), by(gvkey month)
	duplicates drop gvkey month, force
	keep gvkey month boardturn lawsuit execturn
	save "capiq_adverse_events", replace
	
* MERGE ADVERSE OUTCOME VARIABLES ONTO MAIN SAMPLE
use "AppA_matched_sample", clear
	joinby permno month using "12month_ReturnVolatility_from_CRSP"

	*********************************************************************************************************************
	* Next: Join event abnormal returns onto the dataset
	/* Step-by-step guide for event abnormal returns:
	1) Create characteristics-adjusted return benchmarks following Daniel et al. [1997] (doi: 10.1111/j.1540-6261.1997.tb02724.x)
	2) Load CRSP Daily Stock Security File for period spanning 2002-2019
	3) merge 1:1 permno date using "AppA_matched_sample"
	4) Calculate the abnormal return by compounding each obs. firm's raw cumulative return from day t through day t+1, where day t is "date" (i.e., the Reg FD enforcement action date) in the "AppA_matched_sample.dta" file; then, subtract the cumulative size, book-to-market, and momentum benchmark return for firm i over day t through day t+1. This variable is the "Market Reaction" variable in APPENDIX A of the manuscript.
	5) Retain observations that correspond to each sample firm's test date and the market reaction variable
	6) save "AppA_AbnormalReturn", replace */
	*********************************************************************************************************************	
	
	joinby permno date using "AppA_AbnormalReturn"
	
	* Expand obs. to identify adverse events occuring in months following event date:
	expand 13
	sort gvkey
	bysort gvkey: replace month=month+_n-1 if _n>1
	
	joinby gvkey month using "capiq_adverse_events", unmatched(master)
		replace boardturn=0 if _merge==1
		replace lawsuit=0 if _merge==1
		replace execturn=0 if _merge==1
		drop _merge
		egen board_turnover=max(boardturn), by(gvkey)
		egen exec_turnover=max(execturn), by(gvkey)
		*Flowserve (GVKEY=4108) event not recorded in CapIQ; Lewis M. Kling appointed CEO July 2005
		replace exec_turnover=1 if gvkey==4108
		egen litigation=max(lawsuit), by(gvkey)
	joinby permno month using "sec_investigations", unmatched(master)

	*********************************************************************************************************************
	/* The file "sec_investigations.dta" was obtained from Blackburne et al. [2021] (doi: 10.1287/mnsc.2020.3805). These data report undisclosed SEC investigations obtained via FOIA request by Blackburne et al. [2021]. The table includes PERMNO, Initiation Date of Investigation, and a dummy variable=1 (secinvest). To merge to our data, we generated month=mofd(investigation_date). Duplicate PERMNO-MONTH instances are removed, if applicable. */
	*********************************************************************************************************************	
		
		replace secinvest=0 if secinvest==.
		egen sec_investig=max(secinvest), by(gvkey)
		* Set TherapeuticsMD and corresponding control firms to missing:
		replace sec_investig=. if treat_gvkey==183322
		drop _merge
		* Contract sample to original N:
		duplicates drop gvkey, force
save ABKP_Sample_AppendixA, replace



/* END */
