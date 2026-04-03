

// global data "/Users/frank/Dropbox/My Projects/powerlaw/Data"
global data "/Users/szho/Dropbox (Penn)/My Projects/powerlaw/Data/20231110"
global output "${data}/Output"


use "${data}/GeoPeer_DIDSample.dta", clear

gen year = year(datadate)
sort treated gvkey datadate
keep if year <=2019

tab treated 


********************************************************************************
* Generate variables
********************************************************************************

* Time variables
duplicates report treated gvkey datadate // no duplicates
sort treated gvkey datadate
by treated gvkey: gen nvals = _n
gen nvals1 = nvals if datadate == datadate0
by treated gvkey: egen nvals2 = total(nvals1)

gen time = nvals - nvals2
gen post = time >=1
drop nvals*
tab time
tab treated

by treated gvkey: gen nperiod = _N
gen time1 = time+3
gen sic3 = floor(sic/10)


global controls logat leverage mtb loss ret retvol roabeg 
winsor2 $controls , cuts(1 99) replace

egen gvkey1 = group(gvkey)
egen state1 = group(state)


********************************************************************************
* Sample selection
********************************************************************************


foreach var of varlist $controls {
	drop if `var' ==.
}











********************************************************************************
* Descriptives
********************************************************************************

tab treated 

* Summary stats
reg restate_core treated post $controls
estpost tabstat restate_core treated post $controls , stat(count mean sd p25 p50 p75) col(stat) 
esttab . using "$output/SummaryStatistics.csv", b(3) label ///
 cells("count mean(fmt (3)) sd(fmt (3)) p25(fmt (3)) p50(fmt (3)) p75(fmt (3))") main(mean) replace

 
 

* Summary stats by treatment in the pre-period
estimates clear
cap drop _est*
local i=1
foreach var of varlist restate_core $controls {
	reghdfe `var' treated if time ==-1, cluster(state1) a(i.sic3#i.year i.state1#i.year)
	est store t`i'
	local i=`i'+1
}
outreg2 t[*] using "${output}/SummaryStatistics_ByTreated_Significance.xml", bdec(3) drop(_I* o.*) br excel replace adjr2




* Analysis
estimates clear
cap drop _est*
local i=1

reghdfe restate_core c.treated##c.post , noa cluster(state1)
	est store t`i'
	local i=`i'+1
reghdfe restate_core c.treated##c.post $controls , a(i.gvkey1#i.treated i.sic3#i.year i.state1#i.year) cluster(state1) 
	est store t`i'
	local i=`i'+1
outreg2 t[*] using "${output}/DIDMain.xml", bdec(3) drop(_I* o.*) br excel replace 


reghdfe restate_core c.treated##c.post $controls , a(i.gvkey1#i.treated i.sic3#i.year i.state1#i.year) cluster(gvkey1) 
reghdfe restate_core c.treated##c.post $controls , a(i.gvkey1#i.treated i.sic3#i.year i.state1#i.year) cluster(sic2) 



// Figure 
reghdfe restate_core c.treated##b(2).time1 $controls , a(gvkey1 i.sic3#i.year i.state1#i.year) cluster(state1) 

* coefficient matrix
matrix coef_fe = J(1, 7, .)
matrix coln coef_fe= "-3" "-2" "-1" "0" "1" "2" "3" 

forvalues i=0(1)6{
	if `i' !=2{
		matrix coef_fe[1,`i'+1] = _b[c.treated#`i'.time1]
	}
}
matrix coef_fe[1,3] = 0

* standard errors matrix;
matrix coef_fe_ci = J(2, 7, .)
matrix coln coef_fe_ci= 1 2 3 4 5 6 7

forvalues i=0(1)6{
	if `i' !=2{
		matrix coef_fe_ci[1,`i'+1] = _b[c.treated#`i'.time1]-invttail(e(df_r), 0.05)*_se[c.treated#`i'.time1]
		matrix coef_fe_ci[2,`i'+1] = _b[c.treated#`i'.time1]+invttail(e(df_r), 0.05)*_se[c.treated#`i'.time1]
	}
}

matrix coef_fe_ci[1,3] = 0
matrix coef_fe_ci[2,3] = 0

#delimit ;
coefplot ///
matrix(coef_fe), ci(coef_fe_ci) legend(off) vertical ///
ciopts(recast(rcap) lcolor(edkblue)) graphregion(color(white) style(none)) ///
mlcolor(none) mfcolor(maroon) mlcolor(edkblue) msize(*1.2) msymbol(o) ///
xline(4, lwidth(*1) lstyle(major_grid) lcolor(blue) lp(shortdash) noextend) ///
text(0.08 2.5 "Peer Restatement", color(blue) place(e) size(small)) ///
yline(0, lcolor(black*0.5) lwidth(*1.0) lpattern(solid)) ///
xtitle ("Time", size(medsmall) color(black)) ///
ytitle("Misstatement", size(medsmall) color(black)) ///
xlabel(, valuelabel labsize(small) tposition(crossing) tlcolor(gs10) noticks) ///
ylabel(-0.14 "-14%" -0.10 "-10%" -0.06 "-6%" -0.02 "-2%" 0.02 "2%" 0.06 "6%" 0.10 "10%", nogrid labsize(small) tposition(crossing) tlcolor(gs10)) ///
;
#delimit cr	

graph export "${output}/GeoPeer_DID_Figure.pdf", replace





// global path "/Users/frank/Dropbox/My Projects/powerlaw/Data/20231110"
global path "/Users/szho/Dropbox (Penn)/My Projects/powerlaw/Data/20231110"
global output "${path}/Output"

use "${path}/comp_restate_v3.dta", clear
merge m:1 restatement_notification_fkey using "${path}/comp_restate_total.dta", keep(1 3) nogen
sort restatement_notification_fkey company_fkey year



********************************************************************************
********************************************************************************

* Variable creation

********************************************************************************
********************************************************************************

gen misamount = -change_net_income/at0/1000000
by restatement_notification_fkey: egen nperiods = max(period)
tab nperiods

by restatement_notification_fkey company_fkey: egen nvals = max(misamount)
gen largemis = misamount == nvals
drop nvals

* rate of increase
sort restatement_notification_fkey company_fkey period
by restatement_notification_fkey company_fkey: gen delta_misamount = misamount[_n] - misamount[_n-1]

by restatement_notification_fkey company_fkey: egen nvals = max(delta_misamount)
gen largedeltamis = delta_misamount == nvals
replace largedeltamis = . if nvals ==. | nperiods ==2 | nperiods ==1
drop nvals





********************************************************************************
********************************************************************************

* Sample selection

********************************************************************************
********************************************************************************


sort restatement_notification_fkey company_fkey year
gen nvals = change_net_income >=0
by restatement_notification_fkey: egen nvals1 = total(nvals)
gen up = nvals1 >0
keep if up ==0 
drop nvals*

keep if at0 >=1 & misamount <=5 

gen res_begin_year = year(res_begin_date)
gen res_end_year = year(res_end_date)
keep if year >=2005 






********************************************************************************
********************************************************************************

* Analyzing time series patterns

********************************************************************************
********************************************************************************


* Descriptives
tab period if nperiod==2 & restate_core ==1, summarize(misamount)
tab period if nperiod==3 & restate_core ==1, summarize(misamount)
tab period if nperiod==4 & restate_core ==1, summarize(misamount)
tab period if nperiod==5 & restate_core ==1, summarize(misamount)





* Regressions
est clear
local i=1

reghdfe largemis period if nperiods >=2 & restate_core==1, a(restatement_notification_fkey) cluster(company_fkey)
	est store t`i'
	local i=`i'+1
reghdfe largemis lastperiod if nperiods >=2 & restate_core==1, a(restatement_notification_fkey) cluster(company_fkey)
	est store t`i'
	local i=`i'+1
reghdfe largedeltamis period if nperiods >=3 & restate_core==1, a(restatement_notification_fkey) cluster(company_fkey)
	est store t`i'
	local i=`i'+1
reghdfe largedeltamis lastperiod if nperiods >=3 & restate_core==1, a(restatement_notification_fkey) cluster(company_fkey)
	est store t`i'
	local i=`i'+1
outreg2 t[*] using "${output}/Table1_Dynamic.xml", bdec(3) drop(o.* _I*) br excel replace addtext(Restatement FE, YES, CLUSTER, Restatement)

*******************************************************************************
********* Prepare Audit Analytics datasets*************************************
*******************************************************************************

global data "/Users/szho/Dropbox (Penn)/My Projects/powerlaw/Data/Restatement"
global output "/Users/szho/Dropbox (Penn)/My Projects/Powerlaw/Data/20231110"

** Obtain restatement filing date
use "${data}/datasets/feed39_washun",clear
* Restatement_notification_key identifies unique restatements in AA data. 
keep restatement_notification_key company_fkey file_date_num res_begin_date res_end_date res_accounting_restatement_categ res_fraud res_adverse res_board_approval res_sec_investigation restated_cum_net_income initial_cum_net_income change_cum_net_income  quarterly_restated_only res_clerical_errors date_of_8k_402
sort restatement_notification_key
rename restatement_notification_key restatement_notification_fkey  

gen nvals = restated_cum_net_income - initial_cum_net_income 
replace change_cum_net_income = nvals if nvals !=.
drop nvals

drop if change_cum_net_income >=0
duplicates report restatement_notification_fkey 

foreach var of varlist res_begin_date res_end_date{
	
	gen nvals1 = date( `var', "MDY")
	drop `var'
	gen `var' = nvals1
	format `var' %td
	drop nvals1

}
drop if quarterly_restated_only==1

saveold "${output}/restatement_impact_total",replace version(12)
*******************************************************************************
********* Prepare Audit Analytics datasets*************************************
*******************************************************************************


global data "/Users/szho/Dropbox (Penn)/My Projects/powerlaw/Data/Restatement"
global output "/Users/szho/Dropbox (Penn)/My Projects/Powerlaw/Data/20231110"


** Obtain restatement filing date
use "${data}/datasets/feed39_washun",clear
* Restatement_notification_key identifies unique restatements in AA data. 

keep restatement_notification_key company_fkey file_date_num res_begin_date res_end_date res_accounting_restatement_categ res_fraud res_adverse res_board_approval res_sec_investigation change_cum_net_income initial_cum_net_income restated_cum_net_income  
sort restatement_notification_key
rename restatement_notification_key restatement_notification_fkey

gen nvals = restated_cum_net_income - initial_cum_net_income 
replace change_cum_net_income = nvals if nvals !=.
drop nvals


foreach var of varlist res_begin_date res_end_date{
	
	gen nvals1 = date( `var', "MDY")
	drop `var'
	gen `var' = nvals1
	format `var' %td
	drop nvals1

}

saveold "${output}/restatement_linkfile", replace version(12)







*******************************************************************************
*******************************************************************************
*******************************************************************************

use "${data}/datasets/restatement_periods", clear
merge m:1 restatement_notification_fkey using datasets/restatement_linkfile, keep(3) nogenerate
drop if missing(company_fkey)

drop include_in_income_calculations
merge m:1 restatement_filing_fkey using datasets/restatement_filings, keep(1 3)
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           282
        from master                       282  (_merge==1)
        from using                          0  (_merge==2)

    matched                            84,045  (_merge==3)
*/
keep if _merge ==3 
drop _merge

order company_fkey year type file_date_num restatement_filing_fkey restatement_notification_fkey
sort restatement_notification_fkey  company_fkey year type file_date_num restatement_filing_fkey 





*******************************************************************************
* Adjust restatement amounts
*******************************************************************************

// The zero amounts often belong to different filings of the same misstatement. 
// These amounts have no consequences for computing the amount of misstatements, since they are zero. 
drop if (initial_net_income ==0 & restated_net_income ==0) | ( restated_net_income ==.)

gen change_net_income1 = restated_net_income - initial_net_income 
gen nvals1 = (change_net_income1 - change_net_income)/abs(change_net_income1)
sum nvals1,d // many observations for which nvals1 is not equal to change_net_income provided by audit analytics. Many seem to be driven by calculation errors
/*
company_fkey	year	type	file_date_num	initial_net_income	restated_net_income	change_net_income	change_net_income1
49534	2010	Q4	20110609	5923870	6530866	-.05	606996
49534	2011	Q1	20110609	7610595	8183150	-.07	572555
49534	2011	Q2	20110609	8100368	8252093	-.1	151725
*/
count if change_net_income1 ==. & change_net_income !=. // zero observation
replace change_net_income=change_net_income1 if change_net_income1 !=.
drop nvals1 change_net_income1
drop if change_net_income ==.


* Set restatement begin and end years 
tostring file_date_num, replace
gen nvals1 = date( file_date_num, "YMD")
format nvals1 %td
drop file_date_num
gen file_date_num = nvals1
format file_date_num %td
drop nvals1


gen nvals1 = date( file_date, "MDY")
format nvals1 %td
drop file_date
gen file_date = nvals1
format file_date %td
drop nvals1

gen nvals1 = file_accepted + ":00"
gen double nvals = clock(nvals1, "MDY hms")
format nvals %tcCCYY.NN.DD_HH:MM
drop file_accepted
gen file_accepted =nvals
format file_accepted %tcCCYY.NN.DD_HH:MM
drop nvals*

replace file_date = file_date_num if file_date ==.























*******************************************************************************

* Keep annual
keep if type == "Y"
*******************************************************************************





















*******************************************************************************
* Dealing with duplicates

* There are duplicate observations for the same restatement (restatement_notification_fkey)
* year, and restatement type (Y or Q1 to Q4). 

/*
For example, for company 1042173, there are two obsevations in 2003 Q2
restatement_period_key	company_fkey	restatement_notification_fkey	restatement_filing_fkey	year	type	initial_net_income	restated_net_income
177328	1042173	1	32195	2003	Q2	-56000	745000
283501	1042173	1	537	2003	Q2	-56000	745000
*/
*******************************************************************************



* 1. Drop duplicate for each company, year, type, and restatement filing
* restatement filing is finer than restatement_notification_fkey

bys restatement_filing_fkey: egen nvals =sd(restatement_notification_fkey)
sum nvals // sanity check, should be zero
drop nvals

duplicates report restatement_notification_fkey company_fkey year restatement_filing_fkey 
* No duplicates














* 2. Drop duplicate net income numbers for each company, year, and restatement
* For the same misstatement (i.e., restatement_notification_fkey) and type, there should be only one initial net income number
* and one restated net income number. 


* Note that different restatement_filing_fkey may correspond to the same misstatements, so it is important to drop duplicates;
* For example:
/*
company_fkey	year	type	restatement_filing_fkey	restatement_notification_fkey	restatement_period_key	initial_net_income	restated_net_income
1681682	2015	Y	93313	55334	266941	-2147634	-2279204
1681682	2015	Y	95689	55334	266937	-2147634	-2279204
1681682	2015	Y	95690	55334	266933	-2147634	-2213698
1681682	2015	Y	95691	55334	266931	-2147634	-2213698
1681682	2015	Y	95692	55334	266929	-2147634	-2213698
1681682	2015	Y	95693	55334	266927	-2147634	-2213698
1681682	2015	Y	95694	55334	266925	-2147634	-2213698
1681682	2015	Y	95695	55334	266923	-2147634	-2213698
1681682	2015	Y	95696	55334	266921	-2147634	-2213698
1681682	2015	Y	95697	55334	266945	-2147634	-2279204
1681682	2015	Y	95698	55334	266948	-2147634	-2279204
1681682	2015	Y	95699	55334	266950	-2147634	-2279204
*/



* 2.1 Keep those with include_in_income_calculations ==1, following Zakolyukina (2018). 
* include_in_income_calculations is verified by audit analytics
duplicates tag restatement_notification_fkey company_fkey year, gen(dup)
tab dup

sort restatement_notification_fkey  company_fkey year
by restatement_notification_fkey company_fkey year: egen nvals = total(include_in_income_calculations)
drop if dup >=1 & nvals >0 & include_in_income_calculations == 0
drop dup nvals 








* 2.2 Get rid of zero restated numbers when non-zero numbers exist
/*
* Zero restated numbers
company_fkey	year	type	restatement_notification_fkey	restatement_filing_fkey	file_date	file_accepted	initial_net_income	restated_net_income
711039	2004	Y	37946	60863	04may2005	2005.05.04 16:30	-364000	0
711039	2004	Y	37946	60864	04may2005	2005.05.04 16:30	-364000	0
711039	2004	Y	37946	60866	13may2005	2005.05.13 06:02	-1.819e+08	-1.834e+08
*/

sort restatement_notification_fkey  company_fkey year
gen nvals = restated_net_income !=0
by restatement_notification_fkey  company_fkey year: egen nvals1 = total(nvals)
drop if nvals1 >0 & nvals ==0
drop nvals*



* 2.3 Drop duplicates for each company, year, type, restatement, file date, intitial and restated numbers, as these are for sure duplicates. 
duplicates drop restatement_notification_fkey company_fkey year file_date initial_net_income restated_net_income, force




* 2.4 For the same missatement, keep those with last filing dates

/*
Below is an example based on type = "Q1", but note that we dropped this type eventually, keeping only annual restatements
company_fkey	year	type	restatement_notification_fkey	file_date	initial_net_income	restated_net_income	restatement_filing_fkey
3116	2012	Q1	39042	07aug2012	8492000	1228000		63625
3116	2012	Q1	39042	14aug2012	8492000	3108000		63813

* 07aug2012: 8-K filings https://www.sec.gov/Archives/edgar/data/3116/000115752312004317/a50368747_ex99-1.htm
/*
Akorn to File Amended Unaudited Financial Statements for the Quarter Ended March 31, 2012

LAKE FOREST, Ill.--(BUSINESS WIRE)--August 7, 2012--Akorn, Inc. (NASDAQ: AKRX), a niche generic pharmaceutical company, today announced that it will restate the previously issued unaudited financial statements contained in its Quarterly Report on Form 10-Q for the fiscal quarter ended March 31, 2012.

The previously disclosed $66.7 million purchase price for the acquisition of Kilitch Drugs (India) Limited was originally recorded in the first quarter of 2012. During the second quarter of 2012, the Company determined that its preliminary accounting for the acquisition of Kilitch Drugs (India) Limited needed to be corrected, as certain items that had been previously capitalized as purchase price needed to be expensed as either compensation earned from the achievement of acquisition related milestones or other acquisition costs. As a result of the restatement Akorn will re-characterize approximately $8.3 million of originally recorded purchase price as additional expense for the quarter ended March 31, 2012.

In addition, the Company’s consolidated statements of cash flows for the three months ended March 31, 2012 and 2011 have been adjusted to correct a classification error. The error resulted in an understatement of net cash provided by operating activities of $1.4 million, with a corresponding understatement of net cash used in investing activities for the three months ended March 31, 2012 and an overstatement of net cash provided by operating activities of $0.5 million, with a corresponding overstatement of net cash used in investing activities for the three month period ended March 31, 2011.

To address these matters, Akorn expects to file an amendment to its Quarterly Report on Form 10-Q for the fiscal quarter ended March 31, 2012 to reflect the corrections and accordingly, the referenced financial statements should not be relied upon until such time as the company files its restated financial statements.

The decision to restate prior financial statements based on these matters was made by the Audit Committee of Akorn’s Board of Directors, upon the recommendation of management. The company believes that the corrections will not impact its current cash or liquidity position. In connection with this matter, the company has re-evaluated its conclusions regarding the effectiveness of its internal control over financial reporting for the affected period and determined that a material weakness existed at March 31, 2012. The company had previously concluded in its Quarterly Report on Form 10-Q for the fiscal quarter March 31, 2012 that is controls were effective as of March 31, 2012. As a result of the material weakness, the company has now concluded that such controls were ineffective. Accordingly, the company will restate its disclosures as of March 31, 2012 to include the identification of a material weakness related to its restatement.
*/


* 14aug2012: 10-Q
The effect of the restatement on the condensed consolidated income statement for the three months ended March 31, 2012 is as follows:
Consolidated net income	 	 	8,492	 	 	 	(5,384	)	 	 	3,108	
This is the number reported above for date 14aug2012
*/

duplicates tag restatement_notification_fkey company_fkey year, gen(dup)
tab dup
sort restatement_notification_fkey company_fkey year file_date
by restatement_notification_fkey company_fkey year: gen last_file_date=file_date[_N]
drop if dup>=1 & file_date != last_file_date
drop dup



duplicates tag restatement_notification_fkey company_fkey year, gen(dup)
tab dup
sort restatement_notification_fkey company_fkey year file_accepted
by restatement_notification_fkey company_fkey year: gen last_file_accpeted=file_accepted[_N]
drop if dup>=1 & file_accepted != last_file_accpeted
drop dup






* Examine remaining duplicates for each company, year, type, restatement
* Still some duplicates remain but only 0.27%. 
duplicates tag restatement_notification_fkey company_fkey year, gen(dup)
tab dup
drop dup




* Keep the most negative restatement number when there is at least one negative number,
* and the most positive restatement number when there is no negative number for each company, year, type, and filing date

sort restatement_notification_fkey company_fkey year
by restatement_notification_fkey company_fkey year: egen nvals1 = min(change_net_income)
replace nvals1 = nvals1 <0 // an indicator for whether the smallest (i.e., most negative) number of change in net income is negative. 
gen nvals = nvals1*change_net_income + (1-nvals)*(-change_net_income)
sort restatement_notification_fkey company_fkey year nvals
by restatement_notification_fkey company_fkey year: gen nvals2=_n==1
keep if nvals2==1
drop nvals*






keep restatement_notification_fkey company_fkey year change_net_income file_date_num res_begin_date res_end_date res_accounting_restatement_categ res_fraud res_adverse res_board_approval res_sec_investigation change_cum_net_income initial_cum_net_income restated_cum_net_income
label var change_net_income "change in raw net income"







*******************************************************************************
* Generate restatement episode and keep negative cumulative effects
*******************************************************************************

* Generate restatement episode
sort restatement_notification_fkey company_fkey year
by restatement_notification_fkey company_fkey (year): gen period = _n
by restatement_notification_fkey company_fkey (year): gen lastperiod = period == _N

by restatement_notification_fkey company_fkey: egen change_cum_net_income1 = total(change_net_income)
replace change_cum_net_income = change_cum_net_income1 if change_cum_net_income ==.


sort restatement_notification_fkey company_fkey year
by restatement_notification_fkey company_fkey: gen firstyear= year[1]



* Keep negative cumulative effects
keep if change_cum_net_income <0
saveold "${output}/restatement_impact_annual_v2.dta",replace version(12)



