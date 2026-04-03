*********************************************************************************************************************************************************
*
*  Enhancing Loan Quality through Transparency: Evidence from the European Central Bank Loan Level Reporting Initiative
*
*  Aytekin Ertan, Maria Loumioti and Regina Wittenberg Moerman
*
*  This do-file shows the code for converting ED SME loan raw data (version: June 4-6 2014) to the loan sample used in the analyses 
*
*********************************************************************************************************************************************************
*
*  Please refer to the attached SME Data Template for more details on dataset content and variable names
*
*********************************************************************************************************************************************************

 
********************************************************************************
*  I. Read and clean key ED SME loan items 
********************************************************************************

use "F:\SME_loans.dta",replace 

* Data submission date; As1 manually cleaned (e.g., when bank names were entered together with the data submission date)
gen pool_cutoff_date = date(as1, "YMD")
gen pool_cutoff_month=month(pool_cutoff_date)
gen pool_cutoff_day=day(pool_cutoff_date)
gen pool_cutoff_year=year(pool_cutoff_date)

/* Reporting date by quarter may not be the same across all banks. Most banks typically report at the beginning of a calendar quarter, but some banks report just before the quarter starts. 
To alleviate this reporting mismatch across banks, we match loans to the reporting quarter if they are reported before the calendar quarter’s start date. 
For example, if the pool_cutoff_date is Dec 20 2012 (June 30 2013), these observations are matched to the reporting quarter Q1 of 2013 (the reporting quarter Q3 of 2013).
We fix these reporting differences by bank manually, but the process could be summarized as follows*/

replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==12 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==3 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==6 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==9 &pool_cutoff_day>15 &pool_cutoff_day<=31


format pool_cutoff_date %td
gen pool_cutoff_quarter=qofd(pool_cutoff_date)
format pool_cutoff_quarter %tq

* ABS name; ABS names are cleaned manually 
rename as2 pool_id
replace pool_id=lower(pool_id)
encode pool_id, gen(pool_idl)

* Unique loan id by poolid
rename as3 loan_id

* Issuing bank name; bank names are cleaned manually
rename as4 lender
replace lender=lower(lender)
replace lender=trim(lender)

* Servicer bank which is mostly the issuing bank. Servicer names and servicer ids (sometimes the bank name) are also cleaned manually 
rename as5 servicer_id
rename as6 servicer_name
replace servicer_name=lower(servicer_name)
replace servicer_name=trim(servicer_name)

 
rename as7 borrower_id
rename as15 borrower_country

rename as18 borrower_type
replace borrower_type="" if regexm(borrower_type, "ND")==1
destring borrower_type, force replace
replace borrower_type=5 if borrower_type==.

rename as25 asset_type

rename as42 borrower_industry_long
replace borrower_industry_long="" if regexm(borrower_industry_long, "ND")==1
gen borrower_industry=substr(borrower_industry_long, 1, 1) 
replace borrower_industry="22" if borrower_industry==""
encode borrower_industry, gen(borrower_industryl)


rename as26 seniority 
destring seniority, force replace

rename as65 loan_type
destring loan_type, force replace
replace loan_type=3 if loan_type==.

rename as37 loss_given_default 
destring loss_given_default, force replace 
  

* Origination and maturity dates are in string(YYYY-MM) format. We format these in %td as follows:
rename as50 loan_origination_date
split loan_origination_date, p(“-“)
destring loan_origination_date1, force replace
destring loan_origination_date2, force replace
rename loan_origination_date1 year
rename loan_origination_date2 month
gen day=1
gen loan_origination_datel=mdy(month, day, year)
drop loan_origination_date day year month
rename loan_origination_datel loan_origination_date
format loan_origination_date %td
gen year_origination=yofd(loan_origination_date)
gen quarter_origination=qofd(loan_origination_date)

rename as51 loan_maturity_date
split loan_maturity_date, p(“-“)
destring loan_maturity_date1, force replace
destring loan_maturity_date2, force replace
rename loan_maturity_date1 year
rename loan_maturity_date2 month
gen day=1
gen loan_maturity_datel=mdy(month, day, year)
drop loan_maturity_date day year month
rename loan_maturity_datel loan_maturity_date
format loan_maturity_date %td
gen year_maturity=yofd(loan_maturity_date)


rename as54 original_loan_amount
destring original_loan_amount, force replace
rename as55 current_loan_balance
destring current_loan_balance, force replace 
rename as56 securitized_amount
destring securitized_amount, force replace



* Some loan amounts are negative, which are considered an error given that these are less than 1% of the population
replace current_loan_balance=abs(current_loan_balance)
replace original_loan_amount=abs(original_loan_amount)
replace securitized_amount=abs(securitized_amount)



rename as57 loan_purpose
destring loan_purpose, force replace


rename as80 interest_rate
destring interest_rate, force replace 

rename as123 default_reason
rename as125 default_amount
destring default_amount, force replace 
replace default_amount=abs(default_amount)

rename as115 interest_arrears_amount_string
rename as117 principal_arrears_amount_string
destring interest_arrears_amount_string, gen(interest_arrears_amount)
destring principal_arrears_amount_string,  gen(principal_arrears_amount)

* Some loan amounts are negative, which are considered an error given that these are less than 1% of the population
replace interest_arrears_amount=abs(interest_arrears_amount)
replace principal_arrears_amount=abs(principal_arrears_amount)


rename as116 interest_arrears_days_string
rename as118 principal_arrears_days_string
destring interest_arrears_days_string, gen(interest_arrears_days)
destring principal_arrears_days_string, gen (principal_arrears_days)

* Some loan days are negative, which are considered an error given that these are less than 1% of the population
replace interest_arrears_days=abs(interest_arrears_days)
replace principal_arrears_days=abs(principal_arrears_days)





********************************************************************************
*  II. Impose sample restrictions 
********************************************************************************

* Focus on loans; drop guarantees, participation rights, overdrafts etc. for consistency. 95%+ of our data are loans
keep if asset_type=="1"



* Over 99.99% of the loans are not hedged; remove those coded as hedged loans
keep if as53=="N"



* Drop potentially erroneous data
/* As described above, when lender/ABS is populated by a code/number, if possible we manually replace these codes with the relevant unique name. 
ABS and lenders that cannot be uniquely identified are manually dropped. We also identify missing bank names looking at the servicer id or pool id/name*/


drop if lender==""  &servicer_name==""
replace lender=servicer_name if lender==""
 
* Several banks submitted loan data (incomplete) to test the new reporting software in May/June 2012 
drop if pool_cutoff_year==2012



* Drop very small SME loans
drop if original_loan_amount<1000


* When missing, we consider that current/securitized loan balance = loan original balance if the loan is issued in the same quarter
replace current_loan_balance=original_loan_amount if current_loan_balance==. & quarter_origination==pool_cutoff_quarter
replace securitized_amount=original_loan_amount if securitized_amount==. & quarter_origination==pool_cutoff_quarter
drop if current_loan_balance==.
drop if securitized_amount==.


* When missing, continuous values can also be assigned 999 (primarily for interest rate, loss given default) or values greater than 100000000 (primarily for loan amts)
drop if original_loan_amount>=100000000
drop if securitized_amount>=100000000
drop if current_loan_balance>=100000000
drop if current_loan_balance==0
* Securitized loan amount may be 0 if the loan was not securitized upfront
 
* Drop potentially erroneous data entries
drop if securitized_amount>original_loan_amount
drop if current_loan_balance>original_loan_amount
 



* Drop potentially erroneous data loan dates
drop if loan_origination_date==.
drop if loan_maturity_date==.
gen year_origination=yofd(loan_origination_date)
drop if year_origination>2014

* Exclude loans issues during the European credit bubble
drop if year_origination<2009



* Drop potentially erroneous maturity dates; 99.9% of the loans mature before 2053
gen year_maturity=yofd(loan_maturity_date)
drop if year_maturity>2053
* There are about 1000 obs (out of about 3m) with loans that mature in 2012. Since some banks reported in late December 2012, we keep these obs.
drop if year_maturity<2012


* Drop potentially erroneous data entries
drop if loan_origination_date>loan_maturity_date


* Drop potentially erroneous data entries; making sure that interest rates are expressed as % across all loans; drop if interest rate>15% (missing or erroneous), upper 99% of interest rate is at 10.38%  
drop if interest_rate==0
replace interest_rate=interest_rate*100 if interest_rate<1
replace interest_rate=. if interest_rate<1 | interest_rate>15
drop if interest_rate==.

* Drop potentially erroneous data entries; lgd cannot be greater than 100. This cutoff primarily takes care of lgd missing values labeled as 999.99
replace loss_given_default=loss_given_default*100 if loss_given_default>0 & loss_given_default<=1
drop if loss_given_default>100  


* ND,5 classification refers to data not relevant at the present time, i.e. no arrears or defaults are relevant at the present time
replace interest_arrears_amount=0 if interest_arrears_amount==. &interest_arrears_amount_string=="ND,5"
replace principal_arrears_amount=0 if principal_arrears_amount==. &principal_arrears_amount_string=="ND,5"
replace interest_arrears_days=0 if interest_arrears_days==. &interest_arrears_days_string=="ND,5"
replace principal_arrears_days=0 if principal_arrears_days==. &principal_arrears_days_string=="ND,5"


* Drop potentially erroneous data entries
drop if interest_arrears_amount>= 100000000
drop if principal_arrears_amount>= 100000000
drop if interest_arrears_days>=10000
drop if principal_arrears_days>=10000




* Over 99.99% of the loans are from the countries below
keep if borrower_country=="BE" | borrower_country=="DE" | borrower_country=="ES" | borrower_country=="FR" | borrower_country=="IT" | borrower_country=="NL" | borrower_country=="PT"





* We drop lenders with very few obs. (<1000)
gen var=1
bysort lender: egen total=total(var)
drop if total<=1000

* Adoption quarter
bysort lender: egen adoption_quarter=min(pool_cutoff_quarter)


* We finally drop duplicates keeping the most complete data entry by poolid loanid borrowerid lender reporting quarter
 



**************************************************************************************************************
*  III. Calculate key variables 
**************************************************************************************************************

* Defaults*

gen in_default=0
replace in_default=1 if regexm(as121, "Y")==1
replace in_default=1 if regexm(as122, "Y")==1
* if as121 or as122= ND,5 in_default is zero
* 95%+ of the defaulted loans are classified as above. we further do 2 minor adjustments:
* if a loan is in default for more than 2 years, the loan is considered in default even if as121 or as122 is missing (ND) or N 
replace in_default=1 if interest_arrears_days>720 & principal_arrears_days>720
* if the default amount is not missing, the loan is considered in default even if as121 or as122 is missing (ND) or N 
replace in_default=1 if default_amount!=0 &default_amount!=. &default_amount<100000000


 
 
* Delinquent amount*
* Very extreme values in interest and principal arrears amount continue to exist in our sample (despite the above sample restrictions) and are winsorized before we calculate the ratio
winsor interest_arrears_amount, gen(interest_arrears_amountw) p(0.01)
winsor principal_arrears_amount, gen(principal_arrears_amountw) p(0.01)
winsor current_loan_balance, gen(current_loan_balancew) p(0.01)
gen delinquent_amt=(interest_arrears_amountw+principal_arrears_amountw)/current_loan_balancew
replace delinquent_amt=delinquent_amt*100
winsor delinquent_amt, gen(delinquent_amtw) p(0.01)



* Number of days in delinquency*
* In 99% of non-zero deliquent days, interest_arrears_days= principal_arrears_days
egen delinquent_daysmean=rowmean(interest_arrears_days principal_arrears_days)
egen delinquent_days=log(1+delinquent_daysmean)
winsor delinquent_days, gen(delinquent_daysw) p(0.01)



* Loss given default*
replace loss_given_default=loss_given_default/100
winsor loss_given_default, gen(loss_given_defaultw) p(0.01)





* Main independent variable

* Tranparency*
gen transparency=0
replace transparency=1 if quarter_origination>=adoption_quarter





* Controls
winsor interest_rate, gen(interest_ratew) p(0.01)

gen secured=0
replace secured=1 if seniority==1
* For collateral, the variable "seniority" in the loan data sample is incomplete. We use the "Collateral" dataset of ED where we identified whether a loan in a pool is collateralized. The SME_collateral.dta is a dataset that includes whether a loan is included in this dataset
sort loan_id pool_id
merge loan_id pool_id using "F:\SME_collateral.dta"
drop if var==.
drop _m
replace secured=1 if collateral==1
drop collateral
 
 
* Securitized loan amount is static thus we deflate by original loan amount 
gen securitized_amount_defl=securitized_amount/original_loan_amount
winsor securitized_amount_defl, gen(securitized_amount_deflw) p(0.01)

gen yrs_to_maturity=(loan_maturity_date-pool_cutoff_date)/360
gen years_to_maturity=log(1+yrs_to_maturity)
winsor years_to_maturity, gen(years_to_maturityw) p(0.01)

save summary_sme_loans, replace




/* For prior lending relationships, the variable "Obligor is a Customer since?" (as20) is incomplete. 
We structure our lending relationship variable. To do so, we use the full dataset without sample restrictions. No loop is necessary because prior relations are not common.*/

{use "F:\SME_loans.dta"
contract lender borrower_id year_origination
gen borrower_lender=string(borrower_id)+"/"+string(lender)
sort borrower_lender year_origination
gen prior_relation=0
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-1]<=5 &year_origination[_n-1]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-2]<=5 &year_origination[_n-2]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-3]<=5 &year_origination[_n-3]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-4]<=5 &year_origination[_n-4]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-5]<=5 &year_origination[_n-5]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-6]<=5 &year_origination[_n-6]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-7]<=5 &year_origination[_n-7]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-8]<=5 &year_origination[_n-8]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-9]<=5 &year_origination[_n-9]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-10]<=5 &year_origination[_n-10]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-11]<=5 &year_origination[_n-11]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-12]<=5 &year_origination[_n-12]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-13]<=5 &year_origination[_n-13]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-14]<=5 &year_origination[_n-14]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-15]<=5 &year_origination[_n-15]!=.
drop  borrower_lender 
sort borrower_id lender year_origination
save relation.dta 
}


sort borrower_id lender year_origination
merge borrower_id lender year_origination using relation.dta
drop if var==.
drop _m
save,replace




* Fixed effects

gen loan_purposel=.
replace loan_purposel=1 if loan_purpose==12
replace loan_purposel=2 if loan_purpose==1 | loan_purpose==3 | loan_purpose==5 | loan_purpose==6 | loan_purpose==11
replace loan_purposel=3 if loan_purpose==2 | loan_purpose==4 | loan_purpose==7 | loan_purpose==8 | loan_purpose==9 | loan_purpose==10
replace loan_purposel=4 if loan_purpose==13  
replace loan_purposel=4 if missing(loan_purpose)



save summary_sme_loans, replace

 
**************************************************************************************************************
* IV. Table 3, Panel A and B: Baseline regressions 
**************************************************************************************************************


* Panel A
reg delinquent_amtw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

reg delinquent_daysw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

reg loss_given_defaultw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

probit in_default transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation brtp_* tp_* qt_* pur_* ind_* abs_*, r cluster (pool_idl)
mfx


* Panel B

gen quarter_origination=qofd(loan_origination_date)
format quarter_origination %tq
gen keep=0
replace keep=1 if quarter_origination==212 
replace keep=1 if quarter_origination==213

reg delinquent_amtw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

reg delinquent_daysw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

reg loss_given_defaultw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

probit in_default transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation brtp_* tp_* qt_* pur_* ind_* abs_* if keep==1, r cluster (pool_idl)
mfx

* For Panel C, we manually identified banks that borrowed from ECB ABS repo before 2013Q1
*********************************************************************************************************************************************************
*
*  Enhancing Loan Quality through Transparency: Evidence from the European Central Bank Loan Level Reporting Initiative
*
*  Aytekin Ertan, Maria Loumioti and Regina Wittenberg Moerman
*
*  This do-file shows the code for converting ED SME loan raw data (version: June 4-6 2014) to the loan sample used in the analyses 
*
*********************************************************************************************************************************************************
*
*  Please refer to the attached SME Data Template for more details on dataset content and variable names
*
*********************************************************************************************************************************************************

 
********************************************************************************
*  I. Read and clean key ED SME loan items 
********************************************************************************

use "F:\SME_loans.dta",replace 

* Data submission date; As1 manually cleaned (e.g., when bank names were entered together with the data submission date)
gen pool_cutoff_date = date(as1, "YMD")
gen pool_cutoff_month=month(pool_cutoff_date)
gen pool_cutoff_day=day(pool_cutoff_date)
gen pool_cutoff_year=year(pool_cutoff_date)

/* Reporting date by quarter may not be the same across all banks. Most banks typically report at the beginning of a calendar quarter, but some banks report just before the quarter starts. 
To alleviate this reporting mismatch across banks, we match loans to the reporting quarter if they are reported before the calendar quarter’s start date. 
For example, if the pool_cutoff_date is Dec 20 2012 (June 30 2013), these observations are matched to the reporting quarter Q1 of 2013 (the reporting quarter Q3 of 2013).
We fix these reporting differences by bank manually, but the process could be summarized as follows*/

replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==12 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==3 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==6 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==9 &pool_cutoff_day>15 &pool_cutoff_day<=31


format pool_cutoff_date %td
gen pool_cutoff_quarter=qofd(pool_cutoff_date)
format pool_cutoff_quarter %tq

* ABS name; ABS names are cleaned manually 
rename as2 pool_id
replace pool_id=lower(pool_id)
encode pool_id, gen(pool_idl)

* Unique loan id by poolid
rename as3 loan_id

* Issuing bank name; bank names are cleaned manually
rename as4 lender
replace lender=lower(lender)
replace lender=trim(lender)

* Servicer bank which is mostly the issuing bank. Servicer names and servicer ids (sometimes the bank name) are also cleaned manually 
rename as5 servicer_id
rename as6 servicer_name
replace servicer_name=lower(servicer_name)
replace servicer_name=trim(servicer_name)

 
rename as7 borrower_id
rename as15 borrower_country

rename as18 borrower_type
replace borrower_type="" if regexm(borrower_type, "ND")==1
destring borrower_type, force replace
replace borrower_type=5 if borrower_type==.

rename as25 asset_type

rename as42 borrower_industry_long
replace borrower_industry_long="" if regexm(borrower_industry_long, "ND")==1
gen borrower_industry=substr(borrower_industry_long, 1, 1) 
replace borrower_industry="22" if borrower_industry==""
encode borrower_industry, gen(borrower_industryl)


rename as26 seniority 
destring seniority, force replace

rename as65 loan_type
destring loan_type, force replace
replace loan_type=3 if loan_type==.

rename as37 loss_given_default 
destring loss_given_default, force replace 
  

* Origination and maturity dates are in string(YYYY-MM) format. We format these in %td as follows:
rename as50 loan_origination_date
split loan_origination_date, p(“-“)
destring loan_origination_date1, force replace
destring loan_origination_date2, force replace
rename loan_origination_date1 year
rename loan_origination_date2 month
gen day=1
gen loan_origination_datel=mdy(month, day, year)
drop loan_origination_date day year month
rename loan_origination_datel loan_origination_date
format loan_origination_date %td
gen year_origination=yofd(loan_origination_date)
gen quarter_origination=qofd(loan_origination_date)

rename as51 loan_maturity_date
split loan_maturity_date, p(“-“)
destring loan_maturity_date1, force replace
destring loan_maturity_date2, force replace
rename loan_maturity_date1 year
rename loan_maturity_date2 month
gen day=1
gen loan_maturity_datel=mdy(month, day, year)
drop loan_maturity_date day year month
rename loan_maturity_datel loan_maturity_date
format loan_maturity_date %td
gen year_maturity=yofd(loan_maturity_date)


rename as54 original_loan_amount
destring original_loan_amount, force replace
rename as55 current_loan_balance
destring current_loan_balance, force replace 
rename as56 securitized_amount
destring securitized_amount, force replace



* Some loan amounts are negative, which are considered an error given that these are less than 1% of the population
replace current_loan_balance=abs(current_loan_balance)
replace original_loan_amount=abs(original_loan_amount)
replace securitized_amount=abs(securitized_amount)



rename as57 loan_purpose
destring loan_purpose, force replace


rename as80 interest_rate
destring interest_rate, force replace 

rename as123 default_reason
rename as125 default_amount
destring default_amount, force replace 
replace default_amount=abs(default_amount)

rename as115 interest_arrears_amount_string
rename as117 principal_arrears_amount_string
destring interest_arrears_amount_string, gen(interest_arrears_amount)
destring principal_arrears_amount_string,  gen(principal_arrears_amount)

* Some loan amounts are negative, which are considered an error given that these are less than 1% of the population
replace interest_arrears_amount=abs(interest_arrears_amount)
replace principal_arrears_amount=abs(principal_arrears_amount)


rename as116 interest_arrears_days_string
rename as118 principal_arrears_days_string
destring interest_arrears_days_string, gen(interest_arrears_days)
destring principal_arrears_days_string, gen (principal_arrears_days)

* Some loan days are negative, which are considered an error given that these are less than 1% of the population
replace interest_arrears_days=abs(interest_arrears_days)
replace principal_arrears_days=abs(principal_arrears_days)





********************************************************************************
*  II. Impose sample restrictions 
********************************************************************************

* Focus on loans; drop guarantees, participation rights, overdrafts etc. for consistency. 95%+ of our data are loans
keep if asset_type=="1"



* Over 99.99% of the loans are not hedged; remove those coded as hedged loans
keep if as53=="N"



* Drop potentially erroneous data
/* As described above, when lender/ABS is populated by a code/number, if possible we manually replace these codes with the relevant unique name. 
ABS and lenders that cannot be uniquely identified are manually dropped. We also identify missing bank names looking at the servicer id or pool id/name*/


drop if lender==""  &servicer_name==""
replace lender=servicer_name if lender==""
 
* Several banks submitted loan data (incomplete) to test the new reporting software in May/June 2012 
drop if pool_cutoff_year==2012



* Drop very small SME loans
drop if original_loan_amount<1000


* When missing, we consider that current/securitized loan balance = loan original balance if the loan is issued in the same quarter
replace current_loan_balance=original_loan_amount if current_loan_balance==. & quarter_origination==pool_cutoff_quarter
replace securitized_amount=original_loan_amount if securitized_amount==. & quarter_origination==pool_cutoff_quarter
drop if current_loan_balance==.
drop if securitized_amount==.


* When missing, continuous values can also be assigned 999 (primarily for interest rate, loss given default) or values greater than 100000000 (primarily for loan amts)
drop if original_loan_amount>=100000000
drop if securitized_amount>=100000000
drop if current_loan_balance>=100000000
drop if current_loan_balance==0
* Securitized loan amount may be 0 if the loan was not securitized upfront
 
* Drop potentially erroneous data entries
drop if securitized_amount>original_loan_amount
drop if current_loan_balance>original_loan_amount
 



* Drop potentially erroneous data loan dates
drop if loan_origination_date==.
drop if loan_maturity_date==.
gen year_origination=yofd(loan_origination_date)
drop if year_origination>2014

* Exclude loans issues during the European credit bubble
drop if year_origination<2009



* Drop potentially erroneous maturity dates; 99.9% of the loans mature before 2053
gen year_maturity=yofd(loan_maturity_date)
drop if year_maturity>2053
* There are about 1000 obs (out of about 3m) with loans that mature in 2012. Since some banks reported in late December 2012, we keep these obs.
drop if year_maturity<2012


* Drop potentially erroneous data entries
drop if loan_origination_date>loan_maturity_date


* Drop potentially erroneous data entries; making sure that interest rates are expressed as % across all loans; drop if interest rate>15% (missing or erroneous), upper 99% of interest rate is at 10.38%  
drop if interest_rate==0
replace interest_rate=interest_rate*100 if interest_rate<1
replace interest_rate=. if interest_rate<1 | interest_rate>15
drop if interest_rate==.

* Drop potentially erroneous data entries; lgd cannot be greater than 100. This cutoff primarily takes care of lgd missing values labeled as 999.99
replace loss_given_default=loss_given_default*100 if loss_given_default>0 & loss_given_default<=1
drop if loss_given_default>100  


* ND,5 classification refers to data not relevant at the present time, i.e. no arrears or defaults are relevant at the present time
replace interest_arrears_amount=0 if interest_arrears_amount==. &interest_arrears_amount_string=="ND,5"
replace principal_arrears_amount=0 if principal_arrears_amount==. &principal_arrears_amount_string=="ND,5"
replace interest_arrears_days=0 if interest_arrears_days==. &interest_arrears_days_string=="ND,5"
replace principal_arrears_days=0 if principal_arrears_days==. &principal_arrears_days_string=="ND,5"


* Drop potentially erroneous data entries
drop if interest_arrears_amount>= 100000000
drop if principal_arrears_amount>= 100000000
drop if interest_arrears_days>=10000
drop if principal_arrears_days>=10000




* Over 99.99% of the loans are from the countries below
keep if borrower_country=="BE" | borrower_country=="DE" | borrower_country=="ES" | borrower_country=="FR" | borrower_country=="IT" | borrower_country=="NL" | borrower_country=="PT"





* We drop lenders with very few obs. (<1000)
gen var=1
bysort lender: egen total=total(var)
drop if total<=1000

* Adoption quarter
bysort lender: egen adoption_quarter=min(pool_cutoff_quarter)


* We finally drop duplicates keeping the most complete data entry by poolid loanid borrowerid lender reporting quarter
 



**************************************************************************************************************
*  III. Calculate key variables 
**************************************************************************************************************

* Defaults*

gen in_default=0
replace in_default=1 if regexm(as121, "Y")==1
replace in_default=1 if regexm(as122, "Y")==1
* if as121 or as122= ND,5 in_default is zero
* 95%+ of the defaulted loans are classified as above. we further do 2 minor adjustments:
* if a loan is in default for more than 2 years, the loan is considered in default even if as121 or as122 is missing (ND) or N 
replace in_default=1 if interest_arrears_days>720 & principal_arrears_days>720
* if the default amount is not missing, the loan is considered in default even if as121 or as122 is missing (ND) or N 
replace in_default=1 if default_amount!=0 &default_amount!=. &default_amount<100000000


 
 
* Delinquent amount*
* Very extreme values in interest and principal arrears amount continue to exist in our sample (despite the above sample restrictions) and are winsorized before we calculate the ratio
winsor interest_arrears_amount, gen(interest_arrears_amountw) p(0.01)
winsor principal_arrears_amount, gen(principal_arrears_amountw) p(0.01)
winsor current_loan_balance, gen(current_loan_balancew) p(0.01)
gen delinquent_amt=(interest_arrears_amountw+principal_arrears_amountw)/current_loan_balancew
replace delinquent_amt=delinquent_amt*100
winsor delinquent_amt, gen(delinquent_amtw) p(0.01)



* Number of days in delinquency*
* In 99% of non-zero deliquent days, interest_arrears_days= principal_arrears_days
egen delinquent_daysmean=rowmean(interest_arrears_days principal_arrears_days)
egen delinquent_days=log(1+delinquent_daysmean)
winsor delinquent_days, gen(delinquent_daysw) p(0.01)



* Loss given default*
replace loss_given_default=loss_given_default/100
winsor loss_given_default, gen(loss_given_defaultw) p(0.01)





* Main independent variable

* Tranparency*
gen transparency=0
replace transparency=1 if quarter_origination>=adoption_quarter





* Controls
winsor interest_rate, gen(interest_ratew) p(0.01)

gen secured=0
replace secured=1 if seniority==1
* For collateral, the variable "seniority" in the loan data sample is incomplete. We use the "Collateral" dataset of ED where we identified whether a loan in a pool is collateralized. The SME_collateral.dta is a dataset that includes whether a loan is included in this dataset
sort loan_id pool_id
merge loan_id pool_id using "F:\SME_collateral.dta"
drop if var==.
drop _m
replace secured=1 if collateral==1
drop collateral
 
 
* Securitized loan amount is static thus we deflate by original loan amount 
gen securitized_amount_defl=securitized_amount/original_loan_amount
winsor securitized_amount_defl, gen(securitized_amount_deflw) p(0.01)

gen yrs_to_maturity=(loan_maturity_date-pool_cutoff_date)/360
gen years_to_maturity=log(1+yrs_to_maturity)
winsor years_to_maturity, gen(years_to_maturityw) p(0.01)

save summary_sme_loans, replace




/* For prior lending relationships, the variable "Obligor is a Customer since?" (as20) is incomplete. 
We structure our lending relationship variable. To do so, we use the full dataset without sample restrictions. No loop is necessary because prior relations are not common.*/

{use "F:\SME_loans.dta"
contract lender borrower_id year_origination
gen borrower_lender=string(borrower_id)+"/"+string(lender)
sort borrower_lender year_origination
gen prior_relation=0
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-1]<=5 &year_origination[_n-1]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-2]<=5 &year_origination[_n-2]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-3]<=5 &year_origination[_n-3]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-4]<=5 &year_origination[_n-4]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-5]<=5 &year_origination[_n-5]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-6]<=5 &year_origination[_n-6]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-7]<=5 &year_origination[_n-7]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-8]<=5 &year_origination[_n-8]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-9]<=5 &year_origination[_n-9]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-10]<=5 &year_origination[_n-10]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-11]<=5 &year_origination[_n-11]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-12]<=5 &year_origination[_n-12]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-13]<=5 &year_origination[_n-13]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-14]<=5 &year_origination[_n-14]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-15]<=5 &year_origination[_n-15]!=.
drop  borrower_lender 
sort borrower_id lender year_origination
save relation.dta 
}


sort borrower_id lender year_origination
merge borrower_id lender year_origination using relation.dta
drop if var==.
drop _m
save,replace




* Fixed effects

gen loan_purposel=.
replace loan_purposel=1 if loan_purpose==12
replace loan_purposel=2 if loan_purpose==1 | loan_purpose==3 | loan_purpose==5 | loan_purpose==6 | loan_purpose==11
replace loan_purposel=3 if loan_purpose==2 | loan_purpose==4 | loan_purpose==7 | loan_purpose==8 | loan_purpose==9 | loan_purpose==10
replace loan_purposel=4 if loan_purpose==13  
replace loan_purposel=4 if missing(loan_purpose)



save summary_sme_loans, replace

 
**************************************************************************************************************
* IV. Table 3, Panel A and B: Baseline regressions 
**************************************************************************************************************


* Panel A
reg delinquent_amtw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

reg delinquent_daysw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

reg loss_given_defaultw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

probit in_default transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation brtp_* tp_* qt_* pur_* ind_* abs_*, r cluster (pool_idl)
mfx


* Panel B

gen quarter_origination=qofd(loan_origination_date)
format quarter_origination %tq
gen keep=0
replace keep=1 if quarter_origination==212 
replace keep=1 if quarter_origination==213

reg delinquent_amtw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

reg delinquent_daysw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

reg loss_given_defaultw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

probit in_default transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation brtp_* tp_* qt_* pur_* ind_* abs_* if keep==1, r cluster (pool_idl)
mfx

* For Panel C, we manually identified banks that borrowed from ECB ABS repo before 2013Q1
*********************************************************************************************************************************************************
*
*  Enhancing Loan Quality through Transparency: Evidence from the European Central Bank Loan Level Reporting Initiative
*
*  Aytekin Ertan, Maria Loumioti and Regina Wittenberg Moerman
*
*  This do-file shows the code for converting ED SME loan raw data (version: June 4-6 2014) to the loan sample used in the analyses 
*
*********************************************************************************************************************************************************
*
*  Please refer to the attached SME Data Template for more details on dataset content and variable names
*
*********************************************************************************************************************************************************

 
********************************************************************************
*  I. Read and clean key ED SME loan items 
********************************************************************************

use "F:\SME_loans.dta",replace 

* Data submission date; As1 manually cleaned (e.g., when bank names were entered together with the data submission date)
gen pool_cutoff_date = date(as1, "YMD")
gen pool_cutoff_month=month(pool_cutoff_date)
gen pool_cutoff_day=day(pool_cutoff_date)
gen pool_cutoff_year=year(pool_cutoff_date)

/* Reporting date by quarter may not be the same across all banks. Most banks typically report at the beginning of a calendar quarter, but some banks report just before the quarter starts. 
To alleviate this reporting mismatch across banks, we match loans to the reporting quarter if they are reported before the calendar quarter’s start date. 
For example, if the pool_cutoff_date is Dec 20 2012 (June 30 2013), these observations are matched to the reporting quarter Q1 of 2013 (the reporting quarter Q3 of 2013).
We fix these reporting differences by bank manually, but the process could be summarized as follows*/

replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==12 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==3 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==6 &pool_cutoff_day>15 &pool_cutoff_day<=31
replace pool_cutoff_date=pool_cutoff_date+17 if pool_cutoff_month==9 &pool_cutoff_day>15 &pool_cutoff_day<=31


format pool_cutoff_date %td
gen pool_cutoff_quarter=qofd(pool_cutoff_date)
format pool_cutoff_quarter %tq

* ABS name; ABS names are cleaned manually 
rename as2 pool_id
replace pool_id=lower(pool_id)
encode pool_id, gen(pool_idl)

* Unique loan id by poolid
rename as3 loan_id

* Issuing bank name; bank names are cleaned manually
rename as4 lender
replace lender=lower(lender)
replace lender=trim(lender)

* Servicer bank which is mostly the issuing bank. Servicer names and servicer ids (sometimes the bank name) are also cleaned manually 
rename as5 servicer_id
rename as6 servicer_name
replace servicer_name=lower(servicer_name)
replace servicer_name=trim(servicer_name)

 
rename as7 borrower_id
rename as15 borrower_country

rename as18 borrower_type
replace borrower_type="" if regexm(borrower_type, "ND")==1
destring borrower_type, force replace
replace borrower_type=5 if borrower_type==.

rename as25 asset_type

rename as42 borrower_industry_long
replace borrower_industry_long="" if regexm(borrower_industry_long, "ND")==1
gen borrower_industry=substr(borrower_industry_long, 1, 1) 
replace borrower_industry="22" if borrower_industry==""
encode borrower_industry, gen(borrower_industryl)


rename as26 seniority 
destring seniority, force replace

rename as65 loan_type
destring loan_type, force replace
replace loan_type=3 if loan_type==.

rename as37 loss_given_default 
destring loss_given_default, force replace 
  

* Origination and maturity dates are in string(YYYY-MM) format. We format these in %td as follows:
rename as50 loan_origination_date
split loan_origination_date, p(“-“)
destring loan_origination_date1, force replace
destring loan_origination_date2, force replace
rename loan_origination_date1 year
rename loan_origination_date2 month
gen day=1
gen loan_origination_datel=mdy(month, day, year)
drop loan_origination_date day year month
rename loan_origination_datel loan_origination_date
format loan_origination_date %td
gen year_origination=yofd(loan_origination_date)
gen quarter_origination=qofd(loan_origination_date)

rename as51 loan_maturity_date
split loan_maturity_date, p(“-“)
destring loan_maturity_date1, force replace
destring loan_maturity_date2, force replace
rename loan_maturity_date1 year
rename loan_maturity_date2 month
gen day=1
gen loan_maturity_datel=mdy(month, day, year)
drop loan_maturity_date day year month
rename loan_maturity_datel loan_maturity_date
format loan_maturity_date %td
gen year_maturity=yofd(loan_maturity_date)


rename as54 original_loan_amount
destring original_loan_amount, force replace
rename as55 current_loan_balance
destring current_loan_balance, force replace 
rename as56 securitized_amount
destring securitized_amount, force replace



* Some loan amounts are negative, which are considered an error given that these are less than 1% of the population
replace current_loan_balance=abs(current_loan_balance)
replace original_loan_amount=abs(original_loan_amount)
replace securitized_amount=abs(securitized_amount)



rename as57 loan_purpose
destring loan_purpose, force replace


rename as80 interest_rate
destring interest_rate, force replace 

rename as123 default_reason
rename as125 default_amount
destring default_amount, force replace 
replace default_amount=abs(default_amount)

rename as115 interest_arrears_amount_string
rename as117 principal_arrears_amount_string
destring interest_arrears_amount_string, gen(interest_arrears_amount)
destring principal_arrears_amount_string,  gen(principal_arrears_amount)

* Some loan amounts are negative, which are considered an error given that these are less than 1% of the population
replace interest_arrears_amount=abs(interest_arrears_amount)
replace principal_arrears_amount=abs(principal_arrears_amount)


rename as116 interest_arrears_days_string
rename as118 principal_arrears_days_string
destring interest_arrears_days_string, gen(interest_arrears_days)
destring principal_arrears_days_string, gen (principal_arrears_days)

* Some loan days are negative, which are considered an error given that these are less than 1% of the population
replace interest_arrears_days=abs(interest_arrears_days)
replace principal_arrears_days=abs(principal_arrears_days)





********************************************************************************
*  II. Impose sample restrictions 
********************************************************************************

* Focus on loans; drop guarantees, participation rights, overdrafts etc. for consistency. 95%+ of our data are loans
keep if asset_type=="1"



* Over 99.99% of the loans are not hedged; remove those coded as hedged loans
keep if as53=="N"



* Drop potentially erroneous data
/* As described above, when lender/ABS is populated by a code/number, if possible we manually replace these codes with the relevant unique name. 
ABS and lenders that cannot be uniquely identified are manually dropped. We also identify missing bank names looking at the servicer id or pool id/name*/


drop if lender==""  &servicer_name==""
replace lender=servicer_name if lender==""
 
* Several banks submitted loan data (incomplete) to test the new reporting software in May/June 2012 
drop if pool_cutoff_year==2012



* Drop very small SME loans
drop if original_loan_amount<1000


* When missing, we consider that current/securitized loan balance = loan original balance if the loan is issued in the same quarter
replace current_loan_balance=original_loan_amount if current_loan_balance==. & quarter_origination==pool_cutoff_quarter
replace securitized_amount=original_loan_amount if securitized_amount==. & quarter_origination==pool_cutoff_quarter
drop if current_loan_balance==.
drop if securitized_amount==.


* When missing, continuous values can also be assigned 999 (primarily for interest rate, loss given default) or values greater than 100000000 (primarily for loan amts)
drop if original_loan_amount>=100000000
drop if securitized_amount>=100000000
drop if current_loan_balance>=100000000
drop if current_loan_balance==0
* Securitized loan amount may be 0 if the loan was not securitized upfront
 
* Drop potentially erroneous data entries
drop if securitized_amount>original_loan_amount
drop if current_loan_balance>original_loan_amount
 



* Drop potentially erroneous data loan dates
drop if loan_origination_date==.
drop if loan_maturity_date==.
gen year_origination=yofd(loan_origination_date)
drop if year_origination>2014

* Exclude loans issues during the European credit bubble
drop if year_origination<2009



* Drop potentially erroneous maturity dates; 99.9% of the loans mature before 2053
gen year_maturity=yofd(loan_maturity_date)
drop if year_maturity>2053
* There are about 1000 obs (out of about 3m) with loans that mature in 2012. Since some banks reported in late December 2012, we keep these obs.
drop if year_maturity<2012


* Drop potentially erroneous data entries
drop if loan_origination_date>loan_maturity_date


* Drop potentially erroneous data entries; making sure that interest rates are expressed as % across all loans; drop if interest rate>15% (missing or erroneous), upper 99% of interest rate is at 10.38%  
drop if interest_rate==0
replace interest_rate=interest_rate*100 if interest_rate<1
replace interest_rate=. if interest_rate<1 | interest_rate>15
drop if interest_rate==.

* Drop potentially erroneous data entries; lgd cannot be greater than 100. This cutoff primarily takes care of lgd missing values labeled as 999.99
replace loss_given_default=loss_given_default*100 if loss_given_default>0 & loss_given_default<=1
drop if loss_given_default>100  


* ND,5 classification refers to data not relevant at the present time, i.e. no arrears or defaults are relevant at the present time
replace interest_arrears_amount=0 if interest_arrears_amount==. &interest_arrears_amount_string=="ND,5"
replace principal_arrears_amount=0 if principal_arrears_amount==. &principal_arrears_amount_string=="ND,5"
replace interest_arrears_days=0 if interest_arrears_days==. &interest_arrears_days_string=="ND,5"
replace principal_arrears_days=0 if principal_arrears_days==. &principal_arrears_days_string=="ND,5"


* Drop potentially erroneous data entries
drop if interest_arrears_amount>= 100000000
drop if principal_arrears_amount>= 100000000
drop if interest_arrears_days>=10000
drop if principal_arrears_days>=10000




* Over 99.99% of the loans are from the countries below
keep if borrower_country=="BE" | borrower_country=="DE" | borrower_country=="ES" | borrower_country=="FR" | borrower_country=="IT" | borrower_country=="NL" | borrower_country=="PT"





* We drop lenders with very few obs. (<1000)
gen var=1
bysort lender: egen total=total(var)
drop if total<=1000

* Adoption quarter
bysort lender: egen adoption_quarter=min(pool_cutoff_quarter)


* We finally drop duplicates keeping the most complete data entry by poolid loanid borrowerid lender reporting quarter
 



**************************************************************************************************************
*  III. Calculate key variables 
**************************************************************************************************************

* Defaults*

gen in_default=0
replace in_default=1 if regexm(as121, "Y")==1
replace in_default=1 if regexm(as122, "Y")==1
* if as121 or as122= ND,5 in_default is zero
* 95%+ of the defaulted loans are classified as above. we further do 2 minor adjustments:
* if a loan is in default for more than 2 years, the loan is considered in default even if as121 or as122 is missing (ND) or N 
replace in_default=1 if interest_arrears_days>720 & principal_arrears_days>720
* if the default amount is not missing, the loan is considered in default even if as121 or as122 is missing (ND) or N 
replace in_default=1 if default_amount!=0 &default_amount!=. &default_amount<100000000


 
 
* Delinquent amount*
* Very extreme values in interest and principal arrears amount continue to exist in our sample (despite the above sample restrictions) and are winsorized before we calculate the ratio
winsor interest_arrears_amount, gen(interest_arrears_amountw) p(0.01)
winsor principal_arrears_amount, gen(principal_arrears_amountw) p(0.01)
winsor current_loan_balance, gen(current_loan_balancew) p(0.01)
gen delinquent_amt=(interest_arrears_amountw+principal_arrears_amountw)/current_loan_balancew
replace delinquent_amt=delinquent_amt*100
winsor delinquent_amt, gen(delinquent_amtw) p(0.01)



* Number of days in delinquency*
* In 99% of non-zero deliquent days, interest_arrears_days= principal_arrears_days
egen delinquent_daysmean=rowmean(interest_arrears_days principal_arrears_days)
egen delinquent_days=log(1+delinquent_daysmean)
winsor delinquent_days, gen(delinquent_daysw) p(0.01)



* Loss given default*
replace loss_given_default=loss_given_default/100
winsor loss_given_default, gen(loss_given_defaultw) p(0.01)





* Main independent variable

* Tranparency*
gen transparency=0
replace transparency=1 if quarter_origination>=adoption_quarter





* Controls
winsor interest_rate, gen(interest_ratew) p(0.01)

gen secured=0
replace secured=1 if seniority==1
* For collateral, the variable "seniority" in the loan data sample is incomplete. We use the "Collateral" dataset of ED where we identified whether a loan in a pool is collateralized. The SME_collateral.dta is a dataset that includes whether a loan is included in this dataset
sort loan_id pool_id
merge loan_id pool_id using "F:\SME_collateral.dta"
drop if var==.
drop _m
replace secured=1 if collateral==1
drop collateral
 
 
* Securitized loan amount is static thus we deflate by original loan amount 
gen securitized_amount_defl=securitized_amount/original_loan_amount
winsor securitized_amount_defl, gen(securitized_amount_deflw) p(0.01)

gen yrs_to_maturity=(loan_maturity_date-pool_cutoff_date)/360
gen years_to_maturity=log(1+yrs_to_maturity)
winsor years_to_maturity, gen(years_to_maturityw) p(0.01)

save summary_sme_loans, replace




/* For prior lending relationships, the variable "Obligor is a Customer since?" (as20) is incomplete. 
We structure our lending relationship variable. To do so, we use the full dataset without sample restrictions. No loop is necessary because prior relations are not common.*/

{use "F:\SME_loans.dta"
contract lender borrower_id year_origination
gen borrower_lender=string(borrower_id)+"/"+string(lender)
sort borrower_lender year_origination
gen prior_relation=0
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-1]<=5 &year_origination[_n-1]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-2]<=5 &year_origination[_n-2]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-3]<=5 &year_origination[_n-3]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-4]<=5 &year_origination[_n-4]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-5]<=5 &year_origination[_n-5]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-6]<=5 &year_origination[_n-6]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-7]<=5 &year_origination[_n-7]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-8]<=5 &year_origination[_n-8]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-9]<=5 &year_origination[_n-9]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-10]<=5 &year_origination[_n-10]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-11]<=5 &year_origination[_n-11]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-12]<=5 &year_origination[_n-12]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-13]<=5 &year_origination[_n-13]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-14]<=5 &year_origination[_n-14]!=.
by borrower_lender: replace prior_relation=1 if year_origination-year_origination[_n-15]<=5 &year_origination[_n-15]!=.
drop  borrower_lender 
sort borrower_id lender year_origination
save relation.dta 
}


sort borrower_id lender year_origination
merge borrower_id lender year_origination using relation.dta
drop if var==.
drop _m
save,replace




* Fixed effects

gen loan_purposel=.
replace loan_purposel=1 if loan_purpose==12
replace loan_purposel=2 if loan_purpose==1 | loan_purpose==3 | loan_purpose==5 | loan_purpose==6 | loan_purpose==11
replace loan_purposel=3 if loan_purpose==2 | loan_purpose==4 | loan_purpose==7 | loan_purpose==8 | loan_purpose==9 | loan_purpose==10
replace loan_purposel=4 if loan_purpose==13  
replace loan_purposel=4 if missing(loan_purpose)



save summary_sme_loans, replace

 
**************************************************************************************************************
* IV. Table 3, Panel A and B: Baseline regressions 
**************************************************************************************************************


* Panel A
reg delinquent_amtw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

reg delinquent_daysw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

reg loss_given_defaultw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_idl i.pool_cutoff_quarter, r cluster (pool_idl)

probit in_default transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation brtp_* tp_* qt_* pur_* ind_* abs_*, r cluster (pool_idl)
mfx


* Panel B

gen quarter_origination=qofd(loan_origination_date)
format quarter_origination %tq
gen keep=0
replace keep=1 if quarter_origination==212 
replace keep=1 if quarter_origination==213

reg delinquent_amtw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

reg delinquent_daysw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

reg loss_given_defaultw transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation i.borrower_type i.loan_type i.loan_purposel i.borrower_industryl i.pool_cutoff_quarter i.pool_idl if keep==1, r cluster (pool_idl)

probit in_default transparency interest_ratew secured years_to_maturityw securitized_amount_deflw prior_relation brtp_* tp_* qt_* pur_* ind_* abs_* if keep==1, r cluster (pool_idl)
mfx

* For Panel C, we manually identified banks that borrowed from ECB ABS repo before 2013Q1

