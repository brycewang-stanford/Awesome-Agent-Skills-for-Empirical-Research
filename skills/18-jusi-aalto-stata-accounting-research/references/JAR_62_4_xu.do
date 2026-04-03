********************************************************************************
********************************************************************************
* 			    		Replication files for 							       *
*	  	 News Bias in Financial Journalists' Social Networks				   *
*					 	   by Guosong Xu									   *
********************************************************************************

**********************************************
* 0. Instructions
**********************************************

/*
Before running this do-file:

1. Read "Readme" file for overview and information on data sources.
2. Adjust the current directory.
*/

**********************************************
* 1. Prepare folders
**********************************************

* Set folder path
cd	"INSERT FOLDER PATH"

* Stata version
version 17

* Output files will be saved in a subfolder named "Output"

**********************************************
* 2. Load ado files
**********************************************

// cap ssc install tsegen
// cap ssc install estout
// cap ssc install winsor
// cap ssc install winsor2
// cap ssc install reghdfe
// cap ssc install outreg2
// probit2 ado can be installed via https://www.kellogg.northwestern.edu/faculty/petersen/htm/papers/se/probit2.ado
// fffind ado can be downloaded and installed through https://drive.google.com/drive/folders/1siOpyI0hiF7B4GTRzO2TEAtoi97kmLgh

**********************************************
* 3. Sample and variable construction
**********************************************

do "1_SampleAndVariables.do"

**********************************************
* 4. Panel data analysis and summary 
*    Tables 1 - 3
**********************************************

do "2_PanelDataAnalysis.do"

**********************************************
* 5. Cross-sectional data analysis 
*    Tables 4 - 7
**********************************************

do "3_CrossSectionalAnalysis.do"

**********************************************
* 6. Figures
**********************************************

do "4_Figures.do"

cd "`c(pwd)'"
clear all
set more off

********************************************************************************
* Clean up raw sdc data to create panel and cross-sectional datasets
********************************************************************************

// Clean up sdc data 
          
use ../NP/sdc.dta , clear
format anncdate %tdCYND
g anncyear = year(anncdate)
g anncym = mofd(anncdate)
g anncyq = qofd(anncdate)
g acqcusip6 = string(real(v201),"%06.0f")
replace acqcusip6 = v201 if acqcusip6=="."
g acqcusip8 = acqcusip6 + "10"
g acqsic4 = string(real(v99),"%04.0f")
g tgtsic4 = string(real(v159),"%04.0f")
destring acqsic4, g(acqsic4_destring)
destring tgtsic4, g(tgtsic4_destring)
ffind acqsic4_destring , newvar(acqffind48) type(48)
ffind tgtsic4_destring , newvar(tgtffind48) type(48)

save ../sdc_cs.dta

// Merge with bidder CRSP and Compustat identifiers:

use ../NP/permnogvkey.dta

g acqcusip8 = substr(cusip,1,8)
bysort acqcusip8 LPERMNO: egen start_permno=min(LINKDT)
bysort acqcusip8 LPERMNO: egen end_permno=max(LINKENDDT)
bysort acqcusip8 gvkey: egen start_gvkey=min(LINKDT)
bysort acqcusip8 gvkey: egen end_gvkey=max(LINKENDDT)
format start_permno start_gvkey end_permno end_gvkey %td

save ../permnogvkey_use.dta

bysort acqcusip8 LPERMNO: keep if _n==1
save ../permnolink.dta

use ../permnogvkey_use.dta, clear

bysort acqcusip8 gvkey: keep if _n==1
save ../gvkeylink.dta

use ../sdc_cs.dta, clear
keep acqcusip8
duplicates drop
sort acqcusip8
save ../tempuse.dta

use ../permnolink.dta, clear
sort acqcusip8
merge m:1 acqcusip8 using ../tempuse
keep if _merge==3  

sort acqcusip8 start_permno	
gen permno1=LPERMNO
gen start1_permno=start_permno
gen end1_permno=end_permno
bysort acqcusip8: gen permno2=LPERMNO[_n+1]
bysort acqcusip8: gen start2_permno=start_permno[_n+1]
bysort acqcusip8: gen end2_permno=end_permno[_n+1]
bysort acqcusip8: gen permno3=LPERMNO[_n+2]
bysort acqcusip8: gen start3_permno=start_permno[_n+2]
bysort acqcusip8: gen end3_permno=end_permno[_n+2]
bysort acqcusip8: gen permno4=LPERMNO[_n+3]
bysort acqcusip8: gen start4_permno=start_permno[_n+3]
bysort acqcusip8: gen end4_permno=end_permno[_n+3]

keep acqcusip8 permno1 start1 end1 permno2 start2_permno end2_permno permno3 start3_permno end3_permno permno4 start4_permno end4_permno
by acqcusip8: keep if _n==1
sort acqcusip8
save ../tempusepermno.dta

use ../gvkeylink.dta, clear
sort acqcusip8
merge m:1 acqcusip8 using ../tempuse
keep if _merge==3
keep gvkey acqcusip8
sort acqcusip8
save ../tempusegvkey.dta

** START MERGING
use ../sdc_cs.dta, clear
sort acqcusip8
merge m:1 acqcusip8 using ../tempusepermno
drop _merge

gen sm1 = mofd(start1_permno)
gen sm2 = mofd(start2_permno)
gen sm3 = mofd(start3_permno)
gen sm4 = mofd(start4_permno)
gen em1 = mofd(end1_permno)
gen em2 = mofd(end2_permno)
gen em3 = mofd(end3_permno)
gen em4 = mofd(end4_permno)
g mergeym = ym(anncyear-1,12)
gen acqpermno_0 = permno1 if permno1!=. & permno2==.
replace acqpermno_0 = permno1 if acqpermno_0==. & mergeym>=sm1 & mergeym<=em1
replace acqpermno_0 = permno2 if acqpermno_0==. & mergeym>=sm2 & mergeym<=em2 & permno2!=.
replace acqpermno_0 = permno3 if acqpermno_0==. & mergeym>=sm3 & mergeym<=em3 & permno3!=.
replace acqpermno_0 = permno4 if acqpermno_0==. & mergeym>=sm4 & mergeym<=em4 & permno4!=.
drop mergeym permno1 start1 end1 permno2 start2 end2 permno3 start3 end3 permno4 start4 end4 sm* em*

save,replace

// Check unmatched cusips and cusips that correspond to multiple permnos in raw data if necessary


use ../sdc_cs.dta, clear
sort acqcusip8
merge m:1 acqcusip8 using ../tempusegvkey
drop _merge
rename gvkey gvkey_0
save,replace

// Check unmatched cusips and cusips that correspond to multiple gvkeys in raw data if necessary


erase ../gvkeylink.dta
erase ../permnolink.dta
erase ../permnogvkey_use.dta
erase ../tempuse.dta
erase ../tempusegvkey.dta
erase ../tempusepermno.dta


// Merge target CRSP:
use ../sdc_cs.dta, clear
sort v19
merge 1:1 v19 using ../NP/add_tgt_permno.dta
drop _merge
save,replace

clear all

// Get stock data
use ../NP/crsp.dta, clear
g acqmktcap4d = PRC*SHROUT/1000 // mktcap in $M
rename PERMNO acqpermno
sort acqpermno date
keep acqpermno date acqmktcap4d
save ../usemktcap.dta

use ../sdc_cs.dta, clear
g date = anncdate-4
keep v19 acqpermno date
sort acqpermno date
save ../tempuse.dta
merge m:1 acqpermno date using ../usemktcap
drop if _merge==2
drop _merge
rename acqmktcap4d acqmktcap4d_main
** When anncdate-4 cannot be matched to a CRSP date, replace it with the earliest matchable market cap

keep v19 acqmktcap4d_main
rename acqmktcap4d_main acqmktcap4d
save,replace

use ../sdc_cs.dta, clear
sort v19
merge 1:1 v19 using ../tempuse
drop _merge
save,replace
erase ../tempuse.dta
erase ../usemktcap.dta


// Get Compustat data:
use ../NP/compustat.dta ,clear
keep gvkey fyear at ceq mkvalt dlc dltt ch che ni city state
drop if at==.
sort gvkey fyear 
save ../usecompustat.dta

use ../sdc_cs.dta, clear
g fyear = anncyear-1
sort gvkey fyear 
merge m:1 gvkey fyear using ../usecompustat
drop if _merge==2
drop _merge
save,replace

// Check missing values. If possible, replace missing MKVALT with crsp data
erase ../usecompustat.dta


// CONSTRUCT POOLED SAMPLE
use ../Manual/j_wsj.dta , clear
g media="wsj"   // media indicator
save ../pool.dta
use ../Manual/j_ft.dta , clear
g media="ft"   // media indicator
save ../ft.dta
use ../Manual/j_pr.dta , clear
g media="pr"   // media indicator
save ../pr.dta

use ../pool.dta, clear
append using ../ft.dta
append using ../pr.dta
tostring firstauthorid ,gen(firstauthorid_adj)
replace firstauthorid_adj = media + firstauthorid_adj
save,replace

sort v19
merge m:1 v19 using ../Manual/j_twitterfollows.dta 
drop if _merge==2
g connecttwitter = connecttwitter_wsj if media=="wsj"
replace connecttwitter = connecttwitter_ft if media=="ft"
drop connecttwitter_wsj connecttwitter_ft _merge
replace connecttwitter=0 if connecttwitter==. & (media=="wsj"|media=="ft")

sort v19
merge m:1 v19 using ../Manual/to.dta 
drop if _merge==2
g to = toall_wsj if media=="wsj"
replace to = toall_ft if media=="ft"
drop toall_wsj toall_ft _merge
g netneg = negative - positive
bysort firstauthorid_adj: egen joutone = mean(negative) if firstauthorid_adj!="" 
sort v19 media
merge 1:1 v19 media using ../Manual/j_wordcount-all.dta 
drop if _merge==2
drop _merge
sort v19 media
merge 1:1 v19 media using ../Manual/j_tfidf.dta 
drop if _merge==2
drop _merge
sort v19
merge m:1 v19 using ../Manual/j_target_connect.dta  
drop if _merge==2
g connectrep_tgt = connectrep_wsjtgt if media=="wsj"
replace connectrep_tgt = connectrep_fttgt if media=="ft"
drop  connectrep_wsjtgt connectrep_fttgt _merge

// label all variables:
lab var negative "Negative slant"
lab var connectreport "CONNECT_WORK"
lab var connectuni "CONNECT_UNIVERSITY"
lab var connecttwitter "CONNECT_TWITTER"
lab var connectcity "Local journalist"
lab var joufem "Female"
lab var avgworkex "Tenure"
lab var expert "Industry expert"
lab var to "Turnover (promotion)"
lab var quote "Quotes of CEOs"
lab var numpct "Use of numbers (%)"
lab var uncertainty "Use of uncertainty words (%)"
lab var modalweak "Use of weak modal words (%)"

save,replace
erase ../pr.dta
erase ../ft.dta

// CONSTRUCT CROSS-SECTIONAL SAMPLE 
use ../Manual/j_wsj.dta , clear
rename connectuni connectuni_wsj
rename connectcity connectcity_wsj
rename positive positive_wsj
rename negative negative_wsj
rename joufem joufem_wsj
rename avgworkex avgworkex_wsj
rename connectreport connectreport_wsj
rename expert expert_wsj
rename newsdate newsdate_wsj
rename office office_wsj
rename firstauthorid firstauthorid_wsj
rename frontpage frontpage_wsj
drop wordcount litigious modalmoderate modalstrong constraining numcount singleauthor uncertainty modalweak numpct
sort v19
save ../usewsj.dta

use ../Manual/j_ft.dta , clear
rename connectuni connectuni_ft
rename connectcity connectcity_ft
rename positive positive_ft
rename negative negative_ft
rename joufem joufem_ft
rename avgworkex avgworkex_ft
rename connectreport connectreport_ft
rename expert expert_ft
rename newsdate newsdate_ft
rename office office_ft
rename firstauthorid firstauthorid_ft
drop wordcount litigious modalmoderate modalstrong constraining numcount singleauthor uncertainty modalweak numpct
sort v19
save ../useft.dta

use ../Manual/j_twitterfollows.dta , clear

use ../sdc_cs.dta, clear
sort v19
merge 1:1 v19 using ../usewsj 
drop _merge
merge 1:1 v19 using ../useft 
drop _merge
merge 1:1 v19 using ../Manual/j_twitterfollows.dta 
replace connecttwitter_wsj=0 if connecttwitter_wsj==.
replace connecttwitter_ft=0 if connecttwitter_ft==.
drop _merge
save,replace
erase ../useft.dta
erase ../usewsj.dta

********************************************************************************
* Construct deal and firm level variables
********************************************************************************

use ../sdc_cs.dta, clear

g relative = dealval/acqmktcap4d
g toehold = v175-v176
replace toehold = 0 if toehold==.|toehold<0
g hostile = (v270=="Hostile")
g unsolicited = (v270=="Unsolic.")
g diversify = (acqffind48!=tgtffind48)
g payment = v22
replace payment=0 if v22==.
g payment_cash = (v22==100)
g payment_stock = (v24==100)
g withdrawn = (v178=="Withdrawn")
g completed = (withdrawn==0)
g fprc = (premium4w/100 +1)*v191
g pctchg = fprc/initialofferprc-1
g posrev = (pctchg>.001)
replace posrev=0 if pctchg==.
g logat = log(at)
g q = (at-ceq+mkvalt)/at
g lev = (dlc+dltt)/(at-ceq+mkvalt)
g cash = che/at
g profitability = ni/at
winsor relative, g(wrelative) p(0.005)
winsor logat, g(wlogat) p(0.005)
winsor q, g(wq) p(0.005)
winsor lev, g(wlev) p(0.005)
winsor cash, g(wcash) p(0.005)
winsor profitability, g(wprofitability) p(0.005)
g compt = (v213!="")
save,replace

// get board data
use ../Manual/c_firm.dta , clear
sort v19
save ../useboard.dta
use ../sdc_cs.dta, clear
sort v19
merge 1:1 v19 using ../useboard
drop _merge
save,replace
erase ../useboard.dta

g cover_wsj = (newsdate_wsj!=.)
g cover_ft = (newsdate_ft!=.)
save,replace

// Construct past-year mean daily return
use ../sdc_cs.dta, clear

bysort acqpermno : gen eventcount=_N
bysort acqpermno : keep if _n==1
rename acqpermno PERMNO
keep PERMNO eventcount
sort PERMNO 
save ../tempuse

use ../NP/crsp.dta , clear
save ../mastercrsp.dta
sort PERMNO 
merge m:1 PERMNO using ../tempuse
drop if _merge==2
expand eventcount 
drop eventcount _merge
sort PERMNO date
by PERMNO date: gen set=_n
sort PERMNO set
save ../expanded   

use ../sdc_cs.dta, clear
rename acqpermno PERMNO
bysort PERMNO: gen set=_n
keep v19 anncdate PERMNO set
sort PERMNO set
save ../tempuse2

use ../expanded , clear
merge m:1 PERMNO set using ../tempuse2
keep if _merge==3
drop _merge

keep if date>=anncdate-365 & date<=anncdate-1
bysort v19: egen meanret_1y = mean(RET)
bysort v19: keep if _n==1
keep v19 meanret_1y
sort v19
save,replace  

use ../sdc_cs.dta, clear
sort v19
merge 1:1 v19 using ../expanded
drop _merge
winsor meanret_1y, g(wmeanret_1y) p(0.005)
save,replace

erase ../mastercrsp.dta
erase ../expanded.dta
erase ../tempuse.dta
erase ../tempuse2.dta

// get returns (from WRDS ES suite)
use ../NP/essuite.dta
sort v19
save ../cars.dta
use ../sdc_cs.dta, clear
sort v19
merge 1:1 v19 using ../cars 
drop _merge
save,replace
erase ../cars.dta

// get analyst, institutional ownership, illiquidity data
use ../NP/detail.dta
gen yq = qofd(anndats)
bysort cusip yq analys : keep if _n==1
bysort cusip yq : g numa = _N
bysort cusip yq : keep if _n==1
keep cusip yq numa
drop if cusip==""
rename cusip acqcusip8
sort acqcusip8 yq
save ../useana.dta

use ../sdc_cs.dta, clear
g yq = anncyq-1
sort acqcusip8 yq
merge m:1 acqcusip8 yq using ../useana
drop if _merge==2
drop _merge       
replace numa=0 if numa==.
save,replace
erase ../useana.dta


use ../NP/ts13f.dta
gen yq = qofd(fdate)
drop if cusip==""
bysort cusip yq : egen insshare = total(shares)
g instown_pct = insshare/1000000/shrout1
bysort cusip yq : keep if _n==1
keep cusip yq instown_pct
replace instown_pct=1 if instown_pct>1
rename cusip acqcusip8
format yq %tq
sort acqcusip8 yq
save ../usets.dta

use ../sdc_cs.dta, clear
replace yq = anncyq-1
sort acqcusip8 yq
merge m:1 acqcusip8 yq using ../usets
drop if _merge==2
drop _merge       

// manual check if instown_pct has multiple entries in the using dataset.
replace instown_pct=0 if instown_pct==.

save , replace
erase ../usets.dta

// get turnovers 
sort v19
merge 1:1 v19 using ../Manual/to.dta
drop _merge

save,replace

// label all variables:
lab var negative_wsj "Negative slant (%)"
lab var connectreport_wsj "CONNECT_WORK"
lab var connectuni_wsj "CONNECT_UNIVERSITY"
lab var connecttwitter_wsj "CONNECT_TWITTER"
lab var connectcity_wsj "Local journalist"
lab var joufem_wsj "Female"
lab var avgworkex_wsj "Tenure"
lab var expert_wsj "Industry expert"
lab var dealval "Absolute deal size"
lab var wrelative "Relative deal size"
lab var toehold "Toehold (%)"
lab var hostile "Hostile"
lab var unsolicited "Unsolicited"
lab var diversify "Cross-industry"
lab var payment "Financing (cash)"
lab var payment_cash "Cash payment"
lab var payment_stock "Stock payment"
lab var instown_pct "Institutional ownership"
lab var numa "# Analysts"
lab var wlogat "Firm size"
lab var wq "Tobin's Q"
lab var wlev "Firm leverage"
lab var wcash "Firm cash"
lab var wprofitability "Firm profitability"
lab var ceoage "CEO age"
lab var dual "CEO duality"
lab var classified "Classified board"
lab var wwsjcar01 "CAR[0,1]"
lab var wwsjcar240 "CAR[2,40]"
lab var wwsjcar040 "CAR[0,40]"
lab var wcar_complete "CAR[-1,complete]"
lab var toall_wsj "Turnover"
lab var illiq3m "Amihud illiquidity"
lab var frontpage "Front-page"
lab var compt "Competing bids"
lab var posrev "Bid price upward revision"
lab var completed "Bidding success"

save,replace

********************************************************************************
* Construct second-degree connections (companies of directors)
********************************************************************************

use ../sdc_cs.dta, clear
sort gvkey
merge m:1 gvkey using ../NP/add_gvkeyBoardex_link.dta  
drop if _merge==2
drop _merge
save,replace

keep gvkey companyid anncyear 
bysort gvkey anncyear: keep if _n==1  
drop if companyid==.
sort companyid anncyear
save ../usedeals.dta

use ../NP/BoardEx_Committees.dta, clear
g anncyear = year(AnnualReportDate)
sort companyid anncyear
merge m:1 companyid anncyear using ../usedeals 
keep if _merge==3
drop _merge
drop if BrdPosition=="Inside" // drop inside directors
bysort companyid anncyear DirectorID: keep if _n==1
save ../director_network.dta
erase ../usedeals.dta

** From BoardEx Ind_Employment database, identify all companies that directors work for.
** Because each director can work for multiple companies, there is no one-to-one match
** to the acquirer firm when the M&A is announced. To identify the main employer of the
** director at the time of the M&A, manually check the position of the director company 
** using the position of the director in the employer firm. The general procedure of
** identifying directors' companies is as follows. After the manual check, save the main
** employer of the director at the time of the M&A as director_main.dta.
/*
use ../NP/BoardEx_Ind_Employment.dta, clear
keep if RowType=="Listed Organisations"
keep if NED=="No" // keep if the director is an executive of the company
drop if BrdPosition=="Outside" 
bysort DirectorID CompanyID: egen startdate=min(DateStartRole)
bysort DirectorID CompanyID: egen enddate=min(DateEndRole)
format startdate enddate %td
bysort DirectorID CompanyID: keep if _n==1
keep DirectorID CompanyName CompanyID startdate enddate
// manual check of the main employer of directors if multiple matches exist
save ../Manual/director_main.dta   
*/

use ../director_network.dta
sort  DirectorID companyid anncyear
merge 1:1 DirectorID companyid anncyear using ../Manual/director_main.dta   
keep if _merge==3
drop _merge 
save,replace 

use ../director_network.dta
sort gvkey anncyear
merge m:1 gvkey anncyear using ../Manual/j_connectnames_year.dta
keep if _merge==3
drop _merge
save,replace  

rename CompanyID DirectorCompanyID
tostring(DirectorCompanyID anncyear),replace
g DirectorComYearID_temp = anncyear+DirectorCompanyID
gen DirectorComYearID = string(real(DirectorComYearID_temp),"%011.0f") // generate ID to be matched with news article dataset
drop DirectorComYearID_temp
destring(DirectorCompanyID anncyear),replace 

bysort DirectorComYearID: keep if _n==1
keep anncyear DirectorCompanyID connectreport_connectname1 connectreport_connectname2 connectreport_connectname3 connectreport_connectname4 connectuni_connectname1 connecttwitter_connectname1_wsj connectreport_connectname1_ft connectreport_connectname2_ft connectreport_connectname3_ft connectuni_connectname1_ft connecttwitter_connectname1_ft DirectorComYearID
sort DirectorComYearID
save ../director_journconnection.dta 

// CREATE PEER FIRM POOLED DATASET:
use ../NP/peerfirm_pool.dta, clear
g DirectorComYearID = substr(filename,1,11)  
sort DirectorComYearID
merge m:1 DirectorComYearID using ../director_journconnection.dta
* get connected journalist names for each directorCompany-year 
keep if _merge==3
drop _merge
* generate variable: connection to acquirer's friends:
g connect_acqfriend_work =            (author1==connectreport_connectname1 & author1!="" & connectreport_connectname1!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author1==connectreport_connectname2 & author1!="" & connectreport_connectname2!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author1==connectreport_connectname3 & author1!="" & connectreport_connectname3!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author1==connectreport_connectname4 & author1!="" & connectreport_connectname4!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname1 & author2!="" & connectreport_connectname1!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname2 & author2!="" & connectreport_connectname2!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname3 & author2!="" & connectreport_connectname3!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname4 & author2!="" & connectreport_connectname4!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname1 & author3!="" & connectreport_connectname1!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname2 & author3!="" & connectreport_connectname2!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname3 & author3!="" & connectreport_connectname3!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname4 & author3!="" & connectreport_connectname4!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname1 & author4!="" & connectreport_connectname1!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname2 & author4!="" & connectreport_connectname2!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname3 & author4!="" & connectreport_connectname3!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname4 & author4!="" & connectreport_connectname4!="" & media=="wsj")
replace connect_acqfriend_work = 1 if (author1==connectreport_connectname1_ft & author1!="" & connectreport_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author1==connectreport_connectname2_ft & author1!="" & connectreport_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author1==connectreport_connectname3_ft & author1!="" & connectreport_connectname3_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname1_ft & author2!="" & connectreport_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname2_ft & author2!="" & connectreport_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author2==connectreport_connectname3_ft & author2!="" & connectreport_connectname3_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname1_ft & author3!="" & connectreport_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname2_ft & author3!="" & connectreport_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author3==connectreport_connectname3_ft & author3!="" & connectreport_connectname3_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname1_ft & author4!="" & connectreport_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname2_ft & author4!="" & connectreport_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_work = 1 if (author4==connectreport_connectname3_ft & author4!="" & connectreport_connectname3_ft!="" & media=="ft")
g connect_acqfriend_uni =            (author1==connectuni_connectname1 & author1!="" & connectuni_connectname1!="" & media=="wsj")
replace connect_acqfriend_uni = 1 if (author2==connectuni_connectname1 & author2!="" & connectuni_connectname1!="" & media=="wsj")
replace connect_acqfriend_uni = 1 if (author3==connectuni_connectname1 & author3!="" & connectuni_connectname1!="" & media=="wsj")
replace connect_acqfriend_uni = 1 if (author4==connectuni_connectname1 & author4!="" & connectuni_connectname1!="" & media=="wsj")
replace connect_acqfriend_uni = 1 if (author1==connectuni_connectname1_ft & author1!="" & connectuni_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author1==connectuni_connectname2_ft & author1!="" & connectuni_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author2==connectuni_connectname1_ft & author2!="" & connectuni_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author2==connectuni_connectname2_ft & author2!="" & connectuni_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author3==connectuni_connectname1_ft & author3!="" & connectuni_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author3==connectuni_connectname2_ft & author3!="" & connectuni_connectname2_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author4==connectuni_connectname1_ft & author4!="" & connectuni_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_uni = 1 if (author4==connectuni_connectname2_ft & author4!="" & connectuni_connectname2_ft!="" & media=="ft")
g connect_acqfriend_twitter =            (author1==connecttwitter_connectname1_wsj & author1!="" & connecttwitter_connectname1_wsj!="" & media=="wsj")
replace connect_acqfriend_twitter = 1 if (author2==connecttwitter_connectname1_wsj & author2!="" & connecttwitter_connectname1_wsj!="" & media=="wsj")
replace connect_acqfriend_twitter = 1 if (author3==connecttwitter_connectname1_wsj & author3!="" & connecttwitter_connectname1_wsj!="" & media=="wsj")
replace connect_acqfriend_twitter = 1 if (author4==connecttwitter_connectname1_wsj & author4!="" & connecttwitter_connectname1_wsj!="" & media=="wsj")
replace connect_acqfriend_twitter = 1 if (author1==connecttwitter_connectname1_ft & author1!="" & connecttwitter_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_twitter = 1 if (author2==connecttwitter_connectname1_ft & author2!="" & connecttwitter_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_twitter = 1 if (author3==connecttwitter_connectname1_ft & author3!="" & connecttwitter_connectname1_ft!="" & media=="ft")
replace connect_acqfriend_twitter = 1 if (author4==connecttwitter_connectname1_ft & author4!="" & connecttwitter_connectname1_ft!="" & media=="ft")

g connect_acqfriend = (connect_acqfriend_work==1|connect_acqfriend_uni==1|connect_acqfriend_twitter==1)

// label all variables:
lab var negative "Negative slant"
lab var connect_acqfriend "CONNECT_Indirect" 
lab var directconnect "CONNECT_Direct"
lab var connectcity "Local journalist"
lab var joufem "Female"
lab var avgworkex "Tenure"
lab var expert "Industry expert"

save ../peerfirm_pool2.dta

erase ../director_journconnection.dta
erase ../director_network.dta

********************************************************************************
* Construct accounting fraud news pooled sample
********************************************************************************

use ../Manual/fraud_article.dta, clear
sort gvkey fyear
merge m:1 gvkey fyear using ../NP/fraud_compustat.dta
keep if _merge==3
drop _merge
g mkvalt = prcc_f*csho
g logat = log(at)
g q = (at-ceq+mkvalt)/at
g lev = (dlc+dltt)/(at-ceq+mkvalt)
g cash = che/at
g profitability = ni/at

// label all variables:
lab var negative "Negative slant"
lab var connectreport "CONNECT_WORK"
lab var connectuni "CONNECT_UNIVERSITY"
lab var connectcity "Local journalist"
lab var joufem "Female"
lab var avgworkex "Tenure"
lab var expert "Industry expert"
lab var logat "Firm size"
lab var wordcount "Word count"
lab var q "Tobin's Q"
lab var lev "Firm leverage"
lab var cash "Firm cash"
lab var profitability "Firm profitability"

save ../fraudnews.dta

********************************************************************************
* Construct daily CAR for event study
********************************************************************************

use ../NP/car_daily.dta , clear 
g date_temp = substr(uid,7,9)
g newsdate_wsj = date(date_temp,"DMY")
format newsdate_wsj %td
drop date_temp
keep permno newsdate_wsj evtdate evttime abret
sort permno newsdate_wsj
save ../car_plot

use ../sdc_cs.dta, clear
keep if cover_wsj==1
bysort acqpermno newsdate_wsj: keep if _n==1
keep acqpermno newsdate_wsj connectreport_wsj 
rename acqpermno permno
sort permno newsdate_wsj
save ../tempuse.dta

use ../car_plot.dta, clear
merge m:1 permno newsdate_wsj using ../tempuse
drop _merge
winsor2 abret,  cuts(5 95) by(evttime)
sort permno evtdate evttime
by permno evtdate: g car=abret_w if _n==1
by permno evtdate: replace car=abret_w +car[_n-1] if _n>1
g relative=evttime+11
save,replace
********************************************************************************
* Regressions on panel dataset
********************************************************************************

cd "`c(pwd)'"
clear all
set more off

*-----TABLE 1. SUMMARY STATS------*
use ../sdc_cs.dta, clear

replace dealval=dealval/1000 // in billion
// WSJ
estpost summarize negative_wsj connectreport_wsj connectuni_wsj connecttwitter_wsj connectcity_wsj joufem_wsj avgworkex_wsj expert_wsj dealval wrelative toehold hostile unsolicited diversify payment instown_pct numa wlogat wq wlev wcash wprofitability ceoage dual classified if cover_wsj==1,meanonly
esttab using ../Output/SumStat1.xls,replace cells("count mean sd p50") label title(Table 1:Summary statistics)
//FT
estpost summarize negative_ft connectreport_ft connectuni_ft connecttwitter_ft connectcity_ft joufem_ft avgworkex_ft expert_ft dealval wrelative toehold hostile unsolicited diversify payment instown_pct numa wlogat wq wlev wcash wprofitability ceoage dual classified if cover_ft==1 & ceoage!=. & office_ft!="",meanonly
esttab using ../Output/SumStat2.xls,replace cells("count mean sd p50") label title(Table 1:Summary statistics)

clear

	
*-----	  TABLE 2	  ------*
*-----    PANEL A.    ------*
use ../pool.dta, clear

reghdfe negative connectreport connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T2A.xml, excel keep(connectreport connectuni connecttwitter connectcity joufem avgworkex expert ) stats(coef se) bdec(3) sdec(3) addtext(Deal FE, YES, Media outlet FE, YES, Journalist FE, NO) append label
reghdfe negative connectreport connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media firstauthorid_adj) cluster(v19) 
outreg2 using ../Output/T2A.xml, excel keep(connectreport connectuni connecttwitter connectcity joufem avgworkex expert ) stats(coef se) bdec(3) sdec(3) addtext(Deal FE, YES, Media outlet FE, YES, Journalist FE, YES) append label
reghdfe negative connectuni connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T2A.xml, excel keep(connectreport connectuni connecttwitter connectcity joufem avgworkex expert ) stats(coef se) bdec(3) sdec(3) addtext(Deal FE, YES, Media outlet FE, YES, Journalist FE, NO) append label
reghdfe negative connectuni connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media firstauthorid_adj) cluster(v19) 
outreg2 using ../Output/T2A.xml, excel keep(connectreport connectuni connecttwitter connectcity joufem avgworkex expert ) stats(coef se) bdec(3) sdec(3) addtext(Deal FE, YES, Media outlet FE, YES, Journalist FE, YES) append label
reghdfe negative connecttwitter connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T2A.xml, excel keep(connectreport connectuni connecttwitter connectcity joufem avgworkex expert ) stats(coef se) bdec(3) sdec(3) addtext(Deal FE, YES, Media outlet FE, YES, Journalist FE, NO) append label
reghdfe negative connecttwitter connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media firstauthorid_adj) cluster(v19) 
outreg2 using ../Output/T2A.xml, excel keep(connectreport connectuni connecttwitter connectcity joufem avgworkex expert ) stats(coef se) bdec(3) sdec(3) addtext(Deal FE, YES, Media outlet FE, YES, Journalist FE, YES) append label

   
*-----  PANEL B.  ------*
ivreghdfe negative (connectreport=to) joutone if (media=="wsj"|media=="ft"), a(v19 media) cluster(v19) first
outreg2 using ../Output/T2B.xml, excel keep(connectreport  ) stats(coef se) bdec(3) sdec(3) addtext(Controls, NO, Deal FE, YES, Media outlet FE, YES) append label
ivreghdfe negative (connectreport=to) connectcity joufem avgworkex expert joutone if (media=="wsj"|media=="ft"), a(v19 media) cluster(v19) first
outreg2 using ../Output/T2B.xml, excel keep(connectreport  ) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label

clear


*-----	  TABLE 3	 ------*
*-----    PANEL A.   ------*

use ../pool.dta, clear

reghdfe quote connectreport connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe quote connectuni connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19)
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label 
reghdfe quote connecttwitter connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe numpct connectreport connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe numpct connectuni connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe numpct connecttwitter connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe uncertainty connectreport connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe uncertainty connectuni connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe uncertainty connecttwitter connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe modalweak connectreport connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe modalweak connectuni connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label
reghdfe modalweak connecttwitter connectcity joufem avgworkex expert if (media=="wsj"|media=="ft"),  absorb(v19 media) cluster(v19) 
outreg2 using ../Output/T3A.xml, excel keep(connectreport connectuni connecttwitter) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Deal FE, YES, Media outlet FE, YES) append label

clear


*-----    PANEL B.    ------*
use ../peerfirm_pool2.dta

reghdfe negative connect_acqfriend connectcity joufem avgworkex expert ,  absorb(CompanyArticleymID media) cluster(CompanyArticleymID) 
outreg2 using ../Output/T3B.xml, excel keep(connect_acqfriend) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Firm x Year-month FE, YES, Media outlet FE, YES) append label
reghdfe negative connect_acqfriend directconnect connectcity joufem avgworkex expert ,  absorb(CompanyArticleymID media) cluster(CompanyArticleymID) 
outreg2 using ../Output/T3B.xml, excel keep(connect_acqfriend directconnect) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Firm x Year-month FE, YES, Media outlet FE, YES) append label

clear


*-----    PANEL C.    ------*
use ../fraudnews.dta

reghdfe negative connectreport connectcity joufem avgworkex expert logat wordcount q lev cash profitability if (media=="ft"|media=="wsj") ,a(gvkey media) cluster(gvkey)
outreg2 using ../Output/T3C.xml, excel keep(connectreport connectuni) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Fiem FE, YES, Media outlet FE, YES) append label
reghdfe negative connectuni connectcity joufem avgworkex expert logat wordcount q lev cash profitability if (media=="ft"|media=="wsj") , a(gvkey media) cluster(gvkey)
outreg2 using ../Output/T3C.xml, excel keep(connectreport connectuni) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Fiem FE, YES, Media outlet FE, YES) append label

clear



cd "`c(pwd)'"
clear all
set more off


********************************************************************************
* Regressions on cross-sectional dataset
********************************************************************************

*-------   TABLE 4	 -------*

use ../sdc_cs.dta, clear

reghdfe wwsjcar01 connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T4.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar01 connectuni_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T4.xml, excel keep(connectuni_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar01 connecttwitter_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T4.xml, excel keep(connecttwitter_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
xi:ivreg2 wwsjcar01 (connectreport_wsj=toall_wsj) wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48 ,cluster(acqffind48 anncyear) 
outreg2 using ../Output/T4.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label

clear


*-------   TABLE 5	--------*
*-----     PANEL A. --------*

use ../sdc_cs.dta, clear

reghdfe wwsjcar01 i.connectreport_wsj##c.numa wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified ,a(anncyear acqffind48) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T5A.xml, excel keep(i.connectreport_wsj##c.numa) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar01 i.connectreport_wsj##c.wlogat wrelative toehold hostile unsolicited diversify payment_cash payment_stock wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T5A.xml, excel keep(i.connectreport_wsj##c.wlogat) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar01 i.connectreport_wsj##c.instown_pct wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T5A.xml, excel keep(i.connectreport_wsj##c.instown_pct) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar01 i.connectreport_wsj##c.illiq3m wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified ,a(anncyear acqffind48 ) cluster(anncyear acqffind48) 
outreg2 using ../Output/T5A.xml, excel keep(i.connectreport_wsj##c.illiq3m) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar01 i.connectreport_wsj##i.frontpage wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48 ) cluster(acqffind48 anncyear) 
outreg2 using ../Output/T5A.xml, excel keep(i.connectreport_wsj##i.frontpage) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
  
*-----     PANEL B. --------*
reghdfe wwsjcar01 connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48 ) cluster(anncyear acqffind48) 
outreg2 using ../Output/T5B.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES) append label
reghdfe wwsjcar240 connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48 ) cluster(anncyear acqffind48) 
outreg2 using ../Output/T5B.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
reghdfe wwsjcar040 connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48 ) cluster(anncyear acqffind48) 
outreg2 using ../Output/T5B.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
reghdfe wcar_complete connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified,a(anncyear acqffind48 ) cluster(anncyear acqffind48) 
outreg2 using ../Output/T5B.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label

clear


*-------   TABLE 6	--------*

use ../sdc_cs.dta, clear
   
xi:probit2 compt connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48,fcluster(acqffind48) tcluster(anncyear) 
outreg2 using ../Output/T6.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
// Pseudo R2 can be obtained by running the same specification with Stata "probit" command without the cluster option
xi:ivreg2 compt (connectreport_wsj=toall_wsj) wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48 ,cluster(acqffind48 anncyear)
outreg2 using ../Output/T6.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
xi:probit2 posrev connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48 ,fcluster(acqffind48) tcluster(anncyear)
outreg2 using ../Output/T6.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
// Pseudo R2 can be obtained by running the same specification with Stata "probit" command without the cluster option
xi:ivreg2 posrev (connectreport_wsj=toall_wsj) wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48 ,cluster(acqffind48 anncyear)
outreg2 using ../Output/T6.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
xi:probit2  completed connectreport_wsj wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48,fcluster(acqffind48) tcluster(anncyear)
// Pseudo R2 can be obtained by running the same specification with Stata "probit" command without the cluster option
outreg2 using ../Output/T6.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label
xi:ivreg2 completed (connectreport_wsj=toall_wsj) wrelative toehold hostile unsolicited diversify payment_cash payment_stock wlogat wq wlev wcash wprofitability ceoage dual classified i.anncyear i.acqffind48 ,cluster(acqffind48 anncyear)
outreg2 using ../Output/T6.xml, excel keep(connectreport_wsj) stats(coef se) bdec(3) sdec(3) addtext(Controls, YES, Year FE, YES, Industry FE, YES ) append label

clear


*-------   TABLE 7	--------*

use ../Manual/journalist_list.dta, clear

reghdfe changebeat connect_alltypes male tenure logpub journalism ,  absorb(office wsj) vce(robust)
outreg2 using ../Output/T7.xml, excel keep(connect_alltypes male tenure logpub journalism wsj) stats(coef se) bdec(3) sdec(3) addtext(Location FE, YES, Media outlet FE, YES) append label
reghdfe quit_media connect_alltypes male tenure logpub journalism ,  absorb(office wsj) vce(robust)
outreg2 using ../Output/T7.xml, excel keep(connect_alltypes male tenure logpub journalism wsj) stats(coef se) bdec(3) sdec(3) addtext(Location FE, YES, Media outlet FE, YES) append label
reghdfe quit_jnsm connect_alltypes male tenure logpub journalism ,  absorb(office wsj) vce(robust) 
outreg2 using ../Output/T7.xml, excel keep(connect_alltypes male tenure logpub journalism wsj) stats(coef se) bdec(3) sdec(3) addtext(Location FE, YES, Media outlet FE, YES) append label
reghdfe exit_ind connect_alltypes male tenure logpub journalism ,  absorb(office wsj) vce(robust) 
outreg2 using ../Output/T7.xml, excel keep(connect_alltypes male tenure logpub journalism wsj) stats(coef se) bdec(3) sdec(3) addtext(Location FE, YES, Media outlet FE, YES) append label
reghdfe exit_connectind connect_alltypes male tenure logpub journalism ,  absorb(office wsj) vce(robust) 
outreg2 using ../Output/T7.xml, excel keep(connect_alltypes male tenure logpub journalism wsj) stats(coef se) bdec(3) sdec(3) addtext(Location FE, YES, Media outlet FE, YES) append label

clear

   
cd "`c(pwd)'"
clear all
set more off

use ../sdc_cs.dta, clear

*-----FIGURE 1------*
bysort anncyear: gen sdc_deal = _N
bysort anncyear: egen wsj_deal = total(cover_wsj)
bysort anncyear: egen ft_deal = total(cover_ft)
bysort anncyear: keep if _n==1
keep anncyear sdc_deal wsj_deal ft_deal

save figure1.dta
graph bar (mean) sdc_deal (mean) wsj_deal (mean) ft_deal, ///
	over(anncyear, label(angle(vertical))) bar(1, fcolor(white) lcolor(black)) ///
	bar(2, fcolor(black) lcolor(black)) bar(3, fcolor(gray) ///
	lcolor(black)) graphregion(fcolor(white) lcolor(none))

// change lable names and save

clear all



*------ FIGURE 2 DAILY CAR --------*
use ../car_plot.dta, clear
reg  car ib0.relative##i.connectreport, robust

coefplot , vert drop(_cons *.relative 1.connectreport 0.connectreport 0.relative#0.connectreport) xline(11) yline(0,lcolor(gray)) baselevels levels(95) recast(line ) ciopts(recast(rarea) color(navy%30)) xtitle("Days relative to WSJ publication")  ytitle("Cumulative abnormal stock return")rename(1.relative#1.connectreport=-10 2.relative#1.connectreport=-9 3.relative#1.connectreport=-8 4.relative#1.connectreport=-7 5.relative#1.connectreport=-6 6.relative#1.connectreport=-5 7.relative#1.connectreport=-4 8.relative#1.connectreport=-3 9.relative#1.connectreport=-2 10.relative#1.connectreport=-1 11.relative#1.connectreport=0 12.relative#1.connectreport=1 13.relative#1.connectreport=2 14.relative#1.connectreport=3 15.relative#1.connectreport=4 16.relative#1.connectreport=5 17.relative#1.connectreport=6 18.relative#1.connectreport=7 19.relative#1.connectreport=8 20.relative#1.connectreport=9 21.relative#1.connectreport=10 22.relative#1.connectreport=11 23.relative#1.connectreport=12 24.relative#1.connectreport=13 25.relative#1.connectreport=14 26.relative#1.connectreport=15 27.relative#1.connectreport=16 28.relative#1.connectreport=17 29.relative#1.connectreport=18 30.relative#1.connectreport=19 31.relative#1.connectreport=20 32.relative#1.connectreport=21 33.relative#1.connectreport=22 34.relative#1.connectreport=23 35.relative#1.connectreport=24 36.relative#1.connectreport=25 37.relative#1.connectreport=26 38.relative#1.connectreport=27 39.relative#1.connectreport=28 40.relative#1.connectreport=29 41.relative#1.connectreport=30 42.relative#1.connectreport=31 43.relative#1.connectreport=32 44.relative#1.connectreport=33 45.relative#1.connectreport=34 46.relative#1.connectreport=35 47.relative#1.connectreport=36 48.relative#1.connectreport=37 49.relative#1.connectreport=38 50.relative#1.connectreport=39 51.relative#1.connectreport=40) ylabel(-0.02(.01)0.02 ) graphregion(fcolor(white) lcolor(none))

// edit figure layout and save

clear all
