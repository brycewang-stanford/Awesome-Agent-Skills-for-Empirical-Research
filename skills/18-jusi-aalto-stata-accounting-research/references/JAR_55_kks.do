********************************************************************************************************
*** The Form 5500 Raw data were downloaded from the Center for Retirement Research, Boston College
*** The raw data were downloaded for each year and stored as follows raw5500-YEAR-1.dta
*** This code simply appends all individual files into one large file, covering the period 1999 to 2007
********************************************************************************************************

clear all

set memory 10000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC"

use raw5500-2007-1.dta
gen year = 2007
save raw_2007_all.dta, replace

****************

clear 

use raw5500-2006-1.dta
gen year = 2006
save raw_2006_all.dta, replace


****************

clear 

use raw5500-2005-1.dta
gen year = 2005
save raw_2005_all.dta, replace

****************

clear 

use raw5500-2004-1.dta

gen year = 2004
save raw_2004_all.dta, replace

****************

clear 

use raw5500-2003-1.dta


gen year = 2003
save raw_2003_all.dta, replace

****************

clear 

use raw5500-2002-1.dta

gen year = 2002
save raw_2002_all.dta, replace

****************

clear 

use raw5500-2001-1.dta

gen year = 2001
save raw_2001_all.dta, replace

****************

clear 

use raw5500-2000-1.dta


#delimit cr
gen year = 2000
save raw_2000_all.dta, replace

****************

clear 

use raw5500-1999-1.dta

gen year = 1999
save raw_1999_all.dta, replace


**** no inclusion prior to 1999 due to missing actuarial assumptions

***

clear

use raw_2007_all

append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2006_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2005_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2004_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2003_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2002_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2001_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2000_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_1999_all.dta"



save raw5500_all, replace
**** This file merges the different components of the 2011 Submission to the IRS: Form 5500, Schedule H and Schedule SB

clear all


set memory 2000m

*** form 5500

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest"

insheet using F_5500_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save 5500_2011, replace

*** schedule H
clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2011_Latest"

insheet using F_SCH_H_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save H_2011, replace

*** schedule SB

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2011_Latest"

insheet using F_SCH_SB_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save SB_2011, replace

*** merge datasets

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest"

use 5500_2011


merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2011_Latest/SB_2011"

drop if _merge !=3

drop _merge

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2011_Latest/H_2011"

drop if _merge ==2

drop _merge

gen year = 2011

*** generate ID number of plan

gen str3 PIN = string(spons_dfe_pn, "%03.0f")
gen str9 EIN = string(spons_dfe_ein, "%09.0f")

gen ID = EIN + PIN

sort ID

duplicates drop ID, force

save raw_2011.dta, replace
**** This file merges the different components of the 2012 Submission to the IRS: Form 5500, Schedule H and Schedule SB

clear all

set memory 2000m

*** form 5500

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

insheet using F_5500_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save 5500_2012, replace

*** schedule H
clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2012_Latest"

insheet using F_SCH_H_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save H_2012, replace

*** schedule SB

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2012_Latest"

insheet using F_SCH_SB_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save SB_2012, replace

*** merge datasets

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

use 5500_2012

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2012_Latest/SB_2012"

drop if _merge !=3

drop _merge

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2012_Latest/H_2012"

drop if _merge ==2

drop _merge

gen year = 2012

*** generate ID number of plan

gen str3 PIN = string(spons_dfe_pn, "%03.0f")
gen str9 EIN = string(spons_dfe_ein, "%09.0f")

gen ID = EIN + PIN

sort ID

duplicates drop ID, force

save raw_2012.dta, replace
*********************************************************************************************************************
***** DATA PREPARATION PENSION FUNDS ********************************************************************************
*********************************************************************************************************************
*** This file loads the raw file raw5500_all.dta, performs the main sample cleaning steps and defines most variables
*** which are used for this study
*********************************************************************************************************************

clear all

set memory 2000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC"

use raw5500_all

set type double, permanently

*********************************
*** clean dataset from duplicates
*********************************
 
*** generate ID number of plan

gen str3 PIN = string(SPONS_DFE_PN, "%03.0f")
gen str9 EIN = string(SPONS_DFE_EIN, "%09.0f")

gen ID = EIN + PIN

*** generate number of plans

sort ID

egen plans = group(ID)

summ plans
drop plans

*** focus on DB plans only

drop if DC == 1

summ DB

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop multi-employer plans

drop if TYPE_PLAN_ENTITY_IND != 2

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** set time parameter and compute sample

sort ID year

egen id = group(ID)

sort id year

xtset id year

*** drop small plans

gen participants = TOT_PARTCP_BOY_CNT 
drop if participants < 100

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate current-liability variable (RPA)

gen liab = (ACTRL_RPA94_INFO_CURR_LIAB_AMT/1000000)
drop if liab ==.
drop if liab == 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

**** prepare actuarial accrued liabilities
*** background: the accrued liability can be computed using the (a) immediate gain method or (b) the entry age normal method
*** plans thus only report one of the two numbers, but there are few cases/typos where both / no values contain an entry; these cases are dropped

gen dum_gain = 1 if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT !=0
replace dum_gain = 0 if dum_gain ==.

gen dum_age = 1 if ACTRL_ACCR_LIAB_AGE_MTHD_AMT !=0
replace dum_age = 0 if dum_age ==.

summ dum_gain dum_age

*** make sure plans use only one method (only affects few plans)

gen dum_both = dum_gain + dum_age

drop if dum_both !=1
drop dum_both

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** double check that accrued liability is only reported once

summ ACTRL_ACCR_LIAB_GAIN_MTHD_AMT if ACTRL_ACCR_LIAB_AGE_MTHD_AMT ==0
summ ACTRL_ACCR_LIAB_GAIN_MTHD_AMT if ACTRL_ACCR_LIAB_AGE_MTHD_AMT !=0

summ ACTRL_ACCR_LIAB_AGE_MTHD_AMT if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT ==0
summ ACTRL_ACCR_LIAB_AGE_MTHD_AMT if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT !=0

*** generate accrued liability

gen accr_liab = (ACTRL_ACCR_LIAB_GAIN_MTHD_AMT + ACTRL_ACCR_LIAB_AGE_MTHD_AMT)/1000000

drop if accr_liab ==.

drop if accr_liab <= 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate log of liabilities

gen log_AL = log(accr_liab)

gen log_CL = log(liab)

*** generate difference in pension liabilities

gen diff_liab = (liab - accr_liab)/accr_liab
replace diff_liab = diff_liab*100

*** generate asset variable

gen asset = ACTRL_CURR_VALUE_AST_01_AMT/1000000
drop if asset ==.
drop if asset == 0
drop if asset < 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate funding variable

gen funding = asset - liab  

gen relfunding = (funding / liab)
replace relfunding = relfunding*100

*** generate beginning of period FSA variable

gen FSAp = ACTRL_PR_YR_CREDIT_BALANCE_AMT/1000000
replace FSAp = 0 if FSAp <0
replace FSAp = 0 if FSAp ==.

gen FSAn = ACTRL_PR_YR_FNDNG_DEFN_AMT/1000000
replace FSAn = 0 if FSAn <0
replace FSAn = 0 if FSAn ==.

gen FSA = FSAp - FSAn
gen FSA_asset = FSA/asset
replace FSA_asset = FSA_asset*100

*** required cash contributions: MFC, AFR and MPC

gen MPC = ACTRL_TOT_CHARGES_AMT/1000000
gen MPC_asset = MPC/asset
replace MPC_asset= MPC_asset*100

gen MFC =  ACTRL_TOT_CHARGES_AMT/1000000  - ACTRL_ADDNL_FNDNG_PRT2_AMT/1000000 
gen MFC_asset = MFC/asset
replace MFC_asset= MFC_asset*100

gen AFR = ACTRL_ADDNL_FNDNG_PRT2_AMT/1000000
replace AFR = 0 if AFR <0
gen AFR_asset = AFR/asset
replace AFR_asset = AFR_asset*100

*** actual cash contributions

gen tot_contr =  ACTRL_TOT_EMPLR_CONTRIB_AMT/1000000
gen tot_contr_asset = tot_contr/asset
replace tot_contr_asset = tot_contr_asset*100

gen excess = (tot_contr - MPC)/asset

*** generate interest rate variables (in basis points)

** AL interest rate
gen interest = ACTRL_VALUATION_INT_PRE_PRCNT

** CL interest rate
gen interest_RPA = ACTRL_CURR_LIAB_RPA_PRCNT

gen D_interest = (interest - interest_RPA)

drop if D_interest ==.

sort ID
egen plans = group(ID)
summ plans
drop plans

*** use information on (pre-retirement) mortality tables
** comment: we focus on tables for males as they account for a larger fraction of the workforce

gen mortality_m = ACTRL_MORTALITY_MALE_PRE_CODE if ACTRL_MORTALITY_MALE_PRE_CODE != ""

drop if mortality_m == ""

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** check that the retirement mortality table coincides with the pre-retirement table

gen ind = 1 if ACTRL_MORTALITY_MALE_PRE_CODE == ACTRL_MORTALITY_MALE_POST_CODE  
replace ind = 0 if ACTRL_MORTALITY_MALE_PRE_CODE != ACTRL_MORTALITY_MALE_POST_CODE 

*** drop cases where different tables are being used

drop if ind == 0

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*****************************************************************************************************************************************************
*** construct mortality table dummies
*****************************************************************************************************************************************************

quietly: tabulate mortality_m, sort

replace mortality_m = "A" if mortality_m == "9" & year != 2007

gen m_none =  1 if mortality_m == "0" 
replace m_none = 0 if m_none ==.

gen m_1951 = 1 if mortality_m == "1" 
replace m_1951 = 0 if m_1951 ==.

gen m_1971 = 1 if mortality_m == "2" 
replace m_1971 = 0 if m_1971 ==.

gen m_1971b = 1 if mortality_m == "3" 
replace m_1971b = 0 if m_1971b ==.

gen m_1984 = 1 if mortality_m == "4" 
replace m_1984 = 0 if m_1984 ==.

gen m_1983a = 1 if mortality_m == "5" 
replace m_1983a = 0 if m_1983a ==.

gen m_1983b = 1 if mortality_m == "6" 
replace m_1983b = 0 if m_1983b ==.

gen m_1983c = 1 if mortality_m == "7" 
replace m_1983c = 0 if m_1983c ==.

gen m_1983 = m_1983b + m_1983c

gen m_1994 = 1 if mortality_m == "8" 
replace m_1994 = 0 if m_1994 ==.

gen m_2007 = 1 if mortality_m == "9" 
replace m_2007 = 0 if m_2007 ==.

gen m_oth = 1 if mortality_m == "A" 
replace m_oth = 0 if m_oth ==.

gen m_var = 1 - (m_1951 + m_1971 + m_1971b + m_none + m_1984 + m_1983a + m_1983b + m_1983c + m_1994 + m_2007 + m_oth) 

*** drop other tables

drop if m_oth == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop cases where no tables are used

drop if m_none == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop variations of tables / we don't know life expectancy

drop if m_var == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** average retirement age

gen retmt = ACTRL_WEIGHTED_RTM_AGE

drop if retmt ==. 

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

summ retmt

*centile retmt, centile(1 99)
*drop if retmt < r(c_1)
*drop if retmt > r(c_2)

drop if retmt < 56
drop if retmt > 65

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans


*** create cross-sectional longevity index based on mandated life expectancy
*** note: the numbers come from a separate computation in Excel

*** CL life expectancy assumptions

gen long_GM83 = 23.47488295 if retmt == 56
replace long_GM83  = 22.63127472 if retmt == 57
replace long_GM83  = 21.7940011 if retmt == 58
replace long_GM83  = 20.96353764 if retmt == 59
replace long_GM83  = 20.14078196 if retmt == 60
replace long_GM83  = 19.32693604 if retmt == 61
replace long_GM83  = 18.52341974 if retmt == 62
replace long_GM83  = 17.73196268 if retmt == 63
replace long_GM83  = 16.9544361 if retmt == 64
replace long_GM83  = 16.19286677 if retmt == 65

** in year 2007, master table is RP2000

replace long_GM83  = 24.46744037 if year==2007 & retmt == 56
replace long_GM83  = 23.61820224 if year==2007 & retmt == 57
replace long_GM83  = 22.77138505 if year==2007 & retmt == 58
replace long_GM83  = 21.92948384 if year==2007 & retmt == 59
replace long_GM83  = 21.0948639  if year==2007 & retmt == 60
replace long_GM83  = 20.26918615 if year==2007 & retmt == 61
replace long_GM83  = 19.45328617 if year==2007 & retmt == 62
replace long_GM83  = 18.64809706 if year==2007 & retmt == 63
replace long_GM83  = 17.85457349 if year==2007 & retmt == 64
replace long_GM83  = 17.07357095 if year==2007 & retmt == 65

*** AL life expectancy assumptions

gen long_index_cs  = 20.2357447 if m_1951 == 1 & retmt == 56
replace long_index_cs  = 20.66137352 if m_1984 == 1 & retmt == 56
replace long_index_cs  = 21.40249131 if m_1971 == 1 & retmt == 56
replace long_index_cs  = 23.4105909 if m_1971b == 1 & retmt == 56
replace long_index_cs  = 23.47488295 if m_1983 ==1 & retmt == 56
replace long_index_cs  = 24.11367631 if m_1994 ==1 & retmt == 56
replace long_index_cs  = 24.44261395 if m_1983a ==1 & retmt == 56
replace long_index_cs  = 26.13135926 if m_2007 ==1 & retmt == 56

replace long_index_cs  = 19.46797433 if m_1951 == 1 & retmt == 57
replace long_index_cs  = 19.88724822 if m_1984 == 1 & retmt == 57
replace long_index_cs  = 20.60257435 if m_1971 == 1 & retmt == 57
replace long_index_cs  = 22.62603673 if m_1971b == 1 & retmt == 57
replace long_index_cs  = 22.63127472 if m_1983 ==1 & retmt == 57
replace long_index_cs  = 23.24269593 if m_1994 ==1 & retmt == 57
replace long_index_cs  = 23.61948029 if m_1983a ==1 & retmt == 57
replace long_index_cs  = 25.21051502 if m_2007 ==1 & retmt == 57

replace long_index_cs  = 18.71037249 if m_1951 == 1 & retmt == 58
replace long_index_cs  = 19.12600299 if m_1984 == 1 & retmt == 58
replace long_index_cs  = 19.81150101 if m_1971 == 1 & retmt == 58
replace long_index_cs  = 21.85112027 if m_1971b == 1 & retmt == 58
replace long_index_cs  = 21.7940011 if m_1983 ==1 & retmt == 58
replace long_index_cs  = 22.38301742 if m_1994 ==1 & retmt == 58
replace long_index_cs  = 22.80175413 if m_1983a ==1 & retmt == 58
replace long_index_cs  = 24.2981478 if m_2007 ==1 & retmt == 58

replace long_index_cs  = 17.96261318 if m_1951 == 1 & retmt == 59
replace long_index_cs  = 18.37697355 if m_1984 == 1 & retmt == 59
replace long_index_cs  = 19.02960336 if m_1971 == 1 & retmt == 59
replace long_index_cs  = 21.08551382 if m_1971b == 1 & retmt == 59
replace long_index_cs  = 20.96353764 if m_1983 ==1 & retmt == 59
replace long_index_cs  = 21.53567408 if m_1994 ==1 & retmt == 59
replace long_index_cs  = 21.98902271 if m_1983a ==1 & retmt == 59
replace long_index_cs  = 23.39548579 if m_2007 ==1 & retmt == 59

replace long_index_cs  = 17.22466564 if m_1951 == 1 & retmt == 60
replace long_index_cs  = 17.64096693 if m_1984 == 1 & retmt == 60
replace long_index_cs  = 18.25925066 if m_1971 == 1 & retmt == 60
replace long_index_cs  = 20.32889788 if m_1971b == 1 & retmt == 60
replace long_index_cs  = 20.14078196 if m_1983 ==1 & retmt == 60
replace long_index_cs  = 20.70110157 if m_1994 ==1 & retmt == 60
replace long_index_cs  = 21.18135726 if m_1983a ==1 & retmt == 60
replace long_index_cs  = 22.50192601 if m_2007 ==1 & retmt == 60

replace long_index_cs  = 16.49682881 if m_1951 == 1 & retmt == 61
replace long_index_cs  = 16.91887069 if m_1984 == 1 & retmt == 61
replace long_index_cs  = 17.50197812 if m_1971 == 1 & retmt == 61
replace long_index_cs  = 19.58099448 if m_1971b == 1 & retmt == 61
replace long_index_cs  = 19.32693604 if m_1983 ==1 & retmt == 61
replace long_index_cs  = 19.88016991 if m_1994 ==1 & retmt == 61
replace long_index_cs  = 20.37945933 if m_1983a ==1 & retmt == 61
replace long_index_cs  = 21.61902471 if m_2007 ==1 & retmt == 61

replace long_index_cs  = 15.77983756 if m_1951 == 1 & retmt == 62
replace long_index_cs  = 16.2116407 if m_1984 == 1 & retmt == 62
replace long_index_cs  = 16.75840955 if m_1971 == 1 & retmt == 62
replace long_index_cs  = 18.84157387 if m_1971b == 1 & retmt == 62
replace long_index_cs  = 18.52341974 if m_1983 ==1 & retmt == 62
replace long_index_cs  = 19.07414639 if m_1994 ==1 & retmt == 62
replace long_index_cs  = 19.58450155 if m_1983a ==1 & retmt == 62
replace long_index_cs  = 20.75017828 if m_2007 ==1 & retmt == 62

replace long_index_cs  = 15.07485945 if m_1951 == 1 & retmt == 63
replace long_index_cs  = 15.52032294 if m_1984 == 1 & retmt == 63
replace long_index_cs  = 16.02853317 if m_1971 == 1 & retmt == 63
replace long_index_cs  = 18.11051616 if m_1971b == 1 & retmt == 63
replace long_index_cs  = 17.73196268 if m_1983 ==1 & retmt == 63
replace long_index_cs  = 18.28456023 if m_1994 ==1 & retmt == 63
replace long_index_cs  = 18.79806325 if m_1983a ==1 & retmt == 63
replace long_index_cs  = 19.89495945 if m_2007 ==1 & retmt == 63

replace long_index_cs  = 14.38357708 if m_1951 == 1 & retmt == 64
replace long_index_cs  = 14.84542349 if m_1984 == 1 & retmt == 64
replace long_index_cs  = 15.3125842 if m_1971 == 1 & retmt == 64
replace long_index_cs  = 17.38786026 if m_1971b == 1 & retmt == 64
replace long_index_cs  = 16.9544361 if m_1983 ==1 & retmt == 64
replace long_index_cs  = 17.51291706 if m_1994 ==1 & retmt == 64
replace long_index_cs  = 18.02193238 if m_1983a ==1 & retmt == 64
replace long_index_cs  = 19.05740437 if m_2007 ==1 & retmt == 64

replace long_index_cs  = 13.70814164 if m_1951 == 1 & retmt == 65
replace long_index_cs  = 14.18809734 if m_1984 == 1 & retmt == 65
replace long_index_cs  = 14.61210238 if m_1971 == 1 & retmt == 65
replace long_index_cs  = 16.67391253 if m_1971b == 1 & retmt == 65
replace long_index_cs  = 16.19286677 if m_1983 ==1 & retmt == 65
replace long_index_cs  = 16.76003012 if m_1994 ==1 & retmt == 65
replace long_index_cs  = 17.25782346 if m_1983a ==1 & retmt == 65
replace long_index_cs  = 18.23356459 if m_2007 ==1 & retmt == 65

*** compute difference in life expectancy

gen LE = (long_index_cs -long_GM83)

**** create industry dummmies

tostring BUSINESS_CODE, generate(NAICS)

gen agr = 1 if substr(NAICS, 1,2) == "11"
replace agr = 0 if agr ==.

gen min = 1 if substr(NAICS, 1,2) == "21"
replace min = 0 if min ==.

gen util = 1 if substr(NAICS, 1,2) == "22"
replace util = 0 if util ==.

gen cstrc = 1 if substr(NAICS, 1,2) == "23"
replace cstrc = 0 if cstrc ==.

gen man = 1 if substr(NAICS, 1,2) == "31"
replace man = 1 if substr(NAICS, 1,2) == "32"
replace man = 1 if substr(NAICS, 1,2) == "33"
replace man = 0 if man ==.

gen whle = 1 if substr(NAICS, 1,2) == "42"
replace whle = 0 if whle ==.

gen retl = 1 if substr(NAICS, 1,2) == "44"
replace retl = 1 if substr(NAICS, 1,2) == "45"
replace retl = 0 if retl ==.

gen trans = 1 if substr(NAICS, 1,2) == "48"
replace trans = 1 if substr(NAICS, 1,2) == "49"
replace trans = 0 if trans ==.

gen inf = 1 if substr(NAICS, 1,2) == "51"
replace inf = 0 if inf ==.

gen fin = 1 if substr(NAICS, 1,2) == "52"
replace fin = 0 if fin ==.

gen real = 1 if substr(NAICS, 1,2) == "53"
replace real = 0 if real ==.

gen prof = 1 if substr(NAICS, 1,2) == "54"
replace prof = 0 if prof ==.

gen hldg = 1 if substr(NAICS, 1,2) == "55"
replace hldg = 0 if hldg ==.

gen admin = 1 if substr(NAICS, 1,2) == "56"
replace admin = 0 if admin ==.

gen edu = 1 if substr(NAICS, 1,2) == "61"
replace edu = 0 if edu ==.

gen hlth = 1 if substr(NAICS, 1,2) == "62"
replace hlth = 0 if hlth ==.

gen arts = 1 if substr(NAICS, 1,2) == "71"
replace arts = 0 if arts ==.

gen accom = 1 if substr(NAICS, 1,2) == "72"
replace accom = 0 if accom ==.

gen oth = 1 if substr(NAICS, 1,2) == "81"
replace oth = 1 if substr(NAICS, 1,2) == "92"
replace oth = 0 if oth ==.

gen test = agr + min + util + cstrc + man + whle + retl + trans + inf + fin + real + prof + hldg + admin + edu + hlth + arts + accom + oth

summ test if test == 0

*** industry classification: visual inspection suggests that if test == 0, then missing or unclassified numbers

gen industry = "agr" if agr ==1
replace industry = "min" if min == 1
replace industry = "util" if util == 1
replace industry = "cstrc" if cstrc == 1
replace industry = "man" if man == 1
replace industry = "whle" if whle == 1
replace industry = "retl" if retl == 1
replace industry = "trans" if trans == 1
replace industry = "inf" if inf == 1
replace industry = "fin" if fin == 1
replace industry = "real" if real == 1
replace industry = "prof" if prof == 1
replace industry = "hldg" if hldg == 1
replace industry = "admin" if admin == 1
replace industry = "edu" if edu == 1
replace industry = "hlth" if hlth == 1
replace industry = "arts" if arts == 1
replace industry = "accom" if accom == 1
replace industry = "oth" if oth == 1

*** size

gen size = log(asset) 

*** compute "duration" proxy
** intuition: if none of the current plan participants is in retirement, the measure is 1 ( = long term promise)
** intuition ctd: if all of the current plan participants are already in retirement, the measure is 0 ( = short term promise)

replace RTD_SEP_PARTCP_RCVG_CNT= 0 if RTD_SEP_PARTCP_RCVG_CNT ==.
replace BENEF_RCVG_BNFT_CNT = 0 if BENEF_RCVG_BNFT_CNT ==.

gen part_ret = RTD_SEP_PARTCP_RCVG_CNT + BENEF_RCVG_BNFT_CNT

gen duration = (1 - part_ret/participants)
replace duration = duration*100

*** active participants

gen part_act = participants - part_ret

gen rel_part_act = (part_act/asset)
replace rel_part_act = rel_part_act*100

*** time dummies

sort year
quietly: tabulate year, gen(d)

*** generate investment variables

gen cash = NON_INT_BEAR_CASH_EOY_AMT
replace cash = 0 if cash ==.
 
gen cash_inv = INT_BEAR_CASH_EOY_AMT
replace cash_inv = 0 if cash_inv ==.

gen AR = EMPLR_CONTRIB_EOY_AMT + PARTCP_CONTRIB_EOY_AMT + OTHER_RECEIVABLE_EOY_AMT
replace AR = 0 if AR ==.

gen US_treas = GOVG_SEC_EOY_AMT
replace US_treas = 0 if US_treas ==.

gen debt_corp = CORP_DEBT_PREFERRED_EOY_AMT + CORP_DEBT_OTHER_EOY_AMT
replace debt_corp = 0 if debt_corp ==.

gen equity = PREF_STOCK_EOY_AMT + COMMON_STOCK_EOY_AMT
replace equity = 0 if equity ==.

gen JV = JOINT_VENTURE_EOY_AMT
replace JV = 0 if JV ==.

gen RE = REAL_ESTATE_EOY_AMT
replace RE = 0 if RE ==.

gen loans = OTHER_LOANS_EOY_AMT + PARTCP_LOANS_EOY_AMT
replace loans = 0 if loans ==.

gen com_trust = INT_COMMON_TR_EOY_AMT 
replace com_trust = 0 if com_trust ==.

gen pool_trust = INT_POOL_SEP_ACCT_EOY_AMT 
replace pool_trust = 0 if pool_trust ==.

gen master_trust = INT_MASTER_TR_EOY_AMT
replace master_trust = 0 if master_trust ==.

gen inv = INT_103_12_INVST_EOY_AMT
replace inv = 0 if inv ==.

gen funds = INT_REG_INVST_CO_EOY_AMT
replace funds = 0 if funds ==.

gen insurance = INS_CO_GEN_ACCT_EOY_AMT
replace insurance = 0 if insurance ==.

gen other = OTH_INVST_EOY_AMT
replace other = 0 if other ==.

gen employer = EMPLR_SEC_EOY_AMT + EMPLR_PROP_EOY_AMT
replace employer = 0 if employer ==.

gen buildings = BLDGS_USED_EOY_AMT
replace buildings = 0 if buildings ==.

gen impl_TA = cash + cash_inv + AR + US_treas + debt_corp + equity + JV + RE + loans +  com_trust +  pool_trust + master_trust + inv + funds + insurance + other + employer + buildings

*** drop negative values 

drop if cash < 0
drop if cash_inv < 0
drop if AR < 0
drop if US_treas < 0
drop if debt_corp < 0
drop if equity < 0
drop if JV < 0
drop if RE < 0
drop if loans < 0
drop if com_trust < 0
drop if pool_trust < 0
drop if master_trust < 0
drop if inv < 0
drop if funds < 0
drop if insurance < 0
drop if other < 0
drop if employer < 0
drop if buildings < 0


*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans


***

gen rel_cash = cash/impl_TA
gen rel_cash_inv = cash_inv/impl_TA
gen rel_AR = AR/impl_TA
gen rel_US_treas = US_treas/impl_TA
gen rel_debt_corp = debt_corp/impl_TA
gen rel_equity = equity/impl_TA
gen rel_JV = JV/impl_TA
gen rel_RE = RE/impl_TA
gen rel_loans = loans/impl_TA
gen rel_com_trust = com_trust/impl_TA
gen rel_master_trust = master_trust/impl_TA
gen rel_pool_trust = pool_trust/impl_TA
gen rel_inv = inv/impl_TA
gen rel_funds = funds/impl_TA
gen rel_insurance = insurance/impl_TA
gen rel_other = other/impl_TA
gen rel_employer = employer/impl_TA
gen rel_buildings = buildings/impl_TA

*** define risky assets

gen risky = 1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp
replace risky = risky*100

drop if risky ==.

sort ID
egen plans = group(ID)
summ plans
drop plans

gen fyear = year

**** winsorize data (all variables)

centile relfunding, centile(0.5 99.5)
replace relfunding = r(c_1) if relfunding < r(c_1)
replace relfunding = r(c_2) if relfunding > r(c_2)

centile diff_liab, centile(.5 99.5)
replace diff_liab = r(c_1) if diff_liab < r(c_1)
replace diff_liab = r(c_2) if diff_liab > r(c_2)

centile D_interest, centile(.5 99.5)
replace D_interest = r(c_1) if D_interest < r(c_1)
replace D_interest = r(c_2) if D_interest > r(c_2)

centile interest, centile(.5 99.5)
replace interest = r(c_1) if interest < r(c_1)
replace interest = r(c_2) if interest > r(c_2)

centile interest_RPA, centile(0.5 99.5)
replace interest_RPA = r(c_1) if interest_RPA < r(c_1)
replace interest_RPA = r(c_2) if interest_RPA > r(c_2)

centile duration, centile(0.5 99.5)
replace duration = r(c_1) if duration < r(c_1)
replace duration = r(c_2) if duration > r(c_2)

centile size, centile(0.5 99.5)
replace size = r(c_1) if size < r(c_1)
replace size = r(c_2) if size > r(c_2)

centile rel_part_act, centile(0.5 99.5)
replace rel_part_act = r(c_1) if rel_part_act < r(c_1)
replace rel_part_act = r(c_2) if rel_part_act > r(c_2)

centile MFC_asset, centile(0.5 99.5)
replace MFC_asset = r(c_1) if MFC_asset < r(c_1) & MFC_asset !=.
replace MFC_asset = r(c_2) if MFC_asset > r(c_2) & MFC_asset !=.

centile AFR_asset, centile(0.5 99.5)
replace AFR_asset = r(c_1) if AFR_asset < r(c_1) & AFR_asset !=.
replace AFR_asset = r(c_2) if AFR_asset > r(c_2) & AFR_asset !=.

centile MPC_asset, centile(0.5 99.5)
replace MPC_asset = r(c_1) if MPC_asset < r(c_1) & MPC_asset !=.
replace MPC_asset = r(c_2) if MPC_asset > r(c_2) & MPC_asset !=.

centile FSA_asset, centile(0.5 99.5)
replace FSA_asset = r(c_1) if FSA_asset < r(c_1) & FSA_asset !=.
replace FSA_asset = r(c_2) if FSA_asset > r(c_2) & FSA_asset !=.

centile tot_contr_asset, centile(0.5 99.5)
replace tot_contr_asset = r(c_1) if tot_contr_asset < r(c_1) & tot_contr_asset !=.
replace tot_contr_asset = r(c_2) if tot_contr_asset > r(c_2) & tot_contr_asset !=.

centile excess, centile(0.5 99.5)
replace excess = r(c_1) if excess < r(c_1)
replace excess = r(c_2) if excess > r(c_2)


*** generate number of plans
sort id

egen plans = group(id)

summ plans

*** make ready for Compustat merge

summ fyear
sort EIN fyear

*** define manipulation

gen manip = 1 if diff_liab > 0
replace manip = 0 if manip == .


cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save longevity, replace

***************** end of code


clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** number of plans

summ plans

sort id year
gen count = 1
replace count = count[_n-1] + 1 if id == id[_n-1]

gen ncount = count
replace ncount =. if ncount[_n+1] !=. & id == id[_n+1]

edit id year count ncount

*** average and medium number of observations per plan

summ ncount,d

drop count ncount

** generate number of plans each year

sort year
by year: egen obs = count(id)

*** Table 3, Panel A

tabstat accr_liab liab diff_liab asset relfunding interest interest_RPA D_interest long_index_cs long_GM83 LE size duration risky obs, by(year)

*** statistics pension liability manipulation

summ diff_liab, d

summ diff_liab if diff_liab >0
gen N = r(N)
summ diff_liab

display N/r(N)

*** Figure 1

histogram  diff_liab, fraction title("") xtitle("Pension liability gap") ytitle("Fraction of the sample") scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffliab.pdf", as(pdf) preview(off) replace

*** Figure 3

histogram  D_interest, fraction title("") xtitle("Excess discount rate assumptions") ytitle("Fraction of the sample") scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffint.pdf", as(pdf) preview(off) replace


summ diff_liab D_interest LE, d

summ diff_liab D_interest LE if diff_liab < 0, d

summ diff_liab D_interest LE if diff_liab > 0, d

summ LE if LE < 0

*** Figure 2

centile relfunding, centile(1 99)
gen th1 = r(c_1)
gen th2 = r(c_2)

summ relfunding, d

lpoly diff_liab relfunding if relfunding > th1 & relfunding < th2, kernel(epan) ci noscatter bw(10) title("") xtitle("Funding Status") ytitle("Pension liability gap") xlabel(-50(25)150) xmtick(-50(12.5)150) scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffliab_Kernel.pdf", as(pdf) preview(off) replace


*** Table 4

reg diff_liab relfunding, r
estimates store OLS1

reg diff_liab relfunding size duration risky, r
estimates store OLS2

reg diff_liab relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liab relfunding, fe
estimates store FE1

xtscc diff_liab relfunding size duration risky, fe
estimates store FE2

xtscc diff_liab relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** changes in excess interest-rates

sort id year

gen ch_D_interest = D_interest - l1.D_interest

gen dum_ch_D_int_p = 1 if ch_D_interest > 0 & ch_D_interest !=.
replace dum_ch_D_int_p = 0 if dum_ch_D_int_p ==.

gen dum_ch_D_int_n = 1 if ch_D_interest < 0 & ch_D_interest !=.
replace dum_ch_D_int_n = 0 if dum_ch_D_int_n ==.

gen dum_ch_D_int_u = 1 if ch_D_interest == 0 & ch_D_interest !=.
replace dum_ch_D_int_u = 0 if dum_ch_D_int_u ==.

gen dum_first = 1 if ch_D_interest ==.
replace dum_first = 0 if dum_first ==.

*** change in individual interest rates

gen ch_interest = interest - l1.interest

gen ch_interest_RPA = interest_RPA - l1.interest_RPA

**** yearly number of changes in Delta-interest raates

sort year
by year: egen tot_int_p = sum(dum_ch_D_int_p)
by year: egen tot_int_n = sum(dum_ch_D_int_n)
by year: egen tot_int_u = sum(dum_ch_D_int_u)
by year: egen tot_count = count(dum_ch_D_int_p)

by year: egen tot_first = sum(dum_first)

gen fraction_incr = tot_int_p/tot_count*100
gen fraction_decr = tot_int_n/tot_count*100

*** Table 5, Panel A

tabstat ch_D_interest tot_int_p tot_int_u tot_int_n tot_count fraction_incr fraction_decr tot_first, by(year)

*** changes in excess life expectancy assumptions

sort id year

gen ch_LE = LE - l1.LE

gen dum_ch_LE_p = 1 if ch_LE > 0 & ch_LE !=.
replace dum_ch_LE_p = 0 if dum_ch_LE_p ==.

gen dum_ch_LE_n = 1 if ch_LE < 0 & ch_LE !=.
replace dum_ch_LE_n = 0 if dum_ch_LE_n ==.

gen dum_ch_LE_u = 1 if ch_LE == 0 & ch_LE !=.
replace dum_ch_LE_u = 0 if dum_ch_LE_u ==.

sort year
by year: egen tot_LE_p = sum(dum_ch_LE_p)
by year: egen tot_LE_n = sum(dum_ch_LE_n)
by year: egen tot_LE_u = sum(dum_ch_LE_u)

gen fraction_incr_LE = tot_LE_p/tot_count*100
gen fraction_decr_LE = tot_LE_n/tot_count*100

*** Table 5, Panel B

tabstat ch_LE tot_LE_p tot_LE_u tot_LE_n tot_count fraction_incr_LE fraction_decr_LE, by(year)

*** generate positive and negative funding variable
*** note: we use absolute value of underfunding

gen p_relfunding = relfunding if relfunding >=0
replace p_relfunding = 0 if p_relfunding ==.

gen n_relfunding = relfunding*(-1) if relfunding < 0
replace n_relfunding = 0 if n_relfunding ==.

*****************************************************
*** pooled evidence: discount rate assumptions
*****************************************************

*** Table 6

reg D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

** Robustness: interest as LHS variable (Online Appendix Table 1)


reg interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*******************************************************
*** cross-sectional evdience: discount rate assumptions
*******************************************************

*** Online Appendix Table 2

fm D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm1

fm D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm2

fm interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm3

fm interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm4

estout fm*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout fm*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*******************************************************
*** time-series evdience: discount rate assumptions
*******************************************************

sort id year

*** change in funding

gen ch_relfunding = relfunding - l1.relfunding
gen ch_p_relfunding = p_relfunding - l1.p_relfunding
gen ch_n_relfunding = n_relfunding - l1.n_relfunding

*** Online Appendix Table 3

reg ch_D_interest ch_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg ch_D_interest ch_p_relfunding ch_n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

reg ch_interest ch_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg3

reg ch_interest ch_p_relfunding ch_n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*****************************************************
*** pooled evidence: LE assumptions
*****************************************************

gen dum_neg = 1 if LE < 0
replace dum_neg = 0 if dum_neg ==.

*** Table 7

logit dum_neg relfunding, vce(robust) 
estimates store reg1

logit dum_neg relfunding size duration risky, vce(robust)
estimates store reg2

logit dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** Untabulated robustness check: LE choice before 2007

drop plans
sort ID
egen plans = group(ID) if year < 2007
summ plans
drop plans

logistic dum_neg relfunding if year < 2007, vce(robust) 
estimates store reg1

logistic dum_neg relfunding size duration risky if year < 2007, vce(robust)
estimates store reg2

logistic dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg3

logistic dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg4

logistic dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 


*****************************************************************************
*** Untabulated robustness check: impact of frozen, terminated or floor plans
*****************************************************************************

sort TYPE_PENSION_BNFT_CODE

gen entry1 = substr(TYPE_PENSION_BNFT_CODE,1,2)
gen entry2 = substr(TYPE_PENSION_BNFT_CODE,3,2)
gen entry3 = substr(TYPE_PENSION_BNFT_CODE,5,2)
gen entry4 = substr(TYPE_PENSION_BNFT_CODE,7,2)
gen entry5 = substr(TYPE_PENSION_BNFT_CODE,9,2)
gen entry6 = substr(TYPE_PENSION_BNFT_CODE,11,2)
gen entry7 = substr(TYPE_PENSION_BNFT_CODE,13,2)

*** generate indicator variable for being a frozen plan

gen frozen = 1 if entry1 =="1I"
forvalues i=2(1)7{
replace frozen = 1 if entry`i' == "1I"
}

replace frozen = 0 if frozen ==.

*** generate indicator variable for being a terminated plan

gen terminated = 1 if entry1 =="1H"
forvalues i=2(1)7{
replace terminated = 1 if entry`i' == "1H"
}

replace terminated = 0 if terminated ==.

*** generate indicator variable for being a floor offset plan

gen floor = 1 if entry1 =="1D"
forvalues i=2(1)7{
replace floor = 1 if entry`i' == "1D"
}

replace floor = 0 if floor ==.


*** fraction of those pension plans and corresponding liability gap

summ frozen terminated floor

summ diff_liab if frozen == 1
summ diff_liab if terminated == 1
summ diff_liab if floor == 1


*** focus on the first observation a plan becomes frozen, terminated or receives a floor

sort id year
gen first_frozen = frozen - frozen[_n-1] if id==id[_n-1]
replace first_frozen = 0 if first_frozen ==-1

gen first_floor = floor - floor[_n-1] if id==id[_n-1]
replace first_floor = 0 if first_floor ==-1

gen first_terminated = terminated - terminated[_n-1] if id==id[_n-1]
replace first_terminated = 0 if first_terminated ==-1

gen lag_diff_liab = l1.diff_liab

logistic first_frozen lag_diff_liab size duration  , vce(robust)
estimates store reg1

logistic first_floor lag_diff_liab size duration risky  , vce(robust)
estimates store reg2

logistic first_terminated lag_diff_liab size duration risky , vce(robust)
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

**
drop if frozen == 1
drop if terminated == 1
drop if floor == 1

*** Table 4 w/o frozen plans

reg diff_liab relfunding, r
estimates store OLS1

reg diff_liab relfunding size duration risky, r
estimates store OLS2

reg diff_liab relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liab relfunding, fe
estimates store FE1

xtscc diff_liab relfunding size duration risky, fe
estimates store FE2

xtscc diff_liab relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Table 6 w/o frozen plans

reg D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*** Table 7 w/o frozen plans

logit dum_neg relfunding, vce(robust) 
estimates store reg1

logit dum_neg relfunding size duration risky, vce(robust)
estimates store reg2

logit dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

********************************************************************************
*** show summary statistics (Table 8, Panel A) for all plan-years
********************************************************************************
clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** compute trailing number of observations per pension plan 

sort id year

by id: gen num = _n

*** compute number of cross-sectional observations for each "number" num

sort num

by num: egen obs_num = count(num)

*** compute total observations by pension plan

sort id num

by id: egen max_num = max(num)


*** compute total number of years in which plans use regulatory leeway

sort id num

by id: gen sum_manip = sum(manip)

*** compute maximum number of manipulative years by pension plan

gen max_manip = sum_manip
replace max_manip = . if num != max_num

sort id max_manip
replace max_manip = max_manip[_n-1] if id==id[_n-1] & max_manip ==.

*** double check that code is correct (yes, it is)

sort id year

edit id year num max_num sum_manip manip max_manip


*** compute number of plans for each max_manip
*** need to start the code at 1 (instead of zero)

sort max_manip id
replace max_manip = max_manip +1
summ max_manip

forvalues i=1(1)10{
egen manip_plans = group(id) if max_manip == `i'
egen m_plans_`i' = max(manip_plans) if max_manip == `i'
replace m_plans_`i' = 0 if m_plans_`i' ==.
drop manip_plans
}

*** double check that code is correct (yes, it is)

summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip == 1
summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip  == 10

gen m_plans = m_plans_1 + m_plans_2 + m_plans_3 + m_plans_4 + m_plans_5 + m_plans_6 + m_plans_7 + m_plans_8 + m_plans_9 + m_plans_10
drop m_plans_*

*** generate number of plan-years per max_manip

sort max_manip id

by max_manip: egen sum_mmanip = count(manip)

*** double check that code is correct (yes, it is)

edit max_manip id m_plans sum_mmanip

*** Table 8, Panel A

tabstat sum_mmanip m_plans relfunding tot_contr_asset MFC_asset AFR_asset, by(max_manip)

*********************************************************************************************************
*** repeat the code (Table 8, Panel B) for underfunded plan-years only
*** focus only on underfunded plan years for subsequent analysis (only then, contributions are mandatory)
*********************************************************************************************************

clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** compute trailing number of observations per pension plan 

sort id year

by id: gen num = _n

*** compute number of cross-sectional observations for each "number" num

sort num

by num: egen obs_num = count(num)

*** compute total observations by pension plan

sort id num

by id: egen max_num = max(num)


*** compute total number of years in which plans use regulatory leeway

sort id num

by id: gen sum_manip = sum(manip)

*** compute maximum number of manipulative years by pension plan

gen max_manip = sum_manip
replace max_manip = . if num != max_num

sort id max_manip
replace max_manip = max_manip[_n-1] if id==id[_n-1] & max_manip ==.

*** double check that code is correct (yes, it is)

sort id year

edit id year num max_num sum_manip manip max_manip


*** drop underfunded plan years

drop if relfunding > 0

*** compute number of plans for each max_manip
*** need to start the code at 1 (instead of zero)

sort max_manip id
replace max_manip = max_manip +1
summ max_manip

forvalues i=1(1)10{
egen manip_plans = group(id) if max_manip == `i'
egen m_plans_`i' = max(manip_plans) if max_manip == `i'
replace m_plans_`i' = 0 if m_plans_`i' ==.
drop manip_plans
}

*** double check that code is correct (yes, it is)

summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip == 1
summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip  == 10

gen m_plans = m_plans_1 + m_plans_2 + m_plans_3 + m_plans_4 + m_plans_5 + m_plans_6 + m_plans_7 + m_plans_8 + m_plans_9 + m_plans_10
drop m_plans_*

*** generate number of plan-years per max_manip

sort max_manip id

by max_manip: egen sum_mmanip = count(manip)

*** double check that code is correct (yes, it is)

edit max_manip id m_plans sum_mmanip

*** Table 8, Panel B

tabstat sum_mmanip m_plans relfunding tot_contr_asset MFC_asset AFR_asset , by(max_manip)

*** multivariate analysis, total cash contributions
*** Table 9, Panel A

reg tot_contr_asset manip, r
estimates store reg1

reg tot_contr_asset relfunding manip, r
estimates store reg2

reg tot_contr_asset relfunding manip size duration risky , r
estimates store reg3

reg tot_contr_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg tot_contr_asset relfunding manip size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

xtscc tot_contr_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

*** multivariate analysis, mandatory funding contribution
*** Table 9, Panel B

reg MFC_asset manip, r
estimates store reg1

reg MFC_asset manip relfunding, r
estimates store reg2

reg MFC_asset manip relfunding size duration risky , r
estimates store reg3

reg MFC_asset manip relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg MFC_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

xtscc MFC_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** Robustness: multivariate analysis which conditions on the frequency of using regulatory leeway, total cash contributions
*** Online Appendix Table 4, Panel A

*** account for the fact that max_manip is set to start at 1 (not zero)
*** max_num needs to be consistent with it

replace max_num = max_num + 1

summ max_num max_manip

forvalues i=1(1)9{
summ manip max_num if max_num > `i' & max_manip ==`i' 
}

forvalues i=1(1)9{
reg tot_contr_asset manip relfunding agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i' , r

estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

***

forvalues i=1(1)9{
reg MFC_asset manip relfunding agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i', r
estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

*** untabulated results including control variables

forvalues i=1(1)9{
reg tot_contr_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i' , r

estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

***

forvalues i=1(1)9{
reg MFC_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i', r
estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*******************************************************************************************************************************************************
***** PREPARE COMPUSTAT FILE USING EIN AND FYEAR AS MATCHING VARIABLE FOR MERGE
*******************************************************************************************************************************************************

clear all

set memory 1000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Compustat"

*** load raw data

use pension

*** generate 3-digit SIC code

gen sic3 = substr(sic,1,3)

*** make sic and gvkey available as numbers

gen sic1 = real(sic)
drop sic
gen sic = sic1
drop sic1

gen gvkey1 = real(gvkey)
drop gvkey
gen gvkey = gvkey1
drop gvkey1

*** use 1998 value to compute acrual values, sales growth and industry sales growth
*** otherwise we lose the entire first year of the sample (1999)

sort gvkey datadate

*** accrual components

gen COA = (act - che)
gen lagCOA = COA[_n-1] if gvkey==gvkey[_n-1]

gen COL = (lct - dlc)
gen lagCOL = COL[_n-1] if gvkey==gvkey[_n-1]

gen lagat = at[_n-1] if gvkey==gvkey[_n-1]

** sales growth

replace sale = 0 if sale <0
gen gs = (sale - sale[_n-1])/sale[_n-1] if gvkey == gvkey[_n-1]

*** generate 3 digit industry sales growth variable 

sort sic3 fyear
egen industry3_fyear = group(sic3 fyear)

sort industry3_fyear
by industry3_fyear: egen sale_ind = sum(sale)

sort sic3 fyear
gen ISG = (sale_ind - sale_ind[_n-1])/sale_ind[_n-1] if fyear==fyear[_n-1]+1 & sic3==sic3[_n-1]
replace ISG = -99 if ISG ==. 

edit sic3 fyear ISG sale_ind

** replace "-99" values with actual growth number
sort industry3_fyear
by industry3_fyear: egen ISG1 = max(ISG)

*** double check this makes sense (yes, it does)

edit sic3 fyear ISG sale_ind ISG1

drop ISG
rename ISG1 ISG

*** make sure we have same sample period

drop if fyear < 1999
drop if fyear > 2007

***
sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** create EIN number (there is a "-" in the compustat string)
*** and make sure EIN number is available

gen ein1 = substr(ein, 1, 2)
gen ein2 = substr(ein, 4, 7)
gen EIN = ein1 + ein2

drop if EIN == ""

***
sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

**** drop financials, utilities and government entities

drop if sic > 5999 & sic < 7000
drop if sic > 4899 & sic < 5000

**

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** double check that one EIN does not appear several times within a fiscal year

sort EIN fyear datadate at tic

egen id = group(EIN fyear)

sort id datadate

*** check wether id changes

gen idL = id - id[_n-1]

gen idL1 = id[_n+1]-id

*** drop observations in case it id stays constant (only retain the latest info within a fiscal year)

drop if idL1 ==0

drop id idL idL1

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

***********************************************************************************
*** merge with CCM pension accounting data
*** note, that pension accounting data is used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

***
sort gvkey fyear datadate at tic
egen id = group(gvkey fyear)

sort id datadate

*** check wether id changes

gen idL = id - id[_n-1]

gen idL1 = id[_n+1]-id

*** drop observations in case it id stays constant (only keep latest information)

drop if idL1 ==0

drop id idL idL1

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** actual merge with pension FASB data

sort gvkey datadate

merge 1:1 gvkey datadate using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Compustat/pension_robust.dta"

*** drop non merged data from pension accounting file
drop if _merge == 2
rename _merge _merge_FASB

***********************************************************************************
*** merge with Graham's simulated tax rates
*** note, that simulated tax rates are used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

sort gvkey fyear

merge 1:1 gvkey fyear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Tax rates/taxrates.dta"

*** drop non merged data from Graham's file
drop if _merge == 2
rename _merge _merge_tax

***********************************************************************************
*** merge with Gompers corporate governance index
*** note, that simulated tax rates are used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

sort gvkey fyear tic

merge 1:1 gvkey fyear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Gompers/Gindex.dta"

drop _merge

***********************************************************************************
*** prepare the main financial statement variables 
***********************************************************************************

sort gvkey fyear

xtset gvkey fyear

** $ variables

gen C = che

gen D = dlc + dltt

gen EMV = prcc_f*csho

gen MV = EMV + D

*** financial ratios
  
gen Q = MV/at

gen lagQ = l1.Q

gen BL = D/at

gen ML = D/MV

gen CR = C/at

gen size = log(at)

gen d_yield = (dvc + dvp)/EMV

gen prof = oibdp/at

gen NI = ib/at

*** Z-score components

gen X1 = (act - lct)/at

gen X2 = re/at

gen X3 = oiadp/at

gen X4 = EMV/D

gen X5 = sale/at

*** generate taxpayer status 

gen taxpayer = 1 if txfed > 0 & txfed !=.
replace taxpayer = 0 if taxpayer ==. & txfed !=.

gen taxpayer_adv = 2 if txfed > 0 & txfed !=.
replace tlcf = 0 if tlcf ==.
replace taxpayer_adv = 1 if txfed <= 0 & tlcf ==0
replace taxpayer_adv = 0 if taxpayer_adv ==. & txfed !=.

**** no information available for these CF statements

gen E_issue = sstk/at

gen div = dvc/at
gen div1 = dvc/lagat
gen div2 = (dvc + prstkc)/lagat

gen OCF = oancf/at
gen OCF1 = oancf/lagat

gen total_def = capx + aqc + dv

gen DEF = total_def/at

gen capex = capx/at
gen capex1 = capx/lagat

gen AQC = aqc/at

*** generate "action" dummies

gen th = 0.05

gen AI = 1 if AQC > th
replace AI = 0 if AI == .

gen EI = 1 if E_issue > th 
replace EI = 0 if EI ==.

*** generate alternative "action" dummies (2.5%)

gen th25 = 0.025

gen AI25 = 1 if AQC > th25
replace AI25 = 0 if AI25 == .

gen EI25 = 1 if E_issue > th25 
replace EI25 = 0 if EI25 ==.

*** generate alternative "action" dummies (7.5%)

gen th75 = 0.075

gen AI75 = 1 if AQC > th75
replace AI75 = 0 if AI75 == .

gen EI75 = 1 if E_issue > th75 
replace EI75 = 0 if EI75 ==.

***** 3 digit investment & dividend (fyear)

sort industry3_fyear

by industry3_fyear: egen ind_capex_3fyr = median(capex)
by industry3_fyear: egen ind_div_3fyr = median(div)


*** generate accrual variables

gen TACC = (COA - lagCOA - (COL - lagCOL) - dp)/lagat

**** additional financial constraint variables

gen TLDT = dltt/at

gen DIVPOS = 1 if dv >0
replace DIVPOS = 0 if DIVPOS ==.

*** generate industry variables

gen CND =1 if sic >= 0100 & sic <=0999
replace CND =1 if sic >= 2000 & sic <=2399
replace CND =1 if sic >= 2700 & sic <=2749
replace CND =1 if sic >= 2770 & sic <=2799
replace CND =1 if sic >= 3100 & sic <=3199
replace CND =1 if sic >= 3940 & sic <=3989
replace CND = 0 if CND ==.


gen CD =1 if sic >= 2500 & sic <=2519
replace CD =1 if sic >= 2590 & sic <=2599
replace CD =1 if sic >= 3630 & sic <=3659
replace CD =1 if sic >= 3710 & sic <=3711
replace CD =1 if sic >= 3714 & sic <=3714
replace CD =1 if sic >= 3716 & sic <=3716
replace CD =1 if sic >= 3750 & sic <=3751
replace CD =1 if sic >= 3792 & sic <=3792
replace CD =1 if sic >= 3900 & sic <=3939
replace CD =1 if sic >= 3990 & sic <=3999
replace CD = 0 if CD ==.


gen MAN =1 if sic >= 2520 & sic <=2589
replace MAN =1 if sic >= 2600 & sic <=2699
replace MAN =1 if sic >= 2750 & sic <=2769
replace MAN =1 if sic >= 3000 & sic <=3099
replace MAN =1 if sic >= 3200 & sic <=3569
replace MAN =1 if sic >= 3580 & sic <=3629
replace MAN =1 if sic >= 3700 & sic <=3709
replace MAN =1 if sic >= 3712 & sic <=3713
replace MAN =1 if sic >= 3715 & sic <=3715
replace MAN =1 if sic >= 3717 & sic <=3749
replace MAN =1 if sic >= 3752 & sic <=3791
replace MAN =1 if sic >= 3793 & sic <=3799
replace MAN =1 if sic >= 3830 & sic <=3839
replace MAN =1 if sic >= 3860 & sic <=3899
replace MAN = 0 if MAN ==.

gen EN =1 if sic >= 1200 & sic <=1399
replace EN =1 if sic >= 2900 & sic <=2999
replace EN = 0 if EN ==.

gen CHEM =1 if sic >= 2800 & sic <=2829
replace CHEM =1 if sic >= 2840 & sic <=2899
replace CHEM = 0 if CHEM ==.

gen BUS =1 if sic >= 3570 & sic <=3579
replace BUS =1 if sic >= 3660 & sic <=3692
replace BUS =1 if sic >= 3694 & sic <=3699
replace BUS =1 if sic >= 3810 & sic <=3829
replace BUS =1 if sic >= 7370 & sic <=7379
replace BUS = 0 if BUS ==.


gen UTIL =1 if sic >= 4800 & sic <=4899
replace UTIL =1 if sic >= 4900 & sic <=4949
replace UTIL = 0 if UTIL ==.

gen SALE =1 if sic >= 5000 & sic <=5999
replace SALE =1 if sic >= 7200 & sic <=7299
replace SALE =1 if sic >= 7600 & sic <=7699
replace SALE = 0 if SALE ==.

gen HLTH =1 if sic >= 2830 & sic <=2839
replace HLTH =1 if sic >= 3693 & sic <=3693
replace HLTH =1 if sic >= 3840 & sic <=3859
replace HLTH =1 if sic >= 8000 & sic <=8099
replace HLTH = 0 if HLTH ==.

gen FIN =1 if sic >= 6000 & sic <=6999
replace FIN = 0 if FIN ==.

gen OTH = 1 - HLTH - SALE - BUS - CHEM - EN - MAN - CD - CND - FIN - UTIL

*** sort the data again

sort EIN fyear

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save crsp_compustat, replace
****** load CCM sponsor file

clear all

set memory 1000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use crsp_compustat

**** MERGE WITH FORM 5500 

merge 1:m EIN fyear using "/Users/administrator_2014/Documents/Research/Pension manipulation/Results/longevity.dta"

drop if _merge != 3

** manually check merge quality
*edit conm SPONS_DFE_NAME

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** generate industry variable based on compustat (instead of form 5500)

drop industry
gen industry = "HLTH" if HLTH == 1
replace industry = "SALE" if SALE == 1
replace industry = "BUS" if BUS == 1
replace industry = "CHEM" if CHEM == 1
replace industry = "EN" if EN == 1
replace industry = "MAN" if MAN == 1
replace industry = "CD" if CD == 1
replace industry = "CND" if CND == 1
replace industry = "FIN" if FIN == 1
replace industry = "UTIL" if UTIL == 1
replace industry = "OTH" if OTH == 1

*** reminder: number of pension plans

*sort id

*drop plans

*sort gvkey
*egen plans = group(id)

*summ plans

*** account for fact that 1 firm might have several plans

drop id

sort EIN fyear year

egen id = group(EIN fyear)

sort id

*** now we compute pension variables at the level of the plan sponr

*** compute implied $-value of risky investments

replace risky = (1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp)*impl_TA

*** generate underfunding dummy

gen unfun = 1 if relfunding < 0
replace unfun = 0 if unfun ==.

summ unfun
summ unfun if unfun == 1

*** generate aggregate sponsor variables

by id: egen total_assets = sum(asset)
by id: egen total_liab = sum(liab)
by id: egen total_accr_liab = sum(accr_liab)

by id: egen total_tot_contr = sum(tot_contr)
by id: egen total_MFC = sum(MFC)
by id: egen total_AFR = sum(AFR)

by id: egen total_participants = sum(participants)
by id: egen total_part_ret = sum(part_ret)
by id: egen total_risky_nom = sum(risky)
by id: egen total_impl_TA = sum(impl_TA)

by id: egen sum_manip = sum(manip)
by id: egen sum_unfun = sum(unfun)
by id: egen sum_plans = count(fyear)

*** generate dispersion in actuarial assumptions

gen diff_int = interest - interest_RPA
by id: egen m_diff_int = mean(diff_int)
by id: egen min_diff_int = min(diff_int)
by id: egen max_diff_int = max(diff_int)

gen diff_LE = long_index_cs - long_GM83
by id: egen m_diff_LE = mean(diff_LE)
by id: egen min_diff_LE = min(diff_LE)
by id: egen max_diff_LE = max(diff_LE)

*** generate "weight" of each plan (based on CL)

gen weight = liab/total_liab

*** compute sponsor specific LE-assumptions (using weights)

gen long1 = long_index_cs*weight
gen long2 = long_GM83*weight

by id: egen total_longevity = sum(long1)
by id: egen total_longevity_GAM = sum(long2)

drop long1 long2

*** compute sponsor specific discount rate assumptions (using weights)

gen interest1 = interest*weight
gen interest1_RPA = interest_RPA*weight

by id: egen total_interest = sum(interest1)
by id: egen total_interest_RPA = sum(interest1_RPA)

drop interest1 interest1_RPA

summ id

*** now keep one observation per firm-year (i.e. per sponsor)

sort id

gen idL = id - id[_n-1]

drop if idL ==0

drop id idL

summ at

*** compute number of sponsors and years

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** descriptive information on manipulation across the same plans by a sponsor (in a given year)

gen manip_freq = sum_manip/sum_plans
summ manip_freq if sum_manip > 0, d

gen diff_diff_int = max_diff_int - min_diff_int
summ diff_diff_int if sum_manip > 0, d

gen diff_diff_LE = max_diff_LE - min_diff_LE
summ diff_diff_LE if sum_manip > 0, d

*** generate sponsor-specifc aggregate plan variables

gen diff_liabA = (total_liab - total_accr_liab)/total_accr_liab

gen LEA = total_longevity - total_longevity_GAM

gen D_interestA = total_interest - total_interest_RPA

gen relfundingA = (total_assets - total_liab)/total_liab
gen lagrelfundingA = l1.relfundingA

gen sizeA = log(total_assets)

gen durationA = 1 - total_part_ret/total_participants
replace durationA = durationA*100

gen riskyA = total_risky_nom/total_impl_TA
replace riskyA = riskyA*100

*** generate sponsor-specific sponsor/plan variables

gen total_tot_contr_at = total_tot_contr/at
gen total_tot_contr_at1 = total_tot_contr/lagat

gen total_MFC_at = total_MFC/at
gen total_MFC_at1 = total_MFC/lagat

gen total_tot_contr_E = total_tot_contr/seq

gen total_tot_contr_plassets = total_tot_contr/total_assets
gen total_MFC_plassets = total_MFC/total_assets

gen sensitivity = total_asset/oibdp

gen rel_size = total_liab/at

gen consol_liab = total_liab + D 
gen consol_assets = MV + total_assets 
gen consol_lev = consol_liab / consol_assets

gen consol_netliab = consol_liab - C
gen consol_netlev = consol_netliab / consol_assets

*** non-missing balance sheet data for required sponsor variables

drop if at ==.
drop if MV == .
drop if Q ==.
drop if BL ==.
drop if CR ==. 
drop if TLDT ==.
drop if TACC ==.
drop if size ==.
drop if X1 ==.
*drop if X4 ==. (because of all-equity firms, we want to keep them)

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing income statement data for required sponsor variables

drop if prof == .
drop if d_yield ==.
drop if NI ==.
drop if dv ==.
drop if DIVPOS ==.
drop if ISG ==.
drop if X2 ==.
drop if X3 ==.
drop if X5 ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing cash flow statement data for required sponsor variables

drop if OCF ==.
drop if capex ==.
drop if dvc ==.
drop if AQC ==.
drop if total_def ==.
drop if E_issue ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** drop if federal tax information is missing

drop if taxpayer ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing data for required sponsor/plan variables

drop if diff_liabA ==.
drop if LEA ==.
drop if D_interestA ==.
drop if relfundingA ==.
drop if sizeA ==.
drop if durationA ==.
drop if riskyA ==.

drop if total_tot_contr_E ==.
drop if total_tot_contr_plassets ==.

drop if sensitivity ==.

*** compute number of sponsors and years

sort gvkey fyear

egen sponsors = group(gvkey)

summ sponsors
drop sponsors

*** generate manipulation variable

gen manipA = 1 if diff_liabA > 0
replace manipA = 0 if manipA ==.

*** winsorize pension variables

centile diff_liabA, centile(.5 99.5)
replace diff_liabA = r(c_1) if diff_liabA < r(c_1)
replace diff_liabA = r(c_2) if diff_liabA > r(c_2)

centile relfundingA, centile(.5 99.5)
replace relfundingA = r(c_1) if relfundingA < r(c_1)
replace relfundingA = r(c_2) if relfundingA > r(c_2)

centile D_interestA, centile(.5 99.5)
replace D_interestA = r(c_1) if D_interestA < r(c_1)
replace D_interestA = r(c_2) if D_interestA > r(c_2)

centile durationA, centile(0.5 99.5)
replace durationA = r(c_1) if durationA < r(c_1)
replace durationA = r(c_2) if durationA > r(c_2)

centile sizeA, centile(0.5 99.5)
replace sizeA = r(c_1) if sizeA < r(c_1)
replace sizeA = r(c_2) if sizeA > r(c_2)

centile total_tot_contr_at, centile(0.5 99.5)
replace total_tot_contr_at = r(c_1) if total_tot_contr_at < r(c_1)
replace total_tot_contr_at = r(c_2) if total_tot_contr_at > r(c_2)

centile total_tot_contr_at1, centile(0.5 99.5)
replace total_tot_contr_at1 = r(c_1) if total_tot_contr_at1 < r(c_1) & total_tot_contr_at1 !=.
replace total_tot_contr_at1 = r(c_2) if total_tot_contr_at1 > r(c_2) & total_tot_contr_at1 !=.

centile total_MFC_at, centile(0.5 99.5)
replace total_MFC_at = r(c_1) if total_MFC_at < r(c_1)
replace total_MFC_at = r(c_2) if total_MFC_at > r(c_2)

centile total_MFC_at1, centile(0.5 99.5)
replace total_MFC_at1 = r(c_1) if total_MFC_at1 < r(c_1) & total_MFC_at1 !=.
replace total_MFC_at1 = r(c_2) if total_MFC_at1 > r(c_2) & total_MFC_at1 !=.

centile total_tot_contr_plassets, centile(0.5 99.5)
replace total_tot_contr_plassets = r(c_1) if total_tot_contr_plassets < r(c_1)
replace total_tot_contr_plassets = r(c_2) if total_tot_contr_plassets > r(c_2)

centile total_MFC_plassets, centile(0.5 99.5)
replace total_MFC_plassets = r(c_1) if total_MFC_plassets < r(c_1)
replace total_MFC_plassets = r(c_2) if total_MFC_plassets > r(c_2)

centile total_tot_contr_E, centile(0.5 99.5)
replace total_tot_contr_E = r(c_1) if total_tot_contr_E < r(c_1)
replace total_tot_contr_E = r(c_2) if total_tot_contr_E > r(c_2)

centile sensitivity, centile(0.5 99.5)
replace sensitivity = r(c_1) if sensitivity < r(c_1)
replace sensitivity = r(c_2) if sensitivity > r(c_2)

centile rel_size, centile(0.5 99.5)
replace rel_size = r(c_1) if rel_size < r(c_1)
replace rel_size = r(c_2) if rel_size > r(c_2)

centile consol_lev, centile(0.5 99.5)
replace consol_lev = r(c_1) if consol_lev < r(c_1)
replace consol_lev = r(c_2) if consol_lev > r(c_2)


*** winsorize ingredients of index variables

centile X1, centile(0.5 99.5)
replace X1 = r(c_1) if X1 < r(c_1)
replace X1 = r(c_2) if X1 > r(c_2)

centile X2, centile(0.5 99.5)
replace X2 = r(c_1) if X2 < r(c_1)
replace X2 = r(c_2) if X2 > r(c_2)

centile X3, centile(0.5 99.5)
replace X3 = r(c_1) if X3 < r(c_1)
replace X3 = r(c_2) if X3 > r(c_2)

centile X4, centile(0.5 95)
replace X4 = r(c_1) if X4 < r(c_1) & X4 !=.
replace X4 = r(c_2) if X4 > r(c_2) & X4 !=.
*** note: because of high fraction of almost all-equity financed firms we winsorze X4 at the 95% level

centile X5, centile(0.5 99.5)
replace X5 = r(c_1) if X5 < r(c_1)
replace X5 = r(c_2) if X5 > r(c_2)

** generate z-score based on winsorized components

gen Z = 1.2*X1 + 1.4*X2 + 3.3*X3 + 0.6*X4 + 1*X5
summ Z at

centile Z, centile(0.5 99.5)
replace Z = r(c_1) if Z < r(c_1) 
replace Z = r(c_2) if Z > r(c_2) 

summ Z, d

** winsorize BS compustat variables

centile Q, centile(0.5 99.5)
replace Q = r(c_1) if Q < r(c_1)
replace Q = r(c_2) if Q > r(c_2)

centile BL, centile(0.5 99.5)
replace BL = r(c_1) if BL < r(c_1)
replace BL = r(c_2) if BL > r(c_2)

centile CR, centile(0.5 99.5)
replace CR = r(c_1) if CR < r(c_1)
replace CR = r(c_2) if CR > r(c_2)

centile TLDT, centile(0.5 99.5)
replace TLDT = r(c_1) if TLDT < r(c_1)
replace TLDT = r(c_2) if TLDT > r(c_2)

centile TACC, centile(0.5 99.5)
replace TACC = r(c_1) if TACC < r(c_1) 
replace TACC = r(c_2) if TACC > r(c_2) 

centile size, centile(0.5 99.5)
replace size = r(c_1) if size < r(c_1)
replace size = r(c_2) if size > r(c_2)

** winsorize IS compustat variables

centile prof, centile(0.5 99.5)
replace prof = r(c_1) if prof < r(c_1)
replace prof = r(c_2) if prof > r(c_2)

centile d_yield, centile(0.5 99.5)
replace d_yield = r(c_1) if d_yield < r(c_1)
replace d_yield = r(c_2) if d_yield > r(c_2)

centile NI, centile(0.5 99.5)
replace NI = r(c_1) if NI < r(c_1)
replace NI = r(c_2) if NI > r(c_2)

centile div, centile(0.5 99.5)
replace div = r(c_1) if div < r(c_1)
replace div = r(c_2) if div > r(c_2)

centile gs, centile(0.5 99.5)
replace gs = r(c_1) if gs < r(c_1) 
replace gs = r(c_2) if gs > r(c_2) 

** winsorize CF compustat variables

centile OCF, centile(0.5 99.5)
replace OCF = r(c_1) if OCF < r(c_1) 
replace OCF = r(c_2) if OCF > r(c_2)

centile OCF1, centile(0.5 99.5)
replace OCF1 = r(c_1) if OCF1 < r(c_1) & OCF1 !=.
replace OCF1 = r(c_2) if OCF1 > r(c_2) & OCF1 !=.

centile capex, centile(0.5 99.5)
replace capex = r(c_1) if capex < r(c_1)
replace capex = r(c_2) if capex > r(c_2)

centile capex1, centile(0.5 99.5)
replace capex1 = r(c_1) if capex1 < r(c_1) & capex1 !=.
replace capex1 = r(c_2) if capex1 > r(c_2) & capex1 !=.

centile AQC, centile(0.5 99.5)
replace AQC = r(c_1) if AQC < r(c_1)
replace AQC = r(c_2) if AQC > r(c_2)

centile div1, centile(0.5 99.5)
replace div1 = r(c_1) if div1 < r(c_1) & div1 !=.
replace div1 = r(c_2) if div1 > r(c_2) & div1 !=.

centile div2, centile(0.5 99.5)
replace div2 = r(c_1) if div2 < r(c_1) & div2 !=.
replace div2 = r(c_2) if div2 > r(c_2) & div2 !=.

centile DEF, centile(0.5 99.5)
replace DEF = r(c_1) if DEF < r(c_1) & DEF !=.
replace DEF = r(c_2) if DEF > r(c_2) & DEF !=.

*** GENERATE WHITED WU INDEX

gen WW = -0.091*OCF - 0.062*DIVPOS + 0.021*TLDT - 0.044*size + 0.102*ISG - 0.035*gs

*** GENERATE KAPLAN ZINGALES INDEX

gen KZ = -1.001909*OCF + 3.139193*BL - 39.36780*div - 1.314759*CR + 0.2826389*Q
centile KZ, centile(0.5 99.5)

*** gen ecapex and ediv

gen ecapex = capex - ind_capex_3fyr
gen ediv = div - ind_div_3fyr

** record fractions as percentage points

replace consol_lev = consol_lev*100

replace total_tot_contr_E = total_tot_contr_E*100

replace total_tot_contr_at = total_tot_contr_at*100
replace total_tot_contr_plassets = total_tot_contr_plassets*100

replace total_MFC_at = total_MFC_at*100
replace total_MFC_plassets = total_MFC_plassets*100

replace tax1 = tax1*100
replace tax2 = tax2*100

replace diff_liabA = diff_liabA*100

replace relfundingA = relfundingA*100

*** generate positive and negative funding variable

gen p_relfundingA = relfundingA if relfundingA >=0
replace p_relfundingA = 0 if p_relfundingA ==.

gen n_relfundingA = relfundingA*(-1) if relfundingA < 0
replace n_relfundingA = 0 if n_relfundingA ==.

*** generate cash deficit indicator

gen deficit = 1 if DEF > OCF
replace deficit = 0 if deficit ==.


cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save longevity_compustat, replace


**** ANALYSIS OF PENSION PLAN SPONSORS

clear all

set memory 3000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity_compustat 

**** descriptive info on pension liability gap

summ diff_liabA, d

summ diff_liabA if diff_liabA >0
gen N = r(N)
summ diff_liabA

display N/r(N)

*** number of plans

sort gvkey year
gen count = 1
replace count = count[_n-1] + 1 if gvkey == gvkey[_n-1]

gen ncount = count
replace ncount =. if ncount[_n+1] !=. & gvkey == gvkey[_n+1]

edit gvkey year count ncount

*** average and medium number of observations per plan

summ ncount,d

** generate number of plans each year

sort year
by year: egen obs = count(gvkey)

*** define total number of manipulative years by plan sponsor

sort gvkey fyear

by gvkey: egen sum_manipA = sum(manipA)
by gvkey: egen num = count(manipA)

*edit gvkey fyear manip sum_manipA num

*** generate number of plan-years by year and manip

sort year gvkey

by year: egen manipA_obs = count(manipA) if manipA > 0
by year: egen nomanipA_obs = count(manipA) if manipA == 0

*** Table 3, Panel B

tabstat total_accr_liab total_liab diff_liabA total_asset relfundingA total_interest total_interest_RPA D_interestA long_index_cs long_GM83 LEA sizeA durationA riskyA obs, by(year)

*** replication of full sample tables (Section 4)

*** Original Table 4 analysis - displayed in Online Appendix Table 5

reg diff_liabA relfundingA, r
estimates store OLS1

reg diff_liabA relfundingA sizeA durationA riskyA, r
estimates store OLS2

reg diff_liabA relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liabA relfundingA, fe
estimates store FE1

xtscc diff_liabA relfundingA sizeA durationA riskyA, fe
estimates store FE2

xtscc diff_liabA relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Original Table 6 analysis - displayed in Online Appendix Table 6

reg D_interest relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfundingA n_relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfundingA n_relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear


*** Original Table 7 analysis - displayed in Online Appendix Table 7

gen dum_neg = 1 if LEA < 0
replace dum_neg = 0 if dum_neg ==.

logit dum_neg relfundingA, vce(robust) 
estimates store reg1

logit dum_neg relfundingA sizeA durationA riskyA, vce(robust)
estimates store reg2

logit dum_neg relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfundingA n_relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** Original Table 9, Panel A analysis - displayed in Online Appendix Table 8, Panel A

reg total_tot_contr_plassets manipA if relfundingA <=0, r
estimates store reg1

reg total_tot_contr_plassets manipA relfundingA if relfundingA <=0, r
estimates store reg2

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA if relfundingA <=0 , r
estimates store reg3

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg4

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg5

xtscc total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** Original Table 9, Panel B analysis - displayed in Online Appendix Table 8, Panel B

reg total_MFC_plassets manipA if relfundingA <=0, r
estimates store reg1

reg total_MFC_plassets manipA relfundingA if relfundingA <=0, r
estimates store reg2

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA if relfundingA <=0, r
estimates store reg3

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg4

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom d2 d3 d4 d5 d6 d7 d8 d9 d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg5

xtscc total_MFC_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** some untabulated comparisons

tabstat total_tot_contr pbec, by(manipA)

tabstat total_accr_liab total_liab pbpro, by(manipA)

tabstat pbarr total_interest_RPA total_interest, by(manipA) 

*** Table 10: compare manipulative (Panel A) to non-manipulative firms (Panel B) 

tabstat manipA_obs relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1 TACC ppror g pbarr deficit if manipA > 0, by(year)

tabstat nomanipA_obs relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1  TACC ppror g pbarr deficit if manipA == 0, by(year)

** get the number of observations for each variable

summ relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1 TACC ppror g pbarr deficit if manipA > 0

summ relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1  TACC ppror g pbarr deficit if manipA == 0

*** Table 11: determinant regressions

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg1

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg2

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg3

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg4

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg5

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** untabulated info (used for interpretation)

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC deficit HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if g !=.
logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC deficit HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if g!=.

*** untabulated: OLS regressions with G

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg3

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estimates clear 

*** untabulated: FE regressions with G

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg5

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estimates clear 

*** difference in ratios

ttest capex, by(manipA)
ttest div, by(manipA)

ttest ecapex, by(manipA)
ttest ediv, by(manipA)


**************************************************************************************************************
*** Inv/CF Regressions
**************************************************************************************************************

sort gvkey fyear

*** compute cash flow before pension contributions

replace total_MFC_at1 = 0 if lagrelfundingA > 0

gen OCFa1 = OCF1 + total_tot_contr_at1
gen OCFb1 = OCF1 + total_MFC_at1

** compute interaction term

gen IAa1 = manipA*total_tot_contr_at1
gen IAb1 = manipA*total_MFC_at1

*** Table 12, Panel A

xtscc capex1 OCFa1 total_tot_contr_at1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc capex1 manipA OCFa1 total_tot_contr_at1 IAa1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc capex1 manipA OCFa1 total_tot_contr_at1 IAa1 lagQ lagrelfundingA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed)
estimates clear 

*** Table 12, Panel B

xtscc capex1 OCFb1 total_MFC_at1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc capex1 manipA OCFb1 total_MFC_at1 IAb1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc capex1 manipA OCFb1 total_MFC_at1 IAb1 lagQ lagrelfundingA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear 

*** difference in equity issues and acquisition frequencies

ttest EI, by(manipA)
ttest AI, by(manipA)

ttest AI25, by(manipA)
ttest EI25, by(manipA)

ttest AI75, by(manipA)
ttest EI75, by(manipA)

**************************************************************************************************************
*** Credit risk test
**************************************************************************************************************
summ relfundingA p_relfundingA

*** Table 13, Panel A

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND , r
estimates store reg1

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2
predict resid_OLS, residuals
predict yhat_OLS

xtscc D_interestA Z consol_lev rel_size sizeA durationA riskyA,  fe
estimates store reg3

xtscc D_interestA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,   fe
estimates store reg4

areg D_interestA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, absorb(gvkey) r
predict resid_FE, residual
predict yhat, xbd

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Table 13, Panel B

reg resid_OLS relfundingA, r
estimates store OLS1_SS

reg resid_OLS p_relfundingA n_relfundingA, r
estimates store OLS2_SS

xtscc resid_FE relfundingA, fe
estimates store FE1_SS 

xtscc resid_FE p_relfundingA n_relfundingA, fe
estimates store FE2_SS

estout OLS1_SS OLS2_SS FE1_SS FE2_SS, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1_SS OLS2_SS FE1_SS FE2_SS, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*** untabulated
reg D_interestA p_relfundingA n_relfundingA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
xtscc D_interestA p_relfundingA n_relfundingA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,   fe

** check whether this makes sense

gen res = D_interestA - yhat

edit res resid_FE

** check whether this makes sense

gen res_OLS = D_interestA - yhat_OLS

edit res_OLS resid_OLS

*** end of check

drop res* yhat*

************************************************************************************
*** Online Appendix: untabulated double sort consolidated leverage and Z-score
************************************************************************************

centile consol_lev, centile(50)
gen CL_p50 = r(c_1) 

centile Z, centile(50)
gen Z_p50 = r(c_1) 

*** consolidated leverage buckets

gen CL_1 = 1 if consol_lev <= CL_p50 
replace CL_1 = 0 if CL_1 == .

gen CL_2 = 1 if consol_lev > CL_p50 
replace CL_2 = 0 if CL_2 == .

*** Z-score buckets

gen Z_1 = 1 if Z <= Z_p50 
replace Z_1 = 0 if Z_1 == .

gen Z_2 = 1 if Z > Z_p50 
replace Z_2 = 0 if Z_2 == .


*** create 4 "portfolios"

gen CL_PF = 1 if CL_1 == 1
gen Z_PF = 1 if Z_1 == 1

forvalues i=2(1)2{
replace CL_PF = `i' if CL_`i' == 1
replace Z_PF = `i' if Z_`i' == 1
}

** display corresponding sort characteristics

tabsort CL_PF Z_PF, su(consol_lev) nocsort norsort

tabsort CL_PF Z_PF, su(Z) nocsort norsort


**perform 2 stage regression model

sort CL_PF gvkey fyear

*replace p_relfundingA = relfundingA

*replace n_relfundingA = relfundingA

** 1st stage

forvalues j=1(1)2{
reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if CL_PF == `j', r
predict resid_PF_`j', residual
estimates store PF_`j'

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if Z_PF == `j', r
predict Zresid_PF_`j', residual
estimates store ZPF_`j'
}

** 2nd stage
 
forvalues j=1(1)2{
reg resid_PF_`j' p_relfundingA n_relfundingA if CL_PF == `j', r
estimates store PF_`j'
reg Zresid_PF_`j' p_relfundingA n_relfundingA if Z_PF == `j', r
estimates store ZPF_`j'

}

estout ZPF_1 ZPF_2 PF_1 PF_2 , cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout ZPF_1 ZPF_2 PF_1 PF_2, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

drop resid_PF_* Zresid_PF_* 


*** this file appends the raw data for 2011 and 2012
*** this file cleans the data 

clear all

set memory 4000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

use raw_2012

append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest/raw_2011.dta"

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate DB dummy

gen DB_string = substr(type_pension_bnft_code,1,1)
gen DB = 1 if DB_string == "1"
replace DB = 0 if DB ==.

*** generate DC dummy

gen DC_string = substr(type_pension_bnft_code,1,1)
gen DC = 1 if DC_string == "2"
replace DC = 0 if DC ==.

*** generate other dummy

gen oth = 1 if DC == 0 & DB == 0
replace oth = 0 if oth ==.

gen date = date(sb_plan_year_begin_date, "YMD")
format date %td

gen year_date = year(date)
gen month_date = month(date)

*** focus on DB plans

drop if DB != 1
drop oth

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

summ DB

*** drop multi-employer plans and other animals

drop if type_plan_entity_cd != 2

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** check whether some plan years appear twice

sort ID year

egen id = group(ID year)

sort id

*** check wether id changes

gen idL = id - id[_n-1]
gen idL1 = id[_n+1]-id

*** drob observations in case it id stays constant (forward and backward)

drop if idL ==0
drop if idL1 ==0

drop id idL idL1

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** set time parameter and compute sample

sort ID year

egen id = group(ID)

sort id year

xtset id year

summ DB id year

*** drop small plans (total particpation is only available BOY. General, 6)

gen participants = tot_partcp_boy_cnt
drop if participants < 100

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate liability variable 

gen liab = sb_tot_fndng_tgt_amt
drop if liab == .
drop if liab <=0

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen asset = sb_curr_value_ast_01_amt
drop if asset ==.
drop if asset <=0


*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate funding variable

gen relfunding = (asset - liab)/liab
drop if relfunding ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate mandatory pension contribution
sort id year

gen mand_contrib = sb_fndng_rqmt_tot_amt
drop if mand_contrib ==.
summ mand_contrib, d

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate MPC in % of assets

gen rel_mand_contrib = mand_contrib/asset

*** generate change in MPC


sort id year
gen D_mand_contrib = (mand_contrib - l1.mand_contrib)/l1.mand_contrib

*** generate total contributions

*gen contrib = sb_contr_alloc_curr_yr_02_amt
gen contrib = sb_tot_emplr_contrib_amt
drop if contrib ==.
summ contrib, d

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen rel_contrib = sb_tot_emplr_contrib_amt/asset

*** generate excess contributions

gen exc_contrib = contrib - mand_contrib
drop if exc_contrib ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen rel_exc_contrib = exc_contrib/asset

**** create industry dummmies

tostring business_code, generate(NAICS)

****

gen agr = 1 if substr(NAICS, 1,2) == "11"
replace agr = 0 if agr ==.

gen min = 1 if substr(NAICS, 1,2) == "21"
replace min = 0 if min ==.

gen util = 1 if substr(NAICS, 1,2) == "22"
replace util = 0 if util ==.

gen cstrc = 1 if substr(NAICS, 1,2) == "23"
replace cstrc = 0 if cstrc ==.

gen man = 1 if substr(NAICS, 1,2) == "31"
replace man = 1 if substr(NAICS, 1,2) == "32"
replace man = 1 if substr(NAICS, 1,2) == "33"
replace man = 0 if man ==.

gen whle = 1 if substr(NAICS, 1,2) == "42"
replace whle = 0 if whle ==.

gen retl = 1 if substr(NAICS, 1,2) == "44"
replace retl = 1 if substr(NAICS, 1,2) == "45"
replace retl = 0 if retl ==.

gen trans = 1 if substr(NAICS, 1,2) == "48"
replace trans = 1 if substr(NAICS, 1,2) == "49"
replace trans = 0 if trans ==.

gen inf = 1 if substr(NAICS, 1,2) == "51"
replace inf = 0 if inf ==.

gen fin = 1 if substr(NAICS, 1,2) == "52"
replace fin = 0 if fin ==.

gen real = 1 if substr(NAICS, 1,2) == "53"
replace real = 0 if real ==.

gen prof = 1 if substr(NAICS, 1,2) == "54"
replace prof = 0 if prof ==.

gen hldg = 1 if substr(NAICS, 1,2) == "55"
replace hldg = 0 if hldg ==.

gen admin = 1 if substr(NAICS, 1,2) == "56"
replace admin = 0 if admin ==.

gen edu = 1 if substr(NAICS, 1,2) == "61"
replace edu = 0 if edu ==.

gen hlth = 1 if substr(NAICS, 1,2) == "62"
replace hlth = 0 if hlth ==.

gen arts = 1 if substr(NAICS, 1,2) == "71"
replace arts = 0 if arts ==.

gen accom = 1 if substr(NAICS, 1,2) == "72"
replace accom = 0 if accom ==.

gen oth = 1 if substr(NAICS, 1,2) == "81"
replace oth = 1 if substr(NAICS, 1,2) == "92"
replace oth = 0 if oth ==.

gen test = agr + min + util + cstrc + man + whle + retl + trans + inf + fin + real + prof + hldg + admin + edu + hlth + arts + accom + oth

summ test if test == 0

*** industry classification: visual inspection suggests that if test == 0, then missing or unclassified numbers

gen industry = "agr" if agr ==1
replace industry = "min" if min == 1
replace industry = "util" if util == 1
replace industry = "cstrc" if cstrc == 1
replace industry = "man" if man == 1
replace industry = "whle" if whle == 1
replace industry = "retl" if retl == 1
replace industry = "trans" if trans == 1
replace industry = "inf" if inf == 1
replace industry = "fin" if fin == 1
replace industry = "real" if real == 1
replace industry = "prof" if prof == 1
replace industry = "hldg" if hldg == 1
replace industry = "admin" if admin == 1
replace industry = "edu" if edu == 1
replace industry = "hlth" if hlth == 1
replace industry = "arts" if arts == 1
replace industry = "accom" if accom == 1
replace industry = "oth" if oth == 1

*** size variable

gen size = log(asset) 

*** duration variable

replace rtd_sep_partcp_rcvg_cnt= 0 if rtd_sep_partcp_rcvg_cnt ==.
replace benef_rcvg_bnft_cnt = 0 if benef_rcvg_bnft_cnt ==.

gen part_ret = rtd_sep_partcp_rcvg_cnt + benef_rcvg_bnft_cnt

gen duration = 1 - part_ret/participants

**** focus on asset allocation


*** generate investment variables

gen cash = non_int_bear_cash_eoy_amt
replace cash = 0 if cash ==.
 
gen cash_inv = int_bear_cash_eoy_amt
replace cash_inv = 0 if cash_inv ==.

gen AR = emplr_contrib_eoy_amt + partcp_contrib_eoy_amt + other_receivables_eoy_amt
replace AR = 0 if AR ==.

gen US_treas = govt_sec_eoy_amt
replace US_treas = 0 if US_treas ==.

gen debt_corp = corp_debt_preferred_eoy_amt + corp_debt_other_eoy_amt
replace debt_corp = 0 if debt_corp ==.

gen equity = pref_stock_eoy_amt + common_stock_eoy_amt
replace equity = 0 if equity ==.

gen JV = joint_venture_eoy_amt
replace JV = 0 if JV ==.

gen RE = real_estate_eoy_amt
replace RE = 0 if RE ==.

gen loans = other_loans_eoy_amt + partcp_loans_eoy_amt
replace loans = 0 if loans ==.

gen com_trust = int_common_tr_eoy_amt
replace com_trust = 0 if com_trust ==.

gen pool_trust = int_pool_sep_acct_eoy_amt
replace pool_trust = 0 if pool_trust ==.

gen master_trust = int_master_tr_eoy_amt
replace master_trust = 0 if master_trust ==.

gen inv = int_103_12_invst_eoy_amt
replace inv = 0 if inv ==.

gen funds = int_reg_invst_co_eoy_amt
replace funds = 0 if funds ==.

gen insurance = ins_co_gen_acct_eoy_amt
replace insurance = 0 if insurance ==.

gen other = oth_invst_eoy_amt
replace other = 0 if other ==.

gen employer = emplr_sec_eoy_amt + emplr_prop_eoy_amt
replace employer = 0 if employer ==.

gen buildings = bldgs_used_eoy_amt
replace buildings = 0 if buildings ==.

gen TA = tot_assets_eoy_amt

gen impl_TA = cash + cash_inv + AR + US_treas + debt_corp + equity + JV + RE + loans +  com_trust +  pool_trust + master_trust + inv + funds + insurance + other + employer + buildings

summ TA impl_TA

*** drop negative values
drop if cash < 0
drop if cash_inv < 0
drop if AR < 0
drop if US_treas < 0
drop if debt_corp < 0
drop if equity < 0
drop if JV < 0
drop if RE < 0
drop if loans < 0
drop if com_trust < 0
drop if pool_trust < 0
drop if master_trust < 0
drop if inv < 0
drop if funds < 0
drop if insurance < 0
drop if other < 0
drop if employer < 0
drop if buildings < 0

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

***

gen rel_cash = cash/impl_TA
gen rel_cash_inv = cash_inv/impl_TA
gen rel_AR = AR/impl_TA
gen rel_US_treas = US_treas/impl_TA
gen rel_debt_corp = debt_corp/impl_TA
gen rel_equity = equity/impl_TA
gen rel_JV = JV/impl_TA
gen rel_RE = RE/impl_TA
gen rel_loans = loans/impl_TA
gen rel_com_trust = com_trust/impl_TA
gen rel_master_trust = master_trust/impl_TA
gen rel_pool_trust = pool_trust/impl_TA
gen rel_inv = inv/impl_TA
gen rel_funds = funds/impl_TA
gen rel_insurance = insurance/impl_TA
gen rel_other = other/impl_TA
gen rel_employer = employer/impl_TA
gen rel_buildings = buildings/impl_TA


*** define risky assets

gen risky = 1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp
drop if risky ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

summ risky, d 

*** tset the variable

gen myear= ym(year_date,month_date)

format myear %tm

sort ID myear
drop id
egen id = group(ID)

sort id myear
xtset id myear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL"

save data, replace

****
clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

*** manually build up the dataset 
*** reason: we need to enter the segmented yield curve boundaries manually

set obs 1

generate year_date = 2010 in 1
gen month_date = 1 in 1

forvalues i=2(1)12{
set obs `i'
replace year_date = 2010 in `i' 
replace month_date = `i'  in `i' 
}

set obs 13
replace year_date = 2011 in 13
replace month_date =1 in 13

forvalues i=14(1)24{
set obs `i'
replace year_date = 2011 in `i' 
replace month_date = (`i' - 12)  in `i'
}

set obs 25
replace year_date = 2012 in 25
replace month_date =1 in 25

forvalues i=26(1)36{
set obs `i'
replace year_date = 2012 in `i' 
replace month_date = (`i' - 24)  in `i' 
}

** generate monthly variables

gen myear= ym(year_date,month_date)

format myear %tm

tset myear

**** the segement rates are obtains from the IRS
***http://www.irs.gov/Retirement-PLans/Funding-Yield-Curve-Segment-Rates (hardcopy available)


*** official segment rates in 2010

gen reg_interest_seg1 = 460 if year_date == 2010 & month_date == 1
gen reg_interest_seg2 = 665 if year_date == 2010 & month_date == 1
gen reg_interest_seg3 = 676 if year_date == 2010 & month_date == 1

replace reg_interest_seg1 = 451 if year_date == 2010 & month_date == 2
replace reg_interest_seg2 = 664 if year_date == 2010 & month_date == 2
replace reg_interest_seg3 = 675 if year_date == 2010 & month_date == 2

replace reg_interest_seg1 = 444 if year_date == 2010 & month_date == 3
replace reg_interest_seg2 = 662 if year_date == 2010 & month_date == 3
replace reg_interest_seg3 = 674 if year_date == 2010 & month_date == 3

replace reg_interest_seg1 = 435 if year_date == 2010 & month_date == 4
replace reg_interest_seg2 = 659 if year_date == 2010 & month_date == 4
replace reg_interest_seg3 = 672 if year_date == 2010 & month_date == 4

replace reg_interest_seg1 = 426 if year_date == 2010 & month_date == 5
replace reg_interest_seg2 = 656 if year_date == 2010 & month_date == 5
replace reg_interest_seg3 = 670 if year_date == 2010 & month_date == 5

replace reg_interest_seg1 = 416 if year_date == 2010 & month_date == 6
replace reg_interest_seg2 = 652 if year_date == 2010 & month_date == 6
replace reg_interest_seg3 = 668 if year_date == 2010 & month_date == 6

replace reg_interest_seg1 = 405 if year_date == 2010 & month_date == 7
replace reg_interest_seg2 = 647 if year_date == 2010 & month_date == 7
replace reg_interest_seg3 = 665 if year_date == 2010 & month_date == 7

replace reg_interest_seg1 = 392 if year_date == 2010 & month_date == 8
replace reg_interest_seg2 = 640 if year_date == 2010 & month_date == 8
replace reg_interest_seg3 = 661 if year_date == 2010 & month_date == 8

replace reg_interest_seg1 = 378 if year_date == 2010 & month_date == 9
replace reg_interest_seg2 = 631 if year_date == 2010 & month_date == 9
replace reg_interest_seg3 = 657 if year_date == 2010 & month_date == 9

replace reg_interest_seg1 = 361 if year_date == 2010 & month_date == 10
replace reg_interest_seg2 = 620 if year_date == 2010 & month_date == 10
replace reg_interest_seg3 = 653 if year_date == 2010 & month_date == 10

replace reg_interest_seg1 = 337 if year_date == 2010 & month_date == 11
replace reg_interest_seg2 = 604 if year_date == 2010 & month_date == 11
replace reg_interest_seg3 = 649 if year_date == 2010 & month_date == 11

replace reg_interest_seg1 = 314 if year_date == 2010 & month_date == 12
replace reg_interest_seg2 = 590 if year_date == 2010 & month_date == 12
replace reg_interest_seg3 = 646 if year_date == 2010 & month_date == 12

*** official segment rates in 2011

replace reg_interest_seg1 = 294 if year_date == 2011 & month_date == 1
replace reg_interest_seg2 = 582 if year_date == 2011 & month_date == 1
replace reg_interest_seg3 = 646 if year_date == 2011 & month_date == 1

replace reg_interest_seg1 = 281 if year_date == 2011 & month_date == 2
replace reg_interest_seg2 = 576 if year_date == 2011 & month_date == 2
replace reg_interest_seg3 = 646 if year_date == 2011 & month_date == 2

replace reg_interest_seg1 = 267 if year_date == 2011 & month_date == 3
replace reg_interest_seg2 = 569 if year_date == 2011 & month_date == 3
replace reg_interest_seg3 = 644 if year_date == 2011 & month_date == 3

replace reg_interest_seg1 = 251 if year_date == 2011 & month_date == 4
replace reg_interest_seg2 = 559 if year_date == 2011 & month_date == 4
replace reg_interest_seg3 = 638 if year_date == 2011 & month_date == 4

replace reg_interest_seg1 = 238 if year_date == 2011 & month_date == 5
replace reg_interest_seg2 = 551 if year_date == 2011 & month_date == 5
replace reg_interest_seg3 = 636 if year_date == 2011 & month_date == 5

replace reg_interest_seg1 = 227 if year_date == 2011 & month_date == 6
replace reg_interest_seg2 = 543 if year_date == 2011 & month_date == 6
replace reg_interest_seg3 = 634 if year_date == 2011 & month_date == 6

replace reg_interest_seg1 = 218 if year_date == 2011 & month_date == 7
replace reg_interest_seg2 = 536 if year_date == 2011 & month_date == 7
replace reg_interest_seg3 = 633 if year_date == 2011 & month_date == 7

replace reg_interest_seg1 = 211 if year_date == 2011 & month_date == 8
replace reg_interest_seg2 = 531 if year_date == 2011 & month_date == 8
replace reg_interest_seg3 = 632 if year_date == 2011 & month_date == 8

replace reg_interest_seg1 = 206 if year_date == 2011 & month_date == 9
replace reg_interest_seg2 = 525 if year_date == 2011 & month_date == 9
replace reg_interest_seg3 = 632 if year_date == 2011 & month_date == 9

replace reg_interest_seg1 = 203 if year_date == 2011 & month_date == 10
replace reg_interest_seg2 = 520 if year_date == 2011 & month_date == 10
replace reg_interest_seg3 = 630 if year_date == 2011 & month_date == 10

replace reg_interest_seg1 = 201 if year_date == 2011 & month_date == 11
replace reg_interest_seg2 = 516 if year_date == 2011 & month_date == 11
replace reg_interest_seg3 = 628 if year_date == 2011 & month_date == 11

replace reg_interest_seg1 = 199 if year_date == 2011 & month_date == 12
replace reg_interest_seg2 = 512 if year_date == 2011 & month_date == 12
replace reg_interest_seg3 = 624 if year_date == 2011 & month_date == 12

*** official segment rates in 2012

replace reg_interest_seg1 = 198 if year_date == 2012 & month_date == 1
replace reg_interest_seg2 = 507 if year_date == 2012 & month_date == 1
replace reg_interest_seg3 = 619 if year_date == 2012 & month_date == 1

replace reg_interest_seg1 = 196 if year_date == 2012 & month_date == 2
replace reg_interest_seg2 = 501 if year_date == 2012 & month_date == 2
replace reg_interest_seg3 = 613 if year_date == 2012 & month_date == 2

replace reg_interest_seg1 = 193 if year_date == 2012 & month_date == 3
replace reg_interest_seg2 = 495 if year_date == 2012 & month_date == 3
replace reg_interest_seg3 = 607 if year_date == 2012 & month_date == 3

replace reg_interest_seg1 = 190 if year_date == 2012 & month_date == 4
replace reg_interest_seg2 = 490 if year_date == 2012 & month_date == 4
replace reg_interest_seg3 = 601 if year_date == 2012 & month_date == 4

replace reg_interest_seg1 = 187 if year_date == 2012 & month_date == 5
replace reg_interest_seg2 = 484 if year_date == 2012 & month_date == 5
replace reg_interest_seg3 = 596 if year_date == 2012 & month_date == 5

replace reg_interest_seg1 = 184 if year_date == 2012 & month_date == 6
replace reg_interest_seg2 = 479 if year_date == 2012 & month_date == 6
replace reg_interest_seg3 = 590 if year_date == 2012 & month_date == 6

replace reg_interest_seg1 = 181 if year_date == 2012 & month_date == 7
replace reg_interest_seg2 = 473 if year_date == 2012 & month_date == 7
replace reg_interest_seg3 = 585 if year_date == 2012 & month_date == 7

replace reg_interest_seg1 = 177 if year_date == 2012 & month_date == 8
replace reg_interest_seg2 = 467 if year_date == 2012 & month_date == 8
replace reg_interest_seg3 = 578 if year_date == 2012 & month_date == 8

replace reg_interest_seg1 = 175 if year_date == 2012 & month_date == 9
replace reg_interest_seg2 = 462 if year_date == 2012 & month_date == 9
replace reg_interest_seg3 = 572 if year_date == 2012 & month_date == 9

replace reg_interest_seg1 = 172 if year_date == 2012 & month_date == 10
replace reg_interest_seg2 = 458 if year_date == 2012 & month_date == 10
replace reg_interest_seg3 = 567 if year_date == 2012 & month_date == 10

replace reg_interest_seg1 = 169 if year_date == 2012 & month_date == 11
replace reg_interest_seg2 = 453 if year_date == 2012 & month_date == 11
replace reg_interest_seg3 = 560 if year_date == 2012 & month_date == 11

replace reg_interest_seg1 = 166 if year_date == 2012 & month_date == 12
replace reg_interest_seg2 = 447 if year_date == 2012 & month_date == 12
replace reg_interest_seg3 = 552 if year_date == 2012 & month_date == 12

*** official segment rates in 2013

replace reg_interest_seg1 = 162 if year_date == 2013 & month_date == 1
replace reg_interest_seg2 = 440 if year_date == 2013 & month_date == 1
replace reg_interest_seg3 = 545 if year_date == 2013 & month_date == 1

replace reg_interest_seg1 = 158 if year_date == 2013 & month_date == 2
replace reg_interest_seg2 = 434 if year_date == 2013 & month_date == 2
replace reg_interest_seg3 = 538 if year_date == 2013 & month_date == 2

replace reg_interest_seg1 = 154 if year_date == 2013 & month_date == 3
replace reg_interest_seg2 = 428 if year_date == 2013 & month_date == 3
replace reg_interest_seg3 = 532 if year_date == 2013 & month_date == 3

replace reg_interest_seg1 = 150 if year_date == 2013 & month_date == 4
replace reg_interest_seg2 = 422 if year_date == 2013 & month_date == 4
replace reg_interest_seg3 = 526 if year_date == 2013 & month_date == 4

replace reg_interest_seg1 = 146 if year_date == 2013 & month_date == 5
replace reg_interest_seg2 = 415 if year_date == 2013 & month_date == 5
replace reg_interest_seg3 = 520 if year_date == 2013 & month_date == 5

replace reg_interest_seg1 = 143 if year_date == 2013 & month_date == 6
replace reg_interest_seg2 = 410 if year_date == 2013 & month_date == 6
replace reg_interest_seg3 = 515 if year_date == 2013 & month_date == 6

replace reg_interest_seg1 = 141 if year_date == 2013 & month_date == 7
replace reg_interest_seg2 = 407 if year_date == 2013 & month_date == 7
replace reg_interest_seg3 = 511 if year_date == 2013 & month_date == 7

replace reg_interest_seg1 = 139 if year_date == 2013 & month_date == 8
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 8
replace reg_interest_seg3 = 508 if year_date == 2013 & month_date == 8

replace reg_interest_seg1 = 137 if year_date == 2013 & month_date == 9
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 9
replace reg_interest_seg3 = 506 if year_date == 2013 & month_date == 9

replace reg_interest_seg1 = 135 if year_date == 2013 & month_date == 10
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 10
replace reg_interest_seg3 = 505 if year_date == 2013 & month_date == 10

replace reg_interest_seg1 = 131 if year_date == 2013 & month_date == 11
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 11
replace reg_interest_seg3 = 505 if year_date == 2013 & month_date == 11

replace reg_interest_seg1 = 128 if year_date == 2013 & month_date == 12
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 12
replace reg_interest_seg3 = 507 if year_date == 2013 & month_date == 12


*** create both 12 months lag and lead values

forvalues i=1(1)12{
gen lag`i'_reg_interest_seg1 = l`i'.reg_interest_seg1
gen lag`i'_reg_interest_seg2 = l`i'.reg_interest_seg2
gen lag`i'_reg_interest_seg3 = l`i'.reg_interest_seg3
}

forvalues i=1(1)12{
gen lead`i'_reg_interest_seg1 = f`i'.reg_interest_seg1
gen lead`i'_reg_interest_seg2 = f`i'.reg_interest_seg2
gen lead`i'_reg_interest_seg3 = f`i'.reg_interest_seg3
}

*** doublec check that code is correct, it is

*edit if year_date == 2011

*** merge with Form 5500 Raw Data (for 2011 and 2012)

sort myear

merge 1:m myear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/data"

****

drop if _merge !=3

drop _merge

***
sort id myear

*** generate yield curve dummy

gen yield_curve = sb_yield_curve_ind
replace yield_curve = 0 if sb_yield_curve_ind ==.

sort id
egen plans = group(id)
summ plans
drop plans

*** shows that out of full sample of plans in 2011 and 2012, 99.2% use segmented yield curve concept

summ yield_curve, d

*** generate interest rate

gen interest = sb_eff_int_rate_prcnt*100
drop if interest ==.

*** generate segment interest rates

gen interest_seg1 = sb_1st_seg_rate_prcnt*100
gen interest_seg2 = sb_2nd_seg_rate_prcnt*100
gen interest_seg3 = sb_3rd_seg_rate_prcnt*100

drop if interest_seg1 ==.
drop if interest_seg2 ==.
drop if interest_seg3 ==.

*** drop obvious typos (based on page 1, IRS document)

summ interest_seg1 if interest_seg1 > 677
drop  if interest_seg1 > 677

summ interest_seg2 if interest_seg2 > 837
drop  if interest_seg2 > 837

summ interest_seg3 if interest_seg3 > 918
drop  if interest_seg3 > 918

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** deal with details of pension funding law. the used interest rate should equal the published rate (entered manually above) subject to a +/- 12 months deviation
*** we account for the lead/lag and allow for minor typos (defined as 2 basis points difference; small impact on sample size)

**** look at difference between used rate and the regulated interest rate

gen diff_seg1 = interest_seg1 - reg_interest_seg1 if year_date == 2011
gen diff_seg2 = interest_seg2 - reg_interest_seg2 if year_date == 2011
gen diff_seg3 = interest_seg3 - reg_interest_seg3 if year_date == 2011

*** define tolerance threshold (2 basis points)

gen th = 2

*** compute total difference in assumptions (measured in basis points)

gen diff = diff_seg1 + diff_seg2 + diff_seg3 if year_date == 2011
replace diff = 0 if diff > -th & diff < th & year_date == 2011

summ diff if year_date == 2011
summ diff if diff == 0 & year_date == 2011

gen dum = 1 if diff == 0 & year_date == 2011
replace dum = 0 if dum ==. & year_date == 2011

gen diff_0 = diff
gen dum_0 = dum

*** compute lookback (and lookforward) interest rates for 1 to 12 months

forvalues i=1(1)12{
gen diff_seg1_l`i' = interest_seg1 - lag`i'_reg_interest_seg1 if year_date == 2011
gen diff_seg2_l`i' = interest_seg2 - lag`i'_reg_interest_seg2 if year_date == 2011
gen diff_seg3_l`i' = interest_seg3 - lag`i'_reg_interest_seg3 if year_date == 2011

gen diff_seg1_f`i' = interest_seg1 - lead`i'_reg_interest_seg1 if year_date == 2011
gen diff_seg2_f`i' = interest_seg2 - lead`i'_reg_interest_seg2 if year_date == 2011
gen diff_seg3_f`i' = interest_seg3 - lead`i'_reg_interest_seg3 if year_date == 2011

gen diff_l`i' = diff_seg1_l`i' + diff_seg2_l`i' + diff_seg3_l`i' if year_date == 2011
gen diff_f`i' = diff_seg1_f`i' + diff_seg2_f`i' + diff_seg3_f`i' if year_date == 2011

replace diff_l`i' = 0 if diff_l`i' > -th & diff_l`i' < th & year_date == 2011
replace diff_f`i' = 0 if diff_f`i' > -th & diff_f`i' < th & year_date == 2011

gen dum_l`i' = 1 if diff_l`i' == 0 & year_date == 2011
replace dum_l`i' = 0 if dum_l`i' ==. & year_date == 2011

gen dum_f`i' = 1 if diff_f`i' == 0 & year_date == 2011
replace dum_f`i' = 0 if dum_f`i' ==. & year_date == 2011
}

**** replace difference
forvalues i=1(1)12{
replace diff = diff_l`i' if dum_l`i' == 1 & year_date == 2011
replace diff = diff_f`i' if dum_f`i' == 1 & year_date == 2011

replace dum = dum_l`i' if dum_l`i' == 1 & year_date == 2011
replace dum = dum_f`i' if dum_f`i' == 1 & year_date == 2011
}

replace diff = 0 if diff > -th & diff < th & year_date == 2011
summ diff if year_date == 2011, d

*** drop plans that can not identify properly

drop if diff < 0 & year_date == 2011
drop if diff > 0 & year_date == 2011

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** show the fraction of firms using end of year vs 12 month lead/lag interest rate reporting assumptions

summ dum*

*** sort plans

sort id myear

edit id myear dum*


*** use previous value for interst rate reporting assumption
*** reason: sponsors can't choose and cherry pick the lead/lag point in time from period to period

replace dum = dum[_n-1] if id==id[_n-1] & dum ==.
replace dum_0 = dum_0[_n-1] if id==id[_n-1] & dum_0 ==.

forvalues i=1(1)12{
replace dum_l`i' = dum_l`i'[_n-1] if id==id[_n-1] & dum_l`i'==.
replace dum_f`i' = dum_f`i'[_n-1] if id==id[_n-1] & dum_f`i'==.
}

*** make sure you drop the plans in 2012 that could not properly be identified in 2011 and/or did not exist in 2011

drop if dum ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** number of plans in 2012 (final sample for regression)

summ dum* if year_date == 2012

*** compute regulated pre-MAP-21 rate in 2012

gen reg2012_reg_interest_seg1 = reg_interest_seg1 if dum_0 == 1 & year_date == 2012
gen reg2012_reg_interest_seg2 = reg_interest_seg2 if dum_0 == 1 & year_date == 2012
gen reg2012_reg_interest_seg3 = reg_interest_seg3 if dum_0 == 1 & year_date == 2012

forvalues i=1(1)12{
replace reg2012_reg_interest_seg1 = lag`i'_reg_interest_seg1 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg1 = lead`i'_reg_interest_seg1 if dum_f`i'==1 & year_date == 2012

replace reg2012_reg_interest_seg2 = lag`i'_reg_interest_seg2 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg2 = lead`i'_reg_interest_seg2 if dum_f`i'==1 & year_date == 2012

replace reg2012_reg_interest_seg3 = lag`i'_reg_interest_seg3 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg3 = lead`i'_reg_interest_seg3 if dum_f`i'==1 & year_date == 2012
}

**** compute by how much interest rate has changed in 2012

replace diff_seg1 = interest_seg1 - reg2012_reg_interest_seg1 if year_date == 2012
replace diff_seg2 = interest_seg2 - reg2012_reg_interest_seg2 if year_date == 2012
replace diff_seg3 = interest_seg3 - reg2012_reg_interest_seg3 if year_date == 2012

*** now replace "old" diff variable

summ diff if year_date == 2012, d

replace diff = diff_seg1 + diff_seg2 + diff_seg3 if year_date == 2012

summ diff if year_date == 2012, d

gen update = 1 if diff > 0 & year_date == 2012
replace update = 0 if update ==. & year_date == 2012

*** number of plans in 2012

summ update if year_date == 2012

*** compute average increase in interest rates

gen avg_interest_seg = (interest_seg1 + interest_seg2 + interest_seg3)/3 if year_date == 2012

gen avg_reg_interest_seg = (reg2012_reg_interest_seg1 + reg2012_reg_interest_seg2 + reg2012_reg_interest_seg3)/3 if year_date == 2012

gen diff_avg = avg_interest_seg - avg_reg_interest_seg if year_date == 2012

summ diff_avg if update == 1
summ diff_avg if update == 0

*** winsorize main variables

centile relfunding, centile(0.5 99.5)
replace relfunding = r(c_1) if relfunding < r(c_1)
replace relfunding = r(c_2) if relfunding > r(c_2)

centile rel_mand_contrib, centile(0.5 99.5)
replace rel_mand_contrib = r(c_1) if rel_mand_contrib < r(c_1)
replace rel_mand_contrib = r(c_2) if rel_mand_contrib > r(c_2)

centile exc_contrib, centile(0.5 99.5)
replace exc_contrib = r(c_1) if exc_contrib < r(c_1)
replace exc_contrib = r(c_2) if exc_contrib > r(c_2)

centile duration, centile(0.5 99.5)
replace duration = r(c_1) if duration < r(c_1)
replace duration = r(c_2) if duration > r(c_2)

summ D_mand_contrib, d
centile D_mand_contrib, centile(0.5 99.5)
replace D_mand_contrib = r(c_1) if D_mand_contrib < r(c_1)
replace D_mand_contrib = r(c_2) if D_mand_contrib > r(c_2)

summ risky, d

*** summary statistics of main variables

sort id year_date
xtset id year_date

gen lag_relfunding  = l1.relfunding
gen lag_rel_mand_contrib = l1.rel_mand_contrib
gen lag_rel_exc_contrib = l1.rel_exc_contrib

tabstat relfunding lag_relfunding rel_mand_contrib lag_rel_mand_contrib D_mand_contrib rel_exc_contrib lag_rel_exc_contrib, by(update)

tabstat relfunding lag_relfunding rel_mand_contrib lag_rel_mand_contrib D_mand_contrib rel_exc_contrib lag_rel_exc_contrib, by(update) s(med)

*** switching prediction model

gen lag_relfunding_p = lag_relfunding if lag_relfunding > 0
replace lag_relfunding_p = 0 if lag_relfunding_p ==.

gen lag_relfunding_n = lag_relfunding*(-1) if lag_relfunding < 0
replace lag_relfunding_n = 0 if lag_relfunding_n ==.

*** Table 14: 
logistic update lag_relfunding_p lag_relfunding_n if year_date == 2012, r
estimates store logit1

logistic update lag_relfunding_p lag_relfunding_n size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom if year_date == 2012, r
estimates store logit2

estout logit1 logit2, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout logit1 logit2, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estout logit1 logit2, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear
********************************************************************************************************
*** The Form 5500 Raw data were downloaded from the Center for Retirement Research, Boston College
*** The raw data were downloaded for each year and stored as follows raw5500-YEAR-1.dta
*** This code simply appends all individual files into one large file, covering the period 1999 to 2007
********************************************************************************************************

clear all

set memory 10000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC"

use raw5500-2007-1.dta
gen year = 2007
save raw_2007_all.dta, replace

****************

clear 

use raw5500-2006-1.dta
gen year = 2006
save raw_2006_all.dta, replace


****************

clear 

use raw5500-2005-1.dta
gen year = 2005
save raw_2005_all.dta, replace

****************

clear 

use raw5500-2004-1.dta

gen year = 2004
save raw_2004_all.dta, replace

****************

clear 

use raw5500-2003-1.dta


gen year = 2003
save raw_2003_all.dta, replace

****************

clear 

use raw5500-2002-1.dta

gen year = 2002
save raw_2002_all.dta, replace

****************

clear 

use raw5500-2001-1.dta

gen year = 2001
save raw_2001_all.dta, replace

****************

clear 

use raw5500-2000-1.dta


#delimit cr
gen year = 2000
save raw_2000_all.dta, replace

****************

clear 

use raw5500-1999-1.dta

gen year = 1999
save raw_1999_all.dta, replace


**** no inclusion prior to 1999 due to missing actuarial assumptions

***

clear

use raw_2007_all

append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2006_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2005_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2004_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2003_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2002_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2001_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2000_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_1999_all.dta"



save raw5500_all, replace
**** This file merges the different components of the 2011 Submission to the IRS: Form 5500, Schedule H and Schedule SB

clear all


set memory 2000m

*** form 5500

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest"

insheet using F_5500_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save 5500_2011, replace

*** schedule H
clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2011_Latest"

insheet using F_SCH_H_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save H_2011, replace

*** schedule SB

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2011_Latest"

insheet using F_SCH_SB_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save SB_2011, replace

*** merge datasets

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest"

use 5500_2011


merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2011_Latest/SB_2011"

drop if _merge !=3

drop _merge

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2011_Latest/H_2011"

drop if _merge ==2

drop _merge

gen year = 2011

*** generate ID number of plan

gen str3 PIN = string(spons_dfe_pn, "%03.0f")
gen str9 EIN = string(spons_dfe_ein, "%09.0f")

gen ID = EIN + PIN

sort ID

duplicates drop ID, force

save raw_2011.dta, replace
**** This file merges the different components of the 2012 Submission to the IRS: Form 5500, Schedule H and Schedule SB

clear all

set memory 2000m

*** form 5500

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

insheet using F_5500_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save 5500_2012, replace

*** schedule H
clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2012_Latest"

insheet using F_SCH_H_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save H_2012, replace

*** schedule SB

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2012_Latest"

insheet using F_SCH_SB_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save SB_2012, replace

*** merge datasets

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

use 5500_2012

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2012_Latest/SB_2012"

drop if _merge !=3

drop _merge

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2012_Latest/H_2012"

drop if _merge ==2

drop _merge

gen year = 2012

*** generate ID number of plan

gen str3 PIN = string(spons_dfe_pn, "%03.0f")
gen str9 EIN = string(spons_dfe_ein, "%09.0f")

gen ID = EIN + PIN

sort ID

duplicates drop ID, force

save raw_2012.dta, replace
*********************************************************************************************************************
***** DATA PREPARATION PENSION FUNDS ********************************************************************************
*********************************************************************************************************************
*** This file loads the raw file raw5500_all.dta, performs the main sample cleaning steps and defines most variables
*** which are used for this study
*********************************************************************************************************************

clear all

set memory 2000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC"

use raw5500_all

set type double, permanently

*********************************
*** clean dataset from duplicates
*********************************
 
*** generate ID number of plan

gen str3 PIN = string(SPONS_DFE_PN, "%03.0f")
gen str9 EIN = string(SPONS_DFE_EIN, "%09.0f")

gen ID = EIN + PIN

*** generate number of plans

sort ID

egen plans = group(ID)

summ plans
drop plans

*** focus on DB plans only

drop if DC == 1

summ DB

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop multi-employer plans

drop if TYPE_PLAN_ENTITY_IND != 2

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** set time parameter and compute sample

sort ID year

egen id = group(ID)

sort id year

xtset id year

*** drop small plans

gen participants = TOT_PARTCP_BOY_CNT 
drop if participants < 100

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate current-liability variable (RPA)

gen liab = (ACTRL_RPA94_INFO_CURR_LIAB_AMT/1000000)
drop if liab ==.
drop if liab == 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

**** prepare actuarial accrued liabilities
*** background: the accrued liability can be computed using the (a) immediate gain method or (b) the entry age normal method
*** plans thus only report one of the two numbers, but there are few cases/typos where both / no values contain an entry; these cases are dropped

gen dum_gain = 1 if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT !=0
replace dum_gain = 0 if dum_gain ==.

gen dum_age = 1 if ACTRL_ACCR_LIAB_AGE_MTHD_AMT !=0
replace dum_age = 0 if dum_age ==.

summ dum_gain dum_age

*** make sure plans use only one method (only affects few plans)

gen dum_both = dum_gain + dum_age

drop if dum_both !=1
drop dum_both

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** double check that accrued liability is only reported once

summ ACTRL_ACCR_LIAB_GAIN_MTHD_AMT if ACTRL_ACCR_LIAB_AGE_MTHD_AMT ==0
summ ACTRL_ACCR_LIAB_GAIN_MTHD_AMT if ACTRL_ACCR_LIAB_AGE_MTHD_AMT !=0

summ ACTRL_ACCR_LIAB_AGE_MTHD_AMT if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT ==0
summ ACTRL_ACCR_LIAB_AGE_MTHD_AMT if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT !=0

*** generate accrued liability

gen accr_liab = (ACTRL_ACCR_LIAB_GAIN_MTHD_AMT + ACTRL_ACCR_LIAB_AGE_MTHD_AMT)/1000000

drop if accr_liab ==.

drop if accr_liab <= 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate log of liabilities

gen log_AL = log(accr_liab)

gen log_CL = log(liab)

*** generate difference in pension liabilities

gen diff_liab = (liab - accr_liab)/accr_liab
replace diff_liab = diff_liab*100

*** generate asset variable

gen asset = ACTRL_CURR_VALUE_AST_01_AMT/1000000
drop if asset ==.
drop if asset == 0
drop if asset < 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate funding variable

gen funding = asset - liab  

gen relfunding = (funding / liab)
replace relfunding = relfunding*100

*** generate beginning of period FSA variable

gen FSAp = ACTRL_PR_YR_CREDIT_BALANCE_AMT/1000000
replace FSAp = 0 if FSAp <0
replace FSAp = 0 if FSAp ==.

gen FSAn = ACTRL_PR_YR_FNDNG_DEFN_AMT/1000000
replace FSAn = 0 if FSAn <0
replace FSAn = 0 if FSAn ==.

gen FSA = FSAp - FSAn
gen FSA_asset = FSA/asset
replace FSA_asset = FSA_asset*100

*** required cash contributions: MFC, AFR and MPC

gen MPC = ACTRL_TOT_CHARGES_AMT/1000000
gen MPC_asset = MPC/asset
replace MPC_asset= MPC_asset*100

gen MFC =  ACTRL_TOT_CHARGES_AMT/1000000  - ACTRL_ADDNL_FNDNG_PRT2_AMT/1000000 
gen MFC_asset = MFC/asset
replace MFC_asset= MFC_asset*100

gen AFR = ACTRL_ADDNL_FNDNG_PRT2_AMT/1000000
replace AFR = 0 if AFR <0
gen AFR_asset = AFR/asset
replace AFR_asset = AFR_asset*100

*** actual cash contributions

gen tot_contr =  ACTRL_TOT_EMPLR_CONTRIB_AMT/1000000
gen tot_contr_asset = tot_contr/asset
replace tot_contr_asset = tot_contr_asset*100

gen excess = (tot_contr - MPC)/asset

*** generate interest rate variables (in basis points)

** AL interest rate
gen interest = ACTRL_VALUATION_INT_PRE_PRCNT

** CL interest rate
gen interest_RPA = ACTRL_CURR_LIAB_RPA_PRCNT

gen D_interest = (interest - interest_RPA)

drop if D_interest ==.

sort ID
egen plans = group(ID)
summ plans
drop plans

*** use information on (pre-retirement) mortality tables
** comment: we focus on tables for males as they account for a larger fraction of the workforce

gen mortality_m = ACTRL_MORTALITY_MALE_PRE_CODE if ACTRL_MORTALITY_MALE_PRE_CODE != ""

drop if mortality_m == ""

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** check that the retirement mortality table coincides with the pre-retirement table

gen ind = 1 if ACTRL_MORTALITY_MALE_PRE_CODE == ACTRL_MORTALITY_MALE_POST_CODE  
replace ind = 0 if ACTRL_MORTALITY_MALE_PRE_CODE != ACTRL_MORTALITY_MALE_POST_CODE 

*** drop cases where different tables are being used

drop if ind == 0

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*****************************************************************************************************************************************************
*** construct mortality table dummies
*****************************************************************************************************************************************************

quietly: tabulate mortality_m, sort

replace mortality_m = "A" if mortality_m == "9" & year != 2007

gen m_none =  1 if mortality_m == "0" 
replace m_none = 0 if m_none ==.

gen m_1951 = 1 if mortality_m == "1" 
replace m_1951 = 0 if m_1951 ==.

gen m_1971 = 1 if mortality_m == "2" 
replace m_1971 = 0 if m_1971 ==.

gen m_1971b = 1 if mortality_m == "3" 
replace m_1971b = 0 if m_1971b ==.

gen m_1984 = 1 if mortality_m == "4" 
replace m_1984 = 0 if m_1984 ==.

gen m_1983a = 1 if mortality_m == "5" 
replace m_1983a = 0 if m_1983a ==.

gen m_1983b = 1 if mortality_m == "6" 
replace m_1983b = 0 if m_1983b ==.

gen m_1983c = 1 if mortality_m == "7" 
replace m_1983c = 0 if m_1983c ==.

gen m_1983 = m_1983b + m_1983c

gen m_1994 = 1 if mortality_m == "8" 
replace m_1994 = 0 if m_1994 ==.

gen m_2007 = 1 if mortality_m == "9" 
replace m_2007 = 0 if m_2007 ==.

gen m_oth = 1 if mortality_m == "A" 
replace m_oth = 0 if m_oth ==.

gen m_var = 1 - (m_1951 + m_1971 + m_1971b + m_none + m_1984 + m_1983a + m_1983b + m_1983c + m_1994 + m_2007 + m_oth) 

*** drop other tables

drop if m_oth == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop cases where no tables are used

drop if m_none == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop variations of tables / we don't know life expectancy

drop if m_var == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** average retirement age

gen retmt = ACTRL_WEIGHTED_RTM_AGE

drop if retmt ==. 

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

summ retmt

*centile retmt, centile(1 99)
*drop if retmt < r(c_1)
*drop if retmt > r(c_2)

drop if retmt < 56
drop if retmt > 65

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans


*** create cross-sectional longevity index based on mandated life expectancy
*** note: the numbers come from a separate computation in Excel

*** CL life expectancy assumptions

gen long_GM83 = 23.47488295 if retmt == 56
replace long_GM83  = 22.63127472 if retmt == 57
replace long_GM83  = 21.7940011 if retmt == 58
replace long_GM83  = 20.96353764 if retmt == 59
replace long_GM83  = 20.14078196 if retmt == 60
replace long_GM83  = 19.32693604 if retmt == 61
replace long_GM83  = 18.52341974 if retmt == 62
replace long_GM83  = 17.73196268 if retmt == 63
replace long_GM83  = 16.9544361 if retmt == 64
replace long_GM83  = 16.19286677 if retmt == 65

** in year 2007, master table is RP2000

replace long_GM83  = 24.46744037 if year==2007 & retmt == 56
replace long_GM83  = 23.61820224 if year==2007 & retmt == 57
replace long_GM83  = 22.77138505 if year==2007 & retmt == 58
replace long_GM83  = 21.92948384 if year==2007 & retmt == 59
replace long_GM83  = 21.0948639  if year==2007 & retmt == 60
replace long_GM83  = 20.26918615 if year==2007 & retmt == 61
replace long_GM83  = 19.45328617 if year==2007 & retmt == 62
replace long_GM83  = 18.64809706 if year==2007 & retmt == 63
replace long_GM83  = 17.85457349 if year==2007 & retmt == 64
replace long_GM83  = 17.07357095 if year==2007 & retmt == 65

*** AL life expectancy assumptions

gen long_index_cs  = 20.2357447 if m_1951 == 1 & retmt == 56
replace long_index_cs  = 20.66137352 if m_1984 == 1 & retmt == 56
replace long_index_cs  = 21.40249131 if m_1971 == 1 & retmt == 56
replace long_index_cs  = 23.4105909 if m_1971b == 1 & retmt == 56
replace long_index_cs  = 23.47488295 if m_1983 ==1 & retmt == 56
replace long_index_cs  = 24.11367631 if m_1994 ==1 & retmt == 56
replace long_index_cs  = 24.44261395 if m_1983a ==1 & retmt == 56
replace long_index_cs  = 26.13135926 if m_2007 ==1 & retmt == 56

replace long_index_cs  = 19.46797433 if m_1951 == 1 & retmt == 57
replace long_index_cs  = 19.88724822 if m_1984 == 1 & retmt == 57
replace long_index_cs  = 20.60257435 if m_1971 == 1 & retmt == 57
replace long_index_cs  = 22.62603673 if m_1971b == 1 & retmt == 57
replace long_index_cs  = 22.63127472 if m_1983 ==1 & retmt == 57
replace long_index_cs  = 23.24269593 if m_1994 ==1 & retmt == 57
replace long_index_cs  = 23.61948029 if m_1983a ==1 & retmt == 57
replace long_index_cs  = 25.21051502 if m_2007 ==1 & retmt == 57

replace long_index_cs  = 18.71037249 if m_1951 == 1 & retmt == 58
replace long_index_cs  = 19.12600299 if m_1984 == 1 & retmt == 58
replace long_index_cs  = 19.81150101 if m_1971 == 1 & retmt == 58
replace long_index_cs  = 21.85112027 if m_1971b == 1 & retmt == 58
replace long_index_cs  = 21.7940011 if m_1983 ==1 & retmt == 58
replace long_index_cs  = 22.38301742 if m_1994 ==1 & retmt == 58
replace long_index_cs  = 22.80175413 if m_1983a ==1 & retmt == 58
replace long_index_cs  = 24.2981478 if m_2007 ==1 & retmt == 58

replace long_index_cs  = 17.96261318 if m_1951 == 1 & retmt == 59
replace long_index_cs  = 18.37697355 if m_1984 == 1 & retmt == 59
replace long_index_cs  = 19.02960336 if m_1971 == 1 & retmt == 59
replace long_index_cs  = 21.08551382 if m_1971b == 1 & retmt == 59
replace long_index_cs  = 20.96353764 if m_1983 ==1 & retmt == 59
replace long_index_cs  = 21.53567408 if m_1994 ==1 & retmt == 59
replace long_index_cs  = 21.98902271 if m_1983a ==1 & retmt == 59
replace long_index_cs  = 23.39548579 if m_2007 ==1 & retmt == 59

replace long_index_cs  = 17.22466564 if m_1951 == 1 & retmt == 60
replace long_index_cs  = 17.64096693 if m_1984 == 1 & retmt == 60
replace long_index_cs  = 18.25925066 if m_1971 == 1 & retmt == 60
replace long_index_cs  = 20.32889788 if m_1971b == 1 & retmt == 60
replace long_index_cs  = 20.14078196 if m_1983 ==1 & retmt == 60
replace long_index_cs  = 20.70110157 if m_1994 ==1 & retmt == 60
replace long_index_cs  = 21.18135726 if m_1983a ==1 & retmt == 60
replace long_index_cs  = 22.50192601 if m_2007 ==1 & retmt == 60

replace long_index_cs  = 16.49682881 if m_1951 == 1 & retmt == 61
replace long_index_cs  = 16.91887069 if m_1984 == 1 & retmt == 61
replace long_index_cs  = 17.50197812 if m_1971 == 1 & retmt == 61
replace long_index_cs  = 19.58099448 if m_1971b == 1 & retmt == 61
replace long_index_cs  = 19.32693604 if m_1983 ==1 & retmt == 61
replace long_index_cs  = 19.88016991 if m_1994 ==1 & retmt == 61
replace long_index_cs  = 20.37945933 if m_1983a ==1 & retmt == 61
replace long_index_cs  = 21.61902471 if m_2007 ==1 & retmt == 61

replace long_index_cs  = 15.77983756 if m_1951 == 1 & retmt == 62
replace long_index_cs  = 16.2116407 if m_1984 == 1 & retmt == 62
replace long_index_cs  = 16.75840955 if m_1971 == 1 & retmt == 62
replace long_index_cs  = 18.84157387 if m_1971b == 1 & retmt == 62
replace long_index_cs  = 18.52341974 if m_1983 ==1 & retmt == 62
replace long_index_cs  = 19.07414639 if m_1994 ==1 & retmt == 62
replace long_index_cs  = 19.58450155 if m_1983a ==1 & retmt == 62
replace long_index_cs  = 20.75017828 if m_2007 ==1 & retmt == 62

replace long_index_cs  = 15.07485945 if m_1951 == 1 & retmt == 63
replace long_index_cs  = 15.52032294 if m_1984 == 1 & retmt == 63
replace long_index_cs  = 16.02853317 if m_1971 == 1 & retmt == 63
replace long_index_cs  = 18.11051616 if m_1971b == 1 & retmt == 63
replace long_index_cs  = 17.73196268 if m_1983 ==1 & retmt == 63
replace long_index_cs  = 18.28456023 if m_1994 ==1 & retmt == 63
replace long_index_cs  = 18.79806325 if m_1983a ==1 & retmt == 63
replace long_index_cs  = 19.89495945 if m_2007 ==1 & retmt == 63

replace long_index_cs  = 14.38357708 if m_1951 == 1 & retmt == 64
replace long_index_cs  = 14.84542349 if m_1984 == 1 & retmt == 64
replace long_index_cs  = 15.3125842 if m_1971 == 1 & retmt == 64
replace long_index_cs  = 17.38786026 if m_1971b == 1 & retmt == 64
replace long_index_cs  = 16.9544361 if m_1983 ==1 & retmt == 64
replace long_index_cs  = 17.51291706 if m_1994 ==1 & retmt == 64
replace long_index_cs  = 18.02193238 if m_1983a ==1 & retmt == 64
replace long_index_cs  = 19.05740437 if m_2007 ==1 & retmt == 64

replace long_index_cs  = 13.70814164 if m_1951 == 1 & retmt == 65
replace long_index_cs  = 14.18809734 if m_1984 == 1 & retmt == 65
replace long_index_cs  = 14.61210238 if m_1971 == 1 & retmt == 65
replace long_index_cs  = 16.67391253 if m_1971b == 1 & retmt == 65
replace long_index_cs  = 16.19286677 if m_1983 ==1 & retmt == 65
replace long_index_cs  = 16.76003012 if m_1994 ==1 & retmt == 65
replace long_index_cs  = 17.25782346 if m_1983a ==1 & retmt == 65
replace long_index_cs  = 18.23356459 if m_2007 ==1 & retmt == 65

*** compute difference in life expectancy

gen LE = (long_index_cs -long_GM83)

**** create industry dummmies

tostring BUSINESS_CODE, generate(NAICS)

gen agr = 1 if substr(NAICS, 1,2) == "11"
replace agr = 0 if agr ==.

gen min = 1 if substr(NAICS, 1,2) == "21"
replace min = 0 if min ==.

gen util = 1 if substr(NAICS, 1,2) == "22"
replace util = 0 if util ==.

gen cstrc = 1 if substr(NAICS, 1,2) == "23"
replace cstrc = 0 if cstrc ==.

gen man = 1 if substr(NAICS, 1,2) == "31"
replace man = 1 if substr(NAICS, 1,2) == "32"
replace man = 1 if substr(NAICS, 1,2) == "33"
replace man = 0 if man ==.

gen whle = 1 if substr(NAICS, 1,2) == "42"
replace whle = 0 if whle ==.

gen retl = 1 if substr(NAICS, 1,2) == "44"
replace retl = 1 if substr(NAICS, 1,2) == "45"
replace retl = 0 if retl ==.

gen trans = 1 if substr(NAICS, 1,2) == "48"
replace trans = 1 if substr(NAICS, 1,2) == "49"
replace trans = 0 if trans ==.

gen inf = 1 if substr(NAICS, 1,2) == "51"
replace inf = 0 if inf ==.

gen fin = 1 if substr(NAICS, 1,2) == "52"
replace fin = 0 if fin ==.

gen real = 1 if substr(NAICS, 1,2) == "53"
replace real = 0 if real ==.

gen prof = 1 if substr(NAICS, 1,2) == "54"
replace prof = 0 if prof ==.

gen hldg = 1 if substr(NAICS, 1,2) == "55"
replace hldg = 0 if hldg ==.

gen admin = 1 if substr(NAICS, 1,2) == "56"
replace admin = 0 if admin ==.

gen edu = 1 if substr(NAICS, 1,2) == "61"
replace edu = 0 if edu ==.

gen hlth = 1 if substr(NAICS, 1,2) == "62"
replace hlth = 0 if hlth ==.

gen arts = 1 if substr(NAICS, 1,2) == "71"
replace arts = 0 if arts ==.

gen accom = 1 if substr(NAICS, 1,2) == "72"
replace accom = 0 if accom ==.

gen oth = 1 if substr(NAICS, 1,2) == "81"
replace oth = 1 if substr(NAICS, 1,2) == "92"
replace oth = 0 if oth ==.

gen test = agr + min + util + cstrc + man + whle + retl + trans + inf + fin + real + prof + hldg + admin + edu + hlth + arts + accom + oth

summ test if test == 0

*** industry classification: visual inspection suggests that if test == 0, then missing or unclassified numbers

gen industry = "agr" if agr ==1
replace industry = "min" if min == 1
replace industry = "util" if util == 1
replace industry = "cstrc" if cstrc == 1
replace industry = "man" if man == 1
replace industry = "whle" if whle == 1
replace industry = "retl" if retl == 1
replace industry = "trans" if trans == 1
replace industry = "inf" if inf == 1
replace industry = "fin" if fin == 1
replace industry = "real" if real == 1
replace industry = "prof" if prof == 1
replace industry = "hldg" if hldg == 1
replace industry = "admin" if admin == 1
replace industry = "edu" if edu == 1
replace industry = "hlth" if hlth == 1
replace industry = "arts" if arts == 1
replace industry = "accom" if accom == 1
replace industry = "oth" if oth == 1

*** size

gen size = log(asset) 

*** compute "duration" proxy
** intuition: if none of the current plan participants is in retirement, the measure is 1 ( = long term promise)
** intuition ctd: if all of the current plan participants are already in retirement, the measure is 0 ( = short term promise)

replace RTD_SEP_PARTCP_RCVG_CNT= 0 if RTD_SEP_PARTCP_RCVG_CNT ==.
replace BENEF_RCVG_BNFT_CNT = 0 if BENEF_RCVG_BNFT_CNT ==.

gen part_ret = RTD_SEP_PARTCP_RCVG_CNT + BENEF_RCVG_BNFT_CNT

gen duration = (1 - part_ret/participants)
replace duration = duration*100

*** active participants

gen part_act = participants - part_ret

gen rel_part_act = (part_act/asset)
replace rel_part_act = rel_part_act*100

*** time dummies

sort year
quietly: tabulate year, gen(d)

*** generate investment variables

gen cash = NON_INT_BEAR_CASH_EOY_AMT
replace cash = 0 if cash ==.
 
gen cash_inv = INT_BEAR_CASH_EOY_AMT
replace cash_inv = 0 if cash_inv ==.

gen AR = EMPLR_CONTRIB_EOY_AMT + PARTCP_CONTRIB_EOY_AMT + OTHER_RECEIVABLE_EOY_AMT
replace AR = 0 if AR ==.

gen US_treas = GOVG_SEC_EOY_AMT
replace US_treas = 0 if US_treas ==.

gen debt_corp = CORP_DEBT_PREFERRED_EOY_AMT + CORP_DEBT_OTHER_EOY_AMT
replace debt_corp = 0 if debt_corp ==.

gen equity = PREF_STOCK_EOY_AMT + COMMON_STOCK_EOY_AMT
replace equity = 0 if equity ==.

gen JV = JOINT_VENTURE_EOY_AMT
replace JV = 0 if JV ==.

gen RE = REAL_ESTATE_EOY_AMT
replace RE = 0 if RE ==.

gen loans = OTHER_LOANS_EOY_AMT + PARTCP_LOANS_EOY_AMT
replace loans = 0 if loans ==.

gen com_trust = INT_COMMON_TR_EOY_AMT 
replace com_trust = 0 if com_trust ==.

gen pool_trust = INT_POOL_SEP_ACCT_EOY_AMT 
replace pool_trust = 0 if pool_trust ==.

gen master_trust = INT_MASTER_TR_EOY_AMT
replace master_trust = 0 if master_trust ==.

gen inv = INT_103_12_INVST_EOY_AMT
replace inv = 0 if inv ==.

gen funds = INT_REG_INVST_CO_EOY_AMT
replace funds = 0 if funds ==.

gen insurance = INS_CO_GEN_ACCT_EOY_AMT
replace insurance = 0 if insurance ==.

gen other = OTH_INVST_EOY_AMT
replace other = 0 if other ==.

gen employer = EMPLR_SEC_EOY_AMT + EMPLR_PROP_EOY_AMT
replace employer = 0 if employer ==.

gen buildings = BLDGS_USED_EOY_AMT
replace buildings = 0 if buildings ==.

gen impl_TA = cash + cash_inv + AR + US_treas + debt_corp + equity + JV + RE + loans +  com_trust +  pool_trust + master_trust + inv + funds + insurance + other + employer + buildings

*** drop negative values 

drop if cash < 0
drop if cash_inv < 0
drop if AR < 0
drop if US_treas < 0
drop if debt_corp < 0
drop if equity < 0
drop if JV < 0
drop if RE < 0
drop if loans < 0
drop if com_trust < 0
drop if pool_trust < 0
drop if master_trust < 0
drop if inv < 0
drop if funds < 0
drop if insurance < 0
drop if other < 0
drop if employer < 0
drop if buildings < 0


*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans


***

gen rel_cash = cash/impl_TA
gen rel_cash_inv = cash_inv/impl_TA
gen rel_AR = AR/impl_TA
gen rel_US_treas = US_treas/impl_TA
gen rel_debt_corp = debt_corp/impl_TA
gen rel_equity = equity/impl_TA
gen rel_JV = JV/impl_TA
gen rel_RE = RE/impl_TA
gen rel_loans = loans/impl_TA
gen rel_com_trust = com_trust/impl_TA
gen rel_master_trust = master_trust/impl_TA
gen rel_pool_trust = pool_trust/impl_TA
gen rel_inv = inv/impl_TA
gen rel_funds = funds/impl_TA
gen rel_insurance = insurance/impl_TA
gen rel_other = other/impl_TA
gen rel_employer = employer/impl_TA
gen rel_buildings = buildings/impl_TA

*** define risky assets

gen risky = 1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp
replace risky = risky*100

drop if risky ==.

sort ID
egen plans = group(ID)
summ plans
drop plans

gen fyear = year

**** winsorize data (all variables)

centile relfunding, centile(0.5 99.5)
replace relfunding = r(c_1) if relfunding < r(c_1)
replace relfunding = r(c_2) if relfunding > r(c_2)

centile diff_liab, centile(.5 99.5)
replace diff_liab = r(c_1) if diff_liab < r(c_1)
replace diff_liab = r(c_2) if diff_liab > r(c_2)

centile D_interest, centile(.5 99.5)
replace D_interest = r(c_1) if D_interest < r(c_1)
replace D_interest = r(c_2) if D_interest > r(c_2)

centile interest, centile(.5 99.5)
replace interest = r(c_1) if interest < r(c_1)
replace interest = r(c_2) if interest > r(c_2)

centile interest_RPA, centile(0.5 99.5)
replace interest_RPA = r(c_1) if interest_RPA < r(c_1)
replace interest_RPA = r(c_2) if interest_RPA > r(c_2)

centile duration, centile(0.5 99.5)
replace duration = r(c_1) if duration < r(c_1)
replace duration = r(c_2) if duration > r(c_2)

centile size, centile(0.5 99.5)
replace size = r(c_1) if size < r(c_1)
replace size = r(c_2) if size > r(c_2)

centile rel_part_act, centile(0.5 99.5)
replace rel_part_act = r(c_1) if rel_part_act < r(c_1)
replace rel_part_act = r(c_2) if rel_part_act > r(c_2)

centile MFC_asset, centile(0.5 99.5)
replace MFC_asset = r(c_1) if MFC_asset < r(c_1) & MFC_asset !=.
replace MFC_asset = r(c_2) if MFC_asset > r(c_2) & MFC_asset !=.

centile AFR_asset, centile(0.5 99.5)
replace AFR_asset = r(c_1) if AFR_asset < r(c_1) & AFR_asset !=.
replace AFR_asset = r(c_2) if AFR_asset > r(c_2) & AFR_asset !=.

centile MPC_asset, centile(0.5 99.5)
replace MPC_asset = r(c_1) if MPC_asset < r(c_1) & MPC_asset !=.
replace MPC_asset = r(c_2) if MPC_asset > r(c_2) & MPC_asset !=.

centile FSA_asset, centile(0.5 99.5)
replace FSA_asset = r(c_1) if FSA_asset < r(c_1) & FSA_asset !=.
replace FSA_asset = r(c_2) if FSA_asset > r(c_2) & FSA_asset !=.

centile tot_contr_asset, centile(0.5 99.5)
replace tot_contr_asset = r(c_1) if tot_contr_asset < r(c_1) & tot_contr_asset !=.
replace tot_contr_asset = r(c_2) if tot_contr_asset > r(c_2) & tot_contr_asset !=.

centile excess, centile(0.5 99.5)
replace excess = r(c_1) if excess < r(c_1)
replace excess = r(c_2) if excess > r(c_2)


*** generate number of plans
sort id

egen plans = group(id)

summ plans

*** make ready for Compustat merge

summ fyear
sort EIN fyear

*** define manipulation

gen manip = 1 if diff_liab > 0
replace manip = 0 if manip == .


cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save longevity, replace

***************** end of code


clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** number of plans

summ plans

sort id year
gen count = 1
replace count = count[_n-1] + 1 if id == id[_n-1]

gen ncount = count
replace ncount =. if ncount[_n+1] !=. & id == id[_n+1]

edit id year count ncount

*** average and medium number of observations per plan

summ ncount,d

drop count ncount

** generate number of plans each year

sort year
by year: egen obs = count(id)

*** Table 3, Panel A

tabstat accr_liab liab diff_liab asset relfunding interest interest_RPA D_interest long_index_cs long_GM83 LE size duration risky obs, by(year)

*** statistics pension liability manipulation

summ diff_liab, d

summ diff_liab if diff_liab >0
gen N = r(N)
summ diff_liab

display N/r(N)

*** Figure 1

histogram  diff_liab, fraction title("") xtitle("Pension liability gap") ytitle("Fraction of the sample") scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffliab.pdf", as(pdf) preview(off) replace

*** Figure 3

histogram  D_interest, fraction title("") xtitle("Excess discount rate assumptions") ytitle("Fraction of the sample") scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffint.pdf", as(pdf) preview(off) replace


summ diff_liab D_interest LE, d

summ diff_liab D_interest LE if diff_liab < 0, d

summ diff_liab D_interest LE if diff_liab > 0, d

summ LE if LE < 0

*** Figure 2

centile relfunding, centile(1 99)
gen th1 = r(c_1)
gen th2 = r(c_2)

summ relfunding, d

lpoly diff_liab relfunding if relfunding > th1 & relfunding < th2, kernel(epan) ci noscatter bw(10) title("") xtitle("Funding Status") ytitle("Pension liability gap") xlabel(-50(25)150) xmtick(-50(12.5)150) scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffliab_Kernel.pdf", as(pdf) preview(off) replace


*** Table 4

reg diff_liab relfunding, r
estimates store OLS1

reg diff_liab relfunding size duration risky, r
estimates store OLS2

reg diff_liab relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liab relfunding, fe
estimates store FE1

xtscc diff_liab relfunding size duration risky, fe
estimates store FE2

xtscc diff_liab relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** changes in excess interest-rates

sort id year

gen ch_D_interest = D_interest - l1.D_interest

gen dum_ch_D_int_p = 1 if ch_D_interest > 0 & ch_D_interest !=.
replace dum_ch_D_int_p = 0 if dum_ch_D_int_p ==.

gen dum_ch_D_int_n = 1 if ch_D_interest < 0 & ch_D_interest !=.
replace dum_ch_D_int_n = 0 if dum_ch_D_int_n ==.

gen dum_ch_D_int_u = 1 if ch_D_interest == 0 & ch_D_interest !=.
replace dum_ch_D_int_u = 0 if dum_ch_D_int_u ==.

gen dum_first = 1 if ch_D_interest ==.
replace dum_first = 0 if dum_first ==.

*** change in individual interest rates

gen ch_interest = interest - l1.interest

gen ch_interest_RPA = interest_RPA - l1.interest_RPA

**** yearly number of changes in Delta-interest raates

sort year
by year: egen tot_int_p = sum(dum_ch_D_int_p)
by year: egen tot_int_n = sum(dum_ch_D_int_n)
by year: egen tot_int_u = sum(dum_ch_D_int_u)
by year: egen tot_count = count(dum_ch_D_int_p)

by year: egen tot_first = sum(dum_first)

gen fraction_incr = tot_int_p/tot_count*100
gen fraction_decr = tot_int_n/tot_count*100

*** Table 5, Panel A

tabstat ch_D_interest tot_int_p tot_int_u tot_int_n tot_count fraction_incr fraction_decr tot_first, by(year)

*** changes in excess life expectancy assumptions

sort id year

gen ch_LE = LE - l1.LE

gen dum_ch_LE_p = 1 if ch_LE > 0 & ch_LE !=.
replace dum_ch_LE_p = 0 if dum_ch_LE_p ==.

gen dum_ch_LE_n = 1 if ch_LE < 0 & ch_LE !=.
replace dum_ch_LE_n = 0 if dum_ch_LE_n ==.

gen dum_ch_LE_u = 1 if ch_LE == 0 & ch_LE !=.
replace dum_ch_LE_u = 0 if dum_ch_LE_u ==.

sort year
by year: egen tot_LE_p = sum(dum_ch_LE_p)
by year: egen tot_LE_n = sum(dum_ch_LE_n)
by year: egen tot_LE_u = sum(dum_ch_LE_u)

gen fraction_incr_LE = tot_LE_p/tot_count*100
gen fraction_decr_LE = tot_LE_n/tot_count*100

*** Table 5, Panel B

tabstat ch_LE tot_LE_p tot_LE_u tot_LE_n tot_count fraction_incr_LE fraction_decr_LE, by(year)

*** generate positive and negative funding variable
*** note: we use absolute value of underfunding

gen p_relfunding = relfunding if relfunding >=0
replace p_relfunding = 0 if p_relfunding ==.

gen n_relfunding = relfunding*(-1) if relfunding < 0
replace n_relfunding = 0 if n_relfunding ==.

*****************************************************
*** pooled evidence: discount rate assumptions
*****************************************************

*** Table 6

reg D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

** Robustness: interest as LHS variable (Online Appendix Table 1)


reg interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*******************************************************
*** cross-sectional evdience: discount rate assumptions
*******************************************************

*** Online Appendix Table 2

fm D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm1

fm D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm2

fm interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm3

fm interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm4

estout fm*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout fm*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*******************************************************
*** time-series evdience: discount rate assumptions
*******************************************************

sort id year

*** change in funding

gen ch_relfunding = relfunding - l1.relfunding
gen ch_p_relfunding = p_relfunding - l1.p_relfunding
gen ch_n_relfunding = n_relfunding - l1.n_relfunding

*** Online Appendix Table 3

reg ch_D_interest ch_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg ch_D_interest ch_p_relfunding ch_n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

reg ch_interest ch_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg3

reg ch_interest ch_p_relfunding ch_n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*****************************************************
*** pooled evidence: LE assumptions
*****************************************************

gen dum_neg = 1 if LE < 0
replace dum_neg = 0 if dum_neg ==.

*** Table 7

logit dum_neg relfunding, vce(robust) 
estimates store reg1

logit dum_neg relfunding size duration risky, vce(robust)
estimates store reg2

logit dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** Untabulated robustness check: LE choice before 2007

drop plans
sort ID
egen plans = group(ID) if year < 2007
summ plans
drop plans

logistic dum_neg relfunding if year < 2007, vce(robust) 
estimates store reg1

logistic dum_neg relfunding size duration risky if year < 2007, vce(robust)
estimates store reg2

logistic dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg3

logistic dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg4

logistic dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 


*****************************************************************************
*** Untabulated robustness check: impact of frozen, terminated or floor plans
*****************************************************************************

sort TYPE_PENSION_BNFT_CODE

gen entry1 = substr(TYPE_PENSION_BNFT_CODE,1,2)
gen entry2 = substr(TYPE_PENSION_BNFT_CODE,3,2)
gen entry3 = substr(TYPE_PENSION_BNFT_CODE,5,2)
gen entry4 = substr(TYPE_PENSION_BNFT_CODE,7,2)
gen entry5 = substr(TYPE_PENSION_BNFT_CODE,9,2)
gen entry6 = substr(TYPE_PENSION_BNFT_CODE,11,2)
gen entry7 = substr(TYPE_PENSION_BNFT_CODE,13,2)

*** generate indicator variable for being a frozen plan

gen frozen = 1 if entry1 =="1I"
forvalues i=2(1)7{
replace frozen = 1 if entry`i' == "1I"
}

replace frozen = 0 if frozen ==.

*** generate indicator variable for being a terminated plan

gen terminated = 1 if entry1 =="1H"
forvalues i=2(1)7{
replace terminated = 1 if entry`i' == "1H"
}

replace terminated = 0 if terminated ==.

*** generate indicator variable for being a floor offset plan

gen floor = 1 if entry1 =="1D"
forvalues i=2(1)7{
replace floor = 1 if entry`i' == "1D"
}

replace floor = 0 if floor ==.


*** fraction of those pension plans and corresponding liability gap

summ frozen terminated floor

summ diff_liab if frozen == 1
summ diff_liab if terminated == 1
summ diff_liab if floor == 1


*** focus on the first observation a plan becomes frozen, terminated or receives a floor

sort id year
gen first_frozen = frozen - frozen[_n-1] if id==id[_n-1]
replace first_frozen = 0 if first_frozen ==-1

gen first_floor = floor - floor[_n-1] if id==id[_n-1]
replace first_floor = 0 if first_floor ==-1

gen first_terminated = terminated - terminated[_n-1] if id==id[_n-1]
replace first_terminated = 0 if first_terminated ==-1

gen lag_diff_liab = l1.diff_liab

logistic first_frozen lag_diff_liab size duration  , vce(robust)
estimates store reg1

logistic first_floor lag_diff_liab size duration risky  , vce(robust)
estimates store reg2

logistic first_terminated lag_diff_liab size duration risky , vce(robust)
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

**
drop if frozen == 1
drop if terminated == 1
drop if floor == 1

*** Table 4 w/o frozen plans

reg diff_liab relfunding, r
estimates store OLS1

reg diff_liab relfunding size duration risky, r
estimates store OLS2

reg diff_liab relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liab relfunding, fe
estimates store FE1

xtscc diff_liab relfunding size duration risky, fe
estimates store FE2

xtscc diff_liab relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Table 6 w/o frozen plans

reg D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*** Table 7 w/o frozen plans

logit dum_neg relfunding, vce(robust) 
estimates store reg1

logit dum_neg relfunding size duration risky, vce(robust)
estimates store reg2

logit dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

********************************************************************************
*** show summary statistics (Table 8, Panel A) for all plan-years
********************************************************************************
clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** compute trailing number of observations per pension plan 

sort id year

by id: gen num = _n

*** compute number of cross-sectional observations for each "number" num

sort num

by num: egen obs_num = count(num)

*** compute total observations by pension plan

sort id num

by id: egen max_num = max(num)


*** compute total number of years in which plans use regulatory leeway

sort id num

by id: gen sum_manip = sum(manip)

*** compute maximum number of manipulative years by pension plan

gen max_manip = sum_manip
replace max_manip = . if num != max_num

sort id max_manip
replace max_manip = max_manip[_n-1] if id==id[_n-1] & max_manip ==.

*** double check that code is correct (yes, it is)

sort id year

edit id year num max_num sum_manip manip max_manip


*** compute number of plans for each max_manip
*** need to start the code at 1 (instead of zero)

sort max_manip id
replace max_manip = max_manip +1
summ max_manip

forvalues i=1(1)10{
egen manip_plans = group(id) if max_manip == `i'
egen m_plans_`i' = max(manip_plans) if max_manip == `i'
replace m_plans_`i' = 0 if m_plans_`i' ==.
drop manip_plans
}

*** double check that code is correct (yes, it is)

summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip == 1
summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip  == 10

gen m_plans = m_plans_1 + m_plans_2 + m_plans_3 + m_plans_4 + m_plans_5 + m_plans_6 + m_plans_7 + m_plans_8 + m_plans_9 + m_plans_10
drop m_plans_*

*** generate number of plan-years per max_manip

sort max_manip id

by max_manip: egen sum_mmanip = count(manip)

*** double check that code is correct (yes, it is)

edit max_manip id m_plans sum_mmanip

*** Table 8, Panel A

tabstat sum_mmanip m_plans relfunding tot_contr_asset MFC_asset AFR_asset, by(max_manip)

*********************************************************************************************************
*** repeat the code (Table 8, Panel B) for underfunded plan-years only
*** focus only on underfunded plan years for subsequent analysis (only then, contributions are mandatory)
*********************************************************************************************************

clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** compute trailing number of observations per pension plan 

sort id year

by id: gen num = _n

*** compute number of cross-sectional observations for each "number" num

sort num

by num: egen obs_num = count(num)

*** compute total observations by pension plan

sort id num

by id: egen max_num = max(num)


*** compute total number of years in which plans use regulatory leeway

sort id num

by id: gen sum_manip = sum(manip)

*** compute maximum number of manipulative years by pension plan

gen max_manip = sum_manip
replace max_manip = . if num != max_num

sort id max_manip
replace max_manip = max_manip[_n-1] if id==id[_n-1] & max_manip ==.

*** double check that code is correct (yes, it is)

sort id year

edit id year num max_num sum_manip manip max_manip


*** drop underfunded plan years

drop if relfunding > 0

*** compute number of plans for each max_manip
*** need to start the code at 1 (instead of zero)

sort max_manip id
replace max_manip = max_manip +1
summ max_manip

forvalues i=1(1)10{
egen manip_plans = group(id) if max_manip == `i'
egen m_plans_`i' = max(manip_plans) if max_manip == `i'
replace m_plans_`i' = 0 if m_plans_`i' ==.
drop manip_plans
}

*** double check that code is correct (yes, it is)

summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip == 1
summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip  == 10

gen m_plans = m_plans_1 + m_plans_2 + m_plans_3 + m_plans_4 + m_plans_5 + m_plans_6 + m_plans_7 + m_plans_8 + m_plans_9 + m_plans_10
drop m_plans_*

*** generate number of plan-years per max_manip

sort max_manip id

by max_manip: egen sum_mmanip = count(manip)

*** double check that code is correct (yes, it is)

edit max_manip id m_plans sum_mmanip

*** Table 8, Panel B

tabstat sum_mmanip m_plans relfunding tot_contr_asset MFC_asset AFR_asset , by(max_manip)

*** multivariate analysis, total cash contributions
*** Table 9, Panel A

reg tot_contr_asset manip, r
estimates store reg1

reg tot_contr_asset relfunding manip, r
estimates store reg2

reg tot_contr_asset relfunding manip size duration risky , r
estimates store reg3

reg tot_contr_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg tot_contr_asset relfunding manip size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

xtscc tot_contr_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

*** multivariate analysis, mandatory funding contribution
*** Table 9, Panel B

reg MFC_asset manip, r
estimates store reg1

reg MFC_asset manip relfunding, r
estimates store reg2

reg MFC_asset manip relfunding size duration risky , r
estimates store reg3

reg MFC_asset manip relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg MFC_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

xtscc MFC_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** Robustness: multivariate analysis which conditions on the frequency of using regulatory leeway, total cash contributions
*** Online Appendix Table 4, Panel A

*** account for the fact that max_manip is set to start at 1 (not zero)
*** max_num needs to be consistent with it

replace max_num = max_num + 1

summ max_num max_manip

forvalues i=1(1)9{
summ manip max_num if max_num > `i' & max_manip ==`i' 
}

forvalues i=1(1)9{
reg tot_contr_asset manip relfunding agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i' , r

estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

***

forvalues i=1(1)9{
reg MFC_asset manip relfunding agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i', r
estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

*** untabulated results including control variables

forvalues i=1(1)9{
reg tot_contr_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i' , r

estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

***

forvalues i=1(1)9{
reg MFC_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i', r
estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*******************************************************************************************************************************************************
***** PREPARE COMPUSTAT FILE USING EIN AND FYEAR AS MATCHING VARIABLE FOR MERGE
*******************************************************************************************************************************************************

clear all

set memory 1000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Compustat"

*** load raw data

use pension

*** generate 3-digit SIC code

gen sic3 = substr(sic,1,3)

*** make sic and gvkey available as numbers

gen sic1 = real(sic)
drop sic
gen sic = sic1
drop sic1

gen gvkey1 = real(gvkey)
drop gvkey
gen gvkey = gvkey1
drop gvkey1

*** use 1998 value to compute acrual values, sales growth and industry sales growth
*** otherwise we lose the entire first year of the sample (1999)

sort gvkey datadate

*** accrual components

gen COA = (act - che)
gen lagCOA = COA[_n-1] if gvkey==gvkey[_n-1]

gen COL = (lct - dlc)
gen lagCOL = COL[_n-1] if gvkey==gvkey[_n-1]

gen lagat = at[_n-1] if gvkey==gvkey[_n-1]

** sales growth

replace sale = 0 if sale <0
gen gs = (sale - sale[_n-1])/sale[_n-1] if gvkey == gvkey[_n-1]

*** generate 3 digit industry sales growth variable 

sort sic3 fyear
egen industry3_fyear = group(sic3 fyear)

sort industry3_fyear
by industry3_fyear: egen sale_ind = sum(sale)

sort sic3 fyear
gen ISG = (sale_ind - sale_ind[_n-1])/sale_ind[_n-1] if fyear==fyear[_n-1]+1 & sic3==sic3[_n-1]
replace ISG = -99 if ISG ==. 

edit sic3 fyear ISG sale_ind

** replace "-99" values with actual growth number
sort industry3_fyear
by industry3_fyear: egen ISG1 = max(ISG)

*** double check this makes sense (yes, it does)

edit sic3 fyear ISG sale_ind ISG1

drop ISG
rename ISG1 ISG

*** make sure we have same sample period

drop if fyear < 1999
drop if fyear > 2007

***
sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** create EIN number (there is a "-" in the compustat string)
*** and make sure EIN number is available

gen ein1 = substr(ein, 1, 2)
gen ein2 = substr(ein, 4, 7)
gen EIN = ein1 + ein2

drop if EIN == ""

***
sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

**** drop financials, utilities and government entities

drop if sic > 5999 & sic < 7000
drop if sic > 4899 & sic < 5000

**

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** double check that one EIN does not appear several times within a fiscal year

sort EIN fyear datadate at tic

egen id = group(EIN fyear)

sort id datadate

*** check wether id changes

gen idL = id - id[_n-1]

gen idL1 = id[_n+1]-id

*** drop observations in case it id stays constant (only retain the latest info within a fiscal year)

drop if idL1 ==0

drop id idL idL1

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

***********************************************************************************
*** merge with CCM pension accounting data
*** note, that pension accounting data is used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

***
sort gvkey fyear datadate at tic
egen id = group(gvkey fyear)

sort id datadate

*** check wether id changes

gen idL = id - id[_n-1]

gen idL1 = id[_n+1]-id

*** drop observations in case it id stays constant (only keep latest information)

drop if idL1 ==0

drop id idL idL1

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** actual merge with pension FASB data

sort gvkey datadate

merge 1:1 gvkey datadate using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Compustat/pension_robust.dta"

*** drop non merged data from pension accounting file
drop if _merge == 2
rename _merge _merge_FASB

***********************************************************************************
*** merge with Graham's simulated tax rates
*** note, that simulated tax rates are used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

sort gvkey fyear

merge 1:1 gvkey fyear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Tax rates/taxrates.dta"

*** drop non merged data from Graham's file
drop if _merge == 2
rename _merge _merge_tax

***********************************************************************************
*** merge with Gompers corporate governance index
*** note, that simulated tax rates are used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

sort gvkey fyear tic

merge 1:1 gvkey fyear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Gompers/Gindex.dta"

drop _merge

***********************************************************************************
*** prepare the main financial statement variables 
***********************************************************************************

sort gvkey fyear

xtset gvkey fyear

** $ variables

gen C = che

gen D = dlc + dltt

gen EMV = prcc_f*csho

gen MV = EMV + D

*** financial ratios
  
gen Q = MV/at

gen lagQ = l1.Q

gen BL = D/at

gen ML = D/MV

gen CR = C/at

gen size = log(at)

gen d_yield = (dvc + dvp)/EMV

gen prof = oibdp/at

gen NI = ib/at

*** Z-score components

gen X1 = (act - lct)/at

gen X2 = re/at

gen X3 = oiadp/at

gen X4 = EMV/D

gen X5 = sale/at

*** generate taxpayer status 

gen taxpayer = 1 if txfed > 0 & txfed !=.
replace taxpayer = 0 if taxpayer ==. & txfed !=.

gen taxpayer_adv = 2 if txfed > 0 & txfed !=.
replace tlcf = 0 if tlcf ==.
replace taxpayer_adv = 1 if txfed <= 0 & tlcf ==0
replace taxpayer_adv = 0 if taxpayer_adv ==. & txfed !=.

**** no information available for these CF statements

gen E_issue = sstk/at

gen div = dvc/at
gen div1 = dvc/lagat
gen div2 = (dvc + prstkc)/lagat

gen OCF = oancf/at
gen OCF1 = oancf/lagat

gen total_def = capx + aqc + dv

gen DEF = total_def/at

gen capex = capx/at
gen capex1 = capx/lagat

gen AQC = aqc/at

*** generate "action" dummies

gen th = 0.05

gen AI = 1 if AQC > th
replace AI = 0 if AI == .

gen EI = 1 if E_issue > th 
replace EI = 0 if EI ==.

*** generate alternative "action" dummies (2.5%)

gen th25 = 0.025

gen AI25 = 1 if AQC > th25
replace AI25 = 0 if AI25 == .

gen EI25 = 1 if E_issue > th25 
replace EI25 = 0 if EI25 ==.

*** generate alternative "action" dummies (7.5%)

gen th75 = 0.075

gen AI75 = 1 if AQC > th75
replace AI75 = 0 if AI75 == .

gen EI75 = 1 if E_issue > th75 
replace EI75 = 0 if EI75 ==.

***** 3 digit investment & dividend (fyear)

sort industry3_fyear

by industry3_fyear: egen ind_capex_3fyr = median(capex)
by industry3_fyear: egen ind_div_3fyr = median(div)


*** generate accrual variables

gen TACC = (COA - lagCOA - (COL - lagCOL) - dp)/lagat

**** additional financial constraint variables

gen TLDT = dltt/at

gen DIVPOS = 1 if dv >0
replace DIVPOS = 0 if DIVPOS ==.

*** generate industry variables

gen CND =1 if sic >= 0100 & sic <=0999
replace CND =1 if sic >= 2000 & sic <=2399
replace CND =1 if sic >= 2700 & sic <=2749
replace CND =1 if sic >= 2770 & sic <=2799
replace CND =1 if sic >= 3100 & sic <=3199
replace CND =1 if sic >= 3940 & sic <=3989
replace CND = 0 if CND ==.


gen CD =1 if sic >= 2500 & sic <=2519
replace CD =1 if sic >= 2590 & sic <=2599
replace CD =1 if sic >= 3630 & sic <=3659
replace CD =1 if sic >= 3710 & sic <=3711
replace CD =1 if sic >= 3714 & sic <=3714
replace CD =1 if sic >= 3716 & sic <=3716
replace CD =1 if sic >= 3750 & sic <=3751
replace CD =1 if sic >= 3792 & sic <=3792
replace CD =1 if sic >= 3900 & sic <=3939
replace CD =1 if sic >= 3990 & sic <=3999
replace CD = 0 if CD ==.


gen MAN =1 if sic >= 2520 & sic <=2589
replace MAN =1 if sic >= 2600 & sic <=2699
replace MAN =1 if sic >= 2750 & sic <=2769
replace MAN =1 if sic >= 3000 & sic <=3099
replace MAN =1 if sic >= 3200 & sic <=3569
replace MAN =1 if sic >= 3580 & sic <=3629
replace MAN =1 if sic >= 3700 & sic <=3709
replace MAN =1 if sic >= 3712 & sic <=3713
replace MAN =1 if sic >= 3715 & sic <=3715
replace MAN =1 if sic >= 3717 & sic <=3749
replace MAN =1 if sic >= 3752 & sic <=3791
replace MAN =1 if sic >= 3793 & sic <=3799
replace MAN =1 if sic >= 3830 & sic <=3839
replace MAN =1 if sic >= 3860 & sic <=3899
replace MAN = 0 if MAN ==.

gen EN =1 if sic >= 1200 & sic <=1399
replace EN =1 if sic >= 2900 & sic <=2999
replace EN = 0 if EN ==.

gen CHEM =1 if sic >= 2800 & sic <=2829
replace CHEM =1 if sic >= 2840 & sic <=2899
replace CHEM = 0 if CHEM ==.

gen BUS =1 if sic >= 3570 & sic <=3579
replace BUS =1 if sic >= 3660 & sic <=3692
replace BUS =1 if sic >= 3694 & sic <=3699
replace BUS =1 if sic >= 3810 & sic <=3829
replace BUS =1 if sic >= 7370 & sic <=7379
replace BUS = 0 if BUS ==.


gen UTIL =1 if sic >= 4800 & sic <=4899
replace UTIL =1 if sic >= 4900 & sic <=4949
replace UTIL = 0 if UTIL ==.

gen SALE =1 if sic >= 5000 & sic <=5999
replace SALE =1 if sic >= 7200 & sic <=7299
replace SALE =1 if sic >= 7600 & sic <=7699
replace SALE = 0 if SALE ==.

gen HLTH =1 if sic >= 2830 & sic <=2839
replace HLTH =1 if sic >= 3693 & sic <=3693
replace HLTH =1 if sic >= 3840 & sic <=3859
replace HLTH =1 if sic >= 8000 & sic <=8099
replace HLTH = 0 if HLTH ==.

gen FIN =1 if sic >= 6000 & sic <=6999
replace FIN = 0 if FIN ==.

gen OTH = 1 - HLTH - SALE - BUS - CHEM - EN - MAN - CD - CND - FIN - UTIL

*** sort the data again

sort EIN fyear

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save crsp_compustat, replace
****** load CCM sponsor file

clear all

set memory 1000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use crsp_compustat

**** MERGE WITH FORM 5500 

merge 1:m EIN fyear using "/Users/administrator_2014/Documents/Research/Pension manipulation/Results/longevity.dta"

drop if _merge != 3

** manually check merge quality
*edit conm SPONS_DFE_NAME

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** generate industry variable based on compustat (instead of form 5500)

drop industry
gen industry = "HLTH" if HLTH == 1
replace industry = "SALE" if SALE == 1
replace industry = "BUS" if BUS == 1
replace industry = "CHEM" if CHEM == 1
replace industry = "EN" if EN == 1
replace industry = "MAN" if MAN == 1
replace industry = "CD" if CD == 1
replace industry = "CND" if CND == 1
replace industry = "FIN" if FIN == 1
replace industry = "UTIL" if UTIL == 1
replace industry = "OTH" if OTH == 1

*** reminder: number of pension plans

*sort id

*drop plans

*sort gvkey
*egen plans = group(id)

*summ plans

*** account for fact that 1 firm might have several plans

drop id

sort EIN fyear year

egen id = group(EIN fyear)

sort id

*** now we compute pension variables at the level of the plan sponr

*** compute implied $-value of risky investments

replace risky = (1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp)*impl_TA

*** generate underfunding dummy

gen unfun = 1 if relfunding < 0
replace unfun = 0 if unfun ==.

summ unfun
summ unfun if unfun == 1

*** generate aggregate sponsor variables

by id: egen total_assets = sum(asset)
by id: egen total_liab = sum(liab)
by id: egen total_accr_liab = sum(accr_liab)

by id: egen total_tot_contr = sum(tot_contr)
by id: egen total_MFC = sum(MFC)
by id: egen total_AFR = sum(AFR)

by id: egen total_participants = sum(participants)
by id: egen total_part_ret = sum(part_ret)
by id: egen total_risky_nom = sum(risky)
by id: egen total_impl_TA = sum(impl_TA)

by id: egen sum_manip = sum(manip)
by id: egen sum_unfun = sum(unfun)
by id: egen sum_plans = count(fyear)

*** generate dispersion in actuarial assumptions

gen diff_int = interest - interest_RPA
by id: egen m_diff_int = mean(diff_int)
by id: egen min_diff_int = min(diff_int)
by id: egen max_diff_int = max(diff_int)

gen diff_LE = long_index_cs - long_GM83
by id: egen m_diff_LE = mean(diff_LE)
by id: egen min_diff_LE = min(diff_LE)
by id: egen max_diff_LE = max(diff_LE)

*** generate "weight" of each plan (based on CL)

gen weight = liab/total_liab

*** compute sponsor specific LE-assumptions (using weights)

gen long1 = long_index_cs*weight
gen long2 = long_GM83*weight

by id: egen total_longevity = sum(long1)
by id: egen total_longevity_GAM = sum(long2)

drop long1 long2

*** compute sponsor specific discount rate assumptions (using weights)

gen interest1 = interest*weight
gen interest1_RPA = interest_RPA*weight

by id: egen total_interest = sum(interest1)
by id: egen total_interest_RPA = sum(interest1_RPA)

drop interest1 interest1_RPA

summ id

*** now keep one observation per firm-year (i.e. per sponsor)

sort id

gen idL = id - id[_n-1]

drop if idL ==0

drop id idL

summ at

*** compute number of sponsors and years

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** descriptive information on manipulation across the same plans by a sponsor (in a given year)

gen manip_freq = sum_manip/sum_plans
summ manip_freq if sum_manip > 0, d

gen diff_diff_int = max_diff_int - min_diff_int
summ diff_diff_int if sum_manip > 0, d

gen diff_diff_LE = max_diff_LE - min_diff_LE
summ diff_diff_LE if sum_manip > 0, d

*** generate sponsor-specifc aggregate plan variables

gen diff_liabA = (total_liab - total_accr_liab)/total_accr_liab

gen LEA = total_longevity - total_longevity_GAM

gen D_interestA = total_interest - total_interest_RPA

gen relfundingA = (total_assets - total_liab)/total_liab
gen lagrelfundingA = l1.relfundingA

gen sizeA = log(total_assets)

gen durationA = 1 - total_part_ret/total_participants
replace durationA = durationA*100

gen riskyA = total_risky_nom/total_impl_TA
replace riskyA = riskyA*100

*** generate sponsor-specific sponsor/plan variables

gen total_tot_contr_at = total_tot_contr/at
gen total_tot_contr_at1 = total_tot_contr/lagat

gen total_MFC_at = total_MFC/at
gen total_MFC_at1 = total_MFC/lagat

gen total_tot_contr_E = total_tot_contr/seq

gen total_tot_contr_plassets = total_tot_contr/total_assets
gen total_MFC_plassets = total_MFC/total_assets

gen sensitivity = total_asset/oibdp

gen rel_size = total_liab/at

gen consol_liab = total_liab + D 
gen consol_assets = MV + total_assets 
gen consol_lev = consol_liab / consol_assets

gen consol_netliab = consol_liab - C
gen consol_netlev = consol_netliab / consol_assets

*** non-missing balance sheet data for required sponsor variables

drop if at ==.
drop if MV == .
drop if Q ==.
drop if BL ==.
drop if CR ==. 
drop if TLDT ==.
drop if TACC ==.
drop if size ==.
drop if X1 ==.
*drop if X4 ==. (because of all-equity firms, we want to keep them)

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing income statement data for required sponsor variables

drop if prof == .
drop if d_yield ==.
drop if NI ==.
drop if dv ==.
drop if DIVPOS ==.
drop if ISG ==.
drop if X2 ==.
drop if X3 ==.
drop if X5 ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing cash flow statement data for required sponsor variables

drop if OCF ==.
drop if capex ==.
drop if dvc ==.
drop if AQC ==.
drop if total_def ==.
drop if E_issue ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** drop if federal tax information is missing

drop if taxpayer ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing data for required sponsor/plan variables

drop if diff_liabA ==.
drop if LEA ==.
drop if D_interestA ==.
drop if relfundingA ==.
drop if sizeA ==.
drop if durationA ==.
drop if riskyA ==.

drop if total_tot_contr_E ==.
drop if total_tot_contr_plassets ==.

drop if sensitivity ==.

*** compute number of sponsors and years

sort gvkey fyear

egen sponsors = group(gvkey)

summ sponsors
drop sponsors

*** generate manipulation variable

gen manipA = 1 if diff_liabA > 0
replace manipA = 0 if manipA ==.

*** winsorize pension variables

centile diff_liabA, centile(.5 99.5)
replace diff_liabA = r(c_1) if diff_liabA < r(c_1)
replace diff_liabA = r(c_2) if diff_liabA > r(c_2)

centile relfundingA, centile(.5 99.5)
replace relfundingA = r(c_1) if relfundingA < r(c_1)
replace relfundingA = r(c_2) if relfundingA > r(c_2)

centile D_interestA, centile(.5 99.5)
replace D_interestA = r(c_1) if D_interestA < r(c_1)
replace D_interestA = r(c_2) if D_interestA > r(c_2)

centile durationA, centile(0.5 99.5)
replace durationA = r(c_1) if durationA < r(c_1)
replace durationA = r(c_2) if durationA > r(c_2)

centile sizeA, centile(0.5 99.5)
replace sizeA = r(c_1) if sizeA < r(c_1)
replace sizeA = r(c_2) if sizeA > r(c_2)

centile total_tot_contr_at, centile(0.5 99.5)
replace total_tot_contr_at = r(c_1) if total_tot_contr_at < r(c_1)
replace total_tot_contr_at = r(c_2) if total_tot_contr_at > r(c_2)

centile total_tot_contr_at1, centile(0.5 99.5)
replace total_tot_contr_at1 = r(c_1) if total_tot_contr_at1 < r(c_1) & total_tot_contr_at1 !=.
replace total_tot_contr_at1 = r(c_2) if total_tot_contr_at1 > r(c_2) & total_tot_contr_at1 !=.

centile total_MFC_at, centile(0.5 99.5)
replace total_MFC_at = r(c_1) if total_MFC_at < r(c_1)
replace total_MFC_at = r(c_2) if total_MFC_at > r(c_2)

centile total_MFC_at1, centile(0.5 99.5)
replace total_MFC_at1 = r(c_1) if total_MFC_at1 < r(c_1) & total_MFC_at1 !=.
replace total_MFC_at1 = r(c_2) if total_MFC_at1 > r(c_2) & total_MFC_at1 !=.

centile total_tot_contr_plassets, centile(0.5 99.5)
replace total_tot_contr_plassets = r(c_1) if total_tot_contr_plassets < r(c_1)
replace total_tot_contr_plassets = r(c_2) if total_tot_contr_plassets > r(c_2)

centile total_MFC_plassets, centile(0.5 99.5)
replace total_MFC_plassets = r(c_1) if total_MFC_plassets < r(c_1)
replace total_MFC_plassets = r(c_2) if total_MFC_plassets > r(c_2)

centile total_tot_contr_E, centile(0.5 99.5)
replace total_tot_contr_E = r(c_1) if total_tot_contr_E < r(c_1)
replace total_tot_contr_E = r(c_2) if total_tot_contr_E > r(c_2)

centile sensitivity, centile(0.5 99.5)
replace sensitivity = r(c_1) if sensitivity < r(c_1)
replace sensitivity = r(c_2) if sensitivity > r(c_2)

centile rel_size, centile(0.5 99.5)
replace rel_size = r(c_1) if rel_size < r(c_1)
replace rel_size = r(c_2) if rel_size > r(c_2)

centile consol_lev, centile(0.5 99.5)
replace consol_lev = r(c_1) if consol_lev < r(c_1)
replace consol_lev = r(c_2) if consol_lev > r(c_2)


*** winsorize ingredients of index variables

centile X1, centile(0.5 99.5)
replace X1 = r(c_1) if X1 < r(c_1)
replace X1 = r(c_2) if X1 > r(c_2)

centile X2, centile(0.5 99.5)
replace X2 = r(c_1) if X2 < r(c_1)
replace X2 = r(c_2) if X2 > r(c_2)

centile X3, centile(0.5 99.5)
replace X3 = r(c_1) if X3 < r(c_1)
replace X3 = r(c_2) if X3 > r(c_2)

centile X4, centile(0.5 95)
replace X4 = r(c_1) if X4 < r(c_1) & X4 !=.
replace X4 = r(c_2) if X4 > r(c_2) & X4 !=.
*** note: because of high fraction of almost all-equity financed firms we winsorze X4 at the 95% level

centile X5, centile(0.5 99.5)
replace X5 = r(c_1) if X5 < r(c_1)
replace X5 = r(c_2) if X5 > r(c_2)

** generate z-score based on winsorized components

gen Z = 1.2*X1 + 1.4*X2 + 3.3*X3 + 0.6*X4 + 1*X5
summ Z at

centile Z, centile(0.5 99.5)
replace Z = r(c_1) if Z < r(c_1) 
replace Z = r(c_2) if Z > r(c_2) 

summ Z, d

** winsorize BS compustat variables

centile Q, centile(0.5 99.5)
replace Q = r(c_1) if Q < r(c_1)
replace Q = r(c_2) if Q > r(c_2)

centile BL, centile(0.5 99.5)
replace BL = r(c_1) if BL < r(c_1)
replace BL = r(c_2) if BL > r(c_2)

centile CR, centile(0.5 99.5)
replace CR = r(c_1) if CR < r(c_1)
replace CR = r(c_2) if CR > r(c_2)

centile TLDT, centile(0.5 99.5)
replace TLDT = r(c_1) if TLDT < r(c_1)
replace TLDT = r(c_2) if TLDT > r(c_2)

centile TACC, centile(0.5 99.5)
replace TACC = r(c_1) if TACC < r(c_1) 
replace TACC = r(c_2) if TACC > r(c_2) 

centile size, centile(0.5 99.5)
replace size = r(c_1) if size < r(c_1)
replace size = r(c_2) if size > r(c_2)

** winsorize IS compustat variables

centile prof, centile(0.5 99.5)
replace prof = r(c_1) if prof < r(c_1)
replace prof = r(c_2) if prof > r(c_2)

centile d_yield, centile(0.5 99.5)
replace d_yield = r(c_1) if d_yield < r(c_1)
replace d_yield = r(c_2) if d_yield > r(c_2)

centile NI, centile(0.5 99.5)
replace NI = r(c_1) if NI < r(c_1)
replace NI = r(c_2) if NI > r(c_2)

centile div, centile(0.5 99.5)
replace div = r(c_1) if div < r(c_1)
replace div = r(c_2) if div > r(c_2)

centile gs, centile(0.5 99.5)
replace gs = r(c_1) if gs < r(c_1) 
replace gs = r(c_2) if gs > r(c_2) 

** winsorize CF compustat variables

centile OCF, centile(0.5 99.5)
replace OCF = r(c_1) if OCF < r(c_1) 
replace OCF = r(c_2) if OCF > r(c_2)

centile OCF1, centile(0.5 99.5)
replace OCF1 = r(c_1) if OCF1 < r(c_1) & OCF1 !=.
replace OCF1 = r(c_2) if OCF1 > r(c_2) & OCF1 !=.

centile capex, centile(0.5 99.5)
replace capex = r(c_1) if capex < r(c_1)
replace capex = r(c_2) if capex > r(c_2)

centile capex1, centile(0.5 99.5)
replace capex1 = r(c_1) if capex1 < r(c_1) & capex1 !=.
replace capex1 = r(c_2) if capex1 > r(c_2) & capex1 !=.

centile AQC, centile(0.5 99.5)
replace AQC = r(c_1) if AQC < r(c_1)
replace AQC = r(c_2) if AQC > r(c_2)

centile div1, centile(0.5 99.5)
replace div1 = r(c_1) if div1 < r(c_1) & div1 !=.
replace div1 = r(c_2) if div1 > r(c_2) & div1 !=.

centile div2, centile(0.5 99.5)
replace div2 = r(c_1) if div2 < r(c_1) & div2 !=.
replace div2 = r(c_2) if div2 > r(c_2) & div2 !=.

centile DEF, centile(0.5 99.5)
replace DEF = r(c_1) if DEF < r(c_1) & DEF !=.
replace DEF = r(c_2) if DEF > r(c_2) & DEF !=.

*** GENERATE WHITED WU INDEX

gen WW = -0.091*OCF - 0.062*DIVPOS + 0.021*TLDT - 0.044*size + 0.102*ISG - 0.035*gs

*** GENERATE KAPLAN ZINGALES INDEX

gen KZ = -1.001909*OCF + 3.139193*BL - 39.36780*div - 1.314759*CR + 0.2826389*Q
centile KZ, centile(0.5 99.5)

*** gen ecapex and ediv

gen ecapex = capex - ind_capex_3fyr
gen ediv = div - ind_div_3fyr

** record fractions as percentage points

replace consol_lev = consol_lev*100

replace total_tot_contr_E = total_tot_contr_E*100

replace total_tot_contr_at = total_tot_contr_at*100
replace total_tot_contr_plassets = total_tot_contr_plassets*100

replace total_MFC_at = total_MFC_at*100
replace total_MFC_plassets = total_MFC_plassets*100

replace tax1 = tax1*100
replace tax2 = tax2*100

replace diff_liabA = diff_liabA*100

replace relfundingA = relfundingA*100

*** generate positive and negative funding variable

gen p_relfundingA = relfundingA if relfundingA >=0
replace p_relfundingA = 0 if p_relfundingA ==.

gen n_relfundingA = relfundingA*(-1) if relfundingA < 0
replace n_relfundingA = 0 if n_relfundingA ==.

*** generate cash deficit indicator

gen deficit = 1 if DEF > OCF
replace deficit = 0 if deficit ==.


cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save longevity_compustat, replace


**** ANALYSIS OF PENSION PLAN SPONSORS

clear all

set memory 3000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity_compustat 

**** descriptive info on pension liability gap

summ diff_liabA, d

summ diff_liabA if diff_liabA >0
gen N = r(N)
summ diff_liabA

display N/r(N)

*** number of plans

sort gvkey year
gen count = 1
replace count = count[_n-1] + 1 if gvkey == gvkey[_n-1]

gen ncount = count
replace ncount =. if ncount[_n+1] !=. & gvkey == gvkey[_n+1]

edit gvkey year count ncount

*** average and medium number of observations per plan

summ ncount,d

** generate number of plans each year

sort year
by year: egen obs = count(gvkey)

*** define total number of manipulative years by plan sponsor

sort gvkey fyear

by gvkey: egen sum_manipA = sum(manipA)
by gvkey: egen num = count(manipA)

*edit gvkey fyear manip sum_manipA num

*** generate number of plan-years by year and manip

sort year gvkey

by year: egen manipA_obs = count(manipA) if manipA > 0
by year: egen nomanipA_obs = count(manipA) if manipA == 0

*** Table 3, Panel B

tabstat total_accr_liab total_liab diff_liabA total_asset relfundingA total_interest total_interest_RPA D_interestA long_index_cs long_GM83 LEA sizeA durationA riskyA obs, by(year)

*** replication of full sample tables (Section 4)

*** Original Table 4 analysis - displayed in Online Appendix Table 5

reg diff_liabA relfundingA, r
estimates store OLS1

reg diff_liabA relfundingA sizeA durationA riskyA, r
estimates store OLS2

reg diff_liabA relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liabA relfundingA, fe
estimates store FE1

xtscc diff_liabA relfundingA sizeA durationA riskyA, fe
estimates store FE2

xtscc diff_liabA relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Original Table 6 analysis - displayed in Online Appendix Table 6

reg D_interest relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfundingA n_relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfundingA n_relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear


*** Original Table 7 analysis - displayed in Online Appendix Table 7

gen dum_neg = 1 if LEA < 0
replace dum_neg = 0 if dum_neg ==.

logit dum_neg relfundingA, vce(robust) 
estimates store reg1

logit dum_neg relfundingA sizeA durationA riskyA, vce(robust)
estimates store reg2

logit dum_neg relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfundingA n_relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** Original Table 9, Panel A analysis - displayed in Online Appendix Table 8, Panel A

reg total_tot_contr_plassets manipA if relfundingA <=0, r
estimates store reg1

reg total_tot_contr_plassets manipA relfundingA if relfundingA <=0, r
estimates store reg2

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA if relfundingA <=0 , r
estimates store reg3

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg4

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg5

xtscc total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** Original Table 9, Panel B analysis - displayed in Online Appendix Table 8, Panel B

reg total_MFC_plassets manipA if relfundingA <=0, r
estimates store reg1

reg total_MFC_plassets manipA relfundingA if relfundingA <=0, r
estimates store reg2

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA if relfundingA <=0, r
estimates store reg3

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg4

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom d2 d3 d4 d5 d6 d7 d8 d9 d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg5

xtscc total_MFC_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** some untabulated comparisons

tabstat total_tot_contr pbec, by(manipA)

tabstat total_accr_liab total_liab pbpro, by(manipA)

tabstat pbarr total_interest_RPA total_interest, by(manipA) 

*** Table 10: compare manipulative (Panel A) to non-manipulative firms (Panel B) 

tabstat manipA_obs relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1 TACC ppror g pbarr deficit if manipA > 0, by(year)

tabstat nomanipA_obs relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1  TACC ppror g pbarr deficit if manipA == 0, by(year)

** get the number of observations for each variable

summ relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1 TACC ppror g pbarr deficit if manipA > 0

summ relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1  TACC ppror g pbarr deficit if manipA == 0

*** Table 11: determinant regressions

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg1

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg2

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg3

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg4

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg5

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** untabulated info (used for interpretation)

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC deficit HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if g !=.
logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC deficit HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if g!=.

*** untabulated: OLS regressions with G

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg3

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estimates clear 

*** untabulated: FE regressions with G

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg5

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estimates clear 

*** difference in ratios

ttest capex, by(manipA)
ttest div, by(manipA)

ttest ecapex, by(manipA)
ttest ediv, by(manipA)


**************************************************************************************************************
*** Inv/CF Regressions
**************************************************************************************************************

sort gvkey fyear

*** compute cash flow before pension contributions

replace total_MFC_at1 = 0 if lagrelfundingA > 0

gen OCFa1 = OCF1 + total_tot_contr_at1
gen OCFb1 = OCF1 + total_MFC_at1

** compute interaction term

gen IAa1 = manipA*total_tot_contr_at1
gen IAb1 = manipA*total_MFC_at1

*** Table 12, Panel A

xtscc capex1 OCFa1 total_tot_contr_at1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc capex1 manipA OCFa1 total_tot_contr_at1 IAa1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc capex1 manipA OCFa1 total_tot_contr_at1 IAa1 lagQ lagrelfundingA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed)
estimates clear 

*** Table 12, Panel B

xtscc capex1 OCFb1 total_MFC_at1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc capex1 manipA OCFb1 total_MFC_at1 IAb1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc capex1 manipA OCFb1 total_MFC_at1 IAb1 lagQ lagrelfundingA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear 

*** difference in equity issues and acquisition frequencies

ttest EI, by(manipA)
ttest AI, by(manipA)

ttest AI25, by(manipA)
ttest EI25, by(manipA)

ttest AI75, by(manipA)
ttest EI75, by(manipA)

**************************************************************************************************************
*** Credit risk test
**************************************************************************************************************
summ relfundingA p_relfundingA

*** Table 13, Panel A

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND , r
estimates store reg1

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2
predict resid_OLS, residuals
predict yhat_OLS

xtscc D_interestA Z consol_lev rel_size sizeA durationA riskyA,  fe
estimates store reg3

xtscc D_interestA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,   fe
estimates store reg4

areg D_interestA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, absorb(gvkey) r
predict resid_FE, residual
predict yhat, xbd

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Table 13, Panel B

reg resid_OLS relfundingA, r
estimates store OLS1_SS

reg resid_OLS p_relfundingA n_relfundingA, r
estimates store OLS2_SS

xtscc resid_FE relfundingA, fe
estimates store FE1_SS 

xtscc resid_FE p_relfundingA n_relfundingA, fe
estimates store FE2_SS

estout OLS1_SS OLS2_SS FE1_SS FE2_SS, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1_SS OLS2_SS FE1_SS FE2_SS, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*** untabulated
reg D_interestA p_relfundingA n_relfundingA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
xtscc D_interestA p_relfundingA n_relfundingA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,   fe

** check whether this makes sense

gen res = D_interestA - yhat

edit res resid_FE

** check whether this makes sense

gen res_OLS = D_interestA - yhat_OLS

edit res_OLS resid_OLS

*** end of check

drop res* yhat*

************************************************************************************
*** Online Appendix: untabulated double sort consolidated leverage and Z-score
************************************************************************************

centile consol_lev, centile(50)
gen CL_p50 = r(c_1) 

centile Z, centile(50)
gen Z_p50 = r(c_1) 

*** consolidated leverage buckets

gen CL_1 = 1 if consol_lev <= CL_p50 
replace CL_1 = 0 if CL_1 == .

gen CL_2 = 1 if consol_lev > CL_p50 
replace CL_2 = 0 if CL_2 == .

*** Z-score buckets

gen Z_1 = 1 if Z <= Z_p50 
replace Z_1 = 0 if Z_1 == .

gen Z_2 = 1 if Z > Z_p50 
replace Z_2 = 0 if Z_2 == .


*** create 4 "portfolios"

gen CL_PF = 1 if CL_1 == 1
gen Z_PF = 1 if Z_1 == 1

forvalues i=2(1)2{
replace CL_PF = `i' if CL_`i' == 1
replace Z_PF = `i' if Z_`i' == 1
}

** display corresponding sort characteristics

tabsort CL_PF Z_PF, su(consol_lev) nocsort norsort

tabsort CL_PF Z_PF, su(Z) nocsort norsort


**perform 2 stage regression model

sort CL_PF gvkey fyear

*replace p_relfundingA = relfundingA

*replace n_relfundingA = relfundingA

** 1st stage

forvalues j=1(1)2{
reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if CL_PF == `j', r
predict resid_PF_`j', residual
estimates store PF_`j'

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if Z_PF == `j', r
predict Zresid_PF_`j', residual
estimates store ZPF_`j'
}

** 2nd stage
 
forvalues j=1(1)2{
reg resid_PF_`j' p_relfundingA n_relfundingA if CL_PF == `j', r
estimates store PF_`j'
reg Zresid_PF_`j' p_relfundingA n_relfundingA if Z_PF == `j', r
estimates store ZPF_`j'

}

estout ZPF_1 ZPF_2 PF_1 PF_2 , cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout ZPF_1 ZPF_2 PF_1 PF_2, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

drop resid_PF_* Zresid_PF_* 


*** this file appends the raw data for 2011 and 2012
*** this file cleans the data 

clear all

set memory 4000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

use raw_2012

append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest/raw_2011.dta"

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate DB dummy

gen DB_string = substr(type_pension_bnft_code,1,1)
gen DB = 1 if DB_string == "1"
replace DB = 0 if DB ==.

*** generate DC dummy

gen DC_string = substr(type_pension_bnft_code,1,1)
gen DC = 1 if DC_string == "2"
replace DC = 0 if DC ==.

*** generate other dummy

gen oth = 1 if DC == 0 & DB == 0
replace oth = 0 if oth ==.

gen date = date(sb_plan_year_begin_date, "YMD")
format date %td

gen year_date = year(date)
gen month_date = month(date)

*** focus on DB plans

drop if DB != 1
drop oth

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

summ DB

*** drop multi-employer plans and other animals

drop if type_plan_entity_cd != 2

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** check whether some plan years appear twice

sort ID year

egen id = group(ID year)

sort id

*** check wether id changes

gen idL = id - id[_n-1]
gen idL1 = id[_n+1]-id

*** drob observations in case it id stays constant (forward and backward)

drop if idL ==0
drop if idL1 ==0

drop id idL idL1

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** set time parameter and compute sample

sort ID year

egen id = group(ID)

sort id year

xtset id year

summ DB id year

*** drop small plans (total particpation is only available BOY. General, 6)

gen participants = tot_partcp_boy_cnt
drop if participants < 100

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate liability variable 

gen liab = sb_tot_fndng_tgt_amt
drop if liab == .
drop if liab <=0

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen asset = sb_curr_value_ast_01_amt
drop if asset ==.
drop if asset <=0


*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate funding variable

gen relfunding = (asset - liab)/liab
drop if relfunding ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate mandatory pension contribution
sort id year

gen mand_contrib = sb_fndng_rqmt_tot_amt
drop if mand_contrib ==.
summ mand_contrib, d

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate MPC in % of assets

gen rel_mand_contrib = mand_contrib/asset

*** generate change in MPC


sort id year
gen D_mand_contrib = (mand_contrib - l1.mand_contrib)/l1.mand_contrib

*** generate total contributions

*gen contrib = sb_contr_alloc_curr_yr_02_amt
gen contrib = sb_tot_emplr_contrib_amt
drop if contrib ==.
summ contrib, d

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen rel_contrib = sb_tot_emplr_contrib_amt/asset

*** generate excess contributions

gen exc_contrib = contrib - mand_contrib
drop if exc_contrib ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen rel_exc_contrib = exc_contrib/asset

**** create industry dummmies

tostring business_code, generate(NAICS)

****

gen agr = 1 if substr(NAICS, 1,2) == "11"
replace agr = 0 if agr ==.

gen min = 1 if substr(NAICS, 1,2) == "21"
replace min = 0 if min ==.

gen util = 1 if substr(NAICS, 1,2) == "22"
replace util = 0 if util ==.

gen cstrc = 1 if substr(NAICS, 1,2) == "23"
replace cstrc = 0 if cstrc ==.

gen man = 1 if substr(NAICS, 1,2) == "31"
replace man = 1 if substr(NAICS, 1,2) == "32"
replace man = 1 if substr(NAICS, 1,2) == "33"
replace man = 0 if man ==.

gen whle = 1 if substr(NAICS, 1,2) == "42"
replace whle = 0 if whle ==.

gen retl = 1 if substr(NAICS, 1,2) == "44"
replace retl = 1 if substr(NAICS, 1,2) == "45"
replace retl = 0 if retl ==.

gen trans = 1 if substr(NAICS, 1,2) == "48"
replace trans = 1 if substr(NAICS, 1,2) == "49"
replace trans = 0 if trans ==.

gen inf = 1 if substr(NAICS, 1,2) == "51"
replace inf = 0 if inf ==.

gen fin = 1 if substr(NAICS, 1,2) == "52"
replace fin = 0 if fin ==.

gen real = 1 if substr(NAICS, 1,2) == "53"
replace real = 0 if real ==.

gen prof = 1 if substr(NAICS, 1,2) == "54"
replace prof = 0 if prof ==.

gen hldg = 1 if substr(NAICS, 1,2) == "55"
replace hldg = 0 if hldg ==.

gen admin = 1 if substr(NAICS, 1,2) == "56"
replace admin = 0 if admin ==.

gen edu = 1 if substr(NAICS, 1,2) == "61"
replace edu = 0 if edu ==.

gen hlth = 1 if substr(NAICS, 1,2) == "62"
replace hlth = 0 if hlth ==.

gen arts = 1 if substr(NAICS, 1,2) == "71"
replace arts = 0 if arts ==.

gen accom = 1 if substr(NAICS, 1,2) == "72"
replace accom = 0 if accom ==.

gen oth = 1 if substr(NAICS, 1,2) == "81"
replace oth = 1 if substr(NAICS, 1,2) == "92"
replace oth = 0 if oth ==.

gen test = agr + min + util + cstrc + man + whle + retl + trans + inf + fin + real + prof + hldg + admin + edu + hlth + arts + accom + oth

summ test if test == 0

*** industry classification: visual inspection suggests that if test == 0, then missing or unclassified numbers

gen industry = "agr" if agr ==1
replace industry = "min" if min == 1
replace industry = "util" if util == 1
replace industry = "cstrc" if cstrc == 1
replace industry = "man" if man == 1
replace industry = "whle" if whle == 1
replace industry = "retl" if retl == 1
replace industry = "trans" if trans == 1
replace industry = "inf" if inf == 1
replace industry = "fin" if fin == 1
replace industry = "real" if real == 1
replace industry = "prof" if prof == 1
replace industry = "hldg" if hldg == 1
replace industry = "admin" if admin == 1
replace industry = "edu" if edu == 1
replace industry = "hlth" if hlth == 1
replace industry = "arts" if arts == 1
replace industry = "accom" if accom == 1
replace industry = "oth" if oth == 1

*** size variable

gen size = log(asset) 

*** duration variable

replace rtd_sep_partcp_rcvg_cnt= 0 if rtd_sep_partcp_rcvg_cnt ==.
replace benef_rcvg_bnft_cnt = 0 if benef_rcvg_bnft_cnt ==.

gen part_ret = rtd_sep_partcp_rcvg_cnt + benef_rcvg_bnft_cnt

gen duration = 1 - part_ret/participants

**** focus on asset allocation


*** generate investment variables

gen cash = non_int_bear_cash_eoy_amt
replace cash = 0 if cash ==.
 
gen cash_inv = int_bear_cash_eoy_amt
replace cash_inv = 0 if cash_inv ==.

gen AR = emplr_contrib_eoy_amt + partcp_contrib_eoy_amt + other_receivables_eoy_amt
replace AR = 0 if AR ==.

gen US_treas = govt_sec_eoy_amt
replace US_treas = 0 if US_treas ==.

gen debt_corp = corp_debt_preferred_eoy_amt + corp_debt_other_eoy_amt
replace debt_corp = 0 if debt_corp ==.

gen equity = pref_stock_eoy_amt + common_stock_eoy_amt
replace equity = 0 if equity ==.

gen JV = joint_venture_eoy_amt
replace JV = 0 if JV ==.

gen RE = real_estate_eoy_amt
replace RE = 0 if RE ==.

gen loans = other_loans_eoy_amt + partcp_loans_eoy_amt
replace loans = 0 if loans ==.

gen com_trust = int_common_tr_eoy_amt
replace com_trust = 0 if com_trust ==.

gen pool_trust = int_pool_sep_acct_eoy_amt
replace pool_trust = 0 if pool_trust ==.

gen master_trust = int_master_tr_eoy_amt
replace master_trust = 0 if master_trust ==.

gen inv = int_103_12_invst_eoy_amt
replace inv = 0 if inv ==.

gen funds = int_reg_invst_co_eoy_amt
replace funds = 0 if funds ==.

gen insurance = ins_co_gen_acct_eoy_amt
replace insurance = 0 if insurance ==.

gen other = oth_invst_eoy_amt
replace other = 0 if other ==.

gen employer = emplr_sec_eoy_amt + emplr_prop_eoy_amt
replace employer = 0 if employer ==.

gen buildings = bldgs_used_eoy_amt
replace buildings = 0 if buildings ==.

gen TA = tot_assets_eoy_amt

gen impl_TA = cash + cash_inv + AR + US_treas + debt_corp + equity + JV + RE + loans +  com_trust +  pool_trust + master_trust + inv + funds + insurance + other + employer + buildings

summ TA impl_TA

*** drop negative values
drop if cash < 0
drop if cash_inv < 0
drop if AR < 0
drop if US_treas < 0
drop if debt_corp < 0
drop if equity < 0
drop if JV < 0
drop if RE < 0
drop if loans < 0
drop if com_trust < 0
drop if pool_trust < 0
drop if master_trust < 0
drop if inv < 0
drop if funds < 0
drop if insurance < 0
drop if other < 0
drop if employer < 0
drop if buildings < 0

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

***

gen rel_cash = cash/impl_TA
gen rel_cash_inv = cash_inv/impl_TA
gen rel_AR = AR/impl_TA
gen rel_US_treas = US_treas/impl_TA
gen rel_debt_corp = debt_corp/impl_TA
gen rel_equity = equity/impl_TA
gen rel_JV = JV/impl_TA
gen rel_RE = RE/impl_TA
gen rel_loans = loans/impl_TA
gen rel_com_trust = com_trust/impl_TA
gen rel_master_trust = master_trust/impl_TA
gen rel_pool_trust = pool_trust/impl_TA
gen rel_inv = inv/impl_TA
gen rel_funds = funds/impl_TA
gen rel_insurance = insurance/impl_TA
gen rel_other = other/impl_TA
gen rel_employer = employer/impl_TA
gen rel_buildings = buildings/impl_TA


*** define risky assets

gen risky = 1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp
drop if risky ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

summ risky, d 

*** tset the variable

gen myear= ym(year_date,month_date)

format myear %tm

sort ID myear
drop id
egen id = group(ID)

sort id myear
xtset id myear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL"

save data, replace

****
clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

*** manually build up the dataset 
*** reason: we need to enter the segmented yield curve boundaries manually

set obs 1

generate year_date = 2010 in 1
gen month_date = 1 in 1

forvalues i=2(1)12{
set obs `i'
replace year_date = 2010 in `i' 
replace month_date = `i'  in `i' 
}

set obs 13
replace year_date = 2011 in 13
replace month_date =1 in 13

forvalues i=14(1)24{
set obs `i'
replace year_date = 2011 in `i' 
replace month_date = (`i' - 12)  in `i'
}

set obs 25
replace year_date = 2012 in 25
replace month_date =1 in 25

forvalues i=26(1)36{
set obs `i'
replace year_date = 2012 in `i' 
replace month_date = (`i' - 24)  in `i' 
}

** generate monthly variables

gen myear= ym(year_date,month_date)

format myear %tm

tset myear

**** the segement rates are obtains from the IRS
***http://www.irs.gov/Retirement-PLans/Funding-Yield-Curve-Segment-Rates (hardcopy available)


*** official segment rates in 2010

gen reg_interest_seg1 = 460 if year_date == 2010 & month_date == 1
gen reg_interest_seg2 = 665 if year_date == 2010 & month_date == 1
gen reg_interest_seg3 = 676 if year_date == 2010 & month_date == 1

replace reg_interest_seg1 = 451 if year_date == 2010 & month_date == 2
replace reg_interest_seg2 = 664 if year_date == 2010 & month_date == 2
replace reg_interest_seg3 = 675 if year_date == 2010 & month_date == 2

replace reg_interest_seg1 = 444 if year_date == 2010 & month_date == 3
replace reg_interest_seg2 = 662 if year_date == 2010 & month_date == 3
replace reg_interest_seg3 = 674 if year_date == 2010 & month_date == 3

replace reg_interest_seg1 = 435 if year_date == 2010 & month_date == 4
replace reg_interest_seg2 = 659 if year_date == 2010 & month_date == 4
replace reg_interest_seg3 = 672 if year_date == 2010 & month_date == 4

replace reg_interest_seg1 = 426 if year_date == 2010 & month_date == 5
replace reg_interest_seg2 = 656 if year_date == 2010 & month_date == 5
replace reg_interest_seg3 = 670 if year_date == 2010 & month_date == 5

replace reg_interest_seg1 = 416 if year_date == 2010 & month_date == 6
replace reg_interest_seg2 = 652 if year_date == 2010 & month_date == 6
replace reg_interest_seg3 = 668 if year_date == 2010 & month_date == 6

replace reg_interest_seg1 = 405 if year_date == 2010 & month_date == 7
replace reg_interest_seg2 = 647 if year_date == 2010 & month_date == 7
replace reg_interest_seg3 = 665 if year_date == 2010 & month_date == 7

replace reg_interest_seg1 = 392 if year_date == 2010 & month_date == 8
replace reg_interest_seg2 = 640 if year_date == 2010 & month_date == 8
replace reg_interest_seg3 = 661 if year_date == 2010 & month_date == 8

replace reg_interest_seg1 = 378 if year_date == 2010 & month_date == 9
replace reg_interest_seg2 = 631 if year_date == 2010 & month_date == 9
replace reg_interest_seg3 = 657 if year_date == 2010 & month_date == 9

replace reg_interest_seg1 = 361 if year_date == 2010 & month_date == 10
replace reg_interest_seg2 = 620 if year_date == 2010 & month_date == 10
replace reg_interest_seg3 = 653 if year_date == 2010 & month_date == 10

replace reg_interest_seg1 = 337 if year_date == 2010 & month_date == 11
replace reg_interest_seg2 = 604 if year_date == 2010 & month_date == 11
replace reg_interest_seg3 = 649 if year_date == 2010 & month_date == 11

replace reg_interest_seg1 = 314 if year_date == 2010 & month_date == 12
replace reg_interest_seg2 = 590 if year_date == 2010 & month_date == 12
replace reg_interest_seg3 = 646 if year_date == 2010 & month_date == 12

*** official segment rates in 2011

replace reg_interest_seg1 = 294 if year_date == 2011 & month_date == 1
replace reg_interest_seg2 = 582 if year_date == 2011 & month_date == 1
replace reg_interest_seg3 = 646 if year_date == 2011 & month_date == 1

replace reg_interest_seg1 = 281 if year_date == 2011 & month_date == 2
replace reg_interest_seg2 = 576 if year_date == 2011 & month_date == 2
replace reg_interest_seg3 = 646 if year_date == 2011 & month_date == 2

replace reg_interest_seg1 = 267 if year_date == 2011 & month_date == 3
replace reg_interest_seg2 = 569 if year_date == 2011 & month_date == 3
replace reg_interest_seg3 = 644 if year_date == 2011 & month_date == 3

replace reg_interest_seg1 = 251 if year_date == 2011 & month_date == 4
replace reg_interest_seg2 = 559 if year_date == 2011 & month_date == 4
replace reg_interest_seg3 = 638 if year_date == 2011 & month_date == 4

replace reg_interest_seg1 = 238 if year_date == 2011 & month_date == 5
replace reg_interest_seg2 = 551 if year_date == 2011 & month_date == 5
replace reg_interest_seg3 = 636 if year_date == 2011 & month_date == 5

replace reg_interest_seg1 = 227 if year_date == 2011 & month_date == 6
replace reg_interest_seg2 = 543 if year_date == 2011 & month_date == 6
replace reg_interest_seg3 = 634 if year_date == 2011 & month_date == 6

replace reg_interest_seg1 = 218 if year_date == 2011 & month_date == 7
replace reg_interest_seg2 = 536 if year_date == 2011 & month_date == 7
replace reg_interest_seg3 = 633 if year_date == 2011 & month_date == 7

replace reg_interest_seg1 = 211 if year_date == 2011 & month_date == 8
replace reg_interest_seg2 = 531 if year_date == 2011 & month_date == 8
replace reg_interest_seg3 = 632 if year_date == 2011 & month_date == 8

replace reg_interest_seg1 = 206 if year_date == 2011 & month_date == 9
replace reg_interest_seg2 = 525 if year_date == 2011 & month_date == 9
replace reg_interest_seg3 = 632 if year_date == 2011 & month_date == 9

replace reg_interest_seg1 = 203 if year_date == 2011 & month_date == 10
replace reg_interest_seg2 = 520 if year_date == 2011 & month_date == 10
replace reg_interest_seg3 = 630 if year_date == 2011 & month_date == 10

replace reg_interest_seg1 = 201 if year_date == 2011 & month_date == 11
replace reg_interest_seg2 = 516 if year_date == 2011 & month_date == 11
replace reg_interest_seg3 = 628 if year_date == 2011 & month_date == 11

replace reg_interest_seg1 = 199 if year_date == 2011 & month_date == 12
replace reg_interest_seg2 = 512 if year_date == 2011 & month_date == 12
replace reg_interest_seg3 = 624 if year_date == 2011 & month_date == 12

*** official segment rates in 2012

replace reg_interest_seg1 = 198 if year_date == 2012 & month_date == 1
replace reg_interest_seg2 = 507 if year_date == 2012 & month_date == 1
replace reg_interest_seg3 = 619 if year_date == 2012 & month_date == 1

replace reg_interest_seg1 = 196 if year_date == 2012 & month_date == 2
replace reg_interest_seg2 = 501 if year_date == 2012 & month_date == 2
replace reg_interest_seg3 = 613 if year_date == 2012 & month_date == 2

replace reg_interest_seg1 = 193 if year_date == 2012 & month_date == 3
replace reg_interest_seg2 = 495 if year_date == 2012 & month_date == 3
replace reg_interest_seg3 = 607 if year_date == 2012 & month_date == 3

replace reg_interest_seg1 = 190 if year_date == 2012 & month_date == 4
replace reg_interest_seg2 = 490 if year_date == 2012 & month_date == 4
replace reg_interest_seg3 = 601 if year_date == 2012 & month_date == 4

replace reg_interest_seg1 = 187 if year_date == 2012 & month_date == 5
replace reg_interest_seg2 = 484 if year_date == 2012 & month_date == 5
replace reg_interest_seg3 = 596 if year_date == 2012 & month_date == 5

replace reg_interest_seg1 = 184 if year_date == 2012 & month_date == 6
replace reg_interest_seg2 = 479 if year_date == 2012 & month_date == 6
replace reg_interest_seg3 = 590 if year_date == 2012 & month_date == 6

replace reg_interest_seg1 = 181 if year_date == 2012 & month_date == 7
replace reg_interest_seg2 = 473 if year_date == 2012 & month_date == 7
replace reg_interest_seg3 = 585 if year_date == 2012 & month_date == 7

replace reg_interest_seg1 = 177 if year_date == 2012 & month_date == 8
replace reg_interest_seg2 = 467 if year_date == 2012 & month_date == 8
replace reg_interest_seg3 = 578 if year_date == 2012 & month_date == 8

replace reg_interest_seg1 = 175 if year_date == 2012 & month_date == 9
replace reg_interest_seg2 = 462 if year_date == 2012 & month_date == 9
replace reg_interest_seg3 = 572 if year_date == 2012 & month_date == 9

replace reg_interest_seg1 = 172 if year_date == 2012 & month_date == 10
replace reg_interest_seg2 = 458 if year_date == 2012 & month_date == 10
replace reg_interest_seg3 = 567 if year_date == 2012 & month_date == 10

replace reg_interest_seg1 = 169 if year_date == 2012 & month_date == 11
replace reg_interest_seg2 = 453 if year_date == 2012 & month_date == 11
replace reg_interest_seg3 = 560 if year_date == 2012 & month_date == 11

replace reg_interest_seg1 = 166 if year_date == 2012 & month_date == 12
replace reg_interest_seg2 = 447 if year_date == 2012 & month_date == 12
replace reg_interest_seg3 = 552 if year_date == 2012 & month_date == 12

*** official segment rates in 2013

replace reg_interest_seg1 = 162 if year_date == 2013 & month_date == 1
replace reg_interest_seg2 = 440 if year_date == 2013 & month_date == 1
replace reg_interest_seg3 = 545 if year_date == 2013 & month_date == 1

replace reg_interest_seg1 = 158 if year_date == 2013 & month_date == 2
replace reg_interest_seg2 = 434 if year_date == 2013 & month_date == 2
replace reg_interest_seg3 = 538 if year_date == 2013 & month_date == 2

replace reg_interest_seg1 = 154 if year_date == 2013 & month_date == 3
replace reg_interest_seg2 = 428 if year_date == 2013 & month_date == 3
replace reg_interest_seg3 = 532 if year_date == 2013 & month_date == 3

replace reg_interest_seg1 = 150 if year_date == 2013 & month_date == 4
replace reg_interest_seg2 = 422 if year_date == 2013 & month_date == 4
replace reg_interest_seg3 = 526 if year_date == 2013 & month_date == 4

replace reg_interest_seg1 = 146 if year_date == 2013 & month_date == 5
replace reg_interest_seg2 = 415 if year_date == 2013 & month_date == 5
replace reg_interest_seg3 = 520 if year_date == 2013 & month_date == 5

replace reg_interest_seg1 = 143 if year_date == 2013 & month_date == 6
replace reg_interest_seg2 = 410 if year_date == 2013 & month_date == 6
replace reg_interest_seg3 = 515 if year_date == 2013 & month_date == 6

replace reg_interest_seg1 = 141 if year_date == 2013 & month_date == 7
replace reg_interest_seg2 = 407 if year_date == 2013 & month_date == 7
replace reg_interest_seg3 = 511 if year_date == 2013 & month_date == 7

replace reg_interest_seg1 = 139 if year_date == 2013 & month_date == 8
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 8
replace reg_interest_seg3 = 508 if year_date == 2013 & month_date == 8

replace reg_interest_seg1 = 137 if year_date == 2013 & month_date == 9
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 9
replace reg_interest_seg3 = 506 if year_date == 2013 & month_date == 9

replace reg_interest_seg1 = 135 if year_date == 2013 & month_date == 10
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 10
replace reg_interest_seg3 = 505 if year_date == 2013 & month_date == 10

replace reg_interest_seg1 = 131 if year_date == 2013 & month_date == 11
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 11
replace reg_interest_seg3 = 505 if year_date == 2013 & month_date == 11

replace reg_interest_seg1 = 128 if year_date == 2013 & month_date == 12
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 12
replace reg_interest_seg3 = 507 if year_date == 2013 & month_date == 12


*** create both 12 months lag and lead values

forvalues i=1(1)12{
gen lag`i'_reg_interest_seg1 = l`i'.reg_interest_seg1
gen lag`i'_reg_interest_seg2 = l`i'.reg_interest_seg2
gen lag`i'_reg_interest_seg3 = l`i'.reg_interest_seg3
}

forvalues i=1(1)12{
gen lead`i'_reg_interest_seg1 = f`i'.reg_interest_seg1
gen lead`i'_reg_interest_seg2 = f`i'.reg_interest_seg2
gen lead`i'_reg_interest_seg3 = f`i'.reg_interest_seg3
}

*** doublec check that code is correct, it is

*edit if year_date == 2011

*** merge with Form 5500 Raw Data (for 2011 and 2012)

sort myear

merge 1:m myear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/data"

****

drop if _merge !=3

drop _merge

***
sort id myear

*** generate yield curve dummy

gen yield_curve = sb_yield_curve_ind
replace yield_curve = 0 if sb_yield_curve_ind ==.

sort id
egen plans = group(id)
summ plans
drop plans

*** shows that out of full sample of plans in 2011 and 2012, 99.2% use segmented yield curve concept

summ yield_curve, d

*** generate interest rate

gen interest = sb_eff_int_rate_prcnt*100
drop if interest ==.

*** generate segment interest rates

gen interest_seg1 = sb_1st_seg_rate_prcnt*100
gen interest_seg2 = sb_2nd_seg_rate_prcnt*100
gen interest_seg3 = sb_3rd_seg_rate_prcnt*100

drop if interest_seg1 ==.
drop if interest_seg2 ==.
drop if interest_seg3 ==.

*** drop obvious typos (based on page 1, IRS document)

summ interest_seg1 if interest_seg1 > 677
drop  if interest_seg1 > 677

summ interest_seg2 if interest_seg2 > 837
drop  if interest_seg2 > 837

summ interest_seg3 if interest_seg3 > 918
drop  if interest_seg3 > 918

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** deal with details of pension funding law. the used interest rate should equal the published rate (entered manually above) subject to a +/- 12 months deviation
*** we account for the lead/lag and allow for minor typos (defined as 2 basis points difference; small impact on sample size)

**** look at difference between used rate and the regulated interest rate

gen diff_seg1 = interest_seg1 - reg_interest_seg1 if year_date == 2011
gen diff_seg2 = interest_seg2 - reg_interest_seg2 if year_date == 2011
gen diff_seg3 = interest_seg3 - reg_interest_seg3 if year_date == 2011

*** define tolerance threshold (2 basis points)

gen th = 2

*** compute total difference in assumptions (measured in basis points)

gen diff = diff_seg1 + diff_seg2 + diff_seg3 if year_date == 2011
replace diff = 0 if diff > -th & diff < th & year_date == 2011

summ diff if year_date == 2011
summ diff if diff == 0 & year_date == 2011

gen dum = 1 if diff == 0 & year_date == 2011
replace dum = 0 if dum ==. & year_date == 2011

gen diff_0 = diff
gen dum_0 = dum

*** compute lookback (and lookforward) interest rates for 1 to 12 months

forvalues i=1(1)12{
gen diff_seg1_l`i' = interest_seg1 - lag`i'_reg_interest_seg1 if year_date == 2011
gen diff_seg2_l`i' = interest_seg2 - lag`i'_reg_interest_seg2 if year_date == 2011
gen diff_seg3_l`i' = interest_seg3 - lag`i'_reg_interest_seg3 if year_date == 2011

gen diff_seg1_f`i' = interest_seg1 - lead`i'_reg_interest_seg1 if year_date == 2011
gen diff_seg2_f`i' = interest_seg2 - lead`i'_reg_interest_seg2 if year_date == 2011
gen diff_seg3_f`i' = interest_seg3 - lead`i'_reg_interest_seg3 if year_date == 2011

gen diff_l`i' = diff_seg1_l`i' + diff_seg2_l`i' + diff_seg3_l`i' if year_date == 2011
gen diff_f`i' = diff_seg1_f`i' + diff_seg2_f`i' + diff_seg3_f`i' if year_date == 2011

replace diff_l`i' = 0 if diff_l`i' > -th & diff_l`i' < th & year_date == 2011
replace diff_f`i' = 0 if diff_f`i' > -th & diff_f`i' < th & year_date == 2011

gen dum_l`i' = 1 if diff_l`i' == 0 & year_date == 2011
replace dum_l`i' = 0 if dum_l`i' ==. & year_date == 2011

gen dum_f`i' = 1 if diff_f`i' == 0 & year_date == 2011
replace dum_f`i' = 0 if dum_f`i' ==. & year_date == 2011
}

**** replace difference
forvalues i=1(1)12{
replace diff = diff_l`i' if dum_l`i' == 1 & year_date == 2011
replace diff = diff_f`i' if dum_f`i' == 1 & year_date == 2011

replace dum = dum_l`i' if dum_l`i' == 1 & year_date == 2011
replace dum = dum_f`i' if dum_f`i' == 1 & year_date == 2011
}

replace diff = 0 if diff > -th & diff < th & year_date == 2011
summ diff if year_date == 2011, d

*** drop plans that can not identify properly

drop if diff < 0 & year_date == 2011
drop if diff > 0 & year_date == 2011

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** show the fraction of firms using end of year vs 12 month lead/lag interest rate reporting assumptions

summ dum*

*** sort plans

sort id myear

edit id myear dum*


*** use previous value for interst rate reporting assumption
*** reason: sponsors can't choose and cherry pick the lead/lag point in time from period to period

replace dum = dum[_n-1] if id==id[_n-1] & dum ==.
replace dum_0 = dum_0[_n-1] if id==id[_n-1] & dum_0 ==.

forvalues i=1(1)12{
replace dum_l`i' = dum_l`i'[_n-1] if id==id[_n-1] & dum_l`i'==.
replace dum_f`i' = dum_f`i'[_n-1] if id==id[_n-1] & dum_f`i'==.
}

*** make sure you drop the plans in 2012 that could not properly be identified in 2011 and/or did not exist in 2011

drop if dum ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** number of plans in 2012 (final sample for regression)

summ dum* if year_date == 2012

*** compute regulated pre-MAP-21 rate in 2012

gen reg2012_reg_interest_seg1 = reg_interest_seg1 if dum_0 == 1 & year_date == 2012
gen reg2012_reg_interest_seg2 = reg_interest_seg2 if dum_0 == 1 & year_date == 2012
gen reg2012_reg_interest_seg3 = reg_interest_seg3 if dum_0 == 1 & year_date == 2012

forvalues i=1(1)12{
replace reg2012_reg_interest_seg1 = lag`i'_reg_interest_seg1 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg1 = lead`i'_reg_interest_seg1 if dum_f`i'==1 & year_date == 2012

replace reg2012_reg_interest_seg2 = lag`i'_reg_interest_seg2 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg2 = lead`i'_reg_interest_seg2 if dum_f`i'==1 & year_date == 2012

replace reg2012_reg_interest_seg3 = lag`i'_reg_interest_seg3 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg3 = lead`i'_reg_interest_seg3 if dum_f`i'==1 & year_date == 2012
}

**** compute by how much interest rate has changed in 2012

replace diff_seg1 = interest_seg1 - reg2012_reg_interest_seg1 if year_date == 2012
replace diff_seg2 = interest_seg2 - reg2012_reg_interest_seg2 if year_date == 2012
replace diff_seg3 = interest_seg3 - reg2012_reg_interest_seg3 if year_date == 2012

*** now replace "old" diff variable

summ diff if year_date == 2012, d

replace diff = diff_seg1 + diff_seg2 + diff_seg3 if year_date == 2012

summ diff if year_date == 2012, d

gen update = 1 if diff > 0 & year_date == 2012
replace update = 0 if update ==. & year_date == 2012

*** number of plans in 2012

summ update if year_date == 2012

*** compute average increase in interest rates

gen avg_interest_seg = (interest_seg1 + interest_seg2 + interest_seg3)/3 if year_date == 2012

gen avg_reg_interest_seg = (reg2012_reg_interest_seg1 + reg2012_reg_interest_seg2 + reg2012_reg_interest_seg3)/3 if year_date == 2012

gen diff_avg = avg_interest_seg - avg_reg_interest_seg if year_date == 2012

summ diff_avg if update == 1
summ diff_avg if update == 0

*** winsorize main variables

centile relfunding, centile(0.5 99.5)
replace relfunding = r(c_1) if relfunding < r(c_1)
replace relfunding = r(c_2) if relfunding > r(c_2)

centile rel_mand_contrib, centile(0.5 99.5)
replace rel_mand_contrib = r(c_1) if rel_mand_contrib < r(c_1)
replace rel_mand_contrib = r(c_2) if rel_mand_contrib > r(c_2)

centile exc_contrib, centile(0.5 99.5)
replace exc_contrib = r(c_1) if exc_contrib < r(c_1)
replace exc_contrib = r(c_2) if exc_contrib > r(c_2)

centile duration, centile(0.5 99.5)
replace duration = r(c_1) if duration < r(c_1)
replace duration = r(c_2) if duration > r(c_2)

summ D_mand_contrib, d
centile D_mand_contrib, centile(0.5 99.5)
replace D_mand_contrib = r(c_1) if D_mand_contrib < r(c_1)
replace D_mand_contrib = r(c_2) if D_mand_contrib > r(c_2)

summ risky, d

*** summary statistics of main variables

sort id year_date
xtset id year_date

gen lag_relfunding  = l1.relfunding
gen lag_rel_mand_contrib = l1.rel_mand_contrib
gen lag_rel_exc_contrib = l1.rel_exc_contrib

tabstat relfunding lag_relfunding rel_mand_contrib lag_rel_mand_contrib D_mand_contrib rel_exc_contrib lag_rel_exc_contrib, by(update)

tabstat relfunding lag_relfunding rel_mand_contrib lag_rel_mand_contrib D_mand_contrib rel_exc_contrib lag_rel_exc_contrib, by(update) s(med)

*** switching prediction model

gen lag_relfunding_p = lag_relfunding if lag_relfunding > 0
replace lag_relfunding_p = 0 if lag_relfunding_p ==.

gen lag_relfunding_n = lag_relfunding*(-1) if lag_relfunding < 0
replace lag_relfunding_n = 0 if lag_relfunding_n ==.

*** Table 14: 
logistic update lag_relfunding_p lag_relfunding_n if year_date == 2012, r
estimates store logit1

logistic update lag_relfunding_p lag_relfunding_n size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom if year_date == 2012, r
estimates store logit2

estout logit1 logit2, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout logit1 logit2, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estout logit1 logit2, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear
********************************************************************************************************
*** The Form 5500 Raw data were downloaded from the Center for Retirement Research, Boston College
*** The raw data were downloaded for each year and stored as follows raw5500-YEAR-1.dta
*** This code simply appends all individual files into one large file, covering the period 1999 to 2007
********************************************************************************************************

clear all

set memory 10000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC"

use raw5500-2007-1.dta
gen year = 2007
save raw_2007_all.dta, replace

****************

clear 

use raw5500-2006-1.dta
gen year = 2006
save raw_2006_all.dta, replace


****************

clear 

use raw5500-2005-1.dta
gen year = 2005
save raw_2005_all.dta, replace

****************

clear 

use raw5500-2004-1.dta

gen year = 2004
save raw_2004_all.dta, replace

****************

clear 

use raw5500-2003-1.dta


gen year = 2003
save raw_2003_all.dta, replace

****************

clear 

use raw5500-2002-1.dta

gen year = 2002
save raw_2002_all.dta, replace

****************

clear 

use raw5500-2001-1.dta

gen year = 2001
save raw_2001_all.dta, replace

****************

clear 

use raw5500-2000-1.dta


#delimit cr
gen year = 2000
save raw_2000_all.dta, replace

****************

clear 

use raw5500-1999-1.dta

gen year = 1999
save raw_1999_all.dta, replace


**** no inclusion prior to 1999 due to missing actuarial assumptions

***

clear

use raw_2007_all

append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2006_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2005_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2004_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2003_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2002_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2001_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_2000_all.dta"
append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC/raw_1999_all.dta"



save raw5500_all, replace

**** This file merges the different components of the 2011 Submission to the IRS: Form 5500, Schedule H and Schedule SB

clear all


set memory 2000m

*** form 5500

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest"

insheet using F_5500_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save 5500_2011, replace

*** schedule H
clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2011_Latest"

insheet using F_SCH_H_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save H_2011, replace

*** schedule SB

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2011_Latest"

insheet using F_SCH_SB_2011_latest.csv

sort ack_id

duplicates drop ack_id, force

save SB_2011, replace

*** merge datasets

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest"

use 5500_2011


merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2011_Latest/SB_2011"

drop if _merge !=3

drop _merge

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2011_Latest/H_2011"

drop if _merge ==2

drop _merge

gen year = 2011

*** generate ID number of plan

gen str3 PIN = string(spons_dfe_pn, "%03.0f")
gen str9 EIN = string(spons_dfe_ein, "%09.0f")

gen ID = EIN + PIN

sort ID

duplicates drop ID, force

save raw_2011.dta, replace

**** This file merges the different components of the 2012 Submission to the IRS: Form 5500, Schedule H and Schedule SB

clear all

set memory 2000m

*** form 5500

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

insheet using F_5500_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save 5500_2012, replace

*** schedule H
clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2012_Latest"

insheet using F_SCH_H_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save H_2012, replace

*** schedule SB

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2012_Latest"

insheet using F_SCH_SB_2012_latest.csv

sort ack_id

duplicates drop ack_id, force

save SB_2012, replace

*** merge datasets

clear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

use 5500_2012

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule SB/F_SCH_SB_2012_Latest/SB_2012"

drop if _merge !=3

drop _merge

merge 1:1 ack_id using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Schedule H/F_SCH_H_2012_Latest/H_2012"

drop if _merge ==2

drop _merge

gen year = 2012

*** generate ID number of plan

gen str3 PIN = string(spons_dfe_pn, "%03.0f")
gen str9 EIN = string(spons_dfe_ein, "%09.0f")

gen ID = EIN + PIN

sort ID

duplicates drop ID, force

save raw_2012.dta, replace

*********************************************************************************************************************
***** DATA PREPARATION PENSION FUNDS ********************************************************************************
*********************************************************************************************************************
*** This file loads the raw file raw5500_all.dta, performs the main sample cleaning steps and defines most variables
*** which are used for this study
*********************************************************************************************************************

clear all

set memory 2000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/BC"

use raw5500_all

set type double, permanently

*********************************
*** clean dataset from duplicates
*********************************
 
*** generate ID number of plan

gen str3 PIN = string(SPONS_DFE_PN, "%03.0f")
gen str9 EIN = string(SPONS_DFE_EIN, "%09.0f")

gen ID = EIN + PIN

*** generate number of plans

sort ID

egen plans = group(ID)

summ plans
drop plans

*** focus on DB plans only

drop if DC == 1

summ DB

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop multi-employer plans

drop if TYPE_PLAN_ENTITY_IND != 2

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** set time parameter and compute sample

sort ID year

egen id = group(ID)

sort id year

xtset id year

*** drop small plans

gen participants = TOT_PARTCP_BOY_CNT 
drop if participants < 100

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate current-liability variable (RPA)

gen liab = (ACTRL_RPA94_INFO_CURR_LIAB_AMT/1000000)
drop if liab ==.
drop if liab == 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

**** prepare actuarial accrued liabilities
*** background: the accrued liability can be computed using the (a) immediate gain method or (b) the entry age normal method
*** plans thus only report one of the two numbers, but there are few cases/typos where both / no values contain an entry; these cases are dropped

gen dum_gain = 1 if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT !=0
replace dum_gain = 0 if dum_gain ==.

gen dum_age = 1 if ACTRL_ACCR_LIAB_AGE_MTHD_AMT !=0
replace dum_age = 0 if dum_age ==.

summ dum_gain dum_age

*** make sure plans use only one method (only affects few plans)

gen dum_both = dum_gain + dum_age

drop if dum_both !=1
drop dum_both

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** double check that accrued liability is only reported once

summ ACTRL_ACCR_LIAB_GAIN_MTHD_AMT if ACTRL_ACCR_LIAB_AGE_MTHD_AMT ==0
summ ACTRL_ACCR_LIAB_GAIN_MTHD_AMT if ACTRL_ACCR_LIAB_AGE_MTHD_AMT !=0

summ ACTRL_ACCR_LIAB_AGE_MTHD_AMT if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT ==0
summ ACTRL_ACCR_LIAB_AGE_MTHD_AMT if ACTRL_ACCR_LIAB_GAIN_MTHD_AMT !=0

*** generate accrued liability

gen accr_liab = (ACTRL_ACCR_LIAB_GAIN_MTHD_AMT + ACTRL_ACCR_LIAB_AGE_MTHD_AMT)/1000000

drop if accr_liab ==.

drop if accr_liab <= 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate log of liabilities

gen log_AL = log(accr_liab)

gen log_CL = log(liab)

*** generate difference in pension liabilities

gen diff_liab = (liab - accr_liab)/accr_liab
replace diff_liab = diff_liab*100

*** generate asset variable

gen asset = ACTRL_CURR_VALUE_AST_01_AMT/1000000
drop if asset ==.
drop if asset == 0
drop if asset < 0

*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate funding variable

gen funding = asset - liab  

gen relfunding = (funding / liab)
replace relfunding = relfunding*100

*** generate beginning of period FSA variable

gen FSAp = ACTRL_PR_YR_CREDIT_BALANCE_AMT/1000000
replace FSAp = 0 if FSAp <0
replace FSAp = 0 if FSAp ==.

gen FSAn = ACTRL_PR_YR_FNDNG_DEFN_AMT/1000000
replace FSAn = 0 if FSAn <0
replace FSAn = 0 if FSAn ==.

gen FSA = FSAp - FSAn
gen FSA_asset = FSA/asset
replace FSA_asset = FSA_asset*100

*** required cash contributions: MFC, AFR and MPC

gen MPC = ACTRL_TOT_CHARGES_AMT/1000000
gen MPC_asset = MPC/asset
replace MPC_asset= MPC_asset*100

gen MFC =  ACTRL_TOT_CHARGES_AMT/1000000  - ACTRL_ADDNL_FNDNG_PRT2_AMT/1000000 
gen MFC_asset = MFC/asset
replace MFC_asset= MFC_asset*100

gen AFR = ACTRL_ADDNL_FNDNG_PRT2_AMT/1000000
replace AFR = 0 if AFR <0
gen AFR_asset = AFR/asset
replace AFR_asset = AFR_asset*100

*** actual cash contributions

gen tot_contr =  ACTRL_TOT_EMPLR_CONTRIB_AMT/1000000
gen tot_contr_asset = tot_contr/asset
replace tot_contr_asset = tot_contr_asset*100

gen excess = (tot_contr - MPC)/asset

*** generate interest rate variables (in basis points)

** AL interest rate
gen interest = ACTRL_VALUATION_INT_PRE_PRCNT

** CL interest rate
gen interest_RPA = ACTRL_CURR_LIAB_RPA_PRCNT

gen D_interest = (interest - interest_RPA)

drop if D_interest ==.

sort ID
egen plans = group(ID)
summ plans
drop plans

*** use information on (pre-retirement) mortality tables
** comment: we focus on tables for males as they account for a larger fraction of the workforce

gen mortality_m = ACTRL_MORTALITY_MALE_PRE_CODE if ACTRL_MORTALITY_MALE_PRE_CODE != ""

drop if mortality_m == ""

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** check that the retirement mortality table coincides with the pre-retirement table

gen ind = 1 if ACTRL_MORTALITY_MALE_PRE_CODE == ACTRL_MORTALITY_MALE_POST_CODE  
replace ind = 0 if ACTRL_MORTALITY_MALE_PRE_CODE != ACTRL_MORTALITY_MALE_POST_CODE 

*** drop cases where different tables are being used

drop if ind == 0

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*****************************************************************************************************************************************************
*** construct mortality table dummies
*****************************************************************************************************************************************************

quietly: tabulate mortality_m, sort

replace mortality_m = "A" if mortality_m == "9" & year != 2007

gen m_none =  1 if mortality_m == "0" 
replace m_none = 0 if m_none ==.

gen m_1951 = 1 if mortality_m == "1" 
replace m_1951 = 0 if m_1951 ==.

gen m_1971 = 1 if mortality_m == "2" 
replace m_1971 = 0 if m_1971 ==.

gen m_1971b = 1 if mortality_m == "3" 
replace m_1971b = 0 if m_1971b ==.

gen m_1984 = 1 if mortality_m == "4" 
replace m_1984 = 0 if m_1984 ==.

gen m_1983a = 1 if mortality_m == "5" 
replace m_1983a = 0 if m_1983a ==.

gen m_1983b = 1 if mortality_m == "6" 
replace m_1983b = 0 if m_1983b ==.

gen m_1983c = 1 if mortality_m == "7" 
replace m_1983c = 0 if m_1983c ==.

gen m_1983 = m_1983b + m_1983c

gen m_1994 = 1 if mortality_m == "8" 
replace m_1994 = 0 if m_1994 ==.

gen m_2007 = 1 if mortality_m == "9" 
replace m_2007 = 0 if m_2007 ==.

gen m_oth = 1 if mortality_m == "A" 
replace m_oth = 0 if m_oth ==.

gen m_var = 1 - (m_1951 + m_1971 + m_1971b + m_none + m_1984 + m_1983a + m_1983b + m_1983c + m_1994 + m_2007 + m_oth) 

*** drop other tables

drop if m_oth == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop cases where no tables are used

drop if m_none == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** drop variations of tables / we don't know life expectancy

drop if m_var == 1

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

*** average retirement age

gen retmt = ACTRL_WEIGHTED_RTM_AGE

drop if retmt ==. 

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans

summ retmt

*centile retmt, centile(1 99)
*drop if retmt < r(c_1)
*drop if retmt > r(c_2)

drop if retmt < 56
drop if retmt > 65

*** generate number of plans
sort ID
egen plans = group(ID)
summ plans
drop plans


*** create cross-sectional longevity index based on mandated life expectancy
*** note: the numbers come from a separate computation in Excel

*** CL life expectancy assumptions

gen long_GM83 = 23.47488295 if retmt == 56
replace long_GM83  = 22.63127472 if retmt == 57
replace long_GM83  = 21.7940011 if retmt == 58
replace long_GM83  = 20.96353764 if retmt == 59
replace long_GM83  = 20.14078196 if retmt == 60
replace long_GM83  = 19.32693604 if retmt == 61
replace long_GM83  = 18.52341974 if retmt == 62
replace long_GM83  = 17.73196268 if retmt == 63
replace long_GM83  = 16.9544361 if retmt == 64
replace long_GM83  = 16.19286677 if retmt == 65

** in year 2007, master table is RP2000

replace long_GM83  = 24.46744037 if year==2007 & retmt == 56
replace long_GM83  = 23.61820224 if year==2007 & retmt == 57
replace long_GM83  = 22.77138505 if year==2007 & retmt == 58
replace long_GM83  = 21.92948384 if year==2007 & retmt == 59
replace long_GM83  = 21.0948639  if year==2007 & retmt == 60
replace long_GM83  = 20.26918615 if year==2007 & retmt == 61
replace long_GM83  = 19.45328617 if year==2007 & retmt == 62
replace long_GM83  = 18.64809706 if year==2007 & retmt == 63
replace long_GM83  = 17.85457349 if year==2007 & retmt == 64
replace long_GM83  = 17.07357095 if year==2007 & retmt == 65

*** AL life expectancy assumptions

gen long_index_cs  = 20.2357447 if m_1951 == 1 & retmt == 56
replace long_index_cs  = 20.66137352 if m_1984 == 1 & retmt == 56
replace long_index_cs  = 21.40249131 if m_1971 == 1 & retmt == 56
replace long_index_cs  = 23.4105909 if m_1971b == 1 & retmt == 56
replace long_index_cs  = 23.47488295 if m_1983 ==1 & retmt == 56
replace long_index_cs  = 24.11367631 if m_1994 ==1 & retmt == 56
replace long_index_cs  = 24.44261395 if m_1983a ==1 & retmt == 56
replace long_index_cs  = 26.13135926 if m_2007 ==1 & retmt == 56

replace long_index_cs  = 19.46797433 if m_1951 == 1 & retmt == 57
replace long_index_cs  = 19.88724822 if m_1984 == 1 & retmt == 57
replace long_index_cs  = 20.60257435 if m_1971 == 1 & retmt == 57
replace long_index_cs  = 22.62603673 if m_1971b == 1 & retmt == 57
replace long_index_cs  = 22.63127472 if m_1983 ==1 & retmt == 57
replace long_index_cs  = 23.24269593 if m_1994 ==1 & retmt == 57
replace long_index_cs  = 23.61948029 if m_1983a ==1 & retmt == 57
replace long_index_cs  = 25.21051502 if m_2007 ==1 & retmt == 57

replace long_index_cs  = 18.71037249 if m_1951 == 1 & retmt == 58
replace long_index_cs  = 19.12600299 if m_1984 == 1 & retmt == 58
replace long_index_cs  = 19.81150101 if m_1971 == 1 & retmt == 58
replace long_index_cs  = 21.85112027 if m_1971b == 1 & retmt == 58
replace long_index_cs  = 21.7940011 if m_1983 ==1 & retmt == 58
replace long_index_cs  = 22.38301742 if m_1994 ==1 & retmt == 58
replace long_index_cs  = 22.80175413 if m_1983a ==1 & retmt == 58
replace long_index_cs  = 24.2981478 if m_2007 ==1 & retmt == 58

replace long_index_cs  = 17.96261318 if m_1951 == 1 & retmt == 59
replace long_index_cs  = 18.37697355 if m_1984 == 1 & retmt == 59
replace long_index_cs  = 19.02960336 if m_1971 == 1 & retmt == 59
replace long_index_cs  = 21.08551382 if m_1971b == 1 & retmt == 59
replace long_index_cs  = 20.96353764 if m_1983 ==1 & retmt == 59
replace long_index_cs  = 21.53567408 if m_1994 ==1 & retmt == 59
replace long_index_cs  = 21.98902271 if m_1983a ==1 & retmt == 59
replace long_index_cs  = 23.39548579 if m_2007 ==1 & retmt == 59

replace long_index_cs  = 17.22466564 if m_1951 == 1 & retmt == 60
replace long_index_cs  = 17.64096693 if m_1984 == 1 & retmt == 60
replace long_index_cs  = 18.25925066 if m_1971 == 1 & retmt == 60
replace long_index_cs  = 20.32889788 if m_1971b == 1 & retmt == 60
replace long_index_cs  = 20.14078196 if m_1983 ==1 & retmt == 60
replace long_index_cs  = 20.70110157 if m_1994 ==1 & retmt == 60
replace long_index_cs  = 21.18135726 if m_1983a ==1 & retmt == 60
replace long_index_cs  = 22.50192601 if m_2007 ==1 & retmt == 60

replace long_index_cs  = 16.49682881 if m_1951 == 1 & retmt == 61
replace long_index_cs  = 16.91887069 if m_1984 == 1 & retmt == 61
replace long_index_cs  = 17.50197812 if m_1971 == 1 & retmt == 61
replace long_index_cs  = 19.58099448 if m_1971b == 1 & retmt == 61
replace long_index_cs  = 19.32693604 if m_1983 ==1 & retmt == 61
replace long_index_cs  = 19.88016991 if m_1994 ==1 & retmt == 61
replace long_index_cs  = 20.37945933 if m_1983a ==1 & retmt == 61
replace long_index_cs  = 21.61902471 if m_2007 ==1 & retmt == 61

replace long_index_cs  = 15.77983756 if m_1951 == 1 & retmt == 62
replace long_index_cs  = 16.2116407 if m_1984 == 1 & retmt == 62
replace long_index_cs  = 16.75840955 if m_1971 == 1 & retmt == 62
replace long_index_cs  = 18.84157387 if m_1971b == 1 & retmt == 62
replace long_index_cs  = 18.52341974 if m_1983 ==1 & retmt == 62
replace long_index_cs  = 19.07414639 if m_1994 ==1 & retmt == 62
replace long_index_cs  = 19.58450155 if m_1983a ==1 & retmt == 62
replace long_index_cs  = 20.75017828 if m_2007 ==1 & retmt == 62

replace long_index_cs  = 15.07485945 if m_1951 == 1 & retmt == 63
replace long_index_cs  = 15.52032294 if m_1984 == 1 & retmt == 63
replace long_index_cs  = 16.02853317 if m_1971 == 1 & retmt == 63
replace long_index_cs  = 18.11051616 if m_1971b == 1 & retmt == 63
replace long_index_cs  = 17.73196268 if m_1983 ==1 & retmt == 63
replace long_index_cs  = 18.28456023 if m_1994 ==1 & retmt == 63
replace long_index_cs  = 18.79806325 if m_1983a ==1 & retmt == 63
replace long_index_cs  = 19.89495945 if m_2007 ==1 & retmt == 63

replace long_index_cs  = 14.38357708 if m_1951 == 1 & retmt == 64
replace long_index_cs  = 14.84542349 if m_1984 == 1 & retmt == 64
replace long_index_cs  = 15.3125842 if m_1971 == 1 & retmt == 64
replace long_index_cs  = 17.38786026 if m_1971b == 1 & retmt == 64
replace long_index_cs  = 16.9544361 if m_1983 ==1 & retmt == 64
replace long_index_cs  = 17.51291706 if m_1994 ==1 & retmt == 64
replace long_index_cs  = 18.02193238 if m_1983a ==1 & retmt == 64
replace long_index_cs  = 19.05740437 if m_2007 ==1 & retmt == 64

replace long_index_cs  = 13.70814164 if m_1951 == 1 & retmt == 65
replace long_index_cs  = 14.18809734 if m_1984 == 1 & retmt == 65
replace long_index_cs  = 14.61210238 if m_1971 == 1 & retmt == 65
replace long_index_cs  = 16.67391253 if m_1971b == 1 & retmt == 65
replace long_index_cs  = 16.19286677 if m_1983 ==1 & retmt == 65
replace long_index_cs  = 16.76003012 if m_1994 ==1 & retmt == 65
replace long_index_cs  = 17.25782346 if m_1983a ==1 & retmt == 65
replace long_index_cs  = 18.23356459 if m_2007 ==1 & retmt == 65

*** compute difference in life expectancy

gen LE = (long_index_cs -long_GM83)

**** create industry dummmies

tostring BUSINESS_CODE, generate(NAICS)

gen agr = 1 if substr(NAICS, 1,2) == "11"
replace agr = 0 if agr ==.

gen min = 1 if substr(NAICS, 1,2) == "21"
replace min = 0 if min ==.

gen util = 1 if substr(NAICS, 1,2) == "22"
replace util = 0 if util ==.

gen cstrc = 1 if substr(NAICS, 1,2) == "23"
replace cstrc = 0 if cstrc ==.

gen man = 1 if substr(NAICS, 1,2) == "31"
replace man = 1 if substr(NAICS, 1,2) == "32"
replace man = 1 if substr(NAICS, 1,2) == "33"
replace man = 0 if man ==.

gen whle = 1 if substr(NAICS, 1,2) == "42"
replace whle = 0 if whle ==.

gen retl = 1 if substr(NAICS, 1,2) == "44"
replace retl = 1 if substr(NAICS, 1,2) == "45"
replace retl = 0 if retl ==.

gen trans = 1 if substr(NAICS, 1,2) == "48"
replace trans = 1 if substr(NAICS, 1,2) == "49"
replace trans = 0 if trans ==.

gen inf = 1 if substr(NAICS, 1,2) == "51"
replace inf = 0 if inf ==.

gen fin = 1 if substr(NAICS, 1,2) == "52"
replace fin = 0 if fin ==.

gen real = 1 if substr(NAICS, 1,2) == "53"
replace real = 0 if real ==.

gen prof = 1 if substr(NAICS, 1,2) == "54"
replace prof = 0 if prof ==.

gen hldg = 1 if substr(NAICS, 1,2) == "55"
replace hldg = 0 if hldg ==.

gen admin = 1 if substr(NAICS, 1,2) == "56"
replace admin = 0 if admin ==.

gen edu = 1 if substr(NAICS, 1,2) == "61"
replace edu = 0 if edu ==.

gen hlth = 1 if substr(NAICS, 1,2) == "62"
replace hlth = 0 if hlth ==.

gen arts = 1 if substr(NAICS, 1,2) == "71"
replace arts = 0 if arts ==.

gen accom = 1 if substr(NAICS, 1,2) == "72"
replace accom = 0 if accom ==.

gen oth = 1 if substr(NAICS, 1,2) == "81"
replace oth = 1 if substr(NAICS, 1,2) == "92"
replace oth = 0 if oth ==.

gen test = agr + min + util + cstrc + man + whle + retl + trans + inf + fin + real + prof + hldg + admin + edu + hlth + arts + accom + oth

summ test if test == 0

*** industry classification: visual inspection suggests that if test == 0, then missing or unclassified numbers

gen industry = "agr" if agr ==1
replace industry = "min" if min == 1
replace industry = "util" if util == 1
replace industry = "cstrc" if cstrc == 1
replace industry = "man" if man == 1
replace industry = "whle" if whle == 1
replace industry = "retl" if retl == 1
replace industry = "trans" if trans == 1
replace industry = "inf" if inf == 1
replace industry = "fin" if fin == 1
replace industry = "real" if real == 1
replace industry = "prof" if prof == 1
replace industry = "hldg" if hldg == 1
replace industry = "admin" if admin == 1
replace industry = "edu" if edu == 1
replace industry = "hlth" if hlth == 1
replace industry = "arts" if arts == 1
replace industry = "accom" if accom == 1
replace industry = "oth" if oth == 1

*** size

gen size = log(asset) 

*** compute "duration" proxy
** intuition: if none of the current plan participants is in retirement, the measure is 1 ( = long term promise)
** intuition ctd: if all of the current plan participants are already in retirement, the measure is 0 ( = short term promise)

replace RTD_SEP_PARTCP_RCVG_CNT= 0 if RTD_SEP_PARTCP_RCVG_CNT ==.
replace BENEF_RCVG_BNFT_CNT = 0 if BENEF_RCVG_BNFT_CNT ==.

gen part_ret = RTD_SEP_PARTCP_RCVG_CNT + BENEF_RCVG_BNFT_CNT

gen duration = (1 - part_ret/participants)
replace duration = duration*100

*** active participants

gen part_act = participants - part_ret

gen rel_part_act = (part_act/asset)
replace rel_part_act = rel_part_act*100

*** time dummies

sort year
quietly: tabulate year, gen(d)

*** generate investment variables

gen cash = NON_INT_BEAR_CASH_EOY_AMT
replace cash = 0 if cash ==.
 
gen cash_inv = INT_BEAR_CASH_EOY_AMT
replace cash_inv = 0 if cash_inv ==.

gen AR = EMPLR_CONTRIB_EOY_AMT + PARTCP_CONTRIB_EOY_AMT + OTHER_RECEIVABLE_EOY_AMT
replace AR = 0 if AR ==.

gen US_treas = GOVG_SEC_EOY_AMT
replace US_treas = 0 if US_treas ==.

gen debt_corp = CORP_DEBT_PREFERRED_EOY_AMT + CORP_DEBT_OTHER_EOY_AMT
replace debt_corp = 0 if debt_corp ==.

gen equity = PREF_STOCK_EOY_AMT + COMMON_STOCK_EOY_AMT
replace equity = 0 if equity ==.

gen JV = JOINT_VENTURE_EOY_AMT
replace JV = 0 if JV ==.

gen RE = REAL_ESTATE_EOY_AMT
replace RE = 0 if RE ==.

gen loans = OTHER_LOANS_EOY_AMT + PARTCP_LOANS_EOY_AMT
replace loans = 0 if loans ==.

gen com_trust = INT_COMMON_TR_EOY_AMT 
replace com_trust = 0 if com_trust ==.

gen pool_trust = INT_POOL_SEP_ACCT_EOY_AMT 
replace pool_trust = 0 if pool_trust ==.

gen master_trust = INT_MASTER_TR_EOY_AMT
replace master_trust = 0 if master_trust ==.

gen inv = INT_103_12_INVST_EOY_AMT
replace inv = 0 if inv ==.

gen funds = INT_REG_INVST_CO_EOY_AMT
replace funds = 0 if funds ==.

gen insurance = INS_CO_GEN_ACCT_EOY_AMT
replace insurance = 0 if insurance ==.

gen other = OTH_INVST_EOY_AMT
replace other = 0 if other ==.

gen employer = EMPLR_SEC_EOY_AMT + EMPLR_PROP_EOY_AMT
replace employer = 0 if employer ==.

gen buildings = BLDGS_USED_EOY_AMT
replace buildings = 0 if buildings ==.

gen impl_TA = cash + cash_inv + AR + US_treas + debt_corp + equity + JV + RE + loans +  com_trust +  pool_trust + master_trust + inv + funds + insurance + other + employer + buildings

*** drop negative values 

drop if cash < 0
drop if cash_inv < 0
drop if AR < 0
drop if US_treas < 0
drop if debt_corp < 0
drop if equity < 0
drop if JV < 0
drop if RE < 0
drop if loans < 0
drop if com_trust < 0
drop if pool_trust < 0
drop if master_trust < 0
drop if inv < 0
drop if funds < 0
drop if insurance < 0
drop if other < 0
drop if employer < 0
drop if buildings < 0


*** generate number of plans

sort ID
egen plans = group(ID)
summ plans
drop plans


***

gen rel_cash = cash/impl_TA
gen rel_cash_inv = cash_inv/impl_TA
gen rel_AR = AR/impl_TA
gen rel_US_treas = US_treas/impl_TA
gen rel_debt_corp = debt_corp/impl_TA
gen rel_equity = equity/impl_TA
gen rel_JV = JV/impl_TA
gen rel_RE = RE/impl_TA
gen rel_loans = loans/impl_TA
gen rel_com_trust = com_trust/impl_TA
gen rel_master_trust = master_trust/impl_TA
gen rel_pool_trust = pool_trust/impl_TA
gen rel_inv = inv/impl_TA
gen rel_funds = funds/impl_TA
gen rel_insurance = insurance/impl_TA
gen rel_other = other/impl_TA
gen rel_employer = employer/impl_TA
gen rel_buildings = buildings/impl_TA

*** define risky assets

gen risky = 1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp
replace risky = risky*100

drop if risky ==.

sort ID
egen plans = group(ID)
summ plans
drop plans

gen fyear = year

**** winsorize data (all variables)

centile relfunding, centile(0.5 99.5)
replace relfunding = r(c_1) if relfunding < r(c_1)
replace relfunding = r(c_2) if relfunding > r(c_2)

centile diff_liab, centile(.5 99.5)
replace diff_liab = r(c_1) if diff_liab < r(c_1)
replace diff_liab = r(c_2) if diff_liab > r(c_2)

centile D_interest, centile(.5 99.5)
replace D_interest = r(c_1) if D_interest < r(c_1)
replace D_interest = r(c_2) if D_interest > r(c_2)

centile interest, centile(.5 99.5)
replace interest = r(c_1) if interest < r(c_1)
replace interest = r(c_2) if interest > r(c_2)

centile interest_RPA, centile(0.5 99.5)
replace interest_RPA = r(c_1) if interest_RPA < r(c_1)
replace interest_RPA = r(c_2) if interest_RPA > r(c_2)

centile duration, centile(0.5 99.5)
replace duration = r(c_1) if duration < r(c_1)
replace duration = r(c_2) if duration > r(c_2)

centile size, centile(0.5 99.5)
replace size = r(c_1) if size < r(c_1)
replace size = r(c_2) if size > r(c_2)

centile rel_part_act, centile(0.5 99.5)
replace rel_part_act = r(c_1) if rel_part_act < r(c_1)
replace rel_part_act = r(c_2) if rel_part_act > r(c_2)

centile MFC_asset, centile(0.5 99.5)
replace MFC_asset = r(c_1) if MFC_asset < r(c_1) & MFC_asset !=.
replace MFC_asset = r(c_2) if MFC_asset > r(c_2) & MFC_asset !=.

centile AFR_asset, centile(0.5 99.5)
replace AFR_asset = r(c_1) if AFR_asset < r(c_1) & AFR_asset !=.
replace AFR_asset = r(c_2) if AFR_asset > r(c_2) & AFR_asset !=.

centile MPC_asset, centile(0.5 99.5)
replace MPC_asset = r(c_1) if MPC_asset < r(c_1) & MPC_asset !=.
replace MPC_asset = r(c_2) if MPC_asset > r(c_2) & MPC_asset !=.

centile FSA_asset, centile(0.5 99.5)
replace FSA_asset = r(c_1) if FSA_asset < r(c_1) & FSA_asset !=.
replace FSA_asset = r(c_2) if FSA_asset > r(c_2) & FSA_asset !=.

centile tot_contr_asset, centile(0.5 99.5)
replace tot_contr_asset = r(c_1) if tot_contr_asset < r(c_1) & tot_contr_asset !=.
replace tot_contr_asset = r(c_2) if tot_contr_asset > r(c_2) & tot_contr_asset !=.

centile excess, centile(0.5 99.5)
replace excess = r(c_1) if excess < r(c_1)
replace excess = r(c_2) if excess > r(c_2)


*** generate number of plans
sort id

egen plans = group(id)

summ plans

*** make ready for Compustat merge

summ fyear
sort EIN fyear

*** define manipulation

gen manip = 1 if diff_liab > 0
replace manip = 0 if manip == .


cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save longevity, replace

***************** end of code



clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** number of plans

summ plans

sort id year
gen count = 1
replace count = count[_n-1] + 1 if id == id[_n-1]

gen ncount = count
replace ncount =. if ncount[_n+1] !=. & id == id[_n+1]

edit id year count ncount

*** average and medium number of observations per plan

summ ncount,d

drop count ncount

** generate number of plans each year

sort year
by year: egen obs = count(id)

*** Table 3, Panel A

tabstat accr_liab liab diff_liab asset relfunding interest interest_RPA D_interest long_index_cs long_GM83 LE size duration risky obs, by(year)

*** statistics pension liability manipulation

summ diff_liab, d

summ diff_liab if diff_liab >0
gen N = r(N)
summ diff_liab

display N/r(N)

*** Figure 1

histogram  diff_liab, fraction title("") xtitle("Pension liability gap") ytitle("Fraction of the sample") scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffliab.pdf", as(pdf) preview(off) replace

*** Figure 3

histogram  D_interest, fraction title("") xtitle("Excess discount rate assumptions") ytitle("Fraction of the sample") scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffint.pdf", as(pdf) preview(off) replace


summ diff_liab D_interest LE, d

summ diff_liab D_interest LE if diff_liab < 0, d

summ diff_liab D_interest LE if diff_liab > 0, d

summ LE if LE < 0

*** Figure 2

centile relfunding, centile(1 99)
gen th1 = r(c_1)
gen th2 = r(c_2)

summ relfunding, d

lpoly diff_liab relfunding if relfunding > th1 & relfunding < th2, kernel(epan) ci noscatter bw(10) title("") xtitle("Funding Status") ytitle("Pension liability gap") xlabel(-50(25)150) xmtick(-50(12.5)150) scale(0.6) graphregion(color(white))
graph export "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Paper/JAR/RR2/Fig_diffliab_Kernel.pdf", as(pdf) preview(off) replace


*** Table 4

reg diff_liab relfunding, r
estimates store OLS1

reg diff_liab relfunding size duration risky, r
estimates store OLS2

reg diff_liab relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liab relfunding, fe
estimates store FE1

xtscc diff_liab relfunding size duration risky, fe
estimates store FE2

xtscc diff_liab relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** changes in excess interest-rates

sort id year

gen ch_D_interest = D_interest - l1.D_interest

gen dum_ch_D_int_p = 1 if ch_D_interest > 0 & ch_D_interest !=.
replace dum_ch_D_int_p = 0 if dum_ch_D_int_p ==.

gen dum_ch_D_int_n = 1 if ch_D_interest < 0 & ch_D_interest !=.
replace dum_ch_D_int_n = 0 if dum_ch_D_int_n ==.

gen dum_ch_D_int_u = 1 if ch_D_interest == 0 & ch_D_interest !=.
replace dum_ch_D_int_u = 0 if dum_ch_D_int_u ==.

gen dum_first = 1 if ch_D_interest ==.
replace dum_first = 0 if dum_first ==.

*** change in individual interest rates

gen ch_interest = interest - l1.interest

gen ch_interest_RPA = interest_RPA - l1.interest_RPA

**** yearly number of changes in Delta-interest raates

sort year
by year: egen tot_int_p = sum(dum_ch_D_int_p)
by year: egen tot_int_n = sum(dum_ch_D_int_n)
by year: egen tot_int_u = sum(dum_ch_D_int_u)
by year: egen tot_count = count(dum_ch_D_int_p)

by year: egen tot_first = sum(dum_first)

gen fraction_incr = tot_int_p/tot_count*100
gen fraction_decr = tot_int_n/tot_count*100

*** Table 5, Panel A

tabstat ch_D_interest tot_int_p tot_int_u tot_int_n tot_count fraction_incr fraction_decr tot_first, by(year)

*** changes in excess life expectancy assumptions

sort id year

gen ch_LE = LE - l1.LE

gen dum_ch_LE_p = 1 if ch_LE > 0 & ch_LE !=.
replace dum_ch_LE_p = 0 if dum_ch_LE_p ==.

gen dum_ch_LE_n = 1 if ch_LE < 0 & ch_LE !=.
replace dum_ch_LE_n = 0 if dum_ch_LE_n ==.

gen dum_ch_LE_u = 1 if ch_LE == 0 & ch_LE !=.
replace dum_ch_LE_u = 0 if dum_ch_LE_u ==.

sort year
by year: egen tot_LE_p = sum(dum_ch_LE_p)
by year: egen tot_LE_n = sum(dum_ch_LE_n)
by year: egen tot_LE_u = sum(dum_ch_LE_u)

gen fraction_incr_LE = tot_LE_p/tot_count*100
gen fraction_decr_LE = tot_LE_n/tot_count*100

*** Table 5, Panel B

tabstat ch_LE tot_LE_p tot_LE_u tot_LE_n tot_count fraction_incr_LE fraction_decr_LE, by(year)

*** generate positive and negative funding variable
*** note: we use absolute value of underfunding

gen p_relfunding = relfunding if relfunding >=0
replace p_relfunding = 0 if p_relfunding ==.

gen n_relfunding = relfunding*(-1) if relfunding < 0
replace n_relfunding = 0 if n_relfunding ==.

*****************************************************
*** pooled evidence: discount rate assumptions
*****************************************************

*** Table 6

reg D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

** Robustness: interest as LHS variable (Online Appendix Table 1)


reg interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*******************************************************
*** cross-sectional evdience: discount rate assumptions
*******************************************************

*** Online Appendix Table 2

fm D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm1

fm D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm2

fm interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm3

fm interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth, byfm(year)
estimates store fm4

estout fm*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout fm*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*******************************************************
*** time-series evdience: discount rate assumptions
*******************************************************

sort id year

*** change in funding

gen ch_relfunding = relfunding - l1.relfunding
gen ch_p_relfunding = p_relfunding - l1.p_relfunding
gen ch_n_relfunding = n_relfunding - l1.n_relfunding

*** Online Appendix Table 3

reg ch_D_interest ch_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg ch_D_interest ch_p_relfunding ch_n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

reg ch_interest ch_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg3

reg ch_interest ch_p_relfunding ch_n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*****************************************************
*** pooled evidence: LE assumptions
*****************************************************

gen dum_neg = 1 if LE < 0
replace dum_neg = 0 if dum_neg ==.

*** Table 7

logit dum_neg relfunding, vce(robust) 
estimates store reg1

logit dum_neg relfunding size duration risky, vce(robust)
estimates store reg2

logit dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** Untabulated robustness check: LE choice before 2007

drop plans
sort ID
egen plans = group(ID) if year < 2007
summ plans
drop plans

logistic dum_neg relfunding if year < 2007, vce(robust) 
estimates store reg1

logistic dum_neg relfunding size duration risky if year < 2007, vce(robust)
estimates store reg2

logistic dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg3

logistic dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg4

logistic dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 if year < 2007, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 


*****************************************************************************
*** Untabulated robustness check: impact of frozen, terminated or floor plans
*****************************************************************************

sort TYPE_PENSION_BNFT_CODE

gen entry1 = substr(TYPE_PENSION_BNFT_CODE,1,2)
gen entry2 = substr(TYPE_PENSION_BNFT_CODE,3,2)
gen entry3 = substr(TYPE_PENSION_BNFT_CODE,5,2)
gen entry4 = substr(TYPE_PENSION_BNFT_CODE,7,2)
gen entry5 = substr(TYPE_PENSION_BNFT_CODE,9,2)
gen entry6 = substr(TYPE_PENSION_BNFT_CODE,11,2)
gen entry7 = substr(TYPE_PENSION_BNFT_CODE,13,2)

*** generate indicator variable for being a frozen plan

gen frozen = 1 if entry1 =="1I"
forvalues i=2(1)7{
replace frozen = 1 if entry`i' == "1I"
}

replace frozen = 0 if frozen ==.

*** generate indicator variable for being a terminated plan

gen terminated = 1 if entry1 =="1H"
forvalues i=2(1)7{
replace terminated = 1 if entry`i' == "1H"
}

replace terminated = 0 if terminated ==.

*** generate indicator variable for being a floor offset plan

gen floor = 1 if entry1 =="1D"
forvalues i=2(1)7{
replace floor = 1 if entry`i' == "1D"
}

replace floor = 0 if floor ==.


*** fraction of those pension plans and corresponding liability gap

summ frozen terminated floor

summ diff_liab if frozen == 1
summ diff_liab if terminated == 1
summ diff_liab if floor == 1


*** focus on the first observation a plan becomes frozen, terminated or receives a floor

sort id year
gen first_frozen = frozen - frozen[_n-1] if id==id[_n-1]
replace first_frozen = 0 if first_frozen ==-1

gen first_floor = floor - floor[_n-1] if id==id[_n-1]
replace first_floor = 0 if first_floor ==-1

gen first_terminated = terminated - terminated[_n-1] if id==id[_n-1]
replace first_terminated = 0 if first_terminated ==-1

gen lag_diff_liab = l1.diff_liab

logistic first_frozen lag_diff_liab size duration  , vce(robust)
estimates store reg1

logistic first_floor lag_diff_liab size duration risky  , vce(robust)
estimates store reg2

logistic first_terminated lag_diff_liab size duration risky , vce(robust)
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

**
drop if frozen == 1
drop if terminated == 1
drop if floor == 1

*** Table 4 w/o frozen plans

reg diff_liab relfunding, r
estimates store OLS1

reg diff_liab relfunding size duration risky, r
estimates store OLS2

reg diff_liab relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liab relfunding, fe
estimates store FE1

xtscc diff_liab relfunding size duration risky, fe
estimates store FE2

xtscc diff_liab relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Table 6 w/o frozen plans

reg D_interest relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfunding n_relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*** Table 7 w/o frozen plans

logit dum_neg relfunding, vce(robust) 
estimates store reg1

logit dum_neg relfunding size duration risky, vce(robust)
estimates store reg2

logit dum_neg relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfunding n_relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 


********************************************************************************
*** show summary statistics (Table 8, Panel A) for all plan-years
********************************************************************************
clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** compute trailing number of observations per pension plan 

sort id year

by id: gen num = _n

*** compute number of cross-sectional observations for each "number" num

sort num

by num: egen obs_num = count(num)

*** compute total observations by pension plan

sort id num

by id: egen max_num = max(num)


*** compute total number of years in which plans use regulatory leeway

sort id num

by id: gen sum_manip = sum(manip)

*** compute maximum number of manipulative years by pension plan

gen max_manip = sum_manip
replace max_manip = . if num != max_num

sort id max_manip
replace max_manip = max_manip[_n-1] if id==id[_n-1] & max_manip ==.

*** double check that code is correct (yes, it is)

sort id year

edit id year num max_num sum_manip manip max_manip


*** compute number of plans for each max_manip
*** need to start the code at 1 (instead of zero)

sort max_manip id
replace max_manip = max_manip +1
summ max_manip

forvalues i=1(1)10{
egen manip_plans = group(id) if max_manip == `i'
egen m_plans_`i' = max(manip_plans) if max_manip == `i'
replace m_plans_`i' = 0 if m_plans_`i' ==.
drop manip_plans
}

*** double check that code is correct (yes, it is)

summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip == 1
summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip  == 10

gen m_plans = m_plans_1 + m_plans_2 + m_plans_3 + m_plans_4 + m_plans_5 + m_plans_6 + m_plans_7 + m_plans_8 + m_plans_9 + m_plans_10
drop m_plans_*

*** generate number of plan-years per max_manip

sort max_manip id

by max_manip: egen sum_mmanip = count(manip)

*** double check that code is correct (yes, it is)

edit max_manip id m_plans sum_mmanip

*** Table 8, Panel A

tabstat sum_mmanip m_plans relfunding tot_contr_asset MFC_asset AFR_asset, by(max_manip)

*********************************************************************************************************
*** repeat the code (Table 8, Panel B) for underfunded plan-years only
*** focus only on underfunded plan years for subsequent analysis (only then, contributions are mandatory)
*********************************************************************************************************

clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity

*** compute trailing number of observations per pension plan 

sort id year

by id: gen num = _n

*** compute number of cross-sectional observations for each "number" num

sort num

by num: egen obs_num = count(num)

*** compute total observations by pension plan

sort id num

by id: egen max_num = max(num)


*** compute total number of years in which plans use regulatory leeway

sort id num

by id: gen sum_manip = sum(manip)

*** compute maximum number of manipulative years by pension plan

gen max_manip = sum_manip
replace max_manip = . if num != max_num

sort id max_manip
replace max_manip = max_manip[_n-1] if id==id[_n-1] & max_manip ==.

*** double check that code is correct (yes, it is)

sort id year

edit id year num max_num sum_manip manip max_manip


*** drop underfunded plan years

drop if relfunding > 0

*** compute number of plans for each max_manip
*** need to start the code at 1 (instead of zero)

sort max_manip id
replace max_manip = max_manip +1
summ max_manip

forvalues i=1(1)10{
egen manip_plans = group(id) if max_manip == `i'
egen m_plans_`i' = max(manip_plans) if max_manip == `i'
replace m_plans_`i' = 0 if m_plans_`i' ==.
drop manip_plans
}

*** double check that code is correct (yes, it is)

summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip == 1
summ m_plans_1 m_plans_2 m_plans_3 m_plans_4 m_plans_5 m_plans_6 m_plans_7 m_plans_8 m_plans_9 m_plans_10 if max_manip  == 10

gen m_plans = m_plans_1 + m_plans_2 + m_plans_3 + m_plans_4 + m_plans_5 + m_plans_6 + m_plans_7 + m_plans_8 + m_plans_9 + m_plans_10
drop m_plans_*

*** generate number of plan-years per max_manip

sort max_manip id

by max_manip: egen sum_mmanip = count(manip)

*** double check that code is correct (yes, it is)

edit max_manip id m_plans sum_mmanip

*** Table 8, Panel B

tabstat sum_mmanip m_plans relfunding tot_contr_asset MFC_asset AFR_asset , by(max_manip)

*** multivariate analysis, total cash contributions
*** Table 9, Panel A

reg tot_contr_asset manip, r
estimates store reg1

reg tot_contr_asset relfunding manip, r
estimates store reg2

reg tot_contr_asset relfunding manip size duration risky , r
estimates store reg3

reg tot_contr_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg tot_contr_asset relfunding manip size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

xtscc tot_contr_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

*** multivariate analysis, mandatory funding contribution
*** Table 9, Panel B

reg MFC_asset manip, r
estimates store reg1

reg MFC_asset manip relfunding, r
estimates store reg2

reg MFC_asset manip relfunding size duration risky , r
estimates store reg3

reg MFC_asset manip relfunding size duration risky d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg MFC_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

xtscc MFC_asset relfunding manip size duration risky d2 d3 d4 d5 d6 d7 d8 d9, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** Robustness: multivariate analysis which conditions on the frequency of using regulatory leeway, total cash contributions
*** Online Appendix Table 4, Panel A

*** account for the fact that max_manip is set to start at 1 (not zero)
*** max_num needs to be consistent with it

replace max_num = max_num + 1

summ max_num max_manip

forvalues i=1(1)9{
summ manip max_num if max_num > `i' & max_manip ==`i' 
}

forvalues i=1(1)9{
reg tot_contr_asset manip relfunding agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i' , r

estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

***

forvalues i=1(1)9{
reg MFC_asset manip relfunding agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i', r
estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

*** untabulated results including control variables

forvalues i=1(1)9{
reg tot_contr_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i' , r

estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear

***

forvalues i=1(1)9{
reg MFC_asset manip relfunding size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9 if max_manip == `i' & max_num > `i', r
estimates store reg`i'
}

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear



*******************************************************************************************************************************************************
***** PREPARE COMPUSTAT FILE USING EIN AND FYEAR AS MATCHING VARIABLE FOR MERGE
*******************************************************************************************************************************************************

clear all

set memory 1000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Compustat"

*** load raw data

use pension

*** generate 3-digit SIC code

gen sic3 = substr(sic,1,3)

*** make sic and gvkey available as numbers

gen sic1 = real(sic)
drop sic
gen sic = sic1
drop sic1

gen gvkey1 = real(gvkey)
drop gvkey
gen gvkey = gvkey1
drop gvkey1

*** use 1998 value to compute acrual values, sales growth and industry sales growth
*** otherwise we lose the entire first year of the sample (1999)

sort gvkey datadate

*** accrual components

gen COA = (act - che)
gen lagCOA = COA[_n-1] if gvkey==gvkey[_n-1]

gen COL = (lct - dlc)
gen lagCOL = COL[_n-1] if gvkey==gvkey[_n-1]

gen lagat = at[_n-1] if gvkey==gvkey[_n-1]

** sales growth

replace sale = 0 if sale <0
gen gs = (sale - sale[_n-1])/sale[_n-1] if gvkey == gvkey[_n-1]

*** generate 3 digit industry sales growth variable 

sort sic3 fyear
egen industry3_fyear = group(sic3 fyear)

sort industry3_fyear
by industry3_fyear: egen sale_ind = sum(sale)

sort sic3 fyear
gen ISG = (sale_ind - sale_ind[_n-1])/sale_ind[_n-1] if fyear==fyear[_n-1]+1 & sic3==sic3[_n-1]
replace ISG = -99 if ISG ==. 

edit sic3 fyear ISG sale_ind

** replace "-99" values with actual growth number
sort industry3_fyear
by industry3_fyear: egen ISG1 = max(ISG)

*** double check this makes sense (yes, it does)

edit sic3 fyear ISG sale_ind ISG1

drop ISG
rename ISG1 ISG

*** make sure we have same sample period

drop if fyear < 1999
drop if fyear > 2007

***
sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** create EIN number (there is a "-" in the compustat string)
*** and make sure EIN number is available

gen ein1 = substr(ein, 1, 2)
gen ein2 = substr(ein, 4, 7)
gen EIN = ein1 + ein2

drop if EIN == ""

***
sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

**** drop financials, utilities and government entities

drop if sic > 5999 & sic < 7000
drop if sic > 4899 & sic < 5000

**

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** double check that one EIN does not appear several times within a fiscal year

sort EIN fyear datadate at tic

egen id = group(EIN fyear)

sort id datadate

*** check wether id changes

gen idL = id - id[_n-1]

gen idL1 = id[_n+1]-id

*** drop observations in case it id stays constant (only retain the latest info within a fiscal year)

drop if idL1 ==0

drop id idL idL1

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

***********************************************************************************
*** merge with CCM pension accounting data
*** note, that pension accounting data is used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

***
sort gvkey fyear datadate at tic
egen id = group(gvkey fyear)

sort id datadate

*** check wether id changes

gen idL = id - id[_n-1]

gen idL1 = id[_n+1]-id

*** drop observations in case it id stays constant (only keep latest information)

drop if idL1 ==0

drop id idL idL1

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** actual merge with pension FASB data

sort gvkey datadate

merge 1:1 gvkey datadate using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Compustat/pension_robust.dta"

*** drop non merged data from pension accounting file
drop if _merge == 2
rename _merge _merge_FASB

***********************************************************************************
*** merge with Graham's simulated tax rates
*** note, that simulated tax rates are used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

sort gvkey fyear

merge 1:1 gvkey fyear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Tax rates/taxrates.dta"

*** drop non merged data from Graham's file
drop if _merge == 2
rename _merge _merge_tax

***********************************************************************************
*** merge with Gompers corporate governance index
*** note, that simulated tax rates are used as a robustness check, therefore no
*** negative impact on sample size
***********************************************************************************

sort gvkey fyear tic

merge 1:1 gvkey fyear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Gompers/Gindex.dta"

drop _merge

***********************************************************************************
*** prepare the main financial statement variables 
***********************************************************************************

sort gvkey fyear

xtset gvkey fyear

** $ variables

gen C = che

gen D = dlc + dltt

gen EMV = prcc_f*csho

gen MV = EMV + D

*** financial ratios
  
gen Q = MV/at

gen lagQ = l1.Q

gen BL = D/at

gen ML = D/MV

gen CR = C/at

gen size = log(at)

gen d_yield = (dvc + dvp)/EMV

gen prof = oibdp/at

gen NI = ib/at

*** Z-score components

gen X1 = (act - lct)/at

gen X2 = re/at

gen X3 = oiadp/at

gen X4 = EMV/D

gen X5 = sale/at

*** generate taxpayer status 

gen taxpayer = 1 if txfed > 0 & txfed !=.
replace taxpayer = 0 if taxpayer ==. & txfed !=.

gen taxpayer_adv = 2 if txfed > 0 & txfed !=.
replace tlcf = 0 if tlcf ==.
replace taxpayer_adv = 1 if txfed <= 0 & tlcf ==0
replace taxpayer_adv = 0 if taxpayer_adv ==. & txfed !=.

**** no information available for these CF statements

gen E_issue = sstk/at

gen div = dvc/at
gen div1 = dvc/lagat
gen div2 = (dvc + prstkc)/lagat

gen OCF = oancf/at
gen OCF1 = oancf/lagat

gen total_def = capx + aqc + dv

gen DEF = total_def/at

gen capex = capx/at
gen capex1 = capx/lagat

gen AQC = aqc/at

*** generate "action" dummies

gen th = 0.05

gen AI = 1 if AQC > th
replace AI = 0 if AI == .

gen EI = 1 if E_issue > th 
replace EI = 0 if EI ==.

*** generate alternative "action" dummies (2.5%)

gen th25 = 0.025

gen AI25 = 1 if AQC > th25
replace AI25 = 0 if AI25 == .

gen EI25 = 1 if E_issue > th25 
replace EI25 = 0 if EI25 ==.

*** generate alternative "action" dummies (7.5%)

gen th75 = 0.075

gen AI75 = 1 if AQC > th75
replace AI75 = 0 if AI75 == .

gen EI75 = 1 if E_issue > th75 
replace EI75 = 0 if EI75 ==.

***** 3 digit investment & dividend (fyear)

sort industry3_fyear

by industry3_fyear: egen ind_capex_3fyr = median(capex)
by industry3_fyear: egen ind_div_3fyr = median(div)


*** generate accrual variables

gen TACC = (COA - lagCOA - (COL - lagCOL) - dp)/lagat

**** additional financial constraint variables

gen TLDT = dltt/at

gen DIVPOS = 1 if dv >0
replace DIVPOS = 0 if DIVPOS ==.

*** generate industry variables

gen CND =1 if sic >= 0100 & sic <=0999
replace CND =1 if sic >= 2000 & sic <=2399
replace CND =1 if sic >= 2700 & sic <=2749
replace CND =1 if sic >= 2770 & sic <=2799
replace CND =1 if sic >= 3100 & sic <=3199
replace CND =1 if sic >= 3940 & sic <=3989
replace CND = 0 if CND ==.


gen CD =1 if sic >= 2500 & sic <=2519
replace CD =1 if sic >= 2590 & sic <=2599
replace CD =1 if sic >= 3630 & sic <=3659
replace CD =1 if sic >= 3710 & sic <=3711
replace CD =1 if sic >= 3714 & sic <=3714
replace CD =1 if sic >= 3716 & sic <=3716
replace CD =1 if sic >= 3750 & sic <=3751
replace CD =1 if sic >= 3792 & sic <=3792
replace CD =1 if sic >= 3900 & sic <=3939
replace CD =1 if sic >= 3990 & sic <=3999
replace CD = 0 if CD ==.


gen MAN =1 if sic >= 2520 & sic <=2589
replace MAN =1 if sic >= 2600 & sic <=2699
replace MAN =1 if sic >= 2750 & sic <=2769
replace MAN =1 if sic >= 3000 & sic <=3099
replace MAN =1 if sic >= 3200 & sic <=3569
replace MAN =1 if sic >= 3580 & sic <=3629
replace MAN =1 if sic >= 3700 & sic <=3709
replace MAN =1 if sic >= 3712 & sic <=3713
replace MAN =1 if sic >= 3715 & sic <=3715
replace MAN =1 if sic >= 3717 & sic <=3749
replace MAN =1 if sic >= 3752 & sic <=3791
replace MAN =1 if sic >= 3793 & sic <=3799
replace MAN =1 if sic >= 3830 & sic <=3839
replace MAN =1 if sic >= 3860 & sic <=3899
replace MAN = 0 if MAN ==.

gen EN =1 if sic >= 1200 & sic <=1399
replace EN =1 if sic >= 2900 & sic <=2999
replace EN = 0 if EN ==.

gen CHEM =1 if sic >= 2800 & sic <=2829
replace CHEM =1 if sic >= 2840 & sic <=2899
replace CHEM = 0 if CHEM ==.

gen BUS =1 if sic >= 3570 & sic <=3579
replace BUS =1 if sic >= 3660 & sic <=3692
replace BUS =1 if sic >= 3694 & sic <=3699
replace BUS =1 if sic >= 3810 & sic <=3829
replace BUS =1 if sic >= 7370 & sic <=7379
replace BUS = 0 if BUS ==.


gen UTIL =1 if sic >= 4800 & sic <=4899
replace UTIL =1 if sic >= 4900 & sic <=4949
replace UTIL = 0 if UTIL ==.

gen SALE =1 if sic >= 5000 & sic <=5999
replace SALE =1 if sic >= 7200 & sic <=7299
replace SALE =1 if sic >= 7600 & sic <=7699
replace SALE = 0 if SALE ==.

gen HLTH =1 if sic >= 2830 & sic <=2839
replace HLTH =1 if sic >= 3693 & sic <=3693
replace HLTH =1 if sic >= 3840 & sic <=3859
replace HLTH =1 if sic >= 8000 & sic <=8099
replace HLTH = 0 if HLTH ==.

gen FIN =1 if sic >= 6000 & sic <=6999
replace FIN = 0 if FIN ==.

gen OTH = 1 - HLTH - SALE - BUS - CHEM - EN - MAN - CD - CND - FIN - UTIL

*** sort the data again

sort EIN fyear

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save crsp_compustat, replace

****** load CCM sponsor file

clear all

set memory 1000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use crsp_compustat

**** MERGE WITH FORM 5500 

merge 1:m EIN fyear using "/Users/administrator_2014/Documents/Research/Pension manipulation/Results/longevity.dta"

drop if _merge != 3

** manually check merge quality
*edit conm SPONS_DFE_NAME

sort gvkey
egen firms = group(gvkey)
summ firms
drop firms

*** generate industry variable based on compustat (instead of form 5500)

drop industry
gen industry = "HLTH" if HLTH == 1
replace industry = "SALE" if SALE == 1
replace industry = "BUS" if BUS == 1
replace industry = "CHEM" if CHEM == 1
replace industry = "EN" if EN == 1
replace industry = "MAN" if MAN == 1
replace industry = "CD" if CD == 1
replace industry = "CND" if CND == 1
replace industry = "FIN" if FIN == 1
replace industry = "UTIL" if UTIL == 1
replace industry = "OTH" if OTH == 1

*** reminder: number of pension plans

*sort id

*drop plans

*sort gvkey
*egen plans = group(id)

*summ plans

*** account for fact that 1 firm might have several plans

drop id

sort EIN fyear year

egen id = group(EIN fyear)

sort id

*** now we compute pension variables at the level of the plan sponr

*** compute implied $-value of risky investments

replace risky = (1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp)*impl_TA

*** generate underfunding dummy

gen unfun = 1 if relfunding < 0
replace unfun = 0 if unfun ==.

summ unfun
summ unfun if unfun == 1

*** generate aggregate sponsor variables

by id: egen total_assets = sum(asset)
by id: egen total_liab = sum(liab)
by id: egen total_accr_liab = sum(accr_liab)

by id: egen total_tot_contr = sum(tot_contr)
by id: egen total_MFC = sum(MFC)
by id: egen total_AFR = sum(AFR)

by id: egen total_participants = sum(participants)
by id: egen total_part_ret = sum(part_ret)
by id: egen total_risky_nom = sum(risky)
by id: egen total_impl_TA = sum(impl_TA)

by id: egen sum_manip = sum(manip)
by id: egen sum_unfun = sum(unfun)
by id: egen sum_plans = count(fyear)

*** generate dispersion in actuarial assumptions

gen diff_int = interest - interest_RPA
by id: egen m_diff_int = mean(diff_int)
by id: egen min_diff_int = min(diff_int)
by id: egen max_diff_int = max(diff_int)

gen diff_LE = long_index_cs - long_GM83
by id: egen m_diff_LE = mean(diff_LE)
by id: egen min_diff_LE = min(diff_LE)
by id: egen max_diff_LE = max(diff_LE)

*** generate "weight" of each plan (based on CL)

gen weight = liab/total_liab

*** compute sponsor specific LE-assumptions (using weights)

gen long1 = long_index_cs*weight
gen long2 = long_GM83*weight

by id: egen total_longevity = sum(long1)
by id: egen total_longevity_GAM = sum(long2)

drop long1 long2

*** compute sponsor specific discount rate assumptions (using weights)

gen interest1 = interest*weight
gen interest1_RPA = interest_RPA*weight

by id: egen total_interest = sum(interest1)
by id: egen total_interest_RPA = sum(interest1_RPA)

drop interest1 interest1_RPA

summ id

*** now keep one observation per firm-year (i.e. per sponsor)

sort id

gen idL = id - id[_n-1]

drop if idL ==0

drop id idL

summ at

*** compute number of sponsors and years

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** descriptive information on manipulation across the same plans by a sponsor (in a given year)

gen manip_freq = sum_manip/sum_plans
summ manip_freq if sum_manip > 0, d

gen diff_diff_int = max_diff_int - min_diff_int
summ diff_diff_int if sum_manip > 0, d

gen diff_diff_LE = max_diff_LE - min_diff_LE
summ diff_diff_LE if sum_manip > 0, d

*** generate sponsor-specifc aggregate plan variables

gen diff_liabA = (total_liab - total_accr_liab)/total_accr_liab

gen LEA = total_longevity - total_longevity_GAM

gen D_interestA = total_interest - total_interest_RPA

gen relfundingA = (total_assets - total_liab)/total_liab
gen lagrelfundingA = l1.relfundingA

gen sizeA = log(total_assets)

gen durationA = 1 - total_part_ret/total_participants
replace durationA = durationA*100

gen riskyA = total_risky_nom/total_impl_TA
replace riskyA = riskyA*100

*** generate sponsor-specific sponsor/plan variables

gen total_tot_contr_at = total_tot_contr/at
gen total_tot_contr_at1 = total_tot_contr/lagat

gen total_MFC_at = total_MFC/at
gen total_MFC_at1 = total_MFC/lagat

gen total_tot_contr_E = total_tot_contr/seq

gen total_tot_contr_plassets = total_tot_contr/total_assets
gen total_MFC_plassets = total_MFC/total_assets

gen sensitivity = total_asset/oibdp

gen rel_size = total_liab/at

gen consol_liab = total_liab + D 
gen consol_assets = MV + total_assets 
gen consol_lev = consol_liab / consol_assets

gen consol_netliab = consol_liab - C
gen consol_netlev = consol_netliab / consol_assets

*** non-missing balance sheet data for required sponsor variables

drop if at ==.
drop if MV == .
drop if Q ==.
drop if BL ==.
drop if CR ==. 
drop if TLDT ==.
drop if TACC ==.
drop if size ==.
drop if X1 ==.
*drop if X4 ==. (because of all-equity firms, we want to keep them)

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing income statement data for required sponsor variables

drop if prof == .
drop if d_yield ==.
drop if NI ==.
drop if dv ==.
drop if DIVPOS ==.
drop if ISG ==.
drop if X2 ==.
drop if X3 ==.
drop if X5 ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing cash flow statement data for required sponsor variables

drop if OCF ==.
drop if capex ==.
drop if dvc ==.
drop if AQC ==.
drop if total_def ==.
drop if E_issue ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** drop if federal tax information is missing

drop if taxpayer ==.

sort gvkey fyear
egen sponsors = group(gvkey)
summ sponsors
drop sponsors

*** non-missing data for required sponsor/plan variables

drop if diff_liabA ==.
drop if LEA ==.
drop if D_interestA ==.
drop if relfundingA ==.
drop if sizeA ==.
drop if durationA ==.
drop if riskyA ==.

drop if total_tot_contr_E ==.
drop if total_tot_contr_plassets ==.

drop if sensitivity ==.

*** compute number of sponsors and years

sort gvkey fyear

egen sponsors = group(gvkey)

summ sponsors
drop sponsors

*** generate manipulation variable

gen manipA = 1 if diff_liabA > 0
replace manipA = 0 if manipA ==.

*** winsorize pension variables

centile diff_liabA, centile(.5 99.5)
replace diff_liabA = r(c_1) if diff_liabA < r(c_1)
replace diff_liabA = r(c_2) if diff_liabA > r(c_2)

centile relfundingA, centile(.5 99.5)
replace relfundingA = r(c_1) if relfundingA < r(c_1)
replace relfundingA = r(c_2) if relfundingA > r(c_2)

centile D_interestA, centile(.5 99.5)
replace D_interestA = r(c_1) if D_interestA < r(c_1)
replace D_interestA = r(c_2) if D_interestA > r(c_2)

centile durationA, centile(0.5 99.5)
replace durationA = r(c_1) if durationA < r(c_1)
replace durationA = r(c_2) if durationA > r(c_2)

centile sizeA, centile(0.5 99.5)
replace sizeA = r(c_1) if sizeA < r(c_1)
replace sizeA = r(c_2) if sizeA > r(c_2)

centile total_tot_contr_at, centile(0.5 99.5)
replace total_tot_contr_at = r(c_1) if total_tot_contr_at < r(c_1)
replace total_tot_contr_at = r(c_2) if total_tot_contr_at > r(c_2)

centile total_tot_contr_at1, centile(0.5 99.5)
replace total_tot_contr_at1 = r(c_1) if total_tot_contr_at1 < r(c_1) & total_tot_contr_at1 !=.
replace total_tot_contr_at1 = r(c_2) if total_tot_contr_at1 > r(c_2) & total_tot_contr_at1 !=.

centile total_MFC_at, centile(0.5 99.5)
replace total_MFC_at = r(c_1) if total_MFC_at < r(c_1)
replace total_MFC_at = r(c_2) if total_MFC_at > r(c_2)

centile total_MFC_at1, centile(0.5 99.5)
replace total_MFC_at1 = r(c_1) if total_MFC_at1 < r(c_1) & total_MFC_at1 !=.
replace total_MFC_at1 = r(c_2) if total_MFC_at1 > r(c_2) & total_MFC_at1 !=.

centile total_tot_contr_plassets, centile(0.5 99.5)
replace total_tot_contr_plassets = r(c_1) if total_tot_contr_plassets < r(c_1)
replace total_tot_contr_plassets = r(c_2) if total_tot_contr_plassets > r(c_2)

centile total_MFC_plassets, centile(0.5 99.5)
replace total_MFC_plassets = r(c_1) if total_MFC_plassets < r(c_1)
replace total_MFC_plassets = r(c_2) if total_MFC_plassets > r(c_2)

centile total_tot_contr_E, centile(0.5 99.5)
replace total_tot_contr_E = r(c_1) if total_tot_contr_E < r(c_1)
replace total_tot_contr_E = r(c_2) if total_tot_contr_E > r(c_2)

centile sensitivity, centile(0.5 99.5)
replace sensitivity = r(c_1) if sensitivity < r(c_1)
replace sensitivity = r(c_2) if sensitivity > r(c_2)

centile rel_size, centile(0.5 99.5)
replace rel_size = r(c_1) if rel_size < r(c_1)
replace rel_size = r(c_2) if rel_size > r(c_2)

centile consol_lev, centile(0.5 99.5)
replace consol_lev = r(c_1) if consol_lev < r(c_1)
replace consol_lev = r(c_2) if consol_lev > r(c_2)


*** winsorize ingredients of index variables

centile X1, centile(0.5 99.5)
replace X1 = r(c_1) if X1 < r(c_1)
replace X1 = r(c_2) if X1 > r(c_2)

centile X2, centile(0.5 99.5)
replace X2 = r(c_1) if X2 < r(c_1)
replace X2 = r(c_2) if X2 > r(c_2)

centile X3, centile(0.5 99.5)
replace X3 = r(c_1) if X3 < r(c_1)
replace X3 = r(c_2) if X3 > r(c_2)

centile X4, centile(0.5 95)
replace X4 = r(c_1) if X4 < r(c_1) & X4 !=.
replace X4 = r(c_2) if X4 > r(c_2) & X4 !=.
*** note: because of high fraction of almost all-equity financed firms we winsorze X4 at the 95% level

centile X5, centile(0.5 99.5)
replace X5 = r(c_1) if X5 < r(c_1)
replace X5 = r(c_2) if X5 > r(c_2)

** generate z-score based on winsorized components

gen Z = 1.2*X1 + 1.4*X2 + 3.3*X3 + 0.6*X4 + 1*X5
summ Z at

centile Z, centile(0.5 99.5)
replace Z = r(c_1) if Z < r(c_1) 
replace Z = r(c_2) if Z > r(c_2) 

summ Z, d

** winsorize BS compustat variables

centile Q, centile(0.5 99.5)
replace Q = r(c_1) if Q < r(c_1)
replace Q = r(c_2) if Q > r(c_2)

centile BL, centile(0.5 99.5)
replace BL = r(c_1) if BL < r(c_1)
replace BL = r(c_2) if BL > r(c_2)

centile CR, centile(0.5 99.5)
replace CR = r(c_1) if CR < r(c_1)
replace CR = r(c_2) if CR > r(c_2)

centile TLDT, centile(0.5 99.5)
replace TLDT = r(c_1) if TLDT < r(c_1)
replace TLDT = r(c_2) if TLDT > r(c_2)

centile TACC, centile(0.5 99.5)
replace TACC = r(c_1) if TACC < r(c_1) 
replace TACC = r(c_2) if TACC > r(c_2) 

centile size, centile(0.5 99.5)
replace size = r(c_1) if size < r(c_1)
replace size = r(c_2) if size > r(c_2)

** winsorize IS compustat variables

centile prof, centile(0.5 99.5)
replace prof = r(c_1) if prof < r(c_1)
replace prof = r(c_2) if prof > r(c_2)

centile d_yield, centile(0.5 99.5)
replace d_yield = r(c_1) if d_yield < r(c_1)
replace d_yield = r(c_2) if d_yield > r(c_2)

centile NI, centile(0.5 99.5)
replace NI = r(c_1) if NI < r(c_1)
replace NI = r(c_2) if NI > r(c_2)

centile div, centile(0.5 99.5)
replace div = r(c_1) if div < r(c_1)
replace div = r(c_2) if div > r(c_2)

centile gs, centile(0.5 99.5)
replace gs = r(c_1) if gs < r(c_1) 
replace gs = r(c_2) if gs > r(c_2) 

** winsorize CF compustat variables

centile OCF, centile(0.5 99.5)
replace OCF = r(c_1) if OCF < r(c_1) 
replace OCF = r(c_2) if OCF > r(c_2)

centile OCF1, centile(0.5 99.5)
replace OCF1 = r(c_1) if OCF1 < r(c_1) & OCF1 !=.
replace OCF1 = r(c_2) if OCF1 > r(c_2) & OCF1 !=.

centile capex, centile(0.5 99.5)
replace capex = r(c_1) if capex < r(c_1)
replace capex = r(c_2) if capex > r(c_2)

centile capex1, centile(0.5 99.5)
replace capex1 = r(c_1) if capex1 < r(c_1) & capex1 !=.
replace capex1 = r(c_2) if capex1 > r(c_2) & capex1 !=.

centile AQC, centile(0.5 99.5)
replace AQC = r(c_1) if AQC < r(c_1)
replace AQC = r(c_2) if AQC > r(c_2)

centile div1, centile(0.5 99.5)
replace div1 = r(c_1) if div1 < r(c_1) & div1 !=.
replace div1 = r(c_2) if div1 > r(c_2) & div1 !=.

centile div2, centile(0.5 99.5)
replace div2 = r(c_1) if div2 < r(c_1) & div2 !=.
replace div2 = r(c_2) if div2 > r(c_2) & div2 !=.

centile DEF, centile(0.5 99.5)
replace DEF = r(c_1) if DEF < r(c_1) & DEF !=.
replace DEF = r(c_2) if DEF > r(c_2) & DEF !=.

*** GENERATE WHITED WU INDEX

gen WW = -0.091*OCF - 0.062*DIVPOS + 0.021*TLDT - 0.044*size + 0.102*ISG - 0.035*gs

*** GENERATE KAPLAN ZINGALES INDEX

gen KZ = -1.001909*OCF + 3.139193*BL - 39.36780*div - 1.314759*CR + 0.2826389*Q
centile KZ, centile(0.5 99.5)

*** gen ecapex and ediv

gen ecapex = capex - ind_capex_3fyr
gen ediv = div - ind_div_3fyr

** record fractions as percentage points

replace consol_lev = consol_lev*100

replace total_tot_contr_E = total_tot_contr_E*100

replace total_tot_contr_at = total_tot_contr_at*100
replace total_tot_contr_plassets = total_tot_contr_plassets*100

replace total_MFC_at = total_MFC_at*100
replace total_MFC_plassets = total_MFC_plassets*100

replace tax1 = tax1*100
replace tax2 = tax2*100

replace diff_liabA = diff_liabA*100

replace relfundingA = relfundingA*100

*** generate positive and negative funding variable

gen p_relfundingA = relfundingA if relfundingA >=0
replace p_relfundingA = 0 if p_relfundingA ==.

gen n_relfundingA = relfundingA*(-1) if relfundingA < 0
replace n_relfundingA = 0 if n_relfundingA ==.

*** generate cash deficit indicator

gen deficit = 1 if DEF > OCF
replace deficit = 0 if deficit ==.


cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

save longevity_compustat, replace



**** ANALYSIS OF PENSION PLAN SPONSORS

clear all

set memory 3000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

use longevity_compustat 

**** descriptive info on pension liability gap

summ diff_liabA, d

summ diff_liabA if diff_liabA >0
gen N = r(N)
summ diff_liabA

display N/r(N)

*** number of plans

sort gvkey year
gen count = 1
replace count = count[_n-1] + 1 if gvkey == gvkey[_n-1]

gen ncount = count
replace ncount =. if ncount[_n+1] !=. & gvkey == gvkey[_n+1]

edit gvkey year count ncount

*** average and medium number of observations per plan

summ ncount,d

** generate number of plans each year

sort year
by year: egen obs = count(gvkey)

*** define total number of manipulative years by plan sponsor

sort gvkey fyear

by gvkey: egen sum_manipA = sum(manipA)
by gvkey: egen num = count(manipA)

*edit gvkey fyear manip sum_manipA num

*** generate number of plan-years by year and manip

sort year gvkey

by year: egen manipA_obs = count(manipA) if manipA > 0
by year: egen nomanipA_obs = count(manipA) if manipA == 0

*** Table 3, Panel B

tabstat total_accr_liab total_liab diff_liabA total_asset relfundingA total_interest total_interest_RPA D_interestA long_index_cs long_GM83 LEA sizeA durationA riskyA obs, by(year)

*** replication of full sample tables (Section 4)

*** Original Table 4 analysis - displayed in Online Appendix Table 5

reg diff_liabA relfundingA, r
estimates store OLS1

reg diff_liabA relfundingA sizeA durationA riskyA, r
estimates store OLS2

reg diff_liabA relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store OLS3

xtscc diff_liabA relfundingA, fe
estimates store FE1

xtscc diff_liabA relfundingA sizeA durationA riskyA, fe
estimates store FE2

xtscc diff_liabA relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,  fe 
estimates store FE3

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1 OLS2 OLS3 FE1 FE2 FE3, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Original Table 6 analysis - displayed in Online Appendix Table 6

reg D_interest relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg D_interest p_relfundingA n_relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

xtscc D_interest relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc D_interest p_relfundingA n_relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear


*** Original Table 7 analysis - displayed in Online Appendix Table 7

gen dum_neg = 1 if LEA < 0
replace dum_neg = 0 if dum_neg ==.

logit dum_neg relfundingA, vce(robust) 
estimates store reg1

logit dum_neg relfundingA sizeA durationA riskyA, vce(robust)
estimates store reg2

logit dum_neg relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg3

logit dum_neg relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg4

logit dum_neg p_relfundingA n_relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom oth d2 d3 d4 d5 d6 d7 d8 d9, vce(robust)
estimates store reg5

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** Original Table 9, Panel A analysis - displayed in Online Appendix Table 8, Panel A

reg total_tot_contr_plassets manipA if relfundingA <=0, r
estimates store reg1

reg total_tot_contr_plassets manipA relfundingA if relfundingA <=0, r
estimates store reg2

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA if relfundingA <=0 , r
estimates store reg3

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg4

reg total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg5

xtscc total_tot_contr_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** Original Table 9, Panel B analysis - displayed in Online Appendix Table 8, Panel B

reg total_MFC_plassets manipA if relfundingA <=0, r
estimates store reg1

reg total_MFC_plassets manipA relfundingA if relfundingA <=0, r
estimates store reg2

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA if relfundingA <=0, r
estimates store reg3

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg4

reg total_MFC_plassets manipA relfundingA sizeA durationA riskyA agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom d2 d3 d4 d5 d6 d7 d8 d9 d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, r
estimates store reg5

xtscc total_MFC_plassets relfundingA manipA sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9 if relfundingA <=0, fe 
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear


*** some untabulated comparisons

tabstat total_tot_contr pbec, by(manipA)

tabstat total_accr_liab total_liab pbpro, by(manipA)

tabstat pbarr total_interest_RPA total_interest, by(manipA) 

*** Table 10: compare manipulative (Panel A) to non-manipulative firms (Panel B) 

tabstat manipA_obs relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1 TACC ppror g pbarr deficit if manipA > 0, by(year)

tabstat nomanipA_obs relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1  TACC ppror g pbarr deficit if manipA == 0, by(year)

** get the number of observations for each variable

summ relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1 TACC ppror g pbarr deficit if manipA > 0

summ relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv tax1  TACC ppror g pbarr deficit if manipA == 0

*** Table 11: determinant regressions

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg1

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg2

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg3

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg4

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg5

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estout reg*, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear 

*** untabulated info (used for interpretation)

logit manipA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC deficit HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if g !=.
logit manipA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC deficit HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if g!=.

*** untabulated: OLS regressions with G

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg1

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg3

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg4

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg5

reg diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estimates clear 

*** untabulated: FE regressions with G

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW taxpayer_adv TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg4

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg5

xtscc diff_liabA relfundingA consol_lev total_tot_contr_E KZ WW tax1 TACC ppror g HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg6

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout reg*, cells(se(par fmt(2))) style(fixed) 

estimates clear 

*** difference in ratios

ttest capex, by(manipA)
ttest div, by(manipA)

ttest ecapex, by(manipA)
ttest ediv, by(manipA)


**************************************************************************************************************
*** Inv/CF Regressions
**************************************************************************************************************

sort gvkey fyear

*** compute cash flow before pension contributions

replace total_MFC_at1 = 0 if lagrelfundingA > 0

gen OCFa1 = OCF1 + total_tot_contr_at1
gen OCFb1 = OCF1 + total_MFC_at1

** compute interaction term

gen IAa1 = manipA*total_tot_contr_at1
gen IAb1 = manipA*total_MFC_at1

*** Table 12, Panel A

xtscc capex1 OCFa1 total_tot_contr_at1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc capex1 manipA OCFa1 total_tot_contr_at1 IAa1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc capex1 manipA OCFa1 total_tot_contr_at1 IAa1 lagQ lagrelfundingA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed)
estimates clear 

*** Table 12, Panel B

xtscc capex1 OCFb1 total_MFC_at1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg1

xtscc capex1 manipA OCFb1 total_MFC_at1 IAb1 lagQ d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg2

xtscc capex1 manipA OCFb1 total_MFC_at1 IAb1 lagQ lagrelfundingA d2 d3 d4 d5 d6 d7 d8 d9, fe
estimates store reg3

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) style(fixed) 
estimates clear 

*** difference in equity issues and acquisition frequencies

ttest EI, by(manipA)
ttest AI, by(manipA)

ttest AI25, by(manipA)
ttest EI25, by(manipA)

ttest AI75, by(manipA)
ttest EI75, by(manipA)

**************************************************************************************************************
*** Credit risk test
**************************************************************************************************************
summ relfundingA p_relfundingA

*** Table 13, Panel A

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND , r
estimates store reg1

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
estimates store reg2
predict resid_OLS, residuals
predict yhat_OLS

xtscc D_interestA Z consol_lev rel_size sizeA durationA riskyA,  fe
estimates store reg3

xtscc D_interestA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,   fe
estimates store reg4

areg D_interestA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9, absorb(gvkey) r
predict resid_FE, residual
predict yhat, xbd

estout reg*, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)
estout reg*, cells(se(par fmt(2))) stats(N r2) style(fixed) 
estimates clear

*** Table 13, Panel B

reg resid_OLS relfundingA, r
estimates store OLS1_SS

reg resid_OLS p_relfundingA n_relfundingA, r
estimates store OLS2_SS

xtscc resid_FE relfundingA, fe
estimates store FE1_SS 

xtscc resid_FE p_relfundingA n_relfundingA, fe
estimates store FE2_SS

estout OLS1_SS OLS2_SS FE1_SS FE2_SS, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout OLS1_SS OLS2_SS FE1_SS FE2_SS, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

*** untabulated
reg D_interestA p_relfundingA n_relfundingA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9, r
xtscc D_interestA p_relfundingA n_relfundingA Z consol_lev rel_size sizeA durationA riskyA d2 d3 d4 d5 d6 d7 d8 d9,   fe

** check whether this makes sense

gen res = D_interestA - yhat

edit res resid_FE

** check whether this makes sense

gen res_OLS = D_interestA - yhat_OLS

edit res_OLS resid_OLS

*** end of check

drop res* yhat*

************************************************************************************
*** Online Appendix: untabulated double sort consolidated leverage and Z-score
************************************************************************************

centile consol_lev, centile(50)
gen CL_p50 = r(c_1) 

centile Z, centile(50)
gen Z_p50 = r(c_1) 

*** consolidated leverage buckets

gen CL_1 = 1 if consol_lev <= CL_p50 
replace CL_1 = 0 if CL_1 == .

gen CL_2 = 1 if consol_lev > CL_p50 
replace CL_2 = 0 if CL_2 == .

*** Z-score buckets

gen Z_1 = 1 if Z <= Z_p50 
replace Z_1 = 0 if Z_1 == .

gen Z_2 = 1 if Z > Z_p50 
replace Z_2 = 0 if Z_2 == .


*** create 4 "portfolios"

gen CL_PF = 1 if CL_1 == 1
gen Z_PF = 1 if Z_1 == 1

forvalues i=2(1)2{
replace CL_PF = `i' if CL_`i' == 1
replace Z_PF = `i' if Z_`i' == 1
}

** display corresponding sort characteristics

tabsort CL_PF Z_PF, su(consol_lev) nocsort norsort

tabsort CL_PF Z_PF, su(Z) nocsort norsort


**perform 2 stage regression model

sort CL_PF gvkey fyear

*replace p_relfundingA = relfundingA

*replace n_relfundingA = relfundingA

** 1st stage

forvalues j=1(1)2{
reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if CL_PF == `j', r
predict resid_PF_`j', residual
estimates store PF_`j'

reg D_interestA Z consol_lev rel_size sizeA durationA riskyA HLTH SALE BUS CHEM EN MAN CD CND d2 d3 d4 d5 d6 d7 d8 d9 if Z_PF == `j', r
predict Zresid_PF_`j', residual
estimates store ZPF_`j'
}

** 2nd stage
 
forvalues j=1(1)2{
reg resid_PF_`j' p_relfundingA n_relfundingA if CL_PF == `j', r
estimates store PF_`j'
reg Zresid_PF_`j' p_relfundingA n_relfundingA if Z_PF == `j', r
estimates store ZPF_`j'

}

estout ZPF_1 ZPF_2 PF_1 PF_2 , cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout ZPF_1 ZPF_2 PF_1 PF_2, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estimates clear

drop resid_PF_* Zresid_PF_* 



*** this file appends the raw data for 2011 and 2012
*** this file cleans the data 

clear all

set memory 4000m

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2012_Latest"

use raw_2012

append using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/Form 5500/F_5500_2011_Latest/raw_2011.dta"

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate DB dummy

gen DB_string = substr(type_pension_bnft_code,1,1)
gen DB = 1 if DB_string == "1"
replace DB = 0 if DB ==.

*** generate DC dummy

gen DC_string = substr(type_pension_bnft_code,1,1)
gen DC = 1 if DC_string == "2"
replace DC = 0 if DC ==.

*** generate other dummy

gen oth = 1 if DC == 0 & DB == 0
replace oth = 0 if oth ==.

gen date = date(sb_plan_year_begin_date, "YMD")
format date %td

gen year_date = year(date)
gen month_date = month(date)

*** focus on DB plans

drop if DB != 1
drop oth

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

summ DB

*** drop multi-employer plans and other animals

drop if type_plan_entity_cd != 2

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** check whether some plan years appear twice

sort ID year

egen id = group(ID year)

sort id

*** check wether id changes

gen idL = id - id[_n-1]
gen idL1 = id[_n+1]-id

*** drob observations in case it id stays constant (forward and backward)

drop if idL ==0
drop if idL1 ==0

drop id idL idL1

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** set time parameter and compute sample

sort ID year

egen id = group(ID)

sort id year

xtset id year

summ DB id year

*** drop small plans (total particpation is only available BOY. General, 6)

gen participants = tot_partcp_boy_cnt
drop if participants < 100

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate liability variable 

gen liab = sb_tot_fndng_tgt_amt
drop if liab == .
drop if liab <=0

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen asset = sb_curr_value_ast_01_amt
drop if asset ==.
drop if asset <=0


*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate funding variable

gen relfunding = (asset - liab)/liab
drop if relfunding ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate mandatory pension contribution
sort id year

gen mand_contrib = sb_fndng_rqmt_tot_amt
drop if mand_contrib ==.
summ mand_contrib, d

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** generate MPC in % of assets

gen rel_mand_contrib = mand_contrib/asset

*** generate change in MPC


sort id year
gen D_mand_contrib = (mand_contrib - l1.mand_contrib)/l1.mand_contrib

*** generate total contributions

*gen contrib = sb_contr_alloc_curr_yr_02_amt
gen contrib = sb_tot_emplr_contrib_amt
drop if contrib ==.
summ contrib, d

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen rel_contrib = sb_tot_emplr_contrib_amt/asset

*** generate excess contributions

gen exc_contrib = contrib - mand_contrib
drop if exc_contrib ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

gen rel_exc_contrib = exc_contrib/asset

**** create industry dummmies

tostring business_code, generate(NAICS)

****

gen agr = 1 if substr(NAICS, 1,2) == "11"
replace agr = 0 if agr ==.

gen min = 1 if substr(NAICS, 1,2) == "21"
replace min = 0 if min ==.

gen util = 1 if substr(NAICS, 1,2) == "22"
replace util = 0 if util ==.

gen cstrc = 1 if substr(NAICS, 1,2) == "23"
replace cstrc = 0 if cstrc ==.

gen man = 1 if substr(NAICS, 1,2) == "31"
replace man = 1 if substr(NAICS, 1,2) == "32"
replace man = 1 if substr(NAICS, 1,2) == "33"
replace man = 0 if man ==.

gen whle = 1 if substr(NAICS, 1,2) == "42"
replace whle = 0 if whle ==.

gen retl = 1 if substr(NAICS, 1,2) == "44"
replace retl = 1 if substr(NAICS, 1,2) == "45"
replace retl = 0 if retl ==.

gen trans = 1 if substr(NAICS, 1,2) == "48"
replace trans = 1 if substr(NAICS, 1,2) == "49"
replace trans = 0 if trans ==.

gen inf = 1 if substr(NAICS, 1,2) == "51"
replace inf = 0 if inf ==.

gen fin = 1 if substr(NAICS, 1,2) == "52"
replace fin = 0 if fin ==.

gen real = 1 if substr(NAICS, 1,2) == "53"
replace real = 0 if real ==.

gen prof = 1 if substr(NAICS, 1,2) == "54"
replace prof = 0 if prof ==.

gen hldg = 1 if substr(NAICS, 1,2) == "55"
replace hldg = 0 if hldg ==.

gen admin = 1 if substr(NAICS, 1,2) == "56"
replace admin = 0 if admin ==.

gen edu = 1 if substr(NAICS, 1,2) == "61"
replace edu = 0 if edu ==.

gen hlth = 1 if substr(NAICS, 1,2) == "62"
replace hlth = 0 if hlth ==.

gen arts = 1 if substr(NAICS, 1,2) == "71"
replace arts = 0 if arts ==.

gen accom = 1 if substr(NAICS, 1,2) == "72"
replace accom = 0 if accom ==.

gen oth = 1 if substr(NAICS, 1,2) == "81"
replace oth = 1 if substr(NAICS, 1,2) == "92"
replace oth = 0 if oth ==.

gen test = agr + min + util + cstrc + man + whle + retl + trans + inf + fin + real + prof + hldg + admin + edu + hlth + arts + accom + oth

summ test if test == 0

*** industry classification: visual inspection suggests that if test == 0, then missing or unclassified numbers

gen industry = "agr" if agr ==1
replace industry = "min" if min == 1
replace industry = "util" if util == 1
replace industry = "cstrc" if cstrc == 1
replace industry = "man" if man == 1
replace industry = "whle" if whle == 1
replace industry = "retl" if retl == 1
replace industry = "trans" if trans == 1
replace industry = "inf" if inf == 1
replace industry = "fin" if fin == 1
replace industry = "real" if real == 1
replace industry = "prof" if prof == 1
replace industry = "hldg" if hldg == 1
replace industry = "admin" if admin == 1
replace industry = "edu" if edu == 1
replace industry = "hlth" if hlth == 1
replace industry = "arts" if arts == 1
replace industry = "accom" if accom == 1
replace industry = "oth" if oth == 1

*** size variable

gen size = log(asset) 

*** duration variable

replace rtd_sep_partcp_rcvg_cnt= 0 if rtd_sep_partcp_rcvg_cnt ==.
replace benef_rcvg_bnft_cnt = 0 if benef_rcvg_bnft_cnt ==.

gen part_ret = rtd_sep_partcp_rcvg_cnt + benef_rcvg_bnft_cnt

gen duration = 1 - part_ret/participants

**** focus on asset allocation


*** generate investment variables

gen cash = non_int_bear_cash_eoy_amt
replace cash = 0 if cash ==.
 
gen cash_inv = int_bear_cash_eoy_amt
replace cash_inv = 0 if cash_inv ==.

gen AR = emplr_contrib_eoy_amt + partcp_contrib_eoy_amt + other_receivables_eoy_amt
replace AR = 0 if AR ==.

gen US_treas = govt_sec_eoy_amt
replace US_treas = 0 if US_treas ==.

gen debt_corp = corp_debt_preferred_eoy_amt + corp_debt_other_eoy_amt
replace debt_corp = 0 if debt_corp ==.

gen equity = pref_stock_eoy_amt + common_stock_eoy_amt
replace equity = 0 if equity ==.

gen JV = joint_venture_eoy_amt
replace JV = 0 if JV ==.

gen RE = real_estate_eoy_amt
replace RE = 0 if RE ==.

gen loans = other_loans_eoy_amt + partcp_loans_eoy_amt
replace loans = 0 if loans ==.

gen com_trust = int_common_tr_eoy_amt
replace com_trust = 0 if com_trust ==.

gen pool_trust = int_pool_sep_acct_eoy_amt
replace pool_trust = 0 if pool_trust ==.

gen master_trust = int_master_tr_eoy_amt
replace master_trust = 0 if master_trust ==.

gen inv = int_103_12_invst_eoy_amt
replace inv = 0 if inv ==.

gen funds = int_reg_invst_co_eoy_amt
replace funds = 0 if funds ==.

gen insurance = ins_co_gen_acct_eoy_amt
replace insurance = 0 if insurance ==.

gen other = oth_invst_eoy_amt
replace other = 0 if other ==.

gen employer = emplr_sec_eoy_amt + emplr_prop_eoy_amt
replace employer = 0 if employer ==.

gen buildings = bldgs_used_eoy_amt
replace buildings = 0 if buildings ==.

gen TA = tot_assets_eoy_amt

gen impl_TA = cash + cash_inv + AR + US_treas + debt_corp + equity + JV + RE + loans +  com_trust +  pool_trust + master_trust + inv + funds + insurance + other + employer + buildings

summ TA impl_TA

*** drop negative values
drop if cash < 0
drop if cash_inv < 0
drop if AR < 0
drop if US_treas < 0
drop if debt_corp < 0
drop if equity < 0
drop if JV < 0
drop if RE < 0
drop if loans < 0
drop if com_trust < 0
drop if pool_trust < 0
drop if master_trust < 0
drop if inv < 0
drop if funds < 0
drop if insurance < 0
drop if other < 0
drop if employer < 0
drop if buildings < 0

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

***

gen rel_cash = cash/impl_TA
gen rel_cash_inv = cash_inv/impl_TA
gen rel_AR = AR/impl_TA
gen rel_US_treas = US_treas/impl_TA
gen rel_debt_corp = debt_corp/impl_TA
gen rel_equity = equity/impl_TA
gen rel_JV = JV/impl_TA
gen rel_RE = RE/impl_TA
gen rel_loans = loans/impl_TA
gen rel_com_trust = com_trust/impl_TA
gen rel_master_trust = master_trust/impl_TA
gen rel_pool_trust = pool_trust/impl_TA
gen rel_inv = inv/impl_TA
gen rel_funds = funds/impl_TA
gen rel_insurance = insurance/impl_TA
gen rel_other = other/impl_TA
gen rel_employer = employer/impl_TA
gen rel_buildings = buildings/impl_TA


*** define risky assets

gen risky = 1 - rel_cash - rel_cash_inv - rel_AR - rel_US_trea - rel_debt_corp
drop if risky ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

summ risky, d 

*** tset the variable

gen myear= ym(year_date,month_date)

format myear %tm

sort ID myear
drop id
egen id = group(ID)

sort id myear
xtset id myear

cd "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL"

save data, replace

****

clear all

set memory 2000m

cd "/Users/administrator_2014/Documents/Research/Pension manipulation/Results"

*** manually build up the dataset 
*** reason: we need to enter the segmented yield curve boundaries manually

set obs 1

generate year_date = 2010 in 1
gen month_date = 1 in 1

forvalues i=2(1)12{
set obs `i'
replace year_date = 2010 in `i' 
replace month_date = `i'  in `i' 
}

set obs 13
replace year_date = 2011 in 13
replace month_date =1 in 13

forvalues i=14(1)24{
set obs `i'
replace year_date = 2011 in `i' 
replace month_date = (`i' - 12)  in `i'
}

set obs 25
replace year_date = 2012 in 25
replace month_date =1 in 25

forvalues i=26(1)36{
set obs `i'
replace year_date = 2012 in `i' 
replace month_date = (`i' - 24)  in `i' 
}

** generate monthly variables

gen myear= ym(year_date,month_date)

format myear %tm

tset myear

**** the segement rates are obtains from the IRS
***http://www.irs.gov/Retirement-PLans/Funding-Yield-Curve-Segment-Rates (hardcopy available)


*** official segment rates in 2010

gen reg_interest_seg1 = 460 if year_date == 2010 & month_date == 1
gen reg_interest_seg2 = 665 if year_date == 2010 & month_date == 1
gen reg_interest_seg3 = 676 if year_date == 2010 & month_date == 1

replace reg_interest_seg1 = 451 if year_date == 2010 & month_date == 2
replace reg_interest_seg2 = 664 if year_date == 2010 & month_date == 2
replace reg_interest_seg3 = 675 if year_date == 2010 & month_date == 2

replace reg_interest_seg1 = 444 if year_date == 2010 & month_date == 3
replace reg_interest_seg2 = 662 if year_date == 2010 & month_date == 3
replace reg_interest_seg3 = 674 if year_date == 2010 & month_date == 3

replace reg_interest_seg1 = 435 if year_date == 2010 & month_date == 4
replace reg_interest_seg2 = 659 if year_date == 2010 & month_date == 4
replace reg_interest_seg3 = 672 if year_date == 2010 & month_date == 4

replace reg_interest_seg1 = 426 if year_date == 2010 & month_date == 5
replace reg_interest_seg2 = 656 if year_date == 2010 & month_date == 5
replace reg_interest_seg3 = 670 if year_date == 2010 & month_date == 5

replace reg_interest_seg1 = 416 if year_date == 2010 & month_date == 6
replace reg_interest_seg2 = 652 if year_date == 2010 & month_date == 6
replace reg_interest_seg3 = 668 if year_date == 2010 & month_date == 6

replace reg_interest_seg1 = 405 if year_date == 2010 & month_date == 7
replace reg_interest_seg2 = 647 if year_date == 2010 & month_date == 7
replace reg_interest_seg3 = 665 if year_date == 2010 & month_date == 7

replace reg_interest_seg1 = 392 if year_date == 2010 & month_date == 8
replace reg_interest_seg2 = 640 if year_date == 2010 & month_date == 8
replace reg_interest_seg3 = 661 if year_date == 2010 & month_date == 8

replace reg_interest_seg1 = 378 if year_date == 2010 & month_date == 9
replace reg_interest_seg2 = 631 if year_date == 2010 & month_date == 9
replace reg_interest_seg3 = 657 if year_date == 2010 & month_date == 9

replace reg_interest_seg1 = 361 if year_date == 2010 & month_date == 10
replace reg_interest_seg2 = 620 if year_date == 2010 & month_date == 10
replace reg_interest_seg3 = 653 if year_date == 2010 & month_date == 10

replace reg_interest_seg1 = 337 if year_date == 2010 & month_date == 11
replace reg_interest_seg2 = 604 if year_date == 2010 & month_date == 11
replace reg_interest_seg3 = 649 if year_date == 2010 & month_date == 11

replace reg_interest_seg1 = 314 if year_date == 2010 & month_date == 12
replace reg_interest_seg2 = 590 if year_date == 2010 & month_date == 12
replace reg_interest_seg3 = 646 if year_date == 2010 & month_date == 12

*** official segment rates in 2011

replace reg_interest_seg1 = 294 if year_date == 2011 & month_date == 1
replace reg_interest_seg2 = 582 if year_date == 2011 & month_date == 1
replace reg_interest_seg3 = 646 if year_date == 2011 & month_date == 1

replace reg_interest_seg1 = 281 if year_date == 2011 & month_date == 2
replace reg_interest_seg2 = 576 if year_date == 2011 & month_date == 2
replace reg_interest_seg3 = 646 if year_date == 2011 & month_date == 2

replace reg_interest_seg1 = 267 if year_date == 2011 & month_date == 3
replace reg_interest_seg2 = 569 if year_date == 2011 & month_date == 3
replace reg_interest_seg3 = 644 if year_date == 2011 & month_date == 3

replace reg_interest_seg1 = 251 if year_date == 2011 & month_date == 4
replace reg_interest_seg2 = 559 if year_date == 2011 & month_date == 4
replace reg_interest_seg3 = 638 if year_date == 2011 & month_date == 4

replace reg_interest_seg1 = 238 if year_date == 2011 & month_date == 5
replace reg_interest_seg2 = 551 if year_date == 2011 & month_date == 5
replace reg_interest_seg3 = 636 if year_date == 2011 & month_date == 5

replace reg_interest_seg1 = 227 if year_date == 2011 & month_date == 6
replace reg_interest_seg2 = 543 if year_date == 2011 & month_date == 6
replace reg_interest_seg3 = 634 if year_date == 2011 & month_date == 6

replace reg_interest_seg1 = 218 if year_date == 2011 & month_date == 7
replace reg_interest_seg2 = 536 if year_date == 2011 & month_date == 7
replace reg_interest_seg3 = 633 if year_date == 2011 & month_date == 7

replace reg_interest_seg1 = 211 if year_date == 2011 & month_date == 8
replace reg_interest_seg2 = 531 if year_date == 2011 & month_date == 8
replace reg_interest_seg3 = 632 if year_date == 2011 & month_date == 8

replace reg_interest_seg1 = 206 if year_date == 2011 & month_date == 9
replace reg_interest_seg2 = 525 if year_date == 2011 & month_date == 9
replace reg_interest_seg3 = 632 if year_date == 2011 & month_date == 9

replace reg_interest_seg1 = 203 if year_date == 2011 & month_date == 10
replace reg_interest_seg2 = 520 if year_date == 2011 & month_date == 10
replace reg_interest_seg3 = 630 if year_date == 2011 & month_date == 10

replace reg_interest_seg1 = 201 if year_date == 2011 & month_date == 11
replace reg_interest_seg2 = 516 if year_date == 2011 & month_date == 11
replace reg_interest_seg3 = 628 if year_date == 2011 & month_date == 11

replace reg_interest_seg1 = 199 if year_date == 2011 & month_date == 12
replace reg_interest_seg2 = 512 if year_date == 2011 & month_date == 12
replace reg_interest_seg3 = 624 if year_date == 2011 & month_date == 12

*** official segment rates in 2012

replace reg_interest_seg1 = 198 if year_date == 2012 & month_date == 1
replace reg_interest_seg2 = 507 if year_date == 2012 & month_date == 1
replace reg_interest_seg3 = 619 if year_date == 2012 & month_date == 1

replace reg_interest_seg1 = 196 if year_date == 2012 & month_date == 2
replace reg_interest_seg2 = 501 if year_date == 2012 & month_date == 2
replace reg_interest_seg3 = 613 if year_date == 2012 & month_date == 2

replace reg_interest_seg1 = 193 if year_date == 2012 & month_date == 3
replace reg_interest_seg2 = 495 if year_date == 2012 & month_date == 3
replace reg_interest_seg3 = 607 if year_date == 2012 & month_date == 3

replace reg_interest_seg1 = 190 if year_date == 2012 & month_date == 4
replace reg_interest_seg2 = 490 if year_date == 2012 & month_date == 4
replace reg_interest_seg3 = 601 if year_date == 2012 & month_date == 4

replace reg_interest_seg1 = 187 if year_date == 2012 & month_date == 5
replace reg_interest_seg2 = 484 if year_date == 2012 & month_date == 5
replace reg_interest_seg3 = 596 if year_date == 2012 & month_date == 5

replace reg_interest_seg1 = 184 if year_date == 2012 & month_date == 6
replace reg_interest_seg2 = 479 if year_date == 2012 & month_date == 6
replace reg_interest_seg3 = 590 if year_date == 2012 & month_date == 6

replace reg_interest_seg1 = 181 if year_date == 2012 & month_date == 7
replace reg_interest_seg2 = 473 if year_date == 2012 & month_date == 7
replace reg_interest_seg3 = 585 if year_date == 2012 & month_date == 7

replace reg_interest_seg1 = 177 if year_date == 2012 & month_date == 8
replace reg_interest_seg2 = 467 if year_date == 2012 & month_date == 8
replace reg_interest_seg3 = 578 if year_date == 2012 & month_date == 8

replace reg_interest_seg1 = 175 if year_date == 2012 & month_date == 9
replace reg_interest_seg2 = 462 if year_date == 2012 & month_date == 9
replace reg_interest_seg3 = 572 if year_date == 2012 & month_date == 9

replace reg_interest_seg1 = 172 if year_date == 2012 & month_date == 10
replace reg_interest_seg2 = 458 if year_date == 2012 & month_date == 10
replace reg_interest_seg3 = 567 if year_date == 2012 & month_date == 10

replace reg_interest_seg1 = 169 if year_date == 2012 & month_date == 11
replace reg_interest_seg2 = 453 if year_date == 2012 & month_date == 11
replace reg_interest_seg3 = 560 if year_date == 2012 & month_date == 11

replace reg_interest_seg1 = 166 if year_date == 2012 & month_date == 12
replace reg_interest_seg2 = 447 if year_date == 2012 & month_date == 12
replace reg_interest_seg3 = 552 if year_date == 2012 & month_date == 12

*** official segment rates in 2013

replace reg_interest_seg1 = 162 if year_date == 2013 & month_date == 1
replace reg_interest_seg2 = 440 if year_date == 2013 & month_date == 1
replace reg_interest_seg3 = 545 if year_date == 2013 & month_date == 1

replace reg_interest_seg1 = 158 if year_date == 2013 & month_date == 2
replace reg_interest_seg2 = 434 if year_date == 2013 & month_date == 2
replace reg_interest_seg3 = 538 if year_date == 2013 & month_date == 2

replace reg_interest_seg1 = 154 if year_date == 2013 & month_date == 3
replace reg_interest_seg2 = 428 if year_date == 2013 & month_date == 3
replace reg_interest_seg3 = 532 if year_date == 2013 & month_date == 3

replace reg_interest_seg1 = 150 if year_date == 2013 & month_date == 4
replace reg_interest_seg2 = 422 if year_date == 2013 & month_date == 4
replace reg_interest_seg3 = 526 if year_date == 2013 & month_date == 4

replace reg_interest_seg1 = 146 if year_date == 2013 & month_date == 5
replace reg_interest_seg2 = 415 if year_date == 2013 & month_date == 5
replace reg_interest_seg3 = 520 if year_date == 2013 & month_date == 5

replace reg_interest_seg1 = 143 if year_date == 2013 & month_date == 6
replace reg_interest_seg2 = 410 if year_date == 2013 & month_date == 6
replace reg_interest_seg3 = 515 if year_date == 2013 & month_date == 6

replace reg_interest_seg1 = 141 if year_date == 2013 & month_date == 7
replace reg_interest_seg2 = 407 if year_date == 2013 & month_date == 7
replace reg_interest_seg3 = 511 if year_date == 2013 & month_date == 7

replace reg_interest_seg1 = 139 if year_date == 2013 & month_date == 8
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 8
replace reg_interest_seg3 = 508 if year_date == 2013 & month_date == 8

replace reg_interest_seg1 = 137 if year_date == 2013 & month_date == 9
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 9
replace reg_interest_seg3 = 506 if year_date == 2013 & month_date == 9

replace reg_interest_seg1 = 135 if year_date == 2013 & month_date == 10
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 10
replace reg_interest_seg3 = 505 if year_date == 2013 & month_date == 10

replace reg_interest_seg1 = 131 if year_date == 2013 & month_date == 11
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 11
replace reg_interest_seg3 = 505 if year_date == 2013 & month_date == 11

replace reg_interest_seg1 = 128 if year_date == 2013 & month_date == 12
replace reg_interest_seg2 = 405 if year_date == 2013 & month_date == 12
replace reg_interest_seg3 = 507 if year_date == 2013 & month_date == 12


*** create both 12 months lag and lead values

forvalues i=1(1)12{
gen lag`i'_reg_interest_seg1 = l`i'.reg_interest_seg1
gen lag`i'_reg_interest_seg2 = l`i'.reg_interest_seg2
gen lag`i'_reg_interest_seg3 = l`i'.reg_interest_seg3
}

forvalues i=1(1)12{
gen lead`i'_reg_interest_seg1 = f`i'.reg_interest_seg1
gen lead`i'_reg_interest_seg2 = f`i'.reg_interest_seg2
gen lead`i'_reg_interest_seg3 = f`i'.reg_interest_seg3
}

*** doublec check that code is correct, it is

*edit if year_date == 2011

*** merge with Form 5500 Raw Data (for 2011 and 2012)

sort myear

merge 1:m myear using "/Users/administrator_2014/Dropbox/Research/Pension manipulation/Raw Data/Form 5500/DOL/data"

****

drop if _merge !=3

drop _merge

***
sort id myear

*** generate yield curve dummy

gen yield_curve = sb_yield_curve_ind
replace yield_curve = 0 if sb_yield_curve_ind ==.

sort id
egen plans = group(id)
summ plans
drop plans

*** shows that out of full sample of plans in 2011 and 2012, 99.2% use segmented yield curve concept

summ yield_curve, d

*** generate interest rate

gen interest = sb_eff_int_rate_prcnt*100
drop if interest ==.

*** generate segment interest rates

gen interest_seg1 = sb_1st_seg_rate_prcnt*100
gen interest_seg2 = sb_2nd_seg_rate_prcnt*100
gen interest_seg3 = sb_3rd_seg_rate_prcnt*100

drop if interest_seg1 ==.
drop if interest_seg2 ==.
drop if interest_seg3 ==.

*** drop obvious typos (based on page 1, IRS document)

summ interest_seg1 if interest_seg1 > 677
drop  if interest_seg1 > 677

summ interest_seg2 if interest_seg2 > 837
drop  if interest_seg2 > 837

summ interest_seg3 if interest_seg3 > 918
drop  if interest_seg3 > 918

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** deal with details of pension funding law. the used interest rate should equal the published rate (entered manually above) subject to a +/- 12 months deviation
*** we account for the lead/lag and allow for minor typos (defined as 2 basis points difference; small impact on sample size)

**** look at difference between used rate and the regulated interest rate

gen diff_seg1 = interest_seg1 - reg_interest_seg1 if year_date == 2011
gen diff_seg2 = interest_seg2 - reg_interest_seg2 if year_date == 2011
gen diff_seg3 = interest_seg3 - reg_interest_seg3 if year_date == 2011

*** define tolerance threshold (2 basis points)

gen th = 2

*** compute total difference in assumptions (measured in basis points)

gen diff = diff_seg1 + diff_seg2 + diff_seg3 if year_date == 2011
replace diff = 0 if diff > -th & diff < th & year_date == 2011

summ diff if year_date == 2011
summ diff if diff == 0 & year_date == 2011

gen dum = 1 if diff == 0 & year_date == 2011
replace dum = 0 if dum ==. & year_date == 2011

gen diff_0 = diff
gen dum_0 = dum

*** compute lookback (and lookforward) interest rates for 1 to 12 months

forvalues i=1(1)12{
gen diff_seg1_l`i' = interest_seg1 - lag`i'_reg_interest_seg1 if year_date == 2011
gen diff_seg2_l`i' = interest_seg2 - lag`i'_reg_interest_seg2 if year_date == 2011
gen diff_seg3_l`i' = interest_seg3 - lag`i'_reg_interest_seg3 if year_date == 2011

gen diff_seg1_f`i' = interest_seg1 - lead`i'_reg_interest_seg1 if year_date == 2011
gen diff_seg2_f`i' = interest_seg2 - lead`i'_reg_interest_seg2 if year_date == 2011
gen diff_seg3_f`i' = interest_seg3 - lead`i'_reg_interest_seg3 if year_date == 2011

gen diff_l`i' = diff_seg1_l`i' + diff_seg2_l`i' + diff_seg3_l`i' if year_date == 2011
gen diff_f`i' = diff_seg1_f`i' + diff_seg2_f`i' + diff_seg3_f`i' if year_date == 2011

replace diff_l`i' = 0 if diff_l`i' > -th & diff_l`i' < th & year_date == 2011
replace diff_f`i' = 0 if diff_f`i' > -th & diff_f`i' < th & year_date == 2011

gen dum_l`i' = 1 if diff_l`i' == 0 & year_date == 2011
replace dum_l`i' = 0 if dum_l`i' ==. & year_date == 2011

gen dum_f`i' = 1 if diff_f`i' == 0 & year_date == 2011
replace dum_f`i' = 0 if dum_f`i' ==. & year_date == 2011
}

**** replace difference
forvalues i=1(1)12{
replace diff = diff_l`i' if dum_l`i' == 1 & year_date == 2011
replace diff = diff_f`i' if dum_f`i' == 1 & year_date == 2011

replace dum = dum_l`i' if dum_l`i' == 1 & year_date == 2011
replace dum = dum_f`i' if dum_f`i' == 1 & year_date == 2011
}

replace diff = 0 if diff > -th & diff < th & year_date == 2011
summ diff if year_date == 2011, d

*** drop plans that can not identify properly

drop if diff < 0 & year_date == 2011
drop if diff > 0 & year_date == 2011

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** show the fraction of firms using end of year vs 12 month lead/lag interest rate reporting assumptions

summ dum*

*** sort plans

sort id myear

edit id myear dum*


*** use previous value for interst rate reporting assumption
*** reason: sponsors can't choose and cherry pick the lead/lag point in time from period to period

replace dum = dum[_n-1] if id==id[_n-1] & dum ==.
replace dum_0 = dum_0[_n-1] if id==id[_n-1] & dum_0 ==.

forvalues i=1(1)12{
replace dum_l`i' = dum_l`i'[_n-1] if id==id[_n-1] & dum_l`i'==.
replace dum_f`i' = dum_f`i'[_n-1] if id==id[_n-1] & dum_f`i'==.
}

*** make sure you drop the plans in 2012 that could not properly be identified in 2011 and/or did not exist in 2011

drop if dum ==.

*** number of plans/obs
sort ID
egen plans = group(ID)
summ plans
drop plans

*** number of plans in 2012 (final sample for regression)

summ dum* if year_date == 2012

*** compute regulated pre-MAP-21 rate in 2012

gen reg2012_reg_interest_seg1 = reg_interest_seg1 if dum_0 == 1 & year_date == 2012
gen reg2012_reg_interest_seg2 = reg_interest_seg2 if dum_0 == 1 & year_date == 2012
gen reg2012_reg_interest_seg3 = reg_interest_seg3 if dum_0 == 1 & year_date == 2012

forvalues i=1(1)12{
replace reg2012_reg_interest_seg1 = lag`i'_reg_interest_seg1 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg1 = lead`i'_reg_interest_seg1 if dum_f`i'==1 & year_date == 2012

replace reg2012_reg_interest_seg2 = lag`i'_reg_interest_seg2 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg2 = lead`i'_reg_interest_seg2 if dum_f`i'==1 & year_date == 2012

replace reg2012_reg_interest_seg3 = lag`i'_reg_interest_seg3 if dum_l`i'==1 & year_date == 2012
replace reg2012_reg_interest_seg3 = lead`i'_reg_interest_seg3 if dum_f`i'==1 & year_date == 2012
}

**** compute by how much interest rate has changed in 2012

replace diff_seg1 = interest_seg1 - reg2012_reg_interest_seg1 if year_date == 2012
replace diff_seg2 = interest_seg2 - reg2012_reg_interest_seg2 if year_date == 2012
replace diff_seg3 = interest_seg3 - reg2012_reg_interest_seg3 if year_date == 2012

*** now replace "old" diff variable

summ diff if year_date == 2012, d

replace diff = diff_seg1 + diff_seg2 + diff_seg3 if year_date == 2012

summ diff if year_date == 2012, d

gen update = 1 if diff > 0 & year_date == 2012
replace update = 0 if update ==. & year_date == 2012

*** number of plans in 2012

summ update if year_date == 2012

*** compute average increase in interest rates

gen avg_interest_seg = (interest_seg1 + interest_seg2 + interest_seg3)/3 if year_date == 2012

gen avg_reg_interest_seg = (reg2012_reg_interest_seg1 + reg2012_reg_interest_seg2 + reg2012_reg_interest_seg3)/3 if year_date == 2012

gen diff_avg = avg_interest_seg - avg_reg_interest_seg if year_date == 2012

summ diff_avg if update == 1
summ diff_avg if update == 0

*** winsorize main variables

centile relfunding, centile(0.5 99.5)
replace relfunding = r(c_1) if relfunding < r(c_1)
replace relfunding = r(c_2) if relfunding > r(c_2)

centile rel_mand_contrib, centile(0.5 99.5)
replace rel_mand_contrib = r(c_1) if rel_mand_contrib < r(c_1)
replace rel_mand_contrib = r(c_2) if rel_mand_contrib > r(c_2)

centile exc_contrib, centile(0.5 99.5)
replace exc_contrib = r(c_1) if exc_contrib < r(c_1)
replace exc_contrib = r(c_2) if exc_contrib > r(c_2)

centile duration, centile(0.5 99.5)
replace duration = r(c_1) if duration < r(c_1)
replace duration = r(c_2) if duration > r(c_2)

summ D_mand_contrib, d
centile D_mand_contrib, centile(0.5 99.5)
replace D_mand_contrib = r(c_1) if D_mand_contrib < r(c_1)
replace D_mand_contrib = r(c_2) if D_mand_contrib > r(c_2)

summ risky, d

*** summary statistics of main variables

sort id year_date
xtset id year_date

gen lag_relfunding  = l1.relfunding
gen lag_rel_mand_contrib = l1.rel_mand_contrib
gen lag_rel_exc_contrib = l1.rel_exc_contrib

tabstat relfunding lag_relfunding rel_mand_contrib lag_rel_mand_contrib D_mand_contrib rel_exc_contrib lag_rel_exc_contrib, by(update)

tabstat relfunding lag_relfunding rel_mand_contrib lag_rel_mand_contrib D_mand_contrib rel_exc_contrib lag_rel_exc_contrib, by(update) s(med)

*** switching prediction model

gen lag_relfunding_p = lag_relfunding if lag_relfunding > 0
replace lag_relfunding_p = 0 if lag_relfunding_p ==.

gen lag_relfunding_n = lag_relfunding*(-1) if lag_relfunding < 0
replace lag_relfunding_n = 0 if lag_relfunding_n ==.

*** Table 14: 
logistic update lag_relfunding_p lag_relfunding_n if year_date == 2012, r
estimates store logit1

logistic update lag_relfunding_p lag_relfunding_n size duration risky agr min util cstrc man whle retl trans inf real prof hldg admin edu hlth arts accom if year_date == 2012, r
estimates store logit2

estout logit1 logit2, cells(b(star fmt(2))) stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estout logit1 logit2, cells(se(par fmt(2))) stats(N r2) style(fixed) 

estout logit1 logit2, eform stats(N r2) style(fixed) starlevels(+ 0.10 * 0.05 ** 0.01)

estimates clear

