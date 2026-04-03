
*=====================================================================================================

*   Article: Did the Dodd-Frank Whistleblower Provision Deter Accounting Fraud? 
*   Author: Philip G. Berger and Heemin Lee
*   Journal: Journal of Accounting Research (2022)

*   This STATA-do file compiles various datafiles, converts them into our final 
*   datasets, and performs the main statistical analyses in Berger and Lee (2022).   
    
*=====================================================================================================
clear all
set more off
set matsize 11000

global main "C:\Users\hmlee\Dropbox\_Research\Whistleblowing\Data"
local outdir "C:\Users\hmlee\Dropbox\_Research\Whistleblowing\Tables" 


*===================================================================================

*                          Part A. Sample Construction 

*===================================================================================


*=======================================================================
*   Step A.1 Import Compustat data and define key variables
*=======================================================================

use "$main\rawdata\compustat" , clear
keep if inlist(exchg,11,12,13,14,19)
keep if loc== "USA"
drop if state==""
drop if inlist(state,"GU","VI","PR")
sort gvkey tic fyear
bysort gvkey: egen nn=nvals(tic)
drop if tic==""
 
gen yeardd = year(datadate)
gen mondd = month(datadate)
replace yeardd = yeardd-1 if mondd<6
replace fyear = yeardd if fyear==.  

destring gvkey, replace
bysort gvkey fyear: gen n1=_n
keep if n1==1
replace cusip=substr(cusip,1,8)
  
  
*** Calculate  F-score ***
tsset gvkey fyear

*Average total assets
gen avg_at = (L.at+at)/2
gen wc = act-che-(lct-dlc)
gen nco2 = at-act-ivao-(lt-lct-dltt)
gen fin = (ivst+ivao)-(dltt+dlc+pstkl)

*RSST accruals 
gen rsst_acc= (D.wc+D.nco2+D.fin)/avg_at

*Change in receivables 
gen ch_rec = D.rect/avg_at

*Change in inventory 
gen ch_inv = D.invt/avg_at

*% soft assets 
gen soft_assets = (at-ppent-che)/at

*Change in cash sales-check 
gen ch_cs_raw = sale-D.rect
gen ch_cs = D.ch_cs_raw/L.ch_cs_raw

*Change in return on assets
gen ch_roa = ib/avg_at-L.ib/L.avg_at

*Actual issuance 
gen issue = 0
replace issue = 1 if sstk>0 | dltis>0 

*Calculate F-score : Model 1 from Dechow, Ge, Larson, and Sloan (2011)
gen pred = -7.893+0.79*rsst_acc+2.518*ch_rec+1.191*ch_inv+1.979*soft_assets+0.171*ch_cs+(-0.932)*ch_roa+1.029*issue 
gen prob1 = exp(pred)/(1+exp(pred))
gen ucond = 0.0037
gen Fscore = prob1/ucond


*** Calculate control variables ***  
gen inds_sic2=substr(sic,1,2)
gen inds_sic3=substr(sic,1,3)
destring inds_sic2, replace
destring inds_sic3, replace

gen size = ln(at)
gen ln_mcap = ln(prcc_f*csho)  
gen loss = (ib+L.ib<0)

*Foreign exchange income (loss) is not zero
gen foreign = (fca!=0)
replace foreign = 0 if fca ==.

*Acquisition/merger 
gen merger = (D.aqp !=0)
replace merger = 0 if aqp ==.

*Discontinued operations
gen discont = (do !=0 )

*Restructure
gen restructure = (rcp !=. )
replace restructure =0 if rcp ==0

*MTB and LEV
gen mtb = (prcc_f*csho)/ceq
gen lev= (lct+lt)/at
 
*Free Cash Flow
gen freeCF = (oancf -capx )/L.at

*Net issuance 
gen netfin = 0
replace netfin =1 if sstk-prstkc>0 | dltis-dltr>0

*ROA
gen ROA = ib/L.at
 
*Big4
gen big4=0
replace big4 =1 if  inlist(au,"4","5","6","7")
 * "Ernst & Young"=4, "Deloitte & Touche"=5, "KPMG"=6 ,"PricewaterhouseCoopers"=7

*Auditor tenure 
bysort cusip au (fyear): gen Autenure=_n 

*Industry sales growth (Cassell, Myers, Myers, and Seidel, 2016)
bysort inds_sic2 fyear: egen ind2_sales = sum (revt)
tsset gvkey fyear
gen ind2_growth = ind2_sales/L.ind2_sales

*Sales volatility 
gen rev_s = revt/L.at
bysort tic: asrol rev_s, stat(sd) win(fyear 3) gen(StdRev3)

*Inventory and receivables to assets ratio
gen inv_rec = (invt+ rect)/at

*Quick ratio
gen quick = (act- invt)/lct

*Long-term debt
gen ltdebt = lt/at

*Three-year standard deviation of ROA
bysort tic: asrol ROA, stat(sd)  win(fyear 3) gen(StdROA)

*One-year sales growth
tsset gvkey fyear
gen growth = (sale-L.sale)/L.sale

rename state hqstate

save "$main\working\compfull", replace

keep tic fyear cusip gvkey cik hqstate fyrc  sic  Fscore pred  lct lt revt invt   ib oiadp   rsst_acc ch_rec ch_inv soft_assets ch_cs ch_roa issue  n1  exchg   size ln_mcap loss foreign merger discont restructure mtb lev   lct freeCF netfin ROA  big4 Autenure  ind2_growth   inds_sic2  inds_sic3 revt at lt ceq  StdRev3 prcc_c prcc_f  csho inv_rec  quick ltdebt StdROA growth  

save "$main\working\comp_fyear2_full", replace




*==================================================================
*   Step A.2 Import state fund ownership data from 13f filings    *
*==================================================================

use "$main\rawdata\statefund.dta", clear

sort cusip mgrno fdate
order cusip mgrno fdate
replace mgrname = proper(mgrname)

gen fyear = year(fdate)
gen fmonth = month(fdate)
keep if fmonth==12

tempfile fund
save `fund'

*Add state funds' information
import excel using "$main\rawdata\statefund_list.xlsx" ,sheet(WRDSdata) firstrow clear 
keep state mgrno
drop if mgrno==.

merge 1:m mgrno using `fund'

drop _merge

save "$main\working\fundlevel.dta", replace


*Merge state funds data with Compustat
use "$main\working\comp_fyear2_full", clear
merge 1:m cusip fyear using "C:\Users\hmlee\Dropbox\1_Whistleblower\_Journal\Journal_2nd\JAR_submission\RR\Round2\data\fundlevel.dta"

drop if _merge==2

save "$main\working\fundComp_full_fyear2", replace


*===============================================
*   Step A.3 Merge with stat FCA information   *
*===============================================

use  "$main\working\fundComp_full_fyear2", clear

destring cik, replace
rename _merge merge_fund

tempfile original
save `original'

import excel using  "$main\rawdata\StateFCA_table.xlsx" ,sheet(BR_stata) firstrow clear 

merge 1:m state using `original'

drop if _merge==1
gen own_dum = (_merge==3) 
rename _merge merge_fca


*** Define Healthcare and Financial industries ***

*Healthcare industry dummy
gen health = (inds_sic2 == 80) 
replace health =1 if inds_sic3 == 283
  *Drugs
replace health =1 if inds_sic3 == 384
  *Surgical, Medical, Dental instrument sullplies
replace health =1 if sic == "5047"
  *Medical supplies

*Finance industry dummy
gen finind = 0
replace finind =1 if inds_sic2 >=60  & inds_sic2<= 67

gen adoption = 0
replace adoption =1 if fyear >=passed

gen GenFCA =0
gen MedFCA = 0
replace GenFCA = 1 if  strpos(falseclaims, "General") & strpos(quitam, "yes")
replace MedFCA = 1 if  strpos(falseclaims, "Medicaid")& strpos(quitam, "yes")
gen postG = GenFCA*adoption
gen postM = MedFCA*adoption


*** Define key variables for state FCA analysis ***
bysort cusip fyear: egen own_t = max(own_dum)

egen ffID = group(mgrno cusip)

bysort ffID (fyear): gen own_t1 = own_dum[_n-1]
replace own_t1 = 0 if own_t1==.
 
gen  ownt1XpostG = own_t1*postG
gen  ownt1XpostM = own_t1*postM
  
bysort cusip fyear : egen FCAg = max(ownt1XpostG)
bysort cusip fyear : egen FCAm = max(ownt1XpostM) 
bysort cusip fyear:  egen SH_dum= max(own_t1)
 
egen firmN = group(cusip)

*Create fund state dummies 
xi, prefix(i) noomit i.state  
forval i = 1/22 {
  replace istate_`i' = 0 if istate_`i'==.
  bysort cusip fyear: egen d_state`i'=max(istate_`i')
 }

*Create fund dummies 
xi, prefix(i) noomit i.mgrname  
forval i = 1/32 {
   replace imgrname_`i' = 0 if imgrname_`i'==.
   bysort cusip fyear: egen d_fund`i'=max(imgrname_`i')
 }


save "$main\working\fundComp_full_fyear2_before shrink_full.dta", replace


*================================================
*   Step A.4 Turn the data to firm-year level   *
*================================================

use "$main\working\fundComp_full_fyear2_before shrink_full.dta", clear

drop if cik ==. 

*Market value of assets held by funds 
gen mv_invt =prc * shares 
replace mv_invt = 0 if mv_invt ==.

*Dollar holdings in the lagged year 
bysort ffID (fyear): gen usdf_lag = mv_invt[_n-1]
replace usdf_lag = 0 if usdf_lag ==. 

gen fUSDxFCAg = usdf_lag*postG
gen fUSDxFCAm = usdf_lag*postM

*State with largest holdings in the lagged year
gsort cusip fyear -mv_invt
bysort cusip fyear : gen storder = _n
gen largest = state if storder ==1 & state !=""
bysort cusip fyear : replace largest = largest[_n-1] if missing(largest) & storder > 1

*Total dollar holding  
bysort cusip fyear:  egen ttUSDxFCAg= sum(fUSDxFCAg)
bysort cusip fyear:  egen ttUSDxFCAm= sum(fUSDxFCAm)
bysort cusip fyear:  egen ttUSD= sum(usdf_lag)

*Largest dollar holding state's dollar holding amount
bysort cusip fyear:  egen maxfusd= max(usdf_lag)
bysort cusip fyear:  egen maxUSDxFCAg= max(fUSDxFCAg)
bysort cusip fyear:  egen maxUSDxFCAm= max(fUSDxFCAm)

*Number of states (including hq state) holding the company
bysort cusip fyear: egen N_state=nvals(state)
bysort cusip fyear: egen N_stateFCAg=sum(postG)
bysort cusip fyear: egen N_stateFCAm=sum(postM)
replace N_state = 0 if N_state==.

*Number of funds (including hq state) holding the company
bysort cusip fyear: egen N_fund=sum(SH_dum)
bysort cusip fyear: egen N_fundFCAg=sum(FCAg)
bysort cusip fyear: egen N_fundFCAm=sum(FCAm)

gsort cusip fyear -shares 
bysort cusip fyear  : keep if _n==1

*** Variables of interest ****
gen ln_ttUSDxFCAg = ln(ttUSDxFCAg+1 )  
gen ln_ttUSDxFCAm = ln(ttUSDxFCAm+1 ) 
gen ln_ttUSD = ln(ttUSD +1)  
gen ln_maxUSDxFCAg =ln(maxUSDxFCAg+1 )
gen ln_maxUSDxFCAm =ln(maxUSDxFCAm+1 )
gen ln_maxUSD = ln(maxfusd +1 )  

gen changeG = 0
gen changeM = 0

bysort cusip (fyear) : gen num_yr = _n
replace changeG = 1 if FCAg ==1 & num_yr ==1
replace changeM = 1 if FCAm ==1 & num_yr ==1

*Define FCAgAS and FCAmAS for state FCA analysis
gen FCAgAS = FCAg
gen FCAmAS = FCAm

*For robustness checks, define alternative variables 
bysort cusip (fyear) : replace changeG = FCAg - FCAg[_n-1] if num_yr != 1
bysort cusip (fyear) : replace changeG = -1 if changeG==0 & changeG[_n-1] ==-1 
bysort cusip (fyear) : replace changeM = FCAm - FCAm[_n-1] if num_yr != 1
bysort cusip (fyear) : replace changeM = -1 if changeM==0 & changeM[_n-1] ==-1 

*Method I. Drop all obs after divestment 
gen chG = changeG
gen chM = changeM
bysort cusip (fyear): replace chG = chG[_n-1] if chG[_n-1] == -1
bysort cusip (fyear): replace chM = chM[_n-1] if chM[_n-1] == -1

*Method II. Staying affected after divestment
bysort cusip (fyear): replace FCAg  = 1 if chG == -1
bysort cusip (fyear): replace FCAm  = 1 if chM == -1

tempfile original
save `original'



*================================================
*   Step A.4 Merge with other datasets   *
*================================================

*** Merge with institution ownership data ***
use "$main\rawdata\InstitutionOwn.dta" ,replace

gen fyear = year(rdate)
gen fmonth = month(rdate)
keep if fmonth ==12
keep fyear cusip instown_perc

replace instown_perc =0 if instown_perc ==.
rename instown_perc instown 
replace instown =1 if instown>1
keep cusip fyear instown

merge 1:1 cusip fyear using  `original'

keep if _merge==3
drop _merge
order instown, first

unique tic
unique tic if fyear>=2007 & fyear<=2014
 *34149 obs (6782 firms) in Table 1


*** Merge with segment data ***
merge 1:1 cusip fyear using  "$main\rawdata\fund_segment.dta"
drop if _merge==2
rename _merge merge2

order N_seg, first
tsset gvkey fyear
tsfill
bysort gvkey: carryforward N_seg, gen(N_seg2)
gsort gvkey - fyear
bysort gvkey: carryforward N_seg2, gen(N_seg3)
replace N_seg3 = 1 if N_seg3==.
gen ln_segment = ln(N_seg3)
drop N_seg2
order merge2 ln_segment N_seg3 N_seg, first
drop if cusip==""


*** Merge with audit fees data ***
merge 1:1 cik fyear using  "$main\rawdata\fund_auditfees.dta"
keep if _merge == 3  
gen ln_audfee = ln(audit_fees)
replace audit_fees = audit_fees/1000 
drop  _merge


*** Merge with internal control weaknesses data  ***
merge 1:1 cik fyear using  "$main\rawdata\fund_icw.dta"

gen icw = (count_weak >0)
replace icw = 0 if count_weak ==.
gen icwreport = (_merge ==3)
order count_weak icw icwreport ,first
drop if _merge ==2 
drop sig_date_ic_op_x- _merge

save "$main\working\data_before_final_cleaning_full.dta", replace


*================================================================
*   Step A.5 Delete missing values and winsorize observations   *
*================================================================

use "$main\working\data_before_final_cleaning_full.dta", clear

keep if fyear>=2007 & fyear<=2014
unique tic
 *33517 obs (6609 firms) remaining in Table 1

 
*Drop Healthcare and Financial industries 
drop if health ==1
 *3407 obs (845 firms) dropped 
drop if finind ==1
 *10852 obs (2000 firms) dropped 
unique tic
 *19258 obs (3764 firms) remaining 


*Delete missing values
foreach var in Fscore ln_audfee size mtb lev freeCF ind2_growth StdRev3 inv_rec quick ltdebt StdROA growth ROA instown {
   drop if `var' ==.
   }
   
   
unique tic
 *16372 obs (3345 firms) remaining 
unique tic if fyear>=2008 & fyear<=2014
 *14177 obs (3111 firms) remaining 
unique tic if fyear>=2007 & fyear<=2010
 *8322 obs (2659 firms) remaining 


*Winsorization
foreach var in Fscore mtb lev  freeCF ROA   StdRev3 ind2_growth   inv_rec quick ltdebt growth instown {
	winsor2 `var', replace cuts(1 99)
    }
	

save "$main\working\Sample-selection-winsor.dta", replace



*===================================================================================

*                  Part B. Create Final Datasets for Regression Analyses 

*===================================================================================


*** For Dodd-Frank analysis (2008-2014) ***
use "$main\working\Sample-selection-winsor.dta", clear

keep if fyear>=2008 & fyear <= 2014
unique tic
 *14177 obs (3111 firms) remaining
 
gen SECWB = (fyear>=2011)
egen hqstateN = group(hqstate)

*Define treatment variable
*General FCA
gen treat2 = 1 if fyear<2011
replace treat2 = 0 if FCAgAS ==1 & fyear<2011
bysort cusip : egen treatg2=min(treat2)
gen gTreatXSECWB2 = SECWB*treatg2

*Medicaid FCA
gen treat2m = 1 if fyear<2011
replace treat2m = 0 if FCAmAS ==1 & fyear<2011
bysort cusip : egen treat_fm=min(treat2m)
gen mTreatXSECWB2 = SECWB*treat_fm

*Require firms to have obs from both pre- and post-periods 
bysort cusip: egen both = nvals(SECWB)
keep if both ==2
 *2507 obs (1244 firms) droped  
unique tic
 *11670 obs (1867 firms) remaining 

*Get entropy balanced weights
foreach var in  size mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin {
bysort cusip SECWB: egen premean_`var'=mean(`var') 
}

tempfile EB
save `EB'

bysort cusip (fyear) : gen nth = _n
bysort cusip fyear: keep if nth==1 
ta fyear

ebalance treatg2 size mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin , targets(3)
 *Table 4 Panel C

keep _webal cusip

merge 1:m cusip using `EB'

label var gTreatXSECWB2 "NoFCA_G"  
label var mTreatXSECWB2 "NoFCA_M"  

tempfile DF_sample
save `DF_sample'



*** For Dodd-Frank analysis (2009-2013) ***
use "$main\working\Sample-selection-winsor.dta", clear

keep if fyear>=2009 & fyear <= 2013

gen SECWB = (fyear>=2011)
egen hqstateN = group(hqstate)

*Define treatment variable
*General FCA
gen treat2 = 1 if fyear<2011
replace treat2 = 0 if FCAgAS ==1 & fyear<2011
bysort cusip : egen treatg2=min(treat2)
gen gTreatXSECWB2 = SECWB*treatg2


*Medicaid FCA
gen treat2m = 1 if fyear<2011
replace treat2m = 0 if FCAmAS ==1 & fyear<2011
bysort cusip : egen treat_fm=min(treat2m)
drop if treat_fm==. 
gen mTreatXSECWB2 = SECWB*treat_fm

unique tic
 *9048 obs (2204 firms)

*Require firms to have obs from both pre- and post-periods 
bysort cusip: egen both = nvals(SECWB)
keep if both ==2
  *520 obs deleted
unique tic
  *8528 obs (1835 firms) remaining

*Get entoropy balanced weights
foreach var in  size mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin {
bysort cusip SECWB: egen premean_`var'=mean(`var') 
}

tempfile EB
save `EB'

bysort cusip (fyear) : gen nth = _n
bysort cusip fyear: keep if nth==1 
ta fyear

ebalance treatg2 size mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin , targets(3)
count if _webal==.

keep _webal cusip

merge 1:m cusip using `EB'

label var gTreatXSECWB2 "NoFCA_G"  
label var mTreatXSECWB2 "NoFCA_M"  

tempfile DF_sample_09_13
save `DF_sample_09_13'



*** For state FCA analysis ***
use "$main\working\Sample-selection-winsor.dta", clear

keep if fyear>=2007 & fyear <= 2010
*8322 obs (2659 firms) 

*Require firms to have more than one observation
bysort cusip : gen numobs = _N
drop if numobs==1 
 *452 obs deleted
unique tic 
 *7870 obs (2207 firms) remaining 
 
label var FCAgAS "FCA_G"  
label var FCAmAS "FCA_M"  
label var N_fund "N_FUND"
label var N_fundFCAg "N_FUND_FCAG"
label var N_fundFCAm "N_FUND_FCAM"
label var ln_ttUSDxFCAg "Ln_USD_FCAG"
label var ln_ttUSDxFCAm "Ln_USD_FCAm"
label var ln_maxUSDxFCAg "Ln_MAX_FCAG"
label var ln_maxUSDxFCAm "Ln_MAX_FCAm"
  
tempfile FCA_sample
save `FCA_sample'




*===================================================================================

*                          Part C. Create Tables and Figure 1

*===================================================================================


*=========
*Table 3 
*========= 
use `DF_sample',replace 

asdoc sum treatg2 treat_fm SECWB  Fscore audit_fees at mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ROA  inv_rec quick ltdebt StdROA growth   N_seg3 foreign  Autenure icw, stat(N mean sd p25 p50 p75)  format(%9,3gc) save(Table3.doc)  replace



*=========
*Table 4 
*========= 
*Panel A
use `DF_sample',replace
ssc inst diff, replace
diff Fscore, t(treatg2) p(SECWB)
diff Fscore, t(SECWB) p(treatg2)
ttest size , by(treatg2) level(99) unequal 

*Panel B
gen treatG=1-treatg2
asdoc ttest Fscore, by(treatG) level(99) unequal replace title(t-test Results), save(Table4B) 
foreach var in  audit_fees at mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin {
asdoc ttest `var', by(treatG) level(99) unequal rowappend
}

*Panel C ---> in line 542



*=========
*Table 5 
*========= 
local depvar = "Fscore"

use `DF_sample',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2    , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_5.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
replace  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_5.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample',replace
qui: reghdfe  `depvar'  gTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  [weight=_webal] , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_5.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample_09_13',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_5.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2009-2013)

use `DF_sample_09_13',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   [weight=_webal]  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_5.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2009-2013)




*=========
*Table 6 
*=========
use `FCA_sample',replace

foreach var in ttUSDxFCAg maxUSDxFCAg ttUSDxFCAm maxUSDxFCAm  {
 replace `var' = `var'/1000000
}

asdoc sum  FCAgAS FCAmAS N_fundFCAg N_fundFCAm N_fund ttUSDxFCAg maxUSDxFCAg ttUSDxFCAm maxUSDxFCAm Fscore  audit_fees at   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ROA  inv_rec quick ltdebt StdROA growth   N_seg3 foreign  Autenure icw, stat(N mean sd p25 p50 p75)  format(%9,3gc) save(Table6.doc)   replace




*=========
*Table 7
*=========
local depvar = "Fscore"  

use `FCA_sample',replace
qui:  reghdfe  `depvar'   FCAgAS  size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_7.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
replace  sortvar(  FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'   FCAgAS N_fund size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_7.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'   N_fundFCAg size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_7.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'    ln_ttUSDxFCAg   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_7.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///k
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'    ln_maxUSDxFCAg   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_7.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///k
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)



*=========
*Table 8
*=========
*Panel A
local depvar = "Fscore"

use `DF_sample',replace
qui:  reghdfe  `depvar'  mTreatXSECWB2       , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_8A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
replace  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample',replace
qui:  reghdfe  `depvar'  mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_8A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample',replace
qui:  reghdfe  `depvar'  mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  [weight=_webal] , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_8A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample_09_13',replace
qui:  reghdfe  `depvar'  mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_8A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2009-2013)

use `DF_sample_09_13',replace
qui:  reghdfe  `depvar'  mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  [weight=_webal] , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_8A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2009-2013)



*Panel B
local depvar = "Fscore"

use `FCA_sample',replace
qui:  reghdfe  `depvar'   FCAmAS  size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_8B.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
replace  sortvar(  FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm    size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'   FCAmAS N_fund size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_8B.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm    size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'   N_fundFCAm size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin   ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_8B.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm    size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'    ln_ttUSDxFCAm   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_8B.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm    size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///k
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

use `FCA_sample',replace
qui:  reghdfe  `depvar'    ln_maxUSDxFCAm   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin ,absorb(i.fyear i.firmN ) vce(cluster firmN)
outreg2 using `outdir'/Table_8B.xls,  adjr2  addstat( Number of clusters , `e(N_clust1)')  ///
append  sortvar(  FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm    size   mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin) ///
keep( FCAmAS  N_fund N_fundFCAm    ln_ttUSDxFCAm  ln_maxUSDxFCAm  size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///k
title ("`depvar'") ctitle("`depvar'") ///
addtext( Fixed effects,  Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)




*=========
*Table 9
*=========
*Panel A
local depvar = "ln_audfee"

use `DF_sample',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2     , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
replace  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw    , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  [weight=_webal]  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2008-2014)

use `DF_sample_09_13',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2009-2013)

use `DF_sample_09_13',replace
qui:  reghdfe  `depvar'  gTreatXSECWB2  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw [weight=_webal] , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9A.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( gTreatXSECWB mTreatXSECWB  gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  ) ///
keep( gTreatXSECWB mTreatXSECWB gTreatXSECWB2 mTreatXSECWB2 size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2009-2013)


*Panel B
use `FCA_sample',replace

local depvar = "ln_audfee"
qui:  reghdfe  `depvar'  FCAgAS  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw  if fyear<2011   , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9B.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
replace  sortvar( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   ) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg    size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

qui:  reghdfe  `depvar'  FCAgAS N_fund  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   if fyear<2011  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9B.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   ) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg    size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

qui:  reghdfe  `depvar'  N_fundFCAg  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   if fyear<2011  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9B.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   ) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg    size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

qui:  reghdfe  `depvar'  ln_ttUSDxFCAg  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   if fyear<2011  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9B.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   ) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg    size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)

qui:  reghdfe  `depvar'  ln_maxUSDxFCAg  size loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   if fyear<2011  , absorb(i.fyear i.firmN  ) vce(cluster firmN)
outreg2 using `outdir'/Table_9B.xls, adjr2 addstat( Number of clusters , `e(N_clust)')  ///
append  sortvar( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg   size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   ) ///
keep( FCAgAS  N_fund N_fundFCAg    ln_ttUSDxFCAg  ln_maxUSDxFCAg    size  loss  ROA  inv_rec quick ltdebt StdROA growth  merger ln_segment foreign big4 Autenure icw   )   ///
excel tstat pdec(3) tdec(3) bdec(3) nocon  ///
title ("`depvar'") ctitle("`depvar'") ///
addtext(Fixed effects, Firm & Year ,  Cluster by, Firm ,Sample period, 2007-2010)




*===========
* Figure 1
*=========== 
use `DF_sample',replace

forval i = 2008/2014 {
  gen yr`i' = (fyear ==`i')
 }

foreach x of varlist yr2008-yr2014{ 
 gen trt2X`x' = treatg2*`x'
 }

*Replicate Table 5 Column 3 (Entropy Balanced Model) and save results in coefficient.xlsx. 
reghdfe  Fscore    trt2Xyr2008  trt2Xyr2009  trt2Xyr2011   trt2Xyr2012   trt2Xyr2013   trt2Xyr2014   size  mtb  instown  big4 StdRev3 merger discont restructure ind2_growth lev loss freeCF netfin  [weight=_webal] ,absorb(i.fyear i.firmN ) vce(cluster firmN)  

import excel using  "$main\working\coefficient.xlsx" ,sheet(Fscore) firstrow clear 

graph twoway (scatter coeff year ,msymbol(circle) mcolor(red) msize(medsmall)) (rcap lci uci year, lwidth(vthik) lcolor(gs7)) ,  ylab(-0.5 (0.1) 0.2,labsize(small) ) xlab(2008 (1) 2014,labsize(small))  yline(0, lcolor(gs3) lwidth(thin)) ytitle("Coefficient estimates") xtitle("Year", size(small))legend(label(1 "Point estimate") label(2 "95% CI") size(small) c(1) region(lwidth(thin) color(white)))  graphregion(color(white))






