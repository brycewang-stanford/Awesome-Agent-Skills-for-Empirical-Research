clear all
version 13.1
capture log close
capture log off

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\" // Contains 4 folders: 1_Sources, 2_Code, 3_Datasets, 4_Output

***********************************************
*********** Define Global Variables ***********
***********************************************

global LOG_FILE_YES_NO = "YES"

***********************************************
**************** Run Codes ********************
***********************************************

**** Pass on Log File Options to Do-Files ******

if "${LOG_FILE_YES_NO}" == "YES" {
		global LOG_FILE_OPTION = ""
	 	log using "${STANDARD_FOLDER}\4_Output\LogFile\ResultLog", replace smcl
}
else { 
	global LOG_FILE_OPTION = "capture log off"

}

*************** Import Data *******************

do "${STANDARD_FOLDER}\2_Code\01_Import_Bloomberg"
do "${STANDARD_FOLDER}\2_Code\02_Import_HandCollected"
do "${STANDARD_FOLDER}\2_Code\03_Import_DatastreamIBES"
do "${STANDARD_FOLDER}\2_Code\04_Import_Various"
do "${STANDARD_FOLDER}\2_Code\05_Import_Sell_Side_Analyst_Survey" 	// code also contains analyses related to the analyst survey
do "${STANDARD_FOLDER}\2_Code\06_Import_IR_Survey"				 	// code also contains analyses related to the IR survey

********** Connect and Prepare Data ************

do "${STANDARD_FOLDER}\2_Code\10_Merge_Datafiles"
do "${STANDARD_FOLDER}\2_Code\11_Preparation_Main_Variables"

*****************Make Analyses ****************

do "${STANDARD_FOLDER}\2_Code\20_Main_Archival_Analysis"


// the 90_* and 91_* do-files are included in one of the other do-files

if "${LOG_FILE_YES_NO}" == "YES" {
	log close _all
}


exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

* 1. IntradayBar Data from Bloomberg via the Bloomberg excel tool:
/* Miniute-by-minute ask, bid and trade prices as well as corresponding volumes. Due to data download limitations of Bloomberg as well as technical limitations of the terminal itself, 
the downloads were conducted on three different occasions (Part1, Part2, Part 3):

Part 1 covers the data from August 4, 2014 until February 16, 2015 	(Downloaded on February 16, 2015)
Part 2 covers the data from February 16, 2015 until March 31, 2015 	(Downloaded on April 1, 2015)
Part 3 covers the data from March 2, 2015 until May 31, 2015 		(Downloaded on May 31, 2015)

These three parts are overlapping in terms of dates, which was intentional to verify the completeness of the time series and to ensure that stock splits etc. are not disrupting the time series for certain firms.
Bid Prices, Ask Prices and Trade Prices (as well as corresponding volumes) are all saved in separate folders ("Ask", "Bid" and "Trade").
The data for each firm ticker is a separate Excel workfile within each folder. 
In total 3 (ask, bid, trade) * 3 (part1, part2, part3) *241 (ticker symbols) = 2,169 excel files need to be imported */

* 2. Trading Days calendar (Downloaded April 16, 2015): 
/* Excel file that contains all days and indicates whether they are trading days (=1) or not (=0; e.g. Saturdays and Sundays).
Manually transcribed from SIX Exchange Trading Calendar ("Trading Calendar 2015", "Trading Calendar 2014"). */

local TRADING_FILE = "TradingDays.dta"

*3. Market Value Data from Bloomberg via the Bloomberg excel tool (Downloaded on November 10, 2015):
/* Daily Market Value Data. Compared to the intraday data (which was downloaded on an earlier date), two ticker symbols changed. 
These two ticker symbols are replaced later in the code below*/

local MV_FILE "AllMvMvcSharesAllNoTwoTickerChangesCopy.xlsx"

*** OUTPUT:

local SAVEFILE_MV_DAILY 	= "BloombergMVShares.dta"
local SAVEFILE_BLOOM_MERGE 	= "BloombergMerge.dta"
local SAVEFILE_PX_LAST 		= "PXLastIntraday.dta"
local ROLLINGVOL 			= "IntradayRollingWindow.dta"

*********************************************************************
*********************************************************************
***************I. Import Bloomberg Intraday Data ********************
*********************************************************************
*********************************************************************

***********************************************
********* Import Actual Excel files ***********
***********************************************

capture cd ${STANDARD_FOLDER}


scalar MAXLOOP = 242 // SSIP with 241 firms (still contains 4 duplicate tickers); 242 instead of 241 since Sheet 1 just lists firm tickers (hence, not included in loop below)

foreach PART in Part1 Part2 Part3 {
	foreach TYPE in Trade Bid Ask {
	
* Loop through folders (Parts and Type of Quotes/Trades)

		forvalues i=`=scalar(MAXLOOP)'(-1)2 {
		
			qui cd "${STANDARD_FOLDER}\1_Sources\IntradayBar-`PART'"
			qui cd "`TYPE'\AllSheets"
	
* Capture the Company name (Bloomberg ID) from cell A1
	
			import excel using Sheet`i'`TYPE'.xlsx, ///
			sheet(Sheet`i') cellrange(A1:A1) clear 
			local COMPANY = A[1]    					// local macro with company name

* Get data from the beginning of A3

			import excel using Sheet`i'`TYPE'.xlsx, ///
			sheet(Sheet`i')  cellrange(A3) firstrow case(lower) clear
			
			if missing(last_price[_n]) { 				// do not import if N/A N/A in first line (then there is a missing value in last price column)
			}
	
			else {
	
* Add Company Name (main identifier)

				generate company = "`COMPANY'"
				generate id = `i'-1 

* Adjustments for rounding, deleting missing Bloomberg data and adjusting Var name*/

				replace date = round(date,1000) 			// round data (bc Stata <-> excel mismatch)
				recast double open high low last_price value
				recast long number_ticks volume
				recast str15 company
	
* Rename vars

				rename id ID
				rename company Company
				rename date DateTime
				rename open Open
				rename high High
				rename low Low
				rename last_price LastPrice
				rename number_ticks NumberTicks
				rename volume Volume
				rename value Value
				foreach var of varlist Open High Low LastPrice NumberTicks Volume Value {
					rename `var' `var'`TYPE'
				}

// Append and save data

				if `i'== `=scalar(MAXLOOP)' {
					qui cd "${STANDARD_FOLDER}\3_Datasets"
					save Swiss`TYPE'`PART', replace
				}
				else {
					qui cd "${STANDARD_FOLDER}\3_Datasets"
					append using Swiss`TYPE'`PART'.dta
					save Swiss`TYPE'`PART', replace
				}
			}
	}

		order ID Company
		sort ID DateTime

		qui cd "${STANDARD_FOLDER}\3_Datasets"
		save Swiss`TYPE'`PART', replace

			
	}
}

************************************************
***** Merge Part Files into One File Each ******
************************************************

foreach TYPE in Trade Bid Ask {
	
	qui cd "${STANDARD_FOLDER}\3_Datasets"
	use "Swiss`TYPE'Part1"
	forvalues j = 2/3 {
	
		append using Swiss`TYPE'Part`j'.dta
		sort ID DateTime
		save `TYPE'All, replace
		
	}

	sort ID DateTime
	quietly by ID DateTime: gen dup = cond(_N==1,0,_n)
	tabulate dup
	drop if dup == 2 					// Remove duplicate dates. Duplicates occur since the data was downloaded in three parts with overlapping date intervals (to ensure completeness of the data)
	drop dup	
	
	
	save `TYPE'All, replace

}
foreach TYPE in Trade Bid Ask {
	forvalues j = 1/3 {
		erase Swiss`TYPE'Part`j'.dta
	}
}
***********************************************
************* Clean DataSet Pre Merge *********
***********************************************

cd "${STANDARD_FOLDER}\3_Datasets"

* Various Adjustments
* Here: For 04aug2014 there is one second added too much in excel --> therefore remove this second

foreach DATASET in Trade Bid Ask {

	use `DATASET'All.dta
	
	gen second = ss(DateTime)
	noisily replace DateTime = DateTime - 1000 if second > 0 // for August 4th in bid and ask, seconds are too high (by 1000)
	sort ID DateTime
	by ID DateTime: gen dup = cond(_N==1,0,_n)
	noisily tabulate dup
	drop second dup

* 0 prices or volume are irrelevant or wrong --> drop them
	drop if LastPrice`DATASET' 	== 0
	drop if Volume`DATASET' 	== 0

*Delete useless variables
	drop High`DATASET'
	drop Low`DATASET'
	drop Open`DATASET'

*Rename and make indicator variable to determine whether data was in original data set

	gen Active`DATASET' = 1

*Define all date/time variables needed for the analysis

	generate Date = dofc(DateTime)
	format Date %td 																// Real Date variable

	gen time = hh(DateTime) + mm(DateTime)/60 + ss(DateTime)/3600 					// Time variable

	qui count if ID > 241															// Verify that only 241 SSIP tickers were downloaded.
	assert r(N) == 0 														

	scalar TIMESTART = 9 + 0.1/60 													// i.e. everything deleted before 9.01
	scalar TIMEEND = 17 + 31/60 													// i.e. everything deleted after 17.30

	drop if time < TIMESTART | time > TIMEEND
	
	sort ID DateTime
	save `DATASET'AllManip.dta, replace


}
	erase BidAll.dta
	erase AskAll.dta

***********************************************
************* TSFill for Trade-Dataset ********
***********************************************

use TradeAllManip.dta, replace

* Set to panel data set and fill in gaps

xtset ID DateTime, delta(1 min)
tsfill, full

* Calculate Time & Date Variables for filled data

replace Date = dofc(DateTime)										// Date variable
format Date %td 													// Date variable
replace time = hh(DateTime) + mm(DateTime)/60 + ss(DateTime)/3600 	// Time variable

* Add TradingDays Variable for deletion of irrelevant days

merge m:1 Date using "${STANDARD_FOLDER}\1_Sources\Other\\`TRADING_FILE'", assert(match)
drop if _merge == 2
drop _merge

sort ID DateTime

* Drop if outside trading days or outside trading hours (before 9am [i.e. start with 9.01] or after 5.30pm [i.e. end with 17.31])

drop if tradingdays == 0
drop tradingdays
drop if time < TIMESTART | time > TIMEEND							// Have to do it here  again, because of tsfill
drop time

replace ActiveTrade = 0 if missing(ActiveTrade)

xtset ID DateTime, delta(1 min)

************************************************
******* Merge Ask, Bid and Trades Files ********
************************************************

* Merge files into filled trade dataset

merge 1:1 ID DateTime using BidAllManip.dta, assert(match master)
	gen merge1 = _merge
	drop _merge
	sort ID DateTime

merge 1:1 ID DateTime using AskAllManip.dta, assert(match master)
	gen merge2 = _merge
	drop _merge
	sort ID DateTime


* Prepare everything or variable creation; drop merge variables and set data set correctly
sum merge1, detail
sum merge2, detail
drop merge1
drop merge2

xtset ID DateTime, delta(1 min) 			//reset to balanced panel

* Label variables in data set

label var ID 				"Unique company identifier (xtset)"
label var Company 			"Company name"
label var DateTime 			"Date&Time for obs (xtset)"
label var LastPriceTrade 	"Last Trading Price in this minute"
label var NumberTicksTrade 	"Ticks traded in this minute"
label var VolumeTrade 		"Volume traded in this minute"
label var ValueTrade 		"Value traded (lastPrice*volume)"
label var ActiveTrade 		"non-missing trading obs"
label var Date 				"Date without time"
label var LastPriceAsk 		"Last Ask Price in this minute"
label var NumberTicksAsk 	"Ask Ticks in this minute"
label var VolumeAsk 		"Ask volume in this minute"
label var ValueAsk 			"Ask Value (lastPrice*volume)"
label var ActiveAsk 		"non-missing Ask obs"
label var LastPriceBid 		"Last Bid Price in this minute"
label var NumberTicksBid 	"Bid Ticks in this minute"
label var VolumeBid 		"Bid volume in this minute"
label var ValueBid 			"Bid Value (lastPrice*volume)"
label var ActiveBid 		"non-missing Bid obs"

order ID Company DateTime Date
sort ID DateTime

save FullMerge, replace

cd "${STANDARD_FOLDER}\3_Datasets"
	
erase TradeAllManip.dta
erase BidAllManip.dta
erase AskAllManip.dta
	
*********************************************************************
*********************************************************************
**************II. Import Daily Market Value Data ********************
*********************************************************************
*********************************************************************

tempfile AllNo

local ATTACHMENT = "AllNo" // This refers to the Bloomberg download options. "No" was selected for all options.
local SAVENAME "`AllNo'"

cd "${STANDARD_FOLDER}\1_Sources\Other-Bloomberg"
qui import excel  `MV_FILE', describe

forvalues i=`r(N_worksheet)'(-1)2 {
	cd "${STANDARD_FOLDER}\1_Sources\Other-Bloomberg"

*Capture the company name from cell A1

	import excel using `MV_FILE', sheet(Sheet`i') ///
	cellrange(A1:A1) clear 
	local COMPANY = A[1]   					 		// local macro with company name

*Get data from the beginning of A2

	import excel using `MV_FILE', sheet(Sheet`i') ///
		cellrange(A2) firstrow case(lower) clear

	if missing(cur_mkt_cap) { 				// do not import if N/A N/A in first line
	
	}

	else {
		rename date Date
		generate Company = "`COMPANY'"
		recast str15 Company
		generate id = `i'-1
	
		rename cur_mkt_cap MVCBloom`ATTACHMENT'
		rename eqy_sh_out NoShares`ATTACHMENT'
		rename current_market_cap_share_class MVBloom`ATTACHMENT'
		rename bs_sh_out EndNoShares`ATTACHMENT'
	
		tostring MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT', replace force
	
		foreach var of varlist MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT' {
			replace `var' = "" if `var' == "#N/A N/A"
		}

		destring MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT', replace
		recast double MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT'

		if `i'== 274 { 						// 274, because firm 275 is missing (download was made also for non-SSIP firms; hence n > 241)
			cd "${STANDARD_FOLDER}\3_Datasets"
			save `SAVENAME', replace

		}

		else {
			cd "${STANDARD_FOLDER}\3_Datasets"
			append using `SAVENAME'
			save `SAVENAME', replace
		}
	}
}

order id Company
sort id Date

replace Company = "HOLN VX Equity" if Company == "LHN VX Equity" 	// because of Ticker change from HOLN to LHN. To match with older dataset, ticker needs to be updated
replace Company = "KABN SE Equity" if Company == "DOKA SW Equity" 	// because of Ticker change from KABN to DOKA. To match with older dataset, ticker needs to be updated

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE_MV_DAILY', replace

*********************************************************************
*********************************************************************
************ III. Create Main Dataset for 10_Merge  *****************
*********************************************************************
*********************************************************************


********************************************
*********** Generate Key Variables *********
********************************************
cd "${STANDARD_FOLDER}\3_Datasets"
use FullMerge, replace 													// starts with balanced panel

* Merge with daily market values
merge m:1 Company Date using "`SAVEFILE_MV_DAILY'", keepusing(MVBloomAllNo) assert(match master using) // Market values are only needed for the weighted effective spreads calculation
drop if _merge == 2
drop _merge
compress

* Generate time-related variables
drop time
gen Hour 	= hh(DateTime)
gen Minute 	= mm(DateTime)
gen Weekday = dow(Date)
gen Week 	= week(Date)
gen HourMin = Hour*100+Min

drop if Hour == 17 & Minute == 31								// This is done to obtain 510 observations before collapse (i.e., can be divided by 30)

preserve
	keep if ID == 1
	bys Date: count
	assert `r(N)' == 510
restore

* Generate 30 minutes intraday time period (MINUTESGROUP=30)
sort ID DateTime

scalar MINUTESGROUP = 30 										// Here define how many values should be grouped together for the intraday analyses. 30min == 30

count if ID == 1 												// Assumption, all IDs have same length _N, i.e. balanced panel; asserted above
scalar MAX = r(N)/MINUTESGROUP 									// Assumption, all IDs have same length _N, i.e. balanced panel; asserted above

* Routine to verify that MAX is an integer
assert mod(`=scalar(MAX)',1) == 0

sort ID DateTime
by ID: gen number = _n - 1  + MINUTESGROUP 						// i.e. first observation equals scalar MINUTESGROUP
by ID: gen indicator = int(number/MINUTESGROUP) 				// i.e. divide by MINUTESGROUP and take integer
drop number

* Drop opening and closing auction
drop if Hour == 17 	& Minute >= 20								// Closing auction starts at 17.20								
drop if Hour == 9	& Minute <= 2								// Opening auction ends at 09.02 at the latest


********************************************
*********** Fill-up variables **************
********************************************

sort ID DateTime
foreach x of varlist Company {
	by ID: replace `x' = `x'[_n-1] 		if missing(`x')
}

gsort +ID -DateTime
foreach x of varlist Company {
	by ID: replace `x' = `x'[_n-1] 		if missing(`x')
}

* Calculate Staleness of Bid-Ask Spread for untabulated robustness test (Part 1)

gen SameAsk = missing(LastPriceAsk)
gen SameBid = missing(LastPriceBid)

sort ID DateTime
sort ID Date HourMin
by ID Date: replace SameAsk = SameAsk[_n-1] + 1 if missing(LastPriceAsk)
by ID Date: replace SameBid = SameBid[_n-1] + 1 if missing(LastPriceBid)
gen RelativeStale = abs(SameAsk - SameBid)

*Like McInish carry quotes forward within a day, but not across dates

sort ID DateTime
sort ID Date HourMin
foreach x of varlist LastPrice* {
	by ID Date: replace `x' = `x'[_n-1] if missing(`x') 		// Assumption: lastPrice is still lastPrice on the very same day (i.e. intraday)
}

* replace missing volumes by 0
foreach y of varlist Active* NumberTicks* Volume* Value*{
	replace `y' = 0 if missing(`y')
}

*Generate dummy variable as Post indicator
generate AfterSNB = cond(DateTime>tc(15-jan-2015 10:30),1,0)

****************************************************
*********** Calculate Bid-Ask Spreads **************
****************************************************

* Calculate minute-by-minute spreads
gen BidAskSpreadMinute = (LastPriceAsk-LastPriceBid)/(LastPriceAsk+LastPriceBid)*200 if (LastPriceAsk-LastPriceBid) >= 0 // * 100 for readability in descriptive table

* Calculate minute-by-minute effective spreads
gen Midpoint 			= (LastPriceAsk+LastPriceBid)/2

gen EffSpread_No_W 		= abs(LastPriceTrade - Midpoint)*2 if NumberTicksTrade > 0
gen EffSpread_W_M		= abs(LastPriceTrade - Midpoint)*2*(ValueTrade/MVBloomAllNo) if NumberTicksTrade > 0

drop MVBloomAllNo

sort ID Date HourMin

*Calculate spreads in 30 min intervals (for intraday analysis)
sort ID indicator
by ID: assert DateTime[_n] > DateTime[_n-1] if _n > 1 // Assert that sorting is correct

by ID indicator: egen MeanTimeBidAskSpread = mean(BidAskSpreadMinute) 

*Calculate daily spreads (for daily analyses)
sort ID Date HourMin
by ID Date: egen MeanDateBidAskSpread = mean(BidAskSpreadMinute)
by ID Date: egen MeanDateEffSpread_No_W = mean(EffSpread_No_W)
by ID Date: egen MeanDateEffSpread_W_M 	= mean(EffSpread_W_M)

* Calculate Staleness of bid-ask spread (Part 2)--> Create Staleness indicator for untabulated robustness test
sort ID Date HourMin
by ID Date: egen MeanRelativeStale 	= mean(RelativeStale)


drop BidAskSpreadMinute EffSpread_No_W EffSpread_W_M

* Aggregate Trading Volumes within each 30 minute interval
sort ID Date HourMin
sort ID indicator
by ID: assert DateTime[_n] > DateTime[_n-1] if _n > 1 // Assert that sorting is correct

foreach x of varlist Value* Volume* NumberTicks* Active* {
	by ID indicator: replace `x' = sum(`x') 			
}

* Only keep the last observation for each 30 minute interval
by ID indicator: keep if _n ==_N

drop indicator

xtset ID DateTime

************************************************************
*** Remove firms that are duplicates or too illiquid *******
************************************************************

sort ID DateTime

drop if Date<td(01oct2014)
drop if Date>td(30apr2015)

*Drop duplicate firms

drop if Company == "SCHN SE Equity" 				// ID = 181 SCHN SE (because duplicate with ID 182 SCHP VX and less liquid stock)
drop if Company == "UHRN SE Equity" 				// ID = 219 UHRN SE (because duplicate with ID 218 UHR VX and less liquid stock)
drop if Company == "LISN SE Equity" 				// ID = 125 LISN SE (because duplicate with ID 126 LISP SE and less liquid stock)
drop if Company == "RO SE Equity" 					// ID = 175 RO SE (because duplicate with ID 176 ROG VX and less liquid stock)

*Table 1 Line 1: Initial Sample
preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 237
restore

* Verify that data is a valid&balanced panel
sort ID Date
xtdescribe
assert `r(min)' == `r(max)' 											// Same number of observations

*Delete observations with insufficient number of trades
distinct Date
scalar NumberDay = `r(ndistinct)'

bys ID: egen TRADES = sum(NumberTicksTrade) 
keep if TRADES 		> scalar(NumberDay)*10								// Requirement: At least 10 trades per Day

*Table 1 Line 2: Removed 63 firms due to insufficient trades

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 174
restore

distinct HourMin
scalar TimeSlots = `r(ndistinct)'

*Delete observations with too few updated bid-ask-spreads

gen missingBS = missing(MeanDateBidAskSpread)				
bys ID: egen FirmMissingBS = sum(missingBS)
drop if FirmMissingBS > scalar(TimeSlots)*3							// Requirement: Updated BidAskSpread on 141 of 144 days (i.e., drop if at least 3 missings)

drop TRADES FirmMissingBS FirmMissingBS

*Table 1 Line 3: Removed 15 firms due to insufficient bid-ask spreads

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 159
restore

************************************************
*********** Carry-forward Prices  **************
************************************************

sort ID DateTime
foreach x of varlist LastPriceTrade { 								// Carry Trade-Prices (but not bid or ask prices) over night
	by ID: replace `x' = `x'[_n-1] if missing(`x')
}


************************************************
*********** Save File for 10_Merge  ************
************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE_BLOOM_MERGE', replace

*********************************************************************
*********************************************************************
************ IV. Create Other Datasets for 10_Merge  ****************
*********************************************************************
*********************************************************************

********************************************
* Generate End-of-Day Prices for each Date *
********************************************

use TradeAll.dta, replace // For end-of-day prices, the last valid price is needed (i.e., including closing auction if applicable)

gen Hour 	= hh(DateTime)
gen Minute 	= mm(DateTime)

gen HourMin = Hour*100+Min
gen Date 	= dofc(DateTime)
format %td Date

sort ID Date DateTime
count if missing(LastPriceTrade)
	assert `r(N)' == 0 // Ensures that last value on a day is not missing

by ID Date: keep if _n == _N // keep last price per day

drop DateTime

xtset ID Date, delta(1 day)
	tsfill, full

by ID: replace LastPriceTrade = LastPriceTrade[_n-1] if missing(LastPriceTrade) // because of tsfill
by ID: gen BeforePXLast = LastPriceTrade[_n-1] // carry forward prices if no share price at a given day (only relevant for the first day of the panel)

keep ID Date LastPriceTrade BeforePXLast

rename LastPriceTrade PXLast // Price at the end of the day for each day

save `SAVEFILE_PX_LAST', replace
erase TradeAll.dta

******************************************************
******* Generate Rolling Return Volatility for *******
****************** Intrady Analyses ******************
******************************************************
cd "${STANDARD_FOLDER}\3_Datasets"
										
use `SAVEFILE_BLOOM_MERGE', replace											// starts with balanced panel
sort ID DateTime 

* Conduct consistency checks

qui xtset ID DateTime
xtdescribe

assert `r(N)' == 159													// Sample is correct, final sample is 151 observations; but here 159 because based on  BloombergMerge file (and not after further sample filters in 10_Merge_Datafiles)
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum Date, detail
local MINDATE = `r(min)'

qui sum ID, detail
local MINID =`r(min)'

count if Date == `MINDATE' & ID == `MINID'

scalar INTRADAYOBS = `r(N)'												// Set number of Intraday observations for changes

assert scalar(INTRADAYOBS) == 17										


sum ID if HourMin <= 1030 & Date == `MINDATE' & ID == `MINID', detail
assert `r(N)' == 3
global UNTIL1030 = `r(N)'

keep ID DateTime LastPriceTrade

*Generate Logarithmic Returns
sort ID DateTime 
by ID: 	gen LogReturn = log(LastPriceTrade/LastPriceTrade[_n-1])		 
	replace LogReturn 	= 0 if missing(LogReturn)						//  Only needs to be replaced for Oct 1 (actually irrelevant since not part of the estimation window)

* Generate Rolling SD
sort ID DateTime
by ID: gen CONT = _n
xtset ID CONT 			// necessary for rollstat command
rollstat LogReturn, statistic(sd) w(`=scalar(INTRADAYOBS)')
drop CONT

xtset ID DateTime
sort ID DateTime
by ID: gen SDRolling= _sd17_LogReturn


drop _sd17_LogReturn

cd "${STANDARD_FOLDER}\3_Datasets"

save `ROLLINGVOL', replace
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Hand-Collected data based on firms' annual report 2013 (Downloaded reports in April and May 2015):
/*Excel file that contains the hand collected data based on firms most recent annual report before Jan 15, 2015.
This Excel file contains three main variables that were manually collected and coded:  Risk Disclosure (Score from 1 to 7),  IntSales (from 0 to 1) and ReportLength (# Pages). 
It also contains the sub-scores of the Risk Disclosure score (for IA Table A3) */

local REPORT_HAND_COLLECTED = "HandCollected_Report_Data.xlsx"

*** OUTPUT:

local SAVEFILE1 = "ReportData.dta"

***********************************************
************* Import Excel File ***************
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel `REPORT_HAND_COLLECTED', sheet("Data") cellrange(A2:AT244) firstrow

rename BloombergCode Company
keep if Include == 1 // Variable that shows whether the firm is in the final sample or not (drop step is not necessary, but allows to use perfect match assert command in 10_Merge file)
destring IntSales, replace

keep Company RiskDisclosure Revenues2013 Assets2013 CostsProfits2013 Monetary2013 FXExposure2013 Hedging2013 FXSensitivity2013 IntSales ReportLength

drop if missing(Company)

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace


exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}


***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

*** INPUT:

*1. Datastream/Worldscope File (Various download dates depending on variables, see Datasheet):
/*File that contains the Datastream & Worldscope data via the Datastream Request Table in Excel. 
Each Variable is contained in a separate worksheet.  */

local DS_WORLDSCOPE = "SwissFrancRequestTable_DS.xlsx"


*2. Swiss Disclosure Ranking 2014 from the Swiss Finance Institute (i.e., scoring for 2013 annual reports) (Downloaded on June 22, 2015):
/*Ranking from https://www.bf.uzh.ch/en/research/studies/value-reporting.html. Names are manually matched to Bloomberg Codes. 
Additionally, the Datastream and IBES identifiers are also manually matched to these firms and added to this file (i.e., also functions
as a linking table between Bloomberg and Datastream)   */

local DISC_RANKING = "Ranking_DS_Bloomberg_Match_Data.xlsx"

*3. IBES Weekly Coverage Data (Downloaded on August 20, 2015):
/*Weekly IBES data, which is used to compute analyst following. Data was downloaded via Thomson Reuters Spreadsheet Link 
and hence the downloaded data is contained in an excel file.*/

local IBES_SPREADSHEET = "IBES_Swiss_Weekly_IBES_COPY.xlsx"

*4. Datastream Download of Exchange Rates and Total Return Index (Downloaded on June 8, 2017):
/*Downloaded via Datastream Request Table in Excel. Used to calculate correlations between stock returns and changes in foreign exchange rates.*/

local DS_FX_TRI = "FX-TRI-Datastream.xlsx"

	
*** OUTPUT:

local SAVEFILE = "Datastream_IBES_Final.dta"

***********************************************
***** Import non-market variables from DS *****
***********************************************

tempfile SwissDatastream

cd "${STANDARD_FOLDER}\1_Sources\Datastream"

* Import Excel File with data
qui import excel using `DS_WORLDSCOPE', describe
scalar MAXLOOP = `r(N_worksheet)'-1 // Adjustment -1 because of RequestTable

forvalues i=`=scalar(MAXLOOP)'(-1)1 {
	if `i' == 1 {
	
		cd "${STANDARD_FOLDER}\1_Sources\Datastream"
		
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i')  cellrange(A1) firstrow allstring case(lower) clear
		
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
		}
		
		gen idx = _n 										// idx_is internal merge code
		
	}	
	else {
	
		cd "${STANDARD_FOLDER}\1_Sources\Datastream"
	
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i') cellrange(A5:A5) clear
		local TEMPORARY = A[1]
		local ADD = lower(strtoname(substr("`TEMPORARY'",11,27)))
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i')  cellrange(B4) allstring firstrow case(lower) clear
		
		* Extract names and label
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
			destring `var', replace float
			local label : variable label `var'
			local new_name = lower("`label'")
			rename `var' `ADD'`new_name'
		}
		
		gen idx = _n 										// idx_is internal merge code
		reshape long "`ADD'", i(idx) j(year)
	}
	if `i'== `=scalar(MAXLOOP)' {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		save `SwissDatastream', replace
		
  }
	else if `i' == 1 {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:m idx using `SwissDatastream', assert(match)
		drop _merge
  }
	else {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:1 idx year using `SwissDatastream', assert(match)
	
		drop _merge
		
		save `SwissDatastream', replace
  }
}

order dscd idx name year
drop if missing(dscd)
rename dscd Type

* Save Datastream & Worldscope
cd "${STANDARD_FOLDER}\3_Datasets"
save `SwissDatastream', replace

*******************************************************
**** Historical Correlations Swiss-EUR and Swiss-USD **
*******************************************************

tempfile HistCorr

cd "${STANDARD_FOLDER}\1_Sources\Datastream"

* Import exchange rate from excel worksheet
import excel `DS_FX_TRI', sheet("Sheet2") cellrange(A2:C2613) firstrow clear

save `HistCorr'.dta, replace

* Import firms' total return indices from same excel worksheet
import excel `DS_FX_TRI', sheet("Sheet1") firstrow clear
drop if _n == 1
foreach var of varlist _all {
	replace `var' = "" if `var'== "NA"
	destring `var', replace
	}
	
generate Code = date(Name, "MDY")
drop Name
format Code %td
order Code

cd "${STANDARD_FOLDER}\3_Datasets"

* Merge both files (TRI and exchange rates)
merge 1:1 Code using `HistCorr'.dta
drop _merge
order Code SWEURSPER SWISSFER 
rename Code Date

* Calculate correlations on a weekly basis (weekly instead of daily correlations) to reduce the liquidity impact
gen DateWeek = wofd(Date)
sort DateWeek Date			
order DateWeek, after(Date)
format DateWeek %tw

foreach var of varlist SWISSFER SWEURSPER ABBLTDN-ZWAHLENMAYR  {
	by DateWeek: gen B_`var' = `var'[1]
	by DateWeek: gen E_`var' = `var'[_N]

}

by DateWeek: keep if _n == 1

* Calculate weekly changes of exchange rates and return indices
foreach var of varlist SWEURSPER SWISSFER ABBLTDN-ZWAHLENMAYR {
	gen ret_`var' = log(E_`var'/B_`var')
	}

* Calculate correlations for EUR before minimum exchange rate regime and USD during minimum exchange rate regime
local i = 0
foreach var of varlist ret_ABBLTDN-ret_ZWAHLENMAYR {
	local i = `i' + 1

* Calculate USD and firms' return correlation
	qui sum `var' if Date<td(15jan2015) & Date >= td(15jan2012), detail // Covering Period during Minimum Exchange Rate Regime
	
	if r(N) == 0 {	
		scalar USD_`i' = .
	}
	
	else {
		qui corr ret_SWISSFER `var' if Date<td(15jan2015) & Date >= td(15jan2012) // Covering Period during Minimum Exchange Rate Regime
		scalar USD_`i' = r(rho)
	}

* Calculate EUR and firms' return correlation
	qui sum `var' if Date<td(6sep2011) & Date >= td(6sep2008), detail // Covering Period before Minimum Exchange Rate Regime
	
	if r(N) == 0 {		
		scalar EUR_`i' = .
	}
	
	else {
		qui corr ret_SWEURSPER `var' if Date<td(6sep2011) & Date >= td(6sep2008) // Covering Period before Minimum Exchange Rate Regime
		scalar EUR_`i' = r(rho)
	}
}
qui d
global OBS = (r(k) - 2)/4  - 2 
assert ${OBS} == 241

* Generate dataset that contains both correlations
clear
set obs 241
generate idx = _n
generate HistCorrEUR = 0
generate HistCorrUSD = 0


foreach x of numlist 1/241 {
	replace HistCorrEUR = EUR_`x' if _n == `x'
	replace HistCorrUSD = USD_`x' if _n == `x'

}

save `HistCorr', replace

*******************************************************
************** Import Ranking File ********************
**** (also contains the manually linked Bloomberg *****
*********** & Datastream Identifiers) *****************
*******************************************************

tempfile temporary

cd "${STANDARD_FOLDER}\1_Sources\Other"

* Import excel file
import excel using `DISC_RANKING', sheet(Matched)  cellrange(A2) firstrow case(lower) clear

keep type bloombergcode tonecodeshort gesamtnote
drop if missing(type)

* Rename variables
rename bloombergcode Company
rename gesamtnote DisclosureRank
rename tonecodeshort IBESMatchCode
rename type Type

cd "${STANDARD_FOLDER}\3_Datasets"
save `temporary', replace

* Merge Files
use `SwissDatastream', replace
merge m:1 Type using `temporary', assert(match)
drop _merge

merge m:1 idx using `HistCorr', assert(match)
drop _merge

sort idx year
save `SwissDatastream', replace

***************************************************
******** Clean Dataset and Rename Variables *******
***************************************************

tempfile TempDatastream

* Rename and prepare variables
rename idx IDX // IDX is not ID (which is part of the Bloomberg Dataset)
rename name DatastreamName
rename year Year
format Year %ty // change format for Panel Dataset
rename mnem Mnem
rename acur AccountingCurrency
rename wc07021 SICCode
rename isocur	ISOCurrStock
rename isin ISIN
drop ggisn
rename pcur PriceCurrency
rename wc05427 StockExchanges
rename international_sales InternationalSales
rename net_sales_or_revenues TotalSales
rename date_of_fiscal_year_end FYEnd
rename accounting_standards_follow AccountingStandards
rename __free_float_nosh NoshFF

foreach x of varlist Mnem-StockExchanges {
	replace `x' ="" if inlist(`x',"NA") // Create missing values
}

xtset IDX Year, delta(1 year)

save `SwissDatastream', replace

*Generate relevant variables
generate SIC1 = substr(SICCode,1,1)
destring SIC1, replace
generate IFRS = strpos(AccountingStandards, "IFRS") >= 1
generate USGAAP = strpos(AccountingStandards, "GAAP") >= 1
generate LocalStandards = strpos(AccountingStandards, "Local") >= 1
gen InternationalStandards = USGAAP == 1 | IFRS == 1
replace NoshFF = NoshFF/100 // (Makes variable more readable in tables)

*Replace NoshFF for a single firm. For this firm, NOSH data is only missing in this year. Thus use the 2014 data in the 2013 field for this firm
replace NoshFF = NoshFF[_n+1] if Type == "92219M" & Year == 2013

* Use data from fiscal year which is closest to Swiss Franc Shock (but precedes the Swiss Franc Shock)
gen FYE = date(FYEnd, "MDY")
drop FYEnd
rename FYE FYEnd
format FYEnd %td

keep if Year == 2013 | Year == 2014
gen MONTH = month(FYEnd)

drop if MONTH < 12 & Year == 2013
drop if MONTH == 12 & Year == 2014 

sort IDX Year
by IDX:  drop if _n == 2 // Drop year 2014 --> Yields same number of obs (no duplicates) as just drop Year 2013

save `TempDatastream', replace

********************************************
************* Import from IBES *************
********************************************

tempfile SwissIBESToMerge SwissTempIBES

* Import IBES File
cd "${STANDARD_FOLDER}\1_Sources\IBES"
qui import excel using `IBES_SPREADSHEET', describe

return list
forvalues i = 2/`r(N_worksheet)' { 
	cd "${STANDARD_FOLDER}\1_Sources\IBES"
	if `i' == 2 {

		import excel using `IBES_SPREADSHEET', sheet(`r(worksheet_`i')') cellrange(A1) allstring firstrow case(lower)  clear
		
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
		}
		
		gen idx = _n 										// idx_is internal merge code
		keep idx name tickerfordownload matchingwtr
		order idx name tickerfordownload matchingwtr
		
	}	
	
	else  {
		import excel using `IBES_SPREADSHEET', describe
		local TEMPORARY = r(worksheet_`i')
		import excel using `IBES_SPREADSHEET', sheet(`r(worksheet_`i')')  cellrange(C2)  clear
		scalar COUNTER = td(3-jan-2014) -7 										// Start Date is 3-jan-2014 according to TSL
		
		foreach var of varlist _all {
			scalar COUNTER = COUNTER + 7 										// 20091 is star
			rename `var' `TEMPORARY'`=scalar(COUNTER)'
		}
		
		gen idx = _n // idx_is internal merge code
		reshape long "`r(worksheet_`i')'", i(idx) j(week)
	}
	
	if `i'== 2 {
		cd "${STANDARD_FOLDER}\3_Datasets"
		save `SwissTempIBES', replace
	}
	
	else if `i'== 3 {
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge m:1 idx using `SwissTempIBES', assert(match)
		drop _merge
		save `SwissTempIBES', replace
	}
	
	else {
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:1 idx week using `SwissTempIBES', assert(match) // now 1:1 because of reshape
		drop _merge
		save `SwissTempIBES', replace
	}
}

format week %tdMonth_DD,_CCYY

foreach var of varlist EPSCurrencyFY2-NumberOfAnalystsFY1 {
	replace `var' = "" if `var' == "N/A"
	}

* Generate Number of analysts variable
destring NumberOfAnalystsFY1, replace
replace NumberOfAnalystsFY1 = 0 		if NumberOfAnalystsFY1 == . 				// Continuous Analyst Coverage Var
rename NumberOfAnalystsFY1 NumberOfAnalysts

cd "${STANDARD_FOLDER}\3_Datasets"

* Prepare data file for matching
order matchingwtr name
rename matchingwtr IBESMatchCode

	
save SwissTempIBES, replace

* Only keep one weekly observation
by idx: keep if _n == 54 		// this is the last observation (week) just before SNB Shock
drop idx week 					// no longer needed
	
save `SwissIBESToMerge', replace

*************************************
***** Merge IBES and Datastream *****
*************************************

use `TempDatastream', replace
	
merge 1:1 IBESMatchCode using `SwissIBESToMerge'			
	tab _merge
	keep if _merge == 3 					
	drop _merge
	
save `SAVEFILE', replace


exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Excel-File that contains Swiss ADRs (Downloaded and created in August, 2019):
/*List of Swiss Cross-Listing via Archive.org copy (December 25, 2014) of TopForeignStocks.pdf (cross-verified with adrbnymellon.com).
This list was copied in ab excel file and the ticker symbols were matched to Datastream's Type identifier (manually verified matches) */

local SWISS_ADR_EXCEL = "Swiss-ADRs.xlsx"

*2a. Excel-File that contains LinkedIn Data (Collected in September 2019):
/*Excel file that holds the manually collected LinkedIn data. Contains the numbers of hits of a LinkedIn search (i.e., number of employees) combining a certain firm name
 and an additional search query (e.g., job position that has ‘risk’ in the title). */

local LINKEDIN_DATA = "LinkedIn_DataCollection.xlsx"

*2b. Risk MGTMT Data from 2013 Annual Reports (Downloaded reports in April and May 2015):
/* Hand-Collected data from firms 2013 annual reports. Holds various variables (e.g., whether a firm has a Chief_Risk officer) related to risk management and hedging. */

local ADDITIONAL_REPORT_DATA = "Risk_Hedging_Report_DataCollection.xlsx"


*3a. IR Club indicator (Received in May 2016):
/*Excel-File that contains indicator variable whether a firm belongs to the IR Club (=1) or not (=0) 
(Information comes from our contact at the IR Club, variable is manually coded in Excel)*/

local IR_CLUB = "IRClub_Indicator"

*3b. IR Position (Collected in April and May 2016):
/*Manually collected excel file that contains, among other things, the job title of the most senior IR employee at the company. 
This data was originally collected for the investor relations survey from two main sources: firm webpages and SIX stock exchange web page.*/

local IR_POSITION = "Hand_SIX_Merge_Main_Sample"

*4a. For new information variables: IBES Detail Data (Downloaded on May 17, 2018):
/* Detailed Coverage IBES data (downloaded via WRDS at a later date compared to the Weekly Coverage Data). First IBES Codes were downloaded via Datastream (IBES-Ticker Excel file) 
and then the IBES Detail History Data for those firms was downloaded */

local IBES_CODES = "IBES_Ticker.xlsx"
local IBES_DETAIL_DATA = "Swiss_IBES_Detail_Data.dta"


*4b. For new information variables: Factiva Hand Collected File (Collected and coded from December 2019 until February 2020):
/* Excel file contains all articles that where found within the Factiva-SNB Research. Each worksheet within the excel file contains the data for one firm (each line is a different article).
Articles were read and relevant articles were coded as '1'. */
local FACTIVA_DATA = "Factiva_Hand_Collected_Files.xlsx"

*5.  SMI All Share Index and CHF-EUR Exchange Rate (Downloaded August 8, 2016): 
/* File for Figure 1 (via Datastream Download) that contains exchange rates and the Swiss All Share index  */

local ALL_SHARE_INDEX = "SMI-All-Share-CHF-EUR.xlsx"

*** OTHER INPUT FILES:
local DATASTREAM_IBES = "Datastream_IBES_Final.dta" // From 03_Import_DatastreamIBES.do
local ACTUAL_SAMPLE = "ActualSample151.dta" 		// To verify whether the sample is unchanged and OK (generated once based on the final sample)
local TRADING_FILE = "TradingDays.dta"				// Already referenced in 01_Import_Bloomberg 

*** OUTPUT:

local SAVEFILE1 = "SwissCrossListing.dta"

local SAVEFILE2 = "RiskHedgingData.dta"

local SAVEFILE3 = "IR_DataArchival.dta"

local SAVEFILE4 = "NewInformationData.dta"

local SAVEFILE5 = "SMI_AllShare_CHF_EUR.dta"

***********************************************
***********************************************
************ Import Excel Files **************
***********************************************
***********************************************

***********************************************
********* 1. Import Cross-Listings ************
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel `SWISS_ADR_EXCEL', firstrow clear
keep Type CrossListingType // Three types: 'Real':  U.S. exchange cross-listing, 'S': Sponsored ADR, 'U': Unsponsored ADR
drop if missing(Type) 

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace


***********************************************
******* 2. Import Risk MGTM, Hedging, *********
*********** Direct Communication **************
***********************************************

*** Import LinkedIn File

tempfile LINKEDIN REPORT

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel using `LINKEDIN_DATA', firstrow clear

destring investor_position, replace

keep Type NAME Inc_Linkedin-Other_comment2
drop if missing(Type) 			// Just one Empty Row


gen LogRiskLinkedin 		= log(1 + risk_position) if !missing(risk_position) 			// risk_position: Number of employees whose current job position has ‘risk’ in the title
gen LogHedgeKeyLinkedin  	= log(1 + hedging_keyword) if !missing(hedging_keyword) 		// hedging_keyword: Number of employees whose current job profile contains the term ‘hedging'
gen Log_IR_Linkedin 		= log(1 + investor_position) if !missing(investor_position)		// investor_position: Number of employees whose current job position has ‘IR’ or ‘investor relations’ in the title

save `LINKEDIN', replace

*** Import Additional Report File

import excel using `ADDITIONAL_REPORT_DATA', firstrow clear
drop if missing(Type) 

keep Type RiskCommitteeYesNo ChiefRiskYesNo RiskManagementenglishgerman Hedging NaturalOperationalHedge EconomicHedgeeconomicallyhe

* Generate Report-based variables
rename RiskManagementenglishgerman NumberofRiskManagement // Counts of how often Risk Management is mentioned in report

foreach VAR of varlist NaturalOperationalHedge EconomicHedgeeconomicallyhe {
	replace `VAR' = 0 if missing(`VAR' )
}

gen Sum_Hedge = (NaturalOperationalHedge + EconomicHedgeeconomicallyhe) // Add up how often 'natural hedging' or 'economic hedging' is mentioned in report.
gen  EconHedgeYesNo = Sum_Hedge > 0 if !missing(Sum_Hedge)			 	// Create Dummy Variable with 1: at least once mentioned, 0: Not mentioned at all.
drop Sum_Hedge EconomicHedgeeconomicallyhe NaturalOperationalHedge

gen RiskCommittee = 1 if RiskCommitteeYesNo == "Yes"
replace RiskCommittee = 0 if RiskCommitteeYesNo == "No"

gen ChiefRisk = 1 if ChiefRiskYesNo == "Yes"
replace ChiefRisk = 0 if ChiefRiskYesNo == "No"

drop RiskCommitteeYesNo ChiefRiskYesNo


save `REPORT', replace

* Merge LinkedIn and Report files
use `LINKEDIN', replace

merge 1:1 Type using `REPORT', assert(match) nogenerate

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE2', replace

***********************************************
************* 3. Import IR Data ***************
***********************************************

tempfile IRClub_Data

cd "${STANDARD_FOLDER}\1_Sources\Other"

* Import IR_Club variable
import excel using `IR_CLUB', firstrow clear

rename IRCLUB IR_Club

save `IRClub_Data', replace

* Import Lead_IR variable
import excel using `IR_POSITION', firstrow sheet("Overview") cellrange(A2) clear

tab Position
gen Lead_IR = (inlist(Position, "CCO", "CCO & IR", "Director IR", "Head of Financial Services", "Head of IR") | ///
				 inlist(Position, "Head of IR/CCO", "Leiterin Corporate Communications", "Senior IR", "VP IR")) if !missing(Position)

* Merge Files Together
merge 1:1 ID using `IRClub_Data'

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE3', replace

***********************************************
****** 4. Collect Post-Shock Info Data ********
***********************************************

***********************************************
***** 4a. Import Additional IBES Data *********
***********************************************

* Import IBES ticker
tempfile IBES_CODE_DTA IBES_FORECAST_DATA

cd "${STANDARD_FOLDER}\1_Sources\IBES"

import excel using "`IBES_CODES'", sheet(Sheet1) clear cellrange(A2) firstrow

rename IBTKR ticker // ticker is the IBES Code for the merge

cd "${STANDARD_FOLDER}\3_Datasets"

save `IBES_CODE_DTA', replace

* Import Detailed IBES data
cd "${STANDARD_FOLDER}\1_Sources\IBES"

use "`IBES_DETAIL_DATA'", replace

keep if measure == "EPS"

sort analys ticker anndats anntims

gen Hour = substr(anntims,1,2)
destring Hour, replace

gen Min = substr(anntims,4,2)
destring Min, replace

* Adjust for local Swiss time
gen ann_new = anndats
replace ann_new = anndats + 1 if (Hour >= 12 | (Hour == 11 & Min > 30)) // Adjust for local Swiss time (i.e.,  after 11.30 [5.30pm Swiss time] it only affects the next trading day)

sort analys ticker ann_new
*  Keep only one EPS Forecast per analyst covering a given firm per day
bys analys ticker ann_new: keep if _n == 1


format %td ann_new
drop if ann_new  < td(01dec2014)
drop if ann_new  > td(28feb2015)

count
* Collapse dataset to firm-day dataset
collapse (count) EPS_Revision = analys, by(ann_new ticker)

rename ann_new Date

cd "${STANDARD_FOLDER}\3_Datasets"

save `IBES_FORECAST_DATA', replace


***********************************************
********** 4b. Import Factiva Data ************
***********************************************

tempfile NEWS_SEARCH

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel using "`FACTIVA_DATA'", describe

forvalues i=1/`r(N_worksheet)' {
	local j = `j' + 1
    import excel using "`FACTIVA_DATA'", sheet(`"`r(worksheet_`i')'"') firstrow clear allstring
    save Save_Sheet`j', replace
    local z = `j'
}
use Save_Sheet1.dta
erase Save_Sheet1.dta

forvalues j=2/`z' {
	append using Save_Sheet`j'.dta
	erase Save_Sheet`j'.dta

}

drop if F == "Tensid" // This is a Newswire Service that was initially missed (and included in the Factiva search)

keep firm_name doc_date  Relevant A
destring A, replace
gen date2 = date(doc_date, "DMY")
drop doc_date
format date2 %td
rename date2 Date
rename firm_name Type

gen RelevantSNBArticle 	= 1 if Relevant == "1"

* Collapse dataset to firm-day dataset
collapse (sum) News_SNB = RelevantSNBArticle, by(Type Date)

cd "${STANDARD_FOLDER}\3_Datasets"

save `NEWS_SEARCH', replace


***********************************************
****** 4c. Combine IBES & Factiva Data ********
***********************************************
cd "${STANDARD_FOLDER}\3_Datasets"

*** Merge Files from 4a and 4b in a Panel Dataset together
use "`DATASTREAM_IBES'", replace

keep Company ID Type ISIN
duplicates drop // Only one observation per firm (i.e., 151 firms)

* Ensure that only the 151 final sample firms are in the sample
merge 1:1 Company using "${STANDARD_FOLDER}\1_Sources\Verification\\`ACTUAL_SAMPLE'", assert(match master)
keep if _merge == 3
drop _merge

merge 1:1 Type using `IBES_CODE_DTA',assert(match using)
drop if _merge == 2
drop _merge

cross using  "${STANDARD_FOLDER}\1_Sources\Other\\`TRADING_FILE'"
sort ID Date

merge 1:1 ticker Date using  `IBES_FORECAST_DATA', assert(match master using)
drop if _merge == 2 
drop _merge

merge 1:1 Type Date using `NEWS_SEARCH', assert(match master)
drop if _merge == 2
drop _merge

order ID Date
drop if Date  < td(12nov2014) // The data collection for Factiva only started from 10dec2014 (but not relevant for analyses)
drop if Date  > td(12feb2015)
sum tradingdays

*** Make two minor adjustments to hand-collected
replace News_SNB = 1 if Type == "929910" & Date == td(30jan2015) // Relevant Article for one firm on January 30, which was not part of the Imported Excel-File (those two were the only two relevant articles that were missed in the excel file))
replace News_SNB = 1 if Type == "929910" & Date == td(31jan2015) // Relevant Article for one firm on January 31,which was not part of the Imported Excel-File (those two were the only two relevant articles that were missed in the excel file)


*** Carry forward non-trading day observations to trading day observations
sort ID Date
foreach VAR of varlist News_SNB EPS_Revision   {
	replace `VAR' = 0 if missing(`VAR')
	by ID: replace `VAR' = `VAR' + `VAR'[_n-1] if tradingdays[_n-1] == 0
}
drop if tradingdays == 0

*** Generate TotalNewInfo Variable

gen TotalNewInfo = News_SNB + EPS_Revision

keep ID Company Date EPS_Revision News_SNB TotalNewInfo

save `SAVEFILE4', replace



***********************************************
******* 5. Import Swiss All Share Index *******
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Datastream\"

import excel `ALL_SHARE_INDEX', sheet("Sheet1") cellrange(A5:I1721) firstrow clear
drop C E G H
rename Code Date
label var Date "Date"

rename SWIALSHRI AllShare
label var AllShare "TRI Swiss All Share"

rename SWISSMIRI SMI

rename PRIMALLRI Prime

rename SWEURSPER EURCHF
label var EURCHF "EUR-CHF Exchange Rate"

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE5', replace


exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"

capture cd ${STANDARD_FOLDER}

***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Qualtrics Output file for the analyst survey  (Downloaded from Qualtrics on June 21, 2016):
/*Results file directly exported from Qualtrics in a csv format */

local ANALYST_SURVEY = "SellSide_Analyst_Survey_Impact_of_Swiss_Franc_Shock.csv"

*** OUTPUT:

* None, all results for this survey are directly produced via code in this do-file

***********************************************
************* Import Dataset ******************
***********************************************
cd "1_Sources\Surveys"

import delimited "`ANALYST_SURVEY'", delimiter(comma) varnames(1) encoding("utf-8")

*******************************************
********* PREPARATION OF DATASET **********
*******************************************


************* Merge Analysts with covered firms ************
gen COUNT = _n
rename v5 EMail

* Removed emails for confidentiality reasons 

************* Rename and code questions ************
count
egen Random = group(dobrfl_15) in 2/`r(N)'

drop doqn93-v198 				// Drop Display Order
rename dobrfl_15 OrderQuestion8
tempvar SUBSTR
gen SUBSTR = substr(OrderQuestion8,-4,1)
replace OrderQuestion8 = SUBSTR
destring OrderQuestion8, force replace
drop v2-v4 v6-v9 				// Drop beginning info
drop n11 						// no question
drop n121_1_text n121_2_text 	// Contact data

rename v1 ResponseID
rename v10 FinishedIndicator

rename n21 Part1
rename n22 Q1
rename n23 Q2
rename n24_1 Q3
rename n25 Q4
rename n31 Part2
rename n32_1 Q5_Part1_1 // Not assessed
rename n32_2 Q5_Part1_2 // No material effect
rename n32_3 Q5_Part1_3 // Material Effect
rename n33_1 Q5_Part2_1 // Qualitative
rename n33_2 Q5_Part2_2 // Quantitative
rename n33_3 Q5_Part2_3 // Stock recommendation

forvalues i = 1/9 {

	rename n34_`i' Q6_`i'

}

rename n35 Q6_Comment
rename n36_1 Q7
/* have to rename variables here for later recodes */

rename n91 Part3_Part2
rename n101 Part4
rename n111 Demographics

forvalues i = 1/6 {
	rename n92_`i' Q10_`i' 		// Translational etc.
}

rename n93 Q11

forvalues i = 1/4 {
	rename n94_`i' Q12_`i' // 
}

rename n95 Q12_Comment

forvalues i = 4/6 { 			// Wrong coding in Qualtrics, adjust here
	local j = `i' -3
	rename n96_`i'_text Q13_Most`j'
	}
	
forvalues i = 1/3 {
	rename n97_`i'_text Q13_Least`i'
	}

forvalues i = 1/5 {
	rename n102_`i' Q14_`i'
	}

	rename n103 Q15

	rename n112_1 D1_1
	rename n112_2 D1_2
	
forvalues i = 4/15 {
	local z = `i' -1 		// Wrong coding in Qualtrics, adjust here
	rename n112_`i' D1_`z'
	}

rename n112_15_text D1_15

rename n113 D2

rename n114 D3

rename n115_1 D4

rename n116 D5

rename n117 D6

rename n117_text D6_text

rename n118 D7

rename n119 D8

rename n1110 D9

rename n122 OverallComments
	
	
egen Part3_Part1 = concat(n?1)

forvalues i = 1/9 {
	egen Q8_`i' = concat(n?2_`i')
	}

forvalues i = 1/9 {
	egen Q9_`i' = concat(n?3_x`i')
	}

egen Q9_Comment = concat(n?4)

	
drop n?1*
drop n?2*
drop n?3*
drop n?4*

gen SepQ8Q9 = "" // Needed for ordering (separating q8 and q9), needed for tests
	
order ResponseID EMail FinishedIndicator Part1 Q1 Q2 Q3 Q4 Part2 Q5* Q6* Q7 Part3_Part1 Q8* SepQ8Q9 Q9* Part3_Part2 Q10* Q11* Q12* Q13* Q14* Q15*
 
rename Q9_Comment Comment_Q9
rename Q12_Comment Comment_Q12
rename Q6_Comment Comment_Q6

replace Q14_3 = "Q14" if _n == 1 // because of error of quotation marks in label 
 
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}
  drop if _n == 1 // now drop label observation

foreach var of varlist FinishedIndicator-Q6_9 Q7-Q9_9 Part3_Part2-Q11 Q12* Q14_1-D1_14 D2-D6 D7-D9 {

	destring `var', replace
	replace `var' = . if `var' == -99
}

keep if FinishedIndicator == 1 
drop if missing(Q15) == 1
drop OverallComment 
replace Q7 = 0 if missing(Q7) // The slider's default position was at 0 %, but Qualtrics recorded a missing for those cases

****************** Rename Labels *******************

label variable 	Q1 "Importance BEFORE the shock"
label variable 	Q15 "Importance AFTER the shock"
label variable 	Q2 "Expectation about cap removal"
label define 	Q2 1 "< 3 months" 2 "3 - 6 months" 3 "6 - 12 months" 4 "12 - 24 months" 5 "> 24 months"
label values 	Q2 Q2
label var 		Q3 "% of covered firms which are affected"
label var 		Q4 "How is the typical firm affected"
label define 	Q4 1 "Very negatively" 2 "Negatively" 3 "Neutral" 4 "Positively" 5 "Very positively"
label values 	Q4 Q4
label var 		Q5_Part1_1 "% not assessed"
label var 		Q5_Part1_2 "% assessed but no material effect"
label var 		Q5_Part1_3 "% assessed and material effect"
label var 		Q5_Part2_1 "% (thereof) qualitative adjustment"
label var 		Q5_Part2_2 "% (thereof) quantitative adjustment"
label var 		Q5_Part2_3 "% (thereof) change in EF/SR"

label var Q6_1 "Clients"
label var Q6_2 "Internal departments"
label var Q6_3 "Peer pressure"
label var Q6_4 "Reputation"
label var Q6_5 "Job description"
label var Q6_6 "Availability firm info"
label var Q6_7 "Likely firm exposure"
label var Q6_8 "Firm complexity"
label var Q6_9 "Relative importance"

label var Q7 "% of firms (re-)assessed"

forvalues i = 8/9 {
	label variable Q`i'_1 "Personal knowledge"
	label variable Q`i'_2 "Private communication"
	label variable Q`i'_3 "Existing reports"
	label variable Q`i'_4 "Ad-hoc announcements"
	label variable Q`i'_5 "Peer firms"
	label variable Q`i'_6 "Media"
	label variable Q`i'_7 "Peer analysts"
	label variable Q`i'_8 "Stock price reactions"
	label variable Q`i'_9 "Commercial data providers"
}

label var Q10_1 "Translational exposure"
label var Q10_2 "Transactional exposure"
label var Q10_3 "Hedging strategy"
label var Q10_4 "One-time gains/losses"
label var Q10_5 "Sensitivity to indirect effects"
label var Q10_6 "Operating and strategic responses"

label var Q11 "Assessing the impact was..."

label define Q11 1 "Very similar" 2 "Relatively similar" 3 "More difficult for some"
label values Q11 Q11

label var Q12_1 "Complexity"
label var Q12_2 "Financial information"
label var Q12_3 "Volatility of business model"
label var Q12_4 "Uncertainty about responses"

label var Q13_Most1 "Most difficult 1"
label var Q13_Most2 "Most difficult 2"
label var Q13_Most3 "Most difficult 3"

label var Q13_Least1 "Least difficult 1"
label var Q13_Least2 "Least difficult 2"
label var Q13_Least3 "Least difficult 3"

label var Q14_1 "Quantitative inputs"
label var Q14_2 "Qualitative inputs"
label var Q14_3 "Adjustment of template"
label var Q14_4 "Switching to new template"
label var Q14_5 "Full reassessment"


label var D1_1 "Retail/Wholesale"
label var D1_2 "Construction"
label var D1_3 "Chemicals"
label var D1_4 "Software/Technology"
label var D1_5 "Health Care/Pharmaceuticals/Biotechnology"
label var D1_6 "Telecommunications/Media"
label var D1_7 "Insurance"
label var D1_8 "Real Estate"
label var D1_9 "Banks and other Finance"
label var D1_10 "Manufacturing Consumer Goods"
label var D1_11 "Manufacturing Industrials"
label var D1_12 "Consulting/Business Services"
label var D1_13 "Transportation/Energy/Utilities"
label var D1_14 "Other"

label var D2 "No. Industries"
label define INDUST 1 "1" 2 "2-3" 3 "4+"
label values D2 INDUST

label var D3 "No. Firms"
label define FIRMS 1 "1" 2 "2-4" 3 "5-9" 4 "10-15" 5 "16-25" 6 "25+"
label values D3 FIRMS

label var D4 "% Swiss Firms"

label var D5 "Age"
label define AGE 1 "<30" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60+"
label values D5 AGE

label var D6 "Education"
label define EDUCATION 1 "Bachelor" 2 "Master" 3 "CPA,CFA" 4 "PhD" 5 "Other"
label values D6 EDUCATION

label var D7 "Tenure"
label define TENURE 1 "1-3" 2 "4-9" 3 "10+" 
label values D7 TENURE

label var D8 "Employee Size"
label define SIZE 1 "1" 2 "2-4" 3 "5-10" 4 "11-25" 5 "26-50" 6 ">50"
label values D8 SIZE


label var D9 "Employee Headquarter"
label define HQ 1 "Switzerland" 2 "Europe" 3 "USA" 4 "ROW"
label values D9 HQ

gen SwissHQ = D9 == 1
gen EuropeHQ = D9 == 2

gen NumberFirmsSurvey = 1 		if D3 == 1 	// Mean value
replace NumberFirmsSurvey = 3 	if D3 == 2 	// Mean value
replace NumberFirmsSurvey = 7 	if D3 == 3 	// Mean value
replace NumberFirmsSurvey = 13 	if D3 == 4	// Mean value
replace NumberFirmsSurvey = 20 	if D3 == 5	// Mean value
replace NumberFirmsSurvey = 30 	if D3 == 5	// Mean value

gen SwissFirmsSurvey = D4 * NumberFirmsSurvey/100 

compress

*************************************
************** ANALYSIS *************
*************************************

run "${STANDARD_FOLDER}\2_Code\90_Additional_Survey_Code.do"

//Question 1
tab Q1, plot
tab Q1
sum Q1

//Question 15
tab Q15, plot
tab Q15
sum Q15

ttest Q1 == Q15

//Question 2
tab Q2, plot
tab Q2
sum Q2

//Question 3
tab Q3, plot
tab Q3
sum Q3

//Question 7
tab Q7, plot
tab Q7

sum Q7
ttest Q3 == Q7

//Question 4
tab Q4, plot
tab Q4
sum Q4

ttest Q4 == 3

//Question 5
fsum Q5*, label

//Question 6
fsum Q6*, label

quietly: orderquestion Q6, after(Q5_Part2_3) // Program written (see 90_Additional_Code.do) 

runtestquestion Q6, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 8 (Table 4: Panel A)
fsum Q8*, label

quietly: orderquestion Q8, after(Part3_Part1) // Program written (see 90_Additional_Code.do)

runtestquestion Q8, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 9 (Table 4: Panel B)
fsum Q9*, label

quietly: orderquestion Q9, after(SepQ8Q9) // Program written (see 90_Additional_Code.do)

runtestquestion Q9, signiveau(0.10) against(2) high(3) low(1) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

//Question 10 (Table 5: Panel A)
fsum Q10*, label

quietly: orderquestion Q10, after(Part3_Part2) // Program written (see 90_Additional_Code.do)

runtestquestion Q10, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

//Question 11
tab Q11, plot
tab Q11
sum Q11
ttest Q11 = 2

//Question 12 (Table 5: Panel B)
fsum Q12*, label

quietly: orderquestion Q12, after(Q11) // Program written (see 90_Additional_Code.do)

runtestquestion Q12, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 14
fsum Q14*, label

quietly: orderquestion Q14, after(Q13_Least3) // Program written (see 90_Additional_Code.do)

runtestquestion Q14, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Demographics

preserve

foreach var of varlist D1* {
	replace `var' = `var'*100
}
fsum D1*, label

tab D2

tab D3

tab D4

tab D5

tab D6

tab D7

tab D8

restore

exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"

capture cd ${STANDARD_FOLDER}

***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Qualtrics Output file for the IR survey  (Downloaded from Qualtrics on August 11, 2016):
/*Results file directly exported from Qualtrics in a csv format */

local IR_SURVEY = "Investor_Relations_Survey_Impact_of_Swiss_Franc_Shock.csv"

*** OUTPUT:


local MATCH_IR_DESCRIPTIVES = "MatchIRDescriptives.dta" // Files used to produce Table E1 (IA) eventually
local IR_Q_DATA = "IRSurveyData.dta" // File used to produce Table 8 eventually

* However, most results for this survey are still directly produced via the code in this do-file

***********************************************
************* Import Dataset ******************
***********************************************
cd "1_Sources\Surveys"

import delimited "`IR_SURVEY'", delimiter(comma) varnames(1) encoding("utf-8")

cd "${STANDARD_FOLDER}\3_Datasets"

*******************************************
********* PREPARATION OF DATASET **********
*******************************************

set seed 5

************* Merge Analysts with covered firms ************

foreach var of varlist n103_1_text { // This variable contains the ticker symbol that firms provided to identify their firm

	// Removed ticker symbols for confidentiality reasons

}

foreach var of varlist n102_1_text {

	replace `var' = "CFO" 						if `var' == "CFO" | `var' == "CFO "
	replace `var' = "Head Communications" 		if `var' == "Head Communications"| `var' == "Head of Corporate Communications" | `var' == "Head external communications" | `var' == "CCO" | `var' == "Chief Communications Officer"
	replace `var' = "Head IR"					if `var' == "Hear IR"| `var' == "Director Investor Relations" | `var' == "VP IR" | `var' == "Head of Corporate Communications & IR" | `var' == "Hear IR" | `var' == "Head of Investor Relations" | `var' == "Group Treasurer and head of IR" | `var' == "Head of IR" | `var' == "Head of Investor Relations" | `var' == "Head of IR & Cor Comms"
	replace `var' = "(Senior) IR"				if `var' == "Investor Relations Manager"| `var' == "IR Manager" | `var' == "IR & Tresury" | `var' == "Sr. Investor Relations Manager" | `var' == "IR" | `var' == "Senior IR Officer" | `var' == "Investor Relations" | `var' == "Investor Relations Officer"
	replace `var' = "Other"						if `var' == "Company Secretary" | `var' == "Senior PR Manager"
	replace `var' = "Treasury/Accounting"		if `var' == "Corporate Treasurer" | `var' == "Group Treasurer" | `var' == "Senior Accountant"
}

************* Rename Questions ************

drop dobrfl_26-v226							// Drop Display Order
drop v2-v4 v6 v7							// Drop beginning info
drop n11 									// no question
drop n101 n111_1_text-n126 					// Contact data

order n103_1_text
rename n103_1_text Company
rename n102_1_text Job

rename v1 	ResponseID
rename v5	EMail
rename v10 	FinishedIndicator
rename v8   StartDate
gen double StartDate2 = clock(StartDate, "YMDhms")
order StartDate2, after(StartDate)
drop StartDate
rename StartDate2 StartDate
format StartDate %tc 
rename v9   EndDate
gen double EndDate2 = clock(EndDate, "YMDhms")
order EndDate2, after(EndDate)
drop EndDate
rename EndDate2 EndDate

rename n21 Part1
rename n22 Q1
rename n23 Q2
rename n24 Q3
rename n31 Part2
rename n32 Q4 

forvalues i = 1/8 {

	rename n33_`i' Q5_`i'

}

rename n34 Q5_Comment

forvalues i = 1/6 {

	rename n35_`i' Q6_`i'

}

rename n36 Q6_Comment

/* have to rename here for later recodes */

rename n91 Part4



forvalues i = 1/4 {
	rename n92_`i' Q12_`i' // Translational etc.
}

	rename n93 Q12_Comment
	
forvalues i = 1/6 {
	rename n94_`i' Q13_`i' // Translational etc.
}	
	rename n95 Q13_Comment
	
	rename n96 Q14
	rename n97 Q15

	
/* end of have to rename here for later recodes */

egen Part3 = concat(n?1)

egen Q7 = concat(n?2)


forvalues i = 1/4 {
	egen Q8_`i' = concat(n?3_`i')
	}


forvalues i = 1/4 {
	egen Q9_`i' = concat(n?4_x`i')
	}

egen Q9_Comment = concat(n?5)

forvalues TYPE = 4/8 { // Error in Qualtrics, 4 and 5 is missing in Question 10 (adjusted here)

	local z = 0
	
	forval i = 6/10 {
		local z = `i' - 2
		rename n`TYPE'6_`i' n`TYPE'6_`z'
	}
}

forvalues i = 1/8 {
	egen Q10_`i' = concat(n?6_`i')
	}

egen Q10_Comment = concat(n?7)

forvalues i = 1/9 {
	egen Q11_`i' = concat(n?8_`i')
	}
	
drop n41-n88_9

gen SepQ8Q9 = "" // Needed for ordering (separating q8 and q9), needed for tests
	
order Company ResponseID FinishedIndicator Part1 Q1 Q2 Q3 Part2 Q4  Q5* Q6* Part3 Q7  Q8* SepQ8Q9 Q9* Q10* Q11* Part4 Q12* Q13* Q14* Q15*
 
rename Q5_Comment Comment_Q5
rename Q6_Comment Comment_Q6
rename Q9_Comment Comment_Q9
rename Q10_Comment Comment_Q10
rename Q12_Comment Comment_Q12
rename Q13_Comment Comment_Q13

foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}
  drop if _n == 1 // now drop label observation

foreach var of varlist FinishedIndicator Q* Part* {

	destring `var', replace
	replace `var' = . if `var' == -99
}

keep if FinishedIndicator == 1
drop if  missing(Q15) == 1		// One respondent

****************** Rename Labels *******************

label variable Q1 "Importance BEFORE the shock"
label variable Q15 "Importance AFTER the shock"
label variable Q2 "Expectation about cap removal"
label define Q2 1 "< 3 months" 2 "3 - 6 months" 3 "6 - 12 months" 4 "12 - 24 months" 5 "> 24 months"
label values Q2 Q2

label var Q3 "How is your business affected?"
label define Q3 1 "Very negatively" 2 "Negatively" 3 "Neutral" 4 "Positively" 5 "Very positively"
label values Q3 Q3

label var Q4 "When communication with stakeholders?"
label define Q4 1 "< 1 day" 2 "< 1 week" 3 "< 1 month" 4 "< 3 months" 5 "> 3 months"
label values Q4 Q4


label var Q5_1 "Media and press"
label var Q5_2 "Institutional investors"
label var Q5_3 "Retail investors"
label var Q5_4 "Financial analysts"
label var Q5_5 "External audit firm"
label var Q5_6 "Banks and other lending"
label var Q5_7 "Suppliers and customers"
label var Q5_8 "Management or other internal departments"

label var Q6_1 "Existing financial reports"
label var Q6_2 "Existing internal reports"
label var Q6_3 "Newly prepared ad-hoc reports"
label var Q6_4 "Consultation with key management"
label var Q6_5 "Consultation with outside experts"
label var Q6_6 "Feedback from analysts, media etc."


label var Q7 "How proactive approach?"

forvalues i = 8/9 {
	label variable Q`i'_1 "Ad-hoc announcements"
	label variable Q`i'_2 "Private communication"
	label variable Q`i'_3 "Media and financial press"
	label variable Q`i'_4 "Investor days"
}

label var Q10_1 "Uncertainty about effect"
label var Q10_2 "Uncertainty about FX"
label var Q10_3 "Upcoming event"
label var Q10_4 "Little info needs"
label var Q10_5 "Limited impact on firm"
label var Q10_6 "Fear of disclosure precedent"
label var Q10_7 "Company secrets"
label var Q10_8 "Unwanted scrutiny"

label var Q11_1 "Liquidity"
label var Q11_2 "Playing field"
label var Q11_3 "Prevent underpricing"
label var Q11_4 "Conf. Operating strategy"
label var Q11_5 "Conf. Reporting strategy"
label var Q11_6 "New investors"
label var Q11_7 "Existing investors"
label var Q11_8 "Information risk"
label var Q11_9 "Promote reputation"

label var Q12_1 "E-Mails"
label var Q12_2 "Phone calls"
label var Q12_3 "Website hits"
label var Q12_4 "Downloads"

label var Q13_1 "Translational exposure"
label var Q13_2 "Transactional exposure"
label var Q13_3 "Hedging strategy"
label var Q13_4 "One-time gains/losses"
label var Q13_5 "Sensitivity to indirect effects"
label var Q13_6 "Operating and strategic responses"

label var Q14 "Relevance existing reports"
label var Job "Job Title"

foreach var of varlist Q12* {
	replace `var' = . if `var' == 6
}

********** Drop one company with two answers *************

gen Random = rnormal()				// One firm responded twice via IR-CLub. Remove one answer
sort Company Random

by Company: drop if _n == 2 & missing(Company) == 0
drop Random

*************************************
************** ANALYSIS *************
*************************************

run "${STANDARD_FOLDER}\2_Code\90_Additional_Survey_Code.do"

// Question 1 and 15
tab Q1, plot
tab Q1
tab Q15, plot
tab Q15

sum Q1 Q15
ttest Q1 == Q15
ttest Q1 == 4
ttest Q15 == 4

// Question 2
tab Q2, plot
tab Q2
sum Q2

// Question 3
tab Q3, plot
tab Q3
sum Q3
ttest Q3 == 3

// Question 4
tab Q4, plot
tab Q4
sum Q4

// Question 5 (Table 6: Panel A)
quietly: orderquestion Q5, after(Q4) // Program written (see 90_Additional_Code)

runtestquestion Q5, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 6 (Table 6: Panel B)
quietly: orderquestion Q6, after(Comment_Q5) // Program written (see 90_Additional_Code)

runtestquestion Q6, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 7
tab Q7, plot
tab Q7
sum Q7
ttest Q7==4

// Question 8 (Table 7: Panel A)
quietly: orderquestion Q8, after(Q7) // Program written (see 90_Additional_Code)

runtestquestion Q8, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 9 (Table 7: Panel B)
quietly: orderquestion Q9, after(SepQ8Q9) // Program written (see 90_Additional_Code)

runtestquestion Q9, signiveau(0.10) against(2) high(3) low(1) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test



// Question 10

quietly: orderquestion Q10, after(Comment_Q9) // Program written (see 90_Additional_Code)

runtestquestion Q10, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 11

quietly: orderquestion Q11, after(Comment_Q10) // Program written (see 90_Additional_Code)

runtestquestion Q11, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 12
quietly: orderquestion Q12, after(Part4) // Program written (see 90_Additional_Code)

runtestquestion Q12, signiveau(0.10) against(3) high(5) low(1) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

	
// Question 13
quietly: orderquestion Q13, after(Comment_Q12) // Program written (see 90_Additional_Code)

runtestquestion Q13, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

	
// Question 14
tab Q14, plot
tab Q14
sum Q14
ttest Q14==4

tab Job


*****************************************
**Export Dataset for Archival Analysis **
*****************************************


cd "${STANDARD_FOLDER}\3_Datasets"

preserve
	drop if missing(Company)
	duplicates drop Company, force
	keep Company
	count
	save `MATCH_IR_DESCRIPTIVES', replace		// Used for Table E1	
restore

rename Q8_1_Q8_2 Q8_PrivateInfo
rename Q4 Q4_Timeliness
keep Company Q8_PrivateInfo Q4_Timeliness // Keep Relevant Questions for Analyses

drop if missing(Company)

cd "${STANDARD_FOLDER}\3_Datasets"
compress _all
save `IR_Q_DATA', replace

exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}

***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************
 
*** INPUT:

local SOURCEFILE1 	= "BloombergMerge.dta" 			// created in 01_Import_Bloomberg.do

local SOURCEFILE2 	= "ReportData.dta" 				// created in 02_Import_HandCollected.do

local SOURCEFILE3 	= "Datastream_IBES_Final.dta" 	// created in 03_Import_DS_IBES.do

local SOURCEFILE4 	= "PXLastIntraday.dta"			// created in 01_Import_Bloomberg.do 

local SOURCEFILE5 	= "BloombergMVShares.dta" 		// created in 01_Import_Bloomberg.do
	
local SOURCEFILE6 	= "SwissCrossListing.dta"		// created in 04_Import_Various.do

local SOURCEFILE7 	= "RiskHedgingData.dta"			// created in 04_Import_Various.do 

local SOURCEFILE8 	= "IR_DataArchival.dta"			// created in 04_Import_Various.do 

local SOURCEFILE9 	= "IntradayRollingWindow.dta" 	// created in 01_Import_Bloomberg.do

local SOURCEFILE10 	= "NewInformationData.dta"		// created in 04_Import_Various.do 

local SOURCEFILE11 	= "IRSurveyData.dta"			// created in 06_Import_IR_Survey.do

local SOURCEFILE12 	= "ActualSample151.dta"			// Identifier-List. To verify whether the sample is unchanged and OK (generated based on the final sample)

*** OUTPUT:

local SAVEFILE1 = "Final30MinSample.dta"		

************************************************
*********** Merge with other datasets  *********
************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

use `SOURCEFILE1', replace

merge m:1 Company using  `SOURCEFILE2', assert(match master)
drop _merge		


merge m:1 Company using `SOURCEFILE3', assert(match using) keepusing(Type DatastreamName NoshFF DisclosureRank InternationalStandards ///
										ISOCurrStock PriceCurrency NumberOfAnalysts SICCode SIC1 HistCorr* ///
										USGAAP PriceCurrency IFRS ISIN)
	drop if _merge == 2
	drop _merge
	qui count if (ISOCurrStock != "CHF" | PriceCurrency != "SF")
	assert `r(N)' == 0 												// Verify that all stocks are in CHF
	drop ISOCurrStock PriceCurrency
	

merge m:1 ID Date using `SOURCEFILE4', assert(match using)
	drop if _merge == 2
	drop _merge		

merge m:1 Company Date using `SOURCEFILE5' 							
	drop id 							
	drop if _merge == 2				
	rename _merge _merge1											// verify that the _merge == 1 from this step are later deleted (see below)

merge m:1 Type using `SOURCEFILE6', assert(match master) keepusing(CrossListingType)
	drop if _merge == 2 					// Irrelevant, see assert.
	drop _merge

merge m:1 Type using `SOURCEFILE7', assert(match master) 
	drop if _merge == 2 					// Irrelevant, see assert.
	drop _merge

merge m:1 Company using `SOURCEFILE8', assert(match master using) keepusing(IR_Club Lead_IR)
	drop if _merge == 2 					
	drop _merge

merge 1:1 ID DateTime using `SOURCEFILE9', assert(match) keepusing(*Rolling) 
	keep if _merge == 3
	drop _merge

merge m:1 Company Date using `SOURCEFILE10', assert(match master)	
	drop if _merge == 2
	drop _merge

merge m:1 Company using `SOURCEFILE11', assert(match master)	
	drop if _merge == 2
	drop _merge

******************************************************
*********** Last Step Before "Final Sample"  *********
******************************************************
distinct ID

*Table 1 Line 4: Removed 8 firms because of missing main control variables

foreach var of varlist DisclosureRank IntSales NoshFF NumberOfAnalysts {
	drop if missing(`var') 
}

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 151
	cd "${STANDARD_FOLDER}\1_Sources\Verification\"
	merge 1:1 Company using `SOURCEFILE12', assert(match)
restore

sum _merge1
assert `r(max)' == 3 & `r(min)' == 3
drop _merge1 

sort ID DateTime

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}


***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

*** INPUT:

local SOURCEFILE1 = "Final30MinSample.dta"

*** OUTPUT:

local SAVEFILE1 = "IntradayDataFinal.dta" // File for Intraday Analyses
local SAVEFILE2 = "DailyDataFinal.dta"	// File for Daily Analyses


***************************************************************
***************************************************************
************** I. Generate Intraday Dataset *******************
***************************************************************
***************************************************************

****************************************************************
************************ Import Intraday file ******************
****************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
										
use `SOURCEFILE1', replace											// starts with balanced panel
sort ID DateTime 

****************************************************************
***************** Make consistency checks***********************
****************************************************************

qui xtset ID DateTime
xtdescribe

assert `r(N)' == 151 													// assert that sample is correct, should be 151 observations
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum Date, detail
local MINDATE = `r(min)'

qui sum ID, detail
local MINID =`r(min)'

count if Date == `MINDATE' & ID == `MINID'

scalar INTRADAYOBS = `r(N)'												// Set number of Intraday observations for changes

assert scalar(INTRADAYOBS) == 17										// Set number of Intraday observations for changes

sum ID if HourMin <= 1030 & Date == `MINDATE' & ID == `MINID', detail
assert `r(N)' == 3
global UNTIL1030 = `r(N)'
assert ${UNTIL1030} == 3

****************************************************************
********************* SET SOME GLOBALS *************************
****************************************************************

global BENCHMARK_PERIOD "CenterDate <= -1 & CenterDate >= -30"

****************************************************************
***************** Generate important variables *****************
****************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

*Generate Logarithmic Returns
sort ID DateTime 
by ID: 	gen LogReturn = log(LastPriceTrade/LastPriceTrade[_n-1])		 // Overnight returns are fine
	replace LogReturn 	= 0 if missing(LogReturn)						//  Only for Oct 1 (not necessary as outside of sample)

*Generate CenterDate
sort ID DateTime 
egen 	CenterDate = group(Date)
	egen 	MAXDATE = group(Date) if Date <=td(15-jan-2015)
	qui sum MAXDATE, detail
	replace CenterDate = CenterDate-`r(max)'							// CenterDate is 0 for 15 Jan, 2015
	drop 	MAXDATE

* Generate Intraday Volatility
sort ID Date DateTime
by 	ID Date: egen SDReturn = sd(LogReturn)
	replace SDReturn =SDReturn*100										// * 100 for readability


* Generate BidAskSpread and MarketValue Variables
sort ID Date DateTime
gen LogSpread30 			= log(MeanTimeBidAskSpread) 										// BidAskSpread or LogSpread is only daily data; intraday TimeBidAskSpread, which is grouped by 30mins
gen LogMV 					= log(MVBloomAllNo)
by ID Date: replace LogMV 	= log(MVBloomAllNo*LastPriceTrade/LastPriceTrade[scalar(INTRADAYOBS)]) 	// Because MVBloomAllNo is End of Day; now adjust by intraday movements for intradey data

* Generate Turnover Variables
sort ID DateTime
by ID: gen Turnover = (ValueTrade)/(MVBloomAllNo[_n-scalar(INTRADAYOBS)]*1000000)*100 	// Lagged by one Day; * 100 for readability in %
gen LogTurnover 	= log(Turnover)

*** Generate Variables for Daily Analyses (e.g. Intraday Version of Liquidity Amihud)
gen AmihudIntraday = abs(LogReturn)/ValueTrade
gen RiskMGMTPerPage = NumberofRiskManagement/ReportLength
gen HedgingPerPage = Hedging/ReportLength

* Generate Logged Version of Rolling Return Volatility
sort ID Date DateTime
gen LogSDRolling = log(SDRolling)

* Generate Lagged Variables (not L., because of gaps)
sort ID DateTime
foreach var of varlist LogMV LogTurnover LogSDRolling SDReturn  {					// SDReturn (unlogged) needed for daily data set in collapse (only positive values)
	by ID: gen Lag`var' = `var'[_n-scalar(INTRADAYOBS)]
}

* Standardize Risk Disclosure to mean 0 and SD of 1 for analyses
sum RiskDisclosure, detail
egen StandardRiskDisc = std(RiskDisclosure)

* Generate Main Variables for Intraday Analyses.
sort ID DateTime

assert scalar(INTRADAYOBS) == 17											// Assert whether number of intraday obs is still correct
assert ${UNTIL1030} == 3													// Assert whether number of obs up until 10.30 is still correct.
assert ValueTrade[1193] == 15408579.085 									// Just an assert whether Value Trade as of 10.30 Jan 15 ABB; necessary for START variable

local ANNOUNCEMENT_DAY 	= 0
local WINDOW_START		= -30 	+ `ANNOUNCEMENT_DAY'
local WINDOW_END 		= 0 	+ `ANNOUNCEMENT_DAY'

sort ID DateTime
by ID: gen NUMBER 		= _n
gen START				= NUMBER - 1193-`ANNOUNCEMENT_DAY'*17+${UNTIL1030}
drop NUMBER

local y = 0
	
foreach x of numlist 1/`=scalar(INTRADAYOBS)'{
	
	local t = 8+int((`x'+1)/2)				// To determine Hour for Dummy
	local e = `t'+1							// To determine if Hour moves past
	
	gen _`x'AfterIncrease 		= 0
	replace _`x'AfterIncrease 	= 1 if START <= `x' & START > `y'
	
	gen _`x'AScore 	= _`x'AfterIncrease*StandardRiskDisc
	
	gen only_`x'AScore = _`x'AfterIncrease*StandardRiskDisc

	if int((`x'+1)/2) == (`x'+1)/2 {
		label var 	_`x'AfterIncrease 	"`t'.00-`t'.30 Dummy"
		label var 	_`x'AScore 			"`t'.00-`t'.30 x RiskDisclosure"
	}
	
	else {
		label var 	_`x'AfterIncrease 	"`t'.30-`e'.00 Dummy"
		label var 	_`x'AScore 			"`t'.30-`e'.00 x RiskDisclosure"
	}
	
	local y = `x'							// Counter
	
}


** Label Variables for Main Intraday Analyses
label var LogSpread30 			"Log(Spread)"
label var LagLogMV 				"Log(MarketValue)(t-17)"
label var LagLogTurnover 		"LogTurnover(t-17)"
label var LagLogSDRolling 		"Log(ReturnVolatility)(t-17)"


cd "${STANDARD_FOLDER}\3_Datasets"

sort ID DateTime

save `SAVEFILE1', replace

***************************************************************
***************************************************************
*************** II. Generate Daily Dataset ********************
***************************************************************
***************************************************************

****************************************************************
************* Collapse Dataset to Daily Dataset ****************
****************************************************************


cd "${STANDARD_FOLDER}\3_Datasets"
use `SAVEFILE1', replace

global FIRST Company Type DatastreamName SICCode ISIN CrossListingType // String Variables
global MEAN  AmihudIntraday MeanRelativeStale HistCorrEUR HistCorrUSD // Variables that vary within a day (e.g., AmihudIntraday) or a not varying within a day, but can take negative values (e.g., HistCorr)
global MAX  MeanDateBidAskSpread RiskDisclosure IntSales DisclosureRank NumberOfAnalysts NoshFF ///
			AfterSNB InternationalStandards SDReturn LagSDReturn PXLast BeforePXLast USGAAP IFRS ReportLength MVBloomAllNo Date SIC1 ///
			EPS_Revision News_SNB TotalNewInfo MeanDateEffSpread_No_W MeanDateEffSpread_W_M  ///
			Revenues2013 Assets2013 CostsProfits2013 Monetary2013 FXExposure2013 Hedging2013 FXSensitivity2013 ///
			LogRiskLinkedin LogHedgeKeyLinkedin Log_IR_Linkedin RiskMGMTPerPage HedgingPerPage RiskCommittee ChiefRisk EconHedgeYesNo IR_Club Lead_IR ///
			Q4_Timeliness Q8_PrivateInfo // These variables are not varying within a day and are >=0 (hence max in collapse step within a day always give the same value)
global SUM  ValueTrade

foreach ASS of global MAX {
	assert `ASS' >= 0 	& missing(`var') == 0					// Verify that only positive values, such that max in collapse-command is appropriate.
	}

collapse (mean) ${MEAN} (max) ${MAX} (sum) ${SUM} (first) ${FIRST}, by(ID CenterDate) 	// max because timeinvar and day 0
order ID Date DatastreamName Company

****************************************************************
***************** Generate Key Variables ***********************
****************************************************************

* Panel Checks whether data is correct
qui xtset ID Date
xtdescribe

assert `r(N)' == 151 													// Sample is correct, should be 151 observations
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum ID, detail
count if ID == `r(min)'

scalar TOTAL_DAYS = `r(N)'
assert TOTAL_DAYS == 144

qui sum Date, detail
count if Date == `r(min)'

scalar TOTAL_FIRMS = `r(N)'
assert TOTAL_FIRMS == 151


forval i = 1/`=scalar(TOTAL_FIRMS)'  {
	assert CenterDate[(70+(`i'-1)*TOTAL_DAYS)] == -1
}

* Standardize Risk Disclosure to mean 0 and SD of 1 for analyses
sum RiskDisclosure, detail
egen StandardRiskDisc = std(RiskDisclosure)

* Generate Median Split Risk Disc Variable (mostly for figures)
sum RiskDisclosure, detail
assert  `r(p50)' == 4
gen AboveRiskDisclosure = RiskDisclosure > `r(p50)' & !missing(RiskDisclosure)

* Log Variables (Log-transformation before collapse did not capture them)
gen LogSpread 			= log(MeanDateBidAskSpread)
gen LogSDReturn 		= log(SDReturn)
gen LogReportLength 	= log(ReportLength)
gen LogEffSpread 		= log(MeanDateEffSpread_No_W)
gen LogEffSpread_wgt	= log(MeanDateEffSpread_W_M)
gen LogAmihud 			= log(AmihudIntraday)

* Generate Main Controls (Log-transformation before collapse did not capture them)
sort ID CenterDate
by ID: gen Turnover 	= (ValueTrade/(MVBloomAllNo[_n-1]*1000000))*100				// in pp to enhance readability
by ID: gen LogTurnover 	= log(Turnover)
gen LogMV 				= log(MVBloomAllNo)

* Generate Additional Controls
sort ID CenterDate
foreach VAR of varlist LogTurnover LogMV LogSDReturn {
	by ID: gen Lag`VAR' = `VAR'[_n-1]
}

* Generate Lagged (but not logged) variables for descriptives table
sort ID Date 
by ID: gen LagMV = MVBloomAllNo[_n-1] 
by ID: gen LagTurnover = Turnover[_n-1] 

* Generate Industry Fixed Effects
foreach VAR of varlist SIC1  {
	egen IndustryDate`VAR' = group(`VAR' Date)
}

* Generate additional Control variables
gen HistCorrEur_R = HistCorrEUR
replace HistCorrEur_R = HistCorrUSD if missing(HistCorrEur_R) // Just 4 firms
drop HistCorrEUR HistCorrUSD

* Additional Variables (IA)
gen CrossList = !missing(CrossListingType)
gen MajorCrossList = !missing(CrossListingType) & CrossListingType != "U"
gen ExchCrossList = CrossListingType == "Real"

* Generate New Info Variables
foreach VAR of varlist EPS_Revision News_SNB TotalNewInfo {
	gen Log`VAR' = log(1 + `VAR')
}

* Generate Survey-Based Variable for Archival Analysis  
gen FirstWeek = Q4_Timeliness <= 2 if !missing(Q4_Timeliness) 			// Within The First Week
gen ImportantPrivate = Q8_PrivateInfo >= 6 if !missing(Q8_PrivateInfo) 	// Important Private Communication (6 or 7 on Likert Scale)

* Generate Return Variables
sort ID CenterDate
gen LogPXLast = log(PXLast)
by ID: gen LogReturn		= log(PXLast/PXLast[_n-1])*100															// * 100 for readability
by ID: replace LogReturn	= log(PXLast/BeforePXLast)*100 if Date == td(01oct2014) & missing(LogReturn)			// * 100 for readability


* Generate time-invariant controls based on average of benchmark period (except for LogMV, just for robustness tests)
foreach VAR of varlist LogMV LogTurnover LogSDReturn LogSpread MVBloomAllNo Turnover SDReturn MeanDateBidAskSpread LogReturn {
	by ID: egen MeanPre`VAR' = mean(`VAR') if ${BENCHMARK_PERIOD}
	by ID: replace MeanPre`VAR' = MeanPre`VAR'[_n-1] if missing(MeanPre`VAR')
	rename MeanPre`VAR' `VAR'_030
}

sort ID Date

* Generate Variables for Synthetic Control Analysis in Internet Appendix
foreach VAR of varlist LogSpread LogReturn {

	by ID: egen Mean`VAR' = mean(`VAR') if CenterDate < 0 					// Related to i)
	by ID: replace Mean`VAR' = Mean`VAR'[_n-1] if missing(Mean`VAR')

	by ID: egen Max`VAR' = max(`VAR') if CenterDate < 0						// Related to ii)
	by ID: replace Max`VAR' = Max`VAR'[_n-1] if missing(Max`VAR')

	by ID: egen Min`VAR' = min(`VAR') if CenterDate < 0 					// Related to iii)
	by ID: replace Min`VAR' = Min`VAR'[_n-1] if missing(Min`VAR')

	by ID: egen SD`VAR' = sd(`VAR') if CenterDate < 0 						// Related to iv)
	by ID: replace SD`VAR' = SD`VAR'[_n-1] if missing(SD`VAR')

	by ID: egen Skew`VAR' = skew(`VAR') if CenterDate < 0 					// Related to v)
	by ID: replace Skew`VAR' = Skew`VAR'[_n-1] if missing(Skew`VAR')

}

* Generate PostSNB Interactions
foreach var of varlist 	StandardRiskDisc AboveRiskDisclosure ///
						LagLogMV LagLogTurnover LagLogSDReturn ///
						IntSales DisclosureRank NumberOfAnalysts NoshFF HistCorrEur_R ///
						LogReturn LogMV_030* LogTurnover_030* LogSDReturn_030* LogSpread_030* LogReturn_030 ///
						LogRiskLinkedin LogHedgeKeyLinkedin Log_IR_Linkedin RiskMGMTPerPage HedgingPerPage RiskCommittee ChiefRisk EconHedgeYesNo IR_Club Lead_IR ///
						InternationalStandards IFRS USGAAP LogReportLength ///
						CrossList MajorCrossList ExchCrossList FirstWeek ImportantPrivate ///
						LogEPS_Revision LogNews_SNB LogTotalNewInfo {
	gen A`var' = `var'*AfterSNB
}

* Generate Triple Interactions
foreach VAR of varlist LogEPS_Revision LogNews_SNB LogTotalNewInfo {
	gen Triple_RiskDisc_`VAR' = AStandardRiskDisc * `VAR'
}

* Generate Longer-Term Post Indicators
gen Post1 = CenterDate <= 2 & CenterDate >= 0
gen Post2 = CenterDate <= 10 & CenterDate >= 3
gen Post3 = CenterDate <= 20 & CenterDate >= 11

foreach VAR of varlist Post* {
	gen `VAR'_RiskDisc = `VAR' * StandardRiskDisc
}

* Make tables more readable and label variables
rename SDReturn ReturnVol
cd "${STANDARD_FOLDER}\2_Code"

run "91_Label Variables.do"

* Save Dataset
cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE2', replace

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\" 

	
capture cd ${STANDARD_FOLDER}

***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

* INPUT:
global DAILY_DATA = "DailyDataFinal.dta"

global INTRADAY_DATA = "IntradayDataFinal.dta"

* OUTPUT:
global SPREAD_MODEL			"Table2.doc"
global INTRA_MODEL			"Table3_PanelA.doc"
global PERSIST_MODEL		"Table3_PanelB.doc"
global INTERACT_MODEL		"Table3_PanelC.doc"
global PRIVATE_INFO_MODEL	"Table8.doc"

***********************************************
** Define Some Global Variables for All Var. **
***********************************************

global DEPVAR_SPREAD 			"LogSpread"
global DEPVAR_RETVOL			"ReturnVol"

global TIME						"CenterDate <= 2 & CenterDate >= -30"

global CLUSTER					"ID Date"
global FIXED_NO_DATE			"ID"
global FIXED_DATE				"ID Date"
global FIXED_INDUSTRY_DATE		"ID IndustryDateSIC1"

global POST 					"AfterSNB"
global MAIN_TEST				"AStandardRiskDisc"
global MAIN_CONTROLS			"LagLogMV LagLogTurnover LagLogSDReturn"
global ADD_CONTROLS				"ALogMV_030"
global OTHER_CONTROLS			"AIntSales AHistCorrEur_R ADisclosureRank ANumberOfAnalysts ANoshFF"
global RET_CONTROLS				"LogReturn ALogReturn"

global OUTREG_TITLE		"Regressions with [-30; +2] window using daily data"
global R_PANEL 			"e(r2_a_within)"
global OUTREG_STATS		"nor2 noobs nonote tstat bdec(3) tdec(2) addnote(t-statistics based on robust standard errors clustered by firm and date, *** p<0.01; ** p<0.05; * p<0.1) label"

*************************************************************
*************************************************************
*************** I. Daily Analysis Regressions ***************
*************************************************************
*************************************************************


*************************************************************
************************ Table 2 ****************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

cd "${STANDARD_FOLDER}\4_Output\Tables"

*** Generate Sample of 4,949 (151 firms)

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST}  ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	keep if (e(sample)) 
	count
	assert `r(N)' == 4949

*** Descriptive Statistics Table 1: Panel B

fsum MeanDateBidAskSpread ReturnVol AfterSNB RiskDisclosure LagMV LagTurnover LagSDReturn IntSales HistCorrEur_R DisclosureRank NumberOfAnalysts NoshFF LogReturn, stats(n mean sd p1 p25 p50 p75 p99) f(%9.3f)

***** Table 2

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST} ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Date")  ${OUTREG_STATS}
	
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}
		
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_RETVOL} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) sortvar(${POST}) addtext(Fixed Effects, "Firm & Date") 	${OUTREG_STATS}


*************************************************************
*************************************************************
************* II. Remaining Archival Analyses ***************
*************************************************************
*************************************************************

*************************************************************
****************** Table 3: Panel A *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${INTRADAY_DATA}, replace

cd "${STANDARD_FOLDER}\4_Output\Tables"

global DEPVAR_SPREAD30 			"LogSpread30"

global TIME30_LONG				"CenterDate<=0 & CenterDate>=-30"
global TIME30_SHORT				"CenterDate<=0 & CenterDate>=0"

global MAIN_CONTROLS30			"LagLogMV LagLogTurnover LagLogSDRolling"

global CLUSTER30				"ID DateTime"
global OUTREG30					"nor2 noobs nonote addnote(t-statistics based on robust standard errors clustered by firm and time, *** p<0.01; ** p<0.05; * p<0.1) label"
	
global OUTREG_TITLE30		"Within announcement day: Log(Spread) as the dependent variable"


reghdfe ${DEPVAR_SPREAD30} _*  ${MAIN_CONTROLS30}		if ${TIME30_LONG}, absorb(ID HourMin) vce(cluster ${CLUSTER30}) noconstant
	outreg2 using ${INTRA_MODEL}, replace ctitle([-30; 0]) title("${OUTREG_TITLE30}") nose bdec(3)  ${OUTREG30}
	outreg2 using ${INTRA_MODEL}, append ctitle([-30; 0]) title("${OUTREG_TITLE30}") drop(LogSpread30) stats(tstat)  tdec(2) adds(Adj. Within R2, ${R_PANEL}, No. Firms, e(N_clust1), No. Obs, e(N)) addtext(Fixed Effects, "Firm & Time-of-Day") ${OUTREG30}
	assert `e(N)' == 64012

reghdfe ${DEPVAR_SPREAD30} _*AScore ${MAIN_CONTROLS30} 	if ${TIME30_SHORT}, absorb(HourMin) vce(cluster ${CLUSTER30}) noconstant
	outreg2 using ${INTRA_MODEL}, append ctitle([0; 0]) title("${OUTREG_TITLE30}") nose bdec(3) ${OUTREG30}
	outreg2 using ${INTRA_MODEL}, append ctitle([0; 0]) title("${OUTREG_TITLE30}") drop(LogSpread30) stats(tstat) tdec(2) adds(Adj. Within R2, ${R_PANEL}, No. Firms, e(N_clust1), No. Obs, e(N)) addtext(Fixed Effects, "Time-of-Day") ${OUTREG30}
	count if e(sample)
	assert `e(N)' == 2112


*************************************************************
****************** Table 3: Panel B *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

global TIME_LONG				"CenterDate <= 20 & CenterDate >= -30"

global MAIN_TEST_LONG			"Post1_RiskDisc Post2_RiskDisc Post3_RiskDisc"
global POST_LONG				"Post1 Post2 Post3"

cd "${STANDARD_FOLDER}\4_Output\Tables"

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST_LONG}  ${MAIN_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	keep if (e(sample)) 
	count
	assert `e(N)' == 7653

*****

reghdfe ${DEPVAR_SPREAD} ${POST_LONG} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PERSIST_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Date") ${OUTREG_STATS}
	
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}
		
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_RETVOL} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) sortvar(${POST_LONG}) addtext(Fixed Effects, "Firm & Date") ${OUTREG_STATS}


*************************************************************
****************** Table 3: Panel C *************************
*************************************************************
cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

global MAIN_TEST1				"AStandardRiskDisc ALogEPS_Revision Triple_RiskDisc_LogEPS_Revision"
global MAIN_TEST2				"AStandardRiskDisc ALogNews_SNB Triple_RiskDisc_LogNews_SNB"
global MAIN_TEST3				"AStandardRiskDisc ALogTotalNewInfo Triple_RiskDisc_LogTotalNewInfo"


cd "${STANDARD_FOLDER}\4_Output\Tables"

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST1}  ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER})
	keep if (e(sample)) 
	count
	assert `e(N)' == 4949

*****

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${INTERACT_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER})  noconstant
		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS} sortvar(${MAIN_TEST1}   ${MAIN_TEST2}  ${MAIN_TEST3})

*************************************************************
************************* Table 4-7 *************************
*************************************************************

* Corresponding Results are produced in 05_Import_Sell_Side_Analyst_Survey (Table 4 and 5)
* and 06_Import_IR_Survey (Table 6 and 7)

*************************************************************
*************************** Table 8 *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

drop if missing(Q4) & missing(Q8) // Restrict Sample to Survey Respondents

global TIME						"CenterDate <= 2 & CenterDate >= -30"

global MAIN_TEST1				"AStandardRiskDisc"
global MAIN_TEST2				"AStandardRiskDisc AFirstWeek"
global MAIN_TEST3				"AStandardRiskDisc AImportantPrivate"

 cd "${STANDARD_FOLDER}\4_Output\Tables"

*** Column 1-3
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}
	count if e(sample)
	assert `e(N)' == 1185

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

* Column 4-6: Drop Outliers in this analysis
drop if ID == 26 

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}
	count if e(sample)
	assert `e(N)' == 1119

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS} sortvar(${MAIN_TEST1} ${MAIN_TEST2} ${MAIN_TEST3})


local TXTFILES: dir . files "*.txt"
foreach TXT in `TXTFILES' {
    erase `"`TXT'"'
}



exit
// Two created programs for analysis of surveys (orderquestion + runtestquestion)
// Need to be run before 05_Import_Sell_Side_Analyst_Survey or 06_Import_IR_Survey 
// Or created as two separate ado-files and added do the personal ado folder

capture program drop orderquestion
program define orderquestion
	syntax namelist(max=1) [, after(string)]
	
// From here statslist  http://www.statalist.org/forums/forum/general-stata-discussion/general/1357869-order-variables-based-on-their-mean

ds `namelist'*
local vlist `r(varlist)'

preserve

collapse (mean) `vlist'
local i = 1
foreach v of local vlist {
    gen name`i' = "`v'"
    rename `v' mean`i'
    local ++i
}
gen _i = 1
reshape long mean name, i(_i) j(_j)
sort mean
replace _j = _n
replace name = name + " " + name[_n-1] if _n > 1
local ordered_vlist = name[_N]
restore
order `ordered_vlist', after(`after')

// Until here statslist  http://www.statalist.org/forums/forum/general-stata-discussion/general/1357869-order-variables-based-on-their-mean

ds `namelist'*  // Do it again, because of new ordering
local vlist `r(varlist)'

local i = 0
foreach var of varlist `vlist' {
	local i = `i' + 1
	rename `var' `namelist'_`i'_`var' // i displays the ranking of the means, while the old identifier is retained at the end of the variable name 
}


end

capture program drop runtestquestion
program define runtestquestion
	syntax namelist(max=1) [, signiveau(numlist max = 1) against(numlist max=1) high(numlist max=1) low(numlist max =1) unpaired(numlist max =1)]
	
	local MAX = 0
	local TEST_OPTION = ""
	if `unpaired' == 1 {
		
		local TEST_OPTION = ", unpaired"
	
	}
foreach QUESTION in `namelist' {
	// Determine the number of items
	qui ds `QUESTION'_*
	qui local nword : word count `r(varlist)'
	
	// Determine Mean and Baseline Tests (no comparison between answer items)
	
	matrix define `QUESTION' = J(`nword',5,.) // Column 3 is missing because it is filled in later with the Holm-Adjustment mechanism
	
	local POS = 0
	foreach var of varlist `QUESTION'_* {
		local POS = `POS' +1
		
		qui count if missing(`var') == 0
		local TOTAL = `r(N)'
		
		qui count if missing(`var') == 0 & `var' >= `high'
		
		local highPER = `r(N)'/`TOTAL'*100

		
		qui count if missing(`var') == 0 & `var' <= `low'

		local lowPER = `r(N)'/`TOTAL'*100

		
		qui ttest `var' == `against'
		matrix `QUESTION'[`POS',1] = round(`r(mu_1)',0.01)
		matrix `QUESTION'[`POS',2] = round(`r(p)',0.001)
		matrix `QUESTION'[`POS',4] = round(`highPER',0.01)
		matrix `QUESTION'[`POS',5] = round(`lowPER',0.01)

	}
		matrix colnames `QUESTION' = Mean P-Value Holm High% Low%
		matrix list `QUESTION'
		
		
		forval i = 1/5 {
			display ""
		}
	// Here comparisons across answer items
	
		forval T_TEST_Q = 1/`nword' {
			
			qui sum  `QUESTION'_`T_TEST_Q'
			local MAX = max(`MAX',`r(N)')
			
			matrix define `QUESTION'_`T_TEST_Q' = J(`nword'-1,6,.)

			local POS = 0
			foreach i of numlist 1/`nword' {
				if `i' == `T_TEST_Q' {
			}
			else {
				local POS = `POS' +1
				qui ttest `QUESTION'_`T_TEST_Q' == `QUESTION'_`i' `TEST_OPTION'
				matrix `QUESTION'_`T_TEST_Q'[`POS',1]=`i'
				matrix `QUESTION'_`T_TEST_Q'[`POS',2]=`r(p)'
				matrix `QUESTION'_`T_TEST_Q'[`POS',3]=`r(p)' <= `signiveau'
			}
	}
		mata : st_matrix("`QUESTION'_`T_TEST_Q'", sort(st_matrix("`QUESTION'_`T_TEST_Q'"), 2)) // Command for sorting of p value
	
		local ntests = `nword' -1
	
		forval i = 1/`ntests' {
	
			matrix `QUESTION'_`T_TEST_Q'[`i',4] = `signiveau'/(`ntests'-`i'+1)
			matrix `QUESTION'_`T_TEST_Q'[`i',5] = `QUESTION'_`T_TEST_Q'[`i',2] <= `QUESTION'_`T_TEST_Q'[`i',4]
			matrix `QUESTION'_`T_TEST_Q'[`i',6] = `QUESTION'_`T_TEST_Q'[`i',1] * `QUESTION'_`T_TEST_Q'[`i',5]
			
			matrix colnames `QUESTION'_`T_TEST_Q' = Number SigNiveau Sig? Holm Sig? WhereDiffs
			
	}
	
	local lab: variable label `QUESTION'_`T_TEST_Q'
	di "`lab'"
	
	matrix list `QUESTION'_`T_TEST_Q'
	matrix Only_`QUESTION'_`T_TEST_Q' = `QUESTION'_`T_TEST_Q'[1..`nword'-1,6]
	
	mata : st_matrix("Only_`QUESTION'_`T_TEST_Q'", sort(st_matrix("Only_`QUESTION'_`T_TEST_Q'"), 1)) // Command for sorting of p value
	matrix list Only_`QUESTION'_`T_TEST_Q'

	

	forval i = 1/5 {
		display ""
	}

}
}

display "Max number of obs: `MAX'"

clear matrix
end
version 13.1
${LOG_FILE_OPTION}

* Coming from DailyDataFinal.dta

* Outcome Variables
label var LogSpread 				"Log(Spread)"
label var ReturnVol 				"ReturnVol"

label var AfterSNB					"PostSNB"

* Main Test Variable
label var RiskDisc 			"RiskDisclosure"
label var AStandardRiskDisc	"PostSNB x RiskDisclosure"

* Control Variables
label var LogMV 					"Log(MarketValue)"
label var LagLogMV 					"Log(MarketValue)(T-1)"

label var LogTurnover 				"Log(Turnover)"
label var LagLogTurnover 			"Log(Turnover)(T-1)"

label var LogSDReturn 				"Log(ReturnVolatility)"
label var LagLogSDReturn 			"Log(ReturnVolatility)(T-1)"

label var ALagLogMV					"PostSNB x Log(MarketValue)(T-1)"
label var ALagLogTurnover 			"PostSNB x Log(Turnover)(T-1)"
label var ALagLogSDReturn			"PostSNB x Log(RetVola)(T-1)"

label var LogMV_030					"Log(MV)(0-30)"
label var LogTurnover_030			"Log(Turnover)(0-30)"
label var LogSDReturn_030			"Log(RetVola)(0-30)"

label var ALogMV_030				"PostSNB x Log(MV)(0-30)"

label var IntSales 					"IntSales"
label var AIntSales 				"PostSNB x IntSales"
label var DisclosureRank	 		"Total_Disc"
label var ADisclosureRank			"PostSNB x Total_Disc"
label var NumberOfAnalysts	 		"Num_Analysts"
label var ANumberOfAnalysts 		"PostSNB x Num_Analysts"
label var NoshFF 					"FreeFloat"
label var ANoshFF 					"PostSNB x FreeFloat"
label var LogReportLength			"Log(Report Length)"
label var ALogReportLength			"PostSNB x Log(Report Length)"
label var HistCorrEur_R				"Hist_Corr_EUR"
label var AHistCorrEur_R			"PostSNB x Hist_Corr_EUR"

label var LogReturn 				"LogReturn"
label var ALogReturn				"PostSNB x LogReturn"
label var LogPXLast					"Log(Price)"

label var InternationalStandards	"Int_Standards"
label var AInternationalStandards	"PostSNB x Int_Standards"

* Longer-Term Post-Variables
label var Post1 				"Post(0,2)"
label var Post2 				"Post(3,10)"
label var Post3 				"Post(11,20)"

label var Post1_RiskDisc		"Post(0,2) x RiskDisclosure"
label var Post2_RiskDisc		"Post(3,10) x RiskDisclosure"
label var Post3_RiskDisc		"Post(11,20) x RiskDisclosure"

* Triple Interactions
label var ALogEPS_Revision 					"Post_SNB x Log(1+EPS_Revision)"
label var ALogNews_SNB 						"Post_SNB x Log(1+News)"
label var ALogTotalNewInfo  				"Post_SNB x Log(1+Combined)"
label var Triple_RiskDisc_LogEPS_Revision 	"Post_SNB x FXRisk_Disc x Log(1+EPS_Revision)"
label var Triple_RiskDisc_LogNews_SNB 		"Post_SNB x FXRisk_Disc x Log(1+News)"
label var Triple_RiskDisc_LogTotalNewInfo 	"Post_SNB x FXRisk_Disc x Log(1+Combined)"

* Risk MGMT Variables
label var ChiefRisk 			"ChiefRisk"
label var AChiefRisk 			"PostSNB x ChiefRisk"

label var RiskCommittee 		"RiskCommittee"
label var ARiskCommittee 		"PostSNB x RiskCommittee"

label var RiskMGMTPerPage 		"RiskMGMT/#Page"
label var ARiskMGMTPerPage 		"PostSNB x RiskMGMT/#Page"

label var LogRiskLinkedin 		"Log(#Risk Employees)"
label var ALogRiskLinkedin 		"PostSNB x Log(#Risk Employees)"

* Hedging Variables
label var HedgingPerPage 		"Hedging/#Page"
label var AHedgingPerPage 		"PostSNB x Hedging/#Page"

label var LogHedgeKeyLinkedin 	"Log(#Hedging Employees)"
label var ALogHedgeKeyLinkedin 	"PostSNB x Log(#Hedging Employees)"

label var EconHedgeYes 			"Economic_Hedge"
label var AEconHedgeYes 		"PostSNB x Economic_Hedge"

* IR Variables
label var IR_Club 				"IR_Club"
label var AIR_Club 				"PostSNB x IR_Club"

label var Lead_IR 				"Lead_IR"
label var ALead_IR 				"PostSNB x Lead_IR"

label var Log_IR_Linkedin 		"Log(#IR Employees)"
label var ALog_IR_Linkedin 		"PostSNB x Log(#IR Employees)"

* Other IR Varibales
label var AFirstWeek 			"Post_SNB x First_Week"
label var AImportantPrivate		"Post_SNB x Private_Comm"
clear all
version 13.1
capture log close
capture log off

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\" // Contains 4 folders: 1_Sources, 2_Code, 3_Datasets, 4_Output

***********************************************
*********** Define Global Variables ***********
***********************************************

global LOG_FILE_YES_NO = "YES"

***********************************************
**************** Run Codes ********************
***********************************************

**** Pass on Log File Options to Do-Files ******

if "${LOG_FILE_YES_NO}" == "YES" {
		global LOG_FILE_OPTION = ""
	 	log using "${STANDARD_FOLDER}\4_Output\LogFile\ResultLog", replace smcl
}
else { 
	global LOG_FILE_OPTION = "capture log off"

}

*************** Import Data *******************

do "${STANDARD_FOLDER}\2_Code\01_Import_Bloomberg"
do "${STANDARD_FOLDER}\2_Code\02_Import_HandCollected"
do "${STANDARD_FOLDER}\2_Code\03_Import_DatastreamIBES"
do "${STANDARD_FOLDER}\2_Code\04_Import_Various"
do "${STANDARD_FOLDER}\2_Code\05_Import_Sell_Side_Analyst_Survey" 	// code also contains analyses related to the analyst survey
do "${STANDARD_FOLDER}\2_Code\06_Import_IR_Survey"				 	// code also contains analyses related to the IR survey

********** Connect and Prepare Data ************

do "${STANDARD_FOLDER}\2_Code\10_Merge_Datafiles"
do "${STANDARD_FOLDER}\2_Code\11_Preparation_Main_Variables"

*****************Make Analyses ****************

do "${STANDARD_FOLDER}\2_Code\20_Main_Archival_Analysis"


// the 90_* and 91_* do-files are included in one of the other do-files

if "${LOG_FILE_YES_NO}" == "YES" {
	log close _all
}


exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

* 1. IntradayBar Data from Bloomberg via the Bloomberg excel tool:
/* Miniute-by-minute ask, bid and trade prices as well as corresponding volumes. Due to data download limitations of Bloomberg as well as technical limitations of the terminal itself, 
the downloads were conducted on three different occasions (Part1, Part2, Part 3):

Part 1 covers the data from August 4, 2014 until February 16, 2015 	(Downloaded on February 16, 2015)
Part 2 covers the data from February 16, 2015 until March 31, 2015 	(Downloaded on April 1, 2015)
Part 3 covers the data from March 2, 2015 until May 31, 2015 		(Downloaded on May 31, 2015)

These three parts are overlapping in terms of dates, which was intentional to verify the completeness of the time series and to ensure that stock splits etc. are not disrupting the time series for certain firms.
Bid Prices, Ask Prices and Trade Prices (as well as corresponding volumes) are all saved in separate folders ("Ask", "Bid" and "Trade").
The data for each firm ticker is a separate Excel workfile within each folder. 
In total 3 (ask, bid, trade) * 3 (part1, part2, part3) *241 (ticker symbols) = 2,169 excel files need to be imported */

* 2. Trading Days calendar (Downloaded April 16, 2015): 
/* Excel file that contains all days and indicates whether they are trading days (=1) or not (=0; e.g. Saturdays and Sundays).
Manually transcribed from SIX Exchange Trading Calendar ("Trading Calendar 2015", "Trading Calendar 2014"). */

local TRADING_FILE = "TradingDays.dta"

*3. Market Value Data from Bloomberg via the Bloomberg excel tool (Downloaded on November 10, 2015):
/* Daily Market Value Data. Compared to the intraday data (which was downloaded on an earlier date), two ticker symbols changed. 
These two ticker symbols are replaced later in the code below*/

local MV_FILE "AllMvMvcSharesAllNoTwoTickerChangesCopy.xlsx"

*** OUTPUT:

local SAVEFILE_MV_DAILY 	= "BloombergMVShares.dta"
local SAVEFILE_BLOOM_MERGE 	= "BloombergMerge.dta"
local SAVEFILE_PX_LAST 		= "PXLastIntraday.dta"
local ROLLINGVOL 			= "IntradayRollingWindow.dta"

*********************************************************************
*********************************************************************
***************I. Import Bloomberg Intraday Data ********************
*********************************************************************
*********************************************************************

***********************************************
********* Import Actual Excel files ***********
***********************************************

capture cd ${STANDARD_FOLDER}


scalar MAXLOOP = 242 // SSIP with 241 firms (still contains 4 duplicate tickers); 242 instead of 241 since Sheet 1 just lists firm tickers (hence, not included in loop below)

foreach PART in Part1 Part2 Part3 {
	foreach TYPE in Trade Bid Ask {
	
* Loop through folders (Parts and Type of Quotes/Trades)

		forvalues i=`=scalar(MAXLOOP)'(-1)2 {
		
			qui cd "${STANDARD_FOLDER}\1_Sources\IntradayBar-`PART'"
			qui cd "`TYPE'\AllSheets"
	
* Capture the Company name (Bloomberg ID) from cell A1
	
			import excel using Sheet`i'`TYPE'.xlsx, ///
			sheet(Sheet`i') cellrange(A1:A1) clear 
			local COMPANY = A[1]    					// local macro with company name

* Get data from the beginning of A3

			import excel using Sheet`i'`TYPE'.xlsx, ///
			sheet(Sheet`i')  cellrange(A3) firstrow case(lower) clear
			
			if missing(last_price[_n]) { 				// do not import if N/A N/A in first line (then there is a missing value in last price column)
			}
	
			else {
	
* Add Company Name (main identifier)

				generate company = "`COMPANY'"
				generate id = `i'-1 

* Adjustments for rounding, deleting missing Bloomberg data and adjusting Var name*/

				replace date = round(date,1000) 			// round data (bc Stata <-> excel mismatch)
				recast double open high low last_price value
				recast long number_ticks volume
				recast str15 company
	
* Rename vars

				rename id ID
				rename company Company
				rename date DateTime
				rename open Open
				rename high High
				rename low Low
				rename last_price LastPrice
				rename number_ticks NumberTicks
				rename volume Volume
				rename value Value
				foreach var of varlist Open High Low LastPrice NumberTicks Volume Value {
					rename `var' `var'`TYPE'
				}

// Append and save data

				if `i'== `=scalar(MAXLOOP)' {
					qui cd "${STANDARD_FOLDER}\3_Datasets"
					save Swiss`TYPE'`PART', replace
				}
				else {
					qui cd "${STANDARD_FOLDER}\3_Datasets"
					append using Swiss`TYPE'`PART'.dta
					save Swiss`TYPE'`PART', replace
				}
			}
	}

		order ID Company
		sort ID DateTime

		qui cd "${STANDARD_FOLDER}\3_Datasets"
		save Swiss`TYPE'`PART', replace

			
	}
}

************************************************
***** Merge Part Files into One File Each ******
************************************************

foreach TYPE in Trade Bid Ask {
	
	qui cd "${STANDARD_FOLDER}\3_Datasets"
	use "Swiss`TYPE'Part1"
	forvalues j = 2/3 {
	
		append using Swiss`TYPE'Part`j'.dta
		sort ID DateTime
		save `TYPE'All, replace
		
	}

	sort ID DateTime
	quietly by ID DateTime: gen dup = cond(_N==1,0,_n)
	tabulate dup
	drop if dup == 2 					// Remove duplicate dates. Duplicates occur since the data was downloaded in three parts with overlapping date intervals (to ensure completeness of the data)
	drop dup	
	
	
	save `TYPE'All, replace

}
foreach TYPE in Trade Bid Ask {
	forvalues j = 1/3 {
		erase Swiss`TYPE'Part`j'.dta
	}
}
***********************************************
************* Clean DataSet Pre Merge *********
***********************************************

cd "${STANDARD_FOLDER}\3_Datasets"

* Various Adjustments
* Here: For 04aug2014 there is one second added too much in excel --> therefore remove this second

foreach DATASET in Trade Bid Ask {

	use `DATASET'All.dta
	
	gen second = ss(DateTime)
	noisily replace DateTime = DateTime - 1000 if second > 0 // for August 4th in bid and ask, seconds are too high (by 1000)
	sort ID DateTime
	by ID DateTime: gen dup = cond(_N==1,0,_n)
	noisily tabulate dup
	drop second dup

* 0 prices or volume are irrelevant or wrong --> drop them
	drop if LastPrice`DATASET' 	== 0
	drop if Volume`DATASET' 	== 0

*Delete useless variables
	drop High`DATASET'
	drop Low`DATASET'
	drop Open`DATASET'

*Rename and make indicator variable to determine whether data was in original data set

	gen Active`DATASET' = 1

*Define all date/time variables needed for the analysis

	generate Date = dofc(DateTime)
	format Date %td 																// Real Date variable

	gen time = hh(DateTime) + mm(DateTime)/60 + ss(DateTime)/3600 					// Time variable

	qui count if ID > 241															// Verify that only 241 SSIP tickers were downloaded.
	assert r(N) == 0 														

	scalar TIMESTART = 9 + 0.1/60 													// i.e. everything deleted before 9.01
	scalar TIMEEND = 17 + 31/60 													// i.e. everything deleted after 17.30

	drop if time < TIMESTART | time > TIMEEND
	
	sort ID DateTime
	save `DATASET'AllManip.dta, replace


}
	erase BidAll.dta
	erase AskAll.dta

***********************************************
************* TSFill for Trade-Dataset ********
***********************************************

use TradeAllManip.dta, replace

* Set to panel data set and fill in gaps

xtset ID DateTime, delta(1 min)
tsfill, full

* Calculate Time & Date Variables for filled data

replace Date = dofc(DateTime)										// Date variable
format Date %td 													// Date variable
replace time = hh(DateTime) + mm(DateTime)/60 + ss(DateTime)/3600 	// Time variable

* Add TradingDays Variable for deletion of irrelevant days

merge m:1 Date using "${STANDARD_FOLDER}\1_Sources\Other\\`TRADING_FILE'", assert(match)
drop if _merge == 2
drop _merge

sort ID DateTime

* Drop if outside trading days or outside trading hours (before 9am [i.e. start with 9.01] or after 5.30pm [i.e. end with 17.31])

drop if tradingdays == 0
drop tradingdays
drop if time < TIMESTART | time > TIMEEND							// Have to do it here  again, because of tsfill
drop time

replace ActiveTrade = 0 if missing(ActiveTrade)

xtset ID DateTime, delta(1 min)

************************************************
******* Merge Ask, Bid and Trades Files ********
************************************************

* Merge files into filled trade dataset

merge 1:1 ID DateTime using BidAllManip.dta, assert(match master)
	gen merge1 = _merge
	drop _merge
	sort ID DateTime

merge 1:1 ID DateTime using AskAllManip.dta, assert(match master)
	gen merge2 = _merge
	drop _merge
	sort ID DateTime


* Prepare everything or variable creation; drop merge variables and set data set correctly
sum merge1, detail
sum merge2, detail
drop merge1
drop merge2

xtset ID DateTime, delta(1 min) 			//reset to balanced panel

* Label variables in data set

label var ID 				"Unique company identifier (xtset)"
label var Company 			"Company name"
label var DateTime 			"Date&Time for obs (xtset)"
label var LastPriceTrade 	"Last Trading Price in this minute"
label var NumberTicksTrade 	"Ticks traded in this minute"
label var VolumeTrade 		"Volume traded in this minute"
label var ValueTrade 		"Value traded (lastPrice*volume)"
label var ActiveTrade 		"non-missing trading obs"
label var Date 				"Date without time"
label var LastPriceAsk 		"Last Ask Price in this minute"
label var NumberTicksAsk 	"Ask Ticks in this minute"
label var VolumeAsk 		"Ask volume in this minute"
label var ValueAsk 			"Ask Value (lastPrice*volume)"
label var ActiveAsk 		"non-missing Ask obs"
label var LastPriceBid 		"Last Bid Price in this minute"
label var NumberTicksBid 	"Bid Ticks in this minute"
label var VolumeBid 		"Bid volume in this minute"
label var ValueBid 			"Bid Value (lastPrice*volume)"
label var ActiveBid 		"non-missing Bid obs"

order ID Company DateTime Date
sort ID DateTime

save FullMerge, replace

cd "${STANDARD_FOLDER}\3_Datasets"
	
erase TradeAllManip.dta
erase BidAllManip.dta
erase AskAllManip.dta
	
*********************************************************************
*********************************************************************
**************II. Import Daily Market Value Data ********************
*********************************************************************
*********************************************************************

tempfile AllNo

local ATTACHMENT = "AllNo" // This refers to the Bloomberg download options. "No" was selected for all options.
local SAVENAME "`AllNo'"

cd "${STANDARD_FOLDER}\1_Sources\Other-Bloomberg"
qui import excel  `MV_FILE', describe

forvalues i=`r(N_worksheet)'(-1)2 {
	cd "${STANDARD_FOLDER}\1_Sources\Other-Bloomberg"

*Capture the company name from cell A1

	import excel using `MV_FILE', sheet(Sheet`i') ///
	cellrange(A1:A1) clear 
	local COMPANY = A[1]   					 		// local macro with company name

*Get data from the beginning of A2

	import excel using `MV_FILE', sheet(Sheet`i') ///
		cellrange(A2) firstrow case(lower) clear

	if missing(cur_mkt_cap) { 				// do not import if N/A N/A in first line
	
	}

	else {
		rename date Date
		generate Company = "`COMPANY'"
		recast str15 Company
		generate id = `i'-1
	
		rename cur_mkt_cap MVCBloom`ATTACHMENT'
		rename eqy_sh_out NoShares`ATTACHMENT'
		rename current_market_cap_share_class MVBloom`ATTACHMENT'
		rename bs_sh_out EndNoShares`ATTACHMENT'
	
		tostring MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT', replace force
	
		foreach var of varlist MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT' {
			replace `var' = "" if `var' == "#N/A N/A"
		}

		destring MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT', replace
		recast double MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT'

		if `i'== 274 { 						// 274, because firm 275 is missing (download was made also for non-SSIP firms; hence n > 241)
			cd "${STANDARD_FOLDER}\3_Datasets"
			save `SAVENAME', replace

		}

		else {
			cd "${STANDARD_FOLDER}\3_Datasets"
			append using `SAVENAME'
			save `SAVENAME', replace
		}
	}
}

order id Company
sort id Date

replace Company = "HOLN VX Equity" if Company == "LHN VX Equity" 	// because of Ticker change from HOLN to LHN. To match with older dataset, ticker needs to be updated
replace Company = "KABN SE Equity" if Company == "DOKA SW Equity" 	// because of Ticker change from KABN to DOKA. To match with older dataset, ticker needs to be updated

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE_MV_DAILY', replace

*********************************************************************
*********************************************************************
************ III. Create Main Dataset for 10_Merge  *****************
*********************************************************************
*********************************************************************


********************************************
*********** Generate Key Variables *********
********************************************
cd "${STANDARD_FOLDER}\3_Datasets"
use FullMerge, replace 													// starts with balanced panel

* Merge with daily market values
merge m:1 Company Date using "`SAVEFILE_MV_DAILY'", keepusing(MVBloomAllNo) assert(match master using) // Market values are only needed for the weighted effective spreads calculation
drop if _merge == 2
drop _merge
compress

* Generate time-related variables
drop time
gen Hour 	= hh(DateTime)
gen Minute 	= mm(DateTime)
gen Weekday = dow(Date)
gen Week 	= week(Date)
gen HourMin = Hour*100+Min

drop if Hour == 17 & Minute == 31								// This is done to obtain 510 observations before collapse (i.e., can be divided by 30)

preserve
	keep if ID == 1
	bys Date: count
	assert `r(N)' == 510
restore

* Generate 30 minutes intraday time period (MINUTESGROUP=30)
sort ID DateTime

scalar MINUTESGROUP = 30 										// Here define how many values should be grouped together for the intraday analyses. 30min == 30

count if ID == 1 												// Assumption, all IDs have same length _N, i.e. balanced panel; asserted above
scalar MAX = r(N)/MINUTESGROUP 									// Assumption, all IDs have same length _N, i.e. balanced panel; asserted above

* Routine to verify that MAX is an integer
assert mod(`=scalar(MAX)',1) == 0

sort ID DateTime
by ID: gen number = _n - 1  + MINUTESGROUP 						// i.e. first observation equals scalar MINUTESGROUP
by ID: gen indicator = int(number/MINUTESGROUP) 				// i.e. divide by MINUTESGROUP and take integer
drop number

* Drop opening and closing auction
drop if Hour == 17 	& Minute >= 20								// Closing auction starts at 17.20								
drop if Hour == 9	& Minute <= 2								// Opening auction ends at 09.02 at the latest


********************************************
*********** Fill-up variables **************
********************************************

sort ID DateTime
foreach x of varlist Company {
	by ID: replace `x' = `x'[_n-1] 		if missing(`x')
}

gsort +ID -DateTime
foreach x of varlist Company {
	by ID: replace `x' = `x'[_n-1] 		if missing(`x')
}

* Calculate Staleness of Bid-Ask Spread for untabulated robustness test (Part 1)

gen SameAsk = missing(LastPriceAsk)
gen SameBid = missing(LastPriceBid)

sort ID DateTime
sort ID Date HourMin
by ID Date: replace SameAsk = SameAsk[_n-1] + 1 if missing(LastPriceAsk)
by ID Date: replace SameBid = SameBid[_n-1] + 1 if missing(LastPriceBid)
gen RelativeStale = abs(SameAsk - SameBid)

*Like McInish carry quotes forward within a day, but not across dates

sort ID DateTime
sort ID Date HourMin
foreach x of varlist LastPrice* {
	by ID Date: replace `x' = `x'[_n-1] if missing(`x') 		// Assumption: lastPrice is still lastPrice on the very same day (i.e. intraday)
}

* replace missing volumes by 0
foreach y of varlist Active* NumberTicks* Volume* Value*{
	replace `y' = 0 if missing(`y')
}

*Generate dummy variable as Post indicator
generate AfterSNB = cond(DateTime>tc(15-jan-2015 10:30),1,0)

****************************************************
*********** Calculate Bid-Ask Spreads **************
****************************************************

* Calculate minute-by-minute spreads
gen BidAskSpreadMinute = (LastPriceAsk-LastPriceBid)/(LastPriceAsk+LastPriceBid)*200 if (LastPriceAsk-LastPriceBid) >= 0 // * 100 for readability in descriptive table

* Calculate minute-by-minute effective spreads
gen Midpoint 			= (LastPriceAsk+LastPriceBid)/2

gen EffSpread_No_W 		= abs(LastPriceTrade - Midpoint)*2 if NumberTicksTrade > 0
gen EffSpread_W_M		= abs(LastPriceTrade - Midpoint)*2*(ValueTrade/MVBloomAllNo) if NumberTicksTrade > 0

drop MVBloomAllNo

sort ID Date HourMin

*Calculate spreads in 30 min intervals (for intraday analysis)
sort ID indicator
by ID: assert DateTime[_n] > DateTime[_n-1] if _n > 1 // Assert that sorting is correct

by ID indicator: egen MeanTimeBidAskSpread = mean(BidAskSpreadMinute) 

*Calculate daily spreads (for daily analyses)
sort ID Date HourMin
by ID Date: egen MeanDateBidAskSpread = mean(BidAskSpreadMinute)
by ID Date: egen MeanDateEffSpread_No_W = mean(EffSpread_No_W)
by ID Date: egen MeanDateEffSpread_W_M 	= mean(EffSpread_W_M)

* Calculate Staleness of bid-ask spread (Part 2)--> Create Staleness indicator for untabulated robustness test
sort ID Date HourMin
by ID Date: egen MeanRelativeStale 	= mean(RelativeStale)


drop BidAskSpreadMinute EffSpread_No_W EffSpread_W_M

* Aggregate Trading Volumes within each 30 minute interval
sort ID Date HourMin
sort ID indicator
by ID: assert DateTime[_n] > DateTime[_n-1] if _n > 1 // Assert that sorting is correct

foreach x of varlist Value* Volume* NumberTicks* Active* {
	by ID indicator: replace `x' = sum(`x') 			
}

* Only keep the last observation for each 30 minute interval
by ID indicator: keep if _n ==_N

drop indicator

xtset ID DateTime

************************************************************
*** Remove firms that are duplicates or too illiquid *******
************************************************************

sort ID DateTime

drop if Date<td(01oct2014)
drop if Date>td(30apr2015)

*Drop duplicate firms

drop if Company == "SCHN SE Equity" 				// ID = 181 SCHN SE (because duplicate with ID 182 SCHP VX and less liquid stock)
drop if Company == "UHRN SE Equity" 				// ID = 219 UHRN SE (because duplicate with ID 218 UHR VX and less liquid stock)
drop if Company == "LISN SE Equity" 				// ID = 125 LISN SE (because duplicate with ID 126 LISP SE and less liquid stock)
drop if Company == "RO SE Equity" 					// ID = 175 RO SE (because duplicate with ID 176 ROG VX and less liquid stock)

*Table 1 Line 1: Initial Sample
preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 237
restore

* Verify that data is a valid&balanced panel
sort ID Date
xtdescribe
assert `r(min)' == `r(max)' 											// Same number of observations

*Delete observations with insufficient number of trades
distinct Date
scalar NumberDay = `r(ndistinct)'

bys ID: egen TRADES = sum(NumberTicksTrade) 
keep if TRADES 		> scalar(NumberDay)*10								// Requirement: At least 10 trades per Day

*Table 1 Line 2: Removed 63 firms due to insufficient trades

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 174
restore

distinct HourMin
scalar TimeSlots = `r(ndistinct)'

*Delete observations with too few updated bid-ask-spreads

gen missingBS = missing(MeanDateBidAskSpread)				
bys ID: egen FirmMissingBS = sum(missingBS)
drop if FirmMissingBS > scalar(TimeSlots)*3							// Requirement: Updated BidAskSpread on 141 of 144 days (i.e., drop if at least 3 missings)

drop TRADES FirmMissingBS FirmMissingBS

*Table 1 Line 3: Removed 15 firms due to insufficient bid-ask spreads

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 159
restore

************************************************
*********** Carry-forward Prices  **************
************************************************

sort ID DateTime
foreach x of varlist LastPriceTrade { 								// Carry Trade-Prices (but not bid or ask prices) over night
	by ID: replace `x' = `x'[_n-1] if missing(`x')
}


************************************************
*********** Save File for 10_Merge  ************
************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE_BLOOM_MERGE', replace

*********************************************************************
*********************************************************************
************ IV. Create Other Datasets for 10_Merge  ****************
*********************************************************************
*********************************************************************

********************************************
* Generate End-of-Day Prices for each Date *
********************************************

use TradeAll.dta, replace // For end-of-day prices, the last valid price is needed (i.e., including closing auction if applicable)

gen Hour 	= hh(DateTime)
gen Minute 	= mm(DateTime)

gen HourMin = Hour*100+Min
gen Date 	= dofc(DateTime)
format %td Date

sort ID Date DateTime
count if missing(LastPriceTrade)
	assert `r(N)' == 0 // Ensures that last value on a day is not missing

by ID Date: keep if _n == _N // keep last price per day

drop DateTime

xtset ID Date, delta(1 day)
	tsfill, full

by ID: replace LastPriceTrade = LastPriceTrade[_n-1] if missing(LastPriceTrade) // because of tsfill
by ID: gen BeforePXLast = LastPriceTrade[_n-1] // carry forward prices if no share price at a given day (only relevant for the first day of the panel)

keep ID Date LastPriceTrade BeforePXLast

rename LastPriceTrade PXLast // Price at the end of the day for each day

save `SAVEFILE_PX_LAST', replace
erase TradeAll.dta

******************************************************
******* Generate Rolling Return Volatility for *******
****************** Intrady Analyses ******************
******************************************************
cd "${STANDARD_FOLDER}\3_Datasets"
										
use `SAVEFILE_BLOOM_MERGE', replace											// starts with balanced panel
sort ID DateTime 

* Conduct consistency checks

qui xtset ID DateTime
xtdescribe

assert `r(N)' == 159													// Sample is correct, final sample is 151 observations; but here 159 because based on  BloombergMerge file (and not after further sample filters in 10_Merge_Datafiles)
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum Date, detail
local MINDATE = `r(min)'

qui sum ID, detail
local MINID =`r(min)'

count if Date == `MINDATE' & ID == `MINID'

scalar INTRADAYOBS = `r(N)'												// Set number of Intraday observations for changes

assert scalar(INTRADAYOBS) == 17										


sum ID if HourMin <= 1030 & Date == `MINDATE' & ID == `MINID', detail
assert `r(N)' == 3
global UNTIL1030 = `r(N)'

keep ID DateTime LastPriceTrade

*Generate Logarithmic Returns
sort ID DateTime 
by ID: 	gen LogReturn = log(LastPriceTrade/LastPriceTrade[_n-1])		 
	replace LogReturn 	= 0 if missing(LogReturn)						//  Only needs to be replaced for Oct 1 (actually irrelevant since not part of the estimation window)

* Generate Rolling SD
sort ID DateTime
by ID: gen CONT = _n
xtset ID CONT 			// necessary for rollstat command
rollstat LogReturn, statistic(sd) w(`=scalar(INTRADAYOBS)')
drop CONT

xtset ID DateTime
sort ID DateTime
by ID: gen SDRolling= _sd17_LogReturn


drop _sd17_LogReturn

cd "${STANDARD_FOLDER}\3_Datasets"

save `ROLLINGVOL', replace
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Hand-Collected data based on firms' annual report 2013 (Downloaded reports in April and May 2015):
/*Excel file that contains the hand collected data based on firms most recent annual report before Jan 15, 2015.
This Excel file contains three main variables that were manually collected and coded:  Risk Disclosure (Score from 1 to 7),  IntSales (from 0 to 1) and ReportLength (# Pages). 
It also contains the sub-scores of the Risk Disclosure score (for IA Table A3) */

local REPORT_HAND_COLLECTED = "HandCollected_Report_Data.xlsx"

*** OUTPUT:

local SAVEFILE1 = "ReportData.dta"

***********************************************
************* Import Excel File ***************
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel `REPORT_HAND_COLLECTED', sheet("Data") cellrange(A2:AT244) firstrow

rename BloombergCode Company
keep if Include == 1 // Variable that shows whether the firm is in the final sample or not (drop step is not necessary, but allows to use perfect match assert command in 10_Merge file)
destring IntSales, replace

keep Company RiskDisclosure Revenues2013 Assets2013 CostsProfits2013 Monetary2013 FXExposure2013 Hedging2013 FXSensitivity2013 IntSales ReportLength

drop if missing(Company)

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace


exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}


***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

*** INPUT:

*1. Datastream/Worldscope File (Various download dates depending on variables, see Datasheet):
/*File that contains the Datastream & Worldscope data via the Datastream Request Table in Excel. 
Each Variable is contained in a separate worksheet.  */

local DS_WORLDSCOPE = "SwissFrancRequestTable_DS.xlsx"


*2. Swiss Disclosure Ranking 2014 from the Swiss Finance Institute (i.e., scoring for 2013 annual reports) (Downloaded on June 22, 2015):
/*Ranking from https://www.bf.uzh.ch/en/research/studies/value-reporting.html. Names are manually matched to Bloomberg Codes. 
Additionally, the Datastream and IBES identifiers are also manually matched to these firms and added to this file (i.e., also functions
as a linking table between Bloomberg and Datastream)   */

local DISC_RANKING = "Ranking_DS_Bloomberg_Match_Data.xlsx"

*3. IBES Weekly Coverage Data (Downloaded on August 20, 2015):
/*Weekly IBES data, which is used to compute analyst following. Data was downloaded via Thomson Reuters Spreadsheet Link 
and hence the downloaded data is contained in an excel file.*/

local IBES_SPREADSHEET = "IBES_Swiss_Weekly_IBES_COPY.xlsx"

*4. Datastream Download of Exchange Rates and Total Return Index (Downloaded on June 8, 2017):
/*Downloaded via Datastream Request Table in Excel. Used to calculate correlations between stock returns and changes in foreign exchange rates.*/

local DS_FX_TRI = "FX-TRI-Datastream.xlsx"

	
*** OUTPUT:

local SAVEFILE = "Datastream_IBES_Final.dta"

***********************************************
***** Import non-market variables from DS *****
***********************************************

tempfile SwissDatastream

cd "${STANDARD_FOLDER}\1_Sources\Datastream"

* Import Excel File with data
qui import excel using `DS_WORLDSCOPE', describe
scalar MAXLOOP = `r(N_worksheet)'-1 // Adjustment -1 because of RequestTable

forvalues i=`=scalar(MAXLOOP)'(-1)1 {
	if `i' == 1 {
	
		cd "${STANDARD_FOLDER}\1_Sources\Datastream"
		
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i')  cellrange(A1) firstrow allstring case(lower) clear
		
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
		}
		
		gen idx = _n 										// idx_is internal merge code
		
	}	
	else {
	
		cd "${STANDARD_FOLDER}\1_Sources\Datastream"
	
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i') cellrange(A5:A5) clear
		local TEMPORARY = A[1]
		local ADD = lower(strtoname(substr("`TEMPORARY'",11,27)))
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i')  cellrange(B4) allstring firstrow case(lower) clear
		
		* Extract names and label
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
			destring `var', replace float
			local label : variable label `var'
			local new_name = lower("`label'")
			rename `var' `ADD'`new_name'
		}
		
		gen idx = _n 										// idx_is internal merge code
		reshape long "`ADD'", i(idx) j(year)
	}
	if `i'== `=scalar(MAXLOOP)' {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		save `SwissDatastream', replace
		
  }
	else if `i' == 1 {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:m idx using `SwissDatastream', assert(match)
		drop _merge
  }
	else {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:1 idx year using `SwissDatastream', assert(match)
	
		drop _merge
		
		save `SwissDatastream', replace
  }
}

order dscd idx name year
drop if missing(dscd)
rename dscd Type

* Save Datastream & Worldscope
cd "${STANDARD_FOLDER}\3_Datasets"
save `SwissDatastream', replace

*******************************************************
**** Historical Correlations Swiss-EUR and Swiss-USD **
*******************************************************

tempfile HistCorr

cd "${STANDARD_FOLDER}\1_Sources\Datastream"

* Import exchange rate from excel worksheet
import excel `DS_FX_TRI', sheet("Sheet2") cellrange(A2:C2613) firstrow clear

save `HistCorr'.dta, replace

* Import firms' total return indices from same excel worksheet
import excel `DS_FX_TRI', sheet("Sheet1") firstrow clear
drop if _n == 1
foreach var of varlist _all {
	replace `var' = "" if `var'== "NA"
	destring `var', replace
	}
	
generate Code = date(Name, "MDY")
drop Name
format Code %td
order Code

cd "${STANDARD_FOLDER}\3_Datasets"

* Merge both files (TRI and exchange rates)
merge 1:1 Code using `HistCorr'.dta
drop _merge
order Code SWEURSPER SWISSFER 
rename Code Date

* Calculate correlations on a weekly basis (weekly instead of daily correlations) to reduce the liquidity impact
gen DateWeek = wofd(Date)
sort DateWeek Date			
order DateWeek, after(Date)
format DateWeek %tw

foreach var of varlist SWISSFER SWEURSPER ABBLTDN-ZWAHLENMAYR  {
	by DateWeek: gen B_`var' = `var'[1]
	by DateWeek: gen E_`var' = `var'[_N]

}

by DateWeek: keep if _n == 1

* Calculate weekly changes of exchange rates and return indices
foreach var of varlist SWEURSPER SWISSFER ABBLTDN-ZWAHLENMAYR {
	gen ret_`var' = log(E_`var'/B_`var')
	}

* Calculate correlations for EUR before minimum exchange rate regime and USD during minimum exchange rate regime
local i = 0
foreach var of varlist ret_ABBLTDN-ret_ZWAHLENMAYR {
	local i = `i' + 1

* Calculate USD and firms' return correlation
	qui sum `var' if Date<td(15jan2015) & Date >= td(15jan2012), detail // Covering Period during Minimum Exchange Rate Regime
	
	if r(N) == 0 {	
		scalar USD_`i' = .
	}
	
	else {
		qui corr ret_SWISSFER `var' if Date<td(15jan2015) & Date >= td(15jan2012) // Covering Period during Minimum Exchange Rate Regime
		scalar USD_`i' = r(rho)
	}

* Calculate EUR and firms' return correlation
	qui sum `var' if Date<td(6sep2011) & Date >= td(6sep2008), detail // Covering Period before Minimum Exchange Rate Regime
	
	if r(N) == 0 {		
		scalar EUR_`i' = .
	}
	
	else {
		qui corr ret_SWEURSPER `var' if Date<td(6sep2011) & Date >= td(6sep2008) // Covering Period before Minimum Exchange Rate Regime
		scalar EUR_`i' = r(rho)
	}
}
qui d
global OBS = (r(k) - 2)/4  - 2 
assert ${OBS} == 241

* Generate dataset that contains both correlations
clear
set obs 241
generate idx = _n
generate HistCorrEUR = 0
generate HistCorrUSD = 0


foreach x of numlist 1/241 {
	replace HistCorrEUR = EUR_`x' if _n == `x'
	replace HistCorrUSD = USD_`x' if _n == `x'

}

save `HistCorr', replace

*******************************************************
************** Import Ranking File ********************
**** (also contains the manually linked Bloomberg *****
*********** & Datastream Identifiers) *****************
*******************************************************

tempfile temporary

cd "${STANDARD_FOLDER}\1_Sources\Other"

* Import excel file
import excel using `DISC_RANKING', sheet(Matched)  cellrange(A2) firstrow case(lower) clear

keep type bloombergcode tonecodeshort gesamtnote
drop if missing(type)

* Rename variables
rename bloombergcode Company
rename gesamtnote DisclosureRank
rename tonecodeshort IBESMatchCode
rename type Type

cd "${STANDARD_FOLDER}\3_Datasets"
save `temporary', replace

* Merge Files
use `SwissDatastream', replace
merge m:1 Type using `temporary', assert(match)
drop _merge

merge m:1 idx using `HistCorr', assert(match)
drop _merge

sort idx year
save `SwissDatastream', replace

***************************************************
******** Clean Dataset and Rename Variables *******
***************************************************

tempfile TempDatastream

* Rename and prepare variables
rename idx IDX // IDX is not ID (which is part of the Bloomberg Dataset)
rename name DatastreamName
rename year Year
format Year %ty // change format for Panel Dataset
rename mnem Mnem
rename acur AccountingCurrency
rename wc07021 SICCode
rename isocur	ISOCurrStock
rename isin ISIN
drop ggisn
rename pcur PriceCurrency
rename wc05427 StockExchanges
rename international_sales InternationalSales
rename net_sales_or_revenues TotalSales
rename date_of_fiscal_year_end FYEnd
rename accounting_standards_follow AccountingStandards
rename __free_float_nosh NoshFF

foreach x of varlist Mnem-StockExchanges {
	replace `x' ="" if inlist(`x',"NA") // Create missing values
}

xtset IDX Year, delta(1 year)

save `SwissDatastream', replace

*Generate relevant variables
generate SIC1 = substr(SICCode,1,1)
destring SIC1, replace
generate IFRS = strpos(AccountingStandards, "IFRS") >= 1
generate USGAAP = strpos(AccountingStandards, "GAAP") >= 1
generate LocalStandards = strpos(AccountingStandards, "Local") >= 1
gen InternationalStandards = USGAAP == 1 | IFRS == 1
replace NoshFF = NoshFF/100 // (Makes variable more readable in tables)

*Replace NoshFF for a single firm. For this firm, NOSH data is only missing in this year. Thus use the 2014 data in the 2013 field for this firm
replace NoshFF = NoshFF[_n+1] if Type == "92219M" & Year == 2013

* Use data from fiscal year which is closest to Swiss Franc Shock (but precedes the Swiss Franc Shock)
gen FYE = date(FYEnd, "MDY")
drop FYEnd
rename FYE FYEnd
format FYEnd %td

keep if Year == 2013 | Year == 2014
gen MONTH = month(FYEnd)

drop if MONTH < 12 & Year == 2013
drop if MONTH == 12 & Year == 2014 

sort IDX Year
by IDX:  drop if _n == 2 // Drop year 2014 --> Yields same number of obs (no duplicates) as just drop Year 2013

save `TempDatastream', replace

********************************************
************* Import from IBES *************
********************************************

tempfile SwissIBESToMerge SwissTempIBES

* Import IBES File
cd "${STANDARD_FOLDER}\1_Sources\IBES"
qui import excel using `IBES_SPREADSHEET', describe

return list
forvalues i = 2/`r(N_worksheet)' { 
	cd "${STANDARD_FOLDER}\1_Sources\IBES"
	if `i' == 2 {

		import excel using `IBES_SPREADSHEET', sheet(`r(worksheet_`i')') cellrange(A1) allstring firstrow case(lower)  clear
		
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
		}
		
		gen idx = _n 										// idx_is internal merge code
		keep idx name tickerfordownload matchingwtr
		order idx name tickerfordownload matchingwtr
		
	}	
	
	else  {
		import excel using `IBES_SPREADSHEET', describe
		local TEMPORARY = r(worksheet_`i')
		import excel using `IBES_SPREADSHEET', sheet(`r(worksheet_`i')')  cellrange(C2)  clear
		scalar COUNTER = td(3-jan-2014) -7 										// Start Date is 3-jan-2014 according to TSL
		
		foreach var of varlist _all {
			scalar COUNTER = COUNTER + 7 										// 20091 is star
			rename `var' `TEMPORARY'`=scalar(COUNTER)'
		}
		
		gen idx = _n // idx_is internal merge code
		reshape long "`r(worksheet_`i')'", i(idx) j(week)
	}
	
	if `i'== 2 {
		cd "${STANDARD_FOLDER}\3_Datasets"
		save `SwissTempIBES', replace
	}
	
	else if `i'== 3 {
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge m:1 idx using `SwissTempIBES', assert(match)
		drop _merge
		save `SwissTempIBES', replace
	}
	
	else {
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:1 idx week using `SwissTempIBES', assert(match) // now 1:1 because of reshape
		drop _merge
		save `SwissTempIBES', replace
	}
}

format week %tdMonth_DD,_CCYY

foreach var of varlist EPSCurrencyFY2-NumberOfAnalystsFY1 {
	replace `var' = "" if `var' == "N/A"
	}

* Generate Number of analysts variable
destring NumberOfAnalystsFY1, replace
replace NumberOfAnalystsFY1 = 0 		if NumberOfAnalystsFY1 == . 				// Continuous Analyst Coverage Var
rename NumberOfAnalystsFY1 NumberOfAnalysts

cd "${STANDARD_FOLDER}\3_Datasets"

* Prepare data file for matching
order matchingwtr name
rename matchingwtr IBESMatchCode

	
save SwissTempIBES, replace

* Only keep one weekly observation
by idx: keep if _n == 54 		// this is the last observation (week) just before SNB Shock
drop idx week 					// no longer needed
	
save `SwissIBESToMerge', replace

*************************************
***** Merge IBES and Datastream *****
*************************************

use `TempDatastream', replace
	
merge 1:1 IBESMatchCode using `SwissIBESToMerge'			
	tab _merge
	keep if _merge == 3 					
	drop _merge
	
save `SAVEFILE', replace


exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Excel-File that contains Swiss ADRs (Downloaded and created in August, 2019):
/*List of Swiss Cross-Listing via Archive.org copy (December 25, 2014) of TopForeignStocks.pdf (cross-verified with adrbnymellon.com).
This list was copied in ab excel file and the ticker symbols were matched to Datastream's Type identifier (manually verified matches) */

local SWISS_ADR_EXCEL = "Swiss-ADRs.xlsx"

*2a. Excel-File that contains LinkedIn Data (Collected in September 2019):
/*Excel file that holds the manually collected LinkedIn data. Contains the numbers of hits of a LinkedIn search (i.e., number of employees) combining a certain firm name
 and an additional search query (e.g., job position that has ‘risk’ in the title). */

local LINKEDIN_DATA = "LinkedIn_DataCollection.xlsx"

*2b. Risk MGTMT Data from 2013 Annual Reports (Downloaded reports in April and May 2015):
/* Hand-Collected data from firms 2013 annual reports. Holds various variables (e.g., whether a firm has a Chief_Risk officer) related to risk management and hedging. */

local ADDITIONAL_REPORT_DATA = "Risk_Hedging_Report_DataCollection.xlsx"


*3a. IR Club indicator (Received in May 2016):
/*Excel-File that contains indicator variable whether a firm belongs to the IR Club (=1) or not (=0) 
(Information comes from our contact at the IR Club, variable is manually coded in Excel)*/

local IR_CLUB = "IRClub_Indicator"

*3b. IR Position (Collected in April and May 2016):
/*Manually collected excel file that contains, among other things, the job title of the most senior IR employee at the company. 
This data was originally collected for the investor relations survey from two main sources: firm webpages and SIX stock exchange web page.*/

local IR_POSITION = "Hand_SIX_Merge_Main_Sample"

*4a. For new information variables: IBES Detail Data (Downloaded on May 17, 2018):
/* Detailed Coverage IBES data (downloaded via WRDS at a later date compared to the Weekly Coverage Data). First IBES Codes were downloaded via Datastream (IBES-Ticker Excel file) 
and then the IBES Detail History Data for those firms was downloaded */

local IBES_CODES = "IBES_Ticker.xlsx"
local IBES_DETAIL_DATA = "Swiss_IBES_Detail_Data.dta"


*4b. For new information variables: Factiva Hand Collected File (Collected and coded from December 2019 until February 2020):
/* Excel file contains all articles that where found within the Factiva-SNB Research. Each worksheet within the excel file contains the data for one firm (each line is a different article).
Articles were read and relevant articles were coded as '1'. */
local FACTIVA_DATA = "Factiva_Hand_Collected_Files.xlsx"

*5.  SMI All Share Index and CHF-EUR Exchange Rate (Downloaded August 8, 2016): 
/* File for Figure 1 (via Datastream Download) that contains exchange rates and the Swiss All Share index  */

local ALL_SHARE_INDEX = "SMI-All-Share-CHF-EUR.xlsx"

*** OTHER INPUT FILES:
local DATASTREAM_IBES = "Datastream_IBES_Final.dta" // From 03_Import_DatastreamIBES.do
local ACTUAL_SAMPLE = "ActualSample151.dta" 		// To verify whether the sample is unchanged and OK (generated once based on the final sample)
local TRADING_FILE = "TradingDays.dta"				// Already referenced in 01_Import_Bloomberg 

*** OUTPUT:

local SAVEFILE1 = "SwissCrossListing.dta"

local SAVEFILE2 = "RiskHedgingData.dta"

local SAVEFILE3 = "IR_DataArchival.dta"

local SAVEFILE4 = "NewInformationData.dta"

local SAVEFILE5 = "SMI_AllShare_CHF_EUR.dta"

***********************************************
***********************************************
************ Import Excel Files **************
***********************************************
***********************************************

***********************************************
********* 1. Import Cross-Listings ************
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel `SWISS_ADR_EXCEL', firstrow clear
keep Type CrossListingType // Three types: 'Real':  U.S. exchange cross-listing, 'S': Sponsored ADR, 'U': Unsponsored ADR
drop if missing(Type) 

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace


***********************************************
******* 2. Import Risk MGTM, Hedging, *********
*********** Direct Communication **************
***********************************************

*** Import LinkedIn File

tempfile LINKEDIN REPORT

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel using `LINKEDIN_DATA', firstrow clear

destring investor_position, replace

keep Type NAME Inc_Linkedin-Other_comment2
drop if missing(Type) 			// Just one Empty Row


gen LogRiskLinkedin 		= log(1 + risk_position) if !missing(risk_position) 			// risk_position: Number of employees whose current job position has ‘risk’ in the title
gen LogHedgeKeyLinkedin  	= log(1 + hedging_keyword) if !missing(hedging_keyword) 		// hedging_keyword: Number of employees whose current job profile contains the term ‘hedging'
gen Log_IR_Linkedin 		= log(1 + investor_position) if !missing(investor_position)		// investor_position: Number of employees whose current job position has ‘IR’ or ‘investor relations’ in the title

save `LINKEDIN', replace

*** Import Additional Report File

import excel using `ADDITIONAL_REPORT_DATA', firstrow clear
drop if missing(Type) 

keep Type RiskCommitteeYesNo ChiefRiskYesNo RiskManagementenglishgerman Hedging NaturalOperationalHedge EconomicHedgeeconomicallyhe

* Generate Report-based variables
rename RiskManagementenglishgerman NumberofRiskManagement // Counts of how often Risk Management is mentioned in report

foreach VAR of varlist NaturalOperationalHedge EconomicHedgeeconomicallyhe {
	replace `VAR' = 0 if missing(`VAR' )
}

gen Sum_Hedge = (NaturalOperationalHedge + EconomicHedgeeconomicallyhe) // Add up how often 'natural hedging' or 'economic hedging' is mentioned in report.
gen  EconHedgeYesNo = Sum_Hedge > 0 if !missing(Sum_Hedge)			 	// Create Dummy Variable with 1: at least once mentioned, 0: Not mentioned at all.
drop Sum_Hedge EconomicHedgeeconomicallyhe NaturalOperationalHedge

gen RiskCommittee = 1 if RiskCommitteeYesNo == "Yes"
replace RiskCommittee = 0 if RiskCommitteeYesNo == "No"

gen ChiefRisk = 1 if ChiefRiskYesNo == "Yes"
replace ChiefRisk = 0 if ChiefRiskYesNo == "No"

drop RiskCommitteeYesNo ChiefRiskYesNo


save `REPORT', replace

* Merge LinkedIn and Report files
use `LINKEDIN', replace

merge 1:1 Type using `REPORT', assert(match) nogenerate

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE2', replace

***********************************************
************* 3. Import IR Data ***************
***********************************************

tempfile IRClub_Data

cd "${STANDARD_FOLDER}\1_Sources\Other"

* Import IR_Club variable
import excel using `IR_CLUB', firstrow clear

rename IRCLUB IR_Club

save `IRClub_Data', replace

* Import Lead_IR variable
import excel using `IR_POSITION', firstrow sheet("Overview") cellrange(A2) clear

tab Position
gen Lead_IR = (inlist(Position, "CCO", "CCO & IR", "Director IR", "Head of Financial Services", "Head of IR") | ///
				 inlist(Position, "Head of IR/CCO", "Leiterin Corporate Communications", "Senior IR", "VP IR")) if !missing(Position)

* Merge Files Together
merge 1:1 ID using `IRClub_Data'

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE3', replace

***********************************************
****** 4. Collect Post-Shock Info Data ********
***********************************************

***********************************************
***** 4a. Import Additional IBES Data *********
***********************************************

* Import IBES ticker
tempfile IBES_CODE_DTA IBES_FORECAST_DATA

cd "${STANDARD_FOLDER}\1_Sources\IBES"

import excel using "`IBES_CODES'", sheet(Sheet1) clear cellrange(A2) firstrow

rename IBTKR ticker // ticker is the IBES Code for the merge

cd "${STANDARD_FOLDER}\3_Datasets"

save `IBES_CODE_DTA', replace

* Import Detailed IBES data
cd "${STANDARD_FOLDER}\1_Sources\IBES"

use "`IBES_DETAIL_DATA'", replace

keep if measure == "EPS"

sort analys ticker anndats anntims

gen Hour = substr(anntims,1,2)
destring Hour, replace

gen Min = substr(anntims,4,2)
destring Min, replace

* Adjust for local Swiss time
gen ann_new = anndats
replace ann_new = anndats + 1 if (Hour >= 12 | (Hour == 11 & Min > 30)) // Adjust for local Swiss time (i.e.,  after 11.30 [5.30pm Swiss time] it only affects the next trading day)

sort analys ticker ann_new
*  Keep only one EPS Forecast per analyst covering a given firm per day
bys analys ticker ann_new: keep if _n == 1


format %td ann_new
drop if ann_new  < td(01dec2014)
drop if ann_new  > td(28feb2015)

count
* Collapse dataset to firm-day dataset
collapse (count) EPS_Revision = analys, by(ann_new ticker)

rename ann_new Date

cd "${STANDARD_FOLDER}\3_Datasets"

save `IBES_FORECAST_DATA', replace


***********************************************
********** 4b. Import Factiva Data ************
***********************************************

tempfile NEWS_SEARCH

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel using "`FACTIVA_DATA'", describe

forvalues i=1/`r(N_worksheet)' {
	local j = `j' + 1
    import excel using "`FACTIVA_DATA'", sheet(`"`r(worksheet_`i')'"') firstrow clear allstring
    save Save_Sheet`j', replace
    local z = `j'
}
use Save_Sheet1.dta
erase Save_Sheet1.dta

forvalues j=2/`z' {
	append using Save_Sheet`j'.dta
	erase Save_Sheet`j'.dta

}

drop if F == "Tensid" // This is a Newswire Service that was initially missed (and included in the Factiva search)

keep firm_name doc_date  Relevant A
destring A, replace
gen date2 = date(doc_date, "DMY")
drop doc_date
format date2 %td
rename date2 Date
rename firm_name Type

gen RelevantSNBArticle 	= 1 if Relevant == "1"

* Collapse dataset to firm-day dataset
collapse (sum) News_SNB = RelevantSNBArticle, by(Type Date)

cd "${STANDARD_FOLDER}\3_Datasets"

save `NEWS_SEARCH', replace


***********************************************
****** 4c. Combine IBES & Factiva Data ********
***********************************************
cd "${STANDARD_FOLDER}\3_Datasets"

*** Merge Files from 4a and 4b in a Panel Dataset together
use "`DATASTREAM_IBES'", replace

keep Company ID Type ISIN
duplicates drop // Only one observation per firm (i.e., 151 firms)

* Ensure that only the 151 final sample firms are in the sample
merge 1:1 Company using "${STANDARD_FOLDER}\1_Sources\Verification\\`ACTUAL_SAMPLE'", assert(match master)
keep if _merge == 3
drop _merge

merge 1:1 Type using `IBES_CODE_DTA',assert(match using)
drop if _merge == 2
drop _merge

cross using  "${STANDARD_FOLDER}\1_Sources\Other\\`TRADING_FILE'"
sort ID Date

merge 1:1 ticker Date using  `IBES_FORECAST_DATA', assert(match master using)
drop if _merge == 2 
drop _merge

merge 1:1 Type Date using `NEWS_SEARCH', assert(match master)
drop if _merge == 2
drop _merge

order ID Date
drop if Date  < td(12nov2014) // The data collection for Factiva only started from 10dec2014 (but not relevant for analyses)
drop if Date  > td(12feb2015)
sum tradingdays

*** Make two minor adjustments to hand-collected
replace News_SNB = 1 if Type == "929910" & Date == td(30jan2015) // Relevant Article for one firm on January 30, which was not part of the Imported Excel-File (those two were the only two relevant articles that were missed in the excel file))
replace News_SNB = 1 if Type == "929910" & Date == td(31jan2015) // Relevant Article for one firm on January 31,which was not part of the Imported Excel-File (those two were the only two relevant articles that were missed in the excel file)


*** Carry forward non-trading day observations to trading day observations
sort ID Date
foreach VAR of varlist News_SNB EPS_Revision   {
	replace `VAR' = 0 if missing(`VAR')
	by ID: replace `VAR' = `VAR' + `VAR'[_n-1] if tradingdays[_n-1] == 0
}
drop if tradingdays == 0

*** Generate TotalNewInfo Variable

gen TotalNewInfo = News_SNB + EPS_Revision

keep ID Company Date EPS_Revision News_SNB TotalNewInfo

save `SAVEFILE4', replace



***********************************************
******* 5. Import Swiss All Share Index *******
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Datastream\"

import excel `ALL_SHARE_INDEX', sheet("Sheet1") cellrange(A5:I1721) firstrow clear
drop C E G H
rename Code Date
label var Date "Date"

rename SWIALSHRI AllShare
label var AllShare "TRI Swiss All Share"

rename SWISSMIRI SMI

rename PRIMALLRI Prime

rename SWEURSPER EURCHF
label var EURCHF "EUR-CHF Exchange Rate"

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE5', replace


exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"

capture cd ${STANDARD_FOLDER}

***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Qualtrics Output file for the analyst survey  (Downloaded from Qualtrics on June 21, 2016):
/*Results file directly exported from Qualtrics in a csv format */

local ANALYST_SURVEY = "SellSide_Analyst_Survey_Impact_of_Swiss_Franc_Shock.csv"

*** OUTPUT:

* None, all results for this survey are directly produced via code in this do-file

***********************************************
************* Import Dataset ******************
***********************************************
cd "1_Sources\Surveys"

import delimited "`ANALYST_SURVEY'", delimiter(comma) varnames(1) encoding("utf-8")

*******************************************
********* PREPARATION OF DATASET **********
*******************************************


************* Merge Analysts with covered firms ************
gen COUNT = _n
rename v5 EMail

* Removed emails for confidentiality reasons 

************* Rename and code questions ************
count
egen Random = group(dobrfl_15) in 2/`r(N)'

drop doqn93-v198 				// Drop Display Order
rename dobrfl_15 OrderQuestion8
tempvar SUBSTR
gen SUBSTR = substr(OrderQuestion8,-4,1)
replace OrderQuestion8 = SUBSTR
destring OrderQuestion8, force replace
drop v2-v4 v6-v9 				// Drop beginning info
drop n11 						// no question
drop n121_1_text n121_2_text 	// Contact data

rename v1 ResponseID
rename v10 FinishedIndicator

rename n21 Part1
rename n22 Q1
rename n23 Q2
rename n24_1 Q3
rename n25 Q4
rename n31 Part2
rename n32_1 Q5_Part1_1 // Not assessed
rename n32_2 Q5_Part1_2 // No material effect
rename n32_3 Q5_Part1_3 // Material Effect
rename n33_1 Q5_Part2_1 // Qualitative
rename n33_2 Q5_Part2_2 // Quantitative
rename n33_3 Q5_Part2_3 // Stock recommendation

forvalues i = 1/9 {

	rename n34_`i' Q6_`i'

}

rename n35 Q6_Comment
rename n36_1 Q7
/* have to rename variables here for later recodes */

rename n91 Part3_Part2
rename n101 Part4
rename n111 Demographics

forvalues i = 1/6 {
	rename n92_`i' Q10_`i' 		// Translational etc.
}

rename n93 Q11

forvalues i = 1/4 {
	rename n94_`i' Q12_`i' // 
}

rename n95 Q12_Comment

forvalues i = 4/6 { 			// Wrong coding in Qualtrics, adjust here
	local j = `i' -3
	rename n96_`i'_text Q13_Most`j'
	}
	
forvalues i = 1/3 {
	rename n97_`i'_text Q13_Least`i'
	}

forvalues i = 1/5 {
	rename n102_`i' Q14_`i'
	}

	rename n103 Q15

	rename n112_1 D1_1
	rename n112_2 D1_2
	
forvalues i = 4/15 {
	local z = `i' -1 		// Wrong coding in Qualtrics, adjust here
	rename n112_`i' D1_`z'
	}

rename n112_15_text D1_15

rename n113 D2

rename n114 D3

rename n115_1 D4

rename n116 D5

rename n117 D6

rename n117_text D6_text

rename n118 D7

rename n119 D8

rename n1110 D9

rename n122 OverallComments
	
	
egen Part3_Part1 = concat(n?1)

forvalues i = 1/9 {
	egen Q8_`i' = concat(n?2_`i')
	}

forvalues i = 1/9 {
	egen Q9_`i' = concat(n?3_x`i')
	}

egen Q9_Comment = concat(n?4)

	
drop n?1*
drop n?2*
drop n?3*
drop n?4*

gen SepQ8Q9 = "" // Needed for ordering (separating q8 and q9), needed for tests
	
order ResponseID EMail FinishedIndicator Part1 Q1 Q2 Q3 Q4 Part2 Q5* Q6* Q7 Part3_Part1 Q8* SepQ8Q9 Q9* Part3_Part2 Q10* Q11* Q12* Q13* Q14* Q15*
 
rename Q9_Comment Comment_Q9
rename Q12_Comment Comment_Q12
rename Q6_Comment Comment_Q6

replace Q14_3 = "Q14" if _n == 1 // because of error of quotation marks in label 
 
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}
  drop if _n == 1 // now drop label observation

foreach var of varlist FinishedIndicator-Q6_9 Q7-Q9_9 Part3_Part2-Q11 Q12* Q14_1-D1_14 D2-D6 D7-D9 {

	destring `var', replace
	replace `var' = . if `var' == -99
}

keep if FinishedIndicator == 1 
drop if missing(Q15) == 1
drop OverallComment 
replace Q7 = 0 if missing(Q7) // The slider's default position was at 0 %, but Qualtrics recorded a missing for those cases

****************** Rename Labels *******************

label variable 	Q1 "Importance BEFORE the shock"
label variable 	Q15 "Importance AFTER the shock"
label variable 	Q2 "Expectation about cap removal"
label define 	Q2 1 "< 3 months" 2 "3 - 6 months" 3 "6 - 12 months" 4 "12 - 24 months" 5 "> 24 months"
label values 	Q2 Q2
label var 		Q3 "% of covered firms which are affected"
label var 		Q4 "How is the typical firm affected"
label define 	Q4 1 "Very negatively" 2 "Negatively" 3 "Neutral" 4 "Positively" 5 "Very positively"
label values 	Q4 Q4
label var 		Q5_Part1_1 "% not assessed"
label var 		Q5_Part1_2 "% assessed but no material effect"
label var 		Q5_Part1_3 "% assessed and material effect"
label var 		Q5_Part2_1 "% (thereof) qualitative adjustment"
label var 		Q5_Part2_2 "% (thereof) quantitative adjustment"
label var 		Q5_Part2_3 "% (thereof) change in EF/SR"

label var Q6_1 "Clients"
label var Q6_2 "Internal departments"
label var Q6_3 "Peer pressure"
label var Q6_4 "Reputation"
label var Q6_5 "Job description"
label var Q6_6 "Availability firm info"
label var Q6_7 "Likely firm exposure"
label var Q6_8 "Firm complexity"
label var Q6_9 "Relative importance"

label var Q7 "% of firms (re-)assessed"

forvalues i = 8/9 {
	label variable Q`i'_1 "Personal knowledge"
	label variable Q`i'_2 "Private communication"
	label variable Q`i'_3 "Existing reports"
	label variable Q`i'_4 "Ad-hoc announcements"
	label variable Q`i'_5 "Peer firms"
	label variable Q`i'_6 "Media"
	label variable Q`i'_7 "Peer analysts"
	label variable Q`i'_8 "Stock price reactions"
	label variable Q`i'_9 "Commercial data providers"
}

label var Q10_1 "Translational exposure"
label var Q10_2 "Transactional exposure"
label var Q10_3 "Hedging strategy"
label var Q10_4 "One-time gains/losses"
label var Q10_5 "Sensitivity to indirect effects"
label var Q10_6 "Operating and strategic responses"

label var Q11 "Assessing the impact was..."

label define Q11 1 "Very similar" 2 "Relatively similar" 3 "More difficult for some"
label values Q11 Q11

label var Q12_1 "Complexity"
label var Q12_2 "Financial information"
label var Q12_3 "Volatility of business model"
label var Q12_4 "Uncertainty about responses"

label var Q13_Most1 "Most difficult 1"
label var Q13_Most2 "Most difficult 2"
label var Q13_Most3 "Most difficult 3"

label var Q13_Least1 "Least difficult 1"
label var Q13_Least2 "Least difficult 2"
label var Q13_Least3 "Least difficult 3"

label var Q14_1 "Quantitative inputs"
label var Q14_2 "Qualitative inputs"
label var Q14_3 "Adjustment of template"
label var Q14_4 "Switching to new template"
label var Q14_5 "Full reassessment"


label var D1_1 "Retail/Wholesale"
label var D1_2 "Construction"
label var D1_3 "Chemicals"
label var D1_4 "Software/Technology"
label var D1_5 "Health Care/Pharmaceuticals/Biotechnology"
label var D1_6 "Telecommunications/Media"
label var D1_7 "Insurance"
label var D1_8 "Real Estate"
label var D1_9 "Banks and other Finance"
label var D1_10 "Manufacturing Consumer Goods"
label var D1_11 "Manufacturing Industrials"
label var D1_12 "Consulting/Business Services"
label var D1_13 "Transportation/Energy/Utilities"
label var D1_14 "Other"

label var D2 "No. Industries"
label define INDUST 1 "1" 2 "2-3" 3 "4+"
label values D2 INDUST

label var D3 "No. Firms"
label define FIRMS 1 "1" 2 "2-4" 3 "5-9" 4 "10-15" 5 "16-25" 6 "25+"
label values D3 FIRMS

label var D4 "% Swiss Firms"

label var D5 "Age"
label define AGE 1 "<30" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60+"
label values D5 AGE

label var D6 "Education"
label define EDUCATION 1 "Bachelor" 2 "Master" 3 "CPA,CFA" 4 "PhD" 5 "Other"
label values D6 EDUCATION

label var D7 "Tenure"
label define TENURE 1 "1-3" 2 "4-9" 3 "10+" 
label values D7 TENURE

label var D8 "Employee Size"
label define SIZE 1 "1" 2 "2-4" 3 "5-10" 4 "11-25" 5 "26-50" 6 ">50"
label values D8 SIZE


label var D9 "Employee Headquarter"
label define HQ 1 "Switzerland" 2 "Europe" 3 "USA" 4 "ROW"
label values D9 HQ

gen SwissHQ = D9 == 1
gen EuropeHQ = D9 == 2

gen NumberFirmsSurvey = 1 		if D3 == 1 	// Mean value
replace NumberFirmsSurvey = 3 	if D3 == 2 	// Mean value
replace NumberFirmsSurvey = 7 	if D3 == 3 	// Mean value
replace NumberFirmsSurvey = 13 	if D3 == 4	// Mean value
replace NumberFirmsSurvey = 20 	if D3 == 5	// Mean value
replace NumberFirmsSurvey = 30 	if D3 == 5	// Mean value

gen SwissFirmsSurvey = D4 * NumberFirmsSurvey/100 

compress

*************************************
************** ANALYSIS *************
*************************************

run "${STANDARD_FOLDER}\2_Code\90_Additional_Survey_Code.do"

//Question 1
tab Q1, plot
tab Q1
sum Q1

//Question 15
tab Q15, plot
tab Q15
sum Q15

ttest Q1 == Q15

//Question 2
tab Q2, plot
tab Q2
sum Q2

//Question 3
tab Q3, plot
tab Q3
sum Q3

//Question 7
tab Q7, plot
tab Q7

sum Q7
ttest Q3 == Q7

//Question 4
tab Q4, plot
tab Q4
sum Q4

ttest Q4 == 3

//Question 5
fsum Q5*, label

//Question 6
fsum Q6*, label

quietly: orderquestion Q6, after(Q5_Part2_3) // Program written (see 90_Additional_Code.do) 

runtestquestion Q6, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 8 (Table 4: Panel A)
fsum Q8*, label

quietly: orderquestion Q8, after(Part3_Part1) // Program written (see 90_Additional_Code.do)

runtestquestion Q8, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 9 (Table 4: Panel B)
fsum Q9*, label

quietly: orderquestion Q9, after(SepQ8Q9) // Program written (see 90_Additional_Code.do)

runtestquestion Q9, signiveau(0.10) against(2) high(3) low(1) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

//Question 10 (Table 5: Panel A)
fsum Q10*, label

quietly: orderquestion Q10, after(Part3_Part2) // Program written (see 90_Additional_Code.do)

runtestquestion Q10, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

//Question 11
tab Q11, plot
tab Q11
sum Q11
ttest Q11 = 2

//Question 12 (Table 5: Panel B)
fsum Q12*, label

quietly: orderquestion Q12, after(Q11) // Program written (see 90_Additional_Code.do)

runtestquestion Q12, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 14
fsum Q14*, label

quietly: orderquestion Q14, after(Q13_Least3) // Program written (see 90_Additional_Code.do)

runtestquestion Q14, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Demographics

preserve

foreach var of varlist D1* {
	replace `var' = `var'*100
}
fsum D1*, label

tab D2

tab D3

tab D4

tab D5

tab D6

tab D7

tab D8

restore

exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"

capture cd ${STANDARD_FOLDER}

***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Qualtrics Output file for the IR survey  (Downloaded from Qualtrics on August 11, 2016):
/*Results file directly exported from Qualtrics in a csv format */

local IR_SURVEY = "Investor_Relations_Survey_Impact_of_Swiss_Franc_Shock.csv"

*** OUTPUT:


local MATCH_IR_DESCRIPTIVES = "MatchIRDescriptives.dta" // Files used to produce Table E1 (IA) eventually
local IR_Q_DATA = "IRSurveyData.dta" // File used to produce Table 8 eventually

* However, most results for this survey are still directly produced via the code in this do-file

***********************************************
************* Import Dataset ******************
***********************************************
cd "1_Sources\Surveys"

import delimited "`IR_SURVEY'", delimiter(comma) varnames(1) encoding("utf-8")

cd "${STANDARD_FOLDER}\3_Datasets"

*******************************************
********* PREPARATION OF DATASET **********
*******************************************

set seed 5

************* Merge Analysts with covered firms ************

foreach var of varlist n103_1_text { // This variable contains the ticker symbol that firms provided to identify their firm

	// Removed ticker symbols for confidentiality reasons

}

foreach var of varlist n102_1_text {

	replace `var' = "CFO" 						if `var' == "CFO" | `var' == "CFO "
	replace `var' = "Head Communications" 		if `var' == "Head Communications"| `var' == "Head of Corporate Communications" | `var' == "Head external communications" | `var' == "CCO" | `var' == "Chief Communications Officer"
	replace `var' = "Head IR"					if `var' == "Hear IR"| `var' == "Director Investor Relations" | `var' == "VP IR" | `var' == "Head of Corporate Communications & IR" | `var' == "Hear IR" | `var' == "Head of Investor Relations" | `var' == "Group Treasurer and head of IR" | `var' == "Head of IR" | `var' == "Head of Investor Relations" | `var' == "Head of IR & Cor Comms"
	replace `var' = "(Senior) IR"				if `var' == "Investor Relations Manager"| `var' == "IR Manager" | `var' == "IR & Tresury" | `var' == "Sr. Investor Relations Manager" | `var' == "IR" | `var' == "Senior IR Officer" | `var' == "Investor Relations" | `var' == "Investor Relations Officer"
	replace `var' = "Other"						if `var' == "Company Secretary" | `var' == "Senior PR Manager"
	replace `var' = "Treasury/Accounting"		if `var' == "Corporate Treasurer" | `var' == "Group Treasurer" | `var' == "Senior Accountant"
}

************* Rename Questions ************

drop dobrfl_26-v226							// Drop Display Order
drop v2-v4 v6 v7							// Drop beginning info
drop n11 									// no question
drop n101 n111_1_text-n126 					// Contact data

order n103_1_text
rename n103_1_text Company
rename n102_1_text Job

rename v1 	ResponseID
rename v5	EMail
rename v10 	FinishedIndicator
rename v8   StartDate
gen double StartDate2 = clock(StartDate, "YMDhms")
order StartDate2, after(StartDate)
drop StartDate
rename StartDate2 StartDate
format StartDate %tc 
rename v9   EndDate
gen double EndDate2 = clock(EndDate, "YMDhms")
order EndDate2, after(EndDate)
drop EndDate
rename EndDate2 EndDate

rename n21 Part1
rename n22 Q1
rename n23 Q2
rename n24 Q3
rename n31 Part2
rename n32 Q4 

forvalues i = 1/8 {

	rename n33_`i' Q5_`i'

}

rename n34 Q5_Comment

forvalues i = 1/6 {

	rename n35_`i' Q6_`i'

}

rename n36 Q6_Comment

/* have to rename here for later recodes */

rename n91 Part4



forvalues i = 1/4 {
	rename n92_`i' Q12_`i' // Translational etc.
}

	rename n93 Q12_Comment
	
forvalues i = 1/6 {
	rename n94_`i' Q13_`i' // Translational etc.
}	
	rename n95 Q13_Comment
	
	rename n96 Q14
	rename n97 Q15

	
/* end of have to rename here for later recodes */

egen Part3 = concat(n?1)

egen Q7 = concat(n?2)


forvalues i = 1/4 {
	egen Q8_`i' = concat(n?3_`i')
	}


forvalues i = 1/4 {
	egen Q9_`i' = concat(n?4_x`i')
	}

egen Q9_Comment = concat(n?5)

forvalues TYPE = 4/8 { // Error in Qualtrics, 4 and 5 is missing in Question 10 (adjusted here)

	local z = 0
	
	forval i = 6/10 {
		local z = `i' - 2
		rename n`TYPE'6_`i' n`TYPE'6_`z'
	}
}

forvalues i = 1/8 {
	egen Q10_`i' = concat(n?6_`i')
	}

egen Q10_Comment = concat(n?7)

forvalues i = 1/9 {
	egen Q11_`i' = concat(n?8_`i')
	}
	
drop n41-n88_9

gen SepQ8Q9 = "" // Needed for ordering (separating q8 and q9), needed for tests
	
order Company ResponseID FinishedIndicator Part1 Q1 Q2 Q3 Part2 Q4  Q5* Q6* Part3 Q7  Q8* SepQ8Q9 Q9* Q10* Q11* Part4 Q12* Q13* Q14* Q15*
 
rename Q5_Comment Comment_Q5
rename Q6_Comment Comment_Q6
rename Q9_Comment Comment_Q9
rename Q10_Comment Comment_Q10
rename Q12_Comment Comment_Q12
rename Q13_Comment Comment_Q13

foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}
  drop if _n == 1 // now drop label observation

foreach var of varlist FinishedIndicator Q* Part* {

	destring `var', replace
	replace `var' = . if `var' == -99
}

keep if FinishedIndicator == 1
drop if  missing(Q15) == 1		// One respondent

****************** Rename Labels *******************

label variable Q1 "Importance BEFORE the shock"
label variable Q15 "Importance AFTER the shock"
label variable Q2 "Expectation about cap removal"
label define Q2 1 "< 3 months" 2 "3 - 6 months" 3 "6 - 12 months" 4 "12 - 24 months" 5 "> 24 months"
label values Q2 Q2

label var Q3 "How is your business affected?"
label define Q3 1 "Very negatively" 2 "Negatively" 3 "Neutral" 4 "Positively" 5 "Very positively"
label values Q3 Q3

label var Q4 "When communication with stakeholders?"
label define Q4 1 "< 1 day" 2 "< 1 week" 3 "< 1 month" 4 "< 3 months" 5 "> 3 months"
label values Q4 Q4


label var Q5_1 "Media and press"
label var Q5_2 "Institutional investors"
label var Q5_3 "Retail investors"
label var Q5_4 "Financial analysts"
label var Q5_5 "External audit firm"
label var Q5_6 "Banks and other lending"
label var Q5_7 "Suppliers and customers"
label var Q5_8 "Management or other internal departments"

label var Q6_1 "Existing financial reports"
label var Q6_2 "Existing internal reports"
label var Q6_3 "Newly prepared ad-hoc reports"
label var Q6_4 "Consultation with key management"
label var Q6_5 "Consultation with outside experts"
label var Q6_6 "Feedback from analysts, media etc."


label var Q7 "How proactive approach?"

forvalues i = 8/9 {
	label variable Q`i'_1 "Ad-hoc announcements"
	label variable Q`i'_2 "Private communication"
	label variable Q`i'_3 "Media and financial press"
	label variable Q`i'_4 "Investor days"
}

label var Q10_1 "Uncertainty about effect"
label var Q10_2 "Uncertainty about FX"
label var Q10_3 "Upcoming event"
label var Q10_4 "Little info needs"
label var Q10_5 "Limited impact on firm"
label var Q10_6 "Fear of disclosure precedent"
label var Q10_7 "Company secrets"
label var Q10_8 "Unwanted scrutiny"

label var Q11_1 "Liquidity"
label var Q11_2 "Playing field"
label var Q11_3 "Prevent underpricing"
label var Q11_4 "Conf. Operating strategy"
label var Q11_5 "Conf. Reporting strategy"
label var Q11_6 "New investors"
label var Q11_7 "Existing investors"
label var Q11_8 "Information risk"
label var Q11_9 "Promote reputation"

label var Q12_1 "E-Mails"
label var Q12_2 "Phone calls"
label var Q12_3 "Website hits"
label var Q12_4 "Downloads"

label var Q13_1 "Translational exposure"
label var Q13_2 "Transactional exposure"
label var Q13_3 "Hedging strategy"
label var Q13_4 "One-time gains/losses"
label var Q13_5 "Sensitivity to indirect effects"
label var Q13_6 "Operating and strategic responses"

label var Q14 "Relevance existing reports"
label var Job "Job Title"

foreach var of varlist Q12* {
	replace `var' = . if `var' == 6
}

********** Drop one company with two answers *************

gen Random = rnormal()				// One firm responded twice via IR-CLub. Remove one answer
sort Company Random

by Company: drop if _n == 2 & missing(Company) == 0
drop Random

*************************************
************** ANALYSIS *************
*************************************

run "${STANDARD_FOLDER}\2_Code\90_Additional_Survey_Code.do"

// Question 1 and 15
tab Q1, plot
tab Q1
tab Q15, plot
tab Q15

sum Q1 Q15
ttest Q1 == Q15
ttest Q1 == 4
ttest Q15 == 4

// Question 2
tab Q2, plot
tab Q2
sum Q2

// Question 3
tab Q3, plot
tab Q3
sum Q3
ttest Q3 == 3

// Question 4
tab Q4, plot
tab Q4
sum Q4

// Question 5 (Table 6: Panel A)
quietly: orderquestion Q5, after(Q4) // Program written (see 90_Additional_Code)

runtestquestion Q5, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 6 (Table 6: Panel B)
quietly: orderquestion Q6, after(Comment_Q5) // Program written (see 90_Additional_Code)

runtestquestion Q6, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 7
tab Q7, plot
tab Q7
sum Q7
ttest Q7==4

// Question 8 (Table 7: Panel A)
quietly: orderquestion Q8, after(Q7) // Program written (see 90_Additional_Code)

runtestquestion Q8, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 9 (Table 7: Panel B)
quietly: orderquestion Q9, after(SepQ8Q9) // Program written (see 90_Additional_Code)

runtestquestion Q9, signiveau(0.10) against(2) high(3) low(1) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test



// Question 10

quietly: orderquestion Q10, after(Comment_Q9) // Program written (see 90_Additional_Code)

runtestquestion Q10, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 11

quietly: orderquestion Q11, after(Comment_Q10) // Program written (see 90_Additional_Code)

runtestquestion Q11, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 12
quietly: orderquestion Q12, after(Part4) // Program written (see 90_Additional_Code)

runtestquestion Q12, signiveau(0.10) against(3) high(5) low(1) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

	
// Question 13
quietly: orderquestion Q13, after(Comment_Q12) // Program written (see 90_Additional_Code)

runtestquestion Q13, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

	
// Question 14
tab Q14, plot
tab Q14
sum Q14
ttest Q14==4

tab Job


*****************************************
**Export Dataset for Archival Analysis **
*****************************************


cd "${STANDARD_FOLDER}\3_Datasets"

preserve
	drop if missing(Company)
	duplicates drop Company, force
	keep Company
	count
	save `MATCH_IR_DESCRIPTIVES', replace		// Used for Table E1	
restore

rename Q8_1_Q8_2 Q8_PrivateInfo
rename Q4 Q4_Timeliness
keep Company Q8_PrivateInfo Q4_Timeliness // Keep Relevant Questions for Analyses

drop if missing(Company)

cd "${STANDARD_FOLDER}\3_Datasets"
compress _all
save `IR_Q_DATA', replace

exit
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}

***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************
 
*** INPUT:

local SOURCEFILE1 	= "BloombergMerge.dta" 			// created in 01_Import_Bloomberg.do

local SOURCEFILE2 	= "ReportData.dta" 				// created in 02_Import_HandCollected.do

local SOURCEFILE3 	= "Datastream_IBES_Final.dta" 	// created in 03_Import_DS_IBES.do

local SOURCEFILE4 	= "PXLastIntraday.dta"			// created in 01_Import_Bloomberg.do 

local SOURCEFILE5 	= "BloombergMVShares.dta" 		// created in 01_Import_Bloomberg.do
	
local SOURCEFILE6 	= "SwissCrossListing.dta"		// created in 04_Import_Various.do

local SOURCEFILE7 	= "RiskHedgingData.dta"			// created in 04_Import_Various.do 

local SOURCEFILE8 	= "IR_DataArchival.dta"			// created in 04_Import_Various.do 

local SOURCEFILE9 	= "IntradayRollingWindow.dta" 	// created in 01_Import_Bloomberg.do

local SOURCEFILE10 	= "NewInformationData.dta"		// created in 04_Import_Various.do 

local SOURCEFILE11 	= "IRSurveyData.dta"			// created in 06_Import_IR_Survey.do

local SOURCEFILE12 	= "ActualSample151.dta"			// Identifier-List. To verify whether the sample is unchanged and OK (generated based on the final sample)

*** OUTPUT:

local SAVEFILE1 = "Final30MinSample.dta"		

************************************************
*********** Merge with other datasets  *********
************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

use `SOURCEFILE1', replace

merge m:1 Company using  `SOURCEFILE2', assert(match master)
drop _merge		


merge m:1 Company using `SOURCEFILE3', assert(match using) keepusing(Type DatastreamName NoshFF DisclosureRank InternationalStandards ///
										ISOCurrStock PriceCurrency NumberOfAnalysts SICCode SIC1 HistCorr* ///
										USGAAP PriceCurrency IFRS ISIN)
	drop if _merge == 2
	drop _merge
	qui count if (ISOCurrStock != "CHF" | PriceCurrency != "SF")
	assert `r(N)' == 0 												// Verify that all stocks are in CHF
	drop ISOCurrStock PriceCurrency
	

merge m:1 ID Date using `SOURCEFILE4', assert(match using)
	drop if _merge == 2
	drop _merge		

merge m:1 Company Date using `SOURCEFILE5' 							
	drop id 							
	drop if _merge == 2				
	rename _merge _merge1											// verify that the _merge == 1 from this step are later deleted (see below)

merge m:1 Type using `SOURCEFILE6', assert(match master) keepusing(CrossListingType)
	drop if _merge == 2 					// Irrelevant, see assert.
	drop _merge

merge m:1 Type using `SOURCEFILE7', assert(match master) 
	drop if _merge == 2 					// Irrelevant, see assert.
	drop _merge

merge m:1 Company using `SOURCEFILE8', assert(match master using) keepusing(IR_Club Lead_IR)
	drop if _merge == 2 					
	drop _merge

merge 1:1 ID DateTime using `SOURCEFILE9', assert(match) keepusing(*Rolling) 
	keep if _merge == 3
	drop _merge

merge m:1 Company Date using `SOURCEFILE10', assert(match master)	
	drop if _merge == 2
	drop _merge

merge m:1 Company using `SOURCEFILE11', assert(match master)	
	drop if _merge == 2
	drop _merge

******************************************************
*********** Last Step Before "Final Sample"  *********
******************************************************
distinct ID

*Table 1 Line 4: Removed 8 firms because of missing main control variables

foreach var of varlist DisclosureRank IntSales NoshFF NumberOfAnalysts {
	drop if missing(`var') 
}

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 151
	cd "${STANDARD_FOLDER}\1_Sources\Verification\"
	merge 1:1 Company using `SOURCEFILE12', assert(match)
restore

sum _merge1
assert `r(max)' == 3 & `r(min)' == 3
drop _merge1 

sort ID DateTime

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace
clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}


***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

*** INPUT:

local SOURCEFILE1 = "Final30MinSample.dta"

*** OUTPUT:

local SAVEFILE1 = "IntradayDataFinal.dta" // File for Intraday Analyses
local SAVEFILE2 = "DailyDataFinal.dta"	// File for Daily Analyses


***************************************************************
***************************************************************
************** I. Generate Intraday Dataset *******************
***************************************************************
***************************************************************

****************************************************************
************************ Import Intraday file ******************
****************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
										
use `SOURCEFILE1', replace											// starts with balanced panel
sort ID DateTime 

****************************************************************
***************** Make consistency checks***********************
****************************************************************

qui xtset ID DateTime
xtdescribe

assert `r(N)' == 151 													// assert that sample is correct, should be 151 observations
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum Date, detail
local MINDATE = `r(min)'

qui sum ID, detail
local MINID =`r(min)'

count if Date == `MINDATE' & ID == `MINID'

scalar INTRADAYOBS = `r(N)'												// Set number of Intraday observations for changes

assert scalar(INTRADAYOBS) == 17										// Set number of Intraday observations for changes

sum ID if HourMin <= 1030 & Date == `MINDATE' & ID == `MINID', detail
assert `r(N)' == 3
global UNTIL1030 = `r(N)'
assert ${UNTIL1030} == 3

****************************************************************
********************* SET SOME GLOBALS *************************
****************************************************************

global BENCHMARK_PERIOD "CenterDate <= -1 & CenterDate >= -30"

****************************************************************
***************** Generate important variables *****************
****************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

*Generate Logarithmic Returns
sort ID DateTime 
by ID: 	gen LogReturn = log(LastPriceTrade/LastPriceTrade[_n-1])		 // Overnight returns are fine
	replace LogReturn 	= 0 if missing(LogReturn)						//  Only for Oct 1 (not necessary as outside of sample)

*Generate CenterDate
sort ID DateTime 
egen 	CenterDate = group(Date)
	egen 	MAXDATE = group(Date) if Date <=td(15-jan-2015)
	qui sum MAXDATE, detail
	replace CenterDate = CenterDate-`r(max)'							// CenterDate is 0 for 15 Jan, 2015
	drop 	MAXDATE

* Generate Intraday Volatility
sort ID Date DateTime
by 	ID Date: egen SDReturn = sd(LogReturn)
	replace SDReturn =SDReturn*100										// * 100 for readability


* Generate BidAskSpread and MarketValue Variables
sort ID Date DateTime
gen LogSpread30 			= log(MeanTimeBidAskSpread) 										// BidAskSpread or LogSpread is only daily data; intraday TimeBidAskSpread, which is grouped by 30mins
gen LogMV 					= log(MVBloomAllNo)
by ID Date: replace LogMV 	= log(MVBloomAllNo*LastPriceTrade/LastPriceTrade[scalar(INTRADAYOBS)]) 	// Because MVBloomAllNo is End of Day; now adjust by intraday movements for intradey data

* Generate Turnover Variables
sort ID DateTime
by ID: gen Turnover = (ValueTrade)/(MVBloomAllNo[_n-scalar(INTRADAYOBS)]*1000000)*100 	// Lagged by one Day; * 100 for readability in %
gen LogTurnover 	= log(Turnover)

*** Generate Variables for Daily Analyses (e.g. Intraday Version of Liquidity Amihud)
gen AmihudIntraday = abs(LogReturn)/ValueTrade
gen RiskMGMTPerPage = NumberofRiskManagement/ReportLength
gen HedgingPerPage = Hedging/ReportLength

* Generate Logged Version of Rolling Return Volatility
sort ID Date DateTime
gen LogSDRolling = log(SDRolling)

* Generate Lagged Variables (not L., because of gaps)
sort ID DateTime
foreach var of varlist LogMV LogTurnover LogSDRolling SDReturn  {					// SDReturn (unlogged) needed for daily data set in collapse (only positive values)
	by ID: gen Lag`var' = `var'[_n-scalar(INTRADAYOBS)]
}

* Standardize Risk Disclosure to mean 0 and SD of 1 for analyses
sum RiskDisclosure, detail
egen StandardRiskDisc = std(RiskDisclosure)

* Generate Main Variables for Intraday Analyses.
sort ID DateTime

assert scalar(INTRADAYOBS) == 17											// Assert whether number of intraday obs is still correct
assert ${UNTIL1030} == 3													// Assert whether number of obs up until 10.30 is still correct.
assert ValueTrade[1193] == 15408579.085 									// Just an assert whether Value Trade as of 10.30 Jan 15 ABB; necessary for START variable

local ANNOUNCEMENT_DAY 	= 0
local WINDOW_START		= -30 	+ `ANNOUNCEMENT_DAY'
local WINDOW_END 		= 0 	+ `ANNOUNCEMENT_DAY'

sort ID DateTime
by ID: gen NUMBER 		= _n
gen START				= NUMBER - 1193-`ANNOUNCEMENT_DAY'*17+${UNTIL1030}
drop NUMBER

local y = 0
	
foreach x of numlist 1/`=scalar(INTRADAYOBS)'{
	
	local t = 8+int((`x'+1)/2)				// To determine Hour for Dummy
	local e = `t'+1							// To determine if Hour moves past
	
	gen _`x'AfterIncrease 		= 0
	replace _`x'AfterIncrease 	= 1 if START <= `x' & START > `y'
	
	gen _`x'AScore 	= _`x'AfterIncrease*StandardRiskDisc
	
	gen only_`x'AScore = _`x'AfterIncrease*StandardRiskDisc

	if int((`x'+1)/2) == (`x'+1)/2 {
		label var 	_`x'AfterIncrease 	"`t'.00-`t'.30 Dummy"
		label var 	_`x'AScore 			"`t'.00-`t'.30 x RiskDisclosure"
	}
	
	else {
		label var 	_`x'AfterIncrease 	"`t'.30-`e'.00 Dummy"
		label var 	_`x'AScore 			"`t'.30-`e'.00 x RiskDisclosure"
	}
	
	local y = `x'							// Counter
	
}


** Label Variables for Main Intraday Analyses
label var LogSpread30 			"Log(Spread)"
label var LagLogMV 				"Log(MarketValue)(t-17)"
label var LagLogTurnover 		"LogTurnover(t-17)"
label var LagLogSDRolling 		"Log(ReturnVolatility)(t-17)"


cd "${STANDARD_FOLDER}\3_Datasets"

sort ID DateTime

save `SAVEFILE1', replace

***************************************************************
***************************************************************
*************** II. Generate Daily Dataset ********************
***************************************************************
***************************************************************

****************************************************************
************* Collapse Dataset to Daily Dataset ****************
****************************************************************


cd "${STANDARD_FOLDER}\3_Datasets"
use `SAVEFILE1', replace

global FIRST Company Type DatastreamName SICCode ISIN CrossListingType // String Variables
global MEAN  AmihudIntraday MeanRelativeStale HistCorrEUR HistCorrUSD // Variables that vary within a day (e.g., AmihudIntraday) or a not varying within a day, but can take negative values (e.g., HistCorr)
global MAX  MeanDateBidAskSpread RiskDisclosure IntSales DisclosureRank NumberOfAnalysts NoshFF ///
			AfterSNB InternationalStandards SDReturn LagSDReturn PXLast BeforePXLast USGAAP IFRS ReportLength MVBloomAllNo Date SIC1 ///
			EPS_Revision News_SNB TotalNewInfo MeanDateEffSpread_No_W MeanDateEffSpread_W_M  ///
			Revenues2013 Assets2013 CostsProfits2013 Monetary2013 FXExposure2013 Hedging2013 FXSensitivity2013 ///
			LogRiskLinkedin LogHedgeKeyLinkedin Log_IR_Linkedin RiskMGMTPerPage HedgingPerPage RiskCommittee ChiefRisk EconHedgeYesNo IR_Club Lead_IR ///
			Q4_Timeliness Q8_PrivateInfo // These variables are not varying within a day and are >=0 (hence max in collapse step within a day always give the same value)
global SUM  ValueTrade

foreach ASS of global MAX {
	assert `ASS' >= 0 	& missing(`var') == 0					// Verify that only positive values, such that max in collapse-command is appropriate.
	}

collapse (mean) ${MEAN} (max) ${MAX} (sum) ${SUM} (first) ${FIRST}, by(ID CenterDate) 	// max because timeinvar and day 0
order ID Date DatastreamName Company

****************************************************************
***************** Generate Key Variables ***********************
****************************************************************

* Panel Checks whether data is correct
qui xtset ID Date
xtdescribe

assert `r(N)' == 151 													// Sample is correct, should be 151 observations
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum ID, detail
count if ID == `r(min)'

scalar TOTAL_DAYS = `r(N)'
assert TOTAL_DAYS == 144

qui sum Date, detail
count if Date == `r(min)'

scalar TOTAL_FIRMS = `r(N)'
assert TOTAL_FIRMS == 151


forval i = 1/`=scalar(TOTAL_FIRMS)'  {
	assert CenterDate[(70+(`i'-1)*TOTAL_DAYS)] == -1
}

* Standardize Risk Disclosure to mean 0 and SD of 1 for analyses
sum RiskDisclosure, detail
egen StandardRiskDisc = std(RiskDisclosure)

* Generate Median Split Risk Disc Variable (mostly for figures)
sum RiskDisclosure, detail
assert  `r(p50)' == 4
gen AboveRiskDisclosure = RiskDisclosure > `r(p50)' & !missing(RiskDisclosure)

* Log Variables (Log-transformation before collapse did not capture them)
gen LogSpread 			= log(MeanDateBidAskSpread)
gen LogSDReturn 		= log(SDReturn)
gen LogReportLength 	= log(ReportLength)
gen LogEffSpread 		= log(MeanDateEffSpread_No_W)
gen LogEffSpread_wgt	= log(MeanDateEffSpread_W_M)
gen LogAmihud 			= log(AmihudIntraday)

* Generate Main Controls (Log-transformation before collapse did not capture them)
sort ID CenterDate
by ID: gen Turnover 	= (ValueTrade/(MVBloomAllNo[_n-1]*1000000))*100				// in pp to enhance readability
by ID: gen LogTurnover 	= log(Turnover)
gen LogMV 				= log(MVBloomAllNo)

* Generate Additional Controls
sort ID CenterDate
foreach VAR of varlist LogTurnover LogMV LogSDReturn {
	by ID: gen Lag`VAR' = `VAR'[_n-1]
}

* Generate Lagged (but not logged) variables for descriptives table
sort ID Date 
by ID: gen LagMV = MVBloomAllNo[_n-1] 
by ID: gen LagTurnover = Turnover[_n-1] 

* Generate Industry Fixed Effects
foreach VAR of varlist SIC1  {
	egen IndustryDate`VAR' = group(`VAR' Date)
}

* Generate additional Control variables
gen HistCorrEur_R = HistCorrEUR
replace HistCorrEur_R = HistCorrUSD if missing(HistCorrEur_R) // Just 4 firms
drop HistCorrEUR HistCorrUSD

* Additional Variables (IA)
gen CrossList = !missing(CrossListingType)
gen MajorCrossList = !missing(CrossListingType) & CrossListingType != "U"
gen ExchCrossList = CrossListingType == "Real"

* Generate New Info Variables
foreach VAR of varlist EPS_Revision News_SNB TotalNewInfo {
	gen Log`VAR' = log(1 + `VAR')
}

* Generate Survey-Based Variable for Archival Analysis  
gen FirstWeek = Q4_Timeliness <= 2 if !missing(Q4_Timeliness) 			// Within The First Week
gen ImportantPrivate = Q8_PrivateInfo >= 6 if !missing(Q8_PrivateInfo) 	// Important Private Communication (6 or 7 on Likert Scale)

* Generate Return Variables
sort ID CenterDate
gen LogPXLast = log(PXLast)
by ID: gen LogReturn		= log(PXLast/PXLast[_n-1])*100															// * 100 for readability
by ID: replace LogReturn	= log(PXLast/BeforePXLast)*100 if Date == td(01oct2014) & missing(LogReturn)			// * 100 for readability


* Generate time-invariant controls based on average of benchmark period (except for LogMV, just for robustness tests)
foreach VAR of varlist LogMV LogTurnover LogSDReturn LogSpread MVBloomAllNo Turnover SDReturn MeanDateBidAskSpread LogReturn {
	by ID: egen MeanPre`VAR' = mean(`VAR') if ${BENCHMARK_PERIOD}
	by ID: replace MeanPre`VAR' = MeanPre`VAR'[_n-1] if missing(MeanPre`VAR')
	rename MeanPre`VAR' `VAR'_030
}

sort ID Date

* Generate Variables for Synthetic Control Analysis in Internet Appendix
foreach VAR of varlist LogSpread LogReturn {

	by ID: egen Mean`VAR' = mean(`VAR') if CenterDate < 0 					// Related to i)
	by ID: replace Mean`VAR' = Mean`VAR'[_n-1] if missing(Mean`VAR')

	by ID: egen Max`VAR' = max(`VAR') if CenterDate < 0						// Related to ii)
	by ID: replace Max`VAR' = Max`VAR'[_n-1] if missing(Max`VAR')

	by ID: egen Min`VAR' = min(`VAR') if CenterDate < 0 					// Related to iii)
	by ID: replace Min`VAR' = Min`VAR'[_n-1] if missing(Min`VAR')

	by ID: egen SD`VAR' = sd(`VAR') if CenterDate < 0 						// Related to iv)
	by ID: replace SD`VAR' = SD`VAR'[_n-1] if missing(SD`VAR')

	by ID: egen Skew`VAR' = skew(`VAR') if CenterDate < 0 					// Related to v)
	by ID: replace Skew`VAR' = Skew`VAR'[_n-1] if missing(Skew`VAR')

}

* Generate PostSNB Interactions
foreach var of varlist 	StandardRiskDisc AboveRiskDisclosure ///
						LagLogMV LagLogTurnover LagLogSDReturn ///
						IntSales DisclosureRank NumberOfAnalysts NoshFF HistCorrEur_R ///
						LogReturn LogMV_030* LogTurnover_030* LogSDReturn_030* LogSpread_030* LogReturn_030 ///
						LogRiskLinkedin LogHedgeKeyLinkedin Log_IR_Linkedin RiskMGMTPerPage HedgingPerPage RiskCommittee ChiefRisk EconHedgeYesNo IR_Club Lead_IR ///
						InternationalStandards IFRS USGAAP LogReportLength ///
						CrossList MajorCrossList ExchCrossList FirstWeek ImportantPrivate ///
						LogEPS_Revision LogNews_SNB LogTotalNewInfo {
	gen A`var' = `var'*AfterSNB
}

* Generate Triple Interactions
foreach VAR of varlist LogEPS_Revision LogNews_SNB LogTotalNewInfo {
	gen Triple_RiskDisc_`VAR' = AStandardRiskDisc * `VAR'
}

* Generate Longer-Term Post Indicators
gen Post1 = CenterDate <= 2 & CenterDate >= 0
gen Post2 = CenterDate <= 10 & CenterDate >= 3
gen Post3 = CenterDate <= 20 & CenterDate >= 11

foreach VAR of varlist Post* {
	gen `VAR'_RiskDisc = `VAR' * StandardRiskDisc
}

* Make tables more readable and label variables
rename SDReturn ReturnVol
cd "${STANDARD_FOLDER}\2_Code"

run "91_Label Variables.do"

* Save Dataset
cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE2', replace

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\" 

	
capture cd ${STANDARD_FOLDER}

***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

* INPUT:
global DAILY_DATA = "DailyDataFinal.dta"

global INTRADAY_DATA = "IntradayDataFinal.dta"

* OUTPUT:
global SPREAD_MODEL			"Table2.doc"
global INTRA_MODEL			"Table3_PanelA.doc"
global PERSIST_MODEL		"Table3_PanelB.doc"
global INTERACT_MODEL		"Table3_PanelC.doc"
global PRIVATE_INFO_MODEL	"Table8.doc"

***********************************************
** Define Some Global Variables for All Var. **
***********************************************

global DEPVAR_SPREAD 			"LogSpread"
global DEPVAR_RETVOL			"ReturnVol"

global TIME						"CenterDate <= 2 & CenterDate >= -30"

global CLUSTER					"ID Date"
global FIXED_NO_DATE			"ID"
global FIXED_DATE				"ID Date"
global FIXED_INDUSTRY_DATE		"ID IndustryDateSIC1"

global POST 					"AfterSNB"
global MAIN_TEST				"AStandardRiskDisc"
global MAIN_CONTROLS			"LagLogMV LagLogTurnover LagLogSDReturn"
global ADD_CONTROLS				"ALogMV_030"
global OTHER_CONTROLS			"AIntSales AHistCorrEur_R ADisclosureRank ANumberOfAnalysts ANoshFF"
global RET_CONTROLS				"LogReturn ALogReturn"

global OUTREG_TITLE		"Regressions with [-30; +2] window using daily data"
global R_PANEL 			"e(r2_a_within)"
global OUTREG_STATS		"nor2 noobs nonote tstat bdec(3) tdec(2) addnote(t-statistics based on robust standard errors clustered by firm and date, *** p<0.01; ** p<0.05; * p<0.1) label"

*************************************************************
*************************************************************
*************** I. Daily Analysis Regressions ***************
*************************************************************
*************************************************************


*************************************************************
************************ Table 2 ****************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

cd "${STANDARD_FOLDER}\4_Output\Tables"

*** Generate Sample of 4,949 (151 firms)

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST}  ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	keep if (e(sample)) 
	count
	assert `r(N)' == 4949

*** Descriptive Statistics Table 1: Panel B

fsum MeanDateBidAskSpread ReturnVol AfterSNB RiskDisclosure LagMV LagTurnover LagSDReturn IntSales HistCorrEur_R DisclosureRank NumberOfAnalysts NoshFF LogReturn, stats(n mean sd p1 p25 p50 p75 p99) f(%9.3f)

***** Table 2

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST} ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Date")  ${OUTREG_STATS}
	
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}
		
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_RETVOL} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) sortvar(${POST}) addtext(Fixed Effects, "Firm & Date") 	${OUTREG_STATS}


*************************************************************
*************************************************************
************* II. Remaining Archival Analyses ***************
*************************************************************
*************************************************************

*************************************************************
****************** Table 3: Panel A *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${INTRADAY_DATA}, replace

cd "${STANDARD_FOLDER}\4_Output\Tables"

global DEPVAR_SPREAD30 			"LogSpread30"

global TIME30_LONG				"CenterDate<=0 & CenterDate>=-30"
global TIME30_SHORT				"CenterDate<=0 & CenterDate>=0"

global MAIN_CONTROLS30			"LagLogMV LagLogTurnover LagLogSDRolling"

global CLUSTER30				"ID DateTime"
global OUTREG30					"nor2 noobs nonote addnote(t-statistics based on robust standard errors clustered by firm and time, *** p<0.01; ** p<0.05; * p<0.1) label"
	
global OUTREG_TITLE30		"Within announcement day: Log(Spread) as the dependent variable"


reghdfe ${DEPVAR_SPREAD30} _*  ${MAIN_CONTROLS30}		if ${TIME30_LONG}, absorb(ID HourMin) vce(cluster ${CLUSTER30}) noconstant
	outreg2 using ${INTRA_MODEL}, replace ctitle([-30; 0]) title("${OUTREG_TITLE30}") nose bdec(3)  ${OUTREG30}
	outreg2 using ${INTRA_MODEL}, append ctitle([-30; 0]) title("${OUTREG_TITLE30}") drop(LogSpread30) stats(tstat)  tdec(2) adds(Adj. Within R2, ${R_PANEL}, No. Firms, e(N_clust1), No. Obs, e(N)) addtext(Fixed Effects, "Firm & Time-of-Day") ${OUTREG30}
	assert `e(N)' == 64012

reghdfe ${DEPVAR_SPREAD30} _*AScore ${MAIN_CONTROLS30} 	if ${TIME30_SHORT}, absorb(HourMin) vce(cluster ${CLUSTER30}) noconstant
	outreg2 using ${INTRA_MODEL}, append ctitle([0; 0]) title("${OUTREG_TITLE30}") nose bdec(3) ${OUTREG30}
	outreg2 using ${INTRA_MODEL}, append ctitle([0; 0]) title("${OUTREG_TITLE30}") drop(LogSpread30) stats(tstat) tdec(2) adds(Adj. Within R2, ${R_PANEL}, No. Firms, e(N_clust1), No. Obs, e(N)) addtext(Fixed Effects, "Time-of-Day") ${OUTREG30}
	count if e(sample)
	assert `e(N)' == 2112


*************************************************************
****************** Table 3: Panel B *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

global TIME_LONG				"CenterDate <= 20 & CenterDate >= -30"

global MAIN_TEST_LONG			"Post1_RiskDisc Post2_RiskDisc Post3_RiskDisc"
global POST_LONG				"Post1 Post2 Post3"

cd "${STANDARD_FOLDER}\4_Output\Tables"

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST_LONG}  ${MAIN_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	keep if (e(sample)) 
	count
	assert `e(N)' == 7653

*****

reghdfe ${DEPVAR_SPREAD} ${POST_LONG} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PERSIST_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Date") ${OUTREG_STATS}
	
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}
		
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_RETVOL} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) sortvar(${POST_LONG}) addtext(Fixed Effects, "Firm & Date") ${OUTREG_STATS}


*************************************************************
****************** Table 3: Panel C *************************
*************************************************************
cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

global MAIN_TEST1				"AStandardRiskDisc ALogEPS_Revision Triple_RiskDisc_LogEPS_Revision"
global MAIN_TEST2				"AStandardRiskDisc ALogNews_SNB Triple_RiskDisc_LogNews_SNB"
global MAIN_TEST3				"AStandardRiskDisc ALogTotalNewInfo Triple_RiskDisc_LogTotalNewInfo"


cd "${STANDARD_FOLDER}\4_Output\Tables"

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST1}  ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER})
	keep if (e(sample)) 
	count
	assert `e(N)' == 4949

*****

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${INTERACT_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER})  noconstant
		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS} sortvar(${MAIN_TEST1}   ${MAIN_TEST2}  ${MAIN_TEST3})

*************************************************************
************************* Table 4-7 *************************
*************************************************************

* Corresponding Results are produced in 05_Import_Sell_Side_Analyst_Survey (Table 4 and 5)
* and 06_Import_IR_Survey (Table 6 and 7)

*************************************************************
*************************** Table 8 *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

drop if missing(Q4) & missing(Q8) // Restrict Sample to Survey Respondents

global TIME						"CenterDate <= 2 & CenterDate >= -30"

global MAIN_TEST1				"AStandardRiskDisc"
global MAIN_TEST2				"AStandardRiskDisc AFirstWeek"
global MAIN_TEST3				"AStandardRiskDisc AImportantPrivate"

 cd "${STANDARD_FOLDER}\4_Output\Tables"

*** Column 1-3
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}
	count if e(sample)
	assert `e(N)' == 1185

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

* Column 4-6: Drop Outliers in this analysis
drop if ID == 26 

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}
	count if e(sample)
	assert `e(N)' == 1119

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS} sortvar(${MAIN_TEST1} ${MAIN_TEST2} ${MAIN_TEST3})


local TXTFILES: dir . files "*.txt"
foreach TXT in `TXTFILES' {
    erase `"`TXT'"'
}



exit
// Two created programs for analysis of surveys (orderquestion + runtestquestion)
// Need to be run before 05_Import_Sell_Side_Analyst_Survey or 06_Import_IR_Survey 
// Or created as two separate ado-files and added do the personal ado folder

capture program drop orderquestion
program define orderquestion
	syntax namelist(max=1) [, after(string)]
	
// From here statslist  http://www.statalist.org/forums/forum/general-stata-discussion/general/1357869-order-variables-based-on-their-mean

ds `namelist'*
local vlist `r(varlist)'

preserve

collapse (mean) `vlist'
local i = 1
foreach v of local vlist {
    gen name`i' = "`v'"
    rename `v' mean`i'
    local ++i
}
gen _i = 1
reshape long mean name, i(_i) j(_j)
sort mean
replace _j = _n
replace name = name + " " + name[_n-1] if _n > 1
local ordered_vlist = name[_N]
restore
order `ordered_vlist', after(`after')

// Until here statslist  http://www.statalist.org/forums/forum/general-stata-discussion/general/1357869-order-variables-based-on-their-mean

ds `namelist'*  // Do it again, because of new ordering
local vlist `r(varlist)'

local i = 0
foreach var of varlist `vlist' {
	local i = `i' + 1
	rename `var' `namelist'_`i'_`var' // i displays the ranking of the means, while the old identifier is retained at the end of the variable name 
}


end

capture program drop runtestquestion
program define runtestquestion
	syntax namelist(max=1) [, signiveau(numlist max = 1) against(numlist max=1) high(numlist max=1) low(numlist max =1) unpaired(numlist max =1)]
	
	local MAX = 0
	local TEST_OPTION = ""
	if `unpaired' == 1 {
		
		local TEST_OPTION = ", unpaired"
	
	}
foreach QUESTION in `namelist' {
	// Determine the number of items
	qui ds `QUESTION'_*
	qui local nword : word count `r(varlist)'
	
	// Determine Mean and Baseline Tests (no comparison between answer items)
	
	matrix define `QUESTION' = J(`nword',5,.) // Column 3 is missing because it is filled in later with the Holm-Adjustment mechanism
	
	local POS = 0
	foreach var of varlist `QUESTION'_* {
		local POS = `POS' +1
		
		qui count if missing(`var') == 0
		local TOTAL = `r(N)'
		
		qui count if missing(`var') == 0 & `var' >= `high'
		
		local highPER = `r(N)'/`TOTAL'*100

		
		qui count if missing(`var') == 0 & `var' <= `low'

		local lowPER = `r(N)'/`TOTAL'*100

		
		qui ttest `var' == `against'
		matrix `QUESTION'[`POS',1] = round(`r(mu_1)',0.01)
		matrix `QUESTION'[`POS',2] = round(`r(p)',0.001)
		matrix `QUESTION'[`POS',4] = round(`highPER',0.01)
		matrix `QUESTION'[`POS',5] = round(`lowPER',0.01)

	}
		matrix colnames `QUESTION' = Mean P-Value Holm High% Low%
		matrix list `QUESTION'
		
		
		forval i = 1/5 {
			display ""
		}
	// Here comparisons across answer items
	
		forval T_TEST_Q = 1/`nword' {
			
			qui sum  `QUESTION'_`T_TEST_Q'
			local MAX = max(`MAX',`r(N)')
			
			matrix define `QUESTION'_`T_TEST_Q' = J(`nword'-1,6,.)

			local POS = 0
			foreach i of numlist 1/`nword' {
				if `i' == `T_TEST_Q' {
			}
			else {
				local POS = `POS' +1
				qui ttest `QUESTION'_`T_TEST_Q' == `QUESTION'_`i' `TEST_OPTION'
				matrix `QUESTION'_`T_TEST_Q'[`POS',1]=`i'
				matrix `QUESTION'_`T_TEST_Q'[`POS',2]=`r(p)'
				matrix `QUESTION'_`T_TEST_Q'[`POS',3]=`r(p)' <= `signiveau'
			}
	}
		mata : st_matrix("`QUESTION'_`T_TEST_Q'", sort(st_matrix("`QUESTION'_`T_TEST_Q'"), 2)) // Command for sorting of p value
	
		local ntests = `nword' -1
	
		forval i = 1/`ntests' {
	
			matrix `QUESTION'_`T_TEST_Q'[`i',4] = `signiveau'/(`ntests'-`i'+1)
			matrix `QUESTION'_`T_TEST_Q'[`i',5] = `QUESTION'_`T_TEST_Q'[`i',2] <= `QUESTION'_`T_TEST_Q'[`i',4]
			matrix `QUESTION'_`T_TEST_Q'[`i',6] = `QUESTION'_`T_TEST_Q'[`i',1] * `QUESTION'_`T_TEST_Q'[`i',5]
			
			matrix colnames `QUESTION'_`T_TEST_Q' = Number SigNiveau Sig? Holm Sig? WhereDiffs
			
	}
	
	local lab: variable label `QUESTION'_`T_TEST_Q'
	di "`lab'"
	
	matrix list `QUESTION'_`T_TEST_Q'
	matrix Only_`QUESTION'_`T_TEST_Q' = `QUESTION'_`T_TEST_Q'[1..`nword'-1,6]
	
	mata : st_matrix("Only_`QUESTION'_`T_TEST_Q'", sort(st_matrix("Only_`QUESTION'_`T_TEST_Q'"), 1)) // Command for sorting of p value
	matrix list Only_`QUESTION'_`T_TEST_Q'

	

	forval i = 1/5 {
		display ""
	}

}
}

display "Max number of obs: `MAX'"

clear matrix
end
version 13.1
${LOG_FILE_OPTION}

* Coming from DailyDataFinal.dta

* Outcome Variables
label var LogSpread 				"Log(Spread)"
label var ReturnVol 				"ReturnVol"

label var AfterSNB					"PostSNB"

* Main Test Variable
label var RiskDisc 			"RiskDisclosure"
label var AStandardRiskDisc	"PostSNB x RiskDisclosure"

* Control Variables
label var LogMV 					"Log(MarketValue)"
label var LagLogMV 					"Log(MarketValue)(T-1)"

label var LogTurnover 				"Log(Turnover)"
label var LagLogTurnover 			"Log(Turnover)(T-1)"

label var LogSDReturn 				"Log(ReturnVolatility)"
label var LagLogSDReturn 			"Log(ReturnVolatility)(T-1)"

label var ALagLogMV					"PostSNB x Log(MarketValue)(T-1)"
label var ALagLogTurnover 			"PostSNB x Log(Turnover)(T-1)"
label var ALagLogSDReturn			"PostSNB x Log(RetVola)(T-1)"

label var LogMV_030					"Log(MV)(0-30)"
label var LogTurnover_030			"Log(Turnover)(0-30)"
label var LogSDReturn_030			"Log(RetVola)(0-30)"

label var ALogMV_030				"PostSNB x Log(MV)(0-30)"

label var IntSales 					"IntSales"
label var AIntSales 				"PostSNB x IntSales"
label var DisclosureRank	 		"Total_Disc"
label var ADisclosureRank			"PostSNB x Total_Disc"
label var NumberOfAnalysts	 		"Num_Analysts"
label var ANumberOfAnalysts 		"PostSNB x Num_Analysts"
label var NoshFF 					"FreeFloat"
label var ANoshFF 					"PostSNB x FreeFloat"
label var LogReportLength			"Log(Report Length)"
label var ALogReportLength			"PostSNB x Log(Report Length)"
label var HistCorrEur_R				"Hist_Corr_EUR"
label var AHistCorrEur_R			"PostSNB x Hist_Corr_EUR"

label var LogReturn 				"LogReturn"
label var ALogReturn				"PostSNB x LogReturn"
label var LogPXLast					"Log(Price)"

label var InternationalStandards	"Int_Standards"
label var AInternationalStandards	"PostSNB x Int_Standards"

* Longer-Term Post-Variables
label var Post1 				"Post(0,2)"
label var Post2 				"Post(3,10)"
label var Post3 				"Post(11,20)"

label var Post1_RiskDisc		"Post(0,2) x RiskDisclosure"
label var Post2_RiskDisc		"Post(3,10) x RiskDisclosure"
label var Post3_RiskDisc		"Post(11,20) x RiskDisclosure"

* Triple Interactions
label var ALogEPS_Revision 					"Post_SNB x Log(1+EPS_Revision)"
label var ALogNews_SNB 						"Post_SNB x Log(1+News)"
label var ALogTotalNewInfo  				"Post_SNB x Log(1+Combined)"
label var Triple_RiskDisc_LogEPS_Revision 	"Post_SNB x FXRisk_Disc x Log(1+EPS_Revision)"
label var Triple_RiskDisc_LogNews_SNB 		"Post_SNB x FXRisk_Disc x Log(1+News)"
label var Triple_RiskDisc_LogTotalNewInfo 	"Post_SNB x FXRisk_Disc x Log(1+Combined)"

* Risk MGMT Variables
label var ChiefRisk 			"ChiefRisk"
label var AChiefRisk 			"PostSNB x ChiefRisk"

label var RiskCommittee 		"RiskCommittee"
label var ARiskCommittee 		"PostSNB x RiskCommittee"

label var RiskMGMTPerPage 		"RiskMGMT/#Page"
label var ARiskMGMTPerPage 		"PostSNB x RiskMGMT/#Page"

label var LogRiskLinkedin 		"Log(#Risk Employees)"
label var ALogRiskLinkedin 		"PostSNB x Log(#Risk Employees)"

* Hedging Variables
label var HedgingPerPage 		"Hedging/#Page"
label var AHedgingPerPage 		"PostSNB x Hedging/#Page"

label var LogHedgeKeyLinkedin 	"Log(#Hedging Employees)"
label var ALogHedgeKeyLinkedin 	"PostSNB x Log(#Hedging Employees)"

label var EconHedgeYes 			"Economic_Hedge"
label var AEconHedgeYes 		"PostSNB x Economic_Hedge"

* IR Variables
label var IR_Club 				"IR_Club"
label var AIR_Club 				"PostSNB x IR_Club"

label var Lead_IR 				"Lead_IR"
label var ALead_IR 				"PostSNB x Lead_IR"

label var Log_IR_Linkedin 		"Log(#IR Employees)"
label var ALog_IR_Linkedin 		"PostSNB x Log(#IR Employees)"

* Other IR Varibales
label var AFirstWeek 			"Post_SNB x First_Week"
label var AImportantPrivate		"Post_SNB x Private_Comm"
clear all
version 13.1
capture log close
capture log off

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\" // Contains 4 folders: 1_Sources, 2_Code, 3_Datasets, 4_Output

***********************************************
*********** Define Global Variables ***********
***********************************************

global LOG_FILE_YES_NO = "YES"

***********************************************
**************** Run Codes ********************
***********************************************

**** Pass on Log File Options to Do-Files ******

if "${LOG_FILE_YES_NO}" == "YES" {
		global LOG_FILE_OPTION = ""
	 	log using "${STANDARD_FOLDER}\4_Output\LogFile\ResultLog", replace smcl
}
else { 
	global LOG_FILE_OPTION = "capture log off"

}

*************** Import Data *******************

do "${STANDARD_FOLDER}\2_Code\01_Import_Bloomberg"
do "${STANDARD_FOLDER}\2_Code\02_Import_HandCollected"
do "${STANDARD_FOLDER}\2_Code\03_Import_DatastreamIBES"
do "${STANDARD_FOLDER}\2_Code\04_Import_Various"
do "${STANDARD_FOLDER}\2_Code\05_Import_Sell_Side_Analyst_Survey" 	// code also contains analyses related to the analyst survey
do "${STANDARD_FOLDER}\2_Code\06_Import_IR_Survey"				 	// code also contains analyses related to the IR survey

********** Connect and Prepare Data ************

do "${STANDARD_FOLDER}\2_Code\10_Merge_Datafiles"
do "${STANDARD_FOLDER}\2_Code\11_Preparation_Main_Variables"

*****************Make Analyses ****************

do "${STANDARD_FOLDER}\2_Code\20_Main_Archival_Analysis"


// the 90_* and 91_* do-files are included in one of the other do-files

if "${LOG_FILE_YES_NO}" == "YES" {
	log close _all
}


exit


clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

* 1. IntradayBar Data from Bloomberg via the Bloomberg excel tool:
/* Miniute-by-minute ask, bid and trade prices as well as corresponding volumes. Due to data download limitations of Bloomberg as well as technical limitations of the terminal itself, 
the downloads were conducted on three different occasions (Part1, Part2, Part 3):

Part 1 covers the data from August 4, 2014 until February 16, 2015 	(Downloaded on February 16, 2015)
Part 2 covers the data from February 16, 2015 until March 31, 2015 	(Downloaded on April 1, 2015)
Part 3 covers the data from March 2, 2015 until May 31, 2015 		(Downloaded on May 31, 2015)

These three parts are overlapping in terms of dates, which was intentional to verify the completeness of the time series and to ensure that stock splits etc. are not disrupting the time series for certain firms.
Bid Prices, Ask Prices and Trade Prices (as well as corresponding volumes) are all saved in separate folders ("Ask", "Bid" and "Trade").
The data for each firm ticker is a separate Excel workfile within each folder. 
In total 3 (ask, bid, trade) * 3 (part1, part2, part3) *241 (ticker symbols) = 2,169 excel files need to be imported */

* 2. Trading Days calendar (Downloaded April 16, 2015): 
/* Excel file that contains all days and indicates whether they are trading days (=1) or not (=0; e.g. Saturdays and Sundays).
Manually transcribed from SIX Exchange Trading Calendar ("Trading Calendar 2015", "Trading Calendar 2014"). */

local TRADING_FILE = "TradingDays.dta"

*3. Market Value Data from Bloomberg via the Bloomberg excel tool (Downloaded on November 10, 2015):
/* Daily Market Value Data. Compared to the intraday data (which was downloaded on an earlier date), two ticker symbols changed. 
These two ticker symbols are replaced later in the code below*/

local MV_FILE "AllMvMvcSharesAllNoTwoTickerChangesCopy.xlsx"

*** OUTPUT:

local SAVEFILE_MV_DAILY 	= "BloombergMVShares.dta"
local SAVEFILE_BLOOM_MERGE 	= "BloombergMerge.dta"
local SAVEFILE_PX_LAST 		= "PXLastIntraday.dta"
local ROLLINGVOL 			= "IntradayRollingWindow.dta"

*********************************************************************
*********************************************************************
***************I. Import Bloomberg Intraday Data ********************
*********************************************************************
*********************************************************************

***********************************************
********* Import Actual Excel files ***********
***********************************************

capture cd ${STANDARD_FOLDER}


scalar MAXLOOP = 242 // SSIP with 241 firms (still contains 4 duplicate tickers); 242 instead of 241 since Sheet 1 just lists firm tickers (hence, not included in loop below)

foreach PART in Part1 Part2 Part3 {
	foreach TYPE in Trade Bid Ask {
	
* Loop through folders (Parts and Type of Quotes/Trades)

		forvalues i=`=scalar(MAXLOOP)'(-1)2 {
		
			qui cd "${STANDARD_FOLDER}\1_Sources\IntradayBar-`PART'"
			qui cd "`TYPE'\AllSheets"
	
* Capture the Company name (Bloomberg ID) from cell A1
	
			import excel using Sheet`i'`TYPE'.xlsx, ///
			sheet(Sheet`i') cellrange(A1:A1) clear 
			local COMPANY = A[1]    					// local macro with company name

* Get data from the beginning of A3

			import excel using Sheet`i'`TYPE'.xlsx, ///
			sheet(Sheet`i')  cellrange(A3) firstrow case(lower) clear
			
			if missing(last_price[_n]) { 				// do not import if N/A N/A in first line (then there is a missing value in last price column)
			}
	
			else {
	
* Add Company Name (main identifier)

				generate company = "`COMPANY'"
				generate id = `i'-1 

* Adjustments for rounding, deleting missing Bloomberg data and adjusting Var name*/

				replace date = round(date,1000) 			// round data (bc Stata <-> excel mismatch)
				recast double open high low last_price value
				recast long number_ticks volume
				recast str15 company
	
* Rename vars

				rename id ID
				rename company Company
				rename date DateTime
				rename open Open
				rename high High
				rename low Low
				rename last_price LastPrice
				rename number_ticks NumberTicks
				rename volume Volume
				rename value Value
				foreach var of varlist Open High Low LastPrice NumberTicks Volume Value {
					rename `var' `var'`TYPE'
				}

// Append and save data

				if `i'== `=scalar(MAXLOOP)' {
					qui cd "${STANDARD_FOLDER}\3_Datasets"
					save Swiss`TYPE'`PART', replace
				}
				else {
					qui cd "${STANDARD_FOLDER}\3_Datasets"
					append using Swiss`TYPE'`PART'.dta
					save Swiss`TYPE'`PART', replace
				}
			}
	}

		order ID Company
		sort ID DateTime

		qui cd "${STANDARD_FOLDER}\3_Datasets"
		save Swiss`TYPE'`PART', replace

			
	}
}

************************************************
***** Merge Part Files into One File Each ******
************************************************

foreach TYPE in Trade Bid Ask {
	
	qui cd "${STANDARD_FOLDER}\3_Datasets"
	use "Swiss`TYPE'Part1"
	forvalues j = 2/3 {
	
		append using Swiss`TYPE'Part`j'.dta
		sort ID DateTime
		save `TYPE'All, replace
		
	}

	sort ID DateTime
	quietly by ID DateTime: gen dup = cond(_N==1,0,_n)
	tabulate dup
	drop if dup == 2 					// Remove duplicate dates. Duplicates occur since the data was downloaded in three parts with overlapping date intervals (to ensure completeness of the data)
	drop dup	
	
	
	save `TYPE'All, replace

}
foreach TYPE in Trade Bid Ask {
	forvalues j = 1/3 {
		erase Swiss`TYPE'Part`j'.dta
	}
}
***********************************************
************* Clean DataSet Pre Merge *********
***********************************************

cd "${STANDARD_FOLDER}\3_Datasets"

* Various Adjustments
* Here: For 04aug2014 there is one second added too much in excel --> therefore remove this second

foreach DATASET in Trade Bid Ask {

	use `DATASET'All.dta
	
	gen second = ss(DateTime)
	noisily replace DateTime = DateTime - 1000 if second > 0 // for August 4th in bid and ask, seconds are too high (by 1000)
	sort ID DateTime
	by ID DateTime: gen dup = cond(_N==1,0,_n)
	noisily tabulate dup
	drop second dup

* 0 prices or volume are irrelevant or wrong --> drop them
	drop if LastPrice`DATASET' 	== 0
	drop if Volume`DATASET' 	== 0

*Delete useless variables
	drop High`DATASET'
	drop Low`DATASET'
	drop Open`DATASET'

*Rename and make indicator variable to determine whether data was in original data set

	gen Active`DATASET' = 1

*Define all date/time variables needed for the analysis

	generate Date = dofc(DateTime)
	format Date %td 																// Real Date variable

	gen time = hh(DateTime) + mm(DateTime)/60 + ss(DateTime)/3600 					// Time variable

	qui count if ID > 241															// Verify that only 241 SSIP tickers were downloaded.
	assert r(N) == 0 														

	scalar TIMESTART = 9 + 0.1/60 													// i.e. everything deleted before 9.01
	scalar TIMEEND = 17 + 31/60 													// i.e. everything deleted after 17.30

	drop if time < TIMESTART | time > TIMEEND
	
	sort ID DateTime
	save `DATASET'AllManip.dta, replace


}
	erase BidAll.dta
	erase AskAll.dta

***********************************************
************* TSFill for Trade-Dataset ********
***********************************************

use TradeAllManip.dta, replace

* Set to panel data set and fill in gaps

xtset ID DateTime, delta(1 min)
tsfill, full

* Calculate Time & Date Variables for filled data

replace Date = dofc(DateTime)										// Date variable
format Date %td 													// Date variable
replace time = hh(DateTime) + mm(DateTime)/60 + ss(DateTime)/3600 	// Time variable

* Add TradingDays Variable for deletion of irrelevant days

merge m:1 Date using "${STANDARD_FOLDER}\1_Sources\Other\\`TRADING_FILE'", assert(match)
drop if _merge == 2
drop _merge

sort ID DateTime

* Drop if outside trading days or outside trading hours (before 9am [i.e. start with 9.01] or after 5.30pm [i.e. end with 17.31])

drop if tradingdays == 0
drop tradingdays
drop if time < TIMESTART | time > TIMEEND							// Have to do it here  again, because of tsfill
drop time

replace ActiveTrade = 0 if missing(ActiveTrade)

xtset ID DateTime, delta(1 min)

************************************************
******* Merge Ask, Bid and Trades Files ********
************************************************

* Merge files into filled trade dataset

merge 1:1 ID DateTime using BidAllManip.dta, assert(match master)
	gen merge1 = _merge
	drop _merge
	sort ID DateTime

merge 1:1 ID DateTime using AskAllManip.dta, assert(match master)
	gen merge2 = _merge
	drop _merge
	sort ID DateTime


* Prepare everything or variable creation; drop merge variables and set data set correctly
sum merge1, detail
sum merge2, detail
drop merge1
drop merge2

xtset ID DateTime, delta(1 min) 			//reset to balanced panel

* Label variables in data set

label var ID 				"Unique company identifier (xtset)"
label var Company 			"Company name"
label var DateTime 			"Date&Time for obs (xtset)"
label var LastPriceTrade 	"Last Trading Price in this minute"
label var NumberTicksTrade 	"Ticks traded in this minute"
label var VolumeTrade 		"Volume traded in this minute"
label var ValueTrade 		"Value traded (lastPrice*volume)"
label var ActiveTrade 		"non-missing trading obs"
label var Date 				"Date without time"
label var LastPriceAsk 		"Last Ask Price in this minute"
label var NumberTicksAsk 	"Ask Ticks in this minute"
label var VolumeAsk 		"Ask volume in this minute"
label var ValueAsk 			"Ask Value (lastPrice*volume)"
label var ActiveAsk 		"non-missing Ask obs"
label var LastPriceBid 		"Last Bid Price in this minute"
label var NumberTicksBid 	"Bid Ticks in this minute"
label var VolumeBid 		"Bid volume in this minute"
label var ValueBid 			"Bid Value (lastPrice*volume)"
label var ActiveBid 		"non-missing Bid obs"

order ID Company DateTime Date
sort ID DateTime

save FullMerge, replace

cd "${STANDARD_FOLDER}\3_Datasets"
	
erase TradeAllManip.dta
erase BidAllManip.dta
erase AskAllManip.dta
	
*********************************************************************
*********************************************************************
**************II. Import Daily Market Value Data ********************
*********************************************************************
*********************************************************************

tempfile AllNo

local ATTACHMENT = "AllNo" // This refers to the Bloomberg download options. "No" was selected for all options.
local SAVENAME "`AllNo'"

cd "${STANDARD_FOLDER}\1_Sources\Other-Bloomberg"
qui import excel  `MV_FILE', describe

forvalues i=`r(N_worksheet)'(-1)2 {
	cd "${STANDARD_FOLDER}\1_Sources\Other-Bloomberg"

*Capture the company name from cell A1

	import excel using `MV_FILE', sheet(Sheet`i') ///
	cellrange(A1:A1) clear 
	local COMPANY = A[1]   					 		// local macro with company name

*Get data from the beginning of A2

	import excel using `MV_FILE', sheet(Sheet`i') ///
		cellrange(A2) firstrow case(lower) clear

	if missing(cur_mkt_cap) { 				// do not import if N/A N/A in first line
	
	}

	else {
		rename date Date
		generate Company = "`COMPANY'"
		recast str15 Company
		generate id = `i'-1
	
		rename cur_mkt_cap MVCBloom`ATTACHMENT'
		rename eqy_sh_out NoShares`ATTACHMENT'
		rename current_market_cap_share_class MVBloom`ATTACHMENT'
		rename bs_sh_out EndNoShares`ATTACHMENT'
	
		tostring MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT', replace force
	
		foreach var of varlist MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT' {
			replace `var' = "" if `var' == "#N/A N/A"
		}

		destring MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT', replace
		recast double MVCBloom`ATTACHMENT' NoShares`ATTACHMENT' MVBloom`ATTACHMENT' EndNoShares`ATTACHMENT'

		if `i'== 274 { 						// 274, because firm 275 is missing (download was made also for non-SSIP firms; hence n > 241)
			cd "${STANDARD_FOLDER}\3_Datasets"
			save `SAVENAME', replace

		}

		else {
			cd "${STANDARD_FOLDER}\3_Datasets"
			append using `SAVENAME'
			save `SAVENAME', replace
		}
	}
}

order id Company
sort id Date

replace Company = "HOLN VX Equity" if Company == "LHN VX Equity" 	// because of Ticker change from HOLN to LHN. To match with older dataset, ticker needs to be updated
replace Company = "KABN SE Equity" if Company == "DOKA SW Equity" 	// because of Ticker change from KABN to DOKA. To match with older dataset, ticker needs to be updated

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE_MV_DAILY', replace

*********************************************************************
*********************************************************************
************ III. Create Main Dataset for 10_Merge  *****************
*********************************************************************
*********************************************************************


********************************************
*********** Generate Key Variables *********
********************************************
cd "${STANDARD_FOLDER}\3_Datasets"
use FullMerge, replace 													// starts with balanced panel

* Merge with daily market values
merge m:1 Company Date using "`SAVEFILE_MV_DAILY'", keepusing(MVBloomAllNo) assert(match master using) // Market values are only needed for the weighted effective spreads calculation
drop if _merge == 2
drop _merge
compress

* Generate time-related variables
drop time
gen Hour 	= hh(DateTime)
gen Minute 	= mm(DateTime)
gen Weekday = dow(Date)
gen Week 	= week(Date)
gen HourMin = Hour*100+Min

drop if Hour == 17 & Minute == 31								// This is done to obtain 510 observations before collapse (i.e., can be divided by 30)

preserve
	keep if ID == 1
	bys Date: count
	assert `r(N)' == 510
restore

* Generate 30 minutes intraday time period (MINUTESGROUP=30)
sort ID DateTime

scalar MINUTESGROUP = 30 										// Here define how many values should be grouped together for the intraday analyses. 30min == 30

count if ID == 1 												// Assumption, all IDs have same length _N, i.e. balanced panel; asserted above
scalar MAX = r(N)/MINUTESGROUP 									// Assumption, all IDs have same length _N, i.e. balanced panel; asserted above

* Routine to verify that MAX is an integer
assert mod(`=scalar(MAX)',1) == 0

sort ID DateTime
by ID: gen number = _n - 1  + MINUTESGROUP 						// i.e. first observation equals scalar MINUTESGROUP
by ID: gen indicator = int(number/MINUTESGROUP) 				// i.e. divide by MINUTESGROUP and take integer
drop number

* Drop opening and closing auction
drop if Hour == 17 	& Minute >= 20								// Closing auction starts at 17.20								
drop if Hour == 9	& Minute <= 2								// Opening auction ends at 09.02 at the latest


********************************************
*********** Fill-up variables **************
********************************************

sort ID DateTime
foreach x of varlist Company {
	by ID: replace `x' = `x'[_n-1] 		if missing(`x')
}

gsort +ID -DateTime
foreach x of varlist Company {
	by ID: replace `x' = `x'[_n-1] 		if missing(`x')
}

* Calculate Staleness of Bid-Ask Spread for untabulated robustness test (Part 1)

gen SameAsk = missing(LastPriceAsk)
gen SameBid = missing(LastPriceBid)

sort ID DateTime
sort ID Date HourMin
by ID Date: replace SameAsk = SameAsk[_n-1] + 1 if missing(LastPriceAsk)
by ID Date: replace SameBid = SameBid[_n-1] + 1 if missing(LastPriceBid)
gen RelativeStale = abs(SameAsk - SameBid)

*Like McInish carry quotes forward within a day, but not across dates

sort ID DateTime
sort ID Date HourMin
foreach x of varlist LastPrice* {
	by ID Date: replace `x' = `x'[_n-1] if missing(`x') 		// Assumption: lastPrice is still lastPrice on the very same day (i.e. intraday)
}

* replace missing volumes by 0
foreach y of varlist Active* NumberTicks* Volume* Value*{
	replace `y' = 0 if missing(`y')
}

*Generate dummy variable as Post indicator
generate AfterSNB = cond(DateTime>tc(15-jan-2015 10:30),1,0)

****************************************************
*********** Calculate Bid-Ask Spreads **************
****************************************************

* Calculate minute-by-minute spreads
gen BidAskSpreadMinute = (LastPriceAsk-LastPriceBid)/(LastPriceAsk+LastPriceBid)*200 if (LastPriceAsk-LastPriceBid) >= 0 // * 100 for readability in descriptive table

* Calculate minute-by-minute effective spreads
gen Midpoint 			= (LastPriceAsk+LastPriceBid)/2

gen EffSpread_No_W 		= abs(LastPriceTrade - Midpoint)*2 if NumberTicksTrade > 0
gen EffSpread_W_M		= abs(LastPriceTrade - Midpoint)*2*(ValueTrade/MVBloomAllNo) if NumberTicksTrade > 0

drop MVBloomAllNo

sort ID Date HourMin

*Calculate spreads in 30 min intervals (for intraday analysis)
sort ID indicator
by ID: assert DateTime[_n] > DateTime[_n-1] if _n > 1 // Assert that sorting is correct

by ID indicator: egen MeanTimeBidAskSpread = mean(BidAskSpreadMinute) 

*Calculate daily spreads (for daily analyses)
sort ID Date HourMin
by ID Date: egen MeanDateBidAskSpread = mean(BidAskSpreadMinute)
by ID Date: egen MeanDateEffSpread_No_W = mean(EffSpread_No_W)
by ID Date: egen MeanDateEffSpread_W_M 	= mean(EffSpread_W_M)

* Calculate Staleness of bid-ask spread (Part 2)--> Create Staleness indicator for untabulated robustness test
sort ID Date HourMin
by ID Date: egen MeanRelativeStale 	= mean(RelativeStale)


drop BidAskSpreadMinute EffSpread_No_W EffSpread_W_M

* Aggregate Trading Volumes within each 30 minute interval
sort ID Date HourMin
sort ID indicator
by ID: assert DateTime[_n] > DateTime[_n-1] if _n > 1 // Assert that sorting is correct

foreach x of varlist Value* Volume* NumberTicks* Active* {
	by ID indicator: replace `x' = sum(`x') 			
}

* Only keep the last observation for each 30 minute interval
by ID indicator: keep if _n ==_N

drop indicator

xtset ID DateTime

************************************************************
*** Remove firms that are duplicates or too illiquid *******
************************************************************

sort ID DateTime

drop if Date<td(01oct2014)
drop if Date>td(30apr2015)

*Drop duplicate firms

drop if Company == "SCHN SE Equity" 				// ID = 181 SCHN SE (because duplicate with ID 182 SCHP VX and less liquid stock)
drop if Company == "UHRN SE Equity" 				// ID = 219 UHRN SE (because duplicate with ID 218 UHR VX and less liquid stock)
drop if Company == "LISN SE Equity" 				// ID = 125 LISN SE (because duplicate with ID 126 LISP SE and less liquid stock)
drop if Company == "RO SE Equity" 					// ID = 175 RO SE (because duplicate with ID 176 ROG VX and less liquid stock)

*Table 1 Line 1: Initial Sample
preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 237
restore

* Verify that data is a valid&balanced panel
sort ID Date
xtdescribe
assert `r(min)' == `r(max)' 											// Same number of observations

*Delete observations with insufficient number of trades
distinct Date
scalar NumberDay = `r(ndistinct)'

bys ID: egen TRADES = sum(NumberTicksTrade) 
keep if TRADES 		> scalar(NumberDay)*10								// Requirement: At least 10 trades per Day

*Table 1 Line 2: Removed 63 firms due to insufficient trades

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 174
restore

distinct HourMin
scalar TimeSlots = `r(ndistinct)'

*Delete observations with too few updated bid-ask-spreads

gen missingBS = missing(MeanDateBidAskSpread)				
bys ID: egen FirmMissingBS = sum(missingBS)
drop if FirmMissingBS > scalar(TimeSlots)*3							// Requirement: Updated BidAskSpread on 141 of 144 days (i.e., drop if at least 3 missings)

drop TRADES FirmMissingBS FirmMissingBS

*Table 1 Line 3: Removed 15 firms due to insufficient bid-ask spreads

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 159
restore

************************************************
*********** Carry-forward Prices  **************
************************************************

sort ID DateTime
foreach x of varlist LastPriceTrade { 								// Carry Trade-Prices (but not bid or ask prices) over night
	by ID: replace `x' = `x'[_n-1] if missing(`x')
}


************************************************
*********** Save File for 10_Merge  ************
************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE_BLOOM_MERGE', replace

*********************************************************************
*********************************************************************
************ IV. Create Other Datasets for 10_Merge  ****************
*********************************************************************
*********************************************************************

********************************************
* Generate End-of-Day Prices for each Date *
********************************************

use TradeAll.dta, replace // For end-of-day prices, the last valid price is needed (i.e., including closing auction if applicable)

gen Hour 	= hh(DateTime)
gen Minute 	= mm(DateTime)

gen HourMin = Hour*100+Min
gen Date 	= dofc(DateTime)
format %td Date

sort ID Date DateTime
count if missing(LastPriceTrade)
	assert `r(N)' == 0 // Ensures that last value on a day is not missing

by ID Date: keep if _n == _N // keep last price per day

drop DateTime

xtset ID Date, delta(1 day)
	tsfill, full

by ID: replace LastPriceTrade = LastPriceTrade[_n-1] if missing(LastPriceTrade) // because of tsfill
by ID: gen BeforePXLast = LastPriceTrade[_n-1] // carry forward prices if no share price at a given day (only relevant for the first day of the panel)

keep ID Date LastPriceTrade BeforePXLast

rename LastPriceTrade PXLast // Price at the end of the day for each day

save `SAVEFILE_PX_LAST', replace
erase TradeAll.dta

******************************************************
******* Generate Rolling Return Volatility for *******
****************** Intrady Analyses ******************
******************************************************
cd "${STANDARD_FOLDER}\3_Datasets"
										
use `SAVEFILE_BLOOM_MERGE', replace											// starts with balanced panel
sort ID DateTime 

* Conduct consistency checks

qui xtset ID DateTime
xtdescribe

assert `r(N)' == 159													// Sample is correct, final sample is 151 observations; but here 159 because based on  BloombergMerge file (and not after further sample filters in 10_Merge_Datafiles)
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum Date, detail
local MINDATE = `r(min)'

qui sum ID, detail
local MINID =`r(min)'

count if Date == `MINDATE' & ID == `MINID'

scalar INTRADAYOBS = `r(N)'												// Set number of Intraday observations for changes

assert scalar(INTRADAYOBS) == 17										


sum ID if HourMin <= 1030 & Date == `MINDATE' & ID == `MINID', detail
assert `r(N)' == 3
global UNTIL1030 = `r(N)'

keep ID DateTime LastPriceTrade

*Generate Logarithmic Returns
sort ID DateTime 
by ID: 	gen LogReturn = log(LastPriceTrade/LastPriceTrade[_n-1])		 
	replace LogReturn 	= 0 if missing(LogReturn)						//  Only needs to be replaced for Oct 1 (actually irrelevant since not part of the estimation window)

* Generate Rolling SD
sort ID DateTime
by ID: gen CONT = _n
xtset ID CONT 			// necessary for rollstat command
rollstat LogReturn, statistic(sd) w(`=scalar(INTRADAYOBS)')
drop CONT

xtset ID DateTime
sort ID DateTime
by ID: gen SDRolling= _sd17_LogReturn


drop _sd17_LogReturn

cd "${STANDARD_FOLDER}\3_Datasets"

save `ROLLINGVOL', replace

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Hand-Collected data based on firms' annual report 2013 (Downloaded reports in April and May 2015):
/*Excel file that contains the hand collected data based on firms most recent annual report before Jan 15, 2015.
This Excel file contains three main variables that were manually collected and coded:  Risk Disclosure (Score from 1 to 7),  IntSales (from 0 to 1) and ReportLength (# Pages). 
It also contains the sub-scores of the Risk Disclosure score (for IA Table A3) */

local REPORT_HAND_COLLECTED = "HandCollected_Report_Data.xlsx"

*** OUTPUT:

local SAVEFILE1 = "ReportData.dta"

***********************************************
************* Import Excel File ***************
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel `REPORT_HAND_COLLECTED', sheet("Data") cellrange(A2:AT244) firstrow

rename BloombergCode Company
keep if Include == 1 // Variable that shows whether the firm is in the final sample or not (drop step is not necessary, but allows to use perfect match assert command in 10_Merge file)
destring IntSales, replace

keep Company RiskDisclosure Revenues2013 Assets2013 CostsProfits2013 Monetary2013 FXExposure2013 Hedging2013 FXSensitivity2013 IntSales ReportLength

drop if missing(Company)

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace


exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}


***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

*** INPUT:

*1. Datastream/Worldscope File (Various download dates depending on variables, see Datasheet):
/*File that contains the Datastream & Worldscope data via the Datastream Request Table in Excel. 
Each Variable is contained in a separate worksheet.  */

local DS_WORLDSCOPE = "SwissFrancRequestTable_DS.xlsx"


*2. Swiss Disclosure Ranking 2014 from the Swiss Finance Institute (i.e., scoring for 2013 annual reports) (Downloaded on June 22, 2015):
/*Ranking from https://www.bf.uzh.ch/en/research/studies/value-reporting.html. Names are manually matched to Bloomberg Codes. 
Additionally, the Datastream and IBES identifiers are also manually matched to these firms and added to this file (i.e., also functions
as a linking table between Bloomberg and Datastream)   */

local DISC_RANKING = "Ranking_DS_Bloomberg_Match_Data.xlsx"

*3. IBES Weekly Coverage Data (Downloaded on August 20, 2015):
/*Weekly IBES data, which is used to compute analyst following. Data was downloaded via Thomson Reuters Spreadsheet Link 
and hence the downloaded data is contained in an excel file.*/

local IBES_SPREADSHEET = "IBES_Swiss_Weekly_IBES_COPY.xlsx"

*4. Datastream Download of Exchange Rates and Total Return Index (Downloaded on June 8, 2017):
/*Downloaded via Datastream Request Table in Excel. Used to calculate correlations between stock returns and changes in foreign exchange rates.*/

local DS_FX_TRI = "FX-TRI-Datastream.xlsx"

	
*** OUTPUT:

local SAVEFILE = "Datastream_IBES_Final.dta"

***********************************************
***** Import non-market variables from DS *****
***********************************************

tempfile SwissDatastream

cd "${STANDARD_FOLDER}\1_Sources\Datastream"

* Import Excel File with data
qui import excel using `DS_WORLDSCOPE', describe
scalar MAXLOOP = `r(N_worksheet)'-1 // Adjustment -1 because of RequestTable

forvalues i=`=scalar(MAXLOOP)'(-1)1 {
	if `i' == 1 {
	
		cd "${STANDARD_FOLDER}\1_Sources\Datastream"
		
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i')  cellrange(A1) firstrow allstring case(lower) clear
		
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
		}
		
		gen idx = _n 										// idx_is internal merge code
		
	}	
	else {
	
		cd "${STANDARD_FOLDER}\1_Sources\Datastream"
	
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i') cellrange(A5:A5) clear
		local TEMPORARY = A[1]
		local ADD = lower(strtoname(substr("`TEMPORARY'",11,27)))
		import excel using `DS_WORLDSCOPE', sheet(Sheet`i')  cellrange(B4) allstring firstrow case(lower) clear
		
		* Extract names and label
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
			destring `var', replace float
			local label : variable label `var'
			local new_name = lower("`label'")
			rename `var' `ADD'`new_name'
		}
		
		gen idx = _n 										// idx_is internal merge code
		reshape long "`ADD'", i(idx) j(year)
	}
	if `i'== `=scalar(MAXLOOP)' {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		save `SwissDatastream', replace
		
  }
	else if `i' == 1 {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:m idx using `SwissDatastream', assert(match)
		drop _merge
  }
	else {
	
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:1 idx year using `SwissDatastream', assert(match)
	
		drop _merge
		
		save `SwissDatastream', replace
  }
}

order dscd idx name year
drop if missing(dscd)
rename dscd Type

* Save Datastream & Worldscope
cd "${STANDARD_FOLDER}\3_Datasets"
save `SwissDatastream', replace

*******************************************************
**** Historical Correlations Swiss-EUR and Swiss-USD **
*******************************************************

tempfile HistCorr

cd "${STANDARD_FOLDER}\1_Sources\Datastream"

* Import exchange rate from excel worksheet
import excel `DS_FX_TRI', sheet("Sheet2") cellrange(A2:C2613) firstrow clear

save `HistCorr'.dta, replace

* Import firms' total return indices from same excel worksheet
import excel `DS_FX_TRI', sheet("Sheet1") firstrow clear
drop if _n == 1
foreach var of varlist _all {
	replace `var' = "" if `var'== "NA"
	destring `var', replace
	}
	
generate Code = date(Name, "MDY")
drop Name
format Code %td
order Code

cd "${STANDARD_FOLDER}\3_Datasets"

* Merge both files (TRI and exchange rates)
merge 1:1 Code using `HistCorr'.dta
drop _merge
order Code SWEURSPER SWISSFER 
rename Code Date

* Calculate correlations on a weekly basis (weekly instead of daily correlations) to reduce the liquidity impact
gen DateWeek = wofd(Date)
sort DateWeek Date			
order DateWeek, after(Date)
format DateWeek %tw

foreach var of varlist SWISSFER SWEURSPER ABBLTDN-ZWAHLENMAYR  {
	by DateWeek: gen B_`var' = `var'[1]
	by DateWeek: gen E_`var' = `var'[_N]

}

by DateWeek: keep if _n == 1

* Calculate weekly changes of exchange rates and return indices
foreach var of varlist SWEURSPER SWISSFER ABBLTDN-ZWAHLENMAYR {
	gen ret_`var' = log(E_`var'/B_`var')
	}

* Calculate correlations for EUR before minimum exchange rate regime and USD during minimum exchange rate regime
local i = 0
foreach var of varlist ret_ABBLTDN-ret_ZWAHLENMAYR {
	local i = `i' + 1

* Calculate USD and firms' return correlation
	qui sum `var' if Date<td(15jan2015) & Date >= td(15jan2012), detail // Covering Period during Minimum Exchange Rate Regime
	
	if r(N) == 0 {	
		scalar USD_`i' = .
	}
	
	else {
		qui corr ret_SWISSFER `var' if Date<td(15jan2015) & Date >= td(15jan2012) // Covering Period during Minimum Exchange Rate Regime
		scalar USD_`i' = r(rho)
	}

* Calculate EUR and firms' return correlation
	qui sum `var' if Date<td(6sep2011) & Date >= td(6sep2008), detail // Covering Period before Minimum Exchange Rate Regime
	
	if r(N) == 0 {		
		scalar EUR_`i' = .
	}
	
	else {
		qui corr ret_SWEURSPER `var' if Date<td(6sep2011) & Date >= td(6sep2008) // Covering Period before Minimum Exchange Rate Regime
		scalar EUR_`i' = r(rho)
	}
}
qui d
global OBS = (r(k) - 2)/4  - 2 
assert ${OBS} == 241

* Generate dataset that contains both correlations
clear
set obs 241
generate idx = _n
generate HistCorrEUR = 0
generate HistCorrUSD = 0


foreach x of numlist 1/241 {
	replace HistCorrEUR = EUR_`x' if _n == `x'
	replace HistCorrUSD = USD_`x' if _n == `x'

}

save `HistCorr', replace

*******************************************************
************** Import Ranking File ********************
**** (also contains the manually linked Bloomberg *****
*********** & Datastream Identifiers) *****************
*******************************************************

tempfile temporary

cd "${STANDARD_FOLDER}\1_Sources\Other"

* Import excel file
import excel using `DISC_RANKING', sheet(Matched)  cellrange(A2) firstrow case(lower) clear

keep type bloombergcode tonecodeshort gesamtnote
drop if missing(type)

* Rename variables
rename bloombergcode Company
rename gesamtnote DisclosureRank
rename tonecodeshort IBESMatchCode
rename type Type

cd "${STANDARD_FOLDER}\3_Datasets"
save `temporary', replace

* Merge Files
use `SwissDatastream', replace
merge m:1 Type using `temporary', assert(match)
drop _merge

merge m:1 idx using `HistCorr', assert(match)
drop _merge

sort idx year
save `SwissDatastream', replace

***************************************************
******** Clean Dataset and Rename Variables *******
***************************************************

tempfile TempDatastream

* Rename and prepare variables
rename idx IDX // IDX is not ID (which is part of the Bloomberg Dataset)
rename name DatastreamName
rename year Year
format Year %ty // change format for Panel Dataset
rename mnem Mnem
rename acur AccountingCurrency
rename wc07021 SICCode
rename isocur	ISOCurrStock
rename isin ISIN
drop ggisn
rename pcur PriceCurrency
rename wc05427 StockExchanges
rename international_sales InternationalSales
rename net_sales_or_revenues TotalSales
rename date_of_fiscal_year_end FYEnd
rename accounting_standards_follow AccountingStandards
rename __free_float_nosh NoshFF

foreach x of varlist Mnem-StockExchanges {
	replace `x' ="" if inlist(`x',"NA") // Create missing values
}

xtset IDX Year, delta(1 year)

save `SwissDatastream', replace

*Generate relevant variables
generate SIC1 = substr(SICCode,1,1)
destring SIC1, replace
generate IFRS = strpos(AccountingStandards, "IFRS") >= 1
generate USGAAP = strpos(AccountingStandards, "GAAP") >= 1
generate LocalStandards = strpos(AccountingStandards, "Local") >= 1
gen InternationalStandards = USGAAP == 1 | IFRS == 1
replace NoshFF = NoshFF/100 // (Makes variable more readable in tables)

*Replace NoshFF for a single firm. For this firm, NOSH data is only missing in this year. Thus use the 2014 data in the 2013 field for this firm
replace NoshFF = NoshFF[_n+1] if Type == "92219M" & Year == 2013

* Use data from fiscal year which is closest to Swiss Franc Shock (but precedes the Swiss Franc Shock)
gen FYE = date(FYEnd, "MDY")
drop FYEnd
rename FYE FYEnd
format FYEnd %td

keep if Year == 2013 | Year == 2014
gen MONTH = month(FYEnd)

drop if MONTH < 12 & Year == 2013
drop if MONTH == 12 & Year == 2014 

sort IDX Year
by IDX:  drop if _n == 2 // Drop year 2014 --> Yields same number of obs (no duplicates) as just drop Year 2013

save `TempDatastream', replace

********************************************
************* Import from IBES *************
********************************************

tempfile SwissIBESToMerge SwissTempIBES

* Import IBES File
cd "${STANDARD_FOLDER}\1_Sources\IBES"
qui import excel using `IBES_SPREADSHEET', describe

return list
forvalues i = 2/`r(N_worksheet)' { 
	cd "${STANDARD_FOLDER}\1_Sources\IBES"
	if `i' == 2 {

		import excel using `IBES_SPREADSHEET', sheet(`r(worksheet_`i')') cellrange(A1) allstring firstrow case(lower)  clear
		
		foreach var of varlist _all {
			replace `var' = "" if `var' == "NA" | substr(`var',1,2)== "$$" | `var' == "N/A"
		}
		
		gen idx = _n 										// idx_is internal merge code
		keep idx name tickerfordownload matchingwtr
		order idx name tickerfordownload matchingwtr
		
	}	
	
	else  {
		import excel using `IBES_SPREADSHEET', describe
		local TEMPORARY = r(worksheet_`i')
		import excel using `IBES_SPREADSHEET', sheet(`r(worksheet_`i')')  cellrange(C2)  clear
		scalar COUNTER = td(3-jan-2014) -7 										// Start Date is 3-jan-2014 according to TSL
		
		foreach var of varlist _all {
			scalar COUNTER = COUNTER + 7 										// 20091 is star
			rename `var' `TEMPORARY'`=scalar(COUNTER)'
		}
		
		gen idx = _n // idx_is internal merge code
		reshape long "`r(worksheet_`i')'", i(idx) j(week)
	}
	
	if `i'== 2 {
		cd "${STANDARD_FOLDER}\3_Datasets"
		save `SwissTempIBES', replace
	}
	
	else if `i'== 3 {
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge m:1 idx using `SwissTempIBES', assert(match)
		drop _merge
		save `SwissTempIBES', replace
	}
	
	else {
		cd "${STANDARD_FOLDER}\3_Datasets"
		merge 1:1 idx week using `SwissTempIBES', assert(match) // now 1:1 because of reshape
		drop _merge
		save `SwissTempIBES', replace
	}
}

format week %tdMonth_DD,_CCYY

foreach var of varlist EPSCurrencyFY2-NumberOfAnalystsFY1 {
	replace `var' = "" if `var' == "N/A"
	}

* Generate Number of analysts variable
destring NumberOfAnalystsFY1, replace
replace NumberOfAnalystsFY1 = 0 		if NumberOfAnalystsFY1 == . 				// Continuous Analyst Coverage Var
rename NumberOfAnalystsFY1 NumberOfAnalysts

cd "${STANDARD_FOLDER}\3_Datasets"

* Prepare data file for matching
order matchingwtr name
rename matchingwtr IBESMatchCode

	
save SwissTempIBES, replace

* Only keep one weekly observation
by idx: keep if _n == 54 		// this is the last observation (week) just before SNB Shock
drop idx week 					// no longer needed
	
save `SwissIBESToMerge', replace

*************************************
***** Merge IBES and Datastream *****
*************************************

use `TempDatastream', replace
	
merge 1:1 IBESMatchCode using `SwissIBESToMerge'			
	tab _merge
	keep if _merge == 3 					
	drop _merge
	
save `SAVEFILE', replace


exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"


***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Excel-File that contains Swiss ADRs (Downloaded and created in August, 2019):
/*List of Swiss Cross-Listing via Archive.org copy (December 25, 2014) of TopForeignStocks.pdf (cross-verified with adrbnymellon.com).
This list was copied in ab excel file and the ticker symbols were matched to Datastream's Type identifier (manually verified matches) */

local SWISS_ADR_EXCEL = "Swiss-ADRs.xlsx"

*2a. Excel-File that contains LinkedIn Data (Collected in September 2019):
/*Excel file that holds the manually collected LinkedIn data. Contains the numbers of hits of a LinkedIn search (i.e., number of employees) combining a certain firm name
 and an additional search query (e.g., job position that has ‘risk’ in the title). */

local LINKEDIN_DATA = "LinkedIn_DataCollection.xlsx"

*2b. Risk MGTMT Data from 2013 Annual Reports (Downloaded reports in April and May 2015):
/* Hand-Collected data from firms 2013 annual reports. Holds various variables (e.g., whether a firm has a Chief_Risk officer) related to risk management and hedging. */

local ADDITIONAL_REPORT_DATA = "Risk_Hedging_Report_DataCollection.xlsx"


*3a. IR Club indicator (Received in May 2016):
/*Excel-File that contains indicator variable whether a firm belongs to the IR Club (=1) or not (=0) 
(Information comes from our contact at the IR Club, variable is manually coded in Excel)*/

local IR_CLUB = "IRClub_Indicator"

*3b. IR Position (Collected in April and May 2016):
/*Manually collected excel file that contains, among other things, the job title of the most senior IR employee at the company. 
This data was originally collected for the investor relations survey from two main sources: firm webpages and SIX stock exchange web page.*/

local IR_POSITION = "Hand_SIX_Merge_Main_Sample"

*4a. For new information variables: IBES Detail Data (Downloaded on May 17, 2018):
/* Detailed Coverage IBES data (downloaded via WRDS at a later date compared to the Weekly Coverage Data). First IBES Codes were downloaded via Datastream (IBES-Ticker Excel file) 
and then the IBES Detail History Data for those firms was downloaded */

local IBES_CODES = "IBES_Ticker.xlsx"
local IBES_DETAIL_DATA = "Swiss_IBES_Detail_Data.dta"


*4b. For new information variables: Factiva Hand Collected File (Collected and coded from December 2019 until February 2020):
/* Excel file contains all articles that where found within the Factiva-SNB Research. Each worksheet within the excel file contains the data for one firm (each line is a different article).
Articles were read and relevant articles were coded as '1'. */
local FACTIVA_DATA = "Factiva_Hand_Collected_Files.xlsx"

*5.  SMI All Share Index and CHF-EUR Exchange Rate (Downloaded August 8, 2016): 
/* File for Figure 1 (via Datastream Download) that contains exchange rates and the Swiss All Share index  */

local ALL_SHARE_INDEX = "SMI-All-Share-CHF-EUR.xlsx"

*** OTHER INPUT FILES:
local DATASTREAM_IBES = "Datastream_IBES_Final.dta" // From 03_Import_DatastreamIBES.do
local ACTUAL_SAMPLE = "ActualSample151.dta" 		// To verify whether the sample is unchanged and OK (generated once based on the final sample)
local TRADING_FILE = "TradingDays.dta"				// Already referenced in 01_Import_Bloomberg 

*** OUTPUT:

local SAVEFILE1 = "SwissCrossListing.dta"

local SAVEFILE2 = "RiskHedgingData.dta"

local SAVEFILE3 = "IR_DataArchival.dta"

local SAVEFILE4 = "NewInformationData.dta"

local SAVEFILE5 = "SMI_AllShare_CHF_EUR.dta"

***********************************************
***********************************************
************ Import Excel Files **************
***********************************************
***********************************************

***********************************************
********* 1. Import Cross-Listings ************
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel `SWISS_ADR_EXCEL', firstrow clear
keep Type CrossListingType // Three types: 'Real':  U.S. exchange cross-listing, 'S': Sponsored ADR, 'U': Unsponsored ADR
drop if missing(Type) 

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace


***********************************************
******* 2. Import Risk MGTM, Hedging, *********
*********** Direct Communication **************
***********************************************

*** Import LinkedIn File

tempfile LINKEDIN REPORT

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel using `LINKEDIN_DATA', firstrow clear

destring investor_position, replace

keep Type NAME Inc_Linkedin-Other_comment2
drop if missing(Type) 			// Just one Empty Row


gen LogRiskLinkedin 		= log(1 + risk_position) if !missing(risk_position) 			// risk_position: Number of employees whose current job position has ‘risk’ in the title
gen LogHedgeKeyLinkedin  	= log(1 + hedging_keyword) if !missing(hedging_keyword) 		// hedging_keyword: Number of employees whose current job profile contains the term ‘hedging'
gen Log_IR_Linkedin 		= log(1 + investor_position) if !missing(investor_position)		// investor_position: Number of employees whose current job position has ‘IR’ or ‘investor relations’ in the title

save `LINKEDIN', replace

*** Import Additional Report File

import excel using `ADDITIONAL_REPORT_DATA', firstrow clear
drop if missing(Type) 

keep Type RiskCommitteeYesNo ChiefRiskYesNo RiskManagementenglishgerman Hedging NaturalOperationalHedge EconomicHedgeeconomicallyhe

* Generate Report-based variables
rename RiskManagementenglishgerman NumberofRiskManagement // Counts of how often Risk Management is mentioned in report

foreach VAR of varlist NaturalOperationalHedge EconomicHedgeeconomicallyhe {
	replace `VAR' = 0 if missing(`VAR' )
}

gen Sum_Hedge = (NaturalOperationalHedge + EconomicHedgeeconomicallyhe) // Add up how often 'natural hedging' or 'economic hedging' is mentioned in report.
gen  EconHedgeYesNo = Sum_Hedge > 0 if !missing(Sum_Hedge)			 	// Create Dummy Variable with 1: at least once mentioned, 0: Not mentioned at all.
drop Sum_Hedge EconomicHedgeeconomicallyhe NaturalOperationalHedge

gen RiskCommittee = 1 if RiskCommitteeYesNo == "Yes"
replace RiskCommittee = 0 if RiskCommitteeYesNo == "No"

gen ChiefRisk = 1 if ChiefRiskYesNo == "Yes"
replace ChiefRisk = 0 if ChiefRiskYesNo == "No"

drop RiskCommitteeYesNo ChiefRiskYesNo


save `REPORT', replace

* Merge LinkedIn and Report files
use `LINKEDIN', replace

merge 1:1 Type using `REPORT', assert(match) nogenerate

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE2', replace

***********************************************
************* 3. Import IR Data ***************
***********************************************

tempfile IRClub_Data

cd "${STANDARD_FOLDER}\1_Sources\Other"

* Import IR_Club variable
import excel using `IR_CLUB', firstrow clear

rename IRCLUB IR_Club

save `IRClub_Data', replace

* Import Lead_IR variable
import excel using `IR_POSITION', firstrow sheet("Overview") cellrange(A2) clear

tab Position
gen Lead_IR = (inlist(Position, "CCO", "CCO & IR", "Director IR", "Head of Financial Services", "Head of IR") | ///
				 inlist(Position, "Head of IR/CCO", "Leiterin Corporate Communications", "Senior IR", "VP IR")) if !missing(Position)

* Merge Files Together
merge 1:1 ID using `IRClub_Data'

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE3', replace

***********************************************
****** 4. Collect Post-Shock Info Data ********
***********************************************

***********************************************
***** 4a. Import Additional IBES Data *********
***********************************************

* Import IBES ticker
tempfile IBES_CODE_DTA IBES_FORECAST_DATA

cd "${STANDARD_FOLDER}\1_Sources\IBES"

import excel using "`IBES_CODES'", sheet(Sheet1) clear cellrange(A2) firstrow

rename IBTKR ticker // ticker is the IBES Code for the merge

cd "${STANDARD_FOLDER}\3_Datasets"

save `IBES_CODE_DTA', replace

* Import Detailed IBES data
cd "${STANDARD_FOLDER}\1_Sources\IBES"

use "`IBES_DETAIL_DATA'", replace

keep if measure == "EPS"

sort analys ticker anndats anntims

gen Hour = substr(anntims,1,2)
destring Hour, replace

gen Min = substr(anntims,4,2)
destring Min, replace

* Adjust for local Swiss time
gen ann_new = anndats
replace ann_new = anndats + 1 if (Hour >= 12 | (Hour == 11 & Min > 30)) // Adjust for local Swiss time (i.e.,  after 11.30 [5.30pm Swiss time] it only affects the next trading day)

sort analys ticker ann_new
*  Keep only one EPS Forecast per analyst covering a given firm per day
bys analys ticker ann_new: keep if _n == 1


format %td ann_new
drop if ann_new  < td(01dec2014)
drop if ann_new  > td(28feb2015)

count
* Collapse dataset to firm-day dataset
collapse (count) EPS_Revision = analys, by(ann_new ticker)

rename ann_new Date

cd "${STANDARD_FOLDER}\3_Datasets"

save `IBES_FORECAST_DATA', replace


***********************************************
********** 4b. Import Factiva Data ************
***********************************************

tempfile NEWS_SEARCH

cd "${STANDARD_FOLDER}\1_Sources\Other"

import excel using "`FACTIVA_DATA'", describe

forvalues i=1/`r(N_worksheet)' {
	local j = `j' + 1
    import excel using "`FACTIVA_DATA'", sheet(`"`r(worksheet_`i')'"') firstrow clear allstring
    save Save_Sheet`j', replace
    local z = `j'
}
use Save_Sheet1.dta
erase Save_Sheet1.dta

forvalues j=2/`z' {
	append using Save_Sheet`j'.dta
	erase Save_Sheet`j'.dta

}

drop if F == "Tensid" // This is a Newswire Service that was initially missed (and included in the Factiva search)

keep firm_name doc_date  Relevant A
destring A, replace
gen date2 = date(doc_date, "DMY")
drop doc_date
format date2 %td
rename date2 Date
rename firm_name Type

gen RelevantSNBArticle 	= 1 if Relevant == "1"

* Collapse dataset to firm-day dataset
collapse (sum) News_SNB = RelevantSNBArticle, by(Type Date)

cd "${STANDARD_FOLDER}\3_Datasets"

save `NEWS_SEARCH', replace


***********************************************
****** 4c. Combine IBES & Factiva Data ********
***********************************************
cd "${STANDARD_FOLDER}\3_Datasets"

*** Merge Files from 4a and 4b in a Panel Dataset together
use "`DATASTREAM_IBES'", replace

keep Company ID Type ISIN
duplicates drop // Only one observation per firm (i.e., 151 firms)

* Ensure that only the 151 final sample firms are in the sample
merge 1:1 Company using "${STANDARD_FOLDER}\1_Sources\Verification\\`ACTUAL_SAMPLE'", assert(match master)
keep if _merge == 3
drop _merge

merge 1:1 Type using `IBES_CODE_DTA',assert(match using)
drop if _merge == 2
drop _merge

cross using  "${STANDARD_FOLDER}\1_Sources\Other\\`TRADING_FILE'"
sort ID Date

merge 1:1 ticker Date using  `IBES_FORECAST_DATA', assert(match master using)
drop if _merge == 2 
drop _merge

merge 1:1 Type Date using `NEWS_SEARCH', assert(match master)
drop if _merge == 2
drop _merge

order ID Date
drop if Date  < td(12nov2014) // The data collection for Factiva only started from 10dec2014 (but not relevant for analyses)
drop if Date  > td(12feb2015)
sum tradingdays

*** Make two minor adjustments to hand-collected
replace News_SNB = 1 if Type == "929910" & Date == td(30jan2015) // Relevant Article for one firm on January 30, which was not part of the Imported Excel-File (those two were the only two relevant articles that were missed in the excel file))
replace News_SNB = 1 if Type == "929910" & Date == td(31jan2015) // Relevant Article for one firm on January 31,which was not part of the Imported Excel-File (those two were the only two relevant articles that were missed in the excel file)


*** Carry forward non-trading day observations to trading day observations
sort ID Date
foreach VAR of varlist News_SNB EPS_Revision   {
	replace `VAR' = 0 if missing(`VAR')
	by ID: replace `VAR' = `VAR' + `VAR'[_n-1] if tradingdays[_n-1] == 0
}
drop if tradingdays == 0

*** Generate TotalNewInfo Variable

gen TotalNewInfo = News_SNB + EPS_Revision

keep ID Company Date EPS_Revision News_SNB TotalNewInfo

save `SAVEFILE4', replace



***********************************************
******* 5. Import Swiss All Share Index *******
***********************************************

cd "${STANDARD_FOLDER}\1_Sources\Datastream\"

import excel `ALL_SHARE_INDEX', sheet("Sheet1") cellrange(A5:I1721) firstrow clear
drop C E G H
rename Code Date
label var Date "Date"

rename SWIALSHRI AllShare
label var AllShare "TRI Swiss All Share"

rename SWISSMIRI SMI

rename PRIMALLRI Prime

rename SWEURSPER EURCHF
label var EURCHF "EUR-CHF Exchange Rate"

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE5', replace


exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"

capture cd ${STANDARD_FOLDER}

***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Qualtrics Output file for the analyst survey  (Downloaded from Qualtrics on June 21, 2016):
/*Results file directly exported from Qualtrics in a csv format */

local ANALYST_SURVEY = "SellSide_Analyst_Survey_Impact_of_Swiss_Franc_Shock.csv"

*** OUTPUT:

* None, all results for this survey are directly produced via code in this do-file

***********************************************
************* Import Dataset ******************
***********************************************
cd "1_Sources\Surveys"

import delimited "`ANALYST_SURVEY'", delimiter(comma) varnames(1) encoding("utf-8")

*******************************************
********* PREPARATION OF DATASET **********
*******************************************


************* Merge Analysts with covered firms ************
gen COUNT = _n
rename v5 EMail

* Removed emails for confidentiality reasons 

************* Rename and code questions ************
count
egen Random = group(dobrfl_15) in 2/`r(N)'

drop doqn93-v198 				// Drop Display Order
rename dobrfl_15 OrderQuestion8
tempvar SUBSTR
gen SUBSTR = substr(OrderQuestion8,-4,1)
replace OrderQuestion8 = SUBSTR
destring OrderQuestion8, force replace
drop v2-v4 v6-v9 				// Drop beginning info
drop n11 						// no question
drop n121_1_text n121_2_text 	// Contact data

rename v1 ResponseID
rename v10 FinishedIndicator

rename n21 Part1
rename n22 Q1
rename n23 Q2
rename n24_1 Q3
rename n25 Q4
rename n31 Part2
rename n32_1 Q5_Part1_1 // Not assessed
rename n32_2 Q5_Part1_2 // No material effect
rename n32_3 Q5_Part1_3 // Material Effect
rename n33_1 Q5_Part2_1 // Qualitative
rename n33_2 Q5_Part2_2 // Quantitative
rename n33_3 Q5_Part2_3 // Stock recommendation

forvalues i = 1/9 {

	rename n34_`i' Q6_`i'

}

rename n35 Q6_Comment
rename n36_1 Q7
/* have to rename variables here for later recodes */

rename n91 Part3_Part2
rename n101 Part4
rename n111 Demographics

forvalues i = 1/6 {
	rename n92_`i' Q10_`i' 		// Translational etc.
}

rename n93 Q11

forvalues i = 1/4 {
	rename n94_`i' Q12_`i' // 
}

rename n95 Q12_Comment

forvalues i = 4/6 { 			// Wrong coding in Qualtrics, adjust here
	local j = `i' -3
	rename n96_`i'_text Q13_Most`j'
	}
	
forvalues i = 1/3 {
	rename n97_`i'_text Q13_Least`i'
	}

forvalues i = 1/5 {
	rename n102_`i' Q14_`i'
	}

	rename n103 Q15

	rename n112_1 D1_1
	rename n112_2 D1_2
	
forvalues i = 4/15 {
	local z = `i' -1 		// Wrong coding in Qualtrics, adjust here
	rename n112_`i' D1_`z'
	}

rename n112_15_text D1_15

rename n113 D2

rename n114 D3

rename n115_1 D4

rename n116 D5

rename n117 D6

rename n117_text D6_text

rename n118 D7

rename n119 D8

rename n1110 D9

rename n122 OverallComments
	
	
egen Part3_Part1 = concat(n?1)

forvalues i = 1/9 {
	egen Q8_`i' = concat(n?2_`i')
	}

forvalues i = 1/9 {
	egen Q9_`i' = concat(n?3_x`i')
	}

egen Q9_Comment = concat(n?4)

	
drop n?1*
drop n?2*
drop n?3*
drop n?4*

gen SepQ8Q9 = "" // Needed for ordering (separating q8 and q9), needed for tests
	
order ResponseID EMail FinishedIndicator Part1 Q1 Q2 Q3 Q4 Part2 Q5* Q6* Q7 Part3_Part1 Q8* SepQ8Q9 Q9* Part3_Part2 Q10* Q11* Q12* Q13* Q14* Q15*
 
rename Q9_Comment Comment_Q9
rename Q12_Comment Comment_Q12
rename Q6_Comment Comment_Q6

replace Q14_3 = "Q14" if _n == 1 // because of error of quotation marks in label 
 
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}
  drop if _n == 1 // now drop label observation

foreach var of varlist FinishedIndicator-Q6_9 Q7-Q9_9 Part3_Part2-Q11 Q12* Q14_1-D1_14 D2-D6 D7-D9 {

	destring `var', replace
	replace `var' = . if `var' == -99
}

keep if FinishedIndicator == 1 
drop if missing(Q15) == 1
drop OverallComment 
replace Q7 = 0 if missing(Q7) // The slider's default position was at 0 %, but Qualtrics recorded a missing for those cases

****************** Rename Labels *******************

label variable 	Q1 "Importance BEFORE the shock"
label variable 	Q15 "Importance AFTER the shock"
label variable 	Q2 "Expectation about cap removal"
label define 	Q2 1 "< 3 months" 2 "3 - 6 months" 3 "6 - 12 months" 4 "12 - 24 months" 5 "> 24 months"
label values 	Q2 Q2
label var 		Q3 "% of covered firms which are affected"
label var 		Q4 "How is the typical firm affected"
label define 	Q4 1 "Very negatively" 2 "Negatively" 3 "Neutral" 4 "Positively" 5 "Very positively"
label values 	Q4 Q4
label var 		Q5_Part1_1 "% not assessed"
label var 		Q5_Part1_2 "% assessed but no material effect"
label var 		Q5_Part1_3 "% assessed and material effect"
label var 		Q5_Part2_1 "% (thereof) qualitative adjustment"
label var 		Q5_Part2_2 "% (thereof) quantitative adjustment"
label var 		Q5_Part2_3 "% (thereof) change in EF/SR"

label var Q6_1 "Clients"
label var Q6_2 "Internal departments"
label var Q6_3 "Peer pressure"
label var Q6_4 "Reputation"
label var Q6_5 "Job description"
label var Q6_6 "Availability firm info"
label var Q6_7 "Likely firm exposure"
label var Q6_8 "Firm complexity"
label var Q6_9 "Relative importance"

label var Q7 "% of firms (re-)assessed"

forvalues i = 8/9 {
	label variable Q`i'_1 "Personal knowledge"
	label variable Q`i'_2 "Private communication"
	label variable Q`i'_3 "Existing reports"
	label variable Q`i'_4 "Ad-hoc announcements"
	label variable Q`i'_5 "Peer firms"
	label variable Q`i'_6 "Media"
	label variable Q`i'_7 "Peer analysts"
	label variable Q`i'_8 "Stock price reactions"
	label variable Q`i'_9 "Commercial data providers"
}

label var Q10_1 "Translational exposure"
label var Q10_2 "Transactional exposure"
label var Q10_3 "Hedging strategy"
label var Q10_4 "One-time gains/losses"
label var Q10_5 "Sensitivity to indirect effects"
label var Q10_6 "Operating and strategic responses"

label var Q11 "Assessing the impact was..."

label define Q11 1 "Very similar" 2 "Relatively similar" 3 "More difficult for some"
label values Q11 Q11

label var Q12_1 "Complexity"
label var Q12_2 "Financial information"
label var Q12_3 "Volatility of business model"
label var Q12_4 "Uncertainty about responses"

label var Q13_Most1 "Most difficult 1"
label var Q13_Most2 "Most difficult 2"
label var Q13_Most3 "Most difficult 3"

label var Q13_Least1 "Least difficult 1"
label var Q13_Least2 "Least difficult 2"
label var Q13_Least3 "Least difficult 3"

label var Q14_1 "Quantitative inputs"
label var Q14_2 "Qualitative inputs"
label var Q14_3 "Adjustment of template"
label var Q14_4 "Switching to new template"
label var Q14_5 "Full reassessment"


label var D1_1 "Retail/Wholesale"
label var D1_2 "Construction"
label var D1_3 "Chemicals"
label var D1_4 "Software/Technology"
label var D1_5 "Health Care/Pharmaceuticals/Biotechnology"
label var D1_6 "Telecommunications/Media"
label var D1_7 "Insurance"
label var D1_8 "Real Estate"
label var D1_9 "Banks and other Finance"
label var D1_10 "Manufacturing Consumer Goods"
label var D1_11 "Manufacturing Industrials"
label var D1_12 "Consulting/Business Services"
label var D1_13 "Transportation/Energy/Utilities"
label var D1_14 "Other"

label var D2 "No. Industries"
label define INDUST 1 "1" 2 "2-3" 3 "4+"
label values D2 INDUST

label var D3 "No. Firms"
label define FIRMS 1 "1" 2 "2-4" 3 "5-9" 4 "10-15" 5 "16-25" 6 "25+"
label values D3 FIRMS

label var D4 "% Swiss Firms"

label var D5 "Age"
label define AGE 1 "<30" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60+"
label values D5 AGE

label var D6 "Education"
label define EDUCATION 1 "Bachelor" 2 "Master" 3 "CPA,CFA" 4 "PhD" 5 "Other"
label values D6 EDUCATION

label var D7 "Tenure"
label define TENURE 1 "1-3" 2 "4-9" 3 "10+" 
label values D7 TENURE

label var D8 "Employee Size"
label define SIZE 1 "1" 2 "2-4" 3 "5-10" 4 "11-25" 5 "26-50" 6 ">50"
label values D8 SIZE


label var D9 "Employee Headquarter"
label define HQ 1 "Switzerland" 2 "Europe" 3 "USA" 4 "ROW"
label values D9 HQ

gen SwissHQ = D9 == 1
gen EuropeHQ = D9 == 2

gen NumberFirmsSurvey = 1 		if D3 == 1 	// Mean value
replace NumberFirmsSurvey = 3 	if D3 == 2 	// Mean value
replace NumberFirmsSurvey = 7 	if D3 == 3 	// Mean value
replace NumberFirmsSurvey = 13 	if D3 == 4	// Mean value
replace NumberFirmsSurvey = 20 	if D3 == 5	// Mean value
replace NumberFirmsSurvey = 30 	if D3 == 5	// Mean value

gen SwissFirmsSurvey = D4 * NumberFirmsSurvey/100 

compress

*************************************
************** ANALYSIS *************
*************************************

run "${STANDARD_FOLDER}\2_Code\90_Additional_Survey_Code.do"

//Question 1
tab Q1, plot
tab Q1
sum Q1

//Question 15
tab Q15, plot
tab Q15
sum Q15

ttest Q1 == Q15

//Question 2
tab Q2, plot
tab Q2
sum Q2

//Question 3
tab Q3, plot
tab Q3
sum Q3

//Question 7
tab Q7, plot
tab Q7

sum Q7
ttest Q3 == Q7

//Question 4
tab Q4, plot
tab Q4
sum Q4

ttest Q4 == 3

//Question 5
fsum Q5*, label

//Question 6
fsum Q6*, label

quietly: orderquestion Q6, after(Q5_Part2_3) // Program written (see 90_Additional_Code.do) 

runtestquestion Q6, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 8 (Table 4: Panel A)
fsum Q8*, label

quietly: orderquestion Q8, after(Part3_Part1) // Program written (see 90_Additional_Code.do)

runtestquestion Q8, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 9 (Table 4: Panel B)
fsum Q9*, label

quietly: orderquestion Q9, after(SepQ8Q9) // Program written (see 90_Additional_Code.do)

runtestquestion Q9, signiveau(0.10) against(2) high(3) low(1) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

//Question 10 (Table 5: Panel A)
fsum Q10*, label

quietly: orderquestion Q10, after(Part3_Part2) // Program written (see 90_Additional_Code.do)

runtestquestion Q10, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

//Question 11
tab Q11, plot
tab Q11
sum Q11
ttest Q11 = 2

//Question 12 (Table 5: Panel B)
fsum Q12*, label

quietly: orderquestion Q12, after(Q11) // Program written (see 90_Additional_Code.do)

runtestquestion Q12, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Question 14
fsum Q14*, label

quietly: orderquestion Q14, after(Q13_Least3) // Program written (see 90_Additional_Code.do)

runtestquestion Q14, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code.do); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


//Demographics

preserve

foreach var of varlist D1* {
	replace `var' = `var'*100
}
fsum D1*, label

tab D2

tab D3

tab D4

tab D5

tab D6

tab D7

tab D8

restore

exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"

capture cd ${STANDARD_FOLDER}

***********************************************
****** Inputs and Outputs in this File ********
***********************************************

*** INPUT:

*1. Qualtrics Output file for the IR survey  (Downloaded from Qualtrics on August 11, 2016):
/*Results file directly exported from Qualtrics in a csv format */

local IR_SURVEY = "Investor_Relations_Survey_Impact_of_Swiss_Franc_Shock.csv"

*** OUTPUT:


local MATCH_IR_DESCRIPTIVES = "MatchIRDescriptives.dta" // Files used to produce Table E1 (IA) eventually
local IR_Q_DATA = "IRSurveyData.dta" // File used to produce Table 8 eventually

* However, most results for this survey are still directly produced via the code in this do-file

***********************************************
************* Import Dataset ******************
***********************************************
cd "1_Sources\Surveys"

import delimited "`IR_SURVEY'", delimiter(comma) varnames(1) encoding("utf-8")

cd "${STANDARD_FOLDER}\3_Datasets"

*******************************************
********* PREPARATION OF DATASET **********
*******************************************

set seed 5

************* Merge Analysts with covered firms ************

foreach var of varlist n103_1_text { // This variable contains the ticker symbol that firms provided to identify their firm

	// Removed ticker symbols for confidentiality reasons

}

foreach var of varlist n102_1_text {

	replace `var' = "CFO" 						if `var' == "CFO" | `var' == "CFO "
	replace `var' = "Head Communications" 		if `var' == "Head Communications"| `var' == "Head of Corporate Communications" | `var' == "Head external communications" | `var' == "CCO" | `var' == "Chief Communications Officer"
	replace `var' = "Head IR"					if `var' == "Hear IR"| `var' == "Director Investor Relations" | `var' == "VP IR" | `var' == "Head of Corporate Communications & IR" | `var' == "Hear IR" | `var' == "Head of Investor Relations" | `var' == "Group Treasurer and head of IR" | `var' == "Head of IR" | `var' == "Head of Investor Relations" | `var' == "Head of IR & Cor Comms"
	replace `var' = "(Senior) IR"				if `var' == "Investor Relations Manager"| `var' == "IR Manager" | `var' == "IR & Tresury" | `var' == "Sr. Investor Relations Manager" | `var' == "IR" | `var' == "Senior IR Officer" | `var' == "Investor Relations" | `var' == "Investor Relations Officer"
	replace `var' = "Other"						if `var' == "Company Secretary" | `var' == "Senior PR Manager"
	replace `var' = "Treasury/Accounting"		if `var' == "Corporate Treasurer" | `var' == "Group Treasurer" | `var' == "Senior Accountant"
}

************* Rename Questions ************

drop dobrfl_26-v226							// Drop Display Order
drop v2-v4 v6 v7							// Drop beginning info
drop n11 									// no question
drop n101 n111_1_text-n126 					// Contact data

order n103_1_text
rename n103_1_text Company
rename n102_1_text Job

rename v1 	ResponseID
rename v5	EMail
rename v10 	FinishedIndicator
rename v8   StartDate
gen double StartDate2 = clock(StartDate, "YMDhms")
order StartDate2, after(StartDate)
drop StartDate
rename StartDate2 StartDate
format StartDate %tc 
rename v9   EndDate
gen double EndDate2 = clock(EndDate, "YMDhms")
order EndDate2, after(EndDate)
drop EndDate
rename EndDate2 EndDate

rename n21 Part1
rename n22 Q1
rename n23 Q2
rename n24 Q3
rename n31 Part2
rename n32 Q4 

forvalues i = 1/8 {

	rename n33_`i' Q5_`i'

}

rename n34 Q5_Comment

forvalues i = 1/6 {

	rename n35_`i' Q6_`i'

}

rename n36 Q6_Comment

/* have to rename here for later recodes */

rename n91 Part4



forvalues i = 1/4 {
	rename n92_`i' Q12_`i' // Translational etc.
}

	rename n93 Q12_Comment
	
forvalues i = 1/6 {
	rename n94_`i' Q13_`i' // Translational etc.
}	
	rename n95 Q13_Comment
	
	rename n96 Q14
	rename n97 Q15

	
/* end of have to rename here for later recodes */

egen Part3 = concat(n?1)

egen Q7 = concat(n?2)


forvalues i = 1/4 {
	egen Q8_`i' = concat(n?3_`i')
	}


forvalues i = 1/4 {
	egen Q9_`i' = concat(n?4_x`i')
	}

egen Q9_Comment = concat(n?5)

forvalues TYPE = 4/8 { // Error in Qualtrics, 4 and 5 is missing in Question 10 (adjusted here)

	local z = 0
	
	forval i = 6/10 {
		local z = `i' - 2
		rename n`TYPE'6_`i' n`TYPE'6_`z'
	}
}

forvalues i = 1/8 {
	egen Q10_`i' = concat(n?6_`i')
	}

egen Q10_Comment = concat(n?7)

forvalues i = 1/9 {
	egen Q11_`i' = concat(n?8_`i')
	}
	
drop n41-n88_9

gen SepQ8Q9 = "" // Needed for ordering (separating q8 and q9), needed for tests
	
order Company ResponseID FinishedIndicator Part1 Q1 Q2 Q3 Part2 Q4  Q5* Q6* Part3 Q7  Q8* SepQ8Q9 Q9* Q10* Q11* Part4 Q12* Q13* Q14* Q15*
 
rename Q5_Comment Comment_Q5
rename Q6_Comment Comment_Q6
rename Q9_Comment Comment_Q9
rename Q10_Comment Comment_Q10
rename Q12_Comment Comment_Q12
rename Q13_Comment Comment_Q13

foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}
  drop if _n == 1 // now drop label observation

foreach var of varlist FinishedIndicator Q* Part* {

	destring `var', replace
	replace `var' = . if `var' == -99
}

keep if FinishedIndicator == 1
drop if  missing(Q15) == 1		// One respondent

****************** Rename Labels *******************

label variable Q1 "Importance BEFORE the shock"
label variable Q15 "Importance AFTER the shock"
label variable Q2 "Expectation about cap removal"
label define Q2 1 "< 3 months" 2 "3 - 6 months" 3 "6 - 12 months" 4 "12 - 24 months" 5 "> 24 months"
label values Q2 Q2

label var Q3 "How is your business affected?"
label define Q3 1 "Very negatively" 2 "Negatively" 3 "Neutral" 4 "Positively" 5 "Very positively"
label values Q3 Q3

label var Q4 "When communication with stakeholders?"
label define Q4 1 "< 1 day" 2 "< 1 week" 3 "< 1 month" 4 "< 3 months" 5 "> 3 months"
label values Q4 Q4


label var Q5_1 "Media and press"
label var Q5_2 "Institutional investors"
label var Q5_3 "Retail investors"
label var Q5_4 "Financial analysts"
label var Q5_5 "External audit firm"
label var Q5_6 "Banks and other lending"
label var Q5_7 "Suppliers and customers"
label var Q5_8 "Management or other internal departments"

label var Q6_1 "Existing financial reports"
label var Q6_2 "Existing internal reports"
label var Q6_3 "Newly prepared ad-hoc reports"
label var Q6_4 "Consultation with key management"
label var Q6_5 "Consultation with outside experts"
label var Q6_6 "Feedback from analysts, media etc."


label var Q7 "How proactive approach?"

forvalues i = 8/9 {
	label variable Q`i'_1 "Ad-hoc announcements"
	label variable Q`i'_2 "Private communication"
	label variable Q`i'_3 "Media and financial press"
	label variable Q`i'_4 "Investor days"
}

label var Q10_1 "Uncertainty about effect"
label var Q10_2 "Uncertainty about FX"
label var Q10_3 "Upcoming event"
label var Q10_4 "Little info needs"
label var Q10_5 "Limited impact on firm"
label var Q10_6 "Fear of disclosure precedent"
label var Q10_7 "Company secrets"
label var Q10_8 "Unwanted scrutiny"

label var Q11_1 "Liquidity"
label var Q11_2 "Playing field"
label var Q11_3 "Prevent underpricing"
label var Q11_4 "Conf. Operating strategy"
label var Q11_5 "Conf. Reporting strategy"
label var Q11_6 "New investors"
label var Q11_7 "Existing investors"
label var Q11_8 "Information risk"
label var Q11_9 "Promote reputation"

label var Q12_1 "E-Mails"
label var Q12_2 "Phone calls"
label var Q12_3 "Website hits"
label var Q12_4 "Downloads"

label var Q13_1 "Translational exposure"
label var Q13_2 "Transactional exposure"
label var Q13_3 "Hedging strategy"
label var Q13_4 "One-time gains/losses"
label var Q13_5 "Sensitivity to indirect effects"
label var Q13_6 "Operating and strategic responses"

label var Q14 "Relevance existing reports"
label var Job "Job Title"

foreach var of varlist Q12* {
	replace `var' = . if `var' == 6
}

********** Drop one company with two answers *************

gen Random = rnormal()				// One firm responded twice via IR-CLub. Remove one answer
sort Company Random

by Company: drop if _n == 2 & missing(Company) == 0
drop Random

*************************************
************** ANALYSIS *************
*************************************

run "${STANDARD_FOLDER}\2_Code\90_Additional_Survey_Code.do"

// Question 1 and 15
tab Q1, plot
tab Q1
tab Q15, plot
tab Q15

sum Q1 Q15
ttest Q1 == Q15
ttest Q1 == 4
ttest Q15 == 4

// Question 2
tab Q2, plot
tab Q2
sum Q2

// Question 3
tab Q3, plot
tab Q3
sum Q3
ttest Q3 == 3

// Question 4
tab Q4, plot
tab Q4
sum Q4

// Question 5 (Table 6: Panel A)
quietly: orderquestion Q5, after(Q4) // Program written (see 90_Additional_Code)

runtestquestion Q5, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 6 (Table 6: Panel B)
quietly: orderquestion Q6, after(Comment_Q5) // Program written (see 90_Additional_Code)

runtestquestion Q6, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 7
tab Q7, plot
tab Q7
sum Q7
ttest Q7==4

// Question 8 (Table 7: Panel A)
quietly: orderquestion Q8, after(Q7) // Program written (see 90_Additional_Code)

runtestquestion Q8, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 9 (Table 7: Panel B)
quietly: orderquestion Q9, after(SepQ8Q9) // Program written (see 90_Additional_Code)

runtestquestion Q9, signiveau(0.10) against(2) high(3) low(1) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test



// Question 10

quietly: orderquestion Q10, after(Comment_Q9) // Program written (see 90_Additional_Code)

runtestquestion Q10, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 11

quietly: orderquestion Q11, after(Comment_Q10) // Program written (see 90_Additional_Code)

runtestquestion Q11, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test


// Question 12
quietly: orderquestion Q12, after(Part4) // Program written (see 90_Additional_Code)

runtestquestion Q12, signiveau(0.10) against(3) high(5) low(1) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

	
// Question 13
quietly: orderquestion Q13, after(Comment_Q12) // Program written (see 90_Additional_Code)

runtestquestion Q13, signiveau(0.10) against(4) high(6) low(2) unpaired(0) // Program written (see 90_Additional_Code); signiveau = Sig-level for Holm test, against = mean value, high = when answer is high, low = when question is low, unpaired=0 is default, unpaired=1 is unpaired t-test

	
// Question 14
tab Q14, plot
tab Q14
sum Q14
ttest Q14==4

tab Job


*****************************************
**Export Dataset for Archival Analysis **
*****************************************


cd "${STANDARD_FOLDER}\3_Datasets"

preserve
	drop if missing(Company)
	duplicates drop Company, force
	keep Company
	count
	save `MATCH_IR_DESCRIPTIVES', replace		// Used for Table E1	
restore

rename Q8_1_Q8_2 Q8_PrivateInfo
rename Q4 Q4_Timeliness
keep Company Q8_PrivateInfo Q4_Timeliness // Keep Relevant Questions for Analyses

drop if missing(Company)

cd "${STANDARD_FOLDER}\3_Datasets"
compress _all
save `IR_Q_DATA', replace

exit

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}

***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************
 
*** INPUT:

local SOURCEFILE1 	= "BloombergMerge.dta" 			// created in 01_Import_Bloomberg.do

local SOURCEFILE2 	= "ReportData.dta" 				// created in 02_Import_HandCollected.do

local SOURCEFILE3 	= "Datastream_IBES_Final.dta" 	// created in 03_Import_DS_IBES.do

local SOURCEFILE4 	= "PXLastIntraday.dta"			// created in 01_Import_Bloomberg.do 

local SOURCEFILE5 	= "BloombergMVShares.dta" 		// created in 01_Import_Bloomberg.do
	
local SOURCEFILE6 	= "SwissCrossListing.dta"		// created in 04_Import_Various.do

local SOURCEFILE7 	= "RiskHedgingData.dta"			// created in 04_Import_Various.do 

local SOURCEFILE8 	= "IR_DataArchival.dta"			// created in 04_Import_Various.do 

local SOURCEFILE9 	= "IntradayRollingWindow.dta" 	// created in 01_Import_Bloomberg.do

local SOURCEFILE10 	= "NewInformationData.dta"		// created in 04_Import_Various.do 

local SOURCEFILE11 	= "IRSurveyData.dta"			// created in 06_Import_IR_Survey.do

local SOURCEFILE12 	= "ActualSample151.dta"			// Identifier-List. To verify whether the sample is unchanged and OK (generated based on the final sample)

*** OUTPUT:

local SAVEFILE1 = "Final30MinSample.dta"		

************************************************
*********** Merge with other datasets  *********
************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

use `SOURCEFILE1', replace

merge m:1 Company using  `SOURCEFILE2', assert(match master)
drop _merge		


merge m:1 Company using `SOURCEFILE3', assert(match using) keepusing(Type DatastreamName NoshFF DisclosureRank InternationalStandards ///
										ISOCurrStock PriceCurrency NumberOfAnalysts SICCode SIC1 HistCorr* ///
										USGAAP PriceCurrency IFRS ISIN)
	drop if _merge == 2
	drop _merge
	qui count if (ISOCurrStock != "CHF" | PriceCurrency != "SF")
	assert `r(N)' == 0 												// Verify that all stocks are in CHF
	drop ISOCurrStock PriceCurrency
	

merge m:1 ID Date using `SOURCEFILE4', assert(match using)
	drop if _merge == 2
	drop _merge		

merge m:1 Company Date using `SOURCEFILE5' 							
	drop id 							
	drop if _merge == 2				
	rename _merge _merge1											// verify that the _merge == 1 from this step are later deleted (see below)

merge m:1 Type using `SOURCEFILE6', assert(match master) keepusing(CrossListingType)
	drop if _merge == 2 					// Irrelevant, see assert.
	drop _merge

merge m:1 Type using `SOURCEFILE7', assert(match master) 
	drop if _merge == 2 					// Irrelevant, see assert.
	drop _merge

merge m:1 Company using `SOURCEFILE8', assert(match master using) keepusing(IR_Club Lead_IR)
	drop if _merge == 2 					
	drop _merge

merge 1:1 ID DateTime using `SOURCEFILE9', assert(match) keepusing(*Rolling) 
	keep if _merge == 3
	drop _merge

merge m:1 Company Date using `SOURCEFILE10', assert(match master)	
	drop if _merge == 2
	drop _merge

merge m:1 Company using `SOURCEFILE11', assert(match master)	
	drop if _merge == 2
	drop _merge

******************************************************
*********** Last Step Before "Final Sample"  *********
******************************************************
distinct ID

*Table 1 Line 4: Removed 8 firms because of missing main control variables

foreach var of varlist DisclosureRank IntSales NoshFF NumberOfAnalysts {
	drop if missing(`var') 
}

preserve
	bys ID: keep if _n == 1
	count
	assert r(N) == 151
	cd "${STANDARD_FOLDER}\1_Sources\Verification\"
	merge 1:1 Company using `SOURCEFILE12', assert(match)
restore

sum _merge1
assert `r(max)' == 3 & `r(min)' == 3
drop _merge1 

sort ID DateTime

cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE1', replace

clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\"
	
	
capture cd ${STANDARD_FOLDER}


***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

*** INPUT:

local SOURCEFILE1 = "Final30MinSample.dta"

*** OUTPUT:

local SAVEFILE1 = "IntradayDataFinal.dta" // File for Intraday Analyses
local SAVEFILE2 = "DailyDataFinal.dta"	// File for Daily Analyses


***************************************************************
***************************************************************
************** I. Generate Intraday Dataset *******************
***************************************************************
***************************************************************

****************************************************************
************************ Import Intraday file ******************
****************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
										
use `SOURCEFILE1', replace											// starts with balanced panel
sort ID DateTime 

****************************************************************
***************** Make consistency checks***********************
****************************************************************

qui xtset ID DateTime
xtdescribe

assert `r(N)' == 151 													// assert that sample is correct, should be 151 observations
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum Date, detail
local MINDATE = `r(min)'

qui sum ID, detail
local MINID =`r(min)'

count if Date == `MINDATE' & ID == `MINID'

scalar INTRADAYOBS = `r(N)'												// Set number of Intraday observations for changes

assert scalar(INTRADAYOBS) == 17										// Set number of Intraday observations for changes

sum ID if HourMin <= 1030 & Date == `MINDATE' & ID == `MINID', detail
assert `r(N)' == 3
global UNTIL1030 = `r(N)'
assert ${UNTIL1030} == 3

****************************************************************
********************* SET SOME GLOBALS *************************
****************************************************************

global BENCHMARK_PERIOD "CenterDate <= -1 & CenterDate >= -30"

****************************************************************
***************** Generate important variables *****************
****************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"

*Generate Logarithmic Returns
sort ID DateTime 
by ID: 	gen LogReturn = log(LastPriceTrade/LastPriceTrade[_n-1])		 // Overnight returns are fine
	replace LogReturn 	= 0 if missing(LogReturn)						//  Only for Oct 1 (not necessary as outside of sample)

*Generate CenterDate
sort ID DateTime 
egen 	CenterDate = group(Date)
	egen 	MAXDATE = group(Date) if Date <=td(15-jan-2015)
	qui sum MAXDATE, detail
	replace CenterDate = CenterDate-`r(max)'							// CenterDate is 0 for 15 Jan, 2015
	drop 	MAXDATE

* Generate Intraday Volatility
sort ID Date DateTime
by 	ID Date: egen SDReturn = sd(LogReturn)
	replace SDReturn =SDReturn*100										// * 100 for readability


* Generate BidAskSpread and MarketValue Variables
sort ID Date DateTime
gen LogSpread30 			= log(MeanTimeBidAskSpread) 										// BidAskSpread or LogSpread is only daily data; intraday TimeBidAskSpread, which is grouped by 30mins
gen LogMV 					= log(MVBloomAllNo)
by ID Date: replace LogMV 	= log(MVBloomAllNo*LastPriceTrade/LastPriceTrade[scalar(INTRADAYOBS)]) 	// Because MVBloomAllNo is End of Day; now adjust by intraday movements for intradey data

* Generate Turnover Variables
sort ID DateTime
by ID: gen Turnover = (ValueTrade)/(MVBloomAllNo[_n-scalar(INTRADAYOBS)]*1000000)*100 	// Lagged by one Day; * 100 for readability in %
gen LogTurnover 	= log(Turnover)

*** Generate Variables for Daily Analyses (e.g. Intraday Version of Liquidity Amihud)
gen AmihudIntraday = abs(LogReturn)/ValueTrade
gen RiskMGMTPerPage = NumberofRiskManagement/ReportLength
gen HedgingPerPage = Hedging/ReportLength

* Generate Logged Version of Rolling Return Volatility
sort ID Date DateTime
gen LogSDRolling = log(SDRolling)

* Generate Lagged Variables (not L., because of gaps)
sort ID DateTime
foreach var of varlist LogMV LogTurnover LogSDRolling SDReturn  {					// SDReturn (unlogged) needed for daily data set in collapse (only positive values)
	by ID: gen Lag`var' = `var'[_n-scalar(INTRADAYOBS)]
}

* Standardize Risk Disclosure to mean 0 and SD of 1 for analyses
sum RiskDisclosure, detail
egen StandardRiskDisc = std(RiskDisclosure)

* Generate Main Variables for Intraday Analyses.
sort ID DateTime

assert scalar(INTRADAYOBS) == 17											// Assert whether number of intraday obs is still correct
assert ${UNTIL1030} == 3													// Assert whether number of obs up until 10.30 is still correct.
assert ValueTrade[1193] == 15408579.085 									// Just an assert whether Value Trade as of 10.30 Jan 15 ABB; necessary for START variable

local ANNOUNCEMENT_DAY 	= 0
local WINDOW_START		= -30 	+ `ANNOUNCEMENT_DAY'
local WINDOW_END 		= 0 	+ `ANNOUNCEMENT_DAY'

sort ID DateTime
by ID: gen NUMBER 		= _n
gen START				= NUMBER - 1193-`ANNOUNCEMENT_DAY'*17+${UNTIL1030}
drop NUMBER

local y = 0
	
foreach x of numlist 1/`=scalar(INTRADAYOBS)'{
	
	local t = 8+int((`x'+1)/2)				// To determine Hour for Dummy
	local e = `t'+1							// To determine if Hour moves past
	
	gen _`x'AfterIncrease 		= 0
	replace _`x'AfterIncrease 	= 1 if START <= `x' & START > `y'
	
	gen _`x'AScore 	= _`x'AfterIncrease*StandardRiskDisc
	
	gen only_`x'AScore = _`x'AfterIncrease*StandardRiskDisc

	if int((`x'+1)/2) == (`x'+1)/2 {
		label var 	_`x'AfterIncrease 	"`t'.00-`t'.30 Dummy"
		label var 	_`x'AScore 			"`t'.00-`t'.30 x RiskDisclosure"
	}
	
	else {
		label var 	_`x'AfterIncrease 	"`t'.30-`e'.00 Dummy"
		label var 	_`x'AScore 			"`t'.30-`e'.00 x RiskDisclosure"
	}
	
	local y = `x'							// Counter
	
}


** Label Variables for Main Intraday Analyses
label var LogSpread30 			"Log(Spread)"
label var LagLogMV 				"Log(MarketValue)(t-17)"
label var LagLogTurnover 		"LogTurnover(t-17)"
label var LagLogSDRolling 		"Log(ReturnVolatility)(t-17)"


cd "${STANDARD_FOLDER}\3_Datasets"

sort ID DateTime

save `SAVEFILE1', replace

***************************************************************
***************************************************************
*************** II. Generate Daily Dataset ********************
***************************************************************
***************************************************************

****************************************************************
************* Collapse Dataset to Daily Dataset ****************
****************************************************************


cd "${STANDARD_FOLDER}\3_Datasets"
use `SAVEFILE1', replace

global FIRST Company Type DatastreamName SICCode ISIN CrossListingType // String Variables
global MEAN  AmihudIntraday MeanRelativeStale HistCorrEUR HistCorrUSD // Variables that vary within a day (e.g., AmihudIntraday) or a not varying within a day, but can take negative values (e.g., HistCorr)
global MAX  MeanDateBidAskSpread RiskDisclosure IntSales DisclosureRank NumberOfAnalysts NoshFF ///
			AfterSNB InternationalStandards SDReturn LagSDReturn PXLast BeforePXLast USGAAP IFRS ReportLength MVBloomAllNo Date SIC1 ///
			EPS_Revision News_SNB TotalNewInfo MeanDateEffSpread_No_W MeanDateEffSpread_W_M  ///
			Revenues2013 Assets2013 CostsProfits2013 Monetary2013 FXExposure2013 Hedging2013 FXSensitivity2013 ///
			LogRiskLinkedin LogHedgeKeyLinkedin Log_IR_Linkedin RiskMGMTPerPage HedgingPerPage RiskCommittee ChiefRisk EconHedgeYesNo IR_Club Lead_IR ///
			Q4_Timeliness Q8_PrivateInfo // These variables are not varying within a day and are >=0 (hence max in collapse step within a day always give the same value)
global SUM  ValueTrade

foreach ASS of global MAX {
	assert `ASS' >= 0 	& missing(`var') == 0					// Verify that only positive values, such that max in collapse-command is appropriate.
	}

collapse (mean) ${MEAN} (max) ${MAX} (sum) ${SUM} (first) ${FIRST}, by(ID CenterDate) 	// max because timeinvar and day 0
order ID Date DatastreamName Company

****************************************************************
***************** Generate Key Variables ***********************
****************************************************************

* Panel Checks whether data is correct
qui xtset ID Date
xtdescribe

assert `r(N)' == 151 													// Sample is correct, should be 151 observations
assert `r(min)' == `r(max)' 											// Same number of observations

qui sum ID, detail
count if ID == `r(min)'

scalar TOTAL_DAYS = `r(N)'
assert TOTAL_DAYS == 144

qui sum Date, detail
count if Date == `r(min)'

scalar TOTAL_FIRMS = `r(N)'
assert TOTAL_FIRMS == 151


forval i = 1/`=scalar(TOTAL_FIRMS)'  {
	assert CenterDate[(70+(`i'-1)*TOTAL_DAYS)] == -1
}

* Standardize Risk Disclosure to mean 0 and SD of 1 for analyses
sum RiskDisclosure, detail
egen StandardRiskDisc = std(RiskDisclosure)

* Generate Median Split Risk Disc Variable (mostly for figures)
sum RiskDisclosure, detail
assert  `r(p50)' == 4
gen AboveRiskDisclosure = RiskDisclosure > `r(p50)' & !missing(RiskDisclosure)

* Log Variables (Log-transformation before collapse did not capture them)
gen LogSpread 			= log(MeanDateBidAskSpread)
gen LogSDReturn 		= log(SDReturn)
gen LogReportLength 	= log(ReportLength)
gen LogEffSpread 		= log(MeanDateEffSpread_No_W)
gen LogEffSpread_wgt	= log(MeanDateEffSpread_W_M)
gen LogAmihud 			= log(AmihudIntraday)

* Generate Main Controls (Log-transformation before collapse did not capture them)
sort ID CenterDate
by ID: gen Turnover 	= (ValueTrade/(MVBloomAllNo[_n-1]*1000000))*100				// in pp to enhance readability
by ID: gen LogTurnover 	= log(Turnover)
gen LogMV 				= log(MVBloomAllNo)

* Generate Additional Controls
sort ID CenterDate
foreach VAR of varlist LogTurnover LogMV LogSDReturn {
	by ID: gen Lag`VAR' = `VAR'[_n-1]
}

* Generate Lagged (but not logged) variables for descriptives table
sort ID Date 
by ID: gen LagMV = MVBloomAllNo[_n-1] 
by ID: gen LagTurnover = Turnover[_n-1] 

* Generate Industry Fixed Effects
foreach VAR of varlist SIC1  {
	egen IndustryDate`VAR' = group(`VAR' Date)
}

* Generate additional Control variables
gen HistCorrEur_R = HistCorrEUR
replace HistCorrEur_R = HistCorrUSD if missing(HistCorrEur_R) // Just 4 firms
drop HistCorrEUR HistCorrUSD

* Additional Variables (IA)
gen CrossList = !missing(CrossListingType)
gen MajorCrossList = !missing(CrossListingType) & CrossListingType != "U"
gen ExchCrossList = CrossListingType == "Real"

* Generate New Info Variables
foreach VAR of varlist EPS_Revision News_SNB TotalNewInfo {
	gen Log`VAR' = log(1 + `VAR')
}

* Generate Survey-Based Variable for Archival Analysis  
gen FirstWeek = Q4_Timeliness <= 2 if !missing(Q4_Timeliness) 			// Within The First Week
gen ImportantPrivate = Q8_PrivateInfo >= 6 if !missing(Q8_PrivateInfo) 	// Important Private Communication (6 or 7 on Likert Scale)

* Generate Return Variables
sort ID CenterDate
gen LogPXLast = log(PXLast)
by ID: gen LogReturn		= log(PXLast/PXLast[_n-1])*100															// * 100 for readability
by ID: replace LogReturn	= log(PXLast/BeforePXLast)*100 if Date == td(01oct2014) & missing(LogReturn)			// * 100 for readability


* Generate time-invariant controls based on average of benchmark period (except for LogMV, just for robustness tests)
foreach VAR of varlist LogMV LogTurnover LogSDReturn LogSpread MVBloomAllNo Turnover SDReturn MeanDateBidAskSpread LogReturn {
	by ID: egen MeanPre`VAR' = mean(`VAR') if ${BENCHMARK_PERIOD}
	by ID: replace MeanPre`VAR' = MeanPre`VAR'[_n-1] if missing(MeanPre`VAR')
	rename MeanPre`VAR' `VAR'_030
}

sort ID Date

* Generate Variables for Synthetic Control Analysis in Internet Appendix
foreach VAR of varlist LogSpread LogReturn {

	by ID: egen Mean`VAR' = mean(`VAR') if CenterDate < 0 					// Related to i)
	by ID: replace Mean`VAR' = Mean`VAR'[_n-1] if missing(Mean`VAR')

	by ID: egen Max`VAR' = max(`VAR') if CenterDate < 0						// Related to ii)
	by ID: replace Max`VAR' = Max`VAR'[_n-1] if missing(Max`VAR')

	by ID: egen Min`VAR' = min(`VAR') if CenterDate < 0 					// Related to iii)
	by ID: replace Min`VAR' = Min`VAR'[_n-1] if missing(Min`VAR')

	by ID: egen SD`VAR' = sd(`VAR') if CenterDate < 0 						// Related to iv)
	by ID: replace SD`VAR' = SD`VAR'[_n-1] if missing(SD`VAR')

	by ID: egen Skew`VAR' = skew(`VAR') if CenterDate < 0 					// Related to v)
	by ID: replace Skew`VAR' = Skew`VAR'[_n-1] if missing(Skew`VAR')

}

* Generate PostSNB Interactions
foreach var of varlist 	StandardRiskDisc AboveRiskDisclosure ///
						LagLogMV LagLogTurnover LagLogSDReturn ///
						IntSales DisclosureRank NumberOfAnalysts NoshFF HistCorrEur_R ///
						LogReturn LogMV_030* LogTurnover_030* LogSDReturn_030* LogSpread_030* LogReturn_030 ///
						LogRiskLinkedin LogHedgeKeyLinkedin Log_IR_Linkedin RiskMGMTPerPage HedgingPerPage RiskCommittee ChiefRisk EconHedgeYesNo IR_Club Lead_IR ///
						InternationalStandards IFRS USGAAP LogReportLength ///
						CrossList MajorCrossList ExchCrossList FirstWeek ImportantPrivate ///
						LogEPS_Revision LogNews_SNB LogTotalNewInfo {
	gen A`var' = `var'*AfterSNB
}

* Generate Triple Interactions
foreach VAR of varlist LogEPS_Revision LogNews_SNB LogTotalNewInfo {
	gen Triple_RiskDisc_`VAR' = AStandardRiskDisc * `VAR'
}

* Generate Longer-Term Post Indicators
gen Post1 = CenterDate <= 2 & CenterDate >= 0
gen Post2 = CenterDate <= 10 & CenterDate >= 3
gen Post3 = CenterDate <= 20 & CenterDate >= 11

foreach VAR of varlist Post* {
	gen `VAR'_RiskDisc = `VAR' * StandardRiskDisc
}

* Make tables more readable and label variables
rename SDReturn ReturnVol
cd "${STANDARD_FOLDER}\2_Code"

run "91_Label Variables.do"

* Save Dataset
cd "${STANDARD_FOLDER}\3_Datasets"

save `SAVEFILE2', replace


clear all
version 13.1
${LOG_FILE_OPTION}

***********************************************
*********** Set Working Directories ***********
***********************************************

global STANDARD_FOLDER "D:\Swiss-Franc\" 

	
capture cd ${STANDARD_FOLDER}

***********************************************
*** Define Dependencies (Sources and Output) **
***********************************************

* INPUT:
global DAILY_DATA = "DailyDataFinal.dta"

global INTRADAY_DATA = "IntradayDataFinal.dta"

* OUTPUT:
global SPREAD_MODEL			"Table2.doc"
global INTRA_MODEL			"Table3_PanelA.doc"
global PERSIST_MODEL		"Table3_PanelB.doc"
global INTERACT_MODEL		"Table3_PanelC.doc"
global PRIVATE_INFO_MODEL	"Table8.doc"

***********************************************
** Define Some Global Variables for All Var. **
***********************************************

global DEPVAR_SPREAD 			"LogSpread"
global DEPVAR_RETVOL			"ReturnVol"

global TIME						"CenterDate <= 2 & CenterDate >= -30"

global CLUSTER					"ID Date"
global FIXED_NO_DATE			"ID"
global FIXED_DATE				"ID Date"
global FIXED_INDUSTRY_DATE		"ID IndustryDateSIC1"

global POST 					"AfterSNB"
global MAIN_TEST				"AStandardRiskDisc"
global MAIN_CONTROLS			"LagLogMV LagLogTurnover LagLogSDReturn"
global ADD_CONTROLS				"ALogMV_030"
global OTHER_CONTROLS			"AIntSales AHistCorrEur_R ADisclosureRank ANumberOfAnalysts ANoshFF"
global RET_CONTROLS				"LogReturn ALogReturn"

global OUTREG_TITLE		"Regressions with [-30; +2] window using daily data"
global R_PANEL 			"e(r2_a_within)"
global OUTREG_STATS		"nor2 noobs nonote tstat bdec(3) tdec(2) addnote(t-statistics based on robust standard errors clustered by firm and date, *** p<0.01; ** p<0.05; * p<0.1) label"

*************************************************************
*************************************************************
*************** I. Daily Analysis Regressions ***************
*************************************************************
*************************************************************


*************************************************************
************************ Table 2 ****************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

cd "${STANDARD_FOLDER}\4_Output\Tables"

*** Generate Sample of 4,949 (151 firms)

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST}  ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	keep if (e(sample)) 
	count
	assert `r(N)' == 4949

*** Descriptive Statistics Table 1: Panel B

fsum MeanDateBidAskSpread ReturnVol AfterSNB RiskDisclosure LagMV LagTurnover LagSDReturn IntSales HistCorrEur_R DisclosureRank NumberOfAnalysts NoshFF LogReturn, stats(n mean sd p1 p25 p50 p75 p99) f(%9.3f)

***** Table 2

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST} ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Date")  ${OUTREG_STATS}
	
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}
		
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_RETVOL} ${MAIN_TEST} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${SPREAD_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) sortvar(${POST}) addtext(Fixed Effects, "Firm & Date") 	${OUTREG_STATS}


*************************************************************
*************************************************************
************* II. Remaining Archival Analyses ***************
*************************************************************
*************************************************************

*************************************************************
****************** Table 3: Panel A *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${INTRADAY_DATA}, replace

cd "${STANDARD_FOLDER}\4_Output\Tables"

global DEPVAR_SPREAD30 			"LogSpread30"

global TIME30_LONG				"CenterDate<=0 & CenterDate>=-30"
global TIME30_SHORT				"CenterDate<=0 & CenterDate>=0"

global MAIN_CONTROLS30			"LagLogMV LagLogTurnover LagLogSDRolling"

global CLUSTER30				"ID DateTime"
global OUTREG30					"nor2 noobs nonote addnote(t-statistics based on robust standard errors clustered by firm and time, *** p<0.01; ** p<0.05; * p<0.1) label"
	
global OUTREG_TITLE30		"Within announcement day: Log(Spread) as the dependent variable"


reghdfe ${DEPVAR_SPREAD30} _*  ${MAIN_CONTROLS30}		if ${TIME30_LONG}, absorb(ID HourMin) vce(cluster ${CLUSTER30}) noconstant
	outreg2 using ${INTRA_MODEL}, replace ctitle([-30; 0]) title("${OUTREG_TITLE30}") nose bdec(3)  ${OUTREG30}
	outreg2 using ${INTRA_MODEL}, append ctitle([-30; 0]) title("${OUTREG_TITLE30}") drop(LogSpread30) stats(tstat)  tdec(2) adds(Adj. Within R2, ${R_PANEL}, No. Firms, e(N_clust1), No. Obs, e(N)) addtext(Fixed Effects, "Firm & Time-of-Day") ${OUTREG30}
	assert `e(N)' == 64012

reghdfe ${DEPVAR_SPREAD30} _*AScore ${MAIN_CONTROLS30} 	if ${TIME30_SHORT}, absorb(HourMin) vce(cluster ${CLUSTER30}) noconstant
	outreg2 using ${INTRA_MODEL}, append ctitle([0; 0]) title("${OUTREG_TITLE30}") nose bdec(3) ${OUTREG30}
	outreg2 using ${INTRA_MODEL}, append ctitle([0; 0]) title("${OUTREG_TITLE30}") drop(LogSpread30) stats(tstat) tdec(2) adds(Adj. Within R2, ${R_PANEL}, No. Firms, e(N_clust1), No. Obs, e(N)) addtext(Fixed Effects, "Time-of-Day") ${OUTREG30}
	count if e(sample)
	assert `e(N)' == 2112


*************************************************************
****************** Table 3: Panel B *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

global TIME_LONG				"CenterDate <= 20 & CenterDate >= -30"

global MAIN_TEST_LONG			"Post1_RiskDisc Post2_RiskDisc Post3_RiskDisc"
global POST_LONG				"Post1 Post2 Post3"

cd "${STANDARD_FOLDER}\4_Output\Tables"

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST_LONG}  ${MAIN_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	keep if (e(sample)) 
	count
	assert `e(N)' == 7653

*****

reghdfe ${DEPVAR_SPREAD} ${POST_LONG} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PERSIST_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Date") ${OUTREG_STATS}
	
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}
		
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_RETVOL} ${MAIN_TEST_LONG} ${MAIN_CONTROLS} ${ADD_CONTROLS} if ${TIME_LONG}, absorb(${FIXED_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PERSIST_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) sortvar(${POST_LONG}) addtext(Fixed Effects, "Firm & Date") ${OUTREG_STATS}


*************************************************************
****************** Table 3: Panel C *************************
*************************************************************
cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

global MAIN_TEST1				"AStandardRiskDisc ALogEPS_Revision Triple_RiskDisc_LogEPS_Revision"
global MAIN_TEST2				"AStandardRiskDisc ALogNews_SNB Triple_RiskDisc_LogNews_SNB"
global MAIN_TEST3				"AStandardRiskDisc ALogTotalNewInfo Triple_RiskDisc_LogTotalNewInfo"


cd "${STANDARD_FOLDER}\4_Output\Tables"

reghdfe ${DEPVAR_SPREAD} ${POST} ${MAIN_TEST1}  ${MAIN_CONTROLS} if ${TIME}, absorb(${FIXED_NO_DATE}) vce(cluster ${CLUSTER})
	keep if (e(sample)) 
	count
	assert `e(N)' == 4949

*****

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${INTERACT_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER})  noconstant
		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
 		outreg2 using ${INTERACT_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") ${OUTREG_STATS} sortvar(${MAIN_TEST1}   ${MAIN_TEST2}  ${MAIN_TEST3})

*************************************************************
************************* Table 4-7 *************************
*************************************************************

* Corresponding Results are produced in 05_Import_Sell_Side_Analyst_Survey (Table 4 and 5)
* and 06_Import_IR_Survey (Table 6 and 7)

*************************************************************
*************************** Table 8 *************************
*************************************************************

cd "${STANDARD_FOLDER}\3_Datasets"
use ${DAILY_DATA}, replace

drop if missing(Q4) & missing(Q8) // Restrict Sample to Survey Respondents

global TIME						"CenterDate <= 2 & CenterDate >= -30"

global MAIN_TEST1				"AStandardRiskDisc"
global MAIN_TEST2				"AStandardRiskDisc AFirstWeek"
global MAIN_TEST3				"AStandardRiskDisc AImportantPrivate"

 cd "${STANDARD_FOLDER}\4_Output\Tables"

*** Column 1-3
reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, replace title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}
	count if e(sample)
	assert `e(N)' == 1185

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

* Column 4-6: Drop Outliers in this analysis
drop if ID == 26 

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST1} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}
	count if e(sample)
	assert `e(N)' == 1119

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST2} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
		outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS}

reghdfe ${DEPVAR_SPREAD} ${MAIN_TEST3} ${MAIN_CONTROLS} ${ADD_CONTROLS} ${OTHER_CONTROLS} ${RET_CONTROLS} if ${TIME}, absorb(${FIXED_INDUSTRY_DATE}) vce(cluster ${CLUSTER}) noconstant
	outreg2 using ${PRIVATE_INFO_MODEL}, append title("${OUTREG_TITLE}") addstat(Adj. Within R2, ${R_PANEL}, No. Firms, `e(N_clust1)', No. Obs, e(N)) addtext(Fixed Effects, "Firm & Industry-Date") 	${OUTREG_STATS} sortvar(${MAIN_TEST1} ${MAIN_TEST2} ${MAIN_TEST3})


local TXTFILES: dir . files "*.txt"
foreach TXT in `TXTFILES' {
    erase `"`TXT'"'
}



exit

// Two created programs for analysis of surveys (orderquestion + runtestquestion)
// Need to be run before 05_Import_Sell_Side_Analyst_Survey or 06_Import_IR_Survey 
// Or created as two separate ado-files and added do the personal ado folder

capture program drop orderquestion
program define orderquestion
	syntax namelist(max=1) [, after(string)]
	
// From here statslist  http://www.statalist.org/forums/forum/general-stata-discussion/general/1357869-order-variables-based-on-their-mean

ds `namelist'*
local vlist `r(varlist)'

preserve

collapse (mean) `vlist'
local i = 1
foreach v of local vlist {
    gen name`i' = "`v'"
    rename `v' mean`i'
    local ++i
}
gen _i = 1
reshape long mean name, i(_i) j(_j)
sort mean
replace _j = _n
replace name = name + " " + name[_n-1] if _n > 1
local ordered_vlist = name[_N]
restore
order `ordered_vlist', after(`after')

// Until here statslist  http://www.statalist.org/forums/forum/general-stata-discussion/general/1357869-order-variables-based-on-their-mean

ds `namelist'*  // Do it again, because of new ordering
local vlist `r(varlist)'

local i = 0
foreach var of varlist `vlist' {
	local i = `i' + 1
	rename `var' `namelist'_`i'_`var' // i displays the ranking of the means, while the old identifier is retained at the end of the variable name 
}


end

capture program drop runtestquestion
program define runtestquestion
	syntax namelist(max=1) [, signiveau(numlist max = 1) against(numlist max=1) high(numlist max=1) low(numlist max =1) unpaired(numlist max =1)]
	
	local MAX = 0
	local TEST_OPTION = ""
	if `unpaired' == 1 {
		
		local TEST_OPTION = ", unpaired"
	
	}
foreach QUESTION in `namelist' {
	// Determine the number of items
	qui ds `QUESTION'_*
	qui local nword : word count `r(varlist)'
	
	// Determine Mean and Baseline Tests (no comparison between answer items)
	
	matrix define `QUESTION' = J(`nword',5,.) // Column 3 is missing because it is filled in later with the Holm-Adjustment mechanism
	
	local POS = 0
	foreach var of varlist `QUESTION'_* {
		local POS = `POS' +1
		
		qui count if missing(`var') == 0
		local TOTAL = `r(N)'
		
		qui count if missing(`var') == 0 & `var' >= `high'
		
		local highPER = `r(N)'/`TOTAL'*100

		
		qui count if missing(`var') == 0 & `var' <= `low'

		local lowPER = `r(N)'/`TOTAL'*100

		
		qui ttest `var' == `against'
		matrix `QUESTION'[`POS',1] = round(`r(mu_1)',0.01)
		matrix `QUESTION'[`POS',2] = round(`r(p)',0.001)
		matrix `QUESTION'[`POS',4] = round(`highPER',0.01)
		matrix `QUESTION'[`POS',5] = round(`lowPER',0.01)

	}
		matrix colnames `QUESTION' = Mean P-Value Holm High% Low%
		matrix list `QUESTION'
		
		
		forval i = 1/5 {
			display ""
		}
	// Here comparisons across answer items
	
		forval T_TEST_Q = 1/`nword' {
			
			qui sum  `QUESTION'_`T_TEST_Q'
			local MAX = max(`MAX',`r(N)')
			
			matrix define `QUESTION'_`T_TEST_Q' = J(`nword'-1,6,.)

			local POS = 0
			foreach i of numlist 1/`nword' {
				if `i' == `T_TEST_Q' {
			}
			else {
				local POS = `POS' +1
				qui ttest `QUESTION'_`T_TEST_Q' == `QUESTION'_`i' `TEST_OPTION'
				matrix `QUESTION'_`T_TEST_Q'[`POS',1]=`i'
				matrix `QUESTION'_`T_TEST_Q'[`POS',2]=`r(p)'
				matrix `QUESTION'_`T_TEST_Q'[`POS',3]=`r(p)' <= `signiveau'
			}
	}
		mata : st_matrix("`QUESTION'_`T_TEST_Q'", sort(st_matrix("`QUESTION'_`T_TEST_Q'"), 2)) // Command for sorting of p value
	
		local ntests = `nword' -1
	
		forval i = 1/`ntests' {
	
			matrix `QUESTION'_`T_TEST_Q'[`i',4] = `signiveau'/(`ntests'-`i'+1)
			matrix `QUESTION'_`T_TEST_Q'[`i',5] = `QUESTION'_`T_TEST_Q'[`i',2] <= `QUESTION'_`T_TEST_Q'[`i',4]
			matrix `QUESTION'_`T_TEST_Q'[`i',6] = `QUESTION'_`T_TEST_Q'[`i',1] * `QUESTION'_`T_TEST_Q'[`i',5]
			
			matrix colnames `QUESTION'_`T_TEST_Q' = Number SigNiveau Sig? Holm Sig? WhereDiffs
			
	}
	
	local lab: variable label `QUESTION'_`T_TEST_Q'
	di "`lab'"
	
	matrix list `QUESTION'_`T_TEST_Q'
	matrix Only_`QUESTION'_`T_TEST_Q' = `QUESTION'_`T_TEST_Q'[1..`nword'-1,6]
	
	mata : st_matrix("Only_`QUESTION'_`T_TEST_Q'", sort(st_matrix("Only_`QUESTION'_`T_TEST_Q'"), 1)) // Command for sorting of p value
	matrix list Only_`QUESTION'_`T_TEST_Q'

	

	forval i = 1/5 {
		display ""
	}

}
}

display "Max number of obs: `MAX'"

clear matrix
end

version 13.1
${LOG_FILE_OPTION}

* Coming from DailyDataFinal.dta

* Outcome Variables
label var LogSpread 				"Log(Spread)"
label var ReturnVol 				"ReturnVol"

label var AfterSNB					"PostSNB"

* Main Test Variable
label var RiskDisc 			"RiskDisclosure"
label var AStandardRiskDisc	"PostSNB x RiskDisclosure"

* Control Variables
label var LogMV 					"Log(MarketValue)"
label var LagLogMV 					"Log(MarketValue)(T-1)"

label var LogTurnover 				"Log(Turnover)"
label var LagLogTurnover 			"Log(Turnover)(T-1)"

label var LogSDReturn 				"Log(ReturnVolatility)"
label var LagLogSDReturn 			"Log(ReturnVolatility)(T-1)"

label var ALagLogMV					"PostSNB x Log(MarketValue)(T-1)"
label var ALagLogTurnover 			"PostSNB x Log(Turnover)(T-1)"
label var ALagLogSDReturn			"PostSNB x Log(RetVola)(T-1)"

label var LogMV_030					"Log(MV)(0-30)"
label var LogTurnover_030			"Log(Turnover)(0-30)"
label var LogSDReturn_030			"Log(RetVola)(0-30)"

label var ALogMV_030				"PostSNB x Log(MV)(0-30)"

label var IntSales 					"IntSales"
label var AIntSales 				"PostSNB x IntSales"
label var DisclosureRank	 		"Total_Disc"
label var ADisclosureRank			"PostSNB x Total_Disc"
label var NumberOfAnalysts	 		"Num_Analysts"
label var ANumberOfAnalysts 		"PostSNB x Num_Analysts"
label var NoshFF 					"FreeFloat"
label var ANoshFF 					"PostSNB x FreeFloat"
label var LogReportLength			"Log(Report Length)"
label var ALogReportLength			"PostSNB x Log(Report Length)"
label var HistCorrEur_R				"Hist_Corr_EUR"
label var AHistCorrEur_R			"PostSNB x Hist_Corr_EUR"

label var LogReturn 				"LogReturn"
label var ALogReturn				"PostSNB x LogReturn"
label var LogPXLast					"Log(Price)"

label var InternationalStandards	"Int_Standards"
label var AInternationalStandards	"PostSNB x Int_Standards"

* Longer-Term Post-Variables
label var Post1 				"Post(0,2)"
label var Post2 				"Post(3,10)"
label var Post3 				"Post(11,20)"

label var Post1_RiskDisc		"Post(0,2) x RiskDisclosure"
label var Post2_RiskDisc		"Post(3,10) x RiskDisclosure"
label var Post3_RiskDisc		"Post(11,20) x RiskDisclosure"

* Triple Interactions
label var ALogEPS_Revision 					"Post_SNB x Log(1+EPS_Revision)"
label var ALogNews_SNB 						"Post_SNB x Log(1+News)"
label var ALogTotalNewInfo  				"Post_SNB x Log(1+Combined)"
label var Triple_RiskDisc_LogEPS_Revision 	"Post_SNB x FXRisk_Disc x Log(1+EPS_Revision)"
label var Triple_RiskDisc_LogNews_SNB 		"Post_SNB x FXRisk_Disc x Log(1+News)"
label var Triple_RiskDisc_LogTotalNewInfo 	"Post_SNB x FXRisk_Disc x Log(1+Combined)"

* Risk MGMT Variables
label var ChiefRisk 			"ChiefRisk"
label var AChiefRisk 			"PostSNB x ChiefRisk"

label var RiskCommittee 		"RiskCommittee"
label var ARiskCommittee 		"PostSNB x RiskCommittee"

label var RiskMGMTPerPage 		"RiskMGMT/#Page"
label var ARiskMGMTPerPage 		"PostSNB x RiskMGMT/#Page"

label var LogRiskLinkedin 		"Log(#Risk Employees)"
label var ALogRiskLinkedin 		"PostSNB x Log(#Risk Employees)"

* Hedging Variables
label var HedgingPerPage 		"Hedging/#Page"
label var AHedgingPerPage 		"PostSNB x Hedging/#Page"

label var LogHedgeKeyLinkedin 	"Log(#Hedging Employees)"
label var ALogHedgeKeyLinkedin 	"PostSNB x Log(#Hedging Employees)"

label var EconHedgeYes 			"Economic_Hedge"
label var AEconHedgeYes 		"PostSNB x Economic_Hedge"

* IR Variables
label var IR_Club 				"IR_Club"
label var AIR_Club 				"PostSNB x IR_Club"

label var Lead_IR 				"Lead_IR"
label var ALead_IR 				"PostSNB x Lead_IR"

label var Log_IR_Linkedin 		"Log(#IR Employees)"
label var ALog_IR_Linkedin 		"PostSNB x Log(#IR Employees)"

* Other IR Varibales
label var AFirstWeek 			"Post_SNB x First_Week"
label var AImportantPrivate		"Post_SNB x Private_Comm"

