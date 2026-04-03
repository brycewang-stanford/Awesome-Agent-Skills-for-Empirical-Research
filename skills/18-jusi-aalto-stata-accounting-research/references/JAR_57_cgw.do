***************************************************************************************************************************************************************
**********                                                                    																    	 **********
**********        ARTICLE: Do Strict Regulators Increase the Transparency of the Banking System?							                     	 **********
**********        AUTHOR:  Anna M. Costello, João Granja, and Joseph P. Weber                   													 **********
**********        JOURNAL OF ACCOUNTING RESEARCH                               																		 **********
**********                                                         																	             	 **********
**********                                    		                	        														       		 **********
**********        TABLE OF CONTENTS:                                            																     **********
**********        -- A: Formation of the Datasets used in the Analysis																                 **********
**********        -- B: Merging the Datasets                    																               	     **********
**********        -- C: Regressions and Figures - Published Paper              																         **********
**********                                                          															         	       	 **********
**********                                                                        																	 **********
**********        README / DESCRIPTION:                                       																	     **********
**********        This STATA do-file converts the raw data into our final     																	     **********
**********        dataset and performs the main statistical analyses. The code         																 **********
**********        uses multiple datasets as inputs and yields the content         																	 **********
**********        of the main analysis as output. 			        																				 **********
**********                                                                         																	 **********
***************************************************************************************************************************************************************

*****************************************************************************************
*****************************************************************************************
******************************  A: SAMPLE FORMATION   ***********************************
*****************************************************************************************
*****************************************************************************************

log using final_log, replace

clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements/Data"
cd "$dropbox/Source Data"

*********************************************************************************************
* Step A.0 -- Pulling Relevant Variables from Call Report Data downloaded from WRDS: (2000:Q1-2010:Q4) and defining relevant variables with financial characteristics
*********************************************************************************************

// A.0.1 - Pull ID, Geographic, and Regulatory Information
use RSSD, clear
keep rssd9001 rssd9007 rssd9010 rssd9050 rssd9056 rssd9130 rssd9150 rssd9180 rssd9200 rssd9220 rssd9220 rssd9210 rssd9220 rssd9331 rssd9348 rssd9364 rssd9421 rssd9422 rssd9950 rssd9999

tostring rssd9999, replace force
gen q = substr(rssd9999,5,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr(rssd9999,1,4)
destring q y rssd9999, replace force
gen quarter = yq(y,q)
drop y q 

gen FedReg = rssd9421==1
gen county = 1000*rssd9210 + rssd9150

save "$dropbox/cleaned files/regmaster", replace

// A.0.2 - Pull Income Statement Information (RIAD Schedules)

use "RIAD", clear
tostring rssd9999, replace force
gen q = substr(rssd9999,5,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr(rssd9999,1,4)
destring q y rssd9999, replace force
gen quarter = yq(y,q)
drop y q 

keep rssd9001 quarter rssd9200 riad4340 riada517 riad4174 riad4230 riad4508 riad0093 riad4509 riadc233 riad4511 riada518 riad4512 riad4107 riadb522 riad4605 riadc079 riad3123 riad5523 ///
riad4079 riad4065 riad4070 riad4080 riada220 riadc886 riadc887 riadc888 riadc386 riadc387 riad4079 riadb491 riadb492 riadb493 riad4415 riadb507 riad4635 riad4302 riad3210 riada517 riadf556 ///
riad3123
tempfile RI
save "`RI'"

// A.0.3 - Pull Balance Sheet Information (RCON and RCFD Schedules)

use "RCON0.dta", clear
keep rssd9001 quarter rcon0010 rcon0352 rcon0426
tempfile RCON0
save "`RCON0'"

use "RCFD0.dta", clear
keep rssd9001 quarter rcfd0010 rcfd0426
tempfile RCFD0
save "`RCFD0'"

use "RCON1.dta", clear
keep rssd9001 quarter rcon1350 rcon1400 rcon1403 rcon1406 rcon1407 rcon1410 rcon1415 rcon1460 rcon1480 rcon1754 rcon1763 rcon1764 rcon1766 rcon1773 rcon1797
tempfile RCON1
save "`RCON1'"

use "RCFD1.dta", clear
keep rssd9001 quarter rcfd1350 rcfd1400 rcfd1403 rcfd1406 rcfd1407 rcfd1410 rcfd1415 rcfd1460 rcfd1480 rcfd1754 rcfd1763 rcfd1764 rcfd1766 rcfd1773 rcfd1797
tempfile RCFD1
save "`RCFD1'"

use "RCON2.dta", clear
keep rssd9001 quarter rcon2008 rcon2011 rcon2122 rcon2170 rcon2200 rcon2215 rcon2702 rcon2365 rcon2604 rcon2746 rcon2800 rcon2150
tempfile RCON2
save "`RCON2'"

use "RCFD2.dta", clear
keep rssd9001 quarter rcfd2008 rcfd2011 rcfd2122 rcfd2170 rcfd2200 rcfd2746 rcfd2800 rcfd2150
tempfile RCFD2
save "`RCFD2'"

use "RCON3.dta", clear
keep rssd9001 quarter rcon3190 rcon3200 rcon3210 rcon3230 rcon3163 rcon3345 rcon3485 rcon3486 rcon3487 rcon3469 rcon3411 rcon3814 rcon3816 rcon3817 rcon3818 rcon3819 rcon3821 rcon3838 rcon3839 rcon3123 rcon3632
tempfile RCON3
save "`RCON3'"

use "RCFD3.dta", clear
keep rssd9001 quarter rcfd3190 rcfd3200 rcfd3210 rcfd3230 rcfd3163 rcfd3345 rcfd3411 rcfd3814 rcfd3816 rcfd3817 rcfd3818 rcfd3819 rcfd3821 rcfd3838 rcfd3123 rcfd3839 rcfd3632
tempfile RCFD3
save "`RCFD3'"

use "RCON5.dta", clear
keep rssd9001 quarter rcon5367 rcon5368
tempfile RCON5
save "`RCON5'"

use "RCON6.dta", clear
keep rssd9001 quarter rcon6550 rcon6810 rcon6648 rcon6164 rcon6165 rcon6724
tempfile RCON6
save "`RCON6'"

use "RCFD6.dta", clear
keep rssd9001 quarter rcfd6550 rcfd6165 rcfd6164 rcfd6724
tempfile RCFD6
save "`RCFD6'"

use "RCON7.dta", clear
keep rssd9001 quarter rcon7204 rcon7205 rcon7206
tempfile RCON7
save "`RCON7'"

use "RCFD7.dta", clear
keep rssd9001 quarter rcfd7204 rcfd7205 rcfd7206
tempfile RCFD7
save "`RCFD7'"

use "RCON8.dta", clear
keep rssd9001 quarter rcon8500 rcon8504 rcon8503 rcon8507 rcon8274
tempfile RCON8
save "`RCON8'"

use "RCFD8.dta", clear
keep rssd9001 quarter rcfd8500 rcfd8504 rcfd8503 rcfd8507 rcfd8274 
tempfile RCFD8
save "`RCFD8'"

use "RCONA.dta", clear
keep rssd9001 quarter rcona514 rcona529 rcona584 rcona585 rcona223 rcona224
tempfile RCONA
save "`RCONA'"

use "RCFDA.dta", clear
keep rssd9001 quarter rcfda223 rcfda224 
tempfile RCONA
save "`RCONA'"

use "RCONB.dta", clear
keep rssd9001 quarter rconb563 rconb987 rconb989 rconb993 rconb995 rconb538 rconb539 
tempfile RCONB
save "`RCONB'"

use "RCFDB.dta", clear
keep rssd9001 quarter rcfdb987 rcfdb989 rcfdb993 rcfdb995 rcfdb538 rcfdb539 
tempfile RCFDB
save "`RCFDB'"

use "RCONC.dta", clear
keep rssd9001 quarter rconc026 rconc027 
tempfile RCONC
save "`RCONC'"

use "RCFDC.dta", clear
keep rssd9001 quarter rcfdc026 rcfdc027 rcfdc410 rcfdc411
tempfile RCFDC
save "`RCFDC'"

use "RCONF.dta", clear
keep rssd9001 quarter rconf049 rconf045 rconf070 rconf071 rconf158 rconf159 rconf160 rconf161 rconf164 rconf165
tempfile RCONF
save "`RCONF'"

use "RCFDF.dta", clear
keep rssd9001 quarter rcfdf070 rcfdf071 rcfdf164 rcfdf165
tempfile RCFDF
save "`RCFDF'"

use "RCONG.dta", clear
keep rssd9001 quarter rcong167 rcong300 rcong304 rcong308 rcong312 rcong316 rcong320 rcong324 rcong328 rcong315 rcong319 rcong323 rcong327 rcong331 ///
rcong336 rcong340 rcong344 rcong303 rcong307 rcong311 rcong339 rcong343 rcong347 rconj473 rconj474 rconj457 rconj458 rconj459
tempfile RCONG
save "`RCONG'"

use "RCFDG.dta", clear
keep rssd9001 quarter rcfdg300 rcfdg304 rcfdg308 rcfdg312 rcfdg316 rcfdg320 rcfdg324 rcfdg328 rcfdg315 rcfdg319 rcfdg323 rcfdg327 rcfdg331 ///
rcfdg336 rcfdg340 rcfdg344 rcfdg303 rcfdg307 rcfdg311 rcfdg339 rcfdg343 rcfdg347 rcfdj457 rcfdj458 rcfdj459
tempfile RCFDG
save "`RCFDG'"

use "$dropbox/cleaned files/regmaster", clear
local c RI RCON0 RCON1 RCON2 RCON3 RCON5 RCON6 RCON7 RCON8 RCONA RCONB RCONF RCONG RCFD0 RCFD1 RCFD2 RCFD3 RCFD6 RCFD7 RCFD8 RCFDB RCFDC RCFDF RCFDG
foreach x of local c{
	merge 1:1 rssd9001 quarter using "``x''"
	drop _merge
	
}
keep if quarter<200

tempfile var1994_2010
save `var1994_2010'

// A.0.4 - Pulling in 2010:Q1 - 2012:Q4 (This set of files was downloaded from FFIEC rather than WRDS)
local d RCA RCCI RCCII RCD RCE RCEI RCEII RCF RCG RCH RCI RCK RCN RCN_1 RCN_2 RCM RCO RCP RCS RI_2 RIA RIBI RIBII RID RIE RCB_1 RCL_1 RCQ_1 RCR_1 RCT_1 RCB_2 RCL_2 RCQ_2 RCR_2 RCT_2
use RC, clear

foreach t of local d{
 merge 1:1 rssd9001 quarter using `t', update
 drop _merge
}
*************************************

gen year =  substr(quarter,5,4)
gen q = substr(quarter,1,2)
gen d = substr(quarter,3,2)
gen rssd9999 = year + q + d
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
destring year q rssd9999, replace force
gen qrt = yq(year,q)
drop quarter
rename qrt quarter

// Defining what variables to keep
keep rssd9001 rssd9999 quarter riada517 riad4415 riad4508 riad0093 riada518 riad4340 rcon0010 rcon0352 rcon3230 rcon3163 rcfd3230 rcfd3163 rcon1227 rcon1228 rcon1420 rcon1460 rcon1545 rcon1590 rcon1607 rcon1608 rcon1754 rcon1763 rcon1764 rcon1766 rcon1773 rcon1797 rcon2011 rcon2081 rcon2107 rcon2122 rcon2165 ///
rcon2170 rcon2200 rcon2215 rcon2365 rcon2746 rcon3190 rcon3200 rcon3210 rcon3411 rcon3485 rcon3494 rcon3495 rcon3500 rcon3501 rcon3814 rcon3817 rcon3838 rcon5367 rcon5368 rcon5390 rcon5391 rcon5399 rcon5400 rcon5460 ///
rcon5461 rcon6550 rcon6810 rcon6648 rcon7204 rcon7205 rcon7206 rcona514 rcona529 rcona584 rcona585 rconb531 rconb534 rconb535 rconb538 rconb539 rconb563 rconb987 rconb989 rconb993 rconb995 rconb538 rconb539 rconb576 rconb577 rconb579 rconb580 rconb835 rconb836 ///
rconc026 rconc027 rconc229 rconc230 rconc237 rconc239 rconf049 rconf045 rconf070 rcon7273 rcon7274 rcon7275 rcfnb574 rcon0426 rcfd0426  ///
rconf158 rconf159 rconf160 rconf161 rconf164 rconf165 rconf174 rconf175 rconf176 rconf177 rconf180 rconf181 rconf182 rconf183 rcong167 rcong300 rcong304 rcong308 rcong312 rcong316 rcong320 rcong324 rcong328 rcong336 rcong340 rcong344 rcong303 rcong307 rcong311 rcong315 ///
rcong319 rcong323 rcong327 rcong331 rcong339 rcong343 rcong347 rconj451 rconj453 rconj454 rconj457 rconj458 rconj459 rconj473 rconj474 rconk137 rconk142 rconk145 rconk146 rconk149 rconk150 rconk153 rconk154 rconk157 rconk207 ///
rcfd0010 rcfd1410 rcfd1754 rcfd1763 rcfd1764 rcfd1773 rcfd2011 rcfd2122 rcfd2170 rcfd2746 rcfd3190 rcfd3200 rcfd3210 rcfd3411 rcfd3814 rcfd3817 rcfd3838 rcfd3839 rcon3839 ///
rcfd6550 rcfd7204 rcfd7205 rcfd7206 rcfdb989 rcfdb995 rcfdb538 rcfdb539 rcfdc026 rcfdc027 rcfdf164 rcfdf165 rcfdg300 rcfdg304 rcfdg308 rcfdg312 rcfdg316 rcfdg320 rcfdg324 rcfdg328 rcfdg315 rcfdg319 rcfdg323 rcfdg327 rcfdg331 ///
rcfdg336 rcfdg340 rcfdg344 rcfdg303 rcfdg307 rcfdg311 rcfdg339 rcfdg343 rcfdg347 rcfdk137 rcfdk207 rcfdb534 rcfdb532 rcfdb533 rcfdb536 rcfdb537 rcfd1590 rcfdb538 rcfdb539 rcfd1763 rcfd1764 rcfd2011 ///
rcfd2081 rcfd2107 rcfd1563 rcfdf162 rcfdf163 rcfdj457 rcfdj458 rcfdj459 rcon1583 rcon1256 rcon2150 rcfd2150 rcon3632 rcfd3632 ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 rcfd1256 rcfdb577 rcfdk215 rcfdk218 ///
rcfd5461 rcfdf168 rcfdf171 rcfd3507 rcfdk038 rcfdk041 rcfdk044 rconk047 rconk050 rconk053 rconk056 rconk059 rconk062 rconk065 rconk068 rconk071 ///
rcfdk074 rcfdk077 rcfdk080 rcfdk083 rcfdk086 rcfdk089 rcfdk093 rcfdk097 rcfdk101 rcfdk272 rcfnk293 rcfdk104 rcon3123 rcfd3123 ///
rcon5382 rcon1583 rcon1256 rconb577 rconk215 rconk218 rcon5391 rcon5461 rconf168 rcon3507 rconk038 rconk041 rconk044 rconk074 rconk077 rconk080 rconk083 rconk086 rconk089 rconk093 rconk097 rconk101 rconk272 rconk104 /// 
rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 rcfd1255 rcfdb576 rcfdk214 rcfdk217 rcfd5390 rcfd5460 rcfdf167 rcfdf170 rcfd3506 ///
rcfdk037 rcfdk040 rcfdk043 rconk046 rconk049 rconk052 rconk055 rconk058 rconk061 rconk064 rconk067 rconk070 rcon8274 rcfd8274 ///
rcfdk073 rcfdk076 rcfdk079 rcfdk082 rcfdk085 rcfdk088 rcfdk092 rcfdk096 rcfdk100 rcfdk271 rcfnk292 rcfdk103 riad4230 rcona223 rcona224 ///
rcon5381 rcon1597 rcon1255 rconb576 rconk214 rconk217 rcon5390 rcon5460 rconf167 rcon3506 rconk037 rconk040 rconk043 rconk046 rconk049 rconk052 rconk055 rconk058 rconk061 rconk064 rconk067 rconk070 ///
rconk073 rconk076 rconk079 rconk082 rconk085 rconk088 rconk092 rconk096 rconk100 rconk271 rcfnk292 rconk103 rcfd3819 rcfd3821 rcon3819 rcon3821 ///
rcfdb579 rcfd5390 rcfd5460 rcfdf167 rcfdf170 rcfd3506 rcfd5613 rcfd5616 rcfdc867 rconb579 rcon5613 rcon5616 rconc867 ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcon5382 rcon1583 rcfd1253 rcfdj457 rcfdj458 rcfdj459 rconj457 rconj458 rconj459 ///
rcon1256 rconb577 rconb580 rcon5391 rcon5461 rcfdf168 rcfdf171 rcon3507 rcon5614 rcon5617 rcfdc868 riadb491 riadb492 riadb493 riadf556  ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 rcfd6724 rcon6724 ///
rcfd1256 rcfdb577 rcfdb580 rcfd5391 rcfd5461 rcfdf168 rcfdf171 rcfd3507 rcfd5614 rcfd5617 rcfdc868 riad4070 riad4080 riada220 riadc886 riadc887 riadc888 riadc386 riadc387 riad4079 riad4079 riad4065 riad4107 rconf172 rconf173 rcon3493 rcon5398 rconc236 rconc238 rcon3499 rconf178 ///
rconf179 rcfnb572 rcfd5377 rcfd5380 rcfd1594 rcfd1251 rcfd1254 rcfdb575 rcfdb578 rconb578 rcfd5389 rcfd5459 rcfdf166 rconf166 rcfdf169 rcfdk213 rcfdk216 rcfd6165 rcfd6164 rcon6165 rcon6164 rcon1254 rconb575 rconk213 rconk216 rcon5389 rcon5459 rcon1594 rcon5380 riadb507 rcfda223 riad4635 riad4605 riad4302 riad3210 riad3123

tempfile var2010_2013
save `var2010_2013'

use "$dropbox/cleaned files/regmaster", clear
merge 1:1 rssd9001 quarter using `var2010_2013'
keep if quarter>199
drop _merge

save `var2010_2013', replace
use `var1994_2010', clear
append using `var2010_2013'


// A.0.5 - Creating Financial Ratios and other variables to use in the main empirical analysis

tsset rssd9001 quarter
tostring rssd9999, replace force

// Defining the Restatement Variables
gen restat = riadb507 !=0 if riadb507!=.
gen negrestat = riadb507 <0 if riadb507!=.
gen posrestat = riadb507 > 0 if riadb507!=.

// Restatement Amount as a fraction of total risk-weighted assets
gen riskeqcapital = rcfda223
replace riskeqcapital = rcona223 if quarter>=200
gen pct_negrestat = riadb507/riskeqcapital if riadb507 <=0 & riadb507!=.

// Fixed-Effect Groups
egen state = group(rssd9200)
egen reg_state = group(rssd9200 FedReg)
egen cnty_qt  = group(county quarter)

* Creating Size Variable (Total Assets)
gen totass = rcfd2170
replace totass = rcon2170 if rcfd2170==.
label var totass "Total Assets (Current Prices)"

gen totdep = rcfd2200
replace totdep = rcon2200 if totdep==.
label var totdep "Total Deposits (Current Prices)"

gen tot_loans = rcfd2122
replace tot_loans = rcon2122 if tot_loans==.
label var tot_loans "Total Loans (Current Prices)"

// Portfolio Composition Variables: Share of Residential, CRE, and Consumer Loans

* Residential 1-4 Family Loans
gen residential = rcon1797 + rcon5367 + rcon5368 // Total Loand secured by Residential Real Estate
gen resishare = residential/tot_loans

* Commercial & Real Estate Loans
gen cre_loans = rcon1415 + rcon1460 + rcon1480 + rcfd2746 // Total Loans secured by CRE
replace cre_loans = rconf158 + rconf159 + rcon1460 + rconf160 + rconf161 + rcfd2746 if cre_loans==. 
replace cre_loans = rconf158 + rconf159 + rcon1460 + rconf160 + rconf161 + rcon2746 if cre_loans==.
gen creshare = cre_loans/tot_loans

// Consumer Loans Share
gen cons_loans = rcfdb538 + rcfdb539 + rcfd2011 if quarter<200 // Total Individual loans
replace cons_loans = rcfdb538 + rcfdb539 + rcfd2011 if quarter>=200 
replace cons_loans = rconb538 + rconb539 + rcon2011 if quarter>=200 & cons_loans==.
replace cons_loans = rcfdb538 + rcfdb539 + rcfdk137 + rcfdk207 if quarter>=204 & cons_loans==.
replace cons_loans = rconb538 + rconb539 + rconk137 + rconk207 if quarter>=204 & cons_loans==.
gen cshare = cons_loans/tot_loans


// Asset Quality Ratios: Delinquent Loan Ratio (NPL ratio) and OREO Ratio (Foreclosed Property Ratio)

// NPL Ratio
gen npl1403 = rcfd1403 if quarter<200
egen npl1403v1 = rowtotal (rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 ///
rcfd1256 rcfdb577 rcfdb580 rcfd5391 rcfd5461 rcfdf168 rcfdf171) if quarter>=200 & quarter<204 & rcfd5391!=.
egen npl1403v2 = rowtotal (rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcon5382 rcon1583 rcfd1253 ///
rcon1256 rconb577 rconb580 rcon5391 rcon5461 rconf168 rcfdf171) if quarter>=200 & quarter<204
replace npl1403 = npl1403v1 if npl1403==.
replace npl1403 = npl1403v2 if npl1403==.

gen npl1407 = rcfd1407
egen npl1407v1 = rowtotal(rconf174 rconf175 rcon3494 rcon5399 rconc237 rconc239 rcon3500 rconf180 rconf181 rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 ///
rcfd1255 rcfdb576 rcfdb579 rcfd5390 rcfd5460 rcfdf167 rcfdf170) if quarter>=200 & quarter<204 & rcfd5381!=.
egen npl1407v2 = rowtotal(rconf174 rconf175 rcon3494 rcon5399 rconc237 rconc239 rcon3500 rconf180 rconf181 rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 ///
rcfd1255 rcfdb576 rconb579 rcfd5390 rcfd5460 rconf167 rcfdf170) if quarter>=200 & quarter<204
replace npl1407 = npl1407v1 if npl1407==.
replace npl1407 = npl1407v2 if npl1407==.

gen npl_loans = (npl1407 + npl1403) // This is total non-performing loans
gen nplratio = (npl1407 + npl1403)/tot_loans
label var nplratio "Nonperforming Loans (+90 PD + Nonacc)/Total Loans"
drop npl1403v1 npl1403v2 npl1407v1 npl1407v2

// Other Real Estate Owned Ratio

gen oreo_ratio = rcfd2150/rcfd2170
replace oreo_ratio = rcon2150/rcon2170 if oreo_ratio==.


// Liquidity and Solvency Ratios
******
* Liquidity Ratio is the Unused Commmitment Ratio (Following Acharya and Mora, 2015 JF)

* Total Commitments
egen commitments = rowtotal(rcfd3814 rcfd3816 rcfd3817 rcfd3818 rcfd6550 rcfd3411) if quarter<200
egen commitments1 = rowtotal(rcfd3814 rcfdf164 rcfdf165 rcfd3817 rcfdj457 rcfdj458 rcfdj459 rcfd6550 rcfd3411) if quarter>=200 & rcfd3814!=.
egen commitments2 = rowtotal(rcon3814 rconf164 rconf165 rcon3817 rconj457 rconj458 rconj459 rcon6550 rcon3411) if quarter>=200
replace commitments = commitments1 if commitments==.
replace commitments = commitments2 if commitments==.

* Unused Commitments ratio
gen commit_ratio = commitments/(tot_loans+commitments)
label var commit_ratio "Unused Commitments as % Gross Loans + Unused Commitments"
drop commitments1 commitments2

// Tier 1 Capital Ratio
replace rcon7204 = rcon7204*100 if quarter<195 |quarter>=200
gen tier1ratio = rcon7204
gen wellcap = tier1ratio>5

******************************
// Income and Loan Loss Numbers
************************************

// Quarterly Income
gen qinc = riad4340-l.riad4340
replace qinc = riad4340 if substr(rssd9999, 5, 2)=="03"

// Charge-Offs by Quarter
gen CO_qrt = (riad4635-riad4605) if substr(rssd9999, 5, 2)=="03"
replace CO_qrt = (riad4635-riad4605) - (l.riad4635-l.riad4605) if substr(rssd9999, 5, 2)!="03"

// Quarterly Provisions
gen prov_qrt = riad4230 if substr(rssd9999, 5, 2)=="03"
replace prov_qrt = riad4230 - l.riad4230 if substr(rssd9999, 5, 2)!="03"

// Allowance for Loan and Lease Losses (ALLL)
gen ALLL = riad3123

keep rssd9001 quarter riad3123 restat-ALLL
save "$dropbox/cleaned files/char",replace

*********************************************************************************************
* Step A.1 -- Pulling and cleaning TED Spread Data
*********************************************************************************************

import delimited "TEDRATE.csv", clear
rename tedrate av_ted

tostring date, replace force
gen q = substr(date,6,2)
replace q = "1" if q=="01"
replace q = "2" if q=="04"
replace q = "3" if q=="07"
replace q = "4" if q=="10"
gen y = substr(date,1,4)
destring q y date, replace force
gen quarter = yq(y,q)
drop y q date

tsset quarter
gen nextyr_av_ted = f4.av_ted
gen lastyr_av_ted = l4.av_ted

save "$dropbox/cleaned files/TED", replace

*********************************************************************************************
* Step A.2 -- Creating Bank-Specific House Price Indices
*********************************************************************************************

// A.2.1 --> Pulling and Cleaning House Price Data obtained from FFIEC website

// 1) Metropolitan Areas House Price Indices
import delimited "3q13hpi_cbsa.csv", clear
drop v6

rename v1 msaname
rename v2 msabr
rename v3 year
rename v4 q
rename v5 HPI

gen divisionb = msabr

destring HPI, replace force
gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if  msaname[`i'+4]==msaname[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  msaname[`i']==msaname[`i'-4]
}


gen quarter = yq(year,q)
drop year q HPI

tempfile MSA_HPI
save `MSA_HPI', replace

// 2) House Price Indices of the NonMetropolitan Areas of each State
import excel "indexes_nonmetro_thru_13q3.xls", sheet("hpi_stsbal") clear
drop in 1/3
rename A stalpbr
rename B year
rename C q
rename D HPI
drop E

destring  year q HPI, replace force

gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if stalpbr[`i'+4]==stalpbr[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  stalpbr[`i']==stalpbr[`i'-4]
}

gen quarter = yq(year,q)
drop year q HPI

tempfile nonMSA_HPI
save `nonMSA_HPI'

// 3) Puerto Rico
import excel "PR_Downloadable_alltransactions.xls", sheet("Puerto Rico--All Transactions") clear
drop in 1/6
drop A
gen stalpbr = "PR"
rename B year
rename C q
rename D HPI

destring  year q HPI, replace force

gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if stalpbr[`i'+4]==stalpbr[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  stalpbr[`i']==stalpbr[`i'-4]
		}

gen quarter = yq(year,q)
drop year q HPI
duplicates drop stalpbr quarter, force

append using `nonMSA_HPI'
save `nonMSA_HPI', replace

// A.2.2 -->  Merge HPI indices with SOD data: Computing Bank-Specific House Price Change Index that weights House Price Changes based on share of deposits of the bank in each area

foreach num of numlist 1(1)4{
use "/Users/joaogranja/Dropbox (Personal)/Summary of Deposits/SOD_all.dta", clear
gen q = `num'
gen quarter = yq(year,q)
drop year q

merge m:1 msabr quarter using `MSA_HPI'
drop if _merge==2
drop _merge

merge m:1 divisionb quarter using `MSA_HPI', update
drop if _merge==2
drop _merge

merge m:1 stalpbr quarter using `nonMSA_HPI', update
drop if _merge==2
drop _merge

collapse (mean) HPI_change HPI_pastchange [fw=depsumbr], by(cert quarter)
rename cert rssd9050
saveold "$dropbox/cleaned files/HPI_changeq`num'", replace
}

append using "$dropbox/cleaned files/HPI_changeq3"
append using "$dropbox/cleaned files/HPI_changeq2"
append using "$dropbox/cleaned files/HPI_changeq1"
rename HPI_change HPI_yoy_change

save "$dropbox/cleaned files/HPI_changeyoy", replace

*********************************************************************************************
* Step A.3. -- Pulling and Cleaning Textual Description of the Catch-Up restatements
*********************************************************************************************

//PULLING IN RI-E SCHEDULE DATA

clear all
cd "$dropbox/Source Data/FFIEC RIE Schedules for all quarters"
file open myfile using "../filelist.txt", read
file read myfile line
drop _all
import delimited "`line'", clear

keep textb526 textb527 idrssd
drop in 1 //dropping label row
save "`line'.dta", replace
gen q = substr("`line'",29,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr("`line'",33,4)
destring q y, replace force
gen quarter = yq(y,q)
drop y q
rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
save "$dropbox/cleaned files/RIE_data.dta", replace 
drop _all

file read myfile line
while r(eof)==0 {
import delimited "`line'", clear
keep textb526 textb527 idrssd
drop in 1 //dropping label row
save "`line'.dta", replace
gen q = substr("`line'",29,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr("`line'",33,4)
destring q y, replace force
gen quarter = yq(y,q)
drop y q 
rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
append using "$dropbox/cleaned files/RIE_data.dta"
duplicates drop rssd9001 quarter, force
save "$dropbox/cleaned files/RIE_data.dta", replace
drop _all
file read myfile line
}


local a 12312009 12312010 09302009 09302010 06302010 03312008 03312010 06302007 06302008 06302009 09302007 09302008 12312007 12312008
foreach b of local a{
	import delimited "FFIEC CDR Call Schedule RIE `b'.txt", clear varnames(1)
	keep textb527 idrssd
	drop in 1 //dropping label row
	gen q = substr("`b'",1,2)
	replace q = "1" if q=="03"
	replace q = "2" if q=="06"
	replace q = "3" if q=="09"
	replace q = "4" if q=="12"
	gen y = substr("`b'",5,4)
	destring q y, replace force
	gen quarter = yq(y,q)
	drop y q 
	rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
	append using "$dropbox/cleaned files/RIE_data.dta"
	save "$dropbox/cleaned files/RIE_data.dta", replace
clear all
}


cd ..

use "$dropbox/cleaned files/RIE_data.dta", clear
gen text = textb526
replace text = textb527 if text==""
replace text = proper(text)
drop textb526 textb527

// Mathematical or Rounding Error Categories
gen error =  regexm(text,"((Math)+)") | regexm(text,"((Round)+)") 

// Adjustment related to change in Accounting Principle
gen principle =  regexm(text,"(Fas)") | regexm(text,"((Eitf)+)") | regexm(text,"((Sab)+)") | regexm(text,"((Fin48)+)") | regexm(text,"((fas)+)") | regexm(text,"((Fin 48)+)")  | regexm(text,"((Principle)+)") | regexm(text,"((Split)+)") ///
| regexm(text,"((Eift)+)") | regexm(text,"((Life Insurance)+)") | regexm(text,"((Retirement)+)") | regexm(text,"((Boli)+)") | regexm(text,"((principal)+)") 

// Adjustments that are related to Audits
gen audit =  regexm(text,"((Audit)+)")

// Adjustments that are related to Taxes
gen tax =  regexm(text,"((Tax)+)") | regexm(text,"((tax)+)") | regexm(text,"((Irs)+)")

// Adjustments in Loan Loss Accounting
gen loanloss =  regexm(text,"((Loan Loss)+)") | regexm(text,"((Loss Reserve)+)") | regexm(text,"((Llr)+)") | regexm(text,"((Alll)+)") | regexm(text,"((Allowance)+)") // Loan Loss Accounting

// Adjustment related to the misclassification or mismeasurement of the portfolio of securities and Investments
gen secport = regexm(text,"((Reclassification)+)") | regexm(text,"((Htm)+)") | regexm(text,"((Afs)+)") | regexm(text,"((Unrealized Gains)+)") | regexm(text,"((Unrealized Losses)+)") | regexm(text,"((U/R)+)") | regexm(text,"((Write Down)+)") | regexm(text,"((Write-Down)+)") ///
| regexm(text,"((Wrote Down)+)") | regexm(text,"((Impairment)+)") | regexm(text,"((Oci)+)") | regexm(text,"((Other Comprehensive Income)+)") | regexm(text,"((Investment)+)") | regexm(text,"((Reo)+)") | regexm(text,"((Oreo)+)")

// Accrual Accounting Adjustment
gen noncurrent = regexm(text,"((Goodwill)+)") | regexm(text,"((Depreciation)+)") | regexm(text,"((Depr.)+)") | regexm(text,"((Amortization)+)") | regexm(text,"((Lease)+)") | regexm(text,"((Pension Plan)+)") | regexm(text,"((Mortgage Servicing)+)") // Accruals related to noncurrent assets and liabilities

// Consolidation Accounting Adjustment
gen consolidation = regexm(text,"((Consolidation)+)") | regexm(text,"((Unconsolidated)+)") | regexm(text,"((Subsidiary)+)") | regexm(text,"((Parent)+)") | regexm(text,"((Holding)+)") |  regexm(text,"((Merger)+)") | regexm(text,"((Purchase Accounting)+)") // Consolidation Acounting

// General Accounting Adjustment
gen accounting = regexm(text,"((Reserve)+)") | regexm(text,"((Loan Loss)+)") | regexm(text,"((Loss Reserve)+)") | regexm(text,"((Llr)+)") | regexm(text,"((Alll)+)") | regexm(text,"((Provision)+)") | regexm(text,"((Allowance)+)") /// Loan Loss Accounting
| regexm(text,"((Reclassification)+)") | regexm(text,"((Htm)+)") | regexm(text,"((Afs)+)") | regexm(text,"((Unrealized Gains)+)") | regexm(text,"((Unrealized Losses)+)") | regexm(text,"((U/R)+)") | regexm(text,"((Write Down)+)") | regexm(text,"((Write-Down)+)") | regexm(text,"((Wrote Down)+)") | regexm(text,"((Impairment)+)") | regexm(text,"((Oci)+)") | regexm(text,"((Other Comprehensive Income)+)") | regexm(text,"((Investment)+)") | regexm(text,"((Reo)+)") | regexm(text,"((Oreo)+)") /// Misclassification of Gains and Losses on Securities
| regexm(text,"((Accrual)+)") | regexm(text,"((Accr)+)") | regexm(text,"((Overaccrual)+)") | regexm(text,"((Accrued)+)") | regexm(text,"((Deferred)+)") | regexm(text,"((Deferral)+)") | regexm(text,"((Payable)+)") | regexm(text,"((Receivable)+)") | regexm(text,"((Adjusting Entries)+)") | regexm(text,"((Reverse entry)+)")  /// Errors in Accrual Accounting
| regexm(text,"((Goodwill)+)") | regexm(text,"((Depreciation)+)") | regexm(text,"((Depr.)+)") | regexm(text,"((Amortization)+)") | regexm(text,"((Lease)+)") | regexm(text,"((Pension Plan)+)") | regexm(text,"((Mortgage Servicing)+)") | regexm(text,"((Prepaid)+)") /// Specific misclassified Accounting accruals
| regexm(text,"((Expense)+)") | regexm(text,"((Interest)+)")  /// Misclassification of interest and expense
| regexm(text,"((Consolidation)+)") | regexm(text,"((Unconsolidated)+)") | regexm(text,"((Subsidiary)+)") | regexm(text,"((Parent)+)") | regexm(text,"((Holding)+)") |  regexm(text,"((Merger)+)") | regexm(text,"((Purchase Accounting)+)") /// Investment Acounting
| regexm(text,"((Liability Increase)+)") | regexm(text,"((Retained Earnings)+)")  | regexm(text,"((Understated)+)") | regexm(text,"((Overstated)+)") | regexm(text,"((Measurement)+)") | regexm(text,"((Unrecorded)+)") /// Issues with Measurement
| regexm(text,"((Accounting)+)") 

duplicates drop rssd9001 quarter, force
save "$dropbox/cleaned files/RIE_data_final.dta", replace

*********************************************************************************************
* Step A.4. -- Pulling the dates of the last submission of the Call Report (To compute likelihood of an ammendment to the call report)
*********************************************************************************************

local a 12312010 12312009 12312008 12312007 12312006 12312005 09302010 09302009 09302008 09302007 09302006 09302005 06302010 06302009 06302008 06302007 06302006 03312010 03312009 03312008 03312007 03312006
foreach b of local a{
import delimited  "$dropbox/Source Data/FFIEC/FFIEC CDR Call Bulk All Schedules `b'/FFIEC CDR Call Bulk POR `b'.txt", clear
gen callreportdate = "`b'"
gen monthcallreport = substr(callreportdate, 1,2)
gen daycallreport = substr(callreportdate, 3,2)
gen yearcallreport = substr(callreportdate, 5,4)
gen monthlastsubmission = substr(lastdatetimesubmissionupdatedon, 6,2)
gen daylastsubmission = substr(lastdatetimesubmissionupdatedon, 9,2)
gen yearlastsubmission = substr(lastdatetimesubmissionupdatedon, 1,4)
destring monthlastsubmission daylastsubmission yearlastsubmission monthcallreport daycallreport yearcallreport, replace force
gen lastcalldate = mdy(monthlastsubmission, daylastsubmission, yearlastsubmission)
gen calldate = mdy(monthcallreport, daycallreport, yearcallreport)
gen diffcalldate = lastcalldate-calldate

rename idrssd rssd9001

tostring yearcallreport monthcallreport , replace force
replace monthcallreport = "1" if monthcallreport=="03"
replace monthcallreport = "1" if monthcallreport=="3"
replace monthcallreport = "2" if monthcallreport=="06"
replace monthcallreport = "2" if monthcallreport=="6"
replace monthcallreport = "3" if monthcallreport=="09"
replace monthcallreport = "3" if monthcallreport=="9"
replace monthcallreport = "4" if monthcallreport=="12"
destring monthcallreport yearcallreport, replace force

gen quarter = yq(yearcallreport,monthcallreport)
keep rssd9001 quarter lastcalldate calldate diffcalldate
save  "$dropbox/Source Data/FFIEC/days`b'", replace
}
*
local a 12312009 12312008 12312007 12312006 12312005 09302010 09302009 09302008 09302007 09302006 09302005 06302010 06302009 06302008 06302007 06302006 03312010 03312009 03312008 03312007 03312006
use  "$dropbox/Source Data/FFIEC/days12312010", clear
foreach b of local a{
append using  "$dropbox/Source Data/FFIEC/days`b'"
}
duplicates drop rssd9001 quarter,force // Eliminates one duplicate observation -- Error in the data
save  "$dropbox/cleaned files/dates",replace


*******************************************************************************************************************
*******************************************************************************************************************
******************************  B: MERGING DATASETS   *************************************************************
*******************************************************************************************************************
*******************************************************************************************************************

clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements/Data"

// Start with ID, Geographic, and Regulatory Information 
use "$dropbox/cleaned files/regmaster", clear

// Merging the Financial Characteristics Variables
merge 1:1 rssd9001 quarter using "$dropbox/cleaned files/char"
drop if _merge==2
drop _merge

// Merging with the Bank Regulatory Index obtained form Amit Seru
merge m:1 rssd9200 using "$dropbox/cleaned files/alst_cross_states"
replace b = 0 if FedReg==1 & b!=.
drop _merge

// Merging the TED Spread
merge m:1 quarter using "$dropbox/cleaned files/TED"
drop if _merge==2
drop _merge

// Merging with the HPI Y-o-Y Change
merge m:1 rssd9050 quarter using "$dropbox/cleaned files/HPI_changeyoy"
drop if _merge==2
drop _merge

// Merging the Text Variables
merge m:1 rssd9001 quarter using "$dropbox/cleaned files/RIE_data_final"
drop if _merge==2
drop _merge

// Merging Last Call Report Dates

merge 1:1 rssd9001 quarter using "$dropbox/cleaned files/dates"
drop if _merge==2
drop _merge

save "$dropbox/work files/sample", replace

*******************************************************************************************************************
*******************************************************************************************************************
******************************  C: Regressions and Figures - Published Paper    ***********************************
*******************************************************************************************************************
*******************************************************************************************************************


clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements"
cd "$dropbox/Final Results"

use "$dropbox/Data/work files/sample", clear

// 1) Labeling the main variables

label var FedReg "Federal Regulator"
label var b "Regulatory Leniency Index"
label var totass "Total Assets"
label var totdep "Total Deposits"
label var resishare "Residential Loans/Total Loans"
label var creshare "CRE Loans/Total Loans"
label var cshare "Consumer Loans/Total Loans"
label var nplratio "Nonperforming Loans/Total Loans"
label var oreo_ratio "Other Real Estate Owned Ratio"
label var commit_ratio "Unused Commitment Ratio"
label var negrestat "Negative Restatement"
label var posrestat "Positive Restatement"


*****************************************************************
*****************************************************************
// Descriptive Statistics
*****************************************************************
*****************************************************************

************************
* Table 1, Panel A: Summary Statistics
**********************

// Step 1: Run main regression to guarantee that I provide descriptives of the set of observations that I use in the main regression
gen lnassets = ln(totass)
gen lndep = ln(totdep)
global d lnassets lndep resishare cshare creshare nplratio oreo_ratio commit_ratio
areg negrestat b $d i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)


// Panel A:
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist FedReg b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

************************
* Table 1, Panel B: Summary Statistics of State-Chartered Banks and Federal-Chartered Banks
**********************

// Summary Statistics of Federal-Chartered Banks

tempfile a 
save `a'

keep if FedReg==1
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives_federal, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

// Summary Statistics of State-Chartered Banks
use `a', clear

areg negrestat b $d i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
keep if FedReg==0
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives_state, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

use `a', clear
tempfile r 
save `r'
************************
* Table 1, Panel C: Summary Statistics of Restatements by Type
**********************

********************************
// Creating the Negative Restatement by Category Variables

foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	gen `var'_negrestat = `var' * negrestat
	gen `var'_pctnegrestat = `var' * pct_negrestat
}

******************************
label var error_negrestat "Error Restatement"
label var principle_negrestat "Principle Restatement"
label var tax_negrestat "Tax Restatement"
label var audit_negrestat "Audit Restatement"
label var accounting_negrestat "Accounting Restatement"
********************************

drop if text==""
foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	replace `var'_pctnegrestat = . if `var'_pctnegrestat==0
}
collapse audit_negrestat tax_negrestat accounting_negrestat loanloss_negrestat secport_negrestat noncurrent_negrestat consolidation_negrestat error_negrestat principle_negrestat audit tax accounting error principle loanloss secport noncurrent consolidation audit_pctnegrestat tax_pctnegrestat accounting_pctnegrestat error_pctnegrestat principle_pctnegrestat loanloss_pctnegrestat secport_pctnegrestat noncurrent_pctnegrestat consolidation_pctnegrestat
foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	gen `var'_share = `var'_negrestat/`var'
}

****
* Reshaping the dataset

local a error principle audit tax loanloss secport noncurrent consolidation accounting
foreach b of local a{
	preserve
	keep `b'*
		drop `b'_negrestat
		rename `b'_share share_neg
		rename `b' percent
		rename `b'_pctnegrestat pctnegrestat
		gen type = "`b'"
		tempfile `b'_temp
		save ``b'_temp'
		restore
	}
**********
use `error_temp', clear
local c principle audit tax loanloss secport noncurrent consolidation accounting
	foreach d of local c{
	append using ``d'_temp'
}

replace type  = "Error Restatements" if type=="error"
replace type  = "Principle Restatements" if type=="principle"
replace type  = "Tax Restatements" if type=="tax"
replace type  = "Audit Restatements" if type=="audit"
replace type  = "Loan Loss Accounting Restatements" if type =="loanloss"
replace type = "Securities Portfolio Restatements" if type=="secport"
replace type = "Noncurrent Items Restatements" if type=="noncurrent"
replace type = "Consolidation Accounting Restatements" if type=="consolidation"
replace type = "Other Accrual Accounting Restatements" if type=="accounting"
order type percent share_neg pctnegrestat

foreach var of varlist percent share_neg pctnegrestat{
replace `var' = `var'*100
}
mkmat percent share_neg pctnegrestat, matrix(b) rown(type)
mat colnames b= "\%_Restatements" "ShareNegativeRestatements" "AverageAmount" 
outtable using "PanelCTable2", mat(b) replace nobox center f(%12.2fc %12.2fc %12.2fc)


************************
* Table 2: Likelihood of Negative Restatement
**********************

use `r', clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

// Setting up the Panel Setting
tsset rssd9001 quarter

// Defining a balanced set of observations across all specifications must delete observations with missing data on our main explanatory variables
foreach var of varlist totass totdep resishare creshare cshare nplratio{
	drop if `var' == .
	}

// Table 2)
global c
areg negrestat b $c i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons replace bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep
areg negrestat b $c i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)	
	
global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
areg negrestat b $c i.quarter i.FedReg if quarter>163 , absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c  i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)	

global c	
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

************************
* Table 3: Likelihood of Negative Restatement: Timing Analysis
**********************	

sum lastyr_av_ted, de
replace lastyr_av_ted = (lastyr_av_ted - `r(mean)')/`r(sd)'
label var lastyr_av_ted "Past TED Spread"

sum nextyr_av_ted, de
replace nextyr_av_ted = (nextyr_av_ted - `r(mean)')/`r(sd)'
label var nextyr_av_ted "Future TED Spread"

global c totass totdep resishare cshare creshare nplratio oreo_ratio wellcap commit_ratio
areg negrestat b c.b#c.lastyr_av_ted $c i.FedReg if quarter>163 , absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.lastyr_av_ted $c  ///
	using Table3.tex, ///
	tex nocons replace bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(High HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

areg negrestat b c.b#c.nextyr_av_ted $c i.FedReg if quarter>163 , absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.nextyr_av_ted $c  ///
	using Table3.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(High HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)
	
sum HPI_yoy_change,de
replace HPI_yoy_change = (HPI_yoy_change - `r(mean)')/`r(sd)'
	
sum HPI_pastchange,de
replace HPI_pastchange = (HPI_pastchange - `r(mean)')/`r(sd)'
 	
global c totass totdep resishare cshare creshare nplratio oreo_ratio wellcap commit_ratio
areg negrestat b c.b#c.HPI_yoy_change HPI_yoy_change  $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.HPI_yoy_change HPI_yoy_change $c  ///
	using Table3.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(Low HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)		

areg negrestat b c.b#c.HPI_pastchange HPI_pastchange $c  i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.HPI_pastchange HPI_pastchange $c  ///
	using Table3.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(Low HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)			
	
*****************************************************************
** TABLE 4: Likelihood of Call Report Amendment
*****************************************************************	

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
gen late = diffcalldate > 45 if diffcalldate!=. // This means that call date is 15 days past the last day of the quarter
areg late b $c  i.quarter i.FedReg if quarter>163 , absorb(county) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4) replace  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">15 days", Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg late b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">15 days", Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

// Results with dates call Report
replace late = diffcalldate > 75 if diffcalldate!=. // This means that call date is 45 days past the last day of the quarter
areg late b $c   i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">45 days", Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg late b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">45 days", Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

*****************************************************************
** FIGURE 1: Magnitude of Accounting Restatements
*****************************************************************		

use "$dropbox/Data/work files/sample", clear
gen restatement_qinc = (pct_negrestat*riskeqcapital)/qinc

replace restatement_qinc = restatement_qinc*100
eqprhistogram restatement_qinc if restatement_qinc<0 & qinc>0 & restatement_qinc>-200, bin(10) ///
	xlabel(-200(25)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Quarterly Earnings", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Quarterly Earnings", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(5.5 -200 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_earnings, replace)
	graph export eqprhist_restatement_earnings.pdf, replace

replace pct_negrestat = pct_negrestat*100
eqprhistogram pct_negrestat if pct_negrestat<0 & pct_negrestat>-1, bin(10) ///
	xlabel(-1(.125)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Risk-Weighted Assets", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Risk-Weighted Assets (in percentage points)", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(12 -1 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_rwassets, replace)
	graph export eqprhist_restatement_rwassets.pdf, replace

gen restatement_allowance = ((pct_negrestat*riskeqcapital)/ALLL)
eqprhistogram restatement_allowance if pct_negrestat<0 & restatement_allowance>-100, bin(10) ///
	xlabel(-100(25)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Allowance for Loan Losses", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Allowance for Loan Losses", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(.15 -98 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_allowance, replace)
	graph export eqprhist_restatement_allowance.pdf, replace

*****************************************************************
** FIGURE 2: Percentage of Negative and Positive Restatements over Time
*****************************************************************		

use "$dropbox/Data/work files/sample",clear
tostring rssd9999, replace force
gen year = substr(rssd9999, 1, 4)
destring year, replace force
collapse negrestat posrestat, by(year)
drop if year<2001
tsset year
replace negrestat = negrestat*100
replace posrestat = posrestat*100
twoway ///
		(tsline negrestat posrestat, lpattern(dash))  ///
, title("Percentage of Banks with Regulatory Accounting Restatements", size(small)) xlabel(2001(2)2010, val labsize(small)) ylab(0 "0%" 2 "2%"  4 "4%" 6 "6%" 8 "8%" 10 "10%" 12 "12%", labsize(vsmall)) ///
xtitle("Year", size(small)) ytitle("% Restatements", size(small)) graphregion(color(white)) bgcolor(white) note("") legend(lab(1 "% Negative Restatements") lab(2 "% Positive Restatements") size(small)) saving(tseries, replace)
graph export tseries.pdf, replace

*****************************************************************
** FIGURE 3: Regulatory Accounting Restatements and Regulatory Leniency
*****************************************************************		

use "$dropbox/Data/work files/sample",clear

preserve
collapse (mean) negrestat posrestat b, by(county FedReg)
drop if negrestat==.
egen two = count(county), by (county)
drop if two!=2
drop two

egen fedmeanrestatv1 = max(negrestat) if FedReg==1, by(county)
egen fedmeanrestat = max(fedmeanrestatv1), by(county)
egen fedposmeanrestatv1 = max(posrestat) if FedReg==1, by(county)
egen fedposmeanrestat = max(fedposmeanrestatv1), by(county)


fastxtile btiles = b if FedReg==0, nquantiles(5)
label var btiles "Index Bins"

	
collapse (mean) negrestat fedmeanrestat posrestat fedposmeanrestat (sem) semnegrestat = negrestat semposrestat = posrestat semfednegrestat = fedmeanrestat semfedposrestat = fedposmeanrestat, by(btiles FedReg)
gen ubnegrestat = negrestat + 1.65*semnegrestat
gen lbnegrestat = negrestat - 1.65*semnegrestat
gen ubposrestat = posrestat + 1.65*semposrestat
gen lbposrestat = posrestat - 1.65*semposrestat
gen ubfednegrestat = fedmeanrestat + 1.65*semfednegrestat
gen lbfednegrestat = fedmeanrestat - 1.65*semfednegrestat
gen ubfedposrestat = fedposmeanrestat + 1.65*semfedposrestat
gen lbfedposrestat = fedposmeanrestat - 1.65*semfedposrestat

drop in 6/7

twoway ///
	(connected negrestat btiles if FedReg==0, lpattern(solid)) ///
	(rcap ubnegrestat lbnegrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))		legend(off)				///
	title("Percentage of Income-Decreasing Restatements by Leniency Index Quintile (State Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))										///
	ytitle("% Income-Decreasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.02(0.005).05, labsize(vsmall))	///
	saving(leniencybins, replace)
	graph export leniencybins.pdf, replace

twoway ///
	(connected posrestat  btiles if FedReg==0, lpattern(solid))										///
	(rcap ubposrestat lbposrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))			legend(off)				///
	title("Percentage of Income-Increasing Restatements by Regulatory Leniency Quintile (State Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))												///
	ytitle("% Income-Increasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.005(0.005).04, labsize(vsmall))	///
	saving(posleniencybins, replace)
	graph export posleniencybins.pdf, replace
	
twoway ///
	(connected fedmeanrestat btiles if FedReg==0, lpattern(solid))										///
	(rcap ubfednegrestat lbfednegrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))	legend(off)					///
	title("Percentage of Income-Decreasing Restatements by Regulatory Leniency Quintile (National Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))										///
	ytitle("% Income-Decreasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.01(0.005).045, labsize(vsmall))	///
	saving(fednegleniencybins, replace)
	graph export fednegleniencybins.pdf, replace

twoway ///
	(connected fedposmeanrestat btiles if FedReg==0, lpattern(solid))										///
	(rcap ubfedposrestat lbfedposrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))		legend(off)					///
	title("Percentage of Income-Increasing Restatements by Regulatory Leniency Quintile (National Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(vsmall))										///
	ytitle("% Income-Increasing Restatements", size(vsmall)) graphregion(color(white)) bgcolor(white) ylab(0(0.005).035, labsize(small))	///
	saving(fedposleniencybins, replace)
	graph export fedposleniencybins.pdf, replace
restore

*****************************************************************
** FIGURE 4: Regulatory Leniency and the Likelihood of Restatements by Quarter
*****************************************************************

use "$dropbox/Data/work files/sample",clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio 


areg negrestat c.b#i.quarter $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(thin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas, replace)
	graph export betas.pdf, replace

*****************************************************************
** FIGURE 5: Regulatory Leniency and the Likelihood of Restatements by Quarter: Heterogeneity across CRE Lending Specialization
*****************************************************************
	
use "$dropbox/Data/work files/sample",clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

preserve
sum creshare if quarter>163, de
tempvar hi_cre
gen `hi_cre' = creshare>`r(p50)' if creshare!=.

areg negrestat c.b#i.quarter $c i.FedReg if quarter>163 & `hi_cre'==1 , absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(vvthin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	title("High CRE Concentration Banks", size(small))								///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas_highcre, replace)
	graph export betas_highcre.pdf, replace
restore

preserve
sum creshare if quarter>163, de
tempvar hi_cre
gen `hi_cre' = creshare>`r(p50)' if creshare!=.


areg negrestat c.b#i.quarter $c i.FedReg if quarter>163 & `hi_cre'==0 , absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(vvthin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	title("Low CRE Concentration Banks", size(small))								///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent 1.96 +/- St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas_lowcre, replace)
	graph export betas_lowcre.pdf, replace
restore
	
*****************************************************************
** FIGURE 6: Regulatory Leniency and the Timeliness of Loan Loss Provisions during the Financial Crisis
*****************************************************************			

// This is going to be the Merging File
use "$dropbox/Data/cleaned files/regmaster", clear

// Merging the Financial Characteristics Variables
merge 1:1 rssd9001 quarter using "$dropbox/Data/cleaned files/char"
drop _merge
egen rssd92001 = mode(rssd9200), by(rssd9001)
replace rssd9200 = rssd92001 if rssd9200==""
drop rssd92001

egen rssd92001 = mode(reg_state), by(rssd9001)
replace reg_state = rssd92001 if reg_state==.
drop rssd92001

egen fr = mode(FedReg), by(rssd9001)
replace FedReg = fr if FedReg==. 
drop fr

egen cnty = mode(county), by(rssd9001)
replace county = cnty if county==.
drop cnty
drop cnty_qt
egen cnty_qt = group(county quarter)
 
//Merging the Bank Regulatory Index
merge m:1 rssd9200 using "$dropbox/Data/cleaned files/alst_cross_states"
replace b = 0 if FedReg==1 & b!=.
drop _merge


tsset rssd9001 quarter
gen prov_ratio = prov_qrt/tot_loans
gen coratio =  CO_qrt/tot_loans
gen ALLLratio = riad3123/tot_loans

winsor2 prov_ratio coratio ALLLratio, replace cuts(2.5 97.5) trim

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

global c totass totdep resishare creshare oreo_ratio commit_ratio cshare wellcap

// 4 Leads and 4 Lags

preserve
areg prov_ratio c.b#i.quarter f1.coratio f2.coratio f3.coratio coratio l.coratio l2.coratio l3.coratio l4.coratio $c i.FedReg  if quarter>163, absorb(cnty_qt) vce(cl reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..46]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..46]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.645
gen uu = A + sterror*1.645

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)46{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq
twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(thin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)209, labsize(vsmall) angle(60)) ylab(-0.005(0.0025).005, nogrid labsize(small)) ///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	ttext( -.004 166 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall))  ///
	saving(betas_prov, replace)
	graph export betas_prov.pdf, replace
restore
log close
***************************************************************************************************************************************************************
**********                                                                    																    	 **********
**********        ARTICLE: Do Strict Regulators Increase the Transparency of the Banking System?							                     	 **********
**********        AUTHOR:  Anna M. Costello, João Granja, and Joseph P. Weber                   													 **********
**********        JOURNAL OF ACCOUNTING RESEARCH                               																		 **********
**********                                                         																	             	 **********
**********                                    		                	        														       		 **********
**********        TABLE OF CONTENTS:                                            																     **********
**********        -- A: Formation of the Datasets used in the Analysis																                 **********
**********        -- B: Merging the Datasets                    																               	     **********
**********        -- C: Regressions and Figures - Published Paper              																         **********
**********                                                          															         	       	 **********
**********                                                                        																	 **********
**********        README / DESCRIPTION:                                       																	     **********
**********        This STATA do-file converts the raw data into our final     																	     **********
**********        dataset and performs the main statistical analyses. The code         																 **********
**********        uses multiple datasets as inputs and yields the content         																	 **********
**********        of the main analysis as output. 			        																				 **********
**********                                                                         																	 **********
***************************************************************************************************************************************************************

*****************************************************************************************
*****************************************************************************************
******************************  A: SAMPLE FORMATION   ***********************************
*****************************************************************************************
*****************************************************************************************

log using final_log, replace

clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements/Data"
cd "$dropbox/Source Data"

*********************************************************************************************
* Step A.0 -- Pulling Relevant Variables from Call Report Data downloaded from WRDS: (2000:Q1-2010:Q4) and defining relevant variables with financial characteristics
*********************************************************************************************

// A.0.1 - Pull ID, Geographic, and Regulatory Information
use RSSD, clear
keep rssd9001 rssd9007 rssd9010 rssd9050 rssd9056 rssd9130 rssd9150 rssd9180 rssd9200 rssd9220 rssd9220 rssd9210 rssd9220 rssd9331 rssd9348 rssd9364 rssd9421 rssd9422 rssd9950 rssd9999

tostring rssd9999, replace force
gen q = substr(rssd9999,5,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr(rssd9999,1,4)
destring q y rssd9999, replace force
gen quarter = yq(y,q)
drop y q 

gen FedReg = rssd9421==1
gen county = 1000*rssd9210 + rssd9150

save "$dropbox/cleaned files/regmaster", replace

// A.0.2 - Pull Income Statement Information (RIAD Schedules)

use "RIAD", clear
tostring rssd9999, replace force
gen q = substr(rssd9999,5,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr(rssd9999,1,4)
destring q y rssd9999, replace force
gen quarter = yq(y,q)
drop y q 

keep rssd9001 quarter rssd9200 riad4340 riada517 riad4174 riad4230 riad4508 riad0093 riad4509 riadc233 riad4511 riada518 riad4512 riad4107 riadb522 riad4605 riadc079 riad3123 riad5523 ///
riad4079 riad4065 riad4070 riad4080 riada220 riadc886 riadc887 riadc888 riadc386 riadc387 riad4079 riadb491 riadb492 riadb493 riad4415 riadb507 riad4635 riad4302 riad3210 riada517 riadf556 ///
riad3123
tempfile RI
save "`RI'"

// A.0.3 - Pull Balance Sheet Information (RCON and RCFD Schedules)

use "RCON0.dta", clear
keep rssd9001 quarter rcon0010 rcon0352 rcon0426
tempfile RCON0
save "`RCON0'"

use "RCFD0.dta", clear
keep rssd9001 quarter rcfd0010 rcfd0426
tempfile RCFD0
save "`RCFD0'"

use "RCON1.dta", clear
keep rssd9001 quarter rcon1350 rcon1400 rcon1403 rcon1406 rcon1407 rcon1410 rcon1415 rcon1460 rcon1480 rcon1754 rcon1763 rcon1764 rcon1766 rcon1773 rcon1797
tempfile RCON1
save "`RCON1'"

use "RCFD1.dta", clear
keep rssd9001 quarter rcfd1350 rcfd1400 rcfd1403 rcfd1406 rcfd1407 rcfd1410 rcfd1415 rcfd1460 rcfd1480 rcfd1754 rcfd1763 rcfd1764 rcfd1766 rcfd1773 rcfd1797
tempfile RCFD1
save "`RCFD1'"

use "RCON2.dta", clear
keep rssd9001 quarter rcon2008 rcon2011 rcon2122 rcon2170 rcon2200 rcon2215 rcon2702 rcon2365 rcon2604 rcon2746 rcon2800 rcon2150
tempfile RCON2
save "`RCON2'"

use "RCFD2.dta", clear
keep rssd9001 quarter rcfd2008 rcfd2011 rcfd2122 rcfd2170 rcfd2200 rcfd2746 rcfd2800 rcfd2150
tempfile RCFD2
save "`RCFD2'"

use "RCON3.dta", clear
keep rssd9001 quarter rcon3190 rcon3200 rcon3210 rcon3230 rcon3163 rcon3345 rcon3485 rcon3486 rcon3487 rcon3469 rcon3411 rcon3814 rcon3816 rcon3817 rcon3818 rcon3819 rcon3821 rcon3838 rcon3839 rcon3123 rcon3632
tempfile RCON3
save "`RCON3'"

use "RCFD3.dta", clear
keep rssd9001 quarter rcfd3190 rcfd3200 rcfd3210 rcfd3230 rcfd3163 rcfd3345 rcfd3411 rcfd3814 rcfd3816 rcfd3817 rcfd3818 rcfd3819 rcfd3821 rcfd3838 rcfd3123 rcfd3839 rcfd3632
tempfile RCFD3
save "`RCFD3'"

use "RCON5.dta", clear
keep rssd9001 quarter rcon5367 rcon5368
tempfile RCON5
save "`RCON5'"

use "RCON6.dta", clear
keep rssd9001 quarter rcon6550 rcon6810 rcon6648 rcon6164 rcon6165 rcon6724
tempfile RCON6
save "`RCON6'"

use "RCFD6.dta", clear
keep rssd9001 quarter rcfd6550 rcfd6165 rcfd6164 rcfd6724
tempfile RCFD6
save "`RCFD6'"

use "RCON7.dta", clear
keep rssd9001 quarter rcon7204 rcon7205 rcon7206
tempfile RCON7
save "`RCON7'"

use "RCFD7.dta", clear
keep rssd9001 quarter rcfd7204 rcfd7205 rcfd7206
tempfile RCFD7
save "`RCFD7'"

use "RCON8.dta", clear
keep rssd9001 quarter rcon8500 rcon8504 rcon8503 rcon8507 rcon8274
tempfile RCON8
save "`RCON8'"

use "RCFD8.dta", clear
keep rssd9001 quarter rcfd8500 rcfd8504 rcfd8503 rcfd8507 rcfd8274 
tempfile RCFD8
save "`RCFD8'"

use "RCONA.dta", clear
keep rssd9001 quarter rcona514 rcona529 rcona584 rcona585 rcona223 rcona224
tempfile RCONA
save "`RCONA'"

use "RCFDA.dta", clear
keep rssd9001 quarter rcfda223 rcfda224 
tempfile RCONA
save "`RCONA'"

use "RCONB.dta", clear
keep rssd9001 quarter rconb563 rconb987 rconb989 rconb993 rconb995 rconb538 rconb539 
tempfile RCONB
save "`RCONB'"

use "RCFDB.dta", clear
keep rssd9001 quarter rcfdb987 rcfdb989 rcfdb993 rcfdb995 rcfdb538 rcfdb539 
tempfile RCFDB
save "`RCFDB'"

use "RCONC.dta", clear
keep rssd9001 quarter rconc026 rconc027 
tempfile RCONC
save "`RCONC'"

use "RCFDC.dta", clear
keep rssd9001 quarter rcfdc026 rcfdc027 rcfdc410 rcfdc411
tempfile RCFDC
save "`RCFDC'"

use "RCONF.dta", clear
keep rssd9001 quarter rconf049 rconf045 rconf070 rconf071 rconf158 rconf159 rconf160 rconf161 rconf164 rconf165
tempfile RCONF
save "`RCONF'"

use "RCFDF.dta", clear
keep rssd9001 quarter rcfdf070 rcfdf071 rcfdf164 rcfdf165
tempfile RCFDF
save "`RCFDF'"

use "RCONG.dta", clear
keep rssd9001 quarter rcong167 rcong300 rcong304 rcong308 rcong312 rcong316 rcong320 rcong324 rcong328 rcong315 rcong319 rcong323 rcong327 rcong331 ///
rcong336 rcong340 rcong344 rcong303 rcong307 rcong311 rcong339 rcong343 rcong347 rconj473 rconj474 rconj457 rconj458 rconj459
tempfile RCONG
save "`RCONG'"

use "RCFDG.dta", clear
keep rssd9001 quarter rcfdg300 rcfdg304 rcfdg308 rcfdg312 rcfdg316 rcfdg320 rcfdg324 rcfdg328 rcfdg315 rcfdg319 rcfdg323 rcfdg327 rcfdg331 ///
rcfdg336 rcfdg340 rcfdg344 rcfdg303 rcfdg307 rcfdg311 rcfdg339 rcfdg343 rcfdg347 rcfdj457 rcfdj458 rcfdj459
tempfile RCFDG
save "`RCFDG'"

use "$dropbox/cleaned files/regmaster", clear
local c RI RCON0 RCON1 RCON2 RCON3 RCON5 RCON6 RCON7 RCON8 RCONA RCONB RCONF RCONG RCFD0 RCFD1 RCFD2 RCFD3 RCFD6 RCFD7 RCFD8 RCFDB RCFDC RCFDF RCFDG
foreach x of local c{
	merge 1:1 rssd9001 quarter using "``x''"
	drop _merge
	
}
keep if quarter<200

tempfile var1994_2010
save `var1994_2010'

// A.0.4 - Pulling in 2010:Q1 - 2012:Q4 (This set of files was downloaded from FFIEC rather than WRDS)
local d RCA RCCI RCCII RCD RCE RCEI RCEII RCF RCG RCH RCI RCK RCN RCN_1 RCN_2 RCM RCO RCP RCS RI_2 RIA RIBI RIBII RID RIE RCB_1 RCL_1 RCQ_1 RCR_1 RCT_1 RCB_2 RCL_2 RCQ_2 RCR_2 RCT_2
use RC, clear

foreach t of local d{
 merge 1:1 rssd9001 quarter using `t', update
 drop _merge
}
*************************************

gen year =  substr(quarter,5,4)
gen q = substr(quarter,1,2)
gen d = substr(quarter,3,2)
gen rssd9999 = year + q + d
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
destring year q rssd9999, replace force
gen qrt = yq(year,q)
drop quarter
rename qrt quarter

// Defining what variables to keep
keep rssd9001 rssd9999 quarter riada517 riad4415 riad4508 riad0093 riada518 riad4340 rcon0010 rcon0352 rcon3230 rcon3163 rcfd3230 rcfd3163 rcon1227 rcon1228 rcon1420 rcon1460 rcon1545 rcon1590 rcon1607 rcon1608 rcon1754 rcon1763 rcon1764 rcon1766 rcon1773 rcon1797 rcon2011 rcon2081 rcon2107 rcon2122 rcon2165 ///
rcon2170 rcon2200 rcon2215 rcon2365 rcon2746 rcon3190 rcon3200 rcon3210 rcon3411 rcon3485 rcon3494 rcon3495 rcon3500 rcon3501 rcon3814 rcon3817 rcon3838 rcon5367 rcon5368 rcon5390 rcon5391 rcon5399 rcon5400 rcon5460 ///
rcon5461 rcon6550 rcon6810 rcon6648 rcon7204 rcon7205 rcon7206 rcona514 rcona529 rcona584 rcona585 rconb531 rconb534 rconb535 rconb538 rconb539 rconb563 rconb987 rconb989 rconb993 rconb995 rconb538 rconb539 rconb576 rconb577 rconb579 rconb580 rconb835 rconb836 ///
rconc026 rconc027 rconc229 rconc230 rconc237 rconc239 rconf049 rconf045 rconf070 rcon7273 rcon7274 rcon7275 rcfnb574 rcon0426 rcfd0426  ///
rconf158 rconf159 rconf160 rconf161 rconf164 rconf165 rconf174 rconf175 rconf176 rconf177 rconf180 rconf181 rconf182 rconf183 rcong167 rcong300 rcong304 rcong308 rcong312 rcong316 rcong320 rcong324 rcong328 rcong336 rcong340 rcong344 rcong303 rcong307 rcong311 rcong315 ///
rcong319 rcong323 rcong327 rcong331 rcong339 rcong343 rcong347 rconj451 rconj453 rconj454 rconj457 rconj458 rconj459 rconj473 rconj474 rconk137 rconk142 rconk145 rconk146 rconk149 rconk150 rconk153 rconk154 rconk157 rconk207 ///
rcfd0010 rcfd1410 rcfd1754 rcfd1763 rcfd1764 rcfd1773 rcfd2011 rcfd2122 rcfd2170 rcfd2746 rcfd3190 rcfd3200 rcfd3210 rcfd3411 rcfd3814 rcfd3817 rcfd3838 rcfd3839 rcon3839 ///
rcfd6550 rcfd7204 rcfd7205 rcfd7206 rcfdb989 rcfdb995 rcfdb538 rcfdb539 rcfdc026 rcfdc027 rcfdf164 rcfdf165 rcfdg300 rcfdg304 rcfdg308 rcfdg312 rcfdg316 rcfdg320 rcfdg324 rcfdg328 rcfdg315 rcfdg319 rcfdg323 rcfdg327 rcfdg331 ///
rcfdg336 rcfdg340 rcfdg344 rcfdg303 rcfdg307 rcfdg311 rcfdg339 rcfdg343 rcfdg347 rcfdk137 rcfdk207 rcfdb534 rcfdb532 rcfdb533 rcfdb536 rcfdb537 rcfd1590 rcfdb538 rcfdb539 rcfd1763 rcfd1764 rcfd2011 ///
rcfd2081 rcfd2107 rcfd1563 rcfdf162 rcfdf163 rcfdj457 rcfdj458 rcfdj459 rcon1583 rcon1256 rcon2150 rcfd2150 rcon3632 rcfd3632 ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 rcfd1256 rcfdb577 rcfdk215 rcfdk218 ///
rcfd5461 rcfdf168 rcfdf171 rcfd3507 rcfdk038 rcfdk041 rcfdk044 rconk047 rconk050 rconk053 rconk056 rconk059 rconk062 rconk065 rconk068 rconk071 ///
rcfdk074 rcfdk077 rcfdk080 rcfdk083 rcfdk086 rcfdk089 rcfdk093 rcfdk097 rcfdk101 rcfdk272 rcfnk293 rcfdk104 rcon3123 rcfd3123 ///
rcon5382 rcon1583 rcon1256 rconb577 rconk215 rconk218 rcon5391 rcon5461 rconf168 rcon3507 rconk038 rconk041 rconk044 rconk074 rconk077 rconk080 rconk083 rconk086 rconk089 rconk093 rconk097 rconk101 rconk272 rconk104 /// 
rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 rcfd1255 rcfdb576 rcfdk214 rcfdk217 rcfd5390 rcfd5460 rcfdf167 rcfdf170 rcfd3506 ///
rcfdk037 rcfdk040 rcfdk043 rconk046 rconk049 rconk052 rconk055 rconk058 rconk061 rconk064 rconk067 rconk070 rcon8274 rcfd8274 ///
rcfdk073 rcfdk076 rcfdk079 rcfdk082 rcfdk085 rcfdk088 rcfdk092 rcfdk096 rcfdk100 rcfdk271 rcfnk292 rcfdk103 riad4230 rcona223 rcona224 ///
rcon5381 rcon1597 rcon1255 rconb576 rconk214 rconk217 rcon5390 rcon5460 rconf167 rcon3506 rconk037 rconk040 rconk043 rconk046 rconk049 rconk052 rconk055 rconk058 rconk061 rconk064 rconk067 rconk070 ///
rconk073 rconk076 rconk079 rconk082 rconk085 rconk088 rconk092 rconk096 rconk100 rconk271 rcfnk292 rconk103 rcfd3819 rcfd3821 rcon3819 rcon3821 ///
rcfdb579 rcfd5390 rcfd5460 rcfdf167 rcfdf170 rcfd3506 rcfd5613 rcfd5616 rcfdc867 rconb579 rcon5613 rcon5616 rconc867 ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcon5382 rcon1583 rcfd1253 rcfdj457 rcfdj458 rcfdj459 rconj457 rconj458 rconj459 ///
rcon1256 rconb577 rconb580 rcon5391 rcon5461 rcfdf168 rcfdf171 rcon3507 rcon5614 rcon5617 rcfdc868 riadb491 riadb492 riadb493 riadf556  ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 rcfd6724 rcon6724 ///
rcfd1256 rcfdb577 rcfdb580 rcfd5391 rcfd5461 rcfdf168 rcfdf171 rcfd3507 rcfd5614 rcfd5617 rcfdc868 riad4070 riad4080 riada220 riadc886 riadc887 riadc888 riadc386 riadc387 riad4079 riad4079 riad4065 riad4107 rconf172 rconf173 rcon3493 rcon5398 rconc236 rconc238 rcon3499 rconf178 ///
rconf179 rcfnb572 rcfd5377 rcfd5380 rcfd1594 rcfd1251 rcfd1254 rcfdb575 rcfdb578 rconb578 rcfd5389 rcfd5459 rcfdf166 rconf166 rcfdf169 rcfdk213 rcfdk216 rcfd6165 rcfd6164 rcon6165 rcon6164 rcon1254 rconb575 rconk213 rconk216 rcon5389 rcon5459 rcon1594 rcon5380 riadb507 rcfda223 riad4635 riad4605 riad4302 riad3210 riad3123

tempfile var2010_2013
save `var2010_2013'

use "$dropbox/cleaned files/regmaster", clear
merge 1:1 rssd9001 quarter using `var2010_2013'
keep if quarter>199
drop _merge

save `var2010_2013', replace
use `var1994_2010', clear
append using `var2010_2013'


// A.0.5 - Creating Financial Ratios and other variables to use in the main empirical analysis

tsset rssd9001 quarter
tostring rssd9999, replace force

// Defining the Restatement Variables
gen restat = riadb507 !=0 if riadb507!=.
gen negrestat = riadb507 <0 if riadb507!=.
gen posrestat = riadb507 > 0 if riadb507!=.

// Restatement Amount as a fraction of total risk-weighted assets
gen riskeqcapital = rcfda223
replace riskeqcapital = rcona223 if quarter>=200
gen pct_negrestat = riadb507/riskeqcapital if riadb507 <=0 & riadb507!=.

// Fixed-Effect Groups
egen state = group(rssd9200)
egen reg_state = group(rssd9200 FedReg)
egen cnty_qt  = group(county quarter)

* Creating Size Variable (Total Assets)
gen totass = rcfd2170
replace totass = rcon2170 if rcfd2170==.
label var totass "Total Assets (Current Prices)"

gen totdep = rcfd2200
replace totdep = rcon2200 if totdep==.
label var totdep "Total Deposits (Current Prices)"

gen tot_loans = rcfd2122
replace tot_loans = rcon2122 if tot_loans==.
label var tot_loans "Total Loans (Current Prices)"

// Portfolio Composition Variables: Share of Residential, CRE, and Consumer Loans

* Residential 1-4 Family Loans
gen residential = rcon1797 + rcon5367 + rcon5368 // Total Loand secured by Residential Real Estate
gen resishare = residential/tot_loans

* Commercial & Real Estate Loans
gen cre_loans = rcon1415 + rcon1460 + rcon1480 + rcfd2746 // Total Loans secured by CRE
replace cre_loans = rconf158 + rconf159 + rcon1460 + rconf160 + rconf161 + rcfd2746 if cre_loans==. 
replace cre_loans = rconf158 + rconf159 + rcon1460 + rconf160 + rconf161 + rcon2746 if cre_loans==.
gen creshare = cre_loans/tot_loans

// Consumer Loans Share
gen cons_loans = rcfdb538 + rcfdb539 + rcfd2011 if quarter<200 // Total Individual loans
replace cons_loans = rcfdb538 + rcfdb539 + rcfd2011 if quarter>=200 
replace cons_loans = rconb538 + rconb539 + rcon2011 if quarter>=200 & cons_loans==.
replace cons_loans = rcfdb538 + rcfdb539 + rcfdk137 + rcfdk207 if quarter>=204 & cons_loans==.
replace cons_loans = rconb538 + rconb539 + rconk137 + rconk207 if quarter>=204 & cons_loans==.
gen cshare = cons_loans/tot_loans


// Asset Quality Ratios: Delinquent Loan Ratio (NPL ratio) and OREO Ratio (Foreclosed Property Ratio)

// NPL Ratio
gen npl1403 = rcfd1403 if quarter<200
egen npl1403v1 = rowtotal (rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 ///
rcfd1256 rcfdb577 rcfdb580 rcfd5391 rcfd5461 rcfdf168 rcfdf171) if quarter>=200 & quarter<204 & rcfd5391!=.
egen npl1403v2 = rowtotal (rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcon5382 rcon1583 rcfd1253 ///
rcon1256 rconb577 rconb580 rcon5391 rcon5461 rconf168 rcfdf171) if quarter>=200 & quarter<204
replace npl1403 = npl1403v1 if npl1403==.
replace npl1403 = npl1403v2 if npl1403==.

gen npl1407 = rcfd1407
egen npl1407v1 = rowtotal(rconf174 rconf175 rcon3494 rcon5399 rconc237 rconc239 rcon3500 rconf180 rconf181 rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 ///
rcfd1255 rcfdb576 rcfdb579 rcfd5390 rcfd5460 rcfdf167 rcfdf170) if quarter>=200 & quarter<204 & rcfd5381!=.
egen npl1407v2 = rowtotal(rconf174 rconf175 rcon3494 rcon5399 rconc237 rconc239 rcon3500 rconf180 rconf181 rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 ///
rcfd1255 rcfdb576 rconb579 rcfd5390 rcfd5460 rconf167 rcfdf170) if quarter>=200 & quarter<204
replace npl1407 = npl1407v1 if npl1407==.
replace npl1407 = npl1407v2 if npl1407==.

gen npl_loans = (npl1407 + npl1403) // This is total non-performing loans
gen nplratio = (npl1407 + npl1403)/tot_loans
label var nplratio "Nonperforming Loans (+90 PD + Nonacc)/Total Loans"
drop npl1403v1 npl1403v2 npl1407v1 npl1407v2

// Other Real Estate Owned Ratio

gen oreo_ratio = rcfd2150/rcfd2170
replace oreo_ratio = rcon2150/rcon2170 if oreo_ratio==.


// Liquidity and Solvency Ratios
******
* Liquidity Ratio is the Unused Commmitment Ratio (Following Acharya and Mora, 2015 JF)

* Total Commitments
egen commitments = rowtotal(rcfd3814 rcfd3816 rcfd3817 rcfd3818 rcfd6550 rcfd3411) if quarter<200
egen commitments1 = rowtotal(rcfd3814 rcfdf164 rcfdf165 rcfd3817 rcfdj457 rcfdj458 rcfdj459 rcfd6550 rcfd3411) if quarter>=200 & rcfd3814!=.
egen commitments2 = rowtotal(rcon3814 rconf164 rconf165 rcon3817 rconj457 rconj458 rconj459 rcon6550 rcon3411) if quarter>=200
replace commitments = commitments1 if commitments==.
replace commitments = commitments2 if commitments==.

* Unused Commitments ratio
gen commit_ratio = commitments/(tot_loans+commitments)
label var commit_ratio "Unused Commitments as % Gross Loans + Unused Commitments"
drop commitments1 commitments2

// Tier 1 Capital Ratio
replace rcon7204 = rcon7204*100 if quarter<195 |quarter>=200
gen tier1ratio = rcon7204
gen wellcap = tier1ratio>5

******************************
// Income and Loan Loss Numbers
************************************

// Quarterly Income
gen qinc = riad4340-l.riad4340
replace qinc = riad4340 if substr(rssd9999, 5, 2)=="03"

// Charge-Offs by Quarter
gen CO_qrt = (riad4635-riad4605) if substr(rssd9999, 5, 2)=="03"
replace CO_qrt = (riad4635-riad4605) - (l.riad4635-l.riad4605) if substr(rssd9999, 5, 2)!="03"

// Quarterly Provisions
gen prov_qrt = riad4230 if substr(rssd9999, 5, 2)=="03"
replace prov_qrt = riad4230 - l.riad4230 if substr(rssd9999, 5, 2)!="03"

// Allowance for Loan and Lease Losses (ALLL)
gen ALLL = riad3123

keep rssd9001 quarter riad3123 restat-ALLL
save "$dropbox/cleaned files/char",replace

*********************************************************************************************
* Step A.1 -- Pulling and cleaning TED Spread Data
*********************************************************************************************

import delimited "TEDRATE.csv", clear
rename tedrate av_ted

tostring date, replace force
gen q = substr(date,6,2)
replace q = "1" if q=="01"
replace q = "2" if q=="04"
replace q = "3" if q=="07"
replace q = "4" if q=="10"
gen y = substr(date,1,4)
destring q y date, replace force
gen quarter = yq(y,q)
drop y q date

tsset quarter
gen nextyr_av_ted = f4.av_ted
gen lastyr_av_ted = l4.av_ted

save "$dropbox/cleaned files/TED", replace

*********************************************************************************************
* Step A.2 -- Creating Bank-Specific House Price Indices
*********************************************************************************************

// A.2.1 --> Pulling and Cleaning House Price Data obtained from FFIEC website

// 1) Metropolitan Areas House Price Indices
import delimited "3q13hpi_cbsa.csv", clear
drop v6

rename v1 msaname
rename v2 msabr
rename v3 year
rename v4 q
rename v5 HPI

gen divisionb = msabr

destring HPI, replace force
gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if  msaname[`i'+4]==msaname[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  msaname[`i']==msaname[`i'-4]
}


gen quarter = yq(year,q)
drop year q HPI

tempfile MSA_HPI
save `MSA_HPI', replace

// 2) House Price Indices of the NonMetropolitan Areas of each State
import excel "indexes_nonmetro_thru_13q3.xls", sheet("hpi_stsbal") clear
drop in 1/3
rename A stalpbr
rename B year
rename C q
rename D HPI
drop E

destring  year q HPI, replace force

gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if stalpbr[`i'+4]==stalpbr[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  stalpbr[`i']==stalpbr[`i'-4]
}

gen quarter = yq(year,q)
drop year q HPI

tempfile nonMSA_HPI
save `nonMSA_HPI'

// 3) Puerto Rico
import excel "PR_Downloadable_alltransactions.xls", sheet("Puerto Rico--All Transactions") clear
drop in 1/6
drop A
gen stalpbr = "PR"
rename B year
rename C q
rename D HPI

destring  year q HPI, replace force

gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if stalpbr[`i'+4]==stalpbr[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  stalpbr[`i']==stalpbr[`i'-4]
		}

gen quarter = yq(year,q)
drop year q HPI
duplicates drop stalpbr quarter, force

append using `nonMSA_HPI'
save `nonMSA_HPI', replace

// A.2.2 -->  Merge HPI indices with SOD data: Computing Bank-Specific House Price Change Index that weights House Price Changes based on share of deposits of the bank in each area

foreach num of numlist 1(1)4{
use "/Users/joaogranja/Dropbox (Personal)/Summary of Deposits/SOD_all.dta", clear
gen q = `num'
gen quarter = yq(year,q)
drop year q

merge m:1 msabr quarter using `MSA_HPI'
drop if _merge==2
drop _merge

merge m:1 divisionb quarter using `MSA_HPI', update
drop if _merge==2
drop _merge

merge m:1 stalpbr quarter using `nonMSA_HPI', update
drop if _merge==2
drop _merge

collapse (mean) HPI_change HPI_pastchange [fw=depsumbr], by(cert quarter)
rename cert rssd9050
saveold "$dropbox/cleaned files/HPI_changeq`num'", replace
}

append using "$dropbox/cleaned files/HPI_changeq3"
append using "$dropbox/cleaned files/HPI_changeq2"
append using "$dropbox/cleaned files/HPI_changeq1"
rename HPI_change HPI_yoy_change

save "$dropbox/cleaned files/HPI_changeyoy", replace

*********************************************************************************************
* Step A.3. -- Pulling and Cleaning Textual Description of the Catch-Up restatements
*********************************************************************************************

//PULLING IN RI-E SCHEDULE DATA

clear all
cd "$dropbox/Source Data/FFIEC RIE Schedules for all quarters"
file open myfile using "../filelist.txt", read
file read myfile line
drop _all
import delimited "`line'", clear

keep textb526 textb527 idrssd
drop in 1 //dropping label row
save "`line'.dta", replace
gen q = substr("`line'",29,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr("`line'",33,4)
destring q y, replace force
gen quarter = yq(y,q)
drop y q
rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
save "$dropbox/cleaned files/RIE_data.dta", replace 
drop _all

file read myfile line
while r(eof)==0 {
import delimited "`line'", clear
keep textb526 textb527 idrssd
drop in 1 //dropping label row
save "`line'.dta", replace
gen q = substr("`line'",29,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr("`line'",33,4)
destring q y, replace force
gen quarter = yq(y,q)
drop y q 
rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
append using "$dropbox/cleaned files/RIE_data.dta"
duplicates drop rssd9001 quarter, force
save "$dropbox/cleaned files/RIE_data.dta", replace
drop _all
file read myfile line
}


local a 12312009 12312010 09302009 09302010 06302010 03312008 03312010 06302007 06302008 06302009 09302007 09302008 12312007 12312008
foreach b of local a{
	import delimited "FFIEC CDR Call Schedule RIE `b'.txt", clear varnames(1)
	keep textb527 idrssd
	drop in 1 //dropping label row
	gen q = substr("`b'",1,2)
	replace q = "1" if q=="03"
	replace q = "2" if q=="06"
	replace q = "3" if q=="09"
	replace q = "4" if q=="12"
	gen y = substr("`b'",5,4)
	destring q y, replace force
	gen quarter = yq(y,q)
	drop y q 
	rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
	append using "$dropbox/cleaned files/RIE_data.dta"
	save "$dropbox/cleaned files/RIE_data.dta", replace
clear all
}


cd ..

use "$dropbox/cleaned files/RIE_data.dta", clear
gen text = textb526
replace text = textb527 if text==""
replace text = proper(text)
drop textb526 textb527

// Mathematical or Rounding Error Categories
gen error =  regexm(text,"((Math)+)") | regexm(text,"((Round)+)") 

// Adjustment related to change in Accounting Principle
gen principle =  regexm(text,"(Fas)") | regexm(text,"((Eitf)+)") | regexm(text,"((Sab)+)") | regexm(text,"((Fin48)+)") | regexm(text,"((fas)+)") | regexm(text,"((Fin 48)+)")  | regexm(text,"((Principle)+)") | regexm(text,"((Split)+)") ///
| regexm(text,"((Eift)+)") | regexm(text,"((Life Insurance)+)") | regexm(text,"((Retirement)+)") | regexm(text,"((Boli)+)") | regexm(text,"((principal)+)") 

// Adjustments that are related to Audits
gen audit =  regexm(text,"((Audit)+)")

// Adjustments that are related to Taxes
gen tax =  regexm(text,"((Tax)+)") | regexm(text,"((tax)+)") | regexm(text,"((Irs)+)")

// Adjustments in Loan Loss Accounting
gen loanloss =  regexm(text,"((Loan Loss)+)") | regexm(text,"((Loss Reserve)+)") | regexm(text,"((Llr)+)") | regexm(text,"((Alll)+)") | regexm(text,"((Allowance)+)") // Loan Loss Accounting

// Adjustment related to the misclassification or mismeasurement of the portfolio of securities and Investments
gen secport = regexm(text,"((Reclassification)+)") | regexm(text,"((Htm)+)") | regexm(text,"((Afs)+)") | regexm(text,"((Unrealized Gains)+)") | regexm(text,"((Unrealized Losses)+)") | regexm(text,"((U/R)+)") | regexm(text,"((Write Down)+)") | regexm(text,"((Write-Down)+)") ///
| regexm(text,"((Wrote Down)+)") | regexm(text,"((Impairment)+)") | regexm(text,"((Oci)+)") | regexm(text,"((Other Comprehensive Income)+)") | regexm(text,"((Investment)+)") | regexm(text,"((Reo)+)") | regexm(text,"((Oreo)+)")

// Accrual Accounting Adjustment
gen noncurrent = regexm(text,"((Goodwill)+)") | regexm(text,"((Depreciation)+)") | regexm(text,"((Depr.)+)") | regexm(text,"((Amortization)+)") | regexm(text,"((Lease)+)") | regexm(text,"((Pension Plan)+)") | regexm(text,"((Mortgage Servicing)+)") // Accruals related to noncurrent assets and liabilities

// Consolidation Accounting Adjustment
gen consolidation = regexm(text,"((Consolidation)+)") | regexm(text,"((Unconsolidated)+)") | regexm(text,"((Subsidiary)+)") | regexm(text,"((Parent)+)") | regexm(text,"((Holding)+)") |  regexm(text,"((Merger)+)") | regexm(text,"((Purchase Accounting)+)") // Consolidation Acounting

// General Accounting Adjustment
gen accounting = regexm(text,"((Reserve)+)") | regexm(text,"((Loan Loss)+)") | regexm(text,"((Loss Reserve)+)") | regexm(text,"((Llr)+)") | regexm(text,"((Alll)+)") | regexm(text,"((Provision)+)") | regexm(text,"((Allowance)+)") /// Loan Loss Accounting
| regexm(text,"((Reclassification)+)") | regexm(text,"((Htm)+)") | regexm(text,"((Afs)+)") | regexm(text,"((Unrealized Gains)+)") | regexm(text,"((Unrealized Losses)+)") | regexm(text,"((U/R)+)") | regexm(text,"((Write Down)+)") | regexm(text,"((Write-Down)+)") | regexm(text,"((Wrote Down)+)") | regexm(text,"((Impairment)+)") | regexm(text,"((Oci)+)") | regexm(text,"((Other Comprehensive Income)+)") | regexm(text,"((Investment)+)") | regexm(text,"((Reo)+)") | regexm(text,"((Oreo)+)") /// Misclassification of Gains and Losses on Securities
| regexm(text,"((Accrual)+)") | regexm(text,"((Accr)+)") | regexm(text,"((Overaccrual)+)") | regexm(text,"((Accrued)+)") | regexm(text,"((Deferred)+)") | regexm(text,"((Deferral)+)") | regexm(text,"((Payable)+)") | regexm(text,"((Receivable)+)") | regexm(text,"((Adjusting Entries)+)") | regexm(text,"((Reverse entry)+)")  /// Errors in Accrual Accounting
| regexm(text,"((Goodwill)+)") | regexm(text,"((Depreciation)+)") | regexm(text,"((Depr.)+)") | regexm(text,"((Amortization)+)") | regexm(text,"((Lease)+)") | regexm(text,"((Pension Plan)+)") | regexm(text,"((Mortgage Servicing)+)") | regexm(text,"((Prepaid)+)") /// Specific misclassified Accounting accruals
| regexm(text,"((Expense)+)") | regexm(text,"((Interest)+)")  /// Misclassification of interest and expense
| regexm(text,"((Consolidation)+)") | regexm(text,"((Unconsolidated)+)") | regexm(text,"((Subsidiary)+)") | regexm(text,"((Parent)+)") | regexm(text,"((Holding)+)") |  regexm(text,"((Merger)+)") | regexm(text,"((Purchase Accounting)+)") /// Investment Acounting
| regexm(text,"((Liability Increase)+)") | regexm(text,"((Retained Earnings)+)")  | regexm(text,"((Understated)+)") | regexm(text,"((Overstated)+)") | regexm(text,"((Measurement)+)") | regexm(text,"((Unrecorded)+)") /// Issues with Measurement
| regexm(text,"((Accounting)+)") 

duplicates drop rssd9001 quarter, force
save "$dropbox/cleaned files/RIE_data_final.dta", replace

*********************************************************************************************
* Step A.4. -- Pulling the dates of the last submission of the Call Report (To compute likelihood of an ammendment to the call report)
*********************************************************************************************

local a 12312010 12312009 12312008 12312007 12312006 12312005 09302010 09302009 09302008 09302007 09302006 09302005 06302010 06302009 06302008 06302007 06302006 03312010 03312009 03312008 03312007 03312006
foreach b of local a{
import delimited  "$dropbox/Source Data/FFIEC/FFIEC CDR Call Bulk All Schedules `b'/FFIEC CDR Call Bulk POR `b'.txt", clear
gen callreportdate = "`b'"
gen monthcallreport = substr(callreportdate, 1,2)
gen daycallreport = substr(callreportdate, 3,2)
gen yearcallreport = substr(callreportdate, 5,4)
gen monthlastsubmission = substr(lastdatetimesubmissionupdatedon, 6,2)
gen daylastsubmission = substr(lastdatetimesubmissionupdatedon, 9,2)
gen yearlastsubmission = substr(lastdatetimesubmissionupdatedon, 1,4)
destring monthlastsubmission daylastsubmission yearlastsubmission monthcallreport daycallreport yearcallreport, replace force
gen lastcalldate = mdy(monthlastsubmission, daylastsubmission, yearlastsubmission)
gen calldate = mdy(monthcallreport, daycallreport, yearcallreport)
gen diffcalldate = lastcalldate-calldate

rename idrssd rssd9001

tostring yearcallreport monthcallreport , replace force
replace monthcallreport = "1" if monthcallreport=="03"
replace monthcallreport = "1" if monthcallreport=="3"
replace monthcallreport = "2" if monthcallreport=="06"
replace monthcallreport = "2" if monthcallreport=="6"
replace monthcallreport = "3" if monthcallreport=="09"
replace monthcallreport = "3" if monthcallreport=="9"
replace monthcallreport = "4" if monthcallreport=="12"
destring monthcallreport yearcallreport, replace force

gen quarter = yq(yearcallreport,monthcallreport)
keep rssd9001 quarter lastcalldate calldate diffcalldate
save  "$dropbox/Source Data/FFIEC/days`b'", replace
}
*
local a 12312009 12312008 12312007 12312006 12312005 09302010 09302009 09302008 09302007 09302006 09302005 06302010 06302009 06302008 06302007 06302006 03312010 03312009 03312008 03312007 03312006
use  "$dropbox/Source Data/FFIEC/days12312010", clear
foreach b of local a{
append using  "$dropbox/Source Data/FFIEC/days`b'"
}
duplicates drop rssd9001 quarter,force // Eliminates one duplicate observation -- Error in the data
save  "$dropbox/cleaned files/dates",replace


*******************************************************************************************************************
*******************************************************************************************************************
******************************  B: MERGING DATASETS   *************************************************************
*******************************************************************************************************************
*******************************************************************************************************************

clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements/Data"

// Start with ID, Geographic, and Regulatory Information 
use "$dropbox/cleaned files/regmaster", clear

// Merging the Financial Characteristics Variables
merge 1:1 rssd9001 quarter using "$dropbox/cleaned files/char"
drop if _merge==2
drop _merge

// Merging with the Bank Regulatory Index obtained form Amit Seru
merge m:1 rssd9200 using "$dropbox/cleaned files/alst_cross_states"
replace b = 0 if FedReg==1 & b!=.
drop _merge

// Merging the TED Spread
merge m:1 quarter using "$dropbox/cleaned files/TED"
drop if _merge==2
drop _merge

// Merging with the HPI Y-o-Y Change
merge m:1 rssd9050 quarter using "$dropbox/cleaned files/HPI_changeyoy"
drop if _merge==2
drop _merge

// Merging the Text Variables
merge m:1 rssd9001 quarter using "$dropbox/cleaned files/RIE_data_final"
drop if _merge==2
drop _merge

// Merging Last Call Report Dates

merge 1:1 rssd9001 quarter using "$dropbox/cleaned files/dates"
drop if _merge==2
drop _merge

save "$dropbox/work files/sample", replace

*******************************************************************************************************************
*******************************************************************************************************************
******************************  C: Regressions and Figures - Published Paper    ***********************************
*******************************************************************************************************************
*******************************************************************************************************************


clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements"
cd "$dropbox/Final Results"

use "$dropbox/Data/work files/sample", clear

// 1) Labeling the main variables

label var FedReg "Federal Regulator"
label var b "Regulatory Leniency Index"
label var totass "Total Assets"
label var totdep "Total Deposits"
label var resishare "Residential Loans/Total Loans"
label var creshare "CRE Loans/Total Loans"
label var cshare "Consumer Loans/Total Loans"
label var nplratio "Nonperforming Loans/Total Loans"
label var oreo_ratio "Other Real Estate Owned Ratio"
label var commit_ratio "Unused Commitment Ratio"
label var negrestat "Negative Restatement"
label var posrestat "Positive Restatement"


*****************************************************************
*****************************************************************
// Descriptive Statistics
*****************************************************************
*****************************************************************

************************
* Table 1, Panel A: Summary Statistics
**********************

// Step 1: Run main regression to guarantee that I provide descriptives of the set of observations that I use in the main regression
gen lnassets = ln(totass)
gen lndep = ln(totdep)
global d lnassets lndep resishare cshare creshare nplratio oreo_ratio commit_ratio
areg negrestat b $d i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)


// Panel A:
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist FedReg b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

************************
* Table 1, Panel B: Summary Statistics of State-Chartered Banks and Federal-Chartered Banks
**********************

// Summary Statistics of Federal-Chartered Banks

tempfile a 
save `a'

keep if FedReg==1
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives_federal, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

// Summary Statistics of State-Chartered Banks
use `a', clear

areg negrestat b $d i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
keep if FedReg==0
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives_state, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

use `a', clear
tempfile r 
save `r'
************************
* Table 1, Panel C: Summary Statistics of Restatements by Type
**********************

********************************
// Creating the Negative Restatement by Category Variables

foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	gen `var'_negrestat = `var' * negrestat
	gen `var'_pctnegrestat = `var' * pct_negrestat
}

******************************
label var error_negrestat "Error Restatement"
label var principle_negrestat "Principle Restatement"
label var tax_negrestat "Tax Restatement"
label var audit_negrestat "Audit Restatement"
label var accounting_negrestat "Accounting Restatement"
********************************

drop if text==""
foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	replace `var'_pctnegrestat = . if `var'_pctnegrestat==0
}
collapse audit_negrestat tax_negrestat accounting_negrestat loanloss_negrestat secport_negrestat noncurrent_negrestat consolidation_negrestat error_negrestat principle_negrestat audit tax accounting error principle loanloss secport noncurrent consolidation audit_pctnegrestat tax_pctnegrestat accounting_pctnegrestat error_pctnegrestat principle_pctnegrestat loanloss_pctnegrestat secport_pctnegrestat noncurrent_pctnegrestat consolidation_pctnegrestat
foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	gen `var'_share = `var'_negrestat/`var'
}

****
* Reshaping the dataset

local a error principle audit tax loanloss secport noncurrent consolidation accounting
foreach b of local a{
	preserve
	keep `b'*
		drop `b'_negrestat
		rename `b'_share share_neg
		rename `b' percent
		rename `b'_pctnegrestat pctnegrestat
		gen type = "`b'"
		tempfile `b'_temp
		save ``b'_temp'
		restore
	}
**********
use `error_temp', clear
local c principle audit tax loanloss secport noncurrent consolidation accounting
	foreach d of local c{
	append using ``d'_temp'
}

replace type  = "Error Restatements" if type=="error"
replace type  = "Principle Restatements" if type=="principle"
replace type  = "Tax Restatements" if type=="tax"
replace type  = "Audit Restatements" if type=="audit"
replace type  = "Loan Loss Accounting Restatements" if type =="loanloss"
replace type = "Securities Portfolio Restatements" if type=="secport"
replace type = "Noncurrent Items Restatements" if type=="noncurrent"
replace type = "Consolidation Accounting Restatements" if type=="consolidation"
replace type = "Other Accrual Accounting Restatements" if type=="accounting"
order type percent share_neg pctnegrestat

foreach var of varlist percent share_neg pctnegrestat{
replace `var' = `var'*100
}
mkmat percent share_neg pctnegrestat, matrix(b) rown(type)
mat colnames b= "\%_Restatements" "ShareNegativeRestatements" "AverageAmount" 
outtable using "PanelCTable2", mat(b) replace nobox center f(%12.2fc %12.2fc %12.2fc)


************************
* Table 2: Likelihood of Negative Restatement
**********************

use `r', clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

// Setting up the Panel Setting
tsset rssd9001 quarter

// Defining a balanced set of observations across all specifications must delete observations with missing data on our main explanatory variables
foreach var of varlist totass totdep resishare creshare cshare nplratio{
	drop if `var' == .
	}

// Table 2)
global c
areg negrestat b $c i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons replace bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep
areg negrestat b $c i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)	
	
global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
areg negrestat b $c i.quarter i.FedReg if quarter>163 , absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c  i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)	

global c	
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

************************
* Table 3: Likelihood of Negative Restatement: Timing Analysis
**********************	

sum lastyr_av_ted, de
replace lastyr_av_ted = (lastyr_av_ted - `r(mean)')/`r(sd)'
label var lastyr_av_ted "Past TED Spread"

sum nextyr_av_ted, de
replace nextyr_av_ted = (nextyr_av_ted - `r(mean)')/`r(sd)'
label var nextyr_av_ted "Future TED Spread"

global c totass totdep resishare cshare creshare nplratio oreo_ratio wellcap commit_ratio
areg negrestat b c.b#c.lastyr_av_ted $c i.FedReg if quarter>163 , absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.lastyr_av_ted $c  ///
	using Table3.tex, ///
	tex nocons replace bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(High HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

areg negrestat b c.b#c.nextyr_av_ted $c i.FedReg if quarter>163 , absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.nextyr_av_ted $c  ///
	using Table3.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(High HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)
	
sum HPI_yoy_change,de
replace HPI_yoy_change = (HPI_yoy_change - `r(mean)')/`r(sd)'
	
sum HPI_pastchange,de
replace HPI_pastchange = (HPI_pastchange - `r(mean)')/`r(sd)'
 	
global c totass totdep resishare cshare creshare nplratio oreo_ratio wellcap commit_ratio
areg negrestat b c.b#c.HPI_yoy_change HPI_yoy_change  $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.HPI_yoy_change HPI_yoy_change $c  ///
	using Table3.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(Low HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)		

areg negrestat b c.b#c.HPI_pastchange HPI_pastchange $c  i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.HPI_pastchange HPI_pastchange $c  ///
	using Table3.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(Low HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)			
	
*****************************************************************
** TABLE 4: Likelihood of Call Report Amendment
*****************************************************************	

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
gen late = diffcalldate > 45 if diffcalldate!=. // This means that call date is 15 days past the last day of the quarter
areg late b $c  i.quarter i.FedReg if quarter>163 , absorb(county) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4) replace  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">15 days", Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg late b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">15 days", Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

// Results with dates call Report
replace late = diffcalldate > 75 if diffcalldate!=. // This means that call date is 45 days past the last day of the quarter
areg late b $c   i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">45 days", Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg late b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">45 days", Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

*****************************************************************
** FIGURE 1: Magnitude of Accounting Restatements
*****************************************************************		

use "$dropbox/Data/work files/sample", clear
gen restatement_qinc = (pct_negrestat*riskeqcapital)/qinc

replace restatement_qinc = restatement_qinc*100
eqprhistogram restatement_qinc if restatement_qinc<0 & qinc>0 & restatement_qinc>-200, bin(10) ///
	xlabel(-200(25)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Quarterly Earnings", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Quarterly Earnings", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(5.5 -200 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_earnings, replace)
	graph export eqprhist_restatement_earnings.pdf, replace

replace pct_negrestat = pct_negrestat*100
eqprhistogram pct_negrestat if pct_negrestat<0 & pct_negrestat>-1, bin(10) ///
	xlabel(-1(.125)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Risk-Weighted Assets", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Risk-Weighted Assets (in percentage points)", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(12 -1 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_rwassets, replace)
	graph export eqprhist_restatement_rwassets.pdf, replace

gen restatement_allowance = ((pct_negrestat*riskeqcapital)/ALLL)
eqprhistogram restatement_allowance if pct_negrestat<0 & restatement_allowance>-100, bin(10) ///
	xlabel(-100(25)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Allowance for Loan Losses", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Allowance for Loan Losses", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(.15 -98 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_allowance, replace)
	graph export eqprhist_restatement_allowance.pdf, replace

*****************************************************************
** FIGURE 2: Percentage of Negative and Positive Restatements over Time
*****************************************************************		

use "$dropbox/Data/work files/sample",clear
tostring rssd9999, replace force
gen year = substr(rssd9999, 1, 4)
destring year, replace force
collapse negrestat posrestat, by(year)
drop if year<2001
tsset year
replace negrestat = negrestat*100
replace posrestat = posrestat*100
twoway ///
		(tsline negrestat posrestat, lpattern(dash))  ///
, title("Percentage of Banks with Regulatory Accounting Restatements", size(small)) xlabel(2001(2)2010, val labsize(small)) ylab(0 "0%" 2 "2%"  4 "4%" 6 "6%" 8 "8%" 10 "10%" 12 "12%", labsize(vsmall)) ///
xtitle("Year", size(small)) ytitle("% Restatements", size(small)) graphregion(color(white)) bgcolor(white) note("") legend(lab(1 "% Negative Restatements") lab(2 "% Positive Restatements") size(small)) saving(tseries, replace)
graph export tseries.pdf, replace

*****************************************************************
** FIGURE 3: Regulatory Accounting Restatements and Regulatory Leniency
*****************************************************************		

use "$dropbox/Data/work files/sample",clear

preserve
collapse (mean) negrestat posrestat b, by(county FedReg)
drop if negrestat==.
egen two = count(county), by (county)
drop if two!=2
drop two

egen fedmeanrestatv1 = max(negrestat) if FedReg==1, by(county)
egen fedmeanrestat = max(fedmeanrestatv1), by(county)
egen fedposmeanrestatv1 = max(posrestat) if FedReg==1, by(county)
egen fedposmeanrestat = max(fedposmeanrestatv1), by(county)


fastxtile btiles = b if FedReg==0, nquantiles(5)
label var btiles "Index Bins"

	
collapse (mean) negrestat fedmeanrestat posrestat fedposmeanrestat (sem) semnegrestat = negrestat semposrestat = posrestat semfednegrestat = fedmeanrestat semfedposrestat = fedposmeanrestat, by(btiles FedReg)
gen ubnegrestat = negrestat + 1.65*semnegrestat
gen lbnegrestat = negrestat - 1.65*semnegrestat
gen ubposrestat = posrestat + 1.65*semposrestat
gen lbposrestat = posrestat - 1.65*semposrestat
gen ubfednegrestat = fedmeanrestat + 1.65*semfednegrestat
gen lbfednegrestat = fedmeanrestat - 1.65*semfednegrestat
gen ubfedposrestat = fedposmeanrestat + 1.65*semfedposrestat
gen lbfedposrestat = fedposmeanrestat - 1.65*semfedposrestat

drop in 6/7

twoway ///
	(connected negrestat btiles if FedReg==0, lpattern(solid)) ///
	(rcap ubnegrestat lbnegrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))		legend(off)				///
	title("Percentage of Income-Decreasing Restatements by Leniency Index Quintile (State Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))										///
	ytitle("% Income-Decreasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.02(0.005).05, labsize(vsmall))	///
	saving(leniencybins, replace)
	graph export leniencybins.pdf, replace

twoway ///
	(connected posrestat  btiles if FedReg==0, lpattern(solid))										///
	(rcap ubposrestat lbposrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))			legend(off)				///
	title("Percentage of Income-Increasing Restatements by Regulatory Leniency Quintile (State Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))												///
	ytitle("% Income-Increasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.005(0.005).04, labsize(vsmall))	///
	saving(posleniencybins, replace)
	graph export posleniencybins.pdf, replace
	
twoway ///
	(connected fedmeanrestat btiles if FedReg==0, lpattern(solid))										///
	(rcap ubfednegrestat lbfednegrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))	legend(off)					///
	title("Percentage of Income-Decreasing Restatements by Regulatory Leniency Quintile (National Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))										///
	ytitle("% Income-Decreasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.01(0.005).045, labsize(vsmall))	///
	saving(fednegleniencybins, replace)
	graph export fednegleniencybins.pdf, replace

twoway ///
	(connected fedposmeanrestat btiles if FedReg==0, lpattern(solid))										///
	(rcap ubfedposrestat lbfedposrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))		legend(off)					///
	title("Percentage of Income-Increasing Restatements by Regulatory Leniency Quintile (National Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(vsmall))										///
	ytitle("% Income-Increasing Restatements", size(vsmall)) graphregion(color(white)) bgcolor(white) ylab(0(0.005).035, labsize(small))	///
	saving(fedposleniencybins, replace)
	graph export fedposleniencybins.pdf, replace
restore

*****************************************************************
** FIGURE 4: Regulatory Leniency and the Likelihood of Restatements by Quarter
*****************************************************************

use "$dropbox/Data/work files/sample",clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio 


areg negrestat c.b#i.quarter $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(thin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas, replace)
	graph export betas.pdf, replace

*****************************************************************
** FIGURE 5: Regulatory Leniency and the Likelihood of Restatements by Quarter: Heterogeneity across CRE Lending Specialization
*****************************************************************
	
use "$dropbox/Data/work files/sample",clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

preserve
sum creshare if quarter>163, de
tempvar hi_cre
gen `hi_cre' = creshare>`r(p50)' if creshare!=.

areg negrestat c.b#i.quarter $c i.FedReg if quarter>163 & `hi_cre'==1 , absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(vvthin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	title("High CRE Concentration Banks", size(small))								///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas_highcre, replace)
	graph export betas_highcre.pdf, replace
restore

preserve
sum creshare if quarter>163, de
tempvar hi_cre
gen `hi_cre' = creshare>`r(p50)' if creshare!=.


areg negrestat c.b#i.quarter $c i.FedReg if quarter>163 & `hi_cre'==0 , absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(vvthin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	title("Low CRE Concentration Banks", size(small))								///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent 1.96 +/- St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas_lowcre, replace)
	graph export betas_lowcre.pdf, replace
restore
	
*****************************************************************
** FIGURE 6: Regulatory Leniency and the Timeliness of Loan Loss Provisions during the Financial Crisis
*****************************************************************			

// This is going to be the Merging File
use "$dropbox/Data/cleaned files/regmaster", clear

// Merging the Financial Characteristics Variables
merge 1:1 rssd9001 quarter using "$dropbox/Data/cleaned files/char"
drop _merge
egen rssd92001 = mode(rssd9200), by(rssd9001)
replace rssd9200 = rssd92001 if rssd9200==""
drop rssd92001

egen rssd92001 = mode(reg_state), by(rssd9001)
replace reg_state = rssd92001 if reg_state==.
drop rssd92001

egen fr = mode(FedReg), by(rssd9001)
replace FedReg = fr if FedReg==. 
drop fr

egen cnty = mode(county), by(rssd9001)
replace county = cnty if county==.
drop cnty
drop cnty_qt
egen cnty_qt = group(county quarter)
 
//Merging the Bank Regulatory Index
merge m:1 rssd9200 using "$dropbox/Data/cleaned files/alst_cross_states"
replace b = 0 if FedReg==1 & b!=.
drop _merge


tsset rssd9001 quarter
gen prov_ratio = prov_qrt/tot_loans
gen coratio =  CO_qrt/tot_loans
gen ALLLratio = riad3123/tot_loans

winsor2 prov_ratio coratio ALLLratio, replace cuts(2.5 97.5) trim

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

global c totass totdep resishare creshare oreo_ratio commit_ratio cshare wellcap

// 4 Leads and 4 Lags

preserve
areg prov_ratio c.b#i.quarter f1.coratio f2.coratio f3.coratio coratio l.coratio l2.coratio l3.coratio l4.coratio $c i.FedReg  if quarter>163, absorb(cnty_qt) vce(cl reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..46]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..46]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.645
gen uu = A + sterror*1.645

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)46{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq
twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(thin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)209, labsize(vsmall) angle(60)) ylab(-0.005(0.0025).005, nogrid labsize(small)) ///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	ttext( -.004 166 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall))  ///
	saving(betas_prov, replace)
	graph export betas_prov.pdf, replace
restore
log close
***************************************************************************************************************************************************************
**********                                                                    																    	 **********
**********        ARTICLE: Do Strict Regulators Increase the Transparency of the Banking System?							                     	 **********
**********        AUTHOR:  Anna M. Costello, João Granja, and Joseph P. Weber                   													 **********
**********        JOURNAL OF ACCOUNTING RESEARCH                               																		 **********
**********                                                         																	             	 **********
**********                                    		                	        														       		 **********
**********        TABLE OF CONTENTS:                                            																     **********
**********        -- A: Formation of the Datasets used in the Analysis																                 **********
**********        -- B: Merging the Datasets                    																               	     **********
**********        -- C: Regressions and Figures - Published Paper              																         **********
**********                                                          															         	       	 **********
**********                                                                        																	 **********
**********        README / DESCRIPTION:                                       																	     **********
**********        This STATA do-file converts the raw data into our final     																	     **********
**********        dataset and performs the main statistical analyses. The code         																 **********
**********        uses multiple datasets as inputs and yields the content         																	 **********
**********        of the main analysis as output. 			        																				 **********
**********                                                                         																	 **********
***************************************************************************************************************************************************************

*****************************************************************************************
*****************************************************************************************
******************************  A: SAMPLE FORMATION   ***********************************
*****************************************************************************************
*****************************************************************************************

log using final_log, replace

clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements/Data"
cd "$dropbox/Source Data"

*********************************************************************************************
* Step A.0 -- Pulling Relevant Variables from Call Report Data downloaded from WRDS: (2000:Q1-2010:Q4) and defining relevant variables with financial characteristics
*********************************************************************************************

// A.0.1 - Pull ID, Geographic, and Regulatory Information
use RSSD, clear
keep rssd9001 rssd9007 rssd9010 rssd9050 rssd9056 rssd9130 rssd9150 rssd9180 rssd9200 rssd9220 rssd9220 rssd9210 rssd9220 rssd9331 rssd9348 rssd9364 rssd9421 rssd9422 rssd9950 rssd9999

tostring rssd9999, replace force
gen q = substr(rssd9999,5,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr(rssd9999,1,4)
destring q y rssd9999, replace force
gen quarter = yq(y,q)
drop y q 

gen FedReg = rssd9421==1
gen county = 1000*rssd9210 + rssd9150

save "$dropbox/cleaned files/regmaster", replace

// A.0.2 - Pull Income Statement Information (RIAD Schedules)

use "RIAD", clear
tostring rssd9999, replace force
gen q = substr(rssd9999,5,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr(rssd9999,1,4)
destring q y rssd9999, replace force
gen quarter = yq(y,q)
drop y q 

keep rssd9001 quarter rssd9200 riad4340 riada517 riad4174 riad4230 riad4508 riad0093 riad4509 riadc233 riad4511 riada518 riad4512 riad4107 riadb522 riad4605 riadc079 riad3123 riad5523 ///
riad4079 riad4065 riad4070 riad4080 riada220 riadc886 riadc887 riadc888 riadc386 riadc387 riad4079 riadb491 riadb492 riadb493 riad4415 riadb507 riad4635 riad4302 riad3210 riada517 riadf556 ///
riad3123
tempfile RI
save "`RI'"

// A.0.3 - Pull Balance Sheet Information (RCON and RCFD Schedules)

use "RCON0.dta", clear
keep rssd9001 quarter rcon0010 rcon0352 rcon0426
tempfile RCON0
save "`RCON0'"

use "RCFD0.dta", clear
keep rssd9001 quarter rcfd0010 rcfd0426
tempfile RCFD0
save "`RCFD0'"

use "RCON1.dta", clear
keep rssd9001 quarter rcon1350 rcon1400 rcon1403 rcon1406 rcon1407 rcon1410 rcon1415 rcon1460 rcon1480 rcon1754 rcon1763 rcon1764 rcon1766 rcon1773 rcon1797
tempfile RCON1
save "`RCON1'"

use "RCFD1.dta", clear
keep rssd9001 quarter rcfd1350 rcfd1400 rcfd1403 rcfd1406 rcfd1407 rcfd1410 rcfd1415 rcfd1460 rcfd1480 rcfd1754 rcfd1763 rcfd1764 rcfd1766 rcfd1773 rcfd1797
tempfile RCFD1
save "`RCFD1'"

use "RCON2.dta", clear
keep rssd9001 quarter rcon2008 rcon2011 rcon2122 rcon2170 rcon2200 rcon2215 rcon2702 rcon2365 rcon2604 rcon2746 rcon2800 rcon2150
tempfile RCON2
save "`RCON2'"

use "RCFD2.dta", clear
keep rssd9001 quarter rcfd2008 rcfd2011 rcfd2122 rcfd2170 rcfd2200 rcfd2746 rcfd2800 rcfd2150
tempfile RCFD2
save "`RCFD2'"

use "RCON3.dta", clear
keep rssd9001 quarter rcon3190 rcon3200 rcon3210 rcon3230 rcon3163 rcon3345 rcon3485 rcon3486 rcon3487 rcon3469 rcon3411 rcon3814 rcon3816 rcon3817 rcon3818 rcon3819 rcon3821 rcon3838 rcon3839 rcon3123 rcon3632
tempfile RCON3
save "`RCON3'"

use "RCFD3.dta", clear
keep rssd9001 quarter rcfd3190 rcfd3200 rcfd3210 rcfd3230 rcfd3163 rcfd3345 rcfd3411 rcfd3814 rcfd3816 rcfd3817 rcfd3818 rcfd3819 rcfd3821 rcfd3838 rcfd3123 rcfd3839 rcfd3632
tempfile RCFD3
save "`RCFD3'"

use "RCON5.dta", clear
keep rssd9001 quarter rcon5367 rcon5368
tempfile RCON5
save "`RCON5'"

use "RCON6.dta", clear
keep rssd9001 quarter rcon6550 rcon6810 rcon6648 rcon6164 rcon6165 rcon6724
tempfile RCON6
save "`RCON6'"

use "RCFD6.dta", clear
keep rssd9001 quarter rcfd6550 rcfd6165 rcfd6164 rcfd6724
tempfile RCFD6
save "`RCFD6'"

use "RCON7.dta", clear
keep rssd9001 quarter rcon7204 rcon7205 rcon7206
tempfile RCON7
save "`RCON7'"

use "RCFD7.dta", clear
keep rssd9001 quarter rcfd7204 rcfd7205 rcfd7206
tempfile RCFD7
save "`RCFD7'"

use "RCON8.dta", clear
keep rssd9001 quarter rcon8500 rcon8504 rcon8503 rcon8507 rcon8274
tempfile RCON8
save "`RCON8'"

use "RCFD8.dta", clear
keep rssd9001 quarter rcfd8500 rcfd8504 rcfd8503 rcfd8507 rcfd8274 
tempfile RCFD8
save "`RCFD8'"

use "RCONA.dta", clear
keep rssd9001 quarter rcona514 rcona529 rcona584 rcona585 rcona223 rcona224
tempfile RCONA
save "`RCONA'"

use "RCFDA.dta", clear
keep rssd9001 quarter rcfda223 rcfda224 
tempfile RCONA
save "`RCONA'"

use "RCONB.dta", clear
keep rssd9001 quarter rconb563 rconb987 rconb989 rconb993 rconb995 rconb538 rconb539 
tempfile RCONB
save "`RCONB'"

use "RCFDB.dta", clear
keep rssd9001 quarter rcfdb987 rcfdb989 rcfdb993 rcfdb995 rcfdb538 rcfdb539 
tempfile RCFDB
save "`RCFDB'"

use "RCONC.dta", clear
keep rssd9001 quarter rconc026 rconc027 
tempfile RCONC
save "`RCONC'"

use "RCFDC.dta", clear
keep rssd9001 quarter rcfdc026 rcfdc027 rcfdc410 rcfdc411
tempfile RCFDC
save "`RCFDC'"

use "RCONF.dta", clear
keep rssd9001 quarter rconf049 rconf045 rconf070 rconf071 rconf158 rconf159 rconf160 rconf161 rconf164 rconf165
tempfile RCONF
save "`RCONF'"

use "RCFDF.dta", clear
keep rssd9001 quarter rcfdf070 rcfdf071 rcfdf164 rcfdf165
tempfile RCFDF
save "`RCFDF'"

use "RCONG.dta", clear
keep rssd9001 quarter rcong167 rcong300 rcong304 rcong308 rcong312 rcong316 rcong320 rcong324 rcong328 rcong315 rcong319 rcong323 rcong327 rcong331 ///
rcong336 rcong340 rcong344 rcong303 rcong307 rcong311 rcong339 rcong343 rcong347 rconj473 rconj474 rconj457 rconj458 rconj459
tempfile RCONG
save "`RCONG'"

use "RCFDG.dta", clear
keep rssd9001 quarter rcfdg300 rcfdg304 rcfdg308 rcfdg312 rcfdg316 rcfdg320 rcfdg324 rcfdg328 rcfdg315 rcfdg319 rcfdg323 rcfdg327 rcfdg331 ///
rcfdg336 rcfdg340 rcfdg344 rcfdg303 rcfdg307 rcfdg311 rcfdg339 rcfdg343 rcfdg347 rcfdj457 rcfdj458 rcfdj459
tempfile RCFDG
save "`RCFDG'"

use "$dropbox/cleaned files/regmaster", clear
local c RI RCON0 RCON1 RCON2 RCON3 RCON5 RCON6 RCON7 RCON8 RCONA RCONB RCONF RCONG RCFD0 RCFD1 RCFD2 RCFD3 RCFD6 RCFD7 RCFD8 RCFDB RCFDC RCFDF RCFDG
foreach x of local c{
	merge 1:1 rssd9001 quarter using "``x''"
	drop _merge
	
}
keep if quarter<200

tempfile var1994_2010
save `var1994_2010'

// A.0.4 - Pulling in 2010:Q1 - 2012:Q4 (This set of files was downloaded from FFIEC rather than WRDS)
local d RCA RCCI RCCII RCD RCE RCEI RCEII RCF RCG RCH RCI RCK RCN RCN_1 RCN_2 RCM RCO RCP RCS RI_2 RIA RIBI RIBII RID RIE RCB_1 RCL_1 RCQ_1 RCR_1 RCT_1 RCB_2 RCL_2 RCQ_2 RCR_2 RCT_2
use RC, clear

foreach t of local d{
 merge 1:1 rssd9001 quarter using `t', update
 drop _merge
}
*************************************

gen year =  substr(quarter,5,4)
gen q = substr(quarter,1,2)
gen d = substr(quarter,3,2)
gen rssd9999 = year + q + d
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
destring year q rssd9999, replace force
gen qrt = yq(year,q)
drop quarter
rename qrt quarter

// Defining what variables to keep
keep rssd9001 rssd9999 quarter riada517 riad4415 riad4508 riad0093 riada518 riad4340 rcon0010 rcon0352 rcon3230 rcon3163 rcfd3230 rcfd3163 rcon1227 rcon1228 rcon1420 rcon1460 rcon1545 rcon1590 rcon1607 rcon1608 rcon1754 rcon1763 rcon1764 rcon1766 rcon1773 rcon1797 rcon2011 rcon2081 rcon2107 rcon2122 rcon2165 ///
rcon2170 rcon2200 rcon2215 rcon2365 rcon2746 rcon3190 rcon3200 rcon3210 rcon3411 rcon3485 rcon3494 rcon3495 rcon3500 rcon3501 rcon3814 rcon3817 rcon3838 rcon5367 rcon5368 rcon5390 rcon5391 rcon5399 rcon5400 rcon5460 ///
rcon5461 rcon6550 rcon6810 rcon6648 rcon7204 rcon7205 rcon7206 rcona514 rcona529 rcona584 rcona585 rconb531 rconb534 rconb535 rconb538 rconb539 rconb563 rconb987 rconb989 rconb993 rconb995 rconb538 rconb539 rconb576 rconb577 rconb579 rconb580 rconb835 rconb836 ///
rconc026 rconc027 rconc229 rconc230 rconc237 rconc239 rconf049 rconf045 rconf070 rcon7273 rcon7274 rcon7275 rcfnb574 rcon0426 rcfd0426  ///
rconf158 rconf159 rconf160 rconf161 rconf164 rconf165 rconf174 rconf175 rconf176 rconf177 rconf180 rconf181 rconf182 rconf183 rcong167 rcong300 rcong304 rcong308 rcong312 rcong316 rcong320 rcong324 rcong328 rcong336 rcong340 rcong344 rcong303 rcong307 rcong311 rcong315 ///
rcong319 rcong323 rcong327 rcong331 rcong339 rcong343 rcong347 rconj451 rconj453 rconj454 rconj457 rconj458 rconj459 rconj473 rconj474 rconk137 rconk142 rconk145 rconk146 rconk149 rconk150 rconk153 rconk154 rconk157 rconk207 ///
rcfd0010 rcfd1410 rcfd1754 rcfd1763 rcfd1764 rcfd1773 rcfd2011 rcfd2122 rcfd2170 rcfd2746 rcfd3190 rcfd3200 rcfd3210 rcfd3411 rcfd3814 rcfd3817 rcfd3838 rcfd3839 rcon3839 ///
rcfd6550 rcfd7204 rcfd7205 rcfd7206 rcfdb989 rcfdb995 rcfdb538 rcfdb539 rcfdc026 rcfdc027 rcfdf164 rcfdf165 rcfdg300 rcfdg304 rcfdg308 rcfdg312 rcfdg316 rcfdg320 rcfdg324 rcfdg328 rcfdg315 rcfdg319 rcfdg323 rcfdg327 rcfdg331 ///
rcfdg336 rcfdg340 rcfdg344 rcfdg303 rcfdg307 rcfdg311 rcfdg339 rcfdg343 rcfdg347 rcfdk137 rcfdk207 rcfdb534 rcfdb532 rcfdb533 rcfdb536 rcfdb537 rcfd1590 rcfdb538 rcfdb539 rcfd1763 rcfd1764 rcfd2011 ///
rcfd2081 rcfd2107 rcfd1563 rcfdf162 rcfdf163 rcfdj457 rcfdj458 rcfdj459 rcon1583 rcon1256 rcon2150 rcfd2150 rcon3632 rcfd3632 ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 rcfd1256 rcfdb577 rcfdk215 rcfdk218 ///
rcfd5461 rcfdf168 rcfdf171 rcfd3507 rcfdk038 rcfdk041 rcfdk044 rconk047 rconk050 rconk053 rconk056 rconk059 rconk062 rconk065 rconk068 rconk071 ///
rcfdk074 rcfdk077 rcfdk080 rcfdk083 rcfdk086 rcfdk089 rcfdk093 rcfdk097 rcfdk101 rcfdk272 rcfnk293 rcfdk104 rcon3123 rcfd3123 ///
rcon5382 rcon1583 rcon1256 rconb577 rconk215 rconk218 rcon5391 rcon5461 rconf168 rcon3507 rconk038 rconk041 rconk044 rconk074 rconk077 rconk080 rconk083 rconk086 rconk089 rconk093 rconk097 rconk101 rconk272 rconk104 /// 
rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 rcfd1255 rcfdb576 rcfdk214 rcfdk217 rcfd5390 rcfd5460 rcfdf167 rcfdf170 rcfd3506 ///
rcfdk037 rcfdk040 rcfdk043 rconk046 rconk049 rconk052 rconk055 rconk058 rconk061 rconk064 rconk067 rconk070 rcon8274 rcfd8274 ///
rcfdk073 rcfdk076 rcfdk079 rcfdk082 rcfdk085 rcfdk088 rcfdk092 rcfdk096 rcfdk100 rcfdk271 rcfnk292 rcfdk103 riad4230 rcona223 rcona224 ///
rcon5381 rcon1597 rcon1255 rconb576 rconk214 rconk217 rcon5390 rcon5460 rconf167 rcon3506 rconk037 rconk040 rconk043 rconk046 rconk049 rconk052 rconk055 rconk058 rconk061 rconk064 rconk067 rconk070 ///
rconk073 rconk076 rconk079 rconk082 rconk085 rconk088 rconk092 rconk096 rconk100 rconk271 rcfnk292 rconk103 rcfd3819 rcfd3821 rcon3819 rcon3821 ///
rcfdb579 rcfd5390 rcfd5460 rcfdf167 rcfdf170 rcfd3506 rcfd5613 rcfd5616 rcfdc867 rconb579 rcon5613 rcon5616 rconc867 ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcon5382 rcon1583 rcfd1253 rcfdj457 rcfdj458 rcfdj459 rconj457 rconj458 rconj459 ///
rcon1256 rconb577 rconb580 rcon5391 rcon5461 rcfdf168 rcfdf171 rcon3507 rcon5614 rcon5617 rcfdc868 riadb491 riadb492 riadb493 riadf556  ///
rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 rcfd6724 rcon6724 ///
rcfd1256 rcfdb577 rcfdb580 rcfd5391 rcfd5461 rcfdf168 rcfdf171 rcfd3507 rcfd5614 rcfd5617 rcfdc868 riad4070 riad4080 riada220 riadc886 riadc887 riadc888 riadc386 riadc387 riad4079 riad4079 riad4065 riad4107 rconf172 rconf173 rcon3493 rcon5398 rconc236 rconc238 rcon3499 rconf178 ///
rconf179 rcfnb572 rcfd5377 rcfd5380 rcfd1594 rcfd1251 rcfd1254 rcfdb575 rcfdb578 rconb578 rcfd5389 rcfd5459 rcfdf166 rconf166 rcfdf169 rcfdk213 rcfdk216 rcfd6165 rcfd6164 rcon6165 rcon6164 rcon1254 rconb575 rconk213 rconk216 rcon5389 rcon5459 rcon1594 rcon5380 riadb507 rcfda223 riad4635 riad4605 riad4302 riad3210 riad3123

tempfile var2010_2013
save `var2010_2013'

use "$dropbox/cleaned files/regmaster", clear
merge 1:1 rssd9001 quarter using `var2010_2013'
keep if quarter>199
drop _merge

save `var2010_2013', replace
use `var1994_2010', clear
append using `var2010_2013'


// A.0.5 - Creating Financial Ratios and other variables to use in the main empirical analysis

tsset rssd9001 quarter
tostring rssd9999, replace force

// Defining the Restatement Variables
gen restat = riadb507 !=0 if riadb507!=.
gen negrestat = riadb507 <0 if riadb507!=.
gen posrestat = riadb507 > 0 if riadb507!=.

// Restatement Amount as a fraction of total risk-weighted assets
gen riskeqcapital = rcfda223
replace riskeqcapital = rcona223 if quarter>=200
gen pct_negrestat = riadb507/riskeqcapital if riadb507 <=0 & riadb507!=.

// Fixed-Effect Groups
egen state = group(rssd9200)
egen reg_state = group(rssd9200 FedReg)
egen cnty_qt  = group(county quarter)

* Creating Size Variable (Total Assets)
gen totass = rcfd2170
replace totass = rcon2170 if rcfd2170==.
label var totass "Total Assets (Current Prices)"

gen totdep = rcfd2200
replace totdep = rcon2200 if totdep==.
label var totdep "Total Deposits (Current Prices)"

gen tot_loans = rcfd2122
replace tot_loans = rcon2122 if tot_loans==.
label var tot_loans "Total Loans (Current Prices)"

// Portfolio Composition Variables: Share of Residential, CRE, and Consumer Loans

* Residential 1-4 Family Loans
gen residential = rcon1797 + rcon5367 + rcon5368 // Total Loand secured by Residential Real Estate
gen resishare = residential/tot_loans

* Commercial & Real Estate Loans
gen cre_loans = rcon1415 + rcon1460 + rcon1480 + rcfd2746 // Total Loans secured by CRE
replace cre_loans = rconf158 + rconf159 + rcon1460 + rconf160 + rconf161 + rcfd2746 if cre_loans==. 
replace cre_loans = rconf158 + rconf159 + rcon1460 + rconf160 + rconf161 + rcon2746 if cre_loans==.
gen creshare = cre_loans/tot_loans

// Consumer Loans Share
gen cons_loans = rcfdb538 + rcfdb539 + rcfd2011 if quarter<200 // Total Individual loans
replace cons_loans = rcfdb538 + rcfdb539 + rcfd2011 if quarter>=200 
replace cons_loans = rconb538 + rconb539 + rcon2011 if quarter>=200 & cons_loans==.
replace cons_loans = rcfdb538 + rcfdb539 + rcfdk137 + rcfdk207 if quarter>=204 & cons_loans==.
replace cons_loans = rconb538 + rconb539 + rconk137 + rconk207 if quarter>=204 & cons_loans==.
gen cshare = cons_loans/tot_loans


// Asset Quality Ratios: Delinquent Loan Ratio (NPL ratio) and OREO Ratio (Foreclosed Property Ratio)

// NPL Ratio
gen npl1403 = rcfd1403 if quarter<200
egen npl1403v1 = rowtotal (rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcfd5382 rcfd1583 rcfd1253 ///
rcfd1256 rcfdb577 rcfdb580 rcfd5391 rcfd5461 rcfdf168 rcfdf171) if quarter>=200 & quarter<204 & rcfd5391!=.
egen npl1403v2 = rowtotal (rconf176 rconf177 rcon3495 rcon5400 rconc229 rconc230 rcon3501 rconf182 rconf183 rcfnb574 rcfd5379 rcon5382 rcon1583 rcfd1253 ///
rcon1256 rconb577 rconb580 rcon5391 rcon5461 rconf168 rcfdf171) if quarter>=200 & quarter<204
replace npl1403 = npl1403v1 if npl1403==.
replace npl1403 = npl1403v2 if npl1403==.

gen npl1407 = rcfd1407
egen npl1407v1 = rowtotal(rconf174 rconf175 rcon3494 rcon5399 rconc237 rconc239 rcon3500 rconf180 rconf181 rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 ///
rcfd1255 rcfdb576 rcfdb579 rcfd5390 rcfd5460 rcfdf167 rcfdf170) if quarter>=200 & quarter<204 & rcfd5381!=.
egen npl1407v2 = rowtotal(rconf174 rconf175 rcon3494 rcon5399 rconc237 rconc239 rcon3500 rconf180 rconf181 rcfnb573 rcfd5378 rcfd5381 rcfd1597 rcfd1252 ///
rcfd1255 rcfdb576 rconb579 rcfd5390 rcfd5460 rconf167 rcfdf170) if quarter>=200 & quarter<204
replace npl1407 = npl1407v1 if npl1407==.
replace npl1407 = npl1407v2 if npl1407==.

gen npl_loans = (npl1407 + npl1403) // This is total non-performing loans
gen nplratio = (npl1407 + npl1403)/tot_loans
label var nplratio "Nonperforming Loans (+90 PD + Nonacc)/Total Loans"
drop npl1403v1 npl1403v2 npl1407v1 npl1407v2

// Other Real Estate Owned Ratio

gen oreo_ratio = rcfd2150/rcfd2170
replace oreo_ratio = rcon2150/rcon2170 if oreo_ratio==.


// Liquidity and Solvency Ratios
******
* Liquidity Ratio is the Unused Commmitment Ratio (Following Acharya and Mora, 2015 JF)

* Total Commitments
egen commitments = rowtotal(rcfd3814 rcfd3816 rcfd3817 rcfd3818 rcfd6550 rcfd3411) if quarter<200
egen commitments1 = rowtotal(rcfd3814 rcfdf164 rcfdf165 rcfd3817 rcfdj457 rcfdj458 rcfdj459 rcfd6550 rcfd3411) if quarter>=200 & rcfd3814!=.
egen commitments2 = rowtotal(rcon3814 rconf164 rconf165 rcon3817 rconj457 rconj458 rconj459 rcon6550 rcon3411) if quarter>=200
replace commitments = commitments1 if commitments==.
replace commitments = commitments2 if commitments==.

* Unused Commitments ratio
gen commit_ratio = commitments/(tot_loans+commitments)
label var commit_ratio "Unused Commitments as % Gross Loans + Unused Commitments"
drop commitments1 commitments2

// Tier 1 Capital Ratio
replace rcon7204 = rcon7204*100 if quarter<195 |quarter>=200
gen tier1ratio = rcon7204
gen wellcap = tier1ratio>5

******************************
// Income and Loan Loss Numbers
************************************

// Quarterly Income
gen qinc = riad4340-l.riad4340
replace qinc = riad4340 if substr(rssd9999, 5, 2)=="03"

// Charge-Offs by Quarter
gen CO_qrt = (riad4635-riad4605) if substr(rssd9999, 5, 2)=="03"
replace CO_qrt = (riad4635-riad4605) - (l.riad4635-l.riad4605) if substr(rssd9999, 5, 2)!="03"

// Quarterly Provisions
gen prov_qrt = riad4230 if substr(rssd9999, 5, 2)=="03"
replace prov_qrt = riad4230 - l.riad4230 if substr(rssd9999, 5, 2)!="03"

// Allowance for Loan and Lease Losses (ALLL)
gen ALLL = riad3123

keep rssd9001 quarter riad3123 restat-ALLL
save "$dropbox/cleaned files/char",replace

*********************************************************************************************
* Step A.1 -- Pulling and cleaning TED Spread Data
*********************************************************************************************

import delimited "TEDRATE.csv", clear
rename tedrate av_ted

tostring date, replace force
gen q = substr(date,6,2)
replace q = "1" if q=="01"
replace q = "2" if q=="04"
replace q = "3" if q=="07"
replace q = "4" if q=="10"
gen y = substr(date,1,4)
destring q y date, replace force
gen quarter = yq(y,q)
drop y q date

tsset quarter
gen nextyr_av_ted = f4.av_ted
gen lastyr_av_ted = l4.av_ted

save "$dropbox/cleaned files/TED", replace

*********************************************************************************************
* Step A.2 -- Creating Bank-Specific House Price Indices
*********************************************************************************************

// A.2.1 --> Pulling and Cleaning House Price Data obtained from FFIEC website

// 1) Metropolitan Areas House Price Indices
import delimited "3q13hpi_cbsa.csv", clear
drop v6

rename v1 msaname
rename v2 msabr
rename v3 year
rename v4 q
rename v5 HPI

gen divisionb = msabr

destring HPI, replace force
gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if  msaname[`i'+4]==msaname[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  msaname[`i']==msaname[`i'-4]
}


gen quarter = yq(year,q)
drop year q HPI

tempfile MSA_HPI
save `MSA_HPI', replace

// 2) House Price Indices of the NonMetropolitan Areas of each State
import excel "indexes_nonmetro_thru_13q3.xls", sheet("hpi_stsbal") clear
drop in 1/3
rename A stalpbr
rename B year
rename C q
rename D HPI
drop E

destring  year q HPI, replace force

gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if stalpbr[`i'+4]==stalpbr[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  stalpbr[`i']==stalpbr[`i'-4]
}

gen quarter = yq(year,q)
drop year q HPI

tempfile nonMSA_HPI
save `nonMSA_HPI'

// 3) Puerto Rico
import excel "PR_Downloadable_alltransactions.xls", sheet("Puerto Rico--All Transactions") clear
drop in 1/6
drop A
gen stalpbr = "PR"
rename B year
rename C q
rename D HPI

destring  year q HPI, replace force

gen HPI_change = .
gen HPI_pastchange = .
forvalues i = 2/`=_N'{
		quietly replace HPI_change = HPI[`i'+4]/HPI[`i'] in `i' if stalpbr[`i'+4]==stalpbr[`i'] 
		quietly replace HPI_pastchange = HPI[`i']/HPI[`i'-4] in `i' if  stalpbr[`i']==stalpbr[`i'-4]
		}

gen quarter = yq(year,q)
drop year q HPI
duplicates drop stalpbr quarter, force

append using `nonMSA_HPI'
save `nonMSA_HPI', replace

// A.2.2 -->  Merge HPI indices with SOD data: Computing Bank-Specific House Price Change Index that weights House Price Changes based on share of deposits of the bank in each area

foreach num of numlist 1(1)4{
use "/Users/joaogranja/Dropbox (Personal)/Summary of Deposits/SOD_all.dta", clear
gen q = `num'
gen quarter = yq(year,q)
drop year q

merge m:1 msabr quarter using `MSA_HPI'
drop if _merge==2
drop _merge

merge m:1 divisionb quarter using `MSA_HPI', update
drop if _merge==2
drop _merge

merge m:1 stalpbr quarter using `nonMSA_HPI', update
drop if _merge==2
drop _merge

collapse (mean) HPI_change HPI_pastchange [fw=depsumbr], by(cert quarter)
rename cert rssd9050
saveold "$dropbox/cleaned files/HPI_changeq`num'", replace
}

append using "$dropbox/cleaned files/HPI_changeq3"
append using "$dropbox/cleaned files/HPI_changeq2"
append using "$dropbox/cleaned files/HPI_changeq1"
rename HPI_change HPI_yoy_change

save "$dropbox/cleaned files/HPI_changeyoy", replace

*********************************************************************************************
* Step A.3. -- Pulling and Cleaning Textual Description of the Catch-Up restatements
*********************************************************************************************

//PULLING IN RI-E SCHEDULE DATA

clear all
cd "$dropbox/Source Data/FFIEC RIE Schedules for all quarters"
file open myfile using "../filelist.txt", read
file read myfile line
drop _all
import delimited "`line'", clear

keep textb526 textb527 idrssd
drop in 1 //dropping label row
save "`line'.dta", replace
gen q = substr("`line'",29,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr("`line'",33,4)
destring q y, replace force
gen quarter = yq(y,q)
drop y q
rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
save "$dropbox/cleaned files/RIE_data.dta", replace 
drop _all

file read myfile line
while r(eof)==0 {
import delimited "`line'", clear
keep textb526 textb527 idrssd
drop in 1 //dropping label row
save "`line'.dta", replace
gen q = substr("`line'",29,2)
replace q = "1" if q=="03"
replace q = "2" if q=="06"
replace q = "3" if q=="09"
replace q = "4" if q=="12"
gen y = substr("`line'",33,4)
destring q y, replace force
gen quarter = yq(y,q)
drop y q 
rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
append using "$dropbox/cleaned files/RIE_data.dta"
duplicates drop rssd9001 quarter, force
save "$dropbox/cleaned files/RIE_data.dta", replace
drop _all
file read myfile line
}


local a 12312009 12312010 09302009 09302010 06302010 03312008 03312010 06302007 06302008 06302009 09302007 09302008 12312007 12312008
foreach b of local a{
	import delimited "FFIEC CDR Call Schedule RIE `b'.txt", clear varnames(1)
	keep textb527 idrssd
	drop in 1 //dropping label row
	gen q = substr("`b'",1,2)
	replace q = "1" if q=="03"
	replace q = "2" if q=="06"
	replace q = "3" if q=="09"
	replace q = "4" if q=="12"
	gen y = substr("`b'",5,4)
	destring q y, replace force
	gen quarter = yq(y,q)
	drop y q 
	rename idrssd rssd9001
	destring rssd9001, replace force
	drop if rssd9001==.
	append using "$dropbox/cleaned files/RIE_data.dta"
	save "$dropbox/cleaned files/RIE_data.dta", replace
clear all
}


cd ..

use "$dropbox/cleaned files/RIE_data.dta", clear
gen text = textb526
replace text = textb527 if text==""
replace text = proper(text)
drop textb526 textb527

// Mathematical or Rounding Error Categories
gen error =  regexm(text,"((Math)+)") | regexm(text,"((Round)+)") 

// Adjustment related to change in Accounting Principle
gen principle =  regexm(text,"(Fas)") | regexm(text,"((Eitf)+)") | regexm(text,"((Sab)+)") | regexm(text,"((Fin48)+)") | regexm(text,"((fas)+)") | regexm(text,"((Fin 48)+)")  | regexm(text,"((Principle)+)") | regexm(text,"((Split)+)") ///
| regexm(text,"((Eift)+)") | regexm(text,"((Life Insurance)+)") | regexm(text,"((Retirement)+)") | regexm(text,"((Boli)+)") | regexm(text,"((principal)+)") 

// Adjustments that are related to Audits
gen audit =  regexm(text,"((Audit)+)")

// Adjustments that are related to Taxes
gen tax =  regexm(text,"((Tax)+)") | regexm(text,"((tax)+)") | regexm(text,"((Irs)+)")

// Adjustments in Loan Loss Accounting
gen loanloss =  regexm(text,"((Loan Loss)+)") | regexm(text,"((Loss Reserve)+)") | regexm(text,"((Llr)+)") | regexm(text,"((Alll)+)") | regexm(text,"((Allowance)+)") // Loan Loss Accounting

// Adjustment related to the misclassification or mismeasurement of the portfolio of securities and Investments
gen secport = regexm(text,"((Reclassification)+)") | regexm(text,"((Htm)+)") | regexm(text,"((Afs)+)") | regexm(text,"((Unrealized Gains)+)") | regexm(text,"((Unrealized Losses)+)") | regexm(text,"((U/R)+)") | regexm(text,"((Write Down)+)") | regexm(text,"((Write-Down)+)") ///
| regexm(text,"((Wrote Down)+)") | regexm(text,"((Impairment)+)") | regexm(text,"((Oci)+)") | regexm(text,"((Other Comprehensive Income)+)") | regexm(text,"((Investment)+)") | regexm(text,"((Reo)+)") | regexm(text,"((Oreo)+)")

// Accrual Accounting Adjustment
gen noncurrent = regexm(text,"((Goodwill)+)") | regexm(text,"((Depreciation)+)") | regexm(text,"((Depr.)+)") | regexm(text,"((Amortization)+)") | regexm(text,"((Lease)+)") | regexm(text,"((Pension Plan)+)") | regexm(text,"((Mortgage Servicing)+)") // Accruals related to noncurrent assets and liabilities

// Consolidation Accounting Adjustment
gen consolidation = regexm(text,"((Consolidation)+)") | regexm(text,"((Unconsolidated)+)") | regexm(text,"((Subsidiary)+)") | regexm(text,"((Parent)+)") | regexm(text,"((Holding)+)") |  regexm(text,"((Merger)+)") | regexm(text,"((Purchase Accounting)+)") // Consolidation Acounting

// General Accounting Adjustment
gen accounting = regexm(text,"((Reserve)+)") | regexm(text,"((Loan Loss)+)") | regexm(text,"((Loss Reserve)+)") | regexm(text,"((Llr)+)") | regexm(text,"((Alll)+)") | regexm(text,"((Provision)+)") | regexm(text,"((Allowance)+)") /// Loan Loss Accounting
| regexm(text,"((Reclassification)+)") | regexm(text,"((Htm)+)") | regexm(text,"((Afs)+)") | regexm(text,"((Unrealized Gains)+)") | regexm(text,"((Unrealized Losses)+)") | regexm(text,"((U/R)+)") | regexm(text,"((Write Down)+)") | regexm(text,"((Write-Down)+)") | regexm(text,"((Wrote Down)+)") | regexm(text,"((Impairment)+)") | regexm(text,"((Oci)+)") | regexm(text,"((Other Comprehensive Income)+)") | regexm(text,"((Investment)+)") | regexm(text,"((Reo)+)") | regexm(text,"((Oreo)+)") /// Misclassification of Gains and Losses on Securities
| regexm(text,"((Accrual)+)") | regexm(text,"((Accr)+)") | regexm(text,"((Overaccrual)+)") | regexm(text,"((Accrued)+)") | regexm(text,"((Deferred)+)") | regexm(text,"((Deferral)+)") | regexm(text,"((Payable)+)") | regexm(text,"((Receivable)+)") | regexm(text,"((Adjusting Entries)+)") | regexm(text,"((Reverse entry)+)")  /// Errors in Accrual Accounting
| regexm(text,"((Goodwill)+)") | regexm(text,"((Depreciation)+)") | regexm(text,"((Depr.)+)") | regexm(text,"((Amortization)+)") | regexm(text,"((Lease)+)") | regexm(text,"((Pension Plan)+)") | regexm(text,"((Mortgage Servicing)+)") | regexm(text,"((Prepaid)+)") /// Specific misclassified Accounting accruals
| regexm(text,"((Expense)+)") | regexm(text,"((Interest)+)")  /// Misclassification of interest and expense
| regexm(text,"((Consolidation)+)") | regexm(text,"((Unconsolidated)+)") | regexm(text,"((Subsidiary)+)") | regexm(text,"((Parent)+)") | regexm(text,"((Holding)+)") |  regexm(text,"((Merger)+)") | regexm(text,"((Purchase Accounting)+)") /// Investment Acounting
| regexm(text,"((Liability Increase)+)") | regexm(text,"((Retained Earnings)+)")  | regexm(text,"((Understated)+)") | regexm(text,"((Overstated)+)") | regexm(text,"((Measurement)+)") | regexm(text,"((Unrecorded)+)") /// Issues with Measurement
| regexm(text,"((Accounting)+)") 

duplicates drop rssd9001 quarter, force
save "$dropbox/cleaned files/RIE_data_final.dta", replace

*********************************************************************************************
* Step A.4. -- Pulling the dates of the last submission of the Call Report (To compute likelihood of an ammendment to the call report)
*********************************************************************************************

local a 12312010 12312009 12312008 12312007 12312006 12312005 09302010 09302009 09302008 09302007 09302006 09302005 06302010 06302009 06302008 06302007 06302006 03312010 03312009 03312008 03312007 03312006
foreach b of local a{
import delimited  "$dropbox/Source Data/FFIEC/FFIEC CDR Call Bulk All Schedules `b'/FFIEC CDR Call Bulk POR `b'.txt", clear
gen callreportdate = "`b'"
gen monthcallreport = substr(callreportdate, 1,2)
gen daycallreport = substr(callreportdate, 3,2)
gen yearcallreport = substr(callreportdate, 5,4)
gen monthlastsubmission = substr(lastdatetimesubmissionupdatedon, 6,2)
gen daylastsubmission = substr(lastdatetimesubmissionupdatedon, 9,2)
gen yearlastsubmission = substr(lastdatetimesubmissionupdatedon, 1,4)
destring monthlastsubmission daylastsubmission yearlastsubmission monthcallreport daycallreport yearcallreport, replace force
gen lastcalldate = mdy(monthlastsubmission, daylastsubmission, yearlastsubmission)
gen calldate = mdy(monthcallreport, daycallreport, yearcallreport)
gen diffcalldate = lastcalldate-calldate

rename idrssd rssd9001

tostring yearcallreport monthcallreport , replace force
replace monthcallreport = "1" if monthcallreport=="03"
replace monthcallreport = "1" if monthcallreport=="3"
replace monthcallreport = "2" if monthcallreport=="06"
replace monthcallreport = "2" if monthcallreport=="6"
replace monthcallreport = "3" if monthcallreport=="09"
replace monthcallreport = "3" if monthcallreport=="9"
replace monthcallreport = "4" if monthcallreport=="12"
destring monthcallreport yearcallreport, replace force

gen quarter = yq(yearcallreport,monthcallreport)
keep rssd9001 quarter lastcalldate calldate diffcalldate
save  "$dropbox/Source Data/FFIEC/days`b'", replace
}
*
local a 12312009 12312008 12312007 12312006 12312005 09302010 09302009 09302008 09302007 09302006 09302005 06302010 06302009 06302008 06302007 06302006 03312010 03312009 03312008 03312007 03312006
use  "$dropbox/Source Data/FFIEC/days12312010", clear
foreach b of local a{
append using  "$dropbox/Source Data/FFIEC/days`b'"
}
duplicates drop rssd9001 quarter,force // Eliminates one duplicate observation -- Error in the data
save  "$dropbox/cleaned files/dates",replace


*******************************************************************************************************************
*******************************************************************************************************************
******************************  B: MERGING DATASETS   *************************************************************
*******************************************************************************************************************
*******************************************************************************************************************

clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements/Data"

// Start with ID, Geographic, and Regulatory Information 
use "$dropbox/cleaned files/regmaster", clear

// Merging the Financial Characteristics Variables
merge 1:1 rssd9001 quarter using "$dropbox/cleaned files/char"
drop if _merge==2
drop _merge

// Merging with the Bank Regulatory Index obtained form Amit Seru
merge m:1 rssd9200 using "$dropbox/cleaned files/alst_cross_states"
replace b = 0 if FedReg==1 & b!=.
drop _merge

// Merging the TED Spread
merge m:1 quarter using "$dropbox/cleaned files/TED"
drop if _merge==2
drop _merge

// Merging with the HPI Y-o-Y Change
merge m:1 rssd9050 quarter using "$dropbox/cleaned files/HPI_changeyoy"
drop if _merge==2
drop _merge

// Merging the Text Variables
merge m:1 rssd9001 quarter using "$dropbox/cleaned files/RIE_data_final"
drop if _merge==2
drop _merge

// Merging Last Call Report Dates

merge 1:1 rssd9001 quarter using "$dropbox/cleaned files/dates"
drop if _merge==2
drop _merge

save "$dropbox/work files/sample", replace

*******************************************************************************************************************
*******************************************************************************************************************
******************************  C: Regressions and Figures - Published Paper    ***********************************
*******************************************************************************************************************
*******************************************************************************************************************


clear all
global dropbox "/Users/joaogranja/Dropbox (Personal)/Regulatory Leniency and Accounting Restatements"
cd "$dropbox/Final Results"

use "$dropbox/Data/work files/sample", clear

// 1) Labeling the main variables

label var FedReg "Federal Regulator"
label var b "Regulatory Leniency Index"
label var totass "Total Assets"
label var totdep "Total Deposits"
label var resishare "Residential Loans/Total Loans"
label var creshare "CRE Loans/Total Loans"
label var cshare "Consumer Loans/Total Loans"
label var nplratio "Nonperforming Loans/Total Loans"
label var oreo_ratio "Other Real Estate Owned Ratio"
label var commit_ratio "Unused Commitment Ratio"
label var negrestat "Negative Restatement"
label var posrestat "Positive Restatement"


*****************************************************************
*****************************************************************
// Descriptive Statistics
*****************************************************************
*****************************************************************

************************
* Table 1, Panel A: Summary Statistics
**********************

// Step 1: Run main regression to guarantee that I provide descriptives of the set of observations that I use in the main regression
gen lnassets = ln(totass)
gen lndep = ln(totdep)
global d lnassets lndep resishare cshare creshare nplratio oreo_ratio commit_ratio
areg negrestat b $d i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)


// Panel A:
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist FedReg b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

************************
* Table 1, Panel B: Summary Statistics of State-Chartered Banks and Federal-Chartered Banks
**********************

// Summary Statistics of Federal-Chartered Banks

tempfile a 
save `a'

keep if FedReg==1
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives_federal, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

// Summary Statistics of State-Chartered Banks
use `a', clear

areg negrestat b $d i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
keep if FedReg==0
mat B = (0,0,0,0,0,0)
mat colnames B=Count Mean St.Dev. p25 p50 p75
foreach var of varlist b totass totdep resishare creshare cshare nplratio oreo_ratio commit_ratio wellcap negrestat posrestat{
preserve
collapse (count) N = `var'  (mean) mean = `var' (sd) StDev=`var' (p25) p25 = `var' (p50) p50 = `var' (p75) p75 = `var' if e(sample)
mkmat _all, matrix(A)
mat B = B\A
restore
}
outtable using descriptives_state, mat(B) replace nobox center f(%9.0fc %15.3fc %15.3fc %12.3fc %12.3fc %12.3fc )

use `a', clear
tempfile r 
save `r'
************************
* Table 1, Panel C: Summary Statistics of Restatements by Type
**********************

********************************
// Creating the Negative Restatement by Category Variables

foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	gen `var'_negrestat = `var' * negrestat
	gen `var'_pctnegrestat = `var' * pct_negrestat
}

******************************
label var error_negrestat "Error Restatement"
label var principle_negrestat "Principle Restatement"
label var tax_negrestat "Tax Restatement"
label var audit_negrestat "Audit Restatement"
label var accounting_negrestat "Accounting Restatement"
********************************

drop if text==""
foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	replace `var'_pctnegrestat = . if `var'_pctnegrestat==0
}
collapse audit_negrestat tax_negrestat accounting_negrestat loanloss_negrestat secport_negrestat noncurrent_negrestat consolidation_negrestat error_negrestat principle_negrestat audit tax accounting error principle loanloss secport noncurrent consolidation audit_pctnegrestat tax_pctnegrestat accounting_pctnegrestat error_pctnegrestat principle_pctnegrestat loanloss_pctnegrestat secport_pctnegrestat noncurrent_pctnegrestat consolidation_pctnegrestat
foreach var of varlist audit tax accounting error principle loanloss secport noncurrent consolidation{
	gen `var'_share = `var'_negrestat/`var'
}

****
* Reshaping the dataset

local a error principle audit tax loanloss secport noncurrent consolidation accounting
foreach b of local a{
	preserve
	keep `b'*
		drop `b'_negrestat
		rename `b'_share share_neg
		rename `b' percent
		rename `b'_pctnegrestat pctnegrestat
		gen type = "`b'"
		tempfile `b'_temp
		save ``b'_temp'
		restore
	}
**********
use `error_temp', clear
local c principle audit tax loanloss secport noncurrent consolidation accounting
	foreach d of local c{
	append using ``d'_temp'
}

replace type  = "Error Restatements" if type=="error"
replace type  = "Principle Restatements" if type=="principle"
replace type  = "Tax Restatements" if type=="tax"
replace type  = "Audit Restatements" if type=="audit"
replace type  = "Loan Loss Accounting Restatements" if type =="loanloss"
replace type = "Securities Portfolio Restatements" if type=="secport"
replace type = "Noncurrent Items Restatements" if type=="noncurrent"
replace type = "Consolidation Accounting Restatements" if type=="consolidation"
replace type = "Other Accrual Accounting Restatements" if type=="accounting"
order type percent share_neg pctnegrestat

foreach var of varlist percent share_neg pctnegrestat{
replace `var' = `var'*100
}
mkmat percent share_neg pctnegrestat, matrix(b) rown(type)
mat colnames b= "\%_Restatements" "ShareNegativeRestatements" "AverageAmount" 
outtable using "PanelCTable2", mat(b) replace nobox center f(%12.2fc %12.2fc %12.2fc)


************************
* Table 2: Likelihood of Negative Restatement
**********************

use `r', clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

// Setting up the Panel Setting
tsset rssd9001 quarter

// Defining a balanced set of observations across all specifications must delete observations with missing data on our main explanatory variables
foreach var of varlist totass totdep resishare creshare cshare nplratio{
	drop if `var' == .
	}

// Table 2)
global c
areg negrestat b $c i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons replace bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep
areg negrestat b $c i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)	
	
global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
areg negrestat b $c i.quarter i.FedReg if quarter>163 , absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg negrestat b $c  i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(NegRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)	

global c	
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
areg posrestat b $c i.FedReg i.quarter if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg posrestat b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b $c  ///
	using Table2.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Positive Restatement") ctitle(PosRestat) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

************************
* Table 3: Likelihood of Negative Restatement: Timing Analysis
**********************	

sum lastyr_av_ted, de
replace lastyr_av_ted = (lastyr_av_ted - `r(mean)')/`r(sd)'
label var lastyr_av_ted "Past TED Spread"

sum nextyr_av_ted, de
replace nextyr_av_ted = (nextyr_av_ted - `r(mean)')/`r(sd)'
label var nextyr_av_ted "Future TED Spread"

global c totass totdep resishare cshare creshare nplratio oreo_ratio wellcap commit_ratio
areg negrestat b c.b#c.lastyr_av_ted $c i.FedReg if quarter>163 , absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.lastyr_av_ted $c  ///
	using Table3.tex, ///
	tex nocons replace bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(High HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

areg negrestat b c.b#c.nextyr_av_ted $c i.FedReg if quarter>163 , absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.nextyr_av_ted $c  ///
	using Table3.tex, ///
	tex nocons  bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(High HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)
	
sum HPI_yoy_change,de
replace HPI_yoy_change = (HPI_yoy_change - `r(mean)')/`r(sd)'
	
sum HPI_pastchange,de
replace HPI_pastchange = (HPI_pastchange - `r(mean)')/`r(sd)'
 	
global c totass totdep resishare cshare creshare nplratio oreo_ratio wellcap commit_ratio
areg negrestat b c.b#c.HPI_yoy_change HPI_yoy_change  $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.HPI_yoy_change HPI_yoy_change $c  ///
	using Table3.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(Low HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)		

areg negrestat b c.b#c.HPI_pastchange HPI_pastchange $c  i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 negrestat b c.b#c.HPI_pastchange HPI_pastchange $c  ///
	using Table3.tex, ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(Low HPI Change) addtext(Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)			
	
*****************************************************************
** TABLE 4: Likelihood of Call Report Amendment
*****************************************************************	

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio wellcap
gen late = diffcalldate > 45 if diffcalldate!=. // This means that call date is 15 days past the last day of the quarter
areg late b $c  i.quarter i.FedReg if quarter>163 , absorb(county) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4) replace  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">15 days", Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg late b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">15 days", Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

// Results with dates call Report
replace late = diffcalldate > 75 if diffcalldate!=. // This means that call date is 45 days past the last day of the quarter
areg late b $c   i.quarter i.FedReg if quarter>163, absorb(county) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">45 days", Quarter Fixed-Effects?, Yes, County Fixed-Effects, Yes, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, No)

areg late b $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
	outreg2 late b $c  ///
	using Table4.tex,  ///
	tex nocons bdec(4)tdec(4)  title ("Likelihood of Negative Restatement") ctitle(amend) addtext(Number of late days?, ">45 days", Quarter Fixed-Effects?, No, County Fixed-Effects, No, Regulator Fixed-Effects, Yes, Quarter/County Fixed-Effects, Yes)

*****************************************************************
** FIGURE 1: Magnitude of Accounting Restatements
*****************************************************************		

use "$dropbox/Data/work files/sample", clear
gen restatement_qinc = (pct_negrestat*riskeqcapital)/qinc

replace restatement_qinc = restatement_qinc*100
eqprhistogram restatement_qinc if restatement_qinc<0 & qinc>0 & restatement_qinc>-200, bin(10) ///
	xlabel(-200(25)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Quarterly Earnings", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Quarterly Earnings", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(5.5 -200 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_earnings, replace)
	graph export eqprhist_restatement_earnings.pdf, replace

replace pct_negrestat = pct_negrestat*100
eqprhistogram pct_negrestat if pct_negrestat<0 & pct_negrestat>-1, bin(10) ///
	xlabel(-1(.125)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Risk-Weighted Assets", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Risk-Weighted Assets (in percentage points)", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(12 -1 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_rwassets, replace)
	graph export eqprhist_restatement_rwassets.pdf, replace

gen restatement_allowance = ((pct_negrestat*riskeqcapital)/ALLL)
eqprhistogram restatement_allowance if pct_negrestat<0 & restatement_allowance>-100, bin(10) ///
	xlabel(-100(25)0, labsize(vsmall)) ylab(, nogrid labsize(small)) ///
	title("Equal Probability Histogram: Restatement as % of Allowance for Loan Losses", size(small)) 		///
	fi(inten70) fcolor(maroon) lcolor(maroon)	bsty(none)	 yscale(off)	///
	xtitle("Restatement Amount as a % of Allowance for Loan Losses", size(vsmall))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("Density", size(small)) graphregion(color(white)) bgcolor(white) 	///
	xscale(noex lw(medthick)) ///
	text(.15 -98 "", place(se) si(vsmall) orientation(vertical)) ///
	saving(eqprhist_restatement_allowance, replace)
	graph export eqprhist_restatement_allowance.pdf, replace

*****************************************************************
** FIGURE 2: Percentage of Negative and Positive Restatements over Time
*****************************************************************		

use "$dropbox/Data/work files/sample",clear
tostring rssd9999, replace force
gen year = substr(rssd9999, 1, 4)
destring year, replace force
collapse negrestat posrestat, by(year)
drop if year<2001
tsset year
replace negrestat = negrestat*100
replace posrestat = posrestat*100
twoway ///
		(tsline negrestat posrestat, lpattern(dash))  ///
, title("Percentage of Banks with Regulatory Accounting Restatements", size(small)) xlabel(2001(2)2010, val labsize(small)) ylab(0 "0%" 2 "2%"  4 "4%" 6 "6%" 8 "8%" 10 "10%" 12 "12%", labsize(vsmall)) ///
xtitle("Year", size(small)) ytitle("% Restatements", size(small)) graphregion(color(white)) bgcolor(white) note("") legend(lab(1 "% Negative Restatements") lab(2 "% Positive Restatements") size(small)) saving(tseries, replace)
graph export tseries.pdf, replace

*****************************************************************
** FIGURE 3: Regulatory Accounting Restatements and Regulatory Leniency
*****************************************************************		

use "$dropbox/Data/work files/sample",clear

preserve
collapse (mean) negrestat posrestat b, by(county FedReg)
drop if negrestat==.
egen two = count(county), by (county)
drop if two!=2
drop two

egen fedmeanrestatv1 = max(negrestat) if FedReg==1, by(county)
egen fedmeanrestat = max(fedmeanrestatv1), by(county)
egen fedposmeanrestatv1 = max(posrestat) if FedReg==1, by(county)
egen fedposmeanrestat = max(fedposmeanrestatv1), by(county)


fastxtile btiles = b if FedReg==0, nquantiles(5)
label var btiles "Index Bins"

	
collapse (mean) negrestat fedmeanrestat posrestat fedposmeanrestat (sem) semnegrestat = negrestat semposrestat = posrestat semfednegrestat = fedmeanrestat semfedposrestat = fedposmeanrestat, by(btiles FedReg)
gen ubnegrestat = negrestat + 1.65*semnegrestat
gen lbnegrestat = negrestat - 1.65*semnegrestat
gen ubposrestat = posrestat + 1.65*semposrestat
gen lbposrestat = posrestat - 1.65*semposrestat
gen ubfednegrestat = fedmeanrestat + 1.65*semfednegrestat
gen lbfednegrestat = fedmeanrestat - 1.65*semfednegrestat
gen ubfedposrestat = fedposmeanrestat + 1.65*semfedposrestat
gen lbfedposrestat = fedposmeanrestat - 1.65*semfedposrestat

drop in 6/7

twoway ///
	(connected negrestat btiles if FedReg==0, lpattern(solid)) ///
	(rcap ubnegrestat lbnegrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))		legend(off)				///
	title("Percentage of Income-Decreasing Restatements by Leniency Index Quintile (State Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))										///
	ytitle("% Income-Decreasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.02(0.005).05, labsize(vsmall))	///
	saving(leniencybins, replace)
	graph export leniencybins.pdf, replace

twoway ///
	(connected posrestat  btiles if FedReg==0, lpattern(solid))										///
	(rcap ubposrestat lbposrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))			legend(off)				///
	title("Percentage of Income-Increasing Restatements by Regulatory Leniency Quintile (State Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))												///
	ytitle("% Income-Increasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.005(0.005).04, labsize(vsmall))	///
	saving(posleniencybins, replace)
	graph export posleniencybins.pdf, replace
	
twoway ///
	(connected fedmeanrestat btiles if FedReg==0, lpattern(solid))										///
	(rcap ubfednegrestat lbfednegrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))	legend(off)					///
	title("Percentage of Income-Decreasing Restatements by Regulatory Leniency Quintile (National Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(small))										///
	ytitle("% Income-Decreasing Restatements", size(small)) graphregion(color(white)) bgcolor(white) ylab(.01(0.005).045, labsize(vsmall))	///
	saving(fednegleniencybins, replace)
	graph export fednegleniencybins.pdf, replace

twoway ///
	(connected fedposmeanrestat btiles if FedReg==0, lpattern(solid))										///
	(rcap ubfedposrestat lbfedposrestat btiles if FedReg==0, lcolor(gs0) lw(thin) )										///
	, xlabel(1(1)5, val labsize(small))		legend(off)					///
	title("Percentage of Income-Increasing Restatements by Regulatory Leniency Quintile (National Banks)", size(small))								///
	xtitle("Regulatory Leniency Index Bin", size(vsmall))										///
	ytitle("% Income-Increasing Restatements", size(vsmall)) graphregion(color(white)) bgcolor(white) ylab(0(0.005).035, labsize(small))	///
	saving(fedposleniencybins, replace)
	graph export fedposleniencybins.pdf, replace
restore

*****************************************************************
** FIGURE 4: Regulatory Leniency and the Likelihood of Restatements by Quarter
*****************************************************************

use "$dropbox/Data/work files/sample",clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

global c totass totdep resishare cshare creshare nplratio oreo_ratio commit_ratio 


areg negrestat c.b#i.quarter $c i.FedReg if quarter>163, absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(thin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas, replace)
	graph export betas.pdf, replace

*****************************************************************
** FIGURE 5: Regulatory Leniency and the Likelihood of Restatements by Quarter: Heterogeneity across CRE Lending Specialization
*****************************************************************
	
use "$dropbox/Data/work files/sample",clear

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

preserve
sum creshare if quarter>163, de
tempvar hi_cre
gen `hi_cre' = creshare>`r(p50)' if creshare!=.

areg negrestat c.b#i.quarter $c i.FedReg if quarter>163 & `hi_cre'==1 , absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(vvthin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	title("High CRE Concentration Banks", size(small))								///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas_highcre, replace)
	graph export betas_highcre.pdf, replace
restore

preserve
sum creshare if quarter>163, de
tempvar hi_cre
gen `hi_cre' = creshare>`r(p50)' if creshare!=.


areg negrestat c.b#i.quarter $c i.FedReg if quarter>163 & `hi_cre'==0 , absorb(cnty_qt) vce(cluster reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..40]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..40]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.96
gen uu = A + sterror*1.96

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)40{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq

twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(vvthin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)203, labsize(vsmall) angle(60)) ylab(-0.5(0.1).2, nogrid labsize(small)) ///
	title("Low CRE Concentration Banks", size(small))								///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	text(-0.45 -17.85 "Vertical bands represent 1.96 +/- St. Error of each point estimate", place(se) si(vsmall)) ///
	saving(betas_lowcre, replace)
	graph export betas_lowcre.pdf, replace
restore
	
*****************************************************************
** FIGURE 6: Regulatory Leniency and the Timeliness of Loan Loss Provisions during the Financial Crisis
*****************************************************************			

// This is going to be the Merging File
use "$dropbox/Data/cleaned files/regmaster", clear

// Merging the Financial Characteristics Variables
merge 1:1 rssd9001 quarter using "$dropbox/Data/cleaned files/char"
drop _merge
egen rssd92001 = mode(rssd9200), by(rssd9001)
replace rssd9200 = rssd92001 if rssd9200==""
drop rssd92001

egen rssd92001 = mode(reg_state), by(rssd9001)
replace reg_state = rssd92001 if reg_state==.
drop rssd92001

egen fr = mode(FedReg), by(rssd9001)
replace FedReg = fr if FedReg==. 
drop fr

egen cnty = mode(county), by(rssd9001)
replace county = cnty if county==.
drop cnty
drop cnty_qt
egen cnty_qt = group(county quarter)
 
//Merging the Bank Regulatory Index
merge m:1 rssd9200 using "$dropbox/Data/cleaned files/alst_cross_states"
replace b = 0 if FedReg==1 & b!=.
drop _merge


tsset rssd9001 quarter
gen prov_ratio = prov_qrt/tot_loans
gen coratio =  CO_qrt/tot_loans
gen ALLLratio = riad3123/tot_loans

winsor2 prov_ratio coratio ALLLratio, replace cuts(2.5 97.5) trim

winsor2 totass, replace cuts(1 99) 
replace totass=ln(totass)
replace totdep=ln(totdep)

global c totass totdep resishare creshare oreo_ratio commit_ratio cshare wellcap

// 4 Leads and 4 Lags

preserve
areg prov_ratio c.b#i.quarter f1.coratio f2.coratio f3.coratio coratio l.coratio l2.coratio l3.coratio l4.coratio $c i.FedReg  if quarter>163, absorb(cnty_qt) vce(cl reg_state)
putexcel set "regcoefs.xls", replace
matrix A1 = e(b)
matrix A1 = A1[1,1..46]
matrix A1 = A1'
matrix B1 = vecdiag(e(V))
matrix B1 = B1[1,1..46]
matrix B1 = B1'

putexcel A1=matrix(A1)
putexcel B1=matrix(B1)

import excel "regcoefs.xls", sheet("Sheet1") clear
gen sterror = (B^.5)
gen ll = A - sterror*1.645
gen uu = A + sterror*1.645

// Creating Quarter Variable
gen quarter = .
foreach num of numlist 1(1)46{
	replace quarter = `num' + 163 in `num'
}
format quarter %tq
twoway ///
	(rcap ll uu quarter, lcolor(gs6) lw(thin) )										///
	(scatter A quarter, m(circle_hollow) mcolor(gs2))														///
	, xlabel(164(2)209, labsize(vsmall) angle(60)) ylab(-0.005(0.0025).005, nogrid labsize(small)) ///
	xtitle("Quarter", size(small))				yline(0, lcolor(gs5)) legend(off)								///
	ytitle("", size(small)) graphregion(color(white)) bgcolor(white) 	///
	ttext( -.004 166 "Vertical bands represent +/- 1.96 * St. Error of each point estimate", place(se) si(vsmall))  ///
	saving(betas_prov, replace)
	graph export betas_prov.pdf, replace
restore
log close

