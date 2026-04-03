*** Journal of Accounting Research ***
*** Corporate Loan Securitization and the Standardization of Financial Covenants ***
*** Bozanic, Loumioti, and Vasvari (2017) ***


*** Table of Contents (TOC) ***
 
* Step 1A: 	Merge CLO-i and and DealScan data
* Step 1B: 	Merge CLO holdings and CLO performance data  
* Step 2:	Identify syndicated loans securitized at origination
* Step 3:	Match securitized loan sample to Chava and Roberts' Dealscan-Compustat data
* Step 4:	Identify a matched sample of non-securitized institutional loans in DealScan
* Step 5:	Hand collect and group the complete financial covenant definitions from loan contracts
* Step 6:	Calculate the Covenant Similarity Score of the financial covenant definitions at the loan level and merge
* Step 7:	Key variables for our loan sample and main analysis
* Step 8:	Key variables for our CLO-quarter sample

*** End TOC ***


***********************************************************************************************************
* Step 1A: Merge CLO-i and (data version: as of June 2013) and DealScan (data version: as of December 2012)
***********************************************************************************************************

/* This section describes in detail the CLOi database to help future users process the data.  
CLOi includes 3 main datasets: CLO holdings, CLO trades and CLO performance.
Holdings dataset is hand-collected from CLO-i website and includes tranche level information on monthly portfolio holdings of US CLOs.

We merge CLOi and DealScan using issuer name, tranche type and maturity date [tranche type specific includes a detailed description of the tranche and thus it is hard to match;
we use this variable when cleaning the dataset after the merge]*/


* Bring in CLO-i
use "F:\holdingsTOTAL_original.dta",replace 

* drop non-US issuers
replace issuer_country=lower(issuer_country)
drop if issuer_country==""
gen usa=0
replace usa=1 if issuer_country=="united states"
keep if usa==1
drop usa

format reporting_date %td
drop if reporting_date==.
gen reporting_month=mofd(reporting_date)
gen reporting_quarter=qofd(reporting_date)
gen reporting_year=yofd(reporting_date)


format maturity_date %td
drop if maturity_date==.
 

replace deal=lower(deal)
replace deal=trim(deal)
* Deal=CLO; Deal names are also manually cleaned


* Simplify issuer name for the matching process
drop if issuer==""
replace issuer=lower(issuer)
replace issuer=trim(issuer)
split issuer
*Punctuation points (e.g., ",", "/", "(", ")", "-") are also removed from issuer1, issuer2, issuer3 using the split function"
replace issuer1=trim(issuer1)
replace issuer2=trim(issuer2)
replace issuer3=trim(issuer3)
gen issuer_3wrds= issuer1+" "+issuer2+" "+issuer3
replace issuer_3wrds=trim(issuer_3wrds)
drop issuer1 issuer2 issuer3 issuer4 issuer5 issuer6 issuer7 issuer8 issuer9 issuer10 issuer11 issuer12 
rename issuer_3wrds issuer_3wrds_cloi



gen loan_type=issuetypemajor
drop if loan_type==""
replace loan_type=lower(loan_type)
replace loan_type=trim(loan_type)

* Drop CLO assets that are not loans; 99.2% of the CLO assets are loans
drop if loan_type=="bond"
drop if loan_type=="credit default swap"
drop if loan_type=="equity"
drop if loan_type=="other"

* Term loan (other) is not a facility type in DealScan, so replace it with term loan
replace loan_type="term loan" if loan_type=="term loan (other)"



* Interest vs. principal balance for CLO loans can be reported as 2 different entries
collapse (sum)balance, by(deal reporting_date reporting_month reporting_quarter reporting_year issuer issuer_3wrds_cloi industry sp_rating moodys_rating loan_type issuetypemajor issuetypeminor maturity_date)

save "F:\holdingsTOTAL.dta",replace 

contract issuer issuer_3wrds_cloi loan_type issuetypeminor maturity_date
gen constant=1
drop _f
gen collateral_id=_n
sort issuer loan_type maturity_date
save "F:\holdingsTOTAL_small.dta",replace 




* Bring in Dealscan
use "F:\facilityid.dta",replace 


* Drop non-US issuers
keep if Country=="USA"



rename Company issuer
drop if issuer==""
replace issuer=lower(issuer)
replace issuer=trim(issuer)
split issuer
*Punctuation points (e.g., ",", "/", "(", ")", "-") are also removed from issuer1, issuer2, issuer3 using the split function"
replace issuer1=trim(issuer1)
replace issuer2=trim(issuer2)
replace issuer3=trim(issuer3)
gen issuer_3wrds= issuer1+" "+issuer2+" "+issuer3
replace issuer_3wrds=trim(issuer_3wrds)
drop issuer1 issuer2 issuer3 issuer4 issuer5 issuer6 issuer7 issuer8 issuer9 issuer10 issuer11 issuer12 issuer13 issuer14 issuer15
rename issuer_3wrds issuer_3wrds_dealscan

rename FacilityEndDate maturity_date
format maturity_date %td
drop if maturity_date==.

rename LoanType loan_type
drop if loan_type==""
replace loan_type=lower(loan_type)
replace loan_type=trim(loan_type) 

* Group and rename loan types in Dealscan to improve match with CLOi
replace loan_type="mezzanine" if loan_type=="mezzanine tranche"
replace loan_type="revolver" if loan_type=="revolver/line < 1 yr."
replace loan_type="revolver" if loan_type=="revolver/line >= 1 yr."
replace loan_type="letter of credit" if loan_type=="performance standby letter of credit"
replace loan_type="letter of credit" if loan_type=="standby letter of credit"
replace loan_type="letter of credit" if loan_type=="trade letter of credit"
replace loan_type="term loan" if loan_type=="delay draw term loan"
replace loan_type="term loan" if loan_type=="term loan e"
replace loan_type="term loan" if loan_type=="term loan f"
replace loan_type="term loan" if loan_type=="term loan g"
replace loan_type="term loan" if loan_type=="term loan h"
replace loan_type="term loan" if loan_type=="term loan i"
replace loan_type="term loan" if loan_type=="term loan j"
replace loan_type="term loan" if loan_type=="term loan k"

contract packageid facilityid borrowerid loan_type maturity_date issuer issuer_3wrds_dealscan 
drop _f
gen constant2=1
sort issuer loan_type maturity_date
save "F:\facilityid_small.dta",replace 





* Note:  We check the accuracy of non-exact matches and manually clean false matches. 

* First, try exact match by issuer loan type and maturity 
use "F:\holdingsTOTAL_small.dta"
merge issuer loan_type maturity_date using "F:\facilityid_small.dta"
drop _m
drop if constant==.
drop if constant2==.
drop constant constant2
sort collateral_id
drop issuer loan_type maturity_date  issuetypeminor issuer_3wrds_cloi  issuer_3wrds_dealscan
save "F:\match_exact.dta", replace


* Exclude exact matches before attempting additional matches
use "F:\holdingsTOTAL_small.dta"
sort collateral_id
merge collateral_id using "F:\match_exact.dta"
drop _m
drop if packageid!=.
rename issuer_3wrds_cloi issuer_3wrds
rename issuer issuer_cloi
sort issuer_3wrds loan_type maturity_date
save "F:\remaining1.dta",replace 
use "F:\facilityid_small.dta"
rename issuer_3wrds_dealscan issuer_3wrds
rename issuer issuer_dealscan
sort issuer_3wrds loan_type maturity_date
save,replace



* In our second attempt, we match CLOi and DealScan by the first three words of the issuer, loan type, and maturity  
use "F:\remaining1.dta"
sort issuer_3wrds loan_type maturity_date
merge issuer_3wrds loan_type maturity_date using "F:\facilityid_small.dta"
drop _m
drop if constant==.
drop if constant2==.
sort collateral_id
drop issuer_cloi issuer_dealscan loan_type maturity_date  issuetypeminor  issuer_3wrds 
save "F:\match_issuer3wrds_type_maturity.dta", replace

*As before, exclude these matches before attempting additional matches
use "F:\remaining1.dta"
sort collateral_id
merge collateral_id using "F:\match_issuer3wrds_type_maturity.dta"
drop _m
drop if packageid!=.
sort issuer_3wrds  maturity_date
rename loan_type loan_type_cloi
save "F:\remaining2.dta"
use "F:\facilityid_small.dta"
sort issuer_3wrds maturity_date
rename loan_type loan_type_dealscan
save,replace

* In our third match attempt, we match CLOi and DealScan by the first three words of the issuer and maturity  
use "F:\remaining2.dta"
sort issuer_3wrds maturity_date
merge issuer_3wrds maturity_date using "F:\facilityid_small.dta"
drop _m
drop if constant==.
drop if constant2==.

* Condition on term loans 
keep if loan_type_cloi=="term loan"
drop if loan_type_dealscan=="revolver"
drop if loan_type_dealscan=="letter of credit"
drop if loan_type_dealscan=="364-day facility" 

drop loan_type_* issuer_3wrds maturity_date issuetypeminor issuer_cloi issuer_dealscan
sort collateral_id
save "F:\match_issuer3wrds_maturity.dta"

use "F:\remaining2.dta"
sort collateral_id
merge collateral_id using "F:\match_issuer3wrds_maturity.dta"
drop _m
drop if packageid!=.
rename loan_type_cloi loan_type
rename maturity_date maturity_date_cloi 
sort issuer_3wrds  loan_type
save "F:\remaining3.dta", replace
use "F:\facilityid_small.dta"
rename loan_type_dealscan loan_type
rename maturity_date maturity_date_dealscan
sort issuer_3wrds loan_type
save,replace

* Append the first three merged datasets
use "F:\match_issuer3wrds_maturity.dta"
append using "F:\match_issuer3wrds_type_maturity.dta"
append using "F:\match_exact.dta"
save "F:\CLOi_DealScan_1_3.dta"

*Note:  At this stage, we manually clean the dataset (F:\CLOi_DealScan_1_3.dta) by comparing borrower names (between CLOi and DealScan), loan types, industry and maturities

* In our fourth match attempt, we match CLOi and DealScan by i) the first three words of the issuer and loan_type & ii) let maturity fluctuate by +/-30 days between CLOi and DealScan
use "F:\remaining3.dta"
sort issuer_3wrds  loan_type
joinby issuer_3wrds  loan_type using "F:\facilityid_small.dta"
drop if constant==.
drop if constant2==.
gen dif=abs(maturity_date_dealscan-maturity_date_cloi)
drop if dif>30
drop loan_type issuer_3wrds maturity_date* issuetypeminor issuer_cloi issuer_dealscan
contract collateral_id packageid facilityid borrowerid
drop _f
sort collateral_id 
save "F:\match_issuer3wrds_loantype.dta", replace

*Note:  Again, we manually clean the dataset (F:\match_issuer3wrds_loantype.dta)

use "F:\remaining3.dta"
sort collateral_id
merge collateral_id using "F:\match_issuer3wrds_loantype.dta"
drop _m
drop if packageid!=.
rename maturity_date_cloi maturity_date 
gen cloi=1
drop constant
rename issuer_cloi issuer
save "F:\remaining4.dta", replace

use "F:\facilityid_small.dta"
rename maturity_date_dealscan  maturity_date 
rename issuer_dealscan issuer
gen dealscan=1
drop constant
save,replace

* As a final approach to obtaining clean matches, to account for abbreviated borrower names, we manually identify any potential remaining matches between CLO-i and Dealscan in Excel. We then append files to create 
* a sample of loans that are identified in CLOi and Dealscan


*******************************************************************************************
*  Step 1B: Merge CLO holdings and CLO performance data (data version: as of June 2013)  
*******************************************************************************************

* Bring in CLO performance data
use  "F:\CLOperformance.dta",replace 


collapse senior_oc junior_oc ccc_bucket defaultpct, by (deal reporting_month)
sort deal reporting_month
save "F:\CLOperformance_month.dta"

use  "F:\holdingsTOTAL.dta",replace 
sort deal reporting_month
merge  deal reporting_month using "F:\CLOperformance_month.dta"
drop _m

gen senior_oc_score=senior_oc_threshold+senior_oc
gen junior_oc_score=junior_oc_threshold+junior_oc

gen senior_oc_scorelog=log(1+senior_oc_score)
save,replace


****************************************************************
*  Step 2: Identify syndicated loans securitized at origination
****************************************************************

* We manually search in DealScan's lendershares file in Excel for lenders whose name includes the term "CLO", "CDO", "CBO", "ABS", "MBS", "Corporate loan obligation", or "Collateralized Debt Obligation".
* We also look whether the names of the CLO deals in the CLO-i dataset are included in the loan's orginal syndicate. We mark these loans as securitized at origination.
* These packages are appended in "F:\securitized_packages.dta" (securitized==1) with an additional identifier at_origination==1.
 

*******************************************************************************************************************************************************************************************************
*  Step 3: Match securitized loan sample to Chava and Roberts' Dealscan-Compustat database (downloaded in June 2013) by facilityid and/or packageid.
*          Obtain the loan contracts from SEC EDGAR. 
*******************************************************************************************************************************************************************************************************


***************************************************************************************
*  Step 4: Identify a matched sample of non-securitized institutional loans in DealScan.
*	       Obtain the loan contracts from SEC EDGAR. 
***************************************************************************************

use "F:\facilityid.dta"
sort packageid
merge packageid using "F:\securitized_packages.dta"
drop if securitized==1
drop _m
drop securitized
rename LoanType loan_type
drop if loan_type==""
replace loan_type=lower(loan_type)
replace loan_type=trim(loan_type) 

rename FacilityEndDate maturity_date
format maturity_date %td
drop if maturity_date==.
drop if Company==""
keep if Country=="USA"

* Drop loans originated before 2000 and after 2009 to match the securitized loan sample
drop if year_origination>2009
drop if year_origination<2000

* Keep tranches term loan B-H that are likely sold to institutional investors
gen institutional=0
replace institutional=1 if loan_type=="term loan b"
replace institutional=1 if loan_type=="term loan c"
replace institutional=1 if loan_type=="term loan d"
replace institutional=1 if loan_type=="term loan e"
replace institutional=1 if loan_type=="term loan f"
replace institutional=1 if loan_type=="term loan g"
replace institutional=1 if loan_type=="term loan h"

save "F:\facilityid_nonsecuritized.dta"

* Bring in Dealscan's market segment data
use "F:\mkt_segment.dta"
rename marketsegment market_segment
replace market_segment=lower(market_segment)
gen institutional_mkt=0
replace institutional_mkt=1 if market_segment=="leveraged"
replace institutional_mkt=1 if market_segment=="highly leveraged"
replace institutional_mkt=1 if market_segment=="institutional"
replace institutional_mkt=1 if market_segment=="lbo"
replace institutional_mkt=1 if market_segment=="non-investment grade"
replace institutional_mkt=1 if market_segment=="non investment grade"
collapse institutional_mkt, by(facilityid)
replace institutional_mkt=1 if institutional_mkt!=0
sort facilityid
save "F:\mkt_segment.dta", replace

use "F:\facilityid_nonsecuritized.dta"
gen constant=1
sort facilityid
merge facilityid using "F:\mkt_segment.dta"
drop _m
drop if constant==.
drop constant
replace institutional=1 if institutional_mkt==1 & loan_type=="term loan"
replace institutional=1 if institutional_mkt==1 & loan_type=="revolver/term loan"
replace institutional=1 if allindrawn>=250 & loan_type=="term loan" &allindrawn!=.
replace institutional=1 if allindrawn>=250 & loan_type=="revolver/term loan" &allindrawn!=.

* Drop loans with no institutional tranche
bysort packageid: egen total=total(institutional)
drop if total==0
drop total

* Drop loans with small institutional tranches
gen institutional_money=0
replace  institutional_money=FacilityAmount if institutional==1
bysort packageid: egen institutional_money_total=total(institutional_money)
bysort packageid: egen deal_amount=total(FacilityAmount)
gen institutionalpct=institutional_money_total/deal_amount
drop if institutionalpct<0.5

* Drop private firms
drop if gvkey==""
contract packageid 
drop _f
save "F:\facilityid_nonsecuritized_controlsample.dta"

use "F:\securitized_packages.dta"
append using "F:\facilityid_nonsecuritized_controlsample.dta"
replace securitized=0 if securitized==.
sort packageid
save "F:\securitized_institutional_packages.dta"


***************************************************************************************************************************************************** 
*  Step 5: Hand collect and group the complete financial covenant definitions from loan contracts in 12 categories following DealScan categorization.
***************************************************************************************************************************************************** 


***************************************************************************************************
*  Step 6: Calculate the Covenant Similarity Score of the financial covenant definitions and merge.
***************************************************************************************************

*Bring in Covenant Similarity Scores
use "F:\covenant_similarity_score_pairs.dta"

drop if packageid1==packageid2
drop if facilityid1==facilityid2
drop if borrowerid1==borrowerid2
drop if covenant_type1!=covenant_type2
gen dif=loan_origination_date1-loan_origination_date2
drop if dif<0
drop if dif>360
collapse covenant_similarity, by(packageid1)
rename packageid1 packageid
sort packageid
save "F:\covenant_similarity_score.dta"


**************************************************************************************************************
*  Step 7: Key variables for our loan sample and main analysis (Table 5 and Table 6)
**************************************************************************************************************

* Bring in DealScan's packageid dataset 
use "F:\packageid.dta"

/* We construct our control variables using the following files from DealScan CD: packageid, facilityid, lendershares, market segment. Number of covenants are directly estimated from the contracts/SEC filings.
We use Loan Connector to retrieve whether a loan is secured or whether a loan is rated (Initial Rating is not missing).
After merging these files, the key independent variables are:*/

* Loan amount (from packageid)*
gen dealamountlog=log(DealAmount)


* All-in-drawn, revolving tranche and loan maturity *
use "F:\facilityid.dta"
rename FacilityEndDate maturity_date
rename FacilityStartDate origination_date
gen maturity_fac=(maturity_date-origination_date)/12
bysort packageid: egen maturity=max(maturity_fac)
bysort packageid: egen allindrawnm=mean(allindrawn)
drop allindrawn 
rename allindrawnm allindrawn
gen revolver=0
replace revolver=1 if LoanType=="Revolver/Line < 1 Yr."
replace revolver=1 if LoanType=="Revolver/Line >= 1 Yr."
replace revolver=1 if LoanType=="Revolver/Term Loan"
bysort packageid: egen revolverm=total(revolver)
replace revolverm=1 if revolverm!=0
drop revolver
rename revolverm revolver
collapse revolver maturity allindrawn, by(packageid)
gen maturitylog=log(maturity)
gen allindrawnlog=log(allindrawn)
sort packageid
save "F:\packageid_add.dta"
 

* Number of co-syndicates *
use "F:\lendershares.dta"
drop if lead_bank==1
contract lenderid packageid
drop _f
gen var=1
bysort packageid: egen syndicates=total(var)
collapse syndicates, by(packageid)
gen syndicateslog=log(syndicates)
sort pack
use "F:\syndicates.dta"

* Lending relationship variable
use "F:\packageid.dta"
gen var=1
sort packageid 
merge packageid using "F:\leadid.dta"
drop _m
drop if var==.
gen match=string(borrowerid)+"/"+string(lenderid)
gen relation=0
sort match loan_origination_date
by match: replace relation=relation+DealAmount[_n-1] if loan_origination_date-loan_origination_date[_n-1]<1800
by match: replace relation=relation+DealAmount[_n-2] if loan_origination_date-loan_origination_date[_n-2]<1800
* and we repeat the loop going backwards till no replace

sort borrowerid loan_origination_date
gen capital_raised=0
by borrowerid: replace capital_raised=capital_raised+DealAmount[_n-1] if loan_origination_date-loan_origination_date[_n-1]<1800
by borrowerid: replace capital_raised=capital_raised+DealAmount[_n-2] if loan_origination_date-loan_origination_date[_n-2]<1800
* and we repeat the loop going backwards till no replace
gen prior_relation=relation/capital_raised


* After merging with our loan sample "F:\similarity_loan.dta" by packageid, the variables are winsorized at the 1% 



* Bring in Compustat data
use "F:\compustat.dta"
rename at assets
gen assetslog=log(assets)
rename act current_assets
rename  lct current_liabilities
gen liquidity=current_assets/current_liabilities
rename  oiadp oper_inc
gen roa=oper_inc/assets
rename oancf oper_cash
sort gvkey year
by gvkey: gen oper_cashlag1=oper_cash[_n-1]
by gvkey: gen oper_cashlag2=oper_cash[_n-2]
by gvkey: gen oper_cashlag3=oper_cash[_n-3]
by gvkey: gen oper_cashlag4=oper_cash[_n-4]
by gvkey: gen oper_cashlag5=oper_cash[_n-5]
egen std_cfo=rowsd(oper_cashlag1 oper_cashlag2 oper_cashlag3 oper_cashlag4 oper_cashlag5)
gen std_cfodefl=std_cfo/assets
rename dltt ltd
gen debt=ltd/assets
destring sic, force replace
sort gvkey year
save,replace
* Note: sic codes were used to derive FF12 classifications  


use "F:\similarity_loan.dta"
sort gvkey year
merge gvkey year using "F:\compustat.dta"
drop _m
drop if var==.
drop  var
* After merging with our loan sample "F:\similarity_loan.dta" by packageid, the variables are winsorized at the 1% 


save,replace
 
 
*************************************************************************************
*  Step 8: Dataset and Key variables for our CLO-quarter sample (Table 5 and Table 7)
*************************************************************************************

* Industry diversification
use "F:\holdingsTOTAL.dta"
gen count=1
bysort deal reporting_month: egen total_loans=total(count)

* Industry is Moody's industry provided by Creditflux// Data are at the CLO-month level
bysort deal reporting_month industry: egen total_industry =total(count)

gen industry_ratio=total_industry/total_loans
bysort deal reporting_month: egen industry_divers=sd(industry_ratio)

* Average loan amount held
gen loan_ratio=balance/CLO_balance
bysort deal reporting_month: egen loan_ratiom=mean(loan_ratio)

* Average at the CLO-quarter level
collapse industry_divers loan_ratiom sp_rating defaultpct senior_oc_scorelog CLO_balance, by(deal reporting_quarter)
rename reporting_quarter quarter
gen CLO_balancelog=log(CLO_balance)
sort deal quarter
by deal: gen industry_diverslag=industry_divers[_n-1]
by deal: gen loan_ratiomlag=loan_ratiom[_n-1]
by deal: gen sp_ratinglag=sp_rating[_n-1]
by deal: gen defaultpctlag=defaultpct[_n-1]
by deal: gen senior_oc_scoreloglag=senior_oc_scorelog[_n-1]
by deal: gen CLO_balancelag=CLO_balancelog[_n-1]
save "F:\CLO_quarter.dta"

use "F:\holdingsTOTAL.dta"
rename reporting_quarter quarter
drop if covenant_similarity==.
collapse covenant_similarity, by(deal quarter)
rename covenant_similar portfolio_similarity
sort deal quarter
by deal: gen portfolio_similarlag=portfolio_similarity[_n-1]
save "F:\avg_sim.dta"
* After merging with CLO performance by CLO-quarter, the variables are winsorized at the 1% 


save,replace

* CLO portfolio turnover
use "F:\CLO_trades.dta"
format trade_date %td
gen trade_month=mofd(trade_date)
gen quarter=qofd(trade_date)

bysort deal quarter: egen total_trades=total(face_amt)
collapse total_trades, by(deal quarter)
sort deal quarter
by deal: gen total_tradeslag=total_trades[_n-1]
save "F:\CLO_trades2.dta", replace
use "F:\CLO_quarter.dta"
sort deal quarter
merge deal quarter using "F:\CLO_trades2.dta"
gen CLO_turnoverlag=total_tradeslag/CLO_balancelag
replace CLO_turnoverlag=0 if CLO_turnoverlag==.
save,replace


************************
*  Additional Variables
************************

* Highly securitized loan
use "F:\holdingsTOTAL.dta"
drop if packageid==.
bysort packageid reporting_month: egen total=total(balance)
collapse total, by(packageid)
sort packageid
merge packageid using "F:\DealAmt.dta"
gen securitized_ratio=total/DealAmt
collapse securitized_ratio, by(packageid)
egen median=median(securitized_ratio)
gen highly_securitized=0
replace highly_securitized=1 if securitized_ratio>=median

* Securitized loan with high bank ownership
use "F:\facilityid.dta"
gen bank=0
replace bank=1 if LoanType=="Revolver/Line < 1 Yr."
replace bank=1 if LoanType=="Revolver/Line >= 1 Yr."
replace bank=1 if LoanType=="Term Loan A"
replace bank=1 if market_segment=="middle market"  
replace bank=1 if market_segment=="investment grade"  
replace bank=1 if allindrawn<=180 & market_segment==""
gen bank_tranche=0
replace bank_tranche=FacilityAmt if bank==1
bysort packageid: egen bank_tranche_total=total(bank_tranche)
bysort packageid: egen total=total(FacilityAmount)
gen bank_ratio=bank_tranche_t/total
collapse bank_ratio, by(packageid)
sort packageid
merge packageid using "F:\securitized_packages.dta"
drop if securitized==.
drop if securitized==0
gen highly_bank=0
egen median=median(bank_ratio)
replace highly_bank=1 if bank_ratio>=median

* Same loan rating
use "F:\holdingsTOTAL.dta"
gen same_rating=0
replace same_rating=1 if sp_ratingl==moodys_ratingl
gen rating_dif=abs(moodys_ratingl-sp_ratingl)
drop if packageid==.
rename reporting_year year
collapse same_rating rating_dif, by(packageid year)
