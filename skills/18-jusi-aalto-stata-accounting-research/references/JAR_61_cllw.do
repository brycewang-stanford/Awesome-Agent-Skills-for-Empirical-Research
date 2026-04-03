*The Following code is used to construct the main sample and to run the main tests for the study
*"Flu Fallout: Information Production Constraints and Corporate Disclosure" forthcoming at JAR

*******************************************************************************************************************
*STEP1: Identify the EA dates for each quarter that will later be used to identify bundled forecasts.
*DataSource 1: obtain all the EA dates from IBES_Actual dataset from year 2003 to 2018, named IBES_Actual_Raw.dta
use IBES_Actual_Raw.dta
keep if curr_act =="USD"
keep if usfirm ==1
g Ann_EA = 1 if pdicity == "ANN"
replace Ann_EA = 0 if pdicity == "QTR"
drop if ticker=="0000"

gsort ticker pends anndats -Ann_EA
duplicates drop ticker pends anndats ,force
keep ticker pends anndats Ann_EA

rename anndats EA_date
rename pends datadate
drop if EA_date<datadate

*identify the quarter end after the Earnings Announcement (EA), i.e., FQEt+1 in Figure 1, named fdate.
g fdate = mdy(month(datadate) + 4, 1,year(datadate))
replace fdate = mdy(month(datadate)-8,1,year(datadate)+1) if fdate==.
replace fdate = fdate -1
format fdate %td
*Drop the EA dates that are later than FQEt+1
drop if EA_date > fdate

g year=year(datadate)
*Merge GVKEY onto the file using the GVKEY-TICKER linkfile, generated using the SAS program provided by WRDS (https://wrds-www.wharton.upenn.edu/pages/support/sample-programs/ibes/link-ibes-ticker-compustat-gvkey/) 
merge m:1 ticker year using Gvkey-IBES.dta, keepusing(gvkey1)
drop if _merge==2
drop _merge
order gvkey1 ticker permno datadate EA_date Ann_EA

*By ticker: replace the missing gvkey using the most recent values 
gsort ticker -EA_date
by ticker: replace gvkey1=gvkey1[_n-1] if gvkey1==. & gvkey1[_n-1]!=.
sort ticker EA_date
by ticker: replace gvkey1=gvkey1[_n-1] if gvkey1==. & gvkey1[_n-1]!=.
drop if gvkey1==.
drop year fdate
sort gvkey1 datadate EA_date
save EA_Dates.dta,replace

********************************************************************************
*STEP2: Clean management forecasts file
*DataSource 2: Download MF_Raw.dta, which contains all the variable from IBES Guidance database
use MF_Raw.dta
keep if curr=="USD"
keep if pdicity =="ANN" | pdicity =="QTR"
keep if measure =="EPS"
keep if year(anndats) >= 2001 & year(anndats) <= 2018
drop act_std curr units actdats mod_date acttims anntims mod_time usfirm diff_code action eefymo

sort ticker pdicity prd_yr prd_mon anndats
rename prd_yr year
rename prd_mon month
rename mean_at_date Consensus

*Generate the Forecasted Date of each MF using the prd_yr and prd_mon, named MF_datadate
g MF_datadate=mdy(month +1,1,year)
replace MF_datadate = mdy(1,1, year+1) if month==12
format MF_datadate %td
replace MF_datadate = MF_datadate -1

drop if anndats > MF_datadate //drop preannouncements

*Merge Actual EPS from IBES, using the actual EPS value from IBES
drop year month
save MF.dta,replace

********************************************************************************
*STEP3: Construct the main file, Compustat quarterly file
*DataSource 3: Download quarterly data from Compustat Quarterly, named Comp_Raw.dta
*Variables: gvkey datadate fyearq fyear fqtr fic sic atq ceqq cshoq dlcq dlttq niq oiadpq xrdq aqcy dltisy oancfy sstky prccq
use Comp_Raw.dta
destring gvkey,gen(gvkey1)
destring sic,gen(sicc)
drop if fic!="USA"

rename fyearq fyear
g fyearq = yq(fyear,fqtr)
format fyearq %tq
keep if fyear>=2003 & fyear<=2019

*Clean the data to keep unique firm-quarter observations
egen mis=rmiss( atq ceqq cshoq dlcq dlttq niq oiadpq xrdq aqcy dltisy oancfy sstky prccq)
gsort gvkey1 datadate mis -fyearq
duplicates drop gvkey1 datadate,force
gsort gvkey1 fyearq mis -datadate
duplicates drop gvkey1 fyearq,force
drop gvkey fic sic mis

*Merge the stock price at the end of each fiscal quarter from CRSP (If missing, replace with prccq)
merge m:1 gvkey1 datadate using Lag_Price.dta
drop if _merge==2
drop _merge
replace Lag_Price = prccq if Lag_Price ==.

*Generate the date FQEt+1, called fdate
g fdate = mdy(month(datadate) + 4, 1,year(datadate))
replace fdate = mdy(month(datadate) - 8,1,year(datadate)+1) if fdate==.
replace fdate = fdate -1
format fdate %td

********************************************************************************
*Merge EA dates previously prepared in STEP1
merge 1:m gvkey1 datadate using EA_Dates.dta
drop if _merge==2
drop _merge

order gvkey1 permno ticker fyearq fyear fqtr datadate  EA_date Ann_EA rdq
sort gvkey1  fyearq EA_date
bysort gvkey1 datadate: egen count = nvals(EA_date)

*Make sure each firm-quarter just has one EA, that has the most consistent information accross the two database
g mark = abs(rdq - EA_date) if EA_date < rdq+14
g mark1 = cond((fqtr==4 & Ann_EA ==1) | (fqtr!=4 & Ann_EA!=1),1,0)
gsort gvkey1 datadate mark -mark1
duplicates drop gvkey1 datadate,force
drop count mark mark1

xtset gvkey1 fyearq,q

*Drop the EA dates that are later than FQEt+1
drop if EA_date ==.
drop if EA_date > fdate

g Lag = EA_date -datadate
********************************************************************************
*Merge the Headquarter State Information  from the 10-K Header File obtained from McDonald's website
*(https://sraf.nd.edu/data/augmented-10-x-header-data/)
merge m:1 gvkey1 fyear using 10K_Header.dta, keepusing(State_HQ)
drop if _merge==2
drop _merge

*replace missing values using the most recent values
gsort gvkey1 -datadate
by gvkey1: replace State_HQ=State_HQ[_n-1] if State_HQ =="" & State_HQ[_n-1]!=""
sort gvkey1 datadate
by gvkey1: replace State_HQ=State_HQ[_n-1] if State_HQ =="" & State_HQ[_n-1]!=""

drop if State_HQ==""
********************************************************************************
*Merge information production window (IPW) Flu Variables, IPW is defined in figure 1
g begin = datadate+1
g end = EA_date -1
*Need to first install the package rangejoin:
*ssc install rangejoin

*Merge the Flu File from CDC and Google Flu Trend, Note that we have expended the weekly data to daily level
rangejoin date begin end using Flu.dta , by(State_HQ)
sort gvkey1 fyearq date
by gvkey1 fyearq: egen Flu_CG = mean(Flu)
*As flu data are missing between Sept 2009 and Oct 2010,to make sure that the IPW does not contain days with missing flu information (as suggested by the reviewer), we require that each day within the IPW to have flu information

by gvkey1 fyearq: egen NUM = nvals(date)
replace Flu_CG = . if Lag - NUM!=1

duplicates drop gvkey1 fyearq,force
drop date Flu NUM

********************************************************************************
*Control Variables
xtset gvkey1 fyearq,q

g Year = year(EA_date)
g Month = month(EA_date)
g Quarter = floor((month(EA_date)-1) / 3) + 1

g Size=log(atq)
g MB= (prccq*cshoq + dlttq) / atq
g Loss = cond(niq<0,1,0) if niq!=.

*Merge Analyst variable from IBES
merge 1:1 gvkey1 datadate using Analyst_Quarterly.dta, keepusing(Coverage_Q Dispersion MBanalyst)
drop if _merge==2
drop _merge
g LogAnalyst = log(1+Coverage_Q)

*Merge institutional shareholding data, generated using the SAS program provided by WRDS
*(https://wrds-www.wharton.upenn.edu/pages/support/applications/institutional-ownership-research/institutional-ownership-concentration-and-breadth-ratios/)
merge 1:1 gvkey1 fyearq using IOR_Quarterly.dta,keepusing(IOR)
drop if _merge==2
drop _merge

*Merge the quarterly EPS volatility calculated from Compustat Quarterly database
merge 1:1 gvkey1 fyearq using EPS_Vol.dta
drop if _merge==2
drop _merge

*Merge quarterly stock return calculated from CRSP
merge 1:1 gvkey1 fyearq using Ret_Quarterly.dta, keepusing(Ret)
drop if _merge==2
drop _merge

*Merge Analyst variable from industry-level MF issuance data downloaded from IBES and generated seperately following Houston et al. (2011 CAR)
merge m:1 sic2 fyearq using IndIssue.dta
drop if _merge==2
drop _merge

*Merge Error-related restatement data obtained from AuditAnalytics Restatement database
merge 1:1 gvkey1 datadate using Restatement.dta, keepusing(Error)
drop if _merge==2
drop _merge
replace Error=0 if Error==.

********************************************************************************
xtset gvkey1 fyearq,q
egen StatexYQ = group(State Year Quarter)

*Merge bundled MFs
g begin = EA_date-1
g end = EA_date+1
rangejoin anndats begin end using MF.dta,by(ticker)

********************************************************************************
g Short = 1 if MF_datadate == fdate
replace Short=1 if Short==. & Horizon<=92

*Clean the data to keep only on MF for each announcement date-forecasted date combination, based on precision and availability of Analyst Concensus by IBES
g MF_Precision=2 if range_de=="02"
replace MF_Precision=1 if range_de=="01" | range_de=="06" |range_de=="08"
replace MF_Precision=0 if MF_Precision==. & val_1!=.

gsort gvkey1 fyearq pdicity anndats MF_datadate -MF_Precision Consensus
duplicates drop gvkey1 fyearq pdicity anndats MF_datadate,force
********************************************************************************

*Generate MF Frequency variables
bysort gvkey1 fyearq: egen Freq = nvals(MF_datadate)
replace Freq = 0 if Freq ==.
g Issue_EPS = cond(Freq>0,1,0)

bysort gvkey1 fyearq: egen Freq1 = nvals(MF_datadate) if Short==1
bysort gvkey1 fyearq: egen Issue_Short = mean( Freq1 )
replace Issue_Short=0 if Issue_Short==.
drop Freq1

g Freq_Long = Freq - Issue_Short
g Issue_Long = cond(Freq_Long>0,1,0)

********************************************************************************

duplicates drop gvkey1 fyearq,force
drop anndats MF_datadate pdicity measure range_de guidance val_1 val_2 Consensus MF_Precision Short 

keep if Year>=2003 & Year<=2018
*Drop firms that never issued MF during our sample period
bysort gvkey1: egen Ever_Issued = max(Freq)
keep if Ever_Issued!=0
drop Ever_Issued

********************************************************************************
*Winsorize all the continuous control variables 
winsor2 Flu_CG, c(1 99) s(_w) by(Year)

winsor2 Size MB LogAnalyst EPS_Vol Dispersion dEPS FutureEPS Return, c(1 99) s(_w) by(fyear)

global Controls Size_w MB_w LogAnalyst_w IOR EPS_Vol_w Dispersion_w MBanalyst Loss dEPS_w FutureEPS_w Return_w LogLag Error

reghdfe Issue_EPS Flu_CG_w $Controls, a(gvkey1 StatexYQ) vce(cl StatexYQ) nocon
keep if e(sample)

********************************************************************************
*Table 2 Descriptives
********************************************************************************
sum2docx Issue_EPS Issue_Short Issue_Long Flu_CG_w $Controls using Table2.docx, stats(mean sd p5 p25 median p75 p95) landscape replace

corr2docx Issue_EPS Issue_Short Issue_Long Flu_CG_w $Controls using Table2.docx, landscape nodiagonal star(* 0.01) append

********************************************************************************
* Table 3 Panel A Forecast Issuance Decisions
********************************************************************************
*Column (1)
reghdfe Issue_EPS Flu_CG_w $Controls IndIssue, a(gvkey1 StatexYQ) vce(cl StatexYQ) nocon
outreg2 using results.xls, tdec(2) rdec(3) bdec(3) parenthesis(tstat) adj tstat replace
*Column (2)
reghdfe Issue_Short Flu_CG_w $Controls IndIssue_Short, a(gvkey1 StatexYQ) vce(cl StatexYQ) nocon
outreg2 using results.xls, tdec(2) rdec(3) bdec(3) parenthesis(tstat) adj tstat 
*Column (3)
reghdfe Issue_Long Flu_CG_w $Controls IndIssue_Long, a(gvkey1 StatexYQ) vce(cl StatexYQ) nocon
outreg2 using results.xls, tdec(2) rdec(3) bdec(3) parenthesis(tstat) adj tstat 
