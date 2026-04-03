
**set working directory
	global cwd "C:\Users\brightg\Box\FGR2022\spillover\SUBMIT\JAR\DATASHEET"
	
	assert !missing("$cwd")

**note today's date and logfile
	global curdate : di %tdCYND daily("$S_DATE", "DMY")
	cap mkdir "$cwd\code\logs"
	cap mkdir "$cwd\data\processed"
	
	*Start log
	cap log close
	log using "$cwd\log\logfile.txt", append //appends unto log file from SAS
*****************************************************************************************
	di "***STATA STATISTICAL ANALYSIS STARTS HERE***   Date and Time: $S_DATE $S_TIME" 
*****************************************************************************************

	
	
use "$cwd\data\EAD_ret_vol_sich10.dta" , clear
	rename *, lower
		
	preserve
		use "$cwd\data\acctcomp_firmpair_1999_2022.dta", clear //computed using SAS "2_comparability_defranco.sas"
			duplicates drop permno_f permno_p year, force
		save "$cwd\data\processed\acctcomp_firmpair.dta", replace	
	restore
	
	gen year=fyear
	merge m:1 permno_f permno_p year using "$cwd\data\processed\acctcomp_firmpair.dta" , keepusing(acctcomp)
		drop if _merge==2
		drop _merge
				
	tab fyear
	
	gen dea_f=(ead1==date)
	gen dea_f_ret_f=dea_f*ret_f
	gen abs_ret_p=abs(ret_p)
	gen abs_ret_f=abs(ret_f)
	gen abs_dea_f_ret_f=dea_f*abs(ret_f)
	
	*adjusted return
	gen adj_ret_p=ret_p-vwretd
	gen adj_ret_f=ret_f-vwretd

	gen dea_f_adj_ret_f=dea_f*adj_ret_f
	
	gen abs_adj_ret_p=abs(adj_ret_p)
	gen abs_adj_ret_f=abs(adj_ret_f)
	gen abs_dea_f_adj_ret_f=dea_f*abs(adj_ret_f)
	
	*earnings surprise
	gen abs_surp1_medest_f=abs(surp1_medest_f)
	xtile surprank_abs=abs_surp1_medest_f, nq(5)
	
	xtile surprank = surp1_medest_f, nq(5)
	
	xtile surprank_pos = surp1_medest_f if surp1_medest_f>0, nq(5)
	xtile surprank_neg = abs(surp1_medest_f) if surp1_medest_f<0, nq(5)
	
	gen surp_abs=(surprank_abs==5)
	replace surp_abs=. if (surprank_abs>1 & surprank_abs<5) | missing(surprank_abs)
	gen surp_abs_abs_dea_f_ret_f=surp_abs*abs_dea_f_ret_f
	gen surp_abs_dea_f_ret_f=surp_abs*dea_f_ret_f
	
	gen surp=(surprank==5)
	replace surp=. if (surprank>1 & surprank<5) | missing(surprank)
	gen surp_dea_f_ret_f=surp*dea_f_ret_f
	gen surp_pos=(surprank_pos==5)
	replace surp_pos=. if (surprank_pos>1 & surprank_pos<5) |  missing(surprank_pos)
	gen surp_pos_dea_f_ret_f=surp_pos*dea_f_ret_f
	gen surp_neg=(surprank_neg==5)
	replace surp_neg=. if (surprank_neg>1 & surprank_neg<5) |  missing(surprank_neg)
	gen surp_neg_dea_f_ret_f=surp_neg*dea_f_ret_f
	
	gen surp_dea_f_abs_ret_f=surp*abs_dea_f_ret_f
	gen surp_pos_abs_dea_f_ret_f=surp_pos*abs_dea_f_ret_f
	gen surp_neg_abs_dea_f_ret_f=surp_neg*abs_dea_f_ret_f
	
	*industry leader (>20% of industry sales)
	gen leader_abs_dea_f_ret_f = leader_f*abs_dea_f_ret_f	
	gen leader_dea_f_ret_f = leader_f*dea_f_ret_f
	
	*comparability
	xtile comprank = acctcomp , nq(5)
	gen comparab = (comprank==5)
	replace comparab=. if (comprank>1 & comprank<5) | missing(comprank)
	
	gen comparab_abs_dea_f_ret_f = comparab*abs_dea_f_ret_f	
	gen comparab_dea_f_ret_f = comparab*dea_f_ret_f
	
	**label variables
	do "$cwd\code\labvar.do"

save "$cwd\data\processed\regressionsample$curdate.dta" , replace 


/********************************************
TABLE 1: Summary statistics
*********************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 

eststo clear
preserve
	keep if dea_f==1
	duplicates drop sich fyear fqtr permno_f , force
	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  , cut(1 99) replace	
	tabstat npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f ,  stats(n mean p25 median p75 sd) column(stats)
restore	

preserve
	keep if dea_f==1
	duplicates drop sich fyear fqtr permno_p , force
	winsor2 ret_p adj_ret_p  abs_ret_p abs_adj_ret_p  , cut(1 99) replace	
	tabstat ret_p adj_ret_p  abs_ret_p abs_adj_ret_p  ,  stats(n mean  p25 median p75 sd) column(stats)
restore

preserve	
	duplicates drop sich fyear fqtr permno_f date  , force
	winsor2 dea_f  ret_f adj_ret_f abs_ret_f abs_adj_ret_f , cut(1 99) replace	
	tabstat dea_f  ret_f adj_ret_f abs_ret_f abs_adj_ret_f , stats(n mean p25 median p75 sd) column(stats)
restore	

preserve	
	duplicates drop sich fyear fqtr permno_p date  , force
	winsor2 ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	
	tabstat ret_p adj_ret_p  abs_ret_p abs_adj_ret_p ,  stats(n mean p25 median p75 sd) column(stats)
restore		


/****************************************************************
TABLE 2: Investors reaction to focal firm's earnings surprise
*****************************************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 		

**focal firm reaction to own earnings surprise
eststo clear
preserve
	keep if dea_f==1
	duplicates drop sich fyear fqtr permno_f , force
	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  , cut(1 99) replace	
	
	qui eststo: reghdfe abs_ret_f abs_surp1_medest_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)  
	qui eststo: reghdfe abs_adj_ret_f abs_surp1_medest_f  , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)  		
	
	qui eststo: reghdfe ret_f surp1_medest_f   , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)   
	qui eststo: reghdfe adj_ret_f surp1_medest_f  , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)    
esttab *, stats(clustvar r2 N)  varwidth(20) 
restore

**peer reaction to focal earnings surprise
eststo clear
preserve
	keep if dea_f==1
	duplicates drop sich fyear fqtr permno_p , force
	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p  , cut(1 99) replace	
	
	qui eststo: reghdfe abs_ret_p abs_surp1_medest_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)  
	qui eststo: reghdfe abs_adj_ret_p abs_surp1_medest_f  , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)  		
	
	qui eststo: reghdfe ret_p surp1_medest_f   , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)   
	qui eststo: reghdfe adj_ret_p surp1_medest_f  , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)    
esttab *, stats(clustvar r2 N) varwidth(20)
restore


/*************************************************
TABLE 3: Peer reaction ON focal-firm EAD
**prior studies using only EADs
*************************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 			
	
eststo clear
preserve
	keep if dea_f==1
	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p  , cut(1 99) replace	
	
	qui eststo: reghdfe abs_ret_p abs_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)  
	qui eststo: reghdfe abs_adj_ret_p abs_adj_ret_f  , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)  		
	
	qui eststo: reghdfe ret_p ret_f   , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)   
	qui eststo: reghdfe adj_ret_p adj_ret_f  , noabsorb /*absorb(sich fyear#fqtr)*/  cluster(sich)    
esttab *, stats(clustvar r2 N) varwidth(20) 
restore

	

/**********************************************************************
**OUR BASELINE RESULT: comovement on all trading days including focal EAD
TABLE 4: Peer and focal firm return correlation on all trading days
*********************************************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 		

	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	

eststo clear
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe abs_adj_ret_p abs_adj_ret_f dea_f abs_dea_f_adj_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe adj_ret_p adj_ret_f dea_f dea_f_adj_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, varwidth(20) stats(clustvar r2 N)


/***************************************************************
**CROSS-SECTION TESTS	
TABLE 5: Peer and focal firm return correlation on all trading days conditioned on absolute earnings surprise
****************************************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 		

	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	
	
**Earnings surprise (surp) of focal firm: 1.absolute surp, 2.signed surp, 3.positive surp, 4.negative surp	
eststo clear		 
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if surprank_abs==5, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar) 
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if surprank_abs==1, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f surp_abs_abs_dea_f_ret_f surp_abs c.(abs_ret_f dea_f)#surp_abs, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if surprank_abs==5, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar) 	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if surprank_abs==1, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar) 
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f surp_abs_dea_f_ret_f surp_abs c.(ret_f dea_f)#surp_abs, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  	
esttab *, stats(clustvar r2 N) varwidth(20)
	
	

/***************************************************************
**CROSS-SECTION TESTS	
TABLE 6: Peer and focal firm return correlation on all trading days conditioned on industry leadership (i.e. 20% of industry sales)	
****************************************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 		

	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	
		
eststo clear		
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if leader_f==1, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  	
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if leader_f==0, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f leader_abs_dea_f_ret_f leader_f c.(abs_ret_f dea_f)#leader_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if leader_f==1, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if leader_f==0, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f leader_dea_f_ret_f leader_f c.(ret_f dea_f)#leader_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  	
esttab *, stats(clustvar r2 N) varwidth(20)

	
	
/***************************************************************
**CROSS-SECTION TESTS	
TABLE 7: Peer and focal firm return correlation on all trading days conditioned on comparability (De Franco et al, 2011) between focal and peers		
****************************************************************/
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 		

	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace		
	
eststo clear		
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if comprank==5, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  	
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if comprank==1, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f comparab_abs_dea_f_ret_f comparab c.(abs_ret_f dea_f)#comparab, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if comprank==5, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if comprank==1, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f comparab_dea_f_ret_f comparab c.(ret_f dea_f)#comparab, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, stats(clustvar r2 N) varwidth(20)

	
/*************************************************************************************************************
TABLE 8: Average R2 and coefficients from yearly regressions of quarterly returns on earnings announcement vs random non-announcement day return 
***************************************************************************************************************/
	**DONE in SAS using "4_vuongtest.sas" file
	**results exported to "VuongResult.xls" and coefficients.xls files for formatting
	
	
	
	
	
/**********************************************************************************************
TABLE 9: Peer and focal firm return correlation condition on non-macro news announcement days
**MACRO DAYS test: Hirshleifer & Sheng (2022)
*********************************************************************************************/
**Macro event announcement dates provided by MaryJane
	import excel "$cwd\data\eco 97-24.xls", sheet("5424185_20240104_214940_eco") firstrow allstring clear
		
		keep if inlist(Event, "FOMC Rate Decision (Lower Bound)", "FOMC Rate Decision (Upper Bound)", "ISM Manufacturing", "Personal Consumption", "Unemployment Rate")
		
		gen Date= date(DateTime , "MDY")
		format Date %td
		
		gen double Time = clock(B, "hm")
		format Time %tc_HH:MM
		
		keep Date Time Event
		order Date Time Event

		gen Year=year(Date)
		keep if Year>=1997 & Year<=2022
		
		drop if missing(Time)
		duplicates drop
		order Year 
		
		gen day = dow(Date)
		tab day //100% announcements occur on Monday - Friday
			
		tab Time	
	
		gen afterhrs = (hh(Time)>16)
			tab afterhrs //2% announcements occur after hours
			
		gen Date_corrected=Date
			replace Date_corrected = Date + 1 if afterhrs==1 & day<5
			replace Date_corrected = Date + 3 if afterhrs==1 & day==5
			replace Date_corrected = Date + 2 if day==6
			replace Date_corrected = Date  if missing(Date_corrected)
			
		cap drop day 
		gen day = dow(Date_corrected)
			tab day 
			
		bys Date_corrected: egen num_event = count(Event)
		
		sum num_event, d //8.6 events on average; median 8 events 
			
		gen Macroday=1
			
		duplicates drop Date_corrected, force 
			
	save "$cwd\data\processed\MacroEventDates.dta" , replace	
		
	
	**match with our sample 	
	use "$cwd\data\processed\regressionsample$curdate.dta" , clear
		rename *, lower
	
		gen Date_corrected = date
		merge m:1 Date_corrected using "$cwd\data\processed\MacroEventDates.dta" , keepusing(Macroday) keep(1 3) nogen
						
		replace Macroday=0 if missing(Macroday)
				
		tab Macroday 
		tab Macroday if dea_f==1
		
					
	gen Macroday_abs_dea_f_ret_f = Macroday*abs_dea_f_ret_f	
	gen Macroday_dea_f_ret_f = 	Macroday*dea_f_ret_f
	gen MacroEAD = Macroday*dea_f
		
	
	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	
	
	
	tabstat Macroday MacroEAD,  stats(n mean sd p25 median p75 ) column(stats)
	tabstat Macroday MacroEAD if  dea_f==1,  stats(n mean sd p25 median p75 ) column(stats)
		
		

preserve
foreach var in abs_ret_p abs_ret_f ret_p ret_f {
	replace `var'=`var'*100
}
 	
	
eststo clear		
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f if Macroday==0, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f if Macroday==0, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, stats(clustvar r2 N) varwidth(20)
		

		

**Several ROBUSTNESS TESTS NEXT 


/**********************************************************************************************
TABLE FNXX: Extended peer firm reaction time, within three days of focal firm EAD
**DELAYED REACTION test: 
**Peer return is [0,+2] on focal EAD; other days are moving 3-day averages; 
**ensure no overlap in days for cumulative returns; focal return is kept at 1 day
*********************************************************************************************/
	use "$cwd\data\processed\regressionsample$curdate.dta", clear
		rename *, lower
		
		tab fyear
	

	gen abs_ret3d_p=abs(ret3d_p)

	*adjusted return
	gen adj_ret3d_p=ret3d_p-cum3dayvwretd
	gen abs_adj_ret3d_p=abs(adj_ret3d_p)

	
	**label variables
	do "$cwd\code\labvar.do"
	

**Regression: BASELINE RESULT
	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret3d_p adj_ret3d_p  abs_ret3d_p abs_adj_ret3d_p , cut(1 99) replace	

eststo clear
	qui eststo: reghdfe abs_ret3d_p abs_ret_f dea_f abs_dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe abs_adj_ret3d_p abs_adj_ret_f dea_f abs_dea_f_adj_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret3d_p ret_f dea_f dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe adj_ret3d_p adj_ret_f dea_f dea_f_adj_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, varwidth(20) stats(clustvar r2 N)
	




/*******************************************************
TABLE 10: Alternative Industry definitions
Panel A: Industry defined as NAICS
*****************************************************/
use "$cwd\data\EAD_ret_vol_naicsh10.dta" , clear 	
	rename *, lower 
	
	tab fyear
	
	gen dea_f=(ead1==date)
	gen dea_f_ret_f=dea_f*ret_f
	gen abs_ret_p=abs(ret_p)
	gen abs_ret_f=abs(ret_f)
	gen abs_dea_f_ret_f=dea_f*abs(ret_f)
	
	*adjusted return
	gen adj_ret_p=ret_p-vwretd
	gen adj_ret_f=ret_f-vwretd

	gen dea_f_adj_ret_f=dea_f*adj_ret_f
	
	gen abs_adj_ret_p=abs(adj_ret_p)
	gen abs_adj_ret_f=abs(adj_ret_f)
	gen abs_dea_f_adj_ret_f=dea_f*abs(adj_ret_f)
	
	**label variables
	do "$cwd\code\labvar.do"

	**Baseline regression
	egen indqtr = group(naicsh fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	

eststo clear
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe abs_adj_ret_p abs_adj_ret_f dea_f abs_dea_f_adj_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe adj_ret_p adj_ret_f dea_f dea_f_adj_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, varwidth(20) stats(clustvar r2 N)
	
	

/*******************************************************
TABLE 10: Alternative Industry definitions
Panel B: Industry defined as GICS
*****************************************************/
use "$cwd\data\EAD_ret_vol_gind10.dta" , clear 	
	rename *, lower 
	
	tab fyear
	
	gen dea_f=(ead1==date)
	gen dea_f_ret_f=dea_f*ret_f
	gen abs_ret_p=abs(ret_p)
	gen abs_ret_f=abs(ret_f)
	gen abs_dea_f_ret_f=dea_f*abs(ret_f)
	
	*adjusted return
	gen adj_ret_p=ret_p-vwretd
	gen adj_ret_f=ret_f-vwretd

	gen dea_f_adj_ret_f=dea_f*adj_ret_f
	
	gen abs_adj_ret_p=abs(adj_ret_p)
	gen abs_adj_ret_f=abs(adj_ret_f)
	gen abs_dea_f_adj_ret_f=dea_f*abs(adj_ret_f)
	
	**label variables
	do "$cwd\code\labvar.do"

	**Baseline regression
	egen indqtr = group(gind fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	

eststo clear
	qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe abs_adj_ret_p abs_adj_ret_f dea_f abs_dea_f_adj_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	
	qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	qui eststo: reghdfe adj_ret_p adj_ret_f dea_f dea_f_adj_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, varwidth(20) stats(clustvar r2 N)





/*******************************************************
TABLE 11: Alternative Days (shorter) Apart
*****************************************************/
**Test using 5 DAYS APART in focal and peer EADs
	use "$cwd\data\EAD_ret_vol_sich5.dta" , clear 
		rename *, lower 
	
	tab fyear
	
	gen dea_f=(ead1==date)
	gen dea_f_ret_f=dea_f*ret_f
	gen abs_ret_p=abs(ret_p)
	gen abs_ret_f=abs(ret_f)
	gen abs_dea_f_ret_f=dea_f*abs(ret_f)
	
	*adjusted return
	gen adj_ret_p=ret_p-vwretd
	gen adj_ret_f=ret_f-vwretd

	gen dea_f_adj_ret_f=dea_f*adj_ret_f
	
	gen abs_adj_ret_p=abs(adj_ret_p)
	gen abs_adj_ret_f=abs(adj_ret_f)
	gen abs_dea_f_adj_ret_f=dea_f*abs(adj_ret_f)
	
	**label variables
	do "$cwd\code\labvar.do"
	
		
	**BASELINE RESULT
	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	

	eststo clear
		qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
		qui eststo: reghdfe abs_adj_ret_p abs_adj_ret_f dea_f abs_dea_f_adj_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
		
		qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
		qui eststo: reghdfe adj_ret_p adj_ret_f dea_f dea_f_adj_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	esttab *, varwidth(20) stats(clustvar r2 N)
	
		
		
**Test using 3 DAYS APART in focal and peer EADs
use "$cwd\data\EAD_ret_vol_sich3.dta"  , clear 
		rename *, lower 
	
	tab fyear
	
	gen dea_f=(ead1==date)
	gen dea_f_ret_f=dea_f*ret_f
	gen abs_ret_p=abs(ret_p)
	gen abs_ret_f=abs(ret_f)
	gen abs_dea_f_ret_f=dea_f*abs(ret_f)
	
	*adjusted return
	gen adj_ret_p=ret_p-vwretd
	gen adj_ret_f=ret_f-vwretd

	gen dea_f_adj_ret_f=dea_f*adj_ret_f
	
	gen abs_adj_ret_p=abs(adj_ret_p)
	gen abs_adj_ret_f=abs(adj_ret_f)
	gen abs_dea_f_adj_ret_f=dea_f*abs(adj_ret_f)
	
	**label variables
	do "$cwd\code\labvar.do"
	
		
	**BASELINE RESULT
	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	winsor2 npeers surp1_medest_f ret_f adj_ret_f abs_ret_f abs_adj_ret_f  ret_p adj_ret_p  abs_ret_p abs_adj_ret_p , cut(1 99) replace	

	eststo clear
		qui eststo: reghdfe abs_ret_p abs_ret_f dea_f abs_dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
		qui eststo: reghdfe abs_adj_ret_p abs_adj_ret_f dea_f abs_dea_f_adj_ret_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
		
		qui eststo: reghdfe ret_p ret_f dea_f dea_f_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
		qui eststo: reghdfe adj_ret_p adj_ret_f dea_f dea_f_adj_ret_f, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	esttab *, varwidth(20) stats(clustvar r2 N)
	

	
**************************************************	
**Trading VOLUME tests
*********************************************
use "$cwd\data\processed\regressionsample$curdate.dta" , clear 
	
	**focal and peers must have common trading data: to be consistent with primary sample 
	keep if !missing(vol_f_scaled) &  !missing(vol_p_scaled)
	
	**focal EAD	
	gen dea_f_3 = (date - ead1)==-3
	gen dea_f_2 = (date - ead1)==-2
	gen dea_f_1 = (date - ead1)==-1
	cap gen dea_f=(ead1==date)	
	gen dea_f1 = (date - ead1)==1
	gen dea_f2 = (date - ead1)==2
	gen dea_f3 = (date - ead1)==3
	gen dea_f4 = (date - ead1)==4
	gen dea_f5 = (date - ead1)==5
	gen dea_f6 = (date - ead1)==6
	gen dea_f7 = (date - ead1)==7
	gen dea_f8 = (date - ead1)==8
	gen dea_f9 = (date - ead1)==9
	gen dea_f10 = (date - ead1)==10
		
		
	**Trading volume test on focal EAD
	sum vol_p_scaled vol_f_scaled
	
	winsor2 vol_p_scaled vol_f_scaled , cut(1 99) replace	
	
	egen indqtr = group(sich fyear fqtr)
	egen firmqtr =group(permno_f fyear fqtr)

	global clustvar "indqtr" //sich ead1 date  (Hann et al, 2019; Brochet et al)

	
	**convert to percentage
	replace vol_p_scaled = vol_p_scaled*100
	
	
	**summary statistics
eststo clear
	tabstat vol_p_scaled dea_f ,  stats(n mean p25 median p75 sd) column(stats)
	
	
**Regression: Peer TRADING VOLUME 
eststo clear
	qui eststo: reghdfe vol_p_scaled dea_f , noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
	*qui eststo: reghdfe vol_p_scaled dea_f_3 dea_f_2 dea_f_1 dea_f dea_f1 dea_f2 dea_f3 dea_f4 dea_f5 dea_f6 dea_f7 dea_f8 dea_f9 dea_f10, noabsorb /*absorb(sich fyear#fqtr)*/  cluster($clustvar)  
esttab *, varwidth(20) stats(clustvar r2 N)
	
	
	
**Graph: Peer TRADING VOLUME [-10, 10]
	gen time = date- ead1
	
	**aggregate for graph 
	bys time: egen median_peervol=median(vol_p_scaled)
	bys time: egen mean_peervol=mean( vol_p_scaled)
	
	bys time: egen median_focalvol=median( vol_f_scaled)
	bys time: egen mean_focalvol=mean( vol_f_scaled)
	
	sort time
	twoway (line median_peervol time)  (line mean_peervol time) if abs(time)<=10 , ytitle("Peer Trading Volume Scaled by No. of Shares (%)") xtitle("Days to Focal EAD") legend(label(1 "Median Peer Volume") label(2 "Mean Peer Volume"))
	
	sort time			
	twoway (line median_focalvol time) (line mean_focalvol time) if abs(time)<=10 , ytitle("Focal Trading Volume Scaled by No. of Shares (%)") xtitle("Days to Focal EAD") legend(label(1 "Median Focal Volume") label(2 "Mean Focal Volume"))
		
*************************************************************************************************************************

// **********Annual R2 Graph: VuongResult.xls file was output from running SAS "4_vuongtest.sas"
// import excel "$cwd\table\VuongResult.xls", sheet("vuong") cellrange(A3:E27) firstrow clear
// sort Year
// twoway (line BenchmarkR2 Year) (line FocalEADR2 Year ) , xlabel(1999(2)2022, angle(45)) ylabel(0 "0%" 1 "1%"  2 "2%" 3 "3%" 4 "4%") legend(label(1 "Benchmark R{superscript:2}") label(2 "Estimated R{superscript:2}")) ytitle("Average R{superscript:2}(%)") xtitle("Year") legend(label(1 "Benchmark R{superscript:2}(%)") label(2 "Estimated R{superscript:2}(%)"))

	
* End log
*****************************************************************************************
	di "***STATA STATISTICAL ANALYSIS ENDS HERE***   Date and Time: $S_DATE $S_TIME" 
*****************************************************************************************
cap log close
exit	
*******************End of file*********************	
	
	
	cap lab  var surp1_medest_f "Surprise (Focal)"
	cap lab  var surp2_meanest_f "Surprise (Focal)"
	cap lab  var numest_f "Analysts (Focal)"
	cap lab  var medest_f "Analysts Forecast (Focal)"
	cap lab  var meanest_f "Analysts Forecast (Focal)"
	cap lab  var dispersest_f "Forecast Dispersion (Focal)"
	cap lab  var epratio_f "EP Ratio (Focal)"
	cap lab  var prc_act_f "Price (Focal)"
	cap lab  var permno_p "Peer Firm"
	cap lab  var npeers "Number of Peers"
	cap lab  var ret_f "Signed Return (Focal)"
	cap lab  var ret_p "Signed Return (Peer)"
	cap lab  var dea_f "EAD (Focal)"
	cap lab  var dea_f_ret_f "EAD x Signed Return (Focal)" 
	cap lab  var abs_ret_p "|Return| (Peer)"
	cap lab  var abs_ret_f "|Return| (Focal)"
	cap lab  var abs_dea_f_ret_f "EAD x |Return| (Focal)"
	cap lab  var adj_ret_p "Signed MktAdj Return (Peer)"
	cap lab  var adj_ret_f "Signed MktAdj Return (Focal)"
	cap lab  var dea_f_adj_ret_f "EAD x Signed MktAdj Return(Focal)"
	cap lab  var abs_adj_ret_p "|MktAdj Return| (Peer)"
	cap lab  var abs_adj_ret_f "|MktAdj Return| (Focal)"
	cap lab  var abs_dea_f_adj_ret_f "EAD x |MktAdj Return| (Focal)"
	cap lab  var abs_surp1_medest_f "|Surprise| (Focal)"
	cap lab  var surprank_abs "|Surprise| Rank (Focal)"
	cap lab  var surprank "Signed Surprise Rank (Focal)"
	cap lab  var surprank_pos "Positive Surprise Rank (Focal)"
	cap lab  var surprank_neg "Negative Surprise Rank (Focal)"
	cap lab  var surp_abs "|Surprise| Rank (Focal)" 
	cap lab  var surp_abs_abs_dea_f_ret_f "EAD x |Return| (Focal) x |Surprise| Rank (Focal)"
	cap lab  var surp_dea_f_abs_ret_f  "EAD x |Return| (Focal) x Surprise Rank (Focal)"
	cap lab  var surp "Surprise Rank (Focal)" 
	cap lab  var surp_dea_f_ret_f "EAD x Return (Focal) x Surprise Rank (Focal)"
	cap lab  var surp_pos "Positive Surprise Rank (Focal)"
	cap lab  var surp_pos_dea_f_ret_f "EAD x Return (Focal) x Positive Surprise Rank (Focal)"
	cap lab  var surp_neg "Negative Surprise Rank (Focal)"
	cap lab  var surp_neg_dea_f_ret_f "EAD x Return (Focal) x Negative Surprise Rank (Focal)"
	cap lab  var surp_abs_dea_f_ret_f "EAD x Return (Focal) x |Surprise| Rank (Focal)"
	cap lab  var surp_pos_abs_dea_f_ret_f "EAD x |Return| (Focal) x Positive Surprise Rank (Focal)"
	cap lab  var surp_neg_abs_dea_f_ret_f "EAD x |Return| (Focal) x Positive Surprise Rank (Focal)"
	cap lab  var leader_f "Leader (Focal)"
	cap lab  var leader_abs_dea_f_ret_f "EAD x |Return| (Focal) x Leader (Focal)"
	cap lab  var leader_dea_f_ret_f "EAD x Return (Focal) x Leader (Focal)"
	cap lab  var comparab "Comparable"
	cap lab  var comparab_abs_dea_f_ret_f "EAD x |Return| (Focal) x Comparable"
	cap lab  var comparab_dea_f_ret_f "EAD x Return (Focal) x Comparable"
	cap lab  var comove "Comovement"
	cap lab  var comove_abs_dea_f_ret_f "EAD x |Return| (Focal) x Comovement"
	cap lab  var comove_dea_f_ret_f "EAD x Return (Focal) x Comovement"
	
	cap lab var adj_ret3d_p "Signed MktAdj Return(Peer)"
	cap lab var abs_ret3d_p "|Return(3-day)|(Peer)"
	cap lab var abs_adj_ret3d_p "|MktAdj Return|(Peer)"
